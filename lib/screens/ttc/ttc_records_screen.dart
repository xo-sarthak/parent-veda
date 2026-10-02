// =============================================================================
//  TTC - Health Records / Reports
// -----------------------------------------------------------------------------
//  Two Tools tiles, one screen. "Reports" opens it on results; "Health Records"
//  opens it whole - because a couple looking for their AMH result and a couple
//  looking for "everything we have had done" want the same folder, and two
//  folders that must agree with each other is how records rot.
//
//  Both people's results live here together. A records screen holding only her
//  results would rebuild the exact asymmetry this stage exists to correct: his
//  semen analysis belongs beside her AMH, in one date order.
//
//  The product never interprets a result. It stores what the report said, shows
//  the library's plain-language explanation next to it, and hands the whole
//  thing to a doctor.
//
//  ---------------------------------------------------------------------------
//  REBUILT 2026-09-03 FROM THE "TTC RECORDS" DESIGN PROJECT
//  ---------------------------------------------------------------------------
//
//  This file is now the frame. Everything inside it lives in
//  `ttc_records_v2.dart`, because the redesign is a different reading of the
//  same data rather than a different feature: same store, same records, same
//  attachments, grouped by test instead of listed by date.
//
//  What changed, and why each one was a defect rather than a taste:
//
//  * **Grouped, not listed.** Two AMH results a year apart used to be two
//    unrelated cards, possibly screens apart, and the one thing worth knowing —
//    which way it moved — was invisible. See `ttc_records_grouping.dart`.
//  * **The Both/Her/Him segmented control became a count line and a small
//    filter.** Ownership belongs on the row, not in a control above it; three
//    segments spent a third of the first screen answering a question nobody
//    had asked yet.
//  * **Adding is photo-first.** The old dialog wanted a label, a value, a unit
//    and a date before it would save anything — which is why reports stayed in
//    her gallery. Now the camera opens straight from Add, and the only required
//    field is the date, prefilled with today.
//  * **The attachment can finally be opened.** The app has stored file refs
//    since records shipped and had never once displayed one: the folder held
//    her reports and could not show them.
//
//  The old flat list and the old add dialog are kept below, commented out per
//  the house rule, so the previous behaviour is one revert away.
// =============================================================================

import 'package:flutter/material.dart';

import '../../ttc/ttc_records_grouping.dart';
import '../../ttc/ttc_records_store.dart';
import 'ttc_common.dart';
import 'ttc_record_edit_screen.dart' show openTtcRecordEdit;
import 'ttc_records_v2.dart';
import 'ttc_strings.dart';
import 'ttc_tool_chrome.dart';

/// [addTestId] opens the add form on arrival with that library test chosen,
/// from the test library's "Add my result" (tools pass, 2026-09-27). She lands
/// in the folder, so the saved result is in front of her when the form shuts.
void openTtcRecords(BuildContext context,
    {bool resultsOnly = false, String? addTestId}) {
  Navigator.of(context).push(MaterialPageRoute<void>(
    builder: (_) =>
        TtcRecordsScreen(resultsOnly: resultsOnly, addTestId: addTestId),
    settings: RouteSettings(name: resultsOnly ? 'ttc/reports' : 'ttc/records'),
  ));
}

class TtcRecordsScreen extends StatefulWidget {
  const TtcRecordsScreen(
      {super.key, this.resultsOnly = false, this.addTestId});

  /// True when opened from the Reports tile - the same folder, filtered to
  /// entries that came from the test library.
  final bool resultsOnly;

  /// A library test to open the add form on, straight away.
  final String? addTestId;

  @override
  State<TtcRecordsScreen> createState() => _TtcRecordsScreenState();
}

class _TtcRecordsScreenState extends State<TtcRecordsScreen> {
  /// null = everyone. Otherwise narrow to one person's results.
  bool? _partner;

