// =============================================================================
//  DearBabyVaultScreen  -  the "Dear Baby" memory vault
// -----------------------------------------------------------------------------
//  Surfaces every Talk-To-Your-Baby message the mother has saved (persisted in
//  DailyStore). Reached from a card on the Profile tab.
//
//  ⚠️ A KEEPSAKE, NOT A LIST — 2026-10-10. The user: "it has old UI, poor design
//  language ... its about celebration and excitement and should be reflected
//  like that for user else they won't be interested". It was a default grey
//  AppBar over plain cards: it read like a settings page. Now, from the Mobbin
//  look at keepsake apps (Bond's dated photo card, Paired's dated memory trail):
//    1. A COVER, not an app bar: "Letters to your baby", how many, which weeks.
//    2. EACH LETTER A KEEPSAKE CARD: paper tone, the week in a seal, the date in
//       italic serif, and what the baby was like that week.
//    3. A TIMELINE, oldest first and grouped by trimester, because a vault is
//       read as a story.
//    4. THE INVITATION ON TOP, every day: the empty vault is the feature's
//       advertisement, never a blank page (CLAUDE.md, "a feature is never
//       hidden").
//  Read aloud and the at-birth "open your letters" are the next step
//  (STILL-OPEN §83.2). New copy English; the shared Hindi strings stay.
// =============================================================================

import 'package:flutter/material.dart';

import '../services/daily_store.dart';
import '../services/pregnancy_controller.dart';
import '../theme/pv_fonts.dart';
import '../widgets/pv_feedback.dart';
import 'home_detail_screens.dart' show TalkComposerScreen;
import 'v2/v2_palette.dart';

/// The paper the letters are written on: a warm off-white, one step from the
/// page ground, so a letter reads as an object on the page.
const Color _paper = Color(0xFFFBF7F0);
const Color _paperLine = Color(0xFFEDE4D6);

const List<String> _kMonths = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String _niceDate(String iso) {
  final d = DateTime.tryParse(iso);
  if (d == null) return iso;
  return '${d.day} ${_kMonths[d.month - 1]} ${d.year}';
}

/// A tap with the app's press feedback (PvPress only draws the press).
Widget _tap(VoidCallback onTap, Widget child) => PvPress(
      child: GestureDetector(
          behavior: HitTestBehavior.opaque, onTap: onTap, child: child),
    );

int _trimesterOf(int week) => week <= 13 ? 1 : (week <= 27 ? 2 : 3);

const Map<int, String> _kTrimester = {
  1: 'First trimester',
  2: 'Second trimester',
  3: 'Third trimester',
};

class DearBabyVaultScreen extends StatefulWidget {
  const DearBabyVaultScreen({super.key, required this.controller});

  final PregnancyController controller;

  @override
  State<DearBabyVaultScreen> createState() => _DearBabyVaultScreenState();
}

class _DearBabyVaultScreenState extends State<DearBabyVaultScreen> {
  @override
  void initState() {
    super.initState();
    // Idempotent - ensures entries are loaded if this is opened very early.
    DailyStore.instance.init();
  }

