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
import '../post_pregnancy/pp_common.dart';

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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _store,
      builder: (context, _) => Scaffold(
        backgroundColor: ppBg,
        appBar: AppBar(
          backgroundColor: ppBg,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          title: Text('Set up your practice', style: ppJakarta(16)),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
          children: [
            _progress(),
            const SizedBox(height: 20),
            Text(_steps[_step].$1, style: ppFraunces(25, h: 1.1)),
            const SizedBox(height: 5),
            Text(_steps[_step].$2, style: ppBody(13, h: 1.5)),
            const SizedBox(height: 20),
            switch (_step) {
              0 => _basics(),
              1 => _qualifications(),
              2 => _registration(),
              3 => _documents(),
              _ => _payouts(),
            },
            const SizedBox(height: 24),
            _cta(),
            const SizedBox(height: 10),
            Center(
              child: GestureDetector(
                onTap: _skip,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text('Skip for now',
                      style: ppJakarta(13, color: ppSoft)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _progress() => Row(children: [
        for (var i = 0; i < _steps.length; i++) ...[
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: i <= _step ? ppPurple : ppHair,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          if (i < _steps.length - 1) const SizedBox(width: 5),
        ],
      ]);

  Widget _cta() => GestureDetector(
        onTap: _next,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: ppPurple, borderRadius: BorderRadius.circular(15)),
          child: Text(_step == _steps.length - 1 ? 'Finish' : 'Continue',
              style: ppJakarta(14.5, color: Colors.white)),
        ),
      );

  // ---- steps ----------------------------------------------------------------

  Widget _basics() => Column(children: [
        _field('Full name', 'Dr. …'),
        _field('Years of experience', 'e.g. 9'),
        _chips('Title', const ['Dr.', 'Mr.', 'Mrs.', 'Ms.']),
        _chips('Languages you consult in',
            const ['English', 'हिन्दी', 'বাংলা', 'தமிழ்', 'मराठी'],
            multi: true),
      ]);

  Widget _qualifications() => Column(children: [
        _field('Qualification', 'MBBS, MD …'),
        _field('College / University', 'e.g. AIIMS, New Delhi'),
        _field('Year of completion', 'e.g. 2016'),
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

  Widget _registration() => Column(children: [
        _field('Registration number', 'e.g. 2254785558'),
        _field('Medical council', 'e.g. Delhi Medical Council'),
        _field('Registration year', 'e.g. 2017'),
        _note(
          'This is what lets a parent check you on a public register. It is '
          'the single most important thing on this screen.',
        ),
      ]);

  Widget _documents() => Column(children: [
        _upload('Proof of qualification', 'Degree certificate'),
        _upload('Registration proof', 'Council registration certificate'),
        _upload('Identity proof', 'Aadhaar, PAN, passport or driving licence'),
        _note(
          'Uploading is a submission, not an approval. A person at ParentVeda '
          'reviews these before your profile goes live to parents.',
        ),
      ]);

  Widget _payouts() => Column(children: [
        _field('Account holder name', 'As printed on the passbook'),
        _field('Account number', ''),
        _field('IFSC', 'e.g. HDFC0001234'),
        _field('PAN', 'For TDS and invoices'),
        _note(
          'Earnings collect in your ParentVeda balance whether or not this is '
          'filled in. You just cannot withdraw until it is.',
        ),
      ]);

  // ---- pieces ---------------------------------------------------------------

  Widget _field(String label, String hint) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label.toUpperCase(),
              style: ppJakarta(10.5, color: ppSoft)),
          const SizedBox(height: 7),
          TextField(
            style: ppBody(13.5, color: ppInk),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: ppBody(13, color: ppMuted),
              filled: true,
              fillColor: Colors.white,
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: ppBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: ppPurple),
              ),
            ),
          ),
        ]),
      );

  Widget _chips(String label, List<String> options, {bool multi = false}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label.toUpperCase(), style: ppJakarta(10.5, color: ppSoft)),
          const SizedBox(height: 9),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final o in options)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: ppBorder),
                ),
                child: Text(o, style: ppBody(12.5, color: ppInk)),
              ),
          ]),
        ]),
      );

  Widget _upload(String title, String hint) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: ppBorder),
          ),
          child: Row(children: [
            const Icon(Icons.upload_file_outlined, size: 20, color: ppPurple),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: ppJakarta(13.5)),
                    const SizedBox(height: 2),
                    Text(hint, style: ppBody(11.5)),
                  ]),
            ),
            Text('Upload', style: ppJakarta(12, color: ppPurple)),
          ]),
        ),
      );

  Widget _note(String s) => Container(
        padding: const EdgeInsets.fromLTRB(13, 12, 13, 12),
        decoration: BoxDecoration(
          color: ppPanel,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.info_outline_rounded, size: 15, color: ppPurple),
          const SizedBox(width: 9),
          Expanded(child: Text(s, style: ppBody(11.5, h: 1.5))),
        ]),
      );
}