  @override
  void initState() {
    super.initState();
    final id = widget.addTestId;
    if (id != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) showTtcRecordAdd(context, testId: id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([TtcRecordsStore.instance, TtcLang.instance]),
      builder: (context, _) {
        final t = TtcS.current();
        final groups = ttcGroupedRecords(resultsOnly: widget.resultsOnly);
        final total = groups.fold<int>(0, (n, g) => n + g.count);
        final his = groups
            .where((g) => g.forPartner)
            .fold<int>(0, (n, g) => n + g.count);
        final soon = _nextAppointment();

        return TtcToolScaffold(
          hue: kTtcRecordsHue,
          // The tool's mark over the eyebrow (2026-09-29, ttc_tool_marks.dart).
          toolId: 'records',
          // ⚠️ ONE NAME (tools pass, 2026-09-27): the Tools tile says
          // "Records and reports" and this said "Health Records". Kept for
          // revert: eyebrow: widget.resultsOnly ? t.recordsReports : t.recordsTitle,
          eyebrow: widget.resultsOnly
              ? t.recordsReports
              : t.hinglish
                  ? t.recordsTitle
                  : 'Records and reports',
          // Plainer (2026-09-27). Kept for revert:
          // title: 'Every result and letter, in one place.',
          title: 'Your test results, in one place.',
          // ⚠️ SAY WHAT SHE DOES HERE, AND SAY IT TRUE. The intro promised
          // "in date order" over a folder grouped by test. Kept for revert:
          // intro: t.recordsIntro,
          intro: t.hinglish
              ? t.recordsIntro
              : "Keep each test report here, yours and your partner's. Take "
                  'a photo of the paper, or type the number in.',
          // ⚠️ WHITE WITH A HAIRLINE, NOT A FILLED PURPLE PILL. It was
          // `ttcPurple`, which is the one thing this stage stopped doing: a
          // solid brand-coloured control shouts, and this one was the loudest
          // object on a screen whose entire job is to be calm about medical
          // results.
          // ⚠️ ONE ADD, ONE PAGE (2026-09-27). This opened a sheet that
          // opened a second, older sheet on top of itself: "two screens open
          // to add". It opens the add page now, with the three ways to bring
          // the report in as rows on it. It does not start the camera: from
          // here she may be holding a PDF, not a sheet of paper. The empty
          // state's "Photograph a report" is the camera-first door.
          action: TtcRecordsHeroPill(
            key: const ValueKey('ttc_rec_add'),
            icon: Icons.add_rounded,
            // Change 5 (2026-09-28): the pill names what it adds; the Hindi
            // side keeps its words. Kept for revert: label: t.recordsAdd,
            label: t.hinglish ? t.recordsAdd : 'Add a result',
            onTap: () => openTtcRecordEdit(context),
          ),
          /*
          // Kept for revert (2026-09-27): the same pill, opening the sheet.
          action: GestureDetector(
            onTap: () => showTtcRecordAdd(context),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: ttcBorder),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.add_rounded, size: 15, color: ttcTitleInk),
                const SizedBox(width: 5),
                Text(t.recordsAdd,
                    style:
                        ttcBody(12, color: ttcTitleInk, w: FontWeight.w800)),
              ]),
            ),
          ),
          */
          children: [
            ttcToolPad(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Kept for revert (2026-09-29): the count line and the filter
                // drew ABOVE the "Your results" heading; they are the
                // heading's own summary now, passed in as `summary`.
                // // ⚠️ A COUNT LINE, NOT A CONTROL. It states what is here and
                // // whose it is in one sentence. The filter beside it is a quiet
                // // chip rather than three segments, because narrowing to one
                // // person is something she does occasionally and the default is
                // // right almost always.
                // if (total > 0) ...[
                //   Row(children: [
                //     Expanded(
                //       child: Text(_countLine(total, his),
                //           style: ttcBody(12.5, color: ttcSoft, h: 1.4)),
                //     ),
                //     const SizedBox(width: 10),
                //     // Kept for revert (2026-09-27): the one-word chip that
                //     // cycled Everyone, You, Partner on each tap. Nobody could
                //     // tell it was a filter until it changed under them.
                //     // _WhoseChip(
                //     //   whose: _partner,
                //     //   onPick: (v) => setState(() => _partner = v),
                //     // ),
                //   ]),
                //   const SizedBox(height: 10),
                //   // Three answers side by side, so she can see all of them
                //   // before she taps. Only drawn when both of you have results:
                //   // a filter with one side empty is a control for nothing.
                //   if (his > 0 && his < total)
                //     _WhoseSegments(
                //       whose: _partner,
                //       onPick: (v) => setState(() => _partner = v),
                //     ),
                //   const SizedBox(height: 18),
                // ],
                const SizedBox(height: 6),

                TtcRecordsBody(
                  // The filter only exists while both of you have results; if
                  // one side empties, it must not keep narrowing to nothing
                  // with no control left to undo it.
                  onlyPartner: his > 0 && his < total ? _partner : null,
                  resultsOnly: widget.resultsOnly,
                  // ⚠️ A COUNT LINE, NOT A CONTROL. It states what is here
                  // and whose it is in one sentence; the three-way filter
                  // shows only while both of you have results (a filter with
                  // one side empty is a control for nothing).
                  summary: total == 0
                      ? null
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_countLine(total, his),
                                key: const ValueKey('ttc_rec_count_line'),
                                style: ttcBody(13, color: ttcSoft, h: 1.4)),
                            if (his > 0 && his < total) ...[
                              const SizedBox(height: 12),
                              _WhoseSegments(
                                whose: _partner,
                                onPick: (v) => setState(() => _partner = v),
                              ),
                            ],
                          ],
                        ),
                ),

                // ⚠️ THE WAY OUT OF THE PHONE IS ALWAYS HERE NOW (2026-09-27).
                // It used to exist only with an appointment booked within
                // seven days, so the PDF (the one thing a new clinic asks
                // for) could not be made at all the rest of the time. The row
                // is always there once something is filed; an appointment
                // soon only changes its words, not whether it exists.
                // Kept for revert: `if (total > 0 && soon != null)`.
                if (total > 0) ...[
                  const SizedBox(height: 20),
                  _IntoTheAppointment(
                    appointment: soon,
                    onTap: () =>
                        showTtcRecordsForAppointment(context, appointment: soon),
                  ),
                ],

                /*
                // Kept for revert (2026-09-27):
                // ⚠️ THE WAITING-ROOM DOOR, AND IT ONLY EXISTS WHEN THERE IS
                // SOMETHING TO WALK INTO. An "into the appointment" link on a
                // folder with nothing in it, or with no appointment booked, is
                // a control advertising a moment that is not happening.
                //
                // It sits below the records rather than above them because it
                // is the thing she reaches for last - in the corridor, with the
                // folder already filled.
                if (total > 0 && soon != null) ...[
                  const SizedBox(height: 20),
                  _IntoTheAppointment(
                    appointment: soon,
                    onTap: () =>
                        showTtcRecordsForAppointment(context, appointment: soon),
                  ),
                ],

                */
                const SizedBox(height: 18),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(Icons.info_outline_rounded,
                      size: 15, color: ttcMuted),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(t.recordsDisclaimer,
                        style: ttcBody(11.5, color: ttcMuted, h: 1.5)),
                  ),
                ]),
                const SizedBox(height: 26),
              ],
            )),
          ],
        );
      },
    );
  }

  /// The appointment worth carrying the folder into: the next one, and only
  /// while it is close enough to be the reason she opened this.
  ///
  /// Seven days is the window because a scan booked next month is not a reason
  /// to gather results today, and a link that is always there stops being a
  /// prompt and becomes furniture.
  TtcAppointment? _nextAppointment() {
    final soon = TtcAppointmentsStore.instance.upcoming;
    if (soon.isEmpty) return null;
    final first = soon.first;
    return first.startsLocal.difference(DateTime.now()).inDays <= 7
        ? first
        : null;
  }

  /// "15 results · You 11 · Partner 4", and the honest short forms of it.
  ///
  /// A split is only printed when there is a split. "You 11 · Partner 0" states
  /// an absence nobody asked about, on a screen where his absence from the
  /// folder is a sore point rather than a statistic.
  ///
  /// ⚠️ SAID AS A SENTENCE (2026-09-29, the user on build 20: "1 result · all
  /// Partner" reads oddly). The one-word tags "You" / "Partner" were never
  /// words anyone says about a result; the owner is said the way the add page
  /// says it, "yours" and "your partner's". Kept for revert:
  ///   if (his == total) return '$head · all Partner';
  ///   return '$head · You ${total - his} · Partner $his';
  String _countLine(int total, int his) => ttcRecordsCountLine(total, his);
}

