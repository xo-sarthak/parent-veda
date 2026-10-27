// =============================================================================
//  "How long have you been trying?" — the line and its Change sheet (T1)
// -----------------------------------------------------------------------------
//  The user, 2026-10-27: "be precise … so that user has less confusion …
//  show an option like want to edit … handle the wording, so that we provide
//  user the flexibility as well". Spec: docs/preg-ttc-tool-plans/00-MASTER.md,
//  TT1.
//
//  The line says exactly what was counted ("Counted from January 2025, leaving
//  out April to June 2025, when you were pregnant."). Change offers three
//  bases. Saving says what changed (the app explains itself).
// =============================================================================

import 'package:flutter/material.dart';

import '../../ttc/ttc_store.dart';
import '../../ttc/ttc_trying_time.dart';
import '../products/pv_store_chrome.dart' show pvSnack;
import 'ttc_common.dart';

/// The count, its line, and a Change way on. Draws nothing on his phone's
/// copy until her phone has published a start (he cannot change hers).
class TtcTryingLine extends StatelessWidget {
  const TtcTryingLine({super.key, this.onChanged});

  /// Called after she saves a new pick, so a screen can re-run its check.
  final VoidCallback? onChanged;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: TtcStore.instance,
      builder: (context, _) {
        final t = TtcStore.instance.tryingTime;
        if (t == null) return const SizedBox.shrink();
        final canChange = t.source != TtcTryingSource.partner;
        return Container(
          key: const ValueKey('ttc_trying_line'),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: ttcBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ttcBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t.heading,
                  style: ttcBody(14, color: ttcInk, w: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(t.line, style: ttcBody(12.5, color: ttcSoft)),
              if (canChange) ...[
                const SizedBox(height: 8),
                GestureDetector(
                  key: const ValueKey('ttc_trying_change'),
                  behavior: HitTestBehavior.opaque,
                  onTap: () async {
                    final changed = await showTtcTryingChange(context);
                    if (changed) onChanged?.call();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                        // A label names what it changes (the explicit-labels
                        // rule), so never a bare "Change".
                        t.startIsAGuess
                            ? 'Add when you really started'
                            : 'Change what this counts from',
                        style: ttcBody(13,
                            color: ttcTitleInk, w: FontWeight.w800)),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// The Change sheet. Returns true when she saved a different pick.
Future<bool> showTtcTryingChange(BuildContext context) async {
  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    routeSettings: const RouteSettings(name: 'ttc/trying_change'),
    builder: (_) => const _TryingSheet(),
  );
  return saved ?? false;
}

class _TryingSheet extends StatefulWidget {
  const _TryingSheet();

  @override
  State<_TryingSheet> createState() => _TryingSheetState();
}

class _TryingSheetState extends State<_TryingSheet> {
  final _store = TtcStore.instance;
  late TtcTryingBasis _pick = _store.tryingBasis ?? TtcTryingBasis.first;
  late DateTime? _own =
      _store.tryingBasis == TtcTryingBasis.own ? _store.tryingBasisDate : null;
  bool _needsDate = false;

  /// What each pick would count, worked out the same way the store does.
  TtcTryingTime? _preview(TtcTryingBasis b, {DateTime? date}) =>
      _store.tryingTimeFor(b, date: date);

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final day = await showDatePicker(
      context: context,
      initialDate: _own ?? _store.journeyStart ?? now,
      // No date in the future, none more than 15 years back.
      firstDate: DateTime(now.year - 15, now.month, now.day),
      lastDate: now,
      helpText: 'When did you start trying?',
    );
    if (day == null || !mounted) return;
    setState(() {
      _own = day;
      _pick = TtcTryingBasis.own;
      _needsDate = false;
    });
  }

  void _save() {
    if (_pick == TtcTryingBasis.own && _own == null) {
      setState(() => _needsDate = true);
      return;
    }
    final before = _store.tryingTime;
    final date = switch (_pick) {
      TtcTryingBasis.first => null,
      TtcTryingBasis.again => _store.tryingAgainSince,
      TtcTryingBasis.own => _own,
    };
    _store.setTryingBasis(_pick, date: date);
    final after = _store.tryingTime;
    Navigator.of(context).pop(true);
    if (after == null) return;
    final from = switch (after.source) {
      TtcTryingSource.own || TtcTryingSource.again =>
        ttcDayMonthYear(after.start),
      _ => ttcMonthYear(after.start),
    };
    final same = before != null && before.days == after.days;
    // The app explains every save: what it now counts, and who uses it.
    pvSnack(
      context,
      same
          ? 'Saved. Still ${after.label} of trying, from $from.'
          : 'Now counting ${after.label} of trying, from $from. '
              'The doctor check uses this.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final first = _preview(TtcTryingBasis.first);
    final againOn = _store.tryingAgainSince;
    final again =
        againOn == null ? null : _preview(TtcTryingBasis.again, date: againOn);
    final own = _own == null ? null : _preview(TtcTryingBasis.own, date: _own);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: ttcLine, borderRadius: BorderRadius.circular(999)),
                ),
              ),
              const SizedBox(height: 18),
              Text('How long have you been trying?', style: ttcJakarta(17)),
              const SizedBox(height: 14),
              if (first != null)
                _Option(
                  key: const ValueKey('ttc_trying_first'),
                  on: _pick == TtcTryingBasis.first,
                  title: first.gaps.isEmpty
                      ? 'Since I first started, ${ttcMonthYear(first.start)}'
                      : 'Since I first started, ${ttcMonthYear(first.start)}, '
                          'leaving out my pregnancy',
                  sub: first.label,
                  onTap: () => setState(() => _pick = TtcTryingBasis.first),
                ),
              if (again != null)
                _Option(
                  key: const ValueKey('ttc_trying_again'),
                  on: _pick == TtcTryingBasis.again,
                  title: 'Since I started again, ${ttcMonthYear(again.start)}',
                  sub: again.label,
                  onTap: () => setState(() => _pick = TtcTryingBasis.again),
                ),
              _Option(
                key: const ValueKey('ttc_trying_own'),
                on: _pick == TtcTryingBasis.own,
                title: own == null
                    ? 'From a different date'
                    : 'From ${ttcDayMonthYear(own.start)}'
                        '${own.gaps.isEmpty ? '' : ', leaving out my pregnancy'}',
                sub: own?.label ?? 'Pick the day',
                onTap: _pickDate,
              ),
              if (_needsDate)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text('Pick the day you started to save this.',
                      style: ttcBody(12, color: ttcMuted, w: FontWeight.w700)),
                ),
              const SizedBox(height: 12),
              Text(
                "Doctors usually ask how long you've been trying in all, so "
                'the first one is what we count unless you change it.',
                style: ttcBody(12, color: ttcSoft),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                key: const ValueKey('ttc_trying_save'),
                onTap: _save,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                      color: ttcTitleInk,
                      borderRadius: BorderRadius.circular(16)),
                  child: Text('Save',
                      style: ttcBody(14,
                          color: Colors.white, w: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    super.key,
    required this.on,
    required this.title,
    required this.sub,
    required this.onTap,
  });

  final bool on;
  final String title;
  final String sub;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: on ? ttcBg : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: on ? ttcTitleInk : ttcBorder, width: on ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Icon(on ? Icons.radio_button_checked : Icons.radio_button_off,
                size: 18, color: on ? ttcTitleInk : ttcMuted),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: ttcBody(13.5, color: ttcInk, w: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(sub, style: ttcBody(12, color: ttcSoft)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
