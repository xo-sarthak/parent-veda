// =============================================================================
//  Labour prep — the door
// -----------------------------------------------------------------------------
//  Built from `ParentVeda_Labour_prep_rebuild.pdf`, 30 Aug 2026. Fifth of the
//  eight pregnancy briefs, and the first that is tools-first: the default tab is
//  a timer, not a read.
//
//  ---------------------------------------------------------------------------
//  ⚠️ THE DEFAULT IS THE TIMER, AND THE REASON IS THE WHOLE AREA
//  ---------------------------------------------------------------------------
//
//  The brief: *"Default is the Contraction timer, because near the due date
//  people open a tool, not a read."*
//
//  That is the right call and it is worth stating as a rule: **a door's default
//  tab is whichever one somebody opens the app FOR.** On Scans it is the
//  timeline, on Complications the search, here the timer. Never the most
//  important content — the thing she came to do.
//
//  ---------------------------------------------------------------------------
//  ⚠️ THE VOICE RULE, AND THE ONE EDIT IT COST
//  ---------------------------------------------------------------------------
//
//  *"Every line the user reads is spoken TO her, warmly, like an app talks to a
//  person, NEVER like a legal notice or company copy."*
//
//  The timer's disclaimer was the offender: a heading reading "A timer, not a
//  diagnosis" over a body that opened "ParentVeda is not a medical or
//  diagnostic service." Both are rewritten in `app_language.dart` — heading and
//  first sentence only, in BOTH languages, with every word of the actual safety
//  untouched. Its closing line was already the brief's second human line, word
//  for word.
//
//  ---------------------------------------------------------------------------
//  ⚠️ THE BIRTH PLAN: LISTED FIRST, THEN BUILT, AND THE ORDER MATTERS
//  ---------------------------------------------------------------------------
//
//  The brief marks *"Your birth plan, and how to make one"* as `[Guide] reuse
//  (pulled out of the old accordion)`. There was no accordion and no content;
//  `pregnancy_journeys.dart` had REMOVED the step that promised it — *"The
//  birth-plan tool does not exist, so the step promised a page and delivered a
//  grey card."* So on 2026-09-10 the card was omitted and the conflict was
//  recorded in STILL-OPEN §37.3 as the user's call.
//
//  On 2026-09-11 the user made it: *"the PDF says it, so we need it."* The tool
//  now exists — `birth_plan_data.dart`, `BirthPlanStore`, `BirthPlanScreen` —
//  and the card is on the rail below as a TOOL, not a guide, because what she
//  needs is somewhere to write it down, not something else to read.
//
//  ⚠️ THE JOURNEY STEP IS NOT RESTORED HERE. `pregnancy_journeys.dart` removed
//  two steps on review, and the review's reason was the grey card. That reason
//  is gone; the decision was still somebody else's. Restoring the step is one
//  uncomment with a `surfaceId` and it is listed in STILL-OPEN §38.6 as a
//  question, not done as a side effect.
//
//  ---------------------------------------------------------------------------
//  ⚠️ SIX COMING-SOON CARDS, AND THE BRIEF MARKS FIVE OF THEM ITSELF
//  ---------------------------------------------------------------------------
//
//  This area promises more than it has written, and it says so. The videos and
//  reads below are declared in `kPgBirthPrep` — as `owed: true` elements or as
//  `JourneyRead`s whose `surfaceId` is, in the model's own words, *"Null until a
//  real article exists behind it."*
//
//  They hold their place at full size and do not tap. That is the rule at the
//  head of `pv_placeholders.dart` and it is the honest treatment: the alternative
//  is a rail of three cards where the brief describes six, and a door that
//  quietly forgets what the area promised.
//
//  ⚠️ AND THE PROMISES STAY. CLAUDE.md: aspirational copy for unbuilt features
//  is not deleted — the gap is recorded and the words remain.
//
//  ---------------------------------------------------------------------------
//  ⚠️ SINGLE SOURCE, THREE TIMES
//  ---------------------------------------------------------------------------
//
//  · The contractions explainer links to **Braxton Hicks in Complications** —
//    which lives in `kReportFindings`, so the tile uses the finding library.
//    See `docs/PREGNANCY-DOOR-BUILD.md` §4a.
//  · "Your partner as birth support" is **class 5 of the birthing course**, not
//    a second video. It opens the course.
//  · "What to pack for whoever comes with you" is **Partner & extras in the
//    packer**, not a second list. It opens the bag.
// =============================================================================

