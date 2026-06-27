// =============================================================================
//  ParentVeda Community (Tools tab) — prototype
// -----------------------------------------------------------------------------
//  A personalized parenting social layer over seeded data: a stories-style row
//  of joined communities, recommended communities, a Community Pulse strip, and
//  one algorithmic feed. Tapping a post opens a YouTube-style detail with
//  comments + related discussions + suggested communities (retention loops).
//  Pregnancy-adapted; no gender communities.
// =============================================================================

// import 'dart:async'; // only Timer (Community Pulse) used it — Pulse removed
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';

import '../data/community_data.dart';
import '../localization/app_language.dart';
import '../models/community_models.dart';
import '../services/community_store.dart';
import '../services/expert_follow_store.dart';
import '../services/pregnancy_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/mic_dictation_button.dart';
import 'community_profile_screen.dart';

const Color _accent = AppTheme.primary500;
const Color _like = AppTheme.secondary500;

/// `endFloat`, lifted up by [lift] logical px — used to clear the floating
/// bottom nav pill that MainScaffold paints over the Community screen. Measuring
/// from the standard (safe-area-aware) endFloat base keeps it correct on every
/// device, unlike a fixed Padding lift.
class _EndFloatLifted extends StandardFabLocation
    with FabEndOffsetX, FabFloatOffsetY {
  const _EndFloatLifted(this.lift);
  final double lift;
  @override
  double getOffsetY(
          ScaffoldPrelayoutGeometry scaffoldGeometry, double adjustment) =>
      super.getOffsetY(scaffoldGeometry, adjustment) - lift;
}

// Warm tints from the old story-circle row — kept for reference; the Community
// Pro layout uses gradient mono badges (_commGradients) instead.
// const List<Color> _storyTints = [
//   AppTheme.secondary100,
//   AppTheme.surfaceContainerHigh,
//   Color(0xFFEAF1EA),
//   Color(0xFFF1E8DA),
// ];

void _push(BuildContext c, Widget w) =>
    Navigator.of(c).push(MaterialPageRoute(builder: (_) => w));

// --- Community Pro palette (purple/pink trust language) --------------------
const Color _proInk = Color(0xFF2C1A45);
const Color _proPurple = Color(0xFF7C3AED);
const Color _proPurpleDeep = Color(0xFF6D28D9);
const Color _proPink = Color(0xFFD6478A);

/// Soft top-to-bottom wash that sits behind the whole tab (matches the design).
const LinearGradient _proBackdrop = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xFFFBEAF2), Color(0xFFF4EAF8), Color(0xFFEFE4F7), Color(0xFFE9E2F6)],
);

/// Gradient cycled across the mono community badges.
const List<List<Color>> _commGradients = [
  [Color(0xFF7C3AED), Color(0xFFA855F7)],
  [Color(0xFFEC4899), Color(0xFFF472B6)],
  [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
  [Color(0xFFA855F7), Color(0xFF7C3AED)],
  [Color(0xFFD6478A), Color(0xFFF472B6)],
];

/// A two-letter monogram from a community name, skipping leading numbers
/// ("November 2026 Moms" → "NM", "Delhi Moms" → "DM").
String _mono(String name) {
  final words = name
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty && !RegExp(r'^[0-9]').hasMatch(w))
      .toList();
  if (words.isEmpty) return name.isNotEmpty ? name[0].toUpperCase() : '?';
  if (words.length == 1) {
    final w = words.first;
    return (w.length >= 2 ? w.substring(0, 2) : w).toUpperCase();
  }
  return (words[0][0] + words[1][0]).toUpperCase();
}

/// Avatar that visibly differentiates a verified expert (gradient + seal) from a
/// member (soft tinted disc). This is the core of the trust language.
Widget _authorAvatar(CommunityPost post, {double size = 46}) {
  final isExpert = post.cred.isNotEmpty || post.type == PostType.expert;
  final initial = post.author.isNotEmpty ? post.author[0].toUpperCase() : '?';
  if (isExpert) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(clipBehavior: Clip.none, children: [
        Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_proPurple, Color(0xFFA855F7)],
            ),
          ),
          child: Text(initial,
              style: GoogleFonts.fraunces(
                  fontSize: size * 0.4,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
        ),
        Positioned(
          right: -2,
          bottom: -2,
          child: Container(
            padding: const EdgeInsets.all(1.5),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Icon(Icons.verified_rounded, size: 15, color: _proPurple),
          ),
        ),
      ]),
    );
  }
  final c = _typeVisual(post.type).color;
  return Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(color: c.withValues(alpha: 0.14), shape: BoxShape.circle),
    child: Text(initial,
        style: GoogleFonts.fraunces(
            fontSize: size * 0.4, fontWeight: FontWeight.w600, color: c)),
  );
}

// --- Twitter-style helpers --------------------------------------------------
/// A handle from an author name ("Dr. Meera" → "meera", "ParentVeda" → "parentveda").
String _handle(String author) {
  var h = author.toLowerCase().replaceAll('dr.', '').replaceAll('dr ', '');
  h = h.replaceAll(RegExp(r'[^a-z0-9]'), '');
  return h.isEmpty ? 'member' : h;
}

/// Stable pseudo "time ago" for seed posts (user posts read as "now").
String _timeAgo(CommunityPost post) {
  if (post.isUser) return 'now';
  final h = post.id.hashCode.abs() % 47;
  if (h == 0) return 'now';
  if (h < 24) return '${h}h';
  return '${(h / 24).ceil()}d';
}

/// Cosmetic "views" count (Twitter shows views) derived from engagement.
String _viewsLabel(CommunityPost post) {
  final v = post.likes * 247 + post.comments * 90 + 503;
  if (v >= 1000) {
    return '${(v / 1000).toStringAsFixed(v >= 100000 ? 0 : 1)}K';
  }
  return '$v';
}

bool _isExpertAuthor(CommunityPost post) =>
    post.cred.isNotEmpty || post.type == PostType.expert;

void _toast(BuildContext c, String m) {
  ScaffoldMessenger.of(c)
    ..clearSnackBars()
    ..showSnackBar(SnackBar(
        content: Text(m), duration: const Duration(milliseconds: 1300)));
}

/// One engagement action (icon + optional count), Twitter-style.
class _EngageButton extends StatelessWidget {
  const _EngageButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 18, color: color),
          if (label.isNotEmpty) ...[
            const SizedBox(width: 5),
            Text(label,
                style: GoogleFonts.manrope(
                    fontSize: 12.5, color: color, fontWeight: FontWeight.w600)),
          ],
        ]),
      ),
    );
  }
}

/// The ⋯ menu on a post (Follow expert / Not interested / Mute / Block / Report).
void _showPostMenu(BuildContext context, S s, CommunityPost post) {
  final ef = ExpertFollowStore.instance;
  final store = CommunityStore.instance;
  final expert = _isExpertAuthor(post);
  final handle = '@${_handle(post.author)}';
  void done(String m) {
    Navigator.of(context).pop();
    _toast(context, m);
  }

  showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppTheme.surface,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
    builder: (ctx) => SafeArea(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(height: 8),
        Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: AppTheme.outlineVariant,
                borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 6),
        if (expert)
          AnimatedBuilder(
            animation: ef,
            builder: (_, _) {
              final following = ef.isFollowing(post.author);
              return ListTile(
                leading: Icon(
                    following
                        ? Icons.person_remove_alt_1_outlined
                        : Icons.person_add_alt_1_outlined,
                    color: _proPurple),
                title: Text('${following ? s.cmUnfollow : s.cmFollow} $handle',
                    style:
                        GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
                onTap: () {
                  ef.toggleFollow(post.author);
                  done(following ? s.cmUnfollowedToast : s.cmFollowedToast);
                },
              );
            },
          ),
        ListTile(
            leading: const Icon(Icons.do_not_disturb_on_outlined),
            title: Text(s.cmNotInterested),
            onTap: () {
              store.hidePost(post.id);
              done(s.cmNotInterestedDone);
            }),
        ListTile(
            leading: const Icon(Icons.volume_off_outlined),
            title: Text('${s.cmMuteUser} $handle'),
            onTap: () => done(s.cmMutedToast)),
        ListTile(
            leading: const Icon(Icons.block_outlined),
            title: Text('${s.cmBlock} $handle'),
            onTap: () => done(s.cmBlockedToast)),
        ListTile(
            leading: const Icon(Icons.flag_outlined, color: _like),
            title: Text(s.cmReport, style: const TextStyle(color: _like)),
            onTap: () => done(s.cmReportedToast)),
        const SizedBox(height: 8),
      ]),
    ),
  );
}

