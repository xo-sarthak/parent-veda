// =============================================================================
//  Doctor chrome — the few pieces every ParentVeda+ screen is built from
// -----------------------------------------------------------------------------
//  ParentVeda+ is used by clinicians who are mostly in their forties or older,
//  on a phone between patients. So this file is DESIGN-SYSTEM §4.0 (ink for
//  actions, brand as a small accent, colour only inside wells) with the type
//  and the targets TIGHTENED rather than loosened:
//
//    body 15.5 not 12.5 · meta 13 not 10.5 · rows ≥ 56 · targets ≥ 48
//    a chevron on every row that opens · numbers grouped the Indian way
//    no gesture-only actions · one commit button per screen, ink pill
//
//  Tokens come from V2PaletteStore (the app's palette), type from pv_fonts,
//  press feedback from pv_feedback — the same three sources as every V3 screen,
//  so the two apps are one brand. `pp_common.dart` is deliberately NOT
//  imported: it belongs to the parenting stage and another terminal.
//
//  The commit button is the onboarding one (ObPrimary / ObSecondary), re-
//  exported under a doctor name. "There is one button" (§4.3) — a second
//  implementation of the same pill would be the drift this file exists to stop.
// =============================================================================

import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/pv_fonts.dart';
import '../../widgets/pv_feedback.dart';
import '../v2/v2_palette.dart';
import 'doctor_art.dart';

export '../auth/onboarding/onboarding_chrome.dart' show ObPrimary, ObSecondary;

/// The palette every doctor widget reads. The doctor app never switches
/// ground, so a getter beats threading `p` through forty constructors.
V2Palette get dcP => V2PaletteStore.instance.current;

// ---- type ----------------------------------------------------------------

TextStyle dcTitle(double size, {Color? color, double h = 1.15}) => pvFraunces(
    fontSize: size,
    fontWeight: FontWeight.w600,
    letterSpacing: -size * 0.02,
    height: h,
    color: color ?? dcP.ink1);

TextStyle dcNum(double size, {Color? color}) => pvFraunces(
    fontSize: size,
    fontWeight: FontWeight.w600,
    letterSpacing: -size * 0.015,
    height: 1.05,
    color: color ?? dcP.ink1);

TextStyle dcBody(double size,
        {Color? color, FontWeight w = FontWeight.w500, double h = 1.45}) =>
    pvManrope(fontSize: size, fontWeight: w, height: h, color: color ?? dcP.ink1);

TextStyle dcStrong(double size, {Color? color}) =>
    pvManrope(fontSize: size, fontWeight: FontWeight.w700, height: 1.3, color: color ?? dcP.ink1);

TextStyle dcMeta(double size, {Color? color}) =>
    pvManrope(fontSize: size, fontWeight: FontWeight.w500, height: 1.35, color: color ?? dcP.ink2);

TextStyle dcEyebrow({Color? color}) => pvManrope(
    fontSize: 11.5,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.2,
    color: color ?? dcP.ink3);

// ---- money ---------------------------------------------------------------

/// ₹ with Indian grouping: 1,20,000 not 120,000. Paise in, rupees out. A
/// negative amount (a reversal) keeps its sign in front of the symbol.
String dcRupees(int paise, {bool showPaise = false}) {
  final neg = paise < 0;
  final abs = paise.abs();
  final r = showPaise ? abs ~/ 100 : (abs / 100).round();
  var s = r.toString();
  if (s.length > 3) {
    final tail = s.substring(s.length - 3);
    var head = s.substring(0, s.length - 3);
    final parts = <String>[];
    while (head.length > 2) {
      parts.insert(0, head.substring(head.length - 2));
      head = head.substring(0, head.length - 2);
    }
    if (head.isNotEmpty) parts.insert(0, head);
    s = '${parts.join(',')},$tail';
  }
  final p = showPaise ? '.${(abs % 100).toString().padLeft(2, '0')}' : '';
  return '${neg ? '−' : ''}₹$s$p';
}

/// "80%" from basis points; "82.5%" when it is not whole.
String dcPercent(int bps) {
  if (bps % 100 == 0) return '${bps ~/ 100}%';
  return '${(bps / 100).toStringAsFixed(1)}%';
}

const _mo = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
const _wd = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

String dcDate(DateTime d, {bool year = false}) {
  final l = d.toLocal();
  return '${l.day} ${_mo[l.month - 1]}${year ? ' ${l.year}' : ''}';
}

