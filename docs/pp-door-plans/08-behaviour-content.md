# Door 8: Behaviour, the new copy (BH2, BH4, BH7)

Written 2026-10-25, and BH1 to BH8 were answered yes the same day. This goes into `pp_scripts_data.dart` and the three `pp_behaviour_*.dart` files at build, if the user says yes. The house rules are the section's own:
- Warm and firm. Never shaming, the child or the parent.
- No hitting, said plainly.
- We say where we stand.
- No product or book on a page with a warning.
- English only, and no emoji.
- Every clinical or safety line is REQUIRED_REVIEW, read by a child psychologist (behaviour) or a paediatrician (honey, pica) before release.

---

## 1. Four scripts for the family, 0–12 months (BH2), `pp_scripts_data.dart`
These are for answering the family, not the baby. Each one keeps the existing script shape: the moment, what to say, and what to leave unsaid.

### "You're spoiling him, putting him down is better"
- **Say:** "He's too little to be spoiled. Babies who get picked up when they cry end up crying less, not more. I'd rather he learns that someone comes."
- **Leave unsaid:** "You did it wrong with your children." It turns a care question into a fight about the past.
- Page: `cant_spoil`.

### "Let him cry, it's good for his lungs"
- **Say:** "Crying doesn't make his lungs stronger. It just tires him out. I'll try to calm him, and if he keeps going, we'll try the next thing together."
- **Leave unsaid:** a lecture. One line and a calm pick-up says more.
- Page: `crying_normal`. REQUIRED_REVIEW.

### "Your milk isn't enough, that's why he cries"
- **Say:** "Crying isn't a sign of hunger on its own. The doctor checks his weight, and that tells us if he's getting enough. I'll ask at his next visit."
- **Leave unsaid:** nothing about how she feeds. The worry is real, and the weight check answers it.
- Page: Feeding's "Is he getting enough?" page (exact id at build). REQUIRED_REVIEW.

### "Give him a little honey, or gripe water"
- **Say:** "Not honey before his first birthday. The doctor says it can make babies very ill. For the crying, I'd rather ask the doctor before giving him anything."
- **Leave unsaid:** that the old ways are wrong. Say what the doctor says, then stop.
- **Safety line, shown on the script:** "No honey, in any amount, before 1 year. This includes janam ghutti made with honey." REQUIRED_REVIEW (paediatrician).
- Page: `crying_doctor`.

**The empty search line:** "Nothing for that yet. Try 'hitting' or 'bedtime'."

**The four scripts with no page today** each get the closest page at build, chosen from the script's own topic, and the build lists them.

## 2. "When it's too much for you" (BH4)
This card goes on `crying_too_much` and `beh_no_hitting`, after the steps and away from the page's own warning. REQUIRED_REVIEW.

> **When it's too much for you.** Everyone who looks after a small child reaches the edge sometimes. If you're there, put him somewhere safe, step out for a few minutes, and breathe.
> **Free, any hour: Tele-MANAS, 14416.** The government's mental health line. Trained counsellors, in your language, free.
> Link: "When the anger is yours" → You, Maa `mind_rage`.

The number is shown as text she can copy. A call link may do nothing on some phones, so the number is always visible.

## 3. Guests, weddings and festivals: a new part of `beh_tantrum_public`
Not a page of its own, because search demand is weak (15 hits). It goes in as a step group, "At functions and festivals". REQUIRED_REVIEW.

**Intro.** A house full of relatives, a wedding till midnight, crackers at Diwali. Every child gets overwhelmed at some point. It isn't bad behaviour, it's too much at once.
- **Before you go:** a nap if you can, a snack in your bag, and one line about what will happen: "There will be lots of people and loud music. We can sit outside if it's too loud."
- **Find a quiet corner early:** a car, a balcony or a back room. Go there before the meltdown, not after.
- **When a relative says "so naughty":** "He's tired, it's a long day for a small person." Then take him for a walk. You don't owe anyone a performance.
- **Hugs and cheek-pinching:** he doesn't have to be kissed or held by everyone. "He'll say namaste from here" protects him and keeps the peace.
- **Leaving early is allowed.** A tired child going home is not a failure, for him or for you.


## 3a. Colic, named on `crying_normal` (BH7)
REQUIRED_REVIEW (paediatrician).
> **Is it colic?** Doctors use "colic" for a healthy baby who cries for more than three hours a day, on more than three days a week, for more than three weeks. It often starts at around two weeks, is worst at six to eight weeks, and usually eases by three to four months. Colic isn't an illness, and it isn't something you did. The doctor callout on this page stays the same.

The card title becomes "Colic, or normal crying?".

## 3b. When tantrums ease, on `first_tantrums` (BH7)
REQUIRED_REVIEW.
> **When do tantrums stop?** They're most common between about 18 months and 3 years, when he wants a lot and has few words to say it. They ease as his words grow, and most children have far fewer by 4 or 5. If they're getting longer, more violent or more frequent after 4, or he hurts himself, mention it to your doctor.

