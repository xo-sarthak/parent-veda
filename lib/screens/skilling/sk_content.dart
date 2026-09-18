// =============================================================================
//  SkBlock / SkPage / SkActivity / SkContentPage — skilling's content model,
//  built once, and the one renderer that draws it
// -----------------------------------------------------------------------------
//  ⚠️ THE FOURTH COPY OF THE BLOCK MODEL, AND WHY IT IS A COPY. Parenting's
//  `pp_content.dart` is the pattern: a page is DATA (a title and a list of
//  blocks), one renderer decides layout, so eleven sections cannot drift and
//  every format rule is a test over data. That file is open in another
//  terminal and welded to `ChildProfileStore` (its tables hoist "her row" by
//  the baby's months). Importing it from a stage that reads a different
//  child's age from a different store would make a skilling page break when
//  a parenting constructor changes. So: same shape, own file, shared only
//  what is stage-neutral (`V2Palette`, `pvFraunces`, the video placeholder).
//
//  ⚠️ WHAT IS SKILLING'S OWN, AND IT IS THE WHOLE POINT OF THE STAGE:
//
//  * **The page speaks to the CHILD.** Bigger type, bigger targets, fewer
//    words, and a speaker at the top that reads the page aloud through the
//    device voice (`BabyVoiceService`, the app's one TTS seam). "Text-heavy
//    is a fail state" is the brief's line; the renderer's sizes are the
//    brief's answer, decided here once rather than per page.
//  * **`SkActivity` is a first-class thing, not a page with a format tag.**
//    The task PDFs ("Task N of 36") name its fields exactly — bracket, band,
//    skillPurpose, title, oneLine, materials, steps, theThinking,
//    whatYouPractised — and say "map to the real model; if a field is
//    missing STOP". The model carries every one, so a fill is a transcription.
//  * **A parent-only line on a child page is a block with a gate.**
//    `SkGrownUpNote` renders as a "For the grown-up" button; the text is
//    behind `skAskGrownUp`. The activity's `theThinking` is the same idea.
//  * **A link out of the child's space is gated too.** `SkLink.url` opens
//    the browser only after the grown-up check; `SkLink.surfaceId` for a
//    parent surface likewise. The child never leaves the learning space by
//    accident.
//  * **No scoring anywhere in this file.** No fraction, no count, no "N of
//    M steps done". The activity screen's three buttons write a WORD to the
//    keepsake and show the honest end line. `test/sk_doors_sanity_test.dart`
//    scans this folder for scoring identifiers.
//
//  ⚠️ THE BLOCK LIST IS CLOSED AND SHORT. Every type appears in a skilling
//  brief by name (intro, article, steps, cards, video slot, link, grown-up
//  note). Carousels, tables, charts and interactives are NOT here — no
//  skilling brief has asked for one, and a model that can express more shapes
//  than the product has is a bug surface. Add a type when a brief names it.
//
//  ENGLISH ONLY. Plain `String`, per the standing rule.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../localization/app_language.dart';
import '../../models/breath_pattern.dart';
import '../../services/baby_voice_service.dart';
import '../../theme/pv_fonts.dart';
import '../../widgets/breathing_circle.dart';
import '../../widgets/pv_placeholders.dart';
import '../v2/v2_palette.dart';
import 'sk_grown_up_gate.dart';
import 'sk_safety.dart';

// =============================================================================
//  THE BLOCKS
// =============================================================================

abstract class SkBlock {
  const SkBlock();
}

/// The warm opening line. Its own type so a test can assert a page opens
/// with one.
class SkIntro extends SkBlock {
  const SkIntro(this.text);
  final String text;
}

/// Prose, in paragraphs. A list, so the paragraph is the unit.
class SkArticle extends SkBlock {
  const SkArticle(this.paragraphs, {this.heading});
  final String? heading;
  final List<String> paragraphs;
}

