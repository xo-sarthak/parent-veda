-- =============================================================================
--  0042 — TTC health records and appointments
-- -----------------------------------------------------------------------------
--  The two tables the last Tools tiles needed. Split from 0041 rather than
--  edited into it, because 0041 may already be applied — a migration that has
--  run is history, not a draft.
--
--  Both are COUPLE-SCOPED. That is the point of them: a semen analysis is his
--  result and it belongs in the same folder as her AMH, and an appointment one
--  of them books is an appointment they both need to know about. A records
--  screen that only holds her results would rebuild exactly the asymmetry this
--  whole stage exists to correct.
--
--  Runs after 0009 (public.my_partner_id) and 0041.
-- =============================================================================

-- ---------------------------------------------------------------------------
--  ttc_records — test results and documents
-- ---------------------------------------------------------------------------

create table if not exists public.ttc_records (
  id           text primary key,            -- app-generated → idempotent merge
  user_id      uuid not null references auth.users (id) on delete cascade,

  -- Points at the test library where the result came from one of its entries
  -- ('amh', 'semen', ...). Null for anything the couple typed themselves, which
  -- must always be possible: no library covers every test an Indian lab runs.
  test_id      text,
  label        text not null,

  -- Kept as text on purpose. Real reports say "12.4", "Normal", "<0.5" and
  -- "Grade II" — coercing that to a number would lose most of them, and the
  -- product never interprets a result anyway.
  value        text not null default '',
  unit         text not null default '',

  taken_on     date not null,
  note         text,
  for_partner  boolean not null default false,
  created_at   timestamptz not null default now()
);

create index if not exists ttc_records_user_idx
  on public.ttc_records (user_id, taken_on desc);

alter table public.ttc_records enable row level security;

drop policy if exists ttc_records_couple on public.ttc_records;
create policy ttc_records_couple on public.ttc_records
  for all
  using (auth.uid() = user_id or user_id = public.my_partner_id())
  with check (auth.uid() = user_id or user_id = public.my_partner_id());


-- ---------------------------------------------------------------------------
--  ttc_appointments — the couple's own appointments
-- ---------------------------------------------------------------------------
--  Separate from the booking engine's `bookings`, and deliberately so: those
--  are things bought through ParentVeda, these are the clinic visits a couple
--  arranges themselves. Both appear together on the Calendar; only these are
--  editable by the couple.

create table if not exists public.ttc_appointments (
  id           text primary key,
  user_id      uuid not null references auth.users (id) on delete cascade,
  title        text not null,
  with_whom    text not null default '',
  starts_utc   timestamptz not null,        -- stored UTC, shown local
  note         text,
  created_at   timestamptz not null default now()
);

create index if not exists ttc_appointments_user_idx
  on public.ttc_appointments (user_id, starts_utc);

alter table public.ttc_appointments enable row level security;

drop policy if exists ttc_appointments_couple on public.ttc_appointments;
create policy ttc_appointments_couple on public.ttc_appointments
  for all
  using (auth.uid() = user_id or user_id = public.my_partner_id())
  with check (auth.uid() = user_id or user_id = public.my_partner_id());


grant select, insert, update, delete on
  public.ttc_records,
  public.ttc_appointments
to authenticated;
