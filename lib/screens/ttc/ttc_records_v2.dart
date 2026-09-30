// =============================================================================
//  Keep your reports together — rebuilt from the "TTC Records" design project
// -----------------------------------------------------------------------------
//  Options 1a, 1d, 1e, 1f, 1g and 1h. 1b (a date spine) and 1c (a dot chart)
//  were drawn and not taken; both notes below say why, because both were close.
//
//  ---------------------------------------------------------------------------
//  ⚠️ THE ONE RULE THAT OVERRIDES EVERY OTHER DECISION HERE
//  ---------------------------------------------------------------------------
//
//  **Nothing on this screen interprets a value.** No normal range, no high or
//  low, no red, no green, no "this looks fine". The app files results; the
//  clinician reads them. A trend of her own three readings with the dates is a
//  description and is allowed; the same three with a shaded band behind them is
//  a second opinion from a phone.
//
//  It is the strictest rule in this part of the product because it is the
//  easiest one to break by being helpful. Every colour choice below is
//  deliberately neutral for that reason — the hue is chrome, never a verdict.
//
//  ---------------------------------------------------------------------------
//  ⚠️ WHY GROUPED BY TEST AND NOT BY DATE (1a over 1b)
//  ---------------------------------------------------------------------------
//
//  The screen this replaces was a flat, date-ordered list, and it could not
//  answer any of the three questions somebody walking into an appointment
//  actually has: has this changed, what is missing, and which of these is his.
//
//  Grouping answers all three at once. The direction sits on the row before
//  anything is tapped; a coverage block can name what has not been added,
//  because the rows are the same shape as the library's list; and ownership
//  becomes a property of the row rather than a filter above it.
//
//  1b kept the date spine, and its argument is real — she remembers "the tests
//  before the last cycle" rather than "my AMH readings". If recency turns out
//  to matter more than direction, that is the design to go back to.
//
//  ---------------------------------------------------------------------------
//  ⚠️ WHY A READING STACK AND NOT A CHART (1d over 1c)
//  ---------------------------------------------------------------------------
//
//  Not aesthetics — data shape. This library holds a thyroid panel with a photo
//  and no typed number, an HSG whose result is a sentence, and a semen analysis
//  that is three values in one result. A dot chart renders none of them, so it
//  would be a view that works for the tests which happen to be single numbers
//  and breaks on the rest.
//
//  The stack holds all of it, survives two readings, and is the safer side of
//  the interpretation rule as a bonus rather than as its reason.
//
//  ---------------------------------------------------------------------------
//  ⚠️ REBUILT FOR USE, NOT PAINT — 2026-09-27, after the user walked build 13
//  ---------------------------------------------------------------------------
//
//  "You gave it the clothes of the new UI but the usability is all old." Three
//  things she hit, and what each became:
//
//  · **Add opened two sheets.** Now one page, `ttc_record_edit_screen.dart`;
//    the mechanism is written at its head.
//  · **A saved result could not be removed** ("6 September, no sperm found").
//    Every result now has "Change this result" (top right and at the foot of
//    its page) and "Remove this result", confirmed, with Undo. A whole test
//    (every reading of it) can be removed from its own page the same way.
//  · **Old pieces in new clothes.** Shadowed V1 cards (`TtcCard`) became the
//    tool shell's white-and-hairline blocks; the rows became one grouped list
//    with hairlines between them; the PDF moved from a small link inside an
//    appointment-only sheet to a row on the folder that is always there; the
//    "not added" tests each carry their own Add; a group's page has "Add a
//    new reading", which is the button the promise "the same test, twice"
//    never had.
//
//  Mobbin, 2026-09-27:
//   · MacroFactor "Expenditure" and "Scale Weight", a history as one grouped
//     list, value first, date under it, an edit mark per row:
//     https://mobbin.com/screens/4a2a61aa-cb4a-4135-8851-44046f9f3529
//     https://mobbin.com/screens/7332c4ed-5f2c-45af-ac89-03fe44216f6e
//   · Perplexity "Artifacts", Yours / Shared as a switch above one list, and
//     delete kept one step away from the row:
//     https://mobbin.com/screens/c67001cd-84ea-4f31-8a2f-f980f06e1932
//   · Mesh note detail, Share / Edit / Delete on the item's own page, the
//     delete confirmed:
//     https://mobbin.com/screens/d748e67d-ab33-4595-9cc8-49409dbd256d
//   · Perplexity connector page, the destructive action alone at the foot:
//     https://mobbin.com/screens/9e40d6ce-675b-4eff-a8ea-54a92b929ef1
//   · Zocdoc after-visit, "What you can do after your visit" as rows:
//     https://mobbin.com/screens/51f39cd3-2442-40e5-97ca-0fb69840d0ab
//  The gap analysis (Flo and What to Expect, v2) has no records vault on
//  either side to copy; what it does fix here is its rule for logging,
//  "Recorded, never interpreted", and "neither competitor shows empty
//  sections": every empty part of this folder carries its own action.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/pv_fonts.dart';
import '../../ttc/ttc_records_grouping.dart';
import '../../ttc/ttc_records_store.dart';
import '../../ttc/ttc_tests_data.dart';
import '../../localization/app_language.dart';
import '../../services/remote/storage_service.dart';
import '../../services/ttc_records_pdf.dart';
import '../products/pv_store_chrome.dart' show pvSnack;
import '../v2/v2_palette.dart' show V2PaletteStore, v2BlockTint;
import 'doors/ttc_tab_art.dart' show TtcTabArt, TtcTabMark;
import 'ttc_attachments.dart';
import 'ttc_common.dart';
import 'ttc_record_edit_screen.dart';
import 'ttc_strings.dart';
import 'ttc_tool_chrome.dart';
import 'ttc_tool_confirm.dart';
import 'ttc_tool_marks.dart' show TtcToolArt, TtcToolMark;

/// The clinical blue-grey this area wears.
const double kTtcRecordsHue = 206;

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String ttcRecordDate(DateTime d) =>
    '${d.day} ${_months[d.month - 1]} ${d.year}';

/// ⚠️ "YOU" AND "PARTNER", NOT INITIALS. The design draws an avatar with two
/// letters in it — Aarti, Rohan — and this app stores no names for either
/// person. A circle containing "Y" is worse than no circle, so ownership is a
/// small word instead. If names are ever collected, this is the one place to
/// change.
String ttcWhose(bool forPartner) => forPartner ? 'Partner' : 'You';

// =============================================================================
//  1a — the main screen
// =============================================================================

/// "Yours" or "Your partner's": the long form, for a sentence rather than a
/// tag. The same two words as the switch on the add page.
String ttcWhoseLong(bool forPartner) =>
    forPartner ? "Your partner's" : 'Yours';

/// One white block with a hairline: the tool shell's surface, in place of the
/// V1 `TtcCard` and its shadow (2026-09-27). Hairlines, not shadows, inside a
/// tool sheet; see the head of `ttc_tool_chrome.dart`.
class TtcRecordPanel extends StatelessWidget {
  const TtcRecordPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(16, 15, 16, 16),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: ttcLine),
        ),
        child: child,
      );
}

/// Rows in one block, a hairline between each: how a history list reads in
/// MacroFactor and Apple Health, rather than a stack of separate cards.
class TtcRecordList extends StatelessWidget {
  const TtcRecordList({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: ttcLine),
        ),
        child: Material(
          color: Colors.transparent,
          child: Column(children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0)
                const Divider(
                    height: 1, thickness: 1, color: ttcLine, indent: 16),
              children[i],
            ],
          ]),
        ),
      );
}

/// The small white pill in a tool's hero: "Add" on the folder, "Edit" on a
/// result. One shape for both, so the top-right corner means one thing.
class TtcRecordsHeroPill extends StatelessWidget {
  const TtcRecordsHeroPill({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: ttcBorder),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, size: 15, color: ttcTitleInk),
              const SizedBox(width: 5),
              Text(label,
                  style: ttcBody(12.5, color: ttcTitleInk, w: FontWeight.w800)),
            ]),
          ),
        ),
      );
}

/// The quiet destructive action at the foot of a page: red words, no fill.
class TtcRecordsRemoveButton extends StatelessWidget {
  const TtcRecordsRemoveButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Center(
        child: TextButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.delete_outline_rounded,
              // One danger red, DESIGN-SYSTEM §4.0 (2026-09-29). Kept for revert: Color(0xFFB42318)
              size: 17, color: Color(0xFFB3261E)),
          label: Text(label,
              style: pvManrope(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  // One danger red, DESIGN-SYSTEM §4.0 (2026-09-29). Kept for revert: Color(0xFFB42318)
                  color: const Color(0xFFB3261E))),
        ),
      );
}

class TtcRecordsBody extends StatelessWidget {
  const TtcRecordsBody({
    super.key,
    required this.onlyPartner,
    this.resultsOnly = false,
    this.summary,
  });

  /// null shows everyone, true only his, false only hers.
  final bool? onlyPartner;

  /// The Reports tile's narrowing — library results only. Kept from the screen
  /// this replaces; two tiles have always opened one folder.
  final bool resultsOnly;

  /// The count line and the whose-filter, drawn UNDER the heading
  /// (2026-09-29): they describe "Your results", so they sit inside that
  /// section instead of floating above its title.
  final Widget? summary;

  @override
  Widget build(BuildContext context) {
    final all = ttcGroupedRecords(resultsOnly: resultsOnly);
    final groups = onlyPartner == null
        ? all
        : all.where((g) => g.forPartner == onlyPartner).toList();
    final coverage = ttcRecordCoverage();

    if (all.isEmpty) return const TtcRecordsEmpty();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Was "What you've had done": said what the list is, in her words.
        // The one section heading (2026-09-29): `ttcSectionTitle` is the serif
        // now, see ttc_common.dart.
        ttcSectionTitle('Your results'),
        if (summary != null) ...[
          summary!,
          const SizedBox(height: 14),
        ],
        if (groups.isEmpty)
          // The filter narrowed to nothing. It says so, and offers the add
          // rather than leaving a blank under a heading.
          TtcRecordPanel(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      onlyPartner!
                          ? "Nothing filed as your partner's yet."
                          : 'Nothing filed as yours yet.',
                      style: ttcBody(13.5, h: 1.5)),
                  const SizedBox(height: 12),
                  TtcRecordsAction(
                      label: 'Add a result',
                      onTap: () => openTtcRecordEdit(context)),
                ]),
          )
        else
          TtcRecordList(children: [
            for (final g in groups) _GroupRow(group: g),
          ]),
        // 28 = DESIGN-SYSTEM §2.3 xl, "between sections". Kept for revert: 24.
        const SizedBox(height: 28),
        _Coverage(coverage: coverage),
      ],
    );
  }
}

/// One test, with every reading behind it. A row in the list, not a card.
class _GroupRow extends StatelessWidget {
  const _GroupRow({required this.group});
  final TtcRecordGroup group;

