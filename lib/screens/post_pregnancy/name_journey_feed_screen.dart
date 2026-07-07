// =============================================================================
//  NameJourneyFeedScreen — V2 taste quiz + couple swipe + match celebration
// -----------------------------------------------------------------------------
//  The heart of the Baby Naming Journey. A 30-second tap-only taste quiz (weights
//  gently, never blocks) leads into the couple swipe feed: beautiful name cards,
//  Love/Pass with real drag physics (reused from the V1 deck), tap for the Deep
//  Dive. Only shared matches surface; a match raises a gentle celebration
//  ("You both loved Aarav" + meaning) — no confetti, no badges, no gamification.
// =============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'name_journey_detail_screen.dart';
import 'name_journey_shortlist_screen.dart';
import 'pp_common.dart';
import 'pp_names_data.dart';
import 'pp_names_v2_data.dart';

const Color _feelBg = Color(0xFFEDE6F5);

class NameJourneyFeedScreen extends StatefulWidget {
  const NameJourneyFeedScreen({super.key, this.collection});
  final NameCollection? collection;

  @override
  State<NameJourneyFeedScreen> createState() => _NameJourneyFeedScreenState();
}

class _NameJourneyFeedScreenState extends State<NameJourneyFeedScreen> with TickerProviderStateMixin {
  final NameMatchStore _store = NameMatchStore.instance;

  // phase: the quick taste quiz, then the swipe feed.
  bool _quizDone = false;
  int _who = 0;
  int _feel = 0;

  static const List<(IconData, String)> _genders = [
    (Icons.male_rounded, 'Boy'),
    (Icons.female_rounded, 'Girl'),
    (Icons.auto_awesome_outlined, 'Surprise'),
  ];
  static const List<String> _feels = ['Rooted & traditional', 'Modern & fresh', 'Rare & unique', 'Devotional'];

  // swipe state
  int _index = 0;
  bool _showMatch = false;
  BabyName? _matched;

