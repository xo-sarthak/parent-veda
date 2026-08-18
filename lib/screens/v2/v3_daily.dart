// =============================================================================
//  V3 daily sections — My journal, and today's medicines
// -----------------------------------------------------------------------------
//  WHAT WENT MISSING, AND WHY IT MATTERS MORE THAN IT LOOKS.
//
//  V3 was built as a CONTENT screen: read this, watch this, practise this. Two
//  of Classic's sections are not content at all — they are the only two places
//  on the home screen where the mother PUTS SOMETHING IN rather than takes
//  something out. Losing them turned the home screen into a magazine.
//
//  They survived as chips in the "Also today" row, which is worse than it
//  sounds. A chip named "Medicines" says the feature exists; it cannot say
//  whether she has taken today's iron, which is the entire question. A daily
//  tick-off demoted to a link is a daily tick-off that stops happening — and
//  because Classic shows it inline for exactly that reason, moving it was a
//  regression dressed as a simplification.
//
//  WHAT IS DIFFERENT FROM CLASSIC, and why each change:
//
//  · NO COLOURED CIRCLES on the journal actions. Classic gives each of the four
//    its own saturated disc — amber, green, coral, blue — which puts four loud
//    hues on one card. DESIGN-LAYER §Q4: one loud colour, many quiet. Here the
//    four sit on the same quiet tinted square and are told apart by their line
//    icon and their label, which is what tells them apart anyway.
//  · NO COUNTER ON THE MEDICINES. Classic is fine; but a "2/3 taken" line is a
//    thing waiting to be cleared, and §16.3 bans those. The row's own tick
//    answers the question without keeping score.
//  · THE EMPTY STATE IS THE ADVERTISEMENT. A feature is never hidden — an empty
//    medicines card says what it would do for her, because the empty state is
//    the only pitch this section ever gets.
//
//  PRESENTATIONAL ONLY. Data and destinations are assembled at the call site in
//  home_v3_screen.dart, the same arrangement V3GarbhSection uses: this file
//  imports no store and no screen, so it cannot drift into knowing about the
//  pregnancy stage.
//
//  ENGLISH ONLY via `.en` at the call site — see v2_sections.dart.
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import 'v2_palette.dart';
import 'v3_daily_art.dart';

/// Nudge lightness only, so a gradient's two ends stay the same colour. Lerping
/// towards white desaturates as it lightens and the top drifts grey — the same
/// note as in v2_block_grid.dart, and the same fix.
Color _shift(Color c, double byLightness) {
  final h = HSLColor.fromColor(c);
  return h.withLightness((h.lightness + byLightness).clamp(0.0, 1.0)).toColor();
}

// -----------------------------------------------------------------------------
//  My journal
// -----------------------------------------------------------------------------

@immutable
class V3QuickAction {
  const V3QuickAction(
      {required this.icon,
      required this.label,
      required this.mark,
      required this.hue,
      required this.onTap});

  final IconData icon;

  /// The drawn mark, in the same language as the six doors.
  final V3DailyMark mark;

  /// Its hue on the controlled-pastel wheel. Four different hues, one fixed
  /// saturation and lightness — see v2_palette's v2BlockTint.
  final double hue;

  /// Two words at most. At four-across on a 360dp screen a third word wraps to
  /// a line that then has to be reserved for every tile, tall or not.
  final String label;

  final VoidCallback onTap;
}

/// The four ways in, plus the door to everything already written.
///
/// WHY FOUR ACROSS RATHER THAN A LIST. These are not choices to be weighed —
/// she already knows whether she wants to type, photograph or speak. A list
/// makes her read four rows to find the verb she arrived with; a row of four
/// puts all of them in one glance and one thumb-reach.
class V3JournalSection extends StatelessWidget {
  const V3JournalSection(
      {super.key, required this.actions, required this.p, this.onOpenAll});

