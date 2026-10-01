// =============================================================================
//  Pre-Pregnancy Checklist — the list
// -----------------------------------------------------------------------------
//  V3 language throughout: `V2PaletteStore`, `pv_fonts`, hairlines not shadows,
//  flat tint not gradient — matching `PvReaderScreen`, `TtcVaccinesScreen` and
//  the PCOS checker.
//
//  ⚠️ NOT A SPREADSHEET AND NOT A COMPLIANCE FORM. Sections are collapsed to a
//  heading and a count; a card opens to show why it matters, what to do, and
//  the four status choices. Twenty-two rows rendered flat would be the medical
//  intake this brief exists to refuse.
//
//  ⚠️ THE PROGRESS RING MEASURES HER LIST, NOT HER HEALTH. "8 of 12 you are
//  tracking" — never a percentage, never "82% ready", and items she marks not
//  relevant leave the denominator so opting out cannot make her look
//  incomplete.
//
//  ---------------------------------------------------------------------------
//  ⚠️ ONE TAP ON THE ROW MARKS IT DONE (tool rebuild, 2026-09-27)
//  ---------------------------------------------------------------------------
//
//  Marking an item took two taps and a scroll: open the section, open the
//  item, find the four chips under its heading. Every checklist on Mobbin that
//  does this job puts the mark on the closed row: Tiimo's to-do rows and
//  Recime's grocery sections (a circle or box at the row's edge, one tap),
//  CVS Health's visit checklist (a status tag on each closed card). So the
//  circle at the start of every row is now a button: one tap marks it done,
//  a second tap takes it off (with Undo). The rest of the row still opens the
//  item for the reading and the other answers ("Need to do", "Not sure",
//  "Not relevant to me").
//
//  Inside an item the four answers are the tool chrome's blocks (two by two,
//  tap the chosen one to clear it), and "I talked to my doctor about this" is
//  a ticked block, not a Material checkbox in the retired purple. Purple is
//  gone from the rows too: "Core", the evidence line and the done mark are
//  ink, as on every other tool.
//
//  Mobbin: Tiimo To-do https://mobbin.com/screens/ba406c22-9856-462f-b3b4-d1a815fa71ac ;
//  Recime Grocery List https://mobbin.com/screens/c7692449-3f88-4ae5-9ca6-7d33d7bdf0bc ;
//  CVS Health Visit checklist https://mobbin.com/screens/387b81ad-b6ed-483c-88d5-5cf2384388b5 ;
//  Target Checklist (sections with "0/12 complete")
//  https://mobbin.com/screens/5c2bd4eb-0deb-413f-976c-133844fe32e1 . Gap
//  analysis: What to Expect's "Countdown to conception" is covered by this
//  list and "The three months before" ("we already have this").
//
//  ---------------------------------------------------------------------------
//  ⚠️ A TOOL, NOT A PAGE OF TEXT (rebuild, 2026-09-29)
//  ---------------------------------------------------------------------------
//
//  The user on build 20: the tools "just look like big blobs of text". The
//  list was ten bordered boxes, each opening into rows, each opening into
//  paragraphs, so the first view was ten headings and ten blurbs. Now, top to
//  bottom (Mobbin references in `ttc_precheck_parts.dart`):
//
//    · a ring and "5 of 21 done" that move as she ticks, with what the app
//      already knows folded under it;
//    · "Your next 3 steps", numbered, each with its reason, and a tap opens
//      that item in the list (the summary page became "Notes for my doctor");
//    · every section drawn flat under the one section heading, its items as
//      tickable rows: one tap on the circle, the tier as a tag, and the tick
//      the app made from her own records tagged "From your supplements";
//    · an item opens in place, answers first, then why, what to do, the
//      question for her doctor on its own card, and rows with drawn marks to
//      the tool or read that helps;
//    · what was already settled when she opened the list folds away under
//      "Done · N" and "Not relevant to me · N". A tick made on this visit
//      stays where it was until she leaves (Things 3's rule), so a slip is
//      seen and undone in place.
//
//  Every item, its tier, why, what to do, doctor question, evidence line,
//  links and the disclaimer are unchanged; only presentation moved.
// =============================================================================

import 'package:flutter/material.dart';

// Kept for revert (2026-09-27): only the old lists' bottom padding read
// `kAskFabReserve`; `TtcToolScaffold`'s sheet clears the reserve itself.
// import '../../widgets/global_ask_fab.dart';

import '../../localization/app_language.dart';
import '../../theme/pv_fonts.dart';
import '../../ttc/ttc_precheck_data.dart';
import '../../ttc/ttc_precheck_rules.dart';
import '../../ttc/ttc_precheck_store.dart';
import '../../ttc/ttc_reads_data.dart' show ttcReadTitle;
import '../../ttc/ttc_store.dart' show TtcStore;
import '../products/pv_store_chrome.dart' show pvSnack;
import '../v2/v2_palette.dart';
import 'ttc_common.dart' show ttcTitleInk;
import 'doors/ttc_tab_art.dart' show TtcTabMark;
import 'ttc_common.dart' show TtcSectionHeading, ttcLine, ttcSectionTitle;
import 'ttc_practice_card_parts.dart' show TtcInkPill;
import 'ttc_precheck_parts.dart';
import 'ttc_precheck_summary.dart';
import 'ttc_strings.dart';
import 'ttc_surface_router.dart';
import 'ttc_tool_chrome.dart';
import 'ttc_tool_hues.dart';
import 'ttc_tool_marks.dart';

/// Getting ready is 104 on the wheel — the tool keeps its door's colour.
// ⚠️ READ FROM THE TOOLS GROUP (2026-09-29): "Plan and check" is 104 too, and
// the header's hue is the group's by rule (`ttc_tool_hues.dart`), so it reads
// the constant rather than repeating the number. Kept for revert:
// const double kPrecheckHue = 104;
const double kPrecheckHue = kTtcToolHuePlan;

/// Days in the stage after which the checklist says "while you try".
const int kPrecheckWhileTryingDays = 30;

String ttcPrecheckTitle() =>
    (TtcStore.instance.daysTrying ?? 0) >= kPrecheckWhileTryingDays
        ? 'Things to sort out while you try'
        : 'Things to sort out before trying';

class TtcPrecheckScreen extends StatefulWidget {
  const TtcPrecheckScreen({super.key, this.openSection});

  /// Which section to land on, expanded, skipping the intro.
  ///
  /// ⚠️ EXISTS SO A DOOR CAN POINT AT THE PART OF THE CHECKLIST IT PROMISED.
  /// The Getting-ready journey's "habits worth building" step wants the
  /// Lifestyle section specifically — dropping her at the top of a
  /// twenty-two-item list and expecting her to find it is the arrival problem
  /// the male-fertility door already had once.
  final PrecheckSection? openSection;

  @override
  State<TtcPrecheckScreen> createState() => _TtcPrecheckScreenState();
}

class _TtcPrecheckScreenState extends State<TtcPrecheckScreen> {
  bool _started = false;
  final Set<String> _openItems = {};

  /// One key per item row, so a step chosen on "My next 3 steps" can be
  /// scrolled to when she comes back to the list (2026-09-27).
  final Map<String, GlobalKey> _itemKeys = {};
  late final Set<PrecheckSection> _openSections = {
    widget.openSection ?? PrecheckSection.folate,
  };

  /// One key per section, so a door that names a section lands on it
  /// (2026-09-29: the sections are all drawn now, so landing is a scroll).
  final Map<PrecheckSection, GlobalKey> _sectionKeys = {};

  /// Items already settled (done, or not relevant) when she opened the list.
  ///
  /// ⚠️ A SNAPSHOT, TAKEN ONCE. These fold away under "Done · N". An item she
  /// ticks on THIS visit stays in its section, ticked, until she leaves:
  /// Things 3's rule, and the reason is the slip. A row that jumps to the
  /// foot of the page the moment it is tapped takes the mistake with it, and
  /// the undo has to be found somewhere else.
  Set<String>? _settledAtOpen;

  /// "Your next 3 steps", chosen once when she opens the list.
  ///
  /// ⚠️ EACH ITEM IS DRAWN ONCE (no-repetition sweep, 2026-09-29). The steps
  /// ARE the rows: a step's item is drawn in the steps card, tickable and
  /// openable, and not again in its section. And it stays where it is for
  /// the visit, ticked or not, by the same rule as `_settledAtOpen`: a row
  /// that leaves the card the moment it is ticked takes the slip with it.
  /// The next visit chooses again.
  List<PrecheckPriority>? _stepsAtOpen;

