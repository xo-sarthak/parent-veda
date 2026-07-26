// =============================================================================
//  "Have an invite code?" — the deferred deep-link fallback
// -----------------------------------------------------------------------------
//  This is what replaces Firebase Dynamic Links, which was shut down on
//  25 August 2025 and whose links now 404.
//
//  When a friend HAS the app, a verified App Link / Universal Link opens it
//  straight onto the code. When she does NOT, no free mechanism can carry the
//  referral through an app-store install - that is precisely the deferred
//  deep-linking problem the paid vendors (Branch, AppsFlyer, Adjust) exist to
//  solve. So rather than pretend, we ask.
//
//  Asking honestly beats guessing badly:
//    * a PASTE button rather than silently reading the clipboard - iOS 16+
//      would show a permission banner anyway, and reading a parent's clipboard
//      unasked to save one tap is a bad trade;
//    * the field forgives what people actually paste: a whole invite URL,
//      spaces, dashes, lower case;
//    * every refusal says WHY, because a code that fails silently reads as a
//      broken app.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../referral/referral_analytics.dart';
import '../../referral/referral_engine.dart';
import '../../referral/referral_store.dart';
import '../post_pregnancy/pp_common.dart';

/// Returns true when a code was accepted.
Future<bool> showEnterCodeSheet(BuildContext context, {String? dueMonth}) async {
  final ok = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _EnterCodeSheet(dueMonth: dueMonth),
  );
  return ok ?? false;
}

class _EnterCodeSheet extends StatefulWidget {
  const _EnterCodeSheet({this.dueMonth});
  final String? dueMonth;

  @override
  State<_EnterCodeSheet> createState() => _EnterCodeSheetState();
}

class _EnterCodeSheetState extends State<_EnterCodeSheet> {
  final _ctrl = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text ?? '';
    if (text.isEmpty) return;
    _ctrl.text = ReferralEngine.normalise(text);
    setState(() => _error = null);
  }

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    ReferralAnalytics.codeEntered();
    final problem = await ReferralStore.instance
        .redeem(_ctrl.text, dueMonth: widget.dueMonth);
    if (!mounted) return;
    if (problem != null) {
      ReferralAnalytics.codeRejected(problem);
      setState(() {
        _busy = false;
        _error = problem;
      });
      return;
    }
    ReferralAnalytics.codeAccepted();
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final reward = ReferralStore.instance.config.inviteeReward.label;
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: ppBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 38,
            height: 4,
            decoration: BoxDecoration(
                color: ppLine, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 20),
          Text('Have an invite code?', style: ppFraunces(23, h: 1.1)),
          const SizedBox(height: 7),
          Text(
            'If a friend invited you, enter her code and you both get $reward.',
            textAlign: TextAlign.center,
            style: ppBody(13, h: 1.5),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _ctrl,
            autocorrect: false,
            enableSuggestions: false,
            textCapitalization: TextCapitalization.characters,
            textAlign: TextAlign.center,
            style: ppFraunces(22, h: 1.1).copyWith(letterSpacing: 3),
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
            decoration: InputDecoration(
              hintText: 'ABCD234',
              hintStyle: ppFraunces(22, h: 1.1)
                  .copyWith(letterSpacing: 3, color: ppMuted),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: _error == null ? ppBorder : ppCoral),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: _error == null ? ppPurple : ppCoral),
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 9),
            Text(_error!,
                textAlign: TextAlign.center, style: ppBody(12, color: ppCoral)),
          ],
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
              child: GestureDetector(
                onTap: _paste,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: ppBorder),
                  ),
                  child: Text('Paste', style: ppJakarta(13, color: ppPurple)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: _busy ? null : _submit,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _busy ? ppMuted : ppPurple,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: _busy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text('Apply code',
                          style: ppJakarta(13.5, color: Colors.white)),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(false),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text('I do not have one',
                  style: ppJakarta(12.5, color: ppSoft)),
            ),
          ),
        ]),
      ),
    );
  }
}
