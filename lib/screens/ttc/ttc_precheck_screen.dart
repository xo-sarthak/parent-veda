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
import '../products/pv_store_chrome.dart' show pvSnack;
import '../v2/v2_palette.dart';
import 'ttc_common.dart' show ttcLine, ttcTitleInk;
import 'ttc_precheck_summary.dart';
import 'ttc_strings.dart';
import 'ttc_surface_router.dart';
import 'ttc_tool_chrome.dart';

/// Getting ready is 104 on the wheel — the tool keeps its door's colour.
const double kPrecheckHue = 104;

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
    widget.openSection ?? PrecheckSection.folate
  };

  TtcPrecheckStore get _store => TtcPrecheckStore.instance;

  @override
  void initState() {
    super.initState();
    _store.load().then((_) {
      if (!mounted) return;
      _store.markOpened();
      // A door that named a section has already made the decision the intro
      // exists to prompt.
      // ⚠️ NO INTRO SCREEN ANY MORE (tools pass, 2026-09-27). It was one
      // extra screen before anything happened; its framing and its "what
      // you've already done" lines now head the list, so the first tap is a
      // real item. `_intro` stays below, unreached. Kept for revert:
      // setState(() => _started = _store.everOpened || widget.openSection != null);
      setState(() => _started = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge(
          [_store, V2PaletteStore.instance, TtcLang.instance]),
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
          // ⚠️ ONE TOOL, ONE NAME: the Tools tile's name, word for word.
          eyebrow: 'Pre-pregnancy checklist',
          // ---- WHAT THIS IS, FIRST (tools pass, 2026-09-27) ---------------
          title: 'Things to sort out before trying',
          // Says the one-tap mark (2026-09-27). Kept for revert:
          // 'Open an item to read why it matters and mark where you '
          // 'are. It saves as you tap. You only need what fits you.'
          intro: 'Tap the circle when something is done. Open an item to '
              'read why it matters or pick another answer. It saves as you '
              'tap. You only need what fits you.',
          action: _started ? _stepsLink(p, t) : null,
          children: [
            ttcToolPad(Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 22),
                ...(!_started ? _intro(p, t, c) : _list(p, lang, t, c)),
                const SizedBox(height: 26),
              ],
            )),
          ],
        );
      },
    );
  }

  /// The one route to the summary, top right of the hero where the old bar
  /// carried it. White with a hairline and ink words: the tool chrome's
  /// treatment, not the purple link it was.
  Widget _stepsLink(V2Palette p, String Function(String, String) t) =>
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
          child: Text(t('My next 3 steps', 'Summary'),
              style: pvManrope(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: ttcTitleInk)),
        ),
      );

  // Kept for revert (2026-09-27): the old back bar with its "GETTING READY"
  // crumb and the purple "My next 3 steps" link. `TtcToolScaffold`'s close
  // button and `_stepsLink` replace it.
  // ignore: unused_element
  Widget _bar(V2Palette p, String Function(String, String) t) => Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 16, 6),
        child: Row(children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Icon(Icons.arrow_back_rounded, size: 21, color: p.ink1),
            ),
          ),
          Expanded(
            child: Text(t('GETTING READY', 'TAIYAARI').toUpperCase(),
                style: pvManrope(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    color: p.ink3)),
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
                child: Text(t('My next 3 steps', 'Summary'),
                    style: pvManrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: p.action)),
              ),
            ),
        ]),
      );

  // ---------------------------------------------------------------------------
  //  Intro
  // ---------------------------------------------------------------------------

  // The stages hand their blocks to the tool sheet now (2026-09-27), so each
  // returns a list rather than its own ListView.
  List<Widget> _intro(
      V2Palette p, String Function(String, String) t, PrecheckContext c) {
    final known = _knownLines(t, c);
    // Kept for revert (2026-09-27):
    // return ListView(
    //   padding: const EdgeInsets.fromLTRB(20, 8, 20, kAskFabReserve + 24),
    //   children: [
    return <Widget>[
        Text(
            t("Getting ready doesn't have to mean doing everything.",
                'Taiyaari ka matlab sab kuch karna nahi hota.'),
            style: pvFraunces(
                fontSize: 29,
                height: 1.18,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.4,
                color: p.ink1)),
        const SizedBox(height: 14),
        Text(
            t(
                'A few checks before you start can make the early weeks '
                    "easier. Here you'll see what you've already covered, and "
                    'what may be worth talking about with a doctor.',
                'Shuru karne se pehle kuch soch-samajh kar ki gayi jaanch, '
                    'shuruaati hafton ko aasaan bana deti hai. Ye dikhata hai ki '
                    'kya ho chuka hai aur kis par baat karna baaki hai.'),
            style: pvFraunces(fontSize: 16.5, height: 1.58, color: p.ink2)),
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
                      t("WHAT YOU'VE ALREADY DONE",
                          'JO AAP PEHLE HI KAR CHUKI HAIN'),
                      style: pvManrope(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                          color: const Color(0xFF2E3A2C))),
                  const SizedBox(height: 10),
                  for (final l in known)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.check_rounded,
                                size: 15, color: const Color(0xFF3D4A38)),
                            const SizedBox(width: 9),
                            Expanded(
                              child: Text(l,
                                  style: pvManrope(
                                      fontSize: 14,
                                      height: 1.5,
                                      color: const Color(0xFF31402D))),
                            ),
                          ]),
                    ),
                ]),
          ),
          const SizedBox(height: 20),
        ],

        Text(
            t(
                "You don't need a perfect checklist. You just need to know "
                    'what matters for you.',
                'Aapko perfect checklist ki zaroorat nahi. Bas ye pata hona '
                    'chahiye ki aapke liye kya maayne rakhta hai.'),
            style: pvFraunces(
                fontSize: 17,
                height: 1.55,
                fontWeight: FontWeight.w500,
                color: p.ink1)),
        const SizedBox(height: 24),

        _Button(
          p: p,
          label: _store.everOpened
              ? t('Continue your checklist', 'Apni checklist jaari rakhein')
              : t('Start my checklist', 'Meri checklist shuru karein'),
          onTap: () => setState(() => _started = true),
        ),
        const SizedBox(height: 16),
        Text(kPrecheckDisclaimer.en,
            style: pvManrope(fontSize: 12, height: 1.6, color: p.ink3)),
    ];
    // Kept for revert (2026-09-27): the ListView's closing `],\n );`.
  }

  List<String> _knownLines(
      String Function(String, String) t, PrecheckContext c) {
    final out = <String>[];
    if (c.loggedCycles >= 2) {
      out.add(t(
          'You\'ve logged ${c.loggedCycles} cycles, so cycle tracking is '
              'already covered.',
          'Aapne ${c.loggedCycles} cycles log kiye hain — cycle tracking ho '
              'chuki hai.'));
    }
    if (c.ranPcosCheck) {
      out.add(t("You've done the PCOS check.",
          'Aapne PCOS check kar liya hai.'));
    }
    if (c.supplementCount > 0) {
      out.add(t(
          'You\'ve noted ${c.supplementCount} supplements.',
          'Aapne ${c.supplementCount} supplements darj kiye hain.'));
    }
    if (c.medicineCount > 0) {
      out.add(t(
          'You\'ve saved ${c.medicineCount} medicines. They\'re worth '
              'reviewing with a doctor before pregnancy.',
          'Aapne ${c.medicineCount} dawaiyan save ki hain — pregnancy se pehle '
              'review karwane layak.'));
    }
    if (c.vaccinesRecorded > 0) {
      out.add(t("You've started your vaccine list.",
          'Aapne vaccination list shuru kar di hai.'));
    }
    return out;
  }

  // ---------------------------------------------------------------------------
  //  The list
  // ---------------------------------------------------------------------------

  List<Widget> _list(V2Palette p, AppLanguage lang,
      String Function(String, String) t, PrecheckContext c) {
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
        // The tier key, once, the first time the labels appear.
        Text(
            'Core: most people should do this. Worth doing: helps most '
            'people. Helpful if it applies: only if it fits your situation.',
            style: pvManrope(fontSize: 12, height: 1.5, color: p.ink3)),
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
                      child: Text(l,
                          style: pvManrope(
                              fontSize: 13, height: 1.5, color: p.ink2)),
                    ),
                  ]),
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
        Text(kPrecheckDisclaimer.en,
            style: pvManrope(fontSize: 12, height: 1.6, color: p.ink3)),
    ];
    // Kept for revert (2026-09-27): the ListView's closing `],\n );`.
  }

  Widget _section(V2Palette p, AppLanguage lang,
      String Function(String, String) t, PrecheckContext c, PrecheckSection s) {
    final items = precheckItemsIn(s);
    if (items.isEmpty) return const SizedBox.shrink();
    final open = _openSections.contains(s);
    final done =
        items.where((i) => _store.statusOf(i.id, c) == PrecheckStatus.done)
            .length;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: p.line),
      ),
      child: Column(children: [
        GestureDetector(
          onTap: () => setState(
              () => open ? _openSections.remove(s) : _openSections.add(s)),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 15, 13, 16),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.title.of(lang),
                          style: pvFraunces(
                              fontSize: 17.5,
                              height: 1.3,
                              fontWeight: FontWeight.w600,
                              color: p.ink1)),
                      const SizedBox(height: 5),
                      Text(s.blurb.of(lang),
                          style: pvManrope(
                              fontSize: 13, height: 1.5, color: p.ink3)),
                    ]),
              ),
              const SizedBox(width: 10),
              Column(children: [
                Text('$done/${items.length}',
                    style: pvManrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: p.ink3)),
                const SizedBox(height: 4),
                Icon(
                    open
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    size: 20,
                    color: p.ink3),
              ]),
            ]),
          ),
        ),
        if (open)
          for (final item in items)
            _itemTile(p, lang, t, c, item),
      ]),
    );
  }

  Widget _itemTile(V2Palette p, AppLanguage lang,
      String Function(String, String) t, PrecheckContext c, PrecheckItem item) {
    final open = _openItems.contains(item.id);
    final status = _store.statusOf(item.id, c);
    final evidence = precheckEvidenceFor(item, c);
    final entry = _store.entryFor(item.id);

    return Container(
      key: _itemKeys.putIfAbsent(item.id, GlobalKey.new),
      decoration:
          BoxDecoration(border: Border(top: BorderSide(color: p.line))),
      child: Column(children: [
        GestureDetector(
          onTap: () => setState(
              () => open ? _openItems.remove(item.id) : _openItems.add(item.id)),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 13, 15),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                      Text(item.title.of(lang),
                          style: pvJakarta(
                              fontSize: 15,
                              height: 1.35,
                              fontWeight: FontWeight.w700,
                              color: p.ink1)),
                      const SizedBox(height: 5),
                      // A Wrap, not a Row (2026-09-27): "Helpful if it
                      // applies · Not relevant to me" ran off a 360dp row.
                      Wrap(children: [
                        Text(item.tier.label.of(lang),
                            style: pvManrope(
                                fontSize: 11,
                                // Ink, not purple (2026-09-27). Kept for
                                // revert: `? p.action`.
                                fontWeight: item.tier == PrecheckTier.core
                                    ? FontWeight.w800
                                    : FontWeight.w700,
                                color: item.tier == PrecheckTier.core
                                    ? p.ink1
                                    : p.ink3)),
                        if (status != PrecheckStatus.untouched) ...[
                          Text('  ·  ',
                              style: pvManrope(fontSize: 11, color: p.ink3)),
                          Text(status.label.of(lang),
                              style: pvManrope(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: p.ink2)),
                        ],
                      ]),
                      // ⚠️ EVIDENCE, SHOWN EVEN WHEN COLLAPSED. It is the most
                      // useful line on the card and the one that proves the app
                      // has been paying attention.
                      if (evidence != null) ...[
                        const SizedBox(height: 7),
                        Text(evidence.of(lang),
                            // Ink, not purple (2026-09-27). Kept for revert:
                            // color: p.action.
                            style: pvManrope(
                                fontSize: 12.5,
                                height: 1.5,
                                fontWeight: FontWeight.w600,
                                color: p.ink2)),
                      ],
                    ]),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(open ? Icons.remove_rounded : Icons.add_rounded,
                    size: 19, color: p.ink3),
              ),
            ]),
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
                  Text(t('WHERE YOU ARE', 'AAP KAHAN HAIN'),
                      style: pvManrope(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                          color: p.ink3)),
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
                          label: s.label.of(lang),
                          on: status == s,
                          onTap: () => _store.setStatus(item.id,
                              status == s ? PrecheckStatus.untouched : s),
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _field(p, t('WHY IT MATTERS', 'KYUN MAAYNE RAKHTA HAI'),
                      item.why.of(lang)),
                  _field(p, t('WHAT TO DO', 'KYA KARNA HAI'),
                      item.whatToDo.of(lang)),
                  if (item.askDoctor != null)
                    _field(
                        p,
                        t('ASK YOUR DOCTOR', 'DOCTOR SE POOCHHEIN'),
                        '"${item.askDoctor!.of(lang)}"'),

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
                          label: t('I talked to my doctor about this',
                              'Doctor se baat ho chuki hai'),
                          on: entry?.discussedWithDoctor ?? false,
                          tick: true,
                          onTap: () => _store.setDiscussed(item.id,
                              !(entry?.discussedWithDoctor ?? false)),
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
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      if (item.surfaceId != null)
                        _LinkChip(
                          p: p,
                          label: t('Open the tool', 'Tool kholein'),
                          onTap: () => _open(item.surfaceId!),
                        ),
                      if (item.readId != null)
                        _LinkChip(
                          p: p,
                          label: t('Learn more', 'Aur padhein'),
                          onTap: () => _open('ttc_read/${item.readId}'),
                        ),
                    ]),
                  ],
                ]),
          ),
      ]),
    );
  }

  Widget _field(V2Palette p, String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: pvManrope(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: p.ink3)),
          const SizedBox(height: 6),
          Text(value,
              style: pvManrope(fontSize: 13.5, height: 1.65, color: p.ink2)),
        ]),
      );

  void _open(String surfaceId) {
    final screen = ttcScreenForSurface(surfaceId);
    if (screen == null) return;
    Navigator.of(context).push(MaterialPageRoute<void>(
      settings: RouteSettings(name: surfaceId),
      builder: (_) => screen,
    ));
  }

  /// One tap on the row's circle (2026-09-27): done, or back off done with
  /// Undo. Any other answer she gave is kept by the Undo too.
  void _toggleDone(PrecheckItem item, PrecheckStatus was, AppLanguage lang) {
    if (was != PrecheckStatus.done) {
      _store.setStatus(item.id, PrecheckStatus.done);
      return;
    }
    _store.setStatus(item.id, PrecheckStatus.untouched);
    pvSnack(context, '${item.title.of(lang)}: taken off done.',
        action: 'Undo',
        lift: 24,
        onAction: () => _store.setStatus(item.id, PrecheckStatus.done));
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
    ));
    if (id == null || !mounted) return;
    final item = precheckItemById(id);
    if (item == null) return;
    setState(() {
      _openSections.add(item.section);
      _openItems.add(id);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _itemKeys[id]?.currentContext;
      if (ctx != null && ctx.mounted) {
        Scrollable.ensureVisible(ctx,
            duration: const Duration(milliseconds: 300), alignment: 0.1);
      }
    });
  }
}

