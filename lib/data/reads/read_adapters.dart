// =============================================================================
//  Every older reading model, as a PvRead — the adapters (STILL-OPEN §60.1)
// -----------------------------------------------------------------------------
//  The app grew nine ways to render a piece of writing: a mind-and-mood
//  article, a belly-and-skin page, a condition entry, a scan, a report
//  finding, a nutrient guide, a weekly read, a parenting library article and
//  the parenting archive's article. Each had its own screen, its own type
//  sizes, its own spacing, its own foot. The user (2026-09-17): *"I don't need
//  issues in confusion for 5 different formats… unify a final flow in the
//  whole app and retire old bad formats by commenting them out."*
//
//  This file is the bridge. Each `pvReadFrom…` turns one seed model into the
//  one model the reader draws, `PvRead`, at the moment the piece opens. The
//  seed data does not move — the same lists still feed hubs, search, Saved
//  and Ask Veda — and the old screens do not disappear: each one's `build`
//  now hands its model to the reader through the adapter, with its previous
//  body kept beside it for revert. So EVERY caller of the old screen — a
//  door, a home, Saved, search, a same-day-signs card — gets the one format
//  without being touched, and anything built tomorrow against those screens
//  lands in it too. `test/reader_unification_test.dart` holds that.
//
//  The rules every adapter follows, stated once:
//
//    · TITLE / TEASER / LEDE. The model's one-line summary is the teaser; its
//      opening explanation ("what it is") is the lede. Where a model has only
//      a body, the first paragraph is the lede and the rest is the body.
//    · SECTIONS carry the model's own structure as headings — "What it is",
//      "How common", "What to watch for" — so a look-up piece keeps its shape
//      and gets a contents box for free (the reader shows one past two
//      headings). Nothing is rewritten as prose.
//    · WHEN TO SEE SOMEONE is required on the model and stays so. A model
//      with a "call now" list gets an URGENT callout built from it; one with
//      a how-to-get-help field gets that; one with neither gets the shared
//      short-piece line. Never invented.
//    · BYLINE. A model with a named author and role is `reviewed` (the mark
//      stays); one without is the editorial desk, no mark.
//    · HUE is the door's own colour, so the picture frame and the foot tiles
//      match the rail the piece was opened from.
//    · LINKS become foot tiles (`nextSteps`, `readNext`), never inline
//      buttons, so the foot is the one place a piece offers the next thing.
//    · BOOKS DO NOT CONVERGE (§60.1): a book is a product, and
//      `ReadItemScreen` still routes it to the Book Companion.
// =============================================================================

import '../../localization/app_language.dart';
import '../../models/pv_read.dart';
import '../../models/read_item.dart';
import '../../models/report_finding.dart';
import '../../screens/post_pregnancy/pp_articles_data.dart';
import '../../screens/post_pregnancy/pp_reading_data.dart';
import '../belly_skin_data.dart';
import '../conditions_data.dart';
import '../mind_mood_data.dart';
import '../nutrition_data.dart';
import '../tests_scans_reports_data.dart';

LocalizedText _same(String s) => LocalizedText(en: s, hi: s);
/// Split a one-string body on blank lines.
List<LocalizedText> _paras(LocalizedText body) {
  final en = body.en.split(RegExp(r'\n\s*\n')).map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
  final hi = body.hi.split(RegExp(r'\n\s*\n')).map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
  final n = en.length > hi.length ? en.length : hi.length;
  return [
    for (var k = 0; k < n; k++)
      LocalizedText(
          en: k < en.length ? en[k] : (k < hi.length ? hi[k] : ''),
          hi: k < hi.length ? hi[k] : (k < en.length ? en[k] : '')),
  ];
}

const LocalizedText _desk = LocalizedText(en: 'ParentVeda editorial', hi: 'ParentVeda editorial');

// -----------------------------------------------------------------------------
//  Pregnancy · Mind and mood
// -----------------------------------------------------------------------------

const String kMmReadPrefix = 'mm_';

