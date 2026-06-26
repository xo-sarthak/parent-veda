// =============================================================================
//  RemindersScreen — customizable local reminders
// -----------------------------------------------------------------------------
//  The mother creates gentle nudges (Kegel session, prenatal vitamin, read to
//  baby, water, or her own) at a time + repeat she chooses. This is the full
//  management UX + persistence; the actual OS notification firing plugs in via
//  NotificationService once flutter_local_notifications is installed.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../localization/app_language.dart';
import '../models/reminder.dart';
import '../services/notification_service.dart';
import '../services/pregnancy_controller.dart';
import '../services/reminder_store.dart';
import '../theme/app_theme.dart';

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
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(title: Text(s.rmdTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showReminderEditor(context, controller),
        icon: const Icon(Icons.add_rounded),
        label: Text(s.rmdAdd),
      ),
      body: AnimatedBuilder(
        animation: store,
        builder: (context, _) {
          final items = store.all;
          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 100),
            children: [
              // Gentle "what this does" note.
              Container(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                decoration: BoxDecoration(
                  color: AppTheme.primary50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(children: [
                  const Icon(Icons.notifications_active_rounded,
                      size: 18, color: AppTheme.primary500),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(s.rmdScheduleNote,
                        style: GoogleFonts.manrope(
                            fontSize: 13,
                            height: 1.4,
                            color: AppTheme.primary800)),
                  ),
                ]),
              ),
              const SizedBox(height: 18),
              if (items.isEmpty)
                _empty(context, s)
              else
                for (final r in items) _reminderCard(context, s, store, r),
              const SizedBox(height: 22),
              // Quick ideas (one-tap add).
              Text(s.rmdSuggestions,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primary900)),
              const SizedBox(height: 10),
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final p in _presets) _presetChip(context, s, store, p),
              ]),
            ],
          );
        },
      ),
    );
  }

  Widget _empty(BuildContext context, S s) => Padding(
        padding: const EdgeInsets.fromLTRB(8, 22, 8, 22),
        child: Column(children: [
          const Icon(Icons.notifications_none_rounded,
              size: 52, color: AppTheme.neutral300),
          const SizedBox(height: 14),
          Text(s.rmdEmpty,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primary900)),
          const SizedBox(height: 6),
          Text(s.rmdEmptySub,
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                  fontSize: 13, height: 1.5, color: AppTheme.neutral600)),
        ]),
      );

  Widget _reminderCard(
      BuildContext context, S s, ReminderStore store, Reminder r) {
    final text = Theme.of(context).textTheme;
    final time = TimeOfDay(hour: r.hour, minute: r.minute).format(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(14, 6, 8, 6),
        onTap: () => showReminderEditor(context, controller, existing: r),
        leading: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppTheme.primary500.withValues(alpha: r.enabled ? 0.12 : 0.06),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(_categoryIcon(r.category),
              size: 22,
              color:
                  r.enabled ? AppTheme.primary500 : AppTheme.neutral400),
        ),
        title: Text(r.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: text.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: r.enabled ? AppTheme.primary900 : AppTheme.neutral500)),
        subtitle: Text('$time · ${_repeatLabel(s, r)}',
            style: text.labelMedium?.copyWith(color: AppTheme.neutral500)),
        trailing: Switch.adaptive(
          value: r.enabled,
          activeThumbColor: AppTheme.primary500,
          onChanged: (_) => store.toggle(r.id),
        ),
      ),
    );
  }

  Widget _presetChip(
      BuildContext context, S s, ReminderStore store, _Preset p) {
    return ActionChip(
      avatar: Icon(_categoryIcon(p.category),
          size: 17, color: AppTheme.primary500),
      label: Text(p.title(s)),
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

  static String _repeatLabel(S s, Reminder r) {
    switch (r.repeat) {
      case ReminderRepeat.once:
        return s.rmdOnce;
      case ReminderRepeat.daily:
        return s.rmdDaily;
      case ReminderRepeat.weekly:
        return '${s.rmdWeekly} · ${s.rmdWeekdayShort(r.weekday)}';
    }
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
  late TimeOfDay _time;
  late ReminderRepeat _repeat;
  late int _weekday;
  late String _category;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _titleCtrl =
        TextEditingController(text: e?.title ?? widget.seedTitle ?? '');
    _time = TimeOfDay(
      hour: e?.hour ?? widget.seedHour ?? 9,
      minute: e?.minute ?? widget.seedMinute ?? 0,
    );
    _repeat = e?.repeat ?? ReminderRepeat.daily;
    _weekday = e?.weekday ?? DateTime.monday;
    _category = e?.category ?? widget.seedCategory ?? 'custom';
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  bool get _canSave => _titleCtrl.text.trim().isNotEmpty;

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  void _save(S s) {
    final t = _titleCtrl.text.trim();
    if (t.isEmpty) return;
    final store = ReminderStore.instance;
    // Ask for notification permission the moment she commits to a reminder.
    NotificationService.instance.requestPermission();
    final id = widget.existing?.id ??
        'rmd_${DateTime.now().microsecondsSinceEpoch}';
    store.upsert(Reminder(
      id: id,
      title: t,
      hour: _time.hour,
      minute: _time.minute,
      repeat: _repeat,
      weekday: _weekday,
      enabled: widget.existing?.enabled ?? true,
      category: _category,
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
            decoration: InputDecoration(
              labelText: s.rmdWhatLabel,
              hintText: s.rmdWhatHint,
              filled: true,
              fillColor: AppTheme.surfaceContainer,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),
          // Time
          _row(
            s.rmdTime,
            OutlinedButton.icon(
              onPressed: _pickTime,
              icon: const Icon(Icons.schedule_rounded, size: 18),
              label: Text(_time.format(context)),
            ),
          ),
          const SizedBox(height: 14),
          // Repeat
          Align(
            alignment: Alignment.centerLeft,
            child: Text(s.rmdRepeat,
                style:
                    text.labelLarge?.copyWith(fontWeight: FontWeight.w800)),
          ),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: [
            _repeatChip(s.rmdOnce, ReminderRepeat.once),
            _repeatChip(s.rmdDaily, ReminderRepeat.daily),
            _repeatChip(s.rmdWeekly, ReminderRepeat.weekly),
          ]),
          if (_repeat == ReminderRepeat.weekly) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(s.rmdOnDay,
                  style:
                      text.labelLarge?.copyWith(fontWeight: FontWeight.w800)),
            ),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (var wd = 1; wd <= 7; wd++)
                ChoiceChip(
                  label: Text(s.rmdWeekdayShort(wd)),
                  selected: _weekday == wd,
                  onSelected: (_) => setState(() => _weekday = wd),
                ),
            ]),
          ],
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _canSave ? () => _save(s) : null,
              style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14)),
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

  Widget _row(String label, Widget trailing) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primary900)),
          trailing,
        ],
      );

  Widget _repeatChip(String label, ReminderRepeat r) => ChoiceChip(
        label: Text(label),
        selected: _repeat == r,
        onSelected: (_) => setState(() => _repeat = r),
      );
}
