// =============================================================================
//  WeekOverviewCard - "ParentVeda Journey" design (de-cluttered week card)
// -----------------------------------------------------------------------------
//  An elevated, de-cluttered take on the week's opening card per the Claude
//  Design "ParentVeda Journey" screen: a soft gradient panel with a progress-
//  RING hero around the baby/fruit figure (size · length · weight beneath), then
//  collapsible accordions (Baby / Mother / Health) so content de-clutters into
//  dropdowns. Horizontal swipe stays (this is one carousel card); each card just
//  scrolls cleaner. Currently used ONLY for week 20 as a preview - the original
//  Size/Baby/Mother cards are untouched (see buildWeekCards).
//
//  PvAccordion is reusable, so the same dropdown pattern can roll out to the
//  other info cards once the look is approved.
// =============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/body_changes.dart';
import '../../data/trimester_tips.dart';
import '../../localization/app_language.dart';
import '../../models/pv_video.dart';
import '../../models/week_content.dart';
import '../../services/size_view_pref.dart';
import '../../services/video_store.dart';
import '../../theme/app_theme.dart';
import '../../theme/father_skin.dart';
import '../cards/food_emoji.dart';

const LinearGradient _pageGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xFFF2E9FB), Color(0xFFF8EFF8), Color(0xFFFBF2F2)],
);

/// Trims wordy prefixes so the stat cards read clean ("a banana" → "Banana",
/// "about 25.7 cm" → "25.7 cm", "ek kela" → "Kela").
String _statValue(String raw) {
  var v = raw.trim();
  const prefixes = [
    'about ',
    'around ',
    'approximately ',
    'lagbhag ',
    'an ',
    'a ',
    'the ',
    'ek ',
  ];
  for (final p in prefixes) {
    if (v.toLowerCase().startsWith(p)) {
      v = v.substring(p.length);
      break;
    }
  }
  if (v.isNotEmpty) v = v[0].toUpperCase() + v.substring(1);
  return v;
}

class WeekOverviewCard extends StatelessWidget {
  const WeekOverviewCard({super.key, required this.w, required this.lang});
  final WeekContent w;
  final AppLanguage lang;

  @override
  Widget build(BuildContext context) {
    final s = S(lang);
    return Container(
      decoration: const BoxDecoration(
        gradient: _pageGradient,
        borderRadius: BorderRadius.all(Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        WeekSizeHero(w: w, lang: lang),
        const SizedBox(height: 20),
        PvAccordion(
          icon: Icons.child_care_rounded,
          color: AppTheme.primary500,
          title: s.ovBaby,
          subtitle: s.ovBabySub,
          initiallyOpen: true,
          child: _RichBaby(w: w, lang: lang),
        ),
        const SizedBox(height: 12),
        PvAccordion(
          icon: Icons.favorite_rounded,
          color: AppTheme.secondary500,
          title: s.ovMother,
          subtitle: s.ovMotherSub,
          child: _RichMother(w: w, lang: lang),
        ),
        const SizedBox(height: 12),
        PvAccordion(
          icon: Icons.health_and_safety_rounded,
          color: AppTheme.primary500,
          title: s.ovHealth,
          subtitle: s.ovHealthSub,
          child: _RichHealth(w: w, lang: lang),
        ),
      ]),
    );
  }
}

// ---------------------------------------------------------------------------
//  Hero - progress ring around baby/fruit + size/length/weight
// ---------------------------------------------------------------------------
class WeekSizeHero extends StatelessWidget {
  const WeekSizeHero(
      {super.key, required this.w, required this.lang, this.father = false});
  final WeekContent w;
  final AppLanguage lang;

  /// Father re-skin (Slate) - colours/fonts only; the real baby/fruit images
  /// are never touched.
  final bool father;

