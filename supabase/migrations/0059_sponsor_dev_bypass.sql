-- =====================================================================
-- 0059_sponsor_dev_bypass.sql -- a way to demo activation before an
--                                email provider exists.
-- ---------------------------------------------------------------------
-- THE PROBLEM THIS SOLVES, STATED PLAINLY
--
-- 0058 built the whole activation path and said so: the code is written
-- to sponsor_activation_codes and NOTHING DELIVERS IT. There is no
-- transactional email provider on this project (STILL-OPEN 11.6 -- the
-- choice between Resend / SES / Postmark is still open). So the feature
-- is complete and unusable, which is the worst state to demo from.
--
-- THE TEMPTING WRONG FIX, and why it is not taken
--
-- The easy fix is to return the code from request_sponsor_activation()
-- so the app can show it. That deletes the feature. The code exists to
-- prove the person CONTROLS the address; handing it back to whoever
-- asked proves nothing, and anyone typing someone@bigcompany.com would
-- get Premium. The verification would still LOOK present in the UI --
-- which is worse than absent, because it would be trusted.
--
-- WHAT IS DONE INSTEAD
--
-- One nullable column on the sponsor: dev_bypass_code. When it is NULL
-- -- which is the default, and must be the state of every real customer
-- -- nothing changes at all; the only accepted code is the one that was
-- generated and mailed. When it is set, that sponsor ALSO accepts the
-- fixed string.
--
-- Everything else on the path stays real and is still exercised by a
-- demo: the domain must match, the sponsor must be active, a seat must
-- be free, the rate limit still applies, the code row is still consumed
-- so it is single-use, and the grant still records its source. The only
-- thing skipped is the inbox.
--
-- HOW THE BLAST RADIUS IS KEPT SMALL
--
--   1. Opt-in per sponsor. Not a global flag, not an environment
--      variable read at runtime. A sponsor without the column set is
--      untouched, so leaving one demo row switched on cannot weaken
--      anybody else.
--   2. It is AUDITED DIFFERENTLY. A bypassed activation returns the
--      code 'activated_dev_bypass', not 'activated', so admin_audit
--      shows exactly which grants skipped verification. A backdoor you
--      cannot find in the log is the one that stays.
--   3. A check constraint refuses a short bypass string, so nobody sets
--      it to '123456' and turns a demo affordance into a guessable one.
--
-- ⚠️ MUST BE NULL FOR EVERY PAYING CUSTOMER. Set it only on the demo
-- sponsor created by supabase/seed/sponsor_demo.sql. To audit
-- production at any time:
--
--   select id, name, status from public.sponsors
--    where dev_bypass_code is not null;
--
-- PREREQ: 0058.
-- =====================================================================


alter table public.sponsors
  add column if not exists dev_bypass_code text;

comment on column public.sponsors.dev_bypass_code is
  'DEMO ONLY. When set, this sponsor also accepts this fixed activation code because no email provider is wired yet (STILL-OPEN 11.6). Must be NULL for every real customer; bypassed activations audit as activated_dev_bypass.';

-- Long enough that it is not guessable in five attempts. The attempt
-- limit below still applies to it, but a six-digit demo string plus a
-- known domain would be a real hole rather than a demo one.
alter table public.sponsors
  drop constraint if exists sponsors_dev_bypass_len;
alter table public.sponsors
  add constraint sponsors_dev_bypass_len
  check (dev_bypass_code is null or length(dev_bypass_code) >= 10);

-- The panel must never be able to set this. Directus was granted
-- table-level write on sponsors in 0058, and a column-level revoke does
-- not narrow an existing table-level grant -- so the grant is replaced
-- with an explicit column list that omits this one. An editor can still
-- manage every commercial field; they cannot mint a backdoor.
revoke insert, update on public.sponsors from directus_cms;
grant insert (id, name, kind, plan_id, seats_purchased, status,
              renewal_at, logo_url, support_contact, created_at, updated_at),
      update (name, kind, plan_id, seats_purchased, status,
              renewal_at, logo_url, support_contact, updated_at)
  on public.sponsors to directus_cms;


-- ---------------------------------------------------------------------
-- confirm_sponsor_activation -- replaced.
--
-- The ONLY behavioural change is the comparison in step 5 and the
-- success code in step 9. The sponsor is now loaded earlier because the
-- comparison needs it; everything else is 0058 verbatim, kept whole
-- rather than diffed so the file reads as the current truth.
-- ---------------------------------------------------------------------
create or replace function public.confirm_sponsor_activation(
  p_work_email text,
  p_code       text
) returns jsonb
language plpgsql security definer set search_path = ''
as $$
declare
  v_email  text := lower(trim(p_work_email));
  v_row    record;
  v_uid    uuid := auth.uid();
  v_used   int;
  v_spons  record;
  v_given  text := trim(p_code);
  v_bypass boolean := false;