String dcDayDate(DateTime d) {
  final l = d.toLocal();
  return '${_wd[l.weekday - 1]} ${l.day} ${_mo[l.month - 1]}';
}

String dcTime(DateTime d) {
  final l = d.toLocal();
  final h = l.hour % 12 == 0 ? 12 : l.hour % 12;
  final m = l.minute.toString().padLeft(2, '0');
  return '$h:$m ${l.hour < 12 ? 'am' : 'pm'}';
}

String dcMonth(DateTime d) => '${_mo[d.month - 1]} ${d.year}';

// ---- page frames ---------------------------------------------------------

/// A tab body inside DoctorScaffold. Two shapes:
///
///   * with a [hero] — A DOOR. The photograph runs under the status bar, the
///     eyebrow, heading and one line sit on it, and the content is a rounded
///     SHEET that rides up over the picture (`DcHero.overlap`) — the
///     pregnancy doors' composition, which the user asked for on every tab
///     (2026-09-21). The picture parallaxes at half the scroll speed and the
///     words fade as the sheet climbs; a ground strip covers the status-bar
///     inset once the band is gone, and the clock flips light → dark.
///   * without — a plain page: title, subtitle, children, on the 16pt gutter.
///
/// Pull-to-refresh when [onRefresh] is given.
class DcTab extends StatefulWidget {
  /// The floating tab bar's footprint: its height (74) plus the 18 it floats
  /// above the inset. The inset itself is the scaffold's; a tab body that
  /// ends this far short of the bottom lets its last row clear the pill.
  static const double barClearance = 74 + 18;

  const DcTab({
    super.key,
    required this.title,
    required this.children,
    this.trailing,
    this.onRefresh,
    this.subtitle,
    this.hero,
  });
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final List<Widget> children;
  final Future<void> Function()? onRefresh;
  final DcHero? hero;

  @override
  State<DcTab> createState() => _DcTabState();
}

class _DcTabState extends State<DcTab> {
  final ScrollController _scroll = ScrollController();
  /// Raw scroll offset, for the parallax and the fade.
  final ValueNotifier<double> _offset = ValueNotifier(0);
  /// 0..1: how far the status-bar strip has faded in.
  final ValueNotifier<double> _cover = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _applyOverlay());
  }

  void _onScroll() {
    final o = _scroll.offset;
    if (o != _offset.value) _offset.value = o;
    final start = (widget.hero?.height ?? DcHero.doorHeight) - 48;
    final v = ((o - start) / 40).clamp(0.0, 1.0);
    if (v != _cover.value) {
      final flipped = (v >= 0.5) != (_cover.value >= 0.5);
      _cover.value = v;
      if (flipped) _applyOverlay();
    }
  }

  /// AnnotatedRegion alone did not flip the clock on the phone (Samsung,
  /// 2026-09-21); setting the style directly does. Light on the photograph,
  /// dark once the ground strip has covered the inset.
  void _applyOverlay() {
    if (widget.hero == null) return;
    SystemChrome.setSystemUIOverlayStyle(_cover.value < 0.5
        ? SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent)
        : SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent));
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    _offset.dispose();
    _cover.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hero = widget.hero;
    final children = widget.children;
    final p = dcP;
    Widget list = ListView(
      controller: hero == null ? null : _scroll,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: hero == null
          ? const EdgeInsets.fromLTRB(16, 14, 16, 40)
          : EdgeInsets.zero,
      children: [
        if (hero != null) ...[
          hero.withScroll(_offset),
          // THE SHEET. Laid out straight after the band and pulled up over it
          // by the overlap: rounded top corners over picture, never over
          // ground (the doors learnt this — pv_door_screen.dart's hero note).
          Transform.translate(
            offset: const Offset(0, -DcHero.overlap),
            child: Container(
              decoration: BoxDecoration(
                color: p.ground,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(16, 22, 16, 40 + DcTab.barClearance),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
            ),
          ),
        ] else ...[
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.title, style: dcTitle(30)),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(widget.subtitle!, style: dcMeta(14)),
                ],
              ]),
            ),
            ?widget.trailing,
          ]),
          const SizedBox(height: 18),
          ...children,
        ],
      ],
    );
    if (widget.onRefresh != null) {
      list = RefreshIndicator(onRefresh: widget.onRefresh!, color: p.ink1, child: list);
    }
    if (hero == null) return list;

    final top = MediaQuery.of(context).padding.top;
    return ValueListenableBuilder<double>(
      valueListenable: _cover,
      builder: (context, cover, _) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: cover < 0.5 ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        child: Stack(children: [
          list,
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: top,
            child: IgnorePointer(
              child: Opacity(opacity: cover, child: ColoredBox(color: p.ground)),
            ),
          ),
        ]),
      ),
    );
  }
}

