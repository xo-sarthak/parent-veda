// =============================================================================
//  Ready for Birth - the Hospital Bag, redesigned as a readiness experience
// -----------------------------------------------------------------------------
//  Rebuilt from first principles (Claude Design prompt). The mother opens this
//  and, within seconds, knows the one thing she came to learn: "If labour starts
//  today, am I ready?" No long checklist. A calm dashboard answers it — week,
//  ready status, % ready, today's focus, minutes left — over four simple
//  categories (Mom · Baby · Documents · Partner & Extras). Progressive
//  disclosure: items only appear inside a category. The primary action is
//  S.now.rfbPackTogether (a guided, small-wins flow); a persistent "Labour
//  started?" opens a calm emergency grab-list. Contextual ParentVeda insights
//  replace articles. Reuses the existing bag data (HospitalBagV2Store + catalogue
//  + seed); personalisation lives in ReadyBirthContextStore. Replaces the old
//  HospitalBagScreen wrapper as the live entry (old files kept for revert).
//
//  ⚠️ ONE PARENTVEDA (2026-09-30, the pregnancy restyle). The page wore the
//  brand violet (the week eyebrow, the ring, every filled button, the chosen
//  pill) and a tinted block behind most sentences. Now: the serif page title
//  under the back arrow, a white hero card, the one ink for everything she
//  presses, the insights as one white card, the four categories as rows with
//  drawn marks (they open somewhere), and the section headings in the serif.
//  The category colours in `kReadyCatMeta` include the violet, so this file
//  no longer reads `meta.color`; each category's mark is `_kCatMark` below.
// =============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../brand/outbound.dart';
import '../../data/hospital_bag_catalog.dart';
import '../../data/hospital_bag_seed.dart';
import '../../data/ready_for_birth_data.dart';
import '../../localization/app_language.dart';
import '../../services/hospital_bag_store.dart';
import '../../services/hospital_bag_v2_store.dart';
import '../../services/pregnancy_controller.dart';
import '../../services/ready_birth_context_store.dart';
import '../../theme/app_theme.dart';
import '../../theme/pv_fonts.dart';
import '../brackets/hub/hub_intent_art.dart';
import '../doors/pv_door_chrome.dart' show kPvUrgentInk;
import '../doors/pv_list_row.dart' show PvMarkWell;
import '../pregnancy/preg_chrome.dart';
import '../product_guide/product_guide_chooser.dart';
import '../products/pv_store_chrome.dart' show kPvInk, kPvLine, pvStorePalette;

/// The Tools tab's "Get ready" hue, so the marks here match the row she tapped.
const double _kReadyHue = 28;

/// Each category's drawn mark (was `meta.icon` in `meta.color`).
const Map<ReadyCategory, IntentMark> _kCatMark = {
  ReadyCategory.mom: IntentMark.lotusMark,
  ReadyCategory.baby: IntentMark.feedMark,
  ReadyCategory.documents: IntentMark.reportPage,
  ReadyCategory.partnerExtras: IntentMark.cuppedHands,
};

// ---- shared pieces (private: the stages stay code-isolated) -----------------

/// The page title on a pushed page, announced as a heading.
Widget _pageTitle(String text) =>
    Semantics(header: true, child: Text(text, style: pregPageTitleStyle()));

/// A filled ink button at a given height (`pregFilledStyle`).
ButtonStyle _filled({double height = 52}) => pregFilledStyle().copyWith(
      minimumSize: WidgetStatePropertyAll(Size.fromHeight(height)),
    );

/// An outlined ink stadium: the second action.
ButtonStyle _outlined({double height = 48}) => OutlinedButton.styleFrom(
      minimumSize: Size.fromHeight(height),
      foregroundColor: kPvInk,
      side: const BorderSide(color: kPvLine, width: 1.5),
      shape: const StadiumBorder(),
    );

TextStyle _buttonText() => pvManrope(fontSize: 14.5, fontWeight: FontWeight.w800);

/// A sheet's or a dialog's title.
TextStyle _sheetTitleStyle() => pvFraunces(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.4,
    color: pvStorePalette.ink1);

void _push(BuildContext c, Widget s) =>
    Navigator.of(c).push(MaterialPageRoute<void>(builder: (_) => s));

/// A representative bag section for custom items added inside a readiness category.
BagCategory _bagCatFor(ReadyCategory c) => switch (c) {
      ReadyCategory.mom => BagCategory.comfort,
      ReadyCategory.baby => BagCategory.baby,
      ReadyCategory.documents => BagCategory.documents,
      ReadyCategory.partnerExtras => BagCategory.custom,
    };

// ---- readiness maths (a thin view over the two stores) ----------------------
class _Readiness {
  _Readiness(this.bag, this.ctx);
  final HospitalBagV2Store bag;
  final ReadyBirthContextStore ctx;

  late final Set<String> _provided = providedItemIds(ctx.hospitalProvides);

  /// Everything still in the bag, minus what the hospital provides.
  List<BagItem> get applicable =>
      bag.active.where((i) => !_provided.contains(i.id)).toList();

  List<BagItem> inCat(ReadyCategory c) =>
      applicable.where((i) => readyCategoryOf(i) == c).toList();
  int totalIn(ReadyCategory c) => inCat(c).length;
  int packedIn(ReadyCategory c) => inCat(c).where((i) => i.packed).length;
  int remainingIn(ReadyCategory c) => totalIn(c) - packedIn(c);

