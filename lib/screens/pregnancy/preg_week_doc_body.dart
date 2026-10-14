// =============================================================================
//  PregWeekDocBody — the week Details sheet for a week with a content doc
// -----------------------------------------------------------------------------
//  2026-10-13. The user's week-wise docs (lib/data/preg_week_pages.dart),
//  drawn in the docs' own order on the page the Details pill opens. A part
//  of preg_week_screen.dart so it reuses that page's tiles, notes and
//  sources rather than copying them; weeks without a doc keep `_WeekBody`.
//
//  Layout from the Mobbin pass (plan, §3b): rows in one hairline card that
//  open a sheet (Faire / TIDE info sheets) with the doc's "Got it"; the
//  symptom sheet in headed parts with the doctor line in its own callout
//  (Tempo, Hers, Google Health); diet as one list with a Favour · Avoid
//  switch (Singapore Airlines); jump links so a long page stays walkable;
//  sources folded away at the foot (Flo's References).
// =============================================================================

part of '../preg_week_screen.dart';

class PregWeekDocBody extends StatefulWidget {
  const PregWeekDocBody({
    super.key,
    required this.p,
    required this.page,
    this.content,
  });
  final V2Palette p;
  final PregWeekPage page;

  /// The older week entry, for Myth or fact; null when the week has none.
  final WeekContent? content;

  @override
  State<PregWeekDocBody> createState() => _PregWeekDocBodyState();
}

class _PregWeekDocBodyState extends State<PregWeekDocBody> {
  final _baby = GlobalKey();
  final _you = GlobalKey();
  final _symptoms = GlobalKey();
  final _diet = GlobalKey();
  final _partner = GlobalKey();
  bool _avoid = false;

  V2Palette get p => widget.p;

  void _jump(GlobalKey k) {
    final c = k.currentContext;
    if (c != null) {
      Scrollable.ensureVisible(c, duration: const Duration(milliseconds: 320), curve: Curves.easeOutCubic);
    }
  }

  Widget _h(String t, {Key? key}) => Semantics(
        key: key,
        header: true,
        child: Text(t, style: pregSectionHeadingStyle()),
      );

  Widget _body(String t) => Text(t, style: pvManrope(fontSize: 14, height: 1.55, color: p.ink2));

  Widget _sub(String t) => Text(t,
      style: pvManrope(fontSize: 14.5, fontWeight: FontWeight.w800, height: 1.35, color: p.ink1));

