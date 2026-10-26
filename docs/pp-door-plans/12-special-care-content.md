# Door 12: Special care, the new copy (SC2, SC3)

Written 2026-10-25. This goes into `pp_special_care_content.dart` at build. The house rules are the section's own:
- Never a diagnosis.
- "Only a trained professional can say."
- Early help is never wasted.
- No blame.
- English only. No emoji.
- Every clinical, legal and money line is REQUIRED_REVIEW, read by a developmental paediatrician (clinical) and checked against current government pages (schemes, tax, amounts) before release. Costs are ranges, dated, in rupees only (the user, 2026-10-26: "right now keep only rupees").

---

## 1. New page: "Not talking yet: what to do next"
Area: `additional_needs`. Bands: 1 year and up. Format: STEP-LIST. This is the first page on Extra support from 1 year.

**Intro.** Children start talking at very different ages, and many late talkers catch up. But you never have to wait to ask. A check costs you nothing, and if he needs help, starting early is what makes the biggest difference.

**Steps:**
1. **Check what's usual for his age.**
   - Link: "Speech by age" → Development `dev_speech_by_age`.
   - Link: "Speech signs worth checking" → Development `dev_speech_flags`.
2. **Get his hearing checked first.** Many speech delays are a hearing problem, often from repeated ear infections. Link: "Hearing checks" (§3).
3. **Ask your paediatrician:** "Would a speech assessment help?" You don't need to be sure.
4. **Where to go:**
   - **The DEIC** (District Early Intervention Centre), free, up to 6 years, at your district hospital
   - a government hospital's speech and hearing department
   - or a private RCI-registered speech therapist
5. **While you wait, at home:**
   - talk about what he's looking at
   - add one word to his
   - wait five seconds for an answer
   - read together
   - keep the TV off in the background

   Link: Early learning's "Help him talk" (EL1).

**Doctor callout:**
> See a doctor soon if he loses words he had, doesn't respond to sounds or his name, or has no words at all by 16 to 18 months.

**India note:** "Boys talk late" and "he's just lazy to talk" are said with love. Your instinct still counts, and a check settles it.

## 2. New page: "Speech therapy and the other therapies, explained"
Area: `additional_needs`. Bands: 1 year and up. Format: CARDS, then STEPS. REQUIRED_REVIEW.

**Intro.** "He needs therapy" can sound frightening. In practice it usually means playing with a trained person who shows you what to do at home.

**The therapies:**
- **Speech therapy:** helps with understanding, talking, sounds, and sometimes eating and swallowing. A session is usually play: toys, pictures, songs, with you in the room.
- **Occupational therapy (OT):** helps with everyday skills like holding a spoon, dressing and handwriting, and with sensory struggles (clothes, noise, textures).
- **Physiotherapy:** helps with sitting, walking, balance and strength.
- **A special educator:** helps with learning at the child's own pace, and with getting ready for school.

**How often:** usually one to three sessions a week, 30 to 45 minutes each. **The practice at home between sessions matters more than the session itself.**

**What it costs in India** (ranges, checked 2026; vary by city):
- **Free:** at a DEIC under RBSK, and at many government hospitals and medical colleges
- **Private, per session:** about ₹500 to ₹1,500 in most cities, and more in metros
- **Ask:** whether the centre offers a home programme, so you need fewer paid sessions

**How to find a good one:**
- **Registered with the RCI** (Rehabilitation Council of India). Ask for the registration number, and check it on the RCI site.
- **Works with you in the room,** and teaches you what to do.
- **Sets goals you can see,** and reviews them every few months.
- **Be careful of any centre that promises a "cure", or wants a long package paid upfront.**

**Doctor callout:**
> Your paediatrician or a developmental paediatrician can tell you which therapy he needs, and how often. Start with them.

## 3. New page: "Hearing checks"
Area: `additional_needs`. Bands: every age. Format: CARDS. REQUIRED_REVIEW.
- **At birth:** many hospitals do a quick newborn hearing screen (OAE) before you go home. If his was missed, or he "didn't pass" one ear, ask for a repeat by 1 month. A failed screen often just means fluid or a noisy room.
- **What to watch for:**
  - by 3 months, he startles at loud sounds
  - by 6 months, he turns to your voice
  - by 12 months, he responds to his name and babbles
