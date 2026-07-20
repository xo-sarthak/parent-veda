// =============================================================================
//  NameJourneyFeedScreen - V2 taste quiz + primer + couple swipe + celebration
// -----------------------------------------------------------------------------
//  Discoverability-first (not a redesign): a 30-sec tap-only taste quiz, then a
//  one-screen PRIMER that sets the mental model ("Discover names one by one"),
//  then the couple swipe feed. The feed never assumes parents know to swipe:
//  a gentle card nudge, an always-visible instruction, and large LABELLED
//  Like/Skip buttons make tapping an equal path. Light progressive + personalized
//  feedback reassures parents that ParentVeda is adapting. A "Just show me names"
//  option opens a no-swipe browsable list. Match celebration is gentle.
// =============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'name_journey_detail_screen.dart';
import 'name_journey_shortlist_screen.dart';
import 'name_list_screen.dart';
import 'pp_common.dart';
import 'pp_names_data.dart';
import 'pp_names_v2_data.dart';

const Color _feelBg = Color(0xFFEDE6F5);

enum _Phase { quiz, primer, swipe }

class NameJourneyFeedScreen extends StatefulWidget {
  const NameJourneyFeedScreen({super.key, this.collection});
  final NameCollection? collection;

  @override
  State<NameJourneyFeedScreen> createState() => _NameJourneyFeedScreenState();
}

class _NameJourneyFeedScreenState extends State<NameJourneyFeedScreen> with TickerProviderStateMixin {
  final NameMatchStore _store = NameMatchStore.instance;

  _Phase _phase = _Phase.quiz;
  int _who = 2; // default 'Both'
  final Set<String> _vibes = {}; // multi-select feelings (empty = no preference)
  String _community = 'Any'; // religion / tradition
  String _region = 'Any';

  static const List<(IconData, String)> _genders = [
    (Icons.male_rounded, 'Boy'),
    (Icons.female_rounded, 'Girl'),
    (Icons.all_inclusive_rounded, 'Both'),
  ];

  // swipe state
  int _index = 0;
  int _interactions = 0; // likes + passes, for progressive feedback
  bool _showMatch = false;
  BabyName? _matched;

