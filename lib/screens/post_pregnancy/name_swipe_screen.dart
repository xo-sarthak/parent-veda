// =============================================================================
//  NameSwipeScreen - Baby Name Finder · swipe deck (parenting · S27·swipe)
// -----------------------------------------------------------------------------
//  The swipe-to-match deck: like (♥) or pass (✕) each name, undo (↺) the last,
//  tap a card for the full story, and when a name is a mutual yes a celebration
//  overlay appears. Likes flow into the shared NameMatchStore, which the matches
//  screen reads. Faithful build of Claude Design "post pregnancy - content.dc.html"
//  · S27·swipe - functional, nothing static.
// =============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'name_detail_screen.dart';
import 'name_matches_screen.dart';
import 'pp_common.dart';
import 'pp_names_data.dart';

const Color _blendFg = Color(0xFF7A4600);
const Color _blendBg = Color(0xFFF5EEE6);
const Color _feelBg = Color(0xFFEDE6F5);

class NameSwipeScreen extends StatefulWidget {
  const NameSwipeScreen({super.key});

  @override
  State<NameSwipeScreen> createState() => _NameSwipeScreenState();
}

class _NameSwipeScreenState extends State<NameSwipeScreen> with TickerProviderStateMixin {
  final NameMatchStore _store = NameMatchStore.instance;
  int _index = 0;
  bool _rareOnly = false;

  bool _showMatch = false;
  BabyName? _matched;

  // Distinct like/pass feedback - a coral heart-burst + warm pulse on a like,
  // a quieter muted pulse on a pass. Its own controller so it can outlast the
  // 260ms fly-off.
  late final AnimationController _fb;
  String? _fbKind;