/// `withTalk` adds the quiet foot every mind-and-mood read carried — a
/// person — when the screen was given a counsellor to open (`mm_talk`).
PvRead pvReadFromMm(MmArticle a, {bool withTalk = false}) {
  final paras = _paras(a.body);
  final lede = a.whatItIs ?? (paras.isNotEmpty ? paras.first : a.teaser);
  final body = a.whatItIs == null && paras.isNotEmpty ? paras.sublist(1) : paras;
  return PvRead(
    id: '$kMmReadPrefix${a.id}',
    kicker: a.group.heading,
    title: a.title,
    teaser: a.teaser,
    scaleSetter: lede,
    author: _desk,
    authorRole: const LocalizedText(en: 'Mind and mood', hi: 'Mann aur mood'),
    reviewed: false,
    hue: 275,
    sections: [
      if (body.isNotEmpty) PvReadSection(paragraphs: body),
      if (a.signsToNotice case final s?)
        PvReadSection(
            heading: const LocalizedText(en: 'Signs to notice', hi: 'Kin baaton par dhyaan dein'),
            paragraphs: [s]),
    ],
    whenToSeeSomeone: a.howToGetHelp == null
        ? kPvShortPieceCallout
        : PvCallout(
            tone: PvCalloutTone.urgent,
            title: const LocalizedText(en: 'How to get help', hi: 'Madad kaise lein'),
            body: a.howToGetHelp!),
    faqs: const [],
    nextSteps: [
      if (a.linkLabel != null && a.linkDoor != null)
        PvReadNextStep(
          kind: PvNextKind.tool,
          title: _same(a.linkLabel!),
          value: const LocalizedText(en: '', hi: ''),
          action: 'mm_link:${a.linkDoor}:${a.linkGroup ?? ''}:${a.linkArticleId ?? ''}',
        ),
      if (withTalk)
        const PvReadNextStep(
          kind: PvNextKind.consult,
          title: LocalizedText(en: 'Talk to someone', hi: 'Kisi se baat karein'),
          value: LocalizedText(
              en: 'If this feeling needs a person.',
              hi: 'Agar is ehsaas ko insaan chahiye.'),
          action: 'mm_talk',
        ),
    ],
  );
}

// -----------------------------------------------------------------------------
//  Pregnancy · Belly and skin
// -----------------------------------------------------------------------------

const String kBsReadPrefix = 'bs_';

PvRead pvReadFromBs(BsPage page) {
  final blocks = List<BsBlock>.of(page.blocks);
  LocalizedText lede = const LocalizedText(en: '', hi: '');
  if (blocks.isNotEmpty && blocks.first.heading == null && blocks.first.paragraphs.isNotEmpty) {
    final first = blocks.first;
    lede = first.paragraphs.first;
    final rest = first.paragraphs.sublist(1);
    if (rest.isEmpty && first.bullets.isEmpty) {
      blocks.removeAt(0);
    } else {
      blocks[0] = BsBlock(heading: null, paragraphs: rest, bullets: first.bullets);
    }
  }
  return PvRead(
    id: '$kBsReadPrefix${page.id}',
    kicker: kBsAreaInfo[page.area]!.title,
    title: page.title,
    teaser: page.videoTitle,
    // The pregnancy warmth pass, 2026-09-29: every Belly & skin page carries
    // a short answer (docs/PREG-VOICE.md §3). Null renders as before.
    shortAnswer: page.shortAnswer,
    scaleSetter: lede,
    author: _desk,
    authorRole: const LocalizedText(en: 'Belly and skin', hi: 'Pet aur twacha'),
    reviewed: false,
    hue: kBsAreaInfo[page.area]!.hue,
    sections: [
      for (final b in blocks)
        PvReadSection(heading: b.heading, paragraphs: b.paragraphs, bullets: b.bullets),
      if (page.honestNote case final n?)
        PvReadSection(
            callout: PvCallout(
                tone: PvCalloutTone.note,
                title: const LocalizedText(en: 'An honest note', hi: 'Ek sacchi baat'),
                body: n)),
    ],
    whenToSeeSomeone: kPvShortPieceCallout,
    faqs: const [],
    nextSteps: [
      for (final p in page.products)
        PvReadNextStep(
          kind: PvNextKind.product,
          title: p.title,
          value: p.blurb,
          action: 'bs_product:${p.id}',
        ),
    ],
  );
}

