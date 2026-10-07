// =============================================================================
//  The parts every parenting care log shares (2026-10-07)
// -----------------------------------------------------------------------------
//  Nappies, pumping, the breastfeed timer, tummy time and the history page are
//  built from these, on the tool shell pregnancy and TTC use
//  (`PregToolScaffold`), so the five read as one family and as ParentVeda.
//
//  Mobbin, for each part:
//    * STATS: Google Health's "1,213 cal per day (avg)" and Oura's single
//      numeral: a plain label and a large ink number on white, no tinted slab
//      behind it (the one-ParentVeda rule: "Stats = plain label + large value
//      on white").
//      https://mobbin.com/screens/87da4565-88e3-4345-9001-744c9dafab89
//    * THE LOG SHEET: Google Health's "Add blood glucose" (value, then Date and
//      Time rows that default to now and can be changed, choice chips, one Save
//      at the foot) and Noom's chip choices. The time row is the gap analysis's
//      "a time picker defaulting to now so a missed feed can be entered".
//      https://mobbin.com/screens/eace5a19-59f0-4a59-9222-8234ae6fa755
//      https://mobbin.com/screens/f5f057c4-65ea-454e-9f3a-bb22ad6926af
//    * THE WEEK: Google Health's week of bars under the average, today picked
//      out, and the day rows under it; Lloyds' calm two-colour bars.
//      https://mobbin.com/screens/f06acbc4-ffaa-4b40-8e2c-464e80f3e53c
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../../widgets/pv_feedback.dart';
import '../products/pv_store_chrome.dart' show PvChip, PvCommit, pvStorePalette;
import '../v2/v2_palette.dart';

const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

/// "9:41 am".
String ppCareClock(DateTime t) {
  var h = t.hour % 12;
  if (h == 0) h = 12;
  return '$h:${t.minute.toString().padLeft(2, '0')} ${t.hour < 12 ? 'am' : 'pm'}';
}

/// "Today, 9:41 am" / "Yesterday, 11:05 pm" / "3 Oct, 6:10 am".
String ppCareWhen(DateTime t, {DateTime? now}) {
  final n = now ?? DateTime.now();
  final today = DateTime(n.year, n.month, n.day);
  final d = DateTime(t.year, t.month, t.day);
  final day = d == today
      ? 'Today'
      : d == today.subtract(const Duration(days: 1))
          ? 'Yesterday'
          : '${t.day} ${_months[t.month - 1]}';
  return '$day, ${ppCareClock(t)}';
}

/// "2h 10m ago", "just now".
String ppCareAgo(DateTime t, {DateTime? now}) {
  final diff = (now ?? DateTime.now()).difference(t);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) {
    final m = diff.inMinutes % 60;
    return m == 0 ? '${diff.inHours}h ago' : '${diff.inHours}h ${m}m ago';
  }
  return diff.inDays == 1 ? 'yesterday' : '${diff.inDays} days ago';
}

/// "12:05" for a running clock, "1:02:05" past an hour.
String ppCareTimer(int seconds) {
  final h = seconds ~/ 3600;
  final m = (seconds % 3600) ~/ 60;
  final s = seconds % 60;
  final mm = m.toString().padLeft(h > 0 ? 2 : 1, '0');
  return h > 0 ? '$h:$mm:${s.toString().padLeft(2, '0')}' : '$mm:${s.toString().padLeft(2, '0')}';
}

/// Plain numbers on white: a large ink value over a small label, side by side,
/// stacked one per line at large text so nothing squeezes.
class PpCareStats extends StatelessWidget {
  const PpCareStats(this.stats, {super.key});
  final List<(String value, String label)> stats;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final big = MediaQuery.textScalerOf(context).scale(10) > 12.5;
    Widget one((String, String) s) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(s.$1,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: pvFraunces(fontSize: 28, fontWeight: FontWeight.w600, height: 1.05, color: p.ink1)),
            const SizedBox(height: 4),
            Text(s.$2, maxLines: 2, style: pvManrope(fontSize: 12.5, height: 1.3, color: p.ink2)),
          ],
        );
    if (big) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        for (final s in stats) Padding(padding: const EdgeInsets.only(bottom: 12), child: one(s)),
      ]);
    }
    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        for (var i = 0; i < stats.length; i++) ...[
          if (i > 0) ...[
            const SizedBox(width: 12),
            VerticalDivider(width: 1, thickness: 1, color: p.line),
            const SizedBox(width: 12),
          ],
          Expanded(child: one(stats[i])),
        ],
      ]),
    );
  }
}

