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
//
//  ---------------------------------------------------------------------------
//  ⚠️ REBUILT 2026-09-27 (the tool rebuild), NOT RE-PAINTED
//  ---------------------------------------------------------------------------
//
//  The user walked build 13: "old tools in new clothes… poor functionality".
//  This one was: V1 cards (`TtcCard`, purple date wells, a purple Add pill)
//  inside the new shell, a bottom sheet styled like neither, the past and the
//  coming mixed on one scroll, nothing to open, one tap that did both date and
//  time, and the notes field the model has always carried (`note`, synced)
//  never shown anywhere. Now there are three places, the shape every
//  appointment app on Mobbin shares:
//
//   1. THE LIST. The next visit first, in a tinted block that says how soon
//      ("Tomorrow"), then the rest as rows with a date block, the time and who
//      it is with. Coming up and Past are two choices, not one long scroll.
//   2. ONE VISIT'S PAGE. When, who with, notes, the reminder switch, the
//      questions to take, and Change / Remove. Every empty line has its own
//      "Add" right there.
//   3. THE FORM. A page in the tool shell, like Records: labelled blocks, the
//      date and the time as two separate taps, notes, the reminder. Leaving
//      with changes asks first.
//
//  Shape from Mobbin (2026-09-27):
//   · Lex "Your Events": Upcoming / Past as two tabs, a date block on the left
//     of each row, time and place under the title:
//     https://mobbin.com/screens/cb327064-1d9b-4275-a731-287cf1bf7ac0
//   · Tock "Reservations": the same Upcoming / Past split:
//     https://mobbin.com/screens/bd0b660e-3123-4487-aab8-2e45bb4fc476
//   · Superpower "Your appointment is tomorrow": the next one said as a
//     relative day, big, before anything else:
//     https://mobbin.com/screens/c7b748df-fa67-4007-93f9-ee3127dd6edf
//   · Zocdoc upcoming visit: one visit's page, date and reason at the top,
//     "How to prepare for your visit" and "Make a list of any questions"
//     below: https://mobbin.com/screens/71930370-307b-4a90-9185-988981407a2f
//     and https://mobbin.com/screens/eb85cae6-d19d-475c-bbfa-4ca47cdc4b22
//   · CVS Health "Review details": When and Where as labelled rows, reschedule
//     and cancel at the foot:
//     https://mobbin.com/screens/c3a9a7d5-a6bb-44a6-a76e-bf9339c78b2e
//   · WhatsApp "Create event" and Apple Invites "New Event": the date and the
//     time as two separate chips on one "Starts" row:
//     https://mobbin.com/screens/c7df3b97-12ee-425c-ba4d-26f949d70d1d
//     https://mobbin.com/screens/d27f0859-2096-4ed2-a084-9d42c208ae1f
//
//  From the gap analysis (Flo / What to Expect): "a short list of what to note
//  down before the visit helps her get more from the appointment", which is
//  the questions block on each coming visit.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../booking/booking_models.dart';
import '../../booking/booking_store.dart';
import '../../services/notification_service.dart';
import '../../theme/pv_fonts.dart';
// Kept for revert (2026-09-28, the user: no journal in trying to conceive).
// The questions for the doctor were journal entries; they have their own
// store now, and nothing on this page touches the journal.
// import '../../ttc/ttc_journal_store.dart';
import '../../ttc/ttc_doctor_questions_store.dart';
import '../../ttc/ttc_records_store.dart';
import '../products/pv_store_chrome.dart' show pvSnack;
import '../v2/v2_palette.dart';
import 'ttc_common.dart';
import 'ttc_ivf_readiness_screen.dart' show kIvfHue;
// Kept for revert (2026-09-28): the journal's writer and entry page.
// import 'ttc_journal_screen.dart' show writeTtcEntry, openTtcJournalEntry;
import 'ttc_doctor_question_screen.dart';
import 'ttc_strings.dart';
import 'ttc_tool_chrome.dart';
import 'ttc_tool_confirm.dart';

void openTtcAppointments(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute<void>(
    builder: (_) => const TtcAppointmentsScreen(),
    settings: const RouteSettings(name: 'ttc/appointments'),
  ));
}

/// The red a destructive word takes. The same one Records uses.
// One danger red, DESIGN-SYSTEM §4.0 (2026-09-29). Kept for revert: Color(0xFFB42318)
const Color _kDanger = Color(0xFFB3261E);

/// One row on the merged list, from either source.
class TtcApptEntry {
  const TtcApptEntry({
    required this.title,
    required this.startsUtc,
    required this.detail,
    required this.fromParentVeda,
    this.own,
    this.bookingId,
  });

  final String title;
  final DateTime startsUtc;
  final String detail;
  final bool fromParentVeda;

  /// The couple's own appointment. Null for a ParentVeda booking, which is
  /// read-only here because the booking engine owns the seat.
  final TtcAppointment? own;

  /// The booking's id, for a ParentVeda booking (2026-09-28), so its
  /// questions can belong to it like any visit's.
  final String? bookingId;

  /// The id her questions use for this visit (`TtcDoctorQuestion.appointmentId`).
  String get visitId =>
      own?.id ?? ttcBookingVisitId(bookingId ?? '$title@$startsUtc');

  DateTime get startsLocal => startsUtc.toLocal();
  bool get isUpcoming => startsUtc.isAfter(DateTime.now().toUtc());
}

/// "Follicle scan, Thu 2 Oct": a visit named the way a caption names it.
String ttcVisitName(TtcVisitRef v) => '${v.title}, ${ttcApptDay(v.startsLocal)}';

/// Both sources, soonest first.
List<TtcApptEntry> ttcApptEntries() {
  final t = TtcS.current();
  return <TtcApptEntry>[
    for (final a in TtcAppointmentsStore.instance.all)
      TtcApptEntry(
        own: a,
        title: a.title,
        startsUtc: a.startsUtc,
        detail: a.withWhom,
        fromParentVeda: false,
      ),
    // Booked through ParentVeda. Read-only here: the engine owns the seat.
    for (final b in BookingStore.instance
        .bookings(stage: ServiceStage.tryingToConceive)
        .where((b) => b.status == BookingStatus.upcoming))
      TtcApptEntry(
        title: b.title,
        startsUtc: b.startsUtc,
        detail: t.appointmentsViaParentVeda,
        fromParentVeda: true,
        bookingId: b.id,
      ),
  ]..sort((a, b) => a.startsUtc.compareTo(b.startsUtc));
}

// ---- words for dates, said the way people say them --------------------------

const _kDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _kMonths = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// "10:30am".
String ttcApptTime(DateTime d) {
  final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final ampm = d.hour < 12 ? 'am' : 'pm';
  return '$h:${d.minute.toString().padLeft(2, '0')}$ampm';
}

/// "Thu 2 Oct".
String ttcApptDay(DateTime d) =>
    '${_kDays[d.weekday - 1]} ${d.day} ${_kMonths[d.month - 1]}';

/// "Today", "Tomorrow", "In 3 days", "In 2 weeks", "Yesterday", "5 days ago",
/// or the date itself when it is further back than that.
///
/// ⚠️ COUNTED ON CALENDAR DAYS IN UTC, NOT ON `Duration.inDays`. A visit at
/// 9 am tomorrow is less than 24 hours away at 10 am today, and `inDays`
/// would call it "Today". Two midnights, subtracted in UTC so a clock change
/// cannot make a day 23 hours long.
String ttcApptRelative(DateTime local, {DateTime? now}) {
  final n = now ?? DateTime.now();
  final a = DateTime.utc(local.year, local.month, local.day);
  final b = DateTime.utc(n.year, n.month, n.day);
  final diff = a.difference(b).inDays;
  if (diff == 0) return 'Today';
  if (diff == 1) return 'Tomorrow';
  if (diff == -1) return 'Yesterday';
  if (diff > 1 && diff < 14) return 'In $diff days';
  if (diff >= 14 && diff < 63) return 'In ${diff ~/ 7} weeks';
  if (diff < -1 && diff > -14) return '${-diff} days ago';
  return ttcApptDay(local);
}

// =============================================================================
//  1. The list
// =============================================================================

class TtcAppointmentsScreen extends StatefulWidget {
  const TtcAppointmentsScreen({super.key});

  @override
  State<TtcAppointmentsScreen> createState() => _TtcAppointmentsScreenState();
}

