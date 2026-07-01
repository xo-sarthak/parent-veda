-- =====================================================================
-- 0009_pairing.sql — mother <-> father pairing
-- Adds partner_id + a persistent pairing_code to profiles, a secure
-- linking RPC, and broadens SELECT so paired partners can read each
-- other's profile + journal (the merged journal view). Writes stay
-- own-only. Run AFTER the earlier migrations. Safe to run once.
-- =====================================================================

-- 1) New columns on profiles ------------------------------------------
alter table public.profiles
  add column if not exists partner_id   uuid references auth.users (id),
  add column if not exists pairing_code text unique;


-- 2) Pairing-code generator: 8 chars, no ambiguous letters (no 0/O/1/I/L).
create or replace function public.gen_pairing_code()
returns text
language plpgsql
volatile
as $$
declare
  alphabet constant text := 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
  code text;
  i int;
begin
  loop
    code := '';
    for i in 1..8 loop
      code := code || substr(alphabet, (floor(random() * length(alphabet)) + 1)::int, 1);
    end loop;
    exit when not exists (select 1 from public.profiles where pairing_code = code);
  end loop;
  return code;
end;
$$;


-- 3) Backfill existing profiles that don't have a code yet.
update public.profiles
set pairing_code = public.gen_pairing_code()
where pairing_code is null;


-- 4) New signups get a code automatically (replaces the earlier trigger fn).
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = ''
as $$
begin
  insert into public.profiles (id, pairing_code)
  values (new.id, public.gen_pairing_code());
  return new;
end;
$$;


-- 5) Helper: the caller's partner id, WITHOUT triggering RLS (security
--    definer) so it can be referenced inside RLS policies below without
--    infinite recursion.
create or replace function public.my_partner_id()
returns uuid
language sql
stable
security definer set search_path = ''
as $$
  select partner_id from public.profiles where id = auth.uid();
$$;


-- 6) The link RPC: the FATHER (auth.uid()) calls this with the mother's
--    code. Links BOTH profiles' partner_id. security definer so it can
--    also update the mother's row. Returns the mother's id on success.
create or replace function public.link_as_partner(code text)
returns uuid
language plpgsql
security definer set search_path = ''
as $$
declare
  me uuid := auth.uid();
  mother_id uuid;
begin
  if me is null then
    raise exception 'Not signed in';
  end if;

  select id into mother_id
  from public.profiles
  where pairing_code = upper(trim(code))
  limit 1;

  if mother_id is null then
    raise exception 'Invalid pairing code';
  end if;
  if mother_id = me then
    raise exception 'You cannot pair with your own code';
  end if;

  update public.profiles set partner_id = mother_id where id = me;
  update public.profiles set partner_id = me        where id = mother_id;

  return mother_id;
end;
$$;

grant execute on function public.link_as_partner(text) to authenticated;


-- 7) Merged view: partners can READ each other's profile + journal entries.
--    (Writes stay own-only — the insert/update/delete policies are unchanged.)
drop policy if exists "Users can view their own profile" on public.profiles;
create policy "view own or partner profile"
  on public.profiles for select
  using (auth.uid() = id or id = public.my_partner_id());

drop policy if exists "journal_entries own select" on public.journal_entries;
create policy "journal_entries own or partner select"
  on public.journal_entries for select
  using (auth.uid() = user_id or user_id = public.my_partner_id());
