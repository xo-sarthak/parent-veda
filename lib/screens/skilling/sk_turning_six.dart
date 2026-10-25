// =============================================================================
//  Turning six: the learning space is ready, and the parent decides when
//  (2026-10-25, STAGE-TRANSITIONS F4 and F5)
// -----------------------------------------------------------------------------
//  The user (2026-10-25): "it's a good thing to ask the parent that hey,
//  [the learning space] is available for you, do you want to access it ...
//  even if they don't or they forget ... we keep prompting them, obviously not
//  irritating them ... and make sure [it] starts the moment the child turns 6,
//  so that they came at age seven ... we are [not] still showing them content
//  for the age 6. Automatically start the skilling side, but only show it to
//  the parent once they want to see it."
//
//  So, from the sixth birthday:
//    * the child's home stays Parenting until a grown-up says yes; the family
//      switch says "Learning space ready" on that child's row;
//    * a card on that child's parenting home asks, and "Not now" rests it
//      for 7 days, then 14, then 30, and every 30 after: it comes back, but
//      never daily;
//    * the age message on the birthday says the space is ready;
//    * "Take a look" opens the celebration page, then the grown-up gate,
//      then the learning space.
//
//  ⚠️ "STARTS AT SIX" NEEDS NOTHING STORED. The learning space reads the
//  child's age from her date of birth every time (`SkChildStore.band`), and
//  the gate fills the date from the parenting record, so a family that says
//  yes at seven lands on seven's content, never on a six-year-old's first day.
//
//  ⚠️ ONE LEARNING SPACE TODAY. `SkChildStore` holds one child, so a second
//  child of six or more shares the first one's space (STAGE-TRANSITIONS F5).
//  The prompt rests per child; the space does not yet.
//
//  On this phone only: losing it costs one more gentle question.
// =============================================================================

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../localization/app_language.dart';
import '../../services/pregnancy_controller.dart';
import '../../theme/pv_fonts.dart';
import '../../widgets/pv_feedback.dart';
import '../post_pregnancy/phase_map_screen.dart' show PhasePainting;
import '../post_pregnancy/pp_child_profile.dart';
import '../post_pregnancy/pp_phases_data.dart' show kPhases, ppFillChildFor;
import '../v2/pv_celebration.dart';
import '../v2/v2_palette.dart';
import 'sk_bands.dart' show kSkAgeFloor;
import 'sk_child_store.dart';
import 'sk_parent_gate_screen.dart';
import 'skilling_preview_screen.dart';

/// Whole years on [now].
int skYearsOn(DateTime dob, DateTime now) {
  var y = now.year - dob.year;
  if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) y--;
  return y < 0 ? 0 : y;
}

/// The rests after each "Not now": 7 days, then 14, then 30, then 30 again.
@visibleForTesting
Duration skTurningSixRest(int timesSaidNotNow) => switch (timesSaidNotNow) {
      <= 1 => const Duration(days: 7),
      2 => const Duration(days: 14),
      _ => const Duration(days: 30),
    };

class SkTurningSixPrompt extends ChangeNotifier {
  SkTurningSixPrompt._();
  static final SkTurningSixPrompt instance = SkTurningSixPrompt._();

  static const String kKey = 'sk_turning_six_v1';

  /// Per child id: how many times "Not now", and until when it rests.
  final Map<String, ({int count, DateTime until})> _rest = {};
  bool _loaded = false;

  Future<void> load() async {
    await SkChildStore.instance.load();
    if (_loaded) return;
    _loaded = true;
    try {
      final raw = (await SharedPreferences.getInstance()).getString(kKey);
      if (raw != null) {
        final j = jsonDecode(raw) as Map<String, dynamic>;
        j.forEach((id, v) {
          final m = v as Map<String, dynamic>;
          final until = DateTime.tryParse('${m['until']}');
          if (until != null) _rest[id] = (count: (m['count'] as num?)?.toInt() ?? 1, until: until);
        });
      }
    } catch (_) {/* asked again, which is the safe side */}
    notifyListeners();
  }

  /// True from [child]'s sixth birthday until a grown-up has opened the
  /// learning space, unless a "Not now" is resting it.
  bool showsFor(Child child, {DateTime? now}) {
    final t = now ?? DateTime.now();
    if (child.name == Child.placeholder && child.id.isEmpty) return false;
    if (skYearsOn(child.dob, t) < kSkAgeFloor) return false;
    if (SkChildStore.instance.consented) return false;
    final r = _rest[child.id];
    return r == null || !t.isBefore(r.until);
  }

  Future<void> notNow(Child child, {DateTime? now}) async {
    final t = now ?? DateTime.now();
    final count = (_rest[child.id]?.count ?? 0) + 1;
    _rest[child.id] = (count: count, until: t.add(skTurningSixRest(count)));
    notifyListeners();
    try {
      await (await SharedPreferences.getInstance()).setString(
          kKey,
          jsonEncode({
            for (final e in _rest.entries)
              e.key: {'count': e.value.count, 'until': e.value.until.toIso8601String()},
          }));
    } catch (_) {}
  }

