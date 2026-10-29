-- =====================================================================
-- verify_rotation.sql -- prove a rotation keeps the per-doctor codes
-- (0134), and leave nothing behind.
-- ---------------------------------------------------------------------
-- HOW TO RUN: paste the whole file into the Supabase SQL editor and Run,
-- AFTER 0134.
--
-- IT WILL FINISH WITH A RED "ERROR". THAT IS THE REPORT, AND IT IS
-- INTENTIONAL. Raising at the end rolls the whole block back, so the
-- fixture clinics, doctors and codes below never reach your data. Read
-- the message: it is a pass/fail table. Same mould as
-- verify_admin_gates.sql.
--
-- The cast:
--   zzr_clinic   a clinic with per-doctor codes
--     zzr_arjun    member, has a code             -> re-minted
--     zzr_priya    member, has a code             -> re-minted
--     zzr_left     had a code, moved to zzr_other -> NOT re-minted
--     zzr_never    member, never had a code       -> not given one
--     zzr_lapsed   member, code already expired   -> not re-minted
--   zzr_other    another clinic                  -> untouched throughout
--   zzr_solo     an own practice (expert_id = zzr_solo_doc)
--
-- Every timestamp below is the transaction's now(), so "current" is
-- decided exactly as the functions decide it.
-- =====================================================================

do $$
declare
  r      text := '';
  pass   int  := 0;
  fail   int  := 0;
  js     jsonb;
  v_tok  text;
  v_old  text;
  v_n    int;
  v_m    int;
