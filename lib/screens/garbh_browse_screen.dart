// =============================================================================
//  GarbhBrowseScreen — "see everything in this pillar", calmly
// -----------------------------------------------------------------------------
//  ⚠️ ONE SCREEN, FOUR CONFIGURATIONS — and that is a deliberate choice against
//  the obvious alternative.
//
//  Review asked for a "see all" under Mark Complete on Shravan, and then for
//  the same on Samvad, Vichara and Kriya. Four screens would have been quicker
//  to write and would have drifted the first time any one of them was touched,
//  which is the same failure `pp_chart_browser_screen.dart` was built to avoid
//  on the parenting side. So: one screen, a config per pillar, and adding a
//  fifth is a list of items rather than a file.
//
//  ---------------------------------------------------------------------------
//  ⚠️ IT HOLDS NO CONTENT OF ITS OWN
//  ---------------------------------------------------------------------------
//  Every item is read from `garbh_data.dart` at call time. A second copy of the
//  raga list here would go on saying "7 min" after the audio was re-cut, and
//  nothing would fail — the same reason the parenting chart browser reads its
//  section's cards through the registry rather than holding numbers.
//
//  ---------------------------------------------------------------------------
//  ⚠️ WHY IT IS BUILT THIS SPARELY, WHICH IS THE ACTUAL BRIEF
//  ---------------------------------------------------------------------------
//  Review: "listed in a very calming way so that user has enough to know which
//  to select on just seeing the preview of all in list."
//
//  Those are two requirements pulling against each other — enough information
//  to choose, without the density that makes a list feel like work — and the
//  resolution is what every decision below is answering to:
//
//    · ONE LINE OF PREVIEW PER ITEM, never two. The subtitle already exists in
//      the data and was written to be exactly this. Truncated to one line so
//      every row is the same height, because a ragged list of different-height
//      cards is what makes a screen feel busy more than any single element.
//    · NO CARDS, NO BORDERS, NO SHADOWS. Hairline dividers only. Ten bordered
//      cards read as ten decisions; ten rows read as one list.
//    · GROUPED WHERE THE GROUPING IS REAL. Shravan splits into ragas, nature
//      and guided because those are genuinely different things to want. Samvad
//      splits by trimester. Kriya and Vichara do not split, because inventing
//      a category to look organised is how a calm screen becomes a taxonomy.
//    · THE MINUTES ARE THE RIGHT-HAND COLUMN. "How long is this" is the second
//      question after "what is it", and putting it in a fixed column lets the
//      eye scan for a seven-minute gap without reading anything.
//    · NO PROGRESS, NO TICKS, NO STREAKS. This is a menu she is browsing, not
//      a syllabus she is behind on. Garbh Sanskar's whole tone depends on that
//      distinction.
// =============================================================================

import 'package:flutter/material.dart';

import '../data/garbh_data.dart';
import '../localization/app_language.dart';
import '../models/garbh_content.dart';
import '../data/garbh_rebuild_data.dart';
import '../services/raga_audio_store.dart';
import '../theme/pv_fonts.dart';
import '../services/shravan_library.dart';
import '../widgets/pv_feedback.dart' show PvPress, pvCommitFeedback;
import 'garbh/garbh_marks.dart' show garbhPracticeArt, shravanCoverThumb, shravanHueFor;

/// ⚠️ EVERY RAGA CURRENTLY PLAYS THE SAME BUNDLED DRONE.
///
/// There is one audio file in the app - `assets/audio/raga_drone.wav`, a
/// twelve-second tanpura loop - and ten named ragas pointing at it. Real
/// recordings are a content job that has not happened.
///
/// That matters here more than anywhere else, because tapping "Ocean Waves"
/// and hearing a tanpura is not a missing feature, it is the app telling her
/// something untrue. So the list SAYS SO in its intro rather than letting her
/// work it out - the same honesty the video placeholders carry with their
/// "coming soon" mark. Playable and labelled beats either silent or silently
/// wrong.
const String kGarbhRagaAsset = 'audio/raga_drone.wav';

