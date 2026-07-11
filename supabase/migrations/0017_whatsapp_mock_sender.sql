-- =====================================================================
-- 0017_whatsapp_mock_sender.sql — WhatsApp notifications: the mock sender/drainer (B4)
-- The other half of the outbox: reads 'queued' rows from wa_message_log and
-- "delivers" them WITHOUT touching the network — it just marks them 'mock'.
-- This proves the enqueue -> drain -> mark flow end-to-end, for free, before
-- the real MSG91 Edge Function (B6) exists.
-- Adds: wa_render() (fills {{1}},{{2}} for readable previews), a preview view,
-- and wa_send_mock() (the drainer). Run AFTER 0016. Safe to run once.
-- =====================================================================


-- 1) wa_render — fill a template's {{1}},{{2}},... from a variables object ----
--    Template body has positional placeholders ({{1}}...) and an ordered
--    variable-name list (["name","week"]); the log row carries the values
--    ({"name":"Priya","week":20}). This maps position -> name -> value.
--    NOTE: this rendering is only for OUR preview/mock. The real MSG91 send
--    passes template_name + the variable VALUES, and Meta renders the body.
create or replace function public.wa_render(p_template text, p_vars jsonb)
returns text
language plpgsql
stable
as $$
declare
  tmpl_body text;
  tmpl_vars jsonb;
  out_text  text;
  i         int;
  var_name  text;
  var_val   text;
begin
  select body, variables into tmpl_body, tmpl_vars
  from public.wa_message_templates
  where name = p_template;

  if not found then
    return null;
  end if;

  out_text := tmpl_body;
  for i in 0 .. jsonb_array_length(tmpl_vars) - 1 loop
    var_name := tmpl_vars ->> i;                        -- position i -> variable name
    var_val  := coalesce(p_vars ->> var_name, '');      -- variable name -> value
    out_text := replace(out_text, '{{' || (i + 1) || '}}', var_val);
  end loop;

  return out_text;
end;
$$;

grant execute on function public.wa_render(text, jsonb) to authenticated, service_role;


-- 2) wa_message_preview — a human-readable window on the outbox ---------------
--    Joins each log row to the recipient's phone/name and renders the message,
--    so you can literally SEE what would go out. Internal/admin use.
create or replace view public.wa_message_preview as
select
  l.id,
  l.created_at,
  l.status,
  l.category,
  l.language,
  p.phone,
  p.name,
  l.template_name,
  public.wa_render(l.template_name, l.variables) as rendered,
  l.provider,
  l.dedupe_key
from public.wa_message_log l
join public.profiles p on p.id = l.user_id
order by l.created_at desc;

grant select on public.wa_message_preview to service_role;


-- 3) wa_send_mock — the drainer (mock) ---------------------------------------
--    Takes every 'queued' row and marks it 'mock' (nothing leaves the DB).
--    Mirrors what the REAL sender (B6) will do, except B6 sets 'sent' after a
--    successful MSG91 call. Returns how many it drained.
create or replace function public.wa_send_mock()
returns int
language plpgsql
security definer set search_path = ''
as $$
declare
  n int := 0;
begin
  update public.wa_message_log
     set status              = 'mock',
         provider            = 'mock',
         provider_message_id = 'mock-' || id::text,
         sent_at             = now(),
         updated_at          = now()
   where status = 'queued';

  get diagnostics n = row_count;
  return n;
end;
$$;

grant execute on function public.wa_send_mock() to service_role;


-- =====================================================================
-- HOW TO TEST  (run by hand in the SQL Editor — watch the full flow)
-- =====================================================================
-- Prereq: you have at least one 'queued' row from the 0016 test.
--   (If not: re-run  select public.wa_enqueue_weekly_guide(date '2026-07-10');)
--
-- 1) See what is waiting to go out, rendered:
--    select phone, status, rendered from public.wa_message_preview;
--    -- e.g. +91999... | queued | Hi Your Name, you are now in week 20 of your pregnancy. - ParentVeda
--
-- 2) Drain the queue (mock "send"):
--    select public.wa_send_mock();          -- returns e.g. 1
--
-- 3) Same message, now delivered (mock):
--    select phone, status, provider, rendered from public.wa_message_preview;
--    -- +91999... | mock | mock | Hi Your Name, you are now in week 20 ...
--
-- 4) Run the drainer again -> 0 (nothing left queued; no re-send):
--    select public.wa_send_mock();          -- returns 0
--
-- To replay the loop, put a row back:  update public.wa_message_log set status='queued' where status='mock';
-- =====================================================================