  @override
  Widget build(BuildContext context) {
    final s = S(lang);
    final snap = w.snapshot;
    final progress = (w.week / 40).clamp(0.0, 1.0);
    // Slate-vs-mother resolved tints (chrome only).
    final accent = father ? kFAccent : AppTheme.primary500;
    final accent2 = father ? kFAccent2 : AppTheme.secondary500;
    return ValueListenableBuilder<bool>(
      valueListenable: SizeViewPref.babyMode,
      builder: (context, baby, _) {
        return Column(children: [
          SizedBox(
            height: 250,
            child: Stack(alignment: Alignment.center, children: [
              SizedBox(
                width: 238,
                height: 238,
                child: CustomPaint(painter: _RingPainter(progress, father: father)),
              ),
              // Inner figure circle (real baby image or fruit).
              Container(
                width: 208,
                height: 208,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.fromBorderSide(
                      BorderSide(color: Color(0xFFFBF2F2), width: 6)),
                ),
                child: ClipOval(
                  child: baby
                      ? Image.asset(
                          'assets/baby/week_${w.week.toString().padLeft(2, '0')}.jpg',
                          fit: BoxFit.cover,
                          gaplessPlayback: true,
                          errorBuilder: (_, _, _) => _fruitFigure(),
                        )
                      : _fruitFigure(),
                ),
              ),
              // "Halfway There" milestone pill, top-centre.
              Positioned(
                top: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                  decoration: BoxDecoration(
                    color: father ? kFCard : AppTheme.surface,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                          color: accent.withValues(alpha: 0.16),
                          blurRadius: 14,
                          offset: const Offset(0, 6)),
                    ],
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                            color: accent2, shape: BoxShape.circle)),
                    const SizedBox(width: 7),
                    Text(snap.milestone.of(lang),
                        style: GoogleFonts.manrope(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: father ? kFAccent : AppTheme.primary600)),
                  ]),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 14),
          _BabyFruitToggle(baby: baby, father: father),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
                child: _StatCard(
                    label: s.sizeWord,
                    value: _statValue(snap.fruit.of(lang)),
                    father: father)),
            const SizedBox(width: 10),
            Expanded(
                child: _StatCard(
                    label: s.lengthLabel,
                    value: _statValue(snap.length.of(lang)),
                    father: father)),
            const SizedBox(width: 10),
            Expanded(
                child: _StatCard(
                    label: s.weightLabel,
                    value: _statValue(snap.weight.of(lang)),
                    father: father)),
          ]),
        ]);
      },
    );
  }

  Widget _fruitFigure() => Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.4),
            radius: 1.0,
            colors: [Color(0xFFFDF0C4), Color(0xFFF7DE8E), Color(0xFFEDC85A)],
          ),
        ),
        alignment: Alignment.center,
        child: Text(foodEmojiForWeek(w.week),
            style: const TextStyle(fontSize: 84)),
      );
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.progress, {this.father = false});
  final double progress;
  final bool father;
  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 15.0;
    final c = size.center(Offset.zero);
    final r = (size.width - stroke) / 2;
    final track = father ? kFAccent : AppTheme.primary500;
    // Single arc colour (was a 2-colour gradient) - matches the progress bar.
    final arc = father ? kFAccent : AppTheme.primary500;
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = track.withValues(alpha: 0.14),
    );
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = arc,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.father != father;
}

class _BabyFruitToggle extends StatelessWidget {
  const _BabyFruitToggle({required this.baby, this.father = false});
  final bool baby;
  final bool father;
  @override
  Widget build(BuildContext context) {
    final accent = father ? kFAccent : AppTheme.primary500;
    Widget seg(String label, bool on, VoidCallback onTap) => Expanded(
          child: GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.symmetric(vertical: 10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: on ? accent : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
                boxShadow: on
                    ? [
                        BoxShadow(
                            color: accent.withValues(alpha: 0.32),
                            blurRadius: 10,
                            offset: const Offset(0, 4))
                      ]
                    : null,
              ),
              child: Text(label,
                  style: GoogleFonts.manrope(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: on
                          ? Colors.white
                          : (father ? kFMuted : AppTheme.neutral600))),
            ),
          ),
        );
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(children: [
        seg('Baby', baby, () => SizeViewPref.set(true)),
        seg('Fruit', !baby, () => SizeViewPref.set(false)),
      ]),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard(
      {required this.label, required this.value, this.father = false});
  final String label;
  final String value;
  final bool father;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
      decoration: BoxDecoration(
        color: father ? kFCard : AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: father ? Border.all(color: kFLine) : null,
        boxShadow: const [
          BoxShadow(
              color: Color(0x14704090), blurRadius: 18, offset: Offset(0, 8)),
        ],
      ),
      child: Column(children: [
        Text(label.toUpperCase(),
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
                fontSize: 9.5,
                letterSpacing: 1.0,
                fontWeight: FontWeight.w700,
                color: father ? kFMuted : AppTheme.neutral400)),
        const SizedBox(height: 5),
        Text(value,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: father ? kFInk : AppTheme.primary900)),
      ]),
    );
  }
}

