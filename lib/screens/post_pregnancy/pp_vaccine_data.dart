// =============================================================================
//  ParentVeda Vaccination Tracker - schedule data, content + store (redesign)
// -----------------------------------------------------------------------------
//  The journey-first tracker's source of truth. Models the immunisation schedule
//  as a chronological set of age VISITS, each carrying its vaccines, status,
//  govt/IAP note, date and one educational insight - so parents feel they are
//  following their child's health journey, not browsing records. Each Vaccine
//  carries its "Learn Why" (why it matters, diseases, expected reactions, myths,
//  FAQs) and "After-Care" (comfort, red flags, products). Reassuring language
//  only - never "missed/danger/critical". Seeded for Aarav (born 8 Mar 2026,
//  ~4 months). Reuses the existing NotificationService for reminders. This is the
//  redesign that replaces the old vaccination_screen (kept, commented, for revert).
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show DateUtils;
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/remote/child_scoped_store.dart';
import '../../care_partner/care_journey.dart';
import '../../services/notification_service.dart';
import '../../services/remote/supabase_repo.dart';
import '../../services/remote/sync_registry.dart';
import '../../services/family_profile.dart';
import 'pp_child_profile.dart';
import 'pp_health_data.dart';

// Reassuring status language - "due" means recommended now, never "missed".
enum VaxStatus { done, due, upcoming }

String vaxStatusLabel(VaxStatus s) => switch (s) {
      VaxStatus.done => 'Done',
      VaxStatus.due => 'Due now',
      VaxStatus.upcoming => 'Upcoming',
    };

/// One vaccine - everything the Learn-Why + After-Care surfaces show for it.
class Vaccine {
  const Vaccine({
    required this.id,
    required this.name,
    required this.shortName,
    required this.protects,
    required this.diseases,
    required this.why,
    this.reactions = const ['Mild soreness or redness where the shot was given', 'A low-grade fever for a day or two', 'Being a little more sleepy or fussy than usual'],
    this.myths = const [],
    this.faqs = const [],
    this.comfort = const ['Extra cuddles and feeds; a cool compress for soreness', "Paracetamol only if he's uncomfortable - weight-based, as your paediatrician advises"],
    this.redFlags = const ['Difficult or noisy breathing, or swelling of the face/lips', 'A seizure, or unusual floppiness/drowsiness', 'A high fever that won\'t settle, or a rash with vomiting'],
    this.products = const [],
  });

  final String id;
  final String name; // "Pneumococcal (PCV)"
  final String shortName; // "PCV"
  final String protects; // one-line
  final List<String> diseases;
  final String why;
  final List<String> reactions;
  final List<(String, String)> myths; // (myth, fact)
  final List<(String, String)> faqs; // (question, answer)
  final List<String> comfort;
  final List<String> redFlags;
  final List<(String, String, String, String)> products; // (title, why, price, productId)
}

/// One age visit on the journey (groups the vaccines given together).
class VaxVisit {
  const VaxVisit({
    required this.id,
    required this.ageLabel,
    required this.ageDays,
    required this.vaccineIds,
    required this.status,
    required this.govtFree,
    required this.date,
    required this.insight,
    this.leadVaccineId,
    this.due,
  });

  final String id;
  final String ageLabel; // "14 weeks", "9 months"
  final int ageDays; // for ordering
  final List<String> vaccineIds;
  final VaxStatus status;
  final bool govtFree; // free at a govt centre
  final String date; // display date (given or due)
  final String insight; // one warm "why now" line
  final String? leadVaccineId; // the vaccine to spotlight (e.g. PCV for the due visit)
  final DateTime? due; // absolute due date for reminders (upcoming/due only)

  List<Vaccine> get vaccines => vaccineIds.map(vaccineById).toList();
  Vaccine get lead => vaccineById(leadVaccineId ?? vaccineIds.first);
}

