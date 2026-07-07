// =============================================================================
//  My Journal V2 - welcome, empty state & the "Our Story" home
// -----------------------------------------------------------------------------
//  The entry surface (reached from the Explore drawer, below Astrology). Welcome
//  → Home. Home is the calm "Our Story" surface: greeting, continue-reading,
//  recent moments and the keepsake storybook, with a bottom nav + FAB.
// =============================================================================

import 'package:flutter/material.dart';

import 'journal_capture_screens.dart';
import 'journal_moments_screens.dart';
import 'journal_settings_screens.dart';
import 'journal_storybook_screens.dart';
import 'jv2_common.dart';
import 'jv2_data.dart';

// ---- Welcome ----------------------------------------------------------------
class JournalWelcomeScreen extends StatelessWidget {
  const JournalWelcomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 20, 28, 28),
          child: Column(children: [
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(onTap: () => Navigator.of(context).maybePop(), child: const Icon(Icons.arrow_back, size: 22, color: ppInk)),
            ),
            const Spacer(),
            const JvPhoto(seed: 0, height: 220, width: 220, radius: 110),
            const SizedBox(height: 34),
            Text('Welcome to\nMy Journal', textAlign: TextAlign.center, style: ppFraunces(34, h: 1.15)),
            const SizedBox(height: 14),
            Text('Capture the little moments today that become their greatest stories tomorrow.',
                textAlign: TextAlign.center, style: ppBody(15, h: 1.6)),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: jvButton("Let's begin", () => Navigator.of(context).pushReplacement(MaterialPageRoute<void>(builder: (_) => const JournalV2Home()))),
            ),
          ]),
        ),
      ),
    );
  }
}

// ---- Empty State ------------------------------------------------------------
class JournalEmptyScreen extends StatelessWidget {
  const JournalEmptyScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 20, 28, 28),
          child: Column(children: [
            const Spacer(),
            Container(
              width: 120,
              height: 120,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(28)),
              child: const Icon(Icons.auto_stories_outlined, size: 52, color: ppPurple),
            ),
            const SizedBox(height: 30),
            Text('Your story\nstarts here', textAlign: TextAlign.center, style: ppFraunces(32, h: 1.15)),
            const SizedBox(height: 14),
            Text('Every photo, every word, every moment you capture becomes a chapter in their life story.',
                textAlign: TextAlign.center, style: ppBody(15, h: 1.6)),
            const Spacer(),
            SizedBox(width: double.infinity, child: jvButton('Add your first memory', () => showAddMemorySheet(context))),
          ]),
        ),
      ),
    );
  }
}

// ---- Home -------------------------------------------------------------------
class JournalV2Home extends StatelessWidget {
  const JournalV2Home({super.key});

