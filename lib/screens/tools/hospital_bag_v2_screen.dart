// =============================================================================
//  Hospital Bag V2 - a from-scratch redesign (lives behind a toggle vs V1)
// -----------------------------------------------------------------------------
//  "I'm getting ready to meet my baby" - calm, emotional, ONE decision at a time.
//  The mother never sees "states"; every item moves along a single journey in
//  plain language:  Needs your decision → Planning to buy → Ready at home → Packed
//  (plus a gentle "Maybe later" set). Commerce stays hidden until she taps
//  "Help me choose one". Built on its own store (HospitalBagV2Store).
// =============================================================================

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart' show Share;

import '../../data/hospital_bag_catalog.dart';
import '../../data/hospital_bag_seed.dart';
import '../../localization/app_language.dart';
import '../../services/bought_store.dart';
import '../../services/hospital_bag_store.dart';
import '../../services/hospital_bag_v2_store.dart';
import '../../services/pregnancy_controller.dart';
import '../../theme/app_theme.dart';
import '../cart_screen.dart' show showSingleBuyNow;

void _push(BuildContext c, Widget s) =>
    Navigator.of(c).push(MaterialPageRoute(builder: (_) => s));

// Category icon + tint (V2-local; V1's helper is private).
({IconData icon, Color color}) _cat(BagCategory c) {
  switch (c) {
    case BagCategory.labour:
      return (icon: Icons.spa_rounded, color: AppTheme.secondary500);
    case BagCategory.afterDelivery:
      return (icon: Icons.favorite_rounded, color: AppTheme.primary400);
    case BagCategory.baby:
      return (icon: Icons.child_friendly_rounded, color: AppTheme.tertiary400);
    case BagCategory.partner:
      return (icon: Icons.handshake_rounded, color: AppTheme.primary500);
    case BagCategory.documents:
      return (icon: Icons.folder_rounded, color: AppTheme.tertiary500);
    case BagCategory.comfort:
      return (icon: Icons.self_improvement_rounded, color: AppTheme.secondary400);
    case BagCategory.custom:
      return (icon: Icons.auto_awesome_rounded, color: AppTheme.primary300);
  }
}

const List<BagCategory> _catOrder = [
  BagCategory.labour,
  BagCategory.afterDelivery,
  BagCategory.baby,
  BagCategory.partner,
  BagCategory.documents,
  BagCategory.comfort,
  BagCategory.custom,
];

({String label, Color color, IconData icon}) _stageStyle(S s, BagStage st) {
  switch (st) {
    case BagStage.needsDecision:
      return (label: s.hb2v2StageDecision, color: AppTheme.neutral500, icon: Icons.help_outline_rounded);
    case BagStage.planningToBuy:
      return (label: s.hb2v2StagePlanning, color: AppTheme.secondary600, icon: Icons.shopping_bag_outlined);
    case BagStage.readyAtHome:
      return (label: s.hb2v2StageHome, color: AppTheme.primary500, icon: Icons.home_rounded);
    case BagStage.packed:
      return (label: s.hb2v2StagePacked, color: AppTheme.tertiary600, icon: Icons.check_circle_rounded);
    case BagStage.maybeLater:
      return (label: s.hb2v2StageLater, color: AppTheme.neutral400, icon: Icons.schedule_rounded);
  }
}

// ===========================================================================
//  Entry - onboarding (first open) or the calm home.
// ===========================================================================
class HospitalBagV2Screen extends StatefulWidget {
  const HospitalBagV2Screen({super.key, required this.controller});
  final PregnancyController controller;
  @override
  State<HospitalBagV2Screen> createState() => _HospitalBagV2ScreenState();
}

class _HospitalBagV2ScreenState extends State<HospitalBagV2Screen> {
  final _store = HospitalBagV2Store.instance;

  @override
  void initState() {
    super.initState();
    _store.init();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_store, BoughtStore.instance]),
      builder: (context, _) {
        if (!_store.onboarded) {
          return _Onboarding(controller: widget.controller);
        }
        return _Home(controller: widget.controller);
      },
    );
  }
}

