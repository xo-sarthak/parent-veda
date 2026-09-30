// =============================================================================
//  RemindersScreen - customizable local reminders
// -----------------------------------------------------------------------------
//  The mother creates gentle nudges (Kegel session, prenatal vitamin, read to
//  baby, water, or her own) at a time + repeat she chooses. This is the full
//  management UX + persistence; the actual OS notification firing plugs in via
//  NotificationService once flutter_local_notifications is installed.
//
//  ⚠️ ONE PARENTVEDA (2026-09-30, the structural restyle). Shaped like trying
//  to conceive's Messages and Appointments (read for shape only, never
//  imported): the serif page title under a back-arrow-only AppBar; the "what
//  this does" banner is a quiet note on the page, not a tinted box; her
//  reminders share one white hairline card, each row leading with a drawn
//  mark (a row opens its editor); "From ParentVeda" and the quick ideas are
//  page sections under the one serif heading; the add button, a selected chip
//  and the save buttons are the one ink.
// =============================================================================

import 'package:flutter/material.dart';

import '../localization/app_language.dart';
import '../models/reminder.dart';
import '../services/notification_service.dart';
import '../services/pregnancy_controller.dart';
import '../services/reminder_store.dart';
import '../theme/app_theme.dart';
import '../theme/pv_fonts.dart';
import 'brackets/hub/hub_intent_art.dart' show IntentMark;
import 'doors/pv_list_row.dart' show PvMarkWell;
import 'pregnancy/preg_chrome.dart';
import 'pregnancy/preg_messages_screen.dart' show PregMessageSwitches;
import 'products/pv_store_chrome.dart' show kPvInk, kPvLine, pvStorePalette;

/// A quick-add suggestion (its title comes from S so it stays bilingual).
typedef _Preset = ({
  String Function(S) title,
  String category,
  int hour,
  int minute,
});

const List<_Preset> _presets = [
  (title: _kegel, category: 'kegel', hour: 9, minute: 0),
  (title: _vitamin, category: 'medication', hour: 9, minute: 0),
  (title: _read, category: 'reads', hour: 20, minute: 0),
  (title: _water, category: 'water', hour: 12, minute: 0),
  (title: _calm, category: 'custom', hour: 7, minute: 30),
];

String _kegel(S s) => s.rmdSugKegel;
String _vitamin(S s) => s.rmdSugVitamin;
String _read(S s) => s.rmdSugRead;
String _water(S s) => s.rmdSugWater;
String _calm(S s) => s.rmdSugCalm;

/// A drawn mark per reminder kind: a row opens its editor, so it leads with a
/// mark, not a line icon (2026-09-30).
IntentMark _categoryMark(String c) => switch (c) {
      'kegel' => IntentMark.lotusMark,
      'medication' => IntentMark.pillMark,
      'reads' => IntentMark.bookMark,
      'water' => IntentMark.dropMark,
      'bag' => IntentMark.bagMark,
      _ => IntentMark.calendarDay,
    };

double _categoryHue(String c) => switch (c) {
      'kegel' => 160,
      'medication' => 344,
      'reads' => 42,
      'water' => 206,
      'bag' => 28,
      _ => 180,
    };

/// A group label inside a form: the small grey caps (was labelLarge / w800).
Widget _groupLabel(String t) => Align(
      alignment: Alignment.centerLeft,
      child: Text(t.toUpperCase(), style: pregGroupLabelStyle()),
    );

/// A form field: white with the hairline, the ink ring when focused. Was a
/// tinted fill (AppTheme.surfaceContainer) with no border, kept for revert.
InputDecoration _fieldDecoration({String? label, String? hint}) {
  OutlineInputBorder b(Color c) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: c));
  return InputDecoration(
    labelText: label,
    hintText: hint,
    filled: true,
    fillColor: Colors.white,
    border: b(kPvLine),
    enabledBorder: b(kPvLine),
    focusedBorder: b(kPvInk),
  );
}

/// The box a dropdown sits in: white with the hairline (was a tinted fill).
BoxDecoration _dropdownBox(double radius) => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: kPvLine),
    );

/// A selected chip is the one ink with white words; the rest white with the
/// hairline. The pregnancy theme alone gives a pale grey selection.
Text _chipText(String label, bool selected) => Text(label,
    style: pvManrope(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: selected ? Colors.white : pvStorePalette.ink1));

