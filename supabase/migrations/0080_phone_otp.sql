-- =====================================================================
-- 0080_phone_otp.sql -- a verified phone number that is NOT an identity
-- ---------------------------------------------------------------------
-- The onboarding audit (docs/ONBOARDING-AUDIT.md §4) decided that Google is
-- the only way to be a user, and the phone is an ATTRIBUTE of that user —
-- verified, because WhatsApp will be sent to it, but never a second door
-- into the account.
--
-- That one sentence decides the whole design, so it is worth being explicit
-- about the road not taken. Supabase has phone auth built in: send an SMS,
-- verify the code, and the number becomes a login. Using it here would have
-- made every mother two identities — a Google one and a phone one — and
-- reopened the duplicate-account problem docs/AUTH-SETUP.md already warns
-- about: two profiles, two journals, and a woman who thinks her data
-- vanished. A number that can only ever be ATTACHED to a session that
-- already exists cannot fork anything.
--
-- So: the code is ours to generate, hash, store and check. The provider
-- (MSG91) only carries it. Which also means the audit row is ours — who
-- asked, for which number, how many times they guessed — instead of living
-- in a vendor dashboard we would have to log into to answer a support
-- question.
--
-- WHY THE RULE LIVES IN SQL AND NOT IN THE EDGE FUNCTION
-- "Three sends per number per ten minutes" is a rule about the TABLE. If the
-- function checks and then inserts, two requests racing through the same
-- check both pass (BACKEND-PATTERNS §16a: enforce where the thing being
-- protected lives). A security-definer function does the check and the
-- insert in one transaction, and the Edge function is left with nothing to
-- get wrong: it calls issue(), sends, calls consume().
--
-- WHAT A HASH BUYS HERE, HONESTLY
-- A six-digit code has a million values. Hashing it does not make it
-- unguessable offline — anyone holding the table AND the user id can try
-- all million in seconds. What the hash prevents is the cheap failure: a
-- backup, a log line, a screen-share of the dashboard, showing a live code
-- in clear. The real protections are the five-minute expiry and the
-- five-attempt cap, both enforced below. Say what a control does; do not
-- let a hash imply more than it delivers.
--
-- PREREQ: 0001 (profiles), 0015 (profiles.phone).
-- =====================================================================


-- 1) When the number was proven. Null means "typed, never confirmed" — the
--    WhatsApp engine (0016) should prefer verified numbers and may skip the
--    rest; that is its decision to take, recorded there, not here.
alter table public.profiles
  add column if not exists phone_verified_at timestamptz;


-- 2) phone_otps — one row per code issued. Server-written ONLY.
--    The app never reads this table: there is nothing on it a client should
--    see, and a select grant would be one policy typo away from exposing
--    hashes. No grant to authenticated at all, and RLS on with no policies,
--    which in Postgres means "nobody but the owner and service_role".
create table if not exists public.phone_otps (
  id                  uuid        primary key default gen_random_uuid(),
  user_id             uuid        not null references auth.users (id) on delete cascade,
  phone               text        not null,                      -- E.164, normalised SERVER-side
  code_hash           text        not null,                      -- sha256(user_id || ':' || code), hex
  attempts            int         not null default 0,            -- wrong guesses against this row
  expires_at          timestamptz not null,
  consumed_at         timestamptz,                               -- set once, on the matching guess
  provider            text,                                      -- 'msg91' | 'mock'
  provider_message_id text,
  created_at          timestamptz not null default now()
);

create index if not exists phone_otps_user_created
  on public.phone_otps (user_id, created_at desc);
create index if not exists phone_otps_phone_created
  on public.phone_otps (phone, created_at desc);

alter table public.phone_otps enable row level security;
grant select, insert, update, delete on public.phone_otps to service_role;
-- (deliberately: nothing for authenticated, and no policies)


-- 3) The limits, in one place, as constants a reader can find.
--    Changing a limit is a migration, not a redeploy — which is the point:
--    the number is reviewed, not tuned in a hurry from a function's env.
create or replace function public.phone_otp_limits()
returns table (
  ttl_seconds        int,
  max_attempts       int,
  per_phone_10min    int,
  per_user_per_day   int
)
language sql immutable
as $$ select 300, 5, 3, 10 $$;


-- ---------------------------------------------------------------------
-- phone_otp_issue(user, phone, code_hash) -> uuid
--
-- Checks both rate limits and inserts the row in the same transaction.
-- Raises with a machine-readable message the Edge function maps to 429:
--   'rate_limited:phone' — three codes to this number in ten minutes
--   'rate_limited:user'  — ten codes for this user today
-- Any earlier unconsumed code for the same (user, phone) is expired, so
-- only the latest code is ever valid — "I got two SMSes, which one?" has
-- exactly one right answer.
-- ---------------------------------------------------------------------
create or replace function public.phone_otp_issue(
  p_user_id   uuid,
  p_phone     text,
  p_code_hash text
)
returns uuid
language plpgsql
security definer set search_path = ''
as $$
declare
  v_lim  record;
  v_id   uuid;
