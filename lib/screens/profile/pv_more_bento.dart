// =============================================================================
//  More — the bento under the identity card (trying to conceive, 2026-09-28)
// -----------------------------------------------------------------------------
//  The user: "the last option in bottom navigation pill should be 'more' not
//  you, and in that ... for each heading follow bento design or something
//  like CRED does, then when you click on each tab you see what's listed for
//  it." So every heading that sat on the You screen (Your health, Your things,
//  Your app, Your journey, Family, Bookings and orders, Preferences, Support,
//  Account) is ONE tile here, and a tile opens a page that lists its rows,
//  the same rows with the same destinations as before.
//
//  ⚠️ MORE HOLDS EVERYTHING THAT IS NOT A TOOL (2026-09-28, the user: "under
//  Tools I should only be seeing tools ... the More button should have
//  everything else that was extra inside Tools, except tools"). A tenth
//  tile, "Experts and courses", holds Talk to an expert, Courses and the
//  programmes catalogue; "Your journey" gained the journey map. Records and
//  the treatment round, which are tools, left for Tools. The definition of a
//  tool and the classification are in ttc_tools_screen.dart
//  (`kTtcToolKinds`); test/ttc_tools_only_tools_test.dart holds both sides.
//
//  WHAT WAS TAKEN FROM WHERE (Mobbin, 2026-09-28):
//
//   * CRED, Explore Club — one tall tile on the left beside two stacked on
//     the right, the mixed-size rhythm the user named. Our first row.
//     https://mobbin.com/screens/a86d33ae-922e-4de5-b00d-4091c93a4c37
//   * CRED, explore CRED — line icons in round wells and a short label; a
//     heading is a door, not a list.
//     https://mobbin.com/screens/a2ceda47-8542-4ef8-840e-5faae3d72b54
//     https://mobbin.com/screens/221e85e8-4b31-4c47-b2d5-93122764f1e6
//   * CRED, help centre — a category tile opens the list of what is in it.
//     https://mobbin.com/screens/4ac796c3-8c58-4436-b174-5a81e3892b6e
//   * PayPal, Do more with your money — cards of two sizes that carry a live
//     value under the title. Our status line ("2 saved · 1 order").
//     https://mobbin.com/screens/9657960b-ebe4-4418-ab0d-ca6cc1f3ef1b
//   * Remote, More — the tab titled More, two tinted tiles to a row and one
//     full-width tile to close; the version line under it all.
//     https://mobbin.com/screens/cd0d67d9-aced-4b05-be4c-1a13010c617e
//   * Satispay, Account — tiles of unequal size, each a soft tint of its own.
//     https://mobbin.com/screens/fab77859-0801-4f75-a3c2-edef649b9ff9
//   * Etsy, You — the identity stays above the tiles.
//     https://mobbin.com/screens/f84c8b88-195c-4935-8b6f-a9a46493b51f
//   * Amazon Alexa, More — the grid first, then the plain rows (our
//     Developer section, under the grid).
//     https://mobbin.com/screens/68956218-9f07-48c9-9b23-2998066a852f
//   * Revolut, profile menu — the page behind a tile: one card of rows with
//     hairlines, nothing else on it.
//     https://mobbin.com/screens/ff9a098a-d3c2-4a8f-bd86-8714c55af083
//
//  WHAT WAS NOT TAKEN: CRED's black ground and 3D renders (our base UI is a
//  white ground with ink, Newsreader and Manrope, docs/DESIGN-SYSTEM.md), and
//  PayPal's saturated blue cards. Tiles here are a soft tint per group with a
//  hairline, no heavy shadow and no purple.
//
//  ⚠️ IT MUST HOLD AT 360dp AND AT LARGE TEXT. The rhythm below (a tall tile
//  beside two, then a wide one, then pairs) is drawn only when the text is
//  near its normal size and the column is wide enough; otherwise every tile
//  takes the full width, one under another. No tile has a fixed height, so
//  nothing can clip. `test/pv_more_bento_test.dart` holds both.
//
//  ⚠️ ONE BUTTON PER TILE for a screen reader: its title, its caption and its
//  state, read as one, with the tap on it (Semantics below).
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../auth/onboarding/onboarding_chrome.dart' show ObPress;
import '../products/pv_store_chrome.dart'
    show kPvLine, pvStorePalette, PvRoundIcon;