  @override
  Widget build(BuildContext context) {
    final latest = group.latest;
    final value = ttcRecordValue(latest);
    final typed = value.isNotEmpty;

    // One line under the value, as one Text so it wraps at 360pt instead of
    // running off the row (two Texts in a Row did, with a long first value).
    // ⚠️ "YOURS" / "YOUR PARTNER'S", NOT "You" / "Partner" (2026-09-29): the
    // row says whose in the words the add page uses. Kept for revert: each
    // line below began with `ttcWhose(group.forPartner)`.
    final whose = ttcWhoseLong(group.forPartner);
    final String under;
    if (group.repeated && ttcRecordValue(group.oldest).isNotEmpty) {
      under = '$whose · first was '
          '${ttcRecordValue(group.oldest)}, '
          '${_months[group.oldest.takenOn.month - 1]} '
          '${group.oldest.takenOn.year}';
    } else if (latest.note != null && latest.note!.trim().isNotEmpty) {
      under = '$whose · with a note';
    } else if (latest.attachments.isNotEmpty) {
      // The row says the report itself is in here, because that is the thing
      // she is actually looking for in a waiting room: the paper.
      under = '$whose · '
          '${latest.attachments.length} '
          '${latest.attachments.length == 1 ? 'photo' : 'photos'}';
    } else {
      under = whose;
    }

    return InkWell(
      onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
        settings: const RouteSettings(name: 'ttc/record'),
        builder: (_) => group.repeated
            ? TtcRecordTrendScreen(groupKey: group.key)
            : TtcRecordDetailScreen(recordId: latest.id),
      )),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ⚠️ A DRAWN MARK PER KIND OF TEST (2026-09-29): a blood test's
          // vial, a scan's magnifier, his test's heart, a folder for anything
          // typed by hand; the Tools rail's family (`TtcTabArt`), so a result
          // row looks like the rest of the app. The mark says what KIND of
          // test it is, never anything about the value.
          TtcRecordMark(
              kind: ttcRecordKindOf(group.testKey, group.label)),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Flexible(
                      child: Text(group.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: ttcJakarta(15)),
                    ),
                    if (group.repeated) ...[
                      const SizedBox(width: 8),
                      _Pill(text: '${group.count} readings'),
                    ],
                  ]),
                  const SizedBox(height: 5),
                  if (typed)
                    Text.rich(
                        TextSpan(children: [
                          TextSpan(
                              text: value,
                              style: ttcBody(14,
                                  color: ttcTitleInk, w: FontWeight.w800)),
                          TextSpan(
                              text: ' · ${ttcRecordDate(latest.takenOn)}',
                              style: ttcBody(13, color: ttcSoft)),
                        ]),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis)
                  else
                    // ⚠️ A RECORD WITH NO NUMBER IS A REAL RECORD, NOT A
                    // BROKEN ONE. Photo-first adding means some rows will only
                    // ever be a photograph, and the row has to hold that
                    // without looking like a failure, so it says what it has
                    // and offers the one thing that would complete it.
                    // ⚠️ STACKED, NOT SIDE BY SIDE (2026-09-29): with the
                    // mark on the row, the words and "Type the number" in one
                    // Row overflowed by 74px at 360dp and 1.5x text. The
                    // action sits under the line it completes. Kept for
                    // revert: Row(children: [Expanded(the line), the action
                    // with left: 8 padding]).
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              '${ttcRecordDate(latest.takenOn)} · photo saved, '
                              'number not entered',
                              style: ttcBody(13, color: ttcSoft, h: 1.4)),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => showTtcTypeValue(context, latest),
                            child: Padding(
                              padding: const EdgeInsets.only(top: 6, bottom: 2),
                              // Kept for revert (2026-09-28): 'Type it'
                              child: Text('Type the number',
                                  style: ttcBody(13,
                                      color: ttcTitleInk, w: FontWeight.w800)),
                            ),
                          ),
                        ]),
                  const SizedBox(height: 4),
                  Text(under,
                      style: ttcBody(12, color: ttcMuted, w: FontWeight.w600)),
                ]),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right_rounded, size: 20, color: ttcMuted),
        ]),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
            color: ttcPanel, borderRadius: BorderRadius.circular(999)),
        child: Text(text,
            style: ttcBody(10.5, color: ttcSoft, w: FontWeight.w800)),
      );
}

/// What a first check usually covers, against what she has filed.
///
/// ⚠️ EVERY "NOT ADDED" LINE CARRIES ITS OWN ADD (2026-09-27). It named ten
/// tests she had not filed and offered no way to file one; the rule is that
/// every "add X" line has its action right there.
///
/// ⚠️ CLEAN ROWS (2026-09-29, the user on build 20: "elevate the UI, it still
/// seems a bit different from our application"). The list was a panel of
/// dots with "· not added" tacked onto each name. Now it is the same white
/// list as "Your results" above it: a filed test shows an ink tick, whose it
/// is and its latest value, and opens that result; a test not filed is a
/// quiet line with one "Add result" in ink, which opens the add page on that
/// test. Mobbin:
///  · Zocdoc "Your Well Guide": each check a row, the missing one a quiet
///    "Last visit: add" with its action on the row:
///    https://mobbin.com/screens/86529650-4ea4-42ec-ad0e-a1d14a9c9fb0
///  · Apple Health "All Recorded Data": value and date as one grouped list,
///    a hairline between rows, a chevron where a row opens:
///    https://mobbin.com/screens/584b8a83-d3e7-441b-8a6d-ba1d951cc4fe
///  · Apple Health "Health Checklist": a section heading in the title face,
///    rows under it, the action as a text button in the row:
///    https://mobbin.com/screens/0420e040-cdba-419e-a764-21d85beffdd5
class _Coverage extends StatelessWidget {
  const _Coverage({required this.coverage});
  final TtcCoverage coverage;

  @override
  Widget build(BuildContext context) {
    final groups = ttcGroupedRecords();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ttcSectionTitle('What a first check usually covers'),
        // ⚠️ "NOT ADDED", NEVER "MISSING". "Missing" says her workup is
        // incomplete, which is a judgement about the clinician looking after
        // her. "Not added" says this app does not have it — a fact about her
        // filing, which is the only thing this screen is entitled to know.
        Text(
            'These are the tests a fertility check usually includes. '
            'You have ${coverage.added.length} of '
            '${coverage.total} saved here.',
            style: ttcBody(13, h: 1.5)),
        const SizedBox(height: 12),
        TtcRecordList(children: [
          for (final t in coverage.added)
            _CoverRow(test: t, group: ttcCoverageGroup(t, groups)),
          for (final t in coverage.notAdded)
            _CoverRow(
              test: t,
              group: null,
              addKey: ValueKey('ttc_rec_cover_add_${t.id}'),
              onAdd: () => openTtcRecordEdit(context, testId: t.id),
            ),
        ]),
        const SizedBox(height: 10),
        Text(
            "If one isn't saved here, that doesn't mean you haven't "
            'had it. Your clinic decides which of these you need.',
            style: ttcBody(12, color: ttcMuted, h: 1.5)),
      ],
    );
  }
}

class _CoverRow extends StatelessWidget {
  const _CoverRow({
    required this.test,
    required this.group,
    this.onAdd,
    this.addKey,
  });
  final TtcTest test;

  /// The filed group, when the test has one. Null draws the quiet line.
  final TtcRecordGroup? group;
  final VoidCallback? onAdd;
  final Key? addKey;

  @override
  Widget build(BuildContext context) {
    final g = group;
    final whose = ttcWhoseLong(test.forHim);
    final String under;
    if (g == null) {
      under = test.forHim ? "Your partner's test · not added yet" : 'Not added yet';
    } else {
      final value = ttcRecordValue(g.latest);
      under = '$whose · '
          '${value.isEmpty ? 'photo saved' : value} · '
          '${ttcRecordDate(g.latest.takenOn)}';
    }

    final row = Padding(
      padding: const EdgeInsets.fromLTRB(16, 13, 10, 13),
      child: Row(children: [
        // ⚠️ AN INK TICK FOR FILED, NOTHING THAT READS AS A FAILURE FOR NOT
        // FILED. A cross would say something went wrong, and half these tests
        // are ones her clinic may never order; the empty ring is a place
        // waiting, not a mark against her.
        SizedBox(
          width: 22,
          child: g != null
              ? const Icon(Icons.check_rounded, size: 20, color: ttcInk)
              : Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: ttcLine, width: 1.5),
                  ),
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(test.name,
                style: ttcBody(14,
                    color: ttcInk,
                    w: g != null ? FontWeight.w700 : FontWeight.w600,
                    h: 1.3)),
            const SizedBox(height: 2),
            Text(under,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: ttcBody(12.5,
                    color: g != null ? ttcSoft : ttcMuted, h: 1.4)),
          ]),
        ),
        if (onAdd != null)
          Semantics(
            button: true,
            label: 'Add result for ${test.name}',
            excludeSemantics: true,
            child: InkWell(
              key: addKey,
              onTap: onAdd,
              borderRadius: BorderRadius.circular(999),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 6, 10),
                // Kept for revert (2026-09-28): 'Add'
                child: Text('Add result',
                    style: ttcBody(13, color: ttcInk, w: FontWeight.w800)),
              ),
            ),
          )
        else if (g != null)
          const Icon(Icons.chevron_right_rounded, size: 20, color: ttcMuted),
      ]),
    );

    if (g == null) return row;
    return InkWell(
      key: ValueKey('ttc_rec_cover_done_${test.id}'),
      onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
        settings: const RouteSettings(name: 'ttc/record'),
        builder: (_) => g.repeated
            ? TtcRecordTrendScreen(groupKey: g.key)
            : TtcRecordDetailScreen(recordId: g.latest.id),
      )),
      child: row,
    );
  }
}

// Kept for revert (2026-09-29, clean rows): the panel of dots.
// /// What a first check usually covers, against what she has filed.
// ///
// /// ⚠️ EVERY "NOT ADDED" LINE CARRIES ITS OWN ADD (2026-09-27). It named ten
// /// tests she had not filed and offered no way to file one; the rule is that
// /// every "add X" line has its action right there.
// class _Coverage extends StatelessWidget {
//   const _Coverage({required this.coverage});
//   final TtcCoverage coverage;
//
//   @override
//   Widget build(BuildContext context) => Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           ttcSectionTitle('What a first check usually covers'),
//           TtcRecordPanel(
//             child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // ⚠️ "NOT ADDED", NEVER "MISSING". "Missing" says her workup
//                   // is incomplete, which is a judgement about the clinician
//                   // looking after her. "Not added" says this app does not have
//                   // it — a fact about her filing, which is the only thing this
//                   // screen is entitled to know.
//                   Text(
//                       'These are the tests a fertility check usually includes. '
//                       'You have ${coverage.added.length} of '
//                       '${coverage.total} saved here.',
//                       style: ttcBody(13, h: 1.5)),
//                   const SizedBox(height: 12),
//                   for (final t in coverage.added)
//                     _CoverRow(name: t.name, added: true),
//                   for (final t in coverage.notAdded)
//                     _CoverRow(
//                       name: t.name,
//                       added: false,
//                       addKey: ValueKey('ttc_rec_cover_add_${t.id}'),
//                       onAdd: () => openTtcRecordEdit(context, testId: t.id),
//                     ),
//                   const SizedBox(height: 8),
//                   Text(
//                       "If one isn't saved here, that doesn't mean you haven't "
//                       'had it. Your clinic decides which of these you need.',
//                       style: ttcBody(12, color: ttcMuted, h: 1.5)),
//                 ]),
//           ),
//         ],
//       );
// }
//
// class _CoverRow extends StatelessWidget {
//   const _CoverRow({
//     required this.name,
//     required this.added,
//     this.onAdd,
//     this.addKey,
//   });
//   final String name;
//   final bool added;
//   final VoidCallback? onAdd;
//   final Key? addKey;
//
//   @override
//   Widget build(BuildContext context) => Padding(
//         padding: const EdgeInsets.symmetric(vertical: 5),
//         child: Row(children: [
//           // ⚠️ A DOT, NOT A TICK AND A CROSS. A cross is a failure mark, and
//           // nothing here has failed — half these tests are ones her clinic may
//           // never order.
//           Container(
//             width: 7,
//             height: 7,
//             margin: const EdgeInsets.only(right: 11),
//             decoration: BoxDecoration(
//               color: added ? ttcTitleInk : Colors.transparent,
//               shape: BoxShape.circle,
//               border: added ? null : Border.all(color: ttcBorder, width: 1.4),
//             ),
//           ),
//           Expanded(
//             child: Text(added ? name : '$name · not added',
//                 style: ttcBody(13,
//                     color: added ? ttcTitleInk : ttcMuted,
//                     w: added ? FontWeight.w700 : FontWeight.w600)),
//           ),
//           if (onAdd != null)
//             GestureDetector(
//               key: addKey,
//               behavior: HitTestBehavior.opaque,
//               onTap: onAdd,
//               child: Padding(
//                 padding: const EdgeInsets.fromLTRB(10, 4, 2, 4),
//                 // Kept for revert (2026-09-28): 'Add'
//                 child: Text('Add result',
//                     style: ttcBody(12.5,
//                         color: ttcTitleInk, w: FontWeight.w800)),
//               ),
//             ),
//         ]),
//       );
// }

// =============================================================================
//  1g — empty
// =============================================================================

