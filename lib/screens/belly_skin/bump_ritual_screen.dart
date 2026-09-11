// =============================================================================
//  The bump ritual — the album
// -----------------------------------------------------------------------------
//  Sub-tab 4 of the Belly & skin door, rendered in place, and the standalone
//  screen every other caller opens. Built from the Claude Design board
//  `Bump Ritual.dc.html` (project b107ecc8…, 2026-09-11), direction **1a**,
//  drawn against `docs/design-prompts/BUMP-RITUAL-DESIGN-PROMPT.md`.
//
//  ⚠️ THIS REPLACES `BumpJourneyScreen` AS THE FRONT, NOT THE STORE. The old
//  screen (`bump_journey_screen.dart`, pre-V2, 981 lines) stays in the tree
//  for revert and is no longer wired. Every keepsake behaviour it had —
//  capture, captions, favourites, delete, the book, the journal mirror — lives
//  in `BumpStore` and `BumpBookScreen`, and this file uses those unchanged.
//  What changed is what the photos sit in.
//
//  ---------------------------------------------------------------------------
//  ⚠️ WHAT THE DESIGN DECIDED, KEPT WHOLE
//  ---------------------------------------------------------------------------
//
//    · **The photo leads.** One week a page, newest first, four-by-five.
//      Nothing on the screen is louder than her picture.
//    · **Missing weeks are simply not drawn.** A photo album has no blank
//      pages for days you did not take a picture. No slot, no dated line, no
//      invitation to backfill.
//    · **The four moments are written, not awarded.** "Halfway. Twenty weeks
//      behind you, twenty ahead." sits in line beside the week it belongs to.
//      The ones still ahead are stated as facts under "Still ahead". No
//      trophy, no badge.
//    · **No count as a score, no percentage, no streak.** The header says
//      which weeks the book runs from and to, and whether this week is in it.
//      That is a description, not a progress state.
//    · **Buttons are white with a hairline.** The old screen's coral and
//      purple are gone; the only colour is the tab's amber, as a tint.
//    · **The book is a row at the end of the scroll**, opening to the three
//      things it does. It used to be a gradient banner above her photos.
//
//  ⚠️ THE TIMELINE IS 1b's ALBUM, NOT 1a's LONG SCROLL — DECIDED ON THE PHONE.
//  1a's one-photo-a-page was built first and looked, with real photos, like a
//  wall: full-width four-by-fives, one after another, for as many weeks as she
//  has. The user: *"what if the person has done it for every week? They keep
//  scrolling with such big images thrown at their face."* Right. So the top of
//  the tab is 1a — the header, the add card, Then & Now — and under "Your
//  weeks" it is 1b: trimester bands, each a quiet heading with its moment
//  written into it, and a two-up grid of weeks read forward like a book. A
//  photo opens full-bleed on tap, which is where the big picture belongs.
//
//  ⚠️ ONE DEPARTURE FROM THE BOARD: the design's "Save as one image" on Then
//  & Now had no behaviour behind it (the board cannot save files). Here it
//  renders the pair to a PNG and hands it to the share sheet — which is the
//  thing she actually does with a Then & Now: sends it to someone. And what
//  she sees on the screen IS what gets saved: the same card, in a
//  `RepaintBoundary`, so there is no surprise in the share sheet.
// =============================================================================

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';

import '../../models/bump_photo.dart';
import '../../services/bump_store.dart';
import '../../services/pregnancy_controller.dart';
import '../../theme/pv_fonts.dart';
import '../../widgets/storage_image.dart';
import '../bump_book_screen.dart';
import '../doors/pv_door_chrome.dart';
import '../v2/v2_palette.dart';

/// This tab's hue — the soft amber the coverflow card wears.
const double kBumpRitualHue = 26;

/// The four moments, in the design's words. `ahead` is how it reads under
/// "Still ahead"; `passed` is the two lines written beside the week once it
/// is behind her.
const List<({int week, String ahead, String passedTitle, String passedLine})>
    kBumpMoments = [
  (
    week: 12,
    ahead: 'The first trimester ends',
    passedTitle: 'The first trimester ended here.',
    passedLine: 'Week 12.',
  ),
  (
    week: 20,
    ahead: 'Halfway',
    passedTitle: 'Halfway.',
    passedLine: 'Twenty weeks behind you, twenty ahead.',
  ),
  (
    week: 28,
    ahead: 'The third trimester begins',
    passedTitle: 'The third trimester began here.',
    passedLine: 'Week 28.',
  ),
  (
    week: 37,
    ahead: 'Full term',
    passedTitle: 'Full term.',
    passedLine: 'Week 37. From here, any day.',
  ),
];

const List<String> _captionSuggestions = [
  'Same window',
  'Kicks all night',
  'Feeling big',
];

const _monthsShort = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];
const _daysShort = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

/// "Tue, 25 Aug" — the design's date shape. No `intl` in this app.
String bumpDate(DateTime d) =>
    '${_daysShort[d.weekday - 1]}, ${d.day} ${_monthsShort[d.month - 1]}';

/// "Twenty-four weeks". Weeks run 4–42 here; anything else falls back to the
/// digits rather than producing a wrong word.
String weeksInWords(int n) {
  const ones = [
    '', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine',
    'ten', 'eleven', 'twelve', 'thirteen', 'fourteen', 'fifteen', 'sixteen',
    'seventeen', 'eighteen', 'nineteen',
  ];
  const tens = ['', '', 'twenty', 'thirty', 'forty'];
  String w;
  if (n < 20) {
    w = ones[n];
  } else if (n < 50) {
    w = tens[n ~/ 10] + (n % 10 == 0 ? '' : '-${ones[n % 10]}');
  } else {
    w = '$n';
  }
  if (w.isEmpty) w = '$n';
  return '${w[0].toUpperCase()}${w.substring(1)} weeks';
}