// ===========================================================================
//  Onboarding - one gentle screen, then a smart bag is generated.
// ===========================================================================
class _Onboarding extends StatefulWidget {
  const _Onboarding({required this.controller});
  final PregnancyController controller;
  @override
  State<_Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<_Onboarding> {
  DeliveryType _delivery = DeliveryType.unsure;

  @override
  Widget build(BuildContext context) {
    final s = S(widget.controller.language);
    final text = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppTheme.surfaceContainer,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
          child: Column(children: [
            const Spacer(),
            Container(
              width: 96,
              height: 96,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFFFFC56B), Color(0xFFFF8FA8)]),
                shape: BoxShape.circle,
              ),
              child: const Text('🧳', style: TextStyle(fontSize: 44)),
            ),
            const SizedBox(height: 24),
            Text(s.hb2v2Title,
                textAlign: TextAlign.center, style: text.headlineMedium),
            const SizedBox(height: 12),
            Text(s.hb2v2Sub,
                textAlign: TextAlign.center,
                style: text.bodyLarge?.copyWith(color: AppTheme.neutral600, height: 1.5)),
            const SizedBox(height: 28),
            // One gentle question - helps tailor the bag.
            Text(s.hb2v2DeliveryQ,
                style: text.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: [
              for (final d in DeliveryType.values)
                ChoiceChip(
                  label: Text(_deliveryLabel(s, d)),
                  selected: _delivery == d,
                  onSelected: (_) => setState(() => _delivery = d),
                ),
            ]),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16)),
                onPressed: () => HospitalBagV2Store.instance
                    .createBag(generateDefaultBag(_delivery), _delivery),
                child: Text(s.hb2v2StartCta),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

String _deliveryLabel(S s, DeliveryType d) {
  switch (d) {
    case DeliveryType.vaginal:
      return s.hbDeliveryVaginal;
    case DeliveryType.csection:
      return s.hbDeliveryCsection;
    case DeliveryType.unsure:
      return s.hbDeliveryUnsure;
  }
}

// ===========================================================================
//  Home - attention first, then categories; emotional progress; no counts.
// ===========================================================================
class _Home extends StatelessWidget {
  const _Home({required this.controller});
  final PregnancyController controller;

