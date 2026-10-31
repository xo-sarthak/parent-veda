// =============================================================================
//  EXPORT TOOL (not a test) - the extra Trying-to-conceive copy for the review
//  pack, the parts the TTC corpus does not carry.
// -----------------------------------------------------------------------------
//  Run:  flutter test tool/review/export_review_ttc.dart
//  Out:  build/review_ttc_extras.json  -> the review-pack builder (Python)
//
//  Companion to tool/export_ttc_corpus.dart. The corpus holds the reads,
//  look-ups and cards; this holds what varies by situation and the facts that
//  say who sees what: treatment-round copy, hero lines, practices, rituals,
//  chapter action plans, door shelves, films, and the tags (phases, steps,
//  brackets) behind each read and card. English only: no Hindi field is read.
// =============================================================================

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/models/pv_read.dart';
import 'package:parentveda/screens/ttc/ttc_home_gap.dart';
import 'package:parentveda/screens/ttc/ttc_round_strings.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/services/bracket_resolver.dart';
import 'package:parentveda/ttc/reads/ttc_reads_after_loss.dart';
import 'package:parentveda/ttc/reads/ttc_reads_age.dart';
import 'package:parentveda/ttc/reads/ttc_reads_body_conditions.dart';
import 'package:parentveda/ttc/reads/ttc_reads_body_cycle.dart';
import 'package:parentveda/ttc/reads/ttc_reads_body_intimate.dart';
import 'package:parentveda/ttc/reads/ttc_reads_conceiving.dart';
import 'package:parentveda/ttc/reads/ttc_reads_extra.dart';
import 'package:parentveda/ttc/reads/ttc_reads_getting_ready.dart';
import 'package:parentveda/ttc/reads/ttc_reads_hard_days.dart';
import 'package:parentveda/ttc/reads/ttc_reads_his_side.dart';
import 'package:parentveda/ttc/reads/ttc_reads_ivf.dart';
import 'package:parentveda/ttc/reads/ttc_reads_loss_more.dart';
import 'package:parentveda/ttc/reads/ttc_reads_meal_plan.dart';
import 'package:parentveda/ttc/reads/ttc_reads_mind_body.dart';
import 'package:parentveda/ttc/reads/ttc_reads_pcos.dart';
import 'package:parentveda/ttc/reads/ttc_reads_safety.dart';
import 'package:parentveda/ttc/reads/ttc_reads_sex.dart';
import 'package:parentveda/ttc/reads/ttc_reads_treatment.dart';
import 'package:parentveda/ttc/reads/ttc_reads_waiting.dart';
import 'package:parentveda/ttc/ttc_age_rank.dart';
import 'package:parentveda/ttc/ttc_can_i_data.dart';
import 'package:parentveda/ttc/ttc_chapter_data.dart';
import 'package:parentveda/ttc/ttc_content_prefs.dart';
import 'package:parentveda/ttc/ttc_daily_data.dart';
import 'package:parentveda/ttc/ttc_expert_signoff.dart';
import 'package:parentveda/ttc/ttc_focus_data.dart';
import 'package:parentveda/ttc/ttc_home_hero.dart';
import 'package:parentveda/ttc/ttc_messages_store.dart';
import 'package:parentveda/ttc/ttc_partner_data.dart';
import 'package:parentveda/ttc/ttc_phase_reads.dart';
import 'package:parentveda/ttc/ttc_practice_data.dart';
import 'package:parentveda/ttc/ttc_prepare_data.dart';
import 'package:parentveda/ttc/ttc_reads_data.dart';
import 'package:parentveda/ttc/ttc_treatment_content.dart';
import 'package:parentveda/ttc/ttc_treatment_round.dart';
import 'package:parentveda/ttc/ttc_treatment_store.dart';
import 'package:parentveda/ttc/ttc_videos_data.dart';
import 'package:parentveda/ttc/ttc_chapter.dart';

