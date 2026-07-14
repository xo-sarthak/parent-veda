// =============================================================================
//  Ready for Birth - the Hospital Bag, redesigned as a readiness experience
// -----------------------------------------------------------------------------
//  Rebuilt from first principles (Claude Design prompt). The mother opens this
//  and, within seconds, knows the one thing she came to learn: "If labour starts
//  today, am I ready?" No long checklist. A calm dashboard answers it — week,
//  ready status, % ready, today's focus, minutes left — over four simple
//  categories (Mom · Baby · Documents · Partner & Extras). Progressive
//  disclosure: items only appear inside a category. The primary action is
//  "Let's Pack Together" (a guided, small-wins flow); a persistent "Labour
//  started?" opens a calm emergency grab-list. Contextual ParentVeda insights
//  replace articles. Reuses the existing bag data (HospitalBagV2Store + catalogue
//  + seed); personalisation lives in ReadyBirthContextStore. Replaces the old
//  HospitalBagScreen wrapper as the live entry (old files kept for revert).
// =============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/hospital_bag_catalog.dart';
import '../../data/hospital_bag_seed.dart';
import '../../data/ready_for_birth_data.dart';
import '../../localization/app_language.dart';
import '../../services/hospital_bag_store.dart';
import '../../services/hospital_bag_v2_store.dart';
import '../../services/pregnancy_controller.dart';
import '../../services/ready_birth_context_store.dart';
import '../../theme/app_theme.dart';

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
    if (left.isEmpty) return "You're fully packed — beautifully ready.";
    if (left.length == 1) {
      return 'Only your ${kReadyCatMeta[left.first]!.label.toLowerCase()} remain.';
    }
    return 'Next up: your ${kReadyCatMeta[left.first]!.label.toLowerCase()}.';
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
        title: const Text('Ready for Birth'),
        actions: [
          IconButton(
            tooltip: 'Personalise',
            icon: const Icon(Icons.tune_rounded),
            onPressed: _booting ? null : () => _openPersonalize(context, _ctx),
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
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                  children: [
                    _hero(r),
                    const SizedBox(height: 16),
                    _packTogetherButton(r),
                    const SizedBox(height: 22),
                    ..._insightCards(r),
                    const SizedBox(height: 8),
                    Text('Four simple parts', style: _t.titleMedium),
                    const SizedBox(height: 4),
                    Text('Tap any one to continue — items only appear inside.',
                        style: _t.bodySmall?.copyWith(color: AppTheme.neutral600)),
                    const SizedBox(height: 14),
                    for (final c in kReadyOrder) ...[
                      _categoryCard(r, c),
                      const SizedBox(height: 12),
                    ],
                  ],
                );
              },
            ),
    );
  }

  TextTheme get _t => Theme.of(context).textTheme;

  // ---- hero ---------------------------------------------------------------
  Widget _hero(_Readiness r) {
    final w = widget.controller.currentWeek;
    final due = widget.controller.isDueDateSet ? widget.controller.daysToDueDate : null;
    final dueLine = due == null
        ? null
        : (due > 0
            ? '$due days to your due date'
            : (due == 0 ? 'Your due date is today' : 'A little past your due date — any day now'));
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFFF3ECFA), Color(0xFFFDF3F5)]),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('WEEK $w'.toUpperCase(),
            style: _t.labelSmall?.copyWith(color: AppTheme.primary, letterSpacing: 1.4, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        Row(children: [
          _ring(r.percent, r.isReady),
          const SizedBox(width: 18),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(r.isReady ? 'Ready for birth' : 'Getting ready',
                  style: _t.headlineSmall?.copyWith(height: 1.05)),
              const SizedBox(height: 6),
              Text(r.focusLine(),
                  style: _t.bodyMedium?.copyWith(color: AppTheme.neutral700, height: 1.4)),
              const SizedBox(height: 10),
              Row(children: [
                _chip(Icons.timelapse_rounded,
                    r.remaining == 0 ? 'All done' : '~${estMinutesFor(r.remaining)} min left'),
                if (dueLine != null) ...[
                  const SizedBox(width: 8),
                  Flexible(child: _chip(Icons.event_rounded, dueLine, soft: true)),
                ],
              ]),
            ]),
          ),
        ]),
      ]),
    );
  }

  Widget _ring(int percent, bool ready) => SizedBox(
        width: 92,
        height: 92,
        child: CustomPaint(
          painter: _RingPainter(percent / 100, ready ? AppTheme.tertiary500 : AppTheme.primary),
          child: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('$percent%',
                  style: _t.titleLarge?.copyWith(color: AppTheme.primary900, fontWeight: FontWeight.w800)),
              Text('ready', style: _t.labelSmall?.copyWith(color: AppTheme.neutral600)),
            ]),
          ),
        ),
      );

  Widget _chip(IconData icon, String label, {bool soft = false}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: soft ? Colors.white.withValues(alpha: 0.6) : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppTheme.outlineVariant),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 13, color: AppTheme.primary),
          const SizedBox(width: 5),
          Flexible(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: _t.labelSmall?.copyWith(color: AppTheme.neutral700, fontWeight: FontWeight.w600))),
        ]),
      );

  // ---- pack together CTA --------------------------------------------------
  Widget _packTogetherButton(_Readiness r) {
    if (r.isReady) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.tertiary50,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.tertiary200),
        ),
        child: Row(children: [
          Icon(Icons.check_circle_rounded, color: AppTheme.tertiary600),
          const SizedBox(width: 12),
          Expanded(
            child: Text('Everything is packed. If your baby comes tonight, you know exactly what to grab.',
                style: _t.bodyMedium?.copyWith(color: AppTheme.tertiary900, height: 1.4)),
          ),
        ]),
      );
    }
    return FilledButton(
      onPressed: () => _push(context, _GuidedPackingScreen(controller: widget.controller)),
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        backgroundColor: AppTheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.auto_awesome_rounded, size: 20),
          const SizedBox(width: 10),
          Text("Let's pack together", style: _t.titleMedium?.copyWith(color: Colors.white)),
          const SizedBox(width: 8),
          Text('~${estMinutesFor(r.remaining)} min',
              style: _t.labelMedium?.copyWith(color: Colors.white.withValues(alpha: 0.85))),
        ]),
      ),
    );
  }

  // ---- insight cards ------------------------------------------------------
  List<Widget> _insightCards(_Readiness r) {
    final insights = readyInsights(
      week: widget.controller.currentWeek,
      delivery: _ctx.delivery,
      season: _ctx.season,
      twins: _ctx.twins,
      hospitalProvides: _ctx.hospitalProvides,
    ).take(3).toList();
    return [
      for (final ins in insights) ...[
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: AppTheme.primary50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.primary100),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(ins.icon, size: 18, color: AppTheme.primary),
            const SizedBox(width: 12),
            Expanded(child: Text(ins.text,
                style: _t.bodyMedium?.copyWith(color: AppTheme.primary900, height: 1.45))),
          ]),
        ),
      ],
      const SizedBox(height: 12),
    ];
  }

  // ---- category card ------------------------------------------------------
  Widget _categoryCard(_Readiness r, ReadyCategory c) {
    final meta = kReadyCatMeta[c]!;
    final total = r.totalIn(c);
    final packed = r.packedIn(c);
    final remaining = total - packed;
    final done = total > 0 && remaining == 0;
    return InkWell(
      onTap: () => _push(context, _CategoryScreen(controller: widget.controller, category: c)),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.outlineVariant),
        ),
        child: Row(children: [
          Container(
            width: 46, height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: meta.color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(14)),
            child: Icon(meta.icon, color: meta.color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(meta.label, style: _t.titleMedium),
              const SizedBox(height: 3),
              Text(done ? 'All packed' : '$packed packed · $remaining to go',
                  style: _t.bodySmall?.copyWith(color: done ? AppTheme.tertiary600 : AppTheme.neutral600)),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: total == 0 ? 0 : packed / total,
                  minHeight: 5,
                  backgroundColor: AppTheme.surfaceContainerHigh,
                  valueColor: AlwaysStoppedAnimation(done ? AppTheme.tertiary500 : meta.color),
                ),
              ),
            ]),
          ),
          const SizedBox(width: 10),
          Icon(done ? Icons.check_circle_rounded : Icons.chevron_right_rounded,
              color: done ? AppTheme.tertiary500 : AppTheme.neutral400),
        ]),
      ),
    );
  }

  // ---- persistent "Labour started?" --------------------------------------
  Widget _labourBar() => SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        child: OutlinedButton(
          onPressed: () => _push(context, _EmergencyScreen(controller: widget.controller)),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            foregroundColor: AppTheme.secondary700,
            side: BorderSide(color: AppTheme.secondary200),
            backgroundColor: AppTheme.secondary50,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.notifications_active_rounded, size: 19, color: AppTheme.secondary600),
            const SizedBox(width: 10),
            Text('Labour started?', style: _t.titleSmall?.copyWith(color: AppTheme.secondary700)),
          ]),
        ),
      );

  void _openPersonalize(BuildContext context, ReadyBirthContextStore ctx) =>
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: AppTheme.scaffoldBackground,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
        builder: (_) => _PersonalizeSheet(ctx: ctx),
      );
}

