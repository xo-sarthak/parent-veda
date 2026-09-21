// =============================================================================
//  Payout account — where the money goes
// -----------------------------------------------------------------------------
//  Airbnb's "Account info is needed — Required to get paid" leads here. One
//  form: account holder, account number, IFSC, optional PAN and UPI. Save
//  submits to expert_payout_accounts (0084) with status 'pending' — the
//  server's with-check makes any client write 'pending', so a doctor editing
//  a verified account puts it back in the queue rather than silently
//  changing where money is sent. Verification is an admin act in Directus,
//  never here (STILL-OPEN §12.3's principle).
//
//  The save is LOUD: upsertRowConfirmed(), not the best-effort upsert. A
//  bank account that looks saved and was not is a payout to nowhere months
//  from now, discovered by the person least able to debug it.
// =============================================================================

import 'package:flutter/material.dart';

import '../../doctor/doctor_ledger.dart';
import 'doctor_chrome.dart';

class DoctorPayoutAccountScreen extends StatefulWidget {
  const DoctorPayoutAccountScreen({super.key});

  @override
  State<DoctorPayoutAccountScreen> createState() => _DoctorPayoutAccountScreenState();
}

class _DoctorPayoutAccountScreenState extends State<DoctorPayoutAccountScreen> {
  late final TextEditingController _name;
  late final TextEditingController _number;
  late final TextEditingController _confirm;
  late final TextEditingController _ifsc;
  late final TextEditingController _pan;
  late final TextEditingController _upi;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final a = DoctorLedger.instance.account;
    _name = TextEditingController(text: a?.accountName ?? '');
    _number = TextEditingController(text: a?.accountNumber ?? '');
    _confirm = TextEditingController(text: a?.accountNumber ?? '');
    _ifsc = TextEditingController(text: a?.ifsc ?? '');
    _pan = TextEditingController(text: a?.pan ?? '');
    _upi = TextEditingController(text: a?.upiId ?? '');
    for (final c in [_name, _number, _confirm, _ifsc, _pan, _upi]) {
      c.addListener(_clearError);
    }
  }

  void _clearError() {
    if (_error != null && mounted) setState(() => _error = null);
  }

  @override
  void dispose() {
    for (final c in [_name, _number, _confirm, _ifsc, _pan, _upi]) {
      c.removeListener(_clearError);
      c.dispose();
    }
    super.dispose();
  }

  String? _validate() {
    if (_name.text.trim().length < 3) return 'Enter the name on the account.';
    final n = _number.text.trim();
    if (n.length < 9 || n.length > 18 || int.tryParse(n) == null) {
      return 'Account numbers are 9 to 18 digits.';
    }
    if (_confirm.text.trim() != n) return 'The two account numbers do not match.';
    final i = _ifsc.text.trim().toUpperCase();
    if (!RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(i)) {
      return 'An IFSC is 11 characters, like HDFC0001234.';
    }
    final pan = _pan.text.trim().toUpperCase();
    if (pan.isNotEmpty && !RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$').hasMatch(pan)) {
      return 'A PAN looks like ABCDE1234F.';
    }
    return null;
  }

  Future<void> _save() async {
    final err = _validate();
    if (err != null) {
      setState(() => _error = err);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final ok = await DoctorLedger.instance.savePayoutAccount(PayoutAccount(
      accountName: _name.text,
      accountNumber: _number.text,
      ifsc: _ifsc.text,
      pan: _pan.text,
      upiId: _upi.text,
    ));
    if (!mounted) return;
    setState(() => _busy = false);
    if (!ok) {
      setState(() => _error = 'Could not save. Check your connection and try again.');
      return;
    }
    dcToast(context, 'Saved. We verify it before the first transfer.');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final a = DoctorLedger.instance.account;
    return DcScreen(
      title: 'Payout account',
      subtitle: a == null
          ? 'Where your earnings are sent'
          : (a.verified ? 'Verified' : a.status == 'rejected' ? 'Needs attention' : 'Being verified'),
      bottom: ObPrimary(
        p: dcP,
        label: _busy ? 'Saving…' : (a == null ? 'Save account' : 'Update account'),
        onTap: _busy ? null : _save,
      ),
      children: [
        if (a != null && a.status == 'rejected' && a.reason != null) ...[
          DcNotice(a.reason!, problem: true),
          const SizedBox(height: 16),
        ],
        if (a != null && a.verified) ...[
          const DcNotice('Changing these details puts the account back into verification. '
              'Payouts pause until it is verified again.'),
          const SizedBox(height: 16),
        ],
        DcInput(label: 'Name on the account', controller: _name, hint: 'As printed on the passbook'),
        const SizedBox(height: 14),
        DcInput(label: 'Account number', controller: _number, keyboard: TextInputType.number),
        const SizedBox(height: 14),
        DcInput(label: 'Account number, again', controller: _confirm, keyboard: TextInputType.number),
        const SizedBox(height: 14),
        DcInput(label: 'IFSC', controller: _ifsc, hint: 'HDFC0001234', capitals: true),
        const SizedBox(height: 14),
        DcInput(label: 'PAN (optional, for the annual statement)', controller: _pan, hint: 'ABCDE1234F', capitals: true),
        const SizedBox(height: 14),
        DcInput(label: 'UPI id (optional)', controller: _upi, hint: 'name@bank', keyboard: TextInputType.emailAddress),
        if (_error != null) ...[
          const SizedBox(height: 14),
          DcNotice(_error!, problem: true),
        ],
        const SizedBox(height: 16),
        Text(
          'Only ParentVeda\'s finance team can see these details. They are never shown to parents.',
          style: dcMeta(12.5, color: dcP.ink3),
        ),
      ],
    );
  }
}
