// =============================================================================
//  The overlay — what the three source catalogues did not carry
// -----------------------------------------------------------------------------
//  Three things, keyed by unified product id:
//
//  1. PHOTOGRAPHS. Free-licence Unsplash photographs of the OBJECT TYPE — a
//     swaddle, a sound machine, a test strip — chosen 2026-09-17 by looking at
//     each one (a contact sheet, not a search rank). They are demo imagery for
//     a catalogue whose brands are half invented (Dozy, SnuggleSack) and half
//     real (Philips, Chicco). ⚠️ They are honest as "what this kind of thing
//     looks like" and dishonest the moment a card implies "this is the exact
//     unit you will receive". So: the product page says "Representative
//     photo" under the gallery until a real product shot replaces it, and a
//     source-file photo always sits FIRST (see `_enrich`). Never a scraped
//     brand shot presented as the product.
//
//  2. VARIANTS. Sizes and packs, with absolute prices, so the cart line
//     carries the number she saw.
//
//  3. "PARENTVEDA RECOMMENDS". The user's brief: *"this is our element, our
//     differentiation, but we are being honest and upfront."* A reason, the
//     one sentence before it, and who reviewed the call. Present on SOME
//     products only. The parenting Guides and every TTC entry already carried
//     a band; this overlay gives the pregnancy "best overall" picks theirs.
//     The reviewer names are the same seed experts the Guide data uses
//     (Dr. Anaya Rao, Dr. Vikram Sethi) plus an obstetrician for pregnancy —
//     SEED CONTENT, to be replaced by the real reviewing clinician's name.
// =============================================================================

import '../../models/pv_product.dart';

String _u(String id) =>
    'https://images.unsplash.com/photo-$id?w=900&q=80&auto=format&fit=crop';

/// Category guidance for TTC (the source file had none; the shelf needs a
/// 20-second line like the other two stages).
const Map<String, PvGuidance> kTtcCategoryGuidance = {
  'supplements': PvGuidance(
    line: 'Folic acid is the one everyone needs. Most of the rest is worth '
        'a conversation before it is worth money.',
    lookFor: ['Folic acid 400 mcg, started before trying', 'One thing at a time'],
    avoid: ['"Fertility blends" that hide the dose', 'Anything promising a result'],
  ),
  'kits': PvGuidance(
    line: 'Ovulation strips find the window; they do not open it. Cheap ones '
        'work as well as the app-connected ones.',
    lookFor: ['25+ strips a pack', 'Clear instructions on when to test'],
    avoid: ['Kits that need a subscription', 'Testing that turns into a job'],
  ),
  'tests': PvGuidance(
    line: 'Every test detects the same hormone. What differs is how early it '
        'can, and how kindly it tells you.',
    lookFor: ['Sensitivity in mIU/mL printed on the box', 'A second test in the pack'],
    avoid: ['Testing before a missed period more than once'],
  ),
  'books': PvGuidance(
    line: 'The right book here is about the waiting, not the trying.',
  ),
  'wellness': PvGuidance(
    line: 'Comfort is allowed. Just check the label says fertility-friendly.',
    lookFor: ['Sperm-friendly / fertility-friendly on the pack'],
    avoid: ['Ordinary lubricants — many slow sperm'],
  ),
};

// ---- photographs -----------------------------------------------------------

