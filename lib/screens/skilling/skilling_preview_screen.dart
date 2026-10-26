// =============================================================================
//  SkillingPreview — the fourth stage's home, as a DESIGN PREVIEW
// -----------------------------------------------------------------------------
//  ⚠️ THIS IS UI ONLY. NOTHING BEHIND IT IS BUILT, AND NOTHING HERE PRETENDS
//  OTHERWISE.
//
//  Asked for explicitly: the look of the skilling stage, without functionality
//  or wiring. So the file is deliberately shaped to make that impossible to
//  forget six weeks from now:
//
//    · It is called a PREVIEW, not a home. `SkillingHomeV3` would have been the
//      symmetrical name and would have been a lie — the other three V3 homes
//      open real screens.
//    · It is reached only behind `kDebugMode`, from the Explore drawer, beside
//      the Brand Studio debug row that set the precedent.
//    · The doors open a SHEET SHOWING THE PLAN, not a bracket screen. A bracket
//      screen with zero live layers renders a header and nothing — twelve doors
//      onto twelve empty rooms, which is worse than no doors. An empty room read
//      as a promise is what makes an app feel abandoned.
//    · The banner at the top says all of that in one line, on screen, where a
//      reviewer sees it rather than where a developer reads it.
//
//  ⚠️ SINCE 2026-09-14 THE BUILT DOORS ARE REAL, AND SINCE 2026-09-22 THEY ARE
//  REAL IN A RELEASE BUILD TOO (the user's call: the whole skilling side
//  ships so a shared APK can be walked). A tile whose bracket has a `SkDoor`
//  opens `SkDoorScreen` (`lib/screens/skilling/doors/`) through
//  `skOpenDoor`, after the parent gate; the rest keep the plan sheet. The
//  two "open questions" below are answered by the Coding v2 brief and the
//  cards now say so. The compass lights a point by practice. Everything
//  else in this header still holds.
//
//  ---------------------------------------------------------------------------
//  ⚠️ WHY THE HERO CANNOT BE THE COMPASS YET
//  ---------------------------------------------------------------------------
//
//  The workbook's L3 spine for this stage is the **child capability profile —
//  "the compass"**: where the child stands across skills, and what to do next.
//  Every other stage's hero shows a position on its spine, so the symmetrical
//  move is to show a position on this one.
//
//  We cannot, and the reason is not that the data is missing — it is that the
//  obvious rendering is banned. "Where the child stands across twelve skills"
//  drawn as filled arcs, a radar chart or a set of bars **is a score for a
//  child**, and this product does not give children scores. The parenting
//  Development area already refused a progress bar for exactly this, and its
//  door mark had to be redrawn from a bar chart to stepping stones.
//
//  So the compass here is drawn UNFILLED: twelve points, evenly spaced, none
//  emphasised. It says "twelve things, and we are not ranking your child in
//  them" — which happens to be both the honest pre-content state AND, I think,
//  the right long-term answer. The alternative that stays honest once data
//  exists is to mark which skills have been PRACTISED recently, never how well.
//
//  That is a product decision and it is flagged, not taken.
//
//  ---------------------------------------------------------------------------
//  ⚠️ SINCE 2026-10-26 IT IS A HOME, IN THE HOUSE LOOK (approved prototype
//  claude.ai/artifact/1wkwCdtNts4X1z9FYi4tek)
//  ---------------------------------------------------------------------------
//
//  The user: skilling did not look like it came from the ParentVeda app. The
//  other three homes share one shape (header, a hero about the person now,
//  then a white sheet: "My daily insights", "Explore by topic", rows), and
//  this one now has it too:
//
//    · The hero is about the child ("Aarav's learning space", his age), on
//      the house teal (186) rather than violet 258.
//    · My daily insights / Today: one card per door that has real
//      activities, from that door's own `todayFor(band)`, so the home and
//      the door agree on today's thing. The onboarding pick leads the rail
//      until the child has tried anything.
//    · Explore by topic: the same grid, hues through `skHouseHue`; the five
//      unbuilt skills say "Soon" and still open their plan sheet.
//    · What he tried lately, and Help him at home (gated by the grown-up
//      screen itself, so a deep link cannot skip the check).
//    · A bottom bar, the shared `PvNavBar`: Today, Learn, Products, Tools,
//      More. The four tab pages say what is coming and point into what
//      already exists inside the doors, so no tab is a dead end.
//
//  The preview banner, the compass and the "Decided" cards are commented out
//  below, kept for revert. The class name stays `SkillingPreviewScreen`: the
//  routes, the observer and five tests read it, and a rename buys nothing.
// =============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../localization/app_language.dart';
import '../../models/bracket.dart';
import '../../services/bracket_resolver.dart';
import '../../services/life_stage_store.dart';
import '../../theme/pv_fonts.dart';
import '../v2/v2_block_grid.dart';
import '../v2/v2_palette.dart';
import '../v2/v3_hero_field.dart';
import '../v2/v3_skill_art.dart';
import '../../data/doors/sk_door_data.dart';
import '../profile/pv_you_screen.dart';
import '../saved_screen.dart';
// Kept for revert: the header chrome before the one header (2026-10-25).
// import '../v2/v3_hero_chrome.dart';
import '../v2/pv_family_switch.dart' show FamilyHome, PvFamilyTitle;
import '../post_pregnancy/pp_surface_router.dart' show ppScreenForSurface;
import 'sk_child_store.dart';
import 'sk_first_activity.dart';
import 'sk_practice_store.dart';
import 'sk_surface_router.dart';
import '../../widgets/pv_home_arrival.dart';
import '../../widgets/pv_nav_bar.dart';
import '../doors/pv_list_row.dart';
import '../v2/pv_insight_rail.dart';
import 'doors/sk_door_chrome.dart' show skHouseHue;
import 'sk_bands.dart';
import 'sk_content_registry.dart';
import 'sk_door_content.dart';

class SkillingPreviewScreen extends StatefulWidget {
  const SkillingPreviewScreen({super.key, this.lang = AppLanguage.english});

  final AppLanguage lang;

  @override
  State<SkillingPreviewScreen> createState() => _SkillingPreviewScreenState();
}