  int get total => applicable.length;
  int get packed => applicable.where((i) => i.packed).length;
  int get remaining => total - packed;
  double get pct => total == 0 ? 0 : packed / total;
  int get percent => (pct * 100).round();
  bool get isReady => total > 0 && remaining == 0;

  /// The single next step for the hero.
  String focusLine() {
    final left = kGuidedOrder.where((c) => remainingIn(c) > 0).toList();
    if (left.isEmpty) return S.now.rfbFullyPacked;
    // Lowercasing is an English habit — Devanagari has no case, and the
    // category name reads correctly as-is in Hindi.
    final name = kReadyCatMeta[left.first]!.label;
    return left.length == 1
        ? S.now.rfbOnlyLeft(name.now, name.en.toLowerCase())
        : S.now.rfbNextUp(name.now, name.en.toLowerCase());
  }
}


// ===========================================================================
//  Dashboard
// ===========================================================================
class ReadyForBirthScreen extends StatefulWidget {
  const ReadyForBirthScreen({super.key, required this.controller});
  final PregnancyController controller;

  @override
  State<ReadyForBirthScreen> createState() => _ReadyForBirthScreenState();
}

class _ReadyForBirthScreenState extends State<ReadyForBirthScreen> {
  final _bag = HospitalBagV2Store.instance;
  final _ctx = ReadyBirthContextStore.instance;
  bool _booting = true;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    // Defensive: a store/cloud hiccup must never leave the bag stuck loading.
    try {
      await _bag.init();
    } catch (_) {/* keep going with whatever loaded */}
    try {
      await _ctx.init();
    } catch (_) {/* defaults */}
    // First open: generate a smart default bag so the dashboard is alive at once
    // (no checklist onboarding wall).
    if (!_bag.onboarded) {
      try {
        await _bag.createBag(generateDefaultBag(_ctx.delivery), _ctx.delivery);
      } catch (_) {/* best-effort */}
    }
    if (mounted) setState(() => _booting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        // One ParentVeda: the title is the serif at the top of the page; the
        // app bar keeps the way back and the two controls. Kept for revert:
        // title: Text(S.now.uiReadyBirth),
        actions: [
          IconButton(
            tooltip: S.now.uiPersonalise,
            icon: const Icon(Icons.tune_rounded),
            onPressed: _booting ? null : () => _openPersonalize(context, _ctx),
          ),
          IconButton(
            tooltip: S.now.uiStartAgain2,
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _booting ? null : _confirmRestart,
          ),
        ],
      ),
      bottomNavigationBar: _booting ? null : _labourBar(),
      body: _booting
          ? const Center(child: CircularProgressIndicator())
          : AnimatedBuilder(
              animation: Listenable.merge([_bag, _ctx]),
              builder: (context, _) {
                final r = _Readiness(_bag, _ctx);
                return ListView(
                  padding: const EdgeInsets.fromLTRB(18, 4, 18, 28),
                  children: [
                    _pageTitle(S.now.uiReadyBirth),
                    const SizedBox(height: 14),
                    _hero(r),
                    const SizedBox(height: 12),
                    _packTogetherButton(r),
                    const SizedBox(height: 12),
                    ..._insightCards(r),
                    const SizedBox(height: 20),
                    // Kept for revert: Text(uiFourSimpleParts, titleMedium) with
                    // uiTapAnyOneContinue in bodySmall under it.
                    PregSectionHeading(S.now.uiFourSimpleParts,
                        lead: S.now.uiTapAnyOneContinue),
                    const SizedBox(height: 12),
                    // Kept for revert: one outlined card per category with its
                    // icon in `meta.color`. They open somewhere, so they are
                    // rows with drawn marks in one white card.
                    PregRowCard(children: [
                      for (final c in kReadyOrder) _categoryRow(r, c),
                    ]),
                  ],
                );
              },
            ),
    );
  }

  // ---- hero ---------------------------------------------------------------
  // Kept for revert: a grey-to-pink gradient card (0xFFF3F2F4 to 0xFFFDF3F5,
  // radius 26) with the week eyebrow in AppTheme.primary. A white card.
  Widget _hero(_Readiness r) {
    final p = pvStorePalette;
    final w = widget.controller.currentWeek;
    final due = widget.controller.isDueDateSet ? widget.controller.daysToDueDate : null;
    final dueLine = due == null
        ? null
        : (due > 0
            ? S.now.rfbDaysToDue(due)
            : (due == 0 ? S.now.rfbDueToday : S.now.rfbPastDue));
    return PregCard(
      padding: const EdgeInsets.all(18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(S.now.rfbWeekCaps(w).toUpperCase(), style: pregGroupLabelStyle()),
        const SizedBox(height: 10),
        Row(children: [
          _ring(r.percent, r.isReady),
          const SizedBox(width: 18),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(r.isReady ? S.now.rfbReadyForBirth : S.now.rfbGettingReady,
                  style: pvFraunces(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      height: 1.1,
                      letterSpacing: -0.4,
                      color: p.ink1)),
              const SizedBox(height: 6),
              Text(r.focusLine(),
                  style: pvManrope(fontSize: 13.5, height: 1.4, color: p.ink2)),
              const SizedBox(height: 10),
              Row(children: [
                _chip(Icons.timelapse_rounded,
                    r.remaining == 0 ? S.now.rfbAllDone : S.now.rfbMinLeft(estMinutesFor(r.remaining))),
                if (dueLine != null) ...[
                  const SizedBox(width: 8),
                  Flexible(child: _chip(Icons.event_rounded, dueLine)),
                ],
              ]),
            ]),
          ),
        ]),
      ]),
    );
  }

  // Kept for revert: the arc was AppTheme.primary (tertiary500 once ready).
  Widget _ring(int percent, bool ready) {
    final p = pvStorePalette;
    return SizedBox(
      width: 92,
      height: 92,
      child: CustomPaint(
        painter: _RingPainter(percent / 100, kPvInk, p.surfaceAlt),
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('$percent%',
                style: pvManrope(
                    fontSize: 20, fontWeight: FontWeight.w800, color: p.ink1)),
            Text(S.now.uiReady, style: pvManrope(fontSize: 11.5, color: p.ink3)),
          ]),
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String label) {
    final p = pvStorePalette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: kPvLine),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        // Kept for revert: the glyph in AppTheme.primary.
        Icon(icon, size: 13, color: p.ink2),
        const SizedBox(width: 5),
        Flexible(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: pvManrope(fontSize: 11.5, fontWeight: FontWeight.w700, color: p.ink2))),
      ]),
    );
  }

  // ---- pack together CTA --------------------------------------------------
  Widget _packTogetherButton(_Readiness r) {
    final p = pvStorePalette;
    if (r.isReady) {
      // Kept for revert: a brown-tinted block (tertiary50 / tertiary200) with
      // the words in tertiary900. A white card, the tick in the ink.
      return SizedBox(
        width: double.infinity,
        child: PregCard(
          padding: const EdgeInsets.all(18),
          child: Row(children: [
            const Icon(Icons.check_circle_rounded, color: kPvInk),
            const SizedBox(width: 12),
            Expanded(
              child: Text(S.now.uiEverythingPackedIfBaby,
                  style: pvManrope(fontSize: 14, height: 1.45, color: p.ink1)),
            ),
          ]),
        ),
      );
    }
    return FilledButton(
      onPressed: () => _push(context, _GuidedPackingScreen(controller: widget.controller)),
      // Kept for revert: backgroundColor: AppTheme.primary, radius 16.
      style: _filled(height: 56),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.auto_awesome_rounded, size: 20),
          const SizedBox(width: 10),
          Text(S.now.uiLetSPackTogether,
              style: pvManrope(fontSize: 15.5, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(width: 8),
          Text(S.now.rfbMin(estMinutesFor(r.remaining)),
              style: pvManrope(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.85))),
        ]),
      ),
    );
  }

  // ---- insight cards ------------------------------------------------------
  // Kept for revert: each insight on its own grey block (neutral50) with the
  // glyph in AppTheme.primary. One white card with hairlines between now.
  List<Widget> _insightCards(_Readiness r) {
    final p = pvStorePalette;
    final insights = readyInsights(
      week: widget.controller.currentWeek,
      delivery: _ctx.delivery,
      season: _ctx.season,
      twins: _ctx.twins,
      hospitalProvides: _ctx.hospitalProvides,
    ).take(3).toList();
    if (insights.isEmpty) return const [];
    return [
      PregCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(children: [
          for (var i = 0; i < insights.length; i++) ...[
            if (i > 0) const Divider(height: 1, thickness: 1, color: kPvLine),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 11),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(insights[i].icon, size: 18, color: p.ink2),
                const SizedBox(width: 12),
                Expanded(child: Text(insights[i].text,
                    style: pvManrope(fontSize: 13.5, height: 1.45, color: p.ink1))),
              ]),
            ),
          ],
        ]),
      ),
    ];
  }

  // ---- category row -------------------------------------------------------
  Widget _categoryRow(_Readiness r, ReadyCategory c) {
    final p = pvStorePalette;
    final meta = kReadyCatMeta[c]!;
    final total = r.totalIn(c);
    final packed = r.packedIn(c);
    final remaining = total - packed;
    final done = total > 0 && remaining == 0;
    return InkWell(
      onTap: () => _push(context, _CategoryScreen(controller: widget.controller, category: c)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
        child: Row(children: [
          PvMarkWell(p: p, hue: _kReadyHue, size: 44, mark: _kCatMark[c]),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(meta.label.now,
                  style: pvManrope(
                      fontSize: 14.5, fontWeight: FontWeight.w700, height: 1.25, color: p.ink1)),
              const SizedBox(height: 2),
              Text(done ? S.now.rfbAllPacked : S.now.rfbPackedToGo(packed, remaining),
                  style: pvManrope(fontSize: 12.5, height: 1.35, color: p.ink3)),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: total == 0 ? 0 : packed / total,
                  minHeight: 4,
                  backgroundColor: p.surfaceAlt,
                  // Kept for revert: meta.color (tertiary500 once done).
                  valueColor: const AlwaysStoppedAnimation(kPvInk),
                ),
              ),
            ]),
          ),
          const SizedBox(width: 10),
          Icon(done ? Icons.check_circle_rounded : Icons.chevron_right_rounded,
              size: done ? 22 : 20, color: done ? kPvInk : p.ink3),
        ]),
      ),
    );
  }

  // ---- persistent "Labour started?" --------------------------------------
  // Kept for revert: a coral-tinted outlined button (secondary50 fill,
  // secondary200 edge, secondary700 words). White with the ink edge; the bell
  // keeps the one rose accent, because this is the urgent way out.
  Widget _labourBar() => SafeArea(
        minimum: const EdgeInsets.fromLTRB(18, 0, 18, 12),
        child: OutlinedButton(
          onPressed: () => _push(context, _EmergencyScreen(controller: widget.controller)),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            foregroundColor: kPvInk,
            backgroundColor: Colors.white,
            side: const BorderSide(color: kPvInk, width: 1.5),
            shape: const StadiumBorder(),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.notifications_active_outlined, size: 19, color: kPvUrgentInk),
            const SizedBox(width: 10),
            Text(S.now.uiLabourStarted, style: _buttonText()),
          ]),
        ),
      );

  void _confirmRestart() {
    final p = pvStorePalette;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(S.now.uiStartAgain,
            style: pvFraunces(fontSize: 19, fontWeight: FontWeight.w600, color: p.ink1)),
        content: Text(
            S.now.uiClearsEverythingPackedItems,
            style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink2)),
        actions: [
          TextButton(
              style: TextButton.styleFrom(foregroundColor: p.ink1),
              onPressed: () => Navigator.of(ctx).pop(), child: Text(S.now.uiCancel3)),
          FilledButton(
            // Kept for revert: backgroundColor: AppTheme.primary.
            style: pregFilledStyle(),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _bag.createBag(generateDefaultBag(_ctx.delivery), _ctx.delivery);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(S.now.uiFreshStartFullList)));
              }
            },
            child: Text(S.now.uiStartAgain2),
          ),
        ],
      ),
    );
  }

  void _openPersonalize(BuildContext context, ReadyBirthContextStore ctx) =>
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
        builder: (_) => _PersonalizeSheet(ctx: ctx),
      );
}

