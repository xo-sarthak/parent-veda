// =============================================================================
//  ScanScheduleScreen — "What's coming"
// -----------------------------------------------------------------------------
//  The workbook's Tools cell, half of it: "scan/test schedule tracker".
//
//  Nine scans in week order, each with its window, whether it is done, and
//  **what it costs**. The cost column is the reason this screen exists rather
//  than being a filter on the library — it is the question nobody in this market
//  answers, and a schedule without it is just a list of names she already knows.
//
//  `prepareMode` re-frames the same list as "pick the one you are getting
//  ready for". Same data, same rows, different question at the top — a second
//  screen would have been two things to maintain that differ by one sentence.
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/scan_extras.dart';
import '../../data/tests_scans_reports_data.dart';
import '../../localization/app_language.dart';
import '../../services/pregnancy_controller.dart';
import '../../services/scans_store.dart';
import '../../theme/pv_fonts.dart';
import '../v2/v2_palette.dart';
import 'scan_detail_screen.dart';

/// The nine, in the order they happen. Ids match `kTestsScans`.
///
/// ⚠️ HAND-ORDERED RATHER THAN SORTED BY `TrimesterTag`, because the tag is
/// only trimester-grained and three of these share a trimester. The clinical
/// order is a fact about pregnancy, not something to derive.
const List<(String, String, String)> _kOrder = [
  ('blood_tests', 'Week 6–10', 'हफ़्ता 6–10'),
  ('dating_scan', 'Week 6–9', 'हफ़्ता 6–9'),
  ('nt_scan', 'Week 11–13', 'हफ़्ता 11–13'),
  ('nipt', 'Week 10+', 'हफ़्ता 10+'),
  ('anomaly_scan', 'Week 18–22', 'हफ़्ता 18–22'),
  ('ogtt', 'Week 24–28', 'हफ़्ता 24–28'),
  ('growth_scan', 'Week 28–36', 'हफ़्ता 28–36'),
  ('doppler', 'Week 30+', 'हफ़्ता 30+'),
  ('gbs', 'Week 35–37', 'हफ़्ता 35–37'),
];

class ScanScheduleScreen extends StatelessWidget {
  const ScanScheduleScreen(
      {super.key, required this.pregnancy, this.prepareMode = false});

  /// ⚠️ PASSED IN, NOT READ FROM A SINGLETON. `PregnancyController` has no
  /// `instance` — it is constructed once and handed down, which is deliberate:
  /// a screen that reaches for a global to answer one question is a screen that
  /// will reach for two more later.
  final PregnancyController pregnancy;

  /// Same list, different question at the top.
  final bool prepareMode;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final lang = S.current;

    return AnimatedBuilder(
      animation: ScansStore.instance,
      builder: (context, _) {
        final store = ScansStore.instance;
        return Scaffold(
          backgroundColor: p.ground,
          appBar: AppBar(
            backgroundColor: p.ground,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            foregroundColor: p.ink1,
            title: Text(
                (prepareMode
                        ? const LocalizedText(
                            en: 'Which one are you getting ready for?',
                            hi: 'किसकी तैयारी कर रही हैं?')
                        : const LocalizedText(
                            en: "What's coming", hi: 'आगे क्या है'))
                    .of(lang),
                style: pvJakarta(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: p.ink1)),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(18, 6, 18, 40),
            children: [
              Text(
                  const LocalizedText(
                          en: 'Prices are what these usually cost at private '
                              'labs and hospitals in India — a range, not a '
                              'quote. Government hospitals charge far less or '
                              'nothing.',
                          hi: 'ये दाम भारत में private labs और अस्पतालों के आम '
                              'दाम हैं — एक अनुमान, कोई quote नहीं। सरकारी '
                              'अस्पतालों में बहुत कम लगते हैं या कुछ नहीं।')
                      .of(lang),
                  style:
                      pvManrope(fontSize: 12.5, height: 1.5, color: p.ink3)),
              const SizedBox(height: 18),
              Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: p.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: p.line),
                ),
                child: Column(children: [
                  for (final (id, weekEn, weekHi) in _kOrder) ...[
                    _Row(
                      scan: _byId(id),
                      week: lang.isEnglish ? weekEn : weekHi,
                      done: store.isCompleted(id),
                      p: p,
                      lang: lang,
                      pregnancy: pregnancy,
                    ),
                    if (id != _kOrder.last.$1)
                      Divider(
                          height: 1,
                          thickness: 1,
                          color: p.line,
                          indent: 16),
                  ],
                ]),
              ),
            ],
          ),
        );
      },
    );
  }
}

TestScanInfo? _byId(String id) {
  for (final s in kTestsScans) {
    if (s.id == id) return s;
  }
  return null;
}

class _Row extends StatelessWidget {
  const _Row(
      {required this.scan,
      required this.week,
      required this.done,
      required this.p,
      required this.lang,
      required this.pregnancy});

  final TestScanInfo? scan;
  final String week;
  final bool done;
  final V2Palette p;
  final AppLanguage lang;
  final PregnancyController pregnancy;

  @override
  Widget build(BuildContext context) {
    if (scan == null) return const SizedBox.shrink();
    final s = scan!;
    final cost = kScanCost[s.id];

    return InkWell(
      onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
        settings: const RouteSettings(name: 'scans/detail'),
        builder: (_) =>
            ScanDetailScreen(scan: s, pregnancy: pregnancy),
      )),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Done is a quiet tick, not a celebration. A schedule of scans is
          // not a checklist to complete — several of these are optional and
          // one of them she may deliberately skip.
          Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            margin: const EdgeInsets.only(top: 2, right: 12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: done ? p.action.withValues(alpha: 0.14) : null,
              border: done
                  ? null
                  : Border.all(color: p.ink3.withValues(alpha: 0.42)),
            ),
            child: done
                ? Icon(Icons.check_rounded, size: 13, color: p.action)
                : null,
          ),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.name.of(lang),
                      style: pvJakarta(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: p.ink1)),
                  const SizedBox(height: 3),
                  Text(
                      cost == null
                          ? week
                          : '$week  ·  ₹${cost.low} – ₹${cost.high}',
                      style: pvManrope(fontSize: 12.5, color: p.ink2)),
                ]),
          ),
          Icon(Icons.chevron_right_rounded, size: 19, color: p.ink3),
        ]),
      ),
    );
  }
}
