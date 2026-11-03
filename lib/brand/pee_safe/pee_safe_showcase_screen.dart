// =============================================================================
//  Pee Safe demo, item 10: the Showcase in You
// -----------------------------------------------------------------------------
//  One page that walks a meeting through every Pee Safe placement, in the
//  order of the voice note: launch film, brand page, reading shelf, recovery
//  kit, product placements, notifications, Partner track. Each card says what
//  to say, then "Show me" opens the REAL screen, never a mock of it. A
//  Showcase that opened copies would prove nothing about the app.
//
//  The sticky top holds the "ParentVeda × Pee Safe" lockup and "Reset demo",
//  so the walk can be run twice in one meeting from a clean slate.
//
//  Design choices worth defending:
//   * The steps are a const list ([kPeeSafeShowcaseSteps]), not seven
//     hand-built widgets. The order is the product here, and a list is the
//     one place a test can hold it.
//   * Reset calls each placement's OWN reset (PeeSafeStoreQr.reset,
//     RecoveryKitTicks.reset). The Showcase knows which state the demo
//     touches, but never how that state is stored. It does NOT call
//     BrandStudioStore.replayAll(): replayPremiere and sendNow record nothing
//     (items 3 and 8), so there is no replay or notification history to clear,
//     and replayAll would wipe every other campaign's impressions too.
//   * Demo mode goes on in initState, like the Brand Studio tour: the walk is
//     useless if targeting hides what it is meant to show.
//
//  Lime appears only inside the logo (PeeSafeCollabLockup); the page itself
//  stays ParentVeda ink. English, line icons, no emoji.
// =============================================================================

import 'package:flutter/material.dart';

// import '../../screens/post_pregnancy/pp_reco_data.dart' show kReco, recoCollectionById; // kept for revert (old Recommendations screens)
// import '../../screens/post_pregnancy/reco_collection_screen.dart' show RecoCollectionScreen; // kept for revert (old Recommendations screens)
// import '../../screens/post_pregnancy/reco_detail_screen.dart' show RecoDetailScreen; // kept for revert (old Recommendations screens)
// import '../../screens/post_pregnancy/recommendations_screen.dart' show RecommendationsScreen; // kept for revert (old Recommendations screens)
import '../../screens/products/pv_shelf_screen.dart' show PvShelfScreen;
import '../../screens/tools/ready_for_birth_screen.dart' show ReadyForBirthScreen;
import '../../services/pregnancy_controller.dart' show PregnancyController;
import '../../theme/pv_fonts.dart';
import '../../widgets/pv_feedback.dart' show PvPress;
import '../../widgets/pv_toast.dart';
import '../brand_notifications.dart';
import '../brand_page_screen.dart' show BrandPageScreen;
import '../brand_studio.dart';
import '../premiere_screen.dart' show replayPremiere;
import 'pee_safe_brand.dart';
import '../brand_store.dart' show BrandStudioStore;
import '../brand_inbox.dart' show BrandInbox;
import 'pee_safe_collab.dart' show PeeSafeCollabLockup;
import 'pee_safe_partner.dart';
import 'pee_safe_reads.dart' show openPeeSafeRead;
import 'pee_safe_recovery_kit_screen.dart';

/// The route name the You row opens this page under.
const String kPeeSafeShowcaseRoute = 'pee_safe_showcase';

/// The read the reading-shelf card opens: the first on the shelf.
const String kPeeSafeShowcaseReadId = 'ps_read_discharge';

/// Which placement a card shows. One per voice-note step.
enum PeeSafeShowcaseKind { premiere, brandPage, reads, kit, placements, notifications, partner }

/// One card: what it is, what to say, and where it lives in the app.
class PeeSafeShowcaseStep {
  const PeeSafeShowcaseStep({
    required this.kind,
    required this.title,
    required this.talk,
    required this.where,
    required this.icon,
  });

  final PeeSafeShowcaseKind kind;
  final String title;

  /// Two or three lines to say in the room.
  final String talk;

  /// "In the app: …", where a parent meets it without the Showcase.
  final String where;
  final IconData icon;
}

