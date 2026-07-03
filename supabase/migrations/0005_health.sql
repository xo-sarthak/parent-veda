-- =====================================================================
-- 0005_health.sql — medications, medication logs, symptom logs
-- Run AFTER 0001.
-- =====================================================================

-- ---- medications  (MedicineStore / models/medication.dart) ----
create table public.medications (
  id            text        primary key,
  user_id       uuid        not null references auth.users (id) on delete cascade,
  name          text        not null default '',
  type          text        not null default 'custom'
                              check (type in ('supplement','medication','custom')),
  dose          text        not null default '',
  time          text        not null default '',
  frequency     text        not null default '',
  notes         text        not null default '',
  preset_key    text,                          -- iron|calcium|folicAcid|vitaminD|dha|multivitamin (open)
  start_date_iso date,
  end_date_iso  date,
  is_active     boolean     not null default true,
  created_at    timestamptz not null default now()
);
grant select, insert, update, delete on public.medications to authenticated;
alter table public.medications enable row level security;
create policy "medications own select" on public.medications for select using (auth.uid() = user_id);
create policy "medications own insert" on public.medications for insert with check (auth.uid() = user_id);
create policy "medications own update" on public.medications for update using (auth.uid() = user_id);
create policy "medications own delete" on public.medications for delete using (auth.uid() = user_id);


-- ---- medication_logs  (medication_id is a soft reference to medications.id;
--      no hard FK, to avoid sync-order issues in local-first sync) ----
create table public.medication_logs (
  id            text        primary key,
  user_id       uuid        not null references auth.users (id) on delete cascade,
  medication_id text,
  date_key      date,
  taken_at_iso  timestamptz,
  created_at    timestamptz not null default now()
);
grant select, insert, update, delete on public.medication_logs to authenticated;
alter table public.medication_logs enable row level security;
create policy "medication_logs own select" on public.medication_logs for select using (auth.uid() = user_id);
create policy "medication_logs own insert" on public.medication_logs for insert with check (auth.uid() = user_id);
create policy "medication_logs own update" on public.medication_logs for update using (auth.uid() = user_id);
create policy "medication_logs own delete" on public.medication_logs for delete using (auth.uid() = user_id);


-- ---- symptom_logs  (SymptomStore / models/symptom.dart) ----
create table public.symptom_logs (
  id              text        primary key,
  user_id         uuid        not null references auth.users (id) on delete cascade,
  symptom_id      text        not null,
  date_key        date,
  severity        text        not null default 'mild'
                                check (severity in ('mild','moderate','severe')),
  notes           text        not null default '',
  created_at_iso  timestamptz,
  created_at      timestamptz not null default now()
);
grant select, insert, update, delete on public.symptom_logs to authenticated;
alter table public.symptom_logs enable row level security;
create policy "symptom_logs own select" on public.symptom_logs for select using (auth.uid() = user_id);
create policy "symptom_logs own insert" on public.symptom_logs for insert with check (auth.uid() = user_id);
create policy "symptom_logs own update" on public.symptom_logs for update using (auth.uid() = user_id);
create policy "symptom_logs own delete" on public.symptom_logs for delete using (auth.uid() = user_id);
