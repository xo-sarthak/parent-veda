// =============================================================================
//  Coming up: what is next, and how soon (2026-10-17)
// -----------------------------------------------------------------------------
//  Replaces the old calendar's Upcoming tab: grey rows, no actions, her own
//  notes left out, and programs dated today. Now (Lex cb327064, Fixtured
//  11d10641, Canopi d88f4063):
//
//    · a date block on the left, a countdown eyebrow ("In 3 days") on the right;
//    · groups: Today · This week · Later this trimester · Next trimester and on;
//    · filters that match the calendar's own kinds exactly;
//    · usual checks as windows ("WK 24", dashed), never as her dates;
//    · daily reminders and enrolled programs in their own groups, undated;
//    · a Done side for past appointments and checks marked done.
// =============================================================================

import 'package:flutter/material.dart';

import '../../../services/pregnancy_controller.dart';
import '../../../theme/pv_fonts.dart';
import '../../../widgets/global_ask_fab.dart' show kAskFabReserve;
import '../../brackets/hub/hub_intent_art.dart' show IntentMark;
import '../../products/pv_store_chrome.dart' show kPvInk, kPvLine, pvStorePalette;
import 'preg_cal_data.dart';
import 'preg_cal_parts.dart';
import 'preg_cal_sheets.dart';
import 'preg_calendar_hub.dart' show pregCalListenable;

class PregCalUpcomingScreen extends StatefulWidget {
  const PregCalUpcomingScreen({
    super.key,
    required this.controller,
    this.readOnly = false,
    this.today,
  });
  final PregnancyController controller;
  final bool readOnly;
  final DateTime? today;

  @override
  State<PregCalUpcomingScreen> createState() => _PregCalUpcomingScreenState();
}

enum _Filter { all, appointment, check, note }

class _PregCalUpcomingScreenState extends State<PregCalUpcomingScreen> {
  late final DateTime _today = pregDayOnly(widget.today ?? DateTime.now());
  _Filter _filter = _Filter.all;
  bool _done = false;

