// =============================================================================
//  EXPORT TOOL (not a test) — the Pregnancy review pack's extras.
// -----------------------------------------------------------------------------
//  Run:  flutter test tool/review/export_review_pregnancy.dart
//  Out:  build/review_pregnancy_extras.json
//
//  Writes down the Pregnancy content that lives in Dart and is NOT in
//  build/pregnancy_corpus.json or build/veda_corpus.json: the week pages, the
//  special weeks, the per-week extras, the daily tips, the phone messages, the
//  held FAQs, the three doors outside `kPvDoorPages`, the door structure (tabs,
//  sections, week bands), the reads re-rendered with their headings marked, and
//  a few lists the review pack needs. English only: no `.hi` is read.
//
//  Companion to `tool/export_pregnancy_corpus.dart` (same style).
// =============================================================================

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/ask_veda/pv_veda_corpus.dart';
import 'package:parentveda/ask_veda/pv_veda_links.dart';
import 'package:parentveda/data/book_companions.dart';
import 'package:parentveda/data/can_i_data.dart';
import 'package:parentveda/data/doors/pv_door_after_loss.dart';
import 'package:parentveda/data/doors/pv_door_data.dart';
import 'package:parentveda/data/doors/pv_door_partner.dart';
import 'package:parentveda/data/doors/pv_door_twins.dart';
import 'package:parentveda/data/garbh_sheet.dart';
import 'package:parentveda/data/journeys/pregnancy_journeys.dart';
import 'package:parentveda/data/preg_daily_tips.dart';
import 'package:parentveda/data/preg_faqs.dart';
import 'package:parentveda/data/preg_week_extras.dart';
import 'package:parentveda/data/preg_week_pages.dart';
import 'package:parentveda/data/products/pv_coming_soon.dart';
import 'package:parentveda/data/products/pv_sheet_products.dart';
import 'package:parentveda/data/products/sheet/catalogue.dart';
import 'package:parentveda/data/read_next_data.dart';
import 'package:parentveda/data/week_articles_data.dart';
import 'package:parentveda/data/reads/can_i_read.dart';
import 'package:parentveda/data/reads/pregnancy_reads.dart';
import 'package:parentveda/data/reads/read_adapters.dart' show PvScanParametersBlock;
import 'package:parentveda/data/reads/symptom_reads.dart';
import 'package:parentveda/data/symptoms/symptom_normal.dart';
import 'package:parentveda/localization/app_language.dart';
import 'package:parentveda/models/pv_read.dart';
import 'package:parentveda/screens/preg_daily_insights.dart';
import 'package:parentveda/services/bracket_resolver.dart' show bracketById;
import 'package:parentveda/services/preg_messages_store.dart';

String _l(LocalizedText? t) => t?.en ?? '';

String _join(Iterable<String?> parts, {String sep = '\n\n'}) =>
    parts.where((s) => s != null && s.trim().isNotEmpty).map((s) => s!.trim()).join(sep);

String _h(LocalizedText? t) {
  final s = _l(t).trim();
  return s.isEmpty ? '' : '## $s';
}

/// `pvVedaReadBody` with each section heading marked "## ". Removing the
/// markers must give the corpus body back exactly (the Python builder checks).
String markedRead(PvRead r) => _join([
      _l(r.shortAnswer),
      _l(r.scaleSetter),
      _l(r.teaser),
      for (final s in r.sections)
        _join([
          _h(s.heading),
          _l(s.summary),
          ...s.paragraphs.map(_l),
          _join(s.bullets.map((b) => '- ${_l(b)}'), sep: '\n'),
          if (s.tip != null) _join([_l(s.tip!.title), _l(s.tip!.body)]),
          if (s.mythFact != null)
            _join(['Myth: ${_l(s.mythFact!.myth)}', 'Fact: ${_l(s.mythFact!.fact)}']),
          if (s.callout != null) _join([_l(s.callout!.title), _l(s.callout!.body)]),
          if (s.custom case PvScanParametersBlock(:final parameters))
            pvVedaScanParametersText(parameters),
        ]),
      _join([_h(r.whenToSeeSomeone.title), _l(r.whenToSeeSomeone.body)]),
      _l(r.evidence),
    ]);

