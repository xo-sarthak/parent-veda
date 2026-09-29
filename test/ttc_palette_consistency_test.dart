// =============================================================================
//  TTC: one black for controls, no off-palette colour, readable headers
//  (2026-09-29)
// -----------------------------------------------------------------------------
//  The user on build 19, at "Start my round": "this color is not in the
//  palette… it has been used at a lot of places inside the newly made tools…
//  we cannot be using random color buttons whenever we want." Then: "those
//  toggle switches are all black, that is what I want… keep it black
//  everywhere", "you have put a purple on a blue background, it does not look
//  good", and "grey on white won't make the visibility good".
//
//  THE RULE (DESIGN-SYSTEM §4.0): ink for anything she presses or chooses,
//  and it is ONE ink, the switches' (`AppTheme.neutral900`, #2F2C30, which is
//  `ttcInk` and now `ttcTitleInk`). Violet (`action`) is spent on section
//  eyebrows, progress hairlines and the nav's lit tab, never on a button, a
//  chosen chip, a ticked box or a field ring. Text on a tinted field is ink,
//  never accent and never a pale grey. A note is a grey line on the page,
//  never a tinted slab.
//
//  What this holds, in three layers:
//   1. the tokens: ttcTitleInk IS the switch black, and the old plum is gone;
//   2. the source: no off-palette hex, no violet or V2 `ink1` used as a FILL,
//      no tinted slab behind text in lib/screens/ttc/** and lib/ttc/**
//      (kept-for-revert blocks, marked `// ignore: unused_element`, are
//      history and are skipped);
//   3. the pixels: every word and icon in a tool's header is measured against
//      the hero field actually painted under it (WCAG: text 4.5:1, large
//      text and icons 3:1), and every dark pill on those screens is the
//      switch black.
// =============================================================================

import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderParagraph;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/ttc_appointments_screen.dart';
import 'package:parentveda/screens/ttc/ttc_bmi_screen.dart';
import 'package:parentveda/screens/ttc/ttc_common.dart';
import 'package:parentveda/screens/ttc/ttc_cycle_companion.dart';
import 'package:parentveda/screens/ttc/ttc_cycle_palette.dart'
    show TtcCycleColours;
import 'package:parentveda/ttc/ttc_chapter.dart' show TtcChapter;
import 'package:parentveda/screens/ttc/ttc_cycle_report_screen.dart';
import 'package:parentveda/screens/ttc/ttc_edit_categories_screen.dart';
import 'package:parentveda/screens/ttc/ttc_get_help_screen.dart';
import 'package:parentveda/screens/ttc/ttc_medication_screen.dart';
import 'package:parentveda/screens/ttc/ttc_supplements_screen.dart';
import 'package:parentveda/screens/ttc/ttc_symptom_log_screen.dart';
import 'package:parentveda/screens/ttc/ttc_tool_chrome.dart';
import 'package:parentveda/screens/ttc/ttc_vaccines_screen.dart';
import 'package:parentveda/screens/v2/v2_palette.dart';
import 'package:parentveda/screens/v2/v3_hero_field.dart';
import 'package:parentveda/theme/app_theme.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_log_store.dart';
import 'package:parentveda/ttc/ttc_store.dart';
import 'package:parentveda/ttc/ttc_treatment_store.dart';

// ---- WCAG arithmetic --------------------------------------------------------

double _lin(double c) =>
    c <= 0.03928 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();

double _lum(Color c) => 0.2126 * _lin(c.r) + 0.7152 * _lin(c.g) + 0.0722 * _lin(c.b);

double contrast(Color a, Color b) {
  final la = _lum(a), lb = _lum(b);
  final hi = math.max(la, lb), lo = math.min(la, lb);
  return (hi + 0.05) / (lo + 0.05);
}

/// [fg] laid over [bg] at fg's own alpha.
Color over(Color fg, Color bg) {
  final a = fg.a;
  return Color.from(
    alpha: 1,
    red: fg.r * a + bg.r * (1 - a),
    green: fg.g * a + bg.g * (1 - a),
    blue: fg.b * a + bg.b * (1 - a),
  );
}

// ---- source scanning --------------------------------------------------------

