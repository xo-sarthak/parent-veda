// =============================================================================
//  OnboardingFlow — the first run (docs/ONBOARDING.md)
// -----------------------------------------------------------------------------
//  ⚠️ V3, 2026-10-17: EVERY ANSWER HAS A READER. The user: "users should not
//  feel like they wasted their time". Approved as a clickable prototype first.
//  What changed: trying asks where she is (getting ready / on our own / with a
//  clinic), her last period and how long ONCE (the TTC intro is the film only),
//  and has a reveal per path; pregnancy asks scan weeks, embryo day, twins and
//  an optional "gentle"; parenting adds twins and a second child; skilling a
//  real birthday; the partner can set up on his own and is never asked about
//  her body; colours are onboarding's own (no lavender). The table of every
//  answer, where it is saved and what reads it is docs/ONBOARDING.md §3.
//  The older history below stays true of the shape.
//
//  Sesame's welcome, Flo's questions, Apple's date, Oura's reveal, Flo's
//  permission ask, our home. Built from the Claude Design "ParentVeda
//  Onboarding" (2026-09-16) plus the question block the audit priced in and the
//  user asked for (2026-09-17): two or three give-back questions per stage,
//  after the date and before the reveal, so the reveal stays the payoff.
//
//  The mother's path, REORDERED 2026-09-22 (docs/ONBOARDING.md (History B)):
//      welcome → privacy → who → stage → name → «hello»
//        → [date] → «week» → questions… → «promise» → building
//        → [reveal] → account → reach → home
//  Trying to conceive has no date, and since V3 a reveal per path. Kept for
//  revert: "Trying to conceive has no date and no reveal".
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
//  its pairing branch — those screens are kept as-is (ONBOARDING.md History A §4).
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
import 'package:share_plus/share_plus.dart';
import '../../../widgets/pv_home_arrival.dart' show PvFirstHome;
import '../../ttc/ttc_intro_flow.dart' show TtcIntroGate;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../referral/referral_store.dart';
import '../../../services/auth/pending_profile.dart';
import '../../../services/auth/phone_otp.dart';
import '../../../services/auth/social_auth.dart';
import '../../../services/family_profile.dart';
import '../../../services/life_stage_store.dart';
import '../../../services/stage_moves.dart';
import '../../../services/notification_service.dart';
import '../../../services/pregnancy_controller.dart';
import '../../../services/remote/supabase_repo.dart';
import '../../../services/ready_birth_context_store.dart';
import '../../../services/whatsapp_prefs.dart';
import '../../../ttc/cycle_store.dart';
import '../../../ttc/ttc_care_pathway.dart' show TtcPath;
import '../../../ttc/ttc_chapter.dart' show TtcChapterEngine, TtcJourneyState;
import '../../../ttc/ttc_fertile_window.dart'
    show ttcWindowOpensBeforeOvulation, ttcWindowClosesAfterOvulation;
import '../../../ttc/ttc_fertility_help_rules.dart'
    show FertilityAgeBand, FertilityAgeBandCopy;
import '../../../ttc/ttc_fertility_help_store.dart';
import '../../../ttc/ttc_messages_store.dart';
import '../../../ttc/ttc_ready_plan.dart'
    show HisAge, HisAgeCopy, HisHabit, HisHabitCopy, readyMonthLabel;
import '../../../ttc/ttc_ready_plan_store.dart';
import '../../../ttc/ttc_store.dart';
import '../../../ttc/ttc_supplements_store.dart';
import '../../ttc/ttc_strings.dart' show TtcPartnerMode;
import '../../../theme/pv_fonts.dart';
import '../../../widgets/pv_date_sheet.dart';
import '../../post_pregnancy/pp_child_profile.dart';
import '../../referral/enter_code_sheet.dart';
import '../../skilling/sk_child_store.dart';
import '../../skilling/sk_first_activity.dart';
import '../../tools/due_date_calculator_screen.dart'
    show DdcMethod, ddcComputeEdd, ddcSourceFor;
import '../../v2/v2_palette.dart';
import '../auth_flow_screen.dart'
    show AuthFlowScreen, kAuthCompletedKey, kUserRoleKey;
import 'onboarding_art.dart';
import 'onboarding_chrome.dart';
import 'onboarding_questions.dart';
// Partner Editions A1: a clinic's QR binds at the end, and the first screen
// names who sent her.
import '../../../care_partner/care_journey.dart';
import '../../../care_partner/care_partner_models.dart' show CarePartner;
import '../../../care_partner/care_partner_store.dart';
import '../../care_partner/care_welcome_sheet.dart' show showCareWelcome;
import '../../../services/partner_brand.dart' show careLineDetail;
import '../../../widgets/pv_feedback.dart' show PvPress;

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
  // Onboarding V3 (2026-10-17): the partner's two ways in, and his link step.
  partnerHow,
  pLink,
}

/// True when the account that just signed in was created well before now,
/// so it is somebody coming back rather than somebody who has just joined.
///
/// ⚠️ A TIME, NOT A TABLE LOOK-UP. A brand-new Google sign-in creates the
/// account in the same breath, so its creation time is seconds old; an
/// account made on another day is not. It needs no query and no schema, and
/// when the time is unknown (Supabase not up, a preview) it says "new", which
/// is the old behaviour. The window is generous so a slow network cannot make
/// a new account look old. The trade-off: an account made earlier but never
/// finished is opened as it is, which is what signing back in means.
bool obAccountIsExisting(DateTime? createdAt, {DateTime? now}) {
  if (createdAt == null) return false;
  return (now ?? DateTime.now()).difference(createdAt.toLocal()) >
      const Duration(minutes: 10);
}

