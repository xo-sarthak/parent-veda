// =============================================================================
//  Courses & Masterclasses — the redesigned home. A guide, not a shop.
// -----------------------------------------------------------------------------
//  Built to the Courses brief, on the same kit as the other three Explore
//  redesigns, because the brief asked for it: "Reuse the same design language
//  established in the redesigned Recipes, Read, and Recommendations sections so
//  the entire Explore experience feels cohesive."
//
//  Page order, as specified:
//      expert banner -> search -> type filters -> topic filters
//      -> Chosen for you -> Live Cohorts / Recorded Courses / Masterclasses,
//         each with View all
//
//  WHAT IS REUSED RATHER THAN REBUILT. The existing filter logic
//  (filterLearning, kLearningTopics, LearningKind) is untouched and drives both
//  rows — the brief says "Keep existing filters. Do NOT redesign them." The
//  detail page (learning_detail_screen.dart) is also untouched; the brief's
//  expandable-section detail page is built as a NEW screen beside it, so a
//  parent mid-purchase on the old one is not moved mid-flight.
//
//  CARD HEIGHT IS DELIBERATELY UNCHANGED, and the brief is unusually specific:
//  "Maintain current card height. Do NOT make cards larger." So the rail here
//  is the same 214 the Recommendations rail uses, and the card carries the
//  seven things the brief lists and nothing else. "Avoid visual clutter" is the
//  whole instruction for this feature.
//
//  THE OLD SCREEN IS UNTOUCHED. learning_home_screen.dart still exists; the
//  Explore row that opened it is commented in place beside the new one.
// =============================================================================

import 'package:flutter/material.dart';

import 'learning_detail_screen.dart';
import 'pp_common.dart';
import 'pp_experts_data.dart';
import 'pp_explore_kit.dart';
import 'pp_learning_data.dart';

// =============================================================================
//  The three sections
// =============================================================================

class CourseSection {
  const CourseSection(this.title, this.kind, this.icon, this.accent);

  final String title;
  final LearningKind kind;
  final IconData icon;
  final Color accent;
}

const List<CourseSection> kCourseSections = [
  CourseSection('Live cohorts', LearningKind.liveCohort,
      Icons.groups_outlined, ppAccentAmber),
  CourseSection('Recorded courses', LearningKind.recordedCourse,
      Icons.play_lesson_outlined, ppPurple),
  CourseSection('Masterclasses', LearningKind.masterclass,
      Icons.workspace_premium_outlined, ppAccentBlue),
];

String courseKindLabel(LearningKind k) => switch (k) {
      LearningKind.liveCohort => 'Live cohort',
      LearningKind.recordedCourse => 'Recorded course',
      LearningKind.masterclass => 'Masterclass',
    };

class CoursesExploreScreen extends StatefulWidget {
  const CoursesExploreScreen({super.key});

  @override
  State<CoursesExploreScreen> createState() => _CoursesExploreScreenState();
}

