// =============================================================================
//  TTC door search — the index, the match and the row behind a door's field
// -----------------------------------------------------------------------------
//  The flow (idle, focused, typing, Back twice) is the shared one,
//  `PvLiveSearch` (lib/screens/doors/pv_live_search.dart), and is not copied.
//  What a door supplies is its own index, its own row, its recents and its
//  way on. This file is those four for Trying to Conceive:
//
//    index    this door's tiles first ("PCOS · What helps"), then every TTC
//             read the door does not already hold, labelled with the door
//             that owns it. So "HSG" typed in Fertile window still finds the
//             IVF door's piece, and says where it lives.
//    match    a query word matches when it STARTS a word, exactly as the
//             pregnancy search does ("nt" finds "NT scan", not "appointment").
//    recents  `TtcSearchStore`, its own key (`ttc_search_recent`).
//    way on   Ask Veda, with the words already typed. TTC has no stage-wide
//             search screen, so there is no "Search everywhere" row: a row
//             that opened nothing would teach her that rows do nothing.
//
//  ⚠️ MIRRORED FROM `pv_search_screen.dart`, NOT SHARED. `PvSearchHit` is
//  typed on the pregnancy door model and opens pregnancy routes; this stage
//  must not appear in that index (the pregnancy search would offer TTC pieces
//  to a pregnant mother).
// =============================================================================

import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../../localization/app_language.dart';
import '../../../models/bracket.dart';
import '../../../theme/pv_fonts.dart';
import '../../../ttc/ttc_focus_data.dart';
import '../../../ttc/ttc_reads_data.dart';
import '../../../widgets/pv_feedback.dart';
import '../../../services/bracket_resolver.dart' show bracketById;
import '../../../services/ttc_search_store.dart';
import '../../../ttc/ttc_content_prefs.dart';
import '../../doors/pv_live_search.dart' show PvLiveSearch;
import '../../v2/v2_palette.dart';
import '../ttc_focus_screen.dart'
    show iconForFormat, openTtcFocusTile, openTtcArticle;
// The one filter for the shared-phone switch. An import cycle with the door
// screen, which Dart allows; the alternative was a second copy of the rule.
import 'ttc_door_screen.dart' show ttcDoorVisiblePage;

Key ttcDoorSearchHitKey(int i) => ValueKey('ttc-door-search-hit-$i');

/// One searchable thing: a tile on this door, or a read from the library.
class TtcDoorHit {
  TtcDoorHit._({
    required this.title,
    required this.blurb,
    required this.meta,
    required this.icon,
    this.tile,
    this.readId,
    List<String> extra = const [],
  }) : _words = '$title $blurb $meta ${extra.join(' ')}'.toLowerCase().split(
         _kSplit,
       );

  final String title;
  final String blurb;

  /// Where the tap lands: "PCOS · What helps", or the owning door of a read.
  final String meta;
  final IconData icon;

  /// A tile on this door. Opens through `openTtcFocusTile`, the one opener.
  final TtcTile? tile;

  /// A library read not on this door. Opens in the one reader.
  final String? readId;

  final List<String> _words;
}

final RegExp _kSplit = RegExp(r'[^a-z0-9]+');

bool _matches(List<String> words, String q) =>
    words.any((w) => w.startsWith(q));

/// The read ids a tile opens, so a read already on the door is not listed a
/// second time from the library.
String? _readIdOf(TtcTile t) => switch (t) {
  TtcArticleTile(:final readId) => readId,
  TtcGuideTile(:final readId) => readId,
  _ => null,
};

/// "PCOS · Understand" for the first door tab that holds [readId], or null.
String? _homeOf(String readId, AppLanguage lang) {
  for (final page in kTtcFocusPages) {
    final b = bracketById(page.bracketId);
    for (final s in page.sections) {
      if (!s.tiles.any((t) => _readIdOf(t) == readId)) continue;
      final g = page.groups?.where((g) => g.id == s.group).firstOrNull;
      final door = b?.label.of(lang) ?? '';
      return g == null ? door : '$door · ${g.label}';
    }
  }
  return null;
}

/// Everything the field on [page] searches, in the order ties are broken:
/// this door's own tiles first, then the rest of the TTC library.
///
/// ⚠️ [hideIntimate] DEFAULTS TO HER SAVED CHOICE, NOT TO FALSE. A caller that
/// forgets the argument gets the safe answer: with "Hide sex and intimacy
/// content" on, the Sex and closeness tiles and every read in
/// `kTtcIntimateReadIds` are left out of both halves of the index, so typing
/// the word cannot bring back what the tab took away.
List<TtcDoorHit> ttcDoorSearchIndex(
  TtcFocusPage page,
  Bracket bracket,
  AppLanguage lang, {
  bool? hideIntimate,
}) {
  final hide = hideIntimate ?? TtcContentPrefs.instance.hideIntimate;
  final visible = ttcDoorVisiblePage(page, hideIntimate: hide);
  final door = bracket.label.of(lang);
  final onDoor = <String>{};
  final hits = <TtcDoorHit>[];
  final groups = visible.groups ?? const <TtcFocusGroup>[];
  for (final s in visible.sections) {
    final g = groups.where((g) => g.id == s.group).firstOrNull;
    for (final t in s.tiles) {
      if (_readIdOf(t) case final id?) onDoor.add(id);
      hits.add(
        TtcDoorHit._(
          title: t.title,
          blurb: t.blurb,
          meta: g == null ? door : '$door · ${g.label}',
          icon: iconForFormat(t.format),
          tile: t,
          extra: t.keywords,
        ),
      );
    }
  }
  for (final r in kTtcReads) {
    if (onDoor.contains(r.id)) continue;
    if (hide && kTtcIntimateReadIds.contains(r.id)) continue;
    hits.add(
      TtcDoorHit._(
        title: r.title.of(lang),
        blurb: r.teaser.of(lang),
        meta: _homeOf(r.id, lang) ?? 'Article',
        icon: Icons.article_outlined,
        readId: r.id,
        // The English words too, so a Hinglish reader typing "folic" still
        // finds the piece.
        extra: [r.title.en, r.kicker.of(lang)],
      ),
    );
  }
  return hits;
}

