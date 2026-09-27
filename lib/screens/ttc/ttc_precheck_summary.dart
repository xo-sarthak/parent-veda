// =============================================================================
//  Pre-Pregnancy Checklist — the snapshot, the next three, and the summary
// -----------------------------------------------------------------------------
//  ⚠️ NO READINESS SCORE ON THIS SCREEN, IN ANY FORM. Not a percentage, not a
//  ring measuring her health, not a "you are mostly ready" band. The tool has
//  no basis for any of them — it has not seen her bloods, her scan or her
//  history, and a checklist she filled in herself cannot become a verdict about
//  her body just because it reached the end.
//
//  What it shows: what she has covered, what is still open, and — at most —
//  three things worth doing next. The three is the whole value: a summary the
//  same length as the checklist has summarised nothing.
// =============================================================================

import 'package:flutter/material.dart';

import '../../widgets/global_ask_fab.dart';
import 'package:flutter/services.dart';

import '../../localization/app_language.dart';
import '../../theme/pv_fonts.dart';
import '../../ttc/ttc_precheck_data.dart';
import '../../ttc/ttc_precheck_rules.dart';
import '../../ttc/ttc_precheck_store.dart';
import '../v2/v2_palette.dart';
import 'ttc_precheck_screen.dart' show PrecheckButton, kPrecheckHue;
import 'ttc_strings.dart';
import 'ttc_surface_router.dart';

class TtcPrecheckSummaryScreen extends StatelessWidget {
  const TtcPrecheckSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = TtcPrecheckStore.instance;

