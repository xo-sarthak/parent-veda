// =============================================================================
//  PvLiveSearch — the search bar's flow, once, for every door
// -----------------------------------------------------------------------------
//  Built 2026-09-20 on Is it safe?, then lifted out at the user's ask: "create
//  this flow as a template so it can be reused for every door wherever the
//  search bar is." The flow is what the lookup apps in the Mobbin library
//  converge on (Yazio, Keeta, Swiggy, Kitchen Stories, Ultrahuman; Woolworths
//  and Instacart for the idle page):
//
//    idle       the field sits in the hero under the blurb; the page is the
//               page — Asked most / the rail / the sections. No history here:
//               history on an idle screen reads as "my past, static, at the
//               top" (the user, on the phone).
//    focused    the field rides to the top of the screen (so the keyboard
//    + empty    sits under her recents, not over them), the hero's words fade,
//               and the sheet shows RECENT (+ Saved where the door has it) as
//               rows she can tap instead of typing. A typing shortcut, not a
//               section.
//    typing     rows replace the recents as she types; the last row is always
//               a way on — "Ask Veda about …" / "Search everywhere".
//    Back       twice: the first closes the keyboard and leaves the rows
//               readable (Android does that by itself; the user's call:
//               "some people would want to see what's happening below"), the
//               second returns to the idle page — it releases the field
//               rather than leaving the door.
//
//  ⚠️ FOCUS IS A STATE OF THE PAGE, NOT OF THE FIELD. Three things change on
//  it — what the sheet shows, where the field sits, what the hero says — and
//  they are one decision. That is why the controller, the field, the fading
//  words and the Back scope are one file: a door takes all four or none.
//
//  What a door supplies: the field's hint, its own `find(query)`, its own row
//  widget, its recents (and saved, if it has them), and what "a way on" means
//  for it. What this file owns: the states, the scroll, the fade, Back.
//
//  Consumers: `can_i_door.dart` (Is it safe?), `pv_door_screen.dart` (every
//  door built on the shell).
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../../widgets/pv_feedback.dart';
import '../v2/v2_palette.dart';
import 'pv_door_chrome.dart';

/// The three states, in one place.
class PvLiveSearch extends ChangeNotifier {
  PvLiveSearch() {
    ctl.addListener(notifyListeners);
    focus.addListener(_onFocus);
  }

  final TextEditingController ctl = TextEditingController();
  final FocusNode focus = FocusNode();

  /// Put on the field's row so the page can scroll it to the top on focus.
  /// With a [PvDoorPinnedBar] in the door it is also what lets the one field
  /// move from the hero into the bar and back without losing its focus, its
  /// text or the keyboard: a GlobalKey moved within a frame keeps its state.
  final GlobalKey fieldKey = GlobalKey();

  /// Set by a [PvDoorPinnedBar] while it is in the door. While the field is
  /// active it then rides in that bar, pinned under the status bar on a
  /// solid band, instead of being scrolled to 4% of the screen.
  bool pinsInBar = false;

  /// The field as the door last built it: its hint, submit and palette, so
  /// the pinned bar draws the same field. Written by [PvLiveSearchField].
  PvLiveSearchField? _field;

  /// The field pins in a bar right now (a bar, and a field built by
  /// [PvLiveSearchField], not a door's own copy of it).
  bool get _pins => pinsInBar && _field != null;

  String get query => ctl.text.trim();

  /// She has typed something: rows replace the page.
  bool get searching => query.isNotEmpty;

  /// The field has focus and is still empty: her recents replace the page.
  bool get recalling => !searching && focus.hasFocus;

  /// Idle: neither.
  bool get idle => !searching && !focus.hasFocus;

  void _onFocus() {
    notifyListeners();
    if (!focus.hasFocus) return;
    // A door with a pinned bar: the bar moves the field and the list itself.
    if (_pins) return;
    // After the frame, so the recall rows exist to scroll over. 4% from
    // the top clears the status bar on every phone tried.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = fieldKey.currentContext;
      if (ctx == null) return;
      Scrollable.ensureVisible(ctx,
          alignment: 0.04, duration: const Duration(milliseconds: 280), curve: Curves.easeOutCubic);
    });
  }

  /// Put a query in the field as if she had typed it (a recent, tapped).
  void run(String q) {
    ctl.text = q;
    ctl.selection = TextSelection.collapsed(offset: q.length);
    focus.requestFocus();
  }

  /// Back to idle: the words gone, the field released.
  void release() {
    if (ctl.text.isNotEmpty) ctl.clear();
    focus.unfocus();
  }

  @override
  void dispose() {
    ctl.removeListener(notifyListeners);
    focus.removeListener(_onFocus);
    ctl.dispose();
    focus.dispose();
    super.dispose();
  }
}