/// The door hero. A photograph of a place (never a face), an ink scrim so
/// the words read, an eyebrow, a heading in Newsreader, ONE line under it
/// — the pregnancy doors' grammar (pv_door_screen.dart `_Hero`) — and, top
/// right, the bell and (on Home) her own photograph, both 44pt.
///
/// The scrim is ink at 0.52 → 0.30 → 0.34, the doors' numbers: heavier at
/// the top for the status bar and the date, lighter through the middle so
/// the picture is a picture, and it never fades to the page colour — that
/// washes the type into a haze.
class DcHero extends StatelessWidget {
  const DcHero({
    super.key,
    required this.asset,
    required this.greeting,
    this.eyebrow,
    this.dateLine,
    this.infoLine,
    this.photoUrl,
    this.initial,
    this.onAvatar,
    this.badge = 0,
    this.onBell,
    this.facts = const [],
    this.height = doorHeight,
    this.scroll,
  });
  final String asset;
  /// The band's height without the status inset. The doors' 332 by default;
  /// Profile passes a banner — LinkedIn's cover is about a quarter of the
  /// screen, and at the door's height the photograph read as the page
  /// (the user, 2026-09-21: "covering 40% of the screen doesn't make sense").
  final double height;
  /// Up to three figures on the photograph under the blurb — "0 today ·
  /// 3 this week · 12 slots open". Fiverr's and Airbnb's host heroes: the
  /// same facts the page repeats below, but read in one glance. Empty on the
  /// tabs whose heading already says everything.
  final List<DcFact> facts;
  /// Small caps above the heading: the tab's name on a tab, nothing on Home.
  final String? eyebrow;
  /// The heading: the greeting on Home, the tab's phrase elsewhere.
  final String greeting;
  final String? dateLine;
  final String? infoLine;
  final String? photoUrl;
  final String? initial;
  final VoidCallback? onAvatar;
  final int badge;
  final VoidCallback? onBell;
  /// The list's scroll offset, for the parallax and the fade. Set by DcTab.
  final ValueListenable<double>? scroll;

  DcHero withScroll(ValueListenable<double> s) => DcHero(
        key: key,
        asset: asset,
        greeting: greeting,
        eyebrow: eyebrow,
        dateLine: dateLine,
        infoLine: infoLine,
        photoUrl: photoUrl,
        initial: initial,
        onAvatar: onAvatar,
        badge: badge,
        onBell: onBell,
        facts: facts,
        height: height,
        scroll: s,
      );

  /// The doors' band height (plus the status inset) and how far the sheet
  /// rides up into it. 300 was the doors' height; the facts row needs the
  /// extra. A tab may pass its own [height].
  static const double doorHeight = 332;
  static const double bannerHeight = 168;
  static const double overlap = 28;