// ===========================================================================
//  Shared: an editorial item card (used by Category + Guided flows).
// ===========================================================================
class _ItemCard extends StatelessWidget {
  const _ItemCard({required this.item, required this.lang, required this.onToggle, this.onNeedOne});
  final BagItem item;
  final AppLanguage lang;
  final VoidCallback onToggle;
  final VoidCallback? onNeedOne;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final packed = item.packed;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: packed ? AppTheme.tertiary200 : AppTheme.outlineVariant),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.name.of(lang),
                style: t.titleSmall?.copyWith(
                    decoration: packed ? TextDecoration.lineThrough : null,
                    color: packed ? AppTheme.neutral500 : AppTheme.neutral900)),
            const SizedBox(height: 4),
            Text(whyPack(item), style: t.bodySmall?.copyWith(color: AppTheme.neutral600, height: 1.4)),
            if (!packed && onNeedOne != null) ...[
              const SizedBox(height: 8),
              InkWell(
                onTap: onNeedOne,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text('Need one?', style: t.labelMedium?.copyWith(color: AppTheme.primary, fontWeight: FontWeight.w700)),
                  const Icon(Icons.chevron_right_rounded, size: 16, color: AppTheme.primary),
                ]),
              ),
            ],
          ]),
        ),
        const SizedBox(width: 12),
        _PackToggle(packed: packed, onTap: onToggle),
      ]),
    );
  }
}

