// =============================================================================
//  Can I eat this? — one bar, two libraries, one scroll
// -----------------------------------------------------------------------------
//  Sub-tab 1 of the Nutrition door, rendered in place. Built from the Claude
//  Design prototype `Can I Eat This.dc.html` (project 9df51a8c…, 2026-09-11),
//  which was drawn against `docs/design-prompts/CAN-I-EAT-THIS-DESIGN-PROMPT.md`.
//
//  ⚠️ THE FOLD WAS RIGHT AND THE SCROLL WAS THE PROBLEM. The first version of
//  this file was `FoodCheckBody` stacked over `CravingsBody` with a heading at
//  the seam — sixty-four food rows before "Cravings" appeared. Seen on a phone.
//  The design's answer, kept whole here:
//
//    · **The 64 rows fold into eight category cards.** Cravings begin one
//      screen down instead of sixty-four rows down. Opening a category opens
//      its rows under the grid; nothing navigates.
//    · **One search bar, and it filters the page rather than covering it.**
//      Results land inside the two sections that already name their own
//      vocabulary. The full-screen search delegate still exists for the
//      standalone `FoodCheckScreen`; this body does not use it.
//    · **The seam is carried by shape, not by a heading.** A food verdict is
//      ALWAYS a hairline capsule with a dot — Safe · Limit · Avoid. A craving
//      answer is ALWAYS a serif word with a week stamp — Yes · In small
//      amounts · Not now. The two vocabularies never wear the same badge, so
//      the second list cannot read as the first one disagreeing with itself.
//    · **Answers open in place.** A most-searched chip answers under the chip
//      row; a list row expands where it sits. Nothing pushes a page — the
//      house rule against bottom sheets and the brief's "not a new screen
//      unless you can argue for it", and the design argued for none.
//
//  ⚠️ TWO DEPARTURES FROM THE PROTOTYPE, BOTH DELIBERATE:
//
//    · **The food row also carries `myth`** as a "Worth knowing" fact. The
//      prototype showed reason and how-much only, because it had no myth text
//      to show. "One bite of papaya and you will miscarry is not true" is the
//      best line in the library, and dropping it from the only place the row
//      now opens would be a content regression the design did not intend.
//    · **No footer disclaimer here.** The prototype ends with "General
//      guidance, not a diagnosis…"; the door already renders
//      `PvDoorDisclaimer` under every tab. A safety line repeated is a safety
//      line devalued — see STILL-OPEN §38.1.
//
//  ⚠️ THE DATA IS THE LIBRARIES', NOT THE PROTOTYPE'S. The prototype carried
//  invented foods to make the grouping legible. Everything here reads
//  `kFoodEntries`, `foodsByCategory`, `searchFoods`, `kCravingItems` and
//  `verdictAt(trimester)` — the same values the standalone screens and Ask
//  Veda use — so the door and the pages cannot drift.
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/cravings_data.dart';
import '../../data/nutrition_data.dart';
import '../../localization/app_language.dart';
import '../../services/pregnancy_controller.dart';
import '../../theme/pv_fonts.dart';
import '../v2/v2_palette.dart';

/// The Nutrition door's hue, and this tab's.
const double _hue = 104;

/// The week stamp's hue — a soft amber, distinct from the tab so the stamp
/// reads as "about her" rather than "about the section".
const double _stampHue = 32;

int _trimesterOf(int week) => week < 14 ? 1 : week < 28 ? 2 : 3;

/// A food verdict's colour. Muted on purpose — `Avoid` is a clay, never a
/// stop-sign red. The word beside the dot does the work; the dot is a glance.
Color _foodDot(NutritionVerdict v) => switch (v) {
      NutritionVerdict.safe => const HSLColor.fromAHSL(1, 104, .30, .34).toColor(),
      NutritionVerdict.limit => const HSLColor.fromAHSL(1, 38, .46, .38).toColor(),
      NutritionVerdict.avoid => const HSLColor.fromAHSL(1, 14, .30, .44).toColor(),
    };

/// A craving answer's word. Never a colour: a serif word is the craving
/// vocabulary's whole badge, which is what keeps it from looking like a food
/// verdict.
String _cravingWord(NutritionVerdict v) => switch (v) {
      NutritionVerdict.safe => 'Yes',
      NutritionVerdict.limit => 'In small amounts',
      NutritionVerdict.avoid => 'Not now',
    };

