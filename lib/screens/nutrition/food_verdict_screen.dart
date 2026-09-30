// =============================================================================
//  Can I eat this? — browse + the food verdict page
// -----------------------------------------------------------------------------
//  Modelled deliberately on `can_i_screen.dart`, which already solved this
//  shape for the wider "is this okay?" question: search → chips → category →
//  a single calm verdict. This is the food-only sibling of that screen, kept
//  visually consistent so it reads as the same feature, not a second one, per
//  the brief.
//
//  ⚠️ THE VERDICT TAG IS CALM, NOT AN ALARM. `_verdictColor` deliberately does
//  not reach for pure red on AVOID — a muted clay reads as "steer clear" '
//  without the stop-sign jolt a saturated red gives a worried reader.
//
//  ⚠️ NO EXPERT / PAID BLOCK ANYWHERE ON THIS FILE. The brief is explicit that
//  a single food verdict never carries the paid Expert options block — see
//  `ExpertOptionsBlock`'s header in `nutrition_stage_screen.dart`. The footer
//  here is a plain one-line prompt, not that block.
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/nutrition_data.dart';
import '../../theme/pv_fonts.dart';
import '../v2/v2_palette.dart';
import '../pregnancy/preg_chrome.dart' show PregCard, PregSectionHeading, pregGroupLabelStyle;
import '../products/pv_store_chrome.dart' show kPvInk;

/// Opens search over the food library and pushes the verdict page on pick.
/// Shared entry point — the Nutrition landing's search bar calls this too, so
/// there is exactly one search experience for food in the app.
Future<void> openFoodSearch(BuildContext context) async {
  final p = V2PaletteStore.instance.current;
  final picked = await showSearch<FoodEntry?>(
    context: context,
    delegate: _FoodSearchDelegate(p),
  );
  if (picked != null && context.mounted) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => FoodVerdictScreen(entry: picked),
    ));
  }
}

({Color color, IconData icon}) _verdictVisual(NutritionVerdict v) {
  switch (v) {
    case NutritionVerdict.safe:
      return (color: const Color(0xFF4E9A6E), icon: Icons.check_circle_rounded);
    case NutritionVerdict.limit:
      return (color: const Color(0xFFC9932F), icon: Icons.balance_rounded);
    case NutritionVerdict.avoid:
      // A muted clay, not a stop-sign red — calm still means AVOID.
      return (color: const Color(0xFFC0705B), icon: Icons.do_not_disturb_on_rounded);
  }
}

// ===========================================================================
//  Browse — "Can I eat this?"
// ===========================================================================

class FoodCheckScreen extends StatelessWidget {
  const FoodCheckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: V2PaletteStore.instance,
      builder: (context, _) {
        final p = V2PaletteStore.instance.current;
        return Scaffold(
          backgroundColor: p.ground,
          appBar: AppBar(
            backgroundColor: p.ground,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            title: Text('Can I eat this?',
                style: pvFraunces(fontSize: 19, fontWeight: FontWeight.w600, color: p.ink1)),
          ),
          body: SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 28),
              children: const [FoodCheckBody()],
            ),
          ),
        );
      },
    );
  }
}

/// The food checker itself — search, most-searched, the category chips and the
/// Safe/Limit/Avoid list — without a Scaffold or an app bar.
///
/// ⚠️ EXTRACTED SO THE NUTRITION DOOR CAN RENDER IT IN PLACE, and the
/// extraction is a MOVE: same children, same order, same spacing. The screen
/// above still exists, still routes, and still looks identical because it now
/// renders this.
///
/// ⚠️ A COLUMN, NOT A LIST. A scrolling widget inside another scrolling widget
/// is either unbounded or a nested scroll nobody can drive with a thumb — the
/// rule `ScanTimelineBody` set and every body since has followed.
class FoodCheckBody extends StatefulWidget {
  const FoodCheckBody({super.key});

  @override
  State<FoodCheckBody> createState() => _FoodCheckBodyState();
}

