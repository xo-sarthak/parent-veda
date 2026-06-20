// =============================================================================
//  My Hospital Bag ❤️
// -----------------------------------------------------------------------------
//  A personalized preparation experience (NOT a checklist) for Week 30+. A
//  welcoming onboarding generates a smart default bag; the mother then prepares
//  it over time. Three views of the same data:
//    • Bag      — emotional: a filling bag visual, progress, category cards
//    • Planner  — a flat, filterable "single source of truth" list
//    • Shopping — three separate cost totals + grouped purchases + partner share
//  Every item supports states (already-have / buy-from-ParentVeda / buy-elsewhere
//  / skip) plus a "packed" flag. Custom items, search, suggested essentials and
//  gentle "ready" moments are all included. Nothing is mandatory; everything
//  autosaves. Commerce is intentionally non-pushy — the ParentVeda store is a
//  gentle "coming soon".
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/hospital_bag_catalog.dart';
import '../../data/hospital_bag_seed.dart';
import '../../localization/app_language.dart';
import '../../services/hospital_bag_store.dart';
import '../../services/pregnancy_controller.dart';
import '../../theme/app_theme.dart';

class HospitalBagScreen extends StatefulWidget {
  const HospitalBagScreen({super.key, required this.controller});
  final PregnancyController controller;

  @override
  State<HospitalBagScreen> createState() => _HospitalBagScreenState();
}

class _HospitalBagScreenState extends State<HospitalBagScreen> {
  final _store = HospitalBagStore.instance;

  @override
  void initState() {
    super.initState();
    _store.init();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _store,
      builder: (context, _) {
        if (!_store.onboarded) {
          return _Onboarding(controller: widget.controller);
        }
        return _BagHome(controller: widget.controller);
      },
    );
  }
}

// ===========================================================================
//  Category style helpers (shared)
// ===========================================================================

({IconData icon, Color color}) _catStyle(BagCategory c) {
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

({String label, Color color}) _statusStyle(S s, BagItemStatus status) {
  switch (status) {
    case BagItemStatus.have:
      return (label: s.hbStateHave, color: AppTheme.tertiary500);
    case BagItemStatus.buyVeda:
      return (label: s.hbStateBuyVeda, color: AppTheme.primary500);
    case BagItemStatus.buyElse:
      return (label: s.hbStateBuyElse, color: AppTheme.secondary500);
    case BagItemStatus.skip:
      return (label: s.hbStateSkip, color: AppTheme.neutral400);
    case BagItemStatus.needed:
      return (label: s.hbStateNeeded, color: AppTheme.neutral500);
  }
}

/// The price shown for a "buy from ParentVeda" item (chosen product, or the
/// best product as a fallback).
int? _vedaPrice(BagItem item) =>
    item.price ?? bagBestProduct(item.id, isCustom: item.isCustom)?.price;

String _relativeUpdated(S s, DateTime? d) {
  if (d == null) return '';
  final now = DateTime.now();
  final days = DateTime(now.year, now.month, now.day)
      .difference(DateTime(d.year, d.month, d.day))
      .inDays;
  if (days <= 0) return s.hbToday;
  if (days == 1) return s.hbYesterday;
  return s.hbDaysAgo(days);
}

// ===========================================================================
//  Onboarding
// ===========================================================================

class _Onboarding extends StatefulWidget {
  const _Onboarding({required this.controller});
  final PregnancyController controller;

  @override
  State<_Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<_Onboarding> {
  int _step = 0;
  DeliveryType _delivery = DeliveryType.unsure;

  @override
  Widget build(BuildContext context) {
    final s = S(widget.controller.language);
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text('${s.hbName} ❤️')),
      body: SafeArea(
        child: _step == 0
            ? _welcome(s, text)
            : _deliveryStep(s, text),
      ),
    );
  }

  Widget _welcome(S s, TextTheme text) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
      children: [
        const SizedBox(height: 8),
        const Center(child: Text('🎒', style: TextStyle(fontSize: 72))),
        const SizedBox(height: 20),
        Text(s.hbWelcomeTitle,
            textAlign: TextAlign.center, style: text.headlineMedium),
        const SizedBox(height: 12),
        Text(s.hbWelcomeSub,
            textAlign: TextAlign.center,
            style: text.bodyLarge?.copyWith(color: AppTheme.neutral700, height: 1.5)),
        const SizedBox(height: 32),
        FilledButton(
          onPressed: () => setState(() => _step = 1),
          style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15)),
          child: Text(s.hbStartBuilding),
        ),
      ],
    );
  }

  Widget _deliveryStep(S s, TextTheme text) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
      children: [
        Text(s.hbDeliveryTitle, style: text.headlineSmall),
        const SizedBox(height: 8),
        Text(s.hbDeliveryHelper,
            style: text.bodyMedium?.copyWith(color: AppTheme.neutral600)),
        const SizedBox(height: 20),
        _deliveryTile(s.hbDeliveryUnsure, DeliveryType.unsure),
        _deliveryTile(s.hbDeliveryVaginal, DeliveryType.vaginal),
        _deliveryTile(s.hbDeliveryCsection, DeliveryType.csection),
        const SizedBox(height: 28),
        FilledButton(
          onPressed: () async {
            await HospitalBagStore.instance
                .createBag(generateDefaultBag(_delivery), _delivery);
          },
          style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15)),
          child: Text(s.hbBuildMyBag),
        ),
      ],
    );
  }

  Widget _deliveryTile(String label, DeliveryType type) {
    final selected = _delivery == type;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => setState(() => _delivery = type),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: selected ? AppTheme.secondary50 : AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppTheme.secondary400 : AppTheme.outlineVariant,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Row(children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected ? AppTheme.secondary500 : AppTheme.neutral400,
            ),
            const SizedBox(width: 14),
            Text(label, style: Theme.of(context).textTheme.titleMedium),
          ]),
        ),
      ),
    );
  }
}