- **Ear infections and glue ear:** repeated ear infections can leave fluid that muffles sound for weeks, a common cause of late talking. It usually clears, and your doctor can check.
- **Where to test:** an ENT doctor or an audiologist, at a government hospital (often free) or a private clinic. Babies and toddlers have tests that need no answers from them.

Link: Health's ear pages (exact id at build).

**Doctor callout:**
> See a doctor if he doesn't react to loud sounds, has ear discharge or pain, or you or anyone in the family feels he isn't hearing well.

## 4. New page: "If your child has a diagnosis from birth"
Area: `additional_needs`. Bands: 0–12 months and up. Format: STEPS. REQUIRED_REVIEW.

**Intro.** Hearing that your baby has Down syndrome, cerebral palsy, a heart condition or another diagnosis can turn the first weeks upside down. You don't have to understand everything at once. He is your baby first.
1. **Ask for the plan, in writing:**
   - who follows him (paediatrician, cardiologist, neurologist)
   - which tests are next
   - when the next visit is
2. **Feeding help early:** some babies tire easily or find sucking hard. Ask for a lactation consultant or a feeding specialist in hospital. Link: Feeding.
3. **Early intervention:** register at the DEIC, free, from birth. Therapy started in the first months makes the biggest difference.
4. **Find other parents:** ask your hospital or DEIC for a parent group. They know the local doctors, therapists and schools.
5. **The papers, when you're ready:** the disability certificate and UDID card open benefits. Link: "Help in India" (§5).
6. **Look after yourself:** link `sc_parent_wellbeing`.

**India note:** relatives may ask "whose side is it from" or suggest remedies. Nothing you or your family did caused this.

## 5. `sc_help_india`, rewritten as steps
Format: STEPS, with the existing cards kept below. REQUIRED_REVIEW (schemes, as of the release date).
1. **Start at the DEIC.**
   - free screening, assessment and therapy up to 6 years under RBSK
   - no diagnosis needed to ask
   - at your district hospital
2. **The disability certificate and UDID card:**
   - apply online at the UDID portal (swavlambancard.gov.in)
   - go for the medical board assessment at the district hospital on the date given
   - the card comes by post
   - carry his birth certificate, Aadhaar (his or yours), photos, address proof and all medical reports
3. **Niramaya health insurance** (the National Trust): low-cost cover for children with autism, cerebral palsy, intellectual disability or multiple disabilities. Apply through a registered organisation.
4. **Tax:** under Section 80DD, a parent who cares for a dependant with a disability can claim a fixed deduction, with a certificate. Ask your tax adviser.
5. **Pensions and scholarships:** many states pay a monthly disability pension and offer school scholarships. Ask at the district social welfare office. Amounts vary by state.
6. **School:**
   - the RPwD Act 2016 and RTE give him the right to a regular school with support
   - **an IEP** (Individual Education Plan) sets his own goals
   - **a shadow teacher** sits with him in class
   - boards like CBSE allow exemptions and extra time later
   - Link: Early learning's "Nursery admission"
7. **Check every professional:** therapists and special educators should be registered with the RCI.

## 6. `sc_late_bloomer`, a new step group: "Questions to ask at the assessment"
- What did you see today, and what does it mean for him?
- What should we do at home this week?
- Which therapy, how often, and for how long before we review?
- Is it free anywhere near us?
- What signs should make us come back sooner?

## Sources (REQUIRED_REVIEW at build)
- **RBSK and DEIC:** the operational guidelines (MoHFW).
- **Disability certificates and UDID:** the Department of Empowerment of Persons with Disabilities (UDID portal).
- **Niramaya:** the National Trust Act 1999, and the Niramaya scheme.
- **Tax:** the Income Tax Act, Section 80DD.
- **Rights:** the RPwD Act 2016, and the RTE Act 2009.
- **Professionals:** the RCI register.
- **Clinical:** AAP and IAP on speech and language delay, newborn hearing screening (JCIH, and India's RBSK newborn screening), and early intervention.
