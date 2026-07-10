// =============================================================================
//  pp_section_extras - shared per-section search bar + floating Ask Veda button
// -----------------------------------------------------------------------------
//  Two small reusable pieces added across the parenting sections:
//    • ppSearchField(...) - a plain white search field (filters that section's
//      own list; each screen wires onChanged to its own state).
//    • PpAskVedaFab - a simple circular bottom-right button that opens Ask Veda
//      (openPpTab 1) from any section. Use inside a Stack (it's Positioned).
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';

/// A calm white search field. The owning screen keeps the controller + state and
/// rebuilds on [onChanged] (so the clear button appears/disappears).
Widget ppSearchField({
  required TextEditingController controller,
  required String hint,
  required ValueChanged<String> onChanged,
}) =>
    Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: ppHair)),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(children: [
        const Icon(Icons.search_rounded, size: 19, color: ppMuted),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            style: ppBody(14, color: ppInk, w: FontWeight.w600),
            decoration: InputDecoration(
              filled: false,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 13),
              border: InputBorder.none,
              hintText: hint,
              hintStyle: ppBody(14, color: ppMuted),
            ),
          ),
        ),
        if (controller.text.isNotEmpty)
          GestureDetector(
            onTap: () {
              controller.clear();
              onChanged('');
            },
            behavior: HitTestBehavior.opaque,
            child: const Padding(padding: EdgeInsets.only(left: 6), child: Icon(Icons.close_rounded, size: 17, color: ppMuted)),
          ),
      ]),
    );

/// A simple circular Ask Veda button, pinned bottom-right. Must live inside a
/// Stack. [bottom] lifts it above a floating bottom nav when present.
class PpAskVedaFab extends StatelessWidget {
  const PpAskVedaFab({super.key, this.bottom = 22});
  final double bottom;

  @override
  Widget build(BuildContext context) => Positioned(
        right: 18,
        bottom: bottom,
        child: GestureDetector(
          onTap: () => openPpTab(context, 1),
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: ppPurple,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Color(0x8C6A30B6), blurRadius: 22, spreadRadius: -6, offset: Offset(0, 10))],
            ),
            child: const Icon(Icons.auto_awesome, size: 24, color: Colors.white),
          ),
        ),
      );
}
