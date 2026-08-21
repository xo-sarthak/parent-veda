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
// =============================================================================

import 'package:flutter/material.dart';

import '../../localization/app_language.dart';
import '../../theme/pv_fonts.dart';
import '../../ttc/ttc_precheck_data.dart';
import '../../ttc/ttc_precheck_rules.dart';
import '../../ttc/ttc_precheck_store.dart';
import '../v2/v2_palette.dart';
import 'ttc_precheck_summary.dart';
import 'ttc_strings.dart';
import 'ttc_surface_router.dart';

/// Getting ready is 104 on the wheel — the tool keeps its door's colour.
const double kPrecheckHue = 104;

class TtcPrecheckScreen extends StatefulWidget {
  const TtcPrecheckScreen({super.key});

  @override
  State<TtcPrecheckScreen> createState() => _TtcPrecheckScreenState();
}

class _TtcPrecheckScreenState extends State<TtcPrecheckScreen> {
  bool _started = false;
  final Set<String> _openItems = {};
  final Set<PrecheckSection> _openSections = {PrecheckSection.folate};

  TtcPrecheckStore get _store => TtcPrecheckStore.instance;

  @override
  void initState() {
    super.initState();
    _store.load().then((_) {
      if (!mounted) return;
      _store.markOpened();
      setState(() => _started = _store.everOpened);
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

        return Scaffold(
          backgroundColor: p.ground,
          body: SafeArea(
            bottom: false,
            child: Column(children: [
              _bar(p, t),
              Expanded(
                child: !_started
                    ? _intro(p, t, c)
                    : _list(p, lang, t, c),
              ),
            ]),
          ),
        );
      },
    );
  }

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
                child: Text(t('Summary', 'Summary'),
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

  Widget _intro(
      V2Palette p, String Function(String, String) t, PrecheckContext c) {
    final known = _knownLines(t, c);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
      children: [
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
                'A few thoughtful checks before you start can make the early '
                    'weeks easier. This shows what you have already covered and '
                    'what may still be worth discussing.',
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
                      t('WHAT YOU HAVE ALREADY DONE',
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
                'You do not need a perfect checklist. You just need to know '
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
      ],
    );
  }

  List<String> _knownLines(
      String Function(String, String) t, PrecheckContext c) {
    final out = <String>[];
    if (c.loggedCycles >= 2) {
      out.add(t(
          'You have logged ${c.loggedCycles} cycles — cycle tracking is '
              'already covered.',
          'Aapne ${c.loggedCycles} cycles log kiye hain — cycle tracking ho '
              'chuki hai.'));
    }
    if (c.ranPcosCheck) {
      out.add(t('You have run the PCOS check.',
          'Aapne PCOS check kar liya hai.'));
    }
    if (c.supplementCount > 0) {
      out.add(t(
          'You have ${c.supplementCount} supplements recorded.',
          'Aapne ${c.supplementCount} supplements darj kiye hain.'));
    }
    if (c.medicineCount > 0) {
      out.add(t(
          'You have ${c.medicineCount} medicines saved — worth a '
              'pre-pregnancy review.',
          'Aapne ${c.medicineCount} dawaiyan save ki hain — pregnancy se pehle '
              'review karwane layak.'));
    }
    if (c.vaccinesRecorded > 0) {
      out.add(t('You have started your vaccination list.',
          'Aapne vaccination list shuru kar di hai.'));
    }
    return out;
  }

  // ---------------------------------------------------------------------------
  //  The list
  // ---------------------------------------------------------------------------

  Widget _list(V2Palette p, AppLanguage lang, String Function(String, String) t,
      PrecheckContext c) {
    final counts = _store.counts(c);
    final sections = PrecheckSection.values;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 44),
      children: [
        _CountBar(p: p, t: t, counts: counts),
        const SizedBox(height: 24),

        for (var si = 0; si < sections.length; si++) ...[
          _section(p, lang, t, c, sections[si]),
          const SizedBox(height: 12),

          // ⚠️ THE EDITORIAL BEAT, AFTER THE FIRST SECTION. Not labelled a tip
          // or an insight — §26. It is there to break the rhythm of a list
          // before the list becomes a chore.
          if (si == 0) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
              child: Text(kPrecheckPatternBreak.of(lang),
                  style: pvFraunces(
                      fontSize: 17.5,
                      height: 1.6,
                      fontWeight: FontWeight.w500,
                      color: p.ink2)),
            ),
            const SizedBox(height: 12),
          ],
        ],

