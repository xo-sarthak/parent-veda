// =============================================================================
//  Guided journeys — a finishable, day-by-day path (parenting · Explore)
// -----------------------------------------------------------------------------
//  The app's existing "journeys" (growth/feeding/sleep) are ambient TRACKERS:
//  you open them, log a thing, read a chart. This is the other shape — a path
//  with a day 1 and a day 30, meant to be walked once.
//
//  Built as a real ParentVeda feature first. A brand can sponsor it (the Brand
//  Studio attaches a "presented by" line), but every word here is ours and the
//  journey stands on its own with no sponsor at all.
//
//  Tone rules, deliberately: self-paced with no lock-outs (a parent who misses
//  four days has not failed anything), no streaks, no gamification, honest
//  about what is hard, and every day that touches a medical edge names when to
//  ask a real person. Non-diagnostic throughout.
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/remote/cloud_synced_store.dart';

@immutable
class JourneyDay {
  const JourneyDay({
    required this.day,
    required this.title,
    required this.body,
    required this.action,
    this.askSomeone = '',
  });

  final int day;
  final String title;

  /// Today's read. Two or three sentences — a parent holding a baby has one
  /// hand and about ninety seconds.
  final String body;

  /// One concrete thing to try. Never a chore, never a test.
  final String action;

  /// When this day touches a medical edge, the line that says who to call.
  final String askSomeone;
}

@immutable
class Journey {
  const Journey({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.about,
    required this.days,
    this.expertName = '',
    this.expertRole = '',
  });

  final String id;
  final String title;
  final String subtitle;
  final String about;
  final List<JourneyDay> days;
  final String expertName;
  final String expertRole;

  int get length => days.length;
  JourneyDay dayAt(int n) => days[(n - 1).clamp(0, days.length - 1)];
  bool get expertHookPresent => expertName.isNotEmpty;
}

