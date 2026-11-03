// =============================================================================
//  Pee Safe — the postpartum recovery kit checklist (demo item 6)
// -----------------------------------------------------------------------------
//  DEMO ONLY (docs/PEE-SAFE-DEMO.md). A ParentVeda tool, funded by Pee Safe
//  through a sponsoredTool campaign with its own placementKey, so buying this
//  tool can never brand another one (brand_studio_test: "a campaign never leaks
//  onto a placement it did not name").
//
//  Order is the point of the design:
//    1. the checklist - generic items, no brand in any of them;
//    2. when to call the doctor - the clinical copy ends at "see your doctor";
//    3. only then, Pee Safe products matched to items, each labelled Sponsored.
//  A parent who never scrolls past the list has a complete tool.
//
//  Ticks live on this device only (shared_preferences). They are a shopping
//  list, not a health record, so they never sync and never leave the phone.
//  Shared surface, so ParentVeda ink - lime stays on Pee Safe's own pages.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/remote/sync_registry.dart';
import '../../screens/brackets/hub/hub_intent_art.dart' show IntentMark;
import '../../screens/pregnancy/preg_tool_chrome.dart' show PregToolScaffold;
import '../../theme/pv_fonts.dart';
import '../../widgets/pv_feedback.dart' show PvPress;
import '../brand_analytics.dart';
import '../brand_models.dart';
import '../brand_studio.dart';
import '../presented_by.dart';
import 'pee_safe_brand.dart';
import 'pee_safe_products.dart';
import 'pee_safe_reads.dart';

/// The route name other code detects this tool by.
const String kPeeSafeKitRoute = 'pee_safe_recovery_kit';

/// One generic thing to have ready. [productId] and [readId] are optional
/// links out; the item stands on its own without either.
@immutable
class RecoveryKitItem {
  const RecoveryKitItem({
    required this.id,
    required this.title,
    required this.line,
    required this.icon,
    this.productId,
    this.readId,
  });

  final String id;
  final String title;
  final String line;
  final IconData icon;

  /// A matching Pee Safe product (`kPeeSafeProducts`), shown after the list.
  final String? productId;

  /// A ParentVeda read that explains why ("Why" link).
  final String? readId;

  PeeSafeProduct? get product {
    if (productId == null) return null;
    for (final p in kPeeSafeProducts) {
      if (p.id == productId) return p;
    }
    return null;
  }
}

const List<RecoveryKitItem> kRecoveryKitItems = [
  RecoveryKitItem(
    id: 'maternity_pads',
    title: 'Maternity pads',
    line: 'Two or three packs of long, soft pads for the heavier bleeding of the first weeks. '
        'Tampons and cups wait until your doctor says they are fine.',
    icon: Icons.layers_outlined,
    productId: 'ps_night_pads',
    readId: 'ps_read_lochia',
  ),
  RecoveryKitItem(
    id: 'disposable_underwear',
    title: 'Disposable underwear',
    line: 'Easy to pull on for the hospital stay and the first days home, including after a C-section.',
    icon: Icons.checkroom_outlined,
    productId: 'ps_period_panty',
    readId: 'ps_read_lochia',
  ),
  RecoveryKitItem(
    id: 'night_protection',
    title: 'Something for nights',
    line: 'Longer pads, or pads with a pull-on layer, so you can rest without worrying about leaks.',
    icon: Icons.bedtime_outlined,
    productId: 'ps_all_night_kit',
  ),
  RecoveryKitItem(
    id: 'peri_rinse',
    title: 'Peri bottle or rinse',
    line: 'Warm water after the toilet, then pat dry from front to back. Gentler than wiping while you heal.',
    icon: Icons.water_drop_outlined,
    productId: 'ps_jet_spray',
    readId: 'ps_read_peri',
  ),
  RecoveryKitItem(
    id: 'cotton_underwear',
    title: 'Loose cotton underwear',
    line: 'High-waisted pairs sit above a C-section wound and let the area breathe.',
    icon: Icons.dry_cleaning_outlined,
  ),
  RecoveryKitItem(
    id: 'cool_pack',
    title: 'A cool pack and a clean cloth',
    line: 'Wrapped in the cloth, never straight on the skin, it can ease swelling in the first day or two.',
    icon: Icons.ac_unit_outlined,
    readId: 'ps_read_peri',
  ),
  RecoveryKitItem(
    id: 'water_bottle',
    title: 'A water bottle by the bed',
    line: 'Drinking well keeps urine pale, which makes passing it sting less.',
    icon: Icons.local_drink_outlined,
  ),
  RecoveryKitItem(
    id: 'liners_later',
    title: 'Panty liners, for later',
    line: 'Bleeding usually tapers to spotting over about six weeks. Thin liners take over from pads.',
    icon: Icons.event_available_outlined,
    productId: 'ps_panty_liners',
    readId: 'ps_read_lochia',
  ),
];