void main() {
  test('export the review-pack extras to build/review_ttc_extras.json', () {
    final out = <String, dynamic>{};

    // ---- reads: bracket file, byline as written, shape ---------------------
    final brackets = <String, List<PvRead>>{
      'conceiving': kTtcReadsConceiving,
      'pcos': kTtcReadsPcos,
      'ivf': kTtcReadsIvf,
      'getting_ready': kTtcReadsGettingReady,
      'his_side': kTtcReadsHisSide,
      'after_loss': kTtcReadsAfterLoss,
      'mind_body': kTtcReadsMindBody,
      'waiting': kTtcReadsWaiting,
      'hard_days': kTtcReadsHardDays,
      'meal_plan': kTtcReadsMealPlan,
      'body_intimate': kTtcReadsBodyIntimate,
      'sex': kTtcReadsSex,
      'loss_more': kTtcReadsLossMore,
      'body_cycle': kTtcReadsBodyCycle,
      'body_conditions': kTtcReadsBodyConditions,
      'extra': kTtcReadsExtra,
      'age': kTtcReadsAge,
      'safety': kTtcReadsSafety,
      'treatment': kTtcReadsTreatment,
    };
    final readMeta = <String, Map<String, dynamic>>{};
    brackets.forEach((b, list) {
      for (final r in list) {
        readMeta[r.id] = {
          'id': r.id,
          'bracket': b,
          'title': r.title.en,
          'kicker': r.kicker.en,
          'author': r.author.en,
          'authorRole': r.authorRole.en,
          'reviewed': r.reviewed,
          'faqs': r.faqs.length,
          'customBlocks': [
            for (final s in r.sections)
              if (s.custom != null) s.heading?.en ?? '',
          ],
          'videoSlot': r.heroVideoSlot,
          'readNext': r.readNext,
        };
      }
    });
    out['reads'] = readMeta.values.toList();
    out['readsInShippedList'] = [for (final r in kTtcReads) r.id];
    out['signedOffReads'] = {
      for (final e in kTtcSignedOffReads.entries) e.key: e.value.toList(),
    };
    out['signedOffStories'] = {
      for (final e in kTtcSignedOffStories.entries) e.key: e.value.toList(),
    };

    // ---- where a read is shown ---------------------------------------------
    out['phaseReads'] = {
      for (final e in kTtcPhaseReadIds.entries) e.key.name: e.value,
    };
    out['treatmentReads'] = {
      for (final e in kTtcTreatmentPhaseReadIds.entries) e.key.name: e.value,
    };
    out['ageReads35'] = kTtcAgeReads35.toList();
    out['ageReads40'] = kTtcAgeReads40.toList();
    out['ageCards35'] = kTtcAgeCards35.toList();
    out['ageCards40'] = kTtcAgeCards40.toList();
    out['ageSections'] = kTtcAgeSections.toList();
    out['intimateReads'] = kTtcIntimateReadIds.toList();
    out['intimateInsights'] = kTtcIntimateInsightIds.toList();

    // ---- daily cards: which stretch each one fits ---------------------------
    Map<String, dynamic> card(TtcInsight i, String set) => {
          'id': i.id,
          'set': set,
          'topic': i.topic,
          'phases': (i.phases.map((p) => p.name).toList()..sort()),
          'forPartner': i.forPartner,
        };
    out['insights'] = [
      for (final i in ttcInsights) card(i, 'general'),
      for (final i in ttcPhaseInsights) card(i, 'phase'),
      for (final e in kTtcTreatmentInsights.entries)
        for (final i in e.value) card(i, 'treatment:${e.key.name}'),
    ];
    out['mythWhy'] = {
      for (final m in ttcMyths) m.id: m.whyEn,
    };

    // ---- practices, rituals, chapter extras --------------------------------
    out['practiceSafety'] = kTtcPracticeSafety;
    out['practices'] = [
      for (final p in kTtcPractices)
        {
          'id': p.id,
          'kind': p.kind.name,
          'title': p.title,
          'duration': p.duration,
          'setting': p.setting,
          'blurb': p.blurb,
          'steps': p.steps,
          'skipIf': p.skipIf,
          'phases': (p.phases.map((x) => x.name).toList()..sort()),
          'twoMarkers':
              p.anim is TtcBreathAnim && (p.anim as TtcBreathAnim).twoMarkers,
        },
    ];
    out['rituals'] = {
      for (final e in ttcRituals.entries)
        e.key.name: [
          for (final r in e.value)
            {
              'part': r.part.name,
              'partTitle': r.part.title(false),
              'partWhy': r.part.why(false),
              'text': r.textEn,
              'shared': kTtcSharedRitualParts.contains(r.part),
            },
        ],
    };
    out['chapters'] = {
      for (final e in ttcChapterContent.entries)
        e.key.name: {
          'title': e.key.title(false),
          'actions': [
            for (final a in e.value.actions)
              {'text': a.textEn, 'forPartner': a.forPartner},
          ],
          'askVeda': e.value.askVedaEn,
        },
    };
    out['partnerBriefs'] = {
      for (final e in ttcPartnerBriefs.entries)
        e.key.name: {'herBody': e.value.herBody(false)},
    };
    out['missions'] = {
      for (final m in ttcMissions) m.id: m.forHimself,
    };

    // ---- the doors ----------------------------------------------------------
    String opens(TtcTile t) => switch (t) {
          TtcToolTile(:final surfaceId) => 'tool:$surfaceId',
          TtcArticleTile(:final readId, :final moreReadId) => readId != null
              ? 'read:$readId'
              : (moreReadId != null ? 'inline:$moreReadId' : 'inline:'),
          TtcGuideTile(:final readId) => 'read:$readId',
          TtcVideoTile(:final slotId) => 'video:$slotId',
          TtcProductTile(:final productId, :final category) =>
            'product:${productId ?? category ?? ''}',
          TtcChecklistTile(:final surfaceId) => 'tool:$surfaceId',
          TtcTalkTile(:final action) => 'talk:$action',
          TtcRecipeTile(:final recipeId) => 'recipe:$recipeId',
          TtcCommunityTile(:final surfaceId) => 'community:$surfaceId',
          TtcDoTile(:final surfaceId) => 'practice:$surfaceId',
          TtcDoorTile(:final bracketId) => 'door:$bracketId',
          TtcMasterclassTile(:final offeringId) => 'class:$offeringId',
          TtcBookingTile(:final action) => 'booking:$action',
          TtcMythTile() => 'inline:myth',
          TtcCarouselTile() => 'inline:carousel',
          TtcInfographicTile() => 'inline:infographic',
        };
    Map<String, dynamic> tile(TtcTile t) => {
          'title': t.title,
          'blurb': t.blurb,
          'meta': t.meta,
          'format': t.format.label,
          'opens': opens(t),
          'slug': ttcTileSlug(t),
          'id': ttcTileKey(t),
          'reviewedBy': switch (t) {
            TtcCarouselTile(:final reviewedBy) => reviewedBy,
            TtcInfographicTile(:final reviewedBy) => reviewedBy,
            _ => null,
          },
        };
    out['doors'] = [
      for (final page in kTtcFocusPages)
        {
          'bracketId': page.bracketId,
          'label': bracketById(page.bracketId)?.label.en ?? page.bracketId,
          'intro': page.intro,
          'heroTitle': page.heroTitle,
          'heroBlurb': page.heroBlurb,
          'closingLine': page.closingLine,
          'heroVideoSlot': page.heroVideoSlot,
          'heroVideoTitle': page.heroVideoTitle,
          'headline': page.headline == null ? null : tile(page.headline!),
          'groups': [
            for (final g in page.groups ?? const <TtcFocusGroup>[])
              {
                'id': g.id,
                'label': g.label,
                'note': g.note,
                'phases': (g.phases.map((p) => p.name).toList()..sort()),
                'steps': (g.steps.map((p) => p.name).toList()..sort()),
              },
          ],
          'sections': [
            for (final s in page.sections)
              {
                'heading': s.heading,
                'group': s.group,
                'phases': (s.phases.map((p) => p.name).toList()..sort()),
                'steps': (s.steps.map((p) => p.name).toList()..sort()),
                'tiles': [for (final t in s.tiles) tile(t)],
              },
          ],
        },
    ];

    // ---- films (none has a file yet) ---------------------------------------
    out['videos'] = [
      for (final v in kTtcVideos)
        {
          'id': v.id,
          'title': v.title.en,
          'why': v.why.en,
          'seconds': v.seconds,
          'expert': v.expert.en,
          'expertRole': v.expertRole.en,
          'chapters': [
            for (final c in v.chapters) {'at': c.at, 'label': c.label.en},
          ],
          'takeaways': [for (final t in v.takeaways) t.en],
          'hasFile': v.url != null,
          'readNext': v.readNext,
          'surfaceNext': v.surfaceNext,
        },
    ];

    // ---- the home headline for her own cycle --------------------------------
    final t = TtcS(false);
    out['hero'] = {
      'startHere': [t.headerStartHere, t.headerStartHereBody],
      'clinicHolds': [
        t.leadYouAreOn,
        t.headerCycleDayBig(23),
        t.headerClinicDatesPassed,
      ],
      'noEstimate': [t.headerNoEstimate, t.headerNoEstimateBody],
      'noEstimateWhy': [
        for (final w in [
          TtcNoEstimate.notEnoughHistory,
          TtcNoEstimate.historyLooksOff,
          TtcNoEstimate.cycleOverdue,
        ])
          t.headerNoEstimateWhy(w),
      ],
      'onPeriod': [
        t.leadYourPeriod,
        t.bigPeriodDay(2),
        t.headerOnPeriodBody(from: '[date]'),
        t.headerOnPeriodBody(from: '[date]', overlaps: true),
        t.headerOnPeriodBody(),
      ],
      'windowOpensIn': [
        t.leadFertileDays + t.headerOpenVerb,
        t.bigInDays(3),
      ],
      'windowOpen': [
        t.leadFertileDays + t.headerAreVerb,
        t.bigTodayAndMore(3),
      ],
      'windowLastDay': [
        t.leadFertileDays,
        t.bigEndToday,
        t.headerWindowLastDayBody,
      ],
      'waiting': [t.leadPeriodMayStart, t.bigInDays(6), t.headerWaitingBody],
      'periodDue': [t.leadPeriodMayStart, t.bigToday, t.headerPeriodDueBody],
      'periodLate': [t.leadPastUsual, t.bigDays(3), t.headerPeriodLateBody],
      'timeToTest': [kTtcTimeToTest, ttcTimeToTestBody(3)],
      'periodExpectedBy': [
        t.headerPeriodExpectedBy,
        t.headerPeriodExpectedByBody,
      ],
      'pastCycle': [
        t.leadEarlierCycle,
        t.headerPastCycleDay(9),
        t.headerPastCycleWindow('[date]', '[date]'),
        t.headerPastCycleNoWindow('[date]'),
        t.headerPastCycle,
        t.headerBeforeFirstPeriodBody,
      ],
      'stepToday': [t.headerStepTodayBody],
      'stepSoon': [t.headerStepInBody],
      'betaOn': [t.leadBetaOn, t.headerBetaOnBody],
      'longGap': [t.leadItsBeen, kTtcLongGapBody],
    };

    // ---- treatment round copy ----------------------------------------------
    final kinds = TtcRoundKind.values;
    out['roundKinds'] = [
      for (final k in kinds)
        {
          'kind': k.name,
          'name': ttcRoundKindName(k),
          'note': ttcRoundKindNote(k),
          'short': ttcRoundKindShort(k),
          'scanLabel': ttcScanLabel(k),
          'rows': [
            for (final r in ttcRoundRows(k))
              r.scans
                  ? {
                      'step': 'scans',
                      'label': ttcScansRowLabel(k),
                      'line': ttcRowLine(r, k),
                    }
                  : {
                      'step': r.step!.name,
                      'label': ttcStepLabel(r.step!, k),
                      'line': ttcRowLine(r, k),
                    },
          ],
        },
    ];
    out['roundSteps'] = [
      for (final s in TtcTreatmentStep.values)
        {
          'step': s.name,
          'label': s.label(false),
          'note': s.note(false),
        },
    ];
    out['roundPhaseNames'] = {
      for (final p in TtcRoundPhase.values)
        p.name: {
          for (final k in [
            TtcRoundKind.ivfFresh,
            TtcRoundKind.iui,
            TtcRoundKind.ovulationInduction,
            TtcRoundKind.fetNatural,
          ])
            k.name: ttcRoundPhaseName(p, k),
        },
    };

    // The home headline for each stretch of a round, as three lines.
    final day = DateTime(2026, 11, 10);
    final next = DateTime(2026, 11, 12);
    List<String> hero(TtcHeroLine l) {
      final (a, b, c) = ttcRoundHeroCopy(l, day);
      return [a, b, c];
    }

    TtcHeroLine hl(TtcHeroState s, TtcRoundKind k,
            {int days = 0,
            TtcTreatmentStep? countStep,
            TtcTreatmentStep? step,
            DateTime? date,
            TtcTreatmentStep? nextStep,
            DateTime? nextOn}) =>
        TtcHeroLine(s,
            kind: k,
            days: days,
            countStep: countStep,
            step: step,
            date: date,
            nextStep: nextStep,
            nextOn: nextOn);
    final heroes = <Map<String, dynamic>>[];
    void add(String phase, String variant, String kind, TtcHeroLine l) =>
        heroes.add({
          'phase': phase,
          'variant': variant,
          'kind': kind,
          'lines': hero(l),
        });
    for (final k in [
      TtcRoundKind.ivfFresh,
      TtcRoundKind.ivfFreezeAll,
      TtcRoundKind.iui,
      TtcRoundKind.ovulationInduction,
      TtcRoundKind.fetMedicated,
      TtcRoundKind.fetNatural,
    ]) {
      add('gettingReady', 'estrogen day', k.name,
          hl(TtcHeroState.treatmentGettingReady, k,
              days: 3, countStep: TtcTreatmentStep.estrogenStart));
      add('gettingReady', 'down-regulation day', k.name,
          hl(TtcHeroState.treatmentGettingReady, k,
              days: 3, countStep: TtcTreatmentStep.downRegStart));
      add('gettingReady', 'otherwise', k.name,
          hl(TtcHeroState.treatmentGettingReady, k));
      add('stimulation', 'on medicines, next scan dated', k.name,
          hl(TtcHeroState.treatmentStimulation, k,
              days: 4,
              countStep: TtcTreatmentStep.stimStart,
              nextOn: next));
      add('stimulation', 'scans only', k.name,
          hl(TtcHeroState.treatmentStimulation, k));
      add('trigger', 'trigger day', k.name,
          hl(TtcHeroState.treatmentTrigger, k,
              days: 0,
              step: TtcTreatmentStep.trigger,
              date: DateTime(2026, 11, 10, 22, 15)));
      add('trigger', 'day after, collection dated', k.name,
          hl(TtcHeroState.treatmentTrigger, k,
              days: 1,
              nextStep: TtcTreatmentStep.retrieval,
              nextOn: next));
      add('trigger', 'day after, IUI dated', k.name,
          hl(TtcHeroState.treatmentTrigger, k,
              days: 1, nextStep: TtcTreatmentStep.iui, nextOn: next));
      add('trigger', 'day after, nothing dated', k.name,
          hl(TtcHeroState.treatmentTrigger, k, days: 1));
      add('procedure', 'egg collection', k.name,
          hl(TtcHeroState.treatmentProcedure, k,
              step: TtcTreatmentStep.retrieval));
      add('procedure', 'IUI', k.name,
          hl(TtcHeroState.treatmentProcedure, k, step: TtcTreatmentStep.iui));
      add('embryoDays', 'embryo day, transfer dated', k.name,
          hl(TtcHeroState.treatmentEmbryoDays, k,
              days: 2,
              nextStep: TtcTreatmentStep.transfer,
              nextOn: next));
      add('embryoDays', 'embryo days', k.name,
          hl(TtcHeroState.treatmentEmbryoDays, k));
      add('transfer', 'transfer day', k.name,
          hl(TtcHeroState.treatmentTransfer, k));
      add('waiting', 'test dated, counting from transfer', k.name,
          hl(TtcHeroState.treatmentWait, k,
              days: 4,
              countStep: TtcTreatmentStep.transfer,
              date: DateTime(2026, 11, 20)));
      add('waiting', 'counting from IUI', k.name,
          hl(TtcHeroState.treatmentWait, k,
              days: 4,
              countStep: TtcTreatmentStep.iui,
              date: DateTime(2026, 11, 20)));
      add('waiting', 'counting from trigger', k.name,
          hl(TtcHeroState.treatmentWait, k,
              days: 4,
              countStep: TtcTreatmentStep.trigger,
              date: DateTime(2026, 11, 20)));
      add('waiting', 'test not dated', k.name,
          hl(TtcHeroState.treatmentWait, k));
      add('testDay', 'on the test day', k.name,
          hl(TtcHeroState.treatmentTestDay, k,
              days: 0, step: TtcTreatmentStep.betaTest));
      add('testDay', 'waiting to hear', k.name,
          hl(TtcHeroState.treatmentTestDay, k,
              days: 1, step: TtcTreatmentStep.betaTest));
      add('result', 'positive', k.name, hl(TtcHeroState.treatmentResult, k));
      add('betweenRounds', 'review dated', k.name,
          hl(TtcHeroState.treatmentBetweenRounds, k, date: next));
      add('betweenRounds', 'no review dated', k.name,
          hl(TtcHeroState.treatmentBetweenRounds, k));
    }
    out['roundHero'] = heroes;

    out['roundScreens'] = {
      'startFlow': [
        kTtcStartKindTitle,
        kTtcStartKindBody,
        kTtcStartKindClearHint,
        kTtcStartKindNeeded,
        kTtcStartDateTitle,
        kTtcStartDateBody,
        kTtcStartLater,
        kTtcStartDateNeeded,
        kTtcStartBackToKind,
        kTtcStartReviewTitle,
        kTtcStartClinicLabel,
        kTtcStartPartnerLine,
        kTtcStartKeepsLegacy,
        kTtcStartClosesCurrent,
        ttcStartWhatChanges(null, day),
        ttcStartWhatChanges(DateTime(2026, 11, 20), day),
        ttcStartWhatChanges(DateTime(2026, 11, 8), day),
        ttcStartWhatChanges(day, day),
        kTtcStartUndoLine,
        kTtcStartOkay,
        kTtcStartOkayNoDate,
        kTtcStartChangeDate,
        kTtcStartAddDate,
      ],
      'roundScreen': [
        kTtcRoundPlanTitle,
        kTtcRoundPlanBody,
        kTtcRoundAddScan,
        kTtcRoundEmbryoQ,
        kTtcRoundStartCardTitle,
        kTtcRoundStartCardBody,
        kTtcRoundStartCta,
        kTtcRoundLegacyTitle,
        kTtcRoundLegacyBody,
        kTtcRoundPastTitle,
        kTtcRoundHistoryNote,
        kTtcRoundUndoCta,
        kTtcRoundPlanChanged,
        kTtcRoundTakeBreak,
        kTtcRoundTellResult,
        kTtcRoundRemove,
        kTtcRoundRemoveBody,
        kTtcRoundMedicationLink,
        kTtcRoundClearedToast,
        kTtcRoundReopenedToast,
        kTtcUndoCardLine,
        kTtcRoundClinicWillTell,
        'Labels on a past round: '
            '${[
          for (final o in TtcRoundOutcome.values) ttcRoundOutcomeLabel(o)
        ].join(', ')}, and ${ttcRoundOutcomeLabel(null)} for a round that has not ended.',
      ],
      'dateChecks': [
        kTtcDateCheckTitle,
        kTtcDateUseIt,
        kTtcDatePickAgain,
        for (final k in TtcDateProblemKind.values)
          ttcDateProblemText(
              TtcDateProblem(
                  k,
                  k == TtcDateProblemKind.beforeEarlierStep ||
                          k == TtcDateProblemKind.afterLaterStep
                      ? TtcTreatmentStep.trigger
                      : null),
              TtcRoundKind.ivfFresh),
      ],
      'checkIn': [
        kTtcCheckInTitle,
        kTtcCheckInBody,
        kTtcCheckInReturnBody,
        '$kTtcCheckInStill: $kTtcCheckInStillLine',
        '$kTtcCheckInPaused: $kTtcCheckInPausedLine',
        '$kTtcCheckInOver: $kTtcCheckInOverLine',
        kTtcCheckInAddDate,
        kTtcCheckInLater,
        kTtcCheckInCardTitle,
        kTtcCheckInCardCta,
      ],
      'closing': [
        kTtcConfirmKeep,
        for (final o in TtcRoundOutcome.values) ...[
          () {
            final (a, b, c) = ttcConfirmClose(o);
            return '$a $b [Button: $c]';
          }(),
          ttcClosedLine(o),
        ],
      ],
      'result': [
        kTtcResultTitle,
        kTtcResultBody,
        '$kTtcResultPositive: $kTtcResultPositiveLine',
        '$kTtcResultNegative: $kTtcResultNegativeLine',
        '$kTtcResultRepeat: $kTtcResultRepeatLine',
        kTtcResultLater,
        kTtcResultPositiveNext,
        kTtcResultCardTitle,
      ],
      'planChanged': [
        kTtcPlanTitle,
        kTtcPlanBody,
        '$kTtcPlanStopped: $kTtcPlanStoppedLine',
        '$kTtcPlanIui: $kTtcPlanIuiLine',
        '$kTtcPlanFreeze: $kTtcPlanFreezeLine',
      ],
      'homeCard': [
        kTtcActiveTitle,
        kTtcActiveBody,
        kTtcActiveWhatChanged,
        ...kTtcActiveChanges,
        kTtcActiveGotIt,
        kTtcReturnTitle,
        kTtcReturnBody,
        kTtcInviteTitle,
        kTtcInviteBody,
        kTtcBetweenTitle,
        kTtcClosedOwnCycleBack,
        kTtcSeeRound,
      ],
      'redFlag': [kTtcOhssLine],
      'calendar': [
        kTtcCalendarClinicDate,
        kTtcCalendarPastRound,
        kTtcCalendarRoundNote,
        kTtcCalendarRoundPlannedNote,
        kTtcCalendarSeeRound,
        kTtcCalendarSeeRoundLine,
      ],
      'doorPanel': [
        kTtcPanelRoundEyebrow,
        kTtcPanelSeePlan,
        kTtcPanelUpdateDates,
        kTtcPanelNoDatesTitle,
        kTtcPanelNoDatesLine,
        kTtcPanelNoNext,
        kTtcPanelBetweenTitle,
        kTtcPanelBetweenLine,
        kTtcPanelStartNext,
        kTtcPanelPositiveTitle,
        kTtcPanelDatePregnancy,
      ],
      'toPregnancy': [
        kTtcToPregTitle,
        kTtcToPregIntro,
        kTtcToPregEmbryoQ,
        '$kTtcToPregClinic: $kTtcToPregClinicLine',
        '$kTtcToPregNotNow: $kTtcToPregNotNowLine',
        kTtcToPregConfirmNo,
        kTtcToPregConfirmYes,
        kTtcToPregNoDate,
        kTtcToPregAddTransfer,
      ],
      'hisRound': [kTtcPartnerRoundEyebrow],
    };

    // ---- look-ups: the parts the corpus body leaves out ---------------------
    out['canI'] = [
      for (final c in ttcCanI)
        {
          'id': c.id,
          'verdict': c.verdict.name,
          'verdictLabel': c.verdict.label(false),
          'limit': c.limitEn,
          'forPartner': c.forPartner,
        },
    ];
    out['offerings'] = [
      for (final o in ttcOfferings)
        {
          'id': o.id,
          'category': o.category,
          'price': o.priceLabel,
          'kind': o.kind,
          'sessions': o.sessions,
          'forCouple': o.forCouple,
          'expertId': o.expertId,
        },
    ];
    out['offeringCategories'] = {
      for (final c in ttcPrepareCategories) c.$1: c.$2,
    };

    // ---- phone message kinds -------------------------------------------------
    out['messageKinds'] = [
      for (final k in TtcMessageKind.values)
        {'kind': k.name, 'label': k.label, 'when': k.when},
    ];

    final f = File('build/review_ttc_extras.json');
    f.parent.createSync(recursive: true);
    f.writeAsStringSync(const JsonEncoder.withIndent(' ').convert(out));
    // ignore: avoid_print
    print('\nEXPORTED review extras -> build/review_ttc_extras.json '
        '(${out.length} groups, ${readMeta.length} reads)');
    expect(out['reads'], isNotEmpty);
  });
}