  // Drag-to-swipe: the front card follows the finger; a fling past the threshold
  // (or a button press) animates it off-screen - right = love, left = pass - and
  // a short release springs it back. One controller drives both the fly-off and
  // the spring-back.
  late final AnimationController _ctrl;
  Offset _drag = Offset.zero;
  Offset _animFrom = Offset.zero;
  Offset _animTo = Offset.zero;
  String? _pending; // 'like' | 'pass' on a completed fly-off; null = spring-back
  static const double _threshold = 96;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 260))
      ..addListener(() {
        setState(() => _drag = Offset.lerp(_animFrom, _animTo, Curves.easeOut.transform(_ctrl.value))!);
      })
      ..addStatusListener((s) {
        if (s != AnimationStatus.completed) return;
        final pending = _pending;
        _pending = null;
        _drag = _animFrom = _animTo = Offset.zero;
        if (pending == 'like') {
          _commitLike();
        } else if (pending == 'pass') {
          _next();
        } else {
          setState(() {}); // spring-back settled
        }
      });
    _fb = AnimationController(vsync: this, duration: const Duration(milliseconds: 720))
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) _fb.reset();
      });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _fb.dispose();
    super.dispose();
  }

  List<BabyName> get _deck => _rareOnly ? kBabyNames.where((n) => n.rare).toList() : kBabyNames;

  bool get _done => _index >= _deck.length;
  BabyName? get _current => _done ? null : _deck[_index];

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
      );

  void _toRare() => setState(() {
        _rareOnly = !_rareOnly;
        _index = 0;
        _drag = Offset.zero;
      });

  void _next() => setState(() {
        _showMatch = false;
        _matched = null;
        if (_index < _deck.length) _index++;
      });

  void _undo() => setState(() {
        if (_index > 0) _index--;
      });

  // Like the swiped card; a mutual yes raises the match overlay (the index holds
  // so "Keep swiping" advances), otherwise move to the next name.
  void _commitLike() {
    final n = _current;
    if (n == null) return;
    _store.like(n.name);
    if (n.mutual) {
      setState(() {
        _matched = n;
        _showMatch = true;
      });
    } else {
      _next();
    }
  }

  // ---- gesture + fly-off ----
  void _onPanUpdate(DragUpdateDetails d) {
    if (_ctrl.isAnimating || _showMatch || _done) return;
    setState(() => _drag += d.delta);
  }

  void _onPanEnd(DragEndDetails d) {
    if (_ctrl.isAnimating || _showMatch || _done) return;
    final vx = d.velocity.pixelsPerSecond.dx;
    if (_drag.dx > _threshold || vx > 720) {
      _flyOff('like');
    } else if (_drag.dx < -_threshold || vx < -720) {
      _flyOff('pass');
    } else {
      _flyOff(null); // spring back to centre
    }
  }

  // kind: 'like' / 'pass' flings the card off that side; null drops it back.
  void _flyOff(String? kind) {
    if (_ctrl.isAnimating || _done) return;
    final w = MediaQuery.of(context).size.width;
    _animFrom = _drag;
    _animTo = kind == null ? Offset.zero : Offset((kind == 'like' ? 1.4 : -1.4) * w, _drag.dy + 40);
    _pending = kind;
    _ctrl.forward(from: 0);
    if (kind != null) {
      _fbKind = kind;
      _fb.forward(from: 0);
      kind == 'like' ? HapticFeedback.mediumImpact() : HapticFeedback.lightImpact();
    }
  }

  void _openList() => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const NameMatchesScreen()));

  // ---- like/pass feedback overlay -------------------------------------------
  // (x-fraction across the deck, heart size, phase offset) for the rising hearts.
  static const List<(double, double, double)> _burst = [
    (0.22, 22.0, 0.0),
    (0.36, 15.0, 0.12),
    (0.50, 27.0, 0.0),
    (0.62, 18.0, 0.16),
    (0.74, 20.0, 0.06),
    (0.44, 14.0, 0.22),
    (0.58, 24.0, 0.09),
  ];

  Widget _feedback() => IgnorePointer(
        child: AnimatedBuilder(
          animation: _fb,
          builder: (context, _) {
            final v = _fb.value;
            if (v == 0) return const SizedBox.shrink();
            final like = _fbKind == 'like';
            final size = MediaQuery.of(context).size;
            final pulse = math.sin(math.pi * v).clamp(0.0, 1.0);
            return Stack(children: [
              // warm (love) / cool (pass) centre pulse
              Positioned.fill(
                child: Opacity(
                  opacity: pulse * (like ? 0.28 : 0.15),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(center: const Alignment(0, -0.06), radius: 0.85, colors: [like ? ppCoral : ppMuted, Colors.transparent]),
                    ),
                  ),
                ),
              ),
              // hearts rise only on a like
              if (like)
                for (final h in _burst) _heart(v, h, size),
            ]);
          },
        ),
      );

  Widget _heart(double v, (double, double, double) h, Size size) {
    final t = ((v - h.$3) / (1 - h.$3)).clamp(0.0, 1.0);
    final op = math.sin(math.pi * t).clamp(0.0, 1.0);
    return Positioned(
      left: size.width * h.$1 - h.$2 / 2,
      top: size.height * 0.60 - t * (size.height * 0.34),
      child: Opacity(
        opacity: op,
        child: Transform.scale(scale: 0.5 + t * 0.7, child: Icon(Icons.favorite, size: h.$2, color: ppCoral)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = _deck.isEmpty ? 1 : _deck.length;
    final progress = (_index / total).clamp(0.0, 1.0);
    return Scaffold(
      backgroundColor: ppBg,
      body: Stack(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
          child: Column(children: [
            // filter bar
            Row(children: [
              GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(color: ppPanel, shape: BoxShape.circle),
                  child: const Icon(Icons.arrow_back, size: 17, color: ppInk),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: [
                    _filterChip('Boy', on: true, onTap: () {}),
                    const SizedBox(width: 7),
                    _filterChip('Starts with', on: false, onTap: () => _snack('Filter by starting letter - coming soon')),
                    const SizedBox(width: 7),
                    _filterChip('Rare only', on: _rareOnly, onTap: _toRare),
                  ]),
                ),
              ),
            ]),

            // progress + matched
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(color: const Color(0xFFECE5F2), borderRadius: BorderRadius.circular(999)),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress == 0 ? 0.02 : progress,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFFB79BDD), ppPurple]),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _openList,
                behavior: HitTestBehavior.opaque,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.favorite, size: 13, color: ppPurple),
                  const SizedBox(width: 5),
                  Text('${_store.matchedCount} matched', style: ppBody(12, color: ppPurple, w: FontWeight.w700)),
                ]),
              ),
            ]),

            // card stack
            Expanded(child: Padding(padding: const EdgeInsets.only(top: 20), child: _cardArea())),

            // actions
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _actionButton(btnKey: const ValueKey('name-pass'), size: 58, bg: Colors.white, border: ppLine, icon: Icons.close_rounded, iconColor: ppMuted, iconSize: 24, onTap: _done ? null : () => _flyOff('pass')),
              const SizedBox(width: 22),
              _actionButton(btnKey: const ValueKey('name-undo'), size: 44, bg: Colors.white, border: ppLine, icon: Icons.undo_rounded, iconColor: ppPurple, iconSize: 18, onTap: _index > 0 ? _undo : null),
              const SizedBox(width: 22),
              _actionButton(btnKey: const ValueKey('name-like'), size: 66, bg: ppPurple, border: ppPurple, icon: Icons.favorite, iconColor: Colors.white, iconSize: 28, onTap: _done ? null : () => _flyOff('like'), glow: true),
            ]),
          ]),
        ),

        // like/pass feedback (heart-burst + pulse)
        _feedback(),

        // match celebration overlay
        if (_showMatch && _matched != null) _matchOverlay(_matched!),
      ]),
    );
  }

  Widget _cardArea() {
    if (_done) return _endCard();
    final n = _current!;
    final w = MediaQuery.of(context).size.width;
    return Stack(children: [
      // decorative back cards
      Positioned(
        left: 12,
        right: 12,
        top: 22,
        bottom: 34,
        child: Transform.rotate(
          angle: -0.05,
          child: Container(decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(26))),
        ),
      ),
      Positioned(
        left: 8,
        right: 8,
        top: 12,
        bottom: 24,
        child: Container(decoration: BoxDecoration(color: const Color(0xFFEEE8F4), borderRadius: BorderRadius.circular(26))),
      ),
      // front card - draggable
      Positioned(
        left: 0,
        right: 0,
        top: 0,
        bottom: 12,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => NameDetailScreen(name: n.name))),
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          child: Transform.translate(
            offset: _drag,
            child: Transform.rotate(
              angle: _drag.dx / w * 0.3,
              child: Stack(children: [
                _nameCard(n),
                Positioned(top: 64, left: 24, child: _stamp('Loved', ppCoral, (_drag.dx / _threshold).clamp(0.0, 1.0), -0.22)),
                Positioned(top: 64, right: 24, child: _stamp('Maybe not', ppMuted, (-_drag.dx / _threshold).clamp(0.0, 1.0), 0.22)),
              ]),
            ),
          ),
        ),
      ),
    ]);
  }

  // A soft drag hint stamp that fades in with the pull (emotional, not arcade).
  Widget _stamp(String text, Color color, double opacity, double angle) => IgnorePointer(
        child: Opacity(
          opacity: opacity,
          child: Transform.rotate(
            angle: angle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color, width: 2),
              ),
              child: Text(text.toUpperCase(), style: ppBody(13, color: color, w: FontWeight.w800).copyWith(letterSpacing: 1.2)),
            ),
          ),
        ),
      );

  Widget _nameCard(BabyName n) => Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.white, ppStripeB], stops: [0.55, 1]),
          borderRadius: BorderRadius.circular(26),
          boxShadow: const [BoxShadow(color: Color(0x736A30B6), blurRadius: 44, spreadRadius: -18, offset: Offset(0, 20))],
        ),
        padding: const EdgeInsets.all(28),
        child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Flexible(child: _tag(n.feel, _feelBg, ppPurple)),
              if (n.blend != null) ...[const SizedBox(width: 8), Flexible(child: _tag(n.blend!, _blendBg, _blendFg))],
            ]),
            Expanded(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(n.name, textAlign: TextAlign.center, style: ppFraunces(52, h: 1.0)),
                const SizedBox(height: 4),
                Text(n.script, textAlign: TextAlign.center, style: ppFraunces(22, color: ppPurple, h: 1.1)),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => _snack('Pronunciation audio - coming soon'),
                  behavior: HitTestBehavior.opaque,
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                      width: 34,
                      height: 34,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(color: ppPurple, shape: BoxShape.circle),
                      child: const Icon(Icons.play_arrow_rounded, size: 18, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Text(n.pron, style: ppBody(13)),
                  ]),
                ),
                const SizedBox(height: 18),
                Text('“${n.meaningShort}”', textAlign: TextAlign.center, style: ppBody(15, h: 1.5)),
              ]),
            ),
            Text('Tap for the full story', style: ppBody(12, color: ppMuted)),
          ]),
        );

  Widget _endCard() => Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: ppHair),
        ),
        padding: const EdgeInsets.all(28),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.favorite, size: 34, color: ppPurple),
          const SizedBox(height: 14),
          Text("That's every name for now", textAlign: TextAlign.center, style: ppFraunces(24, h: 1.15)),
          const SizedBox(height: 8),
          Text('${_store.matchedCount} names are waiting in your shared list.', textAlign: TextAlign.center, style: ppBody(14)),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _openList,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              decoration: BoxDecoration(color: ppPurple, borderRadius: BorderRadius.circular(14)),
              child: Text('See our list', style: ppBody(14, color: Colors.white, w: FontWeight.w700)),
            ),
          ),
          if (_rareOnly) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _toRare,
              behavior: HitTestBehavior.opaque,
              child: Text('Clear filters', style: ppBody(13, color: ppPurple, w: FontWeight.w700)),
            ),
          ],
        ]),
      );

  Widget _tag(String t, Color bg, Color fg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
        child: Text(t, maxLines: 1, overflow: TextOverflow.ellipsis, style: ppBody(10.5, color: fg, w: FontWeight.w700)),
      );

  Widget _filterChip(String t, {required bool on, required VoidCallback onTap}) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: on ? ppPurple : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: on ? null : Border.all(color: ppLine),
          ),
          child: Text(t, style: ppBody(11, color: on ? Colors.white : ppSoft, w: on ? FontWeight.w700 : FontWeight.w600)),
        ),
      );

  Widget _actionButton({
    required double size,
    required Color bg,
    required Color border,
    required IconData icon,
    required Color iconColor,
    required double iconSize,
    required VoidCallback? onTap,
    Key? btnKey,
    bool glow = false,
  }) =>
      Opacity(
        opacity: onTap == null ? 0.4 : 1,
        child: GestureDetector(
          key: btnKey,
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
              border: Border.all(color: border),
              boxShadow: glow
                  ? const [BoxShadow(color: Color(0x996A30B6), blurRadius: 28, spreadRadius: -10, offset: Offset(0, 12))]
                  : const [BoxShadow(color: Color(0x1A2F2C30), blurRadius: 20, spreadRadius: -12, offset: Offset(0, 8))],
            ),
            child: Icon(icon, size: iconSize, color: iconColor),
          ),
        ),
      );

  Widget _matchOverlay(BabyName n) => Positioned.fill(
        child: GestureDetector(
          onTap: _next, // tap the scrim to keep swiping
          behavior: HitTestBehavior.opaque,
          child: Container(
            color: const Color(0x8C4A3A6B),
            alignment: Alignment.center,
            padding: const EdgeInsets.all(32),
            child: GestureDetector(
              onTap: () {}, // swallow taps on the card
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                decoration: BoxDecoration(
                  color: ppBg,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: const [BoxShadow(color: Color(0x802F2C30), blurRadius: 50, spreadRadius: -16, offset: Offset(0, 24))],
                ),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.favorite, size: 34, color: ppPurple),
                  const SizedBox(height: 10),
                  Text("It's a match!", textAlign: TextAlign.center, style: ppFraunces(26, h: 1.05)),
                  const SizedBox(height: 8),
                  Text.rich(TextSpan(children: [
                    TextSpan(text: 'You both love ', style: ppBody(14, h: 1.55)),
                    TextSpan(text: n.name, style: ppBody(14, color: ppPurple, w: FontWeight.w700, h: 1.55)),
                    TextSpan(text: ' - “${n.meaningShort}”', style: ppBody(14, h: 1.55)),
                  ]), textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  Row(children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _openList,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          height: 46,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(14)),
                          child: Text('See our list', style: ppBody(14, color: ppPurple, w: FontWeight.w700)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: _next,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          height: 46,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: ppPurple, borderRadius: BorderRadius.circular(14)),
                          child: Text('Keep swiping', style: ppBody(14, color: Colors.white, w: FontWeight.w700)),
                        ),
                      ),
                    ),
                  ]),
                ]),
              ),
            ),
          ),
        ),
      );
}