/// An ordered sequence she does. Numbered: order is the information — and
/// on a coding door, order is the lesson.
class SkSteps extends SkBlock {
  const SkSteps(this.steps, {this.heading});
  final String? heading;
  final List<SkStep> steps;
}

class SkStep {
  const SkStep(this.title, [this.detail]);
  final String title;
  final String? detail;
}

/// An unordered set, each a title and a line.
class SkCards extends SkBlock {
  const SkCards(this.cards, {this.heading, this.hue = 186});
  final String? heading;
  final List<SkCard> cards;
  final double hue;
}

class SkCard {
  const SkCard(this.title, this.line);
  final String title;
  final String line;
}

/// A film the door will have. Renders as the real 16:9 slot, the way an
/// unshot video renders everywhere else in the app. `slotId` is the wiring,
/// written down at the moment the slot is declared.
class SkVideoSlot extends SkBlock {
  const SkVideoSlot({
    required this.title,
    required this.slotId,
    this.subtitle,
    this.minutes,
    this.hue = 186,
  });
  final String title;
  final String? subtitle;
  final String? minutes;
  final String slotId;
  final double hue;
}

/// A link: to a sibling page in the same door (`pageId`), to a surface
/// (`surfaceId` — `sk_page/<door>/<page>` is how one door windows into
/// another, the parenting `pp_page/` idea), or out to the web (`url`).
///
/// ⚠️ `url` AND A PARENT SURFACE ARE GATED. The renderer asks the grown-up
/// check before either opens. `grownUp: true` forces the gate on a surface
/// link that leads somewhere a child should not reach alone.
class SkLink extends SkBlock {
  const SkLink(
    this.label, {
    this.blurb,
    this.pageId,
    this.surfaceId,
    this.url,
    this.grownUp = false,
  });
  final String label;
  final String? blurb;
  final String? pageId;
  final String? surfaceId;
  final String? url;
  final bool grownUp;

  /// Honestly not built yet: renders as such, never as a dead tap.
  bool get isDead => pageId == null && surfaceId == null && url == null;
}

/// The steady-your-nerves breath: the ONE breathing circle the app has
/// (`lib/widgets/breathing_circle.dart`, stage-neutral), handed a pattern
/// and its own clock. The Confidence brief: "the quick calming breath
/// belongs to Stillness, which itself reuses the breathing-circle the app
/// already has. Confidence references that breath for the moment before
/// you speak, it does not build its own." Added 2026-09-16 for the
/// Confidence fills to use; the block is the reference, not a fourth circle.
class SkBreath extends SkBlock {
  const SkBreath({
    this.heading = 'Steady your nerves',
    this.line,
    this.pattern = kSkSteadyBreath,
  });
  final String heading;

  /// One line under the circle — "Butterflies are normal. Breathe, then go."
  final String? line;
  final BreathPattern pattern;
}

/// In for three, out for five — the long out-breath does the work. The
/// parenting balloon breath's numbers, restated here rather than imported
/// from the parenting shell.
const BreathPattern kSkSteadyBreath = BreathPattern([
  BreathStep('Breathe in', 3, BreathKind.expand),
  BreathStep('Let it out slowly', 5, BreathKind.contract),
]);

/// One paragraph for the parent, on a child's page, behind the gate. The
/// brief: "the parent note explains, in plain words with no hype, why that
/// is a real thinking skill worth building."
class SkGrownUpNote extends SkBlock {
  const SkGrownUpNote(this.text, {this.heading = 'For the grown-up'});
  final String heading;
  final String text;
}

// =============================================================================
//  A PAGE
// =============================================================================

class SkPage {
  const SkPage({
    required this.id,
    required this.title,
    required this.blocks,
    this.subtitle,
    this.bands = const [],
    this.set,
    this.format,
    this.toolSurfaceId,
    this.comingSoon = false,
    this.kidVoice = true,
  });

  /// Stable slug — routing, the keepsake, the owed ledger. Never the title.
  final String id;
  final String title;
  final String? subtitle;
  final List<SkBlock> blocks;