BorderSide _chipSide(bool selected) =>
    BorderSide(color: selected ? kPvInk : kPvLine);

ChoiceChip _choiceChip(String label, bool selected, ValueChanged<bool> onSelected) =>
    ChoiceChip(
      label: _chipText(label, selected),
      selected: selected,
      onSelected: onSelected,
      showCheckmark: false,
      selectedColor: kPvInk,
      backgroundColor: Colors.white,
      side: _chipSide(selected),
      shape: const StadiumBorder(),
    );

FilterChip _filterChip(String label, bool selected, ValueChanged<bool> onSelected) =>
    FilterChip(
      label: _chipText(label, selected),
      selected: selected,
      onSelected: onSelected,
      showCheckmark: false,
      selectedColor: kPvInk,
      backgroundColor: Colors.white,
      side: _chipSide(selected),
      shape: const StadiumBorder(),
    );

IconData _categoryIcon(String c) {
  switch (c) {
    case 'kegel':
      return Icons.self_improvement_rounded;
    case 'medication':
      return Icons.medication_rounded;
    case 'reads':
      return Icons.menu_book_rounded;
    case 'water':
      return Icons.local_drink_rounded;
    case 'bag':
      return Icons.luggage_rounded;
    default:
      return Icons.notifications_active_rounded;
  }
}

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key, required this.controller});
  final PregnancyController controller;

  @override
  Widget build(BuildContext context) {
    final s = S(controller.language);
    final store = ReminderStore.instance;
    store.init();
    final pal = pvStorePalette;
    return Scaffold(
      backgroundColor: pal.ground,
      // The AppBar carries the back arrow and the two test controls; the
      // title is the serif on the page. Kept for revert:
      //   backgroundColor: AppTheme.scaffoldBackground,
      //   appBar: AppBar(title: Text(s.rmdTitle), actions: [...]),
      appBar: AppBar(
        backgroundColor: pal.ground,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: pal.ink1,
        actions: [
          IconButton(
            tooltip: S.now.uiSendTestNotificationNow,
            icon: const Icon(Icons.notifications_active_outlined),
            onPressed: () async {
              await NotificationService.instance.requestPermission();
              await NotificationService.instance.showNow();
              if (context.mounted) {
                ScaffoldMessenger.of(context)
                  ..clearSnackBars()
                  ..showSnackBar(SnackBar(
                      content: Text(
                          S.now.uiTestNotificationSentCheck)));
              }
            },
          ),
          IconButton(
            tooltip: S.now.uiScheduleTestMinFrom,
            icon: const Icon(Icons.alarm_add_outlined),
            onPressed: () async {
              await NotificationService.instance.requestPermission();
              // Show what ACTUALLY happened — the scheduled time, or the real
              // error / the "exact alarms are off" warning. A silent failure is
              // how a broken reminder goes unnoticed.
              final result =
                  await NotificationService.instance.scheduleTestIn1Min();
              if (context.mounted) {
                ScaffoldMessenger.of(context)
                  ..clearSnackBars()
                  ..showSnackBar(SnackBar(
                      duration: const Duration(seconds: 8),
                      content: Text(result)));
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showReminderEditor(context, controller),
        backgroundColor: kPvInk,
        foregroundColor: Colors.white,
        elevation: 2,
        highlightElevation: 5,
        shape: const StadiumBorder(),
        icon: const Icon(Icons.add_rounded),
        label: Text(s.rmdAdd,
            style: pvManrope(fontWeight: FontWeight.w700, fontSize: 14.5)),
      ),
      body: AnimatedBuilder(
        animation: store,
        builder: (context, _) {
          final items = store.all;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
            children: [
              Text(s.rmdTitle, style: pregPageTitleStyle()),
              const SizedBox(height: 10),
              // Gentle "what this does" note, on the page. Kept for revert
              // (2026-09-30, no tinted block behind text): a Container in
              // AppTheme.neutral50 with a neutral900 @ 0.12 border, radius 16,
              // Row(Icon(notifications_active_rounded, 18), the text in ink).
              PregNote(s.rmdScheduleNote, icon: Icons.notifications_none_rounded),
              const SizedBox(height: 18),
              // Her reminders share one white card, hairlines between rows.
              // Kept for revert: `for (final r in items) _reminderCard(...)`,
              // a shadowed card each, and `_empty` bare on the page.
              if (items.isEmpty)
                PregCard(child: _empty(context, s))
              else
                PregRowCard(children: [
                  for (final r in items) _reminderRow(context, s, store, r),
                ]),
              // ---- From ParentVeda (2026-09-30) ---------------------------
              // The messages the app sends on its own, from her dates: the
              // new week and the moments that matter. The gap analysis puts
              // their off switches here, beside the reminders she sets.
              // The one section heading (2026-09-30). Kept for revert: a
              // pvJakarta 15 / w800 title, SizedBox(4), the lead in
              // pvManrope 13 neutral600.
              const SizedBox(height: 30),
              const PregSectionHeading('From ParentVeda',
                  lead: 'Notes we send from your dates. Each one opens the page it is about.'),
              const SizedBox(height: 12),
              const PregMessageSwitches(),
              const SizedBox(height: 30),
              // Quick ideas (one-tap add), under the one section heading.
              // Kept for revert: Text(s.rmdSuggestions) in pvJakarta 15 / w800.
              PregSectionHeading(s.rmdSuggestions),
              const SizedBox(height: 12),
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final p in _presets) _presetChip(context, s, store, p),
              ]),
            ],
          );
        },
      ),
    );
  }

  // The empty state, inside the card her reminders will fill: a drawn mark,
  // then the invitation. Kept for revert: Padding(8, 22, 8, 22) with a 52
  // Icon(notifications_none_rounded) in neutral300 and pvJakarta 16 / w800.
  Widget _empty(BuildContext context, S s) {
    final pal = pvStorePalette;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(children: [
        PvMarkWell(p: pal, hue: 180, size: 52, mark: IntentMark.calendarDay),
        const SizedBox(height: 14),
        Text(s.rmdEmpty,
            textAlign: TextAlign.center,
            style: pvManrope(
                fontSize: 15.5, fontWeight: FontWeight.w700, color: pal.ink1)),
        const SizedBox(height: 6),
        Text(s.rmdEmptySub,
            textAlign: TextAlign.center,
            style: pvManrope(fontSize: 13, height: 1.5, color: pal.ink2)),
      ]),
    );
  }

  /// One of her reminders: the kind's drawn mark, the title, how often, and
  /// the switch. A tap opens its editor (medication has the richer one).
  Widget _reminderRow(
      BuildContext context, S s, ReminderStore store, Reminder r) {
    final pal = pvStorePalette;
    // A transparent Material so the press shows on the white card.
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () => r.isMedication
            ? showMedReminderEditor(context, controller, existing: r)
            : showReminderEditor(context, controller, existing: r),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
          child: Row(children: [
            // A reminder that is off keeps its mark, faded.
            Opacity(
              opacity: r.enabled ? 1 : 0.45,
              child: PvMarkWell(
                  p: pal,
                  hue: _categoryHue(r.category),
                  size: 44,
                  mark: _categoryMark(r.category)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(r.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: pvManrope(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                        color: r.enabled ? pal.ink1 : pal.ink3)),
                const SizedBox(height: 2),
                Text(reminderSummary(s, r, context),
                    style: pvManrope(fontSize: 12.5, height: 1.35, color: pal.ink3)),
              ]),
            ),
            const SizedBox(width: 4),
            Switch(
              value: r.enabled,
              onChanged: (_) => store.toggle(r.id),
              trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
            ),
          ]),
        ),
      ),
    );
  }

  // Superseded by [_reminderRow] inside a [PregRowCard] (2026-09-30); kept
  // for revert.
  // ignore: unused_element
  Widget _reminderCard(
      BuildContext context, S s, ReminderStore store, Reminder r) {
    final text = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: r.enabled
                ? AppTheme.neutral900.withValues(alpha: 0.20)
                : AppTheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: AppTheme.neutral900.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(14, 6, 8, 6),
        // Medication reminders use the richer multi-time editor; others the
        // simple one.
        onTap: () => r.isMedication
            ? showMedReminderEditor(context, controller, existing: r)
            : showReminderEditor(context, controller, existing: r),
        leading: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppTheme.neutral900.withValues(alpha: r.enabled ? 0.12 : 0.06),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(_categoryIcon(r.category),
              size: 22,
              color:
                  r.enabled ? AppTheme.neutral900 : AppTheme.neutral400),
        ),
        title: Text(r.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: text.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: r.enabled ? AppTheme.neutral900 : AppTheme.neutral500)),
        subtitle: Text(reminderSummary(s, r, context),
            style: text.labelMedium?.copyWith(color: AppTheme.neutral500)),
        trailing: Switch(
          value: r.enabled,
          onChanged: (_) => store.toggle(r.id),
          // Kept for revert (2026-09-28, one black switch app-wide): activeThumbColor: Colors.white,
          // Kept for revert (2026-09-28, one black switch app-wide): activeTrackColor: AppTheme.neutral900,
          // Kept for revert (2026-09-28, one black switch app-wide): inactiveThumbColor: Colors.white,
          // Kept for revert (2026-09-28, one black switch app-wide): inactiveTrackColor: AppTheme.neutral300,
          trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
        ),
      ),
    );
  }

  Widget _presetChip(
      BuildContext context, S s, ReminderStore store, _Preset p) {
    // White with the hairline, ink words (2026-09-30).
    return ActionChip(
      avatar: Icon(_categoryIcon(p.category), size: 17, color: kPvInk),
      label: Text(p.title(s),
          style: pvManrope(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: pvStorePalette.ink1)),
      backgroundColor: Colors.white,
      side: const BorderSide(color: kPvLine),
      shape: const StadiumBorder(),
      onPressed: () => showReminderEditor(
        context,
        controller,
        seedTitle: p.title(s),
        seedCategory: p.category,
        seedHour: p.hour,
        seedMinute: p.minute,
      ),
    );
  }

}

