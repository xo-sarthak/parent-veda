// =============================================================================
//  A tracker, rebuilt from the "Track what you're working on" design project
// -----------------------------------------------------------------------------
//  **Where to look:** TTC → Getting ready → Weight and habits →
//  "Track what you're working on". Also TTC → Tools → the same tile.
//
//  ---------------------------------------------------------------------------
//  ⚠️ THIS SCREEN IS GENERIC AND THE DESIGN IS FOR ONE TRACKER
//  ---------------------------------------------------------------------------
//
//  Five trackers share it — symptoms, weight, mood, partner health and the
//  merged `habits`. The design was drawn for `habits`, which has nine fields in
//  four groups; the others have one or two fields and no groups at all.
//
//  So everything the design adds is driven by DATA rather than by the tracker's
//  id: eyebrows come from `TtcField.group`, and a tracker whose fields carry no
//  group renders exactly as it always did, one continuous list. The screen
//  still knows nothing about which tracker it is drawing, which is the property
//  that let eight of them share it in the first place.
//
//  ---------------------------------------------------------------------------
//  ⚠️ WHAT THE REBUILD ACTUALLY CHANGED, AND WHY EACH ONE
//  ---------------------------------------------------------------------------
//
//  * **One continuous sheet, not nine rows in a card.** The old screen put
//    every field inside a single `TtcCard` separated by hairlines — fine for
//    two fields, and after four trackers were merged into one it became a
//    nine-row form in a box. Cards do not nest; grouping is white space and an
//    eyebrow.
//
//  * **One control vocabulary.** A number, a worded scale and a set of named
//    choices now share a white well, a hairline, a 14 radius and a 44pt target.
//    Choosing fills it with the hue at tint strength and draws an ink edge, and
//    nothing else changes. Three control types used to read as three widgets.
//
//  * **"Clear" appears only once something is there.** An untouched field
//    carries no instruction and no obligation — which is the difference between
//    nine optional notes and nine unfinished tasks.
//
//  * **Looking back replaced thirty day-cards.** The old history answered "what
//    did I log on the 4th", which nobody asks. It now answers "has this been
//    getting better or worse", one field at a time, over four weeks.
//
//  ---------------------------------------------------------------------------
//  ⚠️ AND THE RULES THAT ARE NOT STYLE
//  ---------------------------------------------------------------------------
//
//  No score, no streak, no percentage, no ring that fills, no badge. No value
//  is good or bad — eight hours is not a pass and two coffees is not a fail, so
//  nothing turns red, amber or green because of what she entered. The strip has
//  no target line, no shaded band and no second colour; its caption states the
//  range she wrote down and stops.
//
//  ⚠️ AND A GAP IS NOTHING AT ALL. No hollow shape, no faint tick, no dimmed
//  slot — because a slot she did not fill reads as a slot she failed. The
//  four-week rhythm holds the position and draws nothing, so a blank column is
//  a day that went unwritten rather than a day that went wrong.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../localization/app_language.dart';
import '../../theme/pv_fonts.dart';
import '../../ttc/ttc_log_store.dart';
import '../../ttc/ttc_reads_data.dart';
import '../../ttc/ttc_trackers_data.dart';
import '../products/pv_store_chrome.dart' show pvSnack;
import '../v2/v2_palette.dart';
import 'ttc_common.dart';
import 'ttc_focus_screen.dart' show openTtcArticle;
import 'ttc_round_strings.dart' show ttcRoundDate;
import 'ttc_strings.dart';
import 'doors/ttc_tab_art.dart' show TtcTabArt, TtcTabMark;
import 'ttc_tool_chrome.dart';
import 'ttc_tools_screen.dart' show ttcToolById;
import 'ttc_tool_hues.dart';
import 'ttc_surface_router.dart' show openTtcSurface;
import '../../ttc/ttc_bmi_rules.dart';
import '../../ttc/ttc_bmi_store.dart';

/// The hue a field's linked read opens in. 42 is the stage's warm read tone —
/// the same one `ttc_read_stress_fertility` carries in its own definition, so
/// the piece looks the same however it is reached.
const double kTtcTrackerReadHue = 42;

// -----------------------------------------------------------------------------
//  The design's palette, transcribed
// -----------------------------------------------------------------------------
//  ⚠️ FIVE VALUES, ALL FROM ONE HUE, AND NOT ONE OF THEM MEANS ANYTHING. They
//  are chrome: an eyebrow, a chosen state, a bar, a dot. None of them changes
//  with the value she entered, and that is the point — the moment a colour
//  responds to a number, the screen has started grading her.

/// Eyebrows and the "Look back" link.
///
/// ⚠️ VIOLET, NOT GREEN — CHANGED 2026-09-04. The design used the door's own
/// green here, and on the built screen it read as a second accent competing
/// with the tint on the chosen controls. `#6A30B6` is the design system's
/// `action`, which is what every other eyebrow in this app is set in — spent
/// on eyebrows and links and nowhere else.
///
/// The tints below stay green: they are the CHOSEN state, and colouring those
/// violet too would make the whole screen one hue and lose the distinction
/// between "this is a heading" and "this is your answer".
const Color _kGreenInk = Color(0xFF6A30B6);

/// A chosen control. `hsl(104 32% 91%)`.
const Color _kTint = Color(0xFFE5F0E1);

/// A bar's body. Kept for revert (2026-09-27, the tool rebuild): the
/// design's green, `hsl(104 32% 90%)` = 0xFFE2EEDD. Ink-led now, so the
/// look-back matches every other tool's chart.
const Color _kBar = Color(0xFFE9E6EF);

/// A bar's cap and a matrix dot's edge. Kept for revert: 0xFF548D46.
const Color _kBarCap = ttcTitleInk;

/// A matrix dot's fill. Kept for revert: 0xFFDDEBD8.
const Color _kDot = ttcTitleInk;

/// How many days the looking-back view covers. Four weeks, so a week's shape is
/// visible four times over — enough to see a rhythm and short enough that a bad
/// fortnight is not still on screen a month later.
const int _kLookBackDays = 28;

void openTtcTracker(BuildContext context, String trackerId) {
  final tracker = ttcTrackerById(trackerId);
  if (tracker == null) return;
  Navigator.of(context).push(MaterialPageRoute<void>(
    builder: (_) => TtcTrackerScreen(tracker: tracker),
    settings: RouteSettings(name: 'ttc/tracker/$trackerId'),
  ));
}

/// The screen for a tracker id, or null when no such tracker exists.
///
/// ⚠️ NULL IS A REAL ANSWER. An unknown id resolves to nothing rather than to
/// the wrong tracker — the same rule every other id in this stage follows.
Widget? ttcTrackerScreenFor(String id) {
  final t = ttcTrackerById(id);
  return t == null ? null : TtcTrackerScreen(tracker: t);
}

// ⚠️ KEPT FOR REVERT (2026-09-27, the tool rebuild): the screen below was
// the tracker until the rebuild at the foot of this file. It logged TODAY
// only, sat on its own back bar and ground rather than the tool shell, and
// its look-back could not open a day. Unreached; `TtcTrackerScreen` is the
// rebuilt one. To revert, swap the two class names back.
class TtcTrackerScreenClassic extends StatefulWidget {
  const TtcTrackerScreenClassic({super.key, required this.tracker});

  final TtcTracker tracker;

  @override
  State<TtcTrackerScreenClassic> createState() =>
      _TtcTrackerScreenClassicState();
}

class _TtcTrackerScreenClassicState extends State<TtcTrackerScreenClassic> {
  bool _lookBack = false;
  late String _backField = widget.tracker.fields.first.id;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([TtcLogStore.instance, TtcLang.instance]),
      builder: (context, _) {
        final t = TtcS.current();
        return Scaffold(
          backgroundColor: ttcBg,
          body: SafeArea(
            bottom: false,
            child: Column(children: [
              // ⚠️ THE CRUMB NAMES WHERE THE ARROW GOES (tools pass,
              // 2026-09-27). "GETTING READY" showed on every tracker, even
              // Partner health opened from his side. Kept for revert:
              //   crumb: _lookBack ? 'TODAY' : 'GETTING READY',
              _Header(
                crumb: _lookBack ? 'BACK TO TODAY' : '',
                // ⚠️ THE LINK IS ALSO THE WAY BACK. From the looking-back view
                // the header's arrow returns to today rather than leaving the
                // tracker, because she came from today and expects to.
                onBack: _lookBack
                    ? () => setState(() => _lookBack = false)
                    : () => Navigator.of(context).maybePop(),
                onLookBack: _lookBack
                    ? null
                    : () => setState(() => _lookBack = true),
              ),
              Expanded(
                child: _lookBack
                    ? _LookBackBody(
                        tracker: widget.tracker,
                        t: t,
                        fieldId: _backField,
                        onPick: (id) => setState(() => _backField = id),
                      )
                    : _TodayBody(tracker: widget.tracker, t: t),
              ),
            ]),
          ),
        );
      },
    );
  }
}

// =============================================================================
//  The header
// =============================================================================

class _Header extends StatelessWidget {
  const _Header({
    required this.crumb,
    required this.onBack,
    required this.onLookBack,
  });

  final String crumb;
  final VoidCallback onBack;
  final VoidCallback? onLookBack;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 56,
        child: Row(children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onBack,
            child: const SizedBox(
              width: 44,
              height: 44,
              child: Icon(Icons.chevron_left_rounded,
                  size: 24, color: ttcTitleInk),
            ),
          ),
          Text(crumb,
              style: pvManrope(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                  color: ttcMuted)),
          const Spacer(),
          if (onLookBack != null)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onLookBack,
              child: Container(
                height: 44,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                // Says what it shows (2026-09-27). Kept for revert:
                // 'Look back'.
                child: Text(kTtcTrackerLookBack,
                    style: pvManrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: ttcTitleInk)),
              ),
            ),
          const SizedBox(width: 6),
        ]),
      );
}

/// The date line and the title, above the sheet.
class _PageHead extends StatelessWidget {
  const _PageHead({required this.above, required this.title});
  final String above;
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(18, 6, 18, 22),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ⚠️ `ttcSoft`, NOT `ttcMuted`, AND SEMI-BOLD. Reported as "Friday 4
          // September seems so faded". `ttcMuted` is the app's metadata grey —
          // right for a caption under a chart, wrong for the one line telling
          // her which day she is logging.
          Text(above,
              style: ttcBody(13, color: ttcSoft, w: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(title,
              style: ttcFraunces(27,
                  w: FontWeight.w600, color: ttcTitleInk, h: 1.15)),
        ]),
      );
}

