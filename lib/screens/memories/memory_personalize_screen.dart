// =============================================================================
//  MemoryPersonalizeScreen — the only editing the parent does
// -----------------------------------------------------------------------------
//  Just the words and a photo — the fields a parent naturally expects, nothing
//  more. No moving text, no resizing, no free layout. Add a photo and nudge it
//  into place (pinch + drag) inside the frame the template controls. Then
//  Preview, where the templates do all the design.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';

import '../../memories/memory_analytics.dart';
import '../../memories/memory_models.dart';
import '../../memories/memory_photos.dart';
import '../../theme/app_theme.dart';
import 'memory_preview_screen.dart';
import '../../theme/pv_fonts.dart';
import '../../localization/app_language.dart';

class MemoryPersonalizeScreen extends StatefulWidget {
  const MemoryPersonalizeScreen({super.key, required this.type});
  final MemoryType type;

  @override
  State<MemoryPersonalizeScreen> createState() =>
      _MemoryPersonalizeScreenState();
}

class _MemoryPersonalizeScreenState extends State<MemoryPersonalizeScreen> {
  late final MemoryData _data = MemoryData(type: widget.type);

  // Photo gesture state.
  double _baseScale = 1;
  Offset _baseOffset = Offset.zero;

  static const _ink = Color(0xFF3A352E);
  static const _soft = Color(0xFF857D70);

