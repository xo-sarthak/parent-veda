// =============================================================================
//  Pre-Pregnancy Checklist — sections, items, and what each one is for
// -----------------------------------------------------------------------------
//  ⚠️ THIS IS A PLANNING TOOL. IT IS NOT MEDICAL CLEARANCE, AND IT HAS NO
//  SCORE.
//
//  Nothing here may tell a woman she is ready to conceive, or that she is not.
//  There is no readiness percentage, no completion ring dressed up as a health
//  measure, and no item she is required to finish. "8 of the 12 you chose to
//  track" is a count of her own list; "82% ready" is a claim about her body.
//
//  ---------------------------------------------------------------------------
//  ⚠️ THE LINE THAT DECIDES WHAT THIS FEATURE MAY AUTO-COMPLETE
//  ---------------------------------------------------------------------------
//
//  The app knows a great deal already — logged cycles, saved medicines,
//  supplements, vaccination statuses, a finished PCOS check. Using that is the
//  whole point. But there are two kinds of item here and they must be treated
//  differently:
//
//    · **Practical items** describe something SHE DID IN THE APP. "You have
//      logged four cycles" is a fact we own, and ticking `cycle tracking` off
//      her list is honest.
//    · **Medical items** describe a CONVERSATION WITH A CLINICIAN. Three
//      medicines saved in the app is evidence she takes medicines — it is not
//      evidence anyone has reviewed them. Auto-completing "medication review"
//      from a medicines list would tell her a doctor had done something no
//      doctor has done.
//
//  So [autoCompletable] is false on every medical item, and app data surfaces
//  there as EVIDENCE that raises priority instead. See `evidenceFor` in the
//  rules file, and `test/ttc_precheck_test.dart` which fails the build if a
//  core medical item is ever marked auto-completable.
//
//  ENGLISH FIRST — `_en(...)`, so `grep -c '_en('` is the Hindi backlog.
// =============================================================================

import 'package:flutter/foundation.dart';

import '../localization/app_language.dart';

LocalizedText _en(String s) => LocalizedText(en: s, hi: s);

// -----------------------------------------------------------------------------
//  Status
// -----------------------------------------------------------------------------

/// Where she stands on one item. Persisted by NAME, never by index.
///
/// ⚠️ FOUR STATES, AND `notRelevant` IS AS VALID AS `done`. A checklist that
/// only offers done/not-done makes every item that does not apply to her look
/// like a failure — and a good half of this list does not apply to any one
/// person.
enum PrecheckStatus { untouched, done, needsAttention, notSure, notRelevant }

extension PrecheckStatusCopy on PrecheckStatus {
  LocalizedText get label => switch (this) {
        PrecheckStatus.untouched => _en('Not looked at'),
        PrecheckStatus.done => _en('Done'),
        PrecheckStatus.needsAttention => _en('Need to do'),
        PrecheckStatus.notSure => _en('Not sure'),
        PrecheckStatus.notRelevant => _en('Not relevant to me'),
      };

  /// Counted in "worth checking" on the summary.
  bool get isOpen =>
      this == PrecheckStatus.needsAttention || this == PrecheckStatus.notSure;
}

/// How much an item matters — NOT how urgent it is medically.
///
/// ⚠️ THE WORDING IS THE SAFETY FEATURE. "Core" and "worth doing" describe our
/// editorial view of a checklist. "High risk" and "urgent" would be describing
/// her, which this tool has no basis for.
enum PrecheckTier { core, worthDoing, helpful }

extension PrecheckTierCopy on PrecheckTier {
  LocalizedText get label => switch (this) {
        PrecheckTier.core => _en('Core'),
        PrecheckTier.worthDoing => _en('Worth doing'),
        PrecheckTier.helpful => _en('Helpful if relevant'),
      };
}

enum PrecheckSection {
  folate,
  health,
  medicines,
  vaccines,
  lifestyle,
  body,
  dental,
  family,
  history,
  partner,
  practical,
}

