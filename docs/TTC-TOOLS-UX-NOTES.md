# TTC tools: how each could be simpler (notes only, nothing changed)

Kept alongside the TTC warmth pass (`docs/TTC-WARMTH-PASS.md`). The user, 2026-09-25: tools are not just text. For
every tool, note how it could be simpler, more usable and easier to understand for someone new to trying to
conceive. **No tool behaviour was changed in the warmth pass**; only the words were rewritten. Everything below is
for a later decision.

Written 2026-09-26 by the warmth-pass helpers, one per area, each reading the tool's screen code from a first-time
user's point of view; merged and summarised by the lead. 43 tools covered.

## How these notes were made, and what has not been checked yet

- **Every note comes from reading the code, not from using the tool on a phone.** None of the 43 tools has
  been walked on a device since the warmth pass (the user, 2026-09-26: phone check not possible right now). A
  phone walk may confirm, soften or overturn some of these, especially the layout and "hard to find" points.
- **Nothing here has been fixed.** The user's decision, 2026-09-26: keep the tools as they are for now and keep
  this document current, so the list is ready to decide on at the end. When a tool changes, update its entry.
- **Coverage:** all 28 tools on the original TTC inventory list are covered, plus 15 more screens that behave
  like tools (the tools hub, journey map, timeline, infographic reader, More, first-run setup, mood faces,
  ritual, care circle, chapter screen, practice player, generic tracker screen, clinic dates on the calendar,
  records PDF, partner Today).
- **One behaviour that is deliberate, now explained in the words:** the fertile window tool shades seven days
  (five before ovulation, ovulation day, and the day after). The medical window is six days ending on
  ovulation day; the seventh is a margin because our ovulation date is an estimate. Since 2026-09-26 every
  explanation says exactly that, so the words and the shaded days agree.

## Start here: the problems that are more than wording

These came up while reading the code. They are real behaviour issues, not tone, so they are listed first.

1. **Trigger shot reminder** (treatment tracker). The screen promised a reminder "two hours before"; the app
   actually schedules one at 4 hours and one at 15 minutes before. *The words were corrected in the pass to say
   what the app does.* Separately: if she closes the time picker without choosing, the app still saves 9:00 pm and
   schedules reminders for it.
2. **Two symptom loggers write to the same saved slots.** Tools, Symptom Companion opens the old 0 to 4 scale
   tracker, which writes the same keys (`symptoms/cramping`…) as the chip logger, where a tap is stored as 1. Each
   can overwrite or misread the other's day. Worth a code check before acting.
3. **Vaccines: "Had it" always saves today's date**, so the "clear to try from" date can be wrong for a jab she
   had earlier.
4. **Records: the Save button silently does nothing** when there is no photo and no test name (`_canSave ? _save
   : () {}`), which feels broken.
5. **Supplements:** the empty screen says "Add what you take", but she cannot type her own supplement; and
   because "already added" matches by name, once she adds CoQ10 her partner cannot add his.
6. **Products pages show made-up scores, percentages, stars and reviews, plus "VERIFIED" and "BESTSELLER"
   badges** nobody has checked. An honesty problem on a money page.
7. **First-run language button** offers "हिन्दी" in Devanagari, but choosing it switches TTC to Hindi in Latin
   letters. What she picks is not what she gets.
8. **Duplicated tools:** two PCOS tools (PCOS check, Where do I stand) that cover the same ground and look nothing
   alike; "Should I seek fertility help?" and "Should I get help?" (IVF readiness) are near-duplicates. The IVF
   readiness result leads with the paid consult.
9. **Journal:** tapping an entry only offers to delete it, and the prompt card cannot be tapped.
10. **The fertile window tool has three names** (tile, back bar, page title), and when no estimate is shown it is
    a dead end with no next step.
11. **Ritual:** the "0/5" counter works against the stage's no-score promise, and the store still computes a
    streak.
12. **Smaller:** Care Circle "add" buttons only say "coming soon"; `TtcHabitsScreen` lists retired tracker ids
    (unreachable today); `TtcTreatmentCycle.setClinic` is never called; empty time pickers in the Garbh course
    open at 23:00 even for "Wake"; the practice player only advances on tap.

## Every tool by priority

| Priority | Tool | Area | Why |
|---|---|---|---|
| High | Your best days / Fertility Window | Fertile window and chapters | It's the first tool on the first door, it's opened every month, and the naming mismatch and withheld-estimate dead end are the moments where a first-time user most often gives up. |
| High | Read your semen report | His side | It's the one tool in the stage that reads a medical result back to a worried man; a unit or label mix-up could show "below the line" for a normal result, and the length makes drop-off likely. |
| High | Tools (the tools hub) | Home, tools hub and first run | It's the second biggest screen in the stage and the first place a new user goes to "do something". |
| High | First-run setup (TTC intro flow) | Home, tools hub and first run | It's the first thing every new TTC user sees, and the language mismatch is a real bug in what she's promised. |
| High | Your treatment cycle (the IVF / IUI dates tracker) | IVF and IUI treatment | The reminder mismatch and the silent 9pm default both touch the trigger shot, the one moment the app says timing is exact. |
| High | Our journal | Mind, mood, ritual, journal, care circle | Tap-to-delete on precious entries and the non-tappable prompt are real friction for a first-time writer. |
| High | Vaccinations before trying | Partner, tests, vaccines, supplements, medication, appointments | for the "Had it" date (it can give a wrong wait date); Medium for the rest. |
| High | Supplements log | Partner, tests, vaccines, supplements, medication, appointments | The empty state promises free entry that doesn't exist, and the CoQ10 clash blocks his half. |
| High | Products: research page and shelf | Programmes, courses, practice, nutrition, products | The seed numbers and unverified badges are an honesty problem on a money page, in a stage built on never inventing numbers. |
| High | PCOS check | Self-checks and assessments | Two PCOS tools that disagree in length and look is the most visible confusion in this batch, and PCOS is one of the most-visited topics. |
| High | Should I seek fertility help? | Self-checks and assessments | Two near-identical tools for the same worry is confusing, and the sensitive questions need a softer way in. |
| High | Should I get help? (IVF readiness) | Self-checks and assessments | for the same duplication reason, and because the paid action leads on a result that is meant to be neutral. |
| High | Cycle Companion | Trackers: cycle, symptoms, reports, records | It is the base for every date in the stage, and correcting a date is hidden. |
| High | Symptom log and Edit categories | Trackers: cycle, symptoms, reports, records | It is the most-used logging screen and the "did it save" doubt is the biggest risk. |
| High | Generic tracker screen (Symptom Companion, Weight, Mood, Partner Health) | Trackers: cycle, symptoms, reports, records | Two loggers writing the same keys with different meanings is a data problem, not just a wording one (worth a code check before acting on it). |
| High | Health records and PDF export | Trackers: cycle, symptoms, reports, records | Wrong grouping or wrong owner makes the doctor view misleading, and the dead Save tap feels broken. |
| Medium | Your chapter | Fertile window and chapters | It's reading, not data entry, so nothing breaks, but the hidden doctor card and the unexplained chapter names are real comprehension gaps on a clinically reviewed surface. |
| Medium | Journey Map | Home, tools hub and first run | It's helpful for orientation but not something she needs to use daily. |
| Medium | Clinic dates on the calendar | IVF and IUI treatment | It works, but the calendar and the tracker don't point at each other, so a first-time user may never connect them. |
| Medium | Mind & body "Today" | Mind, mood, ritual, journal, care circle | It works and is calm, but the first visit leaves her guessing what happens on tap and why the ticks exist. |
| Medium | Your daily ritual | Mind, mood, ritual, journal, care circle | The counter is the main clash with the stage's tone. |
| Medium | Your Care Circle | Mind, mood, ritual, journal, care circle | Low traffic, but the dead plus buttons and missing invite are easy fixes. |
| Medium | Partner Today, his side | Partner, tests, vaccines, supplements, medication, appointments | The content is good and warm; the gap is that he is given ninety-day tasks with no way to keep them. |
| Medium | Can I...? | Partner, tests, vaccines, supplements, medication, appointments | Search misses are the most likely frustration; the dead-end promise is a small honesty fix. |
| Medium | Medical tests (test library) | Partner, tests, vaccines, supplements, medication, appointments | Clear content; the missing link to Records is the main gap. |
| Medium | Your medication | Partner, tests, vaccines, supplements, medication, appointments | The reminder that never stops is the real problem during a treatment cycle. |
| Medium | Appointments | Partner, tests, vaccines, supplements, medication, appointments | Works, but a changed appointment (common in treatment) is awkward. |
| Medium | Courses and programmes (Prepare) | Programmes, courses, practice, nutrition, products | It is the stage's commerce surface and the titles cost clicks, but nothing here is unsafe. |
| Medium | Preconception garbh sanskar course | Programmes, courses, practice, nutrition, products | The default wake/breakfast time of 23:00 is a small real friction on the one screen that writes into Today. The long scrolls matter because this is the free course meant to bring people in. |
| Medium | Practice player | Programmes, courses, practice, nutrition, products | The practices work, but following steps hands-free is the core job of this screen and it currently needs repeated tapping. |
| Medium | Records PDF export (the printed summary) | Records PDF | It works and is honest, but it is the thing a doctor sees, and small gaps (no names, missing files) cost a real conversation. |
| Medium | Pre-pregnancy checklist | Self-checks and assessments | It works and is safe, but 21 items behind two levels of taps is the kind of list people abandon. |
| Medium | Where do I stand (PCOS self-read) | Self-checks and assessments | It's the gentler of the two PCOS tools and already short; the main gap is a result that only offers a paid step. |
| Medium | BMI calculator | Self-checks and assessments | The maths and wording are careful; the length and the easy-to-miss save are the problems. |
| Medium | Cycle calendar | Trackers: cycle, symptoms, reports, records | It works once data exists, but the empty first visit is a dead end. |
| Medium | Weight and morning temperature cards  (inside `lib/screens/ttc/ttc_symptom_log_screen.dart`) | Trackers: cycle, symptoms, reports, records | Temperature data is only useful if taken the right way, and nothing tells her how. |
| Medium | Cycle report | Trackers: cycle, symptoms, reports, records | It's the page she might show a doctor, but it's reached only from the logger and the companion. |
| Medium | What you're working on (habits tracker) | Trackers: cycle, symptoms, reports, records | Useful and calm, but long; the dead screen is a Low code issue. |
| Low | Family Timeline | Home, tools hub and first run | Nice to have, and not a daily screen. |
| Low | Infographic reader | Home, tools hub and first run | It's a reading format, and the content still gets across. |
| Low | More | Home, tools hub and first run | It works; it's a tidy-up. |
| Low | Mood faces | Mind, mood, ritual, journal, care circle | Cosmetic, except the missing accessibility label, which is a quick win. |
| Low | Nutrition Planner | Programmes, courses, practice, nutrition, products | It's harmless and honest, but a first-time user will expect a planner and find a read-only list. |

## The notes, area by area

## Home, tools hub and first run

