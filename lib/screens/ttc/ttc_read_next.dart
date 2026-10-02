// =============================================================================
//  "Read next" at the foot of a tool screen (2026-10-01)
// -----------------------------------------------------------------------------
//  The user, on Ovulation tests, Supplements and Medication: the article
//  should sit at the bottom of the screen and look "like the way we have at the
//  bottom of each article reader". So a tool names its reads by id and gets the
//  reader's own foot: a rule, "Read next", and the same two-tile rail
//  (`PvReadNextRail`). One function, so the three screens (and any tool after
//  them) cannot drift apart. A read that no longer resolves is simply not
//  drawn, and with none the block is empty.
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/reads/read_images.dart' show readImageFor;
import '../../localization/app_language.dart';
import '../../theme/pv_fonts.dart';
import '../../ttc/ttc_reads_data.dart' show ttcReadById;
import '../reader/pv_read_tile.dart' show PvReadNextRail;
import '../v2/v2_palette.dart';
import 'ttc_common.dart';
import 'ttc_focus_screen.dart' show openTtcArticle;
import 'ttc_tool_chrome.dart';

List<Widget> ttcToolReadNext(
  BuildContext context,
  List<String> readIds, {
  required double hue,
  Key? railKey,
}) {
  final p = V2PaletteStore.instance.current;
  final items = <(String, LocalizedText, LocalizedText?, String?)>[
    for (final id in readIds)
      if (ttcReadById(id) case final r?)
        (id, r.title, r.teaser, readImageFor(r.id, own: r.imageUrl)),
  ];
  if (items.isEmpty) return const [];
  return [
    ttcToolPad(Container(height: 1, color: p.line)),
    const SizedBox(height: 22),
    ttcToolPad(
      Text(
        'Read next',
        style: pvFraunces(
          fontSize: 21,
          height: 1.28,
          fontWeight: FontWeight.w600,
          color: ttcTitleInk,
        ),
      ),
    ),
    const SizedBox(height: 12),
    PvReadNextRail(
      key: railKey,
      items: items,
      lang: AppLanguage.english,
      sidePad: 18,
      onOpen: (id) => openTtcArticle(context, id, hue: hue),
    ),
  ];
}
