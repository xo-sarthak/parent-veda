// =============================================================================
//  ParentVeda Trackers - Feeding & Sleep data model + store
// -----------------------------------------------------------------------------
//  Two everyday parenting trackers, kept deliberately simple so a parent never
//  has to leave the app for them. A single in-memory ChangeNotifier singleton
//  (PpTrackerStore) holds the logs; both the Feeding tracker and Sleep tracker
//  screens read from it and listen for changes. Seeded with a few of "today's"
//  entries (relative to DateTime.now()) so the screens look alive on first open.
//  Static prototype - no persistence, no backend, matching the other pp stores.
// =============================================================================

import 'package:flutter/foundation.dart';

// ---- feeding ----------------------------------------------------------------
enum FeedType { breast, bottle, solid }

enum FeedSide { left, right }

/// One feed. `side`/`durationMin` describe a breastfeed; `amountMl` a bottle;
/// `note` is free text (used most for solids, optional everywhere).
class FeedEntry {
  FeedEntry({
    required this.id,
    required this.time,
    required this.type,
    this.side,
    this.amountMl,
    this.durationMin,
    this.note,
  });

  final String id;
  final DateTime time;
  final FeedType type;
  final FeedSide? side; // breast only
  final int? amountMl; // bottle only
  final int? durationMin; // breast only
  final String? note;
}

// ---- sleep ------------------------------------------------------------------
enum SleepQuality { sound, restless, brief }

/// One sleep stretch. `end` is always after `start`; `durationMinutes` is
/// derived. `quality` and `note` are optional colour.
class SleepEntry {
  SleepEntry({
    required this.id,
    required this.start,
    required this.end,
    this.quality,
    this.note,
  });

  final String id;
  final DateTime start;
  final DateTime end;
  final SleepQuality? quality;
  final String? note;

  int get durationMinutes {
    final m = end.difference(start).inMinutes;
    return m < 0 ? 0 : m;
  }
}

// ---- store ------------------------------------------------------------------
class PpTrackerStore extends ChangeNotifier {
  PpTrackerStore._() {
    _seed();
  }
  static final PpTrackerStore instance = PpTrackerStore._();

  final List<FeedEntry> _feeds = [];
  final List<SleepEntry> _sleeps = [];

  int _seq = 0;
  String _id(String prefix) => '${prefix}_${DateTime.now().microsecondsSinceEpoch}_${_seq++}';

  static bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  // ---- feeds --------------------------------------------------------------
  /// Every feed, newest first.
  List<FeedEntry> get feeds {
    final list = [..._feeds]..sort((a, b) => b.time.compareTo(a.time));
    return List.unmodifiable(list);
  }

  /// Today's feeds, newest first.
  List<FeedEntry> get todaysFeeds =>
      List.unmodifiable(feeds.where((f) => _isToday(f.time)));

  int get feedsTodayCount => todaysFeeds.length;

  /// The most recent feed overall (today or not), or null if none logged.
  FeedEntry? get lastFeed => feeds.isEmpty ? null : feeds.first;

  void addFeed(FeedEntry e) {
    _feeds.add(e);
    notifyListeners();
  }

  /// Convenience builder that mints an id and appends the feed.
  void logFeed({
    required DateTime time,
    required FeedType type,
    FeedSide? side,
    int? amountMl,
    int? durationMin,
    String? note,
  }) {
    addFeed(FeedEntry(
      id: _id('feed'),
      time: time,
      type: type,
      side: side,
      amountMl: amountMl,
      durationMin: durationMin,
      note: note,
    ));
  }

  void removeFeed(String id) {
    _feeds.removeWhere((f) => f.id == id);
    notifyListeners();
  }

  // ---- sleeps -------------------------------------------------------------
  /// Every sleep, newest first (by start).
  List<SleepEntry> get sleeps {
    final list = [..._sleeps]..sort((a, b) => b.start.compareTo(a.start));
    return List.unmodifiable(list);
  }

  /// Today's sleeps (counted by when they started), newest first.
  List<SleepEntry> get todaysSleeps =>
      List.unmodifiable(sleeps.where((s) => _isToday(s.start)));

  /// The most recent sleep overall, or null if none logged.
  SleepEntry? get lastSleep => sleeps.isEmpty ? null : sleeps.first;

  /// Total minutes of sleep that started today.
  int get totalSleepMinutesToday =>
      todaysSleeps.fold(0, (sum, s) => sum + s.durationMinutes);

  void addSleep(SleepEntry e) {
    _sleeps.add(e);
    notifyListeners();
  }

  /// Convenience builder that mints an id and appends the sleep.
  void logSleep({
    required DateTime start,
    required DateTime end,
    SleepQuality? quality,
    String? note,
  }) {
    addSleep(SleepEntry(
      id: _id('sleep'),
      start: start,
      end: end,
      quality: quality,
      note: note,
    ));
  }

  void removeSleep(String id) {
    _sleeps.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  // ---- seed ---------------------------------------------------------------
  //  A few of "today's" entries so both trackers look lived-in on first open.
  void _seed() {
    final now = DateTime.now();

    _feeds.addAll([
      FeedEntry(
        id: _id('feed'),
        time: now.subtract(const Duration(hours: 2, minutes: 10)),
        type: FeedType.breast,
        side: FeedSide.left,
        durationMin: 18,
      ),
      FeedEntry(
        id: _id('feed'),
        time: now.subtract(const Duration(hours: 5)),
        type: FeedType.bottle,
        amountMl: 120,
      ),
      FeedEntry(
        id: _id('feed'),
        time: now.subtract(const Duration(hours: 7, minutes: 30)),
        type: FeedType.solid,
        note: 'Mashed banana - a few spoons',
      ),
    ]);

    _sleeps.addAll([
      SleepEntry(
        id: _id('sleep'),
        start: now.subtract(const Duration(hours: 3, minutes: 30)),
        end: now.subtract(const Duration(hours: 1, minutes: 50)),
        quality: SleepQuality.sound,
      ),
      SleepEntry(
        id: _id('sleep'),
        start: now.subtract(const Duration(hours: 9)),
        end: now.subtract(const Duration(hours: 7, minutes: 20)),
        quality: SleepQuality.restless,
        note: 'Woke once, settled quickly',
      ),
    ]);
  }
}
