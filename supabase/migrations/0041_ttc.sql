-- =============================================================================
--  0041 — Trying to Conceive
-- -----------------------------------------------------------------------------
--  The cloud half of the TTC stage. Deliberately ADDITIVE: no existing table is
--  reshaped, and pregnancy and parenting are untouched. Part 4 of the TTC master
--  document proposes re-modelling everything around a Family Journey Graph;
--  doing that to 56 live tables carrying real user data in order to ship a third
--  stage is the expensive kind of risk, so the graph arrives as ONE new
--  append-only table (journey_timeline) that the other stages can backfill into
--  later at their own pace.
--
--  Runs after 0009 — every couple-scoped policy here uses public.my_partner_id().
--
-- -----------------------------------------------------------------------------
--  THE PRIVACY DECISION THAT SHAPES THIS FILE
--
--  Her raw cycle is OWN-ROW. Her partner cannot read ttc_cycles or
--  ttc_cycle_signals at all — not through a policy he could be granted later,
--  and not by accident.
--
--  But his Today screen shows the chapter the couple is in, and the chapter is
--  derived from her cycle. Rather than widening read access on the cycle and
--  *promising* the client will only show the derived value, the derived value
--  is written to ttc_journeys — which IS couple-scoped — and the raw dates stay
--  private in every direction.
--
--  This is the same shape as the baby-name matches in 0009: when an answer must
--  come from data one person should not see raw, keep the rows private and put
--  the computed answer in front of them. Anyone can write their own client, so
--  the database has to enforce it rather than the app promising it.
-- =============================================================================

-- ---------------------------------------------------------------------------
--  Life stage — which chapter of ParentVeda a family is in.
-- ---------------------------------------------------------------------------
--  The auth screen's "I AM CURRENTLY: Trying / Pregnant / New parent" selector
--  has existed for a long time and its answer was thrown away. This is where it
--  finally lands.

alter table public.profiles
  add column if not exists life_stage       text,
  add column if not exists life_stage_at    timestamptz;

alter table public.profiles
  drop constraint if exists profiles_life_stage_check;

alter table public.profiles
  add constraint profiles_life_stage_check
  check (life_stage is null or life_stage in ('trying', 'pregnancy', 'parenting'));

comment on column public.profiles.life_stage is
  'trying | pregnancy | parenting. Null means never declared, which is a real state — do not default it to pregnancy.';


-- ---------------------------------------------------------------------------
--  ttc_journeys — the journey-level facts, shared by the couple
-- ---------------------------------------------------------------------------
--  One row per user. Both partners can read each other's row, which is what
--  lets his Today show the right chapter without ever reading her cycle.

create table if not exists public.ttc_journeys (
  user_id                 uuid primary key references auth.users (id) on delete cascade,
  journey_start           date,
  path                    text not null default 'natural',
  pregnancy_confirmed_on  date,
  partner_joined          boolean not null default false,

  -- The DERIVED answer, written by the client from TtcChapterEngine. Her
  -- partner reads this instead of her cycle. Nullable because a couple with no
  -- data logged has no chapter to report yet.
  current_chapter         text,
  updated_at              timestamptz not null default now(),

  constraint ttc_journeys_path_check check (
    path in ('natural', 'ovulationInduction', 'iui', 'ivf', 'frozenEmbryoTransfer')
  ),
  constraint ttc_journeys_chapter_check check (
    current_chapter is null or current_chapter in (
      'preparingTogether', 'knowingYourRhythm', 'tryingTogether',
      'theWaitingDays', 'aNewBeginning'
    )
  )
);

alter table public.ttc_journeys enable row level security;

drop policy if exists ttc_journeys_rw on public.ttc_journeys;
create policy ttc_journeys_rw on public.ttc_journeys
  for all
  using (auth.uid() = user_id or user_id = public.my_partner_id())
  with check (auth.uid() = user_id);   -- you may only WRITE your own row


-- ---------------------------------------------------------------------------
--  ttc_cycles — her period starts. OWN-ROW. Never couple-scoped.
-- ---------------------------------------------------------------------------
--  The only cycle fact stored. Everything derived — cycle day, ovulation
--  estimate, the fertile window — is computed by the engine and never written
--  here, so there is exactly one place the arithmetic lives and no stale copy
--  can drift.

create table if not exists public.ttc_cycles (
  id           text primary key,            -- app-generated, so sync is an idempotent merge
  user_id      uuid not null references auth.users (id) on delete cascade,
  started_on   date not null,
  created_at   timestamptz not null default now(),
  unique (user_id, started_on)              -- logging the same day twice is a no-op
);

