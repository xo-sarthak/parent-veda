// =============================================================================
//  My Journal - the thing she is actually making
// -----------------------------------------------------------------------------
//  ⚠️ THE SPEC CALLS THIS THE WOMB ALBUM. THE APP CALLS IT MY JOURNAL, on the
//  user's instruction, and the rename is the better call for a concrete
//  reason: ParentVeda already has a journal, and shipping a second keepsake
//  surface beside it would leave a mother with two places a memory might be
//  and no way to guess which. One place everything lands - her recordings,
//  what the baby heard, and every voice her family sends - is the promise.
//
//  ---------------------------------------------------------------------------
//  ⚠️ THIS SCREEN IS THE POINT OF THE WHOLE SECTION
//  ---------------------------------------------------------------------------
//  The rebuild's single principle is that she is not completing a practice,
//  she is making something for her child. Nothing else in Garbh Sanskar can
//  demonstrate that; a streak counter and a tick cannot. This screen is where
//  the claim is either true or it is not, because it is the only place the
//  accumulated thing is visible.
//
//  Which is why the header counts HER VOICE rather than everything. A bigger
//  total including ragas would be flattery: she did not make the raga.
//
//  ---------------------------------------------------------------------------
//  ⚠️ GROUPED BY THE WEEK IT WAS MADE IN, WHICH IS STAMPED AT CREATION
//  ---------------------------------------------------------------------------
//  Not derived on read. A derived week would re-date every entry as the
//  pregnancy moved on, so the album would reshuffle itself between visits and
//  would have no meaning at all after the birth, when there is no current week.
//  See `GarbhJournalEntry.week`.
//
//  ⚠️ AND IT SURVIVES THE BIRTH. The spec's screen 09 turns this into the
//  newborn playlist, which is the bridge that keeps a mother in the app at the
//  moment she would otherwise leave for a baby tracker. That handover is not
//  built here, but nothing in this screen assumes a live pregnancy: it reads
//  stamped weeks and never asks the controller what week it is.
// =============================================================================

import 'package:flutter/material.dart';

import '../data/garbh_rebuild_data.dart';
import '../localization/app_language.dart';
import '../services/raga_audio_store.dart';
import '../theme/pv_fonts.dart';
import 'garbh_invite_screen.dart';

const _ink = Color(0xFF201C24); // V3 ink1
const _muted = Color(0xFF6F6878); // V3 ink3
const _ground = Color(0xFFF5F3F6); // V3 ground
const _accent = Color(0xFFB98A7E); // Samvad's warm rose - this is her voice

class GarbhJournalScreen extends StatelessWidget {
  const GarbhJournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = GarbhJournalStore.instance;
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final byWeek = store.byWeek;

