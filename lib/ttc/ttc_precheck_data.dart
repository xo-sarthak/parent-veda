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
        PrecheckTier.helpful => _en('Helpful if it applies'),
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

/// The sections the checklist actually renders.
///
/// ⚠️ "PREPARING TOGETHER" IS HIDDEN, NOT REMOVED, and the difference is
/// load-bearing in three separate ways:
///
///   · **The enum value is an IDENTITY.** `PrecheckStore` persists ticks
///     against `section.name` in `shared_preferences` and syncs them to
///     Supabase. Deleting `PrecheckSection.partner` would strand every couple
///     who has already ticked "His side of it" — the row survives, and nothing
///     can ever read it again. Same class of trap as `AppLanguage.hinglish`.
///   · **Its two items are still real.** `partner_health` and `partner_meds`
///     carry the male-factor fact this stage most needs a woman to hear, and
///     both still have their reads and their `ttc_partner` surface. The
///     partner screen is where that content lives now; it did not stop
///     existing because a section stopped being drawn.
///   · **`ttc_precheck/partner` still resolves.** The surface router matches
///     on the enum, so a door or a journey step naming that section opens it
///     directly. Hiding it from the list is not the same as making it
///     unreachable, and that is deliberate — see the wiring gate.
///
/// To put it back: return `PrecheckSection.values` here. Nothing else changed.
// ⚠️ THE ORDER IS THE ORDER OF URGENCY (2026-09-30): what has to start or
// change BEFORE conceiving (folic acid, what she takes), then the check-up and
// the vaccines that need a month's gap, then everyday things, then the rest.
// Medicines was third, after the check-up, though its own blurb calls it "the
// most important section here". Kept for revert: folate, health, medicines,
// vaccines, ...
const List<PrecheckSection> ttcVisiblePrecheckSections = [
  PrecheckSection.folate,
  PrecheckSection.medicines,
  PrecheckSection.health,
  PrecheckSection.vaccines,
  PrecheckSection.lifestyle,
  PrecheckSection.body,
  PrecheckSection.dental,
  PrecheckSection.family,
  PrecheckSection.history,
  // PrecheckSection.partner,
  PrecheckSection.practical,
];

extension PrecheckSectionCopy on PrecheckSection {
  LocalizedText get title => switch (this) {
        PrecheckSection.folate => _en('Folic acid and food'),
        PrecheckSection.health => _en('Health check-up'),
        PrecheckSection.medicines => _en('Medicines and supplements'),
        PrecheckSection.vaccines => _en('Vaccines and immunity'),
        PrecheckSection.lifestyle => _en('Everyday habits'),
        PrecheckSection.body => _en('Weight and body health'),
        PrecheckSection.dental => _en('Teeth and routine check-ups'),
        PrecheckSection.family => _en('Family and genetic history'),
        PrecheckSection.history => _en('Your pregnancy and fertility history'),
        PrecheckSection.partner => _en('Getting ready together'),
        PrecheckSection.practical => _en('Practical things'),
      };

