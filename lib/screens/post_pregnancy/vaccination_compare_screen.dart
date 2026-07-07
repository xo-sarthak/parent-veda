// =============================================================================
//  VaccinationCompareScreen - Govt vs IAP vs Private (parenting · S26·compare)
// -----------------------------------------------------------------------------
//  The three-way cost compare - what the government's UIP covers free, what the
//  IAP recommends on top, and the real private price range. Faithful build of
//  Claude Design "post pregnancy - content.dc.html" · S26·compare. Reached from
//  the Vaccination Tracker's "Compare all →".
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';

const Color _green = Color(0xFF1F8A5B);
const Color _greenTint = Color(0xFFEAF4EE);
const Color _brown = Color(0xFF7A4600);
const Color _brownTint = Color(0xFFF5EEE6);
const Color _iapTint = Color(0xFFEDE6F5);
const Color _dash = Color(0xFFC7BBD6);

// (name, iapAdds?, govt: '✓' | '-', iap: '✓' | '-', privatePrice)
const List<(String, bool, String, String, String)> _rows = [
  ('PCV (Pneumococcal)', false, '✓', '✓', '₹3.8–5.5k'),
  ('Rotavirus', false, '✓', '✓', '₹900–2.5k'),
  ('Hepatitis A', true, '-', '✓', '₹1.4–2.2k'),
  ('Typhoid (TCV)', true, '-', '✓', '₹1.5–2k'),
];

class VaccinationCompareScreen extends StatelessWidget {
  const VaccinationCompareScreen({super.key});

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: c);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: ListView(
        padding: const EdgeInsets.only(top: 60, bottom: 40),
        children: [
          _pad(ppCircleBack(context, eyebrow: 'Compare schedules')),

          const SizedBox(height: 20),
          _pad(Text("What's free, what's extra - honestly.", style: ppFraunces(29, h: 1.14))),
          const SizedBox(height: 12),
          _pad(Text('Every vaccine across the three schedules, side by side. No other app shows you the real cost.',
              style: ppBody(14))),

          // legend
          const SizedBox(height: 20),
          _pad(Row(children: [
            _legend('UIP · Free', _green, _greenTint),
            const SizedBox(width: 8),
            _legend('IAP · Recommended', ppPurple, _iapTint),
            const SizedBox(width: 8),
            _legend('Private · ₹', _brown, _brownTint),
          ])),

          // table
          const SizedBox(height: 18),
          _pad(Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: ppHair),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(children: [
              for (var i = 0; i < _rows.length; i++) _row(_rows[i], last: i == _rows.length - 1),
            ]),
          )),

          const SizedBox(height: 14),
          _pad(Text('Prices vary by city and brand · as of Jul 2026. Free vaccines are available at government centres.',
              style: ppBody(11, color: ppMuted, h: 1.5))),
        ],
      ),
    );
  }

  Widget _legend(String t, Color fg, Color bg) => Expanded(
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 7),
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
          child: Text(t,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: ppBody(10, color: fg, w: FontWeight.w700)),
        ),
      );

  Widget _row((String, bool, String, String, String) r, {required bool last}) {
    final (name, iapAdds, govt, iap, price) = r;
    Widget cell(String t, Color color) =>
        Expanded(child: Text(t, textAlign: TextAlign.center, style: ppBody(12, color: color, w: FontWeight.w700)));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(border: Border(bottom: last ? BorderSide.none : const BorderSide(color: ppPanel))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Flexible(child: Text(name, style: ppJakarta(14), maxLines: 1, overflow: TextOverflow.ellipsis)),
          if (iapAdds) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(color: _brownTint, borderRadius: BorderRadius.circular(999)),
              child: Text('IAP adds', style: ppBody(9, color: _brown, w: FontWeight.w700)),
            ),
          ],
        ]),
        const SizedBox(height: 9),
        Row(children: [
          cell(govt, govt == '✓' ? _green : _dash),
          cell(iap, iap == '✓' ? ppPurple : _dash),
          cell(price, ppInk),
        ]),
      ]),
    );
  }
}
