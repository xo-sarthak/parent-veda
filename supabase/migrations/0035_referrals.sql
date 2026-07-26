-- =====================================================================
-- 0035_referrals.sql -- referral codes, invites, and the reward grant
-- ---------------------------------------------------------------------
-- A referral system is a machine that gives things away, so the rule that
-- matters most is this: THE CLIENT NEVER GRANTS A REWARD. The app can ask,
-- and the app re-runs the same checks locally to keep its UI honest, but
-- only redeem_referral() below can write a reward -- and it re-validates
-- everything from scratch, because a client that decides who gets paid is
-- a client that can be edited.
--
-- Three tables:
--   referral_codes    one per user, unique, stable
--   referral_invites  one per redemption, the lifecycle row
--   referral_rewards  what was actually granted, and to whom
--
-- PREREQ: 0001 (profiles).
-- =====================================================================

-- ---------------------------------------------------------------------
-- Codes. One per user. UNIQUE is the whole point: the app derives a code
-- deterministically from the user id, and this constraint is what catches
-- the rare collision.
-- ---------------------------------------------------------------------
create table public.referral_codes (
  user_id    uuid        primary key references auth.users (id) on delete cascade,
  code       text        not null unique,
  created_at timestamptz not null default now()
);

create index referral_codes_code_idx on public.referral_codes (code);

grant select, insert on public.referral_codes to authenticated;
alter table public.referral_codes enable row level security;

-- READ is open to any signed-in user: redeeming a code requires looking it
-- up, and a code is a public handle by design -- it gets pasted into
-- WhatsApp. It maps to a user id and nothing else; no name, no profile.
create policy "referral_codes read" on public.referral_codes
  for select using (true);

-- You may only claim a code FOR YOURSELF.
create policy "referral_codes own insert" on public.referral_codes
  for insert to authenticated with check (user_id = auth.uid());


-- ---------------------------------------------------------------------
-- Invites. One row per redemption: who invited whom, and how far it got.
--
-- invitee_id is UNIQUE -- a parent may be referred exactly once, ever.
-- That single constraint kills the most valuable attack (redeem repeatedly
-- from one account) at the database level, where no code path can forget it.
-- ---------------------------------------------------------------------
create table public.referral_invites (
  id            bigserial   primary key,
  inviter_id    uuid        not null references auth.users (id) on delete cascade,
  invitee_id    uuid        not null unique references auth.users (id) on delete cascade,
  code          text        not null,
  status        text        not null default 'registered',
  due_month     text,                       -- '2026-10', for Birth Club matching
  qualified_at  timestamptz,
  credited_at   timestamptz,
  blocked_reason text,
  created_at    timestamptz not null default now(),
  -- The other half of self-referral prevention. The app checks it too, for a
  -- decent error message; this is what makes it true.
  constraint referral_no_self check (inviter_id <> invitee_id)
);

create index referral_invites_inviter_idx on public.referral_invites (inviter_id, created_at);
create index referral_invites_status_idx  on public.referral_invites (status);

grant select on public.referral_invites to authenticated;
alter table public.referral_invites enable row level security;

-- A parent sees invites they SENT (their dashboard) and the one they were
-- invited by. Nothing else -- not other people's referral graphs.
create policy "referral_invites own read" on public.referral_invites
  for select using (inviter_id = auth.uid() or invitee_id = auth.uid());

-- No insert/update/delete policy exists ON PURPOSE. Writes happen only
-- inside redeem_referral() / qualify_referral(), which run as definer.
-- With RLS on, a table with no policy for a verb denies that verb outright.


-- ---------------------------------------------------------------------
-- Rewards. What was granted, to whom, for which invite.
-- ---------------------------------------------------------------------
create table public.referral_rewards (
  id         bigserial   primary key,
  user_id    uuid        not null references auth.users (id) on delete cascade,
  invite_id  bigint      not null references public.referral_invites (id) on delete cascade,
  role       text        not null check (role in ('inviter', 'invitee')),
  kind       text        not null,
  value      int         not null default 1,
  label      text        not null default '',
  granted_at timestamptz not null default now(),
  -- Belt and braces against a double-grant: one reward per (invite, role),
  -- so even a retried call cannot pay twice.
  unique (invite_id, role)
);

create index referral_rewards_user_idx on public.referral_rewards (user_id, granted_at);

grant select on public.referral_rewards to authenticated;
alter table public.referral_rewards enable row level security;

create policy "referral_rewards own read" on public.referral_rewards
  for select using (user_id = auth.uid());


