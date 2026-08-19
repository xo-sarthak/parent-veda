// =============================================================================
//  Complications & conditions — the data behind "Understand my condition"
// -----------------------------------------------------------------------------
//  Backs `ConditionsHomeScreen` / `ConditionDetailScreen`. Built to the spec
//  agreed for this section: a two-way door up front (diagnosed vs curious), an
//  8-most-common grid with a searchable "see more" behind it, and one fixed
//  8-part structure for every condition page — but NOT one fixed LENGTH. A
//  common condition earns paragraphs; a rare one earns two honest sentences
//  and a pointer to urgent care. Padding a rare condition to look as complete
//  as gestational diabetes would be lying about how much there is to say.
//
//  ⚠️ ENGLISH ONLY FOR NOW. `_en(...)` = English now, Hindi owed — same
//  convention as `pregnancy_hubs.dart` and `pregnancy_journeys.dart`.
//
//  ⚠️ WHY A DOOR BEFORE ANY CONTENT. A mother who has just been told a word by
//  her doctor and one who is idly reading ahead are not the same visit. Asking
//  first, and only offering "add to my journey" to the one who said "my doctor
//  told me", stops an unconfirmed fear from quietly becoming a profile entry —
//  the same instinct as `Inferable` being default-deny in `journey_state.dart`.
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../localization/app_language.dart';
import '../services/family_profile.dart';

LocalizedText _en(String s) => LocalizedText(en: s, hi: s);

// -----------------------------------------------------------------------------
//  The two-way door
// -----------------------------------------------------------------------------

/// What she told us when she opened this section. `unset` means "not asked
/// yet" — the gate that must be answered before any condition renders.
enum ConditionDoorAnswer { unset, diagnosed, curious }

/// Which shelf a condition sits on, on the home screen.
enum ConditionGroup {
  /// The 8 most-common, shown immediately as tappable cards.
  common,

  /// Miscarriage and preeclampsia — flagged high-anxiety must-haves. Shown in
  /// their own quiet strip, not inside "see more", because someone looking for
  /// either of these should not have to tap a "see more" toggle to find it —
  /// and not on the bright common-8 grid either, because that grid is meant to
  /// read as routine and these two are not.
  highAnxiety,

  placentaBleeding,
  positionCervix,
  discomforts,
  specialist,

  /// One combined page for pregnancy alongside a pre-existing condition
  /// (type 1 diabetes, epilepsy) — deliberately not split into thin
  /// one-condition-each pages. See the entry itself for why.
  preExisting,

  seasonal,
}

extension ConditionGroupMeta on ConditionGroup {
  LocalizedText get title => switch (this) {
        ConditionGroup.common => _en('Most common'),
        ConditionGroup.highAnxiety => _en('If either of these brought you here'),
        ConditionGroup.placentaBleeding => _en('Placenta & bleeding'),
        ConditionGroup.positionCervix => _en('Position & cervix'),
        ConditionGroup.discomforts => _en('Common discomforts'),
        ConditionGroup.specialist => _en('Specialist & less common'),
        // ⚠️ THE SHELF AND THE PAGE ON IT MUST NOT SHARE A NAME. This group
        // title used to read "Pregnancy with a pre-existing condition" —
        // exactly the name of the single entry inside it — so the shelf
        // rendered a heading and one card saying the same words twice, which
        // reads as a rendering bug rather than as organisation. The spec's own
        // wording for the shelf is the plural category; the page keeps the
        // longer sentence, because a page is a thing you read and a shelf is a
        // thing you scan. Found by a test asserting each group title appears
        // once.
        ConditionGroup.preExisting => _en('Pre-existing conditions'),
        ConditionGroup.seasonal => _en('Seasonal & infections'),
      };
}

/// One question-and-answer pair for a condition's FAQ.
class ConditionFaq {
  const ConditionFaq({required this.question, required this.answer});
  final LocalizedText question;
  final LocalizedText answer;
}

/// One condition page, in the fixed 8-part order the spec sets:
/// what it is + reassurance · how common in India · symptoms · when to call
/// vs monitor · which tests confirm it · how it's managed in India · impact on
/// baby · FAQ.
class ConditionEntry {
  const ConditionEntry({
    required this.id,
    required this.name,
    required this.group,
    this.aliases = const [],
    required this.whatItIs,
    required this.reassurance,
    required this.howCommon,
    required this.symptoms,
    required this.callNow,
    this.justMonitor = const [],
    required this.testsToConfirm,
    required this.management,
    required this.babyImpact,
    required this.faqs,
    this.showMedicine = false,
    this.showReadMore = false,
    this.showWatch = false,
    this.watchEpisodes = 1,
    this.highAnxiety = false,
    this.pregSignal,
  });

  final String id;
  final LocalizedText name;
  final ConditionGroup group;

  /// Other words she might type into the search box for this condition.
  final List<String> aliases;

  final LocalizedText whatItIs;

  /// ⚠️ REQUIRED, ONE LINE. The scale-setting sentence that comes with the
  /// definition, not after it — "how worried should I be" from
  /// `kPgUnderstandCondition` is the question this answers.
  final LocalizedText reassurance;

  final LocalizedText howCommon;
  final List<LocalizedText> symptoms;

  /// What should make her pick up the phone today.
  final List<LocalizedText> callNow;

  /// What is normal to simply keep an eye on. Empty for anything that has no
  /// "watch and wait" tier — a condition that is entirely call-now does not
  /// get a padded monitoring list invented for symmetry.
  final List<LocalizedText> justMonitor;

  final List<LocalizedText> testsToConfirm;
  final LocalizedText management;
  final LocalizedText babyImpact;
  final List<ConditionFaq> faqs;

  /// The three conditional foot sections — §"ONLY where genuinely relevant".
  /// See the seeding notes below each group for which conditions earn which,
  /// and why a mild one may earn none at all.
  final bool showMedicine;
  final bool showReadMore;
  final bool showWatch;

  /// How many films the Watch slot will eventually hold.
  ///
  /// ⚠️ 1 IS A VIDEO; MORE THAN 1 IS A SERIES, AND THEY LOOK DIFFERENT.
  /// Review: "it can be a video series too — in that case show only one video
  /// with ¼ as YT does, and clicking it opens the playlist." So this is not a
  /// cosmetic count: it decides whether the top of the page promises five
  /// minutes or forty, which is a thing she is entitled to know before she
  /// starts. Conditions managed over months earn a series; a one-visit scare
  /// does not.
  final int watchEpisodes;

  /// Miscarriage and preeclampsia. Governs tone: no product, no upsell, and
  /// — for miscarriage specifically — no cheerful language anywhere on the
  /// page, including the empty states of its (absent) conditional sections.
  final bool highAnxiety;

  /// ⚠️ THE BRIDGE TO THE APP'S REAL PERSONALISATION AXIS, AND THE REASON THIS
  /// FIELD HAD TO EXIST.
  ///
  /// "Add to my journey" used to write into a `Set<String>` inside
  /// `ConditionsStore` that **nothing anywhere read**. The button changed its
  /// own label to "Added to your journey" and that was the entire effect — a
  /// promise of personalisation with no personalisation behind it.
  ///
  /// The app already had the right home for this signal:
  /// `FamilyProfileStore.pregConditions`, which `veda_context.dart` feeds into
  /// every Ask Veda question and which `matchesSignal` / `orderByPregPriority`
  /// exist to rank content by. What went wrong is a shape worth naming,
  /// because it is how a codebase grows two answers to one question: a new
  /// section needed "which conditions does she have", did not find it, and
  /// built its own — so the app now held that fact twice, and the copy that
  /// anything consumed was the one the new section never wrote to.
  ///
  /// ⚠️ NULL IS A REAL ANSWER. `PregCondition` has seven values and this
  /// library has twenty-seven conditions; ICP, HELLP and dengue have no
  /// counterpart. A null signal means "we keep her note locally and send
  /// nothing downstream" — which is honest — rather than forcing every
  /// condition into the nearest enum value, which would tell Ask Veda she has
  /// something she does not.
  final PregCondition? pregSignal;

  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    if (name.en.toLowerCase().contains(q)) return true;
    return aliases.any((a) => a.toLowerCase().contains(q));
  }
}

