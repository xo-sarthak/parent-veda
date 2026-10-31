// =============================================================================
//  EXPORT TOOL (not a test) — the parts of the Parenting side that are NOT in
//  build/parenting_corpus.json, written down for the content review pack.
// -----------------------------------------------------------------------------
//  Run:  flutter test tool/review/export_review_parenting.dart
//  Out:  build/review_parenting_extras.json
//
//  Read-only: it only reads constants already in the app and writes one JSON
//  file under build/. English only. Companion to tool/export_parenting_corpus.dart.
//
//  What it writes (all plain data, no widgets):
//    sections   every door page with its shelf (area), the shelf's bands, its
//               own bands, its format, and the signals that lift it
//    doors      tabs, tab order by age, tools, age rails, closings
//    bandSets   each section's age bands in months
//    phases / phaseDocs / ageTips / dailyTips / monthNotes / milestones /
//    vaccines / concerns / recipes / reco / remedies / journeys / ...
// =============================================================================

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/data/doors/pp_door_data.dart';
import 'package:parentveda/data/journeys/parenting_journeys.dart';
import 'package:parentveda/data/pp_phase_docs.dart';
import 'package:parentveda/screens/post_pregnancy/pp_age_bands.dart';
import 'package:parentveda/screens/post_pregnancy/pp_baby_food_check_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_content.dart';
import 'package:parentveda/screens/post_pregnancy/pp_daily_tips.dart';
import 'package:parentveda/screens/post_pregnancy/pp_development_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_din_by_din.dart';
import 'package:parentveda/screens/post_pregnancy/pp_faq_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_father_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_food_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_maa_can_i_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_milestones_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_month_notes.dart';
import 'package:parentveda/screens/post_pregnancy/pp_nuskhe_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_phase_faqs.dart';
import 'package:parentveda/screens/post_pregnancy/pp_phases_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_reco_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_relevance.dart';
import 'package:parentveda/screens/post_pregnancy/pp_section_registry.dart';
import 'package:parentveda/screens/post_pregnancy/pp_tile_order.dart';
import 'package:parentveda/screens/post_pregnancy/pp_tip_links.dart';
import 'package:parentveda/screens/post_pregnancy/pp_vaccine_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_what_changed_data.dart';

Map<String, dynamic> _closing(PpDoorClosing? c) => c == null
    ? <String, dynamic>{}
    : {'label': c.label, 'blurb': c.blurb, 'surface': c.surfaceId, 'note': c.note};

Map<String, dynamic> _band(PpBand b) => {
      'id': b.id,
      'label': b.label,
      'from': b.fromMonths,
      'to': b.toMonths,
      'fromWeeks': b.fromWeeks,
      'toWeeks': b.toWeeks,
      'blurb': b.blurb,
    };

Map<String, dynamic> _bandSet(PpBandSet s) => {
      'youngest': s.youngestClock,
      'corrected': s.correctedClock,
      'bands': [for (final b in s.bands) _band(b)],
    };

