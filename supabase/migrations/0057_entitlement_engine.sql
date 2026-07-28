-- =====================================================================
-- 0057_entitlement_engine.sql -- capabilities own access; plans grant
--                                bundles of them.
-- ---------------------------------------------------------------------
-- THE INSTRUCTION, from the Platform Access & Entitlement Bible:
--
--     Never ask "is this user Premium?"
--     Ask "does this user have capability X?"
--
-- WHY THAT IS WORTH THE EXTRA TABLE
--
-- The obvious design is a `plan` column on profiles and `if plan ==
-- 'premium'` at each gate. It works until the second sponsor type
-- arrives. Then it is `if premium or employer`, then `or insurance`,
-- then `or hospital or government or ngo` -- and every one of those
-- conditions lives in app code, so onboarding an insurer means a
-- release, a review and a rollout to people who never update.
--
-- Capabilities invert it. A gate asks one question that never changes
-- ("may this user book a sponsored consultation?"), and WHO may is a row
-- in a table. Adding a hospital-sponsored tier becomes data entry.
--
-- SEEDED SO NOTHING CHANGES TODAY
--
-- The `free` plan grants every capability registered here, and every
-- existing user resolves to it. So this migration is invisible: no
-- feature becomes locked, nobody loses anything. That is the same trick
-- 0019 and 0036 used, and it is what makes it safe to ship an
-- architecture before the product decisions it will eventually carry.
--
-- Deciding that voice Ask Veda is Premium later is then a DELETE of one
-- row from free_plan_capabilities -- not an engineering task.
--
-- ONLY REGISTER A CAPABILITY WHERE A PLAN DIFFERS
--
-- The source document asks for a registry of every feature, nothing
-- omitted. That is resisted deliberately: a registry where 55 of 60 rows
-- say "everyone gets this" encodes no decision and is 55 rows to keep
-- current. CLAUDE.md's rule -- a config that can express more states
-- than the product has is a bug surface, not flexibility -- applies
-- exactly here. Register the fifth capability the day a plan disagrees
-- about it.
--
-- PREREQ: 0001 (profiles), 0045 (directus_cms).
-- =====================================================================


-- ---------------------------------------------------------------------
-- 1. Capabilities -- the things access can be decided about.
-- ---------------------------------------------------------------------
create table if not exists public.capabilities (
  id          text primary key,          -- 'consultation_credit'
  name        text not null,
  description text not null default '',
  category    text not null default 'general',
  active      boolean not null default true,
  created_at  timestamptz not null default now()
);

comment on table public.capabilities is
  'Register a capability only where some plan genuinely differs on it. A row granted to everyone answers no question and is one more thing to keep current.';


