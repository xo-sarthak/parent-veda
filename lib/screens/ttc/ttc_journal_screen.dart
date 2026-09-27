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

import '../../theme/pv_fonts.dart';
import '../../ttc/ttc_daily_data.dart';
import '../../ttc/ttc_journal_store.dart';
import '../../ttc/ttc_store.dart';
import '../../widgets/pv_feedback.dart' show pvCommitFeedback;
import '../products/pv_store_chrome.dart' show pvSnack;
import '../v2/v2_palette.dart';
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

/// Who can read the journal, said plainly (tools pass, 2026-09-27).
String ttcJournalWhoSees(bool partnerJoined) => partnerJoined
    ? 'Your partner can read everything here, and you can read what they write.'
    : 'When your partner joins, they can read everything here too.';

// =============================================================================
//  The journal, redrawn (2026-09-27)
// -----------------------------------------------------------------------------
//  The user, on the phone: "the Our journal page is so bad... hideous... all
//  purple... poor UI UX", and the writing sheet the home's pencil opens was
//  "the old UI, all purple". It was the stage's first screen and had never
//  been redrawn: four purple circles, purple chips, boxed cards, a tap that
//  offered only "Delete?".
//
//  THE SHAPE is the pregnancy journal's (`pv_journal_screen.dart`, redrawn
//  2026-09-23), so the two journals read as one product: a white page, rows on
//  the page instead of boxed cards, a date block on the left (weekday over the
//  day), a small grey eyebrow, the words in a serif, and a tap that READS the
//  entry. Edit and Delete live on the entry's own page, Delete behind the menu
//  and a confirm. Mobbin 2026-09-27: Perplexity's Memories (a grey "KIND ·
//  date" eyebrow over the words, rows with hairlines), Bumble's answer screen
//  (the prompt sits above the text box, one ink Save), Noom's entry detail
//  (Update first, Delete as its own confirmed step).
//
//  WHAT DID NOT CHANGE: the data. `TtcJournalStore` keeps its keys, its ids and
//  its sync; the four kinds are the same enum, now a calm choice inside the
//  writer rather than four purple buttons. The old page and sheet are kept
//  below as `TtcJournalScreenClassic` and `writeTtcEntryClassic`; nothing
//  pushes them.
// =============================================================================

const List<String> _jDays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
const List<String> _jMonths = [
  'January', 'February', 'March', 'April', 'May', 'June', 'July', //
  'August', 'September', 'October', 'November', 'December',
];
const List<String> _jWeekdays = [
  'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', //
  'Sunday',
];

String _jClock(DateTime d) {
  final h = d.hour == 0 ? 12 : (d.hour > 12 ? d.hour - 12 : d.hour);
  return '$h:${d.minute.toString().padLeft(2, '0')} ${d.hour < 12 ? 'am' : 'pm'}';
}

/// The red of a destructive word. The same value the pregnancy entry uses.
const Color _jDanger = Color(0xFFC0392B);

/// Whether she can change or delete this entry here. Her own words only: his
/// arrive from the cloud and are his to change, and a delete of his row would
/// come back on the next sync.
bool ttcJournalIsMine(TtcJournalEntry e) => e.author == TtcAuthor.me;