final Map<String, List<String>> kPvProductPhotos = {
  // pregnancy — pillow
  for (final id in ['pp_overall', 'pp_budget', 'pp_premium'])
    id: [_u('1673309809849-a2f6ebc4836f'), _u('1585010873004-923f9a54e54e')],
  // stretch-mark care
  for (final id in ['sc_overall', 'sc_sensitive', 'sc_budget'])
    id: [_u('1580870069867-74c57ee1bb07'), _u('1609357912334-e96886c0212b'), _u('1680987218595-2d514938a72c')],
  // maternity wear
  for (final id in ['mw_overall', 'mw_premium', 'mw_budget'])
    id: [_u('1538678867871-8a43e7487746'), _u('1568043625493-2b0633c7c491'), _u('1572531186838-27a5459566f2')],
  // belly band
  for (final id in ['bb_overall', 'bb_budget', 'bb_premium'])
    id: [_u('1585010873004-923f9a54e54e'), _u('1680987218595-2d514938a72c')],
  // compression socks
  for (final id in ['cs_overall', 'cs_budget', 'cs_premium'])
    id: [_u('1549412595-66fa1c9c893d'), _u('1746806942505-7215c07810ae')],
  // nursing bra
  for (final id in ['nb_overall', 'nb_budget', 'nb_premium'])
    id: [_u('1596770983115-7cc0f1c903a3'), _u('1576758412641-3b89a82e1043')],
  // breast pump
  for (final id in ['bp_overall', 'bp_budget', 'bp_premium'])
    id: [_u('1576758412641-3b89a82e1043'), _u('1596770983115-7cc0f1c903a3')],
  // swaddles
  for (final id in ['sw_overall', 'sw_budget', 'sw_premium'])
    id: [_u('1570035494768-b7434a1ed820'), _u('1495029987274-01d2f25dfe50'), _u('1524808533204-cda7fe65ff05')],

  // parenting — sleep
  'dozy': [_u('1587061627257-5bf894db248e'), _u('1707651020188-089db91f17fb')],
  'lull': [_u('1707651020188-089db91f17fb'), _u('1587061627257-5bf894db248e')],
  'hush': [_u('1721981036255-2f673a5cf7a5'), _u('1587061627257-5bf894db248e')],
  'cloudtunes': [_u('1760723218865-3aa70a7e49db'), _u('1707651020188-089db91f17fb')],
  'cosysuit': [_u('1582212742235-a2500f31cb39'), _u('1582212742497-86a2c4495267')],
  'merinosack': [_u('1623069485778-ca15fe447464'), _u('1586554586187-198f384b10a4')],
  'hushcurtains': [_u('1616434602533-32fcefcc3621'), _u('1571672346827-ee4040cdd7d8')],
  'snugglesack': [_u('1586554586187-198f384b10a4'), _u('1650651129774-72f8250e4393'), _u('1623069485778-ca15fe447464')],
  // skincare
  'lotion': [_u('1738892248232-a5fd26a98ec4'), _u('1738892248212-80f7d1f5fc94')],
  'rashcream': [_u('1580870069867-74c57ee1bb07'), _u('1619451334792-150fd785ee74')],
  'babywash': [_u('1537673156864-5d2c72de7824'), _u('1475178278683-8c225ae5ec3e'), _u('1609254495151-73a4c7df99ab')],
  // feeding
  'bottle': [_u('1623707430616-d9f956bcac2b'), _u('1635258559918-ed56f88004de')],
  'spoons': [_u('1544829832-c8047d6b9d89'), _u('1567201719502-255e0b3c683a')],
  'steriliser': [_u('1635258559918-ed56f88004de'), _u('1623707430616-d9f956bcac2b')],
  // play
  'playgym': [_u('1515488042361-ee00e0ddd4e4'), _u('1618842676088-c4d48a6a7c9d')],
  'clothbook': [_u('1497633762265-9d179a990aa6'), _u('1515488042361-ee00e0ddd4e4')],
  'crinkle': [_u('1545558014-8692077e9b5c'), _u('1618842676088-c4d48a6a7c9d')],
  // health & safety
  'thermometer': [_u('1594790628624-9e563bea851d'), _u('1609725236589-d987ffc8133a')],
  'cornerguard': [_u('1543346242-2b8e41fb91ca'), _u('1607322851003-f5a88dc5b960')],
  'firstaid': [_u('1624638760852-8ede1666ab07'), _u('1624638764471-cffef5035746')],
  // on the move
  'stroller': [_u('1714392512700-4cab9e51710b'), _u('1670872623744-b37e0474e3d0'), _u('1636384919179-d936e55c5cca')],
  'carrier': [_u('1685633224499-dd3759500e8f'), _u('1633379204542-430941769df3')],
  'carseat': [_u('1516309229383-2001fee59b2b'), _u('1619719287848-883c8f26efbc')],

  // TTC
  'ttc_folic': [_u('1707129785947-ddc627a8bab9'), _u('1664956618021-73c47736845e')],
  'ttc_coq10': [_u('1664956618021-73c47736845e'), _u('1732900293895-233f769299b3')],
  'ttc_myo_inositol': [_u('1732900293895-233f769299b3'), _u('1707129785947-ddc627a8bab9')],
  'ttc_zinc': [_u('1624362772755-4d5843e67047'), _u('1664956618021-73c47736845e')],
  // PR1's rule, one photo one product (2026-09-28): the blend led with
  // Folic acid's own first photo, so the two cards looked like one product.
  // It draws its mark until a photo of a blend exists. Kept for revert:
  //   'ttc_fertility_blend': [_u('1707129785947-ddc627a8bab9'), _u('1624362772755-4d5843e67047')],
  'ttc_fertility_blend': <String>[],
  // ⚠️ NO OTHER BRAND'S PRODUCT, AND NO BUMP (TTC launch walk, 2026-09-27):
  // 1647549228195 is a Clearblue test, shown on a Prega News listing, and
  // 1643659733565 is a pregnant belly on a shelf for people still trying.
  // Both leave; the unbranded card test stays. A real LH strip photo is owed.
  // Kept for revert:
  //   'ttc_lh_strips': [_u('1619183921628-9e6050dcd2e1'), _u('1647549228195-301269c33265')],
  //   'ttc_preg_test': [_u('1647549228195-301269c33265'), _u('1619183921628-9e6050dcd2e1'), _u('1643659733565-94e097cdb7e9')],
  // ⚠️ ONE PHOTO, ONE PRODUCT (launch sanity PR1, PR2, 2026-09-28). The pink
  // test cassette (1619183921628) stood for BOTH the I-CAN LH strips and the
  // Prega News test, so she could not tell the two apart; it is a test card,
  // so it stays on the pregnancy test and the strips draw their mark until a
  // real strip photo exists. The Pre-Seed listing showed The Ordinary's
  // skincare bottles (1580870069867), another brand's products; it draws its
  // mark until a real Pre-Seed photo exists. Photos owed: I-CAN ovulation
  // (LH) strips, Pre-Seed fertility-friendly lubricant. Kept for revert:
  //   'ttc_lh_strips': [_u('1619183921628-9e6050dcd2e1')],
  //   'ttc_lubricant': [_u('1580870069867-74c57ee1bb07')],
  'ttc_lh_strips': <String>[],
  'ttc_preg_test': [_u('1619183921628-9e6050dcd2e1')],
  'ttc_lubricant': <String>[],
  'ttc_thermometer': [_u('1594790628624-9e563bea851d'), _u('1609725236589-d987ffc8133a')],
  'ttc_book_impatient': [_u('1497633762265-9d179a990aa6'), _u('1495446815901-a7297e633e8d')],
};

