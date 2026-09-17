-- =====================================================================
-- 0082_onboarding_stage_and_code.sql -- two things the new first run needs
-- ---------------------------------------------------------------------
-- 1) `skilling` is now a real stage. The onboarding Stage screen writes it
--    (docs/ONBOARDING-AUDIT.md §5.1) and LifeStageStore pushes it to
--    profiles.life_stage, whose check constraint (0041) only knew three
--    values. Without this the write fails -- silently, because profile
--    writes are fire-and-forget -- and every skilling family would boot into
--    the wrong home on the next device.
--
-- 2) One code length. The partner pairing code was 8 characters and the SMS
--    OTP is 6 digits; the user asked for one fixed length so the two entry
--    sheets look and feel like one thing. Six characters from the same
--    unambiguous alphabet (no 0/O, 1/I/L) is 30^6 = 729 million codes --
--    plenty behind link_as_partner's own rate of one attempt per tap.
--    Existing codes are regenerated: partners already linked keep their
--    link (partner_id is what links them, not the code), and nobody has a
--    printed 8-character code anywhere. If that ever stops being true, this
--    block is the one to skip.
--
-- PREREQ: 0009 (pairing), 0041 (life_stage).
-- =====================================================================

-- 1) life_stage accepts skilling.
alter table public.profiles
  drop constraint if exists profiles_life_stage_check;
alter table public.profiles
  add constraint profiles_life_stage_check
  check (life_stage is null or life_stage in ('trying', 'pregnancy', 'parenting', 'skilling'));

-- 2) Six-character pairing codes.
create or replace function public.gen_pairing_code()
returns text
language plpgsql
volatile
as $$
declare
  alphabet constant text := 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
  code text;
  i int;
begin
  loop
    code := '';
    for i in 1..6 loop
      code := code || substr(alphabet, (floor(random() * length(alphabet)) + 1)::int, 1);
    end loop;
    exit when not exists (select 1 from public.profiles where pairing_code = code);
  end loop;
  return code;
end;
$$;

-- Regenerate every existing code to the new length. Links are untouched.
update public.profiles
   set pairing_code = public.gen_pairing_code()
 where pairing_code is not null
   and length(pairing_code) <> 6;
