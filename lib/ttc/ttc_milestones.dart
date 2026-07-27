// =============================================================================
//  TTC milestones - effort, not outcome
// -----------------------------------------------------------------------------
//      "Started prenatal vitamins · Completed blood tests · Partner joined ·
//       Met a fertility specialist · Learned about ovulation · Completed your
//       first cycle together · Positive pregnancy test.
//       Every milestone reflects effort. Not success alone."
//                                                       - TTC master, §3.20
//
//  That last line is the whole design. Exactly ONE milestone here is an
//  outcome, and it is the last one. Every other milestone can be reached by a
//  couple who has not conceived, which is the point: a couple two years in must
//  be able to look at this list and see everything they have done, rather than
//  the one thing that has not happened.
//
//  All of them are DERIVED from what the couple has actually done - never asked
//  for, never manually ticked. Asking "have you started folic acid?" when the
//  supplements list already says so is how a companion turns back into a form.
//
//  Reaching one writes to the FamilyTimeline, so the milestones and the life
//  story cannot drift apart.
// =============================================================================

import '../services/family_timeline.dart';
import '../services/life_stage_store.dart';
import 'cycle_store.dart';
import 'ttc_journal_store.dart';
import 'ttc_log_store.dart';
import 'ttc_ritual_store.dart';
import 'ttc_store.dart';
import 'ttc_supplements_store.dart';

class TtcMilestone {
  const TtcMilestone({
    required this.id,
    required this.iconKey,
    required this.titleEn,
    required this.titleHi,
    required this.bodyEn,
    required this.bodyHi,
    required this.isOutcome,
  });

  final String id;
  final String iconKey;
  final String titleEn;
  final String titleHi;
  final String bodyEn;
  final String bodyHi;

  /// True only for the positive test. Pinned by test so this list cannot
  /// quietly fill up with outcomes.
  final bool isOutcome;

  String title(bool hi) => hi ? titleHi : titleEn;
  String body(bool hi) => hi ? bodyHi : bodyEn;
}

const List<TtcMilestone> ttcMilestones = [
  TtcMilestone(
    id: 'journey_started',
    iconKey: 'flag',
    isOutcome: false,
    titleEn: 'You decided to start',
    titleHi: 'Aapne shuru karne ka faisla kiya',
    bodyEn:
        'The day a family begins is not the day a baby arrives. It is this one.',
    bodyHi:
        'Family us din shuru nahi hoti jis din bachcha aata hai. Isi din hoti hai.',
  ),
  TtcMilestone(
    id: 'supplements_started',
    iconKey: 'pill',
    isOutcome: false,
    titleEn: 'Started your supplements',
    titleHi: 'Supplements shuru kiye',
    bodyEn:
        'Folic acid works before you know you are pregnant. Starting it while trying is the single most evidence-backed thing on this whole list.',
    bodyHi:
        'Folic acid tab kaam karta hai jab pata bhi nahi hota. Koshish ke dauraan ise shuru karna, is poori list ki sabse zyada saboot wali baat hai.',
  ),
  TtcMilestone(
    id: 'first_cycle_logged',
    iconKey: 'cycle',
    isOutcome: false,
    titleEn: 'Logged your first period',
    titleHi: 'Pehla period log kiya',
    bodyEn:
        'One date, and we can start learning your rhythm instead of an average one.',
    bodyHi:
        'Ek date, aur hum average ki jagah aapki apni rhythm seekhna shuru kar sakte hain.',
  ),
  TtcMilestone(
    id: 'first_cycle_complete',
    iconKey: 'loop',
    isOutcome: false,
    titleEn: 'Completed a full cycle together',
    titleHi: 'Ek poora cycle saath mein poora kiya',
    bodyEn:
        'A month of paying attention. Whatever it ended in, you now know something about your body that you did not know last month.',
    bodyHi:
        'Ek mahina dhyaan dene ka. Wo jaise bhi khatam hua, ab aap apne body ke baare mein kuch jaanti hain jo pichhle mahine nahi jaanti thi.',
  ),
  TtcMilestone(
    id: 'ovulation_learned',
    iconKey: 'egg',
    isOutcome: false,
    titleEn: 'Learned to read your own signals',
    titleHi: 'Apne signals padhna seekha',
    bodyEn:
        'You recorded a signal from your own body rather than relying on a calendar estimate. That is the shift this chapter is actually for.',
    bodyHi:
        'Aapne calendar ke andaaze par nirbhar rehne ke bajaye apne body ka signal record kiya. Yahi wo badlaav hai jiske liye ye chapter hai.',
  ),
  TtcMilestone(
    id: 'partner_joined',
    iconKey: 'people',
    isOutcome: false,
    titleEn: 'Your partner joined',
    titleHi: 'Aapka partner juda',
    bodyEn:
        'This stops being something one of you is doing and becomes something you are both in.',
    bodyHi:
        'Ab ye wo cheez nahi rahi jo aap mein se ek kar raha hai - ye wo cheez ban gayi jismein aap dono hain.',
  ),
  TtcMilestone(
    id: 'tests_done',
    iconKey: 'test',
    isOutcome: false,
    titleEn: 'Started keeping your health records',
    titleHi: 'Apne health records rakhna shuru kiya',
    bodyEn:
        'Numbers you can show a doctor beat a memory of how you have been feeling.',
    bodyHi:
        'Jo numbers aap doctor ko dikha sakein, wo "aisa lag raha tha" se behtar hote hain.',
  ),
  TtcMilestone(
    id: 'wrote_something',
    iconKey: 'write',
    isOutcome: false,
    titleEn: 'Wrote something down',
    titleHi: 'Kuch likha',
    bodyEn:
        'Years from now this will be the part you are glad you kept - including the hard entries.',
    bodyHi:
        'Kai saal baad yahi wo hissa hoga jise rakhne ki aapko khushi hogi - mushkil entries bhi.',
  ),
  TtcMilestone(
    id: 'ritual_week',
    iconKey: 'spa',
    isOutcome: false,
    titleEn: 'Kept the daily ritual for a week',
    titleHi: 'Ek hafte daily ritual nibhaya',
    bodyEn:
        'Five minutes a day, for seven days, in a chapter where most things are outside your control.',
    bodyHi:
        'Roz paanch minute, saat din - us chapter mein jahan zyadatar cheezein aapke haath mein nahi hain.',
  ),
  TtcMilestone(
    id: 'lifestyle_tracked',
    iconKey: 'sun',
    isOutcome: false,
    titleEn: 'Looked honestly at your habits',
    titleHi: 'Apni aadaton ko imaandaari se dekha',
    bodyEn:
        'Sleep, movement, and the things that are harder to write down. Noticing is the whole first step.',
    bodyHi:
        'Neend, movement, aur wo cheezein jo likhna mushkil hai. Notice karna hi pehla poora kadam hai.',
  ),
  TtcMilestone(
    id: 'positive_test',
    iconKey: 'star',
    isOutcome: true,
    titleEn: 'A positive test',
    titleHi: 'Positive test',
    bodyEn: 'A beautiful new chapter begins - and nothing you built here is lost.',
    bodyHi:
        'Ek khoobsurat naya chapter shuru hota hai - aur yahan jo banaya, kuch nahi khota.',
  ),
];