  @override
  Widget build(BuildContext context) {
    final page = widget.page;
    final week = page.week;
    final extra = kPregWeekExtras[week];
    final plan = widget.content?.actionPlan;
    final myth = plan?.mythBuster.myth.en.trim() ?? '';
    final truth = plan?.mythBuster.truth.en.trim() ?? '';
    // HIS SIDE (2026-10-14): her page with less on it, as his home. Her body,
    // symptoms and diet stay hers; the partner part leads, spoken to him.
    final him = FatherPreview.instance.on;
    final hisPart = <Widget>[
      const SizedBox(height: 22),
      _h('Your part this week', key: _partner),
      const SizedBox(height: 10),
      _Note(p: p, label: 'A NOTE FROM YOUR BABY', text: page.partnerNote),
      const SizedBox(height: 14),
      _sub('How she is doing'),
      const SizedBox(height: 4),
      _body(page.partnerHowMom),
      const SizedBox(height: 14),
      _sub('Scans and appointments coming up'),
      const SizedBox(height: 6),
      for (final s in page.partnerScans) _Bullet(p: p, text: s),
      const SizedBox(height: 10),
      _sub('How you can help'),
      const SizedBox(height: 6),
      for (final s in page.partnerHelp) _Bullet(p: p, text: s),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---- title, month, desk line (as the older body) ------------------------
        Text('What happens in week $week',
            style: pvFraunces(fontSize: 24, fontWeight: FontWeight.w600, height: 1.15, letterSpacing: -0.5, color: p.ink1)),
        const SizedBox(height: 6),
        Text('Week $week · Month ${pregMonthFor(week)} · ${pregTrimesterFor(week)}',
            style: pvManrope(fontSize: 13, fontWeight: FontWeight.w700, height: 1.4, color: p.ink1)),
        const SizedBox(height: 4),
        Text('ParentVeda editorial · averages for the week, never a measurement of your ${pregBabies()}',
            style: pvManrope(fontSize: 12, height: 1.45, color: p.ink3)),
        if (pregExpectingTwins) ...[
          const SizedBox(height: 6),
          Text(kPregTwinWeekNote, style: pvManrope(fontSize: 12, height: 1.45, color: p.ink3)),
        ],
        const SizedBox(height: 18),

        // ---- opening snapshot ---------------------------------------------------
        Row(children: [
          Expanded(child: _Tile(p: p, label: 'LENGTH', value: page.length)),
          const SizedBox(width: 10),
          Expanded(child: _Tile(p: p, label: 'WEIGHT', value: page.weight)),
        ]),
        const SizedBox(height: 10),
        _Tile(p: p, label: 'ABOUT THE SIZE OF', value: pregDocFruit(page.fruit), wide: true),

        // ---- jump links ---------------------------------------------------------
        const SizedBox(height: 14),
        _JumpLinks(p: p, links: [
          if (him) ('Your part', () => _jump(_partner)),
          ('Baby', () => _jump(_baby)),
          if (!him) ...[
            ('You', () => _jump(_you)),
            ('Symptoms', () => _jump(_symptoms)),
            ('Diet', () => _jump(_diet)),
            ('Partner', () => _jump(_partner)),
          ],
        ]),
        if (him) ...hisPart,

        // ---- about your baby ----------------------------------------------------
        const SizedBox(height: 22),
        _h('About your ${pregBabies()}', key: _baby),
        const SizedBox(height: 8),
        Text(page.teaser,
            style: pvFraunces(fontSize: 19, fontWeight: FontWeight.w500, height: 1.3, color: p.ink1)),
        for (final a in page.about) ...[
          const SizedBox(height: 14),
          // "Opening description" is the doc's label for the lead, not a heading.
          if (a.heading != 'Opening description') ...[_sub(a.heading), const SizedBox(height: 4)],
          _body(a.body),
        ],
        if (page.behaviour.isNotEmpty) ...[
          const SizedBox(height: 18),
          _Eyebrow(p: p, text: 'WHAT I AM UP TO'),
          // Inline, never tappable: the doc's rule for behavioural highlights.
          for (final b in page.behaviour) ...[
            const SizedBox(height: 10),
            _sub(b.title),
            const SizedBox(height: 4),
            _body(b.body),
          ],
        ],

        // ---- baby science -------------------------------------------------------
        const SizedBox(height: 24),
        _h('Baby science'),
        const SizedBox(height: 8),
        _RowCard(p: p, rows: [
          for (final s in page.science)
            _RowItem(
              icon: _scienceIcon(s.title),
              title: s.title,
              onTap: () => _showCardSheet(context, p, _scienceIcon(s.title), s.title, s.body),
            ),
        ]),
        const SizedBox(height: 8),
        Text(kPregWeekScienceFooter, style: pvManrope(fontSize: 12, height: 1.45, color: p.ink3)),

        // ---- you this week ------------------------------------------------------
        // Her sections, through to sharing with her partner: not on his side.
        if (!him) ...[
        const SizedBox(height: 24),
        _h('You this week', key: _you),
        for (final y in page.you) ...[
          const SizedBox(height: 14),
          _sub(y.heading),
          const SizedBox(height: 4),
          _body(y.body),
        ],
        const SizedBox(height: 16),
        _RowCard(p: p, rows: [
          for (final h in page.highlights)
            _RowItem(
              icon: _youIcon(h.title),
              title: h.title,
              teaser: h.teaser,
              onTap: () => _showCardSheet(context, p, _youIcon(h.title), h.title, h.body),
            ),
        ]),
        const SizedBox(height: 14),
        _Note(p: p, label: 'SELF-CARE', text: page.selfCare),
        const SizedBox(height: 10),
        _Urgent(p: p, label: 'A GENTLE REMINDER', text: page.reminder),

        // ---- symptoms -----------------------------------------------------------
        const SizedBox(height: 24),
        _h('What you might notice this week', key: _symptoms),
        const SizedBox(height: 4),
        Text(kPregWeekSymptomsIntro, style: pvManrope(fontSize: 13, height: 1.5, color: p.ink3)),
        const SizedBox(height: 10),
        _RowCard(p: p, rows: [
          for (final s in page.symptoms)
            _RowItem(
              icon: IntentMark.bodyMark, // was Icons.healing_outlined
              title: s.name,
              teaser: s.teaser,
              onTap: () => _showSymptomSheet(context, p, s),
            ),
        ]),
        const SizedBox(height: 8),
        Text(page.symptomsFooter, style: pvManrope(fontSize: 12, height: 1.45, color: p.ink3)),

        // ---- diet ---------------------------------------------------------------
        const SizedBox(height: 24),
        _h('Eating well this week', key: _diet),
        const SizedBox(height: 10),
        _Superfood(p: p, food: page.superfood),
        const SizedBox(height: 14),
        _Switch(
          p: p,
          left: 'Foods to favour',
          right: 'What to avoid',
          rightOn: _avoid,
          onChanged: (v) => setState(() => _avoid = v),
        ),
        const SizedBox(height: 10),
        for (final f in _avoid ? page.avoid : page.favour) _FoodCard(p: p, food: f, avoid: _avoid),

        // ---- trimester tips (week 5) --------------------------------------------
        if (page.tips.isNotEmpty) ...[
          const SizedBox(height: 24),
          _h('Trimester tips'),
          if (page.tipsTitle.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(page.tipsTitle, style: pvManrope(fontSize: 12.5, height: 1.4, color: p.ink3)),
          ],
          const SizedBox(height: 4),
          for (final t in page.tips) _Question(p: p, q: t.tip, a: t.more),
        ],

        // ---- share with partner -------------------------------------------------
        const SizedBox(height: 24),
        _h('Share with your partner', key: _partner),
        const SizedBox(height: 10),
        _Note(p: p, label: 'A NOTE FROM YOUR BABY', text: page.partnerNote),
        const SizedBox(height: 14),
        _sub('How mom is doing'),
        const SizedBox(height: 4),
        _body(page.partnerHowMom),
        const SizedBox(height: 14),
        _sub('Scans and appointments coming up'),
        const SizedBox(height: 6),
        for (final s in page.partnerScans) _Bullet(p: p, text: s),
        const SizedBox(height: 10),
        _sub('How you can help'),
        const SizedBox(height: 6),
        for (final s in page.partnerHelp) _Bullet(p: p, text: s),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            key: const ValueKey('week_share_partner'),
            style: OutlinedButton.styleFrom(
              foregroundColor: kPvInk,
              side: const BorderSide(color: kPvLine),
              shape: const StadiumBorder(),
            ),
            onPressed: () => Share.share(pregWeekPartnerMessage(page)),
            icon: const Icon(Icons.ios_share_rounded, size: 16),
            label: Text('Share with your partner',
                style: pvManrope(fontSize: 13, fontWeight: FontWeight.w700, color: kPvInk)),
          ),
        ),
        ],