  /// `kSkBands` ids this page is for. Empty means every band.
  final List<String> bands;

  /// The lesson set this page belongs to (`SkLessonSet.id`) — Coding's
  /// unplugged / blocks / projects / ai. The door's Lessons tab draws one
  /// rail per set in her band; the AI tab draws the `ai` set.
  final String? set;

  /// The brief's badge word, verbatim, for the chip: Lesson, Article, Video.
  final String? format;

  /// A page that IS a tool: its card opens the surface, blocks stay empty.
  final String? toolSurfaceId;

  /// A card that holds its place and does not tap. Logged in
  /// `docs/DOOR-CONTENT-OWED.md`; the sanity test fails otherwise.
  final bool comingSoon;

  /// Child-facing (bigger type, the speaker) or parent-facing (the note).
  final bool kidVoice;

  bool inBand(String band) => bands.isEmpty || bands.contains(band);

  /// Everything the speaker reads, in order.
  String get spokenText {
    final buf = StringBuffer(title);
    for (final b in blocks) {
      if (b is SkIntro) buf.write('. ${b.text}');
      if (b is SkArticle) {
        if (b.heading != null) buf.write('. ${b.heading}');
        for (final p in b.paragraphs) {
          buf.write('. $p');
        }
      }
      if (b is SkSteps) {
        for (final (i, s) in b.steps.indexed) {
          buf.write('. Step ${i + 1}. ${s.title}');
          if (s.detail != null) buf.write('. ${s.detail}');
        }
      }
      if (b is SkCards) {
        for (final c in b.cards) {
          buf.write('. ${c.title}. ${c.line}');
        }
      }
    }
    return buf.toString();
  }
}

// =============================================================================
//  AN ACTIVITY — the heart of every skill door
// =============================================================================

/// One activity, in the exact field shape the task PDFs write.
///
/// ⚠️ `skillPurpose` IS A STRING, NOT AN ENUM. Coding's six are sequencing,
/// pattern, debugging, decomposition, logic, persistence; Communication's
/// six are clarity, listening, describing, storytelling, the right word,
/// putting your point. An enum shared across doors would either be a union
/// of seventy-two or a switch nobody reads in full. The door declares its
/// own six as `SkSkillPurpose`s and the test holds that every activity
/// carries one of them.
class SkActivity {
  const SkActivity({
    required this.id,
    required this.band,
    required this.skillPurpose,
    required this.title,
    this.oneLine = '',
    this.materials = '',
    this.steps = const [],
    this.theThinking = '',
    this.whatYouPractised = '',
    this.tool,
    this.multiSession = false,
    this.withGrownUp = false,
    this.offersRecording = false,
    this.breathPageId,
    this.comingSoon = false,
  });

  final String id;

  /// `kSkBands` id — '6-8', '8-11', '11-14'.
  final String band;

  /// One of the door's `SkSkillPurpose.id`s.
  final String skillPurpose;

  /// Kid-facing.
  final String title;

  /// One warm line: what we will do.
  final String oneLine;

  /// "Nothing", or the household things, plus the no-supplies fallback.
  final String materials;

  /// Numbered, concrete, short.
  final List<String> steps;

  /// One line for the parent — why this is the skill. Behind the gate.
  final String theThinking;

  /// The honest kid-voice end note. Never a grade.
  final String whatYouPractised;

  /// The free tool a band uses (Scratch, ScratchJr…) — the 8 to 11 and
  /// 11 to 14 task PDFs' field. Null for an unplugged activity.
  final String? tool;

  /// A project that spans more than one sitting (11 to 14). A flag on the
  /// content only; no resume marker is kept about the child. See the
  /// review file for that open call.
  final bool multiSession;

  /// The 11 to 14 task's rule: "AI-literacy projects are marked 'with a
  /// grown-up'". A chip on the card and the screen. Added at the fill
  /// (2026-09-14) — the tool string carried the words, but a mark derived
  /// from prose is a mark that vanishes when the prose is edited.
  final bool withGrownUp;