  final List<V3QuickAction> actions;
  final V2Palette p;
  final VoidCallback? onOpenAll;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: p.line),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          for (final a in actions) ...[
            Expanded(child: _ActionTile(action: a, p: p)),
            if (a != actions.last) const SizedBox(width: 6),
          ],
        ]),
        const SizedBox(height: 12),
        // A BUTTON, NOT A LINE OF COLOURED TEXT. Bare text in the action
        // colour is the weakest signifier there is: it relies on the reader
        // knowing that violet means tappable, which is a convention we taught
        // and cannot assume she learned. A bordered pill says "press me"
        // without her having to know anything about our palette.
        _Pill(
            label: 'Open your journal',
            icon: Icons.menu_book_outlined,
            p: p,
            onTap: onOpenAll,
            fullWidth: true),
      ]),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.action, required this.p});
  final V3QuickAction action;
  final V2Palette p;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            // ⚠️ NO BORDER. This tile sits inside a bordered card, so its own
            // border was the second frame around the same content — padding on
            // padding, which is the mobile-layout mistake that costs the most
            // and shows the least. The fill alone is enough to say "this is a
            // target"; the card around it already said "and these four belong
            // together".
            //
            // Height 50, not 46, for the 44px minimum tap target — the tile is
            // the button, and it has to clear a thumb.
            // Four wells, four hues, four drawn marks — the doors' treatment at
            // row scale. They were one grey fill with a line icon, which made
            // the four read as one control repeated rather than as four things
            // she can do.
            Container(
              height: 54,
              width: double.infinity,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _shift(v2BlockTint(action.hue, p), 0.045),
                    _shift(v2BlockTint(action.hue, p), -0.045),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: V3DailyArt(
                    mark: action.mark, tint: v2BlockTint(action.hue, p)),
              ),
            ),
            const SizedBox(height: 8),
            // 12, up from 10.5. See the type note in v2_block_grid.dart.
            Text(action.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: pvManrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                    color: p.ink2)),
          ]),
        ),
      );
}

// -----------------------------------------------------------------------------
//  Today's medicines
// -----------------------------------------------------------------------------

@immutable
class V3MedItem {
  const V3MedItem(
      {required this.name,
      required this.sub,
      required this.taken,
      required this.onToggle});

  final String name;

  /// Dose and time, joined. Empty when she has recorded neither, and then the
  /// row is just a name — which is honest rather than padded with "—".
  final String sub;

  final bool taken;
  final VoidCallback onToggle;
}

/// Today's medicines and supplements, tickable in place.
///
/// THE WHOLE VALUE IS "IN PLACE". Anything that needs doing every single day at
/// roughly the same moment has to cost one tap from where she already is; two
/// taps and a screen transition is the difference between a habit and an
/// intention. This is the one section on the page whose job is finishing, not
/// reading — and the reason it earns a place above the fold-ish rather than a
/// chip at the bottom.
class V3MedsSection extends StatelessWidget {
  const V3MedsSection(
      {super.key,
      required this.items,
      required this.p,
      this.onManage,
      this.onAddReminder});

  final List<V3MedItem> items;
  final V2Palette p;
  final VoidCallback? onManage;
  final VoidCallback? onAddReminder;

  /// Green means done-and-safe, and nothing else, per the colour table in
  /// docs/DESIGN-LAYER.md. It is never decorative and never a link.
  static const _done = Color(0xFF4F7A52);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: p.line),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (items.isEmpty) ...[
          // ---- THE EMPTY STATE, which is the only pitch this section gets ---
          //
          // A feature is never hidden — an empty medicines card says what it
          // WOULD do for her rather than that it is empty. It also carries the
          // mark, so an empty card and a full one are recognisably the same
          // object: she should not have to work out that the thing that
          // appeared later is the thing she set up.
          Row(children: [
            _Well(mark: V3DailyMark.capsule, hue: _capsuleHue, p: p, size: 52),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nothing added yet',
                        style: pvJakarta(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: p.ink1)),
                    const SizedBox(height: 3),
                    Text('Iron, folate, calcium — whatever you take daily, '
                        'ticked off from here.',
                        style: pvManrope(
                            fontSize: 13, height: 1.45, color: p.ink3)),
                  ]),
            ),
          ]),
          const SizedBox(height: 14),
          _Ghost(
              label: 'Add a medicine or supplement',
              color: _done,
              p: p,
              onTap: onManage),
          const SizedBox(height: 4),
        ] else ...[
          // ---- THE LABEL THAT WAS MISSING -------------------------------
          //
          // The card showed two names and two empty circles and nothing said
          // what to DO with them. Tapping a row toggles it, which is a good
          // interaction and an invisible one: a row with no button on it does
          // not announce that the whole row is the button. One line fixes it,
          // and it is the cheapest kind of labelling there is — it describes
          // the gesture rather than adding a control.
          Text('Tap each one as you take it',
              style: pvManrope(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: p.ink3)),
          const SizedBox(height: 4),
          for (final m in items) ...[
            _MedRow(item: m, p: p),
            if (m != items.last)
              Divider(height: 1, thickness: 1, color: p.line),
          ],
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: _Pill(
                  label: 'Manage list',
                  icon: Icons.tune_rounded,
                  p: p,
                  onTap: onManage),
            ),
            if (onAddReminder != null) ...[
              const SizedBox(width: 8),
              Expanded(
                child: _Pill(
                    label: 'Remind me',
                    icon: Icons.notifications_none_rounded,
                    p: p,
                    onTap: onAddReminder),
              ),
            ],
          ]),
        ],
      ]),
    );
  }
}

