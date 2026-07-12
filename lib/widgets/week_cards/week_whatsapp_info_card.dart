// =============================================================================
//  WeekWhatsAppInfoCard - "This week's update" (the info we send on WhatsApp)
// -----------------------------------------------------------------------------
//  Opened from the small info icon on the week's baby/fruit hero. Presents the
//  weekly baby-development brief the way it would arrive on WhatsApp: a friendly
//  header, the size/length/weight line, an organ / body-systems breakdown as
//  labeled progress bars (from week_development_data), and a tip or two pulled
//  from the week's existing data.
//
//  Entry point:  showWeekWhatsAppInfo(context, w: w, lang: lang, father: father)
//
//  Overflow-safe by design: labels + status words are Flexible + ellipsis, and
//  each progress bar sits on its OWN line (never in a Row beside the label).
//  Bars are static (no AnimationController.repeat) so widget tests settle.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/trimester_tips.dart';
import '../../data/week_development_data.dart';
import '../../localization/app_language.dart';
import '../../models/week_content.dart';
import '../../theme/app_theme.dart';
import '../../theme/father_skin.dart';

/// WhatsApp brand green - used only as a small accent so the card reads as a
/// WhatsApp-style weekly update.
const Color _kWhatsApp = Color(0xFF25D366);

/// Opens the weekly WhatsApp-update card as a bottom sheet.
Future<void> showWeekWhatsAppInfo(
  BuildContext context, {
  required WeekContent w,
  required AppLanguage lang,
  bool father = false,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _WeekWhatsAppSheet(w: w, lang: lang, father: father),
  );
}

class _WeekWhatsAppSheet extends StatelessWidget {
  const _WeekWhatsAppSheet(
      {required this.w, required this.lang, required this.father});
  final WeekContent w;
  final AppLanguage lang;
  final bool father;

  String _t(String en, String hi) => lang.isEnglish ? en : hi;

  /// Up to two tips for this week - the curated trimester tips when present,
  /// else the week's self-care + nutrition tips as a friendly fallback.
  List<String> _tips() {
    final curated = kTrimesterTips[w.week];
    if (curated != null && curated.isNotEmpty) {
      return curated.take(2).map((t) => t.of(lang)).toList();
    }
    final out = <String>[];
    final care = w.mom.selfCareTip.of(lang).trim();
    final eat = w.nutrition.tip.of(lang).trim();
    if (care.isNotEmpty) out.add(care);
    if (eat.isNotEmpty) out.add(eat);
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final accent = father ? kFAccent : AppTheme.primary500;
    final snap = w.snapshot;
    final stats = developmentForWeek(w.week);
    final tips = _tips();
    final maxH = MediaQuery.of(context).size.height * 0.86;

    return Container(
      constraints: BoxConstraints(maxHeight: maxH),
      decoration: BoxDecoration(
        color: father ? kFBg : AppTheme.surfaceContainerLow,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Drag handle.
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 4),
          child: Container(
            width: 42,
            height: 5,
            decoration: BoxDecoration(
                color: AppTheme.neutral300,
                borderRadius: BorderRadius.circular(99)),
          ),
        ),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(context, accent),
                  const SizedBox(height: 16),
                  // Friendly WhatsApp-style opener.
                  Text(
                    _t("Hi! Here's your Week ${w.week} update 💜",
                        'Namaste! Yeh raha aapka Hafta ${w.week} ka update 💜'),
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                        color: father ? kFInk : AppTheme.primary900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _t('Your baby is about ${_clean(snap.fruit.of(lang))} this week.',
                        'Aapka baby is hafte lagbhag ${_clean(snap.fruit.of(lang))} jitna hai.'),
                    style: GoogleFonts.manrope(
                        fontSize: 14, height: 1.5, color: AppTheme.neutral600),
                  ),
                  const SizedBox(height: 16),
                  _sizeRow(),
                  const SizedBox(height: 20),
                  _sectionLabel(
                      Icons.monitor_heart_rounded,
                      accent,
                      _t("Baby's development", 'Baby ka vikas')),
                  const SizedBox(height: 14),
                  for (int i = 0; i < stats.length; i++) ...[
                    _StatBar(stat: stats[i], accent: accent, lang: lang),
                    if (i != stats.length - 1) const SizedBox(height: 14),
                  ],
                  if (tips.isNotEmpty) ...[
                    const SizedBox(height: 22),
                    _sectionLabel(Icons.tips_and_updates_rounded,
                        AppTheme.tertiary500, _t("This week's tips", 'Is hafte ke tips')),
                    const SizedBox(height: 12),
                    for (final tip in tips)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _TipRow(text: tip),
                      ),
                  ],
                  const SizedBox(height: 8),
                  _footer(),
                ]),
          ),
        ),
      ]),
    );
  }

  Widget _header(BuildContext context, Color accent) {
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: _kWhatsApp.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(13)),
        child: const Icon(Icons.chat_rounded, size: 21, color: _kWhatsApp),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_t("This week's update", 'Is hafte ka update'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: father ? kFInk : AppTheme.primary900)),
              Text(_t('What we send you on WhatsApp',
                  'Jo hum aapko WhatsApp par bhejte hain'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                      fontSize: 12.5, color: AppTheme.neutral500)),
            ]),
      ),
      const SizedBox(width: 8),
      GestureDetector(
        onTap: () => Navigator.of(context).maybePop(),
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: AppTheme.surfaceContainer,
              borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.close_rounded,
              size: 18, color: AppTheme.neutral600),
        ),
      ),
    ]);
  }

  Widget _sizeRow() {
    final snap = w.snapshot;
    return Row(children: [
      Expanded(
          child: _MiniStat(
              label: _t('SIZE', 'AAKAR'), value: _clean(snap.fruit.of(lang)), father: father)),
      const SizedBox(width: 10),
      Expanded(
          child: _MiniStat(
              label: _t('LENGTH', 'LAMBAI'), value: _clean(snap.length.of(lang)), father: father)),
      const SizedBox(width: 10),
      Expanded(
          child: _MiniStat(
              label: _t('WEIGHT', 'VAZAN'), value: _clean(snap.weight.of(lang)), father: father)),
    ]);
  }

  Widget _sectionLabel(IconData icon, Color color, String text) {
    return Row(children: [
      Icon(icon, size: 17, color: color),
      const SizedBox(width: 8),
      Flexible(
        child: Text(text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
                color: father ? kFInk : AppTheme.primary900)),
      ),
    ]);
  }

  Widget _footer() {
    return Row(children: [
      Icon(Icons.verified_rounded, size: 14, color: AppTheme.neutral400),
      const SizedBox(width: 6),
      Flexible(
        child: Text(
          _t('ParentVeda - gentle, weekly, on WhatsApp',
              'ParentVeda - har hafte, WhatsApp par'),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.manrope(
              fontSize: 12, color: AppTheme.neutral400),
        ),
      ),
    ]);
  }
}

