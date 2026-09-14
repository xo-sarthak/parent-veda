// =============================================================================
//  SkGrownUpScreen — the parent's side of a skill door, behind the gate
// -----------------------------------------------------------------------------
//  The four parent surfaces the brief lists, on one screen in the parent's
//  voice: the PARENT NOTE (what she has been doing, why it helps, how to
//  help), the COURSE SHELF (leveled live and recorded classes, placeholder
//  price, enrol behind the gate), the PRODUCT SHELF (kits, robotics, books,
//  age-tagged) and SET UP AND CONSENT (the child's record, the PIN, the
//  verifier's word, and the way to withdraw).
//
//  ⚠️ IT ASKS THE GATE ON OPEN. The screen is reached from a child screen
//  (the closing card, a deep link, the router), so the first thing it does
//  is `skAskGrownUp`; until that passes it draws nothing but a lock, and a
//  fail pops it. A child who taps "For the grown-up" sees the sum and then
//  the door again. Money, settings and the note never render to her.
//
//  ⚠️ ENROL AND BUY ARE STUB SHEETS, the user's call (question 7): the price
//  in ₹ and $ and "opens when the programme is real". Not the booking
//  engine, not the parenting shop (question 6). The shelves are the layout
//  that ships; what they open is the part that waits.
//
//  ⚠️ THE NOTE'S BUILT HALF IS THE KEEPSAKE'S WORDS. The copy is job two
//  (coming soon, in the ledger), but "what she has been doing" is already
//  answerable from `SkPracticeStore.entriesFor` — so that list is drawn
//  here, in words, and the authored part is the honest placeholder card.
// =============================================================================

import 'package:flutter/material.dart';

import '../../services/bracket_resolver.dart';
import '../../theme/pv_fonts.dart';
import '../v2/v2_palette.dart';
import 'sk_bands.dart';
import 'sk_child_store.dart';
import 'sk_consent_verifier.dart';
import 'sk_content.dart';
import 'sk_content_registry.dart';
import 'sk_door_content.dart';
import 'sk_grown_up_gate.dart';
import 'sk_practice_store.dart';

/// Which shelf to scroll to when opened by a deep link.
enum SkGrownUpSection { note, courses, products, settings }

class SkGrownUpScreen extends StatefulWidget {
  const SkGrownUpScreen({
    super.key,
    required this.doorId,
    this.section = SkGrownUpSection.note,
    this.alreadyPassed = false,
  });

  final String doorId;
  final SkGrownUpSection section;

  /// The closing card asked the gate a moment ago; do not ask twice.
  final bool alreadyPassed;

  @override
  State<SkGrownUpScreen> createState() => _SkGrownUpScreenState();
}

class _SkGrownUpScreenState extends State<SkGrownUpScreen> {
  late bool _passed = widget.alreadyPassed;
  final _keys = {for (final s in SkGrownUpSection.values) s: GlobalKey()};