// ---- vaccine catalogue ------------------------------------------------------
const List<Vaccine> kVaccines = [
  Vaccine(
    id: 'pcv',
    name: 'Pneumococcal (PCV)',
    shortName: 'PCV',
    protects: 'Guards against some of the most serious infections of the early years.',
    diseases: ['Pneumonia', 'Meningitis (infection of the brain\'s lining)', 'Blood infections (sepsis)', 'Some ear infections'],
    why:
        'PCV protects against pneumococcus - a bacterium behind some of the most dangerous infections a baby can face. The primary series finishes around now, exactly as the passive immunity from birth is fading, which is what makes the timing so powerful.',
    myths: [
      ("It's just for pneumonia, so it's optional.", 'PCV also prevents meningitis and sepsis - among the most serious infant illnesses. It is a core part of the schedule for good reason.'),
    ],
    faqs: [
      ('Can he have it with a mild cold?', 'A mild cold without a high fever is usually fine - your paediatrician makes the final call on the day.'),
      ('Will three doses hurt more than one?', 'Each dose is a small pinch. The three-dose series is what builds strong, lasting protection.'),
    ],
    products: [
      ('Digital thermometer', 'For calm, accurate temperature checks after the shot.', '₹499', 'thermometer'),
      ('White-noise soother', 'Helps a fussy, sore evening settle.', '₹1,499', 'dozy'),
    ],
  ),
  Vaccine(
    id: 'penta',
    name: 'Pentavalent (DTP-HepB-Hib)',
    shortName: 'Pentavalent',
    protects: 'Five diseases in one gentle shot.',
    diseases: ['Diphtheria', 'Tetanus', 'Whooping cough (pertussis)', 'Hepatitis B', 'Hib (a cause of meningitis)'],
    why:
        'The pentavalent shot bundles protection against five serious diseases into a single injection - fewer pricks for your baby, and strong early cover against illnesses that are hardest on the very young.',
    myths: [
      ('The fever afterwards means something went wrong.', 'A mild fever is expected and is a sign the immune system is responding. It usually settles within a day or two.'),
    ],
    faqs: [
      ('Why five in one?', 'Combining them means fewer injections and fewer visits, with the same protection.'),
    ],
  ),
  Vaccine(
    id: 'rota',
    name: 'Rotavirus',
    shortName: 'Rotavirus',
    protects: 'Prevents severe vomiting-and-diarrhoea illness.',
    diseases: ['Rotavirus gastroenteritis (severe vomiting and diarrhoea, a major cause of dehydration in babies)'],
    why:
        'Rotavirus is a leading cause of severe diarrhoea and dangerous dehydration in babies. This one is given as drops by mouth - no needle - and dramatically reduces the risk of a hospital visit for dehydration.',
    reactions: ['Occasionally a little extra fussiness or mild, temporary loose stools'],
    faqs: [
      ('Is it a drink, not a shot?', 'Yes - rotavirus vaccine is given as oral drops. Most babies take it happily.'),
      ('What if he spits it out?', "Mention it to the nurse - they'll advise whether a top-up dose is needed."),
    ],
  ),
  Vaccine(
    id: 'ipv',
    name: 'Polio (IPV)',
    shortName: 'IPV',
    protects: 'Protects against polio.',
    diseases: ['Poliomyelitis (polio) - a virus that can cause lifelong paralysis'],
    why:
        'Polio can cause permanent paralysis. Thanks to vaccination it is now extremely rare, but keeping every baby protected is exactly how it stays that way. IPV is the injectable form, given alongside oral polio drops.',
    faqs: [
      ('Why does he need injected polio when he also gets drops?',
          'They do different jobs. The injection gives strong protection in the blood; the drops give protection in the gut, which is what stops the virus spreading to other children. India uses both on purpose.'),
      ('Polio is gone from India - why still vaccinate?',
          'India is polio-free because vaccination did not stop. The virus still circulates in a few countries and travels, so keeping cover high is what holds the line.'),
    ],
  ),
  Vaccine(
    id: 'opv',
    name: 'Oral Polio (OPV)',
    shortName: 'OPV',
    protects: 'Oral drops against polio.',
    diseases: ['Poliomyelitis (polio)'],
    why: 'OPV is the oral (drops) polio vaccine, given alongside IPV for broad, lasting protection against polio.',
    reactions: ['Usually none - it is given as gentle oral drops'],
    myths: [
      ('The drops are unsafe or are a way of making children infertile.',
          'This claim has been circulating for decades and has been investigated repeatedly. OPV contains a weakened poliovirus and nothing that affects fertility. It is the reason India is polio-free.'),
    ],
    faqs: [
      ('He spat some out - does the dose still count?',
          'If he spits out most of it within a few minutes, tell the vaccinator; they will usually repeat it. A small dribble is fine.'),
      ('Can he feed straight after the drops?',
          'Yes. There is no need to hold off feeding before or after OPV.'),
    ],
  ),
  Vaccine(
    id: 'bcg',
    name: 'BCG',
    shortName: 'BCG',
    protects: 'Protects against severe forms of tuberculosis.',
    diseases: ['Severe childhood tuberculosis (including TB meningitis)'],
    why:
        'Given at birth, BCG protects newborns against the most severe forms of TB. A small raised mark or tiny scar at the injection site over the following weeks is normal and expected.',
    reactions: ['A small swelling that may form a tiny scar over weeks - this is normal'],
    myths: [
      ('No scar means the BCG failed and must be repeated.',
          'A scar is common but not necessary. Many protected children never form one, and repeating on that basis alone is not recommended.'),
    ],
    faqs: [
      ('There is no scar. Did it work?',
          'Usually yes. A visible scar is common but not required, and its absence is not proof the vaccine failed. Ask your paediatrician before assuming it needs repeating.'),
      ('A small sore or lump appeared weeks later. Is that normal?',
          'A small raised spot that slowly forms, sometimes weeps a little and then heals into a flat mark over weeks or months is the expected course. Keep it clean and dry, and do not squeeze or bandage it.'),
    ],
  ),
  Vaccine(
    id: 'hepb',
    name: 'Hepatitis B (birth dose)',
    shortName: 'Hepatitis B',
    protects: 'Protects the liver from hepatitis B.',
    diseases: ['Hepatitis B (a serious, sometimes lifelong liver infection)'],
    why: 'The birth dose of Hepatitis B gives early protection against a virus that can cause long-term liver disease. Later doses in the pentavalent shot complete the cover.',
    myths: [
      ('A newborn\'s body is too small and too new for a vaccine.',
          'A newborn meets an enormous number of germs from the first breath. One vaccine is a very small addition, and this one works best precisely because it is given early.'),
    ],
    faqs: [
      ('Why so soon - can it not wait?',
          'The birth dose works best in the first 24 hours, because it is protecting against transmission around the time of birth itself. Waiting loses most of that benefit.'),
      ('I tested negative. Does he still need it?',
          'Yes, and it is still recommended. It protects him from exposure later in childhood too, not only at birth.'),
    ],
  ),
  Vaccine(
    id: 'vitk',
    name: 'Vitamin K',
    shortName: 'Vitamin K',
    protects: 'Prevents a rare but serious bleeding problem in newborns.',
    diseases: ['Vitamin K deficiency bleeding (VKDB) in newborns'],
    why: 'Not a vaccine but given at birth: a single Vitamin K injection prevents a rare but dangerous bleeding disorder in newborns. A routine, reassuring first-day step.',
    reactions: ['Usually none beyond a brief pinch'],
    myths: [
      ('It is an unnecessary injection for a healthy baby.',
          'Newborns are all born with low vitamin K, healthy or not, and the bleeding it prevents can happen without warning in a baby who seemed entirely well.'),
    ],
    faqs: [
      ('Is this a vaccine?',
          'No. It is a vitamin newborns are simply born low on, given once to prevent a rare but serious bleeding problem in the first weeks. It is on this list because it is given at the same visit.'),
      ('Can it be given by mouth instead?',
          'An oral course exists but needs several correctly timed doses and is less reliable. The single injection is what most paediatricians recommend.'),
    ],
  ),
  Vaccine(
    id: 'mmr',
    name: 'Measles, Mumps & Rubella (MMR/MR)',
    shortName: 'MMR',
    protects: 'Protects against measles, mumps and rubella.',
    diseases: ['Measles', 'Mumps', 'Rubella (German measles)'],
    why:
        'Measles is far more dangerous than many parents realise, and highly contagious. The MMR given around nine months (with a booster later) is the strongest protection - for your child and for the babies around him too soon to be vaccinated.',
    myths: [
      ('MMR is linked to autism.', 'This has been thoroughly and repeatedly disproven by large, careful studies. MMR does not cause autism - the original claim was retracted as fraudulent.'),
      ('Measles is a harmless childhood illness.', 'Measles can cause pneumonia, brain inflammation and, rarely, death. The vaccine prevents this entirely.'),
    ],
    faqs: [
      ('Why two doses?', 'The first builds protection; the second makes sure it is strong and lasting in nearly every child.'),
    ],
  ),
  Vaccine(
    id: 'typhoid',
    name: 'Typhoid conjugate (TCV)',
    shortName: 'Typhoid',
    protects: 'Protects against typhoid fever.',
    diseases: ['Typhoid fever (a serious bacterial infection common in many regions)'],
    why: 'Typhoid conjugate vaccine gives lasting protection against typhoid fever - especially valuable in regions where it is common.',
    faqs: [
      ('We are careful with food and water. Is it needed?',
          'Care helps and is worth keeping up, but typhoid spreads through water and food handled outside the home too. The vaccine covers what hygiene at home cannot.'),
      ('How long does it protect for?',
          'The conjugate vaccine gives several years of protection from one dose. Your paediatrician will say whether and when a booster applies.'),
    ],
  ),
  Vaccine(
    id: 'hepa',
    name: 'Hepatitis A',
    shortName: 'Hepatitis A',
    protects: 'Protects the liver from hepatitis A.',
    diseases: ['Hepatitis A (a liver infection spread through food and water)'],
    why: 'Hepatitis A spreads through contaminated food and water. The vaccine, given in the second year, gives long-lasting protection.',
    faqs: [
      ('Is one dose enough?',
          'No - it is a two-dose course, with the second usually six months or more after the first. Protection is much better after both.'),
      ('He had hepatitis A already. Does he still need it?',
          'Usually not, but confirm with your paediatrician: past infection generally gives lasting protection.'),
    ],
  ),
  Vaccine(
    id: 'varicella',
    name: 'Varicella (Chickenpox)',
    shortName: 'Varicella',
    protects: 'Protects against chickenpox.',
    diseases: ['Chickenpox (varicella)'],
    why: 'Chickenpox is usually mild but can occasionally be serious. The vaccine prevents it and the discomfort of the itchy rash and fever.',
    myths: [
      ('Chickenpox is a harmless childhood illness.',
          'It is mild for most children and genuinely dangerous for a few, and nobody can tell in advance which. It also stays in the body and can return as shingles decades later.'),
    ],
    faqs: [
      ('Is it not better to just catch chickenpox?',
          'Most children recover fine, but a minority get serious complications - skin infection, pneumonia, rarely brain inflammation - and there is no way to know in advance which child that will be. The vaccine avoids the gamble.'),
      ('He got chickenpox anyway after being vaccinated.',
          'It happens, and it is almost always far milder - fewer spots, shorter, and much less likely to cause complications. That is the vaccine doing its job, not failing.'),
    ],
  ),
  // Added 2026-10-02 (gap analysis P1: "the schedule stops at two").
  // REQUIRED_REVIEW (paediatrician): ages and the UIP/IAP notes.
  Vaccine(
    id: 'dtp',
    name: 'DTP booster (diphtheria, tetanus, whooping cough)',
    shortName: 'DTP booster',
    protects: 'Tops up protection against diphtheria, tetanus and whooping cough before school.',
    diseases: ['Diphtheria', 'Tetanus', 'Whooping cough (pertussis)'],
    why: 'Protection from the baby shots fades over the years. The booster at four to six years carries it through the school years, when cuts, scrapes and crowded classrooms are part of every day.',
    faqs: [
      ('Is this free?', 'Under the government programme (UIP) the second DPT booster is given free at five to six years. Private clinics usually give it as DTaP or DTwP between four and six.'),
      ('He had a lot of shots as a baby. Why more?', 'Some protection wears off with time. A booster reminds the immune system, and is far gentler than the illnesses it prevents.'),
    ],
  ),
  Vaccine(
    id: 'td',
    name: 'Td or Tdap (tetanus, diphtheria, whooping cough)',
    shortName: 'Td / Tdap',
    protects: 'Keeps tetanus and diphtheria protection going into the teenage years.',
    diseases: ['Tetanus', 'Diphtheria', 'Whooping cough (Tdap only)'],
    why: 'The government programme gives Td at ten and at sixteen; private clinics often give Tdap at ten to twelve. It is the dose that keeps a deep cut from being a tetanus risk.',
    faqs: [
      ('Is this the same as a tetanus shot after an injury?', 'It covers tetanus, and a child who is up to date often needs nothing extra after a cut. The doctor treating the injury will ask when the last dose was, so keep this record.'),
    ],
  ),
];

