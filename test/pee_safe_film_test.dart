// Pee Safe demo, item 10b: the launch film.
//
// Both surfaces (the Premiere and the brand page's film slot) read a
// videoRef. A ref that names a missing file, or a file pubspec.yaml does not
// bundle, fails SILENTLY on a phone: the player's load throws, the surface
// falls back to its animation, and nobody notices the film never played. So
// this test holds both refs to a real, declared asset.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/brand/brand_studio.dart';
import 'package:parentveda/brand/pee_safe/pee_safe_brand.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    BrandStudio.instance.allowInTests = true;
    BrandStudio.instance.enabled = true;
    BrandStudio.instance.resetCampaigns();
  });

  tearDown(() => BrandStudio.instance.allowInTests = false);

  test('the Premiere and the launch both point at the bundled film', () {
    final byId = {for (final c in BrandStudio.instance.campaigns) c.id: c};
    expect(byId[kPeeSafePremiereId]?.creative.videoRef, kPeeSafeLaunchFilm, reason: 'the Premiere plays the film');
    expect(byId[kPeeSafeLaunchId]?.creative.videoRef, kPeeSafeLaunchFilm, reason: 'the brand page film slot plays it');
  });

  test('the film exists on disk, is a sensible size, and pubspec bundles it', () {
    final f = File(kPeeSafeLaunchFilm);
    expect(f.existsSync(), isTrue, reason: '$kPeeSafeLaunchFilm is missing');
    final bytes = f.lengthSync();
    expect(bytes, greaterThan(100 * 1024), reason: 'too small to be a film');
    expect(bytes, lessThan(15 * 1024 * 1024), reason: 'the brief caps the film at 15 MB');

    // Flutter bundles an asset declared by its own path or by its folder
    // (a line ending in '/'). Either form counts.
    final declared = File('pubspec.yaml')
        .readAsLinesSync()
        .map((l) => l.trim())
        .where((l) => l.startsWith('- '))
        .map((l) => l.substring(2).trim())
        .toSet();
    final folder = kPeeSafeLaunchFilm.substring(0, kPeeSafeLaunchFilm.lastIndexOf('/') + 1);
    expect(declared.contains(kPeeSafeLaunchFilm) || declared.contains(folder), isTrue,
        reason: 'pubspec.yaml must declare $kPeeSafeLaunchFilm or $folder');
  });
}
