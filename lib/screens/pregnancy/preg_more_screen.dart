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
import '../profile/pv_you_chrome.dart';
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

  static IconData _iconOf(PvLearnKind k) => switch (k) {
        PvLearnKind.consult => Icons.video_call_outlined,
        PvLearnKind.course => Icons.play_lesson_outlined,
        PvLearnKind.masterclass => Icons.co_present_outlined,
        PvLearnKind.cohort => Icons.groups_2_outlined,
        PvLearnKind.classPack => Icons.self_improvement_rounded,
      };

  Widget _offeringRow(PvOfferingView v) {
    final soon = kPrepOpeningSoon.contains(v.id);
    final who = [v.expert.name, v.expert.role].where((s) => s.isNotEmpty).join(' · ');
    return PvYouRow(
      icon: _iconOf(v.kind),
      title: v.title,
      subtitle: who.isEmpty ? v.subtitle : who,
      // "Opening soon" where the price would be: nothing is sold that cannot
      // be delivered (gap analysis, "Behind · Trust").
      value: soon ? 'Opening soon' : v.priceLabel,
      onTap: () => _openOffering(v),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return Container(
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
                  'Experts, courses and groups you can book, your calendar and your '
                  'journey. What you have booked or ordered is on your profile.',
                  style: pvManrope(fontSize: 14, height: 1.45, color: p.ink2)),
            ]),
          ),

          // ---- talk to an expert ---------------------------------------------
          PvYouSection(
            key: const ValueKey('preg_more_experts'),
            title: 'Talk to an expert',
            lead: 'Private video calls with a specialist',
            children: [
              for (final v in _consults.take(6)) _offeringRow(v),
              PvYouRow(
                icon: Icons.arrow_forward_rounded,
                title: 'See all consults',
                onTap: () => _push('prepare/consults',
                    () => ConsultationsScreen(lang: _c.language)),
              ),
            ],
          ),

          // ---- courses and masterclasses --------------------------------------
          PvYouSection(
            key: const ValueKey('preg_more_courses'),
            title: 'Courses and masterclasses',
            lead: 'Learn at your own pace, or live with an expert',
            children: [
              for (final v in _courses.take(6)) _offeringRow(v),
              if (_courses.isEmpty)
                PvYouRow(
                  icon: Icons.play_lesson_outlined,
                  title: 'Nothing open yet',
                  subtitle: 'New courses appear here as they open',
                  onTap: _openPrepare,
                ),
            ],
          ),

          // ---- groups ---------------------------------------------------------
          PvYouSection(
            key: const ValueKey('preg_more_groups'),
            title: 'Groups',
            lead: 'A few weeks of live calls in a small group',
            children: [
              for (final v in _groups.take(6)) _offeringRow(v),
              if (_groups.isEmpty)
                PvYouRow(
                  icon: Icons.groups_2_outlined,
                  title: 'Nothing scheduled yet',
                  subtitle: 'Groups appear here when a date is set',
                  onTap: _openPrepare,
                ),
            ],
          ),

          // ---- read and watch -------------------------------------------------
          PvYouSection(
            key: const ValueKey('preg_more_read_watch'),
            title: 'Read and watch',
            lead: 'Every read and every film, in one list each',
            children: [
              PvYouRow(
                icon: Icons.menu_book_outlined,
                title: 'All reads',
                subtitle: 'Every door, by topic, in Learn',
                onTap: () {
                  pvCommitFeedback();
                  AppNav.instance.go(kPregTabLearn);
                },
              ),
              PvYouRow(
                icon: Icons.play_circle_outline_rounded,
                title: 'All films',
                subtitle: 'Short films for each stage of your pregnancy',
                onTap: () => _push('watch', () => WatchLearnScreen(controller: _c)),
              ),
            ],
          ),

          // ---- your journey ---------------------------------------------------
          PvYouSection(
            key: const ValueKey('preg_more_journey'),
            title: 'Your journey',
            children: [
              // What the app said first (2026-09-30): the weekly note and the
              // moments that matter, kept so a missed one is not gone.
              ListenableBuilder(
                listenable: PregMessagesStore.instance,
                builder: (context, _) => PvYouRow(
                  key: const ValueKey('preg_more_messages'),
                  icon: Icons.mail_outline_rounded,
                  title: 'Messages',
                  subtitle: 'Your weekly note, and the moments worth remembering',
                  badge: PregMessagesStore.instance.unreadCount,
                  onTap: () {
                    pvCommitFeedback();
                    openPregMessages(context, _c);
                  },
                ),
              ),
              // ⚠️ CALENDAR'S TAB MOVED HERE (2026-09-29): Learn took its slot.
              PvYouRow(
                icon: Icons.calendar_today_outlined,
                title: 'Calendar',
                subtitle: 'Your appointments, scans and what is coming up',
                onTap: () => _push('calendar', () => CalendarScreen(controller: _c)),
              ),
              PvYouRow(
                icon: Icons.map_outlined,
                title: 'Journey map',
                subtitle: 'Where you are this month, and what comes next',
                onTap: () => _push('journey_map', () => JourneyMapScreen(controller: _c)),
              ),
              PvYouRow(
                icon: Icons.child_care_outlined,
                title: 'Week by week',
                subtitle: 'Your baby and your body, this week and every week',
                onTap: () => _push('pregnancy/week',
                    () => PregWeekScreen(pregnancy: _c, week: _c.currentWeek)),
              ),
            ],
          ),

          // ---- benefits -------------------------------------------------------
          PvYouSection(
            key: const ValueKey('preg_more_benefits'),
            title: 'Benefits',
            children: [
              PvYouRow(
                icon: Icons.business_center_outlined,
                title: 'Employer benefits',
                subtitle: 'Does your employer offer ParentVeda?',
                onTap: () => _push('employer', () => EmployerBenefitsScreen(lang: _c.language)),
              ),
              PvYouRow(
                icon: Icons.card_giftcard_outlined,
                title: 'Invite a friend',
                subtitle: 'Share ParentVeda with someone who is expecting too',
                onTap: () => _push('invite', () => InviteFriendsScreen(controller: _c)),
              ),
            ],
          ),

          // ---- the whole of Prepare, unfiltered ---------------------------------
          //
          // ⚠️ UNSCOPED ON PURPOSE. Yoga, birthing classes and the nutrition
          // funnel have no section above; this row is their door.
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
            child: Material(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18), side: const BorderSide(color: kPvLine)),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                key: const ValueKey('preg_more_all_programmes'),
                onTap: _openPrepare,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(children: [
                    Expanded(
                      child: Text('All programmes and sessions',
                          style: pvManrope(
                              fontSize: 14.5, fontWeight: FontWeight.w600, color: p.ink1)),
                    ),
                    Icon(Icons.arrow_forward_rounded, size: 20, color: p.ink2),
                  ]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
