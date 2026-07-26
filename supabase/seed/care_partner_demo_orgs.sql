-- =====================================================================
-- care_partner_demo_orgs.sql -- the organisation types the first seed
-- missed
-- ---------------------------------------------------------------------
-- ADDENDUM to care_partner_demo.sql. Run separately so the six tokens
-- already handed to the website stay valid -- re-running the first seed
-- would mint new ones and invalidate the test URLs mid-build.
--
-- WHY THESE TWO SPECIFICALLY. The website's organisation list had guessed
-- three type values that do not exist ("lab", "ivf", "organisation") and
-- was missing three that do: diagnostic_lab, corporate and insurance. A
-- partner of those types therefore rendered as a PERSON -- circular crop,
-- reading photo_url -- so a logo that was actually set never appeared.
--
-- hospital was in both the old and new lists, which is exactly why the
-- first seed could not catch the bug: every organisation in it was a
-- hospital. These are the rows that actually exercise the fix.
--
-- Safe to re-run. PREREQ: 0037, 0040, care_partner_demo.sql.
-- =====================================================================

begin;

delete from public.partner_referrals where partner_id like 'demo_org_%';
delete from public.care_partners      where id         like 'demo_org_%';

-- A diagnostic lab. Logo set, no photo -- if this renders as a circle or
-- falls back to initials, the type list is wrong again.
insert into public.care_partners
  (id, name, type, status, organisation, city, logo_url, trust)
values (
  'demo_org_lab', 'Aarogya Diagnostics', 'diagnostic_lab', 'active',
  '', 'Chennai',
  'https://dummyimage.com/240x240/2E7D6E/ffffff&text=A',
  '{"primary":"Recommended by"}'::jsonb
);

-- A corporate partner. 0038 seeds "Provided by" for this type, which the
-- website's allowlist was missing -- so this row also tests that fix. An
-- employer providing a benefit did not "invite" anybody.
insert into public.care_partners
  (id, name, type, status, organisation, city, logo_url, trust)
values (
  'demo_org_corp', 'Infosys Wellbeing', 'corporate', 'active',
  '', 'Bengaluru',
  'https://dummyimage.com/240x240/6A30B6/ffffff&text=I',
  '{"primary":"Provided by","secondary":"Your workplace benefit"}'::jsonb
);

-- An organisation with NO image at all. Must render square initials, not
-- a circle: the shape comes from the type, never from whether an image
-- happens to exist.
insert into public.care_partners
  (id, name, type, status, city, trust)
values (
  'demo_org_ivf', 'Nova IVF Fertility', 'ivf_centre', 'active', 'Pune',
  '{"primary":"Recommended by"}'::jsonb
);

select public.mint_partner_token('demo_org_lab',  'report')       as lab;
select public.mint_partner_token('demo_org_corp', 'email')        as corporate;
select public.mint_partner_token('demo_org_ivf',  'prescription') as ivf;

commit;

select pr.token,
       cp.name,
       cp.type,
       cp.status,
       pr.channel,
       coalesce(cp.logo_url, '(none)')      as logo,
       cp.trust->>'primary'                 as trust_label,
       'https://parentveda.in/care/' || pr.token || '?ch=' || pr.channel as url
  from public.partner_referrals pr
  join public.care_partners cp on cp.id = pr.partner_id
 where pr.partner_id like 'demo_org_%'
 order by cp.id;