// -----------------------------------------------------------------------------
//  Most common — 8, full treatment
// -----------------------------------------------------------------------------
//  ⚠️ MEDICINE/READ/WATCH HERE ARE NOT UNIFORM ACROSS THE EIGHT. Gestational
//  diabetes, thyroid, anaemia, PCOS, hyperemesis and raised BP are usually
//  managed with a daily medicine or supplement, so the reminder question
//  belongs on their pages. Placenta previa and ectopic pregnancy are not — the
//  first is activity and monitoring, the second is a same-visit decision
//  between a clinician and her — so asking "have you been advised any
//  medicine for this?" on either would be a question with no honest answer to
//  give. Both still get a read and a watch card, because there is genuinely
//  more to learn calmly once the scare has passed.
final List<ConditionEntry> kCommonConditions = [
  ConditionEntry(
    id: 'gdm',
    name: _en('Gestational diabetes'),
    group: ConditionGroup.common,
    aliases: ['gdm', 'blood sugar', 'sugar in pregnancy', 'diabetes'],
    whatItIs: _en('Gestational diabetes means your blood sugar has gone above '
        'the usual range because of pregnancy hormones, not because you had '
        'diabetes before.'),
    reassurance: _en('It is one of the most common things flagged in Indian '
        'pregnancies, and with food changes and monitoring most women manage '
        'it well and deliver healthy babies.'),
    howCommon: _en('Studies across Indian cities put it at around 1 in 6 to 1 '
        'in 7 pregnancies, higher than in most Western countries — Indian '
        'guidelines actually test for it earlier because of this.'),
    symptoms: [
      _en('Usually none at all — this is why every pregnant woman in India is '
          'tested for it, not just those with symptoms.'),
      _en('Occasionally more thirst, more frequent urination, or tiredness.'),
    ],
    callNow: [
      _en('You feel shaky, sweaty, confused or faint after starting '
          'medicine — this can mean your sugar has dropped too low.'),
      _en('You have not felt your baby move as usual.'),
    ],
    justMonitor: [
      _en('A single slightly high home reading — one number rarely changes '
          'the plan; a pattern over days does.'),
    ],
    testsToConfirm: [
      _en('OGTT / glucose challenge test, usually between 24 and 28 weeks.'),
      _en('Fasting and post-meal sugar checks once it is confirmed.'),
      _en('HbA1c, in some cases, to see the recent average.'),
    ],
    management: _en('Most women manage it with diet changes alone — smaller, '
        'more frequent meals, less refined sugar and rice, more fibre. Some '
        'need metformin tablets or insulin injections as well, decided by '
        'your doctor from your readings, not by how you feel.'),
    babyImpact: _en('Well-managed GDM has very little effect on your baby. '
        'Left unchecked, it can mean a larger baby and a higher chance of a '
        'caesarean, which is exactly why it is tracked so closely.'),
    faqs: [
      ConditionFaq(
        question: _en('Does this mean I will have diabetes after pregnancy?'),
        answer: _en('For most women, sugar returns to normal after delivery. '
            'You will usually be asked to repeat the test around 6 weeks '
            'after birth, and again every so often after that.'),
      ),
      ConditionFaq(
        question: _en('Can I still have a normal delivery?'),
        answer: _en('Yes, in most cases. The decision is based on your '
            "baby's size and your readings closer to your due date, not on "
            'having GDM by itself.'),
      ),
      ConditionFaq(
        question: _en('Will my next baby have this too?'),
        answer: _en('The chance is higher than for someone who never had it, '
            'which is why doctors test early in a next pregnancy — but it is '
            'not certain, and many women do not get it again.'),
      ),
    ],
    showMedicine: true,
    showReadMore: true,
    showWatch: true,
    pregSignal: PregCondition.gestationalDiabetes,
    watchEpisodes: 4,
  ),
  ConditionEntry(
    id: 'thyroid',
    name: _en('Thyroid in pregnancy'),
    group: ConditionGroup.common,
    aliases: ['thyroid', 'tsh', 'hypothyroid', 'hyperthyroid'],
    whatItIs: _en('Your thyroid gland can run slightly under or over its '
        'usual level in pregnancy — most often under (hypothyroid), which is '
        'the one screened for routinely in India.'),
    reassurance: _en('It is extremely common and, once your levels are '
        'known, straightforward to correct with a daily tablet.'),
    howCommon: _en('Thyroid problems are picked up in a meaningful share of '
        'Indian pregnancies, partly because iodine levels vary a lot by '
        'region — it is one of the most routinely tested things in the '
        'country.'),
    symptoms: [
      _en('Often none — many women feel entirely normal.'),
      _en('Unusual tiredness, feeling cold, or slower weight gain (under-'
          'active).'),
      _en('A racing heartbeat, feeling too warm, or trouble sleeping (over-'
          'active).'),
    ],
    callNow: [
      _en('A fast or irregular heartbeat that does not settle.'),
      _en('Swelling in your neck that is growing quickly, or trouble '
          'swallowing.'),
    ],
    justMonitor: [
      _en('Mild tiredness alone — very common in pregnancy for reasons that '
          'have nothing to do with the thyroid.'),
    ],
    testsToConfirm: [
      _en('TSH blood test, and free T3/T4 if TSH is out of range.'),
      _en('Thyroid antibody test, in some cases, to see the likely cause.'),
    ],
    management: _en('Underactive thyroid is treated with a daily levothyroxine '
        'tablet, taken on an empty stomach and adjusted every few weeks from '
        'your blood test. Overactive thyroid is managed differently and more '
        'closely by your doctor. Either way, it is one of the more easily '
        'corrected things on this list.'),
    babyImpact: _en('Untreated thyroid problems can affect a baby\'s growth '
        'and, rarely, their own development — which is exactly why it is '
        'checked and corrected early rather than left to see.'),
    faqs: [
      ConditionFaq(
        question: _en('Do I need to keep taking the tablet after delivery?'),
        answer: _en('Sometimes yes, sometimes no — your doctor will retest '
            'a few weeks after birth and decide from there.'),
      ),
      ConditionFaq(
        question: _en('Can I take my thyroid tablet with my prenatal '
            'vitamins?'),
        answer: _en('Iron and calcium can block how well the tablet '
            'absorbs, so most doctors ask for a gap of a few hours between '
            'them. Follow your own doctor\'s timing.'),
      ),
    ],
    showMedicine: true,
    showReadMore: true,
    showWatch: true,
    pregSignal: PregCondition.thyroid,
    watchEpisodes: 2,
  ),
  ConditionEntry(
    id: 'anemia',
    name: _en('Anemia'),
    group: ConditionGroup.common,
    aliases: ['anemia', 'anaemia', 'low hemoglobin', 'iron deficiency', 'hb low'],
    whatItIs: _en('Anemia means your haemoglobin, the part of your blood that '
        'carries oxygen, is lower than it should be — almost always because '
        'of low iron in pregnancy.'),
    reassurance: _en('It is the single most common thing flagged in Indian '
        'pregnancies, and it responds well to iron, whether in food or '
        'tablets.'),
    howCommon: _en('A large majority of pregnant women in India are anaemic '
        'to some degree, which is why iron and folic acid tablets are given '
        'as routine, not just to those already low.'),
    symptoms: [
      _en('Tiredness that feels more than usual pregnancy fatigue.'),
      _en('Pale skin, lips or nail beds.'),
      _en('Breathlessness on mild exertion, dizziness, or a fast heartbeat.'),
    ],
    callNow: [
      _en('Breathlessness even at rest, or chest pain.'),
      _en('Fainting, or a heartbeat that feels very fast or irregular.'),
    ],
    justMonitor: [
      _en('Mild tiredness with a haemoglobin only slightly under range — '
          'usually just means continuing your iron and re-checking.'),
    ],
    testsToConfirm: [
      _en('CBC (complete blood count) — the haemoglobin number itself.'),
      _en('Ferritin, in some cases, to see your iron stores specifically.'),
    ],
    management: _en('Iron-rich food — leafy greens, jaggery, dates, meat and '
        'eggs where eaten — alongside a daily iron and folic acid tablet is '
        'the usual first step. Vitamin C alongside a meal helps iron absorb '
        'better; tea and coffee close to a meal block it. If levels are very '
        'low, an iron infusion may be suggested instead of tablets.'),
    babyImpact: _en('Well-corrected anemia has little effect on your baby. '
        'Severe, untreated anemia can affect your baby\'s growth and raise '
        'risks around delivery, which is why it is treated rather than '
        'lived with.'),
    faqs: [
      ConditionFaq(
        question: _en('Why do iron tablets upset my stomach?'),
        answer: _en('Constipation and nausea are common with iron. Taking it '
            'with food, splitting the dose, or switching brands often '
            'helps — ask your doctor rather than stopping it.'),
      ),
      ConditionFaq(
        question: _en('Can I fix this with diet alone?'),
        answer: _en('Food helps, but most Indian diets alone cannot close a '
            'real deficiency fast enough during pregnancy, which is why a '
            'tablet is usually added rather than relied on instead of food.'),
      ),
    ],
    showMedicine: true,
    showReadMore: true,
    showWatch: true,
    pregSignal: PregCondition.anemia,
  ),
  ConditionEntry(
    id: 'pcos',
    name: _en('PCOS and pregnancy'),
    group: ConditionGroup.common,
    aliases: ['pcos', 'pcod', 'polycystic ovaries'],
    whatItIs: _en('If you had PCOS before conceiving, it does not go away in '
        'pregnancy — but it also does not automatically cause problems. It '
        'mainly means your doctor watches a little more closely for a few '
        'related things.'),
    reassurance: _en('Most women with PCOS carry perfectly ordinary '
        'pregnancies once they have conceived; the extra watching is '
        'precaution, not prediction.'),
    howCommon: _en('PCOS is thought to affect roughly 1 in 5 women of '
        'reproductive age in India, so this is a routine, well-understood '
        'part of many antenatal files.'),
    symptoms: [
      _en('No pregnancy-specific symptoms of its own — the watching happens '
          'through readings and scans, not how you feel.'),
    ],
    callNow: [
      _en('Any of the standard warning signs for gestational diabetes or '
          'raised blood pressure — see those pages, since PCOS raises the '
          'chance of both slightly.'),
    ],
    justMonitor: [],
    testsToConfirm: [
      _en('Earlier or repeated glucose testing, since GDM is somewhat more '
          'common with PCOS.'),
      _en('Routine blood pressure checks at every visit.'),
    ],
    management: _en('Mostly the same antenatal care as any pregnancy, with '
        'slightly closer attention to blood sugar and blood pressure. If you '
        'were on metformin or other PCOS medicine before conceiving, do not '
        'stop or continue it without your doctor confirming which is safe '
        'now.'),
    babyImpact: _en('PCOS by itself does not harm your baby. The related '
        'conditions it makes slightly more likely, gestational diabetes and '
        'raised BP, are the ones actually being watched for.'),
    faqs: [
      ConditionFaq(
        question: _en('Does PCOS mean a higher chance of miscarriage?'),
        answer: _en('Population studies show a somewhat higher rate in the '
            'first trimester, but the large majority of PCOS pregnancies '
            'continue normally — this is not a personal prediction about '
            'yours.'),
      ),
    ],
    showMedicine: true,
    showReadMore: true,
    showWatch: true,
  ),
  ConditionEntry(
    id: 'hyperemesis',
    name: _en('Hyperemesis'),
    group: ConditionGroup.common,
    aliases: ['hyperemesis', 'hg', 'severe vomiting', 'severe nausea'],
    whatItIs: _en('Hyperemesis gravidarum is morning sickness taken much '
        'further — vomiting so frequent it stops you keeping down food or '
        'fluids, rather than the queasiness most pregnancies have.'),
    reassurance: _en('It is uncomfortable and frightening while it lasts, '
        'but it is treatable, and it does not mean anything is wrong with '
        'your baby.'),
    howCommon: _en('Ordinary morning sickness affects most pregnancies; this '
        'more severe form affects roughly 1 to 3 in 100, most often in the '
        'first trimester.'),
    symptoms: [
      _en('Vomiting several times a day, unable to keep food or water down.'),
      _en('Losing weight rather than gaining it.'),
      _en('Dizziness, a racing heart, or very dark urine — signs of '
          'dehydration.'),
    ],
    callNow: [
      _en('You cannot keep any fluids down for more than a day.'),
      _en('Dizziness on standing, a racing heart, or very little urine.'),
      _en('Blood in your vomit, or severe abdominal pain.'),
    ],
    justMonitor: [
      _en('Nausea that comes and goes but still lets you eat and drink '
          'something through the day — that is ordinary morning sickness, '
          'not this.'),
    ],
    testsToConfirm: [
      _en('Usually diagnosed from your symptoms and weight loss, not a '
          'single test.'),
      _en('Urine and blood tests to check hydration and rule out other '
          'causes.'),
    ],
    management: _en('Small, frequent, bland meals; ginger; anti-nausea '
        'tablets from your doctor; and, if dehydration is significant, a '
        'short hospital admission for IV fluids. Most women improve by the '
        'second trimester.'),
    babyImpact: _en('When properly managed, hyperemesis does not usually '
        'affect your baby. The risk comes from dehydration and weight loss '
        'going untreated, which is why admission is offered rather than '
        'something to push through alone.'),
    faqs: [
      ConditionFaq(
        question: _en('Is this different from normal morning sickness?'),
        answer: _en('Yes — the difference is severity and whether you can '
            'keep anything down at all, not just how sick you feel.'),
      ),
      ConditionFaq(
        question: _en('Will I need to be admitted?'),
        answer: _en('Some women do, briefly, for fluids — many are managed '
            'at home with medicine and small meals. Your doctor decides '
            'based on hydration, not how bad it feels.'),
      ),
    ],
    showMedicine: true,
    showReadMore: true,
    showWatch: true,
  ),
  ConditionEntry(
    id: 'placenta_previa',
    name: _en('Low-lying placenta / placenta previa'),
    group: ConditionGroup.common,
    aliases: ['placenta previa', 'low lying placenta', 'previa'],
    whatItIs: _en('Your placenta has attached low in the womb, partly or '
        'fully covering the cervix, instead of higher up as usual.'),
    reassurance: _en('Found early, most low-lying placentas move upward on '
        'their own as the womb grows — it is watched, rarely acted on '
        'straight away.'),
    howCommon: _en('Picked up in around 1 in 20 pregnancies at a mid-'
        'pregnancy scan; by the third trimester, the great majority of '
        'those have already moved clear on their own.'),
    symptoms: [
      _en('Usually none — most are found on a routine scan, not from how '
          'you feel.'),
      _en('Painless vaginal bleeding, sometimes the first sign.'),
    ],
    callNow: [
      _en('Any vaginal bleeding, however light — call the same day, do not '
          'wait for your next visit.'),
      _en('Heavy bleeding or pain — go to hospital directly.'),
    ],
    justMonitor: [
      _en('A "low-lying" placenta found before 20 weeks with no bleeding — '
          'this is simply rechecked at a later scan.'),
    ],
    testsToConfirm: [
      _en('Ultrasound, usually the routine anomaly scan around 20 weeks.'),
      _en('A repeat scan around 32 weeks if it was still low.'),
    ],
    management: _en('Mostly watchful waiting with repeat scans, avoiding '
        'strenuous activity and, sometimes, intercourse if advised. If the '
        'placenta is still covering the cervix close to your due date, a '
        'planned caesarean is the usual, safe route rather than labour.'),
    babyImpact: _en('Baby is not directly affected by the placenta\'s '
        'position. The concern is bleeding for you, which is why any '
        'bleeding at all is treated as worth an immediate call.'),
    faqs: [
      ConditionFaq(
        question: _en('Can it move back up on its own?'),
        answer: _en('Yes — most low-lying placentas found in the second '
            'trimester are clear of the cervix by the third, as the lower '
            'part of the womb stretches upward.'),
      ),
      ConditionFaq(
        question: _en('Does this mean I definitely need a caesarean?'),
        answer: _en('Only if it is still covering the cervix close to your '
            'due date. A low placenta that has moved clear can allow a '
            'normal delivery.'),
      ),
    ],
    showReadMore: true,
    showWatch: true,
    pregSignal: PregCondition.lowLyingPlacenta,
  ),
  ConditionEntry(
    id: 'high_bp',
    name: _en('High BP in pregnancy'),
    group: ConditionGroup.common,
    aliases: [
      'high bp',
      'hypertension',
      'gestational hypertension',
      'blood pressure',
    ],
    whatItIs: _en('Gestational hypertension means your blood pressure has '
        'risen above the usual range after 20 weeks, without the protein-in-'
        'urine that marks preeclampsia specifically.'),
    reassurance: _en('It is common, closely monitored, and most women with '
        'it deliver healthy babies with no lasting problem for either of '
        'you.'),
    howCommon: _en('Raised BP in pregnancy is seen in roughly 1 in 12 to 1 '
        'in 15 Indian pregnancies, which is why BP is checked at every '
        'single antenatal visit.'),
    symptoms: [
      _en('Often none — this is exactly why it is checked routinely rather '
          'than only when something feels wrong.'),
      _en('Occasionally headaches or mild swelling, which are common in '
          'pregnancy anyway and not reliable signs on their own.'),
    ],
    callNow: [
      _en('A severe headache that will not ease with rest or paracetamol.'),
      _en('Vision changes — blurring, flashing lights, spots.'),
      _en('Pain just under your ribs, on the right side.'),
      _en('Sudden swelling in your face or hands.'),
    ],
    justMonitor: [
      _en('A single slightly raised reading at a routine check — one '
          'reading is usually repeated, not acted on alone.'),
    ],
    testsToConfirm: [
      _en('Blood pressure readings over more than one visit.'),
      _en('Urine protein test, to rule out preeclampsia.'),
      _en('Blood tests for liver and kidney function, if BP stays raised.'),
    ],
    management: _en('More frequent check-ups, home BP monitoring if asked, '
        'and blood-pressure medicine that is safe in pregnancy if the '
        'numbers stay high. Rest and reduced salt are commonly advised '
        'alongside medicine, not instead of it.'),
    babyImpact: _en('Well-controlled gestational hypertension usually has '
        'little effect. If it worsens toward preeclampsia, it can affect '
        'your baby\'s growth and the timing of delivery, which is the whole '
        'reason it is tracked at every visit.'),
    faqs: [
      ConditionFaq(
        question: _en('Is this the same as preeclampsia?'),
        answer: _en('No — preeclampsia specifically adds protein in your '
            'urine and other signs. This page covers raised BP on its own; '
            'see the Preeclampsia page for that specific condition.'),
      ),
      ConditionFaq(
        question: _en('Will my BP stay high after delivery?'),
        answer: _en('For most women it settles within a few weeks of birth. '
            'You will usually be asked to have it checked again '
            'postpartum.'),
      ),
    ],
    showMedicine: true,
    showReadMore: true,
    showWatch: true,
    pregSignal: PregCondition.hypertension,
    watchEpisodes: 3,
  ),
  ConditionEntry(
    id: 'ectopic',
    name: _en('Ectopic pregnancy'),
    group: ConditionGroup.common,
    aliases: ['ectopic', 'tubal pregnancy'],
    whatItIs: _en('An ectopic pregnancy means the fertilised egg has '
        'implanted outside the womb, almost always in a fallopian tube, '
        'where it cannot grow safely.'),
    reassurance: _en('It is found early in most cases now, from an early '
        'scan or blood test, well before it becomes an emergency.'),
    howCommon: _en('Affects roughly 1 to 2 in 100 pregnancies. It cannot '
        'continue as a normal pregnancy, and it needs medical or surgical '
        'treatment rather than waiting.'),
    symptoms: [
      _en('One-sided lower abdominal pain, often sharp.'),
      _en('Vaginal bleeding that is different from a normal period.'),
      _en('Shoulder-tip pain, dizziness or fainting — signs it needs urgent '
          'attention.'),
    ],
    callNow: [
      _en('Sharp one-sided abdominal pain with bleeding, especially in very '
          'early pregnancy — go to the emergency room, do not wait for an '
          'appointment.'),
      _en('Dizziness, fainting, or shoulder-tip pain — these can mean '
          'internal bleeding and need immediate care.'),
    ],
    justMonitor: [],
    testsToConfirm: [
      _en('Transvaginal ultrasound, to see where the pregnancy has '
          'implanted.'),
      _en('Repeated beta-hCG blood tests, since the pattern of rise matters '
          'as much as one number.'),
    ],
    management: _en('Depending on how early it is found, treatment is '
        'either a medicine (methotrexate) that ends the pregnancy without '
        'surgery, or a surgical procedure to remove it, usually '
        'laparoscopically. This is always a clinical decision made quickly, '
        'not something to research and decide alone.'),
    babyImpact: _en('An ectopic pregnancy cannot continue and cannot become '
        'a viable baby — the tube it has implanted in is not able to '
        'support growth. Treating it protects your health and your future '
        'fertility.'),
    faqs: [
      ConditionFaq(
        question: _en('Will this affect my chances of getting pregnant '
            'again?'),
        answer: _en('Most women who have had one ectopic pregnancy go on to '
            'have normal pregnancies afterwards. Your doctor may suggest an '
            'earlier scan next time to confirm where the pregnancy has '
            'implanted.'),
      ),
    ],
    showReadMore: true,
    showWatch: true,
  ),
];