class _TtcAppointmentsScreenState extends State<TtcAppointmentsScreen> {
  /// Coming up or Past. Past is one tap away, never mixed into what is next.
  bool _past = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        TtcAppointmentsStore.instance,
        BookingStore.instance,
        // Kept for revert (2026-09-28): TtcJournalStore.instance,
        TtcDoctorQuestionsStore.instance,
        TtcLang.instance,
        V2PaletteStore.instance,
      ]),
      builder: (context, _) {
        final t = TtcS.current();
        final p = V2PaletteStore.instance.current;
        final entries = ttcApptEntries();
        final upcoming = entries.where((e) => e.isUpcoming).toList();
        final past = entries.where((e) => !e.isUpcoming).toList().reversed
            .toList();
        // Kept for revert (2026-09-28):
        //   final questions = TtcJournalStore.instance.doctorQuestions;
        // Kept for revert (2026-09-28, a question belongs to a visit): every
        // question on every visit.
        //   final questions = TtcDoctorQuestionsStore.instance.questions;
        final qs = TtcDoctorQuestionsStore.instance;
        // The ones still to ask, soonest visit first. Ticked ones fold under
        // the visit they were asked at, on that visit's page.
        final questions = qs.openAll();
        // The one quiet "Did you get your answers?" line, for the latest
        // visit that has happened with her questions still unticked.
        final followUp = qs.visitToFollowUp();
        // With nothing in the past there is nothing to switch to, so the
        // switch is not drawn. It appears the day the first visit passes.
        final showPast = _past && past.isNotEmpty;
        // The empty invitation is on screen (T13).
        final emptyShowing = !showPast && upcoming.isEmpty;

        return TtcToolScaffold(
          hue: kIvfHue,
          // The tool's mark over the eyebrow (2026-09-29, ttc_tool_marks.dart).
          toolId: 'appointments',
          eyebrow: t.appointmentsTitle,
          // Monitoring scans arrive at short notice, which is the whole reason
          // this screen exists during a treatment cycle.
          title: 'Where you have to be, and when.',
          // ⚠️ SAYS WHAT THIS IS AND WHAT A TAP DOES (the simplicity rule).
          // Kept for revert (2026-09-27): intro: t.appointmentsIntro,
          intro: 'Your clinic visits and anything booked in ParentVeda, '
              'soonest first. Tap one to see it, change it or add your '
              'questions.',
          // ⚠️ AN INK PILL, NOT `ttcPurple` (tool rebuild, 2026-09-27): the
          // purple pill was the V1 look inside the new shell.
          //
          // ⚠️ ONE ADD ON AN EMPTY SCREEN (launch sanity T13, 2026-09-28).
          // While the empty card is showing, it carries the only Add ("Add an
          // appointment", with the same key so every path to adding is one
          // control); the header Add appears once there is a list to add to.
          // Two identical buttons on one empty screen read as a glitch.
          // Kept for revert (2026-09-28): the header pill drawn always.
          action: emptyShowing
              ? null
              : TtcApptInkPill(
                  key: const ValueKey('ttc_appt_add'),
                  label: t.appointmentsAdd,
                  icon: Icons.add_rounded,
                  onTap: () => addTtcAppointment(context),
                ),
          children: [
            ttcToolPad(Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 22),

                // ⚠️ ONE QUIET LINE, NOT A BANNER (2026-09-28). The day
                // after a visit, her unticked questions have already moved to
                // the next visit (derived); this line says so where she will
                // see it, and opens the visit where she answers it.
                if (followUp != null) ...[
                  TtcApptFollowUpLine(visit: followUp, p: p),
                  const SizedBox(height: 16),
                ],

                if (past.isNotEmpty) ...[
                  TtcToolOptions(
                    p: p,
                    hue: kIvfHue,
                    items: [
                      TtcToolOption(
                          label: upcoming.isEmpty
                              ? t.calendarUpcoming
                              : '${t.calendarUpcoming} · ${upcoming.length}',
                          on: !showPast,
                          onTap: () => setState(() => _past = false)),
                      TtcToolOption(
                          label: 'Past · ${past.length}',
                          on: showPast,
                          onTap: () => setState(() => _past = true)),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                if (showPast)
                  _RowGroup(p: p, children: [
                    for (final e in past) TtcApptRow(entry: e, p: p),
                  ])
                else if (upcoming.isEmpty)
                  _EmptyInvite(
                    p: p,
                    icon: Icons.event_note_outlined,
                    title: t.appointmentsEmptyTitle,
                    body: t.appointmentsEmptyBody,
                    cta: 'Add an appointment',
                    // T13: the one Add while the list is empty.
                    ctaKey: const ValueKey('ttc_appt_add'),
                    onTap: () => addTtcAppointment(context),
                  )
                else ...[
                  // Kept for revert (2026-09-28): questions: questions.length,
                  // which counted every question on every visit.
                  _NextUp(
                      entry: upcoming.first,
                      p: p,
                      questions: qs.openCountFor(upcoming.first.visitId)),
                  if (upcoming.length > 1) ...[
                    const SizedBox(height: 14),
                    _RowGroup(p: p, children: [
                      for (final e in upcoming.skip(1))
                        TtcApptRow(entry: e, p: p),
                    ]),
                  ],
                ],

                const SizedBox(height: 30),

                // The questions saved at 2am, ready to walk in with.
                // Kept for revert (2026-09-29, one heading style):
                // Text(t.appointmentsQuestions, style: pvJakarta(
                //     fontSize: 17, fontWeight: FontWeight.w700, color: p.ink1)),
                TtcSectionHeading(t.appointmentsQuestions),
                const SizedBox(height: 5),
                // Kept for revert (2026-09-28): 'These show on every visit
                // that is coming up. Tap one to change it.'
                Text(
                    questions.isEmpty
                        ? t.appointmentsNoQuestionsBody
                        : 'Each question is kept for one visit, and moves to '
                            'the next visit if it is not ticked as asked. Tap '
                            'a question to change it or choose its visit.',
                    style:
                        pvManrope(fontSize: 13, height: 1.5, color: p.ink3)),
                const SizedBox(height: 12),
                TtcApptQuestions(p: p, questions: questions, showVisit: true),

                // ⚠️ SAID ONCE (tools pass, 2026-09-27): the intro already
                // says this list is what you and ParentVeda added, and the
                // empty state says to add clinic visits yourselves, so this
                // foot note was the third telling. Kept for revert:
                // Text("This only shows what you or ParentVeda added. We don't
                //   bring in anything from your clinic on our own.", ...),
                const SizedBox(height: 26),
              ],
            )),
          ],
        );
      },
    );
  }
}

/// A white group with hairlines between its rows. No shadows.
class _RowGroup extends StatelessWidget {
  const _RowGroup({required this.p, required this.children});
  final V2Palette p;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: p.line),
        ),
        child: Column(children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) Divider(height: 1, thickness: 1, color: p.line),
            children[i],
          ],
        ]),
      );
}

/// The empty state: what goes here, and the button to put it there.
class _EmptyInvite extends StatelessWidget {
  const _EmptyInvite({
    required this.p,
    required this.icon,
    required this.title,
    required this.body,
    required this.cta,
    required this.onTap,
    this.ctaKey,
  });

  final V2Palette p;
  final IconData icon;
  final String title;
  final String body;
  final String cta;
  final VoidCallback onTap;
  final Key? ctaKey;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: p.line),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 22, color: p.ink2),
          const SizedBox(height: 10),
          Text(title,
              style: pvFraunces(
                  fontSize: 19, fontWeight: FontWeight.w600, color: p.ink1)),
          const SizedBox(height: 6),
          Text(body,
              style: pvManrope(fontSize: 13.5, height: 1.55, color: p.ink2)),
          const SizedBox(height: 14),
          TtcApptInkPill(
              key: ctaKey, label: cta, icon: Icons.add_rounded, onTap: onTap),
        ]),
      );
}

/// The base UI's ink pill: ink fill, white words. Used for "Add".
class TtcApptInkPill extends StatelessWidget {
  const TtcApptInkPill({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: label,
        excludeSemantics: true,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            padding: EdgeInsets.fromLTRB(icon == null ? 16 : 12, 9, 16, 9),
            decoration: BoxDecoration(
                color: ttcTitleInk, borderRadius: BorderRadius.circular(999)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (icon != null) ...[
                Icon(icon, size: 17, color: Colors.white),
                const SizedBox(width: 5),
              ],
              // Flexible (2026-09-28): a long label at 360dp overflowed the
              // row by 12pt under a large font. Kept for revert: a bare Text.
              Flexible(
                child: Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: pvManrope(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white)),
              ),
            ]),
          ),
        ),
      );
}

/// The next visit, said as how soon it is. Tapping opens it.
class _NextUp extends StatelessWidget {
  const _NextUp(
      {required this.entry, required this.p, required this.questions});

  final TtcApptEntry entry;
  final V2Palette p;
  final int questions;

  @override
  Widget build(BuildContext context) {
    final local = entry.startsLocal;
    final own = entry.own;
    return Material(
      color: v2BlockTint(kIvfHue, p),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        key: const ValueKey('ttc_appt_next'),
        borderRadius: BorderRadius.circular(20),
        onTap: () => openTtcAppointment(context, entry),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 14, 18),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Change 5 (2026-09-28). Kept for revert: 'NEXT'.
                    Text('NEXT VISIT',
                        style: pvManrope(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: p.ink2)),
                    const SizedBox(height: 6),
                    Text(ttcApptRelative(local),
                        style: pvFraunces(
                            fontSize: 26,
                            height: 1.15,
                            fontWeight: FontWeight.w600,
                            color: p.ink1)),
                    const SizedBox(height: 8),
                    Text(entry.title,
                        style: pvJakarta(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w700,
                            color: p.ink1)),
                    const SizedBox(height: 4),
                    Text(
                        '${ttcApptDay(local)} at ${ttcApptTime(local)}'
                        '${entry.detail.isEmpty || entry.fromParentVeda ? '' : ' · ${entry.detail}'}',
                        style: pvManrope(
                            fontSize: 13.5, height: 1.45, color: p.ink2)),
                    if (entry.fromParentVeda) ...[
                      const SizedBox(height: 8),
                      _Tag(p: p, text: entry.detail),
                    ],
                    if (own != null && own.remindEveningBefore) ...[
                      const SizedBox(height: 8),
                      _Mini(
                          p: p,
                          icon: Icons.notifications_none_rounded,
                          // Says which reminder it is (2026-10-01). Kept for
                          // revert: 'Reminder the evening before'.
                          text: ttcApptReminderTag(own)),
                    ],
                    if (questions > 0) ...[
                      const SizedBox(height: 6),
                      _Mini(
                          p: p,
                          icon: Icons.help_outline_rounded,
                          // Kept for revert (2026-09-28): '… to take'. Now
                          // the same words as the reminder and the home card.
                          text: ttcQuestionsToAsk(questions)),
                    ],
                  ]),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Icon(Icons.chevron_right_rounded, size: 22, color: p.ink2),
            ),
          ]),
        ),
      ),
    );
  }
}

/// One appointment as a row: the date block, how soon, what, when, who.
class TtcApptRow extends StatelessWidget {
  const TtcApptRow({super.key, required this.entry, required this.p});

  final TtcApptEntry entry;
  final V2Palette p;