//// One row in the list.
class GarbhBrowseItem {
  const GarbhBrowseItem({
    required this.title,
    this.subtitle,
    this.emoji,
    this.art,
    this.playKey,
    this.meta,
    this.onTap,
    this.pinId,
  });

  final String title;

  /// The one line of preview. See the header on why it is one and not two.
  final String? subtitle;

  /// Kept for revert (2026-10-15): the emoji the row used to lead with. It is
  /// no longer drawn; [art] is.
  final String? emoji;

  /// The row's drawn picture: a Shravan cover or a Kriya practice mark. Given
  /// the row's playing state, so a cover can show it is the one playing.
  final Widget Function(bool playing)? art;

  /// The audio source this row plays, so the row can say "playing" and the
  /// now-playing bar can find it. Null on rows that do not play.
  final String? playKey;

  /// The right-hand column — "7 min", "3 min read".
  final String? meta;

  /// ⚠️ OPTIONAL, BECAUSE ONLY SHRAVAN HAS SOMETHING TO PLAY. Samvad prompts
  /// and Vichara reads are text; giving every row a tap target would teach her
  /// that taps sometimes do nothing, which is worse than a row that plainly is
  /// not a button.
  final VoidCallback? onTap;

  /// A stable id for "add to my daily". Null on rows that cannot be pinned.
  final String? pinId;
}

/// A titled run of items. A single unnamed group renders with no heading at
/// all, which is what keeps Kriya and Vichara from growing a category they do
/// not have.
class GarbhBrowseGroup {
  const GarbhBrowseGroup({this.title, required this.items});
  final String? title;
  final List<GarbhBrowseItem> items;
}

// ⚠️ THE LIST, IN THE NEW UI, WITH A NOW-PLAYING BAR (2026-10-15, the Garbh
// pillars pass). From the Mobbin look at Calm, Me+ and Oura: each row leads
// with its picture, the one playing says so, and a bar at the foot carries
// what is playing (play / pause, close) and opens the full player. Leaving
// the list stops what it started: a sound she can no longer see is a sound
// she cannot find to stop (the "never lost" rule). The header is the round
// back every Garbh screen has. Kept for revert: the AppBar header and the
// emoji lead, in `_GarbhBrowseV1Note` below.
class GarbhBrowseScreen extends StatefulWidget {
  const GarbhBrowseScreen({
    super.key,
    required this.title,
    required this.intro,
    required this.accent,
    required this.groups,
    this.onOpenPlaying,
  });

  final String title;

  /// One sentence, at the top. Says what the list is FOR, because a list of
  /// ten names with no framing makes a mother wonder whether she is supposed
  /// to do all of them.
  final String intro;

  final Color accent;
  final List<GarbhBrowseGroup> groups;

  /// Opens the full player for the row whose [GarbhBrowseItem.playKey] is
  /// playing. Null hides the bar's "open" (the bar still plays and stops).
  final void Function(String playKey)? onOpenPlaying;

  @override
  State<GarbhBrowseScreen> createState() => _GarbhBrowseScreenState();
}

class _GarbhBrowseScreenState extends State<GarbhBrowseScreen> {
  Set<String> get _keys => {
        for (final g in widget.groups)
          for (final i in g.items)
            if (i.playKey != null) i.playKey!,
      };

  @override
  void dispose() {
    final store = RagaAudioStore.instance;
    final a = store.asset;
    if (a != null && _keys.contains(a)) store.stop();
    super.dispose();
  }