/// Trims wordy prefixes ("about 25 cm" -> "25 cm", "a banana" -> "Banana").
String _clean(String raw) {
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

class _MiniStat extends StatelessWidget {
  const _MiniStat(
      {required this.label, required this.value, required this.father});
  final String label;
  final String value;
  final bool father;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 13),
      decoration: BoxDecoration(
        color: father ? kFCard : AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: father ? Border.all(color: kFLine) : null,
        boxShadow: const [
          BoxShadow(
              color: Color(0x11704090), blurRadius: 14, offset: Offset(0, 6)),
        ],
      ),
      child: Column(children: [
        Text(label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.manrope(
                fontSize: 9.5,
                letterSpacing: 0.9,
                fontWeight: FontWeight.w700,
                color: father ? kFMuted : AppTheme.neutral400)),
        const SizedBox(height: 4),
        Text(value,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: father ? kFInk : AppTheme.primary900)),
      ]),
    );
  }
}

/// One labeled progress bar (label + status word on the top row, bar below).
class _StatBar extends StatelessWidget {
  const _StatBar(
      {required this.stat, required this.accent, required this.lang});
  final DevelopmentStat stat;
  final Color accent;
  final AppLanguage lang;

  @override
  Widget build(BuildContext context) {
    final v = stat.progress.clamp(0.0, 1.0);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(
          flex: 3,
          child: Text(stat.label.of(lang),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.manrope(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.neutral700)),
        ),
        const SizedBox(width: 10),
        Flexible(
          flex: 2,
          child: Text(stat.status.of(lang),
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.manrope(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: accent)),
        ),
      ]),
      const SizedBox(height: 7),
      // Bar on its own line - never beside the label (overflow-safe).
      SizedBox(
        height: 9,
        width: double.infinity,
        child: Stack(children: [
          Container(
            decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(99)),
          ),
          FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: v <= 0 ? 0.03 : v,
            child: Container(
              decoration: BoxDecoration(
                  color: accent, borderRadius: BorderRadius.circular(99)),
            ),
          ),
        ]),
      ),
    ]);
  }
}

class _TipRow extends StatelessWidget {
  const _TipRow({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppTheme.tertiary500.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.check_circle_rounded,
            size: 17, color: AppTheme.tertiary500),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text,
              style: GoogleFonts.manrope(
                  fontSize: 13.5,
                  height: 1.5,
                  color: const Color(0xFF5B5070))),
        ),
      ]),
    );
  }
}