  @override
  Widget build(BuildContext context) {
    final p = dcP;
    final top = MediaQuery.of(context).padding.top;
    final total = height + top;
    return SizedBox(
      height: total,
      child: ValueListenableBuilder<double>(
        valueListenable: scroll ?? const AlwaysStoppedAnimation(0.0),
        builder: (context, o, _) {
          // Parallax: the picture climbs at half the sheet's speed, so it
          // reads as behind the page rather than part of it. The words fade
          // over the first 160pt so the sheet is never over live type.
          final shift = (o * 0.5).clamp(0.0, total);
          final fade = (1 - o / 180).clamp(0.0, 1.0);
          return Stack(fit: StackFit.expand, clipBehavior: Clip.hardEdge, children: [
            Transform.translate(
              offset: Offset(0, shift),
              child: Image.asset(asset, fit: BoxFit.cover, alignment: Alignment.center,
                  errorBuilder: (_, _, _) => Container(color: p.surfaceAlt)),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.52),
                    Colors.black.withValues(alpha: 0.30),
                    Colors.black.withValues(alpha: 0.42),
                  ],
                  stops: const [0, 0.55, 1],
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              top: top + 12,
              child: Opacity(
                opacity: fade,
                child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                  Expanded(
                    child: Text(dateLine ?? '', style: dcStrong(13.5, color: Colors.white.withValues(alpha: 0.9))),
                  ),
                  if (onBell != null) ...[
                    _Bell(count: badge, onTap: onBell!),
                    const SizedBox(width: 10),
                  ],
                  if (onAvatar != null || photoUrl != null || initial != null)
                    _Avatar(photoUrl: photoUrl, initial: initial, onTap: onAvatar),
                ]),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: overlap + 24,
              child: Opacity(
                opacity: fade,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  if (eyebrow != null && eyebrow!.isNotEmpty) ...[
                    Text(eyebrow!.toUpperCase(), style: dcEyebrow(color: Colors.white.withValues(alpha: 0.82))),
                    const SizedBox(height: 8),
                  ],
                  // Profile passes an empty heading: its name sits under
                  // the photo circle in the sheet (LinkedIn's arrangement).
                  if (greeting.isNotEmpty)
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 320),
                    child: Text(greeting,
                        style: dcTitle(30, color: Colors.white).copyWith(shadows: const [Shadow(color: Color(0x55000000), blurRadius: 12)]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ),
                  if (infoLine != null && infoLine!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 330),
                      child: Text(infoLine!,
                          style: dcBody(14.5, color: Colors.white.withValues(alpha: 0.92), w: FontWeight.w600, h: 1.5),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                  if (facts.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Row(children: [
                      for (var i = 0; i < facts.length; i++) ...[
                        if (i > 0)
                          Container(
                            width: 1,
                            height: 30,
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            color: Colors.white.withValues(alpha: 0.35),
                          ),
                        // Flexible, so a wide text scale shortens a label
                        // rather than pushing the row off the photograph.
                        Flexible(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                            Text(facts[i].value, style: dcTitle(22, color: Colors.white).copyWith(height: 1.0), maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 3),
                            Text(facts[i].label, style: dcMeta(12, color: Colors.white.withValues(alpha: 0.82)), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ]),
                        ),
                      ],
                    ]),
                  ],
                ]),
              ),
            ),
          ]);
        },
      ),
    );
  }
}

/// One figure on the hero: the value in Fraunces, the label under it.
class DcFact {
  const DcFact(this.value, this.label);
  final String value;
  final String label;
}

/// The bell on the photograph: a white disc, an ink bell, the count as a
/// small ink pill. Never red — a count is information; the one red in this
/// app is for a field with a problem. 44pt, the same as the avatar.
class _Bell extends StatelessWidget {
  const _Bell({required this.count, required this.onTap});
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = dcP;
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Stack(clipBehavior: Clip.none, children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: p.surface,
            boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 10, offset: Offset(0, 3))],
          ),
          child: Icon(count > 0 ? Icons.notifications_rounded : Icons.notifications_none_rounded, size: 22, color: p.ink1),
        ),
        if (count > 0)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              constraints: const BoxConstraints(minWidth: 20),
              height: 20,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: p.ink1,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: p.surface, width: 2),
              ),
              child: Text('$count', style: dcStrong(11, color: p.surface)),
            ),
          ),
      ]),
    );
  }
}

/// Her photograph, 44pt like the bell; her initial when there is none.
class _Avatar extends StatelessWidget {
  const _Avatar({this.photoUrl, this.initial, this.onTap});
  final String? photoUrl;
  final String? initial;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = dcP;
    final ring = Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: p.surface,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 10, offset: Offset(0, 3))],
      ),
      clipBehavior: Clip.antiAlias,
      child: photoUrl == null
          ? Center(child: Text((initial ?? '?').toUpperCase(), style: dcNum(19)))
          : Image.network(
              photoUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Center(child: Text((initial ?? '?').toUpperCase(), style: dcNum(19))),
            ),
    );
    if (onTap == null) return ring;
    return InkWell(onTap: onTap, customBorder: const CircleBorder(), child: ring);
  }
}

/// A pushed screen: white ground, back arrow, title, scrolling body, an
/// optional commit button pinned at the bottom.
class DcScreen extends StatelessWidget {
  const DcScreen({
    super.key,
    required this.title,
    required this.children,
    this.subtitle,
    this.bottom,
    this.trailing,
    this.onRefresh,
  });
  final String title;
  final String? subtitle;
  final List<Widget> children;
  final Widget? bottom;
  final Widget? trailing;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    final p = dcP;
    Widget list = ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32 + DcTab.barClearance),
      children: [
        Text(title, style: dcTitle(28)),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(subtitle!, style: dcMeta(14)),
        ],
        const SizedBox(height: 18),
        ...children,
      ],
    );
    if (onRefresh != null) {
      list = RefreshIndicator(onRefresh: onRefresh!, color: p.ink1, child: list);
    }
    return Scaffold(
      backgroundColor: p.ground,
      body: SafeArea(
        child: Column(children: [
          SizedBox(
            height: 48,
            child: Row(children: [
              IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: Icon(Icons.arrow_back_rounded, color: p.ink1),
                tooltip: 'Back',
              ),
              const Spacer(),
              ?trailing,
            ]),
          ),
          Expanded(child: list),
          if (bottom != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: bottom,
            ),
        ]),
      ),
    );
  }
}