class TtcJournalScreen extends StatelessWidget {
  const TtcJournalScreen({super.key});

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: Listenable.merge([
          TtcJournalStore.instance,
          TtcLang.instance,
          // For the "who can read this" line, which changes when he joins.
          TtcStore.instance,
          V2PaletteStore.instance,
        ]),
        builder: (context, _) => _build(context),
      );

  Widget _build(BuildContext context) {
    final pal = V2PaletteStore.instance.current;
    final t = TtcS.current();
    final entries = TtcJournalStore.instance.entries;
    final prompt = ttcPromptForToday(TtcStore.instance.today.chapter);
    final promptText = prompt.text(t.hinglish);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        foregroundColor: pal.ink1,
        elevation: 0,
        titleSpacing: 0,
        title: Text(t.journalTitle,
            style: pvFraunces(fontSize: 21, color: pal.ink1)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(0, 4, 0, ttcBottomInset),
        children: [
          // ---- what this is, and who reads it: said once -------------------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    'A notebook for the two of you. Write a memory, a letter '
                    'to your future child, a question for the doctor or how '
                    'today felt.',
                    style: pvManrope(
                        fontSize: 15, height: 1.5, color: pal.ink2)),
                const SizedBox(height: 10),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(Icons.visibility_outlined,
                        size: 16, color: pal.ink3),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                        ttcJournalWhoSees(TtcStore.instance.partnerJoined),
                        style: pvManrope(
                            fontSize: 13, height: 1.45, color: pal.ink3)),
                  ),
                ]),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: () {
                    pvCommitFeedback();
                    writeTtcEntry(context, kind: TtcEntryKind.memory);
                  },
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Write something'),
                  style: FilledButton.styleFrom(
                    backgroundColor: pal.ink1,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 46),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    shape: const StadiumBorder(),
                    textStyle: pvManrope(
                        fontSize: 14.5, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ---- one prompt, offered, never a task -----------------------------
          _JournalPromptCard(
            pal: pal,
            eyebrow: t.journalPromptEyebrow.toUpperCase(),
            prompt: promptText,
            onWrite: () => writeTtcEntry(context,
                kind: TtcEntryKind.feeling, prompt: promptText),
          ),
          const SizedBox(height: 28),

          // ---- the entries ---------------------------------------------------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: entries.isEmpty
                // A FEATURE IS NEVER HIDDEN: the empty page says what it is
                // for, and the prompt above is the way in.
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.journalEmptyTitle,
                          style: pvFraunces(fontSize: 20, color: pal.ink1)),
                      const SizedBox(height: 6),
                      Text(t.journalEmptyBody,
                          style: pvManrope(
                              fontSize: 14, height: 1.5, color: pal.ink2)),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tap an entry to read it.',
                          style: pvManrope(fontSize: 13, color: pal.ink3)),
                      const SizedBox(height: 4),
                      for (var i = 0; i < entries.length; i++) ...[
                        // ⚠️ A MONTH HEADING WHERE THE MONTH CHANGES
                        // (2026-09-27, tools rebuild). The date block says
                        // "MON 3" and nothing else, so two entries a month
                        // apart looked like the same week. MacroFactor's
                        // history heads each month the same way
                        // (https://mobbin.com/screens/8d35cd72-9428-4d6d-8466-5748f8840198).
                        if (i == 0 ||
                            entries[i].date.month !=
                                entries[i - 1].date.month ||
                            entries[i].date.year != entries[i - 1].date.year)
                          TtcJournalMonthHead(pal: pal, date: entries[i].date)
                        else
                          Divider(height: 1, thickness: 1, color: pal.line),
                        TtcJournalRow(
                          pal: pal,
                          entry: entries[i],
                          onTap: () =>
                              openTtcJournalEntry(context, entries[i]),
                        ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

/// "September 2026", above the first entry of each month. Public so a test can
/// find it.
class TtcJournalMonthHead extends StatelessWidget {
  const TtcJournalMonthHead({super.key, required this.pal, required this.date});

  final V2Palette pal;
  final DateTime date;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 2),
        child: Text('${_jMonths[date.month - 1]} ${date.year}',
            style: pvFraunces(fontSize: 18, color: pal.ink1)),
      );
}

/// This screen's one prompt, drawn as the pregnancy journal's question card
/// without its painting: a white card, a small grey eyebrow, the question in
/// the serif, one ink pill.
class _JournalPromptCard extends StatelessWidget {
  const _JournalPromptCard({
    required this.pal,
    required this.eyebrow,
    required this.prompt,
    required this.onWrite,
  });

