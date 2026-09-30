// =============================================================================
//  Employer Benefits — what a sponsored parent actually got.
// -----------------------------------------------------------------------------
//  Reached from the always-visible row in Profile. Before activation that row
//  opens the activation flow; after it, this.
//
//  THE "A FEATURE IS NEVER HIDDEN" TENSION, RESOLVED. CLAUDE.md says an empty
//  section renders an invitation rather than disappearing; the enterprise spec
//  says the benefits section is hidden for consumer users. Both are right about
//  different things, so: the ENTRY POINT is always shown (a parent whose company
//  sponsors ParentVeda would otherwise never learn it), and the BENEFITS are
//  shown only once there are benefits. Nothing is hidden; nothing is fictional.
//
//  ONE APP. There is no enterprise navigation, no company theme, no separate
//  home. A sponsored parent's app differs from anyone else's by what she
//  gained, and by one line saying who paid for it. That restraint is the
//  product decision, not an unfinished state.
//
//  ---------------------------------------------------------------------------
//  REDRAWN ON THE BASE UI, 2026-09-29. The user, on the TTC More tab's
//  Benefits section: "the text displayed is correct, but it has that purplish
//  tint in the background of the whole screen, which was discarded way
//  before. Make it white." The page was on `AppTheme.surfaceContainer` (a
//  lilac), its bar the same, its icons in the violet `primary600`, and its two
//  closing notes on `surfaceContainerLow` slabs. Now:
//
//   · WHITE GROUND AND A WHITE BAR, like every current screen (the More tab,
//     the Store, the You screen). One hairline where a bar meets a scroll.
//   · NO SLABS BEHIND TEXT (the user, 2026-09-29, on the Cycle companion: a
//     tinted panel behind a note is noise). The support note and the privacy
//     promise are a serif heading and a paragraph on white.
//   · DRAWN MARKS, NOT MATERIAL ICONS, for the rows: the TTC door family
//     (`TtcTabArt`), in the Benefits section's own tint (hue 20 on the More
//     tab), so the page wears the same object she tapped to get here (the
//     wallet). Line icons stay only for controls (back, chevron).
//   · ROWS ARE NOT BOXED (DESIGN-SYSTEM "Lists are not boxed", 2026-09-21):
//     the capability rows are rows on the page with hairlines between them.
//   · THE EMPTY STATE IS THE APP'S EMPTY STATE (DESIGN-SYSTEM §4.12): a drawn
//     mark in its well, the sentence that was already there, and the one next
//     action as an outlined pill. Mobbin, 2026-09-29: Quicken "No transactions
//     found" (a drawn object, one line, one action)
//     https://mobbin.com/screens/51494906-2c70-48ad-935e-704c14ae1b12 ;
//     Chime "Linked accounts" (drawing, a sentence of value, one button)
//     https://mobbin.com/screens/226fa4f3-a3cb-4c62-ad78-04ad9e6628d4 ;
//     Ubank "Tracked bills" (the mark, one line, one pill)
//     https://mobbin.com/screens/0f38d793-9dc5-4c87-b22f-c4c0290797fa .
//     Not taken: their brand-coloured buttons. Ours is the outlined ink pill.
//
//  ⚠️ THE ACTION IS REAL, AND IT IS HONEST TODAY. The empty copy always said
//  "activate it with your work email" and offered no way to do it. The pill
//  opens the same `openActivationFlow` Profile has always opened. Activation
//  codes have no email sender yet (STILL-OPEN §11.6), but the server checks
//  the domain BEFORE any code exists, so with no live sponsor every address
//  gets "We could not find a benefit for that email address", which is true.
//
//  The text, the bilingual pairs and the logic are unchanged. The old build
//  is kept, commented, at the foot of this file.
// =============================================================================

import 'package:flutter/material.dart';

import '../../services/credits_store.dart';
import '../../localization/app_language.dart';
import '../../services/entitlement_store.dart';
import '../../services/sponsor_admin_store.dart';
import '../../services/sponsor_benefits.dart';
import '../../services/usage_events.dart';
import '../../theme/app_theme.dart';
import '../../theme/pv_fonts.dart';
import '../ttc/doors/ttc_tab_art.dart';
import '../v2/v2_palette.dart';
import 'activation_flow_screen.dart' show openActivationFlow;
import 'enterprise_common.dart';
import 'sponsor_dashboard_screen.dart';