// ---------------------------------------------------------------------------
//  PvAccordion - the reusable dropdown that de-clutters card content
// ---------------------------------------------------------------------------
class PvAccordion extends StatefulWidget {
  const PvAccordion({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    this.subtitle,
    required this.child,
    this.initiallyOpen = false,
  });
  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
  final Widget child;
  final bool initiallyOpen;

  @override
  State<PvAccordion> createState() => _PvAccordionState();
}

class _PvAccordionState extends State<PvAccordion> {
  late bool _open = widget.initiallyOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
              color: Color(0x14704090), blurRadius: 20, offset: Offset(0, 8)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: [
        InkWell(
          onTap: () => setState(() => _open = !_open),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(13)),
                child: Icon(widget.icon, size: 21, color: widget.color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(widget.title,
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primary900)),
                      if (widget.subtitle != null &&
                          widget.subtitle!.isNotEmpty)
                        Text(widget.subtitle!,
                            style: GoogleFonts.manrope(
                                fontSize: 13, color: AppTheme.neutral500)),
                    ]),
              ),
              AnimatedRotation(
                turns: _open ? 0.5 : 0,
                duration: const Duration(milliseconds: 250),
                child: const Icon(Icons.keyboard_arrow_down_rounded,
                    color: AppTheme.neutral400),
              ),
            ]),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: _open
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                  child:
                      Align(alignment: Alignment.topLeft, child: widget.child),
                )
              : const SizedBox(width: double.infinity),
        ),
      ]),
    );
  }
}

// ---------------------------------------------------------------------------
//  Accordion bodies (full content, just collapsed by default = de-cluttered)
// ---------------------------------------------------------------------------
TextStyle _bodyStyle() => GoogleFonts.manrope(
    fontSize: 14.5, height: 1.6, color: const Color(0xFF5B5070));

class _RichBaby extends StatelessWidget {
  const _RichBaby({required this.w, required this.lang});
  final WeekContent w;
  final AppLanguage lang;
  @override
  Widget build(BuildContext context) {
    final d = w.development;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(d.whatImDoing.of(lang), style: _bodyStyle()),
      if (d.funFact != null) ...[
        const SizedBox(height: 12),
        _Tinted(
          icon: Icons.auto_awesome_rounded,
          color: AppTheme.secondary500,
          text: d.funFact!.of(lang),
        ),
      ],
    ]);
  }
}

class _RichMother extends StatelessWidget {
  const _RichMother({required this.w, required this.lang});
  final WeekContent w;
  final AppLanguage lang;
  @override
  Widget build(BuildContext context) {
    final m = w.mom;
    final s = S(lang);
    final changes = kBodyChanges[w.week];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(m.emotionalState.of(lang), style: _bodyStyle()),
      const SizedBox(height: 12),
      // Mother's Body Changes - bucketed biological sections when authored for
      // this week; otherwise the single physical-changes paragraph.
      if (changes != null) ...[
        for (final ch in changes)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ch.label.of(lang),
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.tertiary700)),
                  const SizedBox(height: 2),
                  Text(ch.detail.of(lang), style: _bodyStyle()),
                ]),
          ),
      ] else
        Text(m.physicalChanges.of(lang), style: _bodyStyle()),
      if (m.commonSymptoms.isNotEmpty) ...[
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final sym in m.commonSymptoms)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    color: AppTheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(999)),
                child: Text(sym.of(lang),
                    style: GoogleFonts.manrope(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.neutral700)),
              ),
          ],
        ),
      ],
      const SizedBox(height: 12),
      _Tinted(
          icon: Icons.local_florist_rounded,
          color: AppTheme.tertiary500,
          text: m.selfCareTip.of(lang),
          label: s.selfCare),
    ]);
  }
}

class _RichHealth extends StatelessWidget {
  const _RichHealth({required this.w, required this.lang});
  final WeekContent w;
  final AppLanguage lang;
  @override
  Widget build(BuildContext context) {
    final a = w.actionPlan;
    final s = S(lang);
    // "What to do this week" removed app-wide; Health shows the gentle
    // heads-up (when to contact your doctor) for this week's care.
    return _Tinted(
      icon: Icons.health_and_safety_rounded,
      color: AppTheme.secondary600,
      text: a.redFlags.of(lang),
      label: s.gentleHeadsUp,
    );
  }
}

