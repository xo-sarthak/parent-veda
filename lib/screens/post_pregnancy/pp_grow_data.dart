// =============================================================================
//  Grow — the engine behind three versions of the same feature.
// -----------------------------------------------------------------------------
//  THREE VERSIONS, SIDE BY SIDE, so nothing gets lost in an argument:
//
//    V1  What it is right now.  DevelopmentHomeScreen, untouched. Not a copy,
//        not a port — the actual screen, opened as-is. If V1 ever renders
//        differently from what shipped, that is a bug in the comparison.
//
//    V2  What the redesign brief says.  One hero activity, five capabilities,
//        a breakable streak, a celebration screen, and the Map/check-in gone
//        from the home. Built faithfully INCLUDING the parts this codebase
//        would normally refuse, because a comparison you have pre-corrected is
//        not a comparison.
//
//    V3  The recommendation.  Takes the brief's reframe — one question, one
//        answer, capabilities over academic domains — and declines the rewrite.
//        The Map stays, one tap down. The streak cannot break. Self-care has
//        somewhere to live.
//
//  NOTHING IS DELETED ANYWHERE. kDevActivities keeps its eight; the eight are
//  reused, not replaced. The Explore row that used to open V1 directly is
//  commented out in place rather than removed.
//
//  WHERE THE THREE ACTUALLY DIFFER — worth stating, because two of them look
//  similar at a glance and the differences are the whole point:
//
//    | .                | V1            | V2                  | V3            |
//    | activity pool    | 8             | 40                  | 40            |
//    | organised by     | 8 areas       | 5 capabilities      | 6 capabilities|
//    | self-care        | its own area  | NOWHERE (orphaned)  | "Do"          |
//    | daily habit      | none          | breakable streak    | weekly ring   |
//    | Development Map  | on the home   | removed             | one tap down  |
//    | check-in         | on the home   | removed             | one tap down  |
//
//  The orphaned row is not a slur on the brief — it is arithmetic. The brief
//  lists five capabilities, the library has eight areas, and self-care maps to
//  none of the five. grow_orphaned_test.dart asserts that count rather than
//  arguing about it.
// =============================================================================

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/remote/cloud_synced_store.dart';
import 'pp_child_profile.dart';
import 'pp_common.dart';
import 'pp_development_data.dart';
import 'pp_grow_activities.dart';

// =============================================================================
//  1. WHICH VERSION IS ON SCREEN
// =============================================================================

enum GrowVersion { v1, v2, v3 }

/// Session-scoped, exactly like NameVersionStore: this is a reviewing
/// convenience, not a user preference, so it deliberately does NOT persist.
/// A parent must never find the app in a different shape because of something
/// somebody tapped once during a review.
class GrowVersionStore extends ChangeNotifier {
  GrowVersionStore._();
  static final GrowVersionStore instance = GrowVersionStore._();

  // Opens on V1 so the first thing anyone sees is the thing that already
  // ships. Comparisons should start from what is real.
  GrowVersion _v = GrowVersion.v1;
  GrowVersion get version => _v;

  void setVersion(GrowVersion v) {
    if (v == _v) return;
    _v = v;
    notifyListeners();
  }

  String get label => switch (_v) {
        GrowVersion.v1 => 'What ships today',
        GrowVersion.v2 => 'The brief, as written',
        GrowVersion.v3 => 'The recommendation',
      };
}

// =============================================================================
//  2. CAPABILITIES — the parent-facing layer over the academic areas
// -----------------------------------------------------------------------------
//  The brief is right that "Gross Motor / Fine Motor" is a textbook's
//  vocabulary and "Move" is a parent's. It is a RENAMING LAYER, not a new
//  taxonomy: every capability lists the DevArea ids it covers, so the eight
//  areas, their journeys and the Development Map all keep working underneath.
//
//  Line icons, not the brief's emoji. The app-wide rule is no decorative emoji
//  in chrome, and a 🧠 in a section header is chrome.
// =============================================================================

class GrowCapability {
  const GrowCapability({
    required this.id,
    required this.label,
    required this.icon,
    required this.accent,
    required this.promise,
    required this.abilities,
    required this.areaIds,
  });