import 'package:flutter/material.dart' show Icons;

import 'pv_door_data.dart';
import 'pv_door_twins.dart' show kTwinsSurfaceDoor;

/// Surfaces this door opens. Constants because each becomes a route NAME.
const String kLabourSurfaceTimer = 'contractions';
const String kLabourSurfaceBag = 'hospital_bag';
const String kLabourSurfaceCourse = 'birthing_classes';
const String kLabourSurfaceConsult = 'consults';

/// ⚠️ A ROUTE NAME. `openPvDoorSurface` pushes with `RouteSettings(name: id)`,
/// so this string is what the navigator stack shows — the same `area/thing`
/// shape as `scans/…` and `conditions/…`, which is what anything reading the
/// stack (the Ask Veda FAB's suppression list, a future deep link) matches on.
const String kLabourSurfaceBirthPlan = 'labour/birth_plan';

const String kLabourTabTimer = 'timer';
const String kLabourTabBag = 'bag';
const String kLabourTabBirth = 'birth';
const String kLabourTabPartner = 'partner';
const String kLabourTabTalk = 'talk';

// Added 2026-09-29 from the pregnancy gap analysis (Flo / What to Expect vs
// ParentVeda), Labour prep, P1 and P2: "Signs and stages" (the birth itself,
// written for Indian hospitals, with the timer beside it) and "Feeding and
// first days" (getting ready to feed, before the baby comes). Both are data:
// a `PvDoorGroup` and its sections. The carousel draws any number of groups.
const String kLabourTabSigns = 'signs';
const String kLabourTabFeeding = 'feeding';

/// The human safety line the brief writes, used on two tabs.
///
/// ⚠️ ONE STRING, TWO PLACES. The timer's tab and the Talk tab both carry a
/// safety note, and the brief gives a different sentence for each — the timer's
/// is about what a timer cannot tell her, the area's is about calling anyway.
/// Writing either twice would be two places for a safety line to drift.
const String kLabourTimerNote =
    "We can't tell you if it's labour, but your doctor can.";
// ⚠️ ONE SENTENCE, NOT TWO. It used to continue "If anything feels off, call
// them, even if this screen looks calm" — which is `kLabourAreaNote` in
// other words, and the door prints that as its closing line on the same tab
// three cards down. Seen on a phone, 2026-09-12: the same caution twice in
// one screen. The note now says the thing only this tab needs to say; the
// closing line says the thing every tab does.

// Rewritten 2026-09-29 to docs/PREG-VOICE.md.
const String kLabourAreaNote =
    'If anything feels wrong, call your doctor, even if this screen looks '
    'calm.';