  @override
  Widget build(BuildContext context) {
    final s = S(controller.language);
    final lang = controller.language;
    final text = Theme.of(context).textTheme;
    final store = HospitalBagV2Store.instance;
    final attention = store.needingAttention();
    return Scaffold(
      backgroundColor: AppTheme.surfaceContainer,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceContainer,
        title: Text(s.hb2v2Title),
        actions: [
          IconButton(
            tooltip: s.hb2v2SummaryTitle,
            icon: const Icon(Icons.receipt_long_rounded),
            onPressed: () => _push(context, _Summary(controller: controller)),
          ),
          IconButton(
            tooltip: s.hb2v2SummaryCta,
            icon: const Icon(Icons.ios_share_rounded),
            onPressed: () => _share(context, controller),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: [
          _hero(context, s, store),
          const SizedBox(height: 20),
          // Packing nudge once most things are home (≈ wk 35-36 in spirit).
          if (store.shoppingProgress >= 0.75 && !store.allPacked) ...[
            _packNudge(s, text),
            const SizedBox(height: 16),
          ],
          if (attention.isNotEmpty) ...[
            _sectionTitle(text, s.hb2v2Attention),
            const SizedBox(height: 10),
            for (final i in attention.take(6))
              _AttentionRow(item: i, controller: controller),
            const SizedBox(height: 22),
          ],
          _sectionTitle(text, s.hb2v2Categories),
          const SizedBox(height: 10),
          for (final c in _catOrder) _categoryTile(context, s, lang, c, store),
        ],
      ),
    );
  }

  Widget _hero(BuildContext context, S s, HospitalBagV2Store store) {
    final text = Theme.of(context).textTheme;
    final shop = store.shoppingProgress;
    final pack = store.packingProgress;
    final days = controller.daysToDueDate;
    final ready = shop >= 0.85;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFF1E6), Color(0xFFFDE8F0)]),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.secondary500.withValues(alpha: 0.14)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('🧳', style: TextStyle(fontSize: 30)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(ready ? s.hb2v2HeroReady : s.hb2v2HeroBuilding,
                  style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(s.hb2v2DaysToGo(days),
                  style: text.bodySmall?.copyWith(color: AppTheme.neutral600)),
            ]),
          ),
        ]),
        const SizedBox(height: 16),
        _progress(text, s.hb2v2Shopping, shop, AppTheme.secondary500),
        const SizedBox(height: 12),
        _progress(text, s.hb2v2Packing, pack, AppTheme.primary500),
      ]),
    );
  }

  Widget _progress(TextTheme text, String label, double v, Color color) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label,
              style: text.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
          Text('${(v * 100).round()}%',
              style: text.labelLarge
                  ?.copyWith(fontWeight: FontWeight.w800, color: color)),
        ]),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: v.clamp(0.0, 1.0)),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (_, val, _) => LinearProgressIndicator(
              value: val,
              minHeight: 9,
              backgroundColor: Colors.white.withValues(alpha: 0.6),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
      ]);

  Widget _packNudge(S s, TextTheme text) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.primary100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(children: [
          const Text('🧺', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(s.hb2v2TimeToPack,
                style: text.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800, color: AppTheme.primary900)),
          ),
        ]),
      );

  Widget _sectionTitle(TextTheme text, String t) => Text(t,
      style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800));

  Widget _categoryTile(BuildContext context, S s, AppLanguage lang,
      BagCategory c, HospitalBagV2Store store) {
    final st = _cat(c);
    final items = store.itemsIn(c);
    final done = items.where((i) => i.packed).length;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _push(
              context, _Category(controller: controller, category: c)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: st.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(13)),
                child: Icon(st.icon, color: st.color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(s.hbCategory(c.name),
                    style: Theme.of(context).textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
              ),
              if (items.isNotEmpty)
                Text('$done/${items.length}',
                    style: Theme.of(context).textTheme.labelMedium
                        ?.copyWith(color: AppTheme.neutral500)),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right_rounded, color: AppTheme.neutral400),
            ]),
          ),
        ),
      ),
    );
  }

  static void _share(BuildContext context, PregnancyController c) {
    final s = S(c.language);
    final store = HospitalBagV2Store.instance;
    final lang = c.language;
    final toBuy = store.active.where((i) =>
        bagStageOf(i) == BagStage.needsDecision ||
        bagStageOf(i) == BagStage.planningToBuy);
    final toPack = store.active.where((i) => bagStageOf(i) == BagStage.readyAtHome);
    final missingDocs = store.itemsIn(BagCategory.documents)
        .where((i) => bagStageOf(i) != BagStage.readyAtHome && !i.packed);
    final b = StringBuffer()
      ..writeln('🧳 ${s.hb2v2Title}')
      ..writeln(
          '${s.hb2v2Shopping} ${(store.shoppingProgress * 100).round()}% · ${s.hb2v2Packing} ${(store.packingProgress * 100).round()}%')
      ..writeln();
    if (toBuy.isNotEmpty) {
      b.writeln('🛍️ ${s.hb2v2SecWaiting}:');
      for (final i in toBuy) {
        b.writeln('• ${i.name.of(lang)}');
      }
      b.writeln();
    }
    if (toPack.isNotEmpty) {
      b.writeln('🏠 ${s.hb2v2StageHome}:');
      for (final i in toPack) {
        b.writeln('• ${i.name.of(lang)}');
      }
      b.writeln();
    }
    if (missingDocs.isNotEmpty) {
      b.writeln('📄 ${s.hbCategory('documents')}:');
      for (final i in missingDocs) {
        b.writeln('• ${i.name.of(lang)}');
      }
    }
    Share.share(b.toString().trim());
  }
}