extension PrecheckSectionCopy on PrecheckSection {
  LocalizedText get title => switch (this) {
        PrecheckSection.folate => _en('Folic acid & nutrition'),
        PrecheckSection.health => _en('Health & medical review'),
        PrecheckSection.medicines => _en('Medicines & supplements'),
        PrecheckSection.vaccines => _en('Vaccinations & immunity'),
        PrecheckSection.lifestyle => _en('Lifestyle'),
        PrecheckSection.body => _en('Weight & body health'),
        PrecheckSection.dental => _en('Dental & preventive care'),
        PrecheckSection.family => _en('Family & genetic history'),
        PrecheckSection.history => _en('Your reproductive history'),
        PrecheckSection.partner => _en('Preparing together'),
        PrecheckSection.practical => _en('Practical preparation'),
      };

  LocalizedText get blurb => switch (this) {
        PrecheckSection.folate =>
          _en('The one thing with the strongest evidence behind it, and what '
              'goes around it.'),
        PrecheckSection.health =>
          _en('A quick review now prevents surprises later.'),
        PrecheckSection.medicines =>
          _en('The most important section here, and the least talked about.'),
        PrecheckSection.vaccines =>
          _en('Two of these need a month of notice, which is why they come '
              'before rather than during.'),
        PrecheckSection.lifestyle =>
          _en('Small, specific, and none of it about being perfect.'),
        PrecheckSection.body =>
          _en('Your health habits matter more than a number.'),
        PrecheckSection.dental =>
          _en('The single most-forgotten item on any preconception list.'),
        PrecheckSection.family =>
          _en('What runs in the family, and who needs to know.'),
        PrecheckSection.history =>
          _en('Some past experiences change what a doctor suggests.'),
        PrecheckSection.partner =>
          _en('Half of this is his, and it is the half most often skipped.'),
        PrecheckSection.practical =>
          _en('Not medical, and genuinely useful.'),
      };
}

// -----------------------------------------------------------------------------
//  An item
// -----------------------------------------------------------------------------

@immutable
class PrecheckItem {
  const PrecheckItem({
    required this.id,
    required this.section,
    required this.tier,
    required this.title,
    required this.why,
    required this.whatToDo,
    this.autoCompletable = false,
    this.askDoctor,
    this.surfaceId,
    this.readId,
    this.medicalReview,
  });

  final String id;
  final PrecheckSection section;
  final PrecheckTier tier;

  final LocalizedText title;

  /// "Why it matters" — one or two sentences, never a scare.
  final LocalizedText why;

  /// "What to do" — the concrete action. Never a dose, never a named drug.
  final LocalizedText whatToDo;

  /// ⚠️ FALSE ON EVERY MEDICAL ITEM. See the note at the head of this file: app
  /// data can show that she takes medicines, and cannot show that anyone has
  /// reviewed them.
  final bool autoCompletable;

  /// The line she can carry into an appointment, where one applies.
  final LocalizedText? askDoctor;

  /// A surface in this stage that helps with the item.
  final String? surfaceId;

  /// A read id (without the `ttc_read/` prefix) for "learn more".
  final String? readId;

  /// ⚠️ THE CLINICAL-REVIEW REGISTER, ATTACHED TO THE CLAIM ITSELF.
  ///
  /// §28 of the brief asks for a visible configuration of everything needing
  /// clinical sign-off. Keeping that as a separate list guarantees it goes
  /// stale the first time someone edits copy. Marking the claim in place means
  /// the register is generated from the content — see `precheckReviewRegister`
  /// in the rules file — and cannot drift from it.
  final LocalizedText? medicalReview;
}

// -----------------------------------------------------------------------------
//  The list
// -----------------------------------------------------------------------------

