// =============================================================================
//  PpJournalScreen - the child's real journal (replaces the JournalV2Home demo)
// -----------------------------------------------------------------------------
//  Added 2026-10-02 from the parenting gap analysis (P1: "the journal block
//  saves nothing and shows another family"). Everything here is this child's
//  own: the memories PpJournalStore holds, newest first, grouped by month,
//  with the age he was on the day. Empty, it says where the first memory
//  will go and offers the four ways to add one, so the feature is still its
//  own advertisement.
//
//  JournalV2Home (the "Priya" demo with the storybook) is untouched and kept
//  for revert; nothing opens it any more. Its storybook can come back once it
//  is fed from this store.
// =============================================================================

import 'package:flutter/material.dart';

import '../../../widgets/storage_image.dart';

import '../pp_child_profile.dart';
import 'journal_capture_screens.dart';
import 'jv2_common.dart';
import 'jv2_data.dart';
import 'jv2_store.dart';
import '../../../theme/pv_fonts.dart';
import '../../brackets/hub/hub_intent_art.dart' show IntentMark;
import '../../pregnancy/preg_tool_chrome.dart';
import '../../products/pv_store_chrome.dart' show PvChip, PvCommit, pvStorePalette;
import '../../../widgets/pv_feedback.dart' show PvPress;

const _months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

/// "3 months", "2 weeks", "1 year 4 months": his age on the day it was written.
String ppAgeOn(DateTime day, DateTime dob) {
  final days = day.difference(dob).inDays;
  if (days < 0) return 'Before birth';
  if (days < 14) return days == 1 ? '1 day' : '$days days';
  if (days < 61) return '${days ~/ 7} weeks';
  var months = (day.year - dob.year) * 12 + day.month - dob.month;
  if (day.day < dob.day) months--;
  if (months < 24) return '$months months';
  final y = months ~/ 12;
  final m = months % 12;
  return m == 0 ? '$y years' : '$y years $m months';
}

class PpJournalScreen extends StatefulWidget {
  const PpJournalScreen({super.key});

  @override
  State<PpJournalScreen> createState() => _PpJournalScreenState();
}

class _PpJournalScreenState extends State<PpJournalScreen> {
  final _store = PpJournalStore.instance;

  @override
  void initState() {
    super.initState();
    _store.init();
  }

