// =============================================================================
//  TtcSymptomLogScreen — what kind of day it was
// -----------------------------------------------------------------------------
//  ⚠️ REBUILT AFTER GETTING IT WRONG, AND THE MISTAKE IS WORTH RECORDING.
//
//  The first version put a horizontal strip of dates across the top on a
//  saturated purple ground, tinted every icon purple, and closed with a bright
//  purple button. The note back was blunt and correct: *"Does the V3 home look
//  purple, purple, purple to you? It looks amazing. But when I click on check
//  symptom you just bombard everything with purple."*
//
//  The error was not taste. It was reaching for the stage's ACCENT as though it
//  were the stage's GROUND. The V3 home is teal and cream and white, and it
//  spends purple in about four places: one chip, one arrow, one FAB, one active
//  tab. Purple is what means "touch this", and it works precisely because it is
//  rare. Used as a background it stops being a signal and becomes noise.
//
//  **The rule: purple marks the one thing on screen worth touching. Past about
//  a tenth of the pixels, it has stopped meaning anything.** Colour on this
//  screen comes from the CATEGORY instead — each card's chips share their own
//  hue, so a card reads as a set and no card is purple unless its subject is.
//
//  ---------------------------------------------------------------------------
//  ⚠️ AND THE DATE STRIP IS GONE
//  ---------------------------------------------------------------------------
//
//  It had no business here. The home already carries the week with markers on
//  the days that hold something — that is where "which day am I looking at"
//  belongs. Repeating it inside the logger meant two week strips, two sources
//  of truth for one question, and a second thing to keep in step.
//
//  What replaces it is what the screen actually needs: the day's NAME, the
//  cycle day beneath it, an arrow either side. "Yesterday · Cycle day 7"
//  answers the question in four words and takes one line instead of eighty
//  vertical pixels.
//
//  ---------------------------------------------------------------------------
//  ⚠️ REBUILT INTO THE TOOL SHELL — 2026-09-27, night (the tool rebuild)
//  ---------------------------------------------------------------------------
//
//  The user, walking build 13: "old tools in new clothes… poor functionality".
//  This screen was the last logger on its own plain page (close icon, arrows,
//  a long disclaimer at the foot) while every other tool wore `TtcToolScaffold`.
//  What changed, each against the apps that do it best:
//
//  · THE SHELL. Eyebrow "Symptoms and mood" (the Tools tile, word for word),
//    the title asks about the day she is on, the intro says every tap saves.
//  · THE DAY IS A SCOPE, IN THE HERO, AND ITS NAME OPENS A CALENDAR. Arrows
//    either side, the cycle day under it, the way Flo's logger heads its sheet
//    (https://mobbin.com/screens/77dd11a7-932c-4589-a0f2-8cc4ccd6999f), and a
//    tap on the name jumps to any past day, the way Stardust's "Mon, Jul 06 ▾"
//    and Clue's calendar button do
//    (https://mobbin.com/screens/999c811f-e1cd-4eff-9b18-c129a7b7a2fe,
//    https://mobbin.com/screens/2104b1ea-fed5-445f-bb8b-435213c91ff9). Two
//    weeks back used to be fourteen taps on an arrow.
//  · WHAT IS SAVED FOR THE DAY IS LISTED, AND EACH ONE COMES OFF WITH AN ×.
//    Clue's "Tracked on Aug 12" list and Oura's chosen tags with an ×
//    (https://mobbin.com/screens/796f9cfb-72ef-41d0-bfa1-aca3a3602ada,
//    https://mobbin.com/screens/268d6262-a98a-4704-a6cb-1b1d25a691db). A chip
//    she tapped by mistake was only removable by finding it again in fifty;
//    now it is at the top, and the × has an Undo.
//  · WEIGHT AND TEMPERATURE SAY THEIR ACTION ON THE CARD ("Add" / "Change"),
//    and the sheet says which day it saves to, has − and + either side of the
//    number (Lifesum, https://mobbin.com/screens/34100a72-7705-4c51-a302-6b19ccea394f),
//    types as well as scrolls, says Save, and removes with an Undo. Flo's
//    temperature sheet (https://mobbin.com/screens/a3b4647a-7620-47fb-b22f-6bdff85002fd)
//    and Stardust's "Add daily temperature · Cycle day 9"
//    (https://mobbin.com/screens/6b197a60-bde3-4e10-9355-1c51a277b3e7).
//  · A "DONE" THAT CONFIRMS. Taps still save as they happen (no Apply to
//    forget, unlike Flo), but the way out says what was kept.
//  · THE LONG DISCLAIMER IS A QUESTION SHE CAN OPEN, not a paragraph at the
//    foot; the short line in the hero is the one disclaimer on show.
// =============================================================================

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/bracket_resolver.dart' show bracketById;
import '../../theme/pv_fonts.dart';
import '../../ttc/cycle_store.dart';
import '../../ttc/ttc_chapter.dart';
import '../../ttc/ttc_cycle_report.dart';
import '../../ttc/ttc_focus_data.dart' show ttcFocusPageFor;
import '../../ttc/ttc_log_store.dart';
import '../../ttc/ttc_logging_extras.dart';
import '../../ttc/ttc_reads_data.dart' show ttcReadById;
import '../../ttc/ttc_store.dart';
import '../../ttc/ttc_symptom_data.dart';
import '../../widgets/pv_feedback.dart';
import '../products/pv_store_chrome.dart' show pvSnack;
import '../v2/v2_palette.dart';
import 'ttc_common.dart';
import 'ttc_cycle_palette.dart';
import 'ttc_cycle_report_screen.dart';
import 'ttc_edit_categories_screen.dart';
import 'ttc_focus_screen.dart' show TtcFocusScreen;
import 'ttc_surface_router.dart' show openTtcSurface, kTtcReadPrefix;
import 'ttc_symptom_mark.dart';
import 'ttc_strings.dart';
import 'ttc_tool_chrome.dart';

/// Under the pregnancy test card, to the "Should I test?" chat (2026-09-26).
const String kTtcShouldTestLink = 'Should I test?';

class TtcSymptomLogScreen extends StatefulWidget {
  const TtcSymptomLogScreen({super.key, this.day, this.focusGroup});

  final DateTime? day;

  /// A category to bring into view on open (a group id such as
  /// 'ovulation_test'). Added 2026-09-26 for the home's one-tap "Test": the
  /// test cards sit below the fold, and a button that said "Test" and opened
  /// the top of a long form would make her hunt for what she tapped.
  ///
  /// When that card is hidden in her categories, the pregnancy test card is
  /// tried instead; when neither shows, the screen opens at the top as before.
  final String? focusGroup;

  @override
  State<TtcSymptomLogScreen> createState() => _TtcSymptomLogScreenState();
}

class _TtcSymptomLogScreenState extends State<TtcSymptomLogScreen> {
  /// ⚠️ CLAMPED TO TODAY AT THE DOOR. The home now hands this screen whichever
  /// date the day strip is on, and the future-date guard lives on the button
  /// there — but a guard that lives only at one call site is a guard one new
  /// call site removes. `_step` already refuses to walk forward past today; the
  /// entry point had no such rule, so a future date could be handed straight in
  /// and every tap would write a symptom against a day nobody has lived.
  late DateTime _day = _clampToToday(_dayOnly(widget.day ?? DateTime.now()));

  static DateTime _clampToToday(DateTime d) {
    final today = _dayOnly(DateTime.now());
    return d.isAfter(today) ? today : d;
  }
  String _query = '';

  /// One key per category card, so [TtcSymptomLogScreen.focusGroup] can be
  /// scrolled to after the first layout.
  final Map<String, GlobalKey> _groupKeys = {};
  GlobalKey _keyFor(String groupId) =>
      _groupKeys.putIfAbsent(groupId, () => GlobalKey());

