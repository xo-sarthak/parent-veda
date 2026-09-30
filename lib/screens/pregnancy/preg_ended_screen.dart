// =============================================================================
//  "If your pregnancy has ended" — the confirm screen and the home after it
// -----------------------------------------------------------------------------
//  2026-09-29, from the pregnancy gap analysis ("Behind · After a loss", P1):
//  a quiet row in You › Details opens one gentle screen; if she confirms, the
//  week content stops and her Today becomes a calm page into the After a loss
//  door. Oura keeps the same row in its pregnancy details (Mobbin); What to
//  Expect puts "Report a Loss" in its top menu.
//
//  The words live with the door (lib/data/doors/pv_door_after_loss.dart) so
//  the copy for this whole subject is written, reviewed and changed in one
//  place. This file only arranges them.
//
//  Nothing here deletes anything. The home keeps one small "Go back to my
//  pregnancy view" at its foot, and the You row offers the same undo.
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/doors/pv_door_after_loss.dart';
import '../../services/life_stage_store.dart';
import '../../services/pregnancy_controller.dart';
import '../../services/pregnancy_ended_store.dart';
import '../../services/stage_gateway.dart';
import '../../theme/pv_fonts.dart';
import '../doors/pv_door_screen.dart';
import '../v2/v2_palette.dart';
import '../products/pv_store_chrome.dart' show kPvInk, kPvLine;
import '../doors/pv_list_row.dart' show PvMarkWell;

const String kPregEndedRoute = 'pregnancy/ended';

/// Opens the After a loss door, on a tab when given one.
void openAfterLossDoor(BuildContext context, PregnancyController c, {String? tab}) {
  Navigator.of(context).push(MaterialPageRoute<void>(
    settings: const RouteSettings(name: 'pregnancy/after_loss'),
    builder: (_) => PvDoorScreen(
      page: kAfterLossDoor,
      bracket: kPregAfterLossBracket,
      pregnancy: c,
      initialGroup: tab,
    ),
  ));
}

/// The row in You › Details opens this.
void openPregEnded(BuildContext context, PregnancyController c) {
  Navigator.of(context).push(MaterialPageRoute<void>(
    settings: const RouteSettings(name: kPregEndedRoute),
    builder: (_) => PregEndedConfirmScreen(pregnancy: c),
  ));
}

/// One gentle screen: what changes, and two ways out.
class PregEndedConfirmScreen extends StatelessWidget {
  const PregEndedConfirmScreen({super.key, required this.pregnancy});
  final PregnancyController pregnancy;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: Listenable.merge([PregnancyEndedStore.instance, V2PaletteStore.instance]),
        builder: (context, _) {
          final p = V2PaletteStore.instance.current;
          final ended = PregnancyEndedStore.instance.ended;
          return Scaffold(
            backgroundColor: p.ground,
            appBar: AppBar(
              backgroundColor: p.ground,
              elevation: 0,
              foregroundColor: p.ink1,
            ),
            body: SafeArea(
              top: false,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 4, 22, 32),
                children: [
                  Text(ended ? kPregEndedUndoTitle : kPregEndedTitle,
                      style: pvFraunces(fontSize: 26, fontWeight: FontWeight.w600, height: 1.2, color: p.ink1)),
                  const SizedBox(height: 14),
                  for (final para in (ended ? kPregEndedUndoBody : kPregEndedBody)) ...[
                    Text(para, style: pvManrope(fontSize: 15, height: 1.6, color: p.ink2)),
                    const SizedBox(height: 12),
                  ],
                  const SizedBox(height: 12),
                  _Button(
                    p: p,
                    label: ended ? kPregEndedUndoConfirm : kPregEndedConfirm,
                    filled: true,
                    onTap: () async {
                      if (ended) {
                        await PregnancyEndedStore.instance.undo();
                        if (context.mounted) Navigator.of(context).maybePop();
                      } else {
                        await PregnancyEndedStore.instance.markEnded();
                        if (context.mounted) {
                          Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
                            settings: const RouteSettings(name: 'pregnancy/ended_done'),
                            builder: (_) => PregEndedHome(pregnancy: pregnancy, pushed: true),
                          ));
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  _Button(
                    p: p,
                    label: ended ? kPregEndedUndoCancel : kPregEndedCancel,
                    filled: false,
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                ],
              ),
            ),
          );
        },
      );
}

/// Today, after she has told us. Hers, and his on the partner side.
///
/// ⚠️ A PAGE OF ITS OWN, NOT THE DOOR ITSELF AS THE TAB. The door's hero has a
/// back button, and on a root tab that button would do nothing. So Today is a
/// calm page whose rows open the door on each tab, which is also a gentler
/// first thing to see than a full library.
class PregEndedHome extends StatelessWidget {
  const PregEndedHome({super.key, required this.pregnancy, this.forPartner = false, this.pushed = false});
  final PregnancyController pregnancy;
  final bool forPartner;

