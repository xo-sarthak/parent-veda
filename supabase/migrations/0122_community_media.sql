-- 0122_community_media.sql — community photos, private until approved (2026-10-28)
--
-- Why a PRIVATE bucket when every other bucket here is public (0013, 0090):
-- a public bucket serves any object to anyone who has the URL, forever. A
-- community photo must be invisible until a moderator approves it, and must
-- disappear for everyone when it is rejected or the post is removed. So the
-- bucket is private, and the app asks for a short-lived SIGNED URL; Storage
-- only signs one when the select policy below says this person may see it.
-- The cost: a signed URL expires (we ask for an hour), so the app re-asks when
-- a feed refreshes. The gain: "approved" is enforced by the server, not by
-- the app deciding not to draw a picture it could still fetch.
--
-- ⚠️ THE PATH IS '<postId>/<random>.jpg', NOT '<uid>/…' as in 0013 and 0090.
-- Those buckets hold her own things; this one holds things shown under a
-- community name. A uid in the path would print who she is in every URL of
-- an anonymous post. Ownership is checked by looking the post up instead.

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('community-media', 'community-media', false, 5242880,
        array['image/jpeg', 'image/png', 'image/webp'])
on conflict (id) do update set
  public = false,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

-- May she write under this path? Only into a post that is hers.
create or replace function public.community_media_writable(p_name text)
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (select 1 from public.community_posts p
                  where p.id = split_part(p_name, '/', 1)
                    and p.user_id = auth.uid() and p.deleted_at is null)
$$;

-- May she see this object? Her own post's photos always; anyone's once
-- approved on a live post with no block between them; a moderator, all.
create or replace function public.community_media_readable(p_name text)
returns boolean language sql stable security definer set search_path = '' as $$
  select public.community_is_mod() or exists (
    select 1 from public.community_media m
      join public.community_posts p on p.id = m.post_id
     where m.path = p_name and p.deleted_at is null
       and (p.user_id = auth.uid()
            or (m.status = 'approved' and p.status = 'live'
                and not public.community_blocked_between(auth.uid(), p.user_id))))
$$;

revoke all on function public.community_media_writable(text), public.community_media_readable(text)
  from public, anon;
-- Policies run as the person asking, so she needs execute on the checks.
grant execute on function public.community_media_writable(text), public.community_media_readable(text)
  to authenticated;

drop policy if exists "community-media insert into own post" on storage.objects;
create policy "community-media insert into own post"
  on storage.objects for insert to authenticated
  with check (bucket_id = 'community-media' and public.community_media_writable(name));

drop policy if exists "community-media read when allowed" on storage.objects;
create policy "community-media read when allowed"
  on storage.objects for select to authenticated
  using (bucket_id = 'community-media' and public.community_media_readable(name));

drop policy if exists "community-media delete own" on storage.objects;
create policy "community-media delete own"
  on storage.objects for delete to authenticated
  using (bucket_id = 'community-media' and public.community_media_writable(name));