/// Every live line of TTC source: comments dropped, and the bodies of
/// declarations kept for revert (`// ignore: unused_element`) skipped.
List<({String file, int line, String code})> ttcLiveLines() {
  final out = <({String file, int line, String code})>[];
  for (final dir in ['lib/screens/ttc', 'lib/ttc']) {
    for (final e in Directory(dir).listSync(recursive: true)) {
      if (e is! File || !e.path.endsWith('.dart')) continue;
      final path = e.path.replaceAll('\\', '/');
      final lines = e.readAsLinesSync();
      var skipDepth = -1; // >= 0 while inside a dead declaration
      var depth = 0;
      var armed = false;
      // A `/* ... */` block is kept-for-revert history too (2026-09-29: the
      // old cycle screen in ttc_cycle_screens.dart is one, and its violet
      // hero was being counted as live).
      var inBlock = false;
      for (var i = 0; i < lines.length; i++) {
        final raw = lines[i];
        final lead = raw.trimLeft();
        if (inBlock) {
          if (raw.contains('*/')) inBlock = false;
          continue;
        }
        if (lead.startsWith('/*')) {
          if (!raw.contains('*/')) inBlock = true;
          continue;
        }
        if (RegExp(r'ignore: unused_element(?!_)').hasMatch(raw)) {
          armed = true;
          continue;
        }
        final code = raw.trimLeft().startsWith('//')
            ? ''
            : raw.split(RegExp(r'(?<!:)//')).first;
        final opens = RegExp(r'[({]').allMatches(code).length;
        final closes = RegExp(r'[)}]').allMatches(code).length;
        if (armed && code.trim().isNotEmpty) {
          armed = false;
          skipDepth = depth;
          depth += opens - closes;
          if (depth <= skipDepth &&
              (code.trimRight().endsWith(';') || code.trimRight().endsWith('}'))) {
            skipDepth = -1;
          }
          continue;
        }
        depth += opens - closes;
        if (skipDepth >= 0) {
          if (depth <= skipDepth &&
              (code.trimRight().endsWith(';') || code.trimRight().endsWith('}'))) {
            skipDepth = -1;
          }
          continue;
        }
        if (code.trim().isEmpty) continue;
        out.add((file: path, line: i + 1, code: code));
      }
    }
  }
  return out;
}

