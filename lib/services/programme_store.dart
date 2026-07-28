// =============================================================================
//  ProgrammeStore — masterclasses and cohorts, served from Supabase.
// -----------------------------------------------------------------------------
//  The first SERVER-ONLY content type. Recipes, reads and products all ship a
//  bundled copy inside the app; programmes ship nothing, because there are no
//  masterclasses until somebody schedules one. "Nothing scheduled yet" is a
//  legitimate state, not a failure — so this declares `serverOnly: true` rather
//  than smuggling an empty list past the seed assertion.
//
//  It reads the VIEW `programmes_published` (0056), not the `programmes` table.
//  "Who teaches this" is the outcome of a process — invite several experts, one
//  accepts — so it lives in programme_experts, and resolving it is a join. The
//  join is in the database on purpose: the rule "the host is the first expert
//  who accepted" then has one home that the app, the website and anything
//  later all read the same way.
//
//  Two mapping decisions, made here deliberately rather than guessed:
//
//  1. AN UNKNOWN `kind` RENDERS AS A MASTERCLASS. The column is free text so a
//     new experience type ('meditation', 'webinar') needs no release. Dart's
//     enum is fixed. Falling back to the most generic kind keeps a published
//     programme VISIBLE and sellable in a slightly wrong category, which beats
//     the alternative of a programme that exists, is paid for, and silently
//     appears nowhere. "A feature is never hidden."
//
//  2. THE ACCENT COLOUR IS DERIVED, NOT STORED. Colour is a design decision,
//     not business data, and an editor picking hex codes is how a product
//     stops looking like one product. Derived from `kind`, so every cohort
//     looks like a cohort.
// =============================================================================

import 'package:flutter/material.dart';

import '../screens/post_pregnancy/pp_learning_data.dart';
import 'content_store.dart';
import 'remote/content_repo.dart';

class ProgrammeStore extends ContentStore<LearningProgram> {
  ProgrammeStore._()
      : super(
          table: 'programmes_published',
          cacheKey: 'content_programmes_v1',
          seed: const <LearningProgram>[],
          serverOnly: true,
        );

  static final ProgrammeStore instance = ProgrammeStore._();

  // The view already filters to published, and `sort` does not exist on it —
  // order by when the thing actually happens, which is what a parent scanning
  // a list of live sessions is deciding between.
  @override
  List<ContentOrder> get order =>
      const [ContentOrder('first_session_utc'), ContentOrder('published_at')];

  // No status override needed: the view carries `status` through, so the base
  // class's `status = 'published'` filter still applies. Belt and braces —
  // the view already filters to published itself.

  static String _text(Object? v) => (v as String?) ?? '';

  static LearningKind _kind(Object? v) => switch (v) {
        'cohort' || 'live_cohort' || 'liveCohort' => LearningKind.liveCohort,
        'course' || 'recorded' || 'recordedCourse' => LearningKind.recordedCourse,
        // masterclass, workshop, webinar, yoga, meditation, and anything a
        // future editor invents. See decision 1 in the header.
        _ => LearningKind.masterclass,
      };

  static Color _accent(LearningKind kind) => switch (kind) {
        LearningKind.liveCohort => const Color(0xFF6A30B6),      // violet
        LearningKind.recordedCourse => const Color(0xFF3E6DA6),  // blue
        LearningKind.masterclass => const Color(0xFFFF5A79),     // rose
      };

  /// Where the programme sits in its selling lifecycle, derived from the
  /// session dates rather than stored. A status column would need something to
  /// keep it current, and nothing runs on a schedule here — a programme whose
  /// last session was yesterday would sit at "available" until somebody
  /// noticed. Dates cannot go stale.
  static LearningStatus _status(DateTime? first, DateTime? last) {
    final now = DateTime.now();
    if (last != null && last.isBefore(now)) return LearningStatus.completed;
    if (first != null && first.isBefore(now)) return LearningStatus.ongoing;
    return LearningStatus.available;
  }

  static DateTime? _date(Object? v) =>
      v == null ? null : DateTime.tryParse(v.toString())?.toLocal();

  /// "₹1,499" from integer paise. Money is stored in paise and shown in
  /// rupees; the app never does arithmetic on the displayed string.
  static String _price(Object? paise) {
    final p = (paise as num?)?.toInt() ?? 0;
    if (p == 0) return 'Free';
    final rupees = (p / 100).round().toString();
    if (rupees.length <= 3) return '₹$rupees';
    final head = rupees.substring(0, rupees.length - 3);
    return '₹$head,${rupees.substring(rupees.length - 3)}';
  }

  @override
  LearningProgram fromMap(Map<String, dynamic> row) {
    final kind = _kind(row['kind']);
    final first = _date(row['first_session_utc']);
    final last = _date(row['last_session_utc']);
    final sessions = (row['session_count'] as num?)?.toInt() ?? 0;

    return LearningProgram(
      id: _text(row['id']),
      kind: kind,
      instructorId: _text(row['expert_id']),
      title: _text(row['title']),
      subtitle: _text(row['subtitle']),
      topics: const [],
      accent: _accent(kind),
      price: _price(row['price_paise']),
      status: _status(first, last),
      isLiveScheduled: first != null,
      startLabel: first == null ? null : _startLabel(first),
      durationLabel: sessions > 1 ? '$sessions sessions' : '',
      about: _text(row['summary']).isEmpty
          ? _text(row['body'])
          : _text(row['summary']),
      seatsLeft: (row['seats_left'] as num?)?.toInt(),
      // Newest first among things starting at the same time.
      recency: first?.millisecondsSinceEpoch ?? 0,
    );
  }

  static String _startLabel(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${months[d.month - 1]}';
  }

  @override
  Map<String, dynamic> toCacheMap(LearningProgram p) => <String, dynamic>{
        'id': p.id,
        'kind': p.kind.name,
        'expert_id': p.instructorId,
        'title': p.title,
        'subtitle': p.subtitle,
        'summary': p.about,
        // Cached back in the shape the view returns, so one mapper decodes
        // both a live row and a cached one.
        'price_paise': _paiseFromLabel(p.price),
        'session_count': p.durationLabel.isEmpty ? 1 : null,
        'first_session_utc': null,
        'last_session_utc': null,
        'seats_left': p.seatsLeft,
      };

  /// The inverse of [_price], for the cache only. Imperfect by design: a cached
  /// programme is a placeholder until the next fetch, and the fetch is the
  /// authority on price. Money is never decided from a cached string.
  static int _paiseFromLabel(String label) {
    final digits = label.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.isEmpty ? 0 : int.parse(digits) * 100;
  }
}