// ===========================================================================
//  Shared: an editorial item card (used by Category + Guided flows).
// ===========================================================================
class _ItemCard extends StatelessWidget {
  const _ItemCard({required this.item, required this.lang, required this.onToggle, this.onNeedOne, this.onNotNeeded});
  final BagItem item;
  final AppLanguage lang;
  final VoidCallback onToggle;
  final VoidCallback? onNeedOne;
  final VoidCallback? onNotNeeded;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    final packed = item.packed;
    final showActions = !packed && (onNeedOne != null || onNotNeeded != null);
    // Kept for revert: a packed card took a brown edge (tertiary200).
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: PregCard(
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.name.of(lang),
                  style: pvManrope(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                      decoration: packed ? TextDecoration.lineThrough : null,
                      color: packed ? p.ink3 : p.ink1)),
              const SizedBox(height: 4),
              Text(whyPack(item), style: pvManrope(fontSize: 12.5, height: 1.4, color: p.ink2)),
              if (showActions) ...[
                const SizedBox(height: 10),
                Wrap(spacing: 16, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
                  if (onNeedOne != null)
                    InkWell(
                      onTap: onNeedOne,
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        // Kept for revert: the words and chevron in AppTheme.primary.
                        Text(S.now.uiNeedOne,
                            style: pvManrope(fontSize: 12.5, fontWeight: FontWeight.w800, color: p.ink1)),
                        Icon(Icons.chevron_right_rounded, size: 16, color: p.ink1),
                      ]),
                    ),
                  if (onNotNeeded != null)
                    InkWell(
                      onTap: onNotNeeded,
                      child: Text(S.now.uiIDonTNeed,
                          style: pvManrope(fontSize: 12.5, fontWeight: FontWeight.w600, color: p.ink3)),
                    ),
                ]),
              ],
            ]),
          ),
          const SizedBox(width: 12),
          _PackToggle(packed: packed, onTap: onToggle),
        ]),
      ),
    );
  }
}