// -----------------------------------------------------------------------------
//  High-anxiety must-haves — 2, kept quiet and gentle
// -----------------------------------------------------------------------------
final List<ConditionEntry> kHighAnxietyConditions = [
  ConditionEntry(
    id: 'miscarriage',
    name: _en('Miscarriage / pregnancy loss'),
    group: ConditionGroup.highAnxiety,
    aliases: ['miscarriage', 'pregnancy loss', 'bleeding early pregnancy'],
    whatItIs: _en('A miscarriage is the loss of a pregnancy before 20 weeks. '
        'It is one of the most common outcomes in early pregnancy, and in the '
        'large majority of cases it happens because of a chromosomal issue in '
        'that particular pregnancy, not because of anything you did.'),
    reassurance: _en('If you are here because you are worried, or because it '
        'has happened, none of this was caused by lifting something, '
        'stress, an argument, or travelling. Most women who miscarry go on '
        'to have healthy pregnancies afterwards.'),
    howCommon: _en('Around 1 in 5 to 1 in 6 known pregnancies end this way, '
        'most in the first 12 weeks. It is common enough that it happens to '
        'people all around you, even though it is rarely spoken about.'),
    symptoms: [
      _en('Vaginal bleeding, which can range from light spotting to heavier '
          'bleeding.'),
      _en('Cramping or lower abdominal pain.'),
      _en('A sudden easing of pregnancy symptoms, in some cases.'),
    ],
    callNow: [
      _en('Heavy bleeding, soaking through a pad in an hour or less.'),
      _en('Severe abdominal pain, with or without bleeding.'),
      _en('Fever, or bleeding with a foul smell.'),
      _en('Dizziness or fainting.'),
    ],
    justMonitor: [
      _en('Light spotting with no pain, in early pregnancy, can be common '
          'and harmless — still worth telling your doctor at your next '
          'contact, even if it is not an emergency.'),
    ],
    testsToConfirm: [
      _en('Ultrasound scan, to see the pregnancy directly.'),
      _en('Beta-hCG blood tests, sometimes repeated over a few days.'),
    ],
    management: _en('Care depends on what stage things are at, and is '
        'decided with you, not for you: it can mean waiting for it to '
        'complete naturally, medicine to help it along, or a short '
        'procedure. All three are medically safe options, and your doctor '
        'will talk through what fits your situation.'),
    babyImpact: _en('There is nothing you could have watched for or '
        'prevented. This page will not tell you what caused it — most of '
        'the time, no single cause is ever found, and that is normal too.'),
    faqs: [
      ConditionFaq(
        question: _en('Did I cause this?'),
        answer: _en('Almost certainly not. The overwhelming majority of '
            'early losses happen because of a chromosomal issue in that '
            'pregnancy, which no food, activity, or stress caused or could '
            'have prevented.'),
      ),
      ConditionFaq(
        question: _en('How long should I wait before trying again?'),
        answer: _en('Medically, many doctors say it is safe to try again '
            'after one normal cycle. There is no rule for when you will '
            'feel ready, and that timeline is yours.'),
      ),
      ConditionFaq(
        question: _en('Will this happen again?'),
        answer: _en('For most women, one miscarriage does not mean it will '
            'happen again — the large majority go on to have a healthy '
            'pregnancy next time.'),
      ),
    ],
    highAnxiety: true,
    // ⚠️ NO MEDICINE / READ / WATCH SECTIONS, DELIBERATELY. The spec is
    // explicit here: "gently handled, no product, no upsell, no cheerful
    // language." A coming-soon video card under a page about pregnancy loss
    // is the wrong object in the wrong room, however honest the placeholder.
  ),
  ConditionEntry(
    id: 'preeclampsia',
    name: _en('Preeclampsia'),
    group: ConditionGroup.highAnxiety,
    aliases: ['preeclampsia', 'pre eclampsia', 'toxemia'],
    whatItIs: _en('Preeclampsia is raised blood pressure after 20 weeks '
        'together with protein in your urine or signs that it is affecting '
        'your liver, kidneys or blood — more than raised BP on its own.'),
    reassurance: _en('It is watched for at every single antenatal visit '
        'precisely so it is caught early, when it is very manageable — most '
        'cases are picked up on a routine check, not as a sudden crisis.'),
    howCommon: _en('Affects roughly 3 to 5 in 100 pregnancies worldwide, '
        'somewhat more in first pregnancies. This is exactly why BP and '
        'urine are checked at every visit, whether or not you feel unwell.'),
    symptoms: [
      _en('Often none you would notice yourself — found through routine BP '
          'and urine checks.'),
      _en('A severe headache that does not ease with rest.'),
      _en('Vision changes — blurring, flashing lights, spots.'),
      _en('Swelling that comes on suddenly, especially in the face and '
          'hands.'),
      _en('Pain just under the ribs, usually on the right.'),
    ],
    callNow: [
      _en('A severe headache with vision changes — go to hospital, do not '
          'wait for your next appointment.'),
      _en('Pain under your ribs, or vomiting you have not had before.'),
      _en('Sudden, significant swelling in your face or hands.'),
      _en('Reduced movement from your baby.'),
    ],
    justMonitor: [],
    testsToConfirm: [
      _en('Blood pressure readings over repeated checks.'),
      _en('Urine protein test.'),
      _en('Blood tests for liver, kidney and platelet levels.'),
      _en('Growth scans and Doppler, to check on your baby.'),
    ],
    management: _en('Care depends on how far along you are and how severe it '
        'is: closer monitoring and blood-pressure medicine for milder cases, '
        'hospital admission and, at some point, planned early delivery for '
        'more severe ones — because delivery is the actual treatment for '
        'preeclampsia. Your doctor balances how far along your baby is '
        'against how unwell you are becoming.'),
    babyImpact: _en('Preeclampsia can affect how well your baby grows, which '
        'is why growth scans are added once it is diagnosed. Most babies of '
        'mothers with preeclampsia are born healthy, often a little early, '
        'under close hospital care.'),
    faqs: [
      ConditionFaq(
        question: _en('Is this the same as normal high BP in pregnancy?'),
        answer: _en('No — preeclampsia specifically involves protein in '
            'your urine or signs it is affecting your organs, not just a '
            'raised number. See the "High BP" page for raised BP without '
            'those signs.'),
      ),
      ConditionFaq(
        question: _en('Will I need to deliver early?'),
        answer: _en('Sometimes, yes — delivery is the treatment that '
            'actually resolves preeclampsia. Your doctor times it to '
            'balance your baby\'s development against your own safety.'),
      ),
      ConditionFaq(
        question: _en('Will this happen in my next pregnancy?'),
        answer: _en('The chance is higher than for someone who never had '
            'it, which is why doctors watch more closely from earlier on '
            'next time — but most women who had it once do not have it '
            'again.'),
      ),
    ],
    highAnxiety: true,
    showMedicine: true,
    showReadMore: true,
    showWatch: true,
  ),
];