/// A small purple-gradient seal avatar (verified-expert language).
Widget _sealAvatar(String name, {double size = 32}) {
  final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
  return SizedBox(
    width: size,
    height: size,
    child: Stack(clipBehavior: Clip.none, children: [
      Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [_proPurple, Color(0xFFA855F7)]),
            shape: BoxShape.circle),
        child: Text(initial,
            style: GoogleFonts.fraunces(
                fontSize: size * 0.44,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
      ),
      Positioned(
        right: -2,
        bottom: -2,
        child: Container(
          padding: const EdgeInsets.all(1),
          decoration:
              const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: Icon(Icons.verified_rounded, size: size * 0.4, color: _proPurple),
        ),
      ),
    ]),
  );
}

/// Bottom sheet: the verified experts who've backed a post (builds trust).
void _showExpertsSheet(BuildContext context, S s, int total) {
  final shown = kCommunityExperts;
  final more = (total - shown.length).clamp(0, total);
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppTheme.surface,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) {
      final text = Theme.of(ctx).textTheme;
      return SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 10),
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: AppTheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
            child: Row(children: [
              const Icon(Icons.verified_rounded, size: 20, color: _proPurpleDeep),
              const SizedBox(width: 8),
              Expanded(
                child: Text('${s.cmExpertsWhoVerified} · $total',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _proInk)),
              ),
            ]),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.only(bottom: 8),
              children: [
                for (final e in shown)
                  ListTile(
                    leading: _sealAvatar(e.name, size: 38),
                    title: Text(e.name,
                        style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700, fontSize: 14)),
                    subtitle: Text('${e.cred} · ${e.specialty}',
                        style: GoogleFonts.manrope(
                            fontSize: 12, color: AppTheme.neutral500)),
                  ),
                if (more > 0)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 6, 20, 8),
                    child: Text(s.cmAndMoreExperts(more),
                        style: text.bodySmall?.copyWith(
                            color: AppTheme.neutral500,
                            fontWeight: FontWeight.w600)),
                  ),
              ],
            ),
          ),
        ]),
      );
    },
  );
}

/// The gradient endorsement strip shown atop a post a verified expert (or the
/// test doctor) has publicly backed — with a Facebook-style "+ N other experts"
/// credibility line that opens the "who verified" sheet.
///
/// REPLACED by the subtle [_verifiedHint] (the full-width purple bar read like a
/// heading). Kept for an easy revert.
// ignore: unused_element
Widget _endorsementBanner(BuildContext context, S s, CommunityPost post) {
  final store = CommunityStore.instance;
  final text = Theme.of(context).textTheme;
  final byDoctorOnly = post.endorsedBy.isEmpty; // only the test doctor backs it
  final name = byDoctorOnly ? kTestDoctorName : post.endorsedBy;
  final cred = byDoctorOnly ? kTestDoctorCred : post.endorsedByCred;
  // "Other experts" beyond the headline (seed count + the test doctor).
  final others = byDoctorOnly ? 0 : store.endorseCount(post);
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(14, 10, 12, 10),
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [_proPurpleDeep, Color(0xFF9333EA)],
      ),
    ),
    child: Row(children: [
      _sealAvatar(name),
      const SizedBox(width: 10),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            cred.isEmpty ? name : '$name · $cred',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: text.labelMedium
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 1),
          if (others > 0)
            GestureDetector(
              onTap: () => _showExpertsSheet(context, s, others),
              behavior: HitTestBehavior.opaque,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(s.cmPlusExperts(others),
                    style: text.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.white70)),
                const Icon(Icons.chevron_right_rounded,
                    size: 15, color: Colors.white),
              ]),
            )
          else
            Text(s.cmEndorsed,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: text.labelSmall
                    ?.copyWith(color: Colors.white.withValues(alpha: 0.92))),
        ]),
      ),
      const SizedBox(width: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.20),
            borderRadius: BorderRadius.circular(20)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Text('💜', style: TextStyle(fontSize: 11)),
          const SizedBox(width: 4),
          Text(s.cmExpertLiked,
              style: text.labelSmall
                  ?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
        ]),
      ),
    ]),
  );
}

/// A small, subtle "verified by an expert" line for an endorsed post — replaces
/// the old full-width purple banner (which read like a heading). Tapping it (when
/// other experts also backed the post) opens the "who verified" sheet.
Widget _verifiedHint(BuildContext context, S s, CommunityPost post) {
  final store = CommunityStore.instance;
  final byDoctorOnly = post.endorsedBy.isEmpty; // only the test doctor backs it
  final name = byDoctorOnly ? kTestDoctorName : post.endorsedBy;
  final others = byDoctorOnly ? 0 : store.endorseCount(post);
  final tappable = others > 0;
  return GestureDetector(
    onTap: tappable ? () => _showExpertsSheet(context, s, others) : null,
    behavior: HitTestBehavior.opaque,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: _proPurple.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.verified_rounded, size: 13, color: _proPurple),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            tappable ? s.cmVerifiedByPlus(name, others) : s.cmVerifiedBy(name),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.manrope(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: _proPurpleDeep),
          ),
        ),
        if (tappable)
          const Icon(Icons.chevron_right_rounded, size: 14, color: _proPurple),
      ]),
    ),
  );
}

/// The verification-requested tag. For a MEMBER it shows "Awaiting [specialty]
/// verification"; for a DOCTOR it shows "Comment to verify this post" (the new
/// way a post becomes expert-verified — by a doctor commenting on it).
Widget _pendingVerifyTag(S s, CommunityPost post, {bool doctor = false}) {
  final spKey = post.preferredSpecialty;
  final sp = (spKey.isEmpty || spKey == 'all') ? null : s.cmSpecialty(spKey);
  final label = doctor
      ? s.cmCommentToVerify
      : (sp == null ? s.cmPendingVerify : s.cmAwaitingSpecialty(sp));
  final icon =
      doctor ? Icons.rate_review_outlined : Icons.hourglass_bottom_rounded;
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: _proPurple.withValues(alpha: doctor ? 0.08 : 0.05),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: _proPurple.withValues(alpha: 0.22)),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 12, color: _proPurple),
      const SizedBox(width: 5),
      Text(label,
          style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _proPurpleDeep)),
    ]),
  );
}

/// Share a post via the OS share sheet (share_plus — house style).
void _sharePost(S s, CommunityPost post) {
  final body = '"${post.text}"\n\n— ${post.author} · ${s.cmShareVia}';
  Share.share(body);
}

({IconData icon, Color color, String key}) _typeVisual(PostType t) {
  switch (t) {
    case PostType.question:
      return (icon: Icons.help_outline_rounded, color: _accent, key: 'question');
    case PostType.experience:
      return (icon: Icons.favorite_border_rounded, color: _like, key: 'experience');
    case PostType.poll:
      return (icon: Icons.bar_chart_rounded, color: const Color(0xFF18A39B), key: 'poll');
    case PostType.photo:
      return (icon: Icons.photo_camera_outlined, color: const Color(0xFF3B82C4), key: 'photo');
    case PostType.milestone:
      return (icon: Icons.celebration_outlined, color: const Color(0xFFE6A817), key: 'milestone');
    case PostType.expert:
      return (icon: Icons.verified_rounded, color: const Color(0xFF7A4FC2), key: 'expert');
    case PostType.parentVeda:
      return (icon: Icons.auto_awesome_rounded, color: _accent, key: 'parentVeda');
  }
}

/// Per-type identity for the Community Pulse cards (icon + accent colour) so the
/// strip reads as distinct, premium cards rather than one flat tile.
({IconData icon, Color color}) _pulseVisual(PulseType t) {
  switch (t) {
    case PulseType.poll:
      return (icon: Icons.bar_chart_rounded, color: const Color(0xFF18A39B));
    case PulseType.trending:
      return (icon: Icons.local_fire_department_rounded, color: _like);
    case PulseType.expert:
      return (icon: Icons.verified_rounded, color: const Color(0xFF7A4FC2));
    case PulseType.cohort:
      return (icon: Icons.groups_rounded, color: _accent);
    case PulseType.benchmark:
      return (icon: Icons.insights_rounded, color: const Color(0xFFE6A817));
  }
}