// -----------------------------------------------------------------------------
//  Pregnancy · Conditions
// -----------------------------------------------------------------------------

const String kConditionReadPrefix = 'condition_';

/// The frame every condition page opens with, as a quiet note before the
/// film — "this helps you understand what your doctor is managing; it does
/// not replace them". It was the first thing on the classic page and stays
/// the first thing here.
const PvCallout kConditionFrame = PvCallout(
  tone: PvCalloutTone.note,
  title: LocalizedText(en: 'Before you read', hi: 'Padhne se pehle'),
  body: LocalizedText(
      en: 'This helps you understand what your doctor is managing. It does '
          'not replace them.',
      hi: 'This helps you understand what your doctor is managing. It does '
          'not replace them.'),
);

/// A condition, as a read — with the screen's own blocks slotted where the
/// classic page put them. The blocks are opaque here (see
/// `PvReadSection.custom`): the condition screen hands its film, its
/// "add to my journey" pill and its medicine / read-more feet as marker
/// objects and renders them itself. Headings are the classic page's own
/// words, so the piece reads the same and the tests that pinned them hold.
PvRead pvReadFromCondition(
  ConditionEntry c, {
  Object? watch,
  Object? journey,
  List<Object> foot = const [],
  bool offerConsult = false,
}) =>
    PvRead(
      id: '$kConditionReadPrefix${c.id}',
      kicker: c.group.title,
      title: c.name,
      teaser: c.plainLine,
      scaleSetter: c.reassurance,
      author: _desk,
      authorRole: const LocalizedText(en: 'Conditions', hi: 'Sthitiyaan'),
      reviewed: false,
      hue: 186,
      sections: [
        const PvReadSection(callout: kConditionFrame),
        if (watch != null) PvReadSection(custom: watch),
        PvReadSection(
            heading: const LocalizedText(en: 'What this is', hi: 'What this is'),
            paragraphs: [c.whatItIs]),
        if (journey != null) PvReadSection(custom: journey),
        PvReadSection(
            heading: const LocalizedText(
                en: 'How common this is in India', hi: 'How common this is in India'),
            paragraphs: [c.howCommon]),
        if (c.symptoms.isNotEmpty)
          PvReadSection(
              heading: const LocalizedText(
                  en: 'What you might notice', hi: 'What you might notice'),
              bullets: c.symptoms),
        if (c.justMonitor.isNotEmpty)
          PvReadSection(
              heading: const LocalizedText(
                  en: 'Just keep an eye on', hi: 'Just keep an eye on'),
              bullets: c.justMonitor),
        if (c.testsToConfirm.isNotEmpty)
          PvReadSection(
              heading: const LocalizedText(
                  en: 'Which tests confirm it', hi: 'Which tests confirm it'),
              bullets: c.testsToConfirm),
        PvReadSection(
            heading: const LocalizedText(
                en: 'How it is managed in India', hi: 'How it is managed in India'),
            paragraphs: [c.management]),
        PvReadSection(
            heading: const LocalizedText(
                en: 'What it means for your baby', hi: 'What it means for your baby'),
            paragraphs: [c.babyImpact]),
        for (final f in foot) PvReadSection(custom: f),
      ],
      whenToSeeSomeone: c.callNow.isEmpty
          ? kPvShortPieceCallout
          : PvCallout(
              tone: PvCalloutTone.urgent,
              title: const LocalizedText(en: 'Call now if', hi: 'Call now if'),
              body: LocalizedText(
                  en: '• ${c.callNow.map((x) => x.en).join('\n• ')}',
                  hi: '• ${c.callNow.map((x) => x.hi).join('\n• ')}')),
      faqs: [for (final f in c.faqs) PvReadFaq(question: f.question, answer: f.answer)],
      // The offer that belongs where the need is felt — after she has read
      // what it is, what it means for her baby and eight FAQs about people in
      // general. Never on a high-anxiety page (the screen decides).
      nextSteps: [
        if (offerConsult)
          const PvReadNextStep(
            kind: PvNextKind.consult,
            title: LocalizedText(
                en: 'Ask a gynaecologist about your own case',
                hi: 'Ask a gynaecologist about your own case'),
            value: LocalizedText(
                en: 'This page explains the condition. They can tell you what it means for you.',
                hi: 'This page explains the condition. They can tell you what it means for you.'),
            action: 'condition_consult',
          ),
      ],
    );

