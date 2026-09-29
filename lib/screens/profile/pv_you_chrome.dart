// =============================================================================
//  The You screen's parts — rows, sections, tiles, the identity card
// -----------------------------------------------------------------------------
//  Built 2026-09-19 from the Mobbin profile audit (docs/PROFILE-AUDIT.md) on
//  the base-UI rule and the store's chrome: white ground, ink for the one
//  action, brand violet on eyebrows and the verified mark only.
//
//  The grammar every good profile shares (Clue, Oura, Airbnb, Zomato): an
//  identity card, then GROUPED rows under section headers, hairlines between
//  rows, chevrons, a value on the right when there is one, red only for the
//  irreversible thing at the very end. Nothing here is a filled violet button.
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart' show AppTheme;
import '../../theme/pv_fonts.dart';
import '../auth/onboarding/onboarding_chrome.dart' show ObPress;
import '../products/pv_store_chrome.dart'
    show kPvLine, pvStorePalette, PvRoundIcon;
import '../v2/v2_palette.dart';

export '../products/pv_store_chrome.dart'
    show
        kPvLine,
        pvStorePalette,
        pvToneColor,
        PvRoundIcon,
        PvWell,
        // White + hairline and one quiet line, for what PvWell's lavender
        // slab carried in profile (2026-09-29).
        PvCard,
        PvQuietLine,
        PvChip,
        PvCommit,
        PvSecondary,
        pvSnack;

/// A section: eyebrow header + a white card of rows with hairlines between.
class PvYouSection extends StatelessWidget {
  const PvYouSection({
    super.key,
    required this.title,
    required this.children,
    this.lead,
  });
  final String title;
  final List<Widget> children;

  /// One quiet line under the header (the invitation, or the honest note).
  final String? lead;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: pvManrope(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: p.action,
            ),
          ),
          if (lead != null) ...[
            const SizedBox(height: 4),
            Text(
              lead!,
              style: pvManrope(fontSize: 12.5, height: 1.4, color: p.ink3),
            ),
          ],
          const SizedBox(height: 10),
          if (children.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: kPvLine),
              ),
              child: Column(
                children: [
                  for (var i = 0; i < children.length; i++) ...[
                    if (i > 0)
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: kPvLine,
                        indent: 16,
                        endIndent: 16,
                      ),
                    children[i],
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// One row: icon well · title (· subtitle) · value · chevron. `danger` is the
/// red reserved for Delete account and nothing else.
class PvYouRow extends StatelessWidget {
  const PvYouRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.value,
    this.onTap,
    this.trailing,
    this.danger = false,
    this.badge,
    this.leading,
  });
  final IconData icon;
  final String title;
  final String? subtitle;

  /// ⚠️ ADDITIVE (2026-09-29, TTC's profile). A drawn mark in place of the
  /// line [icon] (the TTC family, `ttc_more_marks.dart`), 40 square. Null on
  /// every row that had none, which draws exactly as before.
  final Widget? leading;

  /// A fact on the right ("Week 21", "--", "Coming").
  final String? value;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool danger;

  /// A count pill after the title.
  final int? badge;

  /// This row with a drawn mark in place of its line icon (2026-09-29, the
  /// one icon rule: a row that goes somewhere leads with a mark). Settings
  /// uses it on the rows the shared builders make, so the words, values and
  /// taps stay exactly theirs.
  PvYouRow withLeading(Widget mark) => PvYouRow(
    key: key,
    icon: icon,
    title: title,
    subtitle: subtitle,
    value: value,
    onTap: onTap,
    trailing: trailing,
    danger: danger,
    badge: badge,
    leading: mark,
  );

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    final ink = danger ? const Color(0xFFC6295A) : p.ink1;
    // ⚠️ A MARKED ROW TAKES THE PROFILE ROW'S METRICS (2026-09-29): at least
    // 60 high, 14 in, so a mark sits where `PvProfileRow`'s does and the
    // hairline (indent 68) starts under the words. Only rows with a mark,
    // which are TTC's profile and Settings; every line-icon row draws as
    // before. Kept for revert: EdgeInsets.symmetric(horizontal: 16,
    // vertical: 13) for every row.
    final marked = leading != null;
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(minHeight: marked ? 60 : 0),
        padding: marked
            ? const EdgeInsets.fromLTRB(14, 10, 12, 10)
            : const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            if (leading != null)
              SizedBox(width: 40, height: 40, child: leading)
            else
              Icon(icon, size: 20, color: danger ? ink : p.ink2),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: pvManrope(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            color: ink,
                          ),
                        ),
                      ),
                      if (badge != null && badge! > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: p.surfaceAlt,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '$badge',
                            style: pvManrope(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: p.ink2,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: pvManrope(
                        fontSize: 12.5,
                        height: 1.35,
                        color: p.ink3,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (value != null) ...[
              const SizedBox(width: 10),
              // A marked row's value sits at its right edge, as on the
              // profile. Kept for revert: Flexible on every row.
              if (marked)
                Flexible(
                  fit: FlexFit.tight,
                  child: Text(
                    value!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: pvManrope(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: value == '--' ? p.ink3 : p.ink2,
                    ),
                  ),
                )
              else
              Flexible(
                child: Text(
                  value!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: pvManrope(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: value == '--' ? p.ink3 : p.ink2,
                  ),
                ),
              ),
            ],
            if (trailing != null) ...[const SizedBox(width: 8), trailing!],
            if (trailing == null && onTap != null) ...[
              const SizedBox(width: 6),
              Icon(Icons.chevron_right_rounded, size: 20, color: p.ink3),
            ],
          ],
        ),
      ),
    );
  }
}