// ===========================================================================
//  Home
// ===========================================================================

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key, required this.controller});
  final PregnancyController controller;
  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  // "For you" (ranked feed) vs "Following" (expert + expert-endorsed only).
  bool _following = false;
  // Expert (doctor-mode) filter: show only posts that asked to be verified.
  // Works in BOTH For You and Following so an expert can triage requests fast.
  bool _needsVerifyOnly = false;
  // Community Pulse removed per request — fields kept commented for revert.
  // final PageController _pulseCtrl = PageController(viewportFraction: 0.84);
  // int _pulsePage = 0;
  // Timer? _pulseTimer;

  PregnancyController get controller => widget.controller;

  // initState/dispose only drove Community Pulse (removed per request) — kept
  // commented for an easy revert.
  /*
  @override
  void initState() {
    super.initState();
    // Community Pulse auto-advances, like the design.
    _pulseTimer = Timer.periodic(const Duration(milliseconds: 4500), (_) {
      if (!_pulseCtrl.hasClients) return;
      final count = _proPulse(S(controller.language)).length;
      _pulseCtrl.animateToPage(
        (_pulsePage + 1) % count,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _pulseTimer?.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }
  */

  /// Community Pulse cards, matching the Community Pro design (tag + dot, a big
  /// reassuring line, and a foot note), with soft per-card gradients.
  /// (Pulse section removed per request — kept for an easy revert.)
  List<({String tag, String text, String foot, List<Color> bg, Color dot})>
      // ignore: unused_element
      _proPulse(S s) => [
            (
              tag: s.cmPulse1Tag,
              text: s.cmPulse1Text,
              foot: s.cmPulse1Foot,
              bg: const [Color(0xFFECE2FB), Color(0xFFF7EFFC)],
              dot: const Color(0xFF7C3AED),
            ),
            (
              tag: s.cmPulse2Tag,
              text: s.cmPulse2Text,
              foot: s.cmPulse2Foot,
              bg: const [Color(0xFFFBE7F1), Color(0xFFF4E9FB)],
              dot: const Color(0xFFD6478A),
            ),
            (
              tag: s.cmPulse3Tag,
              text: s.cmPulse3Text,
              foot: s.cmPulse3Foot,
              bg: const [Color(0xFFE7E9FB), Color(0xFFF0E8FB)],
              dot: const Color(0xFF6D28D9),
            ),
            (
              tag: s.cmPulse4Tag,
              text: s.cmPulse4Text,
              foot: s.cmPulse4Foot,
              bg: const [Color(0xFFF1E8FB), Color(0xFFFBF0F6)],
              dot: const Color(0xFF9333EA),
            ),
          ];

  Future<void> _search(AppLanguage lang) async {
    await showSearch<void>(
      context: context,
      delegate: _CommunitySearchDelegate(lang, controller),
    );
  }

  // Warm header: eyebrow kicker, serif title, soft subtitle.
  Widget _header(S s) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 2),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(s.cmTitle.toUpperCase(),
              style: GoogleFonts.manrope(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                  color: _proPink)),
          const SizedBox(height: 4),
          Text(s.cmWalkingTogether,
              style: GoogleFonts.fraunces(
                  fontSize: 35,
                  height: 1.05,
                  fontWeight: FontWeight.w600,
                  color: _proInk)),
          const SizedBox(height: 4),
          Text(s.cmSubtitle,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  height: 1.4,
                  color: _proInk.withValues(alpha: 0.62))),
        ]),
      );

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
        child: Text(t,
            style: GoogleFonts.fraunces(
                fontSize: 18, fontWeight: FontWeight.w600, color: _proInk)),
      );

  // Slim banner shown while testing the doctor experience.
  Widget _doctorModeBanner(S s) => Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [_proPurpleDeep, Color(0xFF9333EA)]),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(children: [
          const Text('🩺', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(s.cmDoctorBanner,
                style: GoogleFonts.manrope(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                    color: Colors.white)),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => CommunityStore.instance.setDoctorMode(false),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(20)),
              child: Text(s.cmExit,
                  style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)),
            ),
          ),
        ]),
      );

  Widget _feedTabs(S s) {
    Widget chip(String label, bool active, VoidCallback onTap) => Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(vertical: 10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: active ? _proPurple : Colors.transparent,
                borderRadius: BorderRadius.circular(22),
                boxShadow: active
                    ? const [
                        BoxShadow(
                            color: Color(0x337C3AED),
                            blurRadius: 10,
                            offset: Offset(0, 3))
                      ]
                    : null,
              ),
              child: Text(label,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: active ? Colors.white : _proInk.withValues(alpha: 0.55))),
            ),
          ),
        );
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 6, 20, 2),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.66),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
      ),
      child: Row(children: [
        chip(s.cmFeed, !_following, () => setState(() => _following = false)),
        chip(s.cmFollowing, _following, () => setState(() => _following = true)),
      ]),
    );
  }

  /// Expert-only "Needs verification" filter chip (doctor mode). Tapping narrows
  /// the current feed to posts whose authors asked an expert to verify them.
  Widget _verifyFilterChip(S s) {
    final on = _needsVerifyOnly;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: GestureDetector(
          onTap: () => setState(() => _needsVerifyOnly = !_needsVerifyOnly),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
            decoration: BoxDecoration(
              color: on ? _proPurple : _proPurple.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                  color: _proPurple.withValues(alpha: on ? 0 : 0.3)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(on ? Icons.verified_rounded : Icons.verified_outlined,
                  size: 15, color: on ? Colors.white : _proPurpleDeep),
              const SizedBox(width: 6),
              Text(s.cmNeedsVerify,
                  style: GoogleFonts.manrope(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: on ? Colors.white : _proPurpleDeep)),
            ]),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = controller.language;
    final s = S(lang);
    return Scaffold(
      backgroundColor: const Color(0xFFFBEAF2),
      // Lift the compose button clear of the floating bottom nav pill (painted
      // over this screen by MainScaffold). A custom location measures the lift
      // from the safe-area-aware endFloat base, so it clears the pill on every
      // device (a plain Padding lift was unreliable across gesture-bar sizes).
      floatingActionButtonLocation: const _EndFloatLifted(78),
      floatingActionButton: AnimatedBuilder(
        animation: CommunityStore.instance,
        builder: (context, _) {
          // A round + FAB (X-style). In doctor (test) mode it authors as the
          // verified doctor (see CreatePostScreen).
          final doc = CommunityStore.instance.doctorMode;
          return FloatingActionButton(
            heroTag: 'communityComposeFab',
            backgroundColor: doc ? _proPurpleDeep : _proPurple,
            foregroundColor: Colors.white,
            tooltip: doc ? s.cmPostAsDoctor : s.cmCreatePost,
            onPressed: () =>
                _push(context, CreatePostScreen(controller: controller)),
            child: Icon(
                doc ? Icons.medical_services_rounded : Icons.add_rounded,
                size: 26),
          );
        },
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: _proBackdrop),
        child: AnimatedBuilder(
          animation: Listenable.merge(
              [CommunityStore.instance, ExpertFollowStore.instance]),
          builder: (context, _) {
            final store = CommunityStore.instance;
            final ef = ExpertFollowStore.instance;
            final joined = store.joinedCommunities;
            final recommended = store.recommendedCommunities;
            // For You = ranked blend; Following = only joined communities +
            // followed experts. Both drop "not interested" (hidden) posts.
            final feed = (_following
                    ? store.feed().where((p) =>
                        store.isJoined(p.communityId) ||
                        ef.isFollowing(p.author))
                    : store.feed())
                .where((p) => !store.isHidden(p.id))
                // Expert "needs verification" filter (doctor mode only): keep just
                // the posts that requested a verification and aren't verified yet.
                .where((p) => !_needsVerifyOnly ||
                    (p.wantsVerification && !store.isEndorsed(p)))
                .toList();
            final topPad = MediaQuery.of(context).padding.top + 6;
            return ListView(
              padding: EdgeInsets.only(top: topPad, bottom: 110),
              children: [
                // Top utility icons (in-scroll, like the design) — no wasted bar.
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 2, 14, 0),
                  child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    // Doctor (test) mode toggle — for trying the doctor flow.
                    IconButton(
                      tooltip: s.cmDoctorMode,
                      visualDensity: VisualDensity.compact,
                      color: store.doctorMode ? _proPurpleDeep : _proInk,
                      icon: Icon(
                          store.doctorMode
                              ? Icons.medical_services_rounded
                              : Icons.medical_services_outlined,
                          size: 22),
                      onPressed: () {
                        store.setDoctorMode(!store.doctorMode);
                        ScaffoldMessenger.of(context)
                          ..clearSnackBars()
                          ..showSnackBar(SnackBar(
                            duration: const Duration(milliseconds: 1100),
                            content: Text(store.doctorMode
                                ? s.cmDoctorOn
                                : s.cmDoctorOff),
                          ));
                      },
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      tooltip: s.cmMyBookmarks,
                      color: _proInk,
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.bookmark_border_rounded, size: 23),
                      onPressed: () =>
                          _push(context, MyBookmarksScreen(controller: controller)),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      tooltip: s.cmMyActivity,
                      color: _proInk,
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.person_outline_rounded, size: 23),
                      onPressed: () =>
                          _push(context, MyActivityScreen(controller: controller)),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      color: _proInk,
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.search_rounded, size: 23),
                      onPressed: () => _search(lang),
                    ),
                  ]),
                ),
                _header(s),
                if (store.doctorMode) _doctorModeBanner(s),
                // Your communities — premium mono-badge cards
                if (joined.isNotEmpty) ...[
                  _label(s.cmJoinedSection),
                  SizedBox(
                    height: 138,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: joined.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 13),
                      itemBuilder: (context, i) => _CommunityCard(
                        community: joined[i],
                        lang: lang,
                        gradient: _commGradients[i % _commGradients.length],
                        unread: store.postsForCommunity(joined[i].id).length,
                        onTap: () => _push(
                            context,
                            CommunityDetailScreen(
                                community: joined[i], controller: controller)),
                        onLong: () =>
                            _communitySheet(context, joined[i], s, joined: true),
                      ),
                    ),
                  ),
                ],
                // Recommended for you — communities you haven't joined yet. The
                // section now ALWAYS renders (header + either the list or a clear
                // note) so it can never silently disappear when you've joined all.
                _label(s.cmRecommended),
                if (recommended.isNotEmpty)
                  SizedBox(
                    height: 214,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: recommended.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 13),
                      itemBuilder: (context, i) => _RecommendedCard(
                        community: recommended[i],
                        lang: lang,
                        joined: store.isJoined(recommended[i].id),
                        onTap: () => _push(
                            context,
                            CommunityDetailScreen(
                                community: recommended[i], controller: controller)),
                        onJoin: () => store.toggleJoin(recommended[i].id),
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 6),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 18),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                            color: _proPurple.withValues(alpha: 0.16)),
                      ),
                      child: Row(children: [
                        const Icon(Icons.celebration_rounded,
                            size: 20, color: _proPurple),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(s.cmRecommendedEmpty,
                              style: GoogleFonts.manrope(
                                  fontSize: 13,
                                  height: 1.4,
                                  fontWeight: FontWeight.w600,
                                  color: _proInk)),
                        ),
                      ]),
                    ),
                  ),
                // Community Pulse REMOVED per request — kept commented for revert.
                /*
                _label(s.cmPulse),
                SizedBox(
                  height: 170,
                  child: PageView.builder(
                    controller: _pulseCtrl,
                    onPageChanged: (i) => setState(() => _pulsePage = i),
                    itemCount: _proPulse(s).length,
                    itemBuilder: (context, i) {
                      final p = _proPulse(s)[i];
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(20, 2, 8, 6),
                        child: _ProPulseCard(
                            tag: p.tag,
                            text: p.text,
                            foot: p.foot,
                            bg: p.bg,
                            dot: p.dot),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  for (int i = 0; i < _proPulse(s).length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: i == _pulsePage ? 18 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: i == _pulsePage
                            ? _proPurple
                            : _proPurple.withValues(alpha: 0.24),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                ]),
                */
                const SizedBox(height: 8),
                // Feed tabs + feed
                _feedTabs(s),
                // Expert triage filter — only while viewing as a doctor.
                if (store.doctorMode) _verifyFilterChip(s),
                const SizedBox(height: 8),
                if (feed.isEmpty && _needsVerifyOnly)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 40, 28, 40),
                    child: Column(children: [
                      const Icon(Icons.verified_outlined,
                          size: 40, color: _proPurple),
                      const SizedBox(height: 12),
                      Text(s.cmNoVerifyRequests,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: _proInk)),
                    ]),
                  )
                else if (_following && feed.isEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 40, 28, 40),
                    child: Column(children: [
                      const Icon(Icons.group_outlined,
                          size: 40, color: _proPurple),
                      const SizedBox(height: 12),
                      Text(s.cmFollowingEmpty,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: _proInk)),
                      const SizedBox(height: 6),
                      Text(s.cmFollowingEmptySub,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.manrope(
                              fontSize: 12.5, color: AppTheme.neutral500)),
                    ]),
                  )
                else
                  for (final p in feed)
                    CommunityPostCard(
                      key: ValueKey(p.id),
                      post: p,
                      lang: lang,
                      controller: controller,
                      onTap: () => _push(context,
                          PostDetailScreen(post: p, controller: controller)),
                    ),
              ],
            );
          },
        ),
      ),
    );
  }
}