  /// The Communication tasks' field: "the optional 'save your story' step;
  /// true for Tell Me What Happened, Once Upon a Time" — the record row
  /// shows on THIS activity, on a door that keeps her voice, when a parent
  /// has turned recording on. False everywhere else. Added at the fill
  /// (2026-09-15); the tasks said STOP and list, and this is the field.
  final bool offersRecording;

  /// The Confidence tasks' "(Uses the app's breathing circle.)" — three
  /// steadying-nerves activities, one per band, open the circle mid-step.
  /// The id of the door's breath page (`cf_breath`); the activity screen
  /// draws one row that opens it. Added at the fill (2026-09-17): the tasks
  /// said STOP and list a missing field, and this is the field. A page id,
  /// not a bool, so the circle stays the one page and never a second
  /// rendering.
  final String? breathPageId;

  /// The scaffold state: a real card at full size, "Coming soon", no tap.
  final bool comingSoon;

  String get spokenText {
    final buf = StringBuffer('$title. $oneLine');
    if (materials.isNotEmpty) buf.write('. You need: $materials');
    for (final (i, s) in steps.indexed) {
      buf.write('. Step ${i + 1}. $s');
    }
    return buf.toString();
  }
}

/// One of a door's six real thinking skills.
class SkSkillPurpose {
  const SkSkillPurpose({
    required this.id,
    required this.label,
    required this.kidLine,
  });

  /// The tag the task PDFs write: 'sequencing'.
  final String id;

  /// The rail heading, in the child's words: "Putting steps in order".
  final String label;

  /// One quiet line under it — what the skill is, for her.
  final String kidLine;
}

// =============================================================================
//  THE ONE RENDERER
// =============================================================================

/// The speaker. One per page, top right; it reads the page's `spokenText`
/// through the device voice. The app's TTS seam already handles a missing
/// voice pack and the per-scope mute; this widget only asks.
class SkReadAloud extends StatelessWidget {
  const SkReadAloud({super.key, required this.text, required this.cardKey});
  final String text;
  final String cardKey;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: BabyVoiceService.instance,
        builder: (context, _) {
          final p = V2PaletteStore.instance.current;
          final v = BabyVoiceService.instance;
          final playing = v.playingKey == cardKey;
          return Material(
            color: playing ? p.action : p.surface,
            shape: CircleBorder(side: BorderSide(color: p.line)),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => playing
                  ? v.stop()
                  : v.speak(text,
                      cardKey: cardKey, lang: AppLanguage.english),
              child: SizedBox(
                // ⚠️ 56, the brief's "big tap targets". Every control on a
                // child screen is at least this.
                width: kSkTap,
                height: kSkTap,
                child: Icon(
                    playing
                        ? Icons.stop_rounded
                        : Icons.volume_up_outlined,
                    size: 24,
                    color: playing ? Colors.white : p.ink1),
              ),
            ),
          );
        },
      );
}

/// The child-screen tap target. The brief says big; this is the number.
const double kSkTap = 56;

/// The child-screen type sizes, in one place.
///
/// ⚠️ THE "MIDDLE" SETTING, 2026-09-16. Built at 30 / 19 / 17 (the brief's
/// "text-heavy is a fail state" taken literally) and seen on a 6.4" phone
/// as oversized rather than child-sized ("absurdly big"). The app's normal
/// sizes are 26 / 14.5 / 13.5. These sit between: a child page still reads
/// larger than a parent page, and the 56pt targets are untouched. Change
/// them here and every child screen moves.
const double kSkTitleSize = 27;
const double kSkLeadSize = 17;
const double kSkBodySize = 16;
const double kSkHeadingSize = 20;
const double kSkButtonSize = 16;

/// Renders an `SkPage`. The only place skilling page layout is decided.
class SkContentPage extends StatelessWidget {
  const SkContentPage({
    super.key,
    required this.page,
    this.doorId = '',
    this.onSurface,
    this.onPage,
  });

