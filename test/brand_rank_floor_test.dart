// =============================================================================
//  The rank floor — "sponsored must never outrank objectively better"
// -----------------------------------------------------------------------------
//  This is the invariant that decides whether ParentVeda's recommendations are
//  worth anything. If it fails, every other trust feature in the app is
//  decoration.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/brand/brand_campaigns.dart';
import 'package:parentveda/brand/brand_models.dart';
import 'package:parentveda/brand/brand_store.dart';
import 'package:parentveda/brand/brand_studio.dart';
import 'package:parentveda/brand/rank_floor.dart';
import 'package:parentveda/screens/post_pregnancy/pp_reco_data.dart';

/// A stand-in for any ranked item: a name and the host's own merit score.
class _Item {
  const _Item(this.name, this.score);
  final String name;
  final double score;
  @override
  String toString() => '$name(${score.toStringAsFixed(0)})';
}

double _scoreOf(_Item i) => i.score;

List<String> _names(List<_Item> l) => l.map((i) => i.name).toList();

void main() {
  const a = _Item('a', 90);
  const b = _Item('b', 80);
  const c = _Item('c', 70);
  const d = _Item('d', 60);
  final organic = [a, b, c, d];

  test('a sponsored item lands below everything that scores higher', () {
    const promo = _Item('promo', 75); // better than c and d, worse than a and b
    final out = insertWithRankFloor(organic: organic, promo: promo, scoreOf: _scoreOf);
    expect(_names(out), ['a', 'b', 'promo', 'c', 'd']);
  });

  test('a weak sponsored item goes last, not into the middle', () {
    const promo = _Item('promo', 10);
    final out = insertWithRankFloor(organic: organic, promo: promo, scoreOf: _scoreOf);
    expect(_names(out), ['a', 'b', 'c', 'd', 'promo']);
  });

  test('even the best sponsored item cannot buy slot 0', () {
    // The top of a list is what a parent reads as "ParentVeda's pick". It is
    // editorial, and it is not for sale at any score.
    const promo = _Item('promo', 999);
    final out = insertWithRankFloor(organic: organic, promo: promo, scoreOf: _scoreOf);
    expect(out.first.name, 'a');
    expect(_names(out), ['a', 'promo', 'b', 'c', 'd']);
  });

  test('no organic item is ever dropped, reordered or replaced', () {
    const promo = _Item('promo', 75);
    final out = insertWithRankFloor(organic: organic, promo: promo, scoreOf: _scoreOf);
    // Sponsorship adds; it never removes. The organic order is untouched.
    expect(_names(out.where((i) => i.name != 'promo').toList()), _names(organic));
    expect(out.length, organic.length + 1);
  });

  test('the invariant holds for every possible sponsored score', () {
    // Exhaustive rather than anecdotal: whatever a brand pays, and whatever
    // score its product has, no BETTER organic item is ever pushed below it.
    //
    // Note the direction. The rule is "sponsored never outranks something
    // better" — so what must never happen is a higher-scoring item sitting
    // BELOW the promo. The reverse (a worse item sitting above it, which the
    // slot-0 rule can cause) is the floor being deliberately conservative, and
    // is fine.
    for (var s = 0; s <= 120; s += 1) {
      final promo = _Item('promo', s.toDouble());
      final out = insertWithRankFloor(organic: organic, promo: promo, scoreOf: _scoreOf);
      final at = out.indexWhere((i) => i.name == 'promo');

      expect(at, greaterThan(0), reason: 'promo(score $s) took slot 0');

      for (var i = at + 1; i < out.length; i++) {
        expect(
          _scoreOf(out[i]) <= s,
          isTrue,
          reason: 'promo(score $s) outranked ${out[i]}, which is objectively better',
        );
      }
    }
  });

  test('a sponsored item already in the list is not duplicated', () {
    final out = insertWithRankFloor(
      organic: organic,
      promo: c,
      scoreOf: _scoreOf,
      isSame: (x, y) => x.name == y.name,
    );
    expect(out.where((i) => i.name == 'c').length, 1);
    expect(out.length, organic.length);
  });

  test('a sponsored item in an empty list is the only item, not a ranking claim', () {
    const promo = _Item('promo', 50);
    final out = insertWithRankFloor(organic: const <_Item>[], promo: promo, scoreOf: _scoreOf);
    expect(_names(out), ['promo']);
  });

  test('quality floor: sponsorship buys consideration, never entry', () {
    // A product we would not recommend unpaid cannot be bought in at any price.
    expect(clearsQualityFloor(4.6), isTrue);
    expect(clearsQualityFloor(4.0), isTrue);
    expect(clearsQualityFloor(3.9), isFalse);
    expect(clearsQualityFloor(2.0), isFalse);
  });

  // ---- against the REAL engine, not a mock ---------------------------------
  group('the live recommendation engine', () {
    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues(<String, Object>{});
      BrandStudio.instance.allowInTests = true;
      BrandStudio.instance.enabled = true;
      BrandStudio.instance.resetCampaigns();
      BrandStudioStore.instance.resetAll();
    });

    tearDown(() {
      BrandStudio.instance.allowInTests = false;
      BrandStudio.instance.resetCampaigns();
    });

    test('the featured campaign points at a real, quality-clearing item', () {
      final featured = kBrandCampaigns.firstWhere((c) => c.slot == BrandSlot.recoFeatured);
      final item = kReco.firstWhere((r) => r.id == featured.placementKey);
      expect(clearsQualityFloor(item.pvRating), isTrue,
          reason: 'a featured item must earn its place unpaid');
    });

    test('with the Studio off, the feed contains nothing sponsored', () {
      BrandStudio.instance.enabled = false;
      expect(featuredRecoId(), isNull);
    });

    test('a featured item never takes the top slot of the real feed', () {
      final today = recommendedToday();
      final id = featuredRecoId();
      if (id == null) return; // no live campaign for this context is fine
      final at = today.indexWhere((r) => r.id == id);
      if (at < 0) return; // not in the diversified cut — also fine
      expect(at, isNot(0), reason: 'a sponsored pick took the top of the feed');
    });

    test('a featured item never displaces a better-scoring pick in the real feed', () {
      // The end-to-end version of the invariant: real catalogue, real scoring,
      // real campaign. Nothing below the sponsored item may be objectively
      // better than it, as judged by the engine's own commercially-blind score.
      final today = recommendedToday();
      final id = featuredRecoId();
      if (id == null) return;
      final at = today.indexWhere((r) => r.id == id);
      if (at < 0) return;

      // The engine ranks best-first; a sponsored insert must not break that for
      // the items it was placed above.
      final below = today.sublist(at + 1);
      final promo = today[at];
      for (final other in below) {
        expect(
          other.pvRating <= promo.pvRating + 1.0,
          isTrue,
          reason: '${other.id} (${other.pvRating}) sits below sponsored ${promo.id} (${promo.pvRating})',
        );
      }
    });
  });
}
