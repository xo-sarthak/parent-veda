// =============================================================================
//  TTC - the one tracker screen
// -----------------------------------------------------------------------------
//  Renders ANY tracker defined in ttc_trackers_data.dart: symptoms, weight,
//  sleep, mood, stress, lifestyle, movement, partner health.
//
//  One screen rather than eight is not only less code - it is why they will
//  still feel like one product in a year. A tracker cannot drift from the
//  others when there is only one implementation to drift from.
//
//  The shape every tracker gets, in order:
//    why it exists → today's entry → what you have recorded → the disclaimer
//
//  "Why it exists" comes FIRST, above the inputs, on purpose. A field a parent
//  cannot see the point of is a field that should not be asked for.
// =============================================================================

import 'package:flutter/material.dart';

import '../../ttc/ttc_log_store.dart';
import '../../ttc/ttc_trackers_data.dart';
import 'ttc_common.dart';
import 'ttc_strings.dart';

void openTtcTracker(BuildContext context, String trackerId) {
  final tracker = ttcTrackerById(trackerId);
  if (tracker == null) return;
  Navigator.of(context).push(MaterialPageRoute<void>(
    builder: (_) => TtcTrackerScreen(tracker: tracker),
    settings: RouteSettings(name: 'ttc/tracker/$trackerId'),
  ));
}

class TtcTrackerScreen extends StatelessWidget {
  const TtcTrackerScreen({super.key, required this.tracker});

  final TtcTracker tracker;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([TtcLogStore.instance, TtcLang.instance]),
      builder: (context, _) {
        final t = TtcS.current();
        final hi = t.hinglish;
        final store = TtcLogStore.instance;
        final days = store.daysLogged(tracker.id);

        return Scaffold(
          backgroundColor: ttcBg,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                  ttcGutter, 8, ttcGutter, ttcBottomInset),
              children: [
                TtcBackBar(title: tracker.title(hi)),
                const SizedBox(height: 16),

                // ---- why this exists, before anything is asked for --------
                TtcCard(
                  color: ttcPanel,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Icon(ttcTrackerIcon(tracker.iconKey),
                              size: 18, color: ttcPurple),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Text(tracker.subtitle(hi),
                                style: ttcBody(13,
                                    color: ttcPurple, w: FontWeight.w800)),
                          ),
                          if (tracker.forPartner)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 9, vertical: 4),
                              decoration: BoxDecoration(
                                  color: ttcCoralTint,
                                  borderRadius: BorderRadius.circular(999)),
                              child: Text(t.forPartnerTag,
                                  style: ttcBody(10,
                                      color: ttcCoral, w: FontWeight.w800)),
                            ),
                        ]),
                        const SizedBox(height: 11),
                        Text(tracker.why(hi), style: ttcBody(13.5, h: 1.6)),
                      ]),
                ),
                const SizedBox(height: 18),

                // ---- today ------------------------------------------------
                ttcSectionTitle(t.trackerToday),
                TtcCard(
                  child: Column(children: [
                    for (var i = 0; i < tracker.fields.length; i++) ...[
                      _FieldRow(tracker: tracker, field: tracker.fields[i], t: t),
                      if (i < tracker.fields.length - 1) ...[
                        const SizedBox(height: 16),
                        ttcDivider(),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ]),
                ),
                // Ask Veda's guardrails route "severe pain" to a doctor. The
                // tracker recorded the identical thing in silence, so two parts
                // of one product disagreed about what severe means.
                _SevereNotice(tracker: tracker, t: t),
                const SizedBox(height: 20),

                // ---- history ----------------------------------------------
                ttcSectionTitle(t.trackerHistory),
                if (days.isEmpty)
                  TtcEmpty(
                    icon: Icons.history_rounded,
                    title: t.trackerEmptyTitle,
                    body: t.trackerEmptyBody,
                  )
                else
                  for (final day in days.take(30)) ...[
                    _DayCard(tracker: tracker, dayKey: day, t: t),
                    const SizedBox(height: 10),
                  ],

                // ---- disclaimer -------------------------------------------
                if (tracker.disclaimer(hi) != null) ...[
                  const SizedBox(height: 12),
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Icon(Icons.info_outline_rounded,
                        size: 15, color: ttcMuted),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(tracker.disclaimer(hi)!,
                          style: ttcBody(11.5, color: ttcMuted, h: 1.5)),
                    ),
                  ]),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Shown once, quietly, when anything today sits at the top of its scale.
