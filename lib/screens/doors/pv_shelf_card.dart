// =============================================================================
//  PvShelfCard — the pregnancy doors' one content card, in the trying-to-
//  conceive door format (2026-10-02)
// -----------------------------------------------------------------------------
//  The user: "make the door view of each door in pregnancy the same as TTC
//  doors; TTC doors have a new format, so follow that. For now keep the images
//  the pregnancy door hero has; update the UI of the pregnancy doors." And then,
//  with TTC's doors beside ours: "see how a tool is represented with that icon,
//  how an article, a video is ... apply the same on the pregnancy side so that
//  consistency is maintained ... keep the images of the pregnancy the way they
//  are; just apply the UI so a user can tell what each thing is."
//
//  A TTC door shelf is a rail of ONE card: a rounded picture a little under
//  square (Flo's proportion), a small white badge top-left saying what the
//  thing is, the title in two lines and one grey line under it (`TtcShelfCard`,
//  ttc_kind_cards.dart). This is that card, typed on a pregnancy tile.
//
//  ⚠️ THE PICTURE IS THE PREGNANCY CARD'S OWN, UNCHANGED. A photograph where the
//  tile has one, else the drawn mark it already carried on its tab's colour.
//  Only the IDENTIFICATION is TTC's: the badge by kind (a wrench, a document,
//  scales, a camera ...), the word and one fact on the grey line, a ₹ on what
//  costs money, a "Live 1:1" pill on a one-to-one session, and a film's mark.
//  What each card says is decided in `pv_shelf_spec.dart`.
//
//  ⚠️ A COPY OF THE LOOK, NOT OF THE CODE, AND WHY. `TtcShelfCard` is typed on
//  `TtcTile` and reads TTC's own lookups (its read images, its film lengths,
//  its consult roster). A pregnancy tile is a `PvDoorTile` with its own. Making
//  the TTC card generic would mean editing a 3,000-line file the TTC stage
//  depends on, to serve a stage it knows nothing about; the repo settled the
//  same question the same way for the rail, the hero and the engines (a mirror,
//  not a merge). So the numbers, icons and words are TTC's, and
//  `test/pv_door_ttc_format_test.dart` holds them equal so the two cannot drift.
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../../widgets/pv_feedback.dart';
import '../brackets/hub/hub_intent_art.dart';
import '../v2/v2_palette.dart';
import 'pv_shelf_spec.dart' show PvShelfKind;

/// A card's width: two and a bit across a 360-411dp phone, so the shelf says
/// "more this way" without a hint. TTC's own number.
const double kPvShelfCardWidth = 148;

/// The picture's height: a little under square, Flo's proportion.
const double kPvShelfPictureHeight = 128;

const double _kTitleSize = 14;
const double _kTitleLine = 1.25;
const double _kMetaSize = 12;
const double _kMetaLine = 1.3;

/// One height for a shelf, grown with the text size: the picture, the title
/// kept at two lines and the one grey line.
double pvShelfRailHeight(TextScaler s) =>
    (kPvShelfPictureHeight +
            8 +
            s.scale(_kTitleSize) * _kTitleLine * 2 +
            3 +
            s.scale(_kMetaSize) * _kMetaLine +
            4)
        .ceilToDouble();

/// The key on a card, by its title, so a test can find it.
Key pvShelfCardKey(String title) => ValueKey('pv-shelf-card-$title');

/// The key on a card's top-left badge.
Key pvShelfBadgeKey(String title) => ValueKey('pv-shelf-badge-$title');

/// The key on a card's grey line.
Key pvShelfLineKey(String title) => ValueKey('pv-shelf-line-$title');

/// The key on a one-to-one session's pill.
Key pvShelfLiveKey(String title) => ValueKey('pv-shelf-live-$title');

/// The word on a one-to-one session's pill, after a red dot (TTC's).
const String kPvShelfLive = 'Live 1:1';

/// The badge's icon for each kind: TTC's own (`ttcCardKindIcon`), so a tool is
/// a wrench on both sides of the app. Audio, game and plan are pregnancy's own.
IconData pvShelfKindIcon(PvShelfKind k) => switch (k) {
      PvShelfKind.tool => Icons.build_outlined,
      PvShelfKind.read => Icons.article_outlined,
      PvShelfKind.myth => Icons.balance_rounded,
      PvShelfKind.video => Icons.videocam_outlined,
      PvShelfKind.talk => Icons.forum_outlined,
      PvShelfKind.recipe => Icons.restaurant_outlined,
      PvShelfKind.audio => Icons.headphones_outlined,
      PvShelfKind.game => Icons.extension_outlined,
      PvShelfKind.plan => Icons.calendar_view_week_outlined,
    };

/// The word for each kind: TTC's own (`ttcCardKindWord`).
String pvShelfKindWord(PvShelfKind k) => switch (k) {
      PvShelfKind.tool => 'Tool',
      PvShelfKind.read => 'Article',
      PvShelfKind.myth => 'Myth or fact',
      PvShelfKind.video => 'Video',
      PvShelfKind.talk => 'Talk to an expert',
      PvShelfKind.recipe => 'Recipe',
      PvShelfKind.audio => 'Audio',
      PvShelfKind.game => 'Game',
      PvShelfKind.plan => 'Plan',
    };