    return ListenableBuilder(
      listenable:
          Listenable.merge([store, V2PaletteStore.instance, TtcLang.instance]),
      builder: (context, _) {
        final p = V2PaletteStore.instance.current;
        final hi = TtcLang.instance.hinglish;
        final lang = hi ? AppLanguage.hinglish : AppLanguage.english;
        String t(String en, String hin) => hi ? hin : en;

        final c = PrecheckContext.gather();
        final counts = store.counts(c);
        final priorities = store.priorities(c);
        final done = store.doneItems(c);
        final open = store.openItems(c);

        return Scaffold(
          backgroundColor: p.ground,
          body: SafeArea(
            bottom: false,
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 16, 4),
                child: Row(children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Icon(Icons.arrow_back_rounded,
                          size: 21, color: p.ink1),
                    ),
                  ),
                  Expanded(
                    child: Text(t('YOUR SNAPSHOT', 'AAPKA SNAPSHOT'),
                        style: pvManrope(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                            color: p.ink3)),
                  ),
                  GestureDetector(
                    onTap: () => _copy(context, store, c, lang, t),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child:
                          Icon(Icons.copy_rounded, size: 19, color: p.ink2),
                    ),
                  ),
                ]),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, kAskFabReserve + 24),
                  children: [
                    Text(
                        t("You don't need to have everything perfect.",
                            'Sab kuch perfect hona zaroori nahi hai.'),
                        style: pvFraunces(
                            fontSize: 27,
                            height: 1.2,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
                            color: p.ink1)),
                    const SizedBox(height: 12),
                    Text(
                        t(
                            "You can now see what's already taken care of, "
                                'and what may be worth talking about with a '
                                'doctor.',
                            'Ab aapke paas saaf tasveer hai ki kya ho chuka hai '
                                'aur kis par baat karna baaki hai.'),
                        style: pvFraunces(
                            fontSize: 16.5, height: 1.58, color: p.ink2)),
                    const SizedBox(height: 22),

                    // ---- COUNTS, NEVER A SCORE ------------------------------
                    Row(children: [
                      _Count(
                          p: p,
                          n: counts.done,
                          label: t('Covered', 'Ho chuke')),
                      const SizedBox(width: 10),
                      _Count(
                          p: p,
                          n: counts.open,
                          label: t('Worth checking', 'Dekhna baaki')),
                      const SizedBox(width: 10),
                      _Count(
                          p: p,
                          n: counts.tracking - counts.done - counts.open,
                          label: t('Not looked at', 'Chhoot gaye')),
                    ]),
                    const SizedBox(height: 28),

                    // ---- THE NEXT THREE -------------------------------------
                    if (priorities.isNotEmpty) ...[
                      Text(t('Your next 3 steps', 'Aapke agle 3 kadam'),
                          style: pvFraunces(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: p.ink1)),
                      const SizedBox(height: 6),
                      Text(
                          t(
                              'Chosen from what you told us and what the app '
                                  'already knows.',
                              'Jo aapne bataya aur jo app pehle se jaanta hai, '
                                  'usse chune gaye.'),
                          style: pvManrope(
                              fontSize: 13, height: 1.5, color: p.ink3)),
                      const SizedBox(height: 14),
                      for (var i = 0; i < priorities.length; i++) ...[
                        _PriorityCard(
                          p: p,
                          lang: lang,
                          n: i + 1,
                          priority: priorities[i],
                          onOpen: () => _open(context, priorities[i].item),
                        ),
                        const SizedBox(height: 10),
                      ],
                      const SizedBox(height: 18),
                    ],

                    if (done.isNotEmpty) ...[
                      _Group(
                        p: p,
                        lang: lang,
                        title: t('Covered', 'Ho chuke'),
                        items: done,
                        icon: Icons.check_rounded,
                      ),
                      const SizedBox(height: 16),
                    ],

                    if (open.isNotEmpty) ...[
                      _Group(
                        p: p,
                        lang: lang,
                        title: t('Worth checking', 'Dekhna baaki'),
                        items: open,
                        icon: Icons.circle_outlined,
                      ),
                      const SizedBox(height: 16),
                    ],

                    const SizedBox(height: 10),
                    PrecheckButton(
                      p: p,
                      label: t('Copy for my appointment',
                          'Appointment ke liye copy karein'),
                      onTap: () => _copy(context, store, c, lang, t),
                    ),
                    const SizedBox(height: 10),
                    PrecheckButton(
                      p: p,
                      filled: false,
                      label: t('Back to the checklist', 'Checklist par wapas'),
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                    const SizedBox(height: 22),
                    Text(kPrecheckDisclaimer.of(lang),
                        style: pvManrope(
                            fontSize: 12, height: 1.6, color: p.ink3)),
                  ],
                ),
              ),
            ]),
          ),
        );
      },
    );
  }

  void _open(BuildContext context, PrecheckItem item) {
    final id = item.surfaceId ??
        (item.readId != null ? 'ttc_read/${item.readId}' : null);
    if (id == null) return;
    final screen = ttcScreenForSurface(id);
    if (screen == null) return;
    Navigator.of(context).push(MaterialPageRoute<void>(
      settings: RouteSettings(name: id),
      builder: (_) => screen,
    ));
  }

  // ---------------------------------------------------------------------------
  //  The doctor summary, as text she can carry
  // ---------------------------------------------------------------------------
  //
  // ⚠️ WHAT SHE TOLD US, AND NOTHING WE CONCLUDED. No interpretation, no
  // suggested tests, no named medicines. Handing a doctor our reading of her
  // situation would be the app practising medicine at the exact moment a real
  // clinician is in the room — and the questions below are things a patient may
  // reasonably ASK, never treatments to request.
  void _copy(BuildContext context, TtcPrecheckStore store, PrecheckContext c,
      AppLanguage lang, String Function(String, String) t) {
    final buf = StringBuffer()
      ..writeln('Getting ready for pregnancy: notes for my doctor')
      ..writeln();

    if (c.loggedCycles >= 2) {
      buf.writeln('Cycles logged in app: ${c.loggedCycles}');
    }
    if (c.daysTrying != null) {
      buf.writeln('Trying for: about ${(c.daysTrying! / 30).round()} months');
    }
    if (c.medicineCount > 0) {
      buf.writeln('Medicines saved in app: ${c.medicineCount} '
          '(I can share the list)');
    }
    if (c.supplementCount > 0) {
      buf.writeln('Supplements recorded: ${c.supplementCount}');
    }
    buf.writeln();

    final done = store.doneItems(c);
    if (done.isNotEmpty) {
      buf.writeln('Already covered:');
      for (final i in done) {
        final e = store.entryFor(i.id);
        final flag = (e?.discussedWithDoctor ?? false)
            ? ' (talked about with a doctor)'
            : '';
        buf.writeln('- ${i.title.of(lang)}$flag');
      }
      buf.writeln();
    }

    final open = store.openItems(c);
    if (open.isNotEmpty) {
      buf.writeln("I'd like to talk about:");
      for (final i in open) {
        buf.writeln('- ${i.title.of(lang)}');
      }
      buf.writeln();
    }

    buf.writeln('My questions:');
    // Her own open items supply the questions, so the list is hers rather than
    // a generic set.
    final asked = <String>{};
    for (final i in open) {
      final q = i.askDoctor;
      if (q != null && asked.add(q.en)) buf.writeln('- ${q.of(lang)}');
    }
    for (final q in kPrecheckFallbackQuestions) {
      if (asked.length >= 7) break;
      if (asked.add(q.en)) buf.writeln('- ${q.of(lang)}');
    }

    Clipboard.setData(ClipboardData(text: buf.toString()));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text(t('Summary copied. Paste it into a message or your notes.',
          'Summary copy ho gayi')),
    ));
  }
}