  @visibleForTesting
  void resetForTest() {
    _rest.clear();
    _loaded = true;
  }
}

/// [line] written about a boy ("he", "his"), said about [child].
String _about(Child child, String line) =>
    ppFillChildFor(line, sexGiven: child.sexGiven, isBoy: child.isBoy, name: child.nameMid);

String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

/// The page's words, pure so the tests read them.
@visibleForTesting
({String title, String line, List<String> changes, String primary}) turningSixWords(
    Child child, {List<String> youngerNames = const []}) {
  final name = child.nameMid;
  return (
    title: '${_cap(name)} is six',
    line: _cap(_about(child, 'he is ready for a space of his own, to learn, make and play.')),
    changes: [
      'A grown-up says yes first, once',
      'Everything in it is for ${_cap(name)}\'s age today',
      if (youngerNames.length == 1)
        '${youngerNames.first} keeps the Parenting home'
      else if (youngerNames.length > 1)
        'Your younger children keep the Parenting home'
      else
        "${_cap(name)}'s baby years stay in the parenting records",
    ],
    primary: _cap(_about(child, 'set up his space')),
  );
}

/// The celebration, then the grown-up gate, then the learning space.
Future<void> openTurningSix(BuildContext context, Child child) async {
  final kids = ChildProfileStore.instance;
  final words = turningSixWords(child, youngerNames: [
    for (final c in kids.children)
      if (c.id != child.id && skYearsOn(c.dob, DateTime.now()) < kSkAgeFloor) c.name,
  ]);
  await Navigator.of(context).push(MaterialPageRoute<void>(
    settings: const RouteSettings(name: kPvCelebrationRoute),
    builder: (_) => PvCelebrationScreen(
      painting: PhasePainting(phase: kPhases.last),
      title: words.title,
      line: words.line,
      changes: words.changes,
      primary: words.primary,
      onPrimary: (c) => Navigator.of(c).pushReplacement(MaterialPageRoute<void>(
        settings: const RouteSettings(name: 'skilling/gate'),
        builder: (_) => SkParentGateScreen(
          onDone: (g) => Navigator.of(g).pushReplacement(MaterialPageRoute<void>(
            settings: const RouteSettings(name: 'skilling'),
            builder: (_) => SkillingPreviewScreen(
                lang: PregnancyController.current?.language ?? AppLanguage.english),
          )),
        ),
      )),
      secondary: 'Not now',
      onSecondary: (c) {
        SkTurningSixPrompt.instance.notNow(child);
        Navigator.of(c).maybePop();
      },
    ),
  ));
}

/// The card on a six-year-old's parenting home. Draws nothing otherwise.
class PpLearningSpaceCard extends StatefulWidget {
  const PpLearningSpaceCard({super.key, required this.p});
  final V2Palette p;

  @override
  State<PpLearningSpaceCard> createState() => _PpLearningSpaceCardState();
}

class _PpLearningSpaceCardState extends State<PpLearningSpaceCard> {
  @override
  void initState() {
    super.initState();
    SkTurningSixPrompt.instance.load();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: Listenable.merge([
          SkTurningSixPrompt.instance,
          SkChildStore.instance,
          ChildProfileStore.instance,
        ]),
        builder: (context, _) {
          final kids = ChildProfileStore.instance;
          if (!kids.hasRealChild) return const SizedBox.shrink();
          final child = kids.active;
          if (!SkTurningSixPrompt.instance.showsFor(child)) return const SizedBox.shrink();
          final p = widget.p;
          final name = _cap(child.nameMid);
          return Padding(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 14),
            child: Container(
              key: const ValueKey('pp_learning_space_card'),
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              decoration: BoxDecoration(
                color: p.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: p.line),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("$name's learning space is ready",
                    style: pvFraunces(fontSize: 18, fontWeight: FontWeight.w600, color: p.ink1)),
                const SizedBox(height: 4),
                Text(
                    _cap(_about(child,
                        'he is six now: a space of his own to learn, make and play. You decide when he sees it.')),
                    style: pvManrope(fontSize: 13, height: 1.45, color: p.ink2)),
                const SizedBox(height: 10),
                Wrap(spacing: 8, runSpacing: 6, children: [
                  FilledButton(
                    key: const ValueKey('pp_learning_space_look'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2F2C30),
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
                    ),
                    onPressed: () {
                      pvCommitFeedback();
                      openTurningSix(context, child);
                    },
                    child: Text('Take a look',
                        style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                  TextButton(
                    key: const ValueKey('pp_learning_space_not_now'),
                    onPressed: () {
                      pvCommitFeedback();
                      SkTurningSixPrompt.instance.notNow(child);
                    },
                    child: Text('Not now',
                        style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w700, color: p.ink2)),
                  ),
                ]),
              ]),
            ),
          );
        },
      );
}
