// =============================================================================
//  PregWeekScreen — "Details": the baby this week, as Flo's Details page
// -----------------------------------------------------------------------------
//  2026-09-22. The user, on the home's "This week" pill: "when I click on
//  this week it's not that essential … look at their button, the way they
//  are representing — a well descriptive way, like a whole article around
//  how's your baby this week, with well put images, reviewed by, and they
//  take us to a different section. At the moment we can just simply copy
//  it and then implement our innovation over it."
//
//  Flo's Details (Mobbin §15): the baby full-bleed at the top, a chip strip
//  of weeks across the foot of the picture (… 40 weeks · 41 weeks · 42
//  weeks), and a sheet under it — "What happens at 42 weeks", Reviewed by,
//  the baby beside a watermelon with Length · Weight · Size, then prose.
//
//  Ours, in that order:
//    · the 2D figure on the peach field, big; a back round at the top
//    · the week chips — every week she has reached, the current one filled;
//      weeks ahead are dimmed and do not open (the reveal is the product)
//    · the sheet: "What happens in week N" · the desk line (ParentVeda
//      editorial — we do not have a named reviewer, so we do not print
//      one) · Length · Weight · About the size of … tiles · the milestone
//      and headline · what the baby is doing · did you know · for you this
//      week · the averages line
//
//  Opened from the figure and the Details pill on the home, and from the
//  "This week" and "About the size of" insight cards. `showPregSizeSheet`
//  stays for revert and is opened by nothing.
// =============================================================================

import 'package:flutter/material.dart';

import '../data/preg_size_sets.dart';
import '../models/week_content.dart';
import '../services/preg_size_set_store.dart';
import '../services/pregnancy_controller.dart';
import '../theme/pv_fonts.dart';
import 'v2/v2_palette.dart';
import 'v2/v3_preg_hero.dart' show PregField, kPregHalo, pregBabyArt;

const String kPregWeekRoute = 'pregnancy/week';

void openPregWeek(BuildContext context, PregnancyController c, int week) {
  Navigator.of(context).push(MaterialPageRoute<void>(
    settings: const RouteSettings(name: kPregWeekRoute),
    builder: (_) => PregWeekScreen(pregnancy: c, week: week),
  ));
}

class PregWeekScreen extends StatefulWidget {
  const PregWeekScreen({super.key, required this.pregnancy, required this.week});
  final PregnancyController pregnancy;
  final int week;

  @override
  State<PregWeekScreen> createState() => _PregWeekScreenState();
}

class _PregWeekScreenState extends State<PregWeekScreen> {
  late int _week = widget.week;
  final _chips = ScrollController();
  bool _centred = false;

  static const double _chipW = 84;

  @override
  void dispose() {
    _chips.dispose();
    super.dispose();
  }

  /// Put the open week's chip in the middle once the strip has a width.
  void _centre(double viewport) {
    if (_centred || !_chips.hasClients) return;
    _centred = true;
    final index = _week - PregnancyController.firstContentWeek;
    final target = index * (_chipW + 8) - viewport / 2 + _chipW / 2;
    _chips.jumpTo(target.clamp(0.0, _chips.position.maxScrollExtent));
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: Listenable.merge([V2PaletteStore.instance, widget.pregnancy, PregSizeSetStore.instance]),
        builder: (context, _) {
          final p = V2PaletteStore.instance.current;
          final c = widget.pregnancy;
          final content = c.weekData(_week);
          final top = MediaQuery.paddingOf(context).top;
          final artHeight = MediaQuery.sizeOf(context).height * 0.46;

          return Scaffold(
            backgroundColor: p.ground,
            body: Stack(children: [
              // The art's own colours, as on the home. Kept for revert:
              //   V3HeroField(accent: v2BlockTint(kPregFieldHue, p), …)
              Positioned.fill(child: PregField(ground: p.ground, variant: _week)),
              ListView(
                padding: EdgeInsets.zero,
                children: [
                  // ---- the figure, and the weeks across its foot -----------------
                  SizedBox(
                    height: artHeight,
                    child: Stack(children: [
                      Positioned.fill(
                        top: top + 8,
                        bottom: 56,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 260),
                          child: Image.asset(pregBabyArt(_week),
                              key: ValueKey(_week),
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.medium,
                              errorBuilder: (_, _, _) => const SizedBox.shrink()),
                        ),
                      ),
                      Positioned(
                        left: 14,
                        top: top + 8,
                        child: Material(
                          color: p.surface.withValues(alpha: 0.85),
                          shape: CircleBorder(side: BorderSide(color: p.line)),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () => Navigator.of(context).maybePop(),
                            child: SizedBox(
                                width: 38, height: 38, child: Icon(Icons.arrow_back_rounded, size: 19, color: p.ink1)),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 10,
                        height: 40,
                        child: LayoutBuilder(builder: (context, box) {
                          WidgetsBinding.instance.addPostFrameCallback((_) => _centre(box.maxWidth));
                          return ListView.separated(
                            controller: _chips,
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            itemCount: PregnancyController.lastContentWeek - PregnancyController.firstContentWeek + 1,
                            separatorBuilder: (_, _) => const SizedBox(width: 8),
                            itemBuilder: (context, i) {
                              final w = PregnancyController.firstContentWeek + i;
                              final locked = c.isLocked(w);
                              final on = w == _week;
                              return _WeekChip(
                                p: p,
                                week: w,
                                on: on,
                                locked: locked,
                                onTap: locked ? null : () => setState(() => _week = w),
                              );
                            },
                          );
                        }),
                      ),
                    ]),
                  ),

                  // ---- the sheet --------------------------------------------------
                  Container(
                    constraints: BoxConstraints(minHeight: MediaQuery.sizeOf(context).height * 0.6),
                    decoration: BoxDecoration(
                      color: p.ground,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.10), blurRadius: 24, offset: const Offset(0, -6)),
                      ],
                    ),
                    padding: EdgeInsets.fromLTRB(20, 22, 20, 40 + MediaQuery.paddingOf(context).bottom),
                    child: content == null
                        ? Text('Week $_week is on its way.',
                            style: pvManrope(fontSize: 14, color: p.ink2))
                        : _WeekBody(p: p, week: _week, content: content),
                  ),
                ],
              ),
            ]),
          );
        },
      );
}

