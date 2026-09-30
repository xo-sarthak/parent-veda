// =============================================================================
//  TtcDoorHero — the top of a Trying-to-Conceive door, built for flat art
// -----------------------------------------------------------------------------
//  The user, walking build 20 (2026-09-29), on the nine door heroes:
//    · "Instead of real-looking images, we need something that suits our hero
//      sections, the way we have the onboarding images" (assets/onboarding:
//      soft gouache, an Indian woman in pastel clothes, a flat pastel ground,
//      a cream circle behind her).
//    · "The image must be visible, the heading must be visible."
//    · "The search bar feels like a fit-to-fill because of the spacing issues
//      it has with the horizontal swipeable cards below."
//  And the lead, after the His side redo (a regenerated image showed only a
//  slice of itself): the frame CROPPED the art, because it was a cover-fit
//  in a box whose shape was not the art's. So:
//
//  ⚠️ THE ART IS SHOWN WHOLE, AT ITS OWN ASPECT, NEVER ZOOMED OR CROPPED.
//  A full-width frame of exactly [kTtcDoorHeroArtAspect] (3:2, the art is
//  1536 x 1024) with the picture CONTAINED in it. A 3:2 picture fills the
//  frame edge to edge; anything else is letterboxed onto the hero's ground,
//  never cut. `ttc_door_screen_test` holds it (rendered aspect == source).
//
//  ⚠️ NO TYPE ON THE PICTURE, NO SCRIM. The back button sits on the art's
//  plain top-left corner; everything else (the door's name, the headline,
//  the intro line, the search) sits BELOW the frame, in ink, on one flat
//  ground: the colour of the art's own left edge, sampled from the pixels,
//  so the frame and the page read as one painting. The ground is lifted
//  toward white only when ink would not read on it at 7:1 (the photographs'
//  darker edges); a pastel art ground already passes and is used as it is.
//
//  ⚠️ THE SEARCH HAS ITS OWN ROW. The white pill with a hairline, the same
//  `PvLiveSearchField` Learn's header uses, [kTtcDoorHeroSearchGap] under
//  the intro and [kTtcDoorHeroFootGap] over the sheet's edge; the tab rail
//  sits on the sheet, the same gap under its edge, and no longer rides up
//  over the hero. The frosted glass field is retired here: on a flat pastel
//  there is nothing behind it to frost, and its white type would fail
//  contrast on a light ground (kept on disk in `ttc_door_search.dart`).
//
//  ⚠️ NO PARALLAX. It moved a photograph behind a sheet; with the words below
//  the frame, a slower picture would slide under her headline, which is the
//  thing the user asked us to stop. The frame scrolls with the page.
//
//  Mobbin, the shape (art in its own frame at the top, the title and a line
//  in ink under it, the search as its own white row):
//    · Liven, "Love & Connection": art top right, back top left, title and
//      line below (https://mobbin.com/screens/6afeb490-faec-43d4-b8e0-dd31e12a2abb)
//    · Headspace, "Radio Headspace": the art framed whole, title and line
//      under it (https://mobbin.com/screens/f2297328-ef5d-42b9-96ba-e851f428f5e4)
//    · Grab, Help Center: illustration right on a flat pastel band, a white
//      search pill in its own row (https://mobbin.com/screens/d558d8cd-1513-4a03-aeef-b5d1fb80b75e)
//    · Flo, "How to get pregnant": illustration cards whose subject is whole
//      (https://mobbin.com/screens/34cba6ae-ab7b-4233-b8a8-0f9c68d605f7)
//
//  THE ART SLOT, keyed by door id ([kTtcDoorHeroArtSlug]):
//    assets/doors/hero_<slug>.jpg, 1536 x 1024, 3:2 landscape. The subject
//    (person or objects and the cream circle) in the RIGHT half; the LEFT
//    half one flat colour, the art's own ground, with the top-left corner
//    empty for the back button. Until a file exists the door's photograph
//    shows, whole, in the same frame; with neither, the door's drawn mark.
// =============================================================================

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../models/bracket.dart';
import '../../../theme/pv_fonts.dart';
import '../../../ttc/ttc_focus_data.dart';
import '../../doors/pv_door_chrome.dart' show kPvDoorGutter;
import '../../doors/pv_live_search.dart';
import '../../v2/v2_palette.dart';
import '../../v2/v3_bracket_art.dart';

// -----------------------------------------------------------------------------
//  The slot
// -----------------------------------------------------------------------------

/// The art's shape: 1536 x 1024. The frame is this shape, always.
const double kTtcDoorHeroArtAspect = 3 / 2;