// A compact row used in "Needs your attention" - shows the next step + status.
class _AttentionRow extends StatelessWidget {
  const _AttentionRow({required this.item, required this.controller});
  final BagItem item;
  final PregnancyController controller;
  @override
  Widget build(BuildContext context) {
    final s = S(controller.language);
    final lang = controller.language;
    final text = Theme.of(context).textTheme;
    final stage = bagStageOf(item);
    final ss = _stageStyle(s, stage);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => showItemActions(context, controller, item.id),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              Icon(ss.icon, size: 20, color: ss.color),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(item.name.of(lang),
                      style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  Text(ss.label,
                      style: text.labelMedium?.copyWith(color: ss.color)),
                ]),
              ),
              // Ready-at-home → one satisfying pack tap.
              if (stage == BagStage.readyAtHome)
                _PackToggle(item: item, s: s)
              else
                const Icon(Icons.chevron_right_rounded, color: AppTheme.neutral400),
            ]),
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
//  Category screen - clean list + "Add my own" + collapsed "Maybe later".
// ===========================================================================
class _Category extends StatefulWidget {
  const _Category({required this.controller, required this.category});
  final PregnancyController controller;
  final BagCategory category;
  @override
  State<_Category> createState() => _CategoryState();
}

class _CategoryState extends State<_Category> {
  bool _showLater = false;
  @override
  Widget build(BuildContext context) {
    final s = S(widget.controller.language);
    final lang = widget.controller.language;
    final st = _cat(widget.category);
    return AnimatedBuilder(
      animation: Listenable.merge(
          [HospitalBagV2Store.instance, BoughtStore.instance]),
      builder: (context, _) {
        final store = HospitalBagV2Store.instance;
        final items = store.itemsIn(widget.category);
        final later = store.maybeLater
            .where((i) => i.category == widget.category)
            .toList();
        return Scaffold(
          backgroundColor: AppTheme.surfaceContainer,
          appBar: AppBar(
            backgroundColor: AppTheme.surfaceContainer,
            title: Text(s.hbCategory(widget.category.name)),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
            children: [
              _addOwn(context, s, st.color),
              const SizedBox(height: 12),
              for (final i in items)
                _ItemRow(item: i, controller: widget.controller),
              if (later.isNotEmpty) ...[
                const SizedBox(height: 18),
                InkWell(
                  onTap: () => setState(() => _showLater = !_showLater),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(children: [
                      Icon(
                          _showLater
                              ? Icons.expand_less_rounded
                              : Icons.expand_more_rounded,
                          color: AppTheme.neutral500),
                      const SizedBox(width: 6),
                      Text('${s.hb2v2MaybeLaterTitle} (${later.length})',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(color: AppTheme.neutral500)),
                    ]),
                  ),
                ),
                if (_showLater)
                  for (final i in later)
                    _LaterRow(item: i, lang: lang),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _addOwn(BuildContext context, S s, Color color) => Material(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _addCustom(context, widget.controller, widget.category),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              Icon(Icons.add_circle_outline_rounded, color: color),
              const SizedBox(width: 12),
              Text(s.hb2v2AddOwn,
                  style: Theme.of(context).textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700, color: color)),
            ]),
          ),
        ),
      );
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item, required this.controller});
  final BagItem item;
  final PregnancyController controller;
  @override
  Widget build(BuildContext context) {
    final s = S(controller.language);
    final lang = controller.language;
    final text = Theme.of(context).textTheme;
    final stage = bagStageOf(item);
    final ss = _stageStyle(s, stage);
    final productName = item.selectedProductId == null
        ? null
        : bagProductsFor(item.id, isCustom: item.isCustom)
            .where((p) => p.id == item.selectedProductId)
            .map((p) => p.name)
            .cast<String?>()
            .firstWhere((_) => true, orElse: () => null);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => showItemActions(context, controller, item.id),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(item.name.of(lang),
                      style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Row(children: [
                    Icon(ss.icon, size: 14, color: ss.color),
                    const SizedBox(width: 5),
                    Text(ss.label,
                        style: text.labelMedium?.copyWith(color: ss.color)),
                  ]),
                  // Selected product always remains visible.
                  if (productName != null) ...[
                    const SizedBox(height: 2),
                    Text('${s.hb2v2Selected}: $productName',
                        style: text.labelSmall?.copyWith(color: AppTheme.neutral500)),
                  ],
                  // The shop she chose, for "buy elsewhere".
                  if (item.status == BagItemStatus.buyElse && item.store.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text('🔗 ${item.store}',
                        style: text.labelSmall?.copyWith(color: AppTheme.neutral500)),
                  ],
                ]),
              ),
              const SizedBox(width: 8),
              if (stage == BagStage.readyAtHome)
                _PackToggle(item: item, s: s)
              else if (stage == BagStage.planningToBuy &&
                  item.status == BagItemStatus.buyElse)
                // Bought elsewhere → one tap to advance.
                TextButton(
                  onPressed: () =>
                      HospitalBagV2Store.instance.setPurchased(item.id, true),
                  child: Text(s.hb2v2MarkBought),
                )
              else
                const Icon(Icons.chevron_right_rounded, color: AppTheme.neutral400),
            ]),
          ),
        ),
      ),
    );
  }
}

