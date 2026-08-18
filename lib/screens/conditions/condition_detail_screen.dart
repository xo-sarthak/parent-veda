// =============================================================================
//  ConditionDetailScreen — one condition, the same 8-part order every time
// -----------------------------------------------------------------------------
//  what it is + reassurance · how common in India · symptoms · when to call vs
//  monitor · which tests confirm it · how it's managed in India · impact on
//  baby · FAQ — then, only where genuinely relevant, up to three foot
//  sections (medicine reminder, read more, watch).
//
//  ⚠️ THE ORDER NEVER CHANGES. DEPTH DOES. A rare condition still walks
//  through all eight parts; it just says less in each — see the seeding
//  notes in `conditions_data.dart` for why padding a rare page to look as
//  complete as a common one would be dishonest rather than thorough.
//
//  ⚠️ ONE FRAME, EVERY PAGE. "This helps you understand what your doctor is
//  managing. It does not replace them." sits right under the hero, before
//  any content, so it is read first rather than found as a disclaimer at the
//  bottom nobody reaches.
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/conditions_data.dart';
import '../../localization/app_language.dart';
import '../../services/pregnancy_controller.dart';
import '../../theme/pv_fonts.dart';
import '../../widgets/pv_placeholders.dart';
import '../brackets/hub/problem_hub_screen.dart' show HubPill;
import '../tools/medicine_tracker_screen.dart';
import '../v2/v2_palette.dart';

class ConditionDetailScreen extends StatelessWidget {
  const ConditionDetailScreen(
      {super.key, required this.entry, required this.pregnancy});

  final ConditionEntry entry;
  final PregnancyController pregnancy;