// -----------------------------------------------------------------------------
//  The standalone screen — the door family's chrome around the same body
// -----------------------------------------------------------------------------

class BumpRitualScreen extends StatelessWidget {
  const BumpRitualScreen({super.key, required this.controller});

  final PregnancyController controller;

  @override
  Widget build(BuildContext context) => PvDoorToolScaffold(
        hue: kBumpRitualHue,
        eyebrow: 'Belly & skin',
        title: 'The bump ritual',
        intro: 'One photo a week, in the same spot. By week 40 you will have a '
            'book you can flip through — and later, show your child.',
        children: [pvDoorPad(BumpRitualBody(controller: controller))],
      );
}

// -----------------------------------------------------------------------------
//  The body
// -----------------------------------------------------------------------------

class BumpRitualBody extends StatefulWidget {
  const BumpRitualBody({super.key, required this.controller});

  final PregnancyController controller;

  @override
  State<BumpRitualBody> createState() => _BumpRitualBodyState();
}

class _BumpRitualBodyState extends State<BumpRitualBody> {
  PregnancyController get c => widget.controller;

  @override
  void initState() {
    super.initState();
    BumpStore.instance.init();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: Listenable.merge([BumpStore.instance, V2PaletteStore.instance]),
        builder: (context, _) {
          final p = V2PaletteStore.instance.current;
          final store = BumpStore.instance;
          final week = c.currentWeek;
          final photos = store.photos.reversed.toList(); // newest first
          final thisWeekIn = store.hasWeek(week);

          if (photos.isEmpty) {
            return _Empty(p: p, week: week, onAdd: () => _startAdd(context, p, week));
          }

          final first = photos.last.weekNumber;
          final latest = photos.first.weekNumber;
          final ahead = kBumpMoments.where((m) => m.week > week).toList();

          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // ---- header: a description, never a progress state --------------
            _Eyebrow('Your book', p: p),
            const SizedBox(height: 7),
            Text(weeksInWords(week),
                style: pvFraunces(
                    fontSize: 27,
                    fontWeight: FontWeight.w600,
                    height: 1.12,
                    letterSpacing: -0.6,
                    color: p.ink1)),
            const SizedBox(height: 7),
            Text(
                thisWeekIn
                    ? 'Week $week is in your book.'
                    : first == latest
                        ? "It has week $first in it. This week isn't in it yet."
                        : "It runs from week $first to week $latest. This "
                            "week isn't in it yet.",
                style: pvManrope(fontSize: 13, height: 1.5, color: p.ink2)),

            // ---- this week, if it is not in yet -----------------------------
            if (!thisWeekIn) ...[
              const SizedBox(height: 28),
              _AddCard(p: p, week: week, onAdd: () => _startAdd(context, p, week)),
            ],

            // ---- Then & Now -------------------------------------------------
            const SizedBox(height: 28),
            if (photos.length >= 2)
              _ThenNowRow(
                p: p,
                first: first,
                latest: latest,
                onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                  settings: const RouteSettings(name: 'bump_journey/then_now'),
                  builder: (_) => _ThenNowScreen(
                      p: p, initialLeft: photos.last.id, initialRight: photos.first.id),
                )),
              )
            else
              Text('Then & Now opens once you have two weeks to put side by side.',
                  style: pvManrope(fontSize: 12.5, height: 1.5, color: p.ink3)),

            // ---- her weeks: trimester bands, read forward like a book -------
            const SizedBox(height: 26),
            _Eyebrow('Your weeks', p: p),
            const SizedBox(height: 14),
            for (final t in [1, 2, 3])
              if (photos.any((x) => x.trimester == t)) ...[
                _TrimesterBand(
                  p: p,
                  trimester: t,
                  week: week,
                  photos: photos.where((x) => x.trimester == t).toList().reversed.toList(),
                  onOpen: (photo) => Navigator.of(context).push(MaterialPageRoute<void>(
                    settings: const RouteSettings(name: 'bump_journey/photo'),
                    builder: (_) => _PhotoScreen(p: p, id: photo.id),
                  )),
                ),
                const SizedBox(height: 22),
              ],

            // ---- still ahead: the moments to come, in the book's own type ---
            if (ahead.isNotEmpty) ...[
              _AheadBand(p: p, moments: ahead),
              const SizedBox(height: 22),
            ],

