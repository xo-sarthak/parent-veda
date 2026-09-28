// =============================================================================
//  TTC Medication - what she is actually taking
// -----------------------------------------------------------------------------
//  The gap this closes (A-42) was the widest in the stage, and it sat directly
//  under the most careful thinking in it.
//
//  The whole care-pathway design turns on one question: HAS MEDICATION TAKEN
//  OVER WHEN OVULATION HAPPENS? We ask her that, in those words, and the answer
//  decides whether we predict a fertile window or defer to her clinic. Then the
//  "Medication" tile in Tools opened a curated supplement list with `+` buttons
//  and no text field anywhere. She could add *folic acid, from our list*. She
//  could not write down *Letrozole 2.5mg, days 3 to 7*.
//
//  A woman on a stimulation protocol carries four drugs on a schedule, and the
//  app that had just asked her about her medication could hold none of them.
//
//  ---------------------------------------------------------------------------
//  Why this uses MedicineStore rather than a new TTC store
//
//  `MedicineStore` lives in `lib/services/`, not in a stage folder, because a
//  medication is not a pregnancy concept or a TTC concept - it is a fact about a
//  person. It already has the model (name, dose, frequency, notes, start/end),
//  per-day "taken" logs, and real OS alarms with times, weekdays and windows.
//  Its tables already exist.
//
//  So this screen adds **no store, no table and no SQL**. It is a TTC-skinned
//  door onto infrastructure the app already had - which is the same lesson the
//  partner header taught an hour ago: a private copy of a shared thing looks
//  harmless and then silently stops receiving everything the shared one gets.
//
//  Local-first falls out for free. Every cloud call in `MedicineStore` is gated
//  on `SupabaseRepo.isLoggedIn`, so signed out it is a purely local record and
//  behaves identically. Nothing here needs a backend to work.
//
//  ---------------------------------------------------------------------------
//  What it deliberately does NOT do
//
//  It does not interpret. No dose checking, no interaction warnings, no "you
//  missed one" scolding, and no inference from a drug name to a diagnosis -
//  seeing "Letrozole" does not let us decide she has PCOS. We hold what she
//  tells us and we remind her when she asks to be reminded. Her clinician owns
//  everything else, and `TruthSource.verifiedMedication` sits above our own
//  calculation precisely so a schedule she reports outranks anything we derive.
//
//  ---------------------------------------------------------------------------
//  ⚠️ REBUILT 2026-09-27 (tool rebuild, night), out of the same parts as
//  Supplements (`ttc_dose_parts.dart`) so the two neighbouring tiles look and
//  behave as one. The user: "old tools in new clothes... poor functionality".
//  What changed, and the screens that decided it:
//
//    · A short course never ended on screen. The reminders stopped after the
//      last day, but the medicine sat on today's list for ever with a tick
//      nobody would use. Now a course past its last day moves to "Finished
//      courses" (nothing deleted), and the last day can be set with or without
//      reminders. Hims and Hers keep the schedule in the reminder's own sheet
//      (mobbin.com/screens/164de70f-f4dd-4b24-88b0-394b5c4acc88).
//    · A tick could only be today's. A seven-day strip now picks the day, the
//      way Apple Health Medications does
//      (mobbin.com/screens/19cc770b-a386-48a5-9d6b-7a46a8c98685), through the
//      additive `MedicineStore.toggleOn`.
//    · A tap on a medicine opened the edit form, so there was nowhere to see
//      it: no history, no plain statement of when it reminds her. Now the name
//      opens its page (today's tick, reminders in words, notes, four weeks she
//      can correct, change, remove), the shape of Apple Health's medication
//      detail (mobbin.com/flows/61a17fd3-3918-40b6-bfcb-6b12927d5244).
//    · Adding a time meant a clock face every time. Three common times sit
//      under the field to tap, and the clock is still there for any other
//      (Noom "Meal Reminders", mobbin.com/screens/0e473178-bb2b-4247-bb4f-41a7e514a8d8).
//    · The same medicine could be added twice without a word. The first Save
//      now says it is already there; a second Save keeps both, because a
//      clinic can prescribe one drug at two doses.
//    · What to Expect opens its medicine log with one read; the "Medicines and
//      conditions to check with a doctor" read now sits under the list.
//
//  The screen as it was is kept, commented, at the foot of this file.
// =============================================================================

import 'package:flutter/material.dart';

import '../../models/medication.dart';
import '../../services/medicine_store.dart';
import '../../theme/pv_fonts.dart';
import '../products/pv_store_chrome.dart' show pvSnack;
import '../v2/v2_palette.dart';
import 'ttc_common.dart' show ttcTitleInk;
import 'ttc_dose_parts.dart';
import 'ttc_ivf_readiness_screen.dart' show kIvfHue;
import 'ttc_strings.dart';
import 'ttc_supplements_screen.dart';
import 'ttc_surface_router.dart' show openTtcSurface, kTtcReadPrefix;
import 'ttc_tool_chrome.dart';
import 'ttc_tool_confirm.dart';

/// The read that sits under the list.
const String kTtcMedicationRead = 'ttc_read_meds_and_conditions';

void openTtcMedication(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute<void>(
    builder: (_) => const TtcMedicationScreen(),
    settings: const RouteSettings(name: 'ttc/medication'),
  ));
}

/// The last day she gave a medicine: the reminders' end, or the medicine's
/// own end date when it has no reminders. Null means no end.
DateTime? ttcMedLastDay(Medication m) {
  for (final a in m.alarms) {
    final d = DateTime.tryParse(a.endDateIso ?? '');
    if (d != null) return ttcDoseDay(d);
  }
  final d = DateTime.tryParse(m.endDateIso ?? '');
  return d == null ? null : ttcDoseDay(d);
}

/// True once the day after its last day has begun. It still counts as
/// today's on the last day itself.
bool ttcMedFinished(Medication m, {DateTime? now}) {
  final last = ttcMedLastDay(m);
  if (last == null) return false;
  return ttcDoseDay(now ?? DateTime.now()).isAfter(last);
}

/// Every reminder time on a medicine, sorted, as minutes since midnight.
List<int> ttcMedTimes(Medication m) => m.alarms
    .where((a) => a.enabled)
    .expand((a) => a.times)
    .toSet()
    .toList()
  ..sort();

/// "8:00 am and 9:00 pm".
String _joinTimes(List<int> times) {
  final s = times.map(ttcDoseTime).toList();
  if (s.length <= 1) return s.join();
  return '${s.sublist(0, s.length - 1).join(', ')} and ${s.last}';
}

// ⚠️ A DOSE SAYS WHAT IT COUNTS (launch sanity T12, 2026-09-28). The walk
// found "DHA · 3 · twice": a dose saved as a bare number reads as "3 twice",
// and she cannot tell three what. The dose stays one free-text field in
// `MedicineStore` (shared with pregnancy, so its shape does not move); what
// changed is that a bare number is noticed. The sheet offers the unit as one
// tap (tablets, mg, ml) under the field and asks once before saving a number
// on its own, and a bare number already saved reads "Dose 3" rather than a
// lone digit beside the frequency. Mobbin: an amount always travels with its
// unit, as in Noom's glucose log (82 | mg/dL,
// https://mobbin.com/screens/be69b417-b70a-4648-9963-2e77552218e9) and
// MacroFactor's portion (unit chips over the amount,
// https://mobbin.com/screens/498fce5f-7b08-4bf7-80d4-9d629e2f1351).
final RegExp _kTtcBareDose = RegExp(r'^\d+([.,]\d+)?$');

/// True when [dose] is only a number, with nothing saying what it counts.
bool ttcDoseIsBare(String dose) => _kTtcBareDose.hasMatch(dose.trim());