/// True when [i] (0-based in [all] for one file) sits inside a decoration or
/// a Material, i.e. the colour on it is a FILL, not a text or icon colour.
bool _isFill(List<String> file, int i) {
  final line = file[i];
  if (line.contains('backgroundColor:')) return true;
  // The colour of an icon or a word written on this line is not a fill.
  if (RegExp(r'Icon\(|Text\(|TextStyle\(|style:').hasMatch(line)) return false;
  for (var j = i; j >= math.max(0, i - 4); j--) {
    final s = file[j].split('//').first;
    if (j != i &&
        RegExp(r'TextStyle|pvManrope|pvFraunces|pvJakarta|ttcBody\(|ttcJakarta\(|ttcFraunces\(|Icon\(|Text\(|BorderSide|Border\.all|style:')
            .hasMatch(s)) {
      return false;
    }
    if (RegExp(r'BoxDecoration|ShapeDecoration|Material\(|Ink\(').hasMatch(s)) {
      return true;
    }
  }
  return false;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ===========================================================================
  group('1. the tokens', () {
    test('ttcTitleInk is the switch black, not the plum', () {
      // The switch's on-track is the theme's `scheme.onSurface`, and the light
      // scheme's onSurface is `neutral900`. Read from the source rather than
      // by building AppTheme.light, which fetches Google Fonts in a test.
      final theme = File('lib/theme/app_theme.dart').readAsStringSync();
      final sw = theme.substring(theme.indexOf('switchTheme: SwitchThemeData('));
      final track = sw.substring(sw.indexOf('trackColor:'), sw.indexOf('trackOutlineColor'));
      expect(track, contains('? scheme.onSurface'),
          reason: "a switch's on-state is the scheme's onSurface");
      expect(theme, contains('onSurface: neutral900'));
      expect(ttcTitleInk, AppTheme.neutral900,
          reason: 'buttons, pills, chosen chips and switches are one black');
      expect(ttcTitleInk, ttcInk);
      expect(ttcTitleInk, isNot(const Color(0xFF2D144C)),
          reason: 'the plum-indigo the user flagged on "Start my round"');
      // It is the palette's own family: a neutral near-black, no hue of its
      // own worth the name (HSL saturation under 10%).
      expect(HSLColor.fromColor(ttcTitleInk).saturation, lessThan(0.10));
      expect(HSLColor.fromColor(ttcTitleInk).lightness, lessThan(0.20));
    });

    test('ink type reads on the deepest corner of every hero card field', () {
      // TtcHeroFieldCard (2026-09-29) sets every word in ttcInk on the light
      // field. The field's darkest stop is its top-right `deep` tone
      // (v3_hero_field.dart: lightness 0.62, saturation 0.58 x chroma), and
      // on a card that corner always sits under the painter's first arc, a
      // 22% white circle centred above the top-right with a radius of at
      // least 0.95 x the width, so it reaches the corner of any card no
      // taller than twice its width. Every hue a hero card is given must
      // keep ink at AA there.
      final p = V2PaletteStore.instance.current;
      final hues = [
        for (final c in TtcChapter.values) ttcChapterFieldHue(c),
        TtcCycleColours.fertileHue,
      ];
      for (final hue in hues) {
        final h = HSLColor.fromColor(v2BlockTint(hue, p));
        final deep = h
            .withSaturation((0.58 * v3FieldChroma(hue)).clamp(0.0, 1.0))
            .withLightness(0.62)
            .toColor();
        final corner = over(Colors.white.withValues(alpha: 0.22), deep);
        expect(contrast(ttcInk, corner), greaterThanOrEqualTo(4.5),
            reason: 'hue $hue: ink on the deep corner');
      }
    });

    test('the meta grey passes AA on white; the card shadow is ink, not plum',
        () {
      expect(contrast(ttcMuted, Colors.white), greaterThanOrEqualTo(4.5));
      expect(ttcMuted, V2PaletteStore.instance.current.ink3);
      for (final s in ttcCardShadow) {
        expect(s.color.withValues(alpha: 1), ttcInk);
      }
    });
  });

  // ===========================================================================
  group('2. the source', () {
    final live = ttcLiveLines();
    final byFile = <String, List<String>>{};
    List<String> fileLines(String f) =>
        byFile.putIfAbsent(f, () => File(f).readAsLinesSync());

    test('no off-palette hex on a live line', () {
      // Each was a second black, a second violet or a fourth red:
      const banned = {
        '2D144C': 'the plum-indigo (old ttcTitleInk / AppTheme.primary900)',
        '4A1C86': 'ttcPurpleDeep, outside its definition',
        '0xFFB42318': 'a second danger red; the one red is #B3261E',
        '0xFFC0392B': 'a third danger red',
        '0xFFD92D20': 'a fourth danger red',
        '0xFF8B8591': 'the old meta grey (3.6:1 on white)',
        // 2026-09-29: a lilac lift under a white surface is a second hue;
        // the one shadow is the ink's at 8% (ttcCardShadow, 0x142F2C30).
        '0xFFD0C8DC': 'the lilac shadow; use the ink shadow 0x142F2C30',
      };
      final hits = <String>[];
      for (final l in live) {
        for (final e in banned.entries) {
          if (l.code.contains(e.key) &&
              !l.code.contains('const Color ttcPurpleDeep')) {
            hits.add('${l.file}:${l.line} ${e.value}: ${l.code.trim()}');
          }
        }
      }
      expect(hits, isEmpty, reason: hits.join('\n'));
    });

    test('ttcPurpleDeep only ends a hero gradient, never colours a thing', () {
      final uses = live
          .where((l) =>
              l.code.contains('ttcPurpleDeep') &&
              !l.code.contains('const Color ttcPurpleDeep'))
          .toList();
      final bad = uses
          .where((l) => !l.code.contains('colors: [ttcPurple, ttcPurpleDeep]'))
          .map((l) => '${l.file}:${l.line} ${l.code.trim()}')
          .toList();
      expect(bad, isEmpty, reason: bad.join('\n'));
      // Kept for revert (2026-09-29): the six violet hero cards were a
      // decision left with the user, capped so a seventh had to be asked for:
      //   expect(uses.length, lessThanOrEqualTo(6));
      // They are on the tools' light field now (`TtcHeroFieldCard`), so the
      // cap is zero: a violet slab with white type is not a TTC surface.
      expect(uses.map((l) => '${l.file}:${l.line} ${l.code.trim()}'), isEmpty,
          reason: 'a hero card is TtcHeroFieldCard: the light field, ink type');
    });

    test('the hero cards wear the light field, with ink type', () {
      // Each former violet card, by file. A card that went back to a
      // gradient fails above; one that dropped the field fails here. (The
      // sixth, the old cycle screen's hero, sits in a /* */ block kept for
      // revert and is not live.)
      const cards = [
        'lib/screens/ttc/ttc_chapter_screen.dart',
        'lib/screens/ttc/ttc_cycle_screens.dart', // the fertile window
        'lib/screens/ttc/ttc_ritual_screen.dart',
        'lib/screens/ttc/ttc_today_screen.dart',
        'lib/screens/ttc/ttc_transition_screen.dart',
      ];
      for (final f in cards) {
        final n = live
            .where((l) => l.file == f && l.code.contains('TtcHeroFieldCard('))
            .length;
        expect(n, 1, reason: '$f lost its light hero card');
      }
    });

    test('his controls are the one black; slate is for his headers', () {
      // 2026-09-29: his segmented controls (Her / Him) filled the chosen
      // segment in slate. Slate stays on his hero gradient, his nav accent
      // and his tints; a FILL of slate on anything else is a second button
      // colour.
      final hits = <String>[];
      for (final l in live) {
        if (!RegExp(r'\bttcSlate\b').hasMatch(l.code)) continue;
        if (l.code.contains('colors: [ttcSlate, ttcSlateDeep]')) continue;
        if (!_isFill(fileLines(l.file), l.line - 1)) continue;
        hits.add('${l.file}:${l.line} ${l.code.trim()}');
      }
      expect(hits, isEmpty, reason: hits.join('\n'));
    });

    test('violet and V2 ink1 are never a FILL: every control is the one black',
        () {
      // Allowed violet fills, each for a reason:
      //  - the progress hairline (DESIGN-SYSTEM §4.0 permits it);
      const allowed = [
        'ttc_tool_chrome.dart', // TtcToolProgress's bar
        'ttc_fertility_help_screen.dart', // its progress hairline (ColoredBox)
        'ttc_pcos_check_screen.dart', // its progress hairline (ColoredBox)
      ];
      final violet = RegExp(
          r'\bttcPurple\b(?!Deep)|\b(?:p|pal)\.action\b|\bkTtcActionInk\b');
      final ink1 = RegExp(r'\b(?:p|pal)\.ink1\b(?!\.withValues)');
      final hits = <String>[];
      for (final l in live) {
        final isViolet = violet.hasMatch(l.code);
        final isInk1 = ink1.hasMatch(l.code);
        if (!isViolet && !isInk1) continue;
        if (!_isFill(fileLines(l.file), l.line - 1)) continue;
        // An ink1 EDGE (a rule, a ring) is a line, not a button; only an ink1
        // fill is a second black.
        if (isInk1 && !isViolet && RegExp(r'Border').hasMatch(l.code)) continue;
        if (isViolet &&
            allowed.any(l.file.endsWith) &&
            RegExp(r'ColoredBox|color: ttcPurple,$').hasMatch(l.code.trim())) {
          continue;
        }
        if (l.code.contains('colors: [ttcPurple, ttcPurpleDeep]')) continue;
        hits.add('${l.file}:${l.line} ${l.code.trim()}');
      }
      expect(hits, isEmpty,
          reason: 'a fill of violet or of V2 ink1 is a second button colour; '
              'use ttcTitleInk (the switch black):\n${hits.join('\n')}');
    });

    test('no tinted slab behind text', () {
      // A ttcPanel / ttcCautionCard / surfaceAlt FILL whose box holds words
      // and is not a pill, a circle, a small well or one of these:
      // Each exception is a file AND a mark in the box, so a second slab in
      // the same file is still caught.
      final allowed = <(String, RegExp, String)>[
        ('ttc_records_v2.dart', RegExp(r'ttcRecordDate\(taken\)'),
            'the date field (an input well)'),
        ('ttc_attachments.dart', RegExp(r'picture_as_pdf'),
            'the file chip (a tag)'),
        ('ttc_chat.dart', RegExp(r'.'),
            'the chat bubble (the promise, DESIGN-SYSTEM §4.2)'),
        ('ttc_shop_v3.dart', RegExp(r'_HatchPainter'),
            'the hatched photo placeholder'),
        ('ttc_kind_cards.dart', RegExp(r'_photo\('),
            "the product card's photo well"),
        ('ttc_window_screen.dart', RegExp(r'height: 10,'), 'the phase track'),
        ('ttc_profile_screen.dart', RegExp(r'.'),
            "Profile is another helper's (2026-09-29)"),
      ];
      final fill = RegExp(
          r'color:\s*(?:const\s+)?(ttcPanel|ttcCautionCard|(?:p|pal)\.surfaceAlt)\b\s*[,)]');
      final hits = <String>[];
      for (final l in live) {
        if (!fill.hasMatch(l.code)) continue;
        final lines = fileLines(l.file);
        final i = l.line - 1;
        final before =
            lines.sublist(math.max(0, i - 8), i + 1).join('\n');
        final after = lines.sublist(i, math.min(lines.length, i + 14)).join('\n');
        final isCard = RegExp(r'TtcCard\(|TtcCycleCard\(').hasMatch(before);
        final isDeco = RegExp(r'decoration|Decoration\(').hasMatch(before);
        if (!isCard && !isDeco) continue;
        final shape = after.split('child').first + before.substring(math.max(0, before.length - 200));
        if (RegExp(r'circular\(99+\)|StadiumBorder|BoxShape\.circle|CircleBorder')
            .hasMatch(shape)) {
          continue;
        }
        if (RegExp(r'(width|height):\s*\d{1,2}(\.\d)?,').hasMatch(before)) {
          continue;
        }
        if (!RegExp(r'Text\(|ttcBody|RichText').hasMatch(after)) continue;
        final around = '$before\n$after';
        if (allowed.any((a) => l.file.endsWith(a.$1) && a.$2.hasMatch(around))) {
          continue;
        }
        hits.add('${l.file}:${l.line} ${l.code.trim()}');
      }
      expect(hits, isEmpty,
          reason: 'a note is a grey line; a stat is a label and a number; a '
              'card is white with a hairline (DESIGN-SYSTEM §4.0):\n'
              '${hits.join('\n')}');
    });
  });

  // ===========================================================================
  group('3. the pixels', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      CycleStore.instance.resetForTest();
      TtcStore.instance.resetForTest();
      TtcLogStore.instance.resetForTest();
      TtcTreatmentStore.instance.resetForTest();
      TtcCategoryPrefs.instance.resetForTest();
    });

    const phone = Size(390, 844);

    Future<void> pumpPhone(WidgetTester tester, Widget home) async {
      tester.view.physicalSize = phone;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      // No theme: AppTheme fetches Google Fonts over the network in a test.
      // The colours under test are set on the widgets, not by the theme.
      await tester.pumpWidget(MaterialApp(key: UniqueKey(), home: home));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
    }

    /// The colour the scaffold's hero field paints at (x, y).
    ///
    /// ⚠️ COMPUTED, NOT RENDERED, AND THAT IS A TRADE-OFF WORTH NAMING.
    /// Rendering the field to an image needs `runAsync`, and real async lets
    /// the google_fonts loads of the screens under test fail over the network
    /// mid-test. So this replays `_FieldPainter` (v3_hero_field.dart) point by
    /// point: the four-stop gradient from the top-right corner, then the two
    /// arc circles laid over it. The 3% dot texture is left out (it only
    /// lightens). If the painter's recipe changes, change it here too; a
    /// replay that drifts from the painter would pass while the phone fails.
    Color Function(double x, double y) fieldOf(TtcToolScaffold s) {
      final p = V2PaletteStore.instance.current;
      final accent = v2BlockTint(s.hue % 360, p);
      final chroma = s.chroma ?? v3FieldChroma(s.hue % 360);
      final h = HSLColor.fromColor(accent);
      final shifted = HSLColor.fromAHSL(1, (h.hue + 34) % 360,
          (h.saturation + 0.10).clamp(0.0, 1.0), h.lightness);
      double sat(double v) => (v * chroma).clamp(0.0, 1.0);
      final deep = h.withSaturation(sat(0.58)).withLightness(0.62).toColor();
      final mid = shifted.withSaturation(sat(0.52)).withLightness(0.74).toColor();
      final pale = h.withSaturation(sat(0.40)).withLightness(0.90).toColor();
      final stops = [deep, mid, pale, p.ground];
      const at = [0.0, 0.34, 0.78, 1.0];
      final w = phone.width, ht = phone.height;
      final t = (s.variant % 6) / 6.0;
      final c1 = Offset(w * (0.82 - t * 0.30), -ht * (0.22 + t * 0.16));
      final r1 = w * (0.95 + t * 0.30);
      final c2 = Offset(w * (0.10 + t * 0.5), ht * (0.74 - t * 0.14));
      final r2 = w * (0.62 + (1 - t) * 0.26);
      final arc2 = shifted
          .withSaturation(sat(0.50))
          .withLightness(0.84)
          .toColor()
          .withValues(alpha: 0.5);
      // Gradient axis: (w, 0) -> (0, 0.62h).
      const ax = -1.0;
      final dx = ax * w, dy = 0.62 * ht;
      final len2 = dx * dx + dy * dy;
      return (x, y) {
        var f = (((x - w) * dx) + (y * dy)) / len2;
        f = f.clamp(0.0, 1.0);
        var k = 0;
        while (k < 2 && f > at[k + 1]) {
          k++;
        }
        final u = (f - at[k]) / (at[k + 1] - at[k]);
        var c = Color.lerp(stops[k], stops[k + 1], u)!;
        if ((Offset(x, y) - c1).distance <= r1) {
          c = over(Colors.white.withValues(alpha: 0.22), c);
        }
        if ((Offset(x, y) - c2).distance <= r2) c = over(arc2, c);
        return c;
      };
    }

    /// The colour of the nearest opaque box the element sits on, inside the
    /// hero, or null when it sits straight on the field.
    Color? solidGround(Element e, Element stop) {
      Color? found;
      e.visitAncestorElements((a) {
        if (a == stop) return false;
        final w = a.widget;
        Color? c;
        if (w is DecoratedBox) {
          final d = w.decoration;
          if (d is BoxDecoration) c = d.color;
          if (d is ShapeDecoration) c = d.color;
        } else if (w is Material && w.type != MaterialType.transparency) {
          c = w.color;
        }
        if (c != null && c.a >= 0.85) {
          found = over(c, Colors.white);
          return false;
        }
        return true;
      });
      return found;
    }

    /// Measures every word and icon in the hero of the screen on show.
    Future<List<String>> headerFailures(WidgetTester tester, String name) async {
      final scaffold =
          tester.widget<TtcToolScaffold>(find.byType(TtcToolScaffold).first);
      final hero = find
          .descendant(
              of: find.byType(TtcToolScaffold).first,
              matching: find.byType(SafeArea))
          .first;
      final heroEl = tester.element(hero);
      final paras = find.descendant(of: hero, matching: find.byType(RichText));
      final items = <({Rect rect, Color fg, bool icon, bool large, Color? solid, String what})>[];
      for (final el in paras.evaluate()) {
        final rp = el.renderObject! as RenderParagraph;
        if (!rp.attached || rp.size.isEmpty) continue;
        final style = rp.text.style;
        final fg = style?.color;
        if (fg == null || fg.a < 0.6) continue; // inactive controls are exempt
        final icon = (style?.fontFamily ?? '').contains('MaterialIcons');
        final size = style?.fontSize ?? 14;
        final bold = (style?.fontWeight?.value ?? 400) >= 700;
        final large = size >= 24 || (bold && size >= 18.66);
        final rect = rp.localToGlobal(Offset.zero) & rp.size;
        items.add((
          rect: rect,
          fg: fg,
          icon: icon,
          large: large,
          solid: solidGround(el, heroEl),
          what: rp.text.toPlainText().trim(),
        ));
      }
      expect(items, isNotEmpty, reason: '$name: nothing measured in the hero');
      final field = fieldOf(scaffold);
      final fails = <String>[];
      for (final it in items) {
        final need = it.icon || it.large ? 3.0 : 4.5;
        var worst = double.infinity;
        if (it.solid != null) {
          worst = contrast(over(it.fg, it.solid!), it.solid!);
        } else {
          final r = it.rect.intersect(Offset.zero & phone);
          if (r.isEmpty) continue;
          for (var y = r.top.ceil(); y < r.bottom.floor(); y += 2) {
            for (var x = r.left.ceil(); x < r.right.floor(); x += 2) {
              final g = field(x.toDouble(), y.toDouble());
              worst = math.min(worst, contrast(over(it.fg, g), g));
            }
          }
          if (worst == double.infinity) continue;
        }
        if (worst < need) {
          fails.add('$name: "${it.what}" ${it.icon ? 'icon' : 'text'} '
              '${it.fg} at ${worst.toStringAsFixed(2)}:1 (needs $need)');
        }
      }
      return fails;
    }

    /// Every dark, opaque pill on the screen is the switch black.
    List<String> darkPillFailures(WidgetTester tester, String name) {
      final bad = <String>[];
      for (final el in find.byType(DecoratedBox).evaluate()) {
        final d = (el.widget as DecoratedBox).decoration;
        Color? c;
        var pill = false;
        if (d is BoxDecoration) {
          c = d.color;
          final br = d.borderRadius;
          pill = d.shape == BoxShape.circle ||
              (br is BorderRadius && br.topLeft.x >= 99);
        } else if (d is ShapeDecoration) {
          c = d.color;
          pill = d.shape is StadiumBorder || d.shape is CircleBorder;
        }
        if (c == null || !pill || c.a < 0.99) continue;
        if (_lum(c) > 0.06) continue; // only the dark ones
        if (c != ttcTitleInk) bad.add('$name: a dark pill in $c');
      }
      return bad;
    }

    final screens = <String, Widget Function()>{
      'Symptoms and mood': () => const TtcSymptomLogScreen(),
      'Cycle report': () => const TtcCycleReportScreen(),
      'Medication': () => const TtcMedicationScreen(),
      'Supplements': () => const TtcSupplementsScreen(),
      'Appointments': () => const TtcAppointmentsScreen(),
      'BMI': () => const TtcBmiScreen(),
      'Vaccinations': () => const TtcVaccinesScreen(),
      'Get help': () => const TtcGetHelpScreen(),
      'Edit categories': () => const TtcEditCategoriesScreen(),
    };

    for (final e in screens.entries) {
      testWidgets('${e.key}: the header reads, and its pills are the one black',
          (tester) async {
        await pumpPhone(tester, e.value());
        final pills = darkPillFailures(tester, e.key);
        final header = await headerFailures(tester, e.key);
        expect([...pills, ...header], isEmpty,
            reason: [...pills, ...header].join('\n'));
      });
    }

    testWidgets('the logger header has no calendar icon and nothing violet',
        (tester) async {
      await pumpPhone(tester, const TtcSymptomLogScreen());
      final picker = find.byKey(const ValueKey('ttc_log_day_name'));
      expect(picker, findsOneWidget);
      expect(
          find.descendant(
              of: picker, matching: find.byIcon(Icons.calendar_today_rounded)),
          findsNothing,
          reason: 'the user: "why do we need a calendar icon altogether"');
      final hero = find
          .descendant(
              of: find.byType(TtcToolScaffold), matching: find.byType(SafeArea))
          .first;
      for (final el
          in find.descendant(of: hero, matching: find.byType(RichText)).evaluate()) {
        final c = (el.renderObject! as RenderParagraph).text.style?.color;
        expect(c, isNot(ttcPurple));
      }
      // The arrows are still the way to change day.
      expect(find.byKey(const ValueKey('ttc_log_day_back')), findsOneWidget);
      expect(find.byKey(const ValueKey('ttc_log_day_forward')), findsOneWidget);
    });

    testWidgets(
        'Cycle companion: the stat and the note have no filled background',
        (tester) async {
      DateTime ago(int d) {
        final n = DateTime.now().subtract(Duration(days: d));
        return DateTime(n.year, n.month, n.day);
      }

      // An 8-day gap (too short to count) so the note shows, and two
      // counted cycles so the stats do.
      CycleStore.instance
        ..logPeriodStart(ago(98))
        ..logPeriodStart(ago(70))
        ..logPeriodStart(ago(62))
        ..logPeriodStart(ago(34))
        ..logPeriodStart(ago(6));
      tester.view.physicalSize = const Size(400, 6000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
          const MaterialApp(home: TtcCycleCompanionScreen()));
      await tester.pump(const Duration(milliseconds: 300));

      final facts = find.byKey(const ValueKey('ttc_companion_fact'));
      expect(facts, findsWidgets);
      for (final el in facts.evaluate()) {
        // A SizedBox paints nothing: the stat sits on the card's white.
        expect(el.widget, isA<SizedBox>(),
            reason: 'a stat is a label and a number on the white');
        expect(
            find.descendant(
                of: find.byWidget(el.widget),
                matching: find.byType(DecoratedBox)),
            findsNothing);
      }
      final note = find.byKey(const ValueKey('ttc_companion_not_counted_note'));
      expect(note, findsOneWidget);
      expect(tester.widget(note), isA<SizedBox>(),
          reason: 'a note is a quiet line');
      expect(find.descendant(of: note, matching: find.byType(DecoratedBox)),
          findsNothing);
    });
  });
}