/// The white sheet the content slides over. Radius 28 at the top, a hairline,
/// and no shadow — depth here is an edge, never a gradient.
class _Sheet extends StatelessWidget {
  const _Sheet({required this.child, this.padding});
  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 520),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(top: BorderSide(color: ttcBorder)),
        ),
        padding:
            padding ?? const EdgeInsets.fromLTRB(18, 28, 18, ttcBottomInset),
        child: child,
      );
}

Widget _eyebrow(String s) => Text(s.toUpperCase(),
    style: pvManrope(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.4,
        height: 1,
        color: _kGreenInk));

// =============================================================================
//  Today
// =============================================================================

class _TodayBody extends StatelessWidget {
  const _TodayBody({required this.tracker, required this.t});

  final TtcTracker tracker;
  final TtcS t;

  @override
  Widget build(BuildContext context) {
    final hi = t.hinglish;

    // ⚠️ GROUPS COME OUT OF THE FIELD LIST, IN FIELD ORDER. Not a map, not a
    // sort — a tracker's field order is a decision somebody made about what to
    // ask first, and grouping must not quietly re-order it.
    //
    // ⚠️ AND ONE BLOCK PER HEADING (tools pass, 2026-09-27). A field added
    // later under an earlier heading ("In bed by about eleven", Sleep, after
    // Stress) opened a second "Sleep" further down. Fields now join the first
    // block with their heading, still in field order inside it. Kept for
    // revert:
    //   if (blocks.isEmpty || blocks.last.$1 != f.group) {
    //     blocks.add((f.group, [f]));
    //   } else {
    //     blocks.last.$2.add(f);
    //   }
    final blocks = <(String?, List<TtcField>)>[];
    for (final f in tracker.fields) {
      final at = f.group == null
          ? -1
          : blocks.indexWhere((b) => b.$1 == f.group);
      if (at >= 0) {
        blocks[at].$2.add(f);
      } else if (f.group == null &&
          blocks.isNotEmpty &&
          blocks.last.$1 == null) {
        blocks.last.$2.add(f);
      } else {
        blocks.add((f.group, [f]));
      }
    }

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _PageHead(above: _todayLine(), title: tracker.title(hi)),
        _Sheet(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ⚠️ THE PERMISSION, BEFORE ANYTHING IS ASKED FOR. Nine empty
                // fields read as nine things she has failed to do unless
                // something says otherwise first. This is that sentence and it
                // is the most important copy on the screen.
                // "Did it save?" answered up front (2026-09-27): there is no
                // save button. Kept for revert: the first two sentences only.
                Text('Write down as much or as little as you like. One thing '
                    'is enough. Each answer saves as you tap.',
                    style: ttcBody(14, color: ttcInk, h: 1.55)),
                // Who fills in his tracker, said on it (2026-09-27).
                if (tracker.forPartner) ...[
                  const SizedBox(height: 10),
                  Text(kTtcTrackerPartnerWho,
                      key: const ValueKey('ttc_tracker_partner_who'),
                      style: ttcBody(13, color: ttcSoft, h: 1.55)),
                ],

                // ⚠️ THE TRACKER'S OWN "WHY", KEPT — AND THE DESIGN HAS NO
                // SLOT FOR IT.
                //
                // The design's intro is the one permission line above. Every
                // tracker in this app also carries a `why`, shown before
                // anything is asked for, and `ttc_tools_test.dart` asserts it
                // — it is the sentence that says what the thing is FOR before
                // it starts asking questions, and it is per-tracker where the
                // line above is not.
                //
                // Dropping it to match the design exactly would have been a
                // silent regression on four other trackers that share this
                // screen and were never redrawn. It sits second and quieter,
                // so the permission still leads.
                const SizedBox(height: 10),
                Text(tracker.why(hi),
                    style: ttcBody(13, color: ttcSoft, h: 1.55)),
                const SizedBox(height: 28),

                for (var b = 0; b < blocks.length; b++) ...[
                  if (b > 0) ...[
                    const SizedBox(height: 28),
                    Container(height: 1, color: ttcBorder),
                    const SizedBox(height: 28),
                  ],
                  if (blocks[b].$1 != null) ...[
                    _eyebrow(blocks[b].$1!),
                    const SizedBox(height: 16),
                  ],
                  for (var i = 0; i < blocks[b].$2.length; i++) ...[
                    if (i > 0) const SizedBox(height: 20),
                    _FieldRow(
                        tracker: tracker, field: blocks[b].$2[i], t: t),
                  ],
                ],

                _SevereNotice(tracker: tracker, t: t),

                if (tracker.disclaimer(hi) != null) ...[
                  const SizedBox(height: 28),
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Icon(Icons.info_outline_rounded,
                        size: 15, color: ttcMuted),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(tracker.disclaimer(hi)!,
                          style: ttcBody(11.5, color: ttcMuted, h: 1.5)),
                    ),
                  ]),
                ],
              ]),
        ),
      ],
    );
  }

  static const _days = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday',
    'Friday', 'Saturday', 'Sunday',
  ];
  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June', 'July',
    'August', 'September', 'October', 'November', 'December',
  ];

  static String _todayLine() {
    final d = DateTime.now();
    return '${_days[d.weekday - 1]} ${d.day} ${_months[d.month - 1]}';
  }
}

/// The one thing on this screen that reacts to a value — and it reacts to a
/// scale being at its far end, never to a value being "bad".
class _SevereNotice extends StatelessWidget {
  const _SevereNotice({required this.tracker, required this.t});

  final TtcTracker tracker;
  final TtcS t;

  @override
  Widget build(BuildContext context) {
    final severe = tracker.fields.any((f) {
      if (f.kind != TtcFieldKind.scale) return false;
      final v = TtcLogStore.instance.valueFor(tracker.id, f.id);
      // Top of the scale — "Very heavy" at the far end.
      return v != null && v.value.round() >= f.choicesEn.length - 1;
    });
    if (!severe) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: TtcCard(
        color: ttcCoralTint,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.info_outline_rounded, size: 17, color: ttcCoral),
            const SizedBox(width: 9),
            Expanded(child: Text(t.severeNoticedTitle, style: ttcJakarta(14.5))),
          ]),
          const SizedBox(height: 9),
          Text(t.severeNoticedBody, style: ttcBody(12.5, h: 1.55)),
        ]),
      ),
    );
  }
}

// =============================================================================
//  One field
// =============================================================================

class _FieldRow extends StatelessWidget {
  const _FieldRow({required this.tracker, required this.field, required this.t});

  final TtcTracker tracker;
  final TtcField field;
  final TtcS t;

  @override
  Widget build(BuildContext context) {
    final hi = t.hinglish;
    final current = TtcLogStore.instance.valueFor(tracker.id, field.id);

    // ⚠️ THE TITLE COMES FROM THE READ, NOT FROM A STRING HERE. Same
    // single-source rule the tile system follows: renaming the article renames
    // this line, because there is only one of it. A dead id shows nothing
    // rather than a link that opens nothing.
    final read = field.readId == null ? null : ttcReadById(field.readId!);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: Text(field.label(hi),
              style: ttcBody(12.5, color: ttcInk, w: FontWeight.w600, h: 1.35)),
        ),
        // ⚠️ "CLEAR" ONLY ONCE SOMETHING IS THERE. An untouched field carries
        // no instruction and no obligation — and clearing must always be
        // possible, because a mis-tap that cannot be undone turns a log into a
        // permanent record of a mistake.
        // A small "Saved" beside a field that holds something (2026-09-27),
        // so a tap is seen to stick.
        if (current != null) ...[
          const Icon(Icons.check_rounded, size: 14, color: ttcSoft),
          const SizedBox(width: 3),
          Text(kTtcTrackerSaved,
              style: ttcBody(12.5, color: ttcSoft, w: FontWeight.w600)),
        ],
        if (current != null)
          GestureDetector(
            onTap: () => TtcLogStore.instance.clear(tracker.id, field.id),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(t.trackerClear,
                  style: ttcBody(12.5, color: ttcMuted, w: FontWeight.w600)),
            ),
          ),
      ]),
      const SizedBox(height: 8),
      if (field.kind == TtcFieldKind.number) ...[
        _Stepper(tracker: tracker, field: field, current: current),
        // One-tap answers for the usual values (2026-09-27): 40 minutes
        // was eight taps from zero.
        if (field.presets.isNotEmpty) ...[
          const SizedBox(height: 10),
          _Presets(tracker: tracker, field: field, current: current),
        ],
      ] else
        _Segments(tracker: tracker, field: field, hi: hi, current: current),
      if (read != null) ...[
        const SizedBox(height: 10),
        // ⚠️ UNDER THE CONTROL, AND DELIBERATELY QUIET. One field in nine
        // carries this. Anywhere prominent it would make the other eight look
        // like they were missing something, and it would read as required
        // reading before she is allowed to log a number. It is an offer after
        // the fact — and it says what the piece is called, never anything
        // about the value she just chose.
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () =>
              openTtcArticle(context, field.readId!, hue: kTtcTrackerReadHue),
          // ⚠️ IT HAS TO LOOK LIKE A LINK. It was plain grey text with a small
          // icon, which reads as a caption — reported as "that article in
          // stress, it should seem like clickable". It now carries the app's
          // action violet, a semi-bold weight and a chevron, which is the
          // vocabulary every other tappable row in this stage uses.
          //
          // Still quiet: one field in nine has this, and a loud row would make
          // the other eight look like they were missing something.
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              // Kept for revert (2026-09-29, no tinted slab behind text): color: ttcPanel,
              color: Colors.white, border: const Border.fromBorderSide(BorderSide(color: ttcLine)),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(children: [
              Icon(Icons.article_outlined, size: 14, color: ttcTitleInk),
              const SizedBox(width: 8),
              Expanded(
                child: Text(read.title.of(AppLanguage.english),
                    maxLines: 2,
                    style: ttcBody(12.5,
                        color: ttcTitleInk, w: FontWeight.w700, h: 1.4)),
              ),
              const SizedBox(width: 6),
              Icon(Icons.chevron_right_rounded, size: 17, color: ttcTitleInk),
            ]),
          ),
        ),
      ],
    ]);
  }
}

