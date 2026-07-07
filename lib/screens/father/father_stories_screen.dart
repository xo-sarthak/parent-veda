// =============================================================================
//  FatherStoriesScreen - "Stories, Fables & Mythology" library (Father mode)
// -----------------------------------------------------------------------------
//  Opened from the Father Daily "Stories, fables & mythology" card. A Slate-
//  palette library (matching the Father Daily screen) with three tabs -
//  Stories / Fables / Mythology - each listing read-aloud pieces. Tapping one
//  opens a calm reading view with the dad's framing note.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/father/father_tales.dart';

// ---- Slate palette (mirrors the Father Daily _slate look) -----------------
const _bg = Color(0xFFF4EFE8);
const _card = Color(0xFFFFFFFF);
const _line = Color(0xFFECE5DA);
const _ink = Color(0xFF22333B);
const _muted = Color(0xFF6A7B82);
const _accent = Color(0xFF2E5266);
const _accent2 = Color(0xFFE0915B);
const _accentSoft = Color(0xFFE7EDEF);
const _warmSoft = Color(0xFFFBEDDE);
const _cream = Color(0xFFFBF7F0);

class FatherStoriesScreen extends StatefulWidget {
  const FatherStoriesScreen({super.key});

  @override
  State<FatherStoriesScreen> createState() => _FatherStoriesScreenState();
}

class _FatherStoriesScreenState extends State<FatherStoriesScreen> {
  FatherTaleKind _kind = FatherTaleKind.story;

  TextStyle _serif(double size, Color c, {FontWeight w = FontWeight.w600}) =>
      GoogleFonts.fraunces(
          fontSize: size, fontWeight: w, color: c, height: 1.2, letterSpacing: -0.2);
  TextStyle _body(double size, Color c,
          {FontWeight w = FontWeight.w400, double h = 1.5}) =>
      GoogleFonts.plusJakartaSans(
          fontSize: size, fontWeight: w, color: c, height: h);

  @override
  Widget build(BuildContext context) {
    final tales = fatherTalesOf(_kind);
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          // header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 18, 8),
            child: Row(children: [
              GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _card,
                    shape: BoxShape.circle,
                    border: Border.all(color: _line),
                  ),
                  child: const Icon(Icons.arrow_back_rounded, color: _ink, size: 20),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('FOR YOU TO READ ALOUD',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.14 * 11,
                          color: _muted)),
                  const SizedBox(height: 2),
                  Text('Stories, Fables & Mythology',
                      style: _serif(21, _ink, w: FontWeight.w600)),
                ]),
              ),
            ]),
          ),
          // segmented control
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                  color: _accentSoft, borderRadius: BorderRadius.circular(999)),
              child: Row(children: [
                for (final k in FatherTaleKind.values) _segment(k),
              ]),
            ),
          ),
          // list
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
              itemCount: tales.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _taleCard(tales[i]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _segment(FatherTaleKind k) {
    final active = _kind == k;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _kind = k),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 9),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? _card : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            boxShadow: active
                ? const [
                    BoxShadow(
                        color: Color(0x141C2830),
                        blurRadius: 4,
                        offset: Offset(0, 1))
                  ]
                : null,
          ),
          child: Text(fatherTaleKindLabel(k),
              style: _body(13, active ? _accent : _muted,
                  w: active ? FontWeight.w700 : FontWeight.w600)),
        ),
      ),
    );
  }

  Widget _taleCard(FatherTale t) => GestureDetector(
        onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => FatherTaleReadScreen(tale: t))),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _line),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                    color: _accentSoft, borderRadius: BorderRadius.circular(999)),
                child: Text(fatherTaleKindTag(t.kind).toUpperCase(),
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.08 * 9.5,
                        color: _accent)),
              ),
              const Spacer(),
              const Icon(Icons.chevron_right_rounded, color: _muted, size: 20),
            ]),
            const SizedBox(height: 10),
            Text(t.title, style: _serif(18, _ink, w: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(t.body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: _body(13.5, _muted, h: 1.45)),
          ]),
        ),
      );
}

// =============================================================================
//  Reading view
// =============================================================================
class FatherTaleReadScreen extends StatelessWidget {
  const FatherTaleReadScreen({super.key, required this.tale});
  final FatherTale tale;

  TextStyle _serif(double size, Color c, {FontWeight w = FontWeight.w600}) =>
      GoogleFonts.fraunces(
          fontSize: size, fontWeight: w, color: c, height: 1.2, letterSpacing: -0.2);
  TextStyle _body(double size, Color c,
          {FontWeight w = FontWeight.w400, double h = 1.5}) =>
      GoogleFonts.plusJakartaSans(
          fontSize: size, fontWeight: w, color: c, height: h);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 18, 8),
            child: Row(children: [
              GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _card,
                    shape: BoxShape.circle,
                    border: Border.all(color: _line),
                  ),
                  child: const Icon(Icons.arrow_back_rounded, color: _ink, size: 20),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Text(fatherTaleKindTag(tale.kind).toUpperCase(),
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.14 * 11,
                        color: _accent)),
              ),
            ]),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(22, 6, 22, 36),
              children: [
                Text(tale.title, style: _serif(27, _ink)),
                const SizedBox(height: 10),
                Row(children: [
                  const Icon(Icons.auto_stories_rounded, size: 16, color: _muted),
                  const SizedBox(width: 7),
                  Text('Read it aloud - let your voice rise and fall',
                      style: _body(12.5, _muted, w: FontWeight.w500)),
                ]),
                const SizedBox(height: 20),
                Text(tale.body, style: _body(16.5, _ink.withValues(alpha: 0.92), h: 1.7)),
                if (tale.moral.isNotEmpty) ...[
                  const SizedBox(height: 22),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                    decoration: BoxDecoration(
                        color: _warmSoft, borderRadius: BorderRadius.circular(16)),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('THE LESSON',
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.12 * 11,
                                  color: _accent2)),
                          const SizedBox(height: 5),
                          Text(tale.moral,
                              style: _body(14.5, _ink, w: FontWeight.w500, h: 1.45)),
                        ]),
                  ),
                ],
                if (tale.dadNote.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                    decoration: BoxDecoration(
                      color: _cream,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _line),
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('FROM DAD',
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.12 * 11,
                                  color: _accent)),
                          const SizedBox(height: 6),
                          Text(tale.dadNote,
                              style: GoogleFonts.fraunces(
                                  fontSize: 15.5,
                                  fontStyle: FontStyle.italic,
                                  height: 1.5,
                                  color: _ink)),
                        ]),
                  ),
                ],
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
