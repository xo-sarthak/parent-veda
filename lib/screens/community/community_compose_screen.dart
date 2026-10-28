// Writing a post: route 'community/compose', opened as a full-screen dialog
// (it rises from the bottom). Reddit's create-post order: the room first, then
// who she posts as, then the words. POST is top right (see the note at the
// top of community_chrome.dart for why). Returns the new post's id.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../models/pv_community.dart';
import '../../services/community_safety.dart';
import '../../services/pv_community_store.dart';
import '../../theme/pv_motion.dart';
import '../../widgets/pv_toast.dart';
import '../products/pv_store_chrome.dart' show kPvInk;
import 'community_chrome.dart';
import 'community_marks.dart';

class CommunityComposeScreen extends StatefulWidget {
  const CommunityComposeScreen({super.key, this.roomId});
  final String? roomId;

  @override
  State<CommunityComposeScreen> createState() => _CommunityComposeScreenState();
}

class _CommunityComposeScreenState extends State<CommunityComposeScreen> {
  final _store = PvCommunityStore.instance;
  final _title = TextEditingController();
  final _body = TextEditingController();
  final _titleFocus = FocusNode();
  late String? _room = widget.roomId;

  /// Her community name by default (user's call, 2026-10-28): most first
  /// posts are the hard ones, and the safe default is the private one.
  bool _anon = true;
  bool _poll = false;
  int _pollDays = 3;
  final List<TextEditingController> _opts = [TextEditingController(), TextEditingController()];
  final List<String> _photos = [];
  bool _posting = false;

  @override
  void initState() {
    super.initState();
    for (final c in [_title, _body]) {
      c.addListener(() => setState(() {}));
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_room == null) {
        final picked = await pickCommunityRoom(context);
        if (!mounted) return;
        if (picked != null) setState(() => _room = picked);
      }
      _titleFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    for (final c in [_title, _body, ..._opts]) {
      c.dispose();
    }
    _titleFocus.dispose();
    super.dispose();
  }

  bool get _dirty => _title.text.trim().isNotEmpty || _body.text.trim().isNotEmpty || _photos.isNotEmpty;

  List<String> get _pollOptions => [for (final c in _opts) if (c.text.trim().isNotEmpty) c.text.trim()];

  String? get _blocker {
    if (_room == null) return 'Choose a room';
    if (_title.text.trim().length < 4) return 'Add a title';
    if (_poll && _pollOptions.length < 2) return 'Add two poll options';
    return null;
  }

  Future<bool> _confirmDiscard() async {
    if (!_dirty) return true;
    return confirmCommunity(
      context,
      title: 'Discard this post?',
      body: 'What you wrote will not be kept.',
      confirm: 'Discard',
    );
  }

  Future<void> _pickPhotos() async {
    final left = 4 - _photos.length;
    if (left <= 0) {
      pvToast(context, 'Up to 4 photos on a post.', kind: PvToastKind.info);
      return;
    }
    try {
      final picked = await ImagePicker().pickMultiImage(maxWidth: 1600, imageQuality: 85, limit: left);
      if (picked.isEmpty) return;
      // Copied into the app's own folder: the picker's cache can be cleared
      // before a post queued offline is sent.
      final dir = await getApplicationDocumentsDirectory();
      final out = Directory('${dir.path}/community_outbox');
      if (!out.existsSync()) out.createSync(recursive: true);
      final kept = <String>[];
      for (final x in picked.take(left)) {
        final f = File('${out.path}/${PvCommunityStore.newId()}.jpg');
        await f.writeAsBytes(await x.readAsBytes());
        kept.add(f.path);
      }
      if (mounted) setState(() => _photos.addAll(kept));
    } catch (_) {
      if (mounted) {
        pvToast(context, 'Could not open your photos. Check the app has permission in Settings.',
            kind: PvToastKind.gentle);
      }
    }
  }

