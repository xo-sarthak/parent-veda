// The safety words exist twice: the server's rule (0121
// `community_check_text`) and the phone's mirror (community_safety.dart),
// which shows the helplines while she types. If they drift, the phone stays
// quiet on a phrase the server flags, or the reverse. This keeps them equal.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/services/community_safety.dart';

List<String> _between(String src, String start, String end) {
  final body = src.split(start)[1].split(end)[0];
  return [
    for (final m in RegExp(r"""('(?:[^']|'')*'|"[^"]*")""").allMatches(body))
      m.group(0)!.substring(1, m.group(0)!.length - 1).replaceAll("''", "'"),
  ];
}

void main() {
  final sql = File('supabase/migrations/0121_community.sql').readAsStringSync();
  final dart = File('lib/services/community_safety.dart').readAsStringSync();

  test('crisis phrases match the server', () {
    final s = _between(sql, '-- CRISIS-PHRASES-START', '-- CRISIS-PHRASES-END');
    final d = _between(dart, '// CRISIS-PHRASES-START', '// CRISIS-PHRASES-END');
    expect(s, isNotEmpty);
    expect(d.toSet(), s.toSet());
    expect(kCommunityCrisisPhrases.toSet(), s.toSet());
  });

  test('hold words match the server', () {
    final s = _between(sql, '-- HOLD-WORDS-START', '-- HOLD-WORDS-END');
    final d = _between(dart, '// HOLD-WORDS-START', '// HOLD-WORDS-END');
    expect(s, isNotEmpty);
    expect(d.toSet(), s.toSet());
  });

  test('the phone flags a crisis while she types, curly quotes too', () {
    expect(communityLooksLikeCrisis("Some days I can't go on"), isTrue);
    expect(communityLooksLikeCrisis('Some days I can’t go on'), isTrue);
    expect(communityLooksLikeCrisis('I want to die some nights'), isTrue);
    expect(communityLooksLikeCrisis('Week 9 and so tired of the nausea'), isFalse);
  });

  test('links, numbers and abuse are held; ordinary words are not', () {
    expect(communityHoldReason('DM me on wa.me/919999999999'), 'link');
    expect(communityHoldReason('call me 9876543210'), 'phone');
    expect(communityHoldReason('my MIL is a bitch'), 'language');
    // Word-bounded: a word containing a held word is fine.
    expect(communityHoldReason('Dickens was my favourite at school'), isNull);
    expect(communityHoldReason('Scunthorpe is far'), isNull);
    expect(communityHoldReason('Week 20 scan is on the 14th'), isNull);
  });

  test('every helpline has a number', () {
    expect(kCommunityHelplines, isNotEmpty);
    for (final h in kCommunityHelplines) {
      expect(RegExp(r'^\d{3,12}$').hasMatch(h.number), isTrue, reason: h.name);
    }
  });
}