// ---- sections and rows ---------------------------------------------------

class DcSectionHead extends StatelessWidget {
  const DcSectionHead(this.eyebrow, {super.key, this.title, this.note, this.onNote});
  final String eyebrow;
  final String? title;
  final String? note;
  final VoidCallback? onNote;

  @override
  Widget build(BuildContext context) {
    final p = dcP;
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Text(eyebrow.toUpperCase(),
                style: dcEyebrow(color: p.action.withValues(alpha: 0.85)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
          if (note != null)
            InkWell(
              onTap: onNote,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text(note!,
                    style: dcStrong(13, color: onNote == null ? p.ink3 : p.action)),
              ),
            ),
        ]),
        if (title != null) ...[
          const SizedBox(height: 4),
          Text(title!, style: dcTitle(21)),
        ],
      ]),
    );
  }
}

/// A white card with a hairline. Elevation in this system is a line.
class DcCard extends StatelessWidget {
  const DcCard({super.key, required this.child, this.padding = const EdgeInsets.all(14), this.onTap, this.tint});
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final p = dcP;
    final box = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: tint ?? p.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.line),
      ),
      child: child,
    );
    if (onTap == null) return box;
    return PvPress(
      child: Material(
        color: Colors.transparent,
        child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(16), child: box),
      ),
    );
  }
}

/// The list row: optional icon well, title, subtitle, a trailing value or a
/// chevron. ≥ 56 tall. Rows stack with hairlines between them inside a
/// DcRowGroup, or stand alone as a card.
class DcRow extends StatelessWidget {
  const DcRow({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.hue,
    this.trailing,
    this.trailingText,
    this.trailingSub,
    this.onTap,
    this.chevron = true,
    this.titleColor,
    this.leading,
    this.mark,
    this.markMuted = false,
    this.markRing = false,
  });
  final String title;
  final String? subtitle;
  final IconData? icon;
  final double? hue;
  /// A custom leading block (a photograph thumbnail) in place of the icon well.
  final Widget? leading;
  /// A drawn mark (doctor_art.dart) in place of the icon well — the same
  /// hand as the doors, and what replaced "icons everywhere".
  final DoctorMark? mark;
  /// The mark on the neutral surface, greyed — a row that cannot be acted on
  /// yet (a no-show before ten minutes have passed).
  final bool markMuted;
  /// The mark on a white disc in a hairline ring instead of the tinted
  /// well — for a row that explains rather than acts (doctor_art.dart).
  final bool markRing;
  final Widget? trailing;
  final String? trailingText;
  final String? trailingSub;
  final VoidCallback? onTap;
  final bool chevron;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    final p = dcP;
    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(children: [
        if (leading != null) ...[
          leading!,
          const SizedBox(width: 14),
        ] else if (mark != null) ...[
          if (markRing) DoctorArtRing(mark: mark!, p: p, size: 44) else DoctorArtTile(mark: mark!, p: p, size: 44, radius: 13, muted: markMuted),
          const SizedBox(width: 14),
        ] else if (icon != null) ...[
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: hue == null ? p.surfaceAlt : v2BlockTint(hue!, p),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 21, color: p.ink1),
          ),
          const SizedBox(width: 14),
        ],
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: dcStrong(15.5, color: titleColor), maxLines: 2, overflow: TextOverflow.ellipsis),
            if (subtitle != null) ...[
              const SizedBox(height: 3),
              Text(subtitle!, style: dcMeta(13), maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ]),
        ),
        if (trailingText != null) ...[
          const SizedBox(width: 12),
          // Capped, not flexed: a Flexible here takes a flex SHARE of the row
          // and squeezes the value to a quarter width (walked 2026-09-18:
          // "Obstetricia / n"). A cap lets a sum or two-line hours sit at
          // their natural width and only wraps the genuinely long.
          LayoutBuilder(
            builder: (ctx, _) => ConstrainedBox(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(ctx).size.width * 0.44),
              child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(trailingText!, style: dcStrong(15), textAlign: TextAlign.right, maxLines: 2, overflow: TextOverflow.ellipsis),
                if (trailingSub != null) ...[
                  const SizedBox(height: 2),
                  Text(trailingSub!, style: dcMeta(12, color: p.ink3), textAlign: TextAlign.right),
                ],
              ]),
            ),
          ),
        ],
        if (trailing != null) ...[const SizedBox(width: 12), trailing!],
        if (onTap != null && chevron) ...[
          const SizedBox(width: 6),
          Icon(Icons.chevron_right_rounded, size: 24, color: p.ink3),
        ],
      ]),
    );
    if (onTap == null) return row;
    return PvPress(
      child: Material(
        color: Colors.transparent,
        child: InkWell(onTap: onTap, child: row),
      ),
    );
  }
}

