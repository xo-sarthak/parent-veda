# Prepare, Community, Calendar & Shop
_ParentVeda Pregnancy App - Feature & Screen Reference_

## Overview

**Prepare** is the mother-side commerce hub. It is the second tab in the floating bottom nav (a graduation-cap "school" icon labelled "Prepare"), sitting between Today and Tools. It replaced the old Journey tab in the bottom bar (the weekly stack is now reached from the Home hero and Tools). The Prepare tab opens a hub screen that routes into five paid sections: **Masterclasses** (deep-dive live expert sessions), **1:1 Consultations** (private video calls with five specialists), **Cohort Programs** (small guided group programmes), **Prenatal Yoga** (a trimester-safe movement program), and **Birthing Classes** (a six-class course for the big day). Each section has a list screen and, where relevant, a detail screen; masterclass intros, yoga sessions and birthing classes all "play" into one shared placeholder video screen.

Crucially, **all Prepare commerce is a mock**. No payment gateway is wired. A booking sheet reserves a spot, persists an id to local storage (`PrepareStore` via SharedPreferences), and flips the button to a "booked" state, but explicitly tells the user "Payments aren't live yet - nothing is charged now." The video player shows a "Video coming soon" placeholder. All content is static, hardcoded to the "Priya, 30 weeks, third trimester" persona.

This PDF also covers three sibling clusters documented in a companion file: **Community** (a social feed tab, the fifth bottom-nav tab, groups icon; plus per-author profile pages and the `ExpertFollowStore` follow-experts feature - note that following is a Community feature and is NOT used inside Prepare), **Calendar** (the fourth bottom-nav tab, a pregnancy calendar), and the **Shop/Cart** (a product marketplace reached from Tools, Home, global search, Ask Veda, and checklist tools, with a preview-checkout cart that also takes no real payment).

Screens in this PDF:

- **Prepare Hub** (`prepare_hub_screen.dart`) - Prepare tab root
- **Masterclasses** (`masterclasses_screen.dart`) - list
- **Masterclass Detail** (`masterclass_detail_screen.dart`)
- **1:1 Consultations** (`consultations_screen.dart`) - list
- **Consultation Detail** (`consultation_detail_screen.dart`) - specialist profile + slot booking
- **Cohort Programs** (`cohorts_screen.dart`) - list
- **Cohort Detail** (`cohort_detail_screen.dart`)
- **Prenatal Yoga** (`prenatal_yoga_screen.dart`)
- **Birthing Classes** (`birthing_classes_screen.dart`)
- **Prepare Video Player** (`prepare_video_screen.dart`) - shared placeholder
- **Prepare Shared Components** (`prepare_common.dart`) - palette, widgets, mock booking flow
- **Community feed + Community profile** (companion file)
- **Calendar** (companion file)
- **Products / Shop and Cart** (companion file)

## Screen: Prepare Hub (`prepare_hub_screen.dart`)
**Status:** Live - the working root of the Prepare bottom-nav tab. Content is a static replica of the design mock.
**Reached from:** Bottom nav bar, the "Prepare" tab (second tab, school icon). No back button; it is a tab root.
**Purpose:** Landing page for the five guided/paid Prepare experiences, with a recommended rail and a category list.

**Sections & UI:**
- Top bar: title "Prepare" on the left, a visual-only "EN / हिं" language toggle on the right (English + Hindi; not functional).
- Hero block: coral eyebrow "30 WEEKS - THIRD TRIMESTER", large headline "Prepare for your baby, one guided step at a time.", and a sub-line about live classes, expert sessions and gentle movement.
- "RECOMMENDED AT 30 WEEKS" label, then a horizontal rail of two cards: "Birth Confidence Masterclass" (90 min live, Rs 799) and "Birth-Ready Bootcamp" (Cohort, 4 weeks, Rs 6,999). Each card has a striped image placeholder, a tag, title, and price meta.
- A vertical list of five category tiles, each with a purple icon chip, title, one-line description, an item count on the right, and a right-arrow glyph: Masterclasses ("4 sessions"), 1:1 Consultations ("5 specialists"), Cohort Programs ("4 programs"), Prenatal Yoga ("6-week program"), Birthing Classes ("6-class course").
- Footer panel: "Most of this is free with ParentVeda+." (ParentVeda+ is a referenced but unbuilt subscription concept.)