/// The walk, in the voice-note order. The test holds this order.
const List<PeeSafeShowcaseStep> kPeeSafeShowcaseSteps = [
  PeeSafeShowcaseStep(
    kind: PeeSafeShowcaseKind.premiere,
    title: 'The launch film',
    talk: 'Pee Safe arrives with a full-screen film, once per family, never again. '
        'Skip and mute are always there, and the end card hands over to the launch.',
    // Kept for revert: 'shown once when the app opens, in the stage it is aimed at'
    // (the audience is everyone, P3).
    where: 'shown once when the app opens, in every stage',
    icon: Icons.play_circle_outline,
  ),
  PeeSafeShowcaseStep(
    kind: PeeSafeShowcaseKind.brandPage,
    title: 'The brand page',
    talk: 'A home for Pee Safe inside ParentVeda: its story, its film, and its products '
        'grouped by the moment a parent needs them, each going to the store.',
    where: 'the brand link on the Pee Safe launch',
    icon: Icons.storefront_outlined,
  ),
  PeeSafeShowcaseStep(
    kind: PeeSafeShowcaseKind.reads,
    title: 'The reading shelf',
    talk: 'Six short reads and an FAQ on the things parents ask quietly. '
        'Written in our calm voice, marked "Presented by Pee Safe", products only at the end.',
    where: 'the brand page shelf and the launch resources',
    icon: Icons.menu_book_outlined,
  ),
  PeeSafeShowcaseStep(
    kind: PeeSafeShowcaseKind.kit,
    title: 'The recovery kit',
    talk: 'A postpartum checklist a mother ticks off on her own phone. '
        'Each item explains why it helps; Pee Safe products follow, labelled Sponsored.',
    where: 'the card on the Pee Safe brand page',
    icon: Icons.checklist_outlined,
  ),
  PeeSafeShowcaseStep(
    kind: PeeSafeShowcaseKind.placements,
    title: 'Product placements',
    // Kept for revert: talk '... one featured pick, the hospital bag, the
    // After Birth Care collection and the travel kit. Ratings stay ours.',
    // where 'Recommendations, the hospital bag, collections, the travel kit'.
    talk: 'Pee Safe where parents already shop: the hospital bag, and three store shelves, '
        'Maternal Recovery, Skincare & Hygiene, and On the move. Labelled Sponsored, after our own picks; no rating of ours.',
    where: 'the hospital bag and the store shelves',
    icon: Icons.shopping_bag_outlined,
  ),
  PeeSafeShowcaseStep(
    kind: PeeSafeShowcaseKind.notifications,
    title: 'Notifications',
    talk: 'Three timely nudges: the bag at week 36, peri care in the first days, '
        'travel later on. Each opens a real page, once only. Tap again for the next one.',
    where: 'your phone, when the moment comes',
    icon: Icons.notifications_none_outlined,
  ),
  PeeSafeShowcaseStep(
    kind: PeeSafeShowcaseKind.partner,
    title: 'The Partner track',
    talk: 'A family who scans a QR in a Pee Safe store gets ParentVeda presented by Pee Safe, '
        'with an offer. "Show me" turns the switch on and goes back to You, where the offer sits at the top.',
    // Kept for revert: 'with an offer. Turn the switch on, then look at Your benefits.',
    // ("Your benefits" opens the employer screen, which shows nothing of Pee Safe.)
    where: 'the offer card at the top of You, Your benefits, and the rail on Home',
    icon: Icons.qr_code_2_outlined,
  ),
];

/// Back to a clean walk: the store QR off and the kit's ticks cleared. Each
/// placement owns its reset; this only calls them. Replays and demo sends
/// record nothing, so there is no history of theirs to clear.
Future<void> resetPeeSafeDemo() async {
  PeeSafeStoreQr.reset();
  // Item 11: re-arm the app-open Premiere (once per phone) for the next walk.
  BrandStudioStore.instance.forgetImpressions(kPeeSafePremiereId);
  // And the sent notes in Messages, so the next walk starts with none.
  await BrandInbox.instance.reset();
  await RecoveryKitTicks.instance.reset();
}

// Kept for revert: _ink 0xFF2D144C (a purple ink, 2026-11-03: the app's one ink).
const Color _ink = Color(0xFF2F2C30);
const Color _soft = Color(0xFF69636C);
const Color _line = Color(0xFFE4E2E5);
// Kept for revert: _bg 0xFFFBF9FE and _tile 0xFFF3EFF8 (lavender, 2026-11-03).
const Color _bg = Color(0xFFFAF9F7);
const Color _tile = Color(0xFFF2F1EE);

