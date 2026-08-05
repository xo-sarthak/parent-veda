// =============================================================================
//  Birth Club — the second growth mechanic
// -----------------------------------------------------------------------------
//  Mothers due the same month are the most useful people a pregnant woman can
//  talk to: the same questions, the same week, at the same time. So the referral
//  system has a second shape — invite mothers due when you are due — and an
//  invited friend lands in the same club automatically.
//
//  Milestone progression (1 -> 3 -> 5 invites) unlocks things that are worth
//  having and cost us nothing to give: a private discussion, an expert Q&A, a
//  badge. Deliberately NOT discounts — this mechanic is about belonging, and
//  paying people to recruit their friends produces recruiters, not communities.
// =============================================================================

import 'package:flutter/material.dart';

import '../../referral/referral_analytics.dart';
import '../../referral/referral_engine.dart';
import '../../referral/referral_store.dart';
import '../../services/pregnancy_controller.dart';
import '../post_pregnancy/pp_common.dart';
import '../../referral/birth_club_store.dart';
import '../../referral/referral_notifications.dart';
import 'reward_celebration.dart';
import 'invite_friends_screen.dart';
import '../../localization/app_language.dart';

/// The ladder. Reached by inviting mothers who actually join.
class ClubMilestone {
  const ClubMilestone(this.invites, this.title, this.body, this.icon);
  final int invites;
  final String title;
  final String body;
  final IconData icon;
}

const List<ClubMilestone> kClubMilestones = [
  ClubMilestone(1, 'Your club discussion',
      'A private thread for mothers due the same month as you.',
      Icons.forum_outlined),
  ClubMilestone(3, 'Expert Q&A',
      'A monthly session where your club puts questions to a specialist.',
      Icons.record_voice_over_outlined),
  ClubMilestone(5, 'Founding member badge',
      'Shown beside your name in the club you helped build.',
      Icons.workspace_premium_outlined),
];

class BirthClubScreen extends StatefulWidget {
  const BirthClubScreen({super.key, this.controller});

  /// Supplies the due date. Null in tests and before a date is set.
  final PregnancyController? controller;

  @override
  State<BirthClubScreen> createState() => _BirthClubScreenState();
}

class _BirthClubScreenState extends State<BirthClubScreen> {
  final _store = ReferralStore.instance;

  @override
  void initState() {
    super.initState();
    _store.init();
    BirthClubStore.instance.init().then((_) => _evaluate());
  }

  /// Grant anything she has earned but not yet been given, and celebrate only
  /// what is NEW. Runs after the first frame so a sheet is never pushed during
  /// build.
  Future<void> _evaluate() async {
    final club = _clubKey;
    if (club == null || !mounted) return;
    final newly = BirthClubStore.instance
        .evaluate(club: club, joined: _store.friendsJoined);
    if (newly.isEmpty || !mounted) return;

    for (final rung in newly) {
      final m = kClubMilestones.firstWhere((x) => x.invites == rung,
          orElse: () => kClubMilestones.first);
      await ReferralNotifications.instance
          .clubUnlocked(club: club, rung: rung, what: m.title);
      if (!mounted) return;
      await showRewardCelebration(
        context,
        title: m.title,
        body: m.body,
        footnote: 'Unlocked by inviting $rung '
            '${rung == 1 ? 'mother' : 'mothers'} who joined.',
        icon: m.icon,
      );
      if (!mounted) return;
    }
    setState(() {});
  }

  DateTime? get _due {
    final c = widget.controller;
    if (c == null) return null;
    return c.isDueDateSet ? c.dueDate : null;
  }

  String? get _clubKey {
    final d = _due;
    return d == null ? null : ReferralEngine.birthClubFor(d);
  }

