// =============================================================================
//  Shared chrome and copy for the enterprise screens.
// -----------------------------------------------------------------------------
//  Bilingual from the first string, per CLAUDE.md — every line here exists in
//  English and in real conversational Hinglish, in Latin script. Note that the
//  MESSAGES FROM THE SERVER ARE NOT TRANSLATED: a refusal arrives as
//  {ok, code, message}, and this file translates the CODE. The wording on the
//  wire is a fallback for a code this build has not met yet, which is exactly
//  the case where inventing a translation would be inventing a meaning.
//
//  That is the general rule and it is worth stating once: branch on the code,
//  never on the words. A server that improves its phrasing must not break a
//  client, and a client that pattern-matches English breaks the day the message
//  changes — silently, and only for the people it refuses.
// =============================================================================

import 'package:flutter/material.dart';

import '../../localization/app_language.dart';
import '../../theme/app_theme.dart';

String ep(AppLanguage lang, String en, String hi) => lang.isHinglish ? hi : en;

/// Every refusal code these two functions can return (0058 §5, §6), turned
/// into something a person can act on.
///
/// The default branch matters more than it looks: an unknown code means the
/// server has grown a refusal this build does not know, and the honest
/// response is to show what the server said rather than a shrug.
String activationMessage(AppLanguage lang, Map<String, dynamic> res) {
  final code = (res['code'] ?? '').toString();
  final fallback = (res['message'] ?? '').toString();
  switch (code) {
    case 'invalid_email':
      return ep(lang, 'That does not look like an email address.',
          'Yeh email address jaisa nahi lag raha.');
    case 'not_eligible':
      // Deliberately vague, and it must STAY vague. The server answers the
      // same way for an unknown domain and for a customer whose contract
      // lapsed, so that this screen cannot be used to find out which
      // companies bought ParentVeda. A more helpful message here would undo
      // that in one line.
      return ep(
          lang,
          'We could not find a benefit for that email address. Check with your '
              'HR team that they use the address you typed.',
          'Is email par koi benefit nahi mila. Apni HR team se check karo ki '
              'wahi address use hota hai jo aapne likha.');
    case 'already_activated':
      return ep(
          lang,
          'This work email has already been used to activate the benefit.',
          'Is work email se benefit pehle hi activate ho chuka hai.');
    case 'no_seats_left':
      return ep(
          lang,
          'All the seats your organisation purchased are in use. Your HR team '
              'can add more.',
          'Aapke organisation ne jitni seats li thi, sab use ho chuki hain. HR '
              'team aur add kar sakti hai.');
    case 'too_many_requests':
      return ep(lang, 'Too many codes requested. Try again in an hour.',
          'Bahut saare codes maang liye. Ek ghante baad try karo.');
    case 'not_signed_in':
      return ep(lang, 'Sign in first, then activate your employer benefit.',
          'Pehle sign in karo, phir employer benefit activate karo.');
    case 'no_pending_code':
      return ep(lang, 'That code has gone. Ask for a new one.',
          'Woh code ab valid nahi hai. Naya mangao.');
    case 'code_expired':
      return ep(lang, 'That code has expired. Ask for a new one.',
          'Code expire ho gaya. Naya mangao.');
    case 'too_many_attempts':
      return ep(lang, 'Too many incorrect codes. Ask for a new one.',
          'Bahut baar galat code. Naya mangao.');
    case 'wrong_code':
      return ep(lang, 'That code is not right.', 'Yeh code sahi nahi hai.');
    case 'sponsor_inactive':
      return ep(lang, 'This benefit is no longer active.',
          'Yeh benefit ab active nahi hai.');
    case 'network_error':
      return ep(
          lang,
          'We could not reach ParentVeda. Check your connection and try again.',
          'ParentVeda tak nahi pahunch paye. Connection check karke try karo.');
    default:
      return fallback.isEmpty
          ? ep(lang, 'Something went wrong. Try again.',
              'Kuch galat ho gaya. Dobara try karo.')
          : fallback;
  }
}

/// A refusal the parent can fix by asking for a fresh code, as opposed to one
/// where retrying is pointless. Drives whether the code screen offers "send a
/// new code" prominently or quietly.
bool needsFreshCode(String code) => const {
      'no_pending_code',
      'code_expired',
      'too_many_attempts',
    }.contains(code);

// ---- chrome ----------------------------------------------------------------

/// The section heading used across these screens.
class EnterpriseHeading extends StatelessWidget {
  const EnterpriseHeading(this.text, {super.key, this.sub});

  final String text;
  final String? sub;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(text,
            style: t.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
        if (sub != null) ...[
          const SizedBox(height: 8),
          Text(sub!,
              style: t.bodyMedium?.copyWith(
                  color: AppTheme.neutral600, height: 1.5)),
        ],
      ],
    );
  }
}

/// A bordered block. Matches the profile screen's card language rather than
/// introducing a look that only enterprise uses — one app, and the benefit is
/// something the parent GAINED, not somewhere else they went.
class EnterpriseCard extends StatelessWidget {
  const EnterpriseCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.color,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color? color;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color: color ?? AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.outlineVariant),
        ),
        child: child,
      );
}

/// The primary button. One shape, so the flow reads as one flow.
class EnterpriseButton extends StatelessWidget {
  const EnterpriseButton({
    super.key,
    required this.label,
    required this.onTap,
    this.busy = false,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onTap;
  final bool busy;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final live = enabled && !busy && onTap != null;
    return GestureDetector(
      onTap: live ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: live ? AppTheme.primary600 : AppTheme.neutral400,
          borderRadius: BorderRadius.circular(15),
        ),
        child: busy
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
            : Text(label,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
      ),
    );
  }
}

/// A refusal, shown in place rather than as a snackbar that vanishes while
/// someone is still reading it.
class EnterpriseNotice extends StatelessWidget {
  const EnterpriseNotice(this.message, {super.key, this.tone = Colors.red});

  final String message;
  final Color tone;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: tone.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: tone.withValues(alpha: 0.28)),
        ),
        child: Text(message,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: tone, height: 1.45)),
      );
}
