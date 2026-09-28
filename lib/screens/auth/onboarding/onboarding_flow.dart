// =============================================================================
//  OnboardingFlow — the first run, as decided in docs/ONBOARDING-AUDIT.md
// -----------------------------------------------------------------------------
//  Sesame's welcome, Flo's questions, Apple's date, Oura's reveal, Flo's
//  permission ask, our home. Built from the Claude Design "ParentVeda
//  Onboarding" (2026-09-16) plus the question block the audit priced in and the
//  user asked for (2026-09-17): two or three give-back questions per stage,
//  after the date and before the reveal, so the reveal stays the payoff.
//
//  The mother's path, REORDERED 2026-09-22 (docs/ONBOARDING-V2.md):
//      welcome → privacy → who → stage → name → «hello»
//        → [date] → «week» → questions… → «promise» → building
//        → [reveal] → account → reach → home
//  Trying to conceive has no date and no reveal (nothing honest to compute).
//  «…» are BEATS — a whole screen where the app answers back (§1.3).
//
//  ⚠️ THE ACCOUNT MOVED FROM FIRST TO TWELFTH, AND IT IS THE POINT OF THE
//  REWRITE. V1 opened on Google sign-in. Reading fourteen question-led
//  onboarding flows on Mobbin, EVERY ONE of them asks first and signs up last
//  — Flo's first screen is "Are you pregnant?", before anything. The reason is
//  not fashion: a woman who has answered nine questions about her pregnancy
//  has built something she does not want to lose, and that is what makes an
//  account worth creating. BitePal says it on the screen: "Now let's create
//  account — save your progress."
//
//  This costs us nothing structurally because the app is local-first by
//  constitution: the answers live in `FamilyProfileStore` before any session
//  exists, and `PendingProfile` already stashes a profile write that cannot
//  reach the cloud and replays it at the next login. The session simply
//  happens later. Nothing new is written and nothing is written twice.
//  The partner's path leaves at `who` into the old AuthFlowScreen positioned on
//  its pairing branch — those screens are kept as-is (ONBOARDING-AUDIT §4).
//
//  WHAT IT WRITES, AND WHERE (FAMILY-MODEL §4): the session (Google), her name
//  and stage on `profiles`, the due date + DueDateSource on the pregnancy
//  controller, a `children` row for a parent or skilling family, the question
//  answers on FamilyProfileStore, and the reach choices — the OS notification
//  permission and the WhatsApp number, verified through PhoneOtp. Every write
//  is local-first and a cloud failure is never a crash; a profile write that
//  cannot land is stashed by PendingProfile and replayed at the next login,
//  exactly as the old flow did.
//
//  THE REFERRAL. An invite link goes through Play with the code in the install
//  referrer; InstallReferrerService applies it before this screen ever shows.
//  So the welcome screen does not ASK for a code that arrived that way — it
//  says "Invited by a friend · code applied" and shows "Have a code?" only
//  when nothing arrived. Same mechanism, told rather than asked.
//
//  OTP LENGTH: six. Swiggy and Zomato use six, the server issues six, and the
//  partner pairing code is now six too (0082), so the two code sheets are one
//  shape.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../referral/referral_store.dart';
import '../../../services/auth/pending_profile.dart';
import '../../../services/auth/phone_otp.dart';
import '../../../services/auth/social_auth.dart';
import '../../../services/family_profile.dart';
import '../../../services/life_stage_store.dart';
import '../../../services/notification_service.dart';
import '../../../services/pregnancy_controller.dart';
import '../../../services/remote/supabase_repo.dart';
import '../../../services/whatsapp_prefs.dart';
import '../../../theme/pv_fonts.dart';
import '../../../widgets/pv_date_sheet.dart';
import '../../post_pregnancy/pp_child_profile.dart';
import '../../referral/enter_code_sheet.dart';
import '../../skilling/sk_child_store.dart';
import '../../tools/due_date_calculator_screen.dart'
    show DdcMethod, ddcComputeEdd, ddcSourceFor;
import '../../v2/v2_palette.dart';
import '../auth_flow_screen.dart'
    show AuthFlowScreen, kAuthCompletedKey, kUserRoleKey;
import 'onboarding_art.dart';
import 'onboarding_chrome.dart';
import 'onboarding_questions.dart';