/// How tall the sheet must be while the field is active. A short result
/// list ("Nothing by that name" and two rows) gives the list nothing to
/// scroll over, so the field cannot ride to the top and sits mid-screen
/// under the keyboard (the phone, 2026-09-20). Idle, the sheet keeps its
/// own floor; active, it is at least the screen and the keyboard's room.
double pvLiveSearchSheetMin(BuildContext context, PvLiveSearch search) {
  if (search.idle) return 0;
  final mq = MediaQuery.of(context);
  return mq.size.height + mq.viewInsets.bottom;
}

/// Back, twice. Wrap the door's Scaffold in this.
class PvLiveSearchScope extends StatelessWidget {
  const PvLiveSearchScope({super.key, required this.search, required this.child});
  final PvLiveSearch search;
  final Widget child;

  // Listens itself, so the scope is right even inside a consumer that does
  // not rebuild on the search's changes.
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: search,
        builder: (context, _) => PopScope(
          canPop: search.idle,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) search.release();
          },
          child: child,
        ),
      );
}

/// The hero's words, gone while the field has focus. The page scrolls the
/// field to the top then, and a blurb half under the status bar read as a
/// smudge over the clock on the phone.
class PvLiveSearchWords extends StatelessWidget {
  const PvLiveSearchWords({super.key, required this.search, required this.child});
  final PvLiveSearch search;
  final Widget child;

  @override
  Widget build(BuildContext context) => AnimatedOpacity(
        opacity: search.focus.hasFocus ? 0 : 1,
        duration: const Duration(milliseconds: 200),
        child: child,
      );
}

/// The field: PvSearchBar's geometry (48 high, white, hairline, stadium),
/// live. Sits where the door's search bar sits.
class PvLiveSearchField extends StatelessWidget {
  const PvLiveSearchField({
    super.key,
    required this.search,
    required this.p,
    required this.hint,
    this.onSubmitted,
    this.trailing,
  });
  final PvLiveSearch search;
  final V2Palette p;
  final String hint;
  final ValueChanged<String>? onSubmitted;

  /// A door's own control beside the field (Is it safe? once had scan +
  /// snap here). Null: the clear cross while typing, nothing idle.
  final Widget? trailing;

  /// The pill's height, which is also the slot it leaves in the hero.
  static const double height = 48;

  // ⚠️ WHILE ACTIVE IN A DOOR WITH A PINNED BAR, THIS LEAVES ITS SLOT EMPTY.
  // The bar builds the same row under the same GlobalKey, so the one
  // TextField moves up into the bar (focus, text and keyboard kept) and the
  // hero keeps a 48-high gap for it to come back to. Both listen to the
  // search, so they rebuild in the same frame and the key is never in two
  // places. Kept for revert: `build` returned `_row(pinned: false)` always.
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: search,
        builder: (context, _) {
          search._field = this;
          if (search._pins && !search.idle) {
            return const SizedBox(height: height, width: double.infinity);
          }
          return _row(pinned: false);
        },
      );

  Widget _row({required bool pinned}) => Row(key: search.fieldKey, children: [
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: p.surface,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: p.line),
            ),
            child: Row(children: [
              const SizedBox(width: 14),
              Icon(Icons.search_rounded, size: 19, color: p.ink2),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: search.ctl,
                  focusNode: search.focus,
                  textInputAction: TextInputAction.search,
                  onSubmitted: onSubmitted,
                  style: pvManrope(fontSize: 15, color: p.ink1),
                  cursorColor: p.ink1,
                  // ⚠️ EVERY BORDER OFF, NOT JUST THE ENABLED ONE — the theme's
                  // input decoration drew a second box inside the stadium on
                  // the phone (2026-09-19).
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: hint,
                    hintStyle: pvManrope(fontSize: 15, color: p.ink3),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    filled: false,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              if (trailing != null)
                trailing!
              else if (search.searching)
                IconButton(
                  onPressed: () {
                    pvCommitFeedback();
                    search.ctl.clear();
                  },
                  icon: Icon(Icons.close_rounded, size: 18, color: p.ink2),
                  visualDensity: VisualDensity.compact,
                )
              // Pinned and empty: the way out of the search (GitHub's and
              // Rodeo's pinned field), so iOS has one besides Back.
              else if (pinned)
                IconButton(
                  tooltip: 'Close search',
                  onPressed: () {
                    pvCommitFeedback();
                    search.release();
                  },
                  icon: Icon(Icons.close_rounded, size: 18, color: p.ink2),
                  visualDensity: VisualDensity.compact,
                )
              else
                const SizedBox(width: 14),
            ]),
          ),
        ),
      ]);
}

