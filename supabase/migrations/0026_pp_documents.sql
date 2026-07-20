-- =====================================================================
-- 0026_pp_documents.sql — the child's document wallet
-- ---------------------------------------------------------------------
-- BabyDocumentsStore (pp_documents_data.dart): birth certificate,
-- Aadhaar, hospital discharge, insurance, records. CHILD-SCOPED +
-- CO-PARENTED — either parent needs these at a hospital desk, and the
-- one holding the phone is whoever happens to be there.
--
-- THIS IS THE HIGHEST-CONSEQUENCE TABLE IN THE PARENTING SET, and the
-- reason is flag #5 rather than anything in the schema. `attachments`
-- holds [{kind,path,name}] exactly as the app serializes it, and today
-- `path` is an image_picker / file_picker TEMP path. The OS reaps those
-- directories on its own schedule, so a photographed birth certificate
-- is already rotting on-device — this is losing data NOW, independent
-- of any backend.
--
-- Persisting the row is only half the fix. The bytes must go to
-- Supabase Storage (the private `media` bucket, 0013/0014, via
-- lib/services/remote/storage_service.dart) and `path` must hold the
-- returned STORAGE OBJECT PATH instead of a device path. StorageService
-- already handles that shape — upload() returns the object path,
-- resolve() downloads and caches it, and the partner-read policy from
-- 0014 means the other parent's files resolve with no extra work.
-- Nothing on the parenting side calls it yet. Until it does, a synced
-- document row will restore its TITLE and CATEGORY but its attachment
-- path will point at a file that no longer exists on that device.
--
-- No new bucket is needed: `media` and its policies already exist.
-- Foldering convention for these: media/<uid>/documents/<file>.
--
-- PREREQ: 0021_children.sql. Run AFTER 0021.
-- =====================================================================

create table public.pp_documents (
  id          text        primary key,
  child_id    text        not null,
  user_id     uuid        not null references auth.users (id) on delete cascade,

  title       text        not null default '',
  category    text        not null default '',   -- one of kBabyDocCategories
  date        text        not null default '',   -- display string, e.g. "18 Mar 2026"
  notes       text        not null default '',
  attachments jsonb       not null default '[]'::jsonb,

  created_at  timestamptz not null default now()
);

create index pp_documents_child_idx on public.pp_documents (child_id);

grant select, insert, update, delete on public.pp_documents to authenticated;
alter table public.pp_documents enable row level security;

create policy "pp_documents child select" on public.pp_documents for select
  using (child_id in (select public.my_child_ids()));
create policy "pp_documents child insert" on public.pp_documents for insert
  with check (child_id in (select public.my_child_ids()) and auth.uid() = user_id);
create policy "pp_documents child update" on public.pp_documents for update
  using (child_id in (select public.my_child_ids()));
create policy "pp_documents child delete" on public.pp_documents for delete
  using (child_id in (select public.my_child_ids()));
