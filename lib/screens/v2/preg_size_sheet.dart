// =============================================================================
//  The size sheet — "about the size of a …", done properly
// -----------------------------------------------------------------------------
//  Flo's Details sheet, lower half (Mobbin, 2026-09-21): the baby and the thing
//  it is the size of, side by side; Length · Weight · Size; then what is
//  happening this week. Opened from the size line on the hero and from the
//  "About the size of" insight card (docs/PREG-HOME-HERO-PLAN.md, Tier 2 §7).
//
//  ⚠️ POPULATION AVERAGES, SAID SO. Length and weight come from the week's
//  content ("about"); the copy never says *your baby weighs*. Her scan is the
//  measure, and the sheet says that in one line at the foot. `DueDateSource`
//  still owns the week.
//
//  ⚠️ THE COMPARISON OBJECT'S PICTURE IS OWED (plan §8: photos picked by eye,
//  mirrored to R2). Until then the baby's photograph carries the row alone and
//  the object is named in the title — no grey well with a word in it (the
//  "text thrown at me in grey boxes" the Nutrition walk rejected). When the
//  pictures land, `objectImageUrl` fills the right half of the row.
//
//  The set toggle (fruit & veg · kitchen · sweets) is the row above the
//  comparison — ink chips, the app's segmented control. The choice persists
//  (`PregSizeSetStore`) and the hero line and the insight card follow it.
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/preg_size_sets.dart';
import '../../models/week_content.dart';
import '../../services/preg_size_set_store.dart';
import '../../theme/pv_fonts.dart';
import 'v2_palette.dart';

/// Open the sheet for [week].
Future<void> showPregSizeSheet(
  BuildContext context, {
  required int week,
  required WeekContent content,
  required V2Palette p,
  VoidCallback? onThisWeek,
}) {
  final p0 = p;
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: p0.surface,
    clipBehavior: Clip.antiAlias,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) => PregSizeSheet(
        week: week, content: content, p: p0, onThisWeek: onThisWeek),
  );
}

class PregSizeSheet extends StatelessWidget {
  const PregSizeSheet({
    super.key,
    required this.week,
    required this.content,
    required this.p,
    this.onThisWeek,
    this.objectImageUrl,
  });

  final int week;
  final WeekContent content;
  final V2Palette p;

  /// Opens the week stack. Null hides the button (the sheet is already on it).
  final VoidCallback? onThisWeek;