  final SkPage page;
  final String doorId;
  final void Function(BuildContext context, String surfaceId)? onSurface;
  final void Function(BuildContext context, String pageId)? onPage;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: V2PaletteStore.instance,
        builder: (context, _) =>
            _scaffold(context, V2PaletteStore.instance.current),
      );

  Widget _scaffold(BuildContext context, V2Palette p) {
    final kid = page.kidVoice;
    return Scaffold(
      backgroundColor: p.ground,
      // A child page on a door with an off-ramp carries it; a parent page
      // (kidVoice false) does not — the parent's route to help is the note.
      bottomNavigationBar: kid ? skSafetyBarFor(doorId) : null,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 48),
          children: [
            Row(children: [
              skBack(context, p),
              const Spacer(),
              SkReadAloud(text: page.spokenText, cardKey: 'sk/$doorId/${page.id}'),
            ]),
            const SizedBox(height: 18),
            Text(page.title,
                style: pvFraunces(
                    fontSize: kid ? kSkTitleSize : 26,
                    fontWeight: FontWeight.w600,
                    height: 1.18,
                    color: p.ink1)),
            if (page.subtitle != null) ...[
              const SizedBox(height: 8),
              Text(page.subtitle!,
                  style: pvManrope(
                      fontSize: kid ? kSkLeadSize - 1 : 14.5,
                      fontWeight: FontWeight.w500,
                      height: 1.55,
                      color: p.ink2)),
            ],
            const SizedBox(height: 22),
            for (final b in page.blocks) ...[
              SkBlockView(
                  block: b,
                  kidVoice: kid,
                  onSurface: onSurface,
                  onPage: onPage),
              SizedBox(height: _gapAfter(b)),
            ],
          ],
        ),
      ),
    );
  }

  double _gapAfter(SkBlock b) => switch (b) {
        SkIntro() => 24,
        SkLink() => 10,
        _ => 26,
      };
}

/// The back control, V3's hairline circle.
///
/// ⚠️ 44, NOT THE 56 TAP SIZE, AND ALWAYS INSIDE A ROW. At 56 in a bare
/// `ListView` it stretched to the cross axis and drew centred — "such a
/// big button at top centre" on a phone (2026-09-16). A back control is a
/// control the child already knows from every screen; it does not need
/// the activity buttons' size, and it must sit where every other back
/// sits. Callers wrap it in a `Row` so the list cannot centre it.
Widget skBack(BuildContext context, V2Palette p) => GestureDetector(
      onTap: () => Navigator.of(context).maybePop(),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: p.line),
        ),
        child: Icon(Icons.arrow_back_rounded, size: 22, color: p.ink1),
      ),
    );

/// One block, rendered the way the page would render it.
class SkBlockView extends StatelessWidget {
  const SkBlockView({
    super.key,
    required this.block,
    this.kidVoice = true,
    this.onSurface,
    this.onPage,
  });

