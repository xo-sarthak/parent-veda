// =============================================================================
//  Belly & Skin — content + commerce data
// -----------------------------------------------------------------------------
//  Five areas (stretch marks, pigmentation, itching, safe skincare, belly
//  care) plus the Ingredient Safety Checker. Two things this data model exists
//  to protect:
//
//  1. HONESTY. Stretch marks are largely genetic and not always fully
//     preventable — the copy says so plainly rather than overselling a cream.
//     That honesty is the section's differentiator, not a caveat bolted on.
//
//  2. THE SAFETY CORE. Itching can be harmless or it can signal cholestasis
//     (ICP). `kBsItchingWarning` is the one string in this file that must
//     never be softened or buried — see bs_itching_screen.dart, which renders
//     it above everything else and carries no commerce at all.
//
//  Editable data, not layout: adding an ingredient or a page is adding an
//  entry below, never touching a screen file. Follows the comment/code style
//  of lib/data/journeys/pregnancy_journeys.dart.
//
//  ⚠️ ENGLISH ONLY FOR NOW — see `_en` below. `.en == .hi` here is a
//  deliberate, greppable statement that Hindi is owed for this whole section,
//  not a finished bilingual pair.
//  ⚠️ NO EM DASHES IN CONTENT STRINGS.
// =============================================================================

import '../localization/app_language.dart';

LocalizedText _en(String s) => LocalizedText(en: s, hi: s);

// =============================================================================
//  Areas
// =============================================================================

// `bodyChanges` added 2026-09-29 (pregnancy gap analysis, Belly & skin, P3:
// hair, nails, gums and teeth, and her changing shape in one place).
enum BsArea {
  stretchMarks,
  pigmentation,
  itching,
  safeSkincare,
  bellyCare,
  bodyChanges,
}

class BsAreaInfo {
  const BsAreaInfo({
    required this.title,
    required this.blurb,
    required this.hue,
  });
  final LocalizedText title;
  final LocalizedText blurb;

  /// Hue for this area's tile, on the app's controlled wheel (v2BlockTint).
  final double hue;
}

const Map<BsArea, BsAreaInfo> kBsAreaInfo = {
  BsArea.stretchMarks: BsAreaInfo(
    title: LocalizedText(en: 'Stretch marks', hi: 'Stretch marks'),
    blurb: LocalizedText(
        en: 'Why they happen, what helps, and what to expect',
        hi: 'Why they happen, what helps, and what to expect'),
    hue: 344,
  ),
  BsArea.pigmentation: BsAreaInfo(
    title: LocalizedText(en: 'Pigmentation and skin changes',
        hi: 'Pigmentation and skin changes'),
    blurb: LocalizedText(
        en: 'The dark line, the glow, the patches. Most of it fades after birth',
        hi: 'The dark line, the glow, the patches. Most of it fades after birth'),
    hue: 26,
  ),
  BsArea.itching: BsAreaInfo(
    title: LocalizedText(en: 'Itching', hi: 'Itching'),
    blurb: LocalizedText(
        en: "What's normal, and the one warning sign to know",
        hi: "What's normal, and the one warning sign to know"),
    hue: 12,
  ),
  BsArea.safeSkincare: BsAreaInfo(
    title: LocalizedText(en: 'Safe skincare', hi: 'Safe skincare'),
    blurb: LocalizedText(
        en: "What to avoid, what's fine, and a simple daily routine",
        hi: "What to avoid, what's fine, and a simple daily routine"),
    hue: 160,
  ),
  BsArea.bellyCare: BsAreaInfo(
    title: LocalizedText(en: 'Belly care', hi: 'Belly care'),
    blurb: LocalizedText(
        en: 'Oiling, support and comfort for your growing bump',
        hi: 'Oiling, support and comfort for your growing bump'),
    hue: 42,
  ),
  BsArea.bodyChanges: BsAreaInfo(
    title: LocalizedText(
        en: 'Hair, nails and body changes', hi: 'Hair, nails and body changes'),
    blurb: LocalizedText(
        en: 'Hair, nails, gums and your changing shape. Almost all of it settles',
        hi: 'Hair, nails, gums and your changing shape. Almost all of it settles'),
    hue: 300,
  ),
};

// =============================================================================
//  Products — surfaced contextually, never their own tile
// =============================================================================

class BsProduct {
  const BsProduct({
    required this.id,
    required this.title,
    required this.blurb,
    required this.ctaLabel,
    required this.hue,
    this.ownSku = false,
  });
  final String id;
  final LocalizedText title;

  /// One honest line — "what can help", never "the cure".
  final LocalizedText blurb;
  final LocalizedText ctaLabel;
  final double hue;

  /// true = ParentVeda's own SKU. false = an outside brand, shown as an
  /// affiliate surface (e.g. the belly band).
  final bool ownSku;
}

const bsBellyOil = BsProduct(
  id: 'belly_oil',
  title: LocalizedText(en: 'ParentVeda Belly Oil', hi: 'ParentVeda Belly Oil'),
  blurb: LocalizedText(
      en: "A simple oil blend for your daily massage. It keeps skin "
          "comfortable, but it won't erase marks already forming underneath.",
      hi: "A simple oil blend for your daily massage. It keeps skin "
          "comfortable, but it won't erase marks already forming underneath."),
  ctaLabel: LocalizedText(en: 'See the oil', hi: 'See the oil'),
  hue: 344,
  ownSku: true,
);

const bsStretchMarkCream = BsProduct(
  id: 'stretch_mark_cream',
  title: LocalizedText(
      en: 'ParentVeda Stretch Mark Cream', hi: 'ParentVeda Stretch Mark Cream'),
  blurb: LocalizedText(
      en: 'A richer, pregnancy-safe cream for skin that already feels tight '
          'or itchy. Comfort now, and a head start on fading later.',
      hi: 'A richer, pregnancy-safe cream for skin that already feels tight '
          'or itchy. Comfort now, and a head start on fading later.'),
  ctaLabel: LocalizedText(en: 'See the cream', hi: 'See the cream'),
  hue: 344,
  ownSku: true,
);

const bsMineralSunscreen = BsProduct(
  id: 'mineral_sunscreen',
  title: LocalizedText(
      en: 'A pregnancy-safe mineral sunscreen', hi: 'A pregnancy-safe mineral sunscreen'),
  blurb: LocalizedText(
      en: 'Zinc oxide or titanium dioxide, SPF 30 or higher. The one change '
          'shown to reduce dark patches.',
      hi: 'Zinc oxide or titanium dioxide, SPF 30 or higher. The one change '
          'shown to reduce dark patches.'),
  ctaLabel: LocalizedText(en: 'See sunscreen options', hi: 'See sunscreen options'),
  hue: 26,
  ownSku: false,
);

const bsBellyBand = BsProduct(
  id: 'belly_band',
  title: LocalizedText(en: 'A maternity belly band', hi: 'A maternity belly band'),
  blurb: LocalizedText(
      en: 'Extra support for your lower back and bump on long days. Not '
          'medical, and not everyone needs one.',
      hi: 'Extra support for your lower back and bump on long days. Not '
          'medical, and not everyone needs one.'),
  ctaLabel: LocalizedText(en: 'See band options', hi: 'See band options'),
  hue: 42,
  ownSku: false,
);

// =============================================================================
//  Article pages — Areas 1, 2, 4, 5 (Area 3 / itching has its own screen)
// =============================================================================

class BsBlock {
  const BsBlock({
    this.heading,
    this.paragraphs = const [],
    this.bullets = const [],
  });
  final LocalizedText? heading;
  final List<LocalizedText> paragraphs;
  final List<LocalizedText> bullets;
}

class BsPage {
  const BsPage({
    required this.id,
    required this.area,
    required this.title,
    required this.videoTitle,
    this.videoSubtitle,
    this.videoDuration,
    required this.blocks,
    this.products = const [],
    this.honestNote,
    this.shortAnswer,
  });
  final String id;
  final BsArea area;
  final LocalizedText title;

  /// PvVideoPlaceholder is mandatory on every content page — see
  /// lib/widgets/pv_placeholders.dart. These three feed it directly.
  final LocalizedText videoTitle;
  final LocalizedText? videoSubtitle;
  final LocalizedText? videoDuration;
  final List<BsBlock> blocks;

  /// Shown at the FOOT of the page, framed as "what can help". Empty on
  /// pages where a product would not be the honest answer.
  final List<BsProduct> products;

