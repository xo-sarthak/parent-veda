# Door 10: Traditions, the new copy (TR1 to TR6)

Written 2026-10-25. This goes into `pp_traditions_content.dart` at build. The house rules are the section's own:
- Myth versus evidence, never tradition versus science.
- Small is complete.
- Never mocking a family.
- English only, no emoji.
- Every clinical line is REQUIRED_REVIEW, read by the same paediatrician who reviews Sleep's jhula page (SL7), so the doors agree.

---

## 1. The jhula (TR2), page `jhula`, replacing `:813-816`
The old paragraph is commented out, "kept for revert".

> The cloth jhula tied to a beam is how most of India has rocked its babies, and the rocking really does calm them. Use it for soothing and for naps while someone is right there. Once he's deeply asleep and you're leaving the room, move him onto a flat, firm surface on his back: a cot, a bassinet or a firm mattress on the floor. In a deep cloth swing his chin can drop to his chest, and that can narrow his airway without a sound.

Links:
- "Jhula, cradle or saree swing?" → Sleep's new jhula page
- "The jhula in the first weeks" → First 40 `f40_jhula`

**The "good old ways" note (`:2891`)** becomes:
> Most of the old ways are still good. Malish, being carried a lot, rocking in the jhula while you're with him, carom seed water for the mother, ghee in food from six months. This page is a short list of exceptions. It says nothing about how well your family raises children.

"Cosleeping" leaves the list. Sleep's bed-sharing page owns that, with its harm-reduction steps. The old wording is commented out.

## 2. Malish and the oil (TR3), a new part of `newborn_customs`
REQUIRED_REVIEW.

**Malish and the oil**
- **Malish is good for him:** for closeness, calm and sleep. Warm hands matter more than the oil.
- **Mustard oil is best kept off a newborn's skin.** It's traditional and warming, but it can irritate young skin. Studies in India found it can weaken the skin's barrier in the first weeks. Many families keep it for the mother's own massage.
- **What to use instead:** a plain, fragrance-free oil, like cold-pressed coconut or sunflower oil. Test a little on his leg first and wait a day.
- **Never in his ears, nose or eyes,** and keep oil off the cord until it has dropped off and healed.
- **Hot oil:** warm it between your palms, never on the stove. Test it on your wrist.

Links:
- "How to do malish, step by step" → Sleep `malish`
- "Malish in the first forty days" → First 40 `malish`

## 3. Festivals (TR5), additions to `first_festivals`
REQUIRED_REVIEW. Link kept: "Festival safety" → Safety `safety_festivals`.
- **Holi:** use dry, skin-safe colours, keep them away from his face, and oil his skin and hair first. If colour gets in his eyes, rinse with clean running water for several minutes. See a doctor if the eye stays red or painful.
- **Makar Sankranti and kites:** manja, the glass-coated kite string, cuts. Keep small children off rooftops while kites fly. Put a guard on the scooter, or a scarf at his neck, if he rides in front.
- **Lohri and bonfires:** keep him well back and held. Watch loose dupattas and synthetic clothes near the flames.
- **Ramzan while breastfeeding:** many mothers fast, and many are exempt. Talk to your doctor first. Drink plenty of water between iftar and sehri. Stop if you feel dizzy, or if your milk or his wet nappies drop.

## 4. Faiths and regions (TR5)
- **Page title:** "Jain and Parsi welcomes" becomes "Jain, Parsi and Buddhist welcomes".
- **New card, "A Buddhist welcome":** many Buddhist families take the baby to a monastery or vihara in the first months. A monk or elder offers blessings, sometimes ties a white thread on the wrist, and may help choose a name. As with any thread, keep it loose and remove it at sleep (link `newborn_customs`). REQUIRED_REVIEW by a member of the community.
- **On `how_date_chosen`:** "Families from Odisha, Assam, Kashmir, Sindh, the Konkan coast and many other places have their own versions of these ceremonies and dates. This door doesn't list every one. Ask the elder who does it in your family."
- **The 3–6 chart:** Navjote and Dastar Bandi move off the chart to one line under it: "Later, at about 7 to 11: Navjote for Parsi children, Dastar Bandi for Sikh boys."

## 5. `someone_elses_ceremony`, written out (TR6)
The four cards stay. New cards:
- **"If you're bringing your own baby"**
  - feed before you go
  - carry a muslin and a change of clothes
  - find a quiet room early
  - it's fine to keep him in your arms rather than passed around
- **"Feeding the new baby"**
  - Don't offer the new baby anything to eat or drink, not even water or a sweet. That's his parents' call, and before six months only milk is safe.
  - A quiet "I'll leave the honey for later" helps if someone else does.
- **"Smoke, crackers and havan"**
  - sit away from the havan smoke and the crackers
  - step outside with your baby if it gets thick
- **"Leaving"**
  - say your blessing and go before the baby or yours gets overtired
  - that's the kind thing

## 6. Names (TR6)
- **The tool:** "Home remedies from the elders, checked" becomes "Home remedies, checked". The old label is commented out.
- **The door comment:** "Welcoming her home" becomes "Welcoming baby home", and the area count in the comment is fixed.

## 6a. The two tone pages (TR-Q, approved 2026-10-25)
`skip_it` is approved as it stands. `mother_kept_apart` is approved with two changes:
- **The script:** "Can my husband sit with me…" becomes "Can my husband or my mother sit with me and the baby in the evenings?"
- **The doctor callout gains:** "Free, any hour: Tele-MANAS, 14416." REQUIRED_REVIEW.

Both "THE BRIEF ASKS FOR THE USER'S SIGN-OFF" comments come off. The test's "awaiting sign-off" list (`test/pp_traditions_door_test.dart:78-79`) is cleared.

## 7. Age tags (TR1)

| Pages | Bands |
|---|---|
| chatti, namkaran, jhula, nishkramana, aqiqah, tahneek, christening | 0–4 months |
| annaprashan, annaprashan_food | 4–12 months |
| mundan, karnavedha, first_birthday | 4 months – 3 years |
| aksharabhyasam | 1–3 and 3–6 years |
| the faith pages other than newborn welcomes, and keep_it_small, not_safe and first_festivals | every age |

Pages for an age already passed fold under "Earlier", which is already shell behaviour.

## Sources (REQUIRED_REVIEW at build)
- AAP Safe Sleep 2022 (inclined and suspended sleepers).
- Darmstadt et al. and the Lancet/Indian neonatal trials on mustard oil and the skin barrier in newborns, and WHO newborn skin care guidance (sunflower oil).
- AIIMS and IAP guidance on Holi colour eye injuries.
- Reports on manja injuries during Sankranti (state advisories).
- Guidance on fasting during Ramadan while breastfeeding (NHS, and the Islamic Medical Association's guidance).

## Added by the demand re-check (2026-10-25)
**§2, Malish and the oil:** it gains a link, "Which massage oil?" → First 40 `f40_which_oil`, the one source for the comparison (First 40 FD12). That page's mustard row now says what §2 says.
