// =============================================================================
//  L3 contract — live sessions and recordings (docs/LEARNING-ARCHITECTURE.md §5)
// -----------------------------------------------------------------------------
//  LA-16 attendance from LiveKit · LA-17 the host who never arrives · LA-18 the
//  room's size · LA-19 / LA-9 recordings · LA-24 the 0075 fallback · LA-25
//  raise-hand limits · LA-29 the schedule rule in book_slot · LA-32 defaults.
//
//  Reads the LAST definition of each function across the migration set (see
//  learning_security_contract_test.dart for why), the edge functions' source,
//  and the app's call sites. The last group is the wiring gate: a server
//  function nobody calls is a feature that does not exist.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

List<File> _migrations() =>
    Directory('supabase/migrations')
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.sql'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));

String _code(String sql) =>
    sql.split('\n').where((l) => !l.trimLeft().startsWith('--')).join('\n');

String _all() =>
    _migrations().map((f) => _code(f.readAsStringSync())).join('\n');

({String file, String body}) _last(String name) {
  final head = 'create or replace function public.$name(';
  String? file;
  String? body;
  for (final f in _migrations()) {
    final code = _code(f.readAsStringSync());
    final at = code.lastIndexOf(head);
    if (at < 0) continue;
    final open = code.indexOf(RegExp(r'\$(fn)?\$'), at);
    final tag = code.startsWith(r'$fn$', open) ? r'$fn$' : r'$$';
    final close = code.indexOf(tag, open + tag.length);
    file = f.uri.pathSegments.last;
    body = code.substring(at, close);
  }
  if (body == null) fail('no definition of public.$name');
  return (file: file!, body: body);
}

String _src(String path) => File(path).readAsStringSync();