/// The size the art is made at (the lead's prompts, 2026-09-29).
const Size kTtcDoorHeroArtSize = Size(1536, 1024);

/// Past this width (a tablet) the frame stops growing and centres on the
/// ground, so the hero does not become a wall of picture.
const double kTtcDoorHeroArtMaxWidth = 560;

/// Door id to the art's file name, `assets/doors/hero_<slug>.jpg`. The names
/// are the ones the image prompts were written for.
const Map<String, String> kTtcDoorHeroArtSlug = {
  'ttc_conceiving': 'fertile_window',
  'ttc_pcos': 'pcos',
  'ttc_infertility': 'ivf_iui',
  'ttc_preconception_health': 'getting_ready',
  'ttc_not_yet': 'taking_a_while',
  'ttc_male_fertility': 'his_side',
  'ttc_mind_body': 'mind_body',
  'ttc_body_cycle': 'body_cycle',
  'ttc_after_loss': 'after_loss',
};

/// The asset path for a door's art, or null for a door with no slot.
String? ttcDoorHeroArtAsset(String bracketId) {
  final slug = kTtcDoorHeroArtSlug[bracketId];
  return slug == null ? null : 'assets/doors/hero_$slug.jpg';
}

// -----------------------------------------------------------------------------
//  The rhythm under the frame
// -----------------------------------------------------------------------------

/// From the frame's foot to the door's name.
const double kTtcDoorHeroTopGap = 18;

/// From the intro line to the search pill.
const double kTtcDoorHeroSearchGap = 18;

/// From the search pill to the sheet's edge. The rail sits the same distance
/// under that edge (`kTtcDoorRailTopGap` in the door screen).
const double kTtcDoorHeroFootGap = 18;

/// The search pill's height (`PvLiveSearchField`).
const double kTtcDoorHeroSearchHeight = 48;

/// The words' zone under the frame, sized for the door's name, a two-line
/// headline, a four-line intro (three cut the PCOS intro short on a 360dp
/// phone) and the search, so every door is the same height; the words sit
/// at its foot. A larger text size grows it rather than clip her words.
const double kTtcDoorHeroTextZone = 280;

/// How far the ground runs on under the sheet, so its rounded top corners
/// show the hero's colour and not the field behind the list.
const double kTtcDoorHeroBleed = 38;

/// The hero's height for a screen [width] and status-bar [top]. The same on
/// every door (the user, 2026-09-27: "the hero image height differs door to
/// door"); only a very large text size makes it taller.
double ttcDoorHeroHeight(double width, double top) =>
    top +
    math.min(width, kTtcDoorHeroArtMaxWidth) / kTtcDoorHeroArtAspect +
    kTtcDoorHeroTextZone;

// -----------------------------------------------------------------------------
//  Keys a test can find
// -----------------------------------------------------------------------------

const Key kTtcDoorHeroArtKey = ValueKey('ttc-door-hero-art');
const Key kTtcDoorHeroGroundKey = ValueKey('ttc-door-hero-ground');
const Key kTtcDoorHeroTitleKey = ValueKey('ttc-door-hero-title');
const Key kTtcDoorHeroIntroKey = ValueKey('ttc-door-hero-intro');
const Key kTtcDoorHeroEyebrowKey = ValueKey('ttc-door-hero-eyebrow');

// -----------------------------------------------------------------------------
//  The ground
// -----------------------------------------------------------------------------

/// WCAG contrast ratio between two opaque colours.
double ttcContrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

/// The ground under the hero's words, from the colour at the art's left
/// edge: that colour as it is when [ink] reads on it at [atLeast] (a pastel
/// art ground does, so the frame and the page are one colour), else lifted
/// toward white in small steps until it does (a photograph's darker edge).
/// 7:1 is WCAG AAA for body text; the intro is body text in ink.
Color ttcDoorHeroGround(Color edge, Color ink, {double atLeast = 7}) {
  var c = Color.alphaBlend(edge, const Color(0xFFFFFFFF));
  for (var i = 0; i < 40 && ttcContrast(ink, c) < atLeast; i++) {
    c = Color.lerp(c, const Color(0xFFFFFFFF), 0.08)!;
  }
  return c;
}

/// Sampled left-edge colours, by image, so a door opened twice does not
/// flash from the tint to the art's ground.
final Map<Object, Color> _edgeCache = {};

