// =============================================================================
//  HubOwedScreen — where a door goes when what it promises is not built yet
// -----------------------------------------------------------------------------
//  Some doors in the forty hubs are real user intents with nothing behind them
//  yet — a potty-training plan, a school-readiness guide, a PCOS explainer. The
//  door audit says those intents are genuine, and the inventory says the
//  content is `notReady`. Both are true at once.
//
//  ---------------------------------------------------------------------------
//  ⚠️ THE THREE WRONG ANSWERS, AND WHY THIS IS THE FOURTH
//  ---------------------------------------------------------------------------
//   1. **Hide the door.** Breaks the rule that a feature is never hidden — and
//      she then cannot tell whether we have thought about her problem at all.
//   2. **Open nothing.** A tap that does nothing teaches her that taps do
//      nothing, and she stops trying them everywhere else in the app.
//   3. **Open the nearest vaguely-related screen.** The worst of the three: it
//      looks like an answer, wastes her time, and she blames herself for not
//      finding what she wanted.
//
//  So: a real screen that says plainly what will be here, what it will do for
//  her, and — where one exists — the nearest thing that genuinely helps today.
//  ⚠️ The "meanwhile" link is OPTIONAL and must be omitted rather than
//  stretched. "Here is something else" is only kind when it is actually close.
//
//  ⚠️ ENGLISH ONLY FOR NOW.
// =============================================================================

import 'package:flutter/material.dart';

import '../../../localization/app_language.dart';
import '../../../theme/pv_fonts.dart';
import '../../v2/v2_palette.dart';
import 'hub_solution_cards.dart';

LocalizedText _en(String s) => LocalizedText(en: s, hi: s);

class HubOwedScreen extends StatelessWidget {
  const HubOwedScreen({
    super.key,
    required this.title,
    required this.willHold,
    this.meanwhileLabel,
    this.meanwhileValue,
    this.onMeanwhile,
  });

  /// The door's own words, so she lands on what she tapped.
  final String title;

  /// ⚠️ REQUIRED, and it must state the VALUE rather than the format. "What to
  /// expect week by week, and what to do when it goes wrong" — never "content
  /// coming soon".
  final String willHold;

  final String? meanwhileLabel;
  final String? meanwhileValue;
  final VoidCallback? onMeanwhile;

  @override
  Widget build(BuildContext context) {
    final lang = S.current;

    return AnimatedBuilder(
      animation: V2PaletteStore.instance,
      builder: (context, _) {
        final p = V2PaletteStore.instance.current;

        return Scaffold(
          backgroundColor: p.ground,
          appBar: AppBar(
            backgroundColor: p.ground,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            foregroundColor: p.ink1,
            title: Text(title,
                style: pvManrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: p.ink1)),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 40),
            children: [
              Text(_en('WE ARE BUILDING THIS').of(lang),
                  style: pvManrope(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                      color: p.action)),
              const SizedBox(height: 12),
              Text(title,
                  style: pvFraunces(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                      color: p.ink1)),
              const SizedBox(height: 12),
              Text(willHold,
                  style: pvManrope(
                      fontSize: 14.5, height: 1.55, color: p.ink2)),
              const SizedBox(height: 24),

              if (onMeanwhile != null && meanwhileLabel != null) ...[
                Text(_en('MEANWHILE').of(lang),
                    style: pvManrope(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                        color: p.ink3)),
                const SizedBox(height: 12),
                SolutionCard(
                  type: SolutionType.read,
                  title: _en(meanwhileLabel!),
                  value: _en(meanwhileValue ?? ''),
                  p: p,
                  lang: lang,
                  onTap: onMeanwhile,
                ),
                const SizedBox(height: 24),
              ],

              Container(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                decoration: BoxDecoration(
                  color: p.surfaceAlt,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                    _en('We would rather tell you this is coming than show you '
                            'something that half answers it.')
                        .of(lang),
                    style: pvManrope(
                        fontSize: 12.5, height: 1.5, color: p.ink3)),
              ),
            ],
          ),
        );
      },
    );
  }
}
