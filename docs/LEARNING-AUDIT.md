# Learning audit — one funnel for courses, masterclasses, cohorts and 1:1 consults (Mobbin audit #11)

**Date:** 2026-09-20. Research in the morning; built the same day on the
user's green light, with all five §8 decisions taken as recommended.

**Asked, in the user's words:** *"See how other apps are handling courses
screens — the funnel design for the courses, the masterclasses, the cohorts
and the one-on-one consultation screens. In our application there are a lot
of screens like that and they are very inconsistent. Formulate the screens
that are very much needed, so we will be applying those particular screens
everywhere."*

---

## 1. What we have — twenty-four screens for four things

The engine underneath is already one: `lib/booking/` has one `Offering`
model with five kinds (`masterclass · consult · cohort · classPack ·
subscription`), three formats (`liveGroup · liveOneToOne · recorded`), one
`BookingStore`, one entitlement-then-slots rule, one stage tag so a
fertility consult and a postnatal yoga pack sit in one history, and the
call is LiveKit in-app with no link to paste. **That layer needs nothing.**

What sits on top of it is three stages' worth of screens built at different
times to different briefs:

| Stage | Landing | Detail / funnel | Book | After |
|---|---|---|---|---|
| Pregnancy (`prepare/`) | `CoursesCohortsScreen` (grid + 3 kind filters); older `MasterclassesScreen`, `CohortsScreen`, `ConsultationsScreen`, `BirthingClassesScreen` still reachable | `MasterclassDetailScreen`, `CohortDetailScreen`, `ConsultationDetailScreen` (a slot picker, now bypassed when an `Expert` exists) | mock "Reserved" / "Enrolled" | — |
| Parenting (`post_pregnancy/`) | `CoursesExploreScreen` (1,000 lines: expert banner → search → type → topic → Chosen for you → three rails); older `CoursesScreen`, `MasterclassesScreen`, `CohortCoursesScreen` | `CourseFunnelScreen`, `MasterclassFunnelScreen`, `CohortFunnelScreen` (three different page orders), `CourseDetailScreen` + `CourseLessonScreen`, `YogaClassScreen` | `showBookingSheet` (real engine), `provider_booking_sheet` (mock) | `MyBookingsScreen` |
| TTC (`ttc/`) | `TtcPrepareScreen` (categories) | `TtcGarbhCourseScreen` (1,021 lines, free course + session) | engine | same history |
| Expert | — | `ProviderProfileScreen` (1,179 lines; since 4bef5cd the one doctor page, keyed by the doctor, sessions + Book pill) | `showBookingSheet` | — |
| Doctor app | `DoctorClassesScreen` | — | — | — |

Three display models describe "what is this thing" — `LearningProgram`
(parenting), `PrepProgram` (pregnancy), `YogaClass` — plus `Expert` and
`Specialist`, and the TTC course is its own type. Three catalogues, three
grammars for the same fact strip ("2 weeks · 6 classes" is written three
ways), and a masterclass funnel whose section order differs from the cohort
funnel two files away.

The inconsistency the user sees is not in the engine. It is that **the page
for a thing you can book was written once per kind per stage** instead of
once per kind, and the kind was never made a parameter.

---

## 2. Asked (the Mobbin pass)

One query per screen type, iOS, deep mode. Apps that answered, in the order
they were found:

