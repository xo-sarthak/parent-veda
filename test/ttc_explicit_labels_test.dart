// =============================================================================
//  Explicit labels on every Trying to Conceive screen outside the doors
//  (2026-09-28)
// -----------------------------------------------------------------------------
//  The user: "instead of using 'it' use the word, for heading and caption, so
//  the user knows in the right way what they are clicking." A pill saying
//  "Start", a heading saying "Read about it", a link saying "See all" is clear
//  to whoever wrote it and vague to her, most of all where the words stand
//  alone: a button, a chip, a tile's caption, a screen reader.
//
//  The doors, Learn and the reads hold the same rule in
//  test/ttc_doors_explicit_names_test.dart, against their data. This file
//  holds it for everything else in the stage (her home, his side, the Tools
//  hub and every tool, the Cycle companion, calendar, window, report and
//  messages, the chats, practice, ritual, course, treatment and positive-test
//  screens, and the More pages), and it reads the SOURCE: most of these labels
//  are string literals in widget code, not data.
//
//  WHAT COUNTS AS A LABEL. A string literal of eight words or fewer, outside a
//  comment, after adjacent literals are joined ('a ' 'b' is one string). A
//  heading, caption, chip or button is short; body text is longer, and the
//  rule is not about body text, where "it" after the thing it names is
//  ordinary English.
//
//  THE RULES:
//    1. No "it", "them", "these", "those", "here" or "this" standing in for a
//       thing the words never name. Passes: a pronoun after a colon or comma
//       with words before it (the subject came first), "this"/"these" before
//       a noun (a determiner, "this cycle"), and an empty "it" ("is it time",
//       "it's worth").
//    2. No bare action: "Open", "Start", "See all", "Read more", "Learn more",
//       "Continue", "More", "Add", "Edit", "Next", "Change", "View", "Tap
//       here", "Show all".
//
//  ⚠️ THE ALLOW-LIST IS SHORT AND EVERY LINE SAYS WHY. Adding to it is a
//  decision about one string, never a way to quiet the test.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The files this rule covers: the stage's screens outside the doors, Learn
/// and the reads, plus the More pages behind the TTC bar.
List<File> _files() {
  bool skip(String p) => const [
        // The doors and Learn: test/ttc_doors_explicit_names_test.dart.
        'ttc_learn_screen.dart',
        'ttc_focus_screen.dart',
        '/doors/',
        // Retired "…Classic" store screens kept for revert, unreached: TTC
        // shopping goes through lib/screens/products/ (see the report,
        // 2026-09-28).
        'ttc_shop_v3.dart',
        // The journal is out of the stage (2026-09-28), and the questions for
        // the doctor are their own feature under another helper.
        'ttc_journal_screen.dart',
        'ttc_doctor_question',
        // Parenting only, never on a TTC More page.
        'pv_child_screen.dart',
      ].any((s) => p.replaceAll(r'\', '/').contains(s));

  final out = <File>[];
  for (final dir in [
    'lib/screens/ttc',
    'lib/screens/ttc/chats',
    'lib/screens/profile',
  ]) {
    for (final e in Directory(dir).listSync()) {
      if (e is File && e.path.endsWith('.dart') && !skip(e.path)) out.add(e);
    }
  }
  return out;
}

/// Every string literal in [src] outside comments, adjacent literals joined,
/// interpolations replaced by "X". Returns (line, text).
List<(int, String)> _literals(String src) {
  final out = <(int, String)>[];
  var i = 0;
  var line = 1;
  final n = src.length;
  String? pending;
  var pendingLine = 0;
  var sinceLiteral = ''; // what sits between the last literal and here

  void flush() {
    if (pending != null) out.add((pendingLine, pending!));
    pending = null;
  }

  // Reads one string starting at i (at the quote, or at an r prefix).
  String readString() {
    var raw = false;
    if (src[i] == 'r') {
      raw = true;
      i++;
    }
    final q = src[i];
    final triple = i + 2 < n && src[i + 1] == q && src[i + 2] == q;
    final close = triple ? '$q$q$q' : q;
    i += triple ? 3 : 1;
    final buf = StringBuffer();
    while (i < n) {
      if (src.startsWith(close, i)) {
        i += close.length;
        break;
      }
      final c = src[i];
      if (c == '\n') line++;
      if (!raw && c == r'\') {
        final e = i + 1 < n ? src[i + 1] : '';
        buf.write(e == 'n' || e == 't' ? ' ' : e);
        i += 2;
        continue;
      }
      if (!raw && c == r'$') {
        if (i + 1 < n && src[i + 1] == '{') {
          // Skip the interpolation, strings inside it included.
          var depth = 1;
          i += 2;
          while (i < n && depth > 0) {
            final d = src[i];
            if (d == '{') depth++;
            if (d == '}') depth--;
            if (d == "'" || d == '"') {
              readString();
              continue;
            }
            if (d == '\n') line++;
            i++;
          }
          buf.write('X');
          continue;
        }
        i++;
        while (i < n && RegExp(r'[A-Za-z0-9_]').hasMatch(src[i])) {
          i++;
        }
        buf.write('X');
        continue;
      }
      buf.write(c);
      i++;
    }
    return buf.toString();
  }

  while (i < n) {
    final c = src[i];
    if (c == '\n') {
      line++;
      sinceLiteral += c;
      i++;
      continue;
    }
    if (src.startsWith('//', i)) {
      while (i < n && src[i] != '\n') {
        i++;
      }
      continue;
    }
    if (src.startsWith('/*', i)) {
      final end = src.indexOf('*/', i + 2);
      final stop = end < 0 ? n : end + 2;
      line += '\n'.allMatches(src.substring(i, stop)).length;
      i = stop;
      continue;
    }
    final isRaw = c == 'r' &&
        i + 1 < n &&
        (src[i + 1] == "'" || src[i + 1] == '"') &&
        (i == 0 || !RegExp(r'[A-Za-z0-9_]').hasMatch(src[i - 1]));
    if (c == "'" || c == '"' || isRaw) {
      final at = line;
      final s = readString();
      if (pending != null && sinceLiteral.trim().isEmpty) {
        pending = pending! + s;
      } else {
        flush();
        pending = s;
        pendingLine = at;
      }
      sinceLiteral = '';
      continue;
    }
    if (c.trim().isNotEmpty) {
      flush();
      sinceLiteral = c;
    } else {
      sinceLiteral += c;
    }
    i++;
  }
  flush();
  return out;
}

/// True for a literal that is a key, a route, a path or a pattern, never
/// words she reads.
bool _notWords(String s) =>
    !RegExp(r'[A-Za-z]').hasMatch(s) ||
    RegExp(r'^[a-z0-9_./:\-]+$').hasMatch(s) ||
    s.contains('http') ||
    s.contains('assets/') ||
    RegExp(r'[\\^\[\]{}]').hasMatch(s);

int _words(String s) => s.trim().split(RegExp(r'\s+')).length;

/// A full sentence (it ends on a full stop or an exclamation): body text,
/// where "it" after the thing it names is ordinary English. Headings,
/// captions, chips and buttons carry no full stop; a question is a heading.
bool _sentence(String s) => RegExp(r'[.!]["”’)]?$').hasMatch(s.trim());

/// The Hindi side of every `t('English', 'Hindi')` / `_p(…)` / `_t(…)` pair
/// in [src]. Shipped Hindi stays as it is (CLAUDE.md), and the rule is about
/// English words; some shipped Hindi is Latin script ("Anisch it").
Set<String> _hindiSides(String src) {
  const lit = r"""('(?:[^'\\]|\\.)*'|"(?:[^"\\]|\\.)*")""";
  final pair = RegExp(r'\b(?:_?t|_p)\(\s*' + lit + r'\s*,\s*' + lit);
  return {
    for (final m in pair.allMatches(src))
      m.group(2)!.substring(1, m.group(2)!.length - 1).trim(),
  };
}

final RegExp _pronoun = RegExp(
    r"\b(it|it's|its|them|these|those|here|here's|this)\b",
    caseSensitive: false);

/// "this" or "these" before a noun is a determiner: "this cycle", "these
/// dates". Only "this" standing alone (or before a verb) is the pronoun.
final RegExp _determiner = RegExp(
    r"\b(this|these|those) (?!is\b|was\b|one\b|will\b|can\b|means?\b|"
    r"[.?!,]|$)[a-z]",
    caseSensitive: false);

/// An empty "it" that stands for nothing.
final RegExp _dummyIt = RegExp(
    r"\b(is it|it's|it is|it will be|it can be|it takes|it may take) "
    r"(time|worth|okay|ok|fine|safe|common|normal|usual|best|early|late|"
    r"never|not|a|an|the|harder|easier|too|about|(\w+ ){0,2}to)\b|"
    // "Got it" is an acknowledgement; "as it was" an idiom; "which test was
    // it?" names the test before the "it".
    r"\bgot it\b|\bas it (was|is)\b|\b(which|what|whose) \w+ (is|was) (it|this)\b",
    caseSensitive: false);

const Set<String> _bareActions = {
  'open', 'start', 'see all', 'see more', 'read more', 'learn more',
  'continue', 'more', 'add', 'edit', 'next', 'change', 'view', 'view all',
  'tap here', 'show all', 'show more', 'go', 'try it', 'details',
};

/// Why [s] is vague, or null.
String? _vague(String s) {
  final t = s.trim();
  final bare = t
      .toLowerCase()
      .replaceAll(RegExp(r'[\s.…→›>:]+$'), '')
      .replaceAll(RegExp(r'\s+'), ' ');
  if (_bareActions.contains(bare)) return 'a bare action';
  // Rule 1, on what is left once determiners and empty "it"s are removed.
  var rest = t.replaceAll(_determiner, ' ').replaceAll(_dummyIt, ' ');
  final m = _pronoun.firstMatch(rest);
  if (m == null) return null;
  // A pronoun after a colon, dash or comma with words before it: the subject
  // came first ("Your period: what it means").
  final before = rest.substring(0, m.start);
  if (RegExp(r'[A-Za-z]{3,}.*[:,—–-]\s*').hasMatch(before)) return null;
  return 'names nothing: "${m.group(0)}"';
}

/// Strings that keep a word the rules flag, each for a reason. Matched on the
/// joined literal (interpolations read "X").
const Map<String, String> _kAllowed = {
  // ---- the bar and its tab ---------------------------------------------
  'More': 'the bottom-bar tab and its screen title, named More by the user '
      '(2026-09-28); it is the one place in the app for everything else',
  'Aur': 'the Hindi of the More tab, shipped Hindi (the rule is on English)',
  // ---- one-question flows ------------------------------------------------
  'Continue': 'the intro flow asks one question to a screen, and the next '
      'screen is the only place Continue can go (`introContinue`)',
  // ---- verbs inside a row or card that names the thing -------------------
  'Mark as done': 'inside each Sanskar card, under the part\'s own title',
  'Read': 'the course session\'s three-way part pill (Read · The practice · '
      'Your plan); the session title names the reading above it',
  'Add a date': 'on a treatment step row that names the step',
  // ---- map markers and headlines where "here" is the point --------------
  'You are here': 'the map marker on the chapter reader and the report ring',
  'YOU ARE HERE': 'the same marker, uppercase',
  'Your fertile days are here': 'a hero headline: the days have arrived',
  "Here's what happens next": 'a page title over the list it introduces',
  "Here's how your round usually goes":
      'a page title over the list it introduces',
  'Nothing here yet': 'an empty state on a screen whose title names the list',
  // ---- sections the Ask Veda service returns, named there ---------------
  'What this means for you': 'one of the seven sections the Ask Veda service '
      'returns (parentveda-askveda); the name is a contract across repos',
  // ---- test pages ---------------------------------------------------------
  "Why it's done": 'a heading under the test\'s own name',
  'What it measures': 'a heading under the test\'s own name',
  // ---- content titles that are identity keys -----------------------------
  'Half of this is his': 'a chapter card title that is also its identity key '
      'in `kTtcUsCardAudience`; renaming it strands the audience rule',
  // ---- decisions left open for the user ----------------------------------
  'Get this': 'Prepare mixes one-off consults and multi-session programmes; '
      'no single noun fits both (decision for the user, report 2026-09-28)',
  'You have this': 'the same screen, the owned state',
  "Can't stop thinking about it": 'a mood in her own voice; a code comment '
      'defends the "it" and ttc_logging_gap_test pins it',
  // ---- fragments and places outside this rule -----------------------------
  'open': 'the verb that finishes the hero\'s lead-in ("Your fertile days" + '
      '" open"), read as one sentence, never a button (`headerOpenVerb`)',
  'Add it to my questions': 'the questions for the doctor are their own '
      'feature under another helper (2026-09-28); left for them',
  'Not answered here yet': 'the empty search on Can I…?, whose title names '
      'the place',
  'Say it here': 'the community composer, held back for launch and unreached',
  "We're building this": 'an eyebrow over one line that names the feature',
  'Planning a baby? Start here': 'the Trying to conceive card on the '
      'pregnancy home (home_screen_b.dart), outside this stage; its title '
      'names the stage above the line',
};

/// Strings allowed in ONE file only, keyed 'file name|text', so a bare
/// "Add" allowed where it is dead or spoken in full cannot pass anywhere else.
const Map<String, String> _kAllowedAt = {
  'ttc_care_circle_screen.dart|Everything you see here, and why':
      'in TtcCareCircleScreenClassic, kept for revert and unreached',
  'ttc_dose_parts.dart|Add': 'the default of a parameter both callers set '
      '("Add another supplement", "Add another medicine"); never drawn',
  'ttc_supplements_screen.dart|Add': 'a fixed column inside ExcludeSemantics '
      "beside the supplement's name; the row is one button spoken as "
      '"Add <name>"',
  'ttc_symptom_log_screen.dart|Add': 'kTtcMeasureAdd, a dead constant only '
      'named in comments',
  'ttc_symptom_log_screen.dart|Change': 'kTtcMeasureChange, a dead constant '
      'only named in comments',
  'ttc_symptom_log_screen.dart|Tap the number to type it':
      'the sentence names the number before the "it"',
  'ttc_tool_confirm.dart|Keep it': 'the cancel button of a remove dialog '
      'whose title names the item being removed',
  'ttc_ivf_readiness_screen.dart|None of these':
      'an answer option directly under the list it answers',
  'ttc_precheck_screen.dart|I talked to my doctor about this':
      'an answer option inside the checklist item it names',
  'ttc_precheck_screen.dart|Learn more': 'the fallback only when a read has '
      'no title; the live chip says "Read: <read title>"',
  'ttc_pcos_check_result.dart|Could thyroid or prolactin explain any of this?':
      'a question to take to the doctor (their feature), naming both tests',
  'ttc_vaccines_screen.dart|Had it on X': 'the Hindi side of a pair (shipped '
      'Hindi is kept); the English reads "Had the jab on X"',
};

void main() {
  test('every label names what she is tapping', () {
    final bad = <String>[];
    for (final f in _files()) {
      final src = f.readAsStringSync().replaceAll('\r\n', '\n');
      final hindi = _hindiSides(src);
      for (final (line, s) in _literals(src)) {
        if (_notWords(s) || _words(s) > 8 || _sentence(s)) continue;
        if (hindi.contains(s.trim())) continue;
        if (_kAllowed.containsKey(s.trim())) continue;
        final name = f.path.replaceAll(r'\', '/').split('/').last;
        if (_kAllowedAt.containsKey('$name|${s.trim()}')) continue;
        final why = _vague(s);
        if (why != null) {
          bad.add('${f.path.replaceAll(r'\', '/')}:$line  "$s"  ($why)');
        }
      }
    }
    expect(bad, isEmpty,
        reason: '${bad.length} labels do not name their thing:\n'
            '${bad.join('\n')}');
  });

  group('the rules themselves', () {
    test('catch the strings that were fixed', () {
      for (final s in [
        'Read about it',
        'Start',
        'See all',
        'Open',
        'Tap to see or change it',
        'Keep it open',
        "I'll add it later",
        'Taken it? Tick here',
        'Whenever it happens, this is where you tell us.',
        'Your half of this',
        'This one is about you',
      ]) {
        expect(_vague(s), isNotNull, reason: s);
      }
    });

    test('pass what names its subject', () {
      for (final s in [
        'Start my round',
        'See all consults',
        'Read about this step',
        'Remove this scan',
        'This cycle',
        'Your period: what it means',
        "When it's time to see a doctor",
        'Keep the round open',
        'Is it worth testing today?',
      ]) {
        expect(_vague(s), isNull, reason: s);
      }
    });

    test('the lexer joins adjacent literals and skips comments', () {
      final lits = _literals("""
        // 'Open' in a comment
        Text('Read ' 'about it'),
        x = "Keep \${a.b ? 'it' : 'x'} open";
      """);
      final texts = [for (final (_, s) in lits) s];
      expect(texts, contains('Read about it'));
      expect(texts, isNot(contains('Open')));
      expect(texts, contains('Keep X open'));
    });

    test('the allow-list names strings still in the app', () {
      final all = <String>{
        for (final f in _files())
          for (final (_, s) in _literals(
              f.readAsStringSync().replaceAll('\r\n', '\n')))
            s.trim(),
      };
      for (final s in _kAllowed.keys) {
        expect(all, contains(s), reason: '"$s" is gone; take it off the list');
      }
      for (final key in _kAllowedAt.keys) {
        final [name, text] = key.split('|');
        final f = _files().where((f) => f.path.endsWith(name)).single;
        final here = {
          for (final (_, s) in _literals(
              f.readAsStringSync().replaceAll('\r\n', '\n')))
            s.trim(),
        };
        expect(here, contains(text),
            reason: '"$text" is gone from $name; take it off the list');
      }
    });
  });
}
