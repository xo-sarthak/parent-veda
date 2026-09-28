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
import '../../ttc/ttc_journal_store.dart';
import '../../ttc/ttc_records_store.dart';
import '../products/pv_store_chrome.dart' show pvSnack;
import '../v2/v2_palette.dart';
import 'ttc_common.dart';
import 'ttc_ivf_readiness_screen.dart' show kIvfHue;
import 'ttc_journal_screen.dart' show writeTtcEntry, openTtcJournalEntry;
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
const Color _kDanger = Color(0xFFB42318);

/// One row on the merged list, from either source.
class TtcApptEntry {
  const TtcApptEntry({
    required this.title,
    required this.startsUtc,
    required this.detail,
    required this.fromParentVeda,
    this.own,
  });

  final String title;
  final DateTime startsUtc;
  final String detail;
  final bool fromParentVeda;

  /// The couple's own appointment. Null for a ParentVeda booking, which is
  /// read-only here because the booking engine owns the seat.
  final TtcAppointment? own;

  DateTime get startsLocal => startsUtc.toLocal();
  bool get isUpcoming => startsUtc.isAfter(DateTime.now().toUtc());
}

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
        TtcJournalStore.instance,
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
        final questions = TtcJournalStore.instance.doctorQuestions;
        // With nothing in the past there is nothing to switch to, so the
        // switch is not drawn. It appears the day the first visit passes.
        final showPast = _past && past.isNotEmpty;
        // The empty invitation is on screen (T13).
        final emptyShowing = !showPast && upcoming.isEmpty;

        return TtcToolScaffold(
          hue: kIvfHue,
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
                  _NextUp(
                      entry: upcoming.first,
                      p: p,
                      questions: questions.length),
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
                Text(t.appointmentsQuestions,
                    style: pvJakarta(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: p.ink1)),
                const SizedBox(height: 5),
                Text(
                    questions.isEmpty
                        ? t.appointmentsNoQuestionsBody
                        : 'These show on every visit that is coming up. '
                            'Tap one to change it.',
                    style:
                        pvManrope(fontSize: 13, height: 1.5, color: p.ink3)),
                const SizedBox(height: 12),
                TtcApptQuestions(p: p, questions: questions),

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
                    Text('NEXT',
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
                          text: 'Reminder the evening before'),
                    ],
                    if (questions > 0) ...[
                      const SizedBox(height: 6),
                      _Mini(
                          p: p,
                          icon: Icons.help_outline_rounded,
                          text: questions == 1
                              ? '1 question to take'
                              : '$questions questions to take'),
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
                        text: 'Reminder the evening before'),
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

/// The saved questions for the doctor, each one opening to change it, and
/// the way to write another. Used on the list and on each visit's page.
class TtcApptQuestions extends StatelessWidget {
  const TtcApptQuestions(
      {super.key, required this.p, required this.questions});

  final V2Palette p;
  final List<TtcJournalEntry> questions;

  @override
  Widget build(BuildContext context) {
    final add = InkWell(
      key: const ValueKey('ttc_appt_add_question'),
      onTap: () => writeTtcEntry(context, kind: TtcEntryKind.question),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Row(children: [
          Icon(Icons.add_rounded, size: 19, color: p.ink1),
          const SizedBox(width: 9),
          Text(
              questions.isEmpty
                  ? 'Write a question'
                  : TtcS.current().appointmentsAddQuestion,
              style: pvManrope(
                  fontSize: 14, fontWeight: FontWeight.w800, color: p.ink1)),
        ]),
      ),
    );
    return _RowGroup(p: p, children: [
      for (final q in questions)
        InkWell(
          // ⚠️ A QUESTION OPENS (tool rebuild, 2026-09-27). It was a line of
          // text with a purple dot and no way to change or remove it once
          // the visit had answered it.
          onTap: () => openTtcJournalEntry(context, q),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 13, 10, 13),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(Icons.help_outline_rounded,
                    size: 17, color: p.ink3),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(q.text,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: pvManrope(
                        fontSize: 14, height: 1.5, color: p.ink1)),
              ),
              Icon(Icons.chevron_right_rounded, size: 19, color: p.ink3),
            ]),
          ),
        ),
      add,
    ]);
  }
}

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
        TtcJournalStore.instance,
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
        final questions = TtcJournalStore.instance.doctorQuestions;

        return TtcToolScaffold(
          hue: kIvfHue,
          variant: 1,
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
                        label: 'Where it came from',
                        value: 'Booked in ParentVeda. It can\'t be changed '
                            'here.')
                  else ...[
                    _InfoRow(
                        p: p,
                        icon: Icons.person_outline_rounded,
                        label: 'Who with',
                        value: a.withWhom,
                        addLabel: 'Add who it\'s with',
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
                      sub: 'At 7 pm on ${ttcApptDay(a.reminderAt)}.',
                      onChanged: (v) {
                        TtcAppointmentsStore.instance
                            .update(a.copyWith(remindEveningBefore: v));
                        if (v) _askPhonePermission();
                      },
                    ),
                  ]),
                ],

                if (upcoming) ...[
                  const SizedBox(height: 26),
                  Text('Questions to take',
                      style: pvJakarta(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: p.ink1)),
                  const SizedBox(height: 5),
                  Text(
                      questions.isEmpty
                          ? 'Write them down when you think of them, so '
                              'nothing is forgotten in the room.'
                          : 'Everything you saved for the doctor. Tap one to '
                              'change it or remove it once it\'s answered.',
                      style: pvManrope(
                          fontSize: 13, height: 1.5, color: p.ink3)),
                  const SizedBox(height: 12),
                  TtcApptQuestions(p: p, questions: questions),
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

/// "Remind me the evening before", with when it will ring said under it.
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
                  Text('Remind me the evening before',
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
    pvSnack(context, e == null ? 'Added to your appointments.' : 'Changes saved.',
        icon: Icons.check_rounded, lift: 24);
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
        title: Text(_editing ? 'Leave without saving?' : 'Discard this?',
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
                title: 'What is it?',
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
                  sub: 'Your phone will remind you at 7 pm the day before.',
                  onChanged: (v) {
                    setState(() => _remind = v);
                    if (v) _askPhonePermission();
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
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: ttcTitleInk, width: 1.5),
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
                  color: ttcPurple,
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
            if (own != null && own.remindEveningBefore && !faded) ...[
              const SizedBox(height: 6),
              Row(children: [
                const Icon(Icons.notifications_none_rounded,
                    size: 14, color: ttcPurple),
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
                    style: ttcBody(9.5, color: ttcPurple, w: FontWeight.w800)),
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
                            size: 16, color: ttcPurple),
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
                                color: ttcPurple, w: FontWeight.w800)),
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
                              color: ttcPanel,
                              borderRadius: BorderRadius.circular(16)),
                          child: Text(t.journalCancel,
                              style: ttcBody(14,
                                  color: ttcSoft, w: FontWeight.w800)),
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
                              color: ttcPurple,
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
          borderSide: const BorderSide(color: ttcPurple, width: 1.4),
        ),
      ),
    );
*/
