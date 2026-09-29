// =============================================================================
//  Learn covers — drawn in the app's own hand, by subject
// -----------------------------------------------------------------------------
//  ⚠️ THE PHOTOS ARE GONE. THIS IS WHY — 2026-09-22, the device walk.
//
//  This file used to map a topic word to a free Unsplash photo. On the phone
//  the result was indefensible: ONE photograph of a woman on a sofa with two
//  toddlers and a tablet appeared on "The Complete Pregnancy Guide", "Birth
//  Confidence Masterclass", "Birth Prep Essentials" AND "Birth-Ready
//  Bootcamp", one under the other in the same scroll; a second, of three
//  students at laptops in a co-working space, carried both remaining cohorts.
//  Two failures at once:
//
//   1. WRONG SUBJECT. The ids were written from memory rather than looked at
//      — the same mistake the store tiles were rebuilt for. Toddlers with a
//      tablet is not birth preparation.
//   2. REPETITION IS STRUCTURAL, not a bad draw. Keying a photo to a topic
//      WORD means every programme sharing a topic shares a picture, and the
//      catalogue is built out of a handful of topics on purpose.
//
//  The obvious fix — pick better photos by eye from Wikimedia Commons, as the
//  store tiles and the recipe reads do — does not work here, and it is worth
//  writing down why: Commons is an encyclopaedia's picture library. It is
//  excellent at OBJECTS (a bowl of ragi, a strip of iron tablets) and poor at
//  PEOPLE DOING THINGS. Searched for the subjects this screen needs it
//  returns ethnographic archive photographs, a 1907 oil painting, clinical
//  record shots and an Egyptian ostracon. None of that can sit on a card
//  asking a woman for ₹6,999.
//
//  So the cover stops being a photograph and becomes a MARK — the same
//  `IntentMark` family the doors, the hubs and the rails already draw in
//  (`hub_intent_art.dart`, sixty-odd marks). That family's own rule is that
//  marks are reused ACROSS surfaces by meaning, so a shared mark is correct
//  where a shared photograph was not; and each programme keeps its own hue
//  underneath, so two cards wearing one mark still read apart.
//
//  ⚠️ `cover` STAYS ON THE MODEL. When a real shoot exists — our own
//  photographs of our own classes — a URL per programme fills it and the
//  photo path in `PvLearnCover` lights up untouched. What is dead is
//  INVENTING a stock photo from a keyword.
//
//  Kept for revert, the map that shipped 2026-09-20:
//    String _u(String id) =>
//        'https://images.unsplash.com/photo-$id?w=900&q=80&auto=format&fit=crop';
//    'sleep': _u('1503454537195-1dcabb73ffb9'),
//    'newborn': _u('1555252333-9f8e92e65df9'),
//    'feeding': _u('1519689680058-324335c77eba'),
//    'development': _u('1516627145497-ae6968895b74'),
//    'birth': _u('1476703993599-0035a21b17a9'),
//    'pregnancy': _u('1489710437720-ebb67ec84dd2'),
//    'prenatal': _u('1544367567-0f2fcb009e0b'),
//    'yoga': _u('1506126613408-eca07ce68773'),
//    'breathing': _u('1515488042361-ee00e0ddd4e4'),
//    'nutrition': _u('1544027993-37dbfe43562a'),
//    'doctor': _u('1576091160399-112ba8d25d1d'),
//    'trying': _u('1524250502761-1ac6f2e30d43'),
//    …and a per-kind default. The full list is in git at 3ca19db.
// =============================================================================

import '../../screens/brackets/hub/hub_intent_art.dart';
import '../reads/read_images.dart' show readImageFor;
import 'pv_learn_view.dart';

/// Topic word → drawn mark. First match in the programme's topic list wins;
/// the kind's default is the floor.
///
/// ⚠️ SUBSTRING, DELIBERATELY. The topics are display strings — "Birth &
/// Labour", "First Trimester" — so the key is the word inside them. The old
/// photo map used the same lookup and matched nothing at all for "First
/// Trimester", which is how four cards ended up on one per-kind default
/// without anyone noticing: a fallback that reads fine in code and shows as
/// four identical pictures on the phone.
const Map<String, IntentMark> _byTopic = {
  // ---- pregnancy ----------------------------------------------------------
  'birth': IntentMark.bagMark, // a packed bag: ready, not frightened
  'labour': IntentMark.bagMark,
  'trimester': IntentMark.calendarDay, // the weeks, marked
  'breathing': IntentMark.lotusMark, // stillness, practised
  'calm': IntentMark.lotusMark,
  'yoga': IntentMark.lotusMark,
  'fitness': IntentMark.improveMark, // a line rising, with a leaf on it
  'exercise': IntentMark.improveMark,
  'physio': IntentMark.bodyMark,
  'scan': IntentMark.scanFan,
  'test': IntentMark.scanFan,
  'pregnancy': IntentMark.bookMark, // a guide she comes back to
  // ---- the baby -----------------------------------------------------------
  'newborn': IntentMark.cuppedHands, // support offered, not instructions
  'postnatal': IntentMark.cuppedHands,
  'fourth': IntentMark.cuppedHands,
  'breastfeeding': IntentMark.feedMark,
  'lactation': IntentMark.feedMark,
  'feeding': IntentMark.feedMark,
  'weaning': IntentMark.bowlMark,
  'solids': IntentMark.bowlMark,
  'sleep': IntentMark.sleepMark,
  'development': IntentMark.stepsMark,
  'milestone': IntentMark.stepsMark,
  'play': IntentMark.blocksMark,
  'behaviour': IntentMark.moodArc,

  // ---- her ----------------------------------------------------------------
  'nutrition': IntentMark.plate,
  'food': IntentMark.plate,
  'diet': IntentMark.plate,
  // Before 'mind' and 'mental', so it wins for the TTC psychologist and
  // support group (launch sanity MB21, 2026-09-28; see `_fromTtc`).
  'mental support': IntentMark.cuppedHands,
  'mind': IntentMark.moodArc,
  'mental': IntentMark.moodArc,
  'emotion': IntentMark.moodArc,
  'counsel': IntentMark.moodArc,

  // ---- who ----------------------------------------------------------------
  'obstetric': IntentMark.askDoctor,
  'gynae': IntentMark.askDoctor,
  'gynec': IntentMark.askDoctor,
  'paediatric': IntentMark.askDoctor,
  'pediatric': IntentMark.askDoctor,
  'doctor': IntentMark.askDoctor,

  // ---- trying to conceive -------------------------------------------------
  'trying': IntentMark.cycleRing,
  'fertility': IntentMark.cycleRing,
  'cycle': IntentMark.cycleRing,
  'ivf': IntentMark.cycleRing,
  'conceive': IntentMark.cycleRing,
};