  /// An optional highlighted callout — used for the honesty beat ("this is
  /// largely genetic") so it cannot be skimmed past as just another line.
  final LocalizedText? honestNote;

  /// "The short answer": two or three plain sentences under the title, in the
  /// reader's `PvRead.shortAnswer` box. Added 2026-09-29 from the pregnancy
  /// gap analysis ("Behind · How reads are written": the answer in ten
  /// seconds, the detail if she wants it).
  final LocalizedText? shortAnswer;
}

List<BsPage> bsPagesForArea(BsArea a) =>
    kBsPages.where((p) => p.area == a).toList(growable: false);

BsPage? bsPageById(String id) {
  for (final p in kBsPages) {
    if (p.id == id) return p;
  }
  return null;
}

final List<BsPage> kBsPages = [
  // ---------------------------------------------------------------------
  //  Area 1 — Stretch marks
  //
  //  ⚠️ REWRITTEN 2026-09-29 TO docs/PREG-VOICE.md (the pregnancy warmth
  //  pass, from the pregnancy gap analysis). Same facts, warmer words, a
  //  short answer on every page and headings asked as her questions. The
  //  previous English is in git history (commit before this pass).
  // ---------------------------------------------------------------------
  BsPage(
    id: 'sm_why',
    area: BsArea.stretchMarks,
    title: _en('Why stretch marks happen'),
    shortAnswer: _en("Stretch marks happen when your skin stretches faster "
        "than its deeper layer can keep up. How many you get depends mostly "
        "on your genes and skin type, not on anything you did or didn't do."),
    videoTitle: _en("What's happening under your skin, in plain words"),
    videoSubtitle: _en("What's happening under the surface, and why it isn't "
        "your fault"),
    videoDuration: _en('4 MIN'),
    honestNote: _en("Stretch marks are largely genetic. If your mother or "
        "sister has them, you're more likely to get them too, and no cream "
        "can change that. It's nothing you did."),
    blocks: [
      BsBlock(paragraphs: [
        _en("There's a layer under your skin, the dermis, that stretches as "
            "your bump grows. When it stretches faster than it can keep up, "
            "its fibres tear in tiny lines. Those lines are stretch marks."),
        _en("How much you mark depends mostly on your skin type, your genes, "
            "and how much and how fast your bump grows. It isn't about "
            "effort. Two women with exactly the same routine can end up "
            "looking very different, and neither of them did anything wrong."),
      ]),
      BsBlock(heading: _en('What makes them more likely?'), bullets: [
        _en('Your mother or sister had them'),
        _en('Skin that is naturally drier or less stretchy'),
        _en('Putting on weight quickly, or carrying twins'),
        _en("A first pregnancy, when your skin hasn't stretched this way "
            "before"),
      ]),
    ],
  ),
  BsPage(
    id: 'sm_what_helps',
    area: BsArea.stretchMarks,
    title: _en("What helps, and what doesn't"),
    shortAnswer: _en("Moisturising every day and a gentle massage keep your "
        "skin comfortable. No cream can fully stop marks if your skin is "
        "prone to them, and most marks fade a lot in the year after birth."),
    videoTitle: _en('What the evidence says, without the marketing'),
    videoSubtitle: _en("Where the evidence is real, and where it's a guess"),
    videoDuration: _en('5 MIN'),
    blocks: [
      BsBlock(heading: _en('What helps?'), bullets: [
        _en('Moisturising your skin every day, right through your pregnancy'),
        _en('A gentle massage, which feels good and helps circulation'),
        _en('Putting on weight gradually, at a pace your doctor is happy '
            'with'),
        _en('Time. Most marks fade from deep red or purple to a soft silver '
            'in the first year after birth'),
      ]),
      BsBlock(heading: _en("What doesn't help on its own?"), bullets: [
        _en("No cream can fully prevent marks if your skin is prone to them"),
        _en("Expensive doesn't mean better. A budget oil and a premium one "
            "usually have the same active ingredients"),
        _en("A product can't undo a mark that has already formed. It can "
            "only care for the skin around it"),
      ]),
      BsBlock(paragraphs: [
        _en("So the real goal is comfort, not a promise. That still matters. "
            "Comfortable skin itches less, and a small daily habit is "
            "something you can keep up for nine months."),
      ]),
    ],
  ),
  BsPage(
    id: 'sm_oils_creams',
    area: BsArea.stretchMarks,
    title: _en('Oils and creams that help'),
    shortAnswer: _en("Any simple oil or cream works, used a little every day "
        "from the second trimester. Cover every place your skin is "
        "stretching, and let the massage be the part you enjoy."),
    videoTitle: _en('A daily routine that takes two minutes'),
    videoSubtitle: _en('Where to apply, and how much'),
    videoDuration: _en('3 MIN'),
    blocks: [
      BsBlock(heading: _en('How do I use them?'), bullets: [
        _en('Apply once or twice a day from the second trimester, when your '
            'bump grows fastest'),
        _en('Cover your belly, hips, thighs and chest, wherever your skin is '
            'stretching, not just the bump'),
        _en("Warm a little between your palms first. It soaks in better, and "
            "the massage itself is the useful part"),
        _en('A little every day does more than a lot once a week'),
      ]),
      BsBlock(paragraphs: [
        _en('Look for simple ingredients: cocoa or shea butter, coconut or '
            'almond oil, vitamin E. None of them is magic, and all of them do '
            'the real job well, which is keeping your skin soft.'),
      ]),
    ],
    products: [bsBellyOil, bsStretchMarkCream],
  ),
  BsPage(
    id: 'sm_after_delivery',
    area: BsArea.stretchMarks,
    title: _en('How stretch marks fade after birth'),
    shortAnswer: _en("Most stretch marks fade on their own. Over 6 to 12 "
        "months after birth they usually turn from red or dark to a lighter, "
        "silvery line that's much harder to see."),
    videoTitle: _en('What changes after birth'),
    videoSubtitle: _en('A realistic timeline for fading'),
    videoDuration: _en('4 MIN'),
    blocks: [
      BsBlock(paragraphs: [
        _en("At first, marks can look red, purple or dark brown, depending on "
            "your skin tone, because the fibres underneath are still "
            "inflamed. Over 6 to 12 months they usually settle into a "
            "lighter, silvery line that's far less noticeable."),
      ]),
      BsBlock(heading: _en('What helps them fade?'), bullets: [
        _en('Keeping up the same moisturising routine after birth'),
        _en('Gentle massage, which can soften the texture even after marks '
            'have formed'),
        _en('Time. Most of the change happens on its own, in the first year'),
        _en("If marks still bother you long after birth, a skin doctor "
            "(dermatologist) can talk you through options like microneedling "
            "or laser. These go beyond what a cream can do"),
      ]),
    ],
    products: [bsStretchMarkCream],
  ),

  // ---------------------------------------------------------------------
  //  Area 2 — Pigmentation and skin changes
  // ---------------------------------------------------------------------
  BsPage(
    id: 'pg_linea_nigra',
    area: BsArea.pigmentation,
    // ⚠️ RETITLED PLAIN-FIRST, AND IT IS THE ONLY CONTENT CHANGE THIS DOOR
    // MAKES. The locked rule across the pregnancy briefs is that a medical name
    // may lead a page title only where it is the word on her report; "linea
    // nigra" is not — it is the word an article taught her. So the plain phrase
    // leads and the name follows in brackets. The page body is untouched.
    title: _en('The dark line (linea nigra)'),
    shortAnswer: _en("A dark line down the middle of your belly is normal in "
        "pregnancy. Hormones cause it, and it almost always fades by itself "
        "a few months after birth."),
    videoTitle: _en('Why a line appears down your belly'),
    videoSubtitle: _en('A normal pigment line that fades after birth'),
    videoDuration: _en('2 MIN'),
    blocks: [
      BsBlock(paragraphs: [
        _en("Pregnancy hormones make your skin produce more pigment "
            "(melanin), so a line from your belly button downwards often gets "
            "darker. It's completely normal. Most pregnant women get it to "
            "some degree, and it shows more on deeper skin tones."),
        _en("It almost always fades on its own within a few months after "
            "birth. You don't need to treat it."),
      ]),
    ],
  ),
  BsPage(
    id: 'pg_melasma',
    area: BsArea.pigmentation,
    // ⚠️ RETITLED PLAIN-FIRST. See the note on `pg_linea_nigra`.
    title: _en('The pregnancy mask (melasma)'),
    shortAnswer: _en("Brownish patches on your face are common in pregnancy "
        "and usually fade within a year of birth. Daily sunscreen helps most, "
        "because sunlight is what makes them darker."),
    videoTitle: _en('Why patches appear on your face'),
    videoSubtitle: _en('Why sunscreen matters most here'),
    videoDuration: _en('4 MIN'),
    honestNote: _en("Sunscreen is the one step that's shown to reduce these "
        "patches. Sunlight is what makes them darker and slower to fade."),
    blocks: [
      BsBlock(paragraphs: [
        _en('Brownish patches can appear on your cheeks, forehead, nose or '
            'upper lip. People call it the "mask of pregnancy". Hormones '
            'start it and sunlight darkens it, which is why it often looks '
            'worse in summer.'),
      ]),
      BsBlock(heading: _en('What helps?'), bullets: [
        _en('A mineral sunscreen, put on again through the day, even indoors '
            'near a window'),
        _en("A wide-brimmed hat or your dupatta when you're out in strong "
            "sun"),
        _en('Patience. Most patches fade a lot within a year of birth, once '
            'your hormones settle'),
      ]),
    ],
    products: [bsMineralSunscreen],
  ),
  BsPage(
    id: 'pg_dark_areas',
    area: BsArea.pigmentation,
    title: _en('Darker underarms, neck and inner thighs'),
    shortAnswer: _en("Darker skin in your underarms, neck and inner thighs is "
        "a normal pregnancy change. It has nothing to do with how clean you "
        "are, and it fades slowly after birth."),
    videoTitle: _en('Why some areas darken more than others'),
    videoSubtitle: _en('The same hormone change, showing up in skin folds'),
    videoDuration: _en('3 MIN'),
    blocks: [
      BsBlock(paragraphs: [
        _en("Places where skin rubs against skin, like your underarms, neck "
            "and inner thighs, often get darker in pregnancy. It's the same "
            "hormone change that darkens the line on your belly, just showing "
            "up somewhere else."),
        _en("It isn't a hygiene problem, so please don't scrub at it. Wash "
            "gently and wear loose, soft cotton to cut down rubbing, which is "
            "the only thing making it worse day to day. It fades slowly after "
            "birth."),
      ]),
    ],
  ),
  BsPage(
    id: 'pg_acne',
    area: BsArea.pigmentation,
    title: _en('Pregnancy acne'),
    shortAnswer: _en("Pregnancy hormones can bring back spots, most often in "
        "the first and second trimester. A gentle face wash and niacinamide "
        "are safe. Some strong acne creams are best skipped for now."),
    videoTitle: _en('Why spots can come back now'),
    videoSubtitle: _en("What's safe to use while it settles"),
    videoDuration: _en('3 MIN'),
    blocks: [
      BsBlock(paragraphs: [
        _en('A hormone called progesterone rises in pregnancy and makes your '
            'skin oilier. So acne you grew out of years ago can come back, '
            'most often in the first and second trimester.'),
      ]),
      BsBlock(heading: _en('What can I use?'), bullets: [
        _en('A gentle, fragrance-free face wash, twice a day'),
        _en('Niacinamide, a pregnancy-safe ingredient that calms spots '
            'without drying your skin'),
        _en('Check Safe skincare for what to avoid, because the usual strong '
            'acne creams are the ones to skip for now'),
      ]),
    ],
  ),
  BsPage(
    id: 'pg_glow',
    area: BsArea.pigmentation,
    title: _en('The pregnancy glow'),
    shortAnswer: _en("The glow is real. More blood reaches your skin in "
        "pregnancy and your skin makes more oil, which gives it a fresh, "
        "dewy look. If you don't have it, that's normal too."),
    videoTitle: _en('The real reason for the glow'),
    videoSubtitle: _en("There's a real reason behind it"),
    videoDuration: _en('2 MIN'),
    blocks: [
      BsBlock(paragraphs: [
        _en("There's a real reason for it. Your blood volume goes up by as "
            "much as 50% in pregnancy, so more blood reaches the surface of "
            "your skin. Your oil glands work harder too, which gives skin a "
            "dewy look."),
        _en("Not everyone glows in the same way, and that's fine. The same "
            "hormones can bring a glow to one woman and spots to another."),
      ]),
    ],
  ),
  BsPage(
    id: 'pg_dry_sensitive',
    area: BsArea.pigmentation,
    title: _en('Dry or sensitive skin'),
    shortAnswer: _en("Your skin can become drier or more sensitive in "
        "pregnancy, so products you've used for years may suddenly sting. "
        "Gentle, fragrance-free products usually help."),
    videoTitle: _en('Why your skin reacts differently now'),
    videoSubtitle: _en('A gentler routine for skin that has changed'),
    videoDuration: _en('3 MIN'),
    blocks: [
      BsBlock(paragraphs: [
        _en("Hormone changes can make your skin drier, thinner or more easily "
            "irritated than before. So a product you've used for years can "
            "suddenly sting or feel tight."),
      ]),
      BsBlock(heading: _en('What helps?'), bullets: [
        _en('Switch to a gentle, fragrance-free face wash and moisturiser'),
        _en("Try one new product at a time, so if your skin reacts, you'll "
            "know which one it was"),
        _en("Wash with lukewarm water, not hot. Hot water strips your skin's "
            "natural oils faster"),
      ]),
    ],
  ),
  BsPage(
    id: 'pg_veins_tags',
    area: BsArea.pigmentation,
    // Red palms and moles joined this page 2026-09-29, from the gap analysis
    // ("Check your hands", "Keep track of skin changes", What to Expect daily
    // tips, P3: add to this page rather than write new ones).
    title: _en('Spider veins, skin tags and other small changes'),
    shortAnswer: _en("Spider veins, skin tags and red palms are small, "
        "harmless changes that often fade after birth. The one thing to show "
        "your doctor is a mole that is new or changing."),
    videoTitle: _en('Small, harmless changes'),
    videoSubtitle: _en('What causes each, and what to do about them'),
    videoDuration: _en('3 MIN'),
    blocks: [
      BsBlock(heading: _en('Spider veins'), paragraphs: [
        _en("Fine red or bluish lines, usually on your legs or face. They "
            "come from the extra blood in your body pressing on small blood "
            "vessels. Most fade after birth. Support stockings can ease heavy "
            "legs in the meantime."),
      ]),
      BsBlock(heading: _en('Skin tags'), paragraphs: [
        _en("Small, soft bits of skin, often on your neck, underarms or under "
            "your breasts, where skin rubs on skin and hormones are changing. "
            "They're harmless, and many shrink or go after birth. A doctor "
            "can remove any that bother you, at any time."),
      ]),
      BsBlock(heading: _en('Red palms'), paragraphs: [
        _en("Some women find the palms of their hands turning pink or red. "
            "It comes from the extra blood flow, it's harmless, and it fades "
            "after birth."),
        _en("Red palms are different from itchy palms. Strong itching on "
            "your palms or the soles of your feet needs a call to your doctor "
            "the same day. See Itchy skin in pregnancy, explained."),
      ]),
      BsBlock(heading: _en('Moles and freckles'), paragraphs: [
        _en("Moles and freckles can get a little darker in pregnancy, and "
            "that's usually normal. Show your doctor any mole that is new, "
            "changing shape or colour, bleeding or itchy, so they can take a "
            "look."),
      ]),
    ],
  ),

  // ---------------------------------------------------------------------
  //  Area 6 — Hair, nails and body changes (added 2026-09-29)
  //
  //  The gap analysis, Door: Belly & skin, P3: "Add reads for nail changes,
  //  gums and teeth, body hair, and 'your changing shape'" so that "every 'is
  //  this normal on my skin?' question lands in this door". The hair page
  //  moved here from Area 2, where it sat under a pigmentation heading.
  // ---------------------------------------------------------------------
  BsPage(
    id: 'pg_hair_changes',
    area: BsArea.bodyChanges,
    title: _en('Hair changes: thicker now, falling later'),
    shortAnswer: _en("Many women have thicker hair in pregnancy and then lose "
        "more than usual a few months after birth. Both are normal and they "
        "pass. Extra fine hair on the face or belly settles after birth too."),
    videoTitle: _en('What pregnancy does to your hair'),
    videoSubtitle: _en('Why hair changes twice, once now and once after birth'),
    videoDuration: _en('3 MIN'),
    blocks: [
      BsBlock(paragraphs: [
        _en("Pregnancy hormones keep your hair in its growing phase for "
            "longer. So many women notice thicker, fuller hair and less hair "
            "fall through most of the nine months."),
        _en("The hair fall often catches up all at once in the months after "
            "birth, as hair that was held on to finally lets go. It's normal "
            "and it stops, even when the amount looks frightening."),
        _en('Some women also notice extra fine hair on the face, arms or '
            'belly, from the same hormone change. It usually settles within '
            'months of birth.'),
      ]),
      BsBlock(heading: _en('Can I remove extra hair?'), paragraphs: [
        _en("Yes. Threading, shaving and waxing are all fine in pregnancy. "
            "Your skin may be more sensitive than usual, so waxing can sting "
            "more. Patch-test a hair removal cream on a small area first, and "
            "ask your doctor before using a bleach cream."),
      ]),
    ],
  ),
  BsPage(
    id: 'bd_nails',
    area: BsArea.bodyChanges,
    title: _en('Nails that grow fast, or break easily'),
    shortAnswer: _en("Pregnancy hormones can make your nails grow faster, and "
        "sometimes softer or more likely to break. It's harmless and usually "
        "settles after birth."),
    videoTitle: _en('Why your nails change in pregnancy'),
    videoSubtitle: _en('Faster growth, softer nails, and simple care'),
    videoDuration: _en('2 MIN'),
    blocks: [
      BsBlock(paragraphs: [
        _en("Many women find their nails grow faster than ever in pregnancy. "
            "For some, they also turn soft, split or break easily. Both come "
            "from the same hormone changes, and nails usually go back to "
            "normal after birth."),
      ]),
      BsBlock(heading: _en('What helps?'), bullets: [
        _en('Keep your nails short and filed smooth, so they catch less'),
        _en('Wear gloves for washing up and cleaning'),
        _en('Rub a little oil or moisturiser into your nails and cuticles at '
            'night'),
        _en('Nail polish is fine. Put it on near an open window, since '
            'strong smells can bother you more now'),
      ]),
      BsBlock(heading: _en('When should I show my doctor?'), paragraphs: [
        _en("If the skin around a nail turns red, swollen or painful, or a "
            "nail changes colour, show your doctor. It can be an infection, "
            "and it's easy to treat."),
      ]),
    ],
  ),
  BsPage(
    id: 'bd_gums_teeth',
    area: BsArea.bodyChanges,
    title: _en('Bleeding gums and your teeth'),
    shortAnswer: _en("Gums often swell and bleed a little when you brush in "
        "pregnancy. It's common and caused by hormones. Keep brushing gently, "
        "and a dental check-up during pregnancy is safe."),
    videoTitle: _en('Why your gums bleed now'),
    videoSubtitle: _en('Gentle care for gums and teeth, and when to see a '
        'dentist'),
    videoDuration: _en('3 MIN'),
    blocks: [
      BsBlock(paragraphs: [
        _en("Pregnancy hormones make your gums more sensitive to plaque, so "
            "they can swell, feel sore and bleed a little when you brush or "
            "floss. Dentists call it pregnancy gingivitis, and it's very "
            "common."),
      ]),
      BsBlock(heading: _en('What helps?'), bullets: [
        _en('Brush twice a day with a soft toothbrush and a fluoride '
            'toothpaste'),
        _en('Clean gently between your teeth once a day'),
        _en("After vomiting, rinse your mouth with plain water and wait a "
            "while before brushing. Stomach acid softens your teeth for a "
            "short time"),
        _en('Keep sugary snacks and drinks to mealtimes where you can'),
      ]),
      BsBlock(heading: _en('Can I see a dentist while pregnant?'), paragraphs: [
        _en("Yes. A check-up and cleaning are safe in pregnancy, and the "
            "second trimester is often the most comfortable time. Tell your "
            "dentist you're pregnant, so they can plan any X-ray or medicine "
            "with that in mind."),
      ]),
      BsBlock(heading: _en('When should I see a dentist soon?'), bullets: [
        _en("Bleeding that is heavy or doesn't stop"),
        _en('A painful swelling or lump on your gum'),
        _en("A loose tooth, or toothache that doesn't settle"),
      ]),
    ],
  ),
  BsPage(
    id: 'bd_changing_shape',
    area: BsArea.bodyChanges,
    title: _en('Your changing shape: breasts, feet and more'),
    shortAnswer: _en("Your whole body changes shape in pregnancy, not only "
        "your bump. Your breasts grow, your feet may swell and your belly "
        "button may pop out. Most of it settles after birth."),
    videoTitle: _en('How your body makes room for your baby'),
    videoSubtitle: _en('The changes beyond the bump, and what helps'),
    videoDuration: _en('3 MIN'),
    blocks: [
      BsBlock(paragraphs: [
        _en("Your bump is the change everyone notices, but your whole body is "
            "making room for your baby. It can feel strange to look in the "
            "mirror some days. That's a very normal feeling."),
      ]),
      BsBlock(heading: _en('What changes?'), bullets: [
        _en('Your breasts get bigger and heavier, and the skin around your '
            'nipples may darken. A soft, well-fitting bra helps'),
        _en('Your feet may swell by the end of the day. Some women go up a '
            'shoe size, and for some it stays'),
        _en('Your belly button may flatten or pop out later on. It goes back '
            'after birth'),
        _en('Your hips and ribs widen a little to make room, so old clothes '
            'can feel tight'),
      ]),
      BsBlock(heading: _en('When should I call my doctor?'), paragraphs: [
        _en("Call your doctor straight away if your face, hands or feet swell "
            "suddenly, especially with a headache or blurred vision. It can "
            "be a sign of high blood pressure in pregnancy (pre-eclampsia)."),
      ]),
    ],
  ),

  // ---------------------------------------------------------------------
  //  Area 4 — Safe skincare
  // ---------------------------------------------------------------------
  BsPage(
    id: 'sk_avoid',
    area: BsArea.safeSkincare,
    title: _en('What to avoid on your skin'),
    shortAnswer: _en("Three ingredients are best skipped in pregnancy: "
        "retinoids (retinol), strong salicylic acid and hydroquinone. If you "
        "used one before you knew you were pregnant, please don't panic. "
        "Just mention it to your doctor."),
    videoTitle: _en('The ingredients to skip for now'),
    videoSubtitle: _en('Why each one is a caution, not a panic'),
    videoDuration: _en('5 MIN'),
    blocks: [
      BsBlock(bullets: [
        _en("Retinoids and retinol: linked to birth defects at high, "
            "prescription doses in studies. The risk from a skin cream is "
            "likely small, but doctors advise skipping it because a safe "
            "option exists"),
        _en("Strong or oral salicylic acid: it's related to aspirin, and "
            "high doses are linked to complications. A low-dose face wash is "
            "different, see What's safe to use"),
        _en("Hydroquinone: a strong skin-lightening ingredient that gets into "
            "the body more than most creams. Pregnancy is the wrong time to "
            "use it, and pregnancy patches usually fade on their own anyway"),
      ]),
      BsBlock(paragraphs: [
        _en("If you used one of these before you knew you were pregnant, "
            "please don't panic. Using something once or twice is very "
            "different from using it every day. Mention it calmly to your "
            "doctor rather than worrying about it alone."),
      ]),
    ],
  ),
  BsPage(
    id: 'sk_safe',
    area: BsArea.safeSkincare,
    title: _en("What's safe to use"),
    shortAnswer: _en("Vitamin C, niacinamide, hyaluronic acid, azelaic acid, "
        "gentle low-dose acids and a mineral sunscreen are all fine in "
        "pregnancy. Unsure about something else? Check it in the Ingredient "
        "Safety Checker."),
    videoTitle: _en('The pregnancy-safe ingredient list'),
    videoSubtitle: _en("What you can keep using without a second thought"),
    videoDuration: _en('4 MIN'),
    blocks: [
      BsBlock(bullets: [
        _en('Vitamin C, for brighter skin and everyday protection'),
        _en('Niacinamide, which calms skin and suits spot-prone skin'),
        _en('Hyaluronic acid, for moisture, with no known pregnancy risk'),
        _en('Azelaic acid, which doctors often suggest in pregnancy for spots '
            'and dark patches'),
        _en('Low-dose glycolic or lactic acid, for gentle exfoliation in '
            'small amounts'),
        _en('Mineral sunscreen (zinc oxide or titanium dioxide), the most '
            'useful daily step'),
      ]),
      BsBlock(paragraphs: [
        _en('Not sure about an ingredient? Search it in the Ingredient Safety '
            'Checker for a clear answer.'),
      ]),
    ],
  ),
  BsPage(
    id: 'sk_routine',
    area: BsArea.safeSkincare,
    title: _en('A simple, safe daily routine'),
    shortAnswer: _en("Morning: face wash, moisturiser and mineral sunscreen. "
        "Night: face wash, moisturiser and your belly oil. That's all your "
        "skin needs right now."),
    videoTitle: _en('Four steps, morning and night'),
    videoSubtitle: _en('Everything you need, and nothing extra'),
    videoDuration: _en('3 MIN'),
    blocks: [
      BsBlock(heading: _en('Morning'), bullets: [
        _en('Gentle face wash'),
        _en('Vitamin C or niacinamide serum, if you like'),
        _en('Moisturiser'),
        _en('Mineral sunscreen, every day, even indoors'),
      ]),
      BsBlock(heading: _en('Night'), bullets: [
        _en('Gentle face wash'),
        _en('Hyaluronic acid or a plain moisturiser'),
        _en('Belly oil or cream, as part of your bump ritual'),
      ]),
      BsBlock(paragraphs: [
        _en("That's enough. Pregnancy isn't the time for a ten-step routine. "
            "Keep it to a few things you know are safe."),
      ]),
    ],
  ),
  BsPage(
    id: 'sk_facials',
    area: BsArea.safeSkincare,
    title: _en('Are facials and salon treatments okay?'),
    shortAnswer: _en("Yes, most basic facials, threading and pedicures are "
        "fine. Tell the salon you're pregnant, and skip strong peels, heavy "
        "essential oils and very hot steam."),
    videoTitle: _en('What to ask for at the salon'),
    videoSubtitle: _en('Mostly yes, with a few things to skip'),
    videoDuration: _en('3 MIN'),
    blocks: [
      BsBlock(paragraphs: [
        _en("Most basic facials are fine: cleansing, gentle exfoliation, a "
            "moisturising mask and a massage. Tell the salon you're pregnant "
            "before they start. A good salon will ask anyway."),
      ]),
      BsBlock(heading: _en('What should I ask them to skip?'), bullets: [
        _en('Chemical peels with retinoids or strong salicylic acid'),
        _en('Strong-smelling essential oil blends, in a room with little '
            'fresh air'),
        _en('Very hot steam or a sauna, more for your comfort and circulation '
            'than your skin'),
      ]),
      BsBlock(paragraphs: [
        _en("A pedicure, a basic facial and threading are all fine. If a "
            "treatment uses an ingredient you don't know, ask about it, or "
            "check it in the Ingredient Safety Checker before you say yes."),
      ]),
    ],
  ),

  // ---------------------------------------------------------------------
  //  Area 5 — Belly care
  // ---------------------------------------------------------------------
  BsPage(
    id: 'bc_showing',
    area: BsArea.bellyCare,
    // Added 2026-09-29 from the gap analysis (Flo, "When do you start showing
    // in pregnancy?", P2: "one of the most asked early questions").
    title: _en('When will I start showing?'),
    shortAnswer: _en("In a first pregnancy most women start to show somewhere "
        "between 12 and 16 weeks, and often earlier in a second. Every body "
        "is different, so showing earlier or later is usually normal."),
    videoTitle: _en('When your bump starts to show'),
    videoSubtitle: _en('Why some women show early and some late'),
    videoDuration: _en('2 MIN'),
    blocks: [
      BsBlock(paragraphs: [
        _en("In the first weeks your womb (uterus) is still small and sits "
            "low, behind your pelvic bone. Around the end of the first "
            "trimester it starts to rise above it, and that's when a small "
            "bump often appears."),
      ]),
      BsBlock(heading: _en('Why do some women show earlier or later?'),
          bullets: [
        _en('A second or later pregnancy, when your tummy muscles have '
            'stretched before'),
        _en('Your height, your build and your tummy muscles'),
        _en('Where your womb sits, and how your baby is lying'),
        _en('Carrying twins or more'),
        _en('Bloating in the early weeks, which can look like a bump before '
            'there is one'),
      ]),
      BsBlock(paragraphs: [
        _en("Your doctor checks your baby's growth at your visits and scans. "
            "How your bump looks from the outside doesn't tell you how your "
            "baby is growing."),
      ]),
    ],
  ),
  BsPage(
    id: 'bc_bump_sizes',
    area: BsArea.bellyCare,
    // Added 2026-09-29 from the gap analysis (Flo, "Your growing baby bump:
    // What to expect when", P3: "women compare their bumps with others and
    // worry").
    title: _en('Why every bump looks different'),
    shortAnswer: _en("Bumps come in every shape and size. Big or small, high "
        "or low, a bump says more about your body than about your baby. Your "
        "doctor checks your baby's growth. The look of a bump can't."),
    videoTitle: _en('Big, small, high or low'),
    videoSubtitle: _en('What your bump size does and does not mean'),
    videoDuration: _en('2 MIN'),
    blocks: [
      BsBlock(paragraphs: [
        _en("It's hard not to compare, especially when relatives say you look "
            "too small or too big. But the size and shape of a bump depend on "
            "your height, your muscles, how much fluid there is and how your "
            "baby is lying."),
      ]),
      BsBlock(heading: _en('Does a high or low bump mean anything?'),
          paragraphs: [
        _en("No. Relatives may read all sorts of things into a high or low "
            "bump, but its shape doesn't tell you anything about your baby."),
      ]),
      BsBlock(heading: _en('When should I ask my doctor?'), paragraphs: [
        _en("If your bump suddenly seems to grow much faster, or stops "
            "growing, mention it at your next visit. They can check with a "
            "simple measurement or a scan. If your baby's movements slow down "
            "or change, call your doctor the same day."),
      ]),
    ],
  ),
  BsPage(
    id: 'bc_oiling',
    area: BsArea.bellyCare,
    title: _en('Belly oiling and gentle massage'),
    shortAnswer: _en("Belly oiling is an old Indian tradition and a lovely "
        "daily habit. Warm a little oil, massage in slow circles for about "
        "five minutes, and enjoy a few calm minutes with your baby."),
    videoTitle: _en('The daily oiling ritual, step by step'),
    videoSubtitle: _en('An Indian tradition, and why it still holds up'),
    videoDuration: _en('4 MIN'),
    blocks: [
      BsBlock(paragraphs: [
        _en("Belly oiling has been part of Indian pregnancy care for "
            "generations. Warm sesame, coconut or almond oil is massaged in "
            "slow circles, by your mother, your mother-in-law or you. It was "
            "never really about stopping marks. It was about touch, comfort "
            "and a few calm minutes each day for the baby."),
      ]),
      BsBlock(heading: _en('How do I do it?'), bullets: [
        _en('Warm a little oil between your palms'),
        _en('Massage in slow, gentle circles, moving out from your belly '
            'button'),
        _en('Include your hips and lower back if someone is helping you'),
        _en("Five minutes is enough. It's a moment for you, not a chore"),
      ]),
    ],
    products: [bsBellyOil],
  ),
  BsPage(
    id: 'bc_bands',
    area: BsArea.bellyCare,
    title: _en('Belly bands and support'),
    shortAnswer: _en("A belly band is a soft, stretchy support that takes some "
        "weight off your lower back later in pregnancy. It's for comfort, not "
        "a medical need, and many women never use one."),
    videoTitle: _en('What a belly band does'),
    videoSubtitle: _en('Support, not shaping, and when it helps'),
    videoDuration: _en('3 MIN'),
    blocks: [
      BsBlock(paragraphs: [
        _en("A belly band is a wide, stretchy support you wear under or over "
            "your clothes. It doesn't shape your bump or prevent anything. It "
            "gently holds some of your bump's weight, which can ease lower "
            "back and pelvic strain later in pregnancy."),
      ]),
      BsBlock(heading: _en('When does it help?'), bullets: [
        _en('Long days on your feet, in the second half of pregnancy'),
        _en('Lower back or pelvic pain you already have'),
        _en('Travel, when you sit or stand for a long time'),
      ]),
      BsBlock(paragraphs: [
        _en("Not everyone needs one, and that's fine. It's for comfort, not "
            "a medical must, so choose one that feels supportive without "
            "being tight."),
      ]),
    ],
    products: [bsBellyBand],
  ),
  BsPage(
    id: 'bc_comfort',
    area: BsArea.bellyCare,
    title: _en('Comfort for your growing bump'),
    shortAnswer: _en("Sleep on your side with pillows, wear loose cotton, take "
        "short walks, and use a warm compress when your bump feels tight. "
        "Small changes like these make the day easier."),
    videoTitle: _en('Small changes that ease the day'),
    videoSubtitle: _en('Sleep, clothes and short walks that help'),
    videoDuration: _en('3 MIN'),
    blocks: [
      BsBlock(bullets: [
        _en('Sleep on your side with a pillow between your knees and one '
            'under your bump, for support without pressure'),
        _en('Loose, soft cotton, especially in Indian summers, when your skin '
            'already feels warmer and more sensitive'),
        _en('Short walks often, instead of long spells of standing or '
            'sitting'),
        _en('A warm (not hot) compress for a tight or achy bump at the end of '
            'a long day'),
      ]),
    ],
  ),
];

