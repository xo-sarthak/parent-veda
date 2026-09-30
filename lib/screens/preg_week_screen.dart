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
import '../data/preg_week_extras.dart';
import '../data/symptoms/symptom_library.dart' show symptomById;
import 'symptoms/door/symptoms_today_body.dart' show openSymptomRead;
import '../models/week_content.dart';
import '../services/preg_size_set_store.dart';
import '../services/pregnancy_controller.dart';
import '../theme/pv_fonts.dart';
import 'v2/v2_palette.dart';
import 'v2/v3_preg_hero.dart' show PregField, pregBabyArt;
import 'pregnancy/preg_twins.dart';
import 'pregnancy/preg_chrome.dart' show pregSectionHeadingStyle;
import 'products/pv_store_chrome.dart' show kPvLine;

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

  // ⚠️ WEEKS 1 TO 3 AND 41 TO 42, 2026-09-29 (pregnancy gap analysis,
  // "Behind · Week by week", P2: "Every week she can be in has a page").
  // The chip row is one "1 to 3 weeks" chip (it stands for week 3), then 4
  // to 40 from weekContent.json, then 41 and 42. Those pages come from
  // `kPregSpecialWeekPages`; the figure stays at the week 4 or week 40 art.
  static const int _chipCount = 40;
  static int _chipWeek(int i) => i == 0 ? 3 : i + 3;
  static int _chipIndex(int week) => week <= 3 ? 0 : week - 3;

  @override
  void dispose() {
    _chips.dispose();
    super.dispose();
  }

  /// Put the open week's chip in the middle once the strip has a width.
  void _centre(double viewport) {
    if (_centred || !_chips.hasClients) return;
    _centred = true;
    final index = _chipIndex(_week);
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
          final special = pregSpecialPageFor(_week);
          final top = MediaQuery.paddingOf(context).top;
          final artHeight = MediaQuery.sizeOf(context).height * 0.46;

          return Scaffold(
            backgroundColor: p.ground,
            body: Stack(children: [
              // The art's own colours, as on the home. Kept for revert:
              //   V3HeroField(accent: v2BlockTint(kPregFieldHue, p), …)
              Positioned.fill(child: PregField(ground: p.ground, variant: _week.clamp(4, 40))),
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
                            // Was lastContentWeek - firstContentWeek + 1 (4 to 40).
                            itemCount: _chipCount,
                            separatorBuilder: (_, _) => const SizedBox(width: 8),
                            itemBuilder: (context, i) {
                              final w = _chipWeek(i);
                              // 41 and 42 open once she reaches 40, so the
                              // page is there before she needs it.
                              final locked = c.isLocked(w > 40 ? 40 : w);
                              final on = w == _week;
                              return _WeekChip(
                                p: p,
                                week: w,
                                label: pregSpecialPageFor(w)?.chipLabel,
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
                    child: special != null
                        ? _SpecialWeekBody(p: p, page: special)
                        : content == null
                            ? Text('Week $_week is on its way.',
                                style: pvManrope(fontSize: 14, color: p.ink2))
                            : _WeekBody(p: p, week: _week, content: content, pregnancy: c),
                  ),
                ],
              ),
            ]),
          );
        },
      );
}

class _WeekChip extends StatelessWidget {
  const _WeekChip({required this.p, required this.week, this.label, required this.on, required this.locked, required this.onTap});
  final V2Palette p;
  final int week;