            // ---- the book, at the end ---------------------------------------
            _BookRow(
              p: p,
              line: 'Flip through your weeks — view, download or print.',
              onTap: () => _openBookSheet(context, p, first, latest),
            ),
          ]);
        },
      );

  // ---- adding this week: source → pick → caption → save ----------------------

  Future<void> _startAdd(BuildContext context, V2Palette p, int week) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _Sheet(
        p: p,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Week $week',
              style: pvFraunces(
                  fontSize: 22, fontWeight: FontWeight.w600, letterSpacing: -0.5, color: p.ink1)),
          const SizedBox(height: 5),
          Text('However you have it.',
              style: pvManrope(fontSize: 13, height: 1.5, color: p.ink2)),
          const SizedBox(height: 18),
          Row(children: [
            Expanded(
              child: _SourceButton(
                p: p,
                icon: Icons.photo_camera_outlined,
                hue: kBumpRitualHue,
                label: 'Take a photo',
                onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SourceButton(
                p: p,
                icon: Icons.photo_library_outlined,
                hue: 12,
                label: 'Choose from gallery',
                onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
              ),
            ),
          ]),
          const SizedBox(height: 14),
          _QuietButton(p: p, label: 'Not now', onTap: () => Navigator.of(ctx).pop()),
        ]),
      ),
    );
    if (source == null || !context.mounted) return;

    String? path;
    try {
      final x = await ImagePicker()
          .pickImage(source: source, maxWidth: 1600, imageQuality: 88);
      path = x?.path;
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Couldn't open the camera. Try the gallery.")));
      }
      return;
    }
    if (path == null || !context.mounted) return;

    final caption = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CaptionSheet(p: p, week: week, imagePath: path!),
    );
    if (caption == null || !context.mounted) return; // dismissed: not saved

    await BumpStore.instance.addPhoto(
      sourcePath: path,
      week: week,
      caption: caption,
      journalLabel: 'Bump, week $week',
    );
  }

  // ---- the book, opening to the three things it does -----------------------

  void _openBookSheet(BuildContext context, V2Palette p, int first, int latest) {
    void open(BumpBookAction action) {
      Navigator.of(context).pop();
      Navigator.of(context).push(MaterialPageRoute<void>(
        settings: const RouteSettings(name: 'bump_journey/book'),
        builder: (_) => BumpBookScreen(lang: c.language, initialAction: action),
      ));
    }

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _Sheet(
        p: p,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Your bump journey book',
              style: pvFraunces(
                  fontSize: 22, fontWeight: FontWeight.w600, letterSpacing: -0.5, color: p.ink1)),
          const SizedBox(height: 5),
          Text(
              first == latest
                  ? 'Week $first, one to a page.'
                  : 'Weeks $first to $latest, in order, one to a page.',
              style: pvManrope(fontSize: 13, height: 1.5, color: p.ink2)),
          const SizedBox(height: 16),
          _SheetRow(p: p, icon: Icons.auto_stories_outlined, title: 'Flip through it',
              line: 'Page by page, here in the app.',
              onTap: () => open(BumpBookAction.view)),
          _SheetRow(p: p, icon: Icons.download_outlined, title: 'Download as a PDF',
              line: 'To keep, or to send to family.',
              onTap: () => open(BumpBookAction.download)),
          _SheetRow(p: p, icon: Icons.print_outlined, title: 'Print it',
              line: 'A4, four weeks to a sheet.',
              onTap: () => open(BumpBookAction.print)),
          const SizedBox(height: 10),
          _QuietButton(p: p, label: 'Close', onTap: () => Navigator.of(ctx).pop()),
        ]),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
//  Pieces of the main view
// -----------------------------------------------------------------------------

class _Eyebrow extends StatelessWidget {
  const _Eyebrow(this.text, {required this.p});
  final String text;
  final V2Palette p;
  @override
  // ⚠️ THE ACCENT, NOT INK-3. The design system's eyebrow is the one violet
  // on the screen — "the only violet is the section eyebrow" — and a grey
  // eyebrow reads as metadata rather than as the name of what follows.
  Widget build(BuildContext context) => Text(text.toUpperCase(),
      style: pvManrope(
          fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: p.action));
}

/// "Week 24 · Same window, same light. Whenever you're ready. [Add this week]"
class _AddCard extends StatelessWidget {
  const _AddCard({required this.p, required this.week, required this.onAdd});
  final V2Palette p;
  final int week;
  final VoidCallback onAdd;
  @override
  Widget build(BuildContext context) => PvDoorCard(
        p: p,
        child: Row(children: [
          Container(
            width: 62,
            height: 78,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: p.ink1.withValues(alpha: 0.22), width: 1.2),
            ),
            child: Icon(Icons.add_rounded, size: 22, color: p.ink1.withValues(alpha: 0.3)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Week $week',
                  style: pvFraunces(
                      fontSize: 16.5, fontWeight: FontWeight.w600, letterSpacing: -0.3, color: p.ink1)),
              const SizedBox(height: 6),
              Text("Same window, same light. Whenever you're ready.",
                  style: pvManrope(fontSize: 13, height: 1.5, color: p.ink2)),
              const SizedBox(height: 10),
              _HairlineButton(p: p, label: 'Add this week', onTap: onAdd),
            ]),
          ),
        ]),
      );
}

/// Two overlapping frames, a title, a line, a chevron.
class _ThenNowRow extends StatelessWidget {
  const _ThenNowRow(
      {required this.p, required this.first, required this.latest, required this.onTap});
  final V2Palette p;
  final int first;
  final int latest;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Row(children: [
          SizedBox(
            width: 74,
            height: 55,
            child: Stack(children: [
              _frame(const HSLColor.fromAHSL(1, 20, .16, .89).toColor(), 0),
              _frame(const HSLColor.fromAHSL(1, 12, .14, .86).toColor(), 30),
            ]),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Then & Now',
                  style: pvFraunces(
                      fontSize: 16.5, fontWeight: FontWeight.w600, letterSpacing: -0.3, color: p.ink1)),
              const SizedBox(height: 3),
              // Every photo the same week (a test device, or a late starter
              // who took three in week 30) would read "week 30 beside week
              // 30", so the line drops the pair when there is no pair.
              Text(
                  first == latest
                      ? 'Any two of your photos, side by side.'
                      : 'Week $first beside week $latest, or any two you like.',
                  style: pvManrope(fontSize: 13, height: 1.5, color: p.ink2)),
            ]),
          ),
          const SizedBox(width: 6),
          Icon(Icons.chevron_right_rounded, size: 20, color: p.ink3),
        ]),
      );

  Widget _frame(Color tone, double left) => Positioned(
        left: left,
        child: Container(
          width: 44,
          height: 55,
          decoration: BoxDecoration(
            color: tone,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: p.ground, width: 2),
          ),
        ),
      );
}