/// One tile of the bento.
class PvBentoTileData {
  const PvBentoTileData({
    required this.id,
    required this.title,
    required this.caption,
    required this.icon,
    required this.onTap,
    this.hue,
    this.status,
    this.dot,
    this.listen,
  });

  /// Stable, for keys and route names ("health", "things").
  final String id;
  final String title;

  /// One line naming what is inside, so she knows before she taps.
  final String caption;
  final IconData icon;
  final VoidCallback onTap;

  /// The tint. Null draws the neutral tile (Account).
  final double? hue;

  /// A live state under the caption, or null.
  final String? Function()? status;

  /// A dot beside the icon, never a number.
  final bool Function()? dot;

  /// What [status] and [dot] read.
  final Listenable? listen;
}

/// The tile's ground: a soft tint of its hue, lighter than the home's block
/// tints (`v2BlockTint`) because nine of them sit together here.
Color pvBentoTint(double? hue) => hue == null
    ? const Color(0xFFF6F6F4)
    : HSLColor.fromAHSL(1, hue, 0.38, 0.955).toColor();

/// The tile's ink for its icon and state line.
Color pvBentoInk(double? hue) => hue == null
    ? const Color(0xFF4A4A48)
    : HSLColor.fromAHSL(1, hue, 0.34, 0.34).toColor();

enum _Shape { tall, small, wide, half }

/// The tile. Title in Newsreader, caption in Manrope, a line icon in a white
/// well; the tall tile also carries the icon large and faint in its corner,
/// the drawing CRED's club tiles carry as a photograph.
class _PvBentoTile extends StatelessWidget {
  const _PvBentoTile(this.data, this.shape);
  final PvBentoTileData data;
  final _Shape shape;

  @override
  Widget build(BuildContext context) {
    final l = data.listen;
    if (l == null) return _tile(context);
    return ListenableBuilder(listenable: l, builder: (c, _) => _tile(c));
  }

