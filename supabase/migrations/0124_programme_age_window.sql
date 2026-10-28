-- =====================================================================
-- 0124_programme_age_window.sql -- the child's ages a programme is for.
-- ---------------------------------------------------------------------
-- Relevance PP 8 (2026-10-28). More's "Courses and masterclasses" and the
-- reader's one offer chose by catalogue order and topic words, never by
-- the child: "The First 40 Days" showed to the mother of a 3-year-old.
-- The app now ranks programmes that fit the child first (never hides
-- one) and offers none outside the child's ages.
--
-- WHY TWO NULLABLE INTEGERS, NOT A BAND NAME
--   * Months are what every age rule in the app counts in (corrected age
--     under 24 months, birthday age after). A band name ('0-3 mo') would
--     have to be parsed back into months on every device.
--   * NULL means "every age", the right default for a programme nobody
--     has placed yet, and for one that genuinely suits all ages. A
--     programme is never hidden for want of a number.
--   * Both ends included: 3 to 6 fits a child of 3 and of 6 months.
--
-- WHY THE APP'S BUNDLED COPIES ARE FILLED IN HERE TOO
--   A published programme WINS over a bundled one with the same id
--   (mergedLearningPrograms). Without these updates a published copy of
--   "The First 40 Days" would lose the window its bundled copy has.
--   Only rows still empty are touched, so an editor's choice stands.
--
-- Directus is not set up yet (the user, 2026-10-28). When it is, show
-- these two fields on the programmes collection. Nothing else changes.
--
-- PREREQ: 0054 (programmes), 0056 (the view). Safe to re-run.
-- =====================================================================

alter table public.programmes
  add column if not exists age_from_months integer,
  add column if not exists age_to_months   integer;

alter table public.programmes drop constraint if exists programmes_age_window_ok;
alter table public.programmes add constraint programmes_age_window_ok check (
  (age_from_months is null or age_from_months >= 0) and
  (age_to_months is null or age_to_months >= 0) and
  (age_from_months is null or age_to_months is null or age_to_months >= age_from_months)
);

comment on column public.programmes.age_from_months is
  'Youngest child age it is for, in months (included). NULL = no lower limit.';
comment on column public.programmes.age_to_months is
  'Oldest child age it is for, in months (included). NULL = no upper limit.';

-- The bundled programmes' windows (lib/screens/post_pregnancy/pp_learning_data.dart).
update public.programmes p
   set age_from_months = w.f, age_to_months = w.t
  from (values
    ('mc_sleepreg', 3, 6), ('co_sleep', 4, 24), ('co_weaning', 5, 12),
    ('co_calm', 0, 3), ('co_gentlenights', 4, 24), ('mc_solids', 5, 12),
    ('mc_wonderweeks', 0, 20), ('mc_babyproof', 5, 36), ('mc_first40', 0, 2),
    ('rc_playbrain', 3, 6), ('rc_motor', 2, 12), ('rc_language', 3, 12),
    ('rc_sleep', 3, 6)
  ) as w(id, f, t)
 where p.id = w.id and p.age_from_months is null and p.age_to_months is null;

-- The view, as 0056 wrote it, plus the two columns at the end.
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
    where b.offering_id = p.id) as seats_left,

  -- 0124: the child's ages it is for. Appended LAST: `create or replace
  -- view` may add columns only at the end, never reorder them.
  p.age_from_months,
  p.age_to_months

from public.programmes p
where p.status = 'published';

grant select on public.programmes_published to anon, authenticated;

-- =====================================================================
-- VERIFY
--
--   select column_name from information_schema.columns
--    where table_name = 'programmes_published'
--      and column_name in ('age_from_months', 'age_to_months');   -- 2 rows
--
--   update public.programmes set age_from_months = 6, age_to_months = 3
--    where id = '<id>';   -- must fail: programmes_age_window_ok
-- =====================================================================