/// ⚠️ ONE VOCABULARY, THREE MEANINGS. A scale and a set of named choices are
/// the same control — a scale is simply a choice whose options happen to be
/// ordered — and showing it as words rather than a numbered slider is the whole
/// point: "3 out of 5" means nothing, "Sound" means something.
class _Segments extends StatelessWidget {
  const _Segments({
    required this.tracker,
    required this.field,
    required this.hi,
    required this.current,
  });

  final TtcTracker tracker;
  final TtcField field;
  final bool hi;
  final TtcLogValue? current;

  @override
  Widget build(BuildContext context) {
    final options = field.choices(hi);
    final chosen = current?.value.round();

    void tap(int i) => i == chosen
        ? TtcLogStore.instance.clear(tracker.id, field.id)
        : TtcLogStore.instance.log(tracker.id, field.id, i.toDouble());

    // ⚠️ A SCALE DIVIDES ONE ROW; NAMED CHOICES MAY WRAP. THE DESIGN WRAPS
    // BOTH, AND THIS REPO HAS ALREADY PAID FOR THAT ONCE.
    //
    // The design's control is `flex-wrap: wrap` for every set of options. On a
    // 354pt sheet a five-option scale wraps 4 + 1 — "None / A little / Some /
    // A lot" on one line and "Severe" orphaned below it, for every symptom on
    // the screen. The note on the code this replaced says exactly that, and it
    // is not cosmetic: these options are ORDERED, and a wrapped last item reads
    // as a separate control rather than the far end of the same line.
    //
    // So the chip is the design's — same 44pt target, same 14 radius, same
    // tint-and-ink-edge when chosen — and only the LAYOUT differs, by kind:
    //
    //   * `scale`  → one row, equal widths, never wrapping. It is a line from
    //                one end to the other and it must look like one.
    //   * `choice` → the design's wrap. Walk / Yoga / Strength have no order,
    //                so a second line loses nothing.
    if (field.kind == TtcFieldKind.scale) {
      return Row(children: [
        for (var i = 0; i < options.length; i++) ...[
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => tap(i),
              // ⚠️ THE PCOS "WHERE DO I STAND" BLOCK, EXACTLY — 2026-09-04.
              // Asked for, for symmetry, and it is the better one: unchosen is
              // a filled panel with NO border, chosen is the hue at tint
              // strength with a 1.5 ink edge. Bordering both states made every
              // option look half-selected, which is why a row of five read as
              // busy.
              child: Container(
                height: 44,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: i == chosen ? _kTint : ttcPanel,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: i == chosen ? ttcTitleInk : Colors.transparent,
                      width: 1.5),
                ),
                child: Text(options[i],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: ttcBody(11.5,
                        color: i == chosen ? ttcTitleInk : ttcInk,
                        w: i == chosen
                            ? FontWeight.w800
                            : FontWeight.w600)),
              ),
            ),
          ),
          if (i < options.length - 1) const SizedBox(width: 6),
        ],
      ]);
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var i = 0; i < options.length; i++)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            // Tapping the chosen option again clears it. One control, and no
            // separate undo to find.
            onTap: () => tap(i),
            child: Container(
              constraints: const BoxConstraints(minHeight: 44),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: i == chosen ? _kTint : ttcPanel,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: i == chosen ? ttcTitleInk : Colors.transparent,
                    width: 1.5),
              ),
              child: Text(options[i],
                  style: ttcBody(13,
                      color: i == chosen ? ttcTitleInk : ttcInk,
                      w: i == chosen ? FontWeight.w800 : FontWeight.w600)),
            ),
          ),
      ],
    );
  }
}

/// − · a well · +
///
/// ⚠️ THE WELL SHOWS THE UNIT WHEN EMPTY, NOT A ZERO. A zero is a value she did
/// not enter, and a field showing "0 hrs" before she has touched it has put
/// words in her mouth.
class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.tracker,
    required this.field,
    required this.current,
  });

  final TtcTracker tracker;
  final TtcField field;
  final TtcLogValue? current;

  void _bump(double delta) {
    final has = current != null;
    // ⚠️ THE FIRST TAP LANDS ON `start`, WHICHEVER BUTTON IT WAS. Minutes moved
    // steps by 5 from 0, so a first `+` would give "5 minutes" and a walk would
    // be eleven more taps. Starting at the likely answer makes every real value
    // one or two taps away in either direction.
    final next = has
        ? (current!.value + delta).clamp(field.min, field.max)
        : (field.start ?? field.min);
    TtcLogStore.instance
        .log(tracker.id, field.id, (next * 10).roundToDouble() / 10);
  }

  @override
  Widget build(BuildContext context) {
    final has = current != null;
    final shown = !has
        ? ''
        : (current!.value == current!.value.roundToDouble()
            ? current!.value.toStringAsFixed(0)
            : current!.value.toStringAsFixed(1));

    return Row(children: [
      _StepButton(label: '−', onTap: () => _bump(-field.step)),
      const SizedBox(width: 12),
      // ⚠️ THE WELL IS TAPPABLE AND TYPES — ADDED 2026-09-04. Reported as "at
      // the moment it's just adjusted using plus minus".
      //
      // Both controls are needed and neither replaces the other. Steppers are
      // right for a nudge — half an hour more sleep than yesterday — and
      // hopeless for an absolute value: forty minutes of movement is eight taps
      // from zero. Typing is right for a number she already knows and clumsy
      // for a small adjustment.
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => showTtcTypeNumber(context, tracker, field, current),
        child: Container(
        height: 44,
        constraints: const BoxConstraints(minWidth: 104),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: has ? _kTint : ttcPanel,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: has ? ttcTitleInk : Colors.transparent, width: 1.5),
        ),
        child: has
            ? Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(shown,
                      style: ttcFraunces(20,
                          w: FontWeight.w600, color: ttcTitleInk)),
                  if (field.unit != null) ...[
                    const SizedBox(width: 5),
                    Text(field.unit!,
                        style: ttcBody(12.5,
                            color: ttcInk, w: FontWeight.w600)),
                  ],
                ],
              )
            : Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.keyboard_rounded, size: 15, color: ttcMuted),
                const SizedBox(width: 6),
                Text(field.unit ?? '',
                    style:
                        ttcBody(13, color: ttcMuted, w: FontWeight.w600)),
              ]),
      ),
      ),
      const SizedBox(width: 12),
      _StepButton(label: '+', onTap: () => _bump(field.step)),
    ]);
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: ttcPanel,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(label,
              style: ttcBody(19, color: ttcTitleInk, w: FontWeight.w600)),
        ),
      );
}

// =============================================================================
//  Looking back
// =============================================================================

class _LookBackBody extends StatelessWidget {
  const _LookBackBody({
    required this.tracker,
    required this.t,
    required this.fieldId,
    required this.onPick,
  });

  final TtcTracker tracker;
  final TtcS t;
  final String fieldId;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    final hi = t.hinglish;
    final field =
        tracker.fields.firstWhere((f) => f.id == fieldId, orElse: () =>
            tracker.fields.first);

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _PageHead(
            above: 'Four weeks to ${_short(DateTime.now())}',
            title: 'Looking back'),
        _Sheet(
          padding: const EdgeInsets.fromLTRB(0, 28, 0, ttcBottomInset),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Row(children: [
                    for (final f in tracker.fields) ...[
                      _FieldChip(
                        label: f.label(hi),
                        on: f.id == fieldId,
                        onTap: () => onPick(f.id),
                      ),
                      if (f != tracker.fields.last) const SizedBox(width: 8),
                    ],
                  ]),
                ),
                const SizedBox(height: 28),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: _LookBackStrip(
                      tracker: tracker, field: field, hi: hi),
                ),
              ]),
        ),
      ],
    );
  }

  static const _m = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static String _short(DateTime d) => '${d.day} ${_m[d.month - 1]}';
}

class _FieldChip extends StatelessWidget {
  const _FieldChip(
      {required this.label, required this.on, required this.onTap});
  final String label;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 40),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: on ? _kTint : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: on ? ttcTitleInk : ttcBorder),
          ),
          child: Text(label,
              style: ttcBody(12.5,
                  color: on ? ttcTitleInk : ttcInk, w: FontWeight.w600)),
        ),
      );
}

/// Four weeks of one field.
///
/// ⚠️ TWO SHAPES, DECIDED BY THE FIELD AND NOT BY TASTE. A quantity gets bars,
/// because height IS the value and nothing has to be looked up. A scale or a
/// set of named choices gets a matrix — one row per option, one mark per day —
/// because the options are not numbers and drawing "Yoga" as a taller bar than
/// "Walk" would invent an order the data does not have.
class _LookBackStrip extends StatelessWidget {
  const _LookBackStrip({
    required this.tracker,
    required this.field,
    required this.hi,
  });

  final TtcTracker tracker;
  final TtcField field;
  final bool hi;

  /// The last 28 days, oldest first. Null where nothing was written.
  List<double?> _series() {
    final today = DateTime.now();
    final out = <double?>[];
    for (var i = _kLookBackDays - 1; i >= 0; i--) {
      final day = DateTime(today.year, today.month, today.day)
          .subtract(Duration(days: i));
      out.add(TtcLogStore.instance
          .valueFor(tracker.id, field.id, on: day)
          ?.value);
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final data = _series();
    final present = data.whereType<double>().toList();
    final bars = field.kind == TtcFieldKind.number;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Kept for revert (2026-09-29, one heading style): the same Text with
      // style: ttcFraunces(20, w: FontWeight.w600, color: ttcTitleInk)
      TtcSectionHeading(field.label(hi)),
      const SizedBox(height: 4),
      Text('Last four weeks', style: ttcBody(13, color: ttcMuted)),
      const SizedBox(height: 16),

      if (bars)
        _Bars(data: data, field: field)
      else
        _Matrix(data: data, options: field.choices(hi)),

      const SizedBox(height: 16),
      // ⚠️ THE CAPTION DESCRIBES, IT NEVER ASSESSES. "Between 6 and 8 hours"
      // is a fact about what she wrote. "Averaging 7 hours" would be a summary
      // she did not ask for, and anything with the word "good" in it would be
      // a verdict.
      Text(_caption(present, bars),
          style: ttcBody(13, color: ttcInk, h: 1.45)),
      const SizedBox(height: 8),
      Text("A blank space is a day you didn't write anything down.",
          style: ttcBody(13, color: ttcMuted, h: 1.45)),
    ]);
  }

  String _caption(List<double> present, bool bars) {
    // Kept for revert (2026-09-28): 'Nothing written down here yet.'
    if (present.isEmpty) return 'No days written down yet.';
    if (!bars) return 'One mark for what you chose that day.';
    final lo = present.reduce((a, b) => a < b ? a : b);
    final hi2 = present.reduce((a, b) => a > b ? a : b);
    String n(double v) => v == v.roundToDouble()
        ? v.toStringAsFixed(0)
        : v.toStringAsFixed(1);
    final unit = field.unit ?? '';
    if (lo == hi2) {
      return '${n(lo)} $unit on the days you wrote something down.';
    }
    return 'Between ${n(lo)} and ${n(hi2)} $unit, on the days you wrote '
        'something down.';
  }
}

