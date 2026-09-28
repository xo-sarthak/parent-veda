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
import '../../../models/pv_read.dart';
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
    this.bodyWords = const {},
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

  /// Every word of the read behind the hit (D6, 2026-09-28): its sections,
  /// lists, tips, questions and answers. Searched after the title words and
  /// ranked last, so a title match always leads.
  final Set<String> bodyWords;
}

// =============================================================================
//  The words inside a read, and the names people search by (launch sanity D6,
//  L4, 2026-09-28)
// -----------------------------------------------------------------------------
//  "clomid" typed in Fertile window found nothing, although a read on that
//  door explains clomiphene; "duphaston" found nothing anywhere. Two causes:
//  the index held titles, blurbs and keywords only, never what a read SAYS,
//  and people in India search by the name on the strip (Clomid, Siphene,
//  Letroz, Duphaston, Susten), which a read written in plain words names by
//  its medicine (clomiphene, letrozole, progesterone).
//
//  So the index carries every word of the read behind a hit, and the query
//  carries its synonyms: a query word that starts one of [kTtcSearchSynonyms]'
//  keys also matches that key's words. The list is a lookup of names, not a
//  rule about medicine; it says nothing about which to take.
// =============================================================================

/// Brand and everyday names, each to the words our reads use. Lower case.
/// A query word of four letters or more that STARTS a key brings that key's
/// words with it ("clom" is enough for Clomid).
const Map<String, List<String>> kTtcSearchSynonyms = {
  // Ovulation tablets.
  'clomid': ['clomiphene', 'ovulation'],
  'clomiphene': ['clomid', 'ovulation'],
  'siphene': ['clomiphene', 'ovulation'],
  'fertyl': ['clomiphene', 'ovulation'],
  'ovamit': ['clomiphene', 'ovulation'],
  'letroz': ['letrozole', 'ovulation'],
  'femara': ['letrozole', 'ovulation'],
  'letrozole': ['ovulation'],
  // Progesterone support.
  'duphaston': ['dydrogesterone', 'progesterone'],
  'dydroboon': ['dydrogesterone', 'progesterone'],
  'dydrogesterone': ['progesterone'],
  'susten': ['progesterone'],
  'cyclogest': ['progesterone'],
  'utrogestan': ['progesterone'],
  'gestone': ['progesterone'],
  // Trigger injection and stimulation.
  'ovitrelle': ['trigger', 'hcg'],
  'pregnyl': ['trigger', 'hcg'],
  'gonal': ['stimulation', 'injections'],
  'menopur': ['stimulation', 'injections'],
  'foligraf': ['stimulation', 'injections'],
  // PCOS medicines and supplements.
  'glyciphage': ['metformin'],
  'glycomet': ['metformin'],
  'inofolic': ['inositol'],
  'myoinositol': ['inositol'],
  // Everyday words for clinic words.
  'insemination': ['iui'],
  'testtube': ['ivf'],
  'sperm': ['semen'],
  'semen': ['sperm'],
  'pregnancy': ['test', 'pregnant'],
  'miscarriage': ['loss'],
};

/// A query word and the words it also stands for.
Set<String> ttcSearchAlternatives(String w) {
  final out = {w};
  if (w.length < 4) return out;
  for (final e in kTtcSearchSynonyms.entries) {
    if (e.key.startsWith(w) || w.startsWith(e.key)) out.addAll(e.value);
  }
  return out;
}

/// Every word a read says, in both languages, lower case, split the way the
/// index splits. Cached by id: the library is static for the app's life.
Set<String> ttcReadWords(PvRead r) =>
    _kReadWords.putIfAbsent(r.id, () {
      final b = StringBuffer();
      void add(LocalizedText? t) {
        if (t == null) return;
        b
          ..write(t.en)
          ..write(' ')
          ..write(t.hi)
          ..write(' ');
      }

      add(r.shortAnswer);
      add(r.scaleSetter);
      add(r.teaser);
      for (final sec in r.sections) {
        add(sec.heading);
        add(sec.summary);
        sec.paragraphs.forEach(add);
        sec.bullets.forEach(add);
        add(sec.tip?.title);
        add(sec.tip?.body);
        add(sec.mythFact?.myth);
        add(sec.mythFact?.fact);
        add(sec.callout?.title);
        add(sec.callout?.body);
      }
      for (final f in r.faqs) {
        add(f.question);
        add(f.answer);
      }
      return {
        for (final w in b.toString().toLowerCase().split(_kSplit))
          if (w.length > 1) w,
      };
    });

final Map<String, Set<String>> _kReadWords = {};

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
      final read = switch (_readIdOf(t)) {
        final id? => ttcReadById(id),
        _ => null,
      };
      hits.add(
        TtcDoorHit._(
          title: t.title,
          blurb: t.blurb,
          meta: g == null ? door : '$door · ${g.label}',
          icon: iconForFormat(t.format),
          tile: t,
          // A myth's own two halves are its body (D6).
          extra: [
            ...t.keywords,
            if (t case TtcMythTile(:final myth, :final fact)) ...[myth, fact],
          ],
          // ⚠️ NOT WHILE THE SHARED-PHONE SWITCH IS ON: another read's text
          // can mention "lubricant" in passing, and a word she has chosen not
          // to see must not bring back a row. Titles only, as before D6.
          bodyWords: read == null || hide ? const {} : ttcReadWords(read),
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
        bodyWords: hide ? const {} : ttcReadWords(r),
      ),
    );
  }
  return hits;
}

/// Rank: every query word must start a word; a title that starts with the
/// query outranks one that contains it, which outranks a blurb match.
/// Ties keep index order, so this door's tiles come before the library.
///
/// D6 (2026-09-28): each query word also matches its synonyms
/// ([ttcSearchAlternatives]), and a word may be found in the read's own
/// text; a hit found only that way ranks 4, after every title and blurb
/// match. Kept for revert, the title-and-blurb-only rule:
///   if (!words.every((w) => _matches(h._words, w))) continue;
List<TtcDoorHit> ttcDoorSearch(String query, List<TtcDoorHit> index) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return const [];
  // Split the way the index splits (D6, 2026-09-28), so "two-week" is two
  // words on both sides. Kept for revert: q.split(RegExp(r'\s+')).
  final words = [
    for (final w in q.split(_kSplit))
      if (w.isNotEmpty) w,
  ];
  if (words.isEmpty) return const [];
  final alts = [for (final w in words) ttcSearchAlternatives(w)];
  final scored = <(int, int, TtcDoorHit)>[];
  for (var i = 0; i < index.length; i++) {
    final h = index[i];
    var inBody = false;
    var all = true;
    for (final a in alts) {
      if (a.any((w) => _matches(h._words, w))) continue;
      // The read's text, for words of three letters or more, so "a" or
      // "is" does not bring back the whole library.
      if (a.any((w) => w.length >= 3 && h.bodyWords.any((b) => b.startsWith(w)))) {
        inBody = true;
        continue;
      }
      all = false;
      break;
    }
    if (!all) continue;
    final t = h.title.toLowerCase();
    final rank = inBody
        ? 4
        : t.startsWith(q)
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