// =============================================================================
//  Ingredient Safety Checker
// =============================================================================

enum BsVerdict { safe, limit, avoid }

class BsIngredient {
  const BsIngredient({
    required this.id,
    required this.name,
    this.aliases = const [],
    required this.verdict,
    required this.why,
    this.alternativeName,
    this.alternativeProduct,
  });
  final String id;
  final LocalizedText name;

  /// Lowercase search terms beyond the name itself.
  final List<String> aliases;
  final BsVerdict verdict;

  /// 2-3 plain lines on why.
  final List<LocalizedText> why;

  /// A safe alternative to reach for instead, where relevant.
  final LocalizedText? alternativeName;
  final BsProduct? alternativeProduct;
}

BsIngredient? bsIngredientById(String id) {
  for (final i in kBsIngredients) {
    if (i.id == id) return i;
  }
  return null;
}

List<BsIngredient> bsIngredientSearch(String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return const [];
  bool matches(BsIngredient i) =>
      i.name.en.toLowerCase().contains(q) ||
      i.aliases.any((a) => a.contains(q));
  return kBsIngredients.where(matches).toList(growable: false);
}

const List<BsIngredient> kBsIngredients = [
  BsIngredient(
    id: 'retinoids',
    name: LocalizedText(en: 'Retinoids / retinol', hi: 'Retinoids / retinol'),
    aliases: ['retinol', 'retinoid', 'tretinoin', 'retin-a', 'vitamin a acid'],
    verdict: BsVerdict.avoid,
    why: [
      LocalizedText(
          en: 'Prescription-strength retinoids have been linked to birth '
              'defects at high doses in studies.',
          hi: 'Prescription-strength retinoids have been linked to birth '
              'defects at high doses in studies.'),
      LocalizedText(
          en: 'The risk from an over-the-counter cream is likely small, but '
              'doctors advise skipping it because a safe option exists.',
          hi: 'The risk from an over-the-counter cream is likely small, but '
              'doctors advise skipping it because a safe option exists.'),
    ],
    alternativeName:
        LocalizedText(en: 'Vitamin C or niacinamide', hi: 'Vitamin C or niacinamide'),
  ),
  BsIngredient(
    id: 'salicylic_low',
    name: LocalizedText(
        en: 'Salicylic acid (low dose, face wash)',
        hi: 'Salicylic acid (low dose, face wash)'),
    aliases: ['bha', 'beta hydroxy acid', 'salicylic'],
    verdict: BsVerdict.limit,
    why: [
      LocalizedText(
          en: 'A low concentration in a cleanser that is rinsed off, under '
              '2%, is generally considered fine by most doctors.',
          hi: 'A low concentration in a cleanser that is rinsed off, under '
              '2%, is generally considered fine by most doctors.'),
      LocalizedText(
          en: 'The caution is for high-dose, leave-on or oral forms, not a '
              'face wash like this.',
          hi: 'The caution is for high-dose, leave-on or oral forms, not a '
              'face wash like this.'),
    ],
  ),
  BsIngredient(
    id: 'salicylic_high',
    name: LocalizedText(
        en: 'Salicylic acid (high dose / peels / oral)',
        hi: 'Salicylic acid (high dose / peels / oral)'),
    aliases: ['salicylic acid peel', 'aspirin', 'oral salicylic'],
    verdict: BsVerdict.avoid,
    why: [
      LocalizedText(
          en: 'Salicylic acid is chemically related to aspirin, and high '
              'doses have been linked to pregnancy complications.',
          hi: 'Salicylic acid is chemically related to aspirin, and high '
              'doses have been linked to pregnancy complications.'),
      LocalizedText(
          en: 'This covers strong leave-on peels and any oral form, not a '
              'diluted daily cleanser.',
          hi: 'This covers strong leave-on peels and any oral form, not a '
              'diluted daily cleanser.'),
    ],
    alternativeName:
        LocalizedText(en: 'Low-dose glycolic or lactic acid', hi: 'Low-dose glycolic or lactic acid'),
  ),
  BsIngredient(
    id: 'benzoyl_peroxide',
    name: LocalizedText(en: 'Benzoyl peroxide', hi: 'Benzoyl peroxide'),
    aliases: ['bpo'],
    verdict: BsVerdict.limit,
    why: [
      LocalizedText(
          en: 'Very little of it absorbs through skin, so most doctors '
              'consider small, occasional use reasonable for a breakout.',
          hi: 'Very little of it absorbs through skin, so most doctors '
              'consider small, occasional use reasonable for a breakout.'),
      LocalizedText(
          en: 'Check with your own doctor before you make it part of your '
              'daily routine.',
          hi: 'Check with your own doctor before you make it part of your '
              'daily routine.'),
    ],
    alternativeName: LocalizedText(en: 'Niacinamide', hi: 'Niacinamide'),
  ),
  BsIngredient(
    id: 'hydroquinone',
    name: LocalizedText(en: 'Hydroquinone', hi: 'Hydroquinone'),
    aliases: ['skin lightening', 'bleaching cream'],
    verdict: BsVerdict.avoid,
    why: [
      LocalizedText(
          en: 'A strong skin-lightening ingredient that absorbs into the '
              'body more than most topicals.',
          hi: 'A strong skin-lightening ingredient that absorbs into the '
              'body more than most topicals.'),
      LocalizedText(
          en: 'Pregnancy patches fade on their own after birth in most '
              'cases, so there is little reason to take the risk now.',
          hi: 'Pregnancy patches fade on their own after birth in most '
              'cases, so there is little reason to take the risk now.'),
    ],
    alternativeName: LocalizedText(en: 'Mineral sunscreen, daily', hi: 'Mineral sunscreen, daily'),
    alternativeProduct: bsMineralSunscreen,
  ),
  BsIngredient(
    id: 'chemical_sunscreen',
    name: LocalizedText(en: 'Chemical sunscreen', hi: 'Chemical sunscreen'),
    aliases: ['oxybenzone', 'avobenzone', 'octinoxate'],
    verdict: BsVerdict.limit,
    why: [
      LocalizedText(
          en: 'Some chemical filters, oxybenzone in particular, absorb into '
              'the body more than mineral ones do.',
          hi: 'Some chemical filters, oxybenzone in particular, absorb into '
              'the body more than mineral ones do.'),
      LocalizedText(
          en: 'A mineral sunscreen sits on top of skin instead, and is the '
              'straightforward safer swap.',
          hi: 'A mineral sunscreen sits on top of skin instead, and is the '
              'straightforward safer swap.'),
    ],
    alternativeName: LocalizedText(en: 'Mineral (zinc oxide) sunscreen', hi: 'Mineral (zinc oxide) sunscreen'),
    alternativeProduct: bsMineralSunscreen,
  ),
  BsIngredient(
    id: 'mineral_sunscreen',
    name: LocalizedText(en: 'Mineral sunscreen', hi: 'Mineral sunscreen'),
    aliases: ['zinc oxide', 'titanium dioxide', 'physical sunscreen'],
    verdict: BsVerdict.safe,
    why: [
      LocalizedText(
          en: 'Zinc oxide and titanium dioxide sit on the skin\'s surface '
              'rather than absorbing into it.',
          hi: 'Zinc oxide and titanium dioxide sit on the skin\'s surface '
              'rather than absorbing into it.'),
      LocalizedText(
          en: 'It is also the one change shown to reduce dark patches, so '
              'use it every day, not just when you step out.',
          hi: 'It is also the one change shown to reduce dark patches, so '
              'use it every day, not just when you step out.'),
    ],
    alternativeProduct: bsMineralSunscreen,
  ),
  BsIngredient(
    id: 'niacinamide',
    name: LocalizedText(en: 'Niacinamide', hi: 'Niacinamide'),
    aliases: ['vitamin b3'],
    verdict: BsVerdict.safe,
    why: [
      LocalizedText(
          en: 'A well-tolerated, non-irritating ingredient with no known '
              'pregnancy risk.',
          hi: 'A well-tolerated, non-irritating ingredient with no known '
              'pregnancy risk.'),
      LocalizedText(
          en: 'Calms redness and spots, so it is a good stand-in for the '
              'strong creams you are skipping right now.',
          hi: 'Calms redness and spots, so it is a good stand-in for the '
              'strong creams you are skipping right now.'),
    ],
  ),
  BsIngredient(
    id: 'vitamin_c',
    name: LocalizedText(en: 'Vitamin C', hi: 'Vitamin C'),
    aliases: ['ascorbic acid'],
    verdict: BsVerdict.safe,
    why: [
      LocalizedText(
          en: 'A well-studied antioxidant with no known pregnancy risk.',
          hi: 'A well-studied antioxidant with no known pregnancy risk.'),
      LocalizedText(
          en: 'Helps with brightening and everyday sun-related dullness, '
              'alongside sunscreen, not instead of it.',
          hi: 'Helps with brightening and everyday sun-related dullness, '
              'alongside sunscreen, not instead of it.'),
    ],
  ),
  BsIngredient(
    id: 'hyaluronic_acid',
    name: LocalizedText(en: 'Hyaluronic acid', hi: 'Hyaluronic acid'),
    aliases: ['ha', 'sodium hyaluronate'],
    verdict: BsVerdict.safe,
    why: [
      LocalizedText(
          en: 'A hydrating ingredient that holds water in the skin, with no '
              'known pregnancy risk.',
          hi: 'A hydrating ingredient that holds water in the skin, with no '
              'known pregnancy risk.'),
      LocalizedText(
          en: 'A good daily moisturiser step, especially if skin feels '
              'drier or tighter than before.',
          hi: 'A good daily moisturiser step, especially if skin feels '
              'drier or tighter than before.'),
    ],
  ),
  BsIngredient(
    id: 'glycolic_lactic',
    name: LocalizedText(en: 'Glycolic / lactic acid', hi: 'Glycolic / lactic acid'),
    aliases: ['aha', 'alpha hydroxy acid'],
    verdict: BsVerdict.limit,
    why: [
      LocalizedText(
          en: 'Low concentrations, under about 10%, in a rinse-off product '
              'are generally considered fine.',
          hi: 'Low concentrations, under about 10%, in a rinse-off product '
              'are generally considered fine.'),
      LocalizedText(
          en: 'Strong leave-on peels at higher strengths are better left '
              'until after pregnancy.',
          hi: 'Strong leave-on peels at higher strengths are better left '
              'until after pregnancy.'),
    ],
  ),
  BsIngredient(
    id: 'essential_oils',
    name: LocalizedText(en: 'Essential oils', hi: 'Essential oils'),
    aliases: ['clary sage', 'rosemary oil', 'aromatherapy'],
    verdict: BsVerdict.limit,
    why: [
      LocalizedText(
          en: 'Most essential oils, well diluted, are fine for occasional '
              'use, lavender and chamomile among the gentler ones.',
          hi: 'Most essential oils, well diluted, are fine for occasional '
              'use, lavender and chamomile among the gentler ones.'),
      LocalizedText(
          en: 'A few, clary sage and rosemary in particular, are best '
              'avoided as they are linked to uterine contractions.',
          hi: 'A few, clary sage and rosemary in particular, are best '
              'avoided as they are linked to uterine contractions.'),
    ],
  ),
  BsIngredient(
    id: 'self_tanners',
    name: LocalizedText(en: 'Self-tanners', hi: 'Self-tanners'),
    aliases: ['dha', 'sunless tan', 'tan lotion'],
    verdict: BsVerdict.limit,
    why: [
      LocalizedText(
          en: 'The active ingredient, DHA, works on the skin\'s surface and '
              'very little is thought to absorb.',
          hi: 'The active ingredient, DHA, works on the skin\'s surface and '
              'very little is thought to absorb.'),
      LocalizedText(
          en: 'Spray formats are best avoided since inhaling the mist has '
              'not been well studied; a lotion applied by hand is the safer '
              'choice.',
          hi: 'Spray formats are best avoided since inhaling the mist has '
              'not been well studied; a lotion applied by hand is the safer '
              'choice.'),
    ],
  ),
  BsIngredient(
    id: 'hair_dye',
    name: LocalizedText(en: 'Hair dye', hi: 'Hair dye'),
    aliases: ['hair colour', 'hair color', 'henna'],
    verdict: BsVerdict.limit,
    why: [
      LocalizedText(
          en: 'Very little dye is absorbed through the scalp, and most '
              'doctors consider it fine after the first trimester.',
          hi: 'Very little dye is absorbed through the scalp, and most '
              'doctors consider it fine after the first trimester.'),
      LocalizedText(
          en: 'Choose a well-ventilated salon, and highlights or balayage '
              '(which do not touch the scalp) over a full root application '
              'if you would rather be extra cautious.',
          hi: 'Choose a well-ventilated salon, and highlights or balayage '
              '(which do not touch the scalp) over a full root application '
              'if you would rather be extra cautious.'),
    ],
  ),
  BsIngredient(
    id: 'keratin_treatment',
    name: LocalizedText(en: 'Keratin treatments', hi: 'Keratin treatments'),
    aliases: ['hair smoothening', 'brazilian blowout', 'formaldehyde'],
    verdict: BsVerdict.avoid,
    why: [
      LocalizedText(
          en: 'Most keratin and smoothening treatments release formaldehyde '
              'gas when heat-styled, in a closed salon room.',
          hi: 'Most keratin and smoothening treatments release formaldehyde '
              'gas when heat-styled, in a closed salon room.'),
      LocalizedText(
          en: 'Breathing that in over hours is the real concern, not the '
              'product on your hair, so this is best postponed until after '
              'pregnancy and breastfeeding.',
          hi: 'Breathing that in over hours is the real concern, not the '
              'product on your hair, so this is best postponed until after '
              'pregnancy and breastfeeding.'),
    ],
  ),

  // ---- Added 2026-09-29: the gap analysis asks to "grow the ingredient
  // checker past 15 ingredients" (Door: Belly & skin, P3). Six that Indian
  // women ask about most, each with the same caution as the fifteen above.
  BsIngredient(
    id: 'azelaic_acid',
    name: LocalizedText(en: 'Azelaic acid', hi: 'Azelaic acid'),
    aliases: ['azelaic'],
    verdict: BsVerdict.safe,
    why: [
      LocalizedText(
          en: 'Very little of it is absorbed through the skin, and doctors '
              'often suggest it in pregnancy.',
          hi: 'Very little of it is absorbed through the skin, and doctors '
              'often suggest it in pregnancy.'),
      LocalizedText(
          en: 'It helps with both spots and dark patches, so it can stand in '
              'for retinol and stronger lightening creams.',
          hi: 'It helps with both spots and dark patches, so it can stand in '
              'for retinol and stronger lightening creams.'),
    ],
  ),
  BsIngredient(
    id: 'plant_butters_oils',
    name: LocalizedText(
        en: 'Coconut, almond oil, shea or cocoa butter',
        hi: 'Coconut, almond oil, shea or cocoa butter'),
    aliases: ['coconut oil', 'almond oil', 'badam oil', 'shea butter',
      'cocoa butter', 'sesame oil', 'til oil', 'vitamin e'],
    verdict: BsVerdict.safe,
    why: [
      LocalizedText(
          en: 'Plain oils and butters keep skin soft and are fine to use '
              'every day, on your face or your bump.',
          hi: 'Plain oils and butters keep skin soft and are fine to use '
              'every day, on your face or your bump.'),
      LocalizedText(
          en: 'If you have a nut allergy, skip almond oil and choose coconut '
              'or sesame instead.',
          hi: 'If you have a nut allergy, skip almond oil and choose coconut '
              'or sesame instead.'),
    ],
    alternativeProduct: bsBellyOil,
  ),
  BsIngredient(
    id: 'aloe_vera',
    name: LocalizedText(en: 'Aloe vera gel', hi: 'Aloe vera gel'),
    aliases: ['aloe', 'aloevera', 'ghritkumari'],
    verdict: BsVerdict.safe,
    why: [
      LocalizedText(
          en: 'Aloe vera gel on the skin is soothing and fine in pregnancy.',
          hi: 'Aloe vera gel on the skin is soothing and fine in pregnancy.'),
      LocalizedText(
          en: 'This is about the gel on your skin. Aloe juice or tablets to '
              'swallow are different, so ask your doctor before taking those.',
          hi: 'This is about the gel on your skin. Aloe juice or tablets to '
              'swallow are different, so ask your doctor before taking those.'),
    ],
  ),
  BsIngredient(
    id: 'hair_removal_cream',
    name: LocalizedText(en: 'Hair removal cream', hi: 'Hair removal cream'),
    aliases: ['depilatory', 'veet', 'thioglycolate', 'hair removal'],
    verdict: BsVerdict.limit,
    why: [
      LocalizedText(
          en: 'Very little is absorbed, and most doctors consider occasional '
              'use fine.',
          hi: 'Very little is absorbed, and most doctors consider occasional '
              'use fine.'),
      LocalizedText(
          en: 'Your skin may react more easily now, so patch-test a small area '
              'first and use it in a room with fresh air, since the smell is '
              'strong.',
          hi: 'Your skin may react more easily now, so patch-test a small area '
              'first and use it in a room with fresh air, since the smell is '
              'strong.'),
    ],
    alternativeName: LocalizedText(
        en: 'Threading, shaving or waxing', hi: 'Threading, shaving or waxing'),
  ),
  BsIngredient(
    id: 'tea_tree_oil',
    name: LocalizedText(en: 'Tea tree oil', hi: 'Tea tree oil'),
    aliases: ['tea tree', 'melaleuca'],
    verdict: BsVerdict.limit,
    why: [
      LocalizedText(
          en: 'A few drops, well diluted in a face wash or cream, are '
              'generally considered fine for a spot now and then.',
          hi: 'A few drops, well diluted in a face wash or cream, are '
              'generally considered fine for a spot now and then.'),
      LocalizedText(
          en: 'Never put it on neat or swallow it, and stop if your skin '
              'stings or turns red.',
          hi: 'Never put it on neat or swallow it, and stop if your skin '
              'stings or turns red.'),
    ],
    alternativeName: LocalizedText(en: 'Niacinamide', hi: 'Niacinamide'),
  ),
  BsIngredient(
    id: 'minoxidil',
    name: LocalizedText(en: 'Minoxidil (hair regrowth)', hi: 'Minoxidil (hair regrowth)'),
    aliases: ['minoxidil', 'hair regrowth', 'hair fall solution', 'rogaine'],
    verdict: BsVerdict.avoid,
    why: [
      LocalizedText(
          en: 'Hair regrowth treatments with minoxidil are not recommended in '
              'pregnancy or while breastfeeding.',
          hi: 'Hair regrowth treatments with minoxidil are not recommended in '
              'pregnancy or while breastfeeding.'),
      LocalizedText(
          en: 'Hair fall after birth usually stops on its own. If it worries '
              'you, talk to your doctor once your baby is here.',
          hi: 'Hair fall after birth usually stops on its own. If it worries '
              'you, talk to your doctor once your baby is here.'),
    ],
  ),
];

