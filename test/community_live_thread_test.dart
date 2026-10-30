// Community phase 3, C3-1: the live thread (0145).
//
// Three things are held here:
//   1. the SERVER CONTRACT, read from the migration: the signal carries only
//      the post id, phones may listen but never send, a failed signal never
//      blocks a reply, and nothing of 0137 is rewritten (C13);
//   2. the STORE: a signal re-reads into a waiting buffer, never into the
//      list on screen, and her own replies never count as new;
//   3. the SCREEN: a reply from another phone raises "1 new reply", the list
//      does not change until she taps it, and the post screen is wired.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/models/pv_community.dart';
import 'package:parentveda/screens/community/community_post_screen.dart';
import 'package:parentveda/services/pv_community_store.dart';
import 'package:parentveda/services/remote/supabase_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';

String _sql() => File('supabase/migrations/0145_community_live_thread.sql').readAsStringSync();

/// The SQL with its comments stripped, so a rule cannot pass by being
/// mentioned in a comment.
String _code() => _sql().split('\n').map((l) => l.replaceFirst(RegExp(r'--.*$'), '')).join('\n');

Map<String, dynamic> _reply(String id, String body, {bool mine = false, String? parent}) => {
      'id': id,
      'post_id': 'post_live',
      'parent_id': parent,
      'author': {'label': mine ? 'Quiet Monsoon' : 'Rain Mango', 'anon': true, 'seed': 9, 'is_mine': mine},
      'body': body,
      'like_count': 0,
      'created_at': DateTime.now().toUtc().toIso8601String(),
    };

class _FakeServer {
  final replies = <Map<String, dynamic>>[_reply('c_first_one', 'Dry khakhra before getting up.')];
  final calls = <String>[];

  Future<dynamic> call(String fn, Map<String, dynamic> p) async {
    calls.add(fn);
    switch (fn) {
      case 'community_me':
        return {'signed_in': true, 'joined': true, 'pseudonym': 'Quiet Monsoon', 'seed': 5, 'is_mod': false};
      case 'community_rooms_list':
        return [
          {'id': 'preg_first_trimester', 'title': 'First trimester', 'stage': 'pregnancy', 'mark': 'tab:sunrise', 'hue': 26},
        ];
      case 'community_post':
        return {
          'id': 'post_live',
          'room_id': 'preg_first_trimester',
          'room_title': 'First trimester',
          'author': {'label': 'Sunny Tamarind', 'anon': true, 'seed': 3, 'is_mine': false},
          'title': 'Week 9 and I cannot keep anything down',
          'body': '',
          'status': 'live',
          'created_at': DateTime.now().toUtc().toIso8601String(),
        };
      case 'community_comments_list':
        return [...replies];
      default:
        return {'ok': true};
    }
  }
}