Widget _sectionTitle(BuildContext context, String title) => Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
      child: Text(title,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w800)),
    );

/// Community Pulse card — soft gradient, a coloured tag dot, a big reassuring
/// line and a foot note (Community Pro design).
// Pulse card — kept for revert (Community Pulse section removed per request).
// ignore: unused_element
class _ProPulseCard extends StatelessWidget {
  const _ProPulseCard({
    required this.tag,
    required this.text,
    required this.foot,
    required this.bg,
    required this.dot,
  });
  final String tag;
  final String text;
  final String foot;
  final List<Color> bg;
  final Color dot;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight, colors: bg),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x127C3AED)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 8,
            height: 8,
            decoration:
                BoxDecoration(color: dot, borderRadius: BorderRadius.circular(3)),
          ),
          const SizedBox(width: 9),
          Flexible(
            child: Text(tag,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: dot)),
          ),
        ]),
        const SizedBox(height: 12),
        Expanded(
          child: Text(text,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 17.5,
                  height: 1.32,
                  fontWeight: FontWeight.w500,
                  color: _proInk)),
        ),
        const SizedBox(height: 10),
        Text(foot,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: _proInk.withValues(alpha: 0.55))),
      ]),
    );
  }
}

void _communitySheet(BuildContext context, Community c, S s, {required bool joined}) {
  showModalBottomSheet<void>(
    context: context,
    builder: (_) {
      final store = CommunityStore.instance;
      return SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: Icon(store.isMuted(c.id)
                ? Icons.notifications_active_rounded
                : Icons.notifications_off_rounded),
            title: Text(store.isMuted(c.id) ? s.cmUnmute : s.cmMute),
            onTap: () {
              store.toggleMute(c.id);
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout_rounded),
            title: Text(s.cmLeave),
            onTap: () {
              store.toggleJoin(c.id);
              Navigator.of(context).pop();
            },
          ),
        ]),
      );
    },
  );
}

// --- Your communities card (premium mono badge) ---
class _CommunityCard extends StatelessWidget {
  const _CommunityCard({
    required this.community,
    required this.lang,
    required this.gradient,
    required this.unread,
    required this.onTap,
    required this.onLong,
  });
  final Community community;
  final AppLanguage lang;
  final List<Color> gradient;
  final int unread;
  final VoidCallback onTap;
  final VoidCallback onLong;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final s = S(lang);
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLong,
      child: Container(
        width: 172,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
          boxShadow: const [
            BoxShadow(
                color: Color(0x14512D77), blurRadius: 16, offset: Offset(0, 6)),
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Stack(clipBehavior: Clip.none, children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: gradient),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(_mono(community.name),
                    style: GoogleFonts.fraunces(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
              Positioned(
                right: -3,
                top: -3,
                child: Container(
                  width: 13,
                  height: 13,
                  decoration: BoxDecoration(
                    color: const Color(0xFF34C759),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ]),
            const Spacer(),
            if (unread > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: _proPurple.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(s.cmNew(unread),
                    style: text.labelSmall?.copyWith(
                        color: _proPurpleDeep, fontWeight: FontWeight.w800)),
              ),
          ]),
          const SizedBox(height: 14),
          Text(community.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: text.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w800, color: _proInk)),
          const SizedBox(height: 2),
          Text(s.cmMembers(community.members),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: text.labelSmall?.copyWith(color: AppTheme.neutral500)),
        ]),
      ),
    );
  }
}

// --- recommended card (Join + celebrate) ---
class _RecommendedCard extends StatelessWidget {
  const _RecommendedCard({
    required this.community,
    required this.lang,
    required this.joined,
    required this.onTap,
    required this.onJoin,
  });
  final Community community;
  final AppLanguage lang;
  final bool joined;
  final VoidCallback onTap;
  final VoidCallback onJoin;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final s = S(lang);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 210,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
          boxShadow: const [
            BoxShadow(
                color: Color(0x14512D77), blurRadius: 16, offset: Offset(0, 6)),
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _proPurple.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(community.emoji, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(height: 10),
          Text(community.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: text.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w800, color: _proInk)),
          const SizedBox(height: 2),
          Text(s.cmMembers(community.members),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: text.labelSmall?.copyWith(color: AppTheme.neutral500)),
          const SizedBox(height: 8),
          Expanded(
            child: Text(community.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: text.bodySmall
                    ?.copyWith(color: AppTheme.neutral600, height: 1.35)),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: joined
                ? OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _proPurpleDeep,
                      side: BorderSide(color: _proPurple.withValues(alpha: 0.4)),
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      minimumSize: const Size(0, 38),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: onJoin,
                    icon: const Icon(Icons.check_rounded, size: 17),
                    label: Text(s.cmJoinedBadge,
                        style: text.labelMedium
                            ?.copyWith(fontWeight: FontWeight.w800)),
                  )
                : FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: _proPurple,
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      minimumSize: const Size(0, 38),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: onJoin,
                    child: Text(s.cmJoin,
                        style: text.labelMedium?.copyWith(
                            color: Colors.white, fontWeight: FontWeight.w800)),
                  ),
          ),
        ]),
      ),
    );
  }
}