Vaccine vaccineById(String id) => kVaccines.firstWhere((v) => v.id == id, orElse: () => kVaccines.first);

// ---- the schedule (chronological visits, seeded for Aarav) ------------------
const List<VaxVisit> kVaxVisits = [
  VaxVisit(
    id: 'birth',
    ageLabel: 'At birth',
    ageDays: 0,
    vaccineIds: ['bcg', 'opv', 'hepb', 'vitk'],
    status: VaxStatus.done,
    govtFree: true,
    date: '8 Mar 2026',
    insight: 'The very first protection - given in the first hours to guard against TB, polio and hepatitis B from day one.',
    leadVaccineId: 'bcg',
  ),
  VaxVisit(
    id: 'wk6',
    ageLabel: '6 weeks',
    ageDays: 42,
    vaccineIds: ['penta', 'opv', 'ipv', 'rota', 'pcv'],
    status: VaxStatus.done,
    govtFree: true,
    date: '19 Apr 2026',
    insight: 'The first big visit - five diseases covered in one shot, plus oral drops. A little fussiness after is normal.',
    leadVaccineId: 'penta',
  ),
  VaxVisit(
    id: 'wk10',
    ageLabel: '10 weeks',
    ageDays: 70,
    vaccineIds: ['penta', 'rota', 'ipv', 'pcv'],
    status: VaxStatus.done,
    govtFree: true,
    date: '17 May 2026',
    insight: 'The second doses - each one deepens the protection the first began to build.',
    leadVaccineId: 'penta',
  ),
  VaxVisit(
    id: 'wk14',
    ageLabel: '14 weeks',
    ageDays: 98,
    vaccineIds: ['penta', 'rota', 'ipv', 'pcv'],
    status: VaxStatus.due,
    govtFree: true,
    date: '22 Jul 2026',
    insight: "The third doses complete his primary series - the window his early immunity is fully built. It's due now.",
    leadVaccineId: 'pcv',
    due: null, // set at runtime via vaxDueDate()
  ),
  VaxVisit(
    id: 'mo6',
    ageLabel: '6 months',
    ageDays: 182,
    vaccineIds: ['opv', 'hepb'],
    status: VaxStatus.upcoming,
    govtFree: true,
    date: '8 Sep 2026',
    insight: 'A lighter visit - a top-up of polio and hepatitis B protection. Often around when first foods begin.',
    leadVaccineId: 'opv',
  ),
  VaxVisit(
    id: 'mo9',
    ageLabel: '9 months',
    ageDays: 274,
    vaccineIds: ['mmr', 'opv'],
    status: VaxStatus.upcoming,
    govtFree: true,
    date: '8 Dec 2026',
    insight: 'The first measles protection - one of the most important of all, as maternal immunity fades.',
    leadVaccineId: 'mmr',
  ),
  VaxVisit(
    id: 'mo12',
    ageLabel: '12 months',
    ageDays: 365,
    vaccineIds: ['hepa', 'pcv'],
    status: VaxStatus.upcoming,
    govtFree: false,
    date: '8 Mar 2027',
    insight: 'A PCV booster and the first hepatitis A dose mark the end of the busy first year.',
    leadVaccineId: 'hepa',
  ),
  VaxVisit(
    id: 'mo15',
    ageLabel: '15 months',
    ageDays: 456,
    vaccineIds: ['mmr', 'varicella'],
    status: VaxStatus.upcoming,
    govtFree: false,
    date: '8 Jun 2027',
    insight: 'The MMR booster locks in measles protection, and chickenpox cover begins.',
    leadVaccineId: 'mmr',
  ),
  VaxVisit(
    id: 'mo18',
    ageLabel: '16–18 months',
    ageDays: 540,
    vaccineIds: ['penta', 'ipv', 'opv'],
    status: VaxStatus.upcoming,
    govtFree: true,
    date: '8 Sep 2027',
    insight: 'First boosters of the early shots - keeping the protection strong into the toddler years.',
    leadVaccineId: 'penta',
  ),
  VaxVisit(
    id: 'yr2',
    ageLabel: '2 years',
    ageDays: 730,
    vaccineIds: ['typhoid', 'hepa'],
    status: VaxStatus.upcoming,
    govtFree: false,
    date: '8 Mar 2028',
    insight: 'Typhoid protection and the second hepatitis A dose - valuable cover for the exploring years ahead.',
    leadVaccineId: 'typhoid',
  ),
  // Added 2026-10-02: the schedule used to end at two years.
  VaxVisit(
    id: 'yr5',
    ageLabel: '4 to 6 years',
    ageDays: 1461,
    vaccineIds: ['dtp', 'mmr', 'varicella'],
    status: VaxStatus.upcoming,
    govtFree: false,
    date: '',
    insight: 'The school-entry boosters. The DTP booster is free at a government centre at five to six; the third MMR and second chickenpox doses are on the private (IAP) schedule. Ask which your paediatrician follows.',
    leadVaccineId: 'dtp',
  ),
  VaxVisit(
    id: 'yr10',
    ageLabel: '10 years',
    ageDays: 3652,
    vaccineIds: ['td'],
    status: VaxStatus.upcoming,
    govtFree: true,
    date: '',
    insight: 'A look ahead: Td at ten (and again at sixteen) under the government programme, or Tdap at ten to twelve privately. HPV is also offered from nine; ask your paediatrician.',
    leadVaccineId: 'td',
  ),
];

