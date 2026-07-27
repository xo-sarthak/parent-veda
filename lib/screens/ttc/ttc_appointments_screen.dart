// =============================================================================
//  TTC - Appointments
// -----------------------------------------------------------------------------
//  Two sources on one list, because a couple does not think of them as two
//  things:
//
//   * sessions booked THROUGH ParentVeda, which come from the booking engine
//     and are not editable here (the engine owns seats and credits);
//   * clinic visits the couple arranged themselves over the phone, which are
//     theirs to add, change and delete.
//
//  Merged and sorted by time. The source is a small tag, never a section
//  heading - splitting them would make the parent do the merging in their head,
//  which is precisely the job a command centre exists to take off them.
//
//  It also carries the questions saved for the doctor. Walking into an
//  appointment with the questions you wrote at 2am is most of what makes a
//  fifteen-minute consultation useful.
// =============================================================================

import 'package:flutter/material.dart';

import '../../booking/booking_models.dart';
import '../../booking/booking_store.dart';
import '../../ttc/ttc_journal_store.dart';
import '../../ttc/ttc_records_store.dart';
import 'ttc_common.dart';
import 'ttc_journal_screen.dart';
import 'ttc_strings.dart';

void openTtcAppointments(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute<void>(
    builder: (_) => const TtcAppointmentsScreen(),
    settings: const RouteSettings(name: 'ttc/appointments'),
  ));
}

/// One row on the merged list, from either source.
class _Entry {
  const _Entry({
    required this.title,
    required this.startsUtc,
    required this.detail,
    required this.fromParentVeda,
    this.id,
  });

  final String title;
  final DateTime startsUtc;
  final String detail;
  final bool fromParentVeda;

  /// Only set for the couple's own appointments - the ones they may delete.
  final String? id;
}