/// "3 results · 2 yours, 1 your partner's"; "1 result · your partner's";
/// "4 results · all your partner's". Public for the test.
String ttcRecordsCountLine(int total, int his) {
  final head = '$total ${total == 1 ? 'result' : 'results'}';
  if (his == 0) return head;
  if (his == total) {
    return total == 1 ? "$head · your partner's" : "$head · all your partner's";
  }
  return "$head · ${total - his} yours, $his your partner's";
}

/// The one row that turns a folder into something you hand over.
class _IntoTheAppointment extends StatelessWidget {
  const _IntoTheAppointment({required this.appointment, required this.onTap});

  /// Null when nothing is booked soon: the row still opens the card and the
  /// PDF, it just does not name a visit.
  final TtcAppointment? appointment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final a = appointment;
    final String eyebrow;
    final String title;
    final String body;
    if (a == null) {
      eyebrow = 'For a doctor';
      title = 'Show or send your results';
      body = 'Your latest results on one card, or a PDF to print or send.';
    } else {
      final d = a.startsLocal;
      final today = DateTime.now();
      final isToday =
          d.year == today.year && d.month == today.month && d.day == today.day;
      eyebrow = isToday ? 'For today' : 'Before ${ttcRecordDate(d)}';
      title = a.title;
      body = 'The most recent results, in one card you can hand over.';
    }