class TtcRecordsEmpty extends StatelessWidget {
  const TtcRecordsEmpty({super.key});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TtcRecordPanel(
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
            child: Column(children: [
              Text('Start with the paper in your hand.',
                  textAlign: TextAlign.center,
                  style: ttcFraunces(19,
                      w: FontWeight.w600, color: ttcTitleInk, h: 1.25)),
              const SizedBox(height: 9),
              // ⚠️ THIS LINE PROMISES ONLY WHAT THE SCREEN DOES (rewritten
              // 2026-09-03): it holds the report so a person can read it; it
              // reads nothing itself, and it cannot pull values off a photo.
              Text(
                  "Take a photo now, and it's on your phone when a doctor "
                  'asks. It keeps the date, next to whatever came before it.',
                  textAlign: TextAlign.center,
                  style: ttcBody(13.5, h: 1.55)),
              const SizedBox(height: 18),
              // ⚠️ THE CAMERA IS THE PRIMARY ACTION, not a form. It now opens
              // the add page with the phone's camera already up: one page
              // under the camera, never a second sheet of ours.
              TtcRecordsAction(
                  label: 'Photograph a report',
                  onTap: () => openTtcRecordEdit(context, camera: true)),
              const SizedBox(height: 10),
              TtcRecordsAction(
                  label: 'Type a number instead',
                  muted: true,
                  onTap: () => openTtcRecordEdit(context)),
            ]),
          ),
          const SizedBox(height: 26),
          // Kept for revert (2026-09-28): 'What this becomes'
          ttcSectionTitle('What your records become'),
          const TtcRecordList(children: [
            _Becomes(
              title: 'The same test, twice',
              body: 'A second AMH sits next to the first, so you can see which '
                  'way it moved without having to remember.',
            ),
            _Becomes(
              title: 'His results and yours',
              body: 'Every result shows whose it is, so a semen analysis is as '
                  'easy to find as an AMH.',
            ),
            _Becomes(
              title: 'The sheet itself, on the phone',
              body: 'In the waiting room, you can show the report instead of '
                  'describing it.',
            ),
          ]),
        ],
      );
}

class _Becomes extends StatelessWidget {
  const _Becomes({required this.title, required this.body});
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 15),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: ttcJakarta(14)),
          const SizedBox(height: 4),
          Text(body, style: ttcBody(12.5, h: 1.5)),
        ]),
      );
}

/*
// Kept for revert (2026-09-27): the folder body, rows and empty state as V1 shadowed cards (TtcCard), before the tool rebuild.
class TtcRecordsBody extends StatelessWidget {
  const TtcRecordsBody({
    super.key,
    required this.onlyPartner,
    this.resultsOnly = false,
  });

  /// null shows everyone, true only his, false only hers.
  final bool? onlyPartner;

  /// The Reports tile's narrowing — library results only. Kept from the screen
  /// this replaces; two tiles have always opened one folder.
  final bool resultsOnly;

  @override
  Widget build(BuildContext context) {
    final all = ttcGroupedRecords(resultsOnly: resultsOnly);
    final groups = onlyPartner == null
        ? all
        : all.where((g) => g.forPartner == onlyPartner).toList();
    final coverage = ttcRecordCoverage();

    if (all.isEmpty) return const TtcRecordsEmpty();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ttcSectionTitle("What you've had done"),
        for (final g in groups) ...[
          _GroupRow(group: g),
          const SizedBox(height: 10),
        ],
        if (groups.isEmpty) ...[
          TtcCard(
            child: Text(
                'Nothing filed under ${ttcWhose(onlyPartner!).toLowerCase()} '
                'yet.',
                style: ttcBody(13.5, h: 1.5)),
          ),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 18),
        _Coverage(coverage: coverage),
      ],
    );
  }
}

/// One test, with every reading behind it.
class _GroupRow extends StatelessWidget {
  const _GroupRow({required this.group});
  final TtcRecordGroup group;

  @override
  Widget build(BuildContext context) {
    final latest = group.latest;
    final value = ttcRecordValue(latest);
    final typed = value.isNotEmpty;

    return InkWell(
      borderRadius: BorderRadius.circular(ttcCardRadius),
      onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
        settings: const RouteSettings(name: 'ttc/record'),
        builder: (_) => group.repeated
            ? TtcRecordTrendScreen(groupKey: group.key)
            : TtcRecordDetailScreen(recordId: latest.id),
      )),
      child: TtcCard(
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Flexible(
                      child: Text(group.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: ttcJakarta(15)),
                    ),
                    if (group.repeated) ...[
                      const SizedBox(width: 8),
                      _Pill(text: '${group.count} readings'),
                    ],
                  ]),
                  const SizedBox(height: 6),
                  if (typed)
                    Text.rich(TextSpan(children: [
                      TextSpan(
                          text: value,
                          style: ttcBody(14,
                              color: ttcTitleInk, w: FontWeight.w800)),
                      TextSpan(
                          text: ' · ${ttcRecordDate(latest.takenOn)}',
                          style: ttcBody(13, color: ttcSoft)),
                    ]))
                  else
                    // ⚠️ A RECORD WITH NO NUMBER IS A REAL RECORD, NOT A
                    // BROKEN ONE. Photo-first adding means some rows will only
                    // ever be a photograph, and the row has to hold that
                    // without looking like a failure — so it says what it has
                    // and offers the one thing that would complete it.
                    Row(children: [
                      Expanded(
                        child: Text(
                            '${ttcRecordDate(latest.takenOn)} · photo saved, '
                            'number not entered',
                            style: ttcBody(13, color: ttcSoft, h: 1.4)),
                      ),
                      // The one thing that would complete this row, offered on
                      // the row rather than two taps away.
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => showTtcTypeValue(context, latest),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          // Kept for revert (2026-09-28): 'Type it'
                          child: Text('Type the number',
                              style: ttcBody(12.5,
                                  color: ttcTitleInk, w: FontWeight.w800)),
                        ),
                      ),
                    ]),
                  const SizedBox(height: 5),
                  Row(children: [
                    Text(ttcWhose(group.forPartner),
                        style: ttcBody(12, color: ttcMuted,
                            w: FontWeight.w700)),
                    if (group.repeated &&
                        ttcRecordValue(group.oldest).isNotEmpty) ...[
                      Text(' · first was ${ttcRecordValue(group.oldest)}, '
                          '${_months[group.oldest.takenOn.month - 1]} '
                          '${group.oldest.takenOn.year}',
                          style: ttcBody(12, color: ttcMuted)),
                    ] else if (latest.note != null &&
                        latest.note!.trim().isNotEmpty) ...[
                      Text(' · with a note',
                          style: ttcBody(12, color: ttcMuted)),
                    ] else if (latest.attachments.isNotEmpty) ...[
                      // The row says the report itself is in here, because
                      // that is the thing she is actually looking for in a
                      // waiting room - not the number, the paper.
                      Text(
                          ' · ${latest.attachments.length} '
                          '${latest.attachments.length == 1 ? 'photo' : 'photos'}',
                          style: ttcBody(12, color: ttcMuted)),
                    ],
                  ]),
                ]),
          ),
          const SizedBox(width: 10),
          Icon(Icons.chevron_right_rounded, size: 20, color: ttcMuted),
        ]),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
            color: ttcPanel, borderRadius: BorderRadius.circular(999)),
        child: Text(text,
            style: ttcBody(10.5, color: ttcSoft, w: FontWeight.w800)),
      );
}

/// What a first check usually covers, against what she has filed.
class _Coverage extends StatelessWidget {
  const _Coverage({required this.coverage});
  final TtcCoverage coverage;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ttcSectionTitle('What a first check usually covers'),
          TtcCard(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ⚠️ "NOT ADDED", NEVER "MISSING". "Missing" says her workup
                  // is incomplete, which is a judgement about the clinician
                  // looking after her. "Not added" says this app does not have
                  // it — a fact about her filing, which is the only thing this
                  // screen is entitled to know.
                  Text(
                      'These are the tests a fertility check usually includes. '
                      'You have ${coverage.added.length} of '
                      '${coverage.total} saved here.',
                      style: ttcBody(13, h: 1.5)),
                  const SizedBox(height: 14),
                  for (final t in coverage.added) ...[
                    _CoverRow(name: t.name, added: true),
                    const SizedBox(height: 9),
                  ],
                  for (final t in coverage.notAdded) ...[
                    _CoverRow(name: t.name, added: false),
                    const SizedBox(height: 9),
                  ],
                  const SizedBox(height: 4),
                  Text(
                      "If one isn't saved here, that doesn't mean you haven't "
                      'had it. Your clinic decides which of these you need.',
                      style: ttcBody(12, color: ttcMuted, h: 1.5)),
                ]),
          ),
        ],
      );
}

class _CoverRow extends StatelessWidget {
  const _CoverRow({required this.name, required this.added});
  final String name;
  final bool added;

  @override
  Widget build(BuildContext context) =>
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ⚠️ A DOT, NOT A TICK AND A CROSS. A cross is a failure mark, and
        // nothing here has failed — half these tests are ones her clinic may
        // never order.
        Container(
          width: 7,
          height: 7,
          margin: const EdgeInsets.only(top: 6, right: 11),
          decoration: BoxDecoration(
            color: added ? ttcTitleInk : Colors.transparent,
            shape: BoxShape.circle,
            border: added ? null : Border.all(color: ttcBorder, width: 1.4),
          ),
        ),
        Expanded(
          child: Text(added ? name : '$name · not added',
              style: ttcBody(13,
                  color: added ? ttcTitleInk : ttcMuted,
                  w: added ? FontWeight.w700 : FontWeight.w600)),
        ),
      ]);
}

// =============================================================================
//  1g — empty
// =============================================================================

class TtcRecordsEmpty extends StatelessWidget {
  const TtcRecordsEmpty({super.key});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TtcCard(
            child: Column(children: [
              Text('Start with the paper in your hand.',
                  textAlign: TextAlign.center,
                  style: ttcFraunces(19,
                      w: FontWeight.w600, color: ttcTitleInk, h: 1.25)),
              const SizedBox(height: 9),
              // ⚠️ THIS LINE PROMISES ONLY WHAT THE SCREEN DOES, and it was
              // rewritten on 2026-09-03 because the first version did not.
              //
              // It read: "One photograph today, and in a year this screen
              // answers the questions a consultation opens with." Two things
              // wrong with it, and the second one cost something. It says the
              // SCREEN answers — this screen answers nothing, it holds things
              // so a person can. And "in a year" is a strange promise to
              // somebody whose consultation is next Tuesday.
              //
              // The cost: it read as upload-and-get-insights, and the first
              // person to see it asked whether the app could extract values
              // from a photograph. It cannot, and copy that makes somebody ask
              // "wait, can it do that?" has failed regardless of how it scans.
              Text(
                  "Take a photo now, and it's on your phone when a doctor "
                  'asks. It keeps the date, next to whatever came before it.',
                  textAlign: TextAlign.center,
                  style: ttcBody(13.5, h: 1.55)),
              const SizedBox(height: 18),
              // ⚠️ THE CAMERA IS THE PRIMARY ACTION, not a form. The fastest
              // first entry is a photograph of the sheet she is already
              // holding; asking her to type a number first is asking her to
              // read a lab report standing up.
              TtcRecordsAction(
                  label: 'Photograph a report',
                  onTap: () => showTtcRecordAdd(context)),
              const SizedBox(height: 10),
              TtcRecordsAction(
                  label: 'Type a number instead',
                  muted: true,
                  onTap: () => showTtcRecordAdd(context, typing: true)),
            ]),
          ),
          const SizedBox(height: 26),
          // Kept for revert (2026-09-28): 'What this becomes'
          ttcSectionTitle('What your records become'),
          const _Becomes(
            title: 'The same test, twice',
            body: 'A second AMH sits next to the first, so you can see which '
                'way it moved without having to remember.',
          ),
          const SizedBox(height: 10),
          const _Becomes(
            title: 'His results and yours',
            body: 'Every result shows whose it is, so a semen analysis is as '
                'easy to find as an AMH.',
          ),
          const SizedBox(height: 10),
          const _Becomes(
            title: 'The sheet itself, on the phone',
            body: 'In the waiting room, you can show the report instead of '
                'describing it.',
          ),
        ],
      );
}

class _Becomes extends StatelessWidget {
  const _Becomes({required this.title, required this.body});
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(15, 14, 15, 15),
        decoration: BoxDecoration(
            // Kept for revert (2026-09-29, no tinted slab behind text): color: ttcPanel, borderRadius: BorderRadius.circular(16)),
            color: Colors.white, border: const Border.fromBorderSide(BorderSide(color: ttcLine)), borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: ttcJakarta(14)),
          const SizedBox(height: 4),
          Text(body, style: ttcBody(12.5, h: 1.5)),
        ]),
      );
}
*/

/// "0.9 lower" and "ng/mL" -> "0.9 ng/mL lower"; "unchanged" stays as it is.
String ttcSpanWithUnit(String span, String unit) {
  final u = unit.trim();
  if (u.isEmpty) return span;
  final parts = span.split(' ');
  if (parts.length != 2) return span;
  return '${parts[0]} $u ${parts[1]}';
}

/// What kind of test a result is, for its drawn mark. Never a verdict.
enum TtcRecordKind { blood, imaging, semen, other }

const Set<String> _kBloodIds = {
  'tsh', 'amh', 'fsh_lh', 'vitd', 'b12', 'hba1c', 'prolactin',
};
const Set<String> _kImagingIds = {'ultrasound', 'hsg'};

