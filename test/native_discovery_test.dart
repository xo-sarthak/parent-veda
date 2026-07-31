// Native Discovery (Brand Product 14) — the product a piece of content already
// implies.
//
// The brief is unambiguous: "Products mentioned naturally should link to
// Product Guides. Never appear as advertisements." And, earlier: "The platform
// should never display irrelevant promotions."
//
// TWO wrong pairings were shipped, and the pattern in them is the point:
//
//   * a PANEER CUTLET recipe pointed at a peekaboo cloth book
//   * a WOODEN GRASPING RING recommendation pointed at a white-noise soother
//
// Neither is thin coverage — thin coverage is invisible and harmless. A wrong
// pairing is worse, because it teaches a parent that the row is an advert
// rather than a link, and once she believes that she stops tapping the ones
// that ARE useful. The second slipped through because the first version of
// this file only checked recipes; the same field exists on articles, videos
// and recommendations, and nobody was looking there.
//
// So the rule below is deliberately not a list of approved pairings (which
// would just restate the data). It is: the tagged product's SUBJECT has to
// appear in the content's own words. If a recipe never mentions play, it may
// not link to a toy. That generalises to whatever gets tagged next.

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/screens/post_pregnancy/pp_food_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_products_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_reading_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_reco_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_watch_data.dart';

/// The catalogue has no nullable lookup, so do it here rather than assume one.
PpProduct? _product(String id) {
  for (final p in kPpProducts) {
    if (p.id == id) return p;
  }
  return null;
}

/// One tagged thing, flattened: where it lives, what it says, what it points at.
class _Tagged {
  const _Tagged(this.where, this.label, this.text, this.productId);
  final String where; // 'recipe' / 'article' / 'video' / 'recommendation'
  final String label; // human title, for the failure message
  final String text; // everything the content says, lowercased
  final String productId;
}

/// Words that mean a product category is genuinely on-topic. Generous on
/// purpose: this test exists to catch a product from a DIFFERENT WORLD than
/// the content, not to police near-misses. A false pass is a mildly loose
/// link; a false failure would push someone to delete a good pairing.
const Map<String, List<String>> _subject = {
  'Feeding': [
    'feed', 'milk', 'bottle', 'wean', 'solid', 'puree', 'purée', 'mash',
    'spoon', 'meal', 'eat', 'porridge', 'khichdi', 'dal', 'food', 'snack',
    'breakfast', 'lunch', 'dinner', 'appetite', 'swallow', 'taste',
  ],
  'Sleep': [
    'sleep', 'nap', 'night', 'drowsy', 'bedtime', 'wake', 'settle', 'soothe',
    'soother', 'noise', 'swaddle', 'cot', 'dream', 'rest',
  ],
  'Play & Development': [
    'play', 'toy', 'grasp', 'reach', 'sensory', 'book', 'tummy', 'motor',
    'stack', 'crawl', 'milestone', 'skill', 'babble', 'explore',
  ],
  'Health & Safety': [
    'fever', 'temperature', 'safe', 'proof', 'first aid', 'hurt', 'sick',
    'ill', 'injur', 'emergency', 'doctor', 'symptom',
  ],
  'Skincare': [
    'skin', 'rash', 'bath', 'lotion', 'wash', 'nappy', 'diaper', 'massage',
    'dry', 'eczema',
  ],
  'On the move': [
    'stroller', 'carrier', 'car ', 'travel', 'outing', 'walk', 'pram',
    'journey', 'trip',
  ],
};

List<_Tagged> _collect() {
  final out = <_Tagged>[];

  for (final r in kFoodRecipes) {
    if (r.relatedProductId == null) continue;
    out.add(_Tagged(
        'recipe',
        r.title,
        [r.title, r.subtitle, r.category, r.why, ...r.tags, ...r.steps]
            .join(' ')
            .toLowerCase(),
        r.relatedProductId!));
  }

  for (final a in kReadArticles) {
    if (a.relatedProductId == null) continue;
    out.add(_Tagged('article', a.title,
        [a.title, a.teaser, a.whyToday].join(' ').toLowerCase(),
        a.relatedProductId!));
  }

  for (final v in [...kWatchVideos, ...kWatchPodcasts]) {
    if (v.relatedProductId == null) continue;
    out.add(_Tagged('video', v.title,
        [v.title, v.topic, v.category, v.why].join(' ').toLowerCase(),
        v.relatedProductId!));
  }

  for (final i in kReco) {
    if (i.relatedProductId == null) continue;
    out.add(_Tagged(
        'recommendation',
        i.title,
        [i.title, i.summary, i.category, i.why, ...i.tags]
            .join(' ')
            .toLowerCase(),
        i.relatedProductId!));
  }

  return out;
}

