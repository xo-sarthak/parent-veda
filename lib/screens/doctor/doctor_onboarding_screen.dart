// =============================================================================
//  Doctor onboarding — profile, qualifications, registration, documents, KYC
// -----------------------------------------------------------------------------
//  The half of the Practo walkthrough the app had nothing for: everything a
//  real doctor must supply before they may see a parent. Five steps, in the
//  order the reference flow uses, because it is the order that makes sense --
//  who you are, what you trained in, your council registration, proof of all
//  three, then where you get paid.
//
//  EVERY STEP HAS "Skip for now". This is a testing build: the point today is
//  that these screens can be walked end to end and reviewed, not that anyone is
//  actually blocked. Skipping records nothing and moves on.
//
//  WHAT THIS IS NOT: verification. Nothing here approves a doctor. Uploading a
//  certificate is a submission, not a credential -- approval is an editorial
//  act performed by a human in the admin panel, and that is the one part of
//  this flow that must never live in the app the applicant controls.
// =============================================================================

import 'package:flutter/material.dart';

import '../../doctor/doctor_onboarding_store.dart';
import '../../doctor/doctor_session.dart';
import 'doctor_art.dart';
import 'doctor_chrome.dart';

class DoctorOnboardingScreen extends StatefulWidget {
  const DoctorOnboardingScreen({super.key});

  @override
  State<DoctorOnboardingScreen> createState() => _DoctorOnboardingScreenState();
}

class _DoctorOnboardingScreenState extends State<DoctorOnboardingScreen> {
  final _store = DoctorOnboardingStore.instance;
  int _step = 0;

  static const _steps = [
    ('Basic details', 'Who you are'),
    ('Qualifications', 'What you trained in'),
    ('Registration', 'Your medical council'),
    ('Documents', 'Proof of the above'),
    ('Payouts', 'Where your earnings go'),
  ];

  String get _expertId => DoctorSession.instance.expertId ?? '';

  @override
  void initState() {
    super.initState();
    _store.init();
  }

  void _next() {
    if (_step < _steps.length - 1) {
      setState(() => _step++);
    } else {
      Navigator.of(context).maybePop();
    }
  }

  void _skip() {
    _store.markSkipped(_expertId, _steps[_step].$1);
    _next();
  }

  // The form keeps what she types for the length of the visit, so stepping
  // back does not blank a field. Nothing is sent yet — see the file head.
  final Map<String, TextEditingController> _fields = {};
  final Set<String> _picked = {};
  TextEditingController _c(String label) => _fields.putIfAbsent(label, TextEditingController.new);