  @override
  Widget build(BuildContext context) {
    final local = entry.startsLocal;
    final own = entry.own;
    final upcoming = entry.isUpcoming;
    return InkWell(
      onTap: () => openTtcAppointment(context, entry),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            width: 44,
            child: Column(children: [
              Text(_kDays[local.weekday - 1].toUpperCase(),
                  style: pvManrope(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: p.ink3)),
              Text('${local.day}',
                  style: pvFraunces(
                      fontSize: 24,
                      height: 1.15,
                      color: upcoming ? p.ink1 : p.ink3)),
              Text(_kMonths[local.month - 1].toUpperCase(),
                  style: pvManrope(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: p.ink3)),
            ]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      '${ttcApptRelative(local).toUpperCase()} · '
                      '${ttcApptTime(local).toUpperCase()}',
                      style: pvManrope(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: p.ink3)),
                  const SizedBox(height: 4),
                  Text(entry.title,
                      style: pvJakarta(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: upcoming ? p.ink1 : p.ink2)),
                  if (entry.detail.isNotEmpty && !entry.fromParentVeda) ...[
                    const SizedBox(height: 3),
                    Text(entry.detail,
                        style: pvManrope(
                            fontSize: 13, height: 1.4, color: p.ink2)),
                  ],
                  if (own != null && own.remindEveningBefore && upcoming) ...[
                    const SizedBox(height: 6),
                    _Mini(
                        p: p,
                        icon: Icons.notifications_none_rounded,
                        text: ttcApptReminderTag(own)),
                  ],
                  // Each visit says how many questions are kept for it
                  // (2026-09-28), as the next visit's block does.
                  if (upcoming &&
                      TtcDoctorQuestionsStore.instance
                              .openCountFor(entry.visitId) >
                          0) ...[
                    const SizedBox(height: 6),
                    _Mini(
                        p: p,
                        icon: Icons.help_outline_rounded,
                        text: ttcQuestionsToAsk(TtcDoctorQuestionsStore
                            .instance
                            .openCountFor(entry.visitId))),
                  ],
                  // The source is a tag, never a section heading.
                  if (entry.fromParentVeda) ...[
                    const SizedBox(height: 7),
                    _Tag(p: p, text: entry.detail),
                  ],
                ]),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Icon(Icons.chevron_right_rounded, size: 20, color: p.ink3),
          ),
        ]),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.p, required this.text});
  final V2Palette p;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: p.line),
        ),
        child: Text(text,
            style: pvManrope(
                fontSize: 11, fontWeight: FontWeight.w700, color: p.ink2)),
      );
}

class _Mini extends StatelessWidget {
  const _Mini({required this.p, required this.icon, required this.text});
  final V2Palette p;
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(icon, size: 15, color: p.ink2),
        const SizedBox(width: 6),
        Flexible(
          child: Text(text,
              style: pvManrope(
                  fontSize: 12.5, fontWeight: FontWeight.w700, color: p.ink2)),
        ),
      ]);
}

/// "1 question to ask", "3 questions to ask". The words the visit's block,
/// the evening-before reminder and the home's visit-day card all use.
String ttcQuestionsToAsk(int n) =>
    n == 1 ? '1 question to ask' : '$n questions to ask';

/// Who wrote a question, as a row label: "Yours", or her partner's as "His"
/// on her phone and "Hers" on his (his side names her "Her", as in "Her
/// round").
String ttcQuestionWhose(TtcDoctorQuestion q) => q.isMine
    ? 'Yours'
    : (TtcPartnerMode.instance.on ? 'Hers' : 'His');

/// The caption under one question: whose it is, and only when her partner
/// writes questions too ("Yours" on every row of a list only she writes
/// would be a word with nothing to tell apart).
String ttcQuestionCaption(TtcDoctorQuestion q) =>
    TtcDoctorQuestionsStore.instance.hasPartnerQuestions
        ? ttcQuestionWhose(q)
        : '';

/// The heading a question sits under: which visit it is for (on the list
/// page), or where it moved from (on a visit's page). Empty for a question
/// that is simply on the visit it was written for.
///
/// ⚠️ A HEADING ONCE, NOT A CAPTION ON EVERY ROW (the no-repetition rule,
/// 2026-09-28). Three questions for one scan under three "For Follicle scan,
/// Thu 2 Oct" lines is the same sentence said three times.
String ttcQuestionGroup(TtcDoctorQuestion q,
    {bool showVisit = false, String? onVisitId}) {
  final store = TtcDoctorQuestionsStore.instance;
  if (showVisit) {
    final v = store.visitById(store.visitFor(q));
    return v == null
        // Kept for revert (2026-10-01): 'For whichever visit comes next'.
        ? 'Not tied to a visit yet'
        : 'For the ${ttcVisitName(v)}';
  }
  if (onVisitId != null &&
      !q.isAsked &&
      q.appointmentId != null &&
      q.appointmentId != onVisitId) {
    // The derived roll-forward, said once over the rows it brought here.
    final from = store.visitById(q.appointmentId);
    return from == null
        ? 'Moved from a visit that was removed'
        : 'Moved from the ${ttcVisitName(from)}';
  }
  return '';
}

/// The saved questions for the doctor, each one opening to change it, and
/// the way to write another. Used on the list and on each visit's page.
///
/// ⚠️ A TICK ONCE THE VISIT'S DAY HAS COME (2026-09-28). Before the day a
/// question is something to change, so a row opens the writer; from the day
/// of the visit, each of HER rows leads with a round tick that marks it
/// asked (with an Undo), and ticked ones fold away under "Asked" on the
/// visit (see [TtcApptAskedFold]). Her partner's rows carry no tick: only
/// the one who wrote a question may change it (0092's own-row writes).
///
/// Shape from Mobbin (2026-09-28): open items with an empty circle and the
/// done ones folded under a count, Amie's to-do list ("Hide 1 done"):
/// https://mobbin.com/screens/8651d9b8-539c-4a87-af9a-53a2f492dc3a and
/// Structured's round ticks on a card:
/// https://mobbin.com/screens/8c6ff378-2fcd-49f2-9639-54f563e1d06c
class TtcApptQuestions extends StatelessWidget {
  const TtcApptQuestions({
    super.key,
    required this.p,
    required this.questions,
    this.showVisit = false,
    this.visitId,
    this.tickable = false,
    this.canAdd = true,
  });

  final V2Palette p;
  // Kept for revert (2026-09-28): final List<TtcJournalEntry> questions;
  final List<TtcDoctorQuestion> questions;

  /// On the list page: each row names the visit it is kept for.
  final bool showVisit;

  /// On a visit's page: the visit. A new question from here is for it, and
  /// a ticked question is asked at it.
  final String? visitId;

  /// The visit's day has come, so her rows carry a tick.
  final bool tickable;

  /// False on a visit whose day has passed: a question cannot be for it.
  final bool canAdd;

  @override
  Widget build(BuildContext context) {
    final add = InkWell(
      key: const ValueKey('ttc_appt_add_question'),
      // Kept for revert (2026-09-28, journal out of TTC):
      //   onTap: () => writeTtcEntry(context, kind: TtcEntryKind.question),
      onTap: () => writeTtcDoctorQuestion(context, visitId: visitId),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Row(children: [
          Icon(Icons.add_rounded, size: 19, color: p.ink1),
          const SizedBox(width: 9),
          Flexible(
            child: Text(
                questions.isEmpty
                    ? 'Write a question'
                    : TtcS.current().appointmentsAddQuestion,
                style: pvManrope(
                    fontSize: 14, fontWeight: FontWeight.w800, color: p.ink1)),
          ),
        ]),
      ),
    );
    // Rows in their groups: the ones written for this visit first (no
    // heading), then each group under its heading, in the order given.
    final groups = <String, List<TtcDoctorQuestion>>{};
    for (final q in questions) {
      groups
          .putIfAbsent(
              ttcQuestionGroup(q, showVisit: showVisit, onVisitId: visitId),
              () => [])
          .add(q);
    }
    final order = [
      if (groups.containsKey('')) '',
      ...groups.keys.where((k) => k.isNotEmpty),
    ];
    return _RowGroup(p: p, children: [
      for (final g in order) ...[
        if (g.isNotEmpty) _GroupHeading(p: p, text: g),
        for (final q in groups[g]!)
          TtcApptQuestionRow(
            p: p,
            question: q,
            caption: ttcQuestionCaption(q),
            onTick: tickable && q.isMine && visitId != null
                ? () => ttcTickQuestion(context, q, visitId!)
                : null,
          ),
      ],
      if (canAdd) add,
    ]);
  }
}

/// A small heading inside a group of questions: the visit they are for, or
/// where they moved from. Words, not a control.
class _GroupHeading extends StatelessWidget {
  const _GroupHeading({required this.p, required this.text});
  final V2Palette p;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        color: p.ground,
        padding: const EdgeInsets.fromLTRB(14, 9, 14, 8),
        child: Text(text,
            style: pvManrope(
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w800,
                color: p.ink2)),
      );
}

/// Ticks one question as asked at [visitId], with an Undo.
void ttcTickQuestion(
    BuildContext context, TtcDoctorQuestion q, String visitId) {
  final store = TtcDoctorQuestionsStore.instance;
  final before = store.ask(q.id, visitId: visitId);
  if (before == null) return;
  HapticFeedback.selectionClick();
  pvSnack(context, 'Marked as asked.',
      action: 'Undo', onAction: () => store.revert([before]), lift: 24);
}

/// One question as a row: a tick (her rows, from the visit's day) or a
/// question mark, the words, a caption, and a chevron to open it.
class TtcApptQuestionRow extends StatelessWidget {
  const TtcApptQuestionRow({
    super.key,
    required this.p,
    required this.question,
    required this.caption,
    this.onTick,
    this.asked = false,
    this.onUntick,
  });

  final V2Palette p;
  final TtcDoctorQuestion question;
  final String caption;

  /// Marks it asked. Null: no tick on the row.
  final VoidCallback? onTick;

  /// Drawn as asked: a filled tick, the words muted.
  final bool asked;

  /// Takes the tick off (her own asked rows).
  final VoidCallback? onUntick;

