// =============================================================================
//  JournalWriterScreen
// -----------------------------------------------------------------------------
//  The one merged journaling surface for the whole app. A single gentle prompt
//  — "How was your last week?" — that the mother can either WRITE or SPEAK
//  (on-device speech-to-text), plus up to TWO photos kept with the note.
//  Creates a new entry or edits an existing one.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../localization/app_language.dart';
import '../models/memory_models.dart';
import '../widgets/storage_image.dart';
import '../services/memory_store.dart';
import '../theme/app_theme.dart';

const int kMaxNotePhotos = 2;

class JournalWriterScreen extends StatefulWidget {
  const JournalWriterScreen({
    super.key,
    required this.lang,
    required this.week,
    required this.source,
    required this.prompt,
    this.existing,
  });

  final AppLanguage lang;
  final int week;
  final String source;
  final String prompt;
  final JournalEntry? existing;

  @override
  State<JournalWriterScreen> createState() => _JournalWriterScreenState();
}

class _JournalWriterScreenState extends State<JournalWriterScreen> {
  late final TextEditingController _ctrl;
  final stt.SpeechToText _speech = stt.SpeechToText();

  final List<String> _photos = [];
  bool _listening = false;
  bool _busyPhoto = false;
  String _dictationBase = '';

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.existing?.text ?? '');
    if (widget.existing != null) _photos.addAll(widget.existing!.photoPaths);
  }

  @override
  void dispose() {
    _speech.stop();
    _ctrl.dispose();
    super.dispose();
  }

  String get _promptText =>
      widget.prompt.trim().isNotEmpty ? widget.prompt : S(widget.lang).howWasYourWeek;

  // ---- Voice dictation -------------------------------------------------------

  Future<void> _toggleMic() async {
    final s = S(widget.lang);
    final messenger = ScaffoldMessenger.of(context);
    if (_listening) {
      await _speech.stop();
      if (mounted) setState(() => _listening = false);
      return;
    }
    final available = await _speech.initialize(
      onStatus: (status) {
        if ((status == 'done' || status == 'notListening') && mounted) {
          setState(() => _listening = false);
        }
      },
      onError: (_) {
        if (mounted) setState(() => _listening = false);
      },
    );
    if (!available) {
      messenger.showSnackBar(SnackBar(content: Text(s.micPermissionNeeded)));
      return;
    }
    _dictationBase = _ctrl.text;
    setState(() => _listening = true);
    await _speech.listen(onResult: (result) {
      final words = result.recognizedWords;
      final sep = _dictationBase.isEmpty || _dictationBase.endsWith(' ') ? '' : ' ';
      final next = '$_dictationBase$sep$words';
      _ctrl.value = TextEditingValue(
        text: next,
        selection: TextSelection.collapsed(offset: next.length),
      );
    });
  }

  // ---- Photos ---------------------------------------------------------------

  Future<void> _addPhoto() async {
    final s = S(widget.lang);
    final messenger = ScaffoldMessenger.of(context);
    if (_photos.length >= kMaxNotePhotos) {
      messenger.showSnackBar(SnackBar(content: Text(s.photoLimitReached)));
      return;
    }
    setState(() => _busyPhoto = true);
    final path = await MemoryStore.instance.capturePhotoFile();
    if (!mounted) return;
    setState(() {
      _busyPhoto = false;
      if (path != null) _photos.add(path);
    });
    if (path == null) {
      messenger.showSnackBar(SnackBar(content: Text(s.cameraFailed)));
    }
  }

  void _removePhoto(String path) {
    setState(() => _photos.remove(path));
  }

  // ---- Save -----------------------------------------------------------------

  Future<void> _save() async {
    final s = S(widget.lang);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (_listening) await _speech.stop();
    final text = _ctrl.text.trim();
    // Nothing written and no photos → just leave without creating an empty note.
    if (text.isEmpty && _photos.isEmpty) {
      navigator.pop();
      return;
    }
    if (widget.existing != null) {
      await MemoryStore.instance
          .updateJournal(widget.existing!.id, text, photoPaths: _photos);
    } else {
      await MemoryStore.instance.addJournal(
        week: widget.week,
        source: widget.source,
        prompt: _promptText,
        text: text,
        photoPaths: _photos,
      );
    }
    messenger.showSnackBar(SnackBar(content: Text(s.journalSaved)));
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final s = S(widget.lang);
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(s.myJournal, style: text.headlineSmall),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check_rounded, size: 18),
              label: Text(s.saveToJournal),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.primary50,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Text(
                  widget.lang.isEnglish
                      ? 'Week ${widget.week}'
                      : 'Hafta ${widget.week}',
                  style: text.labelMedium?.copyWith(
                      color: AppTheme.primary600, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 16),
              Text(_promptText,
                  style: text.headlineSmall?.copyWith(color: AppTheme.primary700)),
              const SizedBox(height: 16),
              _PhotoStrip(
                photos: _photos,
                busy: _busyPhoto,
                lang: widget.lang,
                onAdd: _addPhoto,
                onRemove: _removePhoto,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  autofocus: false,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  keyboardType: TextInputType.multiline,
                  style: text.bodyLarge?.copyWith(height: 1.6),
                  decoration: InputDecoration(
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    hintText: _listening ? s.listening : s.writePlaceholder,
                    hintStyle: text.bodyLarge?.copyWith(
                      color: AppTheme.neutral400,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
              _MicBar(
                listening: _listening,
                lang: widget.lang,
                onTap: _toggleMic,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  Photo strip (up to 2)
// ---------------------------------------------------------------------------

class _PhotoStrip extends StatelessWidget {
  const _PhotoStrip({
    required this.photos,
    required this.busy,
    required this.lang,
    required this.onAdd,
    required this.onRemove,
  });

  final List<String> photos;
  final bool busy;
  final AppLanguage lang;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final s = S(lang);
    final canAdd = photos.length < kMaxNotePhotos;
    return SizedBox(
      height: 88,
      child: Row(
        children: [
          for (final p in photos)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: StorageImage(p,
                        width: 88, height: 88, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 2,
                    right: 2,
                    child: GestureDetector(
                      onTap: () => onRemove(p),
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close_rounded,
                            size: 15, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (canAdd)
            GestureDetector(
              onTap: busy ? null : onAdd,
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: AppTheme.primary50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.primary100, width: 1.2),
                ),
                child: busy
                    ? const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo_rounded,
                              color: AppTheme.primary500, size: 24),
                          const SizedBox(height: 4),
                          Text(s.addUpToTwoPhotos,
                              textAlign: TextAlign.center,
                              style: text.labelSmall
                                  ?.copyWith(color: AppTheme.primary600)),
                        ],
                      ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  Mic dictation bar
// ---------------------------------------------------------------------------

class _MicBar extends StatelessWidget {
  const _MicBar({
    required this.listening,
    required this.lang,
    required this.onTap,
  });

  final bool listening;
  final AppLanguage lang;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final s = S(lang);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: listening
              ? AppTheme.primary500
              : AppTheme.primary50,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(
            color: listening ? AppTheme.primary500 : AppTheme.primary100,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              listening ? Icons.stop_rounded : Icons.mic_rounded,
              size: 20,
              color: listening ? Colors.white : AppTheme.primary600,
            ),
            const SizedBox(width: 10),
            Text(
              listening ? s.listening : s.tapMicToSpeak,
              style: text.labelLarge?.copyWith(
                color: listening ? Colors.white : AppTheme.primary700,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