class _Bars extends StatelessWidget {
  const _Bars({required this.data, required this.field});
  final List<double?> data;
  final TtcField field;

  @override
  Widget build(BuildContext context) {
    // ⚠️ THE SCALE IS HER OWN HIGHEST VALUE, NOT THE FIELD'S MAXIMUM. `max` on
    // minutes moved is 300; scaling to that would draw every real walk as a
    // sliver against an invisible ceiling nobody is aiming at. Scaling to what
    // she actually wrote makes the shape of her own month readable — and it is
    // still not a target, because the tallest bar is simply her tallest bar.
    final present = data.whereType<double>();
    final top = present.isEmpty
        ? 1.0
        : present.reduce((a, b) => a > b ? a : b);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
        height: 104,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var w = 0; w < 4; w++) ...[
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (var d = 0; d < 7; d++) ...[
                      Expanded(
                        child: _Bar(
                          value: data[w * 7 + d],
                          top: top,
                        ),
                      ),
                      if (d < 6) const SizedBox(width: 3),
                    ],
                  ],
                ),
              ),
              if (w < 3) const SizedBox(width: 10),
            ],
          ],
        ),
      ),
      const SizedBox(height: 6),
      Container(height: 1, color: ttcBorder),
      const SizedBox(height: 7),
      _WeekLabels(),
    ]);
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.value, required this.top});
  final double? value;
  final double top;

  @override
  Widget build(BuildContext context) {
    // ⚠️ A GAP DRAWS NOTHING. Not a hollow shape, not a faint tick, not a
    // dimmed slot — the column holds its position and stays empty.
    if (value == null) return const SizedBox.shrink();
    return FractionallySizedBox(
      alignment: Alignment.bottomCenter,
      heightFactor: top == 0 ? 0 : (value! / top).clamp(0.04, 1.0),
      child: Container(
        decoration: const BoxDecoration(
          color: _kBar,
          border: Border(top: BorderSide(color: _kBarCap, width: 2)),
          borderRadius: BorderRadius.vertical(top: Radius.circular(2)),
        ),
      ),
    );
  }
}

class _Matrix extends StatelessWidget {
  const _Matrix({required this.data, required this.options});
  final List<double?> data;
  final List<String> options;

  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        for (var r = 0; r < options.length; r++)
          SizedBox(
            height: 26,
            child: Row(children: [
              SizedBox(
                width: 92,
                child: Text(options[r],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ttcBody(12.5, color: ttcInk)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Row(children: [
                  for (var w = 0; w < 4; w++) ...[
                    Expanded(
                      child: Row(children: [
                        for (var d = 0; d < 7; d++) ...[
                          Expanded(
                            child: Center(
                              child: data[w * 7 + d]?.round() == r
                                  ? Container(
                                      width: 7,
                                      height: 7,
                                      decoration: BoxDecoration(
                                        color: _kDot,
                                        borderRadius:
                                            BorderRadius.circular(2),
                                        border:
                                            Border.all(color: _kBarCap),
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ),
                          if (d < 6) const SizedBox(width: 3),
                        ],
                      ]),
                    ),
                    if (w < 3) const SizedBox(width: 10),
                  ],
                ]),
              ),
            ]),
          ),
        const SizedBox(height: 4),
        Container(height: 1, color: ttcBorder),
        const SizedBox(height: 7),
        Padding(
          padding: const EdgeInsets.only(left: 102),
          child: _WeekLabels(),
        ),
      ]);
}

/// The four week-starts, under the strip.
class _WeekLabels extends StatelessWidget {
  const _WeekLabels();

  static const _m = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    final today = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day);
    return Row(children: [
      for (var w = 0; w < 4; w++) ...[
        Expanded(
          child: Builder(builder: (_) {
            final d = today.subtract(Duration(days: _kLookBackDays - 1 - w * 7));
            return Text('${d.day} ${_m[d.month - 1]}',
                style: pvManrope(
                    fontSize: 11, letterSpacing: 0.2, color: ttcMuted));
          }),
        ),
        if (w < 3) const SizedBox(width: 10),
      ],
    ]);
  }
}

// =============================================================================
//  Typing a number in
// -----------------------------------------------------------------------------
//  ⚠️ A SHEET, NOT AN INLINE FIELD. An editable text box sitting in the well
//  would put a blinking cursor and a keyboard on a screen whose whole point is
//  that it asks nothing of her — and it would fight the stepper for the same
//  44pt target.
//
//  So the well is tappable, the sheet opens with the current value selected,
//  and one tap on Save closes it. The stepper is unchanged and both still work.
// =============================================================================

Future<void> showTtcTypeNumber(
  BuildContext context,
  TtcTracker tracker,
  TtcField field,
  TtcLogValue? current,
) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NumberSheet(
        tracker: tracker,
        field: field,
        current: current?.value,
      ),
    );

class _NumberSheet extends StatefulWidget {
  const _NumberSheet({
    required this.tracker,
    required this.field,
    required this.current,
  });

  final TtcTracker tracker;
  final TtcField field;
  final double? current;

  @override
  State<_NumberSheet> createState() => _NumberSheetState();
}

class _NumberSheetState extends State<_NumberSheet> {
  late final TextEditingController _c = TextEditingController(
      text: widget.current == null
          ? ''
          : (widget.current == widget.current!.roundToDouble()
              ? widget.current!.toStringAsFixed(0)
              : widget.current!.toStringAsFixed(1)));

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _save() {
    final v = double.tryParse(_c.text.trim());
    if (v == null) {
      // Empty or nonsense clears rather than writing a zero. A zero is a value
      // she did not enter.
      TtcLogStore.instance.clear(widget.tracker.id, widget.field.id);
    } else {
      TtcLogStore.instance.log(widget.tracker.id, widget.field.id,
          v.clamp(widget.field.min, widget.field.max));
    }
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 38,
                        height: 4,
                        decoration: BoxDecoration(
                            color: ttcBorder,
                            borderRadius: BorderRadius.circular(999)),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(widget.field.label(TtcS.current().hinglish),
                        style: ttcFraunces(22,
                            w: FontWeight.w600, color: ttcTitleInk, h: 1.2)),
                    const SizedBox(height: 16),
                    Row(children: [
                      Expanded(
                        child: TextField(
                          controller: _c,
                          autofocus: true,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.]')),
                          ],
                          onSubmitted: (_) => _save(),
                          style: ttcFraunces(28,
                              w: FontWeight.w600, color: ttcTitleInk),
                          decoration: InputDecoration(
                            isDense: true,
                            filled: true,
                            fillColor: ttcPanel,
                            hintText: '—',
                            hintStyle:
                                ttcFraunces(28, color: ttcMuted),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      if (widget.field.unit != null) ...[
                        const SizedBox(width: 12),
                        Text(widget.field.unit!,
                            style: ttcBody(14,
                                color: ttcSoft, w: FontWeight.w600)),
                      ],
                    ]),
                    // ⚠️ ONE WAY TO CLEAR (tools pass, 2026-09-27): the field
                    // already says "Clear" once it holds a value. A blank
                    // still clears. Kept for revert:
                    //   const SizedBox(height: 8),
                    //   Text('Leave it blank to clear it.',
                    //       style: ttcBody(12, color: ttcMuted)),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _save,
                        child: Container(
                          height: 46,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: ttcBorder, width: 1.2),
                          ),
                          // Kept for revert (2026-09-28): 'Save'
                          child: Text('Save the number',
                              style: ttcBody(13,
                                  color: ttcTitleInk, w: FontWeight.w800)),
                        ),
                      ),
                    ),
                  ]),
            ),
          ),
        ),
      );
}

// ---- tools pass, 2026-09-27 ------------------------------------------------

/// The header link to the four-week view, saying what it shows.
const String kTtcTrackerLookBack = 'Past 4 weeks';

/// Beside a field that holds a value.
const String kTtcTrackerSaved = 'Saved';

/// On his tracker: who fills it in.
const String kTtcTrackerPartnerWho =
    'You can fill this in together, or your partner can fill it in from his '
    'side of the app.';

/// 6 · 7 · 8 hrs. A tap writes the value; tapping the chosen one clears it,
/// like every other choice on this screen.
class _Presets extends StatelessWidget {
  const _Presets({
    required this.tracker,
    required this.field,
    required this.current,
  });

  final TtcTracker tracker;
  final TtcField field;
  final TtcLogValue? current;

  @override
  Widget build(BuildContext context) {
    String fmt(double v) =>
        v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
    return Wrap(spacing: 8, runSpacing: 8, children: [
      for (final v in field.presets)
        Builder(builder: (context) {
          final on = current != null && (current!.value - v).abs() < 1e-6;
          final label = field.unit == null ? fmt(v) : '${fmt(v)} ${field.unit}';
          return Semantics(
            button: true,
            selected: on,
            label: label,
            excludeSemantics: true,
            child: GestureDetector(
              key: ValueKey('ttc_preset_${field.id}_${fmt(v)}'),
              behavior: HitTestBehavior.opaque,
              onTap: () => on
                  ? TtcLogStore.instance.clear(tracker.id, field.id)
                  : TtcLogStore.instance.log(tracker.id, field.id, v),
              child: Container(
                constraints: const BoxConstraints(minHeight: 40),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: on ? _kTint : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: on ? ttcTitleInk : ttcBorder, width: on ? 1.5 : 1),
                ),
                child: Text(label,
                    style: ttcBody(12.5,
                        color: on ? ttcTitleInk : ttcInk,
                        w: on ? FontWeight.w800 : FontWeight.w600)),
              ),
            ),
          );
        }),
    ]);
  }
}