  @override
  Widget build(BuildContext context) {
    final lang = pregnancy.language;

    return AnimatedBuilder(
      animation: ConditionsStore.instance,
      builder: (context, _) {
        final p = V2PaletteStore.instance.current;
        final store = ConditionsStore.instance;

        return Scaffold(
          backgroundColor: p.ground,
          appBar: AppBar(
            backgroundColor: p.ground,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            foregroundColor: p.ink1,
            title: Text(entry.name.of(lang),
                style: pvJakarta(
                    fontSize: 16, fontWeight: FontWeight.w700, color: p.ink1)),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 44),
            children: [
              // ---- the permanent frame, on every page, before content -----
              _FrameNote(p: p, lang: lang),
              const SizedBox(height: 22),

              // ---- what it is + reassurance --------------------------------
              _Heading(
                  const LocalizedText(
                          en: 'What this is', hi: 'What this is')
                      .of(lang),
                  p),
              _Body(entry.whatItIs.of(lang), p),
              const SizedBox(height: 10),
              _Reassurance(entry.reassurance.of(lang), p),

              // ---- personalise, diagnosed door only -------------------------
              if (store.isDiagnosed) ...[
                const SizedBox(height: 16),
                HubPill(
                  label: store.isAddedToJourney(entry.id)
                      ? const LocalizedText(
                              en: 'Added to your journey',
                              hi: 'Added to your journey')
                          .of(lang)
                      : const LocalizedText(
                              en: 'Add to my journey', hi: 'Add to my journey')
                          .of(lang),
                  icon: store.isAddedToJourney(entry.id)
                      ? Icons.check_circle_outline_rounded
                      : Icons.add_circle_outline_rounded,
                  p: p,
                  onTap: () => store.toggleAddedToJourney(entry.id),
                ),
              ],
              const SizedBox(height: 26),

              // ---- how common in India ---------------------------------------
              _Heading(
                  const LocalizedText(
                          en: 'How common this is in India',
                          hi: 'How common this is in India')
                      .of(lang),
                  p),
              _Body(entry.howCommon.of(lang), p),
              const SizedBox(height: 26),

              // ---- symptoms ---------------------------------------------------
              _Heading(
                  const LocalizedText(
                          en: "What you might notice",
                          hi: "What you might notice")
                      .of(lang),
                  p),
              _BulletList(entry.symptoms, p, lang),
              const SizedBox(height: 26),

              // ---- when to call vs just monitor --------------------------------
              _Heading(
                  const LocalizedText(
                          en: 'When to call, and when to just watch',
                          hi: 'When to call, and when to just watch')
                      .of(lang),
                  p),
              if (entry.callNow.isNotEmpty) ...[
                _SubLabel(
                    const LocalizedText(en: 'Call now if', hi: 'Call now if')
                        .of(lang),
                    p,
                    warm: true),
                const SizedBox(height: 8),
                _BulletList(entry.callNow, p, lang, warm: true),
                const SizedBox(height: 14),
              ],
              if (entry.justMonitor.isNotEmpty) ...[
                _SubLabel(
                    const LocalizedText(
                            en: 'Just keep an eye on', hi: 'Just keep an eye on')
                        .of(lang),
                    p,
                    warm: false),
                const SizedBox(height: 8),
                _BulletList(entry.justMonitor, p, lang, warm: false),
              ],
              const SizedBox(height: 26),

              // ---- tests --------------------------------------------------------
              _Heading(
                  const LocalizedText(
                          en: 'Which tests confirm it',
                          hi: 'Which tests confirm it')
                      .of(lang),
                  p),
              _BulletList(entry.testsToConfirm, p, lang),
              const SizedBox(height: 26),

              // ---- managed in India -----------------------------------------------
              _Heading(
                  const LocalizedText(
                          en: 'How it is managed in India',
                          hi: 'How it is managed in India')
                      .of(lang),
                  p),
              _Body(entry.management.of(lang), p),
              const SizedBox(height: 26),

              // ---- impact on baby ---------------------------------------------
              _Heading(
                  const LocalizedText(
                          en: 'What it means for your baby',
                          hi: 'What it means for your baby')
                      .of(lang),
                  p),
              _Body(entry.babyImpact.of(lang), p),
              const SizedBox(height: 26),

              // ---- FAQ ---------------------------------------------------------
              if (entry.faqs.isNotEmpty) ...[
                _Heading(
                    const LocalizedText(
                            en: 'Common questions', hi: 'Common questions')
                        .of(lang),
                    p),
                for (final f in entry.faqs) ...[
                  _Faq(f, p, lang),
                  if (f != entry.faqs.last) const SizedBox(height: 14),
                ],
                const SizedBox(height: 26),
              ],

              // ---- foot: only where genuinely relevant ---------------------------
              if (entry.showMedicine)
                _MedicineAsk(entry: entry, pregnancy: pregnancy, p: p, lang: lang, store: store),
              if (entry.showReadMore) ...[
                const SizedBox(height: 26),
                _ReadMoreSection(entry: entry, p: p, lang: lang),
              ],
              if (entry.showWatch) ...[
                const SizedBox(height: 26),
                _WatchSection(entry: entry, p: p, lang: lang),
              ],
            ],
          ),
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------

/// The one line every condition page carries, before any content.
class _FrameNote extends StatelessWidget {
  const _FrameNote({required this.p, required this.lang});
  final V2Palette p;
  final AppLanguage lang;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(15, 13, 15, 13),
        decoration: BoxDecoration(
          color: p.surfaceAlt,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
            const LocalizedText(
                    en: 'This helps you understand what your doctor is '
                        'managing. It does not replace them.',
                    hi: 'This helps you understand what your doctor is '
                        'managing. It does not replace them.')
                .of(lang),
            style: pvManrope(
                fontSize: 13, height: 1.5, color: p.ink2, fontWeight: FontWeight.w600)),
      );
}

class _Heading extends StatelessWidget {
  const _Heading(this.text, this.p);
  final String text;
  final V2Palette p;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: pvFraunces(
                fontSize: 19,
                fontWeight: FontWeight.w600,
                height: 1.24,
                letterSpacing: -0.4,
                color: p.ink1)),
      );
}

class _Body extends StatelessWidget {
  const _Body(this.text, this.p);
  final String text;
  final V2Palette p;

  @override
  Widget build(BuildContext context) => Text(text,
      style: pvManrope(fontSize: 14.5, height: 1.55, color: p.ink2));
}

/// The scale-setting line beside a definition — quieter type, so it reads as
/// a held breath rather than another fact.
class _Reassurance extends StatelessWidget {
  const _Reassurance(this.text, this.p);
  final String text;
  final V2Palette p;

  @override
  Widget build(BuildContext context) => Text(text,
      style: pvManrope(
          fontSize: 13.5,
          height: 1.5,
          fontStyle: FontStyle.italic,
          color: p.ink3));
}

class _SubLabel extends StatelessWidget {
  const _SubLabel(this.text, this.p, {required this.warm});
  final String text;
  final V2Palette p;
  final bool warm;

  @override
  Widget build(BuildContext context) => Text(text.toUpperCase(),
      style: pvManrope(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.0,
          color: warm ? p.ink1 : p.ink3));
}

class _BulletList extends StatelessWidget {
  const _BulletList(this.items, this.p, this.lang, {this.warm = false});
  final List<LocalizedText> items;
  final V2Palette p;
  final AppLanguage lang;
  final bool warm;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final it in items) ...[
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.only(top: 8, right: 11),
              decoration: BoxDecoration(
                  color: warm ? p.ink2 : p.ink3, shape: BoxShape.circle),
            ),
            Expanded(
              child: Text(it.of(lang),
                  style: pvManrope(
                      fontSize: 14,
                      height: 1.5,
                      color: warm ? p.ink1 : p.ink2)),
            ),
          ]),
          if (it != items.last) const SizedBox(height: 9),
        ],
      ],
    );
  }
}

