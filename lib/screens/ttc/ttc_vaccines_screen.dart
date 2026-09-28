// =============================================================================
//  TtcVaccinesScreen — the preconception vaccination list, as something usable
// -----------------------------------------------------------------------------
//  Built because prose was not enough. See the head of `ttc_vaccines_data.dart`
//  for the argument in full; the short version is that this topic is the only
//  one in the stage with BOTH a deadline and a state. Rubella and varicella are
//  live vaccines — not immune means the jab plus a month of not conceiving —
//  and "am I immune?" is a question answered once, by a blood test, and then
//  carried for months.
//
//  ⚠️ THE SCREEN ANSWERS ONE QUESTION ABOVE ALL OTHERS: is there anything here
//  that means waiting? That sits at the top, computed, before any list. The
//  list is how she gets to an answer; the answer is what she came for.
//
//  ---------------------------------------------------------------------------
//  ⚠️ THE V3 LANGUAGE, NOT THE OLDER TTC CHROME
//  ---------------------------------------------------------------------------
//
//  `V2PaletteStore` for colour and `pv_fonts` for type, the same as
//  `PvReaderScreen` and `bs_article_screen.dart` — so a surface opened from a
//  read looks like it belongs to the read. The older TTC screens
//  (`ttc_tests_screen`, `ttc_supplements_screen`) use `ttc_common.dart`'s own
//  palette, which is the previous generation; matching that here would make the
//  newest surface in the stage the oldest-looking one.
//
//  Hairlines, not shadows. Flat tint, no gradient. One accent.
//
//  ⚠️ NEVER A DIAGNOSIS AND NEVER A SCHEDULE OF OUR OWN. Everything here is
//  what is usually advised; which vaccine SHE needs and when is her doctor's
//  call. The status she sets is a note to herself — see the store.
//
//  ---------------------------------------------------------------------------
//  ⚠️ THE TOOL REBUILD (2026-09-27, night): A RECORD, NOT A FORM
//  ---------------------------------------------------------------------------
//
//  After the afternoon pass every card showed four buttons for ever: a card
//  she had answered looked exactly like one she had not, so the list never
//  said what was done and what was still hers to do. The buttons were also
//  outlined in the accent, unlike every other tool's choices. Now:
//
//   · An answered card says its answer in one line ("Had it on 3 Sep",
//     "Clear to try from 1 Oct") with a Change beside it, and the four
//     choices come back only when she asks. An unanswered card shows the
//     choices. So the first look reads as done / still to do.
//   · "I need this" on a live vaccine carries its next step on the card:
//     "I've had it now", which asks the date. The wait is counted from it.
//   · The choices are the tool shell's: white with a hairline, ink when
//     chosen, two to a row, the same on every tool.
//   · "LIVE · 28-DAY WAIT" was a chip with an unexplained word. It is a
//     plain line now: "Live vaccine: wait 28 days after it before you try."
//   · The + / − that opened a card sat beside the choices and read as "add".
//     The card now ends in "More about this".
//   · The India note ("you'll need to ask, and you pay") was its own box
//     saying what the tests box says. It is one line inside that box now.
//   · The tests box leads while nothing is recorded, and moves under the
//     cards once she has started, because by then it is reference.
//   · Clearing an answer offers Undo: it can carry a date she looked up.
//
//  Shape from Mobbin (2026-09-27):
//   · Alan "Care events": each row says its state in words on the row itself,
//     grouped by what still needs doing:
//     https://mobbin.com/screens/2d6a5469-f0d4-490f-8315-d524556b534b
//   · Remote "All time off requests": a status line under each title, the
//     date beside it: https://mobbin.com/screens/a827e0ef-1ea8-4db8-85b0-9e3df9987165
//   · Oura "Logging a dose": the dose's date is its own row, "7 days until
//     next dose" said as a countdown:
//     https://mobbin.com/flows/fabfcfd5-f3cb-4e4d-8b5f-0bda061eb37a
//   · Zocdoc "Medical history": vaccinations as a record she adds to, the
//     value said in the row once it is filled:
//     https://mobbin.com/flows/ed8a5d8e-c649-4f31-8929-c49e780d7b74
// =============================================================================

import 'package:flutter/material.dart';

// Kept for revert (2026-09-27): only the old list's bottom padding read
// `kAskFabReserve`; `TtcToolScaffold`'s sheet clears the reserve itself.
// import '../../widgets/global_ask_fab.dart';

import '../../localization/app_language.dart';
import '../../theme/pv_fonts.dart';
import '../../ttc/ttc_vaccine_store.dart';
import '../../ttc/ttc_vaccines_data.dart';
import '../products/pv_store_chrome.dart' show pvSnack;
import '../v2/v2_palette.dart';
import 'ttc_common.dart' show ttcTitleInk, ttcLine;
import 'ttc_strings.dart';
import 'ttc_tool_chrome.dart';
import 'ttc_tool_hues.dart';

/// The bracket's own hue — Getting ready is 104, and a surface opened from that
/// door keeps its colour.
// ⚠️ LAUNCH SANITY T6 (2026-09-28): a tool's header wears its Tools group's
// colour (`ttc_tool_hues.dart`). Vaccinations sits in Care and medicines.
// Kept for revert (2026-09-28): const double _kHue = 104;
const double _kHue = kTtcToolHueCare;

class TtcVaccinesScreen extends StatefulWidget {
  const TtcVaccinesScreen({super.key});

  @override
  State<TtcVaccinesScreen> createState() => _TtcVaccinesScreenState();
}

class _TtcVaccinesScreenState extends State<TtcVaccinesScreen> {
  /// Which card is expanded. One at a time — six open cards is a wall, and the
  /// detail is only wanted for the one she is deciding about.
  String? _open;

  /// The four non-actionable vaccines, folded by default. See the note at the
  /// call site — six cards open is six problems to an anxious reader.
  bool _showRest = false;

  /// Answered cards she has asked to change. An answered card shows its
  /// answer; the choices come back only for the ones in here.
  final Set<String> _changing = {};

