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
  });
  final IconData icon;
  final String title;
  final String? subtitle;

  /// A fact on the right ("Week 21", "--", "Coming").
  final String? value;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool danger;

  /// A count pill after the title.
  final int? badge;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    final ink = danger ? const Color(0xFFC6295A) : p.ink1;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
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
  });
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => PvYouRow(
    icon: icon,
    title: title,
    subtitle: subtitle,
    onTap: () => onChanged(!value),
    trailing: Switch.adaptive(
      value: value,
      onChanged: onChanged,
      activeTrackColor: pvStorePalette.action,
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
                  Row(
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
                  child: Text(
                    'Edit',
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