// -----------------------------------------------------------------------------
//  Pregnancy · Scans and tests
// -----------------------------------------------------------------------------

const String kScanReadPrefix = 'scan_';

/// The parameters of one scan's report, as a block the reader hands back to
/// the scans stage to draw (`PvReaderScreen.customBlock`). Data only — the
/// widget is `ScanParametersView` in `scan_detail_screen.dart`.
class PvScanParametersBlock {
  const PvScanParametersBlock(this.parameters);
  final List<ReportParameter> parameters;
}

/// A scan, as a read — the classic page's four questions as sections, its
/// "call your gynaecologist if" list as the urgent line, and the screen's
/// own foot (her booked appointment, the line-by-line report, the decoder,
/// the consult, Ask Veda) as next-step tiles the screen supplies and opens.
/// The report's parameters ARE here since 2026-09-18 — "What the report
/// will say" as a data card (`PvScanParametersBlock`, drawn by the scans
/// stage through `customBlock`) and "How to read the result" from the
/// scan's own interpretation. The separate "Your report, line by line"
/// tool that used to hold them is retired from the door: one home per fact.
PvRead pvReadFromScan(
  TestScanInfo s, {
  List<LocalizedText> redFlags = const [],
  List<PvReadNextStep> steps = const [],
}) =>
    PvRead(
      id: '$kScanReadPrefix${s.id}',
      kicker: const LocalizedText(en: 'Scans and tests', hi: 'Scan aur test'),
      title: s.name,
      teaser: s.altName ?? s.when,
      // Pregnancy warmth pass, 2026-09-29 (docs/PREG-VOICE.md §3).
      shortAnswer: s.shortAnswer,
      scaleSetter: s.whatItIs,
      author: _desk,
      authorRole: const LocalizedText(en: 'Scans and tests', hi: 'Scan aur test'),
      reviewed: false,
      hue: 206,
      sections: [
        PvReadSection(
            heading: const LocalizedText(en: 'What is it checking?', hi: 'यह क्या जाँचता है?'),
            paragraphs: [s.why]),
        PvReadSection(
            heading: const LocalizedText(en: 'When is it done?', hi: 'कब होता है?'),
            paragraphs: [s.when]),
        PvReadSection(
            heading: const LocalizedText(en: 'What happens during it?', hi: 'इसमें होता क्या है?'),
            paragraphs: [s.procedure]),
        PvReadSection(
            heading: const LocalizedText(en: 'How should I prepare?', hi: 'तैयारी कैसे करूँ?'),
            paragraphs: [s.preparation]),
        if (s.parameters.isNotEmpty)
          PvReadSection(
              heading: const LocalizedText(
                  en: 'What the report will say', hi: 'Report mein kya likha hoga'),
              paragraphs: [if (s.understandingReport.en.isNotEmpty) s.understandingReport],
              custom: PvScanParametersBlock(s.parameters)),
        if (s.interpretation.en.isNotEmpty)
          PvReadSection(
              heading: const LocalizedText(
                  en: 'How to read the result', hi: 'Nateeja kaise padhein'),
              paragraphs: [s.interpretation],
              bullets: s.interpretPointers),
      ],
      whenToSeeSomeone: redFlags.isEmpty
          ? const PvCallout(
              tone: PvCalloutTone.urgent,
              title: LocalizedText(en: 'Your report is read by your doctor', hi: 'Report aapka doctor padhega'),
              body: LocalizedText(
                  en: 'Nothing here replaces the person who ordered the scan. If a '
                      'value is flagged, or you are unsure what a line means, take '
                      'the report to them — they know your case and this page does not.',
                  hi: 'Yahan kuch bhi us doctor ki jagah nahi leta jisne scan likha. '
                      'Agar koi value flag hai ya koi line samajh na aaye, report unhe '
                      'dikhayein — wo aapka case jaante hain, ye page nahi.'),
            )
          : PvCallout(
              tone: PvCalloutTone.urgent,
              title: const LocalizedText(
                  en: 'Call your gynaecologist if', hi: 'अपनी gynaecologist को फ़ोन कीजिए अगर'),
              body: LocalizedText(
                  en: 'Most pregnancies never need this list. It is here so you '
                      'know what is worth a phone call rather than a wait — asking '
                      'is always alright.\n\n• ${redFlags.map((f) => f.en).join('\n• ')}',
                  hi: 'ज़्यादातर pregnancy में इस सूची की ज़रूरत ही नहीं पड़ती। यह इसलिए '
                      'है ताकि आपको पता हो कि किस बात पर इंतज़ार नहीं, फ़ोन करना बेहतर '
                      'है — पूछना हमेशा ठीक है।\n\n• ${redFlags.map((f) => f.hi).join('\n• ')}'),
            ),
      faqs: const [],
      nextSteps: steps,
    );

