-- =====================================================================
-- 0095_pp_emergency_cards.sql — the child's emergency card, co-parented
-- (2026-10-07, parenting gap analysis P1: "The emergency card on the door")
-- ---------------------------------------------------------------------
-- HealthStore.emergency (lib/screens/post_pregnancy/pp_health_data.dart)
-- used to ride only in the phone's local blob, so the card a father opened
-- at 2am was empty if the mother had filled it on her phone. The card is
-- exactly the record the OTHER parent needs, so it is child-scoped and
-- co-parented, like the care logs (0094).
--
-- ONE ROW PER CHILD: `child_id` is the primary key, so saving is an
-- idempotent upsert on child_id. `card` is the small JSON the app already
-- writes locally (name, dob, weight, blood group, allergies, paediatrician,
-- medicines, contacts[]). It is read whole and written whole; nothing
-- queries inside it, so jsonb rather than columns. `user_id` is whoever
-- saved it last.
--
-- The app writes fire-and-forget; until this migration is run, the write
-- fails silently and the card stays local, exactly as before.
--
-- PREREQ: 0021_children.sql (my_child_ids()).
-- =====================================================================

create table public.pp_emergency_cards (
  child_id   text        primary key,
  user_id    uuid        not null references auth.users (id) on delete cascade,
  card       jsonb       not null,
  updated_at timestamptz not null default now()
);

grant select, insert, update, delete on public.pp_emergency_cards to authenticated;

alter table public.pp_emergency_cards enable row level security;

create policy "pp_emergency_cards child select" on public.pp_emergency_cards for select
  using (child_id in (select public.my_child_ids()));
create policy "pp_emergency_cards child insert" on public.pp_emergency_cards for insert
  with check (child_id in (select public.my_child_ids()) and auth.uid() = user_id);
create policy "pp_emergency_cards child update" on public.pp_emergency_cards for update
  using (child_id in (select public.my_child_ids()))
  with check (child_id in (select public.my_child_ids()) and auth.uid() = user_id);
create policy "pp_emergency_cards child delete" on public.pp_emergency_cards for delete
  using (child_id in (select public.my_child_ids()));