// ===========================================================================
//  Home (Bag / Planner / Shopping)
// ===========================================================================

class _BagHome extends StatelessWidget {
  const _BagHome({required this.controller});
  final PregnancyController controller;

  @override
  Widget build(BuildContext context) {
    final s = S(controller.language);
    final store = HospitalBagStore.instance;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('${s.hbName} ❤️'),
          actions: [
            IconButton(
              tooltip: s.hbSearchHint,
              icon: const Icon(Icons.search_rounded),
              onPressed: () => showSearch(
                context: context,
                delegate: _BagSearchDelegate(controller),
              ),
            ),
            IconButton(
              tooltip: s.hbSharePartner,
              icon: const Icon(Icons.ios_share_rounded),
              onPressed: () => _sharePartner(context, s, store),
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: s.hbTabBag),
              Tab(text: s.hbTabPlanner),
              Tab(text: s.hbTabShopping),
            ],
          ),
        ),
        body: AnimatedBuilder(
          animation: store,
          builder: (context, _) => TabBarView(
            children: [
              _BagView(controller: controller),
              _PlannerView(controller: controller),
              _ShoppingView(controller: controller),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  Bag View
// ---------------------------------------------------------------------------

class _BagView extends StatelessWidget {
  const _BagView({required this.controller});
  final PregnancyController controller;

  @override
  Widget build(BuildContext context) {
    final s = S(controller.language);
    final lang = controller.language;
    final store = HospitalBagStore.instance;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: [
        _progressCard(context, s, store),
        const SizedBox(height: 18),
        // Category cards
        for (final c in store.activeCategories) ...[
          _categoryCard(context, s, lang, store, c),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 6),
        // Suggested essentials
        _suggestedSection(context, s, lang, store),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => showAddCustomBag(context, s),
            icon: const Icon(Icons.add_rounded),
            label: Text(s.hbAddCustom),
          ),
        ),
      ],
    );
  }

  Widget _progressCard(BuildContext context, S s, HospitalBagStore store) {
    final text = Theme.of(context).textTheme;
    final p = store.percentReady;
    final updated = _relativeUpdated(s, store.lastUpdated);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        // Tap to jump to the Planner (the full list of items in the bag).
        onTap: () => DefaultTabController.of(context).animateTo(1),
        child: Ink(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.secondary50, AppTheme.primary50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 96,
            height: 110,
            child: CustomPaint(
              painter: _BagFillPainter(progress: p / 100),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 18),
                  child: Text('$p%',
                      style: text.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primary800)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.hbPreparationProgress,
                    style: text.labelMedium?.copyWith(color: AppTheme.neutral600)),
                const SizedBox(height: 2),
                Text(s.hbPercentReady(p),
                    style: text.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800, color: AppTheme.primary800)),
                const SizedBox(height: 8),
                Text(
                  '${s.hbSelectedCount(store.plannedCount)}  ·  '
                  '${s.hbPackedCountLabel(store.packedCount)}  ·  '
                  '${s.hbRemainingCount(store.remainingCount)}',
                  style: text.bodySmall?.copyWith(color: AppTheme.neutral700),
                ),
                const SizedBox(height: 8),
                Text(s.hbProgressLine(p),
                    style: text.bodyMedium?.copyWith(color: AppTheme.neutral800)),
                if (updated.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text('${s.hbLastUpdatedLabel}: $updated',
                      style: text.labelSmall?.copyWith(color: AppTheme.neutral500)),
                ],
              ],
            ),
          ),
        ],
      ),
        ),
      ),
    );
  }

  Widget _categoryCard(BuildContext context, S s, AppLanguage lang,
      HospitalBagStore store, BagCategory c) {
    final text = Theme.of(context).textTheme;
    final style = _catStyle(c);
    final planned = store.plannedCountIn(c);
    final ready = store.packedCountIn(c);
    final progress = planned == 0 ? 0.0 : ready / planned;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => _CategoryScreen(controller: controller, category: c),
        )),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.outlineVariant),
          ),
          child: Row(children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: style.color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(style.icon, color: style.color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.hbCategory(c.name),
                      style: text.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Row(children: [
                    Text('${s.hbItemsCount(planned)}  ·  ${s.hbReadyCount(ready)}',
                        style: text.bodySmall
                            ?.copyWith(color: AppTheme.neutral600)),
                  ]),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: AppTheme.surfaceContainerHigh,
                      valueColor: AlwaysStoppedAnimation(style.color),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: AppTheme.neutral400),
          ]),
        ),
      ),
    );
  }

  Widget _suggestedSection(BuildContext context, S s, AppLanguage lang,
      HospitalBagStore store) {
    final text = Theme.of(context).textTheme;
    // Only show suggestions not already in the bag.
    final suggestions =
        suggestedEssentials().where((i) => store.byId(i.id) == null).toList();
    if (suggestions.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(s.hbSuggestedTitle,
            style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final item in suggestions)
              ActionChip(
                avatar: const Icon(Icons.add_rounded, size: 18),
                label: Text(item.name.of(lang)),
                onPressed: () async {
                  await store.addSuggested(item);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(s.hbItemAdded)));
                  }
                },
              ),
          ],
        ),
      ]),
    );
  }
}