  @override
  void dispose() {
    for (final c in _fields.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = dcP;
    // 2026-09-21: onto the doctor chrome — violet bars, violet button,
    // tinted notes all gone; the same five steps.
    return AnimatedBuilder(
      animation: _store,
      builder: (context, _) => DcScreen(
        title: _steps[_step].$1,
        subtitle: 'Step ${_step + 1} of ${_steps.length} · ${_steps[_step].$2}',
        bottom: Column(mainAxisSize: MainAxisSize.min, children: [
          ObPrimary(p: p, label: _step == _steps.length - 1 ? 'Finish' : 'Continue', onTap: _next),
          const SizedBox(height: 4),
          TextButton(onPressed: _skip, child: Text('Skip for now', style: dcStrong(14, color: p.ink2))),
        ]),
        children: [
          _progress(p),
          const SizedBox(height: 22),
          switch (_step) {
            0 => _basics(),
            1 => _qualifications(),
            2 => _registration(),
            3 => _documents(),
            _ => _payouts(),
          },
        ],
      ),
    );
  }

  /// Five short ink bars; done and current in ink, the rest hairline.
  Widget _progress(dynamic p) => Row(children: [
        for (var i = 0; i < _steps.length; i++) ...[
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: i <= _step ? p.ink1 : p.line,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          if (i < _steps.length - 1) const SizedBox(width: 5),
        ],
      ]);

  // ---- steps ----------------------------------------------------------------
  //
  // EVERY STEP COLUMN IS `stretch`, and it has to be. A Column defaults to
  // crossAxisAlignment.center. A _field child fills the available width because
  // the TextField inside it expands, so its label landed hard against the left
  // margin; a _chips child is a Wrap, which shrinks to fit its chips, so the
  // whole block — label and all — got centred instead. The result was TITLE and
  // LANGUAGES sitting visibly indented from FULL NAME on the same form.
  //
  // Stretching makes every child full-width, so the labels share one margin.

  Widget _basics() => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _field('Full name', 'Dr. …'),
        _field('Years of experience', 'e.g. 9', keyboard: TextInputType.number),
        _chips('Title', const ['Dr.', 'Mr.', 'Mrs.', 'Ms.']),
        _chips('Languages you consult in',
            const ['English', 'हिन्दी', 'বাংলা', 'தமிழ்', 'मराठी'],
            multi: true),
      ]);

  Widget _qualifications() => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _field('Qualification', 'MBBS, MD …'),
        _field('College / University', 'e.g. AIIMS, New Delhi'),
        _field('Year of completion', 'e.g. 2016', keyboard: TextInputType.number),
        _chips('Speciality', const [
          'Obstetrician',
          'Gynaecologist',
          'Paediatrician',
          'Lactation consultant',
          'Nutritionist',
          'Child psychologist',
          'Sleep consultant',
        ], multi: true),
      ]);

  Widget _registration() => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _field('Registration number', 'e.g. 2254785558'),
        _field('Medical council', 'e.g. Delhi Medical Council'),
        _field('Registration year', 'e.g. 2017', keyboard: TextInputType.number),
        const DcNotice(
          'This is what lets a parent check you on a public register. It is '
          'the single most important thing on this screen.',
        ),
      ]);

  Widget _documents() => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DcRowGroup(children: [
          _upload('Proof of qualification', 'Degree certificate'),
          _upload('Registration proof', 'Council registration certificate'),
          _upload('Identity proof', 'Aadhaar, PAN, passport or driving licence'),
        ]),
        const SizedBox(height: 14),
        const DcNotice(
          'Uploading is a submission, not an approval. A person at ParentVeda '
          'reviews these before your profile goes live to parents.',
        ),
      ]);

  Widget _payouts() => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _field('Account holder name', 'As printed on the passbook'),
        _field('Account number', 'The number on your passbook or cheque', keyboard: TextInputType.number),
        _field('IFSC', 'e.g. HDFC0001234', capitals: true),
        _field('PAN', 'For TDS and invoices', capitals: true),
        const DcNotice(
          'Earnings collect in your ParentVeda balance whether or not this is '
          'filled in. You just cannot withdraw until it is.',
        ),
      ]);

  // ---- pieces ---------------------------------------------------------------

  Widget _field(String label, String hint, {TextInputType? keyboard, bool capitals = false}) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: DcInput(label: label, controller: _c(label), hint: hint, keyboard: keyboard, capitals: capitals),
      );

  /// Ink pills: chosen ones fill with ink, the rest sit on a hairline.
  Widget _chips(String label, List<String> options, {bool multi = false}) {
    final p = dcP;
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label.toUpperCase(), style: dcEyebrow()),
        const SizedBox(height: 9),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final o in options) _chip(p, '$label|$o', o, multi: multi, group: label),
        ]),
      ]),
    );
  }

  Widget _chip(dynamic p, String key, String text, {required bool multi, required String group}) {
    final on = _picked.contains(key);
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () => setState(() {
        if (!multi) _picked.removeWhere((k) => k.startsWith('$group|'));
        on ? _picked.remove(key) : _picked.add(key);
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: on ? p.ink1 : p.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: on ? p.ink1 : p.line, width: 1.2),
        ),
        child: Text(text, style: dcStrong(13.5, color: on ? p.surface : p.ink1)),
      ),
    );
  }

  Widget _upload(String title, String hint) => DcRow(
        mark: DoctorMark.upload,
        title: title,
        subtitle: hint,
        trailing: Text('Upload', style: dcStrong(14, color: dcP.action)),
        chevron: false,
        onTap: () => dcToast(context, 'Uploads open once your account is verified. Email the document to partners@parentveda.com for now.'),
      );
}