-- ---------------------------------------------------------------------
-- redeem_referral(code, due_month) -- the invitee enters a code.
--
-- Creates the invite row. Does NOT grant anything: qualification comes
-- later, when onboarding is actually finished. Returns a status string the
-- app can show verbatim.
-- ---------------------------------------------------------------------
create or replace function public.redeem_referral(p_code text, p_due_month text default null)
returns text
language plpgsql
security definer set search_path = ''
as $$
declare
  v_inviter uuid;
  v_me      uuid := auth.uid();
begin
  if v_me is null then
    return 'not_signed_in';
  end if;

  select user_id into v_inviter
  from public.referral_codes
  where code = upper(trim(p_code));

  if v_inviter is null then
    return 'unknown_code';
  end if;

  if v_inviter = v_me then
    return 'self_referral';
  end if;

  -- The unique constraint on invitee_id would catch this anyway; checking
  -- first turns a raised exception into a message worth showing.
  if exists (select 1 from public.referral_invites where invitee_id = v_me) then
    return 'already_redeemed';
  end if;

  insert into public.referral_invites (inviter_id, invitee_id, code, due_month)
  values (v_inviter, v_me, upper(trim(p_code)), p_due_month);

  return 'ok';
exception
  when unique_violation then
    return 'already_redeemed';
end;
$$;

grant execute on function public.redeem_referral(text, text) to authenticated;


-- ---------------------------------------------------------------------
-- qualify_referral() -- the invitee has finished onboarding.
--
-- Grants BOTH rewards, once, inside one transaction. Called by the app at
-- the end of onboarding; safe to call repeatedly, because the unique
-- (invite_id, role) constraint makes a second grant a no-op rather than a
-- second payout.
--
-- p_max_rewards is passed by the app from campaign config, but is clamped
-- here: config is a business knob, not a security boundary.
-- ---------------------------------------------------------------------
create or replace function public.qualify_referral(
  p_kind text default 'consultCredit',
  p_value int default 1,
  p_label text default '',
  p_max_rewards int default 10
)
returns text
language plpgsql
security definer set search_path = ''
as $$
declare
  v_me       uuid := auth.uid();
  v_invite   public.referral_invites%rowtype;
  v_earned   int;
  v_cap      int := least(greatest(coalesce(p_max_rewards, 10), 0), 100);
begin
  if v_me is null then
    return 'not_signed_in';
  end if;

  select * into v_invite
  from public.referral_invites
  where invitee_id = v_me
  for update;

  if not found then
    return 'no_invite';
  end if;

  if v_invite.credited_at is not null then
    return 'already_credited';
  end if;

  -- Lifetime cap on the INVITER. Checked here, not on the client, because
  -- this is the number that costs money.
  select count(*) into v_earned
  from public.referral_rewards
  where user_id = v_invite.inviter_id and role = 'inviter';

  if v_earned >= v_cap then
    update public.referral_invites
       set status = 'blocked',
           blocked_reason = 'inviter reward cap reached'
     where id = v_invite.id;
    return 'inviter_cap_reached';
  end if;

  insert into public.referral_rewards (user_id, invite_id, role, kind, value, label)
  values (v_invite.inviter_id, v_invite.id, 'inviter', p_kind, p_value, p_label)
  on conflict (invite_id, role) do nothing;

  insert into public.referral_rewards (user_id, invite_id, role, kind, value, label)
  values (v_me, v_invite.id, 'invitee', p_kind, p_value, p_label)
  on conflict (invite_id, role) do nothing;

  update public.referral_invites
     set status = 'credited',
         qualified_at = coalesce(qualified_at, now()),
         credited_at = now()
   where id = v_invite.id;

  return 'ok';
end;
$$;

grant execute on function public.qualify_referral(text, int, text, int) to authenticated;


-- ---------------------------------------------------------------------
-- The questions this schema exists to answer (run from the dashboard).
-- ---------------------------------------------------------------------
-- Funnel, and therefore conversion rate:
--   select status, count(*) from public.referral_invites group by status;
--
-- Reward cost so far, by kind:
--   select kind, count(*), sum(value) from public.referral_rewards group by kind;
--
-- K-factor inputs (invites per user x conversion):
--   select
--     (select count(*) from public.referral_invites)::float
--       / nullif((select count(*) from public.referral_codes), 0) as invites_per_user,
--     (select count(*) from public.referral_invites where status = 'credited')::float
--       / nullif((select count(*) from public.referral_invites), 0)  as conversion;