class PvShelfCard extends StatelessWidget {
  const PvShelfCard({
    super.key,
    required this.p,
    required this.hue,
    required this.kind,
    required this.title,
    required this.onTap,
    this.fact,
    this.paid = false,
    this.live = false,
    this.mark,
    this.imageUrl,
    this.comingSoon = false,
    this.width = kPvShelfCardWidth,
  });

  final V2Palette p;

  /// The tab's hue: the drawn picture's colour.
  final double hue;

  /// What it is: the badge and the word.
  final PvShelfKind kind;
  final String title;

  /// The one fact after the word ("9 min read", "Weeks 14 to 27").
  final String? fact;

  /// A ₹ replaces the badge (something that costs money).
  final bool paid;

  /// A one-to-one session: TTC's red-dot pill, a format and never a presence.
  final bool live;

  /// The tile's drawn mark, for a card with no photograph.
  final IntentMark? mark;

  /// The photograph, when the tile has one.
  final String? imageUrl;

  /// Not made yet: the same card a shade back, and not tappable.
  final bool comingSoon;
  final VoidCallback onTap;
  final double width;

  Color get _ground => HSLColor.fromAHSL(1, hue % 360, 0.52, 0.9).toColor();
  Color get _artTint => HSLColor.fromAHSL(1, hue % 360, 0.6, 0.8).toColor();

  String get _line => [
        pvShelfKindWord(kind),
        if (fact != null && fact!.isNotEmpty) fact!,
      ].join(' · ');

  Widget _drawn() => ColoredBox(
        color: _ground,
        child: Center(
          child: FractionallySizedBox(
            widthFactor: 0.56,
            heightFactor: 0.56,
            child: mark != null
                ? HubIntentArt(mark: mark!, tint: _artTint)
                : Icon(pvShelfKindIcon(kind), size: 40, color: p.ink2),
          ),
        ),
      );

  Widget _picture() {
    final url = imageUrl;
    if (url == null || url.isEmpty) return _drawn();
    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: _ground),
        Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _drawn(),
        ),
      ],
    );
  }

  /// What it is, top left, on every card: the kind's own icon, or a ₹ where it
  /// costs money (TTC: at most two marks on a card, so the ₹ takes the badge's
  /// place rather than sitting beside it).
  Widget _badge() => Positioned(
        key: pvShelfBadgeKey(title),
        left: 7,
        top: 7,
        child: ExcludeSemantics(
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  blurRadius: 5,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Icon(
              paid ? Icons.currency_rupee_rounded : pvShelfKindIcon(kind),
              size: 15,
              color: p.ink1,
            ),
          ),
        ),
      );

  /// TTC's one-to-one pill: a red dot and "Live 1:1", bottom right.
  Widget _livePill() => Positioned(
        key: pvShelfLiveKey(title),
        right: 7,
        bottom: 7,
        child: Container(
          padding: const EdgeInsets.fromLTRB(6, 3, 7, 3),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 5,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: Color(0xFFE5484D),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              kPvShelfLive,
              textScaler: TextScaler.noScaling,
              style: pvManrope(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: p.ink1,
              ),
            ),
          ]),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final label = comingSoon ? '$title, ${pvShelfKindWord(kind)}, coming soon' : '$title, $_line';
    final film = kind == PvShelfKind.video;
    return Semantics(
      button: !comingSoon,
      label: label,
      excludeSemantics: true,
      child: Opacity(
        opacity: comingSoon ? 0.62 : 1,
        child: PvPress(
          child: InkWell(
            key: pvShelfCardKey(title),
            onTap: comingSoon ? null : onTap,
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: SizedBox(
                      width: width,
                      height: kPvShelfPictureHeight,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          _picture(),
                          // A film that plays is known by its play button
                          // (Flo's, as the TTC shelf draws it): the picture
                          // dimmed evenly so the white mark holds on any
                          // picture. None exists yet, so this is for the day
                          // one does.
                          if (film && !comingSoon) ...[
                            ColoredBox(
                                color: Colors.black.withValues(alpha: 0.30)),
                            const Center(
                              child: Icon(
                                Icons.play_arrow_rounded,
                                size: 52,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                      color: Color(0x66000000), blurRadius: 10),
                                ],
                              ),
                            ),
                          ],
                          if (comingSoon)
                            Positioned(
                              right: 6,
                              bottom: 6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.62),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Coming soon',
                                  style: pvManrope(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            )
                          else if (live)
                            _livePill(),
                          _badge(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: pvManrope(
                      fontSize: _kTitleSize,
                      height: _kTitleLine,
                      fontWeight: FontWeight.w600,
                      color: p.ink1,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _line,
                    key: pvShelfLineKey(title),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: pvManrope(
                      fontSize: _kMetaSize,
                      height: _kMetaLine,
                      fontWeight: FontWeight.w500,
                      color: p.ink3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
