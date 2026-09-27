// =============================================================================
//  TTC - Supplements
// -----------------------------------------------------------------------------
//  A record of what they actually take, and whether they took it today.
//
//  What this screen deliberately has no room for: an adherence percentage, a
//  streak, a colour that changes as you fall behind, or any wording that turns
//  a missed Tuesday into a failure. The pregnancy app's medication tracker set
//  that rule and this follows it exactly - "a weekday awareness grid rather
//  than a compliance score".
//
//  Both partners' supplements live on one screen, because zinc and CoQ10 are
//  his in the same way folic acid is hers, and putting his on a separate page
//  is how a couple-first product quietly becomes a single-user one.
//
//  ---------------------------------------------------------------------------
//  ⚠️ REBUILT 2026-09-27 (tool rebuild, night). The user, walking build 13:
//  "old tools in new clothes... poor functionality". The shell was new; the
//  insides were the V1 look (shadowed cards, a purple tick, a coral eyebrow,
//  an "Edit" link that opened a sheet) and the job had gaps:
//
//    · A tick could only ever be today's. Forget on Tuesday and Tuesday stayed
//      empty for good. Now a seven-day strip picks the day (Apple Health
//      Medications, mobbin.com/screens/19cc770b-a386-48a5-9d6b-7a46a8c98685)
//      and the item's page shows four weeks she can correct.
//    · An item had no page: no history, and remove lived at the foot of the
//      edit sheet. Now the name opens its own page: today's tick, the last
//      four weeks, change, remove (Superpower "Today's actions", a box to do
//      and a chevron to open, mobbin.com/screens/6ded6c90-7a86-4441-8536-510cef3e0c65).
//    · Lists saved before the one-name rule held "Folic acid" twice, each with
//      its own ticks, and nothing could join them. Now the pair is named at
//      the top with a "Merge them" that keeps every tick (Pinterest "Merge
//      sections?" says what moves and what goes,
//      mobbin.com/screens/a8426b22-11e4-4673-bce0-bac94d0b5724).
//    · Suggestions already on the list stayed on screen with a tick, so eight
//      long cards sat under even a full list. Now only the ones not yet added
//      show, as rows.
//    · What to Expect opens its Prenatal Vitamin log with one read; ours had
//      none (gap analysis, "Link reads and logging"). The timing read sits
//      under the list now.
//
//  Add stays one calm sheet (Hims / Hers "Set your reminder",
//  mobbin.com/screens/164de70f-f4dd-4b24-88b0-394b5c4acc88): whose, name, dose.
//  The shared parts live in `ttc_dose_parts.dart` so Medication is laid out of
//  the same pieces. The screen as it was is kept, commented, at the foot.
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../../ttc/ttc_journal_store.dart' show TtcAuthor;
import '../../ttc/ttc_supplements_store.dart';
import '../products/pv_store_chrome.dart' show pvSnack;
import '../v2/v2_palette.dart';
import 'ttc_dose_parts.dart';
import 'ttc_ivf_readiness_screen.dart' show kIvfHue;
import 'ttc_medication_screen.dart' show openTtcMedication;
import 'ttc_strings.dart';
import 'ttc_surface_router.dart' show openTtcSurface, kTtcReadPrefix;
import 'ttc_tool_chrome.dart';
import 'ttc_tool_confirm.dart';

/// The read that sits under the list: which supplement to start when.
const String kTtcSupplementsRead = 'ttc_read_supplement_timing';

class TtcSupplementsScreen extends StatefulWidget {
  const TtcSupplementsScreen({super.key});

  @override
  State<TtcSupplementsScreen> createState() => _TtcSupplementsScreenState();
}