class CanIEatBody extends StatefulWidget {
  const CanIEatBody({super.key, required this.pregnancy});

  final PregnancyController pregnancy;

  @override
  State<CanIEatBody> createState() => _CanIEatBodyState();
}

class _CanIEatBodyState extends State<CanIEatBody> {
  final _q = TextEditingController();
  FoodCategory? _cat;
  String? _chip;
  String? _food;
  String? _craving;
  String? _offer;

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  void _setQuery(String _) => setState(() {
        _food = null;
        _craving = null;
        _chip = null;
        _offer = null;
      });

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: V2PaletteStore.instance,
        builder: (context, _) {
          final p = V2PaletteStore.instance.current;
          final week = widget.pregnancy.currentWeek;
          final tri = _trimesterOf(week);
          final lang = widget.pregnancy.language;
          final q = _q.text.trim();
          final searching = q.isNotEmpty;

          // ---- what the food section shows -------------------------------
          List<FoodEntry> foodRows;
          String foodListTitle;
          if (searching) {
            foodRows = searchFoods(q);
            foodListTitle = '${foodRows.length} in foods';
          } else if (_cat != null) {
            foodRows = foodsByCategory(_cat!);
            foodListTitle = _cat!.label.of(lang);
          } else {
            foodRows = const [];
            foodListTitle = '';
          }

          // ---- what the cravings section shows ---------------------------
          final cravingRows = searching
              ? kCravingItems.where((c) => c.matches(q)).toList()
              : kCravingItems;

          final chipEntry = _chip == null ? null : foodById(_chip!);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- the one bar ---------------------------------------------
              _SearchBar(
                controller: _q,
                p: p,
                onChanged: _setQuery,
                onClear: () {
                  _q.clear();
                  _setQuery('');
                },
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Text(
                    'One bar, two libraries. Foods are answered for all of '
                    'pregnancy; cravings for the week you are in.',
                    style: pvManrope(
                        fontSize: 12, height: 1.45, color: p.ink3)),
              ),

              // ---- most searched, with the answer under the chips ----------
              if (!searching) ...[
                const SizedBox(height: 26),
                _Eyebrow('Most searched', p: p),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final m in kMostSearchedFoods)
                      if (foodById(m.id) case final e?)
                        _Pill(
                          label: e.name.of(lang),
                          selected: _chip == e.id,
                          p: p,
                          onTap: () => setState(() {
                            _chip = _chip == e.id ? null : e.id;
                            _offer = null;
                          }),
                        ),
                  ],
                ),
                if (chipEntry != null) ...[
                  const SizedBox(height: 14),
                  _ChipAnswer(
                    entry: chipEntry,
                    p: p,
                    lang: lang,
                    week: week,
                    // ⚠️ `foodId` IS THE LINK, NOT A NAME MATCH. The prototype
                    // matched names; the model already says which craving is
                    // the same food, so the two cannot drift.
                    craving: _cravingForFood(chipEntry.id),
                    onCraving: (c) => setState(() {
                      _craving = c.id;
                      _chip = null;
                      _offer = null;
                    }),
                  ),
                ],
              ],

              // ---- all foods -----------------------------------------------
              const SizedBox(height: 26),
              _Eyebrow('All foods', p: p),
              const SizedBox(height: 4),
              Text(
                  '${kFoodEntries.length} foods · Safe, Limit or Avoid · '
                  'answered for all of pregnancy',
                  style: pvManrope(fontSize: 12, height: 1.45, color: p.ink3)),
              const SizedBox(height: 12),

              if (!searching)
                _CategoryGrid(
                  selected: _cat,
                  p: p,
                  lang: lang,
                  onTap: (c) => setState(() {
                    _cat = _cat == c ? null : c;
                    _food = null;
                  }),
                ),

              if (foodRows.isNotEmpty) ...[
                if (!searching) const SizedBox(height: 12),
                _FoodList(
                  title: foodListTitle,
                  rows: foodRows,
                  open: _food,
                  p: p,
                  lang: lang,
                  onClose: searching
                      ? null
                      : () => setState(() {
                            _cat = null;
                            _food = null;
                          }),
                  onRow: (id) => setState(() => _food = _food == id ? null : id),
                ),
              ],

              if (searching && foodRows.isEmpty)
                _Empty(
                  title: 'Not in the food library yet',
                  body: '${kFoodEntries.length} foods are answered here. If '
                      'yours is missing, the cravings below may still cover '
                      'it — and anything specific is worth one question to '
                      'your doctor.',
                  p: p,
                ),

              // ---- the seam, carried by shape ------------------------------
              const SizedBox(height: 26),
              Container(height: 1, color: p.line),
              const SizedBox(height: 18),
              _Eyebrow('Cravings', p: p),
              const SizedBox(height: 6),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 6,
                children: [
                  _WeekStamp(week: week, p: p),
                  Text(
                      '${kCravingItems.length} cravings · Yes or In small '
                      'amounts · answered for the week you are in',
                      style: pvManrope(
                          fontSize: 12, height: 1.45, color: p.ink3)),
                ],
              ),
              const SizedBox(height: 12),

              if (cravingRows.isNotEmpty)
                _CravingList(
                  rows: cravingRows,
                  open: _craving,
                  offerOpen: _offer,
                  tri: tri,
                  week: week,
                  p: p,
                  lang: lang,
                  onRow: (id) => setState(() {
                    _craving = _craving == id ? null : id;
                    _offer = null;
                  }),
                  onOffer: (id) =>
                      setState(() => _offer = _offer == id ? null : id),
                ),

              if (searching && cravingRows.isEmpty)
                _Empty(
                  title: 'No craving by that name',
                  body: '${kCravingItems.length} cravings are answered for '
                      'the week you are in. Try the feeling rather than the '
                      'dish — sour, salty, cold, very spicy.',
                  p: p,
                ),
            ],
          );
        },
      );

  CravingItem? _cravingForFood(String foodId) {
    for (final c in kCravingItems) {
      if (c.foodId == foodId) return c;
    }
    return null;
  }
}

