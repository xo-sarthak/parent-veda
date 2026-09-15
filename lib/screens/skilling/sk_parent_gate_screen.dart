// =============================================================================
//  SkParentGateScreen — set up and consent, the lawful front door
// -----------------------------------------------------------------------------
//  The brief's first surface: "Parent. Verify, set the child's age, consent
//  to the little data used. The lawful front door, and the gate for all
//  buying." It runs ONCE, before any skill door opens, and the child cannot
//  pass it: it asks for the parent by name, says exactly what is kept, and
//  wants a tap on the consent line before Continue does anything.
//
//  ⚠️ PRE-FILLED FROM THE PARENTING CHILD WHEN SHE IS OLD ENOUGH. The user's
//  addition to question 2: a transition should be smooth — nobody types an
//  age the app already knows. `SkChildStore.suggestion` offers the parenting
//  child at or over the floor; the fields start filled and the parent only
//  confirms. A parent whose first use of the app is a skilling-age child
//  starts empty and is asked, once.
//
//  ⚠️ THE VERIFIER IS THE STUB. `SkConsentVerifier.current` answers; today
//  it is `SkStubConsentVerifier`, which passes and is labelled as a stub on
//  the settings screen. Flagged for legal review in `docs/SKILLING-DOOR-
//  BUILD.md`. No provider is wired here and none should be without that
//  review.
//
//  ⚠️ THE PIN IS OPTIONAL. The sum-in-words gate needs nothing set up; a
//  parent who wants a PIN sets one here or later in settings.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/pv_fonts.dart';
import '../v2/v2_palette.dart';
import 'sk_bands.dart';
import 'sk_child_store.dart';
import 'sk_consent_verifier.dart';

class SkParentGateScreen extends StatefulWidget {
  const SkParentGateScreen({super.key, this.onDone});

  /// What to do after consent — usually open the door that was tapped.
  /// Null pops.
  final void Function(BuildContext context)? onDone;

  @override
  State<SkParentGateScreen> createState() => _SkParentGateScreenState();
}

