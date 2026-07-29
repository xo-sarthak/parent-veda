-- =====================================================================
-- verify_sponsor_gates.sql -- prove every activation refusal, prove the
--                             privacy wall, leave nothing behind.
-- ---------------------------------------------------------------------
-- HOW TO RUN: paste the whole file into the Supabase SQL editor and Run.
--
-- IT WILL FINISH WITH A RED "ERROR". THAT IS THE REPORT, AND IT IS
-- INTENTIONAL. Raising at the end forces Postgres to roll the whole
-- thing back, so the fixture sponsor, its domain, its members and their
-- codes never reach your data. Read the message: it is a pass/fail table.
--
-- WHY THIS EXISTS RATHER THAN A TEST FILE
--
-- The Dart tests can only read the migration TEXT -- they assert that
-- the SQL says what it should. That catches a deleted safeguard; it
-- cannot catch a safeguard that is present and does not work. This runs
-- the functions against real tables and reads what they actually
-- returned. The same pattern found a real defect in verify_admin_gates
-- (refusals were being rolled back by their own raise), which is the
-- argument for it.
--
-- IMPERSONATION. confirm_sponsor_activation() derives the user from
-- auth.uid(), so this borrows an EXISTING auth user and sets the JWT
-- claim for the transaction. Nothing is created in auth, and the claim
-- dies with the rollback. If the project has no users yet, those checks
-- report as skipped rather than failing.
--
-- Re-run after any change to 0058, 0059 or 0060.
-- =====================================================================

do $$
declare
  r        text := '';
  pass     int  := 0;
  fail     int  := 0;
  skip     int  := 0;
  js       jsonb;
  v_n      int;
  v_code   text;
  v_uid    uuid;
  v_uid2   uuid;
  v_cols   int;
