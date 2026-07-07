// =============================================================================
//  MultiChildSheet - Multi-child switcher (parenting app · S10)
// -----------------------------------------------------------------------------
//  A bottom sheet listing the account's children (everything personalises to
//  whoever's active) with an "add a child" affordance. Faithful build of Claude
//  Design S10. Shown from Home → tap "Aarav ▾".
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';

/// Present the switcher as a modal bottom sheet.
Future<void> showMultiChildSheet(BuildContext context) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const MultiChildSheet(),
    );

class MultiChildSheet extends StatelessWidget {
  const MultiChildSheet({super.key});

  void _soon(BuildContext context) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Coming soon'), behavior: SnackBarBehavior.floating),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: ppBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(color: ppLine, borderRadius: BorderRadius.circular(999)),
              ),
            ),
            Text('Your children', style: ppJakarta(19)),
            const SizedBox(height: 4),
            Text("Everything personalises to whoever's active.", style: ppBody(13)),
            const SizedBox(height: 18),

            // active child
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: ppPanel,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE1D7EC)),
              ),
              child: Row(children: [
                _avatar(),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Aarav', style: ppJakarta(16)),
                    const SizedBox(height: 2),
                    Text.rich(TextSpan(children: [
                      const TextSpan(text: '4 months · '),
                      TextSpan(text: 'Leap 4 · The World of Events', style: TextStyle(color: ppCoral, fontWeight: FontWeight.w600)),
                    ]), style: ppBody(12)),
                  ]),
                ),
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(color: ppPurple, shape: BoxShape.circle),
                  child: const Text('✓', style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ]),
            ),

            // other child
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _soon(context),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.all(14),
                color: Colors.transparent,
                child: Row(children: [
                  _avatar(),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Meher', style: ppJakarta(16)),
                      const SizedBox(height: 2),
                      Text('2 years 6 months · Toddler', style: ppBody(12)),
                    ]),
                  ),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFD8C8EA), width: 1.5)),
                  ),
                ]),
              ),
            ),

            // add a child
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () => _soon(context),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                decoration: const BoxDecoration(border: Border(top: BorderSide(color: ppHair))),
                child: Row(children: [
                  Container(
                    width: 50,
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFC7BBD6), width: 1.5)),
                    child: const Text('+', style: TextStyle(color: ppPurple, fontSize: 22)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Add a child', style: ppJakarta(15, color: ppPurple)),
                      const SizedBox(height: 2),
                      Text('Name, birthday, a photo - takes a minute.', style: ppBody(12, color: ppMuted)),
                    ]),
                  ),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _avatar() => Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: ppBorder)),
        clipBehavior: Clip.antiAlias,
        child: const PpStriped(height: 60),
      );
}