// ---- variants + recommends -------------------------------------------------

class PvProductExtra {
  const PvProductExtra({
    this.variants,
    this.reco,
    this.reviews,
    this.experts,
    this.price,
    this.mrp,
    this.rating,
    this.reviewCount,
    this.retailer,
    this.buyUrl,
    this.soldHere,
    this.brand,
    this.expertsPct,
  });
  final List<PvVariant>? variants;
  final PvRecommend? reco;
  final List<PvParentReview>? reviews;
  final List<PvExpertVoice>? experts;
  final int? price;
  final int? mrp;
  final double? rating;
  final int? reviewCount;
  final String? retailer;
  final String? buyUrl;
  final bool? soldHere;
  final String? brand;
  final int? expertsPct;
}

const String _obgyn = 'Dr. Meera Iyer';
const String _obgynRole = 'Obstetrician · reviewed for ParentVeda';
const String _paed = 'Dr. Vikram Sethi';
const String _paedRole = 'Paediatrician · reviewed for ParentVeda';
const String _derm = 'Dr. Anaya Rao';
const String _dermRole = 'Dermatologist · reviewed for ParentVeda';

List<PvVariant> _sizes(String base, int price) => [
      PvVariant(id: '${base}_s', label: 'S', price: price),
      PvVariant(id: '${base}_m', label: 'M', price: price),
      PvVariant(id: '${base}_l', label: 'L', price: price),
      PvVariant(id: '${base}_xl', label: 'XL', price: price + 100),
    ];

List<PvVariant> _ages(String base, int price) => [
      PvVariant(id: '${base}_0_3', label: '0–3 m', price: price),
      PvVariant(id: '${base}_3_6', label: '3–6 m', price: price),
      PvVariant(id: '${base}_6_9', label: '6–9 m', price: price + 50),
      PvVariant(id: '${base}_9_12', label: '9–12 m', price: price + 50),
    ];

