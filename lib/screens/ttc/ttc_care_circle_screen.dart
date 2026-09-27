// =============================================================================
//  TTC - Care Circle
// -----------------------------------------------------------------------------
//      "Instead of Doctor, Hospital, Partner being isolated, the app introduces
//       Your Care Circle... showing that building a family is a shared
//       journey."                                        - TTC master, §2.15
//
//      "Every recommendation stores its source. Everything becomes transparent.
//       Users know why something appears."               - TTC master, §4.13
//
//  The second quote is the one that matters technically, and it is why this
//  screen exists rather than a contacts list: the Care Circle is the visible
//  half of recommendation provenance. A parent should be able to look at any
//  suggestion in the product and trace it to someone.
//
//  Today the circle holds ParentVeda and the partner. Adding doctors, clinics
//  and nutritionists needs the care-partner attribution question settled first
//  (docs/STILL-OPEN.md §2.1) - so this screen shows the shape honestly rather
//  than pretending to a fuller circle than the platform can currently keep.
// =============================================================================

import 'package:flutter/material.dart';

import '../../services/life_stage_store.dart' show LifeStage;
import '../../theme/pv_fonts.dart';
import '../../ttc/ttc_store.dart';
import '../profile/pv_partner_screen.dart';
import '../v2/v2_palette.dart';
import 'ttc_common.dart';
import 'ttc_prepare_screen.dart';
import 'ttc_strings.dart';
import 'ttc_surface_router.dart' show openTtcSurface;
import 'ttc_tool_chrome.dart';

/// The four "add" rows (doctor, nutritionist, psychologist, clinic). Off
/// until adding them does something; the rows are kept, not deleted.
const bool kTtcCareCircleShowAddRows = false;

/// The clinic hue, the one the Tools hub gives "Care and medicines".
const double kTtcCareCircleHue = 206;

// =============================================================================
//  The care circle, rebuilt as "your team" (2026-09-27, tools rebuild)
// -----------------------------------------------------------------------------
//  The morning pass took four dead plus buttons off. What was left was two
//  cards (ParentVeda, your partner) and a promise, which is a status page,
//  not a tool: the user's verdict, "old tools in new clothes".
//
//  The shape is Noom's "Your team"
//  (https://mobbin.com/screens/89d5923b-e1ce-4e93-8019-ebb1c622d64c): each
//  person says what they are for AND how to reach them, right there. So the
//  circle is now four rows, each with one action that works today:
//
//    ParentVeda        where the advice here comes from      (no action)
//    Your partner      invite, or see what he can see         the partner page
//    Your doctor       visits and questions in one place      Appointments
//    Someone to talk to  a private video call                 Talk to an expert
//
//  Adding a named doctor, nutritionist or clinic still waits on the
//  care-partner question (STILL-OPEN §2.1), and the page says so once.
//  Nothing is invented: every row opens a screen that exists.
// =============================================================================
class TtcCareCircleScreen extends StatelessWidget {
  const TtcCareCircleScreen({super.key});

  void _openPartner(BuildContext context) =>
      Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) =>
            const PvPartnerScreen(stage: LifeStage.tryingToConceive),
        settings: const RouteSettings(name: 'you/partner'),
      ));

  void _openExperts(BuildContext context) =>
      Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => const TtcPrepareScreen(onlyCategory: 'consults'),
        settings: const RouteSettings(name: 'ttc/consults'),
      ));

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: Listenable.merge([
          TtcStore.instance,
          TtcLang.instance,
          V2PaletteStore.instance,
        ]),
        builder: (context, _) {
          final t = TtcS.current();
          final pal = V2PaletteStore.instance.current;
          final joined = TtcStore.instance.partnerJoined;

          return TtcToolScaffold(
            hue: kTtcCareCircleHue,
            eyebrow: t.careCircle,
            title: 'Who is with you in this',
            intro: 'The people helping you, and how to reach each one. '
                'Every suggestion in this app says where it came from.',
            children: [
              ttcToolPad(Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TtcCircleMember(
                    pal: pal,
                    icon: Icons.spa_outlined,
                    name: 'ParentVeda',
                    detail: 'The reads, tools and reminders in this app. '
                        'Each suggestion says where it came from.',
                  ),
                  TtcCircleMember(
                    pal: pal,
                    icon: Icons.people_outline_rounded,
                    name: t.careCirclePartner,
                    detail: joined
                        ? '${t.careCircleJoined}. You share the journal.'
                        : 'Not joined yet.',
                    present: joined,
                    action: joined
                        ? 'See what your partner can see'
                        : 'Invite your partner',
                    onTap: () => _openPartner(context),
                  ),
                  TtcCircleMember(
                    pal: pal,
                    icon: Icons.medical_services_outlined,
                    name: 'Your doctor',
                    detail: 'Keep your visits and the questions you want to '
                        'ask in one place.',
                    action: 'Open Appointments',
                    onTap: () => openTtcSurface(context, 'ttc_appointments'),
                  ),
                  TtcCircleMember(
                    pal: pal,
                    icon: Icons.support_agent_outlined,
                    name: 'Someone to talk to',
                    detail: 'A private video call with a psychologist or a '
                        'fertility specialist.',
                    action: 'Talk to an expert',
                    onTap: () => _openExperts(context),
                    last: true,
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: pal.surfaceAlt,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 1),
                            child: Icon(Icons.schedule_rounded,
                                size: 16, color: pal.ink3),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                                "Soon you'll be able to add your doctor, "
                                'nutritionist or clinic here by name.',
                                style: pvManrope(
                                    fontSize: 13,
                                    height: 1.5,
                                    color: pal.ink2)),
                          ),
                        ]),
                  ),
                  const SizedBox(height: 10),
                ],
              )),
            ],
          );
        },
      );
}

