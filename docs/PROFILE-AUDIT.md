# Profile audit — one "You" screen for four stages (Mobbin audit #10)

**Date:** 2026-09-19. Research and plan; the build began the same day on the
user's green light with the five decisions in §8 taken as: *You*; avatar entry
on every home; Notes for your doctor in the first build; Download my data
shown as coming; one partner switch.

**Asked, in the user's words:** *"Unify the profile screens. A format that
stays consistent throughout trying-to-conceive, pregnancy, parenting,
skilling. All the essentials, considering the current state and what should
be there. A few things get added and subtracted as the stages proceed."*

---

## 1. What we have — four answers to "who am I here"

| Stage | Surface | Reached from | Holds |
|---|---|---|---|
| Pregnancy | `ProfileScreen` (1,339 lines) | avatar on Today | avatar + week · Journal · Bump ritual · Dear Baby vault · Saved · Personalise · Analytics · Invite friends · Memories · Invite partner · Employer benefits · WhatsApp · Language · Org sign-in · Reset week / Doctor mode (testing) · Sign out · Delete account |
| TTC | `TtcProfileScreen` + `TtcMoreScreen` | More tab | your chapter · partner ("soon") · journey map · language · home version · view-as · stage switch (testing) · sign out · More: cycle, calendar, community, journal, everything paid |
| Parenting | `PpMoreSheet` → `FamilyProfileScreen`; `MyChildScreen` | More tab | Community · Watch · Learn · Recipes · Memories · Find help · "Settings — your family, reminders and language" → the Living Family Profile (conditions, feeding, sleep, priorities, learning style); the child lives on My Child |
| Skilling | `SkGrownUpScreen` (PIN gate) | child screen → "For the grown-up" | child record · PIN · consent · photos/voice keepsakes · delete her data · courses · products |

What is the same underneath: one `profiles` row, one `FamilyProfileStore`,
one `LifeStageStore`, one `SavedStore`, one `ChildProfileStore`, and since
2026-09-17 one `PvOrderStore` (orders, addresses). The **data** is already
unified by the family model; only the **screens** are four.

