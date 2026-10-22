// =============================================================================
//  ttc_treatment_journey.dart - the IVF door's "Step by step" tab
// =============================================================================
//
// The user (2026-10-22): IVF and IUI are hard to understand "until and unless
// you go to a doctor", so the door must show what happens at each step, and
// "vids should be first thing user sees ... dont place vid in the last of the
// rail". Prototype approved the same day (MOBBIN-DISCOVERY §33: MasterClass
// curriculum, Alan's step timeline, Acorns' numbered lessons).
//
// One switch (IUI, IVF, Frozen transfer), then a vertical timeline: each card
// opens with the step's video, then what happens, how long, whether it hurts,
// and one thing to ask the clinic, then "Read more". The words and the steps
// live in `lib/ttc/ttc_treatment_journey.dart`; this file only draws them.
//
// ⚠️ "YOU ARE HERE" IS DERIVED, NEVER ASKED. With a round open, the switch
// starts on her round's kind and the step comes from her dates
// (`ttcTreatmentPhase`), the same rule as the round tracker.
//
// ⚠️ NEVER A PLAY GLYPH ON A FILM THAT CANNOT PLAY (launch sanity D3): an
// unmade film wears a clock and "Coming soon", and its tap opens the notes
// sheet every other unmade film opens (`openTtcFocusTile`).
// =============================================================================

import 'package:flutter/material.dart';

import '../../../data/reads/read_images.dart' show pvFilmStillFor;
import '../../../ttc/ttc_focus_data.dart' show TtcVideoTile;
import '../../../ttc/ttc_treatment_journey.dart';
import '../../../ttc/ttc_treatment_round.dart' show ttcTreatmentPhase;
import '../../../ttc/ttc_treatment_store.dart' show TtcTreatmentStore;
import '../../../ttc/ttc_videos_data.dart' show ttcVideoBySlot;
import '../../../widgets/pv_feedback.dart' show PvPress;
import '../ttc_common.dart';
import '../ttc_focus_screen.dart' show openTtcArticle, openTtcFocusTile;
import 'ttc_door_screen.dart' show kTtcFilmComingSoon;

/// The surface id the IVF door's first group renders inline
/// (`ttcInlineToolFor`).
const String kTtcTreatmentJourneySurface = 'ttc_treatment_journey';

/// The door's blue, the hue the "Understand treatment" tab already wears.
const double _kHue = 206;

/// Plain neutral grey, never lavender (user 2026-10-21).
const Color _kGrey = Color(0xFFF3F3F4);

class TtcTreatmentJourneyBody extends StatefulWidget {
  const TtcTreatmentJourneyBody({super.key, this.now});

  /// The day "You are here" is read on. Tests pass it; the app uses now.
  final DateTime? now;

  @override
  State<TtcTreatmentJourneyBody> createState() =>
      _TtcTreatmentJourneyBodyState();
}

