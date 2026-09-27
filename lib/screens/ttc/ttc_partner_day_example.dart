// =============================================================================
//  TtcPartnerDayExample — a picture of his day, for the pairing screen
// -----------------------------------------------------------------------------
//  From the TTC gap analysis, "Behind — Partner" (2026-09-26): our pairing
//  screen is clear about privacy but never showed her what he would actually
//  get. This is one day on his side, drawn in his Slate palette so it reads as
//  "his half" at a glance.
//
//  ⚠️ BUILT HERE, PLACED BY THE LEAD. The pairing screen lives in
//  `lib/screens/profile/pv_partner_screen.dart`, which another helper was
//  editing at the time. This widget is self-contained so placing it is one
//  line under the pitch, for the Trying-to-Conceive stage only.
//
//  ⚠️ IT SHOWS NOTHING HIS REAL VIEW DOES NOT. See the note on the copy in
//  `ttc_partner_data.dart`: chapter-level, never a day count.
//
//  ⚠️ AN OBJECT, NOT A PANEL (review P1, 2026-09-26). It was a tinted slate
//  panel full of text on the white pairing screen, which reads as a callout
//  (DESIGN-SYSTEM §4.0 addendum 1: no text on a tinted box). A preview of his
//  screen is an OBJECT, so it is drawn as one: a white card, one hairline,
//  radius 16, and a slim slate strip across its top carrying the heading, so
//  it still says "his half" at a glance. The rows sit between hairlines, and
//  the eyebrow is 11 (was 10). Mobbin: Flo for Partners lists what is shared
//  rather than panelling it (FLO-PARTNER-FAQ,
//  https://mobbin.com/screens/b4219846-68c0-4bce-8207-d0295aeb0759) and draws
//  his steps as rows with line art (FLO-PARTNER-HOW,
//  https://mobbin.com/screens/a3f921e6-76e1-4b52-a46d-255b88fdcc05).
//  Kept for revert: one Container, `ttcSlatePanel` fill, radius 18, the
//  heading at 10 in `ttcSlateAmber`.
// =============================================================================

import 'package:flutter/material.dart';

import '../../ttc/ttc_partner_data.dart';
import 'ttc_common.dart';

class TtcPartnerDayExample extends StatelessWidget {
  const TtcPartnerDayExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('ttc_partner_day_example'),
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ttcLine),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // His half, said by colour: a slim strip in his palette, one line.
        Container(
          key: const ValueKey('ttc_partner_day_strip'),
          width: double.infinity,
          color: ttcSlatePanel,
          padding: const EdgeInsets.fromLTRB(16, 9, 16, 9),
          child: Text(kTtcPartnerDayHeading.toUpperCase(),
              style: ttcBody(11, color: ttcSlate, w: FontWeight.w800)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _row(Icons.wb_sunny_outlined, kTtcPartnerDayTodayLabel,
                kTtcPartnerDayToday),
            _rule(),
            _row(Icons.flag_outlined, kTtcPartnerDayMissionLabel,
                ttcPartnerDayMission()),
            _rule(),
            _row(Icons.chat_bubble_outline_rounded, kTtcTonightLabel,
                kTtcTonightQuestions.first),
            _rule(),
            Text(kTtcPartnerDayFootnote,
                style: ttcBody(11.5, color: ttcSlateSoft, h: 1.4)),
          ]),
        ),
      ]),
    );
  }

  static Widget _rule() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Container(height: 1, color: ttcLine),
      );

  // Kept for revert: the slate hairline between rows.
  //   child: Container(height: 1, color: ttcSlateLine),
  static Widget _row(IconData icon, String label, String value) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(icon, size: 17, color: ttcSlate),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: ttcBody(11.5,
                          color: ttcSlateSoft, w: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text(value,
                      style: ttcBody(14,
                          color: ttcSlateInk, w: FontWeight.w700, h: 1.4)),
                ]),
          ),
        ],
      );
}