/// Rank: every query word must start a word; a title that starts with the
/// query outranks one that contains it, which outranks a blurb match.
/// Ties keep index order, so this door's tiles come before the library.
List<TtcDoorHit> ttcDoorSearch(String query, List<TtcDoorHit> index) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return const [];
  final words = q.split(RegExp(r'\s+'));
  final scored = <(int, int, TtcDoorHit)>[];
  for (var i = 0; i < index.length; i++) {
    final h = index[i];
    if (!words.every((w) => _matches(h._words, w))) continue;
    final t = h.title.toLowerCase();
    final rank = t.startsWith(q)
        ? 0
        : t.contains(q)
        ? 1
        : words.every(t.contains)
        ? 2
        : 3;
    scored.add((rank, i, h));
  }
  scored.sort((a, b) {
    final r = a.$1.compareTo(b.$1);
    return r != 0 ? r : a.$2.compareTo(b.$2);
  });
  return [for (final s in scored) s.$3];
}

/// Open a hit and remember the words that found it.
void openTtcDoorHit(
  BuildContext context,
  TtcDoorHit h, {
  required double hue,
  String? query,
}) {
  pvCommitFeedback();
  if (query != null && query.trim().isNotEmpty) {
    TtcSearchStore.instance.remember(query);
  }
  if (h.tile case final t?) {
    openTtcFocusTile(context, t, hue);
    return;
  }
  if (h.readId case final id?) openTtcArticle(context, id, hue: hue);
}

/// One result row: the format in a neutral well, the title, one grey line,
/// where it lives, a chevron. The same object as the pregnancy search row.
class TtcDoorHitRow extends StatelessWidget {
  const TtcDoorHitRow({
    super.key,
    required this.p,
    required this.hit,
    required this.onTap,
  });

  final V2Palette p;
  final TtcDoorHit hit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final h = hit;
    final well = Color.alphaBlend(p.ink1.withValues(alpha: 0.06), p.surface);
    return PvPress(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: well,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(h.icon, size: 20, color: p.ink2),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      h.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: pvManrope(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                        color: p.ink1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      h.blurb,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: pvManrope(
                        fontSize: 12.5,
                        height: 1.35,
                        color: p.ink2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      h.meta,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: pvManrope(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: p.ink3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(top: 9),
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: p.ink3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
//  TtcDoorGlassSearchField — the door's field, as glass on the photograph
// -----------------------------------------------------------------------------
//  The user, walking build 13 (2026-09-27): the white search bar was "too
//  wide/loud on the photo, maybe a little transparent". A solid white stadium
//  48 high is the brightest object in the hero, brighter than the headline.
//
//  So on a photograph the field is glass: the photo blurred behind it, white
//  at low opacity over that, a hairline of white, white type and icon, 44
//  high. It still reads as a search field (the stadium, the magnifier and the
//  "Search ..." hint are all there) and it keeps every behaviour, because it
//  is the same `PvLiveSearch` controller, focus node and `fieldKey` the shared
//  `PvLiveSearchField` uses: focus still rides it to the top, typing still
//  fills the sheet, Back still releases it twice.
//
//  ⚠️ A TTC COPY, NOT AN EDIT TO `PvLiveSearchField`. The pregnancy doors
//  use that field and are signed off. Where a TTC door has no photograph
//  the door falls back to the shared solid field, because white type on the
//  pale tinted field would not read.
//
//  Mobbin: Slopes' "Explore" search, a frosted stadium over a map, is the
//  shape (https://mobbin.com/screens/12227f99-6404-4736-8d64-4ef2474e6bad).
// =============================================================================

class TtcDoorGlassSearchField extends StatelessWidget {
  const TtcDoorGlassSearchField({
    super.key,
    required this.search,
    required this.hint,
    this.onSubmitted,
  });

  final PvLiveSearch search;
  final String hint;
  final ValueChanged<String>? onSubmitted;

  static const double height = 44;

  @override
  Widget build(BuildContext context) {
    final soft = Colors.white.withValues(alpha: 0.82);
    return Row(
      key: search.fieldKey,
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                height: height,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.38),
                  ),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 14),
                    Icon(Icons.search_rounded, size: 18, color: soft),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: search.ctl,
                        focusNode: search.focus,
                        textInputAction: TextInputAction.search,
                        onSubmitted: onSubmitted,
                        style: pvManrope(fontSize: 14.5, color: Colors.white),
                        cursorColor: Colors.white,
                        // Every border off, as the shared field learnt: the
                        // theme's decoration draws a box inside the stadium.
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: hint,
                          hintStyle: pvManrope(fontSize: 14.5, color: soft),
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
                    if (search.searching)
                      IconButton(
                        tooltip: 'Clear',
                        onPressed: () {
                          pvCommitFeedback();
                          search.ctl.clear();
                        },
                        icon: Icon(Icons.close_rounded, size: 18, color: soft),
                        visualDensity: VisualDensity.compact,
                      )
                    else
                      const SizedBox(width: 14),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
