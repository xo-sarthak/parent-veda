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
import 'ttc_common.dart';
import 'ttc_focus_screen.dart' show openTtcArticle;
import 'ttc_strings.dart';

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

/// A bar's body. `hsl(104 32% 90%)`.
const Color _kBar = Color(0xFFE2EEDD);

/// A bar's cap and a matrix dot's edge. `hsl(104 26% 44%)`.
const Color _kBarCap = Color(0xFF548D46);

/// A matrix dot's fill. `hsl(104 32% 88%)`.
const Color _kDot = Color(0xFFDDEBD8);

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

class TtcTrackerScreen extends StatefulWidget {
  const TtcTrackerScreen({super.key, required this.tracker});

  final TtcTracker tracker;

  @override
  State<TtcTrackerScreen> createState() => _TtcTrackerScreenState();
}

class _TtcTrackerScreenState extends State<TtcTrackerScreen> {
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
              _Header(
                crumb: _lookBack ? 'TODAY' : 'GETTING READY',
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
                child: Text('Look back',
                    style: pvManrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _kGreenInk)),
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
    final blocks = <(String?, List<TtcField>)>[];
    for (final f in tracker.fields) {
      if (blocks.isEmpty || blocks.last.$1 != f.group) {
        blocks.add((f.group, [f]));
      } else {
        blocks.last.$2.add(f);
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
                Text('Write down as much or as little as you like. One thing '
                    'is enough.',
                    style: ttcBody(14, color: ttcInk, h: 1.55)),

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
      if (field.kind == TtcFieldKind.number)
        _Stepper(tracker: tracker, field: field, current: current)
      else
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
              color: ttcPanel,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(children: [
              Icon(Icons.article_outlined, size: 14, color: _kGreenInk),
              const SizedBox(width: 8),
              Expanded(
                child: Text(read.title.of(AppLanguage.english),
                    maxLines: 2,
                    style: ttcBody(12.5,
                        color: _kGreenInk, w: FontWeight.w700, h: 1.4)),
              ),
              const SizedBox(width: 6),
              Icon(Icons.chevron_right_rounded, size: 17, color: _kGreenInk),
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
      Text(field.label(hi),
          style: ttcFraunces(20, w: FontWeight.w600, color: ttcTitleInk)),
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
      Text('A blank space is a day you did not write anything down.',
          style: ttcBody(13, color: ttcMuted, h: 1.45)),
    ]);
  }

  String _caption(List<double> present, bool bars) {
    if (present.isEmpty) return 'Nothing written down here yet.';
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
                    const SizedBox(height: 8),
                    Text('Leave it blank to clear it.',
                        style: ttcBody(12, color: ttcMuted)),
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
                          child: Text('Save',
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