class _MedRow extends StatelessWidget {
  const _MedRow({required this.item, required this.p});
  final V3MedItem item;
  final V2Palette p;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: item.onToggle,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: Row(children: [
            // ---- WHY THIS ROW HAD NOTHING TO LOOK AT --------------------
            //
            // It was a hollow grey circle, a name and a grey subtitle on a
            // white card. Every element on it was either grey or absent, so
            // there was no reason for the eye to stop — which is what "bland"
            // actually means here. It is not that it needed decoration; it is
            // that a card with no colour anywhere reads as a form.
            //
            // The mark fixes it honestly rather than with ornament: it says
            // "this is a medicine" at a glance, it carries the one hue this
            // section is allowed, and it matches the language the doors and the
            // journal now speak.
            _Well(mark: V3DailyMark.capsule, hue: _capsuleHue, p: p, size: 44),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: pvJakarta(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            color: item.taken ? p.ink3 : p.ink1,
                            // Struck through when taken. The row stays on the
                            // card rather than vanishing: disappearing rows
                            // make her doubt whether the tap registered.
                            decoration: item.taken
                                ? TextDecoration.lineThrough
                                : null)),
                    if (item.sub.isNotEmpty)
                      Text(item.sub,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: pvManrope(fontSize: 12.5, color: p.ink3)),
                  ]),
            ),
            const SizedBox(width: 10),
            // The tick moved to the RIGHT, and that is not cosmetic. On the
            // left it was the first thing in the row, so an unticked card read
            // as a column of empty boxes — five things undone, before she had
            // read a single name. On the right it is the answer to the row
            // rather than its heading.
            //
            // 44px target around a 26px mark, per the tap-target minimum.
            SizedBox(
              width: 44,
              height: 44,
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: item.taken
                        ? V3MedsSection._done
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: item.taken
                            ? V3MedsSection._done
                            : V3MedsSection._done.withValues(alpha: 0.35),
                        width: 1.8),
                  ),
                  child: item.taken
                      ? const Icon(Icons.check_rounded,
                          size: 16, color: Colors.white)
                      : null,
                ),
              ),
            ),
          ]),
        ),
      );
}

/// A tinted well with a drawn mark in it. The one shape shared by the medicine
/// rows and the journal tiles, so the two sections read as siblings.
class _Well extends StatelessWidget {
  const _Well(
      {required this.mark,
      required this.hue,
      required this.p,
      required this.size});

  final V3DailyMark mark;
  final double hue;
  final V2Palette p;
  final double size;

  @override
  Widget build(BuildContext context) {
    final tint = v2BlockTint(hue, p);
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_shift(tint, 0.045), _shift(tint, -0.045)],
        ),
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Padding(
        padding: EdgeInsets.all(size * 0.16),
        child: V3DailyArt(mark: mark, tint: tint),
      ),
    );
  }
}

/// Sage. Green is reserved for done-and-safe, and a supplement is the one thing
/// on this page that is literally both.
const double _capsuleHue = 104.0;

// -----------------------------------------------------------------------------
//  Invite a friend
// -----------------------------------------------------------------------------

/// The referral block, written out properly.
///
/// WHAT WAS WRONG WITH THE SHARED ONE, and it is a copy problem rather than a
/// design one. It said *"Going through this with a friend? Invite her and you
/// both get 1 free consultation."* Twenty words that leave every real question
/// unanswered: free consultation with WHOM, when does she get it, when do I,
/// does it cost anything, how many can I invite. A reader who has to guess at
/// terms assumes the worst ones — which is exactly the instinct the review
/// corpus shows this audience arriving with.
///
/// SO THIS SPELLS THE DEAL OUT, and that is the design. §16.3's wedge is *you
/// always know the price before the pitch*; the honest form of that on a free
/// offer is stating the mechanics before asking. It is longer than the banner
/// it replaces and that is the point — the length IS the reassurance.
///
/// V3-ONLY, not a change to the shared widget. `InviteNudgeCard` is bilingual
/// and used on Classic and on the parenting side; rewording it means rewording
/// the `S` strings, which is a real translation change and not a copy tweak.
/// This one is English-only like the rest of V3.
class V3InviteBlock extends StatelessWidget {
  const V3InviteBlock(
      {super.key,
      required this.p,
      required this.inviterReward,
      required this.inviteeReward,
      this.onTap});

  final V2Palette p;