  @override
  void initState() {
    super.initState();
    // ⚠️ A BUG, FOUND IN THE REBUILD (2026-09-27): only the Show or hide
    // page loaded her choices, so after a restart every card she had hidden
    // came back until she happened to open that page. The logger reads them,
    // so the logger loads them. `load` runs once and is safe to call twice.
    TtcCategoryPrefs.instance.load();
    final focus = widget.focusGroup;
    if (focus == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      for (final id in [focus, kTtcPregnancyTestGroup]) {
        final ctx = _groupKeys[id]?.currentContext;
        if (ctx == null) continue;
        Scrollable.ensureVisible(ctx,
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            alignment: 0.05);
        return;
      }
    });
  }

  /// The "Should I test?" chat, from the pregnancy test card.
  void _openShouldTest() => openTtcSurface(context, 'ttc_chat/should_test');

  static DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String get _dayName {
    final today = _dayOnly(DateTime.now());
    final diff = today.difference(_day).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    // The weekday too (tool rebuild, 2026-09-27): "Wed 24 Sep" is a day she
    // can place; "24 Sep" alone makes her count. Kept for revert:
    //   return '${_day.day} ${_months[_day.month - 1]}';
    return '${_weekdays[_day.weekday - 1]} ${_day.day} '
        '${_months[_day.month - 1]}';
  }

  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  bool get _canGoForward => _day.isBefore(_dayOnly(DateTime.now()));

  Set<String> get _selected => TtcLogStore.instance
      .valuesOn(kTtcSymptomTracker, TtcLogStore.dayKey(_day))
      .where((v) => v.value > 0)
      .map((v) => v.field)
      .toSet();

  void _step(int days) {
    final next = DateTime(_day.year, _day.month, _day.day + days);
    if (next.isAfter(_dayOnly(DateTime.now()))) return;
    setState(() => _day = next);
  }

  /// ⚠️ ANY PAST DAY IN ONE TAP (tool rebuild, 2026-09-27). The arrows walk
  /// one day at a time, so a day two weeks ago was fourteen taps, and nothing
  /// said the day's name could be tapped. A calendar that stops at today, the
  /// same guard `_step` and the entry point keep.
  Future<void> _pickDay() async {
    final today = _dayOnly(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: _day,
      firstDate: DateTime(today.year - 2, today.month, today.day),
      lastDate: today,
      helpText: kTtcLogPickDayTitle,
      routeSettings: const RouteSettings(name: 'ttc/symptom_log/day'),
    );
    if (picked == null || !mounted) return;
    setState(() => _day = _clampToToday(_dayOnly(picked)));
  }

  /// Takes one thing off the day, from the list of what is saved, with Undo.
  ///
  /// ⚠️ UNDO, NOT A CONFIRM, and the trade is the opposite of the one
  /// `ttcConfirmRemove` makes. A chip is one value in the store, so holding it
  /// for four seconds costs nothing, and a question before every × on a list
  /// she is tidying would be a tax on the common case.
  void _removeSaved(_SavedItem item) {
    final store = TtcLogStore.instance;
    final day = _day;
    final old = store.valueFor(item.tracker, item.field, on: day)?.value;
    if (old == null) return;
    store.clear(item.tracker, item.field, on: day);
    setState(() {});
    pvSnack(
      context,
      ttcLogRemovedLine(item.label),
      action: 'Undo',
      lift: 24,
      onAction: () {
        // A single-choice card may have taken another answer since; the undo
        // puts the old one back the same way a tap would.
        final group = ttcGroupOf(item.field);
        if (item.tracker == kTtcSymptomTracker && group != null && group.single) {
          for (final other in group.symptoms) {
            if (other.id != item.field) {
              store.clear(kTtcSymptomTracker, other.id, on: day);
            }
          }
        }
        store.log(item.tracker, item.field, old, on: day);
      },
    );
  }

  /// The way out that says what was kept. Taps have already saved; this only
  /// closes, and the confirmation lands on the screen she returns to.
  void _done(int saved) {
    // ⚠️ SHOWN BEFORE THE POP, ON PURPOSE. The app's one ScaffoldMessenger
    // carries a snack across a route change, so it arrives on the screen she
    // goes back to; asked for after the pop, this context is already gone.
    if (saved > 0) {
      // Lifted clear of the home's bar, where it usually lands.
      pvSnack(context, ttcLogDoneLine(saved, _dayName),
          icon: Icons.check_rounded, lift: 96);
    }
    Navigator.of(context).maybePop();
  }

  /// Everything saved for the day on screen, in the order the screen shows it.
  List<_SavedItem> _savedItems(Set<String> selected) {
    final log = TtcLogStore.instance;
    final out = <_SavedItem>[
      for (final g in kTtcSymptomGroups)
        for (final s in g.symptoms)
          if (selected.contains(s.id))
            _SavedItem(kTtcSymptomTracker, s.id, s.label),
    ];
    final w = log.valueFor(kTtcWeightTracker, kTtcWeightField, on: _day);
    if (w != null) {
      out.add(_SavedItem(kTtcWeightTracker, kTtcWeightField,
          'Weight ${w.value.toStringAsFixed(1)} kg'));
    }
    final c = log.valueFor(kTtcTempTracker, kTtcTempField, on: _day);
    if (c != null) {
      out.add(_SavedItem(kTtcTempTracker, kTtcTempField,
          'Temperature ${c.value.toStringAsFixed(2)} °C'));
    }
    return out;
  }

  void _toggle(TtcSymptomGroup group, TtcSymptom symptom) {
    final store = TtcLogStore.instance;
    if (_selected.contains(symptom.id)) {
      store.clear(kTtcSymptomTracker, symptom.id, on: _day);
    } else {
      if (group.single) {
        for (final other in group.symptoms) {
          if (other.id != symptom.id) {
            store.clear(kTtcSymptomTracker, other.id, on: _day);
          }
        }
      }
      store.log(kTtcSymptomTracker, symptom.id, 1, on: _day);
    }
    setState(() {});
  }

  void _setNumber(String tracker, String field, double? v) {
    if (v == null) {
      TtcLogStore.instance.clear(tracker, field, on: _day);
    } else {
      TtcLogStore.instance.log(tracker, field, v, on: _day);
    }
    setState(() {});
  }

  void _openReport() => Navigator.of(context).push(MaterialPageRoute<void>(
        settings: const RouteSettings(name: 'ttc/cycle_report'),
        builder: (_) => const TtcCycleReportScreen(),
      ));

  /// The Hard days read about trying taking over, or the Mind & body door.
  ///
  /// ⚠️ RESOLVED AT THE TAP, NOT AT BUILD. The read was being written in
  /// parallel with this line; `ttcReadById` finds it the moment it is
  /// registered in `ttc_reads_data.dart`, with no change here. Until then the
  /// door it lives behind is the honest next best place, and a line that
  /// promises help never opens nothing.
  void _openHardThoughts() {
    if (ttcReadById(kTtcHardThoughtsReadId) != null) {
      openTtcSurface(context, '$kTtcReadPrefix$kTtcHardThoughtsReadId');
      return;
    }
    // Same wiring gate as `openTtcFocusTile`: an unknown bracket opens nothing.
    final page = ttcFocusPageFor(kTtcMindBodyBracket);
    final bracket = bracketById(kTtcMindBodyBracket);
    if (page == null || bracket == null) return;
    Navigator.of(context).push(MaterialPageRoute<void>(
      settings: const RouteSettings(name: 'ttc/focus/$kTtcMindBodyBracket'),
      builder: (_) => TtcFocusScreen(page: page, bracket: bracket),
    ));
  }

  /// The faint-line read in `ttc_reads_waiting.dart`, through the router.
  void _openFaintLine() =>
      openTtcSurface(context, '$kTtcReadPrefix$kTtcFaintLineReadId');

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        TtcLogStore.instance,
        TtcLang.instance,
        TtcCategoryPrefs.instance,
        // The temperature chart lays readings on her cycle, so a period
        // logged or moved has to redraw it.
        CycleStore.instance,
      ]),
      builder: (context, _) {
        final t = TtcS.current();
        final p = V2PaletteStore.instance.current;
        const engine = TtcChapterEngine();
        final cycleDay = engine.cycleDay(TtcStore.instance.state(on: _day));
        final selected = _selected;
        final groups = _filtered();
        final saved = _savedItems(selected);
        final savedCount = _savedCount(selected);
        final hidden = TtcCategoryPrefs.instance.hidden.length;

        // Kept for revert (2026-09-27, tool rebuild): the plain page this
        // was, before it moved into the tool shell. Everything from the
        // search pill down is unchanged below.
        //   return Scaffold(
        //     backgroundColor: ttcBg,
        //     body: SafeArea(
        //       child: ListView(
        //         padding: const EdgeInsets.fromLTRB(
        //             ttcGutter, 4, ttcGutter, ttcBottomInset),
        //         children: [
        //           Align(alignment: Alignment.centerLeft,
        //               child: IconButton(icon: const Icon(Icons.close_rounded),
        //                   color: ttcTitleInk,
        //                   onPressed: () => Navigator.of(context).maybePop())),
        //           Row(children: [
        //             _Arrow(icon: Icons.chevron_left_rounded, on: true,
        //                 onTap: () => _step(-1)),
        //             Expanded(child: Column(children: [
        //               Text(_dayName, style: ttcJakarta(19)),
        //               if (cycleDay != null) ...[const SizedBox(height: 2),
        //                 Text(t.headerCycleDay(cycleDay),
        //                     style: ttcBody(13, color: ttcMuted))],
        //             ])),
        //             _Arrow(icon: Icons.chevron_right_rounded,
        //                 on: _canGoForward, onTap: () => _step(1)),
        //           ]),
        //           const SizedBox(height: 6),
        //           Center(child: _SavedCount(count: _savedCount(selected))),
        //           const SizedBox(height: 14),
        //           Text(kTtcLogHowItWorks,
        //               key: const ValueKey('ttc_log_how_it_works'),
        //               style: ttcBody(13.5, color: ttcInk, h: 1.5)),
        //           const SizedBox(height: 14),
        //           ...the search pill and everything below...
        return TtcToolScaffold(
          hue: kTtcLogHue,
          variant: 3,
          // ⚠️ ONE NAME: the Tools tile's, word for word.
          eyebrow: kTtcLogEyebrow,
          title: ttcLogTitle(_dayName),
          // The one disclaimer on show; the long one is a question at the
          // foot she can open.
          intro: kTtcLogHowItWorks,
          heroLead: _DayPicker(
            label: _dayName,
            caption: cycleDay == null ? null : t.headerCycleDay(cycleDay),
            canGoForward: _canGoForward,
            onBack: () => _step(-1),
            onForward: () => _step(1),
            onPick: _pickDay,
            onToday: _canGoForward
                ? () => setState(() => _day = _dayOnly(DateTime.now()))
                : null,
          ),
          children: [
            ttcToolPad(Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 22),
                // ⚠️ "DID IT SAVE?" ANSWERED ON THE SCREEN (tools pass,
                // 2026-09-27), and since the rebuild WHAT was saved, each
                // with an × (Clue's "Tracked on", Oura's tags).
                _SavedCard(
                    count: savedCount, items: saved, onRemove: _removeSaved),
                const SizedBox(height: 16),

                // ⚠️ A PLAIN GREY PILL. A search box looks like this on every
                // screen anyone has used; a tinted one would be the only
                // coloured field on the page and would read as a state.
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: ttcPanel,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(children: [
                    const Icon(Icons.search_rounded, size: 20, color: ttcMuted),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        onChanged: (v) => setState(() => _query = v),
                        style: ttcBody(14, color: ttcInk),
                        cursorColor: ttcSoft,
                        // ⚠️ NOT FILLED (launch walk, 2026-09-27): the app's
                        // input theme fills fields white, so a white box sat
                        // inside the grey pill, offset, like a box in a box.
                        decoration: InputDecoration(
                          isDense: true,
                          filled: false,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 13),
                          hintText: t.logSearch,
                          hintStyle: ttcBody(14, color: ttcMuted),
                        ),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 20),

                // When a search finds no chip, say so, and point at the two
                // number cards for the words that mean them (2026-09-27).
                if (_query.isNotEmpty && groups.isEmpty) ...[
                  Text(
                      ttcLogNumberHint(_query) ?? kTtcLogSearchNothing,
                      key: const ValueKey('ttc_log_search_nothing'),
                      style: ttcBody(13.5, color: ttcSoft, h: 1.5)),
                  const SizedBox(height: 18),
                ],
                if (_query.isEmpty) ...[
                  _FeelingRow(
                      selected: selected, onTap: _toggle, p: p),
                  // ⚠️ ONE LINE, AND ONLY AFTER THREE DAYS RUNNING. One hard
                  // day is a hard day; three in a row of guilt, looping
                  // thoughts or being hard on herself is the pattern the
                  // Hard days read was written for. It never counts out
                  // loud and never names anything, it offers a read.
                  if (ttcHardThoughtsRunOn(_day)) ...[
                    const SizedBox(height: 12),
                    _GentleLine(
                        text: kTtcHardThoughtsLine, onTap: _openHardThoughts),
                  ],
                  const SizedBox(height: 22),
                  Row(children: [
                    // Says what is below, not what kind of thing it is
                    // (2026-09-27). Kept for revert: Text(t.logCategories, ...).
                    Expanded(
                        child: Text(kTtcLogMoreHeading, style: ttcJakarta(18))),
                    // ⚠️ PURPLE, AND IT DOES SOMETHING. It shipped coral —
                    // borrowed straight off the reference — and did nothing at
                    // all. Both halves of that were wrong: coral in this stage
                    // is the period marker and means one thing, and a control
                    // styled as a control that does not respond teaches the
                    // reader that taps do nothing. Purple is the app's
                    // interactive colour and this is genuinely interactive.
                    GestureDetector(
                      onTap: () =>
                          Navigator.of(context).push(MaterialPageRoute<void>(
                        settings: const RouteSettings(
                            name: 'ttc/edit_categories'),
                        builder: (_) => const TtcEditCategoriesScreen(),
                      )),
                      behavior: HitTestBehavior.opaque,
                      // Says what the tap does (2026-09-27). Kept for revert:
                      //   Text(t.logEdit, ...)
                      child: Text(kTtcLogShowHide,
                          key: const ValueKey('ttc_log_show_hide'),
                          style: ttcBody(13.5,
                              color: ttcPurple, w: FontWeight.w800)),
                    ),
                  ]),
                  // ⚠️ A HIDDEN CARD IS SAID, NOT SILENT (tool rebuild). A
                  // feature is never hidden without a trace: she hid it a
                  // month ago and wonders where "Sex" went.
                  if (hidden > 0) ...[
                    const SizedBox(height: 4),
                    Text(ttcLogHiddenLine(hidden),
                        key: const ValueKey('ttc_log_hidden_line'),
                        style: ttcBody(12.5, color: ttcMuted)),
                  ],
                  const SizedBox(height: 12),
                ],

                for (final group in groups) ...[
                  _CategoryCard(
                    key: _keyFor(group.id),
                    group: group,
                    selected: selected,
                    onTap: (s) => _toggle(group, s),
                    p: p,
                    // "Faint line" is the chip people stare at longest, so
                    // the read that explains it sits under the card.
                    //
                    // ⚠️ AND "SHOULD I TEST?" UNDER IT SINCE 2026-09-26 (gap
                    // analysis, "Behind: Guided help"). The card that records
                    // a test is where the question comes up, so the chat that
                    // answers it from her own dates is offered right there.
                    // Kept for revert, the single link:
                    //   footer: group.id == kTtcPregnancyTestGroup
                    //       ? _LinkRow(label: kTtcFaintLineLink, onTap: _openFaintLine)
                    //       : null,
                    footer: group.id == kTtcPregnancyTestGroup
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _LinkRow(
                                  label: kTtcFaintLineLink,
                                  onTap: _openFaintLine),
                              const SizedBox(height: 12),
                              _LinkRow(
                                  key: const ValueKey('ttc_log_should_test'),
                                  label: kTtcShouldTestLink,
                                  icon: Icons.chat_bubble_outline_rounded,
                                  onTap: _openShouldTest),
                            ])
                        : null,
                  ),
                  const SizedBox(height: 14),
                ],

                // ⚠️ SIDE BY SIDE, AND THE "VIEW CHART" ROWS ARE GONE.
                //
                // Two things were wrong and they had the same root. Each card
                // was full width with a "View chart" row at its foot, and both
                // of those rows opened `_openReport` — the same screen the
                // "See your cycle report" button directly below them opens.
                // Three controls, one destination, stacked within an inch of
                // each other: *"for both of these buttons we have a View chart
                // option that is opening the same thing. It makes no sense at
                // all."*
                //
                // It made none. And the reason it happened is worth keeping:
                // "View chart" was written as a LABEL for a place, not as a
                // promise about content, so pointing all three at the only
                // chart screen we had felt like wiring rather than like a lie.
                // A reader does not experience it that way — they experience a
                // button that ignores which card it was on.
                //
                // The fix is not a third chart screen. It is that a sparkline
                // of her last fourteen readings fits inside the card, so the
                // chart is simply THERE and there is nothing to navigate to.
                // Removing a button by answering its question is better than
                // removing it by hiding it.
                //
                // Side by side then follows for free, and takes back the
                // vertical space the two full-width cards were spending to say
                // very little — *"they look very bland and cover too much
                // space."*
                // ⚠️ `IntrinsicHeight`, NOT `CrossAxisAlignment.stretch`, AND
                // THE DIFFERENCE IS A CRASH. `stretch` requires the Row to
                // already know its height; here it sits in a `ListView`, where
                // the height is unbounded, so it passes `h=Infinity` down and
                // layout throws.
                //
                // These two cards DO need to match — one may show a value and
                // a sparkline while the other says "not recorded", and cards of
                // different heights side by side read as a mistake.
                // `IntrinsicHeight` gets there the legal way: it measures both
                // children first, then constrains the Row to the taller one.
                //
                // It costs an extra layout pass over its subtree, which is
                // exactly why it is a bad default and fine here — two small
                // cards, laid out once per rebuild of a screen that is not
                // animating.
                IntrinsicHeight(
                  // So "Add today's temperature or weight" can open the log
                  // scrolled to these two (2026-09-28).
                  key: _keyFor(kTtcLogMeasurementsGroup),
                  child:
                      Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Expanded(
                    child: _MeasureCard(
                      label: t.logWeight,
                      unit: 'kg',
                      hue: 206,
                      value: TtcLogStore.instance
                          .valueFor(kTtcWeightTracker, kTtcWeightField,
                              on: _day)
                          ?.value,
                      series: TtcLogStore.instance
                          .history(kTtcWeightTracker, kTtcWeightField),
                      decimals: 1,
                      min: 30,
                      max: 200,
                      onSet: (v) =>
                          _setNumber(kTtcWeightTracker, kTtcWeightField, v),
                      p: p,
                      forLine: ttcLogSheetFor(_dayName, cycleDay),
                      dayName: _dayName,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MeasureCard(
                      label: t.logTemp,
                      unit: '\u00B0C',
                      hue: 42,
                      value: TtcLogStore.instance
                          .valueFor(kTtcTempTracker, kTtcTempField, on: _day)
                          ?.value,
                      series: TtcLogStore.instance
                          .history(kTtcTempTracker, kTtcTempField),
                      decimals: 2,
                      min: 34,
                      max: 40,
                      onSet: (v) =>
                          _setNumber(kTtcTempTracker, kTtcTempField, v),
                      p: p,
                      forLine: ttcLogSheetFor(_dayName, cycleDay),
                      dayName: _dayName,
                      // The fourteen-dot line gave way to the whole-cycle
                      // chart below.
                      //
                      // ⚠️ AND THE CARD NOW SAYS HOW TO TAKE IT (tools pass,
                      // 2026-09-27). A reading taken at noon looks like any
                      // other and means nothing; nothing said so. One line,
                      // and the read that explains it. Kept for revert:
                      //   under: Text(kTtcTempChartBelow,
                      //       style: ttcBody(11, color: ttcMuted, h: 1.35)),
                      under: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(kTtcTempHowTo,
                                key: const ValueKey('ttc_temp_how_to'),
                                style: ttcBody(11.5, color: ttcSoft, h: 1.4)),
                            if (ttcReadById(kTtcTempReadId) != null) ...[
                              const SizedBox(height: 6),
                              GestureDetector(
                                key: const ValueKey('ttc_temp_read_link'),
                                behavior: HitTestBehavior.opaque,
                                onTap: () => openTtcSurface(context,
                                    '$kTtcReadPrefix$kTtcTempReadId'),
                                child: Text(kTtcTempReadLink,
                                    style: ttcBody(11.5,
                                        color: ttcPurple,
                                        w: FontWeight.w800,
                                        h: 1.35)),
                              ),
                            ],
                          ]),
                    ),
                  ),
                ]),
                ),
                const SizedBox(height: 14),
                // ⚠️ THE WHOLE CYCLE ON ONE CHART (gap analysis, Behind ›
                // Logging, 2026-09-26). A morning temperature means nothing
                // as a fourteen-day squiggle; what makes it readable is
                // seeing it against the cycle, with the period and the
                // fertile days behind it. Still recorded, never interpreted:
                // nothing on it says "you ovulated here".
                _TempCycleChart(p: p),
                const SizedBox(height: 22),

                // ⚠️ ONE BUTTON, AND IT SAYS WHAT WAS KEPT (tool rebuild).
                // Taps save as they happen, so this saves nothing; it closes
                // and the screen she returns to says "3 things saved for
                // today". Without it the only way out was an × at the top,
                // which reads as "cancel" on every other screen she knows.
                TtcToolPrimary(
                    key: const ValueKey('ttc_log_done'),
                    label: kTtcLogDone,
                    onTap: () => _done(savedCount)),
                const SizedBox(height: 16),
                // Where the log is read back: the report shows every tap
                // across the cycle. A link, not a second button of the same
                // weight. Kept for revert:
                //   _QuietButton(label: t.logViewReport, onTap: _openReport),
                _LinkRow(
                    key: const ValueKey('ttc_log_open_report'),
                    label: t.logViewReport,
                    icon: Icons.insights_rounded,
                    onTap: _openReport),
                const SizedBox(height: 22),

                // The long disclaimer, as the question it answers. Kept for
                // revert: an info icon and t.logDisclaimer in full, always
                // open, at the very foot.
                _Fold(
                    question: kTtcLogPregnancyQuestion,
                    answer: t.logDisclaimer),
              ],
            )),
          ],
        );
      },
    );
  }

  /// The category cards below the feelings picker.
  ///
  /// ⚠️ `feeling` IS EXCLUDED, BECAUSE IT IS ALREADY THE TOP OF THE SCREEN.
  /// The objection was blunt and correct: *"we can see what are you feeling
  /// today and then we can see in categories how are you feeling. It's both the
  /// same... it's redundant, right?"*
  ///
  /// It was. The row showed four moods, the card below showed all eight of the
  /// same moods under a near-identical heading, and there was no rule anyone
  /// could have inferred for which one to use. Two controls writing to one
  /// field is not a shortcut, it is a question the screen is asking the reader
  /// to answer on its behalf.
  ///
  /// The merge went the way it did — row keeps everything, card goes — because
  /// the row is the better control for this particular group: eight moods are
  /// mutually informative and want to be seen at once, and bubbles read faster
  /// than chips. Nothing was dropped; the row now holds all eight.
  List<TtcSymptomGroup> _filtered() {
    final visible = [
      for (final g in kTtcCategoryGroups)
        if (!TtcCategoryPrefs.instance.isHidden(g.id)) g,
    ];
    if (_query.isEmpty) return visible;
    // ⚠️ SEARCH FINDS THE WORDS SHE WOULD TYPE (tools pass, 2026-09-27). It
    // matched chip labels only, so "could not sleep" missed "Couldn't sleep",
    // "cramps" missed "Cramping", and the feelings could not be searched at
    // all because their row hides while searching. Now a chip matches on its
    // label, a few everyday words (`kTtcLogSearchWords`), or its card's
    // title, and the feelings are searched as a card of their own. Kept for
    // revert:
    //   final q = _query.toLowerCase();
    //   return [
    //     for (final g in visible)
    //       if (g.symptoms.any((s) => s.label.toLowerCase().contains(q)))
    //         TtcSymptomGroup(... symptoms: g.symptoms
    //             .where((s) => s.label.toLowerCase().contains(q)).toList()),
    //   ];
    final feelings =
        kTtcSymptomGroups.firstWhere((g) => g.id == kTtcFeelingGroup);
    return [
      for (final g in [feelings, ...visible])
        if (g.symptoms.any((s) => ttcLogSearchMatches(g, s, _query)))
          TtcSymptomGroup(
            id: g.id,
            title: g.title,
            hue: g.hue,
            single: g.single,
            note: g.note,
            symptoms: g.symptoms
                .where((s) => ttcLogSearchMatches(g, s, _query))
                .toList(),
          ),
    ];
  }

  /// What is saved for the day on screen: chips, plus weight and temperature.
  int _savedCount(Set<String> selected) {
    final log = TtcLogStore.instance;
    return selected.length +
        (log.valueFor(kTtcWeightTracker, kTtcWeightField, on: _day) == null
            ? 0
            : 1) +
        (log.valueFor(kTtcTempTracker, kTtcTempField, on: _day) == null
            ? 0
            : 1);
  }
}