  LocalizedText get blurb => switch (this) {
        PrecheckSection.folate =>
          _en('The step with the strongest evidence behind it, and what goes '
              'with it.'),
        PrecheckSection.health =>
          _en('A quick check now saves surprises later.'),
        PrecheckSection.medicines =>
          _en('The most important section here, and the one least talked '
              'about.'),
        PrecheckSection.vaccines =>
          _en("Two of these need a month's gap, so they belong before "
              'pregnancy, not during it.'),
        PrecheckSection.lifestyle =>
          _en('Small changes. None of it is about being perfect.'),
        PrecheckSection.body =>
          _en('Your health habits matter more than a number.'),
        PrecheckSection.dental =>
          _en('The item people forget most on any before-pregnancy list.'),
        PrecheckSection.family =>
          _en('What runs in the family, and who needs to know.'),
        PrecheckSection.history =>
          _en('Some past experiences change what a doctor suggests.'),
        PrecheckSection.partner =>
          _en("Half of this is his, and it's the half most often skipped."),
        PrecheckSection.practical =>
          _en('Not medical, but really useful.'),
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
    why: _en("The baby's neural tube (the start of the brain and spine) "
        'closes in the first four weeks after conception, often before a '
        "period is missed. Folic acid needs to be in your body by then. That's "
        'why you start it before trying, not after.'),
    // ⚠️ NO DOSE. FOGSI puts the standard at 400–500 mcg and 4–5 mg for defined
    // high-risk groups, and which of those applies to HER is a prescription
    // decision. The article carries the numbers with their conditions
    // attached; a checklist item that named one would be prescribing.
    whatToDo: _en('Ask your doctor or pharmacist which dose is right for you. '
        "It's different if you have a health condition, take certain "
        'medicines, or have had a pregnancy affected by a neural tube defect.'),
    askDoctor: _en('Which folic acid dose is right for me?'),
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
    why: _en('Not a diet. A few shortfalls are very common in Indian women '
        'and very easy to fix: iron, B12, vitamin D and iodine.'),
    whatToDo: _en('Get the common ones tested instead of guessing. Keep eating '
        'the way you already do, with a little more protein.'),
    surfaceId: 'ttc_nutrition',
    readId: 'ttc_read_three_months_before',
    medicalReview: _en('Nutrition priorities for the Indian context — iron, '
        'B12, vitamin D, iodine.'),
  ),

  PrecheckItem(
    id: 'supplement_review',
    // ⚠️ IN THE SECTION THAT NAMES IT (2026-09-30, the user: "why is medicine
    // and supplements randomly placed?"). "Medicines and supplements" held
    // one item, a review of medicines, while "Supplement review" sat under
    // "Folic acid and food". Kept for revert: section: PrecheckSection.folate.
    section: PrecheckSection.medicines,
    tier: PrecheckTier.core,
    title: _en('Supplement review'),
    why: _en('Supplements are medicines with a friendlier label. Some '
        "don't help before pregnancy, and a few mix badly with prescription "
        'medicines.'),
    whatToDo: _en('Take everything you use, including ayurvedic and herbal '
        'products, to one appointment and have it all checked together.'),
    askDoctor: _en('Should I stop or change any of my supplements before '
        'pregnancy?'),
    surfaceId: 'ttc_supplements',
    medicalReview: _en('Herbal and ayurvedic wording — must make no blanket '
        'safety claim in either direction.'),
  ),

  // ---- HEALTH ---------------------------------------------------------------
  PrecheckItem(
    id: 'preconception_visit',
    section: PrecheckSection.health,
    tier: PrecheckTier.core,
    title: _en('A check-up before you try'),
    why: _en('One visit before trying is worth several after. Your medicines, '
        'immunity, health conditions and family history all get looked at '
        'together, not one at a time.'),
    whatToDo: _en('A gynaecologist or a GP can cover all of it in one visit. '
        'Take your list.'),
    surfaceId: 'ttc_prepare',
  ),

