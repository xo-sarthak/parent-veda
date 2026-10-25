// =============================================================================
//  The family switch: "Aarav ▾" in the centre of every home's header
//  (2026-10-25, STAGE-TRANSITIONS "Switching profiles", phase 1)
// -----------------------------------------------------------------------------
//  Each pregnancy and each child is its own profile, and the open profile
//  picks the home: her trying opens TTC, a pregnancy opens Pregnancy, a child
//  up to 5 opens Parenting, a child of 6 or more opens the learning space.
//  Switching changes what she sees, never what is saved. The pattern is What
//  to Expect's stage dropdown and theAsianparent's Pregnancy/Kids switcher
//  (competitor walks, 2026-09-30).
//
//  ⚠️ WHERE IT SITS, AND WHY. The user ruled the hero out ("over
//  clutterning") and picked the header's centre: the name takes the date's
//  place and the date moves under it, smaller. No button joins the row (a
//  third one on the right overflowed a 360pt phone), and the row is the same
//  on every home, so the switch is in one place everywhere.
//
//  ⚠️ ONE PROFILE DRAWS THE DATE ALONE, EXACTLY AS BEFORE. A name with a
//  chevron that opens a list of one is a control that does nothing. Adding a
//  child stays in You; the moment there are two, the name appears.
//
//  ⚠️ THE STAGE'S OWN PROFILE IS THE ROOT of the navigator; every other
//  profile's home is pushed over it, the same move `openStageDoor` already
//  makes (no stage change). "Add a pregnancy" (F2, 2026-10-25, after R1
//  made pregnancies records) is the one row here that moves the stage: to
//  pregnancy, so the new pregnancy is the root and the children open over it
//  (pv_add_pregnancy.dart, `startPregnancyFromFamily`). Kept for revert, the
//  phase 1 note: "What phase 1 does NOT do ... 'Add a pregnancy' from
//  parenting. That is R1, then phase 2."
// =============================================================================

import 'package:flutter/material.dart';

import '../../localization/app_language.dart';
import '../../services/life_stage_store.dart';
import '../../services/pregnancy_controller.dart';
import '../../services/pregnancy_ended_store.dart';
import '../../services/stage_gateway.dart';
import '../../theme/pv_fonts.dart';
import '../../widgets/pv_feedback.dart';
import '../post_pregnancy/pp_child_profile.dart';
import '../../services/pregnancy_records.dart';
import '../pregnancy/pregnancy_kept_screen.dart' show openPregnancyKept, pregnancyKeptTitle;
import '../profile/pv_you_sheets.dart' show showPvAddChildSheet;
import '../skilling/sk_bands.dart' show kSkAgeFloor;
import '../skilling/sk_child_store.dart';
import '../skilling/skilling_preview_screen.dart';
import 'pv_add_pregnancy.dart' show addPregnancyOffered, openAddPregnancy, kAddPregnancyTitle;
import 'v2_palette.dart';

/// Which home is on screen. The caller says so; the switch never guesses
/// from the route.
enum FamilyHome { trying, pregnancy, parenting, learning }

enum FamilyProfileKind { trying, pregnancy, child }

class FamilyProfile {
  const FamilyProfile({
    required this.id,
    required this.kind,
    required this.name,
    required this.line,
    required this.home,
  });

  /// 'trying', 'pregnancy', or the child's id.
  final String id;
  final FamilyProfileKind kind;
  final String name;

  /// "7 months · Parenting", "Week 9 · Pregnancy".
  final String line;
  final FamilyHome home;
}

/// A child's age in the words a parent uses: weeks, then months, then years.
@visibleForTesting
String familyAgeWords(DateTime dob, DateTime now) {
  final days = now.difference(dob).inDays;
  if (days < 0) return 'Not born yet';
  if (days < 7 * 8) {
    final w = days ~/ 7;
    return w <= 0 ? 'Newborn' : '$w ${w == 1 ? 'week' : 'weeks'}';
  }
  var months = (now.year - dob.year) * 12 + now.month - dob.month;
  if (now.day < dob.day) months--;
  if (months < 24) return '$months ${months == 1 ? 'month' : 'months'}';
  final y = months ~/ 12;
  return '$y years';
}