// Kept for revert (2026-09-27, tool rebuild): the day arrows now live in
// `_DayPicker`, in the hero.
// class _Arrow extends StatelessWidget {
//   const _Arrow({required this.icon, required this.on, required this.onTap});
//   final IconData icon;
//   final bool on;
//   final VoidCallback onTap;
//
//   @override
//   Widget build(BuildContext context) => IconButton(
//         icon: Icon(icon),
//         color: on ? ttcTitleInk : ttcBorder,
//         onPressed: on ? onTap : null,
//       );
// }

/// Every mood, as bubbles — the screen's primary control.
///
/// ⚠️ THIS SHIPPED WITH DISCHARGE TYPES IN IT AND THAT WAS NONSENSE. The row is
/// headed as a question about feelings and it offered *Egg white* and *Creamy*
/// alongside *Calm* and *Happy*. The reference does mix them under that
/// heading, and copying that was the mistake: a shortcut row is only worth
/// having if every item in it answers the heading, and nobody has ever felt
/// creamy.
///
/// Discharge is still fully loggable — it has its own category card, with its
/// own note explaining why it is the clearest free sign of the window. It is
/// simply not a mood.
///
/// ⚠️ EIGHT NOW, NOT FOUR, AND THE FEELINGS CATEGORY BELOW IS GONE. It used to
/// show `calm / happy / low / anxious` as "quick picks" while a category card
/// further down offered the same four plus energetic, irritated, mood swings
/// and tearful. So the shortcut was not a shortcut — it was a subset, and the
/// only way to reach half the moods was to scroll past a row that looked like
/// it had already asked.
///
/// ⚠️ ONE HEADING, TAKEN FROM THE GROUP ITSELF. It read "What are you feeling
/// today?" here and "How are you feeling?" on the card below — two names for
/// one thing, which is how a reader concludes they must be different things.
/// Using `group.title` means there is exactly one place to change it.
class _FeelingRow extends StatelessWidget {
  const _FeelingRow(
      {required this.selected, required this.onTap, required this.p});

  final Set<String> selected;
  final void Function(TtcSymptomGroup, TtcSymptom) onTap;
  final V2Palette p;

  @override
  Widget build(BuildContext context) {
    final feelings =
        kTtcSymptomGroups.firstWhere((g) => g.id == kTtcFeelingGroup);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 18),
      // A hairline since the rebuild: a white card on the tool sheet with no
      // edge is not a card (DESIGN-SYSTEM §4.0, white plus one hairline).
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ttcCardRadius),
        border: Border.all(color: ttcLine),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(feelings.title, style: ttcJakarta(16)),
        ),
        const SizedBox(height: 16),
        // ⚠️ FOUR PER ROW VIA `Expanded`, NOT A `Wrap` OF FIXED WIDTHS. Four
        // 74pt bubbles is 296pt and the card's content box on a 360pt screen is
        // 292 — a four-pixel overflow, which only ever shows up on a device.
        // Flexible children cannot overflow whatever the screen width is, and a
        // `Wrap` would leave the second row ragged rather than aligned under
        // the first.
        for (var i = 0; i < feelings.symptoms.length; i += 4) ...[
          if (i > 0) const SizedBox(height: 16),
          Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var j = 0; j < 4; j++)
                  if (i + j < feelings.symptoms.length)
                    Expanded(
                      child: _Bubble(
                        symptom: feelings.symptoms[i + j],
                        on: selected.contains(feelings.symptoms[i + j].id),
                        p: p,
                        onTap: () =>
                            onTap(feelings, feelings.symptoms[i + j]),
                      ),
                    )
                  else
                    // ⚠️ A SPACER, SO A SHORT LAST ROW STAYS LEFT-ALIGNED. With
                    // nine moods the last row holds one bubble; without this it
                    // would be a single `Expanded` filling the whole width and
                    // centring itself under four, which reads as a mistake.
                    const Expanded(child: SizedBox.shrink()),
              ]),
        ],
      ]),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble(
      {required this.symptom,
      required this.on,
      required this.p,
      required this.onTap});

  final TtcSymptom symptom;
  final bool on;
  final V2Palette p;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tint = v2BlockTint(symptom.hue, p);
    final deep = HSLColor.fromColor(tint)
        .withSaturation(0.5)
        .withLightness(0.42)
        .toColor();

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(children: [
          Stack(clipBehavior: Clip.none, children: [
            Container(
              width: 60,
              height: 60,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: tint,
                shape: BoxShape.circle,
                border: on ? Border.all(color: deep, width: 2) : null,
              ),
              // ⚠️ DRAWN, NOT TYPED. See `ttc_mood_face.dart` for why an
              // emoji was the wrong object here — briefly: it is rendered by
              // the OS, so it is a different picture on every phone, and it is
              // a glossy full-colour sticker on a screen made of flat tints.
              child: TtcSymptomMark(symptom: symptom, size: 30, ink: deep),
            ),
            if (on)
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  width: 20,
                  height: 20,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: deep,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2)),
                  child: const Icon(Icons.check_rounded,
                      size: 11, color: Colors.white),
                ),
              ),
          ]),
          const SizedBox(height: 8),
          // ⚠️ TWO LINES, NOT ONE. At four across, a bubble's column is about
          // 73pt and "Mood swings" does not fit — it clipped to "Mood swi…",
          // which is the row's longest label and now one of the eight rather
          // than one of four it never used to include. The Row above is
          // top-aligned so a taller label pushes nothing around.
          // ⚠️ AND NOW THREE. "Can't stop thinking about it" (2026-09-26)
          // is the longest label the row has held, and cut to two lines it
          // read "Can't stop thinking…", which drops the "it" that makes it
          // about trying. The row is top-aligned, so a third line pushes
          // nothing sideways.
          Text(symptom.label,
              maxLines: 3,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: ttcBody(11.5, color: ttcInk, w: FontWeight.w600)),
      ]),
    );
  }
}

