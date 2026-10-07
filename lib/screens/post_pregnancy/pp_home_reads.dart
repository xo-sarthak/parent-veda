// =============================================================================
//  The home's reads, from the doors (2026-10-07)
// -----------------------------------------------------------------------------
//  Gap analysis P1 (The home · "Feed the reads rail from the doors"): "Fill
//  'Recommended reads for today' from door pages in the child's band; keep the
//  10 only as a fallback; add 'Continue reading'."
//
//  WHY THE DOORS: the ten reads are one small shelf; the doors hold hundreds
//  of pages, each already tagged with the age bands it is for. So the rail
//  asks every door for the pages in THIS child's band, takes one door at a
//  time (so three reads are three topics, not three sleep pages), and rotates
//  by the day. A page tagged for every band is a fallback within the doors;
//  the old ten come last.
//
//  "Continue reading" is the last door page she opened, kept on this phone.
//  It is a convenience, not a record, so it is local only.
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../localization/app_language.dart';
import '../../models/pv_read.dart';
import 'pp_child_profile.dart';
import 'pp_content.dart';
import 'pp_daily_tips.dart';
import 'pp_phases_data.dart' show ppFillChild;
import 'pp_section_registry.dart';
import 'pp_section_screen.dart';
import 'pp_tip_links.dart';

/// One read on the home rail: a door page and the section it opens in.
typedef PpHomeRead = ({PpSection section, PpPage page});

/// Doors whose pages are about the mother, or are lookups, not reads for the
/// child's day.
const Set<String> _kNotForTheRail = {'parenting_maternal', 'parenting_papers'};

/// Up to [n] door pages for the child's band, one door at a time, rotated by
/// [day] so the rail changes each morning.
List<PpHomeRead> ppHomeDoorReads(int n, {int? day}) {
  final d = day ?? DateTime.now().day;
  final tagged = <List<PpHomeRead>>[];
  final general = <PpHomeRead>[];
  for (final s in kPpSections) {
    if (_kNotForTheRail.contains(s.id)) continue;
    final band = s.bandSet?.active.id ?? '';
    final mine = <PpHomeRead>[];
    for (final a in s.areas) {
      if (!a.inBand(band)) continue;
      for (final p in a.pagesFor(band)) {
        if (p.comingSoon || p.toolSurfaceId != null) continue;
        (p.bands.isNotEmpty || a.bands.isNotEmpty ? mine : general).add((section: s, page: p));
      }
    }
    if (mine.isNotEmpty) tagged.add(mine);
  }
  // Rotate the doors and each door's pages by the day, then deal one per door.
  final out = <PpHomeRead>[];
  if (tagged.isNotEmpty) {
    final start = d % tagged.length;
    final doors = [for (var i = 0; i < tagged.length; i++) tagged[(start + i) % tagged.length]];
    var round = 0;
    while (out.length < n && doors.any((x) => x.length > round)) {
      for (final door in doors) {
        if (out.length >= n) break;
        if (door.length > round) out.add(door[(d + round) % door.length]);
      }
      round++;
    }
  }
  if (out.length < n && general.isNotEmpty) {
    for (var i = 0; out.length < n && i < general.length; i++) {
      out.add(general[(d + i) % general.length]);
    }
  }
  return out;
}

// =============================================================================
//  "My daily insights" — the parenting rail (2026-10-07)
// -----------------------------------------------------------------------------
//  The user, on the device: "On the home screen I would require the Today
//  insight, the way we are having in Pregnancy and trying to conceive." The
//  card is the shared `PvInsightTile` (lib/screens/v2/pv_insight_rail.dart);
//  what a day earns is this stage's own, as on the other two
//  (preg_daily_insights.dart, ttc_daily_insights.dart).
//
//  WHERE THE CARDS COME FROM: the ~220 age tips in pp_daily_tips.dart, the
//  pool for THIS child's age, starting at today's tip (the same one the
//  app-open pop-up shows) and rotating on through the pool. Nothing new is
//  written. A tip hand-linked to a door page (pp_tip_links.dart) opens that
//  page; a tip with no link opens itself in the one reader (`ppTipAsRead`).
//  So every card opens something, never nothing.
//
//  Mobbin (adopted: a short daily rail of tip cards under the greeting, each
//  opening its piece): Blinkist "Smarter in 5 minutes",
//  https://mobbin.com/screens/a8771dda-c90b-4b19-bf78-7aa953101531
// =============================================================================

/// One card on the parenting home's insight rail.
typedef PpHomeInsight = ({
  String id,
  String eyebrow,
  String value,
  double hue,
  DailyTip tip,

  /// `pp_page/<section>/<page>` when the tip is linked to a door page that
  /// still exists; null opens the tip itself in the reader.
  String? link,
});