  final String id;
  final String label;
  final IconData icon;
  final Color accent;

  /// "Strengthen your child's ability to…" — the one line under the title.
  final String promise;

  /// The named sub-abilities from the brief, shown as a list.
  final List<String> abilities;

  /// The DevArea ids this capability covers. The join back to everything that
  /// already exists.
  final List<String> areaIds;

  List<DevActivity> get activities =>
      kGrowActivities.where((a) => areaIds.contains(a.areaId)).toList();
}

const Color _capThink = Color(0xFF6A30B6);
const Color _capTalk = Color(0xFF2E7D6E);
const Color _capMove = Color(0xFFC2661E);
const Color _capConnect = Color(0xFFFF5A79);
const Color _capCreate = Color(0xFF8F64C8);
const Color _capDo = Color(0xFF3E6BA8);

/// THE BRIEF'S FIVE, exactly as written. Used by V2.
const List<GrowCapability> kDocCapabilities = [
  GrowCapability(
    id: 'think',
    label: 'Think',
    icon: Icons.lightbulb_outline_rounded,
    accent: _capThink,
    promise: 'Focus, remember, explore and solve problems.',
    abilities: [
      'Attention',
      'Memory',
      'Problem solving',
      'Curiosity',
      'Executive function',
    ],
    areaIds: ['cognitive'],
  ),
  GrowCapability(
    id: 'communicate',
    label: 'Communicate',
    icon: Icons.chat_bubble_outline_rounded,
    accent: _capTalk,
    promise: 'Listen, understand, and find the words.',
    abilities: ['Listening', 'Vocabulary', 'Expression', 'Reading', 'Conversation'],
    areaIds: ['language'],
  ),
  GrowCapability(
    id: 'move',
    label: 'Move',
    icon: Icons.directions_run_rounded,
    accent: _capMove,
    promise: 'Balance, coordinate, grip and go.',
    abilities: [
      'Balance',
      'Coordination',
      'Fine motor',
      'Gross motor',
      'Hand-eye coordination',
    ],
    areaIds: ['gross_motor', 'fine_motor'],
  ),
  GrowCapability(
    id: 'connect',
    label: 'Connect',
    icon: Icons.favorite_outline_rounded,
    accent: _capConnect,
    promise: 'Feel safe, feel understood, and reach for others.',
    abilities: [
      'Attachment',
      'Emotional regulation',
      'Confidence',
      'Empathy',
      'Social skills',
    ],
    areaIds: ['emotional', 'social'],
  ),
  GrowCapability(
    id: 'create',
    label: 'Create',
    icon: Icons.palette_outlined,
    accent: _capCreate,
    promise: 'Imagine, pretend, make and explore.',
    abilities: ['Creativity', 'Music', 'Pretend play', 'Imagination', 'Exploration'],
    areaIds: ['creativity'],
  ),
];

/// THE SIXTH. Self-care & Independence — dressing, feeding himself, a real job
/// in the house. A genuine developmental area, an existing DevArea with
/// activities already written against it, and it maps to none of the brief's
/// five. Rather than fold it somewhere it does not belong (it is not "Move",
/// and calling it "Connect" is worse), V3 gives it a name a parent would use.
const GrowCapability kCapabilityDo = GrowCapability(
  id: 'do',
  label: 'Do',
  icon: Icons.self_improvement_rounded,
  accent: _capDo,
  promise: 'Manage himself — and know that he can.',
  abilities: [
    'Self-feeding',
    'Dressing',
    'Independence',
    'Responsibility',
    'Confidence',
  ],
  areaIds: ['selfcare'],
);

/// V3's six.
const List<GrowCapability> kGrowCapabilities = [
  ...kDocCapabilities,
  kCapabilityDo,
];

List<GrowCapability> capabilitiesFor(GrowVersion v) =>
    v == GrowVersion.v2 ? kDocCapabilities : kGrowCapabilities;

GrowCapability? capabilityById(String id) {
  for (final c in kGrowCapabilities) {
    if (c.id == id) return c;
  }
  return null;
}

