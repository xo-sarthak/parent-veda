// =============================================================================
//  FeedingTrackerScreen - everyday Feeding tracker (parenting · Tools)
// -----------------------------------------------------------------------------
//  A calm, one-glance answer to "when did the baby last feed, and how's today
//  going?". A soft summary hero (feeds today · last feed, relative), a prominent
//  "Log a feed" sheet that adapts to Breast / Bottle / Solids, and today's feeds
//  as a quiet list with a delete affordance. Reads the shared PpTrackerStore and
//  rebuilds on change. Design language mirrors the Vax + Health screens.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'pp_common.dart';
import 'pp_trackers_data.dart';

class FeedingTrackerScreen extends StatefulWidget {
  const FeedingTrackerScreen({super.key});

  @override
  State<FeedingTrackerScreen> createState() => _FeedingTrackerScreenState();
}

class _FeedingTrackerScreenState extends State<FeedingTrackerScreen> {
  final _store = PpTrackerStore.instance;

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: _store,
          builder: (context, _) {
            final today = _store.todaysFeeds;
            final last = _store.lastFeed;
            return ListView(
              padding: const EdgeInsets.only(top: 12, bottom: 48),
              children: [
                _pad(ppBack(context, 'Tools')),
                const SizedBox(height: 18),
                _pad(ppEyebrow('ParentVeda', color: ppPurple)),
                const SizedBox(height: 8),
                _pad(Text('Feeding tracker', style: ppFraunces(30, h: 1.1))),
                const SizedBox(height: 8),
                _pad(Text('A gentle record of how today is going - no pressure, just a rhythm you can see.',
                    style: ppBody(14, h: 1.55))),

                const SizedBox(height: 20),
                _pad(_hero(today.length, last)),

                const SizedBox(height: 16),
                _pad(_logButton()),

                const SizedBox(height: 26),
                _pad(Row(children: [
                  Expanded(child: Text("Today's feeds", style: ppJakarta(16))),
                  Text(today.isEmpty ? '' : '${today.length} logged', style: ppBody(12, color: ppMuted)),
                ])),
                const SizedBox(height: 14),
                if (today.isEmpty)
                  _pad(_empty())
                else
                  _pad(Column(children: [for (final f in today) _feedRow(f)])),
              ],
            );
          },
        ),
      ),
    );
  }

  // ---- summary hero -------------------------------------------------------
  Widget _hero(int count, FeedEntry? last) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.white, ppStripeB]),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: ppHair),
          boxShadow: const [BoxShadow(color: Color(0x1A6A30B6), blurRadius: 30, spreadRadius: -20, offset: Offset(0, 12))],
        ),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('$count', style: ppFraunces(38, color: ppPurple, h: 1.0)),
              const SizedBox(height: 2),
              Text(count == 1 ? 'feed today' : 'feeds today', style: ppBody(12.5, color: ppSoft, w: FontWeight.w600)),
            ]),
          ),
          Container(width: 1, height: 46, color: ppHair),
          const SizedBox(width: 18),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.schedule_rounded, size: 15, color: ppPurple),
                const SizedBox(width: 6),
                Text('Last feed', style: ppBody(11.5, color: ppMuted, w: FontWeight.w700)),
              ]),
              const SizedBox(height: 6),
              Text(last == null ? 'none yet' : _relative(last.time), style: ppJakarta(17)),
              const SizedBox(height: 2),
              Text(last == null ? 'log the first below' : _feedDetail(last), style: ppBody(12, color: ppSoft), maxLines: 1, overflow: TextOverflow.ellipsis),
            ]),
          ),
        ]),
      );

  Widget _logButton() => GestureDetector(
        onTap: _openLogSheet,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: ppPurple, borderRadius: BorderRadius.circular(16), boxShadow: ppCardShadow),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.add_rounded, size: 20, color: Colors.white),
            const SizedBox(width: 8),
            Text('Log a feed', style: ppBody(15, color: Colors.white, w: FontWeight.w700)),
          ]),
        ),
      );

  Widget _empty() => Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(18)),
        child: Row(children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Icon(Icons.local_drink_outlined, size: 20, color: ppPurple),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text('No feeds logged today yet. Tap "Log a feed" whenever you like - a few taps keep the rhythm.',
                style: ppBody(13, h: 1.5)),
          ),
        ]),
      );

  // ---- feed row -----------------------------------------------------------
  Widget _feedRow(FeedEntry f) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: ppHair)),
        child: Row(children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: _tint(f.type), borderRadius: BorderRadius.circular(12)),
            child: Icon(_icon(f.type), size: 19, color: ppInk),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(_typeLabel(f.type), style: ppJakarta(14.5)),
                const SizedBox(width: 8),
                Text(_clock(f.time), style: ppBody(11.5, color: ppMuted)),
              ]),
              const SizedBox(height: 3),
              Text(_feedDetail(f), style: ppBody(12.5, color: ppSoft, h: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
            ]),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _confirmDelete('Remove this feed?', () => _store.removeFeed(f.id)),
            behavior: HitTestBehavior.opaque,
            child: const Padding(padding: EdgeInsets.only(left: 4), child: Icon(Icons.delete_outline_rounded, size: 20, color: ppMuted)),
          ),
        ]),
      );

  // ---- log sheet ----------------------------------------------------------
  void _openLogSheet() {
    FeedType type = FeedType.breast;
    FeedSide side = FeedSide.left;
    final amount = TextEditingController();
    final duration = TextEditingController();
    final note = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: ppBg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: ppLine, borderRadius: BorderRadius.circular(999)))),
                const SizedBox(height: 16),
                Text('Log a feed', style: ppJakarta(18)),
                const SizedBox(height: 16),

                _label('Type'),
                Row(children: [
                  for (final t in FeedType.values) ...[
                    _typeChip(t, type == t, () => setSheet(() => type = t)),
                    if (t != FeedType.values.last) const SizedBox(width: 8),
                  ],
                ]),
                const SizedBox(height: 16),

                // type-specific fields
                if (type == FeedType.breast) ...[
                  _label('Side'),
                  Row(children: [
                    _sideChip('Left', side == FeedSide.left, () => setSheet(() => side = FeedSide.left)),
                    const SizedBox(width: 8),
                    _sideChip('Right', side == FeedSide.right, () => setSheet(() => side = FeedSide.right)),
                  ]),
                  const SizedBox(height: 12),
                  _tf(duration, 'Duration (minutes)', number: true),
                ] else if (type == FeedType.bottle) ...[
                  _tf(amount, 'Amount (ml)', number: true),
                ],
                _tf(note, type == FeedType.solid ? 'What they ate' : 'Note (optional)', maxLines: 2),

                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    _store.logFeed(
                      time: DateTime.now(),
                      type: type,
                      side: type == FeedType.breast ? side : null,
                      durationMin: type == FeedType.breast ? int.tryParse(duration.text.trim()) : null,
                      amountMl: type == FeedType.bottle ? int.tryParse(amount.text.trim()) : null,
                      note: note.text.trim().isEmpty ? null : note.text.trim(),
                    );
                    Navigator.of(ctx).pop();
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: ppPurple, borderRadius: BorderRadius.circular(14)),
                    child: Text('Save feed', style: ppBody(15, color: Colors.white, w: FontWeight.w700)),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(String title, VoidCallback onConfirm) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: ppBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (ctx) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(title, style: ppJakarta(16)),
            const SizedBox(height: 18),
            Row(children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.of(ctx).pop(),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: ppLine)),
                    child: Text('Cancel', style: ppBody(14, color: ppInk, w: FontWeight.w700)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    onConfirm();
                    Navigator.of(ctx).pop();
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: ppCoral, borderRadius: BorderRadius.circular(14)),
                    child: Text('Remove', style: ppBody(14, color: Colors.white, w: FontWeight.w700)),
                  ),
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  // ---- small parts --------------------------------------------------------
  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(t, style: ppBody(12, color: ppSoft, w: FontWeight.w700)),
      );

  Widget _typeChip(FeedType t, bool on, VoidCallback onTap) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: BoxDecoration(
              color: on ? ppPurple : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: on ? ppPurple : ppLine),
            ),
            child: Column(children: [
              Icon(_icon(t), size: 18, color: on ? Colors.white : ppPurple),
              const SizedBox(height: 5),
              Text(_typeLabel(t), style: ppBody(12, color: on ? Colors.white : ppInk, w: FontWeight.w700)),
            ]),
          ),
        ),
      );

  Widget _sideChip(String label, bool on, VoidCallback onTap) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 11),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: on ? ppPurple : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: on ? ppPurple : ppLine),
            ),
            child: Text(label, style: ppBody(13, color: on ? Colors.white : ppInk, w: FontWeight.w700)),
          ),
        ),
      );

  Widget _tf(TextEditingController c, String label, {int maxLines = 1, bool number = false}) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _label(label),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: ppLine)),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              controller: c,
              maxLines: maxLines,
              keyboardType: number ? TextInputType.number : TextInputType.text,
              inputFormatters: number ? [FilteringTextInputFormatter.digitsOnly] : null,
              style: ppBody(14, color: ppInk),
              decoration: const InputDecoration(isDense: true, filled: false, border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 12)),
            ),
          ),
        ]),
      );

  // ---- formatting helpers -------------------------------------------------
  String _typeLabel(FeedType t) => switch (t) {
        FeedType.breast => 'Breast',
        FeedType.bottle => 'Bottle',
        FeedType.solid => 'Solids',
      };

  IconData _icon(FeedType t) => switch (t) {
        FeedType.breast => Icons.child_care_outlined,
        FeedType.bottle => Icons.local_drink_outlined,
        FeedType.solid => Icons.restaurant_outlined,
      };

  Color _tint(FeedType t) => switch (t) {
        FeedType.breast => const Color(0xFFEDEAF7),
        FeedType.bottle => const Color(0xFFEAF4EE),
        FeedType.solid => const Color(0xFFFBEAF0),
      };

  String _feedDetail(FeedEntry f) {
    switch (f.type) {
      case FeedType.breast:
        final parts = <String>[
          if (f.side != null) f.side == FeedSide.left ? 'Left side' : 'Right side',
          if (f.durationMin != null) '${f.durationMin} min',
        ];
        final base = parts.isEmpty ? 'Breastfeed' : parts.join(' · ');
        return f.note != null ? '$base · ${f.note}' : base;
      case FeedType.bottle:
        final base = f.amountMl != null ? '${f.amountMl} ml' : 'Bottle';
        return f.note != null ? '$base · ${f.note}' : base;
      case FeedType.solid:
        return f.note ?? 'Solid food';
    }
  }

  String _relative(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) {
      final h = diff.inHours;
      final m = diff.inMinutes % 60;
      return m == 0 ? '${h}h ago' : '${h}h ${m}m ago';
    }
    return '${diff.inDays}d ago';
  }

  String _clock(DateTime t) {
    final ampm = t.hour < 12 ? 'AM' : 'PM';
    var h = t.hour % 12;
    if (h == 0) h = 12;
    return '$h:${t.minute.toString().padLeft(2, '0')} $ampm';
  }
}
