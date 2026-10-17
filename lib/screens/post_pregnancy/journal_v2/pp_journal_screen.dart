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
//
//  ONE BOOK, TWO STAGES (2026-10-17). The user: the two journals "look as
//  separate things… it looks like something else was built." This page now
//  draws the pregnancy journal's keepsake from journal_keepsake.dart: the
//  paper, the cover with "Dear <name>,", a dot strip (the child's twelve
//  months, where pregnancy has forty weeks), a question for the child's age,
//  months as sections led by their photo, and each memory opening as a page
//  (PpJournalEntryScreen, `pp/journal/entry`) instead of a sheet. The data is
//  untouched. The tool-shell page is `_buildToolShell`, kept for revert.
// =============================================================================

import 'package:flutter/material.dart';

import '../../../data/pp_journal_prompts.dart';
import '../../../data/reads/read_images.dart' show readImageFor;
import '../../../widgets/journal/journal_keepsake.dart';
import '../../../widgets/pv_toast.dart';
import '../../../widgets/storage_image.dart';

import '../../v2/v2_palette.dart' show V2Palette, V2PaletteStore;
import '../pp_child_profile.dart';
import 'journal_capture_screens.dart';
import 'jv2_common.dart';
import 'jv2_data.dart';
import 'jv2_store.dart';
import '../../../theme/pv_fonts.dart';
import '../../brackets/hub/hub_intent_art.dart' show IntentMark;
import '../../pregnancy/preg_tool_chrome.dart';
import '../../products/pv_store_chrome.dart' show PvChip, PvCommit, pvStorePalette;
import '../../../widgets/pv_feedback.dart' show PvPress, pvCommitFeedback;

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

/// Whole calendar months old on [day], never below 0. The same count
/// [ppAgeOn] uses, so the dot a memory fills and the age it is labelled with
/// agree.
int ppMonthsOn(DateTime day, DateTime dob) {
  var months = (day.year - dob.year) * 12 + day.month - dob.month;
  if (day.day < dob.day) months--;
  return months < 0 ? 0 : months;
}

/// What kind of memory, in the words the eyebrow uses.
String ppJournalKind(JvKind k) => switch (k) {
      JvKind.letter => 'Letter',
      JvKind.story => 'Story',
      JvKind.guided => 'A first',
      JvKind.moment => 'Moment',
    };

/// Opens one memory as a page, laid down rather than pushed: it fades in
/// while the photo travels (Hero), as the pregnancy journal's entries do.
void openPpJournalEntry(BuildContext context, PpJournalEntry e, {bool replace = false}) {
  final route = PageRouteBuilder<void>(
    settings: const RouteSettings(name: 'pp/journal/entry'),
    transitionDuration: const Duration(milliseconds: 420),
    reverseTransitionDuration: const Duration(milliseconds: 320),
    pageBuilder: (_, _, _) => PpJournalEntryScreen(entryId: e.id),
    transitionsBuilder: (_, a, _, child) => FadeTransition(
      opacity: CurvedAnimation(parent: a, curve: Curves.easeOutCubic),
      child: child,
    ),
  );
  if (replace) {
    Navigator.of(context).pushReplacement(route);
  } else {
    Navigator.of(context).push(route);
  }
}

class PpJournalScreen extends StatefulWidget {
  const PpJournalScreen({super.key});

  @override
  State<PpJournalScreen> createState() => _PpJournalScreenState();
}

class _PpJournalScreenState extends State<PpJournalScreen> with SingleTickerProviderStateMixin {
  final _store = PpJournalStore.instance;
  final _scroll = ScrollController();
  int _skip = 0; // "another question"
  bool _collapsed = false;

  /// The floating "Add a memory" waits until the question card, which has its
  /// own Write it, has scrolled away: the pregnancy journal's rule.
  bool _fab = false;

  /// One clock for the opening: the dots fill, then the months rise.
  late final AnimationController _opening =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..forward();

  static const double _coverHeight = 420;

