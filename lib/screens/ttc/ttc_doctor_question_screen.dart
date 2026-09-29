// =============================================================================
//  TTC - write, change or remove a question for the doctor
// -----------------------------------------------------------------------------
//  The Appointments page's own writer (2026-09-28). Until today a question
//  was written through the journal's writer (`writeTtcEntry(kind:
//  question)`), which opened "for a question" with no other kind on offer.
//  The journal is now commented out of Trying to Conceive, so the questions
//  got their own store (`TtcDoctorQuestionsStore`) and this page of their
//  own. It looks and reads the way that writer did for a question, so
//  nothing changes on her screen:
//
//   · a full page with Close, the title "A question for your doctor" (or
//     "Edit your question"), and Save in the top bar;
//   · the words on the page, not in a boxed field;
//   · a line saying where the question shows, and who can read it.
//
//  One change: a question of hers opens straight here to change it, with
//  "Delete question" at the foot (a confirm, then an Undo), where the journal
//  opened a read page first and hid Delete behind a menu. A question is one
//  line; a page just to read one line was a step with nothing in it. Her
//  partner's question opens read-only: it is his to change.
//
//  Shape from Mobbin (2026-09-28): an edit page where the text sits directly
//  on the page under Cancel / title / Save, Rodeo "Edit summary"
//  https://mobbin.com/screens/7babec1f-9222-467d-b31f-30ba21da85bc and
//  Perplexity https://mobbin.com/screens/36dd7a92-7d59-43f9-9a67-4750f04f0112;
//  the destructive word at the foot, Tripadvisor "Edit note"
//  https://mobbin.com/screens/81bd2fd8-26dc-4819-9a73-4f8764747c5a
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../../ttc/ttc_doctor_questions_store.dart';
import '../../ttc/ttc_store.dart';
import '../../widgets/pv_feedback.dart' show pvCommitFeedback;
import '../products/pv_store_chrome.dart' show pvSnack;
import '../v2/v2_palette.dart';
import 'ttc_appointments_screen.dart' show ttcVisitName;
import 'ttc_ivf_readiness_screen.dart' show kIvfHue;
import 'ttc_tool_chrome.dart' show TtcToolPill;

/// The route name. `global_ask_fab.dart` hides the Ask button on it, because
/// a keyboard is up and the button sat over the words.
const String kTtcDoctorQuestionRoute = 'ttc/appointments/question';

/// The red a destructive word takes.
// One danger red, DESIGN-SYSTEM §4.0 (2026-09-29). Kept for revert: Color(0xFFC0392B)
const Color _kDanger = Color(0xFFB3261E);

/// Opens the writer for a new question. [visitId] is the visit it starts
/// on (a visit's own page passes itself); otherwise her next visit, the
/// approved default (2026-09-28).
// Kept for revert (2026-09-28): writeTtcDoctorQuestion(BuildContext context)
// with no visit.
Future<void> writeTtcDoctorQuestion(BuildContext context, {String? visitId}) =>
    Navigator.of(context).push(MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => TtcDoctorQuestionScreen(initialVisitId: visitId),
      settings: const RouteSettings(name: kTtcDoctorQuestionRoute),
    ));

/// Opens a saved question: hers to change or delete, his to read.
Future<void> openTtcDoctorQuestion(
        BuildContext context, TtcDoctorQuestion question) =>
    Navigator.of(context).push(MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => TtcDoctorQuestionScreen(editing: question),
      settings: const RouteSettings(name: kTtcDoctorQuestionRoute),
    ));

/// Who can read her questions, said plainly.
String ttcDoctorQuestionsWhoSees(bool partnerJoined) => partnerJoined
    ? 'Your partner can read your questions, and you can read theirs.'
    : 'When your partner joins, they can read your questions too.';

class TtcDoctorQuestionScreen extends StatefulWidget {
  const TtcDoctorQuestionScreen(
      {super.key, this.editing, this.initialVisitId});

  /// The question being changed, or null for a new one.
  final TtcDoctorQuestion? editing;

  /// For a new question: the visit it starts on. Null: her next visit.
  final String? initialVisitId;

  @override
  State<TtcDoctorQuestionScreen> createState() =>
      _TtcDoctorQuestionScreenState();
}

class _TtcDoctorQuestionScreenState extends State<TtcDoctorQuestionScreen> {
  late final TextEditingController _text =
      TextEditingController(text: widget.editing?.text);

  bool get _editing => widget.editing != null;

  /// Her partner's question: shown, never changed here.
  bool get _readOnly => _editing && !widget.editing!.isMine;

  // ---- which visit (2026-09-28) ---------------------------------------------
  //  A question belongs to one visit. The choices are the visits whose day
  //  has not passed, plus "whichever visit comes next" (null). A ticked
  //  question keeps the visit it was asked at, so it gets no choice here.