  Set<String> get _stepIds => {
    for (final x in _stepsAtOpen ?? const <PrecheckPriority>[]) x.item.id,
  };

  /// Which folds are open: 'done', 'notRelevant', 'known'.
  final Set<String> _openFolds = {};

  TtcPrecheckStore get _store => TtcPrecheckStore.instance;

  bool _settled(PrecheckStatus s) =>
      s == PrecheckStatus.done || s == PrecheckStatus.notRelevant;

  /// True when an item is drawn in a fold rather than in its section.
  bool _folded(PrecheckItem i, PrecheckContext c) =>
      (_settledAtOpen?.contains(i.id) ?? false) &&
      _settled(_store.statusOf(i.id, c));

  @override
  void initState() {
    super.initState();
    _store.load().then((_) async {
      if (!mounted) return;
      _store.markOpened();
      // The previous visit, for the "since you were last here" line.
      await _store.beginVisit();
      if (!mounted) return;
      // A door that named a section has already made the decision the intro
      // exists to prompt.
      // ⚠️ NO INTRO SCREEN ANY MORE (tools pass, 2026-09-27). It was one
      // extra screen before anything happened; its framing and its "what
      // you've already done" lines now head the list, so the first tap is a
      // real item. `_intro` stays below, unreached. Kept for revert:
      // setState(() => _started = _store.everOpened || widget.openSection != null);
      final c = PrecheckContext.gather();
      setState(() {
        _started = true;
        _settledAtOpen = {
          for (final i in kPrecheckVisibleItems)
            if (_settled(_store.statusOf(i.id, c))) i.id,
        };
        _stepsAtOpen = _store.priorities(c);
      });
      // A door that named a section: scroll to it (2026-09-29). If every
      // item in it was already settled, open the folds that hold them.
      final s = widget.openSection;
      if (s != null) {
        final all = precheckItemsIn(s);
        if (all.isNotEmpty && all.every((i) => _folded(i, c))) {
          setState(() => _openFolds.addAll(const ['done', 'notRelevant']));
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final ctx = _sectionKeys[s]?.currentContext;
          if (ctx != null && ctx.mounted) {
            Scrollable.ensureVisible(
              ctx,
              duration: const Duration(milliseconds: 300),
              alignment: 0.05,
            );
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        _store,
        V2PaletteStore.instance,
        TtcLang.instance,
      ]),
      builder: (context, _) {
        final p = V2PaletteStore.instance.current;
        final hi = TtcLang.instance.hinglish;
        final lang = hi ? AppLanguage.hinglish : AppLanguage.english;
        String t(String en, String hin) => hi ? hin : en;

        final c = PrecheckContext.gather();

        // ⚠️ ONE SHELL FOR EVERY TOOL (2026-09-27). This was a white page
        // under a "GETTING READY" crumb, which named a door rather than the
        // page, beside tools that all wear `TtcToolScaffold`. "ParentVeda is
        // one app... we cannot be having same things represented as
        // different." Only the shell and chrome changed: the eyebrow is the
        // Tools tile's name, the list's title and how-it-works line are the
        // hero, "My next 3 steps" keeps its top-right place as the hero's
        // one action, and the sections sit in the sheet unchanged.
        // Kept for revert (2026-09-27):
        // return Scaffold(
        //   backgroundColor: p.ground,
        //   body: SafeArea(
        //     bottom: false,
        //     child: Column(children: [
        //       _bar(p, t),
        //       Expanded(
        //         child: !_started
        //             ? _intro(p, t, c)
        //             : _list(p, lang, t, c),
        //       ),
        //     ]),
        //   ),
        // );
        return TtcToolScaffold(
          hue: kPrecheckHue,
          // The tool's mark over the eyebrow (2026-09-29, ttc_tool_marks.dart).
          toolId: 'precheck',
          // ⚠️ ONE TOOL, ONE NAME: the Tools tile's name, word for word.
          eyebrow: 'Pre-pregnancy checklist',
          // ---- WHAT THIS IS, FIRST (tools pass, 2026-09-27) ---------------
          // ⚠️ BY WHERE SHE IS (2026-09-30, tools review, fix B): "before
          // trying" is wrong for someone 43 days in. The app has no "actively
          // trying" flag, only how long she has been in the stage (or her own
          // answer, which sets the same start), so from kPrecheckWhileTryingDays
          // on it says "while you try". Derived, never asked. Kept for revert:
          // 'Things to sort out before trying'.
          title: ttcPrecheckTitle(),
          // Says the one-tap mark (2026-09-27). Kept for revert:
          // 'Open an item to read why it matters and mark where you '
          // 'are. It saves as you tap. You only need what fits you.'
          // Shorter (2026-09-29): the list itself now shows how it works.
          // Kept for revert:
          // intro: 'Tap the circle when something is done. Open an item to '
          //     'read why it matters or pick another answer. It saves as you '
          //     'tap. You only need what fits you.',
          intro:
              'Tick what is done. Open any item for why it matters and '
              'what to do. It saves as you tap, and you only need what fits '
              'you.',
          // ⚠️ NO HERO PILL (2026-09-29). "My next 3 steps" is a card at the
          // top of the list now, and its pill opens "Notes for my doctor".
          // The same words in the hero and in the card would be the page
          // saying one thing twice. Kept for revert:
          // action: _started ? _stepsLink(p, t) : null,
          children: [
            ttcToolPad(
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 22),
                  // Kept for revert (2026-09-29):
                  // ...(!_started ? _intro(p, t, c) : _list(p, lang, t, c)),
                  // (Nothing before the store has loaded: the intro screen
                  // was retired on 2026-09-27 and only flashed here.)
                  if (_started) ..._listV2(p, lang, t, c),
                  const SizedBox(height: 26),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// The one route to the summary, top right of the hero where the old bar
  /// carried it. White with a hairline and ink words: the tool chrome's
  /// treatment, not the purple link it was.
  // ⚠️ FLEXIBLE (2026-09-29): at 1.5x text on a 360dp screen the pill ran
  // 27pt past the header's edge. It sits straight in the scaffold's action
  // Row, so it may flex (the day picker's action does the same with
  // Expanded), and its words shrink to fit. Kept for revert: the
  // GestureDetector returned bare.
  // ignore: unused_element
  Widget _stepsLink(V2Palette p, String Function(String, String) t) =>
      Flexible(child: _stepsPill(p, t));

  Widget _stepsPill(V2Palette p, String Function(String, String) t) =>
      GestureDetector(
        key: const ValueKey('ttc_precheck_next_steps'),
        onTap: _openSummary,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: ttcLine),
          ),
          // Named for what it opens (2026-09-27). Kept for revert:
          // t('Summary', 'Summary').
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              t('My next 3 steps', 'Summary'),
              style: pvManrope(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: ttcTitleInk,
              ),
            ),
          ),
        ),
      );

  // Kept for revert (2026-09-27): the old back bar with its "GETTING READY"
  // crumb and the purple "My next 3 steps" link. `TtcToolScaffold`'s close
  // button and `_stepsLink` replace it.
  // ignore: unused_element
  Widget _bar(V2Palette p, String Function(String, String) t) => Padding(
    padding: const EdgeInsets.fromLTRB(8, 4, 16, 6),
    child: Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).maybePop(),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(Icons.arrow_back_rounded, size: 21, color: p.ink1),
          ),
        ),
        Expanded(
          child: Text(
            t('GETTING READY', 'TAIYAARI').toUpperCase(),
            style: pvManrope(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: p.ink3,
            ),
          ),
        ),
        if (_started)
          GestureDetector(
            onTap: _openSummary,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(8),
              // Named for what it opens (2026-09-27). It is now the one
              // route to the summary: the button at the foot of the list is
              // kept for revert below. Kept for revert: t('Summary', 'Summary').
              child: Text(
                t('My next 3 steps', 'Summary'),
                style: pvManrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: p.action,
                ),
              ),
            ),
          ),
      ],
    ),
  );

  // ---------------------------------------------------------------------------
  //  Intro
  // ---------------------------------------------------------------------------

  // The stages hand their blocks to the tool sheet now (2026-09-27), so each
  // returns a list rather than its own ListView.
  // Unreached since 2026-09-27; kept for revert.
  // ignore: unused_element
  List<Widget> _intro(
    V2Palette p,
    String Function(String, String) t,
    PrecheckContext c,
  ) {
    final known = _knownLines(t, c);
    // Kept for revert (2026-09-27):
    // return ListView(
    //   padding: const EdgeInsets.fromLTRB(20, 8, 20, kAskFabReserve + 24),
    //   children: [
    return <Widget>[
      Text(
        t(
          "Getting ready doesn't have to mean doing everything.",
          'Taiyaari ka matlab sab kuch karna nahi hota.',
        ),
        style: pvFraunces(
          fontSize: 29,
          height: 1.18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4,
          color: p.ink1,
        ),
      ),
      const SizedBox(height: 14),
      Text(
        t(
          'A few checks before you start can make the early weeks '
              "easier. Here you'll see what you've already covered, and "
              'what may be worth talking about with a doctor.',
          'Shuru karne se pehle kuch soch-samajh kar ki gayi jaanch, '
              'shuruaati hafton ko aasaan bana deti hai. Ye dikhata hai ki '
              'kya ho chuka hai aur kis par baat karna baaki hai.',
        ),
        style: pvFraunces(fontSize: 16.5, height: 1.58, color: p.ink2),
      ),
      const SizedBox(height: 20),

      // ---- WHAT THE APP ALREADY KNOWS -----------------------------------
      //
      // ⚠️ THE REASON THIS IS NOT A GENERIC CHECKLIST. Opening by telling her
      // what she has already done is the difference between a companion and
      // a health-site listicle. If it knows nothing yet, it says nothing —
      // an empty "based on your data" box is worse than no box.
      if (known.isNotEmpty) ...[
        Container(
          padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
          decoration: BoxDecoration(
            color: v2BlockTint(kPrecheckHue, p),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t("WHAT YOU'VE ALREADY DONE", 'JO AAP PEHLE HI KAR CHUKI HAIN'),
                style: pvManrope(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: const Color(0xFF2E3A2C),
                ),
              ),
              const SizedBox(height: 10),
              for (final l in known)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_rounded,
                        size: 15,
                        color: const Color(0xFF3D4A38),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          l,
                          style: pvManrope(
                            fontSize: 14,
                            height: 1.5,
                            color: const Color(0xFF31402D),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],

      Text(
        t(
          "You don't need a perfect checklist. You just need to know "
              'what matters for you.',
          'Aapko perfect checklist ki zaroorat nahi. Bas ye pata hona '
              'chahiye ki aapke liye kya maayne rakhta hai.',
        ),
        style: pvFraunces(
          fontSize: 17,
          height: 1.55,
          fontWeight: FontWeight.w500,
          color: p.ink1,
        ),
      ),
      const SizedBox(height: 24),

      _Button(
        p: p,
        label: _store.everOpened
            ? t('Continue your checklist', 'Apni checklist jaari rakhein')
            : t('Start my checklist', 'Meri checklist shuru karein'),
        onTap: () => setState(() => _started = true),
      ),
      const SizedBox(height: 16),
      Text(
        kPrecheckDisclaimer.en,
        style: pvManrope(fontSize: 12, height: 1.6, color: p.ink3),
      ),
    ];
    // Kept for revert (2026-09-27): the ListView's closing `],\n );`.
  }

  List<String> _knownLines(
    String Function(String, String) t,
    PrecheckContext c,
  ) {
    final out = <String>[];
    if (c.loggedCycles >= 2) {
      out.add(
        t(
          'You\'ve logged ${c.loggedCycles} cycles, so cycle tracking is '
              'already covered.',
          'Aapne ${c.loggedCycles} cycles log kiye hain — cycle tracking ho '
              'chuki hai.',
        ),
      );
    }
    if (c.ranPcosCheck) {
      out.add(
        t("You've done the PCOS check.", 'Aapne PCOS check kar liya hai.'),
      );
    }
    if (c.supplementCount > 0) {
      out.add(
        t(
          'You\'ve noted ${c.supplementCount} supplements.',
          'Aapne ${c.supplementCount} supplements darj kiye hain.',
        ),
      );
    }
    if (c.medicineCount > 0) {
      out.add(
        t(
          'You\'ve saved ${c.medicineCount} medicines. They\'re worth '
              'reviewing with a doctor before pregnancy.',
          'Aapne ${c.medicineCount} dawaiyan save ki hain — pregnancy se pehle '
              'review karwane layak.',
        ),
      );
    }
    if (c.vaccinesRecorded > 0) {
      out.add(
        t(
          "You've started your vaccine list.",
          'Aapne vaccination list shuru kar di hai.',
        ),
      );
    }
    return out;
  }

  // ---------------------------------------------------------------------------
  //  The list
  // ---------------------------------------------------------------------------

  // Kept for revert (2026-09-29): the list of collapsible section boxes.
  // `_listV2` below draws the rebuilt tool.
  // ignore: unused_element
  List<Widget> _list(
    V2Palette p,
    AppLanguage lang,
    String Function(String, String) t,
    PrecheckContext c,
  ) {
    final counts = _store.counts(c);
    final sections = ttcVisiblePrecheckSections;

    final known = _knownLines(t, c);
    final marked = sections
        .expand(precheckItemsIn)
        .where((i) => _store.statusOf(i.id, c) != PrecheckStatus.untouched)
        .length;

    // Kept for revert (2026-09-27): the list's own ListView, and its title
    // and how-it-works line, which are the tool hero's title and intro now.
    // return ListView(
    //   padding: const EdgeInsets.fromLTRB(20, 4, 20, kAskFabReserve + 24),
    //   children: [
    //     Text('Things to sort out before trying',
    //         style: pvFraunces(
    //             fontSize: 25,
    //             height: 1.2,
    //             fontWeight: FontWeight.w600,
    //             letterSpacing: -0.3,
    //             color: p.ink1)),
    //     const SizedBox(height: 8),
    //     Text(
    //         'Open an item to read why it matters and mark where you are. '
    //         'It saves as you tap. You only need what fits you.',
    //         style: pvManrope(fontSize: 14, height: 1.55, color: p.ink2)),
    //     const SizedBox(height: 10),
    return <Widget>[
      // The tier key, once, the first time the labels appear. One line since
      // 2026-09-30 (only Core is tagged).
      Text(
        'Core: most people should do this.',
        style: pvManrope(fontSize: 12, height: 1.5, color: p.ink3),
      ),
      if (known.isNotEmpty) ...[
        const SizedBox(height: 14),
        for (final l in known)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ink, not the retired purple (2026-09-27).
                Icon(Icons.check_rounded, size: 15, color: p.ink1),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l,
                    style: pvManrope(fontSize: 13, height: 1.5, color: p.ink2),
                  ),
                ),
              ],
            ),
          ),
      ],
      const SizedBox(height: 18),
      // ⚠️ NO COUNT UNTIL SHE HAS MARKED SOMETHING (2026-09-27). "0 of 21
      // are done" before a single tap read like a debt. Kept for revert:
      // _CountBar(p: p, t: t, counts: counts), shown always.
      if (marked > 0) ...[
        _CountBar(p: p, t: t, counts: counts, marked: marked),
        const SizedBox(height: 24),
      ],

      for (var si = 0; si < sections.length; si++) ...[
        _section(p, lang, t, c, sections[si]),
        const SizedBox(height: 12),

        // ⚠️ THE EDITORIAL BEAT, AFTER THE FIRST SECTION. Not labelled a tip
        // or an insight — §26. It is there to break the rhythm of a list
        // before the list becomes a chore.
        // ⚠️ COMMENTED OUT 2026-09-27 (tools pass, simplicity): a line
        // about "the next chapter" between two sections made her ask why it
        // was there. Kept for revert below.
        // if (si == 0) ...[
        //   const SizedBox(height: 10),
        //   Padding(
        //     padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
        //     child: Text(kPrecheckPatternBreak.of(lang),
        //         style: pvFraunces(
        //             fontSize: 17.5,
        //             height: 1.6,
        //             fontWeight: FontWeight.w500,
        //             color: p.ink2)),
        //   ),
        //   const SizedBox(height: 12),
        // ],
      ],

      // The second route to the same summary, kept for revert (2026-09-27):
      // the top bar's "My next 3 steps" is the one route now.
      // const SizedBox(height: 14),
      // _Button(
      //   p: p,
      //   label: t('See my next 3 steps', 'Mere agle 3 kadam dekhein'),
      //   onTap: _openSummary,
      // ),
      const SizedBox(height: 18),
      Text(
        kPrecheckDisclaimer.en,
        style: pvManrope(fontSize: 12, height: 1.6, color: p.ink3),
      ),
    ];
    // Kept for revert (2026-09-27): the ListView's closing `],\n );`.
  }

  // Kept for revert (2026-09-29), with `_list`.
  Widget _section(
    V2Palette p,
    AppLanguage lang,
    String Function(String, String) t,
    PrecheckContext c,
    PrecheckSection s,
  ) {
    final items = precheckItemsIn(s);
    if (items.isEmpty) return const SizedBox.shrink();
    final open = _openSections.contains(s);
    final done = items
        .where((i) => _store.statusOf(i.id, c) == PrecheckStatus.done)
        .length;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: p.line),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(
              () => open ? _openSections.remove(s) : _openSections.add(s),
            ),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 15, 13, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.title.of(lang),
                          style: pvFraunces(
                            fontSize: 17.5,
                            height: 1.3,
                            fontWeight: FontWeight.w600,
                            color: p.ink1,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          s.blurb.of(lang),
                          style: pvManrope(
                            fontSize: 13,
                            height: 1.5,
                            color: p.ink3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    children: [
                      Text(
                        '$done/${items.length}',
                        style: pvManrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: p.ink3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Icon(
                        open
                            ? Icons.expand_less_rounded
                            : Icons.expand_more_rounded,
                        size: 20,
                        color: p.ink3,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (open)
            for (final item in items) _itemTile(p, lang, t, c, item),
        ],
      ),
    );
  }

  Widget _itemTile(
    V2Palette p,
    AppLanguage lang,
    String Function(String, String) t,
    PrecheckContext c,
    PrecheckItem item,
  ) {
    final open = _openItems.contains(item.id);
    final status = _store.statusOf(item.id, c);
    final evidence = precheckEvidenceFor(item, c);
    final entry = _store.entryFor(item.id);

    return Container(
      key: _itemKeys.putIfAbsent(item.id, GlobalKey.new),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: p.line)),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(
              () => open ? _openItems.remove(item.id) : _openItems.add(item.id),
            ),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 13, 15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ⚠️ THE MARK IS A BUTTON (2026-09-27). See the file header.
                  // Kept for revert: `_StatusDot(p: p, status: status),` with 12
                  // after it, and no tap of its own.
                  _DoneButton(
                    key: ValueKey('ttc_precheck_${item.id}_mark'),
                    p: p,
                    status: status,
                    title: item.title.of(lang),
                    onTap: () => _toggleDone(item, status, lang),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title.of(lang),
                          style: pvJakarta(
                            fontSize: 15,
                            height: 1.35,
                            fontWeight: FontWeight.w700,
                            color: p.ink1,
                          ),
                        ),
                        // ⚠️ ONLY "CORE" IS SAID (2026-09-30, tools review,
                        // fix C): 21 rows each carried a tier word and only
                        // one tier is worth knowing. "Worth doing" and
                        // "Helpful if it applies" are not shown; the status
                        // still is. Kept for revert: the tier word on every
                        // row, always.
                        if (item.tier == PrecheckTier.core ||
                            status != PrecheckStatus.untouched) ...[
                        const SizedBox(height: 5),
                        // A Wrap, not a Row (2026-09-27): "Helpful if it
                        // applies · Not relevant to me" ran off a 360dp row.
                        Wrap(
                          children: [
                            if (item.tier == PrecheckTier.core)
                            Text(
                              item.tier.label.of(lang),
                              style: pvManrope(
                                fontSize: 11,
                                // Ink, not purple (2026-09-27). Kept for
                                // revert: `? p.action`.
                                fontWeight: item.tier == PrecheckTier.core
                                    ? FontWeight.w800
                                    : FontWeight.w700,
                                color: item.tier == PrecheckTier.core
                                    ? p.ink1
                                    : p.ink3,
                              ),
                            ),
                            if (status != PrecheckStatus.untouched) ...[
                              if (item.tier == PrecheckTier.core)
                              Text(
                                '  ·  ',
                                style: pvManrope(fontSize: 11, color: p.ink3),
                              ),
                              Text(
                                // The item's own word for the answer she gave
                                // (2026-09-30). Kept for revert:
                                // status.label.of(lang).
                                precheckAskFor(item.id).labelFor(status),
                                style: pvManrope(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: p.ink2,
                                ),
                              ),
                            ],
                          ],
                        ),
                        ],
                        // ⚠️ EVIDENCE, SHOWN EVEN WHEN COLLAPSED. It is the most
                        // useful line on the card and the one that proves the app
                        // has been paying attention.
                        if (evidence != null) ...[
                          const SizedBox(height: 7),
                          Text(
                            evidence.of(lang),
                            // Ink, not purple (2026-09-27). Kept for revert:
                            // color: p.action.
                            style: pvManrope(
                              fontSize: 12.5,
                              height: 1.5,
                              fontWeight: FontWeight.w600,
                              color: p.ink2,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(
                      open ? Icons.remove_rounded : Icons.add_rounded,
                      size: 19,
                      color: p.ink3,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (open)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ⚠️ WHERE SHE IS, FIRST (tools pass, 2026-09-27). Marking
                  // an item is what she opened it for, and the chips sat under
                  // three blocks of reading. Kept for revert: the chips came
                  // after WHY IT MATTERS, WHAT TO DO and ASK YOUR DOCTOR.
                  // ⚠️ THE ITEM'S OWN QUESTION (2026-09-30, the user: "for
                  // every drop down the same question with the same
                  // options"). Kept for revert: 'WHERE YOU ARE' in small
                  // capitals over "Done / Need to do / Not sure / Not
                  // relevant to me" on every item.
                  Text(
                    precheckAskFor(item.id).question,
                    key: ValueKey('ttc_precheck_${item.id}_ask'),
                    style: pvManrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      height: 1.35,
                      color: p.ink1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // ⚠️ THE TOOL CHROME'S BLOCKS, TWO BY TWO (2026-09-27), the
                  // answer control every other tool uses, and the chosen one
                  // taps off again (back to "not looked at"). Kept for revert:
                  // a Wrap of four `_StatusChip`s that could not be cleared.
                  TtcToolOptions(
                    p: p,
                    hue: kPrecheckHue,
                    items: [
                      for (final s in const [
                        PrecheckStatus.done,
                        PrecheckStatus.needsAttention,
                        PrecheckStatus.notSure,
                        PrecheckStatus.notRelevant,
                      ])
                        TtcToolOption(
                          // The item's own words for the same four answers
                          // (2026-09-30). Kept for revert: s.label.of(lang).
                          label: precheckAskFor(item.id).labelFor(s),
                          on: status == s,
                          onTap: () => _store.setStatus(
                            item.id,
                            status == s ? PrecheckStatus.untouched : s,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  // Kept for revert (2026-09-28): 'WHY IT MATTERS'
                  _field(
                    p,
                    t('WHY THIS STEP MATTERS', 'KYUN MAAYNE RAKHTA HAI'),
                    item.why.of(lang),
                  ),
                  _field(
                    p,
                    t('WHAT TO DO', 'KYA KARNA HAI'),
                    item.whatToDo.of(lang),
                  ),
                  if (item.askDoctor != null)
                    _field(
                      p,
                      t('ASK YOUR DOCTOR', 'DOCTOR SE POOCHHEIN'),
                      '"${item.askDoctor!.of(lang)}"',
                    ),

                  // (WHERE YOU ARE moved to the top of the item, 2026-09-27.)

                  // ⚠️ A SEPARATE FLAG, NOT A FIFTH STATUS. "I have started
                  // folic acid" and "a pharmacist confirmed my dose" are
                  // different facts, and on a core medical item the second is
                  // the one that matters.
                  // ⚠️ A TICKED BLOCK, THE CHROME'S OWN (2026-09-27). It was a
                  // Material checkbox in the retired purple, the one old-UI
                  // control left inside the item. Kept for revert below.
                  if (item.askDoctor != null) ...[
                    const SizedBox(height: 14),
                    TtcToolOptions(
                      p: p,
                      hue: kPrecheckHue,
                      items: [
                        TtcToolOption(
                          label: t(
                            'I talked to my doctor about this',
                            'Doctor se baat ho chuki hai',
                          ),
                          on: entry?.discussedWithDoctor ?? false,
                          tick: true,
                          onTap: () => _store.setDiscussed(
                            item.id,
                            !(entry?.discussedWithDoctor ?? false),
                          ),
                        ),
                      ],
                    ),
                  ],

                  // if (item.askDoctor != null) ...[
                  //   const SizedBox(height: 14),
                  //   GestureDetector(
                  //     onTap: () => _store.setDiscussed(item.id,
                  //         !(entry?.discussedWithDoctor ?? false)),
                  //     behavior: HitTestBehavior.opaque,
                  //     child: Row(children: [
                  //       Icon(
                  //           (entry?.discussedWithDoctor ?? false)
                  //               ? Icons.check_box_rounded
                  //               : Icons.check_box_outline_blank_rounded,
                  //           size: 19,
                  //           color: (entry?.discussedWithDoctor ?? false)
                  //               ? p.action
                  //               : p.ink3),
                  //       const SizedBox(width: 9),
                  //       Expanded(
                  //         child: Text(
                  //             t('I talked to my doctor about this',
                  //                 'Doctor se baat ho chuki hai'),
                  //             style: pvManrope(
                  //                 fontSize: 13.5, color: p.ink2)),
                  //       ),
                  //     ]),
                  //   ),
                  // ],
                  if (item.surfaceId != null || item.readId != null) ...[
                    const SizedBox(height: 14),
                    // A Wrap, not a Row (2026-09-27): the two chips ran off a
                    // 360dp phone inside an open item.
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (item.surfaceId != null)
                          _LinkChip(
                            p: p,
                            // Change 5 (2026-09-28): the chip names the
                            // tool. Kept for revert: t('Open the tool', ...).
                            label: t(
                              kPrecheckToolChip[item.surfaceId!] ??
                                  'Open the tool',
                              'Tool kholein',
                            ),
                            onTap: () => _open(item.surfaceId!),
                          ),
                        if (item.readId != null)
                          _LinkChip(
                            p: p,
                            // Change 5 (2026-09-28): the chip names the
                            // read. Kept for revert: t('Learn more', ...).
                            label: t(
                              ttcReadTitle(item.readId!) == null
                                  ? 'Learn more'
                                  : 'Read: ${ttcReadTitle(item.readId!)!.of(lang)}',
                              'Aur padhein',
                            ),
                            onTap: () => _open('ttc_read/${item.readId}'),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  //  The rebuilt list (2026-09-29). See the file header and
  //  `ttc_precheck_parts.dart`.
  // ---------------------------------------------------------------------------

  List<Widget> _listV2(
    V2Palette p,
    AppLanguage lang,
    String Function(String, String) t,
    PrecheckContext c,
  ) {
    final counts = _store.counts(c);
    // The snapshot (see `_stepsAtOpen`). Kept for revert:
    // final priorities = _store.priorities(c);
    final priorities = _stepsAtOpen ?? _store.priorities(c);
    final visible = kPrecheckVisibleItems;
    final doneFolded = [
      for (final i in visible)
        if (_folded(i, c) && _store.statusOf(i.id, c) == PrecheckStatus.done) i,
    ];
    final notRelevantFolded = [
      for (final i in visible)
        if (_folded(i, c) &&
            _store.statusOf(i.id, c) == PrecheckStatus.notRelevant)
          i,
    ];

    return <Widget>[
      _progressCard(p, t, c, counts),
      const SizedBox(height: 28),
      // Kept for revert (2026-09-29): _nextSteps(p, lang, priorities),
      _nextStepsRows(p, lang, t, c, priorities),
      const SizedBox(height: 30),
      // The tier key, once, above the first tier tag. One line since
      // 2026-09-30 (only Core is tagged). Kept for revert: 'Core: most people
      // should do this. Worth doing: helps most people. Helpful if it
      // applies: only if it fits your situation.'
      Text(
        'Core: most people should do this.',
        style: pvManrope(fontSize: 12.5, height: 1.5, color: p.ink2),
      ),
      const SizedBox(height: 22),
      for (final s in ttcVisiblePrecheckSections)
        ..._sectionV2(p, lang, t, c, s),
      if (doneFolded.isNotEmpty || notRelevantFolded.isNotEmpty)
        Container(
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: ttcLine)),
          ),
        ),
      if (doneFolded.isNotEmpty)
        ..._fold(
          p,
          lang,
          t,
          c,
          'done',
          'Done · ${doneFolded.length}',
          Icons.check_circle_rounded,
          doneFolded,
        ),
      if (notRelevantFolded.isNotEmpty)
        ..._fold(
          p,
          lang,
          t,
          c,
          'notRelevant',
          'Not relevant to me · ${notRelevantFolded.length}',
          Icons.remove_circle_outline_rounded,
          notRelevantFolded,
        ),
      const SizedBox(height: 22),
      Text(
        kPrecheckDisclaimer.en,
        style: pvManrope(fontSize: 12, height: 1.6, color: p.ink2),
      ),
    ];
  }

  /// The ring, the count and what the app already knows.
  ///
  /// ⚠️ NO FRACTION BEFORE ANYTHING IS DONE (kept from 2026-09-27: "0 of 21"
  /// before a single tap read like a debt). Until something is done the card
  /// invites instead of counting.
  String _sinceLabel(DateTime d) {
    const m = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${m[d.month - 1]}';
  }

  Widget _progressCard(
    V2Palette p,
    String Function(String, String) t,
    PrecheckContext c,
    ({int done, int open, int notSure, int tracking}) counts,
  ) {
    final known = _knownLines(t, c);
    final notRelevant = kPrecheckVisibleItems
        .where((i) => _store.statusOf(i.id, c) == PrecheckStatus.notRelevant)
        .length;
    final started = counts.done > 0;
    final knownOpen = _openFolds.contains('known');
    return Container(
      key: const ValueKey('ttc_precheck_progress'),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: precheckCard(p),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              PrecheckRing(done: counts.done, total: counts.tracking),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      started
                          ? '${counts.done} of ${counts.tracking} done'
                          : "Start with what you've already done",
                      style: pvFraunces(
                        fontSize: 19,
                        height: 1.25,
                        fontWeight: FontWeight.w600,
                        color: p.ink1,
                      ),
                    ),
                    // ⚠️ "SINCE YOU WERE LAST HERE" (2026-10-01, the fifth change
                    // to what the checklist gives back): the one line that
                    // shows her the list remembered, and that something moved.
                    // Her own ticks only, and only after a visit on another
                    // day. Nothing when there is nothing to say.
                    if (_store.settledSinceLastVisit() > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${_store.settledSinceLastVisit()} more settled since '
                        '${_sinceLabel(_store.sinceVisit!)}.',
                        key: const ValueKey('ttc_precheck_since'),
                        style: pvManrope(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                          color: p.ink1,
                        ),
                      ),
                    ],
                    const SizedBox(height: 5),
                    Text(
                      started
                          ? [
                              if (counts.open > 0)
                                '${counts.open} to ask a doctor about.',
                              if (notRelevant > 0)
                                'Items not relevant to you leave the count.',
                              if (counts.open == 0 && notRelevant == 0)
                                'Counted from your own list, never a score.',
                            ].join(' ')
                          : 'Tick anything that is done. Nothing here is '
                                'required.',
                      style: pvManrope(
                        fontSize: 12.5,
                        height: 1.45,
                        color: p.ink2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // ⚠️ WHAT THE APP ALREADY KNOWS, FOLDED (2026-09-29). The lines were
          // five sentences above the list; each also shows on its own item as
          // evidence, so here they are one row she can open.
          if (known.isNotEmpty) ...[
            Container(height: 1, color: ttcLine),
            PrecheckFoldHead(
              key: const ValueKey('ttc_precheck_known'),
              label: 'What the app already knows · ${known.length}',
              icon: Icons.auto_awesome_outlined,
              open: knownOpen,
              onTap: () => setState(
                () => knownOpen
                    ? _openFolds.remove('known')
                    : _openFolds.add('known'),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: !knownOpen
                  ? const SizedBox(width: double.infinity)
                  : Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        children: [
                          for (final l in known)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 7),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.check_rounded,
                                    size: 15,
                                    color: p.ink1,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      l,
                                      style: pvManrope(
                                        fontSize: 13,
                                        height: 1.5,
                                        color: p.ink1,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
            ),
          ] else
            const SizedBox(height: 8),
        ],
      ),
    );
  }

  /// "Your next 3 steps" as the items themselves: tick, title, the reason it
  /// is next, and it opens in place (2026-09-29, see `_stepsAtOpen`).
  Widget _nextStepsRows(
    V2Palette p,
    AppLanguage lang,
    String Function(String, String) t,
    PrecheckContext c,
    List<PrecheckPriority> steps,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ttcSectionTitle('Your next 3 steps'),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: precheckCard(p),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (steps.isEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: Text(
                    'Nothing left to suggest: everything on your list is done '
                    'or set aside.',
                    style: pvManrope(
                      fontSize: 13.5,
                      height: 1.5,
                      color: p.ink1,
                    ),
                  ),
                ),
              for (var i = 0; i < steps.length; i++)
                KeyedSubtree(
                  key: ValueKey('ttc_precheck_step_${steps[i].item.id}'),
                  child: _row(
                    p,
                    lang,
                    t,
                    c,
                    steps[i].item,
                    first: i == 0,
                    reason: steps[i].reason.of(lang),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: KeyedSubtree(
                    // The key the tests and the old hero pill used: the one
                    // route to the summary (2026-09-29).
                    key: const ValueKey('ttc_precheck_next_steps'),
                    child: TtcInkPill(
                      label: 'Notes for my doctor',
                      onTap: _openSummary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// "Your next 3 steps": numbered, each with its reason. A tap opens that
  /// item here; the pill opens the notes for a doctor.
  // Kept for revert (2026-09-29): the step drew the item's title a second
  // time, above the same item's row in its section. `_nextStepsRows` draws
  // the row itself instead.
  // ignore: unused_element
  Widget _nextSteps(
    V2Palette p,
    AppLanguage lang,
    List<PrecheckPriority> priorities,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ttcSectionTitle('Your next 3 steps'),
        Container(
          padding: const EdgeInsets.fromLTRB(14, 6, 14, 14),
          decoration: precheckCard(p),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (priorities.isEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(2, 12, 2, 6),
                  child: Text(
                    'Nothing left to suggest: everything on your list is done '
                    'or set aside.',
                    style: pvManrope(
                      fontSize: 13.5,
                      height: 1.5,
                      color: p.ink1,
                    ),
                  ),
                ),
              for (var i = 0; i < priorities.length; i++) ...[
                if (i > 0) Container(height: 1, color: ttcLine),
                _stepRow(p, lang, i + 1, priorities[i]),
              ],
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: KeyedSubtree(
                  // The key the tests and the old hero pill used: the one route
                  // to the summary (2026-09-29).
                  key: const ValueKey('ttc_precheck_next_steps'),
                  child: TtcInkPill(
                    label: 'Notes for my doctor',
                    onTap: _openSummary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ignore: unused_element
  Widget _stepRow(
    V2Palette p,
    AppLanguage lang,
    int n,
    PrecheckPriority step,
  ) => Semantics(
    button: true,
    label: 'Step $n: ${step.item.title.of(lang)}. ${step.reason.of(lang)}',
    excludeSemantics: true,
    child: InkWell(
      key: ValueKey('ttc_precheck_step_${step.item.id}'),
      onTap: () => _openItem(step.item.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: ttcTitleInk,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$n',
                style: pvManrope(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.item.title.of(lang),
                    style: pvJakarta(
                      fontSize: 15,
                      height: 1.3,
                      fontWeight: FontWeight.w700,
                      color: p.ink1,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    step.reason.of(lang),
                    style: pvManrope(
                      fontSize: 12.5,
                      height: 1.45,
                      color: p.ink2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Padding(
              padding: EdgeInsets.only(top: 3),
              child: Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: ttcTitleInk,
              ),
            ),
          ],
        ),
      ),
    ),
  );

  /// One section: the one heading, its count, its line, its rows.
  List<Widget> _sectionV2(
    V2Palette p,
    AppLanguage lang,
    String Function(String, String) t,
    PrecheckContext c,
    PrecheckSection s,
  ) {
    final all = precheckItemsIn(s);
    // Kept for revert (2026-09-29):
    // final rows = [for (final i in all) if (!_folded(i, c)) i];
    final steps = _stepIds;
    final rows = [
      for (final i in all)
        if (!_folded(i, c) && !steps.contains(i.id)) i,
    ];
    // Unused since 2026-09-30 (the pointer line is gone). Kept for revert:
    // final inSteps = all.where((i) => steps.contains(i.id)).length;
    // ⚠️ A SECTION WITH NOTHING TO SHOW IS NOT DRAWN (2026-09-30, the user,
    // twice: "why is it randomly placed" about the heading "Medicines and
    // supplements"). On her real data the app ticks folic acid and her cycle
    // record itself, and the two medicine items move up into "Your next 3
    // steps", which left a heading, a blurb and "Its one item is in your next
    // 3 steps, above." with no rows under them: a heading dropped in at
    // random. Now a section draws only while it has rows of its own; its
    // items are in the steps card or in the folds below. The key still exists
    // for a door's scroll. Kept for revert: `rows.isEmpty && inSteps == 0`,
    // and the heading drew whenever a step came from it.
    if (rows.isEmpty) {
      return [SizedBox.shrink(key: _sectionKeys.putIfAbsent(s, GlobalKey.new))];
    }
    // ⚠️ NO "N of M done" BESIDE A SECTION HEADING (2026-09-30, tools review
    // of this tool, fix A). Six of the eleven sections hold one item, so the
    // pill read "0 of 1 done" under a heading and a blurb; and where items had
    // moved up into "Your next 3 steps" it said "0 of 3 done" over one row.
    // The ring at the top is the one count. Kept for revert:
    //   final done = all.where((i) => _store.statusOf(i.id, c) ==
    //       PrecheckStatus.done).length;
    //   final counted = all.where((i) => _store.statusOf(i.id, c) !=
    //       PrecheckStatus.notRelevant).length;
    //   ... Row(children: [Expanded(heading), SizedBox(width: 10),
    //       Padding(bottom: 3, child: PrecheckTag('$done of $counted done',
    //       filled: counted > 0 && done == counted))]).
    return [
      Row(
        key: _sectionKeys.putIfAbsent(s, GlobalKey.new),
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: TtcSectionHeading(s.title.of(lang))),
        ],
      ),
      const SizedBox(height: 5),
      Text(
        s.blurb.of(lang),
        style: pvManrope(fontSize: 13, height: 1.45, color: p.ink2),
      ),
      // Kept for revert (2026-09-30): the pointer under a heading whose
      // items had moved into "Your next 3 steps".
      //   if (inSteps > 0) ...[
      //     const SizedBox(height: 6),
      //     Text(inSteps == 1 && rows.isEmpty
      //         ? 'Its one item is in your next 3 steps, above.'
      //         : '$inSteps more in your next 3 steps, above.',
      //         style: pvManrope(fontSize: 12.5, fontWeight: FontWeight.w700,
      //             height: 1.45, color: p.ink1)),
      //   ],
      const SizedBox(height: 12),
      if (rows.isNotEmpty)
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: precheckCard(p),
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++)
                _row(p, lang, t, c, rows[i], first: i == 0),
            ],
          ),
        ),
      const SizedBox(height: 30),
    ];
  }

  List<Widget> _fold(
    V2Palette p,
    AppLanguage lang,
    String Function(String, String) t,
    PrecheckContext c,
    String id,
    String label,
    IconData icon,
    List<PrecheckItem> items,
  ) {
    final open = _openFolds.contains(id);
    return [
      PrecheckFoldHead(
        key: ValueKey('ttc_precheck_fold_$id'),
        label: label,
        icon: icon,
        open: open,
        onTap: () =>
            setState(() => open ? _openFolds.remove(id) : _openFolds.add(id)),
      ),
      if (open) ...[
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: precheckCard(p),
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++)
                _row(p, lang, t, c, items[i], first: i == 0),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    ];
  }

  /// One item: the tick, the title, its tags, its evidence; opens in place.
  Widget _row(
    V2Palette p,
    AppLanguage lang,
    String Function(String, String) t,
    PrecheckContext c,
    PrecheckItem item, {
    required bool first,
    String? reason,
  }) {
    final open = _openItems.contains(item.id);
    final status = _store.statusOf(item.id, c);
    final evidence = precheckEvidenceFor(item, c);
    // The app's tick, named, only while it is the app's (her answer wins).
    final source = _store.entryFor(item.id) == null
        ? precheckDoneSource(item, c)
        : null;
    final done = status == PrecheckStatus.done;

    return Container(
      key: _itemKeys.putIfAbsent(item.id, GlobalKey.new),
      decoration: first
          ? null
          : BoxDecoration(
              border: Border(top: BorderSide(color: ttcLine)),
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 6, 0, 0),
                child: PrecheckTick(
                  key: ValueKey('ttc_precheck_${item.id}_mark'),
                  status: status,
                  title: item.title.of(lang),
                  onTap: () => _toggleDone(item, status, lang),
                ),
              ),
              Expanded(
                child: Semantics(
                  button: true,
                  expanded: open,
                  child: InkWell(
                    key: ValueKey('ttc_precheck_${item.id}_open'),
                    onTap: () => setState(
                      () => open
                          ? _openItems.remove(item.id)
                          : _openItems.add(item.id),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(4, 16, 12, 15),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 200),
                                  style: pvJakarta(
                                    fontSize: 15.5,
                                    height: 1.3,
                                    fontWeight: FontWeight.w700,
                                    color: done ? p.ink2 : p.ink1,
                                  ),
                                  child: Text(item.title.of(lang)),
                                ),
                                // Why it is one of her next three (only in
                                // the steps card).
                                if (reason != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    reason,
                                    style: pvManrope(
                                      fontSize: 12.5,
                                      height: 1.45,
                                      color: p.ink1,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 7),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: [
                                    // Core only (2026-09-30, fix C).
                                    if (item.tier == PrecheckTier.core)
                                    PrecheckTag(
                                      item.tier.label.of(lang),
                                      filled: true,
                                    ),
                                    if (source != null)
                                      PrecheckTag(
                                        source.of(lang),
                                        filled: true,
                                        icon: Icons.check_rounded,
                                      ),
                                    if (status.isOpen ||
                                        status == PrecheckStatus.notRelevant)
                                      PrecheckTag(
                                          precheckAskFor(item.id).labelFor(status)),
                                    if (_store
                                            .entryFor(item.id)
                                            ?.discussedWithDoctor ??
                                        false)
                                      const PrecheckTag(
                                        'Talked to a doctor',
                                        icon: Icons.forum_outlined,
                                      ),
                                  ],
                                ),
                                // ⚠️ EVIDENCE, SHOWN EVEN WHEN CLOSED (kept
                                // from the first build): the line that proves
                                // the app has been paying attention, and on
                                // folic acid the one that says check the dose.
                                if (evidence != null) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    evidence.of(lang),
                                    style: pvManrope(
                                      fontSize: 12.5,
                                      height: 1.5,
                                      fontWeight: FontWeight.w600,
                                      color: p.ink2,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          AnimatedRotation(
                            turns: open ? 0.5 : 0,
                            duration: const Duration(milliseconds: 200),
                            child: const Icon(
                              Icons.expand_more_rounded,
                              size: 22,
                              color: ttcTitleInk,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: open
                ? _details(p, lang, t, item, status)
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  /// An open item: her answer first, then the reading, then where to go.
  Widget _details(
    V2Palette p,
    AppLanguage lang,
    String Function(String, String) t,
    PrecheckItem item,
    PrecheckStatus status,
  ) {
    final entry = _store.entryFor(item.id);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // The item's own question (2026-09-30). Kept for revert:
          // PrecheckLabel(t('WHERE YOU ARE', 'AAP KAHAN HAIN')),
          Text(
            precheckAskFor(item.id).question,
            style: pvManrope(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              height: 1.35,
              color: p.ink1,
            ),
          ),
          const SizedBox(height: 10),
          TtcToolOptions(
            p: p,
            hue: kPrecheckHue,
            items: [
              for (final s in const [
                PrecheckStatus.done,
                PrecheckStatus.needsAttention,
                PrecheckStatus.notSure,
                PrecheckStatus.notRelevant,
              ])
                TtcToolOption(
                  // The item's own words (2026-09-30).
                  label: precheckAskFor(item.id).labelFor(s),
                  on: status == s,
                  onTap: () => _store.setStatus(
                    item.id,
                    status == s ? PrecheckStatus.untouched : s,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          _field(
            p,
            t('WHY THIS STEP MATTERS', 'KYUN MAAYNE RAKHTA HAI'),
            item.why.of(lang),
          ),
          _field(p, t('WHAT TO DO', 'KYA KARNA HAI'), item.whatToDo.of(lang)),
          // ⚠️ THE QUESTION ON ITS OWN CARD (2026-09-29): the one line she
          // carries into a room, so it reads as a thing to take, not a third
          // paragraph. It also goes into "Notes for my doctor" when the item
          // is open on her list.
          if (item.askDoctor != null) ...[
            Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              decoration: precheckCard(p),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PrecheckLabel(t('ASK YOUR DOCTOR', 'DOCTOR SE POOCHHEIN')),
                  const SizedBox(height: 6),
                  Text(
                    '"${item.askDoctor!.of(lang)}"',
                    style: pvFraunces(
                      fontSize: 16,
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                      color: p.ink1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // A separate flag, not a fifth status: see the store.
            TtcToolOptions(
              p: p,
              hue: kPrecheckHue,
              items: [
                TtcToolOption(
                  label: t(
                    'I talked to my doctor about this',
                    'Doctor se baat ho chuki hai',
                  ),
                  on: entry?.discussedWithDoctor ?? false,
                  tick: true,
                  onTap: () => _store.setDiscussed(
                    item.id,
                    !(entry?.discussedWithDoctor ?? false),
                  ),
                ),
              ],
            ),
          ],
          if (item.surfaceId != null || item.readId != null) ...[
            const SizedBox(height: 12),
            if (item.surfaceId case final sid?)
              PrecheckGoRow(
                // Names the tool (change 5, 2026-09-28).
                label: t(
                  kPrecheckToolChip[sid] ?? 'Open the tool',
                  'Tool kholein',
                ),
                toolMark:
                    ttcToolMarkForSurface(sid) ??
                    (sid == 'ttc_prepare' ? TtcToolMark.expert : null),
                tabMark: sid == 'ttc_partner' ? TtcTabMark.twoCircles : null,
                hue: precheckSurfaceHue(sid),
                onTap: () => _open(sid),
              ),
            if (item.readId case final rid?)
              PrecheckGoRow(
                // Names the read (change 5, 2026-09-28).
                label: t(
                  ttcReadTitle(rid) == null
                      ? 'Learn more'
                      : 'Read: ${ttcReadTitle(rid)!.of(lang)}',
                  'Aur padhein',
                ),
                tabMark: TtcTabMark.openBook,
                hue: kPrecheckHue,
                onTap: () => _open('ttc_read/$rid'),
              ),
          ],
        ],
      ),
    );
  }

  Widget _field(V2Palette p, String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: pvManrope(
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
            color: p.ink3,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: pvManrope(fontSize: 13.5, height: 1.65, color: p.ink2),
        ),
      ],
    ),
  );

  void _open(String surfaceId) {
    final screen = ttcScreenForSurface(surfaceId);
    if (screen == null) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        settings: RouteSettings(name: surfaceId),
        builder: (_) => screen,
      ),
    );
  }

  /// One tap on the row's circle (2026-09-27): done, or back off done with
  /// Undo. Any other answer she gave is kept by the Undo too.
  void _toggleDone(PrecheckItem item, PrecheckStatus was, AppLanguage lang) {
    if (was != PrecheckStatus.done) {
      _store.setStatus(item.id, PrecheckStatus.done);
      return;
    }
    // ⚠️ UNDO PUTS BACK WHAT WAS THERE, NOT "DONE" (2026-09-29). A tick the
    // app made from her supplements has no entry of hers behind it; undoing
    // by storing "done" would turn the app's tick into hers, and the
    // "From your supplements" tag would silently vanish. Kept for revert:
    // onAction: () => _store.setStatus(item.id, PrecheckStatus.done)
    final before = _store.entryFor(item.id);
    _store.setStatus(item.id, PrecheckStatus.untouched);
    pvSnack(
      context,
      '${item.title.of(lang)}: taken off done.',
      action: 'Undo',
      lift: 24,
      onAction: () => _store.restore(item.id, before),
    );
  }

  // ⚠️ A STEP WITH NOWHERE ELSE TO GO COMES BACK HERE, OPEN (2026-09-27).
  // Six items (tobacco, alcohol, caffeine, sleep, dental, conditions) have no
  // tool or read, so tapping one of them on "My next 3 steps" did nothing: a
  // card that looked tappable and was dead. The summary now returns the
  // item's id, and the list opens that item and scrolls to it, which is where
  // its "what to do" and its answers live. Kept for revert: a plain push.
  Future<void> _openSummary() async {
    final id = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        settings: const RouteSettings(name: 'ttc_precheck/summary'),
        builder: (_) => const TtcPrecheckSummaryScreen(),
      ),
    );
    if (id == null || !mounted) return;
    final item = precheckItemById(id);
    if (item == null) return;
    _openItem(id);
  }

  /// Opens one item in place and scrolls to it: from "Your next 3 steps" on
  /// this list, and from a page that hands an item id back.
  void _openItem(String id) {
    if (precheckItemById(id) case final item?) {
      final c = PrecheckContext.gather();
      if (_folded(item, c)) {
        _openFolds.add(
          _store.statusOf(id, c) == PrecheckStatus.done
              ? 'done'
              : 'notRelevant',
        );
      }
      setState(() {
        _openSections.add(item.section);
        _openItems.add(id);
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _itemKeys[id]?.currentContext;
      if (ctx != null && ctx.mounted) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 300),
          alignment: 0.1,
        );
      }
    });
  }
}

// -----------------------------------------------------------------------------
//  Pieces
// -----------------------------------------------------------------------------

/// ⚠️ COUNTS, NOT A PERCENTAGE, AND THE DENOMINATOR IS HER LIST.
class _CountBar extends StatelessWidget {
  const _CountBar({
    required this.p,
    required this.t,
    required this.counts,
    required this.marked,
  });

  final V2Palette p;
  final String Function(String, String) t;
  final ({int done, int open, int notSure, int tracking}) counts;

  /// Items she has marked with any status.
  final int marked;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 15),
    decoration: BoxDecoration(
      // Kept for revert (2026-09-29, no tinted slab behind text): color: p.surfaceAlt,
      color: p.surface,
      border: Border.fromBorderSide(BorderSide(color: p.line)),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Kept for revert (2026-09-27), English:
        //   '${counts.done} of the ${counts.tracking} you're tracking are done'
        Text(
          t(
            "You've marked $marked so far. ${counts.done} done.",
            '${counts.tracking} mein se ${counts.done} ho chuke hain',
          ),
          style: pvJakarta(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: p.ink1,
          ),
        ),
        if (counts.open > 0) ...[
          const SizedBox(height: 5),
          Text(
            t(
              '${counts.open} may be worth asking a doctor about',
              '${counts.open} par baat karna theek rahega',
            ),
            style: pvManrope(fontSize: 13, color: p.ink2),
          ),
        ],
      ],
    ),
  );
}

/// The row's circle, as a button: one tap marks the item done.
///
/// ⚠️ 44 BY 44 TO THE FINGER, 22 TO THE EYE. The mark stays the size it was;
/// the target around it is the size a thumb needs, so a tap meant for the
/// circle does not open the item instead.
class _DoneButton extends StatelessWidget {
  const _DoneButton({
    super.key,
    required this.p,
    required this.status,
    required this.title,
    required this.onTap,
  });

  final V2Palette p;
  final PrecheckStatus status;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final done = status == PrecheckStatus.done;
    return Semantics(
      button: true,
      checked: done,
      label: done ? 'Done: $title. Tap to take it off' : 'Mark $title done',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Align(
            alignment: const Alignment(-0.6, -0.75),
            child: _StatusDot(p: p, status: status),
          ),
        ),
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.p, required this.status});
  final V2Palette p;
  final PrecheckStatus status;

  @override
  Widget build(BuildContext context) {
    // ⚠️ SHAPE AND ICON CARRY THE MEANING, NOT COLOUR ALONE — §32. And no red:
    // an unfinished checklist item is not a failure.
    final (IconData icon, Color colour) = switch (status) {
      // Ink, not purple (2026-09-27). Kept for revert: p.action.
      PrecheckStatus.done => (Icons.check_circle_rounded, p.ink1),
      PrecheckStatus.needsAttention => (Icons.circle_outlined, p.ink2),
      PrecheckStatus.notSure => (Icons.help_outline_rounded, p.ink2),
      PrecheckStatus.notRelevant => (Icons.remove_circle_outline, p.ink3),
      // ink3, not the hairline colour (2026-09-27): the empty circle is a
      // button now and has to be seen. Kept for revert: p.line.
      PrecheckStatus.untouched => (Icons.circle_outlined, p.ink3),
    };
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Icon(icon, size: 20, color: colour),
    );
  }
}

// Unreached since 2026-09-27 (the item's answers are `TtcToolOptions` now);
// kept for revert.
// ignore: unused_element
class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.p,
    required this.label,
    required this.on,
    required this.onTap,
  });

  final V2Palette p;
  final String label;
  final bool on;
  final VoidCallback onTap;

  // ⚠️ THE TOOL CHROME'S OWN PILL (2026-09-27): white with a hairline at
  // rest, ink when chosen, as on every other tool. The chosen chip was a
  // purple outline on a purple wash, the retired accent treatment.
  @override
  Widget build(BuildContext context) =>
      TtcToolPill(label: label, on: on, onTap: onTap, hue: kPrecheckHue);

  // Kept for revert (2026-09-27): the purple chip.
  // ignore: unused_element
  Widget _oldBuild(BuildContext context) => GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: Container(
      constraints: const BoxConstraints(minHeight: 44),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: on ? p.action.withValues(alpha: 0.10) : null,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: on ? p.action : p.line, width: on ? 1.4 : 1),
      ),
      child: Text(
        label,
        style: pvManrope(
          fontSize: 13,
          fontWeight: on ? FontWeight.w800 : FontWeight.w600,
          color: on ? p.action : p.ink2,
        ),
      ),
    ),
  );
}

