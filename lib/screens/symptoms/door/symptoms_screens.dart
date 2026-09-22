// =============================================================================
//  Symptoms — the pushed screens: Your week, Send my week, Is this normal?
// -----------------------------------------------------------------------------
//  Each is `PvDoorToolScaffold` (the door's own tool frame) around a body the
//  door already draws inline, so a tile that opens one and the tab that
//  holds it show the same thing — the Nutrition rule.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/reads/symptom_reads.dart';
import '../../../data/symptoms/symptom_normal.dart';
import '../../../services/pregnancy_controller.dart';
import '../../../theme/pv_fonts.dart';
import '../../../widgets/pv_feedback.dart';
import '../../doors/pv_door_chrome.dart';
import '../../v2/v2_palette.dart';
import 'symptoms_today_body.dart' show symptomReader;
import 'symptoms_week_body.dart';

const String kSymptomsWeekRoute = 'symptoms/week';
const String kSymptomsSendRoute = 'symptoms/send';
const String kSymptomsNormalRoute = 'symptoms/urgent';

/// Your week, as its own page.
class SymptomsWeekScreen extends StatelessWidget {
  const SymptomsWeekScreen({super.key, required this.pregnancy});
  final PregnancyController pregnancy;

  @override
  Widget build(BuildContext context) => PvDoorToolScaffold(
        hue: 160,
        eyebrow: 'Symptoms · Your week',
        title: 'Your week',
        intro: 'Seven days of what you logged. Tap a row for what helps; send the week before a visit.',
        children: [
          SymptomsWeekBody(
            pregnancy: pregnancy,
            showHeading: false,
            onSend: () => Navigator.of(context).push(MaterialPageRoute<void>(
              settings: const RouteSettings(name: kSymptomsSendRoute),
              builder: (_) => SymptomsSendScreen(pregnancy: pregnancy),
            )),
          ),
        ],
      );
}

/// Send my week: the note as it will read, then Share or Copy. Flo's report
/// preview, as text rather than a PDF — a message is what reaches a doctor
/// in India; a PDF sits in Downloads.
class SymptomsSendScreen extends StatelessWidget {
  const SymptomsSendScreen({super.key, required this.pregnancy});
  final PregnancyController pregnancy;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final note = symptomWeekNote(pregnancy);
    return PvDoorToolScaffold(
      hue: 160,
      eyebrow: 'Symptoms · Send my week',
      title: 'Send my week',
      intro: 'This is the note, exactly as it will read. Share it to WhatsApp, or copy it into a message before your visit.',
      children: [
        pvDoorPad(Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
              color: p.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: p.line)),
          child: SelectableText(note, style: pvManrope(fontSize: 13.5, height: 1.6, color: p.ink1)),
        )),
        const SizedBox(height: 16),
        pvDoorPad(Row(children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: () {
                pvCommitFeedback();
                shareSymptomWeek(context, pregnancy);
              },
              icon: const Icon(Icons.ios_share_rounded, size: 18),
              label: const Text('Share'),
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                pvCommitFeedback();
                copySymptomWeek(context, pregnancy);
              },
              icon: const Icon(Icons.copy_rounded, size: 18),
              label: const Text('Copy'),
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            ),
          ),
        ])),
        const SizedBox(height: 10),
        pvDoorPad(Text(
            'Your observation, in your words. It goes only where you send it — nothing here is shared unless you share it.',
            style: pvManrope(fontSize: 11.5, height: 1.45, color: p.ink3))),
      ],
    );
  }
}

/// The ten, as the tab's own tool (self-padded: each row pads itself).
class SymptomsNormalBody extends StatelessWidget {
  const SymptomsNormalBody({super.key, required this.pregnancy});
  final PregnancyController pregnancy;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: V2PaletteStore.instance,
        builder: (context, _) {
          final p = V2PaletteStore.instance.current;
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            pvDoorPad(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Is this normal?',
                  style: pvFraunces(fontSize: 22, fontWeight: FontWeight.w600, height: 1.15, letterSpacing: -0.4, color: p.ink1)),
              const SizedBox(height: 4),
              Text('The ten questions, in your words, with the one answer that matters: rest, call today, or call now.',
                  style: pvManrope(fontSize: 13, height: 1.45, color: p.ink2)),
            ])),
            const SizedBox(height: 14),
            for (final q in kNormalQuestions)
              pvDoorPad(NormalRow(
                p: p,
                question: q,
                onOpen: () => Navigator.of(context).push(MaterialPageRoute<void>(
                  settings: RouteSettings(name: 'symptoms/normal/${q.id}'),
                  builder: (_) => symptomReader(pvReadFromNormal(q), pregnancy),
                )),
              )),
            pvDoorPad(Text(
                'The answers every antenatal service prints on its when-to-call card. Not a diagnosis; your own doctor\'s word wins.',
                style: pvManrope(fontSize: 11.5, height: 1.45, color: p.ink3))),
            const SizedBox(height: 8),
          ]);
        },
      );
}