  /// Taken from ReferralStore rather than written here. A hard-coded reward is
  /// a promise the campaign can silently stop keeping.
  final String inviterReward;
  final String inviteeReward;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: p.line),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('INVITE A FRIEND',
              style: pvManrope(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.6,
                  color: p.ink3)),
          const SizedBox(height: 8),
          // ⚠️ WAS "Someone you know is doing this too" — a statement about
          // someone else. This asks HER a question she can answer, which is what
          // an invite actually is.
          Text('Know someone who might find this useful?',
              style: pvFraunces(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                  letterSpacing: -0.4,
                  color: p.ink1)),
          const SizedBox(height: 10),
          Text(
              'Send her a link. When she joins and finishes setting up, '
              'she gets a $inviteeReward and so do you.',
              style: pvManrope(fontSize: 13.5, height: 1.55, color: p.ink2)),
          const SizedBox(height: 14),
          // ⚠️ THE THREE BENEFIT LINES ARE OFF, KEPT FOR REVERT.
          //
          // They were: "Nothing to buy, now or later" / "She can leave any time,
          // and so can you" / "Invite as many people as you like". Each was a
          // fact a distrustful reader silently checks for, and the reasoning for
          // stating them plainly still stands — but three reassurances above a
          // single button make a small ask look like a scheme that needs
          // defending. Removed for now, per review.
          //
          // Restore by deleting the `false &&` below.
          // ignore: dead_code
          if (false) for (final line in const [
            'Nothing to buy, now or later',
            'She can leave any time, and so can you',
            'Invite as many people as you like',
          ]) ...[
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Icon(Icons.check_rounded,
                    size: 15, color: p.action.withValues(alpha: 0.8)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(line,
                    style:
                        pvManrope(fontSize: 12.5, height: 1.5, color: p.ink3)),
              ),
            ]),
            const SizedBox(height: 4),
          ],
          const SizedBox(height: 12),
          // The one violet thing on the block, because violet means "you can
          // act on this" and this is the only action on it.
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
              decoration: BoxDecoration(
                color: p.action,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text('Click here to invite',
                    style: pvManrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
                const SizedBox(width: 7),
                const Icon(Icons.arrow_forward_rounded,
                    size: 16, color: Colors.white),
              ]),
            ),
          ),
        ]),
      );
}

/// The secondary button for these cards.
///
/// ⚠️ WHY EVERY SECONDARY ACTION HERE WAS A BARE TextButton, and why that made
/// two finished sections look unfinished.
///
/// "Manage", "Remind me" and "Open your journal" were violet words with nothing
/// around them. Flutter's TextButton has no visible boundary, so what shipped
/// was three lines of coloured text that happened to be tappable — which reads
/// as a caption someone forgot to style, not as a control. The rule it breaks
/// is the one about signifiers: a thing you can press has to LOOK pressable,
/// and colour alone only works on a reader who has already learned that violet
/// means action in this app.
///
/// A 1px border and a 44px-tall body cost nothing and settle it. Quiet, not
/// loud: these are secondary to the rows above them, so they take the outline
/// treatment rather than a filled violet fill, which stays reserved for the one
/// primary action on a screen.
class _Pill extends StatelessWidget {
  const _Pill(
      {required this.label,
      required this.icon,
      required this.p,
      required this.onTap,
      this.fullWidth = false});

  final String label;
  final IconData icon;
  final V2Palette p;
  final VoidCallback? onTap;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            // ⚠️ NO FILL. It was `p.surfaceAlt`, which sounds neutral and is
            // not: the app's neutrals are LAVENDER-tinted (#F3EEF7 and family,
            // see DESIGN-LAYER §18.1), so a "grey" button fill lands as a pale
            // purple wash. On a card that already carries violet for its links
            // that reads as a third violet doing nothing in particular.
            //
            // Outline only. The border is what says "button"; the fill was
            // never carrying that job, it was just adding colour to a surface
            // that had already spent its colour budget.
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: p.line, width: 1.2),
          ),
          child: Row(
              mainAxisSize:
                  fullWidth ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16, color: p.ink2),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: pvManrope(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: p.ink1)),
                ),
              ]),
        ),
      );
}

/// A quiet outlined button. Not the violet action pill — this is an invitation
/// inside an empty card, and the violet belongs to what the page is actually
/// asking her to do.
class _Ghost extends StatelessWidget {
  const _Ghost(
      {required this.label,
      required this.color,
      required this.p,
      required this.onTap});

  final String label;
  final Color color;
  final V2Palette p;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: color.withValues(alpha: 0.45)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(label,
                style: pvManrope(
                    fontSize: 13, fontWeight: FontWeight.w700, color: color)),
            const SizedBox(width: 6),
            Icon(Icons.arrow_forward_rounded, size: 15, color: color),
          ]),
        ),
      );
}