| Screen type | Query | Who answered |
|---|---|---|
| Recorded course detail | browse a course catalog, open a course detail page with curriculum and instructor, then enroll | **Coursera** (syllabus modules, instructors, FAQ, "See enrollment options · Starts Feb 19"), **Udemy** (what you'll learn · curriculum "14 sections · 88 lectures · 26h" · this course includes · requirements · description · instructor · student feedback · sticky price + Buy now), Uxcel Go |
| Masterclass | MasterClass app browse classes, open a class page with lessons list and instructor bio | **MasterClass** (Trailer + My List; *Lessons / Overview* tabs; class resources; lessons with duration, blurb, download; related classes; FAQ). Its *Sessions* product is a cohort: Length · Outcome · Feedback · Structure · Difficulty grid, full curriculum, projects, "get feedback from a supportive community", one *Start session* button |
| 1:1 booking | book a one-on-one video consultation with a doctor or therapist: choose, pick a slot, confirm and pay | **Alan** (pick a therapist: availability line + languages + topic chips → profile with *See availabilities* and "From €70 · free cancellation 48 h" under it → week strip + slots grouped Afternoon / Evening → *Your appointment* review: person · date and time range · price · policy · "By confirming you commit to attending" → Pay), **Zocdoc** (video/in-person toggle, slot grid by day, *Review and book*, then *Appointment booked! Add to calendar · Prepare for appointment*) |
| Multi-week program | multi-week guided program page showing weekly structure, start date, live sessions and a join button | **Peloton** (hero · blurb · fact strip *1 week · 7 days/week · 8 classes · 15–30 min/day* · coach · equipment · recommended schedule · *Start program*), **Tonal** (2 coaches, *3,972 currently joined*, weekly cadence dots, *Join program*), **pliability** (*Review program*: start date picker, weeks as cards, *Start*), Tempo, Centr, Withings, Nike Run Club |
| Live schedule | schedule of upcoming live classes by date and time with instructor and reserve | **Peloton** (*Live & Encore / Your schedule* tabs, date strip, rows with LIVE tag and a tick), Open, Equinox+ |
| Dated group session | Airbnb experience detail, choose a date with available seats, reserve | **Airbnb Experiences** (host line · three trust rows: value, top-rated host, cancellation · what you'll do · *Upcoming availability* cards "Fri May 30 · 2–3:30 PM · **8 spots left**" · sticky "From $45 / person · *Show dates*" · date cards with *Choose* · confirm and pay · *Trips: upcoming reservations* "In 2 months") |
| Expert page | tutor or coach profile with intro video, about, specialties, reviews, price and book | **Preply** (intro video hero, stat strip *verified · ★5 · $3/lesson · 33 reviews · 689 lessons*, trust rows *100% refundable · high demand*, sticky message + *Buy trial lesson*), **Mindvalley** (*Expert in* chips, counts strip, *All / Programs / Meditations / Mastery* tabs of what she offers), Alan, Zocdoc |
| Learning hub | learning home with continue where you left off, upcoming session, rows by category | **Skillshare** (*Continue watching* "2m left in lesson"), **Udemy** *My learning*, **Waking Up** ("Day 4 of 28"), Speak (*Your courses* with progress + activity log), Noom (*Current mini-course 66%* pinned above the library) |
| Booked session | upcoming booked session with countdown, join, calendar, reschedule/cancel | **Peloton** (big time · avatar · class · "You are counted in" + friends + Invite · "Starting in 5 days" · Add to calendar · View schedule), **Zocdoc** (three round actions *Call · Directions · Cancel or reschedule* · *How to prepare for your visit*), **Preply** (schedule → sheet: Reschedule / Cancel lesson), Peanut (live session sheet: "Live in 1 day, 4 hours" · Share · Copy link · Add to cal · *Reminder set*) |
| Lesson player | course lesson video player with title, next lesson and the list below | **Udemy** (video · title · *Lectures / Downloads / More* · sections with "01:52 mins remaining"), **Coursera** (*Transcript / Notes / Summary / Attachments* · Previous / Next), **MasterClass** (Share · Bookmark · Download · blurb · *Up next / Moments*), Mindvalley (hero + *29 lessons · 11h 34m · 369,483* + *Play Lesson 1* + Overview / Lessons / Resources) |
| Parenting-specific | prenatal or parenting class page with expert and live date | Nothing from a parenting app with a real funnel. Peanut's live-audio sheet and Tiimo's "Expert-led courses" hero are the closest; Apple Store's *Today at Apple* session page ("4 more sessions · Sign up") is the cleanest dated-session card |

Mobbin flows worth opening: Coursera course detail
`mobbin.com/flows/fa36b8c4…`, Udemy course detail `…/43f70c32…`, MasterClass
class detail `…/1cbf874d…` and session detail `…/ecaffa87…`, Alan book an
appointment `…/e299d5a4…`, Zocdoc booking `…/fcd6461e…`, Airbnb experience
detail `…/c0e1d7e3…` and booking `…/5f4115be…`, Peloton scheduling
`…/d7105a25…`.

---

## 3. Found — the decisions, not the looks

**3.1 Every good funnel is the same page with a different fact strip.**
Udemy's course, MasterClass's class, Peloton's program, Airbnb's experience
and Alan's therapist share one order: *hero · title · who · a strip of four
facts · trust · what you get · the structure · the person · proof · FAQ ·
related · a sticky bar with a price and one verb*. What differs by kind is
(a) the four facts, (b) the *structure* block, and (c) the verb. Nobody
builds a masterclass page and a cohort page as two page designs. We did,
three times.

**3.2 The structure block is the kind.** A recorded course shows a
*curriculum* (sections → lessons with durations — Udemy, Coursera). A
masterclass shows a *lesson list* or, if live, *the one date*. A cohort
shows *weeks* (pliability's week cards, MasterClass Sessions' numbered
curriculum with "over the next 30 days", Tonal's cadence dots). A consult
shows *how it works* (Alan: 45-min video session, languages, availability
line). Change this block and the page reads as the right kind without
anything else moving.

**3.3 Dates live on the page; slots live in a sheet.** Airbnb puts
*Upcoming availability* cards with seats-left on the detail page and opens
the full date list on tap. Alan and Zocdoc open a slot picker (week strip,
slots grouped by time of day) from the profile's one button. Nobody makes a
separate "detail" screen whose only job is the slot picker — which is what
`ConsultationDetailScreen` was, and why the other terminal has already
bypassed it.

**3.4 Seats and scarcity are facts, not banners.** "8 spots left" (Airbnb),
"3,972 currently joined" (Tonal), "High demand: 21 lessons booked in 48
hours" (Preply) — small type inside a card. Zocdoc's yellow availability bar
was declined in the scans pass for the same reason it is declined here.

**3.5 Review-then-pay is one screen with four lines.** Alan: person · date
and time range · price · cancellation policy, then "by confirming you commit
to attending", then the pay button. Airbnb: price details · things to know ·
pay with. Neither asks anything on this screen the earlier steps did not
already settle. Our `showBookingSheet` does buy → slot → booked inside one
sheet; the Alan shape says the *review* is worth a screen of its own,
because it is where the policy is read.

**3.6 Booked is a page, not a toast.** Peloton's scheduled class (big time,
"you are counted in", "starting in 5 days", calendar), Zocdoc's upcoming
visit ("how to prepare"), Preply's lesson sheet (reschedule / cancel). The
confirmation IS the session page, and it is the same page she comes back to
an hour before. `MyBookingsScreen` has the list; nothing has the page.

**3.7 The expert page shows what she offers, by kind.** Mindvalley's *All ·
Programs · Meditations · Mastery* tabs and Preply's stat strip: the person
is the hub and her offerings hang off her. `ProviderProfileScreen` already
does this since 4bef5cd (sessions + Book pill); it is the one screen in the
inventory to keep as the model, not replace.

**3.8 The hub leads with hers, then the catalogue.** Skillshare's *Continue
watching*, Udemy's *My learning*, Noom's pinned current mini-course, Waking
Up's "Day 4 of 28". A learning home that opens on the catalogue every time
treats a paying customer like a browser. Ours (`CoursesExploreScreen`)
opens on an expert banner and a search bar.

**3.9 The player is one component.** Video · title · who · a small action
row · *Up next* · the list. Udemy, MasterClass, Coursera, Skillshare differ
only in which tabs sit under the video. `CourseLessonScreen` and the TTC
garbh session are two players today.

**3.10 Recorded is not a lesser kind.** MasterClass, Udemy, Coursera are
recorded-first and sell on the curriculum; Peloton's *Encore* puts a
recording in the live schedule with the same row. A recorded masterclass
and a live one are one page with a date or without.

---

## 4. The proposal — seven screens and two sheets, kind as a parameter

The rule, in one line: **one Offering page, one Expert page, one slot
sheet, one review sheet, one Booked page, one Player, one Learn home, one
My learning — and the kind (course · masterclass · cohort · consult) changes
what is inside them, never which screen opens.** Same idea as You (the
stage changes a section's content, not the skeleton) and the store.

### 4.1 Learn home — `PvLearnScreen(stage)`

Replaces `CoursesExploreScreen`, `CoursesCohortsScreen`, the older per-kind
landings, and the learning half of `TtcPrepareScreen`.

1. **Yours first** — one strip that renders only when true: *Continue*
   (course in progress, "2 lessons left"), *Next session* (soonest booked
   slot, "Tomorrow 8:00 pm · Join in 22 h"), *Credits left* (a class pack).
   Empty → the strip is the invitation ("Nothing booked yet. The next live
   session is Thursday.").
2. **Kind filter** — *All · Courses · Masterclasses · Cohorts · Consults*,
   ink pills, the store's chrome. This is the ONE place the four kinds are
   named side by side.
3. **Topic chips** — the existing `kLearningTopics`, untouched.
4. **Rails** — *Live this week* (dated things soonest first, Peloton row:
   time · LIVE or RECORDED tag · title · expert), *Chosen for you*
   (personalisation, with the why-line), then one rail per kind with *View
   all*. A rail with nothing renders its invitation.
5. **Experts** — a rail of faces → Expert page. Last, not first.

### 4.2 Offering page — `PvOfferingScreen(offering)`

Replaces `CourseFunnelScreen`, `MasterclassFunnelScreen`,
`CohortFunnelScreen`, `CourseDetailScreen`, `MasterclassDetailScreen`,
`CohortDetailScreen`, `ConsultationDetailScreen`, `YogaClassScreen`, the
TTC garbh course page's top half. **Fixed order; the kind fills the blanks:**

| # | Section | Course | Masterclass | Cohort | Consult |
|---|---|---|---|---|---|
| A | Hero | trailer or cover, title, expert line | same | same | expert photo, name, role |
| B | Fact strip (four) | lessons · hours · level · language | date or "recorded" · length · seats left · language | weeks · live calls/week · start date · seats left | minutes · video · languages · next free slot |
| C | Trust rows (three) | ParentVeda-reviewed by *name* · refund rule · lifetime access | reviewed · refund rule · recording included | reviewed · refund rule · small group (max N) | verified clinician · cancellation rule · never a diagnosis |
| D | What you'll take away | four to six lines, ticks | same | same | "what a session covers" |
| E | **The structure** (the kind) | curriculum: sections → lessons with durations, first lesson free | lesson list, or the one date with add-to-calendar | week-by-week cards, each with its live call and its watch-at-home | how it works: three steps (pick a slot · join in the app · notes after) |
| F | The expert | card → Expert page | same | same | (already the hero) |
| G | Proof | verified-mother reviews, honest count | same | "3,972 joined" only when true | reviews, if any |
| H | FAQ | accordion, five max | same | same | same |
| I | Related | rail of the same kind | | | other experts in the topic |
| J | **Sticky bar** | price · *Start course* (or *Continue*) | price · *Reserve a seat* (dated) / *Watch* (recorded) | price · *Join the cohort* | "From ₹ / session" · *See availability* |

Owned state changes only J and B: *Continue*, *Joined · starts in 5 days*,
*You have 3 credits*. Nothing else on the page moves when she buys.

### 4.3 Expert page — keep `ProviderProfileScreen`, align its top

Already the one doctor page. Two additions from Preply / Mindvalley: the
stat strip under the name (*verified · sessions given · ★ · languages*) and
tabs of what she offers by kind (*All · Consults · Classes · Courses*), so
the page works for a yoga teacher with a class pack and a paediatrician
with consults alike. The Book pill stays.

### 4.4 Dates and slots — `showPvSlotSheet(offering)`

One sheet for every dated thing. Two layouts inside it, chosen by the
offering's format:

- **Group (masterclass, cohort start, class pack):** date cards with time
  range and *seats left* (Airbnb), one *Choose* each. A cohort shows one
  card per start date.
- **One-to-one (consult):** the week strip, then slots grouped *Morning ·
  Afternoon · Evening* (Alan, Preply), duration toggle only when the expert
  offers two lengths.

Reads the engine's real `Slot`s. Replaces the slot half of
`showBookingSheet`, `provider_booking_sheet`, and the retired
`ConsultationDetailScreen`.

### 4.5 Review and confirm — `PvReviewSheet`

Alan's four lines: *who · when · price · the cancellation rule*, one note
("Confirming means you plan to attend"), the pay button → Razorpay (the
store's `pay()`, server-priced). For a recorded course there is no slot, so
the sheet is *what · price · access rule · pay*. Replaces the buy half of
`showBookingSheet`.

### 4.6 Booked — `PvSessionScreen(booking)`

The confirmation and the return page are the same page (Peloton). Big time,
"in 3 days" / "in 22 hours" / **Join now** when within the window (LiveKit,
in-app), the expert, the offering, *Add to calendar*, *Prepare* (the
offering's own list: what to have ready, questions to bring — Zocdoc's
"how to prepare"), *Reschedule* and *Cancel* with the rule stated, and
after it has happened: *Recording* if there is one, *Notes* if the doctor
wrote any (the doctor ledger already carries these), *Book again*.

### 4.7 Player — `PvLessonScreen(course, lesson)`

Video on top, title, who, a small row (*bookmark · download · share*),
*Up next*, then the lesson list with ticks and durations. The TTC garbh
session and `CourseLessonScreen` become this. Audio-only lessons use the
same screen with the cover in place of the video (Garbh Shravan already
has a player; this does not touch it).

### 4.8 My learning — extend `MyBookingsScreen` into `PvMyLearningScreen`

*Continue* (courses in progress with lessons left), *Upcoming* (booked
sessions, soonest first → Booked page), *Credits*, *Past* (with
*Recording* / *Book again*). Reached from You → *Your things · Bookings*
and from the Learn home's strip. One list across stages — the engine's
stage tag, as today.

### The partner / father

Reads what she booked (the family model: bookings are hers), can add to
his calendar and join a group session she has booked if the offering
allows two seats per booking (a birthing class does; a consult does not).
Cannot buy on her behalf. One line on the Booked page says which.

---

## 5. Per-stage content — what changes

Nothing structural. The stage decides which catalogue feeds the Learn home
and which experts appear; the four kinds exist on all three. TTC today has
consults and the free garbh course; pregnancy has all four; parenting has
all four plus class packs (yoga). The skilling stage's child-facing courses
are a different product (the parent gate, no money on the child's side) and
stay out of this.

---

## 6. Declined

- **A separate page design per kind.** The whole finding.
- **A "sales page" tone** (guarantee rows, testimonial carousels, "walk
  away with" — the parenting funnels' vocabulary). The trust rows carry the
  refund rule in one line; the reviews carry the proof.
- **Seat-count urgency in colour.** Seats left is small type inside the
  card, as Airbnb.
- **Progress rings, streaks, badges** (Mindvalley, Skillshare achievements).
  Lessons left is a number; the base-UI rule against counters stands.
- **A separate detail screen for the slot picker.** It is a sheet.
- **Chat with the expert before booking** (Preply's message button). Not
  until there is someone to answer.
- **YouTube courses.** Dead, per memory.

---

## 7. How it was built — 2026-09-20

`lib/screens/learn/` — `pv_learn_screen.dart` (Learn home), `pv_offering_screen.dart`
(the ten-section page), `pv_offering_content.dart` (the per-kind table:
state, verb, trust rows, structure title, how-it-works, FAQs),
`pv_learn_flow.dart` (`pvLearnCommit`, the slot sheet, the review sheet),
`pv_session_screen.dart` (Booked; `pvOpenCall` is the one door to the three
call screens), `pv_lesson_screen.dart` (the player, honest about the film),
`pv_my_learning_screen.dart`, `pv_learn_chrome.dart` (on the store's chrome),
`pv_learn_catalog.dart` (the adapters). `lib/data/learn/pv_learn_view.dart`
is the display contract, `pv_learn_images.dart` the topic covers.
`lib/services/pv_learn_progress_store.dart` holds lessons done, locally.

What differs from the plan below, and why:

- **The catalogue sits in `screens/learn/`, not `data/learn/`.** Two adapters
  hold `BuildContext` closures (the TTC garbh course's sessions open their
  own practice players); a file that pushes routes is screen code.
- **No engine changes at all.** `seatsLeft` was already the server's number
  (`ServerSlotStore` over `booking_slots`) and the "prepare" list is display
  content on the view, not an `Offering` field. Payment is the existing
  `PaymentService.checkout(offering)`; nothing about money moved.
- **Two seats per booking is a line, not a column.** A household is one
  seat; the paired partner reads her bookings (RLS) and opens the same room
  from his phone. The Booked page says so, and says the opposite for a
  class pack (one mat). No seat accounting changed — that is the honest
  reading of decision 4.
- **The free garbh course is a view with no engine offering** (price 0,
  `offering: null`), so its page cannot sell and its lessons keep their own
  screen through `PvLearnLesson.open`.
- **A course written as an outline still has a curriculum.** The flagship
  guide has no modules yet; its "what this covers" lines stand as untimed
  lessons until the modules land.
- **Twenty-five facades**, not twenty-four: `TtcOfferingScreen` and the
  two booking sheets joined the list. Every retired class keeps its name and
  constructor and builds the new screen; bodies are `…Classic`, pushed by
  nothing (`test/pv_learn_test.dart`).
- **A door that names a doctor lands on that doctor's consult page.**
  `ConsultationsScreen(onlyRole: 'sp_ob')` from Scans, Complications and
  Nutrition used to open the whole specialist list with one pill selected;
  the facade opens the named specialist's page, with *Other experts* as the
  way out. The 2026-09-19 pill row is kept in the Classic body.
- **The doctor page's rows now come from `PvLearnCatalog.forExpert`** —
  one row widget, one destination — and its Book pill runs `pvLearnCommit`.
  The four per-source loops and `_pickSlot` are kept commented.

### 7a. The plan, as written

- `lib/screens/learn/` — `pv_learn_screen.dart`, `pv_offering_screen.dart`,
  `pv_offering_content.dart` (the per-kind table: fact strip, trust rows,
  the structure block, the verb — the screen never switches on kind),
  `pv_slot_sheet.dart`, `pv_review_sheet.dart`, `pv_session_screen.dart`,
  `pv_lesson_screen.dart`, `pv_my_learning_screen.dart`, `pv_learn_chrome.dart`
  (on the store's chrome, same base-UI rule).
- **One display adapter**, the store's pattern: `PvOfferingView` built from
  `LearningProgram` / `PrepProgram` / `YogaClass` / the TTC course / an
  `Expert`'s consult through adapters in `lib/data/learn/`, keyed by the
  engine's `Offering.id`. The three catalogues stay; the page reads one
  shape.
- **Facades:** every screen in §1's table keeps its name and opens the new
  one; bodies kept as `…Classic`. `ProviderProfileScreen` is extended, not
  facaded. `showBookingSheet` becomes slot sheet + review sheet.
- **Engine:** unchanged. Two things it does not have and the pages need:
  `Slot.seatsLeft` as a read (capacity minus claimed — a view or an RPC,
  not a client count) and a `prepare` list on `Offering` (content, Directus
  later). Both are additive.
- **Payment:** the store's `pay()` + `razorpay-create-order` with a new
  `kind: 'offering'` branch priced server-side from `offerings`, the same
  `priced_by` note. Money and seats stay server-side.
- **Tests:** the offering page's section order identical across the four
  kinds (pump each, assert the ten headers in order); reachability by grep
  (every old landing → `PvLearnScreen`, every old detail → `PvOfferingScreen`);
  nothing pushes a `…Classic`; the verb per kind is the one named in §4.2
  and no other; `seatsLeft` never computed on the client.
- **Walk:** versus format, ours beside the Mobbin reference, all three
  stages, one of each kind, one full booking to a LiveKit room.

---

## 8. Decisions — taken 2026-09-20, all as recommended

1. All seven screens at once. 2. *Learn* is the word everywhere (the More
sheet, the Tools hub tile, the TTC surface all land on one home; no bar
slot changed). 3. Reviews from the source models for now, the product
`reviews` table when it takes an `offering_id` (STILL-OPEN §69.2).
4. The partner joins on her booking (see §7). 5. The garbh course is a
₹0 view on the one page.

### 8a. As originally put

1. **Scope of the first build:** all seven screens at once (recommended —
   the inconsistency is the problem, and half a set is a fourth grammar),
   or Offering page + slot sheet + Booked page first and the rest after.
2. **The Learn home's name in the bar:** *Learn* (recommended; the
   parenting bar already says it) or *Prepare* (pregnancy's word) — one
   word for all three stages, since slot 2 is the store everywhere and
   this should also be one slot.
3. **Reviews on offerings:** verified-mother reviews from the same
   `reviews` table as products (recommended — one review system), or
   testimonials as content.
4. **Two seats per booking for group sessions** (partner joins a birthing
   class on her booking): in v1 or later.
5. **The free garbh course:** becomes an Offering with price 0 on the same
   page (recommended — one page), or stays its own screen.
