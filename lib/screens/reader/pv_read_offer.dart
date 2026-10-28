// =============================================================================
//  pv_read_offer.dart - one calm link from a read to a service of ours
// =============================================================================
//
// The user (walk 2026-10-20): "In articles, whenever possible, provide the
// option to relevant services that we have ... a course, a masterclass, a
// consultation ... it can be in between as well ... pitch it in the right
// way, in a normal way." Every read opens in `PvReaderScreen`, so one rule
// here reaches all three stages.
//
// ⚠️ RELEVANT OR NOTHING. The match is by shared topic words between the read
// (title, kicker, teaser) and the offering (title, subtitle). No shared topic,
// no card: a pitch that does not fit the page is worse than none ("cakes, not
// pizza": every item fits its screen). Never on a loss or an urgent read.
//
// ⚠️ ONE PER READ, MID-PAGE. After the second section, so it reads as part of
// the page and not as an ad at the end. The read's own "What you can do with
// this" steps are untouched.
//
// Rules in code, not in the CMS (CLAUDE.md: behaviour rules are not content).
// The catalogue is `PvLearnCatalog`, the same one Learn and More show, so a
// price or a title is never typed twice.

import 'package:flutter/material.dart';

import '../../data/learn/pv_learn_view.dart';
import '../../data/mind_mood_data.dart' show kCrisisHelplineNumber;
import '../../models/pv_read.dart';
import '../../services/life_stage_store.dart' show LifeStage;
import '../../ttc/ttc_care_pathway.dart' show TimingOwnership;
import '../../ttc/ttc_store.dart' show TtcStore;
import '../../theme/pv_fonts.dart';
import '../learn/pv_learn_catalog.dart';
import '../learn/pv_offering_screen.dart' show pvOpenOffering;

/// Topic words a read and an offering can share. Lower case, whole words.
const List<String> kPvOfferTopics = [
  'pcos', 'ivf', 'iui', 'sperm', 'semen', 'thyroid', 'fertility',
  'food', 'nutrition', 'diet', 'eat', 'eating', 'weight',
  'yoga', 'exercise', 'fitness', 'move', 'breath', 'breathing',
  'stress', 'anxiety', 'mind', 'mood', 'sleep',
  'labour', 'birth', 'delivery', 'breastfeeding', 'feeding', 'lactation',
  'garbh', 'sanskar', 'newborn', 'baby', 'toddler', 'behaviour', 'potty',
  'development', 'speech', 'solids', 'weaning', 'partner', 'father',
];

