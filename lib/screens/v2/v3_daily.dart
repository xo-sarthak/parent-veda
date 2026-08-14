// =============================================================================
//  V3 daily sections — My journal, and today's medicines
// -----------------------------------------------------------------------------
//  WHAT WENT MISSING, AND WHY IT MATTERS MORE THAN IT LOOKS.
//
//  V3 was built as a CONTENT screen: read this, watch this, practise this. Two
//  of Classic's sections are not content at all — they are the only two places
//  on the home screen where the mother PUTS SOMETHING IN rather than takes
//  something out. Losing them turned the home screen into a magazine.
//
//  They survived as chips in the "Also today" row, which is worse than it
//  sounds. A chip named "Medicines" says the feature exists; it cannot say
//  whether she has taken today's iron, which is the entire question. A daily
//  tick-off demoted to a link is a daily tick-off that stops happening — and
//  because Classic shows it inline for exactly that reason, moving it was a
//  regression dressed as a simplification.
//
//  WHAT IS DIFFERENT FROM CLASSIC, and why each change:
//
//  · NO COLOURED CIRCLES on the journal actions. Classic gives each of the four
//    its own saturated disc — amber, green, coral, blue — which puts four loud
//    hues on one card. DESIGN-LAYER §Q4: one loud colour, many quiet. Here the
//    four sit on the same quiet tinted square and are told apart by their line
//    icon and their label, which is what tells them apart anyway.
//  · NO COUNTER ON THE MEDICINES. Classic is fine; but a "2/3 taken" line is a
//    thing waiting to be cleared, and §16.3 bans those. The row's own tick
//    answers the question without keeping score.
//  · THE EMPTY STATE IS THE ADVERTISEMENT. A feature is never hidden — an empty
//    medicines card says what it would do for her, because the empty state is
//    the only pitch this section ever gets.
//
//  PRESENTATIONAL ONLY. Data and destinations are assembled at the call site in
//  home_v3_screen.dart, the same arrangement V3GarbhSection uses: this file
//  imports no store and no screen, so it cannot drift into knowing about the
//  pregnancy stage.
//
//  ENGLISH ONLY via `.en` at the call site — see v2_sections.dart.
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import 'v2_palette.dart';

// -----------------------------------------------------------------------------
//  My journal
// -----------------------------------------------------------------------------

@immutable
class V3QuickAction {
  const V3QuickAction(
      {required this.icon, required this.label, required this.onTap});

  final IconData icon;

  /// Two words at most. At four-across on a 360dp screen a third word wraps to
  /// a line that then has to be reserved for every tile, tall or not.
  final String label;

  final VoidCallback onTap;
}

/// The four ways in, plus the door to everything already written.
///
/// WHY FOUR ACROSS RATHER THAN A LIST. These are not choices to be weighed —
/// she already knows whether she wants to type, photograph or speak. A list
/// makes her read four rows to find the verb she arrived with; a row of four
/// puts all of them in one glance and one thumb-reach.
class V3JournalSection extends StatelessWidget {
  const V3JournalSection(
      {super.key, required this.actions, required this.p, this.onOpenAll});

  final List<V3QuickAction> actions;
  final V2Palette p;
  final VoidCallback? onOpenAll;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: p.line),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          for (final a in actions) ...[
            Expanded(child: _ActionTile(action: a, p: p)),
            if (a != actions.last) const SizedBox(width: 6),
          ],
        ]),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.center,
          child: TextButton(
            onPressed: onOpenAll,
            child: Text('Open your journal',
                style: pvManrope(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: p.action)),
          ),
        ),
      ]),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.action, required this.p});
  final V3QuickAction action;
  final V2Palette p;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              height: 46,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: p.surfaceAlt,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: p.line),
              ),
              child: Icon(action.icon, size: 20, color: p.ink2),
            ),
            const SizedBox(height: 7),
            Text(action.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: pvManrope(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                    color: p.ink2)),
          ]),
        ),
      );
}

// -----------------------------------------------------------------------------
//  Today's medicines
// -----------------------------------------------------------------------------

