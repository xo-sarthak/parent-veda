// =============================================================================
//  PregnancyKeptScreen - "Kept for you" (R1, 2026-10-25)
// -----------------------------------------------------------------------------
//  A pregnancy that has ended, as she left it: her bump photos, journal,
//  weekly notes, letters and Garbh Sanskar recordings, her appointments, and
//  a line for everything else that is kept. View only: no weeks, no reminders,
//  no edit controls. It is one calm page rather than a read-only mode on a
//  dozen tool screens, so nothing here can start counting again.
//
//  The user (2026-10-25): "let them take control of it and delete it
//  permanently if they want tht, why decide for them?" So its foot holds
//  "Delete this pregnancy", behind one confirmation that names what goes.
//  Found from the Your family sheet and from You, never pushed at her, and
//  never asked about at the moment of the loss.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';

import '../../data/garbh_rebuild_data.dart';
import '../../services/bump_store.dart';
import '../../services/daily_store.dart';
import '../../services/journal_store.dart';
import '../../services/memory_store.dart';
import '../../services/pregnancy_archive.dart';
import '../../services/pregnancy_records.dart';
import '../../services/scans_store.dart';
import '../../services/symptom_store.dart';
import '../../services/tools_store.dart';
import '../../theme/pv_fonts.dart';
import '../../widgets/pv_feedback.dart';
import '../../widgets/pv_toast.dart';
import '../post_pregnancy/pp_child_profile.dart';
import '../products/pv_store_chrome.dart' show PvRoundIcon;
import '../v2/v2_palette.dart';

const String kPregnancyKeptRoute = 'pregnancy_kept';

const _months = [
  '', 'January', 'February', 'March', 'April', 'May', 'June', 'July',
  'August', 'September', 'October', 'November', 'December',
];

/// "Kiara's pregnancy", or "Pregnancy, March to June 2026": the name a kept
/// pregnancy goes by in the family sheet, in You and on its page. The months
/// run from about the positive test (four weeks after the start the weeks are
/// counted from) to the end. Neutral words for every ending: a loss is never
/// named for her.
String pregnancyKeptTitle(PregnancyRecord r, {List<Child>? children}) {
  if (r.outcome == PregnancyOutcome.birth && r.childId != null) {
    for (final c in children ?? ChildProfileStore.instance.children) {
      if (c.id == r.childId && c.name.trim().isNotEmpty && c.name != Child.placeholder) {
        return "${c.name.trim()}'s pregnancy";
      }
    }
    return "Your baby's pregnancy";
  }
  final from = r.startedOn.add(const Duration(days: 28));
  final to = r.endedOn ?? from;
  final a = '${_months[from.month]}${from.year == to.year ? '' : ' ${from.year}'}';
  final b = '${_months[to.month]} ${to.year}';
  return from.year == to.year && from.month == to.month
      ? 'Pregnancy, $b'
      : 'Pregnancy, $a to $b';
}

Future<void> openPregnancyKept(BuildContext context, PregnancyRecord r) =>
    Navigator.of(context).push(MaterialPageRoute(
      settings: const RouteSettings(name: kPregnancyKeptRoute),
      builder: (_) => PregnancyKeptScreen(record: r),
    ));

/// The words of the delete confirmation: what goes, in her terms (pure).
String pregnancyDeleteSummary({
  required int photos,
  required int journal,
  required int notes,
  required int letters,
  required int recordings,
  required int other,
}) {
  String n(int c, String one, String many) => '$c ${c == 1 ? one : many}';
  final parts = [
    if (photos > 0) n(photos, 'bump photo', 'bump photos'),
    if (journal > 0) n(journal, 'journal entry', 'journal entries'),
    if (notes > 0) n(notes, 'weekly note', 'weekly notes'),
    if (letters > 0) n(letters, 'letter', 'letters'),
    if (recordings > 0) n(recordings, 'recording', 'recordings'),
    if (other > 0) 'everything else you logged',
  ];
  if (parts.isEmpty) return 'This pregnancy has nothing saved in it.';
  final list = parts.length == 1
      ? parts.single
      : '${parts.sublist(0, parts.length - 1).join(', ')} and ${parts.last}';
  return 'This deletes $list.';
}

class PregnancyKeptScreen extends StatefulWidget {
  const PregnancyKeptScreen({super.key, required this.record});
  final PregnancyRecord record;

  @override
  State<PregnancyKeptScreen> createState() => _PregnancyKeptScreenState();
}