class _Faq extends StatelessWidget {
  const _Faq(this.faq, this.p, this.lang);
  final ConditionFaq faq;
  final V2Palette p;
  final AppLanguage lang;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(faq.question.of(lang),
              style: pvManrope(
                  fontSize: 14, fontWeight: FontWeight.w700, color: p.ink1)),
          const SizedBox(height: 5),
          Text(faq.answer.of(lang),
              style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink2)),
        ],
      );
}

// -----------------------------------------------------------------------------
//  Foot section 1 — the medicine reminder question
// -----------------------------------------------------------------------------
//  ⚠️ "NO" NEVER ASKS AGAIN. `ConditionsStore.declineMedicineFor` persists the
//  choice per condition, and this widget renders nothing once it has —
//  re-asking a question she already answered "no" to reads as not listening.
class _MedicineAsk extends StatelessWidget {
  const _MedicineAsk(
      {required this.entry,
      required this.pregnancy,
      required this.p,
      required this.lang,
      required this.store});

  final ConditionEntry entry;
  final PregnancyController pregnancy;
  final V2Palette p;
  final AppLanguage lang;
  final ConditionsStore store;

  @override
  Widget build(BuildContext context) {
    if (store.medicineDeclinedFor(entry.id)) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: p.line),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
            const LocalizedText(
                    en: 'Have you been advised any medicine for this?',
                    hi: 'Have you been advised any medicine for this?')
                .of(lang),
            style: pvManrope(
                fontSize: 14.5, fontWeight: FontWeight.w700, color: p.ink1)),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: HubPill(
              label:
                  const LocalizedText(en: 'Yes', hi: 'Yes').of(lang),
              icon: Icons.medication_outlined,
              p: p,
              fullWidth: true,
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                  settings: const RouteSettings(name: 'medication'),
                  builder: (_) =>
                      MedicineTrackerScreen(controller: pregnancy))),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: HubPill(
              label: const LocalizedText(en: 'No', hi: 'No').of(lang),
              icon: Icons.close_rounded,
              p: p,
              fullWidth: true,
              onTap: () => store.declineMedicineFor(entry.id),
            ),
          ),
        ]),
      ]),
    );
  }
}

// -----------------------------------------------------------------------------
//  Foot section 2 — read more
// -----------------------------------------------------------------------------
class _ReadMoreSection extends StatelessWidget {
  const _ReadMoreSection({required this.entry, required this.p, required this.lang});
  final ConditionEntry entry;
  final V2Palette p;
  final AppLanguage lang;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Heading(
              const LocalizedText(en: 'Read more', hi: 'Read more').of(lang),
              p),
          PvReadPlaceholder(
            title: const LocalizedText(
                    en: 'A longer read on what to expect',
                    hi: 'A longer read on what to expect')
                .of(lang),
            subtitle: const LocalizedText(
                    en: 'Written with an Indian obstetrician, in plain '
                        'language.',
                    hi: 'Written with an Indian obstetrician, in plain '
                        'language.')
                .of(lang),
            readingTime: '6 MIN',
            slotId: 'condition_read_${entry.id}_1',
          ),
          const SizedBox(height: 10),
          PvReadPlaceholder(
            title: const LocalizedText(
                    en: "Real questions other mothers asked",
                    hi: "Real questions other mothers asked")
                .of(lang),
            subtitle: const LocalizedText(
                    en: 'Answered plainly, without jargon.',
                    hi: 'Answered plainly, without jargon.')
                .of(lang),
            readingTime: '4 MIN',
            slotId: 'condition_read_${entry.id}_2',
          ),
        ],
      );
}

// -----------------------------------------------------------------------------
//  Foot section 3 — watch
// -----------------------------------------------------------------------------
class _WatchSection extends StatelessWidget {
  const _WatchSection({required this.entry, required this.p, required this.lang});
  final ConditionEntry entry;
  final V2Palette p;
  final AppLanguage lang;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Heading(
              const LocalizedText(en: 'Watch', hi: 'Watch').of(lang), p),
          PvVideoPlaceholder(
            title: const LocalizedText(
                    en: 'Explained in five minutes',
                    hi: 'Explained in five minutes')
                .of(lang),
            subtitle: const LocalizedText(
                    en: 'What this condition is doing, drawn simply, by a '
                        'doctor.',
                    hi: 'What this condition is doing, drawn simply, by a '
                        'doctor.')
                .of(lang),
            duration: '5 MIN',
            slotId: 'condition_watch_${entry.id}',
          ),
        ],
      );
}