  final SkBlock block;
  final bool kidVoice;
  final void Function(BuildContext context, String surfaceId)? onSurface;
  final void Function(BuildContext context, String pageId)? onPage;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final b = block;
    if (b is SkIntro) return _intro(b, p);
    if (b is SkArticle) return _article(b, p);
    if (b is SkSteps) return _steps(b, p);
    if (b is SkCards) return _cards(b, p);
    if (b is SkVideoSlot) return _video(b, p);
    if (b is SkLink) return _link(context, b, p);
    if (b is SkGrownUpNote) return _grownUp(context, b, p);
    if (b is SkBreath) return _breath(b, p);
    return const SizedBox.shrink();
  }

  Widget _breath(SkBreath b, V2Palette p) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _heading(b.heading, p),
          Center(
            child: PvBreathTicker(
              running: true,
              builder: (context, s) => PvBreathingCircle(
                pattern: b.pattern,
                elapsed: s,
                tint: p.action.withValues(alpha: 0.18),
                ink: p.ink1,
                size: 220,
              ),
            ),
          ),
          if (b.line case final line?) ...[
            const SizedBox(height: 14),
            Text(line,
                style: pvManrope(
                    fontSize: _body,
                    fontWeight: FontWeight.w500,
                    height: 1.55,
                    color: p.ink2)),
          ],
        ],
      );

  // Kid-voice sizes are the brief's answer to "text-heavy is a fail state":
  // body 17 on a child page, 14.5 on a parent one.
  double get _body => kidVoice ? kSkBodySize : 14.5;
  double get _lead => kidVoice ? kSkLeadSize : 16;

  Widget _intro(SkIntro b, V2Palette p) => Text(b.text,
      style: pvManrope(
          fontSize: _lead,
          fontWeight: FontWeight.w500,
          height: 1.55,
          color: p.ink1));

  Widget _heading(String? t, V2Palette p) => t == null
      ? const SizedBox.shrink()
      : Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(t,
              style: pvFraunces(
                  fontSize: kidVoice ? kSkHeadingSize : 19,
                  fontWeight: FontWeight.w600,
                  height: 1.22,
                  color: p.ink1)),
        );

  Widget _article(SkArticle b, V2Palette p) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _heading(b.heading, p),
          for (var i = 0; i < b.paragraphs.length; i++) ...[
            Text(b.paragraphs[i],
                style: pvManrope(
                    fontSize: _body,
                    fontWeight: FontWeight.w500,
                    height: 1.6,
                    color: p.ink2)),
            if (i != b.paragraphs.length - 1) const SizedBox(height: 13),
          ],
        ],
      );

  Widget _steps(SkSteps b, V2Palette p) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _heading(b.heading, p),
          for (var i = 0; i < b.steps.length; i++) ...[
            skStepRow(i, b.steps[i].title, b.steps[i].detail, p,
                kidVoice: kidVoice),
            if (i != b.steps.length - 1) SizedBox(height: kidVoice ? 18 : 16),
          ],
        ],
      );

  Widget _cards(SkCards b, V2Palette p) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _heading(b.heading, p),
          for (var i = 0; i < b.cards.length; i++) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(14, 13, 14, 14),
              decoration: BoxDecoration(
                color: v2BlockTint((b.hue + i * 22) % 360, p),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(b.cards[i].title,
                        style: pvManrope(
                            fontSize: _body,
                            fontWeight: FontWeight.w700,
                            height: 1.5,
                            color: p.ink1)),
                    const SizedBox(height: 4),
                    Text(b.cards[i].line,
                        style: pvManrope(
                            fontSize: _body - 1.5,
                            fontWeight: FontWeight.w500,
                            height: 1.55,
                            color: p.ink2)),
                  ]),
            ),
            if (i != b.cards.length - 1) const SizedBox(height: 9),
          ],
        ],
      );

  Widget _video(SkVideoSlot b, V2Palette p) => PvVideoPlaceholder(
        title: b.title,
        subtitle: b.subtitle,
        duration: b.minutes,
        hue: b.hue,
        slotId: b.slotId,
        overlayTitle: true,
      );

  Widget _link(BuildContext context, SkLink b, V2Palette p) {
    final dead = b.isDead;
    Future<void> open() async {
      if (b.pageId != null) {
        onPage?.call(context, b.pageId!);
        return;
      }
      // ⚠️ THE GATE. A url, or a surface marked grown-up, asks first.
      if (b.url != null || b.grownUp) {
        if (!await skAskGrownUp(context)) return;
        if (!context.mounted) return;
      }
      if (b.url != null) {
        try {
          await launchUrl(Uri.parse(b.url!),
              mode: LaunchMode.externalApplication);
        } catch (_) {}
        return;
      }
      onSurface?.call(context, b.surfaceId!);
    }

    return InkWell(
      onTap: dead ? null : open,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        constraints: const BoxConstraints(minHeight: kSkTap),
        padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: p.line),
        ),
        child: Row(children: [
          Icon(
              b.url != null
                  ? Icons.open_in_new_rounded
                  : Icons.arrow_forward_rounded,
              size: 18,
              color: dead ? p.ink3 : p.action),
          const SizedBox(width: 10),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(b.label,
                  style: pvManrope(
                      fontSize: _body - 1,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                      color: dead ? p.ink3 : p.ink1)),
              if (b.blurb != null)
                Text(b.blurb!,
                    style: pvManrope(
                        fontSize: _body - 3.5, height: 1.45, color: p.ink2)),
            ]),
          ),
          if (b.url != null || b.grownUp)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Icon(Icons.lock_outline_rounded, size: 16, color: p.ink3),
            ),
          if (dead)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                  color: p.surfaceAlt, borderRadius: BorderRadius.circular(999)),
              child: Text('SOON',
                  style: pvManrope(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: p.ink3)),
            ),
        ]),
      ),
    );
  }

  /// "For the grown-up": a button on the child's page; the text behind the
  /// gate, in a sheet, in the parent's voice and size.
  Widget _grownUp(BuildContext context, SkGrownUpNote b, V2Palette p) =>
      SkGrownUpButton(
        label: b.heading,
        onPassed: () => skShowGrownUpSheet(context, title: b.heading, body: b.text),
      );
}

