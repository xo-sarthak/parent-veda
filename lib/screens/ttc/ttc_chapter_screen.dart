// =============================================================================
//  TTC - the chapter page
// -----------------------------------------------------------------------------
//  What the weekly journey is to pregnancy, this is to TTC. Same hierarchy,
//  different content (master doc §2.5) - and organised behind the same three
//  shortcuts the hero offers, so tapping "Us" on Today lands exactly where the
//  couple expected.
//
//    ME   - her body, the science, what it means today
//    US   - his part, and what to talk about
//    NEXT - the action plan, the medical guidance, what is coming
//
//  Two things this page deliberately does NOT do:
//
//   * It never shows a chapter number as progress. Chapters 2-4 repeat with the
//     cycle; a "3 of 5" here would read as regression every month.
//   * The action plan is not a checklist with a completion percentage. Items
//     carry no tick and no score - they are suggestions, and a couple who does
//     none of them has not failed at anything.
// =============================================================================

import 'package:flutter/material.dart';

import '../../ttc/ttc_chapter.dart';
import '../../ttc/ttc_chapter_data.dart';
import '../../ttc/ttc_daily_data.dart';
import '../../ttc/ttc_journal_store.dart';
import '../../ttc/ttc_store.dart';
import 'ttc_askveda_screen.dart';
import 'ttc_common.dart';
import 'ttc_journal_screen.dart';
import 'ttc_strings.dart';

/// Which of the three faces of a chapter to open on.
enum TtcChapterTab { me, us, next }

/// Opens a chapter from the hero shortcuts, the Journey Map or search.
void openTtcChapter(
  BuildContext context,
  TtcChapter chapter, {
  TtcChapterTab tab = TtcChapterTab.me,
}) {
  Navigator.of(context).push(MaterialPageRoute<void>(
    builder: (_) => TtcChapterScreen(chapter: chapter, initialTab: tab),
    settings: const RouteSettings(name: 'ttc/chapter'),
  ));
}

class TtcChapterScreen extends StatefulWidget {
  const TtcChapterScreen({
    super.key,
    required this.chapter,
    this.initialTab = TtcChapterTab.me,
  });

  final TtcChapter chapter;
  final TtcChapterTab initialTab;

  @override
  State<TtcChapterScreen> createState() => _TtcChapterScreenState();
}

class _TtcChapterScreenState extends State<TtcChapterScreen> {
  late TtcChapterTab _tab = widget.initialTab;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([TtcLang.instance, TtcStore.instance]),
      builder: (context, _) {
        final t = TtcS.current();
        final hi = t.hinglish;
        final chapter = widget.chapter;
        final content = ttcChapterContent[chapter]!;
        final isCurrent = TtcStore.instance.today.chapter == chapter;

        final sections = switch (_tab) {
          TtcChapterTab.me => content.me,
          TtcChapterTab.us => content.us,
          TtcChapterTab.next => content.next,
        };

        return Scaffold(
          backgroundColor: ttcBg,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(ttcGutter, 8, ttcGutter, 40),
              children: [
                TtcBackBar(title: t.yourChapter),
                const SizedBox(height: 16),

                _ChapterHero(
                    chapter: chapter,
                    content: content,
                    t: t,
                    isCurrent: isCurrent),
                const SizedBox(height: 20),

                _Tabs(
                  active: _tab,
                  t: t,
                  onChanged: (v) => setState(() => _tab = v),
                ),
                const SizedBox(height: 20),

                for (final s in sections) ...[
                  TtcCard(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.title(hi), style: ttcJakarta(16.5)),
                          const SizedBox(height: 10),
                          Text(s.body(hi),
                              style: ttcBody(14.5, color: ttcInk, h: 1.68)),
                        ]),
                  ),
                  const SizedBox(height: 12),
                ],

                // The action plan and the medical guidance live on the NEXT
                // face, because that is what "what's next" means here.
                if (_tab == TtcChapterTab.next) ...[
                  const SizedBox(height: 6),
                  _ActionPlan(content: content, t: t),
                  const SizedBox(height: 12),
                  _MedicalCard(content: content, t: t),
                ],

                const SizedBox(height: 12),
                _AskVedaCard(content: content, t: t),
                const SizedBox(height: 12),
                _WriteAboutIt(chapter: chapter, t: t),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ---- hero -------------------------------------------------------------------

class _ChapterHero extends StatelessWidget {
  const _ChapterHero({
    required this.chapter,
    required this.content,
    required this.t,
    required this.isCurrent,
  });

  final TtcChapter chapter;
  final TtcChapterContent content;
  final TtcS t;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final hi = t.hinglish;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ttcCardRadius),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [ttcPurple, ttcPurpleDeep],
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (isCurrent)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(t.chapterYouAreHere,
                style: ttcBody(10.5, color: Colors.white, w: FontWeight.w800)),
          ),
        if (isCurrent) const SizedBox(height: 12),
        Text(chapter.title(hi),
            style: ttcFraunces(27, w: FontWeight.w600, color: Colors.white)),
        const SizedBox(height: 10),
        Text(content.overview(hi),
            style: ttcBody(14,
                color: Colors.white.withValues(alpha: 0.95), h: 1.55)),
      ]),
    );
  }
}

// ---- the three faces --------------------------------------------------------

class _Tabs extends StatelessWidget {
  const _Tabs({required this.active, required this.t, required this.onChanged});

  final TtcChapterTab active;
  final TtcS t;
  final ValueChanged<TtcChapterTab> onChanged;