// -----------------------------------------------------------------------------
//  Pieces
// -----------------------------------------------------------------------------

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.p,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final V2Palette p;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) => Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: p.line),
        ),
        child: Row(children: [
          Icon(Icons.search_rounded, size: 19, color: p.ink3),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: pvManrope(
                  fontSize: 14, fontWeight: FontWeight.w600, color: p.ink1),
              decoration: InputDecoration(
                isDense: true,
                // ⚠️ `filled: false` — the app theme fills every input grey
                // inside the white pill this bar draws. See the conditions
                // search field for the lesson.
                filled: false,
                border: InputBorder.none,
                // ⚠️ AND THE FOCUSED ONE. `border` is the fallback; the theme
                // sets `focusedBorder` separately, so a focused field grew a
                // purple ring inside its own white pill. Seen on a phone.
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: 'Type any food or craving',
                hintStyle: pvManrope(
                    fontSize: 14, fontWeight: FontWeight.w600, color: p.ink3),
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            GestureDetector(
              onTap: onClear,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: p.surfaceAlt,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Icon(Icons.close_rounded, size: 15, color: p.ink2),
              ),
            ),
        ]),
      );
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow(this.text, {required this.p});
  final String text;
  final V2Palette p;
  @override
  Widget build(BuildContext context) => Text(text.toUpperCase(),
      style: pvManrope(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: p.ink3));
}

/// A most-searched chip. Selected is the tab's tint with an ink edge.
class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.selected,
    required this.p,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final V2Palette p;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        // ⚠️ NO `alignment` ON THIS CONTAINER. With `alignment` set and no
        // width, a Container sizes to the widest constraint it is given — and
        // inside a `Wrap` that is the whole row, so every chip rendered
        // full-width, one per line. Seen on a phone. A min-size Row keeps the
        // pill the width of its word.
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: selected ? v2BlockTint(_hue, p) : p.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
                color: selected ? p.ink1 : p.line, width: selected ? 1.5 : 1),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(label,
                style: pvManrope(
                    fontSize: 13, fontWeight: FontWeight.w700, color: p.ink1)),
          ]),
        ),
      );
}

