// =============================================================================
//  SkKeepsakeScreen — "What I've made and tried"
// -----------------------------------------------------------------------------
//  The no-score tracker, for her and for the parent. A list of the things
//  she did, each with its furthest word — Tried, Practised again, Made —
//  and the day. That is the whole screen. The brief: "Effort and things
//  made, never a grade."
//
//  ⚠️ THE EMPTY STATE IS THE INVITATION. "A feature is never hidden": with
//  nothing recorded the screen says so warmly and points at Things to do.
//
//  ⚠️ NOTHING HERE ADDS UP. No "3 things", no bar, no per-skill tally. The
//  list is in the order she did them, newest first, and the eye can count
//  if it wants to; the screen does not do it for anyone. That line is the
//  keepsake's whole design and `SkPracticeStore`'s API is what holds it.
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../v2/v2_palette.dart';
import 'sk_child_store.dart';
import 'sk_content.dart';
import 'sk_content_registry.dart';
import 'sk_practice_store.dart';

class SkKeepsakeScreen extends StatelessWidget {
  const SkKeepsakeScreen({super.key, required this.doorId, this.doorTitle = ''});
  final String doorId;
  final String doorTitle;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: Listenable.merge([
          V2PaletteStore.instance,
          SkPracticeStore.instance,
          SkChildStore.instance,
        ]),
        builder: (context, _) =>
            _body(context, V2PaletteStore.instance.current),
      );

  Widget _body(BuildContext context, V2Palette p) {
    final lines = SkPracticeStore.instance.entriesFor(doorId);
    final name = SkChildStore.instance.name;
    return Scaffold(
      backgroundColor: p.ground,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 48),
          children: [
            Row(children: [skBack(context, p)]),
            const SizedBox(height: 18),
            if (doorTitle.isNotEmpty)
              Text(doorTitle.toUpperCase(),
                  style: pvManrope(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: p.action)),
            const SizedBox(height: 8),
            Text(skDoorContentFor(doorId)?.keepsakeTitle ?? "What I've made and tried",
                style: pvFraunces(
                    fontSize: kSkTitleSize,
                    fontWeight: FontWeight.w600,
                    height: 1.18,
                    color: p.ink1)),
            const SizedBox(height: 10),
            Text(
                name.isEmpty
                    ? 'The things you tried, did again and made. Words, not marks.'
                    : 'The things $name tried, did again and made. Words, not marks.',
                style: pvManrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                    color: p.ink2)),
            const SizedBox(height: 26),
            if (lines.isEmpty)
              Container(
                key: const Key('sk-keepsake-empty'),
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                decoration: BoxDecoration(
                  color: p.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: p.line),
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.auto_awesome_outlined, size: 22, color: p.action),
                      const SizedBox(height: 10),
                      Text('Nothing here yet, and that is fine.',
                          style: pvFraunces(
                              fontSize: 19,
                              fontWeight: FontWeight.w600,
                              height: 1.25,
                              color: p.ink1)),
                      const SizedBox(height: 6),
                      Text('Try one thing from Things to do. When you tap '
                          '"I tried it", it lands here.',
                          style: pvManrope(
                              fontSize: 15,
                              height: 1.5,
                              color: p.ink2)),
                    ]),
              )
            else
              for (final l in lines) ...[
                _Line(line: l, p: p),
                const SizedBox(height: 10),
              ],
          ],
        ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.line, required this.p});
  final SkKeepsakeLine line;
  final V2Palette p;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    final d = line.lastAt;
    final when = '${d.day} ${_months[d.month - 1]}';
    final icon = switch (line.word) {
      'Made' => Icons.auto_awesome_outlined,
      'Practised again' => Icons.replay_rounded,
      _ => Icons.check_rounded,
    };
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.line),
      ),
      child: Row(children: [
        Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: v2BlockTint(128, p), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, size: 18, color: p.ink1),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(line.title,
                style: pvManrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                    color: p.ink1)),
            const SizedBox(height: 3),
            Text('${line.word}  ·  $when',
                style: pvManrope(fontSize: 13, height: 1.4, color: p.ink2)),
          ]),
        ),
      ]),
    );
  }
}
