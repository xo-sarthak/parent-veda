// =============================================================================
//  Your birth plan — the screen
// -----------------------------------------------------------------------------
//  Renders `kBirthPlanSections` over `BirthPlanStore`, on the door family's
//  tool chrome. Opened from the Labour prep door's "Your choices to make now"
//  rail, surface id `labour/birth_plan`.
//
//  ⚠️ THIS IS THE WORKING VERSION, NOT THE DESIGNED ONE. A Claude Design brief
//  exists for this screen (`docs/design-prompts/BIRTH-PLAN-DESIGN-PROMPT.md`)
//  and what comes back replaces the widgets below. What it must NOT replace is
//  the model, the store or the rules in this header — the brief says the same
//  in its own words. So: keep the presentation cheap and the behaviour right.
//
//  ---------------------------------------------------------------------------
//  ⚠️ IT NEVER SCORES, NEVER REQUIRES, NEVER WARNS
//  ---------------------------------------------------------------------------
//
//  No "3 of 6 sections", no progress bar, no red, no asterisks. A plan with
//  two answers is a plan. This is the same rule the checklist screen states
//  and the door playbook enforces for anything a nervous person fills in.
//
//  ---------------------------------------------------------------------------
//  ⚠️ "TALKED THIS THROUGH WITH MY DOCTOR" IS THE IMPORTANT CONTROL
//  ---------------------------------------------------------------------------
//
//  One tick per section, and it is the ownership rule made visible: she may
//  write anything, and the thing that makes it real is the conversation. It
//  sits at the foot of each section, after the answers, in the section's own
//  tint — present without shouting.
//
//  ---------------------------------------------------------------------------
//  ⚠️ SHARE IS A TEXT MESSAGE, NOT A DOCUMENT
//  ---------------------------------------------------------------------------
//
//  `Share.share` with plain text, the same call as the checklists. It lands
//  in WhatsApp — to her partner, her mother, or herself — which is where a
//  birth plan actually travels in India. A PDF would look finished and would
//  be worse.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/birth_plan_data.dart';
import '../../services/birth_plan_store.dart';
import '../../services/pregnancy_controller.dart';
import '../../theme/pv_fonts.dart';
import '../doors/pv_door_chrome.dart';
import '../doors/pv_door_router.dart' show openPvDoorRead;
import '../v2/v2_palette.dart';
import '../products/pv_store_chrome.dart' show kPvInk;

/// The Labour prep door's hue. Passed as a default rather than read from the
/// bracket so this screen has no dependency on the brackets file.
const double kBirthPlanHue = 344;

class BirthPlanScreen extends StatefulWidget {
  const BirthPlanScreen({
    super.key,
    required this.pregnancy,
    this.hue = kBirthPlanHue,
  });

  final PregnancyController pregnancy;
  final double hue;

  @override
  State<BirthPlanScreen> createState() => _BirthPlanScreenState();
}

class _BirthPlanScreenState extends State<BirthPlanScreen> {
  @override
  void initState() {
    super.initState();
    BirthPlanStore.instance.init();
  }

  Future<void> _share() async {
    final store = BirthPlanStore.instance;
    if (store.isEmpty) return;
    await Share.share(store.summary());
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: Listenable.merge([
          BirthPlanStore.instance,
          V2PaletteStore.instance,
        ]),
        builder: (context, _) {
          final p = V2PaletteStore.instance.current;
          final store = BirthPlanStore.instance;

          return PvDoorToolScaffold(
            hue: widget.hue,
            eyebrow: 'Labour prep',
            title: 'Your birth plan',
            intro: 'One page your hospital can read at 3am. '
                '$kBirthPlanVoice',
            action: store.isEmpty ? null : _ShareBar(p: p, onTap: _share),
            children: [
              for (final s in kBirthPlanSections) ...[
                pvDoorPad(_SectionCard(
                  section: s,
                  hue: widget.hue,
                  p: p,
                  store: store,
                  onOpenRead: s.readId == null
                      ? null
                      : () => openPvDoorRead(
                          context, s.readId!, widget.pregnancy),
                )),
                const SizedBox(height: 14),
              ],

              // ⚠️ THE INVITATION, NOT A BLANK. With nothing answered the share
              // bar is absent, and a screen whose only action has vanished
              // reads as broken. One line says where it went.
              if (store.isEmpty)
                pvDoorPad(Text(
                    "Answer whatever you've thought about. Even two answers is "
                    "a plan. A share button appears once there's something "
                    'to send.',
                    style: pvManrope(
                        fontSize: 12.5, height: 1.55, color: p.ink3))),
              if (!store.isEmpty)
                pvDoorPad(GestureDetector(
                  onTap: () => _confirmClear(context, p),
                  behavior: HitTestBehavior.opaque,
                  child: Text('Start again',
                      style: pvManrope(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: p.ink3)),
                )),
              const SizedBox(height: 22),
              pvDoorPad(PvDoorDisclaimer(
                  p: p,
                  text: "This records what you'd prefer. It isn't medical "
                      'advice, and your hospital may do things differently '
                      'on the day. Your doctor knows your pregnancy.')),
              if (!store.isEmpty) const SizedBox(height: 64),
            ],
          );
        },
      );

  Future<void> _confirmClear(BuildContext context, V2Palette p) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: p.surface,
        title: Text('Start again?',
            style: pvFraunces(
                fontSize: 19, fontWeight: FontWeight.w600, color: p.ink1)),
        content: Text('This clears every answer on the plan. Nothing else.',
            style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink2)),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text('Keep it',
                  style: pvManrope(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: p.ink1))),
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text('Clear',
                  style: pvManrope(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: p.ink3))),
        ],
      ),
    );
    if (yes == true) await BirthPlanStore.instance.clear();
  }
}