final Map<String, PvProductExtra> kPvProductExtras = {
  // ---- pregnancy: the "best overall" picks get the ParentVeda mark --------
  'pp_overall': const PvProductExtra(
    mrp: 2999,
    rating: 4.6,
    reviewCount: 312,
    reco: PvRecommend(
      band: PvRecoBand.strong,
      reason: 'Supports bump, back and knees at the same time, and holds its '
          'shape past the third trimester — which is where cheaper pillows '
          'give up. The cover comes off and survives a hot wash.',
      beforeYouBuy: 'A firm ordinary pillow between the knees does most of '
          'this job until about week 24. Buy this when that stops working.',
      reviewerName: _obgyn,
      reviewerRole: _obgynRole,
    ),
  ),
  'pp_budget': const PvProductExtra(mrp: 1299, rating: 4.3, reviewCount: 148),
  'pp_premium': const PvProductExtra(mrp: 4999, rating: 4.7, reviewCount: 86),
  'sc_overall': PvProductExtra(
    mrp: 799,
    rating: 4.5,
    reviewCount: 540,
    variants: const [
      PvVariant(id: 'sc_overall_100', label: '100 ml', price: 649),
      PvVariant(id: 'sc_overall_200', label: '200 ml', price: 1099),
    ],
    reco: const PvRecommend(
      band: PvRecoBand.buy,
      reason: 'No cream prevents stretch marks — genetics decide that. This '
          'one earns its place by being fragrance-free and non-sticky, so '
          'you will actually use it daily, and daily is what helps the itch.',
      beforeYouBuy: 'Any plain moisturiser applied every day does most of '
          'this. Pay for this if the itching is real and the plain one is '
          'not staying on.',
      reviewerName: _derm,
      reviewerRole: _dermRole,
    ),
  ),
  'sc_sensitive': const PvProductExtra(mrp: 899, rating: 4.4, reviewCount: 201),
  'sc_budget': const PvProductExtra(mrp: 349, rating: 4.2, reviewCount: 388),
  'mw_overall': PvProductExtra(
    mrp: 1899,
    rating: 4.5,
    reviewCount: 264,
    variants: _sizes('mw_overall', 1499),
    reco: const PvRecommend(
      band: PvRecoBand.buy,
      reason: 'Over-bump cotton with a nursing opening, so it is still in use '
          'six months after the birth. That second life is what makes the '
          'price fair.',
      beforeYouBuy: 'Your own loose kurtas will carry you to week 20 or so. '
          'Buy maternity wear when the waistband starts to matter.',
      reviewerName: _obgyn,
      reviewerRole: _obgynRole,
    ),
  ),
  'mw_premium': PvProductExtra(mrp: 3299, rating: 4.6, reviewCount: 92, variants: _sizes('mw_premium', 2799)),
  'mw_budget': PvProductExtra(mrp: 999, rating: 4.1, reviewCount: 410, variants: _sizes('mw_budget', 799)),
  'bb_overall': PvProductExtra(
    mrp: 1499,
    rating: 4.4,
    reviewCount: 177,
    variants: _sizes('bb_overall', 1199),
    reco: const PvRecommend(
      band: PvRecoBand.consider,
      reason: 'Eases lower-back and pelvic strain for many women after week '
          '24, especially on their feet all day. Worth trying; not for '
          'everyone.',
      beforeYouBuy: 'If your back is fine, you do not need this. If it is not, '
          'ask your doctor about pelvic girdle pain before buying a band.',
      reviewerName: _obgyn,
      reviewerRole: _obgynRole,
    ),
  ),
  'bb_budget': PvProductExtra(mrp: 799, rating: 4.1, reviewCount: 230, variants: _sizes('bb_budget', 599)),
  'bb_premium': PvProductExtra(mrp: 2799, rating: 4.6, reviewCount: 64, variants: _sizes('bb_premium', 2299)),
  'cs_overall': PvProductExtra(
    mrp: 999,
    rating: 4.5,
    reviewCount: 315,
    variants: _sizes('cs_overall', 749),
    reco: const PvRecommend(
      band: PvRecoBand.buy,
      reason: 'Graduated compression genuinely reduces evening swelling and '
          'the tired-leg ache of later pregnancy. Cheap and well evidenced.',
      beforeYouBuy: 'Sudden swelling in one leg, or swelling with a headache, '
          'is a call to your doctor, not a sock.',
      reviewerName: _obgyn,
      reviewerRole: _obgynRole,
    ),
  ),
  'cs_budget': PvProductExtra(mrp: 499, rating: 4.2, reviewCount: 402, variants: _sizes('cs_budget', 349)),
  'cs_premium': PvProductExtra(mrp: 1799, rating: 4.6, reviewCount: 88, variants: _sizes('cs_premium', 1499)),
  'nb_overall': PvProductExtra(
    mrp: 1299,
    rating: 4.5,
    reviewCount: 522,
    variants: _sizes('nb_overall', 999),
    reco: const PvRecommend(
      band: PvRecoBand.buy,
      reason: 'Wire-free, one-hand clips, and it holds up after the weekly '
          'wash. Get fitted late in the third trimester — your size will '
          'change again after the milk comes in.',
      beforeYouBuy: 'Buy two, not five. Sizing settles about six weeks after '
          'the birth.',
      reviewerName: _obgyn,
      reviewerRole: _obgynRole,
    ),
  ),
  'nb_budget': PvProductExtra(mrp: 699, rating: 4.2, reviewCount: 611, variants: _sizes('nb_budget', 549)),
  'nb_premium': PvProductExtra(mrp: 2499, rating: 4.7, reviewCount: 143, variants: _sizes('nb_premium', 1999)),
  'bp_overall': const PvProductExtra(
    mrp: 8999,
    rating: 4.6,
    reviewCount: 388,
    reco: PvRecommend(
      band: PvRecoBand.consider,
      reason: 'A good electric pump matters if you are returning to work or '
          'building a stash. For a mother at home with a feeding baby, a '
          'manual pump does the job at a tenth of the price.',
      beforeYouBuy: 'Decide after the birth, not before. Many mothers never '
          'need one; the ones who do, need a good one.',
      reviewerName: _obgyn,
      reviewerRole: _obgynRole,
    ),
  ),
  'bp_budget': const PvProductExtra(mrp: 1499, rating: 4.3, reviewCount: 704),
  'bp_premium': const PvProductExtra(mrp: 24999, rating: 4.8, reviewCount: 96),
  'sw_overall': const PvProductExtra(
    mrp: 1499,
    rating: 4.7,
    reviewCount: 458,
    variants: [
      PvVariant(id: 'sw_overall_2', label: 'Pack of 2', price: 1199),
      PvVariant(id: 'sw_overall_3', label: 'Pack of 3', price: 1649),
    ],
    reco: PvRecommend(
      band: PvRecoBand.strong,
      reason: 'Breathable muslin that gets softer with every wash, big enough '
          'to swaddle properly and light enough for an Indian summer. It '
          'becomes a burp cloth, a shade and a blanket for two years.',
      beforeYouBuy: 'Stop swaddling the moment your baby shows signs of '
          'rolling — usually around eight weeks.',
      reviewerName: _paed,
      reviewerRole: _paedRole,
    ),
  ),
  'sw_budget': const PvProductExtra(mrp: 699, rating: 4.3, reviewCount: 522),
  'sw_premium': const PvProductExtra(mrp: 2999, rating: 4.7, reviewCount: 119),

  // ---- parenting: variants; recommends come from the Guides ----------------
  'dozy': const PvProductExtra(
    mrp: 1999,
    reco: PvRecommend(
      band: PvRecoBand.buy,
      reason: 'True continuous white noise, an auto-off timer, and a volume '
          'you can keep at soft-shower level. It masks a joint-family '
          'household without becoming a habit the baby cannot sleep without.',
      beforeYouBuy: 'A fan or a phone playing brown noise works for many '
          'babies. Buy a machine when the phone becomes a problem.',
      reviewerName: _paed,
      reviewerRole: _paedRole,
    ),
  ),
  'lull': const PvProductExtra(mrp: 1499),
  'cosysuit': PvProductExtra(variants: _ages('cosysuit', 599)),
  'merinosack': PvProductExtra(variants: _ages('merinosack', 2499)),
  'snugglesack': PvProductExtra(variants: _ages('snugglesack', 1299)),
  'lotion': const PvProductExtra(variants: [
    PvVariant(id: 'lotion_200', label: '200 ml', price: 349),
    PvVariant(id: 'lotion_400', label: '400 ml', price: 599),
  ]),
  'rashcream': const PvProductExtra(variants: [
    PvVariant(id: 'rashcream_50', label: '50 g', price: 249),
    PvVariant(id: 'rashcream_100', label: '100 g', price: 429),
  ]),
  'babywash': const PvProductExtra(variants: [
    PvVariant(id: 'babywash_200', label: '200 ml', price: 299),
    PvVariant(id: 'babywash_400', label: '400 ml', price: 499),
  ]),
  'bottle': const PvProductExtra(
    variants: [
      PvVariant(id: 'bottle_150', label: '150 ml', price: 449),
      PvVariant(id: 'bottle_260', label: '260 ml', price: 549),
      PvVariant(id: 'bottle_twin', label: 'Twin pack · 260 ml', price: 949),
    ],
  ),
  'stroller': const PvProductExtra(
    mrp: 9999,
    reco: PvRecommend(
      band: PvRecoBand.buy,
      reason: 'Under six kilos, folds with one hand, and the seat reclines '
          'flat enough for a newborn nap. For Indian pavements and auto '
          'boots, weight and fold matter more than suspension.',
      beforeYouBuy: 'If you mostly carry your baby, a carrier is the better '
          'first purchase. Buy the stroller when your back says so.',
      reviewerName: _paed,
      reviewerRole: _paedRole,
    ),
  ),
  'carrier': const PvProductExtra(
    mrp: 7499,
    reco: PvRecommend(
      band: PvRecoBand.strong,
      reason: 'Hip-healthy M-position seat, padded shoulder straps, and it '
          'goes from newborn to toddler without an insert. The one gear '
          'purchase almost every parent uses daily.',
      beforeYouBuy: 'Check the baby\'s face is always visible and kissable — '
          'the T.I.C.K.S. rules apply to every carrier.',
      reviewerName: _paed,
      reviewerRole: _paedRole,
    ),
  ),
  'carseat': const PvProductExtra(
    mrp: 12999,
    reco: PvRecommend(
      band: PvRecoBand.strong,
      reason: 'Rear-facing with a five-point harness and a proper ISOFIX '
          'base. A car seat is the one product where the cheapest option '
          'is the wrong one; this is the least you should buy.',
      beforeYouBuy: 'A car seat only works fitted correctly. Get the fitting '
          'checked before the first drive home.',
      reviewerName: _paed,
      reviewerRole: _paedRole,
    ),
  ),
  'thermometer': const PvProductExtra(
    reco: PvRecommend(
      band: PvRecoBand.buy,
      reason: 'A forehead reading in two seconds on a sleeping baby is what '
          'a parent needs at 3 am. Accurate enough to decide whether to '
          'call; a doctor will confirm with their own.',
      beforeYouBuy: 'Under three months, any fever is a same-day call to the '
          'doctor — the thermometer tells you to go, not what to do.',
      reviewerName: _paed,
      reviewerRole: _paedRole,
    ),
  ),

  // ---- TTC: variants for the two things people actually buy in packs -------
  'ttc_folic': PvProductExtra(
    variants: const [
      PvVariant(id: 'ttc_folic_30', label: '30 tablets', price: 95),
      PvVariant(id: 'ttc_folic_90', label: '90 tablets', price: 249),
    ],
    experts: const [
      PvExpertVoice(
        name: _obgyn,
        role: 'Obstetrician',
        quote: 'The neural tube closes by day 28 — before most women know '
            'they are pregnant. That is why folic acid starts before, not '
            'after, the positive test.',
      ),
    ],
  ),
  'ttc_lh_strips': const PvProductExtra(variants: [
    PvVariant(id: 'ttc_lh_25', label: '25 strips', price: 299),
    PvVariant(id: 'ttc_lh_50', label: '50 strips', price: 499),
  ]),
  'ttc_preg_test': const PvProductExtra(variants: [
    PvVariant(id: 'ttc_pt_1', label: 'Single', price: 55),
    PvVariant(id: 'ttc_pt_3', label: 'Pack of 3', price: 149),
  ]),
};