/// Whole years, for the learning-space line.
@visibleForTesting
int familyYears(DateTime dob, DateTime now) {
  var y = now.year - dob.year;
  if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) y--;
  return y < 0 ? 0 : y;
}

/// Pure, so it is tested without stores: the family's profiles, in the
/// order the sheet draws them: her trying or the pregnancy first, then the
/// children in the order she added them.
@visibleForTesting
List<FamilyProfile> familyProfilesFrom({
  required LifeStage stage,
  required bool pregnancyEnded,
  required int? pregnancyWeek,
  required List<Child> children,
  required String skillingName,
  required DateTime now,
  bool learningOpen = true,
}) {
  final out = <FamilyProfile>[];
  if (stage == LifeStage.tryingToConceive) {
    out.add(const FamilyProfile(
        id: 'trying',
        kind: FamilyProfileKind.trying,
        name: 'Trying',
        line: 'Your cycle, and everything for trying',
        home: FamilyHome.trying));
  }
  if (stage == LifeStage.pregnancy && !pregnancyEnded) {
    out.add(FamilyProfile(
        id: 'pregnancy',
        kind: FamilyProfileKind.pregnancy,
        name: 'Baby-to-be',
        line: pregnancyWeek == null ? 'Pregnancy' : 'Week $pregnancyWeek · Pregnancy',
        home: FamilyHome.pregnancy));
  }
  for (final c in children) {
    // ⚠️ SIX OR MORE OPENS THE LEARNING SPACE ONLY ONCE A GROWN-UP SAID YES
    // (F4/F5, 2026-10-25, the user: "only show it to the parent once they
    // want to see it"). Until then the child's home is Parenting, where the
    // card asks. Kept for revert:
    //   final learning = familyYears(c.dob, now) >= kSkAgeFloor;
    final six = familyYears(c.dob, now) >= kSkAgeFloor;
    final learning = six && learningOpen;
    out.add(FamilyProfile(
        id: c.id,
        kind: FamilyProfileKind.child,
        name: c.name,
        line: '${familyAgeWords(c.dob, now)} · '
            '${learning ? 'Learning space' : six ? 'Parenting · learning space ready' : 'Parenting'}',
        home: learning ? FamilyHome.learning : FamilyHome.parenting));
  }
  // A family that joined at skilling may have no parenting record of the
  // child: the learning space's own record stands in.
  if (stage == LifeStage.skilling &&
      !out.any((x) => x.home == FamilyHome.learning) &&
      skillingName.isNotEmpty) {
    final y = SkChildStore.instance.ageYears;
    out.add(FamilyProfile(
        id: 'skilling',
        kind: FamilyProfileKind.child,
        name: skillingName,
        line: '${y == null ? '' : '$y years · '}Learning space',
        home: FamilyHome.learning));
  }
  return out;
}

List<FamilyProfile> familyProfiles() {
  final kids = ChildProfileStore.instance;
  return familyProfilesFrom(
    stage: LifeStageStore.instance.stage ?? LifeStage.pregnancy,
    pregnancyEnded: PregnancyEndedStore.instance.ended,
    pregnancyWeek: PregnancyController.current?.isDueDateSet == true
        ? PregnancyController.current!.currentWeek
        : null,
    children: kids.hasRealChild ? kids.children : const [],
    skillingName: SkChildStore.instance.name,
    now: DateTime.now(),
    learningOpen: SkChildStore.instance.consented,
  );
}

/// The profile this home is showing: the stage's own one, or the active
/// child on Parenting and the learning space.
@visibleForTesting
FamilyProfile? openProfileIn(List<FamilyProfile> all, FamilyHome here, String? activeChildId) {
  for (final x in all) {
    if (x.home != here) continue;
    if (x.kind != FamilyProfileKind.child || x.id == activeChildId || x.id == 'skilling') return x;
  }
  for (final x in all) {
    if (x.home == here) return x;
  }
  return null;
}

/// The stage's own home is the navigator's root; this is it.
FamilyHome? _rootHome() => switch (LifeStageStore.instance.stage) {
      LifeStage.tryingToConceive => FamilyHome.trying,
      LifeStage.pregnancy => FamilyHome.pregnancy,
      LifeStage.parenting => FamilyHome.parenting,
      LifeStage.skilling => FamilyHome.learning,
      null => FamilyHome.pregnancy,
    };