  final V2Palette pal;
  final String eyebrow;
  final String prompt;
  final VoidCallback onWrite;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: pal.line),
            // Kept for revert (2026-09-27): a soft drop shadow. The base UI
            // is hairlines, not shadows; it was the one lifted card on a
            // flat page.
            //   boxShadow: const [BoxShadow(color: Color(0x0F000000),
            //       blurRadius: 20, offset: Offset(0, 6))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(eyebrow,
                  style: pvManrope(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                      color: pal.ink3)),
              const SizedBox(height: 8),
              Text(prompt,
                  style: pvFraunces(
                      fontSize: 21,
                      height: 1.3,
                      letterSpacing: -0.2,
                      color: pal.ink1)),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: onWrite,
                style: OutlinedButton.styleFrom(
                  foregroundColor: pal.ink1,
                  side: BorderSide(color: pal.line),
                  minimumSize: const Size(0, 42),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  shape: const StadiumBorder(),
                  textStyle:
                      pvManrope(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                child: const Text('Write about this'),
              ),
            ],
          ),
        ),
      );
}

/// One entry as a row on the page: the date block, a grey eyebrow, the words
/// in the serif. Public so a test can find it.
class TtcJournalRow extends StatelessWidget {
  const TtcJournalRow({
    super.key,
    required this.pal,
    required this.entry,
    required this.onTap,
  });

  final V2Palette pal;
  final TtcJournalEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final e = entry;
    final d = e.date;
    final hi = TtcS.current().hinglish;
    final eyebrow = [
      e.kind.label(hi).toUpperCase(),
      _jClock(d).toUpperCase(),
      if (e.author == TtcAuthor.partner) 'FROM YOUR PARTNER',
    ].join(' · ');

    return InkWell(
      onTap: onTap,
      // A long press opens it too: people who press and hold expect a menu,
      // and the entry's page is where its menu is.
      onLongPress: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            width: 44,
            child: Column(children: [
              Text(_jDays[d.weekday - 1],
                  style: pvManrope(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: pal.ink3)),
              Text('${d.day}',
                  style: pvFraunces(
                      fontSize: 24, height: 1.15, color: pal.ink1)),
            ]),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(eyebrow,
                      style: pvManrope(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.9,
                          color: pal.ink3)),
                  if (e.prompt != null) ...[
                    const SizedBox(height: 5),
                    Text(e.prompt!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: pvManrope(
                            fontSize: 13,
                            height: 1.4,
                            fontStyle: FontStyle.italic,
                            color: pal.ink3)),
                  ],
                  const SizedBox(height: 5),
                  Text(e.text,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: pvFraunces(
                          fontSize: 17.5, height: 1.4, color: pal.ink1)),
                  // "For the doctor" is marked where it is listed, so she
                  // can see these reach her appointments.
                  if (e.kind == TtcEntryKind.question) ...[
                    const SizedBox(height: 8),
                    _DoctorNote(pal: pal),
                  ],
                ]),
          ),
        ]),
      ),
    );
  }
}

/// The one line that says where a question for the doctor goes. The
/// Appointments page reads `doctorQuestions`, so the line is true.
class _DoctorNote extends StatelessWidget {
  const _DoctorNote({required this.pal});
  final V2Palette pal;

  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(Icons.event_note_outlined, size: 15, color: pal.ink2),
        const SizedBox(width: 6),
        Flexible(
          child: Text('Also on your Appointments page',
              style: pvManrope(
                  fontSize: 12.5, fontWeight: FontWeight.w700, color: pal.ink2)),
        ),
      ]);
}

// =============================================================================
//  One entry, opened to read
// =============================================================================

/// Opens one entry on its own page, to read. Edit and Delete live there.
Future<void> openTtcJournalEntry(BuildContext context, TtcJournalEntry entry) =>
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => TtcJournalEntryScreen(entryId: entry.id, initial: entry),
      settings: const RouteSettings(name: 'ttc/journal/entry'),
    ));

class TtcJournalEntryScreen extends StatelessWidget {
  const TtcJournalEntryScreen(
      {super.key, required this.entryId, required this.initial});

  final String entryId;

  /// Shown until the store has it (and after a delete, for the frame before
  /// the page closes).
  final TtcJournalEntry initial;

  TtcJournalEntry? get _live {
    for (final e in TtcJournalStore.instance.entries) {
      if (e.id == entryId) return e;
    }
    return null;
  }

