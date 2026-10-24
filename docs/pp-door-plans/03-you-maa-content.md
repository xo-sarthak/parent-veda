# Door 3: You, Maa, the new and deepened pages (decision M7)

Written 2026-10-24, ready to go into `pp_you_maa_content.dart` in the build. It is in two parts:
- **Part A:** 8 new pages, written in full.
- **Part B:** additions to the 11 thin pages. These are blocks to add, not rewrites; the shipped copy stays.

Every page uses the content model's own blocks:
- `PpIntro`
- `PpArticle`
- `PpCards`
- `PpSteps`
- `PpCallout`
- `PpWhenLine`
- `PpIndiaNote`
- `PpLink` (with `pageId` once M4 lands)
- `PpConsult`

House rules held throughout:
- **Never a dose from us.** Contraceptives and tests are named with *who gives them and where*, never an amount or a schedule to follow at home without a doctor.
- **Never a diagnosis.** Every clinical page ends with a doctor callout.
- **Bands measure her, not the baby** (`_b0` 0–6 weeks … `_b3` 6 months+, in weeks after M2).
- **No commerce on a mind or safety page.** `people_safe_at_home` carries no consult and no product. Free help sits above any paid card everywhere (M5).
- **No "bounce back" framing,** no weight talk, no formula promotion (IMS Act).
- **REQUIRED_REVIEW** marks every clinical, legal and scheme line. A gynaecologist reads Part A's clinical pages, and someone checks the scheme and law lines against the current government text before release (BEFORE-LAUNCH).
- English only, no emoji, "you" addressed to her.

---

# Part A: the 8 new pages

## 1. `body_contraception`: "Not ready for another baby yet? Your choices after birth"
Area `your_body` · format ARTICLE · bands all · after `body_when_normal`
Linked from: `people_intimacy`, `people_spacing`, First 40's `f40_pregnant_again` (window)
Consult: Gynaecologist, offer card under the doctor box (M6)
Product: none

**Intro.** You can get pregnant again before your periods come back. Many mothers in India find this out the hard way. You do not have to decide anything today, but it helps to know your choices before you need one.

**Article.**
1. Your body can release an egg about three to six weeks after birth, before you see a single period. If you are not breastfeeding, this can happen even sooner. So "my periods haven't started" does not mean "I can't get pregnant". REQUIRED_REVIEW
2. Breastfeeding protects you, but only under three conditions, all at once. Your baby is under six months. Your baby has nothing but breast milk, day and night, with no long gaps. Your periods have not come back. When any one of these stops being true, the protection stops too. Doctors call this LAM, the lactational amenorrhoea method. REQUIRED_REVIEW
3. Most choices are safe while breastfeeding. The one family to avoid in the first months of feeding is the combined pill, which can reduce milk. Your doctor will steer you. REQUIRED_REVIEW

**Cards, heading "The choices, in plain words" (each one: what it is, how long it lasts):** REQUIRED_REVIEW
- **Copper-T (IUCD).** A small device placed in the uterus by a doctor or trained nurse. It can go in within 48 hours of birth, even during a caesarean (called PPIUCD), or from six weeks after. Lasts 5 or 10 years depending on the type, and comes out whenever you want. Free at government hospitals.
- **Antara, the injection.** One injection every three months, given at a health centre. Safe while breastfeeding, usually from six weeks after birth. Free at government facilities. Periods often become irregular or stop while you use it; that is expected.
- **Chhaya, the non-hormonal pill.** A pill taken twice a week at first and then once a week, as your health worker explains. Safe while breastfeeding. Free at government facilities and through ASHA workers.
- **The progestogen-only pill.** A daily pill made for breastfeeding mothers. It needs to be taken at the same time every day.
- **Condoms.** Work from day one, with no effect on milk. Free through ASHA workers and health centres.
- **Sterilisation.** Permanent. For you, a tubectomy can be done within seven days of birth or from six weeks after. For your husband, a no-scalpel vasectomy is simpler, quicker to recover from and just as effective. Government hospitals do both free, and the scheme pays a small amount towards the cost of the day.

**When-line.** Have this conversation at your six-week check, or before you leave hospital if you already know you want a Copper-T.

**India note.** Your ASHA worker can bring condoms and Chhaya home, and can take you to the health centre for Antara or a Copper-T. Nobody in the family needs to give permission. This is your health and your decision, made with your doctor.

