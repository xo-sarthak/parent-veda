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
import '../pregnancy/preg_tool_chrome.dart' show pregToolPad, PregToolScaffold;
import '../products/pv_store_chrome.dart' show PvChip;
import '../v2/v2_palette.dart';
import 'pp_child_profile.dart';
import 'pp_phases_data.dart' show ppFillChild;

class PpKidsBooksShelf extends StatefulWidget {
  const PpKidsBooksShelf({
    super.key,
    required this.p,
    this.goal,
    this.allAges = false,
    this.heading = true,
  });
  final V2Palette p;

  /// The goal chip chosen when the shelf opens (`pp_books/<goal>`, BHO4).
  /// Null opens on All, as the Reading home always has.
  final String? goal;

  /// ⚠️ EVERY AGE, NOT HIS (BHO4). On the Reading home the shelf is his age,
  /// which is right for browsing. A page link is not browsing: the worry
  /// books are 3 to 5 and Behaviour's Scared page starts at 1, so the link
  /// would have opened on nothing. Each row already says its own age.
  final bool allAges;

  /// Off on the shelf's own screen, whose title already says it.
  final bool heading;

  @override
  State<PpKidsBooksShelf> createState() => _PpKidsBooksShelfState();
}

class _PpKidsBooksShelfState extends State<PpKidsBooksShelf> {
  late String? _goal = widget.goal;
  // A goal opened from a page shows all its books; the home keeps six first.
  late bool _all = widget.goal != null;
  static const int _first = 6;

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final child = ChildProfileStore.instance;
    final months = widget.allAges || !child.hasRealChild ? null : child.ageInMonths;
    final books = kidsBooksFor(months);
    final goals = kidsBookGoals(books);
    final shown = [for (final b in books) if (_goal == null || b.goals.contains(_goal)) b];
    final visible = _all ? shown : shown.take(_first).toList();
    final scaler = MediaQuery.textScalerOf(context);
    return Column(
      key: const ValueKey('pp_kids_books_shelf'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.heading) ...[
          pregToolPad(PregSectionHeading(
            'Books to read with your child',
            lead: months == null
                ? 'Picture books and first readers, the team\'s essentials first.'
                : ppFillChild('Picture books and first readers for his age, the team\'s essentials first.'),
          )),
          const SizedBox(height: 12),
        ],
        // Before BHO4, kept for revert:
        // pregToolPad(PregSectionHeading(
        //   'Books to read with your child',
        //   lead: months == null
        //       ? 'Picture books and first readers, the team\'s essentials first.'
        //       : ppFillChild('Picture books and first readers for his age, the team\'s essentials first.'),
        // )),
        // const SizedBox(height: 12),
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

// =============================================================================
//  The shelf on its own screen, on one goal (BHO4, built in the door 9 build)
// -----------------------------------------------------------------------------
//  `pp_books/<name>` opened a toast naming two titles, because the shelf sat
//  far down the Reading home and nothing could land on it. Now a page's
//  "picture books for this" opens the shelf by itself, that goal's chip
//  already chosen, every age, each book's age on its row.
// =============================================================================

/// A page link's name -> (the list's goal, the screen's title). The names
/// are the ones the pages already use; the goals are the sheet's own words,
/// so nothing here renames a book or invents a goal.
const Map<String, (String, String)> kPpBookGoals = {
  'Worry': ('Anxiety', 'Picture books for worries'),
  'New sibling': ('New Sibling', 'Picture books for a new baby'),
  'Potty': ('Potty Training', 'Picture books for potty time'),
};

/// The shelf for `pp_books/<name>`: a page name above, or a goal the list
/// already has. Null for anything else, so a typo fails the link gate
/// instead of opening a shelf on nothing.
Widget? ppKidsBooksScreenFor(String name) {
  if (kPpBookGoals[name] case (final goal, final title)) {
    return PpKidsBooksScreen(goal: goal, title: title);
  }
  if (kidsBookGoals(kKidsBooks).contains(name)) {
    return PpKidsBooksScreen(goal: name, title: 'Picture books: $name');
  }
  return null;
}

class PpKidsBooksScreen extends StatelessWidget {
  const PpKidsBooksScreen({super.key, required this.goal, required this.title});

  /// The list's goal, chosen on open.
  final String goal;
  final String title;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return PregToolScaffold(
      hue: 206,
      eyebrow: 'Books to read together',
      title: title,
      intro: 'Every age is here, and each book says its own on its row. '
          'The team\'s essentials come first.',
      mark: IntentMark.bookMark,
      children: [PpKidsBooksShelf(p: p, goal: goal, allAges: true, heading: false)],
    );
  }
}