/// The mean colour of a column 1% in from the left, across the middle 60%
/// of the height: the art's flat ground, clear of any corner vignette.
Future<Color?> _sampleLeftEdge(ui.Image img) async {
  final data = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
  if (data == null) return null;
  final w = img.width, h = img.height;
  if (w == 0 || h == 0) return null;
  final x = (w * 0.01).floor().clamp(0, w - 1);
  final step = math.max(1, h ~/ 60);
  var r = 0, g = 0, b = 0, n = 0;
  for (
    var y = (h * 0.2).floor();
    y < math.max(1, (h * 0.8).floor());
    y += step
  ) {
    final i = (y * w + x) * 4;
    if (i + 3 >= data.lengthInBytes) break;
    final a = data.getUint8(i + 3) / 255;
    // Composited on white, so a transparent edge reads as the white it shows.
    r += (data.getUint8(i) * a + 255 * (1 - a)).round();
    g += (data.getUint8(i + 1) * a + 255 * (1 - a)).round();
    b += (data.getUint8(i + 2) * a + 255 * (1 - a)).round();
    n++;
  }
  if (n == 0) return null;
  return Color.fromARGB(255, r ~/ n, g ~/ n, b ~/ n);
}

// =============================================================================
//  The hero
// =============================================================================

class TtcDoorHero extends StatefulWidget {
  const TtcDoorHero({
    super.key,
    required this.page,
    required this.p,
    required this.tint,
    required this.eyebrow,
    required this.bracket,
    required this.search,
    required this.onSubmitted,
    this.fieldKey,
  });

  /// The search pill's key (`kTtcDoorSearchKey`, which tests find).
  final Key? fieldKey;

  final TtcFocusPage page;
  final V2Palette p;

  /// The door's pastel: the ground until the art's own colour is known, and
  /// the ground behind the drawn mark when there is no picture at all.
  final Color tint;

  /// `bracket.label`: the exact words on the tile that opened this door.
  final String eyebrow;
  final Bracket bracket;
  final PvLiveSearch search;
  final ValueChanged<String> onSubmitted;

  @override
  State<TtcDoorHero> createState() => _TtcDoorHeroState();
}

/// What is in the frame.
enum _ArtState { loading, art, photo, none }

class _TtcDoorHeroState extends State<TtcDoorHero> {
  _ArtState _state = _ArtState.loading;
  ImageProvider? _shown;
  Color? _edge;

