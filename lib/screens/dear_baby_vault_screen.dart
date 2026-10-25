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
//
//  ⚠️ THE THREE OWED PARTS — 2026-10-15 (STILL-OPEN §83.2, REMAINING-CHANGES
//  8 + 12, folded into one pass on the user's word). Mobbin pass in
//  MOBBIN-DISCOVERY §22.
//    5. READ ALOUD on every letter, and "Read them all" on the cover. Never
//       locked: reading her own words to the bump is the point. The row being
//       read turns into a moving level mark (Brink's playing pill), and a
//       floating bar says which letter of how many with a Stop (Queue's
//       floating Play). The pill answers the tap before the voice starts.
//    6. THE BOOK, SEALED UNTIL BIRTH (the user: "unlocks at birth"). Before:
//       a sealed tile, a book with a lock badge and when it opens (Substack's
//       locked card): visible, never hidden. After the birth and the opening:
//       "Download your letters book" (LetterBookPdf).
//    7. "OPEN YOUR LETTERS" AT BIRTH. While the letters are unlocked but not
//       opened (DearBabyVaultStore), the vault hands over to
//       DearBabyOpeningScreen once a session, and the book card says "ready
//       to open" until she does.
//  After the birth the Write / Say it aloud invitation steps aside: a letter
//  written now would be stamped with a pregnancy week that is over. Kept in
//  code, shown only before birth.
//  New copy English; the shared Hindi strings stay.
// =============================================================================

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../localization/app_language.dart';
import '../services/daily_store.dart';
import '../services/dear_baby_vault_store.dart';
import '../services/garbh_narrator.dart';
import '../services/letter_book_pdf.dart';
import '../services/pregnancy_controller.dart';
import '../theme/pv_fonts.dart';
import '../widgets/pv_feedback.dart';
import '../widgets/pv_toast.dart';
import 'dear_baby_opening_screen.dart';
import 'home_detail_screens.dart' show TalkComposerScreen;
import 'v2/v2_palette.dart';
import '../services/pregnancy_records.dart';

/// The letters this vault holds (R1, 2026-10-25). Once the baby is born,
/// the letters of the pregnancy that became them, even after a later
/// pregnancy starts (whose letters are its own); before the birth, the
/// pregnancy going on now.
List<TalkEntry> dearBabyLetters() {
  final born = DearBabyVaultStore.instance.bornOn;
  if (born == null) return DailyStore.instance.talkEntries;
  final recs = PregnancyRecords.instance;
  final before = born.subtract(const Duration(days: 1));
  for (final r in recs.all) {
    final w = recs.windowOf(r);
    if (w.holds(before)) return DailyStore.instance.talkEntriesIn(w);
  }
  return DailyStore.instance.talkEntries;
}

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
Widget _tap(VoidCallback onTap, Widget child, {Key? key}) => PvPress(
      child: GestureDetector(
          key: key,
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: child),
    );

int _trimesterOf(int week) => week <= 13 ? 1 : (week <= 27 ? 2 : 3);

const Map<int, String> _kTrimester = {
  1: 'First trimester',
  2: 'Second trimester',
  3: 'Third trimester',
};

/// One letter's identity on this screen. The id is a clock reading, and two
/// letters saved in the same tick (a cloud merge, a coarse clock) can share
/// it; the day cannot, because a day holds one letter (DailyStore.saveTalk
/// replaces it). So the pair is the key, for the voice and the scroll alike.
String _letterId(TalkEntry e) => '${e.id}_${e.day}';

String _speakKey(TalkEntry e) => 'dear_baby/${_letterId(e)}';

class DearBabyVaultScreen extends StatefulWidget {
  const DearBabyVaultScreen({super.key, required this.controller});

  /// Null after the birth on a phone where the pregnancy controller is gone;
  /// the vault then simply drops the "your baby that week" line.
  final PregnancyController? controller;

  /// The opening hands over once per app session, not on every visit: "Later"
  /// must mean later.
  static bool _openingOfferedThisSession = false;

  @visibleForTesting
  static void resetSessionForTest() => _openingOfferedThisSession = false;

  @override
  State<DearBabyVaultScreen> createState() => _DearBabyVaultScreenState();
}

class _DearBabyVaultScreenState extends State<DearBabyVaultScreen> {
  final GarbhNarrator _narrator = GarbhNarrator.instance;
  final Map<String, GlobalKey> _cardKeys = {};

  /// The letter she just tapped, shown as reading before the engine starts,
  /// so the pill answers the finger and not the TTS warm-up.
  String? _pending;

