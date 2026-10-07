// =============================================================================
//  NameListScreen - the no-swipe way to browse names (accessibility + choice)
// -----------------------------------------------------------------------------
//  The destination for "Just show me names": a calm, scrollable list parents can
//  browse and search without any gesture. Each name can be opened (full story),
//  liked (into the shared shortlist) with a large, labelled tap target, and the
//  shortlist / compare is one tap away. Nothing here requires swiping.
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../../widgets/global_ask_fab.dart' show kAskFabReserve;
import '../doors/pv_list_row.dart';
import '../pregnancy/preg_chrome.dart' show pregGroupLabelStyle, pregPageTitleStyle;
import '../pregnancy/preg_tool_chrome.dart' show pregToolPad;
import '../products/pv_store_chrome.dart' show PvChip, kPvInk, pvStorePalette;
import '../v2/v2_palette.dart';
import 'name_journey_detail_screen.dart';
import 'name_journey_shortlist_screen.dart';
import 'pp_common.dart';
import 'pp_names_data.dart';
import 'pp_section_extras.dart';

class NameListScreen extends StatefulWidget {
  const NameListScreen({super.key});

  @override
  State<NameListScreen> createState() => _NameListScreenState();
}

class _NameListScreenState extends State<NameListScreen> {
  final TextEditingController _searchCtl = TextEditingController();
  String _q = '';

