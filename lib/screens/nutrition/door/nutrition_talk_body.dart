// =============================================================================
//  Nutrition — Talk: the dietician, in the base UI
// -----------------------------------------------------------------------------
//  2026-09-20, the consistency pass. The Talk tab used to render
//  `ExpertOptionsBlock`: a violet card with four "Request this" buttons whose
//  only effect was a snackbar ("our team will reach out") — a button that
//  confirmed nothing. That block stays in nutrition_stage_screen.dart for
//  revert; this is its replacement, and it is honest:
//
//    the nutritionist herself — the same profile card Scans' doctor page
//    uses (name, role, credential, price, "Book a 1:1"), opening the same
//    profile and the same booking sheet as every consult in the app;
//    the four things she can do, as plain rows under it, each opening the
//    same profile — because that IS how you get any of them.
//
//  A body, no Scaffold, in the door's gutters (`pvDoorInlineToolFor`).
// =============================================================================

import 'package:flutter/material.dart';

import '../../../data/prepare_data.dart';
import '../../../services/pregnancy_controller.dart';
import '../../../theme/pv_fonts.dart';
import '../../../widgets/pv_feedback.dart';
import '../../doors/pv_door_chrome.dart';
import '../../../experts/expert.dart';
import '../../../services/expert_store.dart' show mergedExperts;
import '../../post_pregnancy/pp_expert_link.dart' show openExpertProfile;
import '../../post_pregnancy/pp_experts_data.dart' show expertByName;
import '../../prepare/consultations_screen.dart';
import '../../v2/v2_palette.dart';
import '../../brackets/hub/hub_intent_art.dart';
import 'nutrition_widgets.dart';

const String kNutritionConsultRole = 'sp_nutrition';

// Drawn marks since 2026-09-21 (were description / videocam / monitor_heart
// / help_outline line icons).
const List<(IntentMark, String, String)> _kWhatSheDoes = [
  (IntentMark.pageMark, 'A personal diet plan', 'Built around your own reports and routine, not a generic chart.'),
  (IntentMark.calendarDay, 'Weekly check-ins', 'Steady calls as your needs change through pregnancy.'),
  (IntentMark.chartLog, 'Day-to-day management', 'Hands-on help if a condition needs close watching.'),
  (IntentMark.questionMark, 'One session, your questions', 'A single consult to get specific answers.'),
];

class NutritionTalkBody extends StatelessWidget {
  const NutritionTalkBody({super.key, required this.pregnancy});
  final PregnancyController pregnancy;

  void _open(BuildContext context) {
    pvCommitFeedback();
    final sp = kSpecialists.where((s) => s.id == kNutritionConsultRole).firstOrNull;
    final e = sp == null ? null : expertByName(sp.name.en);
    if (e != null) {
      openExpertProfile(context, e);
      return;
    }
    Navigator.of(context).push(MaterialPageRoute<void>(
      settings: const RouteSettings(name: 'consults'),
      builder: (_) => ConsultationsScreen(lang: pregnancy.language, onlyRole: kNutritionConsultRole),
    ));
  }

  /// Every nutritionist on the panel, the named prenatal one first. Reads
  /// `mergedExperts()` — the live catalogue over the bundled floor — because
  /// that is the rule every consulting surface follows (expert_store.dart),
  /// and this tab did not: it read the older one-per-role `kSpecialists`
  /// seed and so showed one woman (the user, 2026-09-20: "we are only
  /// promoting a single person — any reason?"). No reason; a seam.
  static List<Expert> panel() {
    final sp = kSpecialists.where((s) => s.id == kNutritionConsultRole).firstOrNull;
    final lead = sp == null ? null : expertByName(sp.name.en);
    final all = mergedExperts();
    final rest = [
      for (final e in all)
        if (e.id != lead?.id && _isNutrition(e)) e
    ];
    rest.sort((a, b) {
      if (a.topPick != b.topPick) return a.topPick ? -1 : 1;
      if (a.seeded != b.seeded) return a.seeded ? 1 : -1;
      return b.ratingValue.compareTo(a.ratingValue);
    });
    return [if (lead != null) lead, ...rest];
  }

