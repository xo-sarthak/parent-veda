// The wiring gate for the community (CLAUDE.md: correct-but-unreachable code
// is the failure this repo has actually hit). Reads the source, not a build:
// every way in opens the NEW community, and nothing opens the old ones.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _read(String p) => File(p).readAsStringSync();

/// Source lines that are not comments.
Iterable<String> _live(String src) =>
    src.split('\n').map((l) => l.trim()).where((l) => !l.startsWith('//') && !l.startsWith('///'));

void main() {
  test('the three stage homes carry the "Parents like you" card', () {
    for (final f in [
      'lib/screens/home_v3_screen.dart',
      'lib/screens/ttc/ttc_home_v3.dart',
      'lib/screens/post_pregnancy/pp_home_v3.dart',
    ]) {
      expect(_live(_read(f)).any((l) => l.contains('CommunityHomeCard()')), isTrue, reason: f);
    }
  });

  test('the app loads the new store, not the old one', () {
    final main = _live(_read('lib/main.dart')).join('\n');
    expect(main, contains('PvCommunityStore.instance.init()'));
    expect(main.contains('CommunityStore.instance.init()') && !main.contains('PvCommunityStore.instance.init()'),
        isFalse);
  });

  test('the Ask button stays off community screens', () {
    final fab = _read('lib/widgets/global_ask_fab.dart');
    expect(fab, contains("name.startsWith('community/')"));
    expect(fab, contains("name == 'community'"));
  });

  test('old door links and routers open the new community', () {
    expect(_live(_read('lib/screens/post_pregnancy/pp_surface_router.dart')).join('\n'), contains('openCommunity('));
    expect(_live(_read('lib/screens/ttc/ttc_surface_router.dart')).join('\n'), contains('openCommunity('));
    expect(_live(_read('lib/screens/saved_screen.dart')).join('\n'), contains('openCommunityPost('));
  });

  test('nothing outside the old files pushes an old community screen', () {
    const old = {
      'lib/screens/community_screen.dart',
      'lib/screens/community_profile_screen.dart',
      'lib/screens/post_pregnancy/community_screen.dart',
      'lib/screens/post_pregnancy/pp_community_detail_screen.dart',
      'lib/screens/post_pregnancy/pp_post_detail_screen.dart',
      'lib/screens/post_pregnancy/pp_create_post_screen.dart',
      'lib/screens/post_pregnancy/pp_community_activity_screen.dart',
      'lib/screens/ttc/ttc_community_screen.dart',
    };
    final pushes = RegExp(
        r'\b(TtcCommunityScreen|PpCommunityDetailScreen|PpPostDetailScreen|PpCreatePostScreen|PpMyActivityScreen|PostDetailScreen|CreatePostScreen|CommunityDetailScreen|MyActivityScreen)\(|[^a-zA-Z]CommunityScreen\(');
    final offenders = <String>[];
    for (final f in Directory('lib').listSync(recursive: true).whereType<File>()) {
      final path = f.path.replaceAll('\\', '/');
      if (!path.endsWith('.dart') || old.contains(path) || path.startsWith('lib/screens/community/')) continue;
      for (final l in _live(f.readAsStringSync())) {
        if (pushes.hasMatch(l)) offenders.add('$path: $l');
      }
    }
    expect(offenders, isEmpty);
  });

  test('every community screen has a named route', () {
    final chrome = _read('lib/screens/community/community_chrome.dart');
    for (final r in [
      "kCommunityRoute = 'community'",
      "kCommunityRoomPrefix = 'community/room/'",
      "kCommunityPostPrefix = 'community/post/'",
      "kCommunityComposeRoute = 'community/compose'",
      "kCommunityProfileRoute = 'community/profile'",
      "kCommunityActivityRoute = 'community/activity'",
      "kCommunityModerationRoute = 'community/moderation'",
    ]) {
      expect(chrome, contains(r));
    }
    expect(RegExp(r'MaterialPageRoute<\w+>\(\s*(fullscreenDialog: true,\s*)?builder:[^;]*?settings:')
            .allMatches(chrome)
            .length,
        greaterThanOrEqualTo(7));
  });
}