  @override
  Widget build(BuildContext context) {
    final q = question;
    Widget lead;
    if (asked) {
      lead = _TickButton(
        key: ValueKey('ttc_question_untick_${q.id}'),
        on: true,
        p: p,
        label: 'Asked: ${q.text}. Tap to mark it not asked yet.',
        onTap: onUntick,
      );
    } else if (onTick != null) {
      lead = _TickButton(
        key: ValueKey('ttc_question_tick_${q.id}'),
        on: false,
        p: p,
        label: 'Mark as asked: ${q.text}',
        onTap: onTick,
      );
    } else {
      lead = Padding(
        padding: const EdgeInsets.fromLTRB(2, 2, 0, 0),
        child: Icon(Icons.help_outline_rounded, size: 17, color: p.ink3),
      );
    }
    return InkWell(
      // ⚠️ A QUESTION OPENS (tool rebuild, 2026-09-27). It was a line of
      // text with a purple dot and no way to change or remove it once
      // the visit had answered it.
      // Kept for revert (2026-09-28):
      //   onTap: () => openTtcJournalEntry(context, q),
      key: ValueKey('ttc_appt_question_${q.id}'),
      onTap: () => openTtcDoctorQuestion(context, q),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 11, 10, 11),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(width: 30, child: Align(alignment: Alignment.topLeft, child: lead)),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(q.text,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: pvManrope(
                          fontSize: 14,
                          height: 1.5,
                          color: asked ? p.ink3 : p.ink1)),
                  if (caption.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(caption,
                        style: pvManrope(
                            fontSize: 11.5,
                            height: 1.4,
                            fontWeight: FontWeight.w700,
                            color: p.ink3)),
                  ],
                ]),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(Icons.chevron_right_rounded, size: 19, color: p.ink3),
          ),
        ]),
      ),
    );
  }
}

/// A round tick: an empty ring to tap, or a filled ink disc with a check.
class _TickButton extends StatelessWidget {
  const _TickButton({
    super.key,
    required this.on,
    required this.p,
    required this.label,
    this.onTap,
  });

  final bool on;
  final V2Palette p;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: onTap != null,
        checked: on,
        label: label,
        onTap: onTap,
        excludeSemantics: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: on ? ttcTitleInk : Colors.white,
                border: Border.all(
                    color: on ? ttcTitleInk : p.ink3, width: 1.6),
              ),
              child: on
                  ? const Icon(Icons.check_rounded,
                      size: 15, color: Colors.white)
                  : null,
            ),
          ),
        ),
      );
}

/// "Asked · 3", folded shut, under a visit. Opening it shows each ticked
/// question; her own can be unticked from here.
class TtcApptAskedFold extends StatefulWidget {
  const TtcApptAskedFold({
    super.key,
    required this.p,
    required this.questions,
  });

  final V2Palette p;
  final List<TtcDoctorQuestion> questions;

  @override
  State<TtcApptAskedFold> createState() => _TtcApptAskedFoldState();
}

class _TtcApptAskedFoldState extends State<TtcApptAskedFold> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final n = widget.questions.length;
    final head = InkWell(
      key: const ValueKey('ttc_appt_asked_fold'),
      onTap: () => setState(() => _open = !_open),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 13, 12, 13),
        child: Row(children: [
          Icon(Icons.check_circle_outline_rounded, size: 18, color: p.ink2),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
                // Named for what is inside, with the count, so the fold says
                // what opening it will show.
                n == 1 ? 'Asked · 1 question' : 'Asked · $n questions',
                style: pvManrope(
                    fontSize: 14, fontWeight: FontWeight.w800, color: p.ink1)),
          ),
          Icon(
              _open
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              size: 21,
              color: p.ink2),
        ]),
      ),
    );
    return _RowGroup(p: p, children: [
      head,
      if (_open)
        for (final q in widget.questions)
          TtcApptQuestionRow(
            p: p,
            question: q,
            asked: true,
            caption: ttcQuestionCaption(q),
            onUntick: q.isMine
                ? () {
                    final store = TtcDoctorQuestionsStore.instance;
                    if (!store.unask(q.id)) return;
                    HapticFeedback.selectionClick();
                    pvSnack(context, 'Marked as not asked yet.',
                        action: 'Undo',
                        onAction: () => store.revert([q]),
                        lift: 24);
                  }
                : null,
          ),
    ]);
  }
}

/// "Did you get your answers?" on a visit whose day has passed, while any of
/// her questions pinned to it are unticked. It is the one announcement of
/// the roll-forward ("2 questions moved to your next visit"), with the two
/// answers the user approved: keep them for the next visit, or Done (ticks
/// the rest as asked). Each Undo-able.
///
/// Shape from Mobbin (2026-09-28): a tinted "Action required" block on an
/// appointment's page with its action under the words, Fresha:
/// https://mobbin.com/screens/5ef9f1bf-25b5-487c-b347-2dd30dc2d263
class TtcApptFollowUpCard extends StatelessWidget {
  const TtcApptFollowUpCard({
    super.key,
    required this.p,
    required this.visitId,
  });

  final V2Palette p;
  final String visitId;

  @override
  Widget build(BuildContext context) {
    final store = TtcDoctorQuestionsStore.instance;
    final left = store.notTickedAfter(visitId);
    if (left.isEmpty) return const SizedBox.shrink();
    final n = left.length;
    final next = store.visitById(store.visitFor(left.first));
    final moved = n == 1
        ? '1 question was not ticked'
        : '$n questions were not ticked';
    final body = next == null
        ? '$moved, so ${n == 1 ? 'it waits' : 'they wait'} for your next '
            'visit. Tick any you did ask.'
        : '$moved, so ${n == 1 ? 'it' : 'they'} moved to your next visit, '
            '${ttcVisitName(next)}. Tick any you did ask.';
    Widget button(String label, Key key, VoidCallback onTap, bool ink) =>
        Semantics(
          button: true,
          label: label,
          onTap: onTap,
          excludeSemantics: true,
          child: InkWell(
            key: key,
            onTap: onTap,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: ink ? ttcTitleInk : Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: ink ? ttcTitleInk : p.line),
              ),
              child: Text(label,
                  style: pvManrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: ink ? Colors.white : p.ink1)),
            ),
          ),
        );
    return Container(
      key: const ValueKey('ttc_appt_follow_up'),
      decoration: BoxDecoration(
        color: v2BlockTint(kIvfHue, p),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Did you get your answers?',
            style: pvJakarta(
                fontSize: 16.5, fontWeight: FontWeight.w700, color: p.ink1)),
        const SizedBox(height: 5),
        Text(body,
            style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink2)),
        const SizedBox(height: 12),
        _RowGroup(p: p, children: [
          for (final q in left)
            TtcApptQuestionRow(
              p: p,
              question: q,
              caption: ttcQuestionCaption(q),
              onTick: () => ttcTickQuestion(context, q, visitId),
            ),
        ]),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: [
          button('Keep for the next visit',
              const ValueKey('ttc_appt_keep_next'), () {
            final before = store.keepForNextVisit(visitId);
            if (before.isEmpty) return;
            HapticFeedback.selectionClick();
            pvSnack(context, 'Kept for your next visit.',
                action: 'Undo',
                onAction: () => store.revert(before),
                lift: 24);
          }, false),
          button('Done', const ValueKey('ttc_appt_done'), () {
            final before = store.doneAt(visitId);
            if (before.isEmpty) return;
            HapticFeedback.selectionClick();
            pvSnack(
                context,
                before.length == 1
                    ? '1 question marked as asked.'
                    : '${before.length} questions marked as asked.',
                action: 'Undo',
                onAction: () => store.revert(before),
                lift: 24);
          }, true),
        ]),
      ]),
    );
  }
}

/// The one quiet line on the Appointments list: the latest visit that has
/// happened with her questions unticked. Opens that visit's page, where the
/// ticks and "Done" are.
class TtcApptFollowUpLine extends StatelessWidget {
  const TtcApptFollowUpLine({super.key, required this.visit, required this.p});

  final TtcVisitRef visit;
  final V2Palette p;

  @override
  Widget build(BuildContext context) {
    final passed = TtcDoctorQuestionsStore.dayPassed(visit, DateTime.now());
    final title = '${visit.title}, '
        '${ttcApptRelative(visit.startsLocal).toLowerCase()}';
    final ask = passed
        ? 'Did you get your answers?'
        : 'Tick the questions you asked';
    return Semantics(
      button: true,
      label: '$title. $ask',
      excludeSemantics: true,
      child: InkWell(
        key: const ValueKey('ttc_appt_follow_up_line'),
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          final entry = ttcApptEntries()
              .where((e) => e.visitId == visit.id)
              .firstOrNull;
          // A booking that has happened is off the list (the list shows
          // upcoming bookings), so its entry is built from the visit.
          openTtcAppointment(
              context,
              entry ??
                  TtcApptEntry(
                    title: visit.title,
                    startsUtc: visit.startsUtc,
                    detail: TtcS.current().appointmentsViaParentVeda,
                    fromParentVeda: true,
                    bookingId: visit.id.startsWith('booking:')
                        ? visit.id.substring('booking:'.length)
                        : visit.id,
                  ));
        },
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: p.line),
          ),
          child: Row(children: [
            Icon(Icons.fact_check_outlined, size: 19, color: p.ink2),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ask,
                        style: pvManrope(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: p.ink1)),
                    const SizedBox(height: 2),
                    Text(title,
                        style: pvManrope(
                            fontSize: 12.5, height: 1.4, color: p.ink2)),
                  ]),
            ),
            Icon(Icons.chevron_right_rounded, size: 20, color: p.ink3),
          ]),
        ),
      ),
    );
  }
}