class _PregnancyKeptScreenState extends State<PregnancyKeptScreen> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    PregnancyArchive.loadAll().whenComplete(() {
      if (mounted) setState(() => _ready = true);
    });
  }

  PregnancyWindow get _w => PregnancyRecords.instance.windowOf(widget.record);

  Future<void> _delete() async {
    final w = _w;
    final summary = pregnancyDeleteSummary(
      photos: BumpStore.instance.countIn(w),
      journal: JournalStore.instance.countIn(w),
      notes: MemoryStore.instance.countIn(w),
      letters: DailyStore.instance.countIn(w),
      recordings: GarbhJournalStore.instance.countIn(w),
      other: SymptomStore.instance.countIn(w) +
          ToolsStore.instance.countIn(w) +
          ScansStore.instance.countIn(w) +
          PregnancyArchive.archiveCounts(widget.record).length,
    );
    final p = V2PaletteStore.instance.current;
    final yes = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: p.ground,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Delete this pregnancy?',
                style: pvFraunces(fontSize: 24, fontWeight: FontWeight.w600, color: p.ink1)),
            const SizedBox(height: 10),
            Text(
              '$summary It is removed from your phones now, and our servers clear it fully within 90 days. '
              'Your partner\'s own journal stays his.',
              key: const ValueKey('pregnancy_kept_delete_words'),
              style: pvManrope(fontSize: 14.5, height: 1.5, color: p.ink2),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                key: const ValueKey('pregnancy_kept_delete_yes'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF2F2C30), // the one ink
                  foregroundColor: Colors.white,
                  shape: const StadiumBorder(),
                ),
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text('Delete',
                    style: pvManrope(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                key: const ValueKey('pregnancy_kept_delete_no'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: p.ink1,
                  side: BorderSide(color: p.line),
                  shape: const StadiumBorder(),
                ),
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text('Keep it',
                    style: pvManrope(fontSize: 15, fontWeight: FontWeight.w700, color: p.ink1)),
              ),
            ),
          ]),
        ),
      ),
    );
    if (yes != true || !mounted) return;
    pvCommitFeedback();
    await PregnancyArchive.deletePregnancy(widget.record);
    if (!mounted) return;
    Navigator.of(context).pop();
    pvToast(context, 'Deleted. It is gone from your phones now.', kind: PvToastKind.done);
  }

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final r = widget.record;
    return Scaffold(
      backgroundColor: p.ground,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: Listenable.merge([
            PregnancyRecords.instance,
            BumpStore.instance,
            JournalStore.instance,
            MemoryStore.instance,
            DailyStore.instance,
            GarbhJournalStore.instance,
          ]),
          builder: (context, _) {
            final w = _w;
            final photos = BumpStore.instance.photosIn(w);
            final journal = JournalStore.instance.entriesIn(w);
            final notes = MemoryStore.instance.notesIn(w);
            final letters = DailyStore.instance.talkEntriesIn(w);
            final garbh = GarbhJournalStore.instance.entriesIn(w);
            final appts = ScansStore.instance.appointmentsIn(w);
            final tools = ToolsStore.instance.countsIn(w);
            final symptoms = SymptomStore.instance.countIn(w);
            final also = <String>[
              if (symptoms > 0) '$symptoms ${symptoms == 1 ? 'symptom' : 'symptoms'} logged',
              if (tools.weights > 0) '${tools.weights} ${tools.weights == 1 ? 'weight' : 'weights'}',
              if (tools.kicks > 0) '${tools.kicks} kick ${tools.kicks == 1 ? 'count' : 'counts'}',
              if (tools.contractions > 0)
                '${tools.contractions} contraction ${tools.contractions == 1 ? 'session' : 'sessions'}',
              for (final e in PregnancyArchive.archiveCounts(r).entries) '${e.key} (${e.value})',
            ];
            final empty = photos.isEmpty &&
                journal.isEmpty &&
                notes.isEmpty &&
                letters.isEmpty &&
                garbh.isEmpty &&
                appts.isEmpty &&
                also.isEmpty;

            Widget heading(String t) => Padding(
                  padding: const EdgeInsets.fromLTRB(0, 22, 0, 10),
                  child: Text(t.toUpperCase(),
                      style: pvManrope(fontSize: 11.5, fontWeight: FontWeight.w800, letterSpacing: 0.9, color: p.ink3)),
                );
            Widget item(String title, String? sub, String? body) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(title, style: pvManrope(fontSize: 15, fontWeight: FontWeight.w700, color: p.ink1)),
                    if (sub != null && sub.isNotEmpty)
                      Text(sub, style: pvManrope(fontSize: 12.5, fontWeight: FontWeight.w600, color: p.ink3)),
                    if (body != null && body.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(body.trim(), style: pvManrope(fontSize: 14, height: 1.5, color: p.ink2)),
                    ],
                  ]),
                );
            String day(DateTime d) => '${d.day} ${_months[d.month]} ${d.year}';

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                Row(children: [
                  PvRoundIcon(
                    icon: Icons.arrow_back_rounded,
                    semanticLabel: 'Back',
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                ]),
                const SizedBox(height: 16),
                Text(pregnancyKeptTitle(r),
                    key: const ValueKey('pregnancy_kept_title'),
                    style: pvFraunces(fontSize: 28, fontWeight: FontWeight.w600, height: 1.15, color: p.ink1)),
                const SizedBox(height: 8),
                Text('Kept for you, as you left it. Nothing here counts weeks or sends reminders.',
                    style: pvManrope(fontSize: 14.5, height: 1.5, color: p.ink2)),
                if (!_ready)
                  const Padding(
                    padding: EdgeInsets.only(top: 32),
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                else ...[
                  if (empty)
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: Text('Nothing was saved in this pregnancy. It is kept here as part of your story.',
                          style: pvManrope(fontSize: 14, height: 1.5, color: p.ink2)),
                    ),
                  if (photos.isNotEmpty) ...[
                    heading('Bump photos'),
                    GridView.count(
                      key: const ValueKey('pregnancy_kept_photos'),
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      children: [
                        for (final ph in photos)
                          PvPress(
                            child: GestureDetector(
                              onTap: () => _viewPhoto(ph.imageUrl, 'Week ${ph.weekNumber}'),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: _image(ph.imageUrl, p),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                  if (journal.isNotEmpty) ...[
                    heading('Your journal'),
                    for (final e in journal)
                      item(e.title.isEmpty ? 'A memory' : e.title, day(e.date), e.description),
                  ],
                  if (notes.isNotEmpty) ...[
                    heading('Weekly notes'),
                    for (final n in notes) item('Week ${n.week}', null, n.text),
                  ],
                  if (letters.isNotEmpty) ...[
                    heading('Letters to your baby'),
                    for (final l in letters) item(l.prompt.isEmpty ? 'Week ${l.week}' : l.prompt, 'Week ${l.week}', l.text),
                  ],
                  if (garbh.isNotEmpty) ...[
                    heading('Garbh Sanskar'),
                    for (final g in garbh) item(g.title.now, 'Week ${g.week}', null),
                  ],
                  if (appts.isNotEmpty) ...[
                    heading('Appointments'),
                    for (final a in appts) item(a.title, day(a.date), null),
                  ],
                  if (also.isNotEmpty) ...[
                    heading('Also kept'),
                    Text(also.join(' · '),
                        key: const ValueKey('pregnancy_kept_also'),
                        style: pvManrope(fontSize: 14, height: 1.5, color: p.ink2)),
                  ],
                  const SizedBox(height: 36),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      key: const ValueKey('pregnancy_kept_delete'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: p.ink1,
                        side: BorderSide(color: p.line),
                        shape: const StadiumBorder(),
                      ),
                      onPressed: _delete,
                      child: Text('Delete this pregnancy',
                          style: pvManrope(fontSize: 15, fontWeight: FontWeight.w700, color: p.ink1)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Only if you want to. Nothing is ever deleted for you.',
                      textAlign: TextAlign.center,
                      style: pvManrope(fontSize: 12.5, height: 1.5, color: p.ink3)),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _image(String path, V2Palette p) {
    if (path.startsWith('http')) {
      return Image.network(path, fit: BoxFit.cover,
          errorBuilder: (_, _, _) => ColoredBox(color: p.surfaceAlt));
    }
    final f = File(path);
    if (path.isEmpty || !f.existsSync()) return ColoredBox(color: p.surfaceAlt);
    return Image.file(f, fit: BoxFit.cover,
        errorBuilder: (_, _, _) => ColoredBox(color: p.surfaceAlt));
  }

  void _viewPhoto(String path, String label) {
    final p = V2PaletteStore.instance.current;
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: p.ground,
        insetPadding: const EdgeInsets.all(16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: InteractiveViewer(child: AspectRatio(aspectRatio: 3 / 4, child: _image(path, p))),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(label, style: pvManrope(fontSize: 14, fontWeight: FontWeight.w700, color: p.ink1)),
          ),
        ]),
      ),
    );
  }
}

/// More than one pregnancy kept: a quiet list, each opening its own page
/// (You's "Your pregnancies").
Future<void> showPvKeptPregnanciesSheet(BuildContext context) {
  final p = V2PaletteStore.instance.current;
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: p.ground,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Your pregnancies', style: pvFraunces(fontSize: 22, fontWeight: FontWeight.w600, color: p.ink1)),
          const SizedBox(height: 6),
          Text('Each one is kept as you left it. Look at it, or delete it if you want to.',
              style: pvManrope(fontSize: 13.5, height: 1.45, color: p.ink2)),
          const SizedBox(height: 8),
          for (final r in PregnancyRecords.instance.kept)
            ListTile(
              key: ValueKey('pv_kept_pregnancy_${r.id}'),
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.auto_stories_outlined, color: p.ink2),
              title: Text(pregnancyKeptTitle(r),
                  style: pvManrope(fontSize: 15, fontWeight: FontWeight.w700, color: p.ink1)),
              trailing: Icon(Icons.chevron_right_rounded, color: p.ink3),
              onTap: () {
                Navigator.of(ctx).pop();
                openPregnancyKept(context, r);
              },
            ),
        ]),
      ),
    ),
  );
}