// =============================================================================
//  Ticks - device only
// =============================================================================

/// Which kit items are ticked. Singleton ChangeNotifier like every store in
/// the app; local only, by design (see the header).
class RecoveryKitTicks extends ChangeNotifier {
  // Item 11: a sign-out forgets her ticks. They say she is postpartum, so
  // they are hers, not the phone's (test/sync_reset_coverage_test.dart).
  // The cache is already wiped when this runs; only memory is left.
  RecoveryKitTicks._() {
    SyncRegistry.registerReset(_resetForAccount);
  }
  // Kept for revert: RecoveryKitTicks._();
  static final RecoveryKitTicks instance = RecoveryKitTicks._();

  static const String _key = 'pee_safe_recovery_kit_ticks';

  final Set<String> _ticked = {};
  bool _loaded = false;

  bool isTicked(String id) => _ticked.contains(id);
  int get count => _ticked.length;

  Future<void> load() async {
    if (_loaded) return;
    try {
      final p = await SharedPreferences.getInstance();
      _ticked
        ..clear()
        ..addAll(p.getStringList(_key) ?? const []);
    } catch (_) {
      // Storage failing is never a crash; the list just starts empty.
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> toggle(String id) async {
    _ticked.contains(id) ? _ticked.remove(id) : _ticked.add(id);
    notifyListeners();
    await _save();
  }

  void _resetForAccount() {
    _ticked.clear();
    _loaded = false;
    notifyListeners();
  }

  /// Clears every tick. For the Showcase "Reset demo" (item 10).
  Future<void> reset() async {
    _ticked.clear();
    notifyListeners();
    await _save();
  }

  Future<void> _save() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setStringList(_key, _ticked.toList()..sort());
    } catch (_) {}
  }

  /// Forget the in-memory copy so the next load reads storage again.
  @visibleForTesting
  void debugUnload() {
    _ticked.clear();
    _loaded = false;
  }
}

/// The tool's campaign, by id. A lookup, not a resolve: PresentedBy already
/// counted the impression, so this is attribution for product taps only.
BrandCampaign? peeSafeKitCampaign() {
  for (final c in BrandStudio.instance.campaigns) {
    if (c.id == kPeeSafeKitToolId && c.active) return c;
  }
  return null;
}

// =============================================================================
//  The screen
// =============================================================================

// Kept for revert: _ink 0xFF2D144C (a purple ink, 2026-11-03: the app's one ink).
const Color _ink = Color(0xFF2F2C30);
const Color _soft = Color(0xFF69636C);
const Color _line = Color(0xFFE4E2E5);
// const Color _bg = Color(0xFFFBF9FE); // kept for revert: the page before the tool shell

class PeeSafeRecoveryKitScreen extends StatefulWidget {
  const PeeSafeRecoveryKitScreen({super.key});

  /// The one way to open this tool, so the route name is never forgotten.
  static Route<void> route() => MaterialPageRoute(
        settings: const RouteSettings(name: kPeeSafeKitRoute),
        builder: (_) => const PeeSafeRecoveryKitScreen(),
      );

  @override
  State<PeeSafeRecoveryKitScreen> createState() => _PeeSafeRecoveryKitScreenState();
}

class _PeeSafeRecoveryKitScreenState extends State<PeeSafeRecoveryKitScreen> {
  final RecoveryKitTicks _ticks = RecoveryKitTicks.instance;

  @override
  void initState() {
    super.initState();
    _ticks.load();
  }

