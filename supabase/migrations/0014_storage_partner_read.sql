-- =====================================================================
-- 0014_storage_partner_read.sql — let a paired partner READ each other's
--   media files, so the mother's merged journal shows the father's PHOTOS
--   (not just his text) and any shared media resolves. SELECT only —
--   writes stay own-folder (from 0013).
-- Needs public.my_partner_id (0009) + the media bucket policies (0013).
-- =====================================================================

create policy "media partner read"
  on storage.objects for select to authenticated
  using (
    bucket_id = 'media'
    and (storage.foldername(name))[1] = (public.my_partner_id())::text
  );