// ---------------------------------------------------------------------------
//  Category screen (items in one category)
// ---------------------------------------------------------------------------

class _CategoryScreen extends StatelessWidget {
  const _CategoryScreen({required this.controller, required this.category});
  final PregnancyController controller;
  final BagCategory category;

  @override
  Widget build(BuildContext context) {
    final s = S(controller.language);
    final lang = controller.language;
    final store = HospitalBagStore.instance;
    return Scaffold(
      appBar: AppBar(title: Text(s.hbCategory(category.name))),
      body: AnimatedBuilder(
        animation: store,
        builder: (context, _) {
          final items = store.itemsIn(category);
          if (items.isEmpty) {
            return Center(child: Text(s.hbNothingHere));
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
            children: [
              for (final i in items)
                _ItemRow(controller: controller, item: i, lang: lang, s: s),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () =>
                      showAddCustomBag(context, s, preset: category),
                  icon: const Icon(Icons.add_rounded),
                  label: Text(s.hbAddCustom),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// One item row — packed checkbox + name + status chip; tap opens the sheet.
class _ItemRow extends StatelessWidget {
  const _ItemRow({
    required this.controller,
    required this.item,
    required this.lang,
    required this.s,
  });
  final PregnancyController controller;
  final BagItem item;
  final AppLanguage lang;
  final S s;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final st = _statusStyle(s, item.status);
    final dimmed = item.isSkipped;
    final sellable = bagIsSellable(item.id, isCustom: item.isCustom);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: Opacity(
        opacity: dimmed ? 0.55 : 1,
        child: ListTile(
          contentPadding: const EdgeInsets.fromLTRB(8, 4, 14, 4),
          leading: IconButton(
            tooltip: s.hbMarkPacked,
            onPressed: item.isSkipped
                ? null
                : () => _togglePacked(context, s, item),
            icon: Icon(
              item.packed
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: item.packed ? AppTheme.tertiary500 : AppTheme.neutral400,
            ),
          ),
          title: Text(
            item.name.of(lang),
            style: text.bodyLarge?.copyWith(
              decoration: item.packed ? TextDecoration.lineThrough : null,
              color: item.packed ? AppTheme.neutral500 : null,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Wrap(spacing: 8, runSpacing: 4, children: [
              _chip(st.label, st.color),
              if (item.status == BagItemStatus.buyVeda && _vedaPrice(item) != null)
                _chip(s.rupees(_vedaPrice(item)!), AppTheme.primary500),
              if (item.status == BagItemStatus.buyElse && item.price != null)
                _chip(s.rupees(item.price!), AppTheme.secondary500),
              if (sellable && item.status != BagItemStatus.buyVeda)
                _chip('❤️ ${s.hbRecommendation}', AppTheme.primary400),
            ]),
          ),
          trailing: const Icon(Icons.chevron_right_rounded,
              color: AppTheme.neutral400),
          onTap: () {
            if (sellable) {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) =>
                    _ProductScreen(controller: controller, itemId: item.id),
              ));
            } else {
              showBagItemSheet(context, s, lang, item.id);
            }
          },
        ),
      ),
    );
  }

  Widget _chip(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(40),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w700, color: color)),
      );
}

// ---------------------------------------------------------------------------
//  Planner View (flat, filterable)
// ---------------------------------------------------------------------------

class _PlannerView extends StatefulWidget {
  const _PlannerView({required this.controller});
  final PregnancyController controller;