  Future<void> _delete(BuildContext context, V2Palette pal) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Delete this entry?',
            style: pvFraunces(fontSize: 21, color: pal.ink1)),
        // Kept for revert (2026-09-27):
        //   "It will be gone from your journal, and you can't get it back."
        content: Text(
            'It comes off your journal for both of you. You can undo it '
            'straight after.',
            style: pvManrope(fontSize: 14.5, height: 1.45, color: pal.ink2)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Keep it', style: TextStyle(color: pal.ink1))),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete', style: TextStyle(color: _jDanger))),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    // ⚠️ A CONFIRM AND THEN AN UNDO (2026-09-27, tools rebuild). The confirm
    // stops a stray tap; the undo catches the "I meant the other one" a
    // confirm cannot, and a letter to a child is worth both. Same pair the
    // Appointments page uses. The dialog's old "you can't get it back" was
    // untrue once Undo existed, so it now says what goes.
    final gone = _live ?? initial;
    TtcJournalStore.instance.remove(entryId);
    pvSnack(context, 'Entry deleted.',
        action: 'Undo',
        onAction: () => TtcJournalStore.instance.restore(gone),
        lift: 24);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: Listenable.merge(
            [TtcJournalStore.instance, V2PaletteStore.instance]),
        builder: (context, _) {
          final pal = V2PaletteStore.instance.current;
          final e = _live ?? initial;
          final d = e.date;
          final mine = ttcJournalIsMine(e);
          final hi = TtcS.current().hinglish;

          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              foregroundColor: pal.ink1,
              elevation: 0,
              actions: [
                if (mine)
                  TextButton(
                    onPressed: () => writeTtcEntry(context,
                        kind: e.kind, prompt: e.prompt, editing: e),
                    child: Text('Edit',
                        style: pvManrope(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: pal.ink1)),
                  ),
                if (mine)
                  PopupMenuButton<String>(
                    tooltip: 'More',
                    icon: const Icon(Icons.more_horiz_rounded),
                    color: Colors.white,
                    onSelected: (v) {
                      if (v == 'delete') _delete(context, pal);
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(children: [
                          const Icon(Icons.delete_outline_rounded,
                              size: 20, color: _jDanger),
                          const SizedBox(width: 12),
                          Text('Delete entry',
                              style: pvManrope(
                                  fontSize: 14.5, color: _jDanger)),
                        ]),
                      ),
                    ],
                  ),
                const SizedBox(width: 4),
              ],
            ),
            body: ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 48),
              children: [
                Text(
                    [
                      '${_jWeekdays[d.weekday - 1]}, ${d.day} ${_jMonths[d.month - 1]}',
                      _jClock(d),
                    ].join('  ·  ').toUpperCase(),
                    style: pvManrope(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.9,
                        color: pal.ink3)),
                const SizedBox(height: 10),
                Row(children: [
                  Icon(ttcEntryIcon(e.kind), size: 22, color: pal.ink2),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(e.kind.label(hi),
                        style: pvFraunces(
                            fontSize: 28,
                            height: 1.2,
                            letterSpacing: -0.3,
                            color: pal.ink1)),
                  ),
                ]),
                if (e.prompt != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                    decoration: BoxDecoration(
                      color: pal.surfaceAlt,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(e.prompt!,
                        style: pvFraunces(
                            fontSize: 16,
                            height: 1.4,
                            fontStyle: FontStyle.italic,
                            color: pal.ink2)),
                  ),
                ],
                const SizedBox(height: 16),
                SelectableText(e.text,
                    style: pvManrope(
                        fontSize: 16.5, height: 1.65, color: pal.ink1)),
                const SizedBox(height: 18),
                if (e.kind == TtcEntryKind.question) ...[
                  _DoctorNote(pal: pal),
                  const SizedBox(height: 12),
                ],
                Text(
                    mine
                        ? 'Written by you.'
                        : 'Written by your partner. Only they can change it.',
                    style: pvManrope(fontSize: 13, color: pal.ink3)),
              ],
            ),
          );
        },
      );
}

// =============================================================================
//  The writer: a page, not a purple sheet
// =============================================================================

