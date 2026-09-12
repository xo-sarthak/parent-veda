// =============================================================================
//  Mind & mood — the door
// -----------------------------------------------------------------------------
//  Built from `ParentVeda_Mind_and_mood_final.pdf`, 12 Sep 2026. Sixth of the
//  eight pregnancy briefs, and the one whose area was already the fullest —
//  26 reads, a real breathing tool, a 60-second grounding flow, a screener, a
//  mood log, a worry journal, three paid offerings and a crisis path — so the
//  door's job is mostly to put the right front on it.
//
//  ---------------------------------------------------------------------------
//  ⚠️ THE DUPLICATION BUG THE BRIEF NAMES, FIXED IN THE ROUTER NOT HERE
//  ---------------------------------------------------------------------------
//
//  *"In the build, 'Check how I am feeling' and 'Help me feel better' open the
//  SAME screen. That is a bug."* True — `home_v3_screen.dart` pushed the old
//  four-tab landing for both. They now open this door on `kMindTabTrack` and
//  `kMindTabFeel` respectively, through `PvDoorScreen.initialGroup`. The old
//  landing is retired in place; the bracket's V3 tile opens the door on Feel.
//
//  ---------------------------------------------------------------------------
//  ⚠️ REUSE THE WHOLE SECTION, EXCEPT WHERE MARKED — AND WHAT THAT MEANT HERE
//  ---------------------------------------------------------------------------
//
//  The brief: *"the items named are the visible ones, not the full inventory.
//  Do NOT drop anything."* So the rails are read FROM `kMmArticles` by group,
//  the way Belly & skin reads `kBsPages` — every read in the library is on the
//  door, including the fifteen the brief's map does not name (three fears,
//  six "more than a mood", five "everyday care", the partner piece). Where
//  they sit is the one editorial call this file makes:
//
//    · the six "more than a mood" reads go on **When it is more than this**,
//      under the new baby-blues read, because that tab is where the brief puts
//      perinatal depression ("they live in Sub-tab 4");
//    · the five "everyday care" reads and the three unnamed fears stay on
//      **Understand**, in their own sections, after the brief's three.
//
//  What was REBUILT with the brief's copy, verbatim: the nine "Is this normal"
//  reads, "Fear of being a bad mother", the whole affirmation set, the
//  hard-day reset (a coming-soon video became a guided screen). What is NEW
//  from the brief's copy: seven "What no one talks about" reads, "Baby blues,
//  or something more?", the same-day red flag.
//
//  ---------------------------------------------------------------------------
//  ⚠️ WHAT COULD NOT BE BUILT FROM THE BRIEF, LISTED RATHER THAN INVENTED
//  ---------------------------------------------------------------------------
//
//  The brief's rule is absolute: *"Use that copy VERBATIM. Do not rewrite,
//  shorten or generate your own. If a referenced page is missing, STOP and
//  list it."* Three [new] cards have no copy in section 3:
//
//    · **Tell your doctor** [Guide new] — "How to raise it, with Ask Veda to
//      word it." No copy. COMING SOON on the door; the sentence is owed.
//    · **Your partner can feel this too** [Read new · optional] — no copy, and
//      marked optional. Omitted. The existing partner piece is linked from
//      "Bringing him in" instead, which is where the brief points at it.
//    · **Helpline numbers** [Guide new] — no prose, but it is not prose: it is
//      the four numbers `mind_mood_data.dart` already holds for the crisis
//      path. Built from those, as a screen that lists them. Nothing written.
//
//  ---------------------------------------------------------------------------
//  ⚠️ NO ASK VEDA CARD, SAME AS SCANS
//  ---------------------------------------------------------------------------
//
//  The brief lists "Ask a gentle question [Tool reuse]" on Talk. The Scans
//  door settled this and its test enforces it: the Ask Veda FAB is on every
//  screen of every door, carrying the door's context, and a card that opens
//  the same thing is a second button for one action. Talk here is the three
//  offerings and the crisis path.
//
//  ---------------------------------------------------------------------------
//  ⚠️ BOUNDARIES THE BRIEF DRAWS, KEPT
//  ---------------------------------------------------------------------------
//
//  · Calming audio → the four tracks are `MmCalmAudio` with `asset: null`;
//    they are coming-soon audio cards, not a second library.
//  · Meditations → the five `kMmMeditations` placeholders, coming-soon video
//    cards. The sixth, "A hard-day reset", is no longer a film: it is the tool.
//  · Breathing → `MmBreathingScreen`, the shared circle. Three cards, one tool.
//  · Games stay in Buddhi. Fear of labour links to Labour prep. Nothing here
//    creates a perinatal-depression page outside sub-tab 4.
// =============================================================================

