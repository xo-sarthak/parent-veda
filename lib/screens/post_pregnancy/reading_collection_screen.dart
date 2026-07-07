// =============================================================================
//  ReadingCollectionScreen — a learning collection (a finishable path)
// -----------------------------------------------------------------------------
//  Cover, count, estimated reading time, progress, then the ordered reads with
//  completed ticks. Reached from the Reading home's collections.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';
import 'pp_reading_data.dart';
import 'reading_common.dart';
import 'reading_reader_screen.dart';

class ReadingCollectionScreen extends StatelessWidget {
  const ReadingCollectionScreen({super.key, required this.collection});
  final ReadCollection collection;

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  @override
  Widget build(BuildContext context) {
    final reads = collection.articleIds.map(readArticleById).toList();
    final mins = reads.fold<int>(0, (a, r) => a + r.minutes);
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: ReadingStore.instance,
          builder: (context, _) {
            final prog = ReadingStore.instance.collectionProgress(collection);
            return ListView(
              padding: const EdgeInsets.only(top: 12, bottom: 40),
              children: [
                _pad(ppBack(context, 'Learn')),
                const SizedBox(height: 16),
                _pad(ReadCover(seed: collection.seed, height: 168, progress: prog > 0 ? prog : null)),
                const SizedBox(height: 16),
                _pad(Row(children: [
                  Icon(collection.icon, size: 18, color: ppPurple),
                  const SizedBox(width: 8),
                  ppEyebrow('Collection', color: ppPurple, spacing: 1.0),
                ])),
                const SizedBox(height: 10),
                _pad(Text(collection.title, style: ppFraunces(28, h: 1.12))),
                const SizedBox(height: 8),
                _pad(Text(collection.subtitle, style: ppBody(14, h: 1.55))),
                const SizedBox(height: 12),
                _pad(Text('${reads.length} reads · ~$mins min · ${prog >= 1 ? 'completed' : prog > 0 ? '${(prog * 100).round()}% done' : 'not started'}',
                    style: ppBody(12.5, color: ppPurple, w: FontWeight.w700))),
                const SizedBox(height: 22),
                for (int i = 0; i < reads.length; i++) _pad(_row(context, i + 1, reads[i])),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _row(BuildContext context, int n, ReadArticle r) {
    final store = ReadingStore.instance;
    final done = store.isCompleted(r.id);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ReadingReaderScreen(article: r))),
        behavior: HitTestBehavior.opaque,
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 26,
            height: 26,
            margin: const EdgeInsets.only(top: 26),
            alignment: Alignment.center,
            decoration: BoxDecoration(color: done ? ppPurple : Colors.transparent, shape: BoxShape.circle, border: done ? null : Border.all(color: ppBorder, width: 1.5)),
            child: done ? const Icon(Icons.check_rounded, size: 14, color: Colors.white) : Text('$n', style: ppBody(12, color: ppSoft, w: FontWeight.w700)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(width: 112, child: ReadCover(seed: r.seed, height: 76, progress: store.isInProgress(r.id) ? store.progressOf(r.id) : null)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(r.title, style: ppJakarta(14).copyWith(height: 1.25), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 5),
                  readMeta(r),
                ]),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}
