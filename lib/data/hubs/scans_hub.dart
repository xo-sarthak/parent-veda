// =============================================================================
//  Scans & tests — the hub, as data
// -----------------------------------------------------------------------------
//  PARENTVEDA-PROBLEM-HUB-FINAL-SPEC.md §13.1.
//
//    Hero            "Know what your next test or scan is for"
//    LIVE            Content tests_scans · Tools appointments, due_date ·
//                    Consult consults · Extras reports
//    NOT CORE        Activities · Course
//    NOT APPLICABLE  Products
//    Primary intents Understand my next scan · Understand my report ·
//                    See my appointments · Know when to ask my doctor
//
//  ---------------------------------------------------------------------------
//  ⚠️ FOUR DOORS AND NOTHING ELSE. That is the final spec, not an omission.
//  ---------------------------------------------------------------------------
//
//  An earlier build of this hub had a "whole picture" card and three sections of
//  Understand / Check / Talk underneath. §2.2 and §2.3 removed both:
//
//    · asking "what do you need?" and then showing category sections asks the
//      same question twice — she already told us;
//    · a generic situational card interrupts the task she came to do.
//
//  Everything those sections used to list is still reachable — it moved to the
//  DESTINATION each door opens (§5.4), which is where it is actually useful.
//
//  ⚠️ AND EVERY DOOR GOES SOMEWHERE THAT ALREADY EXISTS. Nothing here is new UI:
//  the report decoder, the appointments screen and the scan library all ship
//  today. §2.5 — existing means reuse, not rebuild.
// =============================================================================

import '../../localization/app_language.dart';
import '../../screens/brackets/hub/hub_config.dart';
import '../../screens/brackets/hub/hub_intent_art.dart';

const _t = LocalizedText.new;

/// Actions this hub's own handler understands. Strings, not an enum, because
/// the renderer is generic — it hands the action back rather than knowing what
/// any of them mean.
const String kActUrgent = 'urgent';
const String kActNextScan = 'next_scan';
const String kActSchedule = 'schedule';

/// Journey step 1 — "See my timeline". The run of tests with her own dates on
/// it, which is a different question from "tell me about one scan".
const String kActTimeline = 'timeline';

/// Journey step 5 — "What happens next?". After-scan guidance, and the next
/// test when we know it.
const String kActWhatNext = 'what_next';