VaxVisit vaxVisitById(String id) => kVaxVisits.firstWhere((v) => v.id == id, orElse: () => kVaxVisits.first);

// =============================================================================
//  Dose rows and shared reminders (2026-10-17, 0104, sync log step 6)
// =============================================================================

/// One dose's synced state: one row per (child, visit) in `pp_vaccine_doses`.
class VaxDoseRow {
  const VaxDoseRow({
    required this.id,
    required this.done,
    this.givenOn,
    required this.reminder,
    this.reminderAt,
  });

  final String id;
  final bool done;
  final DateTime? givenOn;
  final bool reminder;
  final DateTime? reminderAt;

  /// The row's own columns. `reminder_hour`, `reminder_minute` and
  /// `reminder_id` (0023) stay unused: `reminder_at` holds the whole moment.
  Map<String, dynamic> toCloud() => {
        'vaccine_id': id,
        'done': done,
        'done_at': givenOn?.toUtc().toIso8601String(),
        'reminder': reminder,
        'reminder_at': reminderAt?.toUtc().toIso8601String(),
      };

  static VaxDoseRow fromCloud(Map<String, dynamic> r) {
    DateTime? at(Object? v) =>
        v == null ? null : DateTime.tryParse(v.toString())?.toLocal();
    return VaxDoseRow(
      id: (r['vaccine_id'] ?? '').toString(),
      done: r['done'] == true,
      givenOn: at(r['done_at']),
      reminder: r['reminder'] == true,
      reminderAt: at(r['reminder_at']),
    );
  }
}

/// The phone notification id for a visit's alarm. One helper, so arming and
/// cancelling always agree. Same value the screens used before 2026-10-17, so
/// an alarm armed by an older version can still be cancelled.
int vaxAlarmId(String visitId) => visitId.hashCode & 0x7fffffff;

/// The alarm id for [visitId] of [childId] (B11, 2026-10-25). Twins share
/// every visit id, so one id each would have one twin's reminder replace the
/// other's. The first child keeps the bare id an older version armed, so its
/// alarms can still be cancelled; every other child's id names the child.
/// The same rule as the message ids (`ppMessageIdPrefix`).
int vaxAlarmIdFor(String visitId, {String? childId, String? firstChildId}) =>
    childId == null || childId == firstChildId
        ? vaxAlarmId(visitId)
        : '$childId|$visitId'.hashCode & 0x7fffffff;

/// Pure: which alarms this phone must arm and which it must cancel, going
/// from [before] to [after] (visit id -> fire time). An alarm whose time has
/// passed is never armed. Unit-tested in `test/pp_records_merge_test.dart`.
({Map<String, DateTime> arm, Set<String> cancel}) vaxAlarmChanges(
  Map<String, DateTime> before,
  Map<String, DateTime> after,
  DateTime now,
) {
  final arm = <String, DateTime>{};
  final cancel = <String>{};
  for (final id in before.keys) {
    if (!after.containsKey(id)) cancel.add(id);
  }
  for (final e in after.entries) {
    final was = before[e.key];
    if (was != null && was.isAtSameMomentAs(e.value)) continue;
    if (was != null) cancel.add(e.key); // moved: replace the old one
    if (e.value.isAfter(now)) arm[e.key] = e.value;
  }
  return (arm: arm, cancel: cancel);
}