class _PackToggle extends StatelessWidget {
  const _PackToggle({required this.packed, required this.onTap});
  final bool packed;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 30, height: 30,
          decoration: BoxDecoration(
            color: packed ? AppTheme.tertiary500 : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(color: packed ? AppTheme.tertiary500 : AppTheme.outline, width: 2),
          ),
          child: packed ? const Icon(Icons.check_rounded, size: 18, color: Colors.white) : null,
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
    final t = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(title: Text(meta.label)),
      body: AnimatedBuilder(
        animation: Listenable.merge([_bag, _ctx]),
        builder: (context, _) {
          final r = _Readiness(_bag, _ctx);
          final items = r.inCat(widget.category);
          final packed = items.where((i) => i.packed).length;
          final provided = _bag.active
              .where((i) => readyCategoryOf(i) == widget.category && providedItemIds(_ctx.hospitalProvides).contains(i.id))
              .toList();
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              // small header
              Row(children: [
                Container(
                  width: 42, height: 42, alignment: Alignment.center,
                  decoration: BoxDecoration(color: meta.color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(13)),
                  child: Icon(meta.icon, color: meta.color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(meta.blurb, style: t.bodyMedium?.copyWith(color: AppTheme.neutral700)),
                    const SizedBox(height: 2),
                    Text('$packed of ${items.length} packed',
                        style: t.labelMedium?.copyWith(color: AppTheme.neutral600)),
                  ]),
                ),
              ]),
              const SizedBox(height: 18),
              for (final i in items)
                _ItemCard(
                  item: i,
                  lang: widget.controller.language,
                  onToggle: () => _bag.togglePacked(i.id),
                  onNeedOne: bagIsSellable(i.id, isCustom: i.isCustom) ? () => _needOne(i) : null,
                ),
              if (provided.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text('Your hospital provides these — no need to pack',
                    style: t.labelMedium?.copyWith(color: AppTheme.neutral500)),
                const SizedBox(height: 8),
                for (final i in provided)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(children: [
                      Icon(Icons.local_hospital_outlined, size: 16, color: AppTheme.neutral400),
                      const SizedBox(width: 10),
                      Expanded(child: Text(i.name.of(widget.controller.language),
                          style: t.bodyMedium?.copyWith(color: AppTheme.neutral500))),
                    ]),
                  ),
              ],
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _addOwn,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add your own'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  foregroundColor: AppTheme.primary,
                  side: BorderSide(color: AppTheme.primary200),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _needOne(BagItem i) {
    final best = bagBestProduct(i.id, isCustom: i.isCustom);
    final t = Theme.of(context).textTheme;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.scaffoldBackground,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 22),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.outlineVariant, borderRadius: BorderRadius.circular(99)))),
            const SizedBox(height: 16),
            Text(i.name.of(widget.controller.language), style: t.titleLarge),
            const SizedBox(height: 6),
            Text(whyPack(i), style: t.bodyMedium?.copyWith(color: AppTheme.neutral600, height: 1.4)),
            const SizedBox(height: 16),
            if (best != null)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.outlineVariant)),
                child: Row(children: [
                  Text(best.emoji, style: const TextStyle(fontSize: 26)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(best.name, style: t.titleSmall),
                      if (best.why.isNotEmpty)
                        Text(best.why.first, style: t.bodySmall?.copyWith(color: AppTheme.neutral600)),
                    ]),
                  ),
                  Text('₹${best.price}', style: t.titleSmall?.copyWith(color: AppTheme.primary)),
                ]),
              ),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: () {
                _bag.setStatus(i.id, BagItemStatus.have);
                Navigator.of(ctx).pop();
              },
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50), backgroundColor: AppTheme.primary),
              child: const Text("I've got this one"),
            ),
            const SizedBox(height: 6),
            Center(child: Text('Shopping links coming soon — for now, mark what you have.',
                style: t.labelSmall?.copyWith(color: AppTheme.neutral500))),
          ]),
        ),
      ),
    );
  }

  void _addOwn() {
    final ctrl = TextEditingController();
    final t = Theme.of(context).textTheme;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.scaffoldBackground,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 16, 22, 22),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.outlineVariant, borderRadius: BorderRadius.circular(99)))),
              const SizedBox(height: 16),
              Text('Add your own', style: t.titleLarge),
              const SizedBox(height: 12),
              TextField(
                controller: ctrl,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'What would you like to add?',
                  filled: true,
                  fillColor: AppTheme.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppTheme.outlineVariant)),
                ),
              ),
              const SizedBox(height: 14),
              FilledButton(
                onPressed: () {
                  final name = ctrl.text.trim();
                  if (name.isNotEmpty) _bag.addCustomItem(name, _bagCatFor(widget.category));
                  Navigator.of(ctx).pop();
                },
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50), backgroundColor: AppTheme.primary),
                child: const Text('Add to my bag'),
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
    final t = Theme.of(context).textTheme;
    // Only the categories that still have something to do.
    final r0 = _Readiness(_bag, _ctx);
    final steps = kGuidedOrder.where((c) => r0.totalIn(c) > 0).toList();
    if (steps.isEmpty || _step >= steps.length) return _done(t);

    final cat = steps[_step];
    final meta = kReadyCatMeta[cat]!;
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: Text('Step ${_step + 1} of ${steps.length}'),
      ),
      body: AnimatedBuilder(
        animation: _bag,
        builder: (context, _) {
          final r = _Readiness(_bag, _ctx);
          final items = r.inCat(cat);
          final remaining = items.where((i) => !i.packed).length;
          return Column(children: [
            // progress dots
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Row(children: [
                for (int i = 0; i < steps.length; i++) ...[
                  Expanded(
                    child: Container(
                      height: 5,
                      decoration: BoxDecoration(
                        color: i < _step ? AppTheme.tertiary500 : (i == _step ? meta.color : AppTheme.surfaceContainerHigh),
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
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                children: [
                  Row(children: [
                    Container(
                      width: 46, height: 46, alignment: Alignment.center,
                      decoration: BoxDecoration(color: meta.color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(14)),
                      child: Icon(meta.icon, color: meta.color),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(meta.label, style: t.titleLarge),
                        Text(remaining == 0 ? 'All done here' : '$remaining left to pack',
                            style: t.bodySmall?.copyWith(color: AppTheme.neutral600)),
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
              minimum: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: FilledButton(
                onPressed: () => setState(() => _step++),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  backgroundColor: remaining == 0 ? AppTheme.tertiary500 : AppTheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  _step == steps.length - 1 ? 'Finish' : (remaining == 0 ? 'Done · next' : 'Next'),
                  style: t.titleMedium?.copyWith(color: Colors.white),
                ),
              ),
            ),
          ]);
        },
      ),
    );
  }

  Widget _done(TextTheme t) => Scaffold(
        backgroundColor: AppTheme.scaffoldBackground,
        appBar: AppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 88, height: 88, alignment: Alignment.center,
                decoration: BoxDecoration(color: AppTheme.tertiary50, shape: BoxShape.circle),
                child: Icon(Icons.check_rounded, size: 44, color: AppTheme.tertiary600),
              ),
              const SizedBox(height: 22),
              Text('That’s a big step done', style: t.headlineSmall, textAlign: TextAlign.center),
              const SizedBox(height: 10),
              Text('You’ve moved through everything for now. Come back any time to add the last few things — you’re close.',
                  style: t.bodyMedium?.copyWith(color: AppTheme.neutral600, height: 1.5), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(minimumSize: const Size(200, 52), backgroundColor: AppTheme.primary),
                child: const Text('Back to my readiness'),
              ),
            ]),
          ),
        ),
      );
}

