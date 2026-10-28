// The community store and screens, against a fake server.
//
// `PvCommunityStore.debugBackend` answers in place of Supabase, so these run
// the real store code (outbox, optimistic likes, rollbacks, outcomes) and
// the real screens with no network and no mocking framework.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/models/pv_community.dart';
import 'package:parentveda/screens/community/community_chrome.dart';
import 'package:parentveda/screens/community/community_compose_screen.dart';
import 'package:parentveda/screens/community/community_home_card.dart';
import 'package:parentveda/screens/community/community_home_screen.dart';
import 'package:parentveda/screens/community/community_post_screen.dart';
import 'package:parentveda/services/pv_community_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A tiny in-memory server: enough of 0121's answers to drive the app.
class _FakeServer {
  bool offline = false;
  bool joined = true;
  String nextStatus = 'live';
  bool refuseLikes = false;
  final calls = <String>[];
  final posts = <Map<String, dynamic>>[
    {
      'id': 'post_seed_one',
      'room_id': 'preg_first_trimester',
      'room_title': 'First trimester',
      'room_mark': 'tab:sunrise',
      'room_hue': 26,
      'author': {'label': 'Sunny Tamarind', 'anon': true, 'seed': 3, 'is_mine': false},
      'title': 'Week 9 and I cannot keep anything down',
      'body': 'What actually helped you?',
      'like_count': 4,
      'comment_count': 1,
      'liked': false,
      'status': 'live',
      'created_at': DateTime.now().toUtc().toIso8601String(),
    },
  ];

  Future<dynamic> call(String fn, Map<String, dynamic> p) async {
    calls.add(fn);
    if (offline) throw Exception('offline');
    switch (fn) {
      case 'community_me':
        return {
          'signed_in': true,
          'joined': joined,
          'pseudonym': joined ? 'Quiet Monsoon' : null,
          'seed': 5,
          'first_name': 'Ananya',
          'is_mod': false,
          'unread': 2,
        };
      case 'community_rooms_list':
        return [
          {'id': 'preg_first_trimester', 'title': 'First trimester', 'stage': 'pregnancy', 'mark': 'tab:sunrise', 'hue': 26, 'sort': 20, 'members': 3},
          {'id': 'ttc_loss', 'title': 'After a loss', 'stage': 'trying', 'mark': 'tab:cloudRain', 'hue': 220, 'sort': 14, 'members': 80},
        ];
      case 'community_feed':
        return posts;
      case 'community_post':
        return posts.where((x) => x['id'] == p['p_id']).firstOrNull;
      case 'community_comments_list':
        return [
          {
            'id': 'c_seed_one',
            'post_id': 'post_seed_one',
            'author': {'label': 'Rain Mango', 'anon': true, 'seed': 9},
            'body': 'Dry khakhra before getting up.',
            'like_count': 2,
            'created_at': DateTime.now().toUtc().toIso8601String(),
          },
        ];
      case 'community_create_post':
      case 'community_comment':
        return {'ok': true, 'status': nextStatus, 'crisis': false};
      case 'community_react':
        return refuseLikes ? {'ok': false, 'reason': 'gone'} : {'ok': true, 'count': 5};
      case 'community_join':
        joined = true;
        return {'ok': true, 'pseudonym': p['p_pseudonym']};
      default:
        return {'ok': true};
    }
  }
}