/// The kind from the library id, or from the words she typed.
TtcRecordKind ttcRecordKindOf(String testKey, String label) {
  if (testKey == 'semen') return TtcRecordKind.semen;
  if (_kBloodIds.contains(testKey)) return TtcRecordKind.blood;
  if (_kImagingIds.contains(testKey)) return TtcRecordKind.imaging;
  final l = '${label.toLowerCase()} ${testKey.toLowerCase()}';
  bool any(List<String> words) => words.any(l.contains);
  if (any(['semen', 'sperm'])) return TtcRecordKind.semen;
  if (any(['scan', 'ultrasound', 'sonograph', 'usg', 'hsg', 'x-ray', 'xray',
    'mri', 'follicle', 'tvs', 'laparoscop', 'hysteroscop'])) {
    return TtcRecordKind.imaging;
  }
  if (any(['blood', 'amh', 'tsh', 'thyroid', 'fsh', 'prolactin', 'vitamin',
    'hba1c', 'sugar', 'hormone', 'cbc', 'haemoglobin', 'hemoglobin',
    'estradiol', 'progesterone', 'testosterone', 'insulin', 'rubella',
    'serum', 'lh '])) {
    return TtcRecordKind.blood;
  }
  return TtcRecordKind.other;
}

/// A result's drawn mark: an object on a disc of the records hue, in the door
/// rails' hand (`TtcTabArt`) and the Tools marks (`TtcToolArt`). Decorative;
/// the row's words already say what the test is. Keyed per kind for tests.
class TtcRecordMark extends StatelessWidget {
  const TtcRecordMark({super.key, required this.kind, this.size = 40});

  final TtcRecordKind kind;
  final double size;

  @override
  Widget build(BuildContext context) {
    final tint = v2BlockTint(kTtcRecordsHue, V2PaletteStore.instance.current);
    final Widget art = switch (kind) {
      // The rail's "Tests and results": a vial in front of a report.
      TtcRecordKind.blood =>
        TtcTabArt(mark: TtcTabMark.vialReport, tint: tint),
      // A magnifier over a page: a scan is someone looking inside.
      TtcRecordKind.imaging =>
        TtcTabArt(mark: TtcTabMark.magnifier, tint: tint),
      // His health's heart with a pulse, as on the Tools row for him.
      TtcRecordKind.semen =>
        TtcToolArt(mark: TtcToolMark.partnerHealth, tint: tint),
      // The Records tool's own folder, for anything typed by hand.
      TtcRecordKind.other =>
        TtcToolArt(mark: TtcToolMark.records, tint: tint),
    };
    return ExcludeSemantics(
      child: SizedBox(
        key: ValueKey('ttc_rec_mark_${kind.name}'),
        width: size,
        height: size,
        child: art,
      ),
    );
  }
}

/// The stage's one button.
class TtcRecordsAction extends StatelessWidget {
  const TtcRecordsAction({
    super.key,
    required this.label,
    required this.onTap,
    this.muted = false,
    this.enabled = true,
  });

  final String label;
  final VoidCallback onTap;
  final bool muted;

  /// False draws the button greyed and ignores the tap. The caller says why
  /// right under it: a disabled button with no reason is a dead tap by another
  /// name (tools pass, 2026-09-27).
  final bool enabled;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: !enabled
                ? ttcPanel
                : muted
                    ? Colors.transparent
                    : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: enabled ? ttcLine : ttcPanel),
          ),
          child: Text(label,
              textAlign: TextAlign.center,
              style: ttcBody(13.5,
                  color: !enabled
                      ? ttcMuted
                      : muted
                          ? ttcSoft
                          : ttcTitleInk,
                  w: FontWeight.w800)),
        ),
      );
}

// =============================================================================
//  1d — one test over time
// =============================================================================

/// Every reading of one test, newest at the top, with the gap between them
/// named in months.
///
/// ⚠️ NO CHART, AND THE REASON IS THE DATA RATHER THAN THE RULE. A dot plot
/// renders a single number and nothing else. This library holds a thyroid panel
/// with a photo and no typed number, an HSG whose result is a sentence, and a
/// semen analysis that is three values in one result — a chart would work for
/// the tests that happen to be single numbers and break on the rest.
///
/// A stack holds all of them. It also survives a test with two readings, which
/// a trend line does not really.
///
/// ⚠️ 2026-09-27: THE PAGE NOW DOES THINGS. "Add a new reading" (top right and
/// at the foot) starts the add page as the same test for the same person, so
/// a repeat lands in this group without retyping its name; and the whole test
/// can be removed here, asked first, with Undo.
class TtcRecordTrendScreen extends StatelessWidget {
  const TtcRecordTrendScreen({super.key, required this.groupKey});

  final String groupKey;

  Future<void> _removeAll(BuildContext context, TtcRecordGroup group) async {
    final nav = Navigator.of(context);
    final rows = [...group.readings];
    final ok = await ttcConfirmRemove(
      context,
      title: 'Remove all ${group.count} ${group.label} readings?',
      body: 'Every reading of this test comes off your records, on this '
          'phone and on your account.',
      yes: 'Remove all',
    );
    if (!ok || !context.mounted) return;
    TtcRecordsStore.instance.removeAll(rows.map((r) => r.id));
    pvSnack(context, '${group.label} removed.',
        action: 'Undo',
        onAction: () => TtcRecordsStore.instance.restore(rows),
        lift: 24);
    nav.maybePop();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: TtcRecordsStore.instance,
        builder: (context, _) {
          final group = ttcGroupedRecords()
              .where((g) => g.key == groupKey)
              .firstOrNull;
          if (group == null) return const _Gone();

          final oldest = group.oldest;
          final latest = group.latest;
          final span = ttcReadingChange(latest, oldest);
          void addOne() => openTtcRecordEdit(context, like: latest);

          return TtcToolScaffold(
            hue: kTtcRecordsHue,
            variant: 2,
            // One test's results, opened from Records: back (2026-09-29).
            leading: TtcToolLeading.back,
            // One name per thing: the tool's name, as on every records page.
            // Kept for revert: eyebrow: ttcWhose(group.forPartner),
            eyebrow: 'Records and reports',
            title: '${group.label}, ${_times(group.count)}',
            intro: '${ttcWhoseLong(group.forPartner)} · '
                '${_months[oldest.takenOn.month - 1]} '
                '${oldest.takenOn.year} to '
                '${_months[latest.takenOn.month - 1]} '
                '${latest.takenOn.year}'
                '${latest.unit.trim().isEmpty ? '' : ' · all values in '
                    '${latest.unit.trim()}'}',
            action: TtcRecordsHeroPill(
                key: const ValueKey('ttc_rec_trend_add'),
                icon: Icons.add_rounded,
                // Kept for revert (2026-09-28): 'Add'
                label: 'Add a result',
                onTap: addOne),
            children: [
              ttcToolPad(Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 22),
                  for (var i = 0; i < group.readings.length; i++) ...[
                    _Reading(
                      record: group.readings[i],
                      previous: i + 1 < group.readings.length
                          ? group.readings[i + 1]
                          : null,
                      isLatest: i == 0,
                      isFirst: i == group.readings.length - 1,
                    ),
                  ],
                  if (span != null && group.repeated) ...[
                    const SizedBox(height: 8),
                    // ⚠️ ARITHMETIC ON HER OWN TWO NUMBERS, IN HER OWN UNITS.
                    // "0.9 lower over 17 months" describes what she recorded.
                    // Anything comparing it to a population would be a second
                    // opinion, and this screen does not give one.
                    // ⚠️ NO TINTED SLAB BEHIND A STAT (2026-09-29, the
                    // one-app rule: stats are a plain label and a large value
                    // on white). Kept for revert: padding
                    // fromLTRB(15, 14, 15, 15) and a BoxDecoration of
                    // ttcPanel at 55% with radius 16 round this Column.
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 6, 4, 4),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('BETWEEN THE FIRST AND THE LATEST',
                                style: pvManrope(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.1,
                                    color: ttcMuted)),
                            const SizedBox(height: 5),
                            Text(
                                // "0.9 ng/mL lower", not "0.9 lower ng/mL"
                                // (2026-09-29, seen on the rendered page):
                                // the unit belongs to the number. Kept for
                                // revert: '$span${unit.isEmpty ? '' : ' $unit'}, '
                                '${ttcSpanWithUnit(span, latest.unit)}, '
                                '${ttcReadingGap(latest.takenOn, oldest.takenOn)
                                    .replaceAll(' later', ' apart')}',
                                style: ttcFraunces(17,
                                    w: FontWeight.w600, color: ttcTitleInk)),
                          ]),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                      'These are your own readings, in the order you saved '
                      'them. Tap one to see it, change it or remove it. Your '
                      'clinic can tell you what they mean.',
                      style: ttcBody(12.5, color: ttcMuted, h: 1.5)),
                  const SizedBox(height: 18),
                  TtcToolSecondary(
                      label: 'Add a new reading', onTap: addOne),
                  const SizedBox(height: 10),
                  TtcRecordsRemoveButton(
                    key: const ValueKey('ttc_rec_trend_remove'),
                    label: 'Remove all ${group.count} readings',
                    onTap: () => _removeAll(context, group),
                  ),
                  const SizedBox(height: 16),
                ],
              )),
            ],
          );
        },
      );

  static String _times(int n) => switch (n) {
        2 => 'twice',
        3 => 'three times',
        4 => 'four times',
        _ => '$n times',
      };
}

class _Reading extends StatelessWidget {
  const _Reading({
    required this.record,
    required this.previous,
    required this.isLatest,
    required this.isFirst,
  });

  final TtcRecord record;
  final TtcRecord? previous;
  final bool isLatest;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    final value = ttcRecordValue(record);
    final change =
        previous == null ? null : ttcReadingChange(record, previous!);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
          settings: const RouteSettings(name: 'ttc/record'),
          builder: (_) => TtcRecordDetailScreen(recordId: record.id),
        )),
        child: TtcRecordPanel(
          child: Row(children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isLatest || isFirst) ...[
                      Text(isLatest ? 'LATEST' : 'FIRST READING',
                          style: pvManrope(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                              color: ttcMuted)),
                      const SizedBox(height: 6),
                    ],
                    if (value.isNotEmpty)
                      Text(value,
                          style: ttcFraunces(value.length > 18 ? 18 : 26,
                              w: FontWeight.w600, color: ttcTitleInk))
                    else
                      Text('Photo only, number not entered',
                          style: ttcBody(14,
                              color: ttcSoft, w: FontWeight.w700)),
                    const SizedBox(height: 5),
                    Text(ttcRecordDate(record.takenOn),
                        style: ttcBody(12.5, color: ttcMuted)),
                    if (record.note != null &&
                        record.note!.trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(record.note!.trim(), style: ttcBody(13, h: 1.5)),
                    ],
                    if (record.attachments.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(children: [
                        const Icon(Icons.attach_file_rounded,
                            size: 14, color: ttcMuted),
                        const SizedBox(width: 6),
                        Text('Report photo attached',
                            style: ttcBody(12, color: ttcMuted)),
                      ]),
                    ],
                  ]),
            ),
            const Icon(Icons.chevron_right_rounded, size: 20, color: ttcMuted),
          ]),
        ),
      ),
      // ⚠️ THE GAP IS NAMED, WHICH IS WHAT REPLACES AN AXIS. "9 months later ·
      // 0.4 lower" tells you the direction and the distance without plotting
      // anything, so it works identically for a number, a sentence and a
      // reading nobody typed.
      if (previous != null)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Row(children: [
            Container(width: 2, height: 18, color: ttcBorder),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                  '${ttcReadingGap(record.takenOn, previous!.takenOn)}'
                  '${change == null ? '' : ' · $change'}',
                  style: ttcBody(12.5, color: ttcSoft, w: FontWeight.w700)),
            ),
          ]),
        )
      else
        const SizedBox(height: 10),
    ]);
  }
}

/// What shows for a moment if a page's record is removed from under it.
///
/// ⚠️ IT HAD NO WAY OUT (fixed 2026-09-27): a bare Scaffold with a sentence
/// and no back control. Now it wears the tool shell, whose close button is
/// always there, and names the way back.
class _Gone extends StatelessWidget {
  const _Gone();

  @override
  Widget build(BuildContext context) => TtcToolScaffold(
        hue: kTtcRecordsHue,
        // Opened from Records: back, not an X (2026-09-29).
        leading: TtcToolLeading.back,
        eyebrow: 'Records and reports',
        title: 'This result has been removed.',
        intro: "It's no longer in your records.",
        children: [
          ttcToolPad(Column(children: [
            const SizedBox(height: 22),
            TtcToolSecondary(
                label: 'Back to your records',
                onTap: () => Navigator.of(context).maybePop()),
          ])),
        ],
      );
}