  // Direct picker — NO modal bottom sheet. On some Android devices/drivers the
  // Impeller renderer paints modal sheets & dialogs as a solid black overlay, so
  // the camera/gallery choice is two inline buttons instead. Errors surface in a
  // snackbar rather than being swallowed.
  Future<void> _pick(ImageSource source) async {
    try {
      final x = await ImagePicker()
          .pickImage(source: source, maxWidth: 2000, imageQuality: 92);
      if (x == null) return;
      // Copy out of the picker's CACHE directory before persisting the path -
      // see MemoryPhotos. Never store x.path directly.
      final path = await MemoryPhotos.importPicked(x.path);
      if (!mounted) return;
      setState(() => _data.photo = MemoryPhoto(path));
      MemoryAnalytics.photoAdded(widget.type.name);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(content: Text(S.now.couldNotAddPhoto(e))));
      }
    }
  }

  void _preview() {
    Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) =>
            MemoryPreviewScreen(type: widget.type, data: _data.copy())));
  }

  @override
  Widget build(BuildContext context) {
    final isExpecting = widget.type == MemoryType.expecting;
    return Scaffold(
      backgroundColor: const Color(0xFFFBF7F2),
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                _back(),
                const SizedBox(height: 16),
                Text(widget.type.label,
                    style: pvFraunces(
                        fontSize: 28, fontWeight: FontWeight.w600, color: _ink)),
                const SizedBox(height: 4),
                Text(S.now.uiAddDetailsEverythingOptional,
                    style: pvManrope(fontSize: 13, color: _soft)),
                const SizedBox(height: 22),

                _photoSection(),
                const SizedBox(height: 22),

                if (isExpecting) ...[
                  _field('Couple names', 'e.g. Aarav & Meera',
                      (v) => _data.coupleNames = v),
                  _field('Due month', 'e.g. December 2026',
                      (v) => _data.dueMonth = v),
                ] else ...[
                  _field("Baby's name", 'e.g. Vivaan',
                      (v) => _data.babyName = v),
                  Row(children: [
                    Expanded(
                        child: _field('Birth date', 'e.g. 12 Jul 2026',
                            (v) => _data.birthDate = v)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _field('Time (optional)', 'e.g. 6:40 AM',
                            (v) => _data.birthTime = v)),
                  ]),
                  Row(children: [
                    Expanded(
                        child: _field('Weight (optional)', 'e.g. 3.2 kg',
                            (v) => _data.weight = v)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _field('Length (optional)', 'e.g. 49 cm',
                            (v) => _data.length = v)),
                  ]),
                  _field('Parent names (optional)', 'e.g. Aarav & Meera',
                      (v) => _data.parentNames = v),
                ],
                _field('A short message (optional)',
                    'Say something from the heart…', (v) => _data.message = v,
                    lines: 3),
              ],
            ),
          ),
          _bottomBar(),
        ]),
      ),
    );
  }

  // ---- photo ----------------------------------------------------------------

  Widget _photoSection() {
    final photo = _data.photo;
    if (photo == null) {
      return Container(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: AppTheme.primary500.withValues(alpha: 0.25), width: 1.4),
        ),
        child: Column(children: [
          Icon(Icons.add_a_photo_outlined,
              size: 26, color: AppTheme.primary500),
          const SizedBox(height: 8),
          Text(S.now.uiAddPhotoOptional,
              style: pvManrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary500)),
          const SizedBox(height: 2),
          Text(S.now.uiCanZoomPositionAfter,
              style: pvManrope(fontSize: 11, color: _soft)),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
                child: _pickButton(
                    'Gallery', Icons.photo_library_outlined, ImageSource.gallery)),
            const SizedBox(width: 10),
            Expanded(
                child: _pickButton(
                    'Camera', Icons.photo_camera_outlined, ImageSource.camera)),
          ]),
        ]),
      );
    }
    // Repositionable frame.
    return Column(children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: GestureDetector(
          onScaleStart: (_) {
            _baseScale = photo.scale;
            _baseOffset = photo.offset;
          },
          onScaleUpdate: (d) => setState(() {
            photo.scale = (_baseScale * d.scale).clamp(1.0, 4.0);
            photo.offset = _baseOffset + d.focalPointDelta;
          }),
          child: SizedBox(
            height: 200,
            width: double.infinity,
            child: _RepositionPhoto(photo: photo),
          ),
        ),
      ),
      const SizedBox(height: 8),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(S.now.uiPinchZoomDragPosition,
            style: pvManrope(fontSize: 11.5, color: _soft)),
        Row(children: [
          GestureDetector(
            onTap: () => _pick(ImageSource.gallery),
            child: Text(S.now.uiReplace,
                style: pvManrope(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary500)),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () => setState(() => _data.photo = null),
            child: Text(S.now.uiRemove,
                style: pvManrope(
                    fontSize: 12.5, fontWeight: FontWeight.w700, color: _soft)),
          ),
        ]),
      ]),
    ]);
  }

  Widget _pickButton(String label, IconData icon, ImageSource source) =>
      GestureDetector(
        onTap: () => _pick(source),
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppTheme.primary500.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: AppTheme.primary500.withValues(alpha: 0.22)),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 18, color: AppTheme.primary500),
            const SizedBox(width: 8),
            Text(label,
                style: pvManrope(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary500)),
          ]),
        ),
      );

  // ---- bits -----------------------------------------------------------------

  Widget _field(String label, String hint, ValueChanged<String> onChanged,
          {int lines = 1}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label.toUpperCase(),
              style: pvManrope(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: _soft)),
          const SizedBox(height: 7),
          TextField(
            maxLines: lines,
            onChanged: onChanged,
            style: pvManrope(fontSize: 14, color: _ink),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: pvManrope(
                  fontSize: 13.5, color: const Color(0xFFB8AFA2)),
              isDense: true,
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFEAE3D8)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide(color: AppTheme.primary500.withValues(alpha: 0.6)),
              ),
            ),
          ),
        ]),
      );

  Widget _bottomBar() => Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
        decoration: const BoxDecoration(
          color: Color(0xFFFBF7F2),
          border: Border(top: BorderSide(color: Color(0xFFEAE3D8))),
        ),
        child: GestureDetector(
          onTap: _preview,
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: 54,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: AppTheme.primary500,
                borderRadius: BorderRadius.circular(16)),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(S.now.uiPreviewTemplates,
                  style: pvManrope(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
              const SizedBox(width: 7),
              const Icon(Icons.arrow_forward_rounded,
                  size: 18, color: Colors.white),
            ]),
          ),
        ),
      );

  Widget _back() => GestureDetector(
        onTap: () => Navigator.of(context).maybePop(),
        behavior: HitTestBehavior.opaque,
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.arrow_back_rounded, size: 20, color: _soft),
          const SizedBox(width: 6),
          Text(S.now.uiBack,
              style: pvManrope(
                  fontSize: 13.5, fontWeight: FontWeight.w700, color: _soft)),
        ]),
      );
}

/// The photo panned/zoomed inside its frame while the parent adjusts it.
class _RepositionPhoto extends StatelessWidget {
  const _RepositionPhoto({required this.photo});
  final MemoryPhoto photo;
  @override
  Widget build(BuildContext context) {
    return OverflowBox(
      maxWidth: double.infinity,
      maxHeight: double.infinity,
      child: Transform.translate(
        offset: photo.offset,
        child: Transform.scale(
          scale: photo.scale,
          child: Image.file(File(photo.path),
              fit: BoxFit.cover, width: 400, height: 400),
        ),
      ),
    );
  }
}