  @override
  void initState() {
    super.initState();
    _store.init();
    _scroll.addListener(() {
      final c = _scroll.hasClients && _scroll.offset > _coverHeight - kToolbarHeight - 40;
      final f = _scroll.hasClients && _scroll.offset > _coverHeight + 360;
      if (c != _collapsed || f != _fab) {
        setState(() {
          _collapsed = c;
          _fab = f;
        });
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    _opening.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_store, ChildProfileStore.instance, V2PaletteStore.instance]),
      builder: (context, _) => _buildBook(context),
    );
  }

  Widget _buildBook(BuildContext context) {
    final pal = V2PaletteStore.instance.current;
    final child = ChildProfileStore.instance;
    final dob = child.dob;
    final now = DateTime.now();
    final months = ppMonthsOn(now, dob);
    final list = _store.entries;
    final name = child.nameMid;
    final named = name != 'your baby';

    // Months as sections, newest first; this month is always there, so the
    // page has somewhere to start even before the first memory.
    final thisMonth = DateTime(now.year, now.month);
    final groups = <DateTime, List<PpJournalEntry>>{thisMonth: []};
    for (final e in list) {
      groups.putIfAbsent(DateTime(e.createdAt.year, e.createdAt.month), () => []).add(e);
    }
    final keys = groups.keys.toList()..sort((a, b) => b.compareTo(a));

    // The dots: this year of the child's life, one per month. Filled where
    // something was kept.
    final year = months ~/ 12;
    final kept = <int>{
      for (final e in list)
        if (ppMonthsOn(e.createdAt, dob) ~/ 12 == year) ppMonthsOn(e.createdAt, dob) % 12 + 1,
    };

    String? cover;
    for (final e in list) {
      if (e.photoPath != null) {
        cover = e.photoPath;
        break;
      }
    }
    // A painting per stretch of childhood once the art is in the table
    // (`pp_journal_cover_b1..3`, STILL-OPEN §77.1), the drawn sky until then.
    final band = months < 12 ? 1 : (months < 36 ? 2 : 3);
    final onPhoto = cover != null && !_collapsed;
    final barInk = onPhoto ? Colors.white : pal.ink1;

    return Scaffold(
      backgroundColor: kJournalPaper,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: IgnorePointer(
        ignoring: !_fab,
        child: AnimatedSlide(
          offset: _fab ? Offset.zero : const Offset(0, 2),
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          child: AnimatedOpacity(
            opacity: _fab ? 1 : 0,
            duration: const Duration(milliseconds: 200),
            child: FloatingActionButton.extended(
              key: const ValueKey('pp_journal_add'),
              heroTag: 'pp_journal_add',
              onPressed: () {
                pvCommitFeedback();
                showAddMemorySheet(context);
              },
              backgroundColor: pal.ink1,
              foregroundColor: pal.surface,
              elevation: 2,
              shape: const StadiumBorder(),
              icon: const Icon(Icons.add_rounded),
              label: Text('Add a memory', style: pvManrope(fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
        ),
      ),
      body: CustomScrollView(
        controller: _scroll,
        slivers: [
          SliverAppBar(
            pinned: true,
            stretch: true,
            expandedHeight: _coverHeight,
            backgroundColor: kJournalPaper,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            foregroundColor: barInk,
            iconTheme: IconThemeData(color: barInk, shadows: [
              if (onPhoto) const Shadow(color: Colors.black38, blurRadius: 8),
            ]),
            title: AnimatedOpacity(
              opacity: _collapsed ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: Text(named ? "$name's journal" : 'My Journal', style: pvFraunces(fontSize: 20, color: pal.ink1)),
            ),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              stretchModes: const [StretchMode.zoomBackground, StretchMode.fadeTitle],
              background: JournalCover(
                key: const ValueKey('pp_journal_cover'),
                pal: pal,
                photo: cover,
                painting: readImageFor('pp_journal_cover_b$band'),
                artVariant: band + 2,
                eyebrow: 'MY JOURNAL  ·  ${child.ageLabel.toUpperCase()} OLD',
                salutation: named ? 'Dear $name,' : 'Dear little one,',
                signoff: 'Everything I kept for you as you grew.',
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 22),
              JournalDotStrip(
                pal: pal,
                count: 12,
                perRow: 12,
                current: months % 12 + 1,
                kept: kept,
                open: _opening,
                headline: year == 0 ? 'First year' : 'Year ${year + 1}',
                headlineMuted: '',
                right: '${child.ageLabel} old',
                keptLegend: 'A month with a memory',
                nowLegend: 'This month',
                dotSize: 14,
              ),
              const SizedBox(height: 26),
              JournalQuestionCard(
                key: const ValueKey('pp_journal_question'),
                pal: pal,
                eyebrow: 'A QUESTION FOR THIS MONTH',
                question: ppJournalPromptFor(months, skip: _skip),
                art: readImageFor('pp_journal_question_b$band'),
                artVariant: months + 7,
                canTurn: ppJournalPromptCount(months) > 1,
                skip: _skip,
                sub: ppPromptBandFor(months).note,
                onWrite: (q) => Navigator.of(context).push(MaterialPageRoute<void>(
                  settings: const RouteSettings(name: 'pp/journal/capture'),
                  builder: (_) => QuickCaptureScreen(prompt: q),
                )),
                onAnother: () => setState(() => _skip++),
              ),
              const SizedBox(height: 10),
            ]),
          ),
          SliverList.builder(
            itemCount: keys.length,
            itemBuilder: (_, i) {
              final k = keys[i];
              return JournalRise(
                open: _opening,
                index: i,
                child: _monthSection(context, pal, k, groups[k]!, k == thisMonth, now, dob, list.isEmpty, name),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  Widget _monthSection(BuildContext context, V2Palette pal, DateTime month, List<PpJournalEntry> entries, bool current,
      DateTime now, DateTime dob, bool nothingYet, String name) {
    final title = _months[month.month - 1] + (month.year == now.year ? '' : ' ${month.year}');
    final age = '${entries.isEmpty ? ChildProfileStore.instance.ageLabel : ppAgeOn(entries.first.createdAt, dob)} old';
    String? photo;
    for (final e in entries) {
      if (e.photoPath != null) {
        photo = e.photoPath;
        break;
      }
    }
    final n = entries.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        JournalSectionHead(
          pal: pal,
          title: title,
          current: current,
          currentLabel: 'THIS MONTH',
          range: age,
          photoEyebrow: '${title.toUpperCase()}  ·  ${age.toUpperCase()}${current ? '  ·  THIS MONTH' : ''}',
          summary: n == 0 ? '' : '$n ${n == 1 ? 'memory' : 'memories'}',
          photo: photo,
        ),
        const SizedBox(height: 4),
        if (entries.isEmpty)
          // ⚠️ A FEATURE IS NEVER HIDDEN. The month with nothing in it asks,
          // once, in its own words; the question card above is the rest.
          InkWell(
            key: const ValueKey('pp_journal_empty'),
            onTap: () => showAddMemorySheet(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(children: [
                Expanded(
                  child: Text(
                      nothingYet
                          ? 'Your first memory of $name goes here. Start with the question above, or anything at all.'
                          : 'Nothing kept this month yet. Start with the question above, or anything at all.',
                      style: pvManrope(fontSize: 14, height: 1.5, color: pal.ink2)),
                ),
                const SizedBox(width: 12),
                Icon(Icons.arrow_forward_rounded, size: 20, color: pal.ink1),
              ]),
            ),
          )
        else
          for (var i = 0; i < entries.length; i++) ...[
            if (i > 0 || photo == null) Divider(height: 1, thickness: 1, color: pal.line),
            _row(context, pal, entries[i]),
          ],
      ]),
    );
  }

  Widget _row(BuildContext context, V2Palette pal, PpJournalEntry e, {bool replace = false}) => KeyedSubtree(
        key: ValueKey('pp_journal_card_${e.id}'),
        child: ppJournalRow(context, pal, e, onTap: () => openPpJournalEntry(context, e, replace: replace)),
      );

  // ---- the tool-shell page (2026-10-07), kept for revert --------------------
  //  The journal on the shell every TTC and pregnancy tool wears: one ink
  //  "Add a memory" instead of the purple floating button, month headings,
  //  white cards. Mobbin: month headings over dated entries, after 5 Minute
  //  Journal (mobbin.com/screens/59059226-c8cc-4e04-a48f-f32331a83c20); a
  //  photo, a title and one meta line per memory, after Paired's timeline
  //  (mobbin.com/screens/0d97143e-8b97-4697-bb75-75bedf45c9fb). A partner's
  //  memory says so in its meta line. `_buildBeforeShell` is the page before.
  // ignore: unused_element
  Widget _buildToolShell(BuildContext context) {
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
    final kind = ppJournalKind(e.kind);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
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
    final kind = ppJournalKind(e.kind);
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

  // ---- the entry sheet (2026-10-07), kept for revert ------------------------
  //  A memory opens as a page now (PpJournalEntryScreen, 2026-10-17). This was
  //  the white sheet: Manrope meta, a Fraunces title, the words in Manrope 15,
  //  and Delete as a quiet ink text button. The partner rule is the same on
  //  the page. `_openBeforeShell` is the sheet before this one.
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
                if (e.fromPartner)
                  Text('Added by your partner. Only they can change it.',
                      style: pvManrope(fontSize: 13, fontWeight: FontWeight.w600, color: p.ink2))
                else
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      style: TextButton.styleFrom(foregroundColor: p.ink1),
                      onPressed: () async {
                        if (await ppConfirmDelete(ctx, p)) {
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

/// One memory as a row on the page: the shared JournalPageRow, with the kind,
/// the age on the day and the partner in the eyebrow.
Widget ppJournalRow(BuildContext context, V2Palette pal, PpJournalEntry e, {required VoidCallback onTap}) {
  final dob = ChildProfileStore.instance.dob;
  return JournalPageRow(
    pal: pal,
    date: e.createdAt,
    eyebrow: [
      ppJournalKind(e.kind),
      ppAgeOn(e.createdAt, dob),
      if (e.fromPartner) 'From your partner',
    ].join(' · ').toUpperCase(),
    title: e.title,
    body: e.body,
    photos: [?e.photoPath],
    heroId: e.id,
    onTap: onTap,
  );
}

/// "Delete this memory?" — the same words the sheet asked with.
Future<bool> ppConfirmDelete(BuildContext context, V2Palette p) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (dctx) => AlertDialog(
      backgroundColor: Colors.white,
      title: Text('Delete this memory?', style: pvFraunces(fontSize: 20, fontWeight: FontWeight.w600, color: p.ink1)),
      content: Text('It will be gone from your journal on every phone. This cannot be undone.',
          style: pvManrope(fontSize: 14, height: 1.5, color: p.ink2)),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(dctx).pop(false),
            child: Text('Keep it', style: pvManrope(fontSize: 14, fontWeight: FontWeight.w700, color: p.ink1))),
        TextButton(
            onPressed: () => Navigator.of(dctx).pop(true),
            child: Text('Delete', style: pvManrope(fontSize: 14, fontWeight: FontWeight.w700, color: p.ink2))),
      ],
    ),
  );
  return ok == true;
}

// =============================================================================
//  One memory, opened to read (2026-10-17)
// -----------------------------------------------------------------------------
//  The pregnancy journal's entry page (JournalEntryScreen), for a child: the
//  photo first, then the day and his age on it, the title in serif, the words.
//  Under it, the rest of that month, each a tap away (⚠️ NO EMPTY SCREENS).
//  A partner's memory is shown, never changed here: no Delete, and the note
//  saying whose it is.
// =============================================================================

class PpJournalEntryScreen extends StatelessWidget {
  const PpJournalEntryScreen({super.key, required this.entryId});
  final String entryId;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([PpJournalStore.instance, V2PaletteStore.instance]),
      builder: (context, _) {
        final pal = V2PaletteStore.instance.current;
        final all = PpJournalStore.instance.entries;
        PpJournalEntry? e;
        for (final x in all) {
          if (x.id == entryId) e = x;
        }
        // Deleted from here or from another phone: nothing to read.
        if (e == null) return const Scaffold(backgroundColor: kJournalPaper);
        final entry = e;
        final d = entry.createdAt;
        final dob = ChildProfileStore.instance.dob;
        final others = [
          for (final o in all)
            if (o.id != entry.id && o.createdAt.year == d.year && o.createdAt.month == d.month) o,
        ];
        return Scaffold(
          key: const ValueKey('pp_journal_entry_page'),
          backgroundColor: kJournalPaper,
          appBar: AppBar(
            backgroundColor: kJournalPaper,
            surfaceTintColor: Colors.transparent,
            foregroundColor: pal.ink1,
            elevation: 0,
            actions: [
              if (!entry.fromPartner)
                IconButton(
                  key: const ValueKey('pp_journal_delete'),
                  tooltip: 'Delete',
                  icon: const Icon(Icons.delete_outline_rounded),
                  onPressed: () async {
                    if (!await ppConfirmDelete(context, pal)) return;
                    await PpJournalStore.instance.remove(entry.id);
                    if (context.mounted) {
                      pvToast(context, 'Memory deleted');
                      Navigator.of(context).maybePop();
                    }
                  },
                ),
              const SizedBox(width: 4),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 48),
            children: [
              if (entry.photoPath != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: AspectRatio(
                    aspectRatio: 4 / 5,
                    child: Hero(
                      tag: journalHeroTag(entry.id),
                      child: StorageImage(entry.photoPath!, fit: BoxFit.cover, borderRadius: BorderRadius.circular(18)),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
              ],
              journalPad(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                    [
                      '${kJournalWeekdays[d.weekday - 1]}, ${d.day} ${_months[d.month - 1]}',
                      '${ppAgeOn(d, dob)} old',
                      if (entry.fromPartner) 'From your partner',
                    ].join('  ·  ').toUpperCase(),
                    style: pvManrope(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.9, color: pal.ink3)),
                const SizedBox(height: 10),
                Text(entry.title.isNotEmpty ? entry.title : ppJournalKind(entry.kind),
                    style: pvFraunces(fontSize: 30, height: 1.2, letterSpacing: -0.3, color: pal.ink1)),
                if (entry.body.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  SelectableText(entry.body,
                      style: entry.kind == JvKind.letter
                          ? pvFraunces(fontSize: 18, height: 1.7, fontStyle: FontStyle.italic, color: pal.ink1)
                          : pvManrope(fontSize: 16.5, height: 1.65, color: pal.ink1)),
                ],
                if (entry.fromPartner) ...[
                  const SizedBox(height: 22),
                  Text('Added by your partner. Only they can change it.',
                      key: const ValueKey('pp_journal_partner_note'),
                      style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w600, color: pal.ink2)),
                ],
              ])),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Divider(height: 1, thickness: 1, color: pal.line),
                  const SizedBox(height: 26),
                  Text(_months[d.month - 1], style: pvFraunces(fontSize: 26, color: pal.ink1)),
                  const SizedBox(height: 8),
                  if (others.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Text('The only thing kept that month.', style: pvManrope(fontSize: 14, color: pal.ink2)),
                    )
                  else ...[
                    Text(others.length == 1 ? 'ALSO THAT MONTH' : 'ALSO THAT MONTH  ·  ${others.length} MORE',
                        style: pvManrope(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.1, color: pal.ink3)),
                    for (var i = 0; i < others.length; i++) ...[
                      if (i > 0) Divider(height: 1, thickness: 1, color: pal.line),
                      // The next page replaces this one, so back returns to the
                      // journal rather than walking back through every page.
                      ppJournalRow(context, pal, others[i],
                          onTap: () => openPpJournalEntry(context, others[i], replace: true)),
                    ],
                  ],
                ]),
              ),
            ],
          ),
        );
      },
    );
  }
}