/// The bar's five tabs, in order. Today is the home itself.
const List<PvNavItem> _kSkTabs = [
  PvNavItem(Icons.home_outlined, 'Today'),
  PvNavItem(Icons.menu_book_outlined, 'Learn'),
  PvNavItem(Icons.shopping_basket_outlined, 'Products'),
  PvNavItem(Icons.handyman_outlined, 'Tools'),
  PvNavItem(Icons.grid_view_outlined, 'More'),
];

class _SkillingPreviewScreenState extends State<SkillingPreviewScreen> {
  /// Which tab is lit. A plain index in the screen's own state, not a
  /// store: nothing outside this screen reads it, and a fresh open landing
  /// on Today is the behaviour the other homes have.
  int _tab = 0;

  AppLanguage get lang => widget.lang;

  @override
  Widget build(BuildContext context) => PvHomeArrival(
      child: AnimatedBuilder(
        // What he tried lately and the today rail read the keepsake; the
        // name, age and band read the child store.
        animation: Listenable.merge(
            [SkPracticeStore.instance, SkChildStore.instance]),
        builder: (context, _) => _body(context),
      ));

  Widget _body(BuildContext context) {
    // Lazy, idempotent, fire-and-forget: each store notifies once loaded.
    SkPracticeStore.instance.load();
    SkChildStore.instance.load();
    final p = V2PaletteStore.instance.current;

    return Scaffold(
      backgroundColor: p.ground,
      body: Stack(children: [
        if (_tab == 0)
          ..._home(context, p)
        else
          Positioned.fill(
            child: _SkTabPage(
                key: ValueKey('sk_tab_$_tab'), tab: _tab, p: p, lang: lang),
          ),
        // ⚠️ THE ONE BAR EVERY STAGE USES, floating as the others do. The
        // default accent is the brand violet, which is what pregnancy and
        // TTC pass; skilling has no slate of its own.
        Positioned(
          left: 14,
          right: 14,
          bottom: MediaQuery.viewPaddingOf(context).bottom + 18,
          child: PvNavBar(
            key: const ValueKey('sk_nav_bar'),
            items: _kSkTabs,
            activeIndex: _tab,
            onTap: (i) => setState(() => _tab = i),
          ),
        ),
      ]),
    );
  }