// --- pulse card (old kPulse renderer; replaced by _ProPulseCard, kept for
// reference per the comment-out-never-delete rule) ---
// ignore: unused_element
class _PulseCardView extends StatelessWidget {
  const _PulseCardView({required this.card, required this.lang, required this.controller});
  final PulseCard card;
  final AppLanguage lang;
  final PregnancyController controller;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final s = S(lang);
    final v = _pulseVisual(card.type);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [v.color.withValues(alpha: 0.09), AppTheme.surface],
          stops: const [0.0, 0.7],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
              color: Color(0x142D144C), blurRadius: 16, offset: Offset(0, 5)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: v.color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(v.icon, size: 18, color: v.color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              card.title.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: text.labelSmall?.copyWith(
                  color: v.color,
                  letterSpacing: 0.6,
                  fontWeight: FontWeight.w800),
            ),
          ),
        ]),
        const SizedBox(height: 11),
        Expanded(
          child: Text(
            card.body,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: text.titleSmall?.copyWith(
                height: 1.35,
                fontWeight: FontWeight.w700,
                color: AppTheme.primary900),
          ),
        ),
        const SizedBox(height: 10),
        _pulseAction(context, s, v.color),
      ]),
    );
  }

  Widget _pulseAction(BuildContext context, S s, Color color) {
    final store = CommunityStore.instance;
    final text = Theme.of(context).textTheme;
    switch (card.type) {
      case PulseType.poll:
        final voted = store.votedOption(kPulseKicksPollId);
        if (voted != null) {
          return Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.check_circle_rounded, size: 16, color: color),
            const SizedBox(width: 6),
            Text('${s.cmVoted} · $voted',
                style: text.labelMedium?.copyWith(
                    color: AppTheme.neutral700, fontWeight: FontWeight.w700)),
          ]);
        }
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final o in card.options)
              GestureDetector(
                onTap: () => store.vote(kPulseKicksPollId, o),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: color.withValues(alpha: 0.28)),
                  ),
                  child: Text(o,
                      style: text.labelMedium
                          ?.copyWith(color: color, fontWeight: FontWeight.w700)),
                ),
              ),
          ],
        );
      case PulseType.trending:
        return GestureDetector(
          onTap: () {
            final p = store.postById(card.linkPostId ?? '');
            if (p != null) {
              _push(context, PostDetailScreen(post: p, controller: controller));
            }
          },
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(s.cmViewDiscussion,
                style: text.labelMedium
                    ?.copyWith(color: color, fontWeight: FontWeight.w800)),
            Icon(Icons.chevron_right_rounded, size: 18, color: color),
          ]),
        );
      case PulseType.expert:
        return GestureDetector(
          onTap: () => ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(s.cmComingSoon))),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.notifications_active_rounded, size: 16, color: color),
            const SizedBox(width: 6),
            Text(s.cmRemindMe,
                style: text.labelMedium
                    ?.copyWith(color: color, fontWeight: FontWeight.w800)),
          ]),
        );
      case PulseType.cohort:
      case PulseType.benchmark:
        return const SizedBox.shrink();
    }
  }
}

// ===========================================================================
//  Post card (feed + detail)
// ===========================================================================

class CommunityPostCard extends StatelessWidget {
  const CommunityPostCard({
    super.key,
    required this.post,
    required this.lang,
    required this.controller,
    this.onTap,
    this.detailed = false,
  });
  final CommunityPost post;
  final AppLanguage lang;
  final PregnancyController controller;
  final VoidCallback? onTap;
  final bool detailed;

  void _openProfile(BuildContext context) => _push(
      context, CommunityProfileScreen(post: post, controller: controller));

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final s = S(lang);
    final store = CommunityStore.instance;
    final community = communityById(post.communityId);
    final endorsed = store.isEndorsed(post);
    final liked = store.isLiked(post.id);
    final saved = store.isSaved(post.id);
    final reposted = store.isReposted(post.id);
    return Container(
      // Flat Twitter-style row (no card chrome). Verified posts no longer get a
      // purple wash or full-width banner — just a small inline "Verified by …"
      // hint on its own line below (see the verification line near the actions).
      color: AppTheme.surface,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 8),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              GestureDetector(
                onTap: () => _openProfile(context),
                child: _authorAvatar(post, size: 44),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // header: [name + seal + @handle · time] ……… ⋯
                      // The name/handle group is Expanded so it truncates and the
                      // ⋯ menu always pins to the FAR top-right corner (it used to
                      // float mid-row whenever the name/handle ran long).
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Row(children: [
                              Flexible(
                                child: GestureDetector(
                                  onTap: () => _openProfile(context),
                                  child: Text(post.author,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: text.titleSmall?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          color: _proInk)),
                                ),
                              ),
                              if (_isExpertAuthor(post)) ...[
                                const SizedBox(width: 3),
                                const Icon(Icons.verified_rounded,
                                    size: 15, color: _proPurple),
                              ],
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                    '@${_handle(post.author)} · ${_timeAgo(post)}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.manrope(
                                        fontSize: 12.5,
                                        color: AppTheme.neutral500)),
                              ),
                            ]),
                          ),
                          InkWell(
                            onTap: () => _showPostMenu(context, s, post),
                            borderRadius: BorderRadius.circular(20),
                            child: const Padding(
                              padding: EdgeInsets.only(left: 6, bottom: 4),
                              child: Icon(Icons.more_horiz_rounded,
                                  size: 19, color: AppTheme.neutral500),
                            ),
                          ),
                        ],
                      ),
                      if (community != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 1),
                          child: Text(
                              '${s.cmInCommunity} ${community.emoji} ${community.name}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.manrope(
                                  fontSize: 11.5, color: AppTheme.neutral400)),
                        ),
                      const SizedBox(height: 6),
                      // body
                      Text(post.text,
                          maxLines: detailed ? null : 6,
                          overflow: detailed
                              ? TextOverflow.visible
                              : TextOverflow.ellipsis,
                          style: text.bodyMedium?.copyWith(
                              height: 1.45, fontSize: 14.5, color: _proInk)),
                      if (post.imageUrls.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        _PostPhotos(paths: post.imageUrls),
                      ] else if (post.image.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Container(
                          height: 150,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child:
                              Text(post.image, style: const TextStyle(fontSize: 56)),
                        ),
                      ],
                      if (post.pollOptions.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        _PollBlock(post: post, lang: lang),
                      ],
                      if (post.topics.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Wrap(spacing: 8, runSpacing: 4, children: [
                          for (final t in post.topics)
                            Text('#${t.replaceAll(' ', '')}',
                                style: GoogleFonts.manrope(
                                    fontSize: 12.5,
                                    color: _proPurpleDeep,
                                    fontWeight: FontWeight.w600)),
                        ]),
                      ],
                      const SizedBox(height: 10),
                      // engagement row — reply · repost · like · views · save · share
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _EngageButton(
                                icon: Icons.mode_comment_outlined,
                                label: '${store.commentCount(post)}',
                                color: AppTheme.neutral500,
                                onTap: onTap ?? () {}),
                            _EngageButton(
                                icon: Icons.repeat_rounded,
                                label: '${store.repostCount(post)}',
                                color: reposted
                                    ? const Color(0xFF17A673)
                                    : AppTheme.neutral500,
                                onTap: () {
                                  store.toggleRepost(post.id);
                                  _toast(
                                      context,
                                      store.isReposted(post.id)
                                          ? s.cmReposted
                                          : s.cmRepostUndone);
                                }),
                            _EngageButton(
                                icon: liked
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                label: '${store.likeCount(post)}',
                                color: liked ? _like : AppTheme.neutral500,
                                onTap: () => store.toggleLike(post.id)),
                            _EngageButton(
                                icon: Icons.bar_chart_rounded,
                                label: _viewsLabel(post),
                                color: AppTheme.neutral500,
                                onTap: onTap ?? () {}),
                            _EngageButton(
                                icon: saved
                                    ? Icons.bookmark_rounded
                                    : Icons.bookmark_border_rounded,
                                label: '',
                                color: saved ? _accent : AppTheme.neutral500,
                                onTap: () => store.toggleSave(post.id)),
                            _EngageButton(
                                icon: Icons.ios_share_rounded,
                                label: '',
                                color: AppTheme.neutral500,
                                onTap: () => _sharePost(s, post)),
                          ]),
                      // Verification line (subtle, single line):
                      //   • endorsed → small "Verified by …" hint (all viewers)
                      //   • asked but not yet verified → for a member, an
                      //     "Awaiting [specialty] verification" tag; for a doctor,
                      //     a "Comment to verify this post" prompt.
                      // A post is verified when a DOCTOR COMMENTS on it (see
                      // CommunityStore.addComment) — the old explicit "Verify
                      // this" button is removed (kept commented just below).
                      if (endorsed) ...[
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: _verifiedHint(context, s, post),
                        ),
                      ] else if (post.wantsVerification) ...[
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child:
                              _pendingVerifyTag(s, post, doctor: store.doctorMode),
                        ),
                      ],
                      // Verification is now comment-driven; the explicit button is
                      // removed but kept here for an easy revert if ever needed:
                      // if (store.doctorMode && post.wantsVerification)
                      //   _DoctorEndorseButton(post: post, lang: lang),
                    ]),
              ),
            ]),
          ),
        ),
        const Divider(height: 1, thickness: 1, color: Color(0x12512D77)),
      ]),
    );
  }
}