/// A row that is a switch (WhatsApp updates, "share my week with Rohan").
class PvYouSwitchRow extends StatelessWidget {
  const PvYouSwitchRow({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.leading,
  });
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  /// A drawn mark in place of [icon] (additive, 2026-09-29; see
  /// [PvYouRow.withLeading]).
  final Widget? leading;

  PvYouSwitchRow withLeading(Widget mark) => PvYouSwitchRow(
    key: key,
    icon: icon,
    title: title,
    subtitle: subtitle,
    value: value,
    onChanged: onChanged,
    leading: mark,
  );

  @override
  Widget build(BuildContext context) => PvYouRow(
    icon: icon,
    leading: leading,
    title: title,
    subtitle: subtitle,
    onTap: () => onChanged(!value),
    trailing: Switch.adaptive(
      value: value,
      onChanged: onChanged,
      // Kept for revert (2026-09-28, one black switch app-wide): activeTrackColor: pvStorePalette.action,
    ),
  );
}

/// The three counted tiles under "Your things" (Airbnb's Past trips /
/// Connections, made three): icon well, count, label.
class PvYouTile extends StatelessWidget {
  const PvYouTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.count,
    this.hue = 268,
  });
  final IconData icon;
  final String label;
  final int? count;
  final VoidCallback onTap;
  final double hue;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    final tint = v2BlockTint(hue, p);
    final ink = HSLColor.fromAHSL(1, hue, 0.32, 0.36).toColor();
    return Expanded(
      child: ObPress(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kPvLine),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: tint,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(icon, size: 19, color: ink),
                ),
                const SizedBox(height: 10),
                Text(
                  count == null ? label : '$count',
                  style: pvFraunces(
                    fontSize: count == null ? 15 : 20,
                    fontWeight: FontWeight.w500,
                    height: 1.1,
                    color: p.ink1,
                  ),
                ),
                if (count != null)
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: pvManrope(fontSize: 12, color: p.ink3),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// An avatar: initial in a hue well, with the verified tick when asked.
class PvAvatar extends StatelessWidget {
  const PvAvatar({
    super.key,
    required this.name,
    this.size = 64,
    this.verified = false,
    this.hue = 268,
    this.child = false,
  });
  final String name;
  final double size;
  final bool verified;
  final double hue;

  /// A child's avatar takes a rounded square (Netflix's profile tiles), an
  /// adult's a circle — so the two read as different kinds at a glance.
  final bool child;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    final tint = v2BlockTint(hue, p);
    final ink = HSLColor.fromAHSL(1, hue, 0.32, 0.36).toColor();
    final initial = name.trim().isEmpty
        ? '?'
        : name.trim().characters.first.toUpperCase();
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: tint,
            shape: child ? BoxShape.rectangle : BoxShape.circle,
            borderRadius: child ? BorderRadius.circular(size * 0.28) : null,
          ),
          child: Text(
            initial,
            style: pvFraunces(
              fontSize: size * 0.42,
              fontWeight: FontWeight.w500,
              color: ink,
            ),
          ),
        ),
        if (verified)
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: size * 0.34,
              height: size * 0.34,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.verified_rounded,
                size: size * 0.3,
                color: p.action,
              ),
            ),
          ),
      ],
    );
  }
}