// =============================================================================
//  The 30-Day Breastfeeding Journey
// =============================================================================
const Journey kBreastfeedingJourney = Journey(
  id: 'jrn_breastfeeding_30',
  title: '30 days of breastfeeding',
  subtitle: 'One short read a day, through the month that decides most of it.',
  about:
      'Most breastfeeding difficulty happens in the first month, and most of it is ordinary and fixable. This is thirty short reads — one a day — covering what actually happens, in the order it usually happens. It is self-paced: miss a week and nothing is lost, because there is nothing here to fail.',
  expertName: 'Priya Nair',
  expertRole: 'Lactation consultant · wrote this journey for ParentVeda',
  days: [
    // ---- Week 1 · the first days ------------------------------------------
    JourneyDay(
      day: 1,
      title: 'Skin to skin',
      body:
          'A newborn placed bare on your chest will often find the breast on their own, without being taught or positioned. It looks like nothing is happening for a long while, and then it happens. This is the one day where doing less works better than doing more.',
      action: 'Twenty uninterrupted minutes, baby bare against your chest. No clock, no phone.',
    ),
    JourneyDay(
      day: 2,
      title: 'Colostrum is enough',
      body:
          'What you make in the first days is measured in teaspoons, and that is the correct amount — a newborn\'s stomach is about the size of a marble. Almost every parent who worries they have "nothing" has exactly what their baby needs.',
      action: 'Feed when they cue. Do not try to measure it; you cannot, and the number would not help.',
    ),
    JourneyDay(
      day: 3,
      title: 'The latch is the whole game',
      body:
          'Nearly every early problem — pain, slow weight gain, endless feeds — traces back to a shallow latch. A deep latch means a big mouthful of breast, not just nipple: chin pressed in, nose free, lips flanged out.',
      action: 'Watch one feed closely. If the latch looks nipple-only, break the seal with a clean finger and start again.',
    ),
    JourneyDay(
      day: 4,
      title: 'It should not actually hurt',
      body:
          'Tenderness in the first seconds is common. Pain through the whole feed, cracked skin, or a lipstick-shaped nipple afterwards are not things to endure — they are signs the latch needs adjusting, and they are fixable.',
      action: 'If it hurts today, do not wait a week to see if it settles.',
      askSomeone: 'Cracked or bleeding nipples, or pain that lasts the whole feed, are worth a lactation consultant or your doctor now, not later.',
    ),
    JourneyDay(
      day: 5,
      title: 'Cluster feeding is not failure',
      body:
          'Around now, many babies feed almost continuously through the evening. It feels exactly like running out of milk. It is not that — it is how a newborn tells your body to make more, and it is one of the most misread nights in the whole month.',
      action: 'Set yourself up for the evening: water, food, a screen, somewhere comfortable. Plan for it rather than fight it.',
    ),
    JourneyDay(
      day: 6,
      title: 'Count what comes out',
      body:
          'You cannot see how much goes in, which is why nappies are the honest measure. By day five, roughly six wet nappies a day and regular yellow stools means enough is going in — whatever your instinct says.',
      action: 'Count today\'s wet nappies. That number is worth more than any feeling about supply.',
      askSomeone: 'Fewer than six wet nappies a day after day five, or a baby too sleepy to feed, is a same-day call.',
    ),
    JourneyDay(
      day: 7,
      title: 'When your milk comes in',
      body:
          'Somewhere between day two and day five, volume arrives and your breasts can go hard, hot and uncomfortable. It passes in a day or two as supply calibrates to your actual baby.',
      action: 'Feed often. A warm flannel before and something cool after helps more than anything you can buy.',
      askSomeone: 'A red, painful area with fever or flu-like aches is not ordinary engorgement — call your doctor.',
    ),

    // ---- Week 2 · finding the rhythm ---------------------------------------
    JourneyDay(
      day: 8,
      title: 'Supply and demand, honestly',
      body:
          'Milk is made in response to milk being removed. That is the whole mechanism. It also means the common advice to "space out feeds so you build up a store" does the exact opposite of what it promises.',
      action: 'Feed on cue, not on a clock, for one full day and notice what happens.',
    ),
    JourneyDay(
      day: 9,
      title: 'Let-down',
      body:
          'The pins-and-needles rush a minute or so in is your let-down. Some parents feel it strongly, some never feel it at all, and neither says anything about how much milk there is.',
      action: 'If let-down is slow, warmth and a few quiet minutes help far more than trying harder.',
    ),
    JourneyDay(
      day: 10,
      title: 'Change one thing: position',
      body:
          'Most parents learn one hold and stay there for a year. A different position changes which part of the breast drains best, and often fixes soreness that no amount of latch-fixing touched.',
      action: 'Try side-lying or the rugby hold once today. It will feel clumsy the first time. Do it anyway.',
    ),
    JourneyDay(
      day: 11,
      title: 'The two-week growth spurt',
      body:
          'Around now, a baby who had settled into a rhythm suddenly wants feeding constantly again. Almost every parent reads this as their supply failing. It is the opposite: it is the order being placed for more.',
      action: 'Ride it out for 48 hours before changing anything at all.',
    ),
    JourneyDay(
      day: 12,
      title: 'Why nights are like this',
      body:
          'Prolactin, the hormone that drives milk production, runs highest overnight. Night feeds are not a phase to be trained out — for now they are doing real work.',
      action: 'Sleep when you can, in whatever broken shape it comes. Nothing else on today\'s list matters more.',
    ),
    JourneyDay(
      day: 13,
      title: 'One side or two?',
      body:
          'Finish the first side properly rather than clock-watching, then offer the second. The old "hindmilk versus foremilk" panic is largely overblown — a baby who drains one side well gets both.',
      action: 'Let them come off the first side themselves today rather than switching at a set time.',
    ),
    JourneyDay(
      day: 14,
      title: 'Two weeks in — a check on you',
      body:
          'Everyone has been asking about the baby. This one is about you. Two weeks of this is genuinely hard, and finding it hard is not a sign you are doing it wrong.',
      action: 'Say out loud to one person how it is actually going. Unedited.',
      askSomeone: 'If you feel persistently low, panicky, or unlike yourself, that is worth telling your doctor. It is common, it is treatable, and it is not a character failure.',
    ),

    // ---- Week 3 · life around it -------------------------------------------
    JourneyDay(
      day: 15,
      title: 'Pumping, if you want to',
      body:
          'A pump is a tool, not an obligation. It is useful if you are heading back to work, building a small buffer, or want someone else to do a feed. It is not a requirement of feeding a baby.',
      action: 'If you plan to pump at all, try it once now rather than the week you need it to work.',
    ),
    JourneyDay(
      day: 16,
      title: 'Storing it',
      body:
          'Roughly: four hours at room temperature, four days in the fridge, six months in a freezer. Fresh beats frozen when you have the choice, because freezing costs some of the immune content.',
      action: 'Label with the date the moment you pump. You will not remember later.',
    ),
    JourneyDay(
      day: 17,
      title: 'Feeding outside the house',
      body:
          'The first time in public is almost entirely nerve and almost never a problem. Practically: a stretchy top you can lift from underneath does more than any cover.',
      action: 'Go somewhere small and feed there. Just once, to break the seal on it.',
    ),
    JourneyDay(
      day: 18,
      title: 'What a partner can actually do',
      body:
          'They cannot feed the baby, which leaves people feeling useless and reaching for the wrong help. The useful version is everything around the feed: bringing water, taking the baby after, protecting your sleep, handling everyone else.',
      action: 'Ask for one specific thing tonight. Specific, not "help more".',
    ),
    JourneyDay(
      day: 19,
      title: 'Your body is doing this too',
      body:
          'Breastfeeding is genuinely hungry work. Thirst arrives out of nowhere the moment you sit down to feed. This is not the month for eating like an afterthought.',
      action: 'Put water within reach of wherever you feed, before you sit down.',
    ),
    JourneyDay(
      day: 20,
      title: 'Spotting mastitis early',
      body:
          'A hard, red, hot wedge in one breast, often with a fever and a hit-by-a-bus feeling. Caught early it usually resolves; ignored for a day or two it can turn nasty fast.',
      action: 'Keep feeding from that side — draining it is part of the fix, not a risk to the baby.',
      askSomeone: 'Fever plus a red painful area means call your doctor today. This is the one on this list not to sleep on.',
    ),
    JourneyDay(
      day: 21,
      title: 'The honest middle',
      body:
          'Three weeks is where a lot of people quietly decide they cannot do this. If that is today, you are not weak and you are not alone — this is the hardest stretch, and it is the one that most reliably gets easier.',
      action: 'Decide nothing permanent today. Just do today.',
    ),

    // ---- Week 4 · sustaining -----------------------------------------------
    JourneyDay(
      day: 22,
      title: 'The six-week spurt is coming',
      body:
          'Another one lands around six weeks and feels exactly like the last: sudden constant feeding, sudden certainty your supply has gone. You have seen this film before.',
      action: 'Nothing. Just know it is coming so it does not frighten you when it does.',
    ),
    JourneyDay(
      day: 23,
      title: 'Bottles and mixed feeding',
      body:
          'Combination feeding is a legitimate way to feed a baby, not a failed attempt at something else. Some formula does not undo the breastfeeding you are doing, and a fed baby with a functioning parent beats an ideology.',
      action: 'If mixed feeding is what makes this sustainable for you, that is a good reason, and it is enough.',
    ),
    JourneyDay(
      day: 24,
      title: 'Sleep, without the myths',
      body:
          'Formula before bed does not reliably buy you more sleep — the studies do not support it. What does help is anything that gets the non-feeding parent doing everything that is not the feed.',
      action: 'Hand off one non-feeding night task entirely. Not shared. Handed off.',
    ),
    JourneyDay(
      day: 25,
      title: 'If work is coming',
      body:
          'Going back does not mean stopping. It means a pump, somewhere private, and a plan you make weeks early rather than the night before.',
      action: 'If you are returning to work, write down the two questions you need to ask about space and breaks.',
    ),
    JourneyDay(
      day: 26,
      title: 'Looking after the skin',
      body:
          'Air, a smear of your own milk, and a decent lanolin do most of the work. Persistent damage this far in is almost always still a latch story, not a skincare one.',
      action: 'Let them air-dry after a feed today instead of covering up immediately.',
    ),
    JourneyDay(
      day: 27,
      title: 'When supply really is low',
      body:
          'It is rarer than the internet suggests, and it looks specific: poor weight gain, too few wet nappies, a baby who stays unsettled after full feeds. Not "my breasts feel soft" and not "she fed an hour ago".',
      action: 'Judge supply on nappies and weight, never on how full you feel.',
      askSomeone: 'Those specific signs together are worth your doctor or a lactation consultant, quickly.',
    ),
    JourneyDay(
      day: 28,
      title: 'Your head matters as much as your milk',
      body:
          'Feeding difficulty and low mood feed each other, and "just keep going" is not always the right advice. A parent who is struggling badly is a bigger problem than a bottle of formula.',
      action: 'If this is costing you more than it is giving your baby, that is a real fact and it counts.',
      askSomeone: 'Persistent low mood, anxiety, or intrusive thoughts: tell your doctor. Treatable, common, and not something to prove your way through.',
    ),
    JourneyDay(
      day: 29,
      title: 'How long is long enough?',
      body:
          'There is no threshold at which this "counted". A week is worth something. Three months is worth something. Two years is worth something. Any amount of breastfeeding you did is breastfeeding you did.',
      action: 'Whatever you have done so far — that is the answer to this question.',
    ),
    JourneyDay(
      day: 30,
      title: 'The month is behind you',
      body:
          'The hardest part is over, whatever shape your feeding has taken by now — exclusive, mixed, or finished. You learned a skill under the worst conditions anyone ever learns anything: exhausted, frightened, and on call.',
      action: 'Nothing today. Read day one again if you want to see how far this went.',
    ),
  ],
);

