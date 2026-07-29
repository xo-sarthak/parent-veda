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
// =============================================================================

import 'package:flutter/material.dart';

import '../../booking/booking_store.dart';
import '../../localization/app_language.dart';
import '../../services/entitlement_store.dart';
import '../../services/sponsor_admin_store.dart';
import '../../services/sponsor_benefits.dart';
import '../../theme/app_theme.dart';
import 'enterprise_common.dart';
import 'sponsor_dashboard_screen.dart';

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
  }

  String _p(String en, String hi) => ep(widget.lang, en, hi);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceContainer,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceContainer,
        elevation: 0,
        title: Text(_p('Employer benefits', 'Employer benefits')),
      ),
      body: SafeArea(
        top: false,
        child: AnimatedBuilder(
          animation: Listenable.merge([
            EntitlementStore.instance,
            BookingStore.instance,
            SponsorAdminStore.instance,
          ]),
          builder: (context, _) => _body(context),
        ),
      ),
    );
  }

  Widget _body(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final ent = EntitlementStore.instance;
    final sponsor = ent.sponsor;

    if (sponsor == null) {
      // Reachable if the benefit was revoked while this screen was open — a
      // leaver, or a contract that ended. Say so plainly instead of showing an
      // empty page that looks broken.
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          EnterpriseHeading(
            _p('No employer benefit is active.',
                'Koi employer benefit active nahi hai.'),
            sub: _p(
                'If your company sponsors ParentVeda, activate it with your '
                    'work email.',
                'Agar aapki company ParentVeda sponsor karti hai, work email se '
                    'activate kar lijiye.'),
          ),
        ],
      );
    }

    final credit = BookingStore.instance
        .entitlements()
        .where((e) => e.id == 'ent_gift_sponsor_${sponsor.id}')
        .toList();
    final creditsLeft =
        credit.isEmpty ? 0 : credit.first.creditsLeft;
    final creditExpires = credit.isEmpty ? null : credit.first.expiresUtc;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        // ---- who is paying -------------------------------------------------
        EnterpriseCard(
          child: Row(children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppTheme.primary100,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.workspace_premium_outlined,
                  color: AppTheme.primary600),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ParentVeda Premium',
                      style:
                          t.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 3),
                  Text(
                    _p('Provided by ${sponsor.name}',
                        '${sponsor.name} ki taraf se'),
                    style: t.bodySmall?.copyWith(color: AppTheme.neutral600),
                  ),
                ],
              ),
            ),
          ]),
        ),
        const SizedBox(height: 14),

        // ---- consultations -------------------------------------------------
        // Rendered whether or not any are left. A section that disappears when
        // it hits zero leaves a parent wondering whether she imagined it.
        if (ent.can(Caps.consultationCredit)) ...[
          EnterpriseCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.event_available_outlined,
                      size: 19, color: AppTheme.primary600),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(_p('Consultations', 'Consultations'),
                        style: t.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w800)),
                  ),
                  Text(
                    '$creditsLeft / ${SponsorBenefits.consultationsPerActivation}',
                    style: t.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: creditsLeft > 0
                            ? AppTheme.primary600
                            : AppTheme.neutral400),
                  ),
                ]),
                const SizedBox(height: 9),
                Text(
                  creditsLeft > 0
                      ? _p(
                          'Book with any ParentVeda doctor or counsellor. Your '
                              'employer is not told who you saw or why.',
                          'Kisi bhi ParentVeda doctor ya counsellor se book '
                              'karo. Employer ko yeh nahi pata chalta ki kisse '
                              'mile ya kyun.')
                      : _p(
                          'You have used this year\'s consultation. It renews '
                              'when your company renews.',
                          'Is saal ki consultation use ho chuki hai. Company '
                              'renew karegi to yeh bhi renew ho jayegi.'),
                  style: t.bodySmall
                      ?.copyWith(color: AppTheme.neutral600, height: 1.45),
                ),
                if (creditExpires != null && creditsLeft > 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    _p('Valid until ${_date(creditExpires)}',
                        '${_date(creditExpires)} tak valid'),
                    style: t.labelSmall?.copyWith(color: AppTheme.neutral400),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],

        // ---- what else the plan carries ------------------------------------
        _capabilityRow(
          on: ent.can(Caps.masterclassAccess),
          icon: Icons.school_outlined,
          title: _p('Masterclasses', 'Masterclasses'),
          body: _p('Paid sessions, included in your plan.',
              'Paid sessions, aapke plan mein included.'),
        ),
        _capabilityRow(
          on: ent.can(Caps.sponsorEvents),
          icon: Icons.groups_outlined,
          title: _p('Company sessions', 'Company sessions'),
          body: _p(
              'Sessions your organisation runs for its parents. Nothing is '
                  'scheduled yet — you will see them here.',
              'Aapka organisation apne parents ke liye jo sessions rakhta hai. '
                  'Abhi kuch schedule nahi hai — yahin dikhenge.'),
        ),
        _capabilityRow(
          on: ent.can(Caps.sponsorResources),
          icon: Icons.folder_open_outlined,
          title: _p('Company resources', 'Company resources'),
          body: _p(
              'Your organisation\'s own parenting policy and guides. Never '
                  'medical advice — that always comes from us or your doctor.',
              'Aapke organisation ki apni parenting policy aur guides. Medical '
                  'advice kabhi nahi — woh hamesha hamse ya aapke doctor se.'),
        ),

        const SizedBox(height: 14),

        // ---- HR's own door -------------------------------------------------
        // The capability architecture doing its job: the same app, the same
        // screen, one extra row for the two people at the company who hold it.
        if (SponsorAdminStore.instance.isAdmin) ...[
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                settings: const RouteSettings(name: 'enterprise/programme'),
                builder: (_) => SponsorDashboardScreen(lang: widget.lang),
              ),
            ),
            behavior: HitTestBehavior.opaque,
            child: EnterpriseCard(
              child: Row(children: [
                const Icon(Icons.insights_outlined,
                    size: 20, color: AppTheme.primary600),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_p('Programme', 'Programme'),
                          style: t.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 3),
                      Text(
                        _p('Take-up across ${sponsor.name}.',
                            '${sponsor.name} mein kitna use ho raha hai.'),
                        style:
                            t.bodySmall?.copyWith(color: AppTheme.neutral600),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: AppTheme.neutral400),
              ]),
            ),
          ),
          const SizedBox(height: 14),
        ],

        // ---- support -------------------------------------------------------
        if ((sponsor.supportContact ?? '').isNotEmpty) ...[
          EnterpriseCard(
            color: AppTheme.surfaceContainerLow,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_p('Questions about the benefit',
                    'Benefit ke baare mein sawaal'),
                    style:
                        t.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(
                  _p(
                      'Anything about seats, renewal or eligibility goes to '
                          '${sponsor.supportContact}. Anything about your '
                          'pregnancy or your baby stays with us.',
                      'Seats, renewal ya eligibility ke liye '
                          '${sponsor.supportContact}. Pregnancy ya baby ki baat '
                          'hamare paas hi rehti hai.'),
                  style: t.bodySmall
                      ?.copyWith(color: AppTheme.neutral600, height: 1.45),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],

        // ---- the promise, again --------------------------------------------
        // Repeated rather than said once at activation, because the question
        // "wait, can my employer see this?" arrives later, on a bad day, and
        // it must have an answer where she is already looking.
        EnterpriseCard(
          color: AppTheme.surfaceContainerLow,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Icon(Icons.lock_outline_rounded,
                    size: 18, color: AppTheme.primary600),
                const SizedBox(width: 8),
                Text(_p('What ${sponsor.name} sees',
                    '${sponsor.name} kya dekhta hai'),
                    style:
                        t.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
              ]),
              const SizedBox(height: 10),
              Text(
                _p(
                    'How many people activated, and how many consultations were '
                        'used across everyone. That is the whole list. They '
                        'cannot see your pregnancy, your child, your journal, '
                        'your questions, your searches or your appointments.',
                    'Kitne logon ne activate kiya, aur sab milakar kitni '
                        'consultations use hui. Bas itna. Aapki pregnancy, baby, '
                        'journal, sawaal, search ya appointments — kuch nahi.'),
                style: t.bodySmall
                    ?.copyWith(color: AppTheme.neutral600, height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _capabilityRow({
    required bool on,
    required IconData icon,
    required String title,
    required String body,
  }) {
    if (!on) return const SizedBox.shrink();
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: EnterpriseCard(
        padding: const EdgeInsets.all(15),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 19, color: AppTheme.primary600),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: t.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(body,
                    style: t.bodySmall
                        ?.copyWith(color: AppTheme.neutral600, height: 1.45)),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  static String _date(DateTime d) {
    const m = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final l = d.toLocal();
    return '${l.day} ${m[l.month - 1]} ${l.year}';
  }
}