**Doctor callout** (`kind: doctor`). Your doctor will ask about your health, your birth and whether you are feeding before suggesting a choice. If a method doesn't suit you, you can always switch. Go back quickly if you have heavy bleeding, fever or bad belly pain after a Copper-T is placed.

**Offer card.** "Talk it through with a gynaecologist · video call · from ₹900 ($11)" (the lowest fee in `pp_experts_data.dart:297`; the card reads it from the data at build, never typed in). The quiet safety line is not needed here: this is not a symptom page.

---

## 2. `body_after_gdm`: "You had sugar in pregnancy: the test after birth"
Area `your_body` · format ARTICLE · bands `_cleared` (6 weeks on) · after `body_thyroid`
Relevance: lifted when her pregnancy record says gestational diabetes (if the signal exists; check at build, else plain band)
Consult: Gynaecologist (or the adult nutritionist once that category exists, M6)
Product: none

**Intro.** If your sugar was high in pregnancy, it most likely went back to normal the day your baby was born. One test, a few weeks from now, tells you whether it really did. It is the most skipped test after birth in India, and one of the most useful.

**Article.**
1. Diabetes in pregnancy (gestational diabetes, GDM) usually goes away after birth. But it is a signal: women who had it are much more likely to develop type 2 diabetes in the years after, and Indian women carry a higher risk than most. REQUIRED_REVIEW
2. The test is a two-hour sugar test (a glucose tolerance test), done six to twelve weeks after birth. You drink a sweet drink and give blood twice. A fasting sugar alone can miss it. REQUIRED_REVIEW
3. If the result is normal, a sugar test once a year (or as your doctor says) is enough. If it is not, catching it now means simple changes can make a big difference. REQUIRED_REVIEW
4. Breastfeeding for longer, moving every day and eating regular meals all lower the risk. None of this is about losing weight; it is about how your body handles sugar.

**When-line.** Six to twelve weeks after birth, then once a year.

**India note.** The test is available at government hospitals and most labs. Ask for it by name ("a glucose tolerance test after GDM"), because it often isn't offered unless you ask.

**Doctor callout.** Book the test with your doctor and take your pregnancy reports along. If you are very thirsty, passing a lot of urine or very tired in a way that doesn't lift, tell them sooner.

---

## 3. `body_after_bp`: "High BP in pregnancy: what to watch after birth"
Area `your_body` · format ARTICLE · bands all · after `body_after_gdm`
Placement: the warning cards are the go-now part, so **the consult goes after them** (the Health §3a pattern for `fever_red_flags`). The card reads "Not on this list, still worried?"
Consult: Gynaecologist, after the warning cards, with the quiet safety line
Product: a home BP monitor (owed; listed in DOOR-CONTENT-OWED), at the foot only and never next to the warning cards

**Intro.** High blood pressure in pregnancy, or pre-eclampsia, does not always end with the birth. It can rise again, or appear for the first time, in the first weeks after. Most mothers are fine. Knowing the signs makes sure you are one of them.

**Article.**
1. Blood pressure is often highest three to six days after birth. Pre-eclampsia can appear up to six weeks after birth, even in a mother whose pregnancy BP was normal. REQUIRED_REVIEW
2. If you had high BP, get it checked within the first week after you go home, and again at your six-week visit. Do not stop or change a BP medicine on your own. Your doctor adjusts it as your body settles. REQUIRED_REVIEW
3. High BP in pregnancy is also an early warning for your heart years later. A BP check once a year from now on is a small habit worth keeping. REQUIRED_REVIEW

**Cards, heading "Go to hospital today if you have any of these":** REQUIRED_REVIEW
- **A bad headache** that doesn't go with rest or a painkiller
- **Blurred vision**, flashing lights or spots
- **Pain under your ribs on the right**, or in the upper belly
- **Sudden swelling** of the face, hands or feet
- **Breathlessness**, or a racing heart
- **A fit**, or feeling confused (call 108 or 112)

**When-line.** Most important in the first six weeks. Then once a year.

**India note.** Government health centres and ASHA workers can check your BP free at home or nearby. If you have a home BP machine, write the readings down with the date and take them to your visit.

**Doctor callout.** If you had pre-eclampsia, ask your doctor what BP reading should make you call, and save that number in your phone.

---

## 4. `body_screening`: "Three checks for you, not the baby"
Area `your_body` · format CARDS · bands `_cleared` · after `body_after_bp`
Consult: Gynaecologist
Product: none

**Intro.** In the year after a baby, every check-up is about the baby. These three are about you. Each takes a few minutes and can be done at your six-week visit or soon after.