  @override
  void initState() {
    super.initState();
    if (!_passed) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final ok = await skAskGrownUp(context);
        if (!mounted) return;
        if (!ok) {
          Navigator.of(context).maybePop();
          return;
        }
        setState(() => _passed = true);
        _scrollToSection();
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSection());
    }
  }

  void _scrollToSection() {
    final ctx = _keys[widget.section]?.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx,
          duration: const Duration(milliseconds: 300));
    }
  }

  SkDoorContent? get content => skDoorContentFor(widget.doorId);

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: Listenable.merge([
          V2PaletteStore.instance,
          SkChildStore.instance,
          SkPracticeStore.instance,
        ]),
        builder: (context, _) =>
            _body(context, V2PaletteStore.instance.current),
      );

  Widget _body(BuildContext context, V2Palette p) {
    final c = content;
    final bracket = bracketById(widget.doorId);
    final child = SkChildStore.instance;
    final band = child.band;
    if (!_passed || c == null) {
      return Scaffold(
        backgroundColor: p.ground,
        body: Center(
          child: Icon(Icons.lock_outline_rounded, size: 28, color: p.ink3),
        ),
      );
    }
    return Scaffold(
      backgroundColor: p.ground,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 48),
          children: [
            Row(children: [
              skBack(context, p),
            ]),
            const SizedBox(height: 18),
            Text((bracket?.title.now ?? widget.doorId).toUpperCase(),
                style: pvManrope(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: p.action)),
            const SizedBox(height: 8),
            Text('For the grown-up',
                style: pvFraunces(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                    color: p.ink1)),
            const SizedBox(height: 8),
            Text(c.parentNote.subtitle ?? '',
                style: pvManrope(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                    height: 1.55,
                    color: p.ink2)),
            const SizedBox(height: 26),

            // ---- the parent note --------------------------------------------
            _Head('What she has been doing', p, key: _keys[SkGrownUpSection.note]),
            const SizedBox(height: 10),
            _Doing(doorId: widget.doorId, content: c, p: p),
            const SizedBox(height: 14),
            _SoonCard(
              p: p,
              title: 'Why it helps her thinking, and how to help',
              line: 'The note for this door is being written. It will say, '
                  'in plain words, what each thinking skill is and how to '
                  'back it at home. No ranking, no worry-making.',
            ),
            const SizedBox(height: 30),

            // ---- the course shelf --------------------------------------------
            _Head('Live and recorded classes', p, key: _keys[SkGrownUpSection.courses]),
            const SizedBox(height: 4),
            Text(
                'Leveled to where she is. They teach; they promise nothing '
                'about her future.',
                style: pvManrope(fontSize: 13.5, height: 1.45, color: p.ink2)),
            const SizedBox(height: 12),
            for (final course in c.coursesFor(band?.id)) ...[
              _ShelfRow(
                p: p,
                icon: course.mode == SkCourseMode.live
                    ? Icons.videocam_outlined
                    : Icons.play_circle_outline_rounded,
                chip: course.comingSoon ? 'Coming soon' : 'Course',
                title: course.title,
                line: '${course.modeLabel}  ·  ${c.bandName(course.level)}',
                blurb: course.blurb,
                price: _price(course.priceInr, course.priceUsd),
                dimmed: false,
                onTap: () => _enrol(context, c, course),
              ),
              const SizedBox(height: 10),
            ],
            if (c.coursesFor(band?.id).isEmpty)
              _SoonCard(
                  p: p,
                  title: 'No classes at this level yet',
                  line: 'They arrive band by band.'),
            const SizedBox(height: 30),

            // ---- the product shelf -------------------------------------------
            _Head('Related things to buy', p, key: _keys[SkGrownUpSection.products]),
            const SizedBox(height: 4),
            Text(
                'Kits, robotics and books tagged to her age. Bought here, by '
                'you; never shown to her as an ad.',
                style: pvManrope(fontSize: 13.5, height: 1.45, color: p.ink2)),
            const SizedBox(height: 12),
            for (final prod in c.productsFor(band?.id)) ...[
              _ShelfRow(
                p: p,
                icon: switch (prod.kind) {
                  SkProductKind.kit => Icons.handyman_outlined,
                  SkProductKind.robotics => Icons.smart_toy_outlined,
                  SkProductKind.book => Icons.menu_book_outlined,
                  SkProductKind.game => Icons.casino_outlined,
                  SkProductKind.other => Icons.shopping_bag_outlined,
                },
                chip: prod.comingSoon ? 'Coming soon' : prod.kindLabel,
                title: prod.title,
                line: prod.kindLabel,
                blurb: prod.blurb,
                price: prod.priceInr == null ? null : '₹${prod.priceInr}',
                dimmed: false,
                onTap: () => _buy(context, prod),
              ),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 30),

            // ---- set up and consent ------------------------------------------
            _Head('Set up and consent', p, key: _keys[SkGrownUpSection.settings]),
            const SizedBox(height: 12),
            _Settings(p: p),
          ],
        ),
      ),
    );
  }

  static String? _price(int? inr, int? usd) {
    if (inr == null && usd == null) return null;
    final parts = [
      if (inr != null) '₹$inr',
      if (usd != null) '\$$usd',
    ];
    return parts.join('  ·  ');
  }

  void _enrol(BuildContext context, SkDoorContent c, SkCourse course) {
    _stubSheet(
      context,
      eyebrow: 'ENROL  ·  ${course.modeLabel.toUpperCase()}',
      title: course.title,
      lines: [
        'Level: ${c.bandName(course.level)} (${skBandById(course.level)?.label ?? course.level}).',
        if (_price(course.priceInr, course.priceUsd) case final pr?)
          'Placeholder price: $pr. The real price is set when the programme is.',
        'Enrolment opens when this programme is real. Nothing is charged '
            'from here.',
        'It teaches. It does not promise what she will become.',
      ],
    );
  }

  void _buy(BuildContext context, SkProduct prod) {
    _stubSheet(
      context,
      eyebrow: 'BUY  ·  ${prod.kindLabel.toUpperCase()}',
      title: prod.title,
      lines: [
        prod.blurb,
        'Buying opens when a real, sourced item is here. Nothing is charged '
            'from here.',
      ],
    );
  }

  void _stubSheet(BuildContext context,
      {required String eyebrow,
      required String title,
      required List<String> lines}) {
    final p = V2PaletteStore.instance.current;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: p.ground,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (_) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
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
                Text(eyebrow,
                    style: pvManrope(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: p.action)),
                const SizedBox(height: 6),
                Text(title,
                    style: pvFraunces(
                        fontSize: 21,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                        color: p.ink1)),
                const SizedBox(height: 12),
                for (final l in lines.where((l) => l.isNotEmpty)) ...[
                  Text(l,
                      style: pvManrope(
                          fontSize: 14, height: 1.55, color: p.ink2)),
                  const SizedBox(height: 8),
                ],
              ]),
        ),
      ),
    );
  }
}