final HubConfig kScansHub = HubConfig(
  bracketId: 'pregnancy_scans_tests',
  template: HubTemplate.trackerLed,
  coreQuestion:
      'What test or scan is coming up, what does it mean, and what should I '
      'do next?',
  hero: _t(
      en: 'Know what your next test or scan is for.',
      hi: 'जानिए आपका अगला test या scan किसलिए है।'),
  heroSupport: _t(
      en: "Understand what's coming, what your report means, and what you may "
          'need to do next.',
      hi: 'आगे क्या है, रिपोर्ट का मतलब क्या है, और आगे क्या करना पड़ सकता है।'),

  // ---------------------------------------------------------------------------
  //  §5.2 — an urgent strip only where red flags genuinely matter
  // ---------------------------------------------------------------------------
  //  They matter here more than anywhere else in the product: ectopic pregnancy
  //  is ~74,000 searches a month and is a surgical emergency.
  //
  //  It does not replace the fourth door. "Know when to ask my doctor" is a
  //  calm question asked in daylight; the strip is for someone bleeding now who
  //  will not read four options first. Same destination, two states of mind.
  urgent: HubUrgent(
    line: _t(
        en: 'Bleeding, one-sided pain, or pain at your shoulder tip?',
        hi: 'ख़ून, एक तरफ़ दर्द, या कंधे के सिरे पर दर्द?'),
    action: kActUrgent,
  ),

  needsTitle:
      _t(en: 'What do you need right now?', hi: 'अभी आपको क्या चाहिए?'),

  // ---------------------------------------------------------------------------
  //  The six doors — the reconciliation Excel's journey, in its order
  // ---------------------------------------------------------------------------
  //  ⚠️ THIS WAS FOUR DOORS AND IS NOW SIX. The four were:
  //
  //      Understand my next scan · Understand my report ·
  //      See my appointments · Know when to ask my doctor
  //
  //  PARENTVEDA_FINAL_40_HUB_236_JOURNEY_RECONCILIATION.xlsx specifies this hub
  //  as ONE primary intent ("Know what my next scan/test is for") walked through
  //  SIX journey steps. Two of them had no home at all in the four-door build:
  //  step 1 "See my timeline" and step 5 "What happens next?".
  //
  //  Those two are not decoration. They are the opening and closing moves — the
  //  run of tests she is partway along, and what to do once a scan is done.
  //  Without them the journey has no closure, which the prompt's §4 forbids
  //  outright. The Excel is authoritative for the journey; the inventory is
  //  authoritative only for implementation status.
  //
  //  ⚠️ EVERY LABEL NAMES AN OUTCOME, NEVER A CONTENT TYPE (§2.1). "Understand
  //  my report", not "Articles"; "See my appointment", not "Tools". The test
  //  file fails the build if an inventory word appears here.
  //
  //  Hues are six off the controlled wheel, no two alike, assigned by meaning:
  //  time is peach, the scan itself is the clinical blue, the appointment green,
  //  the report sand, what-comes-next sage, a person rose.
  needs: [
    // ---- STEP 1 · Tool: appointments / due_date ------------------------------
    HubNeed(
      label: _t(en: 'See my timeline', hi: 'अपनी timeline देखिए'),
      blurb: _t(
          en: 'Every test from here to birth, on your dates — and where you '
              'are on it right now.',
          hi: 'यहाँ से जन्म तक हर test, आपकी तारीख़ों पर — और अभी आप कहाँ हैं।'),
      mark: IntentMark.timelineRail,
      hue: 26,
      action: kActTimeline,
    ),

    // ---- STEP 2 · Content: video + article + FAQs ----------------------------
    HubNeed(
      label: _t(en: 'Understand this scan', hi: 'यह scan समझिए'),
      blurb: _t(
          en: 'What it checks, what happens on the day, and how to prepare.',
          hi: 'यह क्या देखता है, उस दिन क्या होगा, और तैयारी कैसे करें।'),
      mark: IntentMark.scanFan,
      hue: 206,
      action: kActNextScan,
    ),

    // ---- STEP 3 · Tool + Content: appointments, preparation attached ---------
    HubNeed(
      label: _t(en: 'See my appointment', hi: 'अपना appointment देखिए'),
      blurb: _t(
          en: 'What is booked, what you have already done, and what to carry.',
          hi: 'क्या बुक है, क्या हो चुका है, और क्या साथ ले जाना है।'),
      mark: IntentMark.calendarDay,
      hue: 160,
      surfaceId: 'appointments',
    ),

    // ---- STEP 4 · Tool + Content: reports ------------------------------------
    HubNeed(
      label: _t(en: 'Understand my report', hi: 'अपनी रिपोर्ट समझिए'),
      blurb: _t(
          en: 'Look up a line you do not recognise, and what to ask about it.',
          hi: 'कोई अनजान लाइन ढूँढिए, और उस पर क्या पूछें।'),
      mark: IntentMark.reportPage,
      hue: 42,
      surfaceId: 'reports',
    ),

    // ---- STEP 5 · Content + Tool: after-scan guidance, next test -------------
    HubNeed(
      label: _t(en: 'What happens next?', hi: 'आगे क्या होगा?'),
      blurb: _t(
          en: 'The scan is done. What the result usually means for the rest of '
              'the pregnancy, and what is due after it.',
          hi: 'scan हो गया। नतीजे का आम तौर पर आगे क्या मतलब है, और इसके बाद '
              'क्या आना है।'),
      mark: IntentMark.nextStep,
      hue: 104,
      action: kActWhatNext,
    ),

    // ---- STEP 6 · Consult: gynae, at the escalation point --------------------
    HubNeed(
      label: _t(en: 'Need expert help?', hi: 'डॉक्टर से बात करनी है?'),
      blurb: _t(
          en: 'The signs worth a call today — and a gynae consult when a '
              'question needs a person, not a page.',
          hi: 'वो बातें जिन पर आज ही फ़ोन करना बनता है — और जब सवाल के लिए '
              'पन्ना नहीं, इंसान चाहिए तो gynae consult।'),
      mark: IntentMark.askDoctor,
      hue: 344,
      action: kActUrgent,
    ),
  ],
);