  /// Only friends who actually joined count toward the ladder. Counting shares
  /// would let anyone unlock everything by pressing a button five times.
  int get _joined => _store.friendsJoined;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _store,
      builder: (context, _) {
        final key = _clubKey;
        return Scaffold(
          backgroundColor: ppBg,
          appBar: AppBar(
            backgroundColor: ppBg,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            title: Text(S.now.uiBirthClub, style: ppJakarta(16)),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
            children: [
              if (key == null) _noDueDate() else ..._club(key),
            ],
          ),
        );
      },
    );
  }

  Widget _noDueDate() => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ppBorder),
        ),
        child: Column(children: [
          const Icon(Icons.event_outlined, size: 26, color: ppMuted),
          const SizedBox(height: 12),
          Text(S.now.uiSetDueDateFirst, style: ppJakarta(14)),
          const SizedBox(height: 6),
          Text(
            'Your Birth Club is the group of mothers due the same month as you, '
            'so we need your date before we can put you in one.',
            textAlign: TextAlign.center,
            style: ppBody(12.5, h: 1.5),
          ),
        ]),
      );

  List<Widget> _club(String key) => [
        ppEyebrow('YOUR BIRTH CLUB', color: ppPurple),
        const SizedBox(height: 8),
        Text(ReferralEngine.birthClubLabel(key), style: ppFraunces(27, h: 1.1)),
        const SizedBox(height: 8),
        Text(
          'Mothers due the same month as you — the same questions, the same '
          'week, at the same time. Invite the friends you know are due around '
          'now and they join your club automatically.',
          style: ppBody(13.5, h: 1.55),
        ),
        const SizedBox(height: 12),
        // The 5-invite rung recorded a flag nothing read. It is now visible
        // where it means something: on her own club.
        if (BirthClubStore.instance.isFoundingMember(key))
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: ppPurple.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: ppPurple.withValues(alpha: 0.25)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.workspace_premium_rounded,
                      size: 14, color: ppPurple),
                  const SizedBox(width: 6),
                  Text(S.now.uiFoundingMember,
                      style: ppJakarta(11, color: ppPurple)),
                ]),
              ),
            ]),
          ),
        const SizedBox(height: 12),
        _progress(),
        // The 3-invite rung likewise. Gated on qaOpen so it appears only once
        // she has actually earned it, rather than being a locked tease.
        if (BirthClubStore.instance.qaOpen(key)) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: ppPurple.withValues(alpha: 0.3)),
            ),
            child: Row(children: [
              const Icon(Icons.record_voice_over_rounded,
                  size: 19, color: ppPurple),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(S.now.uiExpertQOpen, style: ppJakarta(13.5)),
                      const SizedBox(height: 2),
                      Text(S.now.uiClubPutsQuestionsSpecialist,
                          style: ppBody(11.5, h: 1.4)),
                    ]),
              ),
            ]),
          ),
        ],
        const SizedBox(height: 22),
        Text(S.now.uiWhatUnlock, style: ppJakarta(15)),
        const SizedBox(height: 12),
        for (final m in kClubMilestones) _milestone(m),
        const SizedBox(height: 18),
        GestureDetector(
          onTap: () {
            ReferralAnalytics.birthClubJoined();
            Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (_) => const InviteFriendsScreen()));
          },
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: ppPurple, borderRadius: BorderRadius.circular(15)),
            child: Text('Invite mothers due in ${_monthName(key)}',
                style: ppJakarta(14, color: Colors.white)),
          ),
        ),
      ];

  static String _monthName(String key) =>
      ReferralEngine.birthClubLabel(key).split(' ').first;

  Widget _progress() {
    final next = kClubMilestones.firstWhere((m) => m.invites > _joined,
        orElse: () => kClubMilestones.last);
    final target = next.invites;
    final pct = target == 0 ? 1.0 : (_joined / target).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ppBorder),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('$_joined joined', style: ppJakarta(14)),
          const Spacer(),
          Text(
              _joined >= kClubMilestones.last.invites
                  ? 'All unlocked'
                  : '${target - _joined} more to go',
              style: ppBody(12, color: ppSoft)),
        ]),
        const SizedBox(height: 11),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 7,
            backgroundColor: ppHair,
            valueColor: const AlwaysStoppedAnimation(ppPurple),
          ),
        ),
      ]),
    );
  }

  Widget _milestone(ClubMilestone m) {
    // Read the STORE, not the live count: an unlock is permanent once given,
    // so a later blocked invite cannot take back something she already has.
    final club = _clubKey;
    final unlocked = club != null &&
        (BirthClubStore.instance.hasUnlocked(club, m.invites) ||
            _joined >= m.invites);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: unlocked ? ppPurple : ppBorder),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(unlocked ? Icons.check_circle_rounded : m.icon,
              size: 20, color: unlocked ? ppPurple : ppMuted),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Flexible(child: Text(m.title, style: ppJakarta(13.5))),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                          color: unlocked ? ppPanel : ppHair,
                          borderRadius: BorderRadius.circular(6)),
                      child: Text('${m.invites}',
                          style: ppJakarta(10,
                              color: unlocked ? ppPurple : ppSoft)),
                    ),
                  ]),
                  const SizedBox(height: 3),
                  Text(m.body, style: ppBody(11.5, h: 1.45)),
                ]),
          ),
        ]),
      ),
    );
  }
}
