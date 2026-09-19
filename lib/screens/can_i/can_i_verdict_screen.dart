// =============================================================================
//  Is it safe? — the answer, as a verdict page
// -----------------------------------------------------------------------------
//  2026-09-19, the phone walk. The answer opened in the one reader for a few
//  hours and the user called it: "this is not an article … you don't have to
//  follow the same article format, and there is no need to even tag it as an
//  article when it's not." A lookup is a verdict with reasons, and it wears
//  a verdict's clothes. This is the ONE exception to the one-reader rule for
//  pregnancy writing, and it is an exception because the thing is not
//  writing: it is a card. Recorded in STILL-OPEN §68.10 and DESIGN-SYSTEM
//  §4.0 addendum 5.
//
//  The shape (Mobbin: Yuka's product page, State Farm's driving verdict,
//  Vivino's item page — logged in MOBBIN-DISCOVERY §11):
//
//    photo, edge to edge          the thing itself
//    name · the question          "Papaya · Can I eat it?"
//    THE VERDICT                  dot + word, Fraunces, with the short answer
//    for you · week N             her trimester's line, when there is one
//    why                          three lines, no jargon
//    instead, try                 the safe swaps as cut-outs
//    through the trimesters       T1 · T2 · T3 rows, hers marked
//    in an Indian kitchen         one row with the leaf
//    my doctor said               two pills; her doctor's line prints above
//    send · ask veda              two buttons, not two tiles
//    also asked                   cut-outs, never "ARTICLE" cards
//    the disclaimer line
//
//  No byline, no reading time, no contents, no references, no "was this
//  helpful". The reader's adapter (`pvReadFromCanI`) stays for anything that
//  wants the answer as a read (search, Saved); the screen it opens is this.
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/can_i_data.dart';
import '../../data/can_i_groups.dart';
import '../../data/reads/can_i_read.dart';
import '../../data/reads/read_images.dart';
import '../../models/can_i_entry.dart';
import '../../services/can_i_activity_store.dart';
import '../../services/can_i_store.dart';
import '../../services/pregnancy_controller.dart';
import '../../theme/pv_fonts.dart';
import '../../widgets/global_ask_fab.dart' show kAskVedaRoute;
import '../../widgets/pv_feedback.dart';
import '../doors/pv_door_chrome.dart';
import '../tools/ask_veda_screen.dart';
import '../v2/v2_palette.dart';
import 'can_i_answer.dart' show canIShareText, shareCanIAnswer;
import 'can_i_widgets.dart';

class CanIVerdictScreen extends StatelessWidget {
  const CanIVerdictScreen({super.key, required this.entry, required this.controller});
  final CanIEntry entry;
  final PregnancyController controller;