  /// "Read them all": the letters still to read, in order.
  List<TalkEntry> _queue = const [];
  int _queueTotal = 0;
  String? _lastStarted;

  bool _making = false;

  PregnancyController? get _ctl => widget.controller ?? PregnancyController.current;

  @override
  void initState() {
    super.initState();
    // Idempotent - ensures entries are loaded if this is opened very early.
    DailyStore.instance.init();
    _narrator.addListener(_onNarrator);
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeOfferOpening());
  }

  @override
  void dispose() {
    _narrator.removeListener(_onNarrator);
    // Leaving the vault ends the reading: a voice from a closed screen is a
    // voice she cannot find to stop.
    final k = _narrator.speakingKey;
    if (k != null && k.startsWith('dear_baby/')) _narrator.stop();
    super.dispose();
  }

  // List<TalkEntry> get _entries => [...DailyStore.instance.talkEntries] // kept for revert
  List<TalkEntry> get _entries => [...dearBabyLetters()]
    ..sort((a, b) {
      final d = a.dateIso.compareTo(b.dateIso);
      return d != 0 ? d : a.week.compareTo(b.week);
    });

  // ---- The opening ---------------------------------------------------------

  Future<void> _maybeOfferOpening() async {
    await DearBabyVaultStore.instance.init();
    await DailyStore.instance.init();
    final v = DearBabyVaultStore.instance;
    if (!mounted || !v.unlocked || v.opened || _entries.isEmpty) return;
    if (DearBabyVaultScreen._openingOfferedThisSession) return;
    DearBabyVaultScreen._openingOfferedThisSession = true;
    await _openLetters();
  }

  Future<void> _openLetters() async {
    final entries = _entries;
    final weeks = [for (final e in entries) if (e.week > 0) e.week];
    await Navigator.of(context).push(PageRouteBuilder<bool>(
      settings: const RouteSettings(name: 'dear_baby/open'),
      transitionDuration: const Duration(milliseconds: 380),
      reverseTransitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (_, _, _) => DearBabyOpeningScreen(
        letters: entries.length,
        firstWeek: weeks.isEmpty ? null : weeks.reduce((a, b) => a < b ? a : b),
        lastWeek: weeks.isEmpty ? null : weeks.reduce((a, b) => a > b ? a : b),
      ),
      transitionsBuilder: (_, a, _, child) => FadeTransition(
        opacity: CurvedAnimation(parent: a, curve: Curves.easeOut),
        child: child,
      ),
    ));
  }

  // ---- Read aloud ----------------------------------------------------------

  void _onNarrator() {
    if (!mounted) return;
    final now = _narrator.speakingKey;
    if (now != null && now == _pending) _pending = null;
    // The letter finished on its own: "Read them all" moves to the next.
    if (now == null && _lastStarted != null && _queue.isNotEmpty) {
      final next = _queue.first;
      _queue = _queue.sublist(1);
      _start(next);
    } else if (now == null && _queue.isEmpty) {
      _lastStarted = null;
      _queueTotal = 0;
    }
    setState(() {});
  }

  void _start(TalkEntry e) {
    final key = _speakKey(e);
    _pending = key;
    _lastStarted = key;
    final ctx = _cardKeys[_letterId(e)]?.currentContext;
    if (ctx != null && _queueTotal > 0) {
      Scrollable.ensureVisible(ctx,
          alignment: 0.25,
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeInOut);
    }
    _narrator.speak(key, e.text.trim());
  }

  void _toggleOne(TalkEntry e) {
    pvCommitFeedback();
    final key = _speakKey(e);
    if (_isReading(key)) {
      _stopAll();
      return;
    }
    // One letter tapped ends "Read them all": she chose this one.
    _queue = const [];
    _queueTotal = 0;
    setState(() => _start(e));
  }

  void _readAll() {
    pvCommitFeedback();
    final all = _entries.where((e) => e.text.trim().isNotEmpty).toList();
    if (all.isEmpty) return;
    _queueTotal = all.length;
    _queue = all.sublist(1);
    setState(() => _start(all.first));
  }

  void _stopAll() {
    _queue = const [];
    _queueTotal = 0;
    _lastStarted = null;
    _pending = null;
    _narrator.stop();
    setState(() {});
  }

  bool _isReading(String key) => _pending == key || _narrator.speakingKey == key;

  bool get _readingAll => _queueTotal > 0;

  // ---- The book ------------------------------------------------------------

  Future<void> _makeBook() async {
    if (_making) return;
    pvCommitFeedback();
    setState(() => _making = true);
    try {
      final v = DearBabyVaultStore.instance;
      final c = _ctl;
      final items = LetterBookPdf.plan(_entries,
          fruitOf: (w) => c?.weekData(w)?.snapshot.fruit.en);
      final bytes = await LetterBookPdf.build(
        items: items,
        lang: c?.language ?? AppLanguage.english,
        childName: v.childName,
        bornOn: v.bornOn,
      );
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/parentveda_letters_'
          '${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(bytes);
      if (!mounted) return;
      await Navigator.of(context).push(MaterialPageRoute<void>(
        settings: const RouteSettings(name: 'dear_baby/book'),
        builder: (_) => LetterBookPreviewScreen(bytes: bytes, filePath: file.path),
      ));
    } catch (_) {
      if (mounted) {
        pvToast(context, 'The book could not be made just now. Try again in a moment.',
            kind: PvToastKind.gentle);
      }
    } finally {
      if (mounted) setState(() => _making = false);
    }
  }

  void _sealedTap() {
    pvCommitFeedback();
    pvToast(context, 'Your book opens the day your baby is born.');
  }

  Future<void> _write({required bool voice}) async {
    final c = _ctl;
    if (c == null) return;
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
      animation: Listenable.merge([
        DailyStore.instance,
        V2PaletteStore.instance,
        DearBabyVaultStore.instance,
      ]),
      builder: (context, _) {
        final p = V2PaletteStore.instance.current;
        final vault = DearBabyVaultStore.instance;
        // Oldest first: a vault is read as a story.
        final entries = _entries;
        final top = MediaQuery.paddingOf(context).top;
        final bottom = MediaQuery.paddingOf(context).bottom;

        final children = <Widget>[
          _Cover(
            p: p,
            entries: entries,
            top: top,
            name: vault.opened ? vault.childName : null,
            opened: vault.opened,
            readingAll: _readingAll,
            onReadAll: entries.isEmpty
                ? null
                : (_readingAll ? _stopAll : _readAll),
          ),
          if (!vault.unlocked)
            _Invitation(
              p: p,
              first: entries.isEmpty,
              onWrite: () => _write(voice: false),
              onSpeak: () => _write(voice: true),
            ),
          if (!vault.unlocked || entries.isNotEmpty)
            _BookCard(
              p: p,
              count: entries.length,
              state: !vault.unlocked
                  ? _BookState.sealed
                  : (vault.opened ? _BookState.ready : _BookState.toOpen),
              making: _making,
              onTap: !vault.unlocked
                  ? _sealedTap
                  : (vault.opened ? _makeBook : _openLetters),
            ),
          if (vault.unlocked && entries.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: Text(
                'No letters were written in pregnancy. The words you say to '
                'your baby now count just as much.',
                style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink2),
              ),
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
          final key = _cardKeys.putIfAbsent(_letterId(e), () => GlobalKey());
          children.add(KeyedSubtree(
            key: key,
            child: _LetterOnTrail(
              p: p,
              entry: e,
              fruit: _ctl?.weekData(e.week)?.snapshot.fruit.en,
              last: i == entries.length - 1,
              reading: _isReading(_speakKey(e)),
              onRead: e.text.trim().isEmpty ? null : () => _toggleOne(e),
            ),
          ));
        }
        children.add(SizedBox(height: (_readingAll ? 96 : 32) + bottom));

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
            // The floating bar while "Read them all" runs: which letter of how
            // many, and the one way to stop it.
            AnimatedPositioned(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              left: 16,
              right: 16,
              bottom: _readingAll ? 16 + bottom : -90,
              child: _ReadAllBar(
                p: p,
                index: _queueTotal - _queue.length,
                total: _queueTotal,
                onStop: _stopAll,
              ),
            ),
          ]),
        );
      },
    );
  }
}