/// The identity card: avatar · name · one meta line · the stage clock · Edit.
class PvIdentityCard extends StatelessWidget {
  const PvIdentityCard({
    super.key,
    required this.name,
    required this.meta,
    required this.clock,
    this.verified = false,
    this.onEdit,
    this.chip,
    this.hue = 268,
  });
  final String name;
  final String meta;
  final String clock;
  final bool verified;
  final VoidCallback? onEdit;

  /// A quiet chip (sponsor / employer), never a black band.
  final String? chip;
  final double hue;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kPvLine),
        ),
        child: Row(
          children: [
            PvAvatar(name: name, size: 64, verified: verified, hue: hue),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: pvFraunces(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      height: 1.1,
                      color: p.ink1,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    meta,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: pvManrope(fontSize: 12.5, color: p.ink3),
                  ),
                  const SizedBox(height: 6),
                  // ⚠️ A WRAP, NOT A ROW (2026-09-28, the More bento's 360dp
                  // and 1.5x text test). The trying clock ("Trying · 6 to 12
                  // months · cycles regular") ran past the card at large text.
                  // Where the pills fit, a Wrap lays them out exactly as the
                  // Row did; where they do not, the second goes under the
                  // first and a long pill wraps its words. Kept for revert:
                  //   Row(children: [...])
                  Wrap(
                    spacing: 0,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (clock.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: p.surfaceAlt,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            clock,
                            style: pvManrope(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: p.ink1,
                            ),
                          ),
                        ),
                      if (chip != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: kPvLine),
                          ),
                          child: Text(
                            chip!,
                            style: pvManrope(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: p.ink2,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (onEdit != null)
              InkWell(
                onTap: onEdit,
                borderRadius: BorderRadius.circular(999),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  // Kept for revert (2026-09-28): 'Edit'. It opens the name
                  // sheet on every stage, so it says so.
                  child: Text(
                    'Edit name',
                    style: pvManrope(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: p.action,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A person card in the Family section — the partner, or her.
class PvPersonCard extends StatelessWidget {
  const PvPersonCard({
    super.key,
    required this.name,
    required this.role,
    required this.line,
    required this.onTap,
    this.verified = false,
    this.hue = 268,
    this.action,
  });
  final String name;
  final String role;
  final String line;
  final VoidCallback onTap;
  final bool verified;
  final double hue;

  /// A short action word on the right ("Invite"), else a chevron.
  final String? action;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            PvAvatar(name: name, size: 42, verified: verified, hue: hue),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Flexible, so a long name ellipsises instead of
                      // overflowing the card (seen at phone width,
                      // 2026-09-26). Unchanged whenever the name fits.
                      Flexible(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: pvManrope(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: p.ink1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(role, style: pvManrope(fontSize: 12, color: p.ink3)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    line,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: pvManrope(
                      fontSize: 12.5,
                      height: 1.35,
                      color: p.ink2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (action != null)
              Text(
                action!,
                style: pvManrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: p.action,
                ),
              )
            else
              Icon(Icons.chevron_right_rounded, size: 20, color: p.ink3),
          ],
        ),
      ),
    );
  }
}

/// The child chips (Netflix's profile row, Zocdoc's person chip): the active
/// child in ink, the others quiet, "+ Add a child" always last.
class PvChildChips extends StatelessWidget {
  const PvChildChips({
    super.key,
    required this.children,
    required this.activeId,
    required this.onOpen,
    required this.onAdd,
  });
  final List<({String id, String name, String age})> children;
  final String? activeId;
  final void Function(String id) onOpen;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final c in children) ...[
              ObPress(
                child: InkWell(
                  onTap: () => onOpen(c.id),
                  borderRadius: BorderRadius.circular(14),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: c.id == activeId
                                ? p.ink1
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        padding: const EdgeInsets.all(2),
                        child: PvAvatar(
                          name: c.name,
                          size: 52,
                          hue: 26,
                          child: true,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        c.name,
                        style: pvManrope(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: p.ink1,
                        ),
                      ),
                      Text(
                        c.age,
                        style: pvManrope(fontSize: 11, color: p.ink3),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
            ],
            InkWell(
              onTap: onAdd,
              borderRadius: BorderRadius.circular(14),
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: p.ink1.withValues(alpha: 0.25),
                        width: 1.4,
                      ),
                    ),
                    child: Icon(Icons.add_rounded, size: 24, color: p.ink2),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Add a child',
                    style: pvManrope(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: p.ink2,
                    ),
                  ),
                  Text(' ', style: pvManrope(fontSize: 11, color: p.ink3)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A pushed page's top bar: back · title.
class PvYouTopBar extends StatelessWidget {
  const PvYouTopBar({
    super.key,
    required this.title,
    this.eyebrow,
    this.trailing,
  });
  final String title;
  final String? eyebrow;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 10,
        16,
        6,
      ),
      child: Row(
        children: [
          PvRoundIcon(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (eyebrow != null)
                  Text(
                    eyebrow!.toUpperCase(),
                    style: pvManrope(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                      color: p.action,
                    ),
                  ),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: pvFraunces(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: p.ink1,
                  ),
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

// =============================================================================
//  THE PROFILE, V3 (2026-09-29, TTC first): a hero, a glance, clean groups
// -----------------------------------------------------------------------------
//  The user, on build 19: the profile looked "very random", its top "does not
//  make any sense", and "spacing, margins, a lot of things are not right".
//  What the profiles on Mobbin share, and what these parts take from them:
//
//   * A HERO, not a card in a list. Headspace's profile is a coloured band
//     with the avatar sitting on its edge, the name large and one line under
//     it; Airbnb's centres a large photo and the name, with one quiet line.
//     https://mobbin.com/screens/bb0004ec-e553-4e4d-a10e-1e21e59c8781
//     https://mobbin.com/screens/8f7c5b27-db62-48f9-a403-7b8bdba1253b
//     Revolut's centres the photo and the name, then its rows.
//     https://mobbin.com/screens/8b0c7aa9-1dd5-45e5-92c4-35dc1ffb5559
//   * A GLANCE of two or three facts that are hers (Lifesum's card: current
//     weight, goal; MyFitnessPal's streak and progress either side of the
//     avatar; Headspace's Stats). Facts, never a score.
//     https://mobbin.com/screens/22927521-ebbb-4b49-a592-a2c315380cbf
//     https://mobbin.com/screens/8733b29b-955e-442d-8c7d-a89192f44f53
//   * GROUPS under a small grey capitalised heading, rows in one white group
//     with hairlines, an object's mark leading each row (Lifesum's
//     CUSTOMIZATION, Flo's FLO PREMIUM SETTINGS, Visible's grouped rows).
//     https://mobbin.com/screens/d0094f89-7c43-4a15-b814-4ad76c770527
//     https://mobbin.com/screens/a92f1da1-9411-493b-9a37-59ce57b56821
//   * FACTS AS VALUES ON THE RIGHT, read-only, with one way to change them
//     (Apple Health's Health Details, MyFitnessPal's Personal Details).
//     https://mobbin.com/screens/62991cea-fe42-41ec-b441-754a961c87cc
//     https://mobbin.com/screens/aff3eacb-9930-4c47-bf57-90e212e66a8c
//
//  WHAT WAS NOT TAKEN: Headspace's and Calm's saturated grounds (our band is
//  one soft tint), Flo's toggles on the profile (settings live in Settings),
//  and any stage stepper: no profile on Mobbin draws the life stages as a
//  track. Clue names the mode in one pill; we name it in one status line.
//  https://mobbin.com/screens/bfcc746e-14c3-4d9b-9961-360dedbafc66
//
//  THE SPACING, fixed in numbers so it cannot drift per row: gutter 18
//  (TTC's `ttcGutter`), 28 above a heading, 10 under it, rows at least 60
//  high with a 40pt mark (the door rails' size), hairlines that start under
//  the words, not under the mark. One colour for headings: ink, never violet.
// =============================================================================

/// The profile's page gutter: TTC's `ttcGutter`, restated here so the shared
/// chrome does not import a stage's file.
const double kPvProfileGutter = 18;

/// Space above a group's heading.
const double kPvProfileGroupGap = 28;

/// A group on the profile: a small grey heading (optional), then its rows in
/// one white group with hairlines. No violet: the heading is ink.
class PvProfileGroup extends StatelessWidget {
  const PvProfileGroup({
    super.key,
    this.title,
    required this.children,
    this.lead,
    this.footer,
  });

  /// Drawn in capitals, small and grey. Null draws no heading (the lone
  /// Settings row, Airbnb's "Account settings" under the profile).
  final String? title;
  final List<Widget> children;

  /// One quiet line under the heading.
  final String? lead;

  /// Something drawn under the group, outside it (the care partner's card).
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        kPvProfileGutter,
        kPvProfileGroupGap,
        kPvProfileGutter,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Semantics(
                header: true,
                child: Text(
                  title!.toUpperCase(),
                  style: pvManrope(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: p.ink2,
                  ),
                ),
              ),
            ),
            if (lead != null) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  lead!,
                  style: pvManrope(fontSize: 12.5, height: 1.4, color: p.ink3),
                ),
              ),
            ],
            const SizedBox(height: 10),
          ],
          if (children.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: kPvLine),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  for (var i = 0; i < children.length; i++) ...[
                    if (i > 0)
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: kPvLine,
                        // Under the words, not under the mark: 14 + 40 + 14.
                        indent: 68,
                      ),
                    children[i],
                  ],
                ],
              ),
            ),
          ?footer,
        ],
      ),
    );
  }
}