/// ⚠️ `hello` IS KEPT AND IS NO LONGER REACHED. It is the V1 name-confirmation
/// screen that followed Google sign-in; the name is now typed at `name` and
/// the beat that follows it is `beatHello`. The value stays because
/// `test/onboarding_flow_test.dart` starts a flow at it and because
/// `OnboardingFlow.startAt` is public API — deleting an enum value that a
/// caller may hold is a crash, renaming it is a silent behaviour change.
enum ObStep {
  welcome,
  privacy,
  hello, // retired — see above
  who,
  stage,
  name,
  beatHello,
  date,
  beatWeek,
  question,
  beatPromise,
  building,
  reveal,
  account,
  reach,
}

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({
    super.key,
    required this.pregnancy,
    required this.onDone,
    this.onDoctor,
    this.startAt = ObStep.welcome,
    this.startName = '',
  });

  final PregnancyController pregnancy;

  /// Test seams: begin past Google sign-in with a name already known. Google
  /// cannot run in a widget test, and every screen after it can.
  final ObStep startAt;
  final String startName;

  /// Fired once everything is written. [stageId] is the persisted id
  /// ('trying' | 'pregnancy' | 'parenting' | 'skilling'); [isFather] when the
  /// partner branch completed instead. The caller routes the home.
  final void Function(String? stageId, bool isFather) onDone;

  /// The doctor entry, unchanged from the old flow.
  final void Function(String expertId)? onDoctor;

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  // ---- what she has told us ---------------------------------------------------
  late String _name = widget.startName;
  String? _stage; // persisted id
  // pregnant
  DdcMethod _method = DdcMethod.lmp;
  DateTime? _methodDate;
  // parent / skilling
  final _childName = TextEditingController();

  /// Her name, as she types it. Seeded from `startName` so a flow resumed
  /// mid-way does not blank what she already gave us.
  late final _nameField = TextEditingController(text: widget.startName);
  DateTime? _childDob;
  int? _childAge;
  bool? _childIsBoy;
  // questions
  final Map<String, Set<String>> _answers = {};
  int _q = 0;
  // reach
  bool _reminders = false;
  bool _whatsapp = false;
  final _phone = TextEditingController();
  bool _phoneVerified = false;
  final _otp = PhoneOtpController();

  // ---- navigation -------------------------------------------------------------
  late final List<ObStep> _history = [widget.startAt];
  ObStep get _step => _history.last;
  bool _busy = false;
  String? _toast;

  List<ObQuestion> get _questions =>
      onboardingQuestionsFor(_stage ?? '', childName: _childName.text);

  @override
  void dispose() {
    _childName.dispose();
    _nameField.dispose();
    _phone.dispose();
    _otp.dispose();
    super.dispose();
  }

  void _go(ObStep s) => setState(() => _history.add(s));

  void _back() {
    if (_history.length <= 1) return;
    setState(() {
      if (_step == ObStep.question && _q > 0) {
        _q--;
      } else {
        _history.removeLast();
      }
    });
  }

  /// After the name beat: the stages that have a date go and get it; trying
  /// has none, so it goes straight on to its questions.
  void _afterHello() {
    if (_stage == 'trying') {
      _afterDate();
    } else {
      _go(ObStep.date);
    }
  }

  /// After the date: a beat, but only where there is something TRUE to say.
  /// Pregnancy gets her week and parenting gets the baby's age; skilling's
  /// "age 7" is not a revelation, so it skips rather than manufacture one.
  void _afterDatePage() {
    if (_stage == 'pregnancy' || _stage == 'parenting') {
      _go(ObStep.beatWeek);
    } else {
      _afterDate();
    }
  }

  /// After the date (or after stage, for trying): questions if the stage has
  /// any, else straight to the reveal / reach.
  void _afterDate() {
    _q = 0;
    if (_questions.isNotEmpty) {
      _go(ObStep.question);
    } else {
      _afterQuestions();
    }
  }

  /// One beat inside the question run, and only one.
  ///
  /// ⚠️ A BEAT AFTER EVERY ANSWER IS A FLOW THAT WILL NOT STOP TALKING. It
  /// lands after the second question and only when a third is still coming,
  /// so it reads as the app pausing mid-conversation rather than as a screen
  /// between her and the end.
  bool _promiseShown = false;

  void _nextQuestion() {
    if (_q + 1 < _questions.length) {
      if (_q == 1 && !_promiseShown) {
        _promiseShown = true;
        _go(ObStep.beatPromise);
      } else {
        setState(() => _q++);
      }
    } else {
      _afterQuestions();
    }
  }

  void _afterQuestions() => _go(ObStep.building);

  /// What `building` does when its work is done. Trying still has no reveal —
  /// there is no week to show and nothing honest to compute.
  void _afterBuilding() {
    if (_stage == 'trying') {
      _go(ObStep.account);
    } else {
      _go(ObStep.reveal);
    }
  }

  void _say(String m) {
    setState(() => _toast = m);
    Future<void>.delayed(const Duration(seconds: 3), () {
      if (mounted && _toast == m) setState(() => _toast = null);
    });
  }

  // ---- build -----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: V2PaletteStore.instance,
      builder: (context, _) {
        final p = V2PaletteStore.instance.current;
        final page = switch (_step) {
          ObStep.welcome => _welcome(p),
          ObStep.privacy => _privacy(p),
          ObStep.hello => _namePage(p), // retired; kept routable, see ObStep
          ObStep.who => _who(p),
          ObStep.stage => _stagePage(p),
          ObStep.name => _namePage(p),
          ObStep.beatHello => _beatHello(p),
          ObStep.date => _date(p),
          ObStep.beatWeek => _beatWeek(p),
          ObStep.question => _question(p),
          ObStep.beatPromise => _beatPromise(p),
          ObStep.building => _building(p),
          ObStep.reveal => _reveal(p),
          ObStep.account => _account(p),
          ObStep.reach => _reach(p),
        };
        return Stack(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween(
                    begin: const Offset(0.04, 0),
                    end: Offset.zero,
                  ).animate(anim),
                  child: child,
                ),
              ),
              child: KeyedSubtree(
                key: ValueKey('${_step.name}-$_q'),
                child: page,
              ),
            ),
            if (_toast != null)
              Positioned(
                left: 24,
                right: 24,
                bottom: 96,
                child: Material(
                  color: p.ink1,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: Text(
                      _toast!,
                      style: pvManrope(fontSize: 13.5, color: p.ground),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  // ---- 01 welcome ---------------------------------------------------------------

  /// 01 · The front door.
  ///
  /// ⚠️ NO SIGN-IN HERE ANY MORE. It moved to `_account`, twelve screens
  /// later — see the file header for why. What is left is the one thing a
  /// first screen should do: say what this is, and open the door.
  Widget _welcome(V2Palette p) {
    final referral = ReferralStore.instance;
    final invited = referral.hasRedeemed;
    return Scaffold(
      backgroundColor: p.ground,
      body: Column(
        children: [
          ObBand(art: ObArt.welcome, p: p, height: 340),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 26, 24, 8),
              children: [
                // ⚠️ THE MARK WAS NOWHERE — the user, 2026-09-22: "a little
                // bit of ParentVeda with the branding is missing". The word
                // was here as a grey 12pt eyebrow, which is how you label a
                // section, not how you introduce a company on the first
                // screen a person ever sees. The mark and the name, at a size
                // that means it.
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: p.surface,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      clipBehavior: Clip.antiAlias,
                      padding: const EdgeInsets.all(3),
                      child: Image.asset(
                        'assets/brand/pv-mark.png',
                        errorBuilder: (_, _, _) => const SizedBox.shrink(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'ParentVeda',
                      style: pvManrope(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                        color: p.ink1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // ⚠️ PLACEHOLDER SOCIAL PROOF — MAKE IT REAL OR REMOVE IT
                // BEFORE THE STORE. The user's call, 2026-09-22, having been
                // told the concern: "let it stay 50k it's fine for now, we
                // wanna see how it would look."
                //
                // The concern, recorded once so it is not lost: this app
                // refuses to draw a distribution bar it cannot measure
                // (`pv_reviews_screen.dart`) and refuses a personalised
                // probability (`ttc_clinical_review_test.dart`). A user count
                // nobody counted sits badly beside both, and it sits on the
                // screen where trust is cheapest to lose. It is fine as a
                // design placeholder and it is not fine shipped.
                // A ListView stretches its children across, so a pill has to
                // be told to hug or it is a full-width bar.
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(10, 6, 14, 6),
                    decoration: BoxDecoration(
                      color: p.surface,
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(color: p.line),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (var i = 0; i < 3; i++)
                          Align(
                            widthFactor: 0.66,
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: v2BlockTint([344.0, 42.0, 268.0][i], p),
                                border: Border.all(
                                  color: p.surface,
                                  width: 1.6,
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(width: 10),
                        // ⚠️ FLEXIBLE, THOUGH IT FITS TODAY. The phone-sized
                        // test caught this overflowing by 44pt, which is a
                        // test-font artefact — flutter_test substitutes a
                        // fixed-width font that measures this string about
                        // twice as wide as Manrope, and on the device it sits
                        // comfortably inside the pill. The guard stays anyway,
                        // because the condition the test simulated by accident
                        // is one a real phone reaches on purpose: a person who
                        // has turned their system font size up.
                        Flexible(
                          child: Text(
                            'Loved by 50,000+ parents',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: pvManrope(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: p.ink2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'For the whole journey — trying, expecting, raising.',
                  style: pvFraunces(
                    fontSize: 29,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.7,
                    height: 1.12,
                    color: p.ink1,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'A few questions first, so the app you open is already yours. '
                  'No account needed to start.',
                  style: pvManrope(fontSize: 15, height: 1.5, color: p.ink2),
                ),
                if (invited) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                    decoration: BoxDecoration(
                      color: p.surfaceAlt,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          size: 18,
                          color: p.ink1,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Invited by a friend · code ${referral.redeemedCode} applied',
                            style: pvManrope(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: p.ink1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ObPrimary(
                    p: p,
                    label: 'Get started',
                    onTap: () => _go(ObStep.privacy),
                  ),
                  const SizedBox(height: 10),
                  // Returning users skip the whole flow: their stage, week and
                  // answers are already on the profile the session restores.
                  ObLink(
                    p: p,
                    label: _busy ? 'Signing in…' : 'I already have an account',
                    onTap: () {
                      if (!_busy) _signInExisting();
                    },
                  ),
                  // Two links and a separator. `Wrap` rather than `Row` for
                  // the same reason as the pill above: they fit on one line
                  // at every normal font size and they should drop to two
                  // rather than clip at a large one.
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      ObLink(p: p, label: "I'm a doctor", onTap: _doctor),
                      if (!invited) ...[
                        Text('·', style: TextStyle(color: p.ink3)),
                        ObLink(p: p, label: 'Have a code?', onTap: _code),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// The returning-user door. A successful sign-in hands straight back to the
  /// app with no stage declared, exactly as the doctor and partner paths do —
  /// her stage is on the profile the session just restored, and re-asking it
  /// here would be the app forgetting her.
  Future<void> _signInExisting() async {
    setState(() => _busy = true);
    final r = await SocialAuth.signIn(SocialProvider.google);
    if (!mounted) return;
    setState(() => _busy = false);
    if (r.cancelled) return;
    if (!r.ok) {
      _say(r.message ?? 'Could not sign in. Try again.');
      return;
    }
    widget.onDone(null, false);
  }

  // ---- 02 privacy ---------------------------------------------------------------

  /// ⚠️ EVERY LINE ON THIS SCREEN HAS TO BE TRUE OF THE CODE, and each of
  /// these is. Local-first is a constitutional rule in CLAUDE.md, not a
  /// marketing line; the delete lives on the You screen; and the only person
  /// who sees her logs is a partner she pairs with herself.
  ///
  /// Flo gives this a whole screen ("Your body. Your data") and for an
  /// India-first family health app holding a due date, a child's name and
  /// symptom logs it earns one — this is one of the few claims we can make
  /// more plainly than a competitor can, because it is how the app is built.
  Widget _privacy(V2Palette p) => Scaffold(
    backgroundColor: p.ground,
    body: Column(
      children: [
        ObBand(art: ObArt.privacy, p: p, height: 300),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 26, 24, 8),
            children: [
              Text(
                'What you tell us stays in your family.',
                style: pvFraunces(
                  fontSize: 27,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.6,
                  height: 1.15,
                  color: p.ink1,
                ),
              ),
              const SizedBox(height: 18),
              _privacyLine(
                p,
                'It works without an account.',
                'Your week, your logs and your notes are saved on this phone '
                    'first. Nothing waits on a signal.',
              ),
              _privacyLine(
                p,
                'Nobody outside your home sees it.',
                'Not an advertiser, not an employer, not an insurer. The only '
                    'person who can see your logs is a partner you pair with '
                    'yourself.',
              ),
              _privacyLine(
                p,
                'You can delete all of it.',
                'One tap in You → Data and privacy, and it goes — from this '
                    'phone and from our servers.',
              ),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
            child: ObPrimary(
              p: p,
              label: 'Continue',
              onTap: () => _go(ObStep.who),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _privacyLine(V2Palette p, String title, String body) => Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: pvManrope(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: p.ink1,
          ),
        ),
        const SizedBox(height: 4),
        Text(body, style: pvManrope(fontSize: 14, height: 1.5, color: p.ink2)),
      ],
    ),
  );

  Future<void> _google() async {
    setState(() => _busy = true);
    final r = await SocialAuth.signIn(SocialProvider.google);
    if (!mounted) return;
    setState(() => _busy = false);
    if (r.cancelled) return;
    if (!r.ok) {
      _say(r.message ?? 'Could not sign in. Try again.');
      return;
    }
    // ⚠️ THIS SENT HER BACK TO THE NAME SCREEN UNTIL 2026-09-22. In V1 Google
    // was step one and `hello` was what came next, so `_go(ObStep.hello)` was
    // right. After the reorder, sign-in is the TWELFTH step and this made the
    // flow loop: account → name → beat → date → … with `reach` never pushed
    // at all. Found by counting pushes per step rather than by walking it,
    // which is the only way to catch a step that is simply never linked to.
    //
    // Her own name wins. She typed it eleven screens ago; the Google account
    // on a shared family phone is frequently her husband's, and overwriting
    // "Priya" with "Rahul Menon" at the last moment would be the app
    // forgetting her at the exact point it promised to remember.
    if (_name.trim().isEmpty) _name = _googleName();
    _go(ObStep.reach);
  }

  /// Supabase may not be initialised (tests, previews) — that is "no name",
  /// never a crash; the Hello screen offers "Add your name" instead.
  static String _googleName() {
    try {
      final meta =
          Supabase.instance.client.auth.currentUser?.userMetadata ?? const {};
      return (meta['full_name'] ?? meta['name'] ?? '').toString().trim();
    } catch (_) {
      return '';
    }
  }

  /// ⚠️ KEPT FOR REVERT — unused since the V1 `_hello` screen retired. It
  /// showed the signed-in email above her name, which only made sense while
  /// Google sign-in came FIRST. If the account ever moves back to the front,
  /// this is the reader.
  // ignore: unused_element
  static String _currentEmail() {
    try {
      return Supabase.instance.client.auth.currentUser?.email ?? '';
    } catch (_) {
      return '';
    }
  }

  void _doctor() {
    // The doctor entry lives on the old screen, unchanged.
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        settings: const RouteSettings(name: 'auth/doctor'),
        builder: (_) => AuthFlowScreen(
          onDone: (_, isFather) => widget.onDone(null, isFather),
          onDoctor: widget.onDoctor,
        ),
      ),
    );
  }

  Future<void> _code() async {
    final ok = await showEnterCodeSheet(context);
    if (ok && mounted) setState(() {});
  }

  // ---- 05 name · 06 the beats · 10 building · 12 account ------------------------

  /// ⚠️ `_hello` IS GONE AND THIS REPLACES IT. V1 read the name off the Google
  /// account and showed it back ("Nice to meet you, Priya" with her email
  /// above it). With sign-in moved to the end there is no account to read yet,
  /// so she is asked — which is better anyway: the old screen could only ever
  /// greet her by whatever name her Google account happened to carry, and for
  /// a shared family phone that is frequently her husband's.
  ///
  /// Kept for revert, the V1 screen: an avatar disc + the session email, the
  /// name in Fraunces 34 with the first name in `p.action`, and an "Add your
  /// name / Not X? Edit" link into `_editName` — which is still here and still
  /// used by the field below.
  Widget _namePage(V2Palette p) {
    final first = _name0;
    return ObPage(
      p: p,
      onBack: _back,
      body: [
        ObHead(
          p: p,
          eyebrow: 'Your name',
          title: 'What should we call you?',
          subtitle:
              'It goes at the top of your home and nowhere else. You can skip it.',
        ),
        const SizedBox(height: 18),
        ObField(
          p: p,
          label: 'Your name',
          child: TextField(
            controller: _nameField,
            textCapitalization: TextCapitalization.words,
            onChanged: (v) => setState(() => _name = v.trim()),
            style: pvFraunces(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: p.ink1,
            ),
            // A neutral placeholder, not a person's name — the user,
            // 2026-09-22. "Priya" read as a value already filled in, and the
            // beat two screens later greets her by name, so seeing one here
            // first made it look as though the app had decided who she was.
            decoration: obBareInput(
              hint: 'First name',
              style: pvFraunces(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: p.ink3,
              ),
            ),
          ),
        ),
      ],
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ObPrimary(
            p: p,
            label: 'Continue',
            onTap: () => _go(ObStep.beatHello),
          ),
          if (first.isEmpty)
            ObLink(
              p: p,
              label: 'Skip for now',
              onTap: () => _go(ObStep.beatHello),
            ),
        ],
      ),
    );
  }

  /// What she has told us, in her own answers' words.
  ///
  /// ⚠️ DERIVED FROM THE QUESTIONS THEMSELVES, so a question added to
  /// `onboarding_questions.dart` tomorrow appears here with nothing to wire —
  /// and, more importantly, a question REMOVED cannot leave a stale line
  /// behind. The option labels are the source of the words; this file does
  /// not get its own copy of them to drift from.
  List<String> _summaryRows() {
    final out = <String>[];
    switch (_stage) {
      case 'pregnancy':
        final edd = _edd;
        if (edd != null) {
          final days = 280 - edd.difference(_today()).inDays;
          final w = (days ~/ 7).clamp(0, 42);
          out.add('Week $w · due ${_short(edd)}');
        }
      case 'parenting':
        final dob = _childDob;
        final who = _childName.text.trim().isEmpty
            ? 'Your baby'
            : _childName.text.trim();
        if (dob != null) {
          final age = _monthsWeeks(dob);
          out.add(
            age.$1 == 0
                ? '$who · ${age.$2} ${age.$2 == 1 ? 'week' : 'weeks'} old'
                : '$who · ${age.$1} ${age.$1 == 1 ? 'month' : 'months'} old',
          );
        }
      case 'skilling':
        final who = _childName.text.trim().isEmpty
            ? 'Your child'
            : _childName.text.trim();
        if (_childAge != null) out.add('$who · age $_childAge');
    }
    for (final q in _questions) {
      final chosen = _answers[q.id];
      if (chosen == null || chosen.isEmpty) continue;
      final labels = q.options
          .where((o) => chosen.contains(o.id))
          .map((o) => o.label)
          .join(' · ');
      if (labels.isNotEmpty) out.add(labels);
    }
    return out;
  }

  /// Her first name, or empty. One definition — three screens greet her.
  String get _name0 =>
      _name.split(' ').where((w) => w.isNotEmpty).firstOrNull ?? '';

  // ---- the beats ----------------------------------------------------------------

  Widget _beatHello(V2Palette p) => ObBeat(
    p: p,
    art: ObArt.hello,
    title: _name0.isEmpty ? 'Good to have you here.' : 'Hello, $_name0.',
    body:
        'From here the app is yours. What it shows you on a Tuesday morning '
        'depends on what you tell us next — the week you are in, what you are '
        'worried about, what you would rather not read.',
    cta: 'Continue',
    onNext: _afterHello,
  );

  /// ⚠️ THE ONLY NUMBERS ON THIS SCREEN ARE HERS, AND THEY ARE DERIVED. No
  /// population claim, no "most women feel…", no prediction — the beat says
  /// what her date means and what the app will do about it, and nothing about
  /// how her pregnancy will go. `test/ttc_clinical_review_test.dart` scans
  /// this file.
  Widget _beatWeek(V2Palette p) {
    String title;
    String body;
    if (_stage == 'pregnancy') {
      final edd = _edd;
      final days = edd == null ? 0 : 280 - edd.difference(_today()).inDays;
      final w = (days ~/ 7).clamp(0, 42);
      final tri = w < 13 ? 'first' : (w < 27 ? 'second' : 'third');
      title = 'Week $w.';
      body =
          'That puts you in the $tri trimester. From here every week has its '
          'own page — what is changing, what is worth asking about, and what '
          'you can safely ignore.';
    } else {
      final dob = _childDob;
      final who = _childName.text.trim().isEmpty
          ? 'Your baby'
          : _childName.text.trim();
      final age = dob == null ? (0, 0) : _monthsWeeks(dob);
      title = age.$1 == 0
          ? '$who is ${age.$2} ${age.$2 == 1 ? 'week' : 'weeks'} old.'
          : '$who is ${age.$1} ${age.$1 == 1 ? 'month' : 'months'} old.';
      body =
          'We will follow that with you — what changes this month, what is '
          'normal at this age, and what other parents ask at exactly this '
          'point.';
    }
    return ObBeat(
      p: p,
      art: ObArt.week,
      title: title,
      body: body,
      cta: 'Continue',
      onNext: _afterDate,
    );
  }

  /// ⚠️ THIS SCREEN IS THE CLINICAL INVARIANTS, SAID OUT LOUD. Never a
  /// diagnosis, never contradicting her own clinician, and a clinician's
  /// answer outranks ours (CLAUDE.md, `truth_hierarchy.dart`). Saying it
  /// during onboarding rather than burying it in a disclaimer is the point:
  /// it is the promise that makes the questions safe to answer.
  Widget _beatPromise(V2Palette p) => ObBeat(
    p: p,
    art: ObArt.promise,
    title: 'What we will never do.',
    body:
        'We will never diagnose you, and we will never contradict your '
        'doctor. When something needs a clinician we will say so plainly and '
        'help you get ready for the appointment. If your doctor has told you '
        'something different from what you read here, your doctor is right.',
    cta: 'Good',
    onNext: () => setState(() {
      _q++;
      _history.removeLast();
    }),
  );

  // ---- 10 building ---------------------------------------------------------------

  /// ⚠️ HONEST THEATRE, OR NONE. Flo, Noom, Lifesum, Ten Percent Happier and
  /// half a dozen others show a plan being built, and it works — but Noom's
  /// is the only one worth copying, because it NAMES the sections it is
  /// working through instead of spinning a generic loader.
  ///
  /// So the lines here are the real work and they are ticked as it lands:
  /// the answers go into `FamilyProfileStore` (which is what actually ranks
  /// her content), the week is computed, the stage is set. If we ever find
  /// ourselves adding a line for something the app does not do, the line is
  /// the bug.
  int _built = 0;
  bool _buildingStarted = false;

  static const _buildLines = [
    'Saving your answers',
    'Working out your week',
    'Choosing what to show you first',
    'Setting up your home',
  ];

  /// ⚠️ AFTER THE FRAME, NEVER DURING IT. `_building` calls this from its
  /// `build`, and the first thing it does is write to `FamilyProfileStore` —
  /// a `ChangeNotifier`. Notifying listeners while a build is in flight is
  /// the classic "setState() or markNeedsBuild() called during build" crash,
  /// and it would not fire here today only because nothing happens to be
  /// listening on this route yet. That is luck, not design.
  void _startBuilding() {
    if (_buildingStarted) return;
    _buildingStarted = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _runBuild();
    });
  }

  void _runBuild() {
    // The real local write, before any session exists — this is what
    // local-first buys us, and it is what "Saving your answers" refers to.
    //
    // ⚠️ IDEMPOTENT ON PURPOSE. Each question already applies itself the
    // moment she taps an option, so this is a re-apply rather than the only
    // write — deliberately, because a flow resumed from `startAt`, or one
    // where she went back and changed an answer, must land the LAST state and
    // not the first. `apply` sets rather than accumulates, so running it
    // twice is the same as running it once.
    for (final q in _questions) {
      final chosen = _answers[q.id];
      if (chosen != null) q.apply(FamilyProfileStore.instance, chosen);
    }
    for (var i = 1; i <= _buildLines.length; i++) {
      Future<void>.delayed(Duration(milliseconds: 420 * i), () {
        if (!mounted || _step != ObStep.building) return;
        setState(() => _built = i);
        if (i == _buildLines.length) {
          Future<void>.delayed(const Duration(milliseconds: 460), () {
            if (mounted && _step == ObStep.building) _afterBuilding();
          });
        }
      });
    }
  }

  Widget _building(V2Palette p) {
    _startBuilding();
    return Scaffold(
      backgroundColor: p.ground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Text(
                'Putting your ParentVeda together.',
                style: pvFraunces(
                  fontSize: 27,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.6,
                  height: 1.15,
                  color: p.ink1,
                ),
              ),
              const SizedBox(height: 26),
              for (var i = 0; i < _buildLines.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 260),
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _built > i ? p.ink1 : p.surfaceAlt,
                        ),
                        alignment: Alignment.center,
                        child: _built > i
                            ? Icon(
                                Icons.check_rounded,
                                size: 14,
                                color: p.ground,
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      // Expanded: the line is a sentence and the row is the
                      // width of the page, so it wraps rather than clips at
                      // a large system font size.
                      Expanded(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 260),
                          style: pvManrope(
                            fontSize: 15,
                            height: 1.35,
                            fontWeight: _built > i
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: _built > i ? p.ink1 : p.ink3,
                          ),
                          child: Text(_buildLines[i]),
                        ),
                      ),
                    ],
                  ),
                ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  // ---- 12 account ----------------------------------------------------------------

  /// ⚠️ EVERYTHING BEFORE THIS SCREEN IS ALREADY SAVED, ON THIS PHONE. So the
  /// ask is not "sign in to continue" — it is "sign in so this survives a new
  /// phone", which is a true statement and a much easier one to say.
  Widget _account(V2Palette p) => ObPage(
    p: p,
    onBack: _back,
    body: [
      ObHead(
        p: p,
        eyebrow: 'One last thing',
        title: _name0.isEmpty
            ? 'Keep all of this.'
            : 'Keep all of this, $_name0.',
        subtitle:
            'Your week, your answers and everything you log are on this phone '
            'now. An account is what carries them to a new one — and what '
            'lets your partner pair with you.',
      ),
      // ⚠️ "ALL OF THIS" HAD NOTHING UNDER IT — the user, 2026-09-22: "above
      // the Continue with Google button it's all white, seems very bland".
      //
      // The answer is not decoration. The screen asks her to create an
      // account to keep something, and the most persuasive thing that can
      // possibly sit here is THAT SOMETHING, itemised — twelve screens of her
      // own answers, shown back. It is also the only content on this screen
      // that cannot be written in advance, which is the point of the whole
      // reorder: by now we have something of hers to show.
      //
      // Every row is derived; nothing here is a fixed list.
      const SizedBox(height: 22),
      Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: p.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ON THIS PHONE NOW',
              style: pvManrope(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.3,
                color: p.ink3,
              ),
            ),
            const SizedBox(height: 10),
            for (final row in _summaryRows())
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      margin: const EdgeInsets.only(top: 2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: p.ink1,
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        size: 12,
                        color: p.ground,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        row,
                        style: pvManrope(
                          fontSize: 14.5,
                          height: 1.4,
                          fontWeight: FontWeight.w600,
                          color: p.ink1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    ],
    bottom: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ObSecondary(
          p: p,
          label: _busy ? 'Signing in…' : 'Continue with Google',
          leading: SizedBox(
            width: 20,
            height: 20,
            child: SvgPicture.string(kGoogleMarkSvg),
          ),
          onTap: _busy ? null : _google,
        ),
        const SizedBox(height: 12),
        Text.rich(
          TextSpan(
            text: 'By continuing you agree to our ',
            style: pvManrope(fontSize: 11.5, height: 1.4, color: p.ink3),
            children: [
              TextSpan(
                text: 'Terms',
                style: TextStyle(color: p.action, fontWeight: FontWeight.w700),
              ),
              const TextSpan(text: ' and '),
              TextSpan(
                text: 'Privacy Policy',
                style: TextStyle(color: p.action, fontWeight: FontWeight.w700),
              ),
              const TextSpan(text: '.'),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );

  /// ⚠️ KEPT FOR REVERT — the V1 "Not Priya? Edit" sheet. The name is a plain
  /// field on `_namePage` now, so nothing opens this; it is the editor the
  /// old Google-first flow needed and would need again.
  // ignore: unused_element
  Future<void> _editName() async {
    final c = TextEditingController(text: _name);
    final v = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: V2PaletteStore.instance.current.ground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          20,
          24,
          24 + MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What should we call you?',
              style: pvFraunces(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: V2PaletteStore.instance.current.ink1,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: c,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            ObPrimary(
              p: V2PaletteStore.instance.current,
              label: 'Save',
              onTap: () => Navigator.of(ctx).pop(c.text),
            ),
          ],
        ),
      ),
    );
    if (v != null && mounted) setState(() => _name = v.trim());
  }

  // ---- 03 who -------------------------------------------------------------------

  Widget _who(V2Palette p) => ObPage(
    p: p,
    center: true,
    onBack: _back,
    body: [
      ObHead(
        p: p,
        eyebrow: 'Who is using this',
        title: 'Which of you is this?',
        subtitle: 'Whoever is not here gets their own app, paired to yours.',
      ),
      // ⚠️ THIS SCREEN WAS THE ONE THAT DID NOT GET THE TREATMENT — the user,
      // 2026-09-22, walking it: the welcome and the privacy screens carry a
      // painting, the stage screen carries four, "and that one screen where
      // we have to choose either it's a mother or a father seemed very
      // bland". It was two Material glyphs in pale wells with an empty bottom
      // half, sitting between two illustrated screens — a gap you can only
      // see on the device, in order.
      //
      // Two portraits, drawn as a pair and turned toward each other, and a
      // taller well than the four-up stage cards because these are twice the
      // width: at 76pt the picture read as a swatch above a caption.
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ObGridCard(
              p: p,
              title: 'Mother',
              subtitle: 'Trying, expecting or raising',
              icon: Icons.favorite_border_rounded,
              art: ObArt.whoMother,
              artHeight: 132,
              hue: 344,
              selected: false,
              onTap: () => _go(ObStep.stage),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ObGridCard(
              p: p,
              title: 'Partner',
              subtitle: 'Join with her code',
              icon: Icons.people_outline_rounded,
              art: ObArt.whoPartner,
              artHeight: 132,
              hue: 104,
              selected: false,
              onTap: _partner,
            ),
          ),
        ],
      ),
      const SizedBox(height: 18),
      Text(
        'We only ever hold a name its owner gave us.',
        style: pvManrope(fontSize: 12.5, height: 1.4, color: p.ink3),
      ),
    ],
  );

  void _partner() {
    // The pairing branch is the old screen's, unchanged and already positioned.
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        settings: const RouteSettings(name: 'auth/pairing'),
        builder: (_) => AuthFlowScreen(
          initialScreen: 'pairCode',
          onDone: (_, isFather) => widget.onDone(null, isFather),
          onDoctor: widget.onDoctor,
        ),
      ),
    );
  }

  // ---- 04 stage -----------------------------------------------------------------

  Widget _stagePage(V2Palette p) {
    // A 2x2 of cards with tinted wells — the design's shape. Hues are the
    // stages' own (pink for trying, violet for pregnancy, blue for parenting,
    // green for skilling), from the V3 door palette.
    Widget card(
      String id,
      String title,
      String sub,
      IconData icon,
      double hue,
      ObArt art,
    ) => ObGridCard(
      p: p,
      title: title,
      subtitle: sub,
      icon: icon,
      art: art,
      hue: hue,
      selected: _stage == id,
      onTap: () {
        setState(() => _stage = id);
        // The tap is the answer — no Continue.
        //
        // ⚠️ THIS WENT STRAIGHT TO THE DATE UNTIL 2026-09-22, which after the
        // reorder made `name` and `beatHello` unreachable — the two screens
        // added between stage and date, correct and never once rendered. The
        // wiring gate: a step added to the enum, built, and never linked to,
        // and no test would have caught it because the test that walks this
        // path starts AFTER it.
        _go(ObStep.name);
      },
    );
    return ObPage(
      p: p,
      onBack: _back,
      body: [
        ObHead(
          p: p,
          eyebrow: 'Where you are',
          title: 'Where are you right now?',
          subtitle:
              'This sets your home. You can change it whenever life does.',
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: card(
                'trying',
                'Trying to conceive',
                'Cycle and timing',
                Icons.favorite_border_rounded,
                344,
                ObArt.stageTrying,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: card(
                'pregnancy',
                'Pregnant',
                'Week by week',
                Icons.pregnant_woman_rounded,
                275,
                ObArt.stagePregnant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: card(
                'parenting',
                'Parent — 0 to 5',
                'Sleep and leaps',
                Icons.child_care_rounded,
                205,
                ObArt.stageParenting,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: card(
                'skilling',
                'Skilling — 6 and up',
                'Skills and habits',
                Icons.school_outlined,
                150,
                ObArt.stageSkilling,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          'Expecting twins or more? You can say so later.',
          style: pvManrope(fontSize: 12.5, height: 1.4, color: p.ink3),
        ),
      ],
    );
  }

  // ---- 05 date ------------------------------------------------------------------

  Widget _date(V2Palette p) => switch (_stage) {
    'pregnancy' => _datePregnant(p),
    'skilling' => _dateChild(p, skilling: true),
    _ => _dateChild(p, skilling: false),
  };

  static const _methods = [
    (DdcMethod.lmp, 'Last period', 'First day of your last period'),
    (DdcMethod.known, "Doctor's date", 'The due date you were given'),
    (DdcMethod.ultrasound, 'Scan date', 'The day of your dating scan'),
    (DdcMethod.ivf, 'IVF transfer', 'The day of the embryo transfer'),
  ];

  DateTime? get _edd => _methodDate == null
      ? null
      : ddcComputeEdd(
          method: _method,
          lmp: _methodDate,
          known: _methodDate,
          scan: _methodDate,
          transfer: _methodDate,
        );

  Widget _datePregnant(V2Palette p) {
    final m = _methods.firstWhere((e) => e.$1 == _method);
    return ObPage(
      p: p,
      onBack: _back,
      body: [
        ObHead(p: p, eyebrow: 'Your dates', title: 'When is the baby due?'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final e in _methods)
              ObPill(
                p: p,
                label: e.$2,
                selected: _method == e.$1,
                onTap: () => setState(() => _method = e.$1),
              ),
          ],
        ),
        const SizedBox(height: 16),
        ObField(
          p: p,
          label: m.$3,
          onTap: () => _pickDate(
            initial: _methodDate ?? DateTime.now(),
            first: DateTime.now().subtract(const Duration(days: 300)),
            last: DateTime.now().add(const Duration(days: 300)),
            onPicked: (d) => setState(() => _methodDate = d),
          ),
          child: Text(
            _methodDate == null ? 'Tap to choose' : _long(_methodDate!),
            style: pvFraunces(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: _methodDate == null ? p.ink3 : p.ink1,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Not sure? Your last period is enough to start — you can change it any time.',
          style: pvManrope(fontSize: 12.5, height: 1.45, color: p.ink3),
        ),
      ],
      bottom: ObPrimary(
        p: p,
        label: 'Continue',
        onTap: _edd == null ? null : _afterDatePage,
      ),
    );
  }

  Widget _dateChild(V2Palette p, {required bool skilling}) {
    final ready = skilling ? _childAge != null : _childDob != null;
    return ObPage(
      p: p,
      onBack: _back,
      body: [
        ObHead(
          p: p,
          eyebrow: skilling ? 'Your child' : 'Your baby',
          title: skilling
              ? 'Tell us about your child.'
              : 'Tell us about your baby.',
        ),
        ObField(
          p: p,
          label: skilling
              ? "Child's name — optional"
              : "Baby's name — optional",
          child: TextField(
            controller: _childName,
            textCapitalization: TextCapitalization.words,
            onChanged: (_) => setState(() {}),
            style: pvFraunces(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: p.ink1,
            ),
            decoration: obBareInput(
              hint: "Your baby's name",
              style: pvFraunces(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: p.ink3,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        if (skilling)
          ObField(
            p: p,
            label: 'Age',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var a = 6; a <= 12; a++)
                  ObPill(
                    p: p,
                    label: '$a',
                    selected: _childAge == a,
                    onTap: () => setState(() => _childAge = a),
                  ),
              ],
            ),
          )
        else
          ObField(
            p: p,
            label: 'Birthday',
            onTap: () => _pickDate(
              initial: _childDob ?? DateTime.now(),
              first: DateTime.now().subtract(const Duration(days: 365 * 6)),
              last: DateTime.now(),
              onPicked: (d) => setState(() => _childDob = d),
            ),
            child: Text(
              _childDob == null ? 'Tap to choose' : _long(_childDob!),
              style: pvFraunces(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: _childDob == null ? p.ink3 : p.ink1,
              ),
            ),
          ),
        const SizedBox(height: 10),
        ObField(
          p: p,
          label: 'Boy or girl — optional',
          child: Wrap(
            spacing: 8,
            children: [
              ObPill(
                p: p,
                label: 'Boy',
                selected: _childIsBoy == true,
                onTap: () => setState(() => _childIsBoy = true),
              ),
              ObPill(
                p: p,
                label: 'Girl',
                selected: _childIsBoy == false,
                onTap: () => setState(() => _childIsBoy = false),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          skilling
              ? 'The age is what the activities are chosen by. Nothing else is needed.'
              : 'The name is optional — the birthday is what the months and the leaps are counted from.',
          style: pvManrope(fontSize: 12.5, height: 1.45, color: p.ink3),
        ),
      ],
      bottom: ObPrimary(
        p: p,
        label: 'Continue',
        onTap: ready ? _afterDatePage : null,
      ),
    );
  }

  Future<void> _pickDate({
    required DateTime initial,
    required DateTime first,
    required DateTime last,
    required void Function(DateTime) onPicked,
  }) async {
    // The app's date sheet (2026-09-19) — the Material dialog this replaced
    // sat lavender over the page with a violet day (the user's screenshot).
    // Kept for revert: showDatePicker(context, initialDate, firstDate, lastDate).
    final d = await showPvDateSheet(
      context,
      title: 'Which day?',
      initial: initial,
      first: first,
      last: last,
    );
    if (d != null) onPicked(d);
  }

  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  static String _long(DateTime d) =>
      '${d.day} ${_months[d.month - 1]} ${d.year}';
  static String _short(DateTime d) =>
      '${d.day} ${_months[d.month - 1].substring(0, 3)}';

  // ---- questions ----------------------------------------------------------------

  Widget _question(V2Palette p) {
    final qs = _questions;
    if (qs.isEmpty) return const SizedBox.shrink();
    final q = qs[_q.clamp(0, qs.length - 1)];
    final chosen = _answers[q.id] ?? <String>{};
    final giveBack = q.multi
        ? (chosen.isEmpty ? '' : (q.multiGiveBack ?? ''))
        : (chosen.isEmpty
              ? ''
              : q.options.firstWhere((o) => o.id == chosen.first).giveBack);

    void choose(ObOption o) {
      setState(() {
        final set = _answers.putIfAbsent(q.id, () => <String>{});
        if (q.multi) {
          set.contains(o.id) ? set.remove(o.id) : set.add(o.id);
        } else {
          set
            ..clear()
            ..add(o.id);
        }
      });
      q.apply(FamilyProfileStore.instance, _answers[q.id]!);
    }

    return ObPage(
      p: p,
      onBack: _back,
      trailing: ObLink(p: p, label: 'Skip', onTap: _nextQuestion),
      body: [
        // ⚠️ THE ONE PLACE A BAR BELONGS — see onboarding_chrome's header for
        // why the "no progress bar anywhere" rule was narrowed rather than
        // dropped. Named with the stage, because Noom's finding is that a
        // labelled section reads as a subject with an end and a bare count
        // reads as a chore with a length.
        ObProgress(
          p: p,
          label: switch (_stage) {
            'pregnancy' => 'About your pregnancy',
            'trying' => 'About where you are',
            'skilling' => 'About your child',
            _ => 'About your baby',
          },
          step: _q + 1,
          total: qs.length,
        ),
        const SizedBox(height: 22),
        ObHead(p: p, title: q.title, subtitle: q.subtitle),
        if (q.multi)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final o in q.options)
                ObPill(
                  p: p,
                  label: o.label,
                  selected: chosen.contains(o.id),
                  onTap: () => choose(o),
                ),
            ],
          )
        else
          for (final o in q.options) ...[
            ObTile(
              p: p,
              title: o.label,
              selected: chosen.contains(o.id),
              compact: true,
              onTap: () => choose(o),
            ),
            const SizedBox(height: 8),
          ],
        ObGiveBack(p: p, text: giveBack),
      ],
      bottom: ObPrimary(
        p: p,
        label: 'Continue',
        onTap: chosen.isEmpty ? null : _nextQuestion,
      ),
    );
  }

  // ---- 06 reveal ----------------------------------------------------------------

  Widget _reveal(V2Palette p) {
    String big;
    String small;
    String eyebrow;
    switch (_stage) {
      case 'pregnancy':
        final edd = _edd!;
        final days = 280 - edd.difference(_today()).inDays;
        final w = (days ~/ 7).clamp(0, 42);
        final d = (days % 7).clamp(0, 6);
        final tri = w < 13 ? 'First' : (w < 27 ? 'Second' : 'Third');
        eyebrow = 'Week $w';
        // "Week 14, day 0" is obstetric notation (14+0) and it is correct;
        // it is also the only line on the screen that reads like a chart. On
        // the day a week turns, the week alone is the whole answer.
        big = d == 0 ? 'Week $w.' : 'Week $w, day $d.';
        small = '$tri trimester · Due ${_short(edd)}';
      case 'parenting':
        final dob = _childDob!;
        final age = _monthsWeeks(dob);
        final name = _childName.text.trim().isEmpty
            ? 'Your baby'
            : _childName.text.trim();
        eyebrow = age.$1 == 0 ? 'Week ${age.$2}' : 'Month ${age.$1}';
        big = age.$1 == 0
            ? '$name is ${age.$2} ${age.$2 == 1 ? 'week' : 'weeks'} old.'
            : '$name is ${age.$1} ${age.$1 == 1 ? 'month' : 'months'}${age.$2 > 0 ? ', ${age.$2} ${age.$2 == 1 ? 'week' : 'weeks'}' : ''}.';
        small = "Here's what's changing this month.";
      default:
        final name = _childName.text.trim().isEmpty
            ? 'Your child'
            : _childName.text.trim();
        eyebrow = 'Age ${_childAge ?? 6}';
        big = '$name, ${_childAge ?? 6}.';
        small = "Here's where we start.";
    }
    return ObPage(
      p: p,
      onBack: _back,
      body: [
        // Kept for revert: a 220pt `p.surfaceAlt` box with the eyebrow
        // centred in it — a placeholder that read as a missing image, which
        // is exactly what it was.
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: SizedBox(
            height: 220,
            width: double.infinity,
            child: ObArtFill(art: ObArt.plan, p: p),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          eyebrow.toUpperCase(),
          style: pvManrope(
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.3,
            color: p.ink3,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          big,
          style: pvFraunces(
            fontSize: 36,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.9,
            height: 1.1,
            color: p.ink1,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          small,
          style: pvManrope(fontSize: 15.5, height: 1.45, color: p.ink2),
        ),
        // ⚠️ THE PAYOFF THE QUESTIONS BOUGHT. The reveal showed her week and
        // then stopped, leaving the lower half white — which is a strange
        // place to stop, because the screen before it was three questions
        // about what she wants and this is the first chance to show that they
        // landed. Flo's version of this screen is a list of what she now
        // gets; ours is that list built from her own answers.
        //
        // Every line is true of the app as configured. The priorities really
        // are `PregPriority` values and `togglePregPriority` really does
        // reorder her home — the option ids in `onboarding_questions.dart`
        // ARE the enum's names, which is why this can be stated rather than
        // promised.
        const SizedBox(height: 26),
        for (final row in _revealRows())
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(top: 8, right: 12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: p.ink3,
                  ),
                ),
                Expanded(
                  child: Text(
                    row,
                    style: pvManrope(fontSize: 15, height: 1.45, color: p.ink1),
                  ),
                ),
              ],
            ),
          ),
      ],
      bottom: ObPrimary(
        p: p,
        label: "Let's begin",
        onTap: () => _go(ObStep.account),
      ),
    );
  }

  /// What she now has, in the app's own terms.
  ///
  /// ⚠️ NO NEW CONFIG. The middle line reuses the option LABELS she chose
  /// rather than a second table of marketing copy keyed by the same ids — a
  /// table like that drifts from the question the moment anyone edits either
  /// one, and nobody notices because both still compile.
  List<String> _revealRows() {
    final out = <String>[
      switch (_stage) {
        'pregnancy' => 'A page for every week, from this one to birth',
        'parenting' => 'What changes for them, month by month',
        _ => 'A skill at a time, at the age they are',
      },
    ];
    for (final q in _questions) {
      final chosen = _answers[q.id];
      if (chosen == null || chosen.isEmpty) continue;
      final labels = q.options
          .where((o) => chosen.contains(o.id))
          .map((o) => o.label)
          .toList();
      if (labels.isEmpty) continue;
      if (q.multi) {
        // ⚠️ MIDDOTS, NOT "AND". `_and` produced "Eating well, Worry and mood
        // and Preparing for birth" — grammatical, and it stutters, because
        // one of the options has an "and" inside it already. A list whose
        // items may contain the conjunction cannot be joined with the
        // conjunction.
        out.add('${labels.join(' · ')} — first on your home');
      } else if (q.id.endsWith('_diet')) {
        // The label is a title ("Vegetarian"); mid-sentence it is a word.
        out.add(
          'Every recipe and food page respects '
          '${labels.first.toLowerCase()}',
        );
      }
    }
    out.add('Ask Veda anything, in your own words, any time');
    return out;
  }

  static DateTime _today() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  /// (months, weeks) since [dob], calendar months first.
  static (int, int) _monthsWeeks(DateTime dob) {
    final now = _today();
    var months = (now.year - dob.year) * 12 + (now.month - dob.month);
    var anchor = DateTime(dob.year, dob.month + months, dob.day);
    if (anchor.isAfter(now)) {
      months--;
      anchor = DateTime(dob.year, dob.month + months, dob.day);
    }
    final weeks = (now.difference(anchor).inDays ~/ 7).clamp(0, 4);
    return (months.clamp(0, 240), weeks);
  }

  // ---- 07 reach -----------------------------------------------------------------

  Widget _reach(V2Palette p) {
    final canContinue =
        !_whatsapp || WhatsAppPrefs.normalizePhone(_phone.text) != null;
    return ObPage(
      p: p,
      // Two switches and a sentence. Centred — but it grows a phone field and
      // an OTP box when WhatsApp is on, and a centred column that has grown
      // past the fold scrolls, which is why this is `ObPage`'s option and not
      // a `Center` wrapped round the body.
      center: true,
      onBack: _back,
      body: [
        ObHead(
          p: p,
          eyebrow: 'Staying in touch',
          title: 'How should we reach you?',
          subtitle: 'Both optional. Neither is marketing.',
        ),
        _reachRow(
          p,
          on: _reminders,
          title: 'Reminders on this phone',
          sub: "The week's change, the morning it starts.",
          onChanged: (v) => setState(() => _reminders = v),
          child: _reminders
              ? Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  decoration: BoxDecoration(
                    color: p.ground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: p.line),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ParentVeda · now',
                        style: pvManrope(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: p.ink3,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _previewNotification(),
                        style: pvManrope(
                          fontSize: 13,
                          height: 1.4,
                          color: p.ink1,
                        ),
                      ),
                    ],
                  ),
                )
              : null,
        ),
        const SizedBox(height: 10),
        _reachRow(
          p,
          on: _whatsapp,
          title: "This week's guidance on WhatsApp",
          sub: 'One message a week, in your stage.',
          onChanged: (v) async {
            setState(() => _whatsapp = v);
            if (v && _phone.text.isEmpty) {
              final hint = await PhoneOtp.hintNumber();
              if (hint != null && mounted) setState(() => _phone.text = hint);
            }
          },
          child: _whatsapp
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _phone,
                            keyboardType: TextInputType.phone,
                            onChanged: (_) =>
                                setState(() => _phoneVerified = false),
                            style: pvFraunces(
                              fontSize: 19,
                              fontWeight: FontWeight.w600,
                              color: p.ink1,
                            ),
                            decoration: InputDecoration(
                              isDense: true,
                              prefixText: '+91 ',
                              prefixStyle: pvFraunces(
                                fontSize: 19,
                                fontWeight: FontWeight.w600,
                                color: p.ink2,
                              ),
                              hintText: '98765 43210',
                              hintStyle: pvFraunces(
                                fontSize: 19,
                                fontWeight: FontWeight.w600,
                                color: p.ink3,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        if (_phoneVerified)
                          Icon(
                            Icons.verified_rounded,
                            size: 18,
                            color: p.action,
                          )
                        else
                          ObLink(
                            p: p,
                            label: 'Use another',
                            onTap: () => setState(() => _phone.clear()),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "From your SIM, one tap. We'll send a code to confirm it's you. No marketing.",
                      style: pvManrope(
                        fontSize: 12,
                        height: 1.4,
                        color: p.ink3,
                      ),
                    ),
                  ],
                )
              : null,
        ),
        const SizedBox(height: 18),
        // ⚠️ This line used to read "The permission comes after the value, and
        // nothing is pre-ticked" — a design annotation that leaked into copy.
        Text(
          'You can change both any time from Profile.',
          style: pvManrope(fontSize: 12.5, height: 1.4, color: p.ink3),
        ),
      ],
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ObPrimary(
            p: p,
            label: _busy ? 'Saving…' : 'Continue',
            onTap: (_busy || !canContinue) ? null : _continueFromReach,
          ),
          const SizedBox(height: 4),
          ObLink(
            p: p,
            label: 'Not now',
            onTap: _busy
                ? () {}
                : () {
                    setState(() {
                      _reminders = false;
                      _whatsapp = false;
                    });
                    _finish();
                  },
          ),
        ],
      ),
    );
  }

  String _previewNotification() => switch (_stage) {
    'pregnancy' =>
      "Week ${((280 - (_edd ?? _today()).difference(_today()).inDays) ~/ 7) + 1} starts tomorrow — here's what to expect.",
    'parenting' => "A new month starts this week — here's what's changing.",
    'skilling' => "Today's ten-minute activity is ready.",
    _ => 'Your window this cycle, the morning it opens.',
  };

  Widget _reachRow(
    V2Palette p, {
    required bool on,
    required String title,
    required String sub,
    required ValueChanged<bool> onChanged,
    Widget? child,
  }) => Container(
    padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
    decoration: BoxDecoration(
      color: p.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: p.line, width: 1.2),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: pvFraunces(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w600,
                      color: p.ink1,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    sub,
                    style: pvManrope(
                      fontSize: 12.5,
                      height: 1.4,
                      color: p.ink3,
                    ),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: on,
              onChanged: onChanged,
              // Kept for revert (2026-09-28, one black switch app-wide): activeTrackColor: p.ink1, // was p.action (2026-09-19)
            ),
          ],
        ),
        ?child,
      ],
    ),
  );

  Future<void> _continueFromReach() async {
    if (_whatsapp && !_phoneVerified) {
      final ok = await _verifyPhone();
      if (!ok) return; // she chose to skip verification, or the sheet closed
    }
    await _finish();
  }

  /// Send the code, show the sheet, resolve true when verified. A refusal to
  /// verify (rate limit, offline, "skip") still keeps the number and the
  /// opt-in — unverified, which the WhatsApp engine can see.
  Future<bool> _verifyPhone() async {
    await _otp.requestCode(_phone.text);
    if (!mounted) return false;
    if (_otp.step != PhoneOtpStep.sent) {
      _say(switch (_otp.step) {
        PhoneOtpStep.rateLimited =>
          'Too many codes for now — we saved the number and will confirm it later.',
        PhoneOtpStep.offline =>
          "No connection — we saved the number and will confirm it later.",
        PhoneOtpStep.invalidPhone => 'That number does not look right.',
        _ =>
          "Could not send a code — we saved the number and will confirm it later.",
      });
      return _otp.step != PhoneOtpStep.invalidPhone;
    }
    final verified = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      backgroundColor: V2PaletteStore.instance.current.ground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) =>
          _OtpSheet(controller: _otp, phone: _otp.phone ?? _phone.text),
    );
    if (verified == true && mounted) setState(() => _phoneVerified = true);
    return true;
  }

  // ---- finish -------------------------------------------------------------------

  Future<void> _finish() async {
    if (_busy) return;
    setState(() => _busy = true);
    final stage = _stage ?? 'pregnancy';

    // 1. Stage — locally first, before any network, exactly as the old flow.
    LifeStageStore.instance.setStageId(stage);
    FamilyProfileStore.instance.setStage(switch (stage) {
      'trying' => JourneyStage.tryingToConceive,
      'pregnancy' => JourneyStage.pregnancy,
      _ => JourneyStage.parenting,
    });

    // 2. The date, in the store that owns it.
    DateTime? due;
    if (stage == 'pregnancy' && _edd != null) {
      due = _edd;
      await widget.pregnancy.setDueDate(due!, source: ddcSourceFor(_method));
    }
    if (stage == 'parenting' && _childDob != null) {
      await ChildProfileStore.instance.addChild(
        name: _childName.text,
        isBoy: _childIsBoy ?? true,
        dob: _childDob!,
      );
    }
    if (stage == 'skilling' && _childAge != null) {
      final dob = DateTime(
        _today().year - _childAge!,
        _today().month,
        _today().day,
      );
      SkChildStore.instance.update(name: _childName.text, dob: dob);
      await ChildProfileStore.instance.addChild(
        name: _childName.text,
        isBoy: _childIsBoy ?? true,
        dob: dob,
      );
    }

    // 3. Reminders — the OS prompt, only because she flipped the switch.
    if (_reminders) {
      try {
        await NotificationService.instance.requestPermission();
      } catch (_) {
        /* the switch was the consent; the OS answer is its own */
      }
    }

    // 4. The profile row. Built once, used by both paths (cloud or stash).
    final fields = <String, dynamic>{
      if (_name.isNotEmpty) 'name': _name,
      'role': 'mother',
      if (due != null) 'due_date': due.toIso8601String().split('T').first,
      ...WhatsAppPrefs.fieldsFor(
        optIn: _whatsapp,
        phone: _whatsapp ? _phone.text : null,
        source: 'onboarding',
      ),
    };
    try {
      if (!SupabaseRepo.isLoggedIn) {
        await PendingProfile.save(fields);
      } else {
        final ok = await SupabaseRepo.updateMyProfileConfirmed(fields);
        if (!ok) await PendingProfile.save(fields);
      }
    } catch (_) {
      await PendingProfile.save(fields);
    }

    // 5. The flags the splash reads.
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(kAuthCompletedKey, true);
      await prefs.setString(kUserRoleKey, 'mother');
    } catch (_) {
      /* best-effort */
    }

    if (!mounted) return;
    widget.onDone(stage, false);
  }
}

