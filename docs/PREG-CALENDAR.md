# Pregnancy calendar: rebuilt as one hub (2026-10-17)

The three-tab calendar (Timeline · Calendar · Upcoming) is now one hub, with
Coming up and Whole journey as their own pages. The approved prototype is at
claude.ai/artifact/N6Y95pDA2i5dkQQbFaAF26, and the plan was "do for pregnancy
what was done for TTC".

> **Folded in 2026-10-17:** the Mobbin section is MOBBIN-DISCOVERY §26,
> the open points are STILL-OPEN §94. This file stays as the design record.

## Where it lives

| File | What |
|---|---|
| `lib/screens/pregnancy/calendar/preg_cal_data.dart` | One list of things on days, assembled from the stores that own them. Week maths, trimester rule, usual checks, Coming up |
| `lib/screens/pregnancy/calendar/preg_calendar_hub.dart` | The hub: where she is, the month, the picked day, Coming up, usual checks, rows |
| `lib/screens/pregnancy/calendar/preg_cal_upcoming_screen.dart` | Coming up (was the Upcoming tab) |
| `lib/screens/pregnancy/calendar/preg_cal_journey_screen.dart` | Whole journey (was the Timeline tab) |
| `lib/screens/pregnancy/calendar/preg_cal_sheets.dart` | The Add, item, usual check, note and weight sheets |
| `lib/screens/pregnancy/calendar/preg_cal_parts.dart` | Card, rows, date block, the one tap helper |
| `lib/screens/calendar_screen.dart` | Now a wrapper that opens the hub. The old screen is block-commented, kept for revert |
| `lib/screens/tools/scans_appointments_screen.dart` | `showPregAppointmentSheet`: the one appointment form, for add, edit and "Add as appointment" |
| `test/preg_calendar_hub_test.dart` | Facts, layout at 360dp, empty and future days, his side, wiring |

## The design decision worth defending

**Read from the owners, write to the owners, store nothing.** The calendar
keeps no copy of anything.
- **Reads:** appointments come from `ScansStore`, weight and kicks from
  `ToolsStore`, symptoms from `SymptomStore`, notes from `CalendarStore`.
- **Writes:** an add goes to the same store. A weight added from the
  calendar is the same row the weight chart draws.

The cost is that the calendar re-assembles its list on every rebuild. That is
cheap: a few hundred rows at most. What it buys is that two screens can never
disagree, because there is only one copy to disagree about.

The old screen used `CalendarStore.allEvents`, which had three faults:
- it flattened everything into a display type with no source row;
- it could not open the right tool or edit anything;
- it put every program on "today".

`allEvents` is unchanged, kept for the commented-out screen.

**Edits keep the id.** `ScansStore.updateAppointment` and
`CalendarStore.updatePersonal` write an update to the existing row, not a
delete plus insert. The local row and its cloud copy stay one identity, so a
sync on another device sees a change, not a deletion followed by a stranger.

## Mobbin, screen by screen

| Screen | References | Adopted | Declined |
|---|---|---|---|
| Hub hero | Clue 4109e86e, e6d1a043 · Oura ee1f0724, 4ccc949c · Apple Health 9710c735 | "20 weeks 2 days"; a 3-segment trimester bar; days to go plus due date with Change; a source line ("Due date set by your dating scan") | Flo's full-screen baby bubble (b9868b90): the home already carries the week film |
| Month | Weverse 5d94bb1b · Todoist a62d6a9f · Asana 74725910 | Dots under the date; this week as a pale band; a Today pill off-month; swipe plus arrows; a key listing only what is drawn | Tags inside cells; continuous scroll (TTC reverted it 2026-10-16) |
| Day + Add | Apple Health "Log" 9710c735 · Withings 00c25e9d | Rows; one Add; Add as a list of rows that says why a row waits | Icon-grid pickers (FocusFlight, Craft) |
| Coming up | Lex cb327064 · Fixtured 11d10641 · Canopi d88f4063 · Binance 8339ece6 | Date block plus countdown eyebrow; Today / This week / Later groups; "No more today." | Cover images (Meetup, Luma) |
| Usual checks | Zocdoc 86529650 · CVS 387b81ad | A window, never a date; "Add date" turns it into her booking | Book buttons |
| Item sheet | CVS c3a9a7d5 · Zocdoc 71930370 · Fresha 5ef9f1bf | When / Where / With / Notes rows, then actions | Maps, directions |
| Whole journey | Runna 9eb278de · Flo 347a171b · stoic. 5e124ffa | One card per week, with counts instead of rows; opens on "You are here"; trimester jump | Stardust hormone graph |

**Queries that worked:**
- Describe the content, e.g. "month calendar where each day has small coloured
  dots… selected day's entries listed below".
- "pregnancy app list of upcoming doctor appointments and prenatal tests by week".
- Name the app plus the flow, e.g. "Flo pregnancy mode monthly calendar".

**What the library lacks:**
- Ovia, BabyCenter and What to Expect.
- A real pregnancy month-calendar screen. Pregnancy apps lead with the week,
  not the month, which is why the hero leads too.

## Facts checked

| Fact | Shown | Source | Status |
|---|---|---|---|
| Weeks and days | Completed weeks plus days; due date = day 280 | Naegele; `PregnancyController.currentDay` | Correct, pinned by test |
| Trimesters | 1st to 13w6d · 2nd 14w0d–27w6d · 3rd from 28w0d | ACOG, NHS | Fixed: the old grid tagged week 4 as a start |
| First ultrasound | Around weeks 6–8 | FOGSI, NHS | Correct |
| NT scan | 11 weeks to 13 weeks 6 days | FOGSI, ISUOG | Copy fixed |
| Anomaly scan | Around weeks 18–22 | FOGSI, NHS, ISUOG | Correct |
| Sugar test | 24–28 weeks, and often at the first visit in India | MoHFW (DIPSI) | Copy fixed |
| Growth scan | Around 32, if advised | FOGSI | Correct |
| Group B Strep | 36–37, if your doctor advises | ACOG routine; RCOG and FOGSI risk-based | Title and copy fixed |
| Td injections | At booking, then 4 weeks later | MoHFW | Added (`m_td`) |
| Kick counts | Offered from 28 weeks, today only | ACOG; RCOG prefers knowing her pattern | Enforced in the Add sheet |

## Open

1. **His calendar button on the pregnancy home — decided 2026-10-17: keep
   Saved.** Only two round buttons fit; his stay Messages + Saved, and he
   reaches the read-only calendar from More › Calendar.
2. **"Booked" is matched by name.** An appointment has no link to the check it
   books, so "Add as appointment" fills in the check's name and the calendar
   matches on that. If she renames it, the check reads as open again, which is
   never wrong, just less helpful. A `checkId` on `Appointment` is the real fix:
   - a column, a migration, and a contract-test update;
   - backend work, so it waits for the user's word.
3. **Symptoms log today only.** `SymptomCompanionScreen` has no day parameter,
   so Add on a past day says so instead of opening it.
4. **Programs have no session dates.** `PrepareStore` keeps ids only, so they
   are listed in Coming up, undated.
5. **The Td milestone is English only** (`hi` repeats the English), per the
   2026-08-27 rule.
6. **TTC discussion next.** These are what pregnancy now has that the TTC
   calendar lacks:
   - the empty day that invites;
   - Add as a sheet of rows that says why a row waits;
   - Coming up with date blocks;
   - this fact table format.