/// The section title behind a `pp_page/<section>/<page>` link.
String? _sectionTitleFor(String link) {
  final parts = link.split('/');
  if (parts.length != 3) return null;
  return ppSectionFor(parts[1])?.title;
}

/// Up to [n] insight cards for today: today's tip first, then the next tips
/// in the child's age pool. Stable for the whole day.
List<PpHomeInsight> ppHomeInsights({int n = 5, DateTime? on}) {
  final now = on ?? DateTime.now();
  final doy = now.difference(DateTime(now.year)).inDays;
  final child = ChildProfileStore.instance;
  final out = <PpHomeInsight>[];
  const hues = <double>[268, 28, 188, 104, 344, 42, 232];
  if (child.hasRealChild) {
    final pool = ageTipsFor(child.ageInWeeks.floor());
    if (pool.isEmpty) return out;
    final start = doy % pool.length;
    for (var i = 0; i < n && i < pool.length; i++) {
      final t = pool[(start + i) % pool.length];
      final raw = kPpTipLinks[t.key];
      final link = raw != null && ppPageTitleForSurface(raw) != null ? raw : null;
      out.add((
        id: t.id,
        eyebrow: i == 0 ? "Today's tip" : (link == null ? 'A tip for this age' : (_sectionTitleFor(link) ?? 'A tip for this age')),
        value: ppFillChild(t.tip.title),
        hue: hues[i % hues.length],
        tip: t.tip,
        link: link,
      ));
    }
    return out;
  }
  // No birth date yet: the general rotation, which has no door links.
  if (kDailyTips.isEmpty) return out;
  final start = doy % kDailyTips.length;
  for (var i = 0; i < n && i < kDailyTips.length; i++) {
    final idx = (start + i) % kDailyTips.length;
    final t = kDailyTips[idx];
    out.add((
      id: 'tip_$idx',
      eyebrow: i == 0 ? "Today's tip" : 'A tip for you',
      value: ppFillChild(t.title),
      hue: hues[i % hues.length],
      tip: t,
      link: null,
    ));
  }
  return out;
}

LocalizedText _same(String s) => LocalizedText(en: s, hi: s);

/// A tip with no door page, as a short piece in the one reader (CLAUDE.md,
/// "One reader"). The tip's own words only: the body, why it works, and
/// where that comes from. Byline the desk, no verified mark.
PvRead ppTipAsRead(String id, DailyTip tip) => PvRead(
      id: 'pp_tip_$id',
      kicker: _same("Today's tip"),
      title: _same(ppFillChild(tip.title)),
      teaser: _same(ppFillChild(tip.body)),
      // Empty renders as nothing (pp_page_read.dart does the same).
      scaleSetter: _same(''),
      author: _same('ParentVeda editorial'),
      authorRole: _same('Daily tips'),
      reviewed: false,
      hue: 268,
      sections: [
        if (tip.why.isNotEmpty)
          PvReadSection(heading: _same('Why it works'), paragraphs: [_same(ppFillChild(tip.why))]),
      ],
      whenToSeeSomeone: kPvShortPieceCallout,
      faqs: const [],
      evidence: tip.source.isEmpty ? null : _same(tip.source),
    );

/// The last door page opened, for "Continue reading".
class PpLastPageStore extends ChangeNotifier {
  PpLastPageStore._();
  static final PpLastPageStore instance = PpLastPageStore._();

  static const _key = 'pp_last_page_v1';
  String? _sectionId;
  String? _pageId;
  bool _loaded = false;

  Future<void> init() async {
    if (_loaded) return;
    _loaded = true;
    try {
      final raw = (await SharedPreferences.getInstance()).getString(_key);
      if (raw != null) {
        final m = jsonDecode(raw) as Map;
        _sectionId = m['s'] as String?;
        _pageId = m['p'] as String?;
        notifyListeners();
      }
    } catch (_) {/* nothing to continue */}
  }

  /// Called by the one place every door page opens (`_ppPageScreenAndKind`).
  void opened(String sectionId, String pageId) {
    if (_sectionId == sectionId && _pageId == pageId) return;
    _sectionId = sectionId;
    _pageId = pageId;
    notifyListeners();
    SharedPreferences.getInstance()
        .then((p) => p.setString(_key, jsonEncode({'s': sectionId, 'p': pageId})))
        .catchError((_) => false);
  }

  /// The page to continue, when it still exists.
  PpHomeRead? get last {
    final s = _sectionId == null ? null : ppSectionFor(_sectionId!);
    final p = s?.pageById(_pageId ?? '');
    return (s == null || p == null) ? null : (section: s, page: p);
  }

  @visibleForTesting
  void debugReset() {
    _sectionId = null;
    _pageId = null;
    _loaded = false;
  }
}
