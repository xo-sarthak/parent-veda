// =============================================================================
//  YogaHomeScreen - ParentVeda Yoga & Classes home (cult.fit-style)
// -----------------------------------------------------------------------------
//  An image-led marketplace of yoga & wellbeing classes for the whole journey -
//  prenatal, postnatal, post-IVF, breathing/Lamaze, meditation and core recovery.
//  A top Live / Recorded toggle, and under Live a 1:1 / Group toggle, resolve to
//  three effective modes. Below the toggles, cult.fit-style category sections:
//  each a header + a horizontal scroll of large "image" cards (title overlaid +
//  an EXPLORE pill), filtered to the selected mode. A search bar spans all modes.
//  Reached from the Explore drawer. Pushed screen (back link, no bottom nav).
//
//  ON THE ONE PARENTVEDA LOOK (2026-10-07). The page wears the shared tool
//  shell (`PregToolScaffold`), the same field, round back and drawn mark as
//  every TTC and pregnancy tool, so the pregnancy Prepare tab (which opens this
//  same screen, filtered) and parenting's Explore get one page. The two mode
//  toggles are `PvChip`s; each category is a rail of white hairline cards.
//  Mobbin: Open's Discover, a small-caps rail header and under each picture
//  just the title, then "30 min - teacher" (mobbin.com/screens/a9149d6b-362f-
//  4673-bc79-c52e2cec9dcf). Adopted: the title-then-duration-and-teacher card,
//  the save mark on the picture. Kept out, per the parenting trust rules: the
//  star rating the old cards showed (`cls.rating`), which no real review
//  stands behind. The teacher's name still opens her profile
//  (`yogaInstructorLine`). The old build is kept below for revert.
//
//  THE ONE YOGA & FITNESS HUB (2026-10-16). After the Yog4Lyf comparison the
//  user walked the app and found yoga scattered: a retired month-tab screen
//  wired back in from the Move door, this marketplace behind Prepare, and a
//  way in per stage. This screen is now the ONE hub for all three stages, the
//  way the store became one store. Mobbin decided the UX, the app's own chrome
//  decides the look:
//    For you / All               Tonal Explore  (mobbin.com/screens/efb364af-d90c-4f41-a5a2-18edc1c9829a)
//    chip row with All, big cards Peloton Classes (mobbin.com/screens/660faab6-e6a4-470a-b139-fda69e4bd2b6)
//    count line, active filters   Equinox+       (mobbin.com/screens/00ba8848-6018-4b9c-9d99-e01dfa59c012)
//    titled rails with See all     Fitbit         (mobbin.com/screens/3b31174e-5841-45df-a679-d85df702abf8)
//    a stage's own fitness row     Flo            (mobbin.com/screens/7a7ca385-7a01-4a1f-94a6-fe2c6fc80a93)
//  "For you" is derived, never asked: her cycle phase in TTC, her month in
//  pregnancy, the weeks since birth (and a caesarean) after it. "All" is the
//  whole catalogue (`pv_move_catalog.dart`) with a stage label on every card.
//  The page before the hub is kept below as `_buildRailsPage`, for revert.
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/garbh_data.dart' show garbhMonth;
import '../../data/move/pv_move_catalog.dart';
import '../../data/prepare_data.dart' show yogaSessionsForMonth;
// import '../../localization/app_language.dart'; // kept for revert: only the old session push used it
import '../../services/family_profile.dart';
import '../../services/life_stage_store.dart';
import '../../services/pregnancy_controller.dart';
import '../../theme/pv_fonts.dart';
import '../../ttc/ttc_home_situation.dart' show ttcHomePhaseOn;
import '../../ttc/ttc_mind_today.dart' show ttcTodaysMove, ttcPracticeAsTip;
import '../../ttc/ttc_phase.dart';
import '../../widgets/pv_feedback.dart';
import '../brackets/hub/hub_intent_art.dart' show HubIntentArt, IntentMark;
import '../doors/pv_door_router.dart' show openPvDoorRead;
import '../doors/pv_list_row.dart';
import '../learn/pv_learn_catalog.dart';
import '../learn/pv_offering_screen.dart' show pvOpenOffering;
import '../pregnancy/preg_tool_chrome.dart';
// import '../prepare/prepare_video_screen.dart'; // kept for revert (2026-10-17)
import '../products/pv_store_chrome.dart'
    show PvChip, PvCommit, PvSecondary, PvSectionHead;
import '../tools/kegel_care_screen.dart';
import '../ttc/ttc_daily_tip_open.dart' show openTtcTipRead, ttcMovementAsRead;
import '../v2/v2_palette.dart';
import '../v2/v3_film_screen.dart';
import 'pp_care_parts.dart' show ppCareHeading;
import 'pp_common.dart';
import 'pp_age_bands.dart' show ppDaysSinceBirth;
import 'pp_child_profile.dart' show ChildProfileStore;
import 'pp_section_extras.dart';
import 'pp_yoga_data.dart';
import 'yoga_class_screen.dart';
import 'yoga_common.dart';

class YogaHomeScreen extends StatefulWidget {
  const YogaHomeScreen({
    super.key,
    this.categoryFilter,
    this.backLabel = 'Explore',
    this.eyebrow = 'ParentVeda',
    this.heroTitle = 'Yoga & fitness',
    this.intro,
    this.pregnancy,
    this.startOnAll = false,
    this.startChip = 'all',
  });
  // Kept for revert: the defaults before the hub (2026-10-16).
  //   this.eyebrow = 'ParentVeda Yoga',
  //   this.heroTitle = 'Yoga & parenting classes',
  //   this.intro = 'Expert-led classes for every stage - pregnancy, recovery,
  //       IVF, breath and calm. Live with a teacher, or on your own time.',

  /// If set, only these category ids are shown — how the SAME cult.fit screen
  /// serves the pregnancy Prepare tab (prenatal/breathing/…) and the parenting
  /// Explore tab (everything). Null = show all (the parenting default, kept
  /// exactly as it was).
  final Set<String>? categoryFilter;
  final String backLabel;
  final String eyebrow;
  final String heroTitle;