  TtcDoctorQuestionsStore get _store => TtcDoctorQuestionsStore.instance;

  List<TtcVisitRef> get _visitChoices {
    final now = DateTime.now();
    return _store.visits
        .where((v) => !TtcDoctorQuestionsStore.dayPassed(v, now))
        .take(6)
        .toList();
  }

  /// The visit it starts on: its own for a saved one (when that visit is
  /// still to come), the page's or her next visit for a new one.
  late final String? _startVisit = () {
    final e = widget.editing;
    final ids = _visitChoices.map((v) => v.id).toSet();
    if (e != null) {
      return ids.contains(e.appointmentId) ? e.appointmentId : null;
    }
    final want = widget.initialVisitId ?? _store.nextVisit()?.id;
    return ids.contains(want) ? want : null;
  }();

  late String? _visit = _startVisit;

  bool get _choosesVisit =>
      !_readOnly && !(widget.editing?.isAsked ?? false);

  bool get _visitChanged => _choosesVisit && _visit != _startVisit;

  // Kept for revert (2026-09-28): the words were the only thing to save.
  //   bool get _canSave => !_readOnly && _text.text.trim().isNotEmpty &&
  //       (!_editing || _text.text.trim() != widget.editing!.text);
  //   bool get _dirty => !_readOnly &&
  //       _text.text.trim() != (widget.editing?.text ?? '').trim();
  bool get _canSave =>
      !_readOnly &&
      _text.text.trim().isNotEmpty &&
      (!_editing ||
          _text.text.trim() != widget.editing!.text ||
          _visitChanged);