/// The hue of the More tab's Benefits section (`ttc_more_tab.dart`), so the
/// marks here match the row she tapped.
const double kEmployerBenefitsHue = 20;

/// The page's ground. White, as every current screen (2026-09-29). A test
/// reads this, so the lilac cannot quietly come back.
const Color kEmployerBenefitsGround = Colors.white;

/// The empty state's one action.
const String kEmployerBenefitsActivate = 'Activate with your work email';

/// Card hairline, 0x1F on white (the base UI's White ground spec).
const Color _kLine = Color(0x1F000000);

class EmployerBenefitsScreen extends StatefulWidget {
  const EmployerBenefitsScreen({super.key, this.lang = AppLanguage.english});

  final AppLanguage lang;

  @override
  State<EmployerBenefitsScreen> createState() => _EmployerBenefitsScreenState();
}

class _EmployerBenefitsScreenState extends State<EmployerBenefitsScreen> {
  @override
  void initState() {
    super.initState();
    // Cheap, and it means a benefit that lapsed on the server stops being
    // advertised here on the next visit rather than at the next cold start.
    EntitlementStore.instance.refresh();
    SponsorAdminStore.instance.refresh();
    UsageEvents.instance.screen(UsageSurface.employerBenefits);
  }

  String _p(String en, String hi) => ep(widget.lang, en, hi);

  V2Palette get _pal => V2PaletteStore.instance.current;
  Color get _tint => v2BlockTint(kEmployerBenefitsHue, _pal);

