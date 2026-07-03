-- =====================================================================
-- 0003_trackers.sql — weight, movement, kegel, contractions (ToolsStore)
-- Run AFTER 0001.
-- =====================================================================

-- ---- weight_profile  (ONE row per user; use upsert) ----
create table public.weight_profile (
  user_id     uuid        primary key references auth.users (id) on delete cascade,
  pre         numeric,                       -- pre-pregnancy weight (kg)
  height      numeric,                       -- height (cm)
  updated_at  timestamptz not null default now()
);
grant select, insert, update, delete on public.weight_profile to authenticated;
alter table public.weight_profile enable row level security;
create policy "weight_profile own select" on public.weight_profile for select using (auth.uid() = user_id);
create policy "weight_profile own insert" on public.weight_profile for insert with check (auth.uid() = user_id);
create policy "weight_profile own update" on public.weight_profile for update using (auth.uid() = user_id);
create policy "weight_profile own delete" on public.weight_profile for delete using (auth.uid() = user_id);


-- ---- weight_entries ----
create table public.weight_entries (
  id          text        primary key,
  user_id     uuid        not null references auth.users (id) on delete cascade,
  date_iso    date,
  time_iso    timestamptz,
  week        int         not null default 0,
  weight      numeric     not null default 0,
  notes       text        not null default '',
  created_at  timestamptz not null default now()
);
grant select, insert, update, delete on public.weight_entries to authenticated;
alter table public.weight_entries enable row level security;
create policy "weight_entries own select" on public.weight_entries for select using (auth.uid() = user_id);
create policy "weight_entries own insert" on public.weight_entries for insert with check (auth.uid() = user_id);
create policy "weight_entries own update" on public.weight_entries for update using (auth.uid() = user_id);
create policy "weight_entries own delete" on public.weight_entries for delete using (auth.uid() = user_id);


-- ---- movement_sessions  (kick tracking; times = jsonb array of timestamps) ----
create table public.movement_sessions (
  id          text        primary key,
  user_id     uuid        not null references auth.users (id) on delete cascade,
  start_iso   timestamptz,
  end_iso     timestamptz,                   -- null = session still active
  times       jsonb       not null default '[]'::jsonb,
  created_at  timestamptz not null default now()
);
grant select, insert, update, delete on public.movement_sessions to authenticated;
alter table public.movement_sessions enable row level security;
create policy "movement_sessions own select" on public.movement_sessions for select using (auth.uid() = user_id);
create policy "movement_sessions own insert" on public.movement_sessions for insert with check (auth.uid() = user_id);
create policy "movement_sessions own update" on public.movement_sessions for update using (auth.uid() = user_id);
create policy "movement_sessions own delete" on public.movement_sessions for delete using (auth.uid() = user_id);


-- ---- kegel_state  (ONE row per user; use upsert) ----
create table public.kegel_state (
  user_id       uuid        primary key references auth.users (id) on delete cascade,
  sessions      int         not null default 0,
  last          timestamptz,
  hold_adjust   int         not null default 0,
  rep_adjust    int         not null default 0,
  custom_hold   int,
  custom_relax  int,
  custom_reps   int,
  voice_on      boolean     not null default true,
  this_week     jsonb       not null default '[]'::jsonb,
  updated_at    timestamptz not null default now()
);
grant select, insert, update, delete on public.kegel_state to authenticated;
alter table public.kegel_state enable row level security;
create policy "kegel_state own select" on public.kegel_state for select using (auth.uid() = user_id);
create policy "kegel_state own insert" on public.kegel_state for insert with check (auth.uid() = user_id);
create policy "kegel_state own update" on public.kegel_state for update using (auth.uid() = user_id);
create policy "kegel_state own delete" on public.kegel_state for delete using (auth.uid() = user_id);


-- ---- kegel_history  (model has no id -> server-generated uuid) ----
create table public.kegel_history (
  id            uuid        primary key default gen_random_uuid(),
  user_id       uuid        not null references auth.users (id) on delete cascade,
  date_iso      timestamptz,
  hold_seconds  int         not null default 0,
  relax_seconds int         not null default 0,
  repetitions   int         not null default 0,
  feedback      text        not null default 'comfortable'
                              check (feedback in ('easy','comfortable','difficult')),
  created_at    timestamptz not null default now()
);
grant select, insert, update, delete on public.kegel_history to authenticated;
alter table public.kegel_history enable row level security;
create policy "kegel_history own select" on public.kegel_history for select using (auth.uid() = user_id);
create policy "kegel_history own insert" on public.kegel_history for insert with check (auth.uid() = user_id);
create policy "kegel_history own update" on public.kegel_history for update using (auth.uid() = user_id);
create policy "kegel_history own delete" on public.kegel_history for delete using (auth.uid() = user_id);


-- ---- contraction_sessions  (nested contractions stored as jsonb array) ----
create table public.contraction_sessions (
  id              text        primary key,
  user_id         uuid        not null references auth.users (id) on delete cascade,
  date_iso        date,
  contractions    jsonb       not null default '[]'::jsonb,  -- [{startIso,endIso,durationSeconds,intervalSeconds}]
  labor_response  text        check (labor_response in ('yes','no')),  -- nullable
  created_at      timestamptz not null default now()
);
grant select, insert, update, delete on public.contraction_sessions to authenticated;
alter table public.contraction_sessions enable row level security;
create policy "contraction_sessions own select" on public.contraction_sessions for select using (auth.uid() = user_id);
create policy "contraction_sessions own insert" on public.contraction_sessions for insert with check (auth.uid() = user_id);
create policy "contraction_sessions own update" on public.contraction_sessions for update using (auth.uid() = user_id);
create policy "contraction_sessions own delete" on public.contraction_sessions for delete using (auth.uid() = user_id);