  Future<void> _write({required bool voice}) async {
    final c = widget.controller;
    await Navigator.of(context).push(MaterialPageRoute<void>(
      settings: const RouteSettings(name: 'dear_baby/write'),
      builder: (_) => TalkComposerScreen(
        day: c.currentDay,
        week: c.currentWeek,
        prompt: 'What would you like your baby to know today?',
        motivation: 'A few lines is enough. They will be here, waiting, '
            'for the day you meet.',
        lang: c.language,
        startWithVoice: voice,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([DailyStore.instance, V2PaletteStore.instance]),
      builder: (context, _) {
        final p = V2PaletteStore.instance.current;
        // Oldest first: a vault is read as a story.
        final entries = [...DailyStore.instance.talkEntries]
          ..sort((a, b) {
            final d = a.dateIso.compareTo(b.dateIso);
            return d != 0 ? d : a.week.compareTo(b.week);
          });
        final top = MediaQuery.paddingOf(context).top;

        final children = <Widget>[
          _Cover(p: p, entries: entries, top: top),
          _Invitation(
            p: p,
            first: entries.isEmpty,
            onWrite: () => _write(voice: false),
            onSpeak: () => _write(voice: true),
          ),
        ];
        int? trimester;
        for (var i = 0; i < entries.length; i++) {
          final e = entries[i];
          final t = _trimesterOf(e.week);
          if (t != trimester) {
            trimester = t;
            children.add(_TrimesterHead(p: p, label: _kTrimester[t]!));
          }
          children.add(_LetterOnTrail(
            p: p,
            entry: e,
            fruit: widget.controller.weekData(e.week)?.snapshot.fruit.en,
            last: i == entries.length - 1,
          ));
        }
        children.add(SizedBox(height: 32 + MediaQuery.paddingOf(context).bottom));

        return Scaffold(
          backgroundColor: p.ground,
          body: Stack(children: [
            ListView(padding: EdgeInsets.zero, children: children),
            Positioned(
              top: top + 6,
              left: 10,
              child: _tap(() => Navigator.of(context).maybePop(), Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: p.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: p.line),
                  ),
                  child: Icon(Icons.arrow_back_rounded, size: 20, color: p.ink1),
                ),
              ),
            ),
          ]),
        );
      },
    );
  }
}

/// The cover: what this is, how many letters, across which weeks.
class _Cover extends StatelessWidget {
  const _Cover({required this.p, required this.entries, required this.top});
  final V2Palette p;
  final List<TalkEntry> entries;
  final double top;

  @override
  Widget build(BuildContext context) {
    final n = entries.length;
    final weeks = [for (final e in entries) if (e.week > 0) e.week];
    final span = weeks.isEmpty
        ? null
        : (weeks.first == weeks.last
            ? 'from week ${weeks.first}'
            : 'from week ${weeks.reduce((a, b) => a < b ? a : b)} to week '
                '${weeks.reduce((a, b) => a > b ? a : b)}');
    return Container(
      padding: EdgeInsets.fromLTRB(24, top + 64, 24, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF6EDE2), _paper],
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('DEAR BABY',
            style: pvManrope(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.6,
                color: p.ink3)),
        const SizedBox(height: 10),
        Text('Letters to\nyour baby',
            style: pvDisplayStyle(size: 36, height: 1.05, color: p.ink1)),
        const SizedBox(height: 12),
        Text(
          n == 0
              ? 'Words you write now, for them to read one day.'
              : '${n == 1 ? 'One letter' : '$n letters'}${span == null ? '' : ', $span'}. '
                  'Kept here for the day you meet.',
          style: pvManrope(fontSize: 14, height: 1.5, color: p.ink2),
        ),
      ]),
    );
  }
}

/// Today's invitation, always on top. The first letter gets the warmer line.
class _Invitation extends StatelessWidget {
  const _Invitation({
    required this.p,
    required this.first,
    required this.onWrite,
    required this.onSpeak,
  });
  final V2Palette p;
  final bool first;
  final VoidCallback onWrite;
  final VoidCallback onSpeak;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: p.line),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(first ? 'Write your first letter' : "Today's letter",
              style: pvHeadStyle(size: 19, color: p.ink1)),
          const SizedBox(height: 6),
          Text(
            first
                ? 'A line about today, a hope, a song you hum. One day they '
                    'will read every word.'
                : 'A few lines about today. Each one joins the trail below.',
            style: pvManrope(fontSize: 13, height: 1.5, color: p.ink2),
          ),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
              child: _tap(onWrite, Container(
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: p.ink1,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.edit_outlined, size: 17, color: Colors.white),
                    const SizedBox(width: 8),
                    Text('Write',
                        style: pvManrope(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ]),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _tap(onSpeak, Container(
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: p.surface,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: p.ink1),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.mic_none_rounded, size: 18, color: p.ink1),
                    const SizedBox(width: 8),
                    Text('Say it aloud',
                        style: pvManrope(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: p.ink1)),
                  ]),
                ),
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}