void main() {
  late _FakeServer server;
  final store = PvCommunityStore.instance;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    store.debugReset();
    server = _FakeServer();
    store.debugBackend = server.call;
    store.debugSignedIn = true;
    await store.init();
    await store.refreshMe();
  });

  tearDown(() => store.debugReset());

  group('store', () {
    test('a feed loads and caches; her standing comes from the server', () async {
      expect(await store.loadFeed(), isTrue);
      expect(store.feed(PvCommunityStore.feedKey()).single.title, contains('Week 9'));
      expect(store.me.joined, isTrue);
      expect(store.me.unread, 2);
    });

    test('offline: the post is kept on the phone and sent later, once', () async {
      server.offline = true;
      final o = await store.createPost(roomId: 'preg_first_trimester', anon: true, title: 'Is this normal at week 10?');
      expect(o, PvCommunityOutcome.queued);
      expect(store.unsentCount, 1);
      final mine = store.feed(PvCommunityStore.feedKey(scope: 'mine', sort: 'new'));
      expect(mine.first.sending, isTrue);
      expect(mine.first.author.label, 'Quiet Monsoon');

      server.offline = false;
      await store.flushOutbox();
      expect(store.unsentCount, 0);
      expect(server.calls.where((c) => c == 'community_create_post').length, 2); // one failed, one landed
      expect(store.post(mine.first.id)!.sending, isFalse);
    });

    test('a held post says so and stays on her screen', () async {
      server.nextStatus = 'held';
      final o = await store.createPost(roomId: 'preg_first_trimester', anon: true, title: 'Visit wa.me/123 for help');
      expect(o, PvCommunityOutcome.held);
      final mine = store.feed(PvCommunityStore.feedKey(scope: 'mine', sort: 'new'));
      expect(mine.first.waitingForReview, isTrue);
    });

    test('a like shows at once and rolls back when the server says no', () async {
      await store.loadFeed();
      server.refuseLikes = true;
      final f = store.toggleLike('post_seed_one');
      expect(store.post('post_seed_one')!.liked, isTrue); // optimistic
      expect(await f, isFalse);
      expect(store.post('post_seed_one')!.liked, isFalse);
      expect(store.post('post_seed_one')!.likeCount, 4);
    });

    test('logged out: no calls, the cache stays', () async {
      await store.loadFeed();
      store.debugSignedIn = false;
      expect(await store.loadFeed(), isFalse);
      expect(store.feed(PvCommunityStore.feedKey()), isNotEmpty);
    });

    test('a reply is queued offline and keeps its post count honest', () async {
      await store.loadFeed();
      server.offline = true;
      final o = await store.comment(postId: 'post_seed_one', anon: false, body: 'Same here');
      expect(o, PvCommunityOutcome.queued);
      expect(store.post('post_seed_one')!.commentCount, 2);
      expect(store.comments('post_seed_one')!.last.author.label, 'Ananya');
    });

    test('hiding a post takes it out of every feed on this phone', () async {
      await store.loadFeed();
      await store.hide('post_seed_one');
      expect(store.feed(PvCommunityStore.feedKey()), isEmpty);
    });
  });

  group('screens', () {
    Widget app(Widget home) => MaterialApp(home: home);

    testWidgets('home shows rooms for her stage and the feed', (t) async {
      await t.pumpWidget(app(const CommunityHomeScreen()));
      await t.pumpAndSettle();
      expect(find.text('Community'), findsOneWidget);
      expect(find.text('Rooms for you'), findsOneWidget);
      expect(find.text('Week 9 and I cannot keep anything down'), findsOneWidget);
      expect(find.text('Write a post'), findsWidgets);
    });

    testWidgets('the home card shows unread replies and a real question', (t) async {
      await store.loadFeed();
      await t.pumpWidget(app(const Scaffold(body: SingleChildScrollView(child: CommunityHomeCard()))));
      await t.pumpAndSettle();
      expect(find.text('2 new replies'), findsOneWidget);
      expect(find.text('Week 9 and I cannot keep anything down'), findsOneWidget);
    });

    testWidgets('first post: the house rules, then a community name', (t) async {
      server.joined = false;
      await store.refreshMe();
      await t.pumpWidget(app(Builder(
        builder: (c) => Scaffold(body: TextButton(onPressed: () => openCommunityCompose(c), child: const Text('go'))),
      )));
      await t.tap(find.text('go'));
      await t.pumpAndSettle();
      expect(find.text('A kind place to be honest'), findsOneWidget);
      await t.tap(find.text('I accept'));
      await t.pumpAndSettle();
      expect(find.text('Your community name'), findsOneWidget);
      await t.tap(find.text('Use this name'));
      await t.pumpAndSettle();
      expect(server.calls, contains('community_join'));
      expect(store.me.joined, isTrue);
    });

    testWidgets('composer: Post is top right and waits for a room and a title', (t) async {
      await t.pumpWidget(app(const CommunityComposeScreen(roomId: 'preg_first_trimester')));
      await t.pumpAndSettle();
      final post = find.text('Post');
      expect(post, findsOneWidget);
      // Top right: in the app bar, right of centre.
      final at = t.getCenter(post);
      expect(at.dy, lessThan(100));
      expect(at.dx, greaterThan(t.getSize(find.byType(Scaffold)).width / 2));
      expect(find.text('Add a title'), findsOneWidget);
      await t.enterText(find.byType(TextField).first, 'Is it normal to feel this tired?');
      await t.pumpAndSettle();
      expect(find.text('Add a title'), findsNothing);
    });

    testWidgets('composer: the helplines appear while she types', (t) async {
      await t.pumpWidget(app(const CommunityComposeScreen(roomId: 'preg_first_trimester')));
      await t.pumpAndSettle();
      expect(find.text('You do not have to carry this alone'), findsNothing);
      await t.enterText(find.byType(TextField).at(1), "Some days I can't go on");
      await t.pumpAndSettle();
      expect(find.text('You do not have to carry this alone'), findsOneWidget);
      expect(find.textContaining('Tele-MANAS'), findsOneWidget);
    });

    testWidgets('a post shows its replies and the reply bar', (t) async {
      await store.loadFeed();
      await t.pumpWidget(app(const CommunityPostScreen(postId: 'post_seed_one')));
      await t.pumpAndSettle();
      expect(find.text('Dry khakhra before getting up.'), findsOneWidget);
      expect(find.text('Reply as Quiet Monsoon'), findsOneWidget);
      expect(find.text('Top'), findsOneWidget);
    });
  });
}
