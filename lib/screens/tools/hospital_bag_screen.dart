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

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
// url_launcher + cart_store are used only by the OLD (now-commented) UI below;
// re-add their imports if that block is restored.

import '../../data/hospital_bag_catalog.dart';
import '../../data/hospital_bag_seed.dart';
import '../../localization/app_language.dart';
import '../../models/reminder.dart';
import '../../services/bought_store.dart';
import '../../services/hospital_bag_store.dart';
import '../../services/hospital_bag_v2_store.dart';
import '../../services/pregnancy_controller.dart';
import '../../services/reminder_store.dart';
import '../../theme/app_theme.dart';
import '../cart_screen.dart';
import 'hospital_bag_v2_screen.dart';

class HospitalBagScreen extends StatefulWidget {
  const HospitalBagScreen({super.key, required this.controller});
  final PregnancyController controller;

  @override
  State<HospitalBagScreen> createState() => _HospitalBagScreenState();
}

class _HospitalBagScreenState extends State<HospitalBagScreen> {
  final _store = HospitalBagStore.instance;
  static const _verKey = 'hb_use_v2';
  bool _useV2 = false;

  @override
  void initState() {
    super.initState();
    _store.init();
    HospitalBagV2Store.instance.init();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final p = await SharedPreferences.getInstance();
      if (mounted) setState(() => _useV2 = p.getBool(_verKey) ?? false);
    } catch (_) {/* default V1 */}
  }

  void _setVersion(bool v) {
    setState(() => _useV2 = v);
    SharedPreferences.getInstance().then((p) => p.setBool(_verKey, v));
  }

  @override
  Widget build(BuildContext context) {
    // V1 (untouched) or V2; a small floating "Classic | New" switcher overlays
    // both so they can be compared. V1's widgets/behaviour are unchanged.
    final body = _useV2
        ? HospitalBagV2Screen(controller: widget.controller)
        : AnimatedBuilder(
            animation: _store,
            builder: (context, _) => _store.onboarded
                ? _MyBagScreen(controller: widget.controller)
                : _Onboarding(controller: widget.controller),
          );
    return Stack(children: [
      Positioned.fill(child: body),
      Positioned(
        left: 0,
        right: 0,
        bottom: 0,
        child: SafeArea(
          child: Center(
            child: _VersionPill(
                useV2: _useV2,
                onChanged: _setVersion,
                lang: widget.controller.language),
          ),
        ),
      ),
    ]);
  }
}

/// A small floating segmented switcher between V1 ("Classic") and V2 ("New").
class _VersionPill extends StatelessWidget {
  const _VersionPill(
      {required this.useV2, required this.onChanged, required this.lang});
  final bool useV2;
  final ValueChanged<bool> onChanged;
  final AppLanguage lang;

  @override
  Widget build(BuildContext context) {
    final s = S(lang);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(99),
        boxShadow: const [
          BoxShadow(
              color: Color(0x292D144C), blurRadius: 20, offset: Offset(0, 6)),
        ],
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        _seg(context, s.hb2vClassic, !useV2, () => onChanged(false)),
        _seg(context, s.hb2vNew, useV2, () => onChanged(true)),
      ]),
    );
  }

  Widget _seg(BuildContext context, String label, bool active, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            color: active ? AppTheme.primary500 : Colors.transparent,
            borderRadius: BorderRadius.circular(99),
          ),
          child: Text(label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: active ? Colors.white : AppTheme.neutral600)),
        ),
      );
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

// ignore: unused_element
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

// ignore: unused_element
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
//  SIMPLIFIED "My Hospital Bag" — a warm, tap-only nesting experience.
//    • _MyBagScreen    — the default: a filling-bag hero + her items grouped by
//                        WHERE she'll get them, with inline Bought/Packed.
//    • _AddItemsScreen — the dead-simple catalogue browser (+ "mums like you").
//    • _KeepsakeScreen — the "bag is ready 💛" celebration.
//  The OLD 3-view UI (Bag/Planner/Shopping) is preserved, commented, below.
// ===========================================================================

const String _kBagReminderId = 'bag_prep';

class _MyBagScreen extends StatefulWidget {
  const _MyBagScreen({required this.controller});
  final PregnancyController controller;
  @override
  State<_MyBagScreen> createState() => _MyBagScreenState();
}

class _MyBagScreenState extends State<_MyBagScreen> {
  final _store = HospitalBagStore.instance;
  int _cheer = 0;
  bool _celebrated = false;