/// One trimester: a quiet heading with its moment written into it, then a
/// two-up grid of weeks read forward. The band is the moment's home now —
/// "Halfway was week 20. You're in week 24 now." — so the sentence sits where
/// the weeks it describes are, without a card of its own.
class _TrimesterBand extends StatelessWidget {
  const _TrimesterBand({
    required this.p,
    required this.trimester,
    required this.week,
    required this.photos,
    required this.onOpen,
  });
  final V2Palette p;
  final int trimester;
  final int week;
  final List<BumpPhoto> photos; // oldest first
  final ValueChanged<BumpPhoto> onOpen;

  String get _title =>
      '${const ['First', 'Second', 'Third'][trimester - 1]} trimester';

  /// The band's line, from where she is. Every clause is a fact about a week
  /// that has passed or the one she is in — never a target.
  String get _line {
    final parts = <String>[];
    switch (trimester) {
      case 1:
        parts.add(week > 13 ? 'It ended in week 12.' : "You're in week $week now.");
      case 2:
        if (week >= 20) parts.add('Halfway was week 20.');
        if (week > 27) {
          parts.add('It ended in week 27.');
        } else if (week >= 14) {
          parts.add("You're in week $week now.");
        }
      case 3:
        if (week >= 28) parts.add('It began in week 28.');
        if (week >= 37) parts.add('Full term was week 37.');
        if (week >= 28) parts.add("You're in week $week now.");
    }
    return parts.join(' ');
  }

  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(_title,
            style: pvFraunces(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.4,
                color: p.ink1)),
        if (_line.isNotEmpty) ...[
          const SizedBox(height: 3),
          Text(_line, style: pvManrope(fontSize: 13, height: 1.5, color: p.ink2)),
        ],
        const SizedBox(height: 10),
        Container(height: 1, color: p.line),
        const SizedBox(height: 14),
        LayoutBuilder(builder: (context, c) {
          const gap = 12.0;
          final w = (c.maxWidth - gap) / 2;
          return Wrap(
            spacing: gap,
            runSpacing: 14,
            children: [
              for (final x in photos)
                SizedBox(
                    width: w,
                    child: _GridTile(p: p, photo: x, onTap: () => onOpen(x))),
            ],
          );
        }),
      ]);
}

/// One week in the grid: a three-by-four photo, the heart if she marked it,
/// the week and date under it. Tap for the full-bleed page.
class _GridTile extends StatelessWidget {
  const _GridTile({required this.p, required this.photo, required this.onTap});
  final V2Palette p;
  final BumpPhoto photo;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AspectRatio(
            aspectRatio: 3 / 4,
            child: Stack(fit: StackFit.expand, children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ColoredBox(
                  color: v2BlockTint(kBumpRitualHue, p),
                  child: StorageImage(photo.imageUrl, fit: BoxFit.cover),
                ),
              ),
              if (photo.isFavorite)
                Positioned(
                  right: 9,
                  bottom: 9,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.favorite_rounded, size: 14, color: p.ink1),
                  ),
                ),
            ]),
          ),
          const SizedBox(height: 7),
          Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text('Week ${photo.weekNumber}',
                    style: pvManrope(
                        fontSize: 12.5, fontWeight: FontWeight.w700, color: p.ink1)),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(bumpDate(photo.date),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: pvManrope(fontSize: 11.5, color: p.ink3)),
                ),
              ]),
        ]),
      );
}

/// The moments still to come, in the same type the passed ones are written
/// in — a week in the display face and a line beside it — so they read as
/// pages of the book not yet turned, not as a form.
class _AheadBand extends StatelessWidget {
  const _AheadBand({required this.p, required this.moments});
  final V2Palette p;
  final List<({int week, String ahead, String passedTitle, String passedLine})>
      moments;
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Still ahead',
            style: pvFraunces(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.4,
                color: p.ink1)),
        const SizedBox(height: 3),
        Text(
            moments.length == 1
                ? 'One more page the book will turn on its own.'
                : '${const ['', 'One', 'Two', 'Three', 'Four'][moments.length]} more '
                    'pages the book will turn on its own.',
            style: pvManrope(fontSize: 13, height: 1.5, color: p.ink2)),
        const SizedBox(height: 10),
        Container(height: 1, color: p.line),
        for (final m in moments) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  SizedBox(
                    width: 84,
                    child: Text('Week ${m.week}',
                        style: pvFraunces(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
                            color: p.ink1)),
                  ),
                  Expanded(
                    child: Text(m.ahead,
                        style: pvManrope(fontSize: 13.5, height: 1.4, color: p.ink2)),
                  ),
                ]),
          ),
          if (m != moments.last) Container(height: 1, color: p.line),
        ],
      ]);
}

