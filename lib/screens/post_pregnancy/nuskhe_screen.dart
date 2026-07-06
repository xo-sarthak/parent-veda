// =============================================================================
//  NuskheScreen — Dadi / Nani ke Nuskhe · home remedies (parenting · S19)
// -----------------------------------------------------------------------------
//  Traditional grandmother home-remedies, each validated by an ayurvedic panel
//  + an MBBS paediatrician: a validation banner, search, a browse-by-situation
//  grid, and popular seasonal remedies. Reached from the Explore drawer. Faithful
//  build of Claude Design "post pregnancy - content.dc.html" · S19. Cards and
//  remedies open the remedy detail.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';
import 'remedy_detail_screen.dart';

class NuskheScreen extends StatelessWidget {
  const NuskheScreen({super.key});

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  void _soon(BuildContext context) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Coming soon'), behavior: SnackBarBehavior.floating),
      );

  void _openRemedy(BuildContext context, String category) => Navigator.of(context)
      .push(MaterialPageRoute<void>(builder: (_) => RemedyDetailScreen(category: category)));

  static const List<(IconData, String, String)> _situations = [
    (Icons.masks_outlined, 'Cold & cough', '6 remedies'),
    (Icons.thermostat, 'Fever', '4 remedies'),
    (Icons.local_dining_outlined, 'Stomach & colic', '5 remedies'),
    (Icons.child_care_outlined, 'Teething', '3 remedies'),
    (Icons.bedtime_outlined, 'Sleep issues', '4 remedies'),
    (Icons.spa_outlined, 'Skin issues', '5 remedies'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 40),
          children: [
            _pad(ppBack(context, 'Explore')),

            // header
            const SizedBox(height: 22),
            _pad(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('दादी–नानी के नुस्खे', style: ppBody(11, color: ppBrown, w: FontWeight.w700)),
              const SizedBox(height: 10),
              Text('Home remedies, safely.', style: ppFraunces(32, h: 1.12)),
              const SizedBox(height: 12),
              Text.rich(
                TextSpan(children: [
                  const TextSpan(
                      text:
                          'The remedies your grandmother swore by — each one reviewed and signed off by qualified ayurvedic doctors, with clear notes on when '),
                  TextSpan(text: 'not', style: ppBody(15).copyWith(fontStyle: FontStyle.italic, color: ppBrown)),
                  const TextSpan(text: ' to use them.'),
                ]),
                style: ppBody(15),
              ),
            ])),

            // validation trust banner
            const SizedBox(height: 20),
            _pad(Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(18)),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.verified_user_outlined, size: 20, color: ppPurple),
                const SizedBox(width: 12),
                Expanded(
                  child: Text.rich(
                    TextSpan(children: [
                      const TextSpan(text: 'Every nuskha is validated by a panel of '),
                      TextSpan(text: '5 ayurvedic practitioners', style: ppBody(13, color: ppInk, w: FontWeight.w700)),
                      const TextSpan(text: ' + an MBBS paediatrician for safety.'),
                    ]),
                    style: ppBody(13, color: ppInk, h: 1.5),
                  ),
                ),
              ]),
            )),

            // search
            const SizedBox(height: 16),
            _pad(GestureDetector(
              onTap: () => _soon(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: ppBorder)),
                child: Row(children: [
                  const Icon(Icons.search_rounded, size: 18, color: ppMuted),
                  const SizedBox(width: 11),
                  Flexible(
                      child: Text("What's troubling your little one?",
                          style: ppBody(14, color: ppMuted), maxLines: 1, overflow: TextOverflow.ellipsis)),
                ]),
              ),
            )),

            // by situation
            const SizedBox(height: 28),
            _pad(Text('By situation', style: ppJakarta(18))),
            const SizedBox(height: 14),
            for (int i = 0; i < _situations.length; i += 2) ...[
              if (i > 0) const SizedBox(height: 12),
              _pad(Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: _cat(context, _situations[i])),
                const SizedBox(width: 12),
                Expanded(
                    child: i + 1 < _situations.length ? _cat(context, _situations[i + 1]) : const SizedBox()),
              ])),
            ],

            // popular this monsoon
            const SizedBox(height: 28),
            _pad(Text('Popular this monsoon', style: ppJakarta(16))),
            const SizedBox(height: 12),
            _pad(_remedy(context, Icons.eco_outlined, 'Ajwain potli for a blocked nose',
                'Vaidya-approved', ppBrown, ppPanel, '0+ months',
                top: true)),
            _pad(_remedy(context, Icons.local_florist_outlined, 'Nutmeg (jaiphal) for restful sleep',
                '8+ months only', ppCoral, ppCoralTint, 'read cautions',
                top: true, bottom: true)),

            const SizedBox(height: 22),
            _pad(Text('No WhatsApp forwards here — only nuskhe reviewed and signed off by qualified ayurvedic practitioners.',
                textAlign: TextAlign.center, style: ppBody(12, color: ppMuted, h: 1.55))),
          ],
        ),
      ),
    );
  }

  Widget _cat(BuildContext context, (IconData, String, String) s) => GestureDetector(
        onTap: () => _openRemedy(context, s.$2),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: ppBorder)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(12)),
              child: Icon(s.$1, size: 19, color: ppPurple),
            ),
            const SizedBox(height: 12),
            Text(s.$2, style: ppJakarta(15), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 3),
            Text(s.$3, style: ppBody(12, color: ppMuted)),
          ]),
        ),
      );

  Widget _remedy(BuildContext context, IconData icon, String title, String pill, Color pillFg, Color pillBg, String meta,
      {bool top = false, bool bottom = false}) {
    return GestureDetector(
      onTap: () => _openRemedy(context, 'Cold & cough'),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            top: top ? const BorderSide(color: ppHair) : BorderSide.none,
            bottom: bottom ? const BorderSide(color: ppHair) : BorderSide.none,
          ),
        ),
        child: Row(children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFECE5F2))),
            clipBehavior: Clip.antiAlias,
            child: Stack(children: [
              const PpStriped(height: 56),
              Positioned.fill(child: Center(child: Icon(icon, size: 22, color: ppPurple))),
            ]),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: ppBody(15, color: ppInk, w: FontWeight.w700), maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 6),
              Wrap(spacing: 8, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: pillBg, borderRadius: BorderRadius.circular(999)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(pillFg == ppCoral ? Icons.warning_amber_rounded : Icons.check_rounded, size: 11, color: pillFg),
                    const SizedBox(width: 4),
                    Text(pill, style: ppBody(10, color: pillFg, w: FontWeight.w700)),
                  ]),
                ),
                Text(meta, style: ppBody(12, color: ppMuted)),
              ]),
            ]),
          ),
          const SizedBox(width: 10),
          const Text('→', style: TextStyle(color: ppMuted)),
        ]),
      ),
    );
  }
}
