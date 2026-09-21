// =============================================================================
//  Is it safe? — the door
// -----------------------------------------------------------------------------
//  2026-09-19. The home tile "Is it safe?" opens this (surface `can_i` →
//  `CanIScreen` → this body). Built on five Mobbin passes, logged in
//  docs/MOBBIN-DISCOVERY.md §10:
//
//    the field first     GoodRx, Noom Food Lookup — you came to ask a thing
//    scan beside search  Yuka, Noom, Lifesum, Bevel — a camera next to the
//                        field, never a separate mode
//    cut-out grid        Uber Eats/Safeway, Shipt, Thrive — photos on white,
//                        name under, nothing painted
//    dot + word          Yuka — the verdict at a glance, no tile colour
//    big-photo groups    Uber Eats Browse, Panera — photography for the
//                        shelf, cut-outs for the items
//
//  The page in order: the door hero (eyebrow, title, one line, THE FIELD) →
//  live results while she types; her recents and saved while the field is
//  focused and empty (a typing shortcut, not a section — see `_recall`);
//  else: Asked most (twelve cut-outs), the four shelves (Eat / Drink / Take
//  / Do) with counts, For your weeks (what has a note for her trimester),
//  one Saved row, the disclaimer. Every section renders; an empty one is an
//  invitation.
// =============================================================================

import 'package:flutter/material.dart';

import '../../services/bracket_resolver.dart';
import '../../data/can_i_data.dart';
import '../../data/can_i_groups.dart';
import '../../data/reads/read_images.dart';
import '../../models/can_i_entry.dart';
import '../../services/can_i_activity_store.dart';
import '../../services/can_i_store.dart';
import '../../services/pregnancy_controller.dart';
import '../../theme/pv_fonts.dart';
import '../../widgets/global_ask_fab.dart' show kAskVedaRoute;
import '../../widgets/pv_feedback.dart';
import '../doors/pv_door_chrome.dart';
import '../doors/pv_live_search.dart';
import '../saved_screen.dart';
import '../tools/ask_veda_screen.dart';
import '../v2/v2_palette.dart';
import '../v2/v3_hero_field.dart';
import 'can_i_answer.dart';
import 'can_i_identify.dart';
import 'can_i_widgets.dart';

const String kCanIBracketId = 'pregnancy_is_it_safe';

/// Where the scan and snap buttons live. TRUE = a pinned pill at the bottom
/// centre (PhonePe, GPay, Paytm — the thumb is already there); FALSE = two
/// round buttons beside the field in the hero (Yuka, Noom, Lifesum). Both
/// are built; the user judges on the device, 2026-09-19: "the placement at
/// the bottom should be done, but it should also look good … it should not
/// be like it was looking way better in the hero section."
const bool kCanIScanAtFoot = true;

class CanIDoorBody extends StatefulWidget {
  const CanIDoorBody({super.key, required this.controller});
  final PregnancyController controller;

  @override
  State<CanIDoorBody> createState() => _CanIDoorBodyState();
}

class _CanIDoorBodyState extends State<CanIDoorBody> {
  // The field's three states, the scroll to the top on focus, the fading
  // words and Back-twice all live in `PvLiveSearch` (pv_live_search.dart) —
  // the same flow every door's bar uses. This screen keeps only what is its
  // own: how it finds, what a row is, what a way on means.
  final PvLiveSearch _search = PvLiveSearch();