/// A human-readable "how often + when" summary for any reminder, handling
/// multi-time daily, weekly, fortnightly, monthly and specific-weekday cadences.
String reminderSummary(S s, Reminder r, BuildContext context) {
  String fmt(int mins) =>
      TimeOfDay(hour: mins ~/ 60, minute: mins % 60).format(context);
  switch (r.repeat) {
    case ReminderRepeat.once:
      return '${s.rmdOnce} · ${fmt(r.hour * 60 + r.minute)}';
    case ReminderRepeat.daily:
      final ts = r.effectiveTimes;
      if (ts.length <= 1) return '${s.rmdDaily} · ${fmt(ts.first)}';
      return '${s.mrTimesPerDay(ts.length)} · ${ts.map(fmt).join(', ')}';
    case ReminderRepeat.weekly:
      return '${s.rmdWeekly} · ${s.rmdWeekdayShort(r.weekday)} · ${fmt(r.hour * 60 + r.minute)}';
    case ReminderRepeat.fortnightly:
      return '${s.rmdFortnightly} · ${s.rmdWeekdayShort(r.weekday)} · ${fmt(r.hour * 60 + r.minute)}';
    case ReminderRepeat.monthly:
      return '${s.rmdMonthly} · ${s.mrDayOfMonth} ${r.dayOfMonth} · ${fmt(r.hour * 60 + r.minute)}';
    case ReminderRepeat.customDays:
      final ts = r.effectiveTimes;
      return '${r.effectiveWeekdays.map(s.rmdWeekdayShort).join(', ')} · ${ts.map(fmt).join(', ')}';
  }
}