### Tools (the tools hub)  (`lib/screens/ttc/ttc_tools_screen.dart`)
- **What it's for:** One place that lists every TTC tracker, checker and planner, grouped as Your body, What you're working on, Both of you, Care and medicines, Plan and learn.
- **What a first-time user meets:** A heading ("Tools that help, never judge"), one line listing seven things, then about 25 two-column tiles in five groups. Each tile has an icon, a name, a short line under it and "Open". Nothing asks her to enter anything here.
- **What's hard or confusing:**
  - Too many tiles at once for someone who just arrived. There is no "start here", so she can't tell which one or two matter on day one (the cycle and the period date).
  - Names mix styles: "Cycle Companion", "Ovulation Companion", "Symptom Companion" (brand-ish), "Fertility Window" (title case), plain words like "Mood", and "Can I...?". Companion vs tracker vs checker isn't explained.
  - Near-duplicates are hard to tell apart without opening them: Supplements vs Medication, Records & reports vs Medical Tests, Nutrition Planner vs Eating for fertility (elsewhere), Journey Map vs Family Timeline (the timeline is only reachable from inside the map).
  - "Worth knowing about" is a products list, but the name doesn't say so.
  - The line under a tile disappears once she has used it (replaced by "3 days logged"), so the explanation is gone exactly when a second visit might need it.
  - The tile text is 10.5 pt and cut at two lines; some descriptions get truncated on small phones.
- **Ideas to make it simpler:**
  - Put a small "Start here" row at the top with two tiles (Cycle Companion, add your period date) until a period is logged. It gives a clear first step without hiding anything.
  - Name tiles by what she does: "Track my cycle", "Check for ovulation", "Log symptoms". Plain verbs beat the Companion branding for a first visit.
  - Rename "Worth knowing about" to "Things people buy (and skip)" so she knows it's the product guide.
  - Keep the description under the name, and show the logged count as a small badge instead of replacing it.
  - Add a one-line "What's the difference?" note in Care and medicines: supplements are what you choose to take; medication is what your clinic prescribed.
- **Priority guess:** High. It's the second biggest screen in the stage and the first place a new user goes to "do something".

### Journey Map  (`lib/screens/ttc/ttc_journey_map_screen.dart`)
- **What it's for:** Shows the five chapters of trying to conceive, where she is now, the milestones she's reached and the ones ahead, and links to the Family Timeline.
- **What a first-time user meets:** A short intro, then a vertical line of five chapter cards with the current one marked "You are here", some marked "Comes round each cycle", then "What you've done" with a count, "Still ahead", and a Family Timeline card at the bottom.
- **What's hard or confusing:**
  - "Chapter" is our word, not hers. She isn't told how she moves from one chapter to the next, or that it happens by itself from her cycle.
  - Three chapters repeat every cycle, but the map draws a straight line from 1 to 5, so it looks like progress that goes backwards each month. The loop icon and small grey label are easy to miss.
  - The milestone count ("0" on day one) in a big number can feel like a score, even though the stage avoids scores.
  - The Family Timeline is a different screen with a different purpose and is only reachable from the bottom of this one.
- **Ideas to make it simpler:**
  - Draw chapters 2 to 4 as a loop (a small circle between 1 and 5) so the repeat is visible, not only written.
  - Add one line on each card: "You'll move on when..." (the data already exists as `nextUp`, but it only shows on the current card).
  - Hide the milestone count until at least one milestone is reached, and start with the "you started" milestone already ticked.
  - Put the Family Timeline in the tools hub or the More screen as its own entry.
- **Priority guess:** Medium. It's helpful for orientation but not something she needs to use daily.

### Family Timeline  (`lib/screens/ttc/ttc_timeline_screen.dart`)
- **What it's for:** A running list of moments (milestones, medical events, journal notes) grouped by year, meant to carry on into pregnancy and parenting.
- **What a first-time user meets:** A title, a two-line intro, and on a new account an empty state ("Your story starts here") explaining that things will show up as she logs and writes.
- **What's hard or confusing:**
  - She can't add anything here directly; it only fills from other screens, and the empty state doesn't name which ones.
  - The year heading is very large compared to the few rows under it in the first months.
  - Each row ends with a stage label in small capitals ("TRYING TO CONCEIVE") that repeats on every row and adds little while she is still in one stage.
- **Ideas to make it simpler:**
  - In the empty state, add two buttons: "Write in the journal" and "Log a period", so there is a clear way to make the first entry.
  - Hide the stage label while every event is from the same stage.
- **Priority guess:** Low. Nice to have, and not a daily screen.

### Infographic reader  (`lib/screens/ttc/ttc_infographic_screen.dart`)
- **What it's for:** Shows a two-column comparison (for example, myth and fact, or two options) as a full page.
- **What a first-time user meets:** A coloured header with "INFOGRAPHIC", a title, then a sheet with a headline and two side-by-side columns.
- **What's hard or confusing:**
  - The word "INFOGRAPHIC" labels the format, not the content, so it tells her nothing useful.
  - Two narrow columns on a phone make long lines wrap a lot; comparing row by row is hard when rows have different lengths.
- **Ideas to make it simpler:**
  - Replace the "INFOGRAPHIC" eyebrow with the topic (for example "Fertile window").
  - On narrow phones, stack the columns, or pair the rows so each left item sits directly above its right item.
- **Priority guess:** Low. It's a reading format, and the content still gets across.

### More  (`lib/screens/ttc/ttc_more_screen.dart`)
- **What it's for:** Everything that isn't on the four main tabs: Calendar, Cycle Companion, Fertility Window, Community, Our journal, Profile, and a card for all paid programmes.
- **What a first-time user meets:** A title, one intro line, and three short groups of rows ("Your cycle", "Community", "Prepare"), each with an icon and a label.
- **What's hard or confusing:**
  - Some of her most useful tools (Calendar, Cycle Companion, Fertility Window) live here and also on the Tools hub, so she may not know which place is "the real one".
  - Profile sits under the "Community" heading, which is the wrong group.
  - The paid card lists nine kinds of programme in one long sentence.
- **Ideas to make it simpler:**
  - Put Profile in its own group at the top ("You"), since it holds language and sign out.
  - Shorten the paid card to "All programmes and sessions" plus three examples.
  - Add a one-line hint under the cycle group: "These are also in Tools."
- **Priority guess:** Low. It works; it's a tidy-up.

### First-run setup (TTC intro flow)  (`lib/screens/ttc/ttc_intro_flow.dart`)
- **What it's for:** The first time she opens Trying to Conceive: pick a language, see what the stage covers, then answer three questions (last period date, how long trying, whether a clinic is involved).
- **What a first-time user meets:** Five screens with a progress bar and a "Skip" link at the top. Screen 1 is two big buttons (English, हिन्दी). Screen 2 is a video placeholder that says the film is still being made, four bullet points and Continue. Then a date button, a list of four time ranges, and a list of paths (Trying naturally, Ovulation induction, IUI, IVF).
- **What's hard or confusing:**
  - The language button says हिन्दी in Devanagari, but choosing it switches the TTC stage to Hindi written in Latin letters ("Aapka pichhla period kab shuru hua?"). What she picks isn't what she gets. This also clashes with the app-wide decision that Hindi is Devanagari.
  - Screen 2 is a video that doesn't exist yet. A first screen that says "we're still making this" weakens trust at the very start.
  - The last question asks "Is a clinic involved?" (a yes/no question) but the answers are treatment names. "Ovulation induction" is jargon; many women on letrozole tablets won't recognise their treatment by that name.
  - The date picker opens on today with no hint of what to do if she only knows the rough week.
  - "Skip" at the top skips everything at once, with no warning that the home will then have no cycle data. That is honest, but she isn't told what she'll miss.
  - The progress bar counts the language and video screens as questions, so it feels longer than it is.
- **Ideas to make it simpler:**
  - Until the TTC Hindi is Devanagari, label the second option honestly, or hide it, so the choice matches the result. (Needs a decision from the user; Hindi work is out of scope for this pass.)
  - Drop the video screen until the film exists, or show the four bullets as a short "What you'll find here" card with no player.
  - Word the last question as "Are you having fertility treatment?" with plain options: "No, trying on our own", "Tablets to help me ovulate (like letrozole)", "IUI", "IVF". Keep the saved values the same.
  - Under the date button add "Not sure of the exact day? Pick the closest one. You can change it later."
  - When she taps Skip, show one line: "You can add your period date any time from the home screen."
- **Priority guess:** High. It's the first thing every new TTC user sees, and the language mismatch is a real bug in what she's promised.

## Fertile window and chapters

### Your best days / Fertility Window  (`lib/screens/ttc/ttc_window_screen.dart`)
- **What it's for:** shows the estimated fertile days for this cycle (or a cycle ahead), ranked against each other, from the periods she has logged.
- **What a first-time user meets:** she taps "Your best days this month" on the Fertile window door. With no period logged she gets an empty card ("We're still learning your rhythm" / "Log a period first and we can estimate this") and an "Add the date" button. With one logged period she sees a date range in large type ("12 Oct – 18 Oct"), a seven-segment ramp, a status line ("Opens in 4 days · most likely 17 Oct"), an "Across this cycle" card with a ranked list (DAY / CHANCE ON THAT DAY / RANKED), a list/curve toggle, a "How to read this" walkthrough, a "Why six days" paragraph, a four-word glossary, and the disclaimer.
- **What's hard or confusing:**
  - Three names for one tool: the door tile says "Your best days this month", the back bar says "Fertility Window", the page title says "Your fertile days". She can't be sure she landed where she tapped.
  - With only one logged period and no completed cycle, the engine can return "no estimate" even though she has logged something, and the empty copy ("After a cycle or two…") does not say how many more periods are needed or roughly when the window will appear.
  - The list/curve toggle is two unlabelled icons. Nothing says a second view exists or what it adds.
  - The column header "CHANCE ON THAT DAY" plus a bar invites reading the bar as a percentage, and it is only the grey line under the card ("The shape ranks the days… It isn't a probability") that says otherwise. That line is small and sits below the graphic.
  - Rank words mix two scales: "Medium / High / Peak" are levels, but "Ovulation" is an event, used in the same column as if it were a fourth level above Peak.
  - The glossary says the fertile window is "five before ovulation, the day itself, and the day after" (seven days) while "Why six days" and the reads say six. A careful reader will count and notice.
  - The arrows that page to later cycles are unlabelled; "A cycle ahead" only appears after tapping, and the back arrow is greyed at zero without saying why.
  - The curve view needs a walkthrough to be read at all (whole-cycle axis, shaded band, dashed "today" line, chips below). On a first visit the list view is enough, and the curve adds effort.
  - The walkthrough ("How to read this") is a small pill at the bottom of the card, after the graphic she's trying to read.