begin
  select * into v_lim from public.phone_otp_limits();

  if p_phone !~ '^\+[1-9][0-9]{7,14}$' then
    raise exception 'invalid_phone';
  end if;

  if (select count(*) from public.phone_otps
       where phone = p_phone
         and created_at > now() - interval '10 minutes') >= v_lim.per_phone_10min then
    raise exception 'rate_limited:phone';
  end if;

  if (select count(*) from public.phone_otps
       where user_id = p_user_id
         and created_at > now() - interval '24 hours') >= v_lim.per_user_per_day then
    raise exception 'rate_limited:user';
  end if;

  -- Only one live code per (user, phone).
  update public.phone_otps
     set expires_at = now()
   where user_id = p_user_id
     and phone = p_phone
     and consumed_at is null
     and expires_at > now();

  insert into public.phone_otps (user_id, phone, code_hash, expires_at)
  values (p_user_id, p_phone, p_code_hash,
          now() + make_interval(secs => v_lim.ttl_seconds))
  returning id into v_id;

  return v_id;
end;
$$;

revoke execute on function
  public.phone_otp_issue(uuid, text, text) from public;


-- ---------------------------------------------------------------------
-- phone_otp_consume(user, phone, code_hash) -> text
--
-- Returns one of: 'verified' | 'wrong' | 'expired' | 'too_many' | 'none'.
-- A word, not a boolean, because the app owes her a different sentence
-- for each (BACKEND-PATTERNS §15b): "that code has expired, send another"
-- is not "that code is wrong, try again".
--
-- On 'verified' it ALSO stamps the profile — phone and phone_verified_at —
-- in the same transaction. The alternative, returning true and letting the
-- Edge function write the profile, is two writes that can disagree: a
-- consumed code and an unstamped profile if the second call fails. One
-- transaction, one truth.
--
-- Wrong guesses count against the row. After max_attempts the row is dead
-- even if the next guess would have been right; she has to send again,
-- which is the rate limit doing its job against a guesser.
-- ---------------------------------------------------------------------
create or replace function public.phone_otp_consume(
  p_user_id   uuid,
  p_phone     text,
  p_code_hash text
)
returns text
language plpgsql
security definer set search_path = ''
as $$
declare
  v_lim record;
  v_row public.phone_otps%rowtype;
begin
  select * into v_lim from public.phone_otp_limits();

  select * into v_row
    from public.phone_otps
   where user_id = p_user_id
     and phone = p_phone
     and consumed_at is null
   order by created_at desc
   limit 1
   for update;

  if not found then
    return 'none';
  end if;
  if v_row.expires_at <= now() then
    return 'expired';
  end if;
  if v_row.attempts >= v_lim.max_attempts then
    return 'too_many';
  end if;

  if v_row.code_hash <> p_code_hash then
    update public.phone_otps
       set attempts = attempts + 1
     where id = v_row.id;
    -- The caller gets 'too_many' on the guess that crosses the line, not
    -- one guess later, so the app can stop offering the boxes at once.
    if v_row.attempts + 1 >= v_lim.max_attempts then
      return 'too_many';
    end if;
    return 'wrong';
  end if;

  update public.phone_otps
     set consumed_at = now()
   where id = v_row.id;

  update public.profiles
     set phone             = p_phone,
         phone_verified_at = now()
   where id = p_user_id;

  return 'verified';
end;
$$;

revoke execute on function
  public.phone_otp_consume(uuid, text, text) from public;


-- ---------------------------------------------------------------------
-- phone_otp_sent(id, provider, provider_message_id)
-- Recorded AFTER the provider accepts the message, so a row with a null
-- provider is a code that was issued and never left — visible, not lost.
-- ---------------------------------------------------------------------
create or replace function public.phone_otp_sent(
  p_id                  uuid,
  p_provider            text,
  p_provider_message_id text
)
returns void
language sql
security definer set search_path = ''
as $$
  update public.phone_otps
     set provider = p_provider, provider_message_id = p_provider_message_id
   where id = p_id;
$$;

revoke execute on function
  public.phone_otp_sent(uuid, text, text) from public;


-- ---------------------------------------------------------------------
-- Housekeeping. Rows are useful for about a day (support: "did the code go
-- out?"); after seven they are only a table growing. pg_cron is already in
-- use by 0016; if this project does not have it, the delete is harmless to
-- run by hand.
-- ---------------------------------------------------------------------
create or replace function public.phone_otp_prune()
returns int
language plpgsql
security definer set search_path = ''
as $$
declare v_n int;
begin
  delete from public.phone_otps where created_at < now() - interval '7 days';
  get diagnostics v_n = row_count;
  return v_n;
end;
$$;

revoke execute on function public.phone_otp_prune() from public;