/// The units offered when a dose is a bare number.
const List<String> kTtcDoseUnits = ['tablets', 'mg', 'ml'];

/// [n] with [unit]: "1 tablet", "2 tablets", "500 mg".
String ttcDoseWithUnit(String n, String unit) {
  final v = n.trim();
  final one = v == '1' || v == '1.0';
  return '$v ${unit == 'tablets' && one ? 'tablet' : unit}';
}

/// How a saved dose is said on the list and the page: a bare number reads
/// "Dose 3", never a lone digit.
String ttcDoseShown(String dose) =>
    ttcDoseIsBare(dose) ? 'Dose ${dose.trim()}' : dose.trim();

class TtcMedicationScreen extends StatefulWidget {
  const TtcMedicationScreen({super.key});

  @override
  State<TtcMedicationScreen> createState() => _TtcMedicationScreenState();
}

class _TtcMedicationScreenState extends State<TtcMedicationScreen> {
  DateTime _day = ttcDoseDay(DateTime.now());

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([MedicineStore.instance, TtcLang.instance]),
      builder: (context, _) {
        final t = TtcS.current();
        final p = V2PaletteStore.instance.current;
        final store = MedicineStore.instance;
        final meds = store.activeMeds;
        final current = meds.where((m) => !ttcMedFinished(m)).toList()
          // In the order of the day: the earliest reminder first, and the
          // ones with no time after them, in the order they were added.
          ..sort((a, b) {
            final ta = ttcMedTimes(a), tb = ttcMedTimes(b);
            if (ta.isEmpty && tb.isEmpty) return 0;
            if (ta.isEmpty) return 1;
            if (tb.isEmpty) return -1;
            return ta.first.compareTo(tb.first);
          });
        final finished = meds.where(ttcMedFinished).toList();
        final isToday = ttcDoseSameDay(_day, DateTime.now());
        String key(DateTime d) => MedicineStore.dateKey(d);

        return TtcToolScaffold(
          hue: kIvfHue,
          // ⚠️ ONE TOOL, ONE NAME (2026-09-27): the Tools tile's name, word
          // for word. Kept for revert: eyebrow: t.medTitle ("Your medication").
          eyebrow: t.hinglish ? 'Dawaiyan' : 'Medication',
          title: 'What to take, and when.',
          // ⚠️ SAY WHAT THIS IS, FIRST, and what each tap does once there is
          // a list. Kept for revert:
          // intro: 'Write down the medicines your clinic gave you. Tap the '
          //     "circle on the days you take one. Add a time if you'd like a "
          //     'reminder.',
          intro: meds.isEmpty
              ? 'Write down the medicines your clinic gave you. Add a time '
                  "if you'd like your phone to remind you."
              : 'Tap the circle when you take one. Tap the name to see its '
                  'days and reminders, change it or remove it.',
          // The same "Add" Records, Appointments and Supplements wear.
          //
          // Kept for revert (2026-09-27): "NO `action` HERE" — the add lived
          // beside the "Today" title as a quiet link. Every list tool now
          // carries its add in the same corner, so it is found in one place.
          action: TtcDoseHeroAdd(onTap: () => editTtcMedication(context, null)),
          children: [
            ttcToolPad(Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 22),

                // A feature is never hidden: the empty state is an invitation,
                // and it says what this is FOR rather than that it is empty.
                if (meds.isEmpty)
                  TtcDoseEmpty(
                    icon: Icons.medication_outlined,
                    title: t.medEmptyTitle,
                    body: t.medEmptyBody,
                    cta: t.medAdd,
                    onTap: () => editTtcMedication(context, null),
                  )
                else ...[
                  if (current.isNotEmpty) ...[
                    TtcDayStrip(
                      selected: _day,
                      onPick: (d) => setState(() => _day = d),
                      anyTakenOn: (d) =>
                          current.any((m) => store.isTakenOn(m.id, key(d))),
                    ),
                    const SizedBox(height: 16),
                    Text.rich(
                      key: const ValueKey('ttc_med_count'),
                      TextSpan(children: [
                        TextSpan(
                            text: ttcDoseDayName(_day),
                            style: pvManrope(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: p.ink1)),
                        TextSpan(
                            text: '  ·  ${current.where((m) => store.isTakenOn(m.id, key(_day))).length}'
                                ' of ${current.length} taken',
                            style: pvManrope(fontSize: 13.5, color: p.ink2)),
                      ]),
                    ),
                    if (!isToday) ...[
                      const SizedBox(height: 4),
                      Text('Tick what you took that day.',
                          style: pvManrope(fontSize: 12.5, color: p.ink2)),
                    ],
                    const SizedBox(height: 14),
                    TtcDoseGroup(children: [
                      for (final m in current)
                        TtcDoseRow(
                          name: m.name,
                          // T12: a bare number says it is a dose.
                          // Kept for revert (2026-09-28): [m.dose, ...].
                          detail: [ttcDoseShown(m.dose), m.frequency]
                              .where((s) => s.trim().isNotEmpty)
                              .join(' · '),
                          note: _reminderLine(m),
                          taken: store.isTakenOn(m.id, key(_day)),
                          onTick: () => store.toggleOn(m.id, _day),
                          onOpen: () => openTtcMedicine(context, m.id),
                        ),
                    ]),
                  ] else
                    Text(
                        "Nothing on today's list. Your finished courses are "
                        'below.',
                        style: pvManrope(
                            fontSize: 13.5, height: 1.5, color: p.ink2)),

                  if (finished.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    TtcDoseGroup(
                      label: 'Finished courses',
                      children: [
                        for (final m in finished)
                          TtcDoseRow(
                            name: m.name,
                            // T12. Kept for revert (2026-09-28): m.dose.
                            detail: ttcDoseShown(m.dose),
                            note: 'Last day was '
                                '${ttcDoseShortDate(ttcMedLastDay(m)!)}',
                            onOpen: () => openTtcMedicine(context, m.id),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                        "Their last day has passed, so they're off today's "
                        'list. Nothing is deleted. Open one to take it again.',
                        style: pvManrope(
                            fontSize: 12, height: 1.5, color: p.ink3)),
                  ],
                ],

                const SizedBox(height: 22),
                TtcDoseLinkRow(
                  key: const ValueKey('ttc_med_read'),
                  icon: Icons.menu_book_outlined,
                  eyebrow: 'Read',
                  text: 'Medicines and conditions to check with a doctor',
                  onTap: () => openTtcSurface(
                      context, '$kTtcReadPrefix$kTtcMedicationRead'),
                ),
                const SizedBox(height: 12),
                // ⚠️ ONE PLAIN LINE ON THE DIFFERENCE (tools pass): two tiles,
                // Supplements and Medication, sit side by side in Tools, and
                // nothing said which one folic acid goes in.
                TtcDoseLinkRow(
                  icon: Icons.eco_outlined,
                  text: 'Vitamins you chose yourself, like folic acid? '
                      'Those go in Supplements.',
                  onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                          builder: (_) => const TtcSupplementsScreen(),
                          settings:
                              const RouteSettings(name: 'ttc/supplements'))),
                ),
                const SizedBox(height: 16),
                // The one no-advice line, said once, at the foot.
                Text(t.medNoAdvice,
                    style:
                        pvManrope(fontSize: 11.5, height: 1.5, color: p.ink3)),
                // ⚠️ SAID ONCE (2026-09-27): the old intro card printed this
                // same sentence a second time, and the estimates footer is
                // about cycle dates, not a medicines list. Kept for revert:
                // TtcDisclaimer(t: t),
                const SizedBox(height: 26),
              ],
            )),
          ],
        );
      },
    );
  }

  /// "Reminds you at 8:00 am · until Wed 1 Oct", or nothing.
  static String _reminderLine(Medication m) {
    final times = ttcMedTimes(m);
    if (times.isEmpty) return '';
    final last = ttcMedLastDay(m);
    return 'Reminds you at ${_joinTimes(times)}'
        '${last == null ? '' : ' · until ${ttcDoseShortDate(last)}'}';
  }
}