begin
  -- ---- fixtures --------------------------------------------------
  insert into public.care_partners (id, name, type, status) values
    ('zzr_clinic', 'Verify Clinic', 'hospital', 'active'),
    ('zzr_other',  'Verify Other',  'hospital', 'active');
  insert into public.care_partners (id, name, type, status, expert_id) values
    ('zzr_solo', 'Verify Solo', 'doctor', 'active', 'zzr_solo_doc');

  insert into public.expert_profiles (expert_id, name, partner_id) values
    ('zzr_arjun',    'Arjun',  'zzr_clinic'),
    ('zzr_priya',    'Priya',  'zzr_clinic'),
    ('zzr_left',     'Left',   'zzr_clinic'),
    ('zzr_never',    'Never',  'zzr_clinic'),
    ('zzr_lapsed',   'Lapsed', 'zzr_clinic'),
    ('zzr_solo_doc', 'Solo',   'zzr_solo');

  perform public.mint_partner_token('zzr_clinic');
  perform public.mint_partner_token('zzr_clinic', 'qr', null, null, 'zzr_arjun');
  perform public.mint_partner_token('zzr_clinic', 'qr', null, null, 'zzr_priya');
  perform public.mint_partner_token('zzr_clinic', 'qr', null, null, 'zzr_left');
  perform public.mint_partner_token('zzr_clinic', 'qr', null, now() - interval '1 day', 'zzr_lapsed');
  perform public.mint_partner_token('zzr_other');
  perform public.mint_partner_token('zzr_solo');
  perform public.mint_partner_token('zzr_solo', 'qr', null, null, 'zzr_solo_doc');

  -- Arjun's code before, to prove the new one is NEW.
  select token into v_old from public.partner_referrals
   where expert_id = 'zzr_arjun' and retired_at is null;

  -- zzr_left moves on AFTER her code was printed.
  update public.expert_profiles set partner_id = 'zzr_other'
   where expert_id = 'zzr_left';

  -- =================================================================
  -- A. rotate_partner_token (0069 path, grace window)
  -- =================================================================
  begin
    perform public.rotate_partner_token('zzr_clinic', '  ', 30);
    fail := fail + 1; r := r || E'\nFAIL  rotate, BLANK reason           -> accepted';
  exception when others then
    pass := pass + 1; r := r || E'\nok    rotate, BLANK reason           -> refused';
  end;

  v_tok := public.rotate_partner_token('zzr_clinic', 'verify', 30);

  select count(*) into v_n from public.partner_referrals
   where token = v_tok and expert_id is null and retired_at is null;
  if v_n = 1
    then pass := pass + 1; r := r || E'\nok    returns the new ORG-WIDE code';
    else fail := fail + 1; r := r || E'\nFAIL  returned token is not a current org code';
  end if;

  select count(*) into v_n from public.partner_referrals
   where partner_id = 'zzr_clinic' and retired_at is null and active
     and expert_id in ('zzr_arjun', 'zzr_priya');
  if v_n = 2
    then pass := pass + 1; r := r || E'\nok    arjun + priya each re-minted';
    else fail := fail + 1; r := r || E'\nFAIL  current member codes: ' || v_n || ' (expected 2)';
  end if;

  select count(*) into v_n from public.partner_referrals
   where expert_id = 'zzr_arjun' and retired_at is null and token <> v_old;
  if v_n = 1
    then pass := pass + 1; r := r || E'\nok    arjun''s code is a NEW token';
    else fail := fail + 1; r := r || E'\nFAIL  arjun''s current code is not new';
  end if;

  select count(*) into v_n from public.partner_referrals
   where expert_id = 'zzr_left' and retired_at is null;
  select count(*) into v_m from public.partner_referrals
   where expert_id = 'zzr_left' and retired_at is not null
     and expires_at > now();
  if v_n = 0 and v_m = 1
    then pass := pass + 1; r := r || E'\nok    LEFT doctor: no new code, old one in grace';
    else fail := fail + 1; r := r || E'\nFAIL  left doctor: current ' || v_n || ', in grace ' || v_m;
  end if;

  select count(*) into v_n from public.partner_referrals
   where expert_id in ('zzr_never', 'zzr_lapsed') and retired_at is null;
  if v_n = 0
    then pass := pass + 1; r := r || E'\nok    NEVER-had and LAPSED: nothing minted';
    else fail := fail + 1; r := r || E'\nFAIL  ' || v_n || ' code(s) minted for never/lapsed';
  end if;

  select count(*) into v_n from public.partner_referrals
   where partner_id = 'zzr_clinic' and retired_at is not null
     and (retired_reason is distinct from 'verify'
          or expires_at <> now() + interval '30 days');
  if v_n = 0
    then pass := pass + 1; r := r || E'\nok    retired rows carry reason + 30-day grace';
    else fail := fail + 1; r := r || E'\nFAIL  ' || v_n || ' retired row(s) without reason/grace';
  end if;

  select count(*) into v_n from public.partner_referrals
   where partner_id = 'zzr_other' and retired_at is null and active;
  if v_n = 1
    then pass := pass + 1; r := r || E'\nok    another clinic is untouched';
    else fail := fail + 1; r := r || E'\nFAIL  zzr_other current codes: ' || v_n;
  end if;

  -- =================================================================
  -- B. rotate_partner_tokens (the panel's gate)
  -- =================================================================
  js := public.rotate_partner_tokens('zzr_clinic', 'wrong', 'verifier', 'verify');
  if (js ->> 'code') = 'not_confirmed'
    then pass := pass + 1; r := r || E'\nok    panel rotate, WRONG confirm    -> refused';
    else fail := fail + 1; r := r || E'\nFAIL  panel rotate, wrong confirm   -> ' || js::text;
  end if;

  js := public.rotate_partner_tokens('zzr_clinic', 'zzr_clinic', 'verifier', 'verify');
  if (js ->> 'ok') = 'true' and (js ->> 'reminted') = '2'
    then pass := pass + 1; r := r || E'\nok    panel rotate re-mints 2';
    else fail := fail + 1; r := r || E'\nFAIL  panel rotate                  -> ' || js::text;
  end if;

  select count(*) into v_n from public.partner_referrals
   where partner_id = 'zzr_clinic' and active and expert_id = 'zzr_arjun';
  if v_n = 1
    then pass := pass + 1; r := r || E'\nok    after the panel: one live code for arjun';
    else fail := fail + 1; r := r || E'\nFAIL  arjun live codes after panel: ' || v_n;
  end if;

  -- =================================================================
  -- C. an own practice rotates only its own codes
  -- =================================================================
  select count(*) into v_m from public.partner_referrals
   where partner_id <> 'zzr_solo' and partner_id like 'zzr_%' and active;

  perform public.rotate_partner_token('zzr_solo', 'verify', 30);

  select count(*) into v_n from public.partner_referrals
   where partner_id = 'zzr_solo' and expert_id = 'zzr_solo_doc'
     and retired_at is null and active;
  if v_n = 1
    then pass := pass + 1; r := r || E'\nok    solo doctor keeps her own code';
    else fail := fail + 1; r := r || E'\nFAIL  solo doctor current codes: ' || v_n;
  end if;

  select count(*) into v_n from public.partner_referrals
   where partner_id <> 'zzr_solo' and partner_id like 'zzr_%' and active;
  if v_n = v_m
    then pass := pass + 1; r := r || E'\nok    solo rotation touched no other partner';
    else fail := fail + 1; r := r || E'\nFAIL  other partners'' live rows ' || v_m || ' -> ' || v_n;
  end if;

  -- =================================================================
  -- D. clients still cannot reach any of it
  -- =================================================================
  if not has_function_privilege('authenticated',
         'public.rotate_partner_token(text, text, int)', 'execute')
     and not has_function_privilege('authenticated',
         'public.rotate_partner_tokens(text, text, text, text)', 'execute')
     and not has_function_privilege('authenticated',
         'public._remint_doctor_codes(text, text[])', 'execute')
     and not has_function_privilege('anon',
         'public._remint_doctor_codes(text, text[])', 'execute')
    then pass := pass + 1; r := r || E'\nok    no client can rotate or re-mint';
    else fail := fail + 1; r := r || E'\nFAIL  a client role can execute a rotation function';
  end if;

  raise exception E'\n\n=== ROTATION VERIFICATION (0134) ===%\n\nPASSED %  FAILED %\n\n(This "error" is the report. It forces the rollback -- no fixtures were kept.)\n',
    r, pass, fail;
end $$;