// -----------------------------------------------------------------------------
//  Pregnancy · Report findings
// -----------------------------------------------------------------------------

const String kFindingReadPrefix = 'finding_';

/// `steps` — the screen's own foot (Ask Veda, pre-filled with the finding).
PvRead pvReadFromFinding(ReportFinding f, {List<PvReadNextStep> steps = const []}) => PvRead(
      id: '$kFindingReadPrefix${f.id}',
      kicker: const LocalizedText(en: 'On your report', hi: 'Aapki report mein'),
      title: f.name,
      teaser: f.altName ?? f.howCommon,
      scaleSetter: f.whatItMeans,
      author: _desk,
      authorRole: const LocalizedText(en: 'Report findings', hi: 'Report ki baatein'),
      reviewed: false,
      hue: 206,
      sections: [
        PvReadSection(
            heading: const LocalizedText(en: 'How common', hi: 'Kitna aam'),
            paragraphs: [f.howCommon]),
        PvReadSection(
            heading: const LocalizedText(en: 'What happens next', hi: 'Aage kya'),
            paragraphs: [f.whatNext]),
        if (f.questions.isNotEmpty)
          PvReadSection(
              heading: const LocalizedText(en: 'Questions to ask', hi: 'Kya poochhein'),
              bullets: f.questions),
        if (f.remember.isNotEmpty)
          PvReadSection(
              heading: const LocalizedText(en: 'Worth remembering', hi: 'Yaad rakhne layak'),
              bullets: f.remember),
      ],
      whenToSeeSomeone: const PvCallout(
        tone: PvCalloutTone.urgent,
        title: LocalizedText(en: 'Take this to the doctor who ordered it', hi: 'Jisne likha, unhe dikhayein'),
        body: LocalizedText(
            en: 'A finding on a report is read with your history, your other '
                'results and your scan — none of which this page has. The next '
                'step is theirs to name.',
            hi: 'Report ki baat aapki history, baaki nateeje aur scan ke saath '
                'padhi jaati hai — jo is page ke paas nahi. Agla kadam unka hai.'),
      ),
      faqs: const [],
      nextSteps: steps,
    );

// -----------------------------------------------------------------------------
//  Pregnancy · Nutrients
// -----------------------------------------------------------------------------

const String kNutrientReadPrefix = 'nutrient_';

PvRead pvReadFromNutrient(NutrientGuide g) => PvRead(
      id: '$kNutrientReadPrefix${g.id}',
      kicker: const LocalizedText(en: 'Nutrition', hi: 'Poshan'),
      title: g.name,
      teaser: g.whatItDoes,
      scaleSetter: g.supplementNote,
      author: _desk,
      authorRole: const LocalizedText(en: 'Nutrition', hi: 'Poshan'),
      reviewed: false,
      hue: 150,
      sections: [
        PvReadSection(
            heading: const LocalizedText(en: 'Where to find it', hi: 'Kahan milta hai'),
            bullets: g.foods),
      ],
      whenToSeeSomeone: kPvShortPieceCallout,
      faqs: const [],
    );