/// The cover: what this is, how many letters, across which weeks, and
/// "Read them all".
class _Cover extends StatelessWidget {
  const _Cover({
    required this.p,
    required this.entries,
    required this.top,
    required this.name,
    required this.opened,
    required this.readingAll,
    required this.onReadAll,
  });
  final V2Palette p;
  final List<TalkEntry> entries;
  final double top;
  final String? name;
  final bool opened;
  final bool readingAll;
  final VoidCallback? onReadAll;

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
      padding: EdgeInsets.fromLTRB(24, top + 64, 24, 24),
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
        Text(opened ? 'Letters to\n${name ?? 'your baby'}' : 'Letters to\nyour baby',
            style: pvDisplayStyle(size: 36, height: 1.05, color: p.ink1)),
        const SizedBox(height: 12),
        Text(
          n == 0
              ? 'Words you write now, for them to read one day.'
              : '${n == 1 ? 'One letter' : '$n letters'}${span == null ? '' : ', $span'}. '
                  '${opened ? 'Opened the day you met.' : 'Kept here for the day you meet.'}',
          style: pvManrope(fontSize: 14, height: 1.5, color: p.ink2),
        ),
        if (onReadAll != null) ...[
          const SizedBox(height: 16),
          _tap(onReadAll!, AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: readingAll ? p.ink1 : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: p.ink1),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(readingAll ? Icons.stop_rounded : Icons.play_arrow_rounded,
                    size: 19, color: readingAll ? Colors.white : p.ink1),
                const SizedBox(width: 6),
                Text(readingAll ? 'Stop reading' : 'Read them all aloud',
                    style: pvManrope(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: readingAll ? Colors.white : p.ink1)),
              ]),
            ),
            key: const ValueKey('dear_baby_read_all'),
          ),
        ],
      ]),
    );
  }
}