class _TtcTreatmentJourneyBodyState extends State<TtcTreatmentJourneyBody> {
  /// Her pick on the switch. Null follows her round, else IVF.
  TtcJourneyKind? _picked;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: TtcTreatmentStore.instance,
      builder: (context, _) {
        final c = TtcTreatmentStore.instance.cycle;
        final open = !c.isEmpty && !c.isClosed;
        final roundKind = open ? ttcJourneyKindFor(c.kind) : null;
        final kind = _picked ?? roundKind ?? TtcJourneyKind.ivf;
        final here = roundKind == kind
            ? ttcJourneyHere(kind, ttcTreatmentPhase(c, widget.now ?? DateTime.now()))
            : null;
        final steps = kTtcJourney[kind]!;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: ttcGutter),
          child: Column(
            key: const ValueKey('ttc_journey'),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('What happens at each step?',
                  style: ttcBody(16.5, color: ttcInk, w: FontWeight.w800)),
              const SizedBox(height: 10),
              _switch(kind),
              const SizedBox(height: 8),
              Text(
                here != null
                    ? 'Showing your round. You are on step ${here + 1}.'
                    : 'Your clinic may change the order a little.',
                style: ttcBody(12.5, color: ttcMuted, h: 1.4),
              ),
              const SizedBox(height: 14),
              for (var i = 0; i < steps.length; i++)
                _StepRow(
                  step: steps[i],
                  n: i + 1,
                  last: i == steps.length - 1,
                  here: here == i,
                  done: here != null && i < here,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _switch(TtcJourneyKind kind) => Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
            color: _kGrey, borderRadius: BorderRadius.circular(999)),
        child: Row(children: [
          for (final k in TtcJourneyKind.values)
            Expanded(
              child: PvPress(child: GestureDetector(
                key: ValueKey('ttc_journey_kind_${k.name}'),
                onTap: () => setState(() => _picked = k),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 140),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: k == kind ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: k == kind
                        ? const [
                            BoxShadow(
                                color: Color(0x14000000),
                                blurRadius: 3,
                                offset: Offset(0, 1)),
                          ]
                        : null,
                  ),
                  child: Text(k.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ttcBody(13,
                          color: k == kind ? ttcInk : ttcMuted,
                          w: FontWeight.w800)),
                ),
              )),
            ),
        ]),
      );
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.step,
    required this.n,
    required this.last,
    required this.here,
    required this.done,
  });

  final TtcJourneyStep step;
  final int n;
  final bool last;
  final bool here;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // The timeline: a numbered dot and the dashed line down to the next.
        SizedBox(
          width: 30,
          child: Column(children: [
            const SizedBox(height: 10),
            Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: here ? ttcTitleInk : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                    color: here || done ? ttcTitleInk : ttcLine, width: 2),
              ),
              child: done
                  ? const Icon(Icons.check_rounded,
                      size: 14, color: ttcTitleInk)
                  : Text('$n',
                      style: ttcBody(11,
                          color: here ? Colors.white : ttcMuted,
                          w: FontWeight.w800)),
            ),
            if (!last)
              Expanded(
                child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: ttcLine),
              ),
          ]),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _card(context),
          ),
        ),
      ]),
    );
  }

  Widget _card(BuildContext context) {
    final film = ttcVideoBySlot(step.videoSlotId);
    final live = film?.isLive ?? false;
    final still = pvFilmStillFor(step.videoSlotId);
    final grey = Container(color: _kGrey);
    return Container(
      key: ValueKey('ttc_journey_step_${step.key}'),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: here ? ttcTitleInk : ttcLine, width: here ? 2 : 1),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // ---- the video, first --------------------------------------------
        PvPress(child: GestureDetector(
          key: ValueKey('ttc_journey_video_${step.key}'),
          onTap: () => openTtcFocusTile(
            context,
            TtcVideoTile(
              title: film?.title.en ?? step.title,
              blurb: film?.why.en ?? step.what,
              slotId: step.videoSlotId,
              duration: '${step.videoMinutes} MIN',
            ),
            _kHue,
          ),
          behavior: HitTestBehavior.opaque,
          child: AspectRatio(
            aspectRatio: 2,
            child: Stack(fit: StackFit.expand, children: [
              if (still == null)
                grey
              else
                Image.network(still,
                    fit: BoxFit.cover, errorBuilder: (_, _, _) => grey),
              if (here)
                Positioned(
                  left: 10,
                  top: 10,
                  child: _badge('You are here', ink: true),
                ),
              Positioned(
                left: 10,
                bottom: 10,
                child: _badge(
                  live
                      ? '${step.videoMinutes} min'
                      : '$kTtcFilmComingSoon · ${step.videoMinutes} min',
                  icon: live
                      ? Icons.play_arrow_rounded
                      : Icons.schedule_rounded,
                ),
              ),
            ]),
          ),
        )),
        // ---- what happens ---------------------------------------------------
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      Text(step.title,
                          style: ttcBody(15.5,
                              color: ttcInk, h: 1.3, w: FontWeight.w800)),
                      if (step.someClinics)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                              color: _kGrey,
                              borderRadius: BorderRadius.circular(999)),
                          child: Text('Some clinics',
                              style: ttcBody(11,
                                  color: ttcMuted, w: FontWeight.w800)),
                        ),
                    ]),
                const SizedBox(height: 4),
                Text(step.what,
                    style: ttcBody(13.5, color: ttcInk, h: 1.5)),
                const SizedBox(height: 10),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: _fact('How long', step.howLong)),
                  const SizedBox(width: 8),
                  Expanded(child: _fact('Does it hurt?', step.hurts)),
                ]),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.only(left: 10),
                  decoration: const BoxDecoration(
                      border: Border(
                          left: BorderSide(color: ttcTitleInk, width: 3))),
                  child: Text.rich(
                    TextSpan(children: [
                      TextSpan(
                          text: 'Ask your clinic: ',
                          style: ttcBody(13,
                              color: ttcInk, w: FontWeight.w800)),
                      TextSpan(
                          text: step.ask,
                          style: ttcBody(13, color: ttcInk, h: 1.45)),
                    ]),
                  ),
                ),
                const SizedBox(height: 10),
                PvPress(child: GestureDetector(
                  key: ValueKey('ttc_journey_read_${step.key}'),
                  onTap: () => openTtcArticle(context, step.readId, hue: _kHue),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text('Read more',
                        style: ttcBody(13,
                                color: ttcTitleInk, w: FontWeight.w800)
                            .copyWith(decoration: TextDecoration.underline)),
                  ),
                )),
              ]),
        ),
      ]),
    );
  }

  Widget _fact(String label, String value) => Container(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
        decoration: BoxDecoration(
            color: _kGrey, borderRadius: BorderRadius.circular(12)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label.toUpperCase(),
              style: ttcBody(10, color: ttcMuted, w: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(value, style: ttcBody(12.5, color: ttcInk, h: 1.4)),
        ]),
      );

  Widget _badge(String label, {IconData? icon, bool ink = false}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: ink ? ttcTitleInk : Colors.black.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: Colors.white),
            const SizedBox(width: 4),
          ],
          Text(label,
              style: ttcBody(11.5, color: Colors.white, w: FontWeight.w800)),
        ]),
      );
}
