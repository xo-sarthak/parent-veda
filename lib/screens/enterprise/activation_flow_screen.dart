// =============================================================================
//  Activating an employer benefit — work email, code, welcome.
// -----------------------------------------------------------------------------
//  Three steps in one screen with a `_step` state machine, matching
//  auth_flow_screen.dart's shape rather than inventing a second convention for
//  the same problem. Navigator + MaterialPageRoute, RouteSettings named, per
//  CLAUDE.md.
//
//  WHY THERE IS A CODE AT ALL, since it is the step people ask to remove:
//  the address is the ONLY evidence of employment we have. Without proving
//  control of it, "my employer is Acme" is a claim anybody can type, and the
//  domain list becomes free Premium for the internet. So the code is the
//  feature, not friction in front of it.
//
//  EVERY REFUSAL BRANCHES ON `code`, NEVER ON THE WORDING. The server owns the
//  rules and returns a machine-readable reason; this screen owns how that reads
//  in two languages. Pattern-matching the English would break silently the day
//  someone improves a sentence — and only for the people being refused, who are
//  the least likely to be watching.
//
//  ⚠️ NOTHING SENDS THE EMAIL YET (STILL-OPEN §11.6). The code is written and
//  delivered by nobody. Until a provider is wired, the demo sponsor seeded by
//  supabase/seed/sponsor_demo.sql carries a bypass string — see 0059 for why
//  that is done per-sponsor and audited separately rather than by handing the
//  real code back to the caller.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../localization/app_language.dart';
import '../../services/entitlement_store.dart';
import '../../services/sponsor_benefits.dart';
import '../../theme/app_theme.dart';
import 'enterprise_common.dart';

/// Returns true when the benefit was activated.
Future<bool> openActivationFlow(BuildContext context,
    {AppLanguage lang = AppLanguage.english, String? prefillEmail}) async {
  final ok = await Navigator.of(context).push<bool>(
    MaterialPageRoute<bool>(
      settings: const RouteSettings(name: 'enterprise/activate'),
      builder: (_) =>
          ActivationFlowScreen(lang: lang, prefillEmail: prefillEmail),
    ),
  );
  return ok ?? false;
}

class ActivationFlowScreen extends StatefulWidget {
  const ActivationFlowScreen(
      {super.key, this.lang = AppLanguage.english, this.prefillEmail});

  final AppLanguage lang;
  final String? prefillEmail;

  @override
  State<ActivationFlowScreen> createState() => _ActivationFlowScreenState();
}

enum _Step { email, code, welcome }

class _ActivationFlowScreenState extends State<ActivationFlowScreen> {
  late final TextEditingController _email =
      TextEditingController(text: widget.prefillEmail ?? '');
  final _code = TextEditingController();

  _Step _step = _Step.email;
  bool _busy = false;
  String? _notice;
  String _lastCode = '';