class _Tinted extends StatelessWidget {
  const _Tinted(
      {required this.icon, required this.color, required this.text, this.label});
  final IconData icon;
  final Color color;
  final String text;
  final String? label;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (label != null) ...[
          Row(children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 6),
            Text(label!.toUpperCase(),
                style: GoogleFonts.manrope(
                    fontSize: 11,
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w800,
                    color: color)),
          ]),
          const SizedBox(height: 6),
          Text(text, style: _bodyStyle()),
        ] else
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon, size: 17, color: color),
            const SizedBox(width: 10),
            Expanded(child: Text(text, style: _bodyStyle())),
          ]),
      ]),
    );
  }
}

// ===========================================================================
//  Week-20 design cards - same elevated panel + dropdown pattern for the rest
//  of the carousel (Video / Nutrition / Action Plan / Share). Week 20 only.
// ===========================================================================

/// The soft gradient panel that every week-20 design card sits on.
class _DesignPanel extends StatelessWidget {
  const _DesignPanel({required this.child, this.father = false});
  final Widget child;
  final bool father;
  @override
  Widget build(BuildContext context) => Container(
        decoration: father
            ? BoxDecoration(
                color: kFCard,
                border: Border.all(color: kFLine),
                borderRadius: const BorderRadius.all(Radius.circular(28)),
              )
            : const BoxDecoration(
                gradient: _pageGradient,
                borderRadius: BorderRadius.all(Radius.circular(28)),
              ),
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
        child: child,
      );
}

Widget _cardHeader(IconData icon, Color color, String eyebrow, String title) {
  return Row(children: [
    Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14)),
      child: Icon(icon, size: 22, color: color),
    ),
    const SizedBox(width: 14),
    Expanded(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(eyebrow.toUpperCase(),
            style: GoogleFonts.manrope(
                fontSize: 11,
                letterSpacing: 0.6,
                fontWeight: FontWeight.w800,
                color: color)),
        Text(title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.primary900)),
      ]),
    ),
  ]);
}

Widget _pill(String text, Color color) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999)),
      child: Text(text,
          style: GoogleFonts.manrope(
              fontSize: 12.5, fontWeight: FontWeight.w700, color: color)),
    );

/// Recommended Watch & Learn video for [week] (nearest curated range).
PvVideo? _pickWeekVideo(int week) {
  final recs =
      kVideos.where((v) => v.category == VideoCategory.recommended).toList();
  for (final v in recs) {
    if (v.matchesWeek(week)) return v;
  }
  if (recs.isEmpty) return null;
  int dist(PvVideo v) => week < v.weekStart
      ? v.weekStart - week
      : (week > v.weekEnd ? week - v.weekEnd : 0);
  recs.sort((a, b) => dist(a).compareTo(dist(b)));
  return recs.first;
}

class WeekVideoCard extends StatelessWidget {
  const WeekVideoCard(
      {super.key, required this.w, required this.lang, this.father = false});
  final WeekContent w;
  final AppLanguage lang;
  final bool father;
  @override
  Widget build(BuildContext context) {
    final s = S(lang);
    final v = _pickWeekVideo(w.week);
    if (v == null) return const SizedBox.shrink();
    final meta = videoMeta(v.category);
    final accent = father ? kFAccent : AppTheme.primary500;
    return _DesignPanel(
      father: father,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            // One heading for the whole week's video - just "Pregnancy Week N".
            // The specific video title was removed: this video covers the entire
            // week, not a single event.
            child: Row(children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14)),
                child: Icon(Icons.play_circle_rounded,
                    size: 22, color: accent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(s.wkPregnancyWeek(w.week),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    // Father uses the MOTHER's heading font (plusJakartaSans),
                    // a bit bolder (w800), in Slate ink - the serif read poorly.
                    style: father
                        ? GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: kFInk)
                        : GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary900)),
              ),
            ]),
          ),
          AnimatedBuilder(
            animation: VideoStore.instance,
            builder: (context, _) {
              final saved = VideoStore.instance.isSaved(v.id);
              return GestureDetector(
                onTap: () => VideoStore.instance.toggle(v.id),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8, top: 2),
                  child: Icon(
                      saved
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      color: accent,
                      size: 22),
                ),
              );
            },
          ),
        ]),
        const SizedBox(height: 14),
        GestureDetector(
          onTap: () => ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(s.wkVideoSoon))),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: father
                        ? const [kFAccent, Color(0xFF1A2A33)]
                        : [meta.color, AppTheme.primary700]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(children: [
                Center(
                  child: Container(
                    width: 58,
                    height: 58,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        shape: BoxShape.circle),
                    child: Icon(Icons.play_arrow_rounded,
                        size: 32, color: father ? kFAccent : AppTheme.primary600),
                  ),
                ),
                Positioned(
                  right: 10,
                  bottom: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(40)),
                    child: Text(v.duration,
                        style: GoogleFonts.manrope(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ]),
            ),
          ),
        ),
        // "Why this matters" removed from the Watch-this-week section - just
        // the video now. Kept (commented) for revert.
        // const SizedBox(height: 12),
        // PvAccordion(
        //   icon: Icons.info_outline_rounded,
        //   color: AppTheme.primary500,
        //   title: s.ovVideoWhy,
        //   initiallyOpen: true,
        //   child: Text(v.reason.of(lang), style: _bodyStyle()),
        // ),
      ]),
    );
  }
}

