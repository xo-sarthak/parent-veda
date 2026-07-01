-- =====================================================================
-- 0007_calendar_reminders.sql — personal calendar events + reminders
-- Run AFTER 0001.
-- =====================================================================

-- ---- calendar_personal_events  (CalendarStore; only 4 fields persisted) ----
create table public.calendar_personal_events (
  id          text        primary key,
  user_id     uuid        not null references auth.users (id) on delete cascade,
  title       text        not null default '',
  description text        not null default '',
  date        timestamptz,
  created_at  timestamptz not null default now()
);
grant select, insert, update, delete on public.calendar_personal_events to authenticated;
alter table public.calendar_personal_events enable row level security;
create policy "calendar_personal_events own select" on public.calendar_personal_events for select using (auth.uid() = user_id);
create policy "calendar_personal_events own insert" on public.calendar_personal_events for insert with check (auth.uid() = user_id);
create policy "calendar_personal_events own update" on public.calendar_personal_events for update using (auth.uid() = user_id);
create policy "calendar_personal_events own delete" on public.calendar_personal_events for delete using (auth.uid() = user_id);


-- ---- reminders  (ReminderStore / models/reminder.dart) ----
create table public.reminders (
  id            text        primary key,
  user_id       uuid        not null references auth.users (id) on delete cascade,
  title         text        not null default '',
  body          text        not null default '',
  hour          int         not null default 0,
  minute        int         not null default 0,
  repeat        text        not null default 'daily'
                              check (repeat in ('once','daily','weekly','fortnightly','monthly','customDays')),
  weekday       int         not null default 1,   -- 1=Mon .. 7=Sun
  enabled       boolean     not null default true,
  category      text        not null default 'custom',  -- kegel|medication|reads|bag|water|custom (open)
  times         jsonb       not null default '[]'::jsonb,   -- extra times (minutes since midnight)
  day_of_month  int         not null default 1,
  weekdays      jsonb       not null default '[]'::jsonb,   -- for customDays
  created_at    timestamptz not null default now()
);
grant select, insert, update, delete on public.reminders to authenticated;
alter table public.reminders enable row level security;
create policy "reminders own select" on public.reminders for select using (auth.uid() = user_id);
create policy "reminders own insert" on public.reminders for insert with check (auth.uid() = user_id);
create policy "reminders own update" on public.reminders for update using (auth.uid() = user_id);
create policy "reminders own delete" on public.reminders for delete using (auth.uid() = user_id);
