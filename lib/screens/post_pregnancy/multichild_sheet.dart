// =============================================================================
//  MultiChildSheet - Multi-child switcher (parenting app · S10)
// -----------------------------------------------------------------------------
//  A bottom sheet listing the account's children (everything personalises to
//  whoever's active) with an "add a child" affordance. Faithful build of Claude
//  Design S10. Shown from the My Child home → tap the child's name / photo.
//
//  This sheet existed but was orphaned: nothing in the app opened it, and its
//  contents were hard-coded to "Aarav" and "Meher" with the tap on the second
//  child going to a "coming soon" snackbar. ChildProfileStore has supported
//  multiple children and switchTo() the whole time — the data layer was simply
//  ahead of the wiring. It now reads the real children and really switches.
//
//  The Claude Design layout is unchanged; only the data behind it is real.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_child_profile.dart';
import 'pp_common.dart';
import 'pp_phases_data.dart';

/// Present the switcher as a modal bottom sheet.
Future<void> showMultiChildSheet(BuildContext context) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const MultiChildSheet(),
    );

class MultiChildSheet extends StatelessWidget {
  const MultiChildSheet({super.key});

  ChildProfileStore get _store => ChildProfileStore.instance;

  /// Add a child. ChildProfileStore.addChild() has been complete (and
  /// cloud-writing) for a while; only this form was missing, so the button sat
  /// on a "coming soon" snackbar while the data layer was ready.
  ///
  /// Name and date of birth are required; birth weight, weight and height are
  /// OPTIONAL, added at the review's request.
  ///
  /// This deliberately used to ask for name and date of birth only, on the
  /// grounds that a measurement belongs in the growth record where it is dated
  /// rather than guessed at sign-up. That still holds for CURRENT weight and
  /// height, which is why they are marked optional and the form saves happily
  /// without them.
  ///
  /// Birth weight is the one that genuinely belongs here: it is a fixed fact
  /// about the child that never changes, a parent knows it on the day, and
  /// asking later means asking someone to remember it.
  Future<void> _addChild(BuildContext context) async {
    final nameCtl = TextEditingController();
    // Optional, per the review. Empty stays empty — _num() returns 0 and the
    // store treats 0 as "not recorded" rather than as a measurement of zero.
    final birthWtCtl = TextEditingController();
    final wtCtl = TextEditingController();
    final htCtl = TextEditingController();
    var isBoy = true;
    DateTime? dob;

    final saved = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: ppBg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(
              22, 18, 22, MediaQuery.of(ctx).viewInsets.bottom + 22),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: ppHair, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 18),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Add a child', style: ppFraunces(24, h: 1.1)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameCtl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                child: SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: true, label: Text('Boy')),
                    ButtonSegment(value: false, label: Text('Girl')),
                  ],
                  selected: {isBoy},
                  onSelectionChanged: (v) => setSheet(() => isBoy = v.first),
                ),
              ),
            ]),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () async {
                final now = DateTime.now();
                final picked = await showDatePicker(
                  context: ctx,
                  initialDate: dob ?? now,
                  firstDate: DateTime(now.year - 18),
                  lastDate: now,
                );
                if (picked != null) setSheet(() => dob = picked);
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                decoration: BoxDecoration(
                    border: Border.all(color: ppHair),
                    borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  const Icon(Icons.cake_outlined, size: 18, color: ppMuted),
                  const SizedBox(width: 10),
                  Text(
                    dob == null
                        ? 'Date of birth'
                        : '${dob!.day}/${dob!.month}/${dob!.year}',
                    style: ppBody(14,
                        color: dob == null ? ppMuted : ppInk),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 14),
            Row(children: [
              Text('Optional', style: ppBody(11.5, color: ppMuted, w: FontWeight.w700)),
              const SizedBox(width: 8),
              Expanded(child: Container(height: 1, color: ppHair)),
            ]),
            const SizedBox(height: 12),
            _numField(birthWtCtl, 'Birth weight', 'kg', Icons.child_friendly_outlined),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _numField(wtCtl, 'Weight now', 'kg', Icons.monitor_weight_outlined)),
              const SizedBox(width: 10),
              Expanded(child: _numField(htCtl, 'Height now', 'cm', Icons.straighten_outlined)),
            ]),
            const SizedBox(height: 8),
            Text(
                'You can leave these blank and add them later from the growth '
                'record.',
                style: ppBody(11.5, color: ppMuted, h: 1.45)),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                if (nameCtl.text.trim().isEmpty || dob == null) return;
                Navigator.of(ctx).pop(true);
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: ppPurple, borderRadius: BorderRadius.circular(14)),
                child: Text('Save',
                    style: ppBody(15, color: Colors.white, w: FontWeight.w700)),
              ),
            ),
          ]),
        ),
      ),
    );

    if (saved != true || dob == null) return;
    await _store.addChild(
      name: nameCtl.text.trim(),
      isBoy: isBoy,
      dob: dob!,
      birthWeightKg: _num(birthWtCtl.text),
      weightKg: _num(wtCtl.text),
      heightCm: _num(htCtl.text),
    );
    if (!context.mounted) return;
    Navigator.of(context).maybePop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('${nameCtl.text.trim()} added'),
          behavior: SnackBarBehavior.floating),
    );
  }

  /// A blank optional field is 0, not an error and not a zero measurement.
  ///
  /// Also tolerates a comma decimal separator, which is what a phone keypad
  /// gives on a lot of Indian locales — '3,2' silently parsing to null would
  /// look to a parent like the app had ignored what they typed.
  static double _num(String raw) =>
      double.tryParse(raw.trim().replaceAll(',', '.')) ?? 0;

  Widget _numField(
          TextEditingController c, String label, String unit, IconData icon) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
            border: Border.all(color: ppHair),
            borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          Icon(icon, size: 18, color: ppMuted),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: c,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: ppBody(14, color: ppInk),
              cursorColor: ppPurple,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: label,
                hintStyle: ppBody(14, color: ppMuted),
              ),
            ),
          ),
          Text(unit, style: ppBody(12.5, color: ppMuted)),
        ]),
      );

  /// "4 months · Reaching out" — the child's age and the phase they are in.
  /// Previously named a Wonder Weeks leap ("Leap 4 · The World of Events"),
  /// which stopped meaning anything past 20 months and told every parent the
  /// same thing at the same week.
  Widget _subtitle(Child c, bool active) {
    final weeks = _ageInWeeks(c);
    final months = (weeks / 4.345).floor();
    final age = _ageLabel(months);
    final phase = kPhases[phaseIndexForMonths(months.toDouble())];
    // Phases run to five years, so unlike leaps there is no "past the end"
    // case to handle before then.
    final inPhase = months < 60;

    if (!inPhase) {
      return Text('$age · ${months >= 12 ? 'Toddler' : 'Baby'}', style: ppBody(12));
    }
    return Text.rich(
      TextSpan(children: [
        TextSpan(text: '$age · '),
        TextSpan(
          text: phase.name,
          style: const TextStyle(color: ppCoral, fontWeight: FontWeight.w600),
        ),
      ]),
      style: ppBody(12),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  double _ageInWeeks(Child c) {
    final d = DateTime.now().difference(c.dob).inDays;
    return d < 0 ? 0 : d / 7.0;
  }

  String _ageLabel(int months) {
    if (months < 1) return 'newborn';
    if (months < 24) return '$months month${months == 1 ? '' : 's'}';
    final y = months ~/ 12;
    final m = months % 12;
    return m == 0 ? '$y years' : '$y years $m month${m == 1 ? '' : 's'}';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _store,
      builder: (context, _) {
        final children = _store.children;
        final activeId = _store.active.id;

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

                for (final c in children) ...[
                  _childRow(context, c, c.id == activeId),
                  const SizedBox(height: 10),
                ],

                // add a child
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () => _addChild(context),
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
      },
    );
  }

  Widget _childRow(BuildContext context, Child c, bool active) {
    final row = Row(children: [
      _avatar(),
      const SizedBox(width: 14),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(c.name, style: ppJakarta(16)),
          const SizedBox(height: 2),
          _subtitle(c, active),
        ]),
      ),
      if (active)
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: ppPurple, shape: BoxShape.circle),
          child: const Text('✓', style: TextStyle(color: Colors.white, fontSize: 12)),
        )
      else
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFD8C8EA), width: 1.5)),
        ),
    ]);

    if (active) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: ppPanel,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: ppPanelDiv),
        ),
        child: row,
      );
    }

    return GestureDetector(
      onTap: () async {
        await _store.switchTo(c.id);
        if (!context.mounted) return;
        Navigator.of(context).maybePop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Showing ${c.name} now'), behavior: SnackBarBehavior.floating),
        );
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(14),
        color: Colors.transparent,
        child: row,
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