/// Today's invitation, on top until the birth. The first letter gets the
/// warmer line.
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

enum _BookState { sealed, toOpen, ready }

/// The book of letters: sealed until the birth, then waiting to be opened,
/// then ready to download.
class _BookCard extends StatelessWidget {
  const _BookCard({
    required this.p,
    required this.count,
    required this.state,
    required this.making,
    required this.onTap,
  });
  final V2Palette p;
  final int count;
  final _BookState state;
  final bool making;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final sealed = state == _BookState.sealed;
    final title = switch (state) {
      _BookState.sealed => 'Your letters, as a book',
      _BookState.toOpen => 'Your letters are ready to open',
      _BookState.ready => 'Download your letters book',
    };
    final line = switch (state) {
      _BookState.sealed => count == 0
          ? 'Every letter you write goes in. It opens the day you meet.'
          : '${count == 1 ? 'One letter' : '$count letters'} so far. '
              'It opens the day you meet.',
      _BookState.toOpen => 'They were sealed until today.',
      _BookState.ready => making
          ? 'Making your book…'
          : 'A page for every letter, to keep, print or share.',
    };
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: _tap(onTap, AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          decoration: BoxDecoration(
            color: sealed ? _paper : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: sealed ? _paperLine : p.ink1.withValues(alpha: 0.25)),
          ),
          child: Row(children: [
            // The mark: a book, with a lock badge while sealed.
            SizedBox(
              width: 48,
              height: 48,
              child: Stack(clipBehavior: Clip.none, children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: sealed ? Colors.white : _paper,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _paperLine),
                  ),
                  child: Icon(Icons.menu_book_outlined,
                      size: 22, color: sealed ? p.ink3 : p.ink1),
                ),
                if (sealed)
                  Positioned(
                    right: -4,
                    bottom: -4,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: p.ink1,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.lock_outline_rounded,
                          size: 11, color: Colors.white),
                    ),
                  ),
              ]),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title,
                    style: pvManrope(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: sealed ? p.ink2 : p.ink1)),
                const SizedBox(height: 3),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(line,
                      key: ValueKey(line),
                      style: pvManrope(fontSize: 12.5, height: 1.4, color: p.ink3)),
                ),
              ]),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 22,
              height: 22,
              child: making
                  ? CircularProgressIndicator(strokeWidth: 2, color: p.ink1)
                  : Icon(
                      switch (state) {
                        _BookState.sealed => Icons.schedule_rounded,
                        _BookState.toOpen => Icons.arrow_forward_rounded,
                        _BookState.ready => Icons.download_rounded,
                      },
                      size: 20,
                      color: sealed ? p.ink3 : p.ink1),
            ),
          ]),
        ),
        key: const ValueKey('dear_baby_book'),
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
    required this.reading,
    required this.onRead,
  });
  final V2Palette p;
  final TalkEntry entry;
  final String? fruit;
  final bool last;
  final bool reading;
  final VoidCallback? onRead;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SizedBox(
          width: 40,
          child: Column(children: [
            const SizedBox(height: 26),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: reading ? p.ink1 : _paper,
                shape: BoxShape.circle,
                border: Border.all(color: reading ? p.ink1 : p.ink2, width: 1.5),
              ),
            ),
            if (!last)
              Expanded(child: Container(width: 1.2, color: _paperLine)),
          ]),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 6, 16, 10),
            child: _LetterCard(
                p: p, entry: entry, fruit: fruit, reading: reading, onRead: onRead),
          ),
        ),
      ]),
    );
  }
}