begin
  if v_uid is null then
    return jsonb_build_object('ok', false, 'code', 'not_signed_in',
      'message', 'Sign in first, then activate your employer benefit.');
  end if;

  -- 1. Is there a code in flight for this address at all?
  select * into v_row from public.sponsor_activation_codes
   where lower(work_email) = v_email and consumed_at is null
   order by created_at desc limit 1;

  if v_row.id is null then
    return public._refuse(v_uid::text, 'confirm_sponsor_activation',
      'sponsor_members', null, 'no_pending_code',
      'Request a new code.');
  end if;

  -- 2. Expiry. Ten minutes, checked before anything is spent.
  if v_row.expires_at < now() then
    return public._refuse(v_uid::text, 'confirm_sponsor_activation',
      'sponsor_members', v_row.sponsor_id, 'code_expired',
      'That code has expired. Request a new one.');
  end if;

  select * into v_spons from public.sponsors where id = v_row.sponsor_id;

  -- 3. Count the attempt BEFORE comparing, so a wrong guess costs one
  --    regardless of what happens next. Five guesses at six digits is a
  --    1-in-200,000 chance, which is the point of counting at all. Note
  --    that this counts bypass attempts too -- the demo path is not
  --    exempt from the attempt limit.
  update public.sponsor_activation_codes
     set attempts = attempts + 1 where id = v_row.id;

  if v_row.attempts + 1 > 5 then
    update public.sponsor_activation_codes
       set consumed_at = now() where id = v_row.id;
    return public._refuse(v_uid::text, 'confirm_sponsor_activation',
      'sponsor_members', v_row.sponsor_id, 'too_many_attempts',
      'Too many incorrect codes. Request a new one.');
  end if;

  -- 4. THE DEMO DOOR. Only open when the sponsor carries a bypass
  --    string; for every real customer the column is null and this
  --    whole branch is dead.
  v_bypass := v_spons.dev_bypass_code is not null
              and v_given = v_spons.dev_bypass_code;

  -- 5. The real comparison.
  if v_row.code <> v_given and not v_bypass then
    return public._refuse(v_uid::text, 'confirm_sponsor_activation',
      'sponsor_members', v_row.sponsor_id, 'wrong_code',
      'That code is not right.');
  end if;

  -- 6. Re-check eligibility at the moment of granting. Ten minutes is
  --    long enough for the last seat to go, or for a subscription to
  --    lapse, and the check that mattered was the one at the time of
  --    the grant.
  if v_spons.status <> 'active' then
    return public._refuse(v_uid::text, 'confirm_sponsor_activation',
      'sponsor_members', v_spons.id, 'sponsor_inactive',
      'This benefit is no longer active.');
  end if;

  if v_spons.seats_purchased is not null then
    select count(*) into v_used from public.sponsor_members
     where sponsor_id = v_spons.id and status = 'active';
    if v_used >= v_spons.seats_purchased then
      return public._refuse(v_uid::text, 'confirm_sponsor_activation',
        'sponsor_members', v_spons.id, 'no_seats_left',
        'All the seats your organisation purchased are in use.');
    end if;
  end if;

  -- 7. Single use.
  update public.sponsor_activation_codes
     set consumed_at = now() where id = v_row.id;

  -- 8. Membership.
  insert into public.sponsor_members (user_id, sponsor_id, work_email)
  values (v_uid, v_spons.id, v_email)
  on conflict (user_id, sponsor_id) do update
    set status = 'active', activated_at = now(), removed_at = null;

  perform public.grant_plan(v_uid, v_spons.plan_id, 'sponsor', v_spons.id,
                            null, v_uid::text);

  -- 9. Success -- but say WHICH kind. A bypassed grant is a different
  --    fact from a verified one, and the audit log is the only place
  --    that difference survives.
  return public._allow(v_uid::text, 'confirm_sponsor_activation',
    'sponsor_members', v_spons.id,
    case when v_bypass then 'activated_dev_bypass' else 'activated' end,
    format('Welcome. Your benefit is provided by %s.', v_spons.name),
    jsonb_build_object('sponsor', v_spons.id, 'plan', v_spons.plan_id,
                       'bypass', v_bypass));
end;
$$;

grant execute on function
  public.confirm_sponsor_activation(text, text) to authenticated;


-- =====================================================================
-- VERIFY
--
--   -- Nothing in production may carry one. This must return zero rows:
--   select id, name from public.sponsors where dev_bypass_code is not null;
--
--   -- The constraint refuses a guessable string:
--   update public.sponsors set dev_bypass_code = '123456' where id = 'x';
--     expect: new row violates check constraint "sponsors_dev_bypass_len"
--
--   -- Directus cannot set it even though it may edit the row:
--   set role directus_cms;
--   update public.sponsors set dev_bypass_code = 'aaaaaaaaaaaa';
--     expect: permission denied for table sponsors
--   reset role;
--
--   Then run supabase/seed/sponsor_demo.sql for a working demo sponsor.
-- =====================================================================