class _SkParentGateScreenState extends State<SkParentGateScreen> {
  final _parent = TextEditingController();
  final _child = TextEditingController();
  final _pin = TextEditingController();
  DateTime? _dob;
  bool _consent = false;
  bool _fromParenting = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final s = SkChildStore.instance;
    // Editing an existing record, or adopting the parenting child.
    if (s.dob != null) {
      _child.text = s.name;
      _dob = s.dob;
    } else if (s.suggestion case final sug?) {
      _child.text = sug.name;
      _dob = sug.dob;
      _fromParenting = true;
    }
  }

  @override
  void dispose() {
    _parent.dispose();
    _child.dispose();
    _pin.dispose();
    super.dispose();
  }

  int? get _years {
    final d = _dob;
    if (d == null) return null;
    final now = DateTime.now();
    var y = now.year - d.year;
    if (now.month < d.month || (now.month == d.month && now.day < d.day)) y--;
    return y < 0 ? 0 : y;
  }

  bool get _ready =>
      _parent.text.trim().isNotEmpty && _dob != null && _consent && !_busy;

  Future<void> _pickDob() async {
    // The keyboard from the name field stayed up under the picker on a
    // phone (2026-09-14) and ate the next tap. Drop focus first.
    FocusScope.of(context).unfocus();
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(now.year - 8, now.month, now.day),
      firstDate: DateTime(now.year - 18, 1, 1),
      lastDate: now,
      helpText: 'When was she born?',
    );
    if (picked != null) setState(() => _dob = picked);
  }

  Future<void> _continue() async {
    if (!_ready) return;
    setState(() => _busy = true);
    final v = await SkConsentVerifier.current.verify(
      parentName: _parent.text.trim(),
      childName: _child.text.trim(),
      childDob: _dob!,
    );
    if (!mounted) return;
    if (v == SkVerification.refused) {
      setState(() => _busy = false);
      return;
    }
    SkChildStore.instance.consent(
      name: _child.text.trim(),
      dob: _dob!,
      verification: v,
    );
    final pin = _pin.text.trim();
    if (pin.length == 4 && int.tryParse(pin) != null) {
      SkChildStore.instance.setPin(pin);
    }
    if (widget.onDone != null) {
      widget.onDone!(context);
    } else {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: V2PaletteStore.instance,
        builder: (context, _) =>
            _body(context, V2PaletteStore.instance.current),
      );

  Widget _body(BuildContext context, V2Palette p) {
    final years = _years;
    final band = years == null ? null : skBandFor(years);
    return Scaffold(
      backgroundColor: p.ground,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, border: Border.all(color: p.line)),
                  child: Icon(Icons.arrow_back_rounded, size: 19, color: p.ink1),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text('SKILLING  ·  FOR THE PARENT',
                style: pvManrope(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.3,
                    color: p.action)),
            const SizedBox(height: 8),
            Text('Set up and consent',
                style: pvFraunces(
                    fontSize: 27,
                    fontWeight: FontWeight.w600,
                    height: 1.15,
                    color: p.ink1)),
            const SizedBox(height: 10),
            Text(
                'The learning screens talk to your child. Everything around '
                'them — her age, her settings, anything to do with money — '
                'sits with you. This is where that starts.',
                style: pvManrope(fontSize: 14.5, height: 1.55, color: p.ink2)),
            const SizedBox(height: 24),

            _label('You', p),
            _field(_parent, 'Your name', p,
                key: const Key('sk-gate-parent'),
                onChanged: (_) => setState(() {})),
            const SizedBox(height: 18),

            _label('Your child', p),
            if (_fromParenting)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text('Filled in from her profile. Change anything that is wrong.',
                    style: pvManrope(fontSize: 12.5, height: 1.45, color: p.ink3)),
              ),
            _field(_child, 'Her name (what the screens call her)', p,
                key: const Key('sk-gate-child')),
            const SizedBox(height: 10),
            InkWell(
              key: const Key('sk-gate-dob'),
              onTap: _pickDob,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: p.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: p.line),
                ),
                child: Row(children: [
                  Icon(Icons.cake_outlined, size: 18, color: p.ink2),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                        _dob == null
                            ? 'Her date of birth'
                            : '${_dob!.day}/${_dob!.month}/${_dob!.year}'
                                '  ·  $years years',
                        style: pvManrope(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            color: _dob == null ? p.ink3 : p.ink1)),
                  ),
                  Icon(Icons.chevron_right_rounded, size: 20, color: p.ink3),
                ]),
              ),
            ),
            if (years != null) ...[
              const SizedBox(height: 8),
              Text(
                  band == null
                      ? 'Skilling starts at $kSkAgeFloor. Until then the doors '
                          'show what is coming, locked, and you can still read '
                          'the grown-up side.'
                      : 'She will see the ${band.label} band. No age chooser '
                          'anywhere — the app scopes to her on its own.',
                  style: pvManrope(fontSize: 12.5, height: 1.45, color: p.ink2)),
            ],
            const SizedBox(height: 22),

            _label('What is kept', p),
            Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              decoration: BoxDecoration(
                color: p.surfaceAlt,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                for (final line in const [
                  'Her name and date of birth, so the screens can speak to '
                      'her and scope to her age.',
                  'The words "tried", "practised again" and "made" against '
                      'the activities she does. Never a score.',
                  'Recordings she makes in her own voice, on the doors that '
                      'keep one. On this phone only; you can delete any of '
                      'them.',
                  'All of it on this phone only. Nothing about her is sent '
                      'anywhere, and no ad is ever shown to her.',
                ]) ...[
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Icon(Icons.check_rounded, size: 15, color: p.action),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(line,
                          style: pvManrope(
                              fontSize: 13, height: 1.5, color: p.ink1)),
                    ),
                  ]),
                  const SizedBox(height: 6),
                ],
              ]),
            ),
            const SizedBox(height: 12),
            InkWell(
              key: const Key('sk-gate-consent'),
              onTap: () => setState(() => _consent = !_consent),
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(
                      _consent
                          ? Icons.check_box_rounded
                          : Icons.check_box_outline_blank_rounded,
                      size: 24,
                      color: _consent ? p.action : p.ink3),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                        'I am her parent or guardian, and I consent to this '
                        'little data being kept on this phone.',
                        style: pvManrope(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            height: 1.5,
                            color: p.ink1)),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 18),

            _label('Grown-up gate (optional)', p),
            Text(
                'When she reaches a link, a purchase or these settings, the '
                'app asks a sum in words. Set a four-digit PIN to be asked '
                'that instead.',
                style: pvManrope(fontSize: 12.5, height: 1.45, color: p.ink2)),
            const SizedBox(height: 8),
            _field(_pin, 'PIN (4 digits, or leave empty)', p,
                key: const Key('sk-gate-pin'),
                digits: true,
                maxLength: 4,
                obscure: true),
            const SizedBox(height: 8),
            Text(
                'Verification: ${SkConsentVerifier.current.label}.',
                style: pvManrope(fontSize: 11.5, height: 1.45, color: p.ink3)),
            const SizedBox(height: 22),

            SizedBox(
              height: 54,
              child: FilledButton(
                key: const Key('sk-gate-continue'),
                onPressed: _ready ? _continue : null,
                style: FilledButton.styleFrom(
                    backgroundColor: p.action,
                    disabledBackgroundColor: p.surfaceAlt,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14))),
                child: Text('Continue',
                    style: pvManrope(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: _ready ? Colors.white : p.ink3)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String t, V2Palette p) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(t.toUpperCase(),
            style: pvManrope(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
                color: p.ink3)),
      );

  Widget _field(TextEditingController c, String hint, V2Palette p,
          {Key? key,
          bool digits = false,
          int? maxLength,
          bool obscure = false,
          ValueChanged<String>? onChanged}) =>
      TextField(
        key: key,
        controller: c,
        onChanged: onChanged,
        obscureText: obscure,
        keyboardType: digits ? TextInputType.number : TextInputType.name,
        inputFormatters: digits ? [FilteringTextInputFormatter.digitsOnly] : null,
        maxLength: maxLength,
        textCapitalization: TextCapitalization.words,
        style: pvManrope(fontSize: 14.5, fontWeight: FontWeight.w600, color: p.ink1),
        decoration: InputDecoration(
          counterText: '',
          hintText: hint,
          hintStyle: pvManrope(fontSize: 14, color: p.ink3),
          filled: true,
          fillColor: p.surface,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: p.line)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: p.line)),
        ),
      );
}