  PregnancyController get c => widget.controller;

  @override
  Widget build(BuildContext context) {
    final s = S(c.language);
    final lang = c.language;
    final text = Theme.of(context).textTheme;
    return AnimatedBuilder(
      animation: Listenable.merge([_store, BoughtStore.instance]),
      builder: (context, _) {
        final items = _store.items;
        final veda = _store.withStatus(BagItemStatus.buyVeda);
        final els = _store.withStatus(BagItemStatus.buyElse);
        final have = _store.withStatus(BagItemStatus.have);
        final needed = _store.withStatus(BagItemStatus.needed);
        final total = items.length;
        final packed = items.where((i) => i.packed).length;
        final allReady = total > 0 && packed == total;

        if (allReady && !_celebrated) {
          _celebrated = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _openKeepsake();
          });
        } else if (!allReady) {
          _celebrated = false;
        }

        final hasReminder =
            ReminderStore.instance.byId(_kBagReminderId) != null;

        return Scaffold(
          backgroundColor: AppTheme.surfaceContainer,
          appBar: AppBar(
            title: Text('${s.hb2MyBag} ❤️'),
            actions: [
              IconButton(
                icon: const Icon(Icons.ios_share_rounded),
                tooltip: s.hb2ShareTitle,
                onPressed: () => _share(s, lang),
              ),
              PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'remind') _toggleReminder(s);
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'remind',
                    child: Text(hasReminder ? s.hb2RemindOff : s.hb2RemindMe),
                  ),
                ],
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 40),
            children: [
              _hero(s, text, packed, total, allReady),
              const SizedBox(height: 16),
              _addButton(s),
              const SizedBox(height: 18),
              if (total == 0)
                _emptyState(s, text)
              else ...[
                if (veda.isNotEmpty)
                  _group(s, text, lang, BagItemStatus.buyVeda, veda),
                if (els.isNotEmpty)
                  _group(s, text, lang, BagItemStatus.buyElse, els),
                if (have.isNotEmpty)
                  _group(s, text, lang, BagItemStatus.have, have),
                if (needed.isNotEmpty)
                  _group(s, text, lang, BagItemStatus.needed, needed),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _hero(S s, TextTheme text, int packed, int total, bool allReady) {
    final fill = total == 0 ? 0.0 : packed / total;
    final pct = (fill * 100).round();
    final days = c.daysToDueDate;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFF1E6), Color(0xFFFDE8F0)]),
        borderRadius: BorderRadius.circular(24),
        border:
            Border.all(color: AppTheme.secondary500.withValues(alpha: 0.14)),
      ),
      child: Row(children: [
        SizedBox(
          width: 76,
          height: 92,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: fill),
            duration: const Duration(milliseconds: 650),
            curve: Curves.easeOutCubic,
            builder: (_, v, _) => CustomPaint(painter: _BagHeroPainter(v)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(allReady ? s.hb2ReadyBanner : s.hb2FillingUp,
                style: text.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800, color: AppTheme.primary900)),
            const SizedBox(height: 6),
            Text(
              total == 0
                  ? s.hb2HeroEmpty
                  : (days > 0
                      ? '${s.hb2ReadyPct(pct)}  ·  ${s.hb2DaysToGo(days)}'
                      : s.hb2ReadyPct(pct)),
              style: text.bodySmall?.copyWith(color: AppTheme.neutral700),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: total == 0 ? 0 : fill,
                minHeight: 7,
                backgroundColor: Colors.white.withValues(alpha: 0.6),
                valueColor:
                    const AlwaysStoppedAnimation(AppTheme.secondary500),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _addButton(S s) => SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: _openAddItems,
          icon: const Icon(Icons.add_rounded),
          label: Text(s.hb2AddItems),
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.secondary500,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      );

  Widget _emptyState(S s, TextTheme text) => Container(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppTheme.outlineVariant),
        ),
        child: Column(children: [
          const Text('🎒', style: TextStyle(fontSize: 54)),
          const SizedBox(height: 12),
          Text(s.hb2EmptyTitle,
              textAlign: TextAlign.center,
              style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(s.hb2EmptySub,
              textAlign: TextAlign.center,
              style: text.bodyMedium?.copyWith(color: AppTheme.neutral600)),
        ]),
      );

  ({IconData icon, Color color, String label}) _groupMeta(
      S s, BagItemStatus st) {
    switch (st) {
      case BagItemStatus.buyVeda:
        return (
          icon: Icons.storefront_rounded,
          color: AppTheme.primary500,
          label: s.hb2GroupVeda
        );
      case BagItemStatus.buyElse:
        return (
          icon: Icons.link_rounded,
          color: AppTheme.secondary500,
          label: s.hb2GroupElse
        );
      case BagItemStatus.have:
        return (
          icon: Icons.check_circle_rounded,
          color: AppTheme.tertiary500,
          label: s.hb2GroupHave
        );
      default:
        return (
          icon: Icons.help_outline_rounded,
          color: AppTheme.neutral500,
          label: s.hb2GroupNeeded
        );
    }
  }

  Widget _group(S s, TextTheme text, AppLanguage lang, BagItemStatus st,
      List<BagItem> items) {
    final m = _groupMeta(s, st);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(children: [
            Icon(m.icon, size: 18, color: m.color),
            const SizedBox(width: 8),
            Text('${m.label}  ·  ${items.length}',
                style: text.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800, color: m.color)),
          ]),
        ),
        for (final it in items) _itemCard(s, text, lang, it),
      ]),
    );
  }

  Widget _itemCard(S s, TextTheme text, AppLanguage lang, BagItem it) {
    final sellable = bagIsSellable(it.id, isCustom: it.isCustom);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: Column(children: [
        InkWell(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
          onTap: () => _sourceSheet(s, it),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 12, 8),
            child: Row(children: [
              Text(_emojiFor(it), style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(it.name.of(lang),
                          style: text.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      if (it.status == BagItemStatus.buyElse &&
                          it.store.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                              '${it.store}${it.link.isNotEmpty ? '  🔗' : ''}',
                              style: text.labelSmall
                                  ?.copyWith(color: AppTheme.neutral500)),
                        ),
                    ]),
              ),
              const Icon(Icons.unfold_more_rounded,
                  size: 18, color: AppTheme.neutral400),
            ]),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _controls(s, it, sellable),
          ),
        ),
      ]),
    );
  }

  List<Widget> _controls(S s, BagItem it, bool sellable) {
    if (it.status == BagItemStatus.needed) {
      return [
        _pill(
          label: s.hb2ChooseSource,
          icon: Icons.add_shopping_cart_rounded,
          on: false,
          onTap: () => _sourceSheet(s, it),
        ),
      ];
    }
    final out = <Widget>[];
    final buyable = it.status == BagItemStatus.buyVeda ||
        it.status == BagItemStatus.buyElse;
    if (it.status == BagItemStatus.buyVeda && sellable && !it.purchased) {
      out.add(_buyPill(s, it));
    }
    if (buyable) {
      out.add(_pill(
        label: it.purchased ? s.hb2Bought : s.hb2ToBuy,
        icon: Icons.shopping_bag_rounded,
        on: it.purchased,
        onTap: () => _store.togglePurchased(it.id),
      ));
    }
    out.add(_pill(
      label: it.packed ? s.hb2Packed : s.hb2Pack,
      icon: Icons.backpack_rounded,
      on: it.packed,
      onTap: () => _pack(s, it),
    ));
    return out;
  }

  Widget _pill({
    required String label,
    required IconData icon,
    required bool on,
    required VoidCallback onTap,
  }) {
    final color = on ? AppTheme.tertiary600 : AppTheme.neutral500;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: on ? AppTheme.tertiary50 : AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: on ? AppTheme.tertiary400 : AppTheme.outlineVariant),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(on ? Icons.check_rounded : icon, size: 15, color: color),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  fontSize: 12.5, fontWeight: FontWeight.w700, color: color)),
        ]),
      ),
    );
  }

  Widget _buyPill(S s, BagItem it) {
    final price = _vedaPrice(it) ?? 0;
    return GestureDetector(
      onTap: () => _buyVeda(it),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.primary500,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.shopping_bag_rounded, size: 15, color: Colors.white),
          const SizedBox(width: 6),
          Text(s.hb2Buy(price),
              style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.white)),
        ]),
      ),
    );
  }

  String _emojiFor(BagItem it) {
    final p = bagBestProduct(it.id, isCustom: it.isCustom);
    if (p != null) return p.emoji;
    switch (it.category) {
      case BagCategory.documents:
        return '📄';
      case BagCategory.partner:
        return '👜';
      case BagCategory.comfort:
        return '🌸';
      default:
        return '🎒';
    }
  }

  void _pack(S s, BagItem it) {
    final wasPacked = it.packed;
    _store.togglePacked(it.id);
    if (!wasPacked) {
      HapticFeedback.lightImpact();
      final msg = s.hb2PackedCheer(_cheer % 4);
      _cheer++;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(
          content: Text(msg),
          duration: const Duration(milliseconds: 1300),
          behavior: SnackBarBehavior.floating,
        ));
    }
  }

  void _buyVeda(BagItem it) {
    final best = bagBestProduct(it.id, isCustom: it.isCustom);
    final price = best?.price ?? _vedaPrice(it) ?? 0;
    final pid = best?.id ?? '${it.id}_pv';
    _store.chooseVedaProduct(it.id, productId: pid, price: price);
    showSingleBuyNow(
      context,
      c,
      productId: pid,
      name: it.name.of(c.language),
      emoji: _emojiFor(it),
      unitPrice: price.toDouble(),
    );
  }

  void _openAddItems() => Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => _AddItemsScreen(controller: c)));

  void _openKeepsake() => Navigator.of(context).push(MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => _KeepsakeScreen(controller: c)));

  void _toggleReminder(S s) {
    final store = ReminderStore.instance;
    if (store.byId(_kBagReminderId) == null) {
      store.upsert(Reminder(
        id: _kBagReminderId,
        title: s.hb2ReminderTitle,
        body: s.hb2ReminderBody,
        hour: 18,
        minute: 0,
        repeat: ReminderRepeat.daily,
        category: 'bag',
      ));
      _toast(s.hb2ReminderSet);
    } else {
      store.remove(_kBagReminderId);
      _toast(s.hb2ReminderOff);
    }
  }

  void _toast(String msg) => ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1500)));

  void _share(S s, AppLanguage lang) {
    final b = StringBuffer('${s.hb2MyBag} 💛\n\n');
    final toBuy = _store.items
        .where((i) =>
            (i.status == BagItemStatus.buyVeda ||
                i.status == BagItemStatus.buyElse) &&
            !i.purchased)
        .toList();
    if (toBuy.isNotEmpty) {
      b.writeln('${s.hb2ShareToBuy}:');
      for (final i in toBuy) {
        final where = i.status == BagItemStatus.buyVeda
            ? 'ParentVeda'
            : (i.store.isNotEmpty ? i.store : s.hb2GroupElse);
        b.writeln('• ${i.name.of(lang)}  ($where)');
      }
      b.writeln();
    }
    final packed = _store.items.where((i) => i.packed).length;
    b.writeln(s.hb2SharePacked(packed, _store.items.length));
    Share.share(b.toString());
  }

  void _sourceSheet(S s, BagItem it) {
    final lang = c.language;
    final sellable = bagIsSellable(it.id, isCustom: it.isCustom);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        top: false,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 10),
          Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                  color: AppTheme.outlineVariant,
                  borderRadius: BorderRadius.circular(99))),
          const SizedBox(height: 14),
          Text(it.name.of(lang),
              style: Theme.of(ctx)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(s.hb2ChooseSource,
              style: Theme.of(ctx)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppTheme.neutral500)),
          const SizedBox(height: 8),
          if (sellable)
            _sheetOption(Icons.storefront_rounded, AppTheme.primary500,
                s.hb2SrcVeda, () {
              Navigator.pop(ctx);
              _chooseVeda(it);
            }),
          _sheetOption(
              Icons.link_rounded, AppTheme.secondary500, s.hb2SrcElse, () {
            Navigator.pop(ctx);
            _buyElseSheet(s, it);
          }),
          _sheetOption(Icons.check_circle_rounded, AppTheme.tertiary500,
              s.hb2SrcHave, () {
            Navigator.pop(ctx);
            _store.setStatus(it.id, BagItemStatus.have);
          }),
          _sheetOption(Icons.delete_outline_rounded, AppTheme.neutral500,
              s.hb2Remove, () {
            Navigator.pop(ctx);
            _store.removeItem(it.id);
          }),
          const SizedBox(height: 12),
        ]),
      ),
    );
  }

  Widget _sheetOption(
          IconData icon, Color color, String label, VoidCallback onTap) =>
      ListTile(
        leading: Icon(icon, color: color),
        title: Text(label),
        onTap: onTap,
      );

  void _chooseVeda(BagItem it) {
    final best = bagBestProduct(it.id, isCustom: it.isCustom);
    _store.chooseVedaProduct(it.id,
        productId: best?.id ?? '${it.id}_pv',
        price: best?.price ?? _vedaPrice(it) ?? 0);
  }

  void _buyElseSheet(S s, BagItem it) {
    var shop = it.store.isNotEmpty ? it.store : 'Amazon';
    final linkCtrl = TextEditingController(text: it.link);
    const shops = ['Amazon', 'Flipkart', 'FirstCry', 'Other'];
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 18,
            bottom: 18 + MediaQuery.of(ctx).viewInsets.bottom),
        child: StatefulBuilder(
          builder: (ctx, setSheet) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.hb2SrcElse,
                  style: Theme.of(ctx)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  for (final sh in shops)
                    ChoiceChip(
                      label: Text(sh),
                      selected: shop == sh,
                      onSelected: (_) => setSheet(() => shop = sh),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: linkCtrl,
                decoration: InputDecoration(
                  hintText: s.hb2LinkOptional,
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    _store.setBuyElse(it.id,
                        store: shop, link: linkCtrl.text.trim());
                    Navigator.pop(ctx);
                  },
                  child: Text(s.hb2Save),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  Add items — the dead-simple catalogue browser.
// ---------------------------------------------------------------------------
class _AddItemsScreen extends StatefulWidget {
  const _AddItemsScreen({required this.controller});
  final PregnancyController controller;
  @override
  State<_AddItemsScreen> createState() => _AddItemsScreenState();
}

class _AddItemsScreenState extends State<_AddItemsScreen> {
  final _store = HospitalBagStore.instance;
  final _searchCtrl = TextEditingController();
  String _query = '';
  final Set<BagCategory> _expanded = {BagCategory.labour};

  PregnancyController get c => widget.controller;

  static const _order = [
    BagCategory.labour,
    BagCategory.afterDelivery,
    BagCategory.baby,
    BagCategory.partner,
    BagCategory.documents,
    BagCategory.comfort,
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S(c.language);
    final lang = c.language;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppTheme.surfaceContainer,
      appBar: AppBar(
        title: Text(s.hb2AddTitle),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(s.hb2Done),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _store,
        builder: (context, _) {
          final inBag = _store.items.map((i) => i.id).toSet();
          final byCat = bagCatalogByCategory();
          final suggestions = suggestedEssentials()
              .where((i) => !inBag.contains(i.id))
              .toList();
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 40),
            children: [
              TextField(
                controller: _searchCtrl,
                onChanged: (v) =>
                    setState(() => _query = v.trim().toLowerCase()),
                decoration: InputDecoration(
                  hintText: s.hb2Search,
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: AppTheme.surface,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 16),
              if (_query.isEmpty && suggestions.isNotEmpty) ...[
                Row(children: [
                  const Text('💛', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Text(s.hb2MumsAlsoPacked,
                      style: text.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w800)),
                ]),
                const SizedBox(height: 10),
                for (final sug in suggestions.take(6))
                  _suggestionTile(s, text, lang, sug),
                const SizedBox(height: 18),
              ],
              for (final cat in _order)
                _catSection(
                    s, text, lang, cat, byCat[cat] ?? const [], inBag),
            ],
          );
        },
      ),
    );
  }

  Widget _suggestionTile(S s, TextTheme text, AppLanguage lang, BagItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFFFFF6E9), Color(0xFFFDEEF4)]),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: AppTheme.secondary500.withValues(alpha: 0.16)),
      ),
      child: Row(children: [
        Text(_emojiForTemplate(item), style: const TextStyle(fontSize: 22)),
        const SizedBox(width: 12),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.name.of(lang),
                style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            Text(s.hb2SocialProof,
                style: text.labelSmall?.copyWith(color: AppTheme.neutral600)),
          ]),
        ),
        FilledButton(
          onPressed: () {
            _store.addSuggested(item);
            HapticFeedback.selectionClick();
          },
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.secondary500,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(s.hb2Add),
        ),
      ]),
    );
  }

  Widget _catSection(S s, TextTheme text, AppLanguage lang, BagCategory cat,
      List<BagItem> items, Set<String> inBag) {
    final filtered = _query.isEmpty
        ? items
        : items
            .where((i) => i.name.en.toLowerCase().contains(_query))
            .toList();
    if (filtered.isEmpty) return const SizedBox.shrink();
    final open = _query.isNotEmpty || _expanded.contains(cat);
    final style = _catStyle(cat);
    final addedCount = filtered.where((i) => inBag.contains(i.id)).length;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => setState(() {
          if (!_expanded.remove(cat)) _expanded.add(cat);
        }),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(children: [
            Icon(style.icon, size: 20, color: style.color),
            const SizedBox(width: 10),
            Expanded(
              child: Text(_catLabel(s, cat),
                  style:
                      text.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
            ),
            Text('$addedCount/${filtered.length}',
                style: text.labelSmall?.copyWith(color: AppTheme.neutral500)),
            const SizedBox(width: 6),
            Icon(open ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                color: AppTheme.neutral400),
          ]),
        ),
      ),
      if (open)
        for (final it in filtered)
          _addRow(text, lang, it, inBag.contains(it.id)),
      const Divider(height: 1),
    ]);
  }

  Widget _addRow(TextTheme text, AppLanguage lang, BagItem it, bool added) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        if (added) {
          _store.removeItem(it.id);
        } else {
          _store.addSuggested(it);
        }
        HapticFeedback.selectionClick();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
        child: Row(children: [
          Text(_emojiForTemplate(it), style: const TextStyle(fontSize: 19)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(it.name.of(lang),
                style: text.bodyLarge?.copyWith(
                    color: added ? AppTheme.primary700 : null,
                    fontWeight: added ? FontWeight.w700 : FontWeight.w500)),
          ),
          Icon(
            added
                ? Icons.check_circle_rounded
                : Icons.add_circle_outline_rounded,
            color: added ? AppTheme.secondary500 : AppTheme.neutral400,
          ),
        ]),
      ),
    );
  }

  String _emojiForTemplate(BagItem it) {
    final p = bagBestProduct(it.id, isCustom: it.isCustom);
    if (p != null) return p.emoji;
    switch (it.category) {
      case BagCategory.documents:
        return '📄';
      case BagCategory.partner:
        return '👜';
      case BagCategory.comfort:
        return '🌸';
      default:
        return '🎒';
    }
  }

  String _catLabel(S s, BagCategory cat) {
    switch (cat) {
      case BagCategory.labour:
        return s.hb2CatLabour;
      case BagCategory.afterDelivery:
        return s.hb2CatAfter;
      case BagCategory.baby:
        return s.hb2CatBaby;
      case BagCategory.partner:
        return s.hb2CatPartner;
      case BagCategory.documents:
        return s.hb2CatDocs;
      case BagCategory.comfort:
        return s.hb2CatComfort;
      case BagCategory.custom:
        return s.hb2CatCustom;
    }
  }
}

