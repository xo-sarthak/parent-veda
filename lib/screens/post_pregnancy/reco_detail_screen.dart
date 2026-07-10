// =============================================================================
//  RecoDetailScreen - one recommendation, in full
// -----------------------------------------------------------------------------
//  Every recommendation deserves a beautiful page. The star is the ParentVeda
//  take: WHY we recommend it, and what to CONSIDER - balanced, never
//  promotional. Plus age suitability, skills supported, development benefits,
//  best-for, both ratings, cross-links into the rest of the app, and Ask-Veda
//  prompts. Opening it marks it viewed (feeding "Continue exploring").
// =============================================================================

import 'package:flutter/material.dart';

import 'development_activity_screen.dart';
import 'pp_child_profile.dart';
import 'pp_common.dart';
import 'pp_development_data.dart';
import 'pp_products_data.dart';
import 'pp_reading_data.dart';
import 'pp_reco_data.dart';
import 'pp_watch_data.dart';
import 'product_detail_screen.dart';
import 'reading_reader_screen.dart';
import 'reco_common.dart';
import 'watch_player_screen.dart';
import 'watch_quicklearn_screen.dart';

class RecoDetailScreen extends StatefulWidget {
  const RecoDetailScreen({super.key, required this.item});
  final RecoItem item;

  @override
  State<RecoDetailScreen> createState() => _RecoDetailScreenState();
}

class _RecoDetailScreenState extends State<RecoDetailScreen> {
  RecoItem get it => widget.item;