class _LetterCard extends StatelessWidget {
  const _LetterCard({
    required this.p,
    required this.entry,
    required this.fruit,
    required this.reading,
    required this.onRead,
  });
  final V2Palette p;
  final TalkEntry entry;
  final String? fruit;
  final bool reading;
  final VoidCallback? onRead;

  @override
  Widget build(BuildContext context) {
    final e = entry;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
      decoration: BoxDecoration(
        color: _paper,
        borderRadius: BorderRadius.circular(18),
        // The letter being read gets the soft ink edge.
        border: Border.all(
            color: reading ? p.ink1.withValues(alpha: 0.55) : _paperLine,
            width: reading ? 1.4 : 1),
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
        if (onRead != null) ...[
          const SizedBox(height: 12),
          _ReadPill(p: p, reading: reading, onTap: onRead!),
        ],
      ]),
    );
  }
}

/// "Read aloud" on a letter; while reading, a moving level mark and "Stop".
class _ReadPill extends StatelessWidget {
  const _ReadPill({required this.p, required this.reading, required this.onTap});
  final V2Palette p;
  final bool reading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerLeft,
        child: _tap(onTap, AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 34,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: reading ? p.ink1 : Colors.white,
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: reading ? p.ink1 : _paperLine),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              reading
                  ? const _Levels(color: Colors.white)
                  : Icon(Icons.volume_up_outlined, size: 16, color: p.ink1),
              const SizedBox(width: 7),
              Text(reading ? 'Reading · Stop' : 'Read aloud',
                  style: pvManrope(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: reading ? Colors.white : p.ink1)),
            ]),
          ),
        ),
      );
}

/// Three bars moving out of step: the line mark for "this is being read".
class _Levels extends StatefulWidget {
  const _Levels({required this.color, this.active = true});
  final Color color;

  /// False parks the bars still. The floating bar is built off screen while
  /// nothing is read; a mark that kept moving there would burn frames (and
  /// battery) for nobody.
  final bool active;

  @override
  State<_Levels> createState() => _LevelsState();
}

class _LevelsState extends State<_Levels> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  void _sync() {
    // Reduced motion: three still bars, the state still reads.
    if (!widget.active || MediaQuery.of(context).disableAnimations) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(covariant _Levels old) {
    super.didUpdateWidget(old);
    if (old.active != widget.active) _sync();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (_, _) => SizedBox(
          width: 16,
          height: 14,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final phase in const [0.0, 0.33, 0.66])
                Container(
                  width: 3,
                  height: 4 + 10 * (0.5 + 0.5 * _wave(_c.value + phase)),
                  decoration: BoxDecoration(
                    color: widget.color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
            ],
          ),
        ),
      );

  static double _wave(double t) {
    final x = (t % 1.0) * 2 - 1; // -1..1
    return 1 - 2 * x.abs(); // a triangle wave, -1..1
  }
}

/// The floating bar while "Read them all" runs.
class _ReadAllBar extends StatelessWidget {
  const _ReadAllBar({
    required this.p,
    required this.index,
    required this.total,
    required this.onStop,
  });
  final V2Palette p;
  final int index;
  final int total;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) => Container(
        height: 56,
        padding: const EdgeInsets.fromLTRB(18, 0, 8, 0),
        decoration: BoxDecoration(
          color: p.ink1,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(children: [
          _Levels(color: Colors.white, active: total > 0),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              total == 0 ? 'Reading' : 'Reading letter ${index.clamp(1, total)} of $total',
              style: pvManrope(
                  fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ),
          _tap(onStop, Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('Stop',
                  style: pvManrope(
                      fontSize: 13.5, fontWeight: FontWeight.w700, color: p.ink1)),
            ),
          ),
        ]),
      );
}

// =============================================================================
//  DearBabyLettersReadyCard — on the parenting home until she opens them
// -----------------------------------------------------------------------------
//  Draws nothing unless the letters are unlocked, not yet opened, and there is
//  at least one. Opens the vault, which hands over to the opening.
// =============================================================================

class DearBabyLettersReadyCard extends StatelessWidget {
  const DearBabyLettersReadyCard({super.key, required this.p});
  final V2Palette p;