// =============================================================================
//  THE REBUILD — 2026-09-27, the tool rebuild (the user, walking build 13:
//  "old tools in new clothes… poor functionality")
// -----------------------------------------------------------------------------
//  What a first-time user hit on the old screen, and what happens now:
//
//  * **Only today could be logged.** Sleep is logged the next morning, a
//    weigh-in gets missed, a Sunday is remembered on Monday, and there was no
//    way to put any of it on the right day. A week strip now sits at the top
//    (Bevel's Journal and Clue's log both open on one): tap a day, log it.
//  * **The look-back could look, not touch.** "Past 4 weeks" drew a chart and
//    nothing on it opened. It now lists every day with an entry under the
//    chart, and a tap opens that day to change or clear it (the weight apps'
//    "All entries" list: Alma, MacroFactor, Hevy).
//  * **Weight was drawn as bars from zero,** so 61 kg and 62 kg looked the
//    same height. Weight is a line now, scaled to her own range.
//  * **Clear had no way back.** A mis-tap on "Clear" lost the value; it now
//    says so and offers Undo.
//  * **Old chrome.** Its own back bar, `ttcBg`, a coral `TtcCard` and green
//    tints: none of it matched the tool shell the other tools wear. It is the
//    tool shell now (`TtcToolScaffold`), with the tile's name as the eyebrow,
//    a chosen answer in ink like every other tool, and hairlines for depth.
//
//  Mobbin (2026-09-27):
//    Bevel Journal, a week strip over the day's rows
//      https://mobbin.com/screens/be4c91e4-d0a8-4840-9654-6834039006b0
//    Clue log, the day strip above the categories
//      https://mobbin.com/screens/061215bd-34ed-4f9d-909e-e4481b6faafb
//    Alma weight, a line then "All entries"
//      https://mobbin.com/screens/f28eba19-4f70-46e3-aa06-78501c448430
//    MacroFactor Scale Weight, dated entries each with an edit mark
//      https://mobbin.com/screens/3670bd7d-82d1-4015-940a-8cf38d5d90a0
//
//  Unchanged on purpose: the store and every key (`tracker/field/day`), the
//  no-score rule, "a gap draws nothing", the severe-scale notice, the field
//  presets and typing, and the tracker's own `why`.
// =============================================================================

/// The hue each tracker's field takes: the group its Tools tile sits in.
/// T6 (launch sanity, 2026-09-28): the named group constants, so the rule
/// is one file (ttc_tool_hues.dart). Kept for revert (2026-09-28):
/// double _trackerHue(TtcTracker t) => t.id == 'partner_health' ? 186 : 172;
double _trackerHue(TtcTracker t) =>
    t.id == 'partner_health' ? kTtcToolHueBoth : kTtcToolHueBody;

/// The eyebrow is the Tools tile's name, so tile, eyebrow and title agree.
String _trackerEyebrow(TtcTracker t, bool hi) {
  if (t.forPartner && TtcPartnerMode.instance.on) return 'Your health';
  return ttcToolById(t.id)?.name(hi) ?? t.title(hi);
}

/// One plain line saying what this screen is for.
String ttcTrackerTitle(TtcTracker t) {
  final him = TtcPartnerMode.instance.on;
  return switch (t.id) {
    'weight' => 'Note your weight.',
    'habits' => 'Sleep, movement and what you cut down.',
    'partner_health' => him
        ? 'Your sleep, drinks, smoke and heat.'
        : 'His sleep, drinks, smoke and heat.',
    'mood' => 'How today felt.',
    'symptoms' => 'What your body did today.',
    _ => t.subtitle(false),
  };
}

/// The intro: what she does here, and that it saves.
const String kTtcTrackerIntro =
    'Pick a day, then tap what fits. Each answer saves as you tap. One thing '
    'is enough.';

/// On his tracker, when he is the one looking.
// Kept for revert (2026-09-28): 'This one is yours to fill in.'
const String kTtcTrackerPartnerWhoHim = 'This tracker is yours to fill in.';

/// The first of the two views; the second is [kTtcTrackerLookBack].
const String kTtcTrackerLogView = 'Log a day';

/// Under the day strip.
String ttcTrackerDayLine(DateTime day, DateTime today) {
  final gap = today.difference(day).inDays;
  final date = ttcRoundDate(day);
  if (gap == 0) return 'Logging for today, $date';
  if (gap == 1) return 'Logging for yesterday, $date';
  return 'Logging for $date';
}

/// Above the entries under the chart.
const String kTtcTrackerEntriesTitle = 'Days with an entry';
const String kTtcTrackerEntriesHint = 'Tap a day to change or clear it.';
const String kTtcTrackerEntriesEmpty =
    'Nothing written down in the past four weeks. Tap "Log a day" to add one.';

DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

String _fmtNum(double v) =>
    v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

class TtcTrackerScreen extends StatefulWidget {
  const TtcTrackerScreen({super.key, required this.tracker, this.day});

  final TtcTracker tracker;

  /// The day to open on. Null is today.
  final DateTime? day;

  @override
  State<TtcTrackerScreen> createState() => _TtcTrackerScreenState();
}

class _TtcTrackerScreenState extends State<TtcTrackerScreen> {
  late DateTime _day = _dayOnly(widget.day ?? DateTime.now());
  bool _past = false;
  late String _pastField = widget.tracker.fields.first.id;