  List<Widget> _home(BuildContext context, V2Palette p) {
    final brackets = bracketsFor(LifeStage.skilling);
    final kid = SkChildStore.instance;
    final who = kid.name.isEmpty ? 'your child' : kid.name;
    final band = kid.band?.id ?? kSkBands.first.id;
    // The doors whose activities are real (task fills), not placeholders.
    // Derived, so a door that gets its fills joins the rail and the
    // grown-up rows without an edit here.
    final real = [
      for (final c in kSkDoorContents)
        if (c.activities.any((a) => !a.comingSoon)) c,
    ];
    final triedAny = [
      for (final c in kSkDoorContents) c.doorId,
    ].any(SkPracticeStore.instance.hasPractised);
    // The old accent, kept for revert: v2BlockTint(258, p), v3FieldChroma(258).
    final accent = v2BlockTint(186, p);

    return [
      // Same structure as parenting and TTC: the field is the PAGE's surface
      // and does not scroll; the content sheet slides over it.
      Positioned.fill(
        child: PvArrive.field(
          child: V3HeroField(
              accent: accent,
              ground: p.ground,
              variant: 3,
              chroma: v3FieldChroma(186)),
        ),
      ),
      ListView(padding: EdgeInsets.zero, children: [
        PvArrive(
            delay: PvArriveAt.header,
            child: _Hero(p: p, count: brackets.length)),
        _Sheet(p: p, children: [
          const SizedBox(height: 26),
          // Kept for revert: the preview banner.
          // _pad(_PreviewBanner(p: p)),
          // const SizedBox(height: 26),

          // ---- MY DAILY INSIGHTS / TODAY ------------------------------------
          _pad(_Head(eyebrow: 'My daily insights', title: 'Today', p: p)),
          const SizedBox(height: 12),
          // The parenting home's clamp: a fixed 100 x 112 tile, and an
          // activity title is longer than most values.
          MediaQuery.withClampedTextScaling(
            maxScaleFactor: 1.3,
            child: KeyedSubtree(
              key: const ValueKey('sk_home_insights'),
              child: PvInsightRail(tiles: [
                // Onboarding V3: what the child enjoys and the time there is
                // pick one thing to start with. It leads until anything has
                // been tried, then the doors' own cards carry the rail.
                if (!triedAny)
                  if (skFirstActivityFromProfile() case final first?)
                    PvInsightTile(
                      key: const ValueKey('sk_first_activity'),
                      eyebrow: 'Picked for $who',
                      value: first.title.split(':').first,
                      caption: first.time,
                      hue: 160,
                      art: PvInsightArt.note,
                      showArt: false,
                      centreValue: true,
                      p: p,
                      onTap: () => _showFirst(context, first, p),
                    ),
                for (final c in real)
                  if (c.todayFor(band) case final a? when !a.comingSoon)
                    PvInsightTile(
                      key: ValueKey('sk_today_${c.doorId}'),
                      eyebrow: bracketById(c.doorId)?.label.now ?? '',
                      value: a.title,
                      caption: c.skillById(a.skillPurpose)?.label,
                      hue: skHouseHue(bracketById(c.doorId)?.hue ?? 186),
                      art: PvInsightArt.note,
                      showArt: false,
                      centreValue: true,
                      p: p,
                      onTap: () => _openGated(
                          context, c.doorId, 'sk_activity/${c.doorId}/${a.id}'),
                    ),
              ]),
            ),
          ),
          const SizedBox(height: 30),

          // ---- EXPLORE BY TOPIC ---------------------------------------------
          // Kept for revert: eyebrow 'Where to go', 'Twelve things worth
          // getting good at'.
          _pad(_Head(eyebrow: '', title: 'Explore by topic', p: p)),
          const SizedBox(height: 14),
          _pad(V2BlockGrid(
            palette: p,
            columns: 4,
            blocks: [
              for (final b in brackets)
                V2Block(
                  label: b.label.of(lang),
                  icon: Icons.circle_outlined,
                  // The house hue, not the bracket's own (violet, purple and
                  // pink move; kSkBracketHouseHues). Kept for revert:
                  // tint: v2BlockTint(b.hue, p),
                  tint: v2BlockTint(skHouseHue(b.hue), p),
                  // A feature is never hidden: an unbuilt skill keeps its
                  // tile and says so under the label.
                  meta: skDoorFor(b.id) == null ? 'Soon' : null,
                  // ⚠️ `skillMark`, a separate slot from `bracketMark`. The
                  // grid takes either; passing a SkillMark through the
                  // bracket slot would have meant one enum with 29 cases and
                  // a switch that no stage reads in full.
                  skillMark: skillMarkFor(b.id),
                  // ⚠️ A BRACKET WITH A DOOR OPENS IT; the rest keep the
                  // plan sheet. `skOpenDoor` is false for a bracket with
                  // no `SkDoor`, and falls through to the sheet — so the
                  // tile never opens nothing.
                  onTap: () {
                    if (!skOpenDoor(context, b.id)) _showPlan(context, b, p);
                  },
                ),
            ],
          )),
          const SizedBox(height: 30),

          // ---- RIGHT NOW / WHAT HE TRIED LATELY -----------------------------
          _pad(_Head(
              eyebrow: 'Right now',
              title: 'What $who tried lately',
              p: p)),
          const SizedBox(height: 10),
          _pad(_TriedLately(p: p)),
          const SizedBox(height: 30),

          // ---- FOR THE GROWN-UP / HELP HIM AT HOME --------------------------
          _pad(_Head(
              eyebrow: 'For the grown-up',
              title: 'Help $who at home',
              p: p)),
          const SizedBox(height: 10),
          _pad(PvRowGroup(p: p, children: [
            for (final c in real)
              PvListRow(
                key: ValueKey('sk_grown_up_${c.doorId}'),
                p: p,
                leading: _SkillWell(bracketId: c.doorId, p: p),
                title: bracketById(c.doorId)?.label.now ?? '',
                line: _kGrownUpLine[c.doorId] ??
                    'Classes, things that help, a note for you',
                // The grown-up screen asks the check itself, so this row
                // cannot skip it; the lock says so before the tap.
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.lock_outline_rounded, size: 14, color: p.ink3),
                  const SizedBox(width: 2),
                  Icon(Icons.chevron_right_rounded, size: 20, color: p.ink3),
                ]),
                onTap: () => skOpenSurface(context, 'sk_grown_up/${c.doorId}'),
              ),
          ])),
          // The old "Decided" card's meaning, as one quiet line.
          _pad(_QuietLine(
              p: p,
              text: 'Nothing here scores a child. What $who does is kept '
                  'in words, on this phone.')),

          // ---- KEPT FOR REVERT: the compass and the two "Decided" cards ----
          // _pad(_Head(eyebrow: 'The spine', title: 'The compass', p: p)),
          // const SizedBox(height: 12),
          // _pad(_CompassCard(p: p, brackets: brackets, lang: lang)),
          // const SizedBox(height: 32),
          // _pad(_Head(eyebrow: 'Decided', title: 'Two things settled first', p: p)),
          // const SizedBox(height: 12),
          // _pad(_QuestionCard(p: p, n: '1',
          //   title: 'The learning screens talk to the child.',
          //   body: 'The parent registers, verifies and consents; the child '
          //       'steps into a space that speaks to her, reads aloud and '
          //       'asks nothing of her data. Settings, courses and anything '
          //       'to do with money stay with the parent, behind a gate.')),
          // const SizedBox(height: 12),
          // _pad(_QuestionCard(p: p, n: '2',
          //   title: 'Nothing here scores a child.',
          //   body: 'No points, streaks, ranking badges, levels, percentages '
          //       'or graded certificates. The keepsake records tried, '
          //       'practised again and made, in words. Challenges become '
          //       'optional fun; the progress report is not built.')),
          // The first-activity card before the rail took it, kept for revert:
          // _pad(_QuestionCard(key: const ValueKey('sk_first_activity'), p: p,
          //   n: '1', title: first.title,
          //   body: '${first.time}. Picked from what you told us they '
          //       'enjoy. The doors below hold the rest.')),

          // Clearance for the floating bar.
          const SizedBox(height: 70),
        ]),
      ]),
    ];
  }

  /// The onboarding pick has no screen of its own (it is a thing to do
  /// together, away from the phone), so its card opens the whole title and
  /// what to do with it. Never a silent tap.
  void _showFirst(BuildContext context, SkFirstActivity first, V2Palette p) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: p.ground,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (_) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Grab(p: p),
                const SizedBox(height: 18),
                Text(first.title,
                    style: pvFraunces(
                        fontSize: 21,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                        letterSpacing: -0.5,
                        color: p.ink1)),
                const SizedBox(height: 8),
                Text(first.time,
                    style: pvManrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: p.ink3)),
                const SizedBox(height: 12),
                Text(
                    'Picked from what you told us they enjoy. It needs no '
                    'screen: do it together, then try a skill below.',
                    style: pvManrope(fontSize: 14, height: 1.5, color: p.ink2)),
              ]),
        ),
      ),
    );
  }

  /// What a door does, in place of opening a bracket screen it cannot fill.
  ///
  /// It shows the workbook's own plan for that bracket, layer by layer. That is
  /// not a feature pretending to be one — it is the preview being useful: a
  /// reviewer can tap a door and see exactly what was intended behind it,
  /// which is the question a design preview exists to answer.
  void _showPlan(BuildContext context, Bracket b, V2Palette p) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: p.ground,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (_) => _PlanSheet(bracket: b, p: p, lang: lang),
    );
  }
}

/// One line per open door under Help him at home: what the grown-up side
/// holds, in plain words. A door missing here gets the generic line.
const Map<String, String> _kGrownUpLine = {
  'skilling_coding': 'Blocks, kits and classes',
  'skilling_communication': 'Story decks, classes, one honest line',
  'skilling_confidence': 'A speaking coach, classes',
};