**Cards:** REQUIRED_REVIEW
- **Your haemoglobin (Hb).** Many Indian mothers are anaemic after birth, especially after heavy bleeding. Tiredness, breathlessness on the stairs and hair fall can all be anaemia. One blood test tells you. If it is low, your doctor decides the iron.
- **A cervical screening test (Pap smear or VIA).** It checks for early changes in the cervix that can be treated long before they become cancer. Recommended every few years from your late twenties or thirty onwards. Usually done from about three months after birth, once things have healed. Government health centres offer VIA screening free to women from 30.
- **Breast awareness.** Feeding breasts are lumpy and change daily, which makes a new lump easy to dismiss. Get to know how yours usually feel. A lump that is still there after a feed, and after a week, needs a doctor to see it. Most are blocked ducts or milk cysts; the check is still worth it.

**When-line.** Hb at your six-week visit. Cervical screening from about three months after birth if it is due. Breast awareness always.

**India note.** These checks are part of the free NCD screening at government health centres and Ayushman Arogya Mandirs for women over 30. Ask the ASHA or ANM when the next screening day is.

**Doctor callout.** Ask your doctor at the six-week visit which of these are due for you.

---

## 5. `people_partner_low`: "When he is struggling too"
Area `people_around_you` · format ARTICLE · bands all · after `people_partner`
Consult: Maternal mental health (a counsellor sees couples and fathers too), after the free line
Product: none

**Intro.** Fathers can get depressed after a baby too. About one in ten do, and it is even less likely to be named in an Indian home than hers. If he seems far away, angry or always out, this may be part of it.

**Article.**
1. Fathers' low mood often shows up differently. Less crying, more irritability, working late, drinking more, going quiet, or being on the phone all evening. It often begins a few months in, and it is more likely if the mother is struggling too. REQUIRED_REVIEW
2. It is not a competition about who has it harder. Two tired people who both feel unseen can quietly blame each other. Naming it ("I think we are both not okay") often helps more than an argument about who does what.
3. Help is the same kind of help: talking to someone, sleep, time outside, and a doctor if it lasts more than two weeks.

**Steps, heading "Something to try this week":**
- **Pick a calm time, not 2am.** Say what you see, not what he is doing wrong.
- **Give him one job that is fully his,** like the bath or the evening walk with the baby. Fathers who have a job of their own often feel less shut out.
- **Each of you gets one stretch of sleep,** in turns, protected by the other.
- **Point him to the same free help** you would use.

**India note.** Tele-MANAS (14416) is for him too. It is free, any time, in Indian languages, and nobody needs to know he called.

**Free line, above any card.** If either of you has thoughts of not wanting to be here, call Tele-MANAS on 14416 today.

**Doctor callout** (`kind: doctor`). If his mood has been low for more than two weeks, or he is drinking to cope, his own doctor is the right first step.

---

## 6. `people_safe_at_home`: "If you are not safe at home"
Area `people_around_you` · format ROUTE · bands all · after `people_saying_no`
**No consult, no product, no class** (M5 and the house rule). It also appears in the `circle_safe` links.

**Intro.** Pregnancy and the first year after birth are when violence at home often begins or gets worse. If someone in your home hurts you, threatens you, controls your money or your phone, or stops you from seeing your family or a doctor, it is not your fault, and you do not have to keep it secret.

**Cards, heading "Help you can reach today":** REQUIRED_REVIEW
- **181, the Women Helpline.** Free, any hour. They listen, and can connect you to the police, a shelter, legal help or counselling.
- **112, emergency.** If you are in danger right now.
- **One Stop Centre (Sakhi).** In every district: medical help, police help, legal advice and a safe place to stay for a few days, all in one place. 181 can tell you the nearest one.
- **The law is on your side.** The Protection of Women from Domestic Violence Act covers violence from a husband and from his family, including in-laws. It includes the right to stay in your shared home.

**Steps, heading "If you are not ready to leave":**
- **Keep a few things in one place:** your Aadhaar, some money, your phone charger, the baby's papers.
- **Save one number under an ordinary name.**
- **Tell one person you trust** what is happening.
- **Know which room has a way out,** and stay away from the kitchen in an argument.

**India note.** Your doctor, nurse or ASHA worker can help quietly. You can tell them during a check-up when no one else is in the room.

**Callout** (`kind: safety`). If you or your baby are in danger right now, call 112.

---

