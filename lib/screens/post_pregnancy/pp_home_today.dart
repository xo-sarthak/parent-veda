// =============================================================================
//  Today on the Parenting home (relevance PP 7, 2026-10-28)
// -----------------------------------------------------------------------------
//  PARENTING-GAP PP 7: "No single lead action, especially after 12 months."
//  Approved in the Artifact prototype (2026-10-28), with the user's three
//  changes: less white space; today's block under "Explore by topic", where
//  Pregnancy keeps its daily practice and TTC its "Recommended"; and an urgent
//  follow-up back at the top, where the "You told us" rows used to sit.
//
//  Three pieces, each only when it applies:
//
//    1. URGENT FOLLOW-UP, above the Today rail. An answer to "Something
//       changed?" whose result told her to see a doctor (`WcTone.urgent`),
//       for 7 days after she told us. We know only what she told us: the
//       concern and the result's tone. We never guess an illness, and the
//       card repeats what the check already said and routes to a doctor.
//
//    2. A VISIT WITHIN A WEEK, first in today's block under the grid. Only
//       ahead, never overdue: with nothing ticked every past visit reads
//       "due", and a card nagging a parent who simply has not recorded would
//       be a false alarm on every open (the Health door's rule, plan H1).
//
//    3. THE FIRST OF TODAY'S THREE, raised. It IS activity one, not a copy,
//       so its tick is the only tick and nothing jumps when she ticks it.
//
//  Both windows read an injected clock (`now:`), so tests move time instead
//  of waiting for it.
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../../widgets/pv_feedback.dart' show PvPress;
import '../v2/v2_palette.dart';
import 'pp_changes_store.dart';
import 'pp_child_profile.dart';
import 'pp_content.dart' show ppAlertInk;
import 'pp_development_data.dart';
import 'pp_phases_data.dart' show ppFillChild;
import 'pp_vaccine_data.dart';
import 'pp_visit_card.dart' show kPpVisitNotes;
import 'pp_what_changed_data.dart' show WcTone;

/// How long an urgent answer leads the home. After this, if she has not
/// cleared it, it is an ordinary "You told us" row for the rest of its three
/// weeks (`kPpChangeActiveFor`).
const Duration kPpUrgentLeadFor = Duration(days: 7);

/// How many days ahead a visit leads today's block.
const int kPpVisitLeadDays = 7;

/// The newest urgent answer for the child on screen, from the last 7 days,
/// or null. `active()` already applies her consent and the child.
PpChange? ppUrgentFollowUp({DateTime? now}) {
  final t = now ?? DateTime.now();
  for (final c in PpChangesStore.instance.active(now: t)) {
    if (c.tone == WcTone.urgent && t.difference(c.at) < kPpUrgentLeadFor) return c;
  }
  return null;
}

/// Whole days from [now]'s date to the visit's date for this child. Visits
/// fall by birthday age, never corrected age (PARENTING-GAP §0).
int ppDaysToVisit(VaxVisit v, {DateTime? now}) {
  final t = now ?? DateTime.now();
  final w = ChildProfileStore.instance.dob.add(Duration(days: v.ageDays));
  return DateTime(w.year, w.month, w.day).difference(DateTime(t.year, t.month, t.day)).inDays;
}

/// The visit that leads today's block: the next one, today or within a week.
VaxVisit? ppVisitLead({DateTime? now}) {
  final v = VaxStore.instance.nextVisit;
  if (v == null || !kPpVisitNotes.containsKey(v.id)) return null;
  final d = ppDaysToVisit(v, now: now);
  return d >= 0 && d <= kPpVisitLeadDays ? v : null;
}

/// "First here, because ..." for the visit: the doors' wording (item 12).
String ppVisitLeadWhy(int days) => switch (days) {
      0 => 'First here, because the visit is today.',
      1 => 'First here, because the visit is tomorrow.',
      _ => 'First here, because the visit is in $days days.',
    };

/// "Yesterday", "3 days ago".
String _ago(DateTime at, DateTime now) {
  final d = DateTime(now.year, now.month, now.day).difference(DateTime(at.year, at.month, at.day)).inDays;
  return d <= 0 ? 'today' : (d == 1 ? 'yesterday' : '$d days ago');
}