// -----------------------------------------------------------------------------
//  Placenta & bleeding — 4, brief
// -----------------------------------------------------------------------------
//  Placental abruption is the one genuine emergency in this group — its page
//  stays short on purpose and every conditional foot section is left off, so
//  nothing stands between the page and the "call now" line. The other three
//  are watched-not-treated conditions, so a short "read more" is honest and a
//  medicine question or a video would not be.
final List<ConditionEntry> kPlacentaBleedingConditions = [
  ConditionEntry(
    id: 'placental_abruption',
    name: _en('Placental abruption'),
    group: ConditionGroup.placentaBleeding,
    aliases: ['abruption', 'placenta separation'],
    whatItIs: _en('The placenta has started to separate from the wall of '
        'the womb before your baby is born. This is a medical emergency.'),
    reassurance: _en('It is uncommon, and hospitals are set up to act on it '
        'fast — the outcome depends heavily on getting there quickly, which '
        'is the one thing this page wants you to do.'),
    howCommon: _en('Affects roughly 1 in 100 pregnancies, most often in the '
        'third trimester.'),
    symptoms: [
      _en('Sudden vaginal bleeding, often with pain.'),
      _en('Constant, severe abdominal or back pain, unlike normal '
          'contractions.'),
      _en('The womb feeling unusually firm or tender.'),
    ],
    callNow: [
      _en('Any of the above — go to the nearest hospital emergency '
          'department immediately, do not wait to call first.'),
    ],
    justMonitor: [],
    testsToConfirm: [
      _en('This is diagnosed clinically and by ultrasound, in hospital, as '
          'an emergency, not on a routine visit.'),
    ],
    management: _en('Immediate hospital care. Depending on severity and how '
        'far along you are, this can mean close monitoring or urgent '
        'delivery, usually by caesarean.'),
    babyImpact: _en('This can seriously reduce your baby\'s oxygen supply, '
        'which is why it is treated as an emergency and why speed matters '
        'more than anything else on this page.'),
    faqs: [
      ConditionFaq(
        question: _en('What increases the chance of this?'),
        answer: _en('Raised blood pressure, previous abruption, smoking and '
            'abdominal trauma raise the chance, but it can also happen with '
            'none of these present.'),
      ),
    ],
  ),
  ConditionEntry(
    id: 'iugr',
    name: _en('IUGR (baby growing slowly)'),
    group: ConditionGroup.placentaBleeding,
    aliases: ['iugr', 'fgr', 'small baby', 'growth restriction'],
    whatItIs: _en('IUGR means your baby is measuring smaller than expected '
        'for their stage, usually because the placenta is not passing '
        'through nutrients as efficiently as usual.'),
    reassurance: _en('Many babies flagged as measuring small are simply '
        'small, healthy babies — IUGR is confirmed with growth pattern and '
        'Doppler flow, not a single measurement.'),
    howCommon: _en('Affects roughly 5 to 10 in 100 pregnancies to some '
        'degree.'),
    symptoms: [
      _en('No symptoms you would feel — found on a growth scan.'),
    ],
    callNow: [
      _en('You notice your baby moving noticeably less than usual.'),
    ],
    justMonitor: [
      _en('A single scan measuring a little small — this is followed up '
          'with a repeat scan a few weeks later to see the trend.'),
    ],
    testsToConfirm: [
      _en('Growth ultrasound, tracked over more than one visit.'),
      _en('Doppler scan, to check blood flow through the umbilical cord.'),
    ],
    management: _en('More frequent growth scans and Doppler checks, and '
        'closer kick-count monitoring. Depending on how things trend, this '
        'can lead to earlier delivery if your baby is genuinely better off '
        'outside than in.'),
    babyImpact: _en('The monitoring exists specifically to protect your '
        'baby\'s wellbeing and to time delivery correctly if needed.'),
    faqs: [
      ConditionFaq(
        question: _en('Does this mean something is wrong with my baby?'),
        answer: _en('Not necessarily — many causes are about the placenta '
            'or your own health, not the baby, and some small babies are '
            'simply small and entirely healthy.'),
      ),
    ],
    showReadMore: true,
  ),
  ConditionEntry(
    id: 'low_amniotic_fluid',
    name: _en('Low amniotic fluid'),
    group: ConditionGroup.placentaBleeding,
    aliases: ['oligohydramnios', 'low fluid', 'low amniotic fluid'],
    whatItIs: _en('Oligohydramnios means the fluid cushioning your baby is '
        'lower than the usual range for your stage.'),
    reassurance: _en('Mild cases found late in pregnancy are common and '
        'often need nothing more than closer watching.'),
    howCommon: _en('Affects roughly 4 in 100 pregnancies, more often near '
        'the due date.'),
    symptoms: [
      _en('Usually none — found on a routine growth scan.'),
    ],
    callNow: [
      _en('Fluid leaking or gushing from the vagina — this could be your '
          'waters, and needs same-day assessment.'),
      _en('Reduced movement from your baby.'),
    ],
    justMonitor: [
      _en('A mildly low reading close to your due date, with everything '
          'else normal — often just rechecked.'),
    ],
    testsToConfirm: [
      _en('Ultrasound measurement of amniotic fluid.'),
    ],
    management: _en('More frequent scans and monitoring, staying well '
        'hydrated, and, depending on how far along you are and how low the '
        'fluid is, a discussion about earlier delivery.'),
    babyImpact: _en('Fluid cushions your baby and supports lung development '
        'earlier in pregnancy, which is why the timing of when this is '
        'found matters for how it is handled.'),
    faqs: [
      ConditionFaq(
        question: _en('Can drinking more water help?'),
        answer: _en('Staying well hydrated is commonly advised and can help '
            'a little, but it is not a guaranteed fix — the monitoring '
            'still matters more than the water itself.'),
      ),
    ],
    showReadMore: true,
  ),
  ConditionEntry(
    id: 'polyhydramnios',
    name: _en('Polyhydramnios'),
    group: ConditionGroup.placentaBleeding,
    aliases: ['polyhydramnios', 'excess fluid', 'too much fluid'],
    whatItIs: _en('Polyhydramnios means there is more amniotic fluid around '
        'your baby than the usual range.'),
    reassurance: _en('Most cases are mild and the cause is never fully '
        'known — mild polyhydramnios often needs nothing beyond watching.'),
    howCommon: _en('Affects roughly 1 to 2 in 100 pregnancies.'),
    symptoms: [
      _en('A womb measuring larger than expected for your dates.'),
      _en('Discomfort or breathlessness from the extra size, in more '
          'noticeable cases.'),
    ],
    callNow: [
      _en('Sudden, severe abdominal discomfort or breathlessness.'),
      _en('Contractions that start earlier than expected.'),
    ],
    justMonitor: [
      _en('Mild extra fluid with no discomfort — usually just rechecked at '
          'later scans.'),
    ],
    testsToConfirm: [
      _en('Ultrasound measurement of amniotic fluid.'),
      _en('A glucose test, since it is sometimes linked to blood sugar.'),
    ],
    management: _en('Monitoring, and treating any underlying cause found, '
        'such as gestational diabetes. Rarely, fluid may be drained if it is '
        'causing significant discomfort.'),
    babyImpact: _en('Mild cases usually have no effect on your baby. More '
        'significant polyhydramnios is followed with growth scans, since it '
        'can occasionally point to something else worth checking.'),
    faqs: [
      ConditionFaq(
        question: _en('Does this mean I will go into labour early?'),
        answer: _en('It raises the chance slightly, which is why it is '
            'watched, but most women with mild polyhydramnios carry to term '
            'or close to it.'),
      ),
    ],
    showReadMore: true,
  ),
];