  @override
  Widget build(BuildContext context) {
    final v = DearBabyVaultStore.instance;
    v.init();
    return ListenableBuilder(
      listenable: Listenable.merge([v, DailyStore.instance]),
      builder: (context, _) {
        // final n = DailyStore.instance.talkEntries.length; // kept for revert
        final n = dearBabyLetters().length;
        if (!v.unlocked || v.opened || n == 0) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
          child: _tap(() {
            pvCommitFeedback();
            Navigator.of(context).push(MaterialPageRoute<void>(
              settings: const RouteSettings(name: 'dear_baby'),
              builder: (_) =>
                  DearBabyVaultScreen(controller: PregnancyController.current),
            ));
          }, Container(
              padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
              decoration: BoxDecoration(
                color: _paper,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _paperLine),
              ),
              child: Row(children: [
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: p.ink1, shape: BoxShape.circle),
                  child: const Icon(Icons.mail_outline_rounded,
                      size: 22, color: Colors.white),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Your letters are ready to open',
                        style: pvManrope(
                            fontSize: 14.5, fontWeight: FontWeight.w700, color: p.ink1)),
                    const SizedBox(height: 3),
                    Text(
                        '${n == 1 ? 'One letter' : '$n letters'} you wrote in pregnancy, '
                        'sealed until today.',
                        style: pvManrope(fontSize: 12.5, height: 1.4, color: p.ink2)),
                  ]),
                ),
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 20, color: p.ink1),
              ]),
            ),
            key: const ValueKey('dear_baby_ready_card'),
          ),
        );
      },
    );
  }
}

// =============================================================================
//  LetterBookPreviewScreen — the book, before she shares it
// -----------------------------------------------------------------------------
//  From the Mobbin pass: Polarsteps' "your book is ready" over the book, and
//  Withings' one pair at the foot (Close / Share) rather than an app bar of
//  icons. The preview's own action bar is off; print stays one tap away in
//  the share sheet.
// =============================================================================

class LetterBookPreviewScreen extends StatefulWidget {
  const LetterBookPreviewScreen({
    super.key,
    required this.bytes,
    required this.filePath,
  });

  final Uint8List bytes;
  final String filePath;

  @override
  State<LetterBookPreviewScreen> createState() => _LetterBookPreviewScreenState();
}

class _LetterBookPreviewScreenState extends State<LetterBookPreviewScreen> {
  bool _sharing = false;

  Future<void> _share() async {
    if (_sharing) return;
    pvCommitFeedback();
    setState(() => _sharing = true);
    try {
      await Share.shareXFiles(
        [XFile(widget.filePath, mimeType: 'application/pdf')],
        text: 'Letters written while you were on your way.',
      );
    } catch (_) {
      if (mounted) {
        pvToast(context, 'Sharing did not open. Try again in a moment.',
            kind: PvToastKind.gentle);
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      backgroundColor: p.ground,
      body: SafeArea(
        bottom: false,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 4),
            child: Text('Your letters book is ready',
                style: pvDisplayStyle(size: 26, height: 1.15, color: p.ink1)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Text('Every letter, a page of its own. Keep it, print it, or send it.',
                style: pvManrope(fontSize: 13.5, height: 1.45, color: p.ink2)),
          ),
          Expanded(
            child: PdfPreview(
              build: (_) => widget.bytes,
              useActions: false,
              canChangePageFormat: false,
              canChangeOrientation: false,
              canDebug: false,
              scrollViewDecoration: BoxDecoration(color: p.ground),
              pdfFileName: widget.filePath.split(Platform.pathSeparator).last,
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 10, 16, 12 + bottom),
            child: Row(children: [
              Expanded(
                child: _tap(() => Navigator.of(context).maybePop(), Container(
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: p.ink1),
                    ),
                    child: Text('Close',
                        style: pvManrope(
                            fontSize: 14.5, fontWeight: FontWeight.w700, color: p.ink1)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _tap(_share, Container(
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: p.ink1,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: _sharing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : Row(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.ios_share_rounded,
                                size: 18, color: Colors.white),
                            const SizedBox(width: 8),
                            Text('Share or save',
                                style: pvManrope(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white)),
                          ]),
                  ),
                ),
              ),
            ]),
          ),
        ]),
      ),
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
//
// ---- KEPT FOR REVERT (2026-10-15): before read aloud and the birth ---------
// The invitation showed in every state (no `if (!vault.unlocked)`), there was
// no _BookCard, no _ReadPill on the card, no "Read them all" on the cover and
// no _ReadAllBar; the card padding was 18,16,18,16 in a plain Container.