// -----------------------------------------------------------------------------
//  Pregnancy · The weekly reads (ReadItem) — articles, research, expert notes
// -----------------------------------------------------------------------------

const String kReadItemPrefix = 'readitem_';

/// Books do not converge — see the file head. The caller keeps routing
/// `ReadType.book` to the Book Companion and never calls this for one.
/// `foot` — the screen's own control at the end of the piece (mark as read,
/// which also ticks the home's daily-reads box through `ReadDoneStore`).
PvRead pvReadFromReadItem(ReadItem r, {Object? foot}) {
  assert(r.type != ReadType.book, 'a book is a product, not an article');
  final paras = _paras(r.body);
  final lede = paras.isNotEmpty ? paras.first : r.reason;
  final body = paras.length > 1 ? paras.sublist(1) : const <LocalizedText>[];
  final named = r.author.trim().isNotEmpty;
  return PvRead(
    id: '$kReadItemPrefix${r.id}',
    kicker: r.category,
    title: r.title,
    teaser: r.reason,
    scaleSetter: lede,
    author: named ? _same(r.author) : _desk,
    authorRole: r.authorRole.en.trim().isEmpty ? r.category : r.authorRole,
    reviewed: named && r.authorRole.en.trim().isNotEmpty,
    hue: switch (r.type) {
      ReadType.research => 206,
      ReadType.expert => 186,
      ReadType.reflection => 42,
      _ => 344,
    },
    sections: [
      if (body.isNotEmpty) PvReadSection(paragraphs: body),
      if (r.why.en.trim().isNotEmpty)
        PvReadSection(
            callout: PvCallout(
                tone: PvCalloutTone.note,
                title: const LocalizedText(en: 'Why ParentVeda picked this', hi: 'ParentVeda ne ye kyun chuna'),
                body: r.why)),
      if (foot != null) PvReadSection(custom: foot),
    ],
    whenToSeeSomeone: kPvShortPieceCallout,
    faqs: const [],
  );
}

// -----------------------------------------------------------------------------
//  Parenting · The library (ReadArticle)
// -----------------------------------------------------------------------------

const String kReadArticlePrefix = 'readarticle_';

/// `video` — the one film embedded mid-piece (the classic reader dropped it
/// at the arithmetic middle; it still does, as a custom block). `related` —
/// the films at the end. `complete` — the mark-as-read control. All rendered
/// by the screen; the adapter only places them. Read next is the library's
/// own `readNextArticles`, so the rail keeps the same picks.
PvRead pvReadFromReadArticle(
  ReadArticle a, {
  Object? video,
  Object? related,
  Object? complete,
}) {
  final sections = List<ReadSection>.of(a.sections);
  var lede = a.whyToday;
  if (sections.isNotEmpty && sections.first.heading == null && sections.first.paragraphs.isNotEmpty) {
    final first = sections.first;
    lede = first.paragraphs.first;
    final rest = first.paragraphs.sublist(1);
    if (rest.isEmpty && first.tip == null && first.mythFact == null) {
      sections.removeAt(0);
    } else {
      sections[0] = ReadSection(paragraphs: rest, tip: first.tip, mythFact: first.mythFact);
    }
  }
  return PvRead(
    id: '$kReadArticlePrefix${a.id}',
    kicker: _same(a.collection),
    title: _same(a.title),
    teaser: _same(a.teaser),
    scaleSetter: _same(lede),
    author: _same(a.author),
    authorRole: _same(a.authorRole),
    reviewed: a.authorRole.trim().isNotEmpty,
    hue: 268,
    sections: [
      for (var i = 0; i < sections.length; i++) ...[
        PvReadSection(
          heading: sections[i].heading == null ? null : _same(sections[i].heading!),
          paragraphs: [for (final p in sections[i].paragraphs) _same(p)],
          tip: sections[i].tip == null
              ? null
              : PvReadTip(title: _same(sections[i].tip!.title), body: _same(sections[i].tip!.body)),
          mythFact: sections[i].mythFact == null
              ? null
              : PvMythFact(
                  myth: _same(sections[i].mythFact!.myth), fact: _same(sections[i].mythFact!.fact)),
        ),
        if (video != null && i == (sections.length - 1) ~/ 2) PvReadSection(custom: video),
      ],
      if (video != null && sections.isEmpty) PvReadSection(custom: video),
      if (related != null) PvReadSection(custom: related),
      if (complete != null) PvReadSection(custom: complete),
    ],
    whenToSeeSomeone: kPvShortPieceCallout,
    faqs: const [],
    evidence: a.evidence == null ? null : _same(a.evidence!),
    readNext: [for (final n in readNextArticles(a)) '$kReadArticlePrefix${n.id}'],
    // `relatedActivity` stays on the seed; the old reader never rendered it.
  );
}