  @override
  State<_PlannerView> createState() => _PlannerViewState();
}

class _PlannerViewState extends State<_PlannerView> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final s = S(widget.controller.language);
    final lang = widget.controller.language;
    final store = HospitalBagStore.instance;
    final items = store.filter(_filter);
    const keys = ['all', 'veda', 'else', 'owned', 'packed', 'pending', 'skipped'];

    return Column(children: [
      const SizedBox(height: 10),
      SizedBox(
        height: 40,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: keys.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, i) {
            final k = keys[i];
            return ChoiceChip(
              label: Text(s.hbFilter(k)),
              selected: _filter == k,
              onSelected: (_) => setState(() => _filter = k),
            );
          },
        ),
      ),
      const SizedBox(height: 4),
      Expanded(
        child: items.isEmpty
            ? Center(child: Text(s.hbNothingHere))
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                children: [
                  for (final i in items)
                    _ItemRow(
                        controller: widget.controller,
                        item: i,
                        lang: lang,
                        s: s),
                ],
              ),
      ),
    ]);
  }
}

// ---------------------------------------------------------------------------
//  Shopping View (cost totals + grouped purchases + partner share)
// ---------------------------------------------------------------------------

class _ShoppingView extends StatelessWidget {
  const _ShoppingView({required this.controller});
  final PregnancyController controller;

  @override
  Widget build(BuildContext context) {
    final s = S(controller.language);
    final lang = controller.language;
    final text = Theme.of(context).textTheme;
    final store = HospitalBagStore.instance;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: [
        // Cost totals — kept strictly separate.
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.outlineVariant),
          ),
          child: Column(children: [
            _costRow(text, s.hbVedaPurchases, s.rupees(store.vedaTotal),
                AppTheme.primary600),
            const Divider(height: 18),
            _costRow(text, s.hbExternalPurchases, s.rupees(store.externalTotal),
                AppTheme.secondary600),
            const Divider(height: 18),
            _costRow(text, s.hbAlreadyOwnedTotal, s.rupees(0),
                AppTheme.neutral500),
            const Divider(height: 18),
            _costRow(text, s.hbTotalPlanned, s.rupees(store.totalPlanned),
                AppTheme.primary800,
                bold: true),
          ]),
        ),
        const SizedBox(height: 14),
        // Buy what's planned from ParentVeda (store coming soon).
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(s.hbStoreComingSoon))),
            icon: const Icon(Icons.storefront_rounded, size: 18),
            label: Text(s.hbOrderFromVeda),
          ),
        ),
        const SizedBox(height: 16),
        _group(context, s, lang, s.hbBuyingFromVeda,
            store.withStatus(BagItemStatus.buyVeda)),
        _group(context, s, lang, s.hbBuyingElsewhere,
            store.withStatus(BagItemStatus.buyElse)),
        _group(context, s, lang, s.hbOwnedGroup,
            store.withStatus(BagItemStatus.have)),
        _group(context, s, lang, s.hbPendingGroup,
            store.withStatus(BagItemStatus.needed)),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => _sharePartner(context, s, store),
            icon: const Icon(Icons.ios_share_rounded, size: 18),
            label: Text(s.hbSharePartner),
          ),
        ),
      ],
    );
  }

  Widget _costRow(TextTheme text, String label, String value, Color color,
      {bool bold = false}) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label,
          style: bold
              ? text.titleMedium?.copyWith(fontWeight: FontWeight.w800)
              : text.bodyMedium),
      Text(value,
          style: (bold ? text.titleMedium : text.titleSmall)
              ?.copyWith(fontWeight: FontWeight.w800, color: color)),
    ]);
  }

  Widget _group(BuildContext context, S s, AppLanguage lang, String title,
      List<BagItem> items) {
    if (items.isEmpty) return const SizedBox.shrink();
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        for (final i in items)
          _ItemRow(controller: controller, item: i, lang: lang, s: s),
      ]),
    );
  }
}