class _CoursesExploreScreenState extends State<CoursesExploreScreen> {
  final _search = TextEditingController();
  String _q = '';
  String _type = 'All';
  String _topic = 'All topics';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _push(Widget s) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => s));

  LearningKind? get _kind => switch (_type) {
        'Live cohorts' => LearningKind.liveCohort,
        'Recorded courses' => LearningKind.recordedCourse,
        'Masterclasses' => LearningKind.masterclass,
        _ => null,
      };

  /// The existing filter, untouched — the brief was explicit about not
  /// redesigning it.
  List<LearningProgram> _pool({LearningKind? kind}) => filterLearning(
        kind: kind ?? _kind,
        topic: _topic == 'All topics' ? null : _topic,
        query: null,
      );

  List<LearningProgram> get _results {
    final t = _q.trim().toLowerCase();
    if (t.isEmpty) return const [];
    // Searches courses AND experts, per the brief.
    return learningCatalogue().where((p) {
      final e = expertById(p.instructorId);
      return p.title.toLowerCase().contains(t) ||
          p.subtitle.toLowerCase().contains(t) ||
          p.topics.any((x) => x.toLowerCase().contains(t)) ||
          e.name.toLowerCase().contains(t);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final searching = _q.trim().isNotEmpty;
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 40),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: ppBack(context, 'Explore'),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Text('Courses & Masterclasses',
                  style: ppFraunces(29, h: 1.08)),
            ),

            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 22),
              child: ExpertCuratedBanner(
                text: 'Every course and masterclass is created or carefully '
                    'vetted by trusted parenting experts, and suggested for '
                    'your baby’s age and stage.',
                icon: Icons.school_outlined,
                accent: ppPurple,
              ),
            ),

            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: ExploreSearchBar(
                controller: _search,
                hint: 'Search sleep, feeding, solids, experts…',
                onChanged: (v) => setState(() => _q = v),
              ),
            ),

            const SizedBox(height: 14),
            ExploreFilterChips(
              labels: const [
                'All',
                'Live cohorts',
                'Recorded courses',
                'Masterclasses',
              ],
              selected: _type,
              onSelect: (v) => setState(() => _type = v),
            ),
            const SizedBox(height: 9),
            ExploreFilterChips(
              labels: ['All topics', ...kLearningTopics],
              selected: _topic,
              onSelect: (v) => setState(() => _topic = v),
            ),

            const SizedBox(height: 22),
            if (searching) ..._searchResults() else ..._sections(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ---- sections ------------------------------------------------------------

  List<Widget> _sections() {
    final chosen = _pool();
    final out = <Widget>[];

    out
      ..add(ExploreSectionHeader(
        title: 'Chosen for you',
        subtitle: 'Suggested for this age and what you have been learning.',
      ))
      ..add(const SizedBox(height: 12));

    if (chosen.isEmpty) {
      out.add(ExploreEmpty(
        title: 'No courses match',
        subtitle: 'Try another topic, or clear the filters above.',
        icon: Icons.school_outlined,
        cta: 'Clear filters',
        onCta: () => setState(() {
          _type = 'All';
          _topic = 'All topics';
        }),
      ));
      return out;
    }

    // 3–5, per the brief.
    out
      ..add(ExploreRail(
        height: 236,
        itemWidth: 210,
        children: [for (final p in chosen.take(5)) _card(p, reason: true)],
      ))
      ..add(const SizedBox(height: 28));

    for (final s in kCourseSections) {
      // A type filter narrows the page to one section; the others would render
      // empty, so they are skipped rather than shown as three empty headers.
      if (_kind != null && _kind != s.kind) continue;
      final items = _pool(kind: s.kind);
      if (items.isEmpty) continue;
      out
        ..add(ExploreSectionHeader(
          title: s.title,
          seeMoreLabel: 'View all',
          onSeeMore: () => _push(CourseListingScreen(section: s, topic: _topic)),
        ))
        ..add(const SizedBox(height: 12))
        ..add(ExploreRail(
          height: 236,
          itemWidth: 210,
          children: [for (final p in items.take(6)) _card(p)],
        ))
        ..add(const SizedBox(height: 26));
    }
    return out;
  }

  Widget _card(LearningProgram p, {bool reason = false}) =>
      CourseCard(program: p, showReason: reason, onTap: () => _open(p));

  void _open(LearningProgram p) => _push(CourseDetailScreen(program: p));

  // ---- search --------------------------------------------------------------

  List<Widget> _searchResults() {
    final results = _results;
    if (results.isEmpty) {
      return [
        ExploreEmpty(
          title: 'No courses found',
          subtitle: 'Try another topic, or a different expert’s name.',
          cta: 'Clear search',
          onCta: () {
            _search.clear();
            setState(() => _q = '');
            FocusScope.of(context).unfocus();
          },
        ),
      ];
    }
    return [
      ExploreSectionHeader(
        title: '${results.length} result${results.length == 1 ? '' : 's'}',
        subtitle: 'Courses, cohorts, masterclasses and experts',
      ),
      const SizedBox(height: 12),
      for (final p in results)
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 10),
          child: CourseResultRow(program: p, onTap: () => _open(p)),
        ),
    ];
  }
}