/// Which capabilities an activity strengthens. Derived from its area, so no
/// activity needed editing to gain one.
List<GrowCapability> capabilitiesOf(DevActivity a,
    {List<GrowCapability>? from}) {
  final pool = from ?? kGrowCapabilities;
  return pool.where((c) => c.areaIds.contains(a.areaId)).toList();
}

/// The activities NO capability in [pool] can reach. Zero for V3's six; not
/// zero for the brief's five, which is the arithmetic worth seeing.
List<DevActivity> orphanedUnder(List<GrowCapability> pool) {
  final covered = <String>{for (final c in pool) ...c.areaIds};
  return kGrowActivities.where((a) => !covered.contains(a.areaId)).toList();
}

// =============================================================================
//  3. THE LIBRARY, AND HOW OLD AN ACTIVITY IS FOR
// =============================================================================

/// The original eight PLUS the birth-to-five additions. V1 keeps reading
/// kDevActivities directly, so it is unaffected by anything here.
final List<DevActivity> kGrowActivities = [
  ...kDevActivities,
  ...kGrowExtraActivities,
];

DevActivity growActivityById(String id) => kGrowActivities.firstWhere(
      (a) => a.id == id,
      orElse: () => kGrowActivities.first,
    );

/// Parse `ageTag` into a month range.
///
/// Accepts '0–3 mo', '3-12 mo', '2–3 yr', '12+ mo'. Returns null when a tag
/// cannot be read, rather than guessing — a silently mis-parsed tag would drop
/// an activity out of every age band and nothing would look broken.
(int, int)? growAgeRange(DevActivity a) {
  final t = a.ageTag.toLowerCase().replaceAll('–', '-').replaceAll('—', '-');
  final unit = t.contains('yr') || t.contains('year') ? 12 : 1;
  final nums = RegExp(r'\d+').allMatches(t).map((m) => int.parse(m[0]!)).toList();
  if (nums.isEmpty) return null;
  if (t.contains('+')) return (nums.first * unit, 72);
  if (nums.length == 1) return (nums.first * unit, nums.first * unit + unit);
  return (nums.first * unit, nums[1] * unit);
}

bool growSuitsAge(DevActivity a, int months) {
  final r = growAgeRange(a);
  if (r == null) return false;
  return months >= r.$1 && months <= r.$2;
}

/// A daily feature must not repeat inside a fortnight.
///
/// This number is not a preference — it is the promise. The brief asks for a
/// 14-day streak, so if the pool a parent draws from is smaller than 14 she
/// meets the same activity again while the app is still congratulating her for
/// consistency, and "ParentVeda already knows what to do today" is visibly
/// untrue. 14 activities is the floor that makes the claim survivable.
const int _kFortnight = 14;

/// Age-appropriate activities, widening the window until there are enough.
///
/// THE PROBLEM THIS SOLVES, found by a test rather than by looking: the library
/// has 47 activities but only 4 of them suit a 30-month-old exactly. Plenty of
/// content overall, thin at any one age — so a picker that filters strictly
/// repeats every four days for a two-and-a-half-year-old.
///
/// So the window OPENS rather than the filter being dropped: exact band first,
/// then ±6 months, ±12, ±24, and only then everything. A child a little ahead
/// or behind the tag is the normal case, not an edge case, and an activity six
/// months either side is a better answer than the same one twice a week.
///
/// Never returns empty. An empty list would render an empty feature, and the
/// rule here is that a feature is never hidden.
List<DevActivity> growActivitiesForAge(int months) {
  for (final slack in [0, 6, 12, 24]) {
    final pool = kGrowActivities.where((a) {
      final r = growAgeRange(a);
      return r != null && months >= r.$1 - slack && months <= r.$2 + slack;
    }).toList();
    if (pool.length >= _kFortnight) return pool;
  }
  return kGrowActivities;
}

// =============================================================================
//  4. TODAY'S ONE ACTIVITY
// -----------------------------------------------------------------------------
//  Deterministic on the DATE, not random. Two reasons, and the second is the
//  important one:
//
//    * a rebuild, a hot restart or a second visit must not change today's
//      answer — "the best activity for today" that reshuffles on every open
//      was never a recommendation;
//    * and it means the app can honestly say "tomorrow: X", because tomorrow's
//      pick is already knowable.
//
//  Completed-today is skipped so the hero moves on after it is done, rather
//  than sitting there inviting a parent to do the same thing twice.
// =============================================================================

