// =============================================================================
//  MultiChildSheet - Multi-child switcher (parenting app · S10)
// -----------------------------------------------------------------------------
//  A bottom sheet listing the account's children (everything personalises to
//  whoever's active) with an "add a child" affordance. Faithful build of Claude
//  Design S10. Shown from the My Child home → tap the child's name / photo.
//
//  This sheet existed but was orphaned: nothing in the app opened it, and its
//  contents were hard-coded to "Aarav" and "Meher" with the tap on the second
//  child going to a "coming soon" snackbar. ChildProfileStore has supported
//  multiple children and switchTo() the whole time — the data layer was simply
//  ahead of the wiring. It now reads the real children and really switches.
//
//  The Claude Design layout is unchanged; only the data behind it is real.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_child_profile.dart';
import 'pp_common.dart';
import 'pp_leaps_data.dart';

/// Present the switcher as a modal bottom sheet.
Future<void> showMultiChildSheet(BuildContext context) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const MultiChildSheet(),
    );

class MultiChildSheet extends StatelessWidget {
  const MultiChildSheet({super.key});

  ChildProfileStore get _store => ChildProfileStore.instance;

  void _soon(BuildContext context, [String m = 'Coming soon']) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(m), behavior: SnackBarBehavior.floating),
      );

  /// "4 months · Leap 4 · The World of Events" for a baby in a leap window,
  /// "2 years 6 months · Toddler" once leaps are behind them.
  Widget _subtitle(Child c, bool active) {
    final weeks = _ageInWeeks(c);
    final months = (weeks / 4.345).floor();
    final age = _ageLabel(months);
    final leap = kLeaps[currentLeapIndex(weeks)];
    // Past the last leap window a child is simply a toddler — naming a leap
    // they finished a year ago would be worse than saying nothing.
    final inLeap = weeks <= leap.endWeek;

    if (!inLeap) {
      return Text('$age · ${months >= 12 ? 'Toddler' : 'Baby'}', style: ppBody(12));
    }
    return Text.rich(
      TextSpan(children: [
        TextSpan(text: '$age · '),
        TextSpan(
          text: 'Leap ${leap.number} · ${leap.name}',
          style: const TextStyle(color: ppCoral, fontWeight: FontWeight.w600),
        ),
      ]),
      style: ppBody(12),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  double _ageInWeeks(Child c) {
    final d = DateTime.now().difference(c.dob).inDays;
    return d < 0 ? 0 : d / 7.0;
  }

  String _ageLabel(int months) {
    if (months < 1) return 'newborn';
    if (months < 24) return '$months month${months == 1 ? '' : 's'}';
    final y = months ~/ 12;
    final m = months % 12;
    return m == 0 ? '$y years' : '$y years $m month${m == 1 ? '' : 's'}';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _store,
      builder: (context, _) {
        final children = _store.children;
        final activeId = _store.active.id;

        return Container(
          decoration: const BoxDecoration(
            color: ppBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(color: ppLine, borderRadius: BorderRadius.circular(999)),
                  ),
                ),
                Text('Your children', style: ppJakarta(19)),
                const SizedBox(height: 4),
                Text("Everything personalises to whoever's active.", style: ppBody(13)),
                const SizedBox(height: 18),

                for (final c in children) ...[
                  _childRow(context, c, c.id == activeId),
                  const SizedBox(height: 10),
                ],

                // add a child
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () => _soon(context, 'Adding a child - coming soon'),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                    decoration: const BoxDecoration(border: Border(top: BorderSide(color: ppHair))),
                    child: Row(children: [
                      Container(
                        width: 50,
                        height: 50,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFC7BBD6), width: 1.5)),
                        child: const Text('+', style: TextStyle(color: ppPurple, fontSize: 22)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Add a child', style: ppJakarta(15, color: ppPurple)),
                          const SizedBox(height: 2),
                          Text('Name, birthday, a photo - takes a minute.', style: ppBody(12, color: ppMuted)),
                        ]),
                      ),
                    ]),
                  ),
                ),
              ]),
            ),
          ),
        );
      },
    );
  }

  Widget _childRow(BuildContext context, Child c, bool active) {
    final row = Row(children: [
      _avatar(),
      const SizedBox(width: 14),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(c.name, style: ppJakarta(16)),
          const SizedBox(height: 2),
          _subtitle(c, active),
        ]),
      ),
      if (active)
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: ppPurple, shape: BoxShape.circle),
          child: const Text('✓', style: TextStyle(color: Colors.white, fontSize: 12)),
        )
      else
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFD8C8EA), width: 1.5)),
        ),
    ]);

    if (active) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: ppPanel,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: ppPanelDiv),
        ),
        child: row,
      );
    }

    return GestureDetector(
      onTap: () async {
        await _store.switchTo(c.id);
        if (!context.mounted) return;
        Navigator.of(context).maybePop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Showing ${c.name} now'), behavior: SnackBarBehavior.floating),
        );
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(14),
        color: Colors.transparent,
        child: row,
      ),
    );
  }

  Widget _avatar() => Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: ppBorder)),
        clipBehavior: Clip.antiAlias,
        child: const PpStriped(height: 60),
      );
}
