// =============================================================================
//  Invite Friends — the referral home
// -----------------------------------------------------------------------------
//  One screen, three jobs: share the code, see what happened to the invites
//  already sent, and understand what is actually earned. It has to survive a
//  mother reading it at 3 a.m., so every number is plain and every status says
//  what is being waited on rather than just "pending".
//
//  The CODE is the hero, not the link. Firebase Dynamic Links died in August
//  2025, and a code survives being screenshotted, read aloud down a phone, or
//  pasted into a WhatsApp group - which is how invitations actually travel here.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../referral/referral_analytics.dart';
import '../../referral/referral_engine.dart';
import '../../referral/referral_models.dart';
import '../../referral/referral_store.dart';
import '../../services/pregnancy_controller.dart';
import '../post_pregnancy/pp_common.dart';
import 'birth_club_screen.dart';
import 'reward_celebration.dart';

class InviteFriendsScreen extends StatefulWidget {
  const InviteFriendsScreen({super.key, this.controller});

  /// Supplies the due date for the Birth Club. Null is fine - that screen then
  /// asks her to set one rather than guessing a cohort.
  final PregnancyController? controller;

  @override
  State<InviteFriendsScreen> createState() => _InviteFriendsScreenState();
}

class _InviteFriendsScreenState extends State<InviteFriendsScreen> {
  final _store = ReferralStore.instance;

  @override
  void initState() {
    super.initState();
    _store.init().then((_) async {
      await _store.syncToServer();
      ReferralAnalytics.opened();
      if (!mounted) return;
      // Celebrate anything that landed while she was away — once each.
      for (final label in _store.takeFreshRewards()) {
        if (!mounted) return;
        await showRewardCelebration(
          context,
          title: 'You earned $label',
          body: 'A friend you invited finished setting up. It is in your '
              'account, ready whenever you need it.',
          footnote: 'Spend it on a consultation with any ParentVeda expert.',
        );
      }
    });
  }

  void _toast(String m) => ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(SnackBar(content: Text(m)));