// =============================================================================
//  One medicine's own page
// =============================================================================

void openTtcMedicine(BuildContext context, String id) {
  Navigator.of(context).push(MaterialPageRoute<void>(
    builder: (_) => TtcMedicineDetailScreen(id: id),
    settings: const RouteSettings(name: 'ttc/medicine'),
  ));
}

class TtcMedicineDetailScreen extends StatefulWidget {
  const TtcMedicineDetailScreen({super.key, required this.id});

  final String id;

  @override
  State<TtcMedicineDetailScreen> createState() =>
      _TtcMedicineDetailScreenState();
}

class _TtcMedicineDetailScreenState extends State<TtcMedicineDetailScreen> {
  /// Last seen, so the page does not flash empty while it slides away.
  Medication? _last;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: MedicineStore.instance,
      builder: (context, _) {
        final t = TtcS.current();
        final p = V2PaletteStore.instance.current;
        final store = MedicineStore.instance;
        final m =
            store.all.where((x) => x.id == widget.id).firstOrNull ?? _last;
        _last = m;
        final eyebrow = t.hinglish ? 'Dawaiyan' : 'Medication';
        if (m == null) {
          return TtcToolScaffold(
            hue: kIvfHue,
            eyebrow: eyebrow,
            title: 'Not on the list any more.',
            intro: 'It was removed. Close this to go back to the list.',
            children: const [SizedBox(height: 40)],
          );
        }
        final finished = ttcMedFinished(m);
        final last = ttcMedLastDay(m);
        final times = ttcMedTimes(m);
        // T12. Kept for revert (2026-09-28): [m.dose, m.frequency].
        final what = [ttcDoseShown(m.dose), m.frequency]
            .where((s) => s.trim().isNotEmpty)
            .join(' · ');

        final String reminders;
        if (times.isEmpty) {
          reminders = 'No reminders. Change this to add a time, and your '
              'phone will remind you.';
        } else if (finished) {
          reminders = 'Reminders stopped after ${ttcDoseShortDate(last!)}.';
        } else {
          reminders = 'Your phone reminds you at ${_joinTimes(times)}, every '
              'day${last == null ? '' : ' until ${ttcDoseShortDate(last)}'}.';
        }

        return TtcToolScaffold(
          hue: kIvfHue,
          eyebrow: eyebrow,
          title: m.name,
          intro: what.isEmpty ? 'No dose written down yet.' : what,
          variant: 3,
          children: [
            ttcToolPad(Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 22),
                if (finished) ...[
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: p.line),
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              'Its last day was ${ttcDoseShortDate(last!)}, '
                              "so it's off today's list. Its days are kept "
                              'below.',
                              style: pvManrope(
                                  fontSize: 13.5,
                                  height: 1.5,
                                  color: p.ink1)),
                          const SizedBox(height: 12),
                          TtcDoseInkButton(
                            key: const ValueKey('ttc_med_again'),
                            label: 'Take it again',
                            icon: Icons.replay_rounded,
                            onTap: () => editTtcMedication(context, m,
                                again: true),
                          ),
                        ]),
                  ),
                ] else
                  TtcDoseTodayButton(
                    taken: store.isTakenToday(m.id),
                    onTap: () => store.toggleOn(m.id, DateTime.now()),
                  ),
                const SizedBox(height: 26),
                ttcDoseHeading(t.medReminders),
                Text(reminders,
                    key: const ValueKey('ttc_med_reminders'),
                    style: pvManrope(
                        fontSize: 13.5, height: 1.55, color: p.ink1)),
                if (m.notes.trim().isNotEmpty) ...[
                  const SizedBox(height: 22),
                  ttcDoseHeading(t.medNotes),
                  Text(m.notes,
                      style: pvManrope(
                          fontSize: 13.5, height: 1.55, color: p.ink1)),
                ],
                const SizedBox(height: 26),
                ttcDoseHeading('The last four weeks'),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                      'Each filled circle is a day you ticked it. Tap a day '
                      'to add or clear it.',
                      style: pvManrope(
                          fontSize: 12.5, height: 1.5, color: p.ink2)),
                ),
                TtcDoseHistory(
                  takenOn: (d) =>
                      store.isTakenOn(m.id, MedicineStore.dateKey(d)),
                  onToggle: (d) => store.toggleOn(m.id, d),
                ),
                const SizedBox(height: 26),
                TtcDoseLinkRow(
                  key: const ValueKey('ttc_med_change'),
                  icon: Icons.edit_outlined,
                  text: 'Change the details or reminders',
                  onTap: () => editTtcMedication(context, m),
                ),
                const SizedBox(height: 14),
                TtcDoseRemoveLine(
                  label: t.medDelete,
                  onTap: () => _remove(context, m),
                ),
                const SizedBox(height: 26),
              ],
            )),
          ],
        );
      },
    );
  }

  Future<void> _remove(BuildContext context, Medication m) async {
    final nav = Navigator.of(context);
    // ⚠️ ASKED FIRST (tools pass): removing a medicine also removes every day
    // she ticked it and its reminders, in one tap, with no way back.
    final ok = await ttcConfirmRemove(context,
        title: 'Remove ${m.name}?',
        body: 'Its reminders stop, and the days you ticked it go too.');
    if (!ok || !context.mounted) return;
    pvSnack(context, '${m.name} removed', lift: 24);
    // Not awaited: the list changes at once, and the alarm cancel behind it
    // is a platform call the page need not wait for.
    MedicineStore.instance.deleteMed(m.id);
    nav.maybePop();
  }
}

// =============================================================================
//  Add or change - one sheet
// =============================================================================

/// Opens the add sheet (null) or the change sheet. [again] opens a finished
/// course with its last day cleared, ready to take again.
Future<void> editTtcMedication(BuildContext context, Medication? existing,
        {bool again = false}) =>
    showTtcDoseSheet<void>(
      context,
      routeName: 'ttc/medication_edit',
      builder: (_) =>
          _MedSheet(t: TtcS.current(), existing: existing, again: again),
    );

class _MedSheet extends StatefulWidget {
  const _MedSheet({required this.t, this.existing, this.again = false});

  final TtcS t;
  final Medication? existing;
  final bool again;

  @override
  State<_MedSheet> createState() => _MedSheetState();
}

class _MedSheetState extends State<_MedSheet> {
  late final TextEditingController _name;
  late final TextEditingController _dose;
  late final TextEditingController _freq;
  late final TextEditingController _notes;

  /// Minutes since midnight. Empty means "no reminder", which is a real choice
  /// and the default - a medication she takes at the clinic does not need one.
  late List<int> _times;
  late final List<int> _startTimes;

  /// The last day she takes it. Null means every day until she removes it.
  ///
  /// ⚠️ WHY THIS EXISTS: "When" is free text ("Days 3 to 7"), but reminders
  /// were daily for ever, so a five-day course kept ringing on day 8 and every
  /// day after. `MedAlarm` already carried an `endDateIso` and
  /// `NotificationService` already stops materialising alarms after it. Since
  /// the rebuild it is asked with or without reminders, because it also moves
  /// the medicine to "Finished courses" once it has passed.
  DateTime? _lastDay;
  DateTime? _startLastDay;

