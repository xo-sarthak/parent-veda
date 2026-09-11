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

/// The human safety line the brief writes, used on two tabs.
///
/// ⚠️ ONE STRING, TWO PLACES. The timer's tab and the Talk tab both carry a
/// safety note, and the brief gives a different sentence for each — the timer's
/// is about what a timer cannot tell her, the area's is about calling anyway.
/// Writing either twice would be two places for a safety line to drift.
const String kLabourTimerNote =
    "We can't tell you if it's labour, but your doctor can. If anything feels "
    'off, call them, even if this screen looks calm.';

const String kLabourAreaNote =
    'If anything feels off, call your doctor, even if this screen looks calm.';

final PvDoorPage kLabourDoor = PvDoorPage(
  bracketId: 'pregnancy_labour',

  // ⚠️ THE HUB'S OWN LINE, KEPT. The brief says keep the hero, and "Getting
  // ready for the birth" is what the landing said.
  heroTitle: 'Getting ready for the birth.',
  heroBlurb: 'What happens, what to decide beforehand, and what to carry.',

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
          blurb: 'Tap when one starts, tap when it stops. It keeps the '
              'pattern so you do not have to.',
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
          blurb: 'When to start timing, what the numbers mean, and the one '
              'pattern that means leave for the hospital.',
          meta: '2 MIN',
        ),
        // ⚠️ THE SINGLE-SOURCE LINK THE BRIEF ASKS FOR. The contractions
        // explainer must not restate practice contractions; it points here.
        // The page lives in `kReportFindings`, which is why this is a finding
        // rather than a condition — see §4a of the playbook.
        PvDoorEntryTile(
          title: 'Tightenings that are not labour',
          blurb: 'The practice contractions almost everyone gets, and how they '
              'differ from the real thing.',
          library: PvDoorLibrary.finding,
          entryId: 'braxton_hicks',
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
          blurb: 'Documents, you, the baby and whoever comes with you — with '
              'how ready you actually are.',
          surfaceId: kLabourSurfaceBag,
        ),
      ],
    ),

    // =========================================================================
    //  SUB-TAB 3 · Understand the birth
    // =========================================================================
    PvDoorSection(
      group: kLabourTabBirth,
      heading: 'What actually happens',
      tiles: [
        PvDoorVideoTile(
          title: 'Labour, start to finish',
          blurb: 'The stages, how long each usually takes, and what it feels '
              'like.',
          meta: '12 MIN',
        ),
        PvDoorReadTile.comingSoon(
          title: 'If it becomes a C-section',
          blurb: 'What the operation involves, what you will feel, and what '
              'recovery is actually like.',
          meta: '6 MIN',
        ),
        PvDoorReadTile.comingSoon(
          title: 'The first hour after birth',
          blurb: 'What happens to you and the baby in the hour nobody '
              'describes.',
          meta: '5 MIN',
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
          blurb: 'What each one involves, what it costs here, and what you can '
              'leave until the day.',
          readId: 'preg_labour_read_pain_relief',
        ),
        // ⚠️ THE TOOL SITS BETWEEN THE PRIMER AND THE OWED READ. She reads
        // about pain relief, writes down what she is thinking, and the read
        // about her options is the one still coming. The blurb is the journey
        // step's own line, kept — it was the best sentence anyone wrote about
        // this feature before it existed.
        PvDoorToolTile(
          title: 'Your birth plan',
          blurb: 'One page your hospital can actually read at 3am. A '
              'preference, not a promise.',
          surfaceId: kLabourSurfaceBirthPlan,
        ),
        PvDoorReadTile.comingSoon(
          title: 'What labour is actually like, and your options',
          blurb: 'Pain relief, positions, who is in the room — decided calmly '
              'now rather than mid-contraction.',
          meta: '5 MIN',
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
      heading: 'What your partner can actually do',
      tiles: [
        PvDoorReadTile.comingSoon(
          title: 'What your partner should actually do',
          blurb: 'The practical jobs, in order, for somebody who has never '
              'done this either.',
          meta: '5 MIN',
        ),
        // ⚠️ CLASS 5 OF THE COURSE, NOT A SECOND VIDEO. It opens the course
        // rather than playing anything, which is honest: the class is real, it
        // is behind the paywall, and the card says so by opening the page where
        // that is visible.
        PvDoorToolTile(
          title: 'Your partner as birth support',
          blurb: 'Class 5 of the birthing course — sixteen minutes on what to '
              'do in the room.',
          surfaceId: kLabourSurfaceCourse,
        ),
        // ⚠️ THE PACKER'S OWN SECTION, NOT A SECOND LIST.
        PvDoorToolTile(
          title: 'What to pack for whoever comes with you',
          blurb: 'The Partner & extras section of your hospital bag.',
          surfaceId: kLabourSurfaceBag,
        ),
      ],
    ),

    // =========================================================================
    //  SUB-TAB 5 · Talk and learn
    // =========================================================================
    PvDoorSection(
      group: kLabourTabTalk,
      heading: 'Get taught properly',
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
              'and Hindi. ₹1,499 one-time — the first class and the trailer '
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
          blurb: 'Half an hour with an obstetrician to ask what you actually '
              'want to ask.',
          surfaceId: kLabourSurfaceConsult,
        ),
      ],
    ),
  ],
);