  @override
  Widget build(BuildContext context) {
    final matched = [
      for (final i in kRecoveryKitItems)
        if (i.product != null) i,
    ];
    // ⚠️ ON THE ONE TOOL SHELL (2026-11-03): listed in Tools now, so it wears
    // PregToolScaffold like every tool (test/pp_tools_one_look_test.dart), not
    // a page of its own. Kept for revert: a Scaffold on _bg with an AppBar
    // titled 'Recovery kit', a ListView padded (20, 4, 20, 40), and a Fraunces
    // 26 'Your recovery kit' with the intro line under it.
    return ListenableBuilder(
      listenable: _ticks,
      builder: (context, _) => PregToolScaffold(
          hue: 288,
          eyebrow: 'Recovery kit',
          title: 'Ready for the weeks after birth',
          intro: 'Eight small things that make healing easier. Tick what you have; ticks stay on this phone.',
          mark: IntentMark.bagMark,
          children: [
            const PresentedBy(
              slot: BrandSlot.sponsoredTool,
              stage: BrandStage.parenting,
              placementKey: kPeeSafeKitPlacement,
              padding: EdgeInsets.only(top: 12),
            ),
            const SizedBox(height: 18),
            Text('${_ticks.count} of ${kRecoveryKitItems.length} ready',
                key: const ValueKey('ps_kit_progress'),
                style: pvManrope(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.4, color: _ink)),
            const SizedBox(height: 10),
            for (final item in kRecoveryKitItems) _row(context, item),
            const SizedBox(height: 14),
            _doctor(),
            if (matched.isNotEmpty) ...[
              const SizedBox(height: 30),
              _products(matched),
            ],
          ],
        ),
    );
  }

  Widget _row(BuildContext context, RecoveryKitItem item) {
    final on = _ticks.isTicked(item.id);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: PvPress(
        child: GestureDetector(
          key: ValueKey('ps_kit_item_${item.id}'),
          behavior: HitTestBehavior.opaque,
          onTap: () => _ticks.toggle(item.id),
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: on ? _ink.withValues(alpha: 0.35) : _line),
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(on ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                  size: 22, color: on ? _ink : _soft),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Icon(item.icon, size: 15, color: _ink),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(item.title,
                          style: pvJakarta(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _ink,
                            decoration: on ? TextDecoration.lineThrough : null,
                          )),
                    ),
                  ]),
                  const SizedBox(height: 4),
                  Text(item.line, style: pvManrope(fontSize: 12.5, height: 1.45, color: _soft)),
                  if (item.readId != null)
                    PvPress(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => openPeeSafeRead(context, item.readId!),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Text('Why this helps',
                                style: pvManrope(fontSize: 12, fontWeight: FontWeight.w700, color: _ink)),
                            const SizedBox(width: 2),
                            const Icon(Icons.chevron_right_rounded, size: 15, color: _ink),
                          ]),
                        ),
                      ),
                    ),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  // Clinical copy ends at "see your doctor" - nothing after it in this block.
  Widget _doctor() => Container(
        key: const ValueKey('ps_kit_doctor'),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F1EE), // was 0xFFF3EFF8 lavender (2026-11-03)
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.medical_services_outlined, size: 18, color: _ink),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Soaking a pad in an hour or less, clots bigger than a plum, a fever, a smell that worries you, '
              'or pain that is getting worse rather than better are reasons not to wait. If any of these happen, '
              'see your doctor.',
              style: pvManrope(fontSize: 12.5, height: 1.5, color: _ink),
            ),
          ),
        ]),
      );

  Widget _products(List<RecoveryKitItem> matched) {
    final c = peeSafeKitCampaign();
    return Column(
      key: const ValueKey('ps_kit_products'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('FROM PEE SAFE',
            style: pvManrope(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.1, color: _ink)),
        const SizedBox(height: 4),
        Text('Matched to your list. Any brand will do; the list above does not change because of these.',
            style: pvManrope(fontSize: 12, height: 1.45, color: _soft)),
        const SizedBox(height: 12),
        for (final item in matched) _productRow(item, item.product!, c),
      ],
    );
  }

  Widget _productRow(RecoveryKitItem item, PeeSafeProduct p, BrandCampaign? c) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: PvPress(
          child: GestureDetector(
            key: ValueKey('ps_kit_product_${p.id}'),
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (c != null) BrandAnalytics.instance.event(c, BrandEvent.opened, meta: {'item': item.id});
              p.open(campaign: c);
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _line),
              ),
              child: Row(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(p.image,
                      width: 52,
                      height: 52,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(width: 52, height: 52, color: _line)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Flexible(
                        child: Text('For: ${item.title}',
                            overflow: TextOverflow.ellipsis,
                            style: pvManrope(fontSize: 11, fontWeight: FontWeight.w700, color: _soft)),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: _line),
                        ),
                        child: Text('Sponsored',
                            style: pvManrope(fontSize: 10, fontWeight: FontWeight.w800, color: _soft)),
                      ),
                    ]),
                    const SizedBox(height: 3),
                    Text(p.name, style: pvJakarta(fontSize: 13.5, fontWeight: FontWeight.w700, color: _ink)),
                  ]),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.open_in_new_rounded, size: 15, color: _soft),
              ]),
            ),
          ),
        ),
      );
}
