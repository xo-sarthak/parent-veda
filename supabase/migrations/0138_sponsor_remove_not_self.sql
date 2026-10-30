-- =====================================================================
-- 0138_sponsor_remove_not_self.sql -- an admin cannot remove themselves.
-- ---------------------------------------------------------------------
-- P2 of the Partners app (docs/partner-editions/PARTNERS-APP.md) puts a
-- Remove action on every active person in the roster. One of those
-- people can be the admin: an HR lead who is also expecting, and who
-- activated the benefit for herself.
--
-- sponsor_remove_member (0060) resolves the person by WORK EMAIL and
-- then removes them. It never asked whether that person is the caller.
-- Two different things happen when they are:
--
--   * A seatless admin (sponsor_admins, 0136) loses her own Premium but
--     keeps the admin role. Surprising, and not what she meant.
--   * A legacy admin (the 0060 rule: an active member holding the
--     capability) loses the membership the role is DERIVED from, so
--     my_sponsor_admin_id() returns null on her next call and she is
--     locked out of the screen she was standing in. Nobody at the
--     company can let her back in; only ParentVeda can.
--
-- The app refuses this too, by comparing the row's email with the
-- signed-in email. That check is a courtesy, not the guard: a work
-- email and a login email are often different addresses for the same
-- person, and only the server knows that both rows carry one user id.
-- So the rule is enforced here, on the uid, and the app's check only
-- saves a round trip in the common case.
--
-- > The general rule: a client check is UX, a server check is policy.
-- > Write the server one first and treat the client one as a hint.
--
-- Refuses rather than raising, with an audit row, as every gate since
-- 0055 does.
--
-- PREREQ: 0055 (_refuse), 0058 (remove_sponsor_member),
--         0136 (my_sponsor_admin_id reads sponsor_admins first).
-- =====================================================================

create or replace function public.sponsor_remove_member(p_work_email text)
returns jsonb
language plpgsql security definer set search_path = ''
as $$
declare
  v_id    text := public.my_sponsor_admin_id();
  v_email text := lower(trim(p_work_email));
  v_uid   uuid;
begin
  if v_id is null then
    return public._refuse(coalesce(auth.uid()::text, 'anonymous'),
      'sponsor_remove_member', 'sponsor_members', null,
      'not_a_sponsor_admin', 'You do not administer a programme.');
  end if;

  select user_id into v_uid from public.sponsor_members
   where sponsor_id = v_id and lower(work_email) = v_email and status = 'active';

  if v_uid is null then
    return public._refuse(auth.uid()::text, 'sponsor_remove_member',
      'sponsor_members', v_id, 'not_a_member',
      'That person is not an active member.');
  end if;

  -- (0138) Never the caller, whichever email they activated under.
  if v_uid = auth.uid() then
    return public._refuse(auth.uid()::text, 'sponsor_remove_member',
      'sponsor_members', v_id, 'cannot_remove_self',
      'You cannot remove yourself. Ask your ParentVeda manager.');
  end if;

  return public.remove_sponsor_member(v_id, v_uid, auth.uid()::text);
end;
$$;

grant execute on function public.sponsor_remove_member(text) to authenticated;


-- =====================================================================
-- VERIFY: run supabase/seed/verify_remove_self.sql. The lines below need
-- a signed-in admin; pasted into the SQL editor (no user) they all answer
-- not_a_sponsor_admin, which is correct and proves nothing.
--
--   -- Removing your own work email is refused and audited:
--   select public.sponsor_remove_member('<your-work-email>');
--     -> {"ok": false, "code": "cannot_remove_self", ...}
--
--   -- Anybody else behaves exactly as before:
--   select public.sponsor_remove_member('nobody@nowhere.test');
--     -> {"ok": false, "code": "not_a_member", ...}
-- =====================================================================
