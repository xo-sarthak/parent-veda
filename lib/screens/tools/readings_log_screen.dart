// =============================================================================
//  Blood pressure & sugar — the readings log (2026-09-30)
// -----------------------------------------------------------------------------
//  WHY SHE OPENS IT. Her doctor asked her to check at home (sugar after meals,
//  pressure daily) and she will open this more often than almost any other
//  screen: quickly, one-handed, often tired, sometimes anxious about the number.
//  She is reporting, not learning. So the FIRST thing on the page is the act
//  (add a reading), the second is her own last number, and nothing she must read
//  sits in front of either.
//
//  WHAT IT DOES: keeps her numbers, shows them back, and packs them for her
//  doctor ("Share with my doctor"). WHAT IT NEVER DOES: judge a number. No red,
//  no green, no "high", no "normal". The only comparison is her DOCTOR's target,
//  which she may enter and which we print beside her readings as hers. See
//  `readings_store.dart` for why that line is held.
//
//  WHERE ELSE IT LIVES: the Complications door ("Keep your numbers") and the
//  Tools list open this same screen. One screen, two ways in.
//
//  Mobbin (a tracker's shape: latest value, add, history by day): Apple Health's
//  blood pressure detail, and Clue's tracking lists. The whole design is one
//  screen with a kind switch rather than two near-identical screens.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../services/pregnancy_controller.dart';
import '../../services/readings_store.dart';
import '../../theme/pv_fonts.dart';
import '../brackets/hub/hub_intent_art.dart' show IntentMark;
import '../brackets/same_day_signs_screen.dart';
import '../pregnancy/preg_chrome.dart';
import '../pregnancy/preg_tool_chrome.dart';
import '../products/pv_store_chrome.dart' show kPvInk, kPvLine, pvStorePalette;

const double _kToolHue = 206;

const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

String _day(DateTime d) => '${d.day} ${_months[d.month - 1]}';
String _time(DateTime d) {
  final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
  return '$h:${d.minute.toString().padLeft(2, '0')} ${d.hour < 12 ? 'am' : 'pm'}';
}

bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

class ReadingsLogScreen extends StatefulWidget {
  const ReadingsLogScreen({super.key, required this.controller, this.store});

  final PregnancyController controller;

  /// A store of her own, for a test. Null is the app's one.
  final ReadingsStore? store;

  @override
  State<ReadingsLogScreen> createState() => _ReadingsLogScreenState();
}

class _ReadingsLogScreenState extends State<ReadingsLogScreen> {
  ReadingKind _kind = ReadingKind.bloodPressure;

  ReadingsStore get store => widget.store ?? ReadingsStore.instance;

  @override
  void initState() {
    super.initState();
    store.load();
  }

  bool get _isBp => _kind == ReadingKind.bloodPressure;

  Future<void> _share() => Share.share(store.summary(_kind));