class WeekNutritionCard extends StatelessWidget {
  const WeekNutritionCard({super.key, required this.w, required this.lang});
  final WeekContent w;
  final AppLanguage lang;
  @override
  Widget build(BuildContext context) {
    final s = S(lang);
    final n = w.nutrition;
    return _DesignPanel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _cardHeader(Icons.restaurant_rounded, AppTheme.tertiary500,
            s.nutritionEyebrow, s.whatToEat),
        const SizedBox(height: 14),
        Wrap(spacing: 8, runSpacing: 8, children: [
          _pill(n.nutritionTheme.of(lang), AppTheme.tertiary500),
          for (final fn in n.focusNutrients)
            _pill(fn.of(lang), AppTheme.primary500),
        ]),
        const SizedBox(height: 12),
        Text(n.whyNow.of(lang), style: _bodyStyle()),
        const SizedBox(height: 14),
        PvAccordion(
          icon: Icons.eco_rounded,
          color: AppTheme.tertiary500,
          title: s.foodsToFavour,
          initiallyOpen: true,
          child: Wrap(spacing: 8, runSpacing: 8, children: [
            for (final f in n.foods)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                    color: AppTheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(999)),
                child: Text(f.of(lang),
                    style: GoogleFonts.manrope(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.neutral700)),
              ),
          ]),
        ),
        if (n.superfood != null) ...[
          const SizedBox(height: 12),
          PvAccordion(
            icon: Icons.star_rounded,
            color: AppTheme.tertiary500,
            title: s.superfoodOfWeek,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(n.superfood!.food.of(lang),
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.tertiary700)),
                  const SizedBox(height: 4),
                  Text(n.superfood!.benefit.of(lang), style: _bodyStyle()),
                  const SizedBox(height: 6),
                  Text(n.superfood!.howToConsume.of(lang),
                      style: GoogleFonts.manrope(
                          fontSize: 13, color: AppTheme.neutral600)),
                ]),
          ),
        ],
        const SizedBox(height: 12),
        PvAccordion(
          icon: Icons.ramen_dining_rounded,
          color: AppTheme.primary500,
          title: s.mealIdeaLabel,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(n.mealIdea.of(lang), style: _bodyStyle()),
            const SizedBox(height: 8),
            Text(n.tip.of(lang), style: _bodyStyle()),
          ]),
        ),
      ]),
    );
  }
}

class WeekActionCard extends StatelessWidget {
  const WeekActionCard({super.key, required this.w, required this.lang});
  final WeekContent w;
  final AppLanguage lang;
  @override
  Widget build(BuildContext context) {
    final s = S(lang);
    final a = w.actionPlan;
    return _DesignPanel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _cardHeader(Icons.checklist_rounded, AppTheme.primary500,
            s.guidanceEyebrow, s.doSkipTruth),
        const SizedBox(height: 14),
        // "What to do this week" removed per Deepti - skip + myth buster only.
        PvAccordion(
          icon: Icons.do_not_disturb_on_rounded,
          color: AppTheme.secondary500,
          title: s.skipThisWeek,
          initiallyOpen: true,
          child: Text(a.skipThisWeek.of(lang), style: _bodyStyle()),
        ),
        const SizedBox(height: 12),
        PvAccordion(
          icon: Icons.lightbulb_rounded,
          color: AppTheme.primary500,
          title: s.mythBuster,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${s.mythLabel}: ${a.mythBuster.myth.of(lang)}',
                style: GoogleFonts.manrope(
                    fontSize: 14,
                    height: 1.5,
                    fontStyle: FontStyle.italic,
                    color: AppTheme.neutral600)),
            const SizedBox(height: 6),
            Text('${s.truthLabel}: ${a.mythBuster.truth.of(lang)}',
                style: _bodyStyle()),
          ]),
        ),
      ]),
    );
  }
}