// =============================================================================
//  The OTP sheet — six boxes that fill themselves
// =============================================================================
class _OtpSheet extends StatefulWidget {
  const _OtpSheet({required this.controller, required this.phone});
  final PhoneOtpController controller;
  final String phone;

  @override
  State<_OtpSheet> createState() => _OtpSheetState();
}

class _OtpSheetState extends State<_OtpSheet> {
  static const _len = 6;
  final _field = TextEditingController();
  final _focus = FocusNode();
  int _resendIn = 30;
  bool _listening = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onController);
    _tick();
    _listen();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onController);
    PhoneOtp.stopListening();
    _field.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onController() {
    if (!mounted) return;
    setState(() {});
    if (widget.controller.step == PhoneOtpStep.verified) {
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _tick() async {
    while (mounted && _resendIn > 0) {
      await Future<void>.delayed(const Duration(seconds: 1));
      if (mounted) setState(() => _resendIn--);
    }
  }

  Future<void> _listen() async {
    if (_listening) return;
    _listening = true;
    final code = await PhoneOtp.listenForCode();
    _listening = false;
    if (code != null && mounted) {
      _field.text = code;
      _submit();
    }
  }

  void _submit() {
    final code = _field.text.replaceAll(RegExp(r'\D'), '');
    if (code.length != _len) return;
    widget.controller.submitCode(code);
  }

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final c = widget.controller;
    final masked = _mask(widget.phone);
    final line = switch (c.step) {
      PhoneOtpStep.wrong => "That code isn't right — try again.",
      PhoneOtpStep.expired => 'That code has expired. Send another.',
      PhoneOtpStep.tooMany => 'Too many tries. Send another code.',
      PhoneOtpStep.verifying => 'Checking…',
      PhoneOtpStep.offline => 'No connection. Try again in a moment.',
      _ => 'It fills itself from the SMS.',
    };
    final needsResend =
        c.step == PhoneOtpStep.expired || c.step == PhoneOtpStep.tooMany;
    final digits = _field.text.replaceAll(RegExp(r'\D'), '');

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        18,
        24,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Confirm your number',
                  style: pvFraunces(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: p.ink1,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(false),
                icon: Icon(Icons.close_rounded, color: p.ink2),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'We sent a code to $masked',
            style: pvManrope(fontSize: 14, color: p.ink2),
          ),
          const SizedBox(height: 20),
          // Six boxes drawn over one invisible field, so the keyboard, paste and
          // the SMS auto-fill all land in one place.
          GestureDetector(
            onTap: () => _focus.requestFocus(),
            child: Stack(
              children: [
                Row(
                  children: [
                    for (var i = 0; i < _len; i++) ...[
                      Expanded(
                        child: Container(
                          height: 56,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: p.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: i == digits.length ? p.ink1 : p.line,
                              width: 1.4,
                            ),
                          ),
                          child: Text(
                            i < digits.length ? digits[i] : '',
                            style: pvFraunces(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: p.ink1,
                            ),
                          ),
                        ),
                      ),
                      if (i < _len - 1) const SizedBox(width: 8),
                    ],
                  ],
                ),
                Positioned.fill(
                  child: Opacity(
                    opacity: 0,
                    child: TextField(
                      controller: _field,
                      focusNode: _focus,
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      maxLength: _len,
                      onChanged: (_) {
                        setState(() {});
                        if (digits.length + 1 >= _len) _submit();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            line,
            style: pvManrope(fontSize: 12.5, height: 1.4, color: p.ink3),
          ),
          const SizedBox(height: 18),
          ObPrimary(
            p: p,
            label: c.busy ? 'Checking…' : 'Confirm',
            onTap: (c.busy || digits.length != _len || needsResend)
                ? null
                : _submit,
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_resendIn > 0 && !needsResend)
                Text(
                  'Resend in ${_resendIn}s',
                  style: pvManrope(fontSize: 13, color: p.ink3),
                )
              else
                ObLink(
                  p: p,
                  label: 'Send another code',
                  onTap: c.busy
                      ? () {}
                      : () async {
                          _field.clear();
                          setState(() => _resendIn = 30);
                          _tick();
                          await c.requestCode(widget.phone);
                          _listen();
                        },
                ),
              Text('·', style: TextStyle(color: p.ink3)),
              ObLink(
                p: p,
                label: 'Skip for now',
                onTap: () => Navigator.of(context).pop(false),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _mask(String phone) {
    final d = phone.replaceAll(RegExp(r'\D'), '');
    if (d.length < 6) return phone;
    final tail = d.substring(d.length - 3);
    final head = d.length > 10 ? '+${d.substring(0, d.length - 10)} ' : '';
    final body = d.substring(d.length - 10, d.length - 3);
    return '$head${body.substring(0, 2)}${'•' * (body.length - 2)} ••$tail';
  }
}
