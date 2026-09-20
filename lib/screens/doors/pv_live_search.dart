// =============================================================================
//  PvLiveSearch — the search bar's flow, once, for every door
// -----------------------------------------------------------------------------
//  Built 2026-09-20 on Is it safe?, then lifted out at the user's ask: "create
//  this flow as a template so it can be reused for every door wherever the
//  search bar is." The flow is what the lookup apps in the Mobbin library
//  converge on (Yazio, Keeta, Swiggy, Kitchen Stories, Ultrahuman; Woolworths
//  and Instacart for the idle page):
//
//    idle       the field sits in the hero under the blurb; the page is the
//               page — Asked most / the rail / the sections. No history here:
//               history on an idle screen reads as "my past, static, at the
//               top" (the user, on the phone).
//    focused    the field rides to the top of the screen (so the keyboard
//    + empty    sits under her recents, not over them), the hero's words fade,
//               and the sheet shows RECENT (+ Saved where the door has it) as
//               rows she can tap instead of typing. A typing shortcut, not a
//               section.
//    typing     rows replace the recents as she types; the last row is always
//               a way on — "Ask Veda about …" / "Search everywhere".
//    Back       twice: the first closes the keyboard and leaves the rows
//               readable (Android does that by itself; the user's call:
//               "some people would want to see what's happening below"), the
//               second returns to the idle page — it releases the field
//               rather than leaving the door.
//
//  ⚠️ FOCUS IS A STATE OF THE PAGE, NOT OF THE FIELD. Three things change on
//  it — what the sheet shows, where the field sits, what the hero says — and
//  they are one decision. That is why the controller, the field, the fading
//  words and the Back scope are one file: a door takes all four or none.
//
//  What a door supplies: the field's hint, its own `find(query)`, its own row
//  widget, its recents (and saved, if it has them), and what "a way on" means
//  for it. What this file owns: the states, the scroll, the fade, Back.
//
//  Consumers: `can_i_door.dart` (Is it safe?), `pv_door_screen.dart` (every
//  door built on the shell).
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../../widgets/pv_feedback.dart';
import '../v2/v2_palette.dart';
import 'pv_door_chrome.dart';

/// The three states, in one place.
class PvLiveSearch extends ChangeNotifier {
  PvLiveSearch() {
    ctl.addListener(notifyListeners);
    focus.addListener(_onFocus);
  }

  final TextEditingController ctl = TextEditingController();
  final FocusNode focus = FocusNode();

  /// Put on the field's row so the page can scroll it to the top on focus.
  final GlobalKey fieldKey = GlobalKey();

  String get query => ctl.text.trim();

  /// She has typed something: rows replace the page.
  bool get searching => query.isNotEmpty;

  /// The field has focus and is still empty: her recents replace the page.
  bool get recalling => !searching && focus.hasFocus;

  /// Idle: neither.
  bool get idle => !searching && !focus.hasFocus;

  void _onFocus() {
    notifyListeners();
    if (!focus.hasFocus) return;
    // After the frame, so the recall rows exist to scroll over. 4% from
    // the top clears the status bar on every phone tried.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = fieldKey.currentContext;
      if (ctx == null) return;
      Scrollable.ensureVisible(ctx,
          alignment: 0.04, duration: const Duration(milliseconds: 280), curve: Curves.easeOutCubic);
    });
  }

  /// Put a query in the field as if she had typed it (a recent, tapped).
  void run(String q) {
    ctl.text = q;
    ctl.selection = TextSelection.collapsed(offset: q.length);
    focus.requestFocus();
  }

  /// Back to idle: the words gone, the field released.
  void release() {
    if (ctl.text.isNotEmpty) ctl.clear();
    focus.unfocus();
  }

  @override
  void dispose() {
    ctl.removeListener(notifyListeners);
    focus.removeListener(_onFocus);
    ctl.dispose();
    focus.dispose();
    super.dispose();
  }
}

/// How tall the sheet must be while the field is active. A short result
/// list ("Nothing by that name" and two rows) gives the list nothing to
/// scroll over, so the field cannot ride to the top and sits mid-screen
/// under the keyboard (the phone, 2026-09-20). Idle, the sheet keeps its
/// own floor; active, it is at least the screen and the keyboard's room.
double pvLiveSearchSheetMin(BuildContext context, PvLiveSearch search) {
  if (search.idle) return 0;
  final mq = MediaQuery.of(context);
  return mq.size.height + mq.viewInsets.bottom;
}