  /// The comparison object's picture, when we have one. See the file note.
  final String? objectImageUrl;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
      listenable: PregSizeSetStore.instance,
      builder: (context, _) => _build(context, PregSizeSetStore.instance.set));

  Widget _build(BuildContext context, PregSizeSet set) {
    final s = content.snapshot;
    final item = pregSizeOrFallback(week, set, s.fruit.en);
    final len = s.length.en.trim();
    final wt = s.weight.en.trim();
    final doing = content.development.whatImDoing.en.trim();
    final fact = content.development.funFact?.en.trim() ?? '';
    final headline = s.weekHeadline.en.trim();
    final milestone = s.milestone.en.trim();
    final forYou = [
      content.mom.physicalChanges.en.trim(),
      content.mom.emotionalState.en.trim(),
      content.mom.selfCareTip.en.trim(),
    ].where((t) => t.isNotEmpty).toList();
    final ww = week.toString().padLeft(2, '0');

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.72,
      maxChildSize: 0.94,
      minChildSize: 0.4,
      builder: (ctx, sc) => ListView(
        controller: sc,
        padding: EdgeInsets.fromLTRB(
            20, 14, 20, 24 + MediaQuery.paddingOf(ctx).bottom),
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: p.line, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 18),
          Text('WEEK $week',
              style: pvManrope(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.3,
                  color: p.ink3)),
          const SizedBox(height: 4),
          Text(item?.line ?? 'This week',
              style: pvFraunces(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  height: 1.15,
                  letterSpacing: -0.5,
                  color: p.ink1)),
          const SizedBox(height: 14),

          // ---- the toggle: which things ------------------------------------
          //
          // ⚠️ OFF UNTIL THE PICTURES LAND (2026-09-22). The user: "kitchen
          // and sweets … the images don't change." A toggle that changes one
          // word and nothing she can see is a control with no payoff; it
          // comes back with the comparison pictures (STILL-OPEN §72.1), one
          // per entry, so switching to Kitchen shows the tawa. The sets and
          // the store stay; `kPregSizeToggle` gates the row and the store
          // answers fruit while it is off.
          if (kPregSizeToggle) ...[
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final s in PregSizeSet.values)
                _Chip(
                    p: p,
                    label: s.label,
                    selected: s == set,
                    onTap: () => PregSizeSetStore.instance.choose(s)),
            ]),
            const SizedBox(height: 14),
          ],

          // ---- the baby, and the thing it is the size of --------------------
          SizedBox(
            height: 170,
            child: Row(children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset('assets/baby/week_$ww.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          Container(color: p.surfaceAlt)),
                ),
              ),
              if (objectImageUrl case final url?) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(url,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            Container(color: p.surfaceAlt)),
                  ),
                ),
              ],
            ]),
          ),
          const SizedBox(height: 12),

          // ---- length · weight ---------------------------------------------
          Row(children: [
            Expanded(child: _Tile(p: p, label: 'LENGTH', value: len.isEmpty ? '—' : len)),
            const SizedBox(width: 10),
            Expanded(child: _Tile(p: p, label: 'WEIGHT', value: wt.isEmpty ? '—' : wt)),
          ]),

          // ---- what is happening --------------------------------------------
          //
          // "What your baby is doing isn't as descriptive as it should be"
          // (the user, 2026-09-22): the week's headline and milestone lead,
          // the development prose follows, and the mother's own week — what
          // changes for her, how she may feel, one thing to do for herself —
          // closes it. All from the week's content; nothing computed.
          if (headline.isNotEmpty || milestone.isNotEmpty) ...[
            const SizedBox(height: 22),
            // The milestone is the short one ("A New Beginning"); the
            // headline is the sentence. Heading, then prose.
            Text(milestone.isNotEmpty ? milestone : headline,
                style: pvFraunces(
                    fontSize: 20, fontWeight: FontWeight.w600, height: 1.2, color: p.ink1)),
            if (headline.isNotEmpty && milestone.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(headline,
                  style: pvManrope(fontSize: 14, height: 1.55, color: p.ink2)),
            ],
          ],
          if (doing.isNotEmpty) ...[
            const SizedBox(height: 18),
            Text('What your baby is doing',
                style: pvFraunces(
                    fontSize: 18, fontWeight: FontWeight.w600, color: p.ink1)),
            const SizedBox(height: 6),
            Text(doing,
                style: pvManrope(fontSize: 14, height: 1.55, color: p.ink2)),
          ],
          if (fact.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              decoration: BoxDecoration(
                  color: v2BlockTint(24, p),
                  borderRadius: BorderRadius.circular(14)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('DID YOU KNOW',
                        style: pvManrope(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: p.ink3)),
                    const SizedBox(height: 4),
                    Text(fact,
                        style: pvManrope(
                            fontSize: 13.5, height: 1.5, color: p.ink1)),
                  ]),
            ),
          ],

          if (forYou.isNotEmpty) ...[
            const SizedBox(height: 18),
            Text('For you this week',
                style: pvFraunces(
                    fontSize: 18, fontWeight: FontWeight.w600, color: p.ink1)),
            const SizedBox(height: 6),
            for (final line in forYou) ...[
              Text(line, style: pvManrope(fontSize: 14, height: 1.55, color: p.ink2)),
              const SizedBox(height: 8),
            ],
          ],

          const SizedBox(height: 10),
          // The clinical line: averages, and whose measurement counts.
          Text(
              'Averages for week $week. Every baby grows at their own pace — '
              'your scan is the measure, not this line.',
              style: pvManrope(fontSize: 12, height: 1.45, color: p.ink3)),

          if (onThisWeek != null) ...[
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: p.ink1,
                    foregroundColor: p.ground,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: const StadiumBorder()),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  onThisWeek!();
                },
                child: Text('This week',
                    style: pvManrope(
                        fontSize: 14, fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// One ink chip of the toggle. Filled when chosen, outlined otherwise.
class _Chip extends StatelessWidget {
  const _Chip(
      {required this.p,
      required this.label,
      required this.selected,
      required this.onTap});
  final V2Palette p;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: selected ? p.ink1 : Colors.transparent,
        shape: StadiumBorder(
            side: BorderSide(color: selected ? p.ink1 : p.line, width: 1.2)),
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
            child: Text(label,
                style: pvManrope(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: selected ? p.ground : p.ink1)),
          ),
        ),
      );
}

class _Tile extends StatelessWidget {
  const _Tile({required this.p, required this.label, required this.value});
  final V2Palette p;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
            color: p.surfaceAlt, borderRadius: BorderRadius.circular(14)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: pvManrope(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: p.ink3)),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value,
                style: pvJakarta(
                    fontSize: 20, fontWeight: FontWeight.w800, color: p.ink1)),
          ),
        ]),
      );
}