// -----------------------------------------------------------------------------
//  Position & cervix — 2, brief
// -----------------------------------------------------------------------------
final List<ConditionEntry> kPositionCervixConditions = [
  ConditionEntry(
    id: 'breech',
    name: _en('Breech baby'),
    group: ConditionGroup.positionCervix,
    aliases: ['breech', 'baby position', 'bottom first'],
    whatItIs: _en('Breech means your baby is positioned bottom or feet-first '
        'rather than head-down, close to your due date.'),
    reassurance: _en('Very common before 36 weeks — most babies who are '
        'breech earlier turn head-down on their own well before birth.'),
    howCommon: _en('Around 1 in 25 babies are still breech at term, after '
        'the majority turn on their own earlier in the third trimester.'),
    symptoms: [
      _en('No symptoms you would feel — found on examination or scan.'),
    ],
    callNow: [],
    justMonitor: [
      _en('Breech position before 36 weeks — this is simply rechecked '
          'closer to term, since most babies still turn.'),
    ],
    testsToConfirm: [
      _en('Abdominal examination by your doctor.'),
      _en('Ultrasound, to confirm position.'),
    ],
    management: _en('If still breech close to term, options include a '
        'procedure to try to turn your baby (ECV) or a planned caesarean. '
        'Your doctor will discuss which fits your situation.'),
    babyImpact: _en('Breech position on its own does not harm your baby — '
        'it mainly changes the discussion around how you will deliver.'),
    faqs: [
      ConditionFaq(
        question: _en('Can I still have a normal delivery?'),
        answer: _en('It is less common but possible in some hospitals with '
            'the right experience for breech vaginal birth. Most breech '
            'babies in India are delivered by planned caesarean.'),
      ),
    ],
    showReadMore: true,
  ),
  ConditionEntry(
    id: 'cervical_incompetence',
    name: _en('Cervical incompetence'),
    group: ConditionGroup.positionCervix,
    aliases: ['cervical incompetence', 'weak cervix', 'cervical insufficiency'],
    whatItIs: _en('This means your cervix begins to open earlier than it '
        'should, without contractions, raising the chance of an early '
        'delivery.'),
    reassurance: _en('It is uncommon, and where it is known about in '
        'advance, there are effective ways to support the pregnancy.'),
    howCommon: _en('A less common cause of second-trimester loss, more '
        'often picked up after a previous early loss or premature birth.'),
    symptoms: [
      _en('Often none until it is advanced — this is why it is watched '
          'closely if you have a relevant history.'),
      _en('A feeling of pelvic pressure, or spotting, in some cases.'),
    ],
    callNow: [
      _en('Pelvic pressure, spotting or fluid loss, especially before 24 '
          'weeks.'),
    ],
    justMonitor: [],
    testsToConfirm: [
      _en('Cervical length measured by ultrasound.'),
      _en('Your obstetric history — this often guides whether closer '
          'watching starts early.'),
    ],
    management: _en('Depending on your history and scan findings, this can '
        'mean a cervical stitch (cerclage), progesterone support, or closer '
        'monitoring through the second trimester.'),
    babyImpact: _en('The concern is early delivery before your baby is '
        'ready, which is exactly what the monitoring and any treatment aim '
        'to prevent.'),
    faqs: [
      ConditionFaq(
        question: _en('Will I need a stitch in every pregnancy now?'),
        answer: _en('Not necessarily — the decision is made fresh each '
            'pregnancy from your cervical length and history, not applied '
            'automatically.'),
      ),
    ],
    showMedicine: true,
  ),
];