  late final AnimationController _fb;
  String? _fbKind;
  late final AnimationController _ctrl;
  late final AnimationController _hint; // one gentle nudge to signal draggability
  late final AnimationController _hand; // bounded swipe hand demo (yeah / nahh)
  int _handLoops = 0;
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
    _hint = AnimationController(vsync: this, duration: const Duration(milliseconds: 950))
      ..addListener(() {
        if (mounted) setState(() {});
      });
    // A few gentle loops, then it settles (so it never blocks pumpAndSettle).
    _hand = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) {
          _hand.reverse();
        } else if (s == AnimationStatus.dismissed) {
          _handLoops++;
          if (_handLoops < 3) _hand.forward();
        }
      })
      ..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _fb.dispose();
    _hint.dispose();
    _hand.dispose();
    super.dispose();
  }

  List<BabyName> get _deck {
    // A passed collection (legacy) wins; otherwise the deck honours the quiz.
    if (widget.collection != null) {
      final c = widget.collection!.names;
      return c.isEmpty ? kBabyNames : c;
    }
    final d = namesForSelection(
      gender: kNameGenders[_who],
      community: _community,
      region: _region,
      vibes: _vibes,
    );
    return d.isEmpty ? kBabyNames : d;
  }

  bool get _done => _index >= _deck.length;
  BabyName? get _current => _done ? null : _deck[_index];

  void _startSwiping() {
    setState(() => _phase = _Phase.swipe);
    _hint.forward(from: 0); // one gentle nudge so the first card looks movable
  }

  void _next() => setState(() {
        _showMatch = false;
        _matched = null;
        if (_index < _deck.length) _index++;
      });

  void _undo() => setState(() {
        if (_index > 0) {
          _index--;
          if (_interactions > 0) _interactions--;
        }
      });

  void _commitLike() {
    final n = _current;
    if (n == null) return;
    _store.like(n.name);
    _interactions++;
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
      if (kind == 'pass') _interactions++; // like counts in _commitLike
      _fbKind = kind;
      _fb.forward(from: 0);
      kind == 'like' ? HapticFeedback.mediumImpact() : HapticFeedback.lightImpact();
    }
  }

  void _openList() => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const NameJourneyShortlistScreen()));
  void _openBrowse() => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const NameListScreen()));
  void _openDetail(BabyName n) => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => NameJourneyDetailScreen(name: n.name)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: switch (_phase) {
          _Phase.quiz => _quizView(),
          _Phase.primer => _primerView(),
          _Phase.swipe => _swipeView(),
        },
      ),
    );
  }

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

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
          _pad(Text('A couple of taps, and we\'ll tune your names', style: ppFraunces(26, h: 1.15))),
          const SizedBox(height: 8),
          _pad(Text('This only gently weights what you see first. It never hides names from you.', style: ppBody(13.5, h: 1.55))),

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
          _pad(Row(children: [
            Expanded(child: Text('The feeling you want', style: ppJakarta(17))),
            Text('pick any', style: ppBody(12, color: ppMuted)),
          ])),
          const SizedBox(height: 12),
          _pad(Wrap(spacing: 10, runSpacing: 10, children: [
            _noPrefChip(),
            for (final v in kNameVibes) _vibeChip(v.label),
          ])),

          const SizedBox(height: 28),
          _pad(Text('Region or tradition', style: ppJakarta(17))),
          const SizedBox(height: 6),
          _pad(Text('Optional - localise names by community and region.', style: ppBody(12.5, color: ppMuted))),
          const SizedBox(height: 12),
          _pad(Wrap(spacing: 8, runSpacing: 8, children: [
            for (final c in kNameCommunities) _pillChip(c, c == _community, () => setState(() => _community = c)),
          ])),
          const SizedBox(height: 10),
          _pad(Wrap(spacing: 8, runSpacing: 8, children: [
            for (final r in kNameRegions) _pillChip(r, r == _region, () => setState(() => _region = r)),
          ])),

          const SizedBox(height: 30),
          _pad(GestureDetector(
            onTap: () => setState(() => _phase = _Phase.primer),
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
                Text('Start discovering', style: ppBody(15, color: Colors.white, w: FontWeight.w700)),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, size: 16, color: Colors.white),
              ]),
            ),
          )),
          const SizedBox(height: 12),
          _pad(Center(child: GestureDetector(
            onTap: _openBrowse,
            behavior: HitTestBehavior.opaque,
            child: Text('Just show me names', style: ppBody(13, color: ppPurple, w: FontWeight.w700)),
          ))),
        ],
      );

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

  Widget _vibeChip(String label) {
    final on = _vibes.contains(label);
    return GestureDetector(
      onTap: () => setState(() => on ? _vibes.remove(label) : _vibes.add(label)),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
        decoration: BoxDecoration(
          color: on ? ppPurple : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: on ? null : Border.all(color: ppLine),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (on) ...[const Icon(Icons.check_rounded, size: 14, color: Colors.white), const SizedBox(width: 6)],
          Text(label, style: ppBody(13, color: on ? Colors.white : ppInk, w: on ? FontWeight.w700 : FontWeight.w600)),
        ]),
      ),
    );
  }

  Widget _noPrefChip() {
    final on = _vibes.isEmpty;
    return GestureDetector(
      onTap: () => setState(_vibes.clear),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
        decoration: BoxDecoration(
          color: on ? ppInk : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: on ? null : Border.all(color: ppLine),
        ),
        child: Text('No preference', style: ppBody(13, color: on ? Colors.white : ppSoft, w: FontWeight.w700)),
      ),
    );
  }

  Widget _pillChip(String label, bool on, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
          decoration: BoxDecoration(
            color: on ? ppStripeB : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: on ? ppPurple : ppLine, width: on ? 1.5 : 1),
          ),
          child: Text(label, style: ppBody(12.5, color: on ? ppPurple : ppSoft, w: on ? FontWeight.w700 : FontWeight.w600)),
        ),
      );

  // ---- primer (sets the mental model - one screen, not a tutorial) --------
  Widget _primerView() => ListView(
        padding: const EdgeInsets.only(top: 12, bottom: 40),
        children: [
          _pad(GestureDetector(
            onTap: () => setState(() => _phase = _Phase.quiz),
            behavior: HitTestBehavior.opaque,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.arrow_back, size: 20, color: ppSoft),
              const SizedBox(width: 12),
              Text('Back', style: ppBody(14, color: ppSoft)),
            ]),
          )),
          const SizedBox(height: 30),
          Center(
            child: Container(
              width: 132,
              height: 132,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFF1EAF8), Color(0xFFE6D8F1)]),
                shape: BoxShape.circle,
              ),
              child: Stack(alignment: Alignment.center, clipBehavior: Clip.none, children: [
                Transform.rotate(angle: -0.12, child: Container(width: 58, height: 76, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Color(0x226A30B6), blurRadius: 12, offset: Offset(0, 6))]))),
                Transform.rotate(angle: 0.10, child: Container(width: 58, height: 76, alignment: Alignment.center, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: ppBorder), boxShadow: const [BoxShadow(color: Color(0x226A30B6), blurRadius: 14, offset: Offset(0, 8))]), child: const Icon(Icons.favorite, size: 22, color: ppCoral))),
              ]),
            ),
          ),
          const SizedBox(height: 28),
          _pad(Text('Discover names one by one', textAlign: TextAlign.center, style: ppFraunces(28, h: 1.15))),
          const SizedBox(height: 12),
          _pad(Text('We\'ll show you one beautiful name at a time. Tell us how you feel about each - by tapping a button or swiping the card.', textAlign: TextAlign.center, style: ppBody(14.5, h: 1.6))),

          const SizedBox(height: 24),
          _pad(Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _sampleAction(Icons.favorite, ppPurple, Colors.white, 'Love it'),
            const SizedBox(width: 16),
            _sampleAction(Icons.close_rounded, Colors.white, ppMuted, 'Skip', outlined: true),
          ])),
          const SizedBox(height: 20),
          _pad(Text('We\'ll learn what you love and gradually tailor every suggestion.', textAlign: TextAlign.center, style: ppBody(13, color: ppSoft, h: 1.5))),

          const SizedBox(height: 30),
          _pad(GestureDetector(
            onTap: _startSwiping,
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: 54,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: ppPurple, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x8C6A30B6), blurRadius: 28, spreadRadius: -10, offset: Offset(0, 12))]),
              child: Text('Let\'s begin', style: ppBody(15, color: Colors.white, w: FontWeight.w700)),
            ),
          )),
        ],
      );

  Widget _sampleAction(IconData icon, Color bg, Color fg, String label, {bool outlined = false}) => Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 60,
          height: 60,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle, border: outlined ? Border.all(color: ppLine) : null, boxShadow: const [BoxShadow(color: Color(0x1A2F2C30), blurRadius: 16, spreadRadius: -10, offset: Offset(0, 6))]),
          child: Icon(icon, size: 26, color: fg),
        ),
        const SizedBox(height: 8),
        Text(label, style: ppBody(12.5, color: ppInk, w: FontWeight.w700)),
      ]);

  // ---- swipe feed ---------------------------------------------------------
  String? get _feedback {
    if (_interactions == 0) {
      return 'Let\'s begin with a few thoughtfully chosen names. We\'ll personalise as we learn what you like.';
    }
    if (_interactions < 3) return null;
    final feel = _dominantLikedFeel();
    if (_interactions >= 5 && feel != null) return 'Showing more $feel names.';
    return 'We\'re learning the names you like. Suggestions will get more personal.';
  }

  String? _dominantLikedFeel() {
    final liked = _store.liked.map(babyNameByName).toList();
    if (liked.isEmpty) return null;
    final counts = <String, int>{};
    for (final n in liked) {
      final f = n.feel.toLowerCase();
      final key = f.contains('rooted') || f.contains('devotional')
          ? 'rooted, traditional'
          : f.contains('modern')
              ? 'modern, fresh'
              : f.contains('rare')
                  ? 'rare Sanskrit'
                  : null;
      if (key != null) counts[key] = (counts[key] ?? 0) + 1;
    }
    if (counts.isEmpty) return null;
    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  Offset get _hintOffset {
    if (_hint.value == 0) return Offset.zero;
    final v = _hint.value;
    return Offset(math.sin(v * math.pi * 2) * (1 - v) * 16, 0);
  }

  Widget _swipeView() {
    final total = _deck.isEmpty ? 1 : _deck.length;
    final progress = (_index / total).clamp(0.0, 1.0);
    final feedback = _feedback;
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
            Expanded(child: Text(widget.collection?.title ?? 'For you', style: ppJakarta(15), maxLines: 1, overflow: TextOverflow.ellipsis)),
            GestureDetector(
              onTap: _openList,
              behavior: HitTestBehavior.opaque,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.favorite, size: 13, color: ppPurple),
                const SizedBox(width: 5),
                Text('${_store.likedCount}', style: ppBody(12, color: ppPurple, w: FontWeight.w700)),
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
          // gentle, reassuring feedback (empty state / progressive / personalised)
          if (feedback != null) ...[
            const SizedBox(height: 12),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Container(
                key: ValueKey(feedback),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  const Icon(Icons.auto_awesome, size: 14, color: ppPurple),
                  const SizedBox(width: 8),
                  Expanded(child: Text(feedback, style: ppBody(12, color: ppInk, h: 1.4))),
                ]),
              ),
            ),
          ],
          Expanded(child: Padding(padding: const EdgeInsets.only(top: 16), child: _cardArea())),
          if (!_done) ...[
            const SizedBox(height: 4),
            Text('Swipe the card, or use the buttons below', style: ppBody(11.5, color: ppMuted)),
          ],
          const SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
            _labelled('Not for us', _actionButton(size: 58, bg: Colors.white, border: ppLine, icon: Icons.close_rounded, iconColor: ppMuted, iconSize: 24, onTap: _done ? null : () => _flyOff('pass'), semantic: 'Not for us')),
            const SizedBox(width: 20),
            _labelled('Undo', _actionButton(size: 44, bg: Colors.white, border: ppLine, icon: Icons.undo_rounded, iconColor: ppPurple, iconSize: 18, onTap: _index > 0 ? _undo : null, semantic: 'Undo the last name')),
            const SizedBox(width: 20),
            _labelled('We like this', _actionButton(size: 66, bg: ppPurple, border: ppPurple, icon: Icons.favorite, iconColor: Colors.white, iconSize: 28, onTap: _done ? null : () => _flyOff('like'), glow: true, semantic: 'We like this')),
          ]),
        ]),
      ),
      if (_interactions == 0 && !_done && !_showMatch)
        Positioned.fill(child: IgnorePointer(child: _swipeHandHint())),
      _feedbackOverlay(),
      if (_showMatch && _matched != null) _matchOverlay(_matched!),
    ]);
  }

  // An animated hand that slides right (yeah) then left (nahh), shown on the
  // very first card so the swipe gesture is obvious. Fades out once the parent
  // interacts with any name.
  Widget _swipeHandHint() => AnimatedBuilder(
        animation: _hand,
        builder: (context, _) {
          final s = math.sin(_hand.value * 2 * math.pi);
          final dx = s * 48;
          return Align(
            alignment: const Alignment(0, 0.28),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(color: ppInk.withValues(alpha: 0.82), borderRadius: BorderRadius.circular(20)),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Row(mainAxisSize: MainAxisSize.min, children: [
                  _hintSide('Nahh', Icons.west_rounded, const Color(0xFFFFB0C0), s < -0.15),
                  const SizedBox(width: 12),
                  Transform.translate(
                    offset: Offset(dx, 0),
                    child: Container(
                      width: 46,
                      height: 46,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Color(0x40000000), blurRadius: 12, offset: Offset(0, 4))]),
                      child: const Icon(Icons.back_hand_rounded, size: 24, color: ppPurple),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _hintSide('Yeah', Icons.east_rounded, const Color(0xFF9FE4BC), s > 0.15),
                ]),
                const SizedBox(height: 10),
                Text('Swipe right to love, left to skip', style: ppBody(12, color: Colors.white, w: FontWeight.w600)),
              ]),
            ),
          );
        },
      );

  Widget _hintSide(String label, IconData icon, Color color, bool active) => AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: active ? 1 : 0.4,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 2),
          Text(label, style: ppBody(11, color: color, w: FontWeight.w800)),
        ]),
      );

  Widget _labelled(String label, Widget button) => Column(mainAxisSize: MainAxisSize.min, children: [
        button,
        const SizedBox(height: 7),
        Text(label, style: ppBody(11, color: ppSoft, w: FontWeight.w600)),
      ]);

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
            offset: _drag + _hintOffset,
            child: Transform.rotate(
              angle: (_drag.dx + _hintOffset.dx) / w * 0.3,
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
              Text('"${n.meaningShort}"', textAlign: TextAlign.center, style: ppBody(15, h: 1.5)),
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
          Text('${_store.likedCount} names are waiting in the ones you love. Skipped names are never gone; find them anytime in Browse.', textAlign: TextAlign.center, style: ppBody(14, h: 1.5)),
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
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _openBrowse,
            behavior: HitTestBehavior.opaque,
            child: Text('Browse all names', style: ppBody(13, color: ppPurple, w: FontWeight.w700)),
          ),
        ]),
      );

  Widget _tag(String t, Color bg, Color fg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
        child: Text(t, maxLines: 1, overflow: TextOverflow.ellipsis, style: ppBody(10.5, color: fg, w: FontWeight.w700)),
      );

  Widget _actionButton({required double size, required Color bg, required Color border, required IconData icon, required Color iconColor, required double iconSize, required VoidCallback? onTap, bool glow = false, String? semantic}) => Opacity(
        opacity: onTap == null ? 0.4 : 1,
        child: Semantics(
          button: true,
          label: semantic,
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

  Widget _feedbackOverlay() => IgnorePointer(
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
                  Text('You loved', style: ppBody(13, color: ppSoft, w: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(n.name, textAlign: TextAlign.center, style: ppFraunces(34, h: 1.02)),
                  const SizedBox(height: 8),
                  Text('"${n.meaningShort}"', textAlign: TextAlign.center, style: ppBody(14, h: 1.55)),
                  const SizedBox(height: 22),
                  Row(children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _openDetail(n),
                        behavior: HitTestBehavior.opaque,
                        child: Container(height: 46, alignment: Alignment.center, decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(14)), child: Text('Read its story', style: ppBody(14, color: ppPurple, w: FontWeight.w700))),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: _next,
                        behavior: HitTestBehavior.opaque,
                        child: Container(height: 46, alignment: Alignment.center, decoration: BoxDecoration(color: ppPurple, borderRadius: BorderRadius.circular(14)), child: Text('Keep going', style: ppBody(14, color: Colors.white, w: FontWeight.w700))),
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
