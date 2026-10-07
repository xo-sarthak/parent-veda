// =============================================================================
//  Parenting · the More tab, in the one ParentVeda format (2026-10-07)
// -----------------------------------------------------------------------------
//  The user: the More section "is also different". Pregnancy's and TTC's More
//  is a full tab screen: TtcTabRootHeader, then headed sections of rounded row
//  cards (PregSectionHeading, PregRowCard, PregOfferRow) with the TTC family's
//  drawn marks. Parenting's was a modal sheet of Material-icon rows. This is
//  pregnancy's More (`lib/screens/pregnancy/preg_more_screen.dart`) for a
//  parent, in pregnancy's order: Talk to an expert, Courses and masterclasses,
//  Groups, Read and watch, Your child's journey, then everything else the old
//  sheet reached, so every Explore row still has an entrance (the old sheet's
//  test holds that). The sheet is kept for revert in pp_more_sheet.dart.
//
//  Community is not here: out of parenting for now (the user, 2026-10-07).
//  A placeholder programme says Opening soon and opens the honest page
//  (pvOpenOffering), never a sales page.
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/learn/pv_learn_view.dart';
import '../../services/life_stage_store.dart';
import '../../widgets/global_ask_fab.dart' show kAskFabReserve;
import '../../widgets/pv_feedback.dart';
import '../brackets/hub/hub_intent_art.dart' show IntentMark;
import '../doors/pv_list_row.dart' show PvMarkWell;
import '../learn/pv_learn_catalog.dart';
import '../learn/pv_offering_screen.dart' show pvOpenOffering;
import '../memories/memories_home_screen.dart';
import '../pregnancy/preg_chrome.dart';
import '../products/pv_store_chrome.dart' show pvStorePalette;
import '../ttc/doors/ttc_tab_art.dart' show TtcTabMark;
import '../ttc/ttc_more_marks.dart';
import '../ttc/ttc_tab_root_header.dart' show TtcTabRootHeader, kTtcTabRootGutter, ttcTabRootIntroStyle;
import '../v2/v2_palette.dart';
import 'journal_v2/pp_journal_screen.dart';
import 'pp_common.dart' show PpBottomNav, PpTab;
import 'pp_expert_honesty.dart' show ppProgramIsPlaceholder;
import 'pp_messages_screen.dart' show openPpMessages;
import 'pp_more_sheet.dart' show ppMoreSheetEntries;
import 'problem_solver_screen.dart';
import 'reading_home_screen.dart';
// import 'recipes_explore_screen.dart'; // kept for revert
import 'watch_home_screen.dart';
import '../../services/pp_messages_store.dart';
import 'pp_recipes_screen.dart';

/// Rows this screen draws by name; the rest of the old sheet goes under
/// "Everything else".
// "My Journal V2" opened the old demo journal and "Read" a second reads
// library; the named Journal and All reads rows above are the real ones
// (2026-10-07), so both are folded into them rather than listed twice.
const Set<String> _kNamedHere = {
  'Watch', 'Learn', 'Recipes', 'Memories', 'Find help', 'You', 'My Journal V2', 'Read',
};

/// ⚠️ MOVED TO THE PARENTING PROFILE (2026-10-07, the user: "Under More >
/// Everything else ... a lot of it can go inside the Profile section"). These
/// rows tune the family's own account rather than offer something, so they
/// live under "Your family's setup" on the profile (pv_you_content.dart,
/// `setupThings`), and My Bookings is the profile's "Your bookings" tile.
/// Listed by the drawer's titles so nothing shows twice. Kept for revert: an
/// empty set lists them under Everything else again.
const Set<String> kPpMovedToProfile = {
  'Personalize ParentVeda experience',
  'Your Care Circle',
  'Invite a friend',
  'Investments & Savings',
  'Astrology & Numerology',
  'My Bookings',
};

class PpMoreScreen extends StatefulWidget {
  const PpMoreScreen({super.key});

  @override
  State<PpMoreScreen> createState() => _PpMoreScreenState();
}

