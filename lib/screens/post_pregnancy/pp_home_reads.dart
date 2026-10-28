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
import '../../services/remote/cloud_merged_store.dart';
// import '../../services/remote/sync_registry.dart'; // kept for revert (step 13: the mixin registers)
import 'pp_child_profile.dart';
import 'pp_content.dart';
import 'pp_daily_tips.dart';
import 'pp_phases_data.dart' show ppFillChild;
import 'pp_section_registry.dart';
import 'pp_section_screen.dart';
import 'pp_tip_links.dart';
import '../../services/pv_read_store.dart';
import 'pp_page_read.dart' show kPpPageReadPrefix;
import 'pp_relevance.dart';
import 'pp_phases_data.dart' show AgePhase, watchCategoryForPhase;
import 'pp_watch_data.dart';
import 'video/pv_video_config.dart' show pvResolveVideoUrl;
import '../../data/pp_phase_videos.dart';

/// One read on the home rail: a door page and the section it opens in.
typedef PpHomeRead = ({PpSection section, PpPage page});

/// Doors whose pages are about the mother, or are lookups, not reads for the
/// child's day.
const Set<String> _kNotForTheRail = {'parenting_maternal', 'parenting_papers'};

/// Up to [n] door pages for the child's band, one door at a time, rotated by
/// [day] so the rail changes each morning.
List<PpHomeRead> ppHomeDoorReads(int n, {int? day, PpSituation? situation}) {
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
  // THE RELEVANCE BRAIN (2026-10-21, Wave 4, pp_relevance.dart). Up to two
  // pages about her situation (born early, C-section, formula...) lead, from
  // any door in her band, so a day's rotation can never bury them; finished
  // reads sink. Nothing the rotation chose is dropped unless a lifted page
  // takes its slot within [n].
  final sit = situation ?? PpSituation.now();
  String rid(PpHomeRead r) => '$kPpPageReadPrefix${r.section.id}_${r.page.id}';
  final lifted = ppRelevanceOrder(
    [
      for (final door in tagged)
        for (final r in door)
          // What she told us lifts too (PP 4, 2026-10-28): was signals only,
          // so an answer reordered the three but never brought its page in.
          // Matched on the concern's own keywords, not its area's stems.
          // Kept for revert:
          // if (sit.signalFor(r.page.title, [r.page.id]) != null && !out.any((o) => o.page.id == r.page.id)) r,
          if ((sit.signalFor(r.page.title, [r.page.id]) != null ||
                  sit.changes.any((c) => c.matchesKeyword(r.page.title))) &&
              !out.any((o) => o.page.id == r.page.id))
            r,
    ],
    situation: sit,
    text: (r) => r.page.title,
    ids: (r) => [r.page.id],
    readId: rid,
  ).where((r) => !PvReadStore.instance.isFinished(rid(r))).take(2);
  final merged = [...lifted, ...out].take(n).toList();
  return ppRelevanceOrder(merged,
      situation: sit, text: (r) => r.page.title, ids: (r) => [r.page.id], readId: rid);
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
    // Corrected age: a tip is development content (relevance PP 2,
    // 2026-10-28). Kept for revert: ageTipsFor(child.ageInWeeks.floor())
    final pool = ageTipsFor(child.devAgeInWeeks.floor());
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

/// One tip from the child's age pool that matches her situation, with the
/// reason as its eyebrow ("Breastfeeding"), or null when none matches
/// (relevance PP 7, 2026-10-28). Never today's tip, which the rail already
/// carries. Searched in the rail's own rotation order, so it is stable all day.
/// Corrected age, like the rest of the rail (PP 2).
PpHomeInsight? ppHomeSituationTip(PpSituation situation, {DateTime? on}) {
  final child = ChildProfileStore.instance;
  if (!child.hasRealChild) return null;
  final pool = ageTipsFor(child.devAgeInWeeks.floor());
  if (pool.length < 2) return null;
  final now = on ?? DateTime.now();
  final start = now.difference(DateTime(now.year)).inDays % pool.length;
  for (var i = 1; i < pool.length; i++) {
    final t = pool[(start + i) % pool.length];
    final why = ppRelevanceWhy(situation, '${t.tip.title} ${t.tip.body}', t.key);
    if (why == null) continue;
    final raw = kPpTipLinks[t.key];
    return (
      id: t.id,
      eyebrow: why,
      value: ppFillChild(t.tip.title),
      hue: 188,
      tip: t.tip,
      link: raw != null && ppPageTitleForSurface(raw) != null ? raw : null,
    );
  }
  return null;
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
///
/// In the cloud since step 13 (2026-10-22, sync log). It was phone-only, so a
/// sign-out or a new phone lost her place. One item: `last`, value
/// `{s: section id, p: page id}`; the newer open wins.
///
/// ⚠️ ONE PAGE PER CHILD (relevance PP 17, 2026-10-28). A toddler page read
/// for the older child was offered on the baby's home. Now each child has an
/// item `child:<id>` (the stand-in is `none`), and the home shows the page of
/// the child on screen. `last` stays, as the newest open for any child: an
/// older app version on another phone still reads it, and a page saved
/// before this change shows for whoever is on screen until the first open
/// after it. One item per child, because two phones can each read for a
/// different child and neither should erase the other's place.
class PpLastPageStore extends ChangeNotifier with CloudMergedStore {
  PpLastPageStore._();
  // Kept for revert (step 13): the mixin's reset calls applyCloudItems({}).
  //   PpLastPageStore._() {
  //     SyncRegistry.registerReset(_resetForAccount);
  //   }
  static final PpLastPageStore instance = PpLastPageStore._();

  static const _key = 'pp_last_page_v1';
  // The newest open, any child (the `last` item).
  String? _sectionId;
  String? _pageId;
  // Child key -> (section id, page id). PP 17.
  final Map<String, (String, String)> _byChild = {};
  bool _loaded = false;

  /// The item key for [childId]; null or empty is the stand-in child.
  static String childKey(String? childId) =>
      (childId == null || childId.isEmpty) ? 'none' : childId;

  String get _activeKey =>
      childKey(ChildProfileStore.instance.activeChildId);

  static (String, String)? _pair(Object? v) =>
      v is Map && v['s'] is String && v['p'] is String
          ? (v['s'] as String, v['p'] as String)
          : null;

  String _encode() => jsonEncode({
        's': _sectionId,
        'p': _pageId,
        'c': {
          for (final e in _byChild.entries) e.key: {'s': e.value.$1, 'p': e.value.$2},
        },
      });

  Future<void> init() async {
    if (_loaded) return;
    _loaded = true;
    try {
      final raw = (await SharedPreferences.getInstance()).getString(_key);
      if (raw != null) {
        final m = jsonDecode(raw) as Map;
        _sectionId = m['s'] as String?;
        _pageId = m['p'] as String?;
        // A cache from before PP 17 has no `c`: the page stays as `last`.
        final c = m['c'];
        if (c is Map) {
          for (final e in c.entries) {
            if (_pair(e.value) case final v?) _byChild['${e.key}'] = v;
          }
        }
        notifyListeners();
      }
    } catch (_) {/* nothing to continue */}
    await syncMergedFromCloud();
  }

  // ---- the cloud (step 13) --------------------------------------------------

  @override
  String get cloudKey => 'pp_last_page';

  @override
  Map<String, Object?> cloudItems() => {
        if (_sectionId != null && _pageId != null)
          'last': {'s': _sectionId, 'p': _pageId},
        for (final e in _byChild.entries)
          'child:${e.key}': {'s': e.value.$1, 'p': e.value.$2},
      };

  @override
  void applyCloudItems(Map<String, Object?> items) {
    final v = items['last'];
    _sectionId = v is Map && v['s'] is String ? v['s'] as String : null;
    _pageId = v is Map && v['p'] is String ? v['p'] as String : null;
    _byChild.clear();
    for (final e in items.entries) {
      if (!e.key.startsWith('child:')) continue;
      if (_pair(e.value) case final pv?) _byChild[e.key.substring(6)] = pv;
    }
    _loaded = true;
  }

  @override
  Future<void> persistLocalCache() async {
    try {
      final p = await SharedPreferences.getInstance();
      if (_sectionId == null || _pageId == null) {
        await p.remove(_key);
      } else {
        // Kept for revert (PP 17):
        //   await p.setString(_key, jsonEncode({'s': _sectionId, 'p': _pageId}));
        await p.setString(_key, _encode());
      }
    } catch (_) {}
  }

  /// Called by the one place every door page opens (`_ppPageScreenAndKind`).
  /// Saved against the child on screen (PP 17).
  void opened(String sectionId, String pageId) {
    final k = _activeKey;
    // Kept for revert (PP 17):
    //   if (_sectionId == sectionId && _pageId == pageId) return;
    if (_byChild[k] == (sectionId, pageId)) return;
    _byChild[k] = (sectionId, pageId);
    _sectionId = sectionId;
    _pageId = pageId;
    notifyListeners();
    // Kept for revert (PP 17):
    //   .then((p) => p.setString(_key, jsonEncode({'s': sectionId, 'p': pageId})))
    final blob = _encode();
    SharedPreferences.getInstance()
        .then((p) => p.setString(_key, blob))
        .catchError((_) => false);
  }

  /// The page to continue for the child on screen, when it still exists. A
  /// page saved before PP 17 (no child items yet) shows for whoever is here.
  PpHomeRead? get last {
    // Kept for revert (PP 17): the newest open, for every child.
    //   final s = _sectionId == null ? null : ppSectionFor(_sectionId!);
    //   final p = s?.pageById(_pageId ?? '');
    final pair = _byChild[_activeKey] ??
        (_byChild.isEmpty && _sectionId != null && _pageId != null
            ? (_sectionId!, _pageId!)
            : null);
    if (pair == null) return null;
    final s = ppSectionFor(pair.$1);
    final p = s?.pageById(pair.$2);
    return (s == null || p == null) ? null : (section: s, page: p);
  }

  // Kept for revert (step 13): the mixin's reset calls applyCloudItems({}).
  //   // Sign-out forgets her in memory too (sync log step 12, 2026-10-21): prefs
  //   // are wiped, the singleton was not.
  //   void _resetForAccount() {
  //     debugReset();
  //     notifyListeners();
  //   }

  @visibleForTesting
  void debugReset() {
    _sectionId = null;
    _pageId = null;
    _byChild.clear();
    _loaded = false;
  }
}

// ---- The phase video, one pick for every screen (2026-10-21, Wave 5) -------
//
// Was private to the home (`_PpHomeV3State._video`). The phase screen now shows
// the same film on its painting, so the pick lives here: a playable video from
// the phase's own category, rotated by day, else any playable video, else null
// (and both screens then say the video is coming, never a blank box).
//
// The phase's own video leads (2026-10-23, Wave 8): a line in kPhaseVideos
// (lib/data/pp_phase_videos.dart) puts it live. The watch pick below is the
// fallback, kept as it was.
WatchVideo? ppPhaseVideo(AgePhase phase) {
  if (kPhaseVideos[phase.number] case final v?) {
    return WatchVideo(
      id: 'phase_${phase.number}',
      title: phase.name,
      topic: 'This phase',
      category: watchCategoryForPhase(phase),
      expertId: '',
      ageTag: '',
      seconds: v.seconds,
      quick: false,
      why: 'What this phase is about, in a few minutes.',
      seed: phase.number,
      videoUrl: v.url,
    );
  }
  bool plays(WatchVideo v) => pvResolveVideoUrl(v) != null;
  final pool = watchByCategory(watchCategoryForPhase(phase)).where(plays).toList();
  if (pool.isNotEmpty) return pool[DateTime.now().day % pool.length];
  final all = kWatchVideos.where(plays).toList();
  return all.isEmpty ? null : all[DateTime.now().day % all.length];
}
