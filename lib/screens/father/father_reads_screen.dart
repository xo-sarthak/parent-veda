// =============================================================================
//  FatherReadsScreen - the father's "Reads" tab (Slate)
// -----------------------------------------------------------------------------
//  A tab in the unified father shell (mirrors the mother's nav structure, in the
//  father palette/fonts). Lists the father read articles (kFatherReadItems) with
//  a calm Slate reader, plus a way into the Stories, Fables & Mythology tales.
//  Embedded as a tab → no back button, bottom padding clears the floating pill.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/father/father_read_data.dart';
import '../../models/read_item.dart';
import '../../theme/father_skin.dart';
import 'father_stories_screen.dart';

class FatherReadsScreen extends StatelessWidget {
  const FatherReadsScreen({super.key});

  TextStyle _body(double s,
          {FontWeight w = FontWeight.w400, Color c = kFInk, double h = 1.5}) =>
      GoogleFonts.plusJakartaSans(fontSize: s, fontWeight: w, color: c, height: h);
  TextStyle _eyebrow(Color c) => GoogleFonts.plusJakartaSans(
      fontSize: 11, fontWeight: FontWeight.w700, color: c, letterSpacing: 1.4);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kFBg,
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 120),
          children: [
            Text('FOR YOU, DAD', style: _eyebrow(kFMuted)),
            const SizedBox(height: 4),
            Text('Reads', style: fatherSerif(26, weight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text('Short reads about her, the baby, and how to show up.',
                style: _body(13, c: kFMuted)),
            const SizedBox(height: 16),
            // Tales entry - the Stories, Fables & Mythology collection.
            _talesCard(context),
            const SizedBox(height: 18),
            Text('ARTICLES', style: _eyebrow(kFAccent)),
            const SizedBox(height: 10),
            for (final r in kFatherReadItems) _readCard(context, r),
          ],
        ),
      ),
    );
  }

  Widget _talesCard(BuildContext context) => GestureDetector(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const FatherStoriesScreen())),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: kFAccent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: kFAccent2, borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.history_edu_rounded,
                  color: kFCream, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Stories, Fables & Mythology',
                        style: fatherSerif(17, color: kFCream)),
                    const SizedBox(height: 3),
                    Text('Tales to read aloud to the bump',
                        style: _body(12.5,
                            c: kFCream.withValues(alpha: 0.85))),
                  ]),
            ),
            Icon(Icons.chevron_right_rounded,
                color: kFCream.withValues(alpha: 0.9)),
          ]),
        ),
      );

  Widget _readCard(BuildContext context, ReadItem r) => GestureDetector(
        onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => _FatherReadReader(read: r))),
        behavior: HitTestBehavior.opaque,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kFCard,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: kFLine),
          ),
          child: Row(children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: kFAccentSoft, borderRadius: BorderRadius.circular(14)),
              child: Text(r.emoji, style: const TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.title,
                        style: fatherSerif(16, weight: FontWeight.w600)),
                    const SizedBox(height: 5),
                    Text('${r.readingTime} · ${r.category}',
                        style: _body(12, c: kFMuted)),
                  ]),
            ),
            const Icon(Icons.chevron_right_rounded, color: kFMuted),
          ]),
        ),
      );
}

// ---------------------------------------------------------------------------
//  A calm Slate reader for a single father article.
// ---------------------------------------------------------------------------
class _FatherReadReader extends StatelessWidget {
  const _FatherReadReader({required this.read});
  final ReadItem read;

  @override
  Widget build(BuildContext context) {
    final paras = read.body.split('\n\n');
    return Scaffold(
      backgroundColor: kFBg,
      appBar: AppBar(
        backgroundColor: kFBg,
        elevation: 0,
        foregroundColor: kFInk,
        title: Text(read.category,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
                color: kFMuted)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(22, 6, 22, 36),
        children: [
          Text(read.title, style: fatherSerif(27, weight: FontWeight.w600)),
          const SizedBox(height: 9),
          Text('${read.readingTime} · ${read.category}',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5, fontWeight: FontWeight.w500, color: kFMuted)),
          const SizedBox(height: 18),
          for (final para in paras) ...[
            Text(para,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 15.5,
                    height: 1.62,
                    color: kFInk.withValues(alpha: 0.9))),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}
