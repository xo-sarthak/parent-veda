-- =====================================================================
-- 0006_scans_appointments.sql — completed scans + appointments (ScansStore)
-- Run AFTER 0001.
-- =====================================================================

-- ---- completed_scans  (identity = scan_id; PK = user_id + scan_id) ----
create table public.completed_scans (
  user_id     uuid        not null references auth.users (id) on delete cascade,
  scan_id     text        not null,
  date_iso    timestamptz,
  notes       text        not null default '',
  created_at  timestamptz not null default now(),
  primary key (user_id, scan_id)
);
grant select, insert, update, delete on public.completed_scans to authenticated;
alter table public.completed_scans enable row level security;
create policy "completed_scans own select" on public.completed_scans for select using (auth.uid() = user_id);
create policy "completed_scans own insert" on public.completed_scans for insert with check (auth.uid() = user_id);
create policy "completed_scans own update" on public.completed_scans for update using (auth.uid() = user_id);
create policy "completed_scans own delete" on public.completed_scans for delete using (auth.uid() = user_id);


-- ---- appointments ----
create table public.appointments (
  id          text        primary key,
  user_id     uuid        not null references auth.users (id) on delete cascade,
  title       text        not null default '',
  date_iso    timestamptz,
  time        text        not null default '',
  location    text        not null default '',
  doctor      text        not null default '',
  type        text        not null default 'doctor'
                            check (type in ('doctor','scan','test','vaccination','custom')),
  notes       text        not null default '',
  status      text        not null default 'upcoming'
                            check (status in ('upcoming','completed')),
  created_at  timestamptz not null default now()
);
grant select, insert, update, delete on public.appointments to authenticated;
alter table public.appointments enable row level security;
create policy "appointments own select" on public.appointments for select using (auth.uid() = user_id);
create policy "appointments own insert" on public.appointments for insert with check (auth.uid() = user_id);
create policy "appointments own update" on public.appointments for update using (auth.uid() = user_id);
create policy "appointments own delete" on public.appointments for delete using (auth.uid() = user_id);
