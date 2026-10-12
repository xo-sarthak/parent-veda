// =============================================================================
//  pv_veda_reveal.dart - how an Ask Veda answer arrives on the screen
// -----------------------------------------------------------------------------
//  The service returns the whole 7-section answer in one reply (no streaming).
//  Dropping 200 words onto the page at once reads as a wall; ChatGPT, Claude
//  and Perplexity all let the answer ARRIVE. These pieces give the three Ask
//  Veda screens (pregnancy, parenting, trying to conceive) one shared way to
//  do that:
//
//    PvVedaThinking     - the calm wait: three soft dots, a status line that
//                         moves on ("Looking through ParentVeda..."), and two
//                         faint placeholder lines where the answer will be.
//    PvTypewriterText   - the answer, revealed a few words at a time with a
//                         soft trailing fade and a small caret. Tap to finish.
//    PvVedaFadeIn       - everything below the text (cards, actions) fades and
//                         rises in, staggered, once the text has finished.
//    pvVedaFollowUps    - "You could also ask": picks the next questions from
//                         the suggestion pool the screen already has.
//
//  ⚠️ THIS IS PRESENTATION ONLY. The answer is complete before the first word
//  shows; the reveal is a pacing choice on the phone. Nothing here touches the
//  wire body (`AskVedaService.ask`) or the service, so there is no two-repo
//  change. The trade-off, stated plainly: real streaming would show the first
//  word sooner (the wait is the service's, not ours); a client reveal costs
//  1-3 seconds of pacing on an answer we already hold, which is why it is
//  fast, scaled to length, skippable with a tap, and skipped entirely when
//  the system asks for reduced motion or the answer has been seen before.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;

/// Answers already revealed this session. A rebuild, a cached answer coming
/// back, or the same question asked twice shows the text at once rather than
/// typing it again: the second time, the reveal is only a delay.
///
/// Keyed on the text itself, and capped so a long session does not grow it
/// without bound (oldest dropped first; a [Set] literal keeps insertion order).
final Set<String> _pvRevealed = <String>{};
const int _kRevealedCap = 80;

void _markRevealed(String text) {
  _pvRevealed.add(text);
  while (_pvRevealed.length > _kRevealedCap) {
    _pvRevealed.remove(_pvRevealed.first);
  }
}

/// True when [text] has already been revealed once this session.
bool pvVedaAlreadyRevealed(String text) => _pvRevealed.contains(text);

/// Test seam: forget every revealed answer.
@visibleForTesting
void pvVedaResetRevealed() => _pvRevealed.clear();

bool _reduceMotion(BuildContext context) =>
    MediaQuery.maybeDisableAnimationsOf(context) ?? false;

// =============================================================================
//  PvTypewriterText
// =============================================================================

/// Reveals [text] progressively, by words, then calls [onDone] once.
///
/// * Paced by length: ~22 ms a word, never under 0.6 s nor over 2.8 s, so a
///   short answer does not crawl and a long one does not keep her waiting.
/// * Words, not characters: a word appears whole, so a line never re-wraps
///   under her eye, and the last few words fade up softly (the Claude app's
///   trailing fade) instead of popping.
/// * A small caret dot sits at the end while it types.
/// * Tap the text to finish at once.
/// * Instant when [MediaQuery.disableAnimations] is set, when [animate] is
///   false, or when this exact text was revealed before ([pvVedaAlreadyRevealed]).
/// * While it types it keeps its last line in view inside the enclosing
///   scroll view - unless she scrolls up herself, which stops the following
///   for this answer (she is reading something; the page must not pull her).
/// * Screen readers get the whole text at once, never a half sentence.
class PvTypewriterText extends StatefulWidget {
  const PvTypewriterText(
    this.text, {
    super.key,
    required this.style,
    this.onDone,
    this.caretColor,
    this.animate = true,
    this.followBottomInset = 120,
  });

  final String text;
  final TextStyle style;

  /// Called once, after the last word is shown (also when shown instantly).
  final VoidCallback? onDone;