        // ---- kept from the older page -------------------------------------------
        if (extra != null && extra.asked.isNotEmpty) ...[
          const SizedBox(height: 24),
          _h('Asked this week'),
          const SizedBox(height: 4),
          for (final qa in extra.asked) _Question(p: p, q: qa.q, a: qa.a),
        ],
        if (myth.isNotEmpty && truth.isNotEmpty) ...[
          const SizedBox(height: 18),
          _Note(p: p, label: 'MYTH OR FACT', title: myth, text: truth),
        ],
        if (extra != null && extra.sources.isNotEmpty) ...[
          const SizedBox(height: 14),
          Material(
            type: MaterialType.transparency,
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.only(bottom: 6),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                iconColor: p.ink2,
                collapsedIconColor: p.ink3,
                title: Text('References',
                    style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w800, color: p.ink2)),
                children: [_Sources(p: p, keys: extra.sources)],
              ),
            ),
          ),
        ],
        const SizedBox(height: 10),
        Text(
          'Averages for week $week. Every baby grows at their own pace, and your scan is what counts, not this page.',
          style: pvManrope(fontSize: 12, height: 1.45, color: p.ink3),
        ),
      ],
    );
  }
}

/// What the Share button sends: the week, the baby's note, and how to help.
String pregWeekPartnerMessage(PregWeekPage page) => [
      'Our Pregnancy Week: Week ${page.week}',
      '',
      page.partnerNote,
      '',
      'How you can help:',
      for (final h in page.partnerHelp) '- $h',
      '',
      'From ParentVeda',
    ].join('\n');