  void _openDay(DateTime d) => setState(() {
        _day = _dayOnly(d);
        _past = false;
      });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(
          [TtcLogStore.instance, TtcLang.instance, TtcPartnerMode.instance]),
      builder: (context, _) {
        final t = TtcS.current();
        final hi = t.hinglish;
        final tracker = widget.tracker;
        final hue = _trackerHue(tracker);
        return TtcToolScaffold(
          hue: hue,
          // The tool's mark over the eyebrow (2026-09-29, ttc_tool_marks.dart).
          toolId: tracker.id,
          eyebrow: _trackerEyebrow(tracker, hi),
          title: ttcTrackerTitle(tracker),
          intro: kTtcTrackerIntro,
          children: [
            const SizedBox(height: 20),
            // A Wrap, so a large text size puts the second pill under the
            // first rather than off the edge at 360dp.
            ttcToolPad(Wrap(spacing: 8, runSpacing: 8, children: [
              TtcToolPill(
                key: const ValueKey('ttc_tracker_view_log'),
                label: kTtcTrackerLogView,
                on: !_past,
                hue: hue,
                onTap: () => setState(() => _past = false),
              ),
              TtcToolPill(
                key: const ValueKey('ttc_tracker_view_past'),
                label: kTtcTrackerLookBack,
                on: _past,
                hue: hue,
                onTap: () => setState(() => _past = true),
              ),
            ])),
            const SizedBox(height: 20),
            if (!_past)
              ..._log(context, tracker, t)
            else
              ..._pastView(tracker, t),
            const SizedBox(height: 28),
          ],
        );
      },
    );
  }

  List<Widget> _log(BuildContext context, TtcTracker tracker, TtcS t) {
    final hi = t.hinglish;
    final p = V2PaletteStore.instance.current;
    final today = _dayOnly(DateTime.now());

    // One block per heading, in field order (the same rule as `_TodayBody`).
    final blocks = <(String?, List<TtcField>)>[];
    for (final f in tracker.fields) {
      final at =
          f.group == null ? -1 : blocks.indexWhere((b) => b.$1 == f.group);
      if (at >= 0) {
        blocks[at].$2.add(f);
      } else if (f.group == null &&
          blocks.isNotEmpty &&
          blocks.last.$1 == null) {
        blocks.last.$2.add(f);
      } else {
        blocks.add((f.group, [f]));
      }
    }

    return [
      ttcToolPad(_DayStrip(
        tracker: tracker,
        selected: _day,
        today: today,
        onPick: (d) => setState(() => _day = d),
      )),
      const SizedBox(height: 12),
      ttcToolPad(Row(children: [
        Expanded(
          child: Text(ttcTrackerDayLine(_day, today),
              key: const ValueKey('ttc_tracker_day_line'),
              style: pvManrope(
                  fontSize: 13.5, fontWeight: FontWeight.w800, color: p.ink1)),
        ),
        if (_day != today)
          InkWell(
            key: const ValueKey('ttc_tracker_back_today'),
            onTap: () => setState(() => _day = today),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              child: Text('Back to today',
                  style: pvManrope(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: ttcTitleInk,
                      decoration: TextDecoration.underline)),
            ),
          ),
      ])),
      const SizedBox(height: 14),
      // ⚠️ THE CONTROLS COME FIRST (launch sanity T4, 2026-09-28). The whole
      // "why" (two paragraphs on Weight) sat between the day strip and the
      // first control and pushed the controls below the fold. The reason
      // still comes before anything is asked for, as `ttc_tools_test.dart`
      // holds, but as ONE sentence; the rest is behind "Why this matters",
      // which opens it in a sheet. Mobbin: Stardust's symptom log (an info
      // mark beside the name opens the explanation; the control is what
      // the page shows),
      // https://mobbin.com/screens/8841ef76-e6a4-453f-bebc-cd838feb5804 ;
      // Lifesum "Nutrition ratings" (the explanation lives in a sheet),
      // https://mobbin.com/screens/376876df-203e-4fba-9afa-4c4c1b2fba10 ;
      // Oura heart rate zones (an explainer sheet off the data screen),
      // https://mobbin.com/screens/7f8a6ae0-de39-4e5f-8fee-3e0bd3aa5ce3 .
      // Kept for revert (2026-09-28):
      // ttcToolPad(Text(tracker.why(hi),
      //     style: pvManrope(fontSize: 12.5, height: 1.55, color: p.ink2))),
      ttcToolPad(Text(ttcTrackerWhyLead(tracker, hi),
          key: const ValueKey('ttc_tracker_why_lead'),
          style: pvManrope(fontSize: 12.5, height: 1.55, color: p.ink2))),
      if (ttcTrackerWhyLead(tracker, hi) != tracker.why(hi).trim())
        ttcToolPad(_WhyRow(
            onTap: () => showTtcTrackerWhy(context, tracker, hi))),
      if (tracker.forPartner) ...[
        const SizedBox(height: 10),
        ttcToolPad(Text(
            TtcPartnerMode.instance.on
                ? kTtcTrackerPartnerWhoHim
                : kTtcTrackerPartnerWho,
            key: const ValueKey('ttc_tracker_partner_who'),
            style: pvManrope(
                fontSize: 12.5,
                height: 1.5,
                fontWeight: FontWeight.w700,
                color: p.ink2))),
      ],
      const SizedBox(height: 24),
      // ⚠️ A GROUP IS A CARD WITH ITS OWN DRAWN MARK (2026-10-02, the user:
      // "What you're working on looks kinda bland", then "habits card redesign
      // has my go"; Mobbin: Brick's calm rows, Lifesum and Noom's drawn picture
      // on every item, MacroFactor's grouped cards). A tracker whose fields
      // carry a `group` (What you're working on, and his Partner health) drew a
      // small grey capitals label and a hairline between blocks, so Sleep,
      // Movement and Stress read as one long form. Now each group is a white
      // card, its mark and name on top and its fields inside; a tracker with no
      // groups (everything else) draws exactly as before. Kept for revert (the
      // old label-and-hairline loop):
      // for (var b = 0; b < blocks.length; b++) ...[
      //   if (b > 0) ...[
      //     const SizedBox(height: 22),
      //     ttcToolPad(Container(height: 1, color: p.line)),
      //     const SizedBox(height: 22),
      //   ],
      //   if (blocks[b].$1 != null) ...[
      //     ttcToolPad(Text(blocks[b].$1!.toUpperCase(),
      //         style: pvManrope(
      //             fontSize: 10.5,
      //             fontWeight: FontWeight.w800,
      //             letterSpacing: 1.3,
      //             color: p.ink3))),
      //     const SizedBox(height: 14),
      //   ],
      //   for (var i = 0; i < blocks[b].$2.length; i++) ...[
      //     if (i > 0) const SizedBox(height: 20),
      //     ttcToolPad(_FieldBlock(
      //         tracker: tracker, field: blocks[b].$2[i], day: _day, t: t)),
      //   ],
      // ],
      for (var b = 0; b < blocks.length; b++) ...[
        if (blocks[b].$1 != null) ...[
          if (b > 0) const SizedBox(height: 14),
          ttcToolPad(_GroupCard(
            name: blocks[b].$1!,
            hue: _trackerHue(tracker),
            children: [
              for (final f in blocks[b].$2)
                _FieldBlock(tracker: tracker, field: f, day: _day, t: t),
            ],
          )),
        ] else ...[
          if (b > 0) ...[
            const SizedBox(height: 22),
            ttcToolPad(Container(height: 1, color: p.line)),
            const SizedBox(height: 22),
          ],
          for (var i = 0; i < blocks[b].$2.length; i++) ...[
            if (i > 0) const SizedBox(height: 20),
            ttcToolPad(_FieldBlock(
                tracker: tracker, field: blocks[b].$2[i], day: _day, t: t)),
          ],
        ],
      ],
      ttcToolPad(_SevereLine(tracker: tracker, day: _day, t: t)),
      // ⚠️ BMI LIVES ON THE WEIGHT PAGE (launch sanity T1/T2, 2026-09-28).
      // "Weight" and "Weight and fertility" were two tiles for one subject;
      // the hub keeps one, and this row is the way to the BMI screen.
      if (tracker.id == 'weight') ...[
        const SizedBox(height: 24),
        ttcToolPad(const TtcWeightBmiRow()),
      ],
      if (tracker.disclaimer(hi) != null) ...[
        const SizedBox(height: 24),
        ttcToolPad(Text(tracker.disclaimer(hi)!,
            style: pvManrope(fontSize: 11.5, height: 1.5, color: p.ink3))),
      ],
    ];
  }

  List<Widget> _pastView(TtcTracker tracker, TtcS t) {
    final hi = t.hinglish;
    final p = V2PaletteStore.instance.current;
    final field = tracker.fields.firstWhere((f) => f.id == _pastField,
        orElse: () => tracker.fields.first);
    final today = _dayOnly(DateTime.now());
    final entries = <(DateTime, double)>[
      for (var i = 0; i < _kLookBackDays; i++)
        if (TtcLogStore.instance.valueFor(tracker.id, field.id,
                on: today.subtract(Duration(days: i)))
            case final v?)
          (today.subtract(Duration(days: i)), v.value),
    ];
    return [
      if (tracker.fields.length > 1) ...[
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(children: [
            for (final f in tracker.fields) ...[
              TtcToolPill(
                key: ValueKey('ttc_tracker_past_${f.id}'),
                label: f.label(hi),
                on: f.id == field.id,
                hue: _trackerHue(tracker),
                onTap: () => setState(() => _pastField = f.id),
              ),
              if (f != tracker.fields.last) const SizedBox(width: 8),
            ],
          ]),
        ),
        const SizedBox(height: 22),
      ],
      ttcToolPad(field.kind == TtcFieldKind.number && field.unit == 'kg'
          ? _WeightLook(tracker: tracker, field: field)
          : _LookBackStrip(tracker: tracker, field: field, hi: hi)),
      const SizedBox(height: 26),
      // Kept for revert (2026-09-29, one heading style): the same Text with
      // style: pvFraunces(fontSize: 19, fontWeight: FontWeight.w600, color: p.ink1)
      ttcToolPad(const TtcSectionHeading(kTtcTrackerEntriesTitle)),
      const SizedBox(height: 4),
      ttcToolPad(Text(
          entries.isEmpty ? kTtcTrackerEntriesEmpty : kTtcTrackerEntriesHint,
          style: pvManrope(fontSize: 12.5, height: 1.45, color: p.ink3))),
      const SizedBox(height: 8),
      for (final (d, v) in entries)
        ttcToolPad(InkWell(
          key: ValueKey('ttc_tracker_entry_${TtcLogStore.dayKey(d)}'),
          onTap: () => _openDay(d),
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration:
                BoxDecoration(border: Border(bottom: BorderSide(color: p.line))),
            child: Row(children: [
              Expanded(
                child: Text(
                    d == today ? 'Today, ${ttcRoundDate(d)}' : ttcRoundDate(d),
                    style: pvManrope(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: p.ink1)),
              ),
              Text(field.display(hi, v),
                  style: pvManrope(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: p.ink1)),
              const SizedBox(width: 6),
              Icon(Icons.chevron_right_rounded, size: 18, color: p.ink3),
            ]),
          ),
        )),
    ];
  }
}

/// The last seven days, today on the right. A dot under a day that holds
/// anything for this tracker; the chosen day in ink.
class _DayStrip extends StatelessWidget {
  const _DayStrip({
    required this.tracker,
    required this.selected,
    required this.today,
    required this.onPick,
  });

  final TtcTracker tracker;
  final DateTime selected;
  final DateTime today;
  final ValueChanged<DateTime> onPick;

  static const _letters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final logged = TtcLogStore.instance.daysLogged(tracker.id).toSet();
    return Row(children: [
      for (var i = 6; i >= 0; i--)
        Expanded(
          child: Builder(builder: (_) {
            final d = today.subtract(Duration(days: i));
            final on = d == selected;
            final has = logged.contains(TtcLogStore.dayKey(d));
            return Semantics(
              button: true,
              selected: on,
              label: '${ttcRoundDate(d)}${has ? ', has an entry' : ''}',
              excludeSemantics: true,
              onTap: () => onPick(d),
              child: GestureDetector(
                key: ValueKey('ttc_tracker_day_${TtcLogStore.dayKey(d)}'),
                behavior: HitTestBehavior.opaque,
                onTap: () => onPick(d),
                child: Column(children: [
                  Text(_letters[d.weekday - 1],
                      style: pvManrope(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: p.ink3)),
                  const SizedBox(height: 6),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 140),
                    width: 38,
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: on ? ttcTitleInk : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: on ? ttcTitleInk : ttcLine, width: 1.4),
                    ),
                    child: Text('${d.day}',
                        style: pvManrope(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: on ? Colors.white : ttcTitleInk)),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: has ? ttcTitleInk : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ]),
              ),
            );
          }),
        ),
    ]);
  }
}

/// One field for one day: its label, "Saved" and Clear, then the control.
/// The drawn mark for a field group, from the marks the stage already owns, so
/// one subject keeps one drawing. Null for a group the table does not know,
/// which then draws its name alone.
TtcTabMark? _groupMark(String name) => switch (name) {
      'Sleep' => TtcTabMark.sunrise,
      'Movement' => TtcTabMark.sprout,
      'Stress' => TtcTabMark.lotus,
      'Food' || 'Food and water' => TtcTabMark.bowl,
      'Cutting down' => TtcTabMark.flagPath,
      'Heat' => TtcTabMark.sun,
      _ => null,
    };

/// One group of a grouped tracker: a white hairline card, the group's mark and
/// name on top, its fields inside (2026-10-02).
class _GroupCard extends StatelessWidget {
  const _GroupCard({
    required this.name,
    required this.hue,
    required this.children,
  });

  final String name;
  final double hue;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final mark = _groupMark(name);
    return Container(
      key: ValueKey('ttc_group_$name'),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: p.line),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          if (mark != null) ...[
            SizedBox(
              width: 38,
              height: 38,
              child: TtcTabArt(mark: mark, tint: v2BlockTint(hue % 360, p)),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(name,
                style: pvJakarta(
                    fontSize: 16.5, fontWeight: FontWeight.w700, color: p.ink1)),
          ),
        ]),
        const SizedBox(height: 18),
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(height: 22),
          children[i],
        ],
      ]),
    );
  }
}

class _FieldBlock extends StatelessWidget {
  const _FieldBlock({
    required this.tracker,
    required this.field,
    required this.day,
    required this.t,
  });

  final TtcTracker tracker;
  final TtcField field;
  final DateTime day;
  final TtcS t;

  /// Clear, then say so with Undo: a mis-tap on "Clear" used to lose the value.
  void _clear(BuildContext context, TtcLogValue was) {
    final log = TtcLogStore.instance;
    log.clear(tracker.id, field.id, on: day);
    pvSnack(context, '${field.labelEn} cleared.',
        icon: Icons.check_rounded,
        lift: 24,
        action: 'Undo',
        onAction: () => log.log(tracker.id, field.id, was.value, on: day));
  }

