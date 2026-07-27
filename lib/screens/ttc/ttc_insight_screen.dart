// =============================================================================
//  TTC - the insight reader
// -----------------------------------------------------------------------------
//  One insight, read properly. Follows ParentVeda's editorial structure:
//
//      What → Why → What this means for you → Today's takeaway → Related
//                                                    - TTC master, §3.2
//
//  Progressive disclosure applies here as everywhere: the answer is above the
//  fold, the depth is below it. The takeaway is repeated at the end because it
//  is the one line meant to survive the day.
// =============================================================================

import 'package:flutter/material.dart';

import '../../ttc/ttc_daily_data.dart';
import 'ttc_common.dart';
import 'ttc_strings.dart';

class TtcInsightScreen extends StatelessWidget {
  const TtcInsightScreen({super.key, required this.insight});

  final TtcInsight insight;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: TtcLang.instance,
      builder: (context, _) {
        final t = TtcS.current();
        final hi = t.hinglish;
        final paragraphs = insight.body(hi).split('\n\n');
        return Scaffold(
          backgroundColor: ttcBg,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(ttcGutter, 8, ttcGutter, 40),
              children: [
                TtcBackBar(title: t.todaysInsight),
                const SizedBox(height: 20),

                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                        color: ttcPanel,
                        borderRadius: BorderRadius.circular(999)),
                    child: Text(ttcTopicLabel(insight.topic, hi),
                        style:
                            ttcBody(11, color: ttcPurple, w: FontWeight.w800)),
                  ),
                  const SizedBox(width: 9),
                  Text(t.readSeconds(insight.readSeconds),
                      style: ttcBody(11.5, color: ttcMuted, w: FontWeight.w700)),
                ]),
                const SizedBox(height: 14),

                // Fraunces for the headline - this is a reading surface, which
                // is one of the few places the display serif belongs.
                Text(insight.title(hi),
                    style: ttcFraunces(26, w: FontWeight.w600, color: ttcTitleInk)),
                const SizedBox(height: 18),

                for (final p in paragraphs) ...[
                  Text(p, style: ttcBody(15, h: 1.72, color: ttcInk)),
                  const SizedBox(height: 16),
                ],

                const SizedBox(height: 4),
                TtcCard(
                  color: ttcPanel,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ttcEyebrow(
                            hi ? 'Aaj ki ek baat' : "Today's takeaway",
                            color: ttcPurple),
                        const SizedBox(height: 9),
                        Text(insight.takeaway(hi),
                            style: ttcBody(15,
                                color: ttcTitleInk,
                                w: FontWeight.w700,
                                h: 1.5)),
                      ]),
                ),
                const SizedBox(height: 16),

                // Every clinical surface in this product ends with a
                // disclaimer. This is not decoration - it is the rule.
                _Disclaimer(hi: hi),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Disclaimer extends StatelessWidget {
  const _Disclaimer({required this.hi});
  final bool hi;

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Icon(Icons.info_outline_rounded, size: 15, color: ttcMuted),
      const SizedBox(width: 9),
      Expanded(
        child: Text(
          hi
              ? 'Ye jaankari padhne ke liye hai, diagnosis ke liye nahi. Apni sehat ke faisle apne doctor ke saath lein.'
              : 'This is information, never a diagnosis. Decisions about your health belong with your doctor.',
          style: ttcBody(11.5, color: ttcMuted, h: 1.5),
        ),
      ),
    ]);
  }
}

String ttcTopicLabel(String topic, bool hi) {
  switch (topic) {
    case 'fertility':
      return hi ? 'Fertility' : 'Fertility';
    case 'nutrition':
      return hi ? 'Khaana' : 'Nutrition';
    case 'lifestyle':
      return hi ? 'Lifestyle' : 'Lifestyle';
    case 'male':
      return hi ? 'Male fertility' : 'Male fertility';
    case 'medical':
      return hi ? 'Medical' : 'Medical';
    case 'emotional':
      return hi ? 'Mann' : 'Emotional';
    default:
      return topic;
  }
}