DevActivity growPickFor(DateTime day, {int? ageMonths}) {
  final months = ageMonths ?? ChildProfileStore.instance.ageInMonths;
  final pool = growActivitiesForAge(months);
  final epochDay = DateTime(day.year, day.month, day.day)
          .difference(DateTime(2020))
          .inDays
          .abs();
  return pool[epochDay % pool.length];
}

DevActivity growToday({int? ageMonths}) =>
    growPickFor(DateTime.now(), ageMonths: ageMonths);

DevActivity growTomorrow({int? ageMonths}) => growPickFor(
    DateTime.now().add(const Duration(days: 1)),
    ageMonths: ageMonths);

/// "Why today?" — the line under the hero.
///
/// DELIBERATELY NOT a claim about this child specifically. It says what the
/// activity is for at this age, which is true, rather than "your baby is ready
/// for this", which we cannot know. The repo's clinical rule is that we never
/// generate a personalised assessment, and a warm sentence is still an
/// assessment if it asserts something about one child's development.
String growWhyToday(DevActivity a, {int? ageMonths}) {
  final months = ageMonths ?? ChildProfileStore.instance.ageInMonths;
  final band = months < 12
      ? 'this year'
      : months < 24
          ? 'around now'
          : 'at this age';
  final caps = capabilitiesOf(a);
  final what = caps.isEmpty ? 'how he grows' : caps.first.label.toLowerCase();
  return 'Most of what changes $band is $what — and this is one of the '
      'simplest ways to give it a nudge. ${a.minutes} minutes.';
}

// =============================================================================
//  5. THE HABIT LOOP
// -----------------------------------------------------------------------------
//  ONE store, TWO readings, and this is where V2 and V3 genuinely disagree.
//
//    V2 reads streakDays  — consecutive days, resets to zero on a miss.
//    V3 reads daysThisWeek — how many days this week, fills, never empties.
//
//  Both are computed from the same dated log, so switching versions does not
//  rewrite history and neither number is faked.
//
//  WHY V3 REFUSES THE STREAK. The Development feature was deliberately built
//  with "supportive words only, no gamification" on record. A counter that
//  resets to zero, sitting beside the words "your child's brain", punishes the
//  parent who had a hard fortnight — a sick baby, a bad month — by telling her
//  she broke something. This app is opened at 2am by someone already worried.
//  The weekly ring keeps the daily pull and drops the punishment.
//
//  V2 keeps the streak anyway, because building the brief with its sharp edge
//  filed off would make the comparison meaningless.
// =============================================================================

class GrowStore extends ChangeNotifier with CloudSyncedStore {
  GrowStore._();
  static final GrowStore instance = GrowStore._();

  /// ISO dates (yyyy-MM-dd) on which SOMETHING was completed.
  final Set<String> _days = {};

  /// activityId -> the last ISO date it was completed on.
  final Map<String, String> _last = {};

  static const _prefsKey = 'pp_grow_v1';

