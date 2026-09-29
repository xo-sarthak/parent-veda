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
        // Rewritten 2026-09-29 to docs/PREG-VOICE.md. Preterm labour joined
        // the cervix shelf and five infections joined the seasonal one, so
        // those two titles now say so.
        ConditionGroup.placentaBleeding => _en('Placenta and bleeding'),
        ConditionGroup.positionCervix =>
          _en("Baby's position, cervix and early labour"),
        ConditionGroup.discomforts => _en('Common discomforts'),
        ConditionGroup.specialist => _en('Less common conditions'),
        // ⚠️ THE SHELF AND THE PAGE ON IT MUST NOT SHARE A NAME. This group
        // title used to read "Pregnancy with a pre-existing condition" —
        // exactly the name of the single entry inside it — so the shelf
        // rendered a heading and one card saying the same words twice, which
        // reads as a rendering bug rather than as organisation. The spec's own
        // wording for the shelf is the plural category; the page keeps the
        // longer sentence, because a page is a thing you read and a shelf is a
        // thing you scan. Found by a test asserting each group title appears
        // once.
        ConditionGroup.preExisting => _en('Conditions you had before'),
        ConditionGroup.seasonal => _en('Infections and fevers'),
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
    required this.plainLine,
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
    this.shortAnswer,
  });

  final String id;

  /// The medical name, and the ONLY place one is allowed to stand alone.
  ///
  /// ⚠️ THE COMPLICATIONS BRIEF STATES THE RULE EXACTLY: *"A medical name
  /// appears ONLY as the title of a condition page, because that is what a user
  /// matches to their doctor's words."* Every other heading, label and card we
  /// write is plain. In a browse list the plain phrase leads and the medical
  /// name follows in brackets — never the other way round.
  final LocalizedText name;

  /// One plain line saying what it is, in the words she would use.
  ///
  /// ⚠️ REQUIRED, NOT OPTIONAL, AND THAT IS THE WHOLE POINT. The brief asks for
  /// it under every title and under every browse row. Making it optional would
  /// mean a list where some rows explain themselves and some do not — and the
  /// ones that do not would be exactly the rarer conditions, where a mother is
  /// least likely to know the word.
  ///
  /// ⚠️ TEN OF THESE ARE THE BRIEF'S OWN WORDS, VERBATIM — gestational diabetes
  /// through cord around neck. They are a contract, held by
  /// `test/pv_door_complications_test.dart`. The rest are written to the same
  /// pattern: what it is, in one breath, no jargon, no reassurance. The
  /// reassurance is a separate field doing a separate job.
  ///
  /// ⚠️ IT IS NOT `whatItIs`. That is a paragraph and it is the first thing on
  /// the page; this is a label. "Pregnancy sugar goes high" is not a summary of
  /// the paragraph, it is the sentence somebody would say out loud.
  final LocalizedText plainLine;

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

  /// "The short answer": two or three plain sentences answering the page's
  /// title, for the reader's `PvRead.shortAnswer` box. Added 2026-09-29 from
  /// the pregnancy gap analysis ("Behind · How reads are written", P1).
  /// Optional so a page without one renders exactly as before; the adapter in
  /// `read_adapters.dart` passes it through.
  final LocalizedText? shortAnswer;

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
// Rewritten 2026-09-29 to docs/PREG-VOICE.md: every page speaks to her as
// "you", in short plain sentences, with a short answer on top. Facts, numbers,
// warning signs and their urgency are unchanged. The previous English is in
// git history.
final List<ConditionEntry> kCommonConditions = [
  ConditionEntry(
    id: 'gdm',
    name: _en('Gestational diabetes'),
    plainLine: _en('Pregnancy sugar goes high.'),
    group: ConditionGroup.common,
    aliases: ['gdm', 'blood sugar', 'sugar in pregnancy', 'diabetes'],
    shortAnswer: _en("Gestational diabetes means your blood sugar has gone "
        "higher than usual because of pregnancy hormones. It's common in "
        "India and usually has no symptoms, which is why everyone is tested. "
        "Most women manage it with food changes and regular checks, and have "
        "healthy babies."),
    whatItIs: _en("Your blood sugar has gone above the usual range because of "
        "pregnancy hormones. It isn't because you had diabetes before."),
    reassurance: _en("It's one of the most common things flagged in an Indian "
        "pregnancy. With food changes and regular checks, most women manage "
        "it well and have healthy babies."),
    howCommon: _en("Studies across Indian cities put it at around 1 in 6 to 1 "
        "in 7 pregnancies. That's higher than in most Western countries, "
        "which is why Indian guidelines test for it earlier."),
    symptoms: [
      _en("Usually none at all. That's why every pregnant woman in India is "
          "tested, not only those with symptoms."),
      _en('Sometimes more thirst, needing to pass urine more often, or '
          'tiredness.'),
    ],
    callNow: [
      _en('You feel shaky, sweaty, confused or faint after starting '
          'medicine. This can mean your sugar has dropped too low.'),
      _en("You haven't felt your baby move as usual."),
    ],
    justMonitor: [
      _en('One slightly high reading at home. A single number rarely changes '
          'the plan. A pattern over a few days does.'),
    ],
    testsToConfirm: [
      _en('OGTT (glucose tolerance test) or glucose challenge test, usually '
          'between 24 and 28 weeks.'),
      _en("Fasting and after-meal sugar checks once it's confirmed."),
      _en('HbA1c in some cases, to see your recent average.'),
    ],
    management: _en('Most women manage it with food changes alone: smaller '
        'meals more often, less refined sugar and rice, and more fibre. Some '
        'also need metformin tablets or insulin injections. Your doctor '
        'decides that from your readings, not from how you feel.'),
    babyImpact: _en("Well-managed gestational diabetes has very little effect "
        "on your baby. Left unchecked, it can mean a larger baby and a higher "
        "chance of a caesarean. That's why it's watched so closely."),
    faqs: [
      ConditionFaq(
        question: _en('Will I have diabetes after pregnancy?'),
        answer: _en("For most women, sugar goes back to normal after "
            "delivery. You'll usually be asked to repeat the test around 6 "
            "weeks after birth, and every so often after that."),
      ),
      ConditionFaq(
        question: _en('Can I still have a normal delivery?'),
        answer: _en("Yes, in most cases. The decision depends on your baby's "
            "size and your readings closer to your due date, not on having "
            "gestational diabetes by itself."),
      ),
      ConditionFaq(
        question: _en('Will I get it again in my next pregnancy?'),
        answer: _en("The chance is higher than for someone who never had it, "
            "so doctors test early next time. But it isn't certain, and many "
            "women don't get it again."),
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
    plainLine: _en('The neck gland is off, fixed with a daily tablet.'),
    group: ConditionGroup.common,
    aliases: ['thyroid', 'tsh', 'hypothyroid', 'hyperthyroid'],
    shortAnswer: _en("Your thyroid can run a little low or a little high in "
        "pregnancy, most often low. It's very common in India and is "
        "corrected with one tablet a day. Your doctor sets the dose from "
        "blood tests."),
    whatItIs: _en("Your thyroid gland can run slightly under or over its usual "
        "level in pregnancy. Most often it's under (hypothyroid), which is "
        "the one routinely checked in India."),
    reassurance: _en("It's very common. Once your levels are known, a daily "
        "tablet corrects it."),
    howCommon: _en("Thyroid problems are picked up in a good share of Indian "
        "pregnancies, partly because iodine levels vary a lot from region to "
        "region. It's one of the most routinely tested things in the "
        "country."),
    symptoms: [
      _en('Often none. Many women feel completely normal.'),
      _en('Unusual tiredness, feeling cold, or slower weight gain '
          '(underactive).'),
      _en('A racing heartbeat, feeling too warm, or trouble sleeping '
          '(overactive).'),
    ],
    callNow: [
      _en("A fast or uneven heartbeat that doesn't settle."),
      _en("Swelling in your neck that's growing quickly, or trouble "
          "swallowing."),
    ],
    justMonitor: [
      _en("Mild tiredness on its own. It's very common in pregnancy for "
          "reasons that have nothing to do with your thyroid."),
    ],
    testsToConfirm: [
      _en("TSH blood test, and free T3 and T4 if your TSH is out of range."),
      _en('Thyroid antibody test in some cases, to find the likely cause.'),
    ],
    management: _en("An underactive thyroid is treated with a daily "
        "levothyroxine tablet. You take it on an empty stomach, and the dose "
        "is adjusted every few weeks from your blood test. An overactive "
        "thyroid is managed differently, and more closely, by your doctor. "
        "Either way, it's one of the easier things on this list to correct."),
    babyImpact: _en("Untreated thyroid problems can affect your baby's growth "
        "and, rarely, their development. That's why it's checked and "
        "corrected early rather than left to see."),
    faqs: [
      ConditionFaq(
        question: _en('Will I need the tablet after delivery?'),
        answer: _en('Sometimes yes, sometimes no. Your doctor will test again '
            'a few weeks after birth and decide from there.'),
      ),
      ConditionFaq(
        question: _en('Can I take my thyroid tablet with my pregnancy '
            'vitamins?'),
        answer: _en("Iron and calcium can stop the tablet absorbing well, so "
            "most doctors ask for a gap of a few hours between them. Follow "
            "your own doctor's timing."),
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
    plainLine: _en('Low blood, low iron.'),
    group: ConditionGroup.common,
    aliases: ['anemia', 'anaemia', 'low hemoglobin', 'iron deficiency', 'hb low'],
    shortAnswer: _en("Anaemia means your blood has less haemoglobin than it "
        "should, usually because of low iron. It's the most common finding "
        "in Indian pregnancies, and it responds well to iron from food and "
        "tablets."),
    whatItIs: _en("Anaemia means your haemoglobin, the part of your blood that "
        "carries oxygen, is lower than it should be. In pregnancy it's almost "
        "always because of low iron."),
    reassurance: _en("It's the most common thing flagged in Indian "
        "pregnancies, and it responds well to iron, from food and from "
        "tablets."),
    howCommon: _en("A large majority of pregnant women in India are anaemic to "
        "some degree. That's why iron and folic acid tablets are given to "
        "everyone, not only to those already low."),
    symptoms: [
      _en('Tiredness that feels like more than usual pregnancy tiredness.'),
      _en('Pale skin, lips or nail beds.'),
      _en('Feeling breathless with light effort, dizziness, or a fast '
          'heartbeat.'),
    ],
    callNow: [
      _en('Breathlessness even at rest, or chest pain.'),
      _en('Fainting, or a heartbeat that feels very fast or uneven.'),
    ],
    justMonitor: [
      _en('Mild tiredness with a haemoglobin only slightly under range. This '
          'usually means carrying on with your iron and checking again.'),
    ],
    testsToConfirm: [
      _en('CBC (complete blood count), which gives the haemoglobin number '
          'itself.'),
      _en('Ferritin in some cases, to see your iron stores.'),
    ],
    management: _en("The usual first step is iron-rich food (leafy greens, "
        "jaggery, dates, and meat and eggs if you eat them) alongside a daily "
        "iron and folic acid tablet. Vitamin C with a meal helps iron absorb. "
        "Tea and coffee close to a meal block it. If your levels are very "
        "low, you may be offered iron through a drip (an infusion) instead of "
        "tablets."),
    babyImpact: _en("Well-corrected anaemia has little effect on your baby. "
        "Severe anaemia that isn't treated can affect your baby's growth and "
        "raise risks around delivery. That's why it's treated, not lived "
        "with."),
    faqs: [
      ConditionFaq(
        question: _en('Why do iron tablets upset my stomach?'),
        answer: _en('Constipation and nausea are common with iron. Taking it '
            'with food, splitting the dose or switching brands often helps. '
            'Ask your doctor before you stop it.'),
      ),
      ConditionFaq(
        question: _en('Can I fix this with food alone?'),
        answer: _en("Food helps, but in pregnancy most Indian diets can't "
            "close a real shortfall fast enough. That's why a tablet is "
            "usually added alongside food, not used instead of it."),
      ),
      // Added 2026-09-29 (pregnancy gap analysis, Appendix A, "Types of
      // anemia"): low folate and low B12, which matter in India.
      ConditionFaq(
        question: _en('Is anaemia always about iron?'),
        answer: _en("Mostly, but not always. Low folate (folic acid) or low "
            "vitamin B12 can cause it too. B12 comes mainly from milk, curd, "
            "paneer, eggs, meat and fish, so women who eat little of these, "
            "including many vegetarians, can run low. If your haemoglobin "
            "doesn't rise on iron, your doctor may check your B12 and folate. "
            "Don't start extra supplements without asking."),
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
    plainLine: _en('A hormone imbalance you had before, watched more closely now.'),
    group: ConditionGroup.common,
    aliases: ['pcos', 'pcod', 'polycystic ovaries'],
    shortAnswer: _en("If you had PCOS before, your doctor will watch your "
        "sugar and blood pressure a little more closely. Most women with PCOS "
        "have ordinary pregnancies. The extra checks are a precaution, not a "
        "prediction."),
    whatItIs: _en("If you had PCOS before you conceived, it doesn't go away in "
        "pregnancy. It also doesn't automatically cause problems. It mainly "
        "means your doctor watches a little more closely for a few related "
        "things."),
    reassurance: _en("Most women with PCOS have perfectly ordinary "
        "pregnancies once they've conceived. The extra watching is a "
        "precaution, not a prediction."),
    howCommon: _en("PCOS is thought to affect roughly 1 in 5 women of "
        "childbearing age in India. So it's a routine, well-understood part "
        "of many pregnancy files."),
    symptoms: [
      _en('It has no pregnancy symptoms of its own. The watching happens '
          'through your readings and scans, not through how you feel.'),
    ],
    callNow: [
      _en('Any of the usual warning signs of pregnancy sugar or raised blood '
          'pressure. PCOS raises the chance of both a little, so see those '
          'pages too.'),
    ],
    justMonitor: [],
    testsToConfirm: [
      _en("Earlier or repeated sugar tests, since pregnancy sugar is a bit "
          "more common with PCOS."),
      _en('Blood pressure checks at every visit, as usual.'),
    ],
    management: _en("Mostly the same pregnancy care as anyone else, with a "
        "little closer attention to your blood sugar and blood pressure. If "
        "you were on metformin or another PCOS medicine before conceiving, "
        "don't stop or continue it until your doctor confirms what's safe "
        "now."),
    babyImpact: _en("PCOS by itself doesn't harm your baby. What's watched for "
        "are the two things it makes a little more likely: pregnancy sugar "
        "and raised blood pressure."),
    faqs: [
      ConditionFaq(
        question: _en('Does PCOS mean a higher chance of miscarriage?'),
        answer: _en("Population studies show a somewhat higher rate in the "
            "first trimester. But most PCOS pregnancies continue normally, "
            "and this isn't a prediction about yours."),
      ),
    ],
    showMedicine: true,
    showReadMore: true,
    showWatch: true,
    pregSignal: PregCondition.pcos,
  ),
  ConditionEntry(
    id: 'hyperemesis',
    name: _en('Hyperemesis'),
    plainLine: _en('Severe pregnancy vomiting.'),
    group: ConditionGroup.common,
    aliases: ['hyperemesis', 'hg', 'severe vomiting', 'severe nausea'],
    shortAnswer: _en("Hyperemesis is very severe pregnancy sickness, where you "
        "can't keep food or water down. It's treatable, and it doesn't mean "
        "anything is wrong with your baby. If you can't keep any fluids down "
        "for more than a day, call your doctor."),
    whatItIs: _en("Hyperemesis gravidarum is morning sickness taken much "
        "further. The vomiting is so frequent that you can't keep food or "
        "fluids down, far beyond the queasiness most pregnancies bring."),
    reassurance: _en("It's miserable and frightening while it lasts, but it's "
        "treatable. It doesn't mean anything is wrong with your baby."),
    howCommon: _en('Ordinary morning sickness affects most pregnancies. This '
        'severe form affects roughly 1 to 3 in 100, most often in the first '
        'trimester.'),
    symptoms: [
      _en("Vomiting several times a day, and not being able to keep food or "
          "water down."),
      _en('Losing weight instead of gaining it.'),
      _en('Dizziness, a racing heart, or very dark urine. These are signs of '
          'dehydration.'),
    ],
    callNow: [
      _en("You can't keep any fluids down for more than a day."),
      _en('Dizziness when you stand, a racing heart, or passing very little '
          'urine.'),
      _en('Blood in your vomit, or severe pain in your tummy.'),
    ],
    justMonitor: [
      _en("Nausea that comes and goes but still lets you eat and drink "
          "something through the day. That's ordinary morning sickness, not "
          "hyperemesis."),
    ],
    testsToConfirm: [
      _en("It's usually diagnosed from your symptoms and weight loss, not "
          "from one test."),
      _en('Urine and blood tests, to check how dehydrated you are and rule '
          'out other causes.'),
    ],
    management: _en("Small, frequent, bland meals, ginger, and anti-sickness "
        "tablets from your doctor. If you're quite dehydrated, a short "
        "hospital stay for fluids through a drip (IV fluids). Most women feel "
        "better by the second trimester."),
    babyImpact: _en("When it's properly managed, hyperemesis doesn't usually "
        "affect your baby. The risk comes from dehydration and weight loss "
        "going untreated. That's why a hospital stay is offered, so you "
        "don't have to push through alone."),
    faqs: [
      ConditionFaq(
        question: _en('Is this different from normal morning sickness?'),
        answer: _en('Yes. The difference is how severe it is and whether you '
            'can keep anything down at all, not only how sick you feel.'),
      ),
      ConditionFaq(
        question: _en('Will I need to be admitted?'),
        answer: _en("Some women are, for a short time, for fluids. Many are "
            "looked after at home with medicine and small meals. Your doctor "
            "decides from how dehydrated you are, not from how bad it "
            "feels."),
      ),
      // Added 2026-09-29 (gap analysis, Appendix A, hyperemesis stories): the
      // point those stories make, that asking for treatment is right. A real
      // woman's story is still owed; see the report.
      ConditionFaq(
        question: _en('Should I try to put up with it?'),
        answer: _en("No. Asking for treatment isn't making a fuss. Your "
            "doctor can offer anti-sickness medicine used in pregnancy, and "
            "being able to eat and drink again matters for you both."),
      ),
    ],
    showMedicine: true,
    showReadMore: true,
    showWatch: true,
    pregSignal: PregCondition.hyperemesis,
  ),
  ConditionEntry(
    id: 'placenta_previa',
    name: _en('Low-lying placenta / placenta previa'),
    plainLine: _en('The placenta is sitting low.'),
    group: ConditionGroup.common,
    aliases: ['placenta previa', 'low lying placenta', 'previa'],
    shortAnswer: _en("Your placenta is lower in the womb than usual, near or "
        "over the cervix. Found early, most move up on their own as the womb "
        "grows. Any bleeding at all means calling your doctor the same day."),
    whatItIs: _en('Your placenta has attached low in the womb, partly or fully '
        'covering the cervix (the neck of the womb), instead of higher up as '
        'usual.'),
    reassurance: _en("Found early, most low-lying placentas move up on their "
        "own as the womb grows. It's watched, and rarely acted on straight "
        "away."),
    howCommon: _en("It's picked up in around 1 in 20 pregnancies at a "
        "mid-pregnancy scan. By the third trimester, most of those have "
        "already moved clear on their own."),
    symptoms: [
      _en("Usually none. Most are found on a routine scan, not from how you "
          "feel."),
      _en('Bleeding from the vagina without pain, which is sometimes the '
          'first sign.'),
    ],
    callNow: [
      _en("Any bleeding from the vagina, however light. Call the same day. "
          "Don't wait for your next visit."),
      _en('Heavy bleeding or pain. Go straight to hospital.'),
    ],
    justMonitor: [
      _en('A low-lying placenta found before 20 weeks with no bleeding. This '
          'is checked again at a later scan.'),
    ],
    testsToConfirm: [
      _en('Ultrasound, usually the routine anomaly scan around 20 weeks.'),
      _en('A repeat scan around 32 weeks if it was still low.'),
    ],
    management: _en("Mostly watchful waiting with repeat scans, and avoiding "
        "hard exercise. Sometimes you'll be asked to avoid sex too. If the "
        "placenta is still covering the cervix close to your due date, a "
        "planned caesarean is the usual, safe way to deliver, rather than "
        "labour."),
    babyImpact: _en("Your baby isn't directly affected by where the placenta "
        "sits. The concern is bleeding for you. That's why any bleeding at "
        "all is worth a call straight away."),
    faqs: [
      ConditionFaq(
        question: _en('Can it move up on its own?'),
        answer: _en('Yes. Most low-lying placentas found in the second '
            'trimester are clear of the cervix by the third, as the lower '
            'part of the womb stretches upward.'),
      ),
      ConditionFaq(
        question: _en("Does this mean I'll definitely need a caesarean?"),
        answer: _en("Only if it's still covering the cervix close to your due "
            "date. A placenta that has moved clear can allow a normal "
            "delivery."),
      ),
    ],
    showReadMore: true,
    showWatch: true,
    pregSignal: PregCondition.lowLyingPlacenta,
  ),
  ConditionEntry(
    id: 'high_bp',
    name: _en('High BP in pregnancy'),
    plainLine: _en('Blood pressure needs watching.'),
    group: ConditionGroup.common,
    aliases: [
      'high bp',
      'hypertension',
      'gestational hypertension',
      'blood pressure',
    ],
    shortAnswer: _en("Your blood pressure has gone up after 20 weeks, without "
        "the other signs of preeclampsia. It's common and checked at every "
        "visit. Most women with it have healthy babies."),
    whatItIs: _en('Gestational hypertension means your blood pressure has '
        'risen above the usual range after 20 weeks, without the protein in '
        'your urine that marks preeclampsia.'),
    reassurance: _en("It's common and closely watched. Most women with it have "
        "healthy babies, with no lasting problem for either of you."),
    howCommon: _en("Raised blood pressure is seen in roughly 1 in 12 to 1 in "
        "15 Indian pregnancies. That's why it's checked at every visit."),
    symptoms: [
      _en("Often none. That's why it's checked routinely, not only when "
          "something feels wrong."),
      _en("Sometimes headaches or mild swelling. These are common in "
          "pregnancy anyway, so they aren't reliable signs on their own."),
    ],
    callNow: [
      _en("A severe headache that won't ease with rest or paracetamol."),
      _en('Changes in your vision: blurring, flashing lights or spots.'),
      _en('Pain just under your ribs, on the right side.'),
      _en('Sudden swelling in your face or hands.'),
    ],
    justMonitor: [
      _en('One slightly raised reading at a routine check. A single reading '
          'is usually repeated, not acted on alone.'),
    ],
    testsToConfirm: [
      _en('Blood pressure readings over more than one visit.'),
      _en('A urine test for protein, to rule out preeclampsia.'),
      _en('Blood tests for your liver and kidneys, if your blood pressure '
          'stays raised.'),
    ],
    management: _en("More frequent check-ups, checking your blood pressure at "
        "home if you're asked to, and a blood pressure medicine that's safe "
        "in pregnancy if the numbers stay high. Rest and less salt are often "
        "advised alongside medicine, not instead of it."),
    babyImpact: _en("Well-controlled high blood pressure usually has little "
        "effect on your baby. If it moves towards preeclampsia, it can affect "
        "your baby's growth and when you deliver. That's why it's checked at "
        "every visit."),
    faqs: [
      ConditionFaq(
        question: _en('Is this the same as preeclampsia?'),
        answer: _en('No. Preeclampsia also brings protein in your urine or '
            'other signs. This page is about raised blood pressure on its '
            'own. The Preeclampsia page covers the rest.'),
      ),
      ConditionFaq(
        question: _en('Will my blood pressure stay high after delivery?'),
        answer: _en("For most women it settles within a few weeks of birth. "
            "You'll usually be asked to have it checked again after "
            "delivery."),
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
    plainLine: _en('The pregnancy is growing in the wrong place.'),
    group: ConditionGroup.common,
    aliases: ['ectopic', 'tubal pregnancy'],
    shortAnswer: _en("An ectopic pregnancy is growing outside the womb, "
        "usually in a tube, where it can't grow safely. Today most are found "
        "early on a scan or blood test. Sharp pain on one side with bleeding "
        "means going to the emergency room."),
    whatItIs: _en("An ectopic pregnancy means the fertilised egg has settled "
        "outside the womb, almost always in a fallopian tube, where it can't "
        "grow safely."),
    reassurance: _en('Most are found early now, on an early scan or blood '
        'test, well before it becomes an emergency.'),
    howCommon: _en("It affects roughly 1 to 2 in 100 pregnancies. It can't "
        "continue as a normal pregnancy, so it needs medicine or surgery "
        "rather than waiting."),
    symptoms: [
      _en('Pain low in your tummy on one side, often sharp.'),
      _en("Bleeding from the vagina that's different from a normal period."),
      _en('Pain at the tip of your shoulder, dizziness or fainting. These are '
          'signs it needs urgent care.'),
    ],
    callNow: [
      _en("Sharp pain on one side of your tummy with bleeding, especially in "
          "very early pregnancy. Go to the emergency room. Don't wait for an "
          "appointment."),
      _en('Dizziness, fainting, or pain at the tip of your shoulder. These can '
          'mean bleeding inside, and need care immediately.'),
    ],
    justMonitor: [],
    testsToConfirm: [
      _en('An internal (transvaginal) ultrasound, to see where the pregnancy '
          'has settled.'),
      _en('Repeated beta-hCG blood tests, because how the level rises matters '
          'as much as one number.'),
    ],
    management: _en("It depends on how early it's found. Treatment is either a "
        "medicine (methotrexate) that ends the pregnancy without surgery, or "
        "an operation to remove it, usually by keyhole surgery "
        "(laparoscopy). This is always a medical decision made quickly with "
        "your doctor. It isn't something to research and decide alone."),
    babyImpact: _en("An ectopic pregnancy can't continue and can't become a "
        "baby, because the tube can't support it as it grows. Treating it "
        "protects your health and your future fertility."),
    faqs: [
      ConditionFaq(
        question: _en('Will this affect my chances of getting pregnant '
            'again?'),
        answer: _en('Most women who have had one ectopic pregnancy go on to '
            'have normal pregnancies afterwards. Your doctor may suggest an '
            'early scan next time to check where the pregnancy has '
            'settled.'),
      ),
    ],
    showReadMore: true,
    showWatch: true,
  ),
];

// -----------------------------------------------------------------------------
//  High-anxiety must-haves — 2, kept quiet and gentle
// -----------------------------------------------------------------------------
//  ⚠️ 2026-09-29, gap analysis P1 "Give miscarriage and stillbirth a proper
//  home": this page keeps the facts, in gentler words. Everything after a loss
//  belongs to the "After a loss (pregnancy)" section, which is a new door and
//  the lead's to build; this page should link to it once it exists.
final List<ConditionEntry> kHighAnxietyConditions = [
  ConditionEntry(
    id: 'miscarriage',
    name: _en('Miscarriage / pregnancy loss'),
    plainLine: _en('A pregnancy that ends on its own, early.'),
    group: ConditionGroup.highAnxiety,
    aliases: ['miscarriage', 'pregnancy loss', 'bleeding early pregnancy'],
    shortAnswer: _en("A miscarriage is when a pregnancy ends on its own before "
        "20 weeks. It's common, and it's almost never caused by anything you "
        "did. If you're bleeding heavily, in a lot of pain or feel faint, "
        "call your doctor now."),
    whatItIs: _en("A miscarriage is the loss of a pregnancy before 20 weeks. "
        "It's one of the most common things that happens in early pregnancy. "
        "Most of the time it happens because of a chromosome problem in that "
        "particular pregnancy, not because of anything you did."),
    reassurance: _en("If you're here because you're worried, or because it "
        "has happened, please hear this. It wasn't caused by lifting "
        "something, by stress, by an argument or by travelling. Most women "
        "who miscarry go on to have healthy pregnancies afterwards."),
    howCommon: _en("Around 1 in 5 to 1 in 6 known pregnancies end this way, "
        "most in the first 12 weeks. It happens to many people around you, "
        "even though it's rarely talked about."),
    symptoms: [
      _en('Bleeding from the vagina, from light spotting to heavier '
          'bleeding.'),
      _en('Cramping, or pain low in your tummy.'),
      _en('In some cases, pregnancy symptoms easing suddenly.'),
    ],
    callNow: [
      _en('Heavy bleeding, soaking through a pad in an hour or less.'),
      _en('Severe pain in your tummy, with or without bleeding.'),
      _en('Fever, or bleeding that smells bad.'),
      _en('Dizziness or fainting.'),
    ],
    justMonitor: [
      _en("Light spotting with no pain in early pregnancy can be common and "
          "harmless. Still tell your doctor at your next contact, even if it "
          "isn't an emergency."),
    ],
    testsToConfirm: [
      _en('An ultrasound scan, to see the pregnancy.'),
      _en('Beta-hCG blood tests, sometimes repeated over a few days.'),
    ],
    management: _en("Care depends on what stage things are at, and it's "
        "decided with you, not for you. It can mean waiting for it to "
        "complete naturally, medicine to help it along, or a short "
        "procedure. All three are medically safe, and your doctor will talk "
        "through what fits your situation. You can ask to have someone with "
        "you."),
    babyImpact: _en("There was nothing you could have watched for or "
        "prevented. This page won't tell you what caused it. Most of the "
        "time no single cause is ever found, and that's normal too."),
    faqs: [
      ConditionFaq(
        question: _en('Did I cause this?'),
        answer: _en('Almost certainly not. Most early losses happen because '
            'of a chromosome problem in that pregnancy. No food, activity or '
            'stress caused it, and none of them could have prevented it.'),
      ),
      ConditionFaq(
        question: _en('How long should I wait before trying again?'),
        answer: _en("Medically, many doctors say it's safe to try again after "
            "one normal cycle. There's no rule for when you'll feel ready. "
            "That part is yours."),
      ),
      ConditionFaq(
        question: _en('Will this happen again?'),
        answer: _en("For most women, one miscarriage doesn't mean it will "
            "happen again. Most go on to have a healthy pregnancy next "
            "time."),
      ),
      // Added 2026-09-29 (gap analysis P1): grief named once, then a next
      // step. No cheerful language, per `highAnxiety`.
      ConditionFaq(
        question: _en('Is it normal to feel this sad?'),
        answer: _en("Yes. Grief after a loss is real at any number of weeks, "
            "and partners feel it too. If the sadness stays heavy for weeks, "
            "or you can't sleep or eat, tell your doctor. Support helps."),
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
    plainLine: _en('High blood pressure that starts to affect the rest of you.'),
    group: ConditionGroup.highAnxiety,
    aliases: ['preeclampsia', 'pre eclampsia', 'toxemia', 'aspirin'],
    shortAnswer: _en("Preeclampsia is high blood pressure after 20 weeks that "
        "starts to affect other parts of your body, like your kidneys or "
        "liver. It's checked for at every visit so it's caught early. A "
        "severe headache with changes in your vision means going to "
        "hospital."),
    whatItIs: _en("Preeclampsia is raised blood pressure after 20 weeks "
        "together with protein in your urine, or signs that it's affecting "
        "your liver, kidneys or blood. It's more than raised blood pressure "
        "on its own."),
    reassurance: _en("It's checked for at every visit so it's caught early, "
        "when it's very manageable. Most cases are found on a routine check, "
        "not as a sudden crisis."),
    howCommon: _en("It affects roughly 3 to 5 in 100 pregnancies worldwide, a "
        "little more in first pregnancies. That's why your blood pressure "
        "and urine are checked at every visit, whether or not you feel "
        "unwell."),
    symptoms: [
      _en("Often nothing you'd notice yourself. It's found through routine "
          "blood pressure and urine checks."),
      _en("A severe headache that doesn't ease with rest."),
      _en('Changes in your vision: blurring, flashing lights or spots.'),
      _en('Swelling that comes on suddenly, especially in your face and '
          'hands.'),
      _en('Pain just under your ribs, usually on the right.'),
    ],
    callNow: [
      _en("A severe headache with changes in your vision. Go to hospital. "
          "Don't wait for your next appointment."),
      _en("Pain under your ribs, or vomiting you haven't had before."),
      _en('Sudden, marked swelling in your face or hands.'),
      _en('Your baby moving less than usual.'),
    ],
    justMonitor: [],
    testsToConfirm: [
      _en('Blood pressure readings over repeated checks.'),
      _en('A urine test for protein.'),
      _en('Blood tests for your liver, kidneys and platelets.'),
      _en('Growth scans and Doppler, to check on your baby.'),
    ],
    management: _en("Care depends on how far along you are and how severe it "
        "is. Milder cases mean closer checks and blood pressure medicine. "
        "More severe cases mean a hospital stay and, at some point, a planned "
        "early delivery, because delivery is what treats preeclampsia. Your "
        "doctor weighs how ready your baby is against how unwell you're "
        "becoming."),
    babyImpact: _en("Preeclampsia can affect how well your baby grows, so "
        "growth scans are added once it's diagnosed. Most babies whose "
        "mothers have preeclampsia are born healthy, often a little early, "
        "with close hospital care."),
    faqs: [
      ConditionFaq(
        question: _en('Is this the same as ordinary high blood pressure in '
            'pregnancy?'),
        answer: _en("No. Preeclampsia also involves protein in your urine or "
            "signs it's affecting your organs, not only a raised number. The "
            "High BP page covers raised blood pressure without those signs."),
      ),
      ConditionFaq(
        question: _en('Will I need to deliver early?'),
        answer: _en("Sometimes, yes. Delivery is the treatment that ends "
            "preeclampsia. Your doctor times it to balance your baby's "
            "development against your own safety."),
      ),
      ConditionFaq(
        question: _en('Will this happen in my next pregnancy?'),
        answer: _en("The chance is higher than for someone who never had it, "
            "so doctors watch more closely from earlier on next time. But "
            "most women who had it once don't have it again."),
      ),
      // Added 2026-09-29 (gap analysis, Appendix A, "Ask about aspirin").
      ConditionFaq(
        question: _en('My doctor has prescribed aspirin. Why?'),
        answer: _en("Many doctors prescribe a low dose of aspirin to women at "
            "higher risk of preeclampsia, for example after preeclampsia in "
            "a past pregnancy, or with high blood pressure, diabetes or "
            "kidney disease from before. It's usually started between 12 and "
            "16 weeks and taken every day until late pregnancy, and it lowers "
            "the chance of preeclampsia. Take it exactly as prescribed. Never "
            "start aspirin on your own, and don't stop it without asking your "
            "doctor."),
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
    plainLine: _en('The placenta starts coming away too early.'),
    group: ConditionGroup.placentaBleeding,
    aliases: ['abruption', 'placenta separation'],
    shortAnswer: _en("Placental abruption is when the placenta starts coming "
        "away from the womb before your baby is born. It's uncommon, but it's "
        "an emergency. Sudden bleeding, or constant severe pain in your tummy "
        "or back, means going straight to hospital."),
    whatItIs: _en('The placenta has started to come away from the wall of the '
        'womb before your baby is born. This is a medical emergency.'),
    reassurance: _en("It's uncommon, and hospitals are set up to act on it "
        "fast. Getting there quickly makes the biggest difference, and "
        "that's what this page asks you to do."),
    howCommon: _en('It affects roughly 1 in 100 pregnancies, most often in the '
        'third trimester.'),
    symptoms: [
      _en('Sudden bleeding from the vagina, often with pain.'),
      _en('Constant, severe pain in your tummy or back, unlike normal '
          'contractions.'),
      _en('Your womb feeling unusually hard or tender.'),
    ],
    callNow: [
      _en("Any of the above. Go to the nearest hospital emergency department "
          "immediately. Don't wait to call first."),
    ],
    justMonitor: [],
    testsToConfirm: [
      _en("It's diagnosed in hospital as an emergency, by examination and "
          "ultrasound, not at a routine visit."),
    ],
    management: _en('Hospital care straight away. Depending on how severe it '
        'is and how far along you are, this can mean close monitoring or '
        'urgent delivery, usually by caesarean.'),
    babyImpact: _en("It can seriously reduce your baby's oxygen supply. That's "
        "why it's treated as an emergency, and why speed matters more than "
        "anything else on this page."),
    faqs: [
      ConditionFaq(
        question: _en('What makes this more likely?'),
        answer: _en('High blood pressure, a previous abruption, smoking and a '
            'blow to the tummy raise the chance. It can also happen with none '
            'of these.'),
      ),
    ],
  ),
  ConditionEntry(
    id: 'iugr',
    name: _en('IUGR (baby growing slowly)'),
    plainLine: _en('The baby is measuring smaller than expected.'),
    group: ConditionGroup.placentaBleeding,
    aliases: ['iugr', 'fgr', 'small baby', 'growth restriction'],
    shortAnswer: _en("IUGR means your baby is measuring smaller than expected "
        "on scans. Many babies flagged as small are small and healthy. More "
        "scans show the trend, and your doctor plans from that."),
    whatItIs: _en("IUGR (fetal growth restriction) means your baby is "
        "measuring smaller than expected for their stage. Usually it's "
        "because the placenta isn't passing on nutrients as well as usual."),
    reassurance: _en("Many babies flagged as small are small, healthy babies. "
        "IUGR is confirmed from the growth pattern and a Doppler scan, not "
        "from a single measurement."),
    howCommon: _en('It affects roughly 5 to 10 in 100 pregnancies to some '
        'degree.'),
    symptoms: [
      _en("Nothing you'd feel. It's found on a growth scan."),
    ],
    callNow: [
      _en('Your baby is moving noticeably less than usual.'),
    ],
    justMonitor: [
      _en('One scan measuring a little small. This is followed with a repeat '
          'scan a few weeks later to see the trend.'),
    ],
    testsToConfirm: [
      _en('Growth scans, tracked over more than one visit.'),
      _en('A Doppler scan, to check blood flow through the cord.'),
    ],
    management: _en("More frequent growth scans and Doppler checks, and a "
        "closer watch on your baby's movements. Depending on the trend, this "
        "can lead to an earlier delivery if your baby would be better off "
        "outside than in."),
    babyImpact: _en("All this monitoring is there to protect your baby, and to "
        "time the delivery well if it's needed."),
    faqs: [
      ConditionFaq(
        question: _en('Does this mean something is wrong with my baby?'),
        answer: _en('Not necessarily. Many causes are about the placenta or '
            'your own health, not the baby. And some small babies are small '
            'and completely healthy.'),
      ),
    ],
    showReadMore: true,
    pregSignal: PregCondition.iugr,
  ),
  ConditionEntry(
    id: 'low_amniotic_fluid',
    name: _en('Low amniotic fluid'),
    plainLine: _en('Less water around the baby.'),
    group: ConditionGroup.placentaBleeding,
    aliases: ['oligohydramnios', 'low fluid', 'low amniotic fluid'],
    shortAnswer: _en("Low fluid means there's less water around your baby "
        "than usual for your stage. Mild cases late in pregnancy are common "
        "and are usually watched with more scans. Fluid leaking from the "
        "vagina needs checking the same day."),
    whatItIs: _en('Oligohydramnios means the fluid cushioning your baby is '
        'lower than the usual range for your stage.'),
    reassurance: _en('Mild cases found late in pregnancy are common and often '
        'need nothing more than closer watching.'),
    howCommon: _en('It affects roughly 4 in 100 pregnancies, more often near '
        'the due date.'),
    symptoms: [
      _en("Usually none. It's found on a routine growth scan."),
    ],
    callNow: [
      _en('Fluid leaking or gushing from the vagina. This could be your '
          'waters, and needs checking the same day.'),
      _en('Your baby moving less than usual.'),
    ],
    justMonitor: [
      _en('A slightly low reading close to your due date, with everything '
          'else normal. This is often just checked again.'),
    ],
    testsToConfirm: [
      _en('An ultrasound measurement of the fluid (amniotic fluid).'),
    ],
    management: _en("More frequent scans and checks, and drinking plenty of "
        "water. Depending on how far along you are and how low the fluid is, "
        "your doctor may talk with you about an earlier delivery."),
    babyImpact: _en("The fluid cushions your baby, and earlier in pregnancy it "
        "helps their lungs develop. That's why the timing of when it's found "
        "matters for how it's handled."),
    faqs: [
      ConditionFaq(
        question: _en('Can drinking more water help?'),
        answer: _en("Drinking plenty is commonly advised and can help a "
            "little, but it isn't a guaranteed fix. The monitoring still "
            "matters more than the water."),
      ),
    ],
    showReadMore: true,
  ),
  ConditionEntry(
    id: 'polyhydramnios',
    name: _en('Polyhydramnios'),
    plainLine: _en('More water around the baby than usual.'),
    group: ConditionGroup.placentaBleeding,
    aliases: ['polyhydramnios', 'excess fluid', 'too much fluid'],
    shortAnswer: _en("Polyhydramnios means there's more water around your baby "
        "than usual. Most cases are mild and are watched with later scans. "
        "Sudden, severe discomfort or breathlessness means calling your "
        "doctor."),
    whatItIs: _en("Polyhydramnios means there's more fluid (amniotic fluid) "
        "around your baby than the usual range."),
    reassurance: _en("Most cases are mild and the cause is often never fully "
        "known. Mild cases usually need nothing more than watching."),
    howCommon: _en('It affects roughly 1 to 2 in 100 pregnancies.'),
    symptoms: [
      _en('Your womb measuring bigger than expected for your dates.'),
      _en('Discomfort or breathlessness from the extra size, in more '
          'noticeable cases.'),
    ],
    callNow: [
      _en('Sudden, severe discomfort in your tummy, or breathlessness.'),
      _en('Contractions that start earlier than expected.'),
    ],
    justMonitor: [
      _en('A little extra fluid with no discomfort. This is usually just '
          'checked again at later scans.'),
    ],
    testsToConfirm: [
      _en('An ultrasound measurement of the fluid.'),
      _en("A sugar test, since it's sometimes linked to blood sugar."),
    ],
    management: _en("Monitoring, and treating any cause that's found, such as "
        "pregnancy sugar. Rarely, some fluid is drained if it's causing a lot "
        "of discomfort."),
    babyImpact: _en("Mild cases usually have no effect on your baby. More "
        "marked cases are followed with growth scans, because now and then "
        "they point to something else worth checking."),
    faqs: [
      ConditionFaq(
        question: _en("Does this mean I'll go into labour early?"),
        answer: _en("It raises the chance a little, which is why it's watched. "
            "But most women with mild polyhydramnios carry to term or close "
            "to it."),
      ),
    ],
    showReadMore: true,
  ),
];

// -----------------------------------------------------------------------------
//  Position & cervix — 2, brief; preterm labour added 2026-09-29
// -----------------------------------------------------------------------------
final List<ConditionEntry> kPositionCervixConditions = [
  ConditionEntry(
    id: 'breech',
    name: _en('Breech baby'),
    plainLine: _en('The baby is lying feet-down.'),
    group: ConditionGroup.positionCervix,
    aliases: ['breech', 'baby position', 'bottom first'],
    shortAnswer: _en("Breech means your baby is lying bottom or feet first "
        "instead of head down. Before 36 weeks it's common, and most babies "
        "turn on their own. If your baby is still breech near term, your "
        "doctor will talk you through the options."),
    whatItIs: _en('Breech means your baby is lying bottom or feet first rather '
        'than head down, close to your due date.'),
    reassurance: _en("It's very common before 36 weeks. Most babies who are "
        "breech earlier turn head down on their own well before birth."),
    howCommon: _en('Around 1 in 25 babies are still breech at term. Most turn '
        'on their own earlier in the third trimester.'),
    symptoms: [
      _en("Nothing you'd feel. It's found on examination or a scan."),
    ],
    callNow: [],
    justMonitor: [
      _en('Breech before 36 weeks. This is checked again closer to term, '
          'since most babies still turn.'),
    ],
    testsToConfirm: [
      _en('Your doctor feeling your tummy (abdominal examination).'),
      _en('An ultrasound, to confirm the position.'),
    ],
    management: _en("If your baby is still breech close to term, the options "
        "are a procedure to try to turn your baby from the outside (ECV) or a "
        "planned caesarean. Your doctor will talk through which fits your "
        "situation."),
    babyImpact: _en("Being breech doesn't harm your baby by itself. It mainly "
        "changes the conversation about how you'll deliver."),
    faqs: [
      ConditionFaq(
        question: _en('Can I still have a normal delivery?'),
        answer: _en("It's less common, but possible in some hospitals with "
            "experience of vaginal breech birth. Most breech babies in India "
            "are born by planned caesarean."),
      ),
    ],
    showReadMore: true,
  ),
  ConditionEntry(
    id: 'cervical_incompetence',
    name: _en('Cervical incompetence'),
    plainLine: _en('The neck of the womb opens too early.'),
    group: ConditionGroup.positionCervix,
    aliases: ['cervical incompetence', 'weak cervix', 'cervical insufficiency'],
    shortAnswer: _en("This means the cervix, the neck of the womb, starts to "
        "open too early without contractions. It's uncommon, and when it's "
        "known about in advance there are good ways to support the "
        "pregnancy. Pelvic pressure, spotting or leaking fluid means calling "
        "your doctor."),
    whatItIs: _en('Your cervix (the neck of the womb) starts to open earlier '
        'than it should, without contractions. This raises the chance of an '
        'early delivery.'),
    reassurance: _en("It's uncommon. When it's known about in advance, there "
        "are good ways to support the pregnancy."),
    howCommon: _en("It's a less common cause of loss in the middle months. "
        "It's more often picked up after a previous early loss or early "
        "birth."),
    symptoms: [
      _en("Often none until it's advanced. That's why it's watched closely if "
          "your history points to it."),
      _en('A feeling of pressure in your pelvis, or spotting, in some '
          'cases.'),
    ],
    callNow: [
      _en('Pressure in your pelvis, spotting or leaking fluid, especially '
          'before 24 weeks.'),
    ],
    justMonitor: [],
    testsToConfirm: [
      _en('Measuring the length of your cervix on ultrasound.'),
      _en('Your pregnancy history, which often decides whether closer '
          'watching starts early.'),
    ],
    management: _en('Depending on your history and scans, this can mean a '
        'stitch in the cervix (cerclage), progesterone, or closer monitoring '
        'through the middle months.'),
    babyImpact: _en("The concern is your baby arriving before they're ready. "
        "The monitoring and any treatment aim to prevent that."),
    faqs: [
      ConditionFaq(
        question: _en('Will I need a stitch in every pregnancy now?'),
        answer: _en('Not necessarily. The decision is made fresh each '
            'pregnancy, from the length of your cervix and your history.'),
      ),
    ],
    showMedicine: true,
    pregSignal: PregCondition.cervicalIncompetence,
  ),
  // Added 2026-09-29 (pregnancy gap analysis, Complications, "the conditions
  // both apps cover and we do not"). No `pregSignal`: early labour is an
  // event, not a standing condition, and it must never be inferred as
  // "high risk".
  ConditionEntry(
    id: 'preterm_labour',
    name: _en('Preterm labour'),
    plainLine: _en('Labour that starts before 37 weeks.'),
    group: ConditionGroup.positionCervix,
    aliases: [
      'preterm labour',
      'preterm labor',
      'premature labour',
      'early labour',
      'premature birth',
      'preterm birth',
    ],
    shortAnswer: _en("Preterm labour means labour starting before 37 weeks. "
        "Regular tightenings, period-like cramps or leaking fluid before 37 "
        "weeks mean calling your doctor or going in the same day. If labour "
        "does start early, there are treatments that help your baby."),
    whatItIs: _en("Preterm labour is labour that starts before 37 weeks of "
        "pregnancy. Your womb starts tightening regularly and the cervix "
        "begins to open earlier than planned."),
    reassurance: _en("Many women who have early tightenings don't go on to "
        "deliver early. And when labour does start early, there are "
        "treatments that help your baby, and care for early babies in India "
        "has improved a great deal."),
    howCommon: _en("More than 1 in 10 babies in India are born before 37 "
        "weeks. Most of them are born after 32 weeks, and babies born close "
        "to 37 weeks usually do very well."),
    symptoms: [
      _en('Tightenings that come regularly, every 10 minutes or more often.'),
      _en('Period-like cramps, or a dull ache low in your back that comes and '
          'goes.'),
      _en('Pressure low in your pelvis, as if your baby is pushing down.'),
      _en('A change in discharge: watery, like mucus, or blood-stained.'),
      _en('Fluid leaking, or a gush.'),
    ],
    callNow: [
      _en('Regular tightenings or period-like pain before 37 weeks. Call your '
          'doctor or go to hospital the same day.'),
      _en('Fluid leaking or gushing from the vagina before 37 weeks.'),
      _en('Any bleeding from the vagina.'),
    ],
    justMonitor: [
      _en("Occasional, irregular tightenings that ease when you rest or move. "
          "These are practice contractions (Braxton Hicks) and are common "
          "from the middle months. If you can't tell which you have, call."),
    ],
    testsToConfirm: [
      _en('An internal examination, to see whether the cervix is opening.'),
      _en("A monitor (CTG) to record your tightenings and your baby's "
          "heartbeat."),
      _en('In some hospitals, a swab test (fetal fibronectin) or a scan of '
          'your cervix length, to help show whether birth is likely soon.'),
    ],
    management: _en("It depends on how many weeks you are. Before 34 weeks "
        "you may be given steroid injections to help your baby's lungs "
        "mature, and, if birth is very early, magnesium sulphate to help "
        "protect your baby's brain. Medicine to slow contractions may be used "
        "for a short time, so the steroids can work or so you can move to a "
        "hospital with a newborn unit (NICU). If your waters have broken, "
        "you'll usually be given antibiotics."),
    babyImpact: _en("The earlier a baby is born, the more help they need with "
        "breathing, feeding and keeping warm. Babies born close to 37 weeks "
        "usually do very well. Being born in a hospital with a newborn unit "
        "makes a real difference for an early baby."),
    faqs: [
      ConditionFaq(
        question: _en('What causes it?'),
        answer: _en("Often no cause is found. Infections (including urine "
            "infections), a previous early birth, twins, a short cervix, "
            "bleeding and high blood pressure all raise the chance. Your "
            "ordinary daily activity doesn't cause it."),
      ),
      ConditionFaq(
        question: _en('Can it be stopped?'),
        answer: _en("Sometimes it settles on its own, and sometimes medicine "
            "slows it for a short time. Often the aim isn't to stop it for "
            "weeks. It's to give your baby the steroid injections and get you "
            "to the right hospital."),
      ),
      ConditionFaq(
        question: _en('Will it happen again next time?'),
        answer: _en("The chance is higher after one early birth, so doctors "
            "watch more closely next time, sometimes with cervix scans or "
            "progesterone. Many women carry their next baby to term."),
      ),
    ],
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
    plainLine: _en('A water infection: burning, and needing to go often.'),
    group: ConditionGroup.discomforts,
    aliases: ['uti', 'urine infection', 'urinary tract infection'],
    shortAnswer: _en("A urine infection is common in pregnancy and is treated "
        "with antibiotics that are safe for you and your baby. Burning when "
        "you pass urine is the usual sign. Fever, chills or pain in your back "
        "mean it needs urgent treatment."),
    whatItIs: _en("A urinary tract infection is an infection with bacteria, "
        "most often in the bladder. It's common in pregnancy because hormones "
        "change how your urinary tract works."),
    reassurance: _en("It's easy to treat with a short course of antibiotics "
        "that are safe in pregnancy. The main thing is not to ignore it."),
    howCommon: _en("It affects around 1 in 10 pregnant women at some point. "
        "That's why a urine test is part of your routine pregnancy checks."),
    symptoms: [
      _en('Burning or pain when you pass urine.'),
      _en('Needing to go more often, or urgently.'),
      _en('Cloudy or strong-smelling urine.'),
    ],
    callNow: [
      _en('Fever, chills, or pain in your back or side. This can mean the '
          'infection has reached your kidneys, and it needs urgent '
          'treatment.'),
    ],
    justMonitor: [],
    testsToConfirm: [
      _en('Urine routine and microscopy (R/M) test.'),
      _en('Urine culture, to find the bacteria and the right antibiotic.'),
    ],
    management: _en("A short course of pregnancy-safe antibiotics. Finish the "
        "whole course, even once you feel better. Drinking more water and not "
        "holding urine in for long helps stop it coming back."),
    babyImpact: _en("Treated quickly, a urine infection doesn't affect your "
        "baby. Left untreated, it can spread and raise the chance of early "
        "labour. That's why it's treated rather than waited out."),
    faqs: [
      ConditionFaq(
        question: _en('Why is it more likely in pregnancy?'),
        answer: _en('Pregnancy hormones relax the tubes from your kidneys to '
            'your bladder, so bacteria can linger more easily than usual.'),
      ),
    ],
  ),
  ConditionEntry(
    id: 'piles',
    name: _en('Piles (haemorrhoids)'),
    plainLine: _en('Swollen veins around the back passage.'),
    group: ConditionGroup.discomforts,
    aliases: ['piles', 'hemorrhoids', 'haemorrhoids'],
    shortAnswer: _en("Piles are swollen veins around your back passage. "
        "They're very common late in pregnancy and after birth. They're "
        "uncomfortable but harmless, and fibre, water and a warm sitz bath "
        "usually help."),
    whatItIs: _en("Piles are swollen veins around the anus. They're common in "
        "pregnancy because of extra pressure and slower digestion."),
    reassurance: _en("They're uncomfortable, but harmless. They usually settle "
        "on their own or with a few easy changes, and you don't have to put "
        "up with them in silence."),
    howCommon: _en('Very common in the third trimester, and after delivery '
        'because of the pushing in birth.'),
    symptoms: [
      _en('Itching, soreness or swelling around the anus.'),
      _en('Light bleeding, usually noticed when you wipe.'),
    ],
    callNow: [
      _en("Heavy bleeding, or a lump that becomes very painful and doesn't "
          "settle."),
    ],
    justMonitor: [],
    testsToConfirm: [
      _en('Usually diagnosed by a quick examination. No special test is '
          'normally needed.'),
    ],
    management: _en('More fibre and water to avoid constipation, a warm sitz '
        'bath, and a pregnancy-safe cream if your doctor suggests one. '
        'Straining less on the toilet helps stop them getting worse.'),
    babyImpact: _en('No effect on your baby at all. This is only about your '
        'comfort.'),
    faqs: [
      ConditionFaq(
        question: _en('Will they go away after delivery?'),
        answer: _en('For most women, yes, over the following weeks. The same '
            'fibre and water habits help them settle faster.'),
      ),
    ],
  ),
  ConditionEntry(
    id: 'varicose_veins',
    name: _en('Varicose veins'),
    plainLine: _en('Swollen, achy veins in the legs.'),
    group: ConditionGroup.discomforts,
    aliases: ['varicose veins', 'leg veins', 'swollen veins'],
    shortAnswer: _en("Varicose veins are swollen, achy veins, usually in your "
        "legs. They're common in pregnancy and usually get better after "
        "birth. One leg that's suddenly swollen, red, hot or painful needs a "
        "doctor the same day."),
    whatItIs: _en('These are enlarged, bulging veins, usually in the legs. '
        'They come from the extra blood in pregnancy and the pressure of '
        'your growing womb.'),
    reassurance: _en("They're common, more about looks than health in most "
        "cases, and usually improve after delivery."),
    howCommon: _en('Many pregnant women get them to some degree, more often '
        'later in pregnancy and in later pregnancies.'),
    symptoms: [
      _en('Bulging or twisted veins you can see, usually in your legs.'),
      _en('Aching, heaviness or mild swelling by the end of the day.'),
    ],
    callNow: [
      _en('One leg becomes suddenly swollen, red, hot or painful. This needs a '
          'doctor the same day, to rule out a clot.'),
    ],
    justMonitor: [],
    testsToConfirm: [
      _en('Usually diagnosed by examination alone.'),
    ],
    management: _en('Compression stockings, putting your feet up when you '
        'can, and short walks rather than long spells of standing or sitting '
        'still.'),
    babyImpact: _en('No effect on your baby. This is about your comfort, and '
        'it usually eases within a few months of delivery.'),
    faqs: [
      ConditionFaq(
        question: _en('Are they dangerous?'),
        answer: _en("Ordinary varicose veins aren't dangerous. The one thing "
            "to watch for is a leg that suddenly turns hot, red and painful. "
            "That's different, and needs care the same day."),
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
    plainLine: _en('Harmless lumps in the wall of the womb.'),
    group: ConditionGroup.specialist,
    aliases: ['fibroids', 'uterine fibroids'],
    shortAnswer: _en("Fibroids are harmless lumps in the wall of the womb that "
        "many women have without knowing. Most cause no problems in pregnancy "
        "and are watched on your usual scans. Severe pain in one spot that "
        "doesn't ease means calling your doctor."),
    whatItIs: _en('Fibroids are non-cancerous growths in the wall of the '
        'womb. Many women have them without knowing, and pregnancy can make '
        'them grow a little or cause discomfort.'),
    reassurance: _en("Most fibroids cause no problems in pregnancy. They're "
        "checked alongside your regular scans."),
    howCommon: _en('Found in roughly 1 in 10 pregnancies, more often as a '
        "mother's age rises."),
    symptoms: [
      _en("Often none. They're found by chance on a scan."),
      _en('Sometimes pain in one spot, as a fibroid grows or outgrows its '
          'blood supply.'),
    ],
    callNow: [
      _en("Severe pain in one spot of your tummy that doesn't ease."),
    ],
    justMonitor: [
      _en("A fibroid found on a scan with no pain. It's usually just tracked "
          "at routine visits."),
    ],
    testsToConfirm: [
      _en('Ultrasound, usually the scan that found it.'),
    ],
    management: _en("Mostly monitoring, and pain relief if you need it. "
        "Surgery isn't done in pregnancy except in rare emergencies. Any "
        "treatment usually waits until after the birth."),
    babyImpact: _en("Most fibroids don't affect your baby. Depending on size "
        "and position, some can affect how your baby settles or how you "
        "deliver. Your doctor will think about this closer to term."),
    faqs: [
      ConditionFaq(
        question: _en('Will I need surgery to remove it?'),
        answer: _en("Almost never during pregnancy. It's usually looked at "
            "again after the birth, if at all."),
      ),
    ],
    pregSignal: PregCondition.fibroids,
  ),
  ConditionEntry(
    id: 'icp_cholestasis',
    name: _en('ICP / cholestasis'),
    plainLine: _en('Itching caused by the liver, usually worst on hands and feet.'),
    group: ConditionGroup.specialist,
    aliases: ['icp', 'cholestasis', 'itching pregnancy', 'liver itching'],
    shortAnswer: _en("ICP is a liver condition of pregnancy that causes "
        "intense itching, usually on your palms and soles, with no rash. It's "
        "managed with medicine and closer checks. Itching like this means "
        "calling your doctor, not treating it at home."),
    whatItIs: _en('Intrahepatic cholestasis of pregnancy (ICP) is a liver '
        'condition that causes intense itching, usually on the palms and '
        'soles, without a rash.'),
    reassurance: _en("It's managed with medicine and closer monitoring for the "
        "rest of your pregnancy."),
    howCommon: _en('It affects roughly 1 in 100 to 1 in 200 pregnancies in '
        'India, a bit more than in Western countries.'),
    symptoms: [
      _en('Intense itching, especially on your palms and soles, often worse '
          'at night, with no rash you can see.'),
      _en('Sometimes darker urine or pale stools.'),
    ],
    callNow: [
      _en("Intense itching with no rash, especially if it's worse at night. "
          "This is the one skin symptom to call about rather than treat at "
          "home."),
    ],
    justMonitor: [],
    testsToConfirm: [
      _en('A blood test for bile acids.'),
      _en('Liver function tests (LFTs).'),
    ],
    management: _en('Medicine (ursodeoxycholic acid) to ease the itching and '
        'support your liver, more frequent checks, and often a planned '
        'delivery a little before your due date.'),
    babyImpact: _en("ICP raises the chance of problems for your baby later in "
        "pregnancy. That's why checks are closer, and delivery is often "
        "planned a little early rather than waiting for labour."),
    faqs: [
      ConditionFaq(
        question: _en('Is this just normal pregnancy itching?'),
        answer: _en("Ordinary pregnancy itching is common and usually mild, "
            "often with a rash. ICP itching is intense, worse at night, on "
            "your palms and soles, and has no rash. That combination is the "
            "one to tell your doctor about."),
      ),
    ],
    showMedicine: true,
    pregSignal: PregCondition.cholestasis,
  ),
  ConditionEntry(
    id: 'hellp',
    name: _en('HELLP syndrome'),
    plainLine: _en('A severe form of high blood pressure that affects blood and liver.'),
    group: ConditionGroup.specialist,
    aliases: ['hellp', 'hellp syndrome'],
    shortAnswer: _en("HELLP syndrome is a rare, severe condition linked to "
        "preeclampsia that affects your blood and liver. It's an emergency. "
        "Pain under your right ribs, new sickness or a severe headache, "
        "especially with high blood pressure, means going to the emergency "
        "department immediately."),
    whatItIs: _en("HELLP is a severe, fast-moving complication linked to "
        "preeclampsia. It affects your blood and liver, and it's a medical "
        "emergency."),
    reassurance: _en("It's rare, and hospitals recognise it and act quickly. "
        "Speed matters most, which is why this page points you straight to "
        "urgent care."),
    howCommon: _en('It affects a small share of women with preeclampsia, most '
        'often in the third trimester or soon after delivery.'),
    symptoms: [
      _en('Pain under your ribs, usually on the right.'),
      _en('Nausea or vomiting that feels different from earlier in '
          'pregnancy.'),
      _en('A severe headache, or changes in your vision.'),
    ],
    callNow: [
      _en('Any of the above, especially if you already have high blood '
          'pressure. Go to the emergency department immediately.'),
    ],
    justMonitor: [],
    testsToConfirm: [
      _en("It's diagnosed urgently in hospital, with blood tests for liver "
          "enzymes, platelets and the breakdown of red blood cells."),
    ],
    management: _en('A hospital stay, close monitoring and, in almost all '
        'cases, prompt delivery, because delivery is what ends it.'),
    babyImpact: _en("It can affect your baby if it isn't treated quickly. "
        "That's why hospitals move fast once it's suspected."),
    faqs: [
      ConditionFaq(
        question: _en('Is this the same as preeclampsia?'),
        answer: _en("It's closely linked and can develop from it, but it's "
            "more severe and affects your blood and liver. The Preeclampsia "
            "page explains the condition underneath."),
      ),
    ],
  ),
  ConditionEntry(
    id: 'vasa_previa',
    name: _en('Vasa previa'),
    plainLine: _en('Blood vessels crossing the exit of the womb.'),
    group: ConditionGroup.specialist,
    aliases: ['vasa previa'],
    shortAnswer: _en("Vasa previa means some of your baby's blood vessels run "
        "near or across the opening of the womb. It's rare. When it's found "
        "on a scan, a planned caesarean before labour keeps your baby safe."),
    whatItIs: _en("Vasa previa means some of your baby's blood vessels, "
        "without their usual protection, lie near or across the birth canal, "
        "close to the cervix. It's rare, and dangerous if it isn't known "
        "about in advance."),
    reassurance: _en("When it's found ahead of time on a scan, it's managed "
        "very safely with a planned early caesarean, well before labour "
        "starts."),
    howCommon: _en("It's rare, roughly 1 in 2,500 pregnancies, and more and "
        "more often found on routine scans rather than in labour."),
    symptoms: [
      _en("Usually none. That's why it matters that it's looked for on a "
          "scan."),
    ],
    callNow: [
      _en('Bleeding from the vagina without pain, especially once your waters '
          'break. Go to hospital immediately.'),
    ],
    justMonitor: [],
    testsToConfirm: [
      _en('Ultrasound with colour Doppler, usually at the mid-pregnancy '
          'scan.'),
    ],
    management: _en("If it's found in advance: closer monitoring and a planned "
        "caesarean before labour starts, timed to avoid labour altogether."),
    babyImpact: _en("If it isn't known about and the vessels tear during "
        "labour, it's extremely dangerous for your baby. That's why finding "
        "it on a scan beforehand changes the outcome so completely."),
    faqs: [
      ConditionFaq(
        question: _en('Can a normal scan find it?'),
        answer: _en("Yes, when the placenta and the place where the cord joins "
            "it are looked at carefully at your anomaly scan. That's why it's "
            "more and more often found in advance."),
      ),
    ],
  ),
  ConditionEntry(
    id: 'rh_negative',
    name: _en('Rh negative pregnancy'),
    plainLine: _en('Your blood type needs one injection to protect the baby.'),
    group: ConditionGroup.specialist,
    aliases: ['rh negative', 'rhesus negative', 'anti-d'],
    shortAnswer: _en("If your blood group is Rh negative, your body could make "
        "antibodies against an Rh positive baby's blood. An anti-D injection "
        "prevents this almost entirely. It's a routine part of your care."),
    whatItIs: _en("If your blood group is Rh negative and your baby's is Rh "
        "positive, your body can make antibodies against your baby's blood. "
        "If it's managed, this is mainly a concern for a second or later "
        "pregnancy, not this one."),
    reassurance: _en("This is well understood and very well prevented with an "
        "injection. It's a routine part of care for Rh negative mothers, not "
        "a rare complication."),
    howCommon: _en("Around 5 to 6 in 100 people in India are Rh negative, so "
        "this is a routine, well-managed part of many pregnancy files."),
    symptoms: [
      _en("No symptoms. It's picked up from your blood group test, not from "
          "how you feel."),
    ],
    callNow: [],
    justMonitor: [],
    testsToConfirm: [
      _en('Blood group and Rh typing, done early in pregnancy.'),
      _en('An antibody screen, to check whether antibodies have already '
          'formed.'),
    ],
    management: _en('An anti-D injection at around 28 weeks, and again after '
        'delivery if your baby turns out to be Rh positive. This stops '
        'antibodies forming in the first place.'),
    babyImpact: _en("Without treatment, this can affect a future pregnancy if "
        "antibodies form. The anti-D injection, given on time, prevents that "
        "almost entirely."),
    faqs: [
      ConditionFaq(
        question: _en('Does this affect this pregnancy?'),
        answer: _en("Usually not. The concern is mainly for a future "
            "pregnancy, and that's what the anti-D injection prevents."),
      ),
      // Added 2026-09-29: the same fact the bleeding read gives, where an Rh
      // negative mother will look for it.
      ConditionFaq(
        question: _en('What if I bleed or have a fall?'),
        answer: _en("Tell your doctor the same day. After bleeding, a blow to "
            "your tummy or some procedures, you may need an extra anti-D "
            "injection, and its timing matters."),
      ),
    ],
    showMedicine: true,
    pregSignal: PregCondition.rhNegative,
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
//
//  2026-09-29 (gap analysis, Appendix A): diabetes from before pregnancy and
//  skin conditions like psoriasis get their own questions here, still on the
//  one page and still led by her doctor.
final List<ConditionEntry> kPreExistingConditions = [
  ConditionEntry(
    id: 'pre_existing',
    name: _en('Pregnancy with a pre-existing condition'),
    plainLine: _en('Something you already had, now managed alongside pregnancy.'),
    group: ConditionGroup.preExisting,
    aliases: [
      'type 1 diabetes',
      'epilepsy',
      'pre-existing condition',
      'chronic condition pregnancy',
      'type 2 diabetes',
      'diabetes before pregnancy',
      'psoriasis',
      'eczema',
      'chronic illness',
    ],
    shortAnswer: _en("If you already live with a condition like diabetes, "
        "epilepsy or psoriasis, pregnancy adds to your care rather than "
        "replacing it. The specialist who knows you stays in charge, "
        "alongside your obstetrician. Never stop or change a medicine on "
        "your own."),
    whatItIs: _en("If you already live with a condition like type 1 diabetes "
        "or epilepsy, pregnancy doesn't reset your care. It adds to it. The "
        "specialist who already treats you stays in charge. Pregnancy mainly "
        "means more frequent checks and, sometimes, a review of which "
        "medicines are safest now."),
    reassurance: _en("Many women with a condition from before have "
        "straightforward pregnancies. The extra visits are there to keep it "
        "that way, not because something is expected to go wrong."),
    howCommon: _en("Many pregnancies involve a condition the mother already "
        "had before conceiving. So joint care between your specialist and "
        "your obstetrician is a routine path, not an unusual one."),
    symptoms: [
      _en('This depends on your condition. The symptoms you already know to '
          'watch for still apply.'),
    ],
    callNow: [
      _en("Any symptom that would have sent you to your specialist before "
          "pregnancy should still do so now. Pregnancy doesn't change that."),
    ],
    justMonitor: [],
    testsToConfirm: [
      _en('Whatever tests already track your condition, done more often in '
          'pregnancy: blood sugar for diabetes, medicine levels for epilepsy, '
          'and so on.'),
    ],
    management: _en("Joint care between the specialist who already treats you "
        "and your obstetrician. Some medicines are reviewed, and sometimes "
        "changed for ones that are safer in pregnancy. Never stop or switch "
        "anything yourself first. Extra scans and check-ups are usually added "
        "to your regular pregnancy visits."),
    babyImpact: _en("When a condition you had before is well controlled, most "
        "babies do well. The extra checks are there to catch anything early, "
        "for you and your baby."),
    faqs: [
      ConditionFaq(
        question: _en('Should I keep seeing my regular specialist?'),
        answer: _en("Yes. Pregnancy adds an obstetrician to your care. It "
            "doesn't replace the specialist who already knows your "
            "condition."),
      ),
      ConditionFaq(
        question: _en('Do I need to change my medicines?'),
        answer: _en("Possibly. Some medicines are reviewed for pregnancy, but "
            "that's always your specialist's decision. Don't stop or change "
            "anything before that conversation."),
      ),
      // Added 2026-09-29 (gap analysis, Appendix A, "Diabetic Diet").
      ConditionFaq(
        question: _en('I had diabetes before I got pregnant. What changes?'),
        answer: _en("Type 1 or type 2 diabetes from before pregnancy needs "
            "close care, so your diabetes doctor and obstetrician will work "
            "together. You'll usually check your sugar more often, and your "
            "doctor may change your tablets to insulin or adjust your doses as "
            "the weeks go on. You'll be offered extra scans, including a "
            "detailed scan of your baby's heart, and an eye check for you. A "
            "higher dose of folic acid is often advised early on. Keep every "
            "appointment, and never change a dose on your own."),
      ),
      // Added 2026-09-29 (gap analysis, Appendix A, "Psoriasis During
      // Pregnancy").
      ConditionFaq(
        question: _en('I have psoriasis or eczema. Are my creams safe?'),
        answer: _en("Some are and some aren't, so show every cream, tablet and "
            "injection you use to your doctor or skin specialist early on. "
            "Some strong psoriasis treatments must be stopped before or during "
            "pregnancy, and many simple creams are fine to keep using. "
            "Psoriasis calms down in pregnancy for some women and flares for "
            "others, and it can flare after birth. Don't stop a treatment "
            "suddenly without asking."),
      ),
    ],
    showMedicine: true,
  ),
];

// -----------------------------------------------------------------------------
//  Seasonal & infections — 2, brief; five infections added 2026-09-29
// -----------------------------------------------------------------------------
//  ⚠️ THE NEW FIVE (gap analysis, Complications, "infections that matter in
//  India"): toxoplasmosis, hepatitis B, HIV testing at booking, malaria and
//  typhoid. None carries a `pregSignal`: `PregCondition` has no counterpart,
//  and a null signal is the honest answer (see the field's note above).
final List<ConditionEntry> kSeasonalConditions = [
  ConditionEntry(
    id: 'covid_pregnancy',
    name: _en('COVID in pregnancy'),
    plainLine: _en('Covid while pregnant, and what changes.'),
    group: ConditionGroup.seasonal,
    aliases: ['covid', 'coronavirus', 'covid-19'],
    shortAnswer: _en("For most vaccinated, healthy women, COVID in pregnancy "
        "is much like COVID at any other time: rest, fluids and paracetamol "
        "at home. Breathlessness, chest pain or a low oxygen level means "
        "calling your doctor now."),
    whatItIs: _en("This is catching COVID-19 while you're pregnant. For most "
        "vaccinated, otherwise healthy women, it behaves much as it would "
        "outside pregnancy."),
    reassurance: _en('Most pregnant women who get COVID recover at home with '
        'rest and fluids, as anyone else would.'),
    howCommon: _en("It follows the same patterns as for everyone else, with "
        "most cases mild, especially in vaccinated women."),
    symptoms: [
      _en('Fever, cough, sore throat and body aches, the same as anyone '
          'else.'),
      _en('Loss of taste or smell, in some cases.'),
    ],
    callNow: [
      _en('Breathlessness or chest pain.'),
      _en('An oxygen level below 94% on a pulse oximeter, if you have one.'),
      _en('Your baby moving less than usual.'),
    ],
    justMonitor: [
      _en('Mild fever, cough or sore throat with normal breathing. Rest, '
          'fluids and paracetamol as usual, and tell your doctor at your next '
          'contact.'),
    ],
    testsToConfirm: [
      _en('RT-PCR or rapid antigen test.'),
    ],
    management: _en('Rest, fluids, and paracetamol for fever, the same as '
        'outside pregnancy. Vaccination is recommended in pregnancy and '
        'lowers the chance of severe illness.'),
    babyImpact: _en("Most babies are unaffected when their mother has mild "
        "COVID. Severe illness in the mother is what adds risk, which is why "
        "breathlessness on this page means calling now."),
    faqs: [
      ConditionFaq(
        question: _en('Is the vaccine safe in pregnancy?'),
        answer: _en("Yes. It's recommended in pregnancy and lowers the chance "
            "of severe illness."),
      ),
    ],
    showReadMore: true,
  ),
  ConditionEntry(
    id: 'dengue_pregnancy',
    name: _en('Dengue in pregnancy'),
    plainLine: _en('Dengue while pregnant, and what changes.'),
    group: ConditionGroup.seasonal,
    aliases: ['dengue', 'dengue fever'],
    shortAnswer: _en("Dengue is a fever spread by mosquitoes. In pregnancy "
        "it's watched more closely because it can lower your platelets. Use "
        "paracetamol for the fever, never ibuprofen or aspirin, and call your "
        "doctor about any bleeding, severe pain or vomiting."),
    whatItIs: _en("Dengue is a viral fever spread by mosquitoes. In pregnancy "
        "it needs closer monitoring than usual because of how it affects your "
        "platelets and fluid balance."),
    reassurance: _en('Most cases are managed well with monitoring and '
        'supportive care. What matters is not missing the warning signs.'),
    howCommon: _en("It follows local seasonal outbreaks, the same as for "
        "everyone else. In most of India it's more common in and just after "
        "the monsoon."),
    symptoms: [
      _en('High fever, severe headache, and pain behind your eyes.'),
      _en('Joint and muscle pain, and a rash in some cases.'),
    ],
    callNow: [
      _en('Bleeding from your gums or nose, or bruising easily.'),
      _en("Severe tummy pain, or vomiting that won't stop."),
      _en('Passing less urine, or feeling faint.'),
    ],
    justMonitor: [],
    testsToConfirm: [
      _en('NS1 antigen test, in the first few days of fever.'),
      _en('Dengue IgM and IgG antibody test, later in the illness.'),
      _en('Platelet count, tracked through the illness.'),
    ],
    management: _en("Rest, fluids, and paracetamol for fever. Never ibuprofen "
        "or aspirin, which raise the risk of bleeding. Platelet counts are "
        "tracked closely, and in pregnancy a hospital stay for closer "
        "monitoring is common, even for otherwise mild cases."),
    babyImpact: _en("Severe dengue can affect a pregnancy. That's why a "
        "hospital stay for monitoring is offered more readily in pregnancy "
        "than outside it."),
    faqs: [
      ConditionFaq(
        question: _en('Can I take paracetamol for the fever?'),
        answer: _en('Yes, paracetamol is the usual choice. Avoid ibuprofen and '
            'aspirin, which can raise the risk of bleeding in dengue.'),
      ),
      // Added 2026-09-29, beside the new aspirin answer on Preeclampsia: the
      // two pages must not leave her holding opposite instructions.
      ConditionFaq(
        question: _en('I take low-dose aspirin for my pregnancy. What now?'),
        answer: _en("Tell your doctor straight away that you have dengue or a "
            "fever. Don't stop or carry on with the aspirin until they "
            "tell you which."),
      ),
    ],
  ),
  ConditionEntry(
    id: 'malaria_pregnancy',
    name: _en('Malaria in pregnancy'),
    plainLine: _en('A mosquito fever with chills, treated quickly in pregnancy.'),
    group: ConditionGroup.seasonal,
    aliases: ['malaria', 'mosquito fever', 'fever with chills'],
    shortAnswer: _en("Malaria is a fever spread by mosquitoes, often with "
        "shivering and chills. In pregnancy it can become serious faster, so "
        "a fever with chills needs a blood test the same day. It's treated "
        "with medicines that are safe in pregnancy."),
    whatItIs: _en("Malaria is an infection passed on by mosquito bites. It "
        "causes fever that often comes with shivering and chills. Pregnancy "
        "lowers your natural protection a little, so it can become severe "
        "more quickly than usual."),
    reassurance: _en("It's treatable, and there are malaria medicines that are "
        "safe in pregnancy. Testing quickly and starting treatment early "
        "makes the biggest difference."),
    howCommon: _en("Malaria is still found in many parts of India, most of all "
        "in forest and tribal areas and in and after the monsoon. It's less "
        "common in big cities, but still seen."),
    symptoms: [
      _en('Fever, often with shivering, chills and sweating.'),
      _en('Headache, body ache, and feeling very tired.'),
      _en('Nausea or vomiting.'),
    ],
    callNow: [
      _en('A fever, especially with chills, if you live in or have visited an '
          'area with malaria. Get a blood test the same day.'),
      _en('Confusion, fits, extreme drowsiness, breathlessness, yellow eyes '
          'or passing very little urine. Go to hospital immediately.'),
      _en('Your baby moving less than usual.'),
    ],
    justMonitor: [],
    testsToConfirm: [
      _en('A rapid malaria test (RDT) or a blood smear, usually the same '
          'day.'),
      _en('A blood count, and sometimes sugar and liver tests, because '
          'malaria can lower your haemoglobin and your blood sugar.'),
    ],
    management: _en("Malaria medicine chosen for your stage of pregnancy, "
        "taken as a full course. Paracetamol for fever, and plenty of fluids. "
        "Severe malaria is treated in hospital with injections. Sleeping "
        "under a mosquito net, ideally one treated with insecticide, helps "
        "stop it happening again."),
    babyImpact: _en("If it isn't treated, malaria in pregnancy can lead to "
        "anaemia, a smaller baby or early labour. Treated quickly, most "
        "mothers and babies do well."),
    faqs: [
      ConditionFaq(
        question: _en('Are malaria medicines safe in pregnancy?'),
        answer: _en("Yes. There are malaria medicines that are safe at each "
            "stage of pregnancy, and your doctor chooses the right one for "
            "your weeks. Untreated malaria is far riskier for you and your "
            "baby than the medicine."),
      ),
      ConditionFaq(
        question: _en('How can I avoid mosquito bites?'),
        answer: _en("Sleep under a mosquito net, keep screens on windows, wear "
            "long sleeves in the evening, and don't let water stand around "
            "the house. Ask your doctor which repellent to use on your "
            "skin."),
      ),
    ],
  ),
  ConditionEntry(
    id: 'typhoid_pregnancy',
    name: _en('Typhoid in pregnancy'),
    plainLine: _en('A fever from food or water that was not clean.'),
    group: ConditionGroup.seasonal,
    aliases: ['typhoid', 'enteric fever', 'widal'],
    shortAnswer: _en("Typhoid is a fever caught from food or water that has "
        "been contaminated. It builds up over several days and needs "
        "antibiotics, which your doctor chooses to be safe in pregnancy. A "
        "high fever in pregnancy is a reason to call your doctor the same "
        "day."),
    whatItIs: _en("Typhoid (enteric fever) is an infection with bacteria that "
        "you catch from contaminated food or water. The fever usually rises "
        "over several days, and can come with stomach pain, headache and "
        "loss of appetite."),
    reassurance: _en("It's treatable with antibiotics, and there are ones that "
        "are safe in pregnancy. Treated early, most women recover fully."),
    howCommon: _en("Typhoid is still common in India, especially where "
        "drinking water may not be safe, and more so in the monsoon."),
    symptoms: [
      _en('A fever that climbs over several days.'),
      _en('Headache, weakness and body ache.'),
      _en('Stomach pain, constipation or loose motions, and loss of '
          'appetite.'),
    ],
    callNow: [
      _en('A high fever, especially if it lasts or keeps climbing. Call your '
          'doctor the same day.'),
      _en("Severe tummy pain, vomiting that won't stop, blood in your stools, "
          "or feeling confused. Go to hospital immediately."),
      _en('Your baby moving less than usual.'),
    ],
    justMonitor: [],
    testsToConfirm: [
      _en('A blood culture, which is the most reliable test in the first '
          'week.'),
      _en('The Widal test is still widely used in India, but on its own it '
          'can mislead. Your doctor reads it alongside your symptoms and '
          'other tests.'),
    ],
    management: _en("Antibiotics chosen to be safe in pregnancy, taken as a "
        "full course even once you feel better. Plenty of fluids, paracetamol "
        "for fever, and light food you can manage. Some women need a short "
        "hospital stay for a drip."),
    babyImpact: _en("A high fever and dehydration can raise the chance of "
        "early labour, which is why typhoid is treated quickly. Treated in "
        "time, most babies aren't affected."),
    faqs: [
      ConditionFaq(
        question: _en('Can I have the typhoid vaccine while pregnant?'),
        answer: _en('Ask your doctor. It depends on the type of vaccine and '
            'how likely you are to be exposed.'),
      ),
      ConditionFaq(
        question: _en('How can I avoid it?'),
        answer: _en("Drink boiled or filtered water, eat food that's freshly "
            "cooked and hot, and wash your hands before eating. Take care "
            "with cut fruit, chutneys and street food that may have been "
            "washed in unsafe water."),
      ),
    ],
  ),
  ConditionEntry(
    id: 'toxoplasmosis',
    name: _en('Toxoplasmosis'),
    plainLine: _en('An infection from soil, cat litter or undercooked meat.'),
    group: ConditionGroup.seasonal,
    aliases: ['toxoplasmosis', 'toxo', 'cat litter', 'torch test'],
    shortAnswer: _en("Toxoplasmosis is an infection caught from undercooked "
        "meat, unwashed vegetables, soil or cat faeces. Most people have no "
        "symptoms, but a first infection in pregnancy can reach the baby. "
        "That's why the advice on meat, vegetables and cats exists."),
    whatItIs: _en("Toxoplasmosis is caused by a tiny parasite found in soil, "
        "in cat faeces and in undercooked meat. Most people who catch it feel "
        "nothing, or have a mild illness like flu. It matters in pregnancy "
        "because a first infection can pass to your baby."),
    reassurance: _en("Many women had it before pregnancy without knowing, and "
        "that usually protects this baby. A few food and hygiene habits "
        "make catching it much less likely."),
    howCommon: _en("A new infection during pregnancy is uncommon. Testing "
        "everyone isn't routine in India; your doctor tests if there's a "
        "reason to."),
    symptoms: [
      _en('Usually none.'),
      _en('Sometimes a mild fever, tiredness, aches or swollen glands in your '
          'neck, like a mild flu.'),
    ],
    callNow: [
      _en('A fever or flu-like illness with swollen glands in your neck. Call '
          'your doctor so they can decide whether to test.'),
    ],
    justMonitor: [],
    testsToConfirm: [
      _en("A blood test for toxoplasma antibodies (IgG and IgM), sometimes as "
          "part of a TORCH panel."),
      _en("If a new infection is suspected, more tests and detailed scans, "
          "planned by your doctor. One positive result often doesn't mean a "
          "new infection, so ask your doctor to explain it."),
    ],
    management: _en("If a new infection is confirmed in pregnancy, your doctor "
        "may prescribe medicine to lower the chance of it reaching your baby, "
        "and plan extra scans. Prevention is the main thing: cook meat until "
        "no pink is left, wash fruit and vegetables well, wear gloves for "
        "gardening, and let someone else clean the cat's litter."),
    babyImpact: _en("A first infection in pregnancy doesn't always pass to "
        "your baby. When it does, it can affect the eyes and brain, which is "
        "why a confirmed new infection is treated and followed with scans."),
    faqs: [
      ConditionFaq(
        question: _en('Do I have to give away my cat?'),
        answer: _en("No. Let someone else clean the litter every day, or wear "
            "gloves and wash your hands afterwards. Keep your cat indoors if "
            "you can, and don't feed it raw meat."),
      ),
      ConditionFaq(
        question: _en('My TORCH test is positive. Is my baby infected?'),
        answer: _en("Usually not. A positive IgG often means an old infection "
            "that protects you. Ask your doctor to explain your result before "
            "you act on it."),
      ),
    ],
  ),
  ConditionEntry(
    id: 'hepatitis_b',
    name: _en('Hepatitis B in pregnancy'),
    plainLine: _en('A liver virus your baby can be protected from at birth.'),
    group: ConditionGroup.seasonal,
    aliases: ['hepatitis b', 'hep b', 'hbsag', 'hbv'],
    shortAnswer: _en("Hepatitis B is a liver virus that can pass to a baby "
        "around birth. Every pregnant woman is tested for it at booking. If "
        "you have it, your baby gets a vaccine and an antibody injection soon "
        "after birth, which protects most babies."),
    whatItIs: _en("Hepatitis B is a virus that affects the liver. Many people "
        "carry it for years without symptoms. In pregnancy, the main concern "
        "is that it can pass to your baby around the time of birth."),
    reassurance: _en("Passing it on is largely preventable. Your baby is given "
        "the hepatitis B vaccine and an antibody injection (HBIG) soon after "
        "birth, and this protects most babies."),
    howCommon: _en("Studies in India find it in roughly 1 to 3 in 100 "
        "pregnant women. That's why the HBsAg test is part of your routine "
        "booking blood tests."),
    symptoms: [
      _en('Usually none. Most women find out from the booking blood test.'),
      _en('Sometimes tiredness, poor appetite, or yellow eyes and skin '
          '(jaundice).'),
    ],
    callNow: [
      _en('Yellow eyes or skin, dark urine, or pale stools.'),
      _en('Severe tiredness with vomiting, or pain under your right ribs.'),
    ],
    justMonitor: [],
    testsToConfirm: [
      _en('HBsAg blood test at your first booking visit.'),
      _en("If it's positive, more blood tests (such as viral load and liver "
          "tests) to see how active the virus is."),
    ],
    management: _en("Your obstetrician works with a liver specialist or "
        "physician. If the amount of virus is high, you may be offered an "
        "antiviral tablet in the third trimester to lower the chance of "
        "passing it on. Your baby gets the hepatitis B vaccine and HBIG, "
        "ideally within 12 hours of birth, then the rest of the vaccine "
        "course. Your partner and family can be tested and vaccinated too."),
    babyImpact: _en("With the vaccine and HBIG at birth, most babies are "
        "protected. Your baby will usually have a blood test after the "
        "vaccine course to check."),
    faqs: [
      ConditionFaq(
        question: _en('Can I breastfeed?'),
        answer: _en("Yes. Breastfeeding is considered safe once your baby has "
            "had the vaccine and HBIG. If your nipples crack and bleed, ask "
            "your doctor."),
      ),
      ConditionFaq(
        question: _en('Will I need a caesarean because of this?'),
        answer: _en("No. Hepatitis B on its own isn't a reason for a "
            "caesarean. How you deliver is decided as usual."),
      ),
    ],
    showMedicine: true,
  ),
  ConditionEntry(
    id: 'hiv_testing',
    name: _en('HIV testing in pregnancy'),
    plainLine: _en("The routine booking test, and what happens if it's positive."),
    group: ConditionGroup.seasonal,
    aliases: ['hiv', 'aids', 'hiv test', 'art'],
    shortAnswer: _en("An HIV test is part of the routine booking blood tests "
        "for every pregnant woman in India, done with your consent. If it's "
        "positive, free daily treatment keeps you well and makes it very "
        "unlikely your baby gets HIV. Your result is kept confidential."),
    whatItIs: _en("HIV is a virus that affects the body's defences (the "
        "immune system). It can pass from a mother to her baby in pregnancy, "
        "at birth or through breastfeeding. Testing everyone at booking means "
        "anyone who has it can start treatment early."),
    reassurance: _en("Being tested is routine and doesn't mean anyone suspects "
        "anything. If a result is positive, treatment works very well. With "
        "it, most mothers stay healthy and most babies are born without "
        "HIV."),
    howCommon: _en("HIV is uncommon in pregnant women in India, well under 1 "
        "in 100. The test is offered to everyone because treatment works best "
        "when it starts early."),
    symptoms: [
      _en('Usually none. Most people with HIV feel well for years, which is '
          'why testing matters.'),
    ],
    callNow: [
      _en("You're on treatment and can't take your tablets for any reason. "
          "Call your doctor or ART centre."),
    ],
    justMonitor: [],
    testsToConfirm: [
      _en('An HIV test at your booking visit, done with your consent and a '
          'short talk (counselling) first.'),
      _en("If it's positive, confirmation tests and a viral load test."),
    ],
    management: _en("Treatment is daily antiretroviral tablets (ART), started "
        "as soon as possible and continued through pregnancy, birth and "
        "afterwards. It's free at government ART centres under the national "
        "programme. Your baby is given medicine after birth and tested over "
        "the following months. Your doctor will talk with you about "
        "feeding."),
    babyImpact: _en("Without treatment, HIV can pass to a baby. With treatment "
        "that keeps the virus low, the chance becomes very small."),
    faqs: [
      ConditionFaq(
        question: _en('Who will know my result?'),
        answer: _en("Your result is confidential and shared only with the "
            "people caring for you. Telling your partner or family is your "
            "choice, and counsellors can help if you want it."),
      ),
      ConditionFaq(
        question: _en('Can I say no to the test?'),
        answer: _en("Yes, it's your choice. Doctors recommend it because it "
            "protects your baby if the result is positive, and it's free at "
            "government centres."),
      ),
    ],
    showMedicine: true,
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
