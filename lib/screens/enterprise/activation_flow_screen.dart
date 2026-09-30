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
//
//  ---------------------------------------------------------------------------
//  ON THE BASE UI, 2026-09-29, the same pass as Employer benefits (read its
//  header): the page was on the lilac `surfaceContainer` with a violet
//  button, a violet link, a lilac field and the privacy promise on a lilac
//  slab. It opens from that page's "Activate with your work email", so it
//  looked like leaving the app for a form. Now: a white ground and bar, each
//  step led by a drawn mark from the door family in the Benefits tint (the
//  wallet she tapped, and a ticked list when it is done), a serif heading,
//  the field on white with a hairline, the one ink pill, ink links, and the
//  privacy promise as a heading and rows on white under a hairline. Every
//  word, every refusal and every branch is unchanged.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../localization/app_language.dart';
import '../../services/entitlement_store.dart';
import '../../services/sponsor_benefits.dart';
import '../../theme/app_theme.dart';
import '../../theme/pv_fonts.dart';
import '../ttc/doors/ttc_tab_art.dart';
import '../v2/v2_palette.dart';
import 'employer_benefits_screen.dart' show kEmployerBenefitsHue;
import 'enterprise_common.dart';

/// The page's ground and bar: white, like Employer benefits.
const Color kActivationGround = Colors.white;

/// A hairline, the base UI's (0x1F on white).
const Color _kLine = Color(0x1F000000);

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

/// The signed-in account's own address, or ''.
///
/// PREFILLED BECAUSE IT IS USUALLY RIGHT. Plenty of companies issue no work
/// addresses, so HR lists their staff's personal ones — which is very often the
/// same address that person signed up to ParentVeda with. Asking them to retype
/// what we already know is friction with nothing on the other side of it.
///
/// It is a SUGGESTION, not an answer: the field stays editable, because someone
/// with a real work address will have signed up with a personal one, and for
/// them the prefill is wrong and obviously so.
///
/// ⚠️ AND IT IS NOT PROOF OF ANYTHING. The tempting next step is to skip the
/// code entirely when this address is on the roster — after all, Supabase says
/// `email_confirmed_at` is set. It is not proof: with "Confirm email" turned
/// OFF, Supabase auto-confirms at signup, so that column means "confirmation
/// happened, OR was disabled" — two opposite facts sharing one value. Trusting
/// it would let anyone who signs up as priya@acme.com take Acme's benefit,
/// which is precisely the hole the one-time code exists to close.
String _signedInEmail() {
  try {
    return Supabase.instance.client.auth.currentUser?.email ?? '';
  } catch (_) {
    // Uninitialised backend behaves exactly like being logged out.
    return '';
  }
}

class _ActivationFlowScreenState extends State<ActivationFlowScreen> {
  late final TextEditingController _email = TextEditingController(
      text: widget.prefillEmail ?? _signedInEmail());
  final _code = TextEditingController();

  _Step _step = _Step.email;
  bool _busy = false;
  String? _notice;
  String _lastCode = '';

  AppLanguage get _l => widget.lang;
  String _p(String en, String hi) => ep(_l, en, hi);

  V2Palette get _pal => V2PaletteStore.instance.current;

  /// A drawn mark from the door family, in the Benefits section's tint.
  Widget _mark(TtcTabMark m, {double size = 72}) => SizedBox(
        width: size,
        height: size,
        child: TtcTabArt(mark: m, tint: v2BlockTint(kEmployerBenefitsHue, _pal)),
      );