  /// Null = the stage's own line (`_introFor`).
  final String? intro;

  /// Her pregnancy, for the month row. Null falls back to
  /// `PregnancyController.current`, so a caller without one still gets it.
  final PregnancyController? pregnancy;

  /// Open on All instead of For you, on [startChip].
  final bool startOnAll;
  final String startChip;

  @override
  State<YogaHomeScreen> createState() => _YogaHomeScreenState();
}

/// The pregnancy Prepare tab uses this SAME screen, limited to the categories a
/// pregnant mother wants — the content is already tagged, so it is a filter, not
/// a new screen.
const Set<String> kPregnancyYogaCategories = {
  'prenatal',
  'breathing',
  'meditation',
  'yoga',
};

class _YogaHomeScreenState extends State<YogaHomeScreen> {
  // The hub's state (2026-10-16): For you or All, the All chip, the Filter
  // sheet's modes (empty = every mode).
  late bool _forYou = !widget.startOnAll;
  late String _chip = widget.startChip;
  final Set<YogaMode> _modes = {};

  bool _live = true; // Live vs Recorded (top toggle)
  bool _group = true; // within Live: Group vs 1:1

  final TextEditingController _searchCtl = TextEditingController();
  String _query = '';

  YogaMode get _mode => !_live
      ? YogaMode.recorded
      : (_group ? YogaMode.liveGroup : YogaMode.liveOneToOne);

  @override
  void dispose() {
    _searchCtl.dispose();
    super.dispose();
  }