/// Used to fill out the question list where her own items supply too few.
///
/// ⚠️ QUESTIONS, NOT REQUESTS. None asks for a test or a drug — §13 and §27.
final List<LocalizedText> kPrecheckFallbackQuestions = [
  LocalizedText(
      en: 'Is there anything in my health history I should sort out before '
          'trying?',
      hi: 'Meri medical history mein aisa kuch hai jise koshish se pehle dekhna '
          'chahiye?'),
  LocalizedText(
      en: 'Should my vaccines or immunity be checked?',
      hi: 'Kya meri vaccination ya immunity history check karni chahiye?'),
  LocalizedText(
      en: 'Is what I eat now giving me what I need before pregnancy?',
      hi: 'Kya mera abhi ka khaan-paan pregnancy se pehle ki zarooraton ke '
          'liye theek hai?'),
  LocalizedText(
      en: 'With our family histories, is there anything worth looking into?',
      hi: 'Hamare parivaaron ki history dekhte hue, kuch dekhne layak hai?'),
];

// -----------------------------------------------------------------------------
//  Pieces
// -----------------------------------------------------------------------------

class _Count extends StatelessWidget {
  const _Count({required this.p, required this.n, required this.label});
  final V2Palette p;
  final int n;
  final String label;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: p.surfaceAlt,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: [
            Text('$n',
                style: pvFraunces(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    color: p.ink1)),
            const SizedBox(height: 4),
            Text(label,
                textAlign: TextAlign.center,
                style: pvManrope(
                    fontSize: 11.5, height: 1.35, color: p.ink3)),
          ]),
        ),
      );
}

class _PriorityCard extends StatelessWidget {
  const _PriorityCard(
      {required this.p,
      required this.lang,
      required this.n,
      required this.priority,
      required this.onOpen});

  final V2Palette p;
  final AppLanguage lang;
  final int n;
  final PrecheckPriority priority;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onOpen,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.fromLTRB(15, 15, 13, 16),
          decoration: BoxDecoration(
            color: n == 1 ? v2BlockTint(kPrecheckHue, p) : null,
            borderRadius: BorderRadius.circular(16),
            border: n == 1 ? null : Border.all(color: p.line),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('$n',
                style: pvFraunces(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: n == 1 ? const Color(0xFF2E3A2C) : p.ink3)),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(priority.item.title.of(lang),
                        style: pvJakarta(
                            fontSize: 15,
                            height: 1.35,
                            fontWeight: FontWeight.w700,
                            color:
                                n == 1 ? const Color(0xFF23301F) : p.ink1)),
                    const SizedBox(height: 6),
                    // ⚠️ THE REASON IS THE POINT. A priority list without one
                    // is just the checklist reordered, and she has no way to
                    // tell whether it understood her.
                    Text(priority.reason.of(lang),
                        style: pvManrope(
                            fontSize: 13,
                            height: 1.55,
                            color:
                                n == 1 ? const Color(0xFF3D4A38) : p.ink2)),
                  ]),
            ),
          ]),
        ),
      );
}

class _Group extends StatelessWidget {
  const _Group(
      {required this.p,
      required this.lang,
      required this.title,
      required this.items,
      required this.icon});

  final V2Palette p;
  final AppLanguage lang;
  final String title;
  final List<PrecheckItem> items;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(),
              style: pvManrope(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: p.ink3)),
          const SizedBox(height: 10),
          for (final i in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                Icon(icon, size: 16, color: p.ink3),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(i.title.of(lang),
                      style: pvManrope(
                          fontSize: 14, height: 1.45, color: p.ink2)),
                ),
              ]),
            ),
        ],
      );
}