        return Scaffold(
          backgroundColor: _ground,
          appBar: AppBar(
            backgroundColor: _ground,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            foregroundColor: _ink,
            title: Text('My Journal',
                style: pvFraunces(
                    fontSize: 18, fontWeight: FontWeight.w600, color: _ink)),
          ),
          body: SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 40),
              children: [
                _Header(store: store),
                const SizedBox(height: 24),

                if (byWeek.isEmpty)
                  // ⚠️ AN EMPTY ALBUM IS THE MOST IMPORTANT EMPTY STATE IN
                  // THIS SECTION, because it is the one a mother sees on day
                  // one, before she has any reason to believe the section is
                  // for anything. It has to say what this will BECOME, not
                  // that there is nothing here.
                  Container(
                    padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
                    decoration: BoxDecoration(
                      color: _accent.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Nothing here yet, and that is only today.',
                              style: pvFraunces(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  height: 1.3,
                                  color: _ink)),
                          const SizedBox(height: 10),
                          Text(
                              'Every time you read something aloud, every raga '
                              'you play, and every message your family records '
                              'lands here, filed under the week it happened. '
                              'By the time your baby arrives this is months of '
                              'your voice, kept.',
                              style: pvManrope(
                                  fontSize: 13.5, height: 1.6, color: _ink)),
                        ]),
                  )
                else
                  for (final entry in byWeek.entries) ...[
                    _WeekHeading(week: entry.key, count: entry.value.length),
                    const SizedBox(height: 10),
                    for (final e in entry.value) ...[
                      _EntryRow(entry: e),
                      const SizedBox(height: 8),
                    ],
                    const SizedBox(height: 22),
                  ],

                const SizedBox(height: 16),
                // ---- write a letter --------------------------------------
                //
                // ⚠️ `GarbhEntryKind.letter` HAD AN ICON AND NO WAY TO CREATE
                // ONE. The model, the grouping and the row rendering all
                // handled letters; nothing anywhere made one, so the type was
                // furniture.
                //
                // ⚠️ AND IT SITS HERE RATHER THAN ON THE DAILY CARD. A letter
                // is not a daily practice - it is the thing she writes on the
                // evening she has something to say, which is a moment she
                // arrives at by looking at the album, not by working through
                // today's list.
                Material(
                  color: _accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(18),
                  child: InkWell(
                    onTap: () => _writeLetter(context),
                    borderRadius: BorderRadius.circular(18),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 15, 14, 16),
                      child: Row(children: [
                        const Icon(Icons.edit_note_rounded,
                            size: 20, color: _accent),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Write a letter to your baby',
                                    style: pvManrope(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: _ink)),
                                const SizedBox(height: 3),
                                Text(
                                    'Something to read to them one day. It is '
                                    'kept under this week.',
                                    style: pvManrope(
                                        fontSize: 12,
                                        height: 1.4,
                                        color: _muted)),
                              ]),
                        ),
                        const Icon(Icons.chevron_right_rounded,
                            size: 19, color: _muted),
                      ]),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // ---- the family loop, from inside the album --------------
                //
                // ⚠️ HERE RATHER THAN ON THE DAILY CARD. The daily card is
                // about what she does today; this is about what the album
                // could hold, and it lands hardest looking at an album that
                // is already growing. It is also the growth loop, so it wants
                // to be seen by someone who has understood the value first.
                Material(
                  color: _accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(18),
                  child: InkWell(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        settings: const RouteSettings(name: 'garbh/invite'),
                        builder: (_) => const GarbhInviteScreen(),
                      ),
                    ),
                    borderRadius: BorderRadius.circular(18),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 15, 14, 16),
                      child: Row(children: [
                        const Icon(Icons.group_add_outlined,
                            size: 20, color: _accent),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Invite someone to record',
                                    style: pvManrope(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: _ink)),
                                const SizedBox(height: 3),
                                Text(
                                    'Papa, Dadi, Nani, or anyone else whose '
                                    'voice your baby should know.',
                                    style: pvManrope(
                                        fontSize: 12,
                                        height: 1.4,
                                        color: _muted)),
                              ]),
                        ),
                        const Icon(Icons.chevron_right_rounded,
                            size: 19, color: _muted),
                      ]),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // ⚠️ THE BIRTH HANDOVER, PROMISED HERE AND HONOURED BY THE
                // MODEL. Nothing in this screen asks the controller what week
                // it is - every entry carries the week it was stamped with -
                // so the album keeps working after the birth, when there is
                // no current week at all. That is what makes screen 09's
                // "becomes the newborn playlist" additive rather than a
                // rebuild.
                Text(
                    'This stays yours. It does not disappear after the birth: '
                    'these are the voices your newborn will already know, and '
                    'you can play the whole thing back whenever you want.',
                    style: pvManrope(fontSize: 12, height: 1.55, color: _muted)),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// A letter, written into the album under the current week.
///
/// ⚠️ A SHEET, NOT A SCREEN, AND THAT IS THE OPPOSITE CALL FROM THE PREGNANCY
/// JOURNAL COMPOSER. That one is a page because it holds a heading, a body,
/// three photos and a stamp. This holds one thing: what she wants to say. A
/// full page for a single field is ceremony, and ceremony is what stops a
/// person writing the short letter they actually had in them.
Future<void> _writeLetter(BuildContext context) async {
  final ctrl = TextEditingController();
  final week = _currentWeekForLetter();

  final text = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('A letter to your baby',
              style: pvFraunces(
                  fontSize: 19, fontWeight: FontWeight.w600, color: _ink)),
          const SizedBox(height: 6),
          Text('Kept under week $week, for them to read one day.',
              style: pvManrope(fontSize: 12.5, color: _muted)),
          const SizedBox(height: 16),
          TextField(
            controller: ctrl,
            autofocus: true,
            minLines: 5,
            maxLines: 10,
            textCapitalization: TextCapitalization.sentences,
            style: pvManrope(fontSize: 15, height: 1.6, color: _ink),
            decoration: InputDecoration(
              hintText: 'Whatever you want them to know.',
              hintStyle: pvManrope(fontSize: 14.5, color: _muted),
              border: InputBorder.none,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: _accent,
                  padding: const EdgeInsets.symmetric(vertical: 14)),
              onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
              child: Text('Keep it',
                  style: pvManrope(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
          ),
        ]),
      ),
    ),
  );

  ctrl.dispose();
  if (text == null || text.isEmpty) return;

  await GarbhJournalStore.instance.add(GarbhJournalEntry(
    id: 'letter_${DateTime.now().microsecondsSinceEpoch}',
    kind: GarbhEntryKind.letter,
    week: week,
    tsMs: DateTime.now().millisecondsSinceEpoch,
    // ⚠️ THE FIRST LINE IS THE TITLE, not "Letter". The album lists titles,
    // and twelve rows all reading "Letter" is an album she cannot navigate.
    title: LocalizedText(
        en: text.length > 60 ? '${text.substring(0, 60)}...' : text,
        hi: text.length > 60 ? '${text.substring(0, 60)}...' : text),
    text: text,
  ));
}

