// =============================================================================
//  BabyNamingHomeScreen - the naming tool's front door (V1 | V2 header toggle)
// -----------------------------------------------------------------------------
//  A single entry that lets us flip between the two naming experiences:
//    • Version 1 - the classic Baby Name Finder (quiz -> swipe deck -> detail ->
//      matches). Untouched; opened as-is.
//    • Version 2 - the new Baby Naming Journey (curated collections -> taste quiz
//      -> couple swipe -> shared matches -> shortlist -> compare -> chosen ->
//      story), with the Name Journey Timeline ribbon.
//  The toggle lives in the header (NameVersionStore, session-persistent) so we can
//  switch instantly while reviewing. Reached from the Tools hub 'Baby names' row.
// =============================================================================

import 'package:flutter/material.dart';

import 'name_finder_screen.dart';
import 'name_journey_feed_screen.dart';
import 'name_journey_shortlist_screen.dart';
import 'pp_common.dart';
import 'pp_names_data.dart';
import 'pp_names_v2_data.dart';

class BabyNamingHomeScreen extends StatelessWidget {
  const BabyNamingHomeScreen({super.key});

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);
  void _push(BuildContext c, Widget s) => Navigator.of(c).push(MaterialPageRoute<void>(builder: (_) => s));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: NameVersionStore.instance,
          builder: (context, _) {
            final v2 = NameVersionStore.instance.isV2;
            return ListView(
              padding: const EdgeInsets.only(top: 12, bottom: 40),
              children: [
                _pad(Row(children: [
                  Expanded(child: ppBack(context, 'Tools')),
                  _versionToggle(),
                ])),
                const SizedBox(height: 20),
                if (v2) ..._v2Home(context) else ..._v1Home(context),
              ],
            );
          },
        ),
      ),
    );
  }

  // ---- the V1 | V2 header toggle ------------------------------------------
  Widget _versionToggle() {
    final store = NameVersionStore.instance;
    Widget seg(String label, NameVersion v) {
      final on = store.version == v;
      return GestureDetector(
        onTap: () => store.setVersion(v),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: on ? ppPurple : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(label, style: ppBody(12, color: on ? Colors.white : ppSoft, w: FontWeight.w700)),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(999)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [seg('V1', NameVersion.v1), seg('V2', NameVersion.v2)]),
    );
  }

  // =========================================================================
  //  Version 1 - the classic Finder (opened as-is)
  // =========================================================================
  List<Widget> _v1Home(BuildContext context) => [
        _pad(ppEyebrow('Version 1 · Baby Name Finder', color: ppMuted)),
        const SizedBox(height: 10),
        _pad(Text.rich(TextSpan(children: [
          const TextSpan(text: 'Find the name '),
          TextSpan(text: 'you both love.', style: ppFraunces(32, color: ppPurple, h: 1.1).copyWith(fontStyle: FontStyle.italic)),
        ]), style: ppFraunces(32, h: 1.1))),
        const SizedBox(height: 12),
        _pad(Text('A quick taste quiz, then you each swipe - only the names you both adore ever surface. Shortlist, compare and choose together.',
            style: ppBody(14.5, h: 1.6))),
        const SizedBox(height: 22),
        _pad(GestureDetector(
          onTap: () => _push(context, const NameFinderScreen()),
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: 54,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: ppPurple,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [BoxShadow(color: Color(0x8C6A30B6), blurRadius: 28, spreadRadius: -10, offset: Offset(0, 12))],
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text('Open the Name Finder', style: ppBody(15, color: Colors.white, w: FontWeight.w700)),
              const SizedBox(width: 8),
              const Text('→', style: TextStyle(color: Colors.white, fontSize: 16)),
            ]),
          ),
        )),
        const SizedBox(height: 22),
        _pad(Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(16)),
          child: Row(children: [
            const Icon(Icons.tune_rounded, size: 18, color: ppPurple),
            const SizedBox(width: 12),
            Expanded(child: Text('Switch to V2 (top-right) for the new Baby Naming Journey - a guided, keepsake-style experience.', style: ppBody(12.5, h: 1.5))),
          ]),
        )),
      ];

  // =========================================================================
  //  Version 2 - the Baby Naming Journey home
  // =========================================================================
  List<Widget> _v2Home(BuildContext context) {
    return [
      nameJourneyRibbon(active: 0),
      const SizedBox(height: 22),
      _pad(ppEyebrow('Version 2 · The Baby Naming Journey', color: ppPurple)),
      const SizedBox(height: 10),
      _pad(Text.rich(TextSpan(children: [
        const TextSpan(text: 'Choose one '),
        TextSpan(text: 'beautiful name,', style: ppFraunces(33, color: ppPurple, h: 1.08).copyWith(fontStyle: FontStyle.italic)),
        const TextSpan(text: ' together.'),
      ]), style: ppFraunces(33, h: 1.08))),
      const SizedBox(height: 12),
      _pad(Text('Not a database to search - a gentle journey from the first spark to the name that becomes the first chapter of your child\'s story.',
          style: ppBody(14.5, h: 1.6))),

      const SizedBox(height: 22),
      _pad(GestureDetector(
        onTap: () => _push(context, const NameJourneyFeedScreen()),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFF1EAF8), Color(0xFFE6D8F1)]),
            borderRadius: BorderRadius.circular(24),
            boxShadow: ppCardShadow,
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.favorite, size: 16, color: ppCoral),
              const SizedBox(width: 8),
              Flexible(child: ppEyebrow('Begin together · 30 seconds', color: ppPurple, spacing: 1.0)),
            ]),
            const SizedBox(height: 12),
            Text('Take the taste quiz, then start swiping', style: ppFraunces(20, h: 1.25)),
            const SizedBox(height: 8),
            Text('You each swipe privately - only the names you both love appear. Every match is a small, happy moment.', style: ppBody(13.5, h: 1.55)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
              decoration: BoxDecoration(color: ppPurple, borderRadius: BorderRadius.circular(999)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text('Begin the journey', style: ppBody(13, color: Colors.white, w: FontWeight.w700)),
                const SizedBox(width: 7),
                const Icon(Icons.arrow_forward, size: 15, color: Colors.white),
              ]),
            ),
          ]),
        ),
      )),

      // shortlist shortcut
      const SizedBox(height: 14),
      _pad(AnimatedBuilder(
        animation: NameMatchStore.instance,
        builder: (context, _) => GestureDetector(
          onTap: () => _push(context, const NameJourneyShortlistScreen()),
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: ppHair)),
            child: Row(children: [
              const Icon(Icons.favorite_border, size: 20, color: ppPurple),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Names we both love', style: ppJakarta(15)),
                  const SizedBox(height: 2),
                  Text('${NameMatchStore.instance.matchedCount} matched · shortlist, compare & choose', style: ppBody(12)),
                ]),
              ),
              const Icon(Icons.chevron_right_rounded, size: 20, color: ppMuted),
            ]),
          ),
        ),
      )),

      // curated collections
      const SizedBox(height: 30),
      _pad(Text('Discover by collection', style: ppJakarta(18))),
      const SizedBox(height: 4),
      _pad(Text('Browse a few beautiful stories, not endless lists.', style: ppBody(12.5, color: ppMuted))),
      const SizedBox(height: 16),
      _pad(Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [for (final c in kNameCollections) _collectionCard(context, c)],
      )),
    ];
  }

  Widget _collectionCard(BuildContext context, NameCollection c) {
    final count = c.names.length;
    return GestureDetector(
      onTap: () => _push(context, NameJourneyFeedScreen(collection: c)),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: (MediaQuery.of(context).size.width - 48 - 12) / 2,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: ppHair)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 40, height: 40, alignment: Alignment.center, decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(12)), child: Icon(c.icon, size: 20, color: ppPurple)),
          const SizedBox(height: 12),
          Text(c.title, style: ppJakarta(14.5).copyWith(height: 1.2), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(c.subtitle, style: ppBody(12, color: ppSoft, h: 1.35), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          Text('$count ${count == 1 ? 'name' : 'names'}', style: ppBody(11, color: ppMuted, w: FontWeight.w700)),
        ]),
      ),
    );
  }
}