  void _add() => _showEditor(context, store: store, kind: _kind);

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: store,
        builder: (context, _) {
          final rows = store.of(_kind);
          return PregToolScaffold(
            hue: _kToolHue,
            eyebrow: 'Track',
            title: 'Blood pressure & sugar',
            intro: 'Keep the numbers your doctor asked you to check, and take them to your next visit. '
                'We show your readings back. We never say what they mean.',
            mark: IntentMark.chartLog,
            action: PregToolAddAction(label: 'Add a reading', onTap: _add),
            children: [
              pregToolPad(_KindSwitch(kind: _kind, onChanged: (k) => setState(() => _kind = k))),
              const SizedBox(height: 16),
              pregToolPad(rows.isEmpty
                  ? _Empty(isBp: _isBp, onAdd: _add)
                  : _Latest(reading: rows.first, targets: store.targets, onAdd: _add)),
              const SizedBox(height: 14),
              pregToolPad(_TargetRow(
                isBp: _isBp,
                targets: store.targets,
                onTap: () => _showTargets(context, store),
              )),
              if (rows.isNotEmpty) ...[
                const SizedBox(height: 26),
                pregToolPad(const PregSectionHeading('Your readings')),
                const SizedBox(height: 10),
                pregToolPad(_History(rows: rows, onTap: (r) => _showEditor(context, store: store, kind: _kind, existing: r))),
                const SizedBox(height: 16),
                pregToolPad(OutlinedButton.icon(
                  key: const ValueKey('readings_share'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kPvInk,
                    side: const BorderSide(color: kPvInk),
                    shape: const StadiumBorder(),
                    minimumSize: const Size.fromHeight(46),
                  ),
                  onPressed: _share,
                  icon: const Icon(Icons.ios_share_rounded, size: 18),
                  label: Text('Share with my doctor',
                      style: pvManrope(fontSize: 14, fontWeight: FontWeight.w700, color: kPvInk)),
                )),
              ],
              const SizedBox(height: 26),
              // The line this page holds, and a way to the vetted same-day signs
              // rather than new clinical words of our own.
              pregToolPad(const PregNote(
                  'We keep your numbers and show them back. What they mean is for your doctor, who sees your whole picture.')),
              if (_isBp) ...[
                const SizedBox(height: 14),
                pregToolPad(PregRowCard(children: [
                  PregOfferRow(
                    mark: IntentMark.askDoctor,
                    hue: _kToolHue,
                    title: 'Signs to get help the same day',
                    line: 'When a symptom should not wait for your next visit, whatever the number.',
                    onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                      settings: const RouteSettings(name: 'bracket/same_day'),
                      builder: (_) => SameDaySignsScreen(pregnancy: widget.controller),
                    )),
                  ),
                ])),
              ],
            ],
          );
        },
      );
}

// ---- the kind switch ---------------------------------------------------------

class _KindSwitch extends StatelessWidget {
  const _KindSwitch({required this.kind, required this.onChanged});
  final ReadingKind kind;
  final ValueChanged<ReadingKind> onChanged;

  @override
  Widget build(BuildContext context) => Wrap(spacing: 8, runSpacing: 8, children: [
        for (final k in ReadingKind.values)
          _Pill(
            key: ValueKey('readings_kind_${k.name}'),
            label: k == ReadingKind.bloodPressure ? 'Blood pressure' : 'Blood sugar',
            selected: k == kind,
            onTap: () => onChanged(k),
          ),
      ]);
}

class _Pill extends StatelessWidget {
  const _Pill({super.key, required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        selected: selected,
        label: label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? kPvInk : Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: selected ? kPvInk : kPvLine),
            ),
            child: Text(label,
                style: pvManrope(
                    fontSize: 13.5, fontWeight: FontWeight.w700, color: selected ? Colors.white : kPvInk)),
          ),
        ),
      );
}

// ---- empty and latest --------------------------------------------------------

class _Empty extends StatelessWidget {
  const _Empty({required this.isBp, required this.onAdd});
  final bool isBp;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return PregCard(
      key: const ValueKey('readings_empty'),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(isBp ? 'No blood pressure readings yet' : 'No sugar readings yet',
            style: pvFraunces(fontSize: 18, fontWeight: FontWeight.w600, color: p.ink1)),
        const SizedBox(height: 6),
        Text(
            isBp
                ? 'Add each reading as you take it. It takes a few seconds, and builds the record your doctor will ask for.'
                : 'Add each reading as you take it, fasting or after food. It builds the record your doctor will ask for.',
            style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink2)),
        const SizedBox(height: 14),
        FilledButton(
          key: const ValueKey('readings_add_first'),
          style: pregFilledStyle(),
          onPressed: onAdd,
          child: Text('Add a reading',
              style: pvManrope(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
        ),
      ]),
    );
  }
}

