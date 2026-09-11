// =============================================================================
//  Cravings — the foods, answered at her stage
// -----------------------------------------------------------------------------
//  ⚠️ REBUILT. The old screen was six reassuring text cards and nothing else:
//  why cravings happen, sudden aversions, the eating-for-two myth. All true,
//  and none of it the reason anyone opens this page. She opens it at 9pm
//  wanting golgappa.
//
//  So the page now leads with the FOODS. Each one opens an answer keyed to her
//  own trimester — can she, why she wants it, what instead when the answer is
//  no, and how to make a safe version at home. The six explainer cards are kept
//  verbatim and moved below the list, where they read as context rather than as
//  the answer.
//
//  ⚠️ THIS SCREEN NOW NEEDS THE PREGNANCY CONTROLLER, and that is the whole
//  point of the rebuild — a cravings page that does not know her week cannot
//  answer the only question being asked of it. See `NutritionHomeScreen` for
//  the threading.
//
//  ⚠️ ENGLISH ONLY FOR NOW.
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/cravings_data.dart';
import '../../data/nutrition_data.dart';
import '../../services/pregnancy_controller.dart';
import '../../theme/pv_fonts.dart';
import '../v2/v2_palette.dart';
import 'craving_detail_screen.dart';

class CravingsScreen extends StatefulWidget {
  const CravingsScreen(
      {super.key, required this.pregnancy, this.embedded = false});

  final PregnancyController pregnancy;

  /// Rendered inside another page's scroll rather than as a screen.
  ///
  /// ⚠️ A FLAG RATHER THAN A SEPARATE BODY WIDGET, and the reason is the same
  /// one `ReportScreen.embedded` gives: this screen's content is inseparable
  /// from its state — the search controller and the trimester it derives — so a
  /// body widget would either duplicate that state or wrap this class anyway.
  /// The flag changes chrome only.
  final bool embedded;

  @override
  State<CravingsScreen> createState() => _CravingsScreenState();
}

class _CravingsScreenState extends State<CravingsScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([V2PaletteStore.instance, _search]),
      builder: (context, _) {
        final p = V2PaletteStore.instance.current;

        // ⚠️ THE WEEK, THE TRIMESTER AND THE FILTERED LIST ALL MOVED INTO
        // `_body`, WHICH IS WHERE THEY ARE USED. They were computed here when
        // `build` drew the list directly; leaving them behind would be three
        // values derived twice per frame and, worse, two places for the
        // trimester boundary to be written.
        if (widget.embedded) return _body(context, p);

        return Scaffold(
          backgroundColor: p.ground,
          appBar: AppBar(
            backgroundColor: p.ground,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            title: Text('Cravings',
                style: pvFraunces(
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                    color: p.ink1)),
          ),
          body: SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 32),
              children: [_body(context, p)],
            ),
          ),
        );
      },
    );
  }

  /// The cravings list, the stage banner and the About-cravings cards, without
  /// a Scaffold. See [CravingsBody].
  Widget _body(BuildContext context, V2Palette p) {
    final week = widget.pregnancy.currentWeek;
    final tri = _trimesterOf(week);
    final q = _search.text.trim();
    final items =
        kCravingItems.where((c) => c.matches(q)).toList(growable: false);
    return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    'Tap what you are craving. Every answer below is for where '
                    'you are now, not pregnancy in general.',
                    style: pvManrope(
                        fontSize: 13.5, height: 1.45, color: p.ink2)),
                const SizedBox(height: 14),
                // ⚠️ "YOU ARE HERE", SAID ONCE AND PLAINLY. Without it every
                // verdict below reads as a general rule, which is exactly what
                // this rebuild exists to stop it being.
                _StageBanner(week: week, tri: tri, p: p),
                const SizedBox(height: 16),
                _Search(controller: _search, p: p),
                const SizedBox(height: 18),

                if (items.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    child: Text(
                        'Nothing here matches that. Try "Can I eat this?" on '
                        'the Nutrition home — it covers far more foods than '
                        'this list of common cravings.',
                        style: pvManrope(
                            fontSize: 13.5, height: 1.5, color: p.ink3)),
                  )
                else
                  for (final c in items) ...[
                    _CravingRow(
                      item: c,
                      tri: tri,
                      p: p,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          settings:
                              RouteSettings(name: 'nutrition/craving/${c.id}'),
                          builder: (_) => CravingDetailScreen(
                              item: c, pregnancy: widget.pregnancy),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],

                // ---- the old cards, kept, and moved below the list --------
                //
                // ⚠️ NOT DELETED. They are good writing and they answer the
                // second question, which arrives after the first. What was
                // wrong was their POSITION: they were the entire page, so the
                // page could not answer "can I have this".
                if (q.isEmpty) ...[
                  const SizedBox(height: 26),
                  Text('About cravings',
                      style: pvFraunces(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: p.ink1)),
                  const SizedBox(height: 12),
                  for (final c in kCravingCards) ...[
                    _CravingCardView(p: p, card: c),
                    const SizedBox(height: 12),
                  ],
                ],
              ],
        );
  }
}

/// The cravings list and the About-cravings cards, without a Scaffold.
///
/// ⚠️ IT IS THE SAME STATE CLASS, REACHED A DIFFERENT WAY. `CravingsScreen`
/// owns the search controller and the trimester derivation, and both are needed
/// by the body — so rather than duplicating them, the body IS the screen with
/// its chrome suppressed. `embedded` is the flag; nothing else differs.
///
/// The Nutrition brief folds cravings into "Can I eat this?" because it is the
/// same question — *"can I have this"* — asked about a different kind of thing.
class CravingsBody extends StatelessWidget {
  const CravingsBody({super.key, required this.pregnancy});

