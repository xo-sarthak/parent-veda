-- =====================================================================
-- 0090_expert_photo.sql — a doctor puts her own face on her profile
-- ---------------------------------------------------------------------
-- The set-up rail said "Add your photo · send one to partners@parentveda.com"
-- and the user's answer (2026-09-21) was the right one: apps let you add an
-- image. Two things stood in the way, and this file removes exactly those
-- two and nothing more.
--
--   1. expert_profiles has NO client write policy (0072), deliberately: a
--      row there sets a price and a name in front of a pregnant woman, and
--      that stays an editorial act in the panel. So the photo does not get a
--      policy — it gets ONE function that updates ONE column, for the
--      caller's own expert rows. A policy would open the row; a function
--      opens a column. That is the general shape whenever a user owns one
--      field of a record that someone else owns the rest of.
--
--   2. The "media" bucket (0013) is private and foldered per user, which is
--      right for a journal and wrong for a face that parents must see before
--      they sign in. So: a PUBLIC bucket, "expert-photos", where anyone can
--      read and only the uploader can write inside their own folder — the
--      same folder rule as media, the opposite read rule.
--
-- PREREQ (dashboard, once): Storage -> New bucket -> name: expert-photos ->
-- "Public bucket" ON -> Save. Buckets are not created by SQL here because
-- the other bucket was not either (0013); one convention.
--
-- The app writes <uid>/<expert_id>.jpg with upsert, so a new photo REPLACES
-- the old at the same URL. The trade-off: a CDN may serve the old bytes for
-- a while after a change. The app appends ?v=<epoch> to the stored URL, so
-- the URL changes when the picture does and no cache is asked to forget.
-- =====================================================================

-- ---------------------------------------------------------------------
-- The bucket's rules.
-- ---------------------------------------------------------------------
drop policy if exists "expert-photos public read" on storage.objects;
create policy "expert-photos public read"
  on storage.objects for select to anon, authenticated
  using (bucket_id = 'expert-photos');

drop policy if exists "expert-photos own insert" on storage.objects;
create policy "expert-photos own insert"
  on storage.objects for insert to authenticated
  with check (bucket_id = 'expert-photos' and (storage.foldername(name))[1] = auth.uid()::text);

drop policy if exists "expert-photos own update" on storage.objects;
create policy "expert-photos own update"
  on storage.objects for update to authenticated
  using (bucket_id = 'expert-photos' and (storage.foldername(name))[1] = auth.uid()::text);

drop policy if exists "expert-photos own delete" on storage.objects;
create policy "expert-photos own delete"
  on storage.objects for delete to authenticated
  using (bucket_id = 'expert-photos' and (storage.foldername(name))[1] = auth.uid()::text);


-- ---------------------------------------------------------------------
-- The one column the doctor owns.
-- ---------------------------------------------------------------------
-- SECURITY DEFINER, because the caller has no update right on the table
-- and must not gain one. The function checks the identity gate itself
-- (my_expert_ids, 0073) so an organisation login can set a photo for any of
-- its clinicians and a solo doctor only for herself. The url must sit in
-- our own bucket: a function that accepts any string would let a profile
-- point at any image on the internet, which is a different product.
create or replace function public.set_my_expert_photo(p_expert_id text, p_url text)
returns void
language plpgsql security definer set search_path = ''
as $$
begin
  if p_expert_id is null or p_expert_id not in (select public.my_expert_ids()) then
    raise exception 'not your expert' using errcode = '42501';
  end if;
  if p_url is not null and position('/storage/v1/object/public/expert-photos/' in p_url) = 0 then
    raise exception 'photo must live in the expert-photos bucket' using errcode = '22023';
  end if;
  update public.expert_profiles
     set photo_url = p_url
   where expert_id = p_expert_id;
  if not found then
    raise exception 'no profile for %', p_expert_id using errcode = 'P0002';
  end if;
end;
$$;

revoke all on function public.set_my_expert_photo(text, text) from public;
grant execute on function public.set_my_expert_photo(text, text) to authenticated;

comment on function public.set_my_expert_photo(text, text) is
  'The doctor sets her own photo_url — the ONE column of expert_profiles a client may write. Null clears it. Everything else on the row stays the panel''s.';
