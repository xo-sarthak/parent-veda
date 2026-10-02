// =============================================================================
//  MemoryPreviewScreen — swipe the templates, then save or share
// -----------------------------------------------------------------------------
//  The details are already entered, so this is pure delight: swipe horizontally
//  and every template instantly re-dresses the same words and photo. Saving is
//  treated as equal to sharing — Save keeps a copy on the device AND in My
//  Memories; Share hands the image to the OS share sheet (the parent picks the
//  app and the people). No auto-messaging, ever.
//
//  ⚠️ REDRAWN ON THE CURRENT UI (2026-10-02, the user: "the whole flow for the
//  memories in the updated new UI"). It was a cream page (#FBF7F2) with a bare
//  arrow, a one-line title, and a Save / Share pair in the old neutral900 and
//  cream. It is now a quiet page on the app's ground, with a round back, a
//  serif title and a sentence, the cards as the picture (the neighbours peek,
//  the chosen one is full size), the design's name and style under it, the dots,
//  and Save and Share as the app's two pills: a hairline one and the one ink
//  one. Mobbin: Public's "Share" (a card, dots, one black pill,
//  https://mobbin.com/screens/e67dfc2b-8ae3-42bd-80d5-1d67a2112d6c), Brink's
//  "Share Episode" (https://mobbin.com/screens/5237f5b7-5ccb-40c1-a678-f809a2884b18),
//  Garmin's "Choose an image" (three actions under a carousel,
//  https://mobbin.com/screens/405bad9a-3513-4926-b085-1d143e607388).
//  The old build is kept below as `_buildClassic`, for revert.
// =============================================================================

import 'package:flutter/material.dart';

import '../../memories/memories_store.dart';
import '../../memories/memory_analytics.dart';
import '../../memories/memory_export.dart';
import '../../memories/memory_models.dart';
import '../../memories/memory_templates.dart';
import '../../theme/app_theme.dart';
import 'memory_card.dart';
import '../../theme/pv_fonts.dart';
import '../../localization/app_language.dart';
import '../products/pv_store_chrome.dart' show PvCommit, kPvInk, pvStorePalette;
import '../v2/v2_palette.dart' show V2Palette;

class MemoryPreviewScreen extends StatefulWidget {
  const MemoryPreviewScreen({
    super.key,
    required this.type,
    required this.data,
    this.initialTemplateId,
  });

  final MemoryType type;
  final MemoryData data;
  final String? initialTemplateId;

  @override
  State<MemoryPreviewScreen> createState() => _MemoryPreviewScreenState();
}

class _MemoryPreviewScreenState extends State<MemoryPreviewScreen> {
  late final List<MemoryTemplate> _templates = templatesFor(widget.type);
  late final List<GlobalKey> _keys =
      List.generate(_templates.length, (_) => GlobalKey());
  late final PageController _page;
  int _index = 0;
  bool _busy = false;

  static const _ink = Color(0xFF3A352E);
  static const _soft = Color(0xFF857D70);