// ===========================================================================
//  Item detail sheet (shared by category / planner / search)
// ===========================================================================

/// Simple status sheet for NON-sellable items (documents, personal things):
/// already have / buy elsewhere / skip + packed. No marketplace, no recommendation.
Future<void> showBagItemSheet(
    BuildContext context, S s, AppLanguage lang, String itemId) async {
  final store = HospitalBagStore.instance;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: AppTheme.surface,
    builder: (ctx) {
      return StatefulBuilder(builder: (ctx, setSheet) {
        final item = store.byId(itemId);
        if (item == null) return const SizedBox.shrink();
        final text = Theme.of(ctx).textTheme;

        void choose(BagItemStatus st) async {
          if (st == BagItemStatus.buyElse) {
            await _buyElsewhereSheet(ctx, s, itemId);
          } else {
            await store.setStatus(itemId, st);
          }
          setSheet(() {});
        }

        return Padding(
          padding: EdgeInsets.fromLTRB(
              20, 4, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: SingleChildScrollView(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child:
                          Text(item.name.of(lang), style: text.headlineSmall),
                    ),
                    if (item.isCustom)
                      IconButton(
                        tooltip: s.delete,
                        icon: const Icon(Icons.delete_outline_rounded),
                        onPressed: () async {
                          await store.removeItem(itemId);
                          if (ctx.mounted) Navigator.of(ctx).pop();
                        },
                      ),
                  ]),
                  const SizedBox(height: 12),
                  Text(s.hbStatusLabel,
                      style: text.labelMedium
                          ?.copyWith(color: AppTheme.neutral600)),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    _statusChoice(s, item, BagItemStatus.have, choose),
                    _statusChoice(s, item, BagItemStatus.buyElse, choose),
                    _statusChoice(s, item, BagItemStatus.skip, choose),
                  ]),
                  if (item.status == BagItemStatus.buyElse) ...[
                    const SizedBox(height: 12),
                    _buyElseSummary(
                        ctx,
                        s,
                        item,
                        () => _buyElsewhereSheet(ctx, s, itemId)
                            .then((_) => setSheet(() {}))),
                  ],
                  const SizedBox(height: 8),
                  if (!item.isSkipped)
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(s.hbPackedLabel),
                      value: item.packed,
                      onChanged: (_) async {
                        await _togglePacked(ctx, s, item);
                        setSheet(() {});
                      },
                    ),
                ]),
          ),
        );
      });
    },
  );
}

/// Capture "buy elsewhere" details (store, link, price, notes) for any item.
Future<void> _buyElsewhereSheet(
    BuildContext context, S s, String itemId) async {
  final store = HospitalBagStore.instance;
  final item = store.byId(itemId);
  if (item == null) return;
  final linkCtrl = TextEditingController(text: item.link);
  final priceCtrl = TextEditingController(text: item.price?.toString() ?? '');
  final notesCtrl = TextEditingController(text: item.notes);
  String storeSel = item.store.isNotEmpty
      ? (kBagStores.contains(item.store) ? item.store : 'Other')
      : kBagStores.first;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: AppTheme.surface,
    builder: (ctx) {
      return StatefulBuilder(builder: (ctx, setSheet) {
        final text = Theme.of(ctx).textTheme;
        return Padding(
          padding: EdgeInsets.fromLTRB(
              20, 4, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: SingleChildScrollView(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.hbStateBuyElse, style: text.headlineSmall),
                  const SizedBox(height: 16),
                  Text(s.hbWhereBuy,
                      style: text.labelMedium
                          ?.copyWith(color: AppTheme.neutral600)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: storeSel,
                    items: [
                      for (final st in kBagStores)
                        DropdownMenuItem(value: st, child: Text(st)),
                    ],
                    onChanged: (v) => setSheet(() => storeSel = v ?? storeSel),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: linkCtrl,
                    decoration:
                        InputDecoration(labelText: s.hbProductLinkOptional),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: priceCtrl,
                    keyboardType: const TextInputType.numberWithOptions(),
                    decoration: InputDecoration(
                        labelText: s.hbPriceOptional, prefixText: '₹ '),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: notesCtrl,
                    decoration: InputDecoration(labelText: s.hbNotesOptional),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () async {
                        await store.setBuyElse(
                          itemId,
                          store: storeSel,
                          link: linkCtrl.text.trim(),
                          price: int.tryParse(priceCtrl.text.trim()),
                          notes: notesCtrl.text.trim(),
                        );
                        if (ctx.mounted) Navigator.of(ctx).pop();
                      },
                      child: Text(s.saveCta),
                    ),
                  ),
                ]),
          ),
        );
      });
    },
  );

  linkCtrl.dispose();
  priceCtrl.dispose();
  notesCtrl.dispose();
}