// -----------------------------------------------------------------------------
//  The cards. The visit card's shape (white, hairline, radius 18), tighter.
// -----------------------------------------------------------------------------

BoxDecoration _card(V2Palette p, {Color? edge}) => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: edge ?? p.line, width: edge == null ? 1 : 1.4),
    );

Widget _why(String text, V2Palette p) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(top: 1, right: 6),
        child: Icon(Icons.info_outline_rounded, size: 14, color: p.ink3),
      ),
      Expanded(child: Text(text, style: pvManrope(fontSize: 12, height: 1.4, color: p.ink3))),
    ]);

Widget _inkPill(Key key, String label, V2Palette p, VoidCallback onTap) => PvPress(
      child: GestureDetector(
        key: key,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(color: p.ink1, borderRadius: BorderRadius.circular(999)),
          child: Text(label, style: pvManrope(fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.white)),
        ),
      ),
    );

Widget _textButton(Key key, String label, V2Palette p, VoidCallback onTap) => PvPress(
      child: GestureDetector(
        key: key,
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(label,
              style: pvManrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: p.ink1,
                  decoration: TextDecoration.underline)),
        ),
      ),
    );

/// The urgent follow-up, above the Today rail.
class PpUrgentFollowUpCard extends StatelessWidget {
  const PpUrgentFollowUpCard({
    super.key,
    required this.change,
    required this.childName,
    required this.p,
    required this.onOpen,
    required this.onBetter,
    required this.onWorried,
    this.now,
  });

  final PpChange change;
  final String childName;
  final V2Palette p;

  /// Opens the check again, as the "You told us" row does.
  final VoidCallback onOpen;
  final VoidCallback onBetter;

  /// The route the check's own urgent result offered: a doctor.
  final VoidCallback onWorried;
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final alert = ppAlertInk(p);
    // Kept for revert: final what = (change.concern?.label ?? change.concernId).toLowerCase();
    final what = change.name;
    final name = childName.isEmpty ? 'your baby' : childName;
    return Material(
      key: const ValueKey('pp_home_urgent'),
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onOpen,
        child: Ink(
          decoration: _card(p, edge: alert.withValues(alpha: 0.55)),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('YOU TOLD US · ${_ago(change.at, now ?? DateTime.now()).toUpperCase()}',
                style: pvManrope(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.3, color: alert)),
            const SizedBox(height: 3),
            Text('Has $name been seen?',
                style: pvFraunces(fontSize: 18, fontWeight: FontWeight.w600, height: 1.2, color: p.ink1)),
            const SizedBox(height: 5),
            Text('You told us: $what. The check said $name should see a doctor.',
                style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink1)),
            const SizedBox(height: 6),
            _why('First here, because the check said $name should be seen.', p),
            const SizedBox(height: 10),
            Wrap(spacing: 14, runSpacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [
              _inkPill(const ValueKey('pp_home_urgent_better'), 'Better now', p, onBetter),
              _textButton(const ValueKey('pp_home_urgent_worried'), 'Still worried', p, onWorried),
            ]),
            const SizedBox(height: 8),
            Text("We can't tell you what it is. A doctor who sees $name can.",
                style: pvManrope(fontSize: 12, height: 1.4, color: p.ink3)),
          ]),
        ),
      ),
    );
  }
}

/// A visit within a week, first in today's block. The three questions open
/// in place, so the card stays short until she wants them.
class PpVisitLeadCard extends StatefulWidget {
  const PpVisitLeadCard({super.key, required this.visit, required this.days, required this.p, required this.onOpen});

  final VaxVisit visit;
  final int days;
  final V2Palette p;

  /// The vaccines page, as the old card opened.
  final VoidCallback onOpen;

  @override
  State<PpVisitLeadCard> createState() => _PpVisitLeadCardState();
}

