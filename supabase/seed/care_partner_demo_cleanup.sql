-- =====================================================================
-- care_partner_demo_cleanup.sql -- remove the fictional Care Partners.
-- ---------------------------------------------------------------------
-- WHY: care_partner_demo.sql and care_partner_demo_orgs.sql seeded nine
-- invented partners so the Care Partner UI could be reviewed against
-- something that felt real. They are in the LIVE database, and one of
-- them is reachable from the public internet right now:
--
--     parentveda.in/care/MK8UQT96NH   ->  "Dr Meera Rao"
--
-- A fictional doctor on a pregnancy product's live domain is a
-- credibility problem, not a tidiness one. `demo_badlabel` is worse: it
-- carries trust.primary = "Sponsored by", the exact wording the CHECK
-- constraint on care_trust_messages exists to forbid.
--
-- THIS FILE IS DESTRUCTIVE AND IS NOT A MIGRATION. It lives in seed/
-- next to the files that created these rows, and is meant to be run by
-- hand, once, deliberately -- read section 1 before running section 2.
--
-- Re-creating them later is `psql -f care_partner_demo.sql` and the
-- orgs file. Nothing here is unrecoverable; the tokens will differ.
-- =====================================================================


-- ---------------------------------------------------------------------
-- 1. LOOK FIRST. Run this on its own and read the output.
--
-- If `attributions` is anything other than 0 for a partner, a REAL
-- family has been attributed to a fictional doctor -- almost certainly
-- from testing, but confirm it before deleting, because
-- partner_attributions is what decides who introduced whom, and
-- attribution history is meant to survive even deactivation.
-- ---------------------------------------------------------------------
select p.id,
       p.name,
       p.status,
       (select count(*) from public.partner_referrals    r where r.partner_id = p.id) as tokens,
       (select count(*) from public.partner_attributions a where a.partner_id = p.id) as attributions,
       (select count(*) from public.commission_ledger    l where l.partner_id = p.id) as ledger_rows
  from public.care_partners p
 where p.id like 'demo\_%'
 order by p.id;


-- ---------------------------------------------------------------------
-- 2. THEN DELETE. Children first -- care_partners is referenced by
--    partner_referrals and partner_attributions, so the order matters.
--
--    If step 1 showed ledger rows, STOP: commission_ledger is
--    deliberately immutable and append-only (0037), and this script
--    does not touch it. Work out where real money got attached to a
--    fake partner before removing the partner it points at.
-- ---------------------------------------------------------------------
begin;

delete from public.partner_attributions where partner_id like 'demo\_%';
delete from public.partner_referrals    where partner_id like 'demo\_%';
delete from public.care_partners        where id         like 'demo\_%';

-- Expect 0 rows. Anything else means a prefix was missed.
select count(*) as remaining_demo_partners
  from public.care_partners where id like 'demo\_%';

commit;


-- ---------------------------------------------------------------------
-- 3. AFTERWARDS
--
-- parentveda.in/care/MK8UQT96NH stops resolving to a partner. It does
-- NOT 404 -- src/app/care/[token]/page.tsx deliberately falls back to a
-- generic "You've been invited to ParentVeda" page for any unknown
-- token, so a stale printed QR degrades gracefully instead of breaking.
-- That is the intended behaviour; no website change is needed.
--
-- Once real partners exist, they are created through the panel calling
-- create_care_partner() + mint_partner_token() (0040) -- never by
-- editing rows, and never by a second token-minting path.
-- =====================================================================
