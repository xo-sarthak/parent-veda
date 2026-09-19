-- =====================================================================
-- doctor_demo.sql -- a sample doctor's month, through the REAL writers
-- ---------------------------------------------------------------------
-- HOW TO RUN: fill the three values at the top, paste the whole file into
-- the Supabase SQL editor, Run. Then open ParentVeda+ as that doctor and
-- pull to refresh: Home, Appointments and Earnings fill with this data.
--
-- WHAT IT PROVES. Nothing here inserts into expert_earnings by hand. The
-- bookings go into booking_bookings and the 0084 TRIGGER writes the
-- ledger; the video revenue goes through accrue_video_earning(); the
-- sponsorship through add_manual_expert_earning(); the payout through
-- record_expert_payout(). So the Earnings tab you see is the production
-- path with data in it -- the user's test of "it just needs data and a
-- percentage" (2026-09-19).
--
-- PREREQ: 0084 and 0085 run. A parent account to book as (any signed-up
-- email; the demo books consultations in their name). An expert_profiles
-- row for the doctor (fee_inr set) -- the panel's "Adding a doctor" steps
-- 1-4, or the compiled catalogue id if it is one of those.
--
-- IDEMPOTENT: every row carries a 'demo-' prefix in its id or note, and the
-- cleanup block at the bottom removes exactly those. Run the cleanup, then
-- the seed, to reset.
-- =====================================================================

do $$
declare
  -- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  v_doctor_mail text := 'doctor@test.com';   -- the login that opens ParentVeda+
  v_expert      text := '';                  -- expert id; blank = the one linked to v_doctor_mail
  v_parent_mail text := '';                  -- a parent to book as; blank = any account that is not the doctor
  -- <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  v_doctor   uuid;
  v_parent   uuid;
  v_fee      int;
  v_slot     text;
  v_bk       text;
  v_i        int;
  v_when     timestamptz;
  v_video    text;
  v_prog     text;