/// The alarm's words, built from the visit and the moment it fires, so the
/// other parent's phone writes the same reminder (moved here from the two
/// vaccine screens on 2026-10-17).
/// [child] is whose dose it is (B11): an alarm armed for the twin not on
/// screen speaks of that twin and that twin's date. Null: the child on screen.
({String title, String body}) vaxReminderText(VaxVisit v, DateTime at, {Child? child}) {
  // final due = vaxVisitDate(v) ?? vaxDueDate(); // kept for revert
  final due = child == null
      ? vaxVisitDate(v) ?? vaxDueDate()
      : DateTime(child.dob.year, child.dob.month, child.dob.day, 9)
          .add(Duration(days: v.ageDays));
  final daysBefore = DateTime(due.year, due.month, due.day)
      .difference(DateTime(at.year, at.month, at.day))
      .inDays;
  // final name = ChildProfileStore.instance.name; // kept for revert
  final name = child?.name ?? ChildProfileStore.instance.name;
  final shot = v.lead.shortName;
  return (
    title: 'Vaccine reminder - $shot',
    body: daysBefore <= 0
        ? "$name's $shot (${v.ageLabel}) is due today."
        : "$name's $shot (${v.ageLabel}) is due ${daysBefore == 1 ? 'tomorrow' : 'in $daysBefore days'} - ${vaxDateLabel(due)}.",
  );
}

/// When the reminder for the next visit should fire: that visit's date for
/// THIS child, at 9am. Falls back to tomorrow morning when nothing is left.
/// "8 Mar 2026".
String vaxDateLabel(DateTime d) {
  const m = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug',
    'Sep', 'Oct', 'Nov', 'Dec'];
  return '${d.day} ${m[d.month]} ${d.year}';
}

DateTime vaxDueDate() {
  final next = VaxStore.instance.nextVisit;
  if (next != null) return vaxVisitDate(next)!;
  final t = DateTime.now().add(const Duration(days: 1));
  return DateTime(t.year, t.month, t.day, 9, 0);
}

/// A visit's date for this child (date of birth plus the visit's age) at 9am,
/// for the reminder scheduler.
///
/// ⚠️ FIXED 2026-10-02 (gap analysis P1). This parsed `VaxVisit.date`, a
/// display string from one demo baby's calendar ('8 Mar 2027'), so every
/// parent's vaccine alarm fired on that baby's dates. The labels were fixed
/// earlier (VaxStore.dateLabelFor); the alarm was not. Never null now; the
/// nullable type is kept so the two callers need no change.
DateTime? vaxVisitDate(VaxVisit v) {
  final d = ChildProfileStore.instance.dob.add(Duration(days: v.ageDays));
  return DateTime(d.year, d.month, d.day, 9, 0);
}

/* Kept for revert: the demo-calendar versions.
/// The due date for the current "due" visit (kept aligned with the app's 22 Jul
/// scenario). Passed to the reminder scheduler.
DateTime vaxDueDate() => DateTime(2026, 7, 22, 9, 0);

/// Parse a visit's display date ("22 Jul 2026") into a DateTime at 9am, for the
/// reminder scheduler. Returns null if it can't be parsed.
DateTime? vaxVisitDate(VaxVisit v) {
  const months = {'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6, 'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12};
  final parts = v.date.split(' ');
  if (parts.length != 3) return null;
  final d = int.tryParse(parts[0]);
  final m = months[parts[1]];
  final y = int.tryParse(parts[2]);
  if (d == null || m == null || y == null) return null;
  return DateTime(y, m, d, 9, 0);
}
*/

// =============================================================================
//  VaxStore - completed visits + reminders (in-memory, ChangeNotifier singleton)
// =============================================================================
/// Doses on the private (IAP) schedule that the government programme (UIP)
/// does not give. REQUIRED_REVIEW (paediatrician): UIP gives MR, not MMR, and
/// adds JE in endemic districts; this set is deliberately the clear cases only.
const Set<String> kVaxPrivateOnly = {'hepa', 'typhoid', 'varicella'};

class VaxStore extends ChangeNotifier {
  VaxStore._();
  static final VaxStore instance = VaxStore._();

  // EMPTY, not seeded. This used to start as {every visit the SCHEDULE calls
  // done}, so a parent who had recorded nothing opened the tracker to find
  // three doses already ticked - our demo child's history presented as hers.
  // A dose is "done" only when SHE marks it. See statusOf() for how the
  // schedule's own status is now read honestly.
  // ⚠️ ONE RECORD PER CHILD (B11, 2026-10-25). These four were one set for
  // the family, keyed by visit, so twin A's 6-week dose read as done for twin
  // B, and B's reminder was A's. They now live in [_VaxChild], one per child,
  // and the getters below are the child on screen's, so every read and write
  // in this class is unchanged. A record saved before B11 joins that child
  // (PerChild). Kept for revert:
  //   final Set<String> _done = {};
  //   final Set<String> _reminders = {};
  //   final Map<String, DateTime> _givenOn = {};
  //   final Map<String, DateTime> _reminderAt = {};
  final PerChild<_VaxChild> _vaxBy = PerChild<_VaxChild>(_VaxChild.new);
  _VaxChild get _st => _vaxBy.of(_childId, _childId);
  _VaxChild _of(String childId) => _vaxBy.of(childId, _childId);
  Set<String> get _done => _st.done;
  Set<String> get _reminders => _st.reminders;
  Map<String, DateTime> get _givenOn => _st.givenOn;
  Map<String, DateTime> get _reminderAt => _st.reminderAt;

  /// Whether [visitId] is recorded as given for [childId] (B11): the messages
  /// remind every child of their own visits, not only the one on screen.
  bool isDoneFor(String childId, String visitId) =>
      _of(childId).done.contains(visitId);

  // _givenOn: the day each dose was given, when the parent said (2026-10-07,
  // gap analysis P1: "a dose can be ticked but not dated"). Syncs to the
  // `done_at` column 0023 already has. Missing = ticked without a date.
  //
  // _reminderAt: when each reminder fires (2026-10-17, 0104). Reminders are
  // SHARED: the time syncs, and each parent's phone arms its own alarm from
  // it (the user: both phones should buzz). The alarm itself never syncs; it
  // is derived here.

  bool _loaded = false;
  static const _prefsKey = 'pp_vax';
  static const _table = 'pp_vaccine_doses';
  // Newer-wins bookkeeping, keyed by dose (0104, sync log step 6). A dose row
  // is state, not a list item, so it has no removed_at: un-ticking sends
  // done = false.
  final ChildLogLedger _sync = ChildLogLedger(_table, 'pp_vax_sync',
      keyColumn: 'vaccine_id', hasRemovedAt: false);

  String? get _childId => ChildProfileStore.instance.activeChildId;