@immutable
class V3MedItem {
  const V3MedItem(
      {required this.name,
      required this.sub,
      required this.taken,
      required this.onToggle});

  final String name;

  /// Dose and time, joined. Empty when she has recorded neither, and then the
  /// row is just a name — which is honest rather than padded with "—".
  final String sub;

  final bool taken;
  final VoidCallback onToggle;
}

/// Today's medicines and supplements, tickable in place.
///
/// THE WHOLE VALUE IS "IN PLACE". Anything that needs doing every single day at
/// roughly the same moment has to cost one tap from where she already is; two
/// taps and a screen transition is the difference between a habit and an
/// intention. This is the one section on the page whose job is finishing, not
/// reading — and the reason it earns a place above the fold-ish rather than a
/// chip at the bottom.
class V3MedsSection extends StatelessWidget {
  const V3MedsSection(
      {super.key,
      required this.items,
      required this.p,
      this.onManage,
      this.onAddReminder});

  final List<V3MedItem> items;
  final V2Palette p;
  final VoidCallback? onManage;
  final VoidCallback? onAddReminder;

  /// Green means done-and-safe, and nothing else, per the colour table in
  /// docs/DESIGN-LAYER.md. It is never decorative and never a link.
  static const _done = Color(0xFF4F7A52);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: p.line),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (items.isEmpty) ...[
          // The empty state is the feature's advertisement, so it says what the
          // section would do rather than that it is empty.
          Text('Iron, folate, calcium — whatever you take daily.',
              style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink2)),
          const SizedBox(height: 12),
          _Ghost(
              label: 'Add what you take',
              color: _done,
              p: p,
              onTap: onManage),
        ] else ...[
          for (final m in items) ...[
            _MedRow(item: m, p: p),
            if (m != items.last)
              Divider(height: 1, thickness: 1, color: p.line),
          ],
          const SizedBox(height: 6),
          Row(children: [
            TextButton(
              onPressed: onManage,
              style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  visualDensity: VisualDensity.compact),
              child: Text('Manage',
                  style: pvManrope(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: p.action)),
            ),
            const Spacer(),
            if (onAddReminder != null)
              TextButton.icon(
                onPressed: onAddReminder,
                style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    visualDensity: VisualDensity.compact),
                icon: Icon(Icons.notifications_none_rounded,
                    size: 16, color: p.ink3),
                label: Text('Remind me',
                    style: pvManrope(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: p.ink3)),
              ),
          ]),
        ],
      ]),
    );
  }
}

class _MedRow extends StatelessWidget {
  const _MedRow({required this.item, required this.p});
  final V3MedItem item;
  final V2Palette p;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: item.onToggle,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 11),
          child: Row(children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: item.taken
                    ? V3MedsSection._done
                    : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                    color: item.taken ? V3MedsSection._done : p.line,
                    width: 1.8),
              ),
              child: item.taken
                  ? const Icon(Icons.check_rounded,
                      size: 15, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: pvJakarta(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            color: item.taken ? p.ink3 : p.ink1,
                            // Struck through when taken. The row stays on the
                            // card rather than vanishing: disappearing rows
                            // make her doubt whether the tap registered.
                            decoration: item.taken
                                ? TextDecoration.lineThrough
                                : null)),
                    if (item.sub.isNotEmpty)
                      Text(item.sub,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: pvManrope(fontSize: 11.5, color: p.ink3)),
                  ]),
            ),
          ]),
        ),
      );
}

/// A quiet outlined button. Not the violet action pill — this is an invitation
/// inside an empty card, and the violet belongs to what the page is actually
/// asking her to do.
class _Ghost extends StatelessWidget {
  const _Ghost(
      {required this.label,
      required this.color,
      required this.p,
      required this.onTap});

  final String label;
  final Color color;
  final V2Palette p;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: color.withValues(alpha: 0.45)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(label,
                style: pvManrope(
                    fontSize: 13, fontWeight: FontWeight.w700, color: color)),
            const SizedBox(width: 6),
            Icon(Icons.arrow_forward_rounded, size: 15, color: color),
          ]),
        ),
      );
}
