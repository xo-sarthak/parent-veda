-- =====================================================================
-- 0027_pp_name_votes.sql -- baby-name voting between two paired parents
-- ---------------------------------------------------------------------
-- Tinder, for baby names. Each parent swipes independently; a name is a
-- MATCH only when both have liked it. See
-- docs/BACKEND-COUPLE-NAMING-BRIEF.md.
--
-- COUPLE-SCOPED, NOT CHILD-SCOPED -- a deliberate change from section 4
-- of that brief, which proposed child_id uuid references children(id).
-- Two reasons:
--   1. children.id is TEXT (0021), so a uuid foreign key would fail
--      outright.
--   2. More importantly, the name generator has nothing to do with the
--      child record. It is a standalone tool - "we are looking for a
--      name we both like" - and it runs on the PREGNANCY side too, where
--      no child row exists at all. Scoping votes to a child would mean
--      the feature silently did nothing for exactly the couples most
--      likely to use it: the ones who have not added a baby yet. The
--      pairing is the stable thing here, so the pairing is the scope.
--
-- The chosen name does NOT flow into children.name. What a child is
-- called is entered by the parents at the pregnancy -> parenting
-- transition (or falls back to "<parent>'s baby"); this tool only ever
-- says "here are names you both liked".
--
-- A MATCH IS DERIVED, NEVER STORED. If one parent un-likes a name, the
-- match simply stops being returned - there is no second copy to drift.
--
-- PREREQ: public.my_partner_id() (0009_pairing.sql).
-- =====================================================================


-- ---------------------------------------------------------------------
-- One row per (parent, name). liked = false records an explicit skip,
-- so a name she has already judged is not shown to her again.
--
-- PK (user_id, name): a re-swipe is an upsert, never a duplicate. Same
-- composite-key shape as pp_vaccine_doses and pp_milestone_observations.
-- ---------------------------------------------------------------------
create table public.pp_name_votes (
  user_id    uuid        not null references auth.users (id) on delete cascade,
  name       text        not null,
  liked      boolean     not null default true,
  created_at timestamptz not null default now(),
  primary key (user_id, name)
);

-- The match query groups liked rows by name across two users.
create index pp_name_votes_liked_idx on public.pp_name_votes (name) where liked;

grant select, insert, update, delete on public.pp_name_votes to authenticated;
alter table public.pp_name_votes enable row level security;


-- ---------------------------------------------------------------------
-- RLS -- OWN ROWS ONLY, in every direction, including SELECT.
--
-- This is stricter than the brief's section 4, which widens SELECT to
-- the partner so the client can compute the intersection itself. That
-- works, but it hands the client the very thing section 5 says a parent
-- must never see: their partner's individual votes. A rule the client is
-- merely asked to respect is not a rule - anyone reading the table
-- directly, or a future screen added in good faith, can break it.
--
-- So the partner's rows stay unreadable, and matches come from
-- public.pp_name_matches() below, which computes the intersection with
-- definer rights and returns ONLY the names both parents liked. The
-- independence the feature depends on is then enforced by Postgres, not
-- by our discipline: there is no query a client can write that answers
-- "what did my partner like?" for an unmatched name.
-- ---------------------------------------------------------------------
create policy "pp_name_votes own select" on public.pp_name_votes for select
  using (auth.uid() = user_id);
create policy "pp_name_votes own insert" on public.pp_name_votes for insert
  with check (auth.uid() = user_id);
create policy "pp_name_votes own update" on public.pp_name_votes for update
  using (auth.uid() = user_id);
create policy "pp_name_votes own delete" on public.pp_name_votes for delete
  using (auth.uid() = user_id);


-- ---------------------------------------------------------------------
-- public.pp_name_matches() -- the ONLY way the intersection is exposed.
--
-- Returns the names the caller AND their partner have both liked.
-- security definer so it can read both parents' rows despite the
-- own-only policies above; it never returns whose vote is whose, and
-- never returns a name only one of them liked.
--
-- Unpaired: my_partner_id() is null, so only the caller's own rows are
-- in scope, the distinct-user count can never reach 2, and the result is
-- empty. Solo use keeps working - she builds a shortlist and simply has
-- no matches (brief section 3).
-- ---------------------------------------------------------------------
create or replace function public.pp_name_matches()
returns setof text
language sql
stable
security definer set search_path = ''
as $$
  select v.name
  from public.pp_name_votes v
  where v.liked
    and v.user_id in (auth.uid(), public.my_partner_id())
  group by v.name
  having count(distinct v.user_id) = 2;
$$;

grant execute on function public.pp_name_matches() to authenticated;
