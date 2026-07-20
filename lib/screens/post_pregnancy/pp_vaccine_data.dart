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
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/remote/child_scoped_store.dart';
import '../../services/remote/supabase_repo.dart';
import '../../services/remote/sync_registry.dart';
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
  ),
  Vaccine(
    id: 'opv',
    name: 'Oral Polio (OPV)',
    shortName: 'OPV',
    protects: 'Oral drops against polio.',
    diseases: ['Poliomyelitis (polio)'],
    why: 'OPV is the oral (drops) polio vaccine, given alongside IPV for broad, lasting protection against polio.',
    reactions: ['Usually none - it is given as gentle oral drops'],
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
  ),
  Vaccine(
    id: 'hepb',
    name: 'Hepatitis B (birth dose)',
    shortName: 'Hepatitis B',
    protects: 'Protects the liver from hepatitis B.',
    diseases: ['Hepatitis B (a serious, sometimes lifelong liver infection)'],
    why: 'The birth dose of Hepatitis B gives early protection against a virus that can cause long-term liver disease. Later doses in the pentavalent shot complete the cover.',
  ),
  Vaccine(
    id: 'vitk',
    name: 'Vitamin K',
    shortName: 'Vitamin K',
    protects: 'Prevents a rare but serious bleeding problem in newborns.',
    diseases: ['Vitamin K deficiency bleeding (VKDB) in newborns'],
    why: 'Not a vaccine but given at birth: a single Vitamin K injection prevents a rare but dangerous bleeding disorder in newborns. A routine, reassuring first-day step.',
    reactions: ['Usually none beyond a brief pinch'],
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
  ),
  Vaccine(
    id: 'hepa',
    name: 'Hepatitis A',
    shortName: 'Hepatitis A',
    protects: 'Protects the liver from hepatitis A.',
    diseases: ['Hepatitis A (a liver infection spread through food and water)'],
    why: 'Hepatitis A spreads through contaminated food and water. The vaccine, given in the second year, gives long-lasting protection.',
  ),
  Vaccine(
    id: 'varicella',
    name: 'Varicella (Chickenpox)',
    shortName: 'Varicella',
    protects: 'Protects against chickenpox.',
    diseases: ['Chickenpox (varicella)'],
    why: 'Chickenpox is usually mild but can occasionally be serious. The vaccine prevents it and the discomfort of the itchy rash and fever.',
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
];

VaxVisit vaxVisitById(String id) => kVaxVisits.firstWhere((v) => v.id == id, orElse: () => kVaxVisits.first);

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

// =============================================================================
//  VaxStore - completed visits + reminders (in-memory, ChangeNotifier singleton)
// =============================================================================
class VaxStore extends ChangeNotifier {
  VaxStore._();
  static final VaxStore instance = VaxStore._();

  // EMPTY, not seeded. This used to start as {every visit the SCHEDULE calls
  // done}, so a parent who had recorded nothing opened the tracker to find
  // three doses already ticked - our demo child's history presented as hers.
  // A dose is "done" only when SHE marks it. See statusOf() for how the
  // schedule's own status is now read honestly.
  final Set<String> _done = {};
  final Set<String> _reminders = {};

  bool _loaded = false;
  static const _prefsKey = 'pp_vax';
  static const _table = 'pp_vaccine_doses';

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
        for (final e in (j['done'] as List? ?? [])) {
          _done.add(e.toString());
        }
        for (final e in (j['reminders'] as List? ?? [])) {
          _reminders.add(e.toString());
        }
      }
    } catch (_) {/* keep the schedule defaults */}
    _loaded = true;
    notifyListeners();
    try {
      await _syncFromCloud();
    } catch (_) {/* stay local */}
  }

  Future<void> _syncFromCloud() async {
    SyncRegistry.register(_syncFromCloud);
    final childId = _childId;
    if (!SupabaseRepo.isLoggedIn || childId == null) return;
    try {
      final rows = await SupabaseRepo.fetchByChild(_table, childId);
      for (final r in rows) {
        final id = (r['vaccine_id'] ?? '').toString();
        if (id.isEmpty) continue;
        if (r['done'] == true) _done.add(id);
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

  Future<void> _pushDose(String visitId) async {
    await ChildSync.pushKeyed(
      _table,
      _childId,
      {
        'vaccine_id': visitId,
        'done': _done.contains(visitId),
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
        jsonEncode({
          'done': _done.toList(),
          'reminders': _reminders.toList(),
        }),
      );
    } catch (_) {}
  }

  bool isDone(String visitId) => _done.contains(visitId);
  void markDone(String visitId) {
    _done.add(visitId);
    // Health's vaccination section shows an invitation until a real dose is
    // marked; this is what flips it to her actual schedule.
    HealthStore.instance.markVaxEntered();
    notifyListeners();
    _persist();
    _pushDose(visitId);
  }

  void markNotDone(String visitId) {
    // never remove a natively-completed seed; only toggle parent-marked ones
    if (kVaxVisits.firstWhere((v) => v.id == visitId).status != VaxStatus.done) {
      _done.remove(visitId);
      notifyListeners();
      _persist();
      // Still has a reminder? keep the row and just clear `done`.
      if (_reminders.contains(visitId)) {
        _pushDose(visitId);
      } else {
        ChildSync.removeKeyed(_table, _childId, 'vaccine_id', visitId);
      }
    }
  }

  bool hasReminder(String visitId) => _reminders.contains(visitId);
  void setReminder(String visitId, bool on) {
    on ? _reminders.add(visitId) : _reminders.remove(visitId);
    notifyListeners();
    _persist();
    // Persisting this closes the second half of flag #4: the reminder armed a
    // real OS notification that survived a restart while the store forgot it,
    // so the app and the phone disagreed about what was scheduled.
    if (on || _done.contains(visitId)) {
      _pushDose(visitId);
    } else {
      ChildSync.removeKeyed(_table, _childId, 'vaccine_id', visitId);
    }
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
  VaxStatus statusOf(VaxVisit v) {
    if (_done.contains(v.id)) return VaxStatus.done;
    return v.status == VaxStatus.done ? VaxStatus.due : v.status;
  }

  // ---- snapshot ----
  int get completedVaccineCount =>
      kVaxVisits.where((v) => statusOf(v) == VaxStatus.done).fold<int>(0, (a, v) => a + v.vaccineIds.length);

  int get firstYearTotal =>
      kVaxVisits.where((v) => v.ageDays <= 365).fold<int>(0, (a, v) => a + v.vaccineIds.length);

  /// The next visit that needs action - the due one, else the soonest upcoming.
  VaxVisit? get nextVisit {
    for (final v in kVaxVisits) {
      if (statusOf(v) == VaxStatus.due) return v;
    }
    for (final v in kVaxVisits) {
      if (statusOf(v) == VaxStatus.upcoming) return v;
    }
    return null;
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