class _FoodCheckBodyState extends State<FoodCheckBody> {
  FoodCategory? _filter;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: V2PaletteStore.instance,
      builder: (context, _) {
        final p = V2PaletteStore.instance.current;
        final items = _filter == null
            ? kFoodEntries
            : foodsByCategory(_filter!);
        return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SearchBar(p: p, onTap: () => openFoodSearch(context)),
                const SizedBox(height: 22),
                // One section heading (2026-09-30): the serif. Kept for
                // revert: Manrope 12.5 w800 +0.6 in p.ink3.
                const PregSectionHeading('Most searched'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final m in kMostSearchedFoods)
                      Builder(builder: (_) {
                        final e = foodById(m.id);
                        if (e == null) return const SizedBox.shrink();
                        return _Chip(
                          emoji: m.emoji,
                          label: e.name.now,
                          p: p,
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => FoodVerdictScreen(entry: e),
                          )),
                        );
                      }),
                  ],
                ),
                const SizedBox(height: 26),
                // One section heading (2026-09-30). Kept for revert: as above.
                const PregSectionHeading('Browse by category'),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: [
                    _CategoryChip(label: 'All', selected: _filter == null, p: p, onTap: () => setState(() => _filter = null)),
                    for (final c in FoodCategory.values) ...[
                      const SizedBox(width: 8),
                      _CategoryChip(
                        label: c.label.now,
                        selected: _filter == c,
                        p: p,
                        onTap: () => setState(() => _filter = c),
                      ),
                    ],
                  ]),
                ),
                const SizedBox(height: 18),
                for (final e in items) ...[
                  FoodEntryRow(
                    entry: e,
                    p: p,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => FoodVerdictScreen(entry: e),
                    )),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
        );
      },
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.p, required this.onTap});
  final V2Palette p;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: p.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: p.line),
          ),
          child: Row(children: [
            Icon(Icons.search_rounded, color: p.ink3, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text('Type any food', style: pvManrope(fontSize: 14, color: p.ink3))),
          ]),
        ),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: p.line),
        ),
        // No decorative emoji in chrome (2026-09-30). Kept for revert:
        // Text(emoji, style: const TextStyle(fontSize: 15)) and a 7pt gap
        // before the label.
        child: Text(label, style: pvManrope(fontSize: 13, fontWeight: FontWeight.w700, color: p.ink1)),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label, required this.selected, required this.p, required this.onTap});
  final String label;
  final bool selected;
  final V2Palette p;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        // Selected is the one ink, white words (2026-09-30). Kept for revert:
        // an ink1 0.10 fill with an ink1 0.5 border and ink words.
        decoration: BoxDecoration(
          color: selected ? kPvInk : p.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? kPvInk : p.line),
        ),
        child: Text(label,
            style: pvManrope(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : p.ink2)),
      ),
    );
  }
}

/// A compact row: verdict icon + name + verdict label + chevron. Shared by
/// browse, search results and related-food chips.
class FoodEntryRow extends StatelessWidget {
  const FoodEntryRow({super.key, required this.entry, required this.p, required this.onTap});
  final FoodEntry entry;
  final V2Palette p;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final v = _verdictVisual(entry.verdict);
    return Material(
      color: p.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: p.line),
          ),
          child: Row(children: [
            Icon(v.icon, color: v.color, size: 21),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(entry.name.now, style: pvManrope(fontSize: 14.5, fontWeight: FontWeight.w700, color: p.ink1)),
                // Ink words; the verdict's colour stays on its glyph
                // (2026-09-30). Was `color: v.color`.
                Text(entry.verdict.label.now,
                    style: pvManrope(fontSize: 11.5, fontWeight: FontWeight.w800, color: p.ink2)),
              ]),
            ),
            Icon(Icons.chevron_right_rounded, color: p.ink3),
          ]),
        ),
      ),
    );
  }
}

// ===========================================================================
//  The verdict page
// ===========================================================================