// Kept for revert (2026-09-28, a question belongs to a visit): the list of
// questions before ticks, captions and the visit a new one goes to.
// /// The saved questions for the doctor, each one opening to change it, and
// /// the way to write another. Used on the list and on each visit's page.
// class TtcApptQuestions extends StatelessWidget {
//   const TtcApptQuestions(
//       {super.key, required this.p, required this.questions});
//
//   final V2Palette p;
//   // Kept for revert (2026-09-28): final List<TtcJournalEntry> questions;
//   final List<TtcDoctorQuestion> questions;
//
//   @override
//   Widget build(BuildContext context) {
//     final add = InkWell(
//       key: const ValueKey('ttc_appt_add_question'),
//       // Kept for revert (2026-09-28, journal out of TTC):
//       //   onTap: () => writeTtcEntry(context, kind: TtcEntryKind.question),
//       onTap: () => writeTtcDoctorQuestion(context),
//       child: Padding(
//         padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
//         child: Row(children: [
//           Icon(Icons.add_rounded, size: 19, color: p.ink1),
//           const SizedBox(width: 9),
//           Text(
//               questions.isEmpty
//                   ? 'Write a question'
//                   : TtcS.current().appointmentsAddQuestion,
//               style: pvManrope(
//                   fontSize: 14, fontWeight: FontWeight.w800, color: p.ink1)),
//         ]),
//       ),
//     );
//     return _RowGroup(p: p, children: [
//       for (final q in questions)
//         InkWell(
//           // ⚠️ A QUESTION OPENS (tool rebuild, 2026-09-27). It was a line of
//           // text with a purple dot and no way to change or remove it once
//           // the visit had answered it.
//           // Kept for revert (2026-09-28):
//           //   onTap: () => openTtcJournalEntry(context, q),
//           key: ValueKey('ttc_appt_question_${q.id}'),
//           onTap: () => openTtcDoctorQuestion(context, q),
//           child: Padding(
//             padding: const EdgeInsets.fromLTRB(14, 13, 10, 13),
//             child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//               Padding(
//                 padding: const EdgeInsets.only(top: 2),
//                 child: Icon(Icons.help_outline_rounded,
//                     size: 17, color: p.ink3),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: Text(q.text,
//                     maxLines: 4,
//                     overflow: TextOverflow.ellipsis,
//                     style: pvManrope(
//                         fontSize: 14, height: 1.5, color: p.ink1)),
//               ),
//               Icon(Icons.chevron_right_rounded, size: 19, color: p.ink3),
//             ]),
//           ),
//         ),
//       add,
//     ]);
//   }
// }

// =============================================================================
//  2. One visit's page
// =============================================================================

/// Opens one appointment on its own page.
Future<void> openTtcAppointment(BuildContext context, TtcApptEntry entry) =>
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => TtcAppointmentScreen(entry: entry),
      settings: const RouteSettings(name: 'ttc/appointment'),
    ));

class TtcAppointmentScreen extends StatelessWidget {
  const TtcAppointmentScreen({super.key, required this.entry});

  /// As it was when opened. The couple's own appointment is read fresh from
  /// the store on every build, so a change made on the form shows here.
  final TtcApptEntry entry;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        TtcAppointmentsStore.instance,
        // Kept for revert (2026-09-28): TtcJournalStore.instance,
        TtcDoctorQuestionsStore.instance,
        V2PaletteStore.instance,
      ]),
      builder: (context, _) {
        final p = V2PaletteStore.instance.current;
        final id = entry.own?.id;
        final fresh = id == null
            ? null
            : TtcAppointmentsStore.instance.all
                .where((a) => a.id == id)
                .firstOrNull;
        final a = fresh ?? entry.own;
        final title = a?.title ?? entry.title;
        final local = a?.startsLocal ?? entry.startsLocal;
        final upcoming = local.isAfter(DateTime.now());
        final rel = ttcApptRelative(local);
        final when = rel == ttcApptDay(local)
            ? '$rel at ${ttcApptTime(local)}.'
            : '$rel, ${ttcApptDay(local)} at ${ttcApptTime(local)}.';
        // Kept for revert (2026-09-28):
        //   final questions = TtcJournalStore.instance.doctorQuestions;
        // Kept for revert (2026-09-28, a question belongs to a visit):
        //   final questions = TtcDoctorQuestionsStore.instance.questions;
        final qs = TtcDoctorQuestionsStore.instance;
        final visitId = entry.visitId;
        final now = DateTime.now();
        final visitDay = DateTime(local.year, local.month, local.day);
        final today = DateTime(now.year, now.month, now.day);
        // Its day has come: her questions carry a tick.
        final dayCame = !visitDay.isAfter(today);
        // Its day is over: unticked questions are on the next visit now.
        final dayOver = visitDay.isBefore(today);
        final questions = qs.openFor(visitId);
        final asked = qs.askedAt(visitId);
        final pendingAfter = qs.notTickedAfter(visitId);

        return TtcToolScaffold(
          hue: kIvfHue,
          variant: 1,
          // One visit, opened from the list: back, not an X (2026-09-29).
          leading: TtcToolLeading.back,
          eyebrow: 'Appointment',
          title: title,
          intro: upcoming
              ? when
              : 'This was on ${ttcApptDay(local)} at ${ttcApptTime(local)}.',
          children: [
            ttcToolPad(Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 22),
                _RowGroup(p: p, children: [
                  _InfoRow(
                      p: p,
                      icon: Icons.event_outlined,
                      label: 'When',
                      value: '${ttcApptDay(local)} at ${ttcApptTime(local)}'),
                  if (a == null)
                    _InfoRow(
                        p: p,
                        icon: Icons.storefront_outlined,
                        // Change 5 (2026-09-28). Kept for revert: 'Where it
                        // came from' / "…It can't be changed here."
                        label: 'Where the visit came from',
                        value: 'Booked in ParentVeda. A booked visit can\'t '
                            'be changed on this page.')
                  else ...[
                    _InfoRow(
                        p: p,
                        icon: Icons.person_outline_rounded,
                        label: 'Who with',
                        value: a.withWhom,
                        // Change 5 (2026-09-28). Kept for revert: "Add who
                        // it's with".
                        addLabel: 'Add who the visit is with',
                        onAdd: () => editTtcAppointment(context, a)),
                    _InfoRow(
                        p: p,
                        icon: Icons.notes_rounded,
                        label: 'Notes',
                        value: a.note ?? '',
                        addLabel: 'Add a note, like what to bring',
                        onAdd: () => editTtcAppointment(context, a)),
                  ],
                ]),

                if (a != null && upcoming) ...[
                  const SizedBox(height: 14),
                  _RowGroup(p: p, children: [
                    TtcApptRemindRow(
                      p: p,
                      value: a.remindEveningBefore,
                      // The time it really rings, 2026-10-01. Kept for
                      // revert: 'At 7 pm on ${ttcApptDay(a.reminderAt)}.'
                      // Off: what it WOULD do; on: what it will.
                      sub: a.remindEveningBefore
                          ? ttcApptReminderSaidAt(a)
                          : ttcApptReminderLine(a.startsLocal),
                      onChanged: (v) {
                        final tooSoon = v &&
                            ttcApptReminderPlan(a.startsLocal).kind ==
                                TtcApptReminderKind.none;
                        TtcAppointmentsStore.instance
                            .update(a.copyWith(remindEveningBefore: v));
                        if (tooSoon) {
                          pvSnack(
                              context,
                              'This is too soon for a reminder, so none is '
                              'set.',
                              lift: 24);
                        } else if (v) {
                          _askPhonePermission();
                        }
                      },
                    ),
                  ]),
                ],

                // Kept for revert (2026-09-28, a question belongs to a visit):
                // every saved question, on every coming visit, no ticks.
                //   if (upcoming) ...[ Text('Questions to take'), Text(
                //     questions.isEmpty ? 'Write them down when you think of
                //     them, so nothing is forgotten in the room.' :
                //     'Everything you saved for the doctor. Tap one to change
                //     it or remove it once it\'s answered.'),
                //     TtcApptQuestions(p: p, questions: questions) ],
                //
                // ⚠️ THREE STATES, BY THE VISIT'S DAY. Before it: the
                // questions kept for it, each opening to change. On the day:
                // the same rows with a tick each. After it: the one "Did you
                // get your answers?" card for any of hers left unticked
                // (already on the next visit, derived), then the ticked ones
                // folded under "Asked".
                const SizedBox(height: 26),
                // Kept for revert (2026-09-29, one heading style):
                // Text('Questions to ask', style: pvJakarta(
                //     fontSize: 17, fontWeight: FontWeight.w700, color: p.ink1)),
                const TtcSectionHeading('Questions to ask'),
                const SizedBox(height: 5),
                Text(
                    dayOver
                        ? (asked.isEmpty && pendingAfter.isEmpty
                            ? 'No questions were saved for the $title.'
                            : 'What you asked at the $title.')
                        : dayCame
                            ? 'Tick each question once you have asked it. '
                                'Any left unticked move to your next visit '
                                'the day after.'
                            : questions.isEmpty
                                ? 'Write questions for the $title when you '
                                    'think of them, so nothing is forgotten '
                                    'in the room.'
                                : 'Kept for the $title. On the day, tick '
                                    'each one once you have asked it.',
                    style:
                        pvManrope(fontSize: 13, height: 1.5, color: p.ink3)),
                const SizedBox(height: 12),
                if (dayOver) ...[
                  if (pendingAfter.isNotEmpty) ...[
                    TtcApptFollowUpCard(p: p, visitId: visitId),
                    const SizedBox(height: 12),
                  ],
                ] else
                  TtcApptQuestions(
                    p: p,
                    questions: questions,
                    visitId: visitId,
                    tickable: dayCame,
                  ),
                if (asked.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  TtcApptAskedFold(p: p, questions: asked),
                ],

                if (a != null) ...[
                  const SizedBox(height: 26),
                  TtcToolPrimary(
                    key: const ValueKey('ttc_appt_change'),
                    label: 'Change details',
                    onTap: () => editTtcAppointment(context, a),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: TextButton.icon(
                      key: const ValueKey('ttc_appt_remove'),
                      onPressed: () => _remove(context, a),
                      icon: const Icon(Icons.delete_outline_rounded,
                          size: 17, color: _kDanger),
                      label: Text('Remove this appointment',
                          style: pvManrope(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: _kDanger)),
                    ),
                  ),
                ],
                const SizedBox(height: 26),
              ],
            )),
          ],
        );
      },
    );
  }

  Future<void> _remove(BuildContext context, TtcAppointment a) async {
    final nav = Navigator.of(context);
    final ok = await ttcConfirmRemove(context,
        title: 'Remove ${a.title}?',
        body: a.remindEveningBefore
            ? 'It comes off this list and your calendar, and its reminder '
                'is turned off.'
            : 'It comes off this list and your calendar.');
    if (!ok || !context.mounted) return;
    TtcAppointmentsStore.instance.remove(a.id);
    HapticFeedback.selectionClick();
    pvSnack(context, 'Appointment removed.',
        action: 'Undo',
        onAction: () => TtcAppointmentsStore.instance.restore(a),
        lift: 24);
    nav.pop();
  }
}

void _askPhonePermission() {
  NotificationService.instance.requestPermission().catchError((_) => false);
}