// One satisfying tap: Ready at home ⇄ Packed. No dialog, no confirm.
class _PackToggle extends StatelessWidget {
  const _PackToggle({required this.item, required this.s});
  final BagItem item;
  final S s;
  @override
  Widget build(BuildContext context) {
    final packed = item.packed;
    return GestureDetector(
      onTap: () => HospitalBagV2Store.instance.togglePacked(item.id),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: packed ? AppTheme.tertiary500 : AppTheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
              color: packed ? AppTheme.tertiary500 : AppTheme.outlineVariant),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(packed ? Icons.check_rounded : Icons.luggage_rounded,
              size: 16, color: packed ? Colors.white : AppTheme.neutral600),
          const SizedBox(width: 5),
          Text(packed ? s.hb2v2StagePacked : s.hb2v2InBag,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: packed ? Colors.white : AppTheme.neutral700,
                  fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }
}

class _LaterRow extends StatelessWidget {
  const _LaterRow({required this.item, required this.lang});
  final BagItem item;
  final AppLanguage lang;
  @override
  Widget build(BuildContext context) {
    final s = S(lang);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Expanded(
          child: Text(item.name.of(lang),
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: AppTheme.neutral500)),
        ),
        TextButton(
          onPressed: () => HospitalBagV2Store.instance.restore(item.id),
          child: Text(s.hb2v2RestoreItem),
        ),
      ]),
    );
  }
}

// ===========================================================================
//  The ONE action sheet - only five options, ever.
// ===========================================================================
void showItemActions(
    BuildContext context, PregnancyController controller, String itemId) {
  final s = S(controller.language);
  final lang = controller.language;
  final item = HospitalBagV2Store.instance.byId(itemId);
  if (item == null) return;
  final sellable = bagProductsFor(item.id, isCustom: item.isCustom).isNotEmpty;
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppTheme.surface,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) => SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(s.hb2v2WhatDo(item.name.of(lang)),
                  style: Theme.of(ctx).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800)),
            ),
          ),
          if (sellable)
            _action(ctx, Icons.auto_awesome_rounded, AppTheme.primary500,
                s.hb2v2ChooseOne, () {
              Navigator.of(ctx).pop();
              _push(ctx, _ProductExperience(controller: controller, itemId: itemId));
            }),
          _action(ctx, Icons.home_rounded, AppTheme.tertiary500, s.hb2v2HaveOne,
              () {
            HospitalBagV2Store.instance.setStatus(itemId, BagItemStatus.have);
            Navigator.of(ctx).pop();
          }),
          _action(ctx, Icons.storefront_rounded, AppTheme.secondary500,
              s.hb2v2BuyElse, () {
            Navigator.of(ctx).pop();
            _showBuyElse(context, controller, itemId);
          }),
          _action(ctx, Icons.schedule_rounded, AppTheme.neutral500, s.hb2v2Later,
              () {
            HospitalBagV2Store.instance.setStatus(itemId, BagItemStatus.needed);
            Navigator.of(ctx).pop();
          }),
          _action(ctx, Icons.visibility_off_rounded, AppTheme.neutral400,
              s.hb2v2NotNeed, () {
            HospitalBagV2Store.instance.moveToMaybeLater(itemId);
            Navigator.of(ctx).pop();
          }),
          if (item.isCustom)
            _action(ctx, Icons.delete_outline_rounded, AppTheme.secondary600,
                s.hb2v2RemoveItem, () {
              HospitalBagV2Store.instance.removeItem(itemId);
              Navigator.of(ctx).pop();
            }),
        ]),
      ),
    ),
  );
}

