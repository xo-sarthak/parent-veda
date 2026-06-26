// =============================================================================
//  Journal create / edit flows — shared by the Home daily "My Journal" section
//  and the full My Journal screen, so both entry points behave identically.
// -----------------------------------------------------------------------------
//  Five manual entry types: write memory · note for baby · add photo (multiple)
//  · record voice note (multiple, real recording) · custom (user-named tag).
//  Everything is stored in JournalStore and shows up in My Journal.
// =============================================================================

import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../localization/app_language.dart';
import '../../models/journal_entry.dart';
import '../../services/journal_store.dart';
import '../../services/pregnancy_controller.dart';
import '../../theme/app_theme.dart';
import '../mic_dictation_button.dart';

/// A small, on-brand "saved" confirmation at the bottom of the screen.
void _savedSnack(ScaffoldMessengerState m, String msg) {
  m
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppTheme.primary600,
      duration: const Duration(seconds: 2),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      content: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
        const SizedBox(width: 10),
        Flexible(
          child: Text(msg,
              style: GoogleFonts.manrope(
                  color: Colors.white, fontWeight: FontWeight.w600)),
        ),
      ]),
    ));
}

// ---------------------------------------------------------------------------
//  Public entry points
// ---------------------------------------------------------------------------
Future<void> openJournalText(
  BuildContext context,
  PregnancyController p,
  JournalEntryType type, {
  JournalEntry? edit,
}) {
  final s = S(p.language);
  final messenger = ScaffoldMessenger.of(context);
  final isCustom = type == JournalEntryType.custom;
  final isBaby = type == JournalEntryType.noteForBaby;
  final tagCtrl = TextEditingController(text: edit?.customTag ?? '');
  final bodyCtrl = TextEditingController(
      text: isCustom ? (edit?.description ?? '') : (edit?.title ?? ''));
  final title =
      isCustom ? s.jcCustom : (isBaby ? s.jrNoteForBaby : s.jrWriteMemory);
  final hint =
      isCustom ? s.jcCustomBodyHint : (isBaby ? s.jrNoteForBabyHint : s.jrMemoryHint);

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _sheetWrap(
      ctx,
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _grip(),
          const SizedBox(height: 16),
          Text(title,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary900)),
          const SizedBox(height: 14),
          if (isCustom) ...[
            TextField(
              controller: tagCtrl,
              autofocus: true,
              decoration: _fieldDeco(s.jcCustomTagHint),
            ),
            const SizedBox(height: 12),
          ],
          TextField(
            controller: bodyCtrl,
            autofocus: !isCustom,
            minLines: 3,
            maxLines: 6,
            decoration:
                _fieldDeco(hint, suffix: MicDictateButton(controller: bodyCtrl, s: s)),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () async {
                final body = bodyCtrl.text.trim();
                final tag = tagCtrl.text.trim();
                if (isCustom ? (tag.isEmpty && body.isEmpty) : body.isEmpty) {
                  Navigator.pop(ctx);
                  return;
                }
                final store = JournalStore.instance;
                if (edit != null) {
                  await store.updateEntry(isCustom
                      ? edit.copyWith(
                          title: tag.isEmpty ? s.jcCustom : tag,
                          description: body,
                          customTag: tag)
                      : edit.copyWith(title: body));
                } else {
                  await store.addEntry(JournalEntry(
                    id: 'm_${DateTime.now().microsecondsSinceEpoch}',
                    type: type,
                    title: isCustom ? (tag.isEmpty ? s.jcCustom : tag) : body,
                    description: isCustom ? body : '',
                    customTag: isCustom ? tag : '',
                    date: DateTime.now(),
                    weekNumber: p.currentWeek,
                  ));
                }
                if (ctx.mounted) Navigator.pop(ctx);
                _savedSnack(
                    messenger,
                    edit != null
                        ? s.jcUpdated
                        : (isBaby ? s.jcSavedNote : s.jcSavedMemory));
              },
              child: Text(s.jrSaveMemory),
            ),
          ),
        ],
      ),
    ),
  );
}