class _PackToggle extends StatelessWidget {
  const _PackToggle({required this.packed, required this.onTap});
  final bool packed;
  final VoidCallback onTap;
  // Kept for revert: filled and edged in tertiary500 when packed. The ink.
  @override
  Widget build(BuildContext context) => Semantics(
        checked: packed,
        button: true,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 30, height: 30,
            decoration: BoxDecoration(
              color: packed ? kPvInk : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(color: packed ? kPvInk : pvStorePalette.ink3, width: 2),
            ),
            child: packed ? const Icon(Icons.check_rounded, size: 18, color: Colors.white) : null,
          ),
        ),
      );
}

// ===========================================================================
//  Category detail
// ===========================================================================
class _CategoryScreen extends StatefulWidget {
  const _CategoryScreen({required this.controller, required this.category});
  final PregnancyController controller;
  final ReadyCategory category;
  @override
  State<_CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<_CategoryScreen> {
  final _bag = HospitalBagV2Store.instance;
  final _ctx = ReadyBirthContextStore.instance;

  @override
  Widget build(BuildContext context) {
    final meta = kReadyCatMeta[widget.category]!;
    final p = pvStorePalette;
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      // Kept for revert: appBar: AppBar(title: Text(meta.label.now)).
      appBar: AppBar(),
      body: AnimatedBuilder(
        animation: Listenable.merge([_bag, _ctx]),
        builder: (context, _) {
          final r = _Readiness(_bag, _ctx);
          final items = r.inCat(widget.category);
          final packed = items.where((i) => i.packed).length;
          final provided = _bag.active
              .where((i) => readyCategoryOf(i) == widget.category && providedItemIds(_ctx.hospitalProvides).contains(i.id))
              .toList();
          final notNeeded = _bag.maybeLater.where((i) => readyCategoryOf(i) == widget.category).toList();
          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 32),
            children: [
              // small header: the mark she tapped, the title, the blurb.
              // Kept for revert: meta.icon in meta.color on a 14% well.
              Row(children: [
                PvMarkWell(p: p, hue: _kReadyHue, size: 48, mark: _kCatMark[widget.category]),
                const SizedBox(width: 14),
                Expanded(child: _pageTitle(meta.label.now)),
              ]),
              const SizedBox(height: 12),
              Text(meta.blurb.now, style: pvManrope(fontSize: 13.5, height: 1.45, color: p.ink2)),
              const SizedBox(height: 2),
              Text(S.now.rfbPackedOf(packed, items.length),
                  style: pvManrope(fontSize: 12.5, fontWeight: FontWeight.w700, color: p.ink3)),
              const SizedBox(height: 18),
              for (final i in items)
                _ItemCard(
                  item: i,
                  lang: widget.controller.language,
                  onToggle: () => _bag.togglePacked(i.id),
                  onNeedOne: bagIsSellable(i.id, isCustom: i.isCustom)
                      ? () => _push(context, _BagOptionsScreen(controller: widget.controller, itemId: i.id))
                      : null,
                  onNotNeeded: () => _bag.moveToMaybeLater(i.id),
                ),
              if (notNeeded.isNotEmpty) ...[
                const SizedBox(height: 14),
                // Kept for revert: Text(uiNotUs, titleSmall) and the lead in
                // bodySmall; each item on a grey block (surfaceContainer).
                // One child with its card, so the heading is never built
                // without the items it heads.
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  PregSectionHeading(S.now.uiNotUs, lead: S.now.uiSetAsideNotCounted),
                  const SizedBox(height: 10),
                  PregCard(
                    padding: const EdgeInsets.fromLTRB(16, 2, 6, 2),
                    child: Column(children: [
                      for (var k = 0; k < notNeeded.length; k++) ...[
                        if (k > 0) const Divider(height: 1, thickness: 1, color: kPvLine),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(children: [
                            Expanded(child: Text(notNeeded[k].name.of(widget.controller.language),
                                style: pvManrope(fontSize: 13.5, color: p.ink2))),
                            TextButton(
                              onPressed: () => _bag.restore(notNeeded[k].id),
                              // Kept for revert: foregroundColor: AppTheme.primary.
                              style: TextButton.styleFrom(foregroundColor: kPvInk, visualDensity: VisualDensity.compact),
                              child: Text(S.now.uiAddBack,
                                  style: pvManrope(fontSize: 13, fontWeight: FontWeight.w800)),
                            ),
                          ]),
                        ),
                      ],
                    ]),
                  ),
                ]),
                const SizedBox(height: 14),
              ],
              if (provided.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(S.now.uiHospitalProvidesTheseNo,
                    style: pvManrope(fontSize: 12.5, fontWeight: FontWeight.w700, color: p.ink3)),
                const SizedBox(height: 8),
                for (final i in provided)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(children: [
                      Icon(Icons.local_hospital_outlined, size: 16, color: p.ink3),
                      const SizedBox(width: 10),
                      Expanded(child: Text(i.name.of(widget.controller.language),
                          style: pvManrope(fontSize: 13.5, color: p.ink3))),
                    ]),
                  ),
              ],
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _addOwn,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(S.now.uiAddOwn, style: _buttonText()),
                // Kept for revert: foregroundColor: AppTheme.primary, radius 14.
                style: _outlined(),
              ),
            ],
          );
        },
      ),
    );
  }

  void _addOwn() {
    final ctrl = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 16, 22, 22),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: kPvLine, borderRadius: BorderRadius.circular(99)))),
              const SizedBox(height: 16),
              Text(S.now.uiAddOwn, style: _sheetTitleStyle()),
              const SizedBox(height: 12),
              TextField(
                controller: ctrl,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: S.now.uiWhatWouldLikeAdd,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: kPvLine)),
                ),
              ),
              const SizedBox(height: 14),
              FilledButton(
                onPressed: () {
                  final name = ctrl.text.trim();
                  if (name.isNotEmpty) _bag.addCustomItem(name, _bagCatFor(widget.category));
                  Navigator.of(ctx).pop();
                },
                // Kept for revert: backgroundColor: AppTheme.primary.
                style: _filled(height: 50),
                child: Text(S.now.uiAddMyBag, style: _buttonText()),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
//  Guided Packing - one small win at a time.
// ===========================================================================
class _GuidedPackingScreen extends StatefulWidget {
  const _GuidedPackingScreen({required this.controller});
  final PregnancyController controller;
  @override
  State<_GuidedPackingScreen> createState() => _GuidedPackingScreenState();
}

class _GuidedPackingScreenState extends State<_GuidedPackingScreen> {
  final _bag = HospitalBagV2Store.instance;
  final _ctx = ReadyBirthContextStore.instance;
  int _step = 0;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    // Only the categories that still have something to do.
    final r0 = _Readiness(_bag, _ctx);
    final steps = kGuidedOrder.where((c) => r0.totalIn(c) > 0).toList();
    if (steps.isEmpty || _step >= steps.length) return _done();

    final cat = steps[_step];
    final meta = kReadyCatMeta[cat]!;
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: Text(S.now.rfbStepOf(_step + 1, steps.length),
            style: pvManrope(fontSize: 14, fontWeight: FontWeight.w700, color: p.ink2)),
      ),
      body: AnimatedBuilder(
        animation: _bag,
        builder: (context, _) {
          final r = _Readiness(_bag, _ctx);
          final items = r.inCat(cat);
          final remaining = items.where((i) => !i.packed).length;
          return Column(children: [
            // progress segments. Kept for revert: done in tertiary500, the
            // current one in meta.color, the rest surfaceContainerHigh.
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 8),
              child: Row(children: [
                for (int i = 0; i < steps.length; i++) ...[
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: i <= _step ? kPvInk : p.surfaceAlt,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  if (i != steps.length - 1) const SizedBox(width: 6),
                ],
              ]),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
                children: [
                  Row(children: [
                    // Kept for revert: meta.icon in meta.color on a 14% well.
                    PvMarkWell(p: p, hue: _kReadyHue, size: 48, mark: _kCatMark[cat]),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        _pageTitle(meta.label.now),
                        const SizedBox(height: 2),
                        Text(remaining == 0 ? S.now.rfbAllDoneHere : S.now.rfbLeftToPack(remaining),
                            style: pvManrope(fontSize: 12.5, color: p.ink3)),
                      ]),
                    ),
                  ]),
                  const SizedBox(height: 18),
                  for (final i in items)
                    _ItemCard(item: i, lang: widget.controller.language, onToggle: () => _bag.togglePacked(i.id)),
                ],
              ),
            ),
            SafeArea(
              minimum: const EdgeInsets.fromLTRB(18, 0, 18, 12),
              child: FilledButton(
                onPressed: () => setState(() => _step++),
                // Kept for revert: tertiary500 when the step was done,
                // AppTheme.primary otherwise; radius 16.
                style: _filled(height: 54),
                child: Text(
                  _step == steps.length - 1 ? S.now.rfbFinish : (remaining == 0 ? S.now.rfbDoneNext : 'Next'),
                  style: pvManrope(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ),
            ),
          ]);
        },
      ),
    );
  }

  Widget _done() {
    final p = pvStorePalette;
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            // Kept for revert: a brown-tinted disc (tertiary50) with a
            // tertiary600 tick. The drawn mark in the tool's tint.
            PvMarkWell(p: p, hue: _kReadyHue, size: 88, mark: IntentMark.checkMark),
            const SizedBox(height: 22),
            Text(S.now.uiSBigStepDone, style: pregPageTitleStyle(), textAlign: TextAlign.center),
            const SizedBox(height: 10),
            Text(S.now.uiVeMovedThroughEverything,
                style: pvManrope(fontSize: 14, height: 1.5, color: p.ink2), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              // Kept for revert: backgroundColor: AppTheme.primary.
              style: pregFilledStyle().copyWith(
                  minimumSize: const WidgetStatePropertyAll(Size(200, 52))),
              child: Text(S.now.uiBackMyReadiness, style: _buttonText()),
            ),
          ]),
        ),
      ),
    );
  }
}