const List<Journey> kJourneys = [kBreastfeedingJourney];

Journey? journeyById(String id) {
  for (final j in kJourneys) {
    if (j.id == id) return j;
  }
  return null;
}

// =============================================================================
//  JourneyStore — enrolment + progress
// =============================================================================
class JourneyStore extends ChangeNotifier with CloudSyncedStore {
  JourneyStore._();
  static final JourneyStore instance = JourneyStore._();

  static const _key = 'journeys';

  /// journeyId -> ISO date the parent started.
  final Map<String, String> _started = {};

  /// journeyId -> day numbers read.
  final Map<String, Set<int>> _done = {};

  bool _loaded = false;

  Future<void> init() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw != null) _apply(jsonDecode(raw) as Map);
    } catch (_) {/* start fresh */}
    _loaded = true;
    notifyListeners();
    try {
      await syncStateFromCloud();
    } catch (_) {/* stay local */}
  }

  bool hasStarted(String id) => _started.containsKey(id);
  DateTime? startedOn(String id) {
    final s = _started[id];
    return s == null ? null : DateTime.tryParse(s);
  }

  /// The day the calendar says they are on — but nothing is locked to it.
  ///
  /// A parent who misses four days has not failed anything, so this only ever
  /// suggests where to pick up. Every day stays readable regardless.
  int suggestedDay(Journey j) {
    final start = startedOn(j.id);
    if (start == null) return 1;
    final days = DateTime.now().difference(DateTime(start.year, start.month, start.day)).inDays;
    return (days + 1).clamp(1, j.length);
  }

  bool isDone(String id, int day) => _done[id]?.contains(day) ?? false;
  int doneCount(String id) => _done[id]?.length ?? 0;
  double progress(Journey j) => j.length == 0 ? 0 : doneCount(j.id) / j.length;

  void start(String id) {
    _started[id] = DateTime.now().toIso8601String();
    _save();
  }

  void toggleDay(String id, int day) {
    final set = _done.putIfAbsent(id, () => <int>{});
    if (!set.remove(day)) set.add(day);
    _save();
  }

  /// Leaving is one tap and takes nothing away — a journey a parent cannot
  /// walk out of is a commitment, not a companion.
  void reset(String id) {
    _started.remove(id);
    _done.remove(id);
    _save();
  }

  // ---- persistence ---------------------------------------------------------
  Map<String, Object?> _toMap() => {
        'started': _started,
        'done': _done.map((k, v) => MapEntry(k, v.toList())),
      };

  void _apply(Map j) {
    _started
      ..clear()
      ..addAll((j['started'] as Map?)?.map((k, v) => MapEntry('$k', '$v')) ?? const {});
    _done
      ..clear()
      ..addAll((j['done'] as Map?)?.map(
            (k, v) => MapEntry('$k', ((v as List?) ?? const []).map((e) => (e as num).toInt()).toSet()),
          ) ??
          const {});
  }

  Future<void> _save() async {
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, jsonEncode(_toMap()));
    } catch (_) {/* best-effort */}
  }

  @override
  String get cloudKey => 'journeys';
  @override
  Object cloudData() => _toMap();
  @override
  void applyCloudData(Object data) => _apply(data as Map);
  @override
  Future<void> persistLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, jsonEncode(_toMap()));
    } catch (_) {/* best-effort */}
  }
}
