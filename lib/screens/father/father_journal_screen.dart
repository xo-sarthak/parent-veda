// =============================================================================
//  FatherJournalScreen — the father's simple memory journal (Slate)
// -----------------------------------------------------------------------------
//  A deliberately small, less-cluttered cousin of the mother's My Journal: four
//  quick actions (Write a memory · Note for baby · Add photo · Record voice) and
//  a newest-first feed of what the father has saved. No filters, milestones,
//  health, scans or booklet. Stores into the SEPARATE FatherJournalStore and
//  reuses the mother's compose sheets via their `onAdd` hook.
// =============================================================================

import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/journal_entry.dart';
import '../../services/father_journal_store.dart';
import '../../services/pregnancy_controller.dart';
import '../../theme/father_skin.dart';
import '../../widgets/journal/journal_create.dart';

class FatherJournalScreen extends StatefulWidget {
  const FatherJournalScreen({super.key, required this.controller});
  final PregnancyController controller;

  @override
  State<FatherJournalScreen> createState() => _FatherJournalScreenState();
}

class _FatherJournalScreenState extends State<FatherJournalScreen> {
  final AudioPlayer _player = AudioPlayer();
  String? _playing;

  @override
  void initState() {
    super.initState();
    FatherJournalStore.instance.init();
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _playing = null);
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  TextStyle _serif(double s, {FontWeight w = FontWeight.w600, Color c = kFInk}) =>
      GoogleFonts.fraunces(fontSize: s, fontWeight: w, color: c, height: 1.2);
  TextStyle _body(double s,
          {FontWeight w = FontWeight.w400, Color c = kFInk, double h = 1.5}) =>
      GoogleFonts.plusJakartaSans(fontSize: s, fontWeight: w, color: c, height: h);

  void _add(Future<void> Function() open) {
    open();
  }

  Future<void> _togglePlay(String path) async {
    if (_playing == path) {
      await _player.stop();
      if (mounted) setState(() => _playing = null);
      return;
    }
    await _player.stop();
    await _player.play(DeviceFileSource(path));
    if (mounted) setState(() => _playing = path);
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    add(JournalEntry e) => FatherJournalStore.instance.addEntry(e);
    return Scaffold(
      backgroundColor: kFBg,
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          // header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 18, 6),
            child: Row(children: [
              GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: kFCard,
                    shape: BoxShape.circle,
                    border: Border.all(color: kFLine),
                  ),
                  child: const Icon(Icons.arrow_back_rounded,
                      color: kFInk, size: 20),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('YOUR MEMORIES',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.14 * 11,
                              color: kFMuted)),
                      const SizedBox(height: 2),
                      Text("Father's Journal", style: _serif(21)),
                    ]),
              ),
            ]),
          ),
          // quick actions
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
            child: Row(children: [
              _circle(Icons.edit_note_rounded, 'Memory',
                  () => _add(() => openJournalText(
                      context, c, JournalEntryType.memory,
                      onAdd: add, father: true))),
              _circle(Icons.favorite_rounded, 'For baby',
                  () => _add(() => openJournalText(
                      context, c, JournalEntryType.noteForBaby,
                      onAdd: add, father: true))),
              _circle(Icons.add_a_photo_rounded, 'Photo',
                  () => _add(() =>
                      openJournalAddPhoto(context, c, onAdd: add, father: true))),
              _circle(Icons.mic_none_rounded, 'Voice',
                  () => _add(() => openJournalRecordVoice(context, c,
                      onAdd: add, father: true))),
            ]),
          ),
          // feed
          Expanded(
            child: AnimatedBuilder(
              animation: FatherJournalStore.instance,
              builder: (context, _) {
                final entries = FatherJournalStore.instance.entries;
                if (entries.isEmpty) return _empty();
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
                  itemCount: entries.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _entryCard(entries[i]),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }

  Widget _circle(IconData icon, String label, VoidCallback onTap) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Column(children: [
            Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: kFAccentSoft,
                shape: BoxShape.circle,
                border: Border.all(color: kFLine),
              ),
              child: Icon(icon, color: kFAccent, size: 23),
            ),
            const SizedBox(height: 7),
            Text(label, style: _body(11.5, w: FontWeight.w600, c: kFMuted)),
          ]),
        ),
      );

  Widget _empty() => Center(
        child: Padding(
          padding: const EdgeInsets.all(36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                    color: kFAccentSoft, shape: BoxShape.circle),
                child: const Icon(Icons.auto_stories_rounded,
                    color: kFAccent, size: 30),
              ),
              const SizedBox(height: 16),
              Text('Start your journal', style: _serif(20)),
              const SizedBox(height: 8),
              Text(
                  'Write a memory, note something for your baby, add a photo or record your voice. It all stays here for you.',
                  textAlign: TextAlign.center,
                  style: _body(13.5, c: kFMuted)),
            ],
          ),
        ),
      );

  Widget _entryCard(JournalEntry e) {
    final images = e.images;
    final audios = e.audios;
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: kFCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kFLine),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(_iconFor(e.type), size: 17, color: kFAccent2),
          const SizedBox(width: 8),
          Expanded(
            child: Text(_dateLabel(e.date),
                style: _body(11.5, w: FontWeight.w700, c: kFMuted)),
          ),
          GestureDetector(
            onTap: () => FatherJournalStore.instance.deleteEntry(e.id),
            behavior: HitTestBehavior.opaque,
            child: const Icon(Icons.delete_outline_rounded,
                size: 18, color: kFMuted),
          ),
        ]),
        if (images.isNotEmpty) ...[
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.file(File(images.first),
                width: double.infinity,
                height: 190,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                    height: 190,
                    color: kFAccentSoft,
                    alignment: Alignment.center,
                    child: const Icon(Icons.broken_image_rounded,
                        color: kFMuted))),
          ),
        ],
        if (e.title.trim().isNotEmpty) ...[
          const SizedBox(height: 11),
          Text(e.title, style: _serif(17)),
        ],
        if (e.description.trim().isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(e.description, style: _body(14, c: kFInk, h: 1.5)),
        ],
        for (final path in audios) ...[
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => _togglePlay(path),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                  color: kFAccentSoft, borderRadius: BorderRadius.circular(14)),
              child: Row(children: [
                Icon(
                    _playing == path
                        ? Icons.stop_circle_rounded
                        : Icons.play_circle_rounded,
                    color: kFAccent,
                    size: 26),
                const SizedBox(width: 10),
                Text('Voice note', style: _body(13.5, w: FontWeight.w600)),
              ]),
            ),
          ),
        ],
      ]),
    );
  }

  IconData _iconFor(JournalEntryType t) {
    switch (t) {
      case JournalEntryType.noteForBaby:
        return Icons.favorite_rounded;
      case JournalEntryType.photo:
        return Icons.photo_rounded;
      case JournalEntryType.voice:
        return Icons.mic_rounded;
      default:
        return Icons.edit_note_rounded;
    }
  }

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  String _dateLabel(DateTime d) {
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final m = d.minute.toString().padLeft(2, '0');
    final ap = d.hour < 12 ? 'AM' : 'PM';
    return '${d.day} ${_months[d.month - 1]} ${d.year} · $h:$m $ap';
  }
}