/// One category, as a white card of chips.
class _CategoryCard extends StatelessWidget {
  const _CategoryCard(
      {super.key,
      required this.group,
      required this.selected,
      required this.onTap,
      required this.p,
      this.footer});

  final TtcSymptomGroup group;
  final Set<String> selected;
  final void Function(TtcSymptom) onTap;
  final V2Palette p;

  /// Something that belongs to this card only, under its chips.
  final Widget? footer;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(ttcCardRadius),
          border: Border.all(color: ttcLine),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ⚠️ "PICK ONE" ON THE TWO TEST CARDS (tools pass, 2026-09-27).
          // Every other card takes as many taps as she likes; these two swap
          // the old answer for the new one, and nothing said so, so a second
          // tap looked like it undid the first. Kept for revert:
          //   Text(group.title, style: ttcJakarta(16)),
          Row(crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic, children: [
            Expanded(child: Text(group.title, style: ttcJakarta(16))),
            if (group.single)
              Text(kTtcLogPickOne,
                  style: ttcBody(12, color: ttcMuted, w: FontWeight.w700)),
          ]),
          if (group.note != null) ...[
            const SizedBox(height: 5),
            Text(group.note!, style: ttcBody(12.5, color: ttcMuted, h: 1.45)),
          ],
          const SizedBox(height: 14),
          Wrap(spacing: 9, runSpacing: 9, children: [
            for (final s in group.symptoms)
              _Chip(
                symptom: s,
                groupHue: group.hue,
                on: selected.contains(s.id),
                p: p,
                onTap: () => onTap(s),
              ),
          ]),
          if (footer != null) ...[
            const SizedBox(height: 14),
            footer!,
          ],
        ]),
      );
}

/// A quiet link inside a card: words, and an arrow.
class _LinkRow extends StatelessWidget {
  const _LinkRow(
      {super.key,
      required this.label,
      required this.onTap,
      this.icon = Icons.menu_book_outlined});

  final String label;
  final VoidCallback onTap;

  /// A book for a read; a speech bubble for a chat.
  final IconData icon;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Row(children: [
          Icon(icon, size: 16, color: ttcPurple),
          const SizedBox(width: 8),
          Flexible(
            child: Text(label,
                style: ttcBody(13, color: ttcPurple, w: FontWeight.w800)),
          ),
          const Icon(Icons.chevron_right_rounded, size: 18, color: ttcPurple),
        ]),
      );
}

/// One gentle line under the feelings, with a way to something that helps.
///
/// ⚠️ WHITE, NOT A WARNING. It is not an alert and must not look like one:
/// no amber, no icon of a triangle. It is the app noticing, kindly.
class _GentleLine extends StatelessWidget {
  const _GentleLine({required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  // G5 (review, 2026-09-26): the heart is ink and the chevron grey, as on
  // every other row (violet is for eyebrows, links, switches and progress),
  // and the line presses. Kept for revert: both icons in ttcPurple, a bare
  // InkWell.
  @override
  Widget build(BuildContext context) => PvPress(
        child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ttcCardRadius),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(ttcCardRadius),
            border: Border.all(color: ttcLine),
          ),
          child: Row(children: [
            const Icon(Icons.favorite_border_rounded,
                size: 18, color: ttcSoft),
            const SizedBox(width: 11),
            Expanded(
              child: Text(text,
                  style: ttcBody(13.5, color: ttcInk, h: 1.45)),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right_rounded,
                size: 20, color: ttcMuted),
          ]),
        ),
      ));
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.symptom,
    required this.groupHue,
    required this.on,
    required this.p,
    required this.onTap,
  });

  final TtcSymptom symptom;
  final double groupHue;
  final bool on;
  final V2Palette p;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // ⚠️ THE CATEGORY'S HUE, NOT THE APP'S ACCENT. Every chip in one card
    // shares a colour so the card reads as a set, and no card is purple unless
    // its own subject is. That is the difference between a screen with colour
    // on it and a screen painted one colour.
    final tint = v2BlockTint(groupHue, p);
    final deep = HSLColor.fromColor(tint)
        .withSaturation(0.5)
        .withLightness(0.40)
        .toColor();

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 130),
        padding: const EdgeInsets.fromLTRB(6, 6, 14, 6),
        decoration: BoxDecoration(
          color: tint.withValues(alpha: on ? 1 : 0.45),
          borderRadius: BorderRadius.circular(999),
          border: on ? Border.all(color: deep, width: 1.6) : null,
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: deep, shape: BoxShape.circle),
            // ⚠️ ONE MARK COMPONENT FOR EVERY SYMPTOM. It used to be "emoji if
            // there is one, Material icon otherwise", which put two visual
            // languages inside a single `Wrap` of chips. `TtcSymptomMark`
            // resolves mood face / drawn glyph / icon-of-last-resort in one
            // place, so a card cannot be half-custom.
            child: TtcSymptomMark(
                symptom: symptom, size: 16, ink: Colors.white),
          ),
          const SizedBox(width: 9),
          // ⚠️ `Flexible`, BECAUSE A CHIP MUST NOT BE ABLE TO EXCEED ITS CARD.
          // The label was a bare `Text` in a `mainAxisSize: min` Row, so its
          // natural width won every argument — the chip simply grew until it
          // overflowed the `Wrap` that contains it.
          //
          // ⚠️ AND IT WAS FOUND BY A TEST FOR AN UNRELATED REASON, which is
          // worth recording. Widget tests render with a fallback font whose
          // glyphs are far wider than Manrope's, so "Everything is fine"
          // measures about 235pt in the suite and roughly 135 on a device.
          // That exaggeration is what made a latent bug visible.
          //
          // Latent, not imaginary: the same overflow arrives on a real phone
          // the moment the OS text scale goes up, which is a setting a lot of
          // people who are trying to conceive at 5am actually use. A layout
          // that only holds at one font size is a layout that is one accessible
          // setting away from breaking.
          Flexible(
            child: Text(symptom.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: pvManrope(
                    fontSize: 13,
                    fontWeight: on ? FontWeight.w800 : FontWeight.w600,
                    color: ttcTitleInk)),
          ),
          if (on) ...[
            const SizedBox(width: 7),
            Icon(Icons.check_circle_rounded, size: 15, color: deep),
          ],
        ]),
      ),
    );
  }
}

/// One reading: its value, and the shape it has been making.
///
/// ⚠️ THE CHART IS IN THE CARD, NOT BEHIND A ROW THAT SAYS "VIEW CHART". See
/// the call site for why the row had to go; what matters here is that a
/// fourteen-point sparkline answers the only question the row was ever asked —
/// *is this going up or down?* — in the space the row itself occupied.
///
/// ⚠️ AND IT IS THE FIRST `fl_chart` IN THE REPO. Every other chart in this app
/// is a hand-written `CustomPainter`, and most of them should stay that way:
/// they plot one series against cycle PHASES, which is a bespoke axis no
/// library ships. These two are ordinary time series, where the fiddly parts —
/// gaps between readings, a flat series, the y-range, touch targets — are
/// exactly what a chart library has already solved.
class _MeasureCard extends StatelessWidget {
  const _MeasureCard({
    required this.label,
    required this.unit,
    required this.hue,
    required this.value,
    required this.series,
    required this.decimals,
    required this.min,
    required this.max,
    required this.onSet,
    required this.p,
    this.under,
    this.forLine = '',
    this.dayName = 'Today',
  });

  /// What sits under the number. Null draws the fourteen-reading sparkline.
  final Widget? under;

  /// "For today · Cycle day 7", at the top of the sheet: which day the number
  /// lands on, because the logger can be on any past day (tool rebuild).
  final String forLine;

  /// "Today", "Yesterday", "Wed 24 Sep", for the saved line.
  final String dayName;

  final String label;
  final String unit;
  final double hue;

  /// Today's reading, if there is one.
  final double? value;

  /// Every reading ever taken for this field, oldest first.
  final List<TtcLogValue> series;

  final int decimals;
  final double min;
  final double max;
  final void Function(double?) onSet;
  final V2Palette p;