  final PregnancyController pregnancy;

  @override
  Widget build(BuildContext context) =>
      CravingsScreen(pregnancy: pregnancy, embedded: true);
}

int _trimesterOf(int week) {
  if (week < 14) return 1;
  if (week < 28) return 2;
  return 3;
}

/// A verdict, as a colour and a word.
///
/// ⚠️ NEVER COLOUR ALONE. Red-green is the most common colour-vision gap there
/// is, and this is a safety signal — so every use of these pairs the tint with
/// the word.
({Color bg, Color fg, String label}) _verdictStyle(
    NutritionVerdict v, V2Palette p) {
  return switch (v) {
    NutritionVerdict.safe => (
        bg: const Color(0xFF2E7D52).withValues(alpha: 0.12),
        fg: const Color(0xFF2E7D52),
        label: 'Yes'
      ),
    NutritionVerdict.limit => (
        bg: const Color(0xFF9A6B12).withValues(alpha: 0.13),
        fg: const Color(0xFF9A6B12),
        label: 'In small amounts'
      ),
    NutritionVerdict.avoid => (
        bg: const Color(0xFFB3261E).withValues(alpha: 0.11),
        fg: const Color(0xFFB3261E),
        label: 'Not now'
      ),
  };
}

class _StageBanner extends StatelessWidget {
  const _StageBanner({required this.week, required this.tri, required this.p});
  final int week;
  final int tri;
  final V2Palette p;

  @override
  Widget build(BuildContext context) {
    const names = {1: 'first', 2: 'second', 3: 'third'};
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 11, 14, 12),
      decoration: BoxDecoration(
        color: p.action.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(children: [
        Icon(Icons.my_location_rounded, size: 16, color: p.action),
        const SizedBox(width: 10),
        Expanded(
          child: Text('You are in week $week — your ${names[tri]} trimester.',
              style: pvManrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                  color: p.ink1)),
        ),
      ]),
    );
  }
}

class _Search extends StatelessWidget {
  const _Search({required this.controller, required this.p});
  final TextEditingController controller;
  final V2Palette p;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: p.line),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(children: [
          Icon(Icons.search_rounded, size: 19, color: p.ink3),
          const SizedBox(width: 9),
          Expanded(
            child: TextField(
              controller: controller,
              style: pvManrope(fontSize: 14, color: p.ink1),
              decoration: InputDecoration(
                isDense: true,
                // ⚠️ `filled: false` IS LOAD-BEARING AND LOOKS REDUNDANT.
                // `app_theme.dart` sets `filled: true` with a grey
                // `surfaceContainer` on every `InputDecoration` in the app, and
                // `border: InputBorder.none` removes the OUTLINE, not the FILL.
                // So this field painted a grey rounded rect INSIDE the white
                // pill its own Container had already drawn — one search bar
                // that read as two. Seen on a phone, 2026-09-10.
                //
                // The general shape: a widget that draws its own chrome has to
                // switch OFF the theme's, not merely avoid adding to it. A
                // theme default is applied unless overridden, and "I set a
                // different border" is not an override of "fill".
                filled: false,
                border: InputBorder.none,
                // ⚠️ AND THE FOCUSED ONE. `border` is the fallback; the theme
                // sets `focusedBorder` separately, so a focused field grew a
                // purple ring inside its own white pill. Seen on a phone.
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: 'What are you craving?',
                hintStyle: pvManrope(fontSize: 14, color: p.ink3),
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            InkWell(
              onTap: controller.clear,
              child: Icon(Icons.close_rounded, size: 17, color: p.ink3),
            ),
        ]),
      );
}

class _CravingRow extends StatelessWidget {
  const _CravingRow(
      {required this.item,
      required this.tri,
      required this.p,
      required this.onTap});

  final CravingItem item;
  final int tri;
  final V2Palette p;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final v = _verdictStyle(item.verdictAt(tri), p);
    return Material(
      color: p.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 13, 12, 13),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: p.line)),
          child: Row(children: [
            Text(item.emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name.now,
                      style: pvManrope(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: p.ink1)),
                  const SizedBox(height: 5),
                  // ⚠️ THE ANSWER IS ON THE LIST ROW, NOT ONLY INSIDE.
                  // Most visits are one food and one question; making her open
                  // a page to learn "yes" would be a tap charged for nothing.
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: v.bg,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(v.label,
                        style: pvManrope(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: v.fg)),
                  ),
                ],
              ),
            ),
            if (item.recipe != null)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Icon(Icons.soup_kitchen_outlined,
                    size: 17, color: p.ink3),
              ),
            Icon(Icons.chevron_right_rounded, size: 20, color: p.ink3),
          ]),
        ),
      ),
    );
  }
}

class _CravingCardView extends StatelessWidget {
  const _CravingCardView({required this.p, required this.card});
  final V2Palette p;
  final CravingCard card;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
      decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: p.line)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(card.title.now,
            style: pvFraunces(
                fontSize: 16, fontWeight: FontWeight.w600, color: p.ink1)),
        const SizedBox(height: 7),
        Text(card.body.now,
            style: pvManrope(fontSize: 13.5, height: 1.55, color: p.ink2)),
      ]),
    );
  }
}

/// Exported so the detail screen renders the same verdict chip as the list.
({Color bg, Color fg, String label}) cravingVerdictStyle(
        NutritionVerdict v, V2Palette p) =>
    _verdictStyle(v, p);