/// One labelled line on a visit's page. Empty, it says how to fill it and
/// the tap does exactly that.
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.p,
    required this.icon,
    required this.label,
    required this.value,
    this.addLabel,
    this.onAdd,
  });

  final V2Palette p;
  final IconData icon;
  final String label;
  final String value;
  final String? addLabel;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final empty = value.trim().isEmpty;
    final body = Padding(
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(icon, size: 19, color: p.ink2),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label.toUpperCase(),
                style: pvManrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.9,
                    color: p.ink3)),
            const SizedBox(height: 4),
            Text(empty ? (addLabel ?? '') : value,
                style: pvManrope(
                    fontSize: 14.5,
                    height: 1.45,
                    fontWeight: empty ? FontWeight.w800 : FontWeight.w600,
                    color: p.ink1)),
          ]),
        ),
        if (empty && onAdd != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Icon(Icons.add_rounded, size: 19, color: p.ink1),
          ),
      ]),
    );
    return empty && onAdd != null ? InkWell(onTap: onAdd, child: body) : body;
  }
}

/// The reminder, said from a visit's day and time while she is still choosing
/// them ([ttcApptReminderPlan]): when it will ring, why that time, or that it
/// cannot.
String ttcApptReminderLine(DateTime startsLocal, {DateTime? now}) {
  final plan = ttcApptReminderPlan(startsLocal, now: now);
  final at = plan.at;
  switch (plan.kind) {
    case TtcApptReminderKind.eveningBefore:
      return 'At 7 pm on ${ttcApptDay(at!)}, the evening before.';
    case TtcApptReminderKind.twoHoursBefore:
      return 'The evening before has passed, so it will ring 2 hours '
          'before, at ${ttcApptTime(at!)}.';
    case TtcApptReminderKind.thirtyMinutesBefore:
      return 'This is soon, so it will ring 30 minutes before, at '
          '${ttcApptTime(at!)}.';
    case TtcApptReminderKind.none:
      return 'This is too soon for a reminder, so none will be set.';
  }
}

/// The reminder of a saved visit, said at the time it rings.
String ttcApptReminderSaidAt(TtcAppointment a) {
  final at = a.reminderAt;
  switch (a.reminderKind) {
    case TtcApptReminderKind.eveningBefore:
      return 'At 7 pm on ${ttcApptDay(at)}, the evening before.';
    case TtcApptReminderKind.twoHoursBefore:
      return 'At ${ttcApptTime(at)}, 2 hours before.';
    case TtcApptReminderKind.thirtyMinutesBefore:
      return 'At ${ttcApptTime(at)}, 30 minutes before.';
    case TtcApptReminderKind.none:
      return '';
  }
}

/// The short tag on a visit's row.
String ttcApptReminderTag(TtcAppointment a) => switch (a.reminderKind) {
      TtcApptReminderKind.eveningBefore => 'Reminder the evening before',
      TtcApptReminderKind.twoHoursBefore => 'Reminder 2 hours before',
      TtcApptReminderKind.thirtyMinutesBefore => 'Reminder 30 minutes before',
      TtcApptReminderKind.none => 'Reminder the evening before',
    };

/// "Remind me before it", with when it will ring said under it.
///
/// Mobbin: Hers and Lifesum put a reminder on one switch row with its time
/// said beside it, so the switch says exactly what it will do.
class TtcApptRemindRow extends StatelessWidget {
  const TtcApptRemindRow({
    super.key,
    required this.p,
    required this.value,
    required this.sub,
    required this.onChanged,
  });

  final V2Palette p;
  final bool value;
  final String sub;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
        child: Row(children: [
          Icon(Icons.notifications_none_rounded, size: 19, color: p.ink2),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kept for revert (2026-10-01): 'Remind me the evening
                  // before', which was untrue for a visit soon after saving.
                  Text('Remind me before the visit',
                      style: pvManrope(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: p.ink1)),
                  const SizedBox(height: 2),
                  Text(sub,
                      style: pvManrope(
                          fontSize: 12.5, height: 1.4, color: p.ink3)),
                ]),
          ),
          Switch.adaptive(
            key: const ValueKey('ttc_appt_remind'),
            value: value,
            // Ink, not the brand purple: a switch is a control, not a
            // decoration.
            // Kept for revert (2026-09-28, one black switch app-wide): activeTrackColor: ttcTitleInk,
            onChanged: onChanged,
          ),
        ]),
      );
}

// =============================================================================
//  3. The form: add, or change
// =============================================================================

/// Add a clinic visit. Kept as the entry point every "Add" already calls.
Future<void> addTtcAppointment(BuildContext context) =>
    editTtcAppointment(context, null);

/// Add a new appointment, or change one of the couple's own.
///
/// ⚠️ A PAGE IN THE TOOL SHELL, NOT A BOTTOM SHEET (tool rebuild,
/// 2026-09-27). The sheet was white with purple buttons over a shell that is
/// neither, and a sheet with a keyboard up leaves a strip of form to type
/// into. Records made the same move for the same reason; the two forms now
/// look alike.
Future<void> editTtcAppointment(
        BuildContext context, TtcAppointment? existing) =>
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => TtcAppointmentEditScreen(existing: existing),
      settings: const RouteSettings(name: 'ttc/appointment_edit'),
    ));

class TtcAppointmentEditScreen extends StatefulWidget {
  const TtcAppointmentEditScreen({super.key, this.existing});
  final TtcAppointment? existing;

  @override
  State<TtcAppointmentEditScreen> createState() =>
      _TtcAppointmentEditScreenState();
}

class _TtcAppointmentEditScreenState extends State<TtcAppointmentEditScreen> {
  late final TextEditingController _title =
      TextEditingController(text: widget.existing?.title ?? '');
  late final TextEditingController _who =
      TextEditingController(text: widget.existing?.withWhom ?? '');
  late final TextEditingController _note =
      TextEditingController(text: widget.existing?.note ?? '');
  late DateTime _when = widget.existing?.startsLocal ??
      () {
        final t = DateTime.now().add(const Duration(days: 1));
        return DateTime(t.year, t.month, t.day, 10);
      }();
  late bool _remind = widget.existing?.remindEveningBefore ?? false;
  bool _needsTitle = false;
  bool _saved = false;

  bool get _editing => widget.existing != null;

  /// The quick names. The visits a trying couple actually books, so the
  /// common case is one tap instead of typing on a phone in a corridor.
  static const _quick = [
    'Follicle scan',
    'Blood test',
    'Consultation',
    'Follow-up',
  ];

  bool get _dirty {
    final e = widget.existing;
    if (_saved) return false;
    if (e == null) {
      return _title.text.trim().isNotEmpty ||
          _who.text.trim().isNotEmpty ||
          _note.text.trim().isNotEmpty;
    }
    return _title.text.trim() != e.title ||
        _who.text.trim() != e.withWhom ||
        _note.text.trim() != (e.note ?? '') ||
        _when != e.startsLocal ||
        _remind != e.remindEveningBefore;
  }