  void _push(BuildContext context, Widget s) => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => s));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: Stack(children: [
        ListView(
          padding: const EdgeInsets.only(top: 58, bottom: 100),
          children: [
            // greeting
            jvPad(Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Good morning,', style: ppBody(13, color: ppSoft)),
                  const SizedBox(height: 2),
                  Text(jvParent, style: ppFraunces(28, h: 1.05)),
                  const SizedBox(height: 4),
                  Text('$jvChild · $jvChildAge', style: ppBody(12, color: ppMuted)),
                ]),
              ),
              const SizedBox(width: 12),
              _iconBtn(Icons.search_rounded, () => _push(context, const SearchScreen())),
              const SizedBox(width: 8),
              _iconBtn(Icons.notifications_none_rounded, () => _push(context, const JournalSettingsScreen())),
            ])),

            // continue reading
            const SizedBox(height: 22),
            jvPad(GestureDetector(
              onTap: () => _push(context, const StorybookReaderScreen(startPage: 9)),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(22)),
                child: Row(children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      ppEyebrow('Continue reading', color: ppPurple, spacing: 1.2),
                      const SizedBox(height: 10),
                      Text('Chapter 8 · Puppy Kisses', style: ppJakarta(17)),
                      const SizedBox(height: 4),
                      Text('Page 84 of 168 · last opened yesterday', style: ppBody(12)),
                      const SizedBox(height: 14),
                      Row(mainAxisSize: MainAxisSize.min, children: [
                        Text('Resume reading', style: ppBody(13, color: ppPurple, w: FontWeight.w700)),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward, size: 15, color: ppPurple),
                      ]),
                    ]),
                  ),
                  const SizedBox(width: 14),
                  const JvBookCover(width: 72, height: 96),
                ]),
              ),
            )),

            // recent moments
            const SizedBox(height: 26),
            jvPad(Row(children: [
              Expanded(child: Text('Recent moments', style: ppJakarta(18))),
              GestureDetector(onTap: () => _push(context, const TimelineScreen()), behavior: HitTestBehavior.opaque, child: Text('View all', style: ppBody(12, color: ppPurple, w: FontWeight.w700))),
            ])),
            const SizedBox(height: 14),
            jvPad(GestureDetector(
              onTap: () => openMemory(context, jvFeatured),
              behavior: HitTestBehavior.opaque,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                JvPhoto(
                  seed: jvFeatured.seed,
                  height: 200,
                  radius: 20,
                  dim: true,
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('He laughed so hard when the puppy licked his face!',
                          style: ppBody(14, color: Colors.white, w: FontWeight.w700, h: 1.4)),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text('${jvFeatured.title} · ${jvFeatured.date}', style: ppBody(12, color: ppMuted)),
              ]),
            )),
            const SizedBox(height: 14),
            for (final m in jvMemories.skip(1).take(2)) jvPad(_miniRow(context, m)),

            // keepsake storybook
            const SizedBox(height: 22),
            jvPad(GestureDetector(
              onTap: () => _push(context, const StorybookLibraryScreen()),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFF0E9F7), Color(0xFFE7DAF2)]),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Your keepsake', style: ppFraunces(20, h: 1.1)),
                      const SizedBox(height: 6),
                      Text('248 memories, quietly becoming a book.', style: ppBody(13)),
                      const SizedBox(height: 12),
                      Row(mainAxisSize: MainAxisSize.min, children: [
                        Text('Open the storybook', style: ppBody(13, color: ppPurple, w: FontWeight.w700)),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward, size: 15, color: ppPurple),
                      ]),
                    ]),
                  ),
                  const SizedBox(width: 12),
                  const JvBookCover(width: 64, height: 86),
                ]),
              ),
            )),

            const SizedBox(height: 22),
            jvPad(Text('Capture today. Cherish forever.', textAlign: TextAlign.center, style: ppBody(12, color: ppMuted))),
          ],
        ),

        // top fade
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: Container(
              height: 48,
              decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [ppBg, Color(0x00FBF9FE)])),
            ),
          ),
        ),

        // bottom nav
        Positioned(
          left: 16,
          right: 16,
          bottom: 18,
          child: JvBottomNav(
            active: 0,
            onAdd: () => showAddMemorySheet(context),
            onTab: (i) {
              switch (i) {
                case 1:
                  _push(context, const TimelineScreen());
                  break;
                case 2:
                  _push(context, const LettersScreen());
                  break;
                case 3:
                  _push(context, const SearchScreen());
                  break;
              }
            },
          ),
        ),
      ]),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: ppPanel, shape: BoxShape.circle),
          child: Icon(icon, size: 19, color: ppInk),
        ),
      );

  Widget _miniRow(BuildContext context, JvMemory m) => GestureDetector(
        onTap: () => openMemory(context, m),
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(children: [
            JvPhoto(seed: m.seed, height: 56, width: 56, radius: 14),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(m.title, style: ppJakarta(14)),
                const SizedBox(height: 2),
                Text('${m.date} · ${m.age}', style: ppBody(12, color: ppMuted)),
              ]),
            ),
            const Icon(Icons.chevron_right_rounded, size: 20, color: ppMuted),
          ]),
        ),
      );
}