/// Back, twice. Wrap the door's Scaffold in this.
class PvLiveSearchScope extends StatelessWidget {
  const PvLiveSearchScope({super.key, required this.search, required this.child});
  final PvLiveSearch search;
  final Widget child;

  // Listens itself, so the scope is right even inside a consumer that does
  // not rebuild on the search's changes.
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: search,
        builder: (context, _) => PopScope(
          canPop: search.idle,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) search.release();
          },
          child: child,
        ),
      );
}

/// The hero's words, gone while the field has focus. The page scrolls the
/// field to the top then, and a blurb half under the status bar read as a
/// smudge over the clock on the phone.
class PvLiveSearchWords extends StatelessWidget {
  const PvLiveSearchWords({super.key, required this.search, required this.child});
  final PvLiveSearch search;
  final Widget child;

  @override
  Widget build(BuildContext context) => AnimatedOpacity(
        opacity: search.focus.hasFocus ? 0 : 1,
        duration: const Duration(milliseconds: 200),
        child: child,
      );
}

/// The field: PvSearchBar's geometry (48 high, white, hairline, stadium),
/// live. Sits where the door's search bar sits.
class PvLiveSearchField extends StatelessWidget {
  const PvLiveSearchField({
    super.key,
    required this.search,
    required this.p,
    required this.hint,
    this.onSubmitted,
    this.trailing,
  });
  final PvLiveSearch search;
  final V2Palette p;
  final String hint;
  final ValueChanged<String>? onSubmitted;

  /// A door's own control beside the field (Is it safe? once had scan +
  /// snap here). Null: the clear cross while typing, nothing idle.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Row(key: search.fieldKey, children: [
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: p.surface,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: p.line),
            ),
            child: Row(children: [
              const SizedBox(width: 14),
              Icon(Icons.search_rounded, size: 19, color: p.ink2),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: search.ctl,
                  focusNode: search.focus,
                  textInputAction: TextInputAction.search,
                  onSubmitted: onSubmitted,
                  style: pvManrope(fontSize: 15, color: p.ink1),
                  cursorColor: p.ink1,
                  // ⚠️ EVERY BORDER OFF, NOT JUST THE ENABLED ONE — the theme's
                  // input decoration drew a second box inside the stadium on
                  // the phone (2026-09-19).
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: hint,
                    hintStyle: pvManrope(fontSize: 15, color: p.ink3),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    filled: false,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              if (trailing != null)
                trailing!
              else if (search.searching)
                IconButton(
                  onPressed: () {
                    pvCommitFeedback();
                    search.ctl.clear();
                  },
                  icon: Icon(Icons.close_rounded, size: 18, color: p.ink2),
                  visualDensity: VisualDensity.compact,
                )
              else
                const SizedBox(width: 14),
            ]),
          ),
        ),
      ]);
}

/// "Recent" with Clear at the right — the recall state's heading.
Widget pvLiveSearchRecallHeading(V2Palette p, String label, {VoidCallback? onClear, String? sub}) =>
    pvDoorPad(Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: pvFraunces(fontSize: 22, fontWeight: FontWeight.w600, height: 1.15, color: p.ink1)),
          if (sub != null) ...[
            const SizedBox(height: 4),
            Text(sub, style: pvManrope(fontSize: 13.5, height: 1.45, color: p.ink2)),
          ],
        ]),
      ),
      if (onClear != null)
        PvPress(
          child: InkWell(
            onTap: () {
              pvCommitFeedback();
              onClear();
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Text('Clear', style: pvManrope(fontSize: 13, fontWeight: FontWeight.w700, color: p.ink2)),
            ),
          ),
        ),
    ]));

/// The way on under any result list: one card row with an icon, a title
/// and a meaning line. "Ask Veda about …", "Search everywhere".
class PvLiveSearchWayOn extends StatelessWidget {
  const PvLiveSearchWayOn({
    super.key,
    required this.p,
    required this.icon,
    required this.title,
    required this.line,
    required this.onTap,
  });
  final V2Palette p;
  final IconData icon;
  final String title;
  final String line;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => PvPress(
        child: Material(
          color: p.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: p.line)),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
              child: Row(children: [
                Icon(icon, size: 20, color: p.ink1),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: pvManrope(fontSize: 14.5, fontWeight: FontWeight.w700, color: p.ink1)),
                    const SizedBox(height: 2),
                    Text(line,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: pvManrope(fontSize: 12.5, color: p.ink2)),
                  ]),
                ),
                Icon(Icons.chevron_right_rounded, size: 20, color: p.ink3),
              ]),
            ),
          ),
        ),
      );
}