/// Works out which milestones a couple has actually reached, from the stores.
/// Nothing here is asked for or manually ticked.
class TtcMilestoneEngine {
  const TtcMilestoneEngine();

  bool isAchieved(String id) {
    switch (id) {
      case 'journey_started':
        return TtcStore.instance.journeyStart != null;
      case 'supplements_started':
        return TtcSupplementsStore.instance.items.isNotEmpty;
      case 'first_cycle_logged':
        return CycleStore.instance.periodStarts.isNotEmpty;
      case 'first_cycle_complete':
        return CycleStore.instance.completedCycles >= 1;
      case 'ovulation_learned':
        return CycleStore.instance.lhPositiveDay != null ||
            CycleStore.instance.temperatureShiftDay != null;
      case 'partner_joined':
        return TtcStore.instance.partnerJoined;
      case 'tests_done':
        // Any recorded body measurement counts - this is about starting to
        // keep records at all, not about completing a particular panel.
        return TtcLogStore.instance.hasAnythingFor('weight');
      case 'wrote_something':
        return TtcJournalStore.instance.count > 0;
      case 'ritual_week':
        return TtcRitualStore.instance.streak() >= 7;
      case 'lifestyle_tracked':
        return TtcLogStore.instance.hasAnythingFor('lifestyle') ||
            TtcLogStore.instance.hasAnythingFor('sleep') ||
            TtcLogStore.instance.hasAnythingFor('exercise');
      case 'positive_test':
        return TtcStore.instance.pregnancyConfirmed;
      default:
        return false;
    }
  }

  List<TtcMilestone> get achieved =>
      ttcMilestones.where((m) => isAchieved(m.id)).toList();

  /// Everything not yet reached. Shown as "still ahead", never as "missing".
  List<TtcMilestone> get ahead =>
      ttcMilestones.where((m) => !isAchieved(m.id)).toList();

  /// Writes any newly-reached milestone into the family's life story. Safe to
  /// call on every build - FamilyTimeline.add is idempotent on the id.
  void syncToTimeline() {
    for (final m in achieved) {
      FamilyTimeline.instance.add(
        id: 'ttc_ms_${m.id}',
        stage: LifeStage.tryingToConceive,
        kind: m.isOutcome ? TimelineKind.milestone : TimelineKind.action,
        titleEn: m.titleEn,
        titleHi: m.titleHi,
        detailEn: m.bodyEn,
        detailHi: m.bodyHi,
      );
    }
  }
}
