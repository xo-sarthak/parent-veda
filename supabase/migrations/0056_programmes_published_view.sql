-- =====================================================================
-- 0056_programmes_published_view.sql -- one flat row per sellable
--                                       programme, for the app to read.
-- ---------------------------------------------------------------------
-- WHY A VIEW AND NOT A CLIENT-SIDE JOIN
--
-- Every other content type the app reads is one table, one fetch:
-- `select * from recipes where status='published'`. Programmes broke
-- that shape for one reason -- **who teaches this is not a fact about
-- the programme.** It is the outcome of a process:
--
--     invite three experts -> two decline -> one accepts
--
-- So the answer lives in programme_experts, and rendering a single card
-- needs a second question ("of everyone invited, who accepted?").
--
-- That join could go in the app. It should not:
--
--   * it would be the only content type with a bespoke fetch, so the
--     generic engine stops being generic for one special case;
--   * the rule "the host is the FIRST expert who accepted" would then
--     live in Dart, where the website and any future surface cannot see
--     it -- and two places deciding who is hosting is how two screens
--     end up naming different doctors;
--   * a client-side join means two round trips, or one over-fetch, on a
--     screen a parent opens while deciding whether to spend money.
--
-- A view puts the rule where the data is. The app keeps reading one flat
-- thing; if "who hosts" ever gains nuance -- co-hosts, a replacement
-- after someone withdraws -- it changes here, once.
--
-- SECURITY NOTE. This view is created WITHOUT security_invoker, so it
-- runs with the definer's rights and can read programme_experts (which
-- has no public read policy -- an expert sees only their own
-- invitations). That is deliberate and safe because the view exposes
-- ONLY the accepted host's id on an already-published programme, which
-- is public information the moment the programme is on sale. It exposes
-- nothing about who declined, who was invited, or what anyone said --
-- and it filters to status='published' itself, so an unpublished
-- programme cannot leak through it.
--
-- PREREQ: 0054.
-- =====================================================================

create or replace view public.programmes_published as
select
  p.id,
  p.status,
  p.kind,
  p.stage,
  p.title,
  p.title_hi,
  p.subtitle,
  p.summary,
  p.summary_hi,
  p.body,
  p.body_hi,
  p.hero_image,
  p.trailer_url,
  p.price_paise,
  p.compare_at_paise,
  p.currency,
  p.capacity,
  p.certificate_enabled,
  p.published_at,
  p.updated_at,

  -- The host: the first expert who ACCEPTED. Invited is not accepted --
  -- publish_programme already refuses without one, so a published
  -- programme always has exactly this.
  (select pe.expert_id
     from public.programme_experts pe
    where pe.programme_id = p.id and pe.status = 'accepted'
    order by pe.invited_at
    limit 1) as expert_id,

  -- Session facts the card shows without opening the programme.
  (select count(*) from public.programme_sessions s
    where s.programme_id = p.id) as session_count,
  (select min(s.starts_utc) from public.programme_sessions s
    where s.programme_id = p.id) as first_session_utc,
  (select max(s.starts_utc) from public.programme_sessions s
    where s.programme_id = p.id) as last_session_utc,

  -- Seats: reads the ONE authority (booking_slots, 0029), never a
  -- second counter. Null when capacity is unset = unlimited.
  (select sum(greatest(b.capacity - b.booked, 0))
     from public.booking_slots b
    where b.offering_id = p.id) as seats_left

from public.programmes p
where p.status = 'published';

comment on view public.programmes_published is
  'One flat row per sellable programme, with the accepted host resolved. The app reads THIS, not the programmes table - "who hosts" is a rule, and it belongs next to the data rather than in each client.';

grant select on public.programmes_published to anon, authenticated;

-- The CMS edits the underlying tables, not this. Granting it would offer
-- an editor a read-only duplicate of data they already have, in a shape
-- that cannot be written back.


-- =====================================================================
-- VERIFY
--
--   select id, title, expert_id, session_count, first_session_utc, seats_left
--     from public.programmes_published;
--
--   -- an unpublished programme must not appear
--   update public.programmes set status = 'draft' where id = '<id>';
--   select count(*) from public.programmes_published where id = '<id>';  -- 0
-- =====================================================================