  /// The caret's colour; defaults to the text colour.
  final Color? caretColor;

  /// False shows the text at once (e.g. a screen that is not revealing).
  final bool animate;

  /// How far above the bottom of the scroll viewport the last line is kept
  /// (clears a bottom nav or a pinned composer).
  final double followBottomInset;

  @override
  State<PvTypewriterText> createState() => _PvTypewriterTextState();
}

class _PvTypewriterTextState extends State<PvTypewriterText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this)..addListener(_tick);
  List<String> _tokens = const [];
  bool _started = false;
  bool _doneFired = false;
  bool _detached = false; // she scrolled up: stop following
  ScrollPosition? _pos;
  int _lastShown = -1;

  static final RegExp _tokenRe = RegExp(r'\S+\s*|\s+');

  @override
  void initState() {
    super.initState();
    _tokens = _tokenize(widget.text);
  }

  List<String> _tokenize(String t) =>
      _tokenRe.allMatches(t).map((m) => m.group(0)!).toList();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _attachScroll();
    if (!_started) {
      _started = true;
      _begin();
    }
  }

  @override
  void didUpdateWidget(PvTypewriterText old) {
    super.didUpdateWidget(old);
    if (old.text != widget.text) {
      _tokens = _tokenize(widget.text);
      _doneFired = false;
      _detached = false;
      _lastShown = -1;
      _c.stop();
      _c.value = 0;
      _begin();
    }
  }

  void _begin() {
    final instant = !widget.animate ||
        _reduceMotion(context) ||
        _tokens.length <= 1 ||
        pvVedaAlreadyRevealed(widget.text);
    if (instant) {
      _c.value = 1;
      _finish();
      return;
    }
    final ms = (_tokens.length * 22).clamp(600, 2800);
    _c.duration = Duration(milliseconds: ms);
    _c.forward(from: 0);
  }

  void _attachScroll() {
    final pos = Scrollable.maybeOf(context)?.position;
    if (identical(pos, _pos)) return;
    _pos?.removeListener(_onScroll);
    _pos = pos;
    _pos?.addListener(_onScroll);
  }

  void _onScroll() {
    // `forward` is a USER drag toward the top of the list. Our own animateTo
    // reports idle, so this only ever trips on her finger.
    if (_pos?.userScrollDirection == ScrollDirection.forward) _detached = true;
  }

  void _tick() {
    if (!mounted) return;
    final shown = (_c.value * _tokens.length).ceil();
    // Rebuild every frame for the soft fade; follow only when a word lands.
    setState(() {});
    if (shown != _lastShown) {
      _lastShown = shown;
      _follow();
    }
    if (_c.isCompleted) _finish();
  }

  void _follow() {
    if (_detached || _c.isCompleted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _detached) return;
      final pos = _pos;
      final scrollable = Scrollable.maybeOf(context);
      final box = context.findRenderObject();
      final viewport = scrollable?.context.findRenderObject();
      if (pos == null ||
          box is! RenderBox ||
          viewport is! RenderBox ||
          !box.attached ||
          !viewport.attached ||
          !pos.hasPixels) {
        return;
      }
      final bottom = box
          .localToGlobal(Offset(0, box.size.height), ancestor: viewport)
          .dy;
      final limit = viewport.size.height - widget.followBottomInset;
      if (bottom <= limit) return;
      final target =
          (pos.pixels + bottom - limit).clamp(pos.minScrollExtent, pos.maxScrollExtent);
      if ((target - pos.pixels).abs() < 1) return;
      pos.animateTo(target,
          duration: const Duration(milliseconds: 180), curve: Curves.easeOut);
    });
  }

  void _finish() {
    if (_doneFired) return;
    _doneFired = true;
    _markRevealed(widget.text);
    // After this frame: the parent will setState to bring in what follows.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onDone?.call();
    });
  }

  void _complete() {
    if (_c.isAnimating) {
      _c.stop();
      _c.value = 1;
      _finish();
    }
  }

  @override
  void dispose() {
    _pos?.removeListener(_onScroll);
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final done = _c.value >= 1;
    final Widget body;
    if (done) {
      body = Text(widget.text, style: widget.style);
    } else {
      final base = widget.style.color ?? DefaultTextStyle.of(context).style.color ?? Colors.black;
      final r = _c.value * _tokens.length; // fractional words shown
      final shown = r.ceil().clamp(0, _tokens.length);
      const fadeSpan = 4.0; // the last ~4 words are still fading up
      final spans = <InlineSpan>[];
      for (var i = 0; i < shown; i++) {
        final a = ((r - i) / fadeSpan).clamp(0.0, 1.0);
        spans.add(TextSpan(
          text: _tokens[i],
          style: a >= 1 ? null : TextStyle(color: base.withValues(alpha: base.a * (0.25 + 0.75 * a))),
        ));
      }
      spans.add(WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Padding(
          padding: const EdgeInsets.only(left: 2),
          child: Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: widget.caretColor ?? base,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ));
      body = Text.rich(TextSpan(style: widget.style, children: spans));
    }
    return Semantics(
      label: widget.text,
      excludeSemantics: true,
      child: GestureDetector(
        key: const ValueKey('pv_typewriter'),
        behavior: done ? HitTestBehavior.deferToChild : HitTestBehavior.opaque,
        onTap: done ? null : _complete,
        child: SizedBox(width: double.infinity, child: body),
      ),
    );
  }
}