  @override
  Widget build(BuildContext context) {
    final p = _pal;
    return Scaffold(
      // Kept for revert (2026-09-29): backgroundColor: AppTheme.surfaceContainer,
      backgroundColor: kEmployerBenefitsGround,
      appBar: AppBar(
        // Kept for revert (2026-09-29): backgroundColor: AppTheme.surfaceContainer,
        backgroundColor: kEmployerBenefitsGround,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        foregroundColor: AppTheme.neutral900,
        iconTheme: const IconThemeData(color: AppTheme.neutral900),
        title: Text(
          _p('Employer benefits', 'Employer benefits'),
          style: pvManrope(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: p.ink1,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: AnimatedBuilder(
          animation: Listenable.merge([
            EntitlementStore.instance,
            CreditsStore.instance,
            SponsorAdminStore.instance,
          ]),
          builder: (context, _) => _body(context),
        ),
      ),
    );
  }

  Widget _mark(TtcTabMark m, double size) => SizedBox(
    width: size,
    height: size,
    child: TtcTabArt(mark: m, tint: _tint),
  );

  Widget _body(BuildContext context) {
    final p = _pal;
    final ent = EntitlementStore.instance;
    final sponsor = ent.sponsor;

    if (sponsor == null) {
      // Reachable if the benefit was revoked while this screen was open — a
      // leaver, or a contract that ended. Say so plainly instead of showing an
      // empty page that looks broken.
      //
      // Also the page most people see (the More tab opens it before any
      // benefit exists), so it is the app's calm empty state: the mark, the
      // sentence, the one action. A ListView, so 1.5x text scrolls rather
      // than overflows.
      return ListView(
        key: const ValueKey('employer_benefits_empty'),
        padding: const EdgeInsets.fromLTRB(28, 48, 28, 28),
        children: [
          Center(child: _mark(TtcTabMark.wallet, 96)),
          const SizedBox(height: 22),
          Semantics(
            header: true,
            child: Text(
              _p(
                'No employer benefit is active.',
                'कंपनी की कोई सुविधा अभी चालू नहीं है।',
              ),
              textAlign: TextAlign.center,
              style: pvFraunces(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                height: 1.2,
                color: p.ink1,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _p(
              'If your company sponsors ParentVeda, activate it with your '
                  'work email.',
              'अगर आपकी कंपनी ParentVeda का ख़र्च उठाती है, तो अपने ऑफ़िस वाले ईमेल से इसे चालू कीजिए।',
            ),
            textAlign: TextAlign.center,
            style: pvManrope(fontSize: 14, height: 1.5, color: p.ink2),
          ),
          const SizedBox(height: 26),
          Center(
            child: _OutlinedPill(
              key: const ValueKey('employer_benefits_activate'),
              label: kEmployerBenefitsActivate,
              onTap: () => openActivationFlow(context, lang: widget.lang),
            ),
          ),
        ],
      );
    }

    // FROM THE SERVER, not from BookingStore. The local entitlement is a
    // rendering hint kept in step by SponsorBenefits; this screen is where
    // someone checks what they actually have, so it reads the authority
    // (0066) and shows the number that will still be true at the moment they
    // press Book.
    final credits = CreditsStore.instance;
    final creditsLeft = credits.available;
    final creditsSpent = credits.spent;
    final creditExpires = credits.expiringNext;

    final caps = <Widget>[
      if (ent.can(Caps.masterclassAccess))
        _capabilityRow(
          mark: TtcTabMark.openBook,
          title: _p('Masterclasses', 'Masterclasses'),
          body: _p(
            'Paid sessions, included in your plan.',
            'जिन सेशन के पैसे लगते हैं, वे आपके प्लान में शामिल हैं।',
          ),
        ),
      if (ent.can(Caps.sponsorEvents))
        _capabilityRow(
          mark: TtcTabMark.twoFigures,
          title: _p('Company sessions', 'Company sessions'),
          body: _p(
            'Sessions your organisation runs for its parents. Nothing is '
                'scheduled yet — you will see them here.',
            'आपकी कंपनी अपने यहाँ के माता-पिता के लिए जो सेशन रखती है। अभी कुछ तय नहीं हुआ है — जब होगा, यहीं दिखेगा।',
          ),
        ),
      if (ent.can(Caps.sponsorResources))
        _capabilityRow(
          mark: TtcTabMark.checklist,
          title: _p('Company resources', 'Company resources'),
          body: _p(
            'Your organisation\'s own parenting policy and guides. Never '
                'medical advice — that always comes from us or your doctor.',
            'आपकी कंपनी की अपनी परवरिश नीति और गाइड। डॉक्टरी सलाह कभी नहीं — वह हमेशा हमसे या आपके डॉक्टर से आती है।',
          ),
        ),
    ];

    return ListView(
      key: const ValueKey('employer_benefits_active'),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      children: [
        // ---- who is paying -------------------------------------------------
        Row(
          children: [
            _mark(TtcTabMark.wallet, 56),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ParentVeda Premium',
                    style: pvFraunces(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      height: 1.15,
                      color: p.ink1,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _p(
                      'Provided by ${sponsor.name}',
                      '${sponsor.name} की तरफ़ से',
                    ),
                    style: pvManrope(fontSize: 13, height: 1.4, color: p.ink2),
                  ),
                ],
              ),
            ),
          ],
        ),

        // ---- consultations -------------------------------------------------
        // Rendered whether or not any are left. A section that disappears when
        // it hits zero leaves a parent wondering whether she imagined it.
        //
        // A STAT PAIR (DESIGN-SYSTEM §4.10): the label small and above, the
        // number large and below, on white. The count was violet; it is ink,
        // because the number is the fact and colour is not how facts are said.
        if (ent.can(Caps.consultationCredit)) ...[
          const SizedBox(height: 22),
          const Divider(height: 1, thickness: 1, color: _kLine),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _mark(TtcTabMark.doctorChat, 40),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _p('Consultations', 'Consultations'),
                      style: pvManrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: p.ink2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$creditsLeft / ${SponsorBenefits.consultationsPerActivation}',
                      style: pvFraunces(
                        fontSize: 28,
                        fontWeight: FontWeight.w500,
                        height: 1.1,
                        color: p.ink1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      creditsLeft > 0
                          ? _p(
                              'Book with any ParentVeda doctor or counsellor. Your '
                                  'employer is not told who you saw or why.',
                              'किसी भी ParentVeda डॉक्टर या काउंसलर से मिलने का समय बुक कीजिए। आपकी कंपनी को यह नहीं बताया जाता कि आप किससे मिलीं और क्यों।',
                            )
                          : _p(
                              'You have used this year\'s consultations. They renew '
                                  'when your company renews.',
                              'इस साल के कंसल्टेशन इस्तेमाल हो चुके हैं। जब आपकी कंपनी इसे फिर से लेगी, तब ये भी फिर से मिल जाएँगे।',
                            ),
                      style: pvManrope(
                        fontSize: 13.5,
                        height: 1.5,
                        color: p.ink2,
                      ),
                    ),
                    // SAID PLAINLY, because "1 of 2" already implies it and a
                    // parent who cancelled late deserves to know where the other
                    // one went rather than assume the app lost it.
                    if (creditsSpent > 0) ...[
                      const SizedBox(height: 6),
                      Text(
                        _p(
                          '$creditsSpent used so far.',
                          'अब तक $creditsSpent कंसल्टेशन इस्तेमाल हुए।',
                        ),
                        style: pvManrope(fontSize: 12.5, color: p.ink3),
                      ),
                    ],
                    if (creditExpires != null && creditsLeft > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        _p(
                          'Valid until ${_date(creditExpires)}',
                          '${_date(creditExpires)} तक मान्य',
                        ),
                        style: pvManrope(fontSize: 12.5, color: p.ink3),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],

        // ---- what else the plan carries ------------------------------------
        for (final row in caps) ...[
          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 1, color: _kLine),
          const SizedBox(height: 16),
          row,
        ],

        // ---- HR's own door -------------------------------------------------
        // The capability architecture doing its job: the same app, the same
        // screen, one extra row for the two people at the company who hold it.
        if (SponsorAdminStore.instance.isAdmin) ...[
          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 1, color: _kLine),
          Semantics(
            button: true,
            container: true,
            excludeSemantics: true,
            label: 'Programme. Take-up across ${sponsor.name}.',
            onTap: () => _openProgramme(context),
            child: InkWell(
              onTap: () => _openProgramme(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  children: [
                    _mark(TtcTabMark.chartLine, 40),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _p('Programme', 'Programme'),
                            style: pvManrope(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: p.ink1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _p(
                              'Take-up across ${sponsor.name}.',
                              '${sponsor.name} में अब तक कितने लोगों ने इसे लिया है।',
                            ),
                            style: pvManrope(
                              fontSize: 12.5,
                              height: 1.4,
                              color: p.ink3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, size: 20, color: p.ink2),
                  ],
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        const Divider(height: 1, thickness: 1, color: _kLine),

        // ---- support -------------------------------------------------------
        if ((sponsor.supportContact ?? '').isNotEmpty) ...[
          const SizedBox(height: 24),
          _note(
            _p('Questions about the benefit', 'सुविधा के बारे में सवाल'),
            _p(
              'Anything about seats, renewal or eligibility goes to '
                  '${sponsor.supportContact}. Anything about your '
                  'pregnancy or your baby stays with us.',
              'सीट, नवीनीकरण या पात्रता से जुड़ी कोई भी बात ${sponsor.supportContact} पर पूछिए। आपकी गर्भावस्था या आपके शिशु से जुड़ी हर बात हमारे पास ही रहती है।',
            ),
          ),
        ],

        // ---- the promise, again --------------------------------------------
        // Repeated rather than said once at activation, because the question
        // "wait, can my employer see this?" arrives later, on a bad day, and
        // it must have an answer where she is already looking.
        const SizedBox(height: 24),
        _note(
          _p('What ${sponsor.name} sees', '${sponsor.name} को क्या दिखता है'),
          _p(
            'How many people activated, and how many consultations were '
                'used across everyone. That is the whole list. They '
                'cannot see your pregnancy, your child, your journal, '
                'your questions, your searches or your appointments.',
            'कितने लोगों ने चालू किया, और सब मिलाकर कितने कंसल्टेशन इस्तेमाल हुए। बस इतनी ही सूची है। आपकी गर्भावस्था, आपका शिशु, आपका जर्नल, आपके सवाल, आपकी खोज या आपके अपॉइंटमेंट — इनमें से कुछ भी उन्हें नहीं दिखता।',
          ),
        ),
      ],
    );
  }

  void _openProgramme(BuildContext context) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      settings: const RouteSettings(name: 'enterprise/programme'),
      builder: (_) => SponsorDashboardScreen(lang: widget.lang),
    ),
  );

  /// A heading and a paragraph on white. Was a card on a tinted slab.
  Widget _note(String title, String body) {
    final p = _pal;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            title,
            style: pvFraunces(
              fontSize: 19,
              fontWeight: FontWeight.w500,
              height: 1.2,
              color: p.ink1,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          body,
          style: pvManrope(fontSize: 13.5, height: 1.55, color: p.ink2),
        ),
      ],
    );
  }

  Widget _capabilityRow({
    required TtcTabMark mark,
    required String title,
    required String body,
  }) {
    final p = _pal;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _mark(mark, 40),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: pvManrope(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: p.ink1,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                body,
                style: pvManrope(fontSize: 13, height: 1.45, color: p.ink2),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _date(DateTime d) {
    const m = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final l = d.toLocal();
    return '${l.day} ${m[l.month - 1]} ${l.year}';
  }
}

/// The empty state's one next action: DESIGN-SYSTEM §4.12 says an OUTLINED
/// pill, ink label, hairline border. Never the violet `EnterpriseButton`.
class _OutlinedPill extends StatelessWidget {
  const _OutlinedPill({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    container: true,
    excludeSemantics: true,
    label: label,
    onTap: onTap,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppTheme.neutral900, width: 1.2),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: pvManrope(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppTheme.neutral900,
          ),
        ),
      ),
    ),
  );
}

