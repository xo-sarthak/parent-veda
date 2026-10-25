# Door 6: First 40 Days, the new copy (FD3, FD4, FD6, FD7, FD8)

Written 2026-10-24, ready to go into `pp_first40_content.dart` (and `pp_din_by_din.dart` for the Day card) at build, if the user says yes. The house rules are the section's own:
- Reassurance first, instruction second.
- Myth versus evidence, never tradition versus science.
- No product near a red-flag page.
- No "you missed a day".
- English only, no emoji.
- Every clinical or legal line is REQUIRED_REVIEW: a paediatrician or midwife checks clinical lines, and the scheme amounts are checked against the current government pages before release.

---

## 1. Day card with no birth date (FD7), `pp_din_by_din.dart`
When the child profile has no saved date of birth, the Day card shows:

> **Your forty days start the day he's born.**
> Tell us his birthday and this page follows you day by day.
> [ Add his birthday ]

The button opens the child profile's birthday field. The day line, the "Day N of 40" count and the week shelf (FD1) appear once the date is saved. Everything else on the door stays readable.

## 2. The line after day 40 (FD3), above `forty_mark`
> **Your forty days are done.** What comes next lives in three places: **Feeding**, **Sleep** and **Development**. Your own recovery carries on, on the Your recovery tab.

The three names are links to those doors (their opening tab, by his age).

## 3. `not_yourself`: free help first (FD4), placed before the existing "Find help" link
> **Free, any hour: Tele-MANAS, 14416.** The government's mental health line. Trained counsellors, in your language, free. You can call for yourself, or someone can call for you. REQUIRED_REVIEW

Link: "Baby blues or something more?" → You, Maa's `mind_blues_vs_ppd`. The page carries no paid block, as decided (`:2830`).

## 4. `course`, rewritten to the real class (FD6)
The shipped text is commented out, "kept for revert". It promised Rs 1,499 (usually 2,999), Hindi and English, and a free first lesson, none of which is true of `mc_first40`.

> **The first forty days, as a short class.** An 80-minute recorded masterclass: feeding, sleep, the cord, the bath, your own recovery, and the signs that need a doctor, from people who do this every day. ₹1,199 ($14). Opening soon.

The link goes to `mc_first40` by its id. While it's in opening-soon, a tap shows the existing opening-soon page, or the S8d message "This class isn't open yet", with a **Tell me** button.

## 5. New cards (FD8)

### `days_1_7`, new card: "His first vaccines"
REQUIRED_REVIEW. Three vaccines are given at birth, usually before you leave hospital: **BCG** (in the left upper arm; a small bump and later a tiny scar is normal), **OPV-0** (polio drops by mouth) and **Hepatitis B** (an injection in the thigh). Check his card says all three. If you delivered at home or left early, any government health centre gives them free. The next ones are at 6 weeks.
Link: "His vaccine schedule" → the vaccine tool.

### `days_8_15`, new card: "Register his birth"
REQUIRED_REVIEW (legal). A birth must be registered within **21 days**. It's free in that time. Most hospitals register it for you. Ask before discharge, and ask when the certificate will be ready. If he was born at home, the family registers it at the municipality or gram panchayat office. You'll need the certificate for his Aadhaar, passport and school admission, so keep a few copies.
Link: "Papers for your baby" → the Papers door.

### `rest_and_food`, new card: "Money you may be owed"
REQUIRED_REVIEW (amounts and eligibility checked before release).
- **JSY (Janani Suraksha Yojana):** a cash amount for a delivery in a government or accredited hospital, larger in some states. Your ASHA can help you claim it.
- **JSSK (Janani Shishu Suraksha Karyakram):** free delivery, medicines, food, tests and transport in government hospitals, and free care for the baby in his first year.
- **PMMVY (Pradhan Mantri Matru Vandana Yojana):** money paid to your bank account for your first child, and for a second child if she is a girl, after registration and his birth vaccines.

Link: "How to claim, step by step" → the Papers door.

