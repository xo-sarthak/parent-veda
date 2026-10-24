# Door 5: Potty, the new activities and the page changes (PT3, PT6)

Written 2026-10-24, ready to go into `pp_potty_content.dart` at build, if the user says yes to PT3 and PT6. The house rules are the same as the other door content files:
- **Never a diagnosis.** A doctor callout closes every clinical worry. REQUIRED_REVIEW marks each clinical line, and a paediatrician reads them before release (BEFORE-LAUNCH).
- **No scorekeeping** (the section's own rule, `pp_potty_content.dart:29-36`). No activity has a tick, a count, a streak or a "done" state. An activity is something to try today, not something to finish.
- **No product near a doctor flag**, and one pitch per page.
- English only, no emoji. "Your child" and "he", as the section already uses them.

Each activity is an `ACTIVITY` page (the format of `teach_the_toy`): an intro, "What it is", "How to do it" steps, one callout, and a `PpWhenLine`. Each one gets a time for the shelf card. Below are the intro, the steps in short, the callout and the when-line; the build writes them out in full in the house voice.

---

## Part A. The shelf, by stage (PT3)

Order inside each shelf is a fresh pick each day, seeded by date, from the cards for his band. The cards marked *existing* are pages already in the section.

| Band | Cards |
|---|---|
| 0–12 months | Cue at waking · Nappy-off time · Say it as it happens |
| 1–2 years | Let him choose the potty · Pants down, pants up · Flush and wave bye-bye · Say it as it happens |
| 2–3 years | The after-waking sit · Wash at the low tap · Big-kid pants day · The picture routine *(existing `routine_chart`)* · A book on the potty *(existing `sit_and_read`)* · Teach the toy *(existing `teach_the_toy`)* |
| 3–4 years | Wiping practice with a doll · Last wee before bed · Pack the spare-clothes bag · Teach the toy *(existing)* |
| 4–6 years | Wiping practice with a doll · Public toilet practice run · Last wee before bed · Pack the spare-clothes bag |

The plan's first draft put Teach the toy at 1–2 years. Its own when-line says "from about 2.5 years", so it starts at 2–3. The picture routine and the book on the potty say "from about 2 years", so they start there too.

### Cue at waking · 3 min · 0–12 months
**Intro.** Babies often wee within a few minutes of waking. Holding him over a potty or a bowl at that moment, with the same soft sound each time, is the whole of the su-su way.
**Steps.** Pick him up as he wakes, before the nappy goes on · Hold him securely over a small potty, bowl or the bathroom floor drain, his back against your tummy · Make the sound your family uses ("ssss", "su-su") · Wait a minute, no more · If nothing comes, that's fine. Nappy on, and try again after the next nap.
**Callout.** A miss is not a failure. You are teaching a sound and a place, slowly, over months.
**When.** From a few weeks old. Easiest before he crawls.

### Nappy-off time · 10 min · 0–12 months
**Intro.** A few minutes on a towel with no nappy lets air reach his skin and lets you see what a wee looks like on his face just before.
**Steps.** Lay a thick towel or a waterproof sheet on the floor · Let him kick for 10 minutes · Watch his face and body before a wee: a pause, a grunt, a stillness · Say the word as it happens.
**Callout.** On a warm day this is also the best thing for nappy rash.
**When.** From the first weeks. Worth starting again every summer.

### Say it as it happens · 1 min · 0–2 years
**Intro.** Children learn the words for wee and poo the same way they learn "dog" and "milk": by hearing them at the right moment, without fuss.
**Steps.** Pick your family's words, and everyone uses the same ones · Say them when you see or change a wet or dirty nappy: "That's a wee. Wee goes in the potty." · No face, no "chhee", no "dirty". Just the word.
**Callout.** Grandparents' words count. If Dadi says "su-su", let that be the word.
**When.** Any age. It pays off from about 18 months, when he starts telling you.

### Let him choose the potty · 10 min · 1–2 years
**Intro.** A potty he picked is a potty he sits on. Let him choose the colour, or the corner of the bathroom it lives in.
**Steps.** Offer two choices, not ten · Put it where he can see it every day · Let him sit on it in his clothes first, for a story or a song · No asking him to do anything on it yet.
**Callout.** Fully clothed sitting is a real step. It takes the strangeness out.
**When.** From about 15 months, or when he starts watching you in the bathroom.

### Pants down, pants up · 5 min · 1–2 years
**Intro.** A lot of early accidents are not about the bladder at all. He just can't get his pants down in time. Practise it as a game, away from the potty.
**Steps.** Use loose, elastic-waist shorts or a chaddi · Push down to the knees, pull up again · Make it a race against a song, or against Teddy · Praise the trying, not the speed.
**Callout.** Skip buttons, belts, dungarees and tight jeans until he's dry.
**When.** From about 18 months.

### Flush and wave bye-bye · 1 min · 1–2 years
**Intro.** Many children are frightened of the flush, or sad to see something of theirs disappear. Waving it off turns it into a goodbye.
**Steps.** Tip what's in the nappy or the potty into the toilet together · Let him press the flush if he wants to, or stand back if he doesn't · Wave and say "bye-bye, poo".
**Callout.** If the flush scares him, flush after he leaves the room. Fear of the flush is common and passes.
**When.** From about 18 months.

### The after-waking sit · 3 min · 2–3 years
**Intro.** The easiest wee of the day is the one just after he wakes. A short, calm sit then is the start of a routine he can feel, not one you have to remember.
**Steps.** Straight from bed to the potty, before milk · Sit for two or three minutes, with a book or a song · Whatever happens, he gets up, washes hands, and the day goes on · Add a sit after meals once this one is easy.
**Callout.** Never hold him on the potty. If he wants to get up, he gets up.
**When.** From about 2 years.

### Wash at the low tap · 3 min · 2–3 years
**Intro.** Washing hands is the last step of every trip, and it's the one he can do on his own first. A stool, a mug and soap he can reach make it his.
**Steps.** A steady stool at the basin, or a bucket and mug at his height · Wet, soap, rub while you sing one short song, rinse · A small towel on a hook he can reach.
**Callout.** If he uses an Indian toilet, the mug and bucket he washes with are the same ones he'll use for washing hands. Keep them separate and clean.
**When.** From about 2 years.

### Big-kid pants day · all day · 2–3 years
**Intro.** A day at home in cotton chaddis, not a nappy, so he feels what wet means. Choose a calm day with nowhere to go.
**Steps.** Let him pick the chaddis · Offer the potty after waking, after meals, and before going out · Expect accidents, and say "wee goes in the potty" without a sigh · Keep a towel, a mop and three changes ready · Back into a nappy for the nap and night, with no fuss.
**Callout.** If by the evening there's no sign he noticed being wet, he isn't ready yet. Put it away for a few weeks. That's information, not failure.
**When.** Once you see two or three readiness signs.

### Wiping practice with a doll · 5 min · 3–6 years
**Intro.** Wiping well is hard, and most children need help with it until five or six. Practising on a doll, or with paint on a balloon, makes it a game instead of an inspection.
**Steps.** Show front to back on a doll, slowly · Let him do it on the doll · For washing with water, show the mug or health faucet and the left hand, then soap and wash · Then let him try on himself while you stand close.
**Callout.** Girls wipe or wash front to back, every time. It keeps urine infections away. REQUIRED_REVIEW
**When.** From about 3 years.

### Last wee before bed · 2 min · 3–6 years
**Intro.** A wee just before sleep is the one habit that helps dry nights most, and it costs nothing.
**Steps.** Make it part of brushing teeth · Keep water normal through the day and fewer big drinks in the last hour, never none · Leave a night light on the way to the bathroom.
**Callout.** Dry nights come from his body's own clock, not from practice. This only gives it a fair chance.
**When.** From about 3 years, once days are dry.

### Pack the spare-clothes bag · 5 min · 3–6 years
**Intro.** Children who pack their own spare clothes worry less about accidents at playschool and on outings. It's his bag, so it's his plan.
**Steps.** One chaddi, one pair of shorts or a frock, one plastic bag for wet things · He packs, you check · Show him where it lives in his school bag.
**Callout.** Tell the teacher the bag is there. Most accidents at school are because he didn't want to ask.
**When.** From about 3 years, and before playschool starts.

### Public toilet practice run · 15 min · 4–6 years
**Intro.** Loud hand dryers, tall seats and unfamiliar Indian or western toilets can scare a child into holding. A practice visit on a calm day helps.
**Steps.** Pick a clean toilet at a mall, a restaurant or a relative's house · Look around together first: where to sit or squat, where to wash, the flush, the dryer · Let him try, or just look · Carry a folding seat or a travel potty if he needs one.
**Callout.** Holding all day at school or on journeys is how constipation starts. If he won't use any toilet but home's, tell your doctor. REQUIRED_REVIEW
**When.** From about 4 years, or before travel.

---

## Part B. Page changes (PT6)

### 1. `pull_ups` rewritten (thin today, about 570 characters). Title kept: "Pull-ups, cloth pants or a chaddi?"
**Intro.** Pull-ups feel like a nappy to a child, which is why they are useful at night and on long journeys, and less useful while he's learning by day.
**Cards.**
- **Cotton chaddi and a towel.** The cheapest way, and the way most Indian families have always done it. He feels wet at once, and that's the lesson. Best at home.
- **Cloth trainer pants.** A padded chaddi that holds a small wee. Less mess on the floor, and he still feels wet. Good for outings in the first weeks.
- **Pull-ups.** Disposable and absorbent. Use them for the night, long car or train journeys, and weddings. During the day they can slow learning, because he can't feel the difference.
- **Going back and forth is fine.** A pull-up for the train is not a step backwards.
**India note.** Washing chaddis is work. Five or six is enough for most homes, and dried in the sun they stay fresh.

### 2. `night_dryness`: a doctor callout and two links
**Doctor callout** (`kind: doctor`, REQUIRED_REVIEW). See a doctor if he was dry at night for six months and has started wetting again, if a wee hurts or burns, if he's very thirsty or weeing far more than usual, or if he snores loudly and seems tired in the day.
**Links.** "Bedwetting at five and older" → `bedwetting`. The timeline paragraph (repeated from `honest_timeline`) is commented out "kept for revert" and replaced with one line: "How long dry nights take, by age" → `honest_timeline`.

### 3. `indian_toilet`
- The travel-constipation callout becomes `kind: doctor` (REQUIRED_REVIEW): "If he hasn't done a poo in three days on a trip, or it hurts when he goes, see a doctor. Don't give a laxative without asking."
- In the washing card, name all three tools: "a mug and bucket, a lota, or the health faucet (the hand spray beside the toilet). Show him how hard to press a health faucet, gently, before he tries."

### 4. `bedwetting` (REQUIRED_REVIEW throughout)
- **One line naming it.** "Doctors call it enuresis. It is common: about one child in six still wets some nights at five, and most grow out of it on their own."
- **New article block, "What a doctor might suggest, after six".**
  1. A bedwetting alarm: a small sensor in his pants that buzzes at the first drop, so his brain learns to wake. It takes weeks, and works best when the child wants to try. A doctor can tell you if it suits him.
  2. A medicine (desmopressin) that makes the body make less urine at night. It is a doctor's choice, used for camps and sleepovers or for a while. Never start it from a chemist or on a friend's advice.
  3. Neither is needed before six, and neither is a cure for something wrong. Most of the time, waiting is the treatment.

### 5. `withholding_constipation`: new block, "Leaks in his pants can be constipation"
REQUIRED_REVIEW. When a child holds poo for a long time, a hard lump forms and soft poo leaks around it into his pants. It looks like he isn't trying, or is being dirty, and it is neither. He often can't feel it. Doctors call this soiling, or encopresis, and they treat the constipation underneath. Never scold for it. See a doctor.

### 6. `wiping_and_washing`: a pinworm card
REQUIRED_REVIEW. **Itching at night around his bottom?** It may be pinworms (threadworms), small white worms you might see in his poo or around his bottom at night. They're common in children and easy to treat, but the whole family usually takes the medicine together. See a doctor; short nails and hand-washing after the toilet help stop them coming back.

### 7. `school_and_public`
- **New card, "When the nursery asks 'is he toilet trained?'"** Many playschools ask at admission. Say honestly where he is: "dry most days at home, still learning to ask". Ask how they handle accidents and how often they take children to the toilet. A school that has a plan for accidents is a good sign. If the deadline is close and he isn't ready, a few weeks' delay is better than pushing him into fear.
- The second spare-clothes card (`:2136`) is commented out "kept for revert"; the first one stays.

### 8. Links
- `what_is_su_su`, India note: "Read next: how to read your baby's signals" becomes a real link → `reading_signals`.
- `regressions`: the link to the whole Behaviour door (`pp_section/parenting_behaviour`) becomes "When a new baby arrives" → Family's `fam_sibling_jealousy` (M4 `pageId`; checked at build).

### 9. One source for repeats
- The no-stars message stays in full on `no_star_charts`. In `daily_routine` (:923), `routine_chart` (:1704) and `night_dryness` (:1904) it becomes one line plus a link: "Why we skip stars and stickers" → `no_star_charts`. The longer text is commented out "kept for revert".
- The dry-nights timeline: see 2 above.

---

## Sources (REQUIRED_REVIEW at build)
- NICE CG111, bedwetting in under-19s (alarm and desmopressin as first-line options from age 5 to 7; reassurance before).
- NICE CG99, constipation in children (withholding, overflow soiling, no laxatives without a doctor).
- IAP guidance on toilet training and enuresis; the AAP's toilet-training guidance (readiness signs, child-led timing).
- Pinworm: WHO and CDC enterobiasis guidance (whole-household treatment, hygiene).