/// A child screen behind consent. Before consent, the door's own way in
/// (the parent gate, then the door); after it, straight to the surface.
/// The stores are loaded by the home before any card can be tapped.
void _openGated(BuildContext context, String doorId, String surface) {
  if (!SkChildStore.instance.consented) {
    skOpenDoor(context, doorId);
    return;
  }
  skOpenSurface(context, surface);
}

/// The skill's drawn mark in its house tint, 40 across: the lead of every
/// row on the home and the tab pages.
class _SkillWell extends StatelessWidget {
  const _SkillWell({required this.bracketId, required this.p});
  final String bracketId;
  final V2Palette p;

  @override
  Widget build(BuildContext context) {
    final tint = v2BlockTint(skHouseHue(bracketById(bracketId)?.hue ?? 186), p);
    final mark = skillMarkFor(bracketId);
    return Container(
      width: 40,
      height: 40,
      decoration:
          BoxDecoration(color: tint, borderRadius: BorderRadius.circular(12)),
      child: mark == null ? null : V3SkillArt(mark: mark, tint: tint),
    );
  }
}

/// One grey line with an info mark: the empty state's invitation and the
/// home's quiet notes.
class _QuietLine extends StatelessWidget {
  const _QuietLine({super.key, required this.p, required this.text});
  final V2Palette p;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(Icons.info_outline_rounded, size: 15, color: p.ink3),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: pvManrope(fontSize: 13, height: 1.45, color: p.ink3)),
          ),
        ]),
      );
}

/// What the child tried lately, across every door, most recent first. Three
/// at most; the keepsake inside each door holds the rest.
class _TriedLately extends StatelessWidget {
  const _TriedLately({required this.p});
  final V2Palette p;

  @override
  Widget build(BuildContext context) {
    final lines = <(SkDoorContent, SkKeepsakeLine)>[
      for (final c in kSkDoorContents)
        for (final l in SkPracticeStore.instance.entriesFor(c.doorId)) (c, l),
    ]..sort((a, b) => b.$2.lastAt.compareTo(a.$2.lastAt));
    // A feature is never hidden: with nothing tried, the invitation.
    if (lines.isEmpty) {
      return _QuietLine(
          key: const ValueKey('sk_tried_empty'),
          p: p,
          text: 'Nothing yet. Try one thing above and it shows here, in '
              'words, never a score.');
    }
    return PvRowGroup(p: p, children: [
      for (final (c, l) in lines.take(3))
        PvListRow(
          key: ValueKey('sk_tried_${c.doorId}_${l.itemId}'),
          p: p,
          leading: _SkillWell(bracketId: c.doorId, p: p),
          title: l.title,
          line: [
            l.word,
            ?switch (c.activityById(l.itemId)) {
              final a? => c.skillById(a.skillPurpose)?.label,
              null => null,
            },
          ].where((s) => s.isNotEmpty).join(' · '),
          onTap: () => c.activityById(l.itemId) == null
              ? skOpenSurface(context, 'sk_keepsake/${c.doorId}')
              : _openGated(
                  context, c.doorId, 'sk_activity/${c.doorId}/${l.itemId}'),
        ),
    ]);
  }
}

// -----------------------------------------------------------------------------
//  The four tab pages: Learn, Products, Tools, More
// -----------------------------------------------------------------------------

/// One row on a tab page: the door it belongs to, two lines, where it goes.
typedef _SkTabRow = ({
  String door,
  String title,
  String line,
  void Function(BuildContext) open,
});

/// A tab page. Each says what the tab will hold and, until then, points at
/// what already exists inside the doors, so no tab is a dead end. Rows are
/// read from the door data where the data has them (the products are the
/// doors' own shelves); the rest name screens the router already opens.
class _SkTabPage extends StatelessWidget {
  const _SkTabPage(
      {super.key, required this.tab, required this.p, required this.lang});

  final int tab;
  final V2Palette p;
  final AppLanguage lang;

  static const _coding = 'skilling_coding';
  static const _communication = 'skilling_communication';
  static const _confidence = 'skilling_confidence';

  String _label(String door) => bracketById(door)?.label.of(lang) ?? '';