// ===========================================================================
//  Emergency Mode - calm, not alarming.
// ===========================================================================
class _EmergencyScreen extends StatelessWidget {
  const _EmergencyScreen({required this.controller});
  final PregnancyController controller;
  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      // Kept for revert: appBar: AppBar(title: Text(S.now.uiLabourStarted)).
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 32),
        children: [
          _pageTitle(S.now.uiLabourStarted),
          const SizedBox(height: 16),
          // Kept for revert: these two lines sat on a coral block
          // (secondary50 / secondary100, radius 22) in secondary900. The same
          // two lines on the page, the first one first: breathe, then call.
          Text(S.now.uiFirstTakeBreath,
              style: pvFraunces(
                  fontSize: 21, fontWeight: FontWeight.w600, height: 1.25, color: p.ink1)),
          const SizedBox(height: 8),
          Text(S.now.uiHaveTimeCallDoctor,
              style: pvManrope(fontSize: 15, height: 1.5, fontWeight: FontWeight.w600, color: p.ink1)),
          const SizedBox(height: 26),
          // Kept for revert: Text(uiTakeTheseFirst, titleMedium).
          PregSectionHeading(S.now.uiTakeTheseFirst),
          const SizedBox(height: 12),
          // Kept for revert: one outlined card per item, the glyph in
          // AppTheme.primary on a grey well. One card, hairlines, ink glyphs.
          PregCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: Column(children: [
              for (var i = 0; i < kEmergencyGrab.length; i++) ...[
                if (i > 0) const Divider(height: 1, thickness: 1, color: kPvLine),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Row(children: [
                    Icon(kEmergencyGrab[i].icon, size: 22, color: p.ink1),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(kEmergencyGrab[i].title.now,
                            style: pvManrope(fontSize: 14.5, fontWeight: FontWeight.w700, color: p.ink1)),
                        const SizedBox(height: 2),
                        Text(kEmergencyGrab[i].sub.now,
                            style: pvManrope(fontSize: 12.5, height: 1.4, color: p.ink2)),
                      ]),
                    ),
                  ]),
                ),
              ],
            ]),
          ),
          const SizedBox(height: 22),
          // Kept for revert: a brown-tinted block (tertiary50) with the car in
          // tertiary600. The closing line on the page, in the ink.
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.directions_car_outlined, size: 22, color: p.ink1),
            const SizedBox(width: 12),
            Expanded(child: Text(S.now.uiThenLeaveHospitalVe,
                style: pvManrope(fontSize: 15, height: 1.45, fontWeight: FontWeight.w700, color: p.ink1))),
          ]),
        ],
      ),
    );
  }
}