/// One person in the circle: what they are for, and one way to reach them.
/// Public so a test can find it.
class TtcCircleMember extends StatelessWidget {
  const TtcCircleMember({
    super.key,
    required this.pal,
    required this.icon,
    required this.name,
    required this.detail,
    this.present = true,
    this.action,
    this.onTap,
    this.last = false,
  });

  final V2Palette pal;
  final IconData icon;
  final String name;
  final String detail;

  /// False draws the mark as an empty ring (her partner, before he joins).
  final bool present;

  /// What a tap does, said on the row. Null: nothing to tap.
  final String? action;
  final VoidCallback? onTap;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final tint = v2BlockTint(kTtcCareCircleHue, pal);
    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: present ? tint : pal.surface,
            shape: BoxShape.circle,
            border: present ? null : Border.all(color: pal.line, width: 1.5),
          ),
          child: Icon(icon, size: 19, color: present ? pal.ink1 : pal.ink3),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name,
                style: pvJakarta(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: pal.ink1)),
            const SizedBox(height: 3),
            Text(detail,
                style: pvManrope(fontSize: 13, height: 1.45, color: pal.ink2)),
            if (action case final a?) ...[
              const SizedBox(height: 8),
              Row(children: [
                Flexible(
                  child: Text(a,
                      style: pvManrope(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: pal.ink1)),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward_rounded, size: 15, color: pal.ink1),
              ]),
            ],
          ]),
        ),
      ]),
    );
    return Column(children: [
      if (onTap == null)
        row
      else
        Semantics(
          button: true,
          child: InkWell(onTap: onTap, child: row),
        ),
      if (!last) Divider(height: 1, thickness: 1, color: pal.line),
    ]);
  }
}

/// The care circle before the 2026-09-27 rebuild. Kept for revert; nothing
/// pushes it.
class TtcCareCircleScreenClassic extends StatelessWidget {
  const TtcCareCircleScreenClassic({super.key});