/// The one place an entry is written or changed, from Today, the home, the
/// chapter page, the partner screen or the journal itself.
///
/// [kind] is where the writer starts; she can change it inside. [editing]
/// opens an existing entry of hers to change its words.
Future<void> writeTtcEntry(
  BuildContext context, {
  required TtcEntryKind kind,
  String? prompt,
  TtcAuthor author = TtcAuthor.me,
  TtcJournalEntry? editing,
}) =>
    Navigator.of(context).push(MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => TtcJournalWriteScreen(
          kind: kind, prompt: prompt, author: author, editing: editing),
      settings: const RouteSettings(name: 'ttc/journal/write'),
    ));

class TtcJournalWriteScreen extends StatefulWidget {
  const TtcJournalWriteScreen({
    super.key,
    required this.kind,
    this.prompt,
    this.author = TtcAuthor.me,
    this.editing,
  });

  final TtcEntryKind kind;
  final String? prompt;
  final TtcAuthor author;
  final TtcJournalEntry? editing;

  @override
  State<TtcJournalWriteScreen> createState() => _TtcJournalWriteScreenState();
}

class _TtcJournalWriteScreenState extends State<TtcJournalWriteScreen> {
  late TtcEntryKind _kind = widget.editing?.kind ?? widget.kind;
  late final TextEditingController _text =
      TextEditingController(text: widget.editing?.text);

  bool get _editing => widget.editing != null;
  // An edit can change the kind as well as the words (2026-09-27), so either
  // one changing makes Save live. Kept for revert:
  //   (!_editing || _text.text.trim() != widget.editing!.text)
  bool get _canSave =>
      _text.text.trim().isNotEmpty &&
      (!_editing ||
          _text.text.trim() != widget.editing!.text ||
          _kind != widget.editing!.kind);
  bool get _dirty =>
      _text.text.trim() != (widget.editing?.text ?? '').trim() ||
      (_editing && _kind != widget.editing!.kind);

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _save() {
    if (!_canSave) return;
    pvCommitFeedback();
    if (_editing) {
      TtcJournalStore.instance
          .update(widget.editing!.id, text: _text.text, kind: _kind);
    } else {
      TtcJournalStore.instance.add(
        kind: _kind,
        text: _text.text,
        prompt: widget.prompt,
        author: widget.author,
      );
    }
    // She knows it saved, and where (2026-09-27). The writer is opened from
    // Today, the ritual and the chapter page as well as the journal, so the
    // notice names the journal.
    pvSnack(context, _editing ? 'Changes saved.' : 'Saved to Our journal.',
        icon: Icons.check_rounded, lift: 24);
    Navigator.of(context).pop();
  }