/// A label and its value: the label short and fixed, the value taking the
/// rest and wrapping. For "what parents see" and a payout's particulars —
/// the opposite shape from DcRow, where the title is the long side.
class DcKeyValue extends StatelessWidget {
  const DcKeyValue(this.label, this.value, {super.key, this.mono = false});
  final String label;
  final String value;
  final bool mono;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(width: 110, child: Text(label, style: dcMeta(14.5))),
          const SizedBox(width: 12),
          Expanded(
            child: Text(value,
                textAlign: TextAlign.right,
                style: dcStrong(15).copyWith(fontFeatures: mono ? const [FontFeature.tabularFigures()] : null)),
          ),
        ]),
      );
}

/// Rows in one hairlined card, separated by hairlines.
class DcRowGroup extends StatelessWidget {
  const DcRowGroup({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final p = dcP;
    // NO BOX. This was a bordered, rounded container with its own inset,
    // inside the page gutter — so every line started ~37pt from the edge and
    // the content sat in a channel ("a left and a right gutter that squishes
    // everything in between" — the user, 2026-09-21). Airbnb's settings,
    // Notion's and Linear's lists are rows on the ground with a hairline
    // between them: the text sits on the page gutter and nothing else.
    return Column(children: [
      Divider(height: 1, thickness: 1, color: p.line),
      for (var i = 0; i < children.length; i++) ...[
        if (i > 0) Divider(height: 1, thickness: 1, color: p.line),
        children[i],
      ],
      Divider(height: 1, thickness: 1, color: p.line),
    ]);
  }
}

/// Label small and above, value large and below — never the reverse (§4.10).
class DcStat extends StatelessWidget {
  const DcStat(this.label, this.value, {super.key, this.sub, this.valueColor});
  final String label;
  final String value;
  final String? sub;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: dcEyebrow()),
          const SizedBox(height: 6),
          Text(value, style: dcNum(24, color: valueColor), maxLines: 1, overflow: TextOverflow.ellipsis),
          if (sub != null) ...[
            const SizedBox(height: 3),
            Text(sub!, style: dcMeta(12.5)),
          ],
        ],
      );
}

/// Two or three stats side by side between two hairlines. It WAS a card;
/// stacked under the other cards on Earnings the borders read as a wall
/// down each side of the screen (the user, 2026-09-21). Same rule as the
/// lists: rows and hairlines, never a box.
class DcStatRow extends StatelessWidget {
  const DcStatRow(this.stats, {super.key});
  final List<DcStat> stats;

  @override
  Widget build(BuildContext context) {
    final p = dcP;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: p.line), bottom: BorderSide(color: p.line))),
      child: Row(children: [
        for (var i = 0; i < stats.length; i++) ...[
          if (i > 0) Container(width: 1, height: 44, color: p.line, margin: const EdgeInsets.symmetric(horizontal: 14)),
          Expanded(child: stats[i]),
        ],
      ]),
    );
  }
}

/// The blocker / attention card — Airbnb's "Account info is needed — Required
/// to get paid". One thing, one action. Amber well because it is a notice,
/// never a fill.
class DcAttention extends StatelessWidget {
  const DcAttention({
    super.key,
    required this.title,
    required this.body,
    required this.action,
    required this.onTap,
    this.icon = Icons.info_outline_rounded,
    this.urgent = false,
    this.mark,
  });
  final String title;
  final String body;
  final String action;
  final VoidCallback onTap;
  final IconData icon;
  final bool urgent;
  final DoctorMark? mark;