  /// The step's heading on white: a serif line and an ink-2 sub. Replaces
  /// `EnterpriseHeading` here (kept for the sponsor dashboard, which is not
  /// part of this pass).
  Widget _heading(String text, {String? sub}) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(text,
                style: pvFraunces(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                    color: _pal.ink1)),
          ),
          if (sub != null) ...[
            const SizedBox(height: 8),
            Text(sub,
                style: pvManrope(fontSize: 14, height: 1.5, color: _pal.ink2)),
          ],
        ],
      );

  /// A field on white with a hairline, ink when focused.
  InputDecoration _field(String hint, {TextStyle? hintStyle}) =>
      InputDecoration(
        hintText: hint,
        hintStyle: hintStyle ?? pvManrope(fontSize: 15, color: _pal.ink3),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _kLine),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _kLine),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: AppTheme.neutral900, width: 1.4),
        ),
      );

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
      // Kept for revert (2026-09-29): AppTheme.surfaceContainer on both.
      backgroundColor: kActivationGround,
      appBar: AppBar(
        backgroundColor: kActivationGround,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        foregroundColor: AppTheme.neutral900,
        iconTheme: const IconThemeData(color: AppTheme.neutral900),
        elevation: 0,
        leading: _step == _Step.welcome
            // No going back out of a success into a form that would refuse
            // you — the benefit is already granted.
            ? null
            : const BackButton(),
        automaticallyImplyLeading: _step != _Step.welcome,
        // Kept for revert (2026-09-29): the theme's title style.
        title: Text(_p('Employer benefits', 'Employer benefits'),
            style: pvManrope(
                fontSize: 16, fontWeight: FontWeight.w700, color: _pal.ink1)),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The wallet, the object on the Benefits row she tapped to get here.
        _mark(TtcTabMark.wallet),
        const SizedBox(height: 16),
        // Kept for revert (2026-09-29): EnterpriseHeading(...).
        _heading(
          _p('Your employer may already provide this.',
              'हो सकता है आपकी कंपनी यह पहले से दे रही हो।'),
          sub: _p(
              'Some companies pay for ParentVeda for their team. Enter your '
                  'work email and we will check.',
              'कुछ कंपनियाँ अपनी टीम के लिए ParentVeda का ख़र्च उठाती हैं। अपना ऑफ़िस वाला ईमेल डालिए, हम जाँच लेते हैं।'),
        ),
        const SizedBox(height: 22),
        // No card round the field (DESIGN-SYSTEM: a form is a label, a field
        // and a line on white). Kept for revert (2026-09-29): EnterpriseCard(
        // child: Column(...)).
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // NOT "work email", deliberately. Plenty of Indian companies --
              // especially the 30-to-200-person ones this is sold to first --
              // issue no company addresses at all; their staff use Gmail, and
              // HR gives us a list of those. Asking for a "work email" tells
              // that person they are not eligible when they are, and they
              // close the screen. What they need to type is whichever address
              // their company gave us, which is what this says.
              Text(_p('The email your company has for you',
                  'जो ईमेल आपकी कंपनी के पास है'),
                  // Kept for revert (2026-09-29): t.labelLarge w700.
                  style: pvManrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _pal.ink1)),
              const SizedBox(height: 8),
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                enableSuggestions: false,
                textInputAction: TextInputAction.go,
                onSubmitted: (_) => _requestCode(),
                style: pvManrope(fontSize: 15, color: _pal.ink1),
                // Kept for revert (2026-09-29): an InputDecoration filled
                // with the lilac `surfaceContainerLow`, radius 13, borders in
                // `outlineVariant`.
                decoration: _field('you@company.com'),
              ),
              const SizedBox(height: 10),
              Text(
                _p('We have filled in your ParentVeda address — change it if '
                    'your company uses a different one for you. Either way we '
                    'check it once and never show it to them.',
                    'हमने आपका ParentVeda वाला ईमेल भर दिया है — अगर कंपनी आपके लिए कोई और ईमेल इस्तेमाल करती है तो उसे बदल लीजिए। दोनों ही हाल में हम इसे एक बार जाँचते हैं, उन्हें कभी दिखाते नहीं।'),
                // Kept for revert (2026-09-29): t.bodySmall in neutral600.
                style:
                    pvManrope(fontSize: 12.5, height: 1.5, color: _pal.ink2),
              ),
            ],
        ),
        if (_notice != null) ...[
          const SizedBox(height: 14),
          EnterpriseNotice(_notice!),
        ],
        const SizedBox(height: 18),
        EnterpriseButton(
          label: _p('Continue', 'आगे बढ़िए'),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _mark(TtcTabMark.wallet),
        const SizedBox(height: 16),
        // Kept for revert (2026-09-29): EnterpriseHeading(...).
        _heading(
          _p('Check your work inbox.', 'अपना ऑफ़िस वाला इनबॉक्स देखिए।'),
          sub: _p(
              'We sent a six-digit code to ${_email.text.trim()}. It is good '
                  'for ten minutes.',
              'हमने ${_email.text.trim()} पर छह अंकों का कोड भेजा है। यह दस मिनट तक चलेगा।'),
        ),
        const SizedBox(height: 22),
        // The field alone, on white (kept for revert, 2026-09-29: inside an
        // EnterpriseCard with no border of its own).
        TextField(
            controller: _code,
            // TEXT, NOT NUMBER, and this cost a demo before it was noticed.
            //
            // A real code is six digits, so TextInputType.number is the
            // obviously right choice and it was the first one made. But on
            // Android that raises a keypad with NO LETTERS — which makes the
            // demo sponsor's bypass string physically impossible to enter.
            // The field accepted it; the keyboard would not produce it.
            //
            // The trade is a few extra taps for the numeric case against a
            // whole path being unreachable, so text wins. Worth revisiting
            // the day real codes are actually delivered and the bypass goes:
            // then numeric is free.
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.characters,
            textAlign: TextAlign.center,
            autocorrect: false,
            enableSuggestions: false,
            // Not `digitsOnly` either, for the same reason. A formatter that
            // silently eats what someone typed is the worst kind of refusal —
            // one with no message.
            inputFormatters: [LengthLimitingTextInputFormatter(24)],
            // Kept for revert (2026-09-29): t.headlineSmall, letterSpacing 6,
            // w800; the hint in neutral400 with no border.
            style: pvManrope(
                fontSize: 24,
                letterSpacing: 6,
                fontWeight: FontWeight.w800,
                color: _pal.ink1),
            onSubmitted: (_) => _confirm(),
            decoration: _field('000000',
                hintStyle: pvManrope(
                    fontSize: 24,
                    letterSpacing: 6,
                    fontWeight: FontWeight.w800,
                    color: _pal.ink3)),
        ),
        if (_notice != null) ...[
          const SizedBox(height: 14),
          EnterpriseNotice(_notice!),
        ],
        const SizedBox(height: 18),
        EnterpriseButton(
          label: _p('Activate', 'चालू कीजिए'),
          busy: _busy,
          onTap: _confirm,
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: _busy ? null : _requestCode,
            child: Text(
              needsFreshCode(_lastCode)
                  ? _p('Send a new code', 'नया कोड भेजिए')
                  : _p('Did not get it? Send again',
                      'नहीं मिला? दोबारा भेजिए'),
              // Ink, not violet (2026-09-29). Kept for revert:
              //   t.bodyMedium?.copyWith(color: AppTheme.primary600)
              style: pvManrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.neutral900),
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
            child: Text(_p('Use a different email', 'कोई दूसरा ईमेल इस्तेमाल कीजिए'),
                // Kept for revert (2026-09-29): t.bodySmall in neutral600.
                style: pvManrope(fontSize: 13, color: _pal.ink2)),
          ),
        ),
      ],
    );
  }

  // ---- step 3 --------------------------------------------------------------

  Widget _welcomeStep() {
    final sponsor = EntitlementStore.instance.sponsor;
    final name = sponsor?.name ??
        _p('your organisation', 'आपकी कंपनी');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // A ticked list: it is done. Kept for revert (2026-09-29): a 56pt
        // `primary100` square with a violet `Icons.check_rounded`.
        _mark(TtcTabMark.checklist),
        const SizedBox(height: 16),
        // Kept for revert (2026-09-29): EnterpriseHeading(...).
        _heading(
          _p("You're all set.", 'सब हो गया।'),
          sub: _p('ParentVeda Premium, provided by $name.',
              'ParentVeda Premium, $name की तरफ़ से।'),
        ),
        const SizedBox(height: 22),
        // The privacy promise is the FIRST thing after the good news, not
        // buried in a settings page. A parent who has just told a health app
        // where she works is owed the answer to "what does my employer see"
        // before she is asked to do anything else with it.
        _privacyPromise(company: name),
        const SizedBox(height: 20),
        EnterpriseButton(
          label: _p('See what you get', 'देखिए क्या-क्या मिला'),
          onTap: () => Navigator.of(context).pop(true),
        ),
      ],
    );
  }

  Widget _privacyPromise({bool compact = false, String? company}) {
    final name = company ?? _p('your employer', 'आपकी कंपनी');
    final p = _pal;
    final lines = [
      _p('Your pregnancy and your child', 'आपकी गर्भावस्था और आपका शिशु'),
      _p('Your journal and your photos', 'आपका जर्नल और आपकी तस्वीरें'),
      _p('Your Ask Veda questions', 'Ask Veda पर आपके सवाल'),
      _p('Anything you search or read', 'जो भी आप खोजती या पढ़ती हैं'),
      _p('Your appointments and reports', 'आपके अपॉइंटमेंट और रिपोर्ट'),
    ];

    // ⚠️ A HEADING AND ROWS ON WHITE UNDER A HAIRLINE, NOT A SLAB
    // (2026-09-29), as Employer benefits' privacy note is. Kept for revert:
    //   EnterpriseCard(color: AppTheme.surfaceContainerLow, child: ...) with
    //   a violet `Icons.lock_outline_rounded` beside a titleSmall w800
    //   heading, the rows in bodySmall, the closing line in neutral600.
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 18),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: _kLine)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              _p('What your employer never sees',
                  'आपकी कंपनी को क्या कभी नहीं दिखता'),
              style: pvFraunces(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  height: 1.25,
                  color: p.ink1),
            ),
          ),
          const SizedBox(height: 12),
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    // Ink 2, not neutral400 (2.6:1 on white). Kept for
                    // revert: color: AppTheme.neutral400.
                    child: Icon(Icons.close_rounded, size: 15, color: p.ink2),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                      child: Text(line,
                          style: pvManrope(
                              fontSize: 13.5, height: 1.45, color: p.ink1))),
                ],
              ),
            ),
          const SizedBox(height: 6),
          Text(
            compact
                ? _p('They see how many people activated. Nothing about who, '
                    'and nothing about you.',
                    'उन्हें दिखता है कि कितने लोगों ने चालू किया। कौन, यह नहीं — और आपके बारे में कुछ नहीं।')
                : _p(
                    'All $name can see is how many people activated the benefit '
                        'and how many consultations were used across everyone. '
                        'Never who, never what.',
                    '$name को सिर्फ़ इतना दिखता है कि कितने लोगों ने यह सुविधा चालू की और सब मिलाकर कितने कंसल्टेशन इस्तेमाल हुए। कौन, यह कभी नहीं — क्या, यह भी कभी नहीं।'),
            style: pvManrope(fontSize: 13, height: 1.5, color: p.ink2),
          ),
        ],
      ),
    );
  }
}