  @override
  void dispose() {
    _searchCtl.dispose();
    super.dispose();
  }

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);
  void _push(Widget s) => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => s));

  // The filters the naming home promises ("Every name, with filters for
  // community and region", 2026-10-07): the same three the taste quiz asks,
  // over the same `namesFiltered`. Defaults are "everything".
  String _gender = 'Both';
  String _community = 'Any';
  String _region = 'Any';

  List<BabyName> get _results {
    final base = (_gender == 'Both' && _community == 'Any' && _region == 'Any')
        ? kBabyNames
        : namesFiltered(gender: _gender, community: _community, region: _region);
    if (_q.trim().isEmpty) return base;
    final q = _q.toLowerCase();
    return base.where((n) => '${n.name} ${n.meaningShort} ${n.script} ${n.feel} ${n.origin}'.toLowerCase().contains(q)).toList();
  }

  // ---- the one ParentVeda look (2026-10-07) ------------------------------------
  //  A pushed list page as pregnancy draws one (WatchLearnScreen, the Learn
  //  lists): white ground, an app bar carrying only the back arrow, the serif
  //  page title, a stadium search, ink chips, and the names as unboxed rows
  //  (PvRowGroup's hairlines, drawn row by row so 2,000 names build lazily).
  //  `_buildBeforeShell` is the page before, kept for revert.
  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return Scaffold(
      backgroundColor: p.ground,
      appBar: AppBar(
        backgroundColor: p.ground,
        surfaceTintColor: Colors.transparent,
        foregroundColor: p.ink1,
      ),
      body: AnimatedBuilder(
        animation: NameMatchStore.instance,
        builder: (context, _) {
          final results = _results;
          final head = <Widget>[
            pregToolPad(Semantics(header: true, child: Text('Take your time', style: pregPageTitleStyle()))),
            const SizedBox(height: 8),
            pregToolPad(Text('Scroll, search and tap any name to read its story or add it to your shortlist. No swiping needed.',
                style: pvManrope(fontSize: 14, height: 1.5, color: p.ink2))),
            const SizedBox(height: 16),
            pregToolPad(_searchShell(p)),
            const SizedBox(height: 16),
            _chipRow([for (final g in kNameGenders) (g == 'Both' ? 'All names' : g, g)], _gender, (v) => setState(() => _gender = v)),
            const SizedBox(height: 14),
            pregToolPad(Text('COMMUNITY', style: pregGroupLabelStyle())),
            const SizedBox(height: 8),
            _chipRow([for (final c in kNameCommunities) (c, c)], _community, (v) => setState(() => _community = v)),
            const SizedBox(height: 14),
            pregToolPad(Text('REGION', style: pregGroupLabelStyle())),
            const SizedBox(height: 8),
            _chipRow([for (final r in kNameRegions) (r, r)], _region, (v) => setState(() => _region = v)),
            const SizedBox(height: 18),
            pregToolPad(PvRowGroup(p: p, children: [
              PvListRow(
                key: const ValueKey('pp_name_list_shortlist'),
                p: p,
                leading: PvMarkWell(p: p, hue: 344, size: 40, icon: Icons.favorite_border_rounded),
                title: '${NameMatchStore.instance.likedCount} in your shortlist',
                line: 'View and compare',
                onTap: () => _push(const NameJourneyShortlistScreen()),
              ),
            ])),
            const SizedBox(height: 22),
            pregToolPad(Text('${results.length} ${results.length == 1 ? 'name' : 'names'}',
                key: const ValueKey('pp_name_list_count'),
                style: pvManrope(fontSize: 12.5, fontWeight: FontWeight.w700, color: p.ink3))),
            const SizedBox(height: 6),
          ];
          return ListView.builder(
            padding: const EdgeInsets.only(top: 4, bottom: kAskFabReserve),
            itemCount: head.length + (results.isEmpty ? 1 : results.length + 1),
            itemBuilder: (context, i) {
              if (i < head.length) return head[i];
              if (results.isEmpty) {
                return pregToolPad(Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text('No names match that yet. Try a different word or filter, or clear the search to see them all.',
                      style: pvManrope(fontSize: 14, height: 1.5, color: p.ink2)),
                ));
              }
              final j = i - head.length;
              final rule = Divider(height: 1, thickness: 1, color: p.line);
              // The hairline above each row and one below the last: PvRowGroup's
              // rule, laid out one row at a time.
              if (j == results.length) return pregToolPad(rule);
              return pregToolPad(Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [rule, _rowShell(p, results[j])],
              ));
            },
          );
        },
      ),
    );
  }

  Widget _searchShell(V2Palette p) => Container(
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
              controller: _searchCtl,
              onChanged: (v) => setState(() => _q = v),
              style: pvManrope(fontSize: 15, color: p.ink1),
              cursorColor: p.ink1,
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Search names, meanings, origins',
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
          if (_searchCtl.text.isNotEmpty)
            IconButton(
              tooltip: 'Clear the search',
              onPressed: () => setState(() {
                _searchCtl.clear();
                _q = '';
              }),
              icon: Icon(Icons.close_rounded, size: 18, color: p.ink2),
              visualDensity: VisualDensity.compact,
            )
          else
            const SizedBox(width: 14),
        ]),
      );

  /// One row of ink chips, scrolling sideways on the page gutter.
  Widget _chipRow(List<(String, String)> options, String selected, ValueChanged<String> onPick) {
    final scaler = MediaQuery.textScalerOf(context);
    return SizedBox(
      height: (scaler.scale(13) * 1.4 + 18).clamp(36.0, 60.0),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        itemCount: options.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (_, i) => Center(
          child: PvChip(
            label: options[i].$1,
            selected: selected == options[i].$2,
            onTap: () => onPick(options[i].$2),
          ),
        ),
      ),
    );
  }

  Widget _rowShell(V2Palette p, BabyName n) {
    final liked = NameMatchStore.instance.isLiked(n.name);
    return PvListRow(
      key: ValueKey('pp_name_list_row_${n.name}'),
      p: p,
      // The name's first letter in the naming tool's tint: a contact list's
      // well, so two thousand rows are not two thousand identical icons.
      leading: nameLetterWell(p, n),
      title: n.name,
      line: n.meaningShort,
      meta: n.script,
      onTap: () => _push(NameJourneyDetailScreen(name: n.name)),
      // A large, labelled like target: no gesture required.
      trailing: Semantics(
        button: true,
        label: liked ? '${n.name} is in your shortlist' : 'Add ${n.name} to shortlist',
        excludeSemantics: true,
        child: InkWell(
          onTap: () => NameMatchStore.instance.like(n.name),
          borderRadius: BorderRadius.circular(999),
          child: SizedBox(
            width: 48,
            height: 48,
            child: Center(
              child: Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: liked ? kPvInk : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: liked ? kPvInk : p.line),
                ),
                child: Icon(liked ? Icons.favorite : Icons.favorite_border, size: 18, color: liked ? Colors.white : kPvInk),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Kept for revert (2026-10-07): the page before the shared look.
  // ignore: unused_element
  Widget _buildBeforeShell(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: Stack(children: [
        SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: NameMatchStore.instance,
          builder: (context, _) {
            final results = _results;
            return ListView(
              padding: const EdgeInsets.only(top: 12, bottom: 40),
              children: [
                _pad(ppBack(context, 'Baby Names')),
                const SizedBox(height: 18),
                _pad(ppEyebrow('Browse names', color: ppPurple)),
                const SizedBox(height: 8),
                _pad(Text('Take your time', style: ppFraunces(28, h: 1.12))),
                const SizedBox(height: 6),
                _pad(Text('Scroll, search and tap any name to read its story or add it to your shortlist. No swiping needed.', style: ppBody(14, h: 1.55))),

                const SizedBox(height: 16),
                _pad(ppSearchField(
                  controller: _searchCtl,
                  hint: 'Search names, meanings, origins…',
                  onChanged: (v) => setState(() => _q = v),
                )),

                const SizedBox(height: 14),
                _pad(AnimatedBuilder(
                  animation: NameMatchStore.instance,
                  builder: (context, _) => GestureDetector(
                    onTap: () => _push(const NameJourneyShortlistScreen()),
                    behavior: HitTestBehavior.opaque,
                    child: Row(children: [
                      const Icon(Icons.favorite, size: 15, color: ppPurple),
                      const SizedBox(width: 8),
                      Expanded(child: Text('${NameMatchStore.instance.likedCount} in your shortlist', style: ppBody(13, color: ppPurple, w: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)),
                      const SizedBox(width: 10),
                      Text('View & compare →', style: ppBody(12.5, color: ppPurple, w: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ]),
                  ),
                )),

                const SizedBox(height: 16),
                if (results.isEmpty)
                  _pad(_empty())
                else
                  _pad(Column(children: [for (final n in results) _row(n)])),
              ],
            );
          },
        ),
      ),
      ]),
    );
  }

  Widget _empty() => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(16)),
        child: Text('No names match that yet. Try a different word, or clear the search to see them all.', style: ppBody(13.5, color: ppMuted, h: 1.5)),
      );

  Widget _row(BabyName n) {
    final liked = NameMatchStore.instance.isLiked(n.name);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: ppHair)),
      child: Row(children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _push(NameJourneyDetailScreen(name: n.name)),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Flexible(child: Text(n.name, style: ppFraunces(20, h: 1.05), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  const SizedBox(width: 8),
                  Flexible(child: Text(n.script, style: ppFraunces(15, color: ppPurple), maxLines: 1, overflow: TextOverflow.ellipsis)),
                ]),
                const SizedBox(height: 4),
                Text(n.meaningShort, style: ppBody(13, h: 1.4), maxLines: 1, overflow: TextOverflow.ellipsis),
              ]),
            ),
          ),
        ),
        // large, labelled like target - no gesture required
        GestureDetector(
          onTap: () => NameMatchStore.instance.like(n.name),
          behavior: HitTestBehavior.opaque,
          child: Semantics(
            button: true,
            label: liked ? '${n.name} is in your shortlist' : 'Add ${n.name} to shortlist',
            child: Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: liked ? ppPurple : ppPanel, shape: BoxShape.circle),
                child: Icon(liked ? Icons.favorite : Icons.favorite_border, size: 19, color: liked ? Colors.white : ppPurple),
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
      ]),
    );
  }
}