Widget _action(BuildContext ctx, IconData icon, Color color, String label,
        VoidCallback onTap) =>
    ListTile(
      leading: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(label,
          style: Theme.of(ctx).textTheme.titleSmall
              ?.copyWith(fontWeight: FontWeight.w700)),
      onTap: onTap,
    );

// ===========================================================================
//  Buy elsewhere - one decision: where? (store optional, details never forced)
// ===========================================================================
void _showBuyElse(
    BuildContext context, PregnancyController controller, String itemId) {
  final s = S(controller.language);
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppTheme.surface,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(s.hb2v2WhereBuy,
              style: Theme.of(ctx).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final store in kBagStores)
              ActionChip(
                label: Text(store),
                onPressed: () {
                  HospitalBagV2Store.instance.setBuyElse(itemId, store: store);
                  Navigator.of(ctx).pop();
                },
              ),
            ActionChip(
              label: Text(s.hb2v2SkipForNow),
              onPressed: () {
                HospitalBagV2Store.instance.setBuyElse(itemId, store: '');
                Navigator.of(ctx).pop();
              },
            ),
          ]),
          const SizedBox(height: 8),
          Text(s.hb2v2AddDetails,
              style: Theme.of(ctx).textTheme.labelSmall
                  ?.copyWith(color: AppTheme.neutral500)),
        ]),
      ),
    ),
  );
}

void _addCustom(
    BuildContext context, PregnancyController controller, BagCategory category) {
  final s = S(controller.language);
  final nameCtrl = TextEditingController();
  final notesCtrl = TextEditingController();
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppTheme.surface,
    showDragHandle: true,
    builder: (ctx) => Padding(
      padding: EdgeInsets.fromLTRB(
          20, 0, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(s.hb2v2AddOwn,
            style: Theme.of(ctx).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 14),
        TextField(
          controller: nameCtrl,
          autofocus: true,
          decoration: InputDecoration(
            labelText: s.hb2v2ItemName,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: notesCtrl,
          decoration: InputDecoration(
            labelText: s.hb2v2NotesOptional,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () {
              HospitalBagV2Store.instance.addCustomItem(
                  nameCtrl.text, category,
                  notes: notesCtrl.text.trim());
              Navigator.of(ctx).pop();
            },
            child: Text(s.saveCta),
          ),
        ),
      ]),
    ),
  );
}

// ===========================================================================
//  ParentVeda Product Experience - the ONLY commerce path.
// ===========================================================================
class _ProductExperience extends StatelessWidget {
  const _ProductExperience({required this.controller, required this.itemId});
  final PregnancyController controller;
  final String itemId;