Widget _buyElseSummary(
    BuildContext context, S s, BagItem item, VoidCallback onEdit) {
  final text = Theme.of(context).textTheme;
  return Container(
    padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
    decoration: BoxDecoration(
      color: AppTheme.surfaceContainer,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(children: [
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.store.isEmpty ? s.hbStateBuyElse : item.store,
              style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          if (item.price != null)
            Text(s.rupees(item.price!),
                style: text.bodyMedium?.copyWith(color: AppTheme.secondary600)),
          if (item.link.isNotEmpty)
            Text(s.hbLinkSaved,
                style: text.labelSmall?.copyWith(color: AppTheme.neutral500)),
        ]),
      ),
      TextButton(onPressed: onEdit, child: Text(s.hbEditDetails)),
    ]),
  );
}

// ===========================================================================
//  Product (marketplace) screen — for sellable items
// ===========================================================================

class _ProductScreen extends StatelessWidget {
  const _ProductScreen({required this.controller, required this.itemId});
  final PregnancyController controller;
  final String itemId;

  @override
  Widget build(BuildContext context) {
    final s = S(controller.language);
    final lang = controller.language;
    final store = HospitalBagStore.instance;
    final name = store.byId(itemId)?.name.of(lang) ?? '';

    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: AnimatedBuilder(
        animation: store,
        builder: (context, _) {
          final item = store.byId(itemId);
          if (item == null) return const SizedBox.shrink();
          final text = Theme.of(context).textTheme;
          final products = bagProductsFor(itemId, isCustom: item.isCustom);
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            children: [
              Text(s.hbChooseOption,
                  style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              for (final p in products) ...[
                _productCard(context, s, item, p),
                const SizedBox(height: 12),
              ],
              if (item.status == BagItemStatus.buyVeda) ...[
                const SizedBox(height: 2),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(s.hbStoreComingSoon))),
                    icon: const Icon(Icons.storefront_rounded, size: 18),
                    label: Text(s.hbBuyVedaCta),
                  ),
                ),
              ],
              const SizedBox(height: 22),
              Text(s.hbDecideHow,
                  style:
                      text.labelMedium?.copyWith(color: AppTheme.neutral600)),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8, children: [
                _statusChoice(s, item, BagItemStatus.have,
                    (st) => store.setStatus(itemId, st)),
                ChoiceChip(
                  label: Text(s.hbStateBuyElse),
                  selected: item.status == BagItemStatus.buyElse,
                  onSelected: (_) => _buyElsewhereSheet(context, s, itemId),
                ),
                _statusChoice(s, item, BagItemStatus.skip,
                    (st) => store.setStatus(itemId, st)),
              ]),
              if (item.status == BagItemStatus.buyElse) ...[
                const SizedBox(height: 12),
                _buyElseSummary(
                    context, s, item, () => _buyElsewhereSheet(context, s, itemId)),
              ],
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(s.hbPackedLabel),
                value: item.packed,
                onChanged: (_) => _togglePacked(context, s, item),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// A marketplace product card with the ParentVeda trust layer. Tapping it picks
/// it as the mother's "buy from ParentVeda" choice.
Widget _productCard(BuildContext context, S s, BagItem item, BagProduct p) {
  final text = Theme.of(context).textTheme;
  final selected =
      item.status == BagItemStatus.buyVeda && item.selectedProductId == p.id;
  return Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => HospitalBagStore.instance
          .chooseVedaProduct(item.id, productId: p.id, price: p.price),
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary50 : AppTheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? AppTheme.primary400 : AppTheme.outlineVariant,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _productImage(p),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (p.topPick)
                      Text('❤️ ${s.hbBestOverall}',
                          style: text.labelSmall?.copyWith(
                              color: AppTheme.primary600,
                              fontWeight: FontWeight.w800)),
                    Text(p.name,
                        style: text.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(s.rupees(p.price),
                        style: text.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800)),
                  ]),
            ),
            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected ? AppTheme.primary500 : AppTheme.neutral300,
            ),
          ]),
          if (p.why.isNotEmpty) ...[
            const SizedBox(height: 12),
            if (p.topPick)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(s.hbWhyRecommend,
                    style: text.labelSmall?.copyWith(
                        color: AppTheme.neutral600,
                        fontWeight: FontWeight.w700)),
              ),
            for (final w in p.why)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child:
                    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('✓  ',
                      style:
                          TextStyle(color: AppTheme.tertiary600, fontSize: 13)),
                  Expanded(child: Text(w, style: text.bodyMedium)),
                ]),
              ),
          ],
          if (p.consider.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(s.hbThingsToConsider,
                style: text.labelSmall?.copyWith(
                    color: AppTheme.neutral600, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            for (final c in p.consider)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child:
                    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('•  '),
                  Expanded(child: Text(c, style: text.bodyMedium)),
                ]),
              ),
          ],
        ]),
      ),
    ),
  );
}