  AppLanguage get _l => widget.lang;
  String _p(String en, String hi) => ep(_l, en, hi);

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    super.dispose();
  }

  Future<void> _requestCode() async {
    final email = _email.text.trim();
    if (email.isEmpty) return;
    setState(() {
      _busy = true;
      _notice = null;
    });

    final res = await EntitlementStore.instance.requestActivation(email);
    if (!mounted) return;

    final code = (res['code'] ?? '').toString();
    setState(() {
      _busy = false;
      _lastCode = code;
      if (res['ok'] == true) {
        _step = _Step.code;
        _notice = null;
      } else {
        _notice = activationMessage(_l, res);
      }
    });
  }

  Future<void> _confirm() async {
    final code = _code.text.trim();
    if (code.isEmpty) return;
    setState(() {
      _busy = true;
      _notice = null;
    });

    final res = await EntitlementStore.instance
        .confirmActivation(_email.text.trim(), code);
    if (!mounted) return;

    final code0 = (res['code'] ?? '').toString();
    if (res['ok'] == true) {
      // The store already refreshed itself on success; this turns the
      // capability into the credit it promises.
      SponsorBenefits.sync();
      setState(() {
        _busy = false;
        _lastCode = code0;
        _step = _Step.welcome;
      });
      return;
    }

    setState(() {
      _busy = false;
      _lastCode = code0;
      _notice = activationMessage(_l, res);
      // A dead code is worse than a wrong one: retyping it can never work, so
      // clear the field rather than leave something that looks retryable.
      if (needsFreshCode(code0)) _code.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceContainer,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceContainer,
        elevation: 0,
        leading: _step == _Step.welcome
            // No going back out of a success into a form that would refuse
            // you — the benefit is already granted.
            ? null
            : const BackButton(),
        automaticallyImplyLeading: _step != _Step.welcome,
        title: Text(_p('Employer benefits', 'Employer benefits')),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            switch (_step) {
              _Step.email => _emailStep(),
              _Step.code => _codeStep(),
              _Step.welcome => _welcomeStep(),
            },
          ],
        ),
      ),
    );
  }

  // ---- step 1 --------------------------------------------------------------

  Widget _emailStep() {
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EnterpriseHeading(
          _p('Your employer may already provide this.',
              'Ho sakta hai aapki company yeh already de rahi ho.'),
          sub: _p(
              'Some companies pay for ParentVeda for their team. Enter your '
                  'work email and we will check.',
              'Kuch companies apni team ke liye ParentVeda ka kharcha uthati '
                  'hain. Apna work email daaliye, hum check kar lete hain.'),
        ),
        const SizedBox(height: 22),
        EnterpriseCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_p('Work email', 'Work email'),
                  style: t.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                enableSuggestions: false,
                textInputAction: TextInputAction.go,
                onSubmitted: (_) => _requestCode(),
                decoration: InputDecoration(
                  hintText: 'you@company.com',
                  filled: true,
                  fillColor: AppTheme.surfaceContainerLow,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                    borderSide: BorderSide(color: AppTheme.outlineVariant),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                    borderSide: BorderSide(color: AppTheme.outlineVariant),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _p('We use it once, to check whether your company sponsors '
                    'ParentVeda. It is never shown to them.',
                    'Sirf ek baar use hoti hai — yeh check karne ke liye ki '
                        'aapki company ParentVeda sponsor karti hai. Unhe kabhi '
                        'dikhayi nahi jaati.'),
                style: t.bodySmall
                    ?.copyWith(color: AppTheme.neutral600, height: 1.45),
              ),
            ],
          ),
        ),
        if (_notice != null) ...[
          const SizedBox(height: 14),
          EnterpriseNotice(_notice!),
        ],
        const SizedBox(height: 18),
        EnterpriseButton(
          label: _p('Continue', 'Aage badho'),
          busy: _busy,
          onTap: _requestCode,
        ),
        const SizedBox(height: 24),
        _privacyPromise(compact: true),
      ],
    );
  }

  // ---- step 2 --------------------------------------------------------------

  Widget _codeStep() {
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EnterpriseHeading(
          _p('Check your work inbox.', 'Apna work inbox check karo.'),
          sub: _p(
              'We sent a six-digit code to ${_email.text.trim()}. It is good '
                  'for ten minutes.',
              'Humne ${_email.text.trim()} par ek 6-digit code bheja hai. Woh '
                  'das minute tak chalega.'),
        ),
        const SizedBox(height: 22),
        EnterpriseCard(
          child: TextField(
            controller: _code,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            autocorrect: false,
            enableSuggestions: false,
            // Not `digitsOnly`: the demo sponsor's bypass string is not
            // numeric, and a formatter that silently eats what someone typed
            // is the worst kind of refusal — one with no message.
            inputFormatters: [LengthLimitingTextInputFormatter(24)],
            style: t.headlineSmall
                ?.copyWith(letterSpacing: 6, fontWeight: FontWeight.w800),
            onSubmitted: (_) => _confirm(),
            decoration: InputDecoration(
              hintText: '000000',
              hintStyle: t.headlineSmall?.copyWith(
                  letterSpacing: 6, color: AppTheme.neutral400),
              border: InputBorder.none,
            ),
          ),
        ),
        if (_notice != null) ...[
          const SizedBox(height: 14),
          EnterpriseNotice(_notice!),
        ],
        const SizedBox(height: 18),
        EnterpriseButton(
          label: _p('Activate', 'Activate karo'),
          busy: _busy,
          onTap: _confirm,
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: _busy ? null : _requestCode,
            child: Text(
              needsFreshCode(_lastCode)
                  ? _p('Send a new code', 'Naya code bhejo')
                  : _p('Did not get it? Send again',
                      'Nahi mila? Dobara bhejo'),
              style: t.bodyMedium?.copyWith(color: AppTheme.primary600),
            ),
          ),
        ),
        Center(
          child: TextButton(
            onPressed: _busy
                ? null
                : () => setState(() {
                      _step = _Step.email;
                      _notice = null;
                    }),
            child: Text(_p('Use a different email', 'Doosri email use karo'),
                style: t.bodySmall?.copyWith(color: AppTheme.neutral600)),
          ),
        ),
      ],
    );
  }

  // ---- step 3 --------------------------------------------------------------

  Widget _welcomeStep() {
    final sponsor = EntitlementStore.instance.sponsor;
    final name = sponsor?.name ??
        _p('your organisation', 'aapke organisation');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppTheme.primary100,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(Icons.check_rounded,
              color: AppTheme.primary600, size: 30),
        ),
        const SizedBox(height: 18),
        EnterpriseHeading(
          _p("You're all set.", 'Sab set hai.'),
          sub: _p('ParentVeda Premium, provided by $name.',
              'ParentVeda Premium — $name ki taraf se.'),
        ),
        const SizedBox(height: 22),
        // The privacy promise is the FIRST thing after the good news, not
        // buried in a settings page. A parent who has just told a health app
        // where she works is owed the answer to "what does my employer see"
        // before she is asked to do anything else with it.
        _privacyPromise(company: name),
        const SizedBox(height: 20),
        EnterpriseButton(
          label: _p('See what you get', 'Dekho kya mila'),
          onTap: () => Navigator.of(context).pop(true),
        ),
      ],
    );
  }

  Widget _privacyPromise({bool compact = false, String? company}) {
    final name = company ?? _p('your employer', 'aapka employer');
    final t = Theme.of(context).textTheme;
    final lines = [
      _p('Your pregnancy and your child', 'Aapki pregnancy aur aapka baby'),
      _p('Your journal and your photos', 'Aapka journal aur photos'),
      _p('Your Ask Veda questions', 'Aapke Ask Veda sawaal'),
      _p('Anything you search or read', 'Jo bhi search ya read karte ho'),
      _p('Your appointments and reports', 'Aapke appointments aur reports'),
    ];

    return EnterpriseCard(
      color: AppTheme.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.lock_outline_rounded,
                size: 18, color: AppTheme.primary600),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _p('What your employer never sees',
                    'Aapka employer kya kabhi nahi dekhta'),
                style: t.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(Icons.close_rounded,
                        size: 15, color: AppTheme.neutral400),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                      child: Text(line,
                          style: t.bodySmall?.copyWith(height: 1.45))),
                ],
              ),
            ),
          const SizedBox(height: 6),
          Text(
            compact
                ? _p('They see how many people activated. Nothing about who, '
                    'and nothing about you.',
                    'Unhe sirf yeh dikhta hai ki kitne logon ne activate kiya. '
                        'Kaun, ya aapke baare mein kuch nahi.')
                : _p(
                    'All $name can see is how many people activated the benefit '
                        'and how many consultations were used across everyone. '
                        'Never who, never what.',
                    '$name ko sirf itna dikhta hai ki kitne logon ne benefit '
                        'activate kiya aur sab milakar kitni consultations use '
                        'hui. Kaun ya kya — kabhi nahi.'),
            style: t.bodySmall
                ?.copyWith(color: AppTheme.neutral600, height: 1.45),
          ),
        ],
      ),
    );
  }
}