  @override
  Widget build(BuildContext context) {
    final kid = SkChildStore.instance;
    final who = kid.name.isEmpty ? 'your child' : kid.name;
    final band = kid.band?.id ?? kSkBands.first.id;
    final real = [
      for (final c in kSkDoorContents)
        if (c.activities.any((a) => !a.comingSoon)) c.doorId,
    ];

    final (String eyebrow, String title, String line, String? empty,
        String? sub, List<_SkTabRow> rows) = switch (tab) {
      1 => (
          'Learn',
          'Lessons for $who',
          'Short lessons and reads, by age, from every skill. For now they '
              'live inside each skill.',
          'One place for every lesson is coming',
          'Until then, each skill below opens on its lessons.',
          [
            for (final d in real)
              (
                door: d,
                title: _label(d),
                line: 'Lessons inside the door',
                open: (BuildContext c) => _openGated(c, d, 'sk_lessons/$d'),
              ),
          ],
        ),
      2 => (
          'Products',
          'Things that help',
          'Kits, books and games for $who\'s age. Bought by you, behind the '
              'grown-up check; never shown to a child as an ad.',
          'The shop for this stage is coming',
          'Each skill already keeps its own shelf for the grown-up.',
          [
            for (final d in real)
              if (skDoorContentFor(d)?.productsFor(band).firstOrNull
                  case final pr?)
                (
                  door: d,
                  title: pr.title,
                  line: pr.comingSoon
                      ? '${_label(d)} · Coming soon'
                      : _label(d),
                  open: (BuildContext c) =>
                      skOpenSurface(c, 'sk_products/$d'),
                ),
          ],
        ),
      3 => (
          'Tools',
          'Tools for practice',
          'The things $who uses while practising.',
          'More tools are coming',
          'The ones that exist today are inside their skills:',
          [
            (
              door: _confidence,
              title: 'Hear yourself back',
              line: 'Record a turn, play it back',
              open: (BuildContext c) =>
                  _openGated(c, _confidence, 'sk_record/$_confidence'),
            ),
            (
              door: _communication,
              title: 'Your voice, saved',
              line: 'Recordings, on this phone',
              open: (BuildContext c) =>
                  _openGated(c, _communication, 'sk_voice/$_communication'),
            ),
            (
              door: _coding,
              title: 'What I\'ve made and tried',
              line: 'In words, never a score',
              open: (BuildContext c) =>
                  _openGated(c, _coding, 'sk_keepsake/$_coding'),
            ),
          ],
        ),
      _ => (
          'More',
          kid.name.isEmpty ? 'Your child\'s space' : '${kid.name}\'s space',
          'Settings, consent and what is kept on this phone.',
          null,
          null,
          [
            // All three open the grown-up settings, which ask the check
            // themselves (sk_settings in the router).
            (
              door: _coding,
              title: 'Set up and consent',
              line: 'Name, age, what is kept',
              open: (BuildContext c) => skOpenSurface(c, 'sk_settings/$_coding'),
            ),
            (
              door: _confidence,
              title: 'Recording',
              line: 'On or off, and delete clips',
              open: (BuildContext c) => skOpenSurface(c, 'sk_settings/$_coding'),
            ),
            (
              door: _communication,
              title: 'A grown-up PIN',
              line: 'Instead of the sum',
              open: (BuildContext c) => skOpenSurface(c, 'sk_settings/$_coding'),
            ),
          ],
        ),
    };

    return ListView(padding: EdgeInsets.zero, children: [
      SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
          child: _SkHeader(p: p, onField: false),
        ),
      ),
      const SizedBox(height: 22),
      _pad(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(eyebrow.toUpperCase(),
            style: pvManrope(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
                color: p.action)),
        const SizedBox(height: 6),
        Text(title,
            style: pvFraunces(
                fontSize: 27,
                fontWeight: FontWeight.w600,
                height: 1.12,
                letterSpacing: -0.5,
                color: p.ink1)),
        const SizedBox(height: 6),
        Text(line,
            style: pvManrope(fontSize: 14.5, height: 1.4, color: p.ink2)),
      ])),
      if (empty != null)
        _pad(Padding(
          padding: const EdgeInsets.only(top: 22, bottom: 14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: v2BlockTint(186, p), shape: BoxShape.circle),
              child: Icon(Icons.auto_awesome_outlined,
                  size: 20,
                  color: HSLColor.fromAHSL(1, 186, 0.45, 0.34).toColor()),
            ),
            const SizedBox(height: 12),
            Text(empty,
                style: pvFraunces(
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                    color: p.ink1)),
            if (sub != null) ...[
              const SizedBox(height: 6),
              Text(sub,
                  style:
                      pvManrope(fontSize: 13.5, height: 1.45, color: p.ink2)),
            ],
          ]),
        ))
      else
        const SizedBox(height: 18),
      _pad(PvRowGroup(p: p, children: [
        for (final r in rows)
          PvListRow(
            p: p,
            leading: _SkillWell(bracketId: r.door, p: p),
            title: r.title,
            line: r.line,
            onTap: () => r.open(context),
          ),
      ])),
      // Clearance for the floating bar.
      SizedBox(height: pvNavClearance(context, gap: 24)),
    ]);
  }
}

class _Grab extends StatelessWidget {
  const _Grab({required this.p});
  final V2Palette p;

  @override
  Widget build(BuildContext context) => Center(
        child: Container(
          width: 38,
          height: 4,
          decoration: BoxDecoration(
              color: p.line, borderRadius: BorderRadius.circular(2)),
        ),
      );
}

Widget _pad(Widget child) =>
    Padding(padding: const EdgeInsets.symmetric(horizontal: 18), child: child);

// -----------------------------------------------------------------------------

class _Hero extends StatelessWidget {
  const _Hero({required this.p, required this.count});

  final V2Palette p;

  /// How many skills the stage covers, in words in the line under the title.
  final int count;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 288,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ⚠️ ONE HEADER ON EVERY HOME (2026-10-25, the user: "unify the
                // header"). The same three slots as TTC, Pregnancy and
                // Parenting: avatar and Talk on the left, the family switch
                // over the date in the centre, Saved on the right. No Calendar
                // here until the learning space has one (decided 2026-10-25).
                // Since 2026-10-26 it is `_SkHeader`, so the tab pages wear the
                // same header; the slots are unchanged (semantic: 'Profile',
                // 'Talk to an expert', 'Saved' — family_switch_test reads them
                // between `class _Hero` and `class _SkRound`).
                // Kept for revert, Saved and the avatar on the right in the
                // photo-hero chrome:
                // Align(
                //   alignment: Alignment.centerRight,
                //   child: AnimatedBuilder(
                //     animation: SkChildStore.instance,
                //     builder: (context, _) => V3HeroChrome(
                //       tone: V3HeroTone.onField,
                //       p: p,
                //       initial: SkChildStore.instance.name.isEmpty
                //           ? ''
                //           : SkChildStore.instance.name[0],
                //       onSaved: () =>
                //           Navigator.of(context).push(MaterialPageRoute<void>(
                //               settings: const RouteSettings(name: 'saved'),
                //               builder: (_) => const SavedScreen(stage: 'skilling'))),
                //       onProfile: () =>
                //           openPvYou(context, stage: LifeStage.skilling),
                //       avatarOpensProfile: true,
                //     ),
                //   ),
                // ),
                _SkHeader(p: p, onField: true),
                const Spacer(),
                // ⚠️ ABOUT THE CHILD NOW, as the other three heroes are
                // (2026-10-26). Her name and her age are facts she gave us, not
                // measurements; "nothing scored" keeps the old hero's promise in
                // three words. Without a name or a date of birth the line
                // falls back to the stage, never to a guess.
                AnimatedBuilder(
                  animation: SkChildStore.instance,
                  builder: (context, _) {
                    final kid = SkChildStore.instance;
                    final skills = '${_words[count.clamp(0, 12)]} skills to '
                        'practise, nothing scored';
                    return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              kid.name.isEmpty
                                  ? 'The learning space'
                                  : '${kid.name}\'s learning space',
                              key: const ValueKey('sk_hero_title'),
                              style: pvFraunces(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w600,
                                  height: 1.12,
                                  letterSpacing: -0.5,
                                  color: p.ink1)),
                          const SizedBox(height: 6),
                          // ink2 on the tinted field, as everywhere else — a
                          // grey calibrated for a neutral ground loses
                          // contrast on a chromatic one faster than it loses
                          // lightness.
                          Text(
                              kid.ageYears == null
                                  ? _cap(skills)
                                  : 'Age ${kid.ageYears} · $skills',
                              style: pvManrope(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w500,
                                  height: 1.4,
                                  color: p.ink2)),
                        ]);
                  },
                ),
                // Kept for revert: the design-preview hero.
                // Text('SKILLING  ·  DESIGN PREVIEW',
                //     style: pvManrope(
                //         fontSize: 11,
                //         fontWeight: FontWeight.w800,
                //         letterSpacing: 1.5,
                //         color: p.ink2)),
                // const SizedBox(height: 10),
                // // ⚠️ THE BIG FACT IS A COUNT, NOT A MEASUREMENT. Every other
                // // stage's hero carries a number about the child — a week, an
                // // age, a cycle day. The only honest number here is how many
                // // skills the stage covers, because nothing about any child has
                // // been recorded and the alternative big numbers are all scores.
                // PvArriveCount(
                //     text: '$count skills',
                //     builder: (s) => Text(s,
                //         style: pvFraunces(
                //             fontSize: 42,
                //             fontWeight: FontWeight.w600,
                //             height: 1.05,
                //             letterSpacing: -1.3,
                //             color: p.ink1))),
                // const SizedBox(height: 3),
                // Text('Nothing measured. Nothing ranked.',
                //     style: pvManrope(
                //         fontSize: 13.5,
                //         fontWeight: FontWeight.w700,
                //         letterSpacing: 0.3,
                //         color: p.ink2)),
                // const SizedBox(height: 12),
                // Text(
                //     'Twelve things a child can get better at, and a place to '
                //     'practise each one.',
                //     style: pvManrope(
                //         fontSize: 13.5, height: 1.45, color: p.ink2)),
              ],
            ),
          ),
        ),
      );
}