/// What the "open the tool" chip says, by the tool it opens (change 5,
/// 2026-09-28: a chip names what it opens, never "Open the tool").
const Map<String, String> kPrecheckToolChip = {
  'ttc_supplements': 'Open Supplements',
  'ttc_nutrition': "Open this week's food ideas",
  'ttc_prepare': 'See experts and programmes',
  'ttc_tests': 'Open Medical tests',
  'ttc_medication': 'Open Medication',
  'ttc_vaccinations': 'Open Vaccinations',
  'ttc_ritual': "Open today's five small things",
  'ttc_bmi': 'Open the BMI check',
  'ttc_partner': 'Open his side',
  'ttc_window': 'Open Fertile window',
  'ttc_cycle': 'Open Cycle companion',
};

class _LinkChip extends StatelessWidget {
  const _LinkChip({required this.p, required this.label, required this.onTap});

  final V2Palette p;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: Container(
      constraints: const BoxConstraints(minHeight: 44),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: p.line),
      ),
      child: Text(
        label,
        style: pvManrope(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: p.ink1,
        ),
      ),
    ),
  );
}

class _Button extends StatelessWidget {
  const _Button({required this.p, required this.label, required this.onTap});
  final V2Palette p;
  final String label;
  final VoidCallback onTap;

  // The tool chrome's own button (2026-09-27), not a purple fill.
  @override
  Widget build(BuildContext context) =>
      TtcToolPrimary(label: label, onTap: onTap);