class _TtcSupplementsScreenState extends State<TtcSupplementsScreen> {
  /// The day the ticks are for. Today unless she picks another in the strip.
  DateTime _day = ttcDoseDay(DateTime.now());

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(
          [TtcSupplementsStore.instance, TtcLang.instance]),
      builder: (context, _) {
        final t = TtcS.current();
        final hi = t.hinglish;
        final p = V2PaletteStore.instance.current;
        final store = TtcSupplementsStore.instance;
        final mine = store.forAuthor(TtcAuthor.me);
        final theirs = store.forAuthor(TtcAuthor.partner);
        final dupes = store.duplicates();
        final isToday = ttcDoseSameDay(_day, DateTime.now());
        // Only what is not on the list yet: a suggestion she has already
        // added is on the list above, not a second time down here.
        final ideas = [
          for (final s in ttcSuggestedSupplements)
            if (!store.has(s.name,
                s.forPartner ? TtcAuthor.partner : TtcAuthor.me))
              s
        ];

        Widget row(TtcSupplement s) => TtcDoseRow(
              name: s.name,
              detail: s.dose,
              taken: store.isTaken(s.id, on: _day),
              onTick: () => store.toggleTaken(s.id, on: _day),
              onOpen: () => openTtcSupplement(context, s.id),
            );

        return TtcToolScaffold(
          // Care and medicines' hue in Tools, the same as Medication.
          hue: kIvfHue,
          // ⚠️ ONE TOOL, ONE NAME (2026-09-27): the eyebrow IS the Tools
          // tile's name, word for word; the title is the tile's own line.
          eyebrow: t.supplements,
          title: 'What you choose to take, like folic acid.',
          // ⚠️ SAY WHAT THIS IS, FIRST. The line says what each tap does,
          // and changes once there is a list to tap. Kept for revert:
          // intro: 'A daily list of the vitamins you each take. Tap one to '
          //     'tick it for today.',
          intro: store.items.isEmpty
              ? 'A daily list of the vitamins you each take. Add yours, then '
                  'tick them off each day.'
              : 'Tap the circle when you take one. Tap the name to see its '
                  'days, change it or remove it.',
          // The same "Add" Records and Appointments wear, top right.
          action: TtcDoseHeroAdd(onTap: () => editTtcSupplement(context, null)),
          children: [
            ttcToolPad(Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 22),

                // Two rows of one name, from before the one-name rule.
                for (final g in dupes) ...[
                  _MergeNotice(group: g),
                  const SizedBox(height: 14),
                ],

                if (store.items.isEmpty)
                  // The empty state keeps its promise: its button opens a
                  // form she can type into, and the suggestions sit below.
                  TtcDoseEmpty(
                    icon: Icons.eco_outlined,
                    title: t.supplementsEmptyTitle,
                    body: t.supplementsEmptyBody,
                    cta: 'Add your own',
                    onTap: () => editTtcSupplement(context, null),
                  )
                else ...[
                  TtcDayStrip(
                    selected: _day,
                    onPick: (d) => setState(() => _day = d),
                    anyTakenOn: store.anyTakenOn,
                  ),
                  const SizedBox(height: 16),
                  // A count, never a percentage, and it says what it counts.
                  // Kept for revert (2026-09-27): the "Taken today" card with
                  // '${store.takenToday()} of ${store.items.length}'.
                  Text.rich(
                    key: const ValueKey('ttc_supp_count'),
                    TextSpan(children: [
                      TextSpan(
                          text: ttcDoseDayName(_day),
                          style: pvManrope(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: p.ink1)),
                      TextSpan(
                          text: '  ·  ${store.takenToday(on: _day)} of '
                              '${store.items.length} taken',
                          style: pvManrope(fontSize: 13.5, color: p.ink2)),
                    ]),
                  ),
                  if (!isToday) ...[
                    const SizedBox(height: 4),
                    Text('Tick what you took that day.',
                        style: pvManrope(fontSize: 12.5, color: p.ink2)),
                  ],
                  const SizedBox(height: 14),
                  if (mine.isNotEmpty) ...[
                    TtcDoseGroup(
                        label: hi ? 'Aapke' : 'Yours',
                        children: [for (final s in mine) row(s)]),
                    const SizedBox(height: 18),
                  ],
                  if (theirs.isNotEmpty) ...[
                    TtcDoseGroup(
                        label: hi ? 'Partner ke' : "Your partner's",
                        children: [for (final s in theirs) row(s)]),
                    const SizedBox(height: 18),
                  ],
                ],

                const SizedBox(height: 8),
                // What to Expect's vitamin log opens with one read; this is
                // ours, where she is deciding what to take.
                TtcDoseLinkRow(
                  key: const ValueKey('ttc_supp_read'),
                  icon: Icons.menu_book_outlined,
                  eyebrow: 'Read',
                  text: 'When to start what, and how early',
                  onTap: () => openTtcSurface(
                      context, '$kTtcReadPrefix$kTtcSupplementsRead'),
                ),

                if (ideas.isNotEmpty) ...[
                  const SizedBox(height: 26),
                  ttcDoseHeading(t.supplementsSuggested),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                        "Tap one to add it to your list. Listing one here "
                        "isn't advice to take it.",
                        style: pvManrope(
                            fontSize: 12.5, height: 1.5, color: p.ink2)),
                  ),
                  // Offering is not recommending. The dose is left as "as
                  // advised" on purpose for everything except folic acid,
                  // where the guideline number is genuinely universal.
                  TtcDoseGroup(children: [
                    for (final s in ideas) _SuggestionRow(suggestion: s, t: t),
                  ]),
                ],

                const SizedBox(height: 22),
                // ⚠️ ONE PLAIN LINE ON THE DIFFERENCE, the mirror of the one
                // on Medication: two tiles sit side by side in Tools, and
                // nothing said which one a prescription goes in.
                TtcDoseLinkRow(
                  icon: Icons.medication_outlined,
                  text: 'Something your clinic prescribed? That goes in '
                      'Medication.',
                  onTap: () => openTtcMedication(context),
                ),
                const SizedBox(height: 16),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(Icons.info_outline_rounded, size: 15, color: p.ink3),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(t.supplementsDisclaimer,
                        style: pvManrope(
                            fontSize: 11.5, height: 1.5, color: p.ink3)),
                  ),
                ]),
                const SizedBox(height: 26),
              ],
            )),
          ],
        );
      },
    );
  }
}

