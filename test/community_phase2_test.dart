// Community phase 2 against a fake server (0137). L4a: course discussions,
// the team voice, experts and the moved-session notice. L4b adds birth
// clubs, following, search and edit to this file.
//
// `PvCommunityStore.debugBackend` answers in place of Supabase, so these run
// the real store and the real screens with no network and no mocks.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/models/pv_community.dart';
import 'package:parentveda/screens/community/community_compose_screen.dart';
import 'package:parentveda/screens/community/community_offering_thread.dart';
import 'package:parentveda/screens/community/community_post_screen.dart';
import 'package:parentveda/screens/community/community_room_screen.dart';
import 'package:parentveda/services/pv_community_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

String _now([Duration ago = Duration.zero]) => DateTime.now().subtract(ago).toUtc().toIso8601String();

class _Server {
  bool access = true;
  String? reason;
  bool crisisPost = false;
  bool expert = false;
  final calls = <String, Map<String, dynamic>>{};

  Map<String, dynamic> get room => {
        'id': 'run_mc1_r2',
        'title': 'Sleep 101',
        'blurb': 'Batch 2',
        'kind': 'offering',
        'mark': 'tab:openBook',
        'programme_id': 'mc1',
        'run_id': 'mc1_r2',
        'access': access,
        'joined': access,
      };

  List<Map<String, dynamic>> posts() => [
        {
          'id': 'tn_notice_1',
          'room_id': 'run_mc1_r2',
          'room_title': 'Sleep 101',
          'room_kind': 'offering',
          'author': {'label': 'ParentVeda team', 'anon': false, 'team': true},
          'title': 'Session moved: Night waking',
          'body': 'This session has moved from Tue 17 Nov, 7:00 pm to Fri 20 Nov, 7:00 pm (India time).',
          'pinned': true,
          'about': {'kind': 'session', 'id': 's3'},
          'moved_from': '2026-11-17T13:30:00Z',
          'created_at': _now(const Duration(hours: 2)),
        },
        {
          'id': 'post_ritu_01',
          'room_id': 'run_mc1_r2',
          'room_title': 'Sleep 101',
          'room_kind': 'offering',
          'author': {'label': 'Ritu', 'anon': false},
          'title': 'Her nap moved from 10 to 11.30 this week',
          'about': {'kind': 'lesson', 'id': 'l2'},
          'comment_count': 3,
          'created_at': _now(const Duration(hours: 5)),
        },
        {
          'id': 'post_mine_01',
          'room_id': 'feeding',
          'room_title': 'Breast and bottle',
          'author': {'label': 'Quiet Monsoon', 'anon': true, 'seed': 5, 'is_mine': true},
          'title': crisisPost ? 'I cannot go on like this' : 'Feeding every 90 minutes at 5 weeks?',
          'created_at': _now(const Duration(hours: 3)),
        },
      ];

  Future<dynamic> call(String fn, Map<String, dynamic> p) async {
    calls[fn] = p;
    switch (fn) {
      case 'community_me':
        return {
          'signed_in': true,
          'joined': true,
          'pseudonym': 'Quiet Monsoon',
          'seed': 5,
          'first_name': 'Ananya',
          'expert': expert ? {'name': 'Dr Kavya Menon', 'category': 'Lactation consultant'} : null,
        };
      case 'community_rooms_list':
        return [
          {'id': 'feeding', 'title': 'Breast and bottle', 'stage': 'parenting', 'mark': 'tab:hotBottle', 'joined': true},
          if (access) room,
        ];
      case 'community_offering_room':
        return {'ok': true, 'access': access, 'reason': reason, 'is_host': false, 'is_mod': false, 'room': room};
      case 'community_feed':
        final all = posts();
        final about = p['p_about_kind'];
        return [
          for (final x in all)
            if (p['p_scope'] != 'room' || x['room_id'] == p['p_room'])
              if (about == null || (x['about'] is Map && (x['about'] as Map)['id'] == p['p_about_id'])) x,
        ];
      case 'community_post':
        return posts().where((x) => x['id'] == p['p_id']).firstOrNull;
      case 'community_comments_list':
        return [
          {
            'id': 'c_expert_1',
            'post_id': p['p_post'],
            'author': {
              'label': 'Kavya',
              'anon': false,
              'expert': {'name': 'Dr Kavya Menon', 'category': 'Lactation consultant'},
            },
            'body': 'Short feeds close together are common at this age.',
            'created_at': _now(),
          },
          {
            'id': 'c_member_1',
            'post_id': p['p_post'],
            'author': {'label': 'Rain Mango', 'anon': true, 'seed': 9},
            'body': 'Cluster feeding passed by week 7 for us.',
            'endorsements': [
              {'name': 'Dr Kavya Menon', 'category': 'Lactation consultant'},
            ],
            'created_at': _now(),
          },
        ];
      case 'community_ask_expert':
        return crisisPost ? {'ok': false, 'reason': 'crisis'} : {'ok': true};
      case 'community_create_post':
        return {'ok': true, 'status': 'live', 'crisis': false};
      default:
        return {'ok': true};
    }
  }
}