/// A read's word, and the words of the expert who can help with it
/// (2026-10-23, global pass phase 2). The user: "for each and every article,
/// wherever possible, provide option to relevant services." Half the reads had
/// no shared topic word with any offering - a scan read never said
/// "obstetrician" - so they got nothing. This names the person instead.
const Map<String, List<String>> kPvOfferAliases = {
  // pregnancy clinical -> the obstetrician
  'scan': ['obstetrician'], 'scans': ['obstetrician'],
  'ultrasound': ['obstetrician'], 'report': ['obstetrician'],
  'blood': ['obstetrician'], 'bloods': ['obstetrician'],
  'nst': ['obstetrician'], 'doppler': ['obstetrician'],
  'pressure': ['obstetrician'], 'sugar': ['obstetrician', 'nutritionist'],
  'diabetes': ['obstetrician', 'nutritionist'], 'thyroid': ['obstetrician'],
  'waters': ['obstetrician'], 'due': ['obstetrician'], 'rest': ['obstetrician'],
  'risk': ['obstetrician'], 'movement': ['obstetrician'],
  'vaccine': ['obstetrician'], 'vaccines': ['obstetrician'],
  'ohss': ['fertility'], 'ivf': ['fertility'], 'help': ['fertility'],
  // food -> the nutritionist
  'iron': ['nutritionist'], 'weight': ['nutritionist'],
  'supplement': ['nutritionist'], 'supplements': ['nutritionist'],
  'folic': ['nutritionist'], 'omega': ['nutritionist'],
  'recipes': ['nutritionist'], 'plate': ['nutritionist'], 'myths': ['nutritionist'],
  // TTC body and tests -> fertility specialist / gynaecologist
  'ovulation': ['fertility'], 'conception': ['fertility'],
  'conceive': ['fertility'], 'temperature': ['fertility'],
  'preconception': ['fertility'], 'carrier': ['fertility'],
  'screening': ['fertility'], 'testing': ['fertility'], 'results': ['fertility'],
  'months': ['fertility'], 'cycle': ['gynaecologist'], 'cycles': ['gynaecologist'],
  'period': ['gynaecologist'], 'periods': ['gynaecologist'],
  'contraception': ['gynaecologist'], 'control': ['gynaecologist'],
  'discharge': ['gynaecologist'], 'yeast': ['gynaecologist'],
  'uti': ['gynaecologist'], 'sti': ['gynaecologist'], 'infection': ['gynaecologist'],
  'implantation': ['gynaecologist'], 'signs': ['gynaecologist'],
  'meds': ['gynaecologist'], 'conditions': ['gynaecologist'],
  // the worry of it -> the psychologist / counsellor
  // Not 'worry': clinical reads say "when to worry" (OHSS went to the
  // psychologist). Kept for revert: 'worry': ['psychologist', 'counsellor'],
  'wait': ['psychologist', 'counsellor'],
  'waiting': ['psychologist', 'counsellor'], 'family': ['psychologist', 'counsellor'],
  'telling': ['psychologist', 'counsellor'], 'calm': ['psychologist', 'counsellor'],
  'sex': ['psychologist', 'couple'], 'intimate': ['gynaecologist'],
  'close': ['psychologist', 'couple'],
  // body aches -> the physiotherapist
  'back': ['physiotherapist'], 'pelvic': ['physiotherapist'], 'pain': ['physiotherapist'],
  // ⚠️ PARENTING (step 0 · S6, 2026-10-25). A door page never said the words
  // its course is named by, so a talking page reached nothing. Parenting has
  // no consult in the catalogue yet (its experts are gated until Directus
  // serves them), so these name the course or class that fits: talking ->
  // Language and Communication, naps -> the sleep courses, first foods ->
  // weaning, crawling -> Motor Skills, autism -> the special needs course,
  // hazards -> baby-proofing, colic -> the fussy stretches. When paediatric
  // consults arrive, add 'paediatrician', 'lactation', 'speech' and 'child
  // psychologist' to the right words here; nothing else changes.
  'talk': ['language'], 'talking': ['language'], 'words': ['language'],
  'speech': ['language'], 'stammer': ['language'], 'babble': ['language'],
  'nap': ['sleep'], 'naps': ['sleep'], 'night': ['sleep'], 'nights': ['sleep'],
  'waking': ['sleep'], 'bedtime': ['sleep'], 'regression': ['sleep'],
  'solids': ['weaning', 'solids'], 'puree': ['weaning'], 'purees': ['weaning'],
  'spoon': ['weaning'], 'gagging': ['weaning'], 'finger': ['weaning'],
  'crawl': ['motor'], 'crawling': ['motor'], 'walk': ['motor'],
  'walking': ['motor'], 'sit': ['motor'], 'sitting': ['motor'], 'tummy': ['motor'],
  'play': ['play'], 'playing': ['play'], 'toys': ['play'],
  // Not 'delay': a late talker is not an autism course. Not 'safe': a
  // safe-sleep page is not baby-proofing.
  'autism': ['special', 'needs'],
  'therapy': ['special', 'needs'], 'diagnosis': ['special', 'needs'],
  'safety': ['proofing'], 'falls': ['proofing'],
  'poisons': ['proofing'], 'burns': ['proofing'], 'choking': ['proofing'],
  'colic': ['fussy'], 'crying': ['fussy'], 'fussy': ['fussy'],
  'recovery': ['recovery'], 'diastasis': ['diastasis'],
  'overwhelmed': ['calm'], 'calmer': ['calm'],
};

/// When nothing more specific fits, the stage's own doctor - a clinical read
/// is always one a doctor can talk through. Never on a quiet read.
const Map<String, List<String>> _kStageFallback = {
  'pregnancy': ['obstetrician'],
  'trying': ['gynaecologist'],
  'parenting': ['paediatrician'],
};

/// Never pitch on these.
const List<String> _kQuiet = [
  'loss', 'miscarriage', 'stillbirth', 'grief', 'ectopic', 'emergency',
  'bleeding', 'urgent',
];

Set<String> _words(String s) => {
      for (final w in s.toLowerCase().split(RegExp(r'[^a-z]+')))
        if (w.isNotEmpty) w,
    };

LifeStage? _stageOf(PvRead r) {
  if (r.id.startsWith('ttc_')) return LifeStage.tryingToConceive;
  if (r.id.startsWith('preg_')) return LifeStage.pregnancy;
  if (r.id.startsWith('pp_')) return LifeStage.parenting;
  return null;
}