  @override
  Widget build(BuildContext context) {
    final hi = t.hinglish;
    final p = V2PaletteStore.instance.current;
    final current =
        TtcLogStore.instance.valueFor(tracker.id, field.id, on: day);
    final read = field.readId == null ? null : ttcReadById(field.readId!);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(
          child: Text(field.label(hi),
              style: pvManrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                  color: p.ink1)),
        ),
        if (current != null) ...[
          Icon(Icons.check_rounded, size: 14, color: p.ink2),
          const SizedBox(width: 3),
          Text(kTtcTrackerSaved,
              style: pvManrope(
                  fontSize: 12, fontWeight: FontWeight.w700, color: p.ink2)),
          InkWell(
            key: ValueKey('ttc_tracker_clear_${field.id}'),
            onTap: () => _clear(context, current),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 2, 8),
              child: Text(t.trackerClear,
                  style: pvManrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: ttcTitleInk,
                      decoration: TextDecoration.underline)),
            ),
          ),
        ],
      ]),
      const SizedBox(height: 10),
      switch (field.kind) {
        TtcFieldKind.number => _NumberRow(
            tracker: tracker, field: field, day: day, current: current),
        TtcFieldKind.scale => _ScaleRow(
            tracker: tracker, field: field, day: day, hi: hi, current: current),
        TtcFieldKind.choice => _ChoiceWrap(
            tracker: tracker, field: field, day: day, hi: hi, current: current),
      },
      if (read != null) ...[
        const SizedBox(height: 12),
        Semantics(
          button: true,
          label: read.title.of(AppLanguage.english),
          excludeSemantics: true,
          onTap: () =>
              openTtcArticle(context, field.readId!, hue: kTtcTrackerReadHue),
          child: InkWell(
            onTap: () =>
                openTtcArticle(context, field.readId!, hue: kTtcTrackerReadHue),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: ttcLine),
              ),
              child: Row(children: [
                const Icon(Icons.article_outlined,
                    size: 16, color: ttcTitleInk),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(read.title.of(AppLanguage.english),
                      maxLines: 2,
                      style: pvManrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          height: 1.35,
                          color: ttcTitleInk)),
                ),
                Icon(Icons.chevron_right_rounded, size: 18, color: p.ink3),
              ]),
            ),
          ),
        ),
      ],
    ]);
  }
}

/// White with a hairline at rest, ink when chosen: the one selection
/// treatment every tool uses (`ttc_tool_chrome.dart`).
BoxDecoration _block(bool on) => BoxDecoration(
      color: on ? ttcTitleInk : Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: on ? ttcTitleInk : ttcLine, width: 1.4),
    );

TextStyle _blockText(bool on, {double size = 12}) => pvManrope(
    fontSize: size,
    fontWeight: on ? FontWeight.w800 : FontWeight.w600,
    color: on ? Colors.white : ttcTitleInk);

/// An ordered scale: one row, equal widths, never wrapping (see `_Segments`).
class _ScaleRow extends StatelessWidget {
  const _ScaleRow({
    required this.tracker,
    required this.field,
    required this.day,
    required this.hi,
    required this.current,
  });

  final TtcTracker tracker;
  final TtcField field;
  final DateTime day;
  final bool hi;
  final TtcLogValue? current;

  @override
  Widget build(BuildContext context) {
    final options = field.choices(hi);
    final chosen = current?.value.round();
    return Row(children: [
      for (var i = 0; i < options.length; i++) ...[
        Expanded(
          child: Semantics(
            button: true,
            selected: i == chosen,
            label: options[i],
            excludeSemantics: true,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => i == chosen
                  ? TtcLogStore.instance.clear(tracker.id, field.id, on: day)
                  : TtcLogStore.instance
                      .log(tracker.id, field.id, i.toDouble(), on: day),
              child: Container(
                height: 44,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 3),
                decoration: _block(i == chosen),
                child: Text(options[i],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: _blockText(i == chosen, size: 11.5)),
              ),
            ),
          ),
        ),
        if (i < options.length - 1) const SizedBox(width: 6),
      ],
    ]);
  }
}

/// Named choices with no order: they may wrap.
class _ChoiceWrap extends StatelessWidget {
  const _ChoiceWrap({
    required this.tracker,
    required this.field,
    required this.day,
    required this.hi,
    required this.current,
  });

  final TtcTracker tracker;
  final TtcField field;
  final DateTime day;
  final bool hi;
  final TtcLogValue? current;

  @override
  Widget build(BuildContext context) {
    final options = field.choices(hi);
    final chosen = current?.value.round();
    return Wrap(spacing: 8, runSpacing: 8, children: [
      for (var i = 0; i < options.length; i++)
        TtcToolPill(
          label: options[i],
          on: i == chosen,
          hue: _trackerHue(tracker),
          onTap: () => i == chosen
              ? TtcLogStore.instance.clear(tracker.id, field.id, on: day)
              : TtcLogStore.instance
                  .log(tracker.id, field.id, i.toDouble(), on: day),
        ),
    ]);
  }
}

/// − · the number (tap to type) · +, then the usual values in one tap.
class _NumberRow extends StatelessWidget {
  const _NumberRow({
    required this.tracker,
    required this.field,
    required this.day,
    required this.current,
  });

  final TtcTracker tracker;
  final TtcField field;
  final DateTime day;
  final TtcLogValue? current;

  void _bump(double delta) {
    // The first tap lands on `start`, whichever button it was (see _Stepper).
    final next = current != null
        ? (current!.value + delta).clamp(field.min, field.max)
        : (field.start ?? field.min);
    TtcLogStore.instance
        .log(tracker.id, field.id, (next * 10).roundToDouble() / 10, on: day);
  }

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final has = current != null;
    Widget stepButton(String label, String semantics, VoidCallback onTap) =>
        Semantics(
          button: true,
          label: semantics,
          excludeSemantics: true,
          onTap: onTap,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: _block(false),
              child: Text(label,
                  style: pvManrope(
                      fontSize: 19,
                      fontWeight: FontWeight.w600,
                      color: ttcTitleInk)),
            ),
          ),
        );

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        // Kept for revert (2026-09-28): the spoken labels were 'Less' and
        // 'More'.
        stepButton('−', 'Lower the number', () => _bump(-field.step)),
        const SizedBox(width: 10),
        Expanded(
          child: Semantics(
            button: true,
            label: has
                ? '${field.labelEn}: ${field.display(false, current!.value)}. '
                    'Tap to type'
                : '${field.labelEn}. Tap to type',
            excludeSemantics: true,
            child: GestureDetector(
              key: ValueKey('ttc_tracker_type_${field.id}'),
              behavior: HitTestBehavior.opaque,
              onTap: () => _showTypeSheet(context, tracker, field, day, current),
              child: Container(
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border:
                      Border.all(color: has ? ttcTitleInk : ttcLine, width: 1.4),
                ),
                child: has
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(_fmtNum(current!.value),
                              style: pvFraunces(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: p.ink1)),
                          if (field.unit != null) ...[
                            const SizedBox(width: 5),
                            Text(field.unit!,
                                style: pvManrope(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: p.ink2)),
                          ],
                        ],
                      )
                    : Text(
                        field.unit == null
                            ? 'Tap to type'
                            : 'Tap to type ${field.unit}',
                        style: pvManrope(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: p.ink3)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        stepButton('+', 'Raise the number', () => _bump(field.step)),
      ]),
      if (field.presets.isNotEmpty) ...[
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final v in field.presets)
            Builder(builder: (_) {
              final on = has && (current!.value - v).abs() < 1e-6;
              return TtcToolPill(
                key: ValueKey('ttc_preset_${field.id}_${_fmtNum(v)}'),
                label:
                    field.unit == null ? _fmtNum(v) : '${_fmtNum(v)} ${field.unit}',
                on: on,
                hue: _trackerHue(tracker),
                onTap: () => on
                    ? TtcLogStore.instance.clear(tracker.id, field.id, on: day)
                    : TtcLogStore.instance.log(tracker.id, field.id, v, on: day),
              );
            }),
        ]),
      ],
    ]);
  }
}

/// The severe-scale line, as a result block in the tool's own shape. Same
/// trigger and words as `_SevereNotice`: the far end of a scale, never a
/// value judged "bad".
class _SevereLine extends StatelessWidget {
  const _SevereLine(
      {required this.tracker, required this.day, required this.t});

  final TtcTracker tracker;
  final DateTime day;
  final TtcS t;

  @override
  Widget build(BuildContext context) {
    final severe = tracker.fields.any((f) {
      if (f.kind != TtcFieldKind.scale) return false;
      final v = TtcLogStore.instance.valueFor(tracker.id, f.id, on: day);
      return v != null && v.value.round() >= f.choicesEn.length - 1;
    });
    if (!severe) return const SizedBox.shrink();
    final p = V2PaletteStore.instance.current;
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: ttcTitleInk, width: 1.2),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(t.severeNoticedTitle,
              style: pvManrope(
                  fontSize: 14.5, fontWeight: FontWeight.w800, color: p.ink1)),
          const SizedBox(height: 6),
          Text(t.severeNoticedBody,
              style: pvManrope(fontSize: 13, height: 1.55, color: p.ink2)),
        ]),
      ),
    );
  }
}

/// Four weeks of weight, as a line scaled to her own range: from zero, 61 and
/// 62 kg drew the same bar.
class _WeightLook extends StatelessWidget {
  const _WeightLook({required this.tracker, required this.field});

