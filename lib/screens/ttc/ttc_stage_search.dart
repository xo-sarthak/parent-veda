// =============================================================================
//  TTC stage search: everything on the trying-to-conceive side, found as she
//  types in Ask Veda (2026-09-30)
// -----------------------------------------------------------------------------
//  The user: "if I'm in trying to conceive and I click the Ask Veda button, I
//  can search for anything inside the trying to conceive side of the app …
//  the range should be within the side of the app you are in."
//
//  So Ask Veda is two things on one screen:
//    · THIS: an instant, on-the-phone search of the stage's own things (its
//      tools, articles, videos, Can I… answers, doors and products). It works
//      offline and costs nothing, and every hit opens its real screen.
//    · The Ask Veda answer, one tap below, from the service, which since the
//      same day grounds its answer and its pointers in trying-to-conceive
//      content only (parentveda-askveda, app/answer.py `scope_domain`).
//
//  Matching is the Tools hub's own word-prefix rule: every word she typed must
//  start a word of the item. A title match ranks above a match in the
//  supporting line, so "chai" finds "Can I drink chai and coffee?" before a
//  read that mentions chai in its summary.
// =============================================================================

import 'package:flutter/material.dart';

import '../../services/bracket_resolver.dart';
import '../../ttc/ttc_can_i_data.dart';
import '../../ttc/ttc_focus_data.dart';
import '../../ttc/ttc_products_data.dart';
import '../../ttc/ttc_reads_data.dart';
import 'ttc_all_videos_screen.dart' show ttcAllFilms;
import 'ttc_can_i_screen.dart';
import 'ttc_focus_screen.dart' show openTtcArticle, openTtcFocusTile;
import 'ttc_shop_v3.dart' show openTtcProductPage;
import 'ttc_surface_router.dart' show openTtcSurface;
import 'ttc_tools_screen.dart' show ttcToolsMatching;

/// The kinds of thing the search finds, in the order the screen groups them.
enum TtcStageHitKind { tool, article, video, canI, door, product }

extension TtcStageHitKindCopy on TtcStageHitKind {
  /// The group's heading on the screen.
  String get heading => switch (this) {
        TtcStageHitKind.tool => 'Tools',
        TtcStageHitKind.article => 'Articles',
        TtcStageHitKind.video => 'Videos',
        TtcStageHitKind.canI => 'Can I…?',
        TtcStageHitKind.door => 'Topics',
        TtcStageHitKind.product => 'Products',
      };

  IconData get icon => switch (this) {
        TtcStageHitKind.tool => Icons.build_outlined,
        TtcStageHitKind.article => Icons.article_outlined,
        TtcStageHitKind.video => Icons.play_circle_outline_rounded,
        TtcStageHitKind.canI => Icons.help_outline_rounded,
        TtcStageHitKind.door => Icons.grid_view_rounded,
        TtcStageHitKind.product => Icons.shopping_bag_outlined,
      };
}

/// One thing found: what it is, its title and one line, and how to open it.
class TtcStageHit {
  const TtcStageHit({
    required this.kind,
    required this.title,
    required this.line,
    required this.open,
    required this.score,
  });

  final TtcStageHitKind kind;
  final String title;
  final String line;
  final void Function(BuildContext) open;

  /// 2 = matched in the title, 1 = only in the supporting words.
  final int score;
}

List<String> _words(String s) => s
    .toLowerCase()
    .split(RegExp(r'[^a-z0-9]+'))
    .where((w) => w.isNotEmpty)
    .toList();

/// 2 when every query word starts a word of [title], 1 when every one starts
/// a word of [title] and [more] together, else 0.
int _score(List<String> q, String title, String more) {
  final t = _words(title);
  bool all(List<String> w) => q.every((x) => w.any((y) => y.startsWith(x)));
  if (all(t)) return 2;
  if (all([...t, ..._words(more)])) return 1;
  return 0;
}

/// Everything on the trying-to-conceive side that matches [query], best
/// first within each kind, at most [perKind] of each. Nothing for a query
/// under two letters. [him]: his side (his tools, his films).
List<TtcStageHit> ttcStageSearch(
  String query, {
  bool him = false,
  int perKind = 4,
}) {
  final q = _words(query);
  if (query.trim().length < 2 || q.isEmpty) return const [];
  final out = <TtcStageHit>[];

  void addAll(List<TtcStageHit> hits) {
    hits.sort((a, b) => b.score.compareTo(a.score));
    out.addAll(hits.take(perKind));
  }

  // Tools: the Tools hub's own matcher, so the two searches agree.
  addAll([
    for (final t in ttcToolsMatching(query, false, him: him))
      TtcStageHit(
        kind: TtcStageHitKind.tool,
        title: t.nameEn,
        line: t.descEn,
        open: t.open,
        score: _score(q, t.nameEn, t.descEn) == 2 ? 2 : 1,
      ),
  ]);

  // Articles: every read in the stage.
  addAll([
    for (final r in kTtcReads)
      if (_score(q, r.title.en, r.teaser.en) case final s when s > 0)
        TtcStageHit(
          kind: TtcStageHitKind.article,
          title: r.title.en,
          line: r.teaser.en,
          open: (c) => openTtcArticle(c, r.id, hue: 206),
          score: s,
        ),
  ]);

  // Videos: every film, made or coming, as the All videos page lists them.
  addAll([
    for (final f in ttcAllFilms(him: him))
      if (_score(q, f.tile.title, f.tile.blurb) case final s when s > 0)
        TtcStageHit(
          kind: TtcStageHitKind.video,
          title: f.tile.title,
          line: f.live ? f.doorLabel : '${f.doorLabel} · coming soon',
          open: (c) => openTtcFocusTile(c, f.tile, f.hue),
          score: s,
        ),
  ]);

  // Can I…? answers.
  addAll([
    for (final c in ttcCanI)
      if (_score(q, c.questionEn, c.shortEn) case final s when s > 0)
        TtcStageHit(
          kind: TtcStageHitKind.canI,
          title: c.questionEn,
          line: c.shortEn,
          open: (ctx) => Navigator.of(ctx).push(MaterialPageRoute<void>(
            settings: const RouteSettings(name: 'ttc/canI'),
            builder: (_) => TtcCanIScreen(focusId: c.id),
          )),
          score: s,
        ),
  ]);

  // Doors, as topics.
  addAll([
    for (final page in kTtcFocusPages)
      if (bracketById(page.bracketId) case final b?)
        if (_score(q, b.label.en, '${page.heroTitle ?? ''} ${page.intro}')
            case final s when s > 0)
          TtcStageHit(
            kind: TtcStageHitKind.door,
            title: b.label.en,
            line: page.heroTitle ?? page.intro,
            open: (c) => openTtcSurface(c, 'ttc_door/${page.bracketId}'),
            score: s,
          ),
  ]);

  // Products.
  addAll([
    for (final p in ttcProducts)
      if (_score(q, p.nameEn, p.whyEn) case final s when s > 0)
        TtcStageHit(
          kind: TtcStageHitKind.product,
          title: p.nameEn,
          line: p.band.label,
          open: (c) => openTtcProductPage(c, p.id),
          score: s,
        ),
  ]);

  return out;
}