    return InkWell(
      key: const ValueKey('ttc_rec_share_row'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 14, 10, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: ttcLine),
        ),
        child: Row(children: [
          const Icon(Icons.ios_share_rounded, size: 19, color: ttcTitleInk),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(eyebrow,
                      style: ttcBody(11, color: ttcMuted, w: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ttcJakarta(14.5)),
                  const SizedBox(height: 3),
                  Text(body, style: ttcBody(12.5, color: ttcSoft, h: 1.45)),
                ]),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right_rounded, size: 20, color: ttcMuted),
        ]),
      ),
    );
  }
}

/*
// Kept for revert (2026-09-27): the appointment-only row.
class _IntoTheAppointment extends StatelessWidget {
  const _IntoTheAppointment({required this.appointment, required this.onTap});

  final TtcAppointment appointment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final d = appointment.startsLocal;
    final today = DateTime.now();
    final isToday =
        d.year == today.year && d.month == today.month && d.day == today.day;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(ttcCardRadius),
          border: Border.all(color: ttcBorder),
        ),
        child: Row(children: [
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isToday ? 'For today' : 'Before ${ttcRecordDate(d)}',
                      style: ttcBody(11,
                          color: ttcMuted, w: FontWeight.w800)),
                  const SizedBox(height: 5),
                  Text(appointment.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ttcJakarta(14.5)),
                  const SizedBox(height: 4),
                  Text('The most recent results, in one card you can hand over.',
                      style: ttcBody(12.5, color: ttcSoft, h: 1.45)),
                ]),
          ),
          const SizedBox(width: 10),
          const Icon(Icons.chevron_right_rounded, size: 20, color: ttcMuted),
        ]),
      ),
    );
  }
}

*/

/// The filter as three visible answers: Everyone, You, Partner.
class _WhoseSegments extends StatelessWidget {
  const _WhoseSegments({required this.whose, required this.onPick});

  final bool? whose;
  final ValueChanged<bool?> onPick;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
            color: ttcPanel, borderRadius: BorderRadius.circular(999)),
        child: Row(children: [
          // Said as the add page says whose (2026-09-29). Kept for revert:
          // ('Everyone', null), ('You', false), ('Partner', true).
          for (final (label, value) in const [
            ('Both of you', null),
            ('Yours', false),
            ("Your partner's", true),
          ])
            Expanded(
              child: GestureDetector(
                onTap: () => onPick(value),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: whose == value ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: whose == value ? ttcCardShadow : null,
                  ),
                  child: Text(label,
                      textAlign: TextAlign.center,
                      style: ttcBody(12.5,
                          color: whose == value ? ttcTitleInk : ttcSoft,
                          w: FontWeight.w800)),
                ),
              ),
            ),
        ]),
      );
}

/// The filter, as one word that cycles rather than as a row of segments.
/// Kept for revert (2026-09-27); nothing draws it now.
// ignore: unused_element
class _WhoseChip extends StatelessWidget {
  const _WhoseChip({required this.whose, required this.onPick});

  final bool? whose;
  final ValueChanged<bool?> onPick;

  @override
  Widget build(BuildContext context) {
    const order = <bool?>[null, false, true];
    final label = whose == null ? 'Everyone' : ttcWhose(whose!);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onPick(order[(order.indexOf(whose) + 1) % order.length]),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 7, 9, 7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: ttcBorder),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(label,
              style: ttcBody(12, color: ttcTitleInk, w: FontWeight.w800)),
          const SizedBox(width: 3),
          const Icon(Icons.expand_more_rounded, size: 15, color: ttcMuted),
        ]),
      ),
    );
  }
}

