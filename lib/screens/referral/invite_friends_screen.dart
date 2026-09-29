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
//
//  ---------------------------------------------------------------------------
//  REDESIGNED ON THE BASE UI, 2026-09-29. The user, from the TTC More tab:
//  "look at that screen. That's hideous. That's the screen we used to have way
//  before; it was never changed." It was the parenting look: the lilac `ppBg`
//  ground, a violet eyebrow, a lilac gradient code card, a violet Share
//  button beside a violet-outlined one, boxed stat tiles and boxed invite rows
//  with coloured status icons.
//
//  THE ANATOMY, from Mobbin (2026-09-29), in the order a referral page is read:
//   1. A DRAWN OBJECT ABOVE A ONE-LINE PROMISE, centred. TheFork (a coin, "Share
//      your code with a friend", the code in a bordered field with COPY)
//      https://mobbin.com/screens/4d150cbe-8a99-4faa-bc52-8f75ec8c9c33 ;
//      Tolan (a gift, a two-line title, "you both get", Copy beside the field,
//      one wide Share button) https://mobbin.com/screens/072e5097-be0a-4b76-9537-a082244816b7 ;
//      Duolingo (a drawn scene, "Invite your friends", one line)
//      https://mobbin.com/flows/223b066b-098f-4714-841e-d7bb0641606b ;
//      CRED (one mark, a serif line, a quiet sub, one outlined action)
//      https://mobbin.com/screens/122fc8d1-725b-41fc-80aa-660b6ed162a6 .
//   2. THE CODE IN A QUIET BORDERED FIELD WITH COPY INSIDE IT: Airalo ("Your
//      referral code" field with a copy mark)
//      https://mobbin.com/screens/0cf8f3e5-17af-46a4-90ee-f54b31a7ea8d ;
//      Cal AI (the code field above a black Share pill)
//      https://mobbin.com/screens/568e92e9-4034-4e86-ac4a-f375b8cd19f0 .
//   3. HOW IT WORKS IN THREE NUMBERED STEPS: N26 ("Your friend just needs to",
//      1 2 3) https://mobbin.com/screens/33f87f46-bec3-47d9-8b08-f8fa372af26c ;
//      Airbnb ("How it works", three rows, a copied confirmation that floats)
//      https://mobbin.com/screens/47feb5c5-12c1-4928-943b-c831f2dee72e .
//   4. ONE PRIMARY SHARE BUTTON, PINNED AT THE FOOT: Tolan, Cal AI, Greg
//      https://mobbin.com/screens/279b1f4a-d577-420f-b77e-5042a4c19436 . The
//      system share sheet, because on an Indian phone WhatsApp is its first
//      row; Revolut and Mimo put WhatsApp first for the same reason
//      https://mobbin.com/screens/46527950-ca98-4a61-be16-02396692b905
//      https://mobbin.com/screens/4f040645-3a8c-46fd-8408-1f8e38d8da6f .
//   5. PROGRESS UNDERNEATH, AS PLAIN NUMBERS: Airalo "Your progress", Tolan
//      "Friends joined 0" on a hairline row.
//
//  WHAT WAS NOT TAKEN: every one of them spends a brand colour on the button
//  and a stock 3D gift on the hero. Ours is the one ink button
//  (#2F2C30, the switches' black) and a drawn mark from our own family: the
//  big-and-small hearts the More row already wears (`TtcTabArt`), in the
//  Benefits section's tint, so the page opens on the object she tapped.
//
//  WHAT IS KEPT, ALL OF IT: the store, the code, the copy of the code, the
//  copy of the whole invite ("Copy link", now a quiet line under the code),
//  the share sheet, `recordShare` and the analytics on both, the inviting
//  limits (`invitingProblem`), the reward celebration on open, the Birth
//  Club door, the three counts, and the invite list with each status.
//
//  ⚠️ HONESTY: the reward words are the config's, exactly as before ("you both
//  get a free consultation"); the server grants it (0035) when the friend
//  finishes onboarding. Nothing here promises more than that sentence did.
//
//  ⚠️ TRYING TO CONCEIVE (branch on the stage, the screen is shared): the
//  shared invite text says "through my pregnancy", which is false for her and
//  would tell the person she sends it to something she may not want known.
//  On the TTC stage the message says neither. The Birth Club door asks for a
//  due date, which she has not got, so it is left off her page; the empty
//  line asks her to think of a friend who is trying, not one who is pregnant.
// =============================================================================