  @override
  Widget build(BuildContext context) {
    String label(TtcChapterTab tab) => switch (tab) {
          TtcChapterTab.me => t.chapterTabMe,
          TtcChapterTab.us => t.chapterTabUs,
          TtcChapterTab.next => t.chapterTabNext,
        };
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: ttcPanel,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(children: [
        for (final tab in TtcChapterTab.values)
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(tab),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  color: tab == active ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: tab == active ? ttcCardShadow : null,
                ),
                child: Text(label(tab),
                    style: ttcBody(13,
                        color: tab == active ? ttcTitleInk : ttcSoft,
                        w: FontWeight.w800)),
              ),
            ),
          ),
      ]),
    );
  }
}

// ---- action plan ------------------------------------------------------------

class _ActionPlan extends StatelessWidget {
  const _ActionPlan({required this.content, required this.t});

  final TtcChapterContent content;
  final TtcS t;

  @override
  Widget build(BuildContext context) {
    final hi = t.hinglish;
    return TtcCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(t.chapterActions, style: ttcJakarta(16.5)),
        const SizedBox(height: 6),
        // Said plainly, because a list of suggestions that looks like a
        // checklist becomes a list of failures by the end of the month.
        Text(t.actionsNoScore, style: ttcBody(12.5, h: 1.5)),
        const SizedBox(height: 14),
        for (var i = 0; i < content.actions.length; i++) ...[
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.only(top: 7, right: 11),
              decoration: BoxDecoration(
                color: content.actions[i].forPartner ? ttcCoral : ttcPurple,
                shape: BoxShape.circle,
              ),
            ),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(content.actions[i].text(hi),
                        style: ttcBody(13.5, color: ttcInk, h: 1.5)),
                    // Whose item it is. An action plan where every line belongs
                    // to her is not a couple-first product.
                    if (content.actions[i].forPartner) ...[
                      const SizedBox(height: 3),
                      Text(t.forPartnerTag,
                          style: ttcBody(10.5,
                              color: ttcCoral, w: FontWeight.w800)),
                    ],
                  ]),
            ),
          ]),
          if (i < content.actions.length - 1) const SizedBox(height: 13),
        ],
      ]),
    );
  }
}

// ---- medical guidance -------------------------------------------------------

class _MedicalCard extends StatelessWidget {
  const _MedicalCard({required this.content, required this.t});

  final TtcChapterContent content;
  final TtcS t;

  @override
  Widget build(BuildContext context) {
    final hi = t.hinglish;
    return TtcCard(
      color: const Color(0xFFFDF6EC),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.medical_services_outlined, size: 17, color: ttcBrown),
          const SizedBox(width: 9),
          Expanded(
              child: Text(t.chapterMedical,
                  style: ttcJakarta(15.5, color: ttcBrown))),
        ]),
        const SizedBox(height: 11),
        Text(content.medical(hi),
            style: ttcBody(13.5, color: ttcBrown, h: 1.6)),
        const SizedBox(height: 12),
        ttcDivider(),
        const SizedBox(height: 10),
        // Every clinical surface in this product ends with a disclaimer.
        Text(
          hi
              ? 'Ye jaankari hai, diagnosis nahi. Faisle apne doctor ke saath lein.'
              : 'This is information, never a diagnosis. Decisions belong with your doctor.',
          style: ttcBody(11.5, color: ttcMuted, h: 1.5),
        ),
      ]),
    );
  }
}

// ---- Ask Veda ---------------------------------------------------------------

class _AskVedaCard extends StatelessWidget {
  const _AskVedaCard({required this.content, required this.t});

  final TtcChapterContent content;
  final TtcS t;

  @override
  Widget build(BuildContext context) {
    final questions = content.askVeda(t.hinglish);
    return TtcCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.auto_awesome_outlined, size: 17, color: ttcPurple),
          const SizedBox(width: 9),
          Expanded(child: Text(t.chapterAskVeda, style: ttcJakarta(16))),
        ]),
        const SizedBox(height: 13),
        for (var i = 0; i < questions.length; i++) ...[
          GestureDetector(
            // Opens the TTC Ask Veda with this question already running.
            onTap: () => openTtcAskVeda(context, initialQuery: questions[i]),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: ttcPanel,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(children: [
                Expanded(
                  child: Text(questions[i],
                      style: ttcBody(13, color: ttcTitleInk, w: FontWeight.w600)),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded,
                    size: 15, color: ttcPurple),
              ]),
            ),
          ),
          if (i < questions.length - 1) const SizedBox(height: 9),
        ],
      ]),
    );
  }
}

// ---- journal handoff --------------------------------------------------------

class _WriteAboutIt extends StatelessWidget {
  const _WriteAboutIt({required this.chapter, required this.t});

  final TtcChapter chapter;
  final TtcS t;

  @override
  Widget build(BuildContext context) {
    final hi = t.hinglish;
    final prompt = ttcPromptForToday(chapter);
    return TtcCard(
      onTap: () => writeTtcEntry(context,
          kind: TtcEntryKind.feeling, prompt: prompt.text(hi)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.edit_outlined, size: 17, color: ttcPurple),
          const SizedBox(width: 9),
          Expanded(
              child: Text(t.chapterJournalPrompts, style: ttcJakarta(16))),
        ]),
        const SizedBox(height: 12),
        Text(prompt.text(hi),
            style: ttcBody(14, color: ttcInk, w: FontWeight.w600, h: 1.5)),
        const SizedBox(height: 12),
        Row(children: [
          Text(t.journalWrite,
              style: ttcBody(13, color: ttcPurple, w: FontWeight.w800)),
          const SizedBox(width: 5),
          const Icon(Icons.arrow_forward_rounded, size: 15, color: ttcPurple),
        ]),
      ]),
    );
  }
}