**Features & interactions:**
- Tapping the first rail card opens the featured Masterclass Detail; the second rail card opens the featured Cohort Detail.
- Tapping each of the five category tiles pushes the matching section screen (Masterclasses, Consultations, Cohorts, Prenatal Yoga, Birthing Classes).
- The language toggle is decorative only.

**Data:** Pulls the featured masterclass and featured cohort from `kMasterclasses` / `kCohorts` in `prepare_data.dart`. No commerce here; purely navigation.

## Screen: Masterclasses (`masterclasses_screen.dart`)
**Status:** Live - data-driven list. No real payment.
**Reached from:** Prepare Hub -> "Masterclasses" tile (or the recommended rail's first card, which jumps straight to the detail).
**Purpose:** Browse the four masterclasses; open any for the full detail page.

**Sections & UI:**
- Back row ("Prepare") plus the visual language toggle.
- Eyebrow "LIVE WITH AN EXPERT", headline "Masterclasses", sub-line, and a lavender context banner: "You're 30 weeks - birth is on your mind. Start here."
- Featured card (the "Birth Confidence Masterclass"): striped image with a coral badge pill ("Most-booked at 30 weeks"), title, one-line description, a coach avatar + coach line, a divider, then a price row ("Rs 799 - free on ParentVeda+") with a filled "Reserve a seat" button.
- "More masterclasses" list: each of the other three shows title, price, one-line description, an optional chip (for example "Great to catch up on", "Coming up next"), and a "live + recording" tag.
- Footer note: "Always live with an expert. The recording is yours forever. Free for ParentVeda+."

**Features & interactions:**
- Tapping the featured card, its "Reserve a seat" button, or any row in "More masterclasses" opens that Masterclass Detail screen. (The button here does NOT book directly; it navigates to the detail, where booking happens.)

**Data:** Lists from `kMasterclasses` (four entries). Featured entry is the one flagged `featured: true`.

## Screen: Masterclass Detail (`masterclass_detail_screen.dart`)
**Status:** Live layout; booking and video are mocked.
**Reached from:** Masterclasses list, the Prepare Hub rail, or any masterclass card.
**Purpose:** Full sales/detail page for one masterclass, with a sticky reserve button that runs the mock booking flow.

**Sections & UI:**
- Hero: striped placeholder image with a back circle, the visual language toggle, a centered white circular play button, and a "Watch the 90-sec intro" chip.
- Below: an optional badge pill, large title, long description, and a row of three quick-fact tiles (for example "90 min / live", "Sun 13 Jul / 8:00 pm", "Forever / recording").
- "What you'll walk away with" - a checklist of learning outcomes with purple check marks.
- "Meet your coach" / "Meet your coaches" - one or two coach blocks (striped avatar, name, role, bio).
- "What mothers say" - testimonial cards with five coral stars, quote, and attribution (only when the masterclass has testimonials).
- "Common questions" - an FAQ list. Items with an answer render open (question, minus sign, answer text); items without an answer render collapsed (question, plus sign). NOTE: the FAQ rows are static - the plus/minus are visual only and do not expand or collapse on tap.
- Footer note: "Led by a verified expert. Free with ParentVeda+."
- Sticky bottom bar (`PvStickyCta`): price, "free on ParentVeda+" note, and a "Reserve a seat" button.

**Features & interactions:**
- Tapping the hero play button opens the shared Prepare Video Player with the title "<class> - intro" and subtitle "90-sec preview" (placeholder, no real video).
- The sticky "Reserve a seat" button opens the mock booking sheet (heading "Reserve your seat", CTA "Reserve my seat"). Confirming persists the booking; the sticky button then shows "Reserved" in a panel style. Tapping the "Reserved" button opens a "Cancel this?" dialog to un-reserve.

**Data:** Renders any `Masterclass` object from `prepare_data.dart`. Booked state is stored in `PrepareStore` (SharedPreferences), keyed by the masterclass id. Commerce is mocked - nothing is charged.

## Screen: 1:1 Consultations (`consultations_screen.dart`)
**Status:** Live - data-driven list. No real payment.
**Reached from:** Prepare Hub -> "1:1 Consultations" tile.
**Purpose:** Browse the five verified specialists; open any profile to book a call.

**Sections & UI:**
- Back row ("Prepare") and language toggle.
- Eyebrow "PRIVATE & PERSONAL", headline "1:1 Consultations", sub-line, and a banner: "Something on your mind after your 30-week scan? Talk it through."
- A list of five specialist rows: icon chip, role (for example "Obstetrician"), a "from Rs ___" price, the specialist name plus first credential, a one-line description, a coral star rating, a "Hindi / English" tag, an optional "Next: today 6pm" availability, and an outlined "Book" button.
- "How it works" panel: "Pick an expert -> pick a slot -> private video call. Notes saved to your health record." (Health-record saving is described copy, not a wired integration.)
- Footer note about verified specialists, real ratings, transparent pricing.

**Features & interactions:**
- Tapping a specialist row or its "Book" button opens that Consultation Detail (specialist profile).

**Data:** Lists from `kSpecialists` (five entries: Obstetrician Rs 999, Nutritionist Rs 599, Lactation Rs 799, Counsellor Rs 899, Physiotherapist Rs 699). No follow/save on this screen; there is no wired follow button (the app's `ExpertFollowStore` follow feature belongs to Community, not Prepare).

## Screen: Consultation Detail (`consultation_detail_screen.dart`)
**Status:** Live layout; slot selection works; booking is mocked.
**Reached from:** Consultations list -> a specialist.
**Purpose:** Specialist profile page with selectable time slots and a sticky book button running the mock booking flow.

**Sections & UI:**
- Back row ("Consultations") and language toggle.
- Header: striped avatar, name, "role - credentials", coral star rating, and a "<N> mothers" count (computed as review count times 160, so it is a fabricated display number, not a real count).
- Language/format chips: "Hindi", "English", "Video call".
- "About <name>" paragraph.
- "She can help with" checklist.
- "Choose a time": a hardcoded date label "Today, 8 Jul" and a horizontal row of selectable time-slot chips (default four: 6:00 pm, 6:30 pm, 7:15 pm, 8:00 pm). The selected chip turns purple.
- "From mothers she's seen" - review cards (name, when, five coral stars, quote).
- "How it works" panel: "Pick a slot -> private video call -> notes saved to your health record."
- Sticky bottom bar: consult price, "30-min call" note, and a "Book for <selected slot>" button (label updates as you pick a slot).

**Features & interactions:**
- Tapping a time-slot chip selects it (updates the sticky button label). Selection is UI-only; it is not persisted beyond the current screen.
- The sticky "Book for ..." button opens the mock booking sheet (heading "Confirm your consult", CTA "Confirm booking", showing "Today, 8 Jul + slot"). Confirming persists the booking; the button then reads "Booked", and tapping it offers a cancel dialog.

**Data:** Renders any `Specialist` from `prepare_data.dart`. Booked state via `PrepareStore` keyed by specialist id. Slots come from each specialist's `slots` list. Commerce mocked.

## Screen: Cohort Programs (`cohorts_screen.dart`)
**Status:** Live - data-driven list. No real payment.
**Reached from:** Prepare Hub -> "Cohort Programs" tile (or the hub rail's second card, which jumps to the featured cohort detail).
**Purpose:** Browse the four cohort programmes; open any for detail.

**Sections & UI:**
- Back row ("Prepare") and language toggle.
- Eyebrow "TOGETHER, GUIDED", headline "Cohort Programs", sub-line, and a banner referencing the Birth-Ready cohort starting Monday.
- Featured cohort card (purple panel): a "Recommended - 30 to 34 weeks" pill, a seats-left line ("32 of 100 seats left"), name, duration + start, description, a coach avatar/line, divider, price, and a filled "Join the next cohort" button.
- "More programs" list: each row shows name, price, description, and a duration/timing meta line.
- "What's inside every cohort" panel: live sessions, small peer group, weekly homework, a private WhatsApp group, plus a "Rs 500 credit for ParentVeda+" line.
- Footer note.

**Features & interactions:**
- Tapping the featured card, its button, or any "More programs" row opens that Cohort Detail. The button here navigates to the detail (does not book directly).

**Data:** Lists from `kCohorts` (four entries, Rs 4,999 to Rs 7,999). Featured is the entry flagged `featured: true` (Birth-Ready Bootcamp).

## Screen: Cohort Detail (`cohort_detail_screen.dart`)
**Status:** Live layout; join/enroll is mocked.
**Reached from:** Cohorts list, or the Prepare Hub rail.
**Purpose:** Full detail for one cohort, with a sticky join button running the mock enroll flow.

**Sections & UI:**
- Back row ("Cohort Programs") and language toggle.
- Header: optional "Recommended" pill and seats-left line, large cohort name, description.
- Three quick-fact tiles: duration ("programme"), start date or the for-whom window ("start" / "timing"), and "Live / + peer group".
- "What's inside" checklist.
- "The plan" - a numbered week-by-week schedule (only when the cohort defines one).
- "Your coach" block (avatar, name, "Leads every live session and the group.").
- "From mums who did it" - review cards (only when present).
- A "Rs 500 credit for ParentVeda+ members on any cohort." panel.
- Footer note.
- Sticky bottom bar: price, duration note, "Join the next cohort" button.

**Features & interactions:**
- The sticky "Join the next cohort" button opens the mock booking sheet (heading "Join this cohort", CTA "Join cohort"). Confirming persists it; the button then shows "Enrolled" and tapping it offers a cancel dialog.

**Data:** Renders any `Cohort` from `prepare_data.dart`. Enrolled state via `PrepareStore` keyed by cohort id. Commerce mocked.

## Screen: Prenatal Yoga (`prenatal_yoga_screen.dart`)
**Status:** Live and interactive; the videos are placeholders and there is no real payment.
**Reached from:** Prepare Hub -> "Prenatal Yoga" tile.
**Purpose:** A trimester-safe yoga program. Shows the safe (third-trimester) session track and hides earlier-trimester tracks as "not safe at 30 weeks".

**Sections & UI:**
- Back row ("Prepare") and language toggle.
- Eyebrow "SAFE FOR YOUR STAGE", headline "Prenatal Yoga", sub-line, and a shield-icon banner explaining that unsafe content for 30 weeks is hidden.
- Program card: striped image, "Prenatal Yoga Program", "6 weeks - with Sana Kapoor, certified prenatal instructor", and pricing "Rs 599 - Free with ParentVeda+".
- Trimester tabs: "Trimester 1" and "Trimester 2" both show a lock icon; "Trimester 3 - here" is active by default.
- When Trimester 3 is selected: a list of five yoga sessions (title, "duration - focus", a "Safe for you" pill, and a small play triangle).
- When a locked trimester tab is selected: a panel explaining those poses aren't safe at 30 weeks, with a "Back to my safe track" button.
- Italic note and a footer note about content being filtered for the exact week.

**Features & interactions:**
- Tapping the Trimester 1 or 2 tab switches to the locked-track explanation panel; "Back to my safe track" returns to Trimester 3.
- Tapping any of the five sessions opens the shared Prepare Video Player (title, "duration - focus" subtitle, and the session blurb) - placeholder, no real video.
- There is no buy/enroll action on this screen; the program price is display-only.

**Data:** Sessions from `kYogaSessions` (five entries) in `prepare_data.dart`. Tab state is local screen state only.

## Screen: Birthing Classes (`birthing_classes_screen.dart`)
**Status:** Live and interactive; enroll is mocked, videos are placeholders.
**Reached from:** Prepare Hub -> "Birthing Classes" tile.
**Purpose:** A six-class birthing course. Class 1 is a free preview; a mock enroll unlocks classes 2 through 6.

**Sections & UI:**
- Back row ("Prepare") and language toggle.
- Eyebrow "FOR THE BIG DAY", headline "Birthing Classes", sub-line, and a banner ("You're 30 weeks - exactly when most mums prepare for birth.").
- Overview card: "Complete Birthing Course", "6 classes - self-paced video + a monthly live Q&A", a coach line (Meera Nair, OB-reviewed), and a price/CTA row. Before enrolling: "Rs 1,499 - free on ParentVeda+" with a "Free preview" button. After enrolling: "Enrolled" with a "Start watching" button.
- "The 6 classes" list: each row shows number, title, duration, and a status marker - class 1 has a "Free preview" pill; when enrolled, all rows show a play triangle; when not enrolled, classes 2 to 6 show a lock icon.
- When not enrolled, a full-width "Enroll - unlock all 6 classes" button.
- Footer note.

**Features & interactions:**
- The overview button plays class 1 into the Prepare Video Player (free preview).
- Tapping an unlocked class (class 1 always, or any class once enrolled) plays it into the Prepare Video Player. Tapping a locked class opens the mock enroll flow.
- The "Enroll" button (and any locked class) opens the mock booking sheet (heading "Enroll in this course", CTA "Enroll now"). Enrolling persists the course id and unlocks all classes; the UI reacts live via `PrepareStore`.

**Data:** Classes from `kBirthingClasses` (six entries; class 1 flagged `free: true`). Enrollment tracked in `PrepareStore` under the fixed id `course_birthing`. Commerce mocked.

## Screen: Prepare Video Player (`prepare_video_screen.dart`)
**Status:** Placeholder - no real video playback is wired.
**Reached from:** Masterclass Detail (intro), Prenatal Yoga (each session), Birthing Classes (each unlocked class).
**Purpose:** A calm placeholder "player" that stands in for real clips, showing the title and blurb, ready for a real player to be dropped in later.

**Sections & UI:**
- Back row ("Back") and language toggle.
- A 16:10 striped "player" surface with a centered white play button and a "Video coming soon" chip.
- Below: the passed title, an optional purple subtitle (for example "18 min - opening"), an optional blurb paragraph, and a lavender panel: "The full video lands here soon. We'll notify you when it's ready to watch."

**Features & interactions:**
- None functional beyond the back navigation. The play button does not play anything.

**Data:** Purely presentational; takes title / subtitle / blurb as constructor arguments from the calling screen.

## Screen: Prepare - Shared Components (`prepare_common.dart`)
**Status:** Live - shared styling and building blocks used by every Prepare screen. Contains the mock booking flow. This is a support file, not a navigable screen.
**Reached from:** Not a screen; imported by all Prepare screens (and `prepare_data.dart`).
**Purpose:** Holds the "Warm Nest" palette, text styles, and reusable widgets so every Prepare screen renders consistently, and it implements the shared mock booking flow.

**Sections & UI (what it provides):**
- Palette constants (canvas, ink, purple, coral, panel, borders, etc.) and text styles (Fraunces headings, Manrope/Jakarta body).
- Reusable pieces: the "EN / हिं" language toggle (visual only), the top bar (title or back row), eyebrow labels, pills, lavender banners, primary/outline buttons, a diagonal-striped image placeholder (`PvStriped`, standing in for all imagery and video thumbnails), and a striped coach/expert avatar.
- `pvComingSoon(...)` - a helper that shows a "<X> opens soon" snackbar for CTAs without a backend.

**Features & interactions (the mock booking flow):**
- `showPrepareBooking(...)` opens a bottom sheet with two states. State 1 (confirm): the item title, an optional "when" line, the price, and the disclaimer "We'll hold your spot and remind you before it starts. Payments aren't live yet - nothing is charged now.", plus a confirm button. Tapping confirm calls `PrepareStore.book(id)` and switches to State 2 (success): a check mark, "You're all set!", a message that the item is "saved to your Prepare list", and a "Done" button. This single sheet powers reserving a masterclass, booking a consult, joining a cohort, and enrolling in the birthing course.
- `PvStickyCta` - the sticky bottom bar shared by all detail screens. It watches `PrepareStore` and shows either the buy button (purple) or, once booked, a panel-styled "<check> <Reserved/Booked/Enrolled>" button. Tapping the booked button opens a "Cancel this?" dialog ("Keep" / "Cancel it") that calls `PrepareStore.cancel(id)`.

**Data:** `PrepareStore` (singleton `ChangeNotifier`, `prepare_store.dart`) stores the set of "booked" item ids in SharedPreferences under key `prepare_booked_v1`, so reservations survive an app restart. Its own comments state the Prepare commerce flows are a mock with no payment gateway, and that this store is the seam where a real commerce backend would later plug in. `prepare_data.dart` is the single static source of all Prepare content (masterclasses, specialists, cohorts, yoga sessions, birthing classes), described in its comments as a faithful static replica of the design mock, not yet week-adaptive or CMS-backed.
