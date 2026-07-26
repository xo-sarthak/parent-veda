// =============================================================================
//  CarePartnerSlot — drop this where a partner MAY appear
// -----------------------------------------------------------------------------
//  A screen should not know whether this family has a Care Partner, whether the
//  partner is still active, whether this topic is one they cover, whether the
//  card was already shown today, or whether she dismissed it yesterday. It
//  should say only:
//
//      CarePartnerSlot(surface: CareSurface.topic, topic: CareTopic.breastfeeding)
//
//  and get a quiet line, or nothing at all. The rules live in CareVisibility,
//  the memory in CarePresenceStore, the pixels in CarePartnerCard; this is the
//  seam between them.
//
//  It renders SizedBox.shrink() when there is nothing to show — deliberately
//  the empty case, because unlike a feature (which always shows a CTA rather
//  than vanishing) a partner credit is not a feature. A parent with no partner
//  has nothing missing; inviting her to "find a care partner" would turn an
//  attribution mechanism into an advert, which is the one thing this module
//  must never become.
// =============================================================================

import 'package:flutter/material.dart';

import '../../care_partner/care_config.dart';
import '../../care_partner/care_partner_store.dart';
import '../../care_partner/care_presence_store.dart';
import '../../care_partner/care_visibility.dart';
import '../post_pregnancy/pp_common.dart';
import 'care_circle_screen.dart';
import 'care_partner_card.dart';

class CarePartnerSlot extends StatefulWidget {
  const CarePartnerSlot({
    super.key,
    required this.surface,
    this.topic,
    this.stage,
    this.shape = CarePartnerCardShape.line,
    this.padding = EdgeInsets.zero,
  });

  final CareSurface surface;
  final String? topic;
  final String? stage;
  final CarePartnerCardShape shape;
  final EdgeInsets padding;

  @override
  State<CarePartnerSlot> createState() => _CarePartnerSlotState();
}

class _CarePartnerSlotState extends State<CarePartnerSlot> {
  final _store = CarePartnerStore.instance;
  final _presence = CarePresenceStore.instance;

  /// The decision is taken ONCE per mount and then held.
  ///
  /// It has to be: marking the card as shown is exactly the thing that makes
  /// the rule say "not again today", so re-deciding on the next rebuild would
  /// make it vanish mid-scroll.
  bool? _visible;

  @override
  void initState() {
    super.initState();
    _store.init();
    _presence.init().then((_) {
      if (mounted) setState(_decide);
    });
    _decide();
  }

  void _decide() {
    if (_visible != null) return;
    final partner = _store.partner;
    if (partner == null) return; // stay undecided until one loads
    final rule = CareConfig.instance.ruleFor(partner);
    final show = CareVisibility.shouldShow(
      partner: partner,
      rule: rule,
      context: CareContext(
        surface: widget.surface,
        topic: widget.topic,
        stage: widget.stage,
      ),
      dismissed:
          _presence.isDismissed(partner.id, widget.surface, widget.topic),
      lastShown: _presence.lastShown(partner.id, widget.surface, widget.topic),
    );
    _visible = show;
    if (show) {
      _presence.markShown(partner.id, widget.surface, widget.topic);
      _store.recordEvent('partner_shown',
          detail: '${widget.surface.name}:${widget.topic ?? ''}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _store,
      builder: (context, _) {
        if (_visible == null) {
          _decide();
          // Still nothing loaded — occupy no space rather than reserving room
          // for a card that may never come.
          if (_visible == null) return const SizedBox.shrink();
        }
        final partner = _store.partner;
        if (_visible != true || partner == null) {
          return const SizedBox.shrink();
        }

        final rule = CareConfig.instance.ruleFor(partner);
        final card = CarePartnerCard(
          partner: partner,
          shape: widget.shape,
          padding: EdgeInsets.zero,
          onTap: () {
            _store.recordEvent('partner_tapped', detail: widget.surface.name);
            Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const CareCircleScreen()));
          },
        );

        return Padding(
          padding: widget.padding,
          child: rule.dismissible
              ? Row(children: [
                  Expanded(child: card),
                  // A small, unlabelled dismiss. She is closing a card, not
                  // reporting a doctor - anything heavier would make the
                  // presence feel like something to defend against.
                  GestureDetector(
                    onTap: () {
                      _presence.dismiss(
                          partner.id, widget.surface, widget.topic);
                      _store.recordEvent('partner_dismissed',
                          detail: widget.surface.name);
                      setState(() => _visible = false);
                    },
                    behavior: HitTestBehavior.opaque,
                    child: const Padding(
                      padding: EdgeInsets.fromLTRB(10, 8, 2, 8),
                      child: Icon(Icons.close_rounded, size: 15, color: ppSoft),
                    ),
                  ),
                ])
              : card,
        );
      },
    );
  }
}
