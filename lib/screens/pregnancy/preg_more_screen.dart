// =============================================================================
//  Pregnancy — the More tab: everything that is not in the bar
// -----------------------------------------------------------------------------
//  Built 2026-09-29 for the structure pass. The pregnancy bar is now
//  Today · Learn · Products · Tools · More, the trying-to-conceive bar, and
//  More is where the two tabs it replaced went (the user: "remove Community,
//  add More; replace Calendar with Learn").
//
//  ⚠️ THE TTC MORE SCREEN'S HEADINGS, IN ITS ORDER (the user's screenshot):
//
//    Talk to an expert         private video calls, "See all consults"
//    Courses and masterclasses at your own pace, or live
//    Groups                    a few weeks of live calls in a small group
//    Read and watch            every read (the Learn tab) and every film
//    Your journey              Calendar (its tab moved here), the journey map,
//                              the week by week
//    Benefits                  employer benefits, invite a friend
//    All programmes and sessions   the whole of Prepare, unfiltered
//
//  ⚠️ EVERY ROW THE OLD BAR REACHED HAS A HOME, AND THAT IS THE TEST. The
//  TTC More file says it best: a tab that REPLACES another leaves whatever it
//  displaced with no entrance anywhere. Calendar is here. Community is not,
//  on purpose: the gap analysis holds it back until it is real ("Hold the
//  community back", P1), with every entry point commented out, kept for
//  revert. `test/preg_learn_more_test.dart` holds both.
//
//  ⚠️ A SECTION WITH NOTHING IN IT STILL DRAWS. An empty Groups says nothing
//  is scheduled yet and points to Prepare; it does not vanish (CLAUDE.md, "a
//  feature is never hidden").
//
//  Mobbin: American Airlines' More tab, a large title and grouped rounded
//  cards under headings
//  (https://mobbin.com/screens/71e3fc57-af3c-446a-863e-a76f4088e03a); the rows
//  are the You screen's own (`PvYouSection`, `PvYouRow`), so More, You and
//  Settings read as one set, as they do in trying to conceive.
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/learn/pv_learn_view.dart';
import '../../data/prepare_data.dart' show kPrepOpeningSoon;
import '../../services/app_nav.dart';
import '../../services/life_stage_store.dart';
import '../../services/pregnancy_controller.dart';
import '../../theme/pv_fonts.dart';
import '../../widgets/global_ask_fab.dart' show kAskFabReserve;
import '../../widgets/pv_feedback.dart';
import '../calendar_screen.dart';
import '../enterprise/employer_benefits_screen.dart';
import '../journey_map_screen.dart';
import '../learn/pv_learn_catalog.dart';
import '../learn/pv_offering_screen.dart' show pvOpenOffering;
import '../preg_week_screen.dart';
import '../prepare/consultations_screen.dart';
import '../prepare/prepare_hub_screen.dart';
import '../brackets/hub/hub_intent_art.dart';
import '../products/pv_store_chrome.dart' show pvStorePalette;
import 'preg_chrome.dart';
import '../referral/invite_friends_screen.dart';
import '../watch_learn_screen.dart';
import 'preg_learn_screen.dart' show showPregOpeningSoon;
import 'preg_messages_screen.dart' show openPregMessages;
import '../../services/preg_messages_store.dart';

/// The pregnancy bar, by position. Positional because the labels are display
/// text (see `_pregnancySurfaces` in main_scaffold.dart).
const int kPregTabToday = 0;
const int kPregTabLearn = 1;
const int kPregTabProducts = 2;
const int kPregTabTools = 3;
const int kPregTabMore = 4;

class PregMoreScreen extends StatefulWidget {
  const PregMoreScreen({super.key, required this.pregnancy});
  final PregnancyController pregnancy;

  @override
  State<PregMoreScreen> createState() => _PregMoreScreenState();
}

class _PregMoreScreenState extends State<PregMoreScreen> {
  PregnancyController get _c => widget.pregnancy;

  static List<PvOfferingView> _of(Set<PvLearnKind> kinds) {
    try {
      return PvLearnCatalog.instance
          .all(stage: LifeStage.pregnancy)
          .where((v) => kinds.contains(v.kind))
          .toList();
    } catch (_) {
      // Local-first: the catalogue merging late is never a crash here.
      return const [];
    }
  }