Future<void> openJournalAddPhoto(
    BuildContext context, PregnancyController p) async {
  final s = S(p.language);
  final messenger = ScaffoldMessenger.of(context);
  // Let the user choose: take a new photo (camera) or pick from the gallery.
  final source = await showModalBottomSheet<ImageSource>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
      child: SafeArea(
        top: false,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: AppTheme.neutral300,
                borderRadius: BorderRadius.circular(99)),
          ),
          const SizedBox(height: 16),
          _photoSourceTile(
              ctx, Icons.photo_camera_rounded, s.jrTakePhoto, ImageSource.camera),
          _photoSourceTile(ctx, Icons.photo_library_rounded, s.jrChooseGallery,
              ImageSource.gallery),
        ]),
      ),
    ),
  );
  if (source == null) return;
  try {
    final saved = <String>[];
    if (source == ImageSource.camera) {
      final x = await ImagePicker().pickImage(
          source: ImageSource.camera, maxWidth: 1600, imageQuality: 85);
      if (x == null) return;
      saved.add(await JournalStore.saveImage(x.path));
    } else {
      final xs =
          await ImagePicker().pickMultiImage(maxWidth: 1600, imageQuality: 85);
      if (xs.isEmpty) return;
      for (final x in xs) {
        saved.add(await JournalStore.saveImage(x.path));
      }
    }
    if (saved.isEmpty) return;
    await JournalStore.instance.addEntry(JournalEntry(
      id: 'p_${DateTime.now().microsecondsSinceEpoch}',
      type: JournalEntryType.photo,
      title: s.jrFilterPhotos,
      date: DateTime.now(),
      weekNumber: p.currentWeek,
      imageUrls: saved,
    ));
    _savedSnack(messenger, s.jcSavedPhoto);
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(s.cameraFailed)));
    }
  }
}

Widget _photoSourceTile(
    BuildContext ctx, IconData icon, String label, ImageSource source) {
  return InkWell(
    borderRadius: BorderRadius.circular(14),
    onTap: () => Navigator.of(ctx).pop(source),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 13),
      child: Row(children: [
        Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: AppTheme.primary500.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(13)),
          child: Icon(icon, color: AppTheme.primary600, size: 21),
        ),
        const SizedBox(width: 14),
        Text(label,
            style: GoogleFonts.manrope(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.primary900)),
      ]),
    ),
  );
}

Future<void> openJournalRecordVoice(
    BuildContext context, PregnancyController p) async {
  final messenger = ScaffoldMessenger.of(context);
  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _VoiceRecordSheet(p: p),
  );
  if (saved == true) _savedSnack(messenger, S(p.language).jcSavedVoice);
}

/// Edit an existing manual entry (text → re-edit; photo/voice → caption).
Future<void> editJournalEntry(
    BuildContext context, PregnancyController p, JournalEntry e) {
  switch (e.type) {
    case JournalEntryType.memory:
    case JournalEntryType.noteForBaby:
    case JournalEntryType.custom:
      return openJournalText(context, p, e.type, edit: e);
    case JournalEntryType.photo:
    case JournalEntryType.voice:
      return _editCaption(context, p, e);
    default:
      return Future.value();
  }
}

Future<void> _editCaption(
    BuildContext context, PregnancyController p, JournalEntry e) {
  final s = S(p.language);
  final messenger = ScaffoldMessenger.of(context);
  final ctrl = TextEditingController(text: e.title);
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _sheetWrap(
      ctx,
      Column(mainAxisSize: MainAxisSize.min, children: [
        _grip(),
        const SizedBox(height: 16),
        TextField(
            controller: ctrl,
            autofocus: true,
            decoration: _fieldDeco(s.jrCaptionHint,
                suffix: MicDictateButton(controller: ctrl, s: s))),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () async {
              await JournalStore.instance
                  .updateEntry(e.copyWith(title: ctrl.text.trim()));
              if (ctx.mounted) Navigator.pop(ctx);
              _savedSnack(messenger, s.jcUpdated);
            },
            child: Text(s.jrSaveMemory),
          ),
        ),
      ]),
    ),
  );
}

// ---------------------------------------------------------------------------
//  Voice recording sheet (real recording via the `record` package)
// ---------------------------------------------------------------------------
class _VoiceRecordSheet extends StatefulWidget {
  const _VoiceRecordSheet({required this.p});
  final PregnancyController p;
  @override
  State<_VoiceRecordSheet> createState() => _VoiceRecordSheetState();
}