/// Open [to]'s home from [here]. Never changes the stage (test M40's
/// allow-list stays as it is).
void openFamilyProfile(BuildContext context, FamilyProfile to, FamilyHome here) {
  final nav = Navigator.of(context);
  if (to.kind == FamilyProfileKind.child && to.id != 'skilling') {
    ChildProfileStore.instance.switchTo(to.id);
  }
  if (to.home == here) return; // the same home redraws for the new child
  if (to.home == _rootHome()) {
    // Back to the stage's own home, which is already underneath.
    nav.popUntil((r) => r.isFirst);
    return;
  }
  switch (to.home) {
    case FamilyHome.parenting:
      openStageDoor(context, StageDoor.parenting);
    case FamilyHome.pregnancy:
      openStageDoor(context, StageDoor.pregnancy);
    case FamilyHome.trying:
      openStageDoor(context, StageDoor.tryingToConceive);
    case FamilyHome.learning:
      nav.push(MaterialPageRoute<void>(
        settings: const RouteSettings(name: 'skilling'),
        builder: (_) => SkillingPreviewScreen(
            lang: PregnancyController.current?.language ?? AppLanguage.english),
      ));
  }
}

/// The header's centre: the date alone with one profile, "Name ▾" over the
/// date with two or more.
class PvFamilyTitle extends StatelessWidget {
  const PvFamilyTitle({
    super.key,
    required this.p,
    required this.here,
    required this.dateText,
    required this.date,
  });

  final V2Palette p;
  final FamilyHome here;

  /// The date's words ("25 October"), drawn small under the name.
  final String dateText;

  /// The home's own date, drawn exactly as before when there is one profile.
  final Widget date;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: Listenable.merge([
          ChildProfileStore.instance,
          LifeStageStore.instance,
          SkChildStore.instance,
        ]),
        builder: (context, _) {
          // Whether a grown-up opened the learning space is in SkChildStore,
          // which loads lazily; once loaded it notifies and this redraws.
          SkChildStore.instance.load();
          final all = familyProfiles();
          if (all.length < 2) return date;
          final open = openProfileIn(all, here, ChildProfileStore.instance.activeChildId);
          final name = open?.name ?? all.first.name;
          return Semantics(
            button: true,
            label: 'Whose home: $name. Switch',
            child: PvPress(child: GestureDetector(
              key: const ValueKey('pv_family_switch'),
              behavior: HitTestBehavior.opaque,
              onTap: () => showPvFamilySheet(context, p: p, here: here),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(name,
                          maxLines: 1,
                          style: pvManrope(fontSize: 15, fontWeight: FontWeight.w800, height: 1.15, color: p.ink1)),
                      const SizedBox(width: 2),
                      Icon(Icons.expand_more_rounded, size: 18, color: p.ink1),
                    ]),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(dateText,
                        key: const ValueKey('pv_family_switch_date'),
                        maxLines: 1,
                        style: pvManrope(fontSize: 11.5, fontWeight: FontWeight.w700, color: p.ink2)),
                  ),
                ]),
              ),
            )),
          );
        },
      );
}