class _WeekChip extends StatelessWidget {
  const _WeekChip({required this.p, required this.week, required this.on, required this.locked, required this.onTap});
  final V2Palette p;
  final int week;
  final bool on;
  final bool locked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: _PregWeekScreenState._chipW,
        child: Material(
          color: on ? p.ink1 : p.surface.withValues(alpha: locked ? 0.4 : 0.85),
          shape: StadiumBorder(side: BorderSide(color: on ? p.ink1 : p.line.withValues(alpha: locked ? 0.5 : 1))),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Center(
              child: Text('$week weeks',
                  style: pvManrope(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: on
                          ? p.ground
                          : locked
                              ? p.ink3.withValues(alpha: 0.6)
                              : p.ink1)),
            ),
          ),
        ),
      );
}

/// Everything the week says, in Flo's order.
class _WeekBody extends StatelessWidget {
  const _WeekBody({required this.p, required this.week, required this.content});
  final V2Palette p;
  final int week;
  final WeekContent content;

  @override
  Widget build(BuildContext context) {
    final s = content.snapshot;
    final item = pregSizeOrFallback(week, PregSizeSetStore.instance.set, s.fruit.en);
    final len = s.length.en.trim();
    final wt = s.weight.en.trim();
    final milestone = s.milestone.en.trim();
    final headline = s.weekHeadline.en.trim();
    final doing = content.development.whatImDoing.en.trim();
    final fact = content.development.funFact?.en.trim() ?? '';
    final forYou = [
      content.mom.physicalChanges.en.trim(),
      content.mom.emotionalState.en.trim(),
      content.mom.selfCareTip.en.trim(),
    ].where((t) => t.isNotEmpty).toList();

    Widget h(String t) => Text(t, style: pvFraunces(fontSize: 18, fontWeight: FontWeight.w600, color: p.ink1));
    Widget body(String t) => Text(t, style: pvManrope(fontSize: 14, height: 1.55, color: p.ink2));

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('What happens in week $week',
          style: pvFraunces(fontSize: 24, fontWeight: FontWeight.w600, height: 1.15, letterSpacing: -0.5, color: p.ink1)),
      const SizedBox(height: 6),
      // The desk, not a doctor: we have no named reviewer and will not print
      // one. The line still says whose words these are.
      Text('ParentVeda editorial · averages for the week, never a measurement of your baby',
          style: pvManrope(fontSize: 12, height: 1.45, color: p.ink3)),
      const SizedBox(height: 18),

      // ---- length · weight · size ------------------------------------------
      Row(children: [
        Expanded(child: _Tile(p: p, label: 'LENGTH', value: len.isEmpty ? '—' : len)),
        const SizedBox(width: 10),
        Expanded(child: _Tile(p: p, label: 'WEIGHT', value: wt.isEmpty ? '—' : wt)),
      ]),
      if (item != null) ...[
        const SizedBox(height: 10),
        _Tile(p: p, label: item.by == PregSizeBy.weight ? 'ABOUT AS HEAVY AS' : 'ABOUT THE SIZE OF', value: item.name, wide: true),
      ],

      if (milestone.isNotEmpty || headline.isNotEmpty) ...[
        const SizedBox(height: 22),
        Text(milestone.isNotEmpty ? milestone : headline,
            style: pvFraunces(fontSize: 20, fontWeight: FontWeight.w600, height: 1.2, color: p.ink1)),
        if (milestone.isNotEmpty && headline.isNotEmpty) ...[const SizedBox(height: 6), body(headline)],
      ],
      if (doing.isNotEmpty) ...[const SizedBox(height: 18), h('What your baby is doing'), const SizedBox(height: 6), body(doing)],
      if (fact.isNotEmpty) ...[
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(color: kPregHalo.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(14)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('DID YOU KNOW',
                style: pvManrope(fontSize: 9.5, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: p.ink3)),
            const SizedBox(height: 4),
            Text(fact, style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink1)),
          ]),
        ),
      ],
      if (forYou.isNotEmpty) ...[
        const SizedBox(height: 18),
        h('For you this week'),
        const SizedBox(height: 6),
        for (final line in forYou) ...[body(line), const SizedBox(height: 8)],
      ],
      const SizedBox(height: 10),
      Text('Averages for week $week. Every baby grows at their own pace, and your scan is what counts, not this page.',
          style: pvManrope(fontSize: 12, height: 1.45, color: p.ink3)),
    ]);
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.p, required this.label, required this.value, this.wide = false});
  final V2Palette p;
  final String label;
  final String value;
  final bool wide;

  @override
  Widget build(BuildContext context) => Container(
        width: wide ? double.infinity : null,
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(14)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: pvManrope(fontSize: 9.5, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: p.ink3)),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: pvJakarta(fontSize: 20, fontWeight: FontWeight.w800, color: p.ink1)),
          ),
        ]),
      );
}