/// The read behind a library id (`readarticle_<id>`), for the rail.
PvRead? readArticleReadById(String id) {
  final key = id.startsWith(kReadArticlePrefix) ? id.substring(kReadArticlePrefix.length) : id;
  for (final a in kReadArticles) {
    if (a.id == key) return pvReadFromReadArticle(a);
  }
  return null;
}

// -----------------------------------------------------------------------------
//  Parenting · The archive (Article) — a title, a byline and a piece on its way
// -----------------------------------------------------------------------------

const String kPpArticlePrefix = 'pparticle_';

/// The archive's `Article` carries no body of its own; the old screen drew a
/// designed body for ONE id and a "being written" card for the rest. The
/// adapter keeps both honestly: the designed piece as sections, and the rest
/// as a one-line note that the piece is on its way — the words the old screen
/// used, kept (don't remove aspirational copy; record the gap).
PvRead pvReadFromArticle(Article a) {
  final full = a.id == 'sleepcycles';
  return PvRead(
    id: '$kPpArticlePrefix${a.id}',
    kicker: _same(a.category),
    title: _same(a.title),
    teaser: _same(full
        ? 'Something real has changed inside their brain — and it is on schedule.'
        : 'A ParentVeda-reviewed read on ${a.category.toLowerCase()} for the ${a.age} stage.'),
    scaleSetter: _same(full
        ? "If your baby was a champion sleeper and has suddenly started waking every couple of hours - you're not doing anything wrong. Something real has changed inside their brain."
        : 'The full article is being written - it lands soon, reviewed by our medical panel.'),
    author: _same(a.author),
    authorRole: _same(a.authorRole),
    reviewed: a.authorRole.trim().isNotEmpty,
    hue: 268,
    sections: full
        ? [
            PvReadSection(paragraphs: [
              _same("Around the four-month mark, a baby's sleep matures from the simple newborn pattern into a more adult-like structure. Instead of drifting between just two states, they now move through several distinct cycles a night - and between each one, there's a brief moment of near-waking."),
            ]),
            PvReadSection(heading: _same("What's actually happening"), paragraphs: [
              _same("A newborn falls straight into deep sleep. A four-month-old, like an adult, cycles through lighter and deeper stages roughly every 45 minutes. At the end of each cycle they surface - and if they don't yet know how to resettle on their own, they wake fully and call for you."),
            ], callout: PvCallout(
              tone: PvCalloutTone.reassure,
              title: _same('Worth remembering'),
              body: _same("This isn't a step backwards. It's a sign your baby's brain is developing exactly on schedule."),
            )),
            PvReadSection(heading: _same('What helps'), paragraphs: [
              _same("The goal isn't to force sleep - it's to give your baby the chance to practise resettling:"),
            ], bullets: [
              _same('A short, identical wind-down every night.'),
              _same('Putting down drowsy but awake, so they learn the last step themselves.'),
              _same('A calm, dark, consistent room between cycles.'),
            ]),
            PvReadSection(paragraphs: [
              _same('Most of all - hold your routine and be patient. This phase settles within two to six weeks, and your baby comes out the other side a more capable sleeper.'),
            ]),
          ]
        : const [],
    whenToSeeSomeone: kPvShortPieceCallout,
    faqs: const [],
  );
}
