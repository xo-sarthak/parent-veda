// =============================================================================
//  PpCreatePostScreen - the full parenting composer
// -----------------------------------------------------------------------------
//  The parenting mirror of the pregnancy CreatePostScreen: an "ask an expert to
//  verify" toggle (with a preferred-specialty picker), a text field with mic
//  dictation + an inline send, photo attachments (gallery + camera), a "post to"
//  picker (your feed, or a room you've joined), a post-type picker, and live
//  auto-suggested topic tags. In doctor test-mode the post is authored AS the
//  verified doctor. Reuses the shared CommunityStore + image_picker + the mic.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/community_data.dart';
import '../../localization/app_language.dart';
import '../../models/community_models.dart';
import '../../services/community_store.dart';
import '../../widgets/mic_dictation_button.dart';
import 'community_screen.dart';
import 'pp_common.dart';

class PpCreatePostScreen extends StatefulWidget {
  const PpCreatePostScreen({super.key, this.initialCommunityId});
  final String? initialCommunityId;
  @override
  State<PpCreatePostScreen> createState() => _PpCreatePostScreenState();
}

class _PpCreatePostScreenState extends State<PpCreatePostScreen> {
  final _textCtrl = TextEditingController();
  final _picker = ImagePicker();
  final List<String> _photos = [];
  String _communityId = '';
  PostType _type = PostType.question;
  List<String> _autoTags = const [];
  bool _wantVerify = false;
  String _specialty = 'all';