class WeekShareCard extends StatelessWidget {
  const WeekShareCard({super.key, required this.w, required this.lang});
  final WeekContent w;
  final AppLanguage lang;

  Future<void> _share(BuildContext context, S s) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final msg =
          '👶 ${s.partnerShareHeader(w.week)}\n\n${w.partner.shareMessage.of(lang)}\n\n${s.partnerShareFooter} 💜';
      await Share.share(msg, subject: s.partnerShareSubject(w.week));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(s.shareFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S(lang);
    final p = w.partner;
    return _DesignPanel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _cardHeader(Icons.volunteer_activism_rounded, AppTheme.secondary500,
            s.partnerEyebrow, s.shareJourneyTitle),
        const SizedBox(height: 14),
        PvAccordion(
          icon: Icons.favorite_rounded,
          color: AppTheme.secondary500,
          title: s.whatSheMayFeel,
          initiallyOpen: true,
          child: Text(p.whatSheMayFeel.of(lang), style: _bodyStyle()),
        ),
        const SizedBox(height: 12),
        PvAccordion(
          icon: Icons.handshake_rounded,
          color: AppTheme.primary500,
          title: s.whatYouCanDo,
          child: Text(p.whatYouCanDo.of(lang), style: _bodyStyle()),
        ),
        const SizedBox(height: 12),
        PvAccordion(
          icon: Icons.flag_rounded,
          color: AppTheme.secondary600,
          title: s.oneMission,
          child: Text(p.oneMission.of(lang), style: _bodyStyle()),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primary500,
                padding: const EdgeInsets.symmetric(vertical: 14)),
            onPressed: () => _share(context, s),
            icon: const Icon(Icons.chat_rounded, size: 18, color: Colors.white),
            label: Text(s.forwardWhatsapp,
                style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ),
      ]),
    );
  }
}

class WeekTipsCard extends StatelessWidget {
  const WeekTipsCard({super.key, required this.w, required this.lang});
  final WeekContent w;
  final AppLanguage lang;
  @override
  Widget build(BuildContext context) {
    final s = S(lang);
    final tips = kTrimesterTips[w.week] ?? const <LocalizedText>[];
    if (tips.isEmpty) return const SizedBox.shrink();
    return _DesignPanel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _cardHeader(Icons.tips_and_updates_rounded, AppTheme.tertiary500,
            s.ttEyebrow, s.ttTitle(w.week)),
        const SizedBox(height: 14),
        for (int i = 0; i < tips.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: AppTheme.tertiary500.withValues(alpha: 0.14),
                    shape: BoxShape.circle),
                child: Text('${i + 1}',
                    style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.tertiary700)),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(tips[i].of(lang), style: _bodyStyle())),
            ]),
          ),
      ]),
    );
  }
}

// ---------------------------------------------------------------------------
//  Milestone card - baby's journey as a vertical timeline (reached / this
//  week / upcoming). Week 20 preview; curated baby milestones.
// ---------------------------------------------------------------------------
class _MS {
  const _MS(this.week, this.emoji, this.title, this.desc);
  final int week;
  final String emoji;
  final LocalizedText title;
  final LocalizedText desc;
}