/*
// Kept for revert (2026-09-27): the group page and the dead-end "removed" page, before the tool rebuild.
/// Every reading of one test, newest at the top, with the gap between them
/// named in months.
///
/// ⚠️ NO CHART, AND THE REASON IS THE DATA RATHER THAN THE RULE. A dot plot
/// renders a single number and nothing else. This library holds a thyroid panel
/// with a photo and no typed number, an HSG whose result is a sentence, and a
/// semen analysis that is three values in one result — a chart would work for
/// the tests that happen to be single numbers and break on the rest.
///
/// A stack holds all of them. It also survives a test with two readings, which
/// a trend line does not really.
class TtcRecordTrendScreen extends StatelessWidget {
  const TtcRecordTrendScreen({super.key, required this.groupKey});

  final String groupKey;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: TtcRecordsStore.instance,
        builder: (context, _) {
          final group = ttcGroupedRecords()
              .where((g) => g.key == groupKey)
              .firstOrNull;
          if (group == null) return const _Gone();

          final oldest = group.oldest;
          final latest = group.latest;
          final span = ttcReadingChange(latest, oldest);

          return TtcToolScaffold(
            hue: kTtcRecordsHue,
            variant: 2,
            eyebrow: ttcWhose(group.forPartner),
            title: '${group.label}, ${_times(group.count)}',
            intro: '${_months[oldest.takenOn.month - 1]} '
                '${oldest.takenOn.year} to '
                '${_months[latest.takenOn.month - 1]} '
                '${latest.takenOn.year}'
                '${latest.unit.trim().isEmpty ? '' : ' · all values in '
                    '${latest.unit.trim()}'}',
            children: [
              ttcToolPad(Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 22),
                  for (var i = 0; i < group.readings.length; i++) ...[
                    _Reading(
                      record: group.readings[i],
                      previous: i + 1 < group.readings.length
                          ? group.readings[i + 1]
                          : null,
                      isLatest: i == 0,
                      isFirst: i == group.readings.length - 1,
                    ),
                  ],
                  if (span != null && group.repeated) ...[
                    const SizedBox(height: 8),
                    // ⚠️ ARITHMETIC ON HER OWN TWO NUMBERS, IN HER OWN UNITS.
                    // "0.9 lower over 17 months" describes what she recorded.
                    // Anything comparing it to a population would be a second
                    // opinion, and this screen does not give one.
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(15, 14, 15, 15),
                      decoration: BoxDecoration(
                          // Kept for revert (2026-09-29, no tinted slab behind text): color: ttcPanel,
                          color: Colors.white, border: const Border.fromBorderSide(BorderSide(color: ttcLine)),
                          borderRadius: BorderRadius.circular(16)),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('BETWEEN THE FIRST AND THE LATEST',
                                style: pvManrope(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.1,
                                    color: ttcMuted)),
                            const SizedBox(height: 5),
                            Text(
                                '$span${latest.unit.trim().isEmpty ? '' : ' '
                                    '${latest.unit.trim()}'}, '
                                '${ttcReadingGap(latest.takenOn, oldest.takenOn)
                                    .replaceAll(' later', ' apart')}',
                                style: ttcFraunces(17,
                                    w: FontWeight.w600, color: ttcTitleInk)),
                          ]),
                    ),
                  ],
                  const SizedBox(height: 18),
                  Text(
                      'These are your own readings, in the order you saved '
                      'them. Your clinic can tell you what they mean.',
                      style: ttcBody(12.5, color: ttcMuted, h: 1.5)),
                  const SizedBox(height: 10),
                ],
              )),
            ],
          );
        },
      );

  static String _times(int n) => switch (n) {
        2 => 'twice',
        3 => 'three times',
        4 => 'four times',
        _ => '$n times',
      };
}

class _Reading extends StatelessWidget {
  const _Reading({
    required this.record,
    required this.previous,
    required this.isLatest,
    required this.isFirst,
  });

  final TtcRecord record;
  final TtcRecord? previous;
  final bool isLatest;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    final value = ttcRecordValue(record);
    final change =
        previous == null ? null : ttcReadingChange(record, previous!);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      InkWell(
        borderRadius: BorderRadius.circular(ttcCardRadius),
        onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
          settings: const RouteSettings(name: 'ttc/record'),
          builder: (_) => TtcRecordDetailScreen(recordId: record.id),
        )),
        child: TtcCard(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isLatest || isFirst) ...[
                  Text(isLatest ? 'LATEST' : 'FIRST READING',
                      style: pvManrope(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                          color: ttcMuted)),
                  const SizedBox(height: 6),
                ],
                if (value.isNotEmpty)
                  Text(value,
                      style: ttcFraunces(26,
                          w: FontWeight.w600, color: ttcTitleInk))
                else
                  Text('Photo only, number not entered',
                      style: ttcBody(14, color: ttcSoft, w: FontWeight.w700)),
                const SizedBox(height: 5),
                Text(ttcRecordDate(record.takenOn),
                    style: ttcBody(12.5, color: ttcMuted)),
                if (record.note != null && record.note!.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(record.note!.trim(), style: ttcBody(13, h: 1.5)),
                ],
                if (record.attachments.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(children: [
                    Icon(Icons.attach_file_rounded, size: 14, color: ttcMuted),
                    const SizedBox(width: 6),
                    Text('Report photo attached',
                        style: ttcBody(12, color: ttcMuted)),
                  ]),
                ],
              ]),
        ),
      ),
      // ⚠️ THE GAP IS NAMED, WHICH IS WHAT REPLACES AN AXIS. "9 months later ·
      // 0.4 lower" tells you the direction and the distance without plotting
      // anything, so it works identically for a number, a sentence and a
      // reading nobody typed.
      if (previous != null)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Row(children: [
            Container(width: 2, height: 18, color: ttcBorder),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                  '${ttcReadingGap(record.takenOn, previous!.takenOn)}'
                  '${change == null ? '' : ' · $change'}',
                  style: ttcBody(12.5, color: ttcSoft, w: FontWeight.w700)),
            ),
          ]),
        ),
    ]);
  }
}

class _Gone extends StatelessWidget {
  const _Gone();

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: ttcBg,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Text('This record has been removed.',
                  style: ttcBody(14, h: 1.5)),
            ),
          ),
        ),
      );
}
*/

// =============================================================================
//  1e — one result in full, and the report held up
// =============================================================================

/// ⚠️ 2026-09-27: A RESULT CAN BE CHANGED AND REMOVED FROM ITS OWN PAGE. It
/// could be opened and read, and that was all: "the last report added, 6
/// September, no sperm found. Now I cannot delete it." "Edit" sits top right
/// (where "Add" sits on the folder), and the foot carries "Change this result"
/// and "Remove this result", the removal asked first and undoable after.
class TtcRecordDetailScreen extends StatelessWidget {
  const TtcRecordDetailScreen({super.key, required this.recordId});

  final String recordId;

  Future<void> _edit(BuildContext context, TtcRecord r) async {
    final nav = Navigator.of(context);
    final removed = await openTtcRecordEdit(context, record: r);
    if (removed) nav.maybePop();
  }

  Future<void> _remove(BuildContext context, TtcRecord r) async {
    final nav = Navigator.of(context);
    final gone = await ttcRemoveRecord(context, r);
    if (gone) nav.maybePop();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: TtcRecordsStore.instance,
        builder: (context, _) {
          final r = TtcRecordsStore.instance.records
              .where((e) => e.id == recordId)
              .firstOrNull;
          if (r == null) return const _Gone();
          final value = ttcRecordValue(r);
          final test = r.testId == null ? null : ttcTestById(r.testId!);
          // A result that is several values in one (the semen reader saves
          // "Concentration 12 million per ml · Progressive motility 28.5 per
          // cent · Volume 2 ml") reads as a list, not as one huge headline.
          final parts = value.split(' · ');

          return TtcToolScaffold(
            hue: kTtcRecordsHue,
            variant: 3,
            // One result, opened from Records: back, not an X (2026-09-29).
            leading: TtcToolLeading.back,
            // Kept for revert: eyebrow: ttcWhose(r.forPartner), intro: date.
            eyebrow: 'Records and reports',
            title: r.label,
            intro: '${ttcWhoseLong(r.forPartner)} · ${ttcRecordDate(r.takenOn)}',
            action: TtcRecordsHeroPill(
                key: const ValueKey('ttc_rec_edit'),
                icon: Icons.edit_outlined,
                // Kept for revert (2026-09-28): 'Edit'
                label: 'Edit result',
                onTap: () => _edit(context, r)),
            children: [
              ttcToolPad(Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 22),
                  ttcSectionTitle('Result as printed'),
                  TtcRecordPanel(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ⚠️ "AS PRINTED" IS THE PROMISE OF THIS SCREEN. What
                          // is shown is what the report said, unchanged and
                          // un-annotated. No range beside it, no word about
                          // whether it is high.
                          if (value.isEmpty) ...[
                            Text('Number not entered',
                                style: ttcBody(15,
                                    color: ttcSoft, w: FontWeight.w700)),
                            const SizedBox(height: 12),
                            TtcRecordsAction(
                                label: 'Type the number',
                                onTap: () => showTtcTypeValue(context, r)),
                          ] else if (parts.length > 1)
                            for (var i = 0; i < parts.length; i++) ...[
                              if (i > 0) const SizedBox(height: 8),
                              Text(parts[i],
                                  style: ttcBody(15,
                                      color: ttcTitleInk,
                                      w: FontWeight.w800,
                                      h: 1.35)),
                            ]
                          else
                            Text(value,
                                style: ttcFraunces(value.length > 18 ? 21 : 28,
                                    w: FontWeight.w600, color: ttcTitleInk)),
                          const SizedBox(height: 12),
                          ttcDivider(),
                          const SizedBox(height: 12),
                          Row(children: [
                            Expanded(
                                child: _Fact(
                                    label: 'Date on the report',
                                    value: ttcRecordDate(r.takenOn))),
                            Expanded(
                                child: _Fact(
                                    label: 'Whose',
                                    value: ttcWhoseLong(r.forPartner))),
                          ]),
                          if (r.note != null && r.note!.trim().isNotEmpty) ...[
                            const SizedBox(height: 12),
                            ttcDivider(),
                            const SizedBox(height: 12),
                            // ⚠️ A CLINICIAN'S WORDS ARE HELD VERBATIM AND
                            // ATTRIBUTED, NEVER RE-READ.
                            Text('WHAT WAS WRITTEN',
                                style: pvManrope(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.1,
                                    color: ttcMuted)),
                            const SizedBox(height: 6),
                            Text(r.note!.trim(),
                                style: ttcBody(14, h: 1.6, color: ttcInk)),
                          ],
                        ]),
                  ),
                  // ⚠️ CARRIED OVER, DELIBERATELY: the library's plain note on
                  // what the test measures, so a number never sits alone. It
                  // says nothing about HER number.
                  if (test != null) ...[
                    const SizedBox(height: 24),
                    // Kept for revert (2026-09-28): 'What this test measures'
                    ttcSectionTitle('What ${test.name} measures'),
                    TtcRecordPanel(
                      child: Text(test.reading(TtcS.current().hinglish),
                          style: ttcBody(13.5, h: 1.6, color: ttcTitleInk)),
                    ),
                  ],
                  const SizedBox(height: 24),
                  ttcSectionTitle('The report itself'),
                  if (r.attachments.isEmpty)
                    TtcRecordPanel(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Kept for revert (2026-09-28): 'No photo
                            // saved for this one.'
                            Text('No photo saved for this result.',
                                style: ttcBody(13.5, h: 1.5)),
                            const SizedBox(height: 14),
                            // Kept for revert (2026-09-27): this opened the
                            // old attachment chooser, a V1 sheet over this
                            // page: onTap: () => _attach(context, r).
                            TtcRecordsAction(
                                label: 'Add a photo of the report',
                                onTap: () => _edit(context, r)),
                          ]),
                    )
                  else
                    TtcRecordList(children: [
                      for (var i = 0; i < r.attachments.length; i++)
                        _Sheet(
                          path: r.attachments[i],
                          n: i + 1,
                          caption:
                              '${r.label} · ${ttcRecordDate(r.takenOn)} · '
                              '${i + 1} of ${r.attachments.length}',
                        ),
                    ]),
                  const SizedBox(height: 26),
                  TtcToolSecondary(
                      label: 'Change this result',
                      onTap: () => _edit(context, r)),
                  const SizedBox(height: 10),
                  TtcRecordsRemoveButton(
                    key: const ValueKey('ttc_rec_detail_remove'),
                    label: 'Remove this result',
                    onTap: () => _remove(context, r),
                  ),
                  const SizedBox(height: 16),
                ],
              )),
            ],
          );
        },
      );

  // Kept for revert (2026-09-27): adding a photo from this page through the
  // old attachment chooser. The add page now carries the three sources.
  // Future<void> _attach(BuildContext context, TtcRecord r) async {
  //   final added = await showTtcAttachmentPicker(context, TtcS.current());
  //   if (added.isEmpty) return;
  //   TtcRecordsStore.instance
  //       .replace(r.copyWith(attachments: [...r.attachments, ...added]));
  // }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label.toUpperCase(),
            style: pvManrope(
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
                color: ttcMuted)),
        const SizedBox(height: 4),
        Text(value, style: ttcBody(14, color: ttcTitleInk, w: FontWeight.w700)),
      ]);
}