/// The "When" row of a log sheet: the time, defaulting to now, and a way to
/// change it so a feed she forgot to log at 3 am can be put in at 7.
class PpWhenRow extends StatelessWidget {
  const PpWhenRow({super.key, required this.when, required this.onChanged});
  final DateTime when;
  final ValueChanged<DateTime> onChanged;

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final day = await showDatePicker(
      context: context,
      initialDate: when,
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now,
    );
    if (day == null || !context.mounted) return;
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(when));
    if (t == null) return;
    var picked = DateTime(day.year, day.month, day.day, t.hour, t.minute);
    if (picked.isAfter(now)) picked = now;
    onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return InkWell(
      key: const ValueKey('pp_care_when'),
      onTap: () => _pick(context),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: p.line),
        ),
        child: Row(children: [
          Icon(Icons.schedule_rounded, size: 20, color: p.ink2),
          const SizedBox(width: 10),
          Expanded(
            child: Text(ppCareWhen(when),
                style: pvManrope(fontSize: 15, fontWeight: FontWeight.w600, color: p.ink1)),
          ),
          Text('Change', style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w700, color: p.ink1)),
          Icon(Icons.chevron_right_rounded, size: 20, color: p.ink2),
        ]),
      ),
    );
  }
}

/// A small caps label over a field in a sheet.
Widget ppCareLabel(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: pvManrope(
              fontSize: 13, fontWeight: FontWeight.w700, color: V2PaletteStore.instance.current.ink2)),
    );

/// One-choice chips (the shared store chip: ink when chosen).
Widget ppCareChoices<T>({
  required List<T> values,
  required T? selected,
  required String Function(T) label,
  required ValueChanged<T?> onPick,
  bool allowNone = false,
  String keyPrefix = 'pp_care_choice',
}) =>
    Wrap(spacing: 8, runSpacing: 8, children: [
      for (final v in values)
        KeyedSubtree(
          key: ValueKey('${keyPrefix}_$v'),
          child: PvChip(
            label: label(v),
            selected: v == selected,
            onTap: () => onPick(allowNone && v == selected ? null : v),
          ),
        ),
    ]);

/// The log sheet: title, the fields, one ink Save pinned at the foot.
Future<void> showPpCareSheet(
  BuildContext context, {
  required String title,
  required List<Widget> Function(StateSetter setSheet) body,
  required VoidCallback onSave,
  String saveLabel = 'Save',
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSheet) {
        final p = pvStorePalette;
        return SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.88),
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 6),
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(color: p.line, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 8, 4),
                  child: Row(children: [
                    Expanded(
                      child: Text(title,
                          style: pvFraunces(fontSize: 22, fontWeight: FontWeight.w600, height: 1.2, color: p.ink1)),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      icon: Icon(Icons.close_rounded, color: p.ink1),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ]),
                ),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                    children: body(setSheet),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                  child: PvCommit(
                    key: const ValueKey('pp_care_save'),
                    label: saveLabel,
                    onTap: () {
                      pvCommitFeedback();
                      onSave();
                      Navigator.of(ctx).pop();
                    },
                  ),
                ),
              ]),
            ),
          ),
        );
      },
    ),
  );
}

/// The last seven days as bars, with the average of the days she logged.
///
/// ⚠️ THE AVERAGE IS OVER LOGGED DAYS ONLY. A day with nothing logged is a day
/// she did not log, not a day with no feeds; counting it as zero would tell
/// her the baby ate less on the days she was too tired to tap.
class PpWeekBars extends StatelessWidget {
  const PpWeekBars({
    super.key,
    required this.values,
    required this.unit,
    this.format,
    this.now,
  });

  /// Oldest first, today last.
  final List<int> values;

