// =============================================================================
//  Symptoms — the Today tab's tool: the check-in
// -----------------------------------------------------------------------------
//  What she sees when she opens the door: the day strip (the home's), a
//  grid of round tiles — "Common in week 20" first, the rest by area under
//  "More" — one tap logs, the next tap says how strong. Under the grid, for
//  what she logged today: the one thing that helps, and the way to the page.
//  Then the evening reminder, off by default.
//
//  ⚠️ WHY A GRID AND NOT A LIST (Mobbin §18). Flo, Clue, Stardust, Fitbit
//  and Bloom all log symptoms as round icon tiles in a grid; Withings and
//  Apple Health use checklists; Visible uses a severity matrix. A grid is
//  what a hand does at 11pm — it scans, it taps, it is done. A list asks her
//  to read. The severity matrix is right for a clinic and wrong for a home.
//
//  ⚠️ ONE TAP LOGS AS MILD. Flo asks her to "Apply"; Visible asks 0–3 per
//  row before she can leave. The cheapest log wins the habit: a tap is the
//  log, and strength is the SECOND tap, for the days it matters.
//
//  ⚠️ THE STRIP IS THE HOME'S `PvDayStrip`, with the log's own dot under a
//  day. A day ahead is drawn (so today sits in the centre, the user's call
//  on the home) and dimmed; its grid does not log — a symptom cannot be
//  felt on a day that has not happened.
// =============================================================================

import 'package:flutter/material.dart';

import '../../../data/doors/pv_door_data.dart' show PvDoorLibrary;
import '../../../data/reads/symptom_reads.dart';
import '../../../data/symptoms/symptom_library.dart';
import '../../../models/reminder.dart';
import '../../../models/symptom.dart';
import '../../../services/pregnancy_controller.dart';
import '../../../services/reminder_store.dart';
import '../../../services/symptom_store.dart';
import '../../../theme/pv_fonts.dart';
import '../../../widgets/pv_feedback.dart';
import '../../doors/pv_door_chrome.dart';
import '../../doors/pv_door_router.dart' show pvDoorEntryRoute;
import '../../reader/pv_reader_screen.dart';
import '../../brackets/hub/hub_intent_art.dart' show HubIntentArt;
import '../../v2/pv_day_strip.dart';
import '../../v2/v2_palette.dart';
import 'symptoms_widgets.dart';

/// The evening reminder's id in `ReminderStore` — one, toggled.
const String kSymptomReminderId = 'symptoms_evening';

/// Open a symptom's page in the one reader.
void openSymptomRead(BuildContext context, Symptom s, PregnancyController c) {
  Navigator.of(context).push(MaterialPageRoute<void>(
    settings: RouteSettings(name: pvDoorEntryRoute(PvDoorLibrary.symptom, s.id)),
    builder: (_) => symptomReader(pvReadFromSymptom(s), c),
  ));
}

/// The reader with this door's read-next resolved.
Widget symptomReader(dynamic read, PregnancyController c) => PvReaderScreen(
      read: read,
      lang: c.language,
      resolveRead: symptomReadById,
      openRead: (context, id) {
        final r = symptomReadById(id);
        if (r == null) return;
        Navigator.of(context).push(MaterialPageRoute<void>(
          settings: RouteSettings(name: 'symptoms/read/$id'),
          builder: (_) => symptomReader(r, c),
        ));
      },
    );

class SymptomsTodayBody extends StatefulWidget {
  const SymptomsTodayBody({super.key, required this.pregnancy});
  final PregnancyController pregnancy;

  @override
  State<SymptomsTodayBody> createState() => _SymptomsTodayBodyState();
}