  @override
  Widget build(BuildContext context) {
    final p = dcP;
    final well = v2BlockTint(urgent ? 344 : 42, p);
    // A row between hairlines, not a card — see DcStatRow.
    return InkWell(
      onTap: onTap,
      child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: p.line), bottom: BorderSide(color: p.line))),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (mark != null)
          DoctorArtTile(mark: mark!, p: p, size: 44, radius: 13)
        else
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: well, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, size: 21, color: p.ink1),
          ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: dcStrong(15.5)),
            const SizedBox(height: 3),
            Text(body, style: dcMeta(13.5)),
            const SizedBox(height: 8),
            Text(action, style: dcStrong(14, color: p.action)),
          ]),
        ),
        Icon(Icons.chevron_right_rounded, size: 24, color: p.ink3),
      ]),
      ),
    );
  }
}

/// A receipt line: label left, value right. [strong] for the total.
class DcReceiptLine extends StatelessWidget {
  const DcReceiptLine(this.label, this.value, {super.key, this.strong = false, this.muted = false, this.note});
  final String label;
  final String value;
  final bool strong;
  final bool muted;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final p = dcP;
    final c = muted ? p.ink2 : p.ink1;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: strong ? 10 : 7),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(label, style: strong ? dcStrong(16) : dcBody(15, color: c))),
          Text(value, style: strong ? dcNum(20) : dcStrong(15, color: c)),
        ]),
        if (note != null) ...[
          const SizedBox(height: 3),
          Text(note!, style: dcMeta(12.5, color: p.ink3)),
        ],
      ]),
    );
  }
}

/// Segmented control: hairline pills, selected = ink fill (§4.0 chip).
/// [expand] shares the width equally and never scrolls — for two or three
/// segments that must all be visible on a 360px phone (Today · Upcoming ·
/// Past). A segment a clinician cannot see is a tab that does not exist.
class DcSegments extends StatelessWidget {
  const DcSegments({super.key, required this.labels, required this.index, required this.onChanged, this.expand = false});
  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final p = dcP;
    Widget pill(int i) => PvPress(
          child: InkWell(
            onTap: () => onChanged(i),
            borderRadius: BorderRadius.circular(999),
            child: Container(
              height: 40,
              padding: EdgeInsets.symmetric(horizontal: expand ? 6 : 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: i == index ? p.ink1 : p.surface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: i == index ? p.ink1 : p.line),
              ),
              child: Text(labels[i],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: dcStrong(expand ? 13.5 : 14, color: i == index ? p.surface : p.ink1)),
            ),
          ),
        );
    if (expand) {
      return Row(children: [
        for (var i = 0; i < labels.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(child: pill(i)),
        ],
      ]);
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: [
        for (var i = 0; i < labels.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          pill(i),
        ],
      ]),
    );
  }
}

/// A status word in a hairline pill. Colour only as a tinted well.
class DcStatusPill extends StatelessWidget {
  const DcStatusPill(this.label, {super.key, this.hue});
  final String label;
  final double? hue;

  @override
  Widget build(BuildContext context) {
    final p = dcP;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: hue == null ? p.surfaceAlt : v2BlockTint(hue!, p),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: dcStrong(12, color: p.ink1)),
    );
  }
}

/// The empty state — the feature's advertisement, never a blank.
class DcEmpty extends StatelessWidget {
  const DcEmpty(this.title, this.body, {super.key, this.icon = Icons.inbox_outlined, this.action, this.onAction, this.mark});
  final String title;
  final String body;
  final IconData icon;
  /// A drawn mark in place of the line icon — the empty state is the
  /// feature's advertisement, and an advertisement is drawn, not iconed.
  final DoctorMark? mark;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final p = dcP;
    return DcCard(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (mark != null) DoctorArtTile(mark: mark!, p: p, size: 48, radius: 15) else Icon(icon, size: 26, color: p.ink3),
        const SizedBox(height: 12),
        Text(title, style: dcStrong(16)),
        const SizedBox(height: 4),
        Text(body, style: dcMeta(14)),
        if (action != null && onAction != null) ...[
          const SizedBox(height: 12),
          InkWell(
            onTap: onAction,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(action!, style: dcStrong(14, color: p.action)),
            ),
          ),
        ],
      ]),
    );
  }
}