String _askLabel(PregFaqSection s) => switch (s) {
      PregFaqSection.direct => 'Answer:',
      PregFaqSection.why => 'Why this happens:',
      PregFaqSection.whyMatters => 'Why it matters:',
      PregFaqSection.forYou => 'What this means for you:',
      PregFaqSection.doctor => 'When to speak to your doctor:',
      PregFaqSection.perspective => 'ParentVeda perspective:',
      PregFaqSection.takeaways => 'Quick takeaways:',
    };

/// `pvVedaAskBody` with the question line left out (the title carries it) and
/// each part's heading marked. Python re-checks it against the corpus.
String markedAsk(PregFaq f) => _join([
      'Written for: ${f.applicability.isEmpty ? 'month ${f.month} of pregnancy' : f.applicability}'
          ' (month ${f.month} of pregnancy).',
      for (final p in f.parts)
        _join([
          '## ${p.heading.isNotEmpty ? p.heading : _askLabel(p.section)}',
          ...p.paragraphs,
          _join(p.bullets.map((b) => '- $b'), sep: '\n'),
        ], sep: '\n'),
    ]);

String? _band(PvDoorSection s) =>
    s.weeks == null ? null : '${s.weeks!.from}-${s.weeks!.to}';

Map<String, dynamic> _tile(PvDoorPage page, PvDoorTile t, Set<String> paged) {
  String kind = t.runtimeType.toString();
  String? entryBody;
  String? entryId;
  String? library;
  String? readId;
  String? surfaceId;
  String? atHeading;
  if (t is PvDoorEntryTile) {
    entryId = t.entryId;
    library = t.library.name;
    final r = pvVedaEntryRead(t.library, t.entryId);
    if (r != null) entryBody = markedRead(r);
  }
  if (t is PvDoorGuideTile) {
    readId = t.readId;
    atHeading = t.atHeading;
  }
  if (t is PvDoorMythTile) readId = t.readId;
  if (t is PvDoorToolTile) surfaceId = t.surfaceId;
  if (t is PvDoorChecklistTile) surfaceId = t.surfaceId;
  if (t is PvDoorTalkTile) surfaceId = t.surfaceId;
  if (t is PvDoorGameTile) surfaceId = t.surfaceId;
  if (t is PvDoorReadTile) surfaceId = t.surfaceId;
  if (t is PvDoorAudioTile) surfaceId = t.surfaceId;
  final isDoc = pvVedaTileIsDocument(t);
  return {
    'kind': kind,
    'format': t.format.label,
    'title': t.title,
    'blurb': t.blurb,
    'meta': t.meta,
    'comingSoon': t.comingSoon,
    'readId': readId,
    'atHeading': atHeading,
    'entryId': entryId,
    'library': library,
    'surfaceId': surfaceId,
    'isDoc': isDoc,
    'docId': isDoc ? pvVedaDoorId(page.bracketId, t) : null,
    'slug': pvTileSlug(t.title),
    // The page behind the card, carried by the FIRST card in door order that
    // opens it (exactly as the corpus does).
    'carriesPage': t is PvDoorEntryTile && isDoc && paged.add('${t.library.name}:${t.entryId}'),
    'entryBody': entryBody,
  };
}

Map<String, dynamic> _door(PvDoorPage page, String name, Set<String> paged) {
  final groups = [
    for (final g in page.groups)
      {
        'id': g.id,
        'label': g.label,
        'note': g.note,
        'noteByWeek': g.noteFor == null
            ? null
            : {for (var w = 1; w <= 42; w++) '$w': g.noteFor!(w)},
        'redFlag': g.pinnedRedFlag == null
            ? null
            : {
                'title': g.pinnedRedFlag!.title,
                'lines': [for (final l in g.pinnedRedFlag!.lines) l.text],
                'footer': g.pinnedRedFlag!.footer,
              },
      }
  ];
  return {
    'bracketId': page.bracketId,
    'name': name,
    'heroTitle': page.heroTitle,
    'heroBlurb': page.heroBlurb,
    'heroBlurbEnded': page.heroBlurbEnded,
    'closingLine': page.closingLine,
    'opensOn': page.openingGroupFor == null
        ? null
        : {for (var w = 1; w <= 42; w++) '$w': page.openingGroupFor!(w)},
    'groups': groups,
    'sections': [
      for (final s in page.sections)
        {
          'group': s.group,
          'heading': s.heading,
          'weeks': _band(s),
          'folded': s.folded,
          'forAfterLoss': s.forAfterLoss,
          'tilesByWeek': s.tilesByWeek,
          'leadsFor': [for (final l in s.leadsFor) l.name],
          'inline': s.inlineSurfaceId,
          'tiles': [for (final t in s.tiles) _tile(page, t, paged)],
        }
    ],
  };
}

