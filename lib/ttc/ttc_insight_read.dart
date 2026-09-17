// =============================================================================
//  A daily insight, as an article — the adapter, not a rewrite
// -----------------------------------------------------------------------------
//  The "Today's insight" card on the TTC home opened `TtcInsightScreen`: a
//  screen of its own with its own type, its own spacing and its own foot. The
//  user, on the phone (2026-09-17): *"I don't like this reading view… it just
//  feels like everything is taking space."* His rule for the whole app now:
//  anything read is read in the one format — `PvReaderScreen`, the article he
//  confirmed on "How conception actually works". Picture frame, title, teaser,
//  byline, lede, body, a when-to-ask line, references, "was this helpful?",
//  and the tiles at the foot.
//
//  ⚠️ AN ADAPTER, SO NO SEED DATA MOVES. `ttcInsights` stays exactly as it is
//  — sixty-odd bilingual pieces the home, the partner screen and Ask Veda all
//  pick from — and this file turns one into a `PvRead` at the moment it is
//  opened. STILL-OPEN §60.1 decided this shape for every reading model in the
//  app: `fromX()` adapters converge on `PvRead`, the old readers stay
//  commented at their call sites, nothing is rewritten.
//
//  What the adapter has to decide, because a 120-word piece is not a
//  2,000-word one:
//
//    · The takeaway is the teaser — it is the one sentence the piece exists to
//      leave behind, and the teaser is the slot the reader sets in that role.
//    · The first paragraph is the lede (`scaleSetter`); the rest is the body.
//      A short piece has no headings, so no contents box appears (the reader
//      only shows one past two headings).
//    · The when-to-see-someone line is REQUIRED on the model and stays
//      required — CLAUDE.md: anything clinical ends by routing calmly to a
//      doctor. An insight has no hand-written one, so every insight carries
//      the same honest, quiet line (`note` tone, rendered inline): this is
//      general, not about you; your clinic knows your case. Not `urgent`,
//      because nothing here is.
//    · The byline is the editorial desk, WITHOUT the verified mark — the mark
//      says "this person checked it", and no named clinician has. That is
//      `PvRead.reviewed = false`, added for exactly this case.
//    · Read next: the next two insights on the same topic, so the foot is
//      never blank (a feature is never hidden) and the rail says what it is.
// =============================================================================

import 'package:flutter/material.dart';

import '../localization/app_language.dart';
import '../models/pv_read.dart';
import '../screens/reader/pv_reader_screen.dart';
import '../screens/ttc/ttc_surface_router.dart';
import 'ttc_daily_data.dart';
import '../screens/ttc/ttc_strings.dart';

/// The id a daily insight carries as a read: `ttc_insight_<insight.id>`.
const String kTtcInsightReadPrefix = 'ttc_insight_';

/// The one when-to-ask line every short piece carries. See the head of the
/// file for why it is shared and why it is not urgent.
const PvCallout kPvShortPieceCallout = PvCallout(
  tone: PvCalloutTone.note,
  title: LocalizedText(
      en: 'A general note, not advice about you',
      hi: 'Aam baat, aapke baare mein salah nahi'),
  body: LocalizedText(
      en: 'Nothing here is written with your history in front of it. If '
          'anything worries you, or a clinic is already looking after your '
          'cycle, ask them — they know your case and this page does not.',
      hi: 'Yahan kuch bhi aapki history dekh kar nahi likha gaya. Agar kuch '
          'pareshan kare, ya koi clinic pehle se aapka cycle dekh raha hai, '
          'unse poochhein — wo aapka case jaante hain, ye page nahi.'),
);

/// One hue per topic, so the picture frame and the foot tiles read as the
/// insight's subject before a word is read. Hues from `V2BlockHues` where a
/// meaning already has one.
double _hueForTopic(String topic) => switch (topic) {
      'fertility' => 344,
      'medical' => 206,
      'male' => 205,
      'nutrition' => 150,
      'lifestyle' => 104,
      'emotional' => 275,
      _ => 268,
    };