/// Product "photo" — a real network image when [BagProduct.imageUrl] is set,
/// otherwise a soft emoji tile (so real images can be added later).
Widget _productImage(BagProduct p) {
  final tile = Container(
    width: 64,
    height: 64,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [AppTheme.primary50, AppTheme.secondary50],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Text(p.emoji, style: const TextStyle(fontSize: 30)),
  );
  final url = p.imageUrl;
  if (url == null || url.isEmpty) return tile;
  return ClipRRect(
    borderRadius: BorderRadius.circular(14),
    child: Image.network(url,
        width: 64,
        height: 64,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => tile),
  );
}

Widget _statusChoice(S s, BagItem item, BagItemStatus status,
    void Function(BagItemStatus) onPick) {
  final st = _statusStyle(s, status);
  final selected = item.status == status;
  return ChoiceChip(
    label: Text(st.label),
    selected: selected,
    onSelected: (_) => onPick(status),
  );
}

// ===========================================================================
//  Add custom item
// ===========================================================================

Future<void> showAddCustomBag(BuildContext context, S s,
    {BagCategory? preset}) async {
  final nameCtrl = TextEditingController();
  BagCategory category = preset ?? BagCategory.custom;
  const choices = [
    BagCategory.labour,
    BagCategory.afterDelivery,
    BagCategory.baby,
    BagCategory.partner,
    BagCategory.documents,
    BagCategory.comfort,
    BagCategory.custom,
  ];

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: AppTheme.surface,
    builder: (ctx) {
      final text = Theme.of(ctx).textTheme;
      return StatefulBuilder(builder: (ctx, setSheet) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
              20, 4, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.hbAddCustomTitle, style: text.headlineSmall),
                const SizedBox(height: 16),
                TextField(
                  controller: nameCtrl,
                  autofocus: true,
                  decoration: InputDecoration(hintText: s.hbCustomNameHint),
                ),
                const SizedBox(height: 16),
                Text(s.hbWhichSection,
                    style:
                        text.labelMedium?.copyWith(color: AppTheme.neutral600)),
                const SizedBox(height: 8),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  for (final c in choices)
                    ChoiceChip(
                      label: Text(s.hbCategory(c.name)),
                      selected: category == c,
                      onSelected: (_) => setSheet(() => category = c),
                    ),
                ]),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () async {
                      await HospitalBagStore.instance
                          .addCustomItem(nameCtrl.text, category);
                      if (ctx.mounted) Navigator.of(ctx).pop();
                    },
                    child: Text(s.saveCta),
                  ),
                ),
              ]),
        );
      });
    },
  );
  nameCtrl.dispose();
}

// ===========================================================================
//  Packed + emotional moments + partner share
// ===========================================================================

bool _categoryReady(HospitalBagStore store, BagCategory c) {
  final planned = store.plannedCountIn(c);
  return planned > 0 && store.packedCountIn(c) == planned;
}

Future<void> _togglePacked(BuildContext context, S s, BagItem item) async {
  final store = HospitalBagStore.instance;
  final cat = item.category;
  final wasCatReady = _categoryReady(store, cat);
  final wasBagReady = store.plannedCount > 0 && store.percentReady == 100;
  HapticFeedback.lightImpact();
  await store.togglePacked(item.id);
  if (!context.mounted) return;
  final nowBagReady = store.plannedCount > 0 && store.percentReady == 100;
  final nowCatReady = _categoryReady(store, cat);
  if (!wasBagReady && nowBagReady) {
    _showCelebration(context, s.hbBagReadyTitle, s.hbBagReadyBody);
  } else if (!wasCatReady && nowCatReady) {
    _showCelebration(
        context, s.hbCategoryReady(s.hbCategory(cat.name)), s.hbCategoryReadyBody);
  }
}