void main() {
  group('LA-16 · attendance is what LiveKit saw', () {
    test('the webhook proves LiveKit sent it before it writes anything', () {
      final s = _src('supabase/functions/livekit-webhook/index.ts');
      final raw = s.indexOf('await req.text()');
      final verify = s.indexOf('await verifiedByLiveKit(');
      final write = s.indexOf('.rpc("record_room_event"');
      expect(raw, greaterThan(0));
      expect(
        verify,
        greaterThan(raw),
        reason: 'hash the raw body, not a parse of it',
      );
      expect(write, greaterThan(verify));
      expect(s, contains('claims.sha256'));
      expect(s, contains('claims.iss !== LK_KEY'));
    });

    test('record_room_event is the server\'s alone, and idempotent per event', () {
      final all = _all();
      expect(
        all,
        contains(
          'revoke all on function public.record_room_event(jsonb) from public, anon, authenticated',
        ),
      );
      expect(
        all,
        contains(
          'grant execute on function public.record_room_event(jsonb) to service_role',
        ),
      );
      final d = _last('record_room_event');
      expect(d.body, contains('insert into public.livekit_webhook_events'));
      expect(d.body, contains("return 'duplicate'"));
      expect(d.body, contains("'livekit'"));
    });

    test('settling prefers LiveKit and falls back to the phone', () {
      final d = _last('_settle_slot');
      expect(d.body, contains("cs.source = 'livekit'"));
      expect(
        d.body,
        contains('not v_seen and exists'),
        reason: 'the phone\'s row must still count when LiveKit saw nobody',
      );
      expect(
        _last('settle_my_bookings').body,
        contains('public._settle_slot('),
      );
    });
  });

  group('LA-17 · the host who never arrives', () {
    test('host-missed cancels with a reason, never a new status', () {
      final d = _last('_declare_host_missed');
      expect(
        d.body,
        contains("set status = 'cancelled', cancel_reason = 'host_missed'"),
      );
      expect(
        d.body,
        contains('set booking_id = null, spent_at = null'),
        reason: 'her credit comes back',
      );
      expect(
        _all(),
        isNot(contains("status = 'host_missed'")),
        reason: 'an installed app reads an unknown status as upcoming',
      );
    });

    test('no host-missed without LiveKit evidence', () {
      final d = _last('sweep_live_sessions');
      final declare = d.body.indexOf('perform public._declare_host_missed(');
      final evidence = d.body.indexOf("cs.source = 'livekit'");
      expect(evidence, greaterThan(0));
      expect(declare, greaterThan(evidence));
      expect(d.body, contains("'host_unknown'"));
      expect(d.body, contains("'host_late'"));
      expect(_all(), contains("'live-sessions-sweep'"));
    });

    test('a host-missed purchase is refundable whatever the date', () {
      final d = _last('_refund_check');
      final missed = d.body.indexOf("'host_missed'");
      final window = d.body.indexOf("'window_closed'");
      expect(missed, greaterThan(0));
      expect(
        window,
        greaterThan(missed),
        reason: 'checked before the window rule',
      );
    });

    test('the internals are closed to users', () {
      final all = _all();
      for (final f in [
        '_settle_slot(text)',
        '_declare_host_missed(text)',
        'sweep_live_sessions()',
        '_host_seen(text)',
      ]) {
        expect(
          all,
          contains(
            'revoke all on function public.$f from public, anon, authenticated',
          ),
          reason: f,
        );
      }
    });
  });

  group('LA-18 / LA-24 · livekit-token', () {
    final s = _src('supabase/functions/livekit-token/index.ts');

    test('the room is created with a size before the token is minted', () {
      final ensure = s.indexOf('await ensureRoom(room, slotId, authClient)');
      final mint = s.indexOf('const token = await signJwt(', ensure);
      expect(ensure, greaterThan(0));
      expect(mint, greaterThan(ensure));
      expect(s, contains('max_participants'));
      expect(s, contains('.rpc("room_max_participants"'));
    });

    test('the 0075 fallback is gone', () {
      expect(s, isNot(contains('.rpc("join_room_for_booking"')));
    });
  });

  group('LA-19 / LA-9 · recordings', () {
    test(
      'Mux assets are signed, and playback is signed after the access rule',
      () {
        final hook = _src('supabase/functions/livekit-webhook/index.ts');
        expect(hook, contains('playback_policy: ["signed"]'));
        expect(hook, isNot(contains('"public"')));
        final play = _src('supabase/functions/recording-playback/index.ts');
        final ask = play.indexOf('authClient.rpc("recording_for_playback"');
        final sign = play.indexOf('await Promise.all([muxToken(');
        expect(ask, greaterThan(0));
        expect(sign, greaterThan(ask));
        expect(play, contains('const TTL_S = 2 * 3600'));
      },
    );

    test('a consult is never recorded', () {
      expect(_last('begin_recording').body, contains('s.capacity <= 1'));
    });

    test('nothing about a recording is readable by a client', () {
      final all = _all();
      expect(
        all,
        contains(
          'revoke all on public.programme_recordings from anon, authenticated',
        ),
      );
      expect(all, contains("values ('recordings', 'recordings', false)"));
      expect(
        _last('_recording_access').body,
        contains("public.has_course_access(r.programme_id, 'recording')"),
      );
    });

    test('the mux webhook checks Mux\'s signature and refuses replays', () {
      final s = _src('supabase/functions/mux-webhook/index.ts');
      expect(s, contains('mux-signature'));
      expect(s, contains('> 300'));
    });
  });

  group('LA-29 / LA-32 · book_slot', () {
    final d = _last('book_slot');

    test('a new consult slot must fit the doctor\'s schedule', () {
      final fits = d.body.indexOf('public.slot_fits_schedule(');
      final insert = d.body.indexOf('insert into public.booking_slots');
      expect(fits, greaterThan(0), reason: d.file);
      expect(insert, greaterThan(fits));
    });

    test('the phone arguments have defaults (expand)', () {
      for (final p in [
        'p_expert_id',
        'p_starts_utc',
        'p_duration_min',
        'p_capacity',
        'p_stage',
        'p_title',
      ]) {
        expect(
          d.body,
          matches(RegExp('$p\\s+\\w+\\s+default null')),
          reason: p,
        );
      }
    });

    test('the schedule rule reads in IST', () {
      expect(
        _last('slot_fits_schedule').body,
        contains("at time zone 'Asia/Kolkata'"),
      );
    });
  });

  group('LA-32 · contract: the app sends what the server needs, no more', () {
    test('every slot value is optional, and a null leaves the key out', () {
      final repo = _src('lib/services/remote/supabase_repo.dart');
      for (final p in [
        "'p_expert_id': ?expertId",
        "'p_starts_utc': ?startsUtc",
        "'p_duration_min': ?durationMin",
        "'p_capacity': ?capacity",
        "'p_title': ?title",
        "'p_join_url': ?joinUrl",
      ]) {
        expect(repo, contains(p));
      }
    });

    test('an offering the server prices is booked by its ids', () {
      final store = _src('lib/booking/booking_store.dart');
      expect(store, contains('offeringHasServerPrice(offering)'));
      expect(store, contains('expertId: serverKnows ? null : slot.expertId'));
      expect(store,
          contains('startsUtc: (!serverKnows || consult) ? slot.startsUtc : null'));
    });

    test('a doctor with no saved schedule is offered the starter clinic the server assumes', () {
      final cat = _src('lib/booking/booking_catalog.dart');
      expect(cat, contains('        return _fromSchedule(at, o);'));
      expect(cat, contains('        // return _calendar(at, o, seed);'));
      expect(_last('slot_fits_schedule').body, contains('public._starter_schedule()'));
    });
  });

  group('the wiring gate · every new server function has a caller', () {
    String lib(String path) => _src(path);

    test('session_state is asked by both waiting rooms', () {
      expect(
        lib('lib/services/remote/supabase_repo.dart'),
        contains("rpc('session_state'"),
      );
      expect(
        lib('lib/booking/group_call_screen.dart'),
        contains('SupabaseRepo.sessionState('),
      );
      expect(
        lib('lib/booking/call_screen.dart'),
        contains('SupabaseRepo.sessionState('),
      );
    });

    test(
      'my_recordings feeds Your bookings, and the player asks for playback',
      () {
        expect(
          lib('lib/services/remote/supabase_repo.dart'),
          contains("rpc('my_recordings')"),
        );
        expect(
          lib('lib/booking/booking_store.dart'),
          contains('SupabaseRepo.myRecordings()'),
        );
        expect(
          lib('lib/screens/learn/pv_my_learning_screen.dart'),
          contains('syncRecordings()'),
        );
        expect(
          lib('lib/screens/learn/pv_my_learning_screen.dart'),
          contains('pvOpenRecording('),
        );
        expect(
          lib('lib/screens/learn/pv_recording_screen.dart'),
          contains("'recording-playback'"),
        );
        expect(
          lib('lib/screens/learn/pv_lesson_screen.dart'),
          contains('pvFetchPlayback('),
        );
      },
    );

    test('the host controls reach livekit-moderate', () {
      final call = lib('lib/booking/call_session.dart');
      expect(call, contains("'silenceHand'"));
      expect(call, contains("'stopRecording'"));
      final group = lib('lib/booking/group_call_screen.dart');
      expect(group, contains('CallModeration.silenceHand('));
      expect(group, contains('CallModeration.stopRecording('));
      final mod = _src('supabase/functions/livekit-moderate/index.ts');
      expect(mod, contains('case "silenceHand"'));
      expect(mod, contains('case "stopRecording"'));
      expect(mod, contains('.rpc("recording_egress_for_slot"'));
    });

    test('the server-side callers exist for the server-only functions', () {
      final hook = _src('supabase/functions/livekit-webhook/index.ts');
      expect(hook, contains('.rpc("begin_recording"'));
      final token = _src('supabase/functions/livekit-token/index.ts');
      expect(token, contains('.rpc("room_max_participants"'));
      final play = _src('supabase/functions/recording-playback/index.ts');
      expect(play, contains('rpc("lesson_video"'));
      expect(_last('book_slot').body, contains('public.slot_fits_schedule('));
      expect(_all(), contains('select public.sweep_live_sessions();'));
    });
  });
}
