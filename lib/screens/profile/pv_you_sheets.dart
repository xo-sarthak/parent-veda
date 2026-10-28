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
import '../../screens/post_pregnancy/baby_naming_home_screen.dart';
import '../../screens/post_pregnancy/pp_names_data.dart' show NameMatchStore;
// import '../../services/dear_baby_vault_store.dart'; // unused since the birth moved to stage_moves.dart (2026-10-24), kept for revert
// import '../../services/family_timeline.dart'; // unused since the birth moved to stage_moves.dart (2026-10-24), kept for revert
// import '../../services/life_stage_store.dart'; // unused since the birth moved to stage_moves.dart (2026-10-24), kept for revert
// import '../../services/pregnancy_controller.dart'; // unused since the birth moved to stage_moves.dart (2026-10-24), kept for revert
import '../../services/family_profile.dart';
import '../../services/pv_order_store.dart';
import '../../services/stage_moves.dart';
import '../../theme/pv_fonts.dart';
import '../../widgets/pv_toast.dart';
import '../products/pv_checkout_screen.dart' show PvAddressForm;
import '../ttc/doors/ttc_tab_art.dart' show TtcTabArt, TtcTabMark;
import '../skilling/sk_grown_up_gate.dart';
import '../skilling/sk_grown_up_screen.dart';
import '../v2/v2_palette.dart';
import 'pv_you_chrome.dart';

// Weeks of pregnancy at birth when she was born early (before 37 weeks),
// read from the due date we already hold - the same field onboarding fills
// from its "born early?" answer. Null when on time, or with no real due date.
// Moved to lib/services/stage_moves.dart (`bornWeeksFor`, `recordBirth`),
// 2026-10-24, so onboarding records a birth the same way. Kept for revert:
// int? _bornWeeksFor(DateTime dob) {
//   final c = PregnancyController.current;
//   if (c == null || !c.isDueDateSet) return null;
//   final daysEarly = c.dueDate.difference(dob).inDays;
//   final weeks = (280 - daysEarly) ~/ 7;
//   return weeks < 37 && weeks >= 20 ? weeks : null;
// }

