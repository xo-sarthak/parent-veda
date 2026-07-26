-- =====================================================================
-- care_partner_demo.sql -- one fake partner, so the named-doctor half of
-- the /care/ page can actually be exercised
-- ---------------------------------------------------------------------
-- NOT a migration. Run by hand in the Supabase SQL editor (which runs as
-- service_role, which is what mint_partner_token requires).
--
-- Safe to re-run: it deletes its own rows first and nothing else. Every
-- id is prefixed demo_ so it is obvious what to remove before launch.
--
-- Covers the cases the website said were unverified:
--   * a PERSON with a photo         -> circle, photo_url
--   * an ORGANISATION with a logo   -> square, logo_url
--   * a partner with NO image       -> initials fallback
--   * an EXPIRED token              -> generic page, still reaches the store
--   * an INACTIVE partner           -> must not acquire
--   * a BANNED trust label          -> must render "Invited by" instead
--
-- The last one matters most. The DB CHECK constraint on
-- care_trust_messages blocks advertising language there, but
-- care_partners.trust is a plain jsonb column with no constraint, which is
-- exactly the hole a website allowlist has to cover. This seeds a row that
-- WILL try to render "Sponsored by" and must not be allowed to.
--
-- PREREQ: 0037, 0038, 0040.
-- =====================================================================

begin;

delete from public.partner_referrals where partner_id like 'demo_%';
delete from public.care_partners      where id         like 'demo_%';

-- 1. A person, with a photo. The ordinary case.
insert into public.care_partners
  (id, name, type, status, speciality, organisation, city, photo_url, trust)
values (
  'demo_meera', 'Dr Meera Rao', 'doctor', 'active',
  'Obstetrician & Gynaecologist', 'Rainbow Hospital', 'Hyderabad',
  'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=400&q=80',
  '{"primary":"Invited by",
    "secondary":"Your care partner",
    "shortWelcome":"I use ParentVeda with my patients — you will find your week-by-week guidance here.",
    "longWelcome":"Welcome. Everything here is evidence-based and reviewed. Bring any of it to your next appointment."}'::jsonb
);

-- 2. An organisation, with a logo. Square corners, different language.
insert into public.care_partners
  (id, name, type, status, speciality, organisation, city, logo_url, trust)
values (
  'demo_hospital', 'Rainbow Children''s Hospital', 'hospital', 'active',
  '', '', 'Hyderabad',
  'https://dummyimage.com/240x240/6A30B6/ffffff&text=R',
  '{"primary":"Recommended by","secondary":"Your trusted healthcare partner"}'::jsonb
);

-- 3. No image at all -> the initials fallback. "Dr" is stripped, so this
--    must render AK, never DA.
insert into public.care_partners
  (id, name, type, status, speciality, city, trust)
values (
  'demo_noimage', 'Dr Anjali Krishnan', 'lactation_consultant', 'active',
  'IBCLC Lactation Consultant', 'Bengaluru',
  '{"primary":"Connected through"}'::jsonb
);

-- 4. A trust label that MUST NOT render as written. If the page ever shows
--    "Sponsored by Dr Vikram Sethi", the allowlist has a hole.
insert into public.care_partners
  (id, name, type, status, speciality, city, trust)
values (
  'demo_badlabel', 'Dr Vikram Sethi', 'doctor', 'active',
  'Paediatrician', 'Pune',
  '{"primary":"Sponsored by","secondary":"Promoted partner"}'::jsonb
);

-- 5. Not active. The page should still be friendly, but this partner must
--    never acquire a family -- attribute_to_partner returns
--    partner_not_active.
insert into public.care_partners
  (id, name, type, status, speciality, city)
values (
  'demo_inactive', 'Dr Suresh Nair', 'doctor', 'inactive', 'Paediatrician',
  'Kochi'
);

-- Tokens. Minted by the database so the app and the website resolve the
-- same string -- the whole point of 0040.
select public.mint_partner_token('demo_meera',    'qr')       as demo_meera_qr;
select public.mint_partner_token('demo_hospital', 'poster')   as demo_hospital;
select public.mint_partner_token('demo_noimage',  'whatsapp') as demo_noimage;
select public.mint_partner_token('demo_badlabel', 'qr')       as demo_badlabel;
select public.mint_partner_token('demo_inactive', 'qr')       as demo_inactive;

-- 6. An EXPIRED token on the good partner. The page must fall back to the
--    generic version AND still send her to the store: a poster that has
--    been on a wall for two years should cost the doctor their credit,
--    never cost the parent the app.
select public.mint_partner_token(
  'demo_meera', 'poster', null, now() - interval '1 day') as demo_expired;

commit;

-- Every token, to paste into the website's test URLs.
select pr.token,
       cp.name,
       cp.type,
       cp.status,
       pr.channel,
       case when pr.expires_at < now() then 'EXPIRED' else 'ok' end as state,
       'https://parentveda.in/care/' || pr.token || '?ch=' || pr.channel as url
  from public.partner_referrals pr
  join public.care_partners cp on cp.id = pr.partner_id
 where pr.partner_id like 'demo_%'
 order by cp.id, pr.created_at;