/// "Your family": every profile, the open one ticked, and Add a child.
Future<void> showPvFamilySheet(BuildContext context,
    {required V2Palette p, required FamilyHome here}) async {
  final all = familyProfiles();
  final open = openProfileIn(all, here, ChildProfileStore.instance.activeChildId);
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: p.ground,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) {
      Widget group(String t) => Padding(
            padding: const EdgeInsets.fromLTRB(8, 14, 8, 4),
            child: Text(t.toUpperCase(),
                style: pvManrope(fontSize: 11.5, fontWeight: FontWeight.w800, letterSpacing: 0.9, color: p.ink3)),
          );
      Widget row(FamilyProfile x) => ListTile(
            key: ValueKey('pv_family_switch_${x.id}'),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            leading: CircleAvatar(
              radius: 20,
              backgroundColor: p.surfaceAlt,
              child: Icon(
                  switch (x.home) {
                    FamilyHome.trying => Icons.water_drop_outlined,
                    FamilyHome.pregnancy => Icons.favorite_border_rounded,
                    FamilyHome.parenting => Icons.child_care_rounded,
                    FamilyHome.learning => Icons.menu_book_outlined,
                  },
                  size: 20,
                  color: p.ink1),
            ),
            title: Text(x.name, style: pvManrope(fontSize: 15, fontWeight: FontWeight.w700, color: p.ink1)),
            subtitle: Text(x.line, style: pvManrope(fontSize: 13, fontWeight: FontWeight.w600, color: p.ink2)),
            trailing: x.id == open?.id ? Icon(Icons.check_rounded, color: p.ink1) : null,
            onTap: () {
              Navigator.of(ctx).pop();
              if (x.id == open?.id) return;
              openFamilyProfile(context, x, here);
            },
          );
      final own = all.where((x) => x.kind != FamilyProfileKind.child).toList();
      final kids = all.where((x) => x.kind == FamilyProfileKind.child).toList();
      final kept = PregnancyRecords.instance.kept;
      return SafeArea(
        top: false,
        // Scrolls once the family (and what is kept) is taller than the sheet.
        child: SingleChildScrollView(
         child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 2),
              child: Text('Your family',
                  style: pvFraunces(fontSize: 22, fontWeight: FontWeight.w600, color: p.ink1)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
              child: Text('Each one keeps their own home. Switching changes what you see, never what is saved.',
                  style: pvManrope(fontSize: 13.5, height: 1.45, color: p.ink2)),
            ),
            if (own.isNotEmpty) ...[group(own.first.kind == FamilyProfileKind.trying ? 'You' : 'Pregnancy'), ...own.map(row)],
            if (kids.isNotEmpty) ...[group('Children'), ...kids.map(row)],
            group('Add'),
            ListTile(
              key: const ValueKey('pv_family_switch_add_child'),
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              leading: CircleAvatar(
                radius: 20,
                backgroundColor: p.ground,
                child: Icon(Icons.add_rounded, color: p.ink2),
              ),
              title: Text('Add a child', style: pvManrope(fontSize: 15, fontWeight: FontWeight.w700, color: p.ink1)),
              subtitle: Text('Their own records and home',
                  style: pvManrope(fontSize: 13, fontWeight: FontWeight.w600, color: p.ink2)),
              onTap: () {
                Navigator.of(ctx).pop();
                showPvAddChildSheet(context);
              },
            ),
            // ---- ADD A PREGNANCY (F2, 2026-10-25) ----
            // Right under Add a child, where What to Expect and theAsianparent
            // put it. Hers only, and only while no pregnancy is going.
            if (addPregnancyOffered())
              ListTile(
                key: const ValueKey('pv_family_switch_add_pregnancy'),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                leading: CircleAvatar(
                  radius: 20,
                  backgroundColor: p.ground,
                  child: Icon(Icons.add_rounded, color: p.ink2),
                ),
                title: Text(kAddPregnancyTitle,
                    style: pvManrope(fontSize: 15, fontWeight: FontWeight.w700, color: p.ink1)),
                subtitle: Text('Its own weeks, beside your children',
                    style: pvManrope(fontSize: 13, fontWeight: FontWeight.w600, color: p.ink2)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  openAddPregnancy(context);
                },
              ),
            // ---- KEPT FOR YOU (R1, 2026-10-25) ----
            // A pregnancy that has ended, quietly at the foot: never a
            // switchable profile and never in the header (the user's word),
            // so she goes to it rather than running into it.
            if (kept.isNotEmpty) ...[
              group('Kept for you'),
              for (final r in kept)
                ListTile(
                  key: ValueKey('pv_family_kept_${r.id}'),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  leading: CircleAvatar(
                    radius: 20,
                    backgroundColor: p.ground,
                    child: Icon(Icons.auto_stories_outlined, size: 20, color: p.ink2),
                  ),
                  title: Text(pregnancyKeptTitle(r),
                      style: pvManrope(fontSize: 15, fontWeight: FontWeight.w700, color: p.ink1)),
                  subtitle: Text('To look at, or delete if you want to',
                      style: pvManrope(fontSize: 13, fontWeight: FontWeight.w600, color: p.ink2)),
                  trailing: Icon(Icons.chevron_right_rounded, color: p.ink3),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    openPregnancyKept(context, r);
                  },
                ),
            ],
          ]),
         ),
        ),
      );
    },
  );
}