/// Is this normal? — the ten, as rows wearing their verdict. A "now" row
/// carries the phone; every row opens its answer.
class SymptomsNormalScreen extends StatelessWidget {
  const SymptomsNormalScreen({super.key, required this.pregnancy});
  final PregnancyController pregnancy;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return PvDoorToolScaffold(
      hue: 344,
      eyebrow: 'Symptoms · Is this normal?',
      title: 'Is this normal?',
      intro: 'The ten questions, in your words, with the one answer that matters: rest, call today, or call now.',
      children: [
        for (final q in kNormalQuestions)
          pvDoorPad(NormalRow(
            p: p,
            question: q,
            onOpen: () => Navigator.of(context).push(MaterialPageRoute<void>(
              settings: RouteSettings(name: 'symptoms/normal/${q.id}'),
              builder: (_) => symptomReader(pvReadFromNormal(q), pregnancy),
            )),
          )),
        const SizedBox(height: 8),
        pvDoorPad(Text(
            'These are the answers every antenatal service prints on its when-to-call card. They are not a diagnosis, and your own doctor\'s word wins.',
            style: pvManrope(fontSize: 11.5, height: 1.45, color: p.ink3))),
      ],
    );
  }
}

/// One question: the verdict as a small pill in its tone, the question, the
/// short answer, and — for a "now" — a Call round that dials.
class NormalRow extends StatelessWidget {
  const NormalRow({super.key, required this.p, required this.question, required this.onOpen});
  final V2Palette p;
  final NormalQuestion question;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final q = question;
    final hue = switch (q.verdict) { NormalVerdict.usually => 160.0, NormalVerdict.today => 42.0, NormalVerdict.now => 344.0 };
    final tint = v2BlockTint(hue, p);
    final deep = HSLColor.fromColor(tint).withSaturation(0.5).withLightness(0.36).toColor();
    return InkWell(
      onTap: () {
        pvCommitFeedback();
        onOpen();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
        decoration: BoxDecoration(
            color: p.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: p.line)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.fromLTRB(8, 3, 8, 3),
                decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(999)),
                child: Text(q.verdict.word.toUpperCase(),
                    style: pvManrope(fontSize: 9.5, fontWeight: FontWeight.w800, letterSpacing: 1, color: deep)),
              ),
              const SizedBox(height: 6),
              Text(q.question, style: pvManrope(fontSize: 14.5, fontWeight: FontWeight.w800, height: 1.3, color: p.ink1)),
              const SizedBox(height: 3),
              Text(q.short, maxLines: 2, overflow: TextOverflow.ellipsis, style: pvManrope(fontSize: 12.5, height: 1.4, color: p.ink2)),
            ]),
          ),
          const SizedBox(width: 8),
          if (q.verdict == NormalVerdict.now)
            _CallRound(p: p, deep: deep, tint: tint)
          else
            Icon(Icons.chevron_right_rounded, size: 20, color: p.ink3),
        ]),
      ),
    );
  }
}

/// The phone. It opens the dialler with no number — hers is the hospital's,
/// and the app must never guess it. When a care-circle number exists it
/// goes here (STILL-OPEN §73.1).
class _CallRound extends StatelessWidget {
  const _CallRound({required this.p, required this.deep, required this.tint});
  final V2Palette p;
  final Color deep;
  final Color tint;

  @override
  Widget build(BuildContext context) => Material(
        color: deep,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () async {
            pvCommitFeedback();
            final uri = Uri(scheme: 'tel');
            if (await canLaunchUrl(uri)) await launchUrl(uri);
          },
          child: SizedBox(
            width: 44,
            height: 44,
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.call_rounded, size: 18, color: p.ground),
              Text('CALL', style: pvManrope(fontSize: 7.5, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: p.ground)),
            ]),
          ),
        ),
      );
}