class _PpVisitLeadCardState extends State<PpVisitLeadCard> {
  bool _questions = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final v = widget.visit;
    final (what, questions) = kPpVisitNotes[v.id]!;
    final store = VaxStore.instance;
    final names = [for (final id in v.vaccineIds) vaccineById(id).shortName].join(', ');
    final body = pvManrope(fontSize: 13.5, height: 1.5, color: p.ink1);
    return Material(
      key: const ValueKey('pp_home_visit_lead'),
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: widget.onOpen,
        child: Ink(
          decoration: _card(p),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.days == 0 ? 'TODAY' : 'COMING UP · ${store.dateLabelFor(v).toUpperCase()}',
                style: pvManrope(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.3, color: p.action)),
            const SizedBox(height: 3),
            Text('The ${v.ageLabel} visit',
                style: pvFraunces(fontSize: 18, fontWeight: FontWeight.w600, height: 1.2, color: p.ink1)),
            const SizedBox(height: 5),
            Text(what, style: body),
            const SizedBox(height: 4),
            Text.rich(TextSpan(children: [
              TextSpan(text: 'Vaccines: ', style: body.copyWith(fontWeight: FontWeight.w800)),
              TextSpan(text: names),
            ]), style: body),
            if (_questions) ...[
              const SizedBox(height: 8),
              Text('Three questions to ask', style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w800, color: p.ink1)),
              const SizedBox(height: 4),
              for (final q in questions)
                Padding(
                  key: ValueKey('pp_home_visit_q_${questions.indexOf(q)}'),
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8, right: 10),
                      child: Container(width: 5, height: 5, decoration: BoxDecoration(color: p.ink1, shape: BoxShape.circle)),
                    ),
                    Expanded(child: Text(q, style: body)),
                  ]),
                ),
            ],
            const SizedBox(height: 6),
            _why(ppVisitLeadWhy(widget.days), p),
            const SizedBox(height: 10),
            Wrap(spacing: 14, runSpacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [
              _inkPill(const ValueKey('pp_home_visit_questions'), _questions ? 'Hide the questions' : 'Three questions to ask', p,
                  () => setState(() => _questions = !_questions)),
              _textButton(const ValueKey('pp_home_visit_open'), 'Open vaccines', p, widget.onOpen),
            ]),
            const SizedBox(height: 8),
            Text('Your paediatrician will tell you what applies to your child.',
                style: pvManrope(fontSize: 12, height: 1.4, color: p.ink3)),
          ]),
        ),
      ),
    );
  }
}

/// The first of today's three, raised: a row that stands out, not a poster.
/// "Start here", the activity's painting (or its drawn mark), the title, the
/// time, and the same round check the rows use.
class PpFirstActivityCard extends StatelessWidget {
  const PpFirstActivityCard({
    super.key,
    required this.activity,
    required this.leading,
    required this.done,
    required this.p,
    required this.onOpen,
    required this.onDone,
    required this.onSwap,
    this.why,
  });

  final DevActivity activity;

  /// "Because you said: ..." when what she told us raised it (PP 4).
  final String? why;
  final Widget leading;
  final bool done;
  final V2Palette p;
  final VoidCallback onOpen;
  final VoidCallback onDone;
  final VoidCallback onSwap;

  @override
  Widget build(BuildContext context) {
    final a = activity;
    return PvPress(
      child: Material(
        key: ValueKey('pp_home_activity_first_${a.id}'),
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onOpen,
          onLongPress: onSwap,
          child: Ink(
            decoration: _card(p),
            padding: const EdgeInsets.fromLTRB(10, 10, 4, 10),
            child: Row(children: [
              leading,
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('START HERE',
                      style: pvManrope(fontSize: 10.5, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: p.action)),
                  const SizedBox(height: 2),
                  Text(ppFillChild(a.title),
                      style: pvFraunces(
                          fontSize: 17, fontWeight: FontWeight.w600, height: 1.2, color: done ? p.ink2 : p.ink1)),
                  const SizedBox(height: 2),
                  Text(a.metaLine, style: pvManrope(fontSize: 12.5, height: 1.4, color: p.ink3)),
                  if (why case final w?) ...[
                    const SizedBox(height: 4),
                    KeyedSubtree(key: ValueKey('pp_home_activity_why_${a.id}'), child: _why(w, p)),
                  ],
                ]),
              ),
              Semantics(
                button: true,
                label: done ? 'Done' : 'Mark as done',
                child: GestureDetector(
                  key: ValueKey('pp_home_activity_done_${a.id}'),
                  onTap: onDone,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: done ? p.ink1 : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(color: done ? p.ink1 : p.ink3, width: 1.5),
                      ),
                      child: done
                          ? Text('✓', style: pvManrope(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white))
                          : null,
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