void main() {
  late _Server server;
  final store = PvCommunityStore.instance;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    store.debugReset();
    server = _Server();
    store.debugBackend = server.call;
    store.debugSignedIn = true;
    await store.init();
    await store.refreshMe();
  });

  tearDown(() => store.debugReset());

  Widget app(Widget home) => MaterialApp(home: Scaffold(body: SingleChildScrollView(child: home)));

  group('course discussion on the course page', () {
    testWidgets('without a seat: the invitation, never hidden', (t) async {
      server.access = false;
      server.reason = 'book';
      await t.pumpWidget(app(const CommunityOfferingThread(programmeId: 'mc1', expertName: 'Dr Kavya Menon')));
      await t.pumpAndSettle();
      expect(find.byKey(const ValueKey('community_offering_invitation')), findsOneWidget);
      expect(find.textContaining('Opens when you book your seat.'), findsOneWidget);
      expect(find.text('Batch 2 discussion'), findsOneWidget);
      expect(find.text('Open the discussion'), findsNothing);
      // The phone asked the server; it did not decide.
      expect(server.calls['community_offering_room']?['p_programme'], 'mc1');
    });

    testWidgets('after a refund it says the room closed with it', (t) async {
      server.access = false;
      server.reason = 'refunded';
      await t.pumpWidget(app(const CommunityOfferingThread(programmeId: 'mc1')));
      await t.pumpAndSettle();
      expect(find.textContaining('It closed with your refund.'), findsOneWidget);
    });

    testWidgets('with a seat: the pinned notice first, then the newest posts', (t) async {
      await t.pumpWidget(app(const CommunityOfferingThread(programmeId: 'mc1')));
      await t.pumpAndSettle();
      expect(find.byKey(const ValueKey('community_pinned_notice_tn_notice_1')), findsOneWidget);
      expect(find.textContaining('Pinned · ParentVeda team'), findsOneWidget);
      expect(find.text('Her nap moved from 10 to 11.30 this week'), findsOneWidget);
      expect(find.text('Open the discussion'), findsOneWidget);
    });
  });

  group('course posts', () {
    test('a post about a lesson carries it to the server and stays out of For you', () async {
      await store.offeringRoom('mc1');
      final o = await store.createPost(
        roomId: 'run_mc1_r2',
        anon: false,
        title: 'Question about naps',
        about: const PvPostAbout(kind: 'lesson', id: 'l2'),
      );
      expect(o, PvCommunityOutcome.live);
      final sent = server.calls['community_create_post']!;
      expect(sent['p_about_kind'], 'lesson');
      expect(sent['p_about_id'], 'l2');
      expect(store.feed(PvCommunityStore.feedKey()).where((p) => p.roomId == 'run_mc1_r2'), isEmpty);
    });

    test('the lesson tab asks for only that lesson', () async {
      await store.offeringRoom('mc1');
      await store.loadFeed(
          scope: 'room', sort: 'new', room: 'run_mc1_r2', about: const PvPostAbout(kind: 'lesson', id: 'l2'));
      expect(server.calls['community_feed']?['p_about_id'], 'l2');
      expect(CommunityLessonThread.postsFor('mc1', 'l2').single.id, 'post_ritu_01');
    });

    test('a moved session is read from the pinned team notice (LA-22)', () async {
      await store.loadCourseNotices('mc1');
      expect(store.movedFrom('ps_s3'), DateTime.parse('2026-11-17T13:30:00Z').toLocal());
      expect(store.movedFrom('ps_other'), isNull);
      expect(store.movedFrom('generated_slot'), isNull);
    });

    testWidgets('the room screen: no Join, the batch line, about pills', (t) async {
      await store.offeringRoom('mc1');
      await t.pumpWidget(const MaterialApp(home: CommunityRoomScreen(roomId: 'run_mc1_r2')));
      await t.pumpAndSettle();
      expect(find.byKey(const ValueKey('community_room_offering_line')), findsOneWidget);
      expect(find.text('Join room'), findsNothing);
      expect(find.text('A live session'), findsOneWidget); // the notice's session pill
      expect(server.calls.containsKey('community_room_seen'), isTrue);
    });

    testWidgets('composing in a course: first name, and she is told once (B4)', (t) async {
      await store.offeringRoom('mc1');
      await t.pumpWidget(const MaterialApp(
        home: CommunityComposeScreen(
          roomId: 'run_mc1_r2',
          about: PvPostAbout(kind: 'lesson', id: 'l2'),
          aboutLabel: 'Lesson 2',
        ),
      ));
      await t.pumpAndSettle();
      expect(find.byKey(const ValueKey('community_compose_course_heads_up')), findsOneWidget);
      expect(find.textContaining('your first name, Ananya'), findsOneWidget);
      expect(find.text('About: Lesson 2'), findsOneWidget);
      expect(find.text('Others see Ananya.'), findsOneWidget);
      // Once per phone.
      expect(await store.courseHeadsUpDue(), isFalse);
    });
  });

  group('experts', () {
    testWidgets('an expert reply carries the seal, its name and the footer', (t) async {
      await store.loadFeed(scope: 'mine', sort: 'new');
      await t.pumpWidget(const MaterialApp(home: CommunityPostScreen(postId: 'post_mine_01')));
      await t.pumpAndSettle();
      expect(find.text('General guidance from a verified expert, not a diagnosis. For your own care, ask your doctor.'),
          findsOneWidget);
      expect(find.text('Found helpful by Dr Kavya Menon, Lactation consultant'), findsOneWidget);
      // The seal on the expert's face, and the one on the endorsement line.
      expect(find.byIcon(Icons.verified_rounded), findsNWidgets(2));
    });

    testWidgets('the Experts pill is always there', (t) async {
      await store.loadFeed(scope: 'mine', sort: 'new');
      await t.pumpWidget(const MaterialApp(home: CommunityPostScreen(postId: 'post_mine_01')));
      await t.pumpAndSettle();
      await t.tap(find.text('Experts'));
      await t.pumpAndSettle();
      // Both replies stay: one is the expert's, one an expert endorsed.
      expect(find.text('Short feeds close together are common at this age.'), findsOneWidget);
      expect(find.text('Cluster feeding passed by week 7 for us.'), findsOneWidget);
    });

    test('asking an expert about a crisis post is refused with the moderator line', () async {
      server.crisisPost = true;
      await store.loadFeed(scope: 'mine', sort: 'new');
      expect(await store.askExpert('post_mine_01'), 'crisis');
      expect(store.post('post_mine_01')!.expertAsked, isFalse);
      server.crisisPost = false;
      expect(await store.askExpert('post_mine_01'), 'ok');
      expect(store.post('post_mine_01')!.expertAsked, isTrue);
    });

    test('an expert writes under her badge without a community name', () async {
      server.expert = true;
      await store.refreshMe();
      final face = store.myFace(anon: false);
      expect(face.expert?.name, 'Dr Kavya Menon');
      expect(store.me.isExpert, isTrue);
    });
  });
}