// -----------------------------------------------------------------------------
//  Common discomforts — 3, brief, and genuinely complete without extras
// -----------------------------------------------------------------------------
//  ⚠️ NONE OF THESE GET A CONDITIONAL SECTION. They are mild, self-limiting,
//  and the page itself already says everything there is to say — a "have you
//  been advised medicine" question about piles cream, a read-more rail and a
//  video for something this ordinary would be reaching for inventory the app
//  has rather than answering her.
final List<ConditionEntry> kDiscomfortConditions = [
  ConditionEntry(
    id: 'uti',
    name: _en('UTI (urine infection)'),
    group: ConditionGroup.discomforts,
    aliases: ['uti', 'urine infection', 'urinary tract infection'],
    whatItIs: _en('A urinary tract infection — a bacterial infection, most '
        'often in the bladder, which is common in pregnancy because of '
        'hormonal changes to the urinary tract.'),
    reassurance: _en('Very treatable with a short course of antibiotics '
        'that are safe in pregnancy — the main thing is not to ignore it.'),
    howCommon: _en('Affects around 1 in 10 pregnant women at some point, '
        'which is why a urine test is part of routine antenatal checks.'),
    symptoms: [
      _en('Burning or pain when urinating.'),
      _en('Needing to urinate more often, or urgently.'),
      _en('Cloudy or strong-smelling urine.'),
    ],
    callNow: [
      _en('Fever, chills, or pain in your back or side — this can mean the '
          'infection has reached your kidneys and needs urgent treatment.'),
    ],
    justMonitor: [],
    testsToConfirm: [
      _en('Urine routine/microscopy (R/M) test.'),
      _en('Urine culture, to confirm the bacteria and the right '
          'antibiotic.'),
    ],
    management: _en('A short course of pregnancy-safe antibiotics, finished '
        'in full even once you feel better. Drinking more water and not '
        'holding urine for long stretches helps prevent it recurring.'),
    babyImpact: _en('Treated promptly, a UTI does not affect your baby. Left '
        'untreated, it can spread and raise the chance of early labour, '
        'which is why it is treated rather than waited out.'),
    faqs: [
      ConditionFaq(
        question: _en('Why does pregnancy make this more likely?'),
        answer: _en('Pregnancy hormones relax the tube from your kidneys to '
            'your bladder, which lets bacteria linger more easily than '
            'usual.'),
      ),
    ],
  ),
  ConditionEntry(
    id: 'piles',
    name: _en('Piles (haemorrhoids)'),
    group: ConditionGroup.discomforts,
    aliases: ['piles', 'hemorrhoids', 'haemorrhoids'],
    whatItIs: _en('Piles are swollen veins around the anus, common in '
        'pregnancy because of increased pressure and slower digestion.'),
    reassurance: _en('Uncomfortable, but harmless, and usually settles on '
        'its own or with simple measures — it does not need to be endured '
        'quietly.'),
    howCommon: _en('Very common in the third trimester, and after '
        'delivery, because of the pushing involved in birth.'),
    symptoms: [
      _en('Itching, discomfort or swelling around the anus.'),
      _en('Light bleeding, usually noticed on wiping.'),
    ],
    callNow: [
      _en('Heavy bleeding, or a lump that becomes very painful and does not '
          'settle.'),
    ],
    justMonitor: [],
    testsToConfirm: [
      _en('Usually diagnosed by examination — no special test is normally '
          'needed.'),
    ],
    management: _en('More fibre and water to avoid constipation, a warm '
        'sitz bath, and a pregnancy-safe cream if your doctor suggests one. '
        'Straining less on the toilet helps prevent it worsening.'),
    babyImpact: _en('No effect on your baby at all — this is entirely about '
        'your own comfort.'),
    faqs: [
      ConditionFaq(
        question: _en('Will this go away after delivery?'),
        answer: _en('For most women, yes, over the following weeks, though '
            'the same fibre-and-water habits help it settle faster.'),
      ),
    ],
  ),
  ConditionEntry(
    id: 'varicose_veins',
    name: _en('Varicose veins'),
    group: ConditionGroup.discomforts,
    aliases: ['varicose veins', 'leg veins', 'swollen veins'],
    whatItIs: _en('Enlarged, bulging veins, usually in the legs, caused by '
        'increased blood volume and pressure from the growing womb.'),
    reassurance: _en('Common, cosmetic more than medical in most cases, and '
        'usually improves after delivery.'),
    howCommon: _en('Affects a large share of pregnant women to some degree, '
        'more often later in pregnancy and in later pregnancies.'),
    symptoms: [
      _en('Visible bulging or twisted veins, usually in the legs.'),
      _en('Aching, heaviness or mild swelling by the end of the day.'),
    ],
    callNow: [
      _en('One leg becomes suddenly swollen, red, hot or painful — this '
          'needs same-day attention to rule out a clot.'),
    ],
    justMonitor: [],
    testsToConfirm: [
      _en('Usually diagnosed by examination alone.'),
    ],
    management: _en('Compression stockings, putting your feet up when '
        'possible, and staying active with short walks rather than long '
        'periods of standing or sitting still.'),
    babyImpact: _en('No effect on your baby — this is about your own '
        'comfort, and usually eases within a few months after delivery.'),
    faqs: [
      ConditionFaq(
        question: _en('Are these dangerous?'),
        answer: _en('Ordinary varicose veins are not dangerous. The one '
            'thing to watch for is a leg that suddenly becomes hot, red and '
            'painful, which is different and needs same-day care.'),
      ),
    ],
  ),
];