  /// "1 to 3 weeks" for the special chip; null draws "N weeks".
  final String? label;
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
              child: Text(label ?? '$week weeks',
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
///
/// ⚠️ GREW 2026-09-29 (pregnancy gap analysis, "Behind · Week by week", P1:
/// "Show everything we already wrote for each week"). The mother's page had
/// stopped drawing half of weekContent.json on 21 September; only the
/// father's week stack still showed it. The sheet now continues, in the same
/// heading and body styles, with: the month and trimester, her body this week
/// (each symptom with a tip, opening its Symptoms page where there is one),
/// do this and skip this, Asked this week, myth or fact, call your doctor if,
/// for your partner, and where this comes from. The earlier order is kept
/// above them unchanged.
class _WeekBody extends StatelessWidget {
  const _WeekBody({
    required this.p,
    required this.week,
    required this.content,
    required this.pregnancy,
  });
  final V2Palette p;
  final int week;
  final WeekContent content;
  final PregnancyController pregnancy;

  @override
  Widget build(BuildContext context) {
    final s = content.snapshot;
    final item = pregSizeOrFallback(
      week,
      PregSizeSetStore.instance.set,
      s.fruit.en,
    );
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
    final extra = kPregWeekExtras[week];
    final plan = content.actionPlan;
    final doThis = plan.doThisWeek.en.trim();
    final skipThis = plan.skipThisWeek.en.trim();
    final myth = plan.mythBuster.myth.en.trim();
    final truth = plan.mythBuster.truth.en.trim();
    final redFlags = plan.redFlags.en.trim();
    final partner = content.partner.whatYouCanDo.en.trim();
    final symptoms = [
      for (final sym in content.mom.commonSymptoms)
        if (sym.en.trim().isNotEmpty) sym.en.trim(),
    ];

    // One section heading (one ParentVeda, 2026-09-30). Was pvFraunces 18.
    Widget h(String t) => Semantics(
      header: true,
      child: Text(t, style: pregSectionHeadingStyle()),
    );
    Widget body(String t) =>
        Text(t, style: pvManrope(fontSize: 14, height: 1.55, color: p.ink2));

    PregWeekSymptomTip? tipFor(String label) {
      for (final t in extra?.symptomTips ?? const <PregWeekSymptomTip>[]) {
        if (t.symptom == label) return t;
      }
      return null;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What happens in week $week',
          style: pvFraunces(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            height: 1.15,
            letterSpacing: -0.5,
            color: p.ink1,
          ),
        ),
        const SizedBox(height: 6),
        // Month and trimester, the question she asks every week (gap analysis:
        // "How many months pregnant are you now?").
        Text(
          'Week $week · Month ${pregMonthFor(week)} · ${pregTrimesterFor(week)}',
          style: pvManrope(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            height: 1.4,
            color: p.ink1,
          ),
        ),
        const SizedBox(height: 4),
        // The desk, not a doctor: we have no named reviewer and will not print
        // one. The line still says whose words these are.
        Text(
          'ParentVeda editorial · averages for the week, never a measurement of your ${pregBabies()}',
          style: pvManrope(fontSize: 12, height: 1.45, color: p.ink3),
        ),
        if (pregExpectingTwins) ...[
          const SizedBox(height: 6),
          Text(kPregTwinWeekNote, style: pvManrope(fontSize: 12, height: 1.45, color: p.ink3)),
        ],
        const SizedBox(height: 18),

        // ---- length · weight · size ------------------------------------------
        Row(
          children: [
            Expanded(
              child: _Tile(
                p: p,
                label: 'LENGTH',
                value: len.isEmpty ? '—' : len,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _Tile(p: p, label: 'WEIGHT', value: wt.isEmpty ? '—' : wt),
            ),
          ],
        ),
        if (item != null) ...[
          const SizedBox(height: 10),
          _Tile(
            p: p,
            label: item.by == PregSizeBy.weight
                ? 'ABOUT AS HEAVY AS'
                : 'ABOUT THE SIZE OF',
            value: item.name,
            wide: true,
          ),
        ],

        if (milestone.isNotEmpty || headline.isNotEmpty) ...[
          const SizedBox(height: 22),
          Text(
            milestone.isNotEmpty ? milestone : headline,
            style: pvFraunces(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              height: 1.2,
              color: p.ink1,
            ),
          ),
          if (milestone.isNotEmpty && headline.isNotEmpty) ...[
            const SizedBox(height: 6),
            body(headline),
          ],
        ],
        if (doing.isNotEmpty) ...[
          const SizedBox(height: 18),
          // Kept for revert: h('What your baby is doing'),
          h('What your ${pregBabies()} ${pregExpectingTwins ? 'are' : 'is'} doing'),
          const SizedBox(height: 6),
          body(doing),
        ],
        if (fact.isNotEmpty) ...[
          const SizedBox(height: 14),
          _Note(p: p, label: 'DID YOU KNOW', text: fact),
        ],

        // ---- her body this week ----------------------------------------------
        if (symptoms.isNotEmpty) ...[
          const SizedBox(height: 22),
          h('Your body this week'),
          const SizedBox(height: 8),
          for (final label in symptoms)
            _SymptomRow(
              p: p,
              label: label,
              tip: tipFor(label)?.tip,
              onTap: switch (tipFor(label)?.symptomId) {
                final id? when symptomById(id) != null => () => openSymptomRead(
                  context,
                  symptomById(id)!,
                  pregnancy,
                ),
                _ => null,
              },
            ),
        ],
        if (forYou.isNotEmpty) ...[
          const SizedBox(height: 18),
          h('For you this week'),
          const SizedBox(height: 6),
          for (final line in forYou) ...[body(line), const SizedBox(height: 8)],
        ],

        // ---- do this, skip this ------------------------------------------------
        if (doThis.isNotEmpty || skipThis.isNotEmpty) ...[
          const SizedBox(height: 18),
          h('This week'),
          const SizedBox(height: 8),
          if (doThis.isNotEmpty)
            _Labelled(p: p, label: 'DO THIS', text: doThis),
          if (skipThis.isNotEmpty) ...[
            const SizedBox(height: 8),
            _Labelled(p: p, label: 'SKIP THIS', text: skipThis),
          ],
        ],

        // ---- asked this week ---------------------------------------------------
        if (extra != null && extra.asked.isNotEmpty) ...[
          const SizedBox(height: 22),
          h('Asked this week'),
          const SizedBox(height: 4),
          for (final qa in extra.asked) _Question(p: p, q: qa.q, a: qa.a),
        ],

        // ---- myth or fact ------------------------------------------------------
        if (myth.isNotEmpty && truth.isNotEmpty) ...[
          const SizedBox(height: 18),
          _Note(p: p, label: 'MYTH OR FACT', title: myth, text: truth),
        ],

        // ---- call your doctor --------------------------------------------------
        if (redFlags.isNotEmpty) ...[
          const SizedBox(height: 18),
          _Urgent(p: p, text: redFlags),
        ],

        // ---- for your partner --------------------------------------------------
        if (partner.isNotEmpty) ...[
          const SizedBox(height: 22),
          h('For your partner'),
          const SizedBox(height: 6),
          body(partner),
        ],

        if (extra != null && extra.sources.isNotEmpty) ...[
          const SizedBox(height: 22),
          _Sources(p: p, keys: extra.sources),
        ],
        const SizedBox(height: 10),
        Text(
          'Averages for week $week. Every baby grows at their own pace, and your scan is what counts, not this page.',
          style: pvManrope(fontSize: 12, height: 1.45, color: p.ink3),
        ),
      ],
    );
  }
}

/// Weeks 1 to 3, 41 and 42: a written page in the same sheet.
class _SpecialWeekBody extends StatelessWidget {
  const _SpecialWeekBody({required this.p, required this.page});
  final V2Palette p;
  final PregSpecialWeekPage page;

