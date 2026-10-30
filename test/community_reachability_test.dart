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

  // One place in every stage (user, 2026-10-28): each More screen has its own
  // Community section with the same row, and TTC's You no longer carries one.
  test('Community sits in the same place on every More screen', () {
    for (final f in [
      'lib/screens/pregnancy/preg_more_screen.dart',
      'lib/screens/ttc/ttc_more_tab.dart',
      'lib/screens/post_pregnancy/pp_more_screen.dart',
    ]) {
      final src = _live(_read(f)).join('\n');
      expect(src, contains("'Rooms for your stage, to read or to talk'"), reason: f);
      expect(src, contains("'Kind, moderated rooms for every stage'"), reason: f);
      expect(src, contains('openCommunity('), reason: f);
    }
    expect(_live(_read('lib/screens/profile/pv_you_content.dart')).join('\n'), isNot(contains('_ttcCommunity()')));
  });

  // IT Rules 2021, Rule 3(2): the grievance officer's name and contact are
  // shown where members see them (house rules, the room's rules, the report
  // thank-you). Named by the user 2026-10-28.
  test('the grievance officer is shown in the community', () {
    final chrome = _read('lib/screens/community/community_chrome.dart');
    expect(chrome, contains("kCommunityGrievanceOfficer = 'Deepti Sekhri'"));
    expect(chrome, contains("kCommunityGrievanceEmail = 'parentvedateam@gmail.com'"));
    final uses = RegExp(r'CommunityGrievanceLine\(').allMatches(
        _live(chrome).join(' ') + _live(_read('lib/screens/community/community_room_screen.dart')).join(' '));
    expect(uses.length, greaterThanOrEqualTo(4), reason: 'house rules, room rules, report thank-you, plus the class');
  });

  // Phase 2, L4a (0137): every new way in is mounted where the plan put it.
  test('course discussions are reachable from the course page and the lesson', () {
    final offering = _live(_read('lib/screens/learn/pv_offering_screen.dart')).join('\n');
    expect(offering, contains('CommunityOfferingThread('));
    expect(offering, contains('v.offering?.grant.discussionThread == true'));
    final lesson = _live(_read('lib/screens/learn/pv_lesson_screen.dart')).join('\n');
    expect(lesson, contains('CommunityLessonThread('));
    expect(lesson, contains('_LessonTabs('));
    // A moved class says so on its booking card.
    final mine = _live(_read('lib/screens/learn/pv_my_learning_screen.dart')).join('\n');
    expect(mine, contains('PvCommunityStore.instance.movedFrom('));
    expect(mine, contains('loadCourseNotices('));
    // The section opens the room; the room opens the team voice.
    expect(_read('lib/screens/community/community_offering_thread.dart'), contains('openCommunityRoom(context, o.room.id)'));
    expect(_live(_read('lib/screens/community/community_room_screen.dart')).join('\n'), contains('asTeam: true'));
  });

  test('the doctor app reaches Your offerings and the expert queue', () {
    expect(_live(_read('lib/main_doctor.dart')).join('\n'), contains('PvCommunityStore.instance.init()'));
    final home = _live(_read('lib/screens/doctor/doctor_home_tab.dart')).join('\n');
    expect(home, contains('DoctorOfferingsSection('));
    final offerings = _live(_read('lib/screens/doctor/doctor_offerings_screen.dart')).join('\n');
    expect(offerings, contains('openDoctorCommunityQueue(context)'));
    expect(offerings, contains('openDoctorOfferings(context)'));
    expect(offerings, contains('openCommunityRoom(context, room.room.id)'));
    expect(_read('lib/screens/doctor/doctor_community_queue_screen.dart'), contains('openCommunityPost(context, q.post.id)'));
  });

  test('every phase 2 store call is made from a screen', () {
    final screens = [
      for (final f in Directory('lib/screens').listSync(recursive: true))
        if (f is File && f.path.endsWith('.dart')) _live(f.readAsStringSync()).join('\n'),
    ].join('\n');
    for (final call in [
      '.offeringRoom(',
      '.roomSeen(',
      '.createPrompt(',
      '.pin(',
      '.askExpert(',
      '.expertQueue(',
      '.expertClaim(',
      '.endorse(',
      '.myOfferings(',
      '.movedFrom(',
    ]) {
      expect(screens, contains(call), reason: '$call has no caller in lib/screens');
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
