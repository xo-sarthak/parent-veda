// =============================================================================
//  IngredientCheckerScreen — the Ingredient Safety Checker
// -----------------------------------------------------------------------------
//  Free. The standout feature of Belly & Skin, and deliberately the same idea
//  as `lib/screens/can_i_screen.dart` applied to skincare instead of food:
//  search, or a tappable common one, opens a clear verdict page. Reusing that
//  screen's shapes (a search delegate, a verdict card as the hero, a "why"
//  section, a related-ingredient handoff) is what lets this read as the same
//  feature family rather than a second, unrelated tool bolted onto the app.
//
//  Two differences from Can I?, both intentional:
//    - Three verdicts, not five: SAFE / LIMIT / AVOID. A skincare ingredient
//      is rarely a flat yes/no; "fine in this form, not that one" is the
//      honest middle state, and LIMIT carries it.
//    - Calm colours, not alarm red, even for AVOID — see `_verdictColor`.
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/belly_skin_data.dart';
import '../../localization/app_language.dart';
import '../../theme/pv_fonts.dart';
import '../brackets/hub/hub_solution_cards.dart';
import '../v2/v2_palette.dart';

const _lang = AppLanguage.english;

({Color color, IconData icon, String label}) _verdictVisual(BsVerdict v) {
  switch (v) {
    case BsVerdict.safe:
      return (
        color: const Color(0xFF3FA56A),
        icon: Icons.check_circle_rounded,
        label: 'SAFE',
      );
    case BsVerdict.limit:
      return (
        color: const Color(0xFFE6A817),
        icon: Icons.balance_rounded,
        label: 'LIMIT',
      );
    case BsVerdict.avoid:
      // A muted clay tone, not the app's alarm red — the spec's "calm
      // colours, not alarm red" applies even to the AVOID tag, because an
      // ingredient caution and a medical emergency should not share a
      // colour vocabulary. That vocabulary is spent on the itching page.
      return (
        color: const Color(0xFFB5623E),
        icon: Icons.do_not_disturb_on_outlined,
        label: 'AVOID',
      );
  }
}

void _openIngredient(BuildContext context, BsIngredient i) {
  Navigator.of(context).push(MaterialPageRoute<void>(
    builder: (_) => BsIngredientAnswerScreen(ingredient: i),
  ));
}

// ===========================================================================
//  Home
// ===========================================================================

class IngredientCheckerScreen extends StatelessWidget {
  const IngredientCheckerScreen({super.key});

  Future<void> _search(BuildContext context) async {
    final picked = await showSearch<BsIngredient?>(
      context: context,
      delegate: _BsSearchDelegate(),
    );
    if (picked != null && context.mounted) _openIngredient(context, picked);
  }

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final sorted = [...kBsIngredients]
      ..sort((a, b) => a.name.en.compareTo(b.name.en));

    return Scaffold(
      backgroundColor: p.ground,
      appBar: AppBar(
        backgroundColor: p.ground,
        elevation: 0,
        foregroundColor: p.ink1,
        title: Text('Ingredient Safety Checker',
            style: pvJakarta(
                fontSize: 16.5, fontWeight: FontWeight.w700, color: p.ink1)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 32),
        children: [
          Text(
              'Is this cream, serum or salon treatment fine in pregnancy? '
              'Search an ingredient for a straight answer, free, every time.',
              style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink2)),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => _search(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              decoration: BoxDecoration(
                color: p.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: p.line),
              ),
              child: Row(children: [
                Icon(Icons.search_rounded, color: p.ink3),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Type a product or ingredient',
                      style: pvManrope(fontSize: 14.5, color: p.ink3)),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 24),
          Text('Commonly checked',
              style: pvFraunces(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: p.ink1)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final chip in kBsPopularIngredients)
                Builder(builder: (_) {
                  final i = bsIngredientById(chip.id);
                  if (i == null) return const SizedBox.shrink();
                  return _Chip(
                    emoji: chip.emoji,
                    label: i.name.of(_lang),
                    p: p,
                    onTap: () => _openIngredient(context, i),
                  );
                }),
            ],
          ),
          const SizedBox(height: 26),
          Text('All ingredients',
              style: pvFraunces(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: p.ink1)),
          const SizedBox(height: 12),
          for (final i in sorted) ...[
            _IngredientRow(ingredient: i, p: p, onTap: () => _openIngredient(context, i)),
            if (i != sorted.last) const SizedBox(height: 9),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.emoji, required this.label, required this.p, required this.onTap});
  final String emoji;
  final String label;
  final V2Palette p;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: p.line),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(emoji, style: const TextStyle(fontSize: 15)),
          const SizedBox(width: 8),
          Text(label,
              style: pvManrope(
                  fontSize: 13, fontWeight: FontWeight.w700, color: p.ink1)),
        ]),
      ),
    );
  }
}