///
/// Not alarming and not a diagnosis - it names the thing worth mentioning and
/// stops, because this tracker's whole premise is notice, never diagnose.
class _SevereNotice extends StatelessWidget {
  const _SevereNotice({required this.tracker, required this.t});

  final TtcTracker tracker;
  final TtcS t;

  @override
  Widget build(BuildContext context) {
    final severe = tracker.fields.any((f) {
      if (f.kind != TtcFieldKind.scale) return false;
      final v = TtcLogStore.instance.valueFor(tracker.id, f.id);
      // Top of the scale - "Severe", "A lot" at the far end.
      return v != null && v.value.round() >= f.choicesEn.length - 1;
    });
    if (!severe) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: TtcCard(
        color: ttcCoralTint,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.info_outline_rounded, size: 17, color: ttcCoral),
            const SizedBox(width: 9),
            Expanded(
                child:
                    Text(t.severeNoticedTitle, style: ttcJakarta(14.5))),
          ]),
          const SizedBox(height: 9),
          Text(t.severeNoticedBody, style: ttcBody(12.5, h: 1.55)),
        ]),
      ),
    );
  }
}

// ---- one field --------------------------------------------------------------

class _FieldRow extends StatelessWidget {
  const _FieldRow({required this.tracker, required this.field, required this.t});

  final TtcTracker tracker;
  final TtcField field;
  final TtcS t;

  @override
  Widget build(BuildContext context) {
    final hi = t.hinglish;
    final current = TtcLogStore.instance.valueFor(tracker.id, field.id);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(
          child: Text(field.label(hi),
              style: ttcBody(13.5, color: ttcInk, w: FontWeight.w700)),
        ),
        if (current != null)
          GestureDetector(
            // Clearing must always be possible - a mis-tap that cannot be
            // undone turns a log into a permanent record of a mistake.
            onTap: () => TtcLogStore.instance.clear(tracker.id, field.id),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(t.trackerClear,
                  style: ttcBody(11.5, color: ttcMuted, w: FontWeight.w700)),
            ),
          ),
      ]),
      const SizedBox(height: 11),
      switch (field.kind) {
        TtcFieldKind.number => _NumberInput(
            tracker: tracker, field: field, t: t, current: current),
        _ => _ChoiceInput(
            tracker: tracker, field: field, t: t, current: current),
      },
    ]);
  }
}

/// Scales and choices are the same control - a row of named options. A scale is
/// simply a choice whose options happen to be ordered, and showing it as words
/// rather than a numbered slider is the whole point: "3 out of 5" means nothing
/// to a parent, "some" means something.
class _ChoiceInput extends StatelessWidget {
  const _ChoiceInput({
    required this.tracker,
    required this.field,
    required this.t,
    required this.current,
  });

  final TtcTracker tracker;
  final TtcField field;
  final TtcS t;
  final TtcLogValue? current;