  Widget _tile(BuildContext context) {
    final p = pvStorePalette;
    final tint = pvBentoTint(data.hue);
    final ink = pvBentoInk(data.hue);
    final status = data.status?.call();
    final dot = data.dot?.call() == true;
    final tall = shape == _Shape.tall;
    final radius = BorderRadius.circular(20);
    final label = [
      data.title,
      data.caption,
      ?status,
      if (dot) 'Something new inside',
    ].join('. ');
    return Semantics(
      key: ValueKey('pv_more_tile_${data.id}'),
      container: true,
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: data.onTap,
      child: ObPress(
        child: Material(
          color: tint,
          shape: RoundedRectangleBorder(
            borderRadius: radius,
            side: const BorderSide(color: kPvLine),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: data.onTap,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: tall ? 196 : 0),
              child: Stack(
                children: [
                  if (tall)
                    Positioned(
                      right: -10,
                      bottom: -12,
                      child: Icon(
                        data.icon,
                        size: 104,
                        color: ink.withValues(alpha: 0.10),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: kPvLine),
                              ),
                              child: Icon(data.icon, size: 19, color: ink),
                            ),
                            if (dot) ...[
                              const SizedBox(width: 8),
                              Container(
                                key: const ValueKey('pv_more_tile_dot'),
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  // The TTC coral, the home envelope's dot.
                                  color: Color(0xFFFF5A79),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                        SizedBox(height: tall ? 28 : 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data.title,
                              style: pvFraunces(
                                fontSize: tall ? 21 : 17,
                                fontWeight: FontWeight.w500,
                                height: 1.15,
                                color: p.ink1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              data.caption,
                              style: pvManrope(
                                fontSize: 12.5,
                                height: 1.35,
                                color: p.ink2,
                              ),
                            ),
                            if (status != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                status,
                                style: pvManrope(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  height: 1.3,
                                  color: ink,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
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

/// The grid. The rhythm, in order: the first tile tall beside the next two
/// stacked (CRED's club row), the fourth full width, then pairs, and a last
/// odd tile full width. Below 1.3x text or under 300dp of column, one tile
/// per line.
class PvBentoGrid extends StatelessWidget {
  const PvBentoGrid({super.key, required this.tiles});
  final List<PvBentoTileData> tiles;

  static const double _gap = 10;

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context).scale(10) / 10;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: LayoutBuilder(
        builder: (context, box) {
          final single = scale > 1.3 || box.maxWidth < 300;
          final rows = <Widget>[];
          void add(Widget w) {
            if (rows.isNotEmpty) rows.add(const SizedBox(height: _gap));
            rows.add(w);
          }

          if (single) {
            for (var i = 0; i < tiles.length; i++) {
              add(_PvBentoTile(tiles[i], i == 0 ? _Shape.tall : _Shape.wide));
            }
          } else {
            var i = 0;
            if (tiles.length >= 3) {
              add(
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 11,
                        child: _PvBentoTile(tiles[0], _Shape.tall),
                      ),
                      const SizedBox(width: _gap),
                      Expanded(
                        flex: 10,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: _PvBentoTile(tiles[1], _Shape.small),
                            ),
                            const SizedBox(height: _gap),
                            Expanded(
                              child: _PvBentoTile(tiles[2], _Shape.small),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
              i = 3;
            }
            if (i < tiles.length && i == 3) {
              add(_PvBentoTile(tiles[i], _Shape.wide));
              i++;
            }
            while (i < tiles.length) {
              if (i + 1 < tiles.length) {
                add(
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: _PvBentoTile(tiles[i], _Shape.half)),
                        const SizedBox(width: _gap),
                        Expanded(
                          child: _PvBentoTile(tiles[i + 1], _Shape.half),
                        ),
                      ],
                    ),
                  ),
                );
                i += 2;
              } else {
                add(_PvBentoTile(tiles[i], _Shape.wide));
                i++;
              }
            }
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: rows,
          );
        },
      ),
    );
  }
}

/// The page behind a tile: its title, the caption as a quiet lead, and its
/// rows in one white card with hairlines (Revolut's menu). Nothing else, so
/// what she tapped is what she sees.
class PvMoreGroupScreen extends StatelessWidget {
  const PvMoreGroupScreen({
    super.key,
    required this.title,
    required this.caption,
    required this.rows,
    required this.listen,
  });
  final String title;
  final String caption;

  /// Built on every repaint, so a row's value is always the current one.
  final List<Widget> Function() rows;

  /// The You screen's stores and its own state, merged: a switch flipped on
  /// this page repaints this page.
  final Listenable listen;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return Scaffold(
      backgroundColor: p.ground,
      body: ListenableBuilder(
        listenable: listen,
        builder: (context, _) {
          final children = rows();
          return ListView(
            padding: EdgeInsets.fromLTRB(
              0,
              MediaQuery.of(context).padding.top + 10,
              0,
              MediaQuery.of(context).padding.bottom + 40,
            ),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    PvRoundIcon(
                      icon: Icons.arrow_back_rounded,
                      // Named for a screen reader (2026-09-28).
                      semanticLabel: 'Back to More',
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: pvFraunces(
                          fontSize: 26,
                          fontWeight: FontWeight.w500,
                          color: p.ink1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Text(
                  caption,
                  style: pvManrope(fontSize: 13, height: 1.4, color: p.ink3),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: kPvLine),
                  ),
                  child: Column(
                    children: [
                      for (var i = 0; i < children.length; i++) ...[
                        if (i > 0)
                          const Divider(
                            height: 1,
                            thickness: 1,
                            color: kPvLine,
                            indent: 16,
                            endIndent: 16,
                          ),
                        children[i],
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
