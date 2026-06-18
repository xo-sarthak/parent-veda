// =============================================================================
//  WeeklyCardStackScreen
// -----------------------------------------------------------------------------
//  The heart of ParentVeda: a horizontal, swipeable stack of 7 cards for the
//  active week, a week-navigation strip (with locked future weeks), and an
//  English / Hinglish toggle in the AppBar.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_constants.dart';
import '../localization/app_language.dart';
import '../services/baby_voice_service.dart';
import '../services/pregnancy_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/cards/card_shell.dart';
import '../widgets/locked_week_view.dart';
import '../widgets/week_cards/celebration_card.dart';
import '../widgets/week_cards/week_cards.dart';

class WeeklyCardStackScreen extends StatefulWidget {
  const WeeklyCardStackScreen({super.key, required this.controller});

  final PregnancyController controller;

  @override
  State<WeeklyCardStackScreen> createState() => _WeeklyCardStackScreenState();
}

class _WeeklyCardStackScreenState extends State<WeeklyCardStackScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.92);
  int _cardIndex = 0;

  /// Tracks which week the PageView is currently built for, so we can reset to
  /// the first card whenever the user switches weeks.
  int? _builtForWeek;

  PregnancyController get _c => widget.controller;

  @override
  void initState() {
    super.initState();
    _c.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _c.removeListener(_onControllerChanged);
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

  @override
  Widget build(BuildContext context) {
    final s = S(_c.language);
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(s.appName, style: Theme.of(context).textTheme.headlineSmall),
            Text(
              s.weekOf(_c.selectedWeek, PregnancyController.lastContentWeek),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          AnimatedBuilder(
            animation: BabyVoiceService.instance,
            builder: (context, _) {
              final muted = BabyVoiceService.instance.isMuted;
              return IconButton(
                tooltip: muted ? 'Unmute baby voice' : 'Mute baby voice',
                onPressed: () => BabyVoiceService.instance.toggleMute(),
                icon: Icon(
                  muted ? Icons.hearing_disabled_rounded : Icons.hearing_rounded,
                  color: muted ? AppTheme.neutral400 : AppTheme.primary500,
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _LanguageToggle(
              language: _c.language,
              onChanged: _c.setLanguage,
            ),
          ),
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

    return Column(
      children: [
        const SizedBox(height: 6),
        _TrimesterBar(controller: _c),
        const SizedBox(height: 6),
        _WeekStrip(controller: _c, onScrollActive: _onWeekScroll),
        const SizedBox(height: 8),
        Expanded(
          child: _c.isLocked(selectedWeek)
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: LockedWeekView(
                    week: selectedWeek,
                    currentWeek: _c.currentWeek,
                    language: _c.language,
                  ),
                )
              : _buildCardStack(selectedWeek),
        ),
      ],
    );
  }

  /// True while the user is dragging the week strip — keeps the baby voice
  /// quiet so browsing weeks isn't a wall of audio.
  bool _weekScrolling = false;
  void _onWeekScroll(bool active) {
    _weekScrolling = active;
    if (active) BabyVoiceService.instance.stop();
  }

  /// Auto-plays the active card's baby dialogue (once per card per session).
  String? _lastAutoKey;
  void _autoPlayActive(int week) {
    if (_weekScrolling) return;
    final data = _c.weekData(week);
    if (data == null) return;
    final lang = _c.language;
    String? text;
    String? card;
    if (_cardIndex == 0) {
      text = data.snapshot.reveal.of(lang);
      card = 'size_reveal';
    } else if (_cardIndex == 1) {
      text = data.development.whatImDoing.of(lang);
      card = 'baby_update';
    }
    if (text == null || card == null) return;
    final key = BabyVoiceService.keyFor(week, card);
    if (key == _lastAutoKey) return;
    _lastAutoKey = key;
    BabyVoiceService.instance.autoPlay(text, cardKey: key, lang: lang);
  }

  Widget _buildCardStack(int week) {
    final cards = _cardsFor(week);
    if (cards.isEmpty) {
      return Center(child: Text(S(_c.language).noContent));
    }

    // Auto-play the active dialogue card after this frame settles.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _autoPlayActive(week);
    });

    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: cards.length,
            onPageChanged: (i) {
              // Swiping to a different card stops the previous card's audio
              // immediately; auto-play (if any) then fires for the new card.
              BabyVoiceService.instance.stop();
              setState(() => _cardIndex = i);
              _autoPlayActive(week);
            },
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
                child: CardChrome(
                  gradient: gradientForWeek(week),
                  child: cards[index],
                ),
              );
            },
          ),
        ),
        _PageDots(count: cards.length, active: _cardIndex.clamp(0, cards.length - 1)),
        const SizedBox(height: 14),
      ],
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
//  Trimester indicator + progress
// ---------------------------------------------------------------------------