class TtcAppointmentsScreen extends StatelessWidget {
  const TtcAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        TtcAppointmentsStore.instance,
        BookingStore.instance,
        TtcJournalStore.instance,
        TtcLang.instance,
      ]),
      builder: (context, _) {
        final t = TtcS.current();
        final hi = t.hinglish;

        final entries = <_Entry>[
          for (final a in TtcAppointmentsStore.instance.all)
            _Entry(
              id: a.id,
              title: a.title,
              startsUtc: a.startsUtc,
              detail: a.withWhom,
              fromParentVeda: false,
            ),
          // Booked through ParentVeda. Read-only here: the engine owns the seat.
          for (final b in BookingStore.instance
              .bookings(stage: ServiceStage.tryingToConceive)
              .where((b) => b.status == BookingStatus.upcoming))
            _Entry(
              title: b.title,
              startsUtc: b.startsUtc,
              detail: t.appointmentsViaParentVeda,
              fromParentVeda: true,
            ),
        ]..sort((a, b) => a.startsUtc.compareTo(b.startsUtc));

        final now = DateTime.now().toUtc();
        final upcoming = entries.where((e) => e.startsUtc.isAfter(now)).toList();
        final past =
            entries.where((e) => !e.startsUtc.isAfter(now)).toList().reversed;
        final questions = TtcJournalStore.instance.doctorQuestions;

        return Scaffold(
          backgroundColor: ttcBg,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(ttcGutter, 8, ttcGutter, 40),
              children: [
                TtcBackBar(
                  title: t.appointmentsTitle,
                  trailing: GestureDetector(
                    onTap: () => addTtcAppointment(context),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 13, vertical: 8),
                      decoration: BoxDecoration(
                          color: ttcPurple,
                          borderRadius: BorderRadius.circular(999)),
                      child: Text(t.appointmentsAdd,
                          style: ttcBody(12,
                              color: Colors.white, w: FontWeight.w800)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(t.appointmentsIntro, style: ttcBody(13.5, h: 1.6)),
                const SizedBox(height: 20),

                ttcSectionTitle(t.calendarUpcoming),
                if (upcoming.isEmpty)
                  TtcEmpty(
                    icon: Icons.event_note_outlined,
                    title: t.appointmentsEmptyTitle,
                    body: t.appointmentsEmptyBody,
                    cta: t.appointmentsAdd,
                    onTap: () => addTtcAppointment(context),
                  )
                else
                  for (final e in upcoming) ...[
                    _EntryCard(entry: e, t: t),
                    const SizedBox(height: 11),
                  ],

                const SizedBox(height: 20),

                // The questions saved at 2am, ready to walk in with.
                ttcSectionTitle(t.appointmentsQuestions),
                if (questions.isEmpty)
                  TtcEmpty(
                    icon: Icons.help_outline_rounded,
                    title: t.appointmentsNoQuestionsTitle,
                    body: t.appointmentsNoQuestionsBody,
                    cta: t.journalWrite,
                    onTap: () => writeTtcEntry(context,
                        kind: TtcEntryKind.question),
                  )
                else
                  TtcCard(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final q in questions) ...[
                            Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    margin: const EdgeInsets.only(
                                        top: 7, right: 11),
                                    decoration: const BoxDecoration(
                                        color: ttcPurple,
                                        shape: BoxShape.circle),
                                  ),
                                  Expanded(
                                    child: Text(q.text,
                                        style: ttcBody(13.5,
                                            color: ttcInk, h: 1.5)),
                                  ),
                                ]),
                            const SizedBox(height: 11),
                          ],
                          GestureDetector(
                            onTap: () => writeTtcEntry(context,
                                kind: TtcEntryKind.question),
                            behavior: HitTestBehavior.opaque,
                            child: Row(children: [
                              const Icon(Icons.add_circle_outline_rounded,
                                  size: 16, color: ttcPurple),
                              const SizedBox(width: 7),
                              Text(t.appointmentsAddQuestion,
                                  style: ttcBody(12.5,
                                      color: ttcPurple, w: FontWeight.w800)),
                            ]),
                          ),
                        ]),
                  ),

                if (past.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  ttcSectionTitle(t.appointmentsPast),
                  for (final e in past) ...[
                    _EntryCard(entry: e, t: t, faded: true),
                    const SizedBox(height: 11),
                  ],
                ],

                const SizedBox(height: 12),
                Text(
                  hi
                      ? 'Yahan sirf wahi hai jo aap ya ParentVeda ne add kiya. Hum aapke clinic se apne aap kuch nahi laate.'
                      : 'This holds only what you or ParentVeda added. Nothing is pulled from your clinic automatically.',
                  style: ttcBody(11.5, color: ttcMuted, h: 1.5),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({required this.entry, required this.t, this.faded = false});

  final _Entry entry;
  final TtcS t;
  final bool faded;

  @override
  Widget build(BuildContext context) {
    final local = entry.startsUtc.toLocal();
    return TtcCard(
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 44,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: faded ? ttcBg : ttcPanel,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: [
            Text('${local.day}',
                style: ttcJakarta(16, color: faded ? ttcMuted : ttcPurple)),
            Text(_month(local),
                style: ttcBody(9.5, color: ttcMuted, w: FontWeight.w800)),
          ]),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(entry.title,
                style: ttcJakarta(15, color: faded ? ttcSoft : ttcTitleInk)),
            const SizedBox(height: 3),
            Text(_time(local),
                style: ttcBody(12.5, color: ttcSoft, w: FontWeight.w600)),
            if (entry.detail.isNotEmpty) ...[
              const SizedBox(height: 3),
              Text(entry.detail, style: ttcBody(12)),
            ],
            // The source is a tag, never a section heading.
            if (entry.fromParentVeda) ...[
              const SizedBox(height: 7),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                    color: ttcPanel, borderRadius: BorderRadius.circular(999)),
                child: Text(t.appointmentsViaParentVeda,
                    style: ttcBody(9.5, color: ttcPurple, w: FontWeight.w800)),
              ),
            ],
          ]),
        ),
        // Only the couple's own appointments are theirs to delete - the engine
        // owns a booked seat.
        if (entry.id != null)
          GestureDetector(
            onTap: () => TtcAppointmentsStore.instance.remove(entry.id!),
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.only(left: 10),
              child: Icon(Icons.close_rounded, size: 16, color: ttcMuted),
            ),
          ),
      ]),
    );
  }

  static String _month(DateTime d) {
    const m = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
    ];
    return m[d.month - 1];
  }

  static String _time(DateTime d) {
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final ampm = d.hour < 12 ? 'am' : 'pm';
    return '$h:${d.minute.toString().padLeft(2, '0')}$ampm';
  }
}

Future<void> addTtcAppointment(BuildContext context) async {
  final t = TtcS.current();
  final titleC = TextEditingController();
  final whoC = TextEditingController();
  var when = DateTime.now().add(const Duration(days: 1));

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
              child: Text(t.appointmentsAdd, style: ttcJakarta(17)),
            ),
            const SizedBox(height: 14),
            _sheetField(titleC, t.appointmentsWhat, autofocus: true),
            const SizedBox(height: 11),
            _sheetField(whoC, t.appointmentsWho),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () async {
                final day = await showDatePicker(
                  context: ctx,
                  initialDate: when,
                  firstDate: DateTime.now()
                      .subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                );
                if (day == null || !ctx.mounted) return;
                final time = await showTimePicker(
                  context: ctx,
                  initialTime: TimeOfDay.fromDateTime(when),
                );
                setSheet(() => when = DateTime(day.year, day.month, day.day,
                    time?.hour ?? 10, time?.minute ?? 0));
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
                  const Icon(Icons.schedule_rounded, size: 16, color: ttcPurple),
                  const SizedBox(width: 11),
                  Text(
                      '${when.day}/${when.month}/${when.year} · '
                      '${_EntryCard._time(when)}',
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
                        style: ttcBody(14, color: ttcSoft, w: FontWeight.w800)),
                  ),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () {
                    if (titleC.text.trim().isEmpty) return;
                    TtcAppointmentsStore.instance.add(
                      title: titleC.text,
                      withWhom: whoC.text,
                      startsLocal: when,
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
          ]),
        ),
      ),
    ),
  );
  titleC.dispose();
  whoC.dispose();
}

Widget _sheetField(TextEditingController c, String hint,
        {bool autofocus = false}) =>
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