class FoodVerdictScreen extends StatelessWidget {
  const FoodVerdictScreen({super.key, required this.entry});
  final FoodEntry entry;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: V2PaletteStore.instance,
      builder: (context, _) {
        final p = V2PaletteStore.instance.current;
        final v = _verdictVisual(entry.verdict);
        return Scaffold(
          backgroundColor: p.ground,
          appBar: AppBar(
            backgroundColor: p.ground,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            title: Text(entry.name.now,
                style: pvFraunces(fontSize: 19, fontWeight: FontWeight.w600, color: p.ink1)),
          ),
          body: SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 32),
              children: [
                // --- Verdict card ---
                //
                // ⚠️ A WHITE CARD WITH THE HAIRLINE, NOT A TINTED BLOCK
                // (2026-09-30, one ParentVeda). The verdict's colour is the
                // signal, so it stays on the glyph; the words are ink. Kept
                // for revert: a Container filled `v.color` at 0.09 with a
                // `v.color` 0.30 border, radius 22, the label in `v.color`.
                PregCard(
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Icon(v.icon, color: v.color, size: 30),
                      const SizedBox(width: 12),
                      Text(entry.verdict.label.now.toUpperCase(),
                          style: pvManrope(
                              fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 1.0, color: kPvInk)),
                    ]),
                    const SizedBox(height: 14),
                    Text(entry.lines.now, style: pvManrope(fontSize: 14, height: 1.55, color: p.ink1)),
                  ]),
                  ),
                ),

                if (entry.myth != null) ...[
                  const SizedBox(height: 16),
                  _MythCard(p: p, body: entry.myth!.now),
                ],

                if (entry.verdict == NutritionVerdict.limit && entry.limitGuidance != null) ...[
                  const SizedBox(height: 16),
                  _LimitCard(p: p, body: entry.limitGuidance!.now),
                ],

                if (entry.related.isNotEmpty) ...[
                  const SizedBox(height: 26),
                  // One section heading (2026-09-30). Was pvFraunces 17.
                  const PregSectionHeading('Related foods'),
                  const SizedBox(height: 12),
                  for (final rid in entry.related)
                    if (foodById(rid) != null) ...[
                      FoodEntryRow(
                        entry: foodById(rid)!,
                        p: p,
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => FoodVerdictScreen(entry: foodById(rid)!),
                        )),
                      ),
                      const SizedBox(height: 10),
                    ],
                ],

                const SizedBox(height: 22),
                _AskDieticianFooter(p: p),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MythCard extends StatelessWidget {
  const _MythCard({required this.p, required this.body});
  final V2Palette p;
  final String body;
  @override
  Widget build(BuildContext context) {
    // A white card with the hairline, not a grey block (2026-09-30). Kept
    // for revert: a Container on `p.surfaceAlt`, radius 18, the label
    // Manrope 12 w800 +0.5 in p.ink3.
    return PregCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: SizedBox(
        width: double.infinity,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.auto_stories_outlined, size: 16, color: p.ink3),
            const SizedBox(width: 8),
            Text('The myth', style: pregGroupLabelStyle()),
          ]),
          const SizedBox(height: 8),
          Text(body, style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink2)),
        ]),
      ),
    );
  }
}

class _LimitCard extends StatelessWidget {
  const _LimitCard({required this.p, required this.body});
  final V2Palette p;
  final String body;
  @override
  Widget build(BuildContext context) {
    // A white card with the hairline, not an amber block (2026-09-30). The
    // amber stays on the glyph, as on the verdict. Kept for revert: a
    // Container filled 0xFFC9932F at 0.08 with a 0.25 border, radius 18, the
    // label Manrope 12 w800 +0.5 in the amber.
    const accent = Color(0xFFC9932F);
    return PregCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: SizedBox(
        width: double.infinity,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.balance_rounded, size: 16, color: accent),
            const SizedBox(width: 8),
            Text('How much is fine', style: pregGroupLabelStyle()),
          ]),
          const SizedBox(height: 8),
          Text(body, style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink1)),
        ]),
      ),
    );
  }
}

class _AskDieticianFooter extends StatelessWidget {
  const _AskDieticianFooter({required this.p});
  final V2Palette p;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton.icon(
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Noted. Our dietician team will follow up.'),
        )),
        icon: Icon(Icons.chat_bubble_outline_rounded, size: 16, color: p.ink2),
        label: Text('Still unsure? Ask our dietician',
            style: pvManrope(fontSize: 13, fontWeight: FontWeight.w700, color: p.ink2)),
      ),
    );
  }
}

// ===========================================================================
//  Search
// ===========================================================================

class _FoodSearchDelegate extends SearchDelegate<FoodEntry?> {
  _FoodSearchDelegate(this.p);
  final V2Palette p;

  @override
  List<Widget> buildActions(BuildContext context) => [
        if (query.isNotEmpty) IconButton(icon: const Icon(Icons.clear_rounded), onPressed: () => query = ''),
      ];

  @override
  Widget buildLeading(BuildContext context) =>
      IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => close(context, null));

  @override
  Widget buildResults(BuildContext context) => _results(context);

  @override
  Widget buildSuggestions(BuildContext context) => _results(context);

  Widget _results(BuildContext context) {
    if (query.trim().isEmpty) return const SizedBox.shrink();
    final matches = searchFoods(query);
    if (matches.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(36),
          child: Text('No matches yet. Try a different word, or ask our dietician directly.',
              textAlign: TextAlign.center, style: pvManrope(fontSize: 14, color: p.ink3)),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
      itemCount: matches.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, i) => FoodEntryRow(entry: matches[i], p: p, onTap: () => close(context, matches[i])),
    );
  }
}
