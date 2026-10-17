-- =============================================================================
--  0102 — Onboarding V3: the answers that must outlive the phone (2026-10-17)
-- -----------------------------------------------------------------------------
--  Onboarding V3 (docs/ONBOARDING.md) asks fewer things that go nowhere. The
--  answers that someone OTHER than this phone needs to read get a column or a
--  table here. Everything only her own phone reads (age band, gentle, twins,
--  what helps him) rides in the family profile's one jsonb block in
--  user_state, and needs nothing new.
--
--  The rule we used to choose (docs/BACKEND-PATTERNS.md §16jj):
--   · a COLUMN when another person, another service, or a query must read it
--     (the partner, the WhatsApp sender, an admin report);
--   · the jsonb BLOB when only this person's phone ever reads it. The blob is
--     free to change shape; a column is a contract with every reader.
--
--  1. profiles.due_date_source + profiles.dating_date
--     Until now only due_date reached the cloud. A due date from a dating
--     scan or an embryo transfer is the CLINIC's (DueDateSource.clinicOwned),
--     and the app must not recompute it. A new phone pulled the date without
--     the source, so it treated a clinic date as our own estimate. The raw
--     date she gave (last period, scan or transfer day) is kept too, so the
--     due date can be explained and re-derived, never guessed.
--  2. children.birth_mode + children.born_weeks
--     Corrected age (born early) and the postpartum recovery modes (birth
--     mode) are facts about the child, and the other parent's phone needs
--     them. They lived only in one parent's family-profile blob.
--  3. ttc_ready_plans — the Ready-to-Try plan, one row per person.
--     It was phone-only (STILL-OPEN §92.0). His side's card needs to read her
--     plan, and user_state has no partner read, so it is a real table with
--     the couple-scoped policy shape.
--  4. link_as_partner refuses to overwrite an existing link.
--     V3 lets either person type the other's code. The function used to set
--     partner_id on both rows unconditionally, so a code typed by mistake
--     would silently break an existing couple's link.
--
--  Safe to re-run: `if not exists`, `drop ... if exists`, `create or replace`.
-- =============================================================================


-- 1) profiles: where the due date came from, and the date she gave ------------
alter table public.profiles add column if not exists due_date_source text;
alter table public.profiles add column if not exists dating_date date;

alter table public.profiles drop constraint if exists profiles_due_date_source_check;
alter table public.profiles add constraint profiles_due_date_source_check
  check (due_date_source is null or due_date_source in
    ('unknown', 'lastPeriod', 'conception', 'ivfTransfer', 'scan', 'clinician'));


-- 2) children: how the baby was born, and how early --------------------------
alter table public.children add column if not exists birth_mode text;
alter table public.children add column if not exists born_weeks int;

alter table public.children drop constraint if exists children_birth_mode_check;
alter table public.children add constraint children_birth_mode_check
  check (birth_mode is null or birth_mode in ('normal', 'cSection', 'assisted', 'notSaid'));

alter table public.children drop constraint if exists children_born_weeks_check;
alter table public.children add constraint children_born_weeks_check
  check (born_weeks is null or born_weeks between 22 and 42);


-- 3) ttc_ready_plans: her plan and his part, readable by the couple ----------
create table if not exists public.ttc_ready_plans (
  user_id        uuid primary key references auth.users(id) on delete cascade,
  planned_start  date,
  already_trying boolean not null default false,
  -- ReadyPlanAnswers.toJson(): the plan's own answers. jsonb because only the
  -- plan screen reads their detail; planned_start is a column because the
  -- trying clock (and his card) read it.
  answers        jsonb not null default '{}'::jsonb,
  made_at        timestamptz,
  -- The phone's edit time (0097): newer wins, guarded below.
  updated_at     timestamptz not null default now()
);

alter table public.ttc_ready_plans enable row level security;

-- ⚠️ FOUR POLICIES, NOT ONE `for all`. A single `for all using (mine or my
-- partner's)` also lets the partner DELETE her row: `with check` only guards
-- the row being written, and a delete writes none. Read is couple-scoped;
-- every write is own-row.
drop policy if exists ttc_ready_plans_select on public.ttc_ready_plans;
create policy ttc_ready_plans_select on public.ttc_ready_plans
  for select using (auth.uid() = user_id or user_id = public.my_partner_id());

drop policy if exists ttc_ready_plans_insert on public.ttc_ready_plans;
create policy ttc_ready_plans_insert on public.ttc_ready_plans
  for insert with check (auth.uid() = user_id);

drop policy if exists ttc_ready_plans_update on public.ttc_ready_plans;
create policy ttc_ready_plans_update on public.ttc_ready_plans
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists ttc_ready_plans_delete on public.ttc_ready_plans;
create policy ttc_ready_plans_delete on public.ttc_ready_plans
  for delete using (auth.uid() = user_id);

-- Newer wins on the server too (0100's rule, one more table).
do $$
declare
  t text;
begin
  foreach t in array array[
    'ttc_ready_plans'
  ]
  loop
    execute format('drop trigger if exists %I on public.%I',
                   t || '_newer_wins', t);
    execute format(
      'create trigger %I before insert or update on public.%I '
      'for each row execute function public.pv_sync_newer_wins()',
      t || '_newer_wins', t);
  end loop;
end $$;


-- 4) link_as_partner: link, or refuse; never overwrite ------------------------
--  Either person may call it with the OTHER person's code (0009 assumed the
--  father typed the mother's). Returns the other person's id.
--  ⚠️ REFUSE, DON'T RE-PAIR. Re-linking to the same person is fine (a retry);
--  anyone already linked to someone else gets a clear refusal, and nothing is
--  written. A raise discards the whole call, so a half-written link (one
--  side updated, the other not) cannot happen.
create or replace function public.link_as_partner(code text)
returns uuid
language plpgsql
security definer set search_path = ''
as $$
declare
  me uuid := auth.uid();
  other_id uuid;
  my_partner uuid;
  their_partner uuid;
begin
  if me is null then
    raise exception 'Not signed in';
  end if;

  select id, partner_id into other_id, their_partner
  from public.profiles
  where pairing_code = upper(trim(code))
  limit 1;

  if other_id is null then
    raise exception 'Invalid pairing code';
  end if;
  if other_id = me then
    raise exception 'You cannot pair with your own code';
  end if;

  select partner_id into my_partner from public.profiles where id = me;

  if my_partner is not null and my_partner <> other_id then
    raise exception 'You are already linked with someone else';
  end if;
  if their_partner is not null and their_partner <> me then
    raise exception 'That code is already linked with someone else';
  end if;

  update public.profiles set partner_id = other_id where id = me;
  update public.profiles set partner_id = me       where id = other_id;

  return other_id;
end;
$$;

grant execute on function public.link_as_partner(text) to authenticated;