  String get _ageLabel {
    final m = ChildProfileStore.instance.ageInMonths;
    return m >= 12 ? '${(m / 12).floor()}-year' : '$m-month';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => RecoStore.instance.markViewed(it.id));
  }

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);
  void _push(Widget s) => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => s));

  @override
  Widget build(BuildContext context) {
    final related = relatedReco(it);
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: Stack(children: [
          ListView(
            padding: const EdgeInsets.only(top: 12, bottom: 108),
            children: [
              _pad(ppBack(context, it.category)),

              // hero
              const SizedBox(height: 16),
              _pad(RecoThumb(item: it, height: 210, radius: 22)),
              const SizedBox(height: 16),
              _pad(Row(children: [
                recoAgePill('Ages ${it.ageLabel}'),
                const SizedBox(width: 10),
                recoRating(it.pvRating),
                const SizedBox(width: 12),
                Expanded(child: Text('${it.communityLoves} saved', textAlign: TextAlign.right, style: ppBody(11.5, color: ppMuted), maxLines: 1, overflow: TextOverflow.ellipsis)),
              ])),
              const SizedBox(height: 12),
              _pad(Text(it.title, style: ppFraunces(28, h: 1.14))),
              const SizedBox(height: 10),
              _pad(Text(it.summary, style: ppBody(15, color: ppInk, h: 1.55))),

              // the differentiator - Why we recommend it
              const SizedBox(height: 20),
              _pad(Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFF6F1FC), Color(0xFFF3ECF8)]),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    const Icon(Icons.auto_awesome, size: 16, color: ppPurple),
                    const SizedBox(width: 8),
                    Expanded(child: ppEyebrow('Why ParentVeda recommends it', color: ppPurple, spacing: 0.6)),
                  ]),
                  const SizedBox(height: 10),
                  Text(it.why, style: ppBody(14.5, color: ppInk, h: 1.65)),
                ]),
              )),

              // Things to consider - balanced
              const SizedBox(height: 14),
              _pad(Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(16)),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(Icons.info_outline_rounded, size: 17, color: ppBrown),
                  const SizedBox(width: 11),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('THINGS TO CONSIDER', style: ppBody(10, color: ppBrown, w: FontWeight.w800).copyWith(letterSpacing: 0.6)),
                    const SizedBox(height: 5),
                    Text(it.consider, style: ppBody(13.5, color: ppInk, h: 1.55)),
                  ])),
                ]),
              )),

              // best for
              const SizedBox(height: 14),
              _pad(Row(children: [
                const Icon(Icons.check_circle_outline_rounded, size: 17, color: ppPurple),
                const SizedBox(width: 10),
                Expanded(child: Text.rich(TextSpan(children: [
                  TextSpan(text: 'Best for: ', style: ppBody(13.5, color: ppInk, w: FontWeight.w800)),
                  TextSpan(text: it.bestFor, style: ppBody(13.5, color: ppInk)),
                ]), style: ppBody(13.5, h: 1.5))),
              ])),

              // skills + benefits
              if (it.skills.isNotEmpty) ...[
                _pad(ppSectionDivider()),
                _pad(Text('Skills it supports', style: ppJakarta(16))),
                const SizedBox(height: 12),
                _pad(Wrap(spacing: 8, runSpacing: 8, children: [for (final s in it.skills) _chip(s, Icons.psychology_outlined)])),
              ],
              if (it.benefits.isNotEmpty) ...[
                const SizedBox(height: 16),
                _pad(Text('Development benefits', style: ppJakarta(16))),
                const SizedBox(height: 12),
                _pad(Wrap(spacing: 8, runSpacing: 8, children: [for (final b in it.benefits) _chip(b, Icons.spa_outlined)])),
              ],

              // ratings
              _pad(ppSectionDivider()),
              _pad(Row(children: [
                Expanded(child: _ratingCard('ParentVeda', it.pvRating.toStringAsFixed(1), 'Editorially reviewed')),
                const SizedBox(width: 12),
                Expanded(child: _ratingCard('Community', _communityScore(), '${it.communityLoves} parents')),
              ])),

              // cross-links into the app
              if (_hasLinks) ...[
                _pad(ppSectionDivider()),
                _pad(Text('Go deeper', style: ppJakarta(16))),
                const SizedBox(height: 12),
                ..._linkRows(),
              ],

              // related recommendations
              if (related.isNotEmpty) ...[
                _pad(ppSectionDivider()),
                _pad(Text('You might also like', style: ppJakarta(16))),
                const SizedBox(height: 14),
                SizedBox(
                  height: 268,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: related.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 14),
                    itemBuilder: (_, i) => RecoRailCard(item: related[i], onTap: () => _push(RecoDetailScreen(item: related[i]))),
                  ),
                ),
              ],

              // ask veda
              _pad(ppSectionDivider()),
              _pad(Text('Ask Veda about this', style: ppJakarta(16))),
              const SizedBox(height: 12),
              _pad(Column(children: [
                _askRow('Is ${it.title} right for a $_ageLabel old?'),
                _askRow('How do I get the most out of this?'),
              ])),
              const SizedBox(height: 12),
              _pad(Text('Curated by ParentVeda editors - balanced, evidence-first, never sponsored.',
                  textAlign: TextAlign.center, style: ppBody(12, color: ppMuted, h: 1.5))),
            ],
          ),

          // sticky Save + Add to list
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 22),
              decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x00FBF9FE), ppBg], stops: [0, 0.28])),
              child: AnimatedBuilder(
                animation: RecoStore.instance,
                builder: (context, _) {
                  final saved = RecoStore.instance.isSaved(it.id);
                  return Row(children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => RecoStore.instance.toggleSave(it.id),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          height: 52,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: saved ? ppPurple : Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: saved ? ppPurple : ppLine)),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(saved ? Icons.favorite : Icons.favorite_border, size: 18, color: saved ? Colors.white : ppPurple),
                            const SizedBox(width: 8),
                            Text(saved ? 'Saved' : 'Save', style: ppBody(14, color: saved ? Colors.white : ppPurple, w: FontWeight.w700)),
                          ]),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: _addToListSheet,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          height: 52,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: ppPurple, borderRadius: BorderRadius.circular(15), boxShadow: const [BoxShadow(color: Color(0x8C6A30B6), blurRadius: 24, spreadRadius: -10, offset: Offset(0, 10))]),
                          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            const Icon(Icons.playlist_add_rounded, size: 19, color: Colors.white),
                            const SizedBox(width: 8),
                            Flexible(child: Text('Add to list', maxLines: 1, overflow: TextOverflow.ellipsis, style: ppBody(14, color: Colors.white, w: FontWeight.w700))),
                          ]),
                        ),
                      ),
                    ),
                  ]);
                },
              ),
            ),
          ),
        ]),
      ),
    );
  }

  bool get _hasLinks => it.relatedArticleId != null || it.relatedVideoId != null || it.relatedActivityId != null || it.relatedProductId != null;

  List<Widget> _linkRows() {
    final rows = <Widget>[];
    if (it.relatedArticleId != null) {
      final a = readArticleById(it.relatedArticleId!);
      rows.add(_linkRow(Icons.menu_book_outlined, 'Read', a.title, () => _push(ReadingReaderScreen(article: a))));
    }
    if (it.relatedVideoId != null) {
      final v = watchVideoById(it.relatedVideoId!);
      rows.add(_linkRow(Icons.play_circle_outline, 'Watch', v.title, () => _push(v.quick ? QuickLearnScreen(startId: v.id) : WatchPlayerScreen(video: v))));
    }
    if (it.relatedActivityId != null) {
      final act = devActivityById(it.relatedActivityId!);
      rows.add(_linkRow(Icons.extension_outlined, 'Try', act.title, () => _push(DevelopmentActivityScreen(activity: act))));
    }
    if (it.relatedProductId != null) {
      final p = productById(it.relatedProductId!);
      rows.add(_linkRow(Icons.shopping_bag_outlined, 'Shop', p.name, () => _push(ProductDetailScreen(product: p))));
    }
    return rows;
  }

  Widget _linkRow(IconData icon, String tag, String title, VoidCallback onTap) => _pad(GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: ppHair)),
          child: Row(children: [
            Container(width: 38, height: 38, alignment: Alignment.center, decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(11)), child: Icon(icon, size: 18, color: ppPurple)),
            const SizedBox(width: 13),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(tag.toUpperCase(), style: ppBody(9.5, color: ppMuted, w: FontWeight.w800).copyWith(letterSpacing: 0.6)),
              const SizedBox(height: 2),
              Text(title, style: ppBody(13.5, color: ppInk, w: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
            ])),
            const Icon(Icons.chevron_right_rounded, size: 20, color: ppMuted),
          ]),
        ),
      ));

  Widget _chip(String label, IconData icon) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(999)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14, color: ppPurple),
          const SizedBox(width: 6),
          Text(label, style: ppBody(12.5, color: ppInk, w: FontWeight.w600)),
        ]),
      );

  Widget _ratingCard(String label, String value, String sub) => Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: ppHair)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label.toUpperCase(), style: ppBody(9.5, color: ppMuted, w: FontWeight.w700).copyWith(letterSpacing: 0.6)),
          const SizedBox(height: 6),
          Row(children: [const Icon(Icons.star_rounded, size: 18, color: ppCoral), const SizedBox(width: 4), Text(value, style: ppJakarta(19))]),
          const SizedBox(height: 3),
          Text(sub, style: ppBody(11, color: ppMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
        ]),
      );

  Widget _askRow(String q) => GestureDetector(
        onTap: () => openPpTab(context, 1),
        behavior: HitTestBehavior.opaque,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(14)),
          child: Row(children: [
            const Icon(Icons.auto_awesome_outlined, size: 17, color: ppPurple),
            const SizedBox(width: 11),
            Expanded(child: Text(q, style: ppBody(13, color: ppInk, h: 1.4))),
            const Icon(Icons.chevron_right_rounded, size: 18, color: ppMuted),
          ]),
        ),
      );

  String _communityScore() {
    // a soft 4.x score derived from saves, so the community card isn't empty
    final s = 4.0 + (it.communityLoves / 4000).clamp(0.0, 0.9);
    return s.toStringAsFixed(1);
  }

  void _addToListSheet() {
    final store = RecoStore.instance;
    final ctl = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: ppBg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: SafeArea(
          top: false,
          child: AnimatedBuilder(
            animation: store,
            builder: (ctx, _) => SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Center(child: Container(width: 38, height: 4, decoration: BoxDecoration(color: ppLine, borderRadius: BorderRadius.circular(999)))),
                const SizedBox(height: 16),
                Text('Add to a list', style: ppJakarta(18)),
                const SizedBox(height: 14),
                for (final name in store.listNames)
                  GestureDetector(
                    onTap: () => store.toggleInList(name, it.id),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: ppHair)),
                      child: Row(children: [
                        Icon(store.isInList(name, it.id) ? Icons.check_circle_rounded : Icons.circle_outlined, size: 20, color: store.isInList(name, it.id) ? ppPurple : ppMuted),
                        const SizedBox(width: 13),
                        Expanded(child: Text(name, style: ppBody(14, color: ppInk, w: FontWeight.w600))),
                        Text('${store.listCount(name)}', style: ppBody(12, color: ppMuted)),
                      ]),
                    ),
                  ),
                const SizedBox(height: 6),
                Row(children: [
                  Expanded(child: Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: ppHair)),
                    child: TextField(
                      controller: ctl,
                      style: ppBody(14, color: ppInk, w: FontWeight.w600),
                      decoration: const InputDecoration(filled: false, isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 13), border: InputBorder.none, hintText: 'New list…'),
                    ),
                  )),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      if (ctl.text.trim().isNotEmpty) {
                        store.createList(ctl.text);
                        store.toggleInList(ctl.text.trim(), it.id);
                        ctl.clear();
                      }
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      height: 46,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: ppPurple, borderRadius: BorderRadius.circular(12)),
                      child: Text('Create', style: ppBody(13.5, color: Colors.white, w: FontWeight.w700)),
                    ),
                  ),
                ]),
              ]),
            ),
          ),
        ),
      ),
    ).whenComplete(ctl.dispose);
  }
}