class _SymptomsTodayBodyState extends State<SymptomsTodayBody> with WidgetsBindingObserver {
  static DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);
  DateTime _today = _dayOnly(DateTime.now());
  late DateTime _selected = _today;
  bool _more = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SymptomStore.instance.init();
    ReminderStore.instance.init();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _rollOver();
  }

  void _rollOver() {
    final now = _dayOnly(DateTime.now());
    if (now == _today) return;
    setState(() {
      final wasOnToday = _selected == _today;
      _today = now;
      if (wasOnToday) _selected = now;
    });
  }

  static const _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  String _dayWord(DateTime d) {
    final diff = d.difference(_today).inDays;
    if (diff == 0) return 'Today';
    if (diff == -1) return 'Yesterday';
    if (diff == 1) return 'Tomorrow';
    return '${_days[d.weekday - 1]} ${d.day} ${_months[d.month - 1]}';
  }

  Future<void> _tap(Symptom s) async {
    final store = SymptomStore.instance;
    final current = store.severityOn(_selected, s.id);
    if (current == null) {
      await store.setOn(_selected, s.id, 'mild');
      return;
    }
    final picked = await showSeveritySheet(context, s, current);
    if (picked == null) return;
    if (picked.isEmpty) {
      await store.unlogOn(_selected, s.id);
    } else {
      await store.setOn(_selected, s.id, picked);
    }
  }

  void _toggleReminder(bool on) {
    pvCommitFeedback();
    final store = ReminderStore.instance;
    if (on) {
      store.upsert(const Reminder(
        id: kSymptomReminderId,
        title: 'How was today?',
        body: 'Two taps on the Symptoms door and your week keeps itself.',
        hour: 20,
        minute: 30,
        category: 'symptoms',
      ));
    } else {
      store.remove(kSymptomReminderId);
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: Listenable.merge([V2PaletteStore.instance, SymptomStore.instance, ReminderStore.instance, widget.pregnancy]),
        builder: (context, _) {
          if (_dayOnly(DateTime.now()) != _today) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _rollOver();
            });
          }
          final p = V2PaletteStore.instance.current;
          final store = SymptomStore.instance;
          final c = widget.pregnancy;
          final week = c.currentWeek;
          final future = _selected.isAfter(_today);
          final ordered = symptomsCommonAt(week);
          final common = ordered.take(8).toList();
          final rest = ordered.skip(8).toList();
          final loggedToday = store.logsOn(_selected);
          final reminderOn = ReminderStore.instance.byId(kSymptomReminderId)?.enabled ?? false;

          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // ---- the day -------------------------------------------------------
            pvDoorPad(symptomsHeading(p, 'How are you?',
                sub: '${_dayWord(_selected)}. Tap what you feel; tap again to say how strong.')),
            const SizedBox(height: 10),
            // Edge to edge, with the gutter inside it (the door rule).
            PvDayStrip(
              p: p,
              gutter: kPvDoorGutter,
              selected: _selected,
              today: _today,
              onSelect: (d) => setState(() => _selected = d),
              accent: p.ink1,
              keyPrefix: 'sym_day_',
              daysBack: (c.currentDay - 1).clamp(0, 180),
              daysForward: 6,
              markFor: (date, sel) {
                final n = store.logsOn(date).length;
                if (n == 0) return null;
                return Center(
                  child: Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(color: sel ? p.ink1 : p.ink3, shape: BoxShape.circle),
                  ),
                );
              },
            ),
            const SizedBox(height: 6),

            // ---- common this week ---------------------------------------------
            pvDoorPad(Text(future ? 'THAT DAY HAS NOT COME YET' : 'COMMON IN WEEK $week',
                style: pvManrope(fontSize: 10.5, fontWeight: FontWeight.w800, letterSpacing: 1.3, color: p.ink3))),
            const SizedBox(height: 12),
            pvDoorPad(_Grid(
              p: p,
              symptoms: common,
              severityOf: (s) => store.severityOn(_selected, s.id),
              onTap: _tap,
              onOpen: (s) => openSymptomRead(context, s, c),
              enabled: !future,
            )),

            // ---- more ----------------------------------------------------------
            const SizedBox(height: 10),
            pvDoorPad(Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => setState(() => _more = !_more),
                icon: Icon(_more ? Icons.expand_less_rounded : Icons.expand_more_rounded, size: 18, color: p.ink1),
                label: Text(_more ? 'Fewer' : 'Something else · ${rest.length} more',
                    style: pvManrope(fontSize: 13, fontWeight: FontWeight.w800, color: p.ink1)),
                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 4)),
              ),
            )),
            if (_more) ...[
              for (final area in SymptomArea.values)
                if (rest.any((s) => symptomArea(s) == area)) ...[
                  const SizedBox(height: 8),
                  pvDoorPad(Row(children: [
                    SizedBox(width: 18, height: 18, child: symptomAreaMark(p, area)),
                    const SizedBox(width: 8),
                    Text(area.label.toUpperCase(),
                        style: pvManrope(fontSize: 10.5, fontWeight: FontWeight.w800, letterSpacing: 1.3, color: p.ink3)),
                  ])),
                  const SizedBox(height: 10),
                  pvDoorPad(_Grid(
                    p: p,
                    symptoms: [for (final s in rest) if (symptomArea(s) == area) s],
                    severityOf: (s) => store.severityOn(_selected, s.id),
                    onTap: _tap,
                    onOpen: (s) => openSymptomRead(context, s, c),
                    enabled: !future,
                  )),
                ],
            ],
            const SizedBox(height: 22),

            // ---- what helps, for what she logged --------------------------------
            //
            // ⚠️ THE PAYOFF IS RIGHT UNDER THE TAP. A logged symptom earns one
            // line of help and the way to its page — the check-in gives back
            // the moment it is used, which is the difference between a log
            // and a chore. Nothing logged: one honest line, not an empty box.
            pvDoorPad(symptomsHeading(p, 'What helps',
                sub: loggedToday.isEmpty
                    ? (future ? 'Come back on the day.' : 'Tap a symptom above and its help appears here.')
                    : 'For what you logged ${_dayWord(_selected).toLowerCase()}.')),
            const SizedBox(height: 10),
            for (final l in loggedToday)
              if (symptomById(l.symptomId) case final s?)
                pvDoorPad(_HelpRow(
                  p: p,
                  symptom: s,
                  severity: l.severity,
                  onTap: () => openSymptomRead(context, s, c),
                )),
            if (loggedToday.isNotEmpty) ...[
              const SizedBox(height: 4),
              pvDoorPad(Text(
                  'General guidance, never a diagnosis. Anything that worries you is a call to your doctor — the Talk tab has the five to call about at any hour.',
                  style: pvManrope(fontSize: 11.5, height: 1.45, color: p.ink3))),
            ],
            const SizedBox(height: 22),

            // ---- the evening reminder -------------------------------------------
            pvDoorPad(Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
              decoration: BoxDecoration(
                  color: p.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: p.line)),
              child: Row(children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Ask me each evening', style: pvManrope(fontSize: 14.5, fontWeight: FontWeight.w800, color: p.ink1)),
                    const SizedBox(height: 2),
                    Text('"How was today?" at 8:30 pm. Off unless you want it.',
                        style: pvManrope(fontSize: 12.5, height: 1.4, color: p.ink2)),
                  ]),
                ),
                Switch.adaptive(value: reminderOn, onChanged: _toggleReminder, activeThumbColor: p.ground, activeTrackColor: p.ink1),
              ]),
            )),
            const SizedBox(height: 8),
          ]);
        },
      );
}

