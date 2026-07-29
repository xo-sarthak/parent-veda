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
// =============================================================================

import 'package:flutter/material.dart';

import '../../ttc/ttc_records_store.dart';
import '../../ttc/ttc_tests_data.dart';
import 'ttc_common.dart';
import 'ttc_strings.dart';

void openTtcRecords(BuildContext context, {bool resultsOnly = false}) {
  Navigator.of(context).push(MaterialPageRoute<void>(
    builder: (_) => TtcRecordsScreen(resultsOnly: resultsOnly),
    settings: RouteSettings(name: resultsOnly ? 'ttc/reports' : 'ttc/records'),
  ));
}

class TtcRecordsScreen extends StatefulWidget {
  const TtcRecordsScreen({super.key, this.resultsOnly = false});

  /// True when opened from the Reports tile - the same folder, filtered to
  /// entries that came from the test library.
  final bool resultsOnly;

  @override
  State<TtcRecordsScreen> createState() => _TtcRecordsScreenState();
}

class _TtcRecordsScreenState extends State<TtcRecordsScreen> {
  /// null = both. Otherwise filter by whose result it is.
  bool? _partner;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([TtcRecordsStore.instance, TtcLang.instance]),
      builder: (context, _) {
        final t = TtcS.current();
        var records = TtcRecordsStore.instance.records;
        if (widget.resultsOnly) {
          records = records.where((r) => r.testId != null).toList();
        }
        if (_partner != null) {
          records = records.where((r) => r.forPartner == _partner).toList();
        }

        return Scaffold(
          backgroundColor: ttcBg,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                  ttcGutter, 8, ttcGutter, ttcBottomInset),
              children: [
                TtcBackBar(
                  title: widget.resultsOnly ? t.recordsReports : t.recordsTitle,
                  trailing: GestureDetector(
                    onTap: () => _add(context),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 13, vertical: 8),
                      decoration: BoxDecoration(
                          color: ttcPurple,
                          borderRadius: BorderRadius.circular(999)),
                      child: Text(t.recordsAdd,
                          style: ttcBody(12,
                              color: Colors.white, w: FontWeight.w800)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(t.recordsIntro, style: ttcBody(13.5, h: 1.6)),
                const SizedBox(height: 18),

                // Both people, together, by default.
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                      color: ttcPanel,
                      borderRadius: BorderRadius.circular(999)),
                  child: Row(children: [
                    _seg(t.recordsBoth, _partner == null,
                        () => setState(() => _partner = null)),
                    _seg(t.testForHer, _partner == false,
                        () => setState(() => _partner = false)),
                    _seg(t.testForHim, _partner == true,
                        () => setState(() => _partner = true)),
                  ]),
                ),
                const SizedBox(height: 18),

                if (records.isEmpty)
                  TtcEmpty(
                    icon: Icons.description_outlined,
                    title: t.recordsEmptyTitle,
                    body: t.recordsEmptyBody,
                    cta: t.recordsAdd,
                    onTap: () => _add(context),
                  )
                else
                  for (final r in records) ...[
                    _RecordCard(record: r, t: t),
                    const SizedBox(height: 11),
                  ],

                const SizedBox(height: 14),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(Icons.info_outline_rounded,
                      size: 15, color: ttcMuted),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(t.recordsDisclaimer,
                        style: ttcBody(11.5, color: ttcMuted, h: 1.5)),
                  ),
                ]),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _seg(String label, bool on, VoidCallback onTap) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 170),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: on ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
              boxShadow: on ? ttcCardShadow : null,
            ),
            child: Text(label,
                style: ttcBody(12.5,
                    color: on ? ttcTitleInk : ttcSoft, w: FontWeight.w800)),
          ),
        ),
      );

  Future<void> _add(BuildContext context) => addTtcRecord(context);
}

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
              color: ttcPanel,
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
                child: Text(t.recordsAdd, style: ttcJakarta(17)),
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
                                  testId == test.id ? ttcPurple : ttcPanel,
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
                          color: forPartner == isHim ? ttcPurple : ttcPanel,
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
                        size: 16, color: ttcPurple),
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
                          color: ttcPanel,
                          borderRadius: BorderRadius.circular(16)),
                      child: Text(t.journalCancel,
                          style:
                              ttcBody(14, color: ttcSoft, w: FontWeight.w800)),
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
                          color: ttcPurple,
                          borderRadius: BorderRadius.circular(16)),
                      child: Text(t.journalSave,
                          style: ttcBody(14,
                              color: Colors.white, w: FontWeight.w800)),
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 8),
              Text(hi ? 'Ye sirf record hai, natija nahi.' : 'This is a record, not a verdict.',
                  style: ttcBody(11, color: ttcMuted)),
            ]),
          ),
        ),
      ),
    ),
  );
  labelC.dispose();
  valueC.dispose();
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
          borderSide: const BorderSide(color: ttcPurple, width: 1.4),
        ),
      ),
    );