/// Opens the create/edit sheet. Pass [existing] to edit, or seed values to
/// pre-fill a new one (used by the quick-idea chips).
Future<void> showReminderEditor(
  BuildContext context,
  PregnancyController controller, {
  Reminder? existing,
  String? seedTitle,
  String? seedCategory,
  int? seedHour,
  int? seedMinute,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppTheme.surface,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
    builder: (ctx) => _ReminderEditor(
      controller: controller,
      existing: existing,
      seedTitle: seedTitle,
      seedCategory: seedCategory,
      seedHour: seedHour,
      seedMinute: seedMinute,
    ),
  );
}

class _ReminderEditor extends StatefulWidget {
  const _ReminderEditor({
    required this.controller,
    this.existing,
    this.seedTitle,
    this.seedCategory,
    this.seedHour,
    this.seedMinute,
  });
  final PregnancyController controller;
  final Reminder? existing;
  final String? seedTitle;
  final String? seedCategory;
  final int? seedHour;
  final int? seedMinute;

  @override
  State<_ReminderEditor> createState() => _ReminderEditorState();
}

class _ReminderEditorState extends State<_ReminderEditor> {
  late final TextEditingController _titleCtrl;
  late List<TimeOfDay> _times; // one or more times-of-day (daily & custom)
  late ReminderRepeat _repeat;
  late int _weekday; // single weekday (weekly)
  late Set<int> _weekdays; // multi-select weekdays (custom)
  late String _category;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _titleCtrl =
        TextEditingController(text: e?.title ?? widget.seedTitle ?? '');
    final ts = (e?.effectiveTimes ??
            [(widget.seedHour ?? 9) * 60 + (widget.seedMinute ?? 0)])
        .map((m) => TimeOfDay(hour: m ~/ 60, minute: m % 60))
        .toList();
    _times = ts.isEmpty
        ? [TimeOfDay(hour: widget.seedHour ?? 9, minute: widget.seedMinute ?? 0)]
        : ts;
    _repeat = e?.repeat ?? ReminderRepeat.daily;
    _weekday = e?.weekday ?? DateTime.monday;
    _weekdays = (e != null && e.weekdays.isNotEmpty)
        ? e.weekdays.toSet()
        : {DateTime.monday};
    _category = e?.category ?? widget.seedCategory ?? 'custom';
  }

  /// Multiple times only make sense for cadences that fire repeatedly at each
  /// time-of-day (daily & specific-days). Once/weekly fire at a single time.
  bool get _multiTime =>
      _repeat == ReminderRepeat.daily ||
      _repeat == ReminderRepeat.customDays;

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  bool get _canSave => _titleCtrl.text.trim().isNotEmpty;

  Future<void> _pickTimeAt(int i) async {
    final picked =
        await showTimePicker(context: context, initialTime: _times[i]);
    if (picked != null) setState(() => _times[i] = picked);
  }

  void _addTime() =>
      setState(() => _times.add(const TimeOfDay(hour: 18, minute: 0)));

  void _removeTime(int i) {
    if (_times.length > 1) setState(() => _times.removeAt(i));
  }

  void _save(S s) {
    final t = _titleCtrl.text.trim();
    if (t.isEmpty) return;
    final store = ReminderStore.instance;
    // Ask for notification permission the moment she commits to a reminder.
    NotificationService.instance.requestPermission();
    final id = widget.existing?.id ??
        'rmd_${DateTime.now().microsecondsSinceEpoch}';
    // Only daily & custom keep every time; once/weekly collapse to the first.
    final useTimes = _multiTime ? _times : [_times.first];
    final mins = useTimes.map((x) => x.hour * 60 + x.minute).toList();
    final first = useTimes.first;
    final weekdays =
        (_weekdays.isEmpty ? {DateTime.monday} : _weekdays).toList()..sort();
    store.upsert(Reminder(
      id: id,
      title: t,
      hour: first.hour,
      minute: first.minute,
      repeat: _repeat,
      weekday: _weekday,
      enabled: widget.existing?.enabled ?? true,
      category: _category,
      times: mins,
      weekdays:
          _repeat == ReminderRepeat.customDays ? weekdays : const [],
    ));
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(s.rmdSaved)));
  }

  void _delete(S s) {
    final id = widget.existing?.id;
    if (id != null) ReminderStore.instance.remove(id);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(s.rmdRemoved)));
  }

  @override
  Widget build(BuildContext context) {
    final s = S(widget.controller.language);
    final text = Theme.of(context).textTheme;
    final editing = widget.existing != null;
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 8, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Center(
            child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                    color: AppTheme.neutral300,
                    borderRadius: BorderRadius.circular(99))),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(editing ? s.rmdEditTitle : s.rmdNew,
                style: text.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800)),
          ),
          const SizedBox(height: 16),
          // Title
          TextField(
            controller: _titleCtrl,
            autofocus: !editing,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (_) => setState(() {}),
            decoration: _fieldDecoration(label: s.rmdWhatLabel, hint: s.rmdWhatHint),
          ),
          const SizedBox(height: 16),
          // Repeat (Once / Daily / Weekly / Custom-specific-days)
          _groupLabel(s.rmdRepeat),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            _repeatChip(s.rmdOnce, ReminderRepeat.once),
            _repeatChip(s.rmdDaily, ReminderRepeat.daily),
            _repeatChip(s.rmdWeekly, ReminderRepeat.weekly),
            _repeatChip(s.rmdCustomDays, ReminderRepeat.customDays),
          ]),
          const SizedBox(height: 14),
          // Time(s) - single for once/weekly; add/remove list for daily & custom.
          _groupLabel(_multiTime ? s.mrTimes : s.rmdTime),
          const SizedBox(height: 8),
          for (var i = 0; i < (_multiTime ? _times.length : 1); i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickTimeAt(i),
                    icon: const Icon(Icons.schedule_rounded, size: 18),
                    label: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(_times[i].format(context)),
                    ),
                  ),
                ),
                if (_multiTime && _times.length > 1)
                  IconButton(
                    tooltip: MaterialLocalizations.of(context)
                        .deleteButtonTooltip,
                    icon: const Icon(Icons.close_rounded, size: 18),
                    color: AppTheme.neutral500,
                    onPressed: () => _removeTime(i),
                  ),
              ]),
            ),
          if (_multiTime)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _addTime,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(s.rmdAddTime),
              ),
            ),
          // Single weekday (weekly)
          if (_repeat == ReminderRepeat.weekly) ...[
            const SizedBox(height: 12),
            _groupLabel(s.rmdOnDay),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (var wd = 1; wd <= 7; wd++)
                _choiceChip(s.rmdWeekdayShort(wd), _weekday == wd,
                    (_) => setState(() => _weekday = wd)),
            ]),
          ],
          // Multi-select weekdays (custom / specific days)
          if (_repeat == ReminderRepeat.customDays) ...[
            const SizedBox(height: 12),
            _groupLabel(s.mrOnDays),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (var wd = 1; wd <= 7; wd++)
                _filterChip(s.rmdWeekdayShort(wd), _weekdays.contains(wd),
                    (sel) => setState(() {
                          if (sel) {
                            _weekdays.add(wd);
                          } else if (_weekdays.length > 1) {
                            _weekdays.remove(wd);
                          }
                        })),
            ]),
          ],
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _canSave ? () => _save(s) : null,
              style: pregFilledStyle().copyWith(
                  padding: const WidgetStatePropertyAll(
                      EdgeInsets.symmetric(vertical: 14))),
              child: Text(s.rmdSave,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w800)),
            ),
          ),
          if (editing) ...[
            const SizedBox(height: 6),
            TextButton.icon(
              onPressed: () => _delete(s),
              icon: const Icon(Icons.delete_outline_rounded,
                  size: 18, color: AppTheme.secondary600),
              label: Text(s.rmdDelete,
                  style: const TextStyle(color: AppTheme.secondary600)),
            ),
          ],
        ]),
      ),
    );
  }

  // Formerly used for the single Time row; the multi-time list is now inline.
  // Kept (commented) in case a label+trailing row is needed again.
  // Widget _row(String label, Widget trailing) => Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         Text(label,
  //             style: pvJakarta(
  //                 fontSize: 14,
  //                 fontWeight: FontWeight.w800,
  //                 color: AppTheme.neutral900)),
  //         trailing,
  //       ],
  //     );

  Widget _repeatChip(String label, ReminderRepeat r) =>
      _choiceChip(label, _repeat == r, (_) => setState(() => _repeat = r));
}

