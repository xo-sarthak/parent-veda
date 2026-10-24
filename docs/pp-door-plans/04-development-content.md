# Door 4: Development, the new page and the additions (DV8)

Written 2026-10-24, ready to go into `pp_development_content.dart` in the build. It uses the same blocks and house rules as the other door content files:
- **Never a diagnosis.** No list on this page is a checklist to score. A doctor callout closes every clinical page.
- **No pitch near the worry.** The new page carries no toy and no class. It has one specialist row, after the doctor callout.
- **REQUIRED_REVIEW** marks every clinical line. A developmental paediatrician or a paediatric physio reads them before release (BEFORE-LAUNCH).
- **Corrected age** for babies born early, under 2 years (DV4). The page says so once.
- English only, no emoji, "your baby" and "he" as the door already uses them.

---

## 1. `dev_movement_signs`: "Movement signs worth showing a doctor"
Area `on_track` · format FLAGGED CALLOUT · bands all · after `dev_worth_checking`
Links: Special care's `sc_help_india` (RBSK and DEIC, M4 pageId; one source); `dev_born_early`
Specialist: paediatric physio row (owed category; S8b → Paediatrician until it exists), after the doctor callout
Product or class: **none**

**Intro.** Babies move in their own time, and the range is wide. A few signs are worth showing a doctor early, not because something is wrong, but because if help is needed, starting sooner makes a real difference. If he was born early, count from his due date, not his birthday.

**Cards, heading "Show your doctor if you notice":** REQUIRED_REVIEW
- **His body feels very stiff, or very floppy.** He stiffens and arches when you pick him up, or slips through your hands like a rag doll.
- **His hands stay tightly fisted after 4 months,** most of the time, even when he is calm.
- **He uses one side much more than the other before his first birthday.** He always reaches with the same hand, or one arm or leg moves much less. Babies don't pick a favourite hand this early.
- **He isn't sitting on his own by 9 months,** or isn't bearing weight on his legs when held standing by 12 months.
- **He isn't walking by 18 months.**
- **He loses a skill he had.** He could roll or sit, and now he can't. This one is worth a doctor this week, at any age.

**Article.**
1. Most babies who are slow on one of these catch up, and many simply move in their own way. The doctor's job is to look properly. Yours is only to notice and mention it. REQUIRED_REVIEW
2. If the doctor wants a closer look, they may ask a paediatric physiotherapist or a developmental paediatrician to see him. Physiotherapy for babies is play: a physio shows you games that help, and you do them at home.
3. Bring a short phone video of what worries you. It shows the doctor in ten seconds what is hard to describe.

**India note.** Under the RBSK programme, District Early Intervention Centres (DEICs) at district hospitals check and support children from birth to 6 years, free. Your paediatrician, ASHA or anganwadi worker can refer you. (Link: "Free help in India" → `sc_help_india`.)

**Doctor callout** (`kind: doctor`). If you have noticed any of these, mention it at the next visit, or book one sooner. If he has lost a skill, see a doctor this week.

**Specialist row** (after the callout): "A paediatric physio can show you games that help · video call". Until the category exists, S8b shows: "We're adding paediatric physios. A paediatrician can check this first." with a **See one** pill.

---

## 2. Addition to `dev_age_1_2` (append to its doctor callout's lead-in, as a new paragraph)
"At 18 and 24 months your doctor may ask a short set of questions about his play, pointing and talking. It is often called M-CHAT. It is a routine check for every child, not a test he can pass or fail, and most children need nothing more." REQUIRED_REVIEW

## 3. `dev_leaps_lens` rewritten as phases (the shipped text is commented out, "kept for revert")
**Title:** "Fussy patches and new skills"
**Intro.** Many parents notice that a few days of clinginess, poor sleep and crying come just before he does something new. ParentVeda shows these as phases on his phase map: a stretch of change, not a fixed date on a calendar.
**Article.**
1. Babies don't follow a timetable. A fussy patch might come a week earlier or later than another baby's, or not show at all, and both are normal.
2. In a fussy patch: more holding, more feeding, an earlier bedtime, and less going out. It passes.
3. If the crying is new and comes with fever, poor feeding, vomiting or a change in how he moves, that's not a phase. See a doctor.
**Link:** "Your child's phases" → `pp_leaps` (the phase map).

---

## Sources (each REQUIRED_REVIEW at build)
- CDC "Learn the Signs. Act Early." milestones (2022 revision), and the AAP developmental surveillance and M-CHAT-R/F at 18 and 24 months.
- IAP guidelines on developmental screening, and the RBSK operational guidelines (DEIC, 0–6 years).
- Early signs of cerebral palsy and motor delay: hand preference before 12 months, persistent fisting, abnormal tone (general paediatric neurology guidance; a reviewer confirms the ages).