  late final List<PvOfferingView> _consults = _of({PvLearnKind.consult});
  late final List<PvOfferingView> _courses =
      _of({PvLearnKind.course, PvLearnKind.masterclass, PvLearnKind.classPack});
  late final List<PvOfferingView> _groups = _of({PvLearnKind.cohort});

  void _push(String route, Widget Function() b) {
    pvCommitFeedback();
    Navigator.of(context).push(MaterialPageRoute<void>(
      settings: RouteSettings(name: route),
      builder: (_) => b(),
    ));
  }

  void _openOffering(PvOfferingView v) {
    pvCommitFeedback();
    if (kPrepOpeningSoon.contains(v.id)) {
      showPregOpeningSoon(context, v.title, id: v.id);
    } else {
      pvOpenOffering(context, v);
    }
  }

  void _openPrepare() => _push(
      'prepare',
      () => PrepareHubScreen(lang: _c.language, backLabel: 'More'));

  static IntentMark _markOf(PvLearnKind k) => switch (k) {
        PvLearnKind.consult => IntentMark.askDoctor,
        PvLearnKind.course => IntentMark.schoolMark,
        PvLearnKind.masterclass => IntentMark.lampMark,
        PvLearnKind.cohort => IntentMark.seatMark,
        PvLearnKind.classPack => IntentMark.lotusMark,
      };

  // ⚠️ ONE PARENTVEDA (2026-09-30, after main's TTC More tab): a drawn mark in
  // the section's tint, a name, one grey line, the price or a tag on the
  // right. Was `PvYouRow` with a line icon and the price as its value, kept in
  // git at 8124341 (this branch's own, never on main).
  Widget _offeringRow(PvOfferingView v, double hue) {
    final soon = kPrepOpeningSoon.contains(v.id);
    final who = [v.expert.name, v.expert.role].where((s) => s.isNotEmpty).join(' · ');
    final free = !soon && v.priceMinor == 0;
    return PregOfferRow(
      key: ValueKey('preg_more_offer_${v.id}'),
      mark: _markOf(v.kind),
      hue: hue,
      title: v.title,
      line: who.isEmpty ? v.subtitle : who,
      // "Opening soon" where the price would be: nothing is sold that cannot
      // be delivered (gap analysis, "Behind · Trust").
      price: soon || free ? null : v.priceLabel,
      tag: soon
          ? PregOfferTagKind.openingSoon
          : free
              ? PregOfferTagKind.free
              : null,
      onTap: () => _openOffering(v),
    );
  }

