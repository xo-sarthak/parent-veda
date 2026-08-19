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

enum BsArea { stretchMarks, pigmentation, itching, safeSkincare, bellyCare }

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
        en: 'Why they happen, what actually helps, and what to expect',
        hi: 'Why they happen, what actually helps, and what to expect'),
    hue: 344,
  ),
  BsArea.pigmentation: BsAreaInfo(
    title: LocalizedText(en: 'Pigmentation & skin changes',
        hi: 'Pigmentation & skin changes'),
    blurb: LocalizedText(
        en: 'The dark line, the glow, the patches. Most of it fades after birth',
        hi: 'The dark line, the glow, the patches. Most of it fades after birth'),
    hue: 26,
  ),
  BsArea.itching: BsAreaInfo(
    title: LocalizedText(en: 'Itching', hi: 'Itching'),
    blurb: LocalizedText(
        en: 'What is normal, and the one warning sign worth knowing',
        hi: 'What is normal, and the one warning sign worth knowing'),
    hue: 12,
  ),
  BsArea.safeSkincare: BsAreaInfo(
    title: LocalizedText(en: 'Safe skincare', hi: 'Safe skincare'),
    blurb: LocalizedText(
        en: 'What to avoid, what is fine, and a simple daily routine',
        hi: 'What to avoid, what is fine, and a simple daily routine'),
    hue: 160,
  ),
  BsArea.bellyCare: BsAreaInfo(
    title: LocalizedText(en: 'Belly care', hi: 'Belly care'),
    blurb: LocalizedText(
        en: 'Oiling, support and comfort for the growing bump',
        hi: 'Oiling, support and comfort for the growing bump'),
    hue: 42,
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
      en: 'A simple oil blend for the daily massage. Keeps skin comfortable; '
          'it will not erase marks that are already forming underneath.',
      hi: 'A simple oil blend for the daily massage. Keeps skin comfortable; '
          'it will not erase marks that are already forming underneath.'),
  ctaLabel: LocalizedText(en: 'See the oil', hi: 'See the oil'),
  hue: 344,
  ownSku: true,
);

const bsStretchMarkCream = BsProduct(
  id: 'stretch_mark_cream',
  title: LocalizedText(
      en: 'ParentVeda Stretch Mark Cream', hi: 'ParentVeda Stretch Mark Cream'),
  blurb: LocalizedText(
      en: 'A richer, pregnancy-safe cream for skin that is already tight or '
          'itchy. Comfort now, and a head start on fading later.',
      hi: 'A richer, pregnancy-safe cream for skin that is already tight or '
          'itchy. Comfort now, and a head start on fading later.'),
  ctaLabel: LocalizedText(en: 'See the cream', hi: 'See the cream'),
  hue: 344,
  ownSku: true,
);

const bsMineralSunscreen = BsProduct(
  id: 'mineral_sunscreen',
  title: LocalizedText(
      en: 'A pregnancy-safe mineral sunscreen', hi: 'A pregnancy-safe mineral sunscreen'),
  blurb: LocalizedText(
      en: 'Zinc oxide or titanium dioxide, SPF 30 or higher. The single '
          'change that measurably reduces pigmentation.',
      hi: 'Zinc oxide or titanium dioxide, SPF 30 or higher. The single '
          'change that measurably reduces pigmentation.'),
  ctaLabel: LocalizedText(en: 'See sunscreen options', hi: 'See sunscreen options'),
  hue: 26,
  ownSku: false,
);