## 7. `people_spacing`: "The next baby, when you are ready"
Area `people_around_you` · format ARTICLE · bands `_later` (3 months on) · after `people_intimacy`
Links: `body_contraception` (pageId); the TTC stage, as text only ("when you start trying, ParentVeda has a whole part for that"). No stage switch from here.
Consult: Gynaecologist
Product: none

**Intro.** Sooner or later, someone will ask when the next one is coming. The answer is yours to give, and there is no right one. Here is what helps you decide, and what helps your body.

**Article.**
1. Doctors suggest waiting at least two years from this birth before the next pregnancy, so about 33 months between the two births. A shorter gap is linked with more anaemia, early birth and small babies, because your body has not finished refilling its stores of iron and folate. REQUIRED_REVIEW
2. After a caesarean, the gap matters more, because it gives the scar time to become strong. Ask your doctor what they suggest for you. REQUIRED_REVIEW
3. If you are older or worried about time, say so to your doctor. The advice can change for you, and that is a conversation, not a rule.
4. Whenever you start trying, start folic acid three months before, as your doctor advises.

**India note.** Spacing is a choice you make with your husband, not for the family. If you are being pressured for a son or for another baby soon, that pressure is something you can name to your doctor.

**Doctor callout.** Before you try again, a check-up looks at your Hb, sugar, BP, thyroid and scar, so your next pregnancy starts on the strongest footing.

---