// ---------------------------------------------------------------------------
//  Keepsake — "Baby's bag is ready 💛".
// ---------------------------------------------------------------------------
class _KeepsakeScreen extends StatelessWidget {
  const _KeepsakeScreen({required this.controller});
  final PregnancyController controller;
  @override
  Widget build(BuildContext context) {
    final s = S(controller.language);
    final text = Theme.of(context).textTheme;
    final date = s.formatLongDate(DateTime.now());
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFF1E6), Color(0xFFFDE8F0)]),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('🎒', style: TextStyle(fontSize: 84)),
                const SizedBox(height: 6),
                const Text('💛', style: TextStyle(fontSize: 34)),
                const SizedBox(height: 18),
                Text(s.hb2KeepsakeTitle,
                    textAlign: TextAlign.center,
                    style: text.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(s.hb2KeepsakeSub(date),
                    textAlign: TextAlign.center,
                    style:
                        text.bodyLarge?.copyWith(color: AppTheme.neutral700)),
                const SizedBox(height: 30),
                FilledButton.icon(
                  onPressed: () => Share.share(s.hb2KeepsakeShareText(date)),
                  icon: const Icon(Icons.ios_share_rounded),
                  label: Text(s.hb2KeepsakeShare),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.secondary500,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 26, vertical: 13),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(s.hb2Done),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  The filling-bag hero painter.
// ---------------------------------------------------------------------------
class _BagHeroPainter extends CustomPainter {
  _BagHeroPainter(this.fill);
  final double fill; // 0..1

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.10, h * 0.30, w * 0.80, h * 0.66),
      const Radius.circular(14),
    );
    final handle = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..color = AppTheme.secondary500.withValues(alpha: 0.85);
    canvas.drawArc(Rect.fromLTWH(w * 0.30, h * 0.06, w * 0.40, h * 0.42),
        math.pi, math.pi, false, handle);
    final f = fill.clamp(0.0, 1.0);
    if (f > 0) {
      canvas.save();
      canvas.clipRRect(body);
      final fillH = body.height * f;
      final r = Rect.fromLTWH(body.left, body.bottom - fillH, body.width, fillH);
      canvas.drawRect(
          r,
          Paint()
            ..shader = const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFC56B), Color(0xFFFF8FA8)],
            ).createShader(r));
      canvas.restore();
    }
    canvas.drawRRect(
        body,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..color = AppTheme.secondary500.withValues(alpha: 0.55));
    final tp = TextPainter(
      text: const TextSpan(text: '💛', style: TextStyle(fontSize: 18)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(w / 2 - tp.width / 2, h * 0.52));
  }

  @override
  bool shouldRepaint(_BagHeroPainter old) => old.fill != fill;
}

