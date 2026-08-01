// =============================================================================
//  DailyTipPopup — the once-a-day card that opens with the app.
// -----------------------------------------------------------------------------
//  From the parenting review: "on landing on the app, a pop up will come which
//  can be saved and shared — the pop up will have either content or video (short
//  one) — actionable tip with a scientific reason (referring to a study)."
//
//  It replaces the "Today's parenting tip" SECTION on the My Child page, which
//  the same review asked to remove. Same content, better place: a thought for
//  the day is something you meet once and then get on with, not a card you
//  scroll past forty times.
//
//  ONCE A DAY, NOT ONCE A LAUNCH, and the difference matters. A parent opens
//  this app many times in a day — at 3am, in a waiting room, one-handed while
//  feeding. A pop-up on every launch stops being a gift by the third time and
//  becomes a door to push through. So it is keyed on the DATE, and once
//  dismissed it does not come back until tomorrow.
//
//  The Premiere takeover (brand/premiere_screen.dart) already learned this the
//  hard way and is currently forced on for review with kPremiereAlwaysShow — a
//  flag STILL-OPEN §1.4 says must be false before launch. This one has no such
//  flag: the debug affordance is a menu entry, not a global override, because
//  "show it every time" is exactly the state that must never reach a parent.
//
//  SAVING is local and instant. Sharing hands plain text to the OS sheet and
//  always carries the source line — a tip forwarded into a family WhatsApp
//  group with no provenance is precisely the kind of parenting advice this app
//  exists to be an alternative to.
//
//  ⚠️ VIDEO: the review allows "content OR video (short one)". Only the content
//  form is built. There is no short-form video attached to a tip in the
//  catalogue yet, and a play button that opens nothing would be worse than its
//  absence. Recorded in docs/STILL-OPEN.md.
// =============================================================================

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/remote/cloud_synced_store.dart';
import 'pp_common.dart';
import 'pp_daily_tips.dart';

// =============================================================================
//  Store — what was seen, and what was kept
// =============================================================================

class DailyTipStore extends ChangeNotifier with CloudSyncedStore {
  DailyTipStore._();
  static final DailyTipStore instance = DailyTipStore._();

  /// yyyy-MM-dd of the last day the pop-up was shown.
  String _lastShown = '';

  /// Tip ids the parent chose to keep.
  final Set<String> _saved = {};

  static const _prefsKey = 'pp_daily_tip_v1';

  /// Has the saved state been read yet?
  ///
  /// NOTHING IS SHOWN BEFORE THIS IS TRUE, and that is a correctness rule
  /// rather than a nicety: `shownToday` reads `_lastShown`, which is empty
  /// until the cache load finishes. Firing in that window would show a parent
  /// a tip she had already read and dismissed this morning — the pop-up would
  /// be wrong precisely on a slow device, where an extra modal is least
  /// welcome.
  ///
  /// It also means a widget test that pumps the My Child page never gets an
  /// unexpected sheet over it, because a test does not call init(). That is a
  /// consequence of the rule, not the reason for it.
  bool _ready = false;
  bool get isReady => _ready;

  @override
  String get cloudKey => _prefsKey;

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw != null) applyCloudData(jsonDecode(raw));
    } catch (_) {/* an unreadable cache is an empty one */}
    notifyListeners();
    try {
      await syncStateFromCloud();
    } catch (_) {/* stay local */}
    _ready = true;
  }

  @override
  Object cloudData() => {'lastShown': _lastShown, 'saved': _saved.toList()};

  @override
  void applyCloudData(Object data) {
    if (data is! Map) return;
    _lastShown = (data['lastShown'] ?? '').toString();
    final s = data['saved'];
    if (s is List) _saved..clear()..addAll(s.map((e) => e.toString()));
    notifyListeners();
  }

  @override
  Future<void> persistLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, jsonEncode(cloudData()));
    } catch (_) {/* in-memory state still stands */}
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
    persistLocalCache();
  }

  static String _key(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  /// Has today's already been shown?
  ///
  /// NOT "has the app been launched" — see the header. `lastShown` deliberately
  /// stores a DATE rather than a count.
  bool get shownToday => _lastShown == _key(DateTime.now());

  void markShown() {
    final today = _key(DateTime.now());
    if (_lastShown == today) return;
    _lastShown = today;
    notifyListeners();
  }

  bool isSaved(String id) => _saved.contains(id);

  void toggleSaved(String id) {
    if (!_saved.add(id)) _saved.remove(id);
    notifyListeners();
  }

  List<String> get saved => List.unmodifiable(_saved);

  /// For the debug menu entry — lets the pop-up be seen again today without a
  /// global "always show" flag existing in the build at all.
  void resetForToday() {
    _lastShown = '';
    notifyListeners();
  }
}