Three things no stage has: a place to see and edit *her own facts* as a list
(Apple's Health Details); a plain "what we store / download it / delete it"
page (DPDP-shaped); a home for orders and addresses outside checkout.

## 2. Asked (the Mobbin pass)

Fourteen queries, by flow name where the app is in the library:

- **Health & cycle apps (our nearest kin):** [Flo — Settings](https://mobbin.com/flows/34c0b76d-b84b-48f3-88e9-88460c115196), [Flo — Editing my profile](https://mobbin.com/flows/4b4a29ac-b150-4558-a0f4-30ddc8f76daf), [Flo — Partner](https://mobbin.com/flows/06835a50-7fb5-497b-95be-079e5e67f470), [Flo — Linking a partner](https://mobbin.com/flows/0eec4d57-5aee-4176-a5a3-b59b61ddbc5a), [Clue — More menu](https://mobbin.com/flows/5e6fc2e4-cf38-40e0-8b34-a9b28c3d832e), [Clue — Account](https://mobbin.com/flows/7a7068a7-25c8-40a3-a216-30bb5be0151c), [Oura — Settings](https://mobbin.com/flows/cea35527-16e9-4821-869f-0ac465f34e38), [Oura — Updating my profile](https://mobbin.com/flows/7ce04028-3d16-4245-8388-ba4ca35cf1ab), [Apple Health — Profile](https://mobbin.com/flows/40639fc3-6978-4b39-99bd-cd51db256933), [Apple Health — Health details](https://mobbin.com/flows/11aef947-ddd6-40b2-9a7f-237ab73409bd), [Apple Medical ID](https://mobbin.com/screens/1479525a-75f2-4ccb-96be-16401790f39b)
- **Family / child records:** [Fitbit — Family](https://mobbin.com/flows/60bf00ab-f907-47df-a42c-d229896a185d), [Fitbit — Add child](https://mobbin.com/flows/32cae4ed-9faa-4cab-9de6-fe324a385c20), [Garmin — Child Account](https://mobbin.com/screens/9a69bc32-74c5-4dee-9709-caa728b325a7), [YouTube Kids — Create a profile](https://mobbin.com/screens/f4ad5408-81d6-4aa3-b1fa-25fbd6c8a203), [Zocdoc — person chip](https://mobbin.com/screens/4071bcf8-cbba-484f-bfd7-f3bb55e8fdd8)
- **Switchers:** [Netflix — Switch Profiles](https://mobbin.com/screens/a14047ab-4901-4865-8bc1-e5dfa01ade21), [Google — account sheet](https://mobbin.com/screens/8f85ce13-d9fd-48ba-8a57-7fbc8b868a5b), [Notion](https://mobbin.com/screens/fd81a99c-88ed-4274-a3cd-dfb4c04ad275), [Whatnot](https://mobbin.com/screens/648c7bc7-bd10-4999-8a2b-36f09052e25a)
- **Marketplace / Indian:** [Zomato — Profile](https://mobbin.com/flows/d36c6804-b223-4905-8e69-c49856b45753), [Swiggy — Profile](https://mobbin.com/flows/27d7de24-18dd-4874-8dc5-ebc4d91dc035), [Airbnb — Profile](https://mobbin.com/flows/992431f9-6c6a-4ce1-aecd-53dc74796f28), [Airbnb — Account settings](https://mobbin.com/flows/c808890f-1025-46e0-a083-2da40e5a081f)
- **Wellness profiles:** [TIDE](https://mobbin.com/screens/658f99ac-c86b-45fd-8eb7-5ec17894f972), [Withings — My Health Goal](https://mobbin.com/screens/684616c1-6c2a-4745-94f7-49a844721834), Me+, Yazio, Mimo, pliability (the streak/XP ones — declined)
- **Notifications:** [ABY Journal](https://mobbin.com/screens/b0e9cd74-b970-4fee-a44d-afc22a092b77), [Blinkist](https://mobbin.com/screens/cadacc39-d6ce-4817-a1ad-5b633039b077), [Starling](https://mobbin.com/screens/d3298502-cdd1-44e6-8095-741eea276ef7), [Jomo](https://mobbin.com/screens/e75c7211-703e-42ed-8529-1472bc0670de)
- **Data & privacy:** [Urban Company — Privacy Center](https://mobbin.com/screens/d8ca2109-e6d9-44bf-aab2-fe01e1a8af5f), [Zalando — Request or delete data](https://mobbin.com/screens/b44aa19b-0c87-44f3-b90a-a3ca27e9a927), [Airalo](https://mobbin.com/screens/facc6252-77a2-4a12-9c04-99fd642ff5a4), [Google — Data & privacy](https://mobbin.com/screens/556ee6ed-4a5d-44a0-9b9a-a05797a0e689)

Not in the library (already known): Ovia, Glow, Huckleberry, BabyCenter,
What to Expect. Not found either: Google Family Link, Kinedu, FirstCry.

## 3. Found — the decisions, not the looks

| Question | What the good ones do | Source |
|---|---|---|
| **Where does the stage live?** | ON the profile, as one row/chip set under the identity card: Flo's *My goal · Track cycle / Get pregnant / Track pregnancy*; Clue's *Mode* row; Apple Health's "Set Up Pregnancy" inside Health Details | Flo, Clue, Apple Health |
| **Profile vs settings?** | Two things. *My profile* = who I am and my facts (goal, life situation, DOB, body). *Settings* = units, notifications, account, data sharing, security, versions, sign out, delete | Oura (cleanest), Airbnb |
| **How is the list shaped?** | Identity card → grouped rows with section headers → More/About at the foot → version number. Never a flat 20-row list | Clue, Zomato, Airbnb, Oura |
| **Who is the root?** | The adult ("Family manager"); children are a group beneath with *Add child*; switching is a control on the adult's page, not a sign-in | Fitbit Family, Netflix, Garmin |
| **The child's page** | Avatar · name · *View* · attention card if a permission is missing · Contacts / Authorised viewers / Data · Legal. Facts as Add/Edit rows, empties shown as `--`, never hidden | Garmin Child Account, Apple Medical ID |
| **Partner** | A page that says *what your partner can see* (view-only, listed) BEFORE the code; the 3-step invite → pair → share; a "key moments" notification promise | Flo Partner |
| **A mode you can enter and leave** | A floating pill, outside the rows: *Switch to hosting* | Airbnb |
| **Commerce on a profile** | Orders inline as the last card with "rate it / view more"; addresses and payments as rows; empty state is an invitation ("You haven't ordered yet · Explore") | Swiggy, Zomato, Airbnb Account |
| **Notifications** | Grouped by topic with a one-line "why" under each toggle; times where a time matters; one *turn all off* at the foot | ABY Journal, Blinkist, Starling, Jomo |
| **Data & privacy** | One page: what we store in plain words, *Download my data*, *Delete account* with the consequences as bullets, red | Urban Company, Zalando, Airalo |
| **Identity trust** | A verified tick on the avatar; the verified attribute (phone) shown as a fact | Airbnb, Flo (email ✓) |
| **Journey on a profile** | "Joined 2 days ago", Favourites/Recents tiles, an editable goal card. NOT streaks, XP, leagues, "share my progress" | TIDE, Withings vs Mimo/pliability |

## 4. The proposal — one screen, one skeleton, four contents

**Name:** *You*. (Not "Profile" — the screen is about her and her people, not
a card of her. Not "Account" — that is section H.) Reached from the avatar
on every home, as pregnancy already does; TTC's and parenting's *More* tabs
keep their other rows and gain *You* as the first row. Not a fifth tab.

**The rule that makes it one screen:** the section list is FIXED and in this
order on all four stages. A stage changes what is *inside* a section — the
facts, the forward action, the chip labels — never which sections exist or
where they sit. Same principle as the store (H&M's WOMEN/MEN/KIDS) and the
family model (stage is a tag). A section with nothing in it renders its
invitation, never disappears.

```
┌──────────────────────────────────────────────┐
│  You                              [ ⚙ ]      │  ⚙ = Settings (sections F–H
│                                              │      also reachable by scroll)
│  A  IDENTITY CARD                            │
│     (avatar ✓) Priya · with ParentVeda       │
│     since Aug 2026 · Week 21 ▸               │  the clock is the stage's:
│     Edit                                     │  Week 21 / Aarav · 4 mo /
│                                              │  Trying · month 5 / Meera · 7
│  B  YOUR JOURNEY                             │
│     [Trying]─[Pregnancy]─[Parenting]─[6+]    │  the four chapters, current
│     one forward action, stage-specific       │  in ink; NOT a free switch
│                                              │
│  C  FAMILY                                   │
│     ○ Priya (you)  ○ Rohan (partner) ○ +     │  people cards; child chips
│     [Aarav 4 mo] [Meera 7] [+ Add a child]   │  when parenting/skilling
│                                              │
│  D  YOUR DETAILS                     Edit ▸  │  Apple Medical-ID rows,
│     Due date · 12 Feb · from scan     ▸      │  Add/Edit, `--` when empty,
│     Conditions · PCOS                 ▸      │  stage-specific list
│     Priorities · Sleep, Nutrition     ▸      │
│                                              │
│  E  YOUR THINGS                              │
│     [Saved 12] [Memories] [Orders 2]         │  Airbnb's two tiles → a row
│     Journal · Dear Baby vault · Bookings ·   │  of three + rows
│     Addresses · Notes for your doctor        │
│                                              │
│  F  PREFERENCES                              │
│     Language · Reminders · WhatsApp updates  │
│     · Personalise ParentVeda                 │
│                                              │
│  G  SUPPORT                                  │
│     Help · Invite a friend · Employer        │
│     benefits · About ParentVeda              │
│                                              │
│  H  ACCOUNT                                  │
│     Signed in as … · Data and privacy ·      │
│     Sign out · Delete account (red)          │
│     v1.x (build) · Developer (debug only)    │
└──────────────────────────────────────────────┘
        ⤷ floating pill when a partner is linked:
          "Viewing as Rohan ▸" / "Switch to Dad" (Airbnb's hosting pill)
```

### A · Identity card
Avatar (initial in a hue well, photo optional, **verified tick** when the
phone is verified — the phone is a verified attribute, never an identity,
BACKEND-PATTERNS §16c), name, *with ParentVeda since <month>* (TIDE's
"joined"), and the stage clock as the one fact under the name. `Edit` opens
name/photo/phone/email. Sponsor / employer badge here when present (Zomato's
Gold band, but as a quiet chip, not a black band).

### B · Your journey — the stage, on the profile
Flo's *My goal* row, drawn as the four chapters with the current one in
ink and the passed ones quiet. **Not a free switch** — `ttc_profile_screen`'s
reasoning stands: pregnancy content landing on someone mid-cycle is harm.
Instead, ONE forward action per stage, which is what actually moves a
family (FAMILY-MODEL §3: "forward is the only direction, the second baby is
the only way back"):

| Stage | The one action | What it does today |
|---|---|---|
| Trying | *I got a positive test* | `TtcTransition` (exists) |
| Pregnancy | *Baby has arrived* | creates the `children` row, moves stage (exists in onboarding; not reachable from profile today) |
| Parenting | *Add a child* · *Expecting again* | add child (exists); expecting again = the `pregnancies` table (§61.1, owed) |
| Skilling | — (it is a child's chapter, reached through Family) | |

Loss and "I'm no longer trying" belong here too, as a quiet link under the
row, not a chip — the personalisation reads `pregnancies.outcome` (§61.1).
The team's stage switch stays under *Developer*.

### C · Family — the people
The family model drawn: her card (root), the partner card, the children.

- **Her:** the same card as A, tapping opens the person page (A + D).
- **Partner:** linked → name + *what Rohan can see* (Flo's list: her week,
  the calendar, saved things she shares; never her journal, never her
  symptoms unless she turns each on); not linked → *Invite your partner*
  with the code (exists: pairing-code flow). This replaces the pregnancy
  profile's `_InvitePartnerCard` and TTC's "partner (soon)".
- **Children** (parenting, skilling, and pregnancy-with-an-older-child): a
  chip row (Netflix's avatar row; Zocdoc's "Alex S. ▾" chip) — the active
  child in ink; tap opens the **child page**; `+ Add a child` always last.
  TTC and first-pregnancy: the row shows the one invitation "Your first
  child's page appears here after the birth", never blank.

**The child page** (Garmin + Apple Medical ID): avatar, name, age, DOB with
*Edit*; the facts (feeding, sleep, conditions, premature/NICU/multiple —
from `FamilyProfileStore`); *Who can see* (partner → yes/no; skilling →
the PIN and consent, from `SkGrownUpScreen`); *Her things* on this phone
(skilling keepsakes, photos, voice — with the delete controls the skilling
screen already has); vaccination and growth as two rows into their tools.
This is where `MyChildScreen`'s profile half and `SkGrownUpScreen`'s "Child /
Consent" half become one page, and the skilling PIN gate wraps only the
skilling rows of it.

### D · Your details — the stage's facts, editable
Apple's Health Details / Medical ID as rows: label · value · chevron; `--`
plus *Add* when empty. This is the Living Family Profile
(`FamilyProfileScreen`) and the onboarding give-back questions
(`onboarding_questions.dart`) surfaced as facts she can correct — the
"derive, never ask" rule's other half: what we derived, shown, editable.

| Stage | Rows |
|---|---|
| Trying | Trying since (`ttc_duration`) · Cycle length / regularity (`ttc_cycles`) · Folic acid started (`ttc_folic`) · Conditions (PCOS, thyroid, after loss — the TTC focus pathways) · Treatment (IVF/IUI, from `TtcTreatmentStore`) · Partner's side (his tests, if he opted in) |
| Pregnancy | Due date **and its source** (`DueDateSource` — "from your scan on 4 Sep"; a clinic-owned date shows as theirs) · First baby / parity (`preg_parity`) · Conditions (`PregCondition`) · Diet (`preg_diet`) · What you want help with (`PregPriority`) · Hospital / doctor (from bookings / consult if known) |
| Parenting | (the child's facts live on the child page) · Your priorities (`pp_priorities`) · How you like to learn (`LearningStyle`) · Your health after birth (postpartum — new, small) |
| Skilling | (on the child page: interests `sk_interests`, time `sk_time`) · Your role (parent / grandparent — the `sk_grown_up` verifier) |

Every row that is clinical ends where it always does: "your doctor's word
comes first"; nothing here recalculates a clinic date (CLAUDE.md).

### E · Your things
Airbnb's two tiles become a row of three counted tiles — **Saved (n)**,
**Memories**, **Orders (n)** — then rows: Journal (pregnancy; TTC journal),
Dear Baby vault (pregnancy), Bookings (consults, courses, classes —
`BookingStore`), Addresses (`PvOrderStore`), *Notes for your doctor*
(Flo's "Report for a doctor" — a page that assembles what she has logged
into something she can show; NEW, small, and the most-asked-for thing a
health profile has). Orders: Swiggy's inline last-order card when one
exists; the invitation when not.

### F · Preferences
Language (English / हिंदी — one row, the existing `_LanguageCard`),
**Reminders** (a proper page: grouped by topic with a "why" line and a time
where a time matters — the daily tip, scans/appointments, medicines,
feeds/sleep, courses; *turn all off* at the foot; `NotifyTopic` exists),
WhatsApp updates (consent + number, exists), Personalise ParentVeda (the
give-back questions, exists), Analytics (existing screen, under Developer
unless the user wants it public).

### G · Support
Help (FAQ + WhatsApp/email support — the support entry the app lacks),
Invite a friend (referral, exists), Employer benefits / Sponsor programme
(exists, shown when the org sign-in or a benefit is live; otherwise a
single quiet row "Does your employer offer ParentVeda?"), Find help near
you (parenting's providers; lactation/paediatrics), About ParentVeda
(how we review, how we sell — the store's honesty strip lives here too;
licences, terms, privacy).

### H · Account
Signed in as (email / phone, verified state; the org sign-in), **Data and
privacy** (one page: *what we store* in plain words per stage, *Download
my data* — export as a file, *Delete account* — Urban Company's
consequences-as-bullets, red, the existing delete flow), Sign out, version
+ build, **Developer** (debug only: version pills, reset week, doctor mode,
view-as, stage switch — everything currently labelled "· testing").

### The partner / father view
Airbnb's floating pill, present only when a partner is linked or the
father shell is on: *Viewing as Rohan ▸* / *Back to Priya*. His *You*
screen is the same skeleton: his card, **her** journey row (read-only,
"Priya · Week 21"), Family with him as the partner card, his details
(TTC: his tests; pregnancy/parenting: none beyond name — "we ask him
nothing about her"), his things (his reads, his journal), preferences,
support, account. Nothing of hers he cannot already see.

## 5. Per-stage content — the add/subtract table

| Section | Trying | Pregnancy | Parenting | Skilling (parent) |
|---|---|---|---|---|
| A clock | *Trying · month 5* | *Week 21 · day 3* | *Aarav · 4 months* | *Meera · 7* |
| B action | I got a positive test | Baby has arrived | Add a child / Expecting again | — |
| C partner | invite / linked, his side opt-in | invite / linked | linked; co-parent sees child records | linked |
| C children | invitation copy | invitation (or older child) | chip row | chip row (PIN on skilling rows) |
| D rows | 6 (above) | 6 | 3 + child page | 1 + child page |
| E tiles | Saved · Journal · Orders | Saved · Memories · Orders | Saved · Memories · Orders | Saved · Her keepsakes · Orders |
| E rows | Bookings · Addresses · Doctor notes | Dear Baby · Journal · Bookings · Addresses · Doctor notes | Bookings · Addresses · Doctor notes · Vaccination card | Courses booked · Addresses |
| F | all | all | all | all |
| G | all | all + Find help | all + Find help | all |
| H | all | all | all | all |

## 6. Declined

Streaks, XP, leagues, "share my progress" (Mimo, pliability — and the V3
home decision that dropped counters). A completeness meter as pressure
(keep parenting's as an invitation line under D only). A free stage switch.
Followers/following. A fifth tab. A black membership band (the sponsor
badge is a chip). Putting Community/Watch/Learn on the profile (they are
destinations, parenting's *More* sheet keeps them).

## 7. How it was built — 2026-09-19

What landed differs from the plan below in five small ways, each for a
reason worth keeping:

- **`pv_you_content.dart` sits in `lib/screens/profile/`, not
  `lib/data/profile/`.** It is not seed data — it holds `BuildContext`
  closures (what a row opens) and store reads. A file that pushes routes
  is screen code and lives with the screen.
- **`FamilyProfileScreen` is not a facade.** It is the parenting *editor*
  (feeding, sleep, conditions, priorities) and You links to it from
  *Preferences · Personalise* and from every child's About row. Facading
  it would have meant rebuilding a working editor to change nothing.
- **`SkGrownUpScreen` keeps its Child/Consent half.** The parent gate, the
  PIN and the consent record stay where the doors expect them; You's
  skilling content links *there* (*Her keepsakes*, behind the gate) and
  the grown-up page links back (*Your profile*). Two doors, one room.
- **`PpMoreSheet`'s row is *You*, replacing *Settings*** (which opened
  the family editor). `TtcMoreScreen` needed no change — its row calls
  `openTtcProfile`, which is now the facade.
- **No `pv_person_screen.dart` or `pv_reminders_screen.dart`.** Her own
  facts are the identity card plus *Your details* (`PvDetailsScreen`,
  the onboarding questions as chip groups); reminders reuse
  `RemindersScreen` on pregnancy and the notify chips elsewhere.

Files: `pv_you_screen.dart` (the skeleton), `pv_you_content.dart` (the
per-stage table), `pv_you_chrome.dart` (section, row, switch row, tile,
avatar, identity card, person card, child chips, top bar — on the
store's chrome), `pv_you_sheets.dart` (add child, addresses, keepsakes
gate), `pv_details_screen.dart`, `pv_partner_screen.dart`,
`pv_child_screen.dart`, `pv_doctor_notes_screen.dart`,
`pv_data_privacy_screen.dart`, `pv_account_actions.dart` (sign out,
delete — lifted from the pregnancy profile unchanged). Entry:
`openPvYou(context, stage:)` from the avatar on all four homes; facades
`ProfileScreen` → `ProfileScreenClassic`, `TtcProfileScreen` →
`TtcProfileScreenClassic`. Test: `test/pv_you_test.dart` (skeleton
order on all four stages, one forward action, reachability by grep,
facades). The plan as written before the build follows.

### 7a. The plan, as written

- `lib/screens/profile/` — `pv_you_screen.dart` (the skeleton; takes
  `PvYouChrome` like the store takes its bar), `pv_person_screen.dart`,
  `pv_child_screen.dart`, `pv_partner_screen.dart`, `pv_details_screen.dart`
  (the rows editor, per stage), `pv_reminders_screen.dart`,
  `pv_data_privacy_screen.dart`, `pv_you_chrome.dart` (the row, the tile,
  the section head — on the store's chrome, same base-UI rule).
- Stage content as **data**, one file: `lib/data/profile/pv_you_content.dart`
  — for each stage, the clock, the forward action, the D rows and the E
  rows. The screen never switches on stage; it reads the table. A new fact
  is a row in the table, not a screen change.
- Facades, the store's pattern: `ProfileScreen`, `TtcProfileScreen`,
  `FamilyProfileScreen`, and `SkGrownUpScreen`'s Child/Consent half keep
  their names and open the new screens; bodies kept as `…Classic`.
  `MyChildScreen` keeps everything but its profile header, which links to
  the child page. `PpMoreSheet` and `TtcMoreScreen` gain *You* as row one.
- Stores it reads, all existing: `LifeStageStore`, `FamilyProfileStore`,
  `ChildProfileStore`, `PregnancyController` (+ `DueDateSource`),
  `TtcRecordsStore` / `TtcTreatmentStore`, `SavedStore`, `PvOrderStore`,
  `BookingStore`, `MemoriesStore`, WhatsApp consent, the partner link
  (`profiles.partner_id`), `SkChildStore` + the PIN. New: none required
  for v1; *Notes for your doctor* is a read-only assembly; *Download my
  data* needs an edge function that zips her rows (owed, §H).
- Tests: the skeleton's section order is identical across the four stages
  (pump each, assert the eight headers in order); every D row for every
  stage resolves to a store getter; reachability by grep (avatar on each
  home → `PvYouScreen`; More rows on TTC/parenting); the forward action
  per stage is the one named here and no other.
- Copy: English, calm, no counters. The partner "what he can see" list is
  the one piece to write with care.

## 8. Decisions for the user (before building)

1. **Name:** *You* (recommended) or *Profile*.
2. **Entry on TTC and parenting:** avatar on the home (recommended — makes
   all four the same) or the *More* tab's first row, or both.
3. **Notes for your doctor** (Flo's report): in v1 as a read-only page, or
   parked.
4. **Download my data:** in v1 (needs an edge function) or parked with the
   row present and copy that says "coming".
5. **Partner visibility toggles:** one switch ("share my week and calendar")
   in v1, or per-thing switches.

## 9. Pending, unrelated, from the same conversation

- **Products hero band must loop** — DONE 2026-09-19 with the build.
  `PvHeroBand` gives the `PageView` a virtual count of 100,000, maps each
  index onto a slide with `% n`, and starts in the middle so both
  directions have runway; the auto-advance is always "next virtual page",
  so the wrap is invisible. The first/last-card gutter special case went
  with the edge it was for.

## 10. What You still owes — see STILL-OPEN §67

Download-my-data edge function; per-thing partner sharing as a server
rule; the privacy notice page; Help; the device walk; the two classic
bodies' retirement after a release cycle.