class _TrimesterHead extends StatelessWidget {
  const _TrimesterHead({required this.p, required this.label});
  final V2Palette p;
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 22, 24, 10),
        child: Text(label.toUpperCase(),
            style: pvManrope(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
                color: p.ink3)),
      );
}

/// One letter on the trail: a dot and a thread on the left, the card beside it.
class _LetterOnTrail extends StatelessWidget {
  const _LetterOnTrail({
    required this.p,
    required this.entry,
    required this.fruit,
    required this.last,
  });
  final V2Palette p;
  final TalkEntry entry;
  final String? fruit;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SizedBox(
          width: 40,
          child: Column(children: [
            const SizedBox(height: 26),
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: _paper,
                shape: BoxShape.circle,
                border: Border.all(color: p.ink2, width: 1.5),
              ),
            ),
            if (!last)
              Expanded(child: Container(width: 1.2, color: _paperLine)),
          ]),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 6, 16, 10),
            child: _LetterCard(p: p, entry: entry, fruit: fruit),
          ),
        ),
      ]),
    );
  }
}

class _LetterCard extends StatelessWidget {
  const _LetterCard({required this.p, required this.entry, required this.fruit});
  final V2Palette p;
  final TalkEntry entry;
  final String? fruit;

  @override
  Widget build(BuildContext context) {
    final e = entry;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: _paper,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _paperLine),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          // The seal: the week, stamped.
          if (e.week > 0)
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: p.ink1, width: 1.2),
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text('WEEK',
                    style: pvManrope(
                        fontSize: 7.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: p.ink2)),
                Text('${e.week}',
                    style: pvDisplayStyle(size: 17, height: 1.0, color: p.ink1)),
              ]),
            ),
          if (e.week > 0) const SizedBox(width: 12),
          Expanded(
            child: Text(_niceDate(e.dateIso),
                style: pvFraunces(
                    fontSize: 15, fontStyle: FontStyle.italic, color: p.ink2)),
          ),
          Icon(e.spoken ? Icons.mic_none_rounded : Icons.edit_outlined,
              size: 16, color: p.ink3),
          const SizedBox(width: 4),
          Text(e.spoken ? 'Spoken' : 'Written',
              style: pvManrope(fontSize: 11.5, color: p.ink3)),
        ]),
        if (e.prompt.trim().isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(e.prompt.trim(),
              style: pvManrope(
                  fontSize: 12, fontWeight: FontWeight.w700, color: p.ink3)),
        ],
        const SizedBox(height: 8),
        Text(e.text,
            style: pvFraunces(fontSize: 17, height: 1.5, color: p.ink1)),
        if (fruit != null && fruit!.trim().isNotEmpty) ...[
          const SizedBox(height: 14),
          Container(height: 1, color: _paperLine),
          const SizedBox(height: 10),
          Row(children: [
            Icon(Icons.spa_outlined, size: 15, color: p.ink3),
            const SizedBox(width: 6),
            Expanded(
              child: Text('Your baby that week: the size of ${fruit!.trim().toLowerCase()}',
                  style: pvManrope(fontSize: 12, color: p.ink2)),
            ),
          ]),
        ],
      ]),
    );
  }
}

// ---- KEPT FOR REVERT (2026-10-10): the plain list --------------------------
// Scaffold(appBar: AppBar(title: Text(s.dearBabyVaultTitle)), body: ...
// ListView.separated of _VaultCard(week, date, prompt, body, tag: spoken/
// written, weekWord), and _EmptyState(message: s.dearBabyEmpty) when empty.
// _VaultCard: a surface Container (radius 20, outlineVariant border) with a
// "Week N" pill in secondary50 / secondary700, the ISO date at the right, the
// prompt in labelMedium secondary600, the body in bodyLarge and a heart + tag.
// _EmptyState: a 72px secondary50 square with a heart icon above the message.
