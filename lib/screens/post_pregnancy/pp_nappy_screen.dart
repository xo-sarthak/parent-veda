// =============================================================================
//  PpNappyScreen — the nappy log (surface pp_nappies), 2026-10-07
// -----------------------------------------------------------------------------
//  Parenting gap analysis, P1 (Behind · Logging): "Our own safety check asks
//  for a number she has no way to keep. Add a nappy log: Wet / Dirty / Both,
//  and for dirty an optional colour from 6 swatches. If she picks red, black
//  after the first days, or white or very pale, show: 'Show this to your
//  doctor today. Take a photo of the nappy if you can.' Show today's wet
//  count beside 'Is my baby OK?'."
//
//  The store, the colour notes and the backend are the fork's
//  (CognihabRepo/parent-veda-fork f3e0a27: NappyStore, `pp_nappy_logs`,
//  child-scoped and co-parented, migration 0094). This screen is new, on the
//  shared tool shell, so it reads as the same family as every pregnancy and
//  trying-to-conceive tool.
//
//  Mobbin: Google Health's "Add blood glucose" sheet (value, then a time row
//  that defaults to now, chips, one Save) for the details sheet; Oura's single
//  numeral for the counts; Google Health's week of bars for the week
//  (refs in pp_care_parts.dart). One tap for the common case: the three
//  buttons log straight away and say so, with Undo.
// =============================================================================

import 'package:flutter/material.dart';

import '../brackets/hub/hub_intent_art.dart' show IntentMark;
import '../pregnancy/preg_tool_chrome.dart';
import '../pregnancy/preg_tool_parts.dart' show PregFoldRow;
import '../products/pv_store_chrome.dart' show PvSecondary;
import '../v2/v2_palette.dart';
import '../../theme/pv_fonts.dart';
import '../../widgets/pv_feedback.dart';
import 'pp_care_log_data.dart';
import 'pp_care_parts.dart';
import 'pp_child_profile.dart';

/// The swatch for each colour: a calm, recognisable version of it.
Color ppNappySwatch(NappyColour c) => switch (c) {
      NappyColour.yellow => const Color(0xFFE9C64A),
      NappyColour.mustard => const Color(0xFFC79A2E),
      NappyColour.green => const Color(0xFF6F8F3A),
      NappyColour.brown => const Color(0xFF7A4E2D),
      NappyColour.black => const Color(0xFF222222),
      NappyColour.red => const Color(0xFFC0392B),
      NappyColour.pale => const Color(0xFFE8E4DA),
    };

/// True for the colours that mean "today, not at the next visit": red, pale,
/// and black once the first few days of meconium are over.
bool ppNappyColourUrgent(NappyColour c, {required int ageDays}) =>
    c == NappyColour.red || c == NappyColour.pale || (c == NappyColour.black && ageDays > 4);

/// The gap analysis's words, shown under an urgent colour.
const String kPpNappyUrgentLine = 'Show this to your doctor today. Take a photo of the nappy if you can.';

class PpNappyScreen extends StatefulWidget {
  const PpNappyScreen({super.key});

  @override
  State<PpNappyScreen> createState() => _PpNappyScreenState();
}

class _PpNappyScreenState extends State<PpNappyScreen> {
  final _store = NappyStore.instance;

  @override
  void initState() {
    super.initState();
    _store.init();
  }

  void _quick(NappyKind kind) {
    pvCommitFeedback();
    _store.log(time: DateTime.now(), kind: kind);
    final saved = _store.last;
    ppCareSaved(context, '${nappyKindLabel(kind)} nappy saved, ${ppCareClock(DateTime.now())}.',
        undo: saved == null ? null : () => _store.remove(saved.id));
  }