  /// Nothing silent: leaving with words typed asks first.
  Future<bool> _confirmLeave() async {
    if (!_dirty) return true;
    final pal = V2PaletteStore.instance.current;
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(_editing ? 'Leave without saving?' : 'Discard this entry?',
            style: pvFraunces(fontSize: 21, color: pal.ink1)),
        content: Text(
            _editing
                ? 'Your changes will not be kept.'
                : 'What you wrote will not be kept.',
            style: pvManrope(fontSize: 14.5, height: 1.45, color: pal.ink2)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Keep writing', style: TextStyle(color: pal.ink1))),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Discard', style: TextStyle(color: _jDanger))),
        ],
      ),
    );
    return leave == true;
  }

  @override
  Widget build(BuildContext context) {
    final pal = V2PaletteStore.instance.current;
    final hi = TtcS.current().hinglish;

    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmLeave() && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          foregroundColor: pal.ink1,
          elevation: 0,
          leading: IconButton(
            tooltip: 'Close',
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: Text(_editing ? 'Edit entry' : 'Write in your journal',
              style: pvManrope(
                  fontSize: 17, fontWeight: FontWeight.w700, color: pal.ink1)),
          actions: [
            TextButton(
              onPressed: _canSave ? _save : null,
              child: Text('Save',
                  style: pvManrope(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      color: _canSave ? pal.ink1 : pal.ink3)),
            ),
            const SizedBox(width: 4),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 40),
          children: [
            // ---- what kind of entry: a calm choice, not four purple circles
            // Shown when editing too (2026-09-27): an entry filed under the
            // wrong kind could not be moved. Kept for revert: `if (!_editing)`
            // around this, with a read-only kind row after it:
            //   else ...[ Row(children: [Icon(ttcEntryIcon(_kind)),
            //       Text(_kind.label(hi))]), const SizedBox(height: 16) ],
            ...[
              Text('What is this?',
                  style: pvManrope(
                      fontSize: 13, fontWeight: FontWeight.w700, color: pal.ink2)),
              const SizedBox(height: 10),
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final k in TtcEntryKind.values)
                  _KindPill(
                    pal: pal,
                    icon: ttcEntryIcon(k),
                    label: k.label(hi),
                    on: k == _kind,
                    onTap: () => setState(() => _kind = k),
                  ),
              ]),
              const SizedBox(height: 20),
            ],

            // ---- the prompt she tapped, carried into the entry -------------
            if (widget.prompt != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                decoration: BoxDecoration(
                  color: pal.surfaceAlt,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('WRITING ABOUT',
                          style: pvManrope(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                              color: pal.ink3)),
                      const SizedBox(height: 4),
                      Text(widget.prompt!,
                          style: pvFraunces(
                              fontSize: 17,
                              height: 1.35,
                              fontStyle: FontStyle.italic,
                              color: pal.ink1)),
                    ]),
              ),
              const SizedBox(height: 18),
            ],

            TextField(
              controller: _text,
              autofocus: true,
              onChanged: (_) => setState(() {}),
              minLines: 6,
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              style: pvFraunces(fontSize: 18, height: 1.5, color: pal.ink1),
              decoration: InputDecoration(
                hintText: TtcS.current().journalHint,
                hintStyle:
                    pvFraunces(fontSize: 18, height: 1.5, color: pal.ink3),
                // ⚠️ ALL THREE BORDERS, AND NO FILL (2026-09-27, build 11): the
                // app's InputDecorationTheme sets enabledBorder/focusedBorder,
                // which win over `border`, so a thick outline was drawn round
                // the words. A page to write on, not a form field.
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: 18),
            Divider(height: 1, thickness: 1, color: pal.line),
            const SizedBox(height: 14),
            if (_kind == TtcEntryKind.question) ...[
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Icon(Icons.event_note_outlined,
                      size: 16, color: pal.ink2),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                      'This also shows on your Appointments page, ready for '
                      'your next visit.',
                      style: pvManrope(
                          fontSize: 13, height: 1.45, color: pal.ink2)),
                ),
              ]),
              const SizedBox(height: 10),
            ],
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child:
                    Icon(Icons.visibility_outlined, size: 16, color: pal.ink3),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(ttcJournalWhoSees(TtcStore.instance.partnerJoined),
                    style: pvManrope(
                        fontSize: 13, height: 1.45, color: pal.ink3)),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

/// One kind, as a pill: ink when chosen, a hairline when not. The base UI's
/// pill, never the brand colour.
class _KindPill extends StatelessWidget {
  const _KindPill({
    required this.pal,
    required this.icon,
    required this.label,
    required this.on,
    required this.onTap,
  });

  final V2Palette pal;
  final IconData icon;
  final String label;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        selected: on,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: on ? pal.ink1 : Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: on ? pal.ink1 : pal.line),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, size: 16, color: on ? Colors.white : pal.ink2),
              const SizedBox(width: 7),
              Text(label,
                  style: pvManrope(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: on ? Colors.white : pal.ink1)),
            ]),
          ),
        ),
      );
}

// =============================================================================
//  Kept for revert (2026-09-27): the page as it was before the redraw
// =============================================================================

