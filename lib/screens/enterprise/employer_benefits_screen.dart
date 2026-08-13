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

import '../../services/credits_store.dart';
import '../../localization/app_language.dart';
import '../../services/entitlement_store.dart';
import '../../services/sponsor_admin_store.dart';
import '../../services/sponsor_benefits.dart';
import '../../services/usage_events.dart';
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
    UsageEvents.instance.screen(UsageSurface.employerBenefits);
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
            CreditsStore.instance,
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
                'कंपनी की कोई सुविधा अभी चालू नहीं है।'),
            sub: _p(
                'If your company sponsors ParentVeda, activate it with your '
                    'work email.',
                'अगर आपकी कंपनी ParentVeda का ख़र्च उठाती है, तो अपने ऑफ़िस वाले ईमेल से इसे चालू कीजिए।'),
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
                        '${sponsor.name} की तरफ़ से'),
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
                          'किसी भी ParentVeda डॉक्टर या काउंसलर से मिलने का समय बुक कीजिए। आपकी कंपनी को यह नहीं बताया जाता कि आप किससे मिलीं और क्यों।')
                      : _p(
                          'You have used this year\'s consultations. They renew '
                              'when your company renews.',
                          'इस साल के कंसल्टेशन इस्तेमाल हो चुके हैं। जब आपकी कंपनी इसे फिर से लेगी, तब ये भी फिर से मिल जाएँगे।'),
                  style: t.bodySmall
                      ?.copyWith(color: AppTheme.neutral600, height: 1.45),
                ),
                // SAID PLAINLY, because "1 of 2" already implies it and a
                // parent who cancelled late deserves to know where the other
                // one went rather than assume the app lost it.
                if (creditsSpent > 0) ...[
                  const SizedBox(height: 6),
                  Text(
                    _p('$creditsSpent used so far.',
                        'अब तक $creditsSpent कंसल्टेशन इस्तेमाल हुए।'),
                    style: t.labelSmall?.copyWith(color: AppTheme.neutral400),
                  ),
                ],
                if (creditExpires != null && creditsLeft > 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    _p('Valid until ${_date(creditExpires)}',
                        '${_date(creditExpires)} तक मान्य'),
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
              'जिन सेशन के पैसे लगते हैं, वे आपके प्लान में शामिल हैं।'),
        ),
        _capabilityRow(
          on: ent.can(Caps.sponsorEvents),
          icon: Icons.groups_outlined,
          title: _p('Company sessions', 'Company sessions'),
          body: _p(
              'Sessions your organisation runs for its parents. Nothing is '
                  'scheduled yet — you will see them here.',
              'आपकी कंपनी अपने यहाँ के माता-पिता के लिए जो सेशन रखती है। अभी कुछ तय नहीं हुआ है — जब होगा, यहीं दिखेगा।'),
        ),
        _capabilityRow(
          on: ent.can(Caps.sponsorResources),
          icon: Icons.folder_open_outlined,
          title: _p('Company resources', 'Company resources'),
          body: _p(
              'Your organisation\'s own parenting policy and guides. Never '
                  'medical advice — that always comes from us or your doctor.',
              'आपकी कंपनी की अपनी परवरिश नीति और गाइड। डॉक्टरी सलाह कभी नहीं — वह हमेशा हमसे या आपके डॉक्टर से आती है।'),
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
                            '${sponsor.name} में अब तक कितने लोगों ने इसे लिया है।'),
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
                    'सुविधा के बारे में सवाल'),
                    style:
                        t.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(
                  _p(
                      'Anything about seats, renewal or eligibility goes to '
                          '${sponsor.supportContact}. Anything about your '
                          'pregnancy or your baby stays with us.',
                      'सीट, नवीनीकरण या पात्रता से जुड़ी कोई भी बात ${sponsor.supportContact} पर पूछिए। आपकी गर्भावस्था या आपके शिशु से जुड़ी हर बात हमारे पास ही रहती है।'),
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
                    '${sponsor.name} को क्या दिखता है'),
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
                    'कितने लोगों ने चालू किया, और सब मिलाकर कितने कंसल्टेशन इस्तेमाल हुए। बस इतनी ही सूची है। आपकी गर्भावस्था, आपका शिशु, आपका जर्नल, आपके सवाल, आपकी खोज या आपके अपॉइंटमेंट — इनमें से कुछ भी उन्हें नहीं दिखता।'),
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