  @override
  void initState() {
    super.initState();
    TtcVaccineStore.instance.load();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge(
          [TtcVaccineStore.instance, V2PaletteStore.instance, TtcLang.instance]),
      builder: (context, _) {
        final p = V2PaletteStore.instance.current;
        final hi = TtcLang.instance.hinglish;
        final lang = hi ? AppLanguage.hinglish : AppLanguage.english;
        final store = TtcVaccineStore.instance;

        String t(String en, String hin) => hi ? hin : en;

        // ⚠️ ONE SHELL FOR EVERY TOOL (2026-09-27). Tiles in the same Tools
        // hub opened in two different shells: most wore `TtcToolScaffold`
        // (hero field, serif title, white sheet) and this one its own page
        // under a "GETTING READY" crumb, which named a door rather than the
        // page, and a title ("Vaccinations before trying") that did not
        // match its tile. Only the shell changed: the tile's name is the
        // hero title, the reassurance is the hero intro, and every block
        // below sits in the sheet unchanged. Kept for revert (2026-09-27):
        // return Scaffold(
        //   backgroundColor: p.ground,
        //   body: SafeArea(
        //     bottom: false,
        //     child: Column(children: [
        //       _bar(p, t),
        //       Expanded(
        //         child: ListView(
        //           padding: const EdgeInsets.fromLTRB(20, 4, 20, kAskFabReserve + 24),
        //           children: [
        //             Text(
        //                 t('Vaccinations before trying',
        //                     'Koshish se pehle vaccinations'),
        //                 style: pvFraunces(
        //                     fontSize: 28,
        //                     height: 1.15,
        //                     fontWeight: FontWeight.w600,
        //                     letterSpacing: -0.3,
        //                     color: p.ink1)),
        //             const SizedBox(height: 12),
        //             Text(<the reassurance, now the intro below>,
        //                 style: pvFraunces(
        //                     fontSize: 16.5, height: 1.55, color: p.ink2)),
        //             const SizedBox(height: 22),
        return TtcToolScaffold(
          // Care and medicines' hue in Tools (T6, 2026-09-28). Kept for
          // revert: "Getting ready's hue, which this screen always wore."
          hue: _kHue,
          // ⚠️ ONE TOOL, ONE NAME (2026-09-27): the eyebrow IS the Tools
          // tile's name, word for word; the title is the tile's own line.
          eyebrow: 'Vaccinations',
          title: 'Jabs to have before you get pregnant.',
          // ⚠️ THE REASSURANCE COMES FIRST, AND THE FIRST DRAFT
          // GOT THIS EXACTLY BACKWARDS.
          //
          // It opened with "two of these are live vaccines, which
          // means a month of not conceiving afterwards" — so the
          // first sentence an anxious woman read was that her plans
          // might be delayed. For roughly six women in seven that
          // sentence is not even true of them.
          //
          // The honest and calmer opening is the population fact:
          // most Indian women are already immune, and for most people
          // this whole page resolves to one blood test that comes
          // back fine. The wait still gets said — it is said where it
          // becomes relevant, which is after a result.
          // (What the page is for is the title above, so the intro stays
          // the reassurance, unchanged.)
          intro: t(
              'For most people this is one blood test that comes '
                  'back fine. About 85 in 100 Indian women are '
                  'already immune to rubella. The test is to find '
                  'out which group you\'re in, not to find '
                  'something wrong.',
              'Zyadatar logon ke liye ye ek blood test hai jo '
                  'theek aata hai. Lagbhag 100 mein se 85 Indian '
                  'auratein pehle se rubella immune hoti hain — '
                  'test ye jaanne ke liye hai ki aap kaunsi '
                  'hain, kuch galat dhoondhne ke liye nahi.'),
          children: [
            ttcToolPad(Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                    const SizedBox(height: 22),

                    // ---- THE ANSWER, BEFORE THE LIST ---------------------
                    //
                    // ⚠️ NOT ON A FIRST OPEN (launch sanity T8, 2026-09-28).
                    // With nothing recorded the answer was "One blood test
                    // settles most of this", and the box right under it said
                    // "Ask for these tests by name. One blood sample covers all
                    // of them": the page opened by saying one thing twice. On a
                    // first open the tests box is the one box, and it carries
                    // the rubella line the answer box used to. Once anything is
                    // recorded the answer has something of hers to say, so it
                    // comes back. Kept for revert (2026-09-28): drawn always.
                    if (!_firstOpen(store)) ...[
                      _verdict(p, store, t),
                      const SizedBox(height: 26),
                    ],

                    // ---- INDIA -------------------------------------------
                    //
                    // ⚠️ NOT A FOOTNOTE. In India everything on this page
                    // except Td is outside the Universal Immunization
                    // Programme, which means she pays and — far more
                    // importantly — nobody raises it unless she does. A
                    // vaccination screen that omits this is describing another
                    // country's health system.
                    //
                    // ⚠️ STILL SAID, NOW INSIDE THE TESTS BOX (tool rebuild,
                    // 2026-09-27): a second box saying "you'll need to ask"
                    // right above a box saying "ask for these by name" was
                    // the same instruction twice. Kept for revert:
                    // _uipNote(p, t),
                    // const SizedBox(height: 26),

                    // ---- WHAT TO DO FIRST ------------------------------
                    //
                    // ⚠️ THE MOST USEFUL BLOCK ON THE SCREEN, and it comes
                    // before any vaccine. Everything here is downstream of one
                    // blood test, and "ask about your immunity" is not
                    // something anyone can act on. A test has a NAME. Being
                    // able to say the name is the whole difference between a
                    // plan and an intention.
                    //
                    // ⚠️ FIRST ONLY UNTIL SHE HAS STARTED (tool rebuild,
                    // 2026-09-27). Once one of her three is answered, the
                    // cards are what she came back for and this box is
                    // reference, so it moves under them.
                    if (!_started(store)) ...[
                      _theAsk(p, t),
                      const SizedBox(height: 28),
                    ],

                    // ---- THE ONLY INTERACTIVE GROUP --------------------
                    _groupHead(
                        p,
                        t('BEFORE YOU START TRYING',
                            'KOSHISH SHURU KARNE SE PEHLE'),
                        // Kept for revert (2026-09-27, tools pass): 'These
                        // can add a month. Note down what you find out.' The
                        // buttons now sit on the closed card, so the line
                        // says where to tap.
                        t('These can add a month. Once you know, tap what '
                                'fits under each one.',
                            'In se ek mahina lag sakta hai. Jo pata chale, '
                                'yahan darj karein.')),
                    const SizedBox(height: 14),
                    for (final v in ttcVaccinesOn(TtcVaccineTrack.beforeTrying)) ...[
                      _card(p, lang, store, v, t, interactive: true),
                      const SizedBox(height: 12),
                    ],

                    const SizedBox(height: 20),

                    if (_started(store)) ...[
                      _theAsk(p, t),
                      const SizedBox(height: 20),
                    ],

                    // ---- EVERYTHING ELSE, FOLDED ------------------------
                    //
                    // ⚠️ SIX CARDS OPEN IS SIX PROBLEMS TO AN ANXIOUS READER,
                    // and only two of them are hers to act on today. The other
                    // four are either months away (Tdap, influenza) or already
                    // covered (Td) — real, worth having, and not tasks.
                    //
                    // Folded, with a label that says plainly there is nothing
                    // to do in here. The disclosure is the reassurance: she can
                    // see the list is finite and close it again.
                    _moreDisclosure(p, lang, store, t),
                    const SizedBox(height: 14),
                    _disclaimer(p, t),
                    // The old list's `+ 24` under the Ask Veda reserve; the
                    // sheet already clears the reserve itself.
                    const SizedBox(height: 24),
              ],
            )),
          ],
          // Kept for revert (2026-09-27): the old page's closing.
          //         ],
          //       ),
          //     ),
          //   ]),
          // ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------

  // Kept for revert (2026-09-27): the old back bar and its "GETTING READY"
  // crumb, which named the door rather than the page. `TtcToolScaffold`'s
  // close button and hero replace it.
  // Widget _bar(V2Palette p, String Function(String, String) t) => Padding(
  //       padding: const EdgeInsets.fromLTRB(8, 4, 8, 10),
  //       child: Row(children: [
  //         GestureDetector(
  //           onTap: () => Navigator.of(context).maybePop(),
  //           behavior: HitTestBehavior.opaque,
  //           child: Padding(
  //             padding: const EdgeInsets.all(10),
  //             child:
  //                 Icon(Icons.arrow_back_rounded, size: 21, color: p.ink1),
  //           ),
  //         ),
  //         Expanded(
  //           child: Text(t('Getting ready', 'Taiyaari').toUpperCase(),
  //               style: pvManrope(
  //                   fontSize: 11,
  //                   fontWeight: FontWeight.w800,
  //                   letterSpacing: 1.1,
  //                   color: p.ink3)),
  //         ),
  //       ]),
  //     );

  /// The computed answer: is anything holding her back?
  Widget _verdict(
      V2Palette p, TtcVaccineStore store, String Function(String, String) t) {
    final until = store.clearToTryFrom();
    final outstanding = store.liveOutstanding;
    final tint = v2BlockTint(_kHue, p);

    late final String head;
    late final String body;
    late final IconData icon;

    if (until != null) {
      final days = until.difference(DateTime.now()).inDays + 1;
      head = t('Best to wait until ${_date(until)}',
          '${_date(until)} tak rukna behtar');
      body = t(
          'That\'s about $days more ${days == 1 ? 'day' : 'days'}, counted '
              'from your live vaccine. Nothing else on this page needs a wait.',
          'Lagbhag $days aur din, live vaccine se gina hua. Is page par aur '
              'kisi cheez ke liye rukna nahi hai.');
      icon = Icons.hourglass_bottom_rounded;
    } else if (outstanding.isNotEmpty) {
      final names = outstanding.map((v) => v.name.en).join(t(' and ', ' aur '));
      // ⚠️ THE ANXIOUS STATE. She has just learned she is not immune, and the
      // useful thing to tell her is that the clock starts when she acts — so
      // acting today is the shortest possible version of this. Never "you
      // must wait"; always "the sooner it is done, the sooner it is over".
      head = t('$names first, then a month\'s wait',
          '$names lagwana hai, phir ek mahina');
      body = t(
          'The month counts from the dose, not from today. So booking it '
              'this week gets it over with soonest. Nothing else on the list '
              'needs a wait.',
          'Mahina dose se ginta hai, aaj se nahi — toh isi hafte lagwa lena '
              'sabse chhota rasta hai. List par aur kisi cheez ke liye rukna '
              'nahi hai.');
      icon = Icons.event_available_rounded;
    } else if (store.unrecorded == kTtcVaccines.length) {
      // ⚠️ THIS SAID "NOTHING RECORDED YET" AND THAT WAS THE WRONG SENTENCE.
      //
      // It is accurate and it frames her as already behind, on a screen she
      // has just opened, in a stage where the prevailing feeling is that she
      // is failing at something. An empty state is not a deficit — she has
      // simply arrived. Say what happens next instead of what has not
      // happened yet.
      head = t('One blood test settles most of this',
          'Ek blood test se zyadatar baat saaf ho jaati hai');
      body = t(
          'Rubella is the one worth doing first. If it shows you\'re immune, '
              'as it usually does, there\'s nothing more to do here.',
          'Rubella sabse pehle karwane layak hai. Agar immune aaya — jo aksar '
              'aata hai — toh yahan aur kuch karna nahi hai.');
      icon = Icons.science_outlined;
    } else {
      head = t('Nothing here is holding you back',
          'Yahan kuch bhi aapko rok nahi raha');
      body = t(
          'This is based on what you\'ve recorded. If a result changes, '
              'update it here so the date stays right.',
          'Jo aapne darj kiya uske hisaab se. Koi result badle toh yahan bhi '
              'badal dein, taaki tareekh sahi rahe.');
      icon = Icons.check_rounded;
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 17),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 19, color: const Color(0xFF2E3A2C)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(head,
                    style: pvFraunces(
                        fontSize: 17.5,
                        height: 1.3,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF23301F))),
                const SizedBox(height: 7),
                Text(body,
                    style: pvManrope(
                        fontSize: 13.5,
                        height: 1.6,
                        color: const Color(0xFF3D4A38))),
              ]),
        ),
      ]),
    );
  }

  // Kept for revert (2026-09-27, tool rebuild): the India note as its own
  // box. Its words now sit inside `_theAsk`.
  // Widget _uipNote(V2Palette p, String Function(String, String) t) => Container(
  //       padding: const EdgeInsets.fromLTRB(15, 14, 15, 15),
  //       decoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(16),
  //         border: Border.all(color: p.line),
  //       ),
  //       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
  //         Text(
  //             t('YOU\'LL NEED TO ASK', 'AAPKO MAANGNA HOGA'),
  //             style: pvManrope(
  //                 fontSize: 10.5,
  //                 fontWeight: FontWeight.w800,
  //                 letterSpacing: 1.1,
  //                 color: p.ink2)),
  //         const SizedBox(height: 9),
  //         Text(
  //             t(
  //                 'India\'s public programme covers Td at ten and sixteen, and '
  //                     'tetanus cover in pregnancy. Everything else here is '
  //                     'private. You pay for it, and a routine pregnancy '
  //                     'check-up won\'t ask if you\'re immune to rubella. Take '
  //                     'this list with you.',
  //                 'India ke public programme mein Td das aur solah saal par '
  //                     'milta hai, aur pregnancy mein tetanus. Baaki sab private '
  //                     'hai — paisa lagta hai, aur aam antenatal visit mein koi '
  //                     'nahi poochhega ki aap rubella immune hain ya nahi. Ye '
  //                     'list saath le jaayein.'),
  //             style: pvManrope(fontSize: 13.5, height: 1.62, color: p.ink2)),
  //       ]),
  //     );

  // ---------------------------------------------------------------------------

  /// "Ask for these by name" — the one actionable block.
  ///
  /// ⚠️ NAMES, NOT ADVICE. The difference between "check whether you are
  /// immune" and "ask for rubella IgG" is the difference between something she
  /// nods at and something she can say at a counter. Everything else on this
  /// screen is downstream of these three lines.
  Widget _theAsk(V2Palette p, String Function(String, String) t) => Container(
        padding: const EdgeInsets.fromLTRB(16, 15, 16, 17),
        decoration: BoxDecoration(
          color: p.surfaceAlt,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(t('START HERE', 'YAHAN SE SHURU'),
              style: pvManrope(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: p.action)),
          const SizedBox(height: 9),
          Text(
              t('Ask for these tests by name',
                  'Ye tests naam lekar maangein'),
              style: pvFraunces(
                  fontSize: 19,
                  height: 1.3,
                  fontWeight: FontWeight.w600,
                  color: p.ink1)),
          const SizedBox(height: 6),
          // T8 (2026-09-28): the rubella line from the answer box joins
          // here, so a first open says it once. Kept for revert: the first
          // two sentences alone.
          Text(
              t(
                  'One blood sample covers all of them. Everything else on '
                      'this page depends on the result. Rubella is the one '
                      "worth doing first: if it shows you're immune, as it "
                      "usually does, there's nothing more to do for it.",
                  'Ek hi blood test mein teenon ho jaate hain, aur is page ki '
                      'baaki har cheez uske result par tiki hai. Rubella sabse '
                      'pehle karwane layak hai. Agar immune aaya — jo aksar '
                      'aata hai — toh uske liye aur kuch karna nahi hai.'),
              style: pvManrope(fontSize: 13.5, height: 1.6, color: p.ink2)),
          const SizedBox(height: 15),
          for (final ask in kTtcVaccineAsks)
            Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  margin: const EdgeInsets.only(top: 7),
                  width: 5,
                  height: 5,
                  decoration:
                      BoxDecoration(color: p.action, shape: BoxShape.circle),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(ask,
                      style: pvManrope(
                          fontSize: 14.5, height: 1.5, color: p.ink1)),
                ),
              ]),
            ),
          // The India note, folded in here (tool rebuild, 2026-09-27). Its
          // words are the old `_uipNote`'s, unchanged.
          const SizedBox(height: 6),
          Divider(height: 1, thickness: 1, color: p.line),
          const SizedBox(height: 12),
          Text(
              t(
                  'India\'s public programme covers Td at ten and sixteen, and '
                      'tetanus cover in pregnancy. Everything else here is '
                      'private. You pay for it, and a routine pregnancy '
                      'check-up won\'t ask if you\'re immune to rubella. Take '
                      'this list with you.',
                  'India ke public programme mein Td das aur solah saal par '
                      'milta hai, aur pregnancy mein tetanus. Baaki sab private '
                      'hai — paisa lagta hai, aur aam antenatal visit mein koi '
                      'nahi poochhega ki aap rubella immune hain ya nahi. Ye '
                      'list saath le jaayein.'),
              style: pvManrope(fontSize: 13, height: 1.55, color: p.ink2)),
        ]),
      );

  /// Nothing recorded on any vaccine: the tests box is the page's one box
  /// (T8).
  bool _firstOpen(TtcVaccineStore store) =>
      store.unrecorded == kTtcVaccines.length;

  /// Whether she has answered any of the three "before trying" cards.
  bool _started(TtcVaccineStore store) =>
      ttcVaccinesOn(TtcVaccineTrack.beforeTrying)
          .any((v) => store.statusOf(v.id) != TtcVaccineStatus.unknown);

  /// The four vaccines that are not hers to act on today, behind one tap.
  ///
  /// ⚠️ THE LABEL PROMISES NOTHING TO DO, and that is deliberate. "Also on the
  /// full list" with "nothing here needs deciding today" under it lets her
  /// choose to look without the looking implying a task. A bare "4 more"
  /// reads as four more things she has not done.
  Widget _moreDisclosure(V2Palette p, AppLanguage lang, TtcVaccineStore store,
      String Function(String, String) t) {
    final later = ttcVaccinesOn(TtcVaccineTrack.inPregnancy);
    final background = ttcVaccinesOn(TtcVaccineTrack.background);
    final count = later.length + background.length;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      GestureDetector(
        onTap: () => setState(() => _showRest = !_showRest),
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(15, 14, 13, 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: p.line),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        t('The other $count on the full list',
                            'Poori list ke baaki $count'),
                        style: pvJakarta(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: p.ink1)),
                    const SizedBox(height: 5),
                    Text(
                        t(
                            'Nothing here needs deciding today. Two happen '
                                'during pregnancy, and you almost certainly '
                                'have the other one already.',
                            'Yahan aaj kuch tay nahi karna — do pregnancy ke '
                                'dauraan hote hain, aur ek lagbhag pakka aapke '
                                'paas pehle se hai.'),
                        style: pvManrope(
                            fontSize: 13, height: 1.5, color: p.ink3)),
                  ]),
            ),
            const SizedBox(width: 10),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(
                  _showRest
                      ? Icons.expand_less_rounded
                      : Icons.expand_more_rounded,
                  size: 20,
                  color: p.ink3),
            ),
          ]),
        ),
      ),
      if (_showRest) ...[
        const SizedBox(height: 18),
        _groupHead(
            p,
            t('LATER, IN PREGNANCY', 'BAAD MEIN, PREGNANCY MEIN'),
            t('Given at 27 to 36 weeks. Good to know now, so you can ask then.',
                '27 se 36 hafte ke beech. Pata ho toh tab maang sakti hain.')),
        const SizedBox(height: 14),
        for (final v in later) ...[
          _card(p, lang, store, v, t, interactive: false),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 8),
        _groupHead(
            p,
            t('YOU ALMOST CERTAINLY HAVE THIS', 'YE LAGBHAG PAKKA HAI'),
            t('The public programme gives this at ten and sixteen.',
                'Sarkari programme mein, das aur solah saal par.')),
        const SizedBox(height: 14),
        for (final v in background) ...[
          _card(p, lang, store, v, t, interactive: false),
          const SizedBox(height: 12),
        ],
      ],
    ]);
  }

  /// A group label plus the one line saying what this group asks of her.
  ///
  /// ⚠️ THE SUBLINE IS THE POINT. "Later, in pregnancy" without "nothing to do
  /// now" reads as three more items on a to-do list, which is precisely the
  /// anxiety this screen is meant to remove.
  Widget _groupHead(V2Palette p, String label, String sub) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: pvManrope(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: p.ink2)),
          const SizedBox(height: 6),
          Text(sub,
              style: pvManrope(fontSize: 13, height: 1.5, color: p.ink3)),
        ],
      );

  Widget _card(V2Palette p, AppLanguage lang, TtcVaccineStore store,
      TtcVaccine v, String Function(String, String) t,
      {required bool interactive}) {
    final open = _open == v.id;
    final status = store.statusOf(v.id);
    final choosing = interactive &&
        (status == TtcVaccineStatus.unknown || _changing.contains(v.id));

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: p.line),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 15, 16, 12),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(v.name.of(lang),
                    style: pvFraunces(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: p.ink1)),
                const SizedBox(height: 5),
                Text(v.protectsAgainst.of(lang),
                    style: pvManrope(
                        fontSize: 13, height: 1.45, color: p.ink2)),
                // ⚠️ "LIVE" SAID IN A SENTENCE, NOT A CHIP (tool rebuild,
                // 2026-09-27). Kept for revert: the chip beside the name,
                // _chip(p, t('LIVE · ${v.waitDays}-DAY WAIT', ...), p.ink1).
                if (v.isLive) ...[
                  const SizedBox(height: 8),
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 1),
                      child: Icon(Icons.hourglass_bottom_rounded,
                          size: 14, color: p.ink2),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                          t('Live vaccine: wait ${v.waitDays} days after it '
                                  'before you try.',
                              'Live vaccine: wait ${v.waitDays} days after it '
                                  'before you try.'),
                          style: pvManrope(
                              fontSize: 12.5,
                              height: 1.4,
                              fontWeight: FontWeight.w700,
                              color: p.ink2)),
                    ),
                  ]),
                ],
                // ⚠️ SAID ON THE CLOSED CARD (tools pass, 2026-09-27).
                // Hepatitis B sat in "before you start trying" with the
                // two that apply to nearly everyone, so the group read as
                // three to-dos when it is usually one or two.
                if (v.conditional != null) ...[
                  const SizedBox(height: 8),
                  _chip(p, t('ONLY IF A RISK APPLIES', 'ONLY IF A RISK APPLIES'),
                      p.ink3),
                ],
              ]),
        ),
        if (interactive)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: choosing
                ? _choices(p, store, v, status, t)
                : _answer(p, store, v, status, t),
          ),
        // ⚠️ "MORE ABOUT THIS", NOT A + (tool rebuild, 2026-09-27). The +
        // sat beside the choices and read as "add". Kept for revert: an
        // Icon(open ? Icons.remove_rounded : Icons.add_rounded) at the top
        // right of the card, the whole top of the card as its tap target.
        InkWell(
          key: ValueKey('ttc_vax_${v.id}_more'),
          onTap: () => setState(() => _open = open ? null : v.id),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
            decoration:
                BoxDecoration(border: Border(top: BorderSide(color: p.line))),
            child: Row(children: [
              Expanded(
                child: Text(
                    open
                        ? t('Show less', 'Show less')
                        : t('More about this', 'More about this'),
                    style: pvManrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: p.ink2)),
              ),
              Icon(
                  open
                      ? Icons.expand_less_rounded
                      : Icons.expand_more_rounded,
                  size: 20,
                  color: p.ink3),
            ]),
          ),
        ),
        if (open)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  // ⚠️ "LIVE" IS SAID IN WORDS (tools pass, 2026-09-27). The
                  // chip used the word without ever saying what a live
                  // vaccine is, and it is the whole reason for the wait.
                  if (v.isLive)
                    _field(
                        p,
                        lang,
                        t('WHAT LIVE MEANS', 'LIVE KA MATLAB'),
                        LocalizedText(
                            en: 'A live vaccine uses a weakened form of the '
                                'virus. So doctors advise waiting '
                                '${v.waitDays} days after it before you try.',
                            hi: 'A live vaccine uses a weakened form of the '
                                'virus. So doctors advise waiting '
                                '${v.waitDays} days after it before you try.')),
                  _field(p, lang, t('WHY IT MATTERS', 'KYUN ZAROORI HAI'),
                      v.why),
                  _field(p, lang, t('HOW YOU FIND OUT', 'PATA KAISE CHALEGA'),
                      v.howChecked),
                  _field(p, lang, t('WHAT IS USUALLY GIVEN', 'AAM TAUR PAR'),
                      v.schedule),
                  if (v.conditional != null)
                    _field(p, lang, t('ONLY IF', 'SIRF TAB'), v.conditional!),
                  if (v.note != null)
                    _field(p, lang, t('IN INDIA', 'INDIA MEIN'), v.note!),
                  if (v.inUip)
                    _field(
                        p,
                        lang,
                        t('PUBLIC PROGRAMME', 'SARKARI PROGRAMME'),
                        LocalizedText(
                            en: 'Covered by the Universal Immunization '
                                'Programme. It\'s the only one on this page '
                                'that is.',
                            hi: 'Universal Immunization Programme mein shaamil '
                                '— is page par sirf yahi.')),
                ]),
          ),
      ]),
    );
  }

  /// The four choices, two to a row, the tool shell's treatment: white with
  /// a hairline, ink when chosen.
  Widget _choices(V2Palette p, TtcVaccineStore store, TtcVaccine v,
      TtcVaccineStatus status, String Function(String, String) t) {
    final all = [
      for (final s in TtcVaccineStatus.values)
        if (s != TtcVaccineStatus.unknown) s,
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
          status == TtcVaccineStatus.unknown
              ? t('Once you know, tap what fits.', 'Once you know, tap what fits.')
              : t('Change your answer.', 'Change your answer.'),
          style: pvManrope(fontSize: 12, height: 1.4, color: p.ink3)),
      const SizedBox(height: 9),
      for (var i = 0; i < all.length; i += 2) ...[
        if (i > 0) const SizedBox(height: 8),
        IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Expanded(
                child: _statusButton(p, store, v, all[i], status == all[i], t)),
            const SizedBox(width: 8),
            Expanded(
                child: _statusButton(
                    p, store, v, all[i + 1], status == all[i + 1], t)),
          ]),
        ),
      ],
      if (status != TtcVaccineStatus.unknown) ...[
        const SizedBox(height: 10),
        Row(children: [
          TextButton(
            key: ValueKey('ttc_vax_${v.id}_keep'),
            onPressed: () => setState(() => _changing.remove(v.id)),
            child: Text(t('Keep my answer', 'Keep my answer'),
                style: pvManrope(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: p.ink1)),
          ),
          const Spacer(),
          TextButton(
            key: ValueKey('ttc_vax_${v.id}_clear'),
            onPressed: () => _clear(store, v, t),
            child: Text(t('Clear my answer', 'Hata dein'),
                style: pvManrope(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: p.ink3)),
          ),
        ]),
      ],
    ]);
  }

  /// An answered card: the answer in words, what it means next, and Change.
  Widget _answer(V2Palette p, TtcVaccineStore store, TtcVaccine v,
      TtcVaccineStatus status, String Function(String, String) t) {
    final had = store.doneOn(v.id);
    late final String head;
    late final String sub;
    late final IconData icon;
    Widget? next;

    switch (status) {
      case TtcVaccineStatus.immune:
        head = t('Already immune', 'Pehle se immune');
        sub = t('Nothing to do here.', 'Nothing to do here.');
        icon = Icons.verified_outlined;
      case TtcVaccineStatus.needed:
        head = t('You need this', 'Mujhe chahiye');
        sub = v.isLive
            ? t('The ${v.waitDays}-day wait starts on the day you have it, '
                    'so booking it soon ends it soonest.',
                'The ${v.waitDays}-day wait starts on the day you have it, '
                    'so booking it soon ends it soonest.')
            : t('Ask your doctor when to have it.',
                'Ask your doctor when to have it.');
        icon = Icons.event_available_rounded;
        next = _smallAction(
            p,
            ValueKey('ttc_vax_${v.id}_had_now'),
            t("I've had it now", "I've had it now"),
            () => _askWhen(store, v, t));
      case TtcVaccineStatus.done:
        head = had == null
            ? t('Had it', 'Lagwa liya')
            : t('Had it on ${_date(had)}', 'Had it on ${_date(had)}');
        if (v.isLive && had != null) {
          final until = had.add(Duration(days: v.waitDays));
          sub = until.isAfter(DateTime.now())
              ? t('Clear to try from ${_date(until)}.',
                  'Clear to try from ${_date(until)}.')
              : t('The ${v.waitDays}-day wait is over.',
                  'The ${v.waitDays}-day wait is over.');
        } else {
          sub = t('Nothing more to do.', 'Nothing more to do.');
        }
        icon = Icons.check_rounded;
        next = _smallAction(p, ValueKey('ttc_vax_${v.id}_date'),
            t('Change the date', 'Change the date'), () => _askWhen(store, v, t));
      case TtcVaccineStatus.notApplicable:
        head = t('Not for me', 'Mere liye nahi');
        sub = t('You marked this as not for you.',
            'You marked this as not for you.');
        icon = Icons.remove_circle_outline_rounded;
      case TtcVaccineStatus.unknown:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 11, 6, 11),
      decoration: BoxDecoration(
        color: v2BlockTint(_kHue, p),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(icon, size: 18, color: const Color(0xFF2E3A2C)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(head,
                key: ValueKey('ttc_vax_${v.id}_answer'),
                style: pvManrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF23301F))),
            const SizedBox(height: 3),
            Text(sub,
                style: pvManrope(
                    fontSize: 12.5,
                    height: 1.45,
                    color: const Color(0xFF3D4A38))),
            if (next != null) ...[
              const SizedBox(height: 8),
              next,
            ],
          ]),
        ),
        TextButton(
          key: ValueKey('ttc_vax_${v.id}_change'),
          onPressed: () => setState(() => _changing.add(v.id)),
          child: Text(t('Change', 'Change'),
              style: pvManrope(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF23301F),
                  decoration: TextDecoration.underline)),
        ),
      ]),
    );
  }

  /// A small ink-outlined pill for the one next step on an answered card.
  Widget _smallAction(
          V2Palette p, Key key, String label, VoidCallback onTap) =>
      InkWell(
        key: key,
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: ttcTitleInk, width: 1.2),
          ),
          child: Text(label,
              style: pvManrope(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: ttcTitleInk)),
        ),
      );

  /// Clears an answer, with Undo: it can carry a date she looked up.
  Future<void> _clear(TtcVaccineStore store, TtcVaccine v,
      String Function(String, String) t) async {
    final was = store.statusOf(v.id);
    final on = store.doneOn(v.id);
    setState(() => _changing.remove(v.id));
    await store.set(v.id, TtcVaccineStatus.unknown);
    if (!mounted) return;
    pvSnack(context, t('Answer cleared.', 'Answer cleared.'),
        action: t('Undo', 'Undo'),
        onAction: () => store.set(v.id, was, on: on),
        lift: 24);
  }

  // Kept for revert (2026-09-27, tool rebuild): the card that showed the
  // four choices for ever and opened on a +. Superseded by `_card`,
  // `_choices` and `_answer` above.
  // Widget _card(V2Palette p, AppLanguage lang, TtcVaccineStore store,
  //     TtcVaccine v, String Function(String, String) t,
  //     {required bool interactive}) {
  //   final open = _open == v.id;
  //   final status = store.statusOf(v.id);
  //
  //   return Container(
  //     clipBehavior: Clip.antiAlias,
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(18),
  //       border: Border.all(color: p.line),
  //     ),
  //     child: Column(children: [
  //       GestureDetector(
  //         onTap: () => setState(() => _open = open ? null : v.id),
  //         behavior: HitTestBehavior.opaque,
  //         child: Padding(
  //           padding: const EdgeInsets.fromLTRB(16, 15, 13, 15),
  //           child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
  //             Expanded(
  //               child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Row(children: [
  //                       Flexible(
  //                         child: Text(v.name.of(lang),
  //                             style: pvFraunces(
  //                                 fontSize: 18,
  //                                 fontWeight: FontWeight.w600,
  //                                 color: p.ink1)),
  //                       ),
  //                       if (v.isLive) ...[
  //                         const SizedBox(width: 8),
  //                         _chip(
  //                             p,
  //                             t('LIVE · ${v.waitDays}-DAY WAIT',
  //                                 'LIVE · ${v.waitDays} DIN'),
  //                             // ink, not amber — BASE-UI §4.0 (was 0xFFC98A25)
  //                             p.ink1),
  //                       ],
  //                     ]),
  //                     const SizedBox(height: 5),
  //                     Text(v.protectsAgainst.of(lang),
  //                         style: pvManrope(
  //                             fontSize: 13, height: 1.45, color: p.ink2)),
  //                     // ⚠️ SAID ON THE CLOSED CARD (tools pass, 2026-09-27).
  //                     // Hepatitis B sat in "before you start trying" with the
  //                     // two that apply to nearly everyone, so the group read as
  //                     // three to-dos when it is usually one or two.
  //                     if (v.conditional != null) ...[
  //                       const SizedBox(height: 7),
  //                       _chip(p, t('ONLY IF A RISK APPLIES', 'ONLY IF A RISK APPLIES'),
  //                           p.ink3),
  //                     ],
  //                     // Kept for revert (2026-09-27): the status as a quiet
  //                     // line, with the buttons only inside the opened card.
  //                     // if (interactive) ...[
  //                     //   const SizedBox(height: 9),
  //                     //   _statusPill(p, status, t),
  //                     // ],
  //                   ]),
  //             ),
  //             const SizedBox(width: 8),
  //             Padding(
  //               padding: const EdgeInsets.only(top: 4),
  //               child: Icon(
  //                   open ? Icons.remove_rounded : Icons.add_rounded,
  //                   size: 20,
  //                   color: p.ink3),
  //             ),
  //           ]),
  //         ),
  //       ),
  //       // ⚠️ THE BUTTONS ON THE CLOSED CARD (tools pass, 2026-09-27). They
  //       // only appeared once a card was opened, so the list looked read-only
  //       // and nobody found that she could record anything. Mobbin: CVS Health
  //       // puts the vaccine choices straight on the list as chips.
  //       if (interactive)
  //         Padding(
  //           padding: const EdgeInsets.fromLTRB(16, 0, 16, 15),
  //           child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Wrap(
  //                   spacing: 8,
  //                   runSpacing: 8,
  //                   children: [
  //                     for (final s in TtcVaccineStatus.values)
  //                       if (s != TtcVaccineStatus.unknown)
  //                         _statusButton(p, store, v, s, status == s, t),
  //                   ],
  //                 ),
  //                 if (status == TtcVaccineStatus.done &&
  //                     store.doneOn(v.id) != null) ...[
  //                   const SizedBox(height: 9),
  //                   GestureDetector(
  //                     onTap: () => _askWhen(store, v, t),
  //                     behavior: HitTestBehavior.opaque,
  //                     child: Text(
  //                         t('Had it on ${_date(store.doneOn(v.id)!)}. Change',
  //                             'Had it on ${_date(store.doneOn(v.id)!)}. Change'),
  //                         style: pvManrope(
  //                             fontSize: 12.5,
  //                             fontWeight: FontWeight.w700,
  //                             color: p.ink2)),
  //                   ),
  //                 ],
  //                 if (status != TtcVaccineStatus.unknown) ...[
  //                   const SizedBox(height: 10),
  //                   GestureDetector(
  //                     onTap: () => store.set(v.id, TtcVaccineStatus.unknown),
  //                     behavior: HitTestBehavior.opaque,
  //                     child: Text(t('Clear this', 'Hata dein'),
  //                         style: pvManrope(
  //                             fontSize: 12.5,
  //                             fontWeight: FontWeight.w700,
  //                             color: p.ink3,
  //                             decoration: TextDecoration.underline)),
  //                   ),
  //                 ],
  //               ]),
  //         ),
  //       if (open)
  //         Container(
  //           width: double.infinity,
  //           padding: const EdgeInsets.fromLTRB(16, 2, 16, 16),
  //           decoration:
  //               BoxDecoration(border: Border(top: BorderSide(color: p.line))),
  //           child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 const SizedBox(height: 14),
  //                 // ⚠️ "LIVE" IS SAID IN WORDS (tools pass, 2026-09-27). The
  //                 // chip used the word without ever saying what a live
  //                 // vaccine is, and it is the whole reason for the wait.
  //                 if (v.isLive)
  //                   _field(
  //                       p,
  //                       lang,
  //                       t('WHAT LIVE MEANS', 'LIVE KA MATLAB'),
  //                       LocalizedText(
  //                           en: 'A live vaccine uses a weakened form of the '
  //                               'virus. So doctors advise waiting '
  //                               '${v.waitDays} days after it before you try.',
  //                           hi: 'A live vaccine uses a weakened form of the '
  //                               'virus. So doctors advise waiting '
  //                               '${v.waitDays} days after it before you try.')),
  //                 _field(p, lang, t('WHY IT MATTERS', 'KYUN ZAROORI HAI'),
  //                     v.why),
  //                 _field(p, lang, t('HOW YOU FIND OUT', 'PATA KAISE CHALEGA'),
  //                     v.howChecked),
  //                 _field(p, lang, t('WHAT IS USUALLY GIVEN', 'AAM TAUR PAR'),
  //                     v.schedule),
  //                 if (v.conditional != null)
  //                   _field(p, lang, t('ONLY IF', 'SIRF TAB'), v.conditional!),
  //                 if (v.note != null)
  //                   _field(p, lang, t('IN INDIA', 'INDIA MEIN'), v.note!),
  //                 if (v.inUip)
  //                   _field(
  //                       p,
  //                       lang,
  //                       t('PUBLIC PROGRAMME', 'SARKARI PROGRAMME'),
  //                       LocalizedText(
  //                           en: 'Covered by the Universal Immunization '
  //                               'Programme. It\'s the only one on this page '
  //                               'that is.',
  //                           hi: 'Universal Immunization Programme mein shaamil '
  //                               '— is page par sirf yahi.')),
  //                 const SizedBox(height: 2),
  //                 // Kept for revert (2026-09-27): the status buttons lived
  //                 // here, inside the opened card, under "WHERE YOU STAND".
  //                 // They now sit on the closed card, above.
  //                 // if (interactive) ...[
  //                 // const SizedBox(height: 6),
  //                 // Text(t('WHERE YOU STAND', 'AAP KAHAN HAIN'), ...),
  //                 // const SizedBox(height: 10),
  //                 // Wrap(... _statusButton(p, store, v, s, status == s, t) ...),
  //                 // if (status != TtcVaccineStatus.unknown) ...[
  //                 //   GestureDetector(... t('Clear this', 'Hata dein') ...),
  //                 // ],
  //                 // ],
  //               ]),
  //         ),
  //     ]),
  //   );
  // }

  Widget _field(
          V2Palette p, AppLanguage lang, String label, LocalizedText value) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: pvManrope(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: p.ink3)),
          const SizedBox(height: 6),
          Text(value.of(lang),
              style: pvManrope(fontSize: 13.5, height: 1.65, color: p.ink2)),
        ]),
      );

  Widget _chip(V2Palette p, String label, Color c) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: c.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(label,
            style: pvManrope(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.7,
                color: c)),
      );

  // Kept for revert (2026-09-27): the closed card's quiet status line, now
  // replaced by the buttons themselves.
  // Widget _statusPill(
  //     V2Palette p, TtcVaccineStatus s, String Function(String, String) t) {
  //   if (s == TtcVaccineStatus.unknown) {
  //     return Text(t('Not recorded yet', 'Abhi darj nahi'),
  //         style: pvManrope(fontSize: 12, color: p.ink3));
  //   }
  //   return Text('· ${_statusLabel(s, t)}',
  //       style: pvManrope(
  //           fontSize: 12.5, fontWeight: FontWeight.w700, color: p.action));
  // }

  Widget _statusButton(V2Palette p, TtcVaccineStore store, TtcVaccine v,
      TtcVaccineStatus s, bool on, String Function(String, String) t) {
    return GestureDetector(
      key: ValueKey('ttc_vax_${v.id}_${s.name}'),
      // ⚠️ "HAD IT" ASKS WHEN (tools pass, 2026-09-27). It saved today's date,
      // so a jab three weeks ago started the wait today and the screen told
      // her to wait three weeks longer than she needs to, on the one screen
      // whose job is that date. Kept for revert: onTap: () => store.set(v.id, s),
      onTap: () {
        if (s == TtcVaccineStatus.done) {
          _askWhen(store, v, t);
          return;
        }
        setState(() => _changing.remove(v.id));
        store.set(v.id, s);
      },
      behavior: HitTestBehavior.opaque,
      // ⚠️ THE TOOL SHELL'S CHOICE, NOT AN ACCENT OUTLINE (tool rebuild,
      // 2026-09-27): white with a hairline at rest, ink when chosen, the same
      // as `TtcToolOptions` on every other tool. Kept for revert: a pill
      // outlined and tinted in `p.action` when on, `p.line` when not.
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: on ? ttcTitleInk : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: on ? ttcTitleInk : ttcLine, width: 1.5),
        ),
        child: Text(_statusLabel(s, t),
            textAlign: TextAlign.center,
            style: pvManrope(
                fontSize: 12.5,
                height: 1.25,
                fontWeight: on ? FontWeight.w800 : FontWeight.w600,
                color: on ? Colors.white : ttcTitleInk)),
      ),
    );
  }

  /// "When did you have it?", with today already chosen.
  ///
  /// A closed picker records nothing, rather than quietly saving today: the
  /// date is what the wait is counted from, so a guess would be worse than a
  /// blank. Mobbin: MyFitnessPal's "Date: Today" row, a past date picked with
  /// today as the default.
  Future<void> _askWhen(TtcVaccineStore store, TtcVaccine v,
      String Function(String, String) t) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final had = store.doneOn(v.id);
    final picked = await showDatePicker(
      context: context,
      helpText: t('When did you have it?', 'When did you have it?'),
      initialDate: had != null && !had.isAfter(today) ? had : today,
      firstDate: DateTime(today.year - 5),
      // Not in the future: a date to come is not a dose she has had.
      lastDate: today,
    );
    if (picked == null || !mounted) return;
    setState(() => _changing.remove(v.id));
    await store.set(v.id, TtcVaccineStatus.done, on: picked);
  }

  // ⚠️ FOUR ANSWERS SHE CAN TELL APART (launch sanity T8, 2026-09-28).
  // "Already immune" and "Had it" read as the same thing. The walk asked for
  // three answers with "Immune (test or vaccine)", but that would fold "had
  // the jab" into "immune", and for a live vaccine the jab's DATE is what
  // starts the month's wait before trying. So the four stay (the persisted
  // enum names do not move) and each now says HOW she knows: a test, or the
  // jab itself. Kept for revert (2026-09-28): 'Already immune', 'I need
  // this', 'Had it', 'Not for me'.
  String _statusLabel(TtcVaccineStatus s, String Function(String, String) t) =>
      switch (s) {
        TtcVaccineStatus.unknown => t('Not recorded', 'Darj nahi'),
        TtcVaccineStatus.immune =>
          t('Immune (a test says so)', 'Pehle se immune'),
        TtcVaccineStatus.needed => t('Need it', 'Mujhe chahiye'),
        TtcVaccineStatus.done => t('Had the jab', 'Lagwa liya'),
        TtcVaccineStatus.notApplicable => t('Not for me', 'Mere liye nahi'),
      };

  Widget _disclaimer(V2Palette p, String Function(String, String) t) => Text(
      t(
          'This keeps a note of what you tell it and explains what\'s usually '
              'advised. Which vaccine you need, and when, is your doctor\'s '
              'decision. Take this list to them instead of acting on it alone.',
          'Ye wahi darj karta hai jo aap batate hain, aur ye batata hai ki aam '
              'taur par kya salaah hoti hai. Aapko kaunsa vaccine chahiye aur '
              'kab — ye faisla aapke doctor ka hai. Ye list unke paas le '
              'jaayein, khud se faisla na lein.'),
      style: pvManrope(fontSize: 12, height: 1.6, color: p.ink3));

  String _date(DateTime d) {
    const m = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${m[d.month - 1]}';
  }
}