/// The page before the 2026-09-27 redraw. Kept for revert; nothing pushes it.
class TtcJournalScreenClassic extends StatelessWidget {
  const TtcJournalScreenClassic({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation:
          Listenable.merge([
        TtcJournalStore.instance,
        TtcLang.instance,
        // For the "who can see this" line, which changes when he joins.
        TtcStore.instance,
      ]),
      builder: (context, _) {
        final t = TtcS.current();
        final hi = t.hinglish;
        final entries = TtcJournalStore.instance.entries;
        return Scaffold(
          backgroundColor: ttcBg,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                  ttcGutter, 8, ttcGutter, ttcBottomInset),
              children: [
                TtcBackBar(title: t.journalTitle),
                const SizedBox(height: 10),
                // ⚠️ WHAT THIS IS, AND WHO SEES IT (tools pass, 2026-09-27).
                // It said "you can both write here" but never that the
                // partner reads everything, which is a painful surprise to
                // find out after writing something private.
                Text('A notebook for the two of you. Tap one below to write.',
                    style: ttcBody(14, color: ttcInk, h: 1.5)),
                const SizedBox(height: 6),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 1),
                    child: Icon(Icons.visibility_outlined,
                        size: 15, color: ttcMuted),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(ttcJournalWhoSees(TtcStore.instance.partnerJoined),
                        style: ttcBody(12.5, color: ttcSoft, h: 1.45)),
                  ),
                ]),
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
                              // 10.5 → 11.5 (2026-09-27): labels read small.
                              style: ttcBody(11.5, w: FontWeight.w700, h: 1.25)),
                        ]),
                      ),
                    ),
                    if (kind != TtcEntryKind.values.last)
                      const SizedBox(width: 8),
                  ],
                ]),
                const SizedBox(height: 22),

                if (entries.isEmpty) ...[
                  TtcEmpty(
                    icon: Icons.auto_stories_outlined,
                    title: t.journalEmptyTitle,
                    body: t.journalEmptyBody,
                  ),
                  const SizedBox(height: 14),
                  // Sixteen prompts were written for this stage and none of
                  // them reached the screen that says "write here". A blank
                  // page is the hardest possible ask of someone who is anxious
                  // or low, and the answer was already sitting in data.
                  _PromptNudge(t: t),
                ]
                else ...[
                  Text('Tap an entry to read it, change it or delete it.',
                      style: ttcBody(12, color: ttcMuted, h: 1.4)),
                  const SizedBox(height: 10),
                  for (final e in entries) ...[
                    _EntryCard(entry: e, t: t),
                    const SizedBox(height: 11),
                  ],
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
    // ⚠️ A TAP READS, IT NEVER DELETES (tools pass, 2026-09-27). A tap used to
    // open "Delete this entry?", the one thing nobody taps a letter to their
    // child to do. Now a tap (or a long press) opens the entry to read, with
    // Edit for her own words and Delete behind its own confirm. Mobbin: Noom's
    // entry detail (Update first, Delete as a separate confirmed step),
    // Substack's options sheet (Delete last, in red).
    // Kept for revert:
    //   onTap: () => _confirmDelete(context),
    return GestureDetector(
      onLongPress: () => openTtcJournalEntry(context, entry),
      child: TtcCard(
      onTap: () => openTtcJournalEntry(context, entry),
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
        // Four lines in the list; the whole entry opens on tap.
        Text(entry.text,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: ttcBody(14, color: ttcInk, h: 1.6)),
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
      ),
    );
  }

  // Kept for revert (2026-09-27): the old tap handler. Its dialog moved, word
  // for word, into `_confirmTtcJournalDelete` below, which the entry reader
  // calls.
  //   Future<void> _confirmDelete(BuildContext context) async {
  //     final ok = await _confirmTtcJournalDelete(context, t);
  //     if (ok) TtcJournalStore.instance.remove(entry.id);
  //   }

  static String _fmt(DateTime d, bool hi) {
    const m = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${m[d.month - 1]}';
  }
}

