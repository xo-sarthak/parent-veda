// =============================================================================
//  MemoryPreviewScreen — swipe the templates, then save or share
// -----------------------------------------------------------------------------
//  The details are already entered, so this is pure delight: swipe horizontally
//  and every template instantly re-dresses the same words and photo. Saving is
//  treated as equal to sharing — Save keeps a copy on the device AND in My
//  Memories; Share hands the image to the OS share sheet (the parent picks the
//  app and the people). No auto-messaging, ever.
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
        ? 'Saved to your gallery and My Memories.'
        : 'Saved to My Memories. Allow photo access to save to your gallery.');
  }

  Future<void> _share() async {
    setState(() => _busy = true);
    final t = _templates[_index];
    final bytes = await MemoryExport.capture(_keys[_index], t.format.exportScale);
    if (!mounted) return;
    setState(() => _busy = false);
    if (bytes == null) {
      _snack('Could not prepare the image. Try again.');
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
              Text('Choose a template',
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
                    ? AppTheme.primary500
                    : AppTheme.primary500.withValues(alpha: 0.25),
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
                      color: AppTheme.primary500.withValues(alpha: 0.4)),
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.download_rounded,
                      size: 18, color: AppTheme.primary500),
                  const SizedBox(width: 7),
                  Text('Save',
                      style: pvManrope(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary500)),
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
                    color: AppTheme.primary500,
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
