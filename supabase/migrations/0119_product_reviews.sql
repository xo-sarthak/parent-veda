-- =============================================================================
--  0119 · Parents' own reviews of a product (store Track A, 2026-10-28)
-- -----------------------------------------------------------------------------
--  The launch store is affiliate only: she buys on Amazon, Flipkart or a
--  brand's site, never here. Two kinds of review appear on a product page:
--
--    · THE RETAILER'S — star rating and count only, read by affiliate-refresh
--      (0108) from Amazon's API. Their review TEXT is never copied: it is not
--      in the API, and copying it breaks the Associates agreement.
--    · OURS — this table. After "Buy on Amazon" the app asks "Did you buy
--      it?"; a yes lets her rate it and say a few words.
--
--  ⚠️ NOT A "VERIFIED PURCHASE". We cannot see an order placed on Amazon, so
--  the app labels these "Bought on Amazon, says the parent". `verified` stays
--  false from the phone; only a sold-here order (Track B) may set it, and
--  only through the server.
--
--  ⚠️ MODERATED BEFORE ANYONE ELSE SEES IT. A row starts `pending`. She sees
--  her own at once; other people see it once someone sets `approved` (the
--  Supabase dashboard today, a Directus queue later). The phone can never
--  approve its own review: a trigger forces `pending` and `verified = false`
--  on every insert and every edit that does not come from the service role,
--  so editing an approved review sends it back for a fresh check. A policy
--  `with check` alone could not do this, because it can only refuse, and
--  a refused write from a fire-and-forget client is a review silently lost.
--
--  One review per person per product (the unique key). The id is minted by
--  the app, so the local copy and the cloud row are one identity and a
--  resend is an idempotent upsert.
--
--  Runs after 0108.
-- =============================================================================

create table if not exists public.product_reviews (
  id                text primary key,
  user_id           uuid not null default auth.uid()
                      references auth.users (id) on delete cascade,
  product_id        text not null,
  rating            smallint not null check (rating between 1 and 5),
  body              text not null default ''
                      check (char_length(body) <= 2000),
  -- Where she says she bought it ('Amazon', 'Flipkart', 'FirstCry' ...).
  bought_at         text not null default '',
  -- How the page names her: her first name, or '' for "A ParentVeda parent".
  author_label      text not null default ''
                      check (char_length(author_label) <= 40),
  verified          boolean not null default false,
  moderation_status text not null default 'pending'
                      check (moderation_status in ('pending', 'approved', 'rejected')),
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  unique (user_id, product_id)
);

create index if not exists product_reviews_product_idx
  on public.product_reviews (product_id)
  where moderation_status = 'approved';

-- The phone cannot approve or verify. See the header.
create or replace function public.product_reviews_guard()
returns trigger
language plpgsql
as $$
begin
  if coalesce(auth.role(), '') <> 'service_role' then
    new.moderation_status := 'pending';
    new.verified := false;
    if tg_op = 'UPDATE' then
      new.user_id := old.user_id;
      new.created_at := old.created_at;
    end if;
  end if;
  new.updated_at := now();
  return new;
end;
$$;

drop trigger if exists product_reviews_guard on public.product_reviews;
create trigger product_reviews_guard
  before insert or update on public.product_reviews
  for each row execute function public.product_reviews_guard();

alter table public.product_reviews enable row level security;

-- Read: your own (any status), and everyone's approved ones.
drop policy if exists product_reviews_select on public.product_reviews;
create policy product_reviews_select on public.product_reviews
  for select using (
    user_id = auth.uid() or moderation_status = 'approved'
  );

drop policy if exists product_reviews_insert on public.product_reviews;
create policy product_reviews_insert on public.product_reviews
  for insert with check (user_id = auth.uid());

drop policy if exists product_reviews_update on public.product_reviews;
create policy product_reviews_update on public.product_reviews
  for update using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists product_reviews_delete on public.product_reviews;
create policy product_reviews_delete on public.product_reviews
  for delete using (user_id = auth.uid());