import 'package:flutter/material.dart' show Icons;

import '../mind_mood_data.dart';
import 'pv_door_data.dart';

// Tab ids. Route names hang off some of these — see the router.
const String kMindTabFeel = 'feel';
const String kMindTabUnderstand = 'understand';
const String kMindTabTrack = 'track';
const String kMindTabMore = 'more';
const String kMindTabTalk = 'talk';

// Surfaces. Constants because each becomes a route NAME.
const String kMindSurfaceReset = 'mind/hard_day_reset';
const String kMindSurfaceCalmNote = 'mind/calm_note';
const String kMindSurfaceAffirmations = 'mind/affirmations';
const String kMindSurfaceTrack = 'mind/track';
const String kMindSurfaceCheckIn = 'mind/check_in';
const String kMindSurfaceCrisis = 'mind/crisis';
const String kMindSurfaceHelplines = 'mind/helplines';

/// `mind/breathe/<exercise id>`.
String mindSurfaceBreathe(String id) => 'mind/breathe/$id';

/// `mind/offer/<offering id>`.
String mindSurfaceOffer(String id) => 'mind/offer/$id';

/// Every read in one group, as tiles, in the order the library holds them.
/// Read from `kMmArticles`, which is the whole point — see the header.
List<PvDoorTile> _readsIn(MmArticleGroup g, {Set<String> except = const {}}) =>
    [
      for (final a in mmArticlesIn(g))
        if (!except.contains(a.id))
          PvDoorEntryTile(
            title: a.title.en,
            blurb: a.teaser.en,
            meta: a.readingTime.en,
            library: PvDoorLibrary.mindRead,
            entryId: a.id,
          ),
    ];

/// The brief's three named fears, in its order, then the three it does not
/// name. `fear_not_good_mother` was rebuilt with the brief's copy under its
/// new title.
List<PvDoorTile> _fears() {
  const named = ['fear_not_good_mother', 'fear_labour', 'fear_something_wrong'];
  final byId = {for (final a in mmArticlesIn(MmArticleGroup.fears)) a.id: a};
  return [
    for (final id in named)
      if (byId[id] case final a?)
        PvDoorEntryTile(
          title: a.title.en,
          blurb: a.teaser.en,
          meta: a.readingTime.en,
          library: PvDoorLibrary.mindRead,
          entryId: a.id,
        ),
    ..._readsIn(MmArticleGroup.fears, except: named.toSet()),
  ];
}