/// The tiles, four to a row, wrapping.
class _Grid extends StatelessWidget {
  const _Grid({
    required this.p,
    required this.symptoms,
    required this.severityOf,
    required this.onTap,
    required this.onOpen,
    required this.enabled,
  });
  final V2Palette p;
  final List<Symptom> symptoms;
  final String? Function(Symptom) severityOf;
  final void Function(Symptom) onTap;
  final void Function(Symptom) onOpen;
  final bool enabled;

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, box) {
        // Four across on a 324pt gutter: 4 × 78 = 312, three gaps of 4.
        final w = ((box.maxWidth - 12) / 4).clamp(64.0, 96.0);
        return Wrap(
          spacing: 4,
          runSpacing: 14,
          children: [
            for (final s in symptoms)
              SymptomTile(
                key: ValueKey('sym_tile_${s.id}'),
                p: p,
                symptom: s,
                severity: severityOf(s),
                onTap: () => onTap(s),
                onOpen: () => onOpen(s),
                enabled: enabled,
                width: w,
              ),
          ],
        );
      });
}

/// One logged symptom's help: the mark, the name and strength, the first
/// tip, the chevron to the page.
class _HelpRow extends StatelessWidget {
  const _HelpRow({required this.p, required this.symptom, required this.severity, required this.onTap});
  final V2Palette p;
  final Symptom symptom;
  final String severity;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () {
          pvCommitFeedback();
          onTap();
        },
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 42,
              height: 42,
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                  color: symptomAreaTint(p, symptomArea(symptom)), borderRadius: BorderRadius.circular(13)),
              child: HubIntentArt(mark: symptomMark(symptom), tint: symptomAreaTint(p, symptomArea(symptom))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${symptom.name.en} · ${severityLabel(severity).toLowerCase()}',
                    style: pvManrope(fontSize: 14, fontWeight: FontWeight.w800, color: p.ink1)),
                const SizedBox(height: 3),
                Text(symptom.tips.isEmpty ? symptom.why.en : symptom.tips.first.en,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: pvManrope(fontSize: 13, height: 1.45, color: p.ink2)),
              ]),
            ),
            const SizedBox(width: 6),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Icon(Icons.chevron_right_rounded, size: 20, color: p.ink3),
            ),
          ]),
        ),
      );
}