  @override
  Widget build(BuildContext context) {
    // One section heading (one ParentVeda, 2026-09-30). Was pvFraunces 18.
    Widget h(String t) => Semantics(
      header: true,
      child: Text(t, style: pregSectionHeadingStyle()),
    );
    Widget body(String t) =>
        Text(t, style: pvManrope(fontSize: 14, height: 1.55, color: p.ink2));
    final w = page.weeks.last;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          page.title,
          style: pvFraunces(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            height: 1.15,
            letterSpacing: -0.5,
            color: p.ink1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          w <= 3
              ? 'Weeks 1 to 3 · Month 1 · First trimester'
              : 'Week $w · Past your due date',
          style: pvManrope(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            height: 1.4,
            color: p.ink1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'ParentVeda editorial',
          style: pvManrope(fontSize: 12, height: 1.45, color: p.ink3),
        ),
        const SizedBox(height: 16),
        _Note(p: p, label: 'THE SHORT ANSWER', text: page.shortAnswer),
        for (final sec in page.sections) ...[
          const SizedBox(height: 20),
          h(sec.heading),
          const SizedBox(height: 6),
          for (final para in sec.paragraphs) ...[
            body(para),
            const SizedBox(height: 8),
          ],
          for (final b in sec.bullets)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8, right: 10),
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: p.ink3,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Expanded(child: body(b)),
                ],
              ),
            ),
        ],
        if (page.asked.isNotEmpty) ...[
          const SizedBox(height: 22),
          h('Asked this week'),
          const SizedBox(height: 4),
          for (final qa in page.asked) _Question(p: p, q: qa.q, a: qa.a),
        ],
        if (page.callYourDoctor case final c? when c.trim().isNotEmpty) ...[
          const SizedBox(height: 18),
          _Urgent(p: p, text: c),
        ],
        if (page.sources.isNotEmpty) ...[
          const SizedBox(height: 22),
          _Sources(p: p, keys: page.sources),
        ],
      ],
    );
  }
}