  ImageStream? _stream;
  ImageStreamListener? _listener;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started) {
      _started = true;
      _tryArt();
    }
  }

  @override
  void didUpdateWidget(covariant TtcDoorHero old) {
    super.didUpdateWidget(old);
    if (old.bracket.id != widget.bracket.id ||
        old.page.heroImageUrl != widget.page.heroImageUrl) {
      _state = _ArtState.loading;
      _shown = null;
      _edge = null;
      _tryArt();
    }
  }

  @override
  void dispose() {
    _stop();
    super.dispose();
  }

  void _stop() {
    if (_stream != null && _listener != null) {
      _stream!.removeListener(_listener!);
    }
    _stream = null;
    _listener = null;
  }

  /// Decoded no wider than the frame on this screen: a 1536-wide picture on
  /// a 1080-pixel phone costs a third less memory and looks the same.
  ImageProvider _sized(ImageProvider raw) {
    final mq = MediaQuery.maybeOf(context);
    final w = math.min(mq?.size.width ?? 400, kTtcDoorHeroArtMaxWidth);
    final px = (w * (mq?.devicePixelRatio ?? 2)).round();
    return ResizeImage.resizeIfNeeded(px > 0 ? px : null, null, raw);
  }

  /// The art first, then the door's photograph, then the drawn mark.
  void _tryArt() {
    final asset = ttcDoorHeroArtAsset(widget.bracket.id);
    if (asset == null) {
      _tryPhoto();
      return;
    }
    _resolve(_sized(AssetImage(asset)), _ArtState.art, onFail: _tryPhoto);
  }

  void _tryPhoto() {
    final url = widget.page.heroImageUrl;
    if (url == null) {
      if (mounted) setState(() => _state = _ArtState.none);
      return;
    }
    _resolve(
      _sized(NetworkImage(url)),
      _ArtState.photo,
      onFail: () {
        if (mounted) setState(() => _state = _ArtState.none);
      },
    );
  }

  void _resolve(
    ImageProvider provider,
    _ArtState kind, {
    required VoidCallback onFail,
  }) {
    _stop();
    final stream = provider.resolve(createLocalImageConfiguration(context));
    late final ImageStreamListener listener;
    listener = ImageStreamListener(
      (info, _) {
        stream.removeListener(listener);
        if (identical(_listener, listener)) {
          _stream = null;
          _listener = null;
        }
        if (!mounted) {
          info.dispose();
          return;
        }
        setState(() {
          _state = kind;
          _shown = provider;
          _edge = _edgeCache[provider];
        });
        if (_edge != null) {
          info.dispose();
          return;
        }
        _sampleLeftEdge(info.image).then((c) {
          info.dispose();
          if (c == null) return;
          _edgeCache[provider] = c;
          if (mounted && identical(_shown, provider)) {
            setState(() => _edge = c);
          }
        }, onError: (Object _) => info.dispose());
      },
      onError: (Object _, StackTrace? _) {
        stream.removeListener(listener);
        if (identical(_listener, listener)) {
          _stream = null;
          _listener = null;
        }
        if (mounted) onFail();
      },
    );
    _stream = stream;
    _listener = listener;
    stream.addListener(listener);
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final ink = p.ink1;
    final ground = ttcDoorHeroGround(_edge ?? widget.tint, ink);
    final top = MediaQuery.paddingOf(context).top;
    final title = widget.page.heroTitle ?? widget.eyebrow;
    final blurb = widget.page.heroBlurb ?? widget.page.intro;

    final words = PvLiveSearchWords(
      search: widget.search,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.eyebrow.toUpperCase(),
            key: kTtcDoorHeroEyebrowKey,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            // Ink, not grey: the contrast rule (2026-09-29).
            style: pvManrope(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
              color: ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            key: kTtcDoorHeroTitleKey,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: pvFraunces(
              fontSize: 27,
              fontWeight: FontWeight.w600,
              height: 1.15,
              letterSpacing: -0.6,
              color: ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            blurb,
            key: kTtcDoorHeroIntroKey,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: pvManrope(fontSize: 14, height: 1.45, color: ink),
          ),
        ],
      ),
    );

    // The same white pill as Learn's header, with the door's name in it.
    final field = PvLiveSearchField(
      key: widget.fieldKey,
      search: widget.search,
      p: p,
      hint: 'Search ${widget.eyebrow}',
      onSubmitted: widget.onSubmitted,
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // ---- one flat ground, behind the status bar, the frame's letterbox
        // and the words, running on under the sheet's rounded corners -------
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: -kTtcDoorHeroBleed,
          child: AnimatedContainer(
            key: kTtcDoorHeroGroundKey,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            color: ground,
          ),
        ),

        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: top),
            // ---- the art, whole ------------------------------------------
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: kTtcDoorHeroArtMaxWidth,
                ),
                child: AspectRatio(
                  key: kTtcDoorHeroArtKey,
                  aspectRatio: kTtcDoorHeroArtAspect,
                  child: _frame(p),
                ),
              ),
            ),
            // ---- the words and the search, at the zone's foot ------------
            Stack(
              alignment: Alignment.bottomLeft,
              children: [
                const SizedBox(
                  height: kTtcDoorHeroTextZone,
                  width: double.infinity,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    kPvDoorGutter,
                    kTtcDoorHeroTopGap,
                    kPvDoorGutter,
                    kTtcDoorHeroFootGap,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      words,
                      const SizedBox(height: kTtcDoorHeroSearchGap),
                      field,
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),

        // ---- back, on the art's plain top-left corner ----------------------
        Positioned(
          top: top + 10,
          left: 14,
          child: Semantics(
            button: true,
            label: 'Back',
            child: Material(
              color: Colors.white.withValues(alpha: 0.72),
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => Navigator.of(context).maybePop(),
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(Icons.arrow_back_rounded, size: 20, color: ink),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// The picture, contained, never cropped; the drawn mark when there is no
  /// picture; the ground alone while one loads.
  Widget _frame(V2Palette p) {
    switch (_state) {
      case _ArtState.art:
      case _ArtState.photo:
        return Image(
          image: _shown!,
          // ⚠️ CONTAIN, NEVER COVER (the lead, 2026-09-29): cover in a frame
          // of another shape zoomed the art and threw away its subject.
          fit: BoxFit.contain,
          alignment: Alignment.center,
          gaplessPlayback: true,
          errorBuilder: (_, _, _) => const SizedBox.shrink(),
        );
      case _ArtState.none:
        final mark = bracketMarkFor(widget.bracket.id);
        if (mark == null) return const SizedBox.shrink();
        return Align(
          alignment: const Alignment(0.7, 0.2),
          child: FractionallySizedBox(
            widthFactor: 0.42,
            child: AspectRatio(
              aspectRatio: 1,
              child: V3BracketArt(mark: mark, tint: widget.tint),
            ),
          ),
        );
      case _ArtState.loading:
        return const SizedBox.shrink();
    }
  }
}
