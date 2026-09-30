// =============================================================================
//  Explicit names — every heading and caption says what she is tapping
//  (2026-09-28)
// -----------------------------------------------------------------------------
//  The user: "instead of using 'it' use the word, for heading and caption, so
//  the user knows in the right way what they are clicking." A card reading
//  "Can stress stop it?", a tab called "Track", a pill saying "Start the
//  chat" or a Learn link saying "See all" is fine inside the head of whoever
//  wrote it and vague to her, most of all where the words stand alone: a
//  story card in Learn, a Read next rail, a search result, a screen reader.
//
//  What this scans:
//    · on every door: tab labels, section headings, card titles, and the
//      first word of every card caption;
//    · the pills on the Fertile window door's kind cards (`ttcToolVerb`,
//      `ttcChatVerb`); since 2026-09-29 the kind and fact pills of the one
//      card family on every door (`ttcCardKindWord`, `ttcCardMeta`);
//    · every read's title (it is the label on a Read next card) and every
//      next step's title and the first word of its line;
//    · Learn's headings, actions and leads, and the questions it lists.
//
//  The rules, in order of how often they caught something:
//    1. No "it", "them", "these", "those", "here" or "this" standing in for a
//       thing the words never name. A pronoun is fine AFTER the title has
//       named its subject ("Morning temperature: how it works", "Five kinds
//       of bleeding, and how to tell them apart"), so a pronoun after a colon
//       or comma with words before it passes. "This" before a time or a round
//       ("this month", "this treatment cycle") is a date, not a pronoun, and
//       an empty "it" ("is it time", "it's worth", "is it harder to") names
//       nothing because it stands for nothing.
//    2. No bare action: "Open", "Start", "Watch", "See all", "Read more",
//       "Learn more", "Try it", "Get help", "Talk", "Track", "Understand".
//    3. A caption never OPENS on a pronoun ("It changes more slowly than
//       yours"): the line under a title is read first on a card with a photo.
//    4. A title fits its card: a character budget per card width, because
//       the test font has no real glyph widths (see [_budgetFor]).
//
//  ⚠️ THE ALLOW-LIST IS SHORT AND EVERY LINE SAYS WHY. Adding to it is a
//  decision about one string, never a way to quiet the test.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/screens/ttc/doors/ttc_kind_cards.dart';
import 'package:parentveda/screens/ttc/ttc_learn_screen.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/ttc/ttc_focus_data.dart';
import 'package:parentveda/ttc/ttc_reads_data.dart';

/// Strings that keep a word the rules flag, each for a reason.
const Map<String, String> _kAllowed = {
  // The read's own title, a phrase people use; "it" is the difficulty in
  // conceiving, which the card's caption names in its first sentence
  // ("About half of couples having difficulty have a male factor").
  'Whose "side" is it, really':
      'the read title; the caption names the subject',
  // "Is it X or Y?": the two things it could be ARE the subject.
  'Is it implantation bleeding or my period?':
      'the two things named are the subject',
  // The practice library's own line (lib/ttc/ttc_practice_data.dart, not
  // door data): the card's title "Two-minute body relaxation" names what
  // "this" is, one line above it.
  "This isn't breathing work. You move your attention through your body and "
          'let each part relax. Good at the end of the day.':
      'owned by the practice library; the title names it',
};

final RegExp _pronoun = RegExp(
  r"\b(it|it's|its|them|these|those|here|here's|this)\b",
  caseSensitive: false,
);

/// "this" before a time or a round is a date, not a pronoun.
final RegExp _deictic = RegExp(
  r'\bthis (week|month|cycle|cycle.s|round|treatment|year|morning|evening)\b',
  caseSensitive: false,
);

/// An empty "it" that stands for nothing.
final RegExp _dummyIt = RegExp(
  r"\b(is it|it's|it is) (time|worth|(\w+ ){1,2}to)\b",
  caseSensitive: false,
);