final PvDoorPage kMindDoor = PvDoorPage(
  bracketId: 'pregnancy_mental_health',

  // ⚠️ THE EYEBROW IS THE BRACKET'S LABEL — "Mind & mood" — which is what the
  // tile she tapped says. The old landing's title, "Pregnancy mental health",
  // was the bracket's `title` and is not used here; the user asked for the
  // tile's own words at the top.
  heroTitle: 'How you feel matters too.',
  heroBlurb: 'Something to do right now, words for the days no one talks '
      'about, and a real person when you want one.',

  // ⚠️ LOOKED AT BEFORE IT WAS WIRED — see `pv_door_scans.dart` for the rule.
  // A woman resting on a sofa, eyes closed, a hand on her bump, window light,
  // black and white. Nothing clinical, nothing that belongs to a country, and
  // no expression to read a mood off — the one door where a photograph of a
  // feeling would be a photograph of the wrong feeling for half the women
  // who open it. Rest is the one state they all share.
  heroImageUrl:
      'https://images.unsplash.com/photo-1543270216-7c25819fe5af?w=900&h=700&fit=crop',

  // The area's own closing note, in the reads' voice.
  closingLine: 'Nothing here is a test, and nothing is scored. If a feeling '
      'needs a person, the last tab shows you who.',

  groups: [
    // -------------------------------------------------------------------------
    //  1. Feel — "Help me feel better". Default.
    // -------------------------------------------------------------------------
    PvDoorGroup(
      id: kMindTabFeel,
      label: 'Feel',
      icon: Icons.self_improvement_rounded,
      hue: 288,
    ),

    // -------------------------------------------------------------------------
    //  2. Understand — whole tab rebuilt, India-first
    // -------------------------------------------------------------------------
    PvDoorGroup(
      id: kMindTabUnderstand,
      label: 'Understand',
      icon: Icons.menu_book_outlined,
      hue: 206,
    ),

    // -------------------------------------------------------------------------
    //  3. Track — "Check how I am feeling". The mood check-in, in place.
    // -------------------------------------------------------------------------
    //  ⚠️ "Do-it screens, not rails. Must NOT show Feel's content." The tab
    //  is the tool; it holds no sections at all.
    PvDoorGroup(
      id: kMindTabTrack,
      label: 'Track',
      icon: Icons.timeline_rounded,
      hue: 160,
      inlineSurfaceId: kMindSurfaceTrack,
      inlineLabel: 'How are you feeling today?',
      layout: PvDoorLayout.stack,
      note: 'A mood word, never a score. Nothing here is graded and nothing '
          'is shared.',
    ),

    // -------------------------------------------------------------------------
    //  4. When it is more than this — new surface
    // -------------------------------------------------------------------------
    //  ⚠️ THE RED FLAG IS PINNED, AND IT IS THE BRIEF'S OWN COPY. "The honest
    //  safety line, warm, not buried." Above everything on this tab, opening
    //  the crisis path, which is where the numbers and the next step live.
    PvDoorGroup(
      id: kMindTabMore,
      label: 'When it is more than this',
      icon: Icons.favorite_border_rounded,
      hue: 344,
      // ⚠️ THE BRIEF'S 3.4, WHOLE. The flag widget has a title, lines and a
      // footer; the brief's opening sentence is the title's second half and
      // the closing two sentences are the footer, so nothing it wrote is lost
      // to the shape.
      pinnedRedFlag: PvDoorRedFlag(
        title: 'When to reach out the same day — you are not a bad mother, '
            'and you are not alone',
        lines: [
          PvDoorFlagLine('A low feeling has not lifted for two weeks.'),
          PvDoorFlagLine('You cannot sleep even when the baby lets you.'),
          PvDoorFlagLine(
              'Nothing interests you anymore, not even things you loved.'),
          PvDoorFlagLine('You feel detached, like you are watching your own '
              'life from outside.'),
          PvDoorFlagLine(
              'You have any thought of harming yourself or the baby.'),
        ],
        footer: 'None of these mean you have failed. They mean it is time to '
            'let a person help, and there are people right here who do this '
            'every day.',
        surfaceId: kMindSurfaceCrisis,
      ),
    ),

    // -------------------------------------------------------------------------
    //  5. Talk — a real person, plus the paid part
    // -------------------------------------------------------------------------
    PvDoorGroup(
      id: kMindTabTalk,
      label: 'Talk',
      icon: Icons.chat_bubble_outline_rounded,
      hue: 186,
      note: 'The counselling here is the only paid part of Mind & mood. '
          'Everything else is, and stays, free.',
    ),
  ],

  sections: [
    // =========================================================================
    //  FEEL
    // =========================================================================
    PvDoorSection(
      group: kMindTabFeel,
      heading: 'In the moment',
      tiles: [
        // ⚠️ REBUILT: was a coming-soon film; now a three-minute guided
        // screen on the breathing circle, with the brief's copy 3.1.
        PvDoorToolTile(
          title: 'A hard-day reset',
          blurb: 'Three minutes to set the day down. Nothing to fix, '
              'nothing logged.',
          meta: '3 MIN',
          surfaceId: kMindSurfaceReset,
        ),
        PvDoorToolTile(
          title: 'Calm note',
          blurb: '60 seconds, three breaths, grounding.',
          meta: '1 MIN',
          surfaceId: kMindSurfaceCalmNote,
        ),
      ],
    ),

    PvDoorSection(
      group: kMindTabFeel,
      heading: 'Breathe',
      tiles: [
        for (final ex in kMmBreathingExercises)
          PvDoorToolTile(
            title: ex.name.en,
            blurb: ex.description.en,
            surfaceId: mindSurfaceBreathe(ex.id),
          ),
        // "Watch-along versions (coming soon)."
        for (final ex in kMmBreathingExercises)
          PvDoorVideoTile(
            title: '${ex.name.en}, guided',
            blurb: 'A watch-along version of the same breath.',
            meta: '3 MIN',
          ),
      ],
    ),

    PvDoorSection(
      group: kMindTabFeel,
      heading: 'A gentle word',
      tiles: [
        // ⚠️ REBUILT: the whole rotating set is the brief's 3.2, verbatim.
        PvDoorToolTile(
          title: 'Affirmations',
          blurb: 'One at a time, on "Show me one". For you, never about '
              'the baby.',
          surfaceId: kMindSurfaceAffirmations,
        ),
      ],
    ),

    PvDoorSection(
      group: kMindTabFeel,
      heading: 'Calming audio',
      tiles: [
        for (final a in kMmCalmAudio)
          PvDoorAudioTile.comingSoon(
            title: a.title.en,
            blurb: a.subtitle.en,
            meta: a.durationLabel.en,
          ),
      ],
    ),

    PvDoorSection(
      group: kMindTabFeel,
      heading: 'Longer, when there is time',
      tiles: [
        // ⚠️ `hard_day_reset` IS NOT IN THIS RAIL. It is the tool at the top
        // of the tab now; a film of it beside the tool would be two cards for
        // one thing, and the brief rebuilt it as a screen precisely so it
        // would stop being a coming-soon.
        for (final m in kMmMeditations)
          if (m.id != 'hard_day_reset')
            PvDoorVideoTile(
              title: m.title.en,
              blurb: m.subtitle.en,
              meta: m.durationLabel.en,
            ),
      ],
    ),

    // =========================================================================
    //  UNDERSTAND
    // =========================================================================
    PvDoorSection(
      group: kMindTabUnderstand,
      heading: 'Is this normal?',
      tiles: _readsIn(MmArticleGroup.isThisNormal),
    ),

    PvDoorSection(
      group: kMindTabUnderstand,
      heading: 'What no one talks about',
      tiles: _readsIn(MmArticleGroup.noOneTalksAbout),
    ),

    PvDoorSection(
      group: kMindTabUnderstand,
      heading: 'Fears',
      tiles: _fears(),
    ),

    // ⚠️ NOT IN THE BRIEF'S MAP, AND NOT DROPPED — the five everyday-care
    // reads exist and are hers. "Do NOT drop anything."
    PvDoorSection(
      group: kMindTabUnderstand,
      heading: 'Everyday emotional care',
      tiles: _readsIn(MmArticleGroup.everydayCare),
    ),

    // =========================================================================
    //  TRACK — no sections; the tab IS the tool.
    // =========================================================================

    // =========================================================================
    //  WHEN IT IS MORE THAN THIS
    // =========================================================================
    PvDoorSection(
      group: kMindTabMore,
      heading: 'Where you are',
      tiles: [
        // ⚠️ RESLOTTED from Talk, as the brief asks. "Soft questions, no
        // score" — the screener already works that way.
        PvDoorToolTile(
          title: 'A gentle check-in',
          blurb: 'A few soft questions. No score, and nothing is stored.',
          meta: '2 MIN',
          surfaceId: kMindSurfaceCheckIn,
        ),
        PvDoorEntryTile(
          title: 'Baby blues, or something more?',
          blurb: 'Most mothers feel weepy, up and down and a bit raw in the '
              'first days and weeks.',
          meta: '2 MIN',
          library: PvDoorLibrary.mindRead,
          entryId: 'baby_blues_or_more',
        ),
      ],
    ),

    PvDoorSection(
      group: kMindTabMore,
      heading: 'Reaching out',
      tiles: [
        PvDoorTalkTile(
          title: 'Talk to someone today',
          blurb: 'A counsellor trained in pregnancy. Anonymous, at your '
              'pace.',
          surfaceId: 'mind/offer/perinatal_counselling',
        ),
        PvDoorToolTile(
          title: 'Helpline numbers',
          blurb: 'India\'s perinatal and mental-health lines, free, any '
              'hour.',
          surfaceId: kMindSurfaceHelplines,
        ),
        // ⚠️ NO COPY IN THE BRIEF — "How to raise it, with Ask Veda to word
        // it." Listed, not written. See the header.
        PvDoorReadTile.comingSoon(
          title: 'Tell your doctor',
          blurb: 'How to raise it at your next visit, and the words if you '
              'cannot find them.',
          meta: '3 MIN',
        ),
      ],
    ),

    // ⚠️ THE SIX "MORE THAN A MOOD" READS LIVE HERE, NOT ON UNDERSTAND. The
    // brief: perinatal depression pages "live in Sub-tab 4". They were on the
    // old Understand tab; this is where the brief moves them.
    PvDoorSection(
      group: kMindTabMore,
      heading: 'Reading, when you are ready',
      tiles: _readsIn(MmArticleGroup.moreThanMood,
          except: const {'baby_blues_or_more'}),
    ),

    // =========================================================================
    //  TALK
    // =========================================================================
    PvDoorSection(
      group: kMindTabTalk,
      heading: 'Talk to someone',
      tiles: [
        for (final o in kMmTalkOfferings)
          PvDoorTalkTile(
            title: o.title.en,
            blurb: o.whoFor.en,
            // ⚠️ THE PRICE ON THE FACE. This app's rule: a tile that costs
            // money is legible as such before she taps — and `meta` is the
            // field a rail card paints.
            meta: '₹${o.priceInr.toStringAsFixed(0)} ${o.priceUnit.en}',
            surfaceId: mindSurfaceOffer(o.id),
          ),
      ],
    ),

    PvDoorSection(
      group: kMindTabTalk,
      heading: 'If it cannot wait',
      tiles: [
        PvDoorToolTile(
          title: 'Right now, free',
          blurb: 'The crisis path: a person to call, tonight, at no cost.',
          surfaceId: kMindSurfaceCrisis,
        ),
      ],
    ),
  ],
);