// =============================================================================
//  Medication reminders - a richer editor (frequency + multiple times + custom
//  cadences) used by the Daily Medication card. Deliberately NOT tied to any
//  medicine: she just sets when to be pinged + a note.
// =============================================================================

enum _MedFreq { once, twice, thrice, weekly, fortnightly, monthly, custom }

int _timeCountFor(_MedFreq f) => switch (f) {
      _MedFreq.twice => 2,
      _MedFreq.thrice => 3,
      _ => 1, // weekly / fortnightly / monthly / custom all use a single time
    };

List<TimeOfDay> _defaultTimes(int n) => switch (n) {
      3 => const [
          TimeOfDay(hour: 8, minute: 0),
          TimeOfDay(hour: 14, minute: 0),
          TimeOfDay(hour: 20, minute: 0),
        ],
      2 => const [TimeOfDay(hour: 9, minute: 0), TimeOfDay(hour: 21, minute: 0)],
      _ => const [TimeOfDay(hour: 9, minute: 0)],
    };

/// Opens the medication-reminder create/edit sheet.
Future<void> showMedReminderEditor(
  BuildContext context,
  PregnancyController controller, {
  Reminder? existing,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppTheme.surface,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
    builder: (ctx) =>
        _MedReminderEditor(controller: controller, existing: existing),
  );
}