  GarbhBrowseItem? _itemFor(String key) {
    for (final g in widget.groups) {
      for (final i in g.items) {
        if (i.playKey == key) return i;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // V3 baseline values - see the note at the top of garbh_screen.dart for
    // why this section carries the values rather than a live palette
    // reference.
    const ground = Color(0xFFFFFFFF); // V3 ground — white since 2026-09-17; was 0xFFF5F3F6
    const ink = Color(0xFF201C24); // V3 ink1
    const muted = Color(0xFF2F2C30); // V3 ink3
    final top = MediaQuery.paddingOf(context).top;
    final bottom = MediaQuery.paddingOf(context).bottom;
    final store = RagaAudioStore.instance;

    return Scaffold(
      backgroundColor: ground,
      body: AnimatedBuilder(
        animation: store,
        builder: (context, _) {
          final playingKey = store.asset;
          final current = playingKey == null ? null : _itemFor(playingKey);
          return Stack(children: [
            ListView(
              padding: EdgeInsets.fromLTRB(22, top + 8, 22, 40 + (current != null ? 84 : 0)),
              children: [
                Row(children: [
                  PvPress(
                    child: GestureDetector(
                      key: const ValueKey('browse_back'),
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Navigator.of(context).maybePop(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0x1F000000)),
                        ),
                        child: const Icon(Icons.arrow_back_rounded, size: 20, color: ink),
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: 18),
                Text(widget.title,
                    style: pvFraunces(fontSize: 28, fontWeight: FontWeight.w600, height: 1.1, color: ink)),
                const SizedBox(height: 10),
                Text(widget.intro,
                    style: pvManrope(fontSize: 13.5, height: 1.6, color: muted)),
                const SizedBox(height: 26),
                for (final g in widget.groups) ...[
                  if (g.title != null) ...[
                    Text(g.title!.toUpperCase(),
                        style: pvManrope(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.3,
                            color: muted)),
                    const SizedBox(height: 8),
                  ],
                  for (int i = 0; i < g.items.length; i++) ...[
                    _Row(
                        item: g.items[i],
                        ink: ink,
                        muted: muted,
                        playing: g.items[i].playKey != null &&
                            store.isPlayingAsset(g.items[i].playKey!)),
                    if (i != g.items.length - 1)
                      const Divider(height: 1, thickness: 1, color: Color(0x14000000)),
                  ],
                  if (g != widget.groups.last) const SizedBox(height: 30),
                ],
                const SizedBox(height: 30),
                // ⚠️ THE CLOSING LINE IS NOT DECORATION. A list of everything
                // available is exactly where a practice starts to feel like a
                // backlog, and this pillar's whole value is that it does not.
                Text(
                    'Nothing here is a list to finish. Pick whatever suits today, '
                    'and leave the rest where it is.',
                    style: pvManrope(
                        fontSize: 12.5,
                        height: 1.6,
                        fontStyle: FontStyle.italic,
                        color: muted)),
              ],
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              left: 14,
              right: 14,
              bottom: current != null ? 14 + bottom : -100,
              child: current == null
                  ? const SizedBox(height: 68)
                  : _NowPlayingBar(
                      item: current,
                      playing: store.isPlaying,
                      onToggle: () {
                        pvCommitFeedback();
                        current.onTap?.call();
                      },
                      onClose: () {
                        pvCommitFeedback();
                        store.stop();
                      },
                      onOpen: widget.onOpenPlaying == null
                          ? null
                          : () => widget.onOpenPlaying!(playingKey!),
                    ),
            ),
          ]);
        },
      ),
    );
  }
}

/// What is playing, pinned at the foot of the list.
class _NowPlayingBar extends StatelessWidget {
  const _NowPlayingBar({
    required this.item,
    required this.playing,
    required this.onToggle,
    required this.onClose,
    required this.onOpen,
  });
  final GarbhBrowseItem item;
  final bool playing;
  final VoidCallback onToggle;
  final VoidCallback onClose;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF201C24);
    return Container(
      key: const ValueKey('shravan_now_playing'),
      height: 68,
      padding: const EdgeInsets.fromLTRB(10, 0, 6, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x1F000000)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 18,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Row(children: [
        Expanded(
          child: PvPress(
            child: GestureDetector(
              key: const ValueKey('now_playing_open'),
              behavior: HitTestBehavior.opaque,
              onTap: onOpen,
              child: Row(children: [
                if (item.art != null) item.art!(playing),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: pvManrope(
                                fontSize: 14, fontWeight: FontWeight.w700, color: ink)),
                        const SizedBox(height: 2),
                        Text(playing ? 'Playing' : 'Paused',
                            style: pvManrope(fontSize: 12, color: const Color(0xFF6B6570))),
                      ]),
                ),
              ]),
            ),
          ),
        ),
        Semantics(
          button: true,
          label: playing ? 'Pause' : 'Play',
          child: PvPress(
            child: GestureDetector(
              key: const ValueKey('now_playing_toggle'),
              behavior: HitTestBehavior.opaque,
              onTap: onToggle,
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(color: ink, shape: BoxShape.circle),
                child: Icon(playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white, size: 26),
              ),
            ),
          ),
        ),
        Semantics(
          button: true,
          label: 'Stop',
          child: PvPress(
            child: GestureDetector(
              key: const ValueKey('now_playing_close'),
              behavior: HitTestBehavior.opaque,
              onTap: onClose,
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Icon(Icons.close_rounded, size: 22, color: Color(0xFF6B6570)),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.item,
    required this.ink,
    required this.muted,
    this.playing = false,
  });

  final GarbhBrowseItem item;
  final Color ink;
  final Color muted;
  final bool playing;

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (item.art != null) ...[
            item.art!(playing),
            const SizedBox(width: 14),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    style: pvFraunces(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                        color: ink)),
                if (item.subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(item.subtitle!,
                      // ⚠️ ONE LINE, ELLIPSISED. Every row the same height
                      // is most of what makes this list read as calm.
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: pvManrope(
                          fontSize: 12.5, height: 1.4, color: muted)),
                ],
                if (playing) ...[
                  const SizedBox(height: 3),
                  Text('Playing',
                      style: pvManrope(
                          fontSize: 11.5, fontWeight: FontWeight.w800, color: ink)),
                ],
              ],
            ),
          ),
          // ⚠️ "ADD TO MY DAILY", AND IT IS A QUIET OUTLINE RATHER THAN A
          // BUTTON. Every row in a ten-row list carrying a solid control
          // turns a calm list into a form. An outlined pin that fills when
          // it is on says the same thing and disappears when it is off.
          if (item.pinId != null) ...[
            const SizedBox(width: 10),
            _PinButton(id: item.pinId!),
          ],
          if (item.meta != null) ...[
            const SizedBox(width: 12),
            Text(item.meta!,
                style: pvManrope(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: muted)),
          ],
        ],
      ),
    );
    if (item.onTap == null) return row;
    // Kept for revert: an InkWell ripple around the row.
    return PvPress(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          pvCommitFeedback();
          item.onTap!();
        },
        child: row,
      ),
    );
  }
}