/// The food vocabulary's badge: a hairline capsule with a dot and the word.
class _FoodCapsule extends StatelessWidget {
  const _FoodCapsule({required this.verdict, required this.p, required this.lang});
  final NutritionVerdict verdict;
  final V2Palette p;
  final AppLanguage lang;
  @override
  Widget build(BuildContext context) => Container(
        height: 26,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: p.line),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
                color: _foodDot(verdict), shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(verdict.label.of(lang).toUpperCase(),
              style: pvManrope(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.9,
                  color: p.ink1)),
        ]),
      );
}

/// The craving vocabulary's stamp: her week, in the amber tint.
class _WeekStamp extends StatelessWidget {
  const _WeekStamp({required this.week, required this.p});
  final int week;
  final V2Palette p;
  @override
  Widget build(BuildContext context) => Container(
        height: 22,
        padding: const EdgeInsets.symmetric(horizontal: 9),
        decoration: BoxDecoration(
          color: v2BlockTint(_stampHue, p),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text('WEEK $week',
              style: pvManrope(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: p.ink1)),
        ]),
      );
}

/// A labelled fact — "How much", "Worth knowing", "Five minutes".
class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.child, required this.p});
  final String label;
  final Widget child;
  final V2Palette p;
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 11),
        decoration: BoxDecoration(
          color: p.surfaceAlt,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label.toUpperCase(),
              style: pvManrope(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  color: p.ink3)),
          const SizedBox(height: 4),
          child,
        ]),
      );
}

Widget _body(String s, V2Palette p, {Color? color}) => Text(s,
    style: pvManrope(fontSize: 13, height: 1.5, color: color ?? p.ink2));

/// The chip's answer, under the chip row.
class _ChipAnswer extends StatelessWidget {
  const _ChipAnswer({
    required this.entry,
    required this.p,
    required this.lang,
    required this.week,
    required this.craving,
    required this.onCraving,
  });
  final FoodEntry entry;
  final V2Palette p;
  final AppLanguage lang;
  final int week;
  final CravingItem? craving;
  final ValueChanged<CravingItem> onCraving;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: p.line),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: Text(entry.name.of(lang),
                  style: pvFraunces(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                      letterSpacing: -0.4,
                      color: p.ink1)),
            ),
            const SizedBox(width: 12),
            _FoodCapsule(verdict: entry.verdict, p: p, lang: lang),
          ]),
          const SizedBox(height: 10),
          _body(entry.lines.of(lang), p),
          ..._foodFacts(entry, p, lang),
          if (craving != null) ...[
            const SizedBox(height: 12),
            Container(height: 1, color: p.line),
            const SizedBox(height: 12),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 6,
              children: [
                _WeekStamp(week: week, p: p),
                GestureDetector(
                  onTap: () => onCraving(craving!),
                  behavior: HitTestBehavior.opaque,
                  child: Text('Craving it? Answered for your week',
                      style: pvManrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: p.action)),
                ),
              ],
            ),
          ],
        ]),
      );
}

/// The facts a food carries once opened: how much (limit only), and the myth.
List<Widget> _foodFacts(FoodEntry e, V2Palette p, AppLanguage lang) => [
      if (e.limitGuidance case final g?) ...[
        const SizedBox(height: 12),
        _Fact(label: 'How much', p: p, child: _body(g.of(lang), p, color: p.ink1)),
      ],
      if (e.myth case final m?) ...[
        const SizedBox(height: 10),
        _Fact(label: 'Worth knowing', p: p, child: _body(m.of(lang), p, color: p.ink1)),
      ],
    ];

/// Eight category cards in two columns. A count in a tinted well, then the
/// label — the whole library legible in one screen.
class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({
    required this.selected,
    required this.p,
    required this.lang,
    required this.onTap,
  });
  final FoodCategory? selected;
  final V2Palette p;
  final AppLanguage lang;
  final ValueChanged<FoodCategory> onTap;

  @override
  Widget build(BuildContext context) {
    final tint = v2BlockTint(_hue, p);
    final deep = HSLColor.fromColor(tint)
        .withSaturation(0.30)
        .withLightness(0.26)
        .toColor();
    return LayoutBuilder(builder: (context, c) {
      const gap = 8.0;
      final w = (c.maxWidth - gap) / 2;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          for (final cat in FoodCategory.values)
            SizedBox(
              width: w,
              child: GestureDetector(
                onTap: () => onTap(cat),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 140),
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: selected == cat ? tint : p.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: selected == cat ? p.ink1 : p.line,
                        width: selected == cat ? 1.5 : 1),
                  ),
                  child: Row(children: [
                    Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: tint,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Text('${foodsByCategory(cat).length}',
                          style: pvFraunces(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: deep)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(cat.label.of(lang),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: pvManrope(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                              color: p.ink1)),
                    ),
                  ]),
                ),
              ),
            ),
        ],
      );
    });
  }
}