void main() {
  group('0145: the server contract', () {
    test('the signal carries the post id and nothing else', () {
      final code = _code();
      final send = RegExp(r'realtime\.send\(([\s\S]*?)\);').firstMatch(code);
      expect(send, isNotNull, reason: 'the trigger must call realtime.send');
      final args = send!.group(1)!;
      expect(args, contains("jsonb_build_object('post_id', new.post_id)"));
      expect(args, isNot(contains('user_id')));
      expect(args, isNot(contains('body')));
      expect(args, isNot(contains('author')));
      expect(args, contains("'post:' || new.post_id"));
      expect(args, contains('true'), reason: 'private topic: the SELECT policy decides who hears it');
    });

    test('phones may listen, never send', () {
      final code = _code();
      expect(code, contains('create policy community_post_listen on realtime.messages'));
      expect(code, contains('for select to authenticated'));
      expect(RegExp(r'on realtime\.messages\s+for (insert|all|update|delete)', caseSensitive: false).hasMatch(code), isFalse);
      expect(code, contains('revoke all on function public.community_can_listen(text) from public, anon;'));
      expect(code, contains('public.community_can_see(p)'), reason: 'listening uses the same rule as reading');
    });

    test('a failed signal never blocks a reply', () {
      final body = RegExp(r'perform realtime\.send[\s\S]*?end;').firstMatch(_code())!.group(0)!;
      expect(body, contains('exception when others then'));
    });

    test('hung on a trigger; nothing of 0137 is rewritten (C13)', () {
      final code = _code();
      expect(code, contains('after insert or update of status, deleted_at on public.community_comments'));
      for (final f in ['community_comment(', 'community_comments_list(', '_community_timetable_notice(', 'community_can_see(p public']) {
        expect(code, isNot(contains('function public.$f')), reason: '$f must not be redefined here');
      }
    });
  });

  group('the store', () {
    test('only replies she has not seen, and never her own, count as new', () {
      PvCommunityComment c(String id, {bool mine = false}) => PvCommunityComment.fromJson(_reply(id, 'x', mine: mine))!;
      final shown = [c('a'), c('b')];
      expect(communityNewReplyIds(shown, [c('a'), c('b')]), isEmpty);
      expect(communityNewReplyIds(shown, [c('a'), c('mine1', mine: true), c('b'), c('n1')]), ['n1']);
      expect(communityNewReplyIds(shown, [c('a')]), isEmpty, reason: 'a removal is not news');
    });

    test('signed out, nothing listens', () {
      final store = PvCommunityStore.instance..debugReset();
      var asked = 0;
      store.debugSignedIn = false;
      store.debugListen = (_, _) {
        asked++;
        return PvLiveListen(() {});
      };
      store.watchPost('post_live');
      expect(asked, 0);
      expect(store.newReplies('post_live'), 0);
      store.debugReset();
    });
  });

  group('the screen', () {
    late _FakeServer server;
    final store = PvCommunityStore.instance;
    void Function()? signal;
    String? topic;
    var closed = 0;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      store.debugReset();
      server = _FakeServer();
      store.debugBackend = server.call;
      store.debugSignedIn = true;
      signal = null;
      closed = 0;
      store.debugListen = (t, s) {
        topic = t;
        signal = s;
        return PvLiveListen(() => closed++);
      };
      await store.init();
      await store.refreshMe();
    });

    tearDown(() => store.debugReset());

    testWidgets('another phone\'s reply raises the pill; the list waits for her tap', (t) async {
      await t.pumpWidget(const MaterialApp(home: CommunityPostScreen(postId: 'post_live')));
      await t.pumpAndSettle();
      expect(topic, 'post:post_live');
      expect(find.text('Dry khakhra before getting up.'), findsOneWidget);
      expect(find.byKey(const ValueKey('community_new_replies_pill')), findsNothing);

      server.replies.add(_reply('c_new_one', 'Ginger tea in small sips.'));
      signal!();
      signal!(); // two signals in a burst are one re-read
      final reads = server.calls.where((c) => c == 'community_comments_list').length;
      await t.pump(const Duration(milliseconds: 800));
      await t.pumpAndSettle();
      expect(server.calls.where((c) => c == 'community_comments_list').length, reads + 1);

      expect(find.text('1 new reply'), findsOneWidget);
      expect(find.text('Ginger tea in small sips.'), findsNothing, reason: 'the list never moves under her finger');

      await t.tap(find.text('1 new reply'));
      await t.pumpAndSettle();
      expect(find.text('Ginger tea in small sips.'), findsOneWidget);
      expect(find.byKey(const ValueKey('community_new_replies_pill')), findsNothing);
      await t.pump(const Duration(seconds: 3)); // the ring fades

      await t.pumpWidget(const SizedBox());
      expect(closed, 1, reason: 'leaving the post leaves the topic');
    });

    testWidgets('her own reply, arriving back from the server, raises nothing', (t) async {
      await t.pumpWidget(const MaterialApp(home: CommunityPostScreen(postId: 'post_live')));
      await t.pumpAndSettle();
      server.replies.add(_reply('c_mine_one', 'Thank you all.', mine: true));
      signal!();
      await t.pump(const Duration(milliseconds: 800));
      await t.pumpAndSettle();
      expect(find.byKey(const ValueKey('community_new_replies_pill')), findsNothing);
    });

    test('the post screen is wired to the live thread', () {
      final src = File('lib/screens/community/community_post_screen.dart').readAsStringSync();
      expect(src, contains('_store.watchPost(widget.postId)'));
      expect(src, contains('_store.unwatchPost(widget.postId)'));
      expect(src, contains('_store.showNewReplies(widget.postId)'));
      final repo = File('lib/services/remote/supabase_repo.dart').readAsStringSync();
      expect(repo, contains('RealtimeChannelConfig(private: true)'));
    });
  });
}
