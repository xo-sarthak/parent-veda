// =============================================================================
//  The welcome moment — "Dr Meera Rao invited you to ParentVeda"
// -----------------------------------------------------------------------------
//  Shown once, immediately after attribution binds, at the end of onboarding.
//  It is the only interruption this whole module is allowed, and it earns that
//  because it answers a question the parent is actually holding: she scanned a
//  code in a clinic, and this closes the loop.
//
//  What it is NOT: an upsell, a handoff, or a request. There is one button and
//  it says Continue. A partner cannot buy a second button here, because the
//  moment a parent learns that the doctor's card leads somewhere commercial,
//  every future appearance of that doctor's name reads differently.
//
//  Shown via showCareWelcome(), which no-ops when there is no partner — callers
//  never have to check.
// =============================================================================

import 'package:flutter/material.dart';

import '../../care_partner/care_config.dart';
import '../../care_partner/care_partner_store.dart';
import '../post_pregnancy/pp_common.dart';
import 'care_partner_card.dart';

/// Show the welcome if — and only if — this family has a Care Partner.
/// Safe to call unconditionally.
Future<void> showCareWelcome(BuildContext context) async {
  final store = CarePartnerStore.instance;
  final partner = store.partner;
  if (partner == null) return;
  if (!CareConfig.instance.welcomeMomentEnabled) return;
  store.recordEvent('welcome_shown');
  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (_) => _CareWelcomeDialog(store: store),
  );
}

class _CareWelcomeDialog extends StatelessWidget {
  const _CareWelcomeDialog({required this.store});

  final CarePartnerStore store;

  @override
  Widget build(BuildContext context) {
    final partner = store.partner;
    if (partner == null) return const SizedBox.shrink();
    return Dialog(
      backgroundColor: ppBg,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 18),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Welcome to ParentVeda',
              textAlign: TextAlign.center, style: ppFraunces(23, h: 1.15)),
          const SizedBox(height: 8),
          Text(
            'Someone who looks after you brought you here.',
            textAlign: TextAlign.center,
            style: ppBody(12.5, h: 1.5),
          ),
          const SizedBox(height: 18),
          CarePartnerCard(
              partner: partner, shape: CarePartnerCardShape.full),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: ppPurple,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                store.recordEvent('welcome_continued');
                Navigator.of(context).pop();
              },
              child: Text('Continue',
                  style: ppJakarta(14, color: Colors.white)),
            ),
          ),
        ]),
      ),
    );
  }
}