  late final AnimationController _fb;
  String? _fbKind;
  late final AnimationController _ctrl;
  Offset _drag = Offset.zero;
  Offset _animFrom = Offset.zero;
  Offset _animTo = Offset.zero;
  String? _pending;
  static const double _threshold = 96;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 260))
      ..addListener(() => setState(() => _drag = Offset.lerp(_animFrom, _animTo, Curves.easeOut.transform(_ctrl.value))!))
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
          setState(() {});
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

  List<BabyName> get _deck {
    final base = widget.collection?.names ?? kBabyNames;
    return base.isEmpty ? kBabyNames : base;
  }

  bool get _done => _index >= _deck.length;
  BabyName? get _current => _done ? null : _deck[_index];

  void _next() => setState(() {
        _showMatch = false;
        _matched = null;
        if (_index < _deck.length) _index++;
      });

  void _undo() => setState(() {
        if (_index > 0) _index--;
      });

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
      _flyOff(null);
    }
  }

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

  void _openList() => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const NameJourneyShortlistScreen()));
  void _openDetail(BabyName n) => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => NameJourneyDetailScreen(name: n.name)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: _quizDone ? _swipeView() : _quizView(),
      ),
    );
  }

  // ---- taste quiz ---------------------------------------------------------
  Widget _quizView() => ListView(
        padding: const EdgeInsets.only(top: 12, bottom: 40),
        children: [
          _pad(ppBack(context, 'Baby Names')),
          const SizedBox(height: 14),
          nameJourneyRibbon(active: 0),
          const SizedBox(height: 22),
          _pad(ppEyebrow('Taste quiz · about 30 seconds', color: ppPurple)),
          const SizedBox(height: 10),
          _pad(Text('A couple of taps, and we\'ll tune your feed', style: ppFraunces(26, h: 1.15))),
          const SizedBox(height: 8),
          _pad(Text('This only gently weights what you see first — it never hides names from you.', style: ppBody(13.5, h: 1.55))),

          const SizedBox(height: 26),
          _pad(Text('Who are we naming?', style: ppJakarta(17))),
          const SizedBox(height: 14),
          _pad(Row(children: [
            for (var i = 0; i < _genders.length; i++) ...[
              if (i > 0) const SizedBox(width: 10),
              Expanded(child: _whoCard(i)),
            ],
          ])),

          const SizedBox(height: 28),
          _pad(Text('The feeling you want', style: ppJakarta(17))),
          const SizedBox(height: 14),
          _pad(Wrap(spacing: 10, runSpacing: 10, children: [for (var i = 0; i < _feels.length; i++) _feelChip(i)])),

          const SizedBox(height: 30),
          _pad(GestureDetector(
            onTap: () => setState(() => _quizDone = true),
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: 54,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: ppPurple,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Color(0x8C6A30B6), blurRadius: 28, spreadRadius: -10, offset: Offset(0, 12))],
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text('Start swiping', style: ppBody(15, color: Colors.white, w: FontWeight.w700)),
                const SizedBox(width: 8),
                const Text('→', style: TextStyle(color: Colors.white, fontSize: 16)),
              ]),
            ),
          )),
          const SizedBox(height: 10),
          _pad(Center(child: GestureDetector(
            onTap: () => setState(() => _quizDone = true),
            behavior: HitTestBehavior.opaque,
            child: Text('Skip — just show me names', style: ppBody(13, color: ppMuted, w: FontWeight.w600)),
          ))),
        ],
      );

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  Widget _whoCard(int i) {
    final on = i == _who;
    return GestureDetector(
      onTap: () => setState(() => _who = i),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 6),
        decoration: BoxDecoration(
          color: on ? ppStripeB : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: on ? ppPurple : ppLine, width: on ? 2 : 1),
        ),
        child: Column(children: [
          Icon(_genders[i].$1, size: 24, color: on ? ppPurple : ppSoft),
          const SizedBox(height: 8),
          Text(_genders[i].$2, style: ppJakarta(13)),
        ]),
      ),
    );
  }

  Widget _feelChip(int i) {
    final on = i == _feel;
    return GestureDetector(
      onTap: () => setState(() => _feel = i),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: on ? ppPurple : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: on ? null : Border.all(color: ppLine),
        ),
        child: Text(_feels[i], style: ppBody(13, color: on ? Colors.white : ppInk, w: on ? FontWeight.w700 : FontWeight.w600)),
      ),
    );
  }

  // ---- swipe feed ---------------------------------------------------------
  Widget _swipeView() {
    final total = _deck.isEmpty ? 1 : _deck.length;
    final progress = (_index / total).clamp(0.0, 1.0);
    return Stack(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(children: [
          Row(children: [
            GestureDetector(
              onTap: () => Navigator.of(context).maybePop(),
              behavior: HitTestBehavior.opaque,
              child: Container(width: 34, height: 34, alignment: Alignment.center, decoration: const BoxDecoration(color: ppPanel, shape: BoxShape.circle), child: const Icon(Icons.arrow_back, size: 17, color: ppInk)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(widget.collection?.title ?? 'For you both', style: ppJakarta(15), maxLines: 1, overflow: TextOverflow.ellipsis)),
            GestureDetector(
              onTap: _openList,
              behavior: HitTestBehavior.opaque,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.favorite, size: 13, color: ppPurple),
                const SizedBox(width: 5),
                Text('${_store.matchedCount}', style: ppBody(12, color: ppPurple, w: FontWeight.w700)),
              ]),
            ),
          ]),
          const SizedBox(height: 14),
          Container(
            height: 4,
            decoration: BoxDecoration(color: const Color(0xFFECE5F2), borderRadius: BorderRadius.circular(999)),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress == 0 ? 0.02 : progress,
              child: Container(decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFB79BDD), ppPurple]), borderRadius: BorderRadius.circular(999))),
            ),
          ),
          Expanded(child: Padding(padding: const EdgeInsets.only(top: 20), child: _cardArea())),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _actionButton(size: 58, bg: Colors.white, border: ppLine, icon: Icons.close_rounded, iconColor: ppMuted, iconSize: 24, onTap: _done ? null : () => _flyOff('pass')),
            const SizedBox(width: 22),
            _actionButton(size: 44, bg: Colors.white, border: ppLine, icon: Icons.undo_rounded, iconColor: ppPurple, iconSize: 18, onTap: _index > 0 ? _undo : null),
            const SizedBox(width: 22),
            _actionButton(size: 66, bg: ppPurple, border: ppPurple, icon: Icons.favorite, iconColor: Colors.white, iconSize: 28, onTap: _done ? null : () => _flyOff('like'), glow: true),
          ]),
        ]),
      ),
      _feedback(),
      if (_showMatch && _matched != null) _matchOverlay(_matched!),
    ]);
  }

  Widget _cardArea() {
    if (_done) return _endCard();
    final n = _current!;
    final w = MediaQuery.of(context).size.width;
    return Stack(children: [
      Positioned(left: 12, right: 12, top: 22, bottom: 34, child: Transform.rotate(angle: -0.05, child: Container(decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(26))))),
      Positioned(left: 8, right: 8, top: 12, bottom: 24, child: Container(decoration: BoxDecoration(color: const Color(0xFFEEE8F4), borderRadius: BorderRadius.circular(26)))),
      Positioned(
        left: 0,
        right: 0,
        top: 0,
        bottom: 12,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _openDetail(n),
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

  Widget _stamp(String text, Color color, double opacity, double angle) => IgnorePointer(
        child: Opacity(
          opacity: opacity,
          child: Transform.rotate(
            angle: angle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(10), border: Border.all(color: color, width: 2)),
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
          Align(alignment: Alignment.centerLeft, child: _tag(n.feel, _feelBg, ppPurple)),
          Expanded(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(n.name, textAlign: TextAlign.center, style: ppFraunces(52, h: 1.0)),
              const SizedBox(height: 4),
              Text(n.script, textAlign: TextAlign.center, style: ppFraunces(22, color: ppPurple, h: 1.1)),
              const SizedBox(height: 16),
              Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(width: 30, height: 30, alignment: Alignment.center, decoration: const BoxDecoration(color: ppPurple, shape: BoxShape.circle), child: const Icon(Icons.volume_up_rounded, size: 15, color: Colors.white)),
                const SizedBox(width: 8),
                Text(n.pron, style: ppBody(13)),
              ]),
              const SizedBox(height: 18),
              Text('“${n.meaningShort}”', textAlign: TextAlign.center, style: ppBody(15, h: 1.5)),
            ]),
          ),
          Text('Tap for the full story', style: ppBody(12, color: ppMuted)),
        ]),
      );

  Widget _endCard() => Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(26), border: Border.all(color: ppHair)),
        padding: const EdgeInsets.all(28),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.favorite, size: 34, color: ppPurple),
          const SizedBox(height: 14),
          Text("That's every name for now", textAlign: TextAlign.center, style: ppFraunces(24, h: 1.15)),
          const SizedBox(height: 8),
          Text('${_store.matchedCount} names are waiting in the ones you both love.', textAlign: TextAlign.center, style: ppBody(14)),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _openList,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              decoration: BoxDecoration(color: ppPurple, borderRadius: BorderRadius.circular(14)),
              child: Text('See our shortlist', style: ppBody(14, color: Colors.white, w: FontWeight.w700)),
            ),
          ),
        ]),
      );

  Widget _tag(String t, Color bg, Color fg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
        child: Text(t, maxLines: 1, overflow: TextOverflow.ellipsis, style: ppBody(10.5, color: fg, w: FontWeight.w700)),
      );

  Widget _actionButton({required double size, required Color bg, required Color border, required IconData icon, required Color iconColor, required double iconSize, required VoidCallback? onTap, bool glow = false}) => Opacity(
        opacity: onTap == null ? 0.4 : 1,
        child: GestureDetector(
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

  // ---- feedback + celebration --------------------------------------------
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
              Positioned.fill(
                child: Opacity(
                  opacity: pulse * (like ? 0.28 : 0.15),
                  child: DecoratedBox(decoration: BoxDecoration(gradient: RadialGradient(center: const Alignment(0, -0.06), radius: 0.85, colors: [like ? ppCoral : ppMuted, Colors.transparent]))),
                ),
              ),
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
      child: Opacity(opacity: op, child: Transform.scale(scale: 0.5 + t * 0.7, child: Icon(Icons.favorite, size: h.$2, color: ppCoral))),
    );
  }

  Widget _matchOverlay(BabyName n) => Positioned.fill(
        child: GestureDetector(
          onTap: _next,
          behavior: HitTestBehavior.opaque,
          child: Container(
            color: const Color(0x8C4A3A6B),
            alignment: Alignment.center,
            padding: const EdgeInsets.all(32),
            child: GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                decoration: BoxDecoration(color: ppBg, borderRadius: BorderRadius.circular(26), boxShadow: const [BoxShadow(color: Color(0x802F2C30), blurRadius: 50, spreadRadius: -16, offset: Offset(0, 24))]),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.favorite, size: 34, color: ppCoral),
                  const SizedBox(height: 12),
                  Text('You both loved', style: ppBody(13, color: ppSoft, w: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(n.name, textAlign: TextAlign.center, style: ppFraunces(34, h: 1.02)),
                  const SizedBox(height: 8),
                  Text('“${n.meaningShort}”', textAlign: TextAlign.center, style: ppBody(14, h: 1.55)),
                  const SizedBox(height: 22),
                  Row(children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _openDetail(n), // overlay stays behind the pushed detail
                        behavior: HitTestBehavior.opaque,
                        child: Container(height: 46, alignment: Alignment.center, decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(14)), child: Text('Read its story', style: ppBody(14, color: ppPurple, w: FontWeight.w700))),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: _next,
                        behavior: HitTestBehavior.opaque,
                        child: Container(height: 46, alignment: Alignment.center, decoration: BoxDecoration(color: ppPurple, borderRadius: BorderRadius.circular(14)), child: Text('Keep swiping', style: ppBody(14, color: Colors.white, w: FontWeight.w700))),
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
