// =============================================================================
//  Myth or fact — the answer behind the rail card (2026-09-30)
// -----------------------------------------------------------------------------
//  The week's own `mythBuster` (weekContent.json, written for every week), shown
//  as the myth she may have heard and the fact, in a small sheet. From the gap
//  analysis, "A Myth or fact and a Move card" (P3): "the rail has something new
//  to open every day".
//
//  ⚠️ IT SAYS WHOSE WORDS THESE ARE. "ParentVeda editorial", never a named
//  reviewer we do not have, and it ends at the doctor: a myth corrected for the
//  population is not advice about her own pregnancy.
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../products/pv_store_chrome.dart' show kPvInk, kPvLine, pvStorePalette;

Future<void> showPregMythSheet(BuildContext context, {required String myth, required String truth}) {
  final p = pvStorePalette;
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: p.ground,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) => SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Semantics(
              header: true,
              child: Text('Myth or fact',
                  style: pvFraunces(fontSize: 22, fontWeight: FontWeight.w600, height: 1.2, color: p.ink1)),
            ),
            const SizedBox(height: 16),
            _Block(label: 'YOU MAY HAVE HEARD', text: myth, key: const ValueKey('myth_text')),
            const SizedBox(height: 12),
            _Block(label: 'WHAT WE KNOW', text: truth, key: const ValueKey('myth_truth')),
            const SizedBox(height: 14),
            Text('ParentVeda editorial. For your own pregnancy, your doctor knows your whole picture.',
                style: pvManrope(fontSize: 12, height: 1.45, color: p.ink3)),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                key: const ValueKey('myth_done'),
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text('Done', style: pvManrope(fontSize: 14, fontWeight: FontWeight.w700, color: kPvInk)),
              ),
            ),
          ]),
        ),
      ),
    ),
  );
}

class _Block extends StatelessWidget {
  const _Block({super.key, required this.label, required this.text});
  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kPvLine),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: pvManrope(fontSize: 10.5, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: p.ink3)),
        const SizedBox(height: 6),
        Text(text, style: pvManrope(fontSize: 14.5, height: 1.5, color: p.ink1)),
      ]),
    );
  }
}