  /// Wet nappies on each of the last seven days, oldest first.
  List<int> _wetWeek() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return [
      for (var i = 6; i >= 0; i--)
        _store.all.where((n) {
          final d = DateTime(n.time.year, n.time.month, n.time.day);
          return n.isWet && d == today.subtract(Duration(days: i));
        }).length,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_store, ChildProfileStore.instance]),
      builder: (context, _) {
        final p = V2PaletteStore.instance.current;
        final today = _store.todays;
        final last = _store.last;
        final c = ChildProfileStore.instance;
        return PregToolScaffold(
          hue: 206,
          eyebrow: 'Feeding',
          mark: IntentMark.dropMark,
          title: 'Nappies',
          intro: 'One tap when you change ${c.them}. Wet nappies are the clearest sign milk is going in.',
          children: [
            pregToolPad(PpCareStats([
              ('${_store.wetToday}', 'wet today'),
              ('${_store.dirtyToday}', 'dirty today'),
              (last == null ? 'None yet' : ppCareAgo(last.time), 'last change'),
            ])),
            const SizedBox(height: 18),
            pregToolPad(Row(children: [
              for (final (i, k) in [NappyKind.wet, NappyKind.dirty, NappyKind.mixed].indexed) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(child: _QuickButton(kind: k, onTap: () => _quick(k))),
              ],
            ])),
            const SizedBox(height: 10),
            pregToolPad(PvSecondary(
              key: const ValueKey('pp_nappy_details'),
              label: 'Add colour, texture or an earlier time',
              icon: Icons.tune_rounded,
              onTap: _openSheet,
            )),
            const SizedBox(height: 18),
            pregToolPad(Text(_store.insight(),
                key: const ValueKey('pp_nappy_insight'),
                style: pvManrope(fontSize: 14, height: 1.5, color: p.ink1))),
            const SizedBox(height: 26),
            pregToolPad(ppCareHeading("Today's nappies")),
            const SizedBox(height: 6),
            if (today.isEmpty)
              pregToolPad(Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text('Nothing logged today. Tap Wet or Dirty at the next change; that is all it takes.',
                    key: const ValueKey('pp_nappy_empty'),
                    style: pvManrope(fontSize: 14, height: 1.5, color: p.ink2)),
              ))
            else
              for (final n in today)
                pregToolPad(PpCareEntryRow(
                  key: ValueKey('pp_nappy_row_${n.id}'),
                  title: nappyKindLabel(n.kind),
                  when: n.time,
                  detail: [
                    if (n.colour != null) nappyColourLabel(n.colour!),
                    if (n.texture != null) nappyTextureLabel(n.texture!),
                    if (n.note != null) n.note!,
                  ].join(' · '),
                  onRemove: () {
                    _store.remove(n.id);
                    ppCareSaved(context, 'Nappy removed.', undo: () => _store.add(n));
                  },
                )),
            const SizedBox(height: 26),
            pregToolPad(ppCareHeading('Wet nappies this week')),
            const SizedBox(height: 12),
            pregToolPad(PpWeekBars(values: _wetWeek(), unit: 'wet')),
            const SizedBox(height: 22),
            PregFoldRow(
              keyPrefix: 'pp_nappy_guide',
              fold: 'colours',
              icon: Icons.palette_outlined,
              title: 'What the colour usually means',
              body: _colourGuide(p),
            ),
            const SizedBox(height: 32),
          ],
        );
      },
    );
  }

  Widget _colourGuide(V2Palette p) {
    final days = ChildProfileStore.instance.ageInDays;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      for (final col in NappyColour.values) ...[
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _Swatch(colour: col, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(nappyColourLabel(col), style: pvManrope(fontSize: 14, fontWeight: FontWeight.w700, color: p.ink1)),
              const SizedBox(height: 2),
              Text(nappyColourNote(col, ageDays: days) ?? '',
                  style: pvManrope(fontSize: 13, height: 1.5, color: p.ink2)),
            ]),
          ),
        ]),
        const SizedBox(height: 12),
      ],
      Text('A guide, not a diagnosis. If your baby seems unwell, whatever the colour, call your paediatrician.',
          style: pvManrope(fontSize: 12.5, height: 1.5, color: p.ink2)),
    ]);
  }

  void _openSheet() {
    var kind = NappyKind.dirty;
    NappyColour? colour;
    NappyTexture? texture;
    var when = DateTime.now();
    final note = TextEditingController();
    final days = ChildProfileStore.instance.ageInDays;
    showPpCareSheet(
      context,
      title: 'Log a nappy',
      saveLabel: 'Save nappy',
      body: (setSheet) {
        final p = V2PaletteStore.instance.current;
        final dirty = kind == NappyKind.dirty || kind == NappyKind.mixed;
        return [
          ppCareLabel('When'),
          PpWhenRow(when: when, onChanged: (t) => setSheet(() => when = t)),
          const SizedBox(height: 16),
          ppCareLabel('What was in it?'),
          ppCareChoices<NappyKind>(
            values: NappyKind.values,
            selected: kind,
            label: nappyKindLabel,
            keyPrefix: 'pp_nappy_kind',
            onPick: (k) => setSheet(() => kind = k ?? kind),
          ),
          if (dirty) ...[
            const SizedBox(height: 16),
            ppCareLabel('Colour, if you noticed'),
            Wrap(spacing: 10, runSpacing: 10, children: [
              for (final col in NappyColour.values)
                Semantics(
                  button: true,
                  selected: colour == col,
                  label: nappyColourLabel(col),
                  child: GestureDetector(
                    key: ValueKey('pp_nappy_colour_${col.name}'),
                    onTap: () => setSheet(() => colour = colour == col ? null : col),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      _Swatch(colour: col, size: 36, selected: colour == col),
                      const SizedBox(height: 4),
                      Text(nappyColourLabel(col),
                          textScaler: TextScaler.noScaling,
                          style: pvManrope(fontSize: 11, fontWeight: FontWeight.w600, color: p.ink2)),
                    ]),
                  ),
                ),
            ]),
            if (colour != null) ...[
              const SizedBox(height: 12),
              if (ppNappyColourUrgent(colour!, ageDays: days))
                Container(
                  key: const ValueKey('pp_nappy_urgent'),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFC0392B)),
                  ),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Icon(Icons.local_hospital_outlined, size: 20, color: Color(0xFFC0392B)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(kPpNappyUrgentLine,
                          style: pvManrope(fontSize: 14, fontWeight: FontWeight.w700, height: 1.45, color: p.ink1)),
                    ),
                  ]),
                ),
              const SizedBox(height: 8),
              Text(nappyColourNote(colour!, ageDays: days) ?? '',
                  style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink2)),
            ],
            const SizedBox(height: 16),
            ppCareLabel('Texture, if you noticed'),
            ppCareChoices<NappyTexture>(
              values: NappyTexture.values,
              selected: texture,
              label: nappyTextureLabel,
              allowNone: true,
              keyPrefix: 'pp_nappy_texture',
              onPick: (t) => setSheet(() => texture = t),
            ),
          ],
          const SizedBox(height: 16),
          ppCareLabel('Note'),
          ppCareNoteField(note),
        ];
      },
      onSave: () {
        final dirty = kind == NappyKind.dirty || kind == NappyKind.mixed;
        _store.log(
            time: when,
            kind: kind,
            colour: dirty ? colour : null,
            texture: dirty ? texture : null,
            note: ppCareNoteValue(note));
        ppCareSaved(context, '${nappyKindLabel(kind)} nappy saved, ${ppCareWhen(when).toLowerCase()}.');
      },
    );
  }
}

class _QuickButton extends StatelessWidget {
  const _QuickButton({required this.kind, required this.onTap});
  final NappyKind kind;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final icon = switch (kind) {
      NappyKind.wet => Icons.water_drop_outlined,
      NappyKind.dirty => Icons.circle_outlined,
      _ => Icons.join_full_outlined,
    };
    // The one ink: everything pressable is the switch black.
    return Material(
      color: const Color(0xFF2F2C30),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        key: ValueKey('pp_nappy_quick_${kind.name}'),
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 20, color: Colors.white),
            const SizedBox(height: 4),
            Text(nappyKindLabel(kind),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: pvManrope(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
          ]),
        ),
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.colour, required this.size, this.selected = false});
  final NappyColour colour;
  final double size;
  final bool selected;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: ppNappySwatch(colour),
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? const Color(0xFF2F2C30) : const Color(0x33000000),
            width: selected ? 3 : 1,
          ),
        ),
        child: selected ? const Icon(Icons.check_rounded, size: 18, color: Colors.white) : null,
      );
}