class PeeSafeShowcaseScreen extends StatefulWidget {
  const PeeSafeShowcaseScreen({super.key});

  /// The one way to open this page, so the route name is never forgotten.
  static Route<void> route() => MaterialPageRoute(
        settings: const RouteSettings(name: kPeeSafeShowcaseRoute),
        builder: (_) => const PeeSafeShowcaseScreen(),
      );

  @override
  State<PeeSafeShowcaseScreen> createState() => _PeeSafeShowcaseScreenState();
}

class _PeeSafeShowcaseScreenState extends State<PeeSafeShowcaseScreen> {
  /// Which notification "Show me" sends next, so the room sees all three.
  int _notifTurn = 0;

  @override
  void initState() {
    super.initState();
    // As in the Brand Studio tour: demo mode relaxes audience and frequency
    // caps only. Kill switch, schedule and rank floor still apply.
    BrandStudio.instance.demoMode = true;
  }

  void _push(Widget screen, String name) => Navigator.of(context).push(
        MaterialPageRoute<void>(settings: RouteSettings(name: name), builder: (_) => screen),
      );

  void _toast(String m) => pvToast(context, m);

  Future<void> _showMe(PeeSafeShowcaseKind kind) async {
    switch (kind) {
      case PeeSafeShowcaseKind.premiere:
        final ok = await replayPremiere(context, campaignId: kPeeSafePremiereId);
        if (!ok && mounted) _toast('The launch film is not live right now.');
      case PeeSafeShowcaseKind.brandPage:
        Navigator.of(context).push(BrandPageScreen.route(kPeeSafe));
      case PeeSafeShowcaseKind.reads:
        if (!openPeeSafeRead(context, kPeeSafeShowcaseReadId)) _toast('The shelf is empty right now.');
      case PeeSafeShowcaseKind.kit:
        Navigator.of(context).push(PeeSafeRecoveryKitScreen.route());
      case PeeSafeShowcaseKind.placements:
        await _placementsSheet();
      case PeeSafeShowcaseKind.notifications:
        final id = kPeeSafeNotificationIds[_notifTurn % kPeeSafeNotificationIds.length];
        _notifTurn++;
        final sent = await BrandNotifications.instance.sendNow(id);
        if (!mounted) return;
        _toast(sent == null
            ? 'Could not send. Is demo mode on?'
            : 'Sent: ${sent.creative.headline}. Tap it in your notifications.');
      case PeeSafeShowcaseKind.partner:
        // The switch sits on the card; "Show me" turns it on and returns to
        // You (the Showcase is pushed from You), where the offer card renders
        // under the hero. Kept for revert:
        // _toast('Turn the switch on, then open Your benefits in You.');
        if (!PeeSafeStoreQr.on) PeeSafeStoreQr.set(true);
        _toast('Store QR on. Pee Safe\'s offer is at the top of You, and on the Home rail.');
        Navigator.of(context).maybePop();
    }
  }