create index if not exists ttc_cycles_user_idx
  on public.ttc_cycles (user_id, started_on desc);

alter table public.ttc_cycles enable row level security;

drop policy if exists ttc_cycles_own on public.ttc_cycles;
create policy ttc_cycles_own on public.ttc_cycles
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);


-- ---------------------------------------------------------------------------
--  ttc_cycle_signals — LH positives and temperature shifts. OWN-ROW.
-- ---------------------------------------------------------------------------

create table if not exists public.ttc_cycle_signals (
  id            text primary key,
  user_id       uuid not null references auth.users (id) on delete cascade,
  cycle_start   date not null,
  kind          text not null,
  cycle_day     int  not null,
  created_at    timestamptz not null default now(),

  constraint ttc_signals_kind_check check (kind in ('lh', 'temperature')),
  constraint ttc_signals_day_check  check (cycle_day between 1 and 90),
  unique (user_id, cycle_start, kind)
);

alter table public.ttc_cycle_signals enable row level security;

drop policy if exists ttc_cycle_signals_own on public.ttc_cycle_signals;
create policy ttc_cycle_signals_own on public.ttc_cycle_signals
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);


-- ---------------------------------------------------------------------------
--  ttc_logs — every tracker: symptoms, weight, sleep, mood, stress, lifestyle,
--  movement, partner health. OWN-ROW: each partner logs their own body.
-- ---------------------------------------------------------------------------
--  One row per (tracker, field, day). Re-logging the same field on the same day
--  OVERWRITES rather than appending — these are observations of a day, not a
--  stream of events, and a corrected mis-tap must not leave two contradictory
--  rows for the same afternoon.

create table if not exists public.ttc_logs (
  user_id     uuid not null references auth.users (id) on delete cascade,
  tracker     text not null,
  field       text not null,
  logged_on   date not null,
  value       double precision not null,
  note        text,
  updated_at  timestamptz not null default now(),
  primary key (user_id, tracker, field, logged_on)
);

create index if not exists ttc_logs_user_idx
  on public.ttc_logs (user_id, tracker, logged_on desc);

alter table public.ttc_logs enable row level security;

drop policy if exists ttc_logs_own on public.ttc_logs;
create policy ttc_logs_own on public.ttc_logs
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);


-- ---------------------------------------------------------------------------
--  ttc_journal — the shared journal. COUPLE-SCOPED, both directions.
-- ---------------------------------------------------------------------------
--  Unlike baby-name votes, there is no reason for a shared journal to keep
--  secrets: seeing what your partner wrote is the feature. Entries are
--  attributed by author_id and both partners read and write the pair's rows.

create table if not exists public.ttc_journal (
  id          text primary key,            -- app-generated
  user_id     uuid not null references auth.users (id) on delete cascade,
  author_id   uuid not null references auth.users (id) on delete cascade,
  kind        text not null,
  body        text not null,
  prompt      text,
  photo_path  text,
  written_at  timestamptz not null default now(),

  constraint ttc_journal_kind_check check (
    kind in ('memory', 'letter', 'question', 'feeling')
  )
);

create index if not exists ttc_journal_user_idx
  on public.ttc_journal (user_id, written_at desc);

alter table public.ttc_journal enable row level security;

drop policy if exists ttc_journal_couple on public.ttc_journal;
create policy ttc_journal_couple on public.ttc_journal
  for all
  using (auth.uid() = user_id or user_id = public.my_partner_id())
  -- You may write into the couple's journal, but only ever as YOURSELF: the
  -- author is the one field a client must not be able to forge.
  with check (
    (auth.uid() = user_id or user_id = public.my_partner_id())
    and author_id = auth.uid()
  );


-- ---------------------------------------------------------------------------
--  ttc_supplements — what they take. COUPLE-SCOPED.
-- ---------------------------------------------------------------------------
--  Both lists live on one screen because zinc and CoQ10 are his in the same way
--  folic acid is hers, so both partners can see the whole list.

create table if not exists public.ttc_supplements (
  id          text primary key,
  user_id     uuid not null references auth.users (id) on delete cascade,
  for_partner boolean not null default false,
  name        text not null,
  dose        text not null default '',
  created_at  timestamptz not null default now()
);

create table if not exists public.ttc_supplement_taken (
  user_id        uuid not null references auth.users (id) on delete cascade,
  supplement_id  text not null references public.ttc_supplements (id) on delete cascade,
  taken_on       date not null,
  primary key (supplement_id, taken_on)
);