- **Ideas to make it simpler:**
  - Use one name everywhere (tile, back bar, page title), for example "Your fertile days", so she knows she's in the right place.
  - When the estimate is withheld, say exactly what unlocks it ("Log one more period and we'll show your window here") and keep the "Add the date" button visible in that state too, not only when nothing is logged.
  - Give the toggle text labels ("List" / "Curve") or a one-line hint the first time, so the second view is discoverable.
  - Move the "not a probability" line above the list, or rename the column from "CHANCE ON THAT DAY" to something like "HOW GOOD A DAY", so the bars aren't read as numbers in the first place.
  - Show "Ovulation" as a marker (the dot it already has) beside a "Peak" label rather than as a rank of its own, so the column is one scale.
  - Fix the six-versus-seven-day wording in the glossary so it matches the rest of the stage (a content decision for a clinician, not changed here).
  - Label the cycle arrows ("Next cycle") and show the cycle's start date, so paging forward is obvious.
  - Put "How to read this" beside the "Across this cycle" heading, where she looks first.
- **Priority guess:** High. It's the first tool on the first door, it's opened every month, and the naming mismatch and withheld-estimate dead end are the moments where a first-time user most often gives up.

### Your chapter  (`lib/screens/ttc/ttc_chapter_screen.dart`)
- **What it's for:** explains the stage of the cycle she's in right now (Preparing Together, Knowing Your Rhythm, Trying Together, The Waiting Days, A New Beginning), with what's happening, the couple's part, a short action list, when to see a doctor, suggested Ask Veda questions and a journal prompt.
- **What a first-time user meets:** a purple hero with the chapter name, a "You are here" pill if it's her current chapter, and a two-line overview. Under it, three tabs (Me / Us / What's next), then two or three text cards for the chosen tab. The action plan and the doctor card appear only on "What's next". Every tab ends with five Ask Veda questions and a journal prompt.
- **What's hard or confusing:**
  - The chapter names are poetic ("Knowing Your Rhythm", "The Waiting Days") and nothing on the page says which days of her cycle the chapter covers, or when it will change. She has to infer that chapters follow her cycle.
  - "When to see someone" and the action plan are hidden behind the "What's next" tab. Someone reading only "Me" never sees the doctor guidance, which is the most safety-relevant card on the page.
  - The cards are long single blocks of text with no headings inside them, so on a phone each tab is a wall of reading.
  - The same Ask Veda questions and journal prompt repeat under all three tabs, so switching tabs looks like "nothing changed" at the bottom.
  - Partner actions are marked only with a coral dot and a small "For your partner" tag. The Us tab speaks to him in places ("Don't ask her what day it is") and to her in others, without saying who each card is for.
  - Opening a chapter that isn't current (from the journey map or search) shows no "You are here" pill, but also doesn't say which chapter she is in now or how to get back to it.
- **Ideas to make it simpler:**
  - Add one short line under the chapter name saying when it applies ("From your period until your fertile days start"), so the loop through chapters makes sense.
  - Show the "When to see someone" card on every tab (or at least link to it from Me), so safety guidance is never one tap away and unseen.
  - Label each Us card with who it's written for ("For him", "For you both") instead of relying on the reader to work it out.
  - Show Ask Veda questions that match the open tab, or show them once below the tabs rather than repeating them, so each tab feels different.
  - On a non-current chapter, add a small "You're in <chapter> now" link back.
- **Priority guess:** Medium. It's reading, not data entry, so nothing breaks, but the hidden doctor card and the unexplained chapter names are real comprehension gaps on a clinically reviewed surface.

## Trackers: cycle, symptoms, reports, records

### Cycle calendar  (`lib/screens/ttc/ttc_calendar_screen.dart`)
- **What it's for:** one month view that shows period days, fertile days, the expected next period, and anything she logged, with a panel for the day she taps.
- **What a first-time user meets:** a month grid opened on today, a "What the colours mean" legend that starts open, and a day panel under it. With no period date saved, the grid has almost no colour and the day panel says "Nothing on this day".
- **What's hard or confusing:** with no data the calendar is mostly blank and doesn't say how to fill it (no "add your last period" action here). The legend starts open every time, so the grid is pushed down on every visit. The expected period is only an outline, which is easy to miss. In a clinic cycle the "Until your blood test" note appears, but the calendar itself doesn't say why the fertile colours are missing.
- **Ideas to make it simpler:** when there's no period date, show one line and a button ("Add the day your last period started") above the grid, because the empty grid is the first thing she sees. Remember whether she closed the legend, so regular users get the grid first. Label the outlined day in the grid itself ("Due") or in the day panel when tapped. In a clinic cycle, one line saying "Your clinic is timing this cycle, so we don't mark fertile days".
- **Priority guess:** Medium. It works once data exists, but the empty first visit is a dead end.

### Cycle Companion  (`lib/screens/ttc/ttc_cycle_companion.dart`)
- **What it's for:** her period dates, her usual cycle length and spread, and a picture (ring or days grid) of this cycle split into four stretches.
- **What a first-time user meets:** "One date to start", an "Add a period date" button, and a ladder of what each date gives her (one date, two, three). Tapping opens a sheet with a month picker, "How many days did you bleed" chips (with "Still on"), and "Save this period".
- **What's hard or confusing:** fixing or removing a date is hidden behind a swipe ("Swipe a row left to correct or remove it" is the only hint). "Ring" and "Days" toggle names don't say what they show. The word "stretches" for cycle phases is ours and is never defined on this screen. A cycle marked "NOT COUNTED" is explained in small text, but she can't say "no, that really was a long cycle". The raw cycle-day chip beside the title and the big title can show two different kinds of heading at once.
- **Ideas to make it simpler:** add a visible edit icon (or tap to open) on each date row, because swipe actions are invisible to most people. Rename the toggle "Circle" / "Calendar" to match the report. One short line under "This cycle" naming the four stretches. On a "NOT COUNTED" row, offer "This was a real long cycle" so she can include it, since the app is guessing.
- **Priority guess:** High. It is the base for every date in the stage, and correcting a date is hidden.

### Symptom log and Edit categories  (`lib/screens/ttc/ttc_symptom_log_screen.dart`, `lib/screens/ttc/ttc_edit_categories_screen.dart`)
- **What it's for:** tapping what kind of day it was (feelings, body, discharge, sex, test results, the rest of the day), plus weight and morning temperature.
- **What a first-time user meets:** the day name with arrows, a search box, a row of eight feelings with emoji, then category cards of chips, then two number cards, a "See your cycle report" button and a long disclaimer. "Edit" beside Categories opens a list of switches to hide cards.
- **What's hard or confusing:** there is no save button and no confirmation, so it isn't obvious that a tap is saved straight away. Around 50 chips on one screen is a lot on first open. Search only matches chip labels, so "could not sleep" won't find "Couldn't sleep" (the label changed in this pass) and "BBT" won't find anything. Pregnancy test and ovulation test groups are single-choice while every other group is multi-choice, and nothing on screen says so. The disclaimer is long and sits at the very bottom.
- **Ideas to make it simpler:** a small "Saved" tick or a counter on the day header ("3 things logged today") so she knows taps stick. Collapse category cards she hasn't used after a few cycles, or start with body and feelings open. Let search match a few synonyms (sleep, BBT, temperature, spotting). Put a one-line version of the disclaimer near the top and keep the full one at the bottom.
- **Priority guess:** High. It is the most-used logging screen and the "did it save" doubt is the biggest risk.

### Weight and morning temperature cards  (inside `lib/screens/ttc/ttc_symptom_log_screen.dart`)
- **What it's for:** a number for the day, with a 14-reading sparkline under it.
- **What a first-time user meets:** two small cards saying "No readings yet". Tapping opens a sheet with a stepper, a kg/lbs or °C/°F switch and "Done".
- **What's hard or confusing:** morning temperature has no explanation. She isn't told it should be taken before getting out of bed, at the same time each day, or what a rise after ovulation looks like, so a random daytime reading is easy to enter. Stepping to a weight like 68.4 kg from the start value takes many taps. The sparkline has no dates, so she can't tell which reading is which.
- **Ideas to make it simpler:** one line under the temperature card ("Take it before you get up, at the same time each day") with a link to the read that explains it. Let her type the number as well as step it. Show the first and last dates under the sparkline.
- **Priority guess:** Medium. Temperature data is only useful if taken the right way, and nothing tells her how.

### Cycle report  (`lib/screens/ttc/ttc_cycle_report_screen.dart`, `ttc_cycle_report_states.dart`, `ttc_cycle_report_v3.dart`)
- **What it's for:** one cycle at a time: the four stretches with dates, what she logged and when it clustered, weight and temperature across the cycle, and how this cycle's length compares with her usual.
- **What a first-time user meets:** with no period saved, "This fills in as you log", a dashed empty ring with its four labels, a three-step "What one date gives you" list and two buttons to add a date. With data, a hero line ("You're in your fertile days"), a Dial/Calendar toggle, the timeline, and findings.
- **What's hard or confusing:** there are four different states (empty, clinic, no estimate, healthy) with different headers, and the only way to understand which one she is in is to read the body text. The "i" button toggles an about box on some states and opens a sheet on others. Moving between cycles uses small arrows beside a date range with no count ("cycle 2 of 5"). "Stretches" and "the waiting days" are our own words.
- **Ideas to make it simpler:** make the "i" behave the same in every state. Add "Cycle 2 of 5" or "Last cycle / This cycle" to the picker. Use the same phase names everywhere and explain them once in the legend. In the no-estimate state, put the "Fill in the missing month" button above the explanation, since that is the action that fixes it.
- **Priority guess:** Medium. It's the page she might show a doctor, but it's reached only from the logger and the companion.

### What you're working on (habits tracker)  (`lib/screens/ttc/ttc_tracker_screen.dart` with the `habits` tracker; old list screen `lib/screens/ttc/ttc_habits_screen.dart`)
- **What it's for:** noting sleep, movement, stress, bedtime, home-cooked food, caffeine, alcohol, smoke and water for the day, with no score.
- **What a first-time user meets:** a "why this exists" paragraph, one permission line ("Write down as much or as little as you like. One thing is enough."), then nine fields under Sleep, Movement, Stress, Food and Cutting down, with "Look back" in the header for a four-week strip.
- **What's hard or confusing:** nine fields is long for one screen and she has to scroll to reach water and smoke. Stepper fields (hours, minutes, glasses) need many taps. There's no sign that a choice has saved. "Look back" is small and in the header. The old `TtcHabitsScreen` still lists four tracker ids (`sleep`, `exercise`, `stress`, `lifestyle`) that no longer exist, so it would render no rows; it is unreachable today (the router comment says it is kept for revert), but if anyone wires it back it will be an empty screen.
- **Ideas to make it simpler:** let her pin the three or four fields she cares about to the top, since the why text already tells her to skip the rest. Offer quick preset chips for steppers (6, 7, 8 hours; 10, 20, 30 minutes). A short "Saved" confirmation. Either delete the dead id list in the old habits screen or point it at `habits`.
- **Priority guess:** Medium. Useful and calm, but long; the dead screen is a Low code issue.

