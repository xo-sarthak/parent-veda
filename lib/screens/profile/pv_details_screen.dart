// =============================================================================
//  PvDetailsScreen — "Your details", editable
// -----------------------------------------------------------------------------
//  The other half of "derive, never ask": what we asked at onboarding, and
//  what the stage derived, SHOWN as facts she can correct. Each question from
//  `onboarding_questions.dart` renders as a chip group whose current
//  selection is read back from `FamilyProfileStore`, and a tap writes through
//  the same `apply` the onboarding used — one path in, one path out, so the
//  profile and the questions can never disagree.
//
//  `focusId` scrolls to (and highlights) one question when she arrived from a
//  single row. A few rows have no onboarding question and get their own
//  block here: learning style, reminder topics, the TTC treatment and test
//  records (which open their own tools), the skilling role (read-only).
// =============================================================================

import 'package:flutter/material.dart';

import '../../services/family_profile.dart';
import '../../theme/pv_fonts.dart';
import '../auth/onboarding/onboarding_questions.dart';
import '../skilling/sk_child_store.dart';
import '../ttc/ttc_records_screen.dart';
import '../ttc/ttc_treatment_screen.dart';
import '../v2/v2_palette.dart';
import 'pv_you_chrome.dart';

class PvDetailsScreen extends StatefulWidget {
  const PvDetailsScreen({super.key, required this.stageId, this.focusId});
  final String stageId;
  final String? focusId;

  @override
  State<PvDetailsScreen> createState() => _PvDetailsScreenState();
}

class _PvDetailsScreenState extends State<PvDetailsScreen> {
  final Map<String, GlobalKey> _keys = {};