// =============================================================================
//  PvVedaFadeIn - what follows the text
// =============================================================================

/// Fades and lifts [child] in when [show] turns true, after [index] x 70 ms,
/// so the sections under an answer arrive one after another rather than all
/// at once (Perplexity's sources and follow-ups land after the text).
///
/// The child is always laid out and stays tappable while hidden, so the page
/// does not jump when it appears and nothing she reaches for is ever dead.
/// Instant under reduced motion, or when [show] is already true on first build.
class PvVedaFadeIn extends StatefulWidget {
  const PvVedaFadeIn({
    super.key,
    required this.show,
    required this.child,
    this.index = 0,
  });

  final bool show;
  final int index;
  final Widget child;

  @override
  State<PvVedaFadeIn> createState() => _PvVedaFadeInState();
}

class _PvVedaFadeInState extends State<PvVedaFadeIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this);
  late Animation<double> _t;

  @override
  void initState() {
    super.initState();
    _configure();
    if (widget.show) _c.value = 1;
  }

  void _configure() {
    final delay = (widget.index.clamp(0, 8)) * 70;
    const run = 340;
    _c.duration = Duration(milliseconds: delay + run);
    _t = CurvedAnimation(
      parent: _c,
      curve: Interval(delay / (delay + run), 1, curve: Curves.easeOutCubic),
    );
  }

  @override
  void didUpdateWidget(PvVedaFadeIn old) {
    super.didUpdateWidget(old);
    if (old.index != widget.index) _configure();
    if (widget.show && !old.show) {
      if (_reduceMotion(context)) {
        _c.value = 1;
      } else {
        _c.forward(from: 0);
      }
    } else if (!widget.show && old.show) {
      _c.value = 0;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _t,
        child: widget.child,
        builder: (context, child) {
          final v = _t.value;
          return Opacity(
            opacity: v,
            child: Transform.translate(
                offset: Offset(0, 14 * (1 - v)), child: child),
          );
        },
      );
}

// =============================================================================
//  PvVedaThinking - the wait
// =============================================================================

/// The calm wait while the service thinks: three soft pulsing dots, a status
/// line that moves on every ~1.8 s through [lines] (Mindtrip's "Thinking
/// longer / Checking the details"), and two faint placeholder lines where
/// the answer will land (Public's skeleton). No spinner, no emoji.
///
/// Under reduced motion it holds still on the first line.
class PvVedaThinking extends StatefulWidget {
  const PvVedaThinking({
    super.key,
    required this.lines,
    required this.color,
    required this.textStyle,
    this.barColor = const Color(0xFFF0EEF1),
  });