// =============================================================================
//  The card
// -----------------------------------------------------------------------------
//  Seven things, and the brief names all seven: hero image, type badge, title,
//  one-line description, expert, next cohort or duration, price. Plus a
//  bookmark and an optional recommendation line.
//
//  "Nothing more. Avoid visual clutter." — so ratings, seat counts and topic
//  tags are deliberately absent from the card and live on the detail page.
// =============================================================================

class CourseCard extends StatelessWidget {
  const CourseCard({
    super.key,
    required this.program,
    required this.onTap,
    this.showReason = false,
  });

  final LearningProgram program;
  final VoidCallback onTap;
  final bool showReason;

  CourseSection get _section =>
      kCourseSections.firstWhere((s) => s.kind == program.kind);

  @override
  Widget build(BuildContext context) {
    final e = expertById(program.instructorId);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ExploreThumb(
          icon: _section.icon,
          accent: program.accent,
          height: 106,
          topLeft: ExploreBadge(label: courseKindLabel(program.kind)),
        ),
        const SizedBox(height: 9),
        Text(program.title,
            style: ppJakarta(13.5).copyWith(height: 1.25),
            maxLines: 2,
            overflow: TextOverflow.ellipsis),
        const SizedBox(height: 4),
        Text(program.subtitle,
            style: ppBody(11, color: ppMuted, h: 1.3),
            maxLines: 2,
            overflow: TextOverflow.ellipsis),
        const SizedBox(height: 5),
        Text(e.name,
            style: ppBody(11, color: ppSoft, w: FontWeight.w700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        const Spacer(),
        if (showReason && program.topics.isNotEmpty) ...[
          Text('Recommended for ${program.topics.first.toLowerCase()}',
              style: ppBody(10.5, color: ppPurple, w: FontWeight.w700),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
        ],
        Row(children: [
          Expanded(
            child: Text(
                program.startLabel ?? program.durationLabel,
                style: ppBody(10.5, color: ppMuted),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
          Text(program.price,
              style: ppBody(12, color: ppInk, w: FontWeight.w800)),
        ]),
      ]),
    );
  }
}

class CourseResultRow extends StatelessWidget {
  const CourseResultRow({super.key, required this.program, required this.onTap});

  final LearningProgram program;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final e = expertById(program.instructorId);
    final s = kCourseSections.firstWhere((x) => x.kind == program.kind);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ppBorder),
        ),
        child: Row(children: [
          SizedBox(
            width: 62,
            child: ExploreThumb(
              icon: s.icon,
              accent: program.accent,
              height: 62,
              radius: 12,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(program.title,
                  style: ppJakarta(13.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 3),
              Text('${courseKindLabel(program.kind)} · ${e.name}',
                  style: ppBody(11.5, color: ppMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 5),
              Text(program.price,
                  style: ppBody(12, color: ppInk, w: FontWeight.w800)),
            ]),
          ),
          const Icon(Icons.chevron_right_rounded, size: 20, color: ppMuted),
        ]),
      ),
    );
  }
}

// =============================================================================
//  "View all" — one kind
// =============================================================================

class CourseListingScreen extends StatefulWidget {
  const CourseListingScreen({
    super.key,
    required this.section,
    required this.topic,
  });

  final CourseSection section;
  final String topic;

  @override
  State<CourseListingScreen> createState() => _CourseListingScreenState();
}