/// The one header: avatar and Talk on the left, the family switch over the
/// date in the centre, Saved on the right. On the hero field and on the tab
/// pages; [onField] picks the round buttons' fill (white on the tint, the
/// plain grey on the white tab pages).
class _SkHeader extends StatelessWidget {
  const _SkHeader({required this.p, required this.onField});
  final V2Palette p;
  final bool onField;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: SkChildStore.instance,
        builder: (context, _) {
          const side = 84.0; // 38 + 8 + 38, as on the other homes
          final name = SkChildStore.instance.name;
          final today = DateTime.now();
          final date = '${today.day} ${_kSkMonths[today.month - 1]}';
          final fill = onField ? null : p.surfaceAlt;
          return Row(children: [
            SizedBox(
              width: side,
              child: Row(children: [
                // The avatar is the one door to You (2026-09-19, B10).
                _SkRound(
                  p: p,
                  fill: fill,
                  semantic: 'Profile',
                  onTap: () => openPvYou(context, stage: LifeStage.skilling),
                  child: name.isEmpty
                      ? Icon(Icons.person_outline_rounded, size: 18, color: p.ink2)
                      : Text(name[0].toUpperCase(),
                          style: pvJakarta(fontSize: 14, fontWeight: FontWeight.w700, color: p.ink1)),
                ),
                const SizedBox(width: 8),
                _SkRound(
                  p: p,
                  fill: fill,
                  semantic: 'Talk to an expert',
                  onTap: () {
                    final screen = ppScreenForSurface('pp_experts');
                    if (screen == null) return;
                    Navigator.of(context).push(MaterialPageRoute<void>(
                        settings: const RouteSettings(name: 'pp_experts'),
                        builder: (_) => screen));
                  },
                  child: Icon(Icons.forum_outlined, size: 17, color: p.ink2),
                ),
              ]),
            ),
            Expanded(
              child: Center(
                child: PvFamilyTitle(
                  p: p,
                  here: FamilyHome.learning,
                  dateText: date,
                  date: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(date,
                        style: pvManrope(
                            fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 0.1, color: p.ink1)),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: side,
              child: Align(
                alignment: Alignment.centerRight,
                child: _SkRound(
                  p: p,
                  fill: fill,
                  semantic: 'Saved',
                  onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                      settings: const RouteSettings(name: 'saved'),
                      builder: (_) => const SavedScreen(stage: 'skilling'))),
                  child: Icon(Icons.bookmark_border_rounded, size: 18, color: p.ink2),
                ),
              ),
            ),
          ]);
        },
      );
}

const _kSkMonths = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

/// The header's round button, the other homes' shape (white at 0.62 on the
/// field, 38 across). [fill] overrides the white on a page with no field.
class _SkRound extends StatelessWidget {
  const _SkRound({required this.p, required this.child, required this.onTap, required this.semantic, this.fill});
  final V2Palette p;
  final Widget child;
  final VoidCallback onTap;
  final String semantic;
  final Color? fill;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: semantic,
        child: Material(
          color: fill ?? Colors.white.withValues(alpha: 0.62),
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: SizedBox(width: 38, height: 38, child: Center(child: child)),
          ),
        ),
      );
}

class _Sheet extends StatelessWidget {
  const _Sheet({required this.p, required this.children});

  final V2Palette p;
  final List<Widget> children;

  // The first home rises and its sections follow (pv_home_arrival.dart,
  // 2026-10-18); every other open is exactly as before.
  @override
  Widget build(BuildContext context) => PvArrive.sheet(child: Container(
        // The sheet owns the bottom clearance. Once the background belongs to
        // the page, every piece of scroll-view padding is a window onto it.
        constraints: BoxConstraints(
            minHeight: MediaQuery.sizeOf(context).height * 0.72),
        decoration: BoxDecoration(
          color: p.ground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 24,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ...pvArriveEach(children),
          const SizedBox(height: 60),
        ]),
      ));
}

/// The line that stops this screen being mistaken for a shipped stage.
///
/// On screen rather than in a comment, deliberately. A preview that looks
/// finished gets reported as finished — and the whole reason skilling has no
/// doors into real screens is that looking finished is exactly the failure.
///
/// Off the home since 2026-10-26 (the house look); kept for revert.
// ignore: unused_element
class _PreviewBanner extends StatelessWidget {
  const _PreviewBanner({required this.p});