/// The saved sheet, a row in the list, tappable into the viewer.
class _Sheet extends StatelessWidget {
  const _Sheet({required this.path, required this.caption, required this.n});
  final String path;
  final String caption;
  final int n;

  @override
  Widget build(BuildContext context) {
    final pdf = path.toLowerCase().endsWith('.pdf');
    return InkWell(
      onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
        settings: const RouteSettings(name: 'ttc/record_sheet'),
        builder: (_) => TtcSheetViewer(path: path, caption: caption),
      )),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
        child: Row(children: [
          // A hairline page, not a tinted square (2026-09-29: tinted-square
          // wells are retired). Kept for revert: color ttcPanel at 60%.
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: ttcLine),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(
                pdf ? Icons.picture_as_pdf_outlined : Icons.description_outlined,
                size: 21,
                color: ttcTitleInk),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(pdf ? 'PDF, page $n' : 'Photo of the report, page $n',
                      style: ttcJakarta(14)),
                  const SizedBox(height: 3),
                  Text('Tap to open full screen',
                      style: ttcBody(12.5, color: ttcMuted)),
                ]),
          ),
          const Icon(Icons.chevron_right_rounded, size: 20, color: ttcMuted),
        ]),
      ),
    );
  }
}

/*
// Kept for revert (2026-09-27): the result page that could only be read, never changed or removed.
class TtcRecordDetailScreen extends StatelessWidget {
  const TtcRecordDetailScreen({super.key, required this.recordId});

  final String recordId;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: TtcRecordsStore.instance,
        builder: (context, _) {
          final r = TtcRecordsStore.instance.records
              .where((e) => e.id == recordId)
              .firstOrNull;
          if (r == null) return const _Gone();
          final value = ttcRecordValue(r);
          final test = r.testId == null ? null : ttcTestById(r.testId!);

          return TtcToolScaffold(
            hue: kTtcRecordsHue,
            variant: 3,
            eyebrow: ttcWhose(r.forPartner),
            title: r.label,
            intro: ttcRecordDate(r.takenOn),
            children: [
              ttcToolPad(Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 22),
                  ttcSectionTitle('Result as printed'),
                  TtcCard(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ⚠️ "AS PRINTED" IS THE PROMISE OF THIS SCREEN. What
                          // is shown is what the report said, unchanged and
                          // un-annotated. No range beside it, no word about
                          // whether it is high.
                          if (value.isNotEmpty)
                            Text(value,
                                style: ttcFraunces(28,
                                    w: FontWeight.w600, color: ttcTitleInk))
                          else ...[
                            Text('Number not entered',
                                style: ttcBody(15,
                                    color: ttcSoft, w: FontWeight.w700)),
                            const SizedBox(height: 12),
                            TtcRecordsAction(
                                label: 'Type the number',
                                onTap: () => showTtcTypeValue(context, r)),
                          ],
                          const SizedBox(height: 12),
                          ttcDivider(),
                          const SizedBox(height: 12),
                          _Fact(label: 'Date', value: ttcRecordDate(r.takenOn)),
                          if (r.note != null && r.note!.trim().isNotEmpty) ...[
                            const SizedBox(height: 12),
                            ttcDivider(),
                            const SizedBox(height: 12),
                            // ⚠️ A CLINICIAN'S WORDS ARE HELD VERBATIM AND
                            // ATTRIBUTED, NEVER RE-READ. Where a doctor has
                            // interpreted a result, the app carries the
                            // sentence and stops. Summarising it would put a
                            // phone between her and the person treating her.
                            Text('WHAT WAS WRITTEN',
                                style: pvManrope(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.1,
                                    color: ttcMuted)),
                            const SizedBox(height: 6),
                            Text(r.note!.trim(),
                                style: ttcBody(14, h: 1.6, color: ttcInk)),
                            const SizedBox(height: 6),
                            Text('Saved from the report, '
                                '${ttcRecordDate(r.takenOn)}',
                                style: ttcBody(11.5, color: ttcMuted)),
                          ],
                        ]),
                  ),
                  // ⚠️ CARRIED OVER FROM THE CARD THIS REPLACES, DELIBERATELY.
                  // The old screen printed the library's plain-language note
                  // beside every library result so a number never sat alone,
                  // and dropping it in a redesign would have been a silent
                  // regression rather than a decision. It moved from the list
                  // row to here because a list of fifteen paragraphs is not
                  // read; one paragraph on the result she opened is.
                  //
                  // It explains what the test measures. It says nothing about
                  // *her* number — that is the line this whole area does not
                  // cross.
                  if (test != null) ...[
                    const SizedBox(height: 24),
                    // Kept for revert (2026-09-28): 'What this test measures'
                    ttcSectionTitle('What ${test.name} measures'),
                    TtcCard(
                      child: Text(test.reading(TtcS.current().hinglish),
                          style: ttcBody(13.5, h: 1.6, color: ttcTitleInk)),
                    ),
                  ],
                  const SizedBox(height: 24),
                  ttcSectionTitle('The report itself'),
                  if (r.attachments.isEmpty)
                    TtcCard(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Kept for revert (2026-09-28): 'No photo
                            // saved for this one.'
                            Text('No photo saved for this result.',
                                style: ttcBody(13.5, h: 1.5)),
                            const SizedBox(height: 14),
                            TtcRecordsAction(
                                label: 'Add a photo of the report',
                                onTap: () => _attach(context, r)),
                          ]),
                    )
                  else
                    for (var i = 0; i < r.attachments.length; i++) ...[
                      _Sheet(
                        path: r.attachments[i],
                        caption: '${r.label} · ${ttcRecordDate(r.takenOn)} · '
                            '${i + 1} of ${r.attachments.length}',
                      ),
                      const SizedBox(height: 10),
                    ],
                  const SizedBox(height: 10),
                ],
              )),
            ],
          );
        },
      );

  Future<void> _attach(BuildContext context, TtcRecord r) async {
    final added = await showTtcAttachmentPicker(context, TtcS.current());
    if (added.isEmpty) return;
    TtcRecordsStore.instance
        .replace(r.copyWith(attachments: [...r.attachments, ...added]));
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label.toUpperCase(),
            style: pvManrope(
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
                color: ttcMuted)),
        const SizedBox(height: 4),
        Text(value, style: ttcBody(14, color: ttcTitleInk, w: FontWeight.w700)),
      ]);
}

/// The saved sheet, tappable into the viewer.
class _Sheet extends StatelessWidget {
  const _Sheet({required this.path, required this.caption});
  final String path;
  final String caption;

  @override
  Widget build(BuildContext context) => InkWell(
        borderRadius: BorderRadius.circular(ttcCardRadius),
        onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
          settings: const RouteSettings(name: 'ttc/record_sheet'),
          builder: (_) => TtcSheetViewer(path: path, caption: caption),
        )),
        child: TtcCard(
          child: Row(children: [
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: ttcPanel, borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.description_outlined,
                  size: 22, color: ttcTitleInk),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Photo of the lab sheet', style: ttcJakarta(14)),
                    const SizedBox(height: 3),
                    Text('Tap to open full screen',
                        style: ttcBody(12.5, color: ttcMuted)),
                  ]),
            ),
            Icon(Icons.chevron_right_rounded, size: 20, color: ttcMuted),
          ]),
        ),
      );
}
*/

/// The report, full screen, built for being held up to somebody else.
///
/// ⚠️ EVERY CHOICE HERE IS ABOUT ONE MOMENT: a phone turned round and handed
/// across a desk. So it is full-bleed on black rather than a card on a page,
/// it says out loud that the phone can be turned sideways because a lab sheet
/// is wider than it is tall, and the caption stays on screen so the person
/// receiving it knows what they are looking at without being told.
///
/// ⚠️ THE BRIGHTNESS LINE IS A PROMISE THIS APP CANNOT KEEP YET. The design
/// raises screen brightness on open. Doing that needs a platform channel and a
/// permission on some devices, so the label is NOT shown — a screen claiming to
/// have brightened itself when it has not is worse than one that says nothing.
/// Recorded in `docs/STILL-OPEN.md`.
class TtcSheetViewer extends StatelessWidget {
  const TtcSheetViewer({super.key, required this.path, required this.caption});

  final String path;
  final String caption;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.black,
        body: Stack(children: [
          Positioned.fill(
            child: InteractiveViewer(
              minScale: 1,
              maxScale: 5,
              child: Center(child: _Resolved(ref: path)),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Align(
                alignment: Alignment.topLeft,
                child: Material(
                  color: Colors.white.withValues(alpha: 0.16),
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: const SizedBox(
                        width: 38,
                        height: 38,
                        child: Icon(Icons.close_rounded,
                            size: 20, color: Colors.white)),
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(caption,
                      textAlign: TextAlign.center,
                      style: pvManrope(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                  const SizedBox(height: 6),
                  Text(
                      'Pinch to zoom. Turn the phone sideways to fill the '
                      'screen.',
                      textAlign: TextAlign.center,
                      style: pvManrope(
                          fontSize: 11.5,
                          height: 1.4,
                          color: Colors.white.withValues(alpha: 0.7))),
                ]),
              ),
            ),
          ),
        ]),
      );
}

/// The saved file, fetched through the storage layer.
///
/// ⚠️ THE APP HAS NEVER DISPLAYED AN ATTACHMENT BEFORE. Until now a saved
/// report was a chip with a filename on it, so nothing in the codebase turned a
/// stored ref into a picture. `StorageService.resolve` already does the hard
/// half — it handles both a storage object path and a legacy absolute local
/// path, and downloads and caches on demand — which is why this is a
/// `FutureBuilder` and not an `Image.file`.
///
/// ⚠️ A PDF IS NOT SHOWN, AND SAYS SO. Rendering one needs a package this repo
/// does not carry. A blank black screen where a report should be is the worst
/// possible outcome in a waiting room, so the file is named honestly instead.
class _Resolved extends StatefulWidget {
  const _Resolved({required this.ref});
  final String ref;

  @override
  State<_Resolved> createState() => _ResolvedState();
}

class _ResolvedState extends State<_Resolved> {
  late final Future<File?> _file = StorageService.resolve(widget.ref);

  @override
  Widget build(BuildContext context) {
    if (widget.ref.toLowerCase().endsWith('.pdf')) {
      return _Unshown(
          label: _basename(widget.ref),
          body: 'This report is a PDF. Open it from your files to show it.');
    }
    return FutureBuilder<File?>(
      future: _file,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const SizedBox(
            width: 26,
            height: 26,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          );
        }
        final f = snap.data;
        if (f == null) {
          return const _Unshown(
              label: 'Report not available',
              body: 'It may still be uploading, or it was saved on another '
                  'device.');
        }
        return Image.file(f, fit: BoxFit.contain);
      },
    );
  }
}

/// The file's own name, whichever slash the platform used.
///
/// ⚠️ NOT A REGEX. `RegExp('[/\\]')` reads correctly and is a syntax error: the
/// backslash escapes the closing bracket, so the character class never ends.
/// It is the kind of bug that survives review because the line looks obviously
/// right — two separate `lastIndexOf` calls are duller and cannot be wrong.
String ttcRecordFileName(String ref) => _basename(ref);

String _basename(String ref) {
  var out = ref;
  for (final sep in const ['/', '\\']) {
    final i = out.lastIndexOf(sep);
    if (i >= 0) out = out.substring(i + 1);
  }
  return out;
}

class _Unshown extends StatelessWidget {
  const _Unshown({required this.label, required this.body});
  final String label;
  final String body;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(34),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.description_outlined, size: 34, color: Colors.white54),
          const SizedBox(height: 14),
          Text(label,
              textAlign: TextAlign.center,
              style: pvManrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
          const SizedBox(height: 7),
          Text(body,
              textAlign: TextAlign.center,
              style: pvManrope(
                  fontSize: 12.5, height: 1.5, color: Colors.white70)),
        ]),
      );
}