/// One numbered step, at the child size. Shared with the activity screen so
/// a lesson's steps and an activity's steps are the same row.
Widget skStepRow(int i, String title, String? detail, V2Palette p,
        {bool kidVoice = true}) =>
    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: kidVoice ? 32 : 26,
        height: kidVoice ? 32 : 26,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: p.action.withValues(alpha: 0.10),
          shape: BoxShape.circle,
        ),
        child: Text('${i + 1}',
            style: pvManrope(
                fontSize: kidVoice ? 14 : 12,
                fontWeight: FontWeight.w800,
                height: 1.5,
                color: p.action)),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: pvManrope(
                  fontSize: kidVoice ? kSkBodySize : 14.5,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                  color: p.ink1)),
          if (detail != null) ...[
            const SizedBox(height: 3),
            Text(detail,
                style: pvManrope(
                    fontSize: kidVoice ? kSkBodySize - 1 : 13.5,
                    fontWeight: FontWeight.w500,
                    height: 1.55,
                    color: p.ink2)),
          ],
        ]),
      ),
    ]);

/// The "For the grown-up" control: a quiet full-width row with a lock, at
/// the child tap size. Passing the gate runs [onPassed].
class SkGrownUpButton extends StatelessWidget {
  const SkGrownUpButton(
      {super.key, required this.label, required this.onPassed});
  final String label;
  final VoidCallback onPassed;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return InkWell(
      onTap: () async {
        if (await skAskGrownUp(context)) onPassed();
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        constraints: const BoxConstraints(minHeight: kSkTap),
        padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
        decoration: BoxDecoration(
          color: p.surfaceAlt,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(children: [
          Icon(Icons.lock_outline_rounded, size: 18, color: p.ink2),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label,
                style: pvManrope(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                    color: p.ink2)),
          ),
          Icon(Icons.chevron_right_rounded, size: 20, color: p.ink3),
        ]),
      ),
    );
  }
}

/// The parent's text, in a sheet, in the parent's size.
void skShowGrownUpSheet(BuildContext context,
    {required String title, required String body}) {
  final p = V2PaletteStore.instance.current;
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: p.ground,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
    builder: (_) => SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                  color: p.line, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 18),
          Text(title.toUpperCase(),
              style: pvManrope(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: p.action)),
          const SizedBox(height: 8),
          Text(body.isEmpty ? 'The note for this one is still being written.' : body,
              style: pvManrope(fontSize: 14.5, height: 1.6, color: p.ink1)),
        ]),
      ),
    ),
  );
}