// ===========================================================================
//  Personalise sheet
// ===========================================================================
class _PersonalizeSheet extends StatefulWidget {
  const _PersonalizeSheet({required this.ctx});
  final ReadyBirthContextStore ctx;
  @override
  State<_PersonalizeSheet> createState() => _PersonalizeSheetState();
}

class _PersonalizeSheetState extends State<_PersonalizeSheet> {
  ReadyBirthContextStore get _ctx => widget.ctx;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: kPvLine, borderRadius: BorderRadius.circular(99)))),
          const SizedBox(height: 16),
          Text(S.now.uiPersonaliseBag, style: _sheetTitleStyle()),
          const SizedBox(height: 4),
          Text(S.now.uiFewDetailsMakeSuggestions, style: pvManrope(fontSize: 12.5, height: 1.45, color: p.ink2)),
          const SizedBox(height: 20),

          _label(S.now.rfbDeliveryType),
          Row(children: [
            _pick(S.now.rfbNotSure, _ctx.delivery == DeliveryType.unsure, () => _set(() => _ctx.setDelivery(DeliveryType.unsure))),
            const SizedBox(width: 8),
            _pick('Vaginal', _ctx.delivery == DeliveryType.vaginal, () => _set(() => _ctx.setDelivery(DeliveryType.vaginal))),
            const SizedBox(width: 8),
            _pick('C-section', _ctx.delivery == DeliveryType.csection, () => _set(() => _ctx.setDelivery(DeliveryType.csection))),
          ]),
          const SizedBox(height: 18),

          _label(S.now.rfbSeasonOfDue),
          Wrap(spacing: 8, runSpacing: 8, children: [
            _pick('Auto', _ctx.seasonOverride == null, () => _set(() => _ctx.setSeasonOverride(null)), expand: false),
            for (final s in Season.values)
              _pick(seasonLabel(s), _ctx.seasonOverride == s, () => _set(() => _ctx.setSeasonOverride(s)), expand: false),
          ]),
          const SizedBox(height: 18),

          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(S.now.uiExpectingTwins,
                  style: pvManrope(fontSize: 14, fontWeight: FontWeight.w700, color: p.ink1)),
              Text(S.now.uiWeLlSuggestFew, style: pvManrope(fontSize: 12.5, height: 1.4, color: p.ink2)),
            ])),
            Switch(value: _ctx.twins, onChanged: (v) => _set(() => _ctx.setTwins(v))), // Kept for revert (2026-09-28, one black switch app-wide): activeThumbColor: AppTheme.primary
          ]),
          const SizedBox(height: 8),

          _label(S.now.rfbHospitalProvides),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final e in kHospitalProvidableLabel.entries)
              _pick(e.value.now, _ctx.providesFor(e.key), () => _set(() => _ctx.toggleProvides(e.key)), expand: false),
          ]),
          const SizedBox(height: 22),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            // Kept for revert: backgroundColor: AppTheme.primary.
            style: _filled(height: 50),
            child: Text(S.now.uiDone, style: _buttonText()),
          ),
        ]),
      ),
    );
  }

  void _set(VoidCallback f) { f(); setState(() {}); }

  Widget _label(String s) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(s,
            style: pvManrope(fontSize: 13, fontWeight: FontWeight.w800, color: pvStorePalette.ink1)),
      );

  // Kept for revert: a chosen pill was filled and edged in AppTheme.primary,
  // radius 12. The one pill: white with the hairline, the ink when chosen.
  Widget _pick(String label, bool on, VoidCallback onTap, {bool expand = true}) {
    final chip = Semantics(
      button: true,
      selected: on,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: on ? kPvInk : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: on ? kPvInk : kPvLine, width: 1.5),
          ),
          child: Text(label,
              style: pvManrope(
                  fontSize: 13,
                  fontWeight: on ? FontWeight.w800 : FontWeight.w600,
                  color: on ? Colors.white : pvStorePalette.ink1)),
        ),
      ),
    );
    return expand ? Expanded(child: chip) : chip;
  }
}

