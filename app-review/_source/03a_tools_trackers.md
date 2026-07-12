# Tools & Trackers
_ParentVeda Pregnancy App - Feature & Screen Reference_

## Overview
"Tools" is one of the five bottom-navigation tabs in the mother's app (labelled Tools, using a widgets icon; it sits between the Prepare tab and the Calendar tab). Tapping it opens the Tools hub, a calm "toolbox" screen: a large "Your Pregnancy Journey" hero card at the top (which opens the journey map), then a two-column grid of tinted tiles that each launch one tool, and a reassuring support note at the bottom. The tools fall into a few groups: gentle self-tracking trackers (kick counter, weight, Kegel, contractions, medication, symptoms, scans), a warm due-date calculator, birth-preparation planners (hospital bag, product checklist), a personal reminders scheduler, a safety checker ("Can I?"), scan-report help ("Understanding Your Report"), the offline "Ask Veda" answer engine, plus shortcuts to other app features (Garbh Sanskar, Spiritual Reading, the Bump Journey, the Journal, Read Next, and the Father's Journal). The hub only appears in mother mode; in the father (Dad) view the third tab becomes the father's "Reads" section instead. Every tracker is local-first (saved on the device via shared_preferences) and, when the mother is signed in, additionally syncs to Supabase. This PDF documents the Tools hub and its trackers in detail, and a companion file continues the same PDF with the planners (hospital bag, product checklist), the reminders scheduler, the "Can I?" safety checker, the "Understanding Your Report" scan-report help, and the Ask Veda engine.

Tools covered across this PDF (this file plus its companion):

- **Tools hub** (`tools_hub_screen.dart`) - the Tools tab that launches everything (this file)
- **Older Tools screen** (`tools_screen.dart`) - a superseded earlier version (this file)
- **Baby Movement Tracker / kick counter** (this file)
- **Weight Tracker** (this file)
- **Kegel Care** (this file)
- **Contraction Tracker** (this file)
- **Due Date Calculator** (this file)
- **Symptoms Companion** (this file)
- **Medication & Supplements Tracker** (this file)
- **Scans & Appointments** (this file)
- **Hospital Bag planner** (companion file)
- **Product Checklist** (companion file)
- **Reminders / notifications** (companion file)
- **"Can I?" safety checker** (companion file)
- **"Understanding Your Report"** scan-report help (companion file)
- **Ask Veda** offline answer engine (companion file)

## Screen: Tools Hub (`tools_hub_screen.dart`)
**Status:** Live - it is the third bottom-nav tab (`ToolsHubScreen`) wired into the main app scaffold in mother mode. Justification: `main_scaffold.dart` places `ToolsHubScreen` as page index 2 of the non-father tab list.
**Reached from:** Bottom navigation pill -> "Tools" tab (widgets icon). Not shown in father mode.
**Purpose:** The single launch point ("toolbox") for every pregnancy tool, planner and tracker, with the pregnancy journey map as its hero.

**Sections & UI:**
- Screen title ("Tools") and a one-line intro under it.
- **Journey hero card:** a purple gradient card with a map icon, a title and subtitle, and a forward arrow. Tapping it opens the full pregnancy Journey Map (a separate feature).
- **Tool grid:** a two-column wrap of rounded white tiles. Each tile shows a coloured icon in a tinted square, the tool name, and an "Open ->" link in the tool's accent colour.
- **Support note card:** a rounded panel with a shield icon and a short reassurance line at the bottom.

