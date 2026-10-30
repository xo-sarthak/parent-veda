// Search: route 'community/search', from the search icon on the community
// home (0137, plan decision 16). Postgres full text over live posts' title
// and body, plus rooms and #tags whose names match, all from one server call
// (`community_search`), so what she can find is exactly what she may read.
//
// Recent searches are kept on the phone only: a search is a private thought,
// and the server has no reason to remember it.
import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/pv_community.dart';
import '../../services/pv_community_store.dart';
import '../../services/saved_store.dart';
import '../products/pv_store_chrome.dart' show kPvInk;
import 'community_chrome.dart';
import 'community_marks.dart';

class CommunitySearchScreen extends StatefulWidget {
  const CommunitySearchScreen({super.key});

  @override
  State<CommunitySearchScreen> createState() => _CommunitySearchScreenState();
}

class _CommunitySearchScreenState extends State<CommunitySearchScreen> {
  final _store = PvCommunityStore.instance;
  final _q = TextEditingController();
  Timer? _debounce;
  List<String> _recent = const [];
  PvCommunitySearch? _result;
  String _asked = '';
  bool _loading = false;
  bool _offline = false;

  @override
  void initState() {
    super.initState();
    _store.recentSearches().then((r) {
      if (mounted) setState(() => _recent = r);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _q.dispose();
    super.dispose();
  }

  void _changed(String v) {
    _debounce?.cancel();
    setState(() {});
    if (v.trim().length < 2) {
      setState(() => _result = null);
      return;
    }
    // Wait for a pause in her typing, so each letter is not a server call.
    _debounce = Timer(const Duration(milliseconds: 350), () => _run(v));
  }

  Future<void> _run(String q, {bool remember = false}) async {
    final t = q.trim();
    if (t.length < 2) return;
    setState(() {
      _loading = true;
      _asked = t;
    });
    final r = await _store.search(t);
    if (!mounted || _asked != t) return;
    setState(() {
      _loading = false;
      _offline = r == null && _store.signedIn;
      _result = r;
    });
    if (remember) {
      await _store.rememberSearch(t);
      final next = await _store.recentSearches();
      if (mounted) setState(() => _recent = next);
    }
  }

  void _pick(String q) {
    _q.text = q;
    _q.selection = TextSelection.collapsed(offset: q.length);
    _run(q, remember: true);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_store, SavedStore.instance]),
      builder: (context, _) => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          titleSpacing: 0,
          leading: IconButton(
            tooltip: 'Back',
            icon: const Icon(Icons.arrow_back_rounded, color: kPvInk),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: TextField(
            key: const ValueKey('community_search_field'),
            controller: _q,
            autofocus: true,
            textInputAction: TextInputAction.search,
            onChanged: _changed,
            onSubmitted: (v) => _run(v, remember: true),
            style: cmText(16),
            decoration: InputDecoration(
              hintText: 'Search posts, rooms, #tags',
              hintStyle: cmText(16, color: cmP.ink3),
              border: InputBorder.none,
            ),
          ),
          actions: [
            if (_q.text.isNotEmpty)
              IconButton(
                tooltip: 'Clear search',
                icon: const Icon(Icons.close_rounded, color: kPvInk),
                onPressed: () {
                  _q.clear();
                  setState(() => _result = null);
                },
              ),
          ],
        ),
        body: ListView(children: _body()),
      ),
    );
  }

  List<Widget> _body() {
    if (!_store.signedIn) {
      return [
        CommunityEmpty(
          icon: Icons.lock_outline_rounded,
          title: 'Sign in to search the community',
          body: 'Search reads the same moderated rooms you can open.',
          action: 'Sign in',
          onAction: () => openCommunitySignIn(context),
        ),
      ];
    }
    if (_q.text.trim().length < 2) {
      return [
        if (_recent.isEmpty)
          const CommunityEmpty(
            icon: Icons.search_rounded,
            title: 'Search what parents have asked',
            body: 'Try a worry in your own words, like "sleep regression" or "spotting at 6 weeks", or a #tag.',
          )
        else ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text('Recent', style: cmText(15, weight: FontWeight.w800)),
                ),
                TextButton(
                  onPressed: () async {
                    await _store.clearRecentSearches();
                    if (mounted) setState(() => _recent = const []);
                  },
                  style: TextButton.styleFrom(foregroundColor: kPvInk),
                  child: const Text('Clear'),
                ),
              ],
            ),
          ),
          for (final r in _recent) CommunitySheetRow(icon: Icons.history_rounded, label: r, onTap: () => _pick(r)),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Text('Kept on your phone only.', style: cmText(12.5, color: cmP.ink3)),
          ),
        ],
      ];
    }
    final r = _result;
    if (r == null) {
      return [
        if (_offline)
          const Padding(
            padding: EdgeInsets.all(16),
            child: CommunityStatusLine(
              icon: Icons.cloud_off_outlined,
              text: 'Search needs a connection. Try again when you are online.',
            ),
          )
        else if (_loading)
          const Padding(
            padding: EdgeInsets.all(40),
            child: Center(child: CircularProgressIndicator(color: kPvInk, strokeWidth: 2)),
          ),
      ];
    }
    if (r.isEmpty) {
      return [
        CommunityEmpty(
          icon: Icons.search_off_rounded,
          title: 'Nothing found for "$_asked"',
          body: 'Try fewer or different words. Or ask it: parents at your stage will see your post.',
          action: 'Write a post',
          onAction: () => openCommunityCompose(context),
        ),
      ];
    }
    return [
      if (r.tags.isNotEmpty)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in r.tags)
                CommunityPill(label: '#$t', selected: false, onTap: () => openCommunityTag(context, t)),
            ],
          ),
        ),
      for (final room in r.rooms)
        InkWell(
          onTap: () => openCommunityRoom(context, room.id),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                CommunityRoomMark(mark: room.mark, hue: room.hue, size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(room.title, style: cmText(15, weight: FontWeight.w700)),
                ),
                Text('Room', style: cmText(12.5, color: cmP.ink3)),
              ],
            ),
          ),
        ),
      if (r.posts.isEmpty)
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text('No posts mention "$_asked" yet.', style: cmText(14, color: cmP.ink2)),
        ),
      for (final p in r.posts) CommunityPostCard(post: _store.post(p.id) ?? p, showJoin: false),
      const SizedBox(height: 40),
    ];
  }
}