/// One suggestion, as a row. The whole row adds it.
class _SuggestionRow extends StatelessWidget {
  const _SuggestionRow({required this.suggestion, required this.t});

  final TtcSuggestedSupplement suggestion;
  final TtcS t;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final author = suggestion.forPartner ? TtcAuthor.partner : TtcAuthor.me;
    return InkWell(
      onTap: () {
        TtcSupplementsStore.instance.add(
          suggestion.name,
          dose: suggestion.dose,
          author: author,
        );
        // Tell her where it went: a partner's item lands in a list further
        // up the screen, out of sight of the thumb that added it.
        pvSnack(
            context,
            suggestion.forPartner
                ? "Added to your partner's list"
                : 'Added to your list',
            icon: Icons.check_rounded,
            lift: 24);
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Flexible(
              child: Text(suggestion.name,
                  style: pvJakarta(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: p.ink1)),
            ),
            if (suggestion.forPartner) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: p.line),
                ),
                child: Text(t.forPartnerTag,
                    style: pvManrope(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: p.ink2)),
              ),
            ],
            const Spacer(),
            // Says what a tap does, in words, beside the name.
            Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.add_rounded, size: 16, color: p.ink1),
              const SizedBox(width: 3),
              Text('Add',
                  style: pvManrope(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: p.ink1)),
            ]),
          ]),
          const SizedBox(height: 6),
          Text(suggestion.note(t.hinglish),
              style: pvManrope(fontSize: 12.5, height: 1.5, color: p.ink2)),
        ]),
      ),
    );
  }
}

/// Two rows of one name, from a list saved before the one-name rule. Says
/// what a merge keeps, and does it only when she taps.
class _MergeNotice extends StatelessWidget {
  const _MergeNotice({required this.group});

  final List<TtcSupplement> group;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final first = group.first;
    final dose = TtcSupplementsStore.mergedDose(group);
    final whose =
        first.author == TtcAuthor.partner ? "your partner's list" : 'your list';
    final times = group.length == 2 ? 'twice' : '${group.length} times';
    return Container(
      key: ValueKey('ttc_supp_dupe_${first.id}'),
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: p.ink2, width: 1.2),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('${first.name} is on $whose $times',
            style: pvJakarta(
                fontSize: 15, fontWeight: FontWeight.w700, color: p.ink1)),
        const SizedBox(height: 6),
        Text(
            'Merge them into one row: ${first.name}'
            '${dose.isEmpty ? '' : ', $dose'}. Every day you ticked either '
            'one is kept. Or open one below to change or remove it.',
            style: pvManrope(fontSize: 13, height: 1.5, color: p.ink2)),
        const SizedBox(height: 12),
        TtcDoseInkButton(
          key: ValueKey('ttc_supp_merge_${first.id}'),
          label: 'Merge them',
          icon: Icons.call_merge_rounded,
          onTap: () {
            final kept = TtcSupplementsStore.instance.merge(group);
            if (kept != null) {
              pvSnack(context, '${kept.name} is one row now',
                  icon: Icons.check_rounded, lift: 24);
            }
          },
        ),
      ]),
    );
  }
}

// =============================================================================
//  One supplement's own page
// =============================================================================

/// Opens one supplement: today's tick, its last four weeks, change, remove.
void openTtcSupplement(BuildContext context, String id) {
  Navigator.of(context).push(MaterialPageRoute<void>(
    builder: (_) => TtcSupplementDetailScreen(id: id),
    settings: const RouteSettings(name: 'ttc/supplement'),
  ));
}

class TtcSupplementDetailScreen extends StatefulWidget {
  const TtcSupplementDetailScreen({super.key, required this.id});

  final String id;

  @override
  State<TtcSupplementDetailScreen> createState() =>
      _TtcSupplementDetailScreenState();
}

