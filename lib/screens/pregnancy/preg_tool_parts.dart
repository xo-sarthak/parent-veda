// =============================================================================
//  Two small parts shared by the pregnancy tools (2026-10-02)
// -----------------------------------------------------------------------------
//  Both were written for the contraction timer, and the baby movement tracker
//  needed the same two within a day. A second copy would have drifted from the
//  first by the third tool, so they live here, once.
//
//  PregFoldRow      A line that opens. Its icon and title are always on the page
//                   and its body is one tap away. How a tool carries long text
//                   without a paragraph on the screen.
//  pregToolReadNext "Read next" at the foot of a pregnancy tool: a rule, the
//                   heading and the reader's own two-tile rail
//                   (`PvReadNextRail`). The pregnancy twin of
//                   `ttcToolReadNext`, and the same shape for the same reason:
//                   the user asked for the articles at the foot of a tool to look
//                   "the way it's at the end of each article".
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/reads/pregnancy_reads.dart' show pregnancyReadById;
import '../../data/reads/read_images.dart' show readImageFor;
import '../../localization/app_language.dart';
import '../../services/pregnancy_controller.dart';
import '../../theme/pv_fonts.dart';
import '../doors/pv_door_router.dart' show openPvDoorRead;
import '../products/pv_store_chrome.dart' show kPvLine, pvStorePalette;
import '../reader/pv_read_tile.dart' show PvReadNextRail;

/// A line that opens: [icon] and [title] always, [body] on a tap.
///
/// [keyPrefix] names the keys (`<prefix>_<fold>` on the card and
/// `<prefix>_toggle_<fold>` on the tap target), so each tool's tests can find
/// its own folds without two tools' keys colliding.
class PregFoldRow extends StatefulWidget {
  const PregFoldRow({
    super.key,
    required this.keyPrefix,
    required this.fold,
    required this.icon,
    required this.title,
    required this.body,
    this.count,
    this.startOpen = false,
  });

  final String keyPrefix;
  final String fold;
  final IconData icon;
  final String title;
  final Widget body;

  /// A count shown before the chevron (the contractions in a session).
  final String? count;

  /// Open when first drawn (a field she is about to write in).
  final bool startOpen;

  @override
  State<PregFoldRow> createState() => _PregFoldRowState();
}

class _PregFoldRowState extends State<PregFoldRow> {
  late bool _open = widget.startOpen;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return Container(
      key: ValueKey('${widget.keyPrefix}_${widget.fold}'),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kPvLine),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Semantics(
          button: true,
          expanded: _open,
          label: widget.title,
          excludeSemantics: true,
          child: InkWell(
            key: ValueKey('${widget.keyPrefix}_toggle_${widget.fold}'),
            onTap: () => setState(() => _open = !_open),
            child: Container(
              constraints: const BoxConstraints(minHeight: 52),
              padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
              child: Row(children: [
                Icon(widget.icon, size: 20, color: p.ink1),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(widget.title,
                      style: pvManrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          height: 1.3,
                          color: p.ink1)),
                ),
                if (widget.count != null) ...[
                  Text(widget.count!,
                      style: pvManrope(
                          fontSize: 14, fontWeight: FontWeight.w800, color: p.ink1)),
                  const SizedBox(width: 4),
                ],
                AnimatedRotation(
                  turns: _open ? 0.5 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: Icon(Icons.expand_more_rounded, size: 22, color: p.ink2),
                ),
              ]),
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          alignment: Alignment.topCenter,
          child: _open
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                  child: widget.body,
                )
              : const SizedBox(width: double.infinity, height: 0),
        ),
      ]),
    );
  }
}

/// "Read next" at the foot of a pregnancy tool, for the reads named by id.
///
/// A read that no longer resolves is simply not drawn, and with none the
/// result is empty (never a heading over nothing). The tool's own gutter is
/// [sidePad]; the rail's tiles are sized from it.
List<Widget> pregToolReadNext(
  BuildContext context,
  PregnancyController controller,
  List<String> readIds, {
  Key? railKey,
  double sidePad = 18,
}) {
  final p = pvStorePalette;
  final items = <(String, LocalizedText, LocalizedText?, String?)>[
    for (final id in readIds)
      if (pregnancyReadById(id) case final r?)
        (id, r.title, r.teaser, readImageFor(r.id, own: r.imageUrl)),
  ];
  if (items.isEmpty) return const [];
  return [
    Padding(
      padding: EdgeInsets.symmetric(horizontal: sidePad),
      child: Container(height: 1, color: kPvLine),
    ),
    const SizedBox(height: 22),
    Padding(
      padding: EdgeInsets.symmetric(horizontal: sidePad),
      child: Text(
        'Read next',
        style: pvFraunces(
          fontSize: 21,
          height: 1.28,
          fontWeight: FontWeight.w600,
          color: p.ink1,
        ),
      ),
    ),
    const SizedBox(height: 12),
    PvReadNextRail(
      key: railKey,
      items: items,
      lang: controller.language,
      sidePad: sidePad,
      onOpen: (id) => openPvDoorRead(context, id, controller),
    ),
  ];
}