// =============================================================================
//  KEPT FOR REVERT - the flat list and the old add dialog
// -----------------------------------------------------------------------------
//  Superseded on 2026-09-03 by the grouped screen above and by
//  `showTtcRecordAdd` in `ttc_records_v2.dart`. Nothing calls either any more.
//
//  Left whole rather than deleted, per the house rule, and for one specific
//  reason: the argument for the date-ordered list is real — option 1b in the
//  design project — because she remembers "the tests before the last cycle"
//  rather than "my AMH readings". If recency turns out to matter more than
//  direction, going back should be an uncomment, not a rewrite.
// =============================================================================

/*

class _RecordCard extends StatelessWidget {
  const _RecordCard({required this.record, required this.t});

  final TtcRecord record;
  final TtcS t;

  @override
  Widget build(BuildContext context) {
    final hi = t.hinglish;
    final test = record.testId == null ? null : ttcTestById(record.testId!);
    final history = record.testId == null
        ? const <TtcRecord>[]
        : TtcRecordsStore.instance.historyFor(record.testId!);

    return TtcCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Text(record.label, style: ttcJakarta(15.5))),
          if (record.forPartner)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                  color: ttcCoralTint,
                  borderRadius: BorderRadius.circular(999)),
              child: Text(t.forPartnerTag,
                  style: ttcBody(10, color: ttcCoral, w: FontWeight.w800)),
            ),
        ]),
        const SizedBox(height: 10),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          if (record.value.isNotEmpty)
            Text(record.display,
                style: ttcFraunces(22, w: FontWeight.w600, color: ttcTitleInk)),
          const Spacer(),
          Text(_fmt(record.takenOn),
              style: ttcBody(12, color: ttcMuted, w: FontWeight.w700)),
        ]),
        if (record.note != null && record.note!.isNotEmpty) ...[
          const SizedBox(height: 9),
          Text(record.note!, style: ttcBody(13, h: 1.5)),
        ],

        // The actual document.
        //
        // Fertility results in India arrive on paper and as PDFs. Without this
        // the folder could only ever hold a number she retyped, while the thing
        // her clinic actually handed her lived in her gallery or her email -
        // which is where she would go looking for it anyway, so the folder was
        // not the folder.
        const SizedBox(height: 12),
        TtcAttachments(record: record, t: t),

        // A repeat reads as a trend, not a contradiction.
        if (history.length > 1) ...[
          const SizedBox(height: 12),
          ttcDivider(),
          const SizedBox(height: 10),
          Text(t.recordsHistory.toUpperCase(),
              style: ttcBody(9.5, color: ttcMuted, w: FontWeight.w800)),
          const SizedBox(height: 7),
          for (final h in history)
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(children: [
                Text(_fmt(h.takenOn),
                    style: ttcBody(12, color: ttcMuted, w: FontWeight.w600)),
                const SizedBox(width: 12),
                Text(h.display,
                    style: ttcBody(12.5, color: ttcInk, w: FontWeight.w700)),
              ]),
            ),
        ],

        // The library's plain-language note, so a number never sits alone.
        if (test != null) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              // Kept for revert (2026-09-29, no tinted slab behind text): color: ttcPanel,
              color: Colors.white, border: const Border.fromBorderSide(BorderSide(color: ttcLine)),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(test.reading(hi),
                style: ttcBody(12.5, color: ttcTitleInk, h: 1.55)),
          ),
        ],

        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => TtcRecordsStore.instance.remove(record.id),
          behavior: HitTestBehavior.opaque,
          child: Text(t.recordsRemove,
              style: ttcBody(11.5, color: ttcMuted, w: FontWeight.w700)),
        ),
      ]),
    );
  }

  static String _fmt(DateTime d) {
    const m = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${m[d.month - 1]} ${d.year}';
  }
}

// ---- adding -----------------------------------------------------------------

/// Pick from the library or type your own. Typing your own must always be
/// possible - no library covers every test an Indian lab runs.
Future<void> addTtcRecord(BuildContext context) async {
  final t = TtcS.current();
  final hi = t.hinglish;
  final labelC = TextEditingController();
  final valueC = TextEditingController();
  var forPartner = false;
  var takenOn = DateTime.now();
  String? testId;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSheet) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: ttcLine, borderRadius: BorderRadius.circular(999)),
              ),
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerLeft,
                // Kept for revert (2026-09-28): Text(t.recordsAdd, ...)
                child: Text(t.hinglish ? t.recordsAdd : 'Add a result',
                    style: ttcJakarta(17)),
              ),
              const SizedBox(height: 14),

              // From the library.
              SizedBox(
                height: 38,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (final test in ttcTests)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setSheet(() {
                            testId = test.id;
                            labelC.text = test.name;
                            forPartner = test.forHim;
                          }),
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 13, vertical: 9),
                            decoration: BoxDecoration(
                              color:
                                  testId == test.id ? ttcTitleInk : ttcPanel,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(test.name,
                                style: ttcBody(12,
                                    color: testId == test.id
                                        ? Colors.white
                                        : ttcSoft,
                                    w: FontWeight.w700)),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              _field(labelC, t.recordsLabel, autofocus: false),
              const SizedBox(height: 11),
              _field(valueC, t.recordsValue),
              const SizedBox(height: 14),

              // Whose result it is.
              Row(children: [
                Expanded(
                  child: Text(t.recordsWhose,
                      style: ttcBody(13, color: ttcInk, w: FontWeight.w700)),
                ),
                for (final isHim in [false, true])
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: GestureDetector(
                      onTap: () => setSheet(() => forPartner = isHim),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 9),
                        decoration: BoxDecoration(
                          color: forPartner == isHim ? ttcTitleInk : ttcPanel,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(isHim ? t.testForHim : t.testForHer,
                            style: ttcBody(12,
                                color: forPartner == isHim
                                    ? Colors.white
                                    : ttcSoft,
                                w: FontWeight.w800)),
                      ),
                    ),
                  ),
              ]),
              const SizedBox(height: 14),

              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: takenOn,
                    firstDate: DateTime.now()
                        .subtract(const Duration(days: 365 * 5)),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setSheet(() => takenOn = picked);
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: ttcBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: ttcBorder)),
                  child: Row(children: [
                    const Icon(Icons.calendar_today_rounded,
                        size: 16, color: ttcTitleInk),
                    const SizedBox(width: 11),
                    Text(_RecordCard._fmt(takenOn),
                        style: ttcBody(14, color: ttcInk, w: FontWeight.w600)),
                  ]),
                ),
              ),
              const SizedBox(height: 16),

              Row(children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(ctx).pop(),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                          // Kept for revert (2026-09-29, no tinted slab behind text): color: ttcPanel,
                          color: Colors.white, border: const Border.fromBorderSide(BorderSide(color: ttcLine)),
                          borderRadius: BorderRadius.circular(16)),
                      child: Text(t.journalCancel,
                          style:
                              ttcBody(14, color: ttcTitleInk, w: FontWeight.w800)),
                    ),
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: () {
                      if (labelC.text.trim().isEmpty) return;
                      TtcRecordsStore.instance.add(
                        label: labelC.text,
                        value: valueC.text,
                        takenOn: takenOn,
                        testId: testId,
                        forPartner: forPartner,
                      );
                      Navigator.of(ctx).pop();
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                          color: ttcTitleInk,
                          borderRadius: BorderRadius.circular(16)),
                      child: Text(t.journalSave,
                          style: ttcBody(14,
                              color: Colors.white, w: FontWeight.w800)),
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 8),
              Text(hi ? 'Ye sirf record hai, natija nahi.' : 'This is a record, not a judgement.',
                  style: ttcBody(11, color: ttcMuted)),
            ]),
          ),
        ),
      ),
    ),
  );
  // ⚠️ NOT DISPOSED THE MOMENT THE ROUTE CLOSES (2026-10-02, the red screen '_dependents.isEmpty'): the TextField is still on screen for the exit animation and still listening. Same fix as the add-child sheet.
  Future<void>.delayed(const Duration(milliseconds: 600), labelC.dispose);
  Future<void>.delayed(const Duration(milliseconds: 600), valueC.dispose);
}

Widget _field(TextEditingController c, String hint, {bool autofocus = false}) =>
    TextField(
      controller: c,
      autofocus: autofocus,
      style: ttcBody(14.5, color: ttcInk),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: ttcBody(14, color: ttcMuted),
        filled: true,
        fillColor: ttcBg,
        contentPadding: const EdgeInsets.all(14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: ttcBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: ttcBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: ttcTitleInk, width: 1.4),
        ),
      ),
    );
*/