class _VoiceRecordSheetState extends State<_VoiceRecordSheet> {
  final AudioRecorder _rec = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  final List<String> _clips = [];
  bool _recording = false;
  String? _playing;

  @override
  void dispose() {
    _rec.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    final s = S(widget.p.language);
    if (_recording) {
      final path = await _rec.stop();
      if (!mounted) return;
      setState(() => _recording = false);
      if (path != null) {
        final saved = await JournalStore.saveAudio(path);
        if (mounted) setState(() => _clips.add(saved));
      }
    } else {
      if (!await _rec.hasPermission()) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(s.jcMicNeeded)));
        }
        return;
      }
      final dir = await getApplicationDocumentsDirectory();
      final jdir = Directory('${dir.path}/journal');
      if (!jdir.existsSync()) jdir.createSync(recursive: true);
      final path =
          '${jdir.path}/rec_${DateTime.now().microsecondsSinceEpoch}.m4a';
      await _rec.start(const RecordConfig(), path: path);
      if (mounted) setState(() => _recording = true);
    }
  }

  Future<void> _play(String path) async {
    if (_playing == path) {
      await _player.stop();
      if (mounted) setState(() => _playing = null);
      return;
    }
    await _player.stop();
    await _player.play(DeviceFileSource(path));
    if (!mounted) return;
    setState(() => _playing = path);
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _playing = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = S(widget.p.language);
    return _sheetWrap(
      context,
      Column(mainAxisSize: MainAxisSize.min, children: [
        _grip(),
        const SizedBox(height: 14),
        Text(s.jcRecordTitle,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.primary900)),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: _toggle,
          child: Container(
            width: 88,
            height: 88,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _recording
                  ? AppTheme.secondary500
                  : AppTheme.primary500.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(_recording ? Icons.stop_rounded : Icons.mic_rounded,
                size: 40,
                color: _recording ? Colors.white : AppTheme.primary500),
          ),
        ),
        const SizedBox(height: 12),
        Text(
            _recording
                ? s.jcRecording
                : (_clips.isEmpty ? s.jcTapToRecord : s.jcRecordAnother),
            style: GoogleFonts.manrope(
                fontSize: 13, color: AppTheme.neutral600)),
        const SizedBox(height: 14),
        for (int i = 0; i < _clips.length; i++)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
                color: AppTheme.surfaceContainer,
                borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              IconButton(
                icon: Icon(
                    _playing == _clips[i]
                        ? Icons.stop_circle_rounded
                        : Icons.play_circle_rounded,
                    color: AppTheme.primary500),
                onPressed: () => _play(_clips[i]),
              ),
              Expanded(
                child: Text('${s.jcVoiceNote} ${i + 1}',
                    style: GoogleFonts.manrope(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary900)),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded,
                    color: AppTheme.neutral400),
                onPressed: () {
                  try {
                    final f = File(_clips[i]);
                    if (f.existsSync()) f.deleteSync();
                  } catch (_) {}
                  setState(() => _clips.removeAt(i));
                },
              ),
            ]),
          ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _clips.isEmpty
                ? null
                : () async {
                    final nav = Navigator.of(context);
                    await JournalStore.instance.addEntry(JournalEntry(
                      id: 'v_${DateTime.now().microsecondsSinceEpoch}',
                      type: JournalEntryType.voice,
                      title: s.jcVoiceNote,
                      date: DateTime.now(),
                      weekNumber: widget.p.currentWeek,
                      audioUrls: List.of(_clips),
                    ));
                    if (mounted) nav.pop(true);
                  },
            child: Text(s.jrSaveMemory),
          ),
        ),
      ]),
    );
  }
}

// ---------------------------------------------------------------------------
//  Small shared sheet helpers
// ---------------------------------------------------------------------------
Widget _sheetWrap(BuildContext ctx, Widget child) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
        child: SafeArea(top: false, child: child),
      ),
    );

Widget _grip() => Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
            color: AppTheme.neutral300, borderRadius: BorderRadius.circular(99)),
      ),
    );

InputDecoration _fieldDeco(String hint, {Widget? suffix}) => InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppTheme.surfaceContainer,
      suffixIcon: suffix,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
    );