  Future<void> _share(String channel) async {
    final problem = _store.invitingProblem;
    if (problem != null) {
      _toast(problem);
      return;
    }
    final reward = _store.config.inviteeReward.label;
    final text = 'I am using ParentVeda through my pregnancy — it has been '
        'genuinely useful. Join with my code ${_store.code} and you get '
        '$reward to start with.\n\n${_store.link}';

    _store.recordShare(channel: channel);
    ReferralAnalytics.shared(channel);

    if (channel == 'copy') {
      await Clipboard.setData(ClipboardData(text: text));
      if (mounted) _toast('Invite copied. Paste it wherever you like.');
      return;
    }
    await Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _store,
      builder: (context, _) {
        if (!_store.isLoaded) {
          return const Scaffold(
            backgroundColor: ppBg,
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return Scaffold(
          backgroundColor: ppBg,
          appBar: AppBar(
            backgroundColor: ppBg,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            title: Text('Invite friends', style: ppJakarta(16)),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
            children: [
              _hero(),
              const SizedBox(height: 18),
              _codeCard(),
              const SizedBox(height: 14),
              _shareRow(),
              const SizedBox(height: 22),
              // BIRTH CLUB. The second growth mechanic had no entry point at
              // all - the screen existed and nothing opened it.
              _birthClubRow(),
              const SizedBox(height: 26),
              _stats(),
              const SizedBox(height: 26),
              _inviteList(),
            ],
          ),
        );
      },
    );
  }

  Widget _hero() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ppEyebrow('BOTH OF YOU GET SOMETHING', color: ppPurple),
        const SizedBox(height: 8),
        Text('Going through this with\na friend makes it easier',
            style: ppFraunces(26, h: 1.15)),
        const SizedBox(height: 8),
        Text(
          'Share your code. When she joins and finishes setting up, you both '
          'get ${_store.config.inviterReward.label.toLowerCase()}.',
          style: ppBody(13.5, h: 1.55),
        ),
      ]);

  Widget _codeCard() => Container(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF3EEF7), Color(0xFFEDE6F6)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: ppPanelDiv),
        ),
        child: Column(children: [
          Text('YOUR CODE',
              style: ppJakarta(10.5, color: ppSoft)),
          const SizedBox(height: 10),
          Text(
            _store.code,
            style: ppFraunces(34, h: 1.05).copyWith(letterSpacing: 4),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () async {
              await Clipboard.setData(ClipboardData(text: _store.code));
              if (mounted) _toast('Code copied');
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(11)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.copy_rounded, size: 14, color: ppPurple),
                const SizedBox(width: 7),
                Text('Copy code', style: ppJakarta(12, color: ppPurple)),
              ]),
            ),
          ),
        ]),
      );

  Widget _shareRow() => Row(children: [
        Expanded(
          child: _shareButton('Share', Icons.ios_share_rounded,
              filled: true, onTap: () => _share('share_sheet')),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _shareButton('Copy link', Icons.link_rounded,
              onTap: () => _share('copy')),
        ),
      ]);

  Widget _shareButton(String label, IconData icon,
          {required VoidCallback onTap, bool filled = false}) =>
      GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: filled ? ppPurple : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: filled ? ppPurple : ppBorder),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 16, color: filled ? Colors.white : ppPurple),
            const SizedBox(width: 8),
            Text(label,
                style:
                    ppJakarta(13, color: filled ? Colors.white : ppPurple)),
          ]),
        ),
      );

  Widget _birthClubRow() => GestureDetector(
        onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (_) => BirthClubScreen(controller: widget.controller))),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: ppBorder),
          ),
          child: Row(children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: ppPanel, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.groups_2_outlined,
                  size: 19, color: ppPurple),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your Birth Club', style: ppJakarta(13.5)),
                    const SizedBox(height: 2),
                    Text('Invite mothers due the same month as you.',
                        style: ppBody(11.5, h: 1.4)),
                  ]),
            ),
            const Icon(Icons.chevron_right_rounded, size: 20, color: ppMuted),
          ]),
        ),
      );

  Widget _stats() => Row(children: [
        _stat('${_store.totalInvites}', 'Invites sent'),
        const SizedBox(width: 10),
        _stat('${_store.friendsJoined}', 'Friends joined'),
        const SizedBox(width: 10),
        _stat('${_store.rewardsEarned}', 'Rewards earned'),
      ]);

  Widget _stat(String value, String label) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: ppBorder),
          ),
          child: Column(children: [
            Text(value, style: ppFraunces(22, h: 1)),
            const SizedBox(height: 4),
            Text(label,
                textAlign: TextAlign.center, style: ppBody(11, color: ppSoft)),
          ]),
        ),
      );

  Widget _inviteList() {
    if (_store.invites.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ppBorder),
        ),
        child: Column(children: [
          const Icon(Icons.favorite_border_rounded, size: 24, color: ppMuted),
          const SizedBox(height: 10),
          Text('No invites yet', style: ppJakarta(13.5)),
          const SizedBox(height: 4),
          Text(
            'Think of one friend who is pregnant too. That is usually all it takes.',
            textAlign: TextAlign.center,
            style: ppBody(12, h: 1.45),
          ),
        ]),
      );
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Your invites', style: ppJakarta(15)),
      const SizedBox(height: 12),
      for (final i in _store.invites) _inviteRow(i),
    ]);
  }

  Widget _inviteRow(Invite i) {
    final (colour, icon) = switch (i.status) {
      InviteStatus.credited => (const Color(0xFF3E7A5E), Icons.check_circle_rounded),
      InviteStatus.qualified => (ppPurple, Icons.card_giftcard_rounded),
      InviteStatus.blocked => (ppCoral, Icons.block_rounded),
      _ => (ppMuted, Icons.schedule_rounded),
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ppBorder),
        ),
        child: Row(children: [
          Icon(icon, size: 18, color: colour),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(i.displayName, style: ppJakarta(13.5)),
                  const SizedBox(height: 2),
                  Text(
                    i.blockedReason ?? i.status.label,
                    style: ppBody(11.5, color: colour),
                  ),
                ]),
          ),
          if (i.dueMonth != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                  color: ppPanel, borderRadius: BorderRadius.circular(7)),
              child: Text(ReferralEngine.birthClubLabel(i.dueMonth!)
                      .replaceAll(' Birth Club', ''),
                  style: ppBody(10, color: ppSoft)),
            ),
        ]),
      ),
    );
  }
}