class _Latest extends StatelessWidget {
  const _Latest({required this.reading, required this.targets, required this.onAdd});
  final Reading reading;
  final ReadingTargets targets;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    final isBp = reading.kind == ReadingKind.bloodPressure;
    final when = _sameDay(reading.at, DateTime.now()) ? 'Today' : _day(reading.at);
    final ctx = reading.context == null ? '' : ', ${reading.context!.label.toLowerCase()}';
    return PregCard(
      key: const ValueKey('readings_latest'),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('LAST READING',
            style: pvManrope(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.3, color: p.ink3)),
        const SizedBox(height: 8),
        // Ink, always: the number is hers, and its colour says nothing about it.
        Text.rich(TextSpan(children: [
          TextSpan(text: reading.valueText, style: pvFraunces(fontSize: 40, fontWeight: FontWeight.w600, color: p.ink1)),
          TextSpan(text: '  ${isBp ? 'mmHg' : 'mg/dL'}', style: pvManrope(fontSize: 13, color: p.ink3)),
        ])),
        const SizedBox(height: 4),
        Text('$when, ${_time(reading.at)}$ctx', style: pvManrope(fontSize: 13.5, color: p.ink2)),
        if ((isBp ? targets.pressureLine : targets.sugarLine) case final t?) ...[
          const SizedBox(height: 10),
          Text("Your doctor's target: ${t[0].toLowerCase()}${t.substring(1)}",
              style: pvManrope(fontSize: 13, color: p.ink2)),
        ],
        const SizedBox(height: 14),
        FilledButton(
          key: const ValueKey('readings_add'),
          style: pregFilledStyle(),
          onPressed: onAdd,
          child: Text('Add a reading',
              style: pvManrope(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
        ),
      ]),
    );
  }
}

// ---- the doctor's target -----------------------------------------------------

class _TargetRow extends StatelessWidget {
  const _TargetRow({required this.isBp, required this.targets, required this.onTap});
  final bool isBp;
  final ReadingTargets targets;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final line = isBp ? targets.pressureLine : targets.sugarLine;
    return PregRowCard(children: [
      PregOfferRow(
        mark: IntentMark.reportPage,
        hue: _kToolHue,
        title: line == null ? "Add your doctor's target" : "Your doctor's target",
        line: line ?? 'If your doctor gave you a number to aim for, keep it here beside your readings.',
        onTap: onTap,
      ),
    ]);
  }
}

// ---- history -----------------------------------------------------------------

class _History extends StatelessWidget {
  const _History({required this.rows, required this.onTap});
  final List<Reading> rows;
  final ValueChanged<Reading> onTap;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    final shown = rows.take(60).toList();
    return PregRowCard(children: [
      for (var i = 0; i < shown.length; i++)
        InkWell(
          key: ValueKey('reading_row_${shown[i].id}'),
          onTap: () => onTap(shown[i]),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                      i == 0 || !_sameDay(shown[i].at, shown[i - 1].at)
                          ? (_sameDay(shown[i].at, DateTime.now()) ? 'Today' : _day(shown[i].at))
                          : '',
                      style: pvManrope(fontSize: 11.5, fontWeight: FontWeight.w700, color: p.ink3)),
                  Text(
                      '${_time(shown[i].at)}${shown[i].context == null ? '' : ' · ${shown[i].context!.label}'}',
                      style: pvManrope(fontSize: 13, color: p.ink2)),
                  if (shown[i].note.isNotEmpty)
                    Text(shown[i].note,
                        maxLines: 1, overflow: TextOverflow.ellipsis, style: pvManrope(fontSize: 12.5, color: p.ink3)),
                ]),
              ),
              const SizedBox(width: 12),
              Text(shown[i].valueText, style: pvFraunces(fontSize: 22, fontWeight: FontWeight.w600, color: p.ink1)),
            ]),
          ),
        ),
    ]);
  }
}

// ---- the add / edit sheet ----------------------------------------------------

Future<void> _showEditor(BuildContext context,
    {required ReadingsStore store, required ReadingKind kind, Reading? existing}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: pvStorePalette.ground,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => _EditorSheet(store: store, kind: kind, existing: existing),
  );
}

class _EditorSheet extends StatefulWidget {
  const _EditorSheet({required this.store, required this.kind, this.existing});
  final ReadingsStore store;
  final ReadingKind kind;
  final Reading? existing;

  @override
  State<_EditorSheet> createState() => _EditorSheetState();
}

class _EditorSheetState extends State<_EditorSheet> {
  late DateTime _at = widget.existing?.at ?? DateTime.now();
  late SugarContext _ctx = widget.existing?.context ?? SugarContext.fasting;
  late final _sys = TextEditingController(text: widget.existing?.systolic?.toString() ?? '');
  late final _dia = TextEditingController(text: widget.existing?.diastolic?.toString() ?? '');
  late final _sugar = TextEditingController(text: widget.existing?.mgdl?.toString() ?? '');
  late final _note = TextEditingController(text: widget.existing?.note ?? '');
  String? _error;

