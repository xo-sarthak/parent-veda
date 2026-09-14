// =============================================================================
//  skAskGrownUp — the "ask a grown-up" check on a child screen
// -----------------------------------------------------------------------------
//  Two gates, and they are different things:
//
//    · The PARENT GATE (`sk_parent_gate_screen.dart`) runs once: verify,
//      consent, set the child's age. It is the lawful front door.
//    · THIS is the quick adult check every time a child screen reaches the
//      parent's territory — a purchase, a link out, settings, the parent
//      note. The brief: "no external link or purchase without an 'ask a
//      grown-up' gate."
//
//  ⚠️ TWO WAYS TO PASS, THE USER'S CALL (2026-09-14, question 5, "both"):
//
//    a. A sum written in words — "What is twelve plus seven?" — the kids'-app
//       standard. A six-year-old cannot read it; a nine-year-old can, which
//       is why it is a convenience and not a lock. Digits would be too easy;
//       words are what makes it an adult check.
//    b. A four-digit PIN, if the parent set one at consent. Then the PIN is
//       asked instead of the sum, every time.
//
//  Returns true when passed. Every caller `await`s it and does nothing on
//  false — including no snackbar, because a child who fails should see the
//  sheet close and nothing else. Nothing is recorded about attempts.
// =============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/pv_fonts.dart';
import '../v2/v2_palette.dart';
import 'sk_child_store.dart';

const List<String> _words = [
  'zero', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight',
  'nine', 'ten', 'eleven', 'twelve', 'thirteen', 'fourteen', 'fifteen',
  'sixteen', 'seventeen', 'eighteen', 'nineteen', 'twenty',
];

/// The question and its answer. Public so a test can check the sum gate
/// without a screen.
class SkGrownUpSum {
  SkGrownUpSum._(this.a, this.b);
  factory SkGrownUpSum.random([math.Random? r]) {
    final rnd = r ?? math.Random();
    // Both terms at least six, so a child who can add on fingers still has
    // to read the words. Sums to at most 40.
    return SkGrownUpSum._(6 + rnd.nextInt(15), 6 + rnd.nextInt(15));
  }
  final int a;
  final int b;
  String get question => 'What is ${_words[a]} plus ${_words[b]}?';
  int get answer => a + b;
  bool check(String typed) => int.tryParse(typed.trim()) == answer;
}

/// Ask. True when the grown-up passed.
Future<bool> skAskGrownUp(BuildContext context) async {
  final store = SkChildStore.instance;
  final usePin = store.hasPin;
  final sum = SkGrownUpSum.random();
  final passed = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: V2PaletteStore.instance.current.ground,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
    builder: (_) => _GateSheet(usePin: usePin, sum: sum),
  );
  return passed ?? false;
}

class _GateSheet extends StatefulWidget {
  const _GateSheet({required this.usePin, required this.sum});
  final bool usePin;
  final SkGrownUpSum sum;

  @override
  State<_GateSheet> createState() => _GateSheetState();
}

class _GateSheetState extends State<_GateSheet> {
  final _ctl = TextEditingController();
  bool _wrong = false;

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  void _submit() {
    final ok = widget.usePin
        ? SkChildStore.instance.checkPin(_ctl.text.trim())
        : widget.sum.check(_ctl.text);
    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      // One quiet retry. A second miss closes the sheet — a child guessing
      // gets nothing to push against.
      if (_wrong) {
        Navigator.of(context).pop(false);
        return;
      }
      setState(() {
        _wrong = true;
        _ctl.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                      color: p.line, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 18),
              Row(children: [
                Icon(Icons.lock_outline_rounded, size: 18, color: p.action),
                const SizedBox(width: 8),
                Text('ASK A GROWN-UP',
                    style: pvManrope(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: p.action)),
              ]),
              const SizedBox(height: 10),
              Text(
                  widget.usePin
                      ? 'Enter the grown-up PIN.'
                      : widget.sum.question,
                  key: const Key('sk-gate-question'),
                  style: pvFraunces(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                      color: p.ink1)),
              const SizedBox(height: 6),
              Text(
                  _wrong
                      ? 'Not quite. One more try.'
                      : 'This part is for a parent.',
                  style: pvManrope(
                      fontSize: 13.5,
                      height: 1.5,
                      color: _wrong ? p.action : p.ink2)),
              const SizedBox(height: 16),
              TextField(
                key: const Key('sk-gate-answer'),
                controller: _ctl,
                autofocus: true,
                obscureText: widget.usePin,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: widget.usePin ? 4 : 2,
                onSubmitted: (_) => _submit(),
                style: pvManrope(
                    fontSize: 20, fontWeight: FontWeight.w700, color: p.ink1),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: widget.usePin ? '••••' : 'The number',
                  filled: true,
                  fillColor: p.surface,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: p.line)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: p.line)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  key: const Key('sk-gate-submit'),
                  onPressed: _submit,
                  style: FilledButton.styleFrom(
                      backgroundColor: p.action,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14))),
                  child: Text('Open',
                      style: pvManrope(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