  @override
  void initState() {
    super.initState();
    final init = widget.initialCommunityId ?? '';
    _communityId = CommunityStore.instance.isJoined(init) ? init : '';
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  Future<void> _addFromGallery() async {
    final imgs = await _picker.pickMultiImage();
    if (imgs.isEmpty) return;
    setState(() {
      _photos.addAll(imgs.map((x) => x.path));
      if (_type == PostType.question) _type = PostType.photo;
    });
  }

  Future<void> _addFromCamera() async {
    final img = await _picker.pickImage(source: ImageSource.camera);
    if (img == null) return;
    setState(() {
      _photos.add(img.path);
      if (_type == PostType.question) _type = PostType.photo;
    });
  }

  void _share() {
    final t = _textCtrl.text.trim();
    if (t.isEmpty && _photos.isEmpty) return;
    final store = CommunityStore.instance;
    final asDoctor = store.doctorMode;
    store.addPost(CommunityPost(
      id: 'u${DateTime.now().millisecondsSinceEpoch}',
      communityId: _communityId,
      author: asDoctor ? kPpDoctorName : 'You',
      authorEmoji: '',
      text: t,
      type: _type,
      topics: inferTopics(t),
      stage: 'Parenting',
      imageUrls: List.of(_photos),
      isUser: true,
      cred: asDoctor ? kPpDoctorCred : '',
      wantsVerification: !asDoctor && _wantVerify,
      preferredSpecialty: (!asDoctor && _wantVerify) ? _specialty : '',
      createdAt: DateTime.now().millisecondsSinceEpoch,
    ));
    Navigator.of(context).pop();
    ppToast(context, asDoctor ? 'Posted as a verified doctor' : 'Posted');
  }

  @override
  Widget build(BuildContext context) {
    final store = CommunityStore.instance;
    final joined = ppJoinedCommunities();
    const types = [
      PostType.question,
      PostType.experience,
      PostType.milestone,
      PostType.photo,
    ];
    final canPost = _textCtrl.text.trim().isNotEmpty || _photos.isNotEmpty;
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: store,
          builder: (context, _) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
              children: [
                ppBack(context, 'New post'),
                const SizedBox(height: 16),
                Text('Share with your communities',
                    style: ppFraunces(26, w: FontWeight.w600)),
                const SizedBox(height: 16),
                if (store.doctorMode)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [ppPurple, Color(0xFF9B5DE0)]),
                        borderRadius: BorderRadius.circular(16)),
                    child: Row(children: [
                      const Icon(Icons.verified_rounded,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text('Posting as $kPpDoctorName · $kPpDoctorCred',
                            style: ppBody(13,
                                color: Colors.white, w: FontWeight.w700)),
                      ),
                    ]),
                  ),
                // ask an expert to verify (members only)
                if (!store.doctorMode) ...[
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                        color: ppPurple.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: ppPurple.withValues(alpha: 0.18))),
                    child: Row(children: [
                      const Icon(Icons.verified_outlined,
                          size: 20, color: ppPurple),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Ask an expert to verify',
                                  style: ppBody(14,
                                      color: ppInk, w: FontWeight.w800)),
                              Text('A verified doctor can confirm this by replying.',
                                  style: ppBody(12, color: ppSoft)),
                            ]),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => setState(() => _wantVerify = !_wantVerify),
                        behavior: HitTestBehavior.opaque,
                        child: ppSwitch(_wantVerify),
                      ),
                    ]),
                  ),
                  if (_wantVerify) ...[
                    const SizedBox(height: 12),
                    Text('Which expert should see it?',
                        style: ppBody(13.5, color: ppInk, w: FontWeight.w800)),
                    const SizedBox(height: 8),
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      for (final sp in kParentingVerifySpecialties)
                        _chip(ppSpecialtyLabel(sp), _specialty == sp,
                            () => setState(() => _specialty = sp)),
                    ]),
                  ],
                  const SizedBox(height: 18),
                ],
                // text field + mic + send
                Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: ppHair)),
                  padding: const EdgeInsets.fromLTRB(14, 6, 8, 8),
                  child: Column(children: [
                    TextField(
                      controller: _textCtrl,
                      minLines: 4,
                      maxLines: 10,
                      autofocus: true,
                      style: ppBody(15, color: ppInk, h: 1.5),
                      onChanged: (v) => setState(() => _autoTags = inferTopics(v)),
                      decoration: InputDecoration(
                        filled: false,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        border: InputBorder.none,
                        hintText:
                            'What is on your mind, or what would you ask another parent?',
                        hintStyle: ppBody(14, color: ppMuted),
                      ),
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          MicDictateButton(
                              controller: _textCtrl,
                              s: const S(AppLanguage.english),
                              color: ppPurple),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: canPost ? _share : null,
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              width: 40,
                              height: 40,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: canPost ? ppPurple : ppLine,
                                  shape: BoxShape.circle),
                              child: const Icon(Icons.arrow_upward_rounded,
                                  size: 20, color: Colors.white),
                            ),
                          ),
                        ]),
                  ]),
                ),
                const SizedBox(height: 16),
                // photos
                Row(children: [
                  _outlineBtn(Icons.photo_library_outlined, 'Photos',
                      _addFromGallery),
                  const SizedBox(width: 10),
                  _outlineBtn(
                      Icons.photo_camera_outlined, 'Camera', _addFromCamera),
                ]),
                if (_photos.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(spacing: 10, runSpacing: 10, children: [
                    for (var i = 0; i < _photos.length; i++)
                      Stack(clipBehavior: Clip.none, children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.file(File(_photos[i]),
                              width: 92,
                              height: 92,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                  width: 92,
                                  height: 92,
                                  color: ppPanel,
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.broken_image_outlined,
                                      color: ppMuted))),
                        ),
                        Positioned(
                          top: -7,
                          right: -7,
                          child: GestureDetector(
                            onTap: () => setState(() => _photos.removeAt(i)),
                            child: Container(
                              decoration: const BoxDecoration(
                                  color: ppInk, shape: BoxShape.circle),
                              padding: const EdgeInsets.all(3),
                              child: const Icon(Icons.close_rounded,
                                  size: 15, color: Colors.white),
                            ),
                          ),
                        ),
                      ]),
                  ]),
                ],
                const SizedBox(height: 18),
                // post to
                Text('Post to',
                    style: ppBody(13.5, color: ppInk, w: FontWeight.w800)),
                const SizedBox(height: 8),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  _chip('Your feed', _communityId == '',
                      () => setState(() => _communityId = '')),
                  for (final c in joined)
                    _chip(c.name, _communityId == c.id,
                        () => setState(() => _communityId = c.id)),
                ]),
                const SizedBox(height: 18),
                // post type
                Text('Type',
                    style: ppBody(13.5, color: ppInk, w: FontWeight.w800)),
                const SizedBox(height: 8),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  for (final t in types)
                    _chip(ppTypeLabel(t), _type == t,
                        () => setState(() => _type = t)),
                ]),
                if (_autoTags.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  Row(children: [
                    const Icon(Icons.auto_awesome_rounded,
                        size: 16, color: ppPurple),
                    const SizedBox(width: 6),
                    Text('Suggested tags',
                        style: ppBody(13.5, color: ppInk, w: FontWeight.w800)),
                  ]),
                  const SizedBox(height: 8),
                  Wrap(spacing: 6, runSpacing: 6, children: [
                    for (final tag in _autoTags)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                            color: ppPurple.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(20)),
                        child: Text('#${tag.replaceAll(' ', '')}',
                            style: ppBody(11.5, color: ppPurple, w: FontWeight.w700)),
                      ),
                  ]),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _chip(String label, bool active, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: active ? ppPurple : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: active ? ppPurple : ppBorder),
          ),
          child: Text(label,
              style: ppBody(13,
                  color: active ? Colors.white : ppInk,
                  w: active ? FontWeight.w700 : FontWeight.w600)),
        ),
      );

  Widget _outlineBtn(IconData icon, String label, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: ppPurple.withValues(alpha: 0.4))),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 18, color: ppPurple),
            const SizedBox(width: 8),
            Text(label, style: ppBody(13.5, color: ppPurple, w: FontWeight.w700)),
          ]),
        ),
      );
}