import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../referral/referral_analytics.dart';
import '../../referral/referral_engine.dart';
import '../../referral/referral_models.dart';
import '../../referral/referral_store.dart';
import '../../services/life_stage_store.dart';
import '../../services/pregnancy_controller.dart';
import '../../theme/app_theme.dart';
import '../../theme/pv_fonts.dart';
import '../products/pv_store_chrome.dart' show pvSnack;
import '../ttc/doors/ttc_tab_art.dart';
import '../v2/v2_palette.dart';
import 'birth_club_screen.dart';
import 'reward_celebration.dart';
import '../../localization/app_language.dart';

/// The one button's label. Tests and the screen reader read it.
const String kInviteShareLabel = 'Share invite';

/// The Copy control's label.
const String kInviteCopyLabel = 'Copy';

/// The quiet line that copies the whole invite message (was "Copy link").
const String kInviteCopyMessageLabel = 'Copy the whole invite message';

/// The ink of the one button: the switches' black (AppTheme.neutral900).
const Color kInviteInk = AppTheme.neutral900;

/// The hue of the More tab's Benefits section, where "Invite a friend" sits.
const double _kInviteHue = 20;

/// Card hairline, 0x1F on white (the base UI's White ground spec).
const Color _kLine = Color(0x1F000000);

/// How far the confirmation floats: above the pinned Share bar.
const double _kBarClearance = 84;

/// What a share does with the invite text. The system share sheet in the app;
/// a test passes a fake so it can see the call without a platform channel.
typedef InviteShareAction = Future<void> Function(String text);

class InviteFriendsScreen extends StatefulWidget {
  const InviteFriendsScreen({super.key, this.controller, this.shareAction});

  /// Supplies the due date for the Birth Club. Null is fine - that screen then
  /// asks her to set one rather than guessing a cohort.
  final PregnancyController? controller;

  /// Null means the system share sheet (`Share.share`). Only tests pass one.
  final InviteShareAction? shareAction;

  @override
  State<InviteFriendsScreen> createState() => _InviteFriendsScreenState();
}

class _InviteFriendsScreenState extends State<InviteFriendsScreen> {
  final _store = ReferralStore.instance;

  bool get _trying => LifeStageStore.instance.isTrying;

