-- =====================================================================
-- 0030_expert_side.sql -- the doctor/expert side of the booking engine
-- ---------------------------------------------------------------------
-- Two things the expert experience needs from the server:
--   1. a mapping from a logged-in user to WHICH expert they are, so the
--      server can answer "show me my calls" and "let me into this room";
--   2. a roster query that returns the bookings made against that expert
--      -- which are OTHER users' rows, so it must be a definer function,
--      scoped strictly to the caller's own expert slots.
--
-- PREREQ: 0029 (booking_slots, booking_bookings).
-- =====================================================================


-- ---------------------------------------------------------------------
-- expert_accounts -- user <-> expert id.
--
-- For now a user claims their own expert id (testing); in production this
-- is admin-assigned. Own-row only, in every direction.
-- ---------------------------------------------------------------------
create table public.expert_accounts (
  user_id    uuid        primary key references auth.users (id) on delete cascade,
  expert_id  text        not null,
  created_at timestamptz not null default now()
);

create index expert_accounts_expert_idx on public.expert_accounts (expert_id);

grant select, insert, update on public.expert_accounts to authenticated;
alter table public.expert_accounts enable row level security;

create policy "expert_accounts own" on public.expert_accounts
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);


-- ---------------------------------------------------------------------
-- expert_roster() -- the bookings made with the calling expert.
--
-- Joins bookings to slots and keeps only the slots whose expert_id matches
-- the caller's expert_accounts row. security definer so it can read the
-- mothers' booking rows, but it can NEVER return a booking for a slot the
-- caller does not host: the expert_id filter is derived from auth.uid(),
-- not passed in.
-- ---------------------------------------------------------------------
create or replace function public.expert_roster()
returns setof public.booking_bookings
language sql
stable
security definer set search_path = ''
as $$
  select b.*
  from public.booking_bookings b
  join public.booking_slots s on s.id = b.slot_id
  where b.status <> 'cancelled'
    and s.expert_id = (
      select ea.expert_id
      from public.expert_accounts ea
      where ea.user_id = auth.uid()
    )
  order by b.starts_utc;
$$;

grant execute on function public.expert_roster() to authenticated;