const Set<String> _bareActions = {
  'open', 'start', 'watch', 'see all', 'read more', 'learn more', 'try it',
  'get help', 'talk', 'track', 'understand', 'support', 'today', 'more',
  'what to do', 'how it works', 'open the tool', 'start the chat',
};

/// Why [s] is vague as a title, heading, label or action, or null.
String? vagueTitle(String s) {
  if (_kAllowed.containsKey(s)) return null;
  final bare = s.toLowerCase().replaceAll(RegExp(r'[.?!:]+$'), '').trim();
  if (_bareActions.contains(bare)) return 'a bare action: "$s"';
  final cleaned = s.replaceAll(_deictic, '').replaceAll(_dummyIt, '');
  final m = _pronoun.firstMatch(cleaned);
  if (m == null) return null;
  // Named first, then referred to: "Morning temperature: how it works".
  final before = cleaned.substring(0, m.start);
  final sep = before.lastIndexOf(RegExp(r'[:,]'));
  if (sep > 0 && RegExp(r'[A-Za-z]{3,}').hasMatch(before.substring(0, sep))) {
    return null;
  }
  return '"${m[0]}" with nothing named before it: "$s"';
}

/// Why [s] is vague as a caption, or null: a caption may not OPEN on a
/// pronoun, and may not be a bare "Read more".
String? vagueCaption(String s) {
  if (_kAllowed.containsKey(s)) return null;
  final bare = s.toLowerCase().replaceAll(RegExp(r'[.?!]+$'), '').trim();
  if (_bareActions.contains(bare)) return 'a bare action: "$s"';
  if (RegExp(r"^(it|it's|its|this|that|these|those|they|they're|them|here|"
          r"here's)\b", caseSensitive: false)
      .hasMatch(s.trim())) {
    return 'opens on a pronoun: "$s"';
  }
  return null;
}

/// A title's character budget on its card, as a proxy for real text
/// metrics (the test font draws every glyph a full em wide, so a measured
/// width means nothing). The numbers are the card's text width over an
/// average Newsreader glyph, times the card's line limit.
int _budgetFor(String bracketId, TtcTile t) {
  // 2026-09-29: every door draws the one card family (`TtcKindCard`): a 240pt
  // card, a 194pt title box, about 27 Newsreader glyphs a line at 15 over two
  // lines. Kept for revert below, the budgets per 2026-09-28 kind shape on
  // the Fertile window door and the 150pt photo card on the other eight.
  if (ttcCardKindOf(t) != null) return 54;
  // Kept for revert (2026-09-28), when `ttcDoorDrawsKinds(bracketId)`:
  // if (false) {
  //   return switch (ttcCardKindOf(t)) {
  //     TtcCardKind.video => 60, // 224pt, 2 lines
  //     TtcCardKind.story => 60, // 116pt, 4 lines
  //     TtcCardKind.read || TtcCardKind.product => 60, // 3 lines
  //     TtcCardKind.myth => 54,
  //     TtcCardKind.tool || TtcCardKind.practice => 46,
  //     TtcCardKind.chat => 34, // the ink bubble, 2 lines
  //     TtcCardKind.consult => 36, // 2 lines
  //     null => 54,
  //   };
  // }
  // The 150pt door card: 122pt of text, about 18 Newsreader glyphs a line
  // at 15, three lines over a photo.
  return 54;
}