/// The halo card the page already used for "Did you know", now shared.
class _Note extends StatelessWidget {
  const _Note({
    required this.p,
    required this.label,
    required this.text,
    this.title,
  });
  final V2Palette p;
  final String label;
  final String? title;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
    // White with the hairline, not a tint behind the words (one ParentVeda).
    // Was: color: kPregHalo.withValues(alpha: 0.6).
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: kPvLine),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: pvManrope(
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: p.ink3,
          ),
        ),
        const SizedBox(height: 4),
        if (title != null) ...[
          Text(
            title!,
            style: pvManrope(
              fontSize: 13.5,
              height: 1.45,
              fontWeight: FontWeight.w700,
              color: p.ink1,
            ),
          ),
          const SizedBox(height: 4),
        ],
        Text(
          text,
          style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink1),
        ),
      ],
    ),
  );
}

/// A small-caps label over a line, for Do this and Skip this.
class _Labelled extends StatelessWidget {
  const _Labelled({required this.p, required this.label, required this.text});
  final V2Palette p;
  final String label;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
    // White with the hairline, not a tint behind the words. Was p.surfaceAlt.
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: kPvLine),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: pvManrope(
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: p.ink3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          text,
          style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink1),
        ),
      ],
    ),
  );
}

/// One of the week's symptoms: the name, the tip, and a chevron when it
/// opens its Symptoms page.
class _SymptomRow extends StatelessWidget {
  const _SymptomRow({
    required this.p,
    required this.label,
    this.tip,
    this.onTap,
  });
  final V2Palette p;
  final String label;
  final String? tip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Material(
      // White with the hairline (one ParentVeda). Was p.surfaceAlt.
      color: Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14), side: const BorderSide(color: kPvLine)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: pvManrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                        color: p.ink1,
                      ),
                    ),
                    if (tip != null && tip!.trim().isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        tip!,
                        style: pvManrope(
                          fontSize: 13,
                          height: 1.5,
                          color: p.ink2,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (onTap != null)
                Padding(
                  padding: const EdgeInsets.only(left: 6, top: 1),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: p.ink3,
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// A question and its answer, opened by a tap.
class _Question extends StatelessWidget {
  const _Question({required this.p, required this.q, required this.a});
  final V2Palette p;
  final String q;
  final String a;

  @override
  // Its own transparent Material: the sheet is a coloured box, and a list
  // tile paints its ripple on the nearest Material, which the box would hide.
  Widget build(BuildContext context) => Material(
    type: MaterialType.transparency,
    child: Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: 10),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        iconColor: p.ink2,
        collapsedIconColor: p.ink3,
        title: Text(
          q,
          style: pvManrope(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            height: 1.4,
            color: p.ink1,
          ),
        ),
        children: [
          Text(a, style: pvManrope(fontSize: 14, height: 1.55, color: p.ink2)),
        ],
      ),
    ),
  );
}

/// Call your doctor if: calm, but its own bordered card.
class _Urgent extends StatelessWidget {
  const _Urgent({required this.p, required this.text});
  final V2Palette p;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
    decoration: BoxDecoration(
      color: p.surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: p.ink1.withValues(alpha: 0.35), width: 1.2),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1, right: 10),
          child: Icon(Icons.local_hospital_outlined, size: 18, color: p.ink1),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CALL YOUR DOCTOR IF',
                style: pvManrope(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: p.ink3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                text,
                style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink1),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

/// Where this comes from: the week's sources, numbered, in the footnote style.
class _Sources extends StatelessWidget {
  const _Sources({required this.p, required this.keys});
  final V2Palette p;
  final List<String> keys;

  @override
  Widget build(BuildContext context) {
    final labels = [
      for (final k in keys)
        if (kPregWeekSources[k] case final s?) s.label,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Where this comes from',
          style: pvManrope(
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
            color: p.ink2,
          ),
        ),
        const SizedBox(height: 6),
        for (var i = 0; i < labels.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '${i + 1}. ${labels[i]}',
              style: pvManrope(fontSize: 11.5, height: 1.45, color: p.ink3),
            ),
          ),
      ],
    );
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
        // White with the hairline (one ParentVeda). Was p.surfaceAlt.
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: kPvLine)),
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