// Old engagement chip — replaced by the Twitter-style `_EngageButton` row.
// Kept for an easy revert.
// ignore: unused_element
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 6),
          Text(label, style: text.labelMedium?.copyWith(color: AppTheme.neutral600)),
        ]),
      ),
    );
  }
}

// ===========================================================================
//  Doctor (test) mode — verify/endorse a post with a celebratory flourish
//  No longer shown (verification is comment-driven now) — kept for an easy
//  revert if we ever want the explicit button back.
// ===========================================================================
// ignore: unused_element
class _DoctorEndorseButton extends StatefulWidget {
  const _DoctorEndorseButton({required this.post, required this.lang});
  final CommunityPost post;
  final AppLanguage lang;
  @override
  State<_DoctorEndorseButton> createState() => _DoctorEndorseButtonState();
}

class _DoctorEndorseButtonState extends State<_DoctorEndorseButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 760));

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _onTap() {
    final store = CommunityStore.instance;
    final was = store.isDoctorEndorsed(widget.post.id);
    store.toggleDoctorEndorse(widget.post.id);
    if (!was) {
      HapticFeedback.mediumImpact();
      _c.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S(widget.lang);
    final store = CommunityStore.instance;
    final endorsed = store.isDoctorEndorsed(widget.post.id);
    return GestureDetector(
      onTap: _onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final t = _c.value;
          final popping = endorsed && t > 0 && t < 1;
          final seal = Transform.rotate(
            angle: popping ? 0.45 * math.sin(t * math.pi) : 0,
            child: Transform.scale(
              scale: popping ? 1 + 0.55 * math.sin(t * math.pi) : 1,
              child: Icon(Icons.verified_rounded,
                  size: 16, color: endorsed ? Colors.white : _proPurpleDeep),
            ),
          );
          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              if (popping)
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(painter: _EndorseBurstPainter(t)),
                  ),
                ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                decoration: BoxDecoration(
                  gradient: endorsed
                      ? const LinearGradient(
                          colors: [_proPurpleDeep, Color(0xFF9333EA)])
                      : null,
                  color: endorsed ? null : _proPurple.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: endorsed
                      ? null
                      : Border.all(color: _proPurple.withValues(alpha: 0.4)),
                  boxShadow: endorsed
                      ? [
                          BoxShadow(
                              color: _proPurple.withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 3))
                        ]
                      : null,
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  seal,
                  const SizedBox(width: 6),
                  Text(endorsed ? s.cmYouVerified : s.cmEndorseThis,
                      style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: endorsed ? Colors.white : _proPurpleDeep)),
                ]),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// An expanding ring + gold/purple sparkle burst when a doctor verifies a post.
class _EndorseBurstPainter extends CustomPainter {
  _EndorseBurstPainter(this.t);
  final double t;
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final e = Curves.easeOut.transform(t.clamp(0.0, 1.0));
    final fade = 1 - t;
    canvas.drawCircle(
      center,
      6 + 26 * e,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6 * fade
        ..color = const Color(0xFF9333EA).withValues(alpha: fade * 0.75),
    );
    const n = 8;
    for (var i = 0; i < n; i++) {
      final ang = (i / n) * 2 * math.pi + t;
      final p = center + Offset(math.cos(ang), math.sin(ang)) * (8 + 24 * e);
      canvas.drawCircle(
        p,
        2.6 * fade,
        Paint()
          ..color = (i.isEven ? const Color(0xFFE6A817) : _proPurple)
              .withValues(alpha: fade),
      );
    }
  }

  @override
  bool shouldRepaint(_EndorseBurstPainter old) => old.t != t;
}

/// Renders the real photos attached to a user post: one fills the width, more
/// scroll horizontally as rounded tiles.
class _PostPhotos extends StatelessWidget {
  const _PostPhotos({required this.paths});
  final List<String> paths;

  Widget _broken(double w, double h) => Container(
        width: w == double.infinity ? null : w,
        height: h,
        color: AppTheme.surfaceContainer,
        alignment: Alignment.center,
        child: const Icon(Icons.broken_image_outlined, color: AppTheme.neutral400),
      );

  @override
  Widget build(BuildContext context) {
    if (paths.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(
          File(paths.first),
          height: 210,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _broken(double.infinity, 210),
        ),
      );
    }
    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: paths.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) => ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.file(
            File(paths[i]),
            width: 150,
            height: 150,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _broken(150, 150),
          ),
        ),
      ),
    );
  }
}

class _PollBlock extends StatelessWidget {
  const _PollBlock({required this.post, required this.lang});
  final CommunityPost post;
  final AppLanguage lang;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final store = CommunityStore.instance;
    final voted = store.votedOption(post.id);
    return Column(
      children: [
        for (final o in post.pollOptions)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: voted == null ? () => store.vote(post.id, o) : null,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                decoration: BoxDecoration(
                  color: voted == o
                      ? _accent.withValues(alpha: 0.14)
                      : AppTheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: voted == o ? _accent : Colors.transparent,
                    width: 1.4,
                  ),
                ),
                child: Row(children: [
                  Expanded(
                    child: Text(o,
                        style: text.bodyMedium?.copyWith(
                            fontWeight: voted == o ? FontWeight.w800 : FontWeight.w500)),
                  ),
                  if (voted == o) const Icon(Icons.check_circle_rounded, size: 18, color: _accent),
                ]),
              ),
            ),
          ),
      ],
    );
  }
}

// ===========================================================================
//  Community detail
// ===========================================================================

class CommunityDetailScreen extends StatelessWidget {
  const CommunityDetailScreen({super.key, required this.community, required this.controller});
  final Community community;
  final PregnancyController controller;
  @override
  Widget build(BuildContext context) {
    final lang = controller.language;
    final s = S(lang);
    final text = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(title: Text(community.name)),
      body: AnimatedBuilder(
        animation: CommunityStore.instance,
        builder: (context, _) {
          final store = CommunityStore.instance;
          final posts = store.postsForCommunity(community.id);
          final joined = store.isJoined(community.id);
          return ListView(
            padding: const EdgeInsets.only(bottom: 28),
            children: [
              // banner
              Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_accent.withValues(alpha: 0.16), AppTheme.surface],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: _accent.withValues(alpha: 0.18)),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(community.emoji, style: const TextStyle(fontSize: 44)),
                  const SizedBox(height: 10),
                  Text(community.name,
                      style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                  Text(s.cmMembers(community.members),
                      style: text.labelMedium?.copyWith(color: AppTheme.neutral500)),
                  const SizedBox(height: 10),
                  Text(community.description,
                      style: text.bodyMedium?.copyWith(color: AppTheme.neutral700, height: 1.45)),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: joined ? AppTheme.surfaceContainerHigh : _accent,
                        foregroundColor: joined ? AppTheme.neutral700 : Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => store.toggleJoin(community.id),
                      child: Text(joined ? s.cmJoinedBadge : s.cmJoin),
                    ),
                  ),
                ]),
              ),
              // Composer entry — write a post (with photos) to this group.
              if (joined)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 2),
                  child: GestureDetector(
                    onTap: () => _push(
                        context,
                        CreatePostScreen(
                            controller: controller,
                            initialCommunityId: community.id)),
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppTheme.outlineVariant),
                      ),
                      child: Row(children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: _accent.withValues(alpha: 0.12),
                          child: Text(
                            controller.motherName.isNotEmpty
                                ? controller.motherName[0].toUpperCase()
                                : '🙂',
                            style: text.labelLarge
                                ?.copyWith(color: _accent, fontWeight: FontWeight.w800),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(s.cmWritePrompt,
                              style: text.bodyMedium
                                  ?.copyWith(color: AppTheme.neutral500)),
                        ),
                        const Icon(Icons.photo_camera_outlined,
                            size: 22, color: _accent),
                      ]),
                    ),
                  ),
                ),
              _sectionTitle(context, s.cmPosts),
              if (posts.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(s.cmEmptyComments,
                      textAlign: TextAlign.center,
                      style: text.bodyMedium?.copyWith(color: AppTheme.neutral500)),
                )
              else
                for (final p in posts)
                  CommunityPostCard(
                    post: p,
                    lang: lang,
                    controller: controller,
                    onTap: () => _push(context, PostDetailScreen(post: p, controller: controller)),
                  ),
            ],
          );
        },
      ),
    );
  }
}

// ===========================================================================
//  Post detail (YouTube-style: post + comments + related + suggested)
// ===========================================================================