// ===========================================================================
//  "Need one?" — the full options page for a bag item (all choices, our-picks
//  + also-elsewhere, with the ParentVeda why/consider trust layer). Mirrors the
//  app's product page, scoped to one item (e.g. every water bottle option).
// ===========================================================================
class _BagOptionsScreen extends StatefulWidget {
  const _BagOptionsScreen({required this.controller, required this.itemId});
  final PregnancyController controller;
  final String itemId;
  @override
  State<_BagOptionsScreen> createState() => _BagOptionsScreenState();
}

class _BagOptionsScreenState extends State<_BagOptionsScreen> {
  final _bag = HospitalBagV2Store.instance;

  AppLanguage get _lang => widget.controller.language;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    final name = _bag.byId(widget.itemId)?.name.of(_lang) ?? S.now.rfbOptions;
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      // Kept for revert: appBar: AppBar(title: Text(name)).
      appBar: AppBar(),
      body: AnimatedBuilder(
        animation: _bag,
        builder: (context, _) {
          final item = _bag.byId(widget.itemId);
          if (item == null) return const SizedBox.shrink();
          final products = bagProductsFor(item.id, isCustom: item.isCustom);
          final picks = products.where((p) => !p.isAffiliate).toList();
          final elsewhere = products.where((p) => p.isAffiliate).toList();
          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 32),
            children: [
              _pageTitle(name),
              const SizedBox(height: 16),
              // how-to-choose intro. Kept for revert: a grey block (neutral50).
              SizedBox(
                width: double.infinity,
                child: PregCard(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(S.now.uiHowChoose,
                        style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w800, color: p.ink1)),
                    const SizedBox(height: 6),
                    Text(S.now.rfbWhyThenPicks(whyPack(item)),
                        style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink2)),
                  ]),
                ),
              ),
              const SizedBox(height: 24),
              if (picks.isNotEmpty) ...[
                // Kept for revert: Text(uiOurPicks, titleMedium).
                PregSectionHeading(S.now.uiOurPicks),
                const SizedBox(height: 12),
                for (final p in picks) _optionCard(item, p),
              ],
              if (elsewhere.isNotEmpty) ...[
                const SizedBox(height: 12),
                // Kept for revert: Text(uiAlsoAvailableElsewhere, titleMedium)
                // with uiPreferStoreKnowThese in bodySmall under it.
                PregSectionHeading(S.now.uiAlsoAvailableElsewhere,
                    lead: S.now.uiPreferStoreKnowThese),
                const SizedBox(height: 12),
                for (final p in elsewhere) _optionCard(item, p),
              ],
              const SizedBox(height: 10),
              const Divider(height: 1, thickness: 1, color: kPvLine),
              const SizedBox(height: 16),
              // Kept for revert: FilledButton.tonal (the scheme's coral
              // secondaryContainer on a pregnancy screen). The second action is
              // the outlined ink stadium.
              OutlinedButton(
                onPressed: () {
                  _bag.setStatus(item.id, BagItemStatus.have);
                  Navigator.of(context).pop();
                },
                style: _outlined(height: 50),
                child: Text(S.now.uiIVeAlreadyGot, style: _buttonText()),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  _bag.moveToMaybeLater(item.id);
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(foregroundColor: p.ink2),
                child: Text(S.now.uiIDonTNeed,
                    style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w700)),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _optionCard(BagItem item, BagProduct p) {
    final pal = pvStorePalette;
    final affiliate = p.isAffiliate;
    final selected = affiliate
        ? (item.status == BagItemStatus.buyElse && item.store == p.store)
        : (item.status == BagItemStatus.buyVeda && item.selectedProductId == p.id);
    void onTap() {
      if (affiliate) {
        _bag.setBuyElse(item.id, store: p.store, link: p.link, price: p.price);
        if (p.link.isNotEmpty) {
          // NATIVE DISCOVERY (Brand Product 14) + Commerce Integration.
          //
          // This used to launchUrl() straight to the retailer, which broke two
          // rules at once: a product named inside ParentVeda content should
          // reach its Product GUIDE first where one exists (education before
          // commerce), and every outbound click should go through openOutbound
          // so it is tagged and attributed rather than leaving untracked.
          //
          // Old line kept for revert:
          // launchUrl(Uri.parse(p.link), mode: LaunchMode.externalApplication);
          openProductWithGuideCheck(
            context,
            id: p.id,
            name: p.name.now,
            onOpenNormal: () => openOutbound(p.link, productId: p.id),
          );
        }
      } else {
        _bag.chooseVedaProduct(item.id, productId: p.id, price: p.price);
      }
    }

    // Kept for revert: a chosen card filled grey (neutral50) with a neutral500
    // edge; a 56pt grey well held the product's emoji as its picture. No
    // placeholder pictures (rule 9), so no well; a chosen card is white with
    // the ink edge.
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: selected ? kPvInk : kPvLine, width: selected ? 1.5 : 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    if (affiliate)
                      // Kept for revert: color: AppTheme.secondary600.
                      Text(p.store, style: pvManrope(fontSize: 11.5, fontWeight: FontWeight.w800, color: pal.ink2))
                    else if (p.topPick)
                      Text(S.now.uiBestOverall, style: pvManrope(fontSize: 11.5, fontWeight: FontWeight.w800, color: pal.ink1)),
                    Text(affiliate ? S.now.rfbBuyOn(p.store) : p.name.now,
                        style: pvManrope(fontSize: 14.5, fontWeight: FontWeight.w700, height: 1.3, color: pal.ink1)),
                    const SizedBox(height: 2),
                    Text('₹${p.price}',
                        style: pvManrope(fontSize: 15, fontWeight: FontWeight.w800, color: pal.ink1)),
                  ]),
                ),
                const SizedBox(width: 10),
                // Kept for revert: open_in_new in AppTheme.secondary500.
                Icon(
                  affiliate ? Icons.open_in_new_rounded : (selected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded),
                  color: affiliate ? pal.ink2 : (selected ? kPvInk : pal.ink3),
                ),
              ]),
              if (p.why.isNotEmpty) ...[
                const SizedBox(height: 12),
                if (p.topPick)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(S.now.uiWhyWeRecommend,
                        style: pvManrope(fontSize: 12, fontWeight: FontWeight.w700, color: pal.ink2)),
                  ),
                for (final w in p.why)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      // Kept for revert: a '✓' in tertiary600.
                      Padding(
                        padding: const EdgeInsets.only(top: 2, right: 8),
                        child: Icon(Icons.check_rounded, size: 15, color: pal.ink2),
                      ),
                      Expanded(child: Text(w.now, style: pvManrope(fontSize: 13.5, height: 1.45, color: pal.ink1))),
                    ]),
                  ),
              ],
              if (p.consider.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(S.now.uiThingsConsider,
                    style: pvManrope(fontSize: 12, fontWeight: FontWeight.w700, color: pal.ink2)),
                const SizedBox(height: 6),
                for (final c in p.consider)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('•  ', style: pvManrope(fontSize: 13.5, color: pal.ink2)),
                      Expanded(child: Text(c.now, style: pvManrope(fontSize: 13.5, height: 1.45, color: pal.ink1))),
                    ]),
                  ),
              ],
            ]),
          ),
        ),
      ),
    );
  }
}

// ---- readiness ring painter -------------------------------------------------
class _RingPainter extends CustomPainter {
  _RingPainter(this.value, this.color, this.track);
  final double value; // 0..1
  final Color color;

  /// The unfilled ring. Kept for revert: AppTheme.surfaceContainerHigh.
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2 - 5;
    final bg = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    final fg = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(c, r, bg);
    canvas.drawArc(Rect.fromCircle(center: c, radius: r), -math.pi / 2, 2 * math.pi * value.clamp(0, 1), false, fg);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.value != value || old.color != color || old.track != track;
}