  // Kept for revert (2026-09-27): the purple filled button.
  // ignore: unused_element
  Widget _oldBuild(BuildContext context) => GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: Container(
      width: double.infinity,
      height: 54,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: p.action,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: pvJakarta(
          fontSize: 15.5,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    ),
  );
}

/// Shared with the summary screen.
class PrecheckButton extends StatelessWidget {
  const PrecheckButton({
    super.key,
    required this.p,
    required this.label,
    required this.onTap,
    this.filled = true,
  });

  final V2Palette p;
  final String label;
  final VoidCallback onTap;
  final bool filled;

  // ⚠️ THE TOOL CHROME'S OWN BUTTONS (2026-09-27): `TtcToolPrimary` and
  // `TtcToolSecondary`, white with a hairline, as on every other tool. The
  // filled one was bright purple (`p.action`).
  @override
  Widget build(BuildContext context) => filled
      ? TtcToolPrimary(label: label, onTap: onTap)
      : TtcToolSecondary(label: label, onTap: onTap);

  // Kept for revert (2026-09-27): the purple filled button.
  // ignore: unused_element
  Widget _oldBuild(BuildContext context) => GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: Container(
      width: double.infinity,
      height: 54,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: filled ? p.action : null,
        borderRadius: BorderRadius.circular(999),
        border: filled ? null : Border.all(color: p.line),
      ),
      child: Text(
        label,
        style: pvJakarta(
          fontSize: 15.5,
          fontWeight: FontWeight.w700,
          color: filled ? Colors.white : p.ink1,
        ),
      ),
    ),
  );
}