/// A label and a value on one line — used by the empty state.
class _Fact extends StatelessWidget {
  const _Fact({required this.p, required this.label, required this.value});
  final V2Palette p;
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: p.surfaceAlt,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(children: [
          Text(label.toUpperCase(),
              style: pvManrope(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  color: p.ink3)),
          const SizedBox(width: 12),
          Expanded(
              child: Text(value,
                  style: pvManrope(fontSize: 13, height: 1.4, color: p.ink1))),
        ]),
      );
}

class _BookRow extends StatelessWidget {
  const _BookRow({required this.p, required this.line, required this.onTap});
  final V2Palette p;
  final String line;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: PvDoorCard(
          p: p,
          child: Row(children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: v2BlockTint(12, p),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.menu_book_outlined, size: 22, color: p.ink1),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Your bump journey book',
                    style: pvFraunces(
                        fontSize: 16.5, fontWeight: FontWeight.w600, letterSpacing: -0.3, color: p.ink1)),
                const SizedBox(height: 3),
                Text(line, style: pvManrope(fontSize: 13, height: 1.5, color: p.ink2)),
              ]),
            ),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right_rounded, size: 20, color: p.ink3),
          ]),
        ),
      );
}

/// Nothing yet. What it becomes, stated — and the two features named rather
/// than hidden. "Miss a week and nothing breaks. Most people do."
class _Empty extends StatelessWidget {
  const _Empty({required this.p, required this.week, required this.onAdd});
  final V2Palette p;
  final int week;
  final VoidCallback onAdd;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _Eyebrow('The bump ritual', p: p),
        const SizedBox(height: 8),
        Text('One photo a week, in the same spot.',
            style: pvFraunces(
                fontSize: 27, fontWeight: FontWeight.w600, height: 1.12, letterSpacing: -0.6, color: p.ink1)),
        const SizedBox(height: 8),
        Text("By week 40 you'll have a book you can flip through — and later, "
            'show your child.',
            style: pvManrope(fontSize: 14, height: 1.55, color: p.ink2)),
        const SizedBox(height: 26),
        Row(children: [
          for (var i = 0; i < 3; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            Expanded(
              child: Opacity(
                opacity: [1.0, 0.72, 0.45][i],
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  AspectRatio(
                    aspectRatio: 3 / 4,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: p.ink1.withValues(alpha: 0.2), width: 1.2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text('Week ${week + i}', style: pvManrope(fontSize: 12, color: p.ink3)),
                ]),
              ),
            ),
          ],
        ]),
        const SizedBox(height: 26),
        _HairlineButton(p: p, label: 'Add your first photo', onTap: onAdd),
        const SizedBox(height: 30),
        _Eyebrow('What it becomes', p: p),
        const SizedBox(height: 12),
        _Fact(p: p, label: 'Then & Now', value: 'Once you have two weeks to put side by side.'),
        const SizedBox(height: 10),
        _Fact(p: p, label: 'Your book', value: "Once there's something to flip through."),
        const SizedBox(height: 22),
        Text('Miss a week and nothing breaks. Most people do.',
            style: pvManrope(fontSize: 13, height: 1.5, color: p.ink3)),
      ]);
}

// -----------------------------------------------------------------------------
//  Buttons and sheets — white with a hairline, never filled
// -----------------------------------------------------------------------------

class _HairlineButton extends StatelessWidget {
  const _HairlineButton({required this.p, required this.label, required this.onTap});
  final V2Palette p;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: p.surface,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: p.ink1, width: 1.2),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(label,
                  style: pvManrope(fontSize: 13, fontWeight: FontWeight.w700, color: p.ink1)),
            ]),
          ),
        ),
      ]);
}

class _QuietButton extends StatelessWidget {
  const _QuietButton({required this.p, required this.label, required this.onTap});
  final V2Palette p;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: p.line),
          ),
          child: Text(label,
              style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w700, color: p.ink2)),
        ),
      );
}

class _Sheet extends StatelessWidget {
  const _Sheet({required this.p, required this.child});
  final V2Palette p;
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.fromLTRB(18, 24, 18, 30 + MediaQuery.paddingOf(context).bottom),
        child: child,
      );
}

class _SourceButton extends StatelessWidget {
  const _SourceButton(
      {required this.p, required this.icon, required this.hue, required this.label, required this.onTap});
  final V2Palette p;
  final IconData icon;
  final double hue;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: p.line),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: v2BlockTint(hue, p),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: p.ink1),
            ),
            const SizedBox(height: 10),
            Text(label,
                style: pvManrope(fontSize: 12.5, fontWeight: FontWeight.w700, color: p.ink1)),
          ]),
        ),
      );
}

class _SheetRow extends StatelessWidget {
  const _SheetRow(
      {required this.p, required this.icon, required this.title, required this.line, required this.onTap});
  final V2Palette p;
  final IconData icon;
  final String title;
  final String line;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 11),
          child: Row(children: [
            Icon(icon, size: 20, color: p.ink2),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title,
                    style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w700, color: p.ink1)),
                const SizedBox(height: 2),
                Text(line, style: pvManrope(fontSize: 12.5, height: 1.4, color: p.ink3)),
              ]),
            ),
            Icon(Icons.chevron_right_rounded, size: 18, color: p.ink3),
          ]),
        ),
      );
}

/// "A line about this week? You can skip it." — returns the caption, '' for
/// skip, and null when dismissed (not saved).
class _CaptionSheet extends StatefulWidget {
  const _CaptionSheet({required this.p, required this.week, required this.imagePath});
  final V2Palette p;
  final int week;
  final String imagePath;
  @override
  State<_CaptionSheet> createState() => _CaptionSheetState();
}