alter table public.ttc_supplements      enable row level security;
alter table public.ttc_supplement_taken enable row level security;

drop policy if exists ttc_supplements_couple on public.ttc_supplements;
create policy ttc_supplements_couple on public.ttc_supplements
  for all
  using (auth.uid() = user_id or user_id = public.my_partner_id())
  with check (auth.uid() = user_id or user_id = public.my_partner_id());

drop policy if exists ttc_supplement_taken_couple on public.ttc_supplement_taken;
create policy ttc_supplement_taken_couple on public.ttc_supplement_taken
  for all
  using (auth.uid() = user_id or user_id = public.my_partner_id())
  with check (auth.uid() = user_id or user_id = public.my_partner_id());


-- ---------------------------------------------------------------------------
--  ttc_ritual — the five-minute daily ritual. COUPLE-SCOPED.
-- ---------------------------------------------------------------------------
--  Shared because the ritual is shared: "Today's conversation" is not something
--  one person completes alone.
--
--  Note what is NOT here: no streak column. The streak is derived from these
--  rows, so it cannot be stored wrong, and there is nowhere for a "longest
--  streak" or a "streak lost" flag to appear later.

create table if not exists public.ttc_ritual (
  user_id      uuid not null references auth.users (id) on delete cascade,
  part         text not null,
  completed_on date not null,
  primary key (user_id, part, completed_on),

  constraint ttc_ritual_part_check check (
    part in ('reflection', 'breath', 'conversation', 'gratitude', 'action')
  )
);

alter table public.ttc_ritual enable row level security;

drop policy if exists ttc_ritual_couple on public.ttc_ritual;
create policy ttc_ritual_couple on public.ttc_ritual
  for all
  using (auth.uid() = user_id or user_id = public.my_partner_id())
  with check (auth.uid() = user_id or user_id = public.my_partner_id());


-- ---------------------------------------------------------------------------
--  journey_timeline — one continuous life story, across every stage
-- ---------------------------------------------------------------------------
--  The Family Timeline. Belongs to NO stage: TTC is simply the first to write
--  to it, and pregnancy and parenting backfill into the same log later without
--  changing shape.
--
--  Append-only by design. There is no update policy, deliberately — a life
--  story you can silently rewrite is not a record. Deleting your own row is
--  allowed, because a mis-tapped positive test has to be undoable.

create table if not exists public.journey_timeline (
  id          text primary key,            -- app-generated and stable → idempotent
  user_id     uuid not null references auth.users (id) on delete cascade,
  stage       text not null,
  kind        text not null,
  happened_on date not null,
  title_en    text not null,
  title_hi    text not null,
  detail_en   text,
  detail_hi   text,
  created_at  timestamptz not null default now(),

  constraint journey_timeline_stage_check check (
    stage in ('trying', 'pregnancy', 'parenting')
  ),
  constraint journey_timeline_kind_check check (
    kind in ('milestone', 'medical', 'written', 'people', 'action')
  )
);

create index if not exists journey_timeline_user_idx
  on public.journey_timeline (user_id, happened_on);

alter table public.journey_timeline enable row level security;

-- Read: the whole couple's story.
drop policy if exists journey_timeline_read on public.journey_timeline;
create policy journey_timeline_read on public.journey_timeline
  for select
  using (auth.uid() = user_id or user_id = public.my_partner_id());

-- Insert: your own moments only.
drop policy if exists journey_timeline_insert on public.journey_timeline;
create policy journey_timeline_insert on public.journey_timeline
  for insert with check (auth.uid() = user_id);

-- Delete: your own moments only. No UPDATE policy anywhere — append-only.
drop policy if exists journey_timeline_delete on public.journey_timeline;
create policy journey_timeline_delete on public.journey_timeline
  for delete using (auth.uid() = user_id);


-- ---------------------------------------------------------------------------
--  Grants
-- ---------------------------------------------------------------------------
--  Two gates guard every request: the grant (may this role touch the table at
--  all) and RLS (which rows). Both are needed.

grant select, insert, update, delete on
  public.ttc_journeys,
  public.ttc_cycles,
  public.ttc_cycle_signals,
  public.ttc_logs,
  public.ttc_journal,
  public.ttc_supplements,
  public.ttc_supplement_taken,
  public.ttc_ritual
to authenticated;

-- Append-only: no UPDATE grant, so the append-only rule holds even if a policy
-- is added carelessly later.
grant select, insert, delete on public.journey_timeline to authenticated;