final PvDoorPage kLabourDoor = PvDoorPage(
  bracketId: 'pregnancy_labour',

  // ⚠️ THE HUB'S OWN LINE, KEPT. The brief says keep the hero, and "Getting
  // ready for the birth" is what the landing said.
  heroTitle: 'Getting ready for the birth.',
  // Rewritten 2026-09-29 to docs/PREG-VOICE.md.
  heroBlurb: 'What happens on the day, what to decide now, and what to take '
      'with you.',

  // ⚠️ A LATE BUMP AND A DOORWAY, NOT A PACKED SUITCASE. The literal reading
  // of "what to carry" is a bag, and every stock bag is a holiday suitcase on
  // a hotel bed — which would put a woman near her due date in front of a
  // picture of going on a trip.
  //
  // Hands cradling a very late bump in front of a wooden door says "nearly
  // there" without saying anything clinical, and the tab under it is a
  // contraction timer, which is where the specifics live.
  heroImageUrl:
      'https://images.unsplash.com/photo-1568043625493-2b0633c7c491?w=900&h=700&fit=crop',

  closingLine: kLabourAreaNote,

  groups: [
    // -------------------------------------------------------------------------
    //  1. Contraction timer — the tool, inline, and the default
    // -------------------------------------------------------------------------
    //  ⚠️ THE TIMER IS A CARD, NOT AN INLINE TOOL, AND THIS IS THE ONE PLACE
    //  THIS ENGINE DEVIATES FROM ITS OWN RULE. Written down because the rule is
    //  right and this exception is narrow.
    //
    //  Every other tool tab renders its tool in place — the scans timeline, the
    //  report locker, the conditions search, the bump keepsake — because a card
    //  in front of a tool inside a tab whose content IS that tool is a door in
    //  front of a door. Those are all lists.
    //
    //  The contraction timer is not. It is a phase machine with a live session,
    //  a `PopScope` that saves when you leave it, voice guidance, a safety
    //  sheet and a history screen, and its whole interface is one enormous
    //  button. Embedded, it would sit below a carousel inside a scrolling page:
    //  the save-on-pop never fires because you never pop, three app-bar actions
    //  including the safety check have nowhere to live, and a woman timing a
    //  contraction has to scroll to find the button.
    //
    //  ⚠️ SO THE TEST IS NOT "IS IT A TOOL", IT IS "IS IT A LIST". A tool whose
    //  content is a list embeds. A tool that owns the screen — a timer, a
    //  camera, anything with a live session — gets a card and keeps its screen.
    //  The tab is still not a rail, which is what the brief actually forbids.
    PvDoorGroup(
      id: kLabourTabTimer,
      label: 'Contraction timer',
      icon: Icons.timer_outlined,
      hue: 344,
      layout: PvDoorLayout.stack,
      // ⚠️ THE TIMER'S OWN SAFETY LINE, PINNED ABOVE IT. The brief: "Keep it
      // pinned and visible." It is a NOTE and not a red flag — the flag
      // treatment is coral and urgent, and this is a standing caution about
      // what a tool can and cannot tell her, not an emergency.
      note: kLabourTimerNote,
    ),

    // -------------------------------------------------------------------------
    //  2. Signs and stages (added 2026-09-29, gap analysis P1)
    // -------------------------------------------------------------------------
    //  Beside the timer, because the brief puts it there: "Written for Indian
    //  hospitals, with our contraction timer beside it." A rail of reads, like
    //  Understand the birth.
    PvDoorGroup(
      id: kLabourTabSigns,
      label: 'Signs and stages',
      icon: Icons.timeline_rounded,
      hue: 320,
    ),

    //  ⚠️ THE PACKER IS A CARD FOR A SECOND REASON, ON TOP OF THE FIRST. It
    //  carries a `bottomNavigationBar` — the pinned "Labour started?" alert the
    //  brief says to keep — and a bottom bar has no meaning inside somebody
    //  else's scroll. Embedding it would drop the one element on that tool the
    //  brief calls out by name.
    PvDoorGroup(
      id: kLabourTabBag,
      label: 'Hospital bag',
      icon: Icons.work_outline_rounded,
      hue: 160,
      layout: PvDoorLayout.stack,
    ),

    PvDoorGroup(
      id: kLabourTabBirth,
      label: 'Understand the birth',
      icon: Icons.menu_book_outlined,
      hue: 26,
    ),

    // -------------------------------------------------------------------------
    //  Feeding and first days (added 2026-09-29, gap analysis P2)
    // -------------------------------------------------------------------------
    //  "She is not meeting breastfeeding for the first time at 3 am in a
    //  ward." Five reads for the last weeks, and the expert note that was
    //  the whole of this subject before.
    PvDoorGroup(
      id: kLabourTabFeeding,
      label: 'Feeding and first days',
      icon: Icons.child_care_outlined,
      hue: 12,
    ),

    PvDoorGroup(
      id: kLabourTabPartner,
      label: 'For your partner',
      icon: Icons.people_outline_rounded,
      hue: 206,
    ),

    // -------------------------------------------------------------------------
    //  5. Talk and learn — the paid layer
    // -------------------------------------------------------------------------
    //  ⚠️ THE AREA'S SAFETY LINE IS A NOTE HERE TOO. Two notes on one door,
    //  saying different things, which is right: the timer's is about the tool,
    //  this one is about the area.
    PvDoorGroup(
      id: kLabourTabTalk,
      label: 'Talk and learn',
      icon: Icons.school_outlined,
      hue: 42,
      note: kLabourAreaNote,
    ),
  ],

  sections: [
    // =========================================================================
    //  SUB-TAB 1 · Contraction timer
    // =========================================================================
    PvDoorSection(
      group: kLabourTabTimer,
      heading: 'Time a contraction',
      tiles: [
        // ⚠️ FIRST ON THE DEFAULT TAB, WHICH IS THE WHOLE POINT OF THE
        // ORDERING. Somebody opening this door near her due date is one tap
        // from the timer, and the tap lands on the tool's own full screen
        // where the button is the size it needs to be.
        PvDoorToolTile(
          title: 'Contraction Tracker',
          blurb: 'Tap when one starts, tap when it stops. It keeps track of '
              'the pattern for you.',
          surfaceId: kLabourSurfaceTimer,
        ),
      ],
    ),

    PvDoorSection(
      group: kLabourTabTimer,
      heading: 'Before you need it',
      tiles: [
        // ⚠️ COMING SOON. Declared in `kPgBirthPrep` as an owed element, with
        // its own note: "Learning it now is the only time you can. In labour
        // you will want it to already be familiar."
        PvDoorVideoTile(
          title: 'The contraction timer, in two minutes',
          blurb: 'When to start timing, what the numbers mean, and the '
              "pattern that means it's time to go.",
          meta: '2 MIN',
        ),
        // ⚠️ THE SINGLE-SOURCE LINK THE BRIEF ASKS FOR. The contractions
        // explainer must not restate practice contractions; it points here.
        // The page lives in `kReportFindings`, which is why this is a finding
        // rather than a condition — see §4a of the playbook.
        PvDoorEntryTile(
          title: 'Tightenings that are not labour',
          blurb: 'The practice tightenings almost everyone gets, and how '
              'they differ from labour.',
          library: PvDoorLibrary.finding,
          entryId: 'braxton_hicks',
        ),
        // Added 2026-09-29 (gap analysis Appendix A, "Final push: your
        // contraction cheat sheet", P2): the timer counts but did not say
        // what the timings mean. The guide opens the when-to-go read at the
        // section that does, ending on "follow what your doctor told you".
        PvDoorGuideTile(
          title: 'What the timings mean',
          blurb: 'Early labour, the 5-1-1 pattern, and when to leave sooner.',
          readId: 'preg_labour_read_when_to_go',
          atHeading: 'What do the timings on the timer mean?',
        ),
      ],
    ),

    // =========================================================================
    //  Signs and stages (added 2026-09-29, gap analysis P1)
    // -------------------------------------------------------------------------
    //  Twelve reads written for this tab (`pregnancy_reads_labour_birth.dart`),
    //  plus the weekly "Labour, step by step", which the gap analysis found
    //  existed but was not on this door: "The one read we have is not where
    //  she looks for it." The C-section and first-hour reads also sit on
    //  Understand the birth, where their coming-soon cards were.
    // =========================================================================
    PvDoorSection(
      group: kLabourTabSigns,
      heading: 'Is it labour?',
      tiles: [
        PvDoorGuideTile(
          title: 'Is labour near? The signs to look for',
          blurb: 'The days before, practice tightenings or the real thing, '
              'and when babies usually come.',
          readId: 'preg_labour_read_signs_near',
        ),
        PvDoorGuideTile(
          title: 'When your waters break',
          blurb: 'What it feels like, what the colour means, and what to do '
              'next.',
          readId: 'preg_labour_read_waters',
        ),
        PvDoorGuideTile(
          title: 'When to go to hospital, and what to carry',
          blurb: 'When to call first, when to go now, and the folder to keep '
              'by the door.',
          readId: 'preg_labour_read_when_to_go',
        ),
        PvDoorGuideTile(
          title: 'Signs of early labour, before 37 weeks',
          blurb: 'The signs to know, and why going in straight away helps.',
          readId: 'preg_labour_read_preterm',
        ),
      ],
    ),

    PvDoorSection(
      group: kLabourTabSigns,
      heading: 'Time them',
      tiles: [
        PvDoorToolTile(
          title: 'Contraction Tracker',
          blurb: 'Tap when one starts and when it stops. It shows the pattern '
              'to tell your doctor.',
          surfaceId: kLabourSurfaceTimer,
        ),
      ],
    ),

    PvDoorSection(
      group: kLabourTabSigns,
      heading: 'The day itself',
      tiles: [
        PvDoorGuideTile(
          title: 'Labour, step by step',
          blurb: 'The three stages, how long each usually takes, and when to '
              'go in.',
          readId: 'preg_week_read_labour_prep',
        ),
        PvDoorGuideTile(
          title: 'The three stages of labour, in an Indian hospital',
          blurb: "What 'dilated' means, and the checks and drips you may meet.",
          readId: 'preg_labour_read_stages',
        ),
        PvDoorGuideTile(
          title: 'Pushing, and the placenta',
          blurb: 'How to push, positions that help, and the stage after the '
              'baby.',
          readId: 'preg_labour_read_pushing_placenta',
        ),
        PvDoorGuideTile(
          title: 'Will I tear? Episiotomy, tears and stitches',
          blurb: 'What helps before and during the birth, and how stitches '
              'heal.',
          readId: 'preg_labour_read_tears',
        ),
        PvDoorGuideTile(
          title: 'The first hour after birth',
          blurb: 'Skin to skin, the cord, the first checks and the first '
              'feed.',
          readId: 'preg_labour_read_first_hour',
        ),
      ],
    ),

    PvDoorSection(
      group: kLabourTabSigns,
      heading: 'If the plan changes',
      tiles: [
        // Twins and more (2026-09-29): how twins are born lives there.
        PvDoorToolTile(
          title: 'Having twins',
          blurb: 'How twins are born, when, and getting ready for two.',
          surfaceId: kTwinsSurfaceDoor,
        ),
        PvDoorGuideTile(
          title: 'Induction: why, how and what it feels like',
          blurb: 'Why your doctor might start labour, and what to ask first.',
          readId: 'preg_labour_read_induction',
        ),
        PvDoorGuideTile(
          title: 'Past your due date',
          blurb: "The checks after 40 weeks, and what's safe to try at home.",
          readId: 'preg_labour_read_past_due',
        ),
        PvDoorGuideTile(
          title: 'If it becomes a C-section',
          blurb: 'Planned or during labour: why, what happens, and the days '
              'after.',
          readId: 'preg_labour_read_c_section',
        ),
        PvDoorGuideTile(
          title: 'Birth after a C-section',
          blurb: 'When a vaginal birth may still be possible, and what to ask.',
          readId: 'preg_labour_read_vbac',
        ),
      ],
    ),

    // =========================================================================
    //  SUB-TAB 2 · Hospital bag
    // -------------------------------------------------------------------------
    //  ⚠️ ONE CARD, AND EVERYTHING THE BRIEF LISTS IS INSIDE IT. The % ready
    //  ring, the time-left and due-date chips, "Let's pack together", the four
    //  sections with their counts, the India tips and the pinned "Labour
    //  started?" alert are all parts of the packer — the brief lists them to
    //  say "keep all of this", not to ask for six cards.
    // =========================================================================
    PvDoorSection(
      group: kLabourTabBag,
      heading: 'Pack it once, properly',
      tiles: [
        PvDoorToolTile(
          title: 'Ready for Birth',
          blurb: 'Documents, you, the baby and whoever comes with you, and '
              "how ready you are.",
          surfaceId: kLabourSurfaceBag,
        ),
      ],
    ),

    // =========================================================================
    //  SUB-TAB 3 · Understand the birth
    // =========================================================================
    PvDoorSection(
      group: kLabourTabBirth,
      heading: 'What happens on the day',
      tiles: [
        PvDoorVideoTile(
          title: 'Labour, start to finish',
          blurb: 'The stages, how long each usually takes, and what it feels '
              'like.',
          meta: '12 MIN',
        ),
        // Written 2026-09-29 (gap analysis P1: "Write 'If it becomes a
        // C-section' first"). Was `PvDoorReadTile.comingSoon`, meta 6 MIN;
        // kept for revert:
        //   PvDoorReadTile.comingSoon(title: 'If it becomes a C-section',
        //     blurb: ..., meta: '6 MIN'),
        PvDoorGuideTile(
          title: 'If it becomes a C-section',
          blurb: "What happens, what you'll feel, and what recovery is like.",
          readId: 'preg_labour_read_c_section',
        ),
        // Written 2026-09-29, with skin to skin folded in (Appendix A).
        // Was `PvDoorReadTile.comingSoon`, meta 5 MIN.
        PvDoorGuideTile(
          title: 'The first hour after birth',
          blurb: 'What happens to you and your baby in the golden hour.',
          readId: 'preg_labour_read_first_hour',
        ),
      ],
    ),

    PvDoorSection(
      group: kLabourTabBirth,
      heading: 'Your choices to make now',
      tiles: [
        // ⚠️ THE ONE NEW READ ON THIS DOOR, AND IT IS FIRST. The two beside it
        // are still owed, so a rail that led with them would open on two grey
        // cards.
        PvDoorGuideTile(
          title: 'Pain relief: natural, epidural and C-section',
          blurb: 'What each one involves, what it costs here, and what can '
              'wait until the day.',
          readId: 'preg_labour_read_pain_relief',
        ),
        // ⚠️ THE TOOL SITS BETWEEN THE PRIMER AND THE OWED READ. She reads
        // about pain relief, writes down what she is thinking, and the read
        // about her options is the one still coming. The blurb is the journey
        // step's own line, kept — it was the best sentence anyone wrote about
        // this feature before it existed.
        PvDoorToolTile(
          title: 'Your birth plan',
          blurb: 'One page your hospital can read at 3am. A preference, not '
              'a promise.',
          surfaceId: kLabourSurfaceBirthPlan,
        ),
        // Written 2026-09-29. Was `PvDoorReadTile.comingSoon`, titled "What
        // labour is actually like, and your options" (meta 5 MIN); the title
        // lost "actually" (PREG-VOICE §4).
        PvDoorGuideTile(
          title: 'What labour is like, and your options',
          blurb: 'Where to give birth, who can be with you, and positions '
              'that help.',
          readId: 'preg_labour_read_options',
        ),
      ],
    ),

    // =========================================================================
    //  SUB-TAB 4 · For your partner
    // =========================================================================
    PvDoorSection(
      group: kLabourTabPartner,
      // ⚠️ "YOUR PARTNER", NOT "HE". Two cards below this one say "whoever
      // comes with you" — the careful phrase, written that way because the
      // person in the room is often a mother, a sister or a friend. A heading
      // that assumes a husband contradicts the door's own copy a centimetre
      // later, and it is the woman who does not have one who reads it hardest.
      heading: 'How your partner can help',
      tiles: [
        // Written 2026-09-29, with who can be in the room in Indian hospitals
        // and choosing a birth companion folded in (Appendix A). Was
        // `PvDoorReadTile.comingSoon`, titled "What your partner should
        // actually do" (meta 5 MIN).
        PvDoorGuideTile(
          title: 'What your partner should do',
          blurb: 'The jobs, in order, for someone who has never done this '
              'either.',
          readId: 'preg_labour_read_partner',
        ),
        // ⚠️ CLASS 5 OF THE COURSE, NOT A SECOND VIDEO. It opens the course
        // rather than playing anything, which is honest: the class is real, it
        // is behind the paywall, and the card says so by opening the page where
        // that is visible.
        PvDoorToolTile(
          title: 'Your partner as birth support',
          blurb: 'Class 5 of the birthing course: sixteen minutes on what to '
              'do in the room.',
          surfaceId: kLabourSurfaceCourse,
        ),
        // ⚠️ THE PACKER'S OWN SECTION, NOT A SECOND LIST.
        PvDoorToolTile(
          title: 'What to pack for whoever comes with you',
          blurb: 'The Partner & extras part of your hospital bag.',
          surfaceId: kLabourSurfaceBag,
        ),
      ],
    ),

    // =========================================================================
    //  Feeding and first days (added 2026-09-29, gap analysis P2)
    // =========================================================================
    PvDoorSection(
      group: kLabourTabFeeding,
      heading: 'Before the first feed',
      tiles: [
        PvDoorGuideTile(
          title: 'How breastfeeding starts',
          blurb: 'A good latch, holds to learn now, and hand expression.',
          readId: 'preg_labour_read_bf_start',
        ),
        PvDoorGuideTile(
          title: 'Colostrum, and when your milk comes in',
          blurb: 'Why a few drops are enough, and what happens on day two to '
              'four.',
          readId: 'preg_labour_read_colostrum',
        ),
        PvDoorGuideTile(
          title: 'The first feed, in the golden hour',
          blurb: 'What it looks like, and how to ask for it in hospital.',
          readId: 'preg_labour_read_golden_hour_feed',
        ),
        PvDoorGuideTile(
          title: 'Why early breastfeeding preparation helps',
          blurb: 'Three things worth knowing before the first feed.',
          readId: 'preg_week_read_exp_meera',
        ),
      ],
    ),

    PvDoorSection(
      group: kLabourTabFeeding,
      heading: 'Help, and the first weeks',
      tiles: [
        PvDoorGuideTile(
          title: 'Asking for feeding help in hospital',
          blurb: 'Who can help, what to ask on day one, and support at home.',
          readId: 'preg_labour_read_feeding_help',
        ),
        PvDoorGuideTile(
          title: 'Planning the first 40 days at home',
          blurb: 'Rest, help, food and visitors, and the signs that need a '
              'doctor.',
          readId: 'preg_labour_read_first_40',
        ),
        PvDoorGuideTile(
          title: 'The first 24 hours after birth',
          blurb: "The baby's first checks and jabs, and what happens to you.",
          readId: 'preg_week_read_first_24h',
        ),
      ],
    ),

    // =========================================================================
    //  SUB-TAB 5 · Talk and learn
    // =========================================================================
    PvDoorSection(
      group: kLabourTabTalk,
      heading: 'Learn with a teacher',
      tiles: [
        // ⚠️ THE PAID COURSE, AND ITS PRICE IS ON THE CARD. This app's rule is
        // that a tile which costs money must be legible as such BEFORE she taps
        // — a shop tile that looks like an article is a dark pattern whether or
        // not anyone meant it that way.
        //
        // ⚠️ AND THE PRICING, CLASS LIST AND EDUCATOR ARE NOT RETYPED. They
        // live in `kBirthingClasses` and `prepare_data.dart`; this card opens
        // the screen that renders them. The brief says keep them exactly, which
        // is easiest to guarantee by not copying them.
        //
        // ⚠️ THE PRICE IS IN `meta`, NOT ONLY IN THE BLURB, AND THAT IS A BUG
        // FOUND ON THE PHONE. This app's rule is that a tile which costs money
        // is legible as such BEFORE she taps, and `pv_door_labour_test.dart`
        // asserted exactly that — against the BLURB. But a rail card draws the
        // badge, `meta` and the title, and deliberately does not draw the
        // blurb (see `_RailCard`). So the only paid card on this door rendered
        // as "Complete Birthing Course" and nothing else: the test passed and
        // the promise was invisible.
        //
        // The general shape: a test that asserts a string exists on a model is
        // not a test that the string reaches a screen. `meta` is the field the
        // card actually paints, so the price goes there.
        PvDoorToolTile(
          title: 'Complete Birthing Course',
          meta: '₹1,499 · first class free',
          blurb: 'Six classes with a certified childbirth educator, in English '
              'and Hindi. ₹1,499 one-time. The first class and the trailer '
              'are free.',
          surfaceId: kLabourSurfaceCourse,
        ),
      ],
    ),

    PvDoorSection(
      group: kLabourTabTalk,
      heading: 'Talk to someone',
      tiles: [
        PvDoorTalkTile(
          title: 'Book a 1:1 about the birth',
          blurb: 'Half an hour with an obstetrician, to ask everything you '
              'want to ask.',
          surfaceId: kLabourSurfaceConsult,
        ),
      ],
    ),
  ],
);