class _TtcSupplementDetailScreenState extends State<TtcSupplementDetailScreen> {
  /// The row as last seen, so the page does not flash "not on the list"
  /// while it slides away after she removes it.
  TtcSupplement? _last;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: TtcSupplementsStore.instance,
      builder: (context, _) {
        final t = TtcS.current();
        final p = V2PaletteStore.instance.current;
        final store = TtcSupplementsStore.instance;
        final s = store.byId(widget.id) ?? _last;
        _last = s;
        if (s == null) {
          // Removed or merged while this page was open. Say so, never blank.
          return TtcToolScaffold(
            hue: kIvfHue,
            eyebrow: t.supplements,
            title: 'Not on the list any more.',
            intro: 'It was removed, or merged into another row with the same '
                'name. Close this to go back to the list.',
            children: const [SizedBox(height: 40)],
          );
        }
        final partner = s.author == TtcAuthor.partner;
        return TtcToolScaffold(
          hue: kIvfHue,
          eyebrow: t.supplements,
          title: s.name,
          intro: [
            s.dose.isEmpty ? 'No dose written down yet.' : s.dose,
            partner ? "On your partner's list." : 'On your list.',
          ].join(' '),
          variant: 3,
          children: [
            ttcToolPad(Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 22),
                TtcDoseTodayButton(
                  taken: store.isTaken(s.id),
                  onTap: () => store.toggleTaken(s.id),
                ),
                const SizedBox(height: 26),
                ttcDoseHeading('The last four weeks'),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                      'Each filled circle is a day it was ticked. Tap a day '
                      'to add or clear it.',
                      style: pvManrope(
                          fontSize: 12.5, height: 1.5, color: p.ink2)),
                ),
                TtcDoseHistory(
                  takenOn: (d) => store.isTaken(s.id, on: d),
                  onToggle: (d) => store.toggleTaken(s.id, on: d),
                ),
                const SizedBox(height: 26),
                TtcDoseLinkRow(
                  key: const ValueKey('ttc_supp_change'),
                  icon: Icons.edit_outlined,
                  text: 'Change the name or dose',
                  onTap: () => editTtcSupplement(context, s),
                ),
                const SizedBox(height: 14),
                TtcDoseRemoveLine(
                  label: 'Remove from the list',
                  onTap: () => _remove(context, s),
                ),
                const SizedBox(height: 26),
              ],
            )),
          ],
        );
      },
    );
  }

  Future<void> _remove(BuildContext context, TtcSupplement s) async {
    final nav = Navigator.of(context);
    final ok = await ttcConfirmRemove(context,
        title: 'Remove ${s.name}?', body: 'The days you ticked it go too.');
    if (!ok || !context.mounted) return;
    pvSnack(context, '${s.name} removed', lift: 24);
    TtcSupplementsStore.instance.remove(s.id);
    nav.maybePop();
  }
}

// =============================================================================
//  Add your own, or change one - one sheet for both
// =============================================================================

/// Opens the sheet to add a supplement she types herself, or to change the
/// name or dose of one already on the list. Removing lives on the item's
/// page, one place, behind a question.
Future<void> editTtcSupplement(BuildContext context, TtcSupplement? existing) =>
    showTtcDoseSheet<void>(
      context,
      routeName: 'ttc/supplement_edit',
      builder: (_) => _SupplementSheet(existing: existing),
    );

class _SupplementSheet extends StatefulWidget {
  const _SupplementSheet({this.existing});
  final TtcSupplement? existing;

  @override
  State<_SupplementSheet> createState() => _SupplementSheetState();
}

class _SupplementSheetState extends State<_SupplementSheet> {
  late final _name = TextEditingController(text: widget.existing?.name ?? '');
  late final _dose = TextEditingController(text: widget.existing?.dose ?? '');
  late TtcAuthor _whose = widget.existing?.author ?? TtcAuthor.me;
  String? _problem;

  @override
  void dispose() {
    _name.dispose();
    _dose.dispose();
    super.dispose();
  }

  void _clearProblem(String _) {
    if (_problem != null) setState(() => _problem = null);
  }

  void _save() {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _problem = 'Add a name to save.');
      return;
    }
    final store = TtcSupplementsStore.instance;
    final e = widget.existing;
    if (e == null) {
      if (store.has(name, _whose)) {
        setState(() => _problem = _whose == TtcAuthor.partner
            ? "It's already on your partner's list."
            : "It's already on your list.");
        return;
      }
      store.add(name, dose: _dose.text, author: _whose);
      pvSnack(
          context,
          _whose == TtcAuthor.partner
              ? "Added to your partner's list"
              : 'Added to your list',
          icon: Icons.check_rounded,
          lift: 24);
    } else if (!store.update(e.id, name: name, dose: _dose.text)) {
      setState(() => _problem = 'Another one on this list has that name.');
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.existing != null;
    return TtcDoseSheet(
      eyebrow: 'Supplements',
      title: editing ? 'Change this supplement' : 'Add a supplement',
      children: [
        // Whose it is is fixed once it has days behind it, so the choice
        // only shows when adding.
        if (!editing) ...[
          ttcDoseLabel('Whose is it'),
          TtcDoseWhose(
            partner: _whose == TtcAuthor.partner,
            onPick: (partner) => setState(() =>
                _whose = partner ? TtcAuthor.partner : TtcAuthor.me),
          ),
          const SizedBox(height: 16),
        ],
        TtcDoseField(
            label: 'Name',
            controller: _name,
            hint: 'Vitamin D',
            autofocus: !editing,
            onChanged: _clearProblem),
        TtcDoseField(
            label: 'Dose (optional)',
            controller: _dose,
            hint: 'What your doctor said, like 1000 IU daily',
            onChanged: _clearProblem),
        const SizedBox(height: 4),
        TtcToolPrimary(
          key: const ValueKey('ttc_supp_save'),
          label: editing ? 'Save changes' : 'Add to the list',
          onTap: _save,
        ),
        if (_problem != null) TtcFormHint(text: _problem!),
      ],
    );
  }
}

