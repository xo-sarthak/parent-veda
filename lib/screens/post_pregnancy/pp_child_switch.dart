// =============================================================================
//  "Aarav ▾" — switching child from the parenting home (2026-10-07)
// -----------------------------------------------------------------------------
//  Gap analysis P2 (Behind · Onboarding, "More than one child"): "Put the
//  child's name in the hero as a small dropdown when there are two or more
//  children: 'Aarav ▾' with each child and 'Add a child'."
//
//  Drawn only with two or more children: with one, the name would be a
//  control that does nothing. Switching is ChildProfileStore.switchTo, the
//  same move You makes, so every child-scoped store follows.
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../profile/pv_you_sheets.dart' show showPvAddChildSheet;
import '../v2/v2_palette.dart';
import 'pp_child_profile.dart';

class PpChildSwitch extends StatelessWidget {
  const PpChildSwitch({super.key, required this.p});
  final V2Palette p;

  @override
  Widget build(BuildContext context) {
    final store = ChildProfileStore.instance;
    if (store.children.length < 2) return const SizedBox.shrink();
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const ValueKey('pp_child_switch'),
        borderRadius: BorderRadius.circular(10),
        onTap: () => _open(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(store.active.name,
                style: pvManrope(fontSize: 15, fontWeight: FontWeight.w800, color: p.ink1)),
            const SizedBox(width: 2),
            Icon(Icons.expand_more_rounded, size: 20, color: p.ink1),
          ]),
        ),
      ),
    );
  }

  Future<void> _open(BuildContext context) async {
    final store = ChildProfileStore.instance;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: p.ground,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 10),
              child: Text('Whose page?',
                  style: pvFraunces(fontSize: 20, fontWeight: FontWeight.w600, color: p.ink1)),
            ),
            for (final c in store.children)
              ListTile(
                key: ValueKey('pp_child_switch_${c.id}'),
                title: Text(c.name, style: pvManrope(fontSize: 15, fontWeight: FontWeight.w700, color: p.ink1)),
                trailing: c.id == store.active.id ? Icon(Icons.check_rounded, color: p.ink1) : null,
                onTap: () {
                  Navigator.of(ctx).pop();
                  if (c.id != store.active.id) store.switchTo(c.id);
                },
              ),
            ListTile(
              key: const ValueKey('pp_child_switch_add'),
              leading: Icon(Icons.person_add_alt_1_outlined, color: p.ink2),
              title: Text('Add a child', style: pvManrope(fontSize: 15, fontWeight: FontWeight.w700, color: p.ink2)),
              onTap: () {
                Navigator.of(ctx).pop();
                showPvAddChildSheet(context);
              },
            ),
          ]),
        ),
      ),
    );
  }
}