  Widget _section(String id, String title, List<Widget> rows,
          {String? lead, String? link, VoidCallback? onLink, String? empty}) =>
      Padding(
        key: ValueKey('preg_more_$id'),
        padding: const EdgeInsets.fromLTRB(20, 26, 20, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          PregSectionHeading(title, lead: lead, link: link, onLink: onLink),
          const SizedBox(height: 12),
          PregRowCard(empty: empty, children: rows),
        ]),
      );

  PregOfferRow _row(String id, IntentMark mark, double hue, String title, String line, VoidCallback onTap,
          {int? badge}) =>
      PregOfferRow(
          key: ValueKey(id), mark: mark, hue: hue, title: title, line: line, onTap: onTap, badge: badge);

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return ListenableBuilder(
      listenable: PregMessagesStore.instance,
      builder: (context, _) => Container(
        color: p.ground,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
              0, MediaQuery.of(context).padding.top + 12, 0, kAskFabReserve + 40),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('More',
                    style: pvFraunces(
                        fontSize: 30, fontWeight: FontWeight.w500, height: 1.1, color: p.ink1)),
                const SizedBox(height: 6),
                Text(
                    'Experts, courses and groups you can book, and your journey. What you have '
                    'booked or ordered is on your profile.',
                    style: pvManrope(fontSize: 14, height: 1.45, color: p.ink2)),
              ]),
            ),

            // ---- talk to an expert ---------------------------------------------
            _section(
              'experts',
              'Talk to an expert',
              [for (final v in _consults.take(6)) _offeringRow(v, 176)],
              lead: 'Private video calls with a specialist',
              link: 'See all consults',
              onLink: () => _push('prepare/consults', () => ConsultationsScreen(lang: _c.language)),
              empty: 'No experts listed yet. New ones are added as they join.',
            ),

            // ---- courses and masterclasses --------------------------------------
            _section(
              'courses',
              'Courses and masterclasses',
              [for (final v in _courses.take(6)) _offeringRow(v, 240)],
              lead: 'Learn at your own pace, or live with an expert',
              empty: 'Nothing open yet. New courses are added here as they open.',
            ),

            // ---- groups ---------------------------------------------------------
            _section(
              'groups',
              'Groups',
              [for (final v in _groups.take(6)) _offeringRow(v, 160)],
              lead: 'A few weeks of live calls in a small group',
              empty: 'Nothing scheduled yet. Groups appear here when a date is set.',
            ),

            // ---- read and watch -------------------------------------------------
            _section('read_watch', 'Read and watch', [
              _row('preg_more_all_reads', IntentMark.pageMark, 212, 'All reads', 'Every door, by topic, in Learn',
                  () {
                pvCommitFeedback();
                AppNav.instance.go(kPregTabLearn);
              }),
              _row('preg_more_all_films', IntentMark.listMark, 345, 'All films',
                  'Short films for each stage of your pregnancy',
                  () => _push('watch', () => WatchLearnScreen(controller: _c))),
            ], lead: 'Every read and every film, in one list each'),

            // ---- your journey ---------------------------------------------------
            _section('journey', 'Your journey', [
              // What the app said first (2026-09-30): the weekly note and the
              // moments that matter, kept so a missed one is not gone.
              _row('preg_more_messages', IntentMark.nextStep, 268, 'Messages',
                  'Your weekly note, and the moments worth remembering',
                  () {
                pvCommitFeedback();
                openPregMessages(context, _c);
              }, badge: PregMessagesStore.instance.unreadCount),
              // ⚠️ CALENDAR'S TAB MOVED HERE (2026-09-29): Learn took its slot.
              _row('preg_more_calendar', IntentMark.calendarDay, 206, 'Calendar',
                  'Your appointments, scans and what is coming up',
                  () => _push('calendar', () => CalendarScreen(controller: _c))),
              _row('preg_more_journey_map', IntentMark.timelineRail, 104, 'Journey map',
                  'Where you are this month, and what comes next',
                  () => _push('journey_map', () => JourneyMapScreen(controller: _c))),
              _row('preg_more_week', IntentMark.bodyMark, 24, 'Week by week',
                  'Your baby and your body, this week and every week',
                  () => _push('pregnancy/week', () => PregWeekScreen(pregnancy: _c, week: _c.currentWeek))),
            ]),

            // ---- benefits -------------------------------------------------------
            _section('benefits', 'Benefits', [
              _row('preg_more_employer', IntentMark.improveMark, 42, 'Employer benefits',
                  'Does your employer offer ParentVeda?',
                  () => _push('employer', () => EmployerBenefitsScreen(lang: _c.language))),
              _row('preg_more_invite', IntentMark.cuppedHands, 344, 'Invite a friend',
                  'Share ParentVeda with someone who is expecting too',
                  () => _push('invite', () => InviteFriendsScreen(controller: _c))),
            ]),

            // ---- the whole of Prepare, unfiltered: one outlined pill ------------
            //
            // ⚠️ UNSCOPED ON PURPOSE. Yoga, birthing classes and the nutrition
            // funnel have no section above; this row is their door.
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: InkWell(
                key: const ValueKey('preg_more_all_programmes'),
                onTap: _openPrepare,
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 48),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: p.line, width: 1.2),
                  ),
                  child: Row(children: [
                    Expanded(
                      child: Text('All programmes and sessions',
                          style: pvManrope(fontSize: 14, fontWeight: FontWeight.w700, color: p.ink1)),
                    ),
                    Icon(Icons.arrow_forward_rounded, size: 18, color: p.ink2),
                  ]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