  /// The roles a circle can eventually hold, from §2.15.
  static const List<(String, String, String)> roles = [
    ('parentveda', 'ParentVeda', 'Everything you see here, and why'),
    ('partner', 'Your partner', 'In this with you'),
    ('doctor', 'Your doctor', 'Visits, notes and prescriptions'),
    ('nutritionist', 'Nutritionist', 'Food plans that fit your kitchen'),
    ('psychologist', 'Psychologist', 'For the days that just feel hard'),
    ('clinic', 'Clinic or hospital', 'Where your tests and scans happen'),
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([TtcStore.instance, TtcLang.instance]),
      builder: (context, _) {
        final t = TtcS.current();
        final hi = t.hinglish;
        final partnerJoined = TtcStore.instance.partnerJoined;

        return Scaffold(
          backgroundColor: ttcBg,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                  ttcGutter, 8, ttcGutter, ttcBottomInset),
              children: [
                TtcBackBar(title: t.careCircle),
                const SizedBox(height: 16),
                Text(t.careCircleIntro, style: ttcBody(14, h: 1.6)),
                const SizedBox(height: 20),

                // ParentVeda is always in the circle, and is named as a source
                // rather than treated as neutral background.
                _Member(
                  icon: Icons.spa_rounded,
                  name: 'ParentVeda',
                  detail: hi
                      ? 'Har salaah ke saath ye likha hota hai ki wo kahan se aayi'
                      : 'Every suggestion here says where it came from',
                  present: true,
                  t: t,
                ),
                const SizedBox(height: 10),
                // ⚠️ THE PARTNER CARD IS THE INVITE WHEN HE HASN'T JOINED
                // (tools pass, 2026-09-27). "Not joined yet" was a status with
                // no way to act on it. It opens the same partner page the You
                // tab opens (what he can see, the code, the share sheet).
                _Member(
                  icon: Icons.people_outline_rounded,
                  name: t.careCirclePartner,
                  detail: partnerJoined
                      ? t.careCircleJoined
                      : 'Not joined yet. Tap to invite your partner.',
                  present: partnerJoined,
                  t: t,
                  onTap: partnerJoined
                      ? null
                      : () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const PvPartnerScreen(
                                  stage: LifeStage.tryingToConceive),
                              settings:
                                  const RouteSettings(name: 'you/partner'),
                            ),
                          ),
                ),
                const SizedBox(height: 20),

                // ⚠️ ONE HONEST LINE, NOT FOUR DEAD PLUS BUTTONS (tools pass,
                // 2026-09-27). Doctor, nutritionist, psychologist and clinic
                // each had a plus that only said "coming soon". Adding them
                // waits on the care-partner question (STILL-OPEN §2.1), so the
                // screen says so once.
                TtcCard(
                  color: ttcPanel,
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Icon(Icons.schedule_rounded,
                              size: 16, color: ttcMuted),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                              "Soon you'll be able to add your doctor, "
                              'nutritionist or clinic here.',
                              style: ttcBody(13.5, h: 1.55)),
                        ),
                      ]),
                ),
                // Kept for revert (2026-09-27): the "Add someone" section, its
                // panel (which said "as you add a doctor", something she
                // cannot do yet) and the four rows below.
                //   ttcSectionTitle(t.careCircleAdd),
                //   TtcCard(color: ttcPanel, child: Text(t.careCircleEmpty)),
                if (kTtcCareCircleShowAddRows)
                for (final (id, en, detail) in roles.skip(2)) ...[
                  TtcCard(
                    onTap: () => ttcSoon(context, en),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Row(children: [
                      Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                            color: ttcBg, shape: BoxShape.circle),
                        child: Icon(_iconFor(id), size: 17, color: ttcMuted),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(en, style: ttcJakarta(14.5, color: ttcSoft)),
                              const SizedBox(height: 2),
                              Text(detail, style: ttcBody(12)),
                            ]),
                      ),
                      const Icon(Icons.add_rounded, size: 18, color: ttcMuted),
                    ]),
                  ),
                  const SizedBox(height: 10),
                ],

                // Kept for revert (2026-09-27): a footnote that repeated the
                // ParentVeda card's own line ("every suggestion says where it
                // came from"), now said once, at the top.
                //   Row(children: [Icon(Icons.verified_outlined),
                //     Text(t.careCircleWhy)]),
              ],
            ),
          ),
        );
      },
    );
  }

  static IconData _iconFor(String id) {
    switch (id) {
      case 'doctor':
        return Icons.medical_services_outlined;
      case 'nutritionist':
        return Icons.restaurant_outlined;
      case 'psychologist':
        return Icons.psychology_outlined;
      case 'clinic':
        return Icons.local_hospital_outlined;
      default:
        return Icons.person_outline_rounded;
    }
  }
}

class _Member extends StatelessWidget {
  const _Member({
    required this.icon,
    required this.name,
    required this.detail,
    required this.present,
    required this.t,
    this.onTap,
  });

  final IconData icon;
  final String name;
  final String detail;
  final bool present;
  final TtcS t;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return TtcCard(
      onTap: onTap,
      child: Row(children: [
        Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: present ? ttcPanel : ttcBg,
              shape: BoxShape.circle,
              border: present ? null : Border.all(color: ttcLine)),
          child: Icon(icon, size: 19, color: present ? ttcPurple : ttcMuted),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: ttcJakarta(15.5)),
            const SizedBox(height: 3),
            Text(detail,
                style: ttcBody(12.5,
                    color: onTap != null ? ttcPurple : ttcSoft,
                    w: onTap != null ? FontWeight.w700 : FontWeight.w400)),
          ]),
        ),
        if (onTap != null)
          const Icon(Icons.chevron_right_rounded, size: 20, color: ttcMuted),
      ]),
    );
  }
}