  Future<void> _post() async {
    if (_blocker != null || _posting) return;
    if (!_anon && (_store.me.firstName ?? '').isEmpty) {
      communityOutcomeToast(context, PvCommunityOutcome.noName);
      return;
    }
    setState(() => _posting = true);
    HapticFeedback.mediumImpact();
    final text = '${_title.text} ${_body.text}';
    final o = await _store.createPost(
      roomId: _room!,
      anon: _anon,
      title: _title.text,
      body: _body.text,
      pollOptions: _poll ? _pollOptions : null,
      pollDays: _pollDays,
      photoFiles: _photos,
    );
    if (!mounted) return;
    setState(() => _posting = false);
    final kept = o == PvCommunityOutcome.live || o == PvCommunityOutcome.held || o == PvCommunityOutcome.queued;
    communityOutcomeToast(
      context,
      o,
      room: _store.room(_room!)?.title,
      photos: _photos.isNotEmpty,
      crisis: o == PvCommunityOutcome.live && communityLooksLikeCrisis(text),
    );
    if (kept) {
      final id = _store.feed(PvCommunityStore.feedKey(scope: 'mine', sort: 'new')).firstOrNull?.id;
      Navigator.of(context).pop(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final room = _room == null ? null : _store.room(_room!);
    final text = '${_title.text} ${_body.text} ${_pollOptions.join(' ')}';
    final crisis = communityLooksLikeCrisis(text);
    final hold = communityHoldReason(text);
    final me = _store.me;
    final noName = (me.firstName ?? '').isEmpty;
    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmDiscard() && context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            tooltip: 'Close',
            icon: const Icon(Icons.close_rounded, color: kPvInk),
            onPressed: () async {
              if (await _confirmDiscard() && context.mounted) Navigator.of(context).pop();
            },
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: Tooltip(
                  message: _blocker ?? 'Post',
                  child: CommunityInkButton(
                    label: 'Post',
                    compact: true,
                    busy: _posting,
                    onTap: _blocker == null ? _post : null,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Column(children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: () async {
                      final r = await pickCommunityRoom(context, current: _room);
                      if (r != null && mounted) setState(() => _room = r);
                    },
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(5, 5, 12, 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: room == null ? kPvInk : cmP.line, width: room == null ? 1.4 : 1),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        if (room != null)
                          CommunityRoomMark(mark: room.mark, hue: room.hue, size: 28)
                        else
                          const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(Icons.forum_outlined, size: 20, color: kPvInk),
                          ),
                        const SizedBox(width: 8),
                        Text(room?.title ?? 'Choose a room', style: cmText(13.5, weight: FontWeight.w700)),
                        const SizedBox(width: 4),
                        const Icon(Icons.expand_more_rounded, size: 18, color: kPvInk),
                      ]),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(
                    child: _FaceChoice(
                      author: _store.myFace(anon: true),
                      caption: 'Community name',
                      selected: _anon,
                      onTap: () => setState(() => _anon = true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _FaceChoice(
                      author: _store.myFace(anon: false),
                      caption: noName ? 'Add your name in You' : 'Your name',
                      selected: !_anon,
                      onTap: noName
                          ? () => communityOutcomeToast(context, PvCommunityOutcome.noName)
                          : () => setState(() => _anon = false),
                    ),
                  ),
                ]),
                const SizedBox(height: 8),
                AnimatedSwitcher(
                  duration: PvMotion.swap,
                  child: CommunityStatusLine(
                    key: ValueKey(_anon),
                    icon: _anon ? Icons.lock_outline_rounded : Icons.person_outline_rounded,
                    text: _anon
                        ? 'Others see ${me.pseudonym ?? 'your community name'}. Your name and account stay private.'
                        : 'Others see ${me.firstName ?? 'your first name'}.',
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _title,
                  focusNode: _titleFocus,
                  maxLength: 160,
                  minLines: 1,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  style: cmTitle(24),
                  decoration: InputDecoration(
                    hintText: 'Your question or title',
                    hintStyle: cmTitle(24, color: const Color(0xFFB4AFB9)),
                    border: InputBorder.none,
                    counterText: '',
                  ),
                ),
                TextField(
                  controller: _body,
                  maxLength: 4000,
                  minLines: 4,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  style: cmText(15.5, height: 1.55),
                  decoration: InputDecoration(
                    hintText: 'Add details (optional)',
                    hintStyle: cmText(15.5, color: const Color(0xFFB4AFB9)),
                    border: InputBorder.none,
                    counterText: '',
                  ),
                ),
                // Shown while she types, not after she posts.
                AnimatedSize(
                  duration: PvMotion.resize,
                  curve: PvMotion.arrive,
                  child: crisis
                      ? const Padding(padding: EdgeInsets.only(top: 8), child: CommunityHelplines())
                      : const SizedBox(width: double.infinity),
                ),
                AnimatedSize(
                  duration: PvMotion.resize,
                  child: hold == null || crisis
                      ? const SizedBox(width: double.infinity)
                      : Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: CommunityStatusLine(
                            icon: Icons.info_outline_rounded,
                            text: switch (hold) {
                              'link' => 'Posts with links wait for a quick review before others see them.',
                              'phone' => 'Posts with phone numbers wait for a quick review, to keep everyone safe.',
                              _ => 'Some words here mean this post will wait for a quick review.',
                            },
                          ),
                        ),
                ),
                if (_photos.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    for (var i = 0; i < _photos.length; i++)
                      Stack(children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(File(_photos[i]), width: 82, height: 82, fit: BoxFit.cover, cacheWidth: 240),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: InkWell(
                            onTap: () => setState(() => _photos.removeAt(i)),
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                              child: const Icon(Icons.close_rounded, size: 15, color: Colors.white),
                            ),
                          ),
                        ),
                      ]),
                  ]),
                  const SizedBox(height: 8),
                  const CommunityStatusLine(
                    text: 'Your post goes live now. Photos show to others after a quick review.',
                  ),
                ],
                AnimatedSize(
                  duration: PvMotion.resize,
                  curve: PvMotion.arrive,
                  child: !_poll ? const SizedBox(width: double.infinity) : _pollEditor(),
                ),
              ],
            ),
          ),
          Material(
            color: Colors.white,
            child: SafeArea(
              top: false,
              child: Container(
                decoration: BoxDecoration(border: Border(top: BorderSide(color: cmP.line))),
                padding: const EdgeInsets.fromLTRB(6, 4, 14, 4),
                child: Row(children: [
                  TextButton.icon(
                    onPressed: _photos.length >= 4 ? null : _pickPhotos,
                    icon: const Icon(Icons.image_outlined, size: 20),
                    label: Text(_photos.isEmpty ? 'Photo' : 'Photo ${_photos.length}/4'),
                    style: TextButton.styleFrom(foregroundColor: kPvInk, textStyle: cmText(14, weight: FontWeight.w700)),
                  ),
                  TextButton.icon(
                    onPressed: _poll ? null : () => setState(() => _poll = true),
                    icon: const Icon(Icons.poll_outlined, size: 20),
                    label: const Text('Poll'),
                    style: TextButton.styleFrom(foregroundColor: kPvInk, textStyle: cmText(14, weight: FontWeight.w700)),
                  ),
                  const Spacer(),
                  Text(
                    _blocker ?? '${_body.text.length}/4000',
                    style: cmText(12, color: cmP.ink3),
                  ),
                ]),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _pollEditor() => Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 6, 6, 12),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: cmP.line)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              Expanded(child: Text('Poll', style: cmText(15, weight: FontWeight.w800))),
              IconButton(
                tooltip: 'Remove poll',
                icon: const Icon(Icons.close_rounded, size: 20),
                onPressed: () => setState(() {
                  _poll = false;
                  for (final c in _opts) {
                    c.clear();
                  }
                }),
              ),
            ]),
            for (var i = 0; i < _opts.length; i++)
              Padding(
                padding: const EdgeInsets.only(right: 6, bottom: 8),
                child: TextField(
                  controller: _opts[i],
                  maxLength: 60,
                  onChanged: (_) => setState(() {}),
                  style: cmText(14.5),
                  decoration: InputDecoration(
                    counterText: '',
                    isDense: true,
                    hintText: 'Option ${i + 1}',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: cmP.line)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kPvInk)),
                  ),
                ),
              ),
            Row(children: [
              if (_opts.length < 4)
                TextButton.icon(
                  onPressed: () => setState(() => _opts.add(TextEditingController())),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add option'),
                  style: TextButton.styleFrom(foregroundColor: kPvInk, textStyle: cmText(13.5, weight: FontWeight.w700)),
                ),
              const Spacer(),
              Text('Runs for', style: cmText(13, color: cmP.ink2)),
              const SizedBox(width: 6),
              DropdownButton<int>(
                value: _pollDays,
                underline: const SizedBox.shrink(),
                style: cmText(13.5, weight: FontWeight.w800),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('1 day')),
                  DropdownMenuItem(value: 3, child: Text('3 days')),
                  DropdownMenuItem(value: 7, child: Text('7 days')),
                ],
                onChanged: (v) => setState(() => _pollDays = v ?? 3),
              ),
            ]),
          ]),
        ),
      );
}

class _FaceChoice extends StatelessWidget {
  const _FaceChoice({required this.author, required this.caption, required this.selected, required this.onTap});
  final PvCommunityAuthor author;
  final String caption;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        selected: selected,
        button: true,
        label: 'Post as ${author.label}, $caption',
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          child: AnimatedContainer(
            duration: PvMotion.swap,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: selected ? const Color(0xFFFAFAFA) : Colors.white,
              border: Border.all(color: selected ? kPvInk : cmP.line, width: selected ? 1.5 : 1),
            ),
            child: Row(children: [
              CommunityFaceMark(author: author, size: 32),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(author.label, maxLines: 1, overflow: TextOverflow.ellipsis, style: cmText(13.5, weight: FontWeight.w800)),
                  Text(caption, maxLines: 1, overflow: TextOverflow.ellipsis, style: cmText(11.5, color: cmP.ink3)),
                ]),
              ),
            ]),
          ),
        ),
      );
}