  /// True when opened straight after confirming (it then has a back arrow).
  final bool pushed;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final rows = <({String title, String sub, IconData icon, VoidCallback onTap})>[
      for (final g in kAfterLossDoor.groups)
        (
          title: g.label,
          sub: kPregEndedTabLines[g.id] ?? '',
          icon: g.icon,
          onTap: () => openAfterLossDoor(context, pregnancy, tab: g.id),
        ),
    ];
    return Scaffold(
      backgroundColor: p.ground,
      appBar: pushed
          ? AppBar(backgroundColor: p.ground, elevation: 0, foregroundColor: p.ink1)
          : null,
      body: SafeArea(
        top: !pushed,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 120),
          children: [
            Text(forPartner ? kPregEndedPartnerTitle : kPregEndedHomeTitle,
                style: pvFraunces(fontSize: 28, fontWeight: FontWeight.w600, height: 1.2, color: p.ink1)),
            const SizedBox(height: 12),
            Text(forPartner ? kPregEndedPartnerBody : kPregEndedDone,
                style: pvManrope(fontSize: 15, height: 1.6, color: p.ink2)),
            const SizedBox(height: 22),
            for (final r in rows)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                // One ParentVeda: white with a hairline, not a tinted block
                // behind the words. Was: color: p.surfaceAlt.
                child: Material(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16), side: const BorderSide(color: kPvLine)),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: r.onTap,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
                      child: Row(children: [
                        // The tab's glyph in a tinted well: the door's own
                        // icon, as the door's rail draws it.
                        PvMarkWell(p: p, hue: 344, size: 40, icon: r.icon),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(r.title, style: pvManrope(fontSize: 15, fontWeight: FontWeight.w700, color: p.ink1)),
                            if (r.sub.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(r.sub, style: pvManrope(fontSize: 13, height: 1.45, color: p.ink2)),
                            ],
                          ]),
                        ),
                        Icon(Icons.chevron_right_rounded, color: p.ink3),
                      ]),
                    ),
                  ),
                ),
              ),
            if (!forPartner) ...[
              const SizedBox(height: 18),
              Center(
                child: TextButton(
                  onPressed: () => openPregEnded(context, pregnancy),
                  child: Text(kPregEndedUndoLink,
                      style: pvManrope(fontSize: 13, fontWeight: FontWeight.w600, color: p.ink3)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// "When you're ready to try again": the Trying again tab's tool tile.
///
/// ⚠️ THE STAGE SWITCH THE APP ALREADY HAS, AND NOTHING NEW ON THE TTC SIDE.
/// `LifeStageStore.setStage` plus `openStageDoor`, exactly as the stage menu
/// does. What TTC should do for someone arriving this way is written down in
/// docs/PREG-TTC-HANDOFF.md §2 rather than built here.
class PregTryAgainScreen extends StatelessWidget {
  const PregTryAgainScreen({super.key});

  static const String _title = "When you're ready to try again";
  static const List<String> _body = [
    "There's no right time, and no rush. Some couples feel ready within a few "
        'months. Others need much longer, and that is just as normal.',
    'When you choose, ParentVeda can move to the side for trying to conceive, '
        'with your cycle, your fertile days and gentle reads for trying after a '
        'loss. Nothing from your pregnancy is deleted, and you can come back to '
        'these pages whenever you need them.',
    "It's a good idea to talk to your doctor first, especially about when to "
        'start trying and any tests they suggest.',
  ];

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return Scaffold(
      backgroundColor: p.ground,
      appBar: AppBar(backgroundColor: p.ground, elevation: 0, foregroundColor: p.ink1),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 4, 22, 32),
          children: [
            Text(_title,
                style: pvFraunces(fontSize: 26, fontWeight: FontWeight.w600, height: 1.2, color: p.ink1)),
            const SizedBox(height: 14),
            for (final para in _body) ...[
              Text(para, style: pvManrope(fontSize: 15, height: 1.6, color: p.ink2)),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 12),
            _Button(
              p: p,
              label: "I'm ready. Move to trying to conceive",
              filled: true,
              onTap: () {
                LifeStageStore.instance.setStage(LifeStage.tryingToConceive);
                openStageDoor(context, StageDoor.tryingToConceive);
              },
            ),
            const SizedBox(height: 10),
            _Button(
              p: p,
              label: 'Not yet',
              filled: false,
              onTap: () => Navigator.of(context).maybePop(),
            ),
          ],
        ),
      ),
    );
  }
}

class _Button extends StatelessWidget {
  const _Button({required this.p, required this.label, required this.filled, required this.onTap});
  final V2Palette p;
  final String label;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 52,
        child: Material(
          // The one ink for everything pressable (#2F2C30).
          color: filled ? kPvInk : Colors.transparent,
          shape: StadiumBorder(side: BorderSide(color: filled ? kPvInk : p.line)),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Center(
              child: Text(label,
                  style: pvManrope(fontSize: 15, fontWeight: FontWeight.w700, color: filled ? Colors.white : p.ink1)),
            ),
          ),
        ),
      );
}
