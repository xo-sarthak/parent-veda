// =============================================================================
//  Baby Naming Journey (Version 2) - data, version toggle + content engine
// -----------------------------------------------------------------------------
//  V2 is the emotional "Baby Naming Journey" (keepsake-book feel) that sits
//  behind the V1|V2 header toggle. It REUSES the existing name catalogue
//  (BabyName / kBabyNames) and the shared NameMatchStore - nothing here changes
//  or deletes the V1 tool. It adds: curated Collections, the AI Name Story, the
//  Decision Companion content, and the journey-timeline steps. Content is
//  hand-authored for a few heroes and generated (from existing fields) for the
//  rest, so every name reads richly without a backend.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';
import 'pp_names_data.dart';

// ---- version toggle ---------------------------------------------------------
enum NameVersion { v1, v2 }

/// Which naming experience is active. A ChangeNotifier singleton (same pattern as
/// the app's other stores); session-persistent. Defaults to V2 so the new
/// Journey is what opens - flip to V1 in the header to see the classic Finder.
class NameVersionStore extends ChangeNotifier {
  NameVersionStore._();
  static final NameVersionStore instance = NameVersionStore._();

  NameVersion _v = NameVersion.v2;
  NameVersion get version => _v;
  bool get isV2 => _v == NameVersion.v2;

  void setVersion(NameVersion v) {
    if (v != _v) {
      _v = v;
      notifyListeners();
    }
  }
}

// ---- the Name Journey Timeline (the reassuring progress ribbon) -------------
const List<String> kNameJourneySteps = [
  'Discover',
  'Explore',
  'We Both Love',
  'Shortlist',
  'Compare',
  'Chosen',
  'Story',
];

// ---- curated collections (browse stories, not spreadsheets) -----------------
class NameCollection {
  const NameCollection(this.title, this.subtitle, this.icon, this.match);
  final String title;
  final String subtitle;
  final IconData icon;
  final bool Function(BabyName) match;

  List<BabyName> get names => kBabyNames.where(match).toList();
}

final List<NameCollection> kNameCollections = [
  NameCollection('Timeless Classics', 'Names that never go out of style.', Icons.auto_awesome_outlined,
      (n) => n.popularity == 'Classic'),
  NameCollection('Trending Now', "Today's most-loved picks.", Icons.trending_up_rounded,
      (n) => n.popularity == 'Trending'),
  NameCollection('Modern & Fresh', 'Rooted, yet contemporary.', Icons.spa_outlined,
      (n) => n.feel.toLowerCase().contains('modern')),
  NameCollection('Sun & Light', 'Dawn, rays and radiant beginnings.', Icons.wb_sunny_outlined,
      (n) => RegExp(r'light|sun|dawn|ray').hasMatch('${n.meaningShort} ${n.meaningFull}'.toLowerCase())),
  NameCollection('Devotional', 'Names carrying faith and story.', Icons.self_improvement_outlined,
      (n) => n.feel.toLowerCase().contains('devotional')),
  NameCollection('Rare Sanskrit', 'Uncommon, thoughtful, meaningful.', Icons.diamond_outlined,
      (n) => n.rare || n.feel.toLowerCase().contains('rare')),
  NameCollection('Short & Sweet', 'Two easy syllables.', Icons.favorite_border,
      (n) => n.syllables <= 2),
  NameCollection('Every Name', 'Browse the whole collection.', Icons.grid_view_rounded,
      (n) => true),
];

// ---- AI Name Story + Decision Companion content -----------------------------
class NameV2 {
  const NameV2({
    required this.aiStory,
    required this.decisionWhy,
    this.alternatives = const [],
    this.nicknames = const [],
    this.intlPron = '',
  });
  final String aiStory; // the "personality" of the name, beautifully written
  final String decisionWhy; // why parents choose it / who it suits
  final List<String> alternatives;
  final List<String> nicknames;
  final String intlPron;
}