/// Tappable chips on the checker's landing view.
const List<({String id, String emoji})> kBsPopularIngredients = [
  (id: 'retinoids', emoji: '🧴'),
  (id: 'chemical_sunscreen', emoji: '☀️'),
  (id: 'niacinamide', emoji: '✨'),
  (id: 'salicylic_high', emoji: '🧪'),
  (id: 'essential_oils', emoji: '🌿'),
  (id: 'hair_dye', emoji: '💇'),
];

// =============================================================================
//  Area 3 — Itching [SAFETY CORE]. Content lives here; layout in
//  bs_itching_screen.dart. No BsProduct anywhere near this content, by rule.
// =============================================================================

final LocalizedText kBsItchingIntro = _en(
    "Skin stretching over your bump is itchy for most women, and that part is "
    "normal. There's also one warning sign to know about, further down this "
    "page.");

/// ⚠️ SPLIT INTO TWO NAMED LISTS, because the page has two headings and the
/// review asked for both by name: "Usually harmless" and "How to soothe it".
///
/// They used to be one list where the first block had no heading and the
/// second was called "What soothes it", which rendered as one undifferentiated
/// run of text under "Is this normal?" - so the page answered "why does this
/// happen" and "what do I do" in the same breath, and a mother scanning for
/// the second had to read the first.
final List<BsBlock> kBsItchingHarmless = [
  BsBlock(paragraphs: [
    _en("As your skin stretches and dries out faster than usual, it's common "
        "to feel itchy on your belly, breasts and thighs, especially in the "
        "second and third trimester."),
    _en("This kind of itching is mild, comes and goes, and usually settles "
        "with a moisturiser. It's uncomfortable, not worrying."),
  ]),
];