  @override
  Widget build(BuildContext context) {
    final s = S(controller.language);
    final text = Theme.of(context).textTheme;
    return AnimatedBuilder(
      animation: HospitalBagV2Store.instance,
      builder: (context, _) {
        final item = HospitalBagV2Store.instance.byId(itemId);
        if (item == null) return const SizedBox.shrink();
        final products = bagProductsFor(item.id, isCustom: item.isCustom);
        final pick = products.firstWhere((p) => p.topPick, orElse: () => products.first);
        final others = products.where((p) => p.id != pick.id).toList();
        final selectedId = item.selectedProductId;
        return Scaffold(
          backgroundColor: AppTheme.surfaceContainer,
          appBar: AppBar(
            backgroundColor: AppTheme.surfaceContainer,
            title: Text(item.name.of(controller.language)),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
            children: [
              // ParentVeda pick (the hero)
              _pickCard(context, s, text, item, pick, selectedId == pick.id),
              const SizedBox(height: 16),
              _why(text, s, pick),
              if (pick.consider.isNotEmpty) ...[
                const SizedBox(height: 14),
                _bullets(text, s.hb2v2Consider, pick.consider, Icons.info_outline_rounded),
              ],
              const SizedBox(height: 14),
              _guide(text, s),
              const SizedBox(height: 14),
              _reviews(text, s),
              const SizedBox(height: 18),
              Text(s.hb2v2Compare,
                  style: text.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              for (final p in others)
                _altCard(context, s, text, item, p, selectedId == p.id),
            ],
          ),
        );
      },
    );
  }

  void _choose(BuildContext context, BagItem item, BagProduct p) {
    final store = HospitalBagV2Store.instance;
    if (p.isAffiliate) {
      store.setBuyElse(item.id, store: p.store, link: p.link, price: p.price);
    } else {
      store.chooseVedaProduct(item.id, productId: p.id, price: p.price);
    }
  }

  Widget _pickCard(BuildContext context, S s, TextTheme text, BagItem item,
      BagProduct p, bool selected) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [AppTheme.primary100, AppTheme.surface]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primary500.withValues(alpha: 0.25)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: AppTheme.primary500,
                borderRadius: BorderRadius.circular(99)),
            child: Text(s.hb2v2PvPick,
                style: text.labelSmall?.copyWith(
                    color: Colors.white, fontWeight: FontWeight.w800)),
          ),
          const Spacer(),
          Text('₹${p.price}',
              style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Text(p.emoji, style: const TextStyle(fontSize: 30)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(p.name,
                style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          ),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(
            child: selected
                ? OutlinedButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: Text(s.hb2v2Selected),
                  )
                : FilledButton(
                    onPressed: () {
                      _choose(context, item, p);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('${s.hb2v2Selected}: ${p.name}'),
                          duration: const Duration(milliseconds: 900)));
                    },
                    child: Text(s.hb2v2ChooseThis),
                  ),
          ),
          const SizedBox(width: 10),
          FilledButton.tonalIcon(
            onPressed: () {
              _choose(context, item, p);
              showSingleBuyNow(context, controller,
                  productId: p.id,
                  name: p.name,
                  emoji: p.emoji,
                  unitPrice: p.price.toDouble(),
                  title: s.hb2v2Title);
            },
            icon: const Icon(Icons.shopping_bag_rounded, size: 18),
            label: Text(s.hb2v2BuyOnPv),
          ),
        ]),
      ]),
    );
  }

  Widget _why(TextTheme text, S s, BagProduct p) =>
      _bullets(text, s.hb2v2WhyRec, p.why.isEmpty ? const ['Chosen for quality & comfort'] : p.why,
          Icons.favorite_rounded);

  Widget _bullets(TextTheme text, String title, List<String> items, IconData icon) =>
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: AppTheme.surface, borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: text.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          for (final b in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(icon, size: 15, color: AppTheme.primary400),
                const SizedBox(width: 8),
                Expanded(child: Text(b, style: text.bodyMedium)),
              ]),
            ),
        ]),
      );

  // Buying guide + reviews are tastefully placeholdered (no data yet).
  Widget _guide(TextTheme text, S s) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: AppTheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(s.hb2v2BuyingGuide,
              style: text.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(s.hb2v2BuyingGuideBody, style: text.bodyMedium),
        ]),
      );

  Widget _reviews(TextTheme text, S s) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: AppTheme.surface, borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
          const Text('⭐', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s.hb2v2Reviews,
                  style: text.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(s.hb2v2ReviewsSoon,
                  style: text.bodySmall?.copyWith(color: AppTheme.neutral500)),
            ]),
          ),
        ]),
      );

  Widget _altCard(BuildContext context, S s, TextTheme text, BagItem item,
      BagProduct p, bool selected) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: selected ? AppTheme.primary500 : AppTheme.outlineVariant,
              width: selected ? 1.6 : 1),
        ),
        child: Row(children: [
          Text(p.emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p.isAffiliate ? '${p.store} 🔗' : p.name,
                  style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
              Text('₹${p.price}',
                  style: text.labelMedium?.copyWith(color: AppTheme.neutral600)),
            ]),
          ),
          selected
              ? const Icon(Icons.check_circle_rounded, color: AppTheme.primary500)
              : OutlinedButton(
                  onPressed: () {
                    _choose(context, item, p);
                    Navigator.of(context).maybePop();
                  },
                  child: Text(s.hb2v2ChooseThis),
                ),
        ]),
      ),
    );
  }
}

