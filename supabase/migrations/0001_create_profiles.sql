-- =====================================================================
-- 0001_create_profiles.sql
-- ParentVeda — Phase 1: the profiles table (the keystone).
--
-- Run this in the Supabase dashboard:  SQL Editor -> New query -> paste -> Run.
-- Safe to re-run on a fresh project (e.g. a future prod project).
-- =====================================================================


-- ---------------------------------------------------------------------
-- PART 1: the table
-- One row per user. `id` is the SAME id as Supabase's built-in
-- auth.users row, so a profile is glued 1:1 to an account.
-- ---------------------------------------------------------------------
create table public.profiles (
  -- Links 1:1 to the account. If the account is deleted, the profile
  -- is deleted too (on delete cascade).
  id          uuid        primary key references auth.users (id) on delete cascade,

  -- App-level profile fields (filled in during onboarding).
  name        text,
  role        text        check (role in ('mother', 'father')),
  due_date    date,

  -- Bookkeeping.
  created_at  timestamptz not null default now()
);

-- NOTE: we will ADD columns later as features grow — e.g. `partner_id`
-- when we build partner pairing. Adding a column to an existing table is
-- the safe, normal way features evolve (no new table needed).


-- ---------------------------------------------------------------------
-- PART 1b: table privileges (GRANTs)
-- RLS (below) decides WHICH ROWS a role may touch -- but the role also
-- needs table-level permission to touch the table AT ALL, and that layer
-- is checked first. Tables created via raw SQL do NOT auto-grant these
-- (the Table Editor UI does), so grant them explicitly to logged-in users.
-- Without this you get: "permission denied for table profiles" (code 42501).
-- ---------------------------------------------------------------------
grant select, insert, update on public.profiles to authenticated;


-- ---------------------------------------------------------------------
-- PART 2: Row-Level Security (RLS)
-- Turn on RLS so rows are private by default, then add policies that
-- say "you may only touch the row whose id == your own user id".
-- auth.uid() = the id of the currently-logged-in user.
-- ---------------------------------------------------------------------
alter table public.profiles enable row level security;

create policy "Users can view their own profile"
  on public.profiles for select
  using (auth.uid() = id);

create policy "Users can update their own profile"
  on public.profiles for update
  using (auth.uid() = id);

create policy "Users can insert their own profile"
  on public.profiles for insert
  with check (auth.uid() = id);


-- ---------------------------------------------------------------------
-- PART 3: auto-create a profile on signup
-- Whenever a new auth.users row is created, this trigger inserts a
-- matching (empty) profiles row, so a user can never exist without a
-- profile. `security definer` lets it run with elevated rights so it
-- can insert even before the user is "logged in".
-- ---------------------------------------------------------------------
create function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = ''
as $$
begin
  insert into public.profiles (id)
  values (new.id);
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