/// A profile row: a drawn mark, a title (and one grey line), a value, a
/// chevron. At least 60 high; a line makes it taller, never tighter. A row
/// with no [onTap] is a fact and draws no chevron.
class PvProfileRow extends StatelessWidget {
  const PvProfileRow({
    super.key,
    required this.mark,
    required this.title,
    this.subtitle,
    this.value,
    this.onTap,
    this.trailing,
    this.badge,
  });

  /// The drawn mark, 40 square (the TTC family: `TtcTabArt`, the tool marks,
  /// `TtcMoreArt`).
  final Widget mark;
  final String title;
  final String? subtitle;

  /// A fact on the right ("6 to 12 months", "--").
  final String? value;
  final VoidCallback? onTap;

  /// Drawn in place of the chevron (an Invite pill).
  final Widget? trailing;

  /// A count after the title, quiet.
  final int? badge;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    // At large text a line may take a third row rather than cut off.
    final lines = MediaQuery.textScalerOf(context).scale(10) > 13 ? 3 : 2;
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 60),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 12, 10),
          child: Row(
            children: [
              ExcludeSemantics(
                child: SizedBox(width: 40, height: 40, child: mark),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: pvManrope(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              height: 1.25,
                              color: p.ink1,
                            ),
                          ),
                        ),
                        if (badge != null && badge! > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: p.surfaceAlt,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '$badge',
                              style: pvManrope(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: p.ink2,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        maxLines: lines,
                        overflow: TextOverflow.ellipsis,
                        style: pvManrope(
                          fontSize: 12.5,
                          height: 1.35,
                          color: p.ink3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (value != null) ...[
                const SizedBox(width: 10),
                // Expanded, not Flexible: the value sits at the row's right
                // edge (Apple Health's Health Details), not after the title.
                Expanded(
                  flex: 2,
                  child: Text(
                    value!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: pvManrope(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                      color: value == '--' ? p.ink3 : p.ink2,
                    ),
                  ),
                ),
              ],
              if (trailing != null) ...[const SizedBox(width: 8), trailing!],
              if (trailing == null && onTap != null) ...[
                const SizedBox(width: 6),
                Icon(Icons.chevron_right_rounded, size: 20, color: p.ink3),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A small outlined ink pill: the hero's Edit, a row's Invite. Never violet.
class PvProfilePill extends StatelessWidget {
  const PvProfilePill({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
  });
  final String label;
  final IconData? icon;

  /// Null draws the pill as a label inside a tappable row (the row's tap).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // Buttons take the switch black (the lead, 2026-09-29), not ink1.
    const ink = AppTheme.neutral900;
    final pill = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: ink.withValues(alpha: 0.24), width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: ink),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: pvManrope(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: ink,
              ),
            ),
          ),
        ],
      ),
    );
    if (onTap == null) return pill;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: pill,
    );
  }
}