class _TrimesterBar extends StatelessWidget {
  const _TrimesterBar({required this.controller});
  final PregnancyController controller;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final s = S(controller.language);
    final week = controller.selectedWeek;
    final progress = (week / PregnancyController.lastContentWeek).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                s.trimesterName(week),
                style: text.labelMedium?.copyWith(
                  color: AppTheme.primary600,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${s.weekWord} $week · ${(progress * 100).round()}%',
                style: text.labelSmall,
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 4,
                backgroundColor: AppTheme.surfaceContainerHigh,
                valueColor: const AlwaysStoppedAnimation(AppTheme.primary500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  Week navigation strip
// ---------------------------------------------------------------------------

class _WeekStrip extends StatefulWidget {
  const _WeekStrip({required this.controller, required this.onScrollActive});

  final PregnancyController controller;

  /// Called with true when the user starts scrolling the strip and false once
  /// it settles — lets the screen hush the baby voice while browsing weeks.
  final ValueChanged<bool> onScrollActive;

  @override
  State<_WeekStrip> createState() => _WeekStripState();
}

class _WeekStripState extends State<_WeekStrip> {
  final ScrollController _scroll = ScrollController();

  /// Each week occupies a fixed slot; with symmetric padding of half the
  /// leftover width, a week is centred exactly when scrollOffset == i * extent.
  static const double _extent = 64;

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
    final text = Theme.of(context).textTheme;
    final weeks = c.availableWeeks;
    final selRange = c.weekDates(c.selectedWeek);

    return Column(
      children: [
        // Selected week's date range — one calm line, not crammed per pill.
        Text(
          _fmtRange(selRange.start, selRange.end),
          style: text.labelMedium?.copyWith(
            color: AppTheme.primary500,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 60,
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
        const SizedBox(height: 4),
        Text(
          S(c.language).weeksLabel,
          style: text.labelSmall?.copyWith(
            color: AppTheme.neutral400,
            letterSpacing: 1.2,
          ),
        ),
      ],
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

/// Full "18 Jun 2026" — used for the booklet completion date.
String _fmtFull(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

/// A single circular week marker — just the number. The selected week is a
/// filled, slightly larger disc; the rest are soft and faint.
class _WeekDot extends StatelessWidget {
  const _WeekDot({
    required this.week,
    required this.locked,
    required this.isCurrent,
    required this.isSelected,
    required this.onTap,
  });

  final int week;
  final bool locked;
  final bool isCurrent;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final double size = isSelected ? 56 : 46;
    final Color bg =
        isSelected ? AppTheme.primary500 : AppTheme.primary50.withValues(alpha: 0.7);
    final Color fg = isSelected ? Colors.white : AppTheme.primary300;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          border: isCurrent && !isSelected
              ? Border.all(color: AppTheme.primary300, width: 1.5)
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primary400.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: Text(
          '$week',
          style: (isSelected ? text.titleLarge : text.titleMedium)?.copyWith(
            color: fg,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  Page indicator dots
// ---------------------------------------------------------------------------

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