// Pin a library item to her own daily.
class _PinButton extends StatelessWidget {
  const _PinButton({required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    final store = GarbhJournalStore.instance;
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final on = store.isPinned(id);
        return Semantics(
          label: on ? 'Remove from my daily' : 'Add to my daily',
          button: true,
          child: PvPress(child: GestureDetector(
            onTap: () => store.togglePinned(id),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              child: Icon(
                  on ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                  size: 17,
                  color: on ? const Color(0xFF2F2C30) : const Color(0xFF2F2C30)),
            ),
          )),
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
//  The four configurations
// -----------------------------------------------------------------------------
//  ⚠️ EACH IS A FUNCTION, NOT A CONST. They read `garbh_data.dart` at call
//  time, so adding a raga shows up here with no second edit — which is the
//  whole reason this screen holds no content.

GarbhBrowseScreen shravanBrowse(AppLanguage lang, Color accent,
    {void Function(GarbhAudio audio)? onOpen}) {
  final lib = ShravanLibrary.instance;
  lib.init();

  /// What a row plays: the real recording (cached file, else the stream)
  /// where the manifest has one, the bundled sample tone where it does not.
  ///
  /// ⚠️ THE ROWS USED TO PLAY THE DRONE FOR EVERY RAGA (2026-10-15 fix). They
  /// called `toggle(a.asset ?? kGarbhRagaAsset)`, and `a.asset` is null on all
  /// ten, so the list played the same sample tone while the raga's own page
  /// played its recording: two answers to "play this raga" from one app. The
  /// list now asks `ShravanLibrary` exactly as the player does.
  ({String key, bool isFile, bool isUrl, bool loop}) source(GarbhAudio a) {
    final p = lib.playableFor(a.id);
    if (p == null) return (key: kGarbhRagaAsset, isFile: false, isUrl: false, loop: true);
    return (key: p.source, isFile: p.isFile, isUrl: !p.isFile, loop: false);
  }

  final byKey = <String, GarbhAudio>{};
  List<GarbhBrowseItem> of(GarbhKind k) => [
        for (final a in kShravan.where((x) => x.kind == k))
          () {
            final guided = a.kind == GarbhKind.guided;
            final src = guided ? null : source(a);
            if (src != null) byKey[src.key] = a;
            return GarbhBrowseItem(
              title: a.title.of(lang),
              subtitle: lib.trackFor(a.id)?.attribution ?? a.subtitle.of(lang),
              art: (playing) => shravanCoverThumb(shravanHueFor(a.id), playing: playing),
              playKey: src?.key,
              meta: '${a.minutes} min',
              // ⚠️ TAPPING PLAYS IT, WHICH MAKES THIS LIST A CHOICE RATHER THAN
              // A CATALOGUE. Review: "if we are letting her see all ragas we
              // might as well allow her to play." The guided track is a
              // narrated session, not a song, so it opens its own page.
              onTap: guided
                  ? (onOpen == null ? null : () => onOpen(a))
                  : () => RagaAudioStore.instance.toggle(src!.key,
                      title: a.title.of(lang),
                      isFile: src.isFile,
                      isUrl: src.isUrl,
                      loop: src.loop),
              pinId: 'shravan_${a.id}',
            );
          }(),
      ];

  // ⚠️ GROUPED BY KIND BECAUSE THE KINDS ARE GENUINELY DIFFERENT WANTS. A
  // mother reaching for rain sounds and one reaching for a guided body scan
  // are not making the same choice, and one flat list of ten makes her read
  // all ten to discover that.
  final groups = <GarbhBrowseGroup>[
    if (of(GarbhKind.raga).isNotEmpty)
      GarbhBrowseGroup(
          title: lang.isHindi ? 'राग' : 'Ragas', items: of(GarbhKind.raga)),
    if (of(GarbhKind.nature).isNotEmpty)
      GarbhBrowseGroup(
          title: lang.isHindi ? 'प्रकृति की ध्वनियाँ' : 'Nature sounds',
          items: of(GarbhKind.nature)),
    if (of(GarbhKind.guided).isNotEmpty)
      GarbhBrowseGroup(
          title: lang.isHindi ? 'निर्देशित' : 'Guided',
          items: of(GarbhKind.guided)),
  ];

  // The sample-tone caveat shows only while some raga has no recording.
  final allReal = kShravan
      .where((a) => a.kind != GarbhKind.guided)
      .every((a) => a.hasRealAudio || lib.trackFor(a.id) != null);

  return GarbhBrowseScreen(
    title: lang.isHindi ? 'सभी राग' : 'All ragas',
    intro: lang.isHindi
        ? 'हर दिन एक अपने-आप चुना जाता है। पूरी सूची यहाँ है — जो आज के मन से मेल '
            'खाए, वही सुनिए।'
        : 'One is chosen for you each day. Here is everything there is, so you '
            'can pick whatever matches today instead. Tap one to play it.'
            // ⚠️ THE CAVEAT DISAPPEARS ON ITS OWN once every raga has a real
            // file. Nobody has to remember to delete it, which is the only
            // reason an honesty note like this survives contact with a
            // content drop.
            '${allReal ? '' : ' Some still play the same sample tone; their '
                'recordings are on their way.'}',
    accent: accent,
    groups: groups,
    onOpenPlaying: onOpen == null
        ? null
        : (key) {
            final a = byKey[key];
            if (a != null) onOpen(a);
          },
  );
}

GarbhBrowseScreen vicharaBrowse(AppLanguage lang, Color accent) =>
    GarbhBrowseScreen(
      title: lang.isHindi ? 'सभी विचार' : 'All reflections',
      intro: lang.isHindi
          ? 'छोटे-छोटे पाठ, हर एक तीन मिनट के आसपास। कोई क्रम नहीं है — जो आज पढ़ने का मन हो, वही पढ़िए।'
          : 'Short reads, about three minutes each. There is no order to them '
              '— read whichever one you feel like today.',
      accent: accent,
      // No grouping: eight reflections do not need a taxonomy, and the theme
      // is already the first thing on each row.
      groups: [
        GarbhBrowseGroup(items: [
          for (final s in kVichara)
            GarbhBrowseItem(
              title: s.title.of(lang),
              subtitle: s.blurb.of(lang),
              meta: '${s.minutes} min',
              pinId: 'vichara_${s.id}',
            ),
        ]),
      ],
    );

GarbhBrowseScreen samvadBrowse(AppLanguage lang, Color accent) =>
    GarbhBrowseScreen(
      title: lang.isHindi ? 'सभी संवाद' : 'All things to say',
      intro: lang.isHindi
          ? 'शिशु से कहने के लिए शब्द, तिमाही के हिसाब से। ऊँची आवाज़ में पढ़िए, या बस मन में।'
          : 'Words to say to your baby, gathered by trimester. Read one aloud, '
              'or just to yourself.',
      accent: accent,
      // ⚠️ GROUPED BY TRIMESTER because the prompts genuinely differ by it —
      // and shown ALL AT ONCE rather than filtered to hers. This is the browse
      // screen; the daily view is where personalisation belongs. Someone at 12
      // weeks reading what she will say at 30 is the point of a list like this.
      groups: [
        GarbhBrowseGroup(
          title: lang.isHindi ? 'पहली तिमाही' : 'First trimester',
          items: [
            for (final p in kSamvadT1)
              GarbhBrowseItem(
                  title: p.text.of(lang), pinId: 'samvad_${p.id}'),
          ],
        ),
        GarbhBrowseGroup(
          title: lang.isHindi ? 'दूसरी तिमाही' : 'Second trimester',
          items: [
            for (final p in kSamvadT2)
              GarbhBrowseItem(
                  title: p.text.of(lang), pinId: 'samvad_${p.id}'),
          ],
        ),
        GarbhBrowseGroup(
          title: lang.isHindi ? 'तीसरी तिमाही' : 'Third trimester',
          items: [
            for (final p in kSamvadT3)
              GarbhBrowseItem(
                  title: p.text.of(lang), pinId: 'samvad_${p.id}'),
          ],
        ),
      ],
    );

GarbhBrowseScreen kriyaBrowse(AppLanguage lang, Color accent) =>
    GarbhBrowseScreen(
      title: lang.isHindi ? 'सभी अभ्यास' : 'All practices',
      intro: lang.isHindi
          ? 'साँस के छोटे अभ्यास, हर एक कुछ ही मिनट का। किसी भी दिन, कोई भी चुन सकती हैं।'
          : 'Short breathing practices, a few minutes each. Any of them, any '
              'day — there is no sequence to keep to.',
      accent: accent,
      groups: [
        GarbhBrowseGroup(items: [
          for (final k in kKriya)
            GarbhBrowseItem(
              title: k.title.of(lang),
              subtitle: k.blurb.of(lang),
              emoji: k.emoji,
              art: (_) => garbhPracticeArt(k.id, size: 44),
              meta: '${k.minutes} min',
              pinId: 'kriya_${k.id}',
            ),
        ]),
      ],
    );