/// A category's rows, or a search's. Each row expands where it sits.
class _FoodList extends StatelessWidget {
  const _FoodList({
    required this.title,
    required this.rows,
    required this.open,
    required this.p,
    required this.lang,
    required this.onClose,
    required this.onRow,
  });
  final String title;
  final List<FoodEntry> rows;
  final String? open;
  final V2Palette p;
  final AppLanguage lang;
  final VoidCallback? onClose;
  final ValueChanged<String> onRow;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: p.line),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: Text(title,
                      style: pvFraunces(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.3,
                          color: p.ink1)),
                ),
                if (onClose != null)
                  GestureDetector(
                    onTap: onClose,
                    behavior: HitTestBehavior.opaque,
                    child: Text('Close',
                        style: pvManrope(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: p.action)),
                  ),
              ],
            ),
          ),
          for (final f in rows) ...[
            Container(height: 1, color: p.line),
            GestureDetector(
              onTap: () => onRow(f.id),
              behavior: HitTestBehavior.opaque,
              child: Container(
                constraints: const BoxConstraints(minHeight: 46),
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(children: [
                  Expanded(
                    child: Text(f.name.of(lang),
                        style: pvManrope(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: p.ink1)),
                  ),
                  const SizedBox(width: 10),
                  _FoodCapsule(verdict: f.verdict, p: p, lang: lang),
                ]),
              ),
            ),
            if (open == f.id)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _body(f.lines.of(lang), p),
                    ..._foodFacts(f, p, lang),
                  ],
                ),
              ),
          ],
        ]),
      );
}

/// The cravings, each answered for her trimester, each expanding in place.
class _CravingList extends StatelessWidget {
  const _CravingList({
    required this.rows,
    required this.open,
    required this.offerOpen,
    required this.tri,
    required this.week,
    required this.p,
    required this.lang,
    required this.onRow,
    required this.onOffer,
  });
  final List<CravingItem> rows;
  final String? open;
  final String? offerOpen;
  final int tri;
  final int week;
  final V2Palette p;
  final AppLanguage lang;
  final ValueChanged<String> onRow;
  final ValueChanged<String> onOffer;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 4, 14, 4),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: p.line),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          for (final c in rows) ...[
            if (c != rows.first) Container(height: 1, color: p.line),
            GestureDetector(
              onTap: () => onRow(c.id),
              behavior: HitTestBehavior.opaque,
              child: Container(
                constraints: const BoxConstraints(minHeight: 46),
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(children: [
                  Expanded(
                    child: Text(c.name.of(lang),
                        style: pvManrope(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: p.ink1)),
                  ),
                  const SizedBox(width: 10),
                  // ⚠️ A SERIF WORD, NOT A CAPSULE. This is the whole of the
                  // craving vocabulary's badge, and the reason a `Yes` two
                  // rows under a `SAFE` does not read as a contradiction.
                  Text(_cravingWord(c.verdictAt(tri)),
                      style: pvFraunces(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                          color: p.ink1)),
                ]),
              ),
            ),
            if (open == c.id)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _CravingDetail(
                  item: c,
                  tri: tri,
                  week: week,
                  p: p,
                  lang: lang,
                  offerOpen: offerOpen == c.id,
                  onOffer: () => onOffer(c.id),
                ),
              ),
          ],
        ]),
      );
}

class _CravingDetail extends StatelessWidget {
  const _CravingDetail({
    required this.item,
    required this.tri,
    required this.week,
    required this.p,
    required this.lang,
    required this.offerOpen,
    required this.onOffer,
  });
  final CravingItem item;
  final int tri;
  final int week;
  final V2Palette p;
  final AppLanguage lang;
  final bool offerOpen;
  final VoidCallback onOffer;