  /// The four placements, each opening its real screen.
  Future<void> _placementsSheet() => showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (sheet) {
          void go(VoidCallback open) {
            Navigator.of(sheet).pop();
            open();
          }

          Widget row(String key, IconData icon, String title, String sub, VoidCallback open) => ListTile(
                key: ValueKey('ps_showcase_place_$key'),
                leading: Icon(icon, color: _ink),
                title: Text(title, style: pvManrope(fontSize: 14, fontWeight: FontWeight.w700, color: _ink)),
                subtitle: Text(sub, style: pvManrope(fontSize: 12, color: _soft)),
                trailing: const Icon(Icons.chevron_right, color: _soft),
                onTap: () => go(open),
              );

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                // ⚠️ THE LIVE STORE (2026-11-03): the featured pick, the After
                // Birth Care collection and the travel kit opened the old
                // Recommendations screens, which the shipped app no longer
                // reaches. The products are on the store's own shelves now
                // (pee_safe_store.dart). Kept for revert: 'featured' pushed
                // RecommendationsScreen; 'collection' a RecoCollectionScreen
                // of kPeeSafeCollectionKey; 'travel' the RecoDetailScreen of
                // kPeeSafeTravelKey.
                row('recovery', Icons.healing_outlined, 'After birth: Maternal Recovery', 'Pregnancy store', () {
                  _push(const PvShelfScreen(categoryId: 'pvs_maternal_recovery'), 'products/shelf');
                }),
                row('bag', Icons.luggage_outlined, 'Hospital bag', 'Pregnancy tools', () {
                  final preg = PregnancyController.current;
                  if (preg == null) {
                    _toast('Open a pregnancy profile to see the hospital bag.');
                    return;
                  }
                  // forceV1: the Pee Safe rows live on V1 only; a phone left on
                  // V2 must not open an empty bag in front of the room.
                  // The live bag (2026-11-03), where the rows now are. Kept
                  // for revert: HospitalBagScreen(controller: preg, forceV1: true).
                  _push(ReadyForBirthScreen(controller: preg), 'tools/hospital_bag');
                }),
                row('hygiene', Icons.spa_outlined, 'Skincare & Hygiene', 'Pregnancy store', () {
                  _push(const PvShelfScreen(categoryId: 'pvs_skincare_and_hygiene'), 'products/shelf');
                }),
                row('travel', Icons.flight_outlined, 'On the move', 'Parenting store', () {
                  _push(const PvShelfScreen(categoryId: 'on_the_move'), 'products/shelf');
                }),
              ]),
            ),
          );
        },
      );

  Future<void> _reset() async {
    await resetPeeSafeDemo();
    if (!mounted) return;
    setState(() => _notifTurn = 0);
    _toast('Demo reset. Ready to walk again.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          // The sticky top: back, the lockup, Reset demo.
          Container(
            padding: const EdgeInsets.fromLTRB(4, 6, 12, 10),
            decoration: const BoxDecoration(
              color: _bg,
              border: Border(bottom: BorderSide(color: _line)),
            ),
            child: Row(children: [
              IconButton(
                tooltip: 'Back',
                icon: const Icon(Icons.arrow_back, color: _ink),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              const Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: PeeSafeCollabLockup(height: 17),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                key: const ValueKey('ps_showcase_reset'),
                onPressed: _reset,
                icon: const Icon(Icons.restart_alt, size: 18),
                label: const Text('Reset demo'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _ink,
                  side: const BorderSide(color: _line),
                  shape: const StadiumBorder(),
                  textStyle: pvManrope(fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ),
            ]),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
              children: [
                Text('The Showcase',
                    style: pvFraunces(fontSize: 26, fontWeight: FontWeight.w600, color: _ink)),
                const SizedBox(height: 4),
                Text('Every Pee Safe placement, in order. Each "Show me" opens the real screen.',
                    style: pvManrope(fontSize: 13, height: 1.45, color: _soft)),
                const SizedBox(height: 16),
                for (var i = 0; i < kPeeSafeShowcaseSteps.length; i++) ...[
                  _Card(
                    number: i + 1,
                    step: kPeeSafeShowcaseSteps[i],
                    onShowMe: () => _showMe(kPeeSafeShowcaseSteps[i].kind),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.number, required this.step, required this.onShowMe});

  final int number;
  final PeeSafeShowcaseStep step;
  final VoidCallback onShowMe;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey('ps_showcase_card_${step.kind.name}'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _line),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // The preview: the placement's line icon on a quiet tile.
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: _tile, borderRadius: BorderRadius.circular(12)),
            child: Icon(step.icon, color: _ink, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('$number. ${step.title}',
                  style: pvManrope(fontSize: 16, fontWeight: FontWeight.w800, color: _ink)),
              const SizedBox(height: 6),
              Text(step.talk, style: pvManrope(fontSize: 13, height: 1.45, color: _ink)),
            ]),
          ),
        ]),
        if (step.kind == PeeSafeShowcaseKind.partner) ...[
          const SizedBox(height: 12),
          const PeeSafeStoreQrSwitch(),
        ],
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: Text('In the app: ${step.where}',
                style: pvManrope(fontSize: 11.5, height: 1.4, color: _soft)),
          ),
          const SizedBox(width: 8),
          PvPress(
            child: GestureDetector(
              key: ValueKey('ps_showcase_show_${step.kind.name}'),
              behavior: HitTestBehavior.opaque,
              onTap: onShowMe,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(color: _ink, borderRadius: BorderRadius.circular(999)),
                child: Text('Show me ›',
                    style: pvManrope(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
          ),
        ]),
      ]),
    );
  }
}