// =============================================================================
//  Kept for revert (2026-09-29): the lilac build — `surfaceContainer` ground
//  and bar, violet Material icons in `primary100` wells, bordered cards for
//  every block, and the support and privacy notes on `surfaceContainerLow`
//  slabs. It was the body of `_EmployerBenefitsScreenState`, from `build` to
//  `_date`, word for word.
// =============================================================================
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppTheme.surfaceContainer,
//       appBar: AppBar(
//         backgroundColor: AppTheme.surfaceContainer,
//         elevation: 0,
//         title: Text(_p('Employer benefits', 'Employer benefits')),
//       ),
//       body: SafeArea(
//         top: false,
//         child: AnimatedBuilder(
//           animation: Listenable.merge([
//             EntitlementStore.instance,
//             CreditsStore.instance,
//             SponsorAdminStore.instance,
//           ]),
//           builder: (context, _) => _body(context),
//         ),
//       ),
//     );
//   }
//
//   Widget _body(BuildContext context) {
//     final t = Theme.of(context).textTheme;
//     final ent = EntitlementStore.instance;
//     final sponsor = ent.sponsor;
//
//     if (sponsor == null) {
//       // Reachable if the benefit was revoked while this screen was open — a
//       // leaver, or a contract that ended. Say so plainly instead of showing an
//       // empty page that looks broken.
//       return ListView(
//         padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
//         children: [
//           EnterpriseHeading(
//             _p('No employer benefit is active.',
//                 'कंपनी की कोई सुविधा अभी चालू नहीं है।'),
//             sub: _p(
//                 'If your company sponsors ParentVeda, activate it with your '
//                     'work email.',
//                 'अगर आपकी कंपनी ParentVeda का ख़र्च उठाती है, तो अपने ऑफ़िस वाले ईमेल से इसे चालू कीजिए।'),
//           ),
//         ],
//       );
//     }
//
//     // FROM THE SERVER, not from BookingStore. The local entitlement is a
//     // rendering hint kept in step by SponsorBenefits; this screen is where
//     // someone checks what they actually have, so it reads the authority
//     // (0066) and shows the number that will still be true at the moment they
//     // press Book.
//     final credits = CreditsStore.instance;
//     final creditsLeft = credits.available;
//     final creditsSpent = credits.spent;
//     final creditExpires = credits.expiringNext;
//
//     return ListView(
//       padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
//       children: [
//         // ---- who is paying -------------------------------------------------
//         EnterpriseCard(
//           child: Row(children: [
//             Container(
//               width: 46,
//               height: 46,
//               alignment: Alignment.center,
//               decoration: BoxDecoration(
//                 color: AppTheme.primary100,
//                 borderRadius: BorderRadius.circular(14),
//               ),
//               child: const Icon(Icons.workspace_premium_outlined,
//                   color: AppTheme.primary600),
//             ),
//             const SizedBox(width: 13),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text('ParentVeda Premium',
//                       style:
//                           t.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
//                   const SizedBox(height: 3),
//                   Text(
//                     _p('Provided by ${sponsor.name}',
//                         '${sponsor.name} की तरफ़ से'),
//                     style: t.bodySmall?.copyWith(color: AppTheme.neutral600),
//                   ),
//                 ],
//               ),
//             ),
//           ]),
//         ),
//         const SizedBox(height: 14),
//
//         // ---- consultations -------------------------------------------------
//         // Rendered whether or not any are left. A section that disappears when
//         // it hits zero leaves a parent wondering whether she imagined it.
//         if (ent.can(Caps.consultationCredit)) ...[
//           EnterpriseCard(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(children: [
//                   const Icon(Icons.event_available_outlined,
//                       size: 19, color: AppTheme.primary600),
//                   const SizedBox(width: 9),
//                   Expanded(
//                     child: Text(_p('Consultations', 'Consultations'),
//                         style: t.titleSmall
//                             ?.copyWith(fontWeight: FontWeight.w800)),
//                   ),
//                   Text(
//                     '$creditsLeft / ${SponsorBenefits.consultationsPerActivation}',
//                     style: t.titleSmall?.copyWith(
//                         fontWeight: FontWeight.w800,
//                         color: creditsLeft > 0
//                             ? AppTheme.primary600
//                             : AppTheme.neutral400),
//                   ),
//                 ]),
//                 const SizedBox(height: 9),
//                 Text(
//                   creditsLeft > 0
//                       ? _p(
//                           'Book with any ParentVeda doctor or counsellor. Your '
//                               'employer is not told who you saw or why.',
//                           'किसी भी ParentVeda डॉक्टर या काउंसलर से मिलने का समय बुक कीजिए। आपकी कंपनी को यह नहीं बताया जाता कि आप किससे मिलीं और क्यों।')
//                       : _p(
//                           'You have used this year\'s consultations. They renew '
//                               'when your company renews.',
//                           'इस साल के कंसल्टेशन इस्तेमाल हो चुके हैं। जब आपकी कंपनी इसे फिर से लेगी, तब ये भी फिर से मिल जाएँगे।'),
//                   style: t.bodySmall
//                       ?.copyWith(color: AppTheme.neutral600, height: 1.45),
//                 ),
//                 // SAID PLAINLY, because "1 of 2" already implies it and a
//                 // parent who cancelled late deserves to know where the other
//                 // one went rather than assume the app lost it.
//                 if (creditsSpent > 0) ...[
//                   const SizedBox(height: 6),
//                   Text(
//                     _p('$creditsSpent used so far.',
//                         'अब तक $creditsSpent कंसल्टेशन इस्तेमाल हुए।'),
//                     style: t.labelSmall?.copyWith(color: AppTheme.neutral400),
//                   ),
//                 ],
//                 if (creditExpires != null && creditsLeft > 0) ...[
//                   const SizedBox(height: 8),
//                   Text(
//                     _p('Valid until ${_date(creditExpires)}',
//                         '${_date(creditExpires)} तक मान्य'),
//                     style: t.labelSmall?.copyWith(color: AppTheme.neutral400),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//           const SizedBox(height: 14),
//         ],
//
//         // ---- what else the plan carries ------------------------------------
//         _capabilityRow(
//           on: ent.can(Caps.masterclassAccess),
//           icon: Icons.school_outlined,
//           title: _p('Masterclasses', 'Masterclasses'),
//           body: _p('Paid sessions, included in your plan.',
//               'जिन सेशन के पैसे लगते हैं, वे आपके प्लान में शामिल हैं।'),
//         ),
//         _capabilityRow(
//           on: ent.can(Caps.sponsorEvents),
//           icon: Icons.groups_outlined,
//           title: _p('Company sessions', 'Company sessions'),
//           body: _p(
//               'Sessions your organisation runs for its parents. Nothing is '
//                   'scheduled yet — you will see them here.',
//               'आपकी कंपनी अपने यहाँ के माता-पिता के लिए जो सेशन रखती है। अभी कुछ तय नहीं हुआ है — जब होगा, यहीं दिखेगा।'),
//         ),
//         _capabilityRow(
//           on: ent.can(Caps.sponsorResources),
//           icon: Icons.folder_open_outlined,
//           title: _p('Company resources', 'Company resources'),
//           body: _p(
//               'Your organisation\'s own parenting policy and guides. Never '
//                   'medical advice — that always comes from us or your doctor.',
//               'आपकी कंपनी की अपनी परवरिश नीति और गाइड। डॉक्टरी सलाह कभी नहीं — वह हमेशा हमसे या आपके डॉक्टर से आती है।'),
//         ),
//
//         const SizedBox(height: 14),
//
//         // ---- HR's own door -------------------------------------------------
//         // The capability architecture doing its job: the same app, the same
//         // screen, one extra row for the two people at the company who hold it.
//         if (SponsorAdminStore.instance.isAdmin) ...[
//           GestureDetector(
//             onTap: () => Navigator.of(context).push(
//               MaterialPageRoute<void>(
//                 settings: const RouteSettings(name: 'enterprise/programme'),
//                 builder: (_) => SponsorDashboardScreen(lang: widget.lang),
//               ),
//             ),
//             behavior: HitTestBehavior.opaque,
//             child: EnterpriseCard(
//               child: Row(children: [
//                 const Icon(Icons.insights_outlined,
//                     size: 20, color: AppTheme.primary600),
//                 const SizedBox(width: 11),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(_p('Programme', 'Programme'),
//                           style: t.titleSmall
//                               ?.copyWith(fontWeight: FontWeight.w800)),
//                       const SizedBox(height: 3),
//                       Text(
//                         _p('Take-up across ${sponsor.name}.',
//                             '${sponsor.name} में अब तक कितने लोगों ने इसे लिया है।'),
//                         style:
//                             t.bodySmall?.copyWith(color: AppTheme.neutral600),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const Icon(Icons.chevron_right_rounded,
//                     color: AppTheme.neutral400),
//               ]),
//             ),
//           ),
//           const SizedBox(height: 14),
//         ],
//
//         // ---- support -------------------------------------------------------
//         if ((sponsor.supportContact ?? '').isNotEmpty) ...[
//           EnterpriseCard(
//             color: AppTheme.surfaceContainerLow,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(_p('Questions about the benefit',
//                     'सुविधा के बारे में सवाल'),
//                     style:
//                         t.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
//                 const SizedBox(height: 6),
//                 Text(
//                   _p(
//                       'Anything about seats, renewal or eligibility goes to '
//                           '${sponsor.supportContact}. Anything about your '
//                           'pregnancy or your baby stays with us.',
//                       'सीट, नवीनीकरण या पात्रता से जुड़ी कोई भी बात ${sponsor.supportContact} पर पूछिए। आपकी गर्भावस्था या आपके शिशु से जुड़ी हर बात हमारे पास ही रहती है।'),
//                   style: t.bodySmall
//                       ?.copyWith(color: AppTheme.neutral600, height: 1.45),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 14),
//         ],
//
//         // ---- the promise, again --------------------------------------------
//         // Repeated rather than said once at activation, because the question
//         // "wait, can my employer see this?" arrives later, on a bad day, and
//         // it must have an answer where she is already looking.
//         EnterpriseCard(
//           color: AppTheme.surfaceContainerLow,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(children: [
//                 const Icon(Icons.lock_outline_rounded,
//                     size: 18, color: AppTheme.primary600),
//                 const SizedBox(width: 8),
//                 Text(_p('What ${sponsor.name} sees',
//                     '${sponsor.name} को क्या दिखता है'),
//                     style:
//                         t.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
//               ]),
//               const SizedBox(height: 10),
//               Text(
//                 _p(
//                     'How many people activated, and how many consultations were '
//                         'used across everyone. That is the whole list. They '
//                         'cannot see your pregnancy, your child, your journal, '
//                         'your questions, your searches or your appointments.',
//                     'कितने लोगों ने चालू किया, और सब मिलाकर कितने कंसल्टेशन इस्तेमाल हुए। बस इतनी ही सूची है। आपकी गर्भावस्था, आपका शिशु, आपका जर्नल, आपके सवाल, आपकी खोज या आपके अपॉइंटमेंट — इनमें से कुछ भी उन्हें नहीं दिखता।'),
//                 style: t.bodySmall
//                     ?.copyWith(color: AppTheme.neutral600, height: 1.5),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _capabilityRow({
//     required bool on,
//     required IconData icon,
//     required String title,
//     required String body,
//   }) {
//     if (!on) return const SizedBox.shrink();
//     final t = Theme.of(context).textTheme;
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 10),
//       child: EnterpriseCard(
//         padding: const EdgeInsets.all(15),
//         child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           Icon(icon, size: 19, color: AppTheme.primary600),
//           const SizedBox(width: 11),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(title,
//                     style: t.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
//                 const SizedBox(height: 4),
//                 Text(body,
//                     style: t.bodySmall
//                         ?.copyWith(color: AppTheme.neutral600, height: 1.45)),
//               ],
//             ),
//           ),
//         ]),
//       ),
//     );
//   }
