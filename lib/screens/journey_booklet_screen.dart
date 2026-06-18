// =============================================================================
//  JourneyBookletScreen
// -----------------------------------------------------------------------------
//  Shown from the week-40 celebration before generating the keepsake PDF. Lists
//  the weeks that have no memory yet, each with an "Add memory" button that opens
//  that week's journal composer, so the mother can fill any gaps first. When she
//  is ready (or chooses to skip), it builds the multi-page booklet, saves it to
//  the documents directory and opens an in-app preview with share.
// =============================================================================

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../localization/app_language.dart';
import '../services/memory_store.dart';
import '../services/journey_pdf.dart';
import '../theme/app_theme.dart';
import 'journal_writer_screen.dart';

class JourneyBookletScreen extends StatefulWidget {
  const JourneyBookletScreen({
    super.key,
    required this.lang,
    required this.dateRanges,
    required this.completionDate,
  });

  final AppLanguage lang;

  /// Pre-formatted "22–28 Oct" date range per week (4–40).
  final Map<int, String> dateRanges;
  final String completionDate;

  @override
  State<JourneyBookletScreen> createState() => _JourneyBookletScreenState();
}

class _JourneyBookletScreenState extends State<JourneyBookletScreen> {
  bool _busy = false;

  List<int> get _weeks => widget.dateRanges.keys.toList()..sort();

  bool _hasContent(int week) {
    final e = MemoryStore.instance.journalForWeek(week);
    return e != null && (e.text.trim().isNotEmpty || e.photoPaths.isNotEmpty);
  }

  Future<void> _addMemory(int week) async {
    final s = S(widget.lang);
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => JournalWriterScreen(
        lang: widget.lang,
        week: week,
        source: 'reflect_remember',
        prompt: s.howWasYourWeek,
        // Pre-load this week's entry (if any) to keep one entry per week.
        existing: MemoryStore.instance.journalForWeek(week),
      ),
    ));
    if (mounted) setState(() {});
  }

  Future<void> _create() async {
    final s = S(widget.lang);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _busy = true);
    try {
      final weeks = <JourneyWeek>[];
      for (final w in _weeks) {
        final e = MemoryStore.instance.journalForWeek(w);
        if (e == null) continue;
        if (e.text.trim().isEmpty && e.photoPaths.isEmpty) continue;
        weeks.add(JourneyWeek(
          week: w,
          dateRange: widget.dateRanges[w] ?? '',
          text: e.text,
          photoPaths: e.photoPaths,
        ));
      }
      final bytes = await JourneyPdf.build(
        lang: widget.lang,
        weeks: weeks,
        completionDate: widget.completionDate,
      );
      final dir = await getApplicationDocumentsDirectory();
      final stamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${dir.path}/parentveda_journey_$stamp.pdf');
      await file.writeAsBytes(bytes);
      if (!mounted) return;
      navigator.push(MaterialPageRoute(
        builder: (_) => _BookletPreviewScreen(
          lang: widget.lang,
          bytes: bytes,
          filePath: file.path,
        ),
      ));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(s.bookletFailed)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final s = S(widget.lang);
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(s.bookletPreviewTitle, style: text.headlineSmall),
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: MemoryStore.instance,
          builder: (context, _) {
            final missing =
                _weeks.where((w) => !_hasContent(w)).toList();
            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    children: [
                      Text(
                        missing.isEmpty ? s.noMissingWeeks : s.missingWeeksTitle,
                        style: text.headlineSmall
                            ?.copyWith(color: AppTheme.primary700),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        missing.isEmpty ? '' : s.missingWeeksIntro,
                        style: text.bodyMedium
                            ?.copyWith(color: AppTheme.neutral600, height: 1.4),
                      ),
                      if (missing.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(s.weeksWithNoEntry(missing.length),
                            style: text.labelSmall),
                        const SizedBox(height: 14),
                        for (final w in missing)
                          _MissingWeekRow(
                            label: widget.lang.isEnglish
                                ? 'Week $w'
                                : 'Hafta $w',
                            range: widget.dateRanges[w] ?? '',
                            addLabel: s.addMemory,
                            onAdd: _busy ? null : () => _addMemory(w),
                          ),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _busy ? null : _create,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.primary500,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: _busy
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.auto_stories_rounded,
                              color: Colors.white),
                      label: Text(
                        _busy ? s.buildingBooklet : s.createNow,
                        style: text.labelLarge?.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MissingWeekRow extends StatelessWidget {
  const _MissingWeekRow({
    required this.label,
    required this.range,
    required this.addLabel,
    required this.onAdd,
  });
  final String label;
  final String range;
  final String addLabel;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: text.titleMedium),
              if (range.isNotEmpty)
                Text(range, style: text.labelSmall),
            ]),
          ),
          TextButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: Text(addLabel),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  In-app PDF preview + share
// ---------------------------------------------------------------------------

class _BookletPreviewScreen extends StatelessWidget {
  const _BookletPreviewScreen({
    required this.lang,
    required this.bytes,
    required this.filePath,
  });

  final AppLanguage lang;
  final Uint8List bytes;
  final String filePath;

  Future<void> _share(BuildContext context) async {
    final s = S(lang);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await Share.shareXFiles(
        [XFile(filePath, mimeType: 'application/pdf')],
        text: s.celebrationShareText,
      );
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(s.shareFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S(lang);
    return Scaffold(
      appBar: AppBar(
        title: Text(s.bookletPreviewTitle,
            style: Theme.of(context).textTheme.headlineSmall),
        actions: [
          IconButton(
            tooltip: s.forwardWhatsapp,
            onPressed: () => _share(context),
            icon: const Icon(Icons.share_rounded),
          ),
        ],
      ),
      body: PdfPreview(
        build: (format) => bytes,
        canChangePageFormat: false,
        canChangeOrientation: false,
        canDebug: false,
        allowPrinting: true,
        allowSharing: true,
        pdfFileName: filePath.split('/').last,
      ),
    );
  }
}