const List<_MS> _milestones = [
  _MS(6, '💓', LocalizedText(en: 'First heartbeat', hi: 'Pehli dhadkan'),
      LocalizedText(
          en: "Your baby's heart began to beat.",
          hi: 'Aapke baby ka dil dhadakna shuru hua.')),
  _MS(12, '🤏', LocalizedText(en: 'First movements', hi: 'Pehli harkatein'),
      LocalizedText(
          en: 'Baby started moving - still too small to feel.',
          hi: 'Baby ne hilna shuru kiya - abhi mehsoos hone ke liye bahut chhota.')),
  _MS(18, '👂', LocalizedText(en: 'Beginning to hear', hi: 'Sunna shuru'),
      LocalizedText(
          en: "Baby's hearing is developing and picking up sound.",
          hi: 'Baby ki sunne ki shakti viksit ho rahi hai.')),
  _MS(
      20,
      '✨',
      LocalizedText(
          en: 'Halfway & first flutters', hi: 'Aadha safar & pehli harkat'),
      LocalizedText(
          en: "You may feel the first kicks - and you're halfway there!",
          hi: 'Aap pehli kicks mehsoos kar sakti hain - aur aadha safar poora!')),
  _MS(24, '🛡️', LocalizedText(en: 'Viability milestone', hi: 'Viability padaav'),
      LocalizedText(
          en: "A major step in your baby's development.",
          hi: 'Aapke baby ke vikas mein ek bada kadam.')),
  _MS(27, '🎵', LocalizedText(en: 'Knows your voice', hi: 'Aapki awaaz pehchaane'),
      LocalizedText(
          en: 'Baby begins to recognise and respond to your voice.',
          hi: 'Baby aapki awaaz pehchaanne aur react karne lagta hai.')),
];

class WeekMilestoneCard extends StatelessWidget {
  const WeekMilestoneCard({super.key, required this.w, required this.lang});
  final WeekContent w;
  final AppLanguage lang;
  @override
  Widget build(BuildContext context) {
    final s = S(lang);
    return _DesignPanel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _cardHeader(
            Icons.flag_rounded, AppTheme.secondary500, s.msEyebrow, s.msTitle),
        const SizedBox(height: 16),
        for (int i = 0; i < _milestones.length; i++)
          _MilestoneRow(
            m: _milestones[i],
            lang: lang,
            currentWeek: w.week,
            isFirst: i == 0,
            isLast: i == _milestones.length - 1,
          ),
      ]),
    );
  }
}

class _MilestoneRow extends StatelessWidget {
  const _MilestoneRow({
    required this.m,
    required this.lang,
    required this.currentWeek,
    required this.isFirst,
    required this.isLast,
  });
  final _MS m;
  final AppLanguage lang;
  final int currentWeek;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final s = S(lang);
    final reached = m.week < currentWeek;
    final current = m.week == currentWeek;
    final lineDone = reached || current;
    final dim = current ? 28.0 : 24.0;
    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Timeline rail.
        SizedBox(
          width: 30,
          child: Column(children: [
            Container(
              width: 2,
              height: 3,
              color: isFirst
                  ? Colors.transparent
                  : (lineDone ? AppTheme.primary500 : AppTheme.outlineVariant),
            ),
            Container(
              width: dim,
              height: dim,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: current
                    ? AppTheme.secondary500
                    : (reached ? AppTheme.primary500 : AppTheme.surface),
                shape: BoxShape.circle,
                border: (!reached && !current)
                    ? Border.all(color: AppTheme.neutral300, width: 2)
                    : null,
                boxShadow: current
                    ? [
                        BoxShadow(
                            color: AppTheme.secondary500.withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3))
                      ]
                    : null,
              ),
              child: current
                  ? const Icon(Icons.star_rounded, size: 15, color: Colors.white)
                  : (reached
                      ? const Icon(Icons.check_rounded,
                          size: 14, color: Colors.white)
                      : null),
            ),
            Expanded(
              child: Container(
                width: 2,
                color: isLast
                    ? Colors.transparent
                    : (reached ? AppTheme.primary500 : AppTheme.outlineVariant),
              ),
            ),
          ]),
        ),
        const SizedBox(width: 14),
        // Content.
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(m.emoji, style: const TextStyle(fontSize: 17)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(m.title.of(lang),
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: current
                              ? AppTheme.secondary700
                              : (reached
                                  ? AppTheme.primary900
                                  : AppTheme.neutral500))),
                ),
                const SizedBox(width: 8),
                if (current)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                        color: AppTheme.secondary500.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(99)),
                    child: Text(s.msThisWeek.toUpperCase(),
                        style: GoogleFonts.manrope(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                            color: AppTheme.secondary700)),
                  )
                else
                  Text(s.jrWeekLabel(m.week),
                      style: GoogleFonts.manrope(
                          fontSize: 11, color: AppTheme.neutral400)),
              ]),
              const SizedBox(height: 3),
              Text(m.desc.of(lang),
                  style: GoogleFonts.manrope(
                      fontSize: 13,
                      height: 1.45,
                      color: (reached || current)
                          ? const Color(0xFF5B5070)
                          : AppTheme.neutral400)),
            ]),
          ),
        ),
      ]),
    );
  }
}