void main() {
  test('export the parenting review extras to build/review_parenting_extras.json', () {
    final out = <String, dynamic>{};

    // ---- band sets used by the sections --------------------------------------
    final bandSets = <String, dynamic>{};
    final bandSetsShared = <String, dynamic>{
      'kPpChildBands': _bandSet(kPpChildBands),
      'kPpSleepBands': _bandSet(kPpSleepBands),
      'kPpPostpartumBands': _bandSet(kPpPostpartumBands),
    };

    // ---- sections: every shelf and page ----------------------------------------
    final sections = <Map<String, dynamic>>[];
    for (final s in kPpSections) {
      if (s.bandSet != null) bandSets[s.id] = _bandSet(s.bandSet!);
      sections.add({
        'id': s.id,
        'title': s.title,
        'subtitle': s.subtitle,
        'intro': s.intro,
        'autoScope': s.autoScope,
        'tools': [
          for (final t in s.tools) {'label': t.label, 'blurb': t.blurb, 'surface': t.surfaceId},
        ],
        'areas': [
          for (final a in s.areas)
            {
              'id': a.id,
              'title': a.title,
              'blurb': a.blurb,
              'bands': a.bands,
              'toolSurface': a.toolSurfaceId,
              'pinned': a.pinned,
              'pages': [
                for (final p in a.pages)
                  {
                    'id': p.id,
                    'title': p.title,
                    'subtitle': p.subtitle,
                    'bands': p.bands,
                    'format': p.format,
                    'comingSoon': p.comingSoon,
                    'linkedOnly': p.linkedOnly,
                    'pinned': p.pinned,
                    'toolSurface': p.toolSurfaceId,
                    'aboutAdult': p.aboutAdult,
                    'hasVideo': p.hasVideo,
                    'videos': [
                      for (final b in p.blocks)
                        if (b is PpVideoSlot) {'title': b.title, 'subtitle': b.subtitle, 'minutes': b.minutes, 'slot': b.slotId},
                    ],
                    'audios': [
                      for (final b in p.blocks)
                        if (b is PpAudioSlot)
                          {'title': b.title, 'category': b.category, 'minutes': b.minutes, 'slot': b.slotId, 'pending': b.pendingNote},
                    ],
                    'ageLead': p.ageLead == null
                        ? null
                        : {'fromMonths': p.ageLead!.fromMonths, 'olderHeading': p.ageLead!.olderHeading},
                    'signals': [
                      for (final sig in PpSignal.values)
                        if (sig.matches(p.title, [p.id])) sig.name,
                    ],
                  },
              ],
            },
        ],
      });
    }
    out['sections'] = sections;
    out['bandSets'] = bandSets;
    out['bandSetsShared'] = bandSetsShared;

    // ---- doors ----------------------------------------------------------------
    out['doors'] = [
      for (final d in kPpDoors)
        {
          'section': d.sectionId,
          'aboutHer': d.aboutHer,
          'hiddenAreaIds': d.hiddenAreaIds,
          'closing': _closing(d.closing),
          'closingLine': d.closingLine,
          'disclaimer': d.disclaimer,
          'tabOrder': d.tabOrder,
          'emergency': d.emergency == null
              ? null
              : {
                  'calls': [for (final c in d.emergency!.calls) '${c.label} ${c.number}'],
                  'numbersLine': d.emergency!.numbersLine,
                  'links': [for (final l in d.emergency!.links) {'label': l.label, 'surface': l.surfaceId}],
                  'pin': d.emergency!.pin == null
                      ? null
                      : {
                          'tab': d.emergency!.pin!.tabId,
                          'title': d.emergency!.pin!.title,
                          'line': d.emergency!.pin!.line,
                          'surface': d.emergency!.pin!.surfaceId,
                        },
                },
          'tabs': [
            for (final t in d.tabs)
              {
                'id': t.id,
                'label': t.label,
                'areaIds': t.areaIds,
                'toMonths': t.toMonths,
                'redFlagPageId': t.redFlagPageId,
                'jumpToTabId': t.jumpToTabId,
                'jumpTitle': t.jumpTitle,
                'note': t.note,
                'footer': t.footer,
                'extraPageIds': t.extraPageIds,
                'inlineSurface': t.inlineSurfaceId,
                'expert': _closing(t.expert),
                'closing': _closing(t.closing),
                'shop': _closing(t.shop),
                'ageRail': {
                  for (final e in t.ageRail.entries) e.key: {'title': e.value.title, 'pageIds': e.value.pageIds},
                },
                'tools': [
                  for (final x in t.tools)
                    {
                      'label': x.label,
                      'blurb': x.blurb,
                      'surface': x.surfaceId,
                      'chip': x.chip,
                      'afterPageId': x.afterPageId,
                      'atEnd': x.atEnd,
                      'bands': x.bands,
                    },
                ],
              },
          ],
        },
    ];

    // inline shelves on Sleep and Behaviour (the "Tonight" / "Right now" cards)
    out['sleepTonight'] = {
      for (final e in kPpSleepTonightCards.entries)
        e.key: [for (final c in e.value) {'name': c.name, 'page': c.pageId, 'surface': c.surfaceId}],
    };
    out['behRightNow'] = {
      for (final e in kPpBehRightNowCards.entries)
        e.key: [for (final c in e.value) {'name': c.name, 'page': c.pageId, 'surface': c.surfaceId}],
    };

    // ---- signals + home tile order by age --------------------------------------
    out['signals'] = [
      for (final s in PpSignal.values)
        {
          'name': s.name,
          'why': s.why,
          'because': s.because,
          'words': s.words,
          'pageIds': s.pageIds.toList(),
          'leadTabs': s.leadTabs,
        },
    ];
    final ids = [for (final s in kPpSections) s.id];
    out['tileOrder'] = {
      for (final d in const [10, 50, 100, 190, 280, 370, 550, 740, 1100, 1470, 1830, 2200])
        '$d': ppTileOrder(ids, ageInDays: d),
    };
    out['tileOrderCSection'] = {
      for (final d in const [10, 50, 100])
        '$d': ppTileOrder(ids, ageInDays: d, birthMode: null),
    };

    // ---- age phases (authored, not shown) and the team's phase docs ------------
    out['phases'] = [
      for (final p in kPhasesAuthored)
        {
          'number': p.number,
          'name': p.name,
          'ageLabel': p.ageLabel,
          'start': p.startMonth,
          'end': p.endMonth,
          'tagline': p.tagline,
          'summary': p.summary,
          'workingOn': p.workingOn,
          'reassurance': p.reassurance,
          'milestones': [for (final m in p.milestones) {'domain': m.domain.label, 'text': m.text}],
          'sections': [for (final s in p.sections) {'heading': s.heading, 'paragraphs': s.paragraphs}],
          'source': p.source,
          'checkpoint': p.checkpoint,
          'screeningNote': p.screeningNote,
          'indianNote': p.indianNote,
          'videoId': p.videoId,
        },
    ];
    out['phaseDocs'] = [
      for (final d in kPpPhaseDocList)
        {
          'phase': d.phase,
          'code': d.code,
          'name': d.name,
          'hero': d.hero,
          'living': [for (final c in d.living) {'title': c.title, 'body': c.body, 'tips': c.tips}],
          'snapshot': [
            for (final s in d.snapshot) {'domain': s.domain.label, 'title': s.title, 'line': s.line},
          ],
          'doctor': d.doctor,
          'milestones': [
            for (final m in d.milestones)
              {
                'domain': m.domain.label,
                'title': m.title,
                'typicalAge': m.typicalAge,
                'summary': m.summary,
                'whatIsIt': m.whatIsIt,
                'whyItMatters': m.whyItMatters,
                'insight': m.insight,
                'ways': m.ways,
                'activities': m.activities,
                'relatedTopics': m.relatedTopics,
                'doctor': m.doctor,
              },
          ],
          'activities': [
            for (final a in d.activities)
              {
                'title': a.title,
                'domain': a.domain.label,
                'intro': a.intro,
                'builds': a.builds,
                'why': a.why,
                'need': a.need,
                'steps': a.steps,
                'remember': a.remember,
                'safe': a.safe,
                'variations': a.variations,
                'linked': a.linked,
              },
          ],
        },
    ];

    // ---- tips ------------------------------------------------------------------
    out['ageTips'] = [
      for (final t in kAgeTips)
        {
          'key': t.key,
          'fromWeek': t.fromWeek,
          'toWeek': t.toWeek,
          'title': t.tip.title,
          'body': t.tip.body,
          'why': t.tip.why,
          'source': t.tip.source,
          'link': kPpTipLinks[t.key],
        },
    ];
    out['dailyTips'] = [
      for (final t in kDailyTips) {'title': t.title, 'body': t.body, 'why': t.why, 'source': t.source},
    ];

    out['monthNotes'] = [
      for (final n in kPpMonthNotes)
        {
          'from': n.fromMonth,
          'label': n.label,
          'whatsNew': n.whatsNew,
          'usually': n.usually,
          'tryThis': n.tryThis,
          'callIf': n.callIf,
        },
    ];

    // ---- milestones ------------------------------------------------------------
    out['milestones'] = [
      for (final m in kMilestones)
        {
          'id': m.id,
          'domain': kDomainMeta[m.domain]!.label,
          'title': m.title,
          'lo': m.loMonths,
          'hi': m.hiMonths,
          'desc': m.desc,
          'why': m.why,
          'encourage': m.encourage,
          'variation': m.variation,
          'discuss': m.discuss,
        },
    ];

    // ---- vaccines --------------------------------------------------------------
    out['vaccines'] = [
      for (final v in kVaccines)
        {
          'id': v.id,
          'name': v.name,
          'short': v.shortName,
          'protects': v.protects,
          'diseases': v.diseases,
          'why': v.why,
          'reactions': v.reactions,
          'myths': [for (final m in v.myths) {'myth': m.$1, 'fact': m.$2}],
          'faqs': [for (final f in v.faqs) {'q': f.$1, 'a': f.$2}],
          'comfort': v.comfort,
          'redFlags': v.redFlags,
          'products': [for (final p in v.products) {'title': p.$1, 'why': p.$2, 'price': p.$3, 'id': p.$4}],
        },
    ];
    out['vaxVisits'] = [
      for (final v in kVaxVisits)
        {
          'id': v.id,
          'ageLabel': v.ageLabel,
          'ageDays': v.ageDays,
          'vaccineIds': v.vaccineIds,
          'govtFree': v.govtFree,
          'insight': v.insight,
          'lead': v.leadVaccineId,
        },
    ];
    out['vaxPrivateOnly'] = kVaxPrivateOnly.toList();

    // ---- "Is my baby OK?" ------------------------------------------------------
    out['concerns'] = [
      for (final c in kWcConcerns)
        {
          'id': c.id,
          'category': c.category,
          'label': c.label,
          'quote': c.quote,
          'common': c.common,
          'keywords': c.keywords,
          'questions': [
            for (final q in c.questions) {'category': q.category, 'prompt': q.prompt, 'options': q.options},
          ],
          'result': {
            'cause': c.result.cause,
            'explanation': c.result.explanation,
            'todos': c.result.todos,
            'tone': c.result.tone.name,
          },
        },
    ];

    // ---- Maa Can I + baby food: only the public bits (the lists are private) ----
    out['maaCanI'] = {
      'categories': kPpMaaCanICategories,
      'sources': kPpMaaCanISources,
      'count': ppMaaCanICount,
    };
    out['babyFood'] = {
      'maaDefault': kPpMaaFoodDefault,
      'count': ppBabyFoodCount,
      'bands': [for (final b in kPpChildFoodBands) {'label': b.$1, 'from': b.$2, 'to': b.$3}],
      'entries': [for (final e in ppBabyFoodEntries()) {'name': e.$1, 'aliases': e.$2}],
    };

    // ---- recipes ---------------------------------------------------------------
    out['recipes'] = [
      for (final r in kFoodRecipes)
        {
          'id': r.id,
          'docId': r.docId,
          'docFormat': r.docFormat,
          'title': r.title,
          'subtitle': r.subtitle,
          'category': r.category,
          'alsoIn': r.alsoIn.toList(),
          'slot': r.slot,
          'ageTag': r.ageTag,
          'veg': r.veg,
          'vegan': r.vegan,
          'egg': r.egg,
          'serves': r.serves,
          'mealRole': r.mealRole,
          'texture': r.texture,
          'prepMin': r.prepMin,
          'cookMin': r.cookMin,
          'difficulty': r.difficulty,
          'highlight': r.highlight,
          'why': r.why,
          'nutrients': [for (final n in r.nutrients) {'name': n.name, 'amount': n.amount, 'note': n.note}],
          'frequency': r.frequency,
          'ingredients': r.ingredients,
          'amounts': r.amounts,
          'equipment': r.equipment,
          'steps': r.steps,
          'storage': r.storage,
          'mistakes': r.mistakes,
          'substitutions': r.substitutions,
          'healthierNote': r.healthierNote,
          'situations': r.situations.toList(),
          'comfortOnly': r.comfortOnly,
          'photo': r.photo,
        },
    ];
    out['nutritionFocuses'] = [
      for (final f in kNutritionFocuses)
        {
          'id': f.id,
          'nutrient': f.nutrient,
          'oneLine': f.oneLine,
          'why': f.why,
          'sources': f.sources,
          'easyFoods': f.easyFoods,
          'deficiency': f.deficiency,
          'recipeIds': f.recipeIds,
        },
    ];
    out['recipeMoved'] = kFoodRecipeMoved;

    // ---- first 40 days, father -------------------------------------------------
    out['din'] = {
      'lines': kPpDinLines,
      'ranges': [for (final r in kPpDinRanges) {'from': r.$1, 'to': r.$2, 'page': r.$3}],
      'afterPage': kPpDinAfterPageId,
    };
    out['father'] = {'jobs': kPpFatherJobs, 'monthJobs': kPpFatherMonthJobs};

    // ---- recommendations -------------------------------------------------------
    out['reco'] = {
      'items': [
        for (final r in kReco)
          {
            'id': r.id,
            'category': r.category,
            'title': r.title,
            'summary': r.summary,
            'ageMin': r.ageMin,
            'ageMax': r.ageMax,
            'why': r.why,
            'consider': r.consider,
            'bestFor': r.bestFor,
            'skills': r.skills,
            'benefits': r.benefits,
            'indian': r.indian,
            'price': r.price,
            'collections': r.collections,
            'subtype': r.subtype,
          },
      ],
      'collections': [
        for (final c in kRecoCollections) {'id': c.id, 'title': c.title, 'subtitle': c.subtitle},
      ],
    };

    // ---- nuskhe (home remedies) ------------------------------------------------
    out['remedies'] = {
      'categories': [for (final c in kNuskheCategories) c.name],
      'defaultPanel': {'lead': kDefaultPanel.lead, 'note': kDefaultPanel.note},
      'items': [
        for (final r in kRemedies)
          {
            'id': r.id,
            'name': r.name,
            'category': r.category,
            'oneLine': r.oneLine,
            'description': r.description,
            'age': r.age,
            'ageWarning': r.ageWarning,
            'frequency': r.frequency,
            'prepTime': r.prepTime,
            'ingredients': r.ingredients,
            'steps': r.steps,
            'whenToUse': r.whenToUse,
            'redFlags': r.redFlags,
            'verdict': nuskheVerdictLabel(r.verdict),
            'pill': r.pillLabel,
            'reviewerLead': r.reviewer.lead,
            'reviewerNote': r.reviewer.note,
            'related': [for (final l in r.related) '${l.tag}: ${l.title}'],
            'sponsor': r.sponsor == null ? null : '${r.sponsor!.title} - ${r.sponsor!.subtitle}',
            'hasVideo': r.hasVideo,
            'videoNote': r.videoNote,
            'popular': r.popular,
          },
      ],
    };

    // ---- journeys --------------------------------------------------------------
    out['journeys'] = [
      for (final j in kParentingJourneys.values)
        {
          'door': j.doorId,
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
                      'surface': e.surfaceId,
                      'action': e.action,
                      'meta': e.meta?.en,
                      'owed': e.owed,
                    },
                ],
              },
          ],
          'reads': [
            for (final r in j.reads)
              {'title': r.title.en, 'value': r.value.en, 'minutes': r.minutes?.en, 'surface': r.surfaceId},
          ],
        },
    ];

    // ---- also reachable, found while walking the code --------------------------
    out['devActivities'] = [
      for (final a in kDevActivities)
        {
          'id': a.id,
          'title': a.title,
          'areaId': a.areaId,
          'minutes': a.minutes,
          'difficulty': a.difficulty,
          'ageTag': a.ageTag,
          'materials': a.materials,
          'skills': a.skills,
          'safety': a.safety,
          'benefit': a.benefit,
          'steps': a.steps,
          'intro': a.intro,
        },
    ];
    out['devAreas'] = [
      for (final a in kDevAreas)
        {'id': a.id, 'name': a.name, 'summary': a.summary, 'todayTip': a.todayTip, 'brainNote': a.brainNote},
    ];
    out['checkIns'] = {
      'lostSkill': {'area': kCheckInLostSkill.areaId, 'text': kCheckInLostSkill.text},
      'bands': {
        '0-6 months': kCheckIns0to6,
        '6-12 months': kCheckIns6to12,
        '1-2 years': kCheckIns1to2,
        '2-3 years': kCheckIns2to3,
        '3 years and over': kCheckIns3plus,
      }.map((k, v) => MapEntry(k, [
            for (final q in v)
              {
                'area': q.areaId,
                'text': q.text,
                'redFlag': q.redFlag,
                'yesIsConcern': q.yesIsConcern,
                'askFrom': q.askFrom,
                'flagFrom': q.flagFrom,
              },
          ])),
    };
    out['faqs'] = [
      for (final f in kPpFaqs)
        {
          'question': f.question,
          'general': f.general,
          'under6m': f.under6m,
          'm6to12': f.m6to12,
          'm12to36': f.m12to36,
          'over36m': f.over36m,
        },
    ];
    out['phaseFaqs'] = {
      for (var n = 1; n <= 20; n++)
        '$n': [for (final f in phaseFaqs(n, count: 99)) {'q': f.question, 'a': f.answer}],
    };
    out['brain'] = {
      'thisWeek': kBrainThisWeek,
      'topics': [for (final t in kBrainTopics) {'title': t.title, 'body': t.body, 'tip': t.tip}],
      'lookAhead': [for (final l in kLookAhead) {'title': l.title, 'body': l.body}],
      'lookAheadPicks': [for (final x in kLookAheadPicks) {'kind': x.$1, 'text': x.$2}],
    };

    final f = File('build/review_parenting_extras.json');
    f.parent.createSync(recursive: true);
    f.writeAsStringSync(const JsonEncoder.withIndent(' ').convert(out));
    // ignore: avoid_print
    print('\nEXPORTED ${out.keys.length} groups -> build/review_parenting_extras.json');
    expect(out['sections'], isNotEmpty);
  });
}