/// "Recent" with Clear at the right — the recall state's heading.
Widget pvLiveSearchRecallHeading(V2Palette p, String label, {VoidCallback? onClear, String? sub}) =>
    pvDoorPad(Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: pvFraunces(fontSize: 22, fontWeight: FontWeight.w600, height: 1.15, color: p.ink1)),
          if (sub != null) ...[
            const SizedBox(height: 4),
            Text(sub, style: pvManrope(fontSize: 13.5, height: 1.45, color: p.ink2)),
          ],
        ]),
      ),
      if (onClear != null)
        PvPress(
          child: InkWell(
            onTap: () {
              pvCommitFeedback();
              onClear();
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Text('Clear', style: pvManrope(fontSize: 13, fontWeight: FontWeight.w700, color: p.ink2)),
            ),
          ),
        ),
    ]));

/// The way on under any result list: one card row with an icon, a title
/// and a meaning line. "Ask Veda about …", "Search everywhere".
class PvLiveSearchWayOn extends StatelessWidget {
  const PvLiveSearchWayOn({
    super.key,
    required this.p,
    required this.icon,
    required this.title,
    required this.line,
    required this.onTap,
  });
  final V2Palette p;
  final IconData icon;
  final String title;
  final String line;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => PvPress(
        child: Material(
          color: p.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: p.line)),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
              child: Row(children: [
                Icon(icon, size: 20, color: p.ink1),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: pvManrope(fontSize: 14.5, fontWeight: FontWeight.w700, color: p.ink1)),
                    const SizedBox(height: 2),
                    Text(line,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: pvManrope(fontSize: 12.5, color: p.ink2)),
                  ]),
                ),
                Icon(Icons.chevron_right_rounded, size: 20, color: p.ink3),
              ]),
            ),
          ),
        ),
      );
}

// =============================================================================
//  PvDoorPinnedBar — what sits at the top of a door once it scrolls
// -----------------------------------------------------------------------------
//  The user (2026-10-10): "search bar when scrolled in the door gets at a
//  position at top that doesn't look nice". Two mechanisms made it so:
//
//    scrolled   the field lives in the hero, so it slid on up over the
//               parallaxing photograph and under the status-bar clock, with
//               nothing behind it, and the back button went with it. (TTC
//               had already grown a bar for this, `TtcDoorPinnedBar`; the
//               pregnancy and parenting doors had none.)
//    focused    `Scrollable.ensureVisible(alignment: 0.04)` put the field 4%
//               down the screen, about 32 px: hugging, or under, the status
//               bar on most phones, and still floating on the hero's dark
//               shade, because the hero scrolls with it.
//
//  What the apps in the Mobbin library do instead, and what this does on
//  every door shell (pregnancy, parenting, TTC):
//
//    idle, at the top    the hero is the header: name, line, search pill.
//    idle, scrolled      a compact white bar fades in as the field reaches
//                        it: the status bar's height, then back, the door's
//                        name and a search button; a hairline under it.
//                        Public's resource centre, Tripadvisor's article bar
//                        (https://mobbin.com/screens/6ba472e8-f21d-4b32-9eae-ea8d147504eb).
//    searching           the one field rides up into a solid band pinned
//                        under the status bar (safe area + 10), at the hero's
//                        own gutters, with a close mark; rows scroll beneath
//                        it and a hairline appears once they do. GitHub's,
//                        Rodeo's and Polarsteps' focused search
//                        (https://mobbin.com/screens/f8e87985-87c7-4e81-b4ee-3c288fa34421,
//                        https://mobbin.com/screens/98911313-9499-41ac-9a9b-fb2ed93f32cd).
//
//  ⚠️ NO JUMP, BY CONSTRUCTION. On focus the field is drawn in the bar at the
//  exact spot it left in the hero, then slides to its pinned place while the
//  list scrolls its empty slot to the same place, both over 280 ms on the
//  same curve: the two motions are the same numbers, so the field is seen to
//  glide, and the band fades in under it. Released, the list goes back to
//  where she was and the field drops back into its slot.
//
//  Trade-off, named: the field is pinned by MOVING it (a GlobalKey
//  reparent) rather than by a SliverPersistentHeader. A sliver header would
//  have meant rebuilding each door's ListView as a CustomScrollView and
//  splitting its hero in two; a moved widget keeps every door's structure
//  as it is, at the cost of a slot that sits empty in the hero while she
//  searches (scroll the results right back down and the gap shows).
// =============================================================================