  @override
  Widget build(BuildContext context) {
    final hi = t.hinglish;
    final options = field.choices(hi);

    // A single row that divides the width, rather than a Wrap.
    //
    // Wrapping put "None / A little / Some / A lot" on one line and dropped
    // "Severe" onto its own - for every symptom on the screen. Eight orphaned
    // chips, and a scale that no longer looked like a scale, which matters
    // here: these options are ORDERED, and a wrapped last item reads as a
    // separate thing rather than the far end of the same line.
    return Row(
      children: [
        for (var i = 0; i < options.length; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(
            child: GestureDetector(
              onTap: () =>
                  TtcLogStore.instance.log(tracker.id, field.id, i.toDouble()),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: current?.value.round() == i ? ttcPurple : ttcPanel,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  options[i],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: ttcBody(11.5,
                      color: current?.value.round() == i
                          ? Colors.white
                          : ttcSoft,
                      w: FontWeight.w700),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _NumberInput extends StatelessWidget {
  const _NumberInput({
    required this.tracker,
    required this.field,
    required this.t,
    required this.current,
  });

  final TtcTracker tracker;
  final TtcField field;
  final TtcS t;
  final TtcLogValue? current;

  @override
  Widget build(BuildContext context) {
    final hi = t.hinglish;
    final value = current?.value;
    return Row(children: [
      _stepper(context, Icons.remove_rounded, -field.step, value),
      const SizedBox(width: 14),
      Expanded(
        child: GestureDetector(
          onTap: () => _typeIn(context),
          behavior: HitTestBehavior.opaque,
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
                color: ttcPanel, borderRadius: BorderRadius.circular(14)),
            child: Text(
              value == null ? t.trackerTapToAdd : field.display(hi, value),
              style: ttcBody(15,
                  color: value == null ? ttcMuted : ttcTitleInk,
                  w: FontWeight.w800),
            ),
          ),
        ),
      ),
      const SizedBox(width: 14),
      _stepper(context, Icons.add_rounded, field.step, value),
    ]);
  }

  Widget _stepper(
      BuildContext context, IconData icon, double delta, double? value) {
    return GestureDetector(
      onTap: () {
        // Stepping from nothing starts at a sensible midpoint rather than at
        // zero, so "add" does not mean "record that you slept 0.5 hours".
        final base = value ?? _sensibleStart();
        final next = (base + delta).clamp(field.min, field.max);
        TtcLogStore.instance.log(tracker.id, field.id, next.toDouble());
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: ttcBorder),
        ),
        child: Icon(icon, size: 19, color: ttcPurple),
      ),
    );
  }

  double _sensibleStart() {
    switch (field.id) {
      case 'hours':
      case 'sleep':
        return 7;
      case 'kg':
        return 60;
      case 'minutes':
        return 30;
      case 'water':
        return 6;
      default:
        return field.min;
    }
  }

  Future<void> _typeIn(BuildContext context) async {
    final hi = t.hinglish;
    final controller = TextEditingController(
        text: current?.value.toStringAsFixed(current!.value % 1 == 0 ? 0 : 1));
    final result = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(field.label(hi), style: ttcJakarta(16)),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: ttcBody(16, color: ttcInk, w: FontWeight.w700),
          decoration: InputDecoration(
            suffixText: field.unit,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(t.journalCancel,
                style: ttcBody(13, color: ttcSoft, w: FontWeight.w700)),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(ctx).pop(double.tryParse(controller.text)),
            child: Text(t.journalSave,
                style: ttcBody(13, color: ttcPurple, w: FontWeight.w800)),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result == null) return;
    TtcLogStore.instance.log(tracker.id, field.id,
        result.clamp(field.min, field.max).toDouble());
  }
}

// ---- one logged day ---------------------------------------------------------

class _DayCard extends StatelessWidget {
  const _DayCard({required this.tracker, required this.dayKey, required this.t});

  final TtcTracker tracker;
  final String dayKey;
  final TtcS t;

  @override
  Widget build(BuildContext context) {
    final hi = t.hinglish;
    final values = TtcLogStore.instance.valuesOn(tracker.id, dayKey);
    final date = DateTime.parse(dayKey);
    return TtcCard(
      padding: const EdgeInsets.all(15),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(_fmt(date),
            style: ttcBody(12, color: ttcMuted, w: FontWeight.w800)),
        const SizedBox(height: 10),
        for (final v in values) ...[
          Row(children: [
            Expanded(
              child: Text(
                  tracker.fields
                          .where((f) => f.id == v.field)
                          .firstOrNull
                          ?.label(hi) ??
                      v.field,
                  style: ttcBody(13)),
            ),
            Text(
              tracker.fields
                      .where((f) => f.id == v.field)
                      .firstOrNull
                      ?.display(hi, v.value) ??
                  v.value.toStringAsFixed(0),
              style: ttcBody(13, color: ttcTitleInk, w: FontWeight.w800),
            ),
          ]),
          const SizedBox(height: 7),
        ],
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

IconData ttcTrackerIcon(String key) {
  switch (key) {
    case 'healing':
      return Icons.healing_outlined;
    case 'weight':
      return Icons.monitor_weight_outlined;
    case 'sleep':
      return Icons.bedtime_outlined;
    case 'mood':
      return Icons.mood_outlined;
    case 'stress':
      return Icons.spa_outlined;
    case 'lifestyle':
      return Icons.wb_sunny_outlined;
    case 'partner':
      return Icons.male_rounded;
    case 'exercise':
      return Icons.directions_walk_rounded;
    default:
      return Icons.circle_outlined;
  }
}
