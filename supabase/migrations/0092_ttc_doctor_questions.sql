-- =============================================================================
--  0092 — questions for the doctor get their own table (2026-09-28)
-- -----------------------------------------------------------------------------
--  Until now a question she saved for her doctor was a row in ttc_journal with
--  kind = 'question'. The journal has been taken out of Trying to Conceive
--  (the user, 2026-09-28: "question for your doctor stays on appointments...
--  it has to do nothing with journal now on"), and a feature that lives in
--  another feature's table is switched off with it. So the questions move to
--  a table of their own, read and written only by the Appointments page
--  (lib/ttc/ttc_doctor_questions_store.dart). See docs/BACKEND-PATTERNS.md,
--  section 16r.
--
--  SHAPE, following the other TTC tables (0041, 0042):
--   · id is app-generated, so a phone's row and its cloud copy are one
--     identity and every sync write is an idempotent upsert on id;
--   · updated_at is the merge clock: the newer copy wins;
--   · removed_at is a soft delete. A removal is written as data, so it cannot
--     be undone by an upsert that was already in flight (16q), and an Undo is
--     one more upsert that clears it.
--
--  OWNERSHIP (docs/FAMILY-MODEL.md): the person owns what she writes; her
--  partner may read, never write. Unlike 0042's couple-writable tables, the
--  write side here is own-row only, which is also why no author_id column is
--  needed: the owner IS the author.
--
--  Nothing is dropped. ttc_journal and its rows stay exactly as they are.
--
--  Runs after 0009 (public.my_partner_id) and 0041 (ttc_journal).
-- =============================================================================

create table if not exists public.ttc_doctor_questions (
  id          text primary key,            -- app-generated → idempotent merge
  user_id     uuid not null references auth.users (id) on delete cascade,
  body        text not null,
  written_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  removed_at  timestamptz,                 -- soft delete; null = on the list
  -- Added in place 2026-09-28, before this file was ever run: a question
  -- belongs to a visit and is ticked when asked.
  appointment_id text,                     -- the visit she chose; null = whichever comes next
  asked_at    timestamptz,                 -- when she ticked it asked; null = still to ask
  created_at  timestamptz not null default now()
);

--  ⚠️ appointment_id HAS NO FOREIGN KEY, ON PURPOSE. It holds either a
--  ttc_appointments id or 'booking:<id>' for a consult booked in ParentVeda,
--  two tables no single key can point at. And the obvious key would do harm:
--  `on delete set null` would rewrite her question the moment a visit is
--  deleted, so an Undo of that delete (the app offers one) could never put
--  the question back on it. Which visit an unticked question is on TODAY is
--  derived on the phone from the visits' dates (a deleted or passed visit's
--  questions go to the next one); the row keeps only what she chose.
--  See docs/BACKEND-PATTERNS.md, section 16r.

-- Belt and braces: if an earlier draft of this file was ever run somewhere,
-- `create table if not exists` above skipped the table and these add the two
-- columns. On a fresh run they do nothing.
alter table public.ttc_doctor_questions
  add column if not exists appointment_id text;
alter table public.ttc_doctor_questions
  add column if not exists asked_at timestamptz;

create index if not exists ttc_doctor_questions_user_idx
  on public.ttc_doctor_questions (user_id, written_at desc);

alter table public.ttc_doctor_questions enable row level security;

-- Read: her own rows and her partner's.
drop policy if exists ttc_doctor_questions_read on public.ttc_doctor_questions;
create policy ttc_doctor_questions_read on public.ttc_doctor_questions
  for select
  using (auth.uid() = user_id or user_id = public.my_partner_id());

-- Write: only her own. Insert, change and delete are each own-row.
drop policy if exists ttc_doctor_questions_insert on public.ttc_doctor_questions;
create policy ttc_doctor_questions_insert on public.ttc_doctor_questions
  for insert
  with check (auth.uid() = user_id);

drop policy if exists ttc_doctor_questions_update on public.ttc_doctor_questions;
create policy ttc_doctor_questions_update on public.ttc_doctor_questions
  for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists ttc_doctor_questions_delete on public.ttc_doctor_questions;
create policy ttc_doctor_questions_delete on public.ttc_doctor_questions
  for delete
  using (auth.uid() = user_id);

grant select, insert, update, delete on public.ttc_doctor_questions
  to authenticated;


-- ---------------------------------------------------------------------------
--  The cloud half of the one-time move
-- ---------------------------------------------------------------------------
--  Copies every question already in ttc_journal into the new table, keeping
--  its id, so it meets the phone's own copy (moved from the local cache on
--  first load) as the same row. `on conflict do nothing` makes it safe to run
--  twice. The owner is the author: a journal row's user_id could be either of
--  the couple, author_id is always who wrote it. appointment_id and asked_at
--  are left null: a moved question belongs to whichever visit comes next and
--  is still to ask, which is how the list showed it before.
insert into public.ttc_doctor_questions
  (id, user_id, body, written_at, updated_at)
select id, author_id, body, written_at, written_at
from public.ttc_journal
where kind = 'question'
on conflict (id) do nothing;