// Kept for revert (2026-09-27): the classic delete confirm, now on the
// entry page (`TtcJournalEntryScreen._delete`).
// /// The delete confirm. Deleting a journal entry cannot be undone, so it is
// /// always asked, never done on one tap.
// Future<bool> _confirmTtcJournalDelete(BuildContext context, TtcS t) async {
//   final ok = await showDialog<bool>(
//     context: context,
//     builder: (ctx) => AlertDialog(
//       backgroundColor: Colors.white,
//       shape:
//           RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
//       title: Text(t.journalDelete, style: ttcJakarta(16)),
//       content: Text(
//         t.hinglish
//             ? 'Ye wapas nahi aayega.'
//             : "Once it's deleted, you can't get it back.",
//         style: ttcBody(13.5),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.of(ctx).pop(false),
//           child: Text(t.journalCancel,
//               style: ttcBody(13, color: ttcSoft, w: FontWeight.w700)),
//         ),
//         TextButton(
//           onPressed: () => Navigator.of(ctx).pop(true),
//           child: Text(t.journalDelete,
//               style: ttcBody(13,
//                   color: const Color(0xFFD92D20), w: FontWeight.w800)),
//         ),
//       ],
//     ),
//   );
//   return ok == true;
// }

// ---- the writer -------------------------------------------------------------

/// The purple writing sheet before the 2026-09-27 redraw. Kept for revert;
/// nothing calls it. `writeTtcEntry` above is the one entry point.
Future<void> writeTtcEntryClassic(
  BuildContext context, {
  required TtcEntryKind kind,
  String? prompt,
  TtcAuthor author = TtcAuthor.me,
}) async {
  final text = await _showTtcWriter(context, kind: kind, prompt: prompt);
  // An empty entry is silently not saved rather than erroring - tapping save
  // on nothing is a change of mind, not a mistake worth a message.
  if (text != null) {
    TtcJournalStore.instance.add(
      kind: kind,
      text: text,
      prompt: prompt,
      author: author,
    );
  }
}

/// The old writing sheet. Returns the words when she saved something
/// non-empty, else null.
Future<String?> _showTtcWriter(
  BuildContext context, {
  required TtcEntryKind kind,
  String? prompt,
  String? initialText,
}) async {
  final t = TtcS.current();
  final controller = TextEditingController(text: initialText);
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
          // Where a question for the doctor goes, so she knows it is not
          // lost in a diary. Appointments reads `doctorQuestions`.
          if (kind == TtcEntryKind.question) ...[
            const SizedBox(height: 10),
            Text(
                'This also shows on your Appointments page, ready for your '
                'next visit.',
                style: ttcBody(12, color: ttcSoft, h: 1.4)),
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

  final text = controller.text.trim();
  controller.dispose();
  return saved == true && text.isNotEmpty ? text : null;
}

/// One prompt, offered rather than required.
///
/// Phrased as something to answer if she wants to, never as a task - this
/// stage has no streaks and nothing that counts against her for skipping.
class _PromptNudge extends StatelessWidget {
  const _PromptNudge({required this.t});

  final TtcS t;

  @override
  Widget build(BuildContext context) {
    final prompt = ttcPromptForToday(TtcStore.instance.today.chapter);
    final text = prompt.text(t.hinglish);
    // ⚠️ THE PROMPT OPENS THE WRITER WITH ITSELF ATTACHED (tools pass,
    // 2026-09-27). She read a good prompt and then had to pick a kind and
    // remember it; the prompt never reached the entry. Same kind and shape as
    // Today's and the chapter page's prompt cards.
    return TtcCard(
      color: ttcPanel,
      onTap: () =>
          writeTtcEntry(context, kind: TtcEntryKind.feeling, prompt: text),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Kept for revert (2026-09-27): uppercase eyebrow.
        //   Text(t.journalPromptEyebrow.toUpperCase(), style: ttcBody(9.5, ...)),
        Text(t.journalPromptEyebrow,
            style: ttcBody(11.5, color: ttcPurple, w: FontWeight.w800)),
        const SizedBox(height: 8),
        Text(text,
            style: ttcBody(14, color: ttcInk, h: 1.55, w: FontWeight.w600)),
        const SizedBox(height: 12),
        Row(children: [
          const Icon(Icons.edit_outlined, size: 16, color: ttcPurple),
          const SizedBox(width: 7),
          Text('Write about this',
              style: ttcBody(13, color: ttcPurple, w: FontWeight.w800)),
        ]),
      ]),
    );
  }
}