  PregnancyController get p => widget.controller;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: pregCalListenable(p),
        builder: (context, _) => _build(context),
      );

  bool _keep(PregUpcoming u) => switch (_filter) {
        _Filter.all => true,
        _Filter.appointment => u.kind == PregCalKind.appointment,
        _Filter.check => u.kind == PregCalKind.check,
        _Filter.note => u.kind == PregCalKind.note,
      };

  Widget _build(BuildContext context) {
    final items = pregCalItems();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        iconTheme: const IconThemeData(color: kPvInk),
        title: Text('Coming up', style: pregCalSerif(22)),
        actions: [
          if (!widget.readOnly)
            IconButton(
              tooltip: 'Add an appointment',
              icon: const Icon(Icons.add_rounded),
              onPressed: () => showPregCalAdd(context, p, _today, today: _today),
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Column(children: [
            _segmented(),
            if (!_done) ...[const SizedBox(height: 10), _chips()],
          ]),
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(16, 4, 16, kAskFabReserve + 8),
            children: _done ? _doneList(items) : _nextList(items),
          ),
        ),
      ]),
    );
  }

  Widget _segmented() => Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
            color: kPregCalTint, borderRadius: BorderRadius.circular(999)),
        child: Row(children: [
          for (final (label, done) in const [('Coming up', false), ('Done', true)])
            Expanded(
              child: Semantics(
                button: true,
                selected: _done == done,
                child: pregCalTap(
                  onTap: () => setState(() => _done = done),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      color: _done == done ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: _done == done
                          ? [
                              BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1))
                            ]
                          : null,
                    ),
                    child: Text(label,
                        textAlign: TextAlign.center,
                        style: pvManrope(fontSize: 13, fontWeight: FontWeight.w700, color: kPvInk)),
                  ),
                ),
              ),
            ),
        ]),
      );

  Widget _chips() => SizedBox(
        height: 36,
        child: ListView(scrollDirection: Axis.horizontal, children: [
          for (final (f, label) in const [
            (_Filter.all, 'All'),
            (_Filter.appointment, 'Appointments'),
            (_Filter.check, 'Usual checks'),
            (_Filter.note, 'My notes'),
          ])
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Semantics(
                button: true,
                selected: _filter == f,
                child: pregCalTap(
                  onTap: () => setState(() => _filter = f),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                    decoration: BoxDecoration(
                      color: _filter == f ? kPvInk : Colors.white,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: _filter == f ? kPvInk : kPvLine),
                    ),
                    child: Text(label,
                        style: pvManrope(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: _filter == f ? Colors.white : kPvInk)),
                  ),
                ),
              ),
            ),
        ]),
      );

  Widget _groupLabel(String t) => Padding(
        padding: const EdgeInsets.fromLTRB(2, 14, 2, 8),
        child: Text(t.toUpperCase(), style: pregCalEyebrow()),
      );

  void _open(PregUpcoming u) => u.around
      ? showPregCalCheck(context, p, u.check!, readOnly: widget.readOnly)
      : showPregCalItem(context, p, u.item!, readOnly: widget.readOnly);

  List<Widget> _nextList(List<PregCalItem> items) {
    final all = pregUpcoming(items, p.dueDate, _today).where(_keep).toList();
    if (all.isEmpty) {
      return [
        const SizedBox(height: 6),
        PregCalCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
                _filter == _Filter.note
                    ? 'No notes ahead.'
                    : 'Nothing booked yet. Add your next check-up and it will show here with a countdown.',
                style: pregCalBody(color: pvStorePalette.ink2, height: 1.45)),
            if (!widget.readOnly) ...[
              const SizedBox(height: 12),
              PregCalPill(
                  label: _filter == _Filter.note ? 'Add a note' : 'Add an appointment',
                  ink: true,
                  icon: Icons.add_rounded,
                  onTap: () => _filter == _Filter.note
                      ? showPregCalNote(context, day: _today)
                      : showPregCalAdd(context, p, _today, today: _today)),
            ],
          ]),
        ),
        ..._everyDay(),
      ];
    }
    final curTri = pregTrimesterFor(pregCompletedWeeks(p.dueDate, _today));
    int daysOut(PregUpcoming u) => u.date.difference(_today).inDays;
    int tri(PregUpcoming u) => pregTrimesterFor(pregCompletedWeeks(p.dueDate, u.date));
    final groups = <(String, List<PregUpcoming>)>[
      ('Today', [for (final u in all) if (daysOut(u) <= 0) u]),
      ('This week', [for (final u in all) if (daysOut(u) > 0 && daysOut(u) < 7) u]),
      ('Later this trimester',
          [for (final u in all) if (daysOut(u) >= 7 && tri(u) <= curTri) u]),
      ('Next trimester and on',
          [for (final u in all) if (daysOut(u) >= 7 && tri(u) > curTri) u]),
    ];
    return [
      for (final (label, list) in groups) ...[
        _groupLabel(label),
        if (list.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(2, 0, 2, 4),
            child: Text(label == 'Today' ? 'No more today.' : 'Nothing yet.',
                style: pregCalBody(size: 12.5, color: pvStorePalette.ink3)),
          )
        else
          PregCalCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(children: [
              for (final (i, u) in list.indexed)
                PregCalUpcomingRow(u: u, today: _today, first: i == 0, onTap: () => _open(u)),
            ]),
          ),
      ],
      if (_filter == _Filter.all) ..._everyDay(),
    ];
  }

  List<Widget> _everyDay() {
    if (_filter != _Filter.all) return const [];
    final reminders = pregReminderLines();
    final programs = pregProgramLines();
    Widget lines(List<PregCalLine> ls, IntentMark mark) => PregCalCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(children: [
            for (final (i, l) in ls.indexed)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                    border: i == 0 ? null : const Border(top: BorderSide(color: kPvLine))),
                child: Row(children: [
                  pregCalPlainMark(mark, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(l.title, style: pregCalBody(weight: FontWeight.w700)),
                      Text(l.detail, style: pregCalBody(size: 12.5, color: pvStorePalette.ink3)),
                    ]),
                  ),
                ]),
              ),
          ]),
        );
    return [
      if (reminders.isNotEmpty) ...[_groupLabel('Every day'), lines(reminders, IntentMark.listMark)],
      if (programs.isNotEmpty) ...[_groupLabel('Your programs'), lines(programs, IntentMark.schoolMark)],
    ];
  }

  List<Widget> _doneList(List<PregCalItem> items) {
    final done = [
      for (final i in items.reversed)
        if ((i.kind == PregCalKind.appointment && (i.done || i.date.isBefore(_today))) ||
            (i.kind == PregCalKind.check && i.done))
          i
    ];
    if (done.isEmpty) {
      return [
        const SizedBox(height: 6),
        PregCalCard(
          child: Text('No past appointments or checks yet.',
              style: pregCalBody(color: pvStorePalette.ink2)),
        ),
      ];
    }
    return [
      const SizedBox(height: 6),
      PregCalCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(children: [
          for (final (i, it) in done.indexed)
            pregCalTap(
              onTap: () => showPregCalItem(context, p, it, readOnly: widget.readOnly),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                    border: i == 0 ? null : const Border(top: BorderSide(color: kPvLine))),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  PregCalDateBlock(top: pregWeekdayCaps(it.date), big: '${it.date.day}'),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('${pregShortDate(it.date)} · DONE'.toUpperCase(),
                          style: pregCalEyebrow()),
                      const SizedBox(height: 2),
                      Text(it.title, style: pregCalBody(size: 14.5, weight: FontWeight.w700)),
                      if (it.detail.isNotEmpty && it.detail != 'Done')
                        Text(it.detail,
                            style: pregCalBody(size: 12.5, color: pvStorePalette.ink3)),
                    ]),
                  ),
                ]),
              ),
            ),
        ]),
      ),
    ];
  }
}