  /// Set when she taps Save with no name, so the reason shows under the
  /// button instead of the tap doing nothing.
  bool _needsName = false;

  /// Set on the first Save of a name already on the list. A second Save keeps
  /// both: a clinic can prescribe one drug at two doses.
  bool _dupeWarned = false;

  /// Set on the first Save of a dose that is only a number (T12): the sheet
  /// asks what it counts once, and a second Save keeps the number as it is.
  bool _unitAsked = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.name ?? '');
    _dose = TextEditingController(text: e?.dose ?? '');
    _freq = TextEditingController(text: e?.frequency ?? '');
    _notes = TextEditingController(text: e?.notes ?? '');
    _times = e == null ? <int>[] : ttcMedTimes(e);
    _startTimes = [..._times];
    _startLastDay = e == null ? null : ttcMedLastDay(e);
    // "Take it again" opens with the old last day gone, and says so.
    _lastDay = widget.again ? null : _startLastDay;
  }

  @override
  void dispose() {
    _name.dispose();
    _dose.dispose();
    _freq.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    final p = V2PaletteStore.instance.current;
    final editing = widget.existing != null;
    return TtcDoseSheet(
      eyebrow: t.hinglish ? 'Dawaiyan' : 'Medication',
      title: widget.again
          ? 'Take it again'
          : editing
              ? 'Change this medicine'
              : 'Add a medicine',
      children: [
        TtcDoseField(
            label: t.medName,
            controller: _name,
            hint: t.medNameHint,
            autofocus: !editing,
            onChanged: (_) {
              if (_needsName || _dupeWarned) {
                setState(() {
                  _needsName = false;
                  _dupeWarned = false;
                });
              }
            }),
        // Kept for revert (2026-09-28): the dose field with no onChanged.
        TtcDoseField(
            label: t.medDose,
            controller: _dose,
            hint: t.medDoseHint,
            onChanged: (_) => setState(() => _unitAsked = false)),
        // ⚠️ T12: a bare number gets its unit as one tap, right under it.
        if (ttcDoseIsBare(_dose.text)) ...[
          Transform.translate(
            offset: const Offset(0, -6),
            child: Text('${_dose.text.trim()} what?',
                style: pvManrope(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: p.ink2)),
          ),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final u in kTtcDoseUnits)
              _Pill(
                key: ValueKey('ttc_med_unit_$u'),
                label: u,
                icon: Icons.add_rounded,
                on: false,
                semantics: 'The dose is ${ttcDoseWithUnit(_dose.text, u)}',
                onTap: () => setState(() {
                  _dose.text = ttcDoseWithUnit(_dose.text, u);
                  _unitAsked = false;
                }),
              ),
          ]),
          const SizedBox(height: 14),
        ],
        TtcDoseField(
            label: t.medFrequency, controller: _freq, hint: t.medFrequencyHint),
        TtcDoseField(
            label: t.medNotes, controller: _notes, hint: t.medNotesHint, lines: 3),

        // ---- reminders --------------------------------------------------
        const SizedBox(height: 4),
        ttcDoseLabel(t.medReminders),
        Text(t.medRemindersNote,
            style: pvManrope(fontSize: 12.5, height: 1.5, color: p.ink2)),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final m in _times)
            _Pill(
              key: ValueKey('ttc_med_time_$m'),
              label: ttcDoseTime(m),
              icon: Icons.close_rounded,
              on: true,
              semantics: 'Remove the ${ttcDoseTime(m)} reminder',
              onTap: () => setState(() => _times = [..._times]..remove(m)),
            ),
          // Three common times, one tap each, until she has one.
          if (_times.isEmpty)
            for (final m in const [480, 840, 1260])
              _Pill(
                key: ValueKey('ttc_med_quick_$m'),
                label: ttcDoseTime(m),
                icon: Icons.add_rounded,
                on: false,
                semantics: 'Remind me at ${ttcDoseTime(m)}',
                onTap: () => setState(() => _times = [m]),
              ),
          _Pill(
            key: const ValueKey('ttc_med_add_time'),
            label: _times.isEmpty ? 'Another time' : t.medAddTime,
            icon: Icons.schedule_rounded,
            on: false,
            semantics: t.medAddTime,
            onTap: _addTime,
          ),
        ]),

        // ---- the last day ----------------------------------------------
        const SizedBox(height: 18),
        ttcDoseLabel('Last day (optional)'),
        Text(
            'For a short course. After this day the reminders stop and it '
            'moves to Finished courses.',
            style: pvManrope(fontSize: 12.5, height: 1.5, color: p.ink2)),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
            child: InkWell(
              key: const ValueKey('ttc_med_last_day'),
              onTap: _pickLastDay,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: p.line),
                ),
                child: Row(children: [
                  Icon(Icons.event_outlined, size: 16, color: p.ink2),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                        _lastDay == null
                            ? 'Every day, no end date'
                            : 'Until ${ttcDoseShortDate(_lastDay!)} '
                                '${_lastDay!.year}',
                        style: pvManrope(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: p.ink1)),
                  ),
                  Text(_lastDay == null ? 'Set' : 'Change',
                      style: pvManrope(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: p.ink1)),
                ]),
              ),
            ),
          ),
          if (_lastDay != null) ...[
            const SizedBox(width: 6),
            TextButton(
              onPressed: () => setState(() => _lastDay = null),
              child: Text('No end',
                  style: pvManrope(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: p.ink2)),
            ),
          ],
        ]),
        const SizedBox(height: 22),

        TtcToolPrimary(
            key: const ValueKey('ttc_med_save'), label: t.medSave, onTap: _save),
        if (_needsName) const TtcFormHint(text: 'Add a name to save.'),
        if (_unitAsked && ttcDoseIsBare(_dose.text))
          TtcFormHint(
              text: 'The dose says ${_dose.text.trim()}. Pick tablets, mg or '
                  'ml under it, or Save again to keep just the number.'),
        if (_dupeWarned)
          TtcFormHint(
              text: '${_name.text.trim()} is already on your list. Save '
                  'again to keep both, or close this and open the one you '
                  'have.'),
      ],
    );
  }

  Future<void> _addTime() async {
    final picked = await showTimePicker(
      context: context,
      helpText: 'Remind me at',
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    // A closed clock adds nothing: no silent default.
    if (picked == null || !mounted) return;
    final m = picked.hour * 60 + picked.minute;
    if (_times.contains(m)) return;
    setState(() => _times = [..._times, m]..sort());
  }

  Future<void> _pickLastDay() async {
    final today = ttcDoseDay(DateTime.now());
    // Up to three months back, so "I stopped it on Monday" can be said too;
    // a day in the past moves it straight to Finished courses.
    final first = today.subtract(const Duration(days: 90));
    final picked = await showDatePicker(
      context: context,
      helpText: 'Last day you take it',
      initialDate: _lastDay != null && !_lastDay!.isBefore(first)
          ? _lastDay!
          : today,
      firstDate: first,
      lastDate: today.add(const Duration(days: 365)),
    );
    // A closed picker changes nothing: no silent default.
    if (picked == null || !mounted) return;
    setState(() => _lastDay = picked);
  }

  bool _sameTimes(List<int> a, List<int> b) =>
      a.length == b.length && [for (var i = 0; i < a.length; i++) a[i] == b[i]]
          .every((x) => x);

  Future<void> _save() async {
    final name = _name.text.trim();
    // Kept for revert (2026-09-27): `if (name.isEmpty) return;` ignored the
    // tap without a word, which reads as a broken button.
    if (name.isEmpty) {
      setState(() => _needsName = true);
      return;
    }
    // T12: a dose that is only a number is asked about once.
    if (ttcDoseIsBare(_dose.text) && !_unitAsked) {
      setState(() => _unitAsked = true);
      return;
    }
    final nav = Navigator.of(context);
    final store = MedicineStore.instance;
    final existing = widget.existing;

    if (existing == null && !_dupeWarned) {
      final lower = name.toLowerCase();
      if (store.activeMeds.any((m) => m.name.trim().toLowerCase() == lower)) {
        setState(() => _dupeWarned = true);
        return;
      }
    }

    final lastIso = _lastDay?.toIso8601String();

    // ⚠️ AN UNTOUCHED SCHEDULE IS KEPT AS IT WAS. `MedicineStore` is shared
    // with pregnancy, whose tracker can hold weekday alarms and several
    // configs. This sheet writes one daily alarm, so it only rewrites the
    // alarms when she changed the times or the last day here.
    final unchanged = existing != null &&
        _sameTimes(_times, _startTimes) &&
        _lastDay == _startLastDay;
    final alarms = unchanged
        ? existing.alarms
        : _times.isEmpty
            ? const <MedAlarm>[]
            : [
                // One alarm config carrying every chosen time: a thrice-daily
                // medication is one alarm, not three.
                MedAlarm(
                  id: existing?.alarms.isNotEmpty == true
                      ? existing!.alarms.first.id
                      : 'ttcma_${DateTime.now().microsecondsSinceEpoch}',
                  times: _times,
                  repeat: MedAlarmRepeat.daily,
                  // `NotificationService` compares by day, so the medicine
                  // still rings on its last day and not after.
                  endDateIso: lastIso,
                ),
              ];

    if (existing == null) {
      // Not awaited past the list change: the alarms behind it are a
      // platform call, and the sheet closes on the saved list.
      store.addMed(Medication(
        id: 'ttcm_${DateTime.now().microsecondsSinceEpoch}',
        name: name,
        // `medication`, not `supplement`: this screen exists for the things a
        // clinic prescribed, and the distinction is what the care pathway
        // reasons about.
        type: MedType.medication,
        dose: _dose.text.trim(),
        frequency: _freq.text.trim(),
        notes: _notes.text.trim(),
        startDateIso: DateTime.now().toIso8601String(),
        endDateIso: lastIso,
        alarms: alarms,
      ));
      pvSnack(context, '$name added', icon: Icons.check_rounded, lift: 24);
    } else {
      // Built in full rather than with `copyWith`, which cannot clear an end
      // date: "No end" has to be able to take one away.
      store.updateMed(Medication(
        id: existing.id,
        name: name,
        type: existing.type,
        dose: _dose.text.trim(),
        time: existing.time,
        frequency: _freq.text.trim(),
        notes: _notes.text.trim(),
        presetKey: existing.presetKey,
        startDateIso: existing.startDateIso,
        endDateIso: lastIso,
        isActive: existing.isActive,
        alarms: alarms,
      ));
      if (widget.again) {
        pvSnack(context, "$name is back on today's list",
            icon: Icons.check_rounded, lift: 24);
      }
    }
    nav.pop();
  }
}