## 4. New page: "After you've shouted"
Area: `discipline` (Calm and guidance). Bands: 1–2, 2–3 and 3–6 years. Format: SHORT ARTICLE. REQUIRED_REVIEW.

**Intro.** You shouted. Maybe louder than you meant to, maybe at the end of a very long day. Most parents do this sometimes. What matters more is what you do next.
- **Repair, in three lines:** get down to his level, then say: "I shouted. That wasn't okay. I was upset, and I'm sorry." No "but you…"
- **Why it works:** he learns that people who love each other can mend things. That lesson lasts longer than one bad evening.
- **One bad evening doesn't undo him.** Children are shaped by the pattern, not the worst moment.
- **Look at the pattern:** if it's most days, notice when it happens: hunger, no sleep, the same fight every evening. Change one of those first.
- **When to get help:** if you're frightened of your own anger, or it's turning into hitting, talk to someone. See "When it's too much for you" above.

Links: "When the anger is yours" → You, Maa `mind_rage`; "Why hitting doesn't do what it looks like it does" → `beh_no_hitting`.

## 5. The phone at mealtimes, added to `beh_screens_family`
A new step group, "The phone at meals". REQUIRED_REVIEW.
- **Why it's so common:** with a cartoon on, he eats without a fight, and in a busy house that feels like a win.
- **What it costs:** he stops noticing when he's full, and often eats less food he chooses himself. Then meals without a phone become a battle.
- **Coming off it slowly:** first the sound off, then the screen face-down, then one meal a day with no phone. Talk to him, or sing, while he eats.
- **For the grandparents:** "We're trying meals without the phone this week. Can you help me with lunch?" It makes them part of the change.

Link: Feeding's fussy-eating page (exact id at build).

## 6. The thin pages, written out
Each keeps its title and existing steps. The additions:

**`beh_comfort_object`** (bands: 1 year and up)
- **When it gets lost:** stay calm, look together, and offer the spare. A new object can take a week to be loved.
- **At nursery or school:** most allow a small comfort toy at first. Ask the teacher.
- **Letting go:** almost all children drop it on their own between 3 and 6. There's no need to take it away.

**`beh_nail_biting`**
- **What not to do:** bitter polish, slapping hands away and shaming usually make it worse, because the habit is a way of calming down.
- **Hair-pulling:** if he pulls hair out until there are bald patches, mention it to your doctor.
- **When to check:** bleeding or infected fingers, or a habit that grows when something at home or school has changed. REQUIRED_REVIEW.

**`beh_fear_dogs`**
- **Picture books and play first:** a toy dog, a book about dogs, then a real one far away.
- **Lifts and crackers:** count down together ("three, two, one, doors close"), and keep ear protection for Diwali.
- **If he's bitten or scratched by any dog:** wash the wound with soap and running water for 15 minutes and see a doctor the same day about rabies vaccination. This goes in a doctor callout. REQUIRED_REVIEW.

**`feelings_checkin`** (3–6 years)
- **How to run it:** once a day, at the same time (after school, at bath time), ask "Which face are you today?" with three to five faces.
- **Go first yourself:** "I felt cross in the traffic, then happy when I saw you."
- **No fixing:** listen, name the feeling, and stop. "You felt left out. That's hard."

**`beh_eating_nonfood`** (bands: 1 year and up)
- **What to do now:** keep chalk, paint flakes, wall plaster and small objects out of reach, and offer something safe to chew.
- **Iron-rich food:** ragi, dal, green leafy vegetables, eggs or meat if your family eats them, with vitamin C (lemon, amla) to help absorb it.
- **Signpost:** "Signs worth checking in development" → Special care `dev_autism_signs`.
- The doctor callout stays, unchanged. REQUIRED_REVIEW.

**`beh_calm_jar`**
- **How to make it:** a clear plastic bottle, warm water, two spoons of glitter glue and some glitter. Seal the lid with glue.
- **How to use it:** "Shake it, and watch until the glitter settles. Your body settles too." It's for calming down together, not a punishment.
- **Make it together:** he chooses the colour, and it becomes his.

## 7. Sources (REQUIRED_REVIEW at build)
- AAP, "Effective Discipline to Raise Healthy Children" (2018): no spanking, no harsh verbal discipline.
- AAP and IAP on infant crying and soothing, and on honey and infant botulism (no honey under 12 months).
- WHO, "Guidelines on physical activity, sedentary behaviour and sleep for children under 5" (2019): screen time.
- Tele-MANAS, MoHFW (14416).
- WHO and NCDC guidance on animal bites and rabies post-exposure care.
- Research on pica and iron deficiency, at the paediatric reviewer's choice.