  @override
  Widget build(BuildContext context) {
    final verdict = item.verdictAt(tri);
    final stageNote = item.stageNoteAt(tri);
    // ⚠️ ALTERNATIVES ONLY WHEN THE ANSWER IS NOT A PLAIN YES — the model's
    // own rule: a substitute for something she can simply have reads as
    // disapproval dressed up as help.
    final showAlternatives =
        item.alternatives.isNotEmpty && verdict != NutritionVerdict.safe;
    final recipe = item.recipe;
    final offerLabel = recipe != null
        ? 'A ${recipe.minutes}-minute version'
        : showAlternatives
            ? 'A safer version'
            : null;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        runSpacing: 6,
        children: [
          _WeekStamp(week: week, p: p),
          if (stageNote != null)
            Text(stageNote.of(lang),
                style: pvManrope(fontSize: 12, height: 1.45, color: p.ink3)),
        ],
      ),
      const SizedBox(height: 10),
      _body(item.why.of(lang), p),
      if (item.modification case final m?) ...[
        const SizedBox(height: 10),
        _Fact(label: 'Worth knowing', p: p, child: _body(m.of(lang), p, color: p.ink1)),
      ],
      if (item.whenToAvoid case final w?) ...[
        const SizedBox(height: 10),
        _Fact(label: 'When to skip it', p: p, child: _body(w.of(lang), p, color: p.ink1)),
      ],
      if (item.talkToDoctor) ...[
        const SizedBox(height: 10),
        Text('Worth a word with your doctor — this one can point at low iron.',
            style: pvManrope(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                height: 1.45,
                color: p.ink2)),
      ],
      if (offerLabel != null) ...[
        const SizedBox(height: 12),
        Row(mainAxisSize: MainAxisSize.min, children: [
          GestureDetector(
            onTap: onOffer,
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: offerOpen ? v2BlockTint(_hue, p) : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
                border:
                    Border.all(color: offerOpen ? p.ink1 : p.line, width: 1.2),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(offerLabel,
                    style: pvManrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: offerOpen ? p.ink1 : p.ink3)),
              ]),
            ),
          ),
        ]),
        if (offerOpen) ...[
          const SizedBox(height: 10),
          if (recipe != null)
            _Fact(
              label: '${recipe.name.of(lang)} · ${recipe.minutes} min',
              p: p,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _body(recipe.ingredients.map((i) => i.of(lang)).join(' · '),
                      p),
                  const SizedBox(height: 8),
                  for (var i = 0; i < recipe.steps.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: _body('${i + 1}. ${recipe.steps[i].of(lang)}', p,
                          color: p.ink1),
                    ),
                  if (recipe.note case final n?) ...[
                    const SizedBox(height: 4),
                    _body(n.of(lang), p),
                  ],
                ],
              ),
            )
          else
            _Fact(
              label: 'Instead',
              p: p,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final a in item.alternatives)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: _body('• ${a.of(lang)}', p, color: p.ink1),
                    ),
                ],
              ),
            ),
        ],
      ],
    ]);
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.title, required this.body, required this.p});
  final String title;
  final String body;
  final V2Palette p;
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: p.surfaceAlt,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: pvFraunces(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                  color: p.ink1)),
          const SizedBox(height: 6),
          _body(body, p),
        ]),
      );
}

// -----------------------------------------------------------------------------
//  Kept for revert — the first version, two bodies and a heading
// -----------------------------------------------------------------------------
//
// class CanIEatBody extends StatelessWidget {
//   const CanIEatBody({super.key, required this.pregnancy});
//   final PregnancyController pregnancy;
//   @override
//   Widget build(BuildContext context) => AnimatedBuilder(
//         animation: V2PaletteStore.instance,
//         builder: (context, _) {
//           final p = V2PaletteStore.instance.current;
//           return Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const FoodCheckBody(),
//               const SizedBox(height: 30),
//               Text('Cravings', style: pvFraunces(fontSize: 21, ...)),
//               const SizedBox(height: 4),
//               Text('Answered for the week you are in, not pregnancy in '
//                   'general.', style: pvManrope(fontSize: 12.5, ...)),
//               const SizedBox(height: 14),
//               CravingsBody(pregnancy: pregnancy),
//             ],
//           );
//         },
//       );
// }