  @override
  String get cloudKey => _prefsKey;

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw != null) applyCloudData(jsonDecode(raw));
    } catch (_) {/* local-first: an unreadable cache is an empty one */}
    notifyListeners();
    try {
      await syncStateFromCloud();
    } catch (_) {/* stay local */}
  }

  @override
  Object cloudData() => {'days': _days.toList(), 'last': _last};

  @override
  void applyCloudData(Object data) {
    if (data is! Map) return;
    final d = data['days'];
    if (d is List) _days..clear()..addAll(d.map((e) => e.toString()));
    final l = data['last'];
    if (l is Map) {
      _last
        ..clear()
        ..addAll({
          for (final e in l.entries) e.key.toString(): e.value.toString(),
        });
    }
    notifyListeners();
  }

  // Same shape as DevStore: the mixin's notifyListeners() pushes to the cloud,
  // and this writes the local cache after it. Local-first, so the phone is
  // correct even when the push never lands.
  @override
  Future<void> persistLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, jsonEncode(cloudData()));
    } catch (_) {/* local write failed; in-memory state still stands */}
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
    persistLocalCache();
  }

  static String key(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  bool isCompletedToday(String activityId) =>
      _last[activityId] == key(DateTime.now());

  bool get didSomethingToday => _days.contains(key(DateTime.now()));

  /// Record a completion.
  ///
  /// Also mirrors into DevStore so V1's "completed" set agrees — the three
  /// versions are three faces of one feature, and an activity finished in V3
  /// must not look untouched in V1.
  Future<void> complete(String activityId) async {
    final today = key(DateTime.now());
    _days.add(today);
    _last[activityId] = today;
    if (!DevStore.instance.isCompleted(activityId)) {
      DevStore.instance.toggleComplete(activityId);
    }
    notifyListeners();
  }

  /// Consecutive days up to today. V2's number. Resets to zero on a gap.
  int get streakDays {
    var n = 0;
    var d = DateTime.now();
    // A streak is not broken until today is over, so a day with nothing done
    // yet still counts from yesterday backwards.
    if (!_days.contains(key(d))) d = d.subtract(const Duration(days: 1));
    while (_days.contains(key(d))) {
      n++;
      d = d.subtract(const Duration(days: 1));
    }
    return n;
  }

  /// Days with something done in the last seven. V3's number. Fills, never
  /// empties, and a missed day costs one slot rather than everything.
  int get daysThisWeek {
    var n = 0;
    for (var i = 0; i < 7; i++) {
      if (_days.contains(key(DateTime.now().subtract(Duration(days: i))))) n++;
    }
    return n;
  }

  /// Which of the last seven days had something done — oldest first, for the
  /// week ribbon.
  List<bool> get weekPattern => [
        for (var i = 6; i >= 0; i--)
          _days.contains(key(DateTime.now().subtract(Duration(days: i)))),
      ];

  int get totalDays => _days.length;

  /// Recently completed, newest first. Backs the "Completed recently" row in
  /// both new versions.
  List<DevActivity> recentlyCompleted({int limit = 6}) {
    final entries = _last.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return [
      for (final e in entries.take(limit))
        if (kGrowActivities.any((a) => a.id == e.key)) growActivityById(e.key),
    ];
  }
}

// =============================================================================
//  6. SHARED CHROME
// =============================================================================

/// The V1 | V2 | V3 pill. Same shape as the naming tool's retired V1|V2 toggle,
/// deliberately — a reviewer who has seen one should recognise the other.
class GrowVersionPill extends StatelessWidget {
  const GrowVersionPill({super.key});

  @override
  Widget build(BuildContext context) {
    final store = GrowVersionStore.instance;
    Widget seg(String label, GrowVersion v) {
      final on = store.version == v;
      return GestureDetector(
        onTap: () => store.setVersion(v),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
          decoration: BoxDecoration(
            color: on ? ppPurple : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(label,
              style: ppBody(11.5,
                  color: on ? Colors.white : ppSoft, w: FontWeight.w700)),
        ),
      );
    }

    return ListenableBuilder(
      listenable: store,
      builder: (_, _) => Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: ppBorder),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          seg('V1', GrowVersion.v1),
          seg('V2', GrowVersion.v2),
          seg('V3', GrowVersion.v3),
        ]),
      ),
    );
  }
}

/// One capability chip — used on the hero, the activity page and the row.
class GrowCapabilityChip extends StatelessWidget {
  const GrowCapabilityChip({super.key, required this.cap, this.compact = false});
  final GrowCapability cap;
  final bool compact;

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(
            horizontal: compact ? 9 : 11, vertical: compact ? 5 : 7),
        decoration: BoxDecoration(
          color: cap.accent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: cap.accent.withValues(alpha: 0.22)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(cap.icon, size: compact ? 12 : 14, color: cap.accent),
          const SizedBox(width: 6),
          Text(cap.label,
              style: ppBody(compact ? 11 : 12,
                  color: cap.accent, w: FontWeight.w700)),
        ]),
      );
}