  final List<String> lines;
  final Color color;
  final TextStyle textStyle;
  final Color barColor;

  @override
  State<PvVedaThinking> createState() => _PvVedaThinkingState();
}

class _PvVedaThinkingState extends State<PvVedaThinking>
    with SingleTickerProviderStateMixin {
  static const int _lineMs = 1800;
  static const int _dotMs = 1200;
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: _lineMs * widget.lines.length.clamp(1, 9)),
  );
  bool _still = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _still = _reduceMotion(context);
    if (_still) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final totalMs = _c.value * (_c.duration?.inMilliseconds ?? _lineMs);
        final lineIdx = widget.lines.isEmpty
            ? 0
            : (_still ? 0 : (totalMs ~/ _lineMs) % widget.lines.length);
        final dotPhase = (totalMs % _dotMs) / _dotMs;
        return Semantics(
          liveRegion: true,
          label: widget.lines.isEmpty ? null : widget.lines[lineIdx],
          child: Column(
            key: const ValueKey('pv_veda_thinking'),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                for (var i = 0; i < 3; i++) _dot(i, dotPhase),
                const SizedBox(width: 10),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 320),
                    layoutBuilder: (cur, prev) => Stack(
                        alignment: Alignment.centerLeft,
                        children: [...prev, ?cur]),
                    child: Text(
                      widget.lines.isEmpty ? '' : widget.lines[lineIdx],
                      key: ValueKey(lineIdx),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: widget.textStyle,
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 18),
              _bar(1.0, dotPhase, 0),
              const SizedBox(height: 10),
              _bar(0.86, dotPhase, 1),
              const SizedBox(height: 10),
              _bar(0.58, dotPhase, 2),
            ],
          ),
        );
      },
    );
  }

  // A dot breathes between 35% and 100%, each a third of a beat behind.
  Widget _dot(int i, double phase) {
    double a = 0.35;
    if (!_still) {
      final p = (phase - i * 0.18) % 1.0;
      final wave = p < 0.5 ? p * 2 : (1 - p) * 2; // 0..1..0
      a = 0.35 + 0.65 * Curves.easeInOut.transform(wave);
    }
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(
          color: widget.color.withValues(alpha: widget.color.a * a),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _bar(double widthFactor, double phase, int i) {
    double a = 1;
    if (!_still) {
      final p = (phase - i * 0.12) % 1.0;
      final wave = p < 0.5 ? p * 2 : (1 - p) * 2;
      a = 0.55 + 0.45 * wave;
    }
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: Container(
        height: 10,
        decoration: BoxDecoration(
          color: widget.barColor.withValues(alpha: a),
          borderRadius: BorderRadius.circular(99),
        ),
      ),
    );
  }
}

// =============================================================================
//  pvVedaFollowUps - "You could also ask"
// =============================================================================

/// Up to [count] questions from [pool] to offer after an answer, leaving out
/// the one just asked. Questions that share a meaningful word with [asked]
/// lead (a crude relatedness, done on the phone; the service sends no
/// follow-ups of its own), the rest keep the pool's order.
List<String> pvVedaFollowUps(String asked, Iterable<String> pool,
    {int count = 3}) {
  Set<String> words(String s) => {
        for (final w in s.toLowerCase().split(RegExp(r'[^a-z0-9]+')))
          if (w.length >= 4) w
      };
  final a = asked.trim().toLowerCase();
  final aw = words(asked);
  final seen = <String>{};
  final scored = <(int, int, String)>[];
  var i = 0;
  for (final q in pool) {
    final k = q.trim().toLowerCase();
    if (k.isEmpty || k == a || !seen.add(k)) continue;
    final shared = words(q).intersection(aw).length;
    scored.add((-shared, i++, q.trim()));
  }
  scored.sort((x, y) => x.$1 != y.$1 ? x.$1 - y.$1 : x.$2 - y.$2);
  return [for (final s in scored.take(count)) s.$3];
}