  final V2Palette p;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: p.surfaceAlt,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.info_outline_rounded, size: 17, color: p.ink2),
          const SizedBox(width: 9),
          Expanded(
            // Counted from `kSkDoors`, not written: the line said "Coding"
            // for two doors too long (seen on the phone, 2026-09-17).
            child: Text(
                '${_cap(_words[kSkDoors.length])} of the twelve are open to '
                'walk through, most of them still filling up. The other '
                '${_words[12 - kSkDoors.length]} show what is planned '
                'behind them.',
                style:
                    pvManrope(fontSize: 12.5, height: 1.45, color: p.ink2)),
          ),
        ]),
      );
}

class _Head extends StatelessWidget {
  const _Head({required this.eyebrow, required this.title, required this.p});

  final String eyebrow;
  final String title;
  final V2Palette p;

  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ⚠️ `p.action`, NOT `p.ink3` — the section eyebrow is PURPLE on every
        // other V3 screen, and this copy of `_Head` shipped grey.
        //
        // The mechanism is worth naming because it will happen again: the
        // shape was copied from pregnancy and parenting by hand, and one
        // colour token drifted in the copying. Nothing failed — grey is a
        // legal colour, the layout is identical, and no test looks at a
        // Color. It is only visible by putting the three screens side by side,
        // which is exactly what a copied widget makes nobody do.
        //
        // The real fix is a shared `_Head`; it is not shared today because the
        // three take different label types. Until then this comment is the
        // guard.
        //
        // Since 2026-10-26 it is the parenting home's `_Head` by value: an
        // empty eyebrow draws nothing ("Explore by topic" has none), the
        // title is 21 (was 22, height 1.2, gap 5).
        if (eyebrow.isNotEmpty) ...[
          Text(eyebrow.toUpperCase(),
              style: pvManrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                  color: p.action)),
          const SizedBox(height: 6),
        ],
        Text(title,
            style: pvFraunces(
                fontSize: 21,
                fontWeight: FontWeight.w600,
                height: 1.15,
                letterSpacing: -0.5,
                color: p.ink1)),
      ]);
}

/// The compass, drawn UNFILLED.
///
/// See the file header. Twelve points evenly spaced, each in its bracket's own
/// hue, none emphasised and none connected into a filled polygon — because a
/// filled polygon across a child's abilities is a radar chart, and a radar chart
/// is a score with better manners.
///
/// Off the home since 2026-10-26 (the house look); kept for revert.
// ignore: unused_element
class _CompassCard extends StatelessWidget {
  const _CompassCard(
      {required this.p, required this.brackets, required this.lang});

  final V2Palette p;
  final List<Bracket> brackets;
  final AppLanguage lang;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: p.line),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(
            child: SizedBox(
              width: 168,
              height: 168,
              child: CustomPaint(
                painter: _CompassPainter(
                  hues: [for (final b in brackets) b.hue],
                  // ⚠️ LIT BY PRACTICE, NEVER BY ABILITY. The brief's
                  // "compass as practice": a point lights when that skill
                  // has been practised at all — a bool from the keepsake,
                  // not a count, not a level.
                  lit: [
                    for (final b in brackets)
                      SkPracticeStore.instance.hasPractised(b.id)
                  ],
                  ring: p.line,
                  ink: p.ink3,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
              'The workbook puts a "child capability profile" at the centre of '
              'this stage — where the child stands, and what to practise next.',
              style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink2)),
          const SizedBox(height: 8),
          Text(
              'Drawn empty on purpose. Filling these arcs by ability would be a '
              'score, and this app does not score children. A point lights when '
              'that skill has been practised at all — never how well, never how '
              'much.',
              style: pvManrope(fontSize: 13, height: 1.5, color: p.ink3)),
        ]),
      );
}

class _CompassPainter extends CustomPainter {
  _CompassPainter(
      {required this.hues,
      required this.ring,
      required this.ink,
      this.lit = const []});

  final List<double> hues;

  /// Per point: practised at all. A lit point is drawn as a ring around
  /// the dot — the same size dot, so twelve lit points look like twelve
  /// unlit ones with rings, and nothing reads as bigger than anything.
  final List<bool> lit;
  final Color ring;
  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = math.min(size.width, size.height) / 2 - 14;

    // Two faint rings. NOT gradations — there is no scale here, and rings that
    // look like a scale invite someone to plot on them.
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = ring;
    canvas.drawCircle(c, r, ringPaint);
    canvas.drawCircle(c, r * 0.55, ringPaint);

    for (var i = 0; i < hues.length; i++) {
      final ang = -math.pi / 2 + (i / hues.length) * math.pi * 2;
      final at = c + Offset(math.cos(ang), math.sin(ang)) * r;
      // A spoke to each point, hairline, so the twelve read as one object
      // rather than as scattered dots.
      canvas.drawLine(
          c + Offset(math.cos(ang), math.sin(ang)) * (r * 0.55), at, ringPaint);
      final colour = HSLColor.fromAHSL(1, hues[i], 0.44, 0.62).toColor();
      canvas.drawCircle(at, 6, Paint()..color = colour);
      if (i < lit.length && lit[i]) {
        canvas.drawCircle(
            at,
            10,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.5
              ..color = colour);
      }
    }
    // The centre: one small dot, the child. Not a score, not a total.
    canvas.drawCircle(c, 4, Paint()..color = ink);
  }

  @override
  bool shouldRepaint(_CompassPainter old) =>
      old.hues != hues || old.lit.join() != lit.join();
}

// Off the home since 2026-10-26 (the house look); kept for revert.
// ignore: unused_element
class _QuestionCard extends StatelessWidget {
  const _QuestionCard(
      // ignore: unused_element_parameter
      {super.key,
      required this.p,
      required this.n,
      required this.title,
      required this.body});

  final V2Palette p;
  final String n;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: p.line),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: p.surfaceAlt, shape: BoxShape.circle),
            child: Text(n,
                style: pvManrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: p.ink2)),
          ),
          const SizedBox(width: 11),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: pvFraunces(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                      letterSpacing: -0.3,
                      color: p.ink1)),
              const SizedBox(height: 5),
              Text(body,
                  style:
                      pvManrope(fontSize: 13, height: 1.5, color: p.ink2)),
            ]),
          ),
        ]),
      );
}

