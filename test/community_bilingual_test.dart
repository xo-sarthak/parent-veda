// =============================================================================
//  Community is bilingual — and its topics kept their identity
// -----------------------------------------------------------------------------
//  Widening `topics` from List<String> to List<LocalizedText> touched three
//  jobs one list was doing at once: it is DRAWN as a chip, MATCHED to find
//  related posts, and SEARCHED. Only the first of those may follow the language
//  on screen. The other two must not move, or a mother who switches to Hindi
//  sees a feed that relates nothing to anything and a search box that finds
//  less than it did.
//
//  None of that fails to compile. `List<LocalizedText>.contains` still takes an
//  Object?, and LocalizedText has no operator ==, so the old matching code
//  survived the type change and would have compared object references forever.
//  So the invariants are pinned here instead, against the real seed data.
// =============================================================================

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/data/community_data.dart';
import 'package:parentveda/localization/app_language.dart';
import 'package:parentveda/models/community_models.dart';

/// Topic ids that are the SAME word in both languages by nature — acronyms and
/// a term she reads off a report. Anything else with en == hi is an untranslated
/// string wearing the costume of a finished one.
const _sameByNatureTopics = {'PCOS', 'Endometriosis', 'IVF', 'IUI'};

/// The same judgement for expert specialties.
const _sameByNatureSpecialties = {'Fertility', 'PCOS', 'IVF'};

List<Community> get _allRooms =>
    [...kCommunities, ...kTtcCommunities, ...kParentingCommunities];

List<CommunityPost> get _allSeedPosts =>
    [...kSeedPosts, ...kTtcPosts, ...kParentingPosts];

List<CommunityExpert> get _allExperts =>
    [...kCommunityExperts, ...kTtcExperts, ...kParentingExperts];