class _CaptionSheetState extends State<_CaptionSheet> {
  final _c = TextEditingController();
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: _Sheet(
        p: p,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Row(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: 62,
                height: 78,
                child: StorageImage(widget.imagePath, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('A line about this week?',
                    style: pvFraunces(
                        fontSize: 19, fontWeight: FontWeight.w600, letterSpacing: -0.4, color: p.ink1)),
                const SizedBox(height: 4),
                Text('You can skip it.', style: pvManrope(fontSize: 13, color: p.ink2)),
              ]),
            ),
          ]),
          const SizedBox(height: 16),
          Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: p.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: p.line),
            ),
            child: TextField(
              controller: _c,
              autofocus: true,
              style: pvManrope(fontSize: 14, color: p.ink1),
              decoration: InputDecoration(
                isDense: true,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: "Anything you'll want to remember",
                hintStyle: pvManrope(fontSize: 14, color: p.ink3),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final s in _captionSuggestions)
                GestureDetector(
                  onTap: () => setState(() => _c.text = s),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    height: 32,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: p.surface,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: p.line),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(s, style: pvManrope(fontSize: 12.5, color: p.ink2)),
                    ]),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
              child: _WideHairlineButton(
                  p: p, label: 'Save', strong: true,
                  onTap: () => Navigator.of(context).pop(_c.text.trim())),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _WideHairlineButton(
                  p: p, label: 'Skip', strong: false,
                  onTap: () => Navigator.of(context).pop('')),
            ),
          ]),
        ]),
      ),
    );
  }
}

class _WideHairlineButton extends StatelessWidget {
  const _WideHairlineButton(
      {required this.p, required this.label, required this.strong, required this.onTap, this.color});
  final V2Palette p;
  final String label;
  final bool strong;
  final VoidCallback onTap;
  final Color? color;
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: strong ? p.ink1 : p.line, width: strong ? 1.2 : 1),
          ),
          child: Text(label,
              style: pvManrope(
                  fontSize: 13.5, fontWeight: FontWeight.w700, color: color ?? (strong ? p.ink1 : p.ink2))),
        ),
      );
}

// -----------------------------------------------------------------------------
//  One photo, opened — favourite, edit the caption, delete
// -----------------------------------------------------------------------------

class _PhotoScreen extends StatefulWidget {
  const _PhotoScreen({required this.p, required this.id});
  final V2Palette p;
  final String id;
  @override
  State<_PhotoScreen> createState() => _PhotoScreenState();
}

class _PhotoScreenState extends State<_PhotoScreen> {
  bool _editing = false;
  bool _confirm = false;
  final _draft = TextEditingController();

  @override
  void dispose() {
    _draft.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: BumpStore.instance,
        builder: (context, _) {
          final p = widget.p;
          final photo = BumpStore.instance.photos.where((x) => x.id == widget.id).firstOrNull;
          if (photo == null) {
            // Deleted underneath us — go back rather than draw a blank.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) Navigator.of(context).maybePop();
            });
            return Scaffold(backgroundColor: p.ground);
          }
          final moment = kBumpMoments.where((m) => m.week == photo.weekNumber).firstOrNull;

          return Scaffold(
            backgroundColor: p.ground,
            body: ListView(padding: EdgeInsets.zero, children: [
              Stack(children: [
                SizedBox(
                  height: 430,
                  width: double.infinity,
                  child: ColoredBox(
                    color: v2BlockTint(kBumpRitualHue, p),
                    child: StorageImage(photo.imageUrl, fit: BoxFit.cover),
                  ),
                ),
                Positioned(
                  left: 14,
                  top: 16 + MediaQuery.paddingOf(context).top,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        border: Border.all(color: p.line),
                      ),
                      child: Icon(Icons.arrow_back_rounded, size: 18, color: p.ink1),
                    ),
                  ),
                ),
              ]),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 22, 18, 26),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
                    Text('Week ${photo.weekNumber}',
                        style: pvFraunces(
                            fontSize: 22, fontWeight: FontWeight.w600, letterSpacing: -0.5, color: p.ink1)),
                    const SizedBox(width: 10),
                    Text('${bumpDate(photo.date)} ${photo.date.year}',
                        style: pvManrope(fontSize: 12, color: p.ink3)),
                  ]),
                  if (moment != null) ...[
                    const SizedBox(height: 6),
                    Text('${moment.passedTitle} ${moment.passedLine}',
                        style: pvManrope(fontSize: 13, height: 1.5, color: p.ink2)),
                  ],
                  const SizedBox(height: 16),
                  if (!_editing)
                    Text(
                        photo.caption.trim().isEmpty
                            ? 'No caption — that is fine too.'
                            : photo.caption,
                        style: pvManrope(
                            fontSize: 14.5,
                            height: 1.55,
                            color: photo.caption.trim().isEmpty ? p.ink3 : p.ink1))
                  else ...[
                    Container(
                      height: 46,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: p.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: p.ink1),
                      ),
                      child: TextField(
                        controller: _draft,
                        autofocus: true,
                        style: pvManrope(fontSize: 14, color: p.ink1),
                        decoration: const InputDecoration(
                          isDense: true,
                          filled: false,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(children: [
                      Expanded(
                        child: _WideHairlineButton(
                            p: p, label: 'Save', strong: true,
                            onTap: () async {
                              await BumpStore.instance.updateCaption(photo.id, _draft.text.trim());
                              if (mounted) setState(() => _editing = false);
                            }),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _WideHairlineButton(
                            p: p, label: 'Cancel', strong: false,
                            onTap: () => setState(() => _editing = false)),
                      ),
                    ]),
                  ],
                  const SizedBox(height: 16),
                  Container(height: 1, color: p.line),
                  if (!_confirm) ...[
                    _Action(
                      p: p,
                      icon: photo.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      iconColor: photo.isFavorite ? p.ink1 : p.ink2,
                      label: photo.isFavorite ? 'Favourited' : 'Favourite this week',
                      onTap: () => BumpStore.instance.toggleFavorite(photo.id),
                    ),
                    _Action(
                      p: p,
                      icon: Icons.edit_outlined,
                      iconColor: p.ink2,
                      label: 'Edit the caption',
                      onTap: () => setState(() {
                        _editing = true;
                        _confirm = false;
                        _draft.text = photo.caption;
                      }),
                    ),
                    _Action(
                      p: p,
                      icon: Icons.delete_outline_rounded,
                      iconColor: p.ink3,
                      labelColor: p.ink3,
                      label: 'Delete this photo',
                      onTap: () => setState(() {
                        _confirm = true;
                        _editing = false;
                      }),
                    ),
                  ] else ...[
                    const SizedBox(height: 16),
                    Text('Delete week ${photo.weekNumber}?',
                        style: pvFraunces(
                            fontSize: 16.5, fontWeight: FontWeight.w600, letterSpacing: -0.3, color: p.ink1)),
                    const SizedBox(height: 4),
                    Text("It leaves your book and your journal. This can't be undone.",
                        style: pvManrope(fontSize: 13, height: 1.5, color: p.ink2)),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(
                        child: _WideHairlineButton(
                            p: p, label: 'Delete', strong: true, color: kPvUrgentInk,
                            onTap: () async {
                              await BumpStore.instance.delete(photo.id);
                              if (context.mounted) Navigator.of(context).maybePop();
                            }),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _WideHairlineButton(
                            p: p, label: 'Keep it', strong: false,
                            onTap: () => setState(() => _confirm = false)),
                      ),
                    ]),
                  ],
                ]),
              ),
            ]),
          );
        },
      );
}

