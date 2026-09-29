// =============================================================================
//  Is it safe? — the answer, in the one reader
// -----------------------------------------------------------------------------
//  2026-09-19. `openCanIAnswer` is the only way an entry opens — from the
//  door, a group, a search hit, a scan, the Saved screen, a swap on another
//  answer. It records the visit (recents), builds the read
//  (`pvReadFromCanI`) for HER week, and pushes `PvReaderScreen` with the
//  three custom blocks this stage owns. Route name `can_i/answer`, so the
//  Ask Veda button knows where it is.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/can_i_data.dart';
import '../../data/can_i_groups.dart';
import '../../data/reads/can_i_read.dart';
import '../../models/can_i_entry.dart';
import '../../services/can_i_activity_store.dart';
import '../../services/pregnancy_controller.dart';
import '../../theme/pv_fonts.dart';
import '../../widgets/global_ask_fab.dart' show kAskVedaRoute;
import '../../widgets/pv_feedback.dart';
import '../tools/ask_veda_screen.dart';
import '../reader/pv_reader_screen.dart';
import '../v2/v2_palette.dart';
import 'can_i_verdict_screen.dart';
import 'can_i_widgets.dart';

const String kCanIAnswerRoute = 'can_i/answer';

/// Which screen an answer opens. TRUE (2026-09-19, the phone walk) = the
/// verdict page (`CanIVerdictScreen`) — the user: "this is not an article".
/// FALSE = the reader with the three custom blocks (`CanIAnswerReader`),
/// kept for revert and for the reader-shaped seams (Saved, search).
const bool kCanIAnswerAsVerdict = true;

void openCanIAnswer(BuildContext context, CanIEntry entry, PregnancyController c) {
  CanIActivityStore.instance.touch(entry.id);
  Navigator.of(context).push(MaterialPageRoute<void>(
    settings: const RouteSettings(name: kCanIAnswerRoute),
    builder: (_) => kCanIAnswerAsVerdict
        ? CanIVerdictScreen(entry: entry, controller: c)
        : CanIAnswerReader(entry: entry, controller: c),
  ));
}

class CanIAnswerReader extends StatelessWidget {
  const CanIAnswerReader({super.key, required this.entry, required this.controller});
  final CanIEntry entry;
  final PregnancyController controller;

  @override
  Widget build(BuildContext context) {
    final lang = controller.language;
    // Her week, when the stage knows it. `isDueDateSet` false means the
    // controller is on its no-date default (week 20 advancing daily) and a
    // trimester line would be a guess dressed as personal — so none.
    final week = controller.isDueDateSet ? controller.currentWeek : null;
    final read = pvReadFromCanI(entry, week: week);
    return PvReaderScreen(
      read: read,
      lang: lang,
      customBlock: (context, block) => switch (block) {
        PvCanIVerdictBlock b => _VerdictView(block: b),
        PvCanIInsteadBlock b => _InsteadView(block: b, controller: controller),
        PvCanIDoctorBlock b => _DoctorView(block: b),
        _ => const SizedBox.shrink(),
      },
      resolveRead: (id) {
        if (!id.startsWith(kCanIReadPrefix)) return null;
        final e = canIById(id.substring(kCanIReadPrefix.length));
        return e == null ? null : pvReadFromCanI(e, week: week);
      },
      openRead: (context, id) {
        final e = canIById(id.substring(kCanIReadPrefix.length));
        if (e != null) openCanIAnswer(context, e, controller);
      },
      openAction: (context, action) => switch (action) {
        'cani_share' => shareCanIAnswer(entry, week: week),
        'cani_askveda' => Navigator.of(context).push(MaterialPageRoute<void>(
            settings: const RouteSettings(name: kAskVedaRoute),
            builder: (_) => AskVedaScreen(
                controller: controller, initialQuery: 'Is ${entry.name.en} safe in pregnancy?'),
          )),
        _ => null,
      },
    );
  }
}