// ===========================================================================
//  Emergency Mode - calm, not alarming.
// ===========================================================================
class _EmergencyScreen extends StatelessWidget {
  const _EmergencyScreen({required this.controller});
  final PregnancyController controller;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(title: const Text('Labour started?')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.secondary50,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppTheme.secondary100),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('First — take a breath.', style: t.headlineSmall?.copyWith(color: AppTheme.secondary900)),
              const SizedBox(height: 8),
              Text('You have time. Call your doctor or hospital, then take these with you. Everything else can follow later.',
                  style: t.bodyMedium?.copyWith(color: AppTheme.secondary900, height: 1.5)),
            ]),
          ),
          const SizedBox(height: 22),
          Text('Take these first', style: t.titleMedium),
          const SizedBox(height: 12),
          for (final g in kEmergencyGrab)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppTheme.outlineVariant)),
              child: Row(children: [
                Container(
                  width: 44, height: 44, alignment: Alignment.center,
                  decoration: BoxDecoration(color: AppTheme.primary50, borderRadius: BorderRadius.circular(13)),
                  child: Icon(g.icon, color: AppTheme.primary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(g.title, style: t.titleSmall),
                    const SizedBox(height: 2),
                    Text(g.sub, style: t.bodySmall?.copyWith(color: AppTheme.neutral600)),
                  ]),
                ),
              ]),
            ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: AppTheme.tertiary50, borderRadius: BorderRadius.circular(18)),
            child: Row(children: [
              Icon(Icons.directions_car_rounded, color: AppTheme.tertiary600),
              const SizedBox(width: 12),
              Expanded(child: Text('Then leave for the hospital. You’ve got this.',
                  style: t.bodyMedium?.copyWith(color: AppTheme.tertiary900, height: 1.4))),
            ]),
          ),
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
    final t = Theme.of(context).textTheme;
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.outlineVariant, borderRadius: BorderRadius.circular(99)))),
          const SizedBox(height: 16),
          Text('Personalise your bag', style: t.titleLarge),
          const SizedBox(height: 4),
          Text('A few details make the suggestions smarter.', style: t.bodySmall?.copyWith(color: AppTheme.neutral600)),
          const SizedBox(height: 20),

          _label('Delivery type', t),
          Row(children: [
            _pick('Not sure', _ctx.delivery == DeliveryType.unsure, () => _set(() => _ctx.setDelivery(DeliveryType.unsure))),
            const SizedBox(width: 8),
            _pick('Vaginal', _ctx.delivery == DeliveryType.vaginal, () => _set(() => _ctx.setDelivery(DeliveryType.vaginal))),
            const SizedBox(width: 8),
            _pick('C-section', _ctx.delivery == DeliveryType.csection, () => _set(() => _ctx.setDelivery(DeliveryType.csection))),
          ]),
          const SizedBox(height: 18),

          _label('Season of your due date', t),
          Wrap(spacing: 8, runSpacing: 8, children: [
            _pick('Auto', _ctx.seasonOverride == null, () => _set(() => _ctx.setSeasonOverride(null)), expand: false),
            for (final s in Season.values)
              _pick(seasonLabel(s), _ctx.seasonOverride == s, () => _set(() => _ctx.setSeasonOverride(s)), expand: false),
          ]),
          const SizedBox(height: 18),

          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Expecting twins', style: t.titleSmall),
              Text('We’ll suggest a few extras', style: t.bodySmall?.copyWith(color: AppTheme.neutral600)),
            ])),
            Switch(value: _ctx.twins, onChanged: (v) => _set(() => _ctx.setTwins(v)), activeThumbColor: AppTheme.primary),
          ]),
          const SizedBox(height: 8),

          _label('My hospital already provides', t),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final e in kHospitalProvidableLabel.entries)
              _pick(e.value, _ctx.providesFor(e.key), () => _set(() => _ctx.toggleProvides(e.key)), expand: false),
          ]),
          const SizedBox(height: 22),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50), backgroundColor: AppTheme.primary),
            child: const Text('Done'),
          ),
        ]),
      ),
    );
  }

  void _set(VoidCallback f) { f(); setState(() {}); }

  Widget _label(String s, TextTheme t) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(s, style: t.labelLarge?.copyWith(color: AppTheme.neutral700)),
      );

  Widget _pick(String label, bool on, VoidCallback onTap, {bool expand = true}) {
    final chip = GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: on ? AppTheme.primary : AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: on ? AppTheme.primary : AppTheme.outlineVariant),
        ),
        child: Text(label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: on ? Colors.white : AppTheme.neutral800, fontWeight: FontWeight.w600)),
      ),
    );
    return expand ? Expanded(child: chip) : chip;
  }
}

// ---- readiness ring painter -------------------------------------------------
class _RingPainter extends CustomPainter {
  _RingPainter(this.value, this.color);
  final double value; // 0..1
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2 - 5;
    final bg = Paint()
      ..color = AppTheme.surfaceContainerHigh
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
  bool shouldRepaint(covariant _RingPainter old) => old.value != value || old.color != color;
}
