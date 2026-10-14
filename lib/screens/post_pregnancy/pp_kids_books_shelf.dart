// =============================================================================
//  Books to read with your child — the parenting Reading shelf
// -----------------------------------------------------------------------------
//  2026-10-13, the user: the team's Book Recommendations sheet goes on the
//  parenting Reading home, by the child's age and the parent's goal
//  (lib/data/kids_books.dart).
//
//  Mobbin, 2026-10-13: Goodreads lists books as rows (title, "by" author, one
//  meta line) under a chip row; Amazon's children's store sorts by age bands
//  ("Baby–2", "Age 3–5"). So: her child's age decides the list (all ages
//  when there is no child yet — a shelf is never hidden), goal chips narrow
//  it, the team's Essentials lead, and a tap opens a short sheet with what
//  the sheet knows. No buy button: the sheet has no links.
//
//  Drawn marks only (the user, 2026-10-13).
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/kids_books.dart';
import '../../theme/pv_fonts.dart';
import '../brackets/hub/hub_intent_art.dart' show HubIntentArt, IntentMark;
import '../doors/pv_list_row.dart';
import '../pregnancy/preg_chrome.dart' show PregSectionHeading;
import '../pregnancy/preg_tool_chrome.dart' show pregToolPad;
import '../products/pv_store_chrome.dart' show PvChip;
import '../v2/v2_palette.dart';
import 'pp_child_profile.dart';
import 'pp_phases_data.dart' show ppFillChild;

class PpKidsBooksShelf extends StatefulWidget {
  const PpKidsBooksShelf({super.key, required this.p});
  final V2Palette p;

  @override
  State<PpKidsBooksShelf> createState() => _PpKidsBooksShelfState();
}

class _PpKidsBooksShelfState extends State<PpKidsBooksShelf> {
  String? _goal;
  bool _all = false;
  static const int _first = 6;

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final child = ChildProfileStore.instance;
    final months = child.hasRealChild ? child.ageInMonths : null;
    final books = kidsBooksFor(months);
    final goals = kidsBookGoals(books);
    final shown = [for (final b in books) if (_goal == null || b.goals.contains(_goal)) b];
    final visible = _all ? shown : shown.take(_first).toList();
    final scaler = MediaQuery.textScalerOf(context);
    return Column(
      key: const ValueKey('pp_kids_books_shelf'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        pregToolPad(PregSectionHeading(
          'Books to read with your child',
          lead: months == null
              ? 'Picture books and first readers, the team\'s essentials first.'
              : ppFillChild('Picture books and first readers for his age, the team\'s essentials first.'),
        )),
        const SizedBox(height: 12),
        SizedBox(
          height: (scaler.scale(13) * 1.4 + 18).clamp(36.0, 60.0),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            itemCount: goals.length + 1,
            separatorBuilder: (_, _) => const SizedBox(width: 6),
            itemBuilder: (_, i) {
              final g = i == 0 ? null : goals[i - 1];
              return Center(
                child: PvChip(
                  label: g ?? 'All',
                  selected: _goal == g,
                  onTap: () => setState(() {
                    _goal = g;
                    _all = false;
                  }),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        pregToolPad(PvRowGroup(p: p, children: [
          for (final b in visible)
            PvListRow(
              key: ValueKey('pp_kids_book_${b.id}'),
              p: p,
              leading: SizedBox(
                width: 40,
                height: 40,
                child: HubIntentArt(mark: IntentMark.bookMark, tint: v2BlockTint(b.indian ? 26 : 206, p)),
              ),
              title: b.title,
              line: [
                'by ${b.author}',
                b.ageText,
                if (b.indian) 'Indian',
                if (b.rank == KidsBookRank.essential) 'Essential',
              ].join(' · '),
              onTap: () => _open(context, b),
            ),
        ])),
        if (shown.length > _first && !_all)
          pregToolPad(Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextButton(
              key: const ValueKey('pp_kids_books_more'),
              onPressed: () => setState(() => _all = true),
              child: Text('See all ${shown.length} books',
                  style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w800, color: p.ink1)),
            ),
          )),
      ],
    );
  }

  void _open(BuildContext context, KidsBook b) {
    final p = widget.p;
    Widget fact(String label, String value) => value.isEmpty
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(
                width: 104,
                child: Text(label, style: pvManrope(fontSize: 13, fontWeight: FontWeight.w700, color: p.ink3)),
              ),
              Expanded(child: Text(value, style: pvManrope(fontSize: 13.5, height: 1.4, color: p.ink1))),
            ]),
          );
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => SafeArea(
        child: Padding(
          key: ValueKey('pp_kids_book_sheet_${b.id}'),
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(b.title, style: pvFraunces(fontSize: 22, fontWeight: FontWeight.w500, height: 1.2, color: p.ink1)),
            const SizedBox(height: 4),
            Text('by ${b.author}', style: pvManrope(fontSize: 14, color: p.ink2)),
            const SizedBox(height: 16),
            fact('Ages', b.ageText.replaceFirst('Ages ', '')),
            fact('Good for', b.goals.join(', ')),
            fact('Theme', b.theme),
            fact('How to read', b.mode),
            fact('Publisher', b.publisher),
            fact('From', b.indian ? 'An Indian book' : 'A global book'),
            if (b.rank == KidsBookRank.essential) fact('The team', 'An essential for this age'),
          ]),
        ),
      ),
    );
  }
}