// ===========================================================================
//  OLD UI (Bag / Planner / Shopping) — replaced by _MyBagScreen above.
//  Preserved (commented out) for an easy revert, per "comment out, never delete".
// ===========================================================================
/* OLD_BAG_UI_DISABLED

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
            IconButton(
              tooltip: s.cartAddAllToCart,
              icon: const Icon(Icons.add_shopping_cart_rounded),
              onPressed: () => _addPlannedToCart(context, controller),
            ),
            cartIconButton(context, controller,
                cartId: kHospitalCartId, title: s.cartHospitalTitle),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: s.hbTabBag),
              Tab(text: s.hbTabPlanner),
              Tab(text: s.hbTabShopping),
            ],
          ),
        ),
        // Each tab listens to the store itself (see below). The TabBarView is NOT
        // wrapped in an AnimatedBuilder anymore — rebuilding it on every store
        // change, combined with a lazy DefaultTabController.of() in an onTap, left
        // a stale tab-controller dependent and crashed with "_dependents.isEmpty".
        body: TabBarView(
          children: [
            _BagView(controller: controller),
            _PlannerView(controller: controller),
            _ShoppingView(controller: controller),
          ],
        ),
      ),
    );
  }
}

/// Add the planned hospital-bag items to the (separate) hospital-bag cart.
void _addPlannedToCart(BuildContext context, PregnancyController controller) {
  final s = S(controller.language);
  final lang = controller.language;
  final store = HospitalBagStore.instance;
  var added = 0;
  for (final item in store.planned) {
    if (CartStore.instance.contains(kHospitalCartId, item.id)) continue;
    final price =
        item.plannedCost > 0 ? item.plannedCost.toDouble() : mockPriceFor(item.id);
    CartStore.instance.add(
      kHospitalCartId,
      productId: item.id,
      name: item.name.of(lang),
      emoji: '🧳',
      unitPrice: price,
    );
    added++;
  }
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(SnackBar(
      content: Text(added == 0 ? s.cartAllInCart : s.cartAddedN(added)),
      action: added == 0
          ? null
          : SnackBarAction(
              label: s.cartViewCart,
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => CartScreen(
                      controller: controller,
                      cartId: kHospitalCartId,
                      title: s.cartHospitalTitle))),
            ),
    ));
}

// ---------------------------------------------------------------------------
//  Bag View
// ---------------------------------------------------------------------------

class _BagView extends StatefulWidget {
  const _BagView({required this.controller});
  final PregnancyController controller;

  @override
  State<_BagView> createState() => _BagViewState();
}

class _BagViewState extends State<_BagView> {
  // Category cards expanded to show their items inline — so she can pack /
  // favourite right there, without drilling into a separate screen.
  final Set<BagCategory> _expanded = {};

  @override
  Widget build(BuildContext context) {
    final s = S(widget.controller.language);
    final lang = widget.controller.language;
    final store = HospitalBagStore.instance;
    // Capture the TabController during BUILD so its dependency is registered (and
    // cleaned up) properly — not lazily inside an onTap, which was the crash.
    final tabs = DefaultTabController.of(context);

    return AnimatedBuilder(
      animation: store,
      builder: (context, _) => ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          _progressCard(context, s, store, tabs),
          const SizedBox(height: 18),
          // Category cards — tap to expand and pack items inline.
          for (final c in store.activeCategories) ...[
            _categoryCard(context, s, lang, store, c),
            if (_expanded.contains(c)) ...[
              const SizedBox(height: 8),
              for (final i in store.itemsIn(c))
                _ItemRow(
                    controller: widget.controller, item: i, lang: lang, s: s),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => _CategoryScreen(
                        controller: widget.controller, category: c),
                  )),
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: Text(s.hbAddCustom),
                ),
              ),
            ],
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
      ),
    );
  }

  Widget _progressCard(
      BuildContext context, S s, HospitalBagStore store, TabController tabs) {
    final text = Theme.of(context).textTheme;
    final p = store.percentReady;
    final updated = _relativeUpdated(s, store.lastUpdated);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        // Tap to jump to the Planner (the full list of items in the bag) — uses
        // the controller captured during build, not a lazy .of() in the callback.
        onTap: () => tabs.animateTo(1),
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
        onTap: () => setState(() {
          if (!_expanded.remove(c)) _expanded.add(c);
        }),
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
            Icon(
                _expanded.contains(c)
                    ? Icons.expand_less_rounded
                    : Icons.expand_more_rounded,
                color: AppTheme.neutral400),
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
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            // Favourite heart — builds the mother's own must-have list.
            IconButton(
              tooltip: s.hbMarkFavourite,
              visualDensity: VisualDensity.compact,
              onPressed: () =>
                  HospitalBagStore.instance.toggleFavourite(item.id),
              icon: Icon(
                item.favourite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                size: 20,
                color: item.favourite
                    ? AppTheme.secondary500
                    : AppTheme.neutral400,
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppTheme.neutral400),
          ]),
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
    const keys = [
      'all',
      'fav',
      'veda',
      'else',
      'owned',
      'packed',
      'pending',
      'skipped'
    ];

    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final items = store.filter(_filter);
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
      },
    );
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

    return AnimatedBuilder(
      animation: store,
      builder: (context, _) => ListView(
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
        ),
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
          final pvPicks = products.where((p) => !p.isAffiliate).toList();
          final affiliate = products.where((p) => p.isAffiliate).toList();
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            children: [
              if (pvPicks.isNotEmpty) ...[
                Text(s.hbChooseOption,
                    style:
                        text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                for (final p in pvPicks) ...[
                  _productCard(context, s, item, p),
                  const SizedBox(height: 12),
                ],
              ],
              // Affiliate split — also available elsewhere (external links).
              if (affiliate.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(s.hbAlsoElsewhere,
                    style:
                        text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(s.hbAffiliateNote,
                    style: text.bodySmall?.copyWith(color: AppTheme.neutral500)),
                const SizedBox(height: 12),
                for (final p in affiliate) ...[
                  _productCard(context, s, item, p),
                  const SizedBox(height: 12),
                ],
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
  final affiliate = p.isAffiliate;
  // ParentVeda picks select as "buy from ParentVeda"; affiliate options select
  // as "buy elsewhere" + open the external store.
  final selected = affiliate
      ? (item.status == BagItemStatus.buyElse && item.store == p.store)
      : (item.status == BagItemStatus.buyVeda &&
          item.selectedProductId == p.id);

  void onTap() {
    if (affiliate) {
      HospitalBagStore.instance
          .setBuyElse(item.id, store: p.store, link: p.link, price: p.price);
      if (p.link.isNotEmpty) {
        launchUrl(Uri.parse(p.link), mode: LaunchMode.externalApplication);
      }
    } else {
      HospitalBagStore.instance
          .chooseVedaProduct(item.id, productId: p.id, price: p.price);
    }
  }

  return Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
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
                    if (affiliate)
                      Text('🔗 ${p.store}',
                          style: text.labelSmall?.copyWith(
                              color: AppTheme.secondary600,
                              fontWeight: FontWeight.w800))
                    else if (p.topPick)
                      Text('❤️ ${s.hbBestOverall}',
                          style: text.labelSmall?.copyWith(
                              color: AppTheme.primary600,
                              fontWeight: FontWeight.w800)),
                    Text(affiliate ? s.hbBuyOn(p.store) : p.name,
                        style: text.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(s.rupees(p.price),
                        style: text.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800)),
                  ]),
            ),
            Icon(
              affiliate
                  ? Icons.open_in_new_rounded
                  : (selected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded),
              color: affiliate
                  ? AppTheme.secondary500
                  : (selected ? AppTheme.primary500 : AppTheme.neutral300),
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

// END OLD_BAG_UI_DISABLED
*/