  @override
  void dispose() {
    _title.dispose();
    _who.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickDay() async {
    final day = await showDatePicker(
      context: context,
      helpText: 'Day of the appointment',
      initialDate: _when,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (day == null || !mounted) return;
    setState(() => _when =
        DateTime(day.year, day.month, day.day, _when.hour, _when.minute));
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      helpText: 'Time of the appointment',
      initialTime: TimeOfDay.fromDateTime(_when),
    );
    // A closed picker keeps the time she had.
    if (time == null || !mounted) return;
    setState(() => _when = DateTime(
        _when.year, _when.month, _when.day, time.hour, time.minute));
  }

  void _save() {
    if (_title.text.trim().isEmpty) {
      setState(() => _needsTitle = true);
      return;
    }
    final store = TtcAppointmentsStore.instance;
    final e = widget.existing;
    final note = _note.text.trim();
    if (e == null) {
      store.add(
        title: _title.text,
        withWhom: _who.text,
        startsLocal: _when,
        note: note.isEmpty ? null : note,
        remindEveningBefore: _remind,
      );
    } else {
      store.update(e.copyWith(
        title: _title.text,
        withWhom: _who.text,
        startsLocal: _when,
        note: note,
        remindEveningBefore: _remind,
      ));
    }
    _saved = true;
    HapticFeedback.selectionClick();
    // ⚠️ NEVER SILENT ABOUT A REMINDER THAT WILL NOT RING (2026-10-01, the
    // user). She switched it on; if the visit is too soon for any reminder it
    // was switched off, so the message says so rather than leave her trusting
    // it.
    final tooSoon = _remind &&
        ttcApptReminderPlan(_when).kind == TtcApptReminderKind.none;
    pvSnack(
        context,
        tooSoon
            ? (e == null
                ? 'Added. It is too soon for a reminder, so none is set.'
                : 'Saved. It is too soon for a reminder, so none is set.')
            : (e == null ? 'Added to your appointments.' : 'Changes saved.'),
        icon: Icons.check_rounded,
        lift: 24);
    Navigator.of(context).pop();
  }

  /// Nothing silent: leaving with changes asks first.
  Future<bool> _confirmLeave() async {
    final p = V2PaletteStore.instance.current;
    final leave = await showDialog<bool>(
      context: context,
      routeSettings: const RouteSettings(name: 'ttc/confirm_leave'),
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        // Change 5 (2026-09-28). Kept for revert: 'Discard this?'.
        title: Text(_editing ? 'Leave without saving?' : 'Discard this visit?',
            style: pvFraunces(fontSize: 20, color: p.ink1)),
        content: Text(
            _editing
                ? 'Your changes will not be kept.'
                : 'This appointment will not be added.',
            style: pvManrope(fontSize: 14, height: 1.45, color: p.ink2)),
        actions: [
          TextButton(
              key: const ValueKey('ttc_appt_keep_editing'),
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Keep editing',
                  style: pvManrope(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: p.ink1))),
          TextButton(
              key: const ValueKey('ttc_appt_discard'),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Discard',
                  style: pvManrope(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: _kDanger))),
        ],
      ),
    );
    return leave == true;
  }

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final showQuick = _title.text.trim().isEmpty;
    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmLeave() && context.mounted) {
          _saved = true; // lets this pop through
          setState(() {});
          Navigator.of(context).pop();
        }
      },
      child: TtcToolScaffold(
        hue: kIvfHue,
        variant: 3,
        eyebrow: 'Appointments',
        title: _editing ? 'Change this appointment' : 'Add an appointment',
        intro: 'What it is and when is enough to save. The rest is optional.',
        children: [
          ttcToolPad(Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 22),
              _FormBlock(
                p: p,
                // Change 5 (2026-09-28). Kept for revert: 'What is it?'.
                title: 'What kind of visit?',
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ApptField(
                        controller: _title,
                        fieldKey: const ValueKey('ttc_appt_title'),
                        hint: 'For example Follicle scan',
                        autofocus: !_editing,
                        onChanged: (_) => setState(() => _needsTitle = false),
                      ),
                      if (showQuick) ...[
                        const SizedBox(height: 10),
                        Wrap(spacing: 8, runSpacing: 8, children: [
                          for (final q in _quick)
                            TtcToolPill(
                              label: q,
                              on: false,
                              hue: kIvfHue,
                              onTap: () => setState(() {
                                _title.text = q;
                                _title.selection =
                                    TextSelection.collapsed(offset: q.length);
                                _needsTitle = false;
                              }),
                            ),
                        ]),
                      ],
                    ]),
              ),
              _FormBlock(
                p: p,
                title: 'When',
                note: 'Tap the day or the time to change it.',
                child: Row(children: [
                  Expanded(
                    flex: 3,
                    child: _PickChip(
                      key: const ValueKey('ttc_appt_day'),
                      p: p,
                      icon: Icons.calendar_today_outlined,
                      text: ttcApptDay(_when),
                      onTap: _pickDay,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: _PickChip(
                      key: const ValueKey('ttc_appt_time'),
                      p: p,
                      icon: Icons.schedule_rounded,
                      text: ttcApptTime(_when),
                      onTap: _pickTime,
                    ),
                  ),
                ]),
              ),
              _FormBlock(
                p: p,
                title: 'Who with',
                note: 'Optional.',
                child: _ApptField(
                  controller: _who,
                  fieldKey: const ValueKey('ttc_appt_who'),
                  hint: 'Doctor or clinic',
                  onChanged: (_) => setState(() {}),
                ),
              ),
              _FormBlock(
                p: p,
                title: 'Notes',
                note: 'Optional. What to bring, or anything the clinic told '
                    'you to do before.',
                child: _ApptField(
                  controller: _note,
                  fieldKey: const ValueKey('ttc_appt_note'),
                  hint: 'For example Bring the last scan report',
                  lines: 3,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: p.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: p.line),
                ),
                child: TtcApptRemindRow(
                  p: p,
                  value: _remind,
                  // ⚠️ SAYS THE REAL TIME, FROM THE DAY AND TIME SHE PICKED
                  // (2026-10-01). It said "at 7 pm the day before" even for a
                  // visit tomorrow morning, whose 7 pm had already gone, and
                  // nothing rang. Now it shows when it will ring, or says it
                  // cannot. Kept for revert: 'Your phone will remind you at 7
                  // pm the day before.'
                  sub: ttcApptReminderLine(_when),
                  onChanged: (v) {
                    setState(() => _remind = v);
                    if (v &&
                        ttcApptReminderPlan(_when).kind !=
                            TtcApptReminderKind.none) {
                      _askPhonePermission();
                    }
                  },
                ),
              ),
              TtcToolPrimary(
                key: const ValueKey('ttc_appt_save'),
                label: _editing ? 'Save changes' : 'Save',
                onTap: _save,
              ),
              if (_needsTitle)
                const TtcFormHint(text: 'Add what it is to save.'),
              const SizedBox(height: 26),
            ],
          )),
        ],
      ),
    );
  }
}

/// One labelled part of the form. The same block Records' form uses
/// (`TtcRecordBlock`): white, a hairline, the question on top.
class _FormBlock extends StatelessWidget {
  const _FormBlock({
    required this.p,
    required this.title,
    required this.child,
    this.note,
  });

  final V2Palette p;
  final String title;
  final String? note;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: p.line),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: pvJakarta(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                  height: 1.32,
                  color: p.ink1)),
          if (note != null) ...[
            const SizedBox(height: 5),
            Text(note!,
                style: pvManrope(fontSize: 12, height: 1.45, color: p.ink3)),
          ],
          const SizedBox(height: 12),
          child,
        ]),
      );
}

/// A text box in the tool's clothes: white, a hairline, ink when it holds
/// something. Matches Records' `TtcRecordField`.
class _ApptField extends StatelessWidget {
  const _ApptField({
    required this.controller,
    required this.hint,
    this.fieldKey,
    this.lines = 1,
    this.autofocus = false,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final Key? fieldKey;
  final int lines;
  final bool autofocus;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final has = controller.text.trim().isNotEmpty;
    OutlineInputBorder edge(Color c) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c, width: 1.5),
        );
    return TextField(
      key: fieldKey,
      controller: controller,
      autofocus: autofocus,
      minLines: lines,
      maxLines: lines,
      textCapitalization: TextCapitalization.sentences,
      onChanged: onChanged,
      style: ttcBody(14.5, color: ttcTitleInk, w: FontWeight.w700),
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        hintStyle: ttcBody(14, color: ttcMuted, w: FontWeight.w500),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        enabledBorder: edge(has ? ttcTitleInk : ttcLine),
        focusedBorder: edge(ttcTitleInk),
        border: edge(ttcLine),
      ),
    );
  }
}

/// A day or a time, as a box that says it can be tapped.
class _PickChip extends StatelessWidget {
  const _PickChip({
    super.key,
    required this.p,
    required this.icon,
    required this.text,
    required this.onTap,
  });

  final V2Palette p;
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
          // ⚠️ A HAIRLINE LIKE EVERY OTHER FIELD ON THE FORM (2026-10-01, the
          // user: "why is date and time having a black border for no reason,
          // without even being clicked"). A 1.5pt ink border is how this app
          // draws a CHOSEN option, so an untouched date read as selected. The
          // chevron says it opens a picker. Kept for revert: the border was
          // `Border.all(color: ttcTitleInk, width: 1.5)`.
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: p.line, width: 1.2),
          ),
          child: Row(children: [
            Icon(icon, size: 16, color: ttcTitleInk),
            const SizedBox(width: 8),
            Flexible(
              child: Text(text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ttcBody(14, color: ttcTitleInk, w: FontWeight.w700)),
            ),
            const SizedBox(width: 4),
            Icon(Icons.expand_more_rounded, size: 18, color: p.ink3),
          ]),
        ),
      );
}