class _PpMoreScreenState extends State<PpMoreScreen> {
  static List<PvOfferingView> _of(Set<PvLearnKind> kinds) {
    try {
      return PvLearnCatalog.instance
          .all(stage: LifeStage.parenting)
          .where((v) => kinds.contains(v.kind))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  late final List<PvOfferingView> _consults = _of({PvLearnKind.consult});
  late final List<PvOfferingView> _courses =
      _of({PvLearnKind.course, PvLearnKind.masterclass, PvLearnKind.classPack});
  late final List<PvOfferingView> _groups = _of({PvLearnKind.cohort});

  void _push(String route, Widget Function() b) {
    pvCommitFeedback();
    Navigator.of(context).push(MaterialPageRoute<void>(settings: RouteSettings(name: route), builder: (_) => b()));
  }

  static TtcArtBuilder _artOfKind(PvLearnKind k) => switch (k) {
        PvLearnKind.consult => ttcArtTool('expert'),
        PvLearnKind.course => ttcArtTool('courses'),
        PvLearnKind.masterclass => ttcArtTab(TtcTabMark.openBook),
        PvLearnKind.cohort => ttcArtTab(TtcTabMark.twoFigures),
        PvLearnKind.classPack => ttcArtTab(TtcTabMark.lotus),
      };

  static IntentMark _markOf(PvLearnKind k) => switch (k) {
        PvLearnKind.consult => IntentMark.askDoctor,
        PvLearnKind.course => IntentMark.schoolMark,
        PvLearnKind.masterclass => IntentMark.lampMark,
        PvLearnKind.cohort => IntentMark.seatMark,
        PvLearnKind.classPack => IntentMark.lotusMark,
      };

  Widget _offeringRow(PvOfferingView v, double hue) {
    final soon = ppProgramIsPlaceholder(v.id);
    final who = [v.expert.name, v.expert.role].where((s) => s.isNotEmpty).join(' · ');
    final free = !soon && v.priceMinor == 0;
    return PregOfferRow(
      key: ValueKey('pp_more_offer_${v.id}'),
      mark: _markOf(v.kind),
      leading: _artOfKind(v.kind)(v2BlockTint(hue % 360, pvStorePalette)),
      hue: hue,
      title: v.title,
      line: who.isEmpty ? v.subtitle : who,
      price: soon || free ? null : v.priceLabel,
      tag: soon
          ? PregOfferTagKind.openingSoon
          : free
              ? PregOfferTagKind.free
              : null,
      onTap: () {
        pvCommitFeedback();
        pvOpenOffering(context, v);
      },
    );
  }

  Widget _section(String id, String title, List<Widget> rows, {String? lead, String? empty}) => Padding(
        key: ValueKey('pp_more_$id'),
        padding: const EdgeInsets.fromLTRB(kTtcTabRootGutter, 26, kTtcTabRootGutter, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          PregSectionHeading(title, lead: lead),
          const SizedBox(height: 12),
          PregRowCard(empty: empty, children: rows),
        ]),
      );

  PregOfferRow _row(String id, IntentMark mark, double hue, String title, String line, VoidCallback onTap,
          {TtcArtBuilder? art, int? badge}) =>
      PregOfferRow(
        key: ValueKey(id),
        mark: mark,
        leading: art?.call(v2BlockTint(hue % 360, pvStorePalette)),
        hue: hue,
        title: title,
        line: line,
        onTap: onTap,
        badge: badge,
      );

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    // Kept for revert (2026-10-07):
    //   final rest = [for (final e in ppMoreSheetEntries()) if (!_kNamedHere.contains(e.title)) e];
    final rest = [
      for (final e in ppMoreSheetEntries())
        if (!_kNamedHere.contains(e.title) && !kPpMovedToProfile.contains(e.title)) e
    ];
    return ListenableBuilder(
      listenable: PpMessagesStore.instance,
      builder: (context, _) => Scaffold(
        backgroundColor: p.ground,
        body: Stack(children: [
          ListView(
            key: const ValueKey('pp_more_tab'),
            padding: const EdgeInsets.fromLTRB(0, 0, 0, kAskFabReserve + 90),
            children: [
              TtcTabRootHeader(
                title: 'More',
                // Kept for revert (2026-10-07): '... What you have booked or
                // ordered is on your profile.'
                intro: Text(
                    'Experts, courses and groups you can book, and your child\'s journey. What you have '
                    'booked or ordered, and your family\'s setup, are on your profile.',
                    style: ttcTabRootIntroStyle()),
              ),
              _section('experts', 'Talk to an expert', [for (final v in _consults.take(6)) _offeringRow(v, 176)],
                  lead: 'Private video calls with a specialist',
                  empty: 'No experts listed yet. New ones are added as they join.'),
              _section('courses', 'Courses and masterclasses', [for (final v in _courses.take(6)) _offeringRow(v, 240)],
                  lead: 'Learn at your own pace, or live with an expert',
                  empty: 'Nothing open yet. New courses are added here as they open.'),
              _section('groups', 'Groups', [for (final v in _groups.take(6)) _offeringRow(v, 160)],
                  lead: 'A few weeks of live calls in a small group',
                  empty: 'Nothing scheduled yet. Groups appear here when a date is set.'),
              _section('read_watch', 'Read and watch', [
                _row('pp_more_reads', IntentMark.pageMark, 212, 'All reads', 'Every read, by topic and by age',
                    () => _push('pp/read', () => const ReadingHomeScreen()), art: ttcArtTab(TtcTabMark.openBook)),
                _row('pp_more_films', IntentMark.listMark, 345, 'All films', 'Short films for each phase',
                    () => _push('pp/watch', () => const WatchHomeScreen()), art: ttcArtMore(TtcMoreMark.film)),
              ], lead: 'Every read and every film, in one list each'),
              _section('journey', 'Your child\'s journey', [
                _row('pp_more_messages', IntentMark.nextStep, 268, 'Messages',
                    'Each new week and month, and the vaccines coming up', () {
                  pvCommitFeedback();
                  openPpMessages(context);
                }, art: ttcArtTab(TtcTabMark.twoBubbles), badge: PpMessagesStore.instance.unreadCount),
                _row('pp_more_journal', IntentMark.bookMark, 300, 'Journal', 'The moments you keep, with photos',
                    () => _push('pp/journal', () => const PpJournalScreen()), art: ttcArtMore(TtcMoreMark.bookmark)),
                _row('pp_more_memories', IntentMark.cuppedHands, 24, 'Memories', 'Everything you have saved so far',
                    () => _push('pp/memories', () => const MemoriesHomeScreen()), art: ttcArtTab(TtcTabMark.sprout)),
                _row('pp_more_recipes', IntentMark.cookMark, 96, 'Recipes', 'Indian home cooking for each age',
                    () => _push('pp/recipes', () => const PpRecipesScreen()), art: ttcArtTab(TtcTabMark.bowl)),
                _row('pp_more_find_help', IntentMark.askDoctor, 176, 'Find help',
                    'Lactation, paediatrics and night help near you',
                    () => _push('pp/find_help', () => const ProblemSolverScreen()), art: ttcArtTab(TtcTabMark.doctorChat)),
              ]),
              if (rest.isNotEmpty)
                _section('rest', 'Everything else', [
                  for (final e in rest)
                    PregOfferRow(
                      key: ValueKey('pp_more_rest_${e.title}'),
                      mark: IntentMark.listMark,
                      leading: PvMarkWell(p: p, hue: 268, size: 40, icon: e.icon),
                      hue: 268,
                      title: e.title,
                      line: e.desc,
                      onTap: () => _push('pp/more/${e.title}', () => e.screen),
                    ),
                ]),
            ],
          ),
          const Positioned(left: 16, right: 16, bottom: 18, child: PpBottomNav(active: PpTab.more)),
        ]),
      ),
    );
  }
}