## 8. `work_schemes`: "Money the government gives mothers"
Area `back_to_work` · format CARDS · bands all (overrides the area's `_cleared` band, because the scheme deadlines start at birth)
Links: `work_your_entitlement` (the Maternity Benefit Act stays there, one source); the Papers and money door
Consult: none. Product: none.

**Intro.** Two government schemes pay mothers directly, and many families never claim them. They don't depend on your job.

**Cards:** REQUIRED_REVIEW (amounts and rules change; checked against the current scheme guidelines before release)
- **Pradhan Mantri Matru Vandana Yojana (PMMVY).** ₹5,000 for your first child, paid into your bank account. For a second child, ₹6,000 if the baby is a girl, paid after the birth. Register through your anganwadi worker, ASHA or the PMMVY website. You need Aadhaar, a bank account, and the MCP card from your pregnancy visits.
- **Janani Suraksha Yojana (JSY).** A cash amount for giving birth in a government or accredited hospital. It is bigger in some states and in rural areas. It is usually paid at or soon after discharge. Ask the hospital or your ASHA if you have not received it.
- **Your state's own scheme.** Many states add their own payment or kit for mothers or girl children. Your anganwadi worker knows yours.
- **Maternity leave and pay from your employer** are a separate thing, by law (see "What you are entitled to").

**When-line.** PMMVY registration is best done in pregnancy, but it can still be done after the birth. Ask now if you haven't.

**India note.** The anganwadi worker in your area is the person who files these. Visiting with your documents is often faster than doing it online.

---

# Part B: the 11 thin pages, what to add

Each of these blocks is **added** to the existing page. Nothing shipped is removed (comment out, never delete).

## `body_afterpains` (b0)
- **India note:** "Older women at home may give ajwain water or a hot drink for the cramps. A warm drink is fine. If anyone suggests a tight belt or binding to 'push the womb back', it doesn't make the uterus shrink faster."
- **Link** (pageId): `body_red_flags`, "Signs after birth that mean go now".
- The existing doctor callout stays as the last block.

## `body_thyroid` (b1–b3)
- **When-line:** "The overactive phase usually comes one to four months after birth; the underactive phase four to eight months after." REQUIRED_REVIEW
- **India note:** "Thyroid problems are common in Indian women. A TSH test costs little at most labs and is free at many government hospitals."
- **Offer card:** Gynaecologist (M6), under the doctor callout.

## `mind_birth_trauma` (all bands)
- **Article,** after the cards: "Up to one in three mothers describe their birth as traumatic. A smaller number go on to have symptoms that last. It is not about how the birth 'should' have gone: two mothers can have the same birth and feel completely differently about it." REQUIRED_REVIEW
- **India note:** "Families often say 'the baby is healthy, forget it'. You are allowed to not forget it yet. Asking the hospital for your notes is your right."
- **Order (M5):** the existing Tele-MANAS callout moves **above** a new counsellor offer card ("Talk to a perinatal counsellor about the birth"). That card is the first paid card on this page, placed below the free line.

## `people_separated` (all bands)
- **Steps,** heading "If you are bringing up your baby on your own, from the start":
  - **Let one person be your back-up,** for nights you are ill.
  - **Make the birth certificate correct early;** the father's name can be added later through the registrar.
  - **Know that maintenance for you and the child is a legal right,** and free legal aid exists (NALSA, 15100). REQUIRED_REVIEW
- **Link:** `people_safe_at_home` (pageId).
- Its bands stay all. Its existing 181 callout stays.

## `cani_caffeine`
- **India note:** "A cup of masala chai has less caffeine than a cup of filter coffee. Strong 'kadak' chai brewed long has more."
- **When-line:** "Newborns clear caffeine slowly; by three to six months most babies are not bothered."

## `cani_alcohol`
- **India note:** "Ayurvedic tonics and some 'jaapa' preparations made with alcohol count as alcohol too."
- Its existing doctor callout stays.

## `cani_medicines`
- **Link** (pageId): `body_contraception`, "Contraception that is safe while feeding".
- Add one card under "Ask first, or avoid": **"Weight-loss and 'fat-burner' pills: not while feeding."**

## `cani_when_sick`
- **When-line:** "Most illnesses: keep feeding through them. Stomach bugs: drink extra; your milk is fine."
- **India note:** "Dengue, typhoid and malaria are not reasons to stop feeding. Ask your doctor about the medicines."

## `cani_fasting`
- **India note:** "Many priests and maulvis will tell you breastfeeding mothers are exempt. If you are being pressured to keep a waterless fast, you can say your doctor has advised against it." REQUIRED_REVIEW

## `cani_scans_beauty`
- **Doctor callout:** "Tell anyone giving you a scan, a treatment or a beauty procedure that you are breastfeeding, and ask if they recommend anything different."

## `cani_travel`
- **India note:** "Indian Railways and most airports now have feeding rooms. You can ask the station master or airport staff."
- **Card:** "Your own milk and medicines in hand luggage: allowed on flights; tell security."
- **Callout:** "Under six weeks, check with your doctor before a long journey, and after a caesarean before a long drive."

---

# Placement table

| Page | Area | After | Bands | Pitch |
|---|---|---|---|---|
| `body_contraception` | your_body | `body_when_normal` | all | Gynaecologist |
| `body_after_gdm` | your_body | `body_thyroid` | b1–b3 | Gynaecologist |
| `body_after_bp` | your_body | `body_after_gdm` | all | Gynaecologist, after the go-now cards |
| `body_screening` | your_body | `body_after_bp` | b1–b3 | Gynaecologist |
| `people_partner_low` | people_around_you | `people_partner` | all | Counsellor, below the free line |
| `people_safe_at_home` | people_around_you | `people_saying_no` | all | **none** |
| `people_spacing` | people_around_you | `people_intimacy` | b2–b3 | Gynaecologist |
| `work_schemes` | back_to_work | `work_your_entitlement` | all | none |

Body's age shelf (plan §3) adds:
- `body_contraception` to the 6 weeks–3 months shelf
- `body_after_gdm` and `body_screening` to the 6 weeks–3 months and 3–6 months shelves
- `body_after_bp` to the 0–6 weeks shelf

The shelves keep at most 6 cards; the area rail carries the rest.

# Sources (each line REQUIRED_REVIEW at build; secondary sources marked)
- MoHFW Family Planning Division: Reference Manual for IUCD (PPIUCD timing, Cu 380A / Cu 375); Antara (DMPA) and Chhaya (centchroman) under the national programme; sterilisation timing and the compensation scheme.
- WHO Medical Eligibility Criteria for Contraceptive Use (combined pill while breastfeeding; progestogen-only methods).
- WHO: LAM's three conditions; birth spacing (24 months from birth to next pregnancy).
- MoHFW / DIPSI national guidelines on GDM (the 75 g OGTT at 6–12 weeks after birth); ADA (secondary, for the timing window).
- ACOG Committee Opinion on postpartum hypertension (BP check timing; postpartum pre-eclampsia up to 6 weeks).
- MoHFW NP-NCD operational guidelines (VIA screening for women 30–65 at government facilities).
- Paternal postnatal depression prevalence (meta-analysis, about 8–10%; secondary, check the figure).
- Ministry of Women and Child Development: Women Helpline 181, One Stop Centres (Sakhi); the Protection of Women from Domestic Violence Act, 2005.
- PMMVY guidelines (2022 revision: ₹5,000 first child, ₹6,000 second girl child); JSY guidelines. Amounts change; check the current ones.
- NALSA legal aid helpline 15100. Tele-MANAS 14416.