// -----------------------------------------------------------------------------
//  Specialist / less common — 5, brief; three are urgent, two are managed
// -----------------------------------------------------------------------------
final List<ConditionEntry> kSpecialistConditions = [
  ConditionEntry(
    id: 'fibroids',
    name: _en('Fibroids in pregnancy'),
    group: ConditionGroup.specialist,
    aliases: ['fibroids', 'uterine fibroids'],
    whatItIs: _en('Fibroids are non-cancerous growths in the wall of the '
        'womb. Many women have them without knowing, and pregnancy can make '
        'them grow slightly or cause discomfort.'),
    reassurance: _en('Most fibroids in pregnancy cause no problems at all '
        'and are simply monitored alongside your regular scans.'),
    howCommon: _en('Found in roughly 1 in 10 pregnancies, more often as '
        'maternal age rises.'),
    symptoms: [
      _en('Often none — found incidentally on a scan.'),
      _en('Localised abdominal pain, sometimes, as a fibroid grows or '
          'outgrows its blood supply.'),
    ],
    callNow: [
      _en('Severe, focused abdominal pain that does not ease.'),
    ],
    justMonitor: [
      _en('A fibroid found on scan with no pain — usually just tracked at '
          'routine visits.'),
    ],
    testsToConfirm: [
      _en('Ultrasound, usually the one that found it in the first place.'),
    ],
    management: _en('Mostly monitoring and pain relief if needed. Surgery is '
        'not done during pregnancy except in rare emergencies — any '
        'necessary treatment normally waits until afterwards.'),
    babyImpact: _en('Most fibroids do not affect your baby. Depending on '
        'size and position, some can affect the position your baby settles '
        'into or the way you deliver, which your doctor will factor in '
        'closer to term.'),
    faqs: [
      ConditionFaq(
        question: _en('Will I need surgery to remove it?'),
        answer: _en('Not during pregnancy in almost all cases — this is '
            'usually reviewed and decided afterwards, if at all.'),
      ),
    ],
  ),
  ConditionEntry(
    id: 'icp_cholestasis',
    name: _en('ICP / cholestasis'),
    group: ConditionGroup.specialist,
    aliases: ['icp', 'cholestasis', 'itching pregnancy', 'liver itching'],
    whatItIs: _en('Intrahepatic cholestasis of pregnancy is a liver '
        'condition that causes intense itching, usually on the palms and '
        'soles, without a rash.'),
    reassurance: _en('It is manageable with medicine and closer monitoring '
        'through the rest of your pregnancy.'),
    howCommon: _en('Affects roughly 1 in 100 to 1 in 200 pregnancies in '
        'India, somewhat more than in Western countries.'),
    symptoms: [
      _en('Intense itching, especially on palms and soles, often worse at '
          'night, with no visible rash.'),
      _en('Occasionally darker urine or pale stools.'),
    ],
    callNow: [
      _en('Intense itching with no rash, especially worse at night — this '
          'is the one skin symptom worth a call rather than home '
          'treatment.'),
    ],
    justMonitor: [],
    testsToConfirm: [
      _en('Blood test for bile acid levels.'),
      _en('Liver function tests (LFTs).'),
    ],
    management: _en('Medicine (ursodeoxycholic acid) to ease itching and '
        'support your liver, more frequent monitoring, and often a planned '
        'delivery a little earlier than your due date.'),
    babyImpact: _en('ICP raises the chance of complications for your baby '
        'later in pregnancy, which is why monitoring is closer and delivery '
        'is often planned a little early rather than waiting to go into '
        'labour naturally.'),
    faqs: [
      ConditionFaq(
        question: _en('Is this just normal pregnancy itching?'),
        answer: _en('Ordinary pregnancy itching is common and usually mild, '
            'often with a rash. ICP itching is intense, worse at night, on '
            'palms and soles, and without a rash — that combination is the '
            'one to mention to your doctor.'),
      ),
    ],
    showMedicine: true,
  ),
  ConditionEntry(
    id: 'hellp',
    name: _en('HELLP syndrome'),
    group: ConditionGroup.specialist,
    aliases: ['hellp', 'hellp syndrome'],
    whatItIs: _en('HELLP is a severe, fast-moving complication related to '
        'preeclampsia, affecting your blood and liver. It is a medical '
        'emergency.'),
    reassurance: _en('It is rare, and hospitals recognise and act on it '
        'quickly — the outcome depends on speed, which is why this page '
        'points straight to urgent care.'),
    howCommon: _en('Affects a small fraction of preeclampsia cases, most '
        'often in the third trimester or shortly after delivery.'),
    symptoms: [
      _en('Pain under the ribs, usually on the right.'),
      _en('Nausea or vomiting that feels different from earlier in '
          'pregnancy.'),
      _en('Severe headache, or vision changes.'),
    ],
    callNow: [
      _en('Any of the above, especially if you already have raised BP — go '
          'to the emergency department immediately.'),
    ],
    justMonitor: [],
    testsToConfirm: [
      _en('This is diagnosed in hospital, urgently, through blood tests for '
          'liver enzymes, platelets and red blood cell breakdown.'),
    ],
    management: _en('Hospital admission, close monitoring, and, in almost '
        'all cases, prompt delivery, because delivery is what resolves it.'),
    babyImpact: _en('This can affect your baby if not treated promptly, '
        'which is why hospitals move quickly once it is suspected.'),
    faqs: [
      ConditionFaq(
        question: _en('Is this the same as preeclampsia?'),
        answer: _en('It is closely related and can develop from it, but it '
            'is more severe and specifically involves your blood and liver. '
            'See the Preeclampsia page for the underlying condition.'),
      ),
    ],
  ),
  ConditionEntry(
    id: 'vasa_previa',
    name: _en('Vasa previa'),
    group: ConditionGroup.specialist,
    aliases: ['vasa previa'],
    whatItIs: _en('Vasa previa means unprotected fetal blood vessels are '
        'lying near or across the birth canal, close to the cervix. It is '
        'rare, and dangerous if it is not known about in advance.'),
    reassurance: _en('Found ahead of time on a scan, it is very safely '
        'managed with a planned early caesarean, well before labour '
        'starts.'),
    howCommon: _en('A rare finding, roughly 1 in 2,500 pregnancies, and '
        'increasingly picked up on routine scans rather than in labour.'),
    symptoms: [
      _en('Usually none — this is why it matters that it is looked for on '
          'scan rather than waited for.'),
    ],
    callNow: [
      _en('Painless vaginal bleeding, especially once your waters break — '
          'go to hospital immediately.'),
    ],
    justMonitor: [],
    testsToConfirm: [
      _en('Ultrasound with colour Doppler, usually at the mid-pregnancy '
          'scan.'),
    ],
    management: _en('If found in advance: closer monitoring and a planned '
        'caesarean before labour starts, timed to avoid labour altogether.'),
    babyImpact: _en('If it is not known about and these vessels tear during '
        'labour, it is extremely dangerous for your baby — which is exactly '
        'why finding it on a scan beforehand changes the outcome so '
        'completely.'),
    faqs: [
      ConditionFaq(
        question: _en('Can this be found on a normal scan?'),
        answer: _en('Yes, with attention to the placenta and cord '
            'insertion at your anomaly scan, which is why this is '
            'increasingly caught in advance rather than during labour.'),
      ),
    ],
  ),
  ConditionEntry(
    id: 'rh_negative',
    name: _en('Rh negative pregnancy'),
    group: ConditionGroup.specialist,
    aliases: ['rh negative', 'rhesus negative', 'anti-d'],
    whatItIs: _en('If your blood group is Rh negative and your baby\'s is Rh '
        'positive, your body can develop antibodies against your baby\'s '
        'blood — mainly a concern for a second or later pregnancy, not this '
        'one, if managed.'),
    reassurance: _en('This is well understood and very effectively '
        'prevented with an injection — it is a routine part of care for Rh '
        'negative mothers, not a rare complication.'),
    howCommon: _en('Around 5 to 6 in 100 people in India are Rh negative, so '
        'this is a routine, well-managed part of many antenatal files.'),
    symptoms: [
      _en('No symptoms of your own — this is picked up from your blood '
          'group test, not from how you feel.'),
    ],
    callNow: [],
    justMonitor: [],
    testsToConfirm: [
      _en('Blood group and Rh typing, done early in pregnancy.'),
      _en('Antibody screen, to check whether antibodies have already '
          'formed.'),
    ],
    management: _en('An anti-D injection at around 28 weeks, and again '
        'after delivery if your baby turns out to be Rh positive — this '
        'prevents antibodies from forming in the first place.'),
    babyImpact: _en('Untreated, this can affect a future pregnancy if '
        'antibodies form. The anti-D injection, given on schedule, prevents '
        'that almost entirely.'),
    faqs: [
      ConditionFaq(
        question: _en('Does this affect this pregnancy?'),
        answer: _en('Usually not — the concern is mainly for a future '
            'pregnancy, which is exactly what the anti-D injection is '
            'given to prevent.'),
      ),
    ],
    showMedicine: true,
  ),
];

// -----------------------------------------------------------------------------
//  Pre-existing — 1 combined page, deliberately not split
// -----------------------------------------------------------------------------
//  ⚠️ WHY ONE PAGE AND NOT TWO THIN ONES. Type 1 diabetes and epilepsy in
//  pregnancy are different conditions medically, but the SHAPE of what a
//  mother needs to know is the same: her existing doctor stays in charge,
//  some of her medicines may need review, and pregnancy adds extra
//  monitoring on top of what she already does. Two near-empty pages each
//  saying "talk to your specialist" would have been the padding the spec
//  explicitly warns against.
final List<ConditionEntry> kPreExistingConditions = [
  ConditionEntry(
    id: 'pre_existing',
    name: _en('Pregnancy with a pre-existing condition'),
    group: ConditionGroup.preExisting,
    aliases: [
      'type 1 diabetes',
      'epilepsy',
      'pre-existing condition',
      'chronic condition pregnancy',
    ],
    whatItIs: _en('If you already live with a condition like type 1 '
        'diabetes or epilepsy, pregnancy does not reset that care — it adds '
        'to it. The specialist who already treats you stays in charge; '
        'pregnancy mainly means more frequent monitoring and, sometimes, a '
        'review of which medicines are safest now.'),
    reassurance: _en('Millions of women with pre-existing conditions have '
        'straightforward pregnancies. The extra visits are there to keep it '
        'that way, not because something is expected to go wrong.'),
    howCommon: _en('A meaningful share of pregnancies involve an existing '
        'condition the mother already had before conceiving, which is why '
        'joint care between your specialist and your obstetrician is a '
        'routine pathway, not an unusual one.'),
    symptoms: [
      _en('This depends entirely on your specific condition — the '
          'symptoms you already know to watch for still apply.'),
    ],
    callNow: [
      _en('Any symptom that would normally have sent you to your '
          'specialist before pregnancy still should now — pregnancy does '
          'not change that threshold.'),
    ],
    justMonitor: [],
    testsToConfirm: [
      _en('Whatever tests already track your condition, done more often in '
          'pregnancy — blood sugar for diabetes, medicine levels for '
          'epilepsy, and so on.'),
    ],
    management: _en('Joint care between the specialist who already treats '
        'you and your obstetrician. Some medicines are reviewed and '
        'sometimes changed for pregnancy-safer alternatives — never stop or '
        'switch anything yourself first. Extra scans and check-ups are '
        'usually added on top of your regular antenatal schedule.'),
    babyImpact: _en('Well-controlled pre-existing conditions have '
        'reasonable outcomes for most babies. The added monitoring exists '
        'specifically to catch anything early, both for you and your '
        'baby.'),
    faqs: [
      ConditionFaq(
        question: _en('Should I keep seeing my regular specialist?'),
        answer: _en('Yes — pregnancy adds an obstetrician to your care, it '
            'does not replace the specialist who already knows your '
            'condition.'),
      ),
      ConditionFaq(
        question: _en('Do I need to change my medicines?'),
        answer: _en('Possibly — some medicines are reviewed for pregnancy, '
            'but this is always a specialist decision. Do not stop or '
            'change anything before that conversation.'),
      ),
    ],
    showMedicine: true,
  ),
];

