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
import '../theme/pv_fonts.dart';
import 'garbh_invite_screen.dart';

const _ink = Color(0xFF2E2A32);
const _muted = Color(0xFF8A8290);
const _ground = Color(0xFFFBF9F6);
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
    final lang = S.current;
    // ⚠️ THE RELATIONSHIP LABEL WINS OVER THE KIND LABEL. She chose the word
    // "Dadi"; showing "Family" instead would replace her word with our
    // category, on the one screen that is supposed to be hers.
    final tag = entry.relationship ?? entry.kind.label.of(lang);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 13),
      decoration: BoxDecoration(
        color: Colors.white,
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
          const Icon(Icons.play_circle_outline_rounded,
              size: 22, color: _accent),
      ]),
    );
  }

  static String _dur(int s) {
    final m = s ~/ 60;
    final r = s % 60;
    return m > 0 ? '$m min ${r}s' : '${r}s';
  }
}