  // ---- persistence (local-first, then cloud) -------------------------------
  // Everything in _done / _reminders is now parent-entered by construction
  // (nothing seeds them), so it all syncs - no seed-guard needed.
  Future<void> init() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw != null) {
        final j = Map<String, dynamic>.from(jsonDecode(raw));
        // Per child since B11; a blob from before is the family's one record
        // (the same shape), which waits in the legacy bucket.
        if (j['byChild'] is Map) {
          _vaxBy.loadJson(j['byChild'], (v) => v is Map ? _VaxChild.fromJson(v) : null);
        } else {
          _vaxBy.byChild[PerChild.legacy] = _VaxChild.fromJson(j);
        }
        // The one-record read, kept for revert:
        // for (final e in (j['done'] as List? ?? [])) {
        //   _done.add(e.toString());
        // }
        // for (final e in (j['reminders'] as List? ?? [])) {
        //   _reminders.add(e.toString());
        // }
        // final given = j['givenOn'];
        // if (given is Map) {
        //   given.forEach((k, v) {
        //     final d = DateTime.tryParse(v.toString());
        //     if (d != null) _givenOn[k.toString()] = d;
        //   });
        // }
        // final at = j['reminderAt'];
        // if (at is Map) {
        //   at.forEach((k, v) {
        //     final d = DateTime.tryParse(v.toString());
        //     if (d != null) _reminderAt[k.toString()] = d;
        //   });
        // }
      }
    } catch (_) {/* keep the schedule defaults */}
    await _sync.load();
    SyncRegistry.registerPending(_hasPending);
    // Switching child changes what every read returns (B11).
    ChildProfileStore.instance.addListener(notifyListeners);
    _loaded = true;
    notifyListeners();
    try {
      await _syncFromCloud();
    } catch (_) {/* stay local */}
  }

  /// A sign-out, or another account signing in (2026-10-17): this store
  /// forgets the person in memory; the cloud keeps it.
  void _resetLocal() {
    // _done.clear(); _reminders.clear(); _givenOn.clear(); _reminderAt.clear(); // kept for revert
    _vaxBy.clear();
    _sync.clear();
    notifyListeners();
  }

  /// Test-only: empty, for every child, and loaded, so nothing reads prefs (B11).
  @visibleForTesting
  void debugReset() {
    _resetLocal();
    _loaded = true;
  }

  Future<void> _syncFromCloud() async {
    SyncRegistry.register(_syncFromCloud);
    SyncRegistry.registerReset(_resetLocal);
    final childId = _childId;
    if (!SupabaseRepo.isLoggedIn || childId == null) return;
    try {
      // Every child, the one on screen first so a record saved before B11
      // joins it (B11, 2026-10-25). The loop's body is the one-child pull.
      for (final c in [childId, ...ChildProfileStore.instance.childIds.where((x) => x != childId)]) {
        final s = _of(c);
        final before = _alarms(s);
        final merged = await _sync.pull<VaxDoseRow>(
          childId: c,
          local: _rowsFor(c),
          idOf: (d) => d.id,
          fromRow: VaxDoseRow.fromCloud,
        );
        s.done.clear();
        s.reminders.clear();
        s.givenOn.clear();
        s.reminderAt.clear();
        for (final d in merged) {
          if (d.done) s.done.add(d.id);
          if (d.givenOn != null) s.givenOn[d.id] = d.givenOn!;
          if (d.reminder) s.reminders.add(d.id);
          if (d.reminderAt != null) s.reminderAt[d.id] = d.reminderAt!;
        }
        _applyAlarmChanges(vaxAlarmChanges(before, _alarms(s), DateTime.now()), c);
      }
      await _persist();
      notifyListeners();
      await _pushWaiting();
    } catch (_) {/* offline - keep local */}
  }

  /// The old pull, kept for revert: it only ever ADDED doses, so a dose
  /// un-ticked on one phone never reached the other.
  // ignore: unused_element
  Future<void> _syncFromCloudKept(String childId) async {
    try {
      final rows = await SupabaseRepo.fetchByChild(_table, childId);
      for (final r in rows) {
        final id = (r['vaccine_id'] ?? '').toString();
        if (id.isEmpty) continue;
        if (r['done'] == true) _done.add(id);
        final at = r['done_at'] == null ? null : DateTime.tryParse(r['done_at'].toString());
        if (at != null) _givenOn.putIfAbsent(id, () => at.toLocal());
        if (r['reminder'] == true) _reminders.add(id);
      }
      // Push up anything only this device knows (parent-marked doses only).
      final cloudIds = {for (final r in rows) (r['vaccine_id'] ?? '').toString()};
      for (final id in {..._done, ..._reminders}) {
        if (cloudIds.contains(id)) continue;
        await _pushDose(id);
      }
      await _persist();
      notifyListeners();
    } catch (_) {/* offline - keep local */}
  }

  bool _hasPending() => _sync.hasPending;

  /// Every dose this phone has any state for: ticked, reminded, or changed
  /// here and remembered by the book (so an un-tick still merges).
  List<VaxDoseRow> _rowsFor(String childId) {
    final s = _of(childId);
    return [
      for (final id in {...s.done, ...s.reminders, ..._sync.keysFor(childId)})
        _rowOf(id, s),
    ];
  }

  VaxDoseRow _rowOf(String id, [_VaxChild? of]) {
    final s = of ?? _st;
    return VaxDoseRow(
      id: id,
      done: s.done.contains(id),
      givenOn: s.givenOn[id],
      reminder: s.reminders.contains(id),
      reminderAt: s.reminderAt[id],
    );
  }

  /// Uploads whatever the cloud has not confirmed (0104).
  Future<void> _pushWaiting() {
    final child = _childId;
    return _sync.push(
      () => {
        if (child != null)
          for (final d in _rowsFor(child)) d.id: d.toCloud(),
      },
      fallbackChildId: child,
    );
  }

  /// A dose changed on this phone: remember it and upload it.
  void _changed(String visitId) {
    _sync.touch(visitId, _childId, columns: _rowOf(visitId).toCloud());
    _pushWaiting();
  }

  // ---- the alarms (shared reminders, armed on each phone) -------------------

  /// Each dose's alarm as this phone should hold it: reminded, not yet given,
  /// with a time.
  /// [of] is one child's record; null: the child on screen's.
  Map<String, DateTime> _alarms([_VaxChild? of]) {
    final s = of ?? _st;
    return {
      for (final id in s.reminders)
        if (!s.done.contains(id) && s.reminderAt[id] != null)
          id: s.reminderAt[id]!,
    };
  }

  /// The phone's id for [childId]'s alarm of [visitId] (B11).
  int _alarmId(String visitId, String? childId) {
    final kids = ChildProfileStore.instance.children;
    return vaxAlarmIdFor(visitId,
        childId: childId, firstChildId: kids.isEmpty ? null : kids.first.id);
  }

  /// [childId] is whose alarms these are; null: the child on screen.
  void _applyAlarmChanges(({Map<String, DateTime> arm, Set<String> cancel}) c,
      [String? childId]) {
    final child = childId ?? _childId;
    for (final id in c.cancel) {
      // NotificationService.instance.cancel(vaxAlarmId(id)); // kept for revert
      NotificationService.instance.cancel(_alarmId(id, child));
    }
    for (final e in c.arm.entries) {
      _arm(e.key, e.value, child);
    }
  }

  /// Bring one dose's alarm in line with its state.
  void _refreshAlarm(String visitId, Map<String, DateTime> before) {
    final now = _alarms();
    _applyAlarmChanges(vaxAlarmChanges(
      {if (before[visitId] != null) visitId: before[visitId]!},
      {if (now[visitId] != null) visitId: now[visitId]!},
      DateTime.now(),
    ));
  }

  void _arm(String visitId, DateTime at, [String? childId]) {
    // final text = vaxReminderText(vaxVisitById(visitId), at); // kept for revert
    Child? kid;
    for (final k in ChildProfileStore.instance.children) {
      if (k.id == childId) kid = k;
    }
    final text = vaxReminderText(vaxVisitById(visitId), at, child: kid);
    NotificationService.instance.scheduleOneOff(
      // id: vaxAlarmId(visitId), // kept for revert
      id: _alarmId(visitId, childId),
      title: text.title,
      body: text.body,
      when: at,
    );
  }

  /// The old one-row upsert, kept for revert (it wrote user_id = me over the
  /// other parent's row).
  // ignore: unused_element
  Future<void> _pushDose(String visitId) async {
    await ChildSync.pushKeyed(
      _table,
      _childId,
      {
        'vaccine_id': visitId,
        'done': _done.contains(visitId),
        'done_at': _givenOn[visitId]?.toUtc().toIso8601String(),
        'reminder': _reminders.contains(visitId),
      },
      onConflict: 'child_id,vaccine_id',
    );
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _prefsKey,
        // Kept for revert (one record for the family):
        // jsonEncode({
        //   'done': _done.toList(),
        //   'reminders': _reminders.toList(),
        //   'givenOn': {for (final e in _givenOn.entries) e.key: e.value.toIso8601String()},
        //   'reminderAt': {for (final e in _reminderAt.entries) e.key: e.value.toIso8601String()},
        // }),
        jsonEncode({'byChild': _vaxBy.toJson((s) => s.toJson())}),
      );
    } catch (_) {}
  }

  bool isDone(String visitId) => _done.contains(visitId);

  /// The day it was given, when the parent said.
  DateTime? givenOn(String visitId) => _givenOn[visitId];

  /// [on] is the day it was given; null keeps any date already recorded.
  void markDone(String visitId, {DateTime? on}) {
    final before = _alarms();
    _done.add(visitId);
    if (on != null) _givenOn[visitId] = DateTime(on.year, on.month, on.day);
    // Health's vaccination section shows an invitation until a real dose is
    // marked; this is what flips it to her actual schedule.
    HealthStore.instance.markVaxEntered();
    CareJourney.vaccinationDone();
    notifyListeners();
    _persist();
    // _pushDose(visitId); // kept for revert
    _changed(visitId);
    // Given: the reminder for it has nothing left to say.
    _refreshAlarm(visitId, before);
  }

  void markNotDone(String visitId) {
    // The seed-guard is stale (2026-10-07): `done` comes ONLY from the parent
    // now (see statusOf), so it stopped her unticking the birth and 6-week
    // visits, and Undo did nothing. Kept for revert:
    // if (kVaxVisits.firstWhere((v) => v.id == visitId).status != VaxStatus.done) {
    if (_done.contains(visitId)) {
      final before = _alarms();
      _done.remove(visitId);
      _givenOn.remove(visitId);
      notifyListeners();
      _persist();
      // Kept for revert: a hard delete when nothing was left, lost offline.
      // Un-ticking is now an edit (done = false) that wins like any other.
      // if (_reminders.contains(visitId)) {
      //   _pushDose(visitId);
      // } else {
      //   ChildSync.removeKeyed(_table, _childId, 'vaccine_id', visitId);
      // }
      _changed(visitId);
      _refreshAlarm(visitId, before);
    }
  }

  bool hasReminder(String visitId) => _reminders.contains(visitId);
  /// [at] is when the alarm fires. The store arms or cancels this phone's
  /// alarm, and the other parent's phone arms the same one after it syncs
  /// (2026-10-17, 0104). Before, the screens armed it and nothing cancelled
  /// it: turning a reminder off left the alarm set.
  void setReminder(String visitId, bool on, {DateTime? at}) {
    final before = _alarms();
    on ? _reminders.add(visitId) : _reminders.remove(visitId);
    if (on && at != null) _reminderAt[visitId] = at;
    if (!on) _reminderAt.remove(visitId);
    notifyListeners();
    _persist();
    // Persisting this closes the second half of flag #4: the reminder armed a
    // real OS notification that survived a restart while the store forgot it,
    // so the app and the phone disagreed about what was scheduled.
    // Kept for revert (a hard delete when nothing was left):
    // if (on || _done.contains(visitId)) {
    //   _pushDose(visitId);
    // } else {
    //   ChildSync.removeKeyed(_table, _childId, 'vaccine_id', visitId);
    // }
    _changed(visitId);
    _refreshAlarm(visitId, before);
  }

  /// A visit's live status (respecting anything the parent has marked done).
  /// A visit's live status.
  ///
  /// `done` comes ONLY from what the parent has marked. The schedule's own
  /// `status` field still supplies `due` / `upcoming` (both are honest - they
  /// derive from the child's age), but a schedule entry that claims `done`
  /// is our demo history, so for a real parent it reads as `due`: the dose is
  /// in the past and she has not recorded it yet. That is true, and it invites
  /// her to record it instead of telling her it already happened.
  /// The comment above was half right, and the half it got wrong is the whole
  /// problem: the schedule's `status` does NOT derive from the child's age. It
  /// is a literal baked into each seed entry. So a newborn's tracker announced
  /// "At birth · Due now · 8 Mar 2026" — a date five months in the past, for a
  /// child born today — and every "upcoming" was upcoming for the demo baby
  /// rather than for hers.
  ///
  /// AGE DECIDES. A visit whose scheduled age has arrived is due; one that has
  /// not is upcoming; recorded always wins. Now the answer changes with the
  /// child instead of with the seed file.
  ///
  /// Kept for revert:
  /// VaxStatus statusOf(VaxVisit v) {
  ///   if (_done.contains(v.id)) return VaxStatus.done;
  ///   return v.status == VaxStatus.done ? VaxStatus.due : v.status;
  /// }
  VaxStatus statusOf(VaxVisit v) {
    if (_done.contains(v.id)) return VaxStatus.done;
    return v.ageDays <= ChildProfileStore.instance.ageInDays
        ? VaxStatus.due
        : VaxStatus.upcoming;
  }

  /// When this visit falls for THIS child: date of birth plus the scheduled age.
  ///
  /// VaxVisit.date is a display string in the seed ('8 Mar 2026'), which is one
  /// demo baby's calendar. Every screen printed it verbatim, so a parent read
  /// somebody else's appointment dates as her own.
  String dateLabelFor(VaxVisit v) {
    final d = ChildProfileStore.instance.dob.add(Duration(days: v.ageDays));
    const m = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug',
      'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day} ${m[d.month]} ${d.year}';
  }

  /// True when the parent has recorded nothing at all.
  ///
  /// The one thing every "how are we doing?" line on this screen and in the
  /// Health Wallet has to know before it says anything reassuring.
  bool get nothingRecorded => _done.isEmpty;

  // ---- snapshot ----
  int get completedVaccineCount =>
      kVaxVisits.where((v) => statusOf(v) == VaxStatus.done).fold<int>(0, (a, v) => a + v.vaccineIds.length);

  int get firstYearTotal =>
      kVaxVisits.where((v) => v.ageDays <= 365).fold<int>(0, (a, v) => a + v.vaccineIds.length);

  /// The next visit that needs action - the due one, else the soonest upcoming.
  // A visit the parent's chosen schedule does not include is not "next": a
  // government-schedule family is never told a private-only visit is due.
  VaxVisit? get nextVisit {
    for (final v in kVaxVisits) {
      if (statusOf(v) == VaxStatus.due && !isOptionalVisit(v)) return v;
    }
    for (final v in kVaxVisits) {
      if (statusOf(v) == VaxStatus.upcoming && !isOptionalVisit(v)) return v;
    }
    return null;
  }

  /// ⚠️ THE HEALTH DOOR'S VACCINES CARD LINE (plan H1, 2026-10-25): "Due in 5
  /// days" when the next dose on her schedule falls within 14 days, else
  /// null and the card keeps its count. Only ahead, never "overdue": with
  /// nothing ticked every past visit reads due, and a card nagging a parent
  /// who simply has not recorded would be a false alarm on every open.
  String? get dueSoonLine {
    final today = DateUtils.dateOnly(DateTime.now());
    final dob = DateUtils.dateOnly(ChildProfileStore.instance.dob);
    for (final v in kVaxVisits) {
      if (statusOf(v) != VaxStatus.upcoming || isOptionalVisit(v)) continue;
      final days = dob.add(Duration(days: v.ageDays)).difference(today).inDays;
      if (days < 0 || days > 14) return null;
      return switch (days) {
        0 => 'Due today',
        1 => 'Due tomorrow',
        _ => 'Due in $days days',
      };
    }
    return null;
  }

  /// Private-schedule doses in [v] (empty when the visit is all government).
  List<String> privateOnlyIn(VaxVisit v) =>
      [for (final id in v.vaccineIds) if (kVaxPrivateOnly.contains(id)) id];

  /// True when she chose the government schedule and every dose at this visit
  /// is private-only. Shown, never hidden, but not counted as due or reminded.
  bool isOptionalVisit(VaxVisit v) =>
      FamilyProfileStore.instance.vaxSchedule == VaxSchedule.uip &&
      v.vaccineIds.isNotEmpty &&
      v.vaccineIds.every(kVaxPrivateOnly.contains);

  /// The Tools row's subtitle, computed for this child (it was a fixed
  /// "Next due in 3 weeks" for every child; gap analysis P1).
  String get nextVisitSubtitle {
    final v = nextVisit;
    if (v == null) return 'Every visit recorded';
    if (statusOf(v) == VaxStatus.due) return 'Due now: the ${v.ageLabel} visit';
    final days = ChildProfileStore.instance.dob.add(Duration(days: v.ageDays)).difference(DateTime.now()).inDays;
    final when = days <= 1
        ? 'tomorrow'
        : days < 14
            ? 'in $days days'
            : days < 60
                ? 'in ${(days / 7).round()} weeks'
                : 'on ${dateLabelFor(v)}';
    return 'Next: ${v.ageLabel}, $when';
  }

  /// The due-now visit, if any (drives "Due today").
  VaxVisit? get dueVisit {
    for (final v in kVaxVisits) {
      if (statusOf(v) == VaxStatus.due) return v;
    }
    return null;
  }

  /// No "overdue/missed" shaming - the scenario is on track. Returns null unless
  /// a genuinely past-due visit is ever modelled.
  VaxVisit? get catchUpVisit => null;

  bool get hasAnyReminder => _reminders.isNotEmpty;
  String? get nextReminderLabel {
    if (_reminders.isEmpty) return null;
    // earliest reminded visit by ageDays
    final reminded = kVaxVisits.where((v) => _reminders.contains(v.id)).toList()
      ..sort((a, b) => a.ageDays.compareTo(b.ageDays));
    return reminded.isEmpty ? null : '${reminded.first.lead.shortName} · ${reminded.first.date}';
  }
}
/// One child's vaccine record (B11, 2026-10-25): which doses are given and
/// when, and which carry a reminder and when it fires.
class _VaxChild {
  final Set<String> done = {};
  final Set<String> reminders = {};
  final Map<String, DateTime> givenOn = {};
  final Map<String, DateTime> reminderAt = {};

  Map<String, Object?> toJson() => {
        'done': done.toList(),
        'reminders': reminders.toList(),
        'givenOn': {for (final e in givenOn.entries) e.key: e.value.toIso8601String()},
        'reminderAt': {for (final e in reminderAt.entries) e.key: e.value.toIso8601String()},
      };

  /// Reads [toJson], and the one-record blob from before B11 (same shape).
  static _VaxChild fromJson(Map j) {
    final s = _VaxChild();
    for (final e in (j['done'] as List? ?? [])) {
      s.done.add(e.toString());
    }
    for (final e in (j['reminders'] as List? ?? [])) {
      s.reminders.add(e.toString());
    }
    void dates(Object? m, Map<String, DateTime> into) {
      if (m is! Map) return;
      m.forEach((k, v) {
        final d = DateTime.tryParse(v.toString());
        if (d != null) into[k.toString()] = d;
      });
    }
    dates(j['givenOn'], s.givenOn);
    dates(j['reminderAt'], s.reminderAt);
    return s;
  }
}

/// The Vaccines tab card's due line (`PpDoorTab.dueLine`, Health H1).
String? ppVaccineDueLine() => VaxStore.instance.dueSoonLine;
