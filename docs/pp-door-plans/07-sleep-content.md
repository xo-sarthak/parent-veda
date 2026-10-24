# Door 7: Sleep, the new copy (SL2, SL3, SL7)

Written 2026-10-24. This goes into `pp_sleep_content.dart` and `pp_sleep_data.dart` at build, if the user says yes. The house rules are the section's own:
- Safe sleep is harm reduction, not abstinence.
- We say where we stand.
- No target to hit.
- No product on the SIDS, bed-sharing or red-flag pages.
- English only. No emoji.
- Every clinical line is REQUIRED_REVIEW, read by a paediatrician before release.

---

## 1. Tracker ranges (SL3), `ageContext` in `pp_sleep_data.dart`
Each range is the same as the door's own chart for that age. REQUIRED_REVIEW.

| Age | Total in 24 h | Naps |
|---|---|---|
| 0–3 months | 14–17 h | many, no pattern |
| 4–12 months | 12–16 h | 2–3 |
| 1–2 years | 11–14 h | 1–2 |
| 3–5 years | 10–13 h | 0–1 |

The line under the numbers stays: "a range, not a target".

## 2. New page: "Jhula, cradle or saree swing?"
Area: getting_to_sleep. Bands: 0–12 months. Format: ARTICLE. REQUIRED_REVIEW throughout.

**Intro.** The jhula has rocked Indian babies to sleep for generations, and the rocking really does calm them. The question is only where he stays once he's asleep.

**Article.**
1. **For soothing, yes.** Rock him in the jhula, the cradle or your arms until he's drowsy or asleep, while you're right there.
2. **For sleeping, flat and firm.** Once he's asleep, move him onto a flat, firm surface on his back: a cot, a bassinet, or a firm mattress on the floor. In a saree swing or a deep cloth cradle, his chin can drop to his chest. That can narrow his airway without a sound.
3. **If he only sleeps in the jhula:** stay in the room, keep his head and back in a straight line, and keep nothing loose near his face. Move him across as soon as he's deeply asleep.
4. **Nests, swings, bouncers and inclined sleepers** are for awake time, watched. They aren't for sleep.

**Doctor callout.** If he seems to breathe noisily or struggle in any sleeping position, see a doctor.

**Note for the build.** `pp_traditions_content.dart` (~815-822) says "A cloth swing is as good a place to sleep as an imported cot". It goes to the same reviewer, and the two doors must say the same thing.

## 3. New page: "Safe sleep after one"
Area: safe_sleep. Bands: 1–2, 2–3 and 3–5 years. Format: CARDS. REQUIRED_REVIEW.
- **A pillow and a light blanket are fine now.** Use them from about 12 to 18 months, when he can move freely and push things off his face.
- **Cot to bed:** move when he starts climbing out, or at about 2 to 3 years. A mattress on the floor, or a low bed with a rail, is safest at first.
- **Falls:** keep the bed away from windows, and never under a ceiling fan's hanging chain or a shelf. Put a soft rug on the floor.
- **Sharing your bed:** after one, the SIDS risk is gone. What remains is a fall from a high bed, and a squeeze between the bed and the wall.
- **The room at night:** keep cords out of reach and furniture fixed to the wall. No mosquito coil, agarbatti or smoke.

## 4. New page: "Hot nights and power cuts"
Area: safe_sleep. Bands: all. Format: SHORT ARTICLE. REQUIRED_REVIEW.

**Intro.** Hot Indian summers and a sudden power cut can wake anyone. Babies get too hot faster than adults.
- **Dress him in one thin cotton layer,** or just a nappy on the hottest nights. Feel his chest or the back of his neck, not his hands or feet. Hot and sweaty means take a layer off.
- **For a fan or AC:** air should move around him, not blow straight at him. Aim for a room that feels comfortable to you in light clothes.
- **Without power:** open a window with a net on it, hang a damp cloth near him (never on him), and keep a small battery or rechargeable fan.
- **No mosquito coil or agarbatti in the room where he sleeps.** The smoke irritates small lungs. Use a mosquito net over the cot.

**Doctor callout.** See a doctor if he's very hot and floppy, unusually sleepy and hard to wake, or not feeding. Overheating can make a baby unwell.

## 5. `sleep_talk_walk`, rewritten (thin today, about 630 characters). The title is kept.
**Intro.** Sleep talking and sleepwalking are common between about 3 and 7 years, often run in families, and usually stop on their own.
- **During a sleepwalk:** guide him gently back to bed. Don't wake him or shake him, since he may be confused or upset.
- **Make the house safe:** lock outside doors, put a gate at the stairs, and clear the floor of toys.
- **Sleep talk** is just sleep. There's nothing to do.
- **What helps most:** a regular bedtime and enough sleep. Overtired children sleepwalk more.
- **Night terrors versus nightmares:** in a night terror he screams but isn't awake and won't remember it. Stay close, keep him safe, and don't try to wake him.

**Doctor callout (kept and extended).** See a doctor if it happens several times a week, if he hurts himself, if there's jerking or stiffness, or if he snores loudly with pauses in his breathing.

## 6. Additions
- **`sleep_surface`, new checklist item:** "Nests, swings, bouncers and inclined sleepers are not for sleep. Move him to a flat surface once asleep."
- **The library name:** "Lullabies" goes back to "Lullabies and lori". The door comment and the area title say lori again.

## 7. Link fixes (M4 `pageId`, exact ids checked at build)
| Page | From | To |
|---|---|---|
| feeding_to_sleep | the whole Feeding section | Feeding's night-feeds page |
| sids_calmly | the whole Health section | Health's breathing-and-colour red-flag page |
| noisy_breathing | the whole Health section | Health's snoring and breathing page |
| Health, "Gentle settling, in more detail" | Sleep's first tab | Sleep `gentle_settling` |
| swaddling, malish, day_night_confusion | (none) | "In the first weeks" → First 40's swaddle, malish and day-night pages |

## Sources (REQUIRED_REVIEW at build)
- AAP, "Sleep-Related Infant Deaths: Updated 2022 Recommendations" (flat, firm, supine; no inclined sleepers, nests or swings for sleep).
- NHS and Lullaby Trust safer-sleep guidance (room temperature, overheating, bed-sharing harm reduction).
- IAP guidance on infant sleep, and the National Sleep Foundation and AASM sleep-duration ranges by age.
- AAP on parasomnias (sleepwalking, night terrors).