// -----------------------------------------------------------------------------
//  One section
// -----------------------------------------------------------------------------

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.section,
    required this.hue,
    required this.p,
    required this.store,
    this.onOpenRead,
  });

  final BpSection section;
  final double hue;
  final V2Palette p;
  final BirthPlanStore store;
  final VoidCallback? onOpenRead;

  @override
  Widget build(BuildContext context) {
    final tint = v2BlockTint(hue % 360, p);
    final deep = HSLColor.fromColor(tint)
        .withSaturation(0.46)
        .withLightness(0.34)
        .toColor();
    final discussed = store.isDiscussed(section.id);

    return PvDoorCard(
      p: p,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(section.title,
            style: pvFraunces(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                height: 1.2,
                letterSpacing: -0.4,
                color: p.ink1)),
        const SizedBox(height: 4),
        Text(section.lead,
            style: pvManrope(fontSize: 12.5, height: 1.5, color: p.ink3)),
        if (onOpenRead != null) ...[
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onOpenRead,
            behavior: HitTestBehavior.opaque,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.menu_book_outlined, size: 14, color: deep),
              const SizedBox(width: 6),
              Text('Read about this first',
                  style: pvManrope(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: deep)),
            ]),
          ),
        ],
        const SizedBox(height: 14),
        for (final q in section.questions) ...[
          Text(q.prompt,
              style: pvManrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                  color: p.ink1)),
          const SizedBox(height: 8),
          if (q.kind == BpKind.text)
            _TextBox(question: q, p: p, store: store)
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in q.choices)
                  _Chip(
                    label: c.label,
                    chosen: store.isChosen(q.id, c.id),
                    tint: tint,
                    p: p,
                    onTap: () => store.toggle(q.id, c.id),
                  ),
              ],
            ),
          const SizedBox(height: 14),
        ],
        // ---- the tick that matters --------------------------------------
        GestureDetector(
          onTap: () => store.setDiscussed(section.id, !discussed),
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            decoration: BoxDecoration(
              color: discussed ? tint : p.ground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: discussed ? Colors.transparent : p.line),
            ),
            child: Row(children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: 20,
                height: 20,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: discussed ? p.ink1 : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: discussed
                      ? null
                      : Border.all(color: p.line, width: 1.5),
                ),
                child: discussed
                    ? const Icon(Icons.check_rounded,
                        size: 13, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text('Talked this through with my doctor',
                    style: pvManrope(
                        fontSize: 13,
                        fontWeight:
                            discussed ? FontWeight.w700 : FontWeight.w500,
                        color: p.ink1)),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.chosen,
    required this.tint,
    required this.p,
    required this.onTap,
  });

  final String label;
  final bool chosen;
  final Color tint;
  final V2Palette p;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        selected: chosen,
        button: true,
        label: label,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              // ⚠️ A CHOSEN CHIP GOES TINTED WITH AN INK EDGE, NOT FILLED. A
              // filled chip on a screen of preferences reads as a decision
              // locked in; a tint reads as "this one, for now".
              color: chosen ? tint : p.surface,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: chosen ? p.ink1 : p.line),
            ),
            child: Text(label,
                style: pvManrope(
                    fontSize: 12.5,
                    height: 1.3,
                    fontWeight: chosen ? FontWeight.w700 : FontWeight.w500,
                    color: p.ink1)),
          ),
        ),
      );
}

/// A free-text answer. Its own controller, seeded from the store, written back
/// on every change.
class _TextBox extends StatefulWidget {
  const _TextBox({required this.question, required this.p, required this.store});

  final BpQuestion question;
  final V2Palette p;
  final BirthPlanStore store;

  @override
  State<_TextBox> createState() => _TextBoxState();
}

class _TextBoxState extends State<_TextBox> {
  late final TextEditingController _c =
      TextEditingController(text: widget.store.text(widget.question.id));

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: p.line),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: TextField(
        controller: _c,
        minLines: 2,
        maxLines: 6,
        style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink1),
        onChanged: (v) => widget.store.setText(widget.question.id, v),
        decoration: InputDecoration(
          isDense: true,
          // ⚠️ `filled: false` — the app theme fills every input grey, and
          // this box draws its own white. See the note on the conditions
          // search field for the lesson.
          filled: false,
          border: InputBorder.none,
          // `border` is the fallback; the theme sets `focusedBorder`
          // separately, so without these a focused field grows a ring.
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          hintText: widget.question.hint,
          hintStyle: pvManrope(fontSize: 13, height: 1.5, color: p.ink3),
        ),
      ),
    );
  }
}

/// The pinned share bar. Appears once anything is answered.
class _ShareBar extends StatelessWidget {
  const _ShareBar({required this.p, required this.onTap});

  final V2Palette p;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.fromLTRB(kPvDoorGutter, 12, kPvDoorGutter,
            12 + MediaQuery.paddingOf(context).bottom),
        decoration: BoxDecoration(
          color: p.ground,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: 50,
            alignment: Alignment.center,
            // One ParentVeda (2026-09-30): the one ink, not the brand
            // violet. Kept for revert: color: p.action.
            decoration: BoxDecoration(
              color: kPvInk,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.ios_share_rounded, size: 17, color: Colors.white),
                const SizedBox(width: 9),
                Text('Share my plan',
                    style: pvManrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.white)),
              ],
            ),
          ),
        ),
      );
}