/// A reminder time, or a time to add. Ink when it is set.
class _Pill extends StatelessWidget {
  const _Pill({
    super.key,
    required this.label,
    required this.icon,
    required this.on,
    required this.onTap,
    required this.semantics,
  });

  final String label;
  final IconData icon;
  final bool on;
  final VoidCallback onTap;
  final String semantics;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return Semantics(
      button: true,
      label: semantics,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
          decoration: BoxDecoration(
            color: on ? ttcTitleInk : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: on ? ttcTitleInk : p.line),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (!on) ...[
              Icon(icon, size: 15, color: p.ink1),
              const SizedBox(width: 5),
            ],
            Text(label,
                style: pvManrope(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: on ? Colors.white : p.ink1)),
            if (on) ...[
              const SizedBox(width: 6),
              Icon(icon, size: 14, color: Colors.white),
            ],
          ]),
        ),
      ),
    );
  }
}

// =============================================================================
//  Kept for revert (2026-09-27, tool rebuild): the whole medication screen
//  as it was before the rebuild, every line commented.
// =============================================================================
// // =============================================================================
// //  TTC Medication - what she is actually taking
// // -----------------------------------------------------------------------------
// //  The gap this closes (A-42) was the widest in the stage, and it sat directly
// //  under the most careful thinking in it.
// //
// //  The whole care-pathway design turns on one question: HAS MEDICATION TAKEN
// //  OVER WHEN OVULATION HAPPENS? We ask her that, in those words, and the answer
// //  decides whether we predict a fertile window or defer to her clinic. Then the
// //  "Medication" tile in Tools opened a curated supplement list with `+` buttons
// //  and no text field anywhere. She could add *folic acid, from our list*. She
// //  could not write down *Letrozole 2.5mg, days 3 to 7*.
// //
// //  A woman on a stimulation protocol carries four drugs on a schedule, and the
// //  app that had just asked her about her medication could hold none of them.
// //
// //  ---------------------------------------------------------------------------
// //  Why this uses MedicineStore rather than a new TTC store
// //
// //  `MedicineStore` lives in `lib/services/`, not in a stage folder, because a
// //  medication is not a pregnancy concept or a TTC concept - it is a fact about a
// //  person. It already has the model (name, dose, frequency, notes, start/end),
// //  per-day "taken" logs, and real OS alarms with times, weekdays and windows.
// //  Its tables already exist.
// //
// //  So this screen adds **no store, no table and no SQL**. It is a TTC-skinned
// //  door onto infrastructure the app already had - which is the same lesson the
// //  partner header taught an hour ago: a private copy of a shared thing looks
// //  harmless and then silently stops receiving everything the shared one gets.
// //
// //  Local-first falls out for free. Every cloud call in `MedicineStore` is gated
// //  on `SupabaseRepo.isLoggedIn`, so signed out it is a purely local record and
// //  behaves identically. Nothing here needs a backend to work.
// //
// //  ---------------------------------------------------------------------------
// //  What it deliberately does NOT do
// //
// //  It does not interpret. No dose checking, no interaction warnings, no "you
// //  missed one" scolding, and no inference from a drug name to a diagnosis -
// //  seeing "Letrozole" does not let us decide she has PCOS. We hold what she
// //  tells us and we remind her when she asks to be reminded. Her clinician owns
// //  everything else, and `TruthSource.verifiedMedication` sits above our own
// //  calculation precisely so a schedule she reports outranks anything we derive.
// // =============================================================================
//
// import 'package:flutter/material.dart';
//
// import '../../models/medication.dart';
// import '../../services/medicine_store.dart';
// import 'ttc_common.dart';
// import 'ttc_ivf_readiness_screen.dart' show kIvfHue;
// import 'ttc_tool_chrome.dart';
// import 'ttc_strings.dart';
// import 'ttc_supplements_screen.dart';
// import 'ttc_tool_confirm.dart';
//
// void openTtcMedication(BuildContext context) {
//   Navigator.of(context).push(MaterialPageRoute<void>(
//     builder: (_) => const TtcMedicationScreen(),
//     settings: const RouteSettings(name: 'ttc/medication'),
//   ));
// }
//
// class TtcMedicationScreen extends StatelessWidget {
//   const TtcMedicationScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: Listenable.merge([MedicineStore.instance, TtcLang.instance]),
//       builder: (context, _) {
//         final t = TtcS.current();
//         final meds = MedicineStore.instance.activeMeds;
//
//         // ⚠️ V3 CHROME, SHELL ONLY. Every list, dialog and store call below is
//         // untouched. A tool reached from a focus page has to look like it
//         // belongs to the page that sent her, and this one still wore a flat
//         // ground and a back bar. See `ttc_tool_chrome.dart`.
//         //
//         // ⚠️ NO `action` HERE, UNLIKE RECORDS AND APPOINTMENTS. This screen's
//         // add already lives beside the section title it belongs to, and it
//         // changes with the empty state — an invitation when there is nothing,
//         // a quiet link when there is. Lifting it into the hero would break
//         // that, and would put two adds on one screen.
//         return TtcToolScaffold(
//           hue: kIvfHue,
//           // ⚠️ ONE TOOL, ONE NAME (2026-09-27): the Tools tile's name, word
//           // for word. Kept for revert: eyebrow: t.medTitle ("Your medication").
//           eyebrow: t.hinglish ? 'Dawaiyan' : 'Medication',
//           title: 'What to take, and when.',
//           // ⚠️ SAY WHAT THIS IS, FIRST (tools pass, 2026-09-27). The intro was
//           // the no-advice note, so the first thing she read was what the
//           // screen does NOT do. It now says what she does here, and the note
//           // moves to one line at the foot. Kept for revert:
//           // intro: t.medNoAdvice,
//           intro: 'Write down the medicines your clinic gave you. Tap the '
//               "circle on the days you take one. Add a time if you'd like a "
//               'reminder.',
//           // ⚠️ THE GUTTER (launch walk, 2026-09-27): the tool frame leaves
//           // side padding to the screen, and this one had none, so "Today",
//           // the cards and the note ran to the glass. Kept for revert: the
//           // children sat directly in this list.
//           children: [
//             ttcToolPad(Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 const SizedBox(height: 22),
//
//                 // A feature is never hidden: the empty state is an invitation,
//                 // and it says what this is FOR rather than that it is empty.
//                 if (meds.isEmpty)
//                   TtcEmpty(
//                     icon: Icons.medication_outlined,
//                     title: t.medEmptyTitle,
//                     body: t.medEmptyBody,
//                     cta: t.medAdd,
//                     onTap: () => _edit(context, t, null),
//                   )
//                 else ...[
//                   ttcSectionTitle(
//                     t.medToday,
//                     trailing: GestureDetector(
//                       onTap: () => _edit(context, t, null),
//                       behavior: HitTestBehavior.opaque,
//                       child: Text(t.medAdd,
//                           style: ttcBody(12.5,
//                               color: ttcPurple, w: FontWeight.w800)),
//                     ),
//                   ),
//                   for (final m in meds) ...[
//                     _MedCard(med: m, t: t),
//                     const SizedBox(height: 10),
//                   ],
//                 ],
//
//                 const SizedBox(height: 16),
//                 // ⚠️ ONE PLAIN LINE ON THE DIFFERENCE (tools pass): two tiles,
//                 // Supplements and Medication, sit side by side in Tools, and
//                 // nothing said which one folic acid goes in. The line routes
//                 // her to the other one rather than leaving her to guess.
//                 _OtherList(
//                   text: 'Vitamins you chose yourself, like folic acid? '
//                       'Those go in Supplements.',
//                   onTap: () => Navigator.of(context).push(
//                       MaterialPageRoute<void>(
//                           builder: (_) => const TtcSupplementsScreen(),
//                           settings:
//                               const RouteSettings(name: 'ttc/supplements'))),
//                 ),
//                 const SizedBox(height: 14),
//                 // The one no-advice line, said once, at the foot.
//                 Text(t.medNoAdvice,
//                     style: ttcBody(11.5, color: ttcMuted, h: 1.5)),
//                 const SizedBox(height: 18),
//                 // States what we do and do not do with this, in her words,
//                 // where she is looking at it.
//                 // ⚠️ SAID ONCE (2026-09-27): the intro above is this same
//                 // sentence, so this card printed it twice on one screen, and
//                 // the estimates footer below is about cycle dates, not a
//                 // medicines list. Both kept for revert.
//                 // TtcCard(
//                 //   color: ttcPanel,
//                 //   child: Row(
//                 //       crossAxisAlignment: CrossAxisAlignment.start,
//                 //       children: [
//                 //         const Icon(Icons.info_outline_rounded,
//                 //             size: 17, color: ttcBrown),
//                 //         const SizedBox(width: 10),
//                 //         Expanded(
//                 //           child: Text(t.medNoAdvice,
//                 //               style: ttcBody(12.5, color: ttcBrown, h: 1.55)),
//                 //         ),
//                 //       ]),
//                 // ),
//                 // const SizedBox(height: 14),
//                 // TtcDisclaimer(t: t),
//                 const SizedBox(height: 26),
//               ],
//             )),
//           ],
//         );
//       },
//     );
//   }
//
//   static Future<void> _edit(
//       BuildContext context, TtcS t, Medication? existing) async {
//     await showModalBottomSheet<void>(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (_) => _MedSheet(t: t, existing: existing),
//     );
//   }
// }
//
// // ---- one medication ---------------------------------------------------------
//
// class _MedCard extends StatelessWidget {
//   const _MedCard({required this.med, required this.t});
//
//   final Medication med;
//   final TtcS t;
//
//   @override
//   Widget build(BuildContext context) {
//     final taken = MedicineStore.instance.isTakenToday(med.id);
//     final times = med.alarms
//         .where((a) => a.enabled)
//         .expand((a) => a.times)
//         .toList()
//       ..sort();
//     final until = _reminderEnd(med);
//
//     return TtcCard(
//       onTap: () => TtcMedicationScreen._edit(context, t, med),
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         Row(children: [
//           // The tick is the point of the card, so it is the biggest target on
//           // it. Never coloured by how many are outstanding.
//           GestureDetector(
//             onTap: () => MedicineStore.instance.toggleToday(med.id),
//             behavior: HitTestBehavior.opaque,
//             child: Container(
//               width: 30,
//               height: 30,
//               alignment: Alignment.center,
//               decoration: BoxDecoration(
//                 color: taken ? ttcPurple : Colors.transparent,
//                 shape: BoxShape.circle,
//                 border: Border.all(
//                     color: taken ? ttcPurple : ttcLine, width: 1.6),
//               ),
//               child: taken
//                   ? const Icon(Icons.check_rounded,
//                       size: 17, color: Colors.white)
//                   : null,
//             ),
//           ),
//           const SizedBox(width: 13),
//           Expanded(
//             child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(med.name, style: ttcJakarta(15.5)),
//                   if (med.dose.isNotEmpty || med.frequency.isNotEmpty) ...[
//                     const SizedBox(height: 3),
//                     Text(
//                         [med.dose, med.frequency]
//                             .where((s) => s.isNotEmpty)
//                             .join(' · '),
//                         style: ttcBody(12.5)),
//                   ],
//                 ]),
//           ),
//           const Icon(Icons.chevron_right_rounded, size: 18, color: ttcMuted),
//         ]),
//         if (times.isNotEmpty) ...[
//           const SizedBox(height: 12),
//           ttcDivider(),
//           const SizedBox(height: 10),
//           Row(children: [
//             const Icon(Icons.notifications_none_rounded,
//                 size: 15, color: ttcPurple),
//             const SizedBox(width: 8),
//             Expanded(
//               // ⚠️ THE LAST DAY IS SAID WHERE THE TIMES ARE, so a short course
//               // reads as a short course. Once it has passed the line says the
//               // reminders have stopped, rather than listing times that no
//               // longer ring.
//               child: Text(
//                   until == null
//                       ? times.map(_fmtTime).join(', ')
//                       : _endedBy(until)
//                           ? 'Reminders stopped after ${_fmtDay(until)}'
//                           : '${times.map(_fmtTime).join(', ')} · until '
//                               '${_fmtDay(until)}',
//                   style: ttcBody(12, color: ttcSoft, w: FontWeight.w600)),
//             ),
//           ]),
//         ],
//         if (med.notes.isNotEmpty) ...[
//           const SizedBox(height: 10),
//           Text(med.notes, style: ttcBody(12, h: 1.5)),
//         ],
//       ]),
//     );
//   }
//
//   /// The last day reminders ring, when she set one.
//   static DateTime? _reminderEnd(Medication m) {
//     for (final a in m.alarms) {
//       final d = DateTime.tryParse(a.endDateIso ?? '');
//       if (d != null) return d;
//     }
//     return null;
//   }
//
//   static bool _endedBy(DateTime lastDay) {
//     final now = DateTime.now();
//     return DateTime(now.year, now.month, now.day)
//         .isAfter(DateTime(lastDay.year, lastDay.month, lastDay.day));
//   }
//
//   static String _fmtDay(DateTime d) {
//     const m = [
//       'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
//       'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
//     ];
//     return '${d.day} ${m[d.month - 1]}';
//   }
//
//   static String _fmtTime(int minutes) {
//     final h = minutes ~/ 60;
//     final m = minutes % 60;
//     final suffix = h < 12 ? 'am' : 'pm';
//     final h12 = h % 12 == 0 ? 12 : h % 12;
//     return '$h12:${m.toString().padLeft(2, '0')} $suffix';
//   }
// }
//
// // ---- add / edit -------------------------------------------------------------
//
// class _MedSheet extends StatefulWidget {
//   const _MedSheet({required this.t, this.existing});
//
//   final TtcS t;
//   final Medication? existing;
//
//   @override
//   State<_MedSheet> createState() => _MedSheetState();
// }
//
// class _MedSheetState extends State<_MedSheet> {
//   late final TextEditingController _name;
//   late final TextEditingController _dose;
//   late final TextEditingController _freq;
//   late final TextEditingController _notes;
//
//   /// Minutes since midnight. Empty means "no reminder", which is a real choice
//   /// and the default - a medication she takes at the clinic does not need one.
//   late List<int> _times;
//
//   /// The last day the reminders ring. Null means every day until she removes
//   /// it, which was the only behaviour before 2026-09-27.
//   ///
//   /// ⚠️ WHY THIS EXISTS: "When" is free text ("Days 3 to 7"), but reminders
//   /// were daily for ever, so a five-day course kept ringing on day 8 and every
//   /// day after. `MedAlarm` already carried an `endDateIso` and
//   /// `NotificationService` already stops materialising alarms after it, so
//   /// this is a field on the form and nothing new in the shared store.
//   DateTime? _lastDay;
//
//   /// Set when she taps Save with no name, so the reason shows under the
//   /// button instead of the tap doing nothing.
//   bool _needsName = false;
//
//   @override
//   void initState() {
//     super.initState();
//     final e = widget.existing;
//     _name = TextEditingController(text: e?.name ?? '');
//     _dose = TextEditingController(text: e?.dose ?? '');
//     _freq = TextEditingController(text: e?.frequency ?? '');
//     _notes = TextEditingController(text: e?.notes ?? '');
//     _times = [
//       ...?e?.alarms.where((a) => a.enabled).expand((a) => a.times),
//     ]..sort();
//     if (e != null) _lastDay = _MedCard._reminderEnd(e);
//   }
//
//   @override
//   void dispose() {
//     _name.dispose();
//     _dose.dispose();
//     _freq.dispose();
//     _notes.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final t = widget.t;
//     final editing = widget.existing != null;
//     return Padding(
//       padding: EdgeInsets.only(
//           bottom: MediaQuery.of(context).viewInsets.bottom),
//       child: Container(
//         decoration: const BoxDecoration(
//           color: ttcBg,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
//         ),
//         padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
//         child: SingleChildScrollView(
//           child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Center(
//                   child: Container(
//                       width: 40,
//                       height: 4,
//                       decoration: BoxDecoration(
//                           color: ttcLine,
//                           borderRadius: BorderRadius.circular(999))),
//                 ),
//                 const SizedBox(height: 18),
//                 Text(editing ? t.medEdit : t.medAdd, style: ttcJakarta(18)),
//                 const SizedBox(height: 16),
//
//                 _field(t.medName, _name, hint: t.medNameHint,
//                     onChanged: (_) {
//                   if (_needsName) setState(() => _needsName = false);
//                 }),
//                 const SizedBox(height: 12),
//                 _field(t.medDose, _dose, hint: t.medDoseHint),
//                 const SizedBox(height: 12),
//                 _field(t.medFrequency, _freq, hint: t.medFrequencyHint),
//                 const SizedBox(height: 12),
//                 _field(t.medNotes, _notes, hint: t.medNotesHint, lines: 3),
//                 const SizedBox(height: 18),
//
//                 // ---- reminders ------------------------------------------
//                 Text(t.medReminders.toUpperCase(),
//                     style: ttcBody(9.5,
//                         color: ttcMuted, w: FontWeight.w800)),
//                 const SizedBox(height: 4),
//                 Text(t.medRemindersNote, style: ttcBody(12, h: 1.5)),
//                 const SizedBox(height: 10),
//                 Wrap(spacing: 8, runSpacing: 8, children: [
//                   for (final m in _times)
//                     GestureDetector(
//                       onTap: () => setState(() => _times.remove(m)),
//                       behavior: HitTestBehavior.opaque,
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 12, vertical: 8),
//                         decoration: BoxDecoration(
//                           color: ttcPanel,
//                           borderRadius: BorderRadius.circular(999),
//                         ),
//                         child: Row(mainAxisSize: MainAxisSize.min, children: [
//                           Text(_MedCard._fmtTime(m),
//                               style: ttcBody(12.5,
//                                   color: ttcPurple, w: FontWeight.w700)),
//                           const SizedBox(width: 6),
//                           const Icon(Icons.close_rounded,
//                               size: 14, color: ttcPurple),
//                         ]),
//                       ),
//                     ),
//                   GestureDetector(
//                     onTap: _addTime,
//                     behavior: HitTestBehavior.opaque,
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 12, vertical: 8),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(999),
//                         border: Border.all(color: ttcPurple, width: 1.2),
//                       ),
//                       child: Row(mainAxisSize: MainAxisSize.min, children: [
//                         const Icon(Icons.add_rounded,
//                             size: 15, color: ttcPurple),
//                         const SizedBox(width: 5),
//                         Text(t.medAddTime,
//                             style: ttcBody(12.5,
//                                 color: ttcPurple, w: FontWeight.w700)),
//                       ]),
//                     ),
//                   ),
//                 ]),
//
//                 // ---- when the reminders stop ------------------------------
//                 // Only once there is a reminder to stop. Mobbin: GoodRx and
//                 // Hers put the schedule beside the reminder it governs, and
//                 // MyFitnessPal names each row ("Date", "Time") so a filled row
//                 // still says what it is.
//                 if (_times.isNotEmpty) ...[
//                   const SizedBox(height: 16),
//                   Text('LAST DAY OF REMINDERS',
//                       style: ttcBody(9.5,
//                           color: ttcMuted, w: FontWeight.w800)),
//                   const SizedBox(height: 4),
//                   Text(
//                       'For a short course, pick the last day and the '
//                       'reminders stop after it.',
//                       style: ttcBody(12, h: 1.5)),
//                   const SizedBox(height: 8),
//                   Row(children: [
//                     Expanded(
//                       child: GestureDetector(
//                         key: const ValueKey('ttc_med_last_day'),
//                         onTap: _pickLastDay,
//                         behavior: HitTestBehavior.opaque,
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 14, vertical: 13),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(14),
//                             border: Border.all(color: ttcLine),
//                           ),
//                           child: Row(children: [
//                             const Icon(Icons.event_outlined,
//                                 size: 16, color: ttcPurple),
//                             const SizedBox(width: 10),
//                             Expanded(
//                               child: Text(
//                                   _lastDay == null
//                                       ? 'Every day, no end date'
//                                       : 'Until ${_MedCard._fmtDay(_lastDay!)} '
//                                           '${_lastDay!.year}',
//                                   style: ttcBody(13.5,
//                                       color: ttcInk, w: FontWeight.w600)),
//                             ),
//                             Text(_lastDay == null ? 'Set' : 'Change',
//                                 style: ttcBody(12.5,
//                                     color: ttcPurple, w: FontWeight.w800)),
//                           ]),
//                         ),
//                       ),
//                     ),
//                     if (_lastDay != null) ...[
//                       const SizedBox(width: 8),
//                       GestureDetector(
//                         onTap: () => setState(() => _lastDay = null),
//                         behavior: HitTestBehavior.opaque,
//                         child: Padding(
//                           padding: const EdgeInsets.all(8),
//                           child: Text('No end',
//                               style: ttcBody(12.5,
//                                   color: ttcMuted, w: FontWeight.w700)),
//                         ),
//                       ),
//                     ],
//                   ]),
//                 ],
//                 const SizedBox(height: 22),
//
//                 GestureDetector(
//                   onTap: _save,
//                   behavior: HitTestBehavior.opaque,
//                   child: Container(
//                     alignment: Alignment.center,
//                     padding: const EdgeInsets.symmetric(vertical: 15),
//                     decoration: BoxDecoration(
//                         color: ttcPurple,
//                         borderRadius: BorderRadius.circular(16)),
//                     child: Text(t.medSave,
//                         style: ttcBody(14,
//                             color: Colors.white, w: FontWeight.w800)),
//                   ),
//                 ),
//                 if (_needsName) const TtcFormHint(text: 'Add a name to save.'),
//                 if (editing) ...[
//                   const SizedBox(height: 10),
//                   Center(
//                     child: GestureDetector(
//                       onTap: _delete,
//                       behavior: HitTestBehavior.opaque,
//                       child: Padding(
//                         padding: const EdgeInsets.all(8),
//                         child: Text(t.medDelete,
//                             style: ttcBody(12.5,
//                                 color: ttcMuted, w: FontWeight.w700)),
//                       ),
//                     ),
//                   ),
//                 ],
//               ]),
//         ),
//       ),
//     );
//   }
//
//   Widget _field(String label, TextEditingController c,
//           {String hint = '', int lines = 1, ValueChanged<String>? onChanged}) =>
//       Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         Text(label.toUpperCase(),
//             style: ttcBody(9.5, color: ttcMuted, w: FontWeight.w800)),
//         const SizedBox(height: 6),
//         TextField(
//           controller: c,
//           maxLines: lines,
//           onChanged: onChanged,
//           style: ttcBody(14, color: ttcInk),
//           decoration: InputDecoration(
//             hintText: hint,
//             hintStyle: ttcBody(13.5, color: ttcMuted),
//             filled: true,
//             fillColor: Colors.white,
//             contentPadding:
//                 const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(14),
//               borderSide: const BorderSide(color: ttcLine),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(14),
//               borderSide: const BorderSide(color: ttcLine),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(14),
//               borderSide: const BorderSide(color: ttcPurple, width: 1.4),
//             ),
//           ),
//         ),
//       ]);
//
//   Future<void> _addTime() async {
//     final picked = await showTimePicker(
//       context: context,
//       initialTime: const TimeOfDay(hour: 9, minute: 0),
//     );
//     if (picked == null) return;
//     final m = picked.hour * 60 + picked.minute;
//     if (_times.contains(m)) return;
//     setState(() => _times = [..._times, m]..sort());
//   }
//
//   Future<void> _pickLastDay() async {
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);
//     final picked = await showDatePicker(
//       context: context,
//       helpText: 'Last day of reminders',
//       initialDate: _lastDay != null && !_lastDay!.isBefore(today)
//           ? _lastDay!
//           : today,
//       firstDate: today,
//       lastDate: today.add(const Duration(days: 365)),
//     );
//     // A closed picker changes nothing: no silent default.
//     if (picked == null || !mounted) return;
//     setState(() => _lastDay = picked);
//   }
//
//   Future<void> _save() async {
//     final name = _name.text.trim();
//     // Kept for revert (2026-09-27): `if (name.isEmpty) return;` ignored the
//     // tap without a word, which reads as a broken button.
//     if (name.isEmpty) {
//       setState(() => _needsName = true);
//       return;
//     }
//     final nav = Navigator.of(context);
//     final store = MedicineStore.instance;
//     final existing = widget.existing;
//
//     // One alarm config carrying every chosen time - the model supports several
//     // times per config, so a thrice-daily medication is one alarm, not three.
//     final alarms = _times.isEmpty
//         ? const <MedAlarm>[]
//         : [
//             MedAlarm(
//               id: existing?.alarms.isNotEmpty == true
//                   ? existing!.alarms.first.id
//                   : 'ttcma_${DateTime.now().microsecondsSinceEpoch}',
//               times: _times,
//               repeat: MedAlarmRepeat.daily,
//               // `NotificationService` compares by day, so the medicine still
//               // rings on its last day and not after.
//               endDateIso: _lastDay?.toIso8601String(),
//             ),
//           ];
//
//     if (existing == null) {
//       await store.addMed(Medication(
//         id: 'ttcm_${DateTime.now().microsecondsSinceEpoch}',
//         name: name,
//         // `medication`, not `supplement`: this screen exists for the things a
//         // clinic prescribed, and the distinction is what the care pathway
//         // reasons about.
//         type: MedType.medication,
//         dose: _dose.text.trim(),
//         frequency: _freq.text.trim(),
//         notes: _notes.text.trim(),
//         startDateIso: DateTime.now().toIso8601String(),
//         endDateIso: _lastDay?.toIso8601String(),
//         alarms: alarms,
//       ));
//     } else {
//       await store.updateMed(existing.copyWith(
//         name: name,
//         dose: _dose.text.trim(),
//         frequency: _freq.text.trim(),
//         notes: _notes.text.trim(),
//         alarms: alarms,
//       ));
//     }
//     nav.pop();
//   }
//
//   Future<void> _delete() async {
//     final nav = Navigator.of(context);
//     // ⚠️ ASKED FIRST (tools pass): removing a medicine also removes every day
//     // she ticked it and its reminders, in one tap, with no way back.
//     final ok = await ttcConfirmRemove(context,
//         title: 'Remove ${widget.existing!.name}?',
//         body: 'Its reminders stop, and the days you ticked it go too.');
//     if (!ok) return;
//     await MedicineStore.instance.deleteMed(widget.existing!.id);
//     nav.pop();
//   }
// }
//
// /// A quiet link to the neighbouring list, for the thing that belongs there.
// class _OtherList extends StatelessWidget {
//   const _OtherList({required this.text, required this.onTap});
//
//   final String text;
//   final VoidCallback onTap;
//
//   @override
//   Widget build(BuildContext context) => GestureDetector(
//         onTap: onTap,
//         behavior: HitTestBehavior.opaque,
//         child: Row(children: [
//           Expanded(
//             child: Text(text,
//                 style: ttcBody(12.5, color: ttcPurple, w: FontWeight.w700)),
//           ),
//           const Icon(Icons.chevron_right_rounded, size: 18, color: ttcPurple),
//         ]),
//       );
// }
