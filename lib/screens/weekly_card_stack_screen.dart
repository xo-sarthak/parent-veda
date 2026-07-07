// =============================================================================
//  WeeklyCardStackScreen
// -----------------------------------------------------------------------------
//  The heart of ParentVeda: a horizontal, swipeable stack of 7 cards for the
//  active week, a week-navigation strip (with locked future weeks), and an
//  English / Hinglish toggle in the AppBar.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_constants.dart';
import '../localization/app_language.dart';
import '../services/app_nav.dart';
import '../services/baby_voice_service.dart';
import '../services/father_preview.dart';
import '../services/pregnancy_controller.dart';
import '../theme/app_theme.dart';
import '../theme/father_skin.dart';
import '../widgets/cards/card_shell.dart';
import '../widgets/locked_week_view.dart';
import '../widgets/week_cards/celebration_card.dart';
import '../widgets/week_cards/week_cards.dart';
import 'week_flow_screen.dart';

class WeeklyCardStackScreen extends StatefulWidget {
  const WeeklyCardStackScreen({super.key, required this.controller});

  final PregnancyController controller;

  @override
  State<WeeklyCardStackScreen> createState() => _WeeklyCardStackScreenState();
}

class _WeeklyCardStackScreenState extends State<WeeklyCardStackScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.92);
  int _cardIndex = 0;

  /// Week-20 V2 flow preview toggle (Classic ⟷ New). Defaults to New.
  bool _v2 = true;

  /// Collapsing-header geometry: the compact info row (trimester + week + date +
  /// progress) is always pinned; the compact week bar below it collapses away.
  static const double _compactHeaderHeight = 74;
  // A little extra room so the selected week's round shadow renders fully and
  // isn't clipped (straightened) at the header's bottom edge.
  static const double _stripHeaderHeight = 62;

  /// Tracks which week the PageView is currently built for, so we can reset to
  /// the first card whenever the user switches weeks.
  int? _builtForWeek;

  PregnancyController get _c => widget.controller;

  @override
  void initState() {
    super.initState();
    _c.addListener(_onControllerChanged);
    // Re-skin live when the testing Mom|Dad switch flips.
    FatherPreview.instance.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _c.removeListener(_onControllerChanged);
    FatherPreview.instance.removeListener(_onControllerChanged);
    // Stop any baby voice when this screen goes away (tab switch, pop, etc.) so
    // narration never keeps playing after you leave.
    BabyVoiceService.instance.stop();
    _pageController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    // When the selected week changes, snap back to the first card and stop any
    // audio that was playing for the previous week.
    if (_builtForWeek != null && _builtForWeek != _c.selectedWeek) {
      _builtForWeek = _c.selectedWeek;
      _cardIndex = 0;
      BabyVoiceService.instance.stop();
      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
      }
    }
    if (mounted) setState(() {});
  }

  /// Classic ⟷ New (V2) toggle - parked (V2 is now the only view). Kept for revert.
  // ignore: unused_element
  Widget _v2Toggle() {
    final s = S(_c.language);
    final father = FatherPreview.instance.on; // Slate chrome on ALL weeks now
    Widget seg(String label, bool on, VoidCallback onTap) => GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: on
                  ? (father ? kFAccent : AppTheme.primary500)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(label,
                style: GoogleFonts.manrope(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: on
                        ? Colors.white
                        : (father ? kFMuted : AppTheme.neutral500))),
          ),
        );
    return Center(
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: father ? kFAccentSoft : AppTheme.surfaceContainer,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          seg(s.wfClassic, !_v2, () => setState(() => _v2 = false)),
          seg(s.wfNew, _v2, () => setState(() => _v2 = true)),
        ]),
      ),
    );
  }

  /// A smooth, minimal "‹ Daily" pill that returns to the Today (Daily) tab -
  /// the mirror of the Home → weekly hop, so the loop feels two-way.
  Widget _backToDaily() {
    final s = S(_c.language);
    final father = FatherPreview.instance.on; // Slate chrome on ALL weeks now
    final tint = father ? kFAccent : AppTheme.primary600;
    return Center(
      child: GestureDetector(
        onTap: AppNav.instance.goToday,
        behavior: HitTestBehavior.opaque,
        child: Container(
          margin: const EdgeInsets.only(left: 4, right: 2),
          padding: const EdgeInsets.fromLTRB(7, 6, 11, 6),
          decoration: BoxDecoration(
            color: father ? kFAccentSoft : AppTheme.surfaceContainer,
            borderRadius: BorderRadius.circular(99),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.chevron_left_rounded, size: 16, color: tint),
            const SizedBox(width: 1),
            Text(s.weeklyBackToDaily,
                style: GoogleFonts.manrope(
                    fontSize: 11.5, fontWeight: FontWeight.w700, color: tint)),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Father weekly re-skin (Slate) - colours/fonts only, week-20 + Dad switch.
    final father = FatherPreview.instance.on; // Slate chrome on ALL weeks now
    return Scaffold(
      backgroundColor: father ? kFBg : null,
      appBar: AppBar(
        backgroundColor: father ? kFBg : null,
        titleSpacing: 16,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/brand/pv-mark.png', height: 26),
            const SizedBox(width: 8),
            // Flexible so a tight app bar (mute + EN/Hi toggle on the right)
            // never overflows - it shrinks/ellipsises instead of clipping.
            Flexible(
              child: Text(
                'ParentVeda',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                // Father uses the SAME font as the mother (the serif read poorly
                // here), just in the Slate ink colour.
                style: father
                    ? GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: kFAccent,
                        letterSpacing: -0.5,
                      )
                    : GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primary600,
                        letterSpacing: -0.5,
                      ),
              ),
            ),
          ],
        ),
        actions: [
          // Mirror of Home → weekly: hop back to the Daily tab.
          _backToDaily(),
          // Classic/New toggle removed - the New (V2) flow is the only weekly
          // view now (all weeks). Kept (commented) for revert.
          // if (_c.selectedWeek == 20) _v2Toggle(),
          // Mute / unmute baby voice - design's soft round speaker button.
          AnimatedBuilder(
            animation: BabyVoiceService.instance,
            builder: (context, _) {
              final muted =
                  BabyVoiceService.instance.isMutedFor(VoiceScope.journey);
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: () => BabyVoiceService.instance
                      .toggleMuteFor(VoiceScope.journey),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: (father ? kFAccent : AppTheme.primary500)
                          .withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                      size: 20,
                      color: muted
                          ? AppTheme.neutral400
                          : (father ? kFAccent : AppTheme.primary600),
                    ),
                  ),
                ),
              );
            },
          ),
          // EN / Hindi toggle - hidden for now per request. Kept (commented) for
          // an easy revert; _LanguageToggle is preserved below.
          // Padding(
          //   padding: const EdgeInsets.only(right: 16),
          //   child: _LanguageToggle(
          //     language: _c.language,
          //     onChanged: _c.setLanguage,
          //   ),
          // ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_c.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_c.hasError) {
      return _ErrorState(error: _c.error, onRetry: _c.load, strings: S(_c.language));
    }

    final selectedWeek = _c.selectedWeek;
    _builtForWeek ??= selectedWeek;
    final father = FatherPreview.instance.on; // Slate chrome on ALL weeks now

    final selRange = _c.weekDates(selectedWeek);
    final dateText = _fmtRange(selRange.start, selRange.end);

    // The compact week bar (design): current week ±2 on one row, dots between.
    final strip = _WeekBar(controller: _c, father: father);

    return NestedScrollView(
      headerSliverBuilder: (context, innerScrolled) => [
        SliverOverlapAbsorber(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          sliver: SliverPersistentHeader(
            // Only the ParentVeda app bar stays fixed; the trimester / progress
            // / week-bar header scrolls away with the content (better scroll
            // experience on a short page).
            pinned: false,
            delegate: _WeekHeaderDelegate(
              controller: _c,
              strip: strip,
              dateText: dateText,
              father: father,
              compactHeight: _compactHeaderHeight,
              stripHeight: _stripHeaderHeight,
            ),
          ),
        ),
      ],
      // The "New" (V2) vertical section flow is now the ONLY weekly view, for
      // EVERY week (4–40). The classic swipe carousel (_pagerBody) is parked for
      // revert. Week 40 appends the celebration finale at the bottom of the flow.
      body: _c.isLocked(selectedWeek)
          ? _lockedBody(selectedWeek)
          : WeekFlowView(
              controller: _c,
              trailing:
                  selectedWeek == PregnancyController.lastContentWeek
                      ? SizedBox(
                          height: MediaQuery.of(context).size.height * 0.8,
                          child: _celebrationCard(),
                        )
                      : null,
            ),
    );
  }

  /// Locked weeks: a single non-scrolling panel that still sits under the header.
  Widget _lockedBody(int week) {
    return Builder(
      builder: (context) => CustomScrollView(
        slivers: [
          SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: LockedWeekView(
                week: week,
                currentWeek: _c.currentWeek,
                language: _c.language,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// The swipeable card carousel - parked (the V2 flow replaced it for all
  /// weeks). Kept for revert.
  // ignore: unused_element
  Widget _pagerBody(int week) {
    final cards = _cardsFor(week);
    if (cards.isEmpty) {
      return Center(child: Text(S(_c.language).noContent));
    }

    // Auto-play the active dialogue card after this frame settles.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _autoPlayActive(week);
    });

    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: cards.length,
          onPageChanged: (i) {
            BabyVoiceService.instance.stop();
            setState(() => _cardIndex = i);
            _autoPlayActive(week);
          },
          itemBuilder: (context, index) => _cardPage(week, index, cards[index]),
        ),
        Positioned(
          left: 0,
          right: 0,
          // Sit above the floating bottom nav pill so the dots' white pill no
          // longer peeks out behind it.
          bottom: 86,
          child: IgnorePointer(
            child: Center(
              child: _DotsPill(
                count: cards.length,
                active: _cardIndex.clamp(0, cards.length - 1),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// One card as a vertical scroll view tied to the NestedScrollView. The
  /// week-40 finale stays full-bleed (it manages its own internal scroll).
  Widget _cardPage(int week, int index, Widget card) {
    final bool fullBleed = card is CelebrationCard;
    return Builder(
      builder: (context) {
        final injector = SliverOverlapInjector(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        );
        final chrome = CardChrome(
          gradient: gradientForWeek(week),
          child: card,
        );
        return CustomScrollView(
          key: PageStorageKey('wk${week}_c$index'),
          slivers: [
            injector,
            if (fullBleed)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
                  child: chrome,
                ),
              )
            else
              SliverPadding(
                // Bottom room so content clears the floating page dots.
                padding: const EdgeInsets.fromLTRB(8, 10, 8, 92),
                sliver: SliverToBoxAdapter(child: chrome),
              ),
          ],
        );
      },
    );
  }

  /// Auto-plays the active card's baby dialogue (once per card per session).
  String? _lastAutoKey;
  void _autoPlayActive(int week) {
    final data = _c.weekData(week);
    if (data == null) return;
    final lang = _c.language;
    String? text;
    String? card;
    if (_cardIndex == 0) {
      text = data.snapshot.reveal.of(lang);
      card = 'size_reveal';
    } else if (_cardIndex == 2 && week != 20) {
      // Card 1 is the Weekly Video; Baby Update sits at index 2 - except week 20,
      // whose overview card folds Baby into an accordion (no separate card).
      text = data.development.whatImDoing.of(lang);
      card = 'baby_update';
    }
    if (text == null || card == null) return;
    final key = BabyVoiceService.keyFor(week, card);
    if (key == _lastAutoKey) return;
    _lastAutoKey = key;
    BabyVoiceService.instance.autoPlay(text, cardKey: key, lang: lang);
  }

  /// The week-40 celebration finale (the keepsake-booklet entry), built so the
  /// V2 flow can append it at the bottom - same construction the classic
  /// carousel used.
  Widget _celebrationCard() {
    final lang = _c.language;
    final ranges = <int, String>{};
    for (final wk in _c.availableWeeks) {
      final r = _c.weekDates(wk);
      ranges[wk] = _fmtRange(r.start, r.end);
    }
    return CelebrationCard(
      language: lang,
      dateRanges: ranges,
      completionDate: _fmtFull(DateTime.now()),
    );
  }

  /// The ordered card list for a week. Reflect & Remember is second-last and
  /// Share Your Journey is always last. Week 40 appends the celebration finale.
  List<Widget> _cardsFor(int week) {
    final data = _c.weekData(week);
    if (data == null) return const [];
    final lang = _c.language;
    final cards = buildWeekCards(data, lang);
    if (week == PregnancyController.lastContentWeek) {
      // Pre-format each week's date range + the completion date for the booklet.
      final ranges = <int, String>{};
      for (final wk in _c.availableWeeks) {
        final r = _c.weekDates(wk);
        ranges[wk] = _fmtRange(r.start, r.end);
      }
      cards.add(CelebrationCard(
        language: lang,
        dateRanges: ranges,
        completionDate: _fmtFull(DateTime.now()),
      ));
    }
    return cards;
  }
}

// ---------------------------------------------------------------------------
//  English / Hinglish toggle
// ---------------------------------------------------------------------------

// ignore: unused_element  (EN/Hi toggle hidden for now; kept for an easy revert)
class _LanguageToggle extends StatelessWidget {
  const _LanguageToggle({required this.language, required this.onChanged});

  final AppLanguage language;
  final ValueChanged<AppLanguage> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Segment(
            label: 'EN',
            selected: language.isEnglish,
            onTap: () => onChanged(AppLanguage.english),
          ),
          _Segment(
            label: 'Hi',
            selected: language.isHinglish,
            onTap: () => onChanged(AppLanguage.hinglish),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary500 : Colors.transparent,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Text(
          label,
          style: text.labelLarge?.copyWith(
            color: selected ? Colors.white : AppTheme.neutral500,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  Collapsing header: trimester + week + date (pinned) over the week strip
// ---------------------------------------------------------------------------

/// The pinned, collapsing header for the weekly stack. A compact info row
/// (trimester name · week · date range · progress) stays visible at all times;
/// the week-dot carousel underneath collapses smoothly as the cards scroll.
class _WeekHeaderDelegate extends SliverPersistentHeaderDelegate {
  _WeekHeaderDelegate({
    required this.controller,
    required this.strip,
    required this.dateText,
    required this.father,
    required this.compactHeight,
    required this.stripHeight,
  });

  final PregnancyController controller;
  final Widget strip;
  final String dateText;
  final bool father;
  final double compactHeight;
  final double stripHeight;

  @override
  double get minExtent => compactHeight;

  @override
  double get maxExtent => compactHeight + stripHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final extent = (maxExtent - shrinkOffset).clamp(minExtent, maxExtent);
    final stripArea = (extent - compactHeight).clamp(0.0, stripHeight);
    // 1 when fully open, 0 when fully collapsed.
    final reveal = stripHeight == 0 ? 0.0 : (stripArea / stripHeight);

    final s = S(controller.language);
    final week = controller.selectedWeek;
    final togo = PregnancyController.lastContentWeek - controller.currentWeek;
    final progress =
        (week / PregnancyController.lastContentWeek).clamp(0.0, 1.0);

    return Material(
      color: father ? kFBg : Theme.of(context).scaffoldBackgroundColor,
      // A hairline that fades in as the strip collapses, separating the pinned
      // header from the scrolling cards beneath.
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: compactHeight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Trimester + weeks-to-go (design: bold title, pink count).
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Expanded(
                        child: Text(
                          s.trimesterName(week),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          // Same font as the mother (serif read poorly), Slate
                          // ink, a touch bolder (w800) per request.
                          style: father
                              ? GoogleFonts.plusJakartaSans(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: kFInk,
                                )
                              : GoogleFonts.plusJakartaSans(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.primary900,
                                ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        togo <= 0 ? s.weeksToGoNow : s.weeksToGo(togo),
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: father ? kFAccent2 : AppTheme.secondary500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 9),
                  // Progress bar (purple gradient) + "Week N · dates".
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 9,
                          decoration: BoxDecoration(
                            // Flat single-colour track - no two-colour gradient
                            // (the slate→amber "ghost" was removed per request).
                            color: (father ? kFAccent : AppTheme.primary500)
                                .withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: progress,
                            child: Container(
                              decoration: BoxDecoration(
                                // Single fill colour (was a 2-colour gradient).
                                color: father ? kFAccent : AppTheme.primary500,
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${s.weekWord} $week · $dateText',
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: father ? kFAccent : AppTheme.primary600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Collapsible week-dot carousel: shrinks in height and fades together.
          ClipRect(
            child: SizedBox(
              height: stripArea,
              width: double.infinity,
              child: OverflowBox(
                minHeight: 0,
                maxHeight: stripHeight,
                alignment: Alignment.topCenter,
                child: Opacity(
                  opacity: reveal.clamp(0.0, 1.0),
                  child: SizedBox(height: stripHeight, child: strip),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _WeekHeaderDelegate old) =>
      old.dateText != dateText ||
      old.controller.selectedWeek != controller.selectedWeek ||
      old.controller.language != controller.language ||
      old.father != father ||
      old.compactHeight != compactHeight ||
      old.stripHeight != stripHeight;
}

// ---------------------------------------------------------------------------
//  Week navigation strip - OLD scrollable carousel, replaced by the compact
//  _WeekBar (design). Kept (commented) for an easy revert.
// ---------------------------------------------------------------------------
/*
class _WeekStrip extends StatefulWidget {
  const _WeekStrip({
    super.key,
    required this.controller,
    required this.onScrollActive,
  });

  final PregnancyController controller;

  /// Called with true when the user starts scrolling the strip and false once
  /// it settles - lets the screen hush the baby voice while browsing weeks.
  final ValueChanged<bool> onScrollActive;

  @override
  State<_WeekStrip> createState() => _WeekStripState();
}

class _WeekStripState extends State<_WeekStrip> {
  final ScrollController _scroll = ScrollController();

  /// Each week occupies a fixed slot; with symmetric padding of half the
  /// leftover width, a week is centred exactly when scrollOffset == i * extent.
  static const double _extent = 58;

  /// True while we drive the scroll ourselves (tap-to-center / snap), so the
  /// scroll listener doesn't fight the animation by re-selecting.
  bool _programmatic = false;

  PregnancyController get _c => widget.controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _centerSelected(animate: false));
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  int get _selectedIndex {
    final i = _c.availableWeeks.indexOf(_c.selectedWeek);
    return i < 0 ? 0 : i;
  }

  void _centerSelected({bool animate = true}) {
    if (!_scroll.hasClients) return;
    final target =
        (_selectedIndex * _extent).clamp(0.0, _scroll.position.maxScrollExtent);
    if (!animate) {
      _scroll.jumpTo(target);
      return;
    }
    _programmatic = true;
    _scroll
        .animateTo(target,
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic)
        .whenComplete(() => _programmatic = false);
  }

  /// As the strip scrolls, the week nearest the centre becomes active so the
  /// card stack updates live.
  void _onScrollUpdate() {
    if (_programmatic || !_scroll.hasClients) return;
    final weeks = _c.availableWeeks;
    if (weeks.isEmpty) return;
    final idx = (_scroll.offset / _extent).round().clamp(0, weeks.length - 1);
    final week = weeks[idx];
    if (week != _c.selectedWeek) {
      HapticFeedback.selectionClick();
      _c.selectWeek(week);
    }
  }

  /// Snap the nearest week to the exact centre when scrolling settles.
  void _snapToNearest() {
    if (_programmatic || !_scroll.hasClients) return;
    final weeks = _c.availableWeeks;
    if (weeks.isEmpty) return;
    final idx = (_scroll.offset / _extent).round().clamp(0, weeks.length - 1);
    final target =
        (idx * _extent).clamp(0.0, _scroll.position.maxScrollExtent);
    if ((target - _scroll.offset).abs() > 0.5) {
      _programmatic = true;
      _scroll
          .animateTo(target,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut)
          .whenComplete(() => _programmatic = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _c;
    final weeks = c.availableWeeks;

    // Just the tightened week-dot carousel - the date range now lives in the
    // pinned header line, and the redundant "weeks" caption is gone.
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 2),
      child: SizedBox(
        height: 70,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final padH =
                ((constraints.maxWidth - _extent) / 2).clamp(0.0, 9999.0);
            return NotificationListener<ScrollNotification>(
              onNotification: (n) {
                if (n is ScrollStartNotification) {
                  if (!_programmatic) widget.onScrollActive(true);
                } else if (n is ScrollUpdateNotification) {
                  _onScrollUpdate();
                } else if (n is ScrollEndNotification) {
                  _snapToNearest();
                  widget.onScrollActive(false);
                }
                return false;
              },
              child: ListView.builder(
                controller: _scroll,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                // Don't clip children - let the round glow spill past cells.
                clipBehavior: Clip.none,
                padding: EdgeInsets.symmetric(horizontal: padH),
                itemExtent: _extent,
                itemCount: weeks.length,
                itemBuilder: (context, i) {
                  final week = weeks[i];
                  return Center(
                    child: _WeekDot(
                      week: week,
                      locked: c.isLocked(week),
                      isCurrent: week == c.currentWeek,
                      isSelected: week == c.selectedWeek,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        c.selectWeek(week);
                        _centerSelected();
                      },
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
*/

// ---------------------------------------------------------------------------
//  Week bar (design) - current week ±2 on one compact row, dots between, the
//  selected week a filled purple disc. Tapping a neighbour steps the week.
// ---------------------------------------------------------------------------
/// A horizontally scrollable week strip - all weeks in one row, the selected
/// week a filled purple disc. Scrolls left/right to browse; tap to switch; the
/// selected week auto-centres.
class _WeekBar extends StatefulWidget {
  const _WeekBar({required this.controller, this.father = false});
  final PregnancyController controller;
  final bool father;
  @override
  State<_WeekBar> createState() => _WeekBarState();
}

class _WeekBarState extends State<_WeekBar> {
  final ScrollController _sc = ScrollController();
  static const double _cell = 56; // week cell (40) + gap (16)

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChange);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _center(animate: false));
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChange);
    _sc.dispose();
    super.dispose();
  }

  void _onChange() => WidgetsBinding.instance
      .addPostFrameCallback((_) => _center(animate: true));

  void _center({required bool animate}) {
    if (!mounted || !_sc.hasClients) return;
    final weeks = widget.controller.availableWeeks;
    final idx = weeks.indexOf(widget.controller.selectedWeek);
    if (idx < 0) return;
    final screenW = MediaQuery.of(context).size.width;
    final target = ((idx * _cell) + 20 - screenW / 2 + _cell / 2)
        .clamp(0.0, _sc.position.maxScrollExtent);
    if (animate) {
      _sc.animateTo(target,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      _sc.jumpTo(target);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final weeks = c.availableWeeks;
    if (weeks.isEmpty) return const SizedBox.shrink();
    final father = widget.father;
    final connector =
        father ? const Color(0xFFCBD6DA) : const Color(0xFFD8CAEC);
    return SingleChildScrollView(
      controller: _sc,
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 6),
      child: Row(children: [
        for (int i = 0; i < weeks.length; i++) ...[
          SizedBox(
            width: 40,
            child: _WeekDot(
              week: weeks[i],
              locked: c.isLocked(weeks[i]),
              isCurrent: weeks[i] == c.currentWeek,
              isSelected: weeks[i] == c.selectedWeek,
              father: father,
              onTap: () => c.selectWeek(weeks[i]),
            ),
          ),
          if (i < weeks.length - 1)
            SizedBox(
              width: 16,
              child: Center(
                child: SizedBox(
                  width: 4,
                  height: 4,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                        color: connector, shape: BoxShape.circle),
                  ),
                ),
              ),
            ),
        ],
      ]),
    );
  }
}

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
];

/// Compact "22–28 Oct" (same month) or "29 Oct – 4 Nov".
String _fmtRange(DateTime a, DateTime b) {
  if (a.month == b.month) {
    return '${a.day}–${b.day} ${_months[a.month - 1]}';
  }
  return '${a.day} ${_months[a.month - 1]} – ${b.day} ${_months[b.month - 1]}';
}

/// Full "18 Jun 2026" - used for the booklet completion date.
String _fmtFull(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

/// A single circular week marker - just the number. The selected week is a
/// filled, slightly larger disc; the rest are soft and faint.
class _WeekDot extends StatelessWidget {
  const _WeekDot({
    required this.week,
    required this.locked,
    required this.isCurrent,
    required this.isSelected,
    required this.onTap,
    this.father = false,
  });

  final int week;
  final bool locked;
  final bool isCurrent;
  final bool isSelected;
  final VoidCallback onTap;
  final bool father;

  @override
  Widget build(BuildContext context) {
    final accent = father ? kFAccent : AppTheme.primary500;
    // Selected week - a filled disc with a soft glow (design).
    if (isSelected) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.30),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              '$week',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
    }
    // Other weeks - a soft number; the current week gets a small accent dot.
    final color = locked
        ? AppTheme.neutral300
        : (isCurrent ? accent : (father ? kFMuted : AppTheme.neutral400));
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$week',
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            if (isCurrent) ...[
              const SizedBox(height: 4),
              Container(
                width: 5,
                height: 5,
                decoration:
                    BoxDecoration(color: accent, shape: BoxShape.circle),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  Page indicator dots
// ---------------------------------------------------------------------------

/// The page dots wrapped in a soft floating pill so they stay legible over the
/// scrolling card content at the foot of the carousel.
class _DotsPill extends StatelessWidget {
  const _DotsPill({required this.count, required this.active});

  final int count;
  final int active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary900.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: _PageDots(count: count, active: active),
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.active});

  final int count;
  final int active;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == active ? 22 : 7,
            height: 7,
            decoration: BoxDecoration(
              color: i == active
                  ? AppTheme.primary500
                  : AppTheme.primary200,
              borderRadius: BorderRadius.circular(40),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
//  Error state
// ---------------------------------------------------------------------------

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.error,
    required this.onRetry,
    required this.strings,
  });

  final Object? error;
  final Future<void> Function() onRetry;
  final S strings;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded,
                size: 48, color: AppTheme.neutral300),
            const SizedBox(height: 16),
            Text(strings.loadError,
                style: text.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text('$error',
                style: text.bodySmall, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            FilledButton(onPressed: onRetry, child: Text(strings.tryAgain)),
          ],
        ),
      ),
    );
  }
}