class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({super.key, required this.post, required this.controller});
  final CommunityPost post;
  final PregnancyController controller;
  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final _commentCtrl = TextEditingController();

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  void _send() {
    final t = _commentCtrl.text.trim();
    if (t.isEmpty) return;
    CommunityStore.instance.addComment(widget.post.id, t);
    _commentCtrl.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.controller.language;
    final s = S(lang);
    final text = Theme.of(context).textTheme;
    final post = widget.post;
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(title: Text(s.cmTitle)),
      body: AnimatedBuilder(
        animation: CommunityStore.instance,
        builder: (context, _) {
          final store = CommunityStore.instance;
          final seed = seedCommentsFor(post.id);
          final mine = store.userComments(post.id);
          // related: other posts sharing a topic
          final related = store
              .feed()
              .where((p) => p.id != post.id && p.topics.any(post.topics.contains))
              .take(3)
              .toList();
          // suggested: recommended communities sharing a topic
          final suggested = store.recommendedCommunities
              .where((c) => c.topics.any(post.topics.contains))
              .take(3)
              .toList();
          return ListView(
            padding: const EdgeInsets.only(top: 8, bottom: 28),
            children: [
              CommunityPostCard(
                  post: post,
                  lang: lang,
                  controller: widget.controller,
                  detailed: true),
              _sectionTitle(context, s.cmComments),
              if (seed.isEmpty && mine.isEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
                  child: Text(s.cmEmptyComments,
                      style: text.bodyMedium?.copyWith(color: AppTheme.neutral500)),
                ),
              for (final c in seed) _commentTile(context, c.emoji, c.author, c.text),
              // In doctor (test) mode your comments post AS the verified doctor.
              for (final c in mine)
                _commentTile(
                    context,
                    store.doctorMode ? '🩺' : '🙂',
                    store.doctorMode
                        ? kTestDoctorName
                        : widget.controller.motherName,
                    c),
              // add comment
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(children: [
                  Expanded(
                    child: TextField(
                      controller: _commentCtrl,
                      minLines: 1,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: s.cmAddComment,
                        filled: true,
                        fillColor: AppTheme.surface,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: AppTheme.outlineVariant),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: AppTheme.outlineVariant),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    style: IconButton.styleFrom(backgroundColor: _accent),
                    icon: const Icon(Icons.send_rounded, color: Colors.white),
                    onPressed: _send,
                  ),
                ]),
              ),
              if (related.isNotEmpty) ...[
                _sectionTitle(context, s.cmRelated),
                for (final p in related)
                  ListTile(
                    leading: Text(communityById(p.communityId)?.emoji ?? '💬',
                        style: const TextStyle(fontSize: 22)),
                    title: Text(p.text,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: text.bodyMedium),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _push(context,
                        PostDetailScreen(post: p, controller: widget.controller)),
                  ),
              ],
              if (suggested.isNotEmpty) ...[
                _sectionTitle(context, s.cmSuggested),
                for (final c in suggested)
                  ListTile(
                    leading: Text(c.emoji, style: const TextStyle(fontSize: 22)),
                    title: Text(c.name, style: text.titleSmall),
                    subtitle: Text(s.cmMembers(c.members),
                        style: text.labelSmall?.copyWith(color: AppTheme.neutral500)),
                    trailing: TextButton(
                      onPressed: () => store.toggleJoin(c.id),
                      child: Text(store.isJoined(c.id) ? s.cmJoinedBadge : s.cmJoin),
                    ),
                    onTap: () => _push(context,
                        CommunityDetailScreen(community: c, controller: widget.controller)),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}

Widget _commentTile(BuildContext context, String emoji, String author, String text) {
  final t = Theme.of(context).textTheme;
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      CircleAvatar(
        radius: 16,
        backgroundColor: _accent.withValues(alpha: 0.12),
        child: Text(emoji, style: const TextStyle(fontSize: 15)),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.outlineVariant),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(author, style: t.labelMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(text, style: t.bodyMedium?.copyWith(height: 1.4)),
          ]),
        ),
      ),
    ]),
  );
}