/// Split a body on blank lines into paragraphs, both languages kept in step.
/// The seeds write `\n\n` between paragraphs and never differ in count
/// between `bodyEn` and `bodyHi`; if one day they do, the shorter list pads
/// with the other's text rather than dropping a paragraph.
List<LocalizedText> _paragraphs(TtcInsight i) {
  final en = i.bodyEn.split(RegExp(r'\n\s*\n')).map((s) => s.trim()).toList();
  final hi = i.bodyHi.split(RegExp(r'\n\s*\n')).map((s) => s.trim()).toList();
  final n = en.length > hi.length ? en.length : hi.length;
  return [
    for (var k = 0; k < n; k++)
      LocalizedText(
          en: k < en.length ? en[k] : hi[k], hi: k < hi.length ? hi[k] : en[k]),
  ];
}

/// The insight as a read. Pure — the same insight always yields the same read.
PvRead ttcInsightAsRead(TtcInsight i) {
  final paras = _paragraphs(i);
  final lede = paras.isEmpty
      ? LocalizedText(en: i.takeawayEn, hi: i.takeawayHi)
      : paras.first;
  final body = paras.length > 1 ? paras.sublist(1) : const <LocalizedText>[];

  // The next two on the same topic, in seed order, wrapping — so the last
  // piece on a topic still has a rail.
  final peers = ttcInsights.where((o) => o.topic == i.topic && o.id != i.id).toList();
  final at = ttcInsights.where((o) => o.topic == i.topic).toList().indexOf(i);
  final next = <String>[
    for (var k = 0; k < 2 && k < peers.length; k++)
      kTtcInsightReadPrefix + peers[(at + k) % peers.length].id,
  ];

  return PvRead(
    id: kTtcInsightReadPrefix + i.id,
    kicker: const LocalizedText(en: "Today's insight", hi: 'Aaj ki baat'),
    title: LocalizedText(en: i.titleEn, hi: i.titleHi),
    teaser: LocalizedText(en: i.takeawayEn, hi: i.takeawayHi),
    scaleSetter: lede,
    author: const LocalizedText(en: 'ParentVeda editorial', hi: 'ParentVeda editorial'),
    authorRole: const LocalizedText(en: 'Daily insight', hi: 'Aaj ki baat'),
    reviewed: false,
    hue: _hueForTopic(i.topic),
    sections: [
      if (body.isNotEmpty) PvReadSection(paragraphs: body),
    ],
    whenToSeeSomeone: kPvShortPieceCallout,
    faqs: const [],
    readNext: next,
  );
}

/// The read behind an insight id, or null — the resolver the reader's Read
/// next rail and `openRead` both use. Accepts a bare insight id too.
PvRead? ttcInsightReadById(String id) {
  final key = id.startsWith(kTtcInsightReadPrefix)
      ? id.substring(kTtcInsightReadPrefix.length)
      : id;
  for (final i in ttcInsights) {
    if (i.id == key) return ttcInsightAsRead(i);
  }
  return null;
}

/// Open an insight in the article format. Every "Today's insight" tap in the
/// stage goes through here; `TtcInsightScreen` stays in the tree, commented
/// at those call sites, kept for revert.
void openTtcInsight(BuildContext context, TtcInsight insight) {
  final read = ttcInsightAsRead(insight);
  final lang =
      TtcLang.instance.hinglish ? AppLanguage.hinglish : AppLanguage.english;
  Navigator.of(context).push(MaterialPageRoute<void>(
    // The route name the FAB and the tests already know.
    settings: const RouteSettings(name: 'ttc/insight'),
    builder: (_) => PvReaderScreen(
      read: read,
      lang: lang,
      resolveRead: ttcInsightReadById,
      readTitle: (id) => ttcInsightReadById(id)?.title,
      openRead: (ctx, id) {
        final i = ttcInsightReadById(id);
        if (i == null) return;
        for (final raw in ttcInsights) {
          if (kTtcInsightReadPrefix + raw.id == i.id) {
            openTtcInsight(ctx, raw);
            return;
          }
        }
      },
      openSurface: openTtcSurface,
    ),
  ));
}
