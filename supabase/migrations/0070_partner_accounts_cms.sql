-- =====================================================================
-- 0070_partner_accounts_cms.sql -- let the panel attach a login to a
-- partner
-- ---------------------------------------------------------------------
-- partner_accounts (0068) is what turns a care_partners row into
-- something a human can sign in as. Without a row here a hospital has an
-- identity, a token and a poster, and no way to open the app and see any
-- of it.
--
-- It shipped with NO write policy at all, deliberately: a client that
-- could insert there would attach itself to any partner and read that
-- partner's numbers. But that closed the door on Directus too, and
-- Directus is precisely who should be doing this — attaching a login is
-- an editorial act, the same class as verification.
--
-- BOTH HALVES ARE REQUIRED, and this is the bit worth remembering: a
-- GRANT gets directus_cms past the privilege check, and the RLS POLICY
-- decides whether it sees a row. With RLS on and no policy for this role,
-- a grant alone yields a collection that lists nothing and inserts
-- nothing, with no error that explains why. Follows 0045 §4 and 0050.
--
-- Deliberately NOT granted: partner_attributions and parent_timeline.
-- They carry which mother came from which partner, and her pregnancy,
-- her child, her vaccinations, what she read. The Care Partner module
-- rests on a partner never seeing a family row; that is enforced in SQL
-- and holds. Directus staff are not partners — but a mother's timeline
-- becoming casually browsable by anyone with a panel login should be a
-- decision somebody makes on purpose, not a side effect of registering a
-- collection. Verified 2026-07-30: directus_cms has no grant on either.
--
-- PREREQ: 0045 (the role), 0068 (the table).
-- =====================================================================

grant select, insert, update, delete on public.partner_accounts to directus_cms;

drop policy if exists "partner_accounts cms write" on public.partner_accounts;
create policy "partner_accounts cms write" on public.partner_accounts
  for all to directus_cms using (true) with check (true);

-- The app's own policy is untouched: a signed-in partner still reads only
-- their own mapping, and still cannot write one.


-- ---------------------------------------------------------------------
-- The four functions the panel needs a form over.
--
-- Granted to directus_cms so a Directus Flow can call them, rather than
-- the panel writing rows by hand. The difference matters:
--
--   create_care_partner()   also mints the first token, so a partner can
--                           never exist without a code — forgetting that
--                           second step WAS the original defect.
--   rotate_partner_token()  retires with a grace window and demands a
--                           reason. A hand-written update would skip both
--                           and kill every printed poster instantly.
--
-- link_partner_account is included so the panel can attach a login the
-- safe way; the table grant above is the fallback for editing by hand.
-- ---------------------------------------------------------------------
-- Granted by LOOKING THE SIGNATURE UP, not by writing it out.
--
-- Hardcoding `create_care_partner(text, text, text, text, text, text, text,
-- text)` failed on a live database with "function does not exist" while the
-- function was plainly there — the deployed signature had drifted from the
-- one in 0040, and a GRANT names a function by its exact argument types.
--
-- The failure mode is the reason this is worth the extra lines: the error
-- says "does not exist", which reads as "the migration was never run" and
-- sends you looking in entirely the wrong place. Granting whatever signature
-- IS there cannot drift, and keeps working if someone later adds a default
-- parameter.
do $$
declare r record;
begin
  for r in
    select p.oid::regprocedure as sig
      from pg_proc p
      join pg_namespace n on n.oid = p.pronamespace
     where n.nspname = 'public'
       and p.proname in ('create_care_partner',
                         'mint_partner_token',
                         'link_partner_account',
                         'rotate_partner_token',
                         'partner_token_history')
  loop
    execute format('grant execute on function %s to directus_cms', r.sig);
  end loop;
end $$;