void main() {
  group('the topic vocabulary', () {
    test('every seed topic resolves to a real vocabulary entry', () {
      // topicNamed() falls back to English-on-both-sides for an id it has
      // never heard of. That fallback exists so a stored row never loses its
      // tag — it is NOT a licence for a seed to invent an id, because the
      // symptom would be a chip that stays English in Hindi and nothing else.
      final unknown = <String>{};
      for (final c in _allRooms) {
        for (final t in c.topics) {
          if (!kTopicNames.containsKey(t.en)) unknown.add('${c.id} → ${t.en}');
        }
      }
      for (final p in _allSeedPosts) {
        for (final t in p.topics) {
          if (!kTopicNames.containsKey(t.en)) unknown.add('${p.id} → ${t.en}');
        }
      }
      expect(unknown, isEmpty,
          reason: 'these topic ids are not in kTopicNames, so they render '
              'English in Hindi:\n${unknown.join('\n')}');
    });

    test('every auto-tagging key is a vocabulary entry', () {
      // inferTopics() tags real user posts from _topicKeywords. Its KEYS become
      // topic ids, so a key the vocabulary does not know produces a permanently
      // English tag on a mother's own post — and nobody would notice, because
      // auto-tagging is invisible when it half-works.
      final src =
          File('lib/data/community_data.dart').readAsStringSync();
      final block = RegExp(r'_topicKeywords = \{(.*?)\n\};', dotAll: true)
          .firstMatch(src);
      expect(block, isNotNull,
          reason: '_topicKeywords moved or was renamed — this guard is blind '
              'until the pattern is updated');
      final keys = RegExp("^  '([^']+)':", multiLine: true)
          .allMatches(block!.group(1)!)
          .map((m) => m.group(1)!)
          .toList();
      expect(keys, isNotEmpty);
      for (final k in keys) {
        expect(kTopicNames.containsKey(k), isTrue,
            reason: '_topicKeywords key "$k" has no bilingual name');
      }
    });

    test('no entry is English copied into the Hindi column', () {
      // An identical pair reads as finished work to anything counting pairs.
      // That is how can_i_data was once reported done with 302 English strings.
      final fake = kTopicNames.entries
          .where((e) => e.value.en == e.value.hi)
          .map((e) => e.key)
          .where((k) => !_sameByNatureTopics.contains(k))
          .toList();
      expect(fake, isEmpty,
          reason: 'these topics have English in both halves and are not '
              'acronyms: ${fake.join(', ')}');
    });

    test('the key and the English half are the same string', () {
      // The key IS the identity, and `.en` is what every match compares. If
      // they ever drift, a post persisted under the key stops matching a seed
      // tagged from the map, and only in one direction.
      for (final e in kTopicNames.entries) {
        expect(e.value.en, e.key);
      }
    });
  });

  group('identity is invariant, display is not', () {
    final t = kTopicNames['Pregnancy Symptoms']!;

    test('topicTagId never moves with the language', () {
      expect(topicTagId(t), 'PregnancySymptoms');
      // It is built from .en, so there is no language to pass and nothing that
      // could change it. Stated as a test because the next person's instinct
      // will be to "fix" it to use .now.
      expect(topicTagId(t), isNot(contains('गर्भ')));
    });

    test('topicTagLabel does move with the language', () {
      expect(topicTagLabel(t, AppLanguage.english), 'PregnancySymptoms');
      expect(topicTagLabel(t, AppLanguage.hinglish), 'गर्भावस्था के लक्षण');
      // Devanagari keeps its spaces: it has no capitals, so a run-together
      // compound is unreadable rather than merely unconventional.
      expect(topicTagLabel(t, AppLanguage.hinglish), contains(' '));
    });

    test('a stored post relates to a seed post through .en — and would not '
        'through object identity', () {
      // This is the trap in its live form, and it is worth reading twice.
      //
      // LocalizedText has no operator ==, so `List.contains` compares
      // REFERENCES. Between two seed posts that happens to work, because both
      // took the same const instance out of kTopicNames — which is precisely
      // what would have let this ship: every test written against seed data
      // passes. `store.feed()` does not serve seed data alone. It merges the
      // posts SHE wrote, and those come back through fromJson as fresh
      // instances that are equal in value and identical to nothing.
      final seed = _allSeedPosts.firstWhere((p) => p.id == 'p1');
      final stored = CommunityPost.fromJson(<String, dynamic>{
        'id': 'stored1',
        'text': 'her own post',
        'topics': [
          {'en': 'Pregnancy Symptoms', 'hi': 'गर्भावस्था के लक्षण'}
        ],
      });

      // What the app does now: compare the identity half.
      final ids = seed.topics.map((x) => x.en).toSet();
      expect(stored.topics.any((x) => ids.contains(x.en)), isTrue);

      // What the app did before the widening, still compiling, now silent.
      expect(stored.topics.any(seed.topics.contains), isFalse,
          reason: 'if this ever passes, LocalizedText gained an operator == '
              'and the .en matching above could be simplified');
    });
  });

  group('search reaches both halves', () {
    test('an English query and a Hindi query find the same room', () {
      bool findable(String q) => kCommunities.any((c) =>
          localizedMatches(c.name, q.toLowerCase()) ||
          c.topics.any((t) => localizedMatches(t, q.toLowerCase())));
      expect(findable('nutrition'), isTrue);
      expect(findable('खानपान'), isTrue);
    });

    test('localizedMatches is case-insensitive on the English half', () {
      expect(localizedMatches(kTopicNames['Sleep']!, 'sleep'), isTrue);
      expect(localizedMatches(kTopicNames['Sleep']!, 'नींद'), isTrue);
      expect(localizedMatches(kTopicNames['Sleep']!, 'zzz'), isFalse);
    });
  });

  group('persistence survives the widening', () {
    test('a post round-trips both halves of every topic', () {
      final post = CommunityPost(
        id: 'rt1',
        communityId: 'nov2026',
        author: 'Test',
        authorEmoji: '🙂',
        text: 'anything',
        type: PostType.question,
        topics: [kTopicNames['Nutrition']!, kTopicNames['Sleep']!],
      );
      // Through a real encode/decode, not just the maps: a store writes JSON.
      final back = CommunityPost.fromJson(
          jsonDecode(jsonEncode(post.toJson())) as Map<String, dynamic>);
      expect(back.topics.map((t) => t.en), ['Nutrition', 'Sleep']);
      expect(back.topics.map((t) => t.hi), ['खानपान', 'नींद']);
    });

    test('a row written by an OLD build still loads, and gains its Hindi', () {
      // The whole reason .en is the identity: every topic already in prefs and
      // in Supabase is a bare English string, because inferTopics() produced a
      // _topicKeywords key. So the old value IS the new lookup key and the
      // migration is a ?? — no backfill, no version column, nothing to run.
      final old = <String, dynamic>{
        'id': 'legacy1',
        'communityId': 'nov2026',
        'author': 'Anjali',
        'authorEmoji': '🤰',
        'text': 'back pain in week 24',
        'type': 'question',
        'topics': ['Pregnancy Symptoms', 'Sleep'], // bare strings
        'isUser': true,
      };
      final post = CommunityPost.fromJson(old);
      expect(post.topics.map((t) => t.en), ['Pregnancy Symptoms', 'Sleep']);
      expect(post.topics.map((t) => t.hi), ['गर्भावस्था के लक्षण', 'नींद']);
      // ...and it still relates to a seed post tagged the same way.
      final seed = kSeedPosts.firstWhere((p) => p.id == 'p1');
      final ids = post.topics.map((t) => t.en).toSet();
      expect(seed.topics.any((t) => ids.contains(t.en)), isTrue);
    });

    test('a topic the vocabulary has never heard of survives rather than '
        'vanishing', () {
      final post = CommunityPost.fromJson(<String, dynamic>{
        'id': 'legacy2',
        'topics': ['Something We Retired'],
      });
      expect(post.topics.single.en, 'Something We Retired');
      expect(post.topics.single.hi, 'Something We Retired');
    });

    test('a row with no topics at all loads empty, not null', () {
      final post = CommunityPost.fromJson(<String, dynamic>{'id': 'legacy3'});
      expect(post.topics, isEmpty);
    });
  });

  group('auto-tagging still produces valid topics', () {
    test('inferTopics returns vocabulary-backed, bilingual tags', () {
      final tags = inferTopics(
          'I have back pain and cannot sleep, and I keep craving fried food');
      expect(tags, isNotEmpty);
      for (final t in tags) {
        expect(kTopicNames.containsKey(t.en), isTrue,
            reason: '"${t.en}" is not a vocabulary entry');
        expect(t.hi, isNotEmpty);
      }
      expect(tags.map((t) => t.en), contains('Pregnancy Symptoms'));
      expect(tags.length, lessThanOrEqualTo(3));
    });

    test('an auto-tagged post persists as the same ids it was tagged with', () {
      final tags = inferTopics('the latch is painful when nursing');
      final post = CommunityPost(
        id: 'auto1',
        communityId: '',
        author: 'A',
        authorEmoji: '',
        text: 'the latch is painful when nursing',
        type: PostType.question,
        topics: tags,
      );
      final back = CommunityPost.fromJson(
          jsonDecode(jsonEncode(post.toJson())) as Map<String, dynamic>);
      expect(back.topics.map((t) => t.en), tags.map((t) => t.en));
    });
  });

  group('expert specialties', () {
    test('every specialty carries a real Hindi half', () {
      final untranslated = _allExperts
          .where((e) => e.specialty.en == e.specialty.hi)
          .map((e) => e.specialty.en)
          .where((s) => !_sameByNatureSpecialties.contains(s))
          .toSet();
      expect(untranslated, isEmpty,
          reason: 'English in both halves: ${untranslated.join(', ')}');
    });

    test('credentials were left alone', () {
      // IBCLC, OB-GYN, DNB, PsyD are awarded qualifications. Inventing a Hindi
      // rendering of one would be inventing the qualification.
      for (final e in _allExperts) {
        expect(e.cred, isA<String>());
        expect(e.cred.trim(), isNotEmpty);
      }
      expect(kCommunityExperts.first.cred, 'IBCLC');
    });

    test('the verification specialty KEY is untouched and still a String', () {
      // preferredSpecialty is a lowercase routing key ('gynae'), not a label.
      // It must never be handed a translated specialty name.
      for (final sp in kVerifySpecialties) {
        expect(sp, sp.toLowerCase());
      }
      final p = kSeedPosts.firstWhere((p) => p.id == 'p1');
      expect(p.preferredSpecialty, isA<String>());
    });
  });

  group('community pulse', () {
    test('every card is bilingual and every number carries over', () {
      for (final c in kPulse) {
        expect(c.title.en, isNotEmpty);
        expect(c.title.hi, isNotEmpty);
        expect(c.title.en, isNot(c.title.hi));
        expect(c.body.en, isNot(c.body.hi));
        // Digits are mechanical parity: a statistic that drifts in translation
        // is a quiet lie. Same set, same order, in both halves.
        final digits = RegExp(r'\d+');
        expect(digits.allMatches(c.body.hi).map((m) => m.group(0)),
            digits.allMatches(c.body.en).map((m) => m.group(0)),
            reason: 'numbers differ between languages in "${c.body.en}"');
      }
    });

    test('poll options keep an English identity to be voted under', () {
      final poll = kPulse.firstWhere((c) => c.type == PulseType.poll);
      expect(poll.options.map((o) => o.en), ['Yes', 'Sometimes', 'Not yet']);
      for (final o in poll.options) {
        expect(o.hi, isNot(o.en));
      }
    });

    test('the pulse renderer votes on .en, not on the label', () {
      // A vote is persisted and synced. Filing it under the rendered label
      // would record the same answer twice under two names.
      final src =
          File('lib/screens/community_screen.dart').readAsStringSync();
      expect(src.contains('store.vote(kPulseKicksPollId, o.en)'), isTrue,
          reason: 'the pulse poll must store the English option');
    });
  });
}