// ⚠️ THE APP'S DRAWN MARKS, NOT MATERIAL ICONS (the user, 2026-10-13: "use the
// latest ones that we are using"). `IntentMark` is the family the Symptoms door
// beside this page draws. The Material versions are kept below for revert.
IntentMark _scienceIcon(String title) {
  final t = title.toLowerCase();
  if (t.contains('heart')) return IntentMark.bodyMark;
  if (t.contains('brain') || t.contains('nerve') || t.contains('spine')) return IntentMark.headMark;
  if (t.contains('eye') || t.contains('light') || t.contains('see')) return IntentMark.lampMark;
  if (t.contains('ear') || t.contains('hear')) return IntentMark.audioMark;
  if (t.contains('finger') || t.contains('hand') || t.contains('grip') || t.contains('toe')) {
    return IntentMark.cuppedHands;
  }
  if (t.contains('lung') || t.contains('breath') || t.contains('airway') || t.contains('hiccup')) {
    return IntentMark.windMark;
  }
  if (t.contains('bone') || t.contains('skeleton')) return IntentMark.spineMark;
  if (t.contains('sleep')) return IntentMark.sleepMark;
  if (t.contains('taste') || t.contains('swallow') || t.contains('stomach') || t.contains('gut')) {
    return IntentMark.feedMark;
  }
  if (t.contains('move') || t.contains('kick') || t.contains('flex') || t.contains('stretch')) {
    return IntentMark.kickMark;
  }
  return IntentMark.tummyMark;
}

IntentMark _youIcon(String title) {
  final t = title.toLowerCase();
  if (t.contains('hormone')) return IntentMark.dropMark;
  if (t.contains('emotion') || t.contains('mood') || t.contains('feel') || t.contains('mind')) {
    return IntentMark.moodArc;
  }
  if (t.contains('sleep')) return IntentMark.sleepMark;
  if (t.contains('heart') || t.contains('breath')) return IntentMark.windMark;
  if (t.contains('skin') || t.contains('hair')) return IntentMark.skinMark;
  if (t.contains('appetite') || t.contains('craving') || t.contains('food') || t.contains('digest')) {
    return IntentMark.plate;
  }
  if (t.contains('ache') || t.contains('pain') || t.contains('twinge') || t.contains('back')) {
    return IntentMark.spineMark;
  }
  if (t.contains('move') || t.contains('kick') || t.contains('flutter')) return IntentMark.kickMark;
  return IntentMark.bodyMark;
}

// Kept for revert — the Material icons these marks replaced:
//   heart favorite_border_rounded · brain psychology_outlined · eye
//   visibility_outlined · ear hearing_rounded · hand back_hand_outlined ·
//   breath air_rounded · bone accessibility_new_rounded · sleep
//   bedtime_outlined · food restaurant_outlined · default auto_awesome_outlined;
//   hormones science_outlined · mood sentiment_satisfied_outlined · skin
//   face_outlined · aches healing_outlined · movement waves_rounded · spa_outlined.

/// Small-caps label over a block.
class _Eyebrow extends StatelessWidget {
  const _Eyebrow({required this.p, required this.text});
  final V2Palette p;
  final String text;

  @override
  Widget build(BuildContext context) => Text(text,
      style: pvManrope(fontSize: 9.5, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: p.ink3));
}