final List<PrecheckItem> kPrecheckItems = [
  // ---- FOLATE & NUTRITION ---------------------------------------------------
  PrecheckItem(
    id: 'folate',
    section: PrecheckSection.folate,
    tier: PrecheckTier.core,
    title: _en('Folic acid'),
    why: _en('The neural tube closes in the first four weeks after conception '
        '— often before a period is missed. It has to already be in your body '
        'by then, which is why it belongs before rather than after.'),
    // ⚠️ NO DOSE. FOGSI puts the standard at 400–500 mcg and 4–5 mg for defined
    // high-risk groups, and which of those applies to HER is a prescription
    // decision. The article carries the numbers with their conditions
    // attached; a checklist item that named one would be prescribing.
    whatToDo: _en('Ask your doctor or pharmacist which dose is right for you — '
        'it differs if you have a medical condition, take certain medicines, '
        'or have had a pregnancy affected by a neural tube defect.'),
    askDoctor: _en('Which folic acid dose is right for me specifically?'),
    surfaceId: 'ttc_supplements',
    readId: 'ttc_read_three_months_before',
    medicalReview: _en('Folic acid wording — deliberately carries no dose. '
        'Confirm the referral-to-clinician framing is correct for India.'),
  ),

  PrecheckItem(
    id: 'nutrition',
    section: PrecheckSection.folate,
    tier: PrecheckTier.worthDoing,
    title: _en('Everyday eating'),
    why: _en('Not a diet. A handful of deficiencies are genuinely common in '
        'Indian women and genuinely easy to correct — iron, B12, vitamin D, '
        'iodine.'),
    whatToDo: _en('Have the common ones tested rather than guessed at, and eat '
        'the way you already eat with a little more protein in it.'),
    surfaceId: 'ttc_nutrition',
    readId: 'ttc_read_three_months_before',
    medicalReview: _en('Nutrition priorities for the Indian context — iron, '
        'B12, vitamin D, iodine.'),
  ),

  PrecheckItem(
    id: 'supplement_review',
    section: PrecheckSection.folate,
    tier: PrecheckTier.core,
    title: _en('Supplement review'),
    why: _en('Supplements are medicines with a friendlier label. Some are '
        'unhelpful before pregnancy and a few interact with prescriptions.'),
    whatToDo: _en('Take everything you take — including ayurvedic and herbal '
        'preparations — to one appointment and have it looked at together.'),
    askDoctor: _en('Are any of the supplements I take worth stopping or '
        'changing before pregnancy?'),
    surfaceId: 'ttc_supplements',
    medicalReview: _en('Herbal and ayurvedic wording — must make no blanket '
        'safety claim in either direction.'),
  ),

  // ---- HEALTH ---------------------------------------------------------------
  PrecheckItem(
    id: 'preconception_visit',
    section: PrecheckSection.health,
    tier: PrecheckTier.core,
    title: _en('A preconception conversation'),
    why: _en('One appointment before trying is worth several after. It is '
        'where medication, immunity, existing conditions and family history '
        'all get looked at together instead of one at a time.'),
    whatToDo: _en('A gynaecologist or a GP can do the whole thing in one '
        'visit. Take your list.'),
    surfaceId: 'ttc_prepare',
  ),

  PrecheckItem(
    id: 'conditions',
    section: PrecheckSection.health,
    tier: PrecheckTier.core,
    title: _en('Existing conditions'),
    why: _en('Thyroid, diabetes, blood pressure, epilepsy, autoimmune '
        'conditions — control before conception matters more than control '
        'after it, and for several the medicine itself may need changing.'),
    whatToDo: _en('Tell whoever manages the condition that you are planning to '
        'conceive. That sentence is the whole action.'),
    askDoctor: _en('Does anything about my condition or its treatment need to '
        'change before I try?'),
    medicalReview: _en('Condition-specific preconception guidance — kept '
        'deliberately general, no per-condition advice.'),
  ),

  PrecheckItem(
    id: 'baseline_tests',
    section: PrecheckSection.health,
    tier: PrecheckTier.worthDoing,
    title: _en('The blood tests worth doing once'),
    why: _en('Haemoglobin, thyroid, vitamin D, B12, blood sugar — cheap, '
        'commonly abnormal here, and correctable with a tablet.'),
    whatToDo: _en('One blood draw covers all of them. ⚠️ Not everyone needs '
        'every test — your doctor decides which apply to you.'),
    surfaceId: 'ttc_tests',
    readId: 'ttc_read_preconception_tests',
    medicalReview: _en('The baseline panel — confirm this list and that it is '
        'framed as "worth discussing" rather than "required".'),
  ),

  // ---- MEDICINES ------------------------------------------------------------
  PrecheckItem(
    id: 'medication_review',
    section: PrecheckSection.medicines,
    tier: PrecheckTier.core,
    title: _en('Medication review'),
    why: _en('Some medicines need changing before conception, and some '
        'conditions are far more dangerous untreated than the medicine ever '
        'was. Both are true, which is why this is a conversation rather than a '
        'rule.'),
    // ⚠️ THE SINGLE MOST SAFETY-CRITICAL LINE IN THIS FEATURE.
    whatToDo: _en('Take a list of everything you take — prescriptions, '
        'over-the-counter, supplements, herbal and ayurvedic preparations — to '
        'a doctor or pharmacist. ⚠️ Do not stop a prescribed medicine on your '
        'own.'),
    askDoctor: _en('Are any of my current medicines something I should review '
        'before pregnancy?'),
    surfaceId: 'ttc_medication',
    medicalReview: _en('⚠️ HIGHEST PRIORITY. The do-not-stop-on-your-own '
        'wording, and the inclusion of herbal and traditional preparations in '
        'the list.'),
  ),

  // ---- VACCINES -------------------------------------------------------------
  PrecheckItem(
    id: 'vaccines',
    section: PrecheckSection.vaccines,
    tier: PrecheckTier.core,
    title: _en('Vaccination and immunity'),
    why: _en('Rubella and varicella are live vaccines — if you are not immune '
        'you need the jab and then about a month before conceiving. It is the '
        'one item on this list with a deadline attached.'),
    whatToDo: _en('Ask for a rubella IgG test by name. About 85 in 100 Indian '
        'women are already immune, so for most people this is one blood test '
        'that comes back fine.'),
    askDoctor: _en('Do I need my rubella or varicella immunity checked?'),
    surfaceId: 'ttc_vaccinations',
    readId: 'ttc_read_preconception_tests',
    medicalReview: _en('⚠️ Rubella and MMR timing, the 28-day interval, and '
        'the seroprevalence figure.'),
  ),

  // ---- LIFESTYLE ------------------------------------------------------------
  PrecheckItem(
    id: 'tobacco',
    section: PrecheckSection.lifestyle,
    tier: PrecheckTier.core,
    title: _en('Tobacco'),
    why: _en('The clearest of the lifestyle factors, for both of you, and the '
        'one that reverses. This includes gutka, khaini and paan masala, which '
        'often are not counted as smoking by the person using them.'),
    whatToDo: _en('If either of you uses tobacco in any form, this is the '
        'change worth making first. Support exists and asking for it is '
        'reasonable.'),
    medicalReview: _en('Smoking and smokeless tobacco language — supportive, '
        'never shaming.'),
  ),

  PrecheckItem(
    id: 'alcohol',
    section: PrecheckSection.lifestyle,
    tier: PrecheckTier.worthDoing,
    title: _en('Alcohol'),
    why: _en('Heavy drinking clearly affects fertility in both partners. The '
        'evidence on occasional drinking is much weaker, and the honest '
        'position is that heavy is a problem and occasional probably is not.'),
    whatToDo: _en('Most guidance suggests stopping once you are trying, on the '
        'grounds that you may be pregnant before you know.'),
    medicalReview: _en('Alcohol wording — the "no established safe level in '
        'pregnancy" position versus the weaker while-trying evidence.'),
  ),

  PrecheckItem(
    id: 'caffeine',
    section: PrecheckSection.lifestyle,
    tier: PrecheckTier.helpful,
    title: _en('Caffeine'),
    why: _en('The one people over-worry about. Moderate intake has not been '
        'shown to reduce fertility.'),
    whatToDo: _en('You do not need to give up chai. Around two to three cups '
        'of coffee a day is the usual figure quoted.'),
    medicalReview: _en('Caffeine threshold.'),
  ),

  PrecheckItem(
    id: 'movement',
    section: PrecheckSection.lifestyle,
    tier: PrecheckTier.helpful,
    title: _en('Movement'),
    why: _en('Regular activity helps insulin sensitivity and sleep. Extremes '
        'in either direction do not help.'),
    whatToDo: _en('A walk after dinner is doing something specific rather than '
        'something virtuous — muscle takes up glucose with very little '
        'insulin.'),
    surfaceId: 'ttc_ritual',
  ),

  PrecheckItem(
    id: 'sleep',
    section: PrecheckSection.lifestyle,
    tier: PrecheckTier.helpful,
    title: _en('Sleep'),
    why: _en('Broken sleep affects the hormonal rhythm that drives a cycle, '
        'and it is the first thing to go when this stage gets heavy.'),
    whatToDo: _en('Worth raising if it has been poor for months rather than '
        'weeks.'),
  ),

  // ---- BODY -----------------------------------------------------------------
  PrecheckItem(
    id: 'body',
    section: PrecheckSection.body,
    tier: PrecheckTier.worthDoing,
    title: _en('Weight and metabolic health'),
    // ⚠️ NO BMI, NO TARGET, NO NUMBER. Weight affects ovulation at BOTH ends
    // and the evidence supports a modest sustained change rather than reaching
    // a figure. A checklist item with a goal weight on it would be the thing
    // this section exists to refuse.
    why: _en('Weight affects ovulation at both ends, and only one end is ever '
        'discussed. Being significantly underweight suppresses it as reliably '
        'as being significantly overweight does.'),
    whatToDo: _en('Where weight is raised, the figure the evidence keeps '
        'returning to is a modest five per cent — not a target weight, and not '
        'a reason to postpone trying for a year.'),
    readId: 'ttc_read_three_months_before',
    medicalReview: _en('⚠️ The five per cent figure, and that no BMI number or '
        'target weight appears anywhere.'),
  ),

  // ---- DENTAL ---------------------------------------------------------------
  PrecheckItem(
    id: 'dental',
    section: PrecheckSection.dental,
    tier: PrecheckTier.worthDoing,
    title: _en('A dental check'),
    why: _en('Gum disease is associated with preterm birth, and treatment is '
        'more awkward once you are pregnant.'),
    whatToDo: _en('A routine cleaning now is straightforward. This is the '
        'single most-forgotten item on any preconception list.'),
    medicalReview: _en('Dental claim — association with preterm birth is '
        'stated as association, not cause.'),
  ),

  // ---- FAMILY ---------------------------------------------------------------
  PrecheckItem(
    id: 'family_history',
    section: PrecheckSection.family,
    tier: PrecheckTier.core,
    title: _en('What runs in the family'),
    why: _en('Thalassaemia carrier screening is recommended for all couples '
        'here regardless of family history, because carriers have no symptoms '
        'and it only means anything as a pair.'),
    whatToDo: _en('Tell your doctor about any inherited condition in either '
        'family. ⚠️ Not everyone needs genetic testing — they decide whether '
        'carrier screening or counselling applies to you.'),
    askDoctor: _en('Given our family histories, is carrier screening worth '
        'doing?'),
    readId: 'ttc_read_preconception_tests',
    medicalReview: _en('⚠️ Genetic screening language — must not imply anyone '
        'needs testing. Thalassaemia recommendation per FOGSI.'),
  ),

  // ---- HISTORY --------------------------------------------------------------
  PrecheckItem(
    id: 'reproductive_history',
    section: PrecheckSection.history,
    tier: PrecheckTier.worthDoing,
    title: _en('Your reproductive history'),
    why: _en('A previous loss, an ectopic pregnancy, fertility treatment or '
        'pelvic surgery can each change what a doctor suggests before you try '
        'again.'),
    whatToDo: _en('Only if it applies to you, and only as much as you want to '
        'say. It is on this list because it changes advice, not because it '
        'needs explaining.'),
    readId: 'ttc_read_trying_again',
  ),

  // ---- PARTNER --------------------------------------------------------------
  PrecheckItem(
    id: 'partner_health',
    section: PrecheckSection.partner,
    tier: PrecheckTier.core,
    title: _en('His side of it'),
    why: _en('A male factor is involved in about half of couples who take '
        'longer than expected, and his half is the fastest to check.'),
    whatToDo: _en('Tobacco, alcohol and heat are the three with evidence. Any '
        'change he makes shows up in a test about three months later.'),
    readId: 'ttc_read_heat_habits',
    surfaceId: 'ttc_partner',
    medicalReview: _en('Male-factor involvement in roughly half of couples, '
        'and the ~3-month spermatogenesis timeline.'),
  ),

  PrecheckItem(
    id: 'partner_meds',
    section: PrecheckSection.partner,
    tier: PrecheckTier.worthDoing,
    title: _en('His medicines'),
    why: _en('Several ordinary medicines affect sperm production — some for '
        'hair loss, some psychiatric, and anything containing testosterone, '
        'which suppresses production rather than helping it.'),
    whatToDo: _en('Worth him mentioning what he takes at any appointment. ⚠️ '
        'Not a reason to stop anything on his own.'),
    readId: 'ttc_read_whose_side',
  ),

  // ---- PRACTICAL ------------------------------------------------------------
  PrecheckItem(
    id: 'fertile_window',
    section: PrecheckSection.practical,
    tier: PrecheckTier.helpful,
    // ⚠️ AUTO-COMPLETABLE. This is a thing she does in the app, so the app can
    // honestly say it is covered.
    autoCompletable: true,
    title: _en('Understanding your window'),
    why: _en('The window is about six days and the two days before ovulation '
        'carry most of it. Every one to two days across it is the whole '
        'instruction.'),
    whatToDo: _en('Nothing to buy and nothing to track, unless you want to.'),
    surfaceId: 'ttc_window',
    readId: 'ttc_read_timing_myths',
  ),

  PrecheckItem(
    id: 'cycle_tracking',
    section: PrecheckSection.practical,
    tier: PrecheckTier.helpful,
    autoCompletable: true,
    title: _en('A record of your cycles'),
    why: _en('Three months of dates is the single most useful thing to bring '
        'to a first appointment, and it is the one thing no doctor can '
        'reconstruct for you.'),
    whatToDo: _en('Just the first day of each period is enough.'),
    surfaceId: 'ttc_cycle',
  ),

  PrecheckItem(
    id: 'when_to_seek_help',
    section: PrecheckSection.practical,
    tier: PrecheckTier.worthDoing,
    title: _en('Knowing when to ask for help'),
    why: _en('The usual guidance is a year under 36, and at presentation from '
        '36 — but that assumes predictable cycles, and several situations mean '
        'the clock does not apply at all.'),
    whatToDo: _en('Worth the two of you agreeing a point in advance, rather '
        'than deciding it one disappointing month at a time.'),
    readId: 'ttc_read_when_to_seek_help',
    medicalReview: _en('Referral thresholds per NICE — 12 months under 36, at '
        'presentation from 36, earlier where a cause is known.'),
  ),

  PrecheckItem(
    id: 'who_to_see',
    section: PrecheckSection.practical,
    tier: PrecheckTier.helpful,
    title: _en('Knowing who you would see'),
    why: _en('Working out which doctor or clinic while nothing is wrong is '
        'much easier than working it out while something is.'),
    whatToDo: _en('A gynaecologist you can get to is usually where this '
        'starts, rather than a fertility clinic.'),
    surfaceId: 'ttc_prepare',
  ),
];

PrecheckItem? precheckItemById(String id) {
  for (final i in kPrecheckItems) {
    if (i.id == id) return i;
  }
  return null;
}

List<PrecheckItem> precheckItemsIn(PrecheckSection s) =>
    [for (final i in kPrecheckItems) if (i.section == s) i];

/// The editorial beat after the first section — §26. Not labelled a tip.
final LocalizedText kPrecheckPatternBreak = _en(
    'Preparing for pregnancy is not about getting a perfect score. It is about '
    'giving yourself a little more information before the next chapter '
    'begins.');