  static bool _isNutrition(Expert e) {
    final c = e.category.toLowerCase();
    final cred = e.credential.toLowerCase();
    return c.contains('nutrition') ||
        c.contains('diet') ||
        cred.contains('nutrition') ||
        cred.contains('dietitian') ||
        cred.contains('dietician');
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: V2PaletteStore.instance,
        builder: (context, _) {
          final p = V2PaletteStore.instance.current;
          final sp = kSpecialists.where((s) => s.id == kNutritionConsultRole).firstOrNull;
          final others = panel().skip(1).toList();
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            pvDoorPad(nutritionHeading(p, 'Want a real person on this?',
                sub: 'Everything else on this door is free. This is the one part that is not.')),
            const SizedBox(height: 14),
            if (sp != null)
              pvDoorPad(PvDoorCard(
                p: p,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                      width: 46,
                      height: 46,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: p.line)),
                      child: Text(sp.name.en.split(' ').map((w) => w.isEmpty ? '' : w[0]).take(2).join(),
                          style: pvFraunces(fontSize: 16, fontWeight: FontWeight.w600, color: p.ink1)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(sp.name.en, style: pvFraunces(fontSize: 18, fontWeight: FontWeight.w600, color: p.ink1)),
                        const SizedBox(height: 2),
                        Text('${sp.role.en}  ·  ${sp.cred.en}', style: pvManrope(fontSize: 12.5, color: p.ink2)),
                        const SizedBox(height: 6),
                        Row(children: [
                          for (var i = 0; i < 5; i++) Icon(Icons.star_rounded, size: 14, color: p.ink1),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text('${sp.consultPrice} · 30 min video',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: pvManrope(fontSize: 12.5, fontWeight: FontWeight.w700, color: p.ink2)),
                          ),
                        ]),
                      ]),
                    ),
                  ]),
                  const SizedBox(height: 14),
                  FilledButton(
                    onPressed: () => _open(context),
                    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(46)),
                    child: Text('Book a 1:1  ·  ${sp.consultPrice}'),
                  ),
                ]),
              )),
            if (others.isNotEmpty) ...[
              const SizedBox(height: 22),
              pvDoorPad(nutritionHeading(p, 'Also on the panel',
                  sub: 'Dieticians who take a 1:1. Tap one to see her profile and book.')),
              const SizedBox(height: 4),
              pvDoorPad(Column(children: [
                for (var i = 0; i < others.length; i++)
                  InkWell(
                    onTap: () {
                      pvCommitFeedback();
                      openExpertProfile(context, others[i]);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                          border: i == others.length - 1 ? null : Border(bottom: BorderSide(color: p.line))),
                      child: Row(children: [
                        Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: p.line)),
                          child: Text(others[i].name.split(' ').map((w) => w.isEmpty ? '' : w[0]).take(2).join(),
                              style: pvFraunces(fontSize: 14, fontWeight: FontWeight.w600, color: p.ink1)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(others[i].name,
                                style: pvManrope(fontSize: 14.5, fontWeight: FontWeight.w700, color: p.ink1)),
                            const SizedBox(height: 2),
                            Text(others[i].credential,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: pvManrope(fontSize: 12.5, height: 1.4, color: p.ink2)),
                          ]),
                        ),
                        const SizedBox(width: 8),
                        Text(others[i].ctaPrice,
                            style: pvManrope(fontSize: 12.5, fontWeight: FontWeight.w700, color: p.ink2)),
                        Icon(Icons.chevron_right_rounded, size: 20, color: p.ink3),
                      ]),
                    ),
                  ),
              ])),
            ],
            const SizedBox(height: 22),
            pvDoorPad(nutritionHeading(p, 'What they can do for you')),
            const SizedBox(height: 4),
            pvDoorPad(Column(children: [
              for (var i = 0; i < _kWhatSheDoes.length; i++)
                InkWell(
                  onTap: () => _open(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                        border: i == _kWhatSheDoes.length - 1 ? null : Border(bottom: BorderSide(color: p.line))),
                    child: Row(children: [
                      // Four rows, four hues — not the door's green four
                      // times (the user, 2026-09-22: "you don't have to
                      // throw green at everyone").
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            color: v2BlockTint(const [206.0, 26.0, 344.0, 268.0][i % 4], p),
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.all(8),
                        child: HubIntentArt(mark: _kWhatSheDoes[i].$1, tint: v2BlockTint(const [206.0, 26.0, 344.0, 268.0][i % 4], p)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(_kWhatSheDoes[i].$2, style: pvManrope(fontSize: 14.5, fontWeight: FontWeight.w700, color: p.ink1)),
                          const SizedBox(height: 2),
                          Text(_kWhatSheDoes[i].$3, style: pvManrope(fontSize: 12.5, height: 1.4, color: p.ink2)),
                        ]),
                      ),
                      Icon(Icons.chevron_right_rounded, size: 20, color: p.ink3),
                    ]),
                  ),
                ),
            ])),
            const SizedBox(height: 8),
          ]);
        },
      );
}