  @override
  void initState() {
    super.initState();
    CanIActivityStore.instance.init();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  String get _q => _search.query;
  FocusNode get _focus => _search.focus;

  void _open(CanIEntry e) {
    _focus.unfocus();
    openCanIAnswer(context, e, widget.controller);
  }

  void _ask() {
    pvCommitFeedback();
    final q = _q;
    CanIActivityStore.instance.logMiss(q, source: 'typed');
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        settings: const RouteSettings(name: kAskVedaRoute),
        builder: (_) => AskVedaScreen(controller: widget.controller, initialQuery: 'Is $q safe in pregnancy?'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bracket = bracketById(kCanIBracketId);
    final hue = bracket?.hue ?? 232;
    return AnimatedBuilder(
      animation: Listenable.merge([V2PaletteStore.instance, CanIActivityStore.instance, CanIStore.instance, _search]),
      builder: (context, _) {
        final p = V2PaletteStore.instance.current;
        final tint = v2BlockTint(hue, p);
        final searching = _search.searching;
        final recalling = _search.recalling;
        return PvLiveSearchScope(
          search: _search,
          child: Scaffold(
            backgroundColor: p.ground,
            body: Stack(
              children: [
                Positioned.fill(
                  child: V3HeroField(accent: tint, ground: p.ground, variant: 1, chroma: v3FieldChroma(hue)),
                ),
                ListView(
                  padding: EdgeInsets.zero,
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  children: [
                    _hero(p, bracket?.blurb.now ?? 'Food, medicines, travel, beauty — what is fine and what is not.'),
                    PvDoorSheet(
                      p: p,
                      minHeightFactor: 0.8,
                    minHeight: pvLiveSearchSheetMin(context, _search),
                      children: [
                        const SizedBox(height: 22),
                        if (searching) ..._results(p) else if (recalling) ..._recall(p) else ..._welcome(p),
                        // Room for the pinned bar over the last row.
                        if (kCanIScanAtFoot) const SizedBox(height: 72),
                      ],
                    ),
                  ],
                ),
                // ---- SCAN, BOTTOM CENTRE ------------------------------------
                // The payments-app placement (PhonePe, GPay, Paytm): one pill
                // under the thumb, over the scroll, on every state of the page.
                // Barcode is the pill because it is the one that works today
                // with no key; the photo is the small round beside it.
                if (kCanIScanAtFoot && !_focus.hasFocus) Positioned(left: 0, right: 0, bottom: 0, child: _scanBar(p)),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---- hero -----------------------------------------------------------------
  //  ⚠️ THE DOOR HERO, EXACTLY — 2026-09-20, the user on the phone: "we need
  //  to be consistent with the hero images … the same way for Is it safe?
  //  and every door." The numbers below are `_Hero` in pv_door_screen.dart:
  //  the photograph behind, the 0.52/0.30/0.34 scrim, the 38pt back circle,
  //  a tenth of the screen of picture, the eyebrow at 11/800/1.4 in white
  //  82%, the title at 30 white, the blurb at 13.5 white 92%, then the
  //  search — here a LIVE field rather than a bar, because this door's
  //  search answers as she types. Its geometry is PvSearchBar's (48 high,
  //  white, hairline, stadium).

  Widget _hero(V2Palette p, String blurb) {
    final photo = readImageFor('cani_hero');
    final onPhoto = photo != null;
    final ink = onPhoto ? Colors.white : p.ink1;
    final ink2 = onPhoto ? Colors.white.withValues(alpha: 0.82) : p.ink2;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (photo != null)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: -38,
            child: Image.network(
              photo,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
              loadingBuilder: (context, child, progress) => progress == null ? child : const SizedBox.shrink(),
            ),
          ),
        if (photo != null)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: -38,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.52),
                    Colors.black.withValues(alpha: 0.30),
                    Colors.black.withValues(alpha: 0.34),
                  ],
                  stops: const [0, 0.62, 1],
                ),
              ),
            ),
          ),
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 22, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Material(
                  color: Colors.white.withValues(alpha: 0.55),
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: SizedBox(
                      width: 38,
                      height: 38,
                      child: Icon(Icons.arrow_back_rounded, size: 19, color: p.ink1),
                    ),
                  ),
                ),
                SizedBox(height: onPhoto ? MediaQuery.sizeOf(context).height * 0.10 : 20),
                PvLiveSearchWords(
                  search: _search,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'IS IT SAFE?',
                        style: pvManrope(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.4, color: ink2),
                      ),
                      const SizedBox(height: 8),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 300),
                        child: Text(
                          'Can I have it, do it, take it?',
                          style: pvFraunces(
                            fontSize: onPhoto ? 30 : 27,
                            fontWeight: FontWeight.w600,
                            height: 1.15,
                            letterSpacing: -0.6,
                            color: ink,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 330),
                        child: Text(
                          blurb,
                          style: pvManrope(
                            fontSize: 13.5,
                            height: 1.55,
                            color: onPhoto ? Colors.white.withValues(alpha: 0.92) : p.ink2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // THE FIELD — the door's live field (pv_live_search.dart).
                // The camera round beside it is kept for revert behind
                // `kCanIScanAtFoot`; the pill at the foot is the shipped form.
                Row(
                  children: [
                    Expanded(
                      child: PvLiveSearchField(
                        key: const Key('cani_field'),
                        search: _search,
                        p: p,
                        hint: 'Search Is it safe?',
                        onSubmitted: (_) {
                          final hits = canIFind(_q);
                          if (hits.isNotEmpty) {
                            _open(hits.first);
                          } else if (_q.isNotEmpty) {
                            _ask();
                          }
                        },
                      ),
                    ),
                    if (!kCanIScanAtFoot) ...[
                      const SizedBox(width: 8),
                      _round(p, Icons.photo_camera_outlined, 'Open the camera', _chooseCamera),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _round(V2Palette p, IconData icon, String label, VoidCallback onTap) => PvPress(
    child: Material(
      color: p.surface,
      shape: CircleBorder(side: BorderSide(color: p.line)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          pvCommitFeedback();
          _focus.unfocus();
          onTap();
        },
        child: Tooltip(
          message: label,
          child: SizedBox(width: 48, height: 48, child: Icon(icon, size: 21, color: p.ink1)),
        ),
      ),
    ),
  );

  /// One button, then her choice — the user, 2026-09-19: "a single button
  /// at the bottom that indicates you can open the camera; then whether
  /// they want a barcode scanner or a camera, that's upon them … the very
  /// first intuitive thought would be to click a photo." Photo is listed
  /// first for that reason.
  Widget _scanBar(V2Palette p) => SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Center(
        child: PvPress(
          child: Material(
            color: p.ink1,
            shape: const StadiumBorder(),
            clipBehavior: Clip.antiAlias,
            elevation: 6,
            shadowColor: Colors.black.withValues(alpha: 0.35),
            child: InkWell(
              onTap: () {
                pvCommitFeedback();
                _focus.unfocus();
                _chooseCamera();
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 13, 24, 13),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.photo_camera_outlined, size: 20, color: p.ground),
                    const SizedBox(width: 10),
                    Text(
                      'Open the camera',
                      style: pvManrope(fontSize: 14.5, fontWeight: FontWeight.w800, color: p.ground),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Future<void> _chooseCamera() async {
    final p = V2PaletteStore.instance.current;
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: p.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 18, 20, 12 + MediaQuery.paddingOf(ctx).bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'THE CAMERA',
              style: pvManrope(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.3, color: p.ink3),
            ),
            const SizedBox(height: 4),
            Text(
              'Show us the thing',
              style: pvFraunces(fontSize: 22, fontWeight: FontWeight.w600, height: 1.2, color: p.ink1),
            ),
            const SizedBox(height: 14),
            _choice(
              ctx,
              p,
              Icons.photo_camera_outlined,
              'Take a photo',
              'A fruit, a plate, a packet, a cream — anything.',
              'photo',
            ),
            _choice(
              ctx,
              p,
              Icons.qr_code_scanner_rounded,
              'Scan a barcode',
              'Packaged food and medicines; exact when the packet is known.',
              'barcode',
              last: true,
            ),
          ],
        ),
      ),
    );
    if (!mounted || choice == null) return;
    if (choice == 'photo') {
      await canISnap(context, widget.controller);
    } else {
      await openCanIScan(context, widget.controller);
    }
  }

  Widget _choice(
    BuildContext ctx,
    V2Palette p,
    IconData icon,
    String title,
    String sub,
    String value, {
    bool last = false,
  }) => InkWell(
    onTap: () {
      pvCommitFeedback();
      Navigator.pop(ctx, value);
    },
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: last ? null : Border(bottom: BorderSide(color: p.line)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: p.line),
            ),
            child: Icon(icon, size: 21, color: p.ink1),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: pvManrope(fontSize: 15, fontWeight: FontWeight.w700, color: p.ink1),
                ),
                const SizedBox(height: 2),
                Text(sub, style: pvManrope(fontSize: 12.5, height: 1.4, color: p.ink2)),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, size: 20, color: p.ink3),
        ],
      ),
    ),
  );

  // ---- results --------------------------------------------------------------

  List<Widget> _results(V2Palette p) {
    final hits = canIFind(_q);
    return [
      pvDoorPad(
        canIHeading(
          p,
          hits.isEmpty ? 'Nothing by that name yet' : 'Results',
          sub: hits.isEmpty ? 'Try the plain name — "noodles", not the brand — or ask Veda.' : null,
        ),
      ),
      const SizedBox(height: 6),
      pvDoorPad(
        Column(
          children: [
            for (var i = 0; i < hits.length; i++)
              CanIRow(entry: hits[i], p: p, last: i == hits.length - 1, onTap: () => _open(hits[i])),
          ],
        ),
      ),
      const SizedBox(height: 14),
      pvDoorPad(_askRow(p)),
      const SizedBox(height: 8),
    ];
  }

  Widget _askRow(V2Palette p) => PvLiveSearchWayOn(
        p: p,
        icon: Icons.auto_awesome_outlined,
        title: 'Ask Veda about "$_q"',
        line: 'In your own words, with your week in mind.',
        onTap: _ask,
      );

  // ---- recall: the field is focused and empty --------------------------------
  //
  //  Where "Yours" went. On 2026-09-20 the user looked at the Yours row
  //  under the field — Saved · N and her last look-ups as chips — and said
  //  it read as "my history displayed at the very top … static … I don't
  //  see any use of it", and that Asked most deserved the top. Mobbin
  //  agrees on both counts: no lookup screen in the library shows history
  //  idle. Yazio, Keeta, Swiggy, Kitchen Stories and Ultrahuman show
  //  *Recent searches* only once the field has FOCUS and is still empty
  //  (a typing shortcut), Fitbit/Garmin/Lifesum put Recent and Favourites
  //  behind tabs, and the idle screen leads with Popular (Woolworths,
  //  Grubhub, Instacart). So: recents and saved live here, in the focus
  //  state, as rows she can tap instead of typing; the idle page leads with
  //  Asked most; the saved list keeps one quiet row at the foot.

  List<Widget> _recall(V2Palette p) {
    final recents = [for (final id in CanIActivityStore.instance.recents) ?canIById(id)];
    final saved = [for (final id in CanIStore.instance.savedIds) ?canIById(id)];
    return [
      if (recents.isNotEmpty) ...[
        pvLiveSearchRecallHeading(p, 'Recent', onClear: CanIActivityStore.instance.clearRecents),
        const SizedBox(height: 6),
        pvDoorPad(
          Column(
            children: [
              for (var i = 0; i < recents.length; i++)
                CanIRow(entry: recents[i], p: p, last: i == recents.length - 1, onTap: () => _open(recents[i])),
            ],
          ),
        ),
        const SizedBox(height: 22),
      ],
      if (saved.isNotEmpty) ...[
        pvDoorPad(canIHeading(p, 'Saved', sub: 'The ones you kept with the heart.')),
        const SizedBox(height: 6),
        pvDoorPad(
          Column(
            children: [
              for (var i = 0; i < saved.length && i < 6; i++)
                CanIRow(entry: saved[i], p: p, last: i == saved.length - 1 || i == 5, onTap: () => _open(saved[i])),
            ],
          ),
        ),
        const SizedBox(height: 22),
      ],
      // Nothing of hers yet: the twelve, so the keyboard never rises over
      // a blank sheet. (Not the recents' empty line — a hint is not a section.)
      if (recents.isEmpty && saved.isEmpty) ...[
        pvDoorPad(canIHeading(p, 'Asked most', sub: 'Type a food, a medicine, a thing you want to do — or tap one.')),
        const SizedBox(height: 14),
        pvDoorPad(_grid([for (final id in kCanIAskedMost) ?canIById(id)], p)),
        const SizedBox(height: 26),
      ],
    ];
  }

  // ---- welcome --------------------------------------------------------------

  List<Widget> _welcome(V2Palette p) {
    final c = widget.controller;
    final week = c.isDueDateSet ? c.currentWeek : null;
    final forHer = week == null ? const <CanIEntry>[] : canIForTrimester(week);
    final saved = [for (final id in CanIStore.instance.savedIds) ?canIById(id)];
    return [
      // ---- (YOURS was here, first — retired 2026-09-20, see `_recall`) ----
      // Kept for revert:
      // // ---- YOURS, FIRST ------------------------------------------------
      // // Saved and recents used to be two sections, one at the very foot,
      // // each with its own empty paragraph (the phone, 2026-09-19: "Saved
      // // heading is coming at the way bottom"). One row under the field:
      // // "Saved · N" leads, her recents follow; empty, one quiet line.
      // pvDoorPad(canIHeading(p, 'Yours')),
      // const SizedBox(height: 12),
      // if (!yours)
      //   pvDoorPad(Text('What you look up, and what you save with the heart, stays here.',
      //       style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink2)))
      // else
      //   SizedBox(
      //     height: 40,
      //     child: ListView(
      //       scrollDirection: Axis.horizontal,
      //       padding: const EdgeInsets.symmetric(horizontal: kPvDoorGutter),
      //       children: [
      //         if (saved.isNotEmpty) ...[
      //           CanIChip(
      //               label: 'Saved  ·  ${saved.length}',
      //               p: p,
      //               selected: true,
      //               leading: Icon(Icons.favorite_rounded, size: 14, color: p.ground),
      //               onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
      //                   settings: const RouteSettings(name: 'saved'),
      //                   builder: (_) => const SavedScreen()))),
      //           const SizedBox(width: 8),
      //         ],
      //         for (var i = 0; i < recents.length; i++) ...[
      //           if (i > 0) const SizedBox(width: 8),
      //           CanIChip(
      //             label: recents[i].name.now,
      //             p: p,
      //             leading: CanIVerdictDot(verdict: recents[i].verdict, p: p, size: 8),
      //             onTap: () => _open(recents[i]),
      //           ),
      //         ],
      //       ],
      //     ),
      //   ),
      // const SizedBox(height: 26),

      // ---- ASKED MOST ----------------------------------------------------
      pvDoorPad(canIHeading(p, 'Asked most', sub: 'The dozen every pregnancy asks in its first month.')),
      const SizedBox(height: 14),
      pvDoorPad(_grid([for (final id in kCanIAskedMost) ?canIById(id)], p)),
      const SizedBox(height: 26),

      // ---- THE SHELVES ---------------------------------------------------
      pvDoorPad(canIHeading(p, 'Browse the shelves')),
      const SizedBox(height: 14),
      pvDoorPad(
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.45,
          children: [for (final cat in CanICategory.values) _shelf(cat, p)],
        ),
      ),
      const SizedBox(height: 26),

      // ---- FOR HER WEEKS -------------------------------------------------
      pvDoorPad(
        canIHeading(
          p,
          week == null ? 'For your trimester' : 'For your weeks · ${_trimesterWord(week)}',
          sub: week == null
              ? 'Set your due date and this shelf fills with what changes for your trimester.'
              : 'Answers that shift with the trimester you are in.',
        ),
      ),
      const SizedBox(height: 14),
      if (forHer.isNotEmpty) _rail(forHer.take(12).toList(), p),
      const SizedBox(height: 26),

      // ---- SAVED, ONE ROW ------------------------------------------------
      // Woolworths' "Buy Again": a single row with a meaning line, not a
      // section of chips. Empty, it is the invitation (the heart on any
      // answer); filled, it counts and opens the one Saved screen.
      pvDoorPad(_savedRow(p, saved.length)),
      const SizedBox(height: 26),
      pvDoorPad(
        PvDoorDisclaimer(
          p: p,
          text:
              'General guidance for a healthy pregnancy, not a prescription. '
              'Your doctor knows your history; if they have said otherwise, they are right.',
        ),
      ),
    ];
  }

  Widget _savedRow(V2Palette p, int n) => PvPress(
    child: Material(
      color: p.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: p.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          pvCommitFeedback();
          _focus.unfocus();
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              settings: const RouteSettings(name: 'saved'),
              builder: (_) => const SavedScreen(),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
          child: Row(
            children: [
              Icon(n == 0 ? Icons.favorite_border_rounded : Icons.favorite_rounded, size: 20, color: p.ink1),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      n == 0 ? 'Saved answers' : 'Saved answers  ·  $n',
                      style: pvManrope(fontSize: 14.5, fontWeight: FontWeight.w700, color: p.ink1),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      n == 0
                          ? 'The heart on any answer keeps it here.'
                          : 'The ones you kept, in one place with everything else you saved.',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: pvManrope(fontSize: 12.5, color: p.ink2),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, size: 20, color: p.ink3),
            ],
          ),
        ),
      ),
    ),
  );

  String _trimesterWord(int week) => switch (canITrimester(week)) {
    1 => 'first trimester',
    2 => 'second trimester',
    _ => 'third trimester',
  };

  // ⚠️ padding: zero on every grid — a GridView inside a column inherits
  // the MediaQuery's top padding (the status bar) as its own, which read as
  // a blank band under the heading on the phone.
  Widget _grid(List<CanIEntry> items, V2Palette p) => GridView.builder(
    shrinkWrap: true,
    padding: EdgeInsets.zero,
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
      mainAxisSpacing: 14,
      crossAxisSpacing: 10,
      childAspectRatio: 0.74,
    ),
    itemCount: items.length,
    itemBuilder: (_, i) => CanICutoutTile(entry: items[i], p: p, onTap: () => _open(items[i])),
  );

  Widget _rail(List<CanIEntry> items, V2Palette p) => SizedBox(
    height: 156,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: kPvDoorGutter),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(width: 10),
      itemBuilder: (_, i) => SizedBox(
        width: 112,
        child: CanICutoutTile(entry: items[i], p: p, onTap: () => _open(items[i])),
      ),
    ),
  );

  /// A shelf: the category's photo, its name and count over a white scrim
  /// at the foot — the reader's next-step tile treatment.
  Widget _shelf(CanICategory cat, V2Palette p) {
    final n = canIByCategory(cat).length;
    final url = canIImageFor('shelf_${cat.name}');
    return PvPress(
      child: InkWell(
        onTap: () {
          pvCommitFeedback();
          _focus.unfocus();
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              settings: RouteSettings(name: 'can_i/${cat.name}'),
              builder: (_) => CanIGroupScreen(category: cat, controller: widget.controller),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: p.surfaceAlt,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: p.line),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                  right: -14,
                  bottom: -10,
                  child: Opacity(opacity: 0.35, child: canICategoryGlyph(p, cat, size: 110))),
              if (url != null) CanIPhoto(url: url, fallback: const SizedBox.shrink()),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.white.withValues(alpha: 0), Colors.white.withValues(alpha: 0.9)],
                      stops: const [0.35, 0.78],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      canICategoryLabel(cat),
                      style: pvFraunces(fontSize: 19, fontWeight: FontWeight.w600, height: 1.15, color: p.ink1),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$n answers',
                      style: pvManrope(fontSize: 12, fontWeight: FontWeight.w700, color: p.ink2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
//  A shelf — one category, its groups as chips, the grid under
// -----------------------------------------------------------------------------

class CanIGroupScreen extends StatefulWidget {
  const CanIGroupScreen({super.key, required this.category, required this.controller, this.initialGroup});
  final CanICategory category;
  final PregnancyController controller;
  final String? initialGroup;

  @override
  State<CanIGroupScreen> createState() => _CanIGroupScreenState();
}

class _CanIGroupScreenState extends State<CanIGroupScreen> {
  String? _group;

  @override
  void initState() {
    super.initState();
    _group = widget.initialGroup;
  }

  @override
  Widget build(BuildContext context) {
    final groups = canIGroupsIn(widget.category);
    final shown = _group == null
        ? groups
        : [
            for (final g in groups)
              if (g.id == _group) g,
          ];
    final bracket = bracketById(kCanIBracketId);
    return PvDoorToolScaffold(
      hue: bracket?.hue ?? 232,
      eyebrow: 'Is it safe? · ${canICategoryLabel(widget.category)}',
      title: switch (widget.category) {
        CanICategory.eat => 'Can I eat it?',
        CanICategory.drink => 'Can I drink it?',
        CanICategory.take => 'Can I take it?',
        CanICategory.doActivity => 'Can I do it?',
      },
      intro: switch (widget.category) {
        CanICategory.eat => 'Every food we have an answer for, by shelf. The dot is the verdict; tap for the why.',
        CanICategory.drink => 'From chai to coconut water. The dot is the verdict; tap for the why.',
        CanICategory.take => 'Medicines and supplements. Many are your doctor\'s call — the page says which.',
        CanICategory.doActivity => 'Travel, exercise, beauty, the house. The dot is the verdict; tap for the why.',
      },
      children: [
        Builder(
          builder: (context) {
            final p = V2PaletteStore.instance.current;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: kPvDoorGutter),
                    children: [
                      CanIChip(
                        label: 'All',
                        p: p,
                        selected: _group == null,
                        onTap: () => setState(() => _group = null),
                      ),
                      for (final g in groups) ...[
                        const SizedBox(width: 8),
                        CanIChip(
                          label: g.label,
                          p: p,
                          selected: _group == g.id,
                          onTap: () => setState(() => _group = _group == g.id ? null : g.id),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                for (final g in shown) ...[
                  pvDoorPad(canIHeading(p, g.label)),
                  const SizedBox(height: 12),
                  pvDoorPad(
                    GridView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 10,
                        childAspectRatio: 0.74,
                      ),
                      itemCount: g.entryIds.length,
                      itemBuilder: (_, i) {
                        final e = canIById(g.entryIds[i]);
                        if (e == null) return const SizedBox.shrink();
                        return CanICutoutTile(
                          entry: e,
                          p: p,
                          onTap: () => openCanIAnswer(context, e, widget.controller),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 26),
                ],
                pvDoorPad(
                  PvDoorDisclaimer(p: p, text: 'General guidance, not a prescription. Your doctor has the last word.'),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
