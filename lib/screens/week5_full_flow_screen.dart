// =============================================================================
//  Week5FullFlowView - the "Full" Week 5 preview flow
// -----------------------------------------------------------------------------
//  Renders the COMPLETE Week 5 content doc (week5_full_data.dart) section by
//  section: Opening Snapshot · About Your Baby · Baby Science · You This Week ·
//  Health (Symptoms + Diet) · Trimester Tips · Share With Partner. Shown as an
//  alternative to the schema-driven V2 WeekFlowView, behind the Standard|Full
//  toggle on the weekly screen, so the fuller content shape can be compared.
//  Mother palette (purple); bilingual via the controller's language.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/week5_full_data.dart';
import '../localization/app_language.dart';
import '../services/pregnancy_controller.dart';
import '../theme/app_theme.dart';

class Week5FullFlowView extends StatefulWidget {
  const Week5FullFlowView({super.key, required this.controller});
  final PregnancyController controller;

  @override
  State<Week5FullFlowView> createState() => _Week5FullFlowViewState();
}

class _Week5FullFlowViewState extends State<Week5FullFlowView> {
  final Set<int> _openTips = {};

  static const _shadow = [
    BoxShadow(color: Color(0x0F2D144C), blurRadius: 22, offset: Offset(0, 10)),
  ];