  Widget _pad(Widget c) =>
      Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);
  void _open(YogaClass c) => Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => YogaClassScreen(cls: c)));
  // ===========================================================================
  //  The hub (2026-10-16)
  // ===========================================================================

  LifeStage? get _stage => LifeStageStore.instance.stage;
  PregnancyController? get _preg =>
      widget.pregnancy ?? PregnancyController.current;

  static String _introFor(LifeStage? s) => switch (s) {
    LifeStage.tryingToConceive =>
      'Gentle movement that follows your cycle, and classes with a teacher.',
    LifeStage.pregnancy =>
      'Safe movement for your month, and classes with a teacher.',
    LifeStage.parenting =>
      'Recovery first, then strength. With a teacher, or on your own time.',
    _ => 'Yoga, breath and movement for every stage.',
  };

  void _openItem(PvMoveItem i) {
    pvCommitFeedback();
    switch (i.kind) {
      case PvMoveKind.yogaClass:
        _open(i.yogaClass!);
      case PvMoveKind.session:
        final s = i.session!;
        // 2026-10-17: a session opens the house film page, not the old
        // striped Prepare player (the user found it on the phone walk).
        // Kept for revert:
        //   Navigator.of(context).push(
        //     MaterialPageRoute<void>(
        //       builder: (_) => PrepareVideoScreen(
        //         lang: _preg?.language ?? AppLanguage.english,
        //         title: s.title.now,
        //         subtitle: '${s.duration.now} · ${s.focus.now}',
        //         blurb: s.blurb.now,
        //       ),
        //     ),
        //   );
        final film = pvSessionFilm(s);
        final now = _preg?.currentWeek;
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            settings: const RouteSettings(name: 'move/session'),
            builder: (_) => V3FilmScreen(
              video: film,
              week: now != null && film.matchesWeek(now) ? now : film.weekStart,
              pregnancy: _preg,
              // The saved-films list reads kVideos; a saved session would
              // vanish from it.
              canSave: false,
            ),
          ),
        );
      case PvMoveKind.practice:
        openTtcTipRead(
          context,
          ttcMovementAsRead(ttcPracticeAsTip(i.practice!)),
        );
      case PvMoveKind.offering:
        final v = PvLearnCatalog.instance.byId(i.id);
        if (v != null) pvOpenOffering(context, v);
    }
  }

  static String _modeLabel(YogaMode m) => switch (m) {
    YogaMode.liveGroup => 'Live group',
    YogaMode.liveOneToOne => 'Live 1:1',
    YogaMode.recorded => 'On your own time',
  };

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        YogaStore.instance,
        LifeStageStore.instance,
      ]),
      builder: (context, _) {
        final p = V2PaletteStore.instance.current;
        final searching = _query.trim().isNotEmpty;
        return Stack(
          children: [
            PregToolScaffold(
              hue: 280,
              eyebrow: widget.eyebrow,
              mark: IntentMark.lotusMark,
              title: widget.heroTitle,
              intro: widget.intro ?? _introFor(_stage),
              children: [
                pregToolPad(
                  TextField(
                    key: const ValueKey('yoga_search'),
                    controller: _searchCtl,
                    onChanged: (v) => setState(() => _query = v),
                    style: pvManrope(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: p.ink1,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search classes, practices, teachers…',
                      hintStyle: pvManrope(fontSize: 15, color: p.ink3),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        size: 20,
                        color: p.ink3,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(999),
                        borderSide: BorderSide(color: p.line),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(999),
                        borderSide: BorderSide(color: p.line),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(999),
                        borderSide: BorderSide(color: p.ink1),
                      ),
                    ),
                  ),
                ),
                if (searching)
                  ..._hubSearch(p)
                else ...[
                  const SizedBox(height: 14),
                  // For you / All (Tonal's Explore).
                  pregToolPad(
                    Row(
                      children: [
                        KeyedSubtree(
                          key: const ValueKey('move_seg_foryou'),
                          child: PvChip(
                            label: 'For you',
                            selected: _forYou,
                            onTap: () => setState(() => _forYou = true),
                          ),
                        ),
                        const SizedBox(width: 8),
                        KeyedSubtree(
                          key: const ValueKey('move_seg_all'),
                          child: PvChip(
                            label: 'All',
                            selected: !_forYou,
                            onTap: () => setState(() => _forYou = false),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: Column(
                      key: ValueKey(_forYou ? 'foryou' : 'all_$_chip'),
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: _forYou ? _forYouView(p) : _allView(p),
                    ),
                  ),
                  const SizedBox(height: 96),
                ],
              ],
            ),
            // The floating Filter pill (Peloton, Tonal), on All only.
            if (!searching && !_forYou)
              Positioned(
                left: 0,
                right: 0,
                bottom: 24 + MediaQuery.paddingOf(context).bottom,
                child: Center(child: _filterPill(p)),
              ),
          ],
        );
      },
    );
  }

  // ---- For you ---------------------------------------------------------------

  List<Widget> _forYouView(V2Palette p) => switch (_stage) {
    LifeStage.tryingToConceive => _forYouTtc(p),
    LifeStage.pregnancy => _forYouPregnancy(p),
    LifeStage.parenting => _forYouParenting(p),
    _ => _allView(p),
  };

  List<PvMoveItem> _classesIn(String chip) => pvMoveFiltered(
    chip: chip,
  ).where((i) => i.kind == PvMoveKind.yogaClass).toList();

  List<PvMoveItem> get _calm => [
    ..._classesIn('breathing'),
    ..._classesIn('meditation'),
  ];

  List<Widget> _forYouTtc(V2Palette p) {
    final phase = ttcHomePhaseOn(DateTime.now());
    final today = pvMoveFromPractice(ttcTodaysMove(phase: phase));
    final line = switch (phase) {
      TtcDayPhase.period => 'Gentle, for your period days.',
      TtcDayPhase.beforeWindow || TtcDayPhase.window =>
        'A little more active, for this part of your cycle.',
      TtcDayPhase.waiting ||
      TtcDayPhase.late => 'Gentle, for the days of waiting.',
      TtcDayPhase.any => 'A short practice for today.',
    };
    final fertility = pvMoveFiltered(
      chip: 'fertility',
    ).where((i) => i.id != today.id).toList();
    return [
      const SizedBox(height: 26),
      pregToolPad(PvSectionHead(title: "Today's practice")),
      const SizedBox(height: 10),
      pregToolPad(
        _TodayCard(
          p: p,
          item: today,
          line: line,
          onTap: () => _openItem(today),
        ),
      ),
      ..._rail(p, 'Fertility yoga', fertility, chip: 'fertility'),
      ..._rail(p, 'Gentle yoga', _classesIn('yoga'), chip: 'yoga'),
      ..._rail(p, 'Breathe and calm', _calm, chip: 'breathing'),
    ];
  }

  List<Widget> _forYouPregnancy(V2Palette p) {
    final c = _preg;
    final known = c?.isDueDateSet ?? false;
    final month = known ? garbhMonth(c!.currentWeek) : 1;
    final sessions = [
      for (final s in yogaSessionsForMonth(month)) pvMoveFromSession(s),
    ];
    return [
      ..._rail(
        p,
        'For your month',
        sessions,
        chip: 'prenatal',
        lead: known
            ? 'Month $month of your pregnancy.'
            : 'Add your due date to see your month. Showing month 1.',
      ),
      ..._rail(p, 'Prenatal classes', _classesIn('prenatal'), chip: 'prenatal'),
      ..._rail(p, 'Breathe and calm', _calm, chip: 'breathing'),
      ..._tools(p, [
        _ToolRow(
          key: const ValueKey('move_tool_kegel'),
          p: p,
          mark: IntentMark.spineMark,
          hue: 330,
          title: 'Kegel Care',
          line: 'A guided pelvic floor routine for your stage',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => KegelCareScreen(controller: c),
            ),
          ),
        ),
        if (c != null)
          _ToolRow(
            key: const ValueKey('move_tool_when_to_stop'),
            p: p,
            mark: IntentMark.cuppedHands,
            hue: 10,
            title: 'When to stop and call your doctor',
            line: 'The signs that mean stop, whatever you are doing',
            onTap: () =>
                openPvDoorRead(context, 'preg_move_read_when_to_stop', c),
          ),
      ]),
    ];
  }

  /// One calm line from what we already know about the birth: never a
  /// question, never a hidden class. Gone after twelve weeks.
  String? get _afterBirthNote {
    final kids = ChildProfileStore.instance;
    if (!kids.hasRealChild) return null;
    final days = ppDaysSinceBirth;
    if (days >= 84) return null;
    final w = days ~/ 7;
    final when = w == 0
        ? 'Your first week after birth'
        : '$w ${w == 1 ? 'week' : 'weeks'} after birth';
    if (FamilyProfileStore.instance.birthMode == BirthMode.cSection) {
      final whenCs = w == 0
          ? 'Your first week after a caesarean'
          : '$w ${w == 1 ? 'week' : 'weeks'} after a caesarean';
      return '$whenCs: core classes wait until your doctor clears you. '
          'Breathing and gentle classes are fine to start.';
    }
    return days < 42
        ? '$when: start gently. Core classes wait for your six-week check.'
        : '$when: once your six-week check is done, core classes are open to you.';
  }

  List<Widget> _forYouParenting(V2Palette p) {
    final note = _afterBirthNote;
    return [
      if (note != null) ...[
        const SizedBox(height: 20),
        pregToolPad(
          _NoteCard(
            key: const ValueKey('move_after_birth_note'),
            p: p,
            text: note,
          ),
        ),
      ],
      ..._rail(p, 'Recovery', _classesIn('postnatal'), chip: 'postnatal'),
      ..._rail(p, 'Core and pelvic floor', _classesIn('core'), chip: 'core'),
      ..._rail(p, 'Breathe and calm', _calm, chip: 'breathing'),
      ..._tools(p, [
        _ToolRow(
          key: const ValueKey('move_tool_kegel'),
          p: p,
          mark: IntentMark.spineMark,
          hue: 330,
          title: 'Kegel Care',
          line: 'Breathing first, then kegels after your check',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const KegelCareScreen()),
          ),
        ),
      ]),
    ];
  }

  List<Widget> _tools(V2Palette p, List<Widget> rows) => [
    const SizedBox(height: 26),
    pregToolPad(PvSectionHead(title: 'Tools')),
    const SizedBox(height: 6),
    pregToolPad(PvRowGroup(p: p, children: rows)),
  ];

  /// A titled rail with "See all" (Fitbit), which opens All on its chip.
  List<Widget> _rail(
    V2Palette p,
    String title,
    List<PvMoveItem> items, {
    required String chip,
    String? lead,
    bool showStage = false,
  }) {
    if (items.isEmpty) return const [];
    final scale = MediaQuery.textScalerOf(context);
    return [
      const SizedBox(height: 26),
      pregToolPad(
        PvSectionHead(
          title: title,
          action: 'See all',
          onAction: () => setState(() {
            _forYou = false;
            _chip = chip;
          }),
        ),
      ),
      if (lead != null) ...[
        const SizedBox(height: 2),
        pregToolPad(
          Text(
            lead,
            style: pvManrope(fontSize: 13, height: 1.45, color: p.ink2),
          ),
        ),
      ],
      const SizedBox(height: 12),
      SizedBox(
        height: _MoveCard.railHeight(scale),
        child: ListView.separated(
          key: ValueKey(
            'move_rail_${title.toLowerCase().replaceAll(' ', '_')}',
          ),
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (_, i) => _moveCard(p, items[i], showStage: showStage),
        ),
      ),
    ];
  }

  Widget _moveCard(V2Palette p, PvMoveItem i, {bool showStage = false}) {
    final store = YogaStore.instance;
    final c = i.yogaClass;
    return _MoveCard(
      key: ValueKey('move_card_${i.id}'),
      p: p,
      item: i,
      hue: _catHue(i.chip == 'fertility' ? 'postivf' : i.chip),
      mark: _catMark(i.chip == 'fertility' ? 'postivf' : i.chip),
      showStage: showStage,
      saved: c != null && store.isSaved(c.id),
      onSave: c == null ? null : () => store.toggleSave(c.id),
      onTap: () => _openItem(i),
    );
  }

  // ---- All -------------------------------------------------------------------

  List<Widget> _allView(V2Palette p) {
    final items = pvMoveFiltered(chip: _chip, modes: _modes);
    final noun = items.length == 1 ? 'item' : 'items';
    return [
      const SizedBox(height: 14),
      // The chip row (Peloton), All first.
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(
          children: [
            for (final (id, label) in kPvMoveChips) ...[
              KeyedSubtree(
                key: ValueKey('move_chip_$id'),
                child: PvChip(
                  label: label,
                  selected: _chip == id,
                  onTap: () => setState(() => _chip = id),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ],
        ),
      ),
      const SizedBox(height: 14),
      // The count, and the filters that are on (Equinox+).
      pregToolPad(
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              '${items.length} $noun',
              key: const ValueKey('move_count'),
              style: pvManrope(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: p.ink2,
              ),
            ),
            for (final m in _modes)
              PvChip(
                label: _modeLabel(m),
                selected: true,
                leading: Icons.close_rounded,
                onTap: () => setState(() => _modes.remove(m)),
              ),
            if (_modes.isNotEmpty)
              GestureDetector(
                key: const ValueKey('move_clear_all'),
                onTap: () => setState(_modes.clear),
                child: Text(
                  'Clear all',
                  style: pvManrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: p.ink1,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
          ],
        ),
      ),
      if (items.isEmpty) ...[
        const SizedBox(height: 18),
        pregToolPad(
          Text(
            'Nothing matches these filters yet.',
            style: pvManrope(fontSize: 14, height: 1.5, color: p.ink2),
          ),
        ),
        const SizedBox(height: 12),
        pregToolPad(
          PvSecondary(
            label: 'Show everything',
            onTap: () => setState(() {
              _modes.clear();
              _chip = 'all';
            }),
          ),
        ),
      ] else if (_chip == 'all')
        // Everything, grouped by kind in titled rails, each card labelled.
        for (final (id, label) in kPvMoveChips.skip(1))
          ..._rail(
            p,
            label,
            items.where((i) => i.chip == id).toList(),
            chip: id,
            showStage: true,
          )
      else ...[
        const SizedBox(height: 8),
        pregToolPad(
          PvRowGroup(
            p: p,
            children: [
              for (final i in items)
                _MoveRow(
                  key: ValueKey('move_row_${i.id}'),
                  p: p,
                  item: i,
                  hue: _catHue(i.chip == 'fertility' ? 'postivf' : i.chip),
                  mark: _catMark(i.chip == 'fertility' ? 'postivf' : i.chip),
                  onTap: () => _openItem(i),
                ),
            ],
          ),
        ),
      ],
    ];
  }

  List<Widget> _hubSearch(V2Palette p) {
    final items = pvMoveFiltered(query: _query);
    return [
      const SizedBox(height: 22),
      pregToolPad(ppCareHeading('Search results')),
      const SizedBox(height: 8),
      if (items.isEmpty)
        pregToolPad(
          Text(
            'Nothing matches "${_query.trim()}". Try a stage, a kind of class or a teacher.',
            style: pvManrope(fontSize: 14, height: 1.5, color: p.ink2),
          ),
        )
      else
        pregToolPad(
          PvRowGroup(
            p: p,
            children: [
              for (final i in items)
                _MoveRow(
                  key: ValueKey('move_row_${i.id}'),
                  p: p,
                  item: i,
                  hue: _catHue(i.chip == 'fertility' ? 'postivf' : i.chip),
                  mark: _catMark(i.chip == 'fertility' ? 'postivf' : i.chip),
                  onTap: () => _openItem(i),
                ),
            ],
          ),
        ),
    ];
  }

  Widget _filterPill(V2Palette p) => Material(
    key: const ValueKey('move_filter_pill'),
    color: p.ink1,
    shape: const StadiumBorder(),
    elevation: 6,
    shadowColor: const Color(0x33000000),
    child: InkWell(
      customBorder: const StadiumBorder(),
      onTap: () => _openFilterSheet(p),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.tune_rounded, size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              _modes.isEmpty ? 'Filter' : 'Filter · ${_modes.length}',
              style: pvManrope(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Future<void> _openFilterSheet(V2Palette p) async {
    pvCommitFeedback();
    final picked = {..._modes};
    final applied = await showModalBottomSheet<Set<YogaMode>>(
      context: context,
      backgroundColor: p.ground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) {
          final n = pvMoveFiltered(chip: _chip, modes: picked).length;
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'How you want to practise',
                    style: pvManrope(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: p.ink1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pick any. None picked shows everything.',
                    style: pvManrope(fontSize: 13, color: p.ink2),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final m in YogaMode.values)
                        KeyedSubtree(
                          key: ValueKey('move_filter_${m.name}'),
                          child: PvChip(
                            label: _modeLabel(m),
                            selected: picked.contains(m),
                            onTap: () => setSheet(
                              () => picked.contains(m)
                                  ? picked.remove(m)
                                  : picked.add(m),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  PvCommit(
                    label: n == 1 ? 'Show 1 result' : 'Show $n results',
                    onTap: () => Navigator.of(ctx).pop(picked),
                  ),
                  const SizedBox(height: 8),
                  PvSecondary(
                    label: 'Clear all',
                    onTap: () => Navigator.of(ctx).pop(<YogaMode>{}),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
    if (applied == null || !mounted) return;
    setState(
      () => _modes
        ..clear()
        ..addAll(applied),
    );
  }

  /// Each category's drawn mark, by meaning.
  static IntentMark _catMark(String id) => switch (id) {
    'prenatal' => IntentMark.kickMark,
    'postnatal' => IntentMark.cuppedHands,
    'postivf' => IntentMark.improveMark,
    'breathing' => IntentMark.windMark,
    'meditation' => IntentMark.moonMark,
    'core' => IntentMark.spineMark,
    _ => IntentMark.lotusMark,
  };

  static double _catHue(String id) => switch (id) {
    'prenatal' => 330,
    'postnatal' => 20,
    'postivf' => 150,
    'breathing' => 200,
    'meditation' => 250,
    'core' => 40,
    _ => 280,
  };

  // Kept for revert (2026-10-16): the marketplace page before the hub.
  // ignore: unused_element
  Widget _buildRailsPage(BuildContext context) {
    return AnimatedBuilder(
      animation: YogaStore.instance,
      builder: (context, _) {
        final p = V2PaletteStore.instance.current;
        final searching = _query.trim().isNotEmpty;
        return PregToolScaffold(
          hue: 280,
          eyebrow: widget.eyebrow,
          mark: IntentMark.lotusMark,
          title: widget.heroTitle,
          intro: widget.intro ?? '',
          children: [
            pregToolPad(
              TextField(
                key: const ValueKey('yoga_search_rails'),
                controller: _searchCtl,
                onChanged: (v) => setState(() => _query = v),
                style: pvManrope(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: p.ink1,
                ),
                decoration: InputDecoration(
                  hintText: 'Search classes, teachers…',
                  hintStyle: pvManrope(fontSize: 15, color: p.ink3),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    size: 20,
                    color: p.ink3,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(999),
                    borderSide: BorderSide(color: p.line),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(999),
                    borderSide: BorderSide(color: p.line),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(999),
                    borderSide: BorderSide(color: p.ink1),
                  ),
                ),
              ),
            ),
            if (searching)
              ..._searchViewShell(p)
            else ...[
              const SizedBox(height: 14),
              // Live / Recorded, then (under Live) Group / 1:1. Same three modes.
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  children: [
                    KeyedSubtree(
                      key: const ValueKey('yoga_mode_live'),
                      child: PvChip(
                        label: 'Live',
                        selected: _live,
                        onTap: () => setState(() => _live = true),
                      ),
                    ),
                    const SizedBox(width: 8),
                    KeyedSubtree(
                      key: const ValueKey('yoga_mode_recorded'),
                      child: PvChip(
                        label: 'Recorded',
                        selected: !_live,
                        onTap: () => setState(() => _live = false),
                      ),
                    ),
                    if (_live) ...[
                      Container(
                        width: 1,
                        height: 22,
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        color: p.line,
                      ),
                      KeyedSubtree(
                        key: const ValueKey('yoga_mode_group'),
                        child: PvChip(
                          label: 'Group',
                          selected: _group,
                          onTap: () => setState(() => _group = true),
                        ),
                      ),
                      const SizedBox(width: 8),
                      KeyedSubtree(
                        key: const ValueKey('yoga_mode_1to1'),
                        child: PvChip(
                          label: '1:1',
                          selected: !_group,
                          onTap: () => setState(() => _group = false),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              ..._categoryRails(p),
              const SizedBox(height: 24),
            ],
          ],
        );
      },
    );
  }

  List<Widget> _searchViewShell(V2Palette p) {
    final items = yogaSearch(
      _query,
    ).where((c) => _allowed(c.category)).toList();
    return [
      const SizedBox(height: 22),
      pregToolPad(ppCareHeading('Search results')),
      const SizedBox(height: 8),
      if (items.isEmpty)
        pregToolPad(
          Text(
            'No classes match "${_query.trim()}". Try a stage or a teacher.',
            style: pvManrope(fontSize: 14, height: 1.5, color: p.ink2),
          ),
        )
      else
        pregToolPad(
          PvRowGroup(
            p: p,
            children: [
              for (final c in items)
                _ClassRow(
                  key: ValueKey('yoga_row_${c.id}'),
                  p: p,
                  cls: c,
                  hue: _catHue(c.category),
                  mark: _catMark(c.category),
                  onTap: () => _open(c),
                ),
            ],
          ),
        ),
    ];
  }

  List<Widget> _categoryRails(V2Palette p) {
    final cats = yogaCategoriesWithClasses(
      _mode,
    ).where((c) => _allowed(c.id)).toList();
    final store = YogaStore.instance;
    if (cats.isEmpty) {
      return [
        const SizedBox(height: 24),
        pregToolPad(
          Text(
            _live
                ? 'No ${_group ? 'group' : '1:1'} classes here yet. Try ${_group ? '1:1' : 'Group'}, or Recorded.'
                : 'No recorded classes here yet. Try Live.',
            style: pvManrope(fontSize: 14, height: 1.5, color: p.ink2),
          ),
        ),
      ];
    }
    final scale = MediaQuery.textScalerOf(context);
    return [
      for (final cat in cats) ...[
        const SizedBox(height: 26),
        pregToolPad(ppCareHeading(cat.title)),
        const SizedBox(height: 4),
        pregToolPad(
          Text(
            cat.subtitle,
            style: pvManrope(fontSize: 13, height: 1.45, color: p.ink2),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: _ClassCard.railHeight(scale),
          child: ListView.separated(
            key: ValueKey('yoga_rail_${cat.id}'),
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            itemCount: yogaClassesIn(cat.id, _mode).length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              final c = yogaClassesIn(cat.id, _mode)[i];
              return _ClassCard(
                key: ValueKey('yoga_card_${c.id}'),
                p: p,
                cls: c,
                hue: _catHue(cat.id),
                mark: _catMark(cat.id),
                saved: store.isSaved(c.id),
                onSave: () => store.toggleSave(c.id),
                onTap: () => _open(c),
              );
            },
          ),
        ),
      ],
    ];
  }

  // Kept for revert (2026-10-07): the page before the shared look.
  // ignore: unused_element
  Widget _buildBeforeShell(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: AnimatedBuilder(
              animation: YogaStore.instance,
              builder: (context, _) {
                return ListView(
                  padding: const EdgeInsets.only(top: 12, bottom: 40),
                  children: [
                    _pad(ppBack(context, widget.backLabel)),
                    const SizedBox(height: 18),
                    _pad(ppEyebrow(widget.eyebrow, color: ppPurple)),
                    const SizedBox(height: 8),
                    _pad(Text(widget.heroTitle, style: ppFraunces(30, h: 1.1))),
                    const SizedBox(height: 6),
                    _pad(Text(widget.intro ?? '', style: ppBody(14, h: 1.5))),

                    const SizedBox(height: 16),
                    _pad(
                      ppSearchField(
                        controller: _searchCtl,
                        hint: 'Search classes, teachers…',
                        onChanged: (v) => setState(() => _query = v),
                      ),
                    ),

                    if (_query.trim().isNotEmpty)
                      ..._searchView()
                    else ...[
                      const SizedBox(height: 18),
                      _pad(_liveRecordedToggle()),
                      if (_live) ...[
                        const SizedBox(height: 12),
                        _pad(_groupOneToOneToggle()),
                      ],
                      const SizedBox(height: 8),
                      ..._categorySections(),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ---- search results (mode-agnostic) -------------------------------------
  List<Widget> _searchView() {
    final items = yogaSearch(
      _query,
    ).where((c) => _allowed(c.category)).toList();
    return [
      const SizedBox(height: 26),
      _pad(Text('Search results', style: ppJakarta(18))),
      const SizedBox(height: 14),
      if (items.isEmpty)
        _pad(
          Text(
            'No classes match "${_query.trim()}" - try a stage or a teacher.',
            style: ppBody(13, color: ppMuted),
          ),
        )
      else
        _pad(
          Column(
            children: [
              for (final c in items)
                YogaListCard(cls: c, onTap: () => _open(c)),
            ],
          ),
        ),
    ];
  }

  // ---- cult.fit-style category sections -----------------------------------
  // Honour the stage filter: on the pregnancy side only pregnancy-relevant
  // categories are shown; parenting (no filter) shows all, unchanged.
  bool _allowed(String catId) =>
      widget.categoryFilter == null || widget.categoryFilter!.contains(catId);

  List<Widget> _categorySections() {
    final cats = yogaCategoriesWithClasses(
      _mode,
    ).where((c) => _allowed(c.id)).toList();
    final store = YogaStore.instance;
    if (cats.isEmpty) {
      return [
        const SizedBox(height: 40),
        _pad(
          Text(
            'No classes here yet - check another mode.',
            style: ppBody(13, color: ppMuted),
          ),
        ),
      ];
    }
    final out = <Widget>[];
    for (final cat in cats) {
      final classes = yogaClassesIn(cat.id, _mode);
      out.addAll([
        const SizedBox(height: 26),
        _pad(yogaSectionHeader(cat)),
        const SizedBox(height: 14),
        SizedBox(
          height: 268,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: classes.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (_, i) {
              final c = classes[i];
              return YogaBigCard(
                cls: c,
                onTap: () => _open(c),
                saved: store.isSaved(c.id),
                onSave: () => store.toggleSave(c.id),
              );
            },
          ),
        ),
      ]);
    }
    return out;
  }

  // ---- toggles ------------------------------------------------------------
  // The two mode toggles. REBUILT 21 Jul: was two stacked rows of TWO-LINE
  // segments (label + caption) whose highlight cross-faded in place — tall, and
  // the selection did not visibly move. Now each is a single-line sliding
  // segmented control: half the height (the captions moved into the intro copy
  // above), and one white pill that GLIDES left/right on tap. Same two choices,
  // far less vertical space, and a transition you can follow.
  Widget _liveRecordedToggle() => _slideToggle(
    left: 'Live',
    right: 'Recorded',
    leftOn: _live,
    onLeft: () => setState(() => _live = true),
    onRight: () => setState(() => _live = false),
  );

  Widget _groupOneToOneToggle() => _slideToggle(
    left: 'Group',
    right: '1:1',
    leftOn: _group,
    onLeft: () => setState(() => _group = true),
    onRight: () => setState(() => _group = false),
  );

  /// A two-option pill toggle whose white highlight slides between the halves.
  Widget _slideToggle({
    required String left,
    required String right,
    required bool leftOn,
    required VoidCallback onLeft,
    required VoidCallback onRight,
  }) => Container(
    height: 42,
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: ppPanel,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Stack(
      children: [
        // The gliding highlight — half-width, animated to the chosen side.
        AnimatedAlign(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          alignment: leftOn ? Alignment.centerLeft : Alignment.centerRight,
          child: FractionallySizedBox(
            widthFactor: 0.5,
            heightFactor: 1,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x146A30B6),
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
            ),
          ),
        ),
        Row(
          children: [
            _segLabel(left, leftOn, onLeft),
            _segLabel(right, !leftOn, onRight),
          ],
        ),
      ],
    ),
  );

  Widget _segLabel(String label, bool on, VoidCallback onTap) => Expanded(
    child: PvPress(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 240),
            style: ppBody(
              13,
              color: on ? ppPurple : ppSoft,
              w: FontWeight.w700,
            ),
            child: Text(label),
          ),
        ),
      ),
    ),
  );
}

// =============================================================================
//  The class card and row on the shared look (2026-10-07)
// =============================================================================

/// The meta line under a class: "45 min · Teacher", the teacher's NAME
/// tappable (it opens her profile, as on the old cards).
Widget _classMeta(V2Palette p, YogaClass cls) => yogaInstructorLine(
  cls,
  prefix: '${cls.durationLabel} · ',
  style: pvManrope(
    fontSize: 12,
    height: 1.3,
    fontWeight: FontWeight.w600,
    color: p.ink2,
  ),
);

/// A drawn picture: the category's mark on its own soft tint, as the doors'
/// shelf cards draw one (no photo exists for a class yet).
Widget _classPicture(double hue, IntentMark mark) => ColoredBox(
  color: HSLColor.fromAHSL(1, hue % 360, 0.52, 0.9).toColor(),
  child: Center(
    child: FractionallySizedBox(
      widthFactor: 0.5,
      heightFactor: 0.5,
      child: HubIntentArt(
        mark: mark,
        tint: HSLColor.fromAHSL(1, hue % 360, 0.6, 0.8).toColor(),
      ),
    ),
  ),
);

class _ClassCard extends StatelessWidget {
  const _ClassCard({
    super.key,
    required this.p,
    required this.cls,
    required this.hue,
    required this.mark,
    required this.saved,
    required this.onSave,
    required this.onTap,
  });

  final V2Palette p;
  final YogaClass cls;
  final double hue;
  final IntentMark mark;
  final bool saved;
  final VoidCallback onSave;
  final VoidCallback onTap;

  static const double width = 168;
  static const double pictureHeight = 128;

  /// Tall enough for the picture, two title lines and the meta line at any
  /// text scale, so a rail never clips its last line.
  static double railHeight(TextScaler s) =>
      (pictureHeight + 8 + s.scale(14) * 1.25 * 2 + 4 + s.scale(12) * 1.3 + 6)
          .ceilToDouble();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: width,
              height: pictureHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  PvPress(
                    child: InkWell(
                      onTap: onTap,
                      child: _classPicture(hue, mark),
                    ),
                  ),
                  if (cls.mode == YogaMode.recorded)
                    const IgnorePointer(
                      child: Center(
                        child: Icon(
                          Icons.play_circle_outline_rounded,
                          size: 34,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  // What kind of class, top left: one white pill, ink words.
                  Positioned(
                    left: 7,
                    top: 7,
                    child: IgnorePointer(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          cls.modeLabel,
                          textScaler: TextScaler.noScaling,
                          style: pvManrope(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: p.ink1,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 4,
                    top: 4,
                    child: Semantics(
                      button: true,
                      label: saved ? 'Remove from saved' : 'Save class',
                      child: InkWell(
                        key: ValueKey('yoga_save_${cls.id}'),
                        onTap: onSave,
                        borderRadius: BorderRadius.circular(999),
                        child: Padding(
                          padding: const EdgeInsets.all(3),
                          child: Container(
                            width: 28,
                            height: 28,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              saved
                                  ? Icons.bookmark_rounded
                                  : Icons.bookmark_border_rounded,
                              size: 16,
                              color: p.ink1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          PvPress(
            child: GestureDetector(
              onTap: onTap,
              behavior: HitTestBehavior.opaque,
              child: Text(
                cls.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: pvManrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                  color: p.ink1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          _classMeta(p, cls),
        ],
      ),
    );
  }
}

/// A class as a list row (search results): the mark, the title, the mode, and
/// "45 min · Teacher" with the teacher's name tappable.
class _ClassRow extends StatelessWidget {
  const _ClassRow({
    super.key,
    required this.p,
    required this.cls,
    required this.hue,
    required this.mark,
    required this.onTap,
  });

  final V2Palette p;
  final YogaClass cls;
  final double hue;
  final IntentMark mark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => PvPress(
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            PvMarkWell(p: p, hue: hue, size: 40, mark: mark),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cls.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: pvManrope(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                      color: p.ink1,
                    ),
                  ),
                  const SizedBox(height: 3),
                  _classMeta(p, cls),
                  const SizedBox(height: 3),
                  Text(
                    '${cls.modeLabel} · ${cls.categoryInfo.title}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: pvManrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: p.ink3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, size: 20, color: p.ink3),
          ],
        ),
      ),
    ),
  );
}

// =============================================================================
//  The hub's cards and rows (2026-10-16): the class card's look, for any item
// =============================================================================

/// What kind of thing it is, in the top-left pill.
String _kindPill(PvMoveItem i) => switch (i.kind) {
  PvMoveKind.yogaClass => i.yogaClass!.modeLabel,
  PvMoveKind.session => 'Video',
  PvMoveKind.practice => 'Practice',
  PvMoveKind.offering => 'Live',
};

/// The small labels under a card: the stage (in All, where stages mix) and
/// "After your six-week check" (always, never hidden).
List<String> _labelsFor(PvMoveItem i, {required bool showStage}) => [
  if (showStage && i.stageLabel != null) i.stageLabel!,
  if (i.afterCheck) 'After your six-week check',
];

Widget _labelLine(V2Palette p, List<String> labels) => Text(
  labels.join(' · '),
  maxLines: 1,
  overflow: TextOverflow.ellipsis,
  style: pvManrope(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    height: 1.3,
    color: p.ink3,
  ),
);

Widget _metaFor(V2Palette p, PvMoveItem i) => i.yogaClass != null
    ? _classMeta(p, i.yogaClass!)
    : Text(
        i.meta,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: pvManrope(
          fontSize: 12,
          height: 1.3,
          fontWeight: FontWeight.w600,
          color: p.ink2,
        ),
      );

class _MoveCard extends StatelessWidget {
  const _MoveCard({
    super.key,
    required this.p,
    required this.item,
    required this.hue,
    required this.mark,
    required this.showStage,
    required this.saved,
    required this.onSave,
    required this.onTap,
  });

  final V2Palette p;
  final PvMoveItem item;
  final double hue;
  final IntentMark mark;
  final bool showStage;
  final bool saved;
  final VoidCallback? onSave;
  final VoidCallback onTap;

  static const double width = 168;
  static const double pictureHeight = 128;

  /// The class card's height plus one label line, so a rail never clips.
  static double railHeight(TextScaler s) =>
      (_ClassCard.railHeight(s) + 4 + s.scale(11) * 1.3 + 2).ceilToDouble();

  @override
  Widget build(BuildContext context) {
    final labels = _labelsFor(item, showStage: showStage);
    final playable = item.mode == YogaMode.recorded;
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: width,
              height: pictureHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  PvPress(
                    child: InkWell(
                      onTap: onTap,
                      child: _classPicture(hue, mark),
                    ),
                  ),
                  if (playable)
                    const IgnorePointer(
                      child: Center(
                        child: Icon(
                          Icons.play_circle_outline_rounded,
                          size: 34,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  Positioned(
                    left: 7,
                    top: 7,
                    child: IgnorePointer(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          _kindPill(item),
                          textScaler: TextScaler.noScaling,
                          style: pvManrope(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: p.ink1,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (onSave != null)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Semantics(
                        button: true,
                        label: saved ? 'Remove from saved' : 'Save class',
                        child: InkWell(
                          key: ValueKey('move_save_${item.id}'),
                          onTap: onSave,
                          borderRadius: BorderRadius.circular(999),
                          child: Padding(
                            padding: const EdgeInsets.all(3),
                            child: Container(
                              width: 28,
                              height: 28,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                saved
                                    ? Icons.bookmark_rounded
                                    : Icons.bookmark_border_rounded,
                                size: 16,
                                color: p.ink1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          PvPress(
            child: GestureDetector(
              onTap: onTap,
              behavior: HitTestBehavior.opaque,
              child: Text(
                item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: pvManrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                  color: p.ink1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          _metaFor(p, item),
          if (labels.isNotEmpty) ...[
            const SizedBox(height: 4),
            _labelLine(p, labels),
          ],
        ],
      ),
    );
  }
}

/// Any item as a list row (a chip's list, search): mark, title, meta, and the
/// kind, the stage and the six-week label in one quiet line.
class _MoveRow extends StatelessWidget {
  const _MoveRow({
    super.key,
    required this.p,
    required this.item,
    required this.hue,
    required this.mark,
    required this.onTap,
  });

  final V2Palette p;
  final PvMoveItem item;
  final double hue;
  final IntentMark mark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => PvPress(
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            PvMarkWell(p: p, hue: hue, size: 40, mark: mark),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: pvManrope(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                      color: p.ink1,
                    ),
                  ),
                  const SizedBox(height: 3),
                  _metaFor(p, item),
                  const SizedBox(height: 3),
                  _labelLine(p, [
                    _kindPill(item),
                    ..._labelsFor(item, showStage: true),
                  ]),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, size: 20, color: p.ink3),
          ],
        ),
      ),
    ),
  );
}

/// TTC's "Today's practice": one wide card, the phase's reason under the title.
class _TodayCard extends StatelessWidget {
  const _TodayCard({
    required this.p,
    required this.item,
    required this.line,
    required this.onTap,
  });

  final V2Palette p;
  final PvMoveItem item;
  final String line;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => PvPress(
    child: Material(
      key: const ValueKey('move_today_card'),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: p.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              PvMarkWell(p: p, hue: 150, size: 52, mark: IntentMark.lotusMark),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: pvManrope(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                        color: p.ink1,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      line,
                      style: pvManrope(
                        fontSize: 13,
                        height: 1.4,
                        color: p.ink2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.meta,
                      style: pvManrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: p.ink3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, size: 22, color: p.ink3),
            ],
          ),
        ),
      ),
    ),
  );
}

/// The calm after-birth line: a tinted panel, no alarm colour.
class _NoteCard extends StatelessWidget {
  const _NoteCard({super.key, required this.p, required this.text});

  final V2Palette p;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: HSLColor.fromAHSL(1, 20, 0.5, 0.95).toColor(),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline_rounded, size: 18, color: p.ink2),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: pvManrope(fontSize: 13.5, height: 1.45, color: p.ink1),
          ),
        ),
      ],
    ),
  );
}

/// A tool or read in the Tools group: mark, title, one line, chevron.
class _ToolRow extends StatelessWidget {
  const _ToolRow({
    super.key,
    required this.p,
    required this.mark,
    required this.hue,
    required this.title,
    required this.line,
    required this.onTap,
  });

  final V2Palette p;
  final IntentMark mark;
  final double hue;
  final String title;
  final String line;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => PvPress(
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            PvMarkWell(p: p, hue: hue, size: 40, mark: mark),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: pvManrope(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: p.ink1,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    line,
                    style: pvManrope(
                      fontSize: 12.5,
                      height: 1.35,
                      color: p.ink2,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 20, color: p.ink3),
          ],
        ),
      ),
    ),
  );
}