// =============================================================================
//  1f — adding a result, photo first
// =============================================================================

/// ⚠️ THE CAMERA OPENS FIRST AND EVERYTHING ELSE IS OPTIONAL.
///
/// She is standing up holding a lab sheet with a dozen values on it. Capture is
/// one tap and cannot be got wrong; finding the right number among the twelve
/// and typing it accurately is the slow, error-prone part — and it can be done
/// later, sitting down, or never.
///
/// So the photograph IS the record. The only required field is the date, and
/// the date is prefilled with today.
///
/// ⚠️ AND "WHOSE RESULT" IS NEVER ASKED. It used to be a toggle in this sheet
/// AND a filter on the list — two places to think about the same thing. A semen
/// analysis is filed to the partner by the test itself; everything else follows
/// the last thing she filed, correctable on one quiet line at the bottom.
///
/// [testId] opens it with a library test already chosen, from the test
/// library's "Add my result" (tools pass, 2026-09-27). It opens on the form
/// rather than the camera, because she came from reading about the test, not
/// from holding the sheet up.
///
/// ⚠️ 2026-09-27: IT OPENS THE ONE ADD PAGE NOW, and the sheet below is kept
/// for revert only. That sheet opened a second, older sheet (the attachment
/// chooser) on its own first frame, which is the "two screens open to add"
/// the user saw. See the head of `ttc_record_edit_screen.dart`. The name and
/// signature stay so every caller keeps working; `typing: false` still means
/// "camera first", now the phone's camera over the page.
Future<void> showTtcRecordAdd(BuildContext context,
        {bool typing = false, String? testId}) =>
    openTtcRecordEdit(context,
        testId: testId, camera: !typing && testId == null);

// Kept for revert (2026-09-27): the sheet that stacked on another sheet.
// Future<void> showTtcRecordAdd(BuildContext context,
//         {bool typing = false, String? testId}) =>
//     showModalBottomSheet<void>(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       routeSettings: const RouteSettings(name: 'ttc/record_add'),
//       builder: (_) => _AddSheet(
//           startTyping: typing || testId != null, testId: testId),
//     );

/// Kept for revert (2026-09-27); nothing opens it now.
// ignore: unused_element
class _AddSheet extends StatefulWidget {
  // ignore: unused_element_parameter
  const _AddSheet({required this.startTyping, this.testId});
  final bool startTyping;
  final String? testId;

  @override
  State<_AddSheet> createState() => _AddSheetState();
}

class _AddSheetState extends State<_AddSheet> {
  final _label = TextEditingController();
  final _value = TextEditingController();
  final _unit = TextEditingController();

  List<String> _shots = [];
  DateTime _taken = DateTime.now();
  bool? _partner;
  bool _busy = false;

  /// The library test she picked from the suggestions, or arrived with.
  String? _pickedTestId;

  @override
  void initState() {
    super.initState();
    final preset = widget.testId == null ? null : ttcTestById(widget.testId!);
    if (preset != null) {
      _label.text = preset.name;
      _pickedTestId = preset.id;
    }
    // ⚠️ THE FORM FOLLOWS THE TYPING. The Save button, the suggestions and
    // whose it is all read the test name, and nothing rebuilt the sheet as she
    // typed, so the button looked dead until something else redrew it.
    _label.addListener(_onLabel);
    // Straight to the camera unless she chose to type.
    if (!widget.startTyping) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _capture());
    }
  }

  void _onLabel() {
    final picked =
        _pickedTestId == null ? null : ttcTestById(_pickedTestId!);
    // Editing the name away from the picked test un-picks it.
    if (picked != null &&
        picked.name.toLowerCase() != _label.text.trim().toLowerCase()) {
      _pickedTestId = null;
    }
    if (mounted) setState(() {});
  }

  /// Library tests whose name holds what she has typed, so "amh" offers
  /// "AMH" and a repeat files under the same group as the first reading.
  List<TtcTest> get _suggestions {
    final q = _label.text.trim().toLowerCase();
    if (q.isEmpty || _pickedTestId != null) return const [];
    return ttcTests
        .where((t) =>
            t.name.toLowerCase().contains(q) && t.name.toLowerCase() != q)
        .take(4)
        .toList();
  }

  @override
  void dispose() {
    _label.removeListener(_onLabel);
    _label.dispose();
    _value.dispose();
    _unit.dispose();
    super.dispose();
  }

  Future<void> _capture() async {
    final picked = await showTtcAttachmentPicker(context, TtcS.current());
    if (picked.isEmpty || !mounted) return;
    setState(() => _busy = true);
    final refs = <String>[];
    for (final p in picked) {
      refs.add(await StorageService.upload(p, 'ttc_record'));
    }
    if (!mounted) return;
    setState(() {
      _shots = [..._shots, ...refs];
      _busy = false;
    });
  }

  /// ⚠️ THE TEST DECIDES WHOSE IT IS, WHERE THE TEST CAN. A semen analysis is
  /// never hers. Everything else follows what she filed last, which is right
  /// far more often than a toggle nobody reads.
  bool get _whose {
    if (_partner != null) return _partner!;
    final picked =
        _pickedTestId == null ? null : ttcTestById(_pickedTestId!);
    if (picked != null) return picked.forHim;
    final label = _label.text.trim().toLowerCase();
    final test = ttcTests.where((t) => t.name.toLowerCase().startsWith(label));
    if (label.isNotEmpty && test.isNotEmpty) return test.first.forHim;
    final last = TtcRecordsStore.instance.records;
    return last.isEmpty ? false : last.first.forPartner;
  }

  bool get _canSave => _shots.isNotEmpty || _label.text.trim().isNotEmpty;

  void _save() {
    final label = _label.text.trim();
    final match = ttcTests
        .where((t) => t.name.toLowerCase().startsWith(label.toLowerCase()));
    final rec = TtcRecordsStore.instance.add(
      label: label.isEmpty ? 'Report' : label,
      takenOn: _taken,
      testId: _pickedTestId ??
          (label.isEmpty || match.isEmpty ? null : match.first.id),
      value: _value.text.trim(),
      unit: _unit.text.trim(),
      forPartner: _whose,
    );
    if (_shots.isNotEmpty) {
      TtcRecordsStore.instance.replace(rec.copyWith(attachments: _shots));
    }
    HapticFeedback.selectionClick();
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final saved = _shots.isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.92),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 22),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(
                          color: ttcBorder,
                          borderRadius: BorderRadius.circular(999)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('ADD A RESULT',
                      style: pvManrope(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                          color: ttcMuted)),
                  const SizedBox(height: 8),
                  Text(
                      saved
                          ? 'Photo saved.'
                          // A form opened to type into said "fit the sheet in
                          // the frame" over no camera at all.
                          : widget.startTyping
                              ? 'Type in your result.'
                              : 'Fit the whole sheet in the frame.',
                      style: ttcFraunces(22,
                          w: FontWeight.w600, color: ttcTitleInk, h: 1.2)),
                  const SizedBox(height: 6),
                  Text(
                      saved
                          ? 'Everything below is optional. You can come back '
                              'to it.'
                          : 'You can type the number in later.',
                      style: ttcBody(13, h: 1.45)),
                  const SizedBox(height: 18),

                  if (_busy)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 18),
                      child: Center(
                          child: SizedBox(
                              width: 22,
                              height: 22,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2))),
                    )
                  else if (saved)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                          // Kept for revert (2026-09-29, no tinted slab behind text): color: ttcPanel,
                          color: Colors.white, border: const Border.fromBorderSide(BorderSide(color: ttcLine)),
                          borderRadius: BorderRadius.circular(16)),
                      child: Row(children: [
                        Icon(Icons.check_circle_outline_rounded,
                            size: 18, color: ttcTitleInk),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                              '${_shots.length} '
                              '${_shots.length == 1 ? 'photo' : 'photos'} '
                              'attached',
                              style: ttcBody(13,
                                  color: ttcTitleInk, w: FontWeight.w700)),
                        ),
                        GestureDetector(
                          onTap: _capture,
                          behavior: HitTestBehavior.opaque,
                          child: Text('Add another',
                              style: ttcBody(12.5,
                                  color: ttcSoft, w: FontWeight.w800)),
                        ),
                      ]),
                    )
                  else
                    TtcRecordsAction(
                        label: 'Open the camera', onTap: _capture),

                  const SizedBox(height: 20),
                  // ⚠️ WHOSE IS ASKED, AS A TWO-WAY SWITCH, AND IT IS
                  // ALREADY ANSWERED (tools pass, 2026-09-27). The quiet
                  // "Filing under You · Partner instead" line was easy to
                  // miss, so his results got filed as hers and the doctor
                  // view read wrong. The switch starts on the same guess the
                  // line made, so it costs no tap when the guess is right.
                  Text('WHOSE RESULT IS THIS',
                      style: pvManrope(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                          color: ttcMuted)),
                  const SizedBox(height: 6),
                  _TwoWay(
                    left: 'Yours',
                    right: "Your partner's",
                    rightOn: _whose,
                    onPick: (partner) => setState(() => _partner = partner),
                  ),
                  const SizedBox(height: 14),
                  // Kept for revert (2026-09-28): 'What test was it'
                  _Field(label: 'Name of the test', controller: _label),
                  if (_suggestions.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      for (final s in _suggestions)
                        GestureDetector(
                          key: ValueKey('ttc_rec_suggest_${s.id}'),
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            _pickedTestId = s.id;
                            _label.text = s.name;
                            _label.selection = TextSelection.collapsed(
                                offset: s.name.length);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: ttcBorder),
                            ),
                            child: Text(s.name,
                                style: ttcBody(12.5,
                                    color: ttcTitleInk, w: FontWeight.w700)),
                          ),
                        ),
                    ]),
                  ],
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                      flex: 3,
                      child: _Field(
                          label: 'The number',
                          controller: _value,
                          keyboard: const TextInputType.numberWithOptions(
                              decimal: true)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: _Field(label: 'Unit', controller: _unit),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  _DateField(
                    taken: _taken,
                    onPick: (d) => setState(() => _taken = d),
                  ),

                  // Kept for revert (2026-09-27): the quiet line, replaced by
                  // the two-way switch at the top of the form.
                  // const SizedBox(height: 14),
                  // // ⚠️ ONE QUIET LINE, NOT A TOGGLE. ...
                  // Row(children: [
                  //   Expanded(
                  //     child: Text('Filing under ${ttcWhose(_whose)}',
                  //         style: ttcBody(12.5, color: ttcSoft)),
                  //   ),
                  //   GestureDetector(
                  //     onTap: () => setState(() => _partner = !_whose),
                  //     behavior: HitTestBehavior.opaque,
                  //     child: Text('${ttcWhose(!_whose)} instead',
                  //         style: ttcBody(12.5,
                  //             color: ttcTitleInk, w: FontWeight.w800)),
                  //   ),
                  // ]),

                  const SizedBox(height: 20),
                  // ⚠️ AN HONEST DISABLED STATE (tools pass, 2026-09-27). It
                  // was `onTap: _canSave ? _save : () {}`: a live-looking
                  // button that swallowed the tap. Now it looks unavailable
                  // and says what it is waiting for.
                  TtcRecordsAction(
                      key: const ValueKey('ttc_rec_save'),
                      label: 'Save this result',
                      enabled: _canSave,
                      onTap: _save),
                  if (!_canSave)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Center(
                        child: Text('Add a photo or the test name to save.',
                            style: ttcBody(12.5,
                                color: ttcBrown, w: FontWeight.w700)),
                      ),
                    ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text('This is a record, not a judgement.',
                        style: ttcBody(12, color: ttcMuted)),
                  ),
                ]),
          ),
        ),
      ),
    );
  }
}

/// Two answers, one chosen. Used for whose a result is.
class _TwoWay extends StatelessWidget {
  const _TwoWay({
    required this.left,
    required this.right,
    required this.rightOn,
    required this.onPick,
  });

  final String left;
  final String right;
  final bool rightOn;
  final ValueChanged<bool> onPick;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
            color: ttcPanel, borderRadius: BorderRadius.circular(999)),
        child: Row(children: [
          _seg(left, !rightOn, () => onPick(false)),
          _seg(right, rightOn, () => onPick(true)),
        ]),
      );

  Widget _seg(String label, bool on, VoidCallback onTap) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: on ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
              boxShadow: on ? ttcCardShadow : null,
            ),
            child: Text(label,
                style: ttcBody(13,
                    color: on ? ttcTitleInk : ttcSoft, w: FontWeight.w800)),
          ),
        ),
      );
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    this.keyboard,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboard;

  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label.toUpperCase(),
            style: pvManrope(
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
                color: ttcMuted)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboard,
          style: ttcBody(14, color: ttcTitleInk, w: FontWeight.w700),
          // White with a hairline, ink when focused: the tool shell's field,
          // the same as the add page's (2026-09-27). Kept for revert:
          // fillColor: ttcPanel, border: BorderSide.none (a grey V1 well).
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: ttcLine, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: ttcTitleInk, width: 1.5),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: ttcLine, width: 1.5),
            ),
          ),
        ),
      ]);
}

