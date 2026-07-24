-- =====================================================================
-- 0032_prescriptions.sql -- a doctor's prescription to a parent
-- ---------------------------------------------------------------------
-- After a consult the doctor writes a prescription (medicines + advice)
-- that appears in the parent's app, tied to the booking. The parent reads
-- their own; the hosting expert reads theirs. Writing goes through a
-- definer function so the doctor never needs to know the patient's user id
-- -- the function derives it from the booking, and authorises the caller
-- as the expert who hosts that slot.
--
-- PREREQ: 0029 (bookings/slots), 0030 (expert_accounts).
-- =====================================================================

create table public.prescriptions (
  id              text        primary key,
  booking_id      text        not null,
  expert_id       text        not null,
  patient_user_id uuid        not null references auth.users (id) on delete cascade,
  items           jsonb       not null default '[]',   -- [{medicine,dosage,duration,notes}]
  advice          text        not null default '',
  created_at      timestamptz not null default now()
);

create index prescriptions_patient_idx on public.prescriptions (patient_user_id);
create index prescriptions_booking_idx on public.prescriptions (booking_id);

grant select on public.prescriptions to authenticated;
alter table public.prescriptions enable row level security;

-- READ: the parent it is for, or the expert who hosts the consult.
create policy "prescriptions read" on public.prescriptions
  for select using (
    patient_user_id = auth.uid()
    or exists (
      select 1
      from public.booking_bookings b
      join public.booking_slots s on s.id = b.slot_id
      join public.expert_accounts ea on ea.user_id = auth.uid()
      where b.id = prescriptions.booking_id
        and s.expert_id = ea.expert_id
    )
  );
-- No client INSERT policy: writing goes only through write_prescription().


-- ---------------------------------------------------------------------
-- write_prescription() -- the doctor saves a prescription for a booking.
--
-- Authorises the caller as the expert who hosts the booking's slot, then
-- inserts with patient_user_id derived from the booking. The doctor never
-- handles the patient's user id, and cannot write for a booking they do
-- not host.
-- ---------------------------------------------------------------------
create or replace function public.write_prescription(
  p_id         text,
  p_booking_id text,
  p_items      jsonb,
  p_advice     text
) returns void
language plpgsql
security definer set search_path = ''
as $$
declare
  v_booking public.booking_bookings;
  v_slot    public.booking_slots;
begin
  select * into v_booking from public.booking_bookings where id = p_booking_id;
  if not found then raise exception 'no such booking'; end if;

  select * into v_slot from public.booking_slots where id = v_booking.slot_id;

  if not exists (
    select 1 from public.expert_accounts ea
    where ea.user_id = auth.uid() and ea.expert_id = v_slot.expert_id
  ) then
    raise exception 'not your patient';
  end if;

  insert into public.prescriptions
    (id, booking_id, expert_id, patient_user_id, items, advice)
  values
    (p_id, p_booking_id, v_slot.expert_id, v_booking.user_id, p_items, p_advice);
end;
$$;

grant execute on function public.write_prescription(text, text, jsonb, text)
  to authenticated;