class PvDoorPinnedBar extends StatefulWidget {
  const PvDoorPinnedBar({
    super.key,
    required this.controller,
    required this.search,
    required this.p,
    required this.title,
  });

  /// The door list's controller: the bar reads its offset and moves it.
  final ScrollController controller;
  final PvLiveSearch search;
  final V2Palette p;

  /// The door's name, the compact bar's one line.
  final String title;

  /// The compact bar's height under the status bar.
  static const double barHeight = 52;

  /// Status bar to the pinned field, and the field to the band's foot.
  static const double fieldGap = 10;

  /// How far before the field reaches the bar's foot the bar starts to show.
  static const double ramp = 50;

  static const Duration _move = Duration(milliseconds: 280);
  static const Curve _curve = Curves.easeOutCubic;

  @override
  State<PvDoorPinnedBar> createState() => _PvDoorPinnedBarState();
}

class _PvDoorPinnedBarState extends State<PvDoorPinnedBar>
    with SingleTickerProviderStateMixin {
  // Made in initState, not lazily: a `late final` first touched in dispose
  // would make its ticker from a deactivated element.
  late final AnimationController _slide;

  /// The field's rect at rest in the hero, in list coordinates (top) and
  /// the bar's (left, width). Measured after a frame, while idle.
  double? _fieldTop;
  double _fieldLeft = kPvDoorGutter;
  double? _fieldWidth;

  /// Where the field left from on focus (top, in the bar's coordinates).
  double _from = 0;

  /// The list's offset before she started, to return to; and the offset at
  /// which the field's slot sits exactly under the pinned field.
  double? _before;
  double _rest = 0;

  bool _active = false;

  PvLiveSearch get _s => widget.search;
  ScrollController get _c => widget.controller;

  @override
  void initState() {
    super.initState();
    _slide = AnimationController(vsync: this, duration: PvDoorPinnedBar._move);
    _s.pinsInBar = true;
    _s.addListener(_onSearch);
    _c.addListener(_onScroll);
  }

  @override
  void dispose() {
    _s.removeListener(_onSearch);
    _c.removeListener(_onScroll);
    _s.pinsInBar = false;
    _slide.dispose();
    super.dispose();
  }

  /// The field's rect relative to this bar (whose origin is the screen's
  /// top-left, as the door's list's is). Null when the field is not laid
  /// out in the list (the list has culled the hero, or it is in the bar).
  Rect? _fieldRect() {
    final box = _s.fieldKey.currentContext?.findRenderObject();
    final me = context.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize) return null;
    if (me is! RenderBox || !me.attached) return null;
    final at = box.localToGlobal(Offset.zero) - me.localToGlobal(Offset.zero);
    return at & box.size;
  }

  /// After a frame, so offset and layout agree.
  void _measure() {
    if (!mounted || !_s.idle || !_c.hasClients) return;
    final r = _fieldRect();
    if (r == null) return;
    final top = _c.offset + r.top;
    if (top == _fieldTop && r.left == _fieldLeft && r.width == _fieldWidth) {
      return;
    }
    setState(() {
      _fieldTop = top;
      _fieldLeft = r.left;
      _fieldWidth = r.width;
    });
  }

  void _onScroll() {
    if (mounted) setState(() {});
  }

  double get _pinnedTop =>
      MediaQuery.paddingOf(context).top + PvDoorPinnedBar.fieldGap;

  void _onSearch() {
    if (!mounted) return;
    final active = _s._pins && !_s.idle;
    if (active == _active) return;
    _active = active;
    if (active) {
      // Still in the hero this instant: read where it is.
      final r = _fieldRect();
      if (r != null && _c.hasClients) {
        _from = r.top;
        _fieldTop = _c.offset + r.top;
        _fieldLeft = r.left;
        _fieldWidth = r.width;
      } else {
        _from = _pinnedTop;
      }
      _before = _c.hasClients ? _c.offset : null;
      _slide.value = 0;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_c.hasClients) return;
        final top = _fieldTop ?? (_c.offset + _from);
        _rest = (top - _pinnedTop).clamp(0.0, _c.position.maxScrollExtent);
        // The drawn field leaves from where its slot is now, and the slot
        // travels the same distance on the same curve.
        _from = top - _c.offset;
        _c.animateTo(_rest,
            duration: PvDoorPinnedBar._move, curve: PvDoorPinnedBar._curve);
        _slide.forward(from: 0);
      });
    } else {
      _slide.value = 0;
      final back = _before;
      _before = null;
      if (back != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || !_c.hasClients) return;
          _c.animateTo(back.clamp(0.0, _c.position.maxScrollExtent),
              duration: PvDoorPinnedBar._move, curve: PvDoorPinnedBar._curve);
        });
      }
    }
    setState(() {});
  }

  /// The compact bar's search button. The field may not be built (the list
  /// culls the hero once it is far above), and a FocusNode cannot take focus
  /// until it is in the tree: so first bring the slot to the pinned place,
  /// then focus.
  void _openSearch() {
    pvCommitFeedback();
    if (_s.fieldKey.currentContext == null &&
        _fieldTop != null &&
        _c.hasClients) {
      _c.jumpTo((_fieldTop! - _pinnedTop)
          .clamp(0.0, _c.position.maxScrollExtent));
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _s.focus.requestFocus());
      return;
    }
    _s.focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final field = _s._field;
    final pinned = _active && field != null;
    if (!pinned) WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: pinned ? _searching(top, field) : _compact(top),
    );
  }

  /// Idle: back, the door's name, search; in as the field reaches it.
  Widget _compact(double top) {
    final p = widget.p;
    final o = _c.hasClients ? _c.offset : 0.0;
    final ft = _fieldTop;
    final foot = top + PvDoorPinnedBar.barHeight;
    final t = ft == null
        ? 0.0
        : ((foot + PvDoorPinnedBar.ramp - (ft - o)) / PvDoorPinnedBar.ramp)
            .clamp(0.0, 1.0);
    return IgnorePointer(
      ignoring: t < 0.6,
      child: Opacity(
        opacity: t,
        child: Container(
          padding: EdgeInsets.only(top: top),
          decoration: BoxDecoration(
            color: p.ground,
            border: Border(bottom: BorderSide(color: p.line)),
          ),
          child: SizedBox(
            height: PvDoorPinnedBar.barHeight,
            child: Row(
              children: [
                const SizedBox(width: 6),
                IconButton(
                  tooltip: 'Back',
                  icon: Icon(Icons.arrow_back_rounded, color: p.ink1, size: 22),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                const SizedBox(width: 2),
                Expanded(
                  child: Text(
                    widget.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: pvFraunces(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.3,
                      color: p.ink1,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Search ${widget.title}',
                  icon: Icon(Icons.search_rounded, color: p.ink1, size: 22),
                  onPressed: _openSearch,
                ),
                const SizedBox(width: 6),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Searching: the field, pinned on a solid band under the status bar.
  Widget _searching(double top, PvLiveSearchField field) {
    final p = widget.p;
    final pinnedTop = top + PvDoorPinnedBar.fieldGap;
    final bandHeight =
        pinnedTop + PvLiveSearchField.height + PvDoorPinnedBar.fieldGap;
    return AnimatedBuilder(
      animation: _slide,
      builder: (context, child) {
        final k = PvDoorPinnedBar._curve.transform(_slide.value);
        final dy = (_from - pinnedTop) * (1 - k);
        // The hairline only once the rows have gone under the band.
        final under = _slide.isCompleted &&
            _c.hasClients &&
            _c.offset > _rest + 1;
        return SizedBox(
          height: bandHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: Opacity(
                    opacity: k,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: p.ground,
                        border: Border(
                          bottom: BorderSide(
                            color: under ? p.line : p.line.withValues(alpha: 0),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: pinnedTop + dy,
                left: _fieldLeft,
                width: _fieldWidth ??
                    MediaQuery.sizeOf(context).width - 2 * kPvDoorGutter,
                child: child!,
              ),
            ],
          ),
        );
      },
      // Listens itself: the clear mark changes as she types.
      child: ListenableBuilder(
        listenable: _s,
        builder: (context, _) => (_s._field ?? field)._row(pinned: true),
      ),
    );
  }
}