**Features & interactions:**
- The whole screen is a scrolling list. Every tile is a tap target that pushes the matching tool screen onto the navigator.
- Tiles, in on-screen order: Garbh Sanskar; Spiritual Reading; Baby Movement Tracker; Bump Journey; My Journal; Read Next; Weight; Kegel; Contractions; Hospital Bag; Product Checklist; Medication & Supplements; Reminders; Understanding Your Report; "Can I?"; Symptoms Companion; Scans & Appointments; Due Date Calculator; Ask Veda; Father's Journal.
- Of these, the trackers documented in this file are Baby Movement, Weight, Kegel, Contractions, Medication & Supplements, Symptoms Companion, Scans & Appointments, and the Due Date Calculator. The hospital bag, product checklist, reminders, "Understanding Your Report", "Can I?" and Ask Veda tiles are covered by the companion file. The remaining tiles (Garbh Sanskar, Spiritual Reading, Bump Journey, My Journal, Read Next, Father's Journal) are other app features surfaced here for convenience and are documented in their own PDFs.
- A retired "Stories, Fables & Mythology" tile is kept commented-out in the code for possible revert; it does not appear.

**Data:** No data of its own. It reads the current language from `PregnancyController` to localise labels and simply navigates to each tool. All tool state lives in the individual tool stores.

## Screen: Older Tools Screen (`tools_screen.dart`)
**Status:** Superseded / not reachable - `ToolsScreen` is an earlier version of the Tools tab that has been replaced by `ToolsHubScreen`. Justification: a project-wide search finds no navigation that instantiates this `ToolsScreen`; only its own file references it. It is retained (not deleted) in the codebase.
**Reached from:** Nothing in the current app. (Historically it was the Tools tab landing.)
**Purpose:** An early "growing toolbox" grid: a journey feature card plus a set of tool tiles, some of which could show a "coming soon" badge.

**Sections & UI:**
- Title and intro, a "Your Pregnancy Journey" feature card (opens the Journey Map), then a two-column grid of tiles.
- Tiles here: Baby Movement, Weight, Kegel, Contractions, Hospital Bag, Understanding Your Report, Garbh Sanskar, Community, Products.
- The tile widget supports a "Coming soon" pill for tools without an action, but in the current code every listed tile has an action, so none show that pill.

**Features & interactions:**
- Each tile pushes its tool screen (same destinations as the live hub, but a shorter list and different accent colours).
- Because the screen is not wired into navigation, testers will not encounter it in normal use; note it only if verifying dead/legacy code.

**Data:** Same as the hub - it only reads language from `PregnancyController` and navigates; it holds no state.

## Screen: Baby Movement Tracker (`tools/baby_movement_screen.dart`)
**Status:** Live.
**Reached from:** Tools hub -> "Baby Movement Tracker" tile. (The Home screen's "Kicks" quick tile also reads today's movement count from the same store.)
**Purpose:** A calm, session-based "awareness" tool for baby movements from around week 28, deliberately not a running lifetime counter. Movements are grouped into sessions and the main screen never shows a long scroll of timestamps.

**Sections & UI:**
- **Disclaimer banner** (amber tint) - always visible at the top.
- **No active session (start view):** a soft card with a pregnant-woman glyph, a "start a session" title and subtitle, and a "Start Session" button.
- **Active session view:** a large circular tap target (heart glyph, "Baby moved") in the centre; a "This session" summary card; an "End Session" outlined button; and a "Remember this moment" memory card with a note field.
- **Session summary card:** a count chip ("N movements"), the last movement time, and compact time chips. Time chips are limited to the 12 most recent with a "View all times" / "Hide" toggle so a busy day never becomes an endless scroll.
- **History screen** (opened from the app-bar "History" action): one card per ended session.

**Features & interactions:**
- "Start Session" begins a session; there is no auto-start on entry.
- Tapping the big circle logs one movement; the circle briefly changes to a "Movement logged" state for about 1.3 seconds, then reverts.
- The session ends when the mother taps "End Session", when she leaves the screen, or when the app is backgrounded or closed. On ending with at least one movement, a "session saved" snackbar shows; sessions with zero movements are discarded so history stays clean. A session left open by a killed app is auto-closed on next launch.
- The memory note field saves a "Dear Baby" note (to `DailyStore`) tagged to the current week; a confirmation snackbar appears.
- History shows each ended session as a card: the date, a per-day ordinal badge ("Session 2"), start and end times, the movement count, and all of that session's time chips. Empty history shows a friendly placeholder.

**Data:** `ToolsStore` (singleton). Sessions are `MovementSession` objects persisted in shared_preferences and, when signed in, synced to the Supabase `movement_sessions` table (only ended, non-empty sessions are pushed). Legacy flat-timestamp data is migrated into one session per calendar day. Memory notes go to `DailyStore` (Dear Baby). No notifications.

## Screen: Weight Tracker (`tools/weight_tracker_screen.dart`)
**Status:** Live.
**Reached from:** Tools hub -> "Weight" tile.
**Purpose:** A supportive weight companion that reframes gain as "my body is supporting my baby", never a scorecard. It has a one-time setup and then an ongoing dashboard.

**Sections & UI:**
- **Setup flow (shown until a profile exists):** Step 1 asks for pre-pregnancy weight (required, in kg) and height (optional, in cm). Step 2 is a summary card showing the starting weight, height (if given), and a recommended gain range (only if height was entered, otherwise a note that the range needs height). A "Start tracking" button saves the profile.
- **Dashboard (once set up):** a hero card with the current weight (or an empty-state prompt) and week; a "your body is supporting..." insight card; a calm "weight gain since start" figure; a "where your weight comes from" educational bar breakdown; a "what changed" card; a weekly insight line; a weight chart; and a full history table. An "Add today's weight" button sits at the bottom, and a labelled "+ Add" button appears in the app bar once onboarded.
- **Add-weight bottom sheet** (shared by both add buttons): weight field, a date picker (any past date within the last year up to today), and an optional notes field.

**Features & interactions:**
- The recommended gain range is derived from pre-pregnancy BMI: BMI under 18.5 gives 12.5-18.0 kg, under 25 gives 11.5-16.0 kg, under 30 gives 7.0-11.5 kg, and 30+ gives 5.0-9.0 kg.
- The "where your weight comes from" breakdown is an educational estimate (baby, placenta, amniotic fluid, blood, breast tissue, energy stores) scaled by the current week from a week-23 anchor; it is explicitly labelled as an estimate, not a measurement.
- The chart is custom-drawn: an actual-weight line (dots joined by date, positioned by fractional gestational week) over a soft "recommended range" band. It deliberately uses no above/below-target or warning colours. A legend and footer note explain it.
- The history table has Date, Week, Weight and Change columns; each row shows the entry time, and long-pressing a row offers delete (with a confirm dialog). The pre-pregnancy weight is shown as a tinted "START" origin row.
- Multiple weigh-ins on the same day are all kept and never overwrite each other, so the record never appears to reset.

**Data:** `ToolsStore` holds the weight profile (pre-pregnancy weight + optional height) and a list of `WeightEntry` items, persisted in shared_preferences and synced to Supabase `weight_profile` and `weight_entries` when signed in. No notifications.

## Screen: Kegel Care (`tools/kegel_care_screen.dart`)
**Status:** Live.
**Reached from:** Tools hub -> "Kegel" tile.
**Purpose:** Pelvic-floor self-care and birth preparation, deliberately not a gamified workout (no levels, XP, streaks or achievements). It offers a pregnancy-aware routine, a guided hold/relax session, and a calm "Care Journey".

**Sections & UI:**
- **"What is a Kegel & how to do it"** - an expandable card, open by default at the top.
- **Current routine card:** shows the effective routine (hold seconds, relax seconds, reps, estimated time); an info link "Why this routine?" (opens an explanation dialog); an edit (pencil) button that opens the Customize sheet; a "Custom" badge and a "recommended" comparison line when a custom routine is active; and a "Start Care Session" button.
- **"Why am I doing this?"** - an expandable card holding the pelvic-floor intro and benefit lines.
- **Safety warning banner** - an amber-bordered card listing stop signals (pain, bleeding, dizziness, contractions).
- **Customize sheet:** plus/minus steppers for hold, relax and reps (each with the recommended value shown), a live estimated-time readout, a "Save" button, and a "Reset to recommended" button.
- **Guided session screen:** a full-screen animated ring that depletes over each phase, large "Hold"/"Relax" labels with a countdown, the current rep ("Rep X of Y"), pause/resume and exit buttons, and a voice-cue toggle in the app bar. On completion it shows a "well done" screen with three feedback buttons (Easy / Comfortable / Difficult).
- **Care Journey screen** (app-bar heart action): stat cards (stage, current routine, sessions completed, completed this week, last completed) and a history list.

**Features & interactions:**
- The recommended routine adapts by week in three stages: week 16 or under = hold 3s / 8 reps; weeks 17-28 = hold 5s / 10 reps; week 29+ = hold 8s / 12 reps. Relax time equals hold time.
- Feedback nudges difficulty over time: "Easy" gradually increases hold (then reps); "Difficult" decreases them. A custom routine, if set, overrides the recommendation until reset.
- During a session, phases auto-advance (hold then relax, repeated for all reps). Spoken cues ("Hold", "Relax", "Well done") play via text-to-speech in a normal (not baby) voice, with light haptic feedback; the voice can be muted and the setting is remembered. Pause/resume stops and continues the current phase.
- Completing a session records it: increments session counts, applies the adaptive adjustment, and adds a history entry with the chosen feedback.

**Data:** `ToolsStore` holds Kegel state (session count, this-week timestamps, last date, adaptive offsets, optional custom routine, voice on/off) and a `KegelRecord` history, persisted in shared_preferences and synced to Supabase `kegel_state` (and the history blob) when signed in. Uses `flutter_tts` for voice. No scheduled notifications.

## Screen: Contraction Tracker (`tools/contraction_tracker_screen.dart`)
**Status:** Live.
**Reached from:** Tools hub -> "Contractions" tile.
**Purpose:** A calm, non-alarmist tap-to-time contraction timer with automatic pattern insight (explicitly not a diagnosis) and a doctor-ready summary.

**Sections & UI:**
- The screen has three phases: **Home**, **Active** (a contraction is happening), and **Rest** (between contractions).
- **Home:** an "Understanding contractions" card (true vs false / Braxton Hicks and how to time one); a "this is a timer, not a medical app" disclaimer; a safety-check card; and a full-width "Contraction started" button.
- **Active:** the current contraction number, a large orange stopwatch circle counting up, "tap when it ends" text, and a "Contraction ended" button.
- **Rest:** an assessment banner, a safety card, a blue "time since last" stopwatch, stat tiles (last duration, average duration, average interval), a live list of this session's contractions (number, time, duration, interval), a "View summary" button (once there are 3+ contractions), an "End session" link, and a "Contraction started" button to begin the next one.
- **App bar:** a health/safety icon (opens the symptom safety sheet; turns red if an emergency symptom is set) and a history icon.
- **Safety sheet:** choice chips for water broken (no/yes/unsure), bleeding (none/light/heavy), reduced movement (no/yes/unsure), and severe pain (no/yes).
- **Summary screen:** a metrics grid (count, average duration, average interval, longest), the pattern line, a "consult your provider" note, and a "Copy summary" button (copies a text block to the clipboard).
- **History and session-detail screens:** a list of past sessions (with a "felt like labour" chip where answered) opening a per-contraction table.

**Features & interactions:**
- Tapping "Contraction started" times a contraction; "Contraction ended" records its duration and the interval since the previous one, then moves to Rest. Light haptics fire on each tap. The session is saved continuously as it builds and on leaving the screen.
- **Two-layer assessment engine (not a diagnosis):** Layer 1 classifies the pattern from the timings alone into insufficient / no pattern / possible early labour / labour pattern likely / active labour likely, using thresholds on average interval, duration, regularity and tracking time. Layer 2 is a medical-symptom override: any emergency symptom forces an "emergency" reading; before 37 weeks a labour-like pattern reads as "preterm". The banner always points the mother to her doctor, even on a calm "no pattern" reading.
- Once per session, if Layer 1 detects active labour (and there is no emergency), a gentle "does this feel like labour?" prompt appears; the yes/no answer is saved and shown as a chip.
- The summary can be copied for sharing with a provider.

**Data:** `ToolsStore` stores `ContractionSession` objects (each a list of `Contraction` timings plus the optional labour response), persisted in shared_preferences and synced to Supabase `contraction_sessions` when signed in. The classification/assessment logic lives in this file. No notifications.

## Screen: Due Date Calculator (`tools/due_date_calculator_screen.dart`)
**Status:** Live.
**Reached from:** Tools hub -> "Due Date Calculator" tile. (The same estimated-due-date math is shared with the sign-up "calculate your due date" sheet.)
**Purpose:** A warm "gateway" calculator: pick a method, and the result blooms into a full pregnancy roadmap ending in a button that sets the app's real due date.

**Sections & UI:**
- **Input view:** a header and subtitle; five method cards (Last Menstrual Period, Conception date, IVF, Ultrasound, Known due date); method-specific inputs; and a "Calculate" button (enabled only once the required date is provided).
- Method inputs: LMP shows a date field plus a cycle-length slider (21-35 days); Conception shows a date field; IVF shows a transfer-date field plus a day-3/day-5 embryo chooser; Ultrasound shows a scan-date field plus gestational-age week/day steppers; Known shows a future-date field.
- **Result "roadmap" view:** a celebration card with the estimated due date and current week/day/trimester; a "you are here" timeline bar; a key-milestones checklist; a trimester breakdown with date ranges; a conception window with a 9-month circle strip; and a conversion card that lists app benefits and a "Start My Pregnancy Journey" button. A "Recalculate" link returns to the input view.

**Features & interactions:**
- Estimated due date math: LMP = LMP + 280 days adjusted for cycle length; Conception = date + 266 days; IVF = transfer + (266 - embryo day); Ultrasound = scan date + (280 - gestational age); Known = the date as entered.
- If the mother already has a due date set, the screen opens straight to the saved roadmap (with the Recalculate option) rather than a blank calculator.
- The milestones checklist ticks off weeks 8, 12, 20, 24, 28, 37 and 40 based on the computed current week.
- "Start My Pregnancy Journey" writes the due date into the app (via `PregnancyController.setDueDate`), shows a confirmation snackbar, and pops back to the app's first screen so the whole app now runs on that date.

**Data:** Uses `PregnancyController` only; the calculator itself has no store. Setting the due date persists through the controller (used app-wide). No notifications.

## Screen: Symptoms Companion (`tools/symptom_companion_screen.dart`)
**Status:** Live.
**Reached from:** Tools hub -> "Symptoms Companion" tile.
**Purpose:** A calm understanding-and-reassurance library (not a symptom checker): search or browse symptoms and read how common each is, why it happens, what may help, and when to call the doctor. Logging is optional.

**Sections & UI:**
- **Search field** at the top.
- **When not searching:** a "common around week N" list (up to 8 non-urgent symptoms common in the current trimester); a "browse by category" chip row (digestive, physical, sleep, emotional, circulation, movement, labour); a calmly-flagged **urgent** card listing urgent symptoms; and an "All" (or selected-category) list.
- A small disclaimer line at the bottom.
- **Detail screen:** the symptom name and icon; an optional "you've noted this N times this week" insight (shown when logged 2+ times); "How common is it", "Why it happens", "What may help" (tip bullets); a "When to contact your doctor" panel (always shown, more prominent for urgent symptoms); and, for non-urgent symptoms, a "Log this" button.
- **Log sheet:** a severity chooser (mild / moderate / severe), a notes field, and an "add to Journal" switch (on by default).

**Features & interactions:**
- Search matches the symptom name and its keyword synonyms in either language.
- Category chips toggle a filtered list; tapping a symptom row opens its detail page.
- Logging a symptom records severity and notes; with the switch on it also creates a Journal entry (which in turn surfaces in the Calendar). A confirmation snackbar appears. Urgent symptoms are read-only (no log button).

**Data:** Symptom content comes from `kSymptoms` in `data/symptom_data.dart` (bilingual, English + Hindi). Optional logs are held by `SymptomStore` (persisted in shared_preferences, synced to Supabase `symptom_logs`), and journal entries via `JournalStore`. No notifications.

## Screen: Medication & Supplements Tracker (`tools/medicine_tracker_screen.dart`)
**Status:** Live.
**Reached from:** Tools hub -> "Medication & Supplements" tile.
**Purpose:** A gentle "nourishment companion" for tracking doctor-recommended supplements and medicines: mark them taken each day, see a weekly awareness view, and read supplement education. It is tracking only, never advice, and never gamified.

**Sections & UI:**
- **Setup / empty state:** a friendly header, a wrap of preset supplement chips (Iron, Calcium, Folic Acid, Vitamin D, DHA, Multivitamin), an "Add custom" button, and a disclaimer.
- **Main view:** a Daily / Weekly segmented switch, plus a floating "Add new" button.
- **Daily tab:** a "Today's Nourishment" card with a progress bar (taken vs total) and each medicine as a row with a mark-as-taken toggle. Tapping a row opens a details sheet.
- **Weekly tab:** each medicine with a "days of 7" count, plus a 30-day consistency line.
- **Add / edit form:** name, dose, time, frequency and notes fields.
- **Details sheet:** the medicine name and details, the preset educational blurb (for preset supplements), any notes, and a delete option (with a confirm dialog).

**Features & interactions:**
- Choosing a preset chip pre-fills the form with that supplement's name; "Add custom" opens a blank form. Saving adds the medicine.
- The taken toggle is a once-per-day model: tapping marks it taken today (with a snackbar) or un-marks it. The progress bar and weekly counts update accordingly.
- Weekly stats are gentle and judgment-free (distinct days taken in the last 7, and days in the last 30 with at least one medicine logged); there are no streaks.

**Data:** `MedicineStore` holds `Medication` items and `MedicationLog` entries (persisted in shared_preferences, synced to Supabase `medications` and `medication_logs`). Preset keys and educational text come from `models/medication.dart` and the string table. No scheduled notifications from this screen (reminders are a separate tool).

## Screen: Scans & Appointments (`tools/scans_appointments_screen.dart`)
**Status:** Live.
**Reached from:** Tools hub -> "Scans & Appointments" tile. (The Home screen's "Scans & appointments" due-now card reads from the same store.)
**Purpose:** A calm, confidence-building care roadmap (not hospital software): see upcoming and completed scans, learn what each scan is and how to read its report, mark scans done, and add your own appointments.

**Sections & UI:**
- A **Upcoming / Completed** segmented switch, and an app-bar "+" to add an appointment. (A third "Care Roadmap" tab existed but has been removed from the UI; its code is kept commented for revert.)
- **Upcoming tab:** a "Next up" hero card for the nearest scan (its name, week range, "in N days", a short "why" line, and Learn more / Mark done buttons); simpler rows for later scans; and an "Appointments" section for the mother's own appointments. If nothing is pending it shows an "up to date" note.
- **Completed tab:** completed scans (with the date marked done) and past appointments.
- **Scan detail screen:** a "What is this scan?" intro card; the scan's information sections and bullet lists; an "important note"; a "How to interpret the report" link (opens a full-screen glossary); and a Mark done / undo button.
- **Interpret screen:** a large, unmissable "not for medical diagnosis" disclaimer, then a term-by-term glossary of what a report's values mean.
- **Add-appointment sheet:** a type chooser (doctor, scan, test, vaccination, custom), a title field, a date picker, and time / location / doctor / notes fields.

**Features & interactions:**
- Scan dates are computed from the mother's due date and each scan's anchor week, so "Next up" and "in N days" are personalised.
- "Mark done" (from the hero, a row, or the detail page) records the scan as completed and creates a Journal "Scans" entry; it can be undone.
- Adding an appointment stores it and makes it appear in the Calendar's "Appointment" lane; each appointment row has a delete control.
- **Partner sharing:** when paired and signed in, a scan reads as done if either partner marked it, and both partners see all appointments (the partner's rows are read-only, pulled from the cloud).

**Data:** Scan content is reused from `kJourneyMilestones` (medical milestones) plus `data/scan_guide_data.dart` (the "what is" intros and interpret glossaries, bilingual English + Hindi). The mother's own data (`CompletedScan`, `Appointment`) lives in `ScansStore`, persisted in shared_preferences and synced to Supabase `completed_scans` and `appointments`; completed scans link into `JournalStore`. No notifications from this screen.
