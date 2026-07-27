// =============================================================================
//  TTC - the shared journal
// -----------------------------------------------------------------------------
//  "Both partners can write. Everything survives into Pregnancy."
//                                                       - TTC master, §3.15
//
//  Deliberately small: four kinds, one writer sheet, one chronological list.
//  A journal with filters, tabs and categories is a form, and nobody writes
//  honestly into a form.
//
//  Entries are attributed but never hidden from each other. That is a different
//  decision from baby-name votes, where privacy in both directions is the whole
//  point - here, seeing what your partner wrote is the feature.
// =============================================================================

import 'package:flutter/material.dart';

import '../../ttc/ttc_journal_store.dart';
import 'ttc_common.dart';
import 'ttc_strings.dart';
import 'ttc_today_screen.dart' show ttcEntryIcon;

/// Opens the journal from anywhere in the stage.
void openTtcJournal(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute<void>(
    builder: (_) => const TtcJournalScreen(),
    settings: const RouteSettings(name: 'ttc/journal'),
  ));
}

class TtcJournalScreen extends StatelessWidget {
  const TtcJournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation:
          Listenable.merge([TtcJournalStore.instance, TtcLang.instance]),
      builder: (context, _) {
        final t = TtcS.current();
        final hi = t.hinglish;
        final entries = TtcJournalStore.instance.entries;
        return Scaffold(
          backgroundColor: ttcBg,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(ttcGutter, 8, ttcGutter, 40),
              children: [
                TtcBackBar(title: t.journalTitle),
                const SizedBox(height: 18),

                // The four ways in, always visible - including when the list
                // below is empty.
                Row(children: [
                  for (final kind in TtcEntryKind.values) ...[
                    Expanded(
                      child: GestureDetector(
                        onTap: () => writeTtcEntry(context, kind: kind),
                        behavior: HitTestBehavior.opaque,
                        child: Column(children: [
                          Container(
                            width: 50,
                            height: 50,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                                color: ttcPanel, shape: BoxShape.circle),
                            child: Icon(ttcEntryIcon(kind),
                                size: 21, color: ttcPurple),
                          ),
                          const SizedBox(height: 7),
                          Text(kind.label(hi),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: ttcBody(10.5, w: FontWeight.w700, h: 1.25)),
                        ]),
                      ),
                    ),
                    if (kind != TtcEntryKind.values.last)
                      const SizedBox(width: 8),
                  ],
                ]),
                const SizedBox(height: 22),

                if (entries.isEmpty)
                  TtcEmpty(
                    icon: Icons.auto_stories_outlined,
                    title: t.journalEmptyTitle,
                    body: t.journalEmptyBody,
                  )
                else
                  for (final e in entries) ...[
                    _EntryCard(entry: e, t: t),
                    const SizedBox(height: 11),
                  ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({required this.entry, required this.t});

  final TtcJournalEntry entry;
  final TtcS t;

  @override
  Widget build(BuildContext context) {
    final hi = t.hinglish;
    return TtcCard(
      onTap: () => _confirmDelete(context),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(ttcEntryIcon(entry.kind), size: 15, color: ttcPurple),
          const SizedBox(width: 7),
          Text(entry.kind.label(hi),
              style: ttcBody(11.5, color: ttcPurple, w: FontWeight.w800)),
          const Spacer(),
          Text(_fmt(entry.date, hi),
              style: ttcBody(11, color: ttcMuted, w: FontWeight.w600)),
        ]),
        if (entry.prompt != null) ...[
          const SizedBox(height: 10),
          Text(entry.prompt!,
              style: ttcBody(12, color: ttcMuted, w: FontWeight.w600, h: 1.4)),
        ],
        const SizedBox(height: 9),
        Text(entry.text, style: ttcBody(14, color: ttcInk, h: 1.6)),
        if (entry.author == TtcAuthor.partner) ...[
          const SizedBox(height: 10),
          Row(children: [
            const Icon(Icons.person_outline_rounded, size: 13, color: ttcMuted),
            const SizedBox(width: 6),
            Text(t.journalByPartner,
                style: ttcBody(11, color: ttcMuted, w: FontWeight.w600)),
          ]),
        ],
      ]),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(t.journalDelete, style: ttcJakarta(16)),
        content: Text(
          t.hinglish
              ? 'Ye wapas nahi aayega.'
              : 'This cannot be brought back.',
          style: ttcBody(13.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(t.journalCancel,
                style: ttcBody(13, color: ttcSoft, w: FontWeight.w700)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(t.journalDelete,
                style: ttcBody(13,
                    color: const Color(0xFFD92D20), w: FontWeight.w800)),
          ),
        ],
      ),
    );
    if (ok == true) TtcJournalStore.instance.remove(entry.id);
  }

  static String _fmt(DateTime d, bool hi) {
    const m = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${m[d.month - 1]}';
  }
}

// ---- the writer -------------------------------------------------------------

/// The one place an entry is written, from Today or from the journal itself.
Future<void> writeTtcEntry(
  BuildContext context, {
  required TtcEntryKind kind,
  String? prompt,
  TtcAuthor author = TtcAuthor.me,
}) async {
  final t = TtcS.current();
  final controller = TextEditingController();
  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: ttcLine, borderRadius: BorderRadius.circular(999)),
          ),
          const SizedBox(height: 18),
          Row(children: [
            Icon(ttcEntryIcon(kind), size: 18, color: ttcPurple),
            const SizedBox(width: 9),
            Expanded(
                child: Text(kind.label(t.hinglish), style: ttcJakarta(16.5))),
          ]),
          if (prompt != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: ttcPanel, borderRadius: BorderRadius.circular(14)),
              child: Text(prompt,
                  style: ttcBody(13,
                      color: ttcTitleInk, w: FontWeight.w600, h: 1.45)),
            ),
          ],
          const SizedBox(height: 14),
          TextField(
            controller: controller,
            autofocus: true,
            maxLines: 6,
            minLines: 4,
            style: ttcBody(14.5, color: ttcInk, h: 1.6),
            decoration: InputDecoration(
              hintText: t.journalHint,
              hintStyle: ttcBody(14, color: ttcMuted),
              filled: true,
              fillColor: ttcBg,
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: ttcBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: ttcBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: ttcPurple, width: 1.4),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.of(ctx).pop(false),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                      color: ttcPanel,
                      borderRadius: BorderRadius.circular(16)),
                  child: Text(t.journalCancel,
                      style:
                          ttcBody(14, color: ttcSoft, w: FontWeight.w800)),
                ),
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: () => Navigator.of(ctx).pop(true),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                      color: ttcPurple,
                      borderRadius: BorderRadius.circular(16)),
                  child: Text(t.journalSave,
                      style: ttcBody(14,
                          color: Colors.white, w: FontWeight.w800)),
                ),
              ),
            ),
          ]),
        ]),
      ),
    ),
  );

  // An empty entry is silently not saved rather than erroring - tapping save on
  // nothing is a change of mind, not a mistake worth a message.
  if (saved == true && controller.text.trim().isNotEmpty) {
    TtcJournalStore.instance.add(
      kind: kind,
      text: controller.text,
      prompt: prompt,
      author: author,
    );
  }
  controller.dispose();
}
