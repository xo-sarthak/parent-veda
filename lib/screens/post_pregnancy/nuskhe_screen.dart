// =============================================================================
//  NuskheScreen — Dadi / Nani ke Nuskhe · home remedies (parenting · S19)
// -----------------------------------------------------------------------------
//  Traditional grandmother home-remedies, each validated by an ayurvedic panel
//  + an MBBS paediatrician, browsable by situation. Reached from the Explore
//  drawer (design back-label: My Child). Faithful build of the visible portion
//  of Claude Design "post pregnancy app.dc.html" · S19.
//
//  NOTE: the design file exceeds DesignSync's 256 KiB fetch cap, so the tail of
//  the "By situation" grid and the remedy-detail frame (#s19d) are not yet
//  readable — cards/search route to a placeholder until that HTML is available.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';

class NuskheScreen extends StatelessWidget {
  const NuskheScreen({super.key});

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  void _soon(BuildContext context) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Coming soon'), behavior: SnackBarBehavior.floating),
      );

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
            _pad(Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: _cat(context, Icons.sick_outlined, 'Cold & cough', '6 remedies')),
              const SizedBox(width: 12),
              Expanded(child: _cat(context, Icons.thermostat, 'Fever', '4 remedies')),
            ])),
            const SizedBox(height: 12),
            _pad(Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: _cat(context, Icons.local_dining_outlined, 'Stomach issues', 'Remedies')),
              const SizedBox(width: 12),
              const Expanded(child: SizedBox()),
            ])),
          ],
        ),
      ),
    );
  }

  Widget _cat(BuildContext context, IconData icon, String title, String count) {
    return GestureDetector(
      onTap: () => _soon(context),
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
            child: Icon(icon, size: 19, color: ppPurple),
          ),
          const SizedBox(height: 12),
          Text(title, style: ppJakarta(15), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 3),
          Text(count, style: ppBody(12, color: ppMuted)),
        ]),
      ),
    );
  }
}