  @override
  Widget build(BuildContext context) {
    final tint = v2BlockTint(hue, p);
    final deep = HSLColor.fromColor(tint)
        .withSaturation(0.46)
        .withLightness(0.40)
        .toColor();

    return InkWell(
      onTap: () => _pick(context),
      borderRadius: BorderRadius.circular(ttcCardRadius),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 13, 14, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(ttcCardRadius),
          border: Border.all(color: ttcLine),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: tint, borderRadius: BorderRadius.circular(9)),
              child: Icon(
                  unit == 'kg'
                      ? Icons.monitor_weight_outlined
                      : Icons.thermostat_rounded,
                  size: 15,
                  color: deep),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: ttcJakarta(12.5)),
            ),
          ]),
          const SizedBox(height: 12),
          if (value == null)
            Text(TtcS.current().logNotRecorded,
                style: ttcBody(12.5, color: ttcMuted))
          else
            // ⚠️ `FittedBox`, NOT `Flexible` WITH AN ELLIPSIS, AND THE CHOICE
            // MATTERS. This row is a NUMBER and its unit; "36.6…" is not a
            // smaller version of the reading, it is a different and wrong one.
            // Ellipsising type is right for a label and never right for a
            // measurement — scaling down keeps every digit and only costs a
            // point or two of size in the rare case it is needed.
            //
            // Needed when: the card is half the screen, and at a large OS text
            // scale a two-decimal temperature plus a unit runs past it. Caught
            // by the render test at 360pt, where the fallback font is wider
            // than Fraunces — the same exaggeration that surfaced the chip.
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(value!.toStringAsFixed(decimals),
                    style:
                        ttcFraunces(25, w: FontWeight.w600, color: ttcTitleInk)),
                const SizedBox(width: 3),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(unit, style: ttcBody(11, color: ttcMuted)),
                ),
              ]),
            ),
          const SizedBox(height: 10),
          // ⚠️ THE TEMPERATURE CARD NO LONGER DRAWS THE SPARKLINE (2026-09-26).
          // Fourteen dots of temperature with no cycle behind them could not
          // show the one thing a morning temperature is for, so the whole-cycle
          // chart under the two cards replaced it. Weight keeps its line. The
          // old call, kept for revert, was the unconditional:
          //   SizedBox(height: 38, child: _Spark(series: series, ink: deep)),
          // ⚠️ AND THE LINE SAYS WHICH DAYS IT COVERS (tools pass,
          // 2026-09-27): a shape with no dates could not be read. Kept for
          // revert:
          //   under ?? SizedBox(height: 38, child: _Spark(series: series, ink: deep)),
          under ??
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SizedBox(height: 38, child: _Spark(series: series, ink: deep)),
                if (ttcSparkSpan(series) case final span?) ...[
                  const SizedBox(height: 4),
                  Text(span,
                      key: const ValueKey('ttc_spark_span'),
                      style: ttcBody(10.5, color: ttcMuted)),
                ],
              ]),
          // ⚠️ THE CARD SAYS WHAT A TAP DOES (tool rebuild, 2026-09-27). It
          // was a whole card that happened to be tappable, reading "Not
          // recorded", with nothing on it that looked like a control. Flo's
          // weight card carries its pencil on the face; ours says the word.
          const SizedBox(height: 10),
          Row(
              key: ValueKey('ttc_measure_action_$unit'),
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(value == null ? Icons.add_rounded : Icons.edit_outlined,
                    size: 15, color: ttcPurple),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(value == null ? kTtcMeasureAdd : kTtcMeasureChange,
                      style: ttcBody(12.5, color: ttcPurple, w: FontWeight.w800)),
                ),
              ]),
        ]),
      ),
    );
  }

  // ⚠️ THE SHEET, REBUILT (tool rebuild, 2026-09-27). What changed, and why:
  //  · It says which day the number lands on ("For Wed 24 Sep · Cycle day
  //    7"). The logger can be on any past day, and a sheet that did not say so
  //    was one way a reading ended up on the wrong morning.
  //  · − and + either side of the number (Lifesum's "Update your weight"),
  //    one step each, for the nudge from yesterday's reading. The ruler stays
  //    for a bigger move and a tap on the number still types it.
  //  · The units are one segment, white on grey like every other tool sheet's
  //    choice, not two purple chips stacked beside the number.
  //  · "Save", because that is what it does ("Done" is the logger's way out).
  //  · "Remove this reading" in words, with an Undo on the screen behind,
  //    instead of a bare bin icon in the corner with no way back.
  //  · The temperature sheet repeats how to take it, where she is entering it.
  Future<void> _pick(BuildContext context) async {
    final metric = unit == 'kg' ? 'kg' : '°C';
    final imperial = unit == 'kg' ? 'lbs' : '°F';
    final isTemp = unit != 'kg';
    var useImperial = false;
    var v = value ?? (unit == 'kg' ? 60.0 : 36.5);
    var typing = false;
    var typedText = '';
    // Bumped when the number moves by anything but the ruler, so the ruler
    // remounts on it.
    var moved = 0;

    // ⚠️ THE STORE ALWAYS HOLDS METRIC. The toggle converts for display only.
    double toDisplay(double m) => useImperial
        ? (unit == 'kg' ? m * 2.20462 : m * 9 / 5 + 32)
        : m;
    double fromDisplay(double shown) => useImperial
        ? (unit == 'kg' ? shown / 2.20462 : (shown - 32) * 5 / 9)
        : shown;

    void takeTyped() {
      if (!typing) return;
      final n = double.tryParse(typedText.trim());
      if (n != null) {
        v = fromDisplay(n).clamp(min, max).toDouble();
        moved++;
      }
      typing = false;
    }

    final messengerContext = context;
    final old = value;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      routeSettings: RouteSettings(name: 'ttc/symptom_log/$unit'),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) {
          final shown = toDisplay(v);
          final dp = useImperial && isTemp ? 1 : decimals;
          final step = unit == 'kg'
              ? (useImperial ? 0.2 : 0.1)
              : (useImperial ? 0.1 : 0.05);

          void nudge(int dir) => setSheet(() {
                takeTyped();
                final next = toDisplay(v) + dir * step;
                v = fromDisplay(next).clamp(min, max).toDouble();
                moved++;
              });

          return Padding(
            padding:
                EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.fromLTRB(0, 14, 0, 20),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                            color: ttcLine,
                            borderRadius: BorderRadius.circular(999)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(children: [
                        IconButton(
                          tooltip: 'Close',
                          icon: const Icon(Icons.close_rounded),
                          color: ttcTitleInk,
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                        Expanded(
                          child: Column(children: [
                            Text(label,
                                textAlign: TextAlign.center,
                                style: ttcJakarta(17)),
                            if (forLine.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(forLine,
                                  key: const ValueKey('ttc_measure_for'),
                                  textAlign: TextAlign.center,
                                  style: ttcBody(12, color: ttcMuted)),
                            ],
                          ]),
                        ),
                        // Balances the close button so the title centres.
                        const SizedBox(width: 48),
                      ]),
                    ),
                    const SizedBox(height: 14),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      _Nudge(
                          key: const ValueKey('ttc_measure_minus'),
                          icon: Icons.remove_rounded,
                          label: 'Less',
                          onTap: () => nudge(-1)),
                      const SizedBox(width: 14),
                      if (typing)
                        SizedBox(
                          width: 140,
                          child: _TypedNumber(
                            initial: typedText,
                            onChanged: (t) => typedText = t,
                            onSubmitted: () => setSheet(takeTyped),
                          ),
                        )
                      else
                        Flexible(
                          child: Semantics(
                            button: true,
                            label:
                                '${shown.toStringAsFixed(dp)}. $kTtcMeasureTypeHint',
                            excludeSemantics: true,
                            child: GestureDetector(
                              key: const ValueKey('ttc_measure_number'),
                              behavior: HitTestBehavior.opaque,
                              onTap: () => setSheet(() {
                                typing = true;
                                typedText = shown.toStringAsFixed(dp);
                              }),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(shown.toStringAsFixed(dp),
                                          style: ttcFraunces(38,
                                              w: FontWeight.w600,
                                              color: ttcTitleInk)),
                                      const SizedBox(width: 4),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 7),
                                        child: Text(
                                            useImperial ? imperial : metric,
                                            style:
                                                ttcBody(13, color: ttcMuted)),
                                      ),
                                    ]),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(width: 14),
                      _Nudge(
                          key: const ValueKey('ttc_measure_plus'),
                          icon: Icons.add_rounded,
                          label: 'More',
                          onTap: () => nudge(1)),
                    ]),
                    const SizedBox(height: 4),
                    Text(typing ? kTtcMeasureTypingHint : kTtcMeasureTypeHint,
                        style: ttcBody(11.5, color: ttcMuted)),
                    const SizedBox(height: 10),
                    _Ruler(
                      // ⚠️ REMOUNTS ON A UNIT CHANGE OR ANY OTHER MOVE. The
                      // ruler holds a scroll offset, and an offset means a
                      // different number once the range under it changes.
                      key: ValueKey((useImperial, moved)),
                      value: shown,
                      min: toDisplay(min),
                      max: toDisplay(max),
                      step: step,
                      decimals: dp,
                      onChanged: (n) => setSheet(() => v = fromDisplay(n)),
                    ),
                    const SizedBox(height: 12),
                    // The units, as one segment.
                    SizedBox(
                      width: 200,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                            color: ttcPanel,
                            borderRadius: BorderRadius.circular(999)),
                        child: Row(children: [
                          _UnitSeg(
                              label: metric,
                              on: !useImperial,
                              onTap: () => setSheet(() {
                                    takeTyped();
                                    useImperial = false;
                                    moved++;
                                  })),
                          _UnitSeg(
                              label: imperial,
                              on: useImperial,
                              onTap: () => setSheet(() {
                                    takeTyped();
                                    useImperial = true;
                                    moved++;
                                  })),
                        ]),
                      ),
                    ),
                    if (isTemp) ...[
                      const SizedBox(height: 14),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(kTtcTempHowTo,
                            key: const ValueKey('ttc_measure_temp_how_to'),
                            textAlign: TextAlign.center,
                            style: ttcBody(12.5, color: ttcSoft, h: 1.45)),
                      ),
                    ],
                    const SizedBox(height: 18),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TtcToolPrimary(
                        key: const ValueKey('ttc_measure_save'),
                        label: kTtcMeasureSave,
                        onTap: () {
                          takeTyped();
                          onSet(double.parse(v.toStringAsFixed(decimals)));
                          Navigator.of(ctx).pop();
                          pvSnack(messengerContext,
                              ttcLogMeasureSaved(label, dayName),
                              icon: Icons.check_rounded, lift: 24);
                        },
                      ),
                    ),
                    if (old != null) ...[
                      const SizedBox(height: 6),
                      GestureDetector(
                        key: const ValueKey('ttc_measure_remove'),
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          onSet(null);
                          Navigator.of(ctx).pop();
                          pvSnack(messengerContext, ttcLogRemovedLine(label),
                              action: 'Undo',
                              lift: 24,
                              onAction: () => onSet(old));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(kTtcMeasureRemove,
                              style: ttcBody(13,
                                  color: ttcMuted, w: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ]),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Kept for revert (2026-09-27, tool rebuild): the sheet before, with Done,
  // a bin icon in the corner and the units as two purple chips.
  // Future<void> _pick(BuildContext context) async {
  //   final metric = unit == 'kg' ? 'kg' : '\u00B0C';
  //   final imperial = unit == 'kg' ? 'lbs' : '\u00B0F';
  //   var useImperial = false;
  //   var v = value ?? (unit == 'kg' ? 60.0 : 36.5);
  //
  //   // ⚠️ TYPE IT AS WELL AS SCROLL IT (tools pass, 2026-09-27). Reaching
  //   // 68.4 kg from 60 was a long scroll; a number she already knows is a
  //   // number she wants to type (Amazon's typed weight with a unit switch,
  //   // mobbin 28d92f63). Tapping the big number turns it into a field; the
  //   // ruler stays for a nudge.
  //   var typing = false;
  //   // The typed text. The field owns its controller (`_TypedNumber`), so it
  //   // is disposed with the field and never while the sheet animates away.
  //   var typedText = '';
  //   // Bumped when a typed number lands, so the ruler remounts on it.
  //   var typedTimes = 0;
  //
  //   // ⚠️ THE UNIT TOGGLE IS THE POINT OF THIS SHEET, and it was missing.
  //   //
  //   // The reference offers kg/lbs and °C/°F right in the picker, and for an
  //   // India-first product that ships to people who think in either, a logger
  //   // that only accepts kilograms is a logger some people cannot use honestly.
  //   //
  //   // ⚠️ THE STORE ALWAYS HOLDS METRIC. The toggle converts for display only,
  //   // and the value written back is always kg or °C. A unit stored alongside
  //   // each reading would mean the chart has to convert per point and any code
  //   // that forgets is silently wrong by a factor of two.
  //   double toDisplay(double metricValue) => useImperial
  //       ? (unit == 'kg' ? metricValue * 2.20462 : metricValue * 9 / 5 + 32)
  //       : metricValue;
  //   double fromDisplay(double shown) => useImperial
  //       ? (unit == 'kg' ? shown / 2.20462 : (shown - 32) * 5 / 9)
  //       : shown;
  //
  //   // A typed number, in the units on screen, into [v] (kept in metric and
  //   // inside the ruler's range). Anything that is not a number leaves [v].
  //   void takeTyped() {
  //     if (!typing) return;
  //     final n = double.tryParse(typedText.trim());
  //     if (n != null) {
  //       v = fromDisplay(n).clamp(min, max).toDouble();
  //       typedTimes++;
  //     }
  //     typing = false;
  //   }
  //
  //   await showModalBottomSheet<void>(
  //     context: context,
  //     backgroundColor: Colors.white,
  //     // Scroll-controlled, so the keyboard can push the sheet up.
  //     isScrollControlled: true,
  //     shape: const RoundedRectangleBorder(
  //         borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
  //     builder: (ctx) => StatefulBuilder(
  //       builder: (ctx, setSheet) {
  //         final shown = toDisplay(v);
  //
  //         // ⚠️ THE RULER IS BUILT IN DISPLAY UNITS, so its range and its step
  //         // both have to convert with the toggle. A ruler ticking every 0.1 kg
  //         // ticks every 0.22 lb, which reads as a broken scale — so each unit
  //         // gets a step chosen for itself rather than a converted one.
  //         final dp = useImperial && unit != 'kg' ? 1 : decimals;
  //         final step = unit == 'kg'
  //             ? (useImperial ? 0.2 : 0.1)
  //             : (useImperial ? 0.1 : 0.05);
  //
  //         return Padding(
  //           padding: EdgeInsets.fromLTRB(
  //               0, 10, 0, 26 + MediaQuery.viewInsetsOf(ctx).bottom),
  //           child: Column(mainAxisSize: MainAxisSize.min, children: [
  //             Padding(
  //               padding: const EdgeInsets.symmetric(horizontal: 20),
  //               child: Row(children: [
  //                 IconButton(
  //                   icon: const Icon(Icons.close_rounded),
  //                   color: ttcTitleInk,
  //                   onPressed: () => Navigator.of(ctx).pop(),
  //                 ),
  //                 Expanded(
  //                     child: Text(label,
  //                         textAlign: TextAlign.center,
  //                         style: ttcJakarta(16))),
  //                 // ⚠️ CLEARING MOVED HERE FROM THE CARD FACE. It was a bin
  //                 // icon sitting on the card next to a pencil, so a card
  //                 // holding one number carried two controls and neither was
  //                 // the obvious one. Deleting a reading is rare and belongs
  //                 // where you already are to change it.
  //                 SizedBox(
  //                   width: 48,
  //                   child: value == null
  //                       ? null
  //                       : IconButton(
  //                           icon: const Icon(Icons.delete_outline_rounded,
  //                               size: 20),
  //                           color: ttcMuted,
  //                           onPressed: () {
  //                             onSet(null);
  //                             Navigator.of(ctx).pop();
  //                           },
  //                         ),
  //                 ),
  //               ]),
  //             ),
  //             const SizedBox(height: 6),
  //             Row(mainAxisAlignment: MainAxisAlignment.center, children: [
  //               // Kept for revert: the bare Text(shown.toStringAsFixed(dp)).
  //               if (typing)
  //                 SizedBox(
  //                   width: 150,
  //                   child: _TypedNumber(
  //                     initial: typedText,
  //                     onChanged: (t) => typedText = t,
  //                     onSubmitted: () => setSheet(takeTyped),
  //                   ),
  //                 )
  //               else
  //                 Semantics(
  //                   button: true,
  //                   label: '${shown.toStringAsFixed(dp)}. $kTtcMeasureTypeHint',
  //                   excludeSemantics: true,
  //                   child: GestureDetector(
  //                     key: const ValueKey('ttc_measure_number'),
  //                     behavior: HitTestBehavior.opaque,
  //                     onTap: () => setSheet(() {
  //                       typing = true;
  //                       typedText = shown.toStringAsFixed(dp);
  //                     }),
  //                     child: Text(shown.toStringAsFixed(dp),
  //                         style: ttcFraunces(38,
  //                             w: FontWeight.w600, color: ttcTitleInk)),
  //                   ),
  //                 ),
  //               const SizedBox(width: 8),
  //               // The two units, as a segment. Tapping converts what is on
  //               // screen; it never changes what is stored.
  //               Column(mainAxisSize: MainAxisSize.min, children: [
  //                 _UnitChip(
  //                     label: metric,
  //                     on: !useImperial,
  //                     onTap: () => setSheet(() {
  //                           takeTyped();
  //                           useImperial = false;
  //                         })),
  //                 const SizedBox(height: 4),
  //                 _UnitChip(
  //                     label: imperial,
  //                     on: useImperial,
  //                     onTap: () => setSheet(() {
  //                           takeTyped();
  //                           useImperial = true;
  //                         })),
  //               ]),
  //             ]),
  //             const SizedBox(height: 4),
  //             Text(typing ? kTtcMeasureTypingHint : kTtcMeasureTypeHint,
  //                 style: ttcBody(11.5, color: ttcMuted)),
  //             const SizedBox(height: 10),
  //             _Ruler(
  //               // ⚠️ REMOUNTS ON A UNIT CHANGE. The ruler holds a scroll
  //               // offset, and an offset means a different number once the
  //               // range under it changes — without the key it would keep the
  //               // pixel position and silently report the wrong value.
  //               // The value too, so a typed number moves the ruler to it.
  //               // Kept for revert: key: ValueKey(useImperial),
  //               key: ValueKey((useImperial, typedTimes)),
  //               value: shown,
  //               min: toDisplay(min),
  //               max: toDisplay(max),
  //               step: step,
  //               decimals: dp,
  //               onChanged: (n) => setSheet(() => v = fromDisplay(n)),
  //             ),
  //             const SizedBox(height: 18),
  //             Padding(
  //               padding: const EdgeInsets.symmetric(horizontal: 20),
  //               child: _QuietButton(
  //                 label: 'Done',
  //                 onTap: () {
  //                   takeTyped();
  //                   onSet(double.parse(v.toStringAsFixed(decimals)));
  //                   Navigator.of(ctx).pop();
  //                 },
  //               ),
  //             ),
  //           ]),
  //         );
  //       },
  //     ),
  //   );
  // }
}

/// Her morning temperatures across the whole cycle.
///
/// ⚠️ WHAT IT DRAWS AND WHAT IT REFUSES TO. Days run along the bottom, the
/// period and the fertile days are shaded behind, and a dotted line marks the
/// average of her readings before the estimated ovulation day. It never draws
/// "the shift", never marks a day as the ovulation, never colours a reading
/// as good or bad. A rise she can see for herself; the one line of text under
/// the chart tells her what a rise usually means.
///
/// ⚠️ NO SHADING ON A CLINIC'S CYCLE. `ttcBuildTempChart` returns no bands
/// when a clinic owns the timing or the engine will not estimate, and the
/// chart then shows her readings alone with a sentence saying why.
///
/// ⚠️ A HAND-DRAWN AXIS IS NOT NEEDED HERE, UNLIKE THE PHASE CHARTS. The phase
/// pictures elsewhere plot against cycle PHASES, which no library ships; this
/// is day number against temperature, an ordinary chart, so `fl_chart` does it
/// and its range annotations do the bands.
class _TempCycleChart extends StatelessWidget {
  const _TempCycleChart({required this.p});

  final V2Palette p;

  static const double _hue = 42;

  @override
  Widget build(BuildContext context) {
    final chart = ttcBuildTempChart();
    final tint = v2BlockTint(_hue, p);
    // ⚠️ THE CYCLE PALETTE, NOT HUES TYPED HERE (tool rebuild, 2026-09-27).
    // Fertile days were green on this chart (hue 160) while the Companion,
    // calendar and report now draw them violet: one fact, two colours,
    // which is the "colours thrown around randomly" the user named. The
    // bands take the cycle palette's tints, and her readings are ink, the
    // palette's colour for a thing she logged. Kept for revert:
    //   final ink = HSLColor.fromColor(tint)
    //       .withSaturation(0.46).withLightness(0.40).toColor();
    //   final periodTint = v2BlockTint(344, p);
    //   final fertileTint = v2BlockTint(160, p);
    const ink = TtcCycleColours.logged;
    const periodTint = TtcCycleColours.periodTint;
    const fertileTint = TtcCycleColours.fertileTint;
    final wellInk = HSLColor.fromColor(tint)
        .withSaturation(0.46)
        .withLightness(0.40)
        .toColor();

    final String? message = !chart.hasCycle
        ? kTtcTempChartNoCycle
        : chart.state == TtcReportState.clinicHeld
            ? kTtcTempChartClinic
            : !chart.shaded
                ? kTtcTempChartNoEstimate
                : chart.points.isEmpty
                    ? kTtcTempChartNoReadings
                    : null;

    // ⚠️ THE REVIEW PASS (2026-09-26, G1 to G4). G1: the card has its
    // hairline, because a white card on a white page with no edge is not a
    // card (§4.0: white plus one hairline). G2: tap a dot to read it, and a
    // thin line marks today, the way Oura's cycle chart reads (OURA-TEMP,
    // https://mobbin.com/screens/02bc9ee3-1c59-4141-a934-ef325fc0819d).
    // G3: the legend names the ovulation day as estimated. G4: axis labels
    // at 11, the smallest role in the type scale.
    return Container(
      key: const ValueKey('ttc_temp_chart_card'),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ttcCardRadius),
        border: Border.all(color: ttcLine),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: tint, borderRadius: BorderRadius.circular(9)),
            child: Icon(Icons.show_chart_rounded, size: 15, color: wellInk),
          ),
          const SizedBox(width: 9),
          Expanded(
              child: Text(kTtcTempChartTitle, style: ttcJakarta(14.5))),
        ]),
        if (message != null) ...[
          const SizedBox(height: 10),
          Text(message, style: ttcBody(12.5, color: ttcMuted, h: 1.45)),
        ],
        if (chart.hasCycle) ...[
          const SizedBox(height: 14),
          SizedBox(
            height: 170,
            child: _plot(chart, ink, periodTint, fertileTint),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(kTtcTempChartAxis,
                style: ttcBody(11, color: ttcMuted)),
          ),
          const SizedBox(height: 10),
          // The key. `Wrap`, so three entries never overflow at 360pt.
          Wrap(spacing: 14, runSpacing: 6, children: [
            if (chart.shaded) ...[
              _Key(swatch: _swatch(periodTint), label: kTtcTempLegendPeriod),
              if (chart.fertileFrom != null)
                _Key(
                    swatch: _swatch(fertileTint),
                    label: kTtcTempLegendFertile),
            ],
            if (chart.averageBefore != null)
              _Key(
                  swatch: SizedBox(
                      width: 16,
                      height: 10,
                      child: CustomPaint(painter: _DashPainter(ink))),
                  label: kTtcTempLegendAverage),
            if (chart.todayDay != null)
              _Key(
                  swatch: Container(width: 1.5, height: 12, color: ttcInk),
                  label: kTtcTempLegendToday),
          ]),
        ],
        const SizedBox(height: 12),
        Container(height: 1, color: ttcLine),
        const SizedBox(height: 10),
        Text(kTtcTempChartNote,
            style: ttcBody(12, color: ttcInk, h: 1.5)),
      ]),
    );
  }

  static Widget _swatch(Color c) => Container(
        width: 12,
        height: 12,
        decoration:
            BoxDecoration(color: c, borderRadius: BorderRadius.circular(3)),
      );

  Widget _plot(
      TtcTempChart chart, Color ink, Color periodTint, Color fertileTint) {
    final ys = [
      for (final pt in chart.points) pt.celsius,
      if (chart.averageBefore != null) chart.averageBefore!,
    ];
    // ⚠️ A FIXED FLOOR WHEN THERE IS NOTHING TO FIT. With no readings the
    // bands still draw, so she can see where her period and fertile days
    // fall, and they need a y range to sit in. 36 to 37 is where almost every
    // waking temperature lands.
    var lo = ys.isEmpty ? 36.0 : ys.reduce((a, b) => a < b ? a : b) - 0.2;
    var hi = ys.isEmpty ? 37.0 : ys.reduce((a, b) => a > b ? a : b) + 0.2;
    if (hi - lo < 0.6) {
      final mid = (hi + lo) / 2;
      lo = mid - 0.3;
      hi = mid + 0.3;
    }
    lo = (lo * 10).floorToDouble() / 10;
    hi = (hi * 10).ceilToDouble() / 10;
    final yStep = hi - lo > 1.2 ? 0.5 : 0.2;

    // Each band covers its days edge to edge, so it spans day ± half.
    final bands = <VerticalRangeAnnotation>[
      if (chart.periodTo != null)
        VerticalRangeAnnotation(
            x1: 0.5, x2: chart.periodTo! + 0.5, color: periodTint),
      if (chart.fertileFrom != null && chart.fertileTo != null)
        VerticalRangeAnnotation(
            x1: chart.fertileFrom! - 0.5,
            x2: chart.fertileTo! + 0.5,
            color: fertileTint),
    ];

    return LineChart(
      LineChartData(
        minX: 0.5,
        maxX: chart.days + 0.5,
        minY: lo,
        maxY: hi,
        rangeAnnotations: RangeAnnotations(verticalRangeAnnotations: bands),
        extraLinesData: ExtraLinesData(horizontalLines: [
          if (chart.averageBefore != null)
            HorizontalLine(
              y: chart.averageBefore!,
              color: ink.withValues(alpha: 0.75),
              strokeWidth: 1.4,
              dashArray: const [4, 4],
            ),
        ], verticalLines: [
          // G2: a thin ink line at today. A position, never a verdict.
          if (chart.todayDay != null)
            VerticalLine(
              x: chart.todayDay!.toDouble(),
              color: ttcInk.withValues(alpha: 0.55),
              strokeWidth: 1,
            ),
        ]),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: yStep,
          getDrawingHorizontalLine: (_) =>
              const FlLine(color: ttcLine, strokeWidth: 0.6),
        ),
        borderData: FlBorderData(show: false),
        // G2: tap a dot to read it, a small ink label with the day and the
        // reading, nothing else. Kept for revert:
        //   lineTouchData: const LineTouchData(enabled: false),
        lineTouchData: LineTouchData(
          enabled: chart.points.isNotEmpty,
          handleBuiltInTouches: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => ttcInk,
            tooltipBorderRadius: BorderRadius.circular(10),
            tooltipPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipItems: (spots) => [
              for (final s in spots)
                LineTooltipItem(
                  ttcTempTooltip(s.x.round(), s.y),
                  ttcBody(11.5, color: Colors.white, w: FontWeight.w700),
                ),
            ],
          ),
          getTouchedSpotIndicator: (bar, indexes) => [
            for (final _ in indexes)
              TouchedSpotIndicatorData(
                FlLine(color: ttcInk.withValues(alpha: 0.3), strokeWidth: 1),
                FlDotData(
                  getDotPainter: (_, _, _, _) => FlDotCirclePainter(
                      radius: 4.2,
                      color: ink,
                      strokeWidth: 2,
                      strokeColor: Colors.white),
                ),
              ),
          ],
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 34,
              interval: yStep,
              getTitlesWidget: (v, meta) {
                // fl_chart also labels the two edges; skip the ones off-step.
                final onStep = ((v - lo) / yStep - ((v - lo) / yStep).round())
                        .abs() <
                    0.01;
                if (!onStep) return const SizedBox.shrink();
                return Text(v.toStringAsFixed(1),
                    style: ttcBody(11, color: ttcMuted));
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 20,
              interval: 1,
              getTitlesWidget: (v, meta) {
                final d = v.round();
                // Day 1, then every seventh day: a week to a tick.
                if ((v - d).abs() > 0.01 || d < 1 || d > chart.days) {
                  return const SizedBox.shrink();
                }
                if (d != 1 && d % 7 != 0) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('$d', style: ttcBody(11, color: ttcMuted)),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          if (chart.points.isNotEmpty)
            LineChartBarData(
              spots: [
                for (final pt in chart.points)
                  FlSpot(pt.cycleDay.toDouble(), pt.celsius),
              ],
              // Straight segments. A curve would invent readings between the
              // mornings she took one.
              isCurved: false,
              barWidth: 1.8,
              color: ink,
              dotData: FlDotData(
                show: true,
                getDotPainter: (_, _, _, _) => FlDotCirclePainter(
                    radius: 2.6,
                    color: ink,
                    strokeWidth: 1.4,
                    strokeColor: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({required this.swatch, required this.label});

  final Widget swatch;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          swatch,
          const SizedBox(width: 6),
          Flexible(
            child: Text(label,
                style: ttcBody(11, color: ttcMuted),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      );
}

/// The legend's short dotted line, matching the average line on the chart.
class _DashPainter extends CustomPainter {
  const _DashPainter(this.ink);
  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ink
      ..strokeWidth = 1.4;
    final y = size.height / 2;
    for (var x = 0.0; x < size.width; x += 6) {
      canvas.drawLine(Offset(x, y), Offset((x + 3).clamp(0, size.width), y),
          paint);
    }
  }

  @override
  bool shouldRepaint(_DashPainter old) => old.ink != ink;
}

/// The last fourteen readings, as a line.
///
/// ⚠️ FOURTEEN, NOT ALL OF THEM. A sparkline is for the SHAPE of the recent
/// past, and a year of daily weights compressed into 130 points is a texture,
/// not a trend. Two weeks is roughly half a cycle, which is the window in which
/// a basal-temperature shift is actually worth seeing.
class _Spark extends StatelessWidget {
  const _Spark({required this.series, required this.ink});

  final List<TtcLogValue> series;
  final Color ink;

  @override
  Widget build(BuildContext context) {
    final recent =
        series.length <= 14 ? series : series.sublist(series.length - 14);

    // ⚠️ ONE POINT IS NOT A LINE. Two readings are the minimum that can show a
    // direction, and drawing a single dot on an empty field looks like a
    // rendering failure rather than like "you have logged this once".
    if (recent.length < 2) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Text(
            recent.isEmpty ? 'No readings yet' : 'One reading so far',
            style: ttcBody(11, color: ttcMuted)),
      );
    }

    final ys = recent.map((v) => v.value).toList();
    var lo = ys.reduce((a, b) => a < b ? a : b);
    var hi = ys.reduce((a, b) => a > b ? a : b);
    // ⚠️ A FLAT SERIES IS THE INTERESTING EDGE CASE. Identical readings give
    // lo == hi, and a zero-height range either divides by zero or pins every
    // point to one edge. "Her weight did not change" has to render as a line
    // through the middle, which is what padding a zero span does.
    if (hi - lo < 1e-9) {
      lo -= 1;
      hi += 1;
    } else {
      final pad = (hi - lo) * 0.15;
      lo -= pad;
      hi += pad;
    }

    return LineChart(
      LineChartData(
        minY: lo,
        maxY: hi,
        minX: 0,
        maxX: (recent.length - 1).toDouble(),
        // Every piece of chrome off. At 38pt tall there is no room for an axis,
        // and a sparkline that carries labels is just a small bad chart.
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: const LineTouchData(enabled: false),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (var i = 0; i < recent.length; i++)
                FlSpot(i.toDouble(), recent[i].value),
            ],
            isCurved: true,
            // Keeps the curve from overshooting past a local peak, which on a
            // 38pt canvas puts the line outside its own box.
            preventCurveOverShooting: true,
            barWidth: 2,
            color: ink,
            dotData: FlDotData(
              // Only the newest reading gets a dot — it is the one the number
              // above the chart is showing, and marking it ties the two
              // together without speckling the line.
              show: true,
              checkToShowDot: (spot, _) => spot.x == recent.length - 1,
              getDotPainter: (spot, _, _, _) => FlDotCirclePainter(
                  radius: 3,
                  color: ink,
                  strokeWidth: 2,
                  strokeColor: Colors.white),
            ),
            belowBarData: BarAreaData(
                show: true, color: ink.withValues(alpha: 0.10)),
          ),
        ],
      ),
    );
  }
}

/// A horizontal ruler you scroll to a value.
///
/// ⚠️ A RULER RATHER THAN A SLIDER, and it is not only a look. Asked for:
/// *"can the representation be a scroll for temperature and body weight? Let
/// the user do it, input it the way our competitor app is having."*
///
/// The reason it is genuinely better here is resolution. A slider maps its
/// whole range onto the screen's width, so weight from 30 to 200 kg is 170 kg
/// across roughly 320 points — about half a kilo per pixel, and hitting 62.4
/// exactly is luck. A ruler maps a fixed distance to each STEP and lets the
/// content scroll, so precision is constant no matter how wide the range is,
/// and 30–200 kg simply becomes a longer ruler rather than a coarser one.
///
/// The trade is that you can no longer see the whole range at once. For a body
/// weight nobody wants to: she is moving by grams from where she already is,
/// not choosing a point on a scale from thirty to two hundred.
class _Ruler extends StatefulWidget {
  const _Ruler({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.step,
    required this.decimals,
    required this.onChanged,
  });

  final double value;
  final double min;
  final double max;
  final double step;
  final int decimals;
  final ValueChanged<double> onChanged;

  @override
  State<_Ruler> createState() => _RulerState();
}

class _RulerState extends State<_Ruler> {
  /// Points per step. Wide enough that a thumb can settle on one tick, narrow
  /// enough that a whole unit is a comfortable flick rather than a swipe.
  static const double _tick = 9;
  static const double _height = 62;

  late final ScrollController _sc = ScrollController();
  bool _placed = false;

  int get _count => ((widget.max - widget.min) / widget.step).round() + 1;

  @override
  void dispose() {
    _sc.dispose();
    super.dispose();
  }

  void _place() {
    if (_placed || !_sc.hasClients) return;
    _placed = true;
    final i = ((widget.value - widget.min) / widget.step).round();
    _sc.jumpTo((i * _tick).clamp(0.0, _sc.position.maxScrollExtent));
  }

  void _report() {
    if (!_sc.hasClients) return;
    final i = (_sc.offset / _tick).round().clamp(0, _count - 1);
    final v = widget.min + i * widget.step;
    // ⚠️ ROUNDED THROUGH THE STEP, NOT PASSED RAW. `offset / _tick` is a
    // double, so without this the reported value carries pixel noise — 62.400001
    // — and `toStringAsFixed` then shows a number the ruler is not pointing at.
    widget.onChanged(
        double.parse(v.toStringAsFixed(widget.decimals + 2)));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _height,
      child: LayoutBuilder(builder: (context, box) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _place());
        final half = box.maxWidth / 2;

        return Stack(alignment: Alignment.center, children: [
          NotificationListener<ScrollNotification>(
            onNotification: (n) {
              if (n is ScrollUpdateNotification) _report();
              return false;
            },
            child: ListView.builder(
              controller: _sc,
              scrollDirection: Axis.horizontal,
              // ⚠️ HALF A VIEWPORT OF PADDING EACH END. Without it the first
              // and last ticks can never reach the centre indicator, so the two
              // extremes of the range are unselectable — a bug that only shows
              // up if someone tries to log 30 kg.
              padding: EdgeInsets.symmetric(horizontal: half - _tick / 2),
              itemCount: _count,
              itemBuilder: (context, i) {
                // A labelled major tick once per whole unit.
                final atUnit =
                    ((widget.min + i * widget.step) % 1).abs() < widget.step / 2;
                final major = atUnit;
                return SizedBox(
                  width: _tick,
                  child: Column(children: [
                    const SizedBox(height: 6),
                    Container(
                      width: 1.5,
                      height: major ? 22 : 12,
                      decoration: BoxDecoration(
                        color: major ? ttcMuted : ttcLine,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                    if (major) ...[
                      const SizedBox(height: 5),
                      // One line, drawn past the 9pt slot (2026-09-27): in a
                      // 9pt-wide column "60" wrapped to two lines and pushed
                      // the column past the ruler's height.
                      Text((widget.min + i * widget.step).round().toString(),
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.visible,
                          style: ttcBody(9.5, color: ttcMuted)),
                    ],
                  ]),
                );
              },
            ),
          ),
          // The indicator, drawn over the ruler and never moving. Purple,
          // because it is the one thing on this sheet the reader is steering.
          IgnorePointer(
            child: Column(children: [
              Container(
                width: 3,
                height: 34,
                margin: const EdgeInsets.only(top: 2),
                // Ink since the rebuild, the colour of the number it points
                // at; purple is for links and switches. Was ttcPurple.
                decoration: BoxDecoration(
                  color: ttcTitleInk,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ]),
          ),
        ]);
      }),
    );
  }
}

// kg | lbs, °C | °F.
// Kept for revert (2026-09-27, tool rebuild): the purple unit chips, now
// `_UnitSeg` in one segment.
// class _UnitChip extends StatelessWidget {
//   const _UnitChip(
//       {required this.label, required this.on, required this.onTap});
//
//   final String label;
//   final bool on;
//   final VoidCallback onTap;
//
//   @override
//   Widget build(BuildContext context) => GestureDetector(
//         onTap: onTap,
//         behavior: HitTestBehavior.opaque,
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
//           decoration: BoxDecoration(
//             color: on ? ttcPurple : Colors.transparent,
//             borderRadius: BorderRadius.circular(999),
//             border: on ? null : Border.all(color: ttcLine),
//           ),
//           child: Text(label,
//               style: ttcBody(12,
//                   color: on ? Colors.white : ttcMuted, w: FontWeight.w800)),
//         ),
//       );
// }

// This stage's button: white with a hairline, or coral when it is genuinely
// the single action on a sheet.
//
// ⚠️ NOT PURPLE, EITHER WAY — see the head of the file.
// Kept for revert (2026-09-27, tool rebuild): the stage button, now
// `TtcToolPrimary` from the tool shell, which is the same white with a hairline.
// class _QuietButton extends StatelessWidget {
//   const _QuietButton({required this.label, required this.onTap});
//
//   final String label;
//   final VoidCallback onTap;
//
//   /// ⚠️ ONE BUTTON TREATMENT ON THIS STAGE: white with a hairline. The filled
//   /// variant is gone — it existed for one "Done" and shipped coral, which is
//   /// the period marker in this stage and belongs to nothing else.
//   @override
//   Widget build(BuildContext context) => InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(999),
//         child: Container(
//           width: double.infinity,
//           padding: const EdgeInsets.symmetric(vertical: 15),
//           alignment: Alignment.center,
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(999),
//             border: Border.all(color: ttcLine),
//           ),
//           child: Text(label,
//               style: pvManrope(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w800,
//                   color: ttcTitleInk)),
//         ),
//       );
// }

// ---- plain words for the logger (tools pass, 2026-09-27) -------------------

/// The one line at the top: what she does here, that it saves, and what it
/// is not. The full disclaimer stays at the foot.
const String kTtcLogHowItWorks =
    'Tap anything that fits the day. Each tap saves straight away. This is a '
    'record for you, never a diagnosis.';

/// The heading over the cards, and the link that shows or hides them.
const String kTtcLogMoreHeading = 'More to log';
const String kTtcLogShowHide = kTtcEditCategoriesTitle;

/// On the two test cards, where a new answer replaces the old one.
const String kTtcLogPickOne = 'Pick one';

/// A search that finds no chip.
const String kTtcLogSearchNothing =
    'Nothing here matches that. Try a shorter word, like "sleep" or "pain".';

/// Under the temperature card: how to take it, and the read that explains it.
const String kTtcTempHowTo =
    'Take it before you get up, at the same time each morning.';
const String kTtcTempReadLink = 'How temperature tracking works';
const String kTtcTempReadId = 'ttc_read_ovulation_kits';

/// The number sheet's hint, before and while typing.
const String kTtcMeasureTypeHint = 'Tap the number to type it';
const String kTtcMeasureTypingHint = 'Type the number, then tap Done';

/// "3 things saved", under the day, or an invitation when nothing is.
String ttcLogSavedLine(int n) => n == 0
    ? 'Nothing saved for this day yet'
    : n == 1
        ? '1 thing saved for this day'
        : '$n things saved for this day';

class _SavedCount extends StatelessWidget {
  const _SavedCount({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) => Row(
        key: const ValueKey('ttc_log_saved_count'),
        mainAxisSize: MainAxisSize.min,
        children: [
          if (count > 0) ...[
            const Icon(Icons.check_circle_rounded, size: 15, color: ttcSoft),
            const SizedBox(width: 6),
          ],
          // Flexible, so a large text size wraps instead of overflowing.
          Flexible(
            child: Text(ttcLogSavedLine(count),
                textAlign: TextAlign.center,
                style: ttcBody(12.5, color: ttcSoft, w: FontWeight.w700)),
          ),
        ],
      );
}

/// The everyday words a chip also answers to, by symptom id. Search only:
/// nothing here is saved, and a chip's label is still its name.
const Map<String, List<String>> kTtcLogSearchWords = {
  'insomnia': ['sleep', 'could not sleep', 'cant sleep', 'sleepless'],
  'fatigue': ['tired', 'exhausted', 'energy', 'fatigue', 'sleepy'],
  'cramping': ['cramp', 'period pain', 'pain'],
  'pelvic_pain': ['pain', 'ovary', 'ovulation pain', 'pelvic'],
  'backache': ['back pain', 'pain'],
  'headache': ['head', 'migraine', 'pain'],
  'breast': ['breast', 'boobs', 'chest', 'sore'],
  'nausea': ['sick', 'vomit', 'queasy'],
  'bloating': ['bloated', 'gas', 'swollen'],
  'disch_spotting': ['spot', 'bleeding', 'blood'],
  'disch_eggwhite': ['mucus', 'cervical', 'stretchy', 'clear'],
  'disch_watery': ['mucus', 'cervical', 'wet'],
  'disch_creamy': ['mucus', 'cervical', 'white'],
  'disch_sticky': ['mucus', 'cervical'],
  'ov_positive': ['lh', 'opk', 'ovulation', 'strip'],
  'ov_negative': ['lh', 'opk', 'ovulation', 'strip'],
  'ov_none': ['lh', 'opk', 'ovulation', 'strip'],
  'pt_positive': ['hcg', 'pregnant', 'upt', 'pregnancy'],
  'pt_negative': ['hcg', 'pregnant', 'upt', 'pregnancy'],
  'pt_faint': ['hcg', 'pregnant', 'upt', 'pregnancy', 'faint'],
  'pt_none': ['hcg', 'pregnant', 'upt', 'pregnancy'],
  'sex_unprotected': ['intercourse', 'sex', 'intimate'],
  'sex_protected': ['intercourse', 'sex', 'condom'],
  'anxious': ['worried', 'worry', 'anxiety', 'nervous'],
  'low': ['sad', 'down', 'depressed', 'upset'],
  'tearful': ['cry', 'crying', 'tears'],
  'irritated': ['angry', 'annoyed', 'irritable'],
  'stress': ['stressed', 'tension'],
  'exercise': ['workout', 'gym', 'exercise'],
  'walk': ['walking', 'steps'],
};

/// True when a search for [query] should show [symptom] from [group].
bool ttcLogSearchMatches(
    TtcSymptomGroup group, TtcSymptom symptom, String query) {
  String norm(String s) =>
      s.toLowerCase().replaceAll("'", '').replaceAll('’', '').trim();
  final q = norm(query);
  if (q.isEmpty) return true;
  if (norm(symptom.label).contains(q)) return true;
  if (norm(group.title).contains(q)) return true;
  for (final w in kTtcLogSearchWords[symptom.id] ?? const <String>[]) {
    if (norm(w).contains(q) || q.contains(norm(w))) return true;
  }
  return false;
}

/// For a search that means one of the two number cards, where to find it.
String? ttcLogNumberHint(String query) {
  final q = query.toLowerCase().trim();
  const temp = ['bbt', 'temp', 'temperature', 'thermometer', 'basal'];
  const weight = ['weight', 'kg', 'weigh'];
  if (temp.any((w) => w.startsWith(q) || q.startsWith(w))) {
    return 'Morning temperature has its own card, further down this page.';
  }
  if (weight.any((w) => w.startsWith(q) || q.startsWith(w))) {
    return 'Weight has its own card, further down this page.';
  }
  return null;
}

/// "12 Sep to 26 Sep" for the readings a sparkline draws, or null below two.
String? ttcSparkSpan(List<TtcLogValue> series) {
  final recent =
      series.length <= 14 ? series : series.sublist(series.length - 14);
  if (recent.length < 2) return null;
  const m = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  String fmt(String key) {
    final d = DateTime.tryParse(key);
    return d == null ? key : '${d.day} ${m[d.month - 1]}';
  }

  return '${fmt(recent.first.dayKey)} to ${fmt(recent.last.dayKey)}';
}

/// The number field in the measure sheet, owning its own controller.
class _TypedNumber extends StatefulWidget {
  const _TypedNumber({
    required this.initial,
    required this.onChanged,
    required this.onSubmitted,
  });

  final String initial;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmitted;

  @override
  State<_TypedNumber> createState() => _TypedNumberState();
}

class _TypedNumberState extends State<_TypedNumber> {
  late final TextEditingController _c =
      TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
        key: const ValueKey('ttc_measure_type_field'),
        controller: _c,
        autofocus: true,
        textAlign: TextAlign.center,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
        ],
        onChanged: widget.onChanged,
        onSubmitted: (_) => widget.onSubmitted(),
        style: ttcFraunces(34, w: FontWeight.w600, color: ttcTitleInk),
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: ttcPanel,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      );
}

// =============================================================================
//  The rebuilt logger's parts and words (tool rebuild, 2026-09-27, night)
// =============================================================================

/// Body and cycle's hue in Tools, where the "Symptoms and mood" tile sits.
const double kTtcLogHue = 172;

/// The Tools tile's name, word for word: the eyebrow is the tool's name.
const String kTtcLogEyebrow = 'Symptoms and mood';

/// The hero title, a question about the day on screen.
String ttcLogTitle(String dayName) => switch (dayName) {
      'Today' => 'How is today going?',
      'Yesterday' => 'How was yesterday?',
      _ => 'How was $dayName?',
    };

/// The day as it sits inside a sentence: "today", "yesterday", "Wed 24 Sep".
String ttcLogDayInLine(String dayName) =>
    dayName == 'Today' || dayName == 'Yesterday'
        ? dayName.toLowerCase()
        : dayName;

/// Over the calendar the day's name opens.
const String kTtcLogPickDayTitle = 'Which day do you want to log?';

/// Under the day picker when she is on a past day.
const String kTtcLogBackToToday = 'Back to today';

/// The logger's one button, and the line it leaves behind.
const String kTtcLogDone = 'Done';
String ttcLogDoneLine(int n, String dayName) {
  final d = ttcLogDayInLine(dayName);
  return n == 1 ? '1 thing saved for $d' : '$n things saved for $d';
}

/// The snack after an × in the saved list, or "Remove this reading".
String ttcLogRemovedLine(String label) => 'Removed: $label';

/// Under "More to log", when she has hidden cards.
String ttcLogHiddenLine(int n) => n == 1
    ? '1 card is hidden. Tap Show or hide to bring it back.'
    : '$n cards are hidden. Tap Show or hide to bring them back.';

/// The fold at the foot that holds the long disclaimer.
const String kTtcLogPregnancyQuestion = "Can these tell me if I'm pregnant?";

/// On the weight and temperature cards, and in their sheet.
const String kTtcMeasureAdd = 'Add';
const String kTtcMeasureChange = 'Change';
const String kTtcMeasureSave = 'Save';
const String kTtcMeasureRemove = 'Remove this reading';

/// "For today · Cycle day 7", at the top of the number sheet.
String ttcLogSheetFor(String dayName, int? cycleDay) {
  final d = 'For ${ttcLogDayInLine(dayName)}';
  return cycleDay == null ? d : '$d · Cycle day $cycleDay';
}

/// "Weight saved for today".
String ttcLogMeasureSaved(String label, String dayName) =>
    '$label saved for ${ttcLogDayInLine(dayName)}';

/// One thing saved for the day, as the saved list shows it.
class _SavedItem {
  const _SavedItem(this.tracker, this.field, this.label);
  final String tracker;
  final String field;
  final String label;
}

/// The day, in the hero: arrows either side, and a name that opens a calendar.
///
/// ⚠️ THE SAME SHAPE AS THE CYCLE REPORT'S PICKER, on purpose. Two tools that
/// both scope a page to "which one" should look like one control, so she
/// learns it once (the user: "maintain symmetry in design").
class _DayPicker extends StatelessWidget {
  const _DayPicker({
    required this.label,
    required this.caption,
    required this.canGoForward,
    required this.onBack,
    required this.onForward,
    required this.onPick,
    this.onToday,
  });

  final String label;
  final String? caption;
  final bool canGoForward;
  final VoidCallback onBack;
  final VoidCallback onForward;
  final VoidCallback onPick;

  /// Shown only on a past day.
  final VoidCallback? onToday;

  @override
  Widget build(BuildContext context) => Column(children: [
        Row(children: [
          IconButton(
            key: const ValueKey('ttc_log_day_back'),
            icon: const Icon(Icons.chevron_left_rounded),
            tooltip: 'Day before',
            color: ttcTitleInk,
            onPressed: onBack,
          ),
          Expanded(
            child: Semantics(
              button: true,
              label: '$label. Pick another day',
              excludeSemantics: true,
              child: GestureDetector(
                key: const ValueKey('ttc_log_day_name'),
                behavior: HitTestBehavior.opaque,
                onTap: onPick,
                child: Column(children: [
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    Flexible(child: Text(label, style: ttcJakarta(16))),
                    const SizedBox(width: 6),
                    const Icon(Icons.calendar_today_rounded,
                        size: 14, color: ttcPurple),
                  ]),
                  if (caption != null) ...[
                    const SizedBox(height: 2),
                    Text(caption!,
                        style: ttcBody(11.5,
                            color: ttcMuted, w: FontWeight.w700)),
                  ],
                ]),
              ),
            ),
          ),
          IconButton(
            key: const ValueKey('ttc_log_day_forward'),
            icon: const Icon(Icons.chevron_right_rounded),
            tooltip: 'Day after',
            color: canGoForward ? ttcTitleInk : ttcBorder,
            onPressed: canGoForward ? onForward : null,
          ),
        ]),
        if (onToday != null)
          GestureDetector(
            key: const ValueKey('ttc_log_back_to_today'),
            behavior: HitTestBehavior.opaque,
            onTap: onToday,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Text(kTtcLogBackToToday,
                  style: ttcBody(12.5, color: ttcPurple, w: FontWeight.w800)),
            ),
          ),
      ]);
}