class _IngredientRow extends StatelessWidget {
  const _IngredientRow({required this.ingredient, required this.p, required this.onTap});
  final BsIngredient ingredient;
  final V2Palette p;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final v = _verdictVisual(ingredient.verdict);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: p.line),
        ),
        child: Row(children: [
          Icon(v.icon, color: v.color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(ingredient.name.of(_lang),
                style: pvManrope(
                    fontSize: 14, fontWeight: FontWeight.w700, color: p.ink1)),
          ),
          Text(v.label,
              style: pvManrope(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: v.color)),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right_rounded, size: 18, color: p.ink3),
        ]),
      ),
    );
  }
}

// ===========================================================================
//  Verdict page
// ===========================================================================

class BsIngredientAnswerScreen extends StatelessWidget {
  const BsIngredientAnswerScreen({super.key, required this.ingredient});
  final BsIngredient ingredient;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final v = _verdictVisual(ingredient.verdict);

    return Scaffold(
      backgroundColor: p.ground,
      appBar: AppBar(
        backgroundColor: p.ground,
        elevation: 0,
        foregroundColor: p.ink1,
        title: Text(ingredient.name.of(_lang),
            style: pvJakarta(
                fontSize: 16.5, fontWeight: FontWeight.w700, color: p.ink1)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 32),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            decoration: BoxDecoration(
              color: v.color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: v.color.withValues(alpha: 0.35), width: 1.4),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(v.icon, color: v.color, size: 30),
                const SizedBox(width: 12),
                Text(v.label,
                    style: pvFraunces(
                        fontSize: 22, fontWeight: FontWeight.w700, color: v.color)),
              ]),
              const SizedBox(height: 14),
              for (final line in ingredient.why) ...[
                Text(line.of(_lang),
                    style: pvManrope(fontSize: 14, height: 1.55, color: p.ink1)),
                if (line != ingredient.why.last) const SizedBox(height: 8),
              ],
            ]),
          ),
          if (ingredient.alternativeName != null) ...[
            const SizedBox(height: 22),
            Text('Reach for instead',
                style: pvFraunces(
                    fontSize: 17, fontWeight: FontWeight.w600, color: p.ink1)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: p.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: p.line),
              ),
              child: Row(children: [
                const Icon(Icons.check_circle_rounded,
                    color: Color(0xFF3FA56A), size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(ingredient.alternativeName!.of(_lang),
                      style: pvManrope(
                          fontSize: 14, fontWeight: FontWeight.w700, color: p.ink1)),
                ),
              ]),
            ),
          ],
          if (ingredient.alternativeProduct != null) ...[
            const SizedBox(height: 14),
            SolutionCard(
              type: SolutionType.product,
              title: ingredient.alternativeProduct!.title,
              value: ingredient.alternativeProduct!.blurb,
              p: p,
              lang: _lang,
              comingSoon: true,
            ),
          ],
          const SizedBox(height: 22),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.info_outline_rounded, size: 14, color: p.ink3),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                  'General guidance, not a diagnosis. Your own doctor knows '
                  'your case, and always wins if this ever disagrees.',
                  style: pvManrope(fontSize: 11.5, height: 1.4, color: p.ink3)),
            ),
          ]),
        ],
      ),
    );
  }
}

// ===========================================================================
//  Search
// ===========================================================================

class _BsSearchDelegate extends SearchDelegate<BsIngredient?> {
  @override
  List<Widget> buildActions(BuildContext context) => [
        if (query.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.clear_rounded),
            onPressed: () => query = '',
          ),
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
    final p = V2PaletteStore.instance.current;
    if (query.trim().isEmpty) return const SizedBox.shrink();
    final matches = bsIngredientSearch(query);
    if (matches.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(36),
          child: Text('No match yet. Try a shorter or different word.',
              textAlign: TextAlign.center,
              style: pvManrope(fontSize: 14, color: p.ink3)),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
      itemCount: matches.length,
      separatorBuilder: (_, _) => const SizedBox(height: 9),
      itemBuilder: (context, i) => _IngredientRow(
        ingredient: matches[i],
        p: p,
        onTap: () => close(context, matches[i]),
      ),
    );
  }
}
