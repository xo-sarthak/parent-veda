-- =============================================================================
--  0131 — ttc_logs: each partner may share their HABIT logs with the other
--  (T5 Q1, 2026-10-29; docs/preg-ttc-tool-plans/T5-body-checks.md)
-- -----------------------------------------------------------------------------
--  The product rule (Q1, the user, 2026-10-29): a couple trying together can
--  see each other's habits, "just to be having an accountability check". Body
--  and medical logs (symptoms, mood, weight, the PCOS check) stay private.
--  Each person decides for their OWN log, once, on a card after their first
--  save; "Share" is the first answer. Changeable in You.
--
--  1. `ttc_log_shares`: one row per (person, tracker), `shared` true or false.
--     Only two trackers can be shared, held by the check constraint, so a
--     client bug cannot share her symptoms by writing `tracker = 'symptoms'`.
--     Own row: read and write. Partner: read only, so his phone can say "She
--     shares her habits with you" or "She keeps hers to herself".
--
--  2. `ttc_log_is_shared(owner, tracker)`: security definer, so the ttc_logs
--     policy can read the owner's switch without the caller needing its own
--     grant on that row. The four tracker ids folded into `habits` on
--     2026-09-28 (`kTtcHabitMerge` in ttc_log_store.dart) still exist on older
--     cloud rows, so they map to `habits` here exactly as the app maps them.
--     No row means not shared: the default is private until someone says yes.
--
--  3. A second SELECT policy on ttc_logs. Postgres ORs permissive policies, so
--     the 0041 own-row `for all` policy is untouched and this only ADDS a read:
--     my partner's rows, for a shared tracker, while their switch is on. No
--     insert, update or delete is granted, so the view is read-only by rule,
--     not only by UI. Unpairing ends it with no extra code: my_partner_id()
--     returns null and `user_id = null` is never true.
--
--  ⚠️ WHY THIS DOES NOT LEAK INTO HER OWN STORE. TtcLogStore pulls with
--  `SupabaseRepo.fetch`, which pins `.eq('user_id', uid)` (supabase_repo.dart
--  :65). RLS widening what she MAY read changes nothing about what that query
--  asks for. The partner view reads through `fetchByUser` with his id instead.
--  If the store ever moved to `fetchShared`, his rows would merge into hers and
--  push back under her id; test/ttc_t5_body_checks_test.dart pins the call.
--
--  ORDER: run this BEFORE installing the T5 build. Without it the share answer
--  upsert is refused (no table) and the partner view reads nothing. Nothing is
--  lost on the phone, but the switch would not reach the other person.
--
--  Untouched: the 0100 newer-wins trigger, the 0109/0110 purge, the ttc_logs
--  key (user_id, tracker, field, logged_on).
--
--  Safe to re-run: `if not exists`, `create or replace`, `drop policy if
--  exists` first.
-- =============================================================================

create table if not exists public.ttc_log_shares (
  user_id     uuid not null references auth.users (id) on delete cascade,
  tracker     text not null check (tracker in ('partner_health', 'habits')),
  shared      boolean not null,
  updated_at  timestamptz not null default now(),
  primary key (user_id, tracker)
);

alter table public.ttc_log_shares enable row level security;

drop policy if exists ttc_log_shares_own on public.ttc_log_shares;
create policy ttc_log_shares_own on public.ttc_log_shares
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists ttc_log_shares_partner_read on public.ttc_log_shares;
create policy ttc_log_shares_partner_read on public.ttc_log_shares
  for select using (user_id = public.my_partner_id());

create or replace function public.ttc_log_is_shared(p_owner uuid, p_tracker text)
returns boolean
language sql
stable
security definer set search_path = ''
as $$
  select coalesce(
    (select s.shared
       from public.ttc_log_shares s
      where s.user_id = p_owner
        and s.tracker = case
              when p_tracker in ('sleep', 'exercise', 'stress', 'lifestyle')
                then 'habits'
              else p_tracker
            end),
    false);
$$;

revoke all on function public.ttc_log_is_shared(uuid, text) from public, anon;
grant execute on function public.ttc_log_is_shared(uuid, text) to authenticated;

drop policy if exists ttc_logs_partner_read on public.ttc_logs;
create policy ttc_logs_partner_read on public.ttc_logs
  for select using (
    user_id = public.my_partner_id()
    and public.ttc_log_is_shared(user_id, tracker)
  );

-- -----------------------------------------------------------------------------
--  Check after running (as a signed-in partner, in the SQL editor's role
--  switcher, or simply on the two phones):
--    select tracker, shared from public.ttc_log_shares;          -- own + partner's
--    select count(*) from public.ttc_logs where user_id <> auth.uid();
--      -- 0 until the partner switches sharing on; then only habit rows
-- -----------------------------------------------------------------------------