  bool get _isBp => widget.kind == ReadingKind.bloodPressure;

  @override
  void dispose() {
    _sys.dispose();
    _dia.dispose();
    _sugar.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickWhen() async {
    final d = await showDatePicker(
        context: context,
        initialDate: _at,
        firstDate: DateTime.now().subtract(const Duration(days: 365)),
        lastDate: DateTime.now());
    if (d == null || !mounted) return;
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_at));
    if (!mounted) return;
    setState(() => _at = DateTime(d.year, d.month, d.day, t?.hour ?? _at.hour, t?.minute ?? _at.minute));
  }

  void _save() {
    final probe = Reading(
      id: widget.existing?.id ?? 'probe',
      kind: widget.kind,
      at: _at,
      systolic: int.tryParse(_sys.text.trim()),
      diastolic: int.tryParse(_dia.text.trim()),
      mgdl: int.tryParse(_sugar.text.trim()),
    );
    if (!probe.plausible) {
      // Typing hygiene, not a verdict: see ReadingsStore.
      setState(() => _error = _isBp
          ? 'Check the numbers. The top number goes first, and it is larger than the bottom one.'
          : 'Check the number. It is the figure your meter shows, in mg/dL.');
      return;
    }
    if (widget.existing != null) {
      widget.store.update(widget.existing!.copyWith(
        at: _at,
        systolic: probe.systolic,
        diastolic: probe.diastolic,
        mgdl: probe.mgdl,
        context: _isBp ? null : _ctx,
        note: _note.text.trim(),
      ));
    } else {
      widget.store.add(
        kind: widget.kind,
        at: _at,
        systolic: probe.systolic,
        diastolic: probe.diastolic,
        mgdl: probe.mgdl,
        context: _isBp ? null : _ctx,
        note: _note.text,
      );
    }
    Navigator.of(context).pop();
  }

  InputDecoration _dec(String label, {String? suffix}) => InputDecoration(
        labelText: label,
        suffixText: suffix,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: kPvLine)),
        enabledBorder:
            OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: kPvLine)),
        focusedBorder:
            OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: kPvInk, width: 1.5)),
      );

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    final editing = widget.existing != null;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Semantics(
            header: true,
            child: Text(
                editing
                    ? 'Edit this reading'
                    : (_isBp ? 'Add a blood pressure reading' : 'Add a sugar reading'),
                style: pvFraunces(fontSize: 22, fontWeight: FontWeight.w600, color: p.ink1)),
          ),
          const SizedBox(height: 16),
          if (_isBp)
            Row(children: [
              Expanded(
                child: TextField(
                  key: const ValueKey('reading_sys'),
                  controller: _sys,
                  keyboardType: TextInputType.number,
                  decoration: _dec('Top number', suffix: 'mmHg'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  key: const ValueKey('reading_dia'),
                  controller: _dia,
                  keyboardType: TextInputType.number,
                  decoration: _dec('Bottom number', suffix: 'mmHg'),
                ),
              ),
            ])
          else ...[
            TextField(
              key: const ValueKey('reading_sugar'),
              controller: _sugar,
              keyboardType: TextInputType.number,
              decoration: _dec('Sugar', suffix: 'mg/dL'),
            ),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final c in SugarContext.values)
                _Pill(
                  key: ValueKey('reading_ctx_${c.name}'),
                  label: c.label,
                  selected: _ctx == c,
                  onTap: () => setState(() => _ctx = c),
                ),
            ]),
          ],
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(_error!, key: const ValueKey('reading_error'), style: pvManrope(fontSize: 13, color: p.ink2)),
          ],
          const SizedBox(height: 12),
          InkWell(
            key: const ValueKey('reading_when'),
            onTap: _pickWhen,
            borderRadius: BorderRadius.circular(14),
            child: InputDecorator(
              decoration: _dec('When'),
              child: Text('${_day(_at)}, ${_time(_at)}', style: pvManrope(fontSize: 15, color: p.ink1)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const ValueKey('reading_note'),
            controller: _note,
            decoration: _dec('A note for your doctor (optional)'),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 18),
          FilledButton(
            key: const ValueKey('reading_save'),
            style: pregFilledStyle().copyWith(minimumSize: const WidgetStatePropertyAll(Size.fromHeight(48))),
            onPressed: _save,
            child: Text(editing ? 'Save changes' : 'Save reading',
                style: pvManrope(fontSize: 14.5, fontWeight: FontWeight.w700, color: Colors.white)),
          ),
          if (editing) ...[
            const SizedBox(height: 6),
            Center(
              child: TextButton(
                key: const ValueKey('reading_delete'),
                onPressed: () {
                  widget.store.remove(widget.existing!.id);
                  Navigator.of(context).pop();
                },
                child: Text('Delete this reading', style: pvManrope(fontSize: 13.5, color: p.ink2)),
              ),
            ),
          ],
        ]),
      ),
    );
  }
}