/// The answer as a message. The verdict, the short answer, her-week note,
/// and where it came from — what a partner needs at the shop, no more.
String canIShareText(CanIEntry e, {int? week}) {
  final note = week == null ? null : canINoteForWeek(e, week);
  final b = StringBuffer()
    ..writeln('${e.name.en} in pregnancy: ${canIVerdictWord(e.verdict)}')
    ..writeln()
    ..writeln(e.short.en);
  if (note != null) {
    b
      ..writeln()
      ..writeln('At week $week: ${note.en}');
  }
  b
    ..writeln()
    ..write('ParentVeda · Is it safe? General guidance, not a prescription.');
  return b.toString();
}

Future<void> shareCanIAnswer(CanIEntry e, {int? week}) =>
    Share.share(canIShareText(e, week: week));

// -----------------------------------------------------------------------------
//  The blocks — NO HORIZONTAL PADDING OF THEIR OWN: the reader wraps every
//  custom block in its page gutter already, and a second gutter here put
//  these three a step deeper than the reader's headings (the phone,
//  2026-09-19).
// -----------------------------------------------------------------------------

/// The verdict word, then the line for her trimester. The one place the
/// dot is bigger than 7pt: this is the answer, and it is allowed to be seen.
class _VerdictView extends StatelessWidget {
  const _VerdictView({required this.block});
  final PvCanIVerdictBlock block;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final e = block.entry;
    final note = block.noteForHer;
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CanIVerdictDot(verdict: e.verdict, p: p, size: 12),
          const SizedBox(width: 10),
          Text(canIVerdictWord(e.verdict),
              style: pvFraunces(
                  fontSize: 26, fontWeight: FontWeight.w600, height: 1.1, letterSpacing: -0.5, color: p.ink1)),
        ]),
        if (note != null) ...[
          const SizedBox(height: 12),
          Text('FOR YOU · WEEK ${block.week}',
              style: pvManrope(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.3, color: p.ink3)),
          const SizedBox(height: 5),
          Text(note.now, style: pvManrope(fontSize: 15, height: 1.55, color: p.ink1)),
        ],
        const SizedBox(height: 8),
        Container(height: 1, color: p.line),
      ]),
    );
  }
}

/// "Instead, try" — a rail of safe swaps as cut-out tiles.
class _InsteadView extends StatelessWidget {
  const _InsteadView({required this.block, required this.controller});
  final PvCanIInsteadBlock block;
  final PregnancyController controller;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 6, 0, 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: EdgeInsets.zero,
          child: canIHeading(p, 'Instead, try',
              sub: block.entry.verdict == CanIVerdict.avoid
                  ? 'What you can reach for in its place.'
                  : "If you'd rather not count the limit."),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 156,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: block.swaps.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, i) => SizedBox(
              width: 112,
              child: CanICutoutTile(
                  entry: block.swaps[i],
                  p: p,
                  onTap: () => openCanIAnswer(context, block.swaps[i], controller)),
            ),
          ),
        ),
      ]),
    );
  }
}

/// "My doctor said" — two pills and the recorded line. Her doctor's word
/// prints above ours the moment she records it.
class _DoctorView extends StatelessWidget {
  const _DoctorView({required this.block});
  final PvCanIDoctorBlock block;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final e = block.entry;
    return ListenableBuilder(
      listenable: CanIActivityStore.instance,
      builder: (context, _) {
        final said = CanIActivityStore.instance.doctorSaid(e.id);
        return Padding(
          padding: const EdgeInsets.fromLTRB(0, 6, 0, 10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            canIHeading(p, 'My doctor said',
                sub: "Your doctor knows your pregnancy and this page doesn't. "
                    'Record their call and it shows above ours here.'),
            const SizedBox(height: 12),
            if (said != null) ...[
              Row(children: [
                Icon(Icons.verified_outlined, size: 18, color: p.ink1),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                      said == CanIDoctorSaid.ok
                          ? 'Your doctor · OK for you'
                          : 'Your doctor · avoid for now',
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
          ]),
        );
      },
    );
  }
}

/// Kept so a screen that only has the id can still open the answer.
void openCanIAnswerById(BuildContext context, String id, PregnancyController c) {
  final e = canIById(id);
  if (e == null) return;
  pvCommitFeedback();
  openCanIAnswer(context, e, c);
}
