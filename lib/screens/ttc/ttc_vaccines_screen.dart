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
// =============================================================================

import 'package:flutter/material.dart';

import '../../widgets/global_ask_fab.dart';

import '../../localization/app_language.dart';
import '../../theme/pv_fonts.dart';
import '../../ttc/ttc_vaccine_store.dart';
import '../../ttc/ttc_vaccines_data.dart';
import '../v2/v2_palette.dart';
import 'ttc_strings.dart';

/// The bracket's own hue — Getting ready is 104, and a surface opened from that
/// door keeps its colour.
const double _kHue = 104;

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

        return Scaffold(
          backgroundColor: p.ground,
          body: SafeArea(
            bottom: false,
            child: Column(children: [
              _bar(p, t),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, kAskFabReserve + 24),
                  children: [
                    Text(
                        t('Vaccinations before trying',
                            'Koshish se pehle vaccinations'),
                        style: pvFraunces(
                            fontSize: 28,
                            height: 1.15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
                            color: p.ink1)),
                    const SizedBox(height: 12),
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
                    Text(
                        t(
                            'For most people this is one blood test that comes '
                                'back fine. About 85 in 100 Indian women are '
                                'already immune to rubella — the test is to '
                                'find out which you are, not to find something '
                                'wrong.',
                            'Zyadatar logon ke liye ye ek blood test hai jo '
                                'theek aata hai. Lagbhag 100 mein se 85 Indian '
                                'auratein pehle se rubella immune hoti hain — '
                                'test ye jaanne ke liye hai ki aap kaunsi '
                                'hain, kuch galat dhoondhne ke liye nahi.'),
                        style: pvFraunces(
                            fontSize: 16.5, height: 1.55, color: p.ink2)),
                    const SizedBox(height: 22),

                    // ---- THE ANSWER, BEFORE THE LIST ---------------------
                    _verdict(p, store, t),
                    const SizedBox(height: 26),

                    // ---- INDIA -------------------------------------------
                    //
                    // ⚠️ NOT A FOOTNOTE. In India everything on this page
                    // except Td is outside the Universal Immunization
                    // Programme, which means she pays and — far more
                    // importantly — nobody raises it unless she does. A
                    // vaccination screen that omits this is describing another
                    // country's health system.
                    _uipNote(p, t),
                    const SizedBox(height: 26),

                    // ---- WHAT TO DO FIRST ------------------------------
                    //
                    // ⚠️ THE MOST USEFUL BLOCK ON THE SCREEN, and it comes
                    // before any vaccine. Everything here is downstream of one
                    // blood test, and "ask about your immunity" is not
                    // something anyone can act on. A test has a NAME. Being
                    // able to say the name is the whole difference between a
                    // plan and an intention.
                    _theAsk(p, t),
                    const SizedBox(height: 28),

                    // ---- THE ONLY INTERACTIVE GROUP --------------------
                    _groupHead(
                        p,
                        t('BEFORE YOU START TRYING',
                            'KOSHISH SHURU KARNE SE PEHLE'),
                        t('These can add a month. Record what you find out.',
                            'In se ek mahina lag sakta hai. Jo pata chale, '
                                'yahan darj karein.')),
                    const SizedBox(height: 14),
                    for (final v in ttcVaccinesOn(TtcVaccineTrack.beforeTrying)) ...[
                      _card(p, lang, store, v, t, interactive: true),
                      const SizedBox(height: 12),
                    ],

                    const SizedBox(height: 20),

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
                  ],
                ),
              ),
            ]),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------

  Widget _bar(V2Palette p, String Function(String, String) t) => Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 10),
        child: Row(children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child:
                  Icon(Icons.arrow_back_rounded, size: 21, color: p.ink1),
            ),
          ),
          Expanded(
            child: Text(t('Getting ready', 'Taiyaari').toUpperCase(),
                style: pvManrope(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    color: p.ink3)),
          ),
        ]),
      );

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
      head = t('Worth waiting until ${_date(until)}',
          '${_date(until)} tak rukna behtar');
      body = t(
          'That is about $days more ${days == 1 ? 'day' : 'days'}, counted '
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
      head = t('$names to have, then a month',
          '$names lagwana hai, phir ek mahina');
      body = t(
          'The month counts from the dose, not from today — so booking it '
              'this week is the shortest version of this. Nothing else on the '
              'list needs a wait.',
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
          'Rubella is the one worth doing first. If it comes back immune — '
              'which it usually does — there is nothing further to do here.',
          'Rubella sabse pehle karwane layak hai. Agar immune aaya — jo aksar '
              'aata hai — toh yahan aur kuch karna nahi hai.');
      icon = Icons.science_outlined;
    } else {
      head = t('Nothing here is holding you back',
          'Yahan kuch bhi aapko rok nahi raha');
      body = t(
          'Based on what you have recorded. If a result changes, update it '
              'here so the date stays right.',
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

  Widget _uipNote(V2Palette p, String Function(String, String) t) => Container(
        padding: const EdgeInsets.fromLTRB(15, 14, 15, 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: p.line),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
              t('YOU WILL NEED TO ASK', 'AAPKO MAANGNA HOGA'),
              style: pvManrope(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: p.ink2)),
          const SizedBox(height: 9),
          Text(
              t(
                  'India\'s public programme covers Td at ten and sixteen, and '
                      'tetanus cover in pregnancy. Everything else here is '
                      'private — you pay for it, and a routine antenatal visit '
                      'will not ask whether you are rubella immune. Take this '
                      'list with you.',
                  'India ke public programme mein Td das aur solah saal par '
                      'milta hai, aur pregnancy mein tetanus. Baaki sab private '
                      'hai — paisa lagta hai, aur aam antenatal visit mein koi '
                      'nahi poochhega ki aap rubella immune hain ya nahi. Ye '
                      'list saath le jaayein.'),
              style: pvManrope(fontSize: 13.5, height: 1.62, color: p.ink2)),
        ]),
      );

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
          Text(
              t(
                  'One blood draw covers all of them, and everything else on '
                      'this page follows from the result.',
                  'Ek hi blood test mein teenon ho jaate hain, aur is page ki '
                      'baaki har cheez uske result par tiki hai.'),
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
        ]),
      );

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
                            'Nothing here needs deciding today — two happen '
                                'during pregnancy, and one you almost certainly '
                                'already have.',
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
            t('Given at 27 to 36 weeks. Worth knowing so you can ask then.',
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
            t('Covered by the public programme, at ten and sixteen.',
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

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: p.line),
      ),
      child: Column(children: [
        GestureDetector(
          onTap: () => setState(() => _open = open ? null : v.id),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 15, 13, 15),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Flexible(
                          child: Text(v.name.of(lang),
                              style: pvFraunces(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: p.ink1)),
                        ),
                        if (v.isLive) ...[
                          const SizedBox(width: 8),
                          _chip(
                              p,
                              t('LIVE · ${v.waitDays}-DAY WAIT',
                                  'LIVE · ${v.waitDays} DIN'),
                              // ink, not amber — BASE-UI §4.0 (was 0xFFC98A25)
                              p.ink1),
                        ],
                      ]),
                      const SizedBox(height: 5),
                      Text(v.protectsAgainst.of(lang),
                          style: pvManrope(
                              fontSize: 13, height: 1.45, color: p.ink2)),
                      if (interactive) ...[
                        const SizedBox(height: 9),
                        _statusPill(p, status, t),
                      ],
                    ]),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Icon(
                    open ? Icons.remove_rounded : Icons.add_rounded,
                    size: 20,
                    color: p.ink3),
              ),
            ]),
          ),
        ),
        if (open)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 16),
            decoration:
                BoxDecoration(border: Border(top: BorderSide(color: p.line))),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 14),
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
                                'Programme — the one thing here that is.',
                            hi: 'Universal Immunization Programme mein shaamil '
                                '— is page par sirf yahi.')),
                  if (!interactive) const SizedBox(height: 2),
                  if (interactive) ...[
                  const SizedBox(height: 6),
                  Text(t('WHERE YOU STAND', 'AAP KAHAN HAIN'),
                      style: pvManrope(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                          color: p.ink3)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final s in TtcVaccineStatus.values)
                        if (s != TtcVaccineStatus.unknown)
                          _statusButton(p, store, v, s, status == s, t),
                    ],
                  ),
                  if (status != TtcVaccineStatus.unknown) ...[
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => store.set(v.id, TtcVaccineStatus.unknown),
                      behavior: HitTestBehavior.opaque,
                      child: Text(t('Clear this', 'Hata dein'),
                          style: pvManrope(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: p.ink3,
                              decoration: TextDecoration.underline)),
                    ),
                  ],
                  ],
                ]),
          ),
      ]),
    );
  }

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

  Widget _statusPill(
      V2Palette p, TtcVaccineStatus s, String Function(String, String) t) {
    if (s == TtcVaccineStatus.unknown) {
      return Text(t('Not recorded yet', 'Abhi darj nahi'),
          style: pvManrope(fontSize: 12, color: p.ink3));
    }
    return Text('· ${_statusLabel(s, t)}',
        style: pvManrope(
            fontSize: 12.5, fontWeight: FontWeight.w700, color: p.action));
  }

  Widget _statusButton(V2Palette p, TtcVaccineStore store, TtcVaccine v,
      TtcVaccineStatus s, bool on, String Function(String, String) t) {
    return GestureDetector(
      onTap: () => store.set(v.id, s),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        decoration: BoxDecoration(
          color: on ? p.action.withValues(alpha: 0.10) : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border:
              Border.all(color: on ? p.action : p.line, width: on ? 1.4 : 1),
        ),
        child: Text(_statusLabel(s, t),
            style: pvManrope(
                fontSize: 12.5,
                fontWeight: on ? FontWeight.w800 : FontWeight.w600,
                color: on ? p.action : p.ink2)),
      ),
    );
  }

  String _statusLabel(TtcVaccineStatus s, String Function(String, String) t) =>
      switch (s) {
        TtcVaccineStatus.unknown => t('Not recorded', 'Darj nahi'),
        TtcVaccineStatus.immune => t('Already immune', 'Pehle se immune'),
        TtcVaccineStatus.needed => t('I need this', 'Mujhe chahiye'),
        TtcVaccineStatus.done => t('Had it', 'Lagwa liya'),
        TtcVaccineStatus.notApplicable => t('Not for me', 'Mere liye nahi'),
      };

  Widget _disclaimer(V2Palette p, String Function(String, String) t) => Text(
      t(
          'This records what you tell it and explains what is usually advised. '
              'Which vaccine you need, and when, is your doctor\'s decision — '
              'take this list to them rather than acting on it alone.',
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