class _Head extends StatelessWidget {
  const _Head(this.text, this.p, {super.key});
  final String text;
  final V2Palette p;
  @override
  Widget build(BuildContext context) => Text(text,
      style: pvFraunces(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          height: 1.22,
          letterSpacing: -0.4,
          color: p.ink1));
}

/// What she has been doing: the keepsake's lines, in words, and — where an
/// activity has its parent line — the thinking behind it.
class _Doing extends StatelessWidget {
  const _Doing({required this.doorId, required this.content, required this.p});
  final String doorId;
  final SkDoorContent content;
  final V2Palette p;

  @override
  Widget build(BuildContext context) {
    final lines = SkPracticeStore.instance.entriesFor(doorId);
    final name = SkChildStore.instance.name;
    if (lines.isEmpty) {
      return _SoonCard(
        p: p,
        title: name.isEmpty
            ? 'Nothing tried yet'
            : '$name has not tried anything here yet',
        line: 'When she taps "I tried it" on an activity, it shows here in '
            'words — what she did, and the thinking skill it built.',
        icon: Icons.auto_awesome_outlined,
      );
    }
    return Column(children: [
      for (final l in lines.take(6)) ...[
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 13),
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: p.line),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l.title,
                style: pvManrope(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                    color: p.ink1)),
            const SizedBox(height: 3),
            Text(l.word,
                style: pvManrope(fontSize: 13, height: 1.4, color: p.ink2)),
            if (content.activityById(l.itemId) case final a?)
              if (a.theThinking.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(a.theThinking,
                    style: pvManrope(
                        fontSize: 13, height: 1.5, color: p.ink2)),
              ],
          ]),
        ),
        const SizedBox(height: 8),
      ],
    ]);
  }
}

class _SoonCard extends StatelessWidget {
  const _SoonCard(
      {required this.p,
      required this.title,
      required this.line,
      this.icon = Icons.edit_note_rounded});
  final V2Palette p;
  final String title;
  final String line;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
        decoration: BoxDecoration(
          color: p.surfaceAlt,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 18, color: p.ink2),
          const SizedBox(width: 10),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: pvManrope(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                      color: p.ink1)),
              const SizedBox(height: 4),
              Text(line,
                  style: pvManrope(fontSize: 13, height: 1.5, color: p.ink2)),
            ]),
          ),
        ]),
      );
}