void main() {
  group('the nine doors', () {
    test('tab labels name what the tab holds', () {
      final bad = [
        for (final page in kTtcFocusPages)
          for (final g in page.groups ?? const <TtcFocusGroup>[])
            if (vagueTitle(g.label) case final why?) '${page.bracketId}: $why',
      ];
      expect(bad, isEmpty, reason: bad.join('\n'));
    });

    test('tab labels fit the rail card (two lines of about 11 letters)', () {
      // The rail card leaves 92pt for its label: about 11 Manrope letters at
      // 15, two lines, wrapped at spaces. "Going through a round" wraps to
      // "Going" and "through a round", and the second line ends in an
      // ellipsis, which is why that tab is "During a round".
      bool fits(String label) {
        var lines = 1, line = 0;
        for (final w in label.split(' ')) {
          if (w.length > 11) return false;
          final next = line == 0 ? w.length : line + 1 + w.length;
          if (next <= 11) {
            line = next;
          } else {
            lines++;
            line = w.length;
          }
        }
        return lines <= 2;
      }

      final long = [
        for (final page in kTtcFocusPages)
          for (final g in page.groups ?? const <TtcFocusGroup>[])
            if (!fits(g.label)) '${page.bracketId}: "${g.label}"',
      ];
      expect(long, isEmpty, reason: long.join('\n'));
      expect(fits('Going through a round'), isFalse);
    });

    test('section headings name their subject', () {
      final bad = [
        for (final page in kTtcFocusPages)
          for (final s in page.sections)
            if (vagueTitle(s.heading) case final why?)
              '${page.bracketId}: $why',
      ];
      expect(bad, isEmpty, reason: bad.join('\n'));
    });

    test('card titles name what they open', () {
      final bad = [
        for (final page in kTtcFocusPages)
          for (final t in page.allTiles)
            if (vagueTitle(t.title) case final why?)
              '${page.bracketId}: $why',
      ];
      expect(bad, isEmpty, reason: bad.join('\n'));
    });

    test('card captions never open on a pronoun', () {
      final bad = [
        for (final page in kTtcFocusPages)
          for (final t in page.allTiles)
            if (vagueCaption(t.blurb) case final why?)
              '${page.bracketId} › ${t.title}: $why',
      ];
      expect(bad, isEmpty, reason: bad.join('\n'));
    });

    test('card titles fit their cards at 360pt', () {
      final long = [
        for (final page in kTtcFocusPages)
          for (final s in page.sections)
            for (final t in s.tiles)
              if (t.title.length > _budgetFor(page.bracketId, t))
                '${page.bracketId}: "${t.title}" (${t.title.length} > '
                    '${_budgetFor(page.bracketId, t)})',
      ];
      expect(long, isEmpty, reason: long.join('\n'));
    });

    test('every pill on a kind card names its thing', () {
      final bad = <String>[];
      // 2026-09-29: the pills on every door are the kind in words and one
      // fact, and neither may be vague or a bare action.
      for (final page in kTtcFocusPages) {
        for (final t in page.allTiles) {
          final kind = ttcCardKindOf(t);
          if (kind == null) continue;
          for (final pill in [ttcCardKindWord(kind), ?ttcCardMeta(t)]) {
            if (vagueTitle(pill) case final why?) bad.add('${t.title}: $why');
          }
        }
      }
      // The V1 verbs, still held (`TtcKindCardV1`, kept for revert). Kept
      // for revert: `if (!ttcDoorDrawsKinds(page.bracketId)) continue;`.
      for (final page in kTtcFocusPages) {
        for (final t in page.allTiles) {
          if (t case TtcToolTile(:final surfaceId)) {
            final verb = surfaceId.startsWith('ttc_chat/')
                ? ttcChatVerb(surfaceId)
                : ttcToolVerb(surfaceId, t.title);
            if (vagueTitle(verb) case final why?) bad.add('${t.title}: $why');
          }
        }
      }
      expect(bad, isEmpty, reason: bad.join('\n'));
      expect(ttcChatVerb('ttc_chat/should_test'),
          'Start the should-I-test chat');
      // A surface the verbs do not know says the card's own name.
      expect(ttcToolVerb('ttc_unknown', 'Your habit trackers'),
          'Open Your habit trackers');
    });
  });

  group('the reads', () {
    test('a read title stands alone on a Read next card', () {
      final bad = [
        for (final r in kTtcReads)
          if (vagueTitle(r.title.en) case final why?) '${r.id}: $why',
      ];
      expect(bad, isEmpty, reason: bad.join('\n'));
    });

    test('next steps name what they open', () {
      final bad = <String>[];
      for (final r in kTtcReads) {
        for (final n in r.nextSteps) {
          if (vagueTitle(n.title.en) case final why?) bad.add('${r.id}: $why');
          if (vagueCaption(n.value.en) case final why?) {
            bad.add('${r.id}: $why');
          }
        }
      }
      expect(bad, isEmpty, reason: bad.join('\n'));
    });
  });

  group('Learn', () {
    test('headings, actions and leads name their thing', () {
      final t = TtcS.current();
      final heads = <String>[
        t.learnTopics, t.learnYourReading, t.learnContinue, t.learnSaved,
        t.learnSeeSaved, t.learnStartEyebrow, t.learnStartTitle,
        t.learnFilmsEyebrow, t.learnFilmsTitle, t.learnFilmCovers,
        t.learnFilmReadNow, t.learnOpenDoor, t.learnShowAll(6),
        t.learnMythsEyebrow, t.learnMythsTitle, t.learnCoursesEyebrow,
        t.learnCoursesTitle, t.learnCoursesAll, t.learnFaqEyebrow,
        t.learnFaqTitle,
      ];
      final leads = <String>[
        t.learnStartLead, t.learnFilmsLead, t.learnSavedEmpty, t.learnNoMatch,
      ];
      final bad = [
        for (final h in heads) ?vagueTitle(h),
        for (final l in leads) ?vagueCaption(l),
        // A lead's demonstrative must lead to a noun ("these films"), never
        // end a clause ("We're still making these.").
        for (final l in leads)
          if (RegExp(r'\b(it|this|these|those)\b[.,;:!?]',
                  caseSensitive: false)
              .hasMatch(l))
            'a lead ends a clause on a pronoun: "$l"',
      ];
      expect(bad, isEmpty, reason: bad.join('\n'));
      expect(t.learnShowAll(6), 'Show all 6 reads');
      expect(t.learnCoursesAll, 'See all courses');
    });

    test('the common questions stand alone', () {
      final bad = [
        for (final (f, r) in ttcLearnFaqs())
          if (RegExp(r"\b(it|it's|this)\b", caseSensitive: false)
                  .hasMatch(f.question.en.replaceAll(_dummyIt, '')) &&
              vagueTitle(f.question.en) != null)
            '${r.id}: "${f.question.en}"',
      ];
      expect(bad, isEmpty, reason: bad.join('\n'));
    });

    test('the myth and story cards stand alone', () {
      final bad = [
        for (final (tile, _) in ttcLearnStories()) ?vagueTitle(tile.title),
      ];
      expect(bad, isEmpty, reason: bad.join('\n'));
    });
  });

  group('the rules themselves', () {
    test('catch the strings that were fixed', () {
      for (final s in [
        'Can stress stop it?',
        'Keep track of it',
        'Talk it through',
        'Bringing him into this',
        'Worth it or hype?',
        'See all',
        'Open',
        'Track',
      ]) {
        expect(vagueTitle(s), isNotNull, reason: s);
      }
      for (final s in [
        "It changes more slowly than yours. Here's what changes.",
        'This matters a lot if you\'re not ready.',
      ]) {
        expect(vagueCaption(s), isNotNull, reason: s);
      }
    });

    test('pass what names its subject first', () {
      for (final s in [
        'Morning temperature: how it works',
        'Five kinds of bleeding, and how to tell them apart',
        "When it's time to see a doctor",
        'Your best days this month',
        'Track this treatment cycle',
        'Why is it harder to get pregnant the second time?',
      ]) {
        expect(vagueTitle(s), isNull, reason: s);
      }
    });

    test('the allow-list names strings that are still in the app', () {
      final all = <String>{
        for (final page in kTtcFocusPages)
          for (final t in page.allTiles) ...[t.title, t.blurb],
        for (final r in kTtcReads) r.title.en,
      };
      for (final s in _kAllowed.keys) {
        expect(all, contains(s), reason: '"$s" is gone; take it off the list');
      }
    });
  });
}
