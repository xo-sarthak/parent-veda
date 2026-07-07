// =============================================================================
//  VaccineDetailScreen - vaccine detail · after-care (parenting · S26·detail)
// -----------------------------------------------------------------------------
//  One dose, in full: what it protects against, quick facts, honest after-care,
//  the red-flag "call now" box, gentle comfort-essential commerce, and Learn /
//  Ask-Veda cross-links, with a sticky "Mark as done" + reminder bar. Faithful
//  build of Claude Design "post pregnancy - content.dc.html" · S26·detail.
//  Informational only, not medical advice.
// =============================================================================

import 'package:flutter/material.dart';

import '../../services/notification_service.dart';
import 'askveda_screen.dart';
import 'pp_common.dart';
import 'product_detail_screen.dart';
import 'vaccine_learn_screen.dart';

const Color _green = Color(0xFF1F8A5B);
const Color _flagBg = Color(0xFFFFF0F3);
const Color _flagBorder = Color(0xFFFFD9E1);
const Color _flagFg = Color(0xFFC6295A);

// (title, price)
const List<(String, String)> _comfort = [
  ('Digital thermometer', '₹499'),
  ('Medicine dropper', '₹149'),
  ('Cold compress pack', '₹299'),
];

class VaccineDetailScreen extends StatelessWidget {
  const VaccineDetailScreen({super.key});

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  void _push(BuildContext context, Widget s) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => s));

  void _snack(BuildContext context, String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: Stack(children: [
        ListView(
          padding: const EdgeInsets.only(top: 60, bottom: 108),
          children: [
            _pad(ppCircleBack(context, eyebrow: 'Due 22 Jul')),

            const SizedBox(height: 22),
            _pad(ppEyebrow('Dose 3 of 3', color: ppPurple, spacing: 1.2)),
            const SizedBox(height: 10),
            _pad(Text('Pneumococcal (PCV)', style: ppFraunces(31, h: 1.12))),

            // protects against
            const SizedBox(height: 20),
            _pad(Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(18)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                ppEyebrow('Protects against', color: ppPurple, spacing: 0.8),
                const SizedBox(height: 8),
                Text("Pneumonia, meningitis and blood infections (sepsis) - among the most serious illnesses in a baby's first years.",
                    style: ppBody(14, color: ppInk, h: 1.6)),
              ]),
            )),

            // quick facts
            const SizedBox(height: 14),
            _pad(Row(children: [
              _fact('14 wks', 'timing', ppInk),
              const SizedBox(width: 10),
              _fact('Free', 'at govt', _green),
              const SizedBox(width: 10),
              _fact('IM', 'left thigh', ppInk),
            ])),

            _pad(ppSectionDivider()),

            // after care
            _pad(Align(alignment: Alignment.centerLeft, child: Text('After the shot', style: ppJakarta(16)))),
            const SizedBox(height: 12),
            _pad(Text('Mild soreness at the site and a low fever for a day or two are normal and expected - a sign his body is building protection.',
                style: ppBody(14))),
            const SizedBox(height: 12),
            _pad(_check('Extra cuddles and feeds; a cool compress for soreness.')),
            const SizedBox(height: 9),
            _pad(_check("Paracetamol only if he's uncomfortable - weight-based, confirm the dose with your paediatrician. Not before the shot.")),

            // red flag
            const SizedBox(height: 18),
            _pad(Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(color: _flagBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: _flagBorder)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Icon(Icons.warning_amber_rounded, size: 17, color: _flagFg),
                  const SizedBox(width: 8),
                  Text('Call 112 / 108 now if', style: ppBody(13, color: _flagFg, w: FontWeight.w700)),
                ]),
                const SizedBox(height: 8),
                Text('Noisy or difficult breathing, swelling of face/lips, widespread hives with vomiting, floppiness or a seizure.',
                    style: ppBody(13, color: ppInk, h: 1.55)),
              ]),
            )),

            // comfort essentials
            const SizedBox(height: 26),
            _pad(Align(alignment: Alignment.centerLeft, child: Text('Comfort essentials', style: ppJakarta(15)))),
            const SizedBox(height: 12),
            SizedBox(
              height: 160,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _comfort.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (_, i) => _productCard(context, _comfort[i]),
              ),
            ),

            // learn + ask veda
            const SizedBox(height: 20),
            _pad(_crossLink(context, 'Learn', 'PCV: why it matters, explained', const VaccineLearnScreen(), top: true)),
            _pad(_crossLink(context, 'Ask Veda', 'Can he get it if he has a fever?', const AskVedaScreen(), top: true, bottom: true)),

            const SizedBox(height: 20),
            _pad(Text('Informational only, not medical advice - always confirm with your paediatrician.',
                textAlign: TextAlign.center, style: ppBody(12, color: ppMuted, h: 1.55))),
          ],
        ),

        // top fade
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: Container(
              height: 52,
              decoration: const BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [ppBg, Color(0x00FBF9FE)]),
              ),
            ),
          ),
        ),

        // sticky action bar
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 22),
            decoration: const BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x00FBF9FE), ppBg]),
            ),
            child: Row(children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _snack(context, 'Marked as done'),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    height: 54,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: ppPurple,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [BoxShadow(color: Color(0x8C6A30B6), blurRadius: 28, spreadRadius: -10, offset: Offset(0, 12))],
                    ),
                    child: Text('Mark as done', style: ppBody(15, color: Colors.white, w: FontWeight.w700)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => _reminderSheet(context),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 54,
                  height: 54,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: ppLine)),
                  child: const Icon(Icons.notifications_none_rounded, size: 22, color: ppInk),
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }

  // ---- reminder scheduling ------------------------------------------------
  void _reminderSheet(BuildContext context) {
    final due = DateTime(2026, 7, 22, 9, 0); // PCV dose 3 due date (scenario)
    void set(int daysBefore, String label) {
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop();
      // Best-effort local notification (Android configured; a no-op if the
      // platform can't schedule). Fire-and-forget - no context use after await.
      NotificationService.instance.requestPermission();
      NotificationService.instance.scheduleOneOff(
        id: 700003,
        title: 'Vaccine reminder - PCV dose 3',
        body: daysBefore == 0
            ? "Aarav's PCV dose 3 is due today (22 Jul)."
            : "Aarav's PCV dose 3 is due ${daysBefore == 1 ? 'tomorrow' : 'in $daysBefore days'} - 22 Jul.",
        when: due.subtract(Duration(days: daysBefore)),
      );
      messenger.showSnackBar(SnackBar(content: Text('Reminder set - $label'), behavior: SnackBarBehavior.floating));
    }

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: ppBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (ctx) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: ppLine, borderRadius: BorderRadius.circular(999)))),
            const SizedBox(height: 16),
            Text('Remind me about this vaccine', style: ppJakarta(17)),
            const SizedBox(height: 4),
            Text('Due 22 Jul · we’ll send a gentle nudge.', style: ppBody(12.5, color: ppMuted)),
            const SizedBox(height: 14),
            _reminderOption('The day before', '21 Jul', () => set(1, '1 day before')),
            _reminderOption('3 days before', '19 Jul', () => set(3, '3 days before')),
            _reminderOption('A week before', '15 Jul', () => set(7, '1 week before')),
            _reminderOption('On the day', '22 Jul', () => set(0, 'on the day')),
          ]),
        ),
      ),
    );
  }

  Widget _reminderOption(String label, String date, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: ppHair)),
          child: Row(children: [
            const Icon(Icons.notifications_active_outlined, size: 18, color: ppPurple),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: ppBody(14, color: ppInk, w: FontWeight.w600))),
            Text(date, style: ppBody(12.5, color: ppMuted)),
          ]),
        ),
      );

  Widget _fact(String big, String small, Color bigColor) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
          alignment: Alignment.center,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: ppHair)),
          child: Column(children: [
            Text(big, style: ppJakarta(14, color: bigColor)),
            const SizedBox(height: 2),
            Text(small, style: ppBody(10, color: ppMuted)),
          ]),
        ),
      );

  Widget _check(String t) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('✓', style: TextStyle(color: ppPurple, fontWeight: FontWeight.w700)),
        const SizedBox(width: 10),
        Expanded(child: Text(t, style: ppBody(14, color: ppInk, h: 1.5))),
      ]);

  Widget _productCard(BuildContext context, (String, String) p) => GestureDetector(
        onTap: () => _push(context, const ProductDetailScreen()),
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 150,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: ppHair)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const PpStriped(height: 70, radius: 12),
            const SizedBox(height: 9),
            Text(p.$1, style: ppBody(13, color: ppInk, w: FontWeight.w600, h: 1.25), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 3),
            Text(p.$2, style: ppBody(12, color: ppInk, w: FontWeight.w700)),
          ]),
        ),
      );

  Widget _crossLink(BuildContext context, String pill, String text, Widget screen, {bool top = false, bool bottom = false}) =>
      GestureDetector(
        onTap: () => _push(context, screen),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            border: Border(
              top: top ? const BorderSide(color: ppHair) : BorderSide.none,
              bottom: bottom ? const BorderSide(color: ppHair) : BorderSide.none,
            ),
          ),
          child: Row(children: [
            Container(
              width: 66,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(999)),
              child: Text(pill, style: ppBody(10, color: ppPurple, w: FontWeight.w700)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(text, style: ppBody(14, color: ppInk))),
            const SizedBox(width: 10),
            const Text('→', style: TextStyle(color: ppMuted)),
          ]),
        ),
      );
}