// /// The birth as the onboarding join records it (2026-10-23): the stage starts
// /// on the birthday, not the day she tapped, and the family story gets the day.
// /// The callers' own `setStage(parenting)` after this is a no-op, because the
// /// store ignores re-declaring the same stage.
// void _recordBirth(DateTime dob, String name) {
//   LifeStageStore.instance.setStage(LifeStage.parenting, at: dob);
//   final title = name.trim().isEmpty ? 'Baby was born' : '$name was born';
//   FamilyTimeline.instance.add(
//     id: 'baby_born',
//     stage: LifeStage.parenting,
//     kind: TimelineKind.milestone,
//     titleEn: title,
//     titleHi: title,
//     detailEn: 'The day pregnancy ended and parenting began.',
//     on: dob,
//   );
// }

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
  // The birth's two optional answers (final review item 12, 2026-10-28).
  BirthMode? mode;
  bool? nicu;
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
            // Scrolls since the birth's two optional rows (item 12), so the
            // sheet never runs off a small phone with the keyboard up.
            child: SingleChildScrollView(
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
                    // P2 N4 (2026-10-28): the names she kept in Baby names,
                    // offered, never filled in for her. A tap puts one in the
                    // field, which stays hers to change.
                    if (arrival)
                      _BirthNameOffer(
                        current: name.text.trim(),
                        onPick: (n) => setSheet(() {
                          name.text = n;
                          name.selection = TextSelection.collapsed(
                            offset: n.length,
                          );
                        }),
                        onBack: () => setSheet(() {}),
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
                          // A birth just happened: the last two years, not
                          // eighteen (2026-10-23). An older child keeps the
                          // wide range.
                          firstDate: arrival
                              ? DateTime(now.year - 2, now.month, now.day)
                              : DateTime(now.year - 18),
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
                            // ⚠️ FLEXIBLE (2026-10-02, found while reproducing
                            // the add-child red screen): "Date of birth (or the
                            // closest you know)" is about 266 wide at 14.5 and
                            // the row has 264 on a 360dp phone, so it ran off
                            // the sheet, and further at a larger text size. It
                            // wraps to a second line instead. Kept for revert:
                            // the same Text without the Expanded.
                            Expanded(
                              child: Text(
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
                            ),
                          ],
                        ),
                      ),
                    ),
                    // ⚠️ THE BIRTH, TWO OPTIONAL ROWS (final review item 12,
                    // 2026-10-28). The sheet saved name, sex and date only, so a
                    // mother who came through pregnancy in the app never told
                    // the doors about a C-section or a NICU stay, and never got
                    // the pages that move up for them. Optional, and the line
                    // under them says what the answers change. Skipping saves
                    // nothing.
                    if (arrival) ...[
                      const SizedBox(height: 18),
                      Text(
                        'How was your baby born?',
                        style: pvManrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: p.ink1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final (m, label) in [
                            (BirthMode.normal, 'Normal'),
                            (BirthMode.cSection, 'C-section'),
                            (BirthMode.notSaid, 'Rather not say'),
                          ])
                            PvChip(
                              key: ValueKey('pv_birth_mode_${m.name}'),
                              label: label,
                              selected: mode == m,
                              onTap: () =>
                                  setSheet(() => mode = mode == m ? null : m),
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Did your baby need the NICU?',
                        style: pvManrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: p.ink1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          for (final (v, label) in [
                            (true, 'Yes'),
                            (false, 'No'),
                          ])
                            PvChip(
                              key: ValueKey('pv_birth_nicu_$v'),
                              label: label,
                              selected: nicu == v,
                              onTap: () =>
                                  setSheet(() => nicu = nicu == v ? null : v),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Both optional. They bring the recovery and NICU '
                        'pages forward for you.',
                        style: pvManrope(
                          fontSize: 12.5,
                          height: 1.45,
                          color: p.ink2,
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    PvCommit(
                      // Change 5 (2026-09-28), right for every stage. Kept for
                      // revert: 'Add'.
                      label: arrival ? 'Open the parenting home' : 'Add child',
                      onTap: ok
                          ? () async {
                              final child = await ChildProfileStore.instance
                                  .addChild(
                                    name: name.text.trim(),
                                    // A skipped "Boy or girl" is NOT a boy - the
                                    // same fix onboarding has had since 2026-10-07
                                    // (here 2026-10-23). Kept for revert:
                                    // `isBoy: isBoy ?? true,` alone.
                                    isBoy: isBoy ?? true,
                                    sexGiven: isBoy != null,
                                    dob: dob!,
                                    bornWeeks: arrival
                                        ? bornWeeksFor(dob!)
                                        : null,
                                    birthMode: arrival ? mode?.name : null,
                                  );
                              // Item 12: the birth's answers on this child, as
                              // onboarding saves them, and the twins she told
                              // pregnancy about, carried over (derived, never
                              // asked again).
                              if (arrival) {
                                final fam = FamilyProfileStore.instance;
                                if (mode != null) {
                                  fam.setBirthDetails(mode: mode);
                                }
                                if (nicu != null) fam.setBirth(nicu: nicu);
                                if (fam.expectingTwins) {
                                  fam.setBirth(multiple: true);
                                }
                              }
                              // The birth: stage on the birthday, the story,
                              // and the Dear Baby letters (STILL-OPEN §83.2),
                              // in one move shared with onboarding
                              // (stage_moves.dart, 2026-10-24). Only the
                              // arrival does: an older child added later is
                              // not this baby. Kept for revert:
                              //   if (arrival) _recordBirth(dob!, child.name);
                              //   if (arrival) {
                              //     await DearBabyVaultStore.instance.markBorn(
                              //       dob: dob!,
                              //       childId: child.id,
                              //       name: child.name,
                              //     );
                              //   }
                              if (arrival) {
                                await recordBirth(
                                  dob: dob!,
                                  name: child.name,
                                  childId: child.id,
                                );
                              }
                              if (ctx.mounted) Navigator.of(ctx).pop(true);
                            }
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
  // ⚠️ NOT DISPOSED THE MOMENT THE SHEET CLOSES (2026-10-02, the user: a red
  // screen "'_dependents.isEmpty': is not true" while adding an older child).
  // The future completes when the route is popped, but the sheet is still on
  // screen for its exit animation with its field attached to [name]. The
  // same cause as Delete account; the name editor waits for the same reason.
  // Kept for revert: `name.dispose();` here.
  Future<void>.delayed(const Duration(milliseconds: 600), name.dispose);
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

/// Removed children, with Restore (sync log step 7, 2026-10-20). Removing a
/// child is a soft delete: the child is hidden on both phones and every record
/// about them is kept, so a restore brings everything back. The pattern is
/// Messages' "Recently Deleted" and Notion's Trash: one line that says what is
/// kept, then each child as a row with its own Restore.
Future<void> showPvRemovedChildrenSheet(
  BuildContext context, {
  required Color tint,
}) async {
  final p = pvStorePalette;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: p.ground,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => ListenableBuilder(
      listenable: ChildProfileStore.instance,
      builder: (ctx, _) {
        final gone = ChildProfileStore.instance.removedChildren;
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
                        'Removed children',
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
                const SizedBox(height: 8),
                const PvQuietLine(
                  'Their records are kept. Restore a child and everything comes back, on your partner\'s phone too.',
                ),
                const SizedBox(height: 8),
                if (gone.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: PvQuietLine('Nothing to restore.'),
                  ),
                for (final c in gone)
                  PvProfileRow(
                    key: ValueKey('pv_removed_child_${c.id}'),
                    mark: TtcTabArt(mark: TtcTabMark.sun, tint: tint),
                    title: c.name,
                    trailing: PvProfilePill(
                      key: ValueKey('pv_restore_child_${c.id}'),
                      label: 'Restore',
                      onTap: () async {
                        await ChildProfileStore.instance.restoreChild(c.id);
                        if (!ctx.mounted) return;
                        pvToast(
                          ctx,
                          '${c.name} is back, with their records.',
                          kind: PvToastKind.done,
                        );
                        if (ChildProfileStore
                            .instance
                            .removedChildren
                            .isEmpty) {
                          Navigator.of(ctx).pop();
                        }
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

/// P2 N4 (2026-10-28): the birth sheet offers the name she chose in Baby
/// names (or up to three from her shortlist), and a way to look for one if
/// she has not. Only an offer: the field stays empty until she taps.
class _BirthNameOffer extends StatelessWidget {
  const _BirthNameOffer({
    required this.current,
    required this.onPick,
    required this.onBack,
  });
  final String current;
  final ValueChanged<String> onPick;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    final store = NameMatchStore.instance;
    final crowned = store.crowned;
    final names = crowned.isNotEmpty
        ? [crowned]
        : store.liked.take(3).toList();
    return Padding(
      key: const ValueKey('pv_birth_name_offer'),
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (names.isNotEmpty) ...[
            Text(
              crowned.isNotEmpty
                  ? 'The name you chose. Use it, or write another.'
                  : 'From your shortlist. Use one, or write another.',
              style: pvManrope(fontSize: 12.5, height: 1.4, color: p.ink2),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final n in names)
                  PvChip(
                    key: ValueKey('pv_birth_name_$n'),
                    label: n,
                    selected: current == n,
                    onTap: () => onPick(n),
                  ),
              ],
            ),
          ],
          TextButton(
            key: const ValueKey('pv_birth_find_name'),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              foregroundColor: p.ink1,
            ),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute<void>(
                  settings: const RouteSettings(name: 'you/birth/baby_names'),
                  builder: (_) => const BabyNamingHomeScreen(),
                ),
              );
              onBack();
            },
            child: Text(
              names.isEmpty ? 'Still deciding? Find a name' : 'See more names',
              style: pvManrope(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: p.ink1,
              ).copyWith(decoration: TextDecoration.underline),
            ),
          ),
        ],
      ),
    );
  }
}