/// The "You already have an account" notice. Top-level so a widget test can
/// draw it without running Google. True: open it; false: use another.
Future<bool?> showObExistingAccountSheet(BuildContext context, String email) {
  final p = kObPalette;
  return showModalBottomSheet<bool>(
    context: context,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: p.ground,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Column(
          key: const ValueKey('ob_existing_account'),
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You already have an account.',
              style: pvFraunces(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.4,
                height: 1.2,
                color: p.ink1,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              email.isEmpty
                  // Plainer words 2026-10-10. Kept for revert: "This Google
                  // account was set up on ParentVeda before. We will open it
                  // as you left it. What you answered just now will not
                  // replace anything in it."
                  ? "You've used this Google account with us before, so we'll "
                        'open it just as you left it. What you answered just '
                        "now won't change anything in it."
                  : "You've used $email with us before, so we'll "
                        'open it just as you left it. What you answered just '
                        "now won't change anything in it.",
              style: pvManrope(fontSize: 14.5, height: 1.5, color: p.ink2),
            ),
            const SizedBox(height: 22),
            ObPrimary(
              p: p,
              label: 'Open my account',
              onTap: () => Navigator.of(ctx).pop(true),
            ),
            const SizedBox(height: 4),
            Center(
              child: ObLink(
                p: p,
                label: 'Use a different account',
                onTap: () => Navigator.of(ctx).pop(false),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({
    super.key,
    required this.pregnancy,
    required this.onDone,
    this.onDoctor,
    this.startAt = ObStep.welcome,
    this.startName = '',
    this.replay = false,
  });

  /// The developer's "Replay onboarding" (R6, 2026-10-25): every screen runs,
  /// and finishing writes NOTHING (no stage, no profile, no stores, no
  /// flags) before [onDone]. Before this the replay's own comment said
  /// "nothing it writes is kept" while `_finish` rewrote her stage and her
  /// answers on a phone with real data.
  final bool replay;

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

  // The birth, optional (gap analysis P1, Behind · Onboarding, 2026-10-07):
  // how the baby was born, whether early (and the weeks, if known), and who is
  // filling this in. Parenting only; none of it blocks Continue.
  BirthMode? _birthMode;
  bool? _bornEarly; // null = not answered; false = no; true = early
  int? _bornWeeks;
  bool _earlyNotSure = false;
  CareRole? _careRole;

  // ---- Onboarding V3 (2026-10-17) ---------------------------------------------
  // The partner who sets up on his own. Never asked about her body.
  bool _partnerOwn = false;
  String? _partnerHow; // 'code' | 'own', on the partnerHow screen

  // Trying: the month they want to start (getting ready), the kind of clinic
  // care, her last period, her age band. His age and habits.
  DateTime? _readyMonth;
  bool _readyUnsure = false;
  String? _clinicKind; // 'oi' | 'iui' | 'ivf' | 'unsure'
  DateTime? _lmp;
  bool _lmpUnknown = false;
  FertilityAgeBand? _ageBand;
  HisAge? _hisAge;
  final Set<String> _hisHabits = {}; // tobacco, alcohol, medicines, none

  // Pregnancy: what the scan said, the embryo's age, twins, and "gentle".
  int? _scanWeeks;
  int? _embryoDay;
  bool _twins = false;
  String? _gentle; // 'loss' | 'hard' | 'skip'

  // Parenting: twins, and a second child. Skilling: a real birthday.
  bool _childTwins = false;
  bool _secondChild = false;
  final _child2Name = TextEditingController();
  DateTime? _child2Dob;
  DateTime? _skDob;
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

  // Kept for revert (Onboarding V3): the stage's fixed list. `_run` and
  // `_runQuestions` replace it, because the run now depends on the answers.
  //   List<ObQuestion> get _questions =>
  //       onboardingQuestionsFor(_stage ?? '', childName: _childName.text);

  /// The doctor or clinic behind a QR she scanned before installing, looked
  /// up so the first screen can name them (Partner Editions A1). Null until
  /// the lookup lands, and for good when it cannot (offline, or the tables
  /// are not readable before sign-up): the box then says "your doctor".
  CarePartner? _careInviter;

  @override
  void initState() {
    super.initState();
    final care = CarePartnerStore.instance;
    final token = care.pendingToken;
    if (care.hasPending && token != null) {
      care.lookup(token).then((partner) {
        if (mounted && partner != null) setState(() => _careInviter = partner);
      });
    }
  }

  @override
  void dispose() {
    _childName.dispose();
    _child2Name.dispose();
    _nameField.dispose();
    _phone.dispose();
    _otp.dispose();
    super.dispose();
  }

  void _go(ObStep s) => setState(() => _history.add(s));

  /// The partner who set up on his own (not the one who joined with a code).
  bool get _isPartner => _partnerOwn;

  /// Her answer to "Where are you with this?": planning, trying or clinic.
  String? get _where => _answers['ttc_where']?.firstOrNull;
  bool get _planning => _where == 'planning';

  // The question run's own pages, beside the question ids.
  static const _kPromise = '#promise';
  static const _kPeriod = '#period';
  static const _kAboutHim = '#him';

  /// The run of questions for who she is and where she is, in order.
  ///
  /// ⚠️ IDS, NOT QUESTIONS, AND RECOMPUTED ON EVERY READ (Onboarding V3).
  /// Which questions are asked depends on earlier answers: "Getting ready"
  /// drops "How long have you been trying?", and the partner gets his own
  /// run. The promise beat sits in the run where the prototype put it rather
  /// than being inserted after the second answer.
  List<String> get _run {
    final he = _isPartner;
    switch (_stage) {
      case 'trying':
        if (he) {
          return ['ttc_where', if (!_planning) 'ttc_duration', _kPromise,
            _kAboutHim, 'p_help_trying'];
        }
        return ['ttc_where', _kPeriod, 'ttc_cycles', _kPromise,
          if (!_planning) 'ttc_duration', 'ttc_folic'];
      case 'pregnancy':
        return he
            ? ['p_first', _kPromise, 'p_help_pregnancy']
            : ['preg_parity', 'preg_priorities', _kPromise, 'preg_diet'];
      case 'parenting':
        return ['pp_feeding', 'pp_sleep', _kPromise, 'pp_priorities'];
      case 'skilling':
        return ['sk_interests', 'sk_time'];
    }
    return const [];
  }

  /// The questions in the run (its own pages left out), for the summary, the
  /// reveal and the re-apply in `_runBuild`.
  List<ObQuestion> get _runQuestions => [
    for (final id in _run)
      if (!id.startsWith('#')) obQuestion(id, childName: _childName.text),
  ];

  void _back() {
    if (_history.length <= 1) return;
    setState(() {
      if (_step == ObStep.question && _q > 0) {
        _q--;
        // Step back over the beat: it is a pause, not a question.
        if (_q > 0 && _run[_q] == _kPromise) _q--;
      } else {
        _history.removeLast();
        // Leaving the beat backwards lands on the question before it, never
        // on the beat's own empty slot in the run.
        final run = _run;
        if (_step == ObStep.question &&
            _q > 0 &&
            _q < run.length &&
            run[_q] == _kPromise) {
          _q--;
        }
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
  /// any, else straight to building.
  void _afterDate() {
    _q = 0;
    if (_run.isNotEmpty) {
      _go(ObStep.question);
    } else {
      _afterQuestions();
    }
  }

  // Kept for revert (Onboarding V3): the beat was inserted after the second
  // answer whenever a third followed. It now has its own place in `_run`.
  //   bool _promiseShown = false;
  //   if (_q == 1 && !_promiseShown) { _promiseShown = true; _go(beatPromise); }

  void _nextQuestion() {
    final run = _run;
    if (_q + 1 >= run.length) {
      _afterQuestions();
      return;
    }
    setState(() => _q++);
    if (run[_q] == _kPromise) _go(ObStep.beatPromise);
  }

  /// The promise beat's button: on to the question after it.
  void _afterPromise() {
    setState(() {
      _history.removeLast();
      if (_q + 1 < _run.length) {
        _q++;
      }
    });
    if (_q >= _run.length - 1 && _run[_q] == _kPromise) _afterQuestions();
  }

  void _afterQuestions() => _go(ObStep.building);

  /// What `building` does when its work is done: the reveal, for every stage
  /// since V3. Trying has one too now (one per path), because "Getting
  /// ready", a cycle and a clinic each have something true to show.
  void _afterBuilding() => _go(ObStep.reveal);

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
        final p = kObPalette;
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
          ObStep.partnerHow => _partnerHowPage(p),
          ObStep.pLink => _pLink(p),
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
                                // No lavender (Onboarding V3). Kept for revert: 268.0 third.
                                color: v2BlockTint([344.0, 42.0, 140.0][i], p),
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
                          // No number (2026-10-02, the user: "remove that
                          // 'loved by 50,000+', add a better filler line with
                          // no numbers"). A count we cannot show is a claim.
                          // Kept for revert: 'Loved by 50,000+ parents'.
                          child: Text(
                            'A calm companion, from trying to parenting',
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
                  // Kept for revert: 'For the whole journey — trying, expecting, raising.'
                  'With you from trying for a baby to raising one.',
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
                  // Kept for revert: 'A few questions first, so the app you
                  // open is already yours. No account needed to start.'
                  'A few quick questions and your app is ready for you. '
                  "You don't need an account to start.",
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
                // THE PARTNER VARIANT (Partner Editions A1): a QR from a
                // clinic is held until she has an account, then binds in
                // `_finish`. Told, not asked, exactly like a friend's code. A
                // sponsor has no variant here: an employer's benefit only
                // exists once she activates with her work email, after sign-up.
                if (CarePartnerStore.instance.hasPending) ...[
                  SizedBox(height: invited ? 10 : 20),
                  _careInvitedBox(p),
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
                      // ⚠️ NO DOCTOR PATH IN THE PARENT APP (2026-09-30, the
                      // user: "doctor app is different, it has nothing to do
                      // with the parent app... that path should not exist").
                      // Doctors use the doctor flavour (`--flavor doctor`,
                      // main_doctor.dart). Kept for revert:
                      // ObLink(p: p, label: "I'm a doctor", onTap: _doctor),
                      // if (!invited) ...[
                      //   Text('·', style: TextStyle(color: p.ink3)),
                      //   ObLink(p: p, label: 'Have a code?', onTap: _code),
                      // ],
                      if (!invited)
                        ObLink(p: p, label: 'Have a code?', onTap: _code),
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
    await _enterExistingAccount();
  }

  /// Hands a signed-in, already-existing account straight to the app.
  ///
  /// ⚠️ THE FLAG THE SPLASH READS (2026-09-30). This path signed her in but
  /// never set `kAuthCompletedKey`, so every restart found a live session
  /// with no flag and sent her through onboarding again (the user, on a hot
  /// restart: "it is making me go back to the initial sign in screen"). The
  /// other finishing path sets it in step 5 of `_finish`; this one now does
  /// too. The role already on the phone is kept, so a father signing back in
  /// is not turned into a mother.
  ///
  /// Shared since 2026-10-01 by the first-screen link and by the sign-in at
  /// the end of the questions, when that account turns out to exist already.
  Future<void> _enterExistingAccount() async {
    if (widget.replay) {
      widget.onDone(null, false); // R6: no flags written on a replay
      return;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(kAuthCompletedKey, true);
      if (prefs.getString(kUserRoleKey) == null) {
        await prefs.setString(kUserRoleKey, 'mother');
      }
    } catch (_) {
      /* best-effort */
    }
    if (!mounted) return;
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
                'Everything you add is saved on this phone first. It works '
                    'even with no signal.',
              ),
              _privacyLine(
                p,
                'Nobody outside your home sees it.',
                'Not advertisers, not employers, not insurers. Only a '
                    'partner you choose to link with can see what you log.',
              ),
              _privacyLine(
                p,
                'You can delete all of it.',
                'Go to You, then Data and privacy. One tap removes it from '
                    'this phone and from our servers.',
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
    // ⚠️ AN ACCOUNT THAT ALREADY EXISTS IS NOT A NEW ONE (2026-10-01, the
    // user: signed in with a Gmail that had an account, "it took me back to
    // the first screen of the onboarding flow… no alert of any sort").
    // Carrying on would run `_finish`, which WRITES this session's fresh
    // answers (stage, name, due date) over the profile that account already
    // has. So say so first, and open the account as it was; her answers from
    // this session do not replace anything. She can also choose a different
    // account, which signs this one back out.
    final who = _currentAccount();
    if (obAccountIsExisting(who.createdAt)) {
      final open = await _existingAccountSheet(who.email);
      if (!mounted) return;
      if (open == true) {
        setState(() => _busy = true);
        await _enterExistingAccount();
        if (mounted) setState(() => _busy = false);
      } else {
        await _signOutThisAccount();
      }
      return;
    }
    if (_name.trim().isEmpty) _name = _googleName();
    // His link step first (Onboarding V3). Kept for revert: _go(ObStep.reach).
    _go(_isPartner ? ObStep.pLink : ObStep.reach);
  }

  /// Who just signed in. Supabase may not be initialised (tests, previews):
  /// that is "unknown", never a crash.
  static ({String email, DateTime? createdAt}) _currentAccount() {
    try {
      final u = Supabase.instance.client.auth.currentUser;
      return (
        email: u?.email ?? '',
        createdAt: u == null ? null : DateTime.tryParse(u.createdAt),
      );
    } catch (_) {
      return (email: '', createdAt: null);
    }
  }

  /// "Use a different account": drops this session so the next tap on
  /// Continue with Google offers the account chooser again.
  Future<void> _signOutThisAccount() async {
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (_) {
      /* best-effort */
    }
    try {
      await SocialAuth.signOutGoogle();
    } catch (_) {
      /* best-effort */
    }
  }

  /// The notice. Two ways out, both said in words: open the account, or use
  /// another. Not dismissible by a stray tap: either choice changes what
  /// happens next.
  Future<bool?> _existingAccountSheet(String email) =>
      showObExistingAccountSheet(context, email);

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

  // Unreachable since 2026-09-30 (no doctor link in the parent app); kept for
  // revert with the link above.
  // ignore: unused_element
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
              "It's only shown at the top of your home. You can skip this if you like.",
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
  ///
  /// ⚠️ EVERY ROW SAYS WHAT IT IS AN ANSWER TO (2026-10-01, the user: the
  /// answers "look very vague"). It was the bare option label, "Just
  /// starting", "Yes, mostly", with nothing to say which question it
  /// answered, and trying to conceive had no line for its own stage at all.
  /// Now a row is (what it is, what she said), drawn as a small heading over
  /// the answer. The names live in `kObSummaryLabels`, beside the questions.
  /// Kept for revert: this returned `List<String>` of the bare labels.
  List<(String, String)> _summaryRows() {
    final out = <(String, String)>[];
    if (_name0.isNotEmpty) out.add(('Your name', _name0));
    if (_isPartner) out.add(('You are', 'Her partner'));
    switch (_stage) {
      case 'trying':
        final m = _readyMonth;
        out.add((
          'Your journey',
          _planning && m != null
              ? 'Getting ready to try · from ${readyMonthLabel(m)}'
              : switch (_where) {
                  'planning' => 'Getting ready',
                  'trying' => 'Trying on our own',
                  'clinic' => 'With a doctor or clinic',
                  _ => 'Trying to conceive',
                },
        ));
        if (_lmp != null) out.add(('Last period', _long(_lmp!)));
      case 'pregnancy':
        final edd = _edd;
        if (edd != null) {
          out.add(('Your pregnancy', 'Due ${_long(edd)}${_twins ? ' · twins' : ''}'));
        }
      case 'parenting':
        final dob = _childDob;
        if (dob != null) {
          final named = _childName.text.trim();
          out.add((
            'Your little one',
            '${named.isEmpty ? 'Your baby' : named}, ${_ageLine(dob)}',
          ));
        }
      case 'skilling':
        final named = _childName.text.trim();
        if (_childAge != null) {
          out.add((
            'Your child',
            named.isEmpty ? 'Age $_childAge' : '$named · age $_childAge',
          ));
        }
    }
    for (final q in _runQuestions) {
      if (q.id == 'ttc_where') continue; // said above, in words
      final chosen = _answers[q.id];
      if (chosen == null || chosen.isEmpty) continue;
      if (q.id == 'ttc_duration' && chosen.contains('skip')) continue;
      final labels = q.options
          .where((o) => chosen.contains(o.id))
          .map((o) => o.label)
          .join(' · ');
      if (labels.isNotEmpty) out.add((kObSummaryLabels[q.id] ?? '', labels));
    }
    return out;
  }

  /// Her first name, or empty. One definition — three screens greet her.
  String get _name0 =>
      _name.split(' ').where((w) => w.isNotEmpty).firstOrNull ?? '';

  // ---- the beats ----------------------------------------------------------------

  Widget _beatHello(V2Palette p) => ObBeat(
    p: p,
    // His own painting when he sets up alone (Onboarding V3).
    art: _isPartner ? ObArt.helloPartner : ObArt.hello,
    title: _name0.isEmpty ? 'Good to have you here.' : 'Hello, $_name0.',
    body: _isPartner
        ? 'This is your side of it. A few questions about where you two are, '
              'and a couple about you. Nothing about her is asked here. That '
              'comes from her, if she links and chooses to share.'
        : _stage == 'trying'
        ? "Tell us where you are with this, and we'll set things up for that. "
              'A few questions, and every answer is used.'
        :
        // Kept for revert: 'From here the app is yours. What it shows you on
        // a Tuesday morning depends on what you tell us next — the week you
        // are in, what you are worried about, what you would rather not read.'
        'This is your space now. Tell us a little about where you are and '
        "what's on your mind, and we'll show you what fits.",
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
    Widget? headline;
    if (_stage == 'pregnancy') {
      final edd = _edd;
      final days = edd == null ? 0 : 280 - edd.difference(_today()).inDays;
      final w = (days ~/ 7).clamp(0, 42);
      final tri = w < 13 ? 'first' : (w < 27 ? 'second' : 'third');
      title = 'Week $w.';
      headline = ObCountUp(
        value: w,
        builder: (n) => Text('Week $n.', style: obBeatTitleStyle(p)),
      );
      body =
          "You're in your $tri trimester. Each week has its own page: "
          "what's changing, what to ask your doctor, and what you don't "
          'need to worry about.';
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
          "We'll be right alongside you: what changes this month, what's "
          'normal at this age, and what other parents are asking right now.';
    }
    return ObBeat(
      p: p,
      art: ObArt.week,
      title: title,
      headline: headline,
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
    title: "What we'll never do.",
    body:
        // Kept for revert: 'We will never diagnose you, and we will never
        // contradict your doctor. When something needs a clinician we will
        // say so plainly and help you get ready for the appointment. If your
        // doctor has told you something different from what you read here,
        // your doctor is right.'
        "We'll never tell you what's wrong with you. That's a doctor's "
        "job, and we'll never go against yours. If something needs a "
        "doctor, we'll say so clearly and help you get ready for the visit. "
        'If your doctor says something different from what you read '
        'here, go with your doctor.',
    // The same promise as three lines she can take in at a glance (walk,
    // 2026-10-20: the paragraph above read as a block). [body] stays the
    // screen-reader text.
    points: const [
      (Icons.medical_services_outlined,
          "We don't diagnose. Only a doctor can do that."),
      (Icons.event_note_outlined,
          "If something needs a doctor, we'll tell you clearly and help "
          'you prepare.'),
      (Icons.verified_user_outlined,
          'If your doctor says something different, follow your doctor.'),
    ],
    cta: 'Good',
    // Kept for revert: setState(() { _q++; _history.removeLast(); }).
    onNext: _afterPromise,
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

  /// The second line names the real work for her path (Onboarding V3).
  List<String> get _buildLines => [
    'Saving your answers',
    switch (_stage) {
      'trying' when _isPartner => 'Setting up your side',
      'trying' when _planning => 'Starting your Ready-to-Try plan',
      'trying' when _where == 'clinic' => "Putting your clinic's timing first",
      'trying' => 'Working out your cycle',
      'pregnancy' => 'Working out your week',
      'parenting' => 'Working out their age',
      _ => 'Picking a first activity',
    },
    'Choosing what to show you first',
    'Setting up your home',
  ];
  // Kept for revert: the one fixed list for every stage.
  //   'Saving your answers', 'Working out your week',
  //   'Choosing what to show you first', 'Setting up your home'

  /// ⚠️ AFTER THE FRAME, NEVER DURING IT. `_building` calls this from its
  /// `build`, and the first thing it does is write to `FamilyProfileStore` —
  /// a `ChangeNotifier`. Notifying during a build is the classic crash.
  void _startBuilding() {
    if (_buildingStarted) return;
    _buildingStarted = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _runBuild();
    });
  }

  /// ⚠️ EACH TICK FOLLOWS ITS WORK (Onboarding V3, §5.4). The first line ticks
  /// when the answers are applied, the second when the reveal has been worked
  /// out from them. The work is quick, so a minimum pace keeps each line
  /// readable; it never ticks BEFORE its work. Lines three and four are the
  /// ordering the home does from these answers when it opens, and are paced.
  Future<void> _runBuild() async {
    final calm = obCalm(context);
    final pace = Duration(milliseconds: calm ? 0 : 420);
    Future<bool> tick(int i, void Function() work) async {
      final sw = Stopwatch()..start();
      work();
      final rest = pace - sw.elapsed;
      if (rest > Duration.zero) await Future<void>.delayed(rest);
      if (!mounted || _step != ObStep.building) return false;
      setState(() => _built = i);
      return true;
    }

    // ⚠️ IDEMPOTENT ON PURPOSE. Each question already applied itself when
    // she tapped; this lands the LAST state, after any change of mind.
    if (!await tick(1, () {
      for (final q in _runQuestions) {
        final chosen = _answers[q.id];
        if (chosen != null) q.apply(FamilyProfileStore.instance, chosen);
      }
    })) {
      return;
    }
    if (!await tick(2, () => _revealData())) return;
    if (!await tick(3, () {})) return;
    if (!await tick(4, () {})) return;
    await Future<void>.delayed(Duration(milliseconds: calm ? 0 : 460));
    if (mounted && _step == ObStep.building) _afterBuilding();
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
            'Everything so far is saved on this phone. An account keeps it '
            'safe if you ever change phones, and lets your partner join you.',
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
            // Each row ticks in, like things being packed (§5.6).
            ObStagger(
              step: const Duration(milliseconds: 70),
              children: [
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (row.$1.isNotEmpty)
                            Text(
                              row.$1,
                              style: pvManrope(
                                fontSize: 11.5,
                                height: 1.3,
                                fontWeight: FontWeight.w600,
                                color: p.ink3,
                              ),
                            ),
                          Text(
                            row.$2,
                            style: pvManrope(
                              fontSize: 14.5,
                              height: 1.4,
                              fontWeight: FontWeight.w600,
                              color: p.ink1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ],
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
              // Ink and underlined since V3 (no violet in onboarding).
              TextSpan(
                text: 'Terms',
                style: TextStyle(
                  color: p.action,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.underline,
                ),
              ),
              const TextSpan(text: ' and '),
              TextSpan(
                text: 'Privacy Policy',
                style: TextStyle(
                  color: p.action,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.underline,
                ),
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
      backgroundColor: kObPalette.ground,
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
                color: kObPalette.ink1,
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
              p: kObPalette,
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
        subtitle: 'The other person gets their own app, linked to yours.',
      ),
      // ⚠️ THIS SCREEN WAS THE ONE THAT DID NOT GET THE TREATMENT — the user,
      // 2026-09-22: two portraits now, drawn as a pair and turned toward each
      // other, with a taller well than the four-up stage cards.
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ObGridCard(
              p: p,
              title: 'Mother',
              subtitle: 'Trying, pregnant or a parent',
              icon: Icons.favorite_border_rounded,
              art: ObArt.whoMother,
              artHeight: 132,
              hue: 344,
              selected: false,
              onTap: () {
                _partnerOwn = false;
                _go(ObStep.stage);
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ObGridCard(
              p: p,
              title: 'Partner',
              // Kept for revert: 'Join with her code'. Since V3 he can also
              // set up on his own.
              subtitle: 'Father, or the other parent',
              icon: Icons.people_outline_rounded,
              art: ObArt.whoPartner,
              artHeight: 132,
              hue: 104,
              selected: false,
              // Kept for revert: onTap: _partner (straight to the code).
              onTap: () => _go(ObStep.partnerHow),
            ),
          ),
        ],
      ),
      const SizedBox(height: 18),
      Text(
        'We only keep a name that its owner gave us.',
        style: pvManrope(fontSize: 12.5, height: 1.4, color: p.ink3),
      ),
    ],
  );

  /// The partner's two ways in (Onboarding V3, 2026-10-17).
  ///
  /// ⚠️ A FATHER WITHOUT HER CODE USED TO HAVE NO WAY IN, and "Set up my own"
  /// elsewhere sent him through her questions about her body (the user,
  /// 2026-10-17). Mobbin: Flo is invite-only from her side; Stardust lets
  /// either start. We let him start, and keep her in control: his side runs
  /// on what HE told us until she types his code and chooses to share.
  Widget _partnerHowPage(V2Palette p) {
    final how = _partnerHow;
    return ObPage(
      p: p,
      onBack: _back,
      body: [
        ObHead(
          p: p,
          eyebrow: 'Partner',
          title: 'How are you joining?',
          subtitle:
              "Either way, you see the same stage she's in, written for you.",
        ),
        ObTile(
          p: p,
          title: 'I have her code',
          subtitle: 'Six characters, from her You screen',
          selected: how == 'code',
          onTap: () => setState(() => _partnerHow = 'code'),
        ),
        const SizedBox(height: 8),
        ObTile(
          p: p,
          title: 'Set up on my own',
          subtitle: 'She can link with you later',
          selected: how == 'own',
          onTap: () => setState(() => _partnerHow = 'own'),
        ),
        ObGiveBack(
          p: p,
          text: switch (how) {
            'code' =>
              'Your app links to hers. You see what she chooses to share, '
                  'and nothing she logs privately.',
            'own' =>
              "You get your own home for the stage you're in, written to you "
                  'as the partner. When she links with you, the two homes '
                  'join up.',
            _ => '',
          },
        ),
      ],
      bottom: ObPrimary(
        p: p,
        label: 'Continue',
        onTap: how == null
            ? null
            : () {
                if (how == 'code') {
                  _partnerOwn = false;
                  _partner();
                } else {
                  _partnerOwn = true;
                  _go(ObStep.stage);
                }
              },
      ),
    );
  }

  void _partner() {
    // R6: pairing links this phone to a real account, so a replay says why it
    // stops here instead of doing it (never a silent tap).
    if (widget.replay) {
      _say('Pairing is skipped in a replay: it would link this phone to a partner.');
      return;
    }
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
          title: _isPartner
              ? 'Where are you two right now?'
              : 'Where are you right now?',
          subtitle: _isPartner
              ? 'This shapes your side of the app. Once she links, it follows hers.'
              : 'This shapes your home. You can change it any time.',
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: card(
                'trying',
                'Trying to conceive',
                // V3: getting ready is part of this stage now. Kept for
                // revert: 'Cycle and timing'.
                'Or getting ready to',
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
                344, // was 275, a violet (no lavender, Onboarding V3)
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
                'Parent, 0 to 5',
                // Gap analysis P2 (2026-10-07): the promise the setup makes. Kept for revert: 'Sleep and leaps'.
                'Sleep, feeding and every month',
                Icons.child_care_rounded,
                140, // was 205 (Onboarding V3, the prototype's sage)
                ObArt.stageParenting,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: card(
                'skilling',
                'Skilling, 6 and up',
                'Skills and habits',
                Icons.school_outlined,
                150,
                ObArt.stageSkilling,
              ),
            ),
          ],
        ),
        // Kept for revert: "Expecting twins or more? You can say so later."
        // There was no later; twins are asked on the date pages since V3.
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

  /// The due date from what she gave.
  ///
  /// ⚠️ SCAN WEEKS AND EMBRYO DAY ARE ASKED NOW (Onboarding V3). Before, a
  /// scan date was always read as an 8-week scan and every transfer as a
  /// day-5 embryo, so a 12-week scan put her due date four weeks late. The
  /// date waits until the second answer is in.
  DateTime? get _edd {
    final d = _methodDate;
    if (d == null) return null;
    if (_method == DdcMethod.ultrasound && _scanWeeks == null) return null;
    if (_method == DdcMethod.ivf && _embryoDay == null) return null;
    return ddcComputeEdd(
      method: _method,
      lmp: d,
      known: d,
      scan: d,
      transfer: d,
      gaWeeks: _scanWeeks ?? 8,
      embryoDay: _embryoDay ?? 5,
    );
  }

  /// (week, day) on the due date [edd], today.
  (int, int) _weekDay(DateTime edd) {
    final days = 280 - edd.difference(_today()).inDays;
    return ((days ~/ 7).clamp(0, 42), (days % 7).clamp(0, 6));
  }

  Widget _datePregnant(V2Palette p) {
    // The partner is never asked about her period (Onboarding V3).
    final methods = [
      for (final e in _methods)
        if (!(_isPartner && e.$1 == DdcMethod.lmp)) e,
    ];
    if (!methods.any((e) => e.$1 == _method)) _method = methods.first.$1;
    final m = methods.firstWhere((e) => e.$1 == _method);
    final edd = _edd;
    final known = _method == DdcMethod.known;
    final src = switch (_method) {
      DdcMethod.known =>
        " Your doctor gave this date, so we'll never recalculate it.",
      DdcMethod.ultrasound =>
        " It comes from your scan, so we'll never recalculate it.",
      DdcMethod.ivf =>
        " It comes from your transfer date, so we'll never recalculate it.",
      _ => '',
    };
    return ObPage(
      p: p,
      onBack: _back,
      body: [
        ObHead(p: p, eyebrow: 'Your dates', title: 'When is the baby due?'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final e in methods)
              ObPill(
                p: p,
                label: e.$2,
                selected: _method == e.$1,
                onTap: () => setState(() {
                  _method = e.$1;
                  _methodDate = null;
                }),
              ),
          ],
        ),
        const SizedBox(height: 16),
        ObField(
          p: p,
          label: m.$3,
          onTap: () => _pickDate(
            initial: _methodDate ?? DateTime.now(),
            first: known
                ? DateTime.now()
                : DateTime.now().subtract(const Duration(days: 300)),
            last: known
                ? DateTime.now().add(const Duration(days: 300))
                : DateTime.now(),
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
        if (_method == DdcMethod.ultrasound) ...[
          _subLabel(p, 'How many weeks did the scan say?'),
          Wrap(spacing: 6, runSpacing: 6, children: [
            for (var w = 6; w <= 13; w++)
              ObPill(
                p: p,
                label: '$w wk',
                selected: _scanWeeks == w,
                onTap: () => setState(() => _scanWeeks = w),
              ),
          ]),
        ],
        if (_method == DdcMethod.ivf) ...[
          _subLabel(p, 'Embryo age at transfer'),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final d in const [3, 5])
              ObPill(
                p: p,
                label: 'Day $d',
                selected: _embryoDay == d,
                onTap: () => setState(() => _embryoDay = d),
              ),
          ]),
        ],
        // Kept for revert: the stage screen's "Expecting twins or more? You
        // can say so later." There was no later; it is asked here now.
        _subLabel(p, 'Expecting more than one?'),
        Wrap(spacing: 8, children: [
          ObPill(
            p: p,
            label: 'Twins or more',
            selected: _twins,
            onTap: () => setState(() => _twins = !_twins),
          ),
        ]),
        if (edd != null)
          ObGiveBack(
            p: p,
            text: () {
              final (w, d) = _weekDay(edd);
              return 'Due ${_long(edd)}. You\'re in week $w, day $d.$src'
                  '${_twins ? ' Twin pregnancies have their own scan schedule, and we\'ll show it.' : ''}';
            }(),
          )
        else ...[
          const SizedBox(height: 14),
          Text(
            _isPartner
                ? 'Use the date her doctor gave you. If she links later, her '
                      'date takes over.'
                : 'Not sure? The first day of your last period is enough to '
                      'start. You can change it any time.',
            style: pvManrope(fontSize: 12.5, height: 1.45, color: p.ink3),
          ),
        ],
      ],
      bottom: ObPrimary(
        p: p,
        label: 'Continue',
        onTap: edd == null ? null : _afterDatePage,
      ),
    );
  }

  /// A small label over a row of pills, inside a page.
  Widget _subLabel(V2Palette p, String text, {String? optional}) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 8),
    child: Text.rich(
      TextSpan(
        text: text,
        style: pvManrope(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: p.ink2,
        ),
        children: [
          if (optional != null)
            TextSpan(
              text: '  $optional',
              style: pvManrope(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: p.ink3,
              ),
            ),
        ],
      ),
    ),
  );

  /// The name as it reads mid-question: "Meera", or "your baby".
  String _obChildName() {
    final n = _childName.text.trim();
    return n.isEmpty ? 'your baby' : n;
  }

  Widget _dateChild(V2Palette p, {required bool skilling}) {
    final ready = skilling ? _childAge != null : _childDob != null;
    final dob = _childDob;
    final who = _childName.text.trim().isEmpty
        ? (skilling ? 'Your child' : 'Your baby')
        : _childName.text.trim();
    String give = '';
    if (!skilling && dob != null) {
      give = '$who is ${_ageLine(dob)}';
      final w = _bornWeeks;
      if (_bornEarly == true && w != null) {
        final corrected = DateTime(dob.year, dob.month, dob.day + (40 - w) * 7);
        if (corrected.isBefore(_today())) {
          give += ', or ${_ageLine(corrected)} counted from the due date. '
              "We'll use that one for milestones";
        }
      }
      give += '.';
      if (_birthMode == BirthMode.cSection) {
        give += ' Your own recovery pages start with healing after a C-section.';
      }
      if (_careRole == CareRole.father) give += " We'll write to you as dad.";
    }
    if (skilling && _childAge != null) {
      give = 'We pick activities for age $_childAge.'
          '${_skDob != null ? ' With the birthday, the next age band starts on the right day.' : ' Add a birthday and the next age band starts on the right day, not on a guess.'}';
    }
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
              hint: skilling ? "Your child's name" : "Your baby's name",
              style: pvFraunces(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: p.ink3,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        if (skilling) ...[
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
                    onTap: () => setState(() {
                      _childAge = a;
                      // A birthday that disagrees with the age is dropped.
                      if (_skDob != null && _yearsSince(_skDob!) != a) {
                        _skDob = null;
                      }
                    }),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Onboarding V3: a real date of birth when she gives one. Until now
          // it was always "today, N years ago", so every child's next age band
          // started on the day they signed up.
          ObField(
            p: p,
            label: 'Birthday — optional',
            onTap: () => _pickDate(
              initial: _skDob ??
                  DateTime(_today().year - (_childAge ?? 7), _today().month),
              first: DateTime(_today().year - 13, _today().month, _today().day),
              last: DateTime(_today().year - 6, _today().month, _today().day),
              onPicked: (d) => setState(() {
                _skDob = d;
                _childAge = _yearsSince(d).clamp(6, 12);
              }),
            ),
            child: Text(
              _skDob == null ? 'Tap to choose' : _long(_skDob!),
              style: pvFraunces(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: _skDob == null ? p.ink3 : p.ink1,
              ),
            ),
          ),
        ] else
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
          label: 'Boy or girl (optional)',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
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
              if (!skilling)
                ObPill(
                  p: p,
                  label: 'Twins',
                  selected: _childTwins,
                  onTap: () => setState(() => _childTwins = !_childTwins),
                ),
            ],
          ),
        ),
        if (!skilling) ...[
          // The partner is not asked how she gave birth (Onboarding V3).
          if (!_isPartner) ...[
            const SizedBox(height: 10),
            ObField(
              p: p,
              label: 'How was ${_obChildName()} born? Optional',
              child: Wrap(spacing: 8, runSpacing: 8, children: [
                for (final m in BirthMode.values)
                  ObPill(
                    p: p,
                    label: m.label,
                    selected: _birthMode == m,
                    onTap: () => setState(() => _birthMode = m),
                  ),
              ]),
            ),
          ],
          const SizedBox(height: 10),
          ObField(
            p: p,
            label: 'Was ${_obChildName()} born early? Optional',
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Wrap(spacing: 8, runSpacing: 8, children: [
                ObPill(
                  p: p,
                  label: 'No',
                  selected: _bornEarly == false,
                  onTap: () => setState(() {
                    _bornEarly = false;
                    _bornWeeks = null;
                    _earlyNotSure = false;
                  }),
                ),
                ObPill(
                  p: p,
                  label: 'Yes, early',
                  selected: _bornEarly == true,
                  onTap: () => setState(() {
                    _bornEarly = true;
                    _earlyNotSure = false;
                  }),
                ),
                ObPill(
                  p: p,
                  label: 'Not sure',
                  selected: _earlyNotSure,
                  onTap: () => setState(() {
                    _earlyNotSure = true;
                    _bornEarly = null;
                    _bornWeeks = null;
                  }),
                ),
              ]),
              if (_bornEarly == true) ...[
                const SizedBox(height: 10),
                Text('At how many weeks, if you know?',
                    style: pvManrope(fontSize: 13, fontWeight: FontWeight.w600, color: p.ink2)),
                const SizedBox(height: 6),
                Wrap(spacing: 6, runSpacing: 6, children: [
                  for (var w = 26; w <= 36; w++)
                    ObPill(
                      p: p,
                      label: '$w',
                      selected: _bornWeeks == w,
                      onTap: () => setState(() => _bornWeeks = w),
                    ),
                ]),
              ],
            ]),
          ),
          if (!_isPartner) ...[
            const SizedBox(height: 10),
            ObField(
              p: p,
              label: 'Who are you to ${_obChildName()}? Optional',
              child: Wrap(spacing: 8, runSpacing: 8, children: [
                for (final r in CareRole.values)
                  ObPill(
                    p: p,
                    label: r.label,
                    selected: _careRole == r,
                    onTap: () => setState(() => _careRole = r),
                  ),
              ]),
            ),
          ],
          // Onboarding V3: a second child, here rather than "later" (§62.3).
          if (_secondChild) ...[
            _subLabel(p, 'Another child'),
            ObField(
              p: p,
              label: 'Name — optional',
              child: TextField(
                controller: _child2Name,
                textCapitalization: TextCapitalization.words,
                onChanged: (_) => setState(() {}),
                style: pvFraunces(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: p.ink1,
                ),
                decoration: obBareInput(
                  hint: 'Name',
                  style: pvFraunces(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: p.ink3,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            ObField(
              p: p,
              label: 'Birthday',
              onTap: () => _pickDate(
                initial: _child2Dob ?? DateTime.now(),
                first: DateTime.now().subtract(const Duration(days: 365 * 6)),
                last: DateTime.now(),
                onPicked: (d) => setState(() => _child2Dob = d),
              ),
              child: Text(
                _child2Dob == null ? 'Tap to choose' : _long(_child2Dob!),
                style: pvFraunces(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: _child2Dob == null ? p.ink3 : p.ink1,
                ),
              ),
            ),
          ] else
            Align(
              alignment: Alignment.centerLeft,
              child: ObLink(
                p: p,
                label: '+ Add another child',
                center: false,
                onTap: () => setState(() => _secondChild = true),
              ),
            ),
        ],
        ObGiveBack(p: p, text: give),
        if (give.isEmpty) ...[
          const SizedBox(height: 14),
          Text(
            skilling
                ? "We pick activities by age. That's all we need."
                // "and the leaps" dropped 2026-10-07: the app no longer counts by them.
                : 'The name is up to you. We count the weeks and months from the birthday, '
                      'and the birth answers help us show the right pages first.',
            style: pvManrope(fontSize: 12.5, height: 1.45, color: p.ink3),
          ),
        ],
      ],
      bottom: ObPrimary(
        p: p,
        label: 'Continue',
        onTap: ready ? _afterDatePage : null,
      ),
    );
  }

  static int _yearsSince(DateTime d) {
    final n = _today();
    var y = n.year - d.year;
    if (n.month < d.month || (n.month == d.month && n.day < d.day)) y--;
    return y;
  }

  /// "4 months, 2 weeks", "6 weeks old", "2 years, 5 months".
  static String _ageLine(DateTime dob) {
    final (m, w) = _monthsWeeks(dob);
    if (m >= 24) {
      final rest = m % 12;
      return '${m ~/ 12} years${rest == 0 ? '' : ', $rest ${rest == 1 ? 'month' : 'months'}'}';
    }
    if (m < 2) {
      final weeks = _today().difference(dob).inDays ~/ 7;
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} old';
    }
    return '$m months${w == 0 ? '' : ', $w ${w == 1 ? 'week' : 'weeks'}'}';
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
    final run = _run;
    if (run.isEmpty) return const SizedBox.shrink();
    final id = run[_q.clamp(0, run.length - 1)];
    if (id == _kPeriod) return _ttcPeriod(p);
    if (id == _kAboutHim) return _aboutHim(p);
    if (id == _kPromise) return const SizedBox.shrink(); // the beat shows
    final q = obQuestion(id, childName: _childName.text);
    final chosen = _answers[q.id] ?? <String>{};
    final giveBack = _giveBackFor(q, chosen);

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

    return _questionPage(
      p,
      title: _titleFor(q),
      subtitle: q.subtitle,
      canContinue: chosen.isNotEmpty,
      body: [
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
              subtitle: o.subtitle,
              selected: chosen.contains(o.id),
              compact: true,
              onTap: () => choose(o),
            ),
            const SizedBox(height: 8),
          ],
        ..._extraFor(p, q, chosen),
        ObGiveBack(p: p, text: giveBack),
      ],
    );
  }

  /// The frame every page in the run shares: the named bar, Skip, the
  /// question, and Continue.
  Widget _questionPage(
    V2Palette p, {
    required String title,
    String? subtitle,
    required bool canContinue,
    required List<Widget> body,
  }) {
    final run = _run;
    final asked = [for (final id in run) if (id != _kPromise) id];
    final here = run[_q.clamp(0, run.length - 1)];
    return ObPage(
      p: p,
      onBack: _back,
      trailing: ObLink(p: p, label: 'Skip', onTap: _nextQuestion),
      body: [
        // ⚠️ THE ONE PLACE A BAR BELONGS — see onboarding_chrome's header for
        // why the "no progress bar anywhere" rule was narrowed rather than
        // dropped. Named with the stage (Noom's finding).
        ObProgress(
          p: p,
          label: _isPartner
              ? switch (_stage) {
                  'trying' => 'About you two',
                  'pregnancy' => 'About you and the baby',
                  _ => 'About your baby',
                }
              : switch (_stage) {
                  'pregnancy' => 'About your pregnancy',
                  'trying' => 'About where you are',
                  'skilling' => 'About your child',
                  _ => 'About your baby',
                },
          step: asked.indexOf(here) + 1,
          total: asked.length,
        ),
        const SizedBox(height: 22),
        ObHead(p: p, title: title, subtitle: subtitle),
        ...body,
      ],
      bottom: ObPrimary(
        p: p,
        label: 'Continue',
        onTap: canContinue ? _nextQuestion : null,
      ),
    );
  }

  /// The partner reads the shared questions about "you two".
  String _titleFor(ObQuestion q) =>
      _isPartner && q.id == 'ttc_where' ? 'Where are you two with this?' : q.title;

  static const _monthsShort = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  /// The seven months they can choose to start in: next month and six more,
  /// the same choice the TTC intro offered (d8724d1).
  List<DateTime> get _readyMonths {
    final t = _today();
    return [for (var i = 1; i <= 7; i++) DateTime(t.year, t.month + i)];
  }

  /// What appears under a question once it is answered, in place (no extra
  /// screen): the month, the kind of clinic care, her age band, "gentle".
  List<Widget> _extraFor(V2Palette p, ObQuestion q, Set<String> chosen) {
    switch (q.id) {
      case 'ttc_where':
        if (chosen.contains('planning')) {
          return [
            _subLabel(p, 'Which month do you want to start trying?',
                optional: 'Optional'),
            Wrap(spacing: 6, runSpacing: 6, children: [
              for (final m in _readyMonths)
                ObPill(
                  p: p,
                  label: _monthsShort[m.month - 1],
                  selected: _readyMonth == m,
                  onTap: () => setState(() {
                    _readyMonth = m;
                    _readyUnsure = false;
                  }),
                ),
              ObPill(
                p: p,
                label: 'Not sure yet',
                selected: _readyUnsure,
                onTap: () => setState(() {
                  _readyMonth = null;
                  _readyUnsure = true;
                }),
              ),
            ]),
          ];
        }
        if (chosen.contains('clinic')) {
          return [
            _subLabel(p, 'Which kind?', optional: 'Optional'),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final (id, label) in const [
                ('oi', 'Ovulation medicine'),
                ('iui', 'IUI'),
                ('ivf', 'IVF'),
                ('unsure', 'Not sure yet'),
              ])
                ObPill(
                  p: p,
                  label: label,
                  selected: _clinicKind == id,
                  onTap: () => setState(() => _clinicKind = id),
                ),
            ]),
          ];
        }
      case 'ttc_duration':
        return [
          _subLabel(p, _isPartner ? 'Her age' : 'Your age',
              optional: 'Optional. It changes when we suggest a check-up'),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final b in FertilityAgeBand.values)
              ObPill(
                p: p,
                label: b.label.en,
                selected: _ageBand == b,
                onTap: () => setState(() => _ageBand = b),
              ),
          ]),
        ];
      case 'preg_parity':
        if (chosen.contains('subsequent')) {
          return [
            _subLabel(p, 'Anything we should be gentle about?',
                optional: 'Optional'),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final (id, label) in const [
                ('loss', 'A past loss'),
                ('hard', 'A hard birth'),
                ('skip', 'Rather not say'),
              ])
                ObPill(
                  p: p,
                  label: label,
                  selected: _gentle == id,
                  onTap: () => setState(() => _gentle = id),
                ),
            ]),
          ];
        }
    }
    return const [];
  }

  /// When a check-up is worth suggesting, from how long and her age band.
  /// The population guidance (a year under 35, six months from 35, soon
  /// from 40), never a personal probability.
  bool get _doctorSoon {
    final d = _answers['ttc_duration']?.firstOrNull;
    final a = _ageBand;
    final from35 = a != null && a != FertilityAgeBand.under35;
    return d == 'year' ||
        (d == 'six' && from35) ||
        (d == 'months' && a == FertilityAgeBand.over40);
  }

  /// The give-back, where it depends on more than the option tapped.
  String _giveBackFor(ObQuestion q, Set<String> chosen) {
    if (chosen.isEmpty) return '';
    final first = chosen.first;
    String labels(int n) => [
      for (final id in chosen.take(n))
        q.options.firstWhere((o) => o.id == id).label.toLowerCase(),
    ].join(' and ');
    switch (q.id) {
      case 'ttc_where':
        final m = _readyMonth;
        if (_isPartner) {
          return switch (first) {
            'planning' =>
              'Good timing for you too. Sperm take about three months to '
                  'develop, so what you change now counts by '
                  '${m == null ? 'the time you start' : readyMonthLabel(m)}.',
            'trying' =>
              'Your side explains the timing: what the fertile days are and '
                  'how you can help. Her own dates show only if she links and '
                  'chooses to share them.',
            _ =>
              "Then her clinic sets the timing. Your side covers the steps "
                  "you're part of, and what to ask at the appointments you go to.",
          };
        }
        if (first == 'planning' && m != null) {
          return 'Good timing. Starting a few months early gives folic acid '
              'and a check-up time to work. Your Ready-to-Try plan counts '
              'down to ${readyMonthLabel(m)}, and the "how long trying" clock '
              'only starts then.';
        }
      case 'ttc_duration':
        if (first == 'skip') break;
        if (_doctorSoon) {
          return "It's a good time to see a doctor, for both of you. It's a "
              "calm check, not an emergency, and we'll help you prepare the "
              'questions.';
        }
        final lead = first == 'starting'
            ? 'Most couples get pregnant within a year. The first months are '
                  'for getting to know your cycle.'
            : 'This is still normal for many couples.';
        final rule = switch (_ageBand) {
          FertilityAgeBand.under35 =>
            'Under 35, doctors suggest a check-up after a year of trying.',
          FertilityAgeBand.over40 =>
            'From 40, doctors suggest seeing someone soon rather than waiting.',
          null =>
            "Tell us your age and we'll know when a check-up makes sense.",
          _ => 'From 35, doctors suggest a check-up after six months.',
        };
        return '$lead $rule';
      case 'preg_parity':
        if (first == 'subsequent') {
          return switch (_gentle) {
            'loss' =>
              "Thank you for telling us. We'll keep the countdown quiet, and "
                  "loss stories stay out of your feed unless you look for them.",
            'hard' => "Thank you for telling us. You don't have to say more.",
            _ =>
              "Then we'll skip the basics you already know and start with "
                  "what's different this time.",
          };
        }
      case 'preg_priorities':
        return 'Your home will open with ${labels(2)}'
            '${chosen.length > 2 ? ', then the rest' : ''}. You can change '
            'this any time in You.';
      case 'pp_priorities':
        return 'Your home will open with ${labels(2)}. You can change this '
            'any time in You.';
      case 'p_help_trying':
      case 'p_help_pregnancy':
        return 'Your side will open with ${labels(2)}.';
      case 'sk_interests':
        final a = skFirstActivity((chosen.toList()..sort()).join(','), null);
        if (a != null) {
          return "Today's first activity: ${a.title}. The rest follow from "
              'there.';
        }
    }
    return q.multi
        ? (q.multiGiveBack ?? '')
        : q.options.firstWhere((o) => o.id == first).giveBack;
  }

  /// Her fertile window from the one date she gave, worked out by the same
  /// engine the home uses, so the two can never disagree (`TtcChapterEngine`,
  /// the window constants in `ttc_fertile_window.dart`). Null when the engine
  /// would not estimate, or when a clinic runs the timing.
  ({DateTime opens, DateTime closes, DateTime next})? get _ttcWindow {
    final lmp = _lmp;
    if (lmp == null || _lmpUnknown || _where == 'clinic') return null;
    const engine = TtcChapterEngine();
    final today = _today();
    final st = TtcJourneyState(
      lastPeriodStart: lmp,
      today: today,
      statedIrregular: _answers['ttc_cycles']?.contains('no') ?? false,
    );
    final ov = engine.estimatedOvulationDay(st);
    if (ov == null) return null;
    final len = engine.cycleLengthFor(st);
    final day0 = DateTime(lmp.year, lmp.month, lmp.day);
    final cycleDay = today.difference(day0).inDays + 1;
    final opens = ov - ttcWindowOpensBeforeOvulation;
    final closes = ov + ttcWindowClosesAfterOvulation;
    var ahead = 0;
    while (cycleDay > closes + ahead * len && ahead < 24) {
      ahead++;
    }
    DateTime dateOf(int d) =>
        DateTime(day0.year, day0.month, day0.day + d - 1 + ahead * len);
    var k = 1;
    while (!DateTime(day0.year, day0.month, day0.day + k * len)
        .isAfter(today)) {
      k++;
    }
    return (
      opens: dateOf(opens),
      closes: dateOf(closes),
      next: DateTime(day0.year, day0.month, day0.day + k * len),
    );
  }

  /// "When did your last period start?" (Onboarding V3). Moved here from the
  /// TTC intro, so she sees her fertile days before she makes an account
  /// (Flo and Oura do the same).
  Widget _ttcPeriod(V2Palette p) {
    final w = _ttcWindow;
    final String give;
    if (_lmpUnknown) {
      give = "That's fine. Tap \"Period started\" on the first day of your "
          "next one, and we'll start from there.";
    } else if (_lmp != null && _where == 'clinic') {
      give = 'Saved. Your clinic will ask for this date, so it is ready when '
          'they do.';
    } else if (w != null) {
      give = 'If your cycle is about 28 days, your next period is around '
          '${_short(w.next)} and your fertile days are likely around '
          '${_short(w.opens)} to ${_short(w.closes)}. Each period you log '
          'makes this sharper.';
    } else if (_lmp != null) {
      give = "Saved. That was a while ago, so we'll start the estimate from "
          'your next period.';
    } else {
      give = '';
    }
    return _questionPage(
      p,
      title: 'When did your last period start?',
      subtitle: switch (_where) {
        'planning' =>
          "Start logging now and you'll know your cycle well by the time you "
              'begin.',
        'clinic' =>
          "Your clinic asks for this at almost every visit. We'll keep it "
              'ready for you.',
        _ => 'This one date gives us your cycle and your likely fertile days.',
      },
      canContinue: _lmp != null || _lmpUnknown,
      body: [
        ObField(
          p: p,
          label: 'First day of your last period',
          onTap: () => _pickDate(
            initial: _lmp ?? _today(),
            first: _today().subtract(const Duration(days: 90)),
            last: _today(),
            onPicked: (d) => setState(() {
              _lmp = d;
              _lmpUnknown = false;
            }),
          ),
          child: Text(
            _lmp == null ? 'Tap to choose' : _long(_lmp!),
            style: pvFraunces(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: _lmp == null ? p.ink3 : p.ink1,
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: ObLink(
            p: p,
            center: false,
            label: _lmpUnknown ? 'I remember it now' : "I don't remember",
            onTap: () => setState(() {
              _lmpUnknown = !_lmpUnknown;
              if (_lmpUnknown) _lmp = null;
            }),
          ),
        ),
        ObGiveBack(p: p, text: give),
      ],
    );
  }

  /// "A little about you." His part of the Ready-to-Try plan: the plan's own
  /// two questions for him (`HisAge`, `HisHabit`), asked here rather than
  /// invented, and saved where the plan reads them.
  Widget _aboutHim(V2Palette p) {
    final h = _hisHabits;
    final give = [
      if (_hisAge == HisAge.fortyOrOver) 'From 40, a check-up early on is worth it.',
      if (h.contains('tobacco'))
        'Stopping tobacco is the biggest single thing you can do for sperm '
            'health, and it counts in about three months.',
      if (h.contains('alcohol'))
        'Cutting down on drinks helps too, and it also counts in about three '
            'months.',
      if (h.contains('medicines'))
        "Some everyday medicines affect sperm. Ask your doctor, but don't stop "
            'anything on your own.',
      if (h.contains('none'))
        "Good. A quick check-up is still worth it, and for men it's simple.",
    ].join(' ');
    void toggle(String id) => setState(() {
      if (id == 'none') {
        final had = h.contains('none');
        h.clear();
        if (!had) h.add('none');
      } else {
        h.remove('none');
        h.contains(id) ? h.remove(id) : h.add(id);
      }
    });
    return _questionPage(
      p,
      title: 'A little about you.',
      subtitle: 'For your part of the plan. It stays on your phone unless you '
          'choose to share it.',
      canContinue: _hisAge != null || h.isNotEmpty,
      body: [
        _subLabel(p, 'Your age'),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final a in HisAge.values)
            ObPill(
              p: p,
              label: a.label,
              selected: _hisAge == a,
              onTap: () => setState(() => _hisAge = a),
            ),
        ]),
        _subLabel(p, 'Any of these?', optional: 'Pick all that fit'),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final x in HisHabit.values)
            ObPill(
              p: p,
              label: x.label,
              selected: h.contains(x.name),
              onTap: () => toggle(x.name),
            ),
          ObPill(
            p: p,
            label: 'None of these',
            selected: h.contains('none'),
            onTap: () => toggle('none'),
          ),
        ]),
        ObGiveBack(p: p, text: give),
      ],
    );
  }

  // ---- 06 reveal ----------------------------------------------------------------

  Widget _reveal(V2Palette p) {
    final d = _revealData();
    return ObPage(
      p: p,
      onBack: _back,
      body: [
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
          d.eyebrow.toUpperCase(),
          style: pvManrope(
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.3,
            color: p.ink3,
          ),
        ),
        const SizedBox(height: 10),
        ObSettle(
          child: Text(
            d.big,
            style: pvFraunces(
              fontSize: 36,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.9,
              height: 1.1,
              color: p.ink1,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          d.small,
          style: pvManrope(fontSize: 15.5, height: 1.45, color: p.ink2),
        ),
        // ⚠️ EVERY LINE IS ONE OF HER ANSWERS COMING BACK (Onboarding V3),
        // and each is true of the app as it is configured now. They arrive one
        // after another for that reason (§5.5).
        const SizedBox(height: 26),
        ObStagger(
          start: const Duration(milliseconds: 180),
          children: [
            for (final row in d.items)
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            row.$1,
                            style: pvManrope(
                                fontSize: 15, height: 1.45, color: p.ink1),
                          ),
                          if (row.$2.isNotEmpty)
                            Text(
                              row.$2,
                              style: pvManrope(
                                  fontSize: 13, height: 1.4, color: p.ink3),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
      bottom: ObPrimary(
        p: p,
        label: "Let's begin",
        onTap: () => _go(ObStep.account),
      ),
    );
  }

  /// The reveal, built from her answers: an eyebrow, the headline, one line
  /// under it, and the list of what she now has, one item per answer.
  ({String eyebrow, String big, String small, List<(String, String)> items})
      _revealData() {
    const ask = ('Ask Veda anything, in your own words, any time', '');
    final items = <(String, String)>[];
    final folicYes = _answers['ttc_folic']?.contains('yes') ?? false;
    final irregular = _answers['ttc_cycles']?.contains('no') ?? false;
    List<String> picked(String id) {
      final q = obQuestion(id, childName: _childName.text);
      final c = _answers[id] ?? const <String>{};
      return [for (final o in q.options) if (c.contains(o.id)) o.label];
    }

    if (_isPartner && _stage == 'trying') {
      final habits = [for (final h in _hisHabits) if (h != 'none') h];
      items.add(habits.isEmpty
          ? ('Your part of the plan: a simple check-up', 'Quick for men, and worth doing early')
          : ('Your part of the plan: ${habits.map((h) => const {'tobacco': 'tobacco', 'alcohol': 'drinks', 'medicines': 'medicines'}[h]).join(', ')}',
              'What to change, and why it counts in about three months'));
      final helps = picked('p_help_trying');
      if (helps.isNotEmpty) items.add(('${helps.take(2).join(' · ')}, first on your side', ''));
      if (_doctorSoon) items.add(('A check-up for both of you is a good next step', "We'll help you prepare"));
      items.add(('Link with her next', 'Then you see what she chooses to share'));
      items.add(('Ask Veda anything, any time', ''));
      final m = _readyMonth;
      return (
        eyebrow: 'Your side of it',
        big: _planning
            ? (m == null ? 'Getting ready, together.' : 'Ready by ${readyMonthLabel(m)}.')
            : _where == 'clinic'
                ? "Her clinic's plan, from your side."
                : 'The timing, explained for you.',
        small: _planning
            ? 'Your part starts now. Sperm take about three months, so what you change today counts by then.'
            : 'Her dates stay hers. When she links, you see what she shares.',
        items: items,
      );
    }
    if (_isPartner && _stage == 'pregnancy') {
      final edd = _edd!;
      final (w, _) = _weekDay(edd);
      final tri = w < 14 ? 'first' : (w < 28 ? 'second' : 'third');
      items.add(('Your part each week', 'One small thing you can do, and talking to the baby'));
      final helps = picked('p_help_pregnancy');
      if (helps.isNotEmpty) items.add(('${helps.take(2).join(' · ')}, first on your side', ''));
      if (_twins) items.add(('Twins: the pages for two', ''));
      items.add(('Link with her next', 'Her week, and the scans you can go to'));
      items.add(('Ask Veda anything, any time', ''));
      return (
        eyebrow: 'Week $w',
        big: 'Week $w. Due ${_short(edd)}.',
        small: "Her $tri trimester. Here's your side of it.",
        items: items,
      );
    }

    switch (_stage) {
      case 'trying':
        if (_planning) {
          final m = _readyMonth;
          items.add(m == null
              ? ('Your Ready-to-Try plan', 'Pick a month in it and it counts down to it')
              : ('Your Ready-to-Try plan, first on your home',
                  'Tests to ask about, folic acid timing, food for your kitchen. His part is optional'));
          items.add(folicYes
              ? ('Folic acid, 400 mcg a day. Already started', 'Ticked off in your supplements')
              : ('Folic acid, 400 mcg a day. Start this week', 'First on your supplements list'));
          if (m != null) items.add(('The trying clock starts in ${readyMonthLabel(m)}', 'Not today. Doctor timing counts from then'));
          items.add(_lmp != null
              ? ('Your periods, logged from today', 'A few cycles of dates by the time you start')
              : ('Log your next period', 'A few cycles of dates by the time you start'));
          if (irregular) items.add(('Irregular periods: worth mentioning at the check-up', 'Your dates will be ready to show'));
          items.add(ask);
          return (
            eyebrow: 'Getting ready to try',
            big: m == null ? 'Getting ready, at your pace.' : 'Ready by ${readyMonthLabel(m)}.',
            small: 'A plan for the two of you, month by month. When you start trying, the cycle home takes over.',
            items: items,
          );
        }
        if (_where == 'clinic') {
          final kind = const {'oi': 'Ovulation medicine', 'iui': 'IUI', 'ivf': 'IVF'}[_clinicKind];
          // ⚠️ HONEST ABOUT WHEN WE STEP ASIDE. Timing ownership follows real
          // clinic dates in the treatment tracker, never the label tapped here
          // (ttc_care_pathway.dart), so the line says what she has to do.
          items.add(("Your clinic's dates come first", 'Add them, and our estimate steps aside for theirs'));
          items.add(('Questions to take to your next appointment', ''));
          if (!folicYes) items.add(('Folic acid, 400 mcg a day', 'Ask your clinic if your dose is different'));
          items.add(ask);
          return (
            eyebrow: "Your clinic's plan",
            big: '${kind ?? 'Treatment'}, with your clinic.',
            small: 'Your clinic sets the dates. We help you get ready for each one.',
            items: items,
          );
        }
        if (irregular) items.add(('A rough estimate for now', 'It firms up as you log periods'));
        final dur = _answers['ttc_duration']?.firstOrNull;
        if (_doctorSoon) {
          items.add(('A check-up is a good next step', "For both of you. We'll help you prepare"));
        } else if (dur != null && dur != 'skip') {
          items.add(("We'll tell you when a check-up makes sense", switch (_ageBand) {
            FertilityAgeBand.under35 => 'At a year, or sooner if you would like',
            FertilityAgeBand.over40 => "Soon, since you're 40 or over",
            null => 'At a year, or sooner if you would like',
            _ => "At six months, since you're 35 or over",
          }));
        }
        items.add(folicYes
            ? ('Folic acid: ticked off', 'In your supplements')
            : ('Folic acid, 400 mcg a day', 'First on your supplements list'));
        items.add(ask);
        final w = _ttcWindow;
        return w == null
            ? (
                eyebrow: 'Your cycle',
                big: 'Your cycle starts with one date.',
                small: 'Tap "Period started" on the first day, and your fertile days appear.',
                items: items,
              )
            : (
                eyebrow: 'Your cycle',
                big: 'Fertile days likely around ${_short(w.opens)} to ${_short(w.closes)}.',
                small: 'Next period around ${_short(w.next)}. Based on a 28-day cycle, and it gets sharper as you log.',
                items: items,
              );
      case 'pregnancy':
        final edd = _edd!;
        final (w, d) = _weekDay(edd);
        final tri = w < 14 ? 'First' : (w < 28 ? 'Second' : 'Third');
        items.add(('A page for every week, from this one to birth', _twins ? 'With the twin scan schedule' : ''));
        final prios = picked('preg_priorities');
        if (prios.isNotEmpty) items.add(('${prios.take(2).join(' · ')}, first on your home', ''));
        final diet = picked('preg_diet');
        if (diet.isNotEmpty) items.add(('Every recipe and food page will be ${diet.first.toLowerCase()}', ''));
        if (_answers['preg_parity']?.contains('subsequent') ?? false) {
          items.add((_gentle == 'loss'
              ? 'No countdown, and no loss stories in your feed unless you look'
              : 'Skipping the basics you already know', ''));
        }
        items.add(ask);
        return (
          eyebrow: 'Week $w',
          big: d == 0 ? 'Week $w.' : 'Week $w, day $d.',
          small: "$tri trimester · Due ${_short(edd)}"
              "${_method != DdcMethod.lmp ? " · your doctor's date" : ''}",
          items: items,
        );
      case 'parenting':
        final dob = _childDob!;
        final (m, _) = _monthsWeeks(dob);
        final who = _childName.text.trim().isEmpty ? 'Your baby' : _childName.text.trim();
        items.add(('What changes for them, month by month', _bornEarly == true ? 'Milestones counted from the due date' : ''));
        final feeding = picked('pp_feeding');
        if (feeding.isNotEmpty) items.add(('Feeding: ${feeding.first.toLowerCase()}', 'Your feeding page opens there'));
        final sleep = _answers['pp_sleep']?.firstOrNull;
        if (sleep != null && sleep != 'well') items.add(('Sleep: ${picked('pp_sleep').first.toLowerCase()}', "What's normal this month, first"));
        final prios = picked('pp_priorities');
        if (prios.isNotEmpty) items.add(('${prios.take(2).join(' · ')}, first on your home', ''));
        if (_birthMode == BirthMode.cSection) items.add(('Your recovery after a C-section', 'Kegel and yoga set to match'));
        if (_childTwins) items.add(('Twins: we know there are two', ''));
        if (_secondChild && _child2Dob != null) {
          final n2 = _child2Name.text.trim();
          items.add(('${n2.isEmpty ? 'Your second child' : n2} too', 'Switch between them from the top of the home'));
        }
        items.add(ask);
        final dad = _careRole == CareRole.father || _isPartner;
        return (
          eyebrow: m < 2 ? 'Week ${_today().difference(dob).inDays ~/ 7}' : 'Month $m',
          big: '$who is ${_ageLine(dob)}.',
          small: dad ? "Here's what's changing this month, written to you as dad." : "Here's what's changing this month.",
          items: items,
        );
      default:
        final who = _childName.text.trim().isEmpty ? 'Your child' : _childName.text.trim();
        items.add(('A skill at a time, at the age they are', ''));
        final a = skFirstActivity(
          ((_answers['sk_interests'] ?? const <String>{}).toList()..sort()).join(','),
          _answers['sk_time']?.firstOrNull,
        );
        if (a != null) items.add(('Today: ${a.title}', a.time));
        items.add(ask);
        return (
          eyebrow: 'Age ${_childAge ?? 6}',
          big: '$who, ${_childAge ?? 6}.',
          small: "Here's where we start.",
          items: items,
        );
    }
  }

  // Kept for revert (Onboarding V3): `_revealRows()`, the single list of
  // strings the reveal used before every line had to come from an answer.

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

  // ---- his link step (Onboarding V3) ---------------------------------------------

  String? _myCode;
  bool _codeAsked = false;

  /// His pairing code, read once from his profile after he signs in.
  Future<void> _loadMyCode() async {
    if (_codeAsked) return;
    _codeAsked = true;
    final row = await SupabaseRepo.fetchMyProfile('pairing_code');
    final code = row?['pairing_code'] as String?;
    if (mounted && code != null && code.isNotEmpty) {
      setState(() => _myCode = code);
    }
  }

  /// "Link with her, when she's ready." Either can start the link (every
  /// profile has a code, and `link_as_partner` links whoever enters one with
  /// its owner); she types his code on her You screen, so linking stays her
  /// choice. Until then his side runs on what he told us.
  Widget _pLink(V2Palette p) {
    _loadMyCode();
    final code = _myCode;
    return ObPage(
      p: p,
      onBack: _back,
      body: [
        ObHead(
          p: p,
          eyebrow: 'Your partner',
          title: "Link with her, when she's ready.",
          subtitle: 'Send her your code. She enters it in her app, under '
              'You, then Partner, and decides what to share.',
        ),
        if (code != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final ch in code.split(''))
                Container(
                  width: 42,
                  height: 52,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: p.surfaceAlt,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    ch,
                    style: pvFraunces(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: p.ink1,
                    ),
                  ),
                ),
            ],
          )
        else
          Text(
            'Your code is on your You screen, under Partner.',
            style: pvManrope(fontSize: 14, height: 1.5, color: p.ink2),
          ),
        ObGiveBack(
          p: p,
          text: 'Until she links, your side works from what you told us'
              '${_stage == 'pregnancy' ? ': the due date and your week' : ''}. '
              'After that, you see only what she shares, never her private '
              'notes or symptoms, and she can stop sharing any time.',
        ),
      ],
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ObPrimary(
            p: p,
            label: 'Share code',
            onTap: code == null
                ? null
                : () {
                    Share.share(
                      'Link with me on ParentVeda. Open the app, go to You, '
                      'then Partner, and enter my code: $code',
                      subject: 'My ParentVeda code',
                    );
                    _go(ObStep.reach);
                  },
          ),
          ObLink(p: p, label: 'Later', onTap: () => _go(ObStep.reach)),
        ],
      ),
    );
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
          subtitle: 'Both are optional. We never send ads.',
        ),
        _reachRow(
          p,
          on: _reminders,
          title: 'Reminders on this phone',
          sub: 'A short note on the morning something new begins.',
          onChanged: (v) => setState(() => _reminders = v),
          child: _reminders
              ? ObStagger(children: [Container(
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
                )])
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
                      "One tap fills it in from your SIM. We'll send a code to check it's you. No ads.",
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

  String _previewNotification() {
    if (_isPartner) {
      return switch (_stage) {
        'pregnancy' => 'This week: one small thing you can do for her.',
        'trying' => 'Your part this week: one small change, and why it helps.',
        _ => 'A new month starts this week. Here is what is changing.',
      };
    }
    final edd = _edd;
    return switch (_stage) {
      'pregnancy' when edd != null =>
        'Week ${_weekDay(edd).$1 + 1} starts tomorrow. Here is what to expect.',
      'parenting' => "A new month starts this week. Here's what's changing.",
      'skilling' => "Today's ten-minute activity is ready.",
      'trying' when _planning =>
        'Your Ready-to-Try plan: a few small things for this month.',
      'trying' when _ttcWindow != null =>
        'Your fertile days start around ${_short(_ttcWindow!.opens)}.',
      _ => 'A short note on the morning something new begins.',
    };
  }
  // Kept for revert (Onboarding V3): the previews before they were written
  // from her answers (the trying line was "Your fertile days this cycle, the
  // morning they start.").


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
          "Too many codes for now. Your number's saved and we'll check it later.",
        PhoneOtpStep.offline =>
          "No connection right now. Your number's saved and we'll check it later.",
        PhoneOtpStep.invalidPhone => "That number doesn't look quite right. Could you check it?",
        _ =>
          "We couldn't send a code. Your number's saved and we'll check it later.",
      });
      return _otp.step != PhoneOtpStep.invalidPhone;
    }
    final verified = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      backgroundColor: kObPalette.ground,
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
    // A father: the partner on his own, or "Who are you to the baby? Father".
    final isFather = _isPartner || _careRole == CareRole.father;
    if (widget.replay) {
      // A look, not a move (R6): nothing below runs.
      widget.onDone(stage, isFather);
      return;
    }
    final profile = FamilyProfileStore.instance;

    // 1. Stage — locally first, before any network, exactly as the old flow.
    // A parent's stage starts on the child's BIRTHDAY, as the birth sheet's
    // does (STAGE-TRANSITIONS B4, 2026-10-24): it used to start on the day
    // she signed up. Set here, before anything listens, because re-declaring
    // the same stage later keeps the first date. Kept for revert: the
    // `setStageId(stage)` line alone.
    final childDob = _childDob;
    if (stage == 'parenting' && childDob != null) {
      LifeStageStore.instance.setStage(LifeStage.parenting,
          at: DateTime(childDob.year, childDob.month, childDob.day));
    } else {
      LifeStageStore.instance.setStageId(stage);
    }
    profile.setStage(switch (stage) {
      'trying' => JourneyStage.tryingToConceive,
      'pregnancy' => JourneyStage.pregnancy,
      _ => JourneyStage.parenting,
    });

    // 2. Trying (Onboarding V3): every answer into the store that owns it,
    //    once, at the end. A woman who leaves halfway leaves nothing
    //    half-configured (the TTC intro's rule, kept).
    if (stage == 'trying') {
      final ttc = TtcStore.instance;
      final plan = TtcReadyPlanStore.instance;
      await plan.load();
      if (!_isPartner && _lmp != null && !_lmpUnknown) {
        CycleStore.instance.logPeriodStart(_lmp!);
      }
      if (_planning) {
        await plan.setPlannedStart(_readyMonth);
      } else {
        if (_where == 'trying') ttc.setPath(TtcPath.natural);
        if (_where == 'clinic') {
          final path = const {
            'oi': TtcPath.ovulationInduction,
            'iui': TtcPath.iui,
            'ivf': TtcPath.ivf,
          }[_clinicKind];
          if (path != null) ttc.setPath(path);
        }
        // The intro's bands, so "how long" is one answer with one meaning.
        final months = const {'starting': 0, 'months': 3, 'six': 9, 'year': 18}[
            _answers['ttc_duration']?.firstOrNull];
        if (months != null) {
          ttc.setJourneyStart(
              DateTime.now().subtract(Duration(days: (months * 30.44).round())));
        }
      }
      final band = _ageBand;
      if (band != null) await TtcFertilityHelpStore.instance.setAgeBand(band);
      // ⚠️ THE INTRO FILM NO LONGER STANDS IN FRONT OF HER HOME (2026-10-18,
      // the user's decision). She has just had her reveal; the film waits as
      // the first card on her home for a week instead.
      await TtcIntroGate.markSeen();
      await TtcIntroGate.offerCard();
      if (_isPartner) {
        TtcPartnerMode.instance.on = true;
        await plan.setHisAnswers(
          age: _hisAge,
          habits: _hisHabits.isEmpty
              ? null
              : {for (final h in HisHabit.values) if (_hisHabits.contains(h.name)) h},
        );
      } else {
        // Folic acid: "yes" is ticked today; "not yet" puts it first on her
        // supplements list, unticked. Never ticked twice (toggleTaken flips).
        final folic = _answers['ttc_folic']?.firstOrNull;
        if (folic != null) {
          final s = TtcSupplementsStore.instance;
          final row = s.add('Folic acid', dose: '400 mcg daily');
          if (folic == 'yes' && !s.isTaken(row.id)) s.toggleTaken(row.id);
        }
      }
    }

    // 3. The date, in the store that owns it.
    DateTime? due;
    if (stage == 'pregnancy' && _edd != null) {
      due = _edd;
      await widget.pregnancy.setDueDate(
        due!,
        source: ddcSourceFor(_method),
        datingDate: _method == DdcMethod.known ? null : _methodDate,
      );
      if (_twins) await ReadyBirthContextStore.instance.setTwins(true);
      if (_answers['preg_parity']?.contains('subsequent') ?? false) {
        profile.setGentle(_gentle);
      }
    }
    if (stage == 'parenting' && _childDob != null) {
      final first = await ChildProfileStore.instance.addChild(
        name: _childName.text,
        // A skipped "Boy or girl" is NOT a boy (gap analysis P1, 2026-10-07):
        // isBoy is only a stand-in for the WHO chart, sexGiven says so.
        isBoy: _childIsBoy ?? true,
        sexGiven: _childIsBoy != null,
        dob: _childDob!,
        birthMode: _birthMode?.name,
        bornWeeks: _bornEarly == true ? _bornWeeks : null,
      );
      // The birth answers, on this child (2026-10-07). Since bug B1 was fixed
      // (2026-10-17) the feeding and sleep answers given before the child
      // existed are carried onto it by the family profile itself.
      FamilyProfileStore.instance.setBirthDetails(
        mode: _birthMode,
        early: _bornEarly,
        bornWeeks: _bornWeeks,
        role: _isPartner ? CareRole.father : _careRole,
      );
      if (_childTwins) profile.setBirth(multiple: true);
      // The birth, the same move the birth sheet makes (B4, 2026-10-24): the
      // story gets the day and the Dear Baby letters open. The stage was
      // dated to the birthday in step 1.
      await recordBirth(dob: _childDob!, name: first.name, childId: first.id);
      // A second child (Onboarding V3), then back to the first, whose answers
      // these were.
      final dob2 = _child2Dob;
      if (_secondChild && dob2 != null) {
        await ChildProfileStore.instance.addChild(
          name: _child2Name.text,
          isBoy: true,
          sexGiven: false,
          dob: dob2,
        );
        await ChildProfileStore.instance.switchTo(first.id);
      }
    }
    if (stage == 'skilling' && _childAge != null) {
      // A real birthday when she gave one; else "today, N years ago", as
      // before (kept for revert as the only path).
      final dob = _skDob ??
          DateTime(_today().year - _childAge!, _today().month, _today().day);
      // The parenting child first, so her learning space is keyed by her id
      // (F5, 2026-10-25). Kept for revert, the order before:
      //   SkChildStore.instance.update(name: _childName.text, dob: dob);
      //   await ChildProfileStore.instance.addChild(...);
      final skChild = await ChildProfileStore.instance.addChild(
        name: _childName.text,
        isBoy: _childIsBoy ?? true,
        sexGiven: _childIsBoy != null,
        dob: dob,
      );
      SkChildStore.instance.update(name: _childName.text, dob: dob, childId: skChild.id);
    }

    // 4. Reminders — the OS prompt, only because she flipped the switch; and
    //    the choice itself is kept now (STILL-OPEN §79.4). `setPhoneOn(true)`
    //    alone does nothing on a fresh install (it defaults on), so the
    //    permission is asked here directly.
    if (_reminders) {
      try {
        await NotificationService.instance.requestPermission();
      } catch (_) {
        /* the switch was the consent; the OS answer is its own */
      }
    }
    if (stage == 'trying') {
      await TtcMessagesStore.instance.setPhoneOn(_reminders);
      // Getting ready: the plan's own monthly note, on the same switch.
      if (_planning && _reminders && _readyMonth != null) {
        await TtcReadyPlanStore.instance.setNotify(true);
      }
    }

    // 5. The profile row. Built once, used by both paths (cloud or stash).
    final fields = <String, dynamic>{
      if (_name.isNotEmpty) 'name': _name,
      // Kept for revert: 'role': 'mother' (every profile was saved as her).
      'role': isFather ? 'father' : 'mother',
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

    // 6. The flags the splash reads.
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(kAuthCompletedKey, true);
      await prefs.setString(kUserRoleKey, isFather ? 'father' : 'mother');
    } catch (_) {
      /* best-effort */
    }

    // 7. A clinic's QR (Partner Editions A1). She has an account by now (the
    //    account step comes before reach), so the token held since the scan
    //    can bind, and the welcome the old sign-up flow showed is shown here
    //    too: before A1 this flow bound it only on her next launch
    //    (main.dart) and the welcome never appeared. Same order as
    //    `_finishMother` in auth_flow_screen.dart. Never blocks her.
    try {
      await CarePartnerStore.instance.applyPending();
      // Bound by now, so the milestone lands against the right partner.
      if (due != null) CareJourney.pregnancyStarted();
      if (mounted) await showCareWelcome(context);
    } catch (_) {/* a doctor's introduction must never block her way in */}

    if (!mounted) return;
    // The home she lands on welcomes her, once (pv_home_arrival.dart).
    PvFirstHome.owe();
    widget.onDone(stage, isFather);
  }

  /// "Recommended by Dr Meera Rao" — the doctor variant of the welcome
  /// screen's invited box. Same box, same type, so the two read as one family.
  Widget _careInvitedBox(V2Palette p) {
    final partner = _careInviter;
    final detail = partner == null ? '' : careLineDetail(partner);
    return Container(
      key: const ValueKey('ob_care_invited'),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: p.surfaceAlt,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded, size: 18, color: p.ink1),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  partner == null
                      ? 'Recommended by your doctor'
                      : 'Recommended by ${partner.name}',
                  style: pvManrope(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: p.ink1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail.isEmpty
                      ? "They'll appear in your app once you're set up"
                      : "$detail · they'll appear in your app once you're set up",
                  style: pvManrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                    color: p.ink3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
    final p = kObPalette;
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
          PvPress(child: GestureDetector(
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
          )),
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