### `after_csection` and `rest_and_food`, new card: "The old rules for you"
Myth versus evidence, never mocking. REQUIRED_REVIEW.
- **"No cold water, no washing your hair for forty days."** A warm bath or wash is safe once you feel steady on your feet, after a normal delivery or a C-section. Keep a C-section wound dry and pat it gently. Warm water is comfort, not a rule.
- **"Tie your belly tight with a belt or a cloth."** A soft binder can make moving feel easier after a C-section, and some women like it. It doesn't flatten the tummy or close the muscles, and tight binding for long hours isn't helpful. Ask your doctor first after a C-section.
- **"Stay in bed for forty days."** Rest is treatment, but short walks around the house from the first days help prevent clots and constipation. Lie down as much as you need, and get up a little each day.
- **"Only certain foods, no water."** Jaapa foods like gond, ajwain and ghee are fine in sensible amounts. Drink water freely, especially while feeding.

## 6. "As he grows" links (FD4), one line at the foot of each page
| First 40 page | Link text | Target |
|---|---|---|
| jaundice | Jaundice after the first weeks | Health `ill_jaundice` |
| latch | Feeding as he grows | Feeding `bf_latch` |
| swaddle | When to stop swaddling | Sleep's swaddling page |
| malish | Malish after the first month | Sleep's `malish` |
| folk_practices | More family customs, checked | Traditions `newborn_customs` |
| ceremonies | Chhathi and naamkaran | Traditions `chatti`, `namkaran` |
| safe_sleep, day_night, newborn_sleep | The full safe-sleep guide | Sleep's safe-sleep page (replaces the tracker link) |

## Sources (REQUIRED_REVIEW at build)
- MoHFW Universal Immunisation Programme schedule (birth doses).
- Registration of Births and Deaths Act, 1969, as amended 2023 (21-day window).
- NHM guidelines for JSY and JSSK; Ministry of Women and Child Development, PMMVY guidelines (PMMVY 2.0).
- Tele-MANAS, MoHFW (14416).
- RCOG/NICE postnatal care guidance (mobility, bathing, wound care after a caesarean).

## The demand re-check (2026-10-25)
Every line here is REQUIRED_REVIEW by the paediatrician who reviews this door.

### R1. `f40_nappy_poop`, a new part: "After the first weeks, and after solids" (FD13, Potty PT11, Health H8)
Bands: 0–12 months.
- **Colours:**
  - yellow, green and brown are all normal
  - green often just means faster digestion, or iron
- **How often:**
  - breastfed babies may poo after every feed, or, after about six weeks, only once in several days
  - both can be normal if he's feeding well, gaining weight and the poo is soft
- **After solids:**
  - poo gets thicker, browner and smellier
  - bits of food in it are normal
- **Watery and frequent:** many more poos than usual, or very watery, is diarrhoea. Watch for fewer wet nappies. Link: Health's diarrhoea and ORS page.
- **Call the doctor the same day for:**
  - red or bloody poo
  - black poo after the first few days
  - white, grey or very pale poo
  - a hard, swollen tummy with vomiting

### R2. A Day by day card: "What he can see" (FD11)
Bands: weeks 1–6.
- He sees best at about 20 to 30 cm, the distance to your face while he feeds.
- Faces and bold black-and-white shapes hold his eyes first. Colours come over the next few months.
- Eyes that wander or cross now and then are normal in the first weeks.
- **See a doctor if:**
  - one eye turns in or out all the time after 3 to 4 months
  - a pupil looks white in photos or in light
  - he doesn't look at your face at all by about 2 months

### R3. The oil, one source (FD12)
- **`f40_which_oil`, the mustard row's "Watch out for":** "Best kept off a newborn's skin: it can irritate it and weaken its barrier in the first weeks. Many families keep it for the mother's massage." This matches Traditions TR3. The old text is commented out, "kept for revert".
- **The coconut row** stays "the safest default". A sunflower row is added: "Plain, cold-pressed, fragrance-free. Studies found it gentle on newborn skin."
- **The FD5 toast** becomes: "We haven't picked oils yet. A plain, fragrance-free coconut or sunflower oil from your kitchen is fine. See 'Which massage oil?'."
- **Traditions TR3's** "Malish and the oil" keeps its short version and links "Which massage oil?" → `f40_which_oil` (note in `10-traditions-content.md` §2).
