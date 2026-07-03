-- =====================================================================
-- 0013_storage_media.sql — access rules for the private "media" bucket
-- ---------------------------------------------------------------------
-- PREREQ: create a PRIVATE bucket named "media" in the dashboard first
--   (Storage -> New bucket -> name: media -> "Public bucket" OFF -> Save).
--
-- Files are foldered per user + type:  media/<uid>/journal/<file>.jpg
-- Each user may read/write/delete only files inside THEIR OWN folder
-- (the first path segment must equal their user id). Partner-read (for the
-- father's photos in the mother's merged journal) is a later, separate
-- policy — kept out of this one on purpose.
-- =====================================================================

create policy "media own read"
  on storage.objects for select to authenticated
  using (bucket_id = 'media' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "media own insert"
  on storage.objects for insert to authenticated
  with check (bucket_id = 'media' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "media own update"
  on storage.objects for update to authenticated
  using (bucket_id = 'media' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "media own delete"
  on storage.objects for delete to authenticated
  using (bucket_id = 'media' and (storage.foldername(name))[1] = auth.uid()::text);