const bsBellyBand = BsProduct(
  id: 'belly_band',
  title: LocalizedText(en: 'A maternity belly band', hi: 'A maternity belly band'),
  blurb: LocalizedText(
      en: 'Outside support for the lower back and bump on longer days. Not '
          'medical, and not needed by everyone.',
      hi: 'Outside support for the lower back and bump on longer days. Not '
          'medical, and not needed by everyone.'),
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
  // ---------------------------------------------------------------------
  BsPage(
    id: 'sm_why',
    area: BsArea.stretchMarks,
    title: _en('Why stretch marks happen'),
    videoTitle: _en('Why skin marks, explained simply'),
    videoSubtitle: _en('What is actually happening under the surface'),
    videoDuration: _en('4 MIN'),
    honestNote: _en('The honest answer: stretch marks are largely genetic. '
        'If your mother or sister has them, you are more likely to as well, '
        'and no cream changes that fact.'),
    blocks: [
      BsBlock(paragraphs: [
        _en('Skin has a layer under the surface, the dermis, that stretches '
            'as your bump grows. When it stretches faster than that layer '
            'can keep up, the fibres tear in tiny lines. That tear is a '
            'stretch mark.'),
        _en('How much any one body marks depends mostly on skin type, '
            'genetics, and how much and how fast the bump grows, not on '
            'effort. Two women doing the exact same routine can end up '
            'looking very different, and neither one did anything wrong.'),
      ]),
      BsBlock(heading: _en('What raises the odds'), bullets: [
        _en('A close family history of stretch marks'),
        _en('Naturally drier or less elastic skin'),
        _en('Rapid weight gain, or carrying twins'),
        _en('A first pregnancy, when skin has never stretched this way before'),
      ]),
    ],
  ),
  BsPage(
    id: 'sm_what_helps',
    area: BsArea.stretchMarks,
    title: _en('What actually helps, and what does not'),
    videoTitle: _en('Separating fact from the marketing'),
    videoSubtitle: _en('Where the evidence is real, and where it is a guess'),
    videoDuration: _en('5 MIN'),
    blocks: [
      BsBlock(heading: _en('What genuinely helps'), bullets: [
        _en('Keeping skin hydrated, daily, for the whole pregnancy'),
        _en('Gentle massage, which improves comfort and circulation'),
        _en('Gradual weight gain where your doctor is comfortable with the pace'),
        _en('Time. Most marks fade from a deep red or purple to a soft silver '
            'over the first year after birth'),
      ]),
      BsBlock(heading: _en('What does not, on its own'), bullets: [
        _en('No cream can fully prevent marks in skin that is genetically '
            'prone to them'),
        _en('Expensive rarely means more effective. The active ingredients '
            'in a budget oil and a premium one are usually the same'),
        _en('A product cannot undo a tear that has already happened, only '
            'support the skin around it'),
      ]),
      BsBlock(paragraphs: [
        _en('So the honest goal is comfort and support, not a guarantee. '
            'That still matters. Comfortable skin itches less, and a daily '
            'ritual is something you can actually keep up with for nine '
            'months.'),
      ]),
    ],
  ),
  BsPage(
    id: 'sm_oils_creams',
    area: BsArea.stretchMarks,
    title: _en('Oils and creams that help'),
    videoTitle: _en('A daily routine that takes two minutes'),
    videoSubtitle: _en('Where to apply, and how much'),
    videoDuration: _en('3 MIN'),
    blocks: [
      BsBlock(heading: _en('How to use them'), bullets: [
        _en('Apply once or twice a day, from the second trimester onward as '
            'the bump grows fastest'),
        _en('Cover the belly, hips, thighs and chest, wherever skin is '
            'stretching, not only the bump'),
        _en('Warm a small amount between your palms first; it absorbs '
            'better and the massage itself is the useful part'),
        _en('Consistency matters more than quantity. A little, every day, '
            'beats a lot once a week'),
      ]),
      BsBlock(paragraphs: [
        _en('Look for simple ingredients: cocoa or shea butter, coconut or '
            'almond oil, vitamin E. None of them are magic, and all of them '
            'do the real job well, which is keeping skin supple.'),
      ]),
    ],
    products: [bsBellyOil, bsStretchMarkCream],
  ),
  BsPage(
    id: 'sm_after_delivery',
    area: BsArea.stretchMarks,
    title: _en('Fading them after delivery'),
    videoTitle: _en('What changes after birth'),
    videoSubtitle: _en('A realistic timeline for fading'),
    videoDuration: _en('4 MIN'),
    blocks: [
      BsBlock(paragraphs: [
        _en('Marks usually start as red, purple or dark brown, depending on '
            'skin tone, because the torn fibres are still inflamed. Over 6 '
            'to 12 months they typically settle to a lighter, silvery line '
            'that is far less noticeable.'),
      ]),
      BsBlock(heading: _en('What helps the fading'), bullets: [
        _en('The same hydration routine, continued after birth'),
        _en('Gentle massage, which can improve texture even after marks '
            'have formed'),
        _en('Time. Most of the visible change happens on its own, in the '
            'first year'),
        _en('For marks that stay deep or bothersome long after birth, a '
            'dermatologist can discuss options like microneedling or '
            'laser, which are outside what a cream can do'),
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
    title: _en('The linea nigra (the dark line)'),
    videoTitle: _en('Why a line appears down your belly'),
    videoSubtitle: _en('A normal pigment line that fades after birth'),
    videoDuration: _en('2 MIN'),
    blocks: [
      BsBlock(paragraphs: [
        _en('A vertical line, usually from the belly button down, darkens '
            'as pregnancy hormones increase melanin production. It is '
            'completely normal and shows up on most pregnant bodies to some '
            'degree, more visibly on deeper skin tones.'),
        _en('It almost always fades within a few months after birth, on its '
            'own, without any treatment.'),
      ]),
    ],
  ),
  BsPage(
    id: 'pg_melasma',
    area: BsArea.pigmentation,
    title: _en('Melasma (the pregnancy mask)'),
    videoTitle: _en('The patches on the face, explained'),
    videoSubtitle: _en('Why sunscreen matters more here than anywhere else'),
    videoDuration: _en('4 MIN'),
    honestNote: _en('Sunscreen is the one change that genuinely reduces '
        'melasma. Sun exposure is what makes it darker and more stubborn.'),
    blocks: [
      BsBlock(paragraphs: [
        _en('Brownish patches on the cheeks, forehead, nose or upper lip, '
            'often called the "mask of pregnancy". Hormones are the trigger, '
            'and sunlight is what deepens it, which is why it is often worse '
            'in summer.'),
      ]),
      BsBlock(heading: _en('What helps'), bullets: [
        _en('A mineral sunscreen, reapplied through the day, even indoors '
            'near a window'),
        _en('A wide-brim hat or dupatta when out in strong Indian sun'),
        _en('Patience. Most melasma fades substantially within a year of '
            'delivery, once hormones settle'),
      ]),
    ],
    products: [bsMineralSunscreen],
  ),
  BsPage(
    id: 'pg_dark_areas',
    area: BsArea.pigmentation,
    title: _en('Darker underarms, neck and inner thighs'),
    videoTitle: _en('Why some areas darken more than others'),
    videoSubtitle: _en('The same pigment shift, showing up in skin folds'),
    videoDuration: _en('3 MIN'),
    blocks: [
      BsBlock(paragraphs: [
        _en('Skin folds where surfaces rub together, underarms, neck '
            'creases, inner thighs, tend to darken more visibly in '
            'pregnancy. It is the same hormonal pigment shift as the linea '
            'nigra, just showing up somewhere else.'),
        _en('This is not a hygiene issue and nothing to scrub at. Gentle '
            'cleansing and loose, breathable cotton clothing reduce '
            'friction, which is the only thing making it worse day to day. '
            'It fades gradually after birth.'),
      ]),
    ],
  ),
  BsPage(
    id: 'pg_acne',
    area: BsArea.pigmentation,
    title: _en('Pregnancy acne'),
    videoTitle: _en('Why breakouts return in pregnancy'),
    videoSubtitle: _en('What is safe to reach for while you wait it out'),
    videoDuration: _en('3 MIN'),
    blocks: [
      BsBlock(paragraphs: [
        _en('Rising progesterone increases oil production, so acne that you '
            'outgrew years ago can return, most often in the first and '
            'second trimester.'),
      ]),
      BsBlock(heading: _en('What to reach for'), bullets: [
        _en('A gentle, fragrance-free cleanser, twice a day'),
        _en('Niacinamide, a pregnancy-safe ingredient that calms breakouts '
            'without drying skin out'),
        _en('See what to avoid in Safe skincare, since the usual strong '
            'acne actives are exactly the ones to skip for now'),
      ]),
    ],
  ),
  BsPage(
    id: 'pg_glow',
    area: BsArea.pigmentation,
    title: _en('The pregnancy glow'),
    videoTitle: _en('The real reason for the glow'),
    videoSubtitle: _en('A real, physical cause, not just a compliment'),
    videoDuration: _en('2 MIN'),
    blocks: [
      BsBlock(paragraphs: [
        _en('It is not just a compliment, there is a real cause. Blood '
            'volume increases by up to 50% in pregnancy, which brings more '
            'circulation to the skin\'s surface. Oil glands also work '
            'harder, giving skin a naturally dewy look.'),
        _en('Not everyone gets it in the same way, and that is fine too. '
            'The glow and the breakouts often come from the very same '
            'hormones, just landing differently on different skin.'),
      ]),
    ],
  ),
  BsPage(
    id: 'pg_dry_sensitive',
    area: BsArea.pigmentation,
    title: _en('Dry or sensitive skin'),
    videoTitle: _en('Why skin reacts differently now'),
    videoSubtitle: _en('A gentler routine for skin that has changed'),
    videoDuration: _en('3 MIN'),
    blocks: [
      BsBlock(paragraphs: [
        _en('Hormonal shifts can make skin drier, thinner or more reactive '
            'than before, so a product you used for years without issue can '
            'suddenly sting or feel tight.'),
      ]),
      BsBlock(heading: _en('What helps'), bullets: [
        _en('Switch to a fragrance-free, gentle cleanser and moisturiser'),
        _en('Introduce anything new one product at a time, so you know '
            'what caused a reaction if one happens'),
        _en('Lukewarm water rather than hot, which strips natural oils '
            'faster'),
      ]),
    ],
  ),
  BsPage(
    id: 'pg_veins_tags',
    area: BsArea.pigmentation,
    title: _en('Spider veins and skin tags'),
    videoTitle: _en('Two small, harmless changes'),
    videoSubtitle: _en('What causes each, and what to do about them'),
    videoDuration: _en('3 MIN'),
    blocks: [
      BsBlock(heading: _en('Spider veins'), paragraphs: [
        _en('Fine red or bluish lines, usually on the legs or face, from '
            'increased blood volume and pressure on smaller vessels. Most '
            'fade after delivery; support stockings can ease leg heaviness '
            'in the meantime.'),
      ]),
      BsBlock(heading: _en('Skin tags'), paragraphs: [
        _en('Small, soft growths, often in the neck, underarm or under-bust '
            'folds, caused by skin rubbing skin plus hormonal changes. They '
            'are harmless and many shrink or disappear after birth; a '
            'doctor can remove any that bother you, any time.'),
      ]),
    ],
  ),
  BsPage(
    id: 'pg_hair_changes',
    area: BsArea.pigmentation,
    title: _en('Hair changes: fall and extra growth'),
    videoTitle: _en('What pregnancy does to hair'),
    videoSubtitle: _en('Why hair changes twice, once now and once after birth'),
    videoDuration: _en('3 MIN'),
    blocks: [
      BsBlock(paragraphs: [
        _en('Hormones extend hair\'s growing phase during pregnancy, so '
            'many women notice thicker, fuller hair, and less shedding than '
            'usual, through most of the nine months.'),
        _en('The shedding often catches up all at once in the months after '
            'delivery, as hair that was held onto finally lets go. This is '
            'temporary and normal, even when the amount feels alarming.'),
        _en('Some women also notice extra fine hair on the face, arms or '
            'belly, from the same hormonal shift. It usually settles within '
            'months of delivery.'),
      ]),
    ],
  ),

  // ---------------------------------------------------------------------
  //  Area 4 — Safe skincare
  // ---------------------------------------------------------------------
  BsPage(
    id: 'sk_avoid',
    area: BsArea.safeSkincare,
    title: _en('What to avoid'),
    videoTitle: _en('The ingredients to skip for now'),
    videoSubtitle: _en('And why each one is a caution, not a panic'),
    videoDuration: _en('5 MIN'),
    blocks: [
      BsBlock(bullets: [
        _en('Retinoids and retinol: linked to birth defects at high, '
            'prescription doses in studies. The risk from a skincare cream '
            'is likely small, but doctors advise skipping it since a safe '
            'alternative exists'),
        _en('High-dose or oral salicylic acid: related to aspirin, and '
            'linked to complications at high doses. A low-dose face wash '
            'is a different matter, see the safe list'),
        _en('Hydroquinone: a strong skin-lightening ingredient that '
            'absorbs into the body more than most topicals. Pregnancy is '
            'exactly the wrong time to use it, and melasma fades on its '
            'own besides'),
      ]),
      BsBlock(paragraphs: [
        _en('None of this means panic if you used one of these before you '
            'knew you were pregnant. A single earlier use is very different '
            'from ongoing use, and this is a good, calm question for your '
            'doctor rather than something to worry over alone.'),
      ]),
    ],
  ),
  BsPage(
    id: 'sk_safe',
    area: BsArea.safeSkincare,
    title: _en('What is safe'),
    videoTitle: _en('The pregnancy-safe ingredient list'),
    videoSubtitle: _en('What you can keep using without a second thought'),
    videoDuration: _en('4 MIN'),
    blocks: [
      BsBlock(bullets: [
        _en('Vitamin C, for brightening and everyday antioxidant protection'),
        _en('Niacinamide, calming and safe for acne-prone skin'),
        _en('Hyaluronic acid, a hydrator with no known pregnancy risk'),
        _en('Low-dose glycolic or lactic acid, gentle exfoliation in small '
            'amounts'),
        _en('Mineral sunscreen (zinc oxide or titanium dioxide), the single '
            'most useful daily step'),
      ]),
      BsBlock(paragraphs: [
        _en('Search any ingredient you are unsure of in the Ingredient '
            'Safety Checker for a straight answer.'),
      ]),
    ],
  ),
  BsPage(
    id: 'sk_routine',
    area: BsArea.safeSkincare,
    title: _en('A simple safe daily routine'),
    videoTitle: _en('Four steps, morning and night'),
    videoSubtitle: _en('Enough, without a ten-step routine'),
    videoDuration: _en('3 MIN'),
    blocks: [
      BsBlock(heading: _en('Morning'), bullets: [
        _en('Gentle cleanser'),
        _en('Vitamin C or niacinamide serum, optional'),
        _en('Moisturiser'),
        _en('Mineral sunscreen, every day, even indoors'),
      ]),
      BsBlock(heading: _en('Night'), bullets: [
        _en('Gentle cleanser'),
        _en('Hyaluronic acid or a plain moisturiser'),
        _en('Belly oil or cream, as part of the bump ritual'),
      ]),
      BsBlock(paragraphs: [
        _en('That is genuinely enough. Pregnancy is not the time to add a '
            'ten-step routine; it is the time to simplify to what is known '
            'to be safe.'),
      ]),
    ],
  ),
  BsPage(
    id: 'sk_facials',
    area: BsArea.safeSkincare,
    title: _en('Are facials and salon treatments okay?'),
    videoTitle: _en('What to ask for at the salon'),
    videoSubtitle: _en('Mostly yes, with a few things to skip'),
    videoDuration: _en('3 MIN'),
    blocks: [
      BsBlock(paragraphs: [
        _en('Most basic facials are fine, cleansing, gentle exfoliation, a '
            'hydrating mask and massage. Tell your salon you are pregnant '
            'before any treatment; a good one will already ask.'),
      ]),
      BsBlock(heading: _en('Ask them to skip'), bullets: [
        _en('Chemical peels with retinoids or high-dose salicylic acid'),
        _en('Strong-smelling essential oil blends, in a poorly ventilated '
            'room'),
        _en('Very hot steam or saunas, for comfort and circulation reasons '
            'more than skin ones'),
      ]),
      BsBlock(paragraphs: [
        _en('A pedicure, a basic facial or threading are all fine. If a '
            'treatment involves an ingredient you do not recognise, ask, '
            'or check it in the Ingredient Safety Checker before you say '
            'yes.'),
      ]),
    ],
  ),

  // ---------------------------------------------------------------------
  //  Area 5 — Belly care
  // ---------------------------------------------------------------------
  BsPage(
    id: 'bc_oiling',
    area: BsArea.bellyCare,
    title: _en('Belly oiling and gentle massage'),
    videoTitle: _en('The daily oiling ritual, step by step'),
    videoSubtitle: _en('An Indian tradition, and why it still holds up'),
    videoDuration: _en('4 MIN'),
    blocks: [
      BsBlock(paragraphs: [
        _en('Belly oiling has been part of Indian pregnancy care for '
            'generations, usually with warmed sesame, coconut or almond '
            'oil, massaged in slow circles by a mother, mother-in-law or '
            'the woman herself. It was never really about preventing marks; '
            'it was about touch, comfort and a few quiet minutes set aside '
            'for the baby each day.'),
      ]),
      BsBlock(heading: _en('How to do it'), bullets: [
        _en('Warm a small amount of oil between your palms'),
        _en('Massage in slow, gentle circles, moving outward from the '
            'belly button'),
        _en('Extend to the hips and lower back if someone is helping you'),
        _en('Five minutes is enough. This is a ritual, not a chore'),
      ]),
    ],
    products: [bsBellyOil],
  ),
  BsPage(
    id: 'bc_bands',
    area: BsArea.bellyCare,
    title: _en('Belly bands and support'),
    videoTitle: _en('What a belly band actually does'),
    videoSubtitle: _en('Support, not shaping, and when it tends to help'),
    videoDuration: _en('3 MIN'),
    blocks: [
      BsBlock(paragraphs: [
        _en('A belly band is a wide, stretchy support worn under or over '
            'clothes. It does not shape the bump or prevent anything; it '
            'gently supports the weight of the belly, which can ease lower '
            'back and pelvic strain later in pregnancy.'),
      ]),
      BsBlock(heading: _en('When it tends to help'), bullets: [
        _en('Long days on your feet, in the second half of pregnancy'),
        _en('Existing lower back or pelvic discomfort'),
        _en('Travel, where you are sitting or standing for stretches at a '
            'time'),
      ]),
      BsBlock(paragraphs: [
        _en('Not everyone needs one, and that is fine too. It is a comfort '
            'choice, not a medical requirement, so pick one that feels '
            'supportive without being tight.'),
      ]),
    ],
    products: [bsBellyBand],
  ),
  BsPage(
    id: 'bc_comfort',
    area: BsArea.bellyCare,
    title: _en('Comfort for the growing bump'),
    videoTitle: _en('Small changes that ease the day'),
    videoSubtitle: _en('Sleep, clothing and short walks that actually help'),
    videoDuration: _en('3 MIN'),
    blocks: [
      BsBlock(bullets: [
        _en('Sleep on your side with a pillow between your knees and one '
            'under the belly, for support without pressure'),
        _en('Loose, breathable cotton, especially in Indian summers, when '
            'skin already feels warmer and more sensitive'),
        _en('Short, frequent walks rather than long stretches of standing '
            'or sitting'),
        _en('A warm, not hot, compress for a tight or achy bump at the end '
            'of a long day'),
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
              'doctors advise skipping it since a safe alternative exists.',
          hi: 'The risk from an over-the-counter cream is likely small, but '
              'doctors advise skipping it since a safe alternative exists.'),
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
          en: 'It is the high-dose, leave-on or oral forms that carry the '
              'real caution, not this one.',
          hi: 'It is the high-dose, leave-on or oral forms that carry the '
              'real caution, not this one.'),
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
          en: 'Still worth checking with your own doctor before making it '
              'part of a daily routine.',
          hi: 'Still worth checking with your own doctor before making it '
              'part of a daily routine.'),
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
          en: 'Pregnancy melasma fades on its own after delivery in most '
              'cases, so there is little reason to take the risk now.',
          hi: 'Pregnancy melasma fades on its own after delivery in most '
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
          en: 'It is also the single change that genuinely reduces '
              'melasma, so this is worth using daily, not just when '
              'stepping out.',
          hi: 'It is also the single change that genuinely reduces '
              'melasma, so this is worth using daily, not just when '
              'stepping out.'),
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
          en: 'Calms redness and breakouts, which makes it a good stand-in '
              'for the actives you are skipping right now.',
          hi: 'Calms redness and breakouts, which makes it a good stand-in '
              'for the actives you are skipping right now.'),
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
    'Skin stretching over your bump is genuinely itchy for most women. That '
    'part is normal. There is also one warning sign worth knowing, further '
    'down this page.');

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
    _en('As skin stretches and dries out faster than usual, it is common to '
        'feel itchy on the belly, breasts and thighs, especially in the '
        'second and third trimester.'),
    _en('This kind of itching is mild, comes and goes, and usually settles '
        'with moisturiser. It is uncomfortable rather than worrying.'),
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
    _en('A plain, fragrance-free moisturiser, applied while your skin is '
        'still a little damp after a bath'),
    _en('Lukewarm water instead of hot, which dries skin out faster'),
    _en('Avoiding what irritates it: strong soaps, heavily perfumed washes, '
        'and rough synthetic fabric against the skin'),
    _en('Loose, breathable cotton clothing, especially in Indian heat'),
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
    'Intense itching, especially on the palms of your hands and soles of '
    'your feet, with no rash, can be a sign of a real complication called '
    'cholestasis of pregnancy (ICP). It affects how your liver handles bile, '
    'and it needs medical attention.');
final LocalizedText kBsItchingWarningCta = _en('See your doctor');
final LocalizedText kBsItchingWarningNote = _en(
    'Do not wait this out. If the itching is intense, worse at night, or on '
    'your palms and soles, call your doctor today rather than at your next '
    'scheduled visit.');