        const SizedBox(height: 14),
        _Button(
          p: p,
          label: t('See my next 3 steps', 'Mere agle 3 kadam dekhein'),
          onTap: _openSummary,
        ),
        const SizedBox(height: 18),
        Text(kPrecheckDisclaimer.en,
            style: pvManrope(fontSize: 12, height: 1.6, color: p.ink3)),
      ],
    );
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
              _StatusDot(p: p, status: status),
              const SizedBox(width: 12),
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
                      Row(children: [
                        Text(item.tier.label.of(lang),
                            style: pvManrope(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: item.tier == PrecheckTier.core
                                    ? p.action
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
                            style: pvManrope(
                                fontSize: 12.5,
                                height: 1.5,
                                color: p.action)),
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
                  _field(p, t('WHY IT MATTERS', 'KYUN MAAYNE RAKHTA HAI'),
                      item.why.of(lang)),
                  _field(p, t('WHAT TO DO', 'KYA KARNA HAI'),
                      item.whatToDo.of(lang)),
                  if (item.askDoctor != null)
                    _field(
                        p,
                        t('ASK YOUR DOCTOR', 'DOCTOR SE POOCHHEIN'),
                        '"${item.askDoctor!.of(lang)}"'),

                  const SizedBox(height: 4),
                  Text(t('WHERE YOU ARE', 'AAP KAHAN HAIN'),
                      style: pvManrope(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                          color: p.ink3)),
                  const SizedBox(height: 10),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    for (final s in const [
                      PrecheckStatus.done,
                      PrecheckStatus.needsAttention,
                      PrecheckStatus.notSure,
                      PrecheckStatus.notRelevant,
                    ])
                      _StatusChip(
                        p: p,
                        label: s.label.of(lang),
                        on: status == s,
                        onTap: () => _store.setStatus(item.id, s),
                      ),
                  ]),

                  // ⚠️ A SEPARATE FLAG, NOT A FIFTH STATUS. "I have started
                  // folic acid" and "a pharmacist confirmed my dose" are
                  // different facts, and on a core medical item the second is
                  // the one that matters.
                  if (item.askDoctor != null) ...[
                    const SizedBox(height: 14),
                    GestureDetector(
                      onTap: () => _store.setDiscussed(item.id,
                          !(entry?.discussedWithDoctor ?? false)),
                      behavior: HitTestBehavior.opaque,
                      child: Row(children: [
                        Icon(
                            (entry?.discussedWithDoctor ?? false)
                                ? Icons.check_box_rounded
                                : Icons.check_box_outline_blank_rounded,
                            size: 19,
                            color: (entry?.discussedWithDoctor ?? false)
                                ? p.action
                                : p.ink3),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                              t('Discussed with my doctor',
                                  'Doctor se baat ho chuki hai'),
                              style: pvManrope(
                                  fontSize: 13.5, color: p.ink2)),
                        ),
                      ]),
                    ),
                  ],

                  if (item.surfaceId != null || item.readId != null) ...[
                    const SizedBox(height: 14),
                    Row(children: [
                      if (item.surfaceId != null)
                        _LinkChip(
                          p: p,
                          label: t('Open the tool', 'Tool kholein'),
                          onTap: () => _open(item.surfaceId!),
                        ),
                      if (item.surfaceId != null && item.readId != null)
                        const SizedBox(width: 8),
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

  void _openSummary() => Navigator.of(context).push(MaterialPageRoute<void>(
        settings: const RouteSettings(name: 'ttc_precheck/summary'),
        builder: (_) => const TtcPrecheckSummaryScreen(),
      ));
}

// -----------------------------------------------------------------------------
//  Pieces
// -----------------------------------------------------------------------------

/// ⚠️ COUNTS, NOT A PERCENTAGE, AND THE DENOMINATOR IS HER LIST.
class _CountBar extends StatelessWidget {
  const _CountBar({required this.p, required this.t, required this.counts});

  final V2Palette p;
  final String Function(String, String) t;
  final ({int done, int open, int notSure, int tracking}) counts;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 15),
        decoration: BoxDecoration(
          color: p.surfaceAlt,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
              t('${counts.done} of ${counts.tracking} you are tracking are done',
                  '${counts.tracking} mein se ${counts.done} ho chuke hain'),
              style: pvJakarta(
                  fontSize: 15, fontWeight: FontWeight.w700, color: p.ink1)),
          if (counts.open > 0) ...[
            const SizedBox(height: 5),
            Text(
                t('${counts.open} may be worth discussing',
                    '${counts.open} par baat karna theek rahega'),
                style: pvManrope(fontSize: 13, color: p.ink2)),
          ],
        ]),
      );
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
      PrecheckStatus.done => (Icons.check_circle_rounded, p.action),
      PrecheckStatus.needsAttention => (Icons.circle_outlined, p.ink2),
      PrecheckStatus.notSure => (Icons.help_outline_rounded, p.ink2),
      PrecheckStatus.notRelevant => (Icons.remove_circle_outline, p.ink3),
      PrecheckStatus.untouched => (Icons.circle_outlined, p.line),
    };
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Icon(icon, size: 20, color: colour),
    );
  }
}

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

  @override
  Widget build(BuildContext context) => GestureDetector(
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

  @override
  Widget build(BuildContext context) => GestureDetector(
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

  @override
  Widget build(BuildContext context) => GestureDetector(
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