/// The doctors a TTC read may not offer while a clinic owns her cycle: the
/// clinic is already her fertility doctor, and our rule is to explain, remind
/// and help her prepare, never to compete with the clinician who owns the
/// decision (CLAUDE.md, clinical ownership).
const Set<String> _kClinicWords = {
  'fertility', 'gynaecologist', 'gynecologist', 'gynaecology', 'andrologist',
  'specialist', 'ivf', 'iui',
};

/// Whether a clinic owns her cycle now, for [pvReadOfferFor]. False when the
/// store cannot say (local-first: no answer is the ordinary case).
bool pvReadClinicOwnsCycleNow() {
  try {
    return TtcStore.instance.ownership != TimingOwnership.parentveda;
  } catch (_) {
    return false;
  }
}

/// The one offering that fits [r], or null.
///
/// ⚠️ NO DOCTOR PITCH MID-ROUND (relevance Batch 4, TTC 15, 2026-10-28). With
/// [clinicOwnsCycle] a TTC read offers no clinician's consult: no fertility
/// doctor, no gynaecologist, not as a topic match and not as the stage's
/// fallback. A psychologist, a nutrition consult or a course (an IVF course
/// included: it helps her prepare) still can, because they sit beside her
/// clinic rather than in its place.
PvOfferingView? pvReadOfferFor(PvRead r,
    {List<PvOfferingView>? catalog, bool clinicOwnsCycle = false}) {
  final stage = _stageOf(r);
  if (stage == null) return null;
  final read = _words('${r.title.en} ${r.kicker.en} ${r.teaser.en}');
  if (read.any(_kQuiet.contains)) return null;
  if (r.sections.any((s) => s.callout?.tone == PvCalloutTone.urgent)) {
    return null;
  }
  // ⚠️ ONE PITCH PER PAGE (step 0 · S6). A parenting page that already
  // carries its own consult or course at the foot (a `PpConsult`) gets no
  // second offer mid-page. Parenting only: a pregnancy or TTC read's foot
  // tiles are its next steps, and the global pass gives each one a service.
  if (stage == LifeStage.parenting &&
      r.nextSteps.any(
      (n) => n.kind == PvNextKind.consult || n.kind == PvNextKind.course)) {
    return null;
  }
  final topics = {
    ...read.where(kPvOfferTopics.contains),
    for (final w in read) ...?kPvOfferAliases[w],
  };
  List<PvOfferingView> all;
  try {
    all = catalog ?? PvLearnCatalog.instance.all(stage: stage);
  } catch (_) {
    return null; // local-first: a catalogue that is not ready is no card
  }
  if (clinicOwnsCycle && stage == LifeStage.tryingToConceive) {
    all = [
      for (final v in all)
        if (v.kind != PvLearnKind.consult ||
            _words('${v.title} ${v.subtitle}').intersection(_kClinicWords).isEmpty)
          v,
    ];
  }
  PvOfferingView? pick(Set<String> want) {
    PvOfferingView? best;
    var bestScore = 0;
    for (final v in all) {
      final hit = _words('${v.title} ${v.subtitle}').intersection(want).length;
      if (hit > bestScore) {
        best = v;
        bestScore = hit;
      }
    }
    return best;
  }

  // Kept for revert: no topics returned null before the pick.
  return (topics.isEmpty ? null : pick(topics)) ??
      pick({...?_kStageFallback[switch (stage) {
        LifeStage.tryingToConceive => 'trying',
        LifeStage.pregnancy => 'pregnancy',
        _ => 'parenting',
      }]});
}

/// ⚠️ THE PAGE'S OWN CONSULT, NEXT TO THE WORRY (Feeding D2, approved
/// 2026-10-23 on claude.ai/artifact/6Kgs3uNdKsbyKybfbdzdRB; Health and You,
/// Maa use the same pattern). A parenting page that carries a `PpConsult`
/// had it only as the last tile, so a mother who read "see your doctor if
/// he isn't gaining" had to scroll the whole piece to find the person who
/// could help. Now the same consult also sits as the calm grey card right
/// under the page's first doctor box. It is the page's own offer, so S6's
/// rule still holds: one pitch per page, never the matcher's as well.
///
/// The 2026-09-18 rule ("a consult is a foot tile, not a purple button
/// mid-piece") was about the purple button, and that is not coming back:
/// this is the reader's own quiet card, and the foot tile stays.
PvReadNextStep? pvReadOwnConsult(PvRead r) {
  if (_stageOf(r) != LifeStage.parenting) return null;
  final read = _words('${r.title.en} ${r.kicker.en} ${r.teaser.en}');
  if (read.any(_kQuiet.contains)) return null;
  for (final n in r.nextSteps) {
    if (n.kind == PvNextKind.consult && n.surfaceId != null) return n;
  }
  return null;
}