/// Underlined text links to the page's sections; not pills, so they never
/// read as a second row of week chips.
class _JumpLinks extends StatelessWidget {
  const _JumpLinks({required this.p, required this.links});
  final V2Palette p;
  final List<(String, VoidCallback)> links;

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: 4,
        runSpacing: 0,
        children: [
          for (final (label, go) in links)
            InkWell(
              onTap: go,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Text(label,
                    style: pvManrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: p.ink1,
                      decoration: TextDecoration.underline,
                    ).copyWith(decorationColor: p.ink3)),
              ),
            ),
        ],
      );
}

class _RowItem {
  const _RowItem({required this.icon, required this.title, this.teaser, required this.onTap});
  final IntentMark icon;
  final String title;
  final String? teaser;
  final VoidCallback onTap;
}

/// Rows in one hairline card: line icon · title · teaser · chevron.
class _RowCard extends StatelessWidget {
  const _RowCard({required this.p, required this.rows});
  final V2Palette p;
  final List<_RowItem> rows;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), side: const BorderSide(color: kPvLine)),
        clipBehavior: Clip.antiAlias,
        child: Column(children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const Divider(height: 1, thickness: 1, color: kPvLine, indent: 58),
            InkWell(
              onTap: rows[i].onTap,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
                child: Row(children: [
                  _IconDisc(p: p, icon: rows[i].icon),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(rows[i].title,
                          style: pvManrope(fontSize: 14, fontWeight: FontWeight.w700, height: 1.35, color: p.ink1)),
                      if (rows[i].teaser case final t? when t.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(t,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: pvManrope(fontSize: 12.5, height: 1.45, color: p.ink2)),
                      ],
                    ]),
                  ),
                  Icon(Icons.chevron_right_rounded, size: 20, color: p.ink3),
                ]),
              ),
            ),
          ],
        ]),
      );
}

/// A drawn mark in its pastel, as the Symptoms door draws its marks (was a
/// Material icon in a grey disc, kept for revert:
///   Container(circle, p.surfaceAlt, child: Icon(icon, size * 0.53, p.ink1))).
class _IconDisc extends StatelessWidget {
  const _IconDisc({required this.p, required this.icon, this.size = 32});
  final V2Palette p;
  final IntentMark icon;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: HubIntentArt(mark: icon, tint: v2BlockTint(268, p)),
      );
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.p, required this.text});
  final V2Palette p;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.only(top: 8, right: 10),
            child: Container(width: 5, height: 5, decoration: BoxDecoration(color: p.ink3, shape: BoxShape.circle)),
          ),
          Expanded(child: Text(text, style: pvManrope(fontSize: 14, height: 1.55, color: p.ink2))),
        ]),
      );
}

/// The Indian superfood of the week.
class _Superfood extends StatelessWidget {
  const _Superfood({required this.p, required this.food});
  final V2Palette p;
  final PregWeekSuperfood food;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          color: p.surfaceAlt,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kPvLine),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _Eyebrow(p: p, text: 'INDIAN SUPERFOOD OF THE WEEK'),
          const SizedBox(height: 6),
          Text(food.food, style: pvFraunces(fontSize: 20, fontWeight: FontWeight.w600, height: 1.2, color: p.ink1)),
          const SizedBox(height: 6),
          Text(food.benefit, style: pvManrope(fontSize: 14, height: 1.5, color: p.ink1)),
          const SizedBox(height: 8),
          Text.rich(TextSpan(children: [
            TextSpan(text: 'Try it as: ', style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w700, color: p.ink1)),
            TextSpan(text: food.tryAs, style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink2)),
          ])),
          if (food.note.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(food.note, style: pvManrope(fontSize: 13, height: 1.5, color: p.ink2)),
          ],
        ]),
      );
}