  @override
  Widget build(BuildContext context) {
    final e = entry;
    final week = controller.isDueDateSet ? controller.currentWeek : null;
    final tri = week == null ? null : canITrimester(week);
    final note = week == null ? null : canINoteForWeek(e, week);
    final swaps = canIInsteadOf(e);
    final swapIds = {for (final s in swaps) s.id};
    final also = [for (final id in e.related) if (!swapIds.contains(id)) ?canIById(id)];
    final url = canIImageFor(e.id);
    final credit = kReadImageCredits['$kCanIReadPrefix${e.id}'];

    return AnimatedBuilder(
      animation: Listenable.merge([V2PaletteStore.instance, CanIStore.instance, CanIActivityStore.instance]),
      builder: (context, _) {
        final p = V2PaletteStore.instance.current;
        final saved = CanIStore.instance.isSaved(e.id);
        return Scaffold(
          backgroundColor: p.ground,
          body: CustomScrollView(
            slivers: [
              // ---- THE PHOTO, THEN THE BAR -----------------------------------
              // Pinned: the photo at the top, and once it has scrolled away a
              // white bar with the name and a hairline — so back, save and
              // share never float over the text (the phone, 2026-09-19).
              SliverAppBar(
                pinned: true,
                expandedHeight: 300,
                backgroundColor: p.ground,
                surfaceTintColor: Colors.transparent,
                foregroundColor: p.ink1,
                elevation: 0,
                scrolledUnderElevation: 0,
                shape: Border(bottom: BorderSide(color: p.line)),
                leading: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: _round(p, Icons.arrow_back_rounded, () => Navigator.of(context).maybePop()),
                ),
                leadingWidth: 56,
                actions: [
                  _round(p, saved ? Icons.favorite_rounded : Icons.favorite_border_rounded, () {
                    pvCommitFeedback();
                    CanIStore.instance.toggleSaved(e.id);
                  }, tint: saved ? const Color(0xFFE0475F) : null),
                  const SizedBox(width: 8),
                  _round(p, Icons.ios_share_rounded, () {
                    pvCommitFeedback();
                    shareCanIAnswer(e, week: week);
                  }),
                  const SizedBox(width: 12),
                ],
                flexibleSpace: LayoutBuilder(builder: (context, c) {
                  final collapsed = c.maxHeight < 160;
                  return FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.only(left: 64, bottom: 16, right: 120),
                    centerTitle: false,
                    title: AnimatedOpacity(
                      duration: const Duration(milliseconds: 160),
                      opacity: collapsed ? 1 : 0,
                      child: Text(e.name.now,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: pvFraunces(fontSize: 18, fontWeight: FontWeight.w600, color: p.ink1)),
                    ),
                    background: Stack(fit: StackFit.expand, children: [
                      if (url != null) CanIPhoto(url: url, fallback: _well(p)) else _well(p),
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 0,
                        height: 120,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.black.withValues(alpha: 0.28), Colors.black.withValues(alpha: 0)],
                            ),
                          ),
                        ),
                      ),
                    ]),
                  );
                }),
              ),
              SliverList.list(children: [
                if (credit != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
                    child: Text('Photo · $credit',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: pvManrope(fontSize: 10.5, color: p.ink3)),
                  ),

                // ---- NAME, QUESTION, THE VERDICT -------------------------
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(e.name.now,
                        style: pvFraunces(
                            fontSize: 30, fontWeight: FontWeight.w600, height: 1.1, letterSpacing: -0.7, color: p.ink1)),
                    const SizedBox(height: 4),
                    Text(canIQuestion(e.category), style: pvManrope(fontSize: 14, color: p.ink2)),
                    const SizedBox(height: 18),
                    Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                      CanIVerdictDot(verdict: e.verdict, p: p, size: 14),
                      const SizedBox(width: 10),
                      Text(canIVerdictWord(e.verdict),
                          style: pvFraunces(
                              fontSize: 26, fontWeight: FontWeight.w600, height: 1.1, letterSpacing: -0.5, color: p.ink1)),
                    ]),
                    const SizedBox(height: 10),
                    Text(e.short.now, style: pvManrope(fontSize: 16, height: 1.5, color: p.ink1)),
                    if (note != null) ...[
                      const SizedBox(height: 16),
                      _forYou(p, week!, note.now),
                    ],
                  ]),
                ),

                const SizedBox(height: 26),
                _rule(p),

                // ---- WHY ---------------------------------------------------
                _section(p, 'Why', child: Text(e.why.now, style: pvManrope(fontSize: 15, height: 1.55, color: p.ink1))),

                // ---- INSTEAD, TRY ------------------------------------------
                if (swaps.isNotEmpty) ...[
                  _rule(p),
                  _section(
                    p,
                    'Instead, try',
                    sub: e.verdict == CanIVerdict.avoid
                        ? 'What you can reach for in its place.'
                        : 'If you would rather not think about the limit.',
                    flush: true,
                    child: _rail(context, swaps, p),
                  ),
                ],

                // ---- THROUGH THE TRIMESTERS ------------------------------
                // Her trimester's line is already the "For you" block above,
                // so the list holds the OTHER trimesters — the same sentence
                // twice on one screen was the phone's first finding.
                if ([for (final (t, n) in [(1, e.t1), (2, e.t2), (3, e.t3)]) if (n != null && !(note != null && t == tri)) t]
                    case final others when others.isNotEmpty) ...[
                  _rule(p),
                  _section(
                    p,
                    note != null ? 'Earlier and later in pregnancy' : 'Through the trimesters',
                    child: Column(children: [
                      for (final (t, n) in [(1, e.t1), (2, e.t2), (3, e.t3)])
                        if (n != null && others.contains(t)) _triRow(p, t, n.now, mine: t == tri),
                    ]),
                  ),
                ],

                // ---- IN AN INDIAN KITCHEN ----------------------------------
                if (e.indian case final ind?) ...[
                  _rule(p),
                  _section(
                    p,
                    'In an Indian kitchen',
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Icon(Icons.eco_outlined, size: 18, color: p.ink2),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(ind.now, style: pvManrope(fontSize: 15, height: 1.55, color: p.ink1))),
                    ]),
                  ),
                ],

                // ---- MY DOCTOR SAID ------------------------------------------
                _rule(p),
                _section(
                  p,
                  'My doctor said',
                  sub: 'Your doctor knows your pregnancy; this page does not. Record their call and it sits above ours.',
                  child: _doctor(p, e),
                ),

                // ---- SEND · ASK VEDA ---------------------------------------------
                _rule(p),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Row(children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          pvCommitFeedback();
                          shareCanIAnswer(e, week: week);
                        },
                        icon: const Icon(Icons.ios_share_rounded, size: 18),
                        label: const Text('Send'),
                        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          pvCommitFeedback();
                          Navigator.of(context).push(MaterialPageRoute<void>(
                            settings: const RouteSettings(name: kAskVedaRoute),
                            builder: (_) => AskVedaScreen(
                                controller: controller, initialQuery: 'Is ${e.name.en} safe in pregnancy?'),
                          ));
                        },
                        icon: const Icon(Icons.auto_awesome_outlined, size: 18),
                        label: const Text('Ask Veda'),
                        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                      ),
                    ),
                  ]),
                ),

                // ---- ALSO ASKED ---------------------------------------------------
                if (also.isNotEmpty) ...[
                  const SizedBox(height: 26),
                  _rule(p),
                  _section(p, 'Also asked', flush: true, child: _rail(context, also, p)),
                ],

                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: PvDoorDisclaimer(
                      p: p,
                      text: e.verdict == CanIVerdict.askDoctor
                          ? 'This one is your doctor\'s call: the right answer depends on your history and your dose.'
                          : 'General guidance for a healthy pregnancy, not a prescription. If your doctor has said otherwise, they are right.'),
                ),
                const SizedBox(height: 28),
              ]),
            ],
          ),
        );
      },
    );
  }

  // ---- pieces -----------------------------------------------------------------

  Widget _well(V2Palette p) => ColoredBox(
        color: p.surfaceAlt,
        child: Center(child: Icon(canICategoryIcon(entry.category), size: 56, color: p.ink3)),
      );

  Widget _round(V2Palette p, IconData icon, VoidCallback onTap, {Color? tint}) => Material(
        color: Colors.white.withValues(alpha: 0.82),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(width: 40, height: 40, child: Icon(icon, size: 20, color: tint ?? p.ink1)),
        ),
      );

  Widget _rule(V2Palette p) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(height: 1, color: p.line),
      );

  Widget _section(V2Palette p, String title, {String? sub, required Widget child, bool flush = false}) => Padding(
        padding: EdgeInsets.fromLTRB(flush ? 0 : 20, 22, flush ? 0 : 20, 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: flush ? 20 : 0),
            child: canIHeading(p, title, sub: sub),
          ),
          const SizedBox(height: 14),
          child,
        ]),
      );

  /// "For you · week N" — the trimester line, marked as hers.
  Widget _forYou(V2Palette p, int week, String text) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 3, height: 44, margin: const EdgeInsets.only(top: 2), color: p.ink1),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('FOR YOU · WEEK $week',
                style: pvManrope(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.3, color: p.ink3)),
            const SizedBox(height: 4),
            Text(text, style: pvManrope(fontSize: 15, height: 1.5, color: p.ink1)),
          ]),
        ),
      ]);

  Widget _triRow(V2Palette p, int t, String text, {required bool mine}) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 34,
            padding: const EdgeInsets.symmetric(vertical: 3),
            decoration: BoxDecoration(
              color: mine ? p.ink1 : p.surface,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: mine ? p.ink1 : p.line),
            ),
            child: Text('T$t',
                textAlign: TextAlign.center,
                style: pvManrope(fontSize: 11, fontWeight: FontWeight.w800, color: mine ? p.ground : p.ink2)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: pvManrope(fontSize: 14.5, height: 1.5, color: mine ? p.ink1 : p.ink2))),
        ]),
      );

  Widget _rail(BuildContext context, List<CanIEntry> items, V2Palette p) => SizedBox(
        height: 156,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(width: 10),
          itemBuilder: (_, i) => SizedBox(
            width: 112,
            child: CanICutoutTile(
              entry: items[i],
              p: p,
              onTap: () {
                CanIActivityStore.instance.touch(items[i].id);
                Navigator.of(context).push(MaterialPageRoute<void>(
                  settings: const RouteSettings(name: 'can_i/answer'),
                  builder: (_) => CanIVerdictScreen(entry: items[i], controller: controller),
                ));
              },
            ),
          ),
        ),
      );

  Widget _doctor(V2Palette p, CanIEntry e) {
    final said = CanIActivityStore.instance.doctorSaid(e.id);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (said != null) ...[
        Row(children: [
          Icon(Icons.verified_outlined, size: 18, color: p.ink1),
          const SizedBox(width: 8),
          Expanded(
            child: Text(said == CanIDoctorSaid.ok ? 'Your doctor · OK for you' : 'Your doctor · avoid for now',
                style: pvManrope(fontSize: 14.5, fontWeight: FontWeight.w700, color: p.ink1)),
          ),
        ]),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 26),
          child: Text('ParentVeda · ${canIVerdictWord(e.verdict).toLowerCase()} (general note)',
              style: pvManrope(fontSize: 12.5, color: p.ink3)),
        ),
        const SizedBox(height: 12),
      ],
      Wrap(spacing: 8, runSpacing: 8, children: [
        CanIChip(
            label: 'OK for me',
            p: p,
            selected: said == CanIDoctorSaid.ok,
            onTap: () => CanIActivityStore.instance
                .setDoctorSaid(e.id, said == CanIDoctorSaid.ok ? null : CanIDoctorSaid.ok)),
        CanIChip(
            label: 'Avoid for me',
            p: p,
            selected: said == CanIDoctorSaid.avoid,
            onTap: () => CanIActivityStore.instance
                .setDoctorSaid(e.id, said == CanIDoctorSaid.avoid ? null : CanIDoctorSaid.avoid)),
      ]),
    ]);
  }
}

/// The share text, re-exported so the door does not import the reader file
/// for it. (`canIShareText` lives in can_i_answer.dart.)
String canIVerdictShareText(CanIEntry e, {int? week}) => canIShareText(e, week: week);