// =============================================================================
//  Kept for revert (2026-09-27, tool rebuild): the list, card and bottom-sheet
//  form this file shipped before the rebuild above. Superseded by
//  TtcAppointmentsScreen / TtcAppointmentScreen / TtcAppointmentEditScreen.
//  (Dart block comments nest, so the older commented sheet inside is safe.)
// =============================================================================
/*
/// One row on the merged list, from either source.
class _Entry {
  const _Entry({
    required this.title,
    required this.startsUtc,
    required this.detail,
    required this.fromParentVeda,
    this.id,
    this.own,
  });

  final String title;
  final DateTime startsUtc;
  final String detail;
  final bool fromParentVeda;

  /// Only set for the couple's own appointments - the ones they may delete.
  final String? id;

  /// The couple's own appointment, so a tap can open it to change it.
  final TtcAppointment? own;
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
        // Only the commented-out foot note read this. Kept for revert:
        // final hi = t.hinglish;

        final entries = <_Entry>[
          for (final a in TtcAppointmentsStore.instance.all)
            _Entry(
              id: a.id,
              own: a,
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

        // ⚠️ V3 CHROME, SHELL ONLY. Every list, dialog and store call below is
        // untouched. A tool reached from a focus page has to look like it
        // belongs to the page that sent her, and this one still wore a flat
        // ground and a back bar. See `ttc_tool_chrome.dart`.
        return TtcToolScaffold(
          hue: kIvfHue,
          eyebrow: t.appointmentsTitle,
          // Monitoring scans arrive at short notice, which is the whole reason
          // this screen exists during a treatment cycle.
          title: 'Where you have to be, and when.',
          intro: t.appointmentsIntro,
          action: GestureDetector(
            onTap: () => addTtcAppointment(context),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
              decoration: BoxDecoration(
                  color: ttcTitleInk,
                  borderRadius: BorderRadius.circular(999)),
              child: Text(t.appointmentsAdd,
                  style: ttcBody(12,
                      color: Colors.white, w: FontWeight.w800)),
            ),
          ),
          // ⚠️ THE GUTTER (launch walk, 2026-09-27): the tool frame leaves
          // side padding to the screen, and this one had none. Kept for
          // revert: the children sat directly in this list.
          children: [
            ttcToolPad(Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 22),

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
                                        color: ttcTitleInk,
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
                                  size: 16, color: ttcTitleInk),
                              const SizedBox(width: 7),
                              Text(t.appointmentsAddQuestion,
                                  style: ttcBody(12.5,
                                      color: ttcTitleInk, w: FontWeight.w800)),
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

                // ⚠️ SAID ONCE (tools pass, 2026-09-27): the intro already
                // says this list is what you and ParentVeda added, and the
                // empty state says to add clinic visits yourselves, so this
                // foot note was the third telling. Kept for revert:
                // const SizedBox(height: 12),
                // Text(
                //   hi
                //       ? 'Yahan sirf wahi hai jo aap ya ParentVeda ne add kiya. Hum aapke clinic se apne aap kuch nahi laate.'
                //       : "This only shows what you or ParentVeda added. We don't bring in anything from your clinic on our own.",
                //   style: ttcBody(11.5, color: ttcMuted, h: 1.5),
                // ),
                const SizedBox(height: 26),
              ],
            )),
          ],
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
    final own = entry.own;
    return TtcCard(
      // ⚠️ TAP TO CHANGE (tools pass, 2026-09-27). A moved scan used to mean
      // delete and add again, which is the most common change in a treatment
      // cycle. A ParentVeda booking stays read-only: the engine owns the seat.
      onTap: own == null ? null : () => editTtcAppointment(context, own),
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
                style: ttcJakarta(16, color: faded ? ttcMuted : ttcTitleInk)),
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
            if (own != null && own.remindEveningBefore && !faded) ...[
              const SizedBox(height: 6),
              Row(children: [
                const Icon(Icons.notifications_none_rounded,
                    size: 14, color: ttcTitleInk),
                const SizedBox(width: 5),
                Text('Reminder the evening before',
                    style: ttcBody(11.5, color: ttcSoft, w: FontWeight.w600)),
              ]),
            ],
            // The source is a tag, never a section heading.
            if (entry.fromParentVeda) ...[
              const SizedBox(height: 7),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                    color: ttcPanel, borderRadius: BorderRadius.circular(999)),
                child: Text(t.appointmentsViaParentVeda,
                    style: ttcBody(9.5, color: ttcTitleInk, w: FontWeight.w800)),
              ),
            ],
          ]),
        ),
        // Only the couple's own appointments are theirs to change - the engine
        // owns a booked seat.
        //
        // ⚠️ A CHEVRON, NOT AN "x" (tools pass, 2026-09-27). The x deleted at
        // once with no question. Removing now lives inside the edit sheet,
        // behind a confirm, and the row says it opens. Kept for revert:
        // if (entry.id != null)
        //   GestureDetector(
        //     onTap: () => TtcAppointmentsStore.instance.remove(entry.id!),
        //     behavior: HitTestBehavior.opaque,
        //     child: const Padding(
        //       padding: EdgeInsets.only(left: 10),
        //       child: Icon(Icons.close_rounded, size: 16, color: ttcMuted),
        //     ),
        //   ),
        if (own != null)
          const Padding(
            padding: EdgeInsets.only(left: 10, top: 10),
            child:
                Icon(Icons.chevron_right_rounded, size: 18, color: ttcMuted),
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

  static String _weekday(DateTime d) =>
      const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][d.weekday - 1];

  static String _monthWord(DateTime d) => const [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ][d.month - 1];

  static String _time(DateTime d) {
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final ampm = d.hour < 12 ? 'am' : 'pm';
    return '$h:${d.minute.toString().padLeft(2, '0')}$ampm';
  }
}

/// Add a clinic visit. Kept as the entry point every "Add" already calls.
Future<void> addTtcAppointment(BuildContext context) =>
    editTtcAppointment(context, null);

/// Add a new appointment, or change one of the couple's own.
///
/// ⚠️ REBUILT 2026-09-27 (tools pass) from the notes in
/// docs/TTC-TOOLS-UX-NOTES.md. What changed, and why each was a defect:
///  * Each field has a label ABOVE it. The labels were hints inside the box,
///    so once she typed, nothing said which box was which.
///  * The date row says "Change" on it. Nothing said it could be tapped.
///  * A closed time picker keeps the time she had. It used to drop to 10:00
///    without a word.
///  * Save with no name says "Add what it is to save" instead of doing
///    nothing.
///  * An optional reminder at 7 pm the evening before, which is what matters
///    for a short-notice monitoring scan.
///  * Editing and removing live here. Removing asks first.
Future<void> editTtcAppointment(
    BuildContext context, TtcAppointment? existing) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    routeSettings: const RouteSettings(name: 'ttc/appointment_edit'),
    builder: (_) => _ApptSheet(existing: existing),
  );
}

class _ApptSheet extends StatefulWidget {
  const _ApptSheet({this.existing});
  final TtcAppointment? existing;

  @override
  State<_ApptSheet> createState() => _ApptSheetState();
}

class _ApptSheetState extends State<_ApptSheet> {
  late final TextEditingController _title =
      TextEditingController(text: widget.existing?.title ?? '');
  late final TextEditingController _who =
      TextEditingController(text: widget.existing?.withWhom ?? '');
  late DateTime _when = widget.existing?.startsLocal ??
      () {
        final t = DateTime.now().add(const Duration(days: 1));
        return DateTime(t.year, t.month, t.day, 10);
      }();
  late bool _remind = widget.existing?.remindEveningBefore ?? false;
  bool _needsTitle = false;

  @override
  void dispose() {
    _title.dispose();
    _who.dispose();
    super.dispose();
  }

  Future<void> _pickWhen() async {
    final day = await showDatePicker(
      context: context,
      initialDate: _when,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (day == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_when),
    );
    if (!mounted) return;
    // Kept for revert (2026-09-27): a closed time picker set 10:00,
    // `time?.hour ?? 10, time?.minute ?? 0`. Now it keeps the time she had.
    setState(() => _when = DateTime(day.year, day.month, day.day,
        time?.hour ?? _when.hour, time?.minute ?? _when.minute));
  }

  void _save() {
    if (_title.text.trim().isEmpty) {
      setState(() => _needsTitle = true);
      return;
    }
    final store = TtcAppointmentsStore.instance;
    final e = widget.existing;
    if (e == null) {
      store.add(
        title: _title.text,
        withWhom: _who.text,
        startsLocal: _when,
        remindEveningBefore: _remind,
      );
    } else {
      store.update(e.copyWith(
        title: _title.text,
        withWhom: _who.text,
        startsLocal: _when,
        remindEveningBefore: _remind,
      ));
    }
    Navigator.of(context).pop();
  }

  Future<void> _remove() async {
    final e = widget.existing!;
    final nav = Navigator.of(context);
    final ok = await ttcConfirmRemove(context,
        title: 'Remove ${e.title}?',
        body: 'It comes off this list and your calendar.');
    if (!ok) return;
    TtcAppointmentsStore.instance.remove(e.id);
    nav.pop();
  }

  @override
  Widget build(BuildContext context) {
    final t = TtcS.current();
    final editing = widget.existing != null;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: ttcLine,
                          borderRadius: BorderRadius.circular(999)),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(editing ? 'Change this appointment' : 'Add an appointment',
                      style: ttcJakarta(17)),
                  const SizedBox(height: 14),
                  _label('What is it'),
                  _sheetField(_title, 'Scan, blood test, follow-up',
                      autofocus: !editing, onChanged: (_) {
                    if (_needsTitle) setState(() => _needsTitle = false);
                  }),
                  const SizedBox(height: 12),
                  _label('Who with (optional)'),
                  _sheetField(_who, 'Doctor or clinic'),
                  const SizedBox(height: 12),
                  _label('Date and time'),
                  GestureDetector(
                    key: const ValueKey('ttc_appt_when'),
                    onTap: _pickWhen,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                          color: ttcBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: ttcBorder)),
                      child: Row(children: [
                        const Icon(Icons.schedule_rounded,
                            size: 16, color: ttcTitleInk),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Text(
                              '${_EntryCard._weekday(_when)} ${_when.day} '
                              '${_EntryCard._monthWord(_when)} · '
                              '${_EntryCard._time(_when)}',
                              style: ttcBody(14,
                                  color: ttcInk, w: FontWeight.w600)),
                        ),
                        Text('Change',
                            style: ttcBody(12.5,
                                color: ttcTitleInk, w: FontWeight.w800)),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Mobbin: Hers and Lifesum put a reminder on one switch row
                  // with its time said beside it, so the switch says exactly
                  // what it will do.
                  Row(children: [
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Remind me the evening before',
                                style: ttcBody(14,
                                    color: ttcInk, w: FontWeight.w700)),
                            const SizedBox(height: 2),
                            Text('Your phone will remind you at 7 pm the day '
                                'before.',
                                style: ttcBody(12, color: ttcSoft)),
                          ]),
                    ),
                    Switch.adaptive(
                      key: const ValueKey('ttc_appt_remind'),
                      value: _remind,
                      // Kept for revert (2026-09-28, one black switch app-wide): activeTrackColor: ttcPurple,
                      onChanged: (v) {
                        setState(() => _remind = v);
                        if (v) {
                          NotificationService.instance
                              .requestPermission()
                              .catchError((_) => false);
                        }
                      },
                    ),
                  ]),
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                              // Kept for revert (2026-09-29, no tinted slab behind text): color: ttcPanel,
                              color: Colors.white, border: const Border.fromBorderSide(BorderSide(color: ttcLine)),
                              borderRadius: BorderRadius.circular(16)),
                          child: Text(t.journalCancel,
                              style: ttcBody(14,
                                  color: ttcTitleInk, w: FontWeight.w800)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        key: const ValueKey('ttc_appt_save'),
                        onTap: _save,
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
                  if (_needsTitle)
                    const TtcFormHint(text: 'Add what it is to save.'),
                  if (editing) ...[
                    const SizedBox(height: 8),
                    Center(
                      child: GestureDetector(
                        onTap: _remove,
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text('Remove this appointment',
                              style: ttcBody(12.5,
                                  color: ttcMuted, w: FontWeight.w700)),
                        ),
                      ),
                    ),
                  ],
                ]),
          ),
        ),
      ),
    );
  }

  Widget _label(String s) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(s.toUpperCase(),
            style: ttcBody(9.5, color: ttcMuted, w: FontWeight.w800)),
      );
}

// Kept for revert (2026-09-27): the add-only sheet, superseded by
// `editTtcAppointment` above.
/*
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
                  const Icon(Icons.schedule_rounded, size: 16, color: ttcTitleInk),
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
                        // Kept for revert (2026-09-29, no tinted slab behind text): color: ttcPanel,
                        color: Colors.white, border: const Border.fromBorderSide(BorderSide(color: ttcLine)),
                        borderRadius: BorderRadius.circular(16)),
                    child: Text(t.journalCancel,
                        style: ttcBody(14, color: ttcTitleInk, w: FontWeight.w800)),
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
                        color: ttcTitleInk,
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
  // ⚠️ NOT DISPOSED THE MOMENT THE ROUTE CLOSES (2026-10-02, the red screen '_dependents.isEmpty'): the TextField is still on screen for the exit animation and still listening. Same fix as the add-child sheet.
  Future<void>.delayed(const Duration(milliseconds: 600), titleC.dispose);
  Future<void>.delayed(const Duration(milliseconds: 600), whoC.dispose);
}

*/

Widget _sheetField(TextEditingController c, String hint,
        {bool autofocus = false, ValueChanged<String>? onChanged}) =>
    TextField(
      controller: c,
      autofocus: autofocus,
      onChanged: onChanged,
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