// =============================================================================
//  The pop-up
// =============================================================================

/// Show today's tip, if it has not been shown today.
///
/// Returns immediately when there is nothing to do, so a caller can fire it on
/// every home build without guarding.
Future<void> maybeShowDailyTip(BuildContext context) async {
  final store = DailyTipStore.instance;
  // See DailyTipStore._ready: showing before the saved state is loaded would
  // re-show a tip already dismissed today.
  if (!store.isReady || store.shownToday) return;
  store.markShown();
  if (!context.mounted) return;
  await showDailyTip(context);
}

/// Show it regardless — used by the "see it again" affordance.
Future<void> showDailyTip(BuildContext context) => showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _DailyTipSheet(),
    );

class _DailyTipSheet extends StatefulWidget {
  const _DailyTipSheet();

  @override
  State<_DailyTipSheet> createState() => _DailyTipSheetState();
}

class _DailyTipSheetState extends State<_DailyTipSheet> {
  bool _whyOpen = false;

  @override
  Widget build(BuildContext context) {
    final tip = dailyTip();
    final id = dailyTipId();
    final store = DailyTipStore.instance;

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final saved = store.isSaved(id);
        return Container(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.86),
          decoration: const BoxDecoration(
            color: ppBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(
                          color: ppBorder,
                          borderRadius: BorderRadius.circular(999)),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(children: [
                    const Icon(Icons.wb_twilight_rounded,
                        size: 16, color: ppPurple),
                    const SizedBox(width: 8),
                    Text('TODAY, IN ONE THING',
                        style: ppBody(10.5, color: ppPurple, w: FontWeight.w800)
                            .copyWith(letterSpacing: 1.0)),
                  ]),
                  const SizedBox(height: 14),
                  Text(tip.title, style: ppFraunces(27, h: 1.1)),
                  const SizedBox(height: 12),
                  Text(tip.body, style: ppBody(14.5, h: 1.65)),

                  if (tip.why.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    _why(tip),
                  ],

                  const SizedBox(height: 22),
                  _actions(context, tip, id, saved),
                  const SizedBox(height: 12),
                  _dismiss(context),
                  const SizedBox(height: 14),
                  Text(
                      'General guidance for this stage — not advice about your '
                      'child in particular. Anything that worries you is a '
                      'question for your paediatrician.',
                      style: ppBody(11.5, color: ppMuted, h: 1.5)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// The scientific reason, collapsed by default.
  ///
  /// Open-by-default would make this a lecture at 6am; buried entirely would
  /// make it decoration. A closed row with the words "why this works" is the
  /// honest middle — the evidence is one tap away for whoever wants it.
  Widget _why(DailyTip tip) => GestureDetector(
        onTap: () => setState(() => _whyOpen = !_whyOpen),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: ppBorder),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.science_outlined, size: 16, color: ppPurple),
              const SizedBox(width: 9),
              Expanded(child: Text('Why this works', style: ppJakarta(13.5))),
              Icon(
                  _whyOpen
                      ? Icons.expand_less_rounded
                      : Icons.expand_more_rounded,
                  size: 20,
                  color: ppMuted),
            ]),
            if (_whyOpen) ...[
              const SizedBox(height: 11),
              Text(tip.why, style: ppBody(13.5, h: 1.6)),
              if (tip.source.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 11, vertical: 8),
                  decoration: BoxDecoration(
                    color: ppPanel,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('Based on ${tip.source}',
                      style: ppBody(11.5, color: ppSoft, h: 1.45)),
                ),
              ],
            ],
          ]),
        ),
      );

  Widget _actions(BuildContext context, DailyTip tip, String id, bool saved) =>
      Row(children: [
        Expanded(
          child: GestureDetector(
            onTap: () => DailyTipStore.instance.toggleSaved(id),
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: saved ? ppPurple : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: saved ? ppPurple : ppBorder),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(
                    saved
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    size: 17,
                    color: saved ? Colors.white : ppPurple),
                const SizedBox(width: 8),
                Text(saved ? 'Saved' : 'Save',
                    style: ppBody(13.5,
                        color: saved ? Colors.white : ppPurple,
                        w: FontWeight.w800)),
              ]),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () => Share.share(dailyTipShareText(tip)),
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: ppBorder),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.ios_share_rounded, size: 16, color: ppPurple),
                const SizedBox(width: 8),
                Text('Share',
                    style:
                        ppBody(13.5, color: ppPurple, w: FontWeight.w800)),
              ]),
            ),
          ),
        ),
      ]);

  Widget _dismiss(BuildContext context) => GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: ppPanel,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text('Got it', style: ppJakarta(13.5, color: ppPurple)),
        ),
      );
}