  // ---- the one ParentVeda look (2026-10-07) ------------------------------------
  //  The journal on the shell every TTC and pregnancy tool wears: one ink
  //  "Add a memory" instead of the purple floating button, month headings,
  //  white cards. Mobbin: month headings over dated entries, after 5 Minute
  //  Journal (mobbin.com/screens/59059226-c8cc-4e04-a48f-f32331a83c20); a
  //  photo, a title and one meta line per memory, after Paired's timeline
  //  (mobbin.com/screens/0d97143e-8b97-4697-bb75-75bedf45c9fb). A partner's
  //  memory says so in its meta line. `_buildBeforeShell` is the page before.
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_store, ChildProfileStore.instance]),
      builder: (context, _) {
        final p = pvStorePalette;
        final child = ChildProfileStore.instance;
        final list = _store.entries;
        final groups = <String, List<PpJournalEntry>>{};
        for (final e in list) {
          groups.putIfAbsent('${_months[e.createdAt.month - 1]} ${e.createdAt.year}', () => []).add(e);
        }
        return PregToolScaffold(
          // Rose, pregnancy's Keep group (Memories), not the lilac 300 it
          // had: the user, 2026-10-07, "everything purple". Shared with the
          // capture screens it opens. Was: hue: 300.
          hue: kPpJournalHue,
          eyebrow: 'Journal',
          mark: IntentMark.bookMark,
          title: "$jvChild's journal",
          intro: list.isEmpty
              ? '${child.ageLabel} old. Every memory you add stays here, in order, on every phone.'
              : '${list.length} ${list.length == 1 ? 'memory' : 'memories'} so far, ${child.ageLabel} old.',
          children: [
            pregToolPad(PvCommit(
              key: const ValueKey('pp_journal_add'),
              label: 'Add a memory',
              onTap: () => showAddMemorySheet(context),
            )),
            const SizedBox(height: 22),
            if (list.isEmpty)
              pregToolPad(Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: p.line),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Your first memory of $jvChild goes here.',
                      style: pvFraunces(fontSize: 19, fontWeight: FontWeight.w600, height: 1.25, color: p.ink1)),
                  const SizedBox(height: 6),
                  Text('A photo, a first, something funny, or just how today felt. Two lines is plenty.',
                      style: pvManrope(fontSize: 13.5, height: 1.55, color: p.ink2)),
                  const SizedBox(height: 14),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    for (final (label, screen) in [
                      ('A photo', const QuickCaptureScreen(prompt: 'A photo from today') as Widget),
                      ('A first', const GuidedMemoryScreen()),
                      ('A story', const WriteStoryScreen()),
                      ('A letter', const LetterScreen()),
                    ])
                      PvChip(
                        label: label,
                        selected: false,
                        onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen)),
                      ),
                  ]),
                ]),
              )),
            for (final g in groups.entries) ...[
              pregToolPad(Text(g.key,
                  style: pvFraunces(fontSize: 20, fontWeight: FontWeight.w600, color: p.ink1))),
              const SizedBox(height: 10),
              for (final e in g.value) pregToolPad(_cardV3(context, e, child.dob)),
              const SizedBox(height: 12),
            ],
          ],
        );
      },
    );
  }

  Widget _cardV3(BuildContext context, PpJournalEntry e, DateTime dob) {
    final p = pvStorePalette;
    final d = e.createdAt;
    final kind = switch (e.kind) {
      JvKind.letter => 'Letter',
      JvKind.story => 'Story',
      JvKind.guided => 'A first',
      JvKind.moment => 'Moment',
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        key: ValueKey('pp_journal_card_${e.id}'),
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: BorderSide(color: p.line)),
        child: InkWell(
          onTap: () => _open(context, e, dob),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (e.photoPath != null) StorageImage(e.photoPath!, height: 170, width: double.infinity),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                    '$kind · ${d.day} ${_months[d.month - 1]} · ${ppAgeOn(d, dob)}'
                    '${e.fromPartner ? ' · from your partner' : ''}',
                    style: pvManrope(fontSize: 12, fontWeight: FontWeight.w700, color: p.ink3)),
                if (e.title.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(e.title, style: pvFraunces(fontSize: 17, fontWeight: FontWeight.w600, height: 1.25, color: p.ink1)),
                ],
                if (e.body.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(e.body,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: pvManrope(fontSize: 14, height: 1.55, color: p.ink1)),
                ],
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  // Kept for revert (2026-10-07): the page before the shared shell.
  // ignore: unused_element
  Widget _buildBeforeShell(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: ppPurple,
        foregroundColor: Colors.white,
        onPressed: () => showAddMemorySheet(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add a memory'),
      ),
      body: SafeArea(
        bottom: false,
        child: ListenableBuilder(
          listenable: Listenable.merge([_store, ChildProfileStore.instance]),
          builder: (context, _) {
            final child = ChildProfileStore.instance;
            final list = _store.entries;
            final groups = <String, List<PpJournalEntry>>{};
            for (final e in list) {
              groups.putIfAbsent('${_months[e.createdAt.month - 1]} ${e.createdAt.year}', () => []).add(e);
            }
            return ListView(
              padding: const EdgeInsets.only(top: 12, bottom: 110),
              children: [
                jvPad(Row(children: [
                  PvPress(child: GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    behavior: HitTestBehavior.opaque,
                    child: const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.arrow_back_rounded, color: ppInk)),
                  )),
                ])),
                const SizedBox(height: 14),
                jvPad(Text("$jvChild's journal", style: ppFraunces(30, h: 1.1))),
                const SizedBox(height: 6),
                jvPad(Text(
                  list.isEmpty
                      ? '${child.ageLabel} old. Every memory you add stays here, in order.'
                      : '${list.length} ${list.length == 1 ? 'memory' : 'memories'} so far · ${child.ageLabel} old',
                  style: ppBody(13.5, color: ppSoft, h: 1.5),
                )),
                const SizedBox(height: 22),
                if (list.isEmpty) jvPad(_empty(context)),
                for (final g in groups.entries) ...[
                  jvPad(Text(g.key, style: ppJakarta(14, color: ppMuted))),
                  const SizedBox(height: 10),
                  for (final e in g.value) jvPad(_card(context, e, child.dob)),
                  const SizedBox(height: 10),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  // ignore: unused_element
  Widget _empty(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: jvPaper, borderRadius: BorderRadius.circular(22), border: Border.all(color: jvPaperLine)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Your first memory of $jvChild goes here.', style: ppFraunces(20, h: 1.25)),
          const SizedBox(height: 8),
          Text('A photo, a first, a funny thing he did, or just how today felt. Two lines is plenty.',
              style: ppBody(13.5, color: ppSoft, h: 1.55)),
          const SizedBox(height: 16),
          Wrap(spacing: 8, runSpacing: 8, children: [
            _chip(context, Icons.photo_camera_outlined, 'A photo', const QuickCaptureScreen(prompt: 'A photo from today')),
            _chip(context, Icons.auto_awesome_outlined, 'A first', const GuidedMemoryScreen()),
            _chip(context, Icons.edit_outlined, 'A story', const WriteStoryScreen()),
            _chip(context, Icons.favorite_border, 'A letter', const LetterScreen()),
          ]),
        ]),
      );

  // ignore: unused_element
  Widget _chip(BuildContext context, IconData icon, String label, Widget screen) => ActionChip(
        avatar: Icon(icon, size: 16, color: ppPurple),
        label: Text(label, style: ppBody(13, color: ppInk, w: FontWeight.w600)),
        backgroundColor: Colors.white,
        side: const BorderSide(color: ppLine),
        onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen)),
      );

  // ignore: unused_element
  Widget _card(BuildContext context, PpJournalEntry e, DateTime dob) {
    final d = e.createdAt;
    final kind = switch (e.kind) {
      JvKind.letter => 'Letter',
      JvKind.story => 'Story',
      JvKind.guided => 'A first',
      JvKind.moment => 'Moment',
    };
    return PvPress(child: GestureDetector(
      onTap: () => _open(context, e, dob),
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: ppHair)),
        clipBehavior: Clip.antiAlias,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (e.photoPath != null)
            // StorageImage, not Image.file: a synced photo is a storage path
            // (fetched and cached on demand), not a file on this phone.
            StorageImage(e.photoPath!, height: 170, width: double.infinity),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('$kind · ${d.day} ${_months[d.month - 1]} · ${ppAgeOn(d, dob)}', style: ppBody(11.5, color: ppMuted, w: FontWeight.w600)),
              if (e.title.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(e.title, style: ppJakarta(16)),
              ],
              if (e.body.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(e.body, maxLines: 3, overflow: TextOverflow.ellipsis, style: ppBody(13.5, color: ppInk, h: 1.55)),
              ],
            ]),
          ),
        ]),
      ),
    ));
  }

  // ---- the entry sheet, the one look (2026-10-07) ---------------------------
  //  A white sheet: Manrope meta, a Fraunces title, the words in Manrope 15,
  //  and Delete as a quiet ink text button, never a colour. The partner rule
  //  is unchanged: a partner's memory is shown, not changed here, and offers
  //  no Delete. `_openBeforeShell` is the sheet before.
  void _open(BuildContext context, PpJournalEntry e, DateTime dob) {
    final p = pvStorePalette;
    final d = e.createdAt;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: p.ground,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.85),
          child: ListView(
              key: const ValueKey('pp_journal_entry_sheet'),
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                Center(
                    child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(color: p.line, borderRadius: BorderRadius.circular(999)))),
                const SizedBox(height: 16),
                if (e.photoPath != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: StorageImage(e.photoPath!),
                  ),
                  const SizedBox(height: 14),
                ],
                Text(
                    '${d.day} ${_months[d.month - 1]} ${d.year} · ${ppAgeOn(d, dob)}'
                    '${e.fromPartner ? ' · from your partner' : ''}',
                    style: pvManrope(fontSize: 12, fontWeight: FontWeight.w700, color: p.ink3)),
                if (e.title.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(e.title,
                      style: pvFraunces(fontSize: 22, fontWeight: FontWeight.w600, height: 1.25, color: p.ink1)),
                ],
                if (e.body.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(e.body, style: pvManrope(fontSize: 15, height: 1.7, color: p.ink1)),
                ],
                const SizedBox(height: 20),
                Divider(height: 1, thickness: 1, color: p.line),
                const SizedBox(height: 12),
                // A partner's memory: shown, not changed here. Only the person
                // who wrote it can edit or delete it.
                if (e.fromPartner)
                  Text('Added by your partner. Only they can change it.',
                      key: const ValueKey('pp_journal_partner_note'),
                      style: pvManrope(fontSize: 13, fontWeight: FontWeight.w600, color: p.ink2))
                else
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      key: const ValueKey('pp_journal_delete'),
                      style: TextButton.styleFrom(foregroundColor: p.ink1),
                      onPressed: () async {
                        final ok = await showDialog<bool>(
                          context: ctx,
                          builder: (dctx) => AlertDialog(
                            backgroundColor: Colors.white,
                            title: Text('Delete this memory?',
                                style: pvFraunces(fontSize: 20, fontWeight: FontWeight.w600, color: p.ink1)),
                            content: Text('It will be gone from your journal on every phone. This cannot be undone.',
                                style: pvManrope(fontSize: 14, height: 1.5, color: p.ink2)),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.of(dctx).pop(false),
                                  child: Text('Keep it',
                                      style: pvManrope(fontSize: 14, fontWeight: FontWeight.w700, color: p.ink1))),
                              TextButton(
                                  onPressed: () => Navigator.of(dctx).pop(true),
                                  child: Text('Delete',
                                      style: pvManrope(fontSize: 14, fontWeight: FontWeight.w700, color: p.ink2))),
                            ],
                          ),
                        );
                        if (ok == true) {
                          await _store.remove(e.id);
                          if (ctx.mounted) Navigator.of(ctx).pop();
                        }
                      },
                      icon: Icon(Icons.delete_outline_rounded, size: 19, color: p.ink2),
                      label: Text('Delete', style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w700, color: p.ink2)),
                    ),
                  ),
              ]),
        ),
      ),
    );
  }

  // Kept for revert (2026-10-07): the entry sheet before the one look.
  // ignore: unused_element
  void _openBeforeShell(BuildContext context, PpJournalEntry e, DateTime dob) {
    final d = e.createdAt;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: ppBg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (ctx) => SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.85),
          child: ListView(shrinkWrap: true, padding: const EdgeInsets.fromLTRB(24, 16, 24, 24), children: [
            if (e.photoPath != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: StorageImage(e.photoPath!),
              ),
              const SizedBox(height: 14),
            ],
            Text('${d.day} ${_months[d.month - 1]} ${d.year} · ${ppAgeOn(d, dob)}', style: ppBody(12, color: ppMuted, w: FontWeight.w600)),
            if (e.title.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(e.title, style: ppFraunces(22, h: 1.2)),
            ],
            if (e.body.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(e.body, style: ppBody(15, color: ppInk, h: 1.7)),
            ],
            const SizedBox(height: 20),
            // A partner's memory: shown, not changed here (2026-10-07). Only
            // the person who wrote it can edit or delete it.
            if (e.fromPartner)
              Text('Added by your partner. Only they can change it.',
                  key: const ValueKey('pp_journal_partner_note'),
                  style: ppBody(13, color: ppMuted, w: FontWeight.w600))
            else
            TextButton.icon(
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: ctx,
                  builder: (dctx) => AlertDialog(
                    title: const Text('Delete this memory?'),
                    content: const Text('It will be gone from your journal on every phone. This cannot be undone.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(dctx).pop(false), child: const Text('Keep it')),
                      TextButton(onPressed: () => Navigator.of(dctx).pop(true), child: const Text('Delete')),
                    ],
                  ),
                );
                if (ok == true) {
                  await _store.remove(e.id);
                  if (ctx.mounted) Navigator.of(ctx).pop();
                }
              },
              icon: const Icon(Icons.delete_outline_rounded, color: ppMuted),
              label: Text('Delete', style: ppBody(13, color: ppMuted, w: FontWeight.w700)),
            ),
          ]),
        ),
      ),
    );
  }
}