/// The profile's hero: a soft tinted band with the back button and the
/// page's title, a large avatar sitting on the band's edge, the name in the
/// serif, ONE status line, the partner line, and Edit as a small pill.
class PvProfileHero extends StatelessWidget {
  const PvProfileHero({
    super.key,
    required this.name,
    required this.status,
    required this.partnerLine,
    required this.bandTint,
    this.title = 'Profile',
    this.hasName = true,
    this.partnerMark,
    this.onEdit,
    this.editLabel = 'Edit name',
    this.showBack = true,
    this.verified = false,
  });

  final String name;

  /// False when [name] is the placeholder: the avatar draws a person, not
  /// the placeholder's first letter.
  final bool hasName;
  final String status;
  final String partnerLine;

  /// A small drawn mark before [partnerLine], or null.
  final Widget? partnerMark;
  final Color bandTint;
  final String title;
  final VoidCallback? onEdit;
  final String editLabel;

  /// False on a tab root, which has nowhere to go back to.
  final bool showBack;
  final bool verified;

  static const double _avatar = 96;
  static const double _ring = 4;
  static const double _barH = 40;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    final top = MediaQuery.of(context).padding.top;
    // The band ends at the avatar's middle: the bar, the gap, half the
    // ringed avatar.
    final bandH = top + 10 + _barH + 22 + (_avatar / 2 + _ring);
    final initial = name.trim().isEmpty
        ? ''
        : name.trim().characters.first.toUpperCase();
    return Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          height: bandH,
          child: DecoratedBox(
            key: const ValueKey('pv_profile_band'),
            decoration: BoxDecoration(
              color: bandTint,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(28),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            kPvProfileGutter,
            top + 10,
            kPvProfileGutter,
            0,
          ),
          child: Column(
            children: [
              SizedBox(
                height: _barH,
                child: Row(
                  children: [
                    if (showBack) ...[
                      PvRoundIcon(
                        icon: Icons.arrow_back_rounded,
                        semanticLabel: 'Back',
                        onTap: () => Navigator.of(context).maybePop(),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        // The bar is a fixed 40: the title keeps to it.
                        textScaler: TextScaler.noScaling,
                        // 24, the size Settings' bar uses (PvYouTopBar).
                        style: pvFraunces(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          color: p.ink1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    key: const ValueKey('pv_profile_avatar'),
                    width: _avatar + _ring * 2,
                    height: _avatar + _ring * 2,
                    padding: const EdgeInsets.all(_ring),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: p.ground,
                        shape: BoxShape.circle,
                        border: Border.all(color: kPvLine),
                      ),
                      child: hasName && initial.isNotEmpty
                          ? Text(
                              initial,
                              // The monogram is a picture of a letter: it
                              // keeps its size at large text.
                              textScaler: TextScaler.noScaling,
                              style: pvFraunces(
                                fontSize: 42,
                                fontWeight: FontWeight.w500,
                                color: p.ink1,
                              ),
                            )
                          : Icon(
                              Icons.person_outline_rounded,
                              size: 44,
                              color: p.ink2,
                            ),
                    ),
                  ),
                  if (verified)
                    Positioned(
                      right: 2,
                      bottom: 2,
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.verified_rounded,
                          size: 22,
                          color: p.ink1,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                name,
                key: const ValueKey('pv_profile_name'),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: pvFraunces(
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                  height: 1.15,
                  color: p.ink1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                status,
                key: const ValueKey('pv_profile_status'),
                textAlign: TextAlign.center,
                style: pvManrope(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                  color: p.ink2,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                key: const ValueKey('pv_profile_partner'),
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (partnerMark != null) ...[
                    ExcludeSemantics(
                      child: SizedBox(width: 22, height: 22, child: partnerMark),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      partnerLine,
                      textAlign: TextAlign.center,
                      style: pvManrope(
                        fontSize: 13,
                        height: 1.35,
                        color: p.ink3,
                      ),
                    ),
                  ),
                ],
              ),
              if (onEdit != null) ...[
                const SizedBox(height: 16),
                PvProfilePill(
                  key: const ValueKey('pv_profile_edit'),
                  label: editLabel,
                  icon: Icons.edit_outlined,
                  onTap: onEdit,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Two or three facts that are hers, side by side in one white group
/// (Lifesum's card, Headspace's Stats). Facts only: never a score, never a
/// chance.
class PvProfileGlance extends StatelessWidget {
  const PvProfileGlance({
    super.key,
    required this.facts,
    this.note,
    this.top = 24,
  });

  /// (value, label). A value of `--` is drawn grey.
  final List<(String, String)> facts;

  /// One grey line under the facts (what unlocks a `--`), or null.
  final String? note;

  /// Space above the card: 24 under the hero, less under the orders and
  /// bookings tiles, which already set the page apart from the hero.
  final double top;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        kPvProfileGutter,
        top,
        kPvProfileGutter,
        0,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: kPvLine),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < facts.length; i++) ...[
                    if (i > 0)
                      const VerticalDivider(
                        width: 1,
                        thickness: 1,
                        color: kPvLine,
                        indent: 14,
                        endIndent: 14,
                      ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 10, 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                facts[i].$1,
                                maxLines: 1,
                                style: pvFraunces(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w500,
                                  height: 1.1,
                                  color: facts[i].$1 == '--' ? p.ink3 : p.ink1,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              facts[i].$2,
                              style: pvManrope(
                                fontSize: 12,
                                height: 1.3,
                                color: p.ink3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (note != null) ...[
              const Divider(height: 1, thickness: 1, color: kPvLine),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 14, 12),
                child: Text(
                  note!,
                  style: pvManrope(fontSize: 12.5, height: 1.4, color: p.ink3),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// =============================================================================
//  WHAT SHE BOUGHT AND WHAT SHE BOOKED, as two tiles under the hero
//  (2026-09-29, the lead with the user)
// -----------------------------------------------------------------------------
//  The rule: things she HAS bought or booked live on her profile; things she
//  COULD buy or book live on More and the store. From Mobbin:
//
//   * Ro's profile opens with two white tiles under the name, Orders beside
//     Membership, each a small drawn object over its label.
//     https://mobbin.com/screens/2f69a9eb-9760-4183-abe2-4da5660c87e9
//   * Etsy's You: Purchases as a tile with its count ("1 order") under the
//     name, before any settings row.
//     https://mobbin.com/screens/4db4fc7d-e20e-4ed9-a1d9-bde521dfe04f
//   * Instacart's account puts Orders first in the top row of tiles.
//     https://mobbin.com/screens/3450e221-7ee0-478b-bb4a-77ffb4442a4d
//
//  WHAT WAS NOT TAKEN: Ro's shipping address as a profile row (ours sits in
//  Settings, Account, as Deliveroo and Ro's own "Personal information" keep
//  it: an address is account detail, not something she bought), Etsy's order
//  photo carousel (one line of state is enough), and a third tile (two is
//  the whole rule).
// =============================================================================

/// One tile: a drawn mark, a title, and one line of state ("1 on the way",
/// "Next: Thu 2 Oct", "None yet"). The whole tile is the tap.
class PvProfileTile extends StatelessWidget {
  const PvProfileTile({
    super.key,
    required this.mark,
    required this.title,
    required this.line,
    required this.onTap,
  });

  /// The drawn mark, 40 square, in the profile's one tint.
  final Widget mark;
  final String title;
  final String line;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return Semantics(
      button: true,
      container: true,
      label: '$title. $line',
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: kPvLine),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: 40, height: 40, child: mark),
                const SizedBox(height: 12),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: pvManrope(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                    color: p.ink1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  line,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  // ink2, not ink3: the line is the tile's news, and grey on
                  // white must stay readable (the contrast rule, 2026-09-29).
                  style: pvManrope(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                    color: p.ink2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Two [PvProfileTile]s side by side, equal width and equal height, on the
/// profile's gutter.
class PvProfileTiles extends StatelessWidget {
  const PvProfileTiles({super.key, required this.tiles, this.top = 24});
  final List<Widget> tiles;
  final double top;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(kPvProfileGutter, top, kPvProfileGutter, 0),
    child: IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < tiles.length; i++) ...[
            if (i > 0) const SizedBox(width: 12),
            Expanded(child: tiles[i]),
          ],
        ],
      ),
    ),
  );
}