void _showCelebration(BuildContext context, String title, String body) {
  final text = Theme.of(context).textTheme;
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('🎉', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 12),
        Text(title, textAlign: TextAlign.center, style: text.titleLarge),
        const SizedBox(height: 8),
        Text(body,
            textAlign: TextAlign.center,
            style: text.bodyMedium?.copyWith(color: AppTheme.neutral700)),
      ]),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('❤️')),
      ],
    ),
  );
}

Future<void> _sharePartner(
    BuildContext context, S s, HospitalBagStore store) async {
  final lang = s.lang;
  final pending = store.pendingPurchases;
  final buf = StringBuffer()
    ..writeln('${s.hbName} ❤️')
    ..writeln(s.hbShareProgress(store.percentReady))
    ..writeln();
  if (pending.isEmpty) {
    buf.writeln(s.hbShareNothingPending);
  } else {
    buf.writeln(s.hbShareCanHelp);
    for (final i in pending) {
      buf.writeln('• ${i.name.of(lang)}');
    }
  }
  try {
    await Share.share(buf.toString());
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(s.shareFailed)));
    }
  }
}

// ===========================================================================
//  Search
// ===========================================================================

class _BagSearchDelegate extends SearchDelegate<void> {
  _BagSearchDelegate(this.controller);
  final PregnancyController controller;

  @override
  List<Widget> buildActions(BuildContext context) => [
        if (query.isNotEmpty)
          IconButton(
              icon: const Icon(Icons.clear_rounded),
              onPressed: () => query = ''),
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) => _results(context);

  @override
  Widget buildSuggestions(BuildContext context) => _results(context);

  Widget _results(BuildContext context) {
    final s = S(controller.language);
    final lang = controller.language;
    final results = HospitalBagStore.instance.search(query);
    if (query.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    if (results.isEmpty) {
      return Center(child: Text(s.hbNoResults));
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        for (final i in results)
          _ItemRow(controller: controller, item: i, lang: lang, s: s),
      ],
    );
  }
}

// ===========================================================================
//  The filling-bag visual (emotional, not gamified)
// ===========================================================================

class _BagFillPainter extends CustomPainter {
  _BagFillPainter({required this.progress});
  final double progress; // 0..1

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final bodyRect = Rect.fromLTWH(w * 0.14, h * 0.26, w * 0.72, h * 0.70);
    final body = RRect.fromRectAndRadius(bodyRect, const Radius.circular(20));

    // Handle (arc above the bag).
    final handle = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..color = AppTheme.primary300;
    final handleRect = Rect.fromLTWH(w * 0.30, h * 0.06, w * 0.40, h * 0.34);
    canvas.drawArc(handleRect, 3.14159, 3.14159, false, handle);

    // Track (empty bag).
    canvas.drawRRect(body, Paint()..color = Colors.white.withValues(alpha: 0.8));

    // Fill from the bottom up.
    final clamped = progress.clamp(0.0, 1.0);
    if (clamped > 0) {
      canvas.save();
      canvas.clipRRect(body);
      final fillH = bodyRect.height * clamped;
      final fillRect =
          Rect.fromLTWH(bodyRect.left, bodyRect.bottom - fillH, bodyRect.width, fillH);
      final fill = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppTheme.secondary300, AppTheme.secondary500],
        ).createShader(bodyRect);
      canvas.drawRect(fillRect, fill);
      canvas.restore();
    }

    // Outline + flap.
    canvas.drawRRect(
        body,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = AppTheme.primary400);
    final flap = RRect.fromRectAndCorners(
      Rect.fromLTWH(w * 0.14, h * 0.20, w * 0.72, h * 0.20),
      topLeft: const Radius.circular(20),
      topRight: const Radius.circular(20),
      bottomLeft: const Radius.circular(14),
      bottomRight: const Radius.circular(14),
    );
    canvas.drawRRect(flap, Paint()..color = AppTheme.primary100);
    canvas.drawRRect(
        flap,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = AppTheme.primary400);
  }

  @override
  bool shouldRepaint(covariant _BagFillPainter old) =>
      old.progress != progress;
}