class _CourseListingScreenState extends State<CourseListingScreen> {
  final _search = TextEditingController();
  String _q = '';
  late String _topic = widget.topic;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<LearningProgram> get _items {
    var list = filterLearning(
      kind: widget.section.kind,
      topic: _topic == 'All topics' ? null : _topic,
      query: null,
    );
    final t = _q.trim().toLowerCase();
    if (t.isNotEmpty) {
      list = list
          .where((p) =>
              p.title.toLowerCase().contains(t) ||
              p.subtitle.toLowerCase().contains(t))
          .toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 40),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: ppBack(context, 'Courses'),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Text(widget.section.title, style: ppFraunces(28, h: 1.05)),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: ExploreSearchBar(
                controller: _search,
                hint: 'Search ${widget.section.title.toLowerCase()}…',
                onChanged: (v) => setState(() => _q = v),
              ),
            ),
            const SizedBox(height: 14),
            ExploreFilterChips(
              labels: ['All topics', ...kLearningTopics],
              selected: _topic,
              onSelect: (v) => setState(() => _topic = v),
            ),
            const SizedBox(height: 20),
            if (items.isEmpty)
              ExploreEmpty(
                title: 'No courses found',
                subtitle: 'Try another topic.',
                cta: 'Clear',
                onCta: () {
                  _search.clear();
                  setState(() {
                    _q = '';
                    _topic = 'All topics';
                  });
                },
              )
            else
              for (final p in items)
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 10),
                  child: CourseResultRow(
                    program: p,
                    onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                            builder: (_) => CourseDetailScreen(program: p))),
                  ),
                ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
//  The detail page
// -----------------------------------------------------------------------------
//  The brief's shape, and its central rule stated twice: the big sections are
//  EXPANDED BY DEFAULT so a parent understands the course by scrolling, and
//  only the individual outcomes and modules collapse.
//
//  That is the opposite of the usual accordion, and it is right: a page that
//  hides "What you'll learn" behind a chevron is a sales page pretending to be
//  a syllabus. FAQs are the one thing collapsed by default, because they are
//  the one thing you go looking for rather than read through.
//
//  ⚠️ THE EXISTING DETAIL PAGE IS UNTOUCHED. learning_detail_screen.dart still
//  exists and still owns the real purchase flow; the sticky bar here routes
//  into it rather than reimplementing a checkout. A parent halfway through
//  buying should not meet a second, differently-built version of the same
//  transaction.
// =============================================================================

class CourseDetailScreen extends StatefulWidget {
  const CourseDetailScreen({super.key, required this.program});
  final LearningProgram program;

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  final _openOutcomes = <int>{};
  final _openModules = <int>{};
  final _openFaqs = <int>{};

  LearningProgram get p => widget.program;

