-- =====================================================================
-- 0021_children.sql — the `children` table (the parenting keystone)
-- ---------------------------------------------------------------------
-- What `profiles` is to the pregnancy side, this is to the parenting
-- side. Almost every parenting row — health, vaccinations, feeds, sleep,
-- growth, documents, journal — is ABOUT A CHILD, so this table lands
-- first and everything after it references `child_id`.
--
-- ONE ROW PER BABY — NOT ONE PER PARENT.
-- Both paired parents share the SAME child row (whoever created it owns
-- it; the partner reaches it through public.my_partner_id). This is
-- deliberate: if each parent had their own row for the same baby, their
-- child_ids would differ and every feed log, vaccine and measurement
-- would fragment into two disconnected sets that never join up.
--
-- CO-PARENTING — a deliberate deviation from the pregnancy side:
-- On the pregnancy side a row is YOURS and your partner may only READ it
-- (0012_share_scans.sql). That fits: the parents have different apps and
-- the data is personal ("my symptoms", "my journal").
-- The parenting app shows BOTH parents the SAME screens for the SAME
-- baby, so here EITHER parent may read AND write the child's data.
-- Consequence: `user_id` is no longer the access key — it is
-- ATTRIBUTION ("Dad logged this"). Access flows through the CHILD, via
-- public.my_child_ids() at the bottom of this file.
--
-- PREREQ: public.my_partner_id (0009). Run AFTER 0009.
-- =====================================================================


-- ---------------------------------------------------------------------
-- PART 1: the table
-- `id text` (not uuid) to match the house rule: the app generates the id
-- so the local cache row and the cloud row share one id → trivial sync.
-- ---------------------------------------------------------------------
create table public.children (
  id          text        primary key,
  user_id     uuid        not null references auth.users (id) on delete cascade,

  name        text        not null default '',
  is_boy      boolean     not null default true,
  dob         date,

  -- ⚠️ FLAGGED — MIRROR, NOT TRUTH (see BACKEND-PLAN "parenting flags").
  -- The app currently reads the child's growth from THREE places that can
  -- disagree: My Child reads these scalars, Growth journey reads its own
  -- series, and Health + Doctor Record read a hardcoded const list in
  -- pp_health_data.dart that can never change. These columns exist so the
  -- CURRENT code persists unchanged. Once growth is rewired, the single
  -- source becomes the latest growth_measurements row and these should be
  -- derived from it, then dropped.
  weight_kg   numeric,
  height_cm   numeric,
  head_cm     numeric,

  created_at  timestamptz not null default now()
);

-- Every child-scoped policy resolves children by owner, and the client
-- lists a parent's children on every launch.
create index children_user_id_idx on public.children (user_id);


-- ---------------------------------------------------------------------
-- PART 2: privileges
-- RLS decides WHICH ROWS; the GRANT decides whether the role may touch
-- the table at all, and it is checked first. SQL-created tables do not
-- auto-grant (the Table Editor UI does). Without this: "permission denied
-- for table children" (code 42501).
-- ---------------------------------------------------------------------
grant select, insert, update, delete on public.children to authenticated;


-- ---------------------------------------------------------------------
-- PART 3: Row-Level Security
-- ---------------------------------------------------------------------
alter table public.children enable row level security;

-- Read: your own child, or the child of the partner you're paired with.
create policy "children own or partner select"
  on public.children for select
  using (auth.uid() = user_id or user_id = public.my_partner_id());

-- Insert: only ever as YOURSELF — you cannot create a child owned by your
-- partner. Note this is not how the second parent gets a child: they
-- ADOPT the existing row by reading it (the client checks for a partner's
-- child before creating its own — see ChildProfileStore._syncFromCloud).
create policy "children own insert"
  on public.children for insert
  with check (auth.uid() = user_id);

-- Update + delete: CO-PARENTING — either parent may edit the child.
-- (This is the deviation. On the pregnancy side these would be own-only.)
create policy "children own or partner update"
  on public.children for update
  using (auth.uid() = user_id or user_id = public.my_partner_id());

create policy "children own or partner delete"
  on public.children for delete
  using (auth.uid() = user_id or user_id = public.my_partner_id());


-- ---------------------------------------------------------------------
-- PART 4: public.my_child_ids() — THE access key for parenting data
-- Every child the caller may touch: their own children plus their
-- partner's. Later migrations gate their tables on it:
--
--     using (child_id in (select public.my_child_ids()))
--
-- `security definer` so it reads `children` WITHOUT tripping that table's
-- own RLS — the same trick public.my_partner_id uses in 0009. Without it,
-- a policy on `children` that called this function would recurse.
-- `stable` lets Postgres call it once per statement, not once per row.
-- ---------------------------------------------------------------------
create or replace function public.my_child_ids()
returns setof text
language sql
stable
security definer set search_path = ''
as $$
  select id from public.children
  where user_id = auth.uid()
     or user_id = public.my_partner_id();
$$;

grant execute on function public.my_child_ids() to authenticated;


-- ---------------------------------------------------------------------
-- ⚠️ FLAGGED for the next discussion — profiles.baby_dob
-- 0015_whatsapp.sql already added `profiles.baby_dob` ("null until birth;
-- drives post-birth triggers"), a SINGLE date on the parent. That
-- structurally contradicts a multi-child table. Decision: `children` is
-- the source of truth and baby_dob stays as a mirror of the FIRST child
-- so the existing WhatsApp pg_cron keeps working untouched.
-- NOT WIRED YET — no Dart code writes baby_dob today, so nothing changes
-- for now. The mirror (a trigger here, or a write in the client) still
-- needs to be built before any post-birth WhatsApp trigger can fire.
-- ---------------------------------------------------------------------