class _ShelfRow extends StatelessWidget {
  const _ShelfRow({
    required this.p,
    required this.icon,
    required this.chip,
    required this.title,
    required this.line,
    required this.blurb,
    required this.dimmed,
    required this.onTap,
    this.price,
  });
  final V2Palette p;
  final IconData icon;
  final String chip;
  final String title;
  final String line;
  final String blurb;
  final String? price;
  final bool dimmed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: dimmed ? null : onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: p.line),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: p.surfaceAlt,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 18, color: p.ink1),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: pvFraunces(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w600,
                          height: 1.25,
                          letterSpacing: -0.3,
                          color: p.ink1)),
                  const SizedBox(height: 3),
                  Text(line,
                      style: pvManrope(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                          color: p.ink2)),
                  const SizedBox(height: 4),
                  Text(blurb,
                      style: pvManrope(
                          fontSize: 13, height: 1.45, color: p.ink2)),
                  const SizedBox(height: 9),
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: p.ground,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: p.line),
                      ),
                      child: Text(chip,
                          style: pvManrope(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              color: p.ink3)),
                    ),
                    if (price != null) ...[
                      const SizedBox(width: 8),
                      Text(price!,
                          style: pvManrope(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: p.ink1)),
                    ],
                  ]),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right_rounded, size: 20, color: p.ink3),
          ]),
        ),
      );
}

/// The child's record, the PIN, the verifier's word, and withdrawal.
class _Settings extends StatelessWidget {
  const _Settings({required this.p});
  final V2Palette p;

  @override
  Widget build(BuildContext context) {
    final s = SkChildStore.instance;
    final band = s.band;
    final years = s.ageYears;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: p.line),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _kv('Child', s.name.isEmpty ? 'No name' : s.name, p),
        _kv(
            'Age',
            years == null
                ? '—'
                : '$years years'
                    '${band == null ? '  ·  under the floor of $kSkAgeFloor' : '  ·  ${band.label}'}',
            p),
        _kv(
            'Consent',
            s.consentedAt == null
                ? 'Not given'
                : 'Given ${s.consentedAt!.day}/${s.consentedAt!.month}/${s.consentedAt!.year}',
            p),
        _kv('Verification', _verificationLabel(s.verification), p),
        _kv('Grown-up gate', s.hasPin ? 'PIN' : 'A sum in words', p),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: [
          _action(context, s.hasPin ? 'Change PIN' : 'Set a PIN',
              () => _askPin(context)),
          if (s.hasPin)
            _action(context, 'Use the sum instead', () => s.setPin(null)),
          _action(context, 'Withdraw consent and forget her', () {
            SkPracticeStore.instance.forgetAll();
            s.forget();
            Navigator.of(context).popUntil((r) => r.isFirst);
          }, quiet: true),
        ]),
        const SizedBox(height: 12),
        Text(
            'Kept on this phone only. Nothing about her is sent anywhere, '
            'and nothing here can produce a score.',
            style: pvManrope(fontSize: 12, height: 1.5, color: p.ink3)),
      ]),
    );
  }

  static String _verificationLabel(SkVerification v) => switch (v) {
        SkVerification.none => 'Not run',
        SkVerification.stub => SkConsentVerifier.current.label,
        SkVerification.verified => 'Verified',
        SkVerification.refused => 'Refused',
      };

  Widget _kv(String k, String v, V2Palette p) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            width: 104,
            child: Text(k.toUpperCase(),
                style: pvManrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                    height: 1.6,
                    color: p.ink3)),
          ),
          Expanded(
            child: Text(v,
                style: pvManrope(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    height: 1.45,
                    color: p.ink1)),
          ),
        ]),
      );

  Widget _action(BuildContext context, String label, VoidCallback onTap,
          {bool quiet = false}) =>
      OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: quiet ? p.ink2 : p.action,
          side: BorderSide(color: p.line),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(label,
            style: pvManrope(fontSize: 12.5, fontWeight: FontWeight.w800)),
      );

  Future<void> _askPin(BuildContext context) async {
    final ctl = TextEditingController();
    final pin = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: p.ground,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('A four-digit PIN for the grown-up gate',
                  style: pvFraunces(
                      fontSize: 20, fontWeight: FontWeight.w600, color: p.ink1)),
              const SizedBox(height: 12),
              TextField(
                controller: ctl,
                autofocus: true,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 4,
                decoration: const InputDecoration(counterText: '', hintText: '••••'),
                onSubmitted: (v) => Navigator.of(ctx).pop(v),
              ),
              const SizedBox(height: 10),
              FilledButton(
                  onPressed: () => Navigator.of(ctx).pop(ctl.text),
                  child: const Text('Save')),
            ]),
          ),
        ),
      ),
    );
    if (pin != null && pin.length == 4 && int.tryParse(pin) != null) {
      SkChildStore.instance.setPin(pin);
    }
  }
}