  AppLanguage get _lang => widget.controller.language;
  String _tr(LocalizedText t) => t.of(_lang);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final w = week5Full;
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 120),
          children: [
            _snapshot(w),
            const SizedBox(height: 18),
            _aboutBaby(w),
            const SizedBox(height: 22),
            _babyScience(w),
            const SizedBox(height: 22),
            _youThisWeek(w),
            const SizedBox(height: 22),
            _symptoms(w),
            const SizedBox(height: 22),
            _diet(w),
            const SizedBox(height: 22),
            _trimesterTips(w),
            const SizedBox(height: 22),
            _partner(w),
            const SizedBox(height: 24),
            _footer(
              "This is for understanding, not diagnosis — your doctor is always the best guide.",
              'Yeh samajhne ke liye hai, diagnosis ke liye nahi — tumhara doctor hamesha sabse accha maargdarshak hai.',
            ),
          ],
        );
      },
    );
  }

  // ---- shared bits ----------------------------------------------------------
  TextStyle get _title => GoogleFonts.plusJakartaSans(
      fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.primary900);
  TextStyle get _cardTitle => GoogleFonts.plusJakartaSans(
      fontSize: 15.5, fontWeight: FontWeight.w800, color: AppTheme.primary900);
  TextStyle _body([Color? c]) => GoogleFonts.manrope(
      fontSize: 13.5, height: 1.6, color: c ?? AppTheme.neutral700);
  TextStyle get _eyebrow => GoogleFonts.manrope(
      fontSize: 11,
      fontWeight: FontWeight.w800,
      letterSpacing: 1.2,
      color: AppTheme.primary500);

  Widget _sectionHeader(String en, String hi, {String? subEn, String? subHi}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(_lang.isEnglish ? en : hi, style: _title),
      if (subEn != null) ...[
        const SizedBox(height: 4),
        Text(_lang.isEnglish ? subEn : (subHi ?? subEn), style: _body(AppTheme.neutral600)),
      ],
    ]);
  }

  Widget _plainCard({required Widget child, EdgeInsets? padding}) => Container(
        width: double.infinity,
        padding: padding ?? const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppTheme.outlineVariant),
          boxShadow: _shadow,
        ),
        child: child,
      );

  Widget _labelled(String label, String value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: _eyebrow),
          const SizedBox(height: 6),
          Text(value, style: _body(AppTheme.neutral800)),
        ],
      );

  void _sheet(String title, List<Widget> children) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        expand: false,
        builder: (context, scroll) => Container(
          decoration: const BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: ListView(
            controller: scroll,
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                      color: AppTheme.outlineVariant,
                      borderRadius: BorderRadius.circular(99)),
                ),
              ),
              const SizedBox(height: 18),
              Text(title, style: _title),
              const SizedBox(height: 12),
              ...children,
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).maybePop(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                    decoration: BoxDecoration(
                        color: AppTheme.primary500,
                        borderRadius: BorderRadius.circular(99)),
                    child: Text(_lang.isEnglish ? 'Got it' : 'Samajh gaya',
                        style: GoogleFonts.manrope(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tapRow({required IconData icon, required String title, String? sub, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.outlineVariant),
            boxShadow: _shadow,
          ),
          child: Row(children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: AppTheme.primary50, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, size: 20, color: AppTheme.primary500),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: _cardTitle, maxLines: 2, overflow: TextOverflow.ellipsis),
                if (sub != null) ...[
                  const SizedBox(height: 2),
                  Text(sub, style: _body(AppTheme.neutral600), maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ]),
            ),
            const Icon(Icons.chevron_right_rounded, size: 20, color: AppTheme.neutral400),
          ]),
        ),
      ),
    );
  }

  Widget _footer(String en, String hi) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(_lang.isEnglish ? en : hi,
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
                fontSize: 11.5, height: 1.55, color: AppTheme.neutral500)),
      );

  // ---- 1 · Opening Snapshot -------------------------------------------------
  Widget _snapshot(Week5Full w) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primary50, AppTheme.primary100.withValues(alpha: 0.6)],
        ),
        border: Border.all(color: AppTheme.primary100),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 54,
            height: 54,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: AppTheme.surface, borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.spa_rounded, color: AppTheme.primary500, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_lang.isEnglish ? 'This week, baby is about a' : 'Is hafte, baby lagbhag ek',
                  style: _body(AppTheme.neutral600)),
              const SizedBox(height: 2),
              Text(_tr(w.snapshot.fruit), style: _title),
            ]),
          ),
        ]),
        const SizedBox(height: 18),
        Row(children: [
          Expanded(child: _labelled(_lang.isEnglish ? 'Length' : 'Lambaai', _tr(w.snapshot.length))),
          Expanded(child: _labelled(_lang.isEnglish ? 'Weight' : 'Wazan', _tr(w.snapshot.weight))),
        ]),
      ]),
    );
  }

  // ---- 2 · About Your Baby --------------------------------------------------
  Widget _aboutBaby(Week5Full w) {
    return _plainCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(_lang.isEnglish ? 'ABOUT YOUR BABY' : 'TUMHARE BABY KE BAARE MEIN', style: _eyebrow),
        const SizedBox(height: 10),
        Text(_tr(w.about.teaser),
            style: GoogleFonts.fraunces(
                fontSize: 18, height: 1.4, color: AppTheme.primary900, fontWeight: FontWeight.w500)),
        const SizedBox(height: 18),
        _aboutBlock(_lang.isEnglish ? 'In my words' : 'Meri zubaani', _tr(w.about.opening)),
        const SizedBox(height: 14),
        _aboutBlock(_lang.isEnglish ? 'How big am I' : 'Main kitna bada hoon', _tr(w.about.howBig)),
        const SizedBox(height: 14),
        _aboutBlock(_lang.isEnglish ? "What's happening this week" : 'Is hafte kya ho raha hai', _tr(w.about.whatsHappening)),
        // Behavioural highlights: inline heading + description, never a card.
        for (final b in w.about.behaviour) ...[
          const SizedBox(height: 14),
          _aboutBlock(_tr(b.title), _tr(b.body)),
        ],
      ]),
    );
  }

  Widget _aboutBlock(String label, String value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: _cardTitle),
          const SizedBox(height: 5),
          Text(value, style: _body()),
        ],
      );

  // ---- 3 · Baby Science -----------------------------------------------------
  Widget _babyScience(Week5Full w) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionHeader('Baby Science', 'Baby Science',
          subEn: 'Tap any to understand it.', subHi: 'Samajhne ke liye kisi par bhi tap karo.'),
      const SizedBox(height: 14),
      for (final c in w.science)
        _tapRow(
          icon: Icons.science_outlined,
          title: _tr(c.title),
          onTap: () => _sheet(_tr(c.title), [Text(_tr(c.body), style: _body())]),
        ),
    ]);
  }

  // ---- 4 · You This Week ----------------------------------------------------
  Widget _youThisWeek(Week5Full w) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionHeader('You This Week', 'Is Hafte Tum'),
      const SizedBox(height: 14),
      _plainCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _aboutBlock(_lang.isEnglish ? 'How you might be feeling' : 'Tum kaisa mehsoos kar sakti ho', _tr(w.you.feeling)),
          const SizedBox(height: 14),
          _aboutBlock(_lang.isEnglish ? 'Your changing body' : 'Tumhara badalta body', _tr(w.you.changingBody)),
          const SizedBox(height: 14),
          _aboutBlock(_lang.isEnglish ? 'Be kind to yourself' : 'Apne saath naram raho', _tr(w.you.beKind)),
        ]),
      ),
      const SizedBox(height: 16),
      Text(_lang.isEnglish ? 'Highlights' : 'Khaas baatein', style: _cardTitle),
      const SizedBox(height: 12),
      for (final h in w.you.highlights)
        _tapRow(
          icon: Icons.auto_awesome_outlined,
          title: _tr(h.title),
          sub: _tr(h.teaser),
          onTap: () => _sheet(_tr(h.title), [
            Text(_tr(h.teaser), style: _body(AppTheme.primary600)),
            const SizedBox(height: 12),
            Text(_tr(h.body), style: _body()),
          ]),
        ),
      const SizedBox(height: 6),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: AppTheme.primary50, borderRadius: BorderRadius.circular(16)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.favorite_rounded, size: 18, color: AppTheme.primary500),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_lang.isEnglish ? 'Self-care' : 'Self-care', style: _cardTitle),
              const SizedBox(height: 4),
              Text(_tr(w.you.selfCare), style: _body()),
            ]),
          ),
        ]),
      ),
    ]);
  }

  // ---- 5 · Health · Symptoms ------------------------------------------------
  Widget _symptoms(Week5Full w) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionHeader('Health this week · Symptoms', 'Is hafte sehat · Lakshan',
          subEn: 'Common, normal things you may notice now — tap any to understand it and what helps.',
          subHi: 'Aam, normal cheezein jo abhi mehsoos ho sakti hain — samajhne ke liye kisi par bhi tap karo.'),
      const SizedBox(height: 14),
      for (final s in w.symptoms)
        _tapRow(
          icon: Icons.monitor_heart_outlined,
          title: _tr(s.name),
          sub: _tr(s.teaser),
          onTap: () => _sheet(_tr(s.name), [
            Text(_tr(s.teaser), style: _body(AppTheme.neutral600)),
            const SizedBox(height: 16),
            _sheetLabel(_lang.isEnglish ? 'HOW COMMON IS IT?' : 'YEH KITNA AAM HAI?'),
            Text(_tr(s.howCommon), style: _body()),
            const SizedBox(height: 14),
            _sheetLabel(_lang.isEnglish ? 'WHY IT HAPPENS' : 'AISA KYUN HOTA HAI'),
            Text(_tr(s.why), style: _body()),
            const SizedBox(height: 14),
            _sheetLabel(_lang.isEnglish ? 'WHAT MAY HELP' : 'KYA MADAD KAR SAKTA HAI'),
            for (final h in s.helps)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 6, right: 8),
                    child: Icon(Icons.check_circle, size: 14, color: AppTheme.primary500),
                  ),
                  Expanded(child: Text(_tr(h), style: _body())),
                ]),
              ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: const Color(0xFFFDECEC),
                  borderRadius: BorderRadius.circular(14)),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.info_outline_rounded, size: 16, color: AppTheme.danger),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(_lang.isEnglish ? 'WHEN TO CONTACT YOUR DOCTOR' : 'DOCTOR SE KAB SAMPARK KARO',
                        style: GoogleFonts.manrope(
                            fontSize: 10.5, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: AppTheme.danger)),
                    const SizedBox(height: 4),
                    Text(_tr(s.whenDoctor), style: _body(AppTheme.neutral800)),
                  ]),
                ),
              ]),
            ),
          ]),
        ),
      const SizedBox(height: 6),
      _footer(
        "If you notice any spotting, bleeding, or anything that does not feel right to you, please check with your doctor. It is always okay to ask.",
        'Agar koi spotting, bleeding, ya kuch bhi jo theek na lage dikhe, to apne doctor se jaanch karwao. Poochhna hamesha theek hai.',
      ),
    ]);
  }

  Widget _sheetLabel(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Text(t, style: _eyebrow),
      );

  // ---- 6 · Health · Diet ----------------------------------------------------
  Widget _diet(Week5Full w) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionHeader('Health this week · Diet', 'Is hafte sehat · Diet'),
      const SizedBox(height: 14),
      // superfood
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFEAF5EC), Color(0xFFDDEFE0)]),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_lang.isEnglish ? 'INDIAN SUPERFOOD OF THE WEEK' : 'IS HAFTE KA INDIAN SUPERFOOD',
              style: GoogleFonts.manrope(
                  fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.1, color: const Color(0xFF3E7D52))),
          const SizedBox(height: 8),
          Text(_tr(w.diet.superfood.food), style: _title),
          const SizedBox(height: 8),
          Text(_tr(w.diet.superfood.benefit), style: _body(AppTheme.neutral800)),
          const SizedBox(height: 10),
          Text(_tr(w.diet.superfood.tryAs),
              style: GoogleFonts.manrope(fontSize: 13, height: 1.5, fontWeight: FontWeight.w700, color: const Color(0xFF3E7D52))),
          const SizedBox(height: 6),
          Text(_tr(w.diet.superfood.note), style: _body(AppTheme.neutral600)),
        ]),
      ),
      const SizedBox(height: 16),
      Text(_lang.isEnglish ? 'Foods to favour this week' : 'Is hafte pasand karne wale khaane', style: _cardTitle),
      const SizedBox(height: 10),
      _plainCard(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
        child: Column(
          children: [
            for (int i = 0; i < w.diet.favour.length; i++)
              _dietItem(w.diet.favour[i], Icons.check_circle, AppTheme.primary500, last: i == w.diet.favour.length - 1),
          ],
        ),
      ),
      const SizedBox(height: 16),
      Text(_lang.isEnglish ? 'What to avoid' : 'Kis se bachna hai', style: _cardTitle),
      const SizedBox(height: 10),
      _plainCard(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
        child: Column(
          children: [
            for (int i = 0; i < w.diet.avoid.length; i++)
              _dietItem(w.diet.avoid[i], Icons.cancel_rounded, AppTheme.danger, last: i == w.diet.avoid.length - 1),
          ],
        ),
      ),
    ]);
  }

  Widget _dietItem(W5Card c, IconData icon, Color color, {required bool last}) => Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: last ? null : const Border(bottom: BorderSide(color: AppTheme.outlineVariant)),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(padding: const EdgeInsets.only(top: 1, right: 11), child: Icon(icon, size: 17, color: color)),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_tr(c.title), style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppTheme.primary900)),
              const SizedBox(height: 2),
              Text(_tr(c.body), style: _body(AppTheme.neutral600)),
            ]),
          ),
        ]),
      );

  // ---- 7 · Trimester Tips ---------------------------------------------------
  Widget _trimesterTips(Week5Full w) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionHeader('Trimester Tips', 'Trimester Tips',
          subEn: 'Trimester 1 · Weeks 1–13', subHi: 'Trimester 1 · Week 1–13'),
      const SizedBox(height: 14),
      for (int i = 0; i < w.tips.length; i++) _tipTile(w.tips[i], i),
    ]);
  }

  Widget _tipTile(W5Tip tip, int i) {
    final open = _openTips.contains(i);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.outlineVariant),
          boxShadow: _shadow,
        ),
        child: Column(children: [
          GestureDetector(
            onTap: () => setState(() => open ? _openTips.remove(i) : _openTips.add(i)),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(children: [
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: AppTheme.primary50, shape: BoxShape.circle),
                  child: Text('${i + 1}',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.primary600)),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(_tr(tip.oneLine), style: _cardTitle)),
                Icon(open ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: AppTheme.neutral400),
              ]),
            ),
          ),
          if (open)
            Padding(
              padding: const EdgeInsets.fromLTRB(52, 0, 16, 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(_tr(tip.readMore), style: _body()),
              ),
            ),
        ]),
      ),
    );
  }

  // ---- 8 · Share With Partner -----------------------------------------------
  Widget _partner(Week5Full w) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionHeader('Share With Partner', 'Partner ke saath baanto',
          subEn: 'Our Pregnancy Week: Week 5', subHi: 'Hamari Pregnancy Week: Week 5'),
      const SizedBox(height: 14),
      _plainCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _aboutBlock(_lang.isEnglish ? 'Baby' : 'Baby', _tr(w.partner.baby)),
          const SizedBox(height: 14),
          _aboutBlock(_lang.isEnglish ? 'Mother' : 'Maa', _tr(w.partner.mother)),
        ]),
      ),
      const SizedBox(height: 16),
      Text(_lang.isEnglish ? 'Scans & appointments coming up' : 'Aane wale scans aur appointments', style: _cardTitle),
      const SizedBox(height: 10),
      _plainCard(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
        child: Column(children: [
          for (int i = 0; i < w.partner.scans.length; i++)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                border: i == w.partner.scans.length - 1
                    ? null
                    : const Border(bottom: BorderSide(color: AppTheme.outlineVariant)),
              ),
              child: Row(children: [
                const Icon(Icons.event_outlined, size: 18, color: AppTheme.primary500),
                const SizedBox(width: 12),
                Expanded(child: Text(_tr(w.partner.scans[i].name), style: _cardTitle)),
                Text(_tr(w.partner.scans[i].window), style: _body(AppTheme.neutral600)),
              ]),
            ),
        ]),
      ),
      const SizedBox(height: 16),
      Text(_lang.isEnglish ? 'How you can help' : 'Tum kaise madad kar sakte ho', style: _cardTitle),
      const SizedBox(height: 10),
      for (final h in w.partner.help)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Padding(
              padding: EdgeInsets.only(top: 2, right: 10),
              child: Icon(Icons.volunteer_activism_outlined, size: 17, color: AppTheme.primary500),
            ),
            Expanded(child: Text(_tr(h), style: _body(AppTheme.neutral800))),
          ]),
        ),
    ]);
  }
}