begin
  -- ---- fixtures ---------------------------------------------------
  -- 1 seat, on purpose: the second activation must be refused, and
  -- that refusal is the seat cap doing its job in public.
  insert into public.sponsors
    (id, name, kind, plan_id, seats_purchased, status, dev_bypass_code)
  values
    ('zzv_sponsor', 'Verify Fixture Ltd', 'employer', 'employer_standard',
     1, 'active', 'ZZV-BYPASS-CODE');

  insert into public.sponsors
    (id, name, kind, plan_id, status)
  values
    ('zzv_lapsed', 'Lapsed Fixture Ltd', 'employer', 'employer_standard',
     'suspended');

  insert into public.sponsor_domains (domain, sponsor_id) values
    ('zzv-verify.test', 'zzv_sponsor'),
    ('zzv-lapsed.test', 'zzv_lapsed');

  select id into v_uid  from auth.users order by created_at limit 1;
  select id into v_uid2 from auth.users order by created_at desc limit 1;
  if v_uid2 = v_uid then v_uid2 := null; end if;

  -- =================================================================
  -- A. request_sponsor_activation -- who may even ask.
  -- =================================================================
  js := public.request_sponsor_activation('not-an-email');
  if (js ->> 'code') = 'invalid_email'
    then pass := pass + 1; r := r || E'\nok    malformed address              -> refused';
    else fail := fail + 1; r := r || E'\nFAIL  malformed address              -> ' || js::text;
  end if;

  js := public.request_sponsor_activation('someone@nobody-owns-this.test');
  if (js ->> 'code') = 'not_eligible'
    then pass := pass + 1; r := r || E'\nok    unknown domain                 -> refused';
    else fail := fail + 1; r := r || E'\nFAIL  unknown domain                 -> ' || js::text;
  end if;

  -- THE ENUMERATION CHECK. A suspended customer must be indistinguishable
  -- from a domain nobody owns -- otherwise this endpoint is a way to
  -- discover which companies bought ParentVeda, one guess at a time.
  js := public.request_sponsor_activation('someone@zzv-lapsed.test');
  if (js ->> 'code') = 'not_eligible'
    then pass := pass + 1; r := r || E'\nok    suspended customer             -> SAME answer';
    else fail := fail + 1; r := r || E'\nFAIL  suspended customer LEAKS       -> ' || js::text;
  end if;

  js := public.request_sponsor_activation('alice@zzv-verify.test');
  if (js ->> 'ok') = 'true' and (js ->> 'code') = 'code_sent'
    then pass := pass + 1; r := r || E'\nok    eligible address               -> code issued';
    else fail := fail + 1; r := r || E'\nFAIL  eligible address               -> ' || js::text;
  end if;

  -- The code must not be in the response. If it were, proving control
  -- of the address would be theatre and the whole step pointless.
  if not (js::text ilike '%' || (select code from public.sponsor_activation_codes
                                  where work_email = 'alice@zzv-verify.test'
                                  order by created_at desc limit 1) || '%')
    then pass := pass + 1; r := r || E'\nok    code NOT returned to caller';
    else fail := fail + 1; r := r || E'\nFAIL  code LEAKED in the response';
  end if;

  -- Rate limit: three per address per hour, so this is not free mail to
  -- anyone at a customer's domain.
  perform public.request_sponsor_activation('alice@zzv-verify.test');
  perform public.request_sponsor_activation('alice@zzv-verify.test');
  js := public.request_sponsor_activation('alice@zzv-verify.test');
  if (js ->> 'code') = 'too_many_requests'
    then pass := pass + 1; r := r || E'\nok    4th request in an hour        -> refused';
    else fail := fail + 1; r := r || E'\nFAIL  rate limit NOT enforced       -> ' || js::text;
  end if;

  -- =================================================================
  -- B. confirm_sponsor_activation -- the grant.
  -- =================================================================
  if v_uid is null then
    skip := skip + 1;
    r := r || E'\nskip  confirm/roster checks (no auth.users rows)';
  else
    perform set_config('request.jwt.claims',
      json_build_object('sub', v_uid::text, 'role', 'authenticated')::text, true);

    -- An address with no code in flight.
    js := public.confirm_sponsor_activation('bob@zzv-verify.test', '000000');
    if (js ->> 'code') = 'no_pending_code'
      then pass := pass + 1; r := r || E'\nok    confirm with no code request   -> refused';
      else fail := fail + 1; r := r || E'\nFAIL  confirm with no code request   -> ' || js::text;
    end if;

    -- A wrong code, and the bypass string must NOT rescue a wrong one on
    -- a sponsor that does not carry it.
    js := public.confirm_sponsor_activation('alice@zzv-verify.test', '999999');
    if (js ->> 'code') = 'wrong_code'
      then pass := pass + 1; r := r || E'\nok    wrong code                     -> refused';
      else fail := fail + 1; r := r || E'\nFAIL  wrong code                     -> ' || js::text;
    end if;

    -- Expiry is checked before anything is spent.
    update public.sponsor_activation_codes
       set expires_at = now() - interval '1 minute'
     where work_email = 'alice@zzv-verify.test' and consumed_at is null;
    js := public.confirm_sponsor_activation('alice@zzv-verify.test', '123456');
    if (js ->> 'code') = 'code_expired'
      then pass := pass + 1; r := r || E'\nok    expired code                   -> refused';
      else fail := fail + 1; r := r || E'\nFAIL  expired code                   -> ' || js::text;
    end if;

    -- Now a real one, accepted with the REAL code (not the bypass), so
    -- the ordinary path is what is proven here.
    --
    -- ⚠️ A DIFFERENT ADDRESS, and the reason is worth keeping: alice has
    -- already spent her three-codes-per-hour on the rate-limit check
    -- above, so asking her for one more is refused and there is no code
    -- to confirm. The first version of this file reused her here and
    -- five later checks failed downstream of one silent empty v_code.
    -- Consuming her rows does not help -- the limit counts requests in
    -- the last hour, not live codes. bob has asked for nothing yet.
    perform public.request_sponsor_activation('bob@zzv-verify.test');
    select code into v_code from public.sponsor_activation_codes
     where work_email = 'bob@zzv-verify.test' and consumed_at is null
     order by created_at desc limit 1;

    if v_code is null then
      fail := fail + 1;
      r := r || E'\nFAIL  no code was issued to bob -- later checks are void';
    end if;

    js := public.confirm_sponsor_activation('bob@zzv-verify.test', v_code);
    if (js ->> 'ok') = 'true' and (js ->> 'code') = 'activated'
      then pass := pass + 1; r := r || E'\nok    correct code                   -> activated';
      else fail := fail + 1; r := r || E'\nFAIL  correct code                   -> ' || js::text;
    end if;

    -- Single use: the same code again must not work.
    js := public.confirm_sponsor_activation('bob@zzv-verify.test', v_code);
    if (js ->> 'ok') <> 'true'
      then pass := pass + 1; r := r || E'\nok    code reuse                     -> refused';
      else fail := fail + 1; r := r || E'\nFAIL  code REUSABLE                  -> ' || js::text;
    end if;

    -- The grant landed, and it recorded WHERE it came from -- which is
    -- the only reason a leaver can lose this and keep a Premium they
    -- bought themselves.
    select count(*) into v_n from public.user_entitlements
     where user_id = v_uid and source = 'sponsor' and source_ref = 'zzv_sponsor';
    if v_n = 1
      then pass := pass + 1; r := r || E'\nok    entitlement granted, source recorded';
      else fail := fail + 1; r := r || E'\nFAIL  entitlement rows: ' || v_n || ' (expected 1)';
    end if;

    -- The employee's own view of it.
    js := public.my_sponsor();
    if (js ->> 'sponsor_id') = 'zzv_sponsor' and (js ->> 'name') = 'Verify Fixture Ltd'
      then pass := pass + 1; r := r || E'\nok    my_sponsor() answers for the caller';
      else fail := fail + 1; r := r || E'\nFAIL  my_sponsor()                   -> ' || js::text;
    end if;

    -- my_sponsor() must not hand out commercial facts. An employee has
    -- no business knowing the seat count or the renewal date.
    if not (js ? 'seats_purchased') and not (js ? 'renewal_at')
      then pass := pass + 1; r := r || E'\nok    my_sponsor() hides seats/renewal';
      else fail := fail + 1; r := r || E'\nFAIL  my_sponsor() LEAKS commercial  -> ' || js::text;
    end if;

    -- The same work email cannot be re-used to farm a second seat. Note
    -- this must be refused BEFORE the rate limit is consulted, or the
    -- answer would depend on how many codes were asked for -- the
    -- function checks membership first, and this is what pins that.
    js := public.request_sponsor_activation('bob@zzv-verify.test');
    if (js ->> 'code') = 'already_activated'
      then pass := pass + 1; r := r || E'\nok    re-using a work email          -> refused';
      else fail := fail + 1; r := r || E'\nFAIL  work email re-usable           -> ' || js::text;
    end if;

    -- SEAT CAP. One seat was bought and one is taken, so the next
    -- person at the same company is refused at the door.
    js := public.request_sponsor_activation('carol@zzv-verify.test');
    if (js ->> 'code') = 'no_seats_left'
      then pass := pass + 1; r := r || E'\nok    seat cap reached               -> refused';
      else fail := fail + 1; r := r || E'\nFAIL  seat cap NOT enforced          -> ' || js::text;
    end if;

    -- =================================================================
    -- C. 0059 -- the demo door, and its blast radius.
    -- =================================================================
    update public.sponsors set seats_purchased = 5 where id = 'zzv_sponsor';
    perform public.request_sponsor_activation('dave@zzv-verify.test');

    -- A bypass grant must be AUDITED DIFFERENTLY. A backdoor you cannot
    -- find in the log is the one that stays.
    --
    -- bob's membership goes first because sponsor_members is keyed on
    -- (user_id, sponsor_id): with only one borrowed auth user, dave's
    -- activation would otherwise land as an upsert on bob's row and
    -- keep bob's work_email, which makes the roster read confusingly.
    delete from public.sponsor_members
     where user_id = v_uid and sponsor_id = 'zzv_sponsor';
    js := public.confirm_sponsor_activation('dave@zzv-verify.test', 'ZZV-BYPASS-CODE');
    if (js ->> 'ok') = 'true' and (js ->> 'code') = 'activated_dev_bypass'
      then pass := pass + 1; r := r || E'\nok    bypass works AND is labelled';
      else fail := fail + 1; r := r || E'\nFAIL  bypass                         -> ' || js::text;
    end if;

    select count(*) into v_n from public.admin_audit
     where target_id = 'zzv_sponsor' and detail = 'activated_dev_bypass';
    if v_n = 1
      then pass := pass + 1; r := r || E'\nok    bypass is findable in the audit log';
      else fail := fail + 1; r := r || E'\nFAIL  bypass audit rows: ' || v_n;
    end if;

    -- The bypass belongs to ONE sponsor. It must do nothing anywhere else.
    update public.sponsors set status = 'active' where id = 'zzv_lapsed';
    perform public.request_sponsor_activation('erin@zzv-lapsed.test');
    js := public.confirm_sponsor_activation('erin@zzv-lapsed.test', 'ZZV-BYPASS-CODE');
    if (js ->> 'code') = 'wrong_code'
      then pass := pass + 1; r := r || E'\nok    bypass does NOT work on another sponsor';
      else fail := fail + 1; r := r || E'\nFAIL  bypass is GLOBAL               -> ' || js::text;
    end if;

    -- A member belonging to the OTHER sponsor, so the cross-tenant check
    -- below has something it could leak. A test for a leak with nothing
    -- to leak passes for the wrong reason.
    --
    -- ⚠️ activated_at is set explicitly LATER, and this is not cosmetic.
    -- now() is the TRANSACTION timestamp, not the statement's -- inside
    -- one transaction every default activated_at is byte-identical. With
    -- only one borrowed auth user this row and dave's would tie, and
    -- my_sponsor_admin_id()'s "oldest membership wins" tie-break would
    -- pick arbitrarily: the admin checks below would pass or fail by
    -- luck of the row order.
    insert into public.sponsor_members
      (user_id, sponsor_id, work_email, activated_at)
    values (coalesce(v_uid2, v_uid), 'zzv_lapsed', 'frank@zzv-lapsed.test',
            now() + interval '1 hour');

    -- =================================================================
    -- D. 0060 -- the sponsor admin wall.
    -- =================================================================
    -- Membership alone is not enough. Without the capability, nothing.
    if public.my_sponsor_admin_id() is null
      then pass := pass + 1; r := r || E'\nok    member WITHOUT capability      -> not an admin';
      else fail := fail + 1; r := r || E'\nFAIL  membership alone grants admin';
    end if;

    js := public.sponsor_dashboard();
    if (js ->> 'code') = 'not_a_sponsor_admin'
      then pass := pass + 1; r := r || E'\nok    dashboard for a non-admin      -> refused';
      else fail := fail + 1; r := r || E'\nFAIL  dashboard leaked to non-admin  -> ' || js::text;
    end if;

    select count(*) into v_n from public.sponsor_roster();
    if v_n = 0
      then pass := pass + 1; r := r || E'\nok    roster for a non-admin         -> 0 rows';
      else fail := fail + 1; r := r || E'\nFAIL  roster leaked ' || v_n || ' row(s)';
    end if;

    -- Now make them one.
    perform public.grant_plan(v_uid, 'sponsor_admin', 'internal',
                              'zzv_sponsor', null, 'verify');

    if public.my_sponsor_admin_id() = 'zzv_sponsor'
      then pass := pass + 1; r := r || E'\nok    capability + membership        -> admin';
      else fail := fail + 1; r := r || E'\nFAIL  admin not resolved';
    end if;

    js := public.sponsor_dashboard();
    if (js ->> 'ok') = 'true' and (js ->> 'sponsor_id') = 'zzv_sponsor'
      then pass := pass + 1; r := r || E'\nok    dashboard answers for the caller''s company';
      else fail := fail + 1; r := r || E'\nFAIL  dashboard                      -> ' || js::text;
    end if;

    -- SUPPRESSION. One member is far below the threshold, so behaviour
    -- must come back NULL and say so -- not zero. A zero reads as a
    -- fact; this is a policy.
    if (js ->> 'suppressed') = 'true'
       and js ->> 'consultations_booked' is null
       and js ->> 'activated' is not null
      then pass := pass + 1; r := r || E'\nok    small cohort: behaviour withheld, headcount kept';
      else fail := fail + 1; r := r || E'\nFAIL  suppression                    -> ' || js::text;
    end if;

    -- THE PRIVACY PROMISE, as a signature. The roster cannot leak a
    -- user id because the function does not return one -- a caller
    -- cannot select a column that is not in the return type.
    select count(*) into v_cols
      from pg_proc p join pg_namespace n on n.oid = p.pronamespace
     where n.nspname = 'public' and p.proname = 'sponsor_roster'
       and pg_get_function_result(p.oid) ilike '%user_id%';
    if v_cols = 0
      then pass := pass + 1; r := r || E'\nok    roster exposes NO user id';
      else fail := fail + 1; r := r || E'\nFAIL  roster returns a user id column';
    end if;

    select count(*) into v_n from public.sponsor_roster();
    if v_n >= 1
      then pass := pass + 1; r := r || E'\nok    admin sees their own roster (' || v_n || ')';
      else fail := fail + 1; r := r || E'\nFAIL  admin sees an empty roster';
    end if;

    -- CROSS-TENANT. The one failure that would end the product. The
    -- lapsed fixture has its own member; none of them may appear.
    select count(*) into v_n from public.sponsor_roster() sr
     join public.sponsor_members m on lower(m.work_email) = lower(sr.work_email)
     where m.sponsor_id <> 'zzv_sponsor';
    if v_n = 0
      then pass := pass + 1; r := r || E'\nok    cross-tenant: 0 rows from another sponsor';
      else fail := fail + 1; r := r || E'\nFAIL  CROSS-TENANT LEAK: ' || v_n || ' row(s)';
    end if;

    -- An admin at A cannot spell their way into B: the wrapper takes no
    -- sponsor id at all, so there is nothing to change.
    --
    -- ⚠️ THIS MUST RUN BEFORE THE REMOVAL BELOW. my_sponsor_admin_id()
    -- requires an ACTIVE membership, and the only member we have to
    -- remove is the caller -- so removing them correctly strips their
    -- own admin rights, and every later admin call answers
    -- not_a_sponsor_admin. That is the function behaving properly; it
    -- was the test order that was wrong.
    js := public.sponsor_remove_member('frank@zzv-lapsed.test');
    if (js ->> 'code') = 'not_a_member'
      then pass := pass + 1; r := r || E'\nok    admin cannot remove another company''s member';
      else fail := fail + 1; r := r || E'\nFAIL  cross-tenant removal           -> ' || js::text;
    end if;

    -- Removing a leaver takes back the sponsored grant and nothing else.
    js := public.sponsor_remove_member('dave@zzv-verify.test');
    if (js ->> 'ok') = 'true'
      then pass := pass + 1; r := r || E'\nok    admin removes a leaver by email';
      else fail := fail + 1; r := r || E'\nFAIL  remove                         -> ' || js::text;
    end if;

    select count(*) into v_n from public.user_entitlements
     where user_id = v_uid and source = 'sponsor' and source_ref = 'zzv_sponsor';
    if v_n = 0
      then pass := pass + 1; r := r || E'\nok    leaver loses the SPONSORED plan';
      else fail := fail + 1; r := r || E'\nFAIL  sponsored entitlement survived removal';
    end if;

    select count(*) into v_n from public.user_entitlements
     where user_id = v_uid and plan_id = 'sponsor_admin';
    if v_n = 1
      then pass := pass + 1; r := r || E'\nok    ...and keeps what a different source granted';
      else fail := fail + 1; r := r || E'\nFAIL  removal took an unrelated grant too';
    end if;

    -- ...and having removed themselves, they are no longer an admin.
    -- Worth asserting rather than leaving as a surprise: it is the
    -- correct behaviour, and it is the reason the cross-tenant check
    -- above had to come first.
    if public.my_sponsor_admin_id() is null
      then pass := pass + 1; r := r || E'\nok    an admin who removes themselves loses the dashboard';
      else fail := fail + 1; r := r || E'\nFAIL  removed member still resolves as admin';
    end if;

    perform set_config('request.jwt.claims', null, true);
  end if;

  -- =================================================================
  -- E. THE AUDIT TRAIL -- refusals are the rows a log exists for.
  -- =================================================================
  select count(*) into v_n from public.admin_audit
   where action in ('request_sponsor_activation', 'confirm_sponsor_activation',
                    'sponsor_remove_member')
     and outcome = 'refused';
  if v_n >= 6
    then pass := pass + 1; r := r || E'\nok    REFUSALS recorded (' || v_n || ')';
    else fail := fail + 1; r := r || E'\nFAIL  refusals recorded: ' || v_n || ' (expected 6+)';
  end if;

  select count(*) into v_n from public.admin_audit
   where action in ('request_sponsor_activation', 'confirm_sponsor_activation')
     and outcome = 'refused' and coalesce(detail, '') = '';
  if v_n = 0
    then pass := pass + 1; r := r || E'\nok    every refusal carries a code';
    else fail := fail + 1; r := r || E'\nFAIL  ' || v_n || ' refusal(s) with no code';
  end if;

  raise exception E'\n\n=== SPONSOR GATE VERIFICATION ===%\n\nPASSED %  FAILED %  SKIPPED %\n\n(This "error" is the report. It forces the rollback -- no fixtures were kept.)\n',
    r, pass, fail, skip;
end $$;