  bool get _dirty =>
      !_readOnly &&
      (_text.text.trim() != (widget.editing?.text ?? '').trim() ||
          (_editing && _visitChanged));

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _save() {
    if (!_canSave) return;
    pvCommitFeedback();
    final store = TtcDoctorQuestionsStore.instance;
    if (_editing) {
      store.update(widget.editing!.id, _text.text);
      if (_visitChanged) store.moveTo(widget.editing!.id, _visit);
    } else {
      // Kept for revert (2026-09-28): store.add(_text.text);
      store.add(_text.text, visitId: _visit, forNextVisit: _visit == null);
    }
    pvSnack(
        context,
        _editing ? 'Changes saved.' : 'Saved to your questions for the doctor.',
        icon: Icons.check_rounded,
        lift: 24);
    Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final pal = V2PaletteStore.instance.current;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Delete this question?',
            style: pvFraunces(fontSize: 21, color: pal.ink1)),
        content: Text(
            'It comes off your questions for the doctor. You can undo it '
            'straight after.',
            style: pvManrope(fontSize: 14.5, height: 1.45, color: pal.ink2)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Keep it', style: TextStyle(color: pal.ink1))),
          TextButton(
              key: const ValueKey('ttc_question_delete_confirm'),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete', style: TextStyle(color: _kDanger))),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final id = widget.editing!.id;
    // A confirm and then an Undo: the confirm stops a stray tap, the Undo
    // catches "I meant the other one", which a confirm cannot.
    if (TtcDoctorQuestionsStore.instance.remove(id) == null) return;
    pvSnack(context, 'Question deleted.',
        action: 'Undo',
        onAction: () => TtcDoctorQuestionsStore.instance.restore(id),
        lift: 24);
    Navigator.of(context).pop();
  }

  /// Nothing silent: leaving with words typed asks first.
  Future<bool> _confirmLeave() async {
    if (!_dirty) return true;
    final pal = V2PaletteStore.instance.current;
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
            _editing ? 'Leave without saving?' : 'Discard this question?',
            style: pvFraunces(fontSize: 21, color: pal.ink1)),
        content: Text(
            _editing
                ? 'Your changes will not be kept.'
                : 'What you wrote will not be kept.',
            style: pvManrope(fontSize: 14.5, height: 1.45, color: pal.ink2)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Keep writing', style: TextStyle(color: pal.ink1))),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Discard', style: TextStyle(color: _kDanger))),
        ],
      ),
    );
    return leave == true;
  }

  /// Says where the question is kept and what happens to it, naming the
  /// visit rather than "it".
  String _whereLine() {
    final e = widget.editing;
    if (e != null && e.isAsked) {
      final v = _store.visitById(e.appointmentId);
      return v == null
          ? 'Ticked as asked.'
          : 'Ticked as asked at the ${ttcVisitName(v)}.';
    }
    if (_readOnly) {
      final v = _store.visitById(_store.visitFor(e!));
      return v == null
          ? 'Kept for whichever visit comes next.'
          : 'Kept for the ${ttcVisitName(v)}.';
    }
    if (_visitChoices.isEmpty) {
      return 'No visit is on your appointments yet, so the question waits '
          'for the next visit you add. On the day, you can tick it as asked.';
    }
    return 'The question shows on the visit you choose, with a tick for the '
        'day. If it is not ticked, it moves to your next visit.';
  }

  @override
  Widget build(BuildContext context) {
    final pal = V2PaletteStore.instance.current;
    final title = _readOnly
        ? "Your partner's question"
        : (_editing ? 'Edit your question' : 'A question for your doctor');

    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmLeave() && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          foregroundColor: pal.ink1,
          elevation: 0,
          leading: IconButton(
            tooltip: 'Close',
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: Text(title,
              style: pvManrope(
                  fontSize: 17, fontWeight: FontWeight.w700, color: pal.ink1)),
          actions: [
            if (!_readOnly)
              TextButton(
                key: const ValueKey('ttc_question_save'),
                onPressed: _canSave ? _save : null,
                child: Text('Save',
                    style: pvManrope(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: _canSave ? pal.ink1 : pal.ink3)),
              ),
            const SizedBox(width: 4),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 40),
          children: [
            if (_readOnly)
              SelectableText(widget.editing!.text,
                  style:
                      pvFraunces(fontSize: 18, height: 1.5, color: pal.ink1))
            else
              TextField(
                key: const ValueKey('ttc_question_text'),
                controller: _text,
                autofocus: true,
                onChanged: (_) => setState(() {}),
                minLines: 4,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                style: pvFraunces(fontSize: 18, height: 1.5, color: pal.ink1),
                decoration: InputDecoration(
                  hintText: 'What do you want to ask your doctor?',
                  hintStyle:
                      pvFraunces(fontSize: 18, height: 1.5, color: pal.ink3),
                  // All three borders and no fill: the app's input theme
                  // would otherwise draw an outline round the words.
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            const SizedBox(height: 18),
            Divider(height: 1, thickness: 1, color: pal.line),
            const SizedBox(height: 14),
            // Kept for revert (2026-09-28, a question belongs to a visit):
            //   _NoteLine(icon: Icons.event_note_outlined, text: 'It shows on
            //     every appointment that is coming up, ready to take in with
            //     you.'),
            if (_choosesVisit) ...[
              _VisitChoice(
                pal: pal,
                choices: _visitChoices,
                value: _visit,
                onChanged: (v) => setState(() => _visit = v),
              ),
              const SizedBox(height: 16),
            ],
            _NoteLine(
              pal: pal,
              icon: Icons.event_note_outlined,
              text: _whereLine(),
            ),
            const SizedBox(height: 10),
            _NoteLine(
              pal: pal,
              icon: Icons.visibility_outlined,
              text: _readOnly
                  ? 'Written by your partner. Only they can change it.'
                  : ttcDoctorQuestionsWhoSees(TtcStore.instance.partnerJoined),
              muted: true,
            ),
            if (_editing && !_readOnly) ...[
              const SizedBox(height: 30),
              Center(
                child: TextButton.icon(
                  key: const ValueKey('ttc_question_delete'),
                  onPressed: _delete,
                  icon: const Icon(Icons.delete_outline_rounded,
                      size: 17, color: _kDanger),
                  label: Text('Delete question',
                      style: pvManrope(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: _kDanger)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// "For which visit?": one pill per visit still to come, and "Whichever
/// visit comes next". The same pills the appointment form's quick names use.
class _VisitChoice extends StatelessWidget {
  const _VisitChoice({
    required this.pal,
    required this.choices,
    required this.value,
    required this.onChanged,
  });

  final V2Palette pal;
  final List<TtcVisitRef> choices;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('For which visit?',
          style: pvManrope(
              fontSize: 14.5, fontWeight: FontWeight.w800, color: pal.ink1)),
      const SizedBox(height: 10),
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (final v in choices)
          TtcToolPill(
            key: ValueKey('ttc_question_visit_${v.id}'),
            label: ttcVisitName(v),
            on: value == v.id,
            hue: kIvfHue,
            onTap: () => onChanged(v.id),
          ),
        TtcToolPill(
          key: const ValueKey('ttc_question_visit_next'),
          label: 'Whichever visit comes next',
          on: value == null,
          hue: kIvfHue,
          onTap: () => onChanged(null),
        ),
      ]),
    ]);
  }
}

class _NoteLine extends StatelessWidget {
  const _NoteLine({
    required this.pal,
    required this.icon,
    required this.text,
    this.muted = false,
  });

  final V2Palette pal;
  final IconData icon;
  final String text;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final c = muted ? pal.ink3 : pal.ink2;
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(top: 1),
        child: Icon(icon, size: 16, color: c),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Text(text,
            style: pvManrope(fontSize: 13, height: 1.45, color: c)),
      ),
    ]);
  }
}