### Generic tracker screen (Symptom Companion, Weight, Mood, Partner Health)  (`lib/screens/ttc/ttc_tracker_screen.dart`)
- **What it's for:** the same sheet for every tracker defined in `lib/ttc/ttc_trackers_data.dart`: why it exists, the fields, and a four-week look back.
- **What a first-time user meets:** the tracker title and subtitle, the why paragraph (sometimes two paragraphs), the permission line, then the fields.
- **What's hard or confusing:** Tools → "Symptom Companion" still opens the old five-point-scale tracker, next to the new chip-based symptom log, so there are two ways to log cramps. Worse, they write the same keys (tracker `symptoms`, fields `cramping`, `bloating`, `breast`, `fatigue`, `headache`): the chip logger stores 1 for "tapped", the scale stores 0 to 4, so each one can overwrite or misread the other's value for the day (a chip tap shows as "A little" on the scale; a scale "None" (0) may show as tapped in the chip logger). Partner Health is his to fill in, but nothing on the screen says how he gets to it or whether she can fill it for him. Number sheets say "Leave it blank to clear it" but "Clear" also appears on the field, which is two ways to do one thing.
- **Ideas to make it simpler:** retire or redirect the scale-based Symptom Companion to the chip logger so there is one place for symptoms. On Partner Health, one line on who fills it in ("You can fill this in together, or he can from his own phone"). Keep one clear action.
- **Priority guess:** High. Two loggers writing the same keys with different meanings is a data problem, not just a wording one (worth a code check before acting on it).

### Health records and PDF export  (`lib/screens/ttc/ttc_records_v2.dart`, `lib/screens/ttc/ttc_records_screen.dart`)
- **What it's for:** keeping every test result and report photo for both partners, grouped by test, and handing the latest ones to a doctor as a PDF.
- **What a first-time user meets:** "Start with the paper in your hand" with "Photograph a report" and "Type a number instead", then three "What this becomes" cards. The add sheet opens the camera first, then asks for the test name, the number, the unit and whose it is.
- **What's hard or confusing:** "Save this result" does nothing when neither a photo nor a test name is there (the tap is silently ignored). The test name is free text, so "AMH" and "Amh test" become two groups and the "same test, twice" view breaks. Whose result it is sits in small text ("Filing under You · Partner instead") and is easy to miss, so his results can end up filed as hers. Share as PDF needs a connection the first time, which she only finds out when it fails. Swapping the Everyone / You / Partner filter is a single chip that cycles on tap, which isn't obvious.
- **Ideas to make it simpler:** disable the Save button with a short reason ("Add a photo or the test name") instead of a dead tap. Suggest test names from the library as she types, so repeats group together. Make "Yours / Partner's" a two-option switch at the top of the sheet. Say "Needs internet the first time" beside Share as PDF. Use a three-option segmented control for the filter.
- **Priority guess:** High. Wrong grouping or wrong owner makes the doctor view misleading, and the dead Save tap feels broken.

## Records PDF