class _MedReminderEditor extends StatefulWidget {
  const _MedReminderEditor({required this.controller, this.existing});
  final PregnancyController controller;
  final Reminder? existing;
  @override
  State<_MedReminderEditor> createState() => _MedReminderEditorState();
}

class _MedReminderEditorState extends State<_MedReminderEditor> {
  late _MedFreq _freq;
  late List<TimeOfDay> _times; // [0] also used by the single-time cadences
  late int _weekday;
  late int _dayOfMonth;
  late Set<int> _weekdays;
  late final TextEditingController _noteCtrl;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _freq = _freqFromReminder(e);
    final ts = (e?.effectiveTimes ?? const [540]) // 540 = 9:00
        .map((m) => TimeOfDay(hour: m ~/ 60, minute: m % 60))
        .toList();
    _times = ts.isEmpty ? _defaultTimes(1) : ts;
    _weekday = e?.weekday ?? DateTime.monday;
    _dayOfMonth = (e?.dayOfMonth ?? 1).clamp(1, 28);
    _weekdays = (e != null && e.weekdays.isNotEmpty)
        ? e.weekdays.toSet()
        : {DateTime.monday};
    final def = S(widget.controller.language).mrDefaultTitle;
    _noteCtrl = TextEditingController(
        text: (e != null && e.title != def) ? e.title : '');
  }

  static _MedFreq _freqFromReminder(Reminder? e) {
    if (e == null) return _MedFreq.once;
    switch (e.repeat) {
      case ReminderRepeat.daily:
        final n = e.effectiveTimes.length;
        return n >= 3
            ? _MedFreq.thrice
            : (n == 2 ? _MedFreq.twice : _MedFreq.once);
      case ReminderRepeat.weekly:
        return _MedFreq.weekly;
      case ReminderRepeat.fortnightly:
        return _MedFreq.fortnightly;
      case ReminderRepeat.monthly:
        return _MedFreq.monthly;
      case ReminderRepeat.customDays:
        return _MedFreq.custom;
      case ReminderRepeat.once:
        return _MedFreq.once;
    }
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  void _setFreq(_MedFreq f) {
    setState(() {
      _freq = f;
      final need = _timeCountFor(f);
      if (_times.length != need) {
        // Keep her first time where sensible, fill the rest with defaults.
        final defaults = _defaultTimes(need);
        _times = [
          for (var i = 0; i < need; i++)
            i < _times.length ? _times[i] : defaults[i]
        ];
      }
    });
  }

  Future<void> _pickTime(int i) async {
    final picked =
        await showTimePicker(context: context, initialTime: _times[i]);
    if (picked != null) setState(() => _times[i] = picked);
  }

  String _freqLabel(S s, _MedFreq f) => switch (f) {
        _MedFreq.once => s.mrFreqOnce,
        _MedFreq.twice => s.mrFreqTwice,
        _MedFreq.thrice => s.mrFreqThrice,
        _MedFreq.weekly => s.mrFreqWeekly,
        _MedFreq.fortnightly => s.mrFreqFortnightly,
        _MedFreq.monthly => s.mrFreqMonthly,
        _MedFreq.custom => s.mrFreqCustom,
      };

  void _save(S s) {
    final store = ReminderStore.instance;
    NotificationService.instance.requestPermission();
    final note = _noteCtrl.text.trim();
    final title = note.isEmpty ? s.mrDefaultTitle : note;
    final id = widget.existing?.id ??
        'medrmd_${DateTime.now().microsecondsSinceEpoch}';
    final first = _times.first;
    final enabled = widget.existing?.enabled ?? true;
    final base = Reminder(
      id: id,
      title: title,
      hour: first.hour,
      minute: first.minute,
      category: 'medication',
      enabled: enabled,
    );
    final Reminder r;
    switch (_freq) {
      case _MedFreq.once:
      case _MedFreq.twice:
      case _MedFreq.thrice:
        r = base.copyWith(
          repeat: ReminderRepeat.daily,
          times: _times.map((t) => t.hour * 60 + t.minute).toList(),
        );
        break;
      case _MedFreq.weekly:
        r = base.copyWith(repeat: ReminderRepeat.weekly, weekday: _weekday);
        break;
      case _MedFreq.fortnightly:
        r = base.copyWith(
            repeat: ReminderRepeat.fortnightly, weekday: _weekday);
        break;
      case _MedFreq.monthly:
        r = base.copyWith(
            repeat: ReminderRepeat.monthly, dayOfMonth: _dayOfMonth);
        break;
      case _MedFreq.custom:
        final wds = (_weekdays.isEmpty ? {DateTime.monday} : _weekdays).toList()
          ..sort();
        r = base.copyWith(repeat: ReminderRepeat.customDays, weekdays: wds);
        break;
    }
    store.upsert(r);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(s.mrSaved)));
  }

  @override
  Widget build(BuildContext context) {
    final s = S(widget.controller.language);
    final text = Theme.of(context).textTheme;
    final editing = widget.existing != null;
    final isDailyN = _freq == _MedFreq.once ||
        _freq == _MedFreq.twice ||
        _freq == _MedFreq.thrice;
    final needsWeekday =
        _freq == _MedFreq.weekly || _freq == _MedFreq.fortnightly;
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 8, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Center(
            child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                    color: AppTheme.neutral300,
                    borderRadius: BorderRadius.circular(99))),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(editing ? s.mrEdit : s.mrNew,
                style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
          ),
          const SizedBox(height: 16),
          // Frequency
          _groupLabel(s.mrFreq),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: _dropdownBox(14),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<_MedFreq>(
                isExpanded: true,
                value: _freq,
                items: [
                  for (final f in _MedFreq.values)
                    DropdownMenuItem(value: f, child: Text(_freqLabel(s, f))),
                ],
                onChanged: (f) => f == null ? null : _setFreq(f),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Times (one per occurrence for daily-N; a single time otherwise)
          if (isDailyN) ...[
            _groupLabel(s.mrTimes),
            const SizedBox(height: 8),
            for (var i = 0; i < _times.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _row(
                  s.mrTimeN(i + 1),
                  OutlinedButton.icon(
                    onPressed: () => _pickTime(i),
                    icon: const Icon(Icons.schedule_rounded, size: 18),
                    label: Text(_times[i].format(context)),
                  ),
                ),
              ),
          ] else
            _row(
              s.rmdTime,
              OutlinedButton.icon(
                onPressed: () => _pickTime(0),
                icon: const Icon(Icons.schedule_rounded, size: 18),
                label: Text(_times.first.format(context)),
              ),
            ),
          // Weekday (weekly / fortnightly - single)
          if (needsWeekday) ...[
            const SizedBox(height: 12),
            _groupLabel(s.rmdOnDay),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (var wd = 1; wd <= 7; wd++)
                _choiceChip(s.rmdWeekdayShort(wd), _weekday == wd,
                    (_) => setState(() => _weekday = wd)),
            ]),
          ],
          // Specific weekdays (custom - multi)
          if (_freq == _MedFreq.custom) ...[
            const SizedBox(height: 12),
            _groupLabel(s.mrOnDays),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (var wd = 1; wd <= 7; wd++)
                _filterChip(s.rmdWeekdayShort(wd), _weekdays.contains(wd),
                    (sel) => setState(() {
                          if (sel) {
                            _weekdays.add(wd);
                          } else if (_weekdays.length > 1) {
                            _weekdays.remove(wd);
                          }
                        })),
            ]),
          ],
          // Day of month (monthly)
          if (_freq == _MedFreq.monthly) ...[
            const SizedBox(height: 12),
            _row(
              s.mrDayOfMonth,
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: _dropdownBox(12),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _dayOfMonth,
                    items: [
                      for (var d = 1; d <= 28; d++)
                        DropdownMenuItem(value: d, child: Text('$d')),
                    ],
                    onChanged: (d) =>
                        d == null ? null : setState(() => _dayOfMonth = d),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          // Note
          TextField(
            controller: _noteCtrl,
            textCapitalization: TextCapitalization.sentences,
            maxLines: 2,
            minLines: 1,
            decoration: _fieldDecoration(label: s.mrNote, hint: s.mrNoteHint),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => _save(s),
              style: pregFilledStyle().copyWith(
                  padding: const WidgetStatePropertyAll(
                      EdgeInsets.symmetric(vertical: 14))),
              child: Text(s.mrSave,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w800)),
            ),
          ),
          if (editing) ...[
            const SizedBox(height: 6),
            TextButton.icon(
              onPressed: () {
                ReminderStore.instance.remove(widget.existing!.id);
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.delete_outline_rounded,
                  size: 18, color: AppTheme.secondary600),
              label: Text(s.mrDelete,
                  style: const TextStyle(color: AppTheme.secondary600)),
            ),
          ],
        ]),
      ),
    );
  }

  Widget _row(String label, Widget trailing) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(label,
                style: pvJakarta(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.neutral900)),
          ),
          trailing,
        ],
      );
}