/// ⚠️ READ FROM THE MOST RECENT ENTRY, NOT FROM A CONTROLLER.
///
/// This screen deliberately takes no `PregnancyController` - it is the one
/// surface that must keep working after the birth, when there is no current
/// week at all. So a letter is filed against the same week as whatever she
/// last added, and falls back to 1 for an empty album. Threading a controller
/// in just for this would break the property that makes the birth handover
/// free.
int _currentWeekForLetter() {
  final e = GarbhJournalStore.instance.entries;
  return e.isEmpty ? 1 : e.first.week;
}

class _Header extends StatelessWidget {
  const _Header({required this.store});
  final GarbhJournalStore store;

  @override
  Widget build(BuildContext context) {
    final mins = (store.myVoiceSeconds / 60).floor();
    final secs = store.myVoiceSeconds % 60;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        color: _accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('YOUR VOICE, SO FAR',
            style: pvManrope(
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: _accent)),
        const SizedBox(height: 10),
        // ⚠️ THE NUMBER IS MINUTES OF HER VOICE, NOT A COUNT OF ACTIVITIES.
        // "12 practices done" is a habit metric and says nothing to a baby.
        // "48 minutes of your voice" is the artifact itself, measured.
        Text(
            store.myVoiceSeconds == 0
                ? 'Not yet recorded'
                : (mins > 0 ? '$mins min ${secs}s' : '${secs}s'),
            style: pvFraunces(
                fontSize: 30,
                fontWeight: FontWeight.w600,
                height: 1.1,
                color: _ink)),
        const SizedBox(height: 6),
        Text(
            [
              '${store.myVoiceCount} '
                  '${store.myVoiceCount == 1 ? 'recording' : 'recordings'}',
              if (store.familyCount > 0)
                '${store.familyCount} from family',
            ].join('  ·  '),
            style: pvManrope(fontSize: 12.5, color: _muted)),
      ]),
    );
  }
}

class _WeekHeading extends StatelessWidget {
  const _WeekHeading({required this.week, required this.count});
  final int week;
  final int count;

  @override
  Widget build(BuildContext context) => Row(children: [
        Text('WEEK $week',
            style: pvManrope(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: _ink)),
        const SizedBox(width: 10),
        Expanded(child: Container(height: 1, color: const Color(0x14000000))),
        const SizedBox(width: 10),
        Text('$count',
            style: pvManrope(
                fontSize: 11, fontWeight: FontWeight.w700, color: _muted)),
      ]);
}

/// One thing she made, playable where there is something to play.
///
/// ⚠️ THE PLAY ICON USED TO RENDER AND DO NOTHING. That is the defect this
/// section has now produced three times - a control that looks live and is
/// not - and it is the worst instance of it, because the album's entire
/// promise is that she can hear this again.
class _EntryRow extends StatelessWidget {
  const _EntryRow({required this.entry});
  final GarbhJournalEntry entry;

  IconData get _icon => switch (entry.kind) {
        GarbhEntryKind.myVoice => Icons.mic_none_rounded,
        GarbhEntryKind.familyVoice => Icons.groups_outlined,
        GarbhEntryKind.heard => Icons.music_note_outlined,
        GarbhEntryKind.letter => Icons.edit_note_rounded,
        GarbhEntryKind.photo => Icons.photo_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final path = entry.path;
    final audio = RagaAudioStore.instance;

    return AnimatedBuilder(
      animation: audio,
      builder: (context, _) {
        final playing = path != null && audio.isPlayingAsset(path);
        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            // ⚠️ NO TAP TARGET WHERE THERE IS NOTHING TO PLAY. A letter has no
            // audio; making the whole row tappable anyway would teach her that
            // taps sometimes do nothing, which is worse than a row that
            // plainly is not a button.
            onTap: path == null
                ? null
                : () => audio.toggle(path,
                    title: entry.title.en,
                    // Her own voice, and her family's, must not loop.
                    isFile: true,
                    loop: false),
            borderRadius: BorderRadius.circular(16),
            child: _body(playing),
          ),
        );
      },
    );
  }

  Widget _body(bool playing) {
    final lang = S.current;
    // ⚠️ THE RELATIONSHIP LABEL WINS OVER THE KIND LABEL. She chose the word
    // "Dadi"; showing "Family" instead would replace her word with our
    // category, on the one screen that is supposed to be hers.
    final tag = entry.relationship ?? entry.kind.label.of(lang);
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 13),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x14000000)),
      ),
      child: Row(children: [
        Icon(_icon, size: 19, color: _accent),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.title.of(lang),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: pvManrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                        color: _ink)),
                const SizedBox(height: 3),
                Text(
                    [
                      tag,
                      if (entry.seconds > 0) _dur(entry.seconds),
                    ].join('  ·  '),
                    style: pvManrope(fontSize: 11.5, color: _muted)),
              ]),
        ),
        if (entry.path != null)
          Icon(
              playing
                  ? Icons.pause_circle_outline_rounded
                  : Icons.play_circle_outline_rounded,
              size: 22,
              color: _accent),
      ]),
    );
  }

  static String _dur(int s) {
    final m = s ~/ 60;
    final r = s % 60;
    return m > 0 ? '$m min ${r}s' : '${r}s';
  }
}