// ===========================================================================
//  Shopping summary - auto-generated; PV vs external never mixed.
// ===========================================================================
class _Summary extends StatelessWidget {
  const _Summary({required this.controller});
  final PregnancyController controller;
  @override
  Widget build(BuildContext context) {
    final s = S(controller.language);
    final lang = controller.language;
    final text = Theme.of(context).textTheme;
    return AnimatedBuilder(
      animation: HospitalBagV2Store.instance,
      builder: (context, _) {
        final store = HospitalBagV2Store.instance;
        final fromPv = store.active.where((i) => i.status == BagItemStatus.buyVeda);
        final fromElse = store.active.where((i) => i.status == BagItemStatus.buyElse);
        final atHome = store.active.where((i) => i.status == BagItemStatus.have);
        final waiting = store.active.where((i) =>
            (i.status == BagItemStatus.buyVeda ||
                i.status == BagItemStatus.buyElse) &&
            !i.purchased);
        final packed = store.active.where((i) => i.packed);
        final pvSpend = fromPv.fold<int>(0, (a, i) => a + (i.price ?? 0));
        final extSpend = fromElse.fold<int>(0, (a, i) => a + (i.price ?? 0));
        return Scaffold(
          backgroundColor: AppTheme.surfaceContainer,
          appBar: AppBar(
            backgroundColor: AppTheme.surfaceContainer,
            title: Text(s.hb2v2SummaryTitle),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
            children: [
              _totals(text, s, pvSpend, extSpend),
              const SizedBox(height: 18),
              _sec(context, s, lang, s.hb2v2SecFromPv, fromPv),
              _sec(context, s, lang, s.hb2v2SecElse, fromElse),
              _sec(context, s, lang, s.hb2v2SecWaiting, waiting),
              _sec(context, s, lang, s.hb2v2SecHome, atHome),
              _sec(context, s, lang, s.hb2v2SecPacked, packed),
            ],
          ),
        );
      },
    );
  }

  Widget _totals(TextTheme text, S s, int pv, int ext) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: AppTheme.surface, borderRadius: BorderRadius.circular(18)),
        child: Column(children: [
          _totalRow(text, s.hb2v2PvSpend, pv, AppTheme.primary500),
          const Divider(height: 18),
          _totalRow(text, s.hb2v2ExtSpend, ext, AppTheme.secondary500),
          const Divider(height: 18),
          _totalRow(text, s.hb2v2TotalSpend, pv + ext, AppTheme.primary900,
              bold: true),
        ]),
      );

  Widget _totalRow(TextTheme text, String label, int amount, Color color,
          {bool bold = false}) =>
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label,
            style: text.bodyMedium?.copyWith(
                fontWeight: bold ? FontWeight.w800 : FontWeight.w500)),
        Text('₹$amount',
            style: text.titleSmall?.copyWith(
                fontWeight: FontWeight.w800, color: color)),
      ]);

  Widget _sec(BuildContext context, S s, AppLanguage lang, String title,
      Iterable<BagItem> items) {
    if (items.isEmpty) return const SizedBox.shrink();
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: text.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        for (final i in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Row(children: [
              const Text('• '),
              Expanded(child: Text(i.name.of(lang), style: text.bodyMedium)),
              if ((i.price ?? 0) > 0)
                Text('₹${i.price}',
                    style: text.labelMedium?.copyWith(color: AppTheme.neutral500)),
            ]),
          ),
      ]),
    );
  }
}