  @override
  Widget build(BuildContext context) {
    final e = expertById(p.instructorId);
    final s = kCourseSections.firstWhere((x) => x.kind == p.kind);
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: Stack(children: [
          ListView(
            // Room for the sticky bar.
            padding: const EdgeInsets.only(top: 12, bottom: 116),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: ppBack(context, 'Courses'),
              ),
              const SizedBox(height: 16),

              // ---- hero -------------------------------------------------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: ExploreThumb(
                  icon: s.icon,
                  accent: p.accent,
                  height: 170,
                  radius: 20,
                  topLeft: ExploreBadge(label: courseKindLabel(p.kind)),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Text(p.title, style: ppFraunces(27, h: 1.1)),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Text(p.subtitle, style: ppBody(14, h: 1.55)),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Row(children: [
                  const Icon(Icons.person_outline_rounded,
                      size: 15, color: ppMuted),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(e.name,
                        style: ppBody(12.5, color: ppSoft, w: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                ]),
              ),

              // ---- quick facts -----------------------------------------
              const SizedBox(height: 18),
              _quickFacts(),

              // ---- about ------------------------------------------------
              const SizedBox(height: 24),
              _section('About this course',
                  child: Text(
                      p.about.isEmpty
                          ? '${p.title} — ${p.subtitle}'
                          : p.about,
                      style: ppBody(13.5, h: 1.65))),

              // ---- what you'll learn ------------------------------------
              if (p.takeaways.isNotEmpty) ...[
                const SizedBox(height: 22),
                _section("What you'll learn",
                    child: Column(children: [
                      for (var i = 0; i < p.takeaways.length; i++)
                        _outcome(i, p.takeaways[i]),
                    ])),
              ],

              // ---- curriculum -------------------------------------------
              if (p.sessions.isNotEmpty) ...[
                const SizedBox(height: 22),
                _section('Course curriculum',
                    child: Column(children: [
                      for (var i = 0; i < p.sessions.length; i++)
                        _module(i, p.sessions[i]),
                    ])),
              ],

              // ---- who it's for -----------------------------------------
              if (p.covers.isNotEmpty) ...[
                const SizedBox(height: 22),
                _section('What this covers',
                    child: Column(children: [
                      for (final c in p.covers) _tick(c),
                    ])),
              ],

              // ---- expert -----------------------------------------------
              const SizedBox(height: 22),
              _section('Meet your expert',
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: ppPurple.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.person_rounded,
                              size: 24, color: ppPurple),
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(e.name, style: ppJakarta(14.5)),
                                const SizedBox(height: 3),
                                Text(e.credential,
                                    style: ppBody(12, color: ppMuted)),
                                const SizedBox(height: 7),
                                Text(e.blurb, style: ppBody(12.5, h: 1.55)),
                              ]),
                        ),
                      ])),

              // ---- ratings ----------------------------------------------
              const SizedBox(height: 22),
              _section('Ratings',
                  child: Row(children: [
                    const Icon(Icons.star_rounded,
                        size: 20, color: ppAccentAmber),
                    const SizedBox(width: 8),
                    Text(p.rating.toStringAsFixed(1), style: ppJakarta(18)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                          p.reviewsLabel.isEmpty
                              ? 'from parents who took it'
                              : p.reviewsLabel,
                          style: ppBody(12.5, color: ppMuted)),
                    ),
                  ])),

              // ---- FAQs, collapsed --------------------------------------
              const SizedBox(height: 22),
              _section('Common questions',
                  child: Column(children: [
                    for (var i = 0; i < _faqs.length; i++)
                      _faq(i, _faqs[i].$1, _faqs[i].$2),
                  ])),
              const SizedBox(height: 20),
            ],
          ),
          Positioned(left: 0, right: 0, bottom: 0, child: _stickyBar()),
        ]),
      ),
    );
  }

  // ---- pieces --------------------------------------------------------------

  Widget _section(String title, {required Widget child}) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: ppJakarta(17)),
          const SizedBox(height: 12),
          child,
        ]),
      );

  Widget _quickFacts() {
    final facts = <(IconData, String, String)>[
      if ((p.startLabel ?? '').isNotEmpty)
        (Icons.event_outlined, 'Starts', p.startLabel!),
      if (p.durationLabel.isNotEmpty)
        (Icons.schedule_rounded, 'Length', p.durationLabel),
      (Icons.translate_rounded, 'Language', 'Hindi & English'),
      if (p.kind != LearningKind.recordedCourse)
        (Icons.videocam_outlined, 'Recording',
            p.isLiveScheduled ? 'For those who join live' : 'Included'),
    ];
    return SizedBox(
      height: 76,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        itemCount: facts.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (_, i) => Container(
          width: 148,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: ppBorder),
          ),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(children: [
                  Icon(facts[i].$1, size: 13, color: ppMuted),
                  const SizedBox(width: 6),
                  Text(facts[i].$2,
                      style: ppBody(10.5, color: ppMuted, w: FontWeight.w800)),
                ]),
                const SizedBox(height: 5),
                Text(facts[i].$3,
                    style: ppBody(12, color: ppInk, w: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ]),
        ),
      ),
    );
  }

  /// One learning outcome. Expanded independently, per the brief.
  Widget _outcome(int i, String text) {
    final open = _openOutcomes.contains(i);
    return GestureDetector(
      onTap: () => setState(
          () => open ? _openOutcomes.remove(i) : _openOutcomes.add(i)),
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ppBorder),
        ),
        child: Column(children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.check_rounded, size: 16, color: ppAccentGreen),
            const SizedBox(width: 10),
            Expanded(child: Text(text, style: ppBody(13.5, h: 1.5))),
            Icon(open ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                size: 19, color: ppMuted),
          ]),
          if (open) ...[
            const SizedBox(height: 10),
            Container(height: 1, color: ppHair),
            const SizedBox(height: 10),
            // Honest: there is no per-outcome long-form copy in the catalogue
            // yet, so this says what it can rather than inventing detail that
            // would read as filler.
            Text(
                'Covered across the sessions, with the practical version — what '
                'to actually do, and what to expect when you try it.',
                style: ppBody(12.5, color: ppSoft, h: 1.55)),
          ],
        ]),
      ),
    );
  }

  Widget _module(int i, LearningSession s) {
    final open = _openModules.contains(i);
    return GestureDetector(
      onTap: () =>
          setState(() => open ? _openModules.remove(i) : _openModules.add(i)),
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ppBorder),
        ),
        child: Column(children: [
          Row(children: [
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: ppPurple.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Text('${i + 1}',
                  style: ppBody(11.5, color: ppPurple, w: FontWeight.w800)),
            ),
            const SizedBox(width: 11),
            Expanded(child: Text(s.title, style: ppJakarta(13.5))),
            Icon(open ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                size: 19, color: ppMuted),
          ]),
          if (open) ...[
            const SizedBox(height: 10),
            Container(height: 1, color: ppHair),
            const SizedBox(height: 10),
            // The brief: an expanded module shows its lessons and when it
            // runs. LearningSession already carries both — `when` and
            // `points` — so nothing needed inventing.
            Align(
              alignment: Alignment.centerLeft,
              child: Text('${s.label} · ${s.when}',
                  style: ppBody(11.5, color: ppMuted, w: FontWeight.w700)),
            ),
            if (s.points.isNotEmpty) ...[
              const SizedBox(height: 9),
              for (final pt in s.points)
                Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 6),
                          width: 5,
                          height: 5,
                          decoration: const BoxDecoration(
                              color: ppMuted, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(pt, style: ppBody(12.5, h: 1.5)),
                        ),
                      ]),
                ),
            ],
          ],
        ]),
      ),
    );
  }

  Widget _tick(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 9),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.check_circle_outline_rounded,
              size: 16, color: ppPurple),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: ppBody(13.5, h: 1.5))),
        ]),
      );

  /// The one section the brief wants collapsed — you go looking for an FAQ,
  /// you do not read through them.
  List<(String, String)> get _faqs => [
        (
          'What if I cannot attend live?',
          p.isLiveScheduled
              ? 'This one runs live and the recording goes only to parents who '
                  'joined, so the session itself is the course.'
              : 'The recording is included, so you can take it whenever the '
                  'day allows.'
        ),
        (
          'Is it in Hindi or English?',
          'Both. Sessions are run bilingually, the way most Indian families '
              'actually talk.'
        ),
        (
          'How long do I have access?',
          p.kind == LearningKind.recordedCourse
              ? 'Lifetime access once you have it.'
              : 'Through the cohort, and afterwards wherever a recording is '
                  'included.'
        ),
      ];

  Widget _faq(int i, String q, String a) {
    final open = _openFaqs.contains(i);
    return GestureDetector(
      onTap: () => setState(() => open ? _openFaqs.remove(i) : _openFaqs.add(i)),
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: ppPanel,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(children: [
          Row(children: [
            Expanded(child: Text(q, style: ppJakarta(13))),
            Icon(open ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                size: 19, color: ppMuted),
          ]),
          if (open) ...[
            const SizedBox(height: 9),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(a, style: ppBody(12.5, h: 1.55)),
            ),
          ],
        ]),
      ),
    );
  }

  /// Always visible, per the brief. Routes into the EXISTING detail screen,
  /// which owns the real reserve/purchase flow — see the header.
  Widget _stickyBar() => Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: ppHair)),
        ),
        child: Row(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(p.price, style: ppJakarta(18)),
            Text(p.priceNote, style: ppBody(10.5, color: ppMuted)),
          ]),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                  builder: (_) => LearningDetailScreen(program: p))),
              behavior: HitTestBehavior.opaque,
              child: Container(
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: ppPurple,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                    p.isLiveScheduled ? 'Join live' : 'Reserve my seat',
                    style:
                        ppBody(14, color: Colors.white, w: FontWeight.w800)),
              ),
            ),
          ),
        ]),
      );
}