void main() {
  test('export the pregnancy review extras to build/review_pregnancy_extras.json', () {
    final out = <String, dynamic>{};

    // ---- week pages (the Drive docs), weeks 5-18 and 20-23 -------------------
    out['weekPages'] = [
      for (final p in kPregWeekPageList)
        {
          'week': p.week,
          'fruit': p.fruit,
          'length': p.length,
          'weight': p.weight,
          'teaser': p.teaser,
          'about': [for (final a in p.about) [a.heading, a.body]],
          'behaviour': [for (final a in p.behaviour) [a.title, a.body]],
          'science': [for (final a in p.science) [a.title, a.body]],
          'you': [for (final a in p.you) [a.heading, a.body]],
          'highlights': [for (final a in p.highlights) [a.title, a.teaser, a.body]],
          'selfCare': p.selfCare,
          'reminder': p.reminder,
          'symptoms': [
            for (final s in p.symptoms)
              {
                'name': s.name,
                'teaser': s.teaser,
                'howCommon': s.howCommon,
                'why': s.why,
                'helps': s.helps,
                'whenToCall': s.whenToCall,
              }
          ],
          'symptomsFooter': p.symptomsFooter,
          'superfood': {
            'food': p.superfood.food,
            'benefit': p.superfood.benefit,
            'tryAs': p.superfood.tryAs,
            'note': p.superfood.note,
          },
          'favour': [for (final f in p.favour) [f.name, f.reason]],
          'avoid': [for (final f in p.avoid) [f.name, f.reason]],
          'tipsTitle': p.tipsTitle,
          'tips': [for (final t in p.tips) [t.tip, t.more]],
          'partnerNote': p.partnerNote,
          'partnerHowMom': p.partnerHowMom,
          'partnerScans': p.partnerScans,
          'partnerHelp': p.partnerHelp,
        }
    ];
    out['weekPageFixed'] = {
      'scienceFooter': kPregWeekScienceFooter,
      'symptomsIntro': kPregWeekSymptomsIntro,
    };

    // ---- weeks 1-3 and 41-42 --------------------------------------------------
    out['specialWeeks'] = [
      for (final p in kPregSpecialWeekPages)
        {
          'id': p.id,
          'weeks': p.weeks,
          'chip': p.chipLabel,
          'title': p.title,
          'shortAnswer': p.shortAnswer,
          'sections': [
            for (final s in p.sections)
              {'heading': s.heading, 'paragraphs': s.paragraphs, 'bullets': s.bullets}
          ],
          'callYourDoctor': p.callYourDoctor,
          'asked': [for (final q in p.asked) [q.q, q.a]],
          'sources': p.sources,
        }
    ];

    // ---- per-week extras and the sources they cite ---------------------------
    out['weekExtras'] = {
      for (final e in kPregWeekExtras.values)
        '${e.week}': {
          'symptomTips': [for (final t in e.symptomTips) [t.symptom, t.tip]],
          'asked': [for (final q in e.asked) [q.q, q.a]],
          'sources': e.sources,
        }
    };
    out['weekSources'] = {for (final e in kPregWeekSources.entries) e.key: e.value.label};

    // ---- daily tips ------------------------------------------------------------
    out['dailyTips'] = {for (final e in kPregDailyTips.entries) '${e.key}': e.value};

    // ---- phone messages --------------------------------------------------------
    final seen = <String>{};
    final msgs = <Map<String, dynamic>>[];
    final base = DateTime(2026, 1, 5, 6);
    for (final clinic in [false, true]) {
      for (var w = 4; w <= 42; w++) {
        final due = DateTime(base.year, base.month, base.day)
            .add(Duration(days: (40 - w) * 7 + 3));
        final f = PregMessageFacts(
          dueDate: due,
          dueDateSet: true,
          dueDateFromClinic: clinic,
        );
        for (final m in pregMessageCandidates(f, base)) {
          final key = '${m.id}|$clinic';
          if (m.kind == PregMessageKind.dayLine) continue; // = the daily tips
          if (!seen.add(key)) continue;
          if (clinic && m.id != 'datingScan') {
            // the clinic variant only matters for the dating scan
          }
          msgs.add({
            'id': m.id,
            'kind': m.kind.name,
            'week': m.week,
            'title': m.title,
            'body': m.body,
            'fromClinic': clinic,
          });
        }
      }
    }
    out['messages'] = msgs;
    out['messageKinds'] = [
      for (final k in PregMessageKind.values)
        {'kind': k.name, 'label': k.label, 'when': k.when, 'rank': k.slotRank, 'daily': k.isDaily}
    ];

    // ---- held FAQs and marked bodies for every FAQ -------------------------------
    final faqs = <Map<String, dynamic>>[];
    for (final f in kPregFaqsAll) {
      faqs.add({
        'id': f.id,
        'number': f.number,
        'month': f.month,
        'question': f.question,
        'category': f.category,
        'applicability': f.applicability,
        'canI': f.canI,
        'sensitivity': f.sensitivity,
        'held': f.held,
        'live': f.isLive,
        'heldNote': f.heldNote,
        'marked': markedAsk(f),
        'corpusBody': pvVedaAskBody(f),
      });
    }
    out['faqs'] = faqs;
    out['faqMonths'] = [
      for (final m in kPregFaqMonths) {'month': m.month, 'from': m.fromWeek, 'to': m.toWeek}
    ];

    // ---- reads, re-rendered with marked headings --------------------------------
    final reads = <String, dynamic>{};
    for (final r in kPregnancyReads) {
      if (reads.containsKey(r.id)) continue;
      reads[r.id] = {
        'title': r.title.en,
        'kicker': r.kicker.en,
        'reviewed': r.reviewed,
        'author': r.author.en,
        'authorRole': r.authorRole.en,
        'marked': markedRead(r),
        'corpusBody': pvVedaReadBody(r),
        'faqs': r.faqs.length,
      };
    }
    for (final q in kNormalQuestions) {
      final r = pvReadFromNormal(q);
      reads[r.id] = {
        'title': q.question,
        'kicker': r.kicker.en,
        'reviewed': r.reviewed,
        'marked': _join([q.question, markedRead(r)]),
        'corpusBody': _join([q.question, pvVedaReadBody(r)]),
        'faqs': 0,
      };
    }
    out['reads'] = reads;
    out['weekArticles'] = [
      for (final a in kWeekArticles)
        {'week': a.week, 'title': a.title, 'readMins': a.readMins, 'body': a.body}
    ];
    out['readItems'] = [
      for (final r in kReadItems)
        {
          'id': r.id,
          'title': r.title.en,
          'type': r.type.name,
          'weekStart': r.weekStart,
          'weekEnd': r.weekEnd,
          'priority': r.priority,
        }
    ];

    // ---- doors: the twelve in the app's list, then the three outside it ----------
    final paged = <String>{};
    final doors = <Map<String, dynamic>>[];
    for (final page in kPvDoorPages) {
      final b = bracketById(page.bracketId);
      doors.add(_door(page, b?.label.en ?? page.heroTitle, paged));
    }
    doors.add(_door(kPartnerDoor, kPregPartnerBracket.label.en, paged));
    doors.add(_door(kTwinsDoor, kPregTwinsBracket.label.en, paged));
    doors.add(_door(kAfterLossDoor, kPregAfterLossBracket.label.en, paged));
    out['doors'] = doors;
    out['afterLossScreens'] = {
      'rowTitle': kPregEndedRowTitle,
      'rowSub': kPregEndedRowSub,
      'title': kPregEndedTitle,
      'body': kPregEndedBody,
      'confirm': kPregEndedConfirm,
      'cancel': kPregEndedCancel,
      'undoTitle': kPregEndedUndoTitle,
      'undoBody': kPregEndedUndoBody,
      'undoConfirm': kPregEndedUndoConfirm,
      'undoCancel': kPregEndedUndoCancel,
      'homeTitle': kPregEndedHomeTitle,
      'done': kPregEndedDone,
      'tabLines': kPregEndedTabLines,
      'partnerTitle': kPregEndedPartnerTitle,
      'partnerBody': kPregEndedPartnerBody,
      'undoLink': kPregEndedUndoLink,
    };

    // ---- history lifts -------------------------------------------------------------
    out['lifts'] = {
      for (final e in kPregLiftPages.entries) e.key.name: e.value.toList()
    };

    // ---- scan windows the home may mention ----------------------------------------
    out['scanWindows'] = [
      for (final w in pregScanWindows())
        {'id': w.id, 'title': w.title, 'from': w.from, 'to': w.to}
    ];

    // ---- journeys (guided paths) ---------------------------------------------------
    final js = [...kPregnancyJourneys.values, kPgUnderstandCondition];
    out['journeys'] = [
      for (final j in js)
        {
          'doorId': j.doorId,
          'registered': kPregnancyJourneys.containsKey(j.doorId) &&
              !identical(kPregnancyJourneys[j.doorId], kPgUnderstandCondition),
          'title': j.title.en,
          'intro': j.intro.en,
          'closesWhen': j.closesWhen?.en,
          'steps': [
            for (final s in j.steps)
              {
                'question': s.question.en,
                'note': s.note?.en,
                'elements': [
                  for (final e in s.elements)
                    {
                      'type': e.type.name,
                      'title': e.title.en,
                      'value': e.value.en,
                      'meta': e.meta?.en,
                      'owed': e.owed,
                    }
                ],
              }
          ],
        }
    ];

    // ---- Can I? details the corpus body leaves out --------------------------------
    out['canI'] = {
      for (final e in kCanIEntries)
        e.id: {
          'verdict': canIVerdictWord(e.verdict),
          'category': e.category.name,
          'short': e.short.en,
          'why': e.why.en,
          't1': e.t1?.en,
          't2': e.t2?.en,
          't3': e.t3?.en,
          'indian': e.indian?.en,
          'indianHeading': canIIndianHeading(e.category),
        }
    };

    // ---- Garbh Sanskar sheet: one entry per day of pregnancy -------------------------
    out['garbhDays'] = [
      for (final d in kGarbhSheetDays)
        {
          'day': d.day,
          'mother': d.mother,
          'father': d.father,
          'storyTitle': d.storyTitle,
          'story': d.story,
          'storyClose': d.storyClose,
        }
    ];

    // ---- book companions on the pregnancy shelf ----------------------------------------
    out['books'] = [
      for (final d in kBookDocList)
        if (bookStage(d) != BookStage.parenting)
          {
            'id': d.id,
            'stage': bookStage(d).name,
            'title': d.title,
            'author': d.author,
            'minutes': d.minutes,
            'recommendedFor': d.recommendedFor,
            'themes': d.themes,
            'about': d.about,
            'authorIntro': d.authorIntro,
            'otherBooks': d.otherBooks,
            'philosophy': d.philosophy,
            'ideas': [for (final i in d.ideas) {'title': i.title, 'body': i.body, 'points': i.points}],
            'chapters': [
              for (final c in d.chapters) {'title': c.title, 'summary': c.summary, 'points': c.points}
            ],
            'take': d.take,
            'takePoints': [for (final p in d.takePoints) {'good': p.good, 'text': p.text}],
            'quotes': d.quotes,
            'addendumTitle': d.addendumTitle,
            'addendumBody': d.addendumBody,
            'addendumPoints': d.addendumPoints,
          }
    ];

    // ---- the team's product sheet and the coming-soon shelves -----------------------------
    out['sheetPicks'] = [
      for (final p in kSheetPicks)
        {
          'id': p.id,
          'bucket': p.bucket.name,
          'category': p.category,
          'sub': p.sub,
          'factors': p.factors,
          'tier': p.tier,
          'brand': p.brand,
          'name': p.name,
          'week': p.week,
          'held': p.held,
          'live': p.held ? kSheetSubsSignedOff.contains(p.sub) : true,
        }
    ];
    out['comingSoonProducts'] = [
      for (final e in kPvComingSoon) {'id': e.id, 'name': e.name, 'seedId': e.seedId, 'line': e.line}
    ];
    out['comingSoonLine'] = kPvComingSoonLine;

    final f = File('build/review_pregnancy_extras.json');
    f.parent.createSync(recursive: true);
    f.writeAsStringSync(const JsonEncoder.withIndent(' ').convert(out));

    // ignore: avoid_print
    print('\nEXPORTED review extras -> build/review_pregnancy_extras.json\n'
        '  week pages ${(out['weekPages'] as List).length}, special ${(out['specialWeeks'] as List).length}, '
        'messages ${msgs.length}, faqs ${faqs.length}, reads ${reads.length}, doors ${doors.length}, '
        'journeys ${(out['journeys'] as List).length}, garbh days ${(out['garbhDays'] as List).length}, '
        'books ${(out['books'] as List).length}');
    expect(out['weekPages'], isNotEmpty);
  });
}