  PrecheckItem(
    id: 'conditions',
    section: PrecheckSection.health,
    tier: PrecheckTier.core,
    title: _en('Existing conditions'),
    why: _en('Thyroid, diabetes, blood pressure, epilepsy, autoimmune '
        'conditions: keeping these in control before conception matters more '
        'than after. For several, the medicine itself may need changing.'),
    whatToDo: _en('Tell the doctor who looks after your condition that '
        "you're planning a pregnancy. That one sentence is all you need to "
        'do.'),
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
    why: _en('Haemoglobin, thyroid, vitamin D, B12 and blood sugar. They '
        "are cheap, often off in India, and easy to fix with a tablet."),
    whatToDo: _en('One blood draw covers all of them. Not everyone needs '
        'every test. Your doctor decides which ones apply to you.'),
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
    title: _en('A review of your medicines'),
    why: _en('Some medicines need changing before conception. And some '
        'conditions are far more dangerous untreated than the medicine ever '
        'was. Both are true, so this needs a conversation, not a rule.'),
    // ⚠️ THE SINGLE MOST SAFETY-CRITICAL LINE IN THIS FEATURE.
    whatToDo: _en('Take a list of everything you take (prescriptions, '
        'over-the-counter medicines, supplements, herbal and ayurvedic '
        'products) to a doctor or pharmacist. Do not stop a prescribed '
        'medicine on your own.'),
    askDoctor: _en('Should any of my current medicines be reviewed before '
        'pregnancy?'),
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
    why: _en('Rubella and varicella (chickenpox) vaccines are live vaccines. '
        "If you're not immune, you need the jab and then about a month before "
        "trying to conceive. It's the one item on this list with a deadline."),
    whatToDo: _en('Ask for a rubella IgG test by name. About 85 in 100 Indian '
        "women are already immune, so for most people it's one blood test that "
        'comes back fine.'),
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
    why: _en('Of all the everyday habits, this has the clearest evidence, '
        'for both of you, and its effects reverse when you stop. It includes '
        "gutka, khaini and paan masala, which people often don't count as "
        'smoking.'),
    whatToDo: _en('If either of you uses tobacco in any form, this is the '
        "change to make first. Help is out there, and it's fine to ask for "
        'it.'),
    medicalReview: _en('Smoking and smokeless tobacco language — supportive, '
        'never shaming.'),
  ),

  PrecheckItem(
    id: 'alcohol',
    section: PrecheckSection.lifestyle,
    tier: PrecheckTier.worthDoing,
    title: _en('Alcohol'),
    why: _en('Heavy drinking clearly affects fertility in both partners. The '
        'evidence on the odd drink is much weaker. The honest answer: heavy '
        "drinking is a problem, and an occasional drink probably isn't."),
    whatToDo: _en("Most guidance says to stop once you're trying, because you "
        'may be pregnant before you know it.'),
    medicalReview: _en('Alcohol wording — the "no established safe level in '
        'pregnancy" position versus the weaker while-trying evidence.'),
  ),

  PrecheckItem(
    id: 'caffeine',
    section: PrecheckSection.lifestyle,
    tier: PrecheckTier.helpful,
    title: _en('Caffeine'),
    why: _en('The one people worry about too much. A moderate amount '
        "hasn't been shown to lower fertility."),
    whatToDo: _en("You don't need to give up chai. Around two to three cups "
        'of coffee a day is the figure usually quoted.'),
    medicalReview: _en('Caffeine threshold.'),
  ),

  PrecheckItem(
    id: 'movement',
    section: PrecheckSection.lifestyle,
    tier: PrecheckTier.helpful,
    title: _en('Movement'),
    why: _en('Regular activity helps your body use insulin, and helps you '
        "sleep. Too much or too little doesn't help."),
    whatToDo: _en('A walk after dinner does something real. Working muscles '
        'take up sugar from the blood with very little insulin.'),
    surfaceId: 'ttc_ritual',
  ),

  PrecheckItem(
    id: 'sleep',
    section: PrecheckSection.lifestyle,
    tier: PrecheckTier.helpful,
    title: _en('Sleep'),
    why: _en('Broken sleep upsets the hormone rhythm that drives your cycle. '
        "It's also the first thing to go when this stage feels heavy."),
    whatToDo: _en("Worth mentioning to a doctor if it's been poor for months, "
        'not just weeks.'),
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
    why: _en('Weight affects ovulation at both ends, but only one end ever '
        'gets talked about. Being very underweight can hold back ovulation '
        'just as surely as being very overweight.'),
    whatToDo: _en('If weight comes up, the figure the evidence keeps coming '
        "back to is a modest five per cent. That's not a target weight, and "
        "it's not a reason to put off trying for a year."),
    readId: 'ttc_read_three_months_before',
    // ⚠️ THE CALCULATOR IS OFFERED, AND THE ITEM STILL CARRIES NO NUMBER.
    // The checklist item is about a conversation; the calculator is one input
    // to it. Reading a number does not complete this item — see
    // `autoCompletable`, which stays false.
    surfaceId: 'ttc_bmi',
    medicalReview: _en('⚠️ The five per cent figure, and that no BMI number or '
        'target weight appears anywhere in the item itself.'),
  ),