// ===========================================================================
//  Create post
// ===========================================================================

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen(
      {super.key, required this.controller, this.initialCommunityId});
  final PregnancyController controller;
  final String? initialCommunityId;
  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _textCtrl = TextEditingController();
  final _picker = ImagePicker();
  final List<String> _photos = [];
  String? _communityId;
  PostType _type = PostType.question;
  List<String> _autoTags = const [];
  bool _wantVerify = false; // "ask an expert to verify this"
  String _specialty = 'all'; // preferred expert specialty for verification

  @override
  void initState() {
    super.initState();
    // Default to "Your feed" (general timeline). Only pre-select a community the
    // user has actually joined — you can't post into one you're not part of.
    final init = widget.initialCommunityId ?? '';
    _communityId = CommunityStore.instance.isJoined(init) ? init : '';
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  Future<void> _addFromGallery() async {
    final imgs = await _picker.pickMultiImage();
    if (imgs.isEmpty) return;
    setState(() {
      _photos.addAll(imgs.map((x) => x.path));
      if (_type == PostType.question) _type = PostType.photo;
    });
  }

  Future<void> _addFromCamera() async {
    final img = await _picker.pickImage(source: ImageSource.camera);
    if (img == null) return;
    setState(() {
      _photos.add(img.path);
      if (_type == PostType.question) _type = PostType.photo;
    });
  }

  void _share(S s) {
    final t = _textCtrl.text.trim();
    if ((t.isEmpty && _photos.isEmpty) || _communityId == null) return;
    // In doctor (test) mode the post is authored AS the verified doctor — name +
    // credential, so it renders with the gradient expert seal, not a plain user.
    final asDoctor = CommunityStore.instance.doctorMode;
    final post = CommunityPost(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      communityId: _communityId!,
      author: asDoctor ? kTestDoctorName : widget.controller.motherName,
      authorEmoji: asDoctor ? '🩺' : '🙂',
      text: t,
      type: _type,
      topics: inferTopics(t), // auto-tag from the text
      imageUrls: List.of(_photos),
      isUser: true,
      cred: asDoctor ? kTestDoctorCred : '',
      // A doctor's own post doesn't request verification; a member's can.
      wantsVerification: !asDoctor && _wantVerify,
      preferredSpecialty: (!asDoctor && _wantVerify) ? _specialty : '',
      // Stamp creation time so the new post floats to the top of the feed.
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    CommunityStore.instance.addPost(post);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(asDoctor ? s.cmPostedAsDoctor : s.cmPosted)));
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.controller.language;
    final s = S(lang);
    final text = Theme.of(context).textTheme;
    final joined = CommunityStore.instance.joinedCommunities;
    const types = [
      PostType.question,
      PostType.experience,
      PostType.milestone,
      PostType.photo,
    ];
    final canPost = _textCtrl.text.trim().isNotEmpty || _photos.isNotEmpty;
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: Text(s.cmCreatePost),
        // Share/Post moved INTO the composer (bottom-right of the text field) so
        // the user posts right where they type. Old top-right button kept here,
        // commented, for an easy revert.
        // actions: [
        //   TextButton(
        //     onPressed: () => _share(s),
        //     child: Text(s.cmShare,
        //         style: text.labelLarge
        //             ?.copyWith(color: _accent, fontWeight: FontWeight.w800)),
        //   ),
        // ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
        children: [
          // Doctor (test) mode: make it obvious this post goes out as a doctor.
          if (CommunityStore.instance.doctorMode) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [_proPurple, Color(0xFFA855F7)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(children: [
                const Icon(Icons.verified_rounded,
                    color: Colors.white, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('${s.cmPostingAsDoctor}  ·  $kTestDoctorName',
                      style: text.labelLarge?.copyWith(
                          color: Colors.white, fontWeight: FontWeight.w700)),
                ),
              ]),
            ),
          ],
          // ── Ask an expert to verify (members only) ───────────────────────
          // A doctor's own post is already authoritative; a member can request a
          // verification — it marks the post so experts see a "Verify this"
          // button and can find it via their "Needs verification" filter.
          if (!CommunityStore.instance.doctorMode) ...[
            Container(
              decoration: BoxDecoration(
                color: _proPurple.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _proPurple.withValues(alpha: 0.18)),
              ),
              child: SwitchListTile.adaptive(
                value: _wantVerify,
                onChanged: (v) => setState(() => _wantVerify = v),
                activeThumbColor: _proPurple,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                secondary:
                    const Icon(Icons.verified_outlined, color: _proPurpleDeep),
                title: Text(s.cmAskVerifyTitle,
                    style: text.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800, color: _proInk)),
                subtitle: Text(s.cmAskVerifySub,
                    style:
                        text.bodySmall?.copyWith(color: AppTheme.neutral600)),
              ),
            ),
            // When she asks, let her choose which kind of expert to reach.
            if (_wantVerify) ...[
              const SizedBox(height: 12),
              Text(s.cmChooseSpecialty,
                  style: text.labelLarge?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final sp in kVerifySpecialties)
                  ChoiceChip(
                    label: Text(s.cmSpecialty(sp)),
                    selected: _specialty == sp,
                    onSelected: (_) => setState(() => _specialty = sp),
                  ),
              ]),
            ],
            const SizedBox(height: 18),
          ],
          // ── What would you like to share? (text + send, at the top) ──────
          // Chat-composer style: the mic + a circular Share/send button live at
          // the bottom-right INSIDE the text field, so posting happens right
          // where the user is typing.
          Stack(
            children: [
              TextField(
                controller: _textCtrl,
                minLines: 5,
                maxLines: 12,
                autofocus: true,
                onChanged: (v) => setState(() => _autoTags = inferTopics(v)),
                decoration: InputDecoration(
                  hintText: s.cmShareSomething,
                  filled: true,
                  fillColor: AppTheme.surface,
                  contentPadding: const EdgeInsets.fromLTRB(16, 14, 16, 54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: AppTheme.outlineVariant),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: AppTheme.outlineVariant),
                  ),
                ),
              ),
              Positioned(
                right: 8,
                bottom: 8,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  MicDictateButton(controller: _textCtrl, s: s),
                  const SizedBox(width: 4),
                  Material(
                    color: canPost ? _accent : AppTheme.neutral300,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: canPost ? () => _share(s) : null,
                      child: const Padding(
                        padding: EdgeInsets.all(9),
                        child: Icon(Icons.send_rounded,
                            color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ]),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // ── Add photos (gallery + camera) ────────────────────────────────
          Row(children: [
            OutlinedButton.icon(
              onPressed: _addFromGallery,
              icon: const Icon(Icons.photo_library_outlined, size: 18),
              label: Text(s.cmAddPhotos),
              style: OutlinedButton.styleFrom(
                foregroundColor: _proPurpleDeep,
                side: BorderSide(color: _proPurple.withValues(alpha: 0.4)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(width: 10),
            OutlinedButton.icon(
              onPressed: _addFromCamera,
              icon: const Icon(Icons.photo_camera_outlined, size: 18),
              label: Text(s.cmCamera),
              style: OutlinedButton.styleFrom(
                foregroundColor: _proPurpleDeep,
                side: BorderSide(color: _proPurple.withValues(alpha: 0.4)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ]),
          if (_photos.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (var i = 0; i < _photos.length; i++)
                  Stack(clipBehavior: Clip.none, children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.file(File(_photos[i]),
                          width: 92, height: 92, fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: -7,
                      right: -7,
                      child: GestureDetector(
                        onTap: () => setState(() => _photos.removeAt(i)),
                        child: Container(
                          decoration: const BoxDecoration(
                              color: _proInk, shape: BoxShape.circle),
                          padding: const EdgeInsets.all(3),
                          child: const Icon(Icons.close_rounded,
                              size: 15, color: Colors.white),
                        ),
                      ),
                    ),
                  ]),
              ],
            ),
          ],
          const SizedBox(height: 18),
          // ── Where to post (your feed, or a community you've joined) ──────
          Text(s.cmPostTo,
              style: text.labelLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // Post to your own feed (general timeline) or into a community.
              ChoiceChip(
                label: Text('🏠 ${s.cmYourFeed}'),
                selected: _communityId == '',
                onSelected: (_) => setState(() => _communityId = ''),
              ),
              for (final c in joined)
                ChoiceChip(
                  label: Text('${c.emoji} ${c.name}'),
                  selected: _communityId == c.id,
                  onSelected: (_) => setState(() => _communityId = c.id),
                ),
            ],
          ),
          const SizedBox(height: 18),
          // ── Post type ────────────────────────────────────────────────────
          Text(s.cmTypeLabel,
              style: text.labelLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in types)
                ChoiceChip(
                  label: Text(s.cmPostType(_typeVisual(t).key)),
                  selected: _type == t,
                  onSelected: (_) => setState(() => _type = t),
                ),
            ],
          ),
          if (_autoTags.isNotEmpty) ...[
            const SizedBox(height: 18),
            Row(children: [
              const Icon(Icons.auto_awesome_rounded, size: 16, color: _accent),
              const SizedBox(width: 6),
              Text(s.cmSuggestedTags,
                  style: text.labelLarge?.copyWith(fontWeight: FontWeight.w800)),
            ]),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final tag in _autoTags)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('#$tag',
                        style: text.labelSmall
                            ?.copyWith(color: _accent, fontWeight: FontWeight.w700)),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ===========================================================================
//  My Activity & My Bookmarks
// ===========================================================================

class MyActivityScreen extends StatelessWidget {
  const MyActivityScreen({super.key, required this.controller});
  final PregnancyController controller;
  @override
  Widget build(BuildContext context) {
    final lang = controller.language;
    final s = S(lang);
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(title: Text(s.cmMyActivity)),
      body: AnimatedBuilder(
        animation: CommunityStore.instance,
        builder: (context, _) {
          final store = CommunityStore.instance;
          final posts = store.createdPosts;
          final commented = store.commentedPosts;
          final liked = store.likedPosts;
          final upvoted = store.upvotedPosts;
          if (posts.isEmpty &&
              commented.isEmpty &&
              liked.isEmpty &&
              upvoted.isEmpty) {
            return _emptyState(context, Icons.forum_outlined, s.cmActEmpty);
          }
          Widget section(String title, List<CommunityPost> list) {
            if (list.isEmpty) return const SizedBox.shrink();
            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle(context, title),
                  for (final p in list)
                    CommunityPostCard(
                      post: p,
                      lang: lang,
                      controller: controller,
                      onTap: () => _push(context,
                          PostDetailScreen(post: p, controller: controller)),
                    ),
                ]);
          }

          return ListView(
            padding: const EdgeInsets.only(bottom: 28),
            children: [
              section(s.cmActPosts, posts),
              section(s.cmActCommented, commented),
              section(s.cmActLiked, liked),
              section(s.cmActUpvoted, upvoted),
            ],
          );
        },
      ),
    );
  }
}

class MyBookmarksScreen extends StatelessWidget {
  const MyBookmarksScreen({super.key, required this.controller});
  final PregnancyController controller;
  @override
  Widget build(BuildContext context) {
    final lang = controller.language;
    final s = S(lang);
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(title: Text(s.cmMyBookmarks)),
      body: AnimatedBuilder(
        animation: CommunityStore.instance,
        builder: (context, _) {
          final saved = CommunityStore.instance.savedPosts;
          if (saved.isEmpty) {
            return _emptyState(
                context, Icons.bookmark_border_rounded, s.cmBookmarksEmpty);
          }
          return ListView(
            padding: const EdgeInsets.only(top: 8, bottom: 28),
            children: [
              for (final p in saved)
                CommunityPostCard(
                  post: p,
                  lang: lang,
                  controller: controller,
                  onTap: () => _push(
                      context, PostDetailScreen(post: p, controller: controller)),
                ),
            ],
          );
        },
      ),
    );
  }
}

Widget _emptyState(BuildContext context, IconData icon, String msg) {
  final text = Theme.of(context).textTheme;
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(40),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 52, color: AppTheme.neutral300),
        const SizedBox(height: 16),
        Text(msg,
            textAlign: TextAlign.center,
            style: text.bodyMedium
                ?.copyWith(color: AppTheme.neutral500, height: 1.4)),
      ]),
    ),
  );
}

// ===========================================================================
//  Search
// ===========================================================================

class _CommunitySearchDelegate extends SearchDelegate<void> {
  _CommunitySearchDelegate(this.lang, this.controller);
  final AppLanguage lang;
  final PregnancyController controller;

  @override
  List<Widget> buildActions(BuildContext context) => [
        if (query.isNotEmpty)
          IconButton(icon: const Icon(Icons.clear_rounded), onPressed: () => query = ''),
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) => _results(context);
  @override
  Widget buildSuggestions(BuildContext context) => _results(context);

  Widget _results(BuildContext context) {
    final q = query.trim().toLowerCase();
    final text = Theme.of(context).textTheme;
    if (q.isEmpty) return const SizedBox.shrink();
    final comms = kCommunities
        .where((c) =>
            c.name.toLowerCase().contains(q) ||
            c.topics.any((t) => t.toLowerCase().contains(q)))
        .toList();
    final posts = CommunityStore.instance
        .feed()
        .where((p) =>
            p.text.toLowerCase().contains(q) ||
            p.author.toLowerCase().contains(q) ||
            p.topics.any((t) => t.toLowerCase().contains(q)))
        .toList();
    return ListView(
      children: [
        for (final c in comms)
          ListTile(
            leading: Text(c.emoji, style: const TextStyle(fontSize: 22)),
            title: Text(c.name),
            subtitle: Text(S(lang).cmMembers(c.members),
                style: text.labelSmall?.copyWith(color: AppTheme.neutral500)),
            onTap: () {
              close(context, null);
              _push(context, CommunityDetailScreen(community: c, controller: controller));
            },
          ),
        for (final p in posts)
          ListTile(
            leading: const Icon(Icons.mode_comment_outlined),
            title: Text(p.text, maxLines: 2, overflow: TextOverflow.ellipsis),
            onTap: () {
              close(context, null);
              _push(context, PostDetailScreen(post: p, controller: controller));
            },
          ),
      ],
    );
  }
}