class _Action extends StatelessWidget {
  const _Action(
      {required this.p, required this.icon, required this.iconColor, required this.label, required this.onTap, this.labelColor});
  final V2Palette p;
  final IconData icon;
  final Color iconColor;
  final Color? labelColor;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 13),
          child: Row(children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: 12),
            Text(label,
                style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w700, color: labelColor ?? p.ink1)),
          ]),
        ),
      );
}

// -----------------------------------------------------------------------------
//  Then & Now — any two weeks, side by side; shown to someone across a table
// -----------------------------------------------------------------------------
//
//  ⚠️ ONE CARD, THREE PLACES. `_PairCard` is the composed keepsake — two
//  photos, their weeks and dates, a quiet footer. It is what she sees on this
//  screen, what "Full screen" shows large on a dark ground, and what "Save as
//  one image" renders to a PNG. The user's rule, verbatim: *"it should be
//  visible to the user what they are actually getting."* Drawing the preview
//  and the export from one widget is how that stays true.
//
//  ⚠️ THE TWO BUTTONS ARE THE SAME BUTTON. The board drew one primary and one
//  quiet; on the phone that read as one action mattering more than the other,
//  which is not true here. Both are white with the same ink hairline.

class _ThenNowScreen extends StatefulWidget {
  const _ThenNowScreen({required this.p, required this.initialLeft, required this.initialRight});
  final V2Palette p;
  final String initialLeft;
  final String initialRight;
  @override
  State<_ThenNowScreen> createState() => _ThenNowScreenState();
}

class _ThenNowScreenState extends State<_ThenNowScreen> {
  late String _left = widget.initialLeft;
  late String _right = widget.initialRight;
  final _pair = GlobalKey();
  bool _busy = false;

  Future<void> _saveAsImage() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final boundary = _pair.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      final img = await boundary.toImage(pixelRatio: 3);
      final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
      if (bytes == null) return;
      final data = Uint8List.view(bytes.buffer);
      await Share.shareXFiles(
        [XFile.fromData(data, mimeType: 'image/png', name: 'then-and-now.png')],
      );
    } catch (_) {
      // The share sheet failing is not worth an error screen.
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: BumpStore.instance,
        builder: (context, _) {
          final p = widget.p;
          final photos = BumpStore.instance.photos;
          final left = photos.where((x) => x.id == _left).firstOrNull ?? photos.first;
          final right = photos.where((x) => x.id == _right).firstOrNull ?? photos.last;

          return Scaffold(
            backgroundColor: p.ground,
            body: SafeArea(
              child: Column(children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _BackButton(p: p),
                      const SizedBox(height: 18),
                      _Eyebrow('Then & Now', p: p),
                      const SizedBox(height: 6),
                      Text(
                          left.weekNumber == right.weekNumber
                              ? 'Week ${left.weekNumber}, twice'
                              : 'Week ${left.weekNumber} and week ${right.weekNumber}',
                          style: pvFraunces(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.5,
                              color: p.ink1)),
                      const SizedBox(height: 16),
                      // What she sees is what she gets.
                      RepaintBoundary(
                        key: _pair,
                        child: _PairCard(p: p, left: left, right: right),
                      ),
                      const SizedBox(height: 22),
                      _Chips(p: p, label: 'Then', photos: photos, selected: _left,
                          onPick: (id) => setState(() => _left = id)),
                      const SizedBox(height: 14),
                      _Chips(p: p, label: 'Now', photos: photos, selected: _right,
                          onPick: (id) => setState(() => _right = id)),
                    ]),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 14),
                  child: Row(children: [
                    Expanded(
                      child: _WideHairlineButton(
                          p: p, label: 'Full screen', strong: true,
                          onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                                builder: (_) => _FullScreenPair(p: p, left: left, right: right),
                              ))),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _WideHairlineButton(
                          p: p, label: _busy ? 'Saving…' : 'Save as one image', strong: true,
                          onTap: _saveAsImage),
                    ),
                  ]),
                ),
              ]),
            ),
          );
        },
      );
}

