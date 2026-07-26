// =============================================================================
//  The doctor's fourth tab — Impact, with Earnings inside it
// -----------------------------------------------------------------------------
//  The user's instruction was that the Partner Journey Dashboard should ABSORB
//  the existing earnings screen rather than sit beside it, and the ordering is
//  the point: a doctor opening this tab sees how many families they have
//  helped, and has to choose to look at the money.
//
//  Two distinct sets of numbers live here and are deliberately NOT merged:
//
//    Impact   — families brought to ParentVeda, and what happened to them.
//               Includes referral commission from the ledger (0037).
//    Earnings — what this doctor earned from their OWN consultations.
//
//  Adding them together would produce one number that answers no question. A
//  doctor asking "what did my clinic hours make?" and a doctor asking "what did
//  my referrals make?" are asking different things.
// =============================================================================

import 'package:flutter/material.dart';

import '../post_pregnancy/pp_common.dart';
import 'doctor_earnings_screen.dart';
import 'doctor_impact_screen.dart';

class DoctorImpactTab extends StatefulWidget {
  const DoctorImpactTab({super.key});

  @override
  State<DoctorImpactTab> createState() => _DoctorImpactTabState();
}

class _DoctorImpactTabState extends State<DoctorImpactTab> {
  int _view = 0;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
        child: Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
              color: ppPanel, borderRadius: BorderRadius.circular(11)),
          child: Row(children: [
            Expanded(child: _seg(0, 'Impact')),
            Expanded(child: _seg(1, 'Earnings')),
          ]),
        ),
      ),
      Expanded(
        child: _view == 0
            ? const DoctorImpactScreen()
            : const DoctorEarningsScreen(),
      ),
    ]);
  }

  Widget _seg(int i, String label) {
    final on = _view == i;
    return GestureDetector(
      onTap: () => setState(() => _view = i),
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: on ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(label,
            style: ppJakarta(12.5, color: on ? ppPurple : ppSoft)),
      ),
    );
  }
}