// =============================================================================
//  Kept for revert (2026-09-27, tool rebuild): the whole supplements screen
//  as it was before the rebuild, every line commented. The imports it needs
//  are the ones above plus those listed at its head.
// =============================================================================
// // =============================================================================
// //  TTC - Supplements
// // -----------------------------------------------------------------------------
// //  A record of what they actually take, and whether they took it today.
// //
// //  What this screen deliberately has no room for: an adherence percentage, a
// //  streak, a colour that changes as you fall behind, or any wording that turns
// //  a missed Tuesday into a failure. The pregnancy app's medication tracker set
// //  that rule and this follows it exactly - "a weekday awareness grid rather
// //  than a compliance score".
// //
// //  Both partners' supplements live on one screen, because zinc and CoQ10 are
// //  his in the same way folic acid is hers, and putting his on a separate page
// //  is how a couple-first product quietly becomes a single-user one.
// // =============================================================================
//
// import 'package:flutter/material.dart';
//
// import '../../ttc/ttc_journal_store.dart' show TtcAuthor;
// import '../../ttc/ttc_supplements_store.dart';
// import '../products/pv_store_chrome.dart' show pvSnack;
// import 'ttc_common.dart';
// import 'ttc_ivf_readiness_screen.dart' show kIvfHue;
// import 'ttc_medication_screen.dart' show openTtcMedication;
// import 'ttc_strings.dart';
// import 'ttc_tool_chrome.dart';
// import 'ttc_tool_confirm.dart';
//
// class TtcSupplementsScreen extends StatelessWidget {
//   const TtcSupplementsScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: Listenable.merge(
//           [TtcSupplementsStore.instance, TtcLang.instance]),
//       builder: (context, _) {
//         final t = TtcS.current();
//         final hi = t.hinglish;
//         final store = TtcSupplementsStore.instance;
//         final mine = store.forAuthor(TtcAuthor.me);
//         final theirs = store.forAuthor(TtcAuthor.partner);
//
//         // ⚠️ ONE SHELL FOR EVERY TOOL (2026-09-27). Tiles in the same Tools
//         // hub opened in two different shells: most wore `TtcToolScaffold`
//         // (hero field, serif title, white sheet) and this one a plain page
//         // with a back bar. "ParentVeda is one app... we cannot be having
//         // same things represented as different." Only the shell changed:
//         // the tile's name is the hero title, the what-this-is line is the
//         // hero intro, and everything else sits in the sheet unchanged.
//         // Kept for revert (2026-09-27):
//         // return Scaffold(
//         //   backgroundColor: ttcBg,
//         //   body: SafeArea(
//         //     child: ListView(
//         //       padding: const EdgeInsets.fromLTRB(
//         //           ttcGutter, 8, ttcGutter, ttcBottomInset),
//         //       children: [
//         //         TtcBackBar(title: t.supplements),
//         //         const SizedBox(height: 12),
//         //         Text(
//         //             'A daily list of the vitamins you each take. Tap one to '
//         //             'tick it for today.',
//         //             style: ttcBody(14, h: 1.55)),
//         //         const SizedBox(height: 8),
//         return TtcToolScaffold(
//           // Care and medicines' hue in Tools, the same as Medication.
//           hue: kIvfHue,
//           // ⚠️ ONE TOOL, ONE NAME (2026-09-27): the eyebrow IS the Tools
//           // tile's name, word for word; the title is the tile's own line.
//           eyebrow: t.supplements,
//           title: 'What you choose to take, like folic acid.',
//           // ⚠️ SAY WHAT THIS IS, FIRST (tools pass, 2026-09-27). The
//           // screen opened on an empty card, and nothing said what a
//           // tap on a row does. One line now says both.
//           intro: 'A daily list of the vitamins you each take. Tap one to '
//               'tick it for today.',
//           children: [
//             ttcToolPad(Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 const SizedBox(height: 22),
//                 // ⚠️ ONE PLAIN LINE ON THE DIFFERENCE, the mirror of the one on
//                 // Medication: two tiles sit side by side in Tools, and nothing
//                 // said which one a prescription goes in.
//                 GestureDetector(
//                   onTap: () => openTtcMedication(context),
//                   behavior: HitTestBehavior.opaque,
//                   child: Row(children: [
//                     Expanded(
//                       child: Text(
//                           'Something your clinic prescribed? That goes in '
//                           'Medication.',
//                           style: ttcBody(12.5,
//                               color: ttcPurple, w: FontWeight.w700)),
//                     ),
//                     const Icon(Icons.chevron_right_rounded,
//                         size: 18, color: ttcPurple),
//                   ]),
//                 ),
//                 const SizedBox(height: 16),
//
//                 if (store.items.isEmpty)
//                   // ⚠️ THE EMPTY STATE NOW KEEPS ITS PROMISE. It said "Add
//                   // what you take" over a screen that could only add eight
//                   // suggestions. It now opens a form she can type into.
//                   TtcEmpty(
//                     icon: Icons.medication_outlined,
//                     title: t.supplementsEmptyTitle,
//                     body: t.supplementsEmptyBody,
//                     cta: 'Add your own',
//                     onTap: () => editTtcSupplement(context, null),
//                   )
//                 else ...[
//                   // "2 of 4" - a count, never a percentage. It says what it
//                   // counts ("2 of 4 ticked today") rather than a bare fraction.
//                   TtcCard(
//                     color: ttcPanel,
//                     child: Row(children: [
//                       Expanded(
//                         child: Text(t.supplementsTakenToday,
//                             style: ttcBody(13.5,
//                                 color: ttcTitleInk, w: FontWeight.w700)),
//                       ),
//                       // Kept for revert (2026-09-27):
//                       // '${store.takenToday()} / ${store.items.length}'
//                       Text('${store.takenToday()} of ${store.items.length}',
//                           style: ttcJakarta(17, color: ttcPurple)),
//                     ]),
//                   ),
//                   const SizedBox(height: 18),
//                   if (mine.isNotEmpty) ...[
//                     ttcEyebrow(hi ? 'Aapke' : 'Yours', color: ttcPurple),
//                     const SizedBox(height: 11),
//                     for (final s in mine) ...[
//                       _SupplementRow(item: s, t: t),
//                       const SizedBox(height: 10),
//                     ],
//                     const SizedBox(height: 10),
//                   ],
//                   if (theirs.isNotEmpty) ...[
//                     ttcEyebrow(hi ? 'Partner ke' : "Your partner's",
//                         color: ttcCoral),
//                     const SizedBox(height: 11),
//                     for (final s in theirs) ...[
//                       _SupplementRow(item: s, t: t),
//                       const SizedBox(height: 10),
//                     ],
//                     const SizedBox(height: 10),
//                   ],
//                   // Mobbin: Noom's "Can't find it? Let's add it!" row at the
//                   // foot of a list, and Garmin's "Create Food". The suggestions
//                   // are a shortcut, never the only way in.
//                   GestureDetector(
//                     key: const ValueKey('ttc_supp_add_own'),
//                     onTap: () => editTtcSupplement(context, null),
//                     behavior: HitTestBehavior.opaque,
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 6),
//                       child: Row(children: [
//                         const Icon(Icons.add_circle_outline_rounded,
//                             size: 17, color: ttcPurple),
//                         const SizedBox(width: 8),
//                         Text('Add your own',
//                             style: ttcBody(13,
//                                 color: ttcPurple, w: FontWeight.w800)),
//                       ]),
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                 ],
//
//                 const SizedBox(height: 10),
//                 ttcSectionTitle(t.supplementsSuggested),
//                 Padding(
//                   padding: const EdgeInsets.only(bottom: 10),
//                   child: Text('Tap one to add it to the list above.',
//                       style: ttcBody(12.5, color: ttcSoft)),
//                 ),
//                 // Offering is not recommending. The dose is left as "as
//                 // advised" on purpose for everything except folic acid, where
//                 // the guideline number is genuinely universal.
//                 for (final s in ttcSuggestedSupplements) ...[
//                   _SuggestionCard(suggestion: s, t: t),
//                   const SizedBox(height: 10),
//                 ],
//
//                 const SizedBox(height: 14),
//                 Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                   const Icon(Icons.info_outline_rounded,
//                       size: 15, color: ttcMuted),
//                   const SizedBox(width: 9),
//                   Expanded(
//                     child: Text(t.supplementsDisclaimer,
//                         style: ttcBody(11.5, color: ttcMuted, h: 1.5)),
//                   ),
//                 ]),
//                 const SizedBox(height: 26),
//               ],
//             )),
//           ],
//           // Kept for revert (2026-09-27): the old page's closing.
//           //     ],
//           //   ),
//           // ),
//         );
//       },
//     );
//   }
// }
//
// class _SupplementRow extends StatelessWidget {
//   const _SupplementRow({required this.item, required this.t});
//
//   final TtcSupplement item;
//   final TtcS t;
//
//   @override
//   Widget build(BuildContext context) {
//     final taken = TtcSupplementsStore.instance.isTaken(item.id);
//     return TtcCard(
//       padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
//       onTap: () => TtcSupplementsStore.instance.toggleTaken(item.id),
//       child: Row(children: [
//         Container(
//           width: 24,
//           height: 24,
//           alignment: Alignment.center,
//           decoration: BoxDecoration(
//             color: taken ? ttcPurple : Colors.transparent,
//             shape: BoxShape.circle,
//             border: Border.all(
//                 color: taken ? ttcPurple : ttcBorder, width: 1.6),
//           ),
//           child: taken
//               ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
//               : null,
//         ),
//         const SizedBox(width: 13),
//         Expanded(
//           child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             Text(item.name,
//                 style: ttcBody(14, color: ttcInk, w: FontWeight.w700)),
//             if (item.dose.isNotEmpty) ...[
//               const SizedBox(height: 2),
//               Text(item.dose, style: ttcBody(12)),
//             ],
//           ]),
//         ),
//         // ⚠️ EDIT, NOT AN INSTANT "x" (tools pass, 2026-09-27). The x removed
//         // the supplement and every day she ticked it, at once, with no
//         // question. The dose could never be corrected either. Both now live
//         // in one sheet, and removing asks first. Kept for revert:
//         // GestureDetector(
//         //   onTap: () => TtcSupplementsStore.instance.remove(item.id),
//         //   behavior: HitTestBehavior.opaque,
//         //   child: const Padding(
//         //     padding: EdgeInsets.only(left: 10),
//         //     child: Icon(Icons.close_rounded, size: 16, color: ttcMuted),
//         //   ),
//         // ),
//         GestureDetector(
//           onTap: () => editTtcSupplement(context, item),
//           behavior: HitTestBehavior.opaque,
//           child: Padding(
//             padding: const EdgeInsets.only(left: 10),
//             child: Text('Edit',
//                 style: ttcBody(12.5, color: ttcPurple, w: FontWeight.w800)),
//           ),
//         ),
//       ]),
//     );
//   }
// }
//
// class _SuggestionCard extends StatelessWidget {
//   const _SuggestionCard({required this.suggestion, required this.t});
//
//   final TtcSuggestedSupplement suggestion;
//   final TtcS t;
//
//   @override
//   Widget build(BuildContext context) {
//     final hi = t.hinglish;
//     final author = suggestion.forPartner ? TtcAuthor.partner : TtcAuthor.me;
//     // ⚠️ BY NAME AND PERSON (tools pass, 2026-09-27). The store already
//     // matched this way; the card still matched by name alone, so once she had
//     // CoQ10 his CoQ10 showed as already added and could not be tapped. Kept
//     // for revert:
//     // final already = TtcSupplementsStore.instance.items
//     //     .any((e) => e.name.toLowerCase() == suggestion.name.toLowerCase());
//     final already = TtcSupplementsStore.instance.has(suggestion.name, author);
//     return TtcCard(
//       onTap: already
//           ? null
//           : () {
//               TtcSupplementsStore.instance.add(
//                 suggestion.name,
//                 dose: suggestion.dose,
//                 author: author,
//               );
//               // Tell her where it went: a partner's item lands in a list
//               // further up the screen, out of sight of the thumb that added it.
//               pvSnack(
//                   context,
//                   suggestion.forPartner
//                       ? "Added to your partner's list"
//                       : 'Added to your list',
//                   icon: Icons.check_rounded,
//                   lift: 24);
//             },
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         Row(children: [
//           Expanded(child: Text(suggestion.name, style: ttcJakarta(15))),
//           if (suggestion.forPartner) ...[
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
//               decoration: BoxDecoration(
//                   color: ttcCoralTint,
//                   borderRadius: BorderRadius.circular(999)),
//               child: Text(t.forPartnerTag,
//                   style: ttcBody(10, color: ttcCoral, w: FontWeight.w800)),
//             ),
//             const SizedBox(width: 8),
//           ],
//           // The add mark shows on his suggestions too, so "For your partner"
//           // reads as whose it is and the plus as what a tap does.
//           if (already)
//             const Icon(Icons.check_circle_rounded, size: 18, color: ttcPurple)
//           else
//             const Icon(Icons.add_circle_outline_rounded,
//                 size: 18, color: ttcPurple),
//         ]),
//         const SizedBox(height: 7),
//         Text(suggestion.note(hi), style: ttcBody(12.5, h: 1.5)),
//       ]),
//     );
//   }
// }
//
// // =============================================================================
// //  Add your own, or change one - one sheet for both (tools pass, 2026-09-27)
// // =============================================================================
//
// /// Opens the sheet to add a supplement she types herself, or to change the
// /// name or dose of one already on the list, or to remove it (after asking).
// Future<void> editTtcSupplement(
//         BuildContext context, TtcSupplement? existing) =>
//     showModalBottomSheet<void>(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       routeSettings: const RouteSettings(name: 'ttc/supplement_edit'),
//       builder: (_) => _SupplementSheet(existing: existing),
//     );
//
// class _SupplementSheet extends StatefulWidget {
//   const _SupplementSheet({this.existing});
//   final TtcSupplement? existing;
//
//   @override
//   State<_SupplementSheet> createState() => _SupplementSheetState();
// }
//
// class _SupplementSheetState extends State<_SupplementSheet> {
//   late final _name = TextEditingController(text: widget.existing?.name ?? '');
//   late final _dose = TextEditingController(text: widget.existing?.dose ?? '');
//   late TtcAuthor _whose = widget.existing?.author ?? TtcAuthor.me;
//   String? _problem;
//
//   @override
//   void dispose() {
//     _name.dispose();
//     _dose.dispose();
//     super.dispose();
//   }
//
//   void _save() {
//     final name = _name.text.trim();
//     if (name.isEmpty) {
//       setState(() => _problem = 'Add a name to save.');
//       return;
//     }
//     final store = TtcSupplementsStore.instance;
//     final e = widget.existing;
//     if (e == null) {
//       if (store.has(name, _whose)) {
//         setState(() => _problem = _whose == TtcAuthor.partner
//             ? "It's already on your partner's list."
//             : "It's already on your list.");
//         return;
//       }
//       store.add(name, dose: _dose.text, author: _whose);
//     } else if (!store.update(e.id, name: name, dose: _dose.text)) {
//       setState(() => _problem = 'Another one on this list has that name.');
//       return;
//     }
//     Navigator.of(context).pop();
//   }
//
//   Future<void> _remove() async {
//     final e = widget.existing!;
//     final nav = Navigator.of(context);
//     final ok = await ttcConfirmRemove(context,
//         title: 'Remove ${e.name}?',
//         body: 'The days you ticked it go too.');
//     if (!ok) return;
//     TtcSupplementsStore.instance.remove(e.id);
//     nav.pop();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final editing = widget.existing != null;
//     return Padding(
//       padding:
//           EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
//       child: Container(
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
//         ),
//         padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
//         child: SafeArea(
//           top: false,
//           child: SingleChildScrollView(
//             child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Center(
//                     child: Container(
//                       width: 40,
//                       height: 4,
//                       decoration: BoxDecoration(
//                           color: ttcLine,
//                           borderRadius: BorderRadius.circular(999)),
//                     ),
//                   ),
//                   const SizedBox(height: 18),
//                   Text(editing ? 'Change this supplement' : 'Add a supplement',
//                       style: ttcJakarta(17)),
//                   const SizedBox(height: 14),
//                   // Whose it is is fixed once it has history behind it, so
//                   // the choice only shows when adding.
//                   if (!editing) ...[
//                     _label('Whose is it'),
//                     Container(
//                       padding: const EdgeInsets.all(4),
//                       decoration: BoxDecoration(
//                           color: ttcPanel,
//                           borderRadius: BorderRadius.circular(999)),
//                       child: Row(children: [
//                         _seg('Yours', _whose == TtcAuthor.me,
//                             () => setState(() => _whose = TtcAuthor.me)),
//                         _seg("Your partner's", _whose == TtcAuthor.partner,
//                             () => setState(() => _whose = TtcAuthor.partner)),
//                       ]),
//                     ),
//                     const SizedBox(height: 12),
//                   ],
//                   _label('Name'),
//                   _field(_name, 'Vitamin D', autofocus: !editing),
//                   const SizedBox(height: 12),
//                   _label('Dose (optional)'),
//                   _field(_dose, 'What your doctor said, like 1000 IU daily'),
//                   const SizedBox(height: 18),
//                   GestureDetector(
//                     key: const ValueKey('ttc_supp_save'),
//                     onTap: _save,
//                     behavior: HitTestBehavior.opaque,
//                     child: Container(
//                       width: double.infinity,
//                       alignment: Alignment.center,
//                       padding: const EdgeInsets.symmetric(vertical: 15),
//                       decoration: BoxDecoration(
//                           color: ttcPurple,
//                           borderRadius: BorderRadius.circular(16)),
//                       child: Text('Save',
//                           style: ttcBody(14,
//                               color: Colors.white, w: FontWeight.w800)),
//                     ),
//                   ),
//                   if (_problem != null) TtcFormHint(text: _problem!),
//                   if (editing) ...[
//                     const SizedBox(height: 8),
//                     Center(
//                       child: GestureDetector(
//                         onTap: _remove,
//                         behavior: HitTestBehavior.opaque,
//                         child: Padding(
//                           padding: const EdgeInsets.all(8),
//                           child: Text('Remove from the list',
//                               style: ttcBody(12.5,
//                                   color: ttcMuted, w: FontWeight.w700)),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ]),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _label(String s) => Padding(
//         padding: const EdgeInsets.only(bottom: 6),
//         child: Text(s.toUpperCase(),
//             style: ttcBody(9.5, color: ttcMuted, w: FontWeight.w800)),
//       );
//
//   Widget _seg(String label, bool on, VoidCallback onTap) => Expanded(
//         child: GestureDetector(
//           onTap: onTap,
//           behavior: HitTestBehavior.opaque,
//           child: Container(
//             alignment: Alignment.center,
//             padding: const EdgeInsets.symmetric(vertical: 10),
//             decoration: BoxDecoration(
//               color: on ? Colors.white : Colors.transparent,
//               borderRadius: BorderRadius.circular(999),
//               boxShadow: on ? ttcCardShadow : null,
//             ),
//             child: Text(label,
//                 style: ttcBody(13,
//                     color: on ? ttcTitleInk : ttcSoft, w: FontWeight.w800)),
//           ),
//         ),
//       );
//
//   Widget _field(TextEditingController c, String hint,
//           {bool autofocus = false}) =>
//       TextField(
//         controller: c,
//         autofocus: autofocus,
//         onChanged: (_) {
//           if (_problem != null) setState(() => _problem = null);
//         },
//         style: ttcBody(14.5, color: ttcInk),
//         decoration: InputDecoration(
//           hintText: hint,
//           hintStyle: ttcBody(14, color: ttcMuted),
//           filled: true,
//           fillColor: ttcBg,
//           contentPadding: const EdgeInsets.all(14),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(16),
//             borderSide: const BorderSide(color: ttcBorder),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(16),
//             borderSide: const BorderSide(color: ttcBorder),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(16),
//             borderSide: const BorderSide(color: ttcPurple, width: 1.4),
//           ),
//         ),
//       );
// }