  @override
  void initState() {
    super.initState();
    if (widget.focusId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final k = _keys[widget.focusId];
        if (k?.currentContext != null) {
          Scrollable.ensureVisible(
            k!.currentContext!,
            duration: const Duration(milliseconds: 320),
            alignment: 0.1,
          );
        }
      });
    }
  }

  GlobalKey _key(String id) => _keys.putIfAbsent(id, GlobalKey.new);

  /// The chosen option ids for a question, read back from the store.
  Set<String> _chosen(ObQuestion q) {
    final s = FamilyProfileStore.instance;
    switch (q.id) {
      case 'preg_parity':
        return {?s.parity?.name};
      case 'preg_priorities':
        return s.pregPriorities.map((e) => e.name).toSet();
      case 'preg_diet':
        return {?s.diet?.name};
      case 'pp_feeding':
        return s.feedings.map((e) => e.name).toSet();
      case 'pp_sleep':
        return s.sleeps.map((e) => e.name).toSet();
      case 'pp_priorities':
        return s.priorities.map((e) => e.name).toSet();
      default:
        final raw = s.otherFor(q.id);
        return raw == null || raw.isEmpty ? {} : raw.split(',').toSet();
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    final questions = onboardingQuestionsFor(widget.stageId);
    return Scaffold(
      backgroundColor: p.ground,
      body: ListenableBuilder(
        listenable: FamilyProfileStore.instance,
        builder: (context, _) => CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: PvYouTopBar(title: 'Your details', eyebrow: 'You'),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                child: Text(
                  'What you told us, and what we worked out. Change anything — it changes what leads on your home, never what exists.',
                  style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink2),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              sliver: SliverList.list(
                children: [
                  for (final q in questions) _question(p, q),
                  if (widget.stageId == 'parenting') ...[
                    _enumBlock<LearningStyle>(
                      p,
                      'learning',
                      'How you like to learn',
                      LearningStyle.values,
                      (v) => v.label,
                      FamilyProfileStore.instance.learnings,
                      FamilyProfileStore.instance.toggleLearning,
                      note:
                          'We match articles, videos and Ask Veda to your style.',
                    ),
                    _enumBlock<NotifyTopic>(
                      p,
                      'notify',
                      'Reminders you want',
                      NotifyTopic.values,
                      (v) => v.label,
                      FamilyProfileStore.instance.notify,
                      FamilyProfileStore.instance.toggleNotify,
                      note: 'Only what you choose — never noise.',
                    ),
                  ],
                  if (widget.stageId == 'trying') ...[
                    _linkBlock(
                      p,
                      'treatment',
                      'Treatment',
                      'The dates your clinic gave you — trigger, retrieval, transfer, the test day. We remind; we never reschedule.',
                      'Open treatment dates',
                      () => _push(const TtcTreatmentScreen(), 'ttc/treatment'),
                    ),
                    _linkBlock(
                      p,
                      'records',
                      'Test records',
                      'Every reading you have logged, with the date and who it was for.',
                      'Open records',
                      () => _push(const TtcRecordsScreen(), 'ttc/records'),
                    ),
                  ],
                  if (widget.stageId == 'skilling') _roleBlock(p),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _push(Widget w, String name) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => w,
      settings: RouteSettings(name: name),
    ),
  );

  Widget _block(String id, {required Widget child}) => Container(
    key: _key(id),
    margin: const EdgeInsets.only(top: 14),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: widget.focusId == id ? pvStorePalette.ink1 : kPvLine,
        width: widget.focusId == id ? 1.4 : 1,
      ),
    ),
    child: child,
  );

  Widget _question(V2Palette p, ObQuestion q) {
    final chosen = _chosen(q);
    return _block(
      q.id,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            q.title,
            style: pvManrope(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: p.ink1,
            ),
          ),
          if (q.subtitle != null) ...[
            const SizedBox(height: 3),
            Text(
              q.subtitle!,
              style: pvManrope(fontSize: 12.5, height: 1.4, color: p.ink3),
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final o in q.options)
                PvChip(
                  label: o.label,
                  selected: chosen.contains(o.id),
                  onTap: () {
                    final next = {...chosen};
                    if (q.multi) {
                      next.contains(o.id) ? next.remove(o.id) : next.add(o.id);
                    } else {
                      next
                        ..clear()
                        ..add(o.id);
                    }
                    q.apply(FamilyProfileStore.instance, next);
                    setState(() {});
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _enumBlock<T>(
    V2Palette p,
    String id,
    String title,
    List<T> values,
    String Function(T) label,
    Set<T> current,
    void Function(T) toggle, {
    String? note,
  }) => _block(
    id,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: pvManrope(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: p.ink1,
          ),
        ),
        if (note != null) ...[
          const SizedBox(height: 3),
          Text(
            note,
            style: pvManrope(fontSize: 12.5, height: 1.4, color: p.ink3),
          ),
        ],
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final v in values)
              PvChip(
                label: label(v),
                selected: current.contains(v),
                onTap: () {
                  toggle(v);
                  setState(() {});
                },
              ),
          ],
        ),
      ],
    ),
  );

  Widget _linkBlock(
    V2Palette p,
    String id,
    String title,
    String body,
    String cta,
    VoidCallback onTap,
  ) => _block(
    id,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: pvManrope(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: p.ink1,
          ),
        ),
        const SizedBox(height: 4),
        Text(body, style: pvManrope(fontSize: 13, height: 1.45, color: p.ink2)),
        const SizedBox(height: 12),
        PvSecondary(label: cta, onTap: onTap),
      ],
    ),
  );

  Widget _roleBlock(V2Palette p) {
    final s = SkChildStore.instance;
    final v = s.verification.name;
    return _block(
      'role',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your role',
            style: pvManrope(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: p.ink1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            v == 'none'
                ? 'The grown-up gate has not been set up yet. It is set up from any skill door, under "For the grown-up".'
                : 'Verified as: ${v[0].toUpperCase()}${v.substring(1)}. ${s.hasPin ? 'A PIN guards the grown-up side.' : 'No PIN yet — a sum in words guards it.'}',
            style: pvManrope(fontSize: 13, height: 1.45, color: p.ink2),
          ),
        ],
      ),
    );
  }
}