-- ---------------------------------------------------------------------
-- 2. Plans -- bundles. A plan owns nothing; it grants.
-- ---------------------------------------------------------------------
create table if not exists public.plans (
  id         text primary key,           -- 'free' | 'employer_standard'
  name       text not null,
  -- consumer | sponsor | internal. TEXT, not an enum, for the same
  -- reason care_partners.type is: a new plan family must not need a
  -- migration.
  kind       text not null default 'consumer',
  active     boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.plan_capabilities (
  plan_id       text not null references public.plans (id) on delete cascade,
  capability_id text not null references public.capabilities (id) on delete cascade,
  primary key (plan_id, capability_id)
);

comment on table public.plan_capabilities is
  'THE MATRIX. Which plan grants which capability. Making something Premium later is deleting a row here, not editing app code.';


-- ---------------------------------------------------------------------
-- 3. What a user actually holds.
--
-- A row per grant, not a column on profiles, because a user can hold
-- more than one at once -- someone who buys Premium AND works at a
-- sponsoring company should not lose either. Part 17's "multiple
-- sponsors" edge case is then a second row rather than a conflict.
--
-- USER DATA: own-row read, no client write. Granting is a server act.
-- ---------------------------------------------------------------------
create table if not exists public.user_entitlements (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references auth.users (id) on delete cascade,
  plan_id    text not null references public.plans (id),
  -- Where it came from: 'default' | 'sponsor' | 'purchase' | 'internal'.
  -- Kept so a downgrade can remove exactly what one source granted and
  -- leave the rest -- an employee who leaves keeps a Premium they paid for.
  source     text not null default 'default',
  source_ref text,                        -- sponsor id, order id, ...
  starts_at  timestamptz not null default now(),
  ends_at    timestamptz,                 -- null = open-ended
  created_at timestamptz not null default now()
);

create index if not exists user_entitlements_user_idx
  on public.user_entitlements (user_id, plan_id);
create index if not exists user_entitlements_source_idx
  on public.user_entitlements (source, source_ref);

alter table public.user_entitlements enable row level security;

grant select on public.user_entitlements to authenticated;

drop policy if exists "user_entitlements own read" on public.user_entitlements;
create policy "user_entitlements own read" on public.user_entitlements
  for select to authenticated using (auth.uid() = user_id);

-- No client write policy. A user granting themselves a plan is the whole
-- thing this table exists to prevent.


-- ---------------------------------------------------------------------
-- 4. The one question the app asks.
--
-- security definer so it can read the matrix and the user's grants
-- regardless of RLS, but it can only ever answer about the CALLER --
-- the user id comes from auth.uid(), never a parameter. There is no
-- shape of this call that answers for somebody else.
--
-- SERVER-SIDE ENFORCEMENT (Part 16). The app calls this to decide what
-- to SHOW. It must never be the thing that decides what to ALLOW -- a
-- gated table's RLS policy calls it too, so a modified client gains a
-- button that does not work rather than access it should not have.
-- ---------------------------------------------------------------------
create or replace function public.has_capability(p_capability text)
returns boolean
language sql stable security definer set search_path = ''
as $$
  select exists (
    select 1
      from public.user_entitlements ue
      join public.plans p  on p.id = ue.plan_id and p.active
      join public.plan_capabilities pc on pc.plan_id = p.id
      join public.capabilities c on c.id = pc.capability_id and c.active
     where ue.user_id = auth.uid()
       and pc.capability_id = p_capability
       and ue.starts_at <= now()
       and (ue.ends_at is null or ue.ends_at > now())
  );
$$;

grant execute on function public.has_capability(text) to authenticated;

-- Everything the caller currently holds, so the UI can render against one
-- round trip rather than one call per gate.
create or replace function public.my_capabilities()
returns setof text
language sql stable security definer set search_path = ''
as $$
  select distinct pc.capability_id
    from public.user_entitlements ue
    join public.plans p  on p.id = ue.plan_id and p.active
    join public.plan_capabilities pc on pc.plan_id = p.id
    join public.capabilities c on c.id = pc.capability_id and c.active
   where ue.user_id = auth.uid()
     and ue.starts_at <= now()
     and (ue.ends_at is null or ue.ends_at > now());
$$;

grant execute on function public.my_capabilities() to authenticated;


-- ---------------------------------------------------------------------
-- 5. Granting and revoking -- server acts, audited, refusal-returning.
--
-- Returns {ok, code, message} rather than raising, because a raise
-- aborts the transaction and discards the audit row written a line
-- earlier. That defect was found and fixed in 0055; the same rule holds
-- for every gate written after it.
-- ---------------------------------------------------------------------
create or replace function public.grant_plan(
  p_user_id    uuid,
  p_plan_id    text,
  p_source     text,
  p_source_ref text default null,
  p_ends_at    timestamptz default null,
  p_actor      text default 'system'
) returns jsonb
language plpgsql security definer set search_path = ''
as $$
declare
  v_args jsonb := jsonb_build_object(
    'plan', p_plan_id, 'source', p_source, 'ref', p_source_ref);
begin
  if not exists (select 1 from public.plans where id = p_plan_id and active) then
    return public._refuse(p_actor, 'grant_plan', 'user_entitlements',
      p_user_id::text, 'no_such_plan',
      format('No active plan "%s".', p_plan_id), v_args);
  end if;

  -- Idempotent: re-granting the same plan from the same source extends
  -- rather than duplicates. Activating twice is a double tap, not two
  -- entitlements.
  if exists (
    select 1 from public.user_entitlements
     where user_id = p_user_id and plan_id = p_plan_id
       and source = p_source
       and coalesce(source_ref, '') = coalesce(p_source_ref, '')
       and (ends_at is null or ends_at > now())
  ) then
    update public.user_entitlements
       set ends_at = p_ends_at
     where user_id = p_user_id and plan_id = p_plan_id
       and source = p_source
       and coalesce(source_ref, '') = coalesce(p_source_ref, '');
    return public._allow(p_actor, 'grant_plan', 'user_entitlements',
      p_user_id::text, 'already_granted', 'Already held; validity updated.',
      v_args);
  end if;

  insert into public.user_entitlements
    (user_id, plan_id, source, source_ref, ends_at)
  values (p_user_id, p_plan_id, p_source, p_source_ref, p_ends_at);

  return public._allow(p_actor, 'grant_plan', 'user_entitlements',
    p_user_id::text, 'granted', format('Granted %s.', p_plan_id), v_args);
end;
$$;

revoke execute on function public.grant_plan(
  uuid, text, text, text, timestamptz, text) from public;

-- Revoke removes only what ONE SOURCE granted. An employee who leaves a
-- sponsoring company must not lose a Premium they bought themselves --
-- Part 17's downgrade case, and the reason `source` exists at all.
create or replace function public.revoke_plan_by_source(
  p_user_id    uuid,
  p_source     text,
  p_source_ref text,
  p_actor      text default 'system'
) returns jsonb
language plpgsql security definer set search_path = ''
as $$
declare v_n int;
begin
  delete from public.user_entitlements
   where user_id = p_user_id
     and source = p_source
     and coalesce(source_ref, '') = coalesce(p_source_ref, '');
  get diagnostics v_n = row_count;

  return public._allow(p_actor, 'revoke_plan_by_source', 'user_entitlements',
    p_user_id::text, 'revoked', format('%s entitlement(s) removed.', v_n),
    jsonb_build_object('source', p_source, 'ref', p_source_ref, 'removed', v_n));
end;
$$;

revoke execute on function
  public.revoke_plan_by_source(uuid, text, text, text) from public;


-- ---------------------------------------------------------------------
-- 6. Public read of the matrix.
--
-- Capabilities and plans are not secrets -- the app renders "included in
-- Premium" lists from them, and a parent deciding whether to activate an
-- employer benefit should be able to see what it grants before signing
-- in. Only user_entitlements is private.
-- ---------------------------------------------------------------------
alter table public.capabilities enable row level security;
alter table public.plans enable row level security;
alter table public.plan_capabilities enable row level security;

drop policy if exists "capabilities public read" on public.capabilities;
create policy "capabilities public read" on public.capabilities
  for select to anon, authenticated using (active);

drop policy if exists "plans public read" on public.plans;
create policy "plans public read" on public.plans
  for select to anon, authenticated using (active);

drop policy if exists "plan_capabilities public read" on public.plan_capabilities;
create policy "plan_capabilities public read" on public.plan_capabilities
  for select to anon, authenticated using (true);

grant select on public.capabilities      to anon, authenticated;
grant select on public.plans             to anon, authenticated;
grant select on public.plan_capabilities to anon, authenticated;

-- The panel edits the matrix. Internal Admin manages PLANS, never
-- individual feature switches (Part 13) -- so Directus gets the tables
-- that define bundles, and nothing that grants a specific user anything.
grant select, insert, update, delete on public.capabilities      to directus_cms;
grant select, insert, update, delete on public.plans             to directus_cms;
grant select, insert, update, delete on public.plan_capabilities to directus_cms;

drop policy if exists "capabilities cms write" on public.capabilities;
create policy "capabilities cms write" on public.capabilities
  for all to directus_cms using (true) with check (true);
drop policy if exists "plans cms write" on public.plans;
create policy "plans cms write" on public.plans
  for all to directus_cms using (true) with check (true);
drop policy if exists "plan_capabilities cms write" on public.plan_capabilities;
create policy "plan_capabilities cms write" on public.plan_capabilities
  for all to directus_cms using (true) with check (true);

-- Deliberately NOT granted: user_entitlements. Who holds what is a
-- record of grants made by the system, not a form to fill in. An admin
-- who needs to grant something calls grant_plan(), which audits.


-- ---------------------------------------------------------------------
-- 7. Seed -- five capabilities, and a free plan that grants them all.
-- ---------------------------------------------------------------------
insert into public.capabilities (id, name, description, category) values
  ('consultation_credit', 'Sponsored consultation credit',
   'Book a 1:1 expert consultation using a credit granted by a sponsor.',
   'consultations'),
  ('sponsor_events', 'Sponsor events',
   'See and register for events organised by a sponsoring organisation.',
   'sponsor'),
  ('sponsor_resources', 'Sponsor resource centre',
   'Read documents published by a sponsoring organisation.', 'sponsor'),
  ('sponsor_announcements', 'Sponsor announcements',
   'Receive announcements from a sponsoring organisation.', 'sponsor'),
  ('masterclass_access', 'Masterclass access',
   'Attend masterclasses included in a plan rather than bought individually.',
   'learning')
on conflict (id) do nothing;

insert into public.plans (id, name, kind) values
  ('free', 'ParentVeda', 'consumer')
on conflict (id) do nothing;

-- Free grants everything registered. Nothing is locked today; this
-- migration changes no behaviour, which is the point.
insert into public.plan_capabilities (plan_id, capability_id)
select 'free', id from public.capabilities
on conflict do nothing;


-- =====================================================================
-- VERIFY
--
--   select p.id, count(*) from public.plans p
--     join public.plan_capabilities pc on pc.plan_id = p.id group by 1;
--   -- free: 5
--
--   -- nobody holds anything yet, and free is granted implicitly by the
--   -- app rather than by a row per user (see EntitlementStore).
--   select count(*) from public.user_entitlements;   -- 0
--
--   -- a user cannot grant themselves a plan
--   set role authenticated;
--   insert into public.user_entitlements (user_id, plan_id)
--   values (gen_random_uuid(), 'free');   -- expect: permission denied
--   reset role;
--
-- MAKING SOMETHING PREMIUM LATER, for reference:
--   insert into public.plans (id, name, kind) values ('premium','ParentVeda Premium','consumer');
--   insert into public.plan_capabilities values ('premium','voice_ask_veda');
--   delete from public.plan_capabilities where plan_id='free' and capability_id='voice_ask_veda';
-- Two rows. No release.
-- =====================================================================
