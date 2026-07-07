// =============================================================================
//  NameMatchesScreen - Baby Name Finder · matches + crown (parenting · S27·match)
// -----------------------------------------------------------------------------
//  The shared shortlist - every name both parents said yes to - with one name
//  crowned the favourite. Tap any "also loved" name to crown it, then begin its
//  story. Reads the shared NameMatchStore. Faithful build of Claude Design
//  "post pregnancy - content.dc.html" · S27·match.
// =============================================================================

import 'package:flutter/material.dart';

import 'journal_screen.dart';
import 'pp_common.dart';
import 'pp_names_data.dart';

const Color _gold = Color(0xFFE9C877);

class NameMatchesScreen extends StatefulWidget {
  const NameMatchesScreen({super.key});

  @override
  State<NameMatchesScreen> createState() => _NameMatchesScreenState();
}

class _NameMatchesScreenState extends State<NameMatchesScreen> {
  final NameMatchStore _store = NameMatchStore.instance;

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
      );

  @override
  Widget build(BuildContext context) {
    final crowned = babyNameByName(_store.crowned);
    final others = _store.liked.where((n) => n != _store.crowned).toList();
    return Scaffold(
      backgroundColor: ppBg,
      body: Stack(children: [
        ListView(
          padding: const EdgeInsets.only(top: 60, bottom: 40),
          children: [
            // top bar
            _pad(Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(color: ppPanel, shape: BoxShape.circle),
                  child: const Icon(Icons.arrow_back, size: 17, color: ppInk),
                ),
              ),
              GestureDetector(
                onTap: () => _snack('Share your shortlist - coming soon'),
                behavior: HitTestBehavior.opaque,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text('Share', style: ppBody(13, color: ppPurple, w: FontWeight.w700)),
                  const SizedBox(width: 6),
                  const Icon(Icons.favorite, size: 13, color: ppPurple),
                ]),
              ),
            ])),

            // header
            const SizedBox(height: 22),
            _pad(ppEyebrow('You & Ravi', color: ppMuted, spacing: 1.4)),
            const SizedBox(height: 8),
            _pad(Text('Names you both love', style: ppFraunces(31, h: 1.12))),
            const SizedBox(height: 12),
            _pad(Text("${_store.matchedCount} names you've both said yes to. Ready to crown your favourite?", style: ppBody(14))),

            // crowned card
            const SizedBox(height: 22),
            _pad(Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const RadialGradient(center: Alignment(0.55, -0.6), radius: 1.2, colors: [Color(0xFF5A3E8A), Color(0xFF2A2733)]),
                borderRadius: BorderRadius.circular(22),
                boxShadow: const [BoxShadow(color: Color(0x806A30B6), blurRadius: 40, spreadRadius: -18, offset: Offset(0, 16))],
              ),
              child: Column(children: [
                const Icon(Icons.workspace_premium, size: 24, color: _gold),
                const SizedBox(height: 8),
                Text('Your favourite'.toUpperCase(),
                    style: ppBody(10, color: const Color(0xFFC7B2E0), w: FontWeight.w700).copyWith(letterSpacing: 1.4)),
                const SizedBox(height: 6),
                Text(crowned.name, textAlign: TextAlign.center, style: ppFraunces(40, color: Colors.white, h: 1.02)),
                const SizedBox(height: 4),
                Text('“${crowned.meaningShort}”', textAlign: TextAlign.center, style: ppBody(13, color: const Color(0xFFCFC7DA))),
              ]),
            )),

            // also loved
            const SizedBox(height: 24),
            _pad(Text('Also loved · tap to crown'.toUpperCase(),
                style: ppBody(11, color: ppSoft, w: FontWeight.w700).copyWith(letterSpacing: 1.0))),
            const SizedBox(height: 12),
            _pad(Column(children: [
              for (var i = 0; i < others.length; i++) ...[
                if (i > 0) const SizedBox(height: 10),
                _lovedRow(babyNameByName(others[i])),
              ],
            ])),

            // begin the story
            const SizedBox(height: 26),
            _pad(Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [ppStripeB, Color(0xFFECE5F2)]),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(children: [
                Text('A beautiful name deserves a beautiful story.', textAlign: TextAlign.center, style: ppFraunces(18, h: 1.4)),
                const SizedBox(height: 4),
                Text("Let's begin ${crowned.name}'s journey together.", textAlign: TextAlign.center, style: ppBody(13, h: 1.55)),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => _snack('${crowned.name} set as the chosen name'),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: ppPurple, borderRadius: BorderRadius.circular(14)),
                    child: Text("Use as ${crowned.name}'s name →", style: ppBody(14, color: Colors.white, w: FontWeight.w700)),
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const MyChildJournalScreen())),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: ppLine)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.edit_outlined, size: 16, color: ppInk),
                      const SizedBox(width: 8),
                      Text('Write “The story behind my name”', style: ppBody(14, color: ppInk, w: FontWeight.w700)),
                    ]),
                  ),
                ),
              ]),
            )),

            const SizedBox(height: 20),
            _pad(Text('Next, plan the Namkaran - muhurat, invitations & a celebration checklist.',
                textAlign: TextAlign.center, style: ppBody(12, color: ppMuted, h: 1.55))),
          ],
        ),

        // top fade
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: Container(
              height: 52,
              decoration: const BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [ppBg, Color(0x00FBF9FE)]),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _lovedRow(BabyName n) => GestureDetector(
        onTap: () {
          _store.crown(n.name);
          setState(() {});
          _snack('${n.name} crowned your favourite');
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: ppHair)),
          child: Row(children: [
            Text(n.name, style: ppFraunces(24, h: 1.0)),
            const SizedBox(width: 14),
            Expanded(child: Text(n.meaningShort, style: ppBody(13), maxLines: 1, overflow: TextOverflow.ellipsis)),
            const SizedBox(width: 10),
            const Icon(Icons.favorite_border, size: 16, color: Color(0xFFD8C8EA)),
          ]),
        ),
      );
}