final List<BsBlock> kBsItchingSoothe = [
  BsBlock(bullets: [
    // ⚠️ THE BELLY OIL REFERENCE IS GONE. The bullet read "a fragrance-free
    // moisturiser or the belly oil ritual", and the ritual is a product
    // surface. Review: "absolutely no products on this page, this is a safety
    // route, not a commerce page." A nudge toward something purchasable is
    // still a nudge, and on the one page in this section that exists to route
    // a woman to a doctor it is the wrong instinct even in a soft form.
    _en('A plain, fragrance-free moisturiser, put on while your skin is '
        'still a little damp after a bath'),
    _en('Lukewarm water instead of hot, which dries your skin out faster'),
    _en('Staying away from what irritates it: strong soaps, heavily perfumed '
        'washes, and rough synthetic fabric against your skin'),
    _en('Loose, soft cotton clothes, especially in Indian heat'),
    _en('A humidifier in the room if the air is very dry'),
  ]),
];

/// Kept for revert - the pre-split list, before the page grew two headings.
// final List<BsBlock> kBsItchingNormal = [ ... ];

/// ⚠️ THE WARNING. No product anywhere near it. State it plainly.
///
/// ⚠️ IT RENDERS BELOW THE SOOTHING TIPS NOW, NOT ABOVE, AND THAT IS A
/// REVERSAL WORTH EXPLAINING.
///
/// The old comment here said "rendered ABOVE the soothing tips", on the
/// argument that position carries urgency and burying a complication under
/// "how to soothe dry skin" lets reassurance win the argument. That argument
/// is good and it is not what review asked for.
///
/// Two things settled it. First, the review's own order is how a clinician
/// actually explains this: here is what is almost certainly happening, here is
/// what helps, and here is the one thing to watch for. Leading with the
/// complication frightens every woman with ordinary dry skin, which is nearly
/// all of them.
///
/// Second, the page was already contradicting itself. `kBsItchingIntro` says
/// the warning is "further down this page" while the card was rendering
/// directly above the tips. The copy was written for this order; only the
/// layout had drifted.
///
/// The urgency is carried by treatment instead: its own heavy-bordered card,
/// its own heading, and two actions rather than one.
final LocalizedText kBsItchingWarningTitle = _en(
    'When itching is more than dry skin');
final LocalizedText kBsItchingWarningBody = _en(
    'Intense itching, especially on the palms of your hands and the soles of '
    'your feet, with no rash, can be a sign of a liver condition called '
    'cholestasis of pregnancy (ICP). It affects how your liver handles bile, '
    "and it needs a doctor's care.");
final LocalizedText kBsItchingWarningCta = _en('See your doctor');
final LocalizedText kBsItchingWarningNote = _en(
    "Please don't wait this out. If the itching is intense, worse at night, "
    "or on your palms and soles, call your doctor today. Don't wait for your "
    "next visit.");
