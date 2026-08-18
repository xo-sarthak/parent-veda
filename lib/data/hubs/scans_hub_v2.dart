// =============================================================================
//  Scans & tests — V2. Three doors.
// -----------------------------------------------------------------------------
//  V1 (`scans_hub.dart`) is untouched and still reachable from the toggle.
//
//  ---------------------------------------------------------------------------
//  ⚠️ WHY SIX BECAME THREE
//  ---------------------------------------------------------------------------
//  V1 took the reconciliation Excel's six JOURNEY STEPS and made them six
//  DOORS. That was the mistake, and it is worth naming exactly, because it
//  would otherwise have repeated across all forty hubs:
//
//      a journey is a walk; a hub is a fork.
//
//  Flattening the walk into a fork forces every step to justify itself as a
//  reason to open the app — and most steps cannot, because they were never
//  meant to. "What happens next?" is a fine stage of a journey and a nonsense
//  choice on a menu. Nobody unlocks their phone thinking it.
//
//  So the test a door has to pass here is: **it names a reason someone picked
//  up their phone.** Not a topic we cover. Not a thing we happen to have.
//
//  Three sentences survive that test for scans:
//
//      "What's next, and what have I had?"        -> My scans
//      "Where did I put that report?"             -> My reports
//      "What does this line on it mean?"          -> Understand a result
//
//  Nothing was deleted. The four doors that went away became destinations one
//  level in: tapping a scan explains it, the booked date lives on the timeline,
//  and what a result means sits inside the decoder where the question is
//  actually asked.
//
//  ---------------------------------------------------------------------------
//  ⚠️ NO URGENT STRIP, AND NO "NEED EXPERT HELP" DOOR. BOTH DELIBERATE.
//  ---------------------------------------------------------------------------
//  V1 had a red-flag strip at the top (bleeding, one-sided pain, shoulder-tip
//  pain) and a matching door. Both are gone, and the reasoning is the strongest
//  argument made about this hub:
//
//      **Nobody discovers an emergency by scrolling.**
//
//  A woman with one-sided pain is not browsing her scan records. She is already
//  frightened and already knows to call someone. Putting the warning here does
//  not reach her; it only makes a records screen alarming for the thousands of
//  people who are fine. If we handle alarm, it needs a mechanism that finds
//  HER — not a paragraph that waits to be scrolled past.
//
//  That is a real, separate problem. It is not this hub's problem, and pinning
//  it here was us feeling responsible rather than being useful.
//
//  ⚠️ The red-flag DATA is not deleted — `kScanRedFlags`, `kScanUrgentSigns`
//  and `ScanUrgentScreen` all still ship, still tested, still reachable from
//  V1. Nothing is lost; it is unpinned from the wrong screen.
//
//  What replaces it is honest: if she wants an expert, we offer an expert —
//  a real 1:1 consultation she can book, at the foot, after the app has done
//  what it can.
//
//  ⚠️ ENGLISH ONLY FOR NOW. Warm, short, plain — she is often reading this
//  tired, on a phone, in a waiting room.
// =============================================================================

import '../../localization/app_language.dart';
import '../../screens/brackets/hub/hub_config.dart';
import '../../screens/brackets/hub/hub_intent_art.dart';

LocalizedText _en(String s) => LocalizedText(en: s, hi: s);

/// V2 actions. Separate constants from V1 so the two routers cannot drift into
/// each other — the same string meaning two things in two versions is how a
/// toggle stops being a fair comparison.
const String kV2ActMyScans = 'v2_my_scans';
const String kV2ActMyReports = 'v2_my_reports';
const String kV2ActUnderstand = 'v2_understand';
const String kV2ActConsult = 'v2_consult';

final HubConfig kScansHubV2 = HubConfig(
  bracketId: 'pregnancy_scans_tests',
  template: HubTemplate.trackerLed,
  coreQuestion: 'What test is coming, where are my reports, and what do they '
      'mean?',
  hero: _en('Your scans, in one place.'),
  heroSupport: _en('What is coming, what you have had, and what the report '
      'says.'),

  // ⚠️ No `urgent:` — see the header. This is the one hub field whose absence
  // is a decision rather than an omission.

  needsTitle: _en('What do you need?'),

  needs: [
    HubNeed(
      label: _en('My scans'),
      blurb: _en('What is next, and what you have already had.'),
      mark: IntentMark.timelineRail,
      hue: 26,
      action: kV2ActMyScans,
    ),
    HubNeed(
      label: _en('My reports'),
      blurb: _en('Keep every report in one place. A photo is enough.'),
      mark: IntentMark.reportPage,
      hue: 42,
      action: kV2ActMyReports,
    ),
    HubNeed(
      label: _en('Understand a result'),
      blurb: _en('A word you do not know, in plain language.'),
      mark: IntentMark.scanFan,
      hue: 206,
      action: kV2ActUnderstand,
    ),
  ],

  // ⚠️ THIS IS WHAT "NEED EXPERT HELP?" BECAME.
  //
  // V1 answered that question with a list of warning signs, which told a
  // frightened person something she already knew and told everyone else that a
  // records screen was a place to be scared. If she wants an expert, the honest
  // answer is an actual expert — so this books one.
  //
  // At the foot, and quiet: reading usually finishes the job, and this is for
  // when it does not.
  closing: HubClosing(
    label: _en('Talk to a doctor'),
    blurb: _en('Book a 1:1 with a gynaecologist and ask about your report.'),
    action: kV2ActConsult,
  ),
);