### Records PDF export (the printed summary)  (`lib/services/ttc_records_pdf.dart`, opened from `lib/screens/ttc/ttc_records_v2.dart` appointment sheet)
- **What it's for:** turning every saved test result (and its photos) into one PDF she can print, save or send to a doctor.
- **What a first-time user meets:** from the appointment sheet she taps share; the phone's print/share dialog opens straight away with an A4 document: a table of Test / Result as printed / Date / Whose, older readings under each, then "Not in this document", then one page per photo.
- **What's hard or confusing:** the dialog is the system print screen, so on a phone it looks like printing rather than sharing, and there is no preview or hint first saying what will be in the file. The first export needs internet (fonts), and she only finds out when it fails. The "Whose" column says "Her" or "Partner" with no names, which a clinic reading it later may find vague. A PDF attachment is listed as a file that "could not be included", but nothing tells her to bring it separately.
- **Ideas to make it simpler:** a one-line note on the button ("Makes a PDF of all your results and photos to print or send") so she knows what she is about to get; print both names (hers and partner's, if known) in the header so the sheet stands alone; when a PDF attachment could not be included, say on the sheet "Bring or send this file separately"; fetch the fonts in the background when the records screen opens, so the first export does not fail offline.
- **Priority guess:** Medium. It works and is honest, but it is the thing a doctor sees, and small gaps (no names, missing files) cost a real conversation.

## Self-checks and assessments

### Pre-pregnancy checklist  (`lib/screens/ttc/ttc_precheck_screen.dart`, summary in `lib/screens/ttc/ttc_precheck_summary.dart`)
- **What it's for:** A list of things worth sorting out before trying (folic acid, medicines, vaccines, habits, family history), with her own status on each and a short "next 3 steps" summary she can copy for a doctor.
- **What a first-time user meets:** An intro screen with a big headline, a paragraph, an "already done" box (only if the app knows something), a reassurance line, a "Start my checklist" button and the disclaimer. After that, a count bar ("0 of the 21 you're tracking are done") and ten collapsible sections. Each section opens into item rows; each item opens into "Why it matters", "What to do", sometimes "Ask your doctor", four status chips, a "talked to my doctor" tick box and one or two link chips.
- **What's hard or confusing:** The intro is one extra screen before anything happens. The count bar starts at "0 of 21" before she has touched anything, which reads like a debt. Two nested levels of expand/collapse (section, then item) hide the status chips, so it isn't obvious that you mark things by opening a card. "Core / Worth doing / Helpful if it applies" appears on every row with no explanation of what it means. The four statuses ("Done / Need to do / Not sure / Not relevant to me") plus a separate "talked to my doctor" box is two ways to record progress on one card. The "Summary" link in the top bar and the "See my next 3 steps" button at the very bottom lead to the same place. The disclaimer appears on the intro, the list foot and the summary.
- **Ideas to make it simpler:** Skip the intro after the first visit (already done) and consider folding it into a short header on the list, so the first tap is a real item. Hide the count bar until at least one item is marked, or phrase it as "You've marked 3 so far". Add a one-line key the first time the tier labels appear ("Core means almost everyone should do this"). Show the status chips on the collapsed row (or a single tap-to-cycle status) so marking an item doesn't need an expand. Keep one route to the summary, a sticky "See my next 3 steps" button, and drop the top-bar link.
- **Priority guess:** Medium. It works and is safe, but 21 items behind two levels of taps is the kind of list people abandon.

### PCOS check  (`lib/screens/ttc/ttc_pcos_check_screen.dart`, result in `lib/screens/ttc/ttc_pcos_check_result.dart`)
- **What it's for:** A one-question-per-screen check of cycle, ovulation and androgen signs that ends in a plain-words reading (never a diagnosis) and a doctor summary in clinical order.
- **What a first-time user meets:** An intro ("Could your cycle be telling you something?"), three reassurance ticks, maybe a card saying the cycle questions were filled in from her logs, and "Check my pattern". Then up to 20 questions, one per screen, each with a "Why we ask" toggle and large answer tiles. A safety answer (possible pregnancy, severe pain, heavy bleeding, fainting) ends the flow at once. The result shows a headline, three dot "dials", a body paragraph, detail lines, next-step cards and the disclaimer.
- **What's hard or confusing:** The intro promises "two to three minutes" but the flow can run to 20 screens; the counter ("7 / 20") makes the length very visible. Terms like "cervical mucus", "ovulation test strips" and "androgens" appear in question text before "Why we ask" is opened. There is no "skip" or "I'd rather not say" on most questions, only "Not sure". The three dials use words like "Variable" and "Possibly irregular" with no key. The result screen stacks body text, up to four detail lines and a confidence note, which is a lot of reading after a long flow. This tool and "Where do I stand" cover the same ground and write to the same store, but look completely different.
- **Ideas to make it simpler:** Either trim the flow to match the "two to three minutes" promise or change the promise to the real length. Put a short plain gloss in the question itself for the three jargon terms (mucus = discharge, strips = the pee sticks, androgens = hormones like testosterone). Add a one-line caption under the dials ("Three dots means more of this came up in your answers"). Collapse the detail lines under a "Tell me more" so the first view is headline, dials, one paragraph, next step. Decide which of the two PCOS tools is the front door and link the other from it.
- **Priority guess:** High. Two PCOS tools that disagree in length and look is the most visible confusion in this batch, and PCOS is one of the most-visited topics.

### Where do I stand (PCOS self-read)  (`lib/screens/ttc/ttc_pcos_stand_screen.dart`)
- **What it's for:** A short, eight-question, single-scroll version of the PCOS check that reflects her pattern back in plain words and gives her four lines of appointment notes.
- **What a first-time user meets:** A tool header ("A look at your own pattern"), a progress hairline, eight numbered question cards with chips (cycle length is prefilled from logs if possible), a "See my pattern" button and a card showing what her logs say. The result has three blocks (cycle, other things shared, what's worth doing next), a "Talk to a PCOS specialist" button and "What to take with you".
- **What's hard or confusing:** The "From your logs" card sits below the button, so she only learns why question 1 was prefilled after she has finished. The main result button goes straight to a paid consult; there is no free next step (read, tracker) on the result. The hair-growth question lists body areas with a "Haven't noticed" chip first, which works, but the other degree questions ("Mild / Moderate / Severe") give no sense of what counts as each. It's not clear whether answering here also counts as doing the full PCOS check (it does write to the same store).
- **Ideas to make it simpler:** Keep the prefill note on question 1 (already there) and drop or shorten the facts card at the bottom. Add a free secondary action on the result, such as "Read about PCOS" or "Log your cycles", above or beside the consult. Add a small hint for the severity chips ("Mild: you notice it, others don't"). Say once, on the result, that this also updates the longer PCOS check.
- **Priority guess:** Medium. It's the gentler of the two PCOS tools and already short; the main gap is a result that only offers a paid step.

### BMI calculator  (`lib/screens/ttc/ttc_bmi_screen.dart`)
- **What it's for:** Works out BMI from height and weight, reads it against South Asian cut-offs first (international second) and explains what it does and doesn't mean before pregnancy.
- **What a first-time user meets:** An intro screen with a headline, a paragraph, a tinted "information, not a judgement" card, a "Calculate my BMI" button and a disclaimer. Then an input screen with height (cm or ft/in toggle) and weight (kg or lb toggle). The result shows a big number, the band label, a scale, a box explaining the international figure, "What this means", a before-pregnancy box, optional notes, the "not the whole story" paragraph, a collapsible limits list, three next-step cards, save and edit buttons and the disclaimer.
- **What's hard or confusing:** The intro screen adds a tap before the only two fields that matter. The result page is very long: about ten blocks, and the South Asian explainer paragraph is dense (three guideline names in one sentence) and sits above the plain "What this means". The result is not saved until she taps "Save this measurement" at the bottom, so a first-time user can leave without saving and lose it; the next-step card "Add this to my checklist" is a second, separate save. The scale's tick labels (15, 18.5, 23, 25, 35) have no band names under them.
- **Ideas to make it simpler:** Merge the intro into the input screen (one line of framing above the fields). Reorder the result: number, band, "What this means", before-pregnancy box, then the international comparison as a collapsible "Why might a lab say something different?". Save automatically on calculate (with an undo) or make "Save" the first button under the number. Put short band names under the scale ticks.
- **Priority guess:** Medium. The maths and wording are careful; the length and the easy-to-miss save are the problems.

### Should I seek fertility help?  (`lib/screens/ttc/ttc_fertility_help_screen.dart`, summary in `lib/screens/ttc/ttc_fertility_help_summary.dart`)
- **What it's for:** Checks her situation against the usual referral guidance (age, time trying, cycles, known conditions, losses, his side, cancer treatment) and says whether it's worth seeing someone now, with reasons and a snapshot to take along.
- **What a first-time user meets:** An intro with a headline, a paragraph, the disclaimer, a "what we already know" card (trying time, cycles, PCOS check) and two buttons: "Check my readiness" and "I already want to talk to someone". Then only the questions the app can't answer, one per screen (up to eight, including miscarriage, pelvic history, and cancer treatment). The result gives a headline, "Why we say this", "What this doesn't mean", "Your next step", a button to the snapshot, a read link, a closing line, and below a divider a ₹899 consult.
- **What's hard or confusing:** It overlaps heavily with the IVF readiness tool (same store, same age bands, similar questions, similar result), and both are titled around "should I get help". Questions about miscarriage and cancer treatment arrive with no warning that they're coming and no "I'd rather not say". The disclaimer now sits before the start button, which is good, but it makes the intro text-heavy. "Check my readiness" is a vague label for what the tool does.
- **Ideas to make it simpler:** Pick one of the two "should I get help" tools as the main entry and send the other to it (or merge them: IVF readiness is the shorter, one-scroll one). Add a gentle line before the sensitive questions ("A few of these are personal. You can skip any of them.") and a skip option. Rename the button to what she gets: "See if it's time to talk to someone".
- **Priority guess:** High. Two near-identical tools for the same worry is confusing, and the sensitive questions need a softer way in.

### Should I get help? (IVF readiness)  (`lib/screens/ttc/ttc_ivf_readiness_screen.dart`)
- **What it's for:** Six questions on one scroll (age, time trying, cycles, anything already diagnosed, his semen test, earlier fertility checks) that end in a plain read on timing, leaning towards "talk to someone" whenever unsure.
- **What a first-time user meets:** A tool header ("Is it worth talking to someone yet?"), a progress hairline, six numbered cards with chips (time trying and cycles may be prefilled with a note), a "what we already know" card, "See what this means", and a line saying blanks are fine. The result shows "Where you are", "What this means for timing", "What to do next" and either a specialist button plus "What to take with you" or, on the reassuring branch, "Make the most of this cycle" plus "Book a chat anyway".
- **What's hard or confusing:** Same overlap as above with "Should I seek fertility help?", and the two can give differently worded answers from the same stored data. The main button on most results goes to a paid consult; the appointment notes are the secondary action even though they're the free, useful thing. The semen question assumes a male partner, which won't fit every user. "Has a doctor already told you about any of these?" lists conditions as pills with "None" and "Not sure", and it's easy to miss that more than one can be picked.
- **Ideas to make it simpler:** Make this the single "should I get help" tool (it's shorter) and fold the extra questions from the other one (miscarriages, pelvic history, cancer) into it as optional cards. Put "What to take with you" first and the consult second. Add "(pick any)" to the conditions question. Consider wording the partner question so it works when there is no male partner (for example a "Doesn't apply" chip).
- **Priority guess:** High, for the same duplication reason, and because the paid action leads on a result that is meant to be neutral.

## IVF and IUI treatment

### Your treatment cycle (the IVF / IUI dates tracker)  (`lib/screens/ttc/ttc_treatment_screen.dart`, store `lib/ttc/ttc_treatment_store.dart`)
- **What it's for:** keeping the dates her clinic gave her (injections start, trigger shot, egg collection or IUI, transfer, blood test) in one place, with reminders for the trigger shot.
- **What a first-time user meets:** a header "The dates your clinic gave you." and a paragraph, then a card asking "What are you doing this cycle?" with five options, then (for ovulation induction, IUI and frozen transfer only) a card of two yes/no questions, then five date rows that each open a date picker (the trigger row also opens a time picker), then a disclaimer. The big purple "Next" card only appears once a future date is entered.
- **What's hard or confusing:**
  - **The reminder promise is wrong.** The card under the dates says "We will remind you two hours before the trigger shot" (`treatmentTriggerReminder` in `ttc_strings.dart`), but the store schedules two reminders: 4 hours before and 15 minutes before. She is told one thing and gets another, on the one evening where timing matters most.
  - **Cancelling the time picker still saves a time.** If she picks the trigger date and then closes the time picker, the code saves 9:00pm (`time?.hour ?? 21`) and schedules reminders for 5pm and 8:45pm. Nothing on screen says a time was assumed.
  - **The dates she came for are third.** On first open she has to get past the pathway chooser and (often) the two questions before she reaches the date rows, which is the thing the screen is named after.
  - **The date picker doesn't say which date it's for.** Only the trigger's time picker has help text ("What time exactly?"). Every other row opens a bare calendar.
  - **The list is IVF-shaped for everyone.** Someone on IUI sees "Transfer" and "Egg retrieval / IUI" with no way to say a step doesn't apply to her, so an IUI cycle always looks half empty.
  - **The two questions are hard to read.** "Has medication taken over WHEN ovulation or transfer happens, an injection that sets the hour, or a fully medicated schedule?" is long, uses a capitalised word and clinic jargon, and sits in `ttc_strings.dart` (outside this batch, so not rewritten here). It also uses dashes.
  - **The small cross on a set date clears it at once.** No confirm and no undo, and it sits right next to the row she taps to edit.
  - **"Clear this cycle" is at the bottom with no hint of when to use it**, until the dialog opens.
  - **A saved clinic name has no field.** The store keeps `clinic` and has `setClinic`, but nothing in the app calls it, so it is always empty.
  - **Dates show no weekday and no year** ("12 Oct"). For early-morning scans the weekday is the useful part.
- **Ideas to make it simpler:**
  - Fix the reminder line to say what really happens ("We'll remind you 4 hours before, and again 15 minutes before"), or change the schedule to match the words. Reason: a wrong promise on the trigger night is the worst place for one.
  - If the time picker is dismissed, either don't save the trigger or show "Time not set: tap to add" and hold off on reminders. Reason: a silent 9pm guess can fire alarms at the wrong time.
  - Put the five date rows first and move "What are you doing this cycle?" and the two questions below them (or into a one-time setup step). Reason: she opens this mid-cycle to check or add a date.
  - Give each date picker a title ("When does your trigger shot happen?", "When is your blood test?"). Reason: a bare calendar is easy to fill for the wrong row.
  - Hide or grey out steps that don't apply to the chosen path (no transfer on IUI; call the retrieval row "IUI" on an IUI path). Reason: an always-empty row reads like something missed.
  - Rewrite the two questions in plain words with one example each, for example "Is your clinic tracking this cycle with scans or blood tests?" and "Does an injection or medicine decide the day you ovulate?". Reason: she should answer in one read.
  - Add a short undo snackbar after the cross clears a date. Reason: a mis-tap wipes a date she copied off a printout.
  - Either add a "Clinic name" field or remove the unused `clinic` field. Reason: dead data paths confuse the next developer and sync an always-empty value.
  - Show the weekday with each date ("Thu 12 Oct"). Reason: people plan scans by day of the week.
- **Priority guess:** High. The reminder mismatch and the silent 9pm default both touch the trigger shot, the one moment the app says timing is exact.

### Clinic dates on the calendar  (`lib/screens/ttc/ttc_calendar_screen.dart`, reads `TtcTreatmentStore`)
- **What it's for:** showing the treatment dates from the tracker on the month calendar, next to periods and logs.
- **What a first-time user meets:** nothing until she has entered dates in the tracker. After that, the day's facts list the step names (for example "Trigger shot") on the matching day. On a clinic-run path the calendar also stops drawing the expected-period marker.
- **What's hard or confusing:**
  - There's no way to add or edit a clinic date from the calendar. She has to know the tracker exists and go there.
  - The trigger's time isn't shown on the calendar, only the step name, although the time is the part that matters.
  - When the expected period marker disappears on a clinic cycle, nothing says why.
- **Ideas to make it simpler:**
  - On a clinic-run path, add an "Add a clinic date" action on an empty day that opens the tracker at the right row. Reason: the calendar is where people look for dates.
  - Show the trigger time next to its label ("Trigger shot · 10:15pm"). Reason: it's the only date where the hour matters.
  - Add a one-line note on clinic cycles: "Your clinic's dates replace our period estimate this cycle." Reason: a marker that vanishes without a word looks like a bug.
- **Priority guess:** Medium. It works, but the calendar and the tracker don't point at each other, so a first-time user may never connect them.

## His side

### Read your semen report  (`lib/screens/ttc/ttc_semen_report_screen.dart`)
- **What it's for:** He copies the numbers off his printed semen analysis and gets each one explained against the WHO 2021 reference lines, with a calm next step and no verdict.
- **What a first-time user meets:** A tall form titled "Read your semen report." with a paragraph of intro, then up to eight numbered questions on one scroll: (1) does the report say no sperm were found, Yes/No; (2 to 5) four number fields, Concentration, Total motility, Progressive motility, Normal forms (morphology), each with a one-line meaning and a unit; (6) Volume with a "Not on my report" pill; (7) first test or a repeat; (8) days since last ejaculation; (9) four tick boxes for warning signs. One button at the foot, "Read it back to me". The result screen then shows a headline, a paragraph, one card per number, the "not a pass mark" framing, and three buttons (have it read, keep it, change something).
- **What's hard or confusing:**
  - Nine questions on one long page is a lot for a man who may be anxious and reading at night. He can't see how long it is or which fields actually matter.
  - Field labels are the report's jargon ("Total motility", "Progressive motility", "Normal forms (morphology)"). Labs print these in different ways (for example "Sperm count", "Rapid progressive (a)", "Grade a+b", "Morphology, Kruger"), and nothing helps him match his report's wording to ours.
  - Units are a trap. Some labs print concentration as "million/ml" and some print total count per ejaculate, and some print motility as grades a/b/c/d rather than one total. A man who types the wrong one gets a wrong line and has no warning.
  - Question 1 has no default, but if he skips it the form still works, so it's unclear whether he must answer it.
  - The result page is long. The two most useful things (what to do next, and "keep it") sit at the very bottom, under all the number cards.
  - "Keep his reports with yours" is written from her point of view. When he is the one holding the phone it reads oddly ("his" reports).
  - After saving, the button text changes to "Kept with your reports. Open the folder", but there's no visible confirmation at the moment of saving; the folder just opens on top.
  - "Change something" takes him back to the whole form with no hint of which answer caused the result.
  - The number field's placeholder is a long dash, which can look like a value already filled in.
- **Ideas to make it simpler:**
  - Split the form into two short steps: "The four main numbers" first, then "A few details" (volume, repeat, days, warning signs). Less to face at once, same questions.
  - Add a small "Where to find this on your report" helper under each number, listing the common alternative names labs print (count, rapid progressive, grade a+b, Kruger). Cuts the most likely data-entry mistake.
  - Add a gentle unit check: if concentration looks like a total count (for example over 150), or motility looks like a single grade, show a one-line "Check this is per ml / the total moving" note. Prevents a wrong "below the line" from a unit mix-up.
  - Put the three next-step buttons near the top of the result (under the headline), and let the number cards follow. The next step is what he most needs.
  - Show a brief "Saved to your reports" confirmation before the folder opens, so he knows the tap worked.
  - Use neutral wording for the save button when the reader may be him ("Keep this with your reports").
  - Replace the dash placeholder with an empty field or a light "e.g. 20".
- **Priority guess:** High. It's the one tool in the stage that reads a medical result back to a worried man; a unit or label mix-up could show "below the line" for a normal result, and the length makes drop-off likely.

## Partner, tests, vaccines, supplements, medication, appointments

### Partner Today, his side  (`lib/screens/ttc/ttc_partner_screen.dart`)
- **What it's for:** gives the partner one thing to do today, a short explanation of what is happening in her body this chapter, and a note on his own half (sperm, habits).
- **What a first-time user meets:** a Her / Him pill floating over her Today. Tapping Him turns the whole home slate blue: a hero with the chapter name, then eight stacked cards (today's mission, "A few minutes, yours" with two practice rows, Supporting her, What's happening in her body, Your half of this, Today's lesson, Ask Veda, Shared journal).
- **What's hard or confusing:**
  - There is no tracker here for his own habits. The missions and "Your half of this" tell him to fix sleep, drinking, heat and supplements for ninety days, but nothing lets him tick them off or see his own streak of effort. The only tickable things are the two practice rows.
  - Eight cards is a long scroll. The two most useful for a first-time partner (her body, his body) sit fourth and fifth.
  - The Her / Him pill is a testing switch on one phone (the code says so). A real couple could think the partner is meant to use her phone this way.
  - "A FEW MINUTES, YOURS" and "Different from hers" assume he knows she has her own practice cards. He may never have seen hers.
  - Today's mission changes every day with no way to see yesterday's or mark it done, so a good mission is gone tomorrow.
- **Ideas to make it simpler:**
  - Add a small "done" tick to the mission card, reusing the practice-card done state, so he gets the same "I did my part" feeling she does.
  - Give him a light 90-day habit card (sleep, drinking, heat, supplements) that links to the supplements log filtered to "Your partner's". His biology is the one thing he can change, and right now it is only words.
  - Collapse Ask Veda and the journal into one "More for you" row to shorten the scroll.
  - Once pairing is live, hide the Her / Him pill for real users so the partner view only appears on his own install.
- **Priority guess:** Medium. The content is good and warm; the gap is that he is given ninety-day tasks with no way to keep them.

### Can I...?  (`lib/screens/ttc/ttc_can_i_screen.dart`)
- **What it's for:** fast yes/no answers to everyday worries (chai, alcohol, papaya, hair colour, travel, painkillers).
- **What a first-time user meets:** a title, one intro line, a round search box, then 12 cards. Each shows the question, a verdict pill ("Yes, this is fine", "In moderation", "Better not", "Ask your doctor") and a one-line answer. "Read more" opens the reason and an India tip.
- **What's hard or confusing:**
  - Search only looks at the question and the short answer. Typing "henna", "cola", "sauna", "mehndi" or "yoga" finds nothing, even though the answer is on the page.
  - The empty search result says "tell us, so we can add it", but there is no button or form to tell us. Dead end.
  - "In moderation" is used for both chai (a number: 200mg) and hot baths (no number), so the pill means different things on different cards.
  - Twelve items, no grouping. Food and drink, body care, his side and medicines are mixed.
- **Ideas to make it simpler:**
  - Search the "why" and India lines too, so everyday words land on the right card.
  - Put a "Ask Veda instead" or "Send us this question" button on the empty state, so the promise in the copy is kept.
  - Group into three short headings (Food and drink, Body and habits, Medicines) so she can scan without searching.
- **Priority guess:** Medium. Search misses are the most likely frustration; the dead-end promise is a small honesty fix.

### Medical tests (test library)  (`lib/screens/ttc/ttc_tests_screen.dart`)
- **What it's for:** explains the 10 common fertility tests: what each measures, why it's done, when in the cycle, a rough Indian price, and how to read the result.
- **What a first-time user meets:** an intro line, a "For her / For him" switch, then a list of test cards. Each card shows the name, a price chip, one line on what it measures and a brown "when" line. "Read more" opens why, a highlighted timing box, and how to read the result.
- **What's hard or confusing:**
  - Names like "FSH and LH", "AMH", "HSG (tube test)" come first. She may not know which ones she has been asked to do, and there is no "my doctor asked for these" path.
  - The price chip sits in the top corner and is the loudest thing on the card after the name, which can make the list feel like a shop.
  - Nothing links from a test to adding its result. A woman holding an AMH report has to find Records herself.
  - "For him" has one test (semen analysis). The switch looks like half the library is his and then shows one card.
  - In Hindi mode the price keeps the old dash ("₹150 – ₹400") because the Hindi field was not in scope.
- **Ideas to make it simpler:**
  - Add a "Add my result" link on each open card that jumps to Records with that test chosen. It turns reading into doing.
  - Order her list by when people usually meet the tests (thyroid, vitamins and sugar first; FSH/LH, AMH, scan; HSG last).
  - On "For him", add a line under the single card pointing to the semen report reader, so the tab feels complete.
  - Make the price a quieter line inside the card rather than a chip.
- **Priority guess:** Medium. Clear content; the missing link to Records is the main gap.

### Vaccinations before trying  (`lib/screens/ttc/ttc_vaccines_screen.dart`)
- **What it's for:** tells her which vaccines matter before trying, which blood tests to ask for, and whether anything means waiting a month.
- **What a first-time user meets:** a title and a calm intro, a coloured answer box ("One blood test settles most of this"), a note that most of this is private cost, a "Start here: ask for these tests by name" list, then MMR, Varicella and Hepatitis B cards she can mark, and a folded "The other 3 on the full list".
- **What's hard or confusing:**
  - "Had it" saves today's date. If she had the MMR jab three weeks ago, the app counts the month from today and tells her to wait a month longer than needed. There is no way to pick the real date.
  - Status buttons ("Already immune", "I need this", "Had it", "Not for me") only show after she opens a card, so the list looks read-only at first.
  - "LIVE · 28-DAY WAIT" chip uses "live" without saying what a live vaccine is until the card is opened.
  - Hepatitis B sits in the "Before you start trying" group but is only advised with a risk factor, so the group feels like three to-dos when it is usually one.
- **Ideas to make it simpler:**
  - When she taps "Had it", ask "When?" with today as the default. This fixes a wrong date on the one screen whose job is dates.
  - Show the status buttons on the closed card for the "before trying" group, so she sees she can record something.
  - Add a one-line explainer under the chip on first open: "Live vaccines use a weakened virus, so doctors advise waiting a month before trying."
  - Tag Hepatitis B "Only if a risk applies" on the closed card.
- **Priority guess:** High for the "Had it" date (it can give a wrong wait date); Medium for the rest.

### Supplements log  (`lib/screens/ttc/ttc_supplements_screen.dart`)
- **What it's for:** a simple record of what each of you takes, with a tick for today.
- **What a first-time user meets:** an empty card ("Nothing added yet"), then a "Commonly taken" list of 8 suggestions with a note on each. Tapping a suggestion adds it. Once added, a "Taken today 1 / 3" card and rows she taps to tick appear at the top.
- **What's hard or confusing:**
  - There is no way to type her own supplement. The empty text says "Add what you take, including anything your doctor prescribed", but only the eight suggestions can be added. (A "supplementsAdd" string exists but nothing uses it.)
  - Doses are saved as "As advised" and can't be edited.
  - Tapping a partner suggestion (Zinc, the second CoQ10) adds it to his list with no message, and the tag "For partner" looks like a label, not an action.
  - The small "x" deletes a supplement and its history at once, with no confirmation or undo.
  - The two CoQ10 suggestions share a name. Once hers is added, his shows as already added (the check matches by name), so he can't add his own.
- **Ideas to make it simpler:**
  - Add an "Add your own" row with name and dose fields, or send her to Medication for prescribed items. The empty state currently promises something the screen can't do.
  - Let her tap a row to edit the dose.
  - Show a short "Added to your partner's list" confirmation, and ask before deleting.
  - Match "already added" by name and author, so both partners can log CoQ10.
- **Priority guess:** High. The empty state promises free entry that doesn't exist, and the CoQ10 clash blocks his half.

### Your medication  (`lib/screens/ttc/ttc_medication_screen.dart`)
- **What it's for:** holds what a clinic has prescribed (name, dose, when, notes) and can set phone reminders.
- **What a first-time user meets:** a coloured header "What to take, and when.", the "we don't check doses" note, an empty card with "Add a medication". The add sheet has Name, Dose, When, Anything to remember, and optional reminder times.
- **What's hard or confusing:**
  - The same "we save this exactly as you write it" paragraph appears twice, as the intro and again in a box below the list.
  - "When" is free text ("Days 3 to 7, once a day") but reminders are daily for ever. A days-3-to-7 medicine keeps reminding her after day 7.
  - The notes hint says "Prescribed by Dr Rao". Dr Rao is not a real expert on the roster (in `ttc_strings.dart`, outside this batch).
  - Save does nothing if the name is empty, with no message.
- **Ideas to make it simpler:**
  - Show the no-advice note once.
  - Add an optional end date to reminders, or a "stop after" number of days, since treatment medicines are short courses.
  - Change the hint to "Prescribed by my doctor, take after food".
  - Show "Add a name to save" when she taps Save on an empty form.
- **Priority guess:** Medium. The reminder that never stops is the real problem during a treatment cycle.

### Appointments  (`lib/screens/ttc/ttc_appointments_screen.dart`)
- **What it's for:** one date-ordered list of clinic visits she adds and sessions booked through ParentVeda, plus her saved questions for the doctor.
- **What a first-time user meets:** header "Where you have to be, and when.", an "Add" pill, "Nothing coming up" with an add button, then "Questions for the doctor" (empty with "Write" button), and a small note about what's shown.
- **What's hard or confusing:**
  - An added appointment can't be edited, only deleted with a small "x" and no confirmation. A moved scan means delete and re-add.
  - The add sheet fields are "What is it?" and "With whom (optional)" as grey hints with no labels; after typing, the hint is gone and she can't see which box is which.
  - The date and time are picked in one tap on a row that shows "27/9/2026 · 10:00am"; nothing says it's tappable.
  - Save with no title does nothing, silently.
  - No reminder the day before, which matters most for short-notice monitoring scans.
- **Ideas to make it simpler:**
  - Tap a card to edit it; ask before deleting.
  - Put short labels above the two fields, and a "Change date and time" caption on the date row.
  - Offer an optional "Remind me the evening before" switch, using the reminder system Medication already has.
- **Priority guess:** Medium. Works, but a changed appointment (common in treatment) is awkward.

## Mind, mood, ritual, journal, care circle

### Mind & body "Today" (`lib/screens/ttc/ttc_mind_today_screen.dart`, logic in `lib/ttc/ttc_mind_today.dart`)
- **What it's for:** one movement and one breathing practice for today, plus two small habit ticks (bedtime, home-cooked food), with no score.
- **What a first-time user meets:** the first tab of the Mind & body door. Two big tinted blocks ("TODAY'S MOVEMENT", "TODAY'S BREATH OR CALM"), each with a title, a two-line blurb, a time, a place and "Start". Below them a panel with two ticks: "In bed by about eleven" and "Home-cooked meals today". A footnote says the cards change tomorrow and nothing is counted.
- **What's hard or confusing:**
  - Nothing says what "Start" leads to (a guided screen, a video, a timer?) or that finishing it marks the block "DONE TODAY". She has to discover that by going in.
  - The two ticks sit under the practices with no line explaining why these two habits in particular, or where the ticks go (they feed "What you're working on" elsewhere, which she can't see from here).
  - "In bed by about eleven" can read as an instruction she is already failing. The time is only changeable inside the garbh sanskar course (session 5), which a first-time user won't know.
  - When she has finished the course, a strip says "The practice you built in session eight." A user who came here from a link, not the course, won't know what session eight is.
  - The small-caps labels are dense (four in a column) on a narrow phone.
- **Ideas to make it simpler:**
  - Add a short line under each "Start": "About 3 minutes, guided. We'll mark it done when you finish." Sets expectations and explains the chip.
  - Let her tap the bedtime label to set her own time right here. Removes the dependence on a course she may never open.
  - One sentence above the ticks: "Two small things that make the rest easier." Explains why they're there.
  - Change the session-eight strip to "The practice you picked in the garbh sanskar course." Names the thing she'd recognise.
- **Priority guess:** Medium. It works and is calm, but the first visit leaves her guessing what happens on tap and why the ticks exist.

### Mood faces (`lib/screens/ttc/ttc_mood_face.dart`)
- **What it's for:** the drawn faces (calm, happy, low, anxious, tearful and so on) used for mood in the symptom logger and daily insights, instead of emoji.
- **What a first-time user meets:** small line-drawn faces on tinted bubbles next to mood words in the logger and on the home day strip. No text of its own.
- **What's hard or confusing:**
  - At the day-strip size (about 11pt) calm, happy and energetic are hard to tell apart; the drawings rely on small details (closed eyes, two rays).
  - "Mood swings" as a half-smile half-frown is clever but not obvious without its word.
- **Ideas to make it simpler:**
  - Always show the mood word next to the face wherever space allows, and use the face alone only where the word was shown on the same screen.
  - Give each face an accessibility label with the mood word (screen readers currently get nothing from a CustomPaint).
- **Priority guess:** Low. Cosmetic, except the missing accessibility label, which is a quick win.

### Your daily ritual (`lib/screens/ttc/ttc_ritual_screen.dart`, store `lib/ttc/ttc_ritual_store.dart`)
- **What it's for:** five small parts for the day (reflection, breath, conversation, gratitude, action), chosen for where the couple is in the cycle, each ticked when done.
- **What a first-time user meets:** a purple header with the chapter name, one line ("It isn't meditation, and it isn't a to-do list…"), a "0/5" count and a progress bar, then five cards, each with a title, a one-line reason, the prompt text and a big "Mark as done" button.
- **What's hard or confusing:**
  - The "0/5" count and progress bar pull against the promise that there's no way to fail. An empty bar at night reads as a score.
  - Five full cards, all expanded, is a long scroll for something sold as five minutes.
  - "Today's action" doesn't say what kind of action until you read the prompt.
  - The screen's text lives in `ttc_strings.dart` and `ttc_daily_data.dart` (not in this batch), so its words were not rewritten here.
  - The store still computes a day streak (`streak()`), even though the Mind & body brief forbids streaks. It isn't shown on this screen, but anything that reads it later would bring one back.
- **Ideas to make it simpler:**
  - Drop the "0/5" and bar, or show ticks only ("Done: breath, gratitude"). Keeps the "no way to fail" promise.
  - Collapse cards to title plus reason, and open one at a time. Makes the five minutes feel like five minutes.
  - Say in the header that you can do any one part and that's enough, which is how the store already counts a day.
  - Include the ritual strings in a later warmth batch (`ttc_strings.dart`, `ttc_daily_data.dart`).
- **Priority guess:** Medium. The counter is the main clash with the stage's tone.

### Our journal (`lib/screens/ttc/ttc_journal_screen.dart`, store `lib/ttc/ttc_journal_store.dart`)
- **What it's for:** a shared journal both partners can write in: memories, letters to a future child, questions for the doctor and how today felt.
- **What a first-time user meets:** four round buttons ("A memory", "To our child", "For the doctor", "How today felt"), then an empty state ("Nothing written yet…") and one optional prompt card. Tapping a button opens a writing sheet with Cancel and Save.
- **What's hard or confusing:**
  - The prompt card isn't tappable. She reads a good prompt and then has to pick a kind and retype or remember the prompt; the prompt isn't carried into the entry.
  - Deleting is the only thing a tap on an entry does. A tap to read or edit opens "Delete?" instead, which is alarming for a letter to a child. There is no edit at all.
  - "To our child" can be painful for someone who has just had a loss, and it sits first-row with no softer framing.
  - "For the doctor" entries are meant to feed an appointment companion later, but nothing on this screen says so.
  - Nothing tells her who can see an entry. It says "you can both write here" but not that the partner sees everything.
  - Labels are 10.5pt under the icons and wrap to two lines.
- **Ideas to make it simpler:**
  - Make the prompt card tappable: it opens the writer with that prompt attached. Removes the blank-page problem the card was added to solve.
  - Tap an entry to open it; move delete to a menu or a long press, and add edit. Stops accidental fear on tap.
  - Add one line under the buttons: "Your partner can read everything here." Honest and prevents a painful surprise.
  - On "For the doctor", add "We'll show these before your next appointment" once that is wired.
- **Priority guess:** High. Tap-to-delete on precious entries and the non-tappable prompt are real friction for a first-time writer.

### Your Care Circle (`lib/screens/ttc/ttc_care_circle_screen.dart`)
- **What it's for:** shows who is with her in this (ParentVeda, her partner) and, later, her doctor, nutritionist, psychologist and clinic, and that every suggestion says where it came from.
- **What a first-time user meets:** an intro line, a card for ParentVeda, a card for her partner ("Not joined yet" or "Joined"), then "Add someone" with four greyed rows (doctor, nutritionist, psychologist, clinic), each with a plus.
- **What's hard or confusing:**
  - All four "Add" rows only show a "coming soon" snackbar. A plus button that does nothing four times is a dead end.
  - The partner card says "Not joined yet" but gives no way to invite from here.
  - The screen is reached from the After a loss door ("The people you chose"), but she never chose anyone; the circle is filled in by the app.
  - The point of the screen (where advice comes from) is in small grey text at the very bottom.
- **Ideas to make it simpler:**
  - Make the partner card tappable to the partner invite flow when not joined. Turns a status into an action.
  - Replace the four plus rows with one line: "Soon you'll be able to add your doctor, nutritionist or clinic here." Removes four dead taps.
  - Move the "every suggestion says where it came from" line to the top, under the intro.
  - Adjust the After a loss tile blurb once people can be added, so it doesn't promise a choice she hasn't made.
- **Priority guess:** Medium. Low traffic, but the dead plus buttons and missing invite are easy fixes.

## Programmes, courses, practice, nutrition, products

### Courses and programmes (Prepare)  (`lib/screens/ttc/ttc_prepare_screen.dart`, data in `lib/ttc/ttc_prepare_data.dart`)
- **What it's for:** Lets a couple find and book paid help while trying: consults, courses, yoga, a couple assessment, IVF prep and the one free course.
- **What a first-time user meets:** Since 2026-09-20 `TtcPrepareScreen` is a facade over the unified `PvLearnScreen` (the old nine-category list is kept as `TtcPrepareScreenClassic`, never pushed). She lands on a learn hub with kind chips (consults, courses), "Chosen for you", "Live this week" and a list of offerings with prices. Tapping one opens `PvOfferingScreen`.
- **What's hard or confusing:**
  - Several titles don't say what they are: "The half nobody talks about" (a male fertility talk), "Fertility, honestly" (a 90-minute recorded class), "After a loss" (a four-week group). She has to open each one to find out.
  - The free garbh sanskar course sits in the `mental` category next to a ₹799 psychologist session, so the one free thing is easy to miss among priced cards.
  - Payment is stubbed, but the price and a "Buy" step still appear on paid items. The note that no money moves is small grey text at the foot of the page.
  - The kind words (consult, masterclass, cohort, class pack) are internal terms. "Cohort" in particular means nothing to most people.
  - Nine topic categories from the old page (yoga, nutrition, lifestyle, IVF support...) overlap: the ninety-day programme, the nutritionist and the PCOS programme all cover food.
- **Ideas to make it simpler:**
  - Add a short plain subtitle under each title ("A 90-minute talk for him about sperm health"), so she can choose without opening each page.
  - Pin the free course as its own first card with "Free" in the title row, because it is the easiest yes on the page.
  - Show kinds as what she gets: "1 video call", "6 live group sessions", "8 classes to use over 2 months".
  - Make the "no payment yet" note sit next to the price, not at the bottom, so nobody thinks they were charged.
- **Priority guess:** Medium. It is the stage's commerce surface and the titles cost clicks, but nothing here is unsafe.

### Preconception garbh sanskar course  (`lib/screens/ttc/ttc_garbh_course_screen.dart`, data in `lib/ttc/ttc_garbh_course.dart`)
- **What it's for:** A free eight-session course that teaches breath, stillness, sound, gentle movement, routine and couple practices, and ends by building her own five-minute daily practice on Today.
- **What a first-time user meets:** The course page is now `PvOfferingScreen` (from `pv_learn_catalog.dart`), with facts, takeaways and eight lessons. Each lesson opens `TtcCourseSessionScreen`: eyebrow "SESSION n OF 8", title, intro, duration and setting, then (session 1 only) two panels of rules, a numbered "WHAT YOU DO" list, any timer or practice players, any time pickers, and a "SAID PLAINLY" box.
- **What's hard or confusing:**
  - Sessions are long single scrolls. Session 1 stacks the intro, two dense panels, five steps and a timer before she gets to sit still. Session 8 has twelve practice options, two time pickers, a meals line and a save button on one page.
  - The time pickers in sessions 5, 6 and 8 all open at 23:00 when empty (`_TimeRow` uses `TimeOfDay(hour: 23)` as the default). That's sensible for "In bed by", but odd for "Wake" and "Breakfast": she has to scroll from 11 pm to 7 am.
  - The empty state of a time row is a small "Set" pill. It isn't clear that tapping the whole row opens a clock.
  - Session 8's "Set as my daily practice" saves without showing what Today will look like until after she taps. The live Today preview appears only after saving.
  - Uppercase labels ("WHAT YOU DO", "SAID PLAINLY", "AND CONFIRM THESE") read as shouting on a calm course.
  - Session 1's steps tell her to "read the four things this course leaves out", but the panel lists five refusals.
  - Progress is only a filled number circle. Some people won't notice which sessions they've opened.
- **Ideas to make it simpler:**
  - Break each session into two or three short screens (learn, do, keep) with a "Next" button, so the practice isn't buried under reading.
  - Give each time row a sensible default: Wake 06:30, breakfast 08:00, lunch 13:00, dinner 20:00, bed 23:00.
  - Show a small preview of her Today above the save button in session 8 ("Your five minutes: Box breathing, Legs up the wall").
  - Make the step "read the four things" match the panel (either say "the things" or trim the list).
  - Use sentence-case labels for the section headings.
- **Priority guess:** Medium. The default wake/breakfast time of 23:00 is a small real friction on the one screen that writes into Today. The long scrolls matter because this is the free course meant to bring people in.

### Practice player  (`lib/screens/ttc/ttc_practice_player.dart`, `lib/screens/ttc/ttc_practice_screen.dart`, data in `lib/ttc/ttc_practice_data.dart`)
- **What it's for:** Plays one of the twelve Mind & body practices (six movement, six breathing) with a timer ring, a breathing circle or a placeholder, a step list, a "skip it if" note and a "Mark done today" toggle.
- **What a first-time user meets:** Eyebrow MOVE or BREATHE AND CALM, the title, a blurb, duration and place, then a ring with a Start button. Below it, a numbered step list with small up and down arrows, the "SKIP IT IF" box and a big "Mark done today" button.
- **What's hard or confusing:**
  - The step list doesn't move with the timer. It moves only when she taps a step or the small up/down arrows, and the arrows aren't labelled. On a floor practice with the phone at arm's length, she won't know which step she's on unless she keeps tapping.
  - Five of the six movement cards have no drawing yet. The ring says "Follow the steps as you go", so the biggest thing on screen gives no guidance on the pose.
  - The breathing circle is the only cue. There's no sound or vibration, so practices done with eyes closed (body relaxation, box breathing) mean opening her eyes to check.
  - Alternate nostril breathing shows which side in small 11.5pt text under the circle. That's the one thing that matters in the practice.
  - "Mark done today" sits under the safety box. It isn't clear that it feeds the Today tab, or that tapping again undoes it.
  - When the timer ends, the page says "That's the whole thing." but the button changes to "Again". Some people may read that as a prompt to repeat.
- **Ideas to make it simpler:**
  - Label the arrows ("Previous step", "Next step"), or add a "Next" button under the lit step that's big enough to tap from the mat.
  - Offer an optional gentle vibration or soft tone at each breath change, off by default, for eyes-closed practice.
  - Show the nostril side bigger and inside the circle, since it's the point of that card.
  - Add one line under "Mark done today": "Shows as done on your Today tab. Tap again to undo."
  - Until drawings arrive, show a small still sketch of the key pose for each movement card, not only the wash icon.
- **Priority guess:** Medium. The practices work, but following steps hands-free is the core job of this screen and it currently needs repeated tapping.

### Nutrition Planner  (`lib/screens/ttc/ttc_nutrition_screen.dart`)
- **What it's for:** Shows a week of meal ideas (one per day) from the same rotation as Today's nutrition card, each with the nutrient it leans on and an Indian-kitchen tip. It isn't a plan to follow.
- **What a first-time user meets:** Title "Nutrition Planner", a one-line intro, a panel "What this week leans on" with nutrient chips, then seven day cards (Today, then weekday names) each with a nutrient pill, a meal name, a why line and a tip box, then a disclaimer. Reached from the tools hub and the `ttc_nutrition` surface. All text comes from `ttc_strings.dart` and `ttc_daily_data.dart` (not in this batch).
- **What's hard or confusing:**
  - It's called a "Planner" but she can't plan anything: no swapping a day, no saving a meal, no shopping list. The intro says so, but the title promises more.
  - One idea per day, the same for every user. It doesn't know if she's vegetarian, Jain, eats eggs, or has PCOS, even though other parts of the app ask.
  - "What this week leans on" is a vague heading for a row of nutrient names.
  - Meal ideas don't link to a recipe, so "moong dal chilla" with no method is a dead end for someone who doesn't know it.
  - Nothing here is for him, though the file header says "every day is for both of you".
- **Ideas to make it simpler:**
  - Rename it "This week's food ideas", which is what it is.
  - Filter by diet preference if the app already knows it (veg, Jain, eggs), and say so ("Showing vegetarian ideas").
  - Link each meal to its recipe where one exists in the recipe library.
  - Change the heading to "Nutrients this week" and add one plain line on why each matters, on tap.
  - Add a "Swap this day" action that picks the next idea from the rotation.
- **Priority guess:** Low to Medium. It's harmless and honest, but a first-time user will expect a planner and find a read-only list.

### Products: research page and shelf  (`lib/screens/ttc/ttc_products_screen.dart`, data in `lib/ttc/ttc_products_data.dart`)
- **What it's for:** Honest advice on the ten things couples buy while trying (folic acid, LH strips, pregnancy tests, lubricant, CoQ10, inositol, zinc, thermometer, a book, fertility blends), including when not to buy.
- **What a first-time user meets:** `TtcProductsScreen` is a facade over the unified `PvStoreScreen` (TTC stage), or `PvProductScreen` when opened from an Ask Veda link. The shelf shows each product with its band ("Highly recommended" through "Generally not needed"). A product page shows the verdict, evidence strength (Strong, Mixed, Thin), a score out of 100, parents and experts percentages, star rating and review count, "what's good", "worth considering", specs, "from people trying" quotes, "what's inside", studies, and a Buy button that leaves for Amazon.in.
- **What's hard or confusing:**
  - The score, the two percentages, the star rating, the review counts and the quotes are all seed numbers written by us (the file says so, STILL-OPEN §24.2). On screen they look measured. For a stage that refuses invented numbers everywhere else, this is the most authoritative-looking thing on the page.
  - Badges "VERIFIED" and "BESTSELLER" (on the pregnancy test and LH strips) claim things nobody has verified or counted.
  - The brand shown (Folvite, i-can, Prega News...) is an example of the category, but next to a Buy button it reads as our pick of that brand.
  - The band and the evidence are two different scales with similar words ("Worth considering" appears as both a band and a section heading). A first-time user may not see the difference between "how much we recommend it" and "how strong the proof is".
  - Some specs rows repeat the text above them, and the page is long for a ₹55 test.
  - "Not a way to improve odds" and "Only if a clinic named it" chips are useful, but they're styled like the positive chips.
- **Ideas to make it simpler:**
  - Hide the score, percentages, stars and review counts until real data exists, or label them clearly as examples. The band and evidence are enough on their own.
  - Remove "VERIFIED" and "BESTSELLER" until they mean something checkable, and keep "ParentVeda pick" only on folic acid.
  - Put "Example brand" before the brand name, and one line near Buy: "Any plain version works the same."
  - Add one line under the evidence label saying what it measures ("How strong the research is, not how much we like it").
  - Style the caution chips differently from the positive ones.
- **Priority guess:** High. The seed numbers and unverified badges are an honesty problem on a money page, in a stage built on never inventing numbers.

## Added in the gap-plan build (2026-09-26): new tools and screens, first notes

Built from the TTC gap analysis. Same rule as above: notes only, all from code, none walked on a phone yet.

### Messages  (`lib/screens/ttc/ttc_messages_screen.dart`, store `lib/ttc/ttc_messages_store.dart`)
- **What it's for:** the five moments the app speaks first (window opens, period came, late, cycle report, trying a while).
- **What a first-time user meets:** an empty list that says what will arrive and when, and switches per message.
- **What's hard or confusing:** tapping a PHONE notification only opens the app (NotificationService has no tap
  handler), so she has to find the message herself.
- **Ideas:** route the notification tap to the message's destination. Priority: **High** (the promise is "at the
  right moment", and one extra hunt breaks it).

### Guided chats: "Should I test?", "My period came", "My cycle report"  (`lib/screens/ttc/chats/`)
- **What they're for:** a calm step-by-step answer from her own dates, no AI.
- **What's hard:** entry points were missing until the home pass; the chats have no "start again" once finished.
- **Ideas:** a "Start again" chip at the end; remember the last answer for a day. Priority: Medium.

### Learn tab  (`lib/screens/ttc/ttc_learn_screen.dart`)
- **What it's for:** the library of every TTC read, film slot, story, course and question.
- **What's hard:** 122 reads is a lot; the first screen must stay short (search, Start here, Continue) with
  shelves below. Film slots show as "Coming soon" until videos are uploaded.
- **Ideas:** once films land, a "Watch" shelf near the top. Priority: Low (built to the Mobbin brief).

### Door search  (`lib/screens/ttc/doors/ttc_door_search.dart`)
- **What it's for:** find anything inside a door, then across all TTC reads.
- **What's hard:** there is no stage-wide "search everywhere" screen, so the way on is only Ask Veda.
- **Ideas:** a TTC-wide search screen reusing the Learn index. Priority: Medium.

### Whole-cycle temperature chart  (inside the symptom log)
- **What it's for:** morning temperature across one cycle with period and fertile days shaded.
- **What's hard:** it needs three readings before ovulation for the average line; early on it looks empty.
- **Ideas:** a short "how to take it" line under the empty state (already has one) plus a reminder option.
  Priority: Low.

### "Hide sex and intimacy content" switch  (`lib/ttc/ttc_content_prefs.dart`)
- **What it's for:** shared phones. Hides the Sex and closeness tab, its reads in Learn and doors, and one daily card.
- **What's hard:** it lives in You; someone who needs it may not look there. The relationship-safety read mentions
  it.
- **Ideas:** also offer it once, gently, the first time she opens the Sex and closeness tab. Priority: Medium.

### Treatment round (start, plan, result, check-in)  (`lib/screens/ttc/ttc_treatment_round_screens.dart`)
- **What it's for:** following an IUI/IVF/FET/tablets round from the clinic's dates, with the home, calendar and
  reminders switching to the round from the first treatment date.
- **What a first-time user meets:** "Starting treatment?" on the IVF door, three short screens (kind, first dates,
  what we'll show), then a dated timeline where undated steps say "Your clinic will tell you".
- **What's hard:** entering many dates by hand; a partner clinic sending them would remove most of the typing.
- **Ideas:** partner-clinic dates (B12); a "copy last round's schedule" start. Priority: Medium.
- Built to the user's rule: nothing changes silently, every close confirmed with a 7-day undo, check-ins never
  close a round on their own. Not walked on a phone yet.