  final TtcTracker tracker;
  final TtcField field;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final today = _dayOnly(DateTime.now());
    final data = <double?>[
      for (var i = _kLookBackDays - 1; i >= 0; i--)
        TtcLogStore.instance
            .valueFor(tracker.id, field.id,
                on: today.subtract(Duration(days: i)))
            ?.value,
    ];
    final present = data.whereType<double>().toList();
    String caption() {
      // Kept for revert (2026-09-28): 'Nothing written down here yet.'
      if (present.isEmpty) return 'No days written down yet.';
      final lo = present.reduce((a, b) => a < b ? a : b);
      final hi = present.reduce((a, b) => a > b ? a : b);
      if (lo == hi) return '${_fmtNum(lo)} kg on the days you wrote it down.';
      return 'Between ${_fmtNum(lo)} and ${_fmtNum(hi)} kg, on the days you '
          'wrote it down.';
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Kept for revert (2026-09-29, one heading style): the same Text with
      // style: pvFraunces(fontSize: 20, fontWeight: FontWeight.w600, color: p.ink1)
      TtcSectionHeading(field.labelEn),
      const SizedBox(height: 4),
      Text('Last four weeks', style: pvManrope(fontSize: 13, color: p.ink3)),
      const SizedBox(height: 16),
      SizedBox(
        height: 120,
        width: double.infinity,
        child: CustomPaint(
          key: const ValueKey('ttc_tracker_weight_line'),
          painter: _LinePainter(data: data, line: p.line),
        ),
      ),
      const SizedBox(height: 6),
      Container(height: 1, color: p.line),
      const SizedBox(height: 7),
      const _WeekLabels(),
      const SizedBox(height: 14),
      Text(caption(),
          style: pvManrope(fontSize: 13, height: 1.45, color: p.ink1)),
    ]);
  }
}

class _LinePainter extends CustomPainter {
  _LinePainter({required this.data, required this.line});

  final List<double?> data;
  final Color line;

  @override
  void paint(Canvas canvas, Size size) {
    final present = data.whereType<double>().toList();
    if (present.isEmpty) return;
    var lo = present.reduce((a, b) => a < b ? a : b);
    var hi = present.reduce((a, b) => a > b ? a : b);
    // At least a two-kilo range, so a steady weight draws a steady line
    // rather than a zig-zag of tenths.
    if (hi - lo < 2) {
      final mid = (hi + lo) / 2;
      lo = mid - 1;
      hi = mid + 1;
    }
    final grid = Paint()
      ..color = line
      ..strokeWidth = 1;
    canvas.drawLine(const Offset(0, 8), Offset(size.width, 8), grid);
    Offset at(int i, double v) => Offset(
          data.length == 1 ? size.width / 2 : i * size.width / (data.length - 1),
          8 + (1 - (v - lo) / (hi - lo)) * (size.height - 16),
        );
    final stroke = Paint()
      ..color = ttcTitleInk
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final path = Path();
    var started = false;
    for (var i = 0; i < data.length; i++) {
      final v = data[i];
      if (v == null) continue;
      final o = at(i, v);
      if (!started) {
        path.moveTo(o.dx, o.dy);
        started = true;
      } else {
        path.lineTo(o.dx, o.dy);
      }
    }
    canvas.drawPath(path, stroke);
    final dot = Paint()..color = ttcTitleInk;
    for (var i = 0; i < data.length; i++) {
      final v = data[i];
      if (v != null) canvas.drawCircle(at(i, v), 3.5, dot);
    }
  }

  @override
  bool shouldRepaint(_LinePainter old) => old.data != data;
}

/// Type a number for [day]: the tool's own sheet and Save.
Future<void> _showTypeSheet(BuildContext context, TtcTracker tracker,
        TtcField field, DateTime day, TtcLogValue? current) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      routeSettings: const RouteSettings(name: 'ttc/tracker/type'),
      builder: (_) => _TypeSheet(
          tracker: tracker, field: field, day: day, current: current?.value),
    );

class _TypeSheet extends StatefulWidget {
  const _TypeSheet({
    required this.tracker,
    required this.field,
    required this.day,
    required this.current,
  });

  final TtcTracker tracker;
  final TtcField field;
  final DateTime day;
  final double? current;

  @override
  State<_TypeSheet> createState() => _TypeSheetState();
}

class _TypeSheetState extends State<_TypeSheet> {
  late final TextEditingController _c = TextEditingController(
      text: widget.current == null ? '' : _fmtNum(widget.current!));

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _save() {
    final v = double.tryParse(_c.text.trim());
    final log = TtcLogStore.instance;
    if (v == null) {
      // A blank clears rather than writing a zero she did not enter.
      log.clear(widget.tracker.id, widget.field.id, on: widget.day);
    } else {
      log.log(widget.tracker.id, widget.field.id,
          v.clamp(widget.field.min, widget.field.max).toDouble(),
          on: widget.day);
    }
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        decoration: BoxDecoration(
          color: p.ground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(
                          color: p.line,
                          borderRadius: BorderRadius.circular(999)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(widget.field.label(TtcS.current().hinglish),
                      style: pvFraunces(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                          color: p.ink1)),
                  const SizedBox(height: 4),
                  Text('For ${ttcRoundDate(widget.day)}',
                      style: pvManrope(fontSize: 13, color: p.ink2)),
                  const SizedBox(height: 14),
                  Row(children: [
                    Expanded(
                      child: TextField(
                        key: const ValueKey('ttc_tracker_type_field'),
                        controller: _c,
                        autofocus: true,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                        ],
                        onSubmitted: (_) => _save(),
                        style: pvFraunces(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            color: p.ink1),
                        decoration: InputDecoration(
                          isDense: true,
                          filled: true,
                          fillColor: Colors.white,
                          hintText: '—',
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: ttcLine),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide:
                                const BorderSide(color: ttcTitleInk, width: 1.4),
                          ),
                        ),
                      ),
                    ),
                    if (widget.field.unit != null) ...[
                      const SizedBox(width: 12),
                      Text(widget.field.unit!,
                          style: pvManrope(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: p.ink2)),
                    ],
                  ]),
                  const SizedBox(height: 18),
                  TtcToolPrimary(
                      key: const ValueKey('ttc_tracker_type_save'),
                      // Kept for revert (2026-09-28): 'Save'
                      label: 'Save the number',
                      onTap: _save),
                ]),
          ),
        ),
      ),
    );
  }
}


// =============================================================================
//  T4 (launch sanity, 2026-09-28): one sentence of why, the rest in a sheet
// =============================================================================

/// The one sentence a tracker says above its controls, where its "why"
/// does not open with its point. Weight's opens on oestrogen, which is the
/// mechanism, not the reason. A shortening of its own text, never a new fact.
const Map<String, String> kTtcTrackerWhyLeads = {
  'weight': 'Very low or very high weight can make cycles irregular. '
      "There's no target here.",
};

/// The first sentence of a tracker's "why" (or its lead above): what the
/// page shows above its controls. The whole text opens behind "Why this
/// matters".
String ttcTrackerWhyLead(TtcTracker tracker, bool hi) {
  final why = tracker.why(hi);
  final lead = hi ? null : kTtcTrackerWhyLeads[tracker.id];
  if (lead != null) return lead;
  final text = why.trim();
  final para = text.split('\n').first.trim();
  final m = RegExp(r'^.*?[.!?](?=\s|$)').firstMatch(para);
  return (m?.group(0) ?? para).trim();
}

const String kTtcTrackerWhyLabel = 'Why this matters';

class _WhyRow extends StatelessWidget {
  const _WhyRow({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return Semantics(
      button: true,
      label: kTtcTrackerWhyLabel,
      excludeSemantics: true,
      child: InkWell(
        key: const ValueKey('ttc_tracker_why_more'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.info_outline_rounded, size: 15, color: p.ink1),
            const SizedBox(width: 6),
            // Flexible (2026-09-29): 1pt past a 360dp screen at 1.5x text.
            // Kept for revert: the Text unwrapped.
            Flexible(
              child: Text(kTtcTrackerWhyLabel,
                  style: pvManrope(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: p.ink1,
                      decoration: TextDecoration.underline)),
            ),
          ]),
        ),
      ),
    );
  }
}

/// The tracker's whole "why", in a sheet.
Future<void> showTtcTrackerWhy(
        BuildContext context, TtcTracker tracker, bool hi) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final p = V2PaletteStore.instance.current;
        return Container(
          key: const ValueKey('ttc_tracker_why_sheet'),
          constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(ctx).height * 0.8),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                          color: p.line,
                          borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(kTtcTrackerWhyLabel,
                      style: pvFraunces(
                          fontSize: 21,
                          fontWeight: FontWeight.w600,
                          color: p.ink1)),
                  const SizedBox(height: 12),
                  Text(tracker.why(hi),
                      style: pvManrope(
                          fontSize: 14, height: 1.6, color: p.ink2)),
                  const SizedBox(height: 18),
                  TtcToolPrimary(
                    label: 'Got it',
                    onTap: () => Navigator.of(ctx).maybePop(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

// =============================================================================
//  T1/T2 (launch sanity, 2026-09-28): BMI folded into the Weight page
// =============================================================================

/// Her BMI when she has worked one out, else an invitation to. Opens the BMI
/// screen, which fills her height and her latest weight in for her.
class TtcWeightBmiRow extends StatefulWidget {
  const TtcWeightBmiRow({super.key});

  @override
  State<TtcWeightBmiRow> createState() => _TtcWeightBmiRowState();
}

class _TtcWeightBmiRowState extends State<TtcWeightBmiRow> {
  @override
  void initState() {
    super.initState();
    TtcBmiStore.instance.load();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: TtcBmiStore.instance,
        builder: (context, _) {
          final p = V2PaletteStore.instance.current;
          final last = TtcBmiStore.instance.latest;
          final title = last == null
              ? 'Work out your BMI'
              : 'Your BMI: ${last.bmi.toStringAsFixed(1)}';
          final line = last == null
              ? "What BMI does and doesn't tell you, from your height and "
                  'weight. We fill in what you have logged.'
              : '${categoriseBmi(last.bmi, kBmiPrimaryStandard).label.en}, '
                  'from ${ttcToolDate(last.at)}. Tap to work it out again '
                  'or see what it means.';
          return Semantics(
            button: true,
            label: title,
            child: Material(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: p.line)),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                key: const ValueKey('ttc_weight_bmi_row'),
                onTap: () => openTtcSurface(context, 'ttc_bmi'),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
                  child: Row(children: [
                    Icon(Icons.straighten_rounded, size: 20, color: p.ink1),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title,
                              style: pvManrope(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: p.ink1)),
                          const SizedBox(height: 3),
                          Text(line,
                              style: pvManrope(
                                  fontSize: 12.5,
                                  height: 1.45,
                                  color: p.ink2)),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: p.ink3),
                  ]),
                ),
              ),
            ),
          );
        },
      );
}