// ---- the target sheet --------------------------------------------------------

Future<void> _showTargets(BuildContext context, ReadingsStore store) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: pvStorePalette.ground,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _TargetSheet(store: store),
    );

class _TargetSheet extends StatefulWidget {
  const _TargetSheet({required this.store});
  final ReadingsStore store;

  @override
  State<_TargetSheet> createState() => _TargetSheetState();
}

class _TargetSheetState extends State<_TargetSheet> {
  late final _sys = TextEditingController(text: widget.store.targets.sysUnder?.toString() ?? '');
  late final _dia = TextEditingController(text: widget.store.targets.diaUnder?.toString() ?? '');
  late final _fast = TextEditingController(text: widget.store.targets.fastingUnder?.toString() ?? '');
  late final _after = TextEditingController(text: widget.store.targets.afterFoodUnder?.toString() ?? '');

  @override
  void dispose() {
    _sys.dispose();
    _dia.dispose();
    _fast.dispose();
    _after.dispose();
    super.dispose();
  }

  InputDecoration _dec(String label, String suffix) => InputDecoration(
        labelText: label,
        suffixText: suffix,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: kPvLine)),
        enabledBorder:
            OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: kPvLine)),
        focusedBorder:
            OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: kPvInk, width: 1.5)),
      );

  int? _n(TextEditingController c) => int.tryParse(c.text.trim());

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Semantics(
            header: true,
            child: Text("Your doctor's target",
                style: pvFraunces(fontSize: 22, fontWeight: FontWeight.w600, color: p.ink1)),
          ),
          const SizedBox(height: 6),
          Text(
              'Only if your doctor gave you numbers to aim for. We show them beside your readings as yours, '
              'and never compare your readings to anything of our own.',
              style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink2)),
          const SizedBox(height: 16),
          Text('BLOOD PRESSURE, UNDER',
              style: pvManrope(fontSize: 10.5, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: p.ink3)),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
                child: TextField(
                    key: const ValueKey('target_sys'),
                    controller: _sys,
                    keyboardType: TextInputType.number,
                    decoration: _dec('Top number', ''))),
            const SizedBox(width: 12),
            Expanded(
                child: TextField(
                    key: const ValueKey('target_dia'),
                    controller: _dia,
                    keyboardType: TextInputType.number,
                    decoration: _dec('Bottom number', ''))),
          ]),
          const SizedBox(height: 16),
          Text('BLOOD SUGAR, UNDER',
              style: pvManrope(fontSize: 10.5, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: p.ink3)),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
                child: TextField(
                    key: const ValueKey('target_fasting'),
                    controller: _fast,
                    keyboardType: TextInputType.number,
                    decoration: _dec('Fasting', 'mg/dL'))),
            const SizedBox(width: 12),
            Expanded(
                child: TextField(
                    key: const ValueKey('target_after'),
                    controller: _after,
                    keyboardType: TextInputType.number,
                    decoration: _dec('After food', 'mg/dL'))),
          ]),
          const SizedBox(height: 18),
          FilledButton(
            key: const ValueKey('target_save'),
            style: pregFilledStyle().copyWith(minimumSize: const WidgetStatePropertyAll(Size.fromHeight(48))),
            onPressed: () {
              widget.store.setTargets(ReadingTargets(
                  sysUnder: _n(_sys), diaUnder: _n(_dia), fastingUnder: _n(_fast), afterFoodUnder: _n(_after)));
              Navigator.of(context).pop();
            },
            child: Text('Save',
                style: pvManrope(fontSize: 14.5, fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ]),
      ),
    );
  }
}