class _DateField extends StatelessWidget {
  const _DateField({required this.taken, required this.onPick});

  final DateTime taken;
  final ValueChanged<DateTime> onPick;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('DATE ON THE REPORT',
              style: pvManrope(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: ttcMuted)),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: taken,
                firstDate: DateTime(2015),
                // ⚠️ NO FUTURE DATES. A report cannot have been printed
                // tomorrow, and a future date would sort to the top of every
                // group and become the "latest" reading for ever.
                lastDate: DateTime.now(),
              );
              if (picked != null) onPick(picked);
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                  color: ttcPanel, borderRadius: BorderRadius.circular(14)),
              child: Row(children: [
                Expanded(
                  child: Text(ttcRecordDate(taken),
                      style: ttcBody(14,
                          color: ttcTitleInk, w: FontWeight.w700)),
                ),
                Icon(Icons.calendar_today_outlined, size: 15, color: ttcMuted),
              ]),
            ),
          ),
        ],
      );
}

// =============================================================================
//  1h — into the appointment
// =============================================================================

/// ⚠️ A SHEET, NOT A SCREEN, AND THAT WAS THE CALL. The waiting-room moment is
/// real, but a separate "appointment mode" destination risks becoming a second
/// app. PCOS already has this shape — "What to take to your doctor" is a small
/// shareable summary rather than a place you go — and one pattern for one job
/// is worth more than a better version of two.
///
/// ⚠️ TYPE IS ONE TIER UP THROUGHOUT, because it gets read at arm's length by
/// somebody else. And it ends on what is NOT here, which is the line that stops
/// a summary being mistaken for the whole file.
Future<void> showTtcRecordsForAppointment(
  BuildContext context, {
  TtcAppointment? appointment,
}) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AppointmentSheet(appointment: appointment),
    );

class _AppointmentSheet extends StatefulWidget {
  const _AppointmentSheet({this.appointment});

  /// The appointment this was opened for, where there is one. It names the
  /// sheet rather than changing it — the six most recent results are the six
  /// most recent results whoever is about to read them.
  final TtcAppointment? appointment;

  @override
  State<_AppointmentSheet> createState() => _AppointmentSheetState();
}

class _AppointmentSheetState extends State<_AppointmentSheet> {
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    // Fetch the PDF fonts now, while she reads the sheet, so the first share
    // does not fail for want of a connection she had a minute ago.
    TtcRecordsPdf.warmFonts(TtcLang.instance.hinglish
        ? AppLanguage.hinglish
        : AppLanguage.english);
  }

  TtcAppointment? get appointment => widget.appointment;

  /// ⚠️ THE SHEET SHOWS SIX; THE PDF CARRIES EVERYTHING. Not an inconsistency —
  /// the two are read by different people in different rooms. See the head of
  /// `ttc_records_pdf.dart` for why a medical summary must not quietly stop at
  /// six.
  Future<void> _share() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final bytes = await TtcRecordsPdf.build(
        // ⚠️ TTC KEEPS ITS OWN LANGUAGE FLAG. `TtcLang` is a bool, the PDF
        // font loader takes `AppLanguage`, and the two have never met. The
        // conversion belongs here rather than in the PDF, which should not
        // know that one stage models language differently from the rest.
        lang: TtcLang.instance.hinglish
            ? AppLanguage.hinglish
            : AppLanguage.english,
        forAppointment: appointment?.title,
      );
      if (!mounted) return;
      if (bytes == null) {
        // Fonts did not load. Say what happened rather than hand over a
        // document that may print as empty boxes.
        // The app's one notice, not a raw grey SnackBar (2026-09-27).
        pvSnack(
            context,
            "We couldn't make the file. It needs an internet connection the "
            'first time. Your records are safe either way.',
            lift: 24);
        return;
      }
      await TtcRecordsPdf.present(bytes);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _eyebrow() {
    final a = appointment;
    if (a == null) return 'TO TAKE IN';
    final d = a.startsLocal;
    final now = DateTime.now();
    final today = d.year == now.year && d.month == now.month && d.day == now.day;
    return today ? 'FOR TODAY' : 'FOR ${ttcRecordDate(d).toUpperCase()}';
  }

  @override
  Widget build(BuildContext context) {
    final groups = ttcGroupedRecords().take(6).toList();
    final coverage = ttcRecordCoverage();

    return Container(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.9),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                        color: ttcBorder,
                        borderRadius: BorderRadius.circular(999)),
                  ),
                ),
                const SizedBox(height: 18),
                Row(children: [
                  Expanded(
                    child: Text(_eyebrow(),
                        style: pvManrope(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: ttcMuted)),
                  ),
                  // Kept for revert (2026-09-27): "Share as PDF" was a small
                  // link up here, beside the eyebrow, easy to miss and the
                  // only way out of the phone. It is the sheet's main button
                  // now, under the words that say what it makes.
                ]),
                const SizedBox(height: 7),
                if (appointment != null) ...[
                  Text(appointment!.title,
                      style: ttcBody(14.5,
                          color: ttcTitleInk, w: FontWeight.w800)),
                  const SizedBox(height: 7),
                ],
                // Plainer, and true: the list is newest first, one row per
                // test. Kept for revert: 'The most recent, yours and theirs,
                // in date order.'
                Text('Your latest results, newest first.',
                    style: ttcFraunces(21,
                        w: FontWeight.w600, color: ttcTitleInk, h: 1.25)),
                const SizedBox(height: 8),
                // ⚠️ SAY WHAT THE BUTTON MAKES (tools pass, 2026-09-27).
                Text(
                    'Show this card to your doctor, or make one PDF of all '
                    'your results and photos to print or send. The PDF needs '
                    'internet the first time.',
                    style: ttcBody(12.5, color: ttcSoft, h: 1.5)),
                const SizedBox(height: 14),
                if (_busy)
                  const Center(
                      child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2)),
                  ))
                else
                  TtcToolPrimary(
                      key: const ValueKey('ttc_rec_pdf'),
                      label: 'Make a PDF to print or send',
                      onTap: _share),
                /*
                // Kept for revert (2026-09-27): the header link and the old
                // title and line.
                  // ⚠️ THE ONE PLACE THIS SHEET CAN LEAVE THE PHONE. It sits
                  // here rather than on the records screen because sharing is
                  // the handover moment, and the handover moment is what this
                  // sheet is. A share control on the folder itself would invite
                  // it at every other moment too.
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _share,
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      if (_busy)
                        const SizedBox(
                            width: 13,
                            height: 13,
                            child: CircularProgressIndicator(strokeWidth: 1.8))
                      else
                        Icon(Icons.ios_share_rounded,
                            size: 15, color: ttcTitleInk),
                      const SizedBox(width: 6),
                      Text(_busy ? 'Preparing' : 'Share as PDF',
                          style: ttcBody(12.5,
                              color: ttcTitleInk, w: FontWeight.w800)),
                    ]),
                  ),
                ]),
                const SizedBox(height: 7),
                if (appointment != null) ...[
                  Text(appointment!.title,
                      style: ttcBody(14.5,
                          color: ttcTitleInk, w: FontWeight.w800)),
                  const SizedBox(height: 7),
                ],
                Text('The most recent, yours and theirs, in date order.',
                    style: ttcFraunces(21,
                        w: FontWeight.w600, color: ttcTitleInk, h: 1.25)),
                const SizedBox(height: 8),
                // ⚠️ SAY WHAT THE BUTTON MAKES (tools pass, 2026-09-27). It
                // opened the phone's print screen with no word first, so it
                // looked like printing, and the first try failed offline with
                // no warning.
                Text(
                    'Share as PDF makes one file of all your results and '
                    'photos, to print or send. It needs internet the first '
                    'time.',
                    style: ttcBody(12.5, color: ttcSoft, h: 1.5)),
                */
                const SizedBox(height: 18),
                for (final g in groups) ...[
                  _Line(group: g),
                  const SizedBox(height: 16),
                ],
                if (coverage.notAdded.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  ttcDivider(),
                  const SizedBox(height: 14),
                  // Kept for revert (2026-09-28): 'NOT IN HERE'
                  Text('NOT IN YOUR RECORDS YET',
                      style: pvManrope(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: ttcMuted)),
                  const SizedBox(height: 6),
                  Text(
                      coverage.notAdded.map((t) => t.name).join(', '),
                      style: ttcBody(14, h: 1.5, color: ttcSoft)),
                ],
                const SizedBox(height: 18),
                Text(
                    'To see the photo of a report, tap its row on the '
                    'previous screen.',
                    style: ttcBody(12.5, color: ttcMuted, h: 1.5)),
              ]),
        ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.group});
  final TtcRecordGroup group;

  @override
  Widget build(BuildContext context) {
    final latest = group.latest;
    final value = ttcRecordValue(latest);
    final before = group.repeated ? ttcRecordValue(group.oldest) : '';

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(value.isEmpty ? group.label : '${group.label}  $value',
          style: ttcBody(16.5, color: ttcTitleInk, w: FontWeight.w800)),
      const SizedBox(height: 3),
      Text(
          '${ttcRecordDate(latest.takenOn)}'
          '${before.isEmpty ? '' : ' · was $before in '
              '${_months[group.oldest.takenOn.month - 1]} '
              '${group.oldest.takenOn.year}'}'
          '${latest.note != null && latest.note!.trim().isNotEmpty
              ? ' · note saved'
              : ''}',
          style: ttcBody(13.5, color: ttcSoft, h: 1.4)),
    ]);
  }
}

// =============================================================================
//  Completing a photo-only record — "Type it"
// -----------------------------------------------------------------------------
//  ⚠️ THE OTHER HALF OF PHOTO-FIRST ADDING. Letting her save a photograph and
//  nothing else is only kind if there is a way back to finish it later. Without
//  this the fastest path to filing a result also permanently produces a row
//  that can never show a value or join a trend, and "optional" quietly becomes
//  "unavailable".
//
//  It edits the value and the unit and nothing else. The label, the date and
//  whose it is were decided when it was filed; a two-field sheet that can
//  silently rewrite four things is how records drift.
// =============================================================================

Future<void> showTtcTypeValue(BuildContext context, TtcRecord record) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TypeSheet(record: record),
    );

class _TypeSheet extends StatefulWidget {
  const _TypeSheet({required this.record});
  final TtcRecord record;

  @override
  State<_TypeSheet> createState() => _TypeSheetState();
}

class _TypeSheetState extends State<_TypeSheet> {
  late final _value = TextEditingController(text: widget.record.value);
  late final _unit = TextEditingController(text: widget.record.unit);

  @override
  void dispose() {
    _value.dispose();
    _unit.dispose();
    super.dispose();
  }

  void _save() {
    TtcRecordsStore.instance.replace(widget.record.copyWith(
      value: _value.text.trim(),
      unit: _unit.text.trim(),
    ));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 22),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 38,
                        height: 4,
                        decoration: BoxDecoration(
                            color: ttcBorder,
                            borderRadius: BorderRadius.circular(999)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(widget.record.label.toUpperCase(),
                        style: pvManrope(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                            color: ttcMuted)),
                    const SizedBox(height: 8),
                    Text('What does the report say?',
                        style: ttcFraunces(22,
                            w: FontWeight.w600, color: ttcTitleInk, h: 1.2)),
                    const SizedBox(height: 6),
                    Text(
                        'Copy the number exactly as it\'s printed. '
                        '${ttcRecordDate(widget.record.takenOn)}.',
                        style: ttcBody(13, h: 1.45)),
                    const SizedBox(height: 18),
                    Row(children: [
                      Expanded(
                        flex: 3,
                        // A text keyboard, not a number pad (2026-09-27):
                        // reports also say "Normal", "<0.5" or "Grade II",
                        // and a number pad cannot type any of them.
                        child: _Field(label: 'The result', controller: _value),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: _Field(label: 'Unit', controller: _unit),
                      ),
                    ]),
                    const SizedBox(height: 20),
                    // Kept for revert (2026-09-28): 'Save it'
                    TtcToolPrimary(label: 'Save the result', onTap: _save),
                    const SizedBox(height: 10),
                    Center(
                      child: Text('The photo stays either way.',
                          style: ttcBody(12, color: ttcMuted)),
                    ),
                  ]),
            ),
          ),
        ),
      );
}