  V2Palette get _p => V2PaletteStore.instance.current;
  Color get _tint => v2BlockTint(_kInviteHue, _p);

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
          title: S.now.rewardEarnedTitle(label),
          body: S.now.rewardEarnedBody,
          footnote: S.now.rewardEarnedFootnote,
        );
      }
    });
  }

  // Kept for revert (2026-09-29): the Material snackbar.
  // void _toast(String m) => ScaffoldMessenger.of(context)
  //   ..clearSnackBars()
  //   ..showSnackBar(SnackBar(content: Text(m)));
  // Now the app's own notice (white, lifted, ink words), floated above the
  // pinned Share bar so it never sits on top of the one button.
  void _toast(String m, {bool done = false}) => pvSnack(
    context,
    m,
    lift: _kBarClearance,
    icon: done ? Icons.check_rounded : null,
  );

  /// The invite message. The shared string everywhere but Trying to conceive,
  /// where "through my pregnancy" would be untrue (see the header).
  String _shareText() {
    final reward = _store.config.inviteeReward.label;
    if (_trying) {
      return 'I have been using ParentVeda and it has been genuinely useful. '
          // "a free consultation" (2026-09-29). Kept for revert: $reward.
          'Join with my code ${_store.code} and you get '
          '${pvRewardPhrase(reward)} to start '
          'with.\n\n${_store.link}';
    }
    return S.now.inviteShareText(_store.code, reward, _store.link);
  }

  Future<void> _share(String channel) async {
    final problem = _store.invitingProblem;
    if (problem != null) {
      _toast(problem);
      return;
    }
    // Kept for revert (2026-09-29):
    // final reward = _store.config.inviteeReward.label;
    // final text = S.now.inviteShareText(_store.code, reward, _store.link);
    final text = _shareText();

    _store.recordShare(channel: channel);
    ReferralAnalytics.shared(channel);

    if (channel == 'copy') {
      await Clipboard.setData(ClipboardData(text: text));
      if (mounted) _toast(S.now.inviteCopied, done: true);
      return;
    }
    final act = widget.shareAction;
    if (act != null) {
      await act(text);
    } else {
      await Share.share(text);
    }
  }

  Future<void> _copyCode() async {
    await Clipboard.setData(ClipboardData(text: _store.code));
    if (mounted) _toast('Code copied', done: true);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _store,
      builder: (context, _) {
        if (!_store.isLoaded) {
          return const Scaffold(
            // Kept for revert (2026-09-29): backgroundColor: ppBg,
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator(color: kInviteInk)),
          );
        }
        return Scaffold(
          // Kept for revert (2026-09-29): backgroundColor: ppBg,
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            scrolledUnderElevation: 0,
            elevation: 0,
            foregroundColor: kInviteInk,
            iconTheme: const IconThemeData(color: kInviteInk),
            // Kept for revert (2026-09-29):
            // title: Text(S.now.uiInviteFriends, style: ppJakarta(16)),
            title: Text(
              S.now.uiInviteFriends,
              style: pvManrope(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _p.ink1,
              ),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView(
                  key: const ValueKey('invite_scroll'),
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  children: [
                    _hero(),
                    const SizedBox(height: 26),
                    _codeField(),
                    const SizedBox(height: 4),
                    _copyMessageLink(),
                    const SizedBox(height: 26),
                    _howItWorks(),
                    // BIRTH CLUB. The second growth mechanic had no entry point
                    // at all - the screen existed and nothing opened it. Not on
                    // Trying to conceive: it is a due-date cohort.
                    if (!_trying) ...[
                      const SizedBox(height: 22),
                      _birthClubRow(),
                    ],
                    const SizedBox(height: 30),
                    _progress(),
                  ],
                ),
              ),
              _shareBar(),
            ],
          ),
        );
      },
    );
  }

  // ---- the parts -------------------------------------------------------------

  Widget _hero() {
    // The title carries a hand-placed line break for a phone at 1x. At large
    // text it strands a word ("with") on a line of its own, so there the
    // break gives way and the words wrap on their own.
    final big = MediaQuery.textScalerOf(context).scale(10) / 10 > 1.3;
    final title = big
        ? S.now.uiGoingThroughNaFriend.replaceAll('\n', ' ')
        : S.now.uiGoingThroughNaFriend;
    return Column(
      children: [
        SizedBox(
          width: 96,
          height: 96,
          child: TtcTabArt(mark: TtcTabMark.bigSmallHearts, tint: _tint),
        ),
        const SizedBox(height: 18),
        Semantics(
          header: true,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: pvFraunces(
              fontSize: 25,
              fontWeight: FontWeight.w500,
              height: 1.2,
              color: _p.ink1,
            ),
          ),
        ),
        const SizedBox(height: 10),
        // The reward sentence, word for word as before.
        Text(
          'Share your code. When she joins and finishes setting up, you both '
          // "a free consultation", not "free consultation" (2026-09-29):
          // the config label carries no article. Kept for revert:
          // 'get ${_store.config.inviterReward.label.toLowerCase()}.',
          'get ${pvRewardPhrase(_store.config.inviterReward.label)}.',
          textAlign: TextAlign.center,
          style: pvManrope(fontSize: 14.5, height: 1.5, color: _p.ink2),
        ),
      ],
    );
  }

  /// The code in a quiet bordered white field, Copy inside it. At large text
  /// the Copy pill drops under the code so the code keeps its width.
  Widget _codeField() {
    final big = MediaQuery.textScalerOf(context).scale(10) / 10 > 1.3;
    final code = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.now.uiCode,
          style: pvManrope(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
            color: _p.ink3,
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            _store.code,
            key: const ValueKey('invite_code'),
            style: pvFraunces(
              fontSize: 26,
              fontWeight: FontWeight.w500,
              height: 1.1,
              color: _p.ink1,
            ).copyWith(letterSpacing: 3),
          ),
        ),
      ],
    );
    final copy = _CopyPill(onTap: _copyCode, code: _store.code);
    return Container(
      key: const ValueKey('invite_code_field'),
      padding: const EdgeInsets.fromLTRB(18, 14, 12, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kLine),
      ),
      child: big
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [code, const SizedBox(height: 10), copy],
            )
          : Row(
              children: [
                Expanded(child: code),
                const SizedBox(width: 10),
                copy,
              ],
            ),
    );
  }

  /// Was the "Copy link" button beside Share: it copies the whole invite
  /// message (code, reward and link), records the share and counts it.
  Widget _copyMessageLink() => Align(
    alignment: Alignment.centerLeft,
    child: Semantics(
      button: true,
      container: true,
      excludeSemantics: true,
      label: kInviteCopyMessageLabel,
      onTap: () => _share('copy'),
      child: InkWell(
        key: const ValueKey('invite_copy_message'),
        onTap: () => _share('copy'),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 12, 8, 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.link_rounded, size: 18, color: _p.ink1),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  kInviteCopyMessageLabel,
                  style: pvManrope(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: _p.ink1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _heading(String text) => Semantics(
    header: true,
    child: Text(
      text,
      style: pvFraunces(
        fontSize: 21,
        fontWeight: FontWeight.w500,
        height: 1.15,
        color: _p.ink1,
      ),
    ),
  );

  Widget _howItWorks() {
    // The config's own label, as a title ("Free consultation for both of
    // you"): lower-cased after "get" it lost its article.
    final reward = _store.config.inviterReward.label;
    final steps = <(String, String)>[
      (
        'Share your code',
        'Send it on WhatsApp or anywhere else, or read it out. It works either way.',
      ),
      (
        'She joins with your code',
        'She types your code when she signs up to ParentVeda.',
      ),
      (
        '$reward for both of you',
        'When she finishes setting up, it is added to both of your accounts.',
      ),
    ];
    return Column(
      key: const ValueKey('invite_how_it_works'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading('How it works'),
        const SizedBox(height: 14),
        for (var i = 0; i < steps.length; i++) ...[
          if (i > 0) const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _NumberMark(n: i + 1, tint: _tint),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 2),
                    Text(
                      steps[i].$1,
                      style: pvManrope(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                        color: _p.ink1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      steps[i].$2,
                      style: pvManrope(
                        fontSize: 13,
                        height: 1.45,
                        color: _p.ink2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  /// A row on the page between hairlines, the More tab's row shape.
  Widget _birthClubRow() {
    void open() => Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BirthClubScreen(controller: widget.controller),
      ),
    );
    return Container(
      decoration: const BoxDecoration(
        border: Border.symmetric(horizontal: BorderSide(color: _kLine)),
      ),
      child: Semantics(
        button: true,
        container: true,
        excludeSemantics: true,
        label: '${S.now.uiBirthClub2}. ${S.now.uiInviteMothersDueSame}',
        onTap: open,
        child: InkWell(
          onTap: open,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              children: [
                SizedBox(
                  width: 44,
                  height: 44,
                  child: TtcTabArt(mark: TtcTabMark.twoFigures, tint: _tint),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        S.now.uiBirthClub2,
                        style: pvManrope(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: _p.ink1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        S.now.uiInviteMothersDueSame,
                        style: pvManrope(
                          fontSize: 12.5,
                          height: 1.4,
                          color: _p.ink3,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, size: 20, color: _p.ink2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Your invites: the three counts as stat pairs (label small above, the
  /// number large below, DESIGN-SYSTEM §4.10), then each invite as a row.
  Widget _progress() {
    final stats = [
      ('Invites sent', '${_store.totalInvites}'),
      ('Friends joined', '${_store.friendsJoined}'),
      ('Rewards earned', '${_store.rewardsEarned}'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading(S.now.uiInvites),
        const SizedBox(height: 14),
        IntrinsicHeight(
          child: Row(
            children: [
              for (var i = 0; i < stats.length; i++) ...[
                if (i > 0)
                  const VerticalDivider(width: 24, thickness: 1, color: _kLine),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stats[i].$1,
                        style: pvManrope(
                          fontSize: 12,
                          height: 1.3,
                          color: _p.ink3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        stats[i].$2,
                        style: pvFraunces(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          height: 1.05,
                          color: _p.ink1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 18),
        const Divider(height: 1, thickness: 1, color: _kLine),
        if (_store.invites.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.now.uiNoInvitesYet,
                  style: pvManrope(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: _p.ink1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _trying
                      ? 'Think of one friend who is trying too. That is usually all it takes.'
                      : S.now.uiThinkOneFriendWho,
                  style: pvManrope(fontSize: 13, height: 1.45, color: _p.ink2),
                ),
              ],
            ),
          )
        else
          for (final i in _store.invites) _inviteRow(i),
      ],
    );
  }

  Widget _inviteRow(Invite i) {
    // The status is words, in ink; a refusal is said in a readable red. The
    // old coloured icons (green tick, violet gift, coral block, grey clock)
    // are gone: a status is not a control, and colour alone says nothing to
    // a screen reader.
    final blocked = i.status == InviteStatus.blocked;
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _kLine)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  i.displayName,
                  style: pvManrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _p.ink1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  i.blockedReason ?? i.status.label,
                  style: pvManrope(
                    fontSize: 12.5,
                    height: 1.35,
                    color: blocked ? const Color(0xFFB3261E) : _p.ink2,
                  ),
                ),
              ],
            ),
          ),
          if (i.dueMonth != null) ...[
            const SizedBox(width: 10),
            // A tag: the one place a tint may sit behind words.
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: ttcTabGround(_tint),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                ReferralEngine.birthClubLabel(
                  i.dueMonth!,
                ).replaceAll(' Birth Club', ''),
                style: pvManrope(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: _p.ink1,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// The one primary button, pinned above the safe area.
  Widget _shareBar() => Container(
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(top: BorderSide(color: _kLine)),
    ),
    child: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        child: Semantics(
          button: true,
          container: true,
          excludeSemantics: true,
          label: kInviteShareLabel,
          onTap: () => _share('share_sheet'),
          child: Material(
            key: const ValueKey('invite_share_button'),
            color: kInviteInk,
            shape: const StadiumBorder(),
            child: InkWell(
              customBorder: const StadiumBorder(),
              onTap: () => _share('share_sheet'),
              child: SizedBox(
                height: 52,
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.ios_share_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        kInviteShareLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: pvManrope(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  // Kept for revert (2026-09-29): the parenting-look build, from `_hero`
  // to `_inviteRow`, word for word. It used `ppBg`, `ppPurple`, `ppEyebrow`,
  // `ppFraunces`, `ppJakarta`, `ppBody` from ../post_pregnancy/pp_common.dart.
  //
  //   @override
  //   Widget build(BuildContext context) {
  //     return AnimatedBuilder(
  //       animation: _store,
  //       builder: (context, _) {
  //         if (!_store.isLoaded) {
  //           return const Scaffold(
  //             backgroundColor: ppBg,
  //             body: Center(child: CircularProgressIndicator()),
  //           );
  //         }
  //         return Scaffold(
  //           backgroundColor: ppBg,
  //           appBar: AppBar(
  //             backgroundColor: ppBg,
  //             surfaceTintColor: Colors.transparent,
  //             elevation: 0,
  //             title: Text(S.now.uiInviteFriends, style: ppJakarta(16)),
  //           ),
  //           body: ListView(
  //             padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
  //             children: [
  //               _hero(),
  //               const SizedBox(height: 18),
  //               _codeCard(),
  //               const SizedBox(height: 14),
  //               _shareRow(),
  //               const SizedBox(height: 22),
  //               // BIRTH CLUB. The second growth mechanic had no entry point at
  //               // all - the screen existed and nothing opened it.
  //               _birthClubRow(),
  //               const SizedBox(height: 26),
  //               _stats(),
  //               const SizedBox(height: 26),
  //               _inviteList(),
  //             ],
  //           ),
  //         );
  //       },
  //     );
  //   }
  //
  //   Widget _hero() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
  //         ppEyebrow('BOTH OF YOU GET SOMETHING', color: ppPurple),
  //         const SizedBox(height: 8),
  //         Text(S.now.uiGoingThroughNaFriend,
  //             style: ppFraunces(26, h: 1.15)),
  //         const SizedBox(height: 8),
  //         Text(
  //           'Share your code. When she joins and finishes setting up, you both '
  //           'get ${_store.config.inviterReward.label.toLowerCase()}.',
  //           style: ppBody(13.5, h: 1.55),
  //         ),
  //       ]);
  //
  //   Widget _codeCard() => Container(
  //         padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
  //         decoration: BoxDecoration(
  //           gradient: const LinearGradient(
  //             begin: Alignment.topLeft,
  //             end: Alignment.bottomRight,
  //             colors: [Color(0xFFF3EEF7), Color(0xFFEDE6F6)],
  //           ),
  //           borderRadius: BorderRadius.circular(20),
  //           border: Border.all(color: ppPanelDiv),
  //         ),
  //         child: Column(children: [
  //           Text(S.now.uiCode,
  //               style: ppJakarta(10.5, color: ppSoft)),
  //           const SizedBox(height: 10),
  //           Text(
  //             _store.code,
  //             style: ppFraunces(34, h: 1.05).copyWith(letterSpacing: 4),
  //           ),
  //           const SizedBox(height: 14),
  //           GestureDetector(
  //             onTap: () async {
  //               await Clipboard.setData(ClipboardData(text: _store.code));
  //               if (mounted) _toast('Code copied');
  //             },
  //             behavior: HitTestBehavior.opaque,
  //             child: Container(
  //               padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
  //               decoration: BoxDecoration(
  //                   color: Colors.white, borderRadius: BorderRadius.circular(11)),
  //               child: Row(mainAxisSize: MainAxisSize.min, children: [
  //                 const Icon(Icons.copy_rounded, size: 14, color: ppPurple),
  //                 const SizedBox(width: 7),
  //                 Text(S.now.uiCopyCode, style: ppJakarta(12, color: ppPurple)),
  //               ]),
  //             ),
  //           ),
  //         ]),
  //       );
  //
  //   Widget _shareRow() => Row(children: [
  //         Expanded(
  //           child: _shareButton('Share', Icons.ios_share_rounded,
  //               filled: true, onTap: () => _share('share_sheet')),
  //         ),
  //         const SizedBox(width: 10),
  //         Expanded(
  //           child: _shareButton('Copy link', Icons.link_rounded,
  //               onTap: () => _share('copy')),
  //         ),
  //       ]);
  //
  //   Widget _shareButton(String label, IconData icon,
  //           {required VoidCallback onTap, bool filled = false}) =>
  //       GestureDetector(
  //         onTap: onTap,
  //         behavior: HitTestBehavior.opaque,
  //         child: Container(
  //           height: 50,
  //           alignment: Alignment.center,
  //           decoration: BoxDecoration(
  //             color: filled ? ppPurple : Colors.white,
  //             borderRadius: BorderRadius.circular(14),
  //             border: Border.all(color: filled ? ppPurple : ppBorder),
  //           ),
  //           child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
  //             Icon(icon, size: 16, color: filled ? Colors.white : ppPurple),
  //             const SizedBox(width: 8),
  //             Text(label,
  //                 style:
  //                     ppJakarta(13, color: filled ? Colors.white : ppPurple)),
  //           ]),
  //         ),
  //       );
  //
  //   Widget _birthClubRow() => GestureDetector(
  //         onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
  //             builder: (_) => BirthClubScreen(controller: widget.controller))),
  //         behavior: HitTestBehavior.opaque,
  //         child: Container(
  //           padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
  //           decoration: BoxDecoration(
  //             color: Colors.white,
  //             borderRadius: BorderRadius.circular(15),
  //             border: Border.all(color: ppBorder),
  //           ),
  //           child: Row(children: [
  //             Container(
  //               width: 38,
  //               height: 38,
  //               alignment: Alignment.center,
  //               decoration: BoxDecoration(
  //                   color: ppPanel, borderRadius: BorderRadius.circular(12)),
  //               child: const Icon(Icons.groups_2_outlined,
  //                   size: 19, color: ppPurple),
  //             ),
  //             const SizedBox(width: 12),
  //             Expanded(
  //               child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Text(S.now.uiBirthClub2, style: ppJakarta(13.5)),
  //                     const SizedBox(height: 2),
  //                     Text(S.now.uiInviteMothersDueSame,
  //                         style: ppBody(11.5, h: 1.4)),
  //                   ]),
  //             ),
  //             const Icon(Icons.chevron_right_rounded, size: 20, color: ppMuted),
  //           ]),
  //         ),
  //       );
  //
  //   Widget _stats() => Row(children: [
  //         _stat('${_store.totalInvites}', 'Invites sent'),
  //         const SizedBox(width: 10),
  //         _stat('${_store.friendsJoined}', 'Friends joined'),
  //         const SizedBox(width: 10),
  //         _stat('${_store.rewardsEarned}', 'Rewards earned'),
  //       ]);
  //
  //   Widget _stat(String value, String label) => Expanded(
  //         child: Container(
  //           padding: const EdgeInsets.symmetric(vertical: 15),
  //           decoration: BoxDecoration(
  //             color: Colors.white,
  //             borderRadius: BorderRadius.circular(15),
  //             border: Border.all(color: ppBorder),
  //           ),
  //           child: Column(children: [
  //             Text(value, style: ppFraunces(22, h: 1)),
  //             const SizedBox(height: 4),
  //             Text(label,
  //                 textAlign: TextAlign.center, style: ppBody(11, color: ppSoft)),
  //           ]),
  //         ),
  //       );
  //
  //   Widget _inviteList() {
  //     if (_store.invites.isEmpty) {
  //       return Container(
  //         padding: const EdgeInsets.all(20),
  //         decoration: BoxDecoration(
  //           color: Colors.white,
  //           borderRadius: BorderRadius.circular(16),
  //           border: Border.all(color: ppBorder),
  //         ),
  //         child: Column(children: [
  //           const Icon(Icons.favorite_border_rounded, size: 24, color: ppMuted),
  //           const SizedBox(height: 10),
  //           Text(S.now.uiNoInvitesYet, style: ppJakarta(13.5)),
  //           const SizedBox(height: 4),
  //           Text(
  //             S.now.uiThinkOneFriendWho,
  //             textAlign: TextAlign.center,
  //             style: ppBody(12, h: 1.45),
  //           ),
  //         ]),
  //       );
  //     }
  //     return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
  //       Text(S.now.uiInvites, style: ppJakarta(15)),
  //       const SizedBox(height: 12),
  //       for (final i in _store.invites) _inviteRow(i),
  //     ]);
  //   }
  //
  //   Widget _inviteRow(Invite i) {
  //     final (colour, icon) = switch (i.status) {
  //       InviteStatus.credited => (AppTheme.accentGreen, Icons.check_circle_rounded),
  //       InviteStatus.qualified => (ppPurple, Icons.card_giftcard_rounded),
  //       InviteStatus.blocked => (ppCoral, Icons.block_rounded),
  //       _ => (ppMuted, Icons.schedule_rounded),
  //     };
  //     return Padding(
  //       padding: const EdgeInsets.only(bottom: 10),
  //       child: Container(
  //         padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
  //         decoration: BoxDecoration(
  //           color: Colors.white,
  //           borderRadius: BorderRadius.circular(14),
  //           border: Border.all(color: ppBorder),
  //         ),
  //         child: Row(children: [
  //           Icon(icon, size: 18, color: colour),
  //           const SizedBox(width: 12),
  //           Expanded(
  //             child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Text(i.displayName, style: ppJakarta(13.5)),
  //                   const SizedBox(height: 2),
  //                   Text(
  //                     i.blockedReason ?? i.status.label,
  //                     style: ppBody(11.5, color: colour),
  //                   ),
  //                 ]),
  //           ),
  //           if (i.dueMonth != null)
  //             Container(
  //               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  //               decoration: BoxDecoration(
  //                   color: ppPanel, borderRadius: BorderRadius.circular(7)),
  //               child: Text(ReferralEngine.birthClubLabel(i.dueMonth!)
  //                       .replaceAll(' Birth Club', ''),
  //                   style: ppBody(10, color: ppSoft)),
  //             ),
  //         ]),
  //       ),
  //     );
  //   }
}

/// A step number on a small disc in the section's tint: the drawn marks'
/// ground and ink (`ttcTabGround` / `ttcTabInk`), so the steps sit with the
/// hearts above them as one family.
class _NumberMark extends StatelessWidget {
  const _NumberMark({required this.n, required this.tint});

  final int n;
  final Color tint;

  @override
  Widget build(BuildContext context) => Container(
    width: 30,
    height: 30,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: ttcTabGround(tint),
      shape: BoxShape.circle,
    ),
    child: Text(
      '$n',
      textScaler: TextScaler.noScaling,
      style: pvManrope(
        fontSize: 13.5,
        fontWeight: FontWeight.w800,
        color: ttcTabInk(tint),
      ),
    ),
  );
}

/// Copy, inside the code field: an outlined ink pill, the base UI's
/// secondary. The screen reader hears "Copy code".
class _CopyPill extends StatelessWidget {
  const _CopyPill({required this.onTap, required this.code});

  final VoidCallback onTap;
  final String code;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    container: true,
    excludeSemantics: true,
    label: 'Copy code $code',
    onTap: onTap,
    child: InkWell(
      key: const ValueKey('invite_copy_code'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: kInviteInk, width: 1.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.copy_rounded, size: 16, color: kInviteInk),
            const SizedBox(width: 6),
            Text(
              kInviteCopyLabel,
              style: pvManrope(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: kInviteInk,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// A reward label as it reads inside a sentence: lower-cased, with "a" in
/// front when the label has no number or article of its own ("Free
/// consultation" -> "a free consultation"; "1 free consultation" stays).
String pvRewardPhrase(String label) {
  final l = label.trim().toLowerCase();
  if (l.isEmpty) return l;
  if (RegExp(r'^(\d|a |an |the |one |two )').hasMatch(l)) return l;
  return RegExp(r'^[aeiou]').hasMatch(l) ? 'an $l' : 'a $l';
}
