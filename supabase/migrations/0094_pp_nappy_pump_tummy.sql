-- =====================================================================
-- 0094_pp_nappy_pump_tummy.sql — nappy, pump and tummy-time logs
-- (written in the fork as 0093 on 2026-10-02; renumbered 2026-10-07 because
-- main's 0093 is children.sex_given, and tummy time added on the same shape)
-- ---------------------------------------------------------------------
-- NappyStore and PumpStore (lib/screens/post_pregnancy/pp_care_log_data.dart),
-- added 2026-10-02 from the parenting gap analysis: both competitor apps
-- log nappies and pumping, and we logged neither.
--
-- Same shape as 0024 (feed + sleep), on purpose: CHILD-SCOPED and
-- CO-PARENTED. The wet-nappy count is the one a paediatrician asks for in
-- the first weeks, and whoever changed the nappy at 3am is often not the
-- person who will be asked.
--
-- Why pumping is child-scoped, not the mother's own: the record answers
-- "how much expressed milk is there for him", and the person who needs
-- that answer is the one giving the bottle. `user_id` still says who
-- logged it.
--
-- Columns mirror NappyStore.toRow / PumpStore.toRow exactly; the contract
-- is pinned by test/pp_care_log_test.dart, because these writes are
-- fire-and-forget and a mismatch would fail silently.
--
-- PREREQ: 0021_children.sql. Run AFTER 0024 (and after 0093).
-- =====================================================================

create table public.pp_nappy_logs (
  id         text        primary key,
  child_id   text        not null,
  user_id    uuid        not null references auth.users (id) on delete cascade,

  time       timestamptz not null,
  kind       text        not null default 'wet'
                           check (kind in ('wet','dirty','mixed','dry')),
  colour     text        check (colour in ('yellow','mustard','green','brown','black','red','pale')),
  texture    text        check (texture in ('runny','seedy','soft','formed','hard','mucus')),
  note       text,

  created_at timestamptz not null default now()
);

create index pp_nappy_logs_child_time_idx
  on public.pp_nappy_logs (child_id, time desc);


create table public.pp_pump_logs (
  id           text        primary key,
  child_id     text        not null,
  user_id      uuid        not null references auth.users (id) on delete cascade,

  time         timestamptz not null,
  left_ml      int         check (left_ml is null or left_ml between 0 and 1000),
  right_ml     int         check (right_ml is null or right_ml between 0 and 1000),
  duration_min int,
  note         text,

  created_at   timestamptz not null default now()
);

create index pp_pump_logs_child_time_idx
  on public.pp_pump_logs (child_id, time desc);


grant select, insert, update, delete on public.pp_nappy_logs to authenticated;
grant select, insert, update, delete on public.pp_pump_logs  to authenticated;


alter table public.pp_nappy_logs enable row level security;
alter table public.pp_pump_logs  enable row level security;

create policy "pp_nappy_logs child select" on public.pp_nappy_logs for select
  using (child_id in (select public.my_child_ids()));
create policy "pp_nappy_logs child insert" on public.pp_nappy_logs for insert
  with check (child_id in (select public.my_child_ids()) and auth.uid() = user_id);
create policy "pp_nappy_logs child update" on public.pp_nappy_logs for update
  using (child_id in (select public.my_child_ids()));
create policy "pp_nappy_logs child delete" on public.pp_nappy_logs for delete
  using (child_id in (select public.my_child_ids()));

create policy "pp_pump_logs child select" on public.pp_pump_logs for select
  using (child_id in (select public.my_child_ids()));
create policy "pp_pump_logs child insert" on public.pp_pump_logs for insert
  with check (child_id in (select public.my_child_ids()) and auth.uid() = user_id);
create policy "pp_pump_logs child update" on public.pp_pump_logs for update
  using (child_id in (select public.my_child_ids()));
create policy "pp_pump_logs child delete" on public.pp_pump_logs for delete
  using (child_id in (select public.my_child_ids()));


-- ---- tummy time (2026-10-07) -------------------------------------------------
-- TummyStore (pp_care_log_data.dart). Same shape and the same co-parented
-- policies as the two tables above. `seconds` is the session length; there is
-- no goal column on purpose (no target, no streak).

create table public.pp_tummy_logs (
  id         text        primary key,
  child_id   text        not null,
  user_id    uuid        not null references auth.users (id) on delete cascade,

  time       timestamptz not null,
  seconds    int         not null check (seconds between 0 and 14400),

  created_at timestamptz not null default now()
);

create index pp_tummy_logs_child_time_idx
  on public.pp_tummy_logs (child_id, time desc);

grant select, insert, update, delete on public.pp_tummy_logs to authenticated;

alter table public.pp_tummy_logs enable row level security;

create policy "pp_tummy_logs child select" on public.pp_tummy_logs for select
  using (child_id in (select public.my_child_ids()));
create policy "pp_tummy_logs child insert" on public.pp_tummy_logs for insert
  with check (child_id in (select public.my_child_ids()) and auth.uid() = user_id);
create policy "pp_tummy_logs child update" on public.pp_tummy_logs for update
  using (child_id in (select public.my_child_ids()));
create policy "pp_tummy_logs child delete" on public.pp_tummy_logs for delete
  using (child_id in (select public.my_child_ids()));
