// =============================================================================
//  OnboardingFlow — the first run, as decided in docs/ONBOARDING-AUDIT.md
// -----------------------------------------------------------------------------
//  Sesame's welcome, Flo's questions, Apple's date, Oura's reveal, Flo's
//  permission ask, our home. Built from the Claude Design "ParentVeda
//  Onboarding" (2026-09-16) plus the question block the audit priced in and the
//  user asked for (2026-09-17): two or three give-back questions per stage,
//  after the date and before the reveal, so the reveal stays the payoff.
//
//  The mother's path:
//      welcome → hello → who → stage → [date] → questions… → [reveal] → reach → home
//  Trying to conceive has no date and no reveal (nothing honest to compute).
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
import '../../post_pregnancy/pp_child_profile.dart';
import '../../referral/enter_code_sheet.dart';
import '../../skilling/sk_child_store.dart';
import '../../tools/due_date_calculator_screen.dart' show DdcMethod, ddcComputeEdd, ddcSourceFor;
import '../../v2/v2_palette.dart';
import '../auth_flow_screen.dart' show AuthFlowScreen, kAuthCompletedKey, kUserRoleKey;
import 'onboarding_chrome.dart';
import 'onboarding_questions.dart';

enum ObStep { welcome, hello, who, stage, date, question, reveal, reach }

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

  void _nextQuestion() {
    if (_q + 1 < _questions.length) {
      setState(() => _q++);
    } else {
      _afterQuestions();
    }
  }

  void _afterQuestions() {
    if (_stage == 'trying') {
      _go(ObStep.reach);
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
          ObStep.hello => _hello(p),
          ObStep.who => _who(p),
          ObStep.stage => _stagePage(p),
          ObStep.date => _date(p),
          ObStep.question => _question(p),
          ObStep.reveal => _reveal(p),
          ObStep.reach => _reach(p),
        };
        return Stack(children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween(begin: const Offset(0.04, 0), end: Offset.zero).animate(anim),
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
                  child: Text(_toast!,
                      style: pvManrope(fontSize: 13.5, color: p.ground)),
                ),
              ),
            ),
        ]);
      },
    );
  }

  // ---- 01 welcome ---------------------------------------------------------------

  Widget _welcome(V2Palette p) {
    final referral = ReferralStore.instance;
    final invited = referral.hasRedeemed;
    return ObPage(
      p: p,
      body: [
        // The design's hero band: a soft tinted field the mark sits on. The
        // tint is a well hue at the page's own lightness — colour in a well,
        // not on the page.
        Container(
          height: 150,
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [v2BlockTint(300, p), v2BlockTint(344, p).withValues(alpha: 0.55)],
            ),
          ),
          alignment: Alignment.bottomLeft,
          padding: const EdgeInsets.all(16),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.all(8),
            child: Image.asset('assets/brand/pv-mark.png'),
          ),
        ),
        const SizedBox(height: 22),
        Text('ParentVeda',
            style: pvManrope(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
                color: p.action.withValues(alpha: 0.85))),
        const SizedBox(height: 10),
        Text('For the whole journey — trying, expecting, raising.',
            style: pvFraunces(
                fontSize: 30,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.7,
                height: 1.12,
                color: p.ink1)),
        const SizedBox(height: 14),
        Text('One account, both of you, every stage. Nothing is shared with anyone outside your home.',
            style: pvManrope(fontSize: 15, height: 1.5, color: p.ink2)),
        const SizedBox(height: 28),
        if (invited)
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: p.surfaceAlt,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(children: [
              Icon(Icons.check_circle_rounded, size: 18, color: p.ink1),
              const SizedBox(width: 10),
              Expanded(
                child: Text('Invited by a friend · code ${referral.redeemedCode} applied',
                    style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w700, color: p.ink1)),
              ),
            ]),
          ),
      ],
      bottom: Column(mainAxisSize: MainAxisSize.min, children: [
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
              TextSpan(text: 'Terms', style: TextStyle(color: p.action, fontWeight: FontWeight.w700)),
              const TextSpan(text: ' and '),
              TextSpan(text: 'Privacy Policy', style: TextStyle(color: p.action, fontWeight: FontWeight.w700)),
              const TextSpan(text: '.'),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          ObLink(p: p, label: "I'm a doctor", onTap: _doctor),
          if (!invited) ...[
            Text('·', style: TextStyle(color: p.ink3)),
            ObLink(p: p, label: 'Have a code?', onTap: _code),
          ],
        ]),
      ]),
    );
  }

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
    _name = _googleName();
    _go(ObStep.hello);
  }

  /// Supabase may not be initialised (tests, previews) — that is "no name",
  /// never a crash; the Hello screen offers "Add your name" instead.
  static String _googleName() {
    try {
      final meta = Supabase.instance.client.auth.currentUser?.userMetadata ?? const {};
      return (meta['full_name'] ?? meta['name'] ?? '').toString().trim();
    } catch (_) {
      return '';
    }
  }

  static String _currentEmail() {
    try {
      return Supabase.instance.client.auth.currentUser?.email ?? '';
    } catch (_) {
      return '';
    }
  }

  void _doctor() {
    // The doctor entry lives on the old screen, unchanged.
    Navigator.of(context).push(MaterialPageRoute<void>(
      settings: const RouteSettings(name: 'auth/doctor'),
      builder: (_) => AuthFlowScreen(
        onDone: (_, isFather) => widget.onDone(null, isFather),
        onDoctor: widget.onDoctor,
      ),
    ));
  }

  Future<void> _code() async {
    final ok = await showEnterCodeSheet(context);
    if (ok && mounted) setState(() {});
  }

  // ---- 02 hello -----------------------------------------------------------------

  Widget _hello(V2Palette p) {
    final first = _name.split(' ').where((w) => w.isNotEmpty).firstOrNull ?? '';
    final email = _currentEmail();
    return ObPage(
      p: p,
      onBack: _back,
      body: [
        const SizedBox(height: 40),
        Row(children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: p.surfaceAlt, shape: BoxShape.circle),
            child: Text(first.isEmpty ? '·' : first[0].toUpperCase(),
                style: pvManrope(fontSize: 14, fontWeight: FontWeight.w800, color: p.ink2)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(email,
                overflow: TextOverflow.ellipsis,
                style: pvManrope(fontSize: 12.5, color: p.ink3)),
          ),
        ]),
        const SizedBox(height: 28),
        Text.rich(
          TextSpan(
            text: 'Nice to meet you, ',
            style: pvFraunces(
                fontSize: 34,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.8,
                height: 1.1,
                color: p.ink1),
            children: [
              TextSpan(text: first.isEmpty ? 'there' : first, style: TextStyle(color: p.action)),
              const TextSpan(text: '.'),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Align(
          alignment: Alignment.centerLeft,
          child: ObLink(
            p: p,
            label: first.isEmpty ? 'Add your name' : 'Not $first? Edit',
            center: false,
            onTap: _editName,
          ),
        ),
      ],
      bottom: ObPrimary(p: p, label: 'Continue', onTap: () => _go(ObStep.who)),
    );
  }

  Future<void> _editName() async {
    final c = TextEditingController(text: _name);
    final v = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: V2PaletteStore.instance.current.ground,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + MediaQuery.of(ctx).viewInsets.bottom),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('What should we call you?',
              style: pvFraunces(fontSize: 22, fontWeight: FontWeight.w600, color: V2PaletteStore.instance.current.ink1)),
          const SizedBox(height: 14),
          TextField(controller: c, autofocus: true, textCapitalization: TextCapitalization.words),
          const SizedBox(height: 16),
          ObPrimary(p: V2PaletteStore.instance.current, label: 'Save', onTap: () => Navigator.of(ctx).pop(c.text)),
        ]),
      ),
    );
    if (v != null && mounted) setState(() => _name = v.trim());
  }

  // ---- 03 who -------------------------------------------------------------------

  Widget _who(V2Palette p) => ObPage(
        p: p,
        onBack: _back,
        body: [
          ObHead(
              p: p,
              eyebrow: 'Who is using this',
              title: 'Which of you is this?',
              subtitle: 'Whoever is not here gets their own app, paired to yours.'),
          // Two cards side by side with tinted wells — the design's shape.
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: ObGridCard(
                  p: p,
                  title: 'Mother',
                  subtitle: 'Trying, expecting or raising',
                  icon: Icons.favorite_border_rounded,
                  hue: 344,
                  selected: false,
                  onTap: () => _go(ObStep.stage)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ObGridCard(
                  p: p,
                  title: 'Partner',
                  subtitle: 'Join with her code',
                  icon: Icons.people_outline_rounded,
                  hue: 205,
                  selected: false,
                  onTap: _partner),
            ),
          ]),
          const SizedBox(height: 18),
          Text('We only ever hold a name its owner gave us.',
              style: pvManrope(fontSize: 12.5, height: 1.4, color: p.ink3)),
        ],
      );

  void _partner() {
    // The pairing branch is the old screen's, unchanged and already positioned.
    Navigator.of(context).push(MaterialPageRoute<void>(
      settings: const RouteSettings(name: 'auth/pairing'),
      builder: (_) => AuthFlowScreen(
        initialScreen: 'pairCode',
        onDone: (_, isFather) => widget.onDone(null, isFather),
        onDoctor: widget.onDoctor,
      ),
    ));
  }

  // ---- 04 stage -----------------------------------------------------------------

  Widget _stagePage(V2Palette p) {
    // A 2x2 of cards with tinted wells — the design's shape. Hues are the
    // stages' own (pink for trying, violet for pregnancy, blue for parenting,
    // green for skilling), from the V3 door palette.
    Widget card(String id, String title, String sub, IconData icon, double hue) =>
        ObGridCard(
          p: p,
          title: title,
          subtitle: sub,
          icon: icon,
          hue: hue,
          selected: _stage == id,
          onTap: () {
            setState(() => _stage = id);
            // The tap is the answer — no Continue.
            if (id == 'trying') {
              _afterDate();
            } else {
              _go(ObStep.date);
            }
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
            subtitle: 'This sets your home. You can change it whenever life does.'),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: card('trying', 'Trying to conceive', 'Cycle and timing', Icons.favorite_border_rounded, 344)),
          const SizedBox(width: 12),
          Expanded(child: card('pregnancy', 'Pregnant', 'Week by week', Icons.pregnant_woman_rounded, 275)),
        ]),
        const SizedBox(height: 12),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: card('parenting', 'Parent — 0 to 5', 'Sleep and leaps', Icons.child_care_rounded, 205)),
          const SizedBox(width: 12),
          Expanded(child: card('skilling', 'Skilling — 6 and up', 'Skills and habits', Icons.school_outlined, 150)),
        ]),
        const SizedBox(height: 18),
        Text('Expecting twins or more? You can say so later.',
            style: pvManrope(fontSize: 12.5, height: 1.4, color: p.ink3)),
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
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final e in _methods)
            ObPill(
                p: p,
                label: e.$2,
                selected: _method == e.$1,
                onTap: () => setState(() => _method = e.$1)),
        ]),
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
          child: Text(_methodDate == null ? 'Tap to choose' : _long(_methodDate!),
              style: pvFraunces(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: _methodDate == null ? p.ink3 : p.ink1)),
        ),
        const SizedBox(height: 14),
        Text('Not sure? Your last period is enough to start — you can change it any time.',
            style: pvManrope(fontSize: 12.5, height: 1.45, color: p.ink3)),
      ],
      bottom: ObPrimary(p: p, label: 'Continue', onTap: _edd == null ? null : _afterDate),
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
            title: skilling ? 'Tell us about your child.' : 'Tell us about your baby.'),
        ObField(
          p: p,
          label: skilling ? "Child's name — optional" : "Baby's name — optional",
          child: TextField(
            controller: _childName,
            textCapitalization: TextCapitalization.words,
            onChanged: (_) => setState(() {}),
            style: pvFraunces(fontSize: 20, fontWeight: FontWeight.w600, color: p.ink1),
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              hintText: 'Aarav',
              hintStyle: pvFraunces(fontSize: 20, fontWeight: FontWeight.w600, color: p.ink3),
            ),
          ),
        ),
        const SizedBox(height: 10),
        if (skilling)
          ObField(
            p: p,
            label: 'Age',
            child: Wrap(spacing: 8, runSpacing: 8, children: [
              for (var a = 6; a <= 12; a++)
                ObPill(p: p, label: '$a', selected: _childAge == a, onTap: () => setState(() => _childAge = a)),
            ]),
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
            child: Text(_childDob == null ? 'Tap to choose' : _long(_childDob!),
                style: pvFraunces(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: _childDob == null ? p.ink3 : p.ink1)),
          ),
        const SizedBox(height: 10),
        ObField(
          p: p,
          label: 'Boy or girl — optional',
          child: Wrap(spacing: 8, children: [
            ObPill(p: p, label: 'Boy', selected: _childIsBoy == true, onTap: () => setState(() => _childIsBoy = true)),
            ObPill(p: p, label: 'Girl', selected: _childIsBoy == false, onTap: () => setState(() => _childIsBoy = false)),
          ]),
        ),
        const SizedBox(height: 14),
        Text(
            skilling
                ? 'The age is what the activities are chosen by. Nothing else is needed.'
                : 'The name is optional — the birthday is what the months and the leaps are counted from.',
            style: pvManrope(fontSize: 12.5, height: 1.45, color: p.ink3)),
      ],
      bottom: ObPrimary(p: p, label: 'Continue', onTap: ready ? _afterDate : null),
    );
  }

  Future<void> _pickDate({
    required DateTime initial,
    required DateTime first,
    required DateTime last,
    required void Function(DateTime) onPicked,
  }) async {
    final d = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(first) ? first : (initial.isAfter(last) ? last : initial),
      firstDate: first,
      lastDate: last,
    );
    if (d != null) onPicked(d);
  }

  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
  static String _long(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';
  static String _short(DateTime d) => '${d.day} ${_months[d.month - 1].substring(0, 3)}';

  // ---- questions ----------------------------------------------------------------

  Widget _question(V2Palette p) {
    final qs = _questions;
    if (qs.isEmpty) return const SizedBox.shrink();
    final q = qs[_q.clamp(0, qs.length - 1)];
    final chosen = _answers[q.id] ?? <String>{};
    final giveBack = q.multi
        ? (chosen.isEmpty ? '' : (q.multiGiveBack ?? ''))
        : (chosen.isEmpty ? '' : q.options.firstWhere((o) => o.id == chosen.first).giveBack);

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
        ObHead(
          p: p,
          eyebrow: 'A quick one · ${_q + 1} of ${qs.length}',
          title: q.title,
          subtitle: q.subtitle,
        ),
        if (q.multi)
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final o in q.options)
              ObPill(p: p, label: o.label, selected: chosen.contains(o.id), onTap: () => choose(o)),
          ])
        else
          for (final o in q.options) ...[
            ObTile(p: p, title: o.label, selected: chosen.contains(o.id), compact: true, onTap: () => choose(o)),
            const SizedBox(height: 8),
          ],
        ObGiveBack(p: p, text: giveBack),
      ],
      bottom: ObPrimary(p: p, label: 'Continue', onTap: chosen.isEmpty ? null : _nextQuestion),
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
        big = 'Week $w, day $d.';
        small = '$tri trimester · Due ${_short(edd)}';
      case 'parenting':
        final dob = _childDob!;
        final age = _monthsWeeks(dob);
        final name = _childName.text.trim().isEmpty ? 'Your baby' : _childName.text.trim();
        eyebrow = age.$1 == 0 ? 'Week ${age.$2}' : 'Month ${age.$1}';
        big = age.$1 == 0
            ? '$name is ${age.$2} ${age.$2 == 1 ? 'week' : 'weeks'} old.'
            : '$name is ${age.$1} ${age.$1 == 1 ? 'month' : 'months'}${age.$2 > 0 ? ', ${age.$2} ${age.$2 == 1 ? 'week' : 'weeks'}' : ''}.';
        small = "Here's what's changing this month.";
      default:
        final name = _childName.text.trim().isEmpty ? 'Your child' : _childName.text.trim();
        eyebrow = 'Age ${_childAge ?? 6}';
        big = '$name, ${_childAge ?? 6}.';
        small = "Here's where we start.";
    }
    return ObPage(
      p: p,
      onBack: _back,
      body: [
        const SizedBox(height: 24),
        Container(
          height: 220,
          decoration: BoxDecoration(
            color: p.surfaceAlt,
            borderRadius: BorderRadius.circular(24),
          ),
          alignment: Alignment.center,
          child: Text(eyebrow,
              style: pvManrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.3,
                  color: p.ink3)),
        ),
        const SizedBox(height: 28),
        Text(big,
            style: pvFraunces(
                fontSize: 36,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.9,
                height: 1.1,
                color: p.ink1)),
        const SizedBox(height: 10),
        Text(small, style: pvManrope(fontSize: 15.5, height: 1.45, color: p.ink2)),
      ],
      bottom: ObPrimary(p: p, label: "Let's begin", onTap: () => _go(ObStep.reach)),
    );
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
    final canContinue = !_whatsapp || WhatsAppPrefs.normalizePhone(_phone.text) != null;
    return ObPage(
      p: p,
      onBack: _back,
      body: [
        ObHead(
            p: p,
            eyebrow: 'Staying in touch',
            title: 'How should we reach you?',
            subtitle: 'Both optional. Neither is marketing.'),
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
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('ParentVeda · now',
                        style: pvManrope(fontSize: 10.5, fontWeight: FontWeight.w700, color: p.ink3)),
                    const SizedBox(height: 3),
                    Text(_previewNotification(),
                        style: pvManrope(fontSize: 13, height: 1.4, color: p.ink1)),
                  ]),
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
              ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                      child: TextField(
                        controller: _phone,
                        keyboardType: TextInputType.phone,
                        onChanged: (_) => setState(() => _phoneVerified = false),
                        style: pvFraunces(fontSize: 19, fontWeight: FontWeight.w600, color: p.ink1),
                        decoration: InputDecoration(
                          isDense: true,
                          prefixText: '+91 ',
                          prefixStyle: pvFraunces(fontSize: 19, fontWeight: FontWeight.w600, color: p.ink2),
                          hintText: '98765 43210',
                          hintStyle: pvFraunces(fontSize: 19, fontWeight: FontWeight.w600, color: p.ink3),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    if (_phoneVerified)
                      Icon(Icons.verified_rounded, size: 18, color: p.action)
                    else
                      ObLink(
                          p: p,
                          label: 'Use another',
                          onTap: () => setState(() => _phone.clear())),
                  ]),
                  const SizedBox(height: 6),
                  Text("From your SIM, one tap. We'll send a code to confirm it's you. No marketing.",
                      style: pvManrope(fontSize: 12, height: 1.4, color: p.ink3)),
                ])
              : null,
        ),
        const SizedBox(height: 18),
        // ⚠️ This line used to read "The permission comes after the value, and
        // nothing is pre-ticked" — a design annotation that leaked into copy.
        Text('You can change both any time from Profile.',
            style: pvManrope(fontSize: 12.5, height: 1.4, color: p.ink3)),
      ],
      bottom: Column(mainAxisSize: MainAxisSize.min, children: [
        ObPrimary(
            p: p,
            label: _busy ? 'Saving…' : 'Continue',
            onTap: (_busy || !canContinue) ? null : _continueFromReach),
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
                  }),
      ]),
    );
  }

  String _previewNotification() => switch (_stage) {
        'pregnancy' => "Week ${((280 - (_edd ?? _today()).difference(_today()).inDays) ~/ 7) + 1} starts tomorrow — here's what to expect.",
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
  }) =>
      Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: p.line, width: 1.2),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title,
                    style: pvFraunces(fontSize: 16.5, fontWeight: FontWeight.w600, color: p.ink1)),
                const SizedBox(height: 3),
                Text(sub, style: pvManrope(fontSize: 12.5, height: 1.4, color: p.ink3)),
              ]),
            ),
            Switch.adaptive(
              value: on,
              onChanged: onChanged,
              activeTrackColor: p.action,
            ),
          ]),
          ?child,
        ]),
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
        PhoneOtpStep.rateLimited => 'Too many codes for now — we saved the number and will confirm it later.',
        PhoneOtpStep.offline => "No connection — we saved the number and will confirm it later.",
        PhoneOtpStep.invalidPhone => 'That number does not look right.',
        _ => "Could not send a code — we saved the number and will confirm it later.",
      });
      return _otp.step != PhoneOtpStep.invalidPhone;
    }
    final verified = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      backgroundColor: V2PaletteStore.instance.current.ground,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _OtpSheet(controller: _otp, phone: _otp.phone ?? _phone.text),
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
          name: _childName.text, isBoy: _childIsBoy ?? true, dob: _childDob!);
    }
    if (stage == 'skilling' && _childAge != null) {
      final dob = DateTime(_today().year - _childAge!, _today().month, _today().day);
      SkChildStore.instance.update(name: _childName.text, dob: dob);
      await ChildProfileStore.instance.addChild(
          name: _childName.text, isBoy: _childIsBoy ?? true, dob: dob);
    }

    // 3. Reminders — the OS prompt, only because she flipped the switch.
    if (_reminders) {
      try {
        await NotificationService.instance.requestPermission();
      } catch (_) {/* the switch was the consent; the OS answer is its own */}
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
    } catch (_) {/* best-effort */}

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
    final needsResend = c.step == PhoneOtpStep.expired || c.step == PhoneOtpStep.tooMany;
    final digits = _field.text.replaceAll(RegExp(r'\D'), '');

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 18, 24, 24 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Text('Confirm your number',
                style: pvFraunces(fontSize: 22, fontWeight: FontWeight.w600, color: p.ink1)),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(false),
            icon: Icon(Icons.close_rounded, color: p.ink2),
          ),
        ]),
        const SizedBox(height: 4),
        Text('We sent a code to $masked', style: pvManrope(fontSize: 14, color: p.ink2)),
        const SizedBox(height: 20),
        // Six boxes drawn over one invisible field, so the keyboard, paste and
        // the SMS auto-fill all land in one place.
        GestureDetector(
          onTap: () => _focus.requestFocus(),
          child: Stack(children: [
            Row(children: [
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
                          width: 1.4),
                    ),
                    child: Text(i < digits.length ? digits[i] : '',
                        style: pvFraunces(fontSize: 24, fontWeight: FontWeight.w600, color: p.ink1)),
                  ),
                ),
                if (i < _len - 1) const SizedBox(width: 8),
              ],
            ]),
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
          ]),
        ),
        const SizedBox(height: 12),
        Text(line, style: pvManrope(fontSize: 12.5, height: 1.4, color: p.ink3)),
        const SizedBox(height: 18),
        ObPrimary(
          p: p,
          label: c.busy ? 'Checking…' : 'Confirm',
          onTap: (c.busy || digits.length != _len || needsResend) ? null : _submit,
        ),
        const SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (_resendIn > 0 && !needsResend)
            Text('Resend in ${_resendIn}s', style: pvManrope(fontSize: 13, color: p.ink3))
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
          ObLink(p: p, label: 'Skip for now', onTap: () => Navigator.of(context).pop(false)),
        ]),
      ]),
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