  // ---- DENTAL ---------------------------------------------------------------
  PrecheckItem(
    id: 'dental',
    section: PrecheckSection.dental,
    tier: PrecheckTier.worthDoing,
    title: _en('A dental check'),
    why: _en('Gum disease is linked with babies being born early (preterm '
        "birth), and treatment is harder once you're pregnant."),
    whatToDo: _en("A routine cleaning now is easy. It's the item people forget "
        'most on any before-pregnancy list.'),
    medicalReview: _en('Dental claim — association with preterm birth is '
        'stated as association, not cause.'),
  ),

  // ---- FAMILY ---------------------------------------------------------------
  PrecheckItem(
    id: 'family_history',
    section: PrecheckSection.family,
    tier: PrecheckTier.core,
    title: _en('What runs in the family'),
    why: _en('Thalassaemia carrier screening is advised for all couples in '
        'India, whatever your family history. Carriers have no symptoms, and '
        'the result only means something when you look at both of you.'),
    whatToDo: _en('Tell your doctor about any condition that runs in either '
        'family. Not everyone needs genetic testing. Your doctor decides '
        'whether carrier screening or counselling applies to you.'),
    askDoctor: _en('With our family histories, is carrier screening worth '
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
    why: _en('A past loss, an ectopic pregnancy, fertility treatment or '
        'surgery in the pelvis can each change what a doctor suggests before '
        'you try again.'),
    whatToDo: _en('Only if it applies to you, and only as much as you want to '
        "share. It's here because it changes the advice, not because you need "
        'to explain it.'),
    readId: 'ttc_read_trying_again',
  ),

  // ---- PARTNER --------------------------------------------------------------
  PrecheckItem(
    id: 'partner_health',
    section: PrecheckSection.partner,
    tier: PrecheckTier.core,
    title: _en('His side of it'),
    why: _en('A male factor is part of the picture in about half of couples '
        'who take longer than expected. His side is also the quickest to '
        'check.'),
    whatToDo: _en('Tobacco, alcohol and heat are the three with evidence behind '
        'them. Any change he makes shows up in a test about three months '
        'later.'),
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
    why: _en('Several ordinary medicines affect sperm production. Some are '
        'for hair loss, some are for mental health, and anything with '
        'testosterone in it lowers production instead of helping.'),
    whatToDo: _en('Worth him mentioning what he takes at any appointment. '
        "It's not a reason to stop anything on his own."),
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
    title: _en('Knowing your fertile days'),
    why: _en('Your fertile window is about six days, and the two days before '
        'ovulation matter most. Sex every one to two days across it is all '
        'you need to do.'),
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
    why: _en('Three months of dates is the most useful thing to bring to a '
        "first appointment. It's also the one thing no doctor can piece "
        'together for you.'),
    whatToDo: _en('Just the first day of each period is enough.'),
    surfaceId: 'ttc_cycle',
  ),

  PrecheckItem(
    id: 'when_to_seek_help',
    section: PrecheckSection.practical,
    tier: PrecheckTier.worthDoing,
    title: _en('Knowing when to ask for help'),
    why: _en("The usual advice is a year of trying if you're under 36, and "
        "no need to wait from 36. But that assumes regular cycles, and in "
        "several situations the waiting time doesn't apply at all."),
    whatToDo: _en('It helps if the two of you agree on a point in advance, '
        'instead of deciding one hard month at a time.'),
    readId: 'ttc_read_when_to_seek_help',
    medicalReview: _en('Referral thresholds per NICE — 12 months under 36, at '
        'presentation from 36, earlier where a cause is known.'),
  ),

  PrecheckItem(
    id: 'who_to_see',
    section: PrecheckSection.practical,
    tier: PrecheckTier.helpful,
    title: _en("Knowing which doctor you'd see"),
    why: _en('Choosing a doctor or clinic while nothing is wrong is much '
        'easier than choosing one once something is.'),
    whatToDo: _en('This usually starts with a gynaecologist you can easily '
        'get to, not a fertility clinic.'),
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

/// The items the checklist draws: those in a visible section (2026-09-29).
///
/// ⚠️ COUNTS AND LISTS READ THIS, NOT `kPrecheckItems`. The two partner items
/// sit in a hidden section, so counting the whole catalogue put two rows she
/// can never see into "Not looked at" on her summary.
List<PrecheckItem> get kPrecheckVisibleItems => [
      for (final i in kPrecheckItems)
        if (ttcVisiblePrecheckSections.contains(i.section)) i,
    ];

/// The editorial beat after the first section — §26. Not labelled a tip.
final LocalizedText kPrecheckPatternBreak = _en(
    "Getting ready for pregnancy isn't about a perfect score. It's about "
    'giving yourself a little more to go on before the next chapter '
    'begins.');

// -----------------------------------------------------------------------------
//  Each item asks its OWN question (2026-09-30)
// -----------------------------------------------------------------------------
//
//  ⚠️ THE USER, LOOKING AT THE TOOL ON THE PHONE: "Everywhere you open, where
//  are you? Your reproductive history, where are you? Done? Need to do? Not
//  sure, not relevant to me? For every drop down the same question with the
//  same options." Every opened item carried the one question "Where you are"
//  and the four answers "Done / Need to do / Not sure / Not relevant to me",
//  which fit "Folic acid" and made no sense on "Tobacco" ("Done?") or "Your
//  reproductive history" ("Need to do?"). The tools review had rendered one
//  opened item and called it good.
//
//  So each item now asks the question it is about, and its four answers say
//  what they mean for that item. UNDERNEATH NOTHING CHANGES: the four answers
//  still store as the same four statuses (done, needsAttention, notSure,
//  notRelevant), so the ring, the next-3 steps, the folds and the doctor
//  notes read exactly what they read before. Only the words are the item's.
//  English only (new copy); an item with no entry falls back to the generic
//  question, which a test forbids for every shipped item.

class PrecheckAsk {
  const PrecheckAsk(
      this.question, this.done, this.need, this.notSure, this.notRelevant);

  final String question;

  /// Stored as [PrecheckStatus.done].
  final String done;

  /// Stored as [PrecheckStatus.needsAttention].
  final String need;

  /// Stored as [PrecheckStatus.notSure].
  final String notSure;

  /// Stored as [PrecheckStatus.notRelevant]. Leaves her count, as before.
  final String notRelevant;

  String labelFor(PrecheckStatus s) => switch (s) {
        PrecheckStatus.done => done,
        PrecheckStatus.needsAttention => need,
        PrecheckStatus.notSure => notSure,
        PrecheckStatus.notRelevant => notRelevant,
        PrecheckStatus.untouched => 'Not looked at',
      };
}

/// The old one-question-for-everything, kept as the fallback and for revert.
const PrecheckAsk kPrecheckGenericAsk = PrecheckAsk(
  'Where are you with this?',
  'Done',
  'Need to do',
  'Not sure',
  'Not relevant to me',
);

const Map<String, PrecheckAsk> kPrecheckAsks = {
  'folate': PrecheckAsk('Are you taking folic acid?', 'Yes, I take it',
      'Not yet', 'Not sure of the dose', "Doesn't apply to me"),
  'nutrition': PrecheckAsk('Is your eating covering the basics?', 'Yes, mostly',
      'Not really', 'Not sure', "Doesn't apply to me"),
  'supplement_review': PrecheckAsk(
      'Have you checked your supplements with a doctor or pharmacist?',
      'Yes, checked',
      'Not yet',
      'Not sure',
      'I take none'),
  'preconception_visit': PrecheckAsk('Have you had a check-up before trying?',
      "Yes, I've had one", 'I need to book one', 'Not sure I need one',
      "Doesn't apply to me"),
  'conditions': PrecheckAsk('Do you have a long-term condition?',
      "Yes, it's under control", 'Yes, it needs a check', 'Not sure',
      'No, I have none'),
  'baseline_tests': PrecheckAsk('Have you had these blood tests?',
      'Yes, recently', 'Not yet', 'Not sure which', "Doesn't apply to me"),
  'medication_review': PrecheckAsk('Has a doctor reviewed your medicines?',
      'Yes, reviewed', 'Not yet', 'Not sure', 'I take none'),
  'vaccines': PrecheckAsk('Are your vaccines up to date?', 'Yes, up to date',
      'I need some', 'Not sure', "Doesn't apply to me"),
  'tobacco': PrecheckAsk('Do you use tobacco?', "I've stopped",
      'I want to stop', 'Only sometimes', 'I never have'),
  'alcohol': PrecheckAsk('How is alcohol for you?', "I've cut right back",
      'I want to cut back', 'Not sure', "I don't drink"),
  'caffeine': PrecheckAsk('How much caffeine do you have?',
      'Within about 200 mg', 'More than that', 'Not sure how much',
      "I don't have it"),
  'movement': PrecheckAsk('Are you active most days?', 'Yes, most days',
      'I want to do more', 'Not sure', 'My doctor says rest'),
  'sleep': PrecheckAsk('Are you sleeping well?', 'Yes, mostly', "It's broken",
      'Not sure', "Doesn't apply to me"),
  'body': PrecheckAsk('Have you looked at your weight and health?',
      "Yes, it's fine", 'I want to work on it', 'Not sure',
      "Doesn't apply to me"),
  'dental': PrecheckAsk('Have you had a dental check lately?', 'Yes, recently',
      'I need to book', 'Not sure when', "Doesn't apply to me"),
  'family_history': PrecheckAsk('Do you know what runs in your family?',
      "Yes, I've checked", 'I need to ask', 'Not sure', "I can't find out"),
  'reproductive_history': PrecheckAsk(
      'Has a doctor heard about your past pregnancies or treatment?',
      'Yes, they have',
      'I should mention it',
      'Not sure it matters',
      'Nothing to report'),
  'partner_health': PrecheckAsk('Has he had a check-up?', 'Yes, he has',
      'He needs one', 'Not sure', "Doesn't apply to us"),
  'partner_meds': PrecheckAsk('Has he checked his medicines?', 'Yes, he has',
      'He needs to', 'Not sure', 'He takes none'),
  'fertile_window': PrecheckAsk('Do you know your fertile days?',
      'Yes, I know them', 'I want to learn', 'Not sure', "Doesn't apply to me"),
  'cycle_tracking': PrecheckAsk('Do you keep a record of your cycles?',
      'Yes, I log them', 'I need to start', 'Not sure how',
      "Doesn't apply to me"),
  'when_to_seek_help': PrecheckAsk('Do you know when to ask for help?',
      'Yes, I know', "I'd like to read it", 'Not sure', "Doesn't apply to me"),
  'who_to_see': PrecheckAsk('Do you know who to see?', 'Yes, I have someone',
      'I need to find someone', 'Not sure who', "Doesn't apply to me"),
};

PrecheckAsk precheckAskFor(String itemId) =>
    kPrecheckAsks[itemId] ?? kPrecheckGenericAsk;