  @override
  void initState() {
    super.initState();
    _index = widget.initialTemplateId == null
        ? 0
        : _templates
            .indexWhere((t) => t.id == widget.initialTemplateId)
            .clamp(0, _templates.length - 1);
    _page = PageController(initialPage: _index, viewportFraction: 0.82);
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => MemoryAnalytics.previewViewed(_templates[_index].id));
  }

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _busy = true);
    final t = _templates[_index];
    final bytes = await MemoryExport.capture(_keys[_index], t.format.exportScale);
    var ok = false;
    if (bytes != null) ok = await MemoryExport.saveToGallery(bytes);
    if (!mounted) return;
    MemoriesStore.instance.save(templateId: t.id, data: widget.data);
    MemoryAnalytics.saved(t.id);
    setState(() => _busy = false);
    _snack(ok
        ? S.now.savedToGalleryAndMemories
        : S.now.savedToMemoriesAllowPhoto);
  }

  Future<void> _share() async {
    setState(() => _busy = true);
    final t = _templates[_index];
    final bytes = await MemoryExport.capture(_keys[_index], t.format.exportScale);
    if (!mounted) return;
    setState(() => _busy = false);
    if (bytes == null) {
      _snack(S.now.couldNotPrepareImage);
      return;
    }
    // Keep a copy in My Memories too — sharing implies keeping.
    MemoriesStore.instance.save(templateId: t.id, data: widget.data);
    MemoryAnalytics.shared(t.id, 'share_sheet');
    await MemoryExport.share(bytes);
  }

  void _snack(String m) => ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    final t = _templates[_index];
    return Scaffold(
      backgroundColor: p.ground,
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Semantics(
                  button: true,
                  label: 'Back',
                  excludeSemantics: true,
                  child: InkWell(
                    key: const ValueKey('memory_preview_back'),
                    onTap: () => Navigator.of(context).maybePop(),
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: p.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: p.line),
                      ),
                      child: Icon(Icons.arrow_back_rounded, size: 19, color: p.ink1),
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 14),
              Text(S.now.uiChooseTemplate,
                  style: pvFraunces(
                      fontSize: 26, fontWeight: FontWeight.w600, height: 1.15, color: p.ink1)),
              const SizedBox(height: 4),
              Text('Swipe to see your words in each design.',
                  style: pvManrope(fontSize: 14, height: 1.4, color: p.ink2)),
            ]),
          ),
          Expanded(
            child: PageView.builder(
              controller: _page,
              itemCount: _templates.length,
              onPageChanged: (i) {
                setState(() => _index = i);
                MemoryAnalytics.templateSelected(_templates[i].id);
              },
              itemBuilder: (context, i) {
                final tt = _templates[i];
                final active = i == _index;
                return Center(
                  child: AnimatedScale(
                    scale: active ? 1 : 0.9,
                    duration: const Duration(milliseconds: 220),
                    child: MemoryCardPreview(
                      template: tt,
                      data: widget.data,
                      captureKey: _keys[i],
                      maxWidth: MediaQuery.of(context).size.width * 0.72,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Text(t.name,
              key: const ValueKey('memory_preview_name'),
              style: pvFraunces(
                  fontSize: 18, fontWeight: FontWeight.w600, height: 1.2, color: p.ink1)),
          const SizedBox(height: 2),
          Text(t.style.label,
              style: pvManrope(fontSize: 12.5, fontWeight: FontWeight.w600, color: p.ink2)),
          const SizedBox(height: 12),
          _dotsNew(p),
          const SizedBox(height: 16),
          _actionsNew(p),
        ]),
      ),
    );
  }

  Widget _dotsNew(V2Palette p) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < _templates.length; i++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: i == _index ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: i == _index ? kPvInk : kPvInk.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
        ],
      );

  /// Save (a hairline pill) and Share (the one ink pill).
  Widget _actionsNew(V2Palette p) => Container(
        decoration: BoxDecoration(
          color: p.ground,
          border: Border(top: BorderSide(color: p.line)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
            child: Row(children: [
              Expanded(
                child: Semantics(
                  button: true,
                  label: S.now.uiSave,
                  excludeSemantics: true,
                  child: InkWell(
                    key: const ValueKey('memory_save'),
                    onTap: _busy ? null : _save,
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      height: 52,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                            color: kPvInk.withValues(alpha: _busy ? 0.18 : 0.4),
                            width: 1.2),
                      ),
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.download_rounded,
                            size: 18, color: _busy ? p.ink3 : p.ink1),
                        const SizedBox(width: 8),
                        Text(S.now.uiSave,
                            style: pvManrope(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: _busy ? p.ink3 : p.ink1)),
                      ]),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PvCommit(
                  key: const ValueKey('memory_share'),
                  label: 'Share',
                  icon: Icons.ios_share_rounded,
                  busy: _busy,
                  onTap: _busy ? null : _share,
                ),
              ),
            ]),
          ),
        ),
      );

  // Kept for revert (2026-10-02): the cream page, the bare arrow and the old
  // neutral900 pair.
  // ignore: unused_element
  Widget _buildClassic(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF7F2),
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Row(children: [
              GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                behavior: HitTestBehavior.opaque,
                child: const Icon(Icons.arrow_back_rounded,
                    size: 22, color: _soft),
              ),
              const SizedBox(width: 12),
              Text(S.now.uiChooseTemplate,
                  style: pvFraunces(
                      fontSize: 20, fontWeight: FontWeight.w600, color: _ink)),
            ]),
          ),
          Expanded(
            child: PageView.builder(
              controller: _page,
              itemCount: _templates.length,
              onPageChanged: (i) {
                setState(() => _index = i);
                MemoryAnalytics.templateSelected(_templates[i].id);
              },
              itemBuilder: (context, i) {
                final t = _templates[i];
                final active = i == _index;
                return Center(
                  child: AnimatedScale(
                    scale: active ? 1 : 0.9,
                    duration: const Duration(milliseconds: 220),
                    child: MemoryCardPreview(
                      template: t,
                      data: widget.data,
                      captureKey: _keys[i],
                      maxWidth: MediaQuery.of(context).size.width * 0.72,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          _dots(),
          const SizedBox(height: 8),
          Text('${_templates[_index].name} · ${_templates[_index].style.label}',
              style: pvManrope(
                  fontSize: 12.5, color: _soft, fontWeight: FontWeight.w600)),
          const SizedBox(height: 14),
          _actions(),
        ]),
      ),
    );
  }

  Widget _dots() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < _templates.length; i++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: i == _index ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: i == _index
                    ? AppTheme.neutral900
                    : AppTheme.neutral900.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
        ],
      );

  Widget _actions() => Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
        decoration: const BoxDecoration(
          color: Color(0xFFFBF7F2),
          border: Border(top: BorderSide(color: Color(0xFFEAE3D8))),
        ),
        child: Row(children: [
          Expanded(
            child: GestureDetector(
              onTap: _busy ? null : _save,
              behavior: HitTestBehavior.opaque,
              child: Container(
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppTheme.neutral900.withValues(alpha: 0.4)),
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.download_rounded,
                      size: 18, color: AppTheme.neutral900),
                  const SizedBox(width: 7),
                  Text(S.now.uiSave,
                      style: pvManrope(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.neutral900)),
                ]),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: _busy ? null : _share,
              behavior: HitTestBehavior.opaque,
              child: Container(
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: AppTheme.neutral900,
                    borderRadius: BorderRadius.circular(16)),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(_busy ? Icons.hourglass_top_rounded : Icons.ios_share_rounded,
                      size: 18, color: Colors.white),
                  const SizedBox(width: 7),
                  Text(_busy ? 'Working…' : 'Share',
                      style: pvManrope(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ]),
              ),
            ),
          ),
        ]),
      );
}
