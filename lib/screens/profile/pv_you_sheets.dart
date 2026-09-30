// =============================================================================
//  The You screen's sheets — add a child, addresses, her keepsakes
// -----------------------------------------------------------------------------
//  Sheets, not screens, for the three short jobs that should not take her
//  away from the page (the base-UI sheet: ground, top radius 24, close
//  top-right, action pinned).
// =============================================================================

import 'dart:async';

import 'package:flutter/material.dart';

import '../../screens/post_pregnancy/pp_child_profile.dart';
import '../../services/pv_order_store.dart';
import '../../theme/pv_fonts.dart';
import '../products/pv_checkout_screen.dart' show PvAddressForm;
import '../skilling/sk_grown_up_gate.dart';
import '../skilling/sk_grown_up_screen.dart';
import '../v2/v2_palette.dart';
import 'pv_you_chrome.dart';

/// Name · boy/girl · date of birth → `ChildProfileStore.addChild`. With
/// [arrival] the copy is the birth's ("Welcome to the world"), and the caller
/// moves the stage. Returns true when a child was added.
Future<bool> showPvAddChildSheet(
  BuildContext context, {
  bool arrival = false,
}) async {
  final p = pvStorePalette;
  final name = TextEditingController();
  bool? isBoy;
  DateTime? dob;
  final added = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: p.ground,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSheet) {
        final ok = name.text.trim().isNotEmpty && dob != null;
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          arrival ? 'Welcome to the world' : 'Add a child',
                          style: pvFraunces(
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                            color: p.ink1,
                          ),
                        ),
                      ),
                      PvRoundIcon(
                        icon: Icons.close_rounded,
                        size: 34,
                        onTap: () => Navigator.of(ctx).pop(false),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    arrival
                        ? 'Three things and the parenting home opens. Everything from the pregnancy stays yours.'
                        : 'Their own page, their own records. Nothing about anyone else moves.',
                    style: pvManrope(
                      fontSize: 13.5,
                      height: 1.45,
                      color: p.ink2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: name,
                    autofocus: true,
                    textCapitalization: TextCapitalization.words,
                    onChanged: (_) => setSheet(() {}),
                    style: pvManrope(fontSize: 15, color: p.ink1),
                    decoration: _dec(p, 'Name'),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      PvChip(
                        label: 'Girl',
                        selected: isBoy == false,
                        onTap: () => setSheet(() => isBoy = false),
                      ),
                      PvChip(
                        label: 'Boy',
                        selected: isBoy == true,
                        onTap: () => setSheet(() => isBoy = true),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () async {
                      final now = DateTime.now();
                      final d = await showDatePicker(
                        context: ctx,
                        initialDate: dob ?? now,
                        firstDate: DateTime(now.year - 18),
                        lastDate: now,
                      );
                      if (d != null) setSheet(() => dob = d);
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: kPvLine),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.cake_outlined, size: 18, color: p.ink2),
                          const SizedBox(width: 10),
                          Text(
                            dob == null
                                ? (arrival
                                      ? 'Date of birth'
                                      : 'Date of birth (or the closest you know)')
                                : _date(dob!),
                            style: pvManrope(
                              fontSize: 14.5,
                              color: dob == null ? p.ink3 : p.ink1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  PvCommit(
                    // Change 5 (2026-09-28), right for every stage. Kept for
                    // revert: 'Add'.
                    label: arrival ? 'Open the parenting home' : 'Add child',
                    onTap: ok
                        ? () async {
                            await ChildProfileStore.instance.addChild(
                              name: name.text.trim(),
                              isBoy: isBoy ?? true,
                              dob: dob!,
                            );
                            if (ctx.mounted) Navigator.of(ctx).pop(true);
                          }
                        : null,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
  name.dispose();
  return added ?? false;
}

InputDecoration _dec(V2Palette p, String hint) => InputDecoration(
  hintText: hint,
  hintStyle: pvManrope(fontSize: 14, color: p.ink3),
  filled: true,
  fillColor: Colors.white,
  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: const BorderSide(color: kPvLine),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide(color: p.ink1, width: 1.4),
  ),
);

String _date(DateTime d) {
  const m = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${d.day} ${m[d.month - 1]} ${d.year}';
}

/// The address book: the saved addresses with default and remove, plus Add.
/// The checkout's form is reused (`PvAddressForm`), so an address added
/// here and one added at checkout are the same thing in the same store.
Future<void> showPvAddressesSheet(BuildContext context) async {
  final p = pvStorePalette;
  // ⚠️ LOCAL-FIRST: THE SHEET OPENS AT ONCE (2026-09-30, found by
  // test/pv_profile_walk_test.dart). `init()` loads the phone's copy AND then
  // awaits the cloud sync, so awaiting it here made the tap wait on the
  // network: slow on a weak signal, and never opening when the sync hung.
  // The sheet listens to the store, so saved addresses appear the moment the
  // local copy loads, and the sync finishes behind it. Kept for revert:
  //   await PvOrderStore.instance.init();
  //   if (!context.mounted) return;
  unawaited(PvOrderStore.instance.init());
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: p.ground,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => ListenableBuilder(
      listenable: PvOrderStore.instance,
      builder: (ctx, _) {
        final store = PvOrderStore.instance;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Addresses',
                        style: pvFraunces(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          color: p.ink1,
                        ),
                      ),
                    ),
                    PvRoundIcon(
                      icon: Icons.close_rounded,
                      size: 34,
                      onTap: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // An empty list is one quiet line, not a lavender slab
                // (2026-09-29), as the store's empty shelf is. Kept for
                // revert: PvWell(child: Text(..., pvManrope(fontSize: 13.5,
                //     height: 1.45, color: p.ink2))).
                if (store.addresses.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: PvQuietLine(
                      'No address yet. Add one here or at checkout — it is the same list.',
                    ),
                  ),
                for (final a in store.addresses)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: a.id == store.defaultAddress?.id
                            ? p.ink1
                            : kPvLine,
                        width: a.id == store.defaultAddress?.id ? 1.4 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    a.name,
                                    style: pvManrope(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: p.ink1,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: p.surfaceAlt,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      a.label,
                                      style: pvManrope(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w700,
                                        color: p.ink2,
                                      ),
                                    ),
                                  ),
                                  if (a.id == store.defaultAddress?.id) ...[
                                    const SizedBox(width: 6),
                                    Text(
                                      'Default',
                                      style: pvManrope(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: p.action,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                a.oneLine,
                                style: pvManrope(
                                  fontSize: 13,
                                  height: 1.4,
                                  color: p.ink2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: Icon(Icons.more_horiz_rounded, color: p.ink3),
                          onSelected: (v) {
                            if (v == 'default') store.setDefault(a.id);
                            if (v == 'remove') store.removeAddress(a.id);
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                              value: 'default',
                              child: Text('Make default'),
                            ),
                            PopupMenuItem(
                              value: 'remove',
                              child: Text('Remove'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
                PvSecondary(
                  label: 'Add an address',
                  icon: Icons.add_rounded,
                  onTap: () async {
                    final a = await showModalBottomSheet<PvAddress>(
                      context: ctx,
                      isScrollControlled: true,
                      backgroundColor: p.ground,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                      builder: (_) => const PvAddressForm(),
                    );
                    if (a != null) {
                      store.saveAddress(
                        a,
                        makeDefault: store.addresses.isEmpty,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

/// Her keepsakes live behind the grown-up gate on the skilling side; this
/// opens that section, asking the gate first (a child could be holding the
/// phone on any screen of the You tree).
Future<void> showPvKeepsakesSheet(BuildContext context) async {
  final passed = await skAskGrownUp(context);
  if (!passed || !context.mounted) return;
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => const SkGrownUpScreen(
        doorId: 'skilling_coding',
        section: SkGrownUpSection.settings,
        alreadyPassed: true,
      ),
      settings: const RouteSettings(name: 'sk/grown_up'),
    ),
  );
}