/// What is saved for the day, each with an × that takes it off.
class _SavedCard extends StatelessWidget {
  const _SavedCard(
      {required this.count, required this.items, required this.onRemove});

  final int count;
  final List<_SavedItem> items;
  final void Function(_SavedItem) onRemove;

  @override
  Widget build(BuildContext context) => Container(
        key: const ValueKey('ttc_log_saved_card'),
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: ttcLine),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _SavedCount(count: count),
          if (items.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final i in items)
                _SavedChip(item: i, onRemove: () => onRemove(i)),
            ]),
          ],
        ]),
      );
}

class _SavedChip extends StatelessWidget {
  const _SavedChip({required this.item, required this.onRemove});

  final _SavedItem item;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: 'Remove ${item.label}',
        excludeSemantics: true,
        child: GestureDetector(
          key: ValueKey('ttc_log_saved_${item.field}'),
          behavior: HitTestBehavior.opaque,
          onTap: onRemove,
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 7, 8, 7),
            decoration: BoxDecoration(
              color: ttcPanel,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Flexible(
                child: Text(item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ttcBody(12.5,
                        color: ttcTitleInk, w: FontWeight.w700)),
              ),
              const SizedBox(width: 5),
              const Icon(Icons.close_rounded, size: 15, color: ttcSoft),
            ]),
          ),
        ),
      );
}