/// The floor. A kind always has a face, so a programme added tomorrow with a
/// topic nobody mapped still draws something true about what it IS.
const Map<PvLearnKind, IntentMark> _byKind = {
  PvLearnKind.course: IntentMark.bookMark,
  PvLearnKind.masterclass: IntentMark.playMark,
  PvLearnKind.cohort: IntentMark.calendarDay,
  PvLearnKind.consult: IntentMark.askDoctor,
  PvLearnKind.classPack: IntentMark.lotusMark,
};

IntentMark pvLearnMarkFor(List<String> topics, PvLearnKind kind) {
  for (final t in topics) {
    final k = t.toLowerCase().trim();
    for (final e in _byTopic.entries) {
      if (k.contains(e.key)) return e.value;
    }
  }
  return _byKind[kind] ?? IntentMark.bookMark;
}

/// A real photograph for one programme, by its catalogue id.
///
/// ⚠️ EMPTY TODAY, AND THIS IS THE SEAM, NOT A REFUSAL. Photographs are
/// welcome here — the user's call, 2026-09-22 ("we can obviously have images
/// as well"), and `PvLearnCover` renders one the moment this map holds it,
/// falling back to the drawn cover if the URL 404s. What is dead is
/// SYNTHESISING one from a keyword, which is what put a toddler with a
/// tablet on four birth courses.
///
/// Why it is empty rather than filled with something free: picking by eye
/// needs a library to pick FROM, and from this machine there is not one.
/// Checked on 2026-09-22:
///   · Wikimedia Commons — licence fine, pictures wrong. The subjects here
///     return ethnographic archive photographs, a 1907 oil painting and an
///     Egyptian ostracon. It is an encyclopaedia's library, which is why it
///     dresses the store's OBJECTS and the recipes so well and cannot dress
///     a class.
///   · Openverse — amateur Flickr snapshots (a poster on a wall, a screen
///     grab with a "click to read more" banner), and worse, filtered to
///     licences that allow COMMERCIAL use it returns sixteen results for
///     "prenatal yoga", nine of them the same red-carpet launch event. A
///     `by-nc` photo is not usable in a paid app at any quality.
///   · Unsplash — the right licence and the right pictures, but its search
///     API needs a key, and choosing ids without SEEING them is the exact
///     mistake being undone here.
///
/// So: a free Unsplash access key (or our own photographs) fills this map in
/// an afternoon, and every card and hero picks the photo up with no other
/// change. Until then the drawn cover is the cover — a real one, not a gap.
///   'course_pregnancy_guide': 'https://…',
///
/// ⚠️ FILLED FOR TRYING TO CONCEIVE — 2026-09-29. The user: "stop leaving
/// the placeholders and put random but relevant images for them, from free
/// resources on the web." The library that did not exist on 2026-09-22 does
/// now: the read-photo pipeline (`read_images.dart`: StockSnap through
/// Openverse, and Wikimedia Commons, mirrored to our R2 bucket with a
/// licence line each). So every TTC programme has ONE photo, chosen by eye
/// for THAT programme and keyed `learn_<id>` in the read table, which is
/// the rule this file was written to protect: a photo per programme, never
/// a photo per topic word. Objects and rooms only, never a face: a consult
/// is with a named person, and a stock face on her page would be presented
/// as her (a stethoscope beside a laptop for a video consult, spices in
/// steel katoris for the nutritionist, an armchair in soft light for the
/// psychologist). Other stages keep their drawn covers.
/// Kept for revert: `const Map<String, String> kPvLearnCovers = {};`
final Map<String, String> kPvLearnCovers = {
  for (final id in kPvTtcLearnCoverIds) id: ?readImageFor('learn_$id'),
};

/// The TTC programmes that carry a photograph, by catalogue id.
const List<String> kPvTtcLearnCoverIds = [
  'ttc_consult_fertility',
  'ttc_consult_gynae',
  'ttc_consult_androl',
  'ttc_course_basics',
  'ttc_course_pcos',
  'ttc_yoga_pack',
  'ttc_nutrition_consult',
  'ttc_psych_consult',
  'ttc_loss_support',
  'ttc_assessment_couple',
  'ttc_partner_workshop',
  'ttc_ivf_prep',
  'ttc_lifestyle_90',
  'ttc_course_garbh',
];

/// The photograph for a programme, or null for the drawn cover.
String? pvLearnCoverFor(String id, List<String> topics, PvLearnKind kind) =>
    kPvLearnCovers[id];