void main() {
  final tagged = _collect();

  test('every tagged product actually exists', () {
    for (final t in tagged) {
      expect(_product(t.productId), isNotNull,
          reason: 'the ${t.where} "${t.label}" points at a product id that is '
              'not in the catalogue: ${t.productId}');
    }
  });

  test('a tagged product is on the same subject as the content', () {
    for (final t in tagged) {
      final p = _product(t.productId)!;
      final words = _subject[p.category];
      expect(words, isNotNull,
          reason: 'product category "${p.category}" has no subject words here, '
              'so nothing can vouch for a pairing with it — add them');
      expect(words!.any(t.text.contains), isTrue,
          reason: 'the ${t.where} "${t.label}" links to "${p.name}" '
              '(${p.category}), but says nothing about ${p.category}. Native '
              'Discovery must FOLLOW from the content, not sit beside it — an '
              'off-topic product reads as an advert, which is exactly what '
              'this placement must never be.');
    }
  });

  test('a recipe never links outside the categories a meal can imply', () {
    // Narrower than the subject rule and worth keeping separate: a recipe is
    // food, so even an on-topic-sounding match to Sleep or Play is wrong.
    const plausible = {'Feeding', 'Mealtime', 'Kitchen', 'Health & Safety'};
    for (final t in tagged.where((t) => t.where == 'recipe')) {
      final p = _product(t.productId)!;
      expect(plausible.contains(p.category), isTrue,
          reason: '"${t.label}" (a recipe) links to "${p.name}", which is '
              '${p.category}');
    }
  });

  test('the paneer cutlet recipe carries no product', () {
    // The first regression. Finger food needs no equipment, so the correct
    // number of products on that recipe is zero.
    final cutlet = kFoodRecipes.firstWhere((r) => r.id == 'paneercutlet');
    expect(cutlet.relatedProductId, isNull,
        reason: 'a cloth book on a cutlet recipe is how this started');
  });

  test('the grasping ring points at play equipment, not a soother', () {
    // The second regression, found only because the first was.
    final ring = kReco.firstWhere((i) => i.id == 'ty_ring');
    final p = _product(ring.relatedProductId ?? '');
    expect(p?.category, 'Play & Development',
        reason: 'a white-noise soother on a reach-and-grasp toy');
  });

  group('coverage follows a rule, not a mood', () {
    // A weaning spoon set belongs where a parent is at the START of solids.
    // Stating it as a rule means the next recipe added to the file inherits
    // the decision instead of re-litigating it — and means "why is this one
    // tagged and that one not" has an answer.
    final firstFoods =
        kFoodRecipes.where((r) => r.ageTag.startsWith('6')).toList();

    test('there are first-food recipes to tag at all', () {
      expect(firstFoods, isNotEmpty);
    });

    test('every recipe whose age band opens at 6 months carries the spoons', () {
      for (final r in firstFoods) {
        expect(r.relatedProductId, 'spoons',
            reason: '"${r.title}" (${r.ageTag}) is a first-tastes recipe; the '
                'weaning spoon set is the next thing its parent needs');
      }
    });

    test('nothing older carries them', () {
      for (final r in kFoodRecipes.where((r) => !r.ageTag.startsWith('6'))) {
        expect(r.relatedProductId == 'spoons', isFalse,
            reason: '"${r.title}" (${r.ageTag}) is past first tastes — the '
                'product itself says "not for older toddlers"');
      }
    });
  });

  test('at least one item IS tagged, or the placement is dead', () {
    // The other failure mode: fixing wrong pairings by removing every pairing
    // leaves a built, wired, invisible feature — which is how the Brand Studio
    // shipped a dead flagship once already.
    expect(tagged, isNotEmpty,
        reason: 'Native Discovery renders nowhere; the mechanism exists and no '
            'content reaches it');
  });
}