begin
  select id into v_doctor from auth.users where lower(email) = lower(v_doctor_mail);

  -- The expert: given, else the one this login is linked to (expert_accounts).
  if v_expert = '' then
    select ea.expert_id into v_expert from public.expert_accounts ea where ea.user_id = v_doctor;
    if v_expert is null then
      raise exception 'no expert linked to %; set v_expert, or link the login first', v_doctor_mail;
    end if;
  end if;

  -- The parent: given, else the newest account that is not the doctor. A demo
  -- does not care who; it refuses only when there is nobody at all.
  if v_parent_mail <> '' then
    select id into v_parent from auth.users where lower(email) = lower(v_parent_mail);
    if v_parent is null then
      raise exception 'no auth user for %', v_parent_mail;
    end if;
  else
    select id into v_parent from auth.users
     where (v_doctor is null or id <> v_doctor)
     order by created_at desc limit 1;
    if v_parent is null then
      raise exception 'no account to book as; sign a parent up in the app first';
    end if;
  end if;

  -- The fee: the profile's, else ₹800 so the demo still shows money.
  select fee_inr * 100 into v_fee from public.expert_profiles where expert_id = v_expert;
  if v_fee is null then
    raise notice 'no expert_profiles row for %; using a demo fee of 800', v_expert;
    v_fee := 80000;
  elsif v_fee = 0 then
    v_fee := 80000;
  end if;

  -- 1. The invite: the doctor's email may sign in as this expert (0084).
  insert into public.expert_invites (email, expert_id, note)
  values (lower(v_doctor_mail), v_expert, 'demo-seed')
  on conflict (email) do update set expert_id = excluded.expert_id, note = 'demo-seed';

  -- 2. Consultations. Eight in the last five weeks (attended → payable),
  --    two this week (upcoming → accrued), one cancelled by the doctor
  --    (reversed). Each is a slot of capacity 1 -- the guard the trigger
  --    reads -- with the price recorded on the booking (0084).
  for v_i in 1..11 loop
    v_when := date_trunc('day', now()) - make_interval(days => (36 - v_i * 3)) + interval '10 hours 30 minutes';
    if v_i > 8 then v_when := date_trunc('day', now()) + make_interval(days => v_i - 8) + interval '17 hours'; end if;
    v_slot := 'demo-slot-' || v_expert || '-' || v_i;
    v_bk   := 'demo-bkg-'  || v_expert || '-' || v_i;

    insert into public.booking_slots (id, offering_id, expert_id, starts_utc, duration_min, capacity, booked)
    values (v_slot, 'consult_' || v_expert, v_expert, v_when, 30, 1, 1)
    on conflict (id) do nothing;

    insert into public.booking_bookings
      (id, user_id, offering_id, slot_id, stage, title, starts_utc, duration_min, status, price_paise)
    values
      (v_bk, v_parent, 'consult_' || v_expert, v_slot, 'pregnancy', 'Consultation',
       v_when, 30, 'upcoming', v_fee)
    on conflict (id) do nothing;

    -- The past ones happened; one of them was cancelled by the doctor.
    if v_i <= 8 then
      update public.booking_bookings set status = case when v_i = 5 then 'cancelled' else 'attended' end
       where id = v_bk and status = 'upcoming';
    end if;
  end loop;

  -- 3. A masterclass with twelve seats sold (capacity 40), last month.
  v_prog := 'demo-mc-' || v_expert;
  v_when := date_trunc('day', now()) - interval '20 days' + interval '19 hours';
  insert into public.booking_slots (id, offering_id, expert_id, starts_utc, duration_min, capacity, booked)
  values (v_prog || '-slot', v_prog, v_expert, v_when, 60, 40, 12)
  on conflict (id) do nothing;
  for v_i in 1..12 loop
    insert into public.booking_bookings
      (id, user_id, offering_id, slot_id, stage, title, starts_utc, duration_min, status, price_paise)
    values
      (v_prog || '-bkg-' || v_i, v_parent, v_prog, v_prog || '-slot', 'pregnancy',
       'Masterclass: Birth confidence', v_when, 60, 'upcoming', 49900)
    on conflict (id) do nothing;
    update public.booking_bookings set status = 'attended' where id = v_prog || '-bkg-' || v_i and status = 'upcoming';
  end loop;

  -- 4. A video: a link and a percentage, then last month's revenue typed in.
  insert into public.expert_videos (id, expert_id, url, title, share_bps)
  values ('demo-vid-' || v_expert, v_expert, 'https://www.youtube.com/watch?v=demo', 'Sleep basics for the first month', 2000)
  on conflict (id) do nothing;
  if not exists (select 1 from public.expert_earnings where ref_id = 'demo-vid-' || v_expert) then
    perform public.accrue_video_earning('demo-vid-' || v_expert,
      (date_trunc('month', now()) - interval '1 month')::date, 1240000, 'demo-seed: ad revenue, last month');
  end if;

  -- 5. A brand sponsorship as the named face: a manual row, 35%.
  if not exists (select 1 from public.expert_earnings where note = 'demo-seed: sponsored film, named face' and expert_id = v_expert) then
    perform public.add_manual_expert_earning(v_expert, 'sponsorship', 'Sponsored film: iron in pregnancy',
      now() - interval '25 days', 6000000, 3500, 'demo-seed: sponsored film, named face');
  end if;

  -- 6. Last month's payout: everything payable up to the end of last month,
  --    transferred by NEFT, recorded with its UTR.
  if not exists (select 1 from public.expert_payouts where expert_id = v_expert and note = 'demo-seed') then
    begin
      perform public.record_expert_payout(v_expert,
        (date_trunc('month', now()) - interval '1 day')::date,
        'DEMO' || to_char(now(), 'YYYYMMDD') || '0001', 'manual_neft', '4321', 'demo-seed');
    exception when others then
      raise notice 'no payout recorded: %', sqlerrm;   -- nothing payable before this month is fine
    end;
  end if;

  raise notice 'demo seeded for expert % booked as user % (11 consultations, 1 masterclass, 1 video, 1 sponsorship)', v_expert, v_parent;
end $$;


-- ---------------------------------------------------------------------
-- CLEANUP (run this block alone to remove the demo and nothing else)
-- ---------------------------------------------------------------------
-- do $$
-- declare v_expert text := '<the expert id the notice printed>';
-- begin
--   delete from public.expert_earnings where expert_id = v_expert
--     and (ref_id like 'demo-%' or note like 'demo-seed%'
--          or ref_id in (select id from public.booking_bookings where id like 'demo-%'));
--   delete from public.expert_payouts  where expert_id = v_expert and note = 'demo-seed';
--   delete from public.expert_videos   where id = 'demo-vid-' || v_expert;
--   delete from public.booking_bookings where id like 'demo-%';
--   delete from public.booking_slots    where id like 'demo-%';
--   delete from public.expert_invites   where note = 'demo-seed';
-- end $$;