// -----------------------------------------------------------------------------
//  Pieces
// -----------------------------------------------------------------------------

/// ⚠️ COUNTS, NOT A PERCENTAGE, AND THE DENOMINATOR IS HER LIST.
class _CountBar extends StatelessWidget {
  const _CountBar(
      {required this.p,
      required this.t,
      required this.counts,
      required this.marked});

  final V2Palette p;
  final String Function(String, String) t;
  final ({int done, int open, int notSure, int tracking}) counts;

  /// Items she has marked with any status.
  final int marked;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 15),
        decoration: BoxDecoration(
          color: p.surfaceAlt,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Kept for revert (2026-09-27), English:
          //   '${counts.done} of the ${counts.tracking} you're tracking are done'
          Text(
              t("You've marked $marked so far. ${counts.done} done.",
                  '${counts.tracking} mein se ${counts.done} ho chuke hain'),
              style: pvJakarta(
                  fontSize: 15, fontWeight: FontWeight.w700, color: p.ink1)),
          if (counts.open > 0) ...[
            const SizedBox(height: 5),
            Text(
                t('${counts.open} may be worth asking a doctor about',
                    '${counts.open} par baat karna theek rahega'),
                style: pvManrope(fontSize: 13, color: p.ink2)),
          ],
        ]),
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
  const _StatusChip(
      {required this.p,
      required this.label,
      required this.on,
      required this.onTap});

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
            border: Border.all(
                color: on ? p.action : p.line, width: on ? 1.4 : 1),
          ),
          child: Text(label,
              style: pvManrope(
                  fontSize: 13,
                  fontWeight: on ? FontWeight.w800 : FontWeight.w600,
                  color: on ? p.action : p.ink2)),
        ),
      );
}

class _LinkChip extends StatelessWidget {
  const _LinkChip(
      {required this.p, required this.label, required this.onTap});

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
          child: Text(label,
              style: pvManrope(
                  fontSize: 13, fontWeight: FontWeight.w700, color: p.ink1)),
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
              color: p.action, borderRadius: BorderRadius.circular(999)),
          child: Text(label,
              style: pvJakarta(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
        ),
      );
}

/// Shared with the summary screen.
class PrecheckButton extends StatelessWidget {
  const PrecheckButton(
      {super.key,
      required this.p,
      required this.label,
      required this.onTap,
      this.filled = true});

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
          child: Text(label,
              style: pvJakarta(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                  color: filled ? Colors.white : p.ink1)),
        ),
      );
}