// Hand-authored heroes (match the V2 prompt's tone); the rest are generated.
const Map<String, NameV2> _nameV2 = {
  'Aarav': NameV2(
    aiStory:
        'Aarav has become popular because it balances timeless Sanskrit roots with a gentle, modern sound. Parents often choose it because it feels peaceful, is easy to pronounce across cultures, and carries a quietly musical meaning - the calm sound of music itself. It is a name that sounds like the feeling most parents want for their child.',
    decisionWhy:
        'Aarav suits families looking for a name that is traditional in root yet effortlessly modern - soft on the tongue, recognised everywhere, and never harsh or heavy.',
    alternatives: ['Aarush', 'Vihaan', 'Reyansh'],
    nicknames: ['Aaru', 'Rav'],
    intlPron: 'AA-rav (travels easily across languages)',
  ),
  'Vihaan': NameV2(
    aiStory:
        'Vihaan feels like a beginning. Rooted in the Sanskrit for daybreak, it pairs a bright, hopeful meaning with a clean, modern sound that rarely gets shortened or mispronounced. Parents are drawn to the sense of a fresh start it carries - the first light of a new day, held in two easy syllables.',
    decisionWhy:
        'Vihaan suits parents who want an optimistic, forward-looking name that still feels grounded in tradition, and one that travels well across languages.',
    alternatives: ['Vivaan', 'Aarav', 'Reyansh'],
    nicknames: ['Vihu', 'Vee'],
    intlPron: 'vi-HAAN',
  ),
  'Kabir': NameV2(
    aiStory:
        'Kabir carries genuine weight. Named for the 15th-century mystic poet-saint whose verses are loved across faiths, it is short, dignified and instantly recognised - a name with literary and devotional depth that still sits easily in the modern world. It crosses communities gracefully, which is a large part of its quiet appeal.',
    decisionWhy:
        'Kabir suits families who want a name with real cultural and literary roots, one that feels strong and timeless without being ornate.',
    alternatives: ['Arjun', 'Aarav', 'Ishaan'],
    nicknames: ['Kabu', 'Kay'],
    intlPron: 'ka-BEER',
  ),
};

int _min(int a, int b) => a < b ? a : b;

/// Every name's V2 content - hand-authored where we have it, gracefully generated
/// from the existing fields otherwise. So no name ever reads thin.
NameV2 nameV2(BabyName n) {
  final hand = _nameV2[n.name];
  if (hand != null) return hand;
  final meaning = n.meaningShort.replaceAll(RegExp(r'[.;]+$'), '').toLowerCase();
  return NameV2(
    aiStory:
        '${n.name} carries ${n.origin.split('·').first.trim().toLowerCase()} roots and a ${n.popularity.toLowerCase()} feel. ${n.perspective} Its meaning - $meaning - gives it a warmth many parents quietly fall for.',
    decisionWhy:
        'Parents drawn to ${n.name} tend to love that it is ${n.popularity.toLowerCase()}, easy to say and rich in meaning - a natural fit for families who want a name that feels ${n.feel.toLowerCase()}.',
    alternatives: n.similar.map((s) => s.$1).toList(),
    nicknames: [n.name.substring(0, _min(3, n.name.length))],
    intlPron: n.pron,
  );
}

/// A gentle "why this fits your shortlist" line for the Decision Companion.
String decisionCompare(List<BabyName> names) {
  if (names.isEmpty) return 'Swipe a few names you love, and we\'ll help you weigh them here.';
  final trad = names.where((n) => n.feel.toLowerCase().contains('rooted') || n.feel.toLowerCase().contains('devotional')).length;
  final modern = names.length - trad;
  if (trad > 0 && modern > 0) {
    return 'Your shortlist mixes rooted, traditional names with fresher modern ones - a lovely sign you\'re weighing heritage against everyday ease. Neither is more "right"; it comes down to the feeling you want when you call your child in from the garden.';
  }
  if (trad >= modern) {
    return 'Your shortlist leans traditional and rooted - names with story and heritage behind them. You clearly value meaning that carries weight.';
  }
  return 'Your shortlist leans modern and fresh - bright, easy names that travel well. You seem to value a name that feels effortless and contemporary.';
}

/// The Name Journey Timeline ribbon - a reassuring sense of progress (never
/// gamification: no points, no rewards). [active] indexes into kNameJourneySteps.
Widget nameJourneyRibbon({required int active}) => SizedBox(
      height: 30,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: kNameJourneySteps.length,
        itemBuilder: (context, i) {
          final done = i < active;
          final on = i == active;
          final color = on ? ppPurple : (done ? const Color(0xFF9B7FC7) : ppMuted);
          return Row(children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: on || done ? ppPurple : const Color(0xFFD8CEE6), shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(kNameJourneySteps[i], style: ppBody(11.5, color: color, w: on ? FontWeight.w800 : FontWeight.w600)),
            if (i < kNameJourneySteps.length - 1)
              Container(width: 16, height: 1, margin: const EdgeInsets.symmetric(horizontal: 8), color: const Color(0xFFE4DCEC)),
          ]);
        },
      ),
    );
