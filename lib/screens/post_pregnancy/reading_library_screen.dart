// =============================================================================
//  ReadingLibraryScreen - your reading library (bookmarks + progress)
// -----------------------------------------------------------------------------
//  Continue reading, Saved, Completed and Collections in one calm place, so the
//  parent always knows where they left off. Reflects the ReadingStore live.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';
import 'pp_reading_data.dart';
import 'reading_collection_screen.dart';
import 'reading_common.dart';
import 'reading_reader_screen.dart';

class ReadingLibraryScreen extends StatelessWidget {
  const ReadingLibraryScreen({super.key});

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);
  void _open(BuildContext c, ReadArticle a) => Navigator.of(c).push(MaterialPageRoute<void>(builder: (_) => ReadingReaderScreen(article: a)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: ReadingStore.instance,
          builder: (context, _) {
            final store = ReadingStore.instance;
            final cont = store.continueReading;
            final saved = store.saved;
            final completed = kReadArticles.where((a) => store.isCompleted(a.id)).toList();
            return ListView(
              padding: const EdgeInsets.only(top: 12, bottom: 40),
              children: [
                _pad(ppBack(context, 'Read')),
                const SizedBox(height: 18),
                _pad(ppEyebrow('Your library', color: ppPurple)),
                const SizedBox(height: 8),
                _pad(Text('Your reading', style: ppFraunces(30, h: 1.1))),
                const SizedBox(height: 22),

                _section(context, 'Continue reading', cont, showProgress: true),
                _section(context, 'Saved', saved),
                _section(context, 'Completed', completed),

                _pad(readSectionHeader('Collections')),
                const SizedBox(height: 14),
                _pad(Column(children: [
                  for (final c in kReadCollections) _collectionRow(context, c),
                ])),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _section(BuildContext context, String title, List<ReadArticle> items, {bool showProgress = false}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _pad(readSectionHeader(title)),
      const SizedBox(height: 14),
      if (items.isEmpty)
        _pad(Padding(padding: const EdgeInsets.only(bottom: 26), child: Text(_emptyFor(title), style: ppBody(13.5, color: ppMuted))))
      else ...[
        _pad(Column(children: [
          for (final a in items)
            ReadListCard(article: a, onTap: () => _open(context, a), progress: showProgress ? ReadingStore.instance.progressOf(a.id) : null),
        ])),
        const SizedBox(height: 10),
      ],
    ]);
  }

  String _emptyFor(String title) {
    switch (title) {
      case 'Continue reading':
        return 'Nothing in progress - open Today’s read to begin.';
      case 'Saved':
        return 'Tap the bookmark on any read to keep it here.';
      default:
        return 'Reads you finish will gather here.';
    }
  }

  Widget _collectionRow(BuildContext context, ReadCollection c) {
    final mins = c.articleIds.map(readArticleById).fold<int>(0, (a, r) => a + r.minutes);
    final prog = ReadingStore.instance.collectionProgress(c);
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ReadingCollectionScreen(collection: c))),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(children: [
          Container(width: 44, height: 44, alignment: Alignment.center, decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(13)), child: Icon(c.icon, size: 21, color: ppPurple)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(c.title, style: ppJakarta(14.5), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 3),
              Text('${c.articleIds.length} reads · ~$mins min${prog > 0 ? ' · ${(prog * 100).round()}%' : ''}', style: ppBody(12, color: ppMuted)),
            ]),
          ),
          const Icon(Icons.chevron_right_rounded, size: 20, color: ppMuted),
        ]),
      ),
    );
  }
}