/// The keepsake itself: a white card, two photos, their weeks and dates, and
/// a footer line. Rendered on screen, full screen, and to the PNG she shares.
class _PairCard extends StatelessWidget {
  const _PairCard({required this.p, required this.left, required this.right});
  final V2Palette p;
  final BumpPhoto left;
  final BumpPhoto right;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: p.line),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: _Half(p: p, photo: left, tag: 'Then')),
            const SizedBox(width: 10),
            Expanded(child: _Half(p: p, photo: right, tag: 'Now')),
          ]),
          const SizedBox(height: 12),
          Container(height: 1, color: p.line),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
              child: Text(
                  left.weekNumber == right.weekNumber
                      ? 'Week ${left.weekNumber}, ${bumpDate(left.date)} and ${bumpDate(right.date)}'
                      : '${right.weekNumber - left.weekNumber} weeks apart',
                  style: pvManrope(fontSize: 12, height: 1.4, color: p.ink2)),
            ),
            Text('PARENTVEDA',
                style: pvManrope(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: p.ink3)),
          ]),
        ]),
      );
}

class _Half extends StatelessWidget {
  const _Half({required this.p, required this.photo, required this.tag});
  final V2Palette p;
  final BumpPhoto photo;
  final String tag;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        AspectRatio(
          aspectRatio: 3 / 4,
          child: Stack(fit: StackFit.expand, children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: ColoredBox(
                color: v2BlockTint(kBumpRitualHue, p),
                child: StorageImage(photo.imageUrl, fit: BoxFit.cover),
              ),
            ),
            Positioned(
              left: 8,
              top: 8,
              child: Container(
                height: 22,
                padding: const EdgeInsets.symmetric(horizontal: 9),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(tag.toUpperCase(),
                      style: pvManrope(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                          color: p.ink1)),
                ]),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 8),
        Text('Week ${photo.weekNumber}',
            style: pvFraunces(
                fontSize: 15.5, fontWeight: FontWeight.w600, letterSpacing: -0.3, color: p.ink1)),
        const SizedBox(height: 1),
        Text(bumpDate(photo.date), style: pvManrope(fontSize: 11.5, color: p.ink3)),
      ]);
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.p});
  final V2Palette p;
  @override
  Widget build(BuildContext context) => Row(children: [
        GestureDetector(
          onTap: () => Navigator.of(context).maybePop(),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              shape: BoxShape.circle,
              border: Border.all(color: p.line),
            ),
            child: Icon(Icons.arrow_back_rounded, size: 18, color: p.ink1),
          ),
        ),
      ]);
}

class _Chips extends StatelessWidget {
  const _Chips(
      {required this.p, required this.label, required this.photos, required this.selected, required this.onPick});
  final V2Palette p;
  final String label;
  final List<BumpPhoto> photos;
  final String selected;
  final ValueChanged<String> onPick;
  @override
  Widget build(BuildContext context) {
    // ⚠️ TWO PHOTOS IN ONE WEEK GET THEIR DATE ON THE CHIP. Otherwise a woman
    // who took two in week 30 sees "Wk 30 · Wk 30" and cannot tell which is
    // which. Seen on a test device where every photo was week 20.
    final weeks = photos.map((x) => x.weekNumber).toList();
    bool dup(int w) => weeks.where((x) => x == w).length > 1;
    String chipLabel(BumpPhoto x) => dup(x.weekNumber)
        ? 'Wk ${x.weekNumber} · ${x.date.day} ${_monthsShort[x.date.month - 1]}'
        : 'Wk ${x.weekNumber}';
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: pvManrope(fontSize: 12, fontWeight: FontWeight.w700, color: p.ink3)),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final x in photos)
            GestureDetector(
              onTap: () => onPick(x.id),
              behavior: HitTestBehavior.opaque,
              child: Container(
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 13),
                decoration: BoxDecoration(
                  color: x.id == selected ? v2BlockTint(kBumpRitualHue, p) : p.surface,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                      color: x.id == selected ? p.ink1 : p.line, width: x.id == selected ? 1.2 : 1),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(chipLabel(x),
                      style: pvManrope(
                          fontSize: 12.5,
                          fontWeight: x.id == selected ? FontWeight.w700 : FontWeight.w600,
                          color: x.id == selected ? p.ink1 : p.ink2)),
                ]),
              ),
            ),
        ],
      ),
    ]);
  }
}

/// The same card, large, on a dark ground. Tap anywhere to come back.
class _FullScreenPair extends StatelessWidget {
  const _FullScreenPair({required this.p, required this.left, required this.right});
  final V2Palette p;
  final BumpPhoto left;
  final BumpPhoto right;
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFF1B1820),
        body: GestureDetector(
          onTap: () => Navigator.of(context).maybePop(),
          behavior: HitTestBehavior.opaque,
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: _PairCard(p: p, left: left, right: right),
              ),
            ),
          ),
        ),
      );
}