  /// "feeds", "wet nappies", "ml", "min".
  final String unit;
  final String Function(int)? format;
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final logged = values.where((v) => v > 0).toList();
    final avg = logged.isEmpty ? 0 : (logged.reduce((a, b) => a + b) / logged.length).round();
    final top = values.fold<int>(1, (m, v) => v > m ? v : m);
    final n = now ?? DateTime.now();
    const letters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final fmt = format ?? (int v) => '$v';
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(logged.isEmpty ? 'Nothing logged this week' : '${fmt(avg)} $unit a day',
          key: const ValueKey('pp_week_avg'),
          style: pvFraunces(fontSize: 24, fontWeight: FontWeight.w600, height: 1.15, color: p.ink1)),
      const SizedBox(height: 4),
      Text(
          logged.isEmpty
              ? 'Log a few days and the week shows here.'
              : 'Average of the ${logged.length} ${logged.length == 1 ? 'day' : 'days'} you logged',
          style: pvManrope(fontSize: 12.5, color: p.ink2)),
      const SizedBox(height: 14),
      SizedBox(
        height: 110,
        child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          for (var i = 0; i < values.length; i++)
            Expanded(
              child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                if (values[i] > 0)
                  Text(fmt(values[i]),
                      maxLines: 1,
                      textScaler: TextScaler.noScaling,
                      style: pvManrope(fontSize: 10.5, fontWeight: FontWeight.w700, color: p.ink2)),
                const SizedBox(height: 3),
                Container(
                  height: values[i] == 0 ? 3 : (60 * values[i] / top).clamp(6, 60).toDouble(),
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: i == values.length - 1 ? p.ink1 : p.ink1.withValues(alpha: values[i] == 0 ? 0.12 : 0.32),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Text(letters[n.subtract(Duration(days: values.length - 1 - i)).weekday - 1],
                    textScaler: TextScaler.noScaling,
                    style: pvManrope(
                        fontSize: 11,
                        fontWeight: i == values.length - 1 ? FontWeight.w800 : FontWeight.w600,
                        color: i == values.length - 1 ? p.ink1 : p.ink3)),
              ]),
            ),
        ]),
      ),
    ]);
  }
}

/// One logged entry: what, the detail line, when, and a quiet remove that can
/// be undone (TTC's logger: the snackbar says what happened and offers Undo).
class PpCareEntryRow extends StatelessWidget {
  const PpCareEntryRow({
    super.key,
    required this.title,
    required this.when,
    required this.onRemove,
    this.detail,
  });
  final String title;
  final DateTime when;
  final String? detail;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: p.line))),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: 74,
          child: Text(ppCareClock(when),
              style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w700, color: p.ink2)),
        ),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: pvManrope(fontSize: 15, fontWeight: FontWeight.w700, color: p.ink1)),
            if (detail != null && detail!.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(detail!, style: pvManrope(fontSize: 13, height: 1.4, color: p.ink2)),
            ],
          ]),
        ),
        IconButton(
          tooltip: 'Remove',
          visualDensity: VisualDensity.compact,
          icon: Icon(Icons.delete_outline_rounded, size: 20, color: p.ink2),
          onPressed: onRemove,
        ),
      ]),
    );
  }
}

/// The confirmation after a log: names what was saved (the app explains
/// itself), with Undo where it can be taken back.
void ppCareSaved(BuildContext context, String what, {VoidCallback? undo}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text(what),
      action: undo == null ? null : SnackBarAction(label: 'Undo', onPressed: undo),
    ));
}

/// A serif section heading inside a tool page.
Widget ppCareHeading(String text) => Text(text,
    style: pvFraunces(
        fontSize: 20, fontWeight: FontWeight.w600, height: 1.2, color: V2PaletteStore.instance.current.ink1));

/// A question row that opens Ask Veda. Its own `Material`, so the ripple shows
/// on the tool sheet's ground (a bare ListTile there paints its ink underneath).
class PpCareQuestionRow extends StatelessWidget {
  const PpCareQuestionRow({super.key, required this.question, required this.onTap});
  final String question;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () {
          pvCommitFeedback();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: p.line))),
          child: Row(children: [
            Expanded(
              child: Text(question,
                  style: pvManrope(fontSize: 14.5, fontWeight: FontWeight.w600, height: 1.4, color: p.ink1)),
            ),
            Icon(Icons.chevron_right_rounded, size: 20, color: p.ink2),
          ]),
        ),
      ),
    );
  }
}

/// A note on any log entry (gap analysis P2, What to Expect's "Take notes",
/// 2026-10-07): optional, one or two lines, saved with the entry.
Widget ppCareNoteField(TextEditingController c, {String hint = 'Anything to remember? Optional'}) {
  final p = V2PaletteStore.instance.current;
  return TextField(
    key: const ValueKey('pp_care_note'),
    controller: c,
    minLines: 1,
    maxLines: 3,
    textCapitalization: TextCapitalization.sentences,
    style: pvManrope(fontSize: 14.5, color: p.ink1),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: pvManrope(fontSize: 14.5, color: p.ink3),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: p.line)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: p.line)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: p.ink1)),
    ),
  );
}

/// The note as saved: null when empty.
String? ppCareNoteValue(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();