/// What a door opens: the workbook's plan for that bracket, in its own words.
class _PlanSheet extends StatelessWidget {
  const _PlanSheet(
      {required this.bracket, required this.p, required this.lang});

  final Bracket bracket;
  final V2Palette p;
  final AppLanguage lang;

  static const _order = [
    (BracketLayer.content, 'What this would hold'),
    (BracketLayer.activities, 'What they would do'),
    (BracketLayer.tools, 'What could be tracked'),
    (BracketLayer.extras, 'Beyond the six'),
    (BracketLayer.products, 'Things that help'),
    (BracketLayer.course, 'Learn it properly'),
    (BracketLayer.consult, 'Talk to an expert'), // was 'Talk to someone' (2026-10-23)
  ];

  @override
  Widget build(BuildContext context) {
    // The house hue (kSkBracketHouseHues), as on the tile that opened it.
    final tint = v2BlockTint(skHouseHue(bracket.hue), p);
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _Grab(p: p),
          const SizedBox(height: 18),
          Row(children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                  color: tint, borderRadius: BorderRadius.circular(16)),
              child: switch (skillMarkFor(bracket.id)) {
                final SkillMark m => V3SkillArt(mark: m, tint: tint),
                null => const SizedBox.shrink(),
              },
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(bracket.title.of(lang),
                        style: pvFraunces(
                            fontSize: 21,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                            letterSpacing: -0.5,
                            color: p.ink1)),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: p.surfaceAlt,
                          borderRadius: BorderRadius.circular(999)),
                      child: Text('COMING SOON',
                          style: pvManrope(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.7,
                              color: p.ink2)),
                    ),
                  ]),
            ),
          ]),
          const SizedBox(height: 14),
          Text(bracket.blurb.of(lang),
              style: pvManrope(fontSize: 14.5, height: 1.5, color: p.ink1)),
          const SizedBox(height: 20),
          Text('What it will hold',
              style: pvFraunces(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                  letterSpacing: -0.4,
                  color: p.ink1)),
          const SizedBox(height: 6),
          // Hairline rows, as the house lists are; not tappable, so no
          // chevron. The workbook's own words, verbatim — the one place the
          // raw `reason` string is shown, because the audience is whoever is
          // deciding what to build.
          Divider(height: 1, thickness: 1, color: p.line),
          for (final (layer, heading) in _order) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(heading,
                        style: pvManrope(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                            color: p.ink1)),
                    const SizedBox(height: 3),
                    Text(bracket.layer(layer).reason,
                        style: pvManrope(
                            fontSize: 12.5, height: 1.4, color: p.ink3)),
                  ]),
            ),
            Divider(height: 1, thickness: 1, color: p.line),
          ],
          _QuietLine(
              p: p,
              text: 'Not built yet. The tile stays so you can see what is '
                  'coming.'),
        ]),
      ),
    );
  }

  // Kept for revert: the plan sheet before the house look (2026-10-26).
  //   @override
  //   Widget build(BuildContext context) {
  //     final tint = v2BlockTint(bracket.hue, p);
  //     return SafeArea(
  //       top: false,
  //       child: SingleChildScrollView(
  //         padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
  //         child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
  //           Center(
  //             child: Container(
  //               width: 38,
  //               height: 4,
  //               decoration: BoxDecoration(
  //                   color: p.line, borderRadius: BorderRadius.circular(2)),
  //             ),
  //           ),
  //           const SizedBox(height: 18),
  //           Row(children: [
  //             Container(
  //               width: 52,
  //               height: 52,
  //               decoration: BoxDecoration(
  //                   color: tint, borderRadius: BorderRadius.circular(16)),
  //               child: switch (skillMarkFor(bracket.id)) {
  //                 final SkillMark m => V3SkillArt(mark: m, tint: tint),
  //                 null => const SizedBox.shrink(),
  //               },
  //             ),
  //             const SizedBox(width: 13),
  //             Expanded(
  //               child: Text(bracket.title.of(lang),
  //                   style: pvFraunces(
  //                       fontSize: 21,
  //                       fontWeight: FontWeight.w600,
  //                       height: 1.2,
  //                       letterSpacing: -0.5,
  //                       color: p.ink1)),
  //             ),
  //           ]),
  //           const SizedBox(height: 12),
  //           Text(bracket.blurb.of(lang),
  //               style: pvManrope(fontSize: 14, height: 1.5, color: p.ink2)),
  //           const SizedBox(height: 20),
  //           Container(height: 1, color: p.line),
  //           const SizedBox(height: 16),
  //           Text('PLANNED  ·  NONE OF IT BUILT',
  //               style: pvManrope(
  //                   fontSize: 10.5,
  //                   fontWeight: FontWeight.w800,
  //                   letterSpacing: 1.3,
  //                   color: p.ink3)),
  //           const SizedBox(height: 14),
  //           for (final (layer, heading) in _order) ...[
  //             Text(heading,
  //                 style: pvManrope(
  //                     fontSize: 12,
  //                     fontWeight: FontWeight.w800,
  //                     letterSpacing: 0.4,
  //                     color: p.ink2)),
  //             const SizedBox(height: 3),
  //             // The workbook's own words, verbatim — this is the one place in the
  //             // app where the raw `reason` string is shown to a human, and it is
  //             // correct here precisely because the audience is whoever is deciding
  //             // what to build.
  //             Text(bracket.layer(layer).reason,
  //                 style: pvManrope(fontSize: 13.5, height: 1.45, color: p.ink1)),
  //             const SizedBox(height: 14),
  //           ],
  //         ]),
  //       ),
  //     );
  //   }
  // }
}

/// One to twelve, in words — the preview counts its open doors in prose.
const List<String> _words = [
  'none', 'one', 'two', 'three', 'four', 'five', 'six',
  'seven', 'eight', 'nine', 'ten', 'eleven', 'twelve',
];

String _cap(String w) => w[0].toUpperCase() + w.substring(1);