/// A two-way switch: Foods to favour · What to avoid.
class _Switch extends StatelessWidget {
  const _Switch({required this.p, required this.left, required this.right, required this.rightOn, required this.onChanged});
  final V2Palette p;
  final String left;
  final String right;
  final bool rightOn;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget seg(String label, bool on, bool value) => Expanded(
          child: Semantics(
            selected: on,
            button: true,
            child: Material(
              color: on ? kPvInk : Colors.transparent,
              shape: const StadiumBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => onChanged(value),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Center(
                    child: Text(label,
                        style: pvManrope(
                            fontSize: 13, fontWeight: FontWeight.w800, color: on ? Colors.white : p.ink2)),
                  ),
                ),
              ),
            ),
          ),
        );
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: kPvLine),
      ),
      child: Row(children: [seg(left, !rightOn, false), seg(right, rightOn, true)]),
    );
  }
}

class _FoodCard extends StatelessWidget {
  const _FoodCard({required this.p, required this.food, required this.avoid});
  final V2Palette p;
  final PregWeekFood food;
  final bool avoid;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kPvLine),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.only(top: 1, right: 10),
            // Drawn marks (2026-10-13); was Icons.do_not_disturb_on_outlined /
            // Icons.check_circle_outline_rounded.
            child: SizedBox(
                width: 22,
                height: 22,
                child: HubIntentArt(
                    mark: avoid ? IntentMark.noPlateMark : IntentMark.checkMark, tint: v2BlockTint(avoid ? 28 : 150, p))),
          ),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(food.name, style: pvManrope(fontSize: 14, fontWeight: FontWeight.w700, height: 1.35, color: p.ink1)),
              const SizedBox(height: 3),
              Text(food.reason, style: pvManrope(fontSize: 13, height: 1.5, color: p.ink2)),
            ]),
          ),
        ]),
      );
}

// ---- the sheets -------------------------------------------------------------

Widget _sheetShell(BuildContext ctx, V2Palette p, List<Widget> children) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: kPvLine, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                key: const ValueKey('week_sheet_got_it'),
                style: FilledButton.styleFrom(
                  backgroundColor: kPvInk,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: const StadiumBorder(),
                ),
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text('Got it', style: pvManrope(fontSize: 14.5, fontWeight: FontWeight.w800, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );

Future<void> _showSheet(BuildContext context, V2Palette p, List<Widget> Function(BuildContext) children) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: p.ground,
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.85),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => _sheetShell(ctx, p, children(ctx)),
    );

/// A Baby Science or highlight card: icon, title, one paragraph, Got it.
Future<void> _showCardSheet(BuildContext context, V2Palette p, IntentMark icon, String title, String body) =>
    _showSheet(context, p, (ctx) => [
          _IconDisc(p: p, icon: icon, size: 44),
          const SizedBox(height: 14),
          Text(title, style: pvFraunces(fontSize: 22, fontWeight: FontWeight.w600, height: 1.2, color: p.ink1)),
          const SizedBox(height: 10),
          Text(body, style: pvManrope(fontSize: 15, height: 1.6, color: p.ink2)),
        ]);

/// A symptom: what it is, how common, why, what may help, and when to call
/// the doctor in its own callout.
Future<void> _showSymptomSheet(BuildContext context, V2Palette p, PregWeekSymptom s) {
  Widget label(String t) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 4),
        child: _Eyebrow(p: p, text: t),
      );
  Widget text(String t) => Text(t, style: pvManrope(fontSize: 14.5, height: 1.55, color: p.ink2));
  return _showSheet(context, p, (ctx) => [
        Text(s.name, style: pvFraunces(fontSize: 22, fontWeight: FontWeight.w600, height: 1.2, color: p.ink1)),
        const SizedBox(height: 8),
        Text(s.teaser, style: pvManrope(fontSize: 14.5, height: 1.55, color: p.ink1)),
        label('HOW COMMON IS IT?'),
        text(s.howCommon),
        label('WHY IT HAPPENS'),
        text(s.why),
        label('WHAT MAY HELP'),
        for (final h in s.helps) _Bullet(p: p, text: h),
        const SizedBox(height: 14),
        _Urgent(p: p, label: 'WHEN TO CONTACT YOUR DOCTOR', text: s.whenToCall),
      ]);
}