// -----------------------------------------------------------------------------
//  Seasonal & infections — 2, brief
// -----------------------------------------------------------------------------
final List<ConditionEntry> kSeasonalConditions = [
  ConditionEntry(
    id: 'covid_pregnancy',
    name: _en('COVID in pregnancy'),
    group: ConditionGroup.seasonal,
    aliases: ['covid', 'coronavirus', 'covid-19'],
    whatItIs: _en('Catching COVID-19 while pregnant. For most vaccinated, '
        'otherwise healthy women it behaves much like it would outside '
        'pregnancy.'),
    reassurance: _en('The large majority of pregnant women who get COVID '
        'recover at home with rest and fluids, exactly as anyone else '
        'would.'),
    howCommon: _en('Follows the same patterns as the wider population, with '
        'most cases mild, especially in vaccinated women.'),
    symptoms: [
      _en('Fever, cough, sore throat, body aches — the same symptoms as '
          'anyone else.'),
      _en('Loss of taste or smell, in some cases.'),
    ],
    callNow: [
      _en('Breathlessness or chest pain.'),
      _en('Oxygen saturation below 94% on a pulse oximeter, if you have '
          'one.'),
      _en('Reduced movement from your baby.'),
    ],
    justMonitor: [
      _en('Mild fever, cough or sore throat with normal breathing — rest, '
          'fluids and paracetamol as usual, and telling your doctor at '
          'your next contact.'),
    ],
    testsToConfirm: [
      _en('RT-PCR or rapid antigen test.'),
    ],
    management: _en('Rest, fluids, and paracetamol for fever, same as '
        'outside pregnancy. Vaccination is recommended in pregnancy and '
        'lowers the chance of severe illness.'),
    babyImpact: _en('Most babies are unaffected when the mother has mild '
        'COVID. Severe illness in the mother is what carries added risk, '
        'which is why breathlessness on this page is a call-now sign.'),
    faqs: [
      ConditionFaq(
        question: _en('Is the vaccine safe in pregnancy?'),
        answer: _en('Yes — it is recommended in pregnancy and lowers the '
            'chance of severe illness for you.'),
      ),
    ],
    showReadMore: true,
  ),
  ConditionEntry(
    id: 'dengue_pregnancy',
    name: _en('Dengue in pregnancy'),
    group: ConditionGroup.seasonal,
    aliases: ['dengue', 'dengue fever'],
    whatItIs: _en('A mosquito-borne viral fever. In pregnancy it needs '
        'closer monitoring than usual because of its effect on platelets '
        'and fluid balance.'),
    reassurance: _en('Most cases are managed successfully with monitoring '
        'and supportive care — the key is not missing the warning signs.'),
    howCommon: _en('Follows local seasonal outbreaks, same as the wider '
        'population — more common in the monsoon and post-monsoon months in '
        'most of India.'),
    symptoms: [
      _en('High fever, severe headache, pain behind the eyes.'),
      _en('Joint and muscle pain, and a rash in some cases.'),
    ],
    callNow: [
      _en('Bleeding from gums or nose, or bruising easily.'),
      _en('Severe abdominal pain, persistent vomiting.'),
      _en('Reduced urination, or feeling faint.'),
    ],
    justMonitor: [],
    testsToConfirm: [
      _en('NS1 antigen test, in the first few days of fever.'),
      _en('Dengue IgM/IgG antibody test, later in the illness.'),
      _en('Platelet count, tracked over the illness.'),
    ],
    management: _en('Rest, fluids, and paracetamol for fever — never '
        'ibuprofen or aspirin, which raise bleeding risk. Platelet counts '
        'are tracked closely, and hospital admission is common for closer '
        'monitoring in pregnancy even for otherwise mild cases.'),
    babyImpact: _en('Severe dengue can affect a pregnancy, which is why '
        'admission for monitoring is offered more readily in pregnancy than '
        'it might be outside it.'),
    faqs: [
      ConditionFaq(
        question: _en('Can I take paracetamol for the fever?'),
        answer: _en('Yes, paracetamol is the usual choice. Avoid ibuprofen '
            'and aspirin, which can increase bleeding risk in dengue.'),
      ),
    ],
  ),
];

/// Every condition, in one flat list — what the search box and detail lookup
/// both work off.
final List<ConditionEntry> kAllConditions = [
  ...kCommonConditions,
  ...kHighAnxietyConditions,
  ...kPlacentaBleedingConditions,
  ...kPositionCervixConditions,
  ...kDiscomfortConditions,
  ...kSpecialistConditions,
  ...kPreExistingConditions,
  ...kSeasonalConditions,
];

/// The "see more" groups, in display order, common and high-anxiety excluded
/// since those render in their own strips above the toggle.
final Map<ConditionGroup, List<ConditionEntry>> kSeeMoreGroups = {
  ConditionGroup.placentaBleeding: kPlacentaBleedingConditions,
  ConditionGroup.positionCervix: kPositionCervixConditions,
  ConditionGroup.discomforts: kDiscomfortConditions,
  ConditionGroup.specialist: kSpecialistConditions,
  ConditionGroup.preExisting: kPreExistingConditions,
  ConditionGroup.seasonal: kSeasonalConditions,
};

// =============================================================================
//  ConditionsStore — the two-way door answer, and the small per-condition
//  choices made on a detail page
// -----------------------------------------------------------------------------
//  Singleton ChangeNotifier, `shared_preferences`, local-first, fire-and-
//  forget save — the same shape as `CanIStore` and `ReadyBirthContextStore`.
//  No cloud sync: nothing here is clinical data worth merging across devices,
//  it is a UI preference (which door she walked through) plus two small
//  per-condition flags, so the local-only shape those two heavier stores
//  reach for when they need cross-device sync would be more machinery than
//  this earns.
// =============================================================================
class ConditionsStore extends ChangeNotifier {
  ConditionsStore._();
  static final ConditionsStore instance = ConditionsStore._();

  static const _doorKey = 'conditions_door_answer';
  static const _declinedKey = 'conditions_medicine_declined';
  static const _journeyKey = 'conditions_added_to_journey';

  ConditionDoorAnswer _door = ConditionDoorAnswer.unset;
  final Set<String> _medicineDeclined = {};
  final Set<String> _addedToJourney = {};
  bool _loaded = false;

  ConditionDoorAnswer get door => _door;
  bool get isDiagnosed => _door == ConditionDoorAnswer.diagnosed;
  bool get answered => _door != ConditionDoorAnswer.unset;

  bool medicineDeclinedFor(String id) => _medicineDeclined.contains(id);
  bool isAddedToJourney(String id) => _addedToJourney.contains(id);

  Future<void> init() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final d = prefs.getString(_doorKey);
      _door = ConditionDoorAnswer.values
          .firstWhere((e) => e.name == d, orElse: () => ConditionDoorAnswer.unset);
      _medicineDeclined.addAll(prefs.getStringList(_declinedKey) ?? const []);
      _addedToJourney.addAll(prefs.getStringList(_journeyKey) ?? const []);
    } catch (_) {
      // Start with defaults — local-first means an unreadable prefs store
      // behaves like a fresh install, never a crash.
    }
    _loaded = true;
    notifyListeners();
  }

  /// ⚠️ THE GATE ITSELF. `diagnosed` unlocks "add to my journey" on every
  /// condition page; `curious` never shows it. Re-answering (from the small
  /// "change" affordance on the home screen) simply overwrites this — nothing
  /// downstream needs to know she changed her mind, because the only thing
  /// gated on it is a button's visibility.
  void setDoor(ConditionDoorAnswer d) {
    if (_door == d) return;
    _door = d;
    notifyListeners();
    _save(); // fire-and-forget
  }

  /// "No" to the medicine question, for one condition. Persisted so the
  /// question is never asked again for that condition — asking twice after
  /// she has already said no reads as not having listened.
  void declineMedicineFor(String id) {
    if (!_medicineDeclined.add(id)) return;
    notifyListeners();
    _save();
  }

  /// The conditions she has added, as entries, in library order.
  ///
  /// ⚠️ ORDERED BY THE LIBRARY, NOT BY WHEN SHE TAPPED. A set has no order, so
  /// "insertion order" here would be whatever `SharedPreferences` handed back —
  /// stable enough to look deliberate and not actually meaningful. Reading the
  /// library's own order means the strip on the home screen lists them the same
  /// way twice running.
  List<ConditionEntry> get addedConditions =>
      kAllConditions.where((c) => _addedToJourney.contains(c.id)).toList();

  /// ⚠️ THIS NOW WRITES SOMEWHERE THAT IS ACTUALLY READ.
  ///
  /// It used to update a private `Set<String>` and notify — and the only two
  /// readers in the app were the button's own label and its own icon. Tapping
  /// "Add to my journey" changed the words on the button she had just tapped
  /// and did nothing else anywhere. The section promised personalisation and
  /// delivered a checkbox.
  ///
  /// The fix is not a new personalisation engine; it is writing to the one
  /// that already exists. `FamilyProfileStore.pregConditions` is fed into every
  /// Ask Veda question by `veda_context.dart` and is what `matchesSignal` and
  /// `orderByPregPriority` rank content against, so a condition mirrored into
  /// it starts shaping answers immediately, with no consumer to write.
  ///
  /// ⚠️ THE LOCAL SET IS KEPT AS WELL, ON PURPOSE. It is not redundant:
  /// `PregCondition` covers seven things and this library covers twenty-seven,
  /// so the local set is the only record for the twenty-two that have no
  /// downstream signal. Dropping it would mean adding ICP to her journey
  /// silently did nothing at all — the exact bug this method is fixing,
  /// reintroduced from the other side.
  void toggleAddedToJourney(String id) {
    final added = !_addedToJourney.remove(id);
    if (added) _addedToJourney.add(id);
    notifyListeners();
    _save();

    // ⚠️ MIRRORED, NOT MOVED — and only in the direction she just chose.
    //
    // `togglePregCondition` flips, so calling it blindly would invert a
    // condition she set from the Profile screen instead of matching what she
    // just did here. Two screens write the same fact; they must agree on its
    // VALUE, not take turns flipping it.
    final signal = _signalFor(id);
    if (signal == null) return;
    try {
      final fp = FamilyProfileStore.instance;
      if (fp.hasPregCondition(signal) != added) fp.togglePregCondition(signal);
    } catch (_) {
      // Local-first: an unavailable profile store must never stop her saving
      // a note to her own journey. The local set above has already recorded it.
    }
  }

  PregCondition? _signalFor(String id) {
    for (final c in kAllConditions) {
      if (c.id == id) return c.pregSignal;
    }
    return null;
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_doorKey, _door.name);
      await prefs.setStringList(_declinedKey, _medicineDeclined.toList());
      await prefs.setStringList(_journeyKey, _addedToJourney.toList());
    } catch (_) {
      // Best-effort, same as every other local-first store here.
    }
  }
}