/// ⚠️ A HEALTH CONSULT SAYS IT IS NOT FOR AN EMERGENCY (Health plan §3a,
/// 2026-10-25). A video call must never be what a parent reaches for when a
/// go-now sign is on screen, so every consult card on a Health page carries
/// the same quiet line as the door's expert row. Read off the read's id
/// (`pp_page_<section>_<page>`), so no other door changes.
///
/// You, Maa's after-BP page (door 3, 2026-10-25) carries it too: its consult
/// follows a go-now list.
String? pvReadConsultNote(PvRead r) =>
    r.id.startsWith('pp_page_parenting_health_') ||
            r.id == 'pp_page_parenting_maternal_body_after_bp'
        ? 'Not for an emergency. For that, call 112 or go to a hospital.'
        : null;

/// The section the page's own consult follows: its first doctor box, or the
/// matcher's slot when the page has none (after the second section, or the
/// last on a short read).
///
/// ⚠️ FREE HELP STAYS ABOVE IT (You, Maa M5; final review item 8,
/// 2026-10-27). The free helpline used to ride inside the first doctor box so
/// that it came before the paid card. It is its own card now, never inside a
/// doctor box, so a helpline card that comes after the anchor pulls the
/// consult down under it. Found by the one helpline constant, not by a title.
int pvReadOwnConsultAfter(PvRead r) {
  var i = r.sections.indexWhere((s) => s.callout?.tone == PvCalloutTone.urgent);
  if (i < 0) i = r.sections.length >= 3 ? 1 : r.sections.length - 1;
  final free = r.sections.lastIndexWhere(
      (s) => s.callout?.body.en.contains(kCrisisHelplineNumber) ?? false);
  return free > i ? free : i;
}

/// The page's own consult, drawn as the offer card is: one line of why, the
/// expert, who it is for, a chevron. No price, because none is live.
class PvReadConsultCard extends StatelessWidget {
  const PvReadConsultCard(
      {super.key, required this.step, required this.onTap, this.note});
  final PvReadNextStep step;
  final VoidCallback onTap;

  /// The quiet line under it ([pvReadConsultNote]).
  final String? note;

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF2F2C30);
    return Material(
      color: const Color(0xFFF3F3F4),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        key: const ValueKey('pv_read_own_consult'),
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
          child: Row(children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Want an expert to look at this with you?',
                        style: pvManrope(
                            fontSize: 12.5,
                            color: const Color(0xFF69636C),
                            height: 1.35)),
                    const SizedBox(height: 3),
                    Text(step.title.en,
                        style: pvManrope(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: ink,
                            height: 1.3)),
                    if (step.value.en.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(step.value.en,
                          style: pvManrope(
                              fontSize: 12.5, color: ink, height: 1.35)),
                    ],
                    if (note case final line?) ...[
                      const SizedBox(height: 3),
                      Text(line,
                          style: pvManrope(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF69636C),
                              height: 1.35)),
                    ],
                  ]),
            ),
            const Icon(Icons.chevron_right_rounded, color: ink),
          ]),
        ),
      ),
    );
  }
}

/// The card: quiet, one line of why, the price, a chevron.
class PvReadOfferCard extends StatelessWidget {
  const PvReadOfferCard({super.key, required this.offering});
  final PvOfferingView offering;

  String get _lead => switch (offering.kind) {
        PvLearnKind.consult => 'Want an expert to look at this with you?',
        PvLearnKind.course => 'Want to go deeper?',
        PvLearnKind.masterclass => 'Want to learn this live?',
        PvLearnKind.cohort => 'Want to do this with others?',
        PvLearnKind.classPack => 'Want to practise this with a teacher?',
      };

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF2F2C30);
    return Material(
      color: const Color(0xFFF3F3F4),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        key: ValueKey('pv_read_offer_${offering.id}'),
        borderRadius: BorderRadius.circular(16),
        onTap: () => pvOpenOffering(context, offering),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
          child: Row(children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_lead,
                        style: pvManrope(
                            fontSize: 12.5,
                            color: const Color(0xFF69636C),
                            height: 1.35)),
                    const SizedBox(height: 3),
                    Text(offering.title,
                        style: pvManrope(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: ink,
                            height: 1.3)),
                    const SizedBox(height: 2),
                    Text(offering.priceLabel,
                        style: pvManrope(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: ink)),
                  ]),
            ),
            const Icon(Icons.chevron_right_rounded, color: ink),
          ]),
        ),
      ),
    );
  }
}