/// − or + beside the number in the sheet: one step of the ruler.
class _Nudge extends StatelessWidget {
  const _Nudge(
      {super.key,
      required this.icon,
      required this.label,
      required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: label,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: ttcLine, width: 1.5),
            ),
            child: Icon(icon, size: 20, color: ttcTitleInk),
          ),
        ),
      );
}

/// One half of the unit segment: white on grey when chosen, like every other
/// choice on a TTC tool sheet.
class _UnitSeg extends StatelessWidget {
  const _UnitSeg({required this.label, required this.on, required this.onTap});

  final String label;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: on ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(label,
                style: ttcBody(13,
                    color: on ? ttcTitleInk : ttcMuted,
                    w: on ? FontWeight.w800 : FontWeight.w600)),
          ),
        ),
      );
}

/// A question she can open, for the long disclaimer at the foot.
class _Fold extends StatefulWidget {
  const _Fold({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  State<_Fold> createState() => _FoldState();
}

class _FoldState extends State<_Fold> {
  bool _open = false;

  @override
  Widget build(BuildContext context) => Container(
        key: const ValueKey('ttc_log_fold'),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: ttcLine),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          InkWell(
            onTap: () => setState(() => _open = !_open),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
              child: Row(children: [
                const Icon(Icons.info_outline_rounded,
                    size: 17, color: ttcSoft),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(widget.question,
                      style: ttcBody(13.5,
                          color: ttcTitleInk, w: FontWeight.w700)),
                ),
                AnimatedRotation(
                  turns: _open ? 0.5 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: const Icon(Icons.expand_more_rounded,
                      size: 20, color: ttcMuted),
                ),
              ]),
            ),
          ),
          if (_open)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(widget.answer,
                  style: ttcBody(13, color: ttcInk, h: 1.55)),
            ),
        ]),
      );
}

/// The focus id for the weight and morning temperature cards (2026-09-28): pass
/// it as [TtcSymptomLogScreen.focusGroup] to open the log scrolled to them.
const String kTtcLogMeasurementsGroup = 'measurements';