/// A switch row: label + optional sub on the left, the switch on the right.
/// The switch's on-state is one of the five places violet may appear.
class DcSwitchRow extends StatelessWidget {
  const DcSwitchRow({super.key, required this.title, required this.value, required this.onChanged, this.subtitle, this.icon, this.mark});
  final String title;
  final String? subtitle;
  final IconData? icon;
  final DoctorMark? mark;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => DcRow(
        title: title,
        subtitle: subtitle,
        icon: icon,
        mark: mark,
        chevron: false,
        onTap: () => onChanged(!value),
        // Ink, not violet. The base-UI rule allowed the switch's on-state as
        // one of the five places for the brand colour; the user rejected it
        // on the doctor app ("the toggles are purple — makes no sense",
        // 2026-09-21). Ink for actions, and a switch is an action.
        trailing: Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeTrackColor: dcP.ink1,
          activeThumbColor: dcP.surface,
        ),
      );
}

/// A text input in the onboarding field's clothes: label above, hairline box.
class DcInput extends StatelessWidget {
  const DcInput({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.keyboard,
    this.obscure = false,
    this.onSubmitted,
    this.autofocus = false,
    this.capitals = false,
    this.errorText,
  });
  final String label;
  final TextEditingController controller;
  final String? hint;
  final TextInputType? keyboard;
  final bool obscure;
  final bool autofocus;
  final bool capitals;
  final ValueChanged<String>? onSubmitted;

  /// A problem with THIS field: the border turns red and the words sit
  /// under it in red. Subway, CHOPT and Target do exactly this (Mobbin,
  /// 2026-09-21); the tinted block the auth screen had is the callout
  /// language the user rejected on sight. Nothing but the text and the line.
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final p = dcP;
    final bad = errorText != null && errorText!.isNotEmpty;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label.toUpperCase(), style: dcEyebrow(color: bad ? dcError : null)),
      const SizedBox(height: 7),
      TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboard,
        autofocus: autofocus,
        autocorrect: false,
        enableSuggestions: false,
        textCapitalization: capitals ? TextCapitalization.characters : TextCapitalization.none,
        style: dcBody(16),
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: dcBody(16, color: p.ink3),
          filled: true,
          fillColor: p.surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: bad ? dcError : p.line, width: bad ? 1.4 : 1.2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: bad ? dcError : p.ink1, width: 1.4),
          ),
        ),
      ),
      if (bad) ...[
        const SizedBox(height: 7),
        Text(errorText!, style: dcBody(13.5, color: dcError, w: FontWeight.w600)),
      ],
    ]);
  }
}

/// The one red. Text and hairlines only — never a fill.
const Color dcError = Color(0xFFD92D20);

/// A note: an icon and a line of quiet text, no background. This USED to be
/// a tinted rounded block (sand for information, rose for a problem) and
/// the user rejected the shape itself — "a background of colour in a
/// rectangle with soft edges" — on the sign-in screen, 2026-09-21. The
/// message is the words; a coloured box behind them is a second message
/// ("look, a callout") that says nothing. Problems are red text; notes are
/// grey text with an info mark.
class DcNotice extends StatelessWidget {
  const DcNotice(this.text, {super.key, this.problem = false});
  final String text;
  final bool problem;

  @override
  Widget build(BuildContext context) {
    final p = dcP;
    final c = problem ? dcError : p.ink2;
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Icon(problem ? Icons.error_outline_rounded : Icons.info_outline_rounded, size: 17, color: c),
      ),
      const SizedBox(width: 8),
      Expanded(child: Text(text, style: dcBody(14, h: 1.45, color: c, w: problem ? FontWeight.w600 : FontWeight.w500))),
    ]);
  }
}

/// The app's sheet: ground, top radius 24, close top-right (§4.0).
Future<T?> dcSheet<T>(BuildContext context, {required String title, required Widget child, bool scrollable = true}) {
  final p = dcP;
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: p.ground,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.88),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 8, 6),
              child: Row(children: [
                Expanded(child: Text(title, style: dcTitle(22))),
                IconButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  icon: Icon(Icons.close_rounded, color: p.ink1),
                  tooltip: 'Close',
                ),
              ]),
            ),
            Flexible(
              child: scrollable
                  ? SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                      child: child,
                    )
                  : Padding(padding: const EdgeInsets.fromLTRB(20, 4, 20, 20), child: child),
            ),
          ]),
        ),
      ),
    ),
  );
}

/// Every commit tap answers (DESIGN-SYSTEM §4.0c).
void dcToast(BuildContext context, String text) {
  pvCommitFeedback();
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(SnackBar(
      content: Text(text, style: dcBody(14, color: Colors.white)),
      backgroundColor: dcP.ink1,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
}
