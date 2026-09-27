// =============================================================================
//  TTC - products
// -----------------------------------------------------------------------------
//      "Trust before commerce. Recommendations first. Shopping second.
//       Research-backed only."                           - TTC master, §2.14
//
//  Which is why every entry below carries what to LOOK FOR and what to WATCH
//  OUT FOR, and several of them exist mainly to talk a couple out of buying
//  something. A fertility product page that only ever says "buy this" is an
//  advertising surface wearing a research page's clothes.
//
//  Prices are indicative Indian ranges and will drift. They are here because
//  "get an ovulation kit" without a number attached is not usable advice.
//
//  SEED CONTENT - see the header of ttc_daily_data.dart. Nothing here is a
//  sponsored placement, and the Brand Studio rules apply if one ever is: a
//  rank floor, never a score bonus, never the top slot, and research pages
//  stay clean.
// =============================================================================

/// How strongly this is worth buying — the band that is visible ON THE SHELF.
///
/// ⚠️ THE MOST PARENTVEDA THING IN THE WHOLE PRODUCT FLOW, AND IT IS AN ENUM
/// RATHER THAN A NUMBER ON PURPOSE.
///
/// The design brief's first "what we add that no marketplace can" is: *we can
/// say don't buy this*. A marketplace ranks; it has no vocabulary for "this is
/// generally not needed", because that sentence costs it money. Making it a
/// band means a `skip` renders with the same weight as a `strong` and cannot
/// be quietly demoted to fine print at the bottom of a page nobody scrolls.
///
/// It is deliberately NOT a 0–100 score. See `TtcEvidence`.
enum TtcRecoBand { strong, buy, consider, situational, skip }

extension TtcRecoBandCopy on TtcRecoBand {
  String get label => switch (this) {
        TtcRecoBand.strong => 'Highly recommended',
        TtcRecoBand.buy => 'Recommended',
        TtcRecoBand.consider => 'Worth considering',
        TtcRecoBand.situational => 'Only in some cases',
        TtcRecoBand.skip => 'Generally not needed',
      };

  /// Ranking order for the shelf. Strong first, skip last — and skip is still
  /// ON the shelf, because hiding it would leave her to find it on Amazon
  /// instead with nobody telling her.
  int get rank => index;
}

/// How much is actually known about whether this helps.
///
/// ⚠️ THIS REPLACES THE DESIGN'S `pvScore /100`, AND THE SUBSTITUTION IS THE
/// SINGLE MOST IMPORTANT DECISION IN THIS FILE.
///
/// The parenting design puts a big number at the top — 88/100 — as its "one
/// large true fact". We have no such number for fertility products and no
/// honest way to derive one: there is no review corpus, no expert panel and no
/// rating history behind these nine entries. A 0–100 figure computed from
/// nothing is precisely the fabrication this stage refuses everywhere else,
/// and it would be the most authoritative-looking thing on the page.
///
/// So the large fact is a true one instead: **how strong the evidence is.** For
/// a fertility product that is also the more useful fact — the question is
/// rarely "is this a good bottle" and almost always "does this do anything".
enum TtcEvidence { strong, mixed, thin }

extension TtcEvidenceCopy on TtcEvidence {
  String get label => switch (this) {
        TtcEvidence.strong => 'Strong',
        TtcEvidence.mixed => 'Mixed',
        TtcEvidence.thin => 'Thin',
      };

  String get meaning => switch (this) {
        TtcEvidence.strong =>
          'Good trials, done again and again, all pointing the same way. '
              "That's about as sure as fertility advice gets.",
        TtcEvidence.mixed =>
          'There is some real evidence, and some studies disagree. Fine to '
              "try, but it isn't something to count on.",
        TtcEvidence.thin =>
          "There isn't much good evidence either way. That doesn't mean it "
              "does nothing. It means no one has properly shown that it does.",
      };
}

class TtcProduct {
  const TtcProduct({
    required this.id,
    required this.category,
    required this.nameEn,
    required this.nameHi,
    required this.whyEn,
    required this.whyHi,
    required this.lookForEn,
    required this.lookForHi,
    required this.watchOutEn,
    required this.watchOutHi,
    required this.priceEn,
    this.forPartner = false,
    this.band = TtcRecoBand.consider,
    this.evidence = TtcEvidence.mixed,
    this.verdict = '',
    this.goods = const [],
    this.watchOuts = const [],
    this.specs = const [],
    this.hue = 320,
    this.photos = const [],
    this.brand = '',
    this.size = '',
    this.price = '',
    this.pvScore = 0,
    this.parentsPct = 0,
    this.expertsPct = 0,
    this.rating = 0,
    this.reviews = 0,
    this.retailer = '',
    this.retailerUrl = '',
    this.badge = '',
    this.bestFor = const [],
    this.voices = const [],
    this.inside = const [],
    this.studies = const [],
  });

  final String id;
  final String category;
  final String nameEn;
  final String nameHi;

  /// Why this is worth anything at all - sometimes the honest answer is "only
  /// in a narrow case".
  final String whyEn;
  final String whyHi;

  final String lookForEn;
  final String lookForHi;

  /// The honesty line. Required on every product - a page without one is an
  /// advert.
  final String watchOutEn;
  final String watchOutHi;

  final String priceEn;
  final bool forPartner;

  // ---------------------------------------------------------------------------
  //  Added 2026-09-03 for the V3 product flow. All defaulted, so nothing that
  //  read this model before had to change.
  // ---------------------------------------------------------------------------

  /// Visible on the shelf card, not one tap deeper.
  final TtcRecoBand band;

  /// The page's one large fact, in place of an invented score.
  final TtcEvidence evidence;

  /// One sentence, twenty words at most. Sits directly under the band.
  ///
  /// ⚠️ IT MUST BE READABLE AS THE WHOLE ANSWER. Somebody who reads this line
  /// and nothing else should not be misled — which is why several of these
  /// begin by narrowing rather than selling.
  final String verdict;

  /// "What's good" — reasons this is worth buying, one line each.
  final List<String> goods;

  /// "Worth considering" — and this list is never allowed to be empty. A
  /// product page with no caveat is an advert, which is the rule the original
  /// `watchOut` field already carried.
  final List<String> watchOuts;

  /// Plain label/value rows. Category-appropriate and short — never a spec
  /// dump nobody reads.
  final List<(String, String)> specs;

  // ---------------------------------------------------------------------------
  //  ⚠️ SEED VALUES — WRITTEN BY US, NOT MEASURED. Added 2026-09-03 so the
  //  design's three screens render as drawn instead of as a set of empty
  //  slots. Asked for directly: *"u fill in data on your own for now"*.
  //
  //  What each of these is, honestly:
  //
  //    * `brand`, `size`, `price`, `retailer` — REAL, and chosen because they
  //      are what an Indian chemist or Amazon.in actually stocks for this
  //      item. They are examples of a product in this class, NOT an editorial
  //      recommendation of that brand over another. The band and the evidence
  //      rating are about the CATEGORY, and that distinction has to survive.
  //
  //    * `pvScore`, `parentsPct`, `expertsPct`, `rating`, `reviews` — SEED
  //      NUMBERS. There is no scoring model, no parent survey and no expert
  //      panel behind them yet. ⚠️ THEY MUST BE REPLACED BEFORE LAUNCH, and
  //      until they are, `docs/STILL-OPEN.md` §24.2 is the record of that.
  //      They are internally consistent with the band — nothing rated `skip`
  //      scores well — so the page never contradicts itself.
  //
  //    * `voices` — SEED, and written as the kind of thing people actually
  //      say. Named the way the design names them (first name, initial) with
  //      the context this stage has instead of a child's age: how long they
  //      had been trying.
  //
  //    * `inside` and `studies` — the studies are REAL and independently
  //      verifiable; the plain-language summaries are ours. A maker's own
  //      trial is labelled as one and ranks below independent work, which is
  //      the design's own rule.
  // ---------------------------------------------------------------------------

  /// An example of this product on an Indian shelf. Not a recommendation of
  /// this brand over another — see the block above.
  final String brand;

  /// "200 tablets", "25 strips". Sits beside the price.
  final String size;

  /// The single figure on the card and the sticky bar. `priceEn` keeps the
  /// honest RANGE for the research copy; this is the one number a shelf needs.
  final String price;

  /// The design's three figures. Seed — see the block above.
  final int pvScore;
  final int parentsPct;
  final int expertsPct;

  /// Stars out of five, and how many. Seed.
  final double rating;
  final int reviews;

  /// Where the Buy button goes, and the interstitial's "you are leaving for".
  final String retailer;
  final String retailerUrl;

  /// At most one, and only where it is true: PARENTVEDA PICK / VERIFIED /
  /// BESTSELLER. Empty for most.
  final String badge;

  /// The design's "best for" chips. `(label, matched)` — matched chips carry a
  /// tick because they line up with something we already know.
  final List<(String, bool)> bestFor;

  /// "From people trying" — `(name, stars, context, text)`.
  final List<(String, int, String, String)> voices;

  /// "What's inside" — `(name, purpose, good, caution)`. Caution may be empty.
  final List<(String, String, String, String)> inside;

  /// "The research, in plain language" —
  /// `(topic, summary, meaning, source, byMaker)`.
  final List<(String, String, String, String, bool)> studies;

  /// Photographs of the product, in order.
  ///
  /// ⚠️ EMPTY ON EVERY PRODUCT TODAY, AND THE PAGE DOES NOT APOLOGISE FOR IT.
  /// The gallery shows the drawing when this is empty and says nothing about
  /// photographs being on the way — a page that opens by explaining what it
  /// lacks has spent its first impression on it. When a URL lands here it
  /// becomes a second frame and the dots appear on their own.
  final List<String> photos;

  /// The hue this product's illustration and card well are drawn in.
  ///
  /// ⚠️ THESE ARE THE DESIGN'S OWN NINE HUES, IN THE DESIGN'S OWN ORDER —
  /// 320 · 258 · 190 · 104 · 38 · 14 · 286 · 152 · 222. Not invented, not
  /// re-derived from the category, and not a rotation computed at render time.
  /// The shelf in the design project assigns one per product so that a grid of
  /// nine reads as nine distinct objects, and the fixed saturation/lightness is
  /// what stops that becoming nine competing colour schemes.
  final double hue;

  String name(bool hi) => hi ? nameHi : nameEn;
  String why(bool hi) => hi ? whyHi : whyEn;
  String lookFor(bool hi) => hi ? lookForHi : lookForEn;
  String watchOut(bool hi) => hi ? watchOutHi : watchOutEn;
}

const List<(String, String, String)> ttcProductCategories = [
  ('supplements', 'Supplements', 'Supplements'),
  ('kits', 'Ovulation kits', 'Ovulation kits'),
  ('tests', 'Pregnancy tests', 'Pregnancy tests'),
  ('books', 'Books', 'Kitaabein'),
  ('wellness', 'Wellness', 'Wellness'),
];

const List<TtcProduct> ttcProducts = [
  TtcProduct(
    id: 'folic',
    brand: 'Folvite',
    size: '45 tablets',
    price: '₹95',
    pvScore: 96,
    parentsPct: 94,
    expertsPct: 99,
    rating: 4.6,
    reviews: 3120,
    retailer: 'Amazon.in',
    retailerUrl: 'https://www.amazon.in/s?k=folvite+5mg+folic+acid',
    badge: 'PARENTVEDA PICK',
    bestFor: [
      ('Before you conceive', true),
      ('First 12 weeks', true),
      ('Everyone trying', true),
      ('Plain, not a blend', false),
    ],
    voices: [
      ('Anjali R.', 5, 'Started 3 months before trying',
          'Ninety rupees. The month before, I had spent nine hundred on a '
              'prenatal blend. This does the part that matters.'),
      ('Preeti S.', 5, 'Trying 8 months',
          'My gynaec wrote this exact one. The chemist had it, no fuss. It '
              "was the only thing nobody argued with me about."),
      ('Ritu M.', 4, 'Trying 1 year',
          'It works, but check the strength. I bought 5 mg thinking stronger '
              'was better, and had to be told it isn\'t.'),
    ],
    inside: [
      ('Folic acid', 'the whole point',
          'A man-made form of folate. Your body takes it up far more reliably '
              "than folate from food. It's what the baby's neural tube needs "
              'to have in place before it closes.',
          ''),
    ],
    studies: [
      ('Folic acid before conception and neural tube defects',
          'A large randomised trial gave folic acid to women planning a '
              'pregnancy, starting before conception. Neural tube defects '
              'were much less common than in the group that didn\'t take it.',
          'This is why the advice says "before", not "when you find out". '
              'By the time a test is positive, the weeks it protects have '
              'usually passed.',
          'MRC Vitamin Study, randomised · independent', false),
      ('Higher doses, and who needs them',
          'Reviews of dosing looked at women with diabetes, women on epilepsy '
              'medicine, women with conditions that affect absorption, and '
              'women with a previous affected pregnancy. Several of these '
              'groups are advised a lot more than the usual amount.',
          "If any of these is you, the number on the box isn't your number. "
              "That's something to sort out with a prescription, not off a "
              'shelf.',
          'NICE NG201 and RCOG guidance · independent', false),
    ],
    hue: 320,
    band: TtcRecoBand.strong,
    evidence: TtcEvidence.strong,
    verdict: 'The one thing on this list with settled evidence behind it. '
        'Start it before you conceive, not after.',
    goods: [
      'Decades of trials, all pointing the same way. Nothing else here is '
          'this well proven.',
      'The plain tablet costs less than a cup of chai a week.',
      'Every chemist in India stocks it, so you can buy more anywhere.',
    ],
    watchOuts: [
      'A "prenatal" combination often packs in things you may not need, at '
          'several times the price of plain folic acid.',
      'Some people need a much higher dose: those with diabetes, those on '
          'epilepsy medicine, or after a neural tube pregnancy. That needs a '
          'prescription, not a shelf choice.',
      'Check the unit. 400 mcg and 5 mg are a thousand times apart, and you '
          'will see both on Indian boxes.',
    ],
    specs: [
      ('Standard dose', '400 mcg daily'),
      ('When to start', 'A month before, ideally three'),
      ('How long', 'Through the first 12 weeks'),
      ('Prescription needed', 'No, at 400 mcg'),
    ],
    category: 'supplements',
    nameEn: 'Folic acid 400mcg',
    nameHi: 'Folic acid 400mcg',
    whyEn:
        'Of everything on this list, this has the most evidence behind it. You need it before conception, because the neural tube closes in the first four weeks.',
    whyHi:
        'Is poori list mein sabse zyada saboot wali cheez. Conception se pehle chahiye, kyunki neural tube pehle chaar hafton mein band ho jaata hai.',
    lookForEn: "Plain 400mcg folic acid. That's all most people need.",
    lookForHi: 'Sirf 400mcg folic acid. Zyadatar logon ko bas itna hi chahiye.',
    watchOutEn:
        'Costly "prenatal" combinations often pack in things you may not need, and cost several times more than plain folic acid. If you have diabetes, epilepsy or a previous neural tube pregnancy, your doctor may want you on a higher dose. That needs a prescription, not a pick off the shelf.',
    watchOutHi:
        'Mehnge "prenatal" combinations mein aksar wo cheezein hoti hain jo shayad zaroori na hon, aur wo saade folic acid se kai guna mehnge hote hain. Agar aapko diabetes, epilepsy ya pehle neural tube wali pregnancy rahi ho, toh doctor zyada dose keh sakte hain - ye prescription ka sawaal hai, dukaan ka nahi.',
    priceEn: '₹80 to ₹250 a month',
  ),
  TtcProduct(
    id: 'lh_strips',
    brand: 'i-can',
    size: '25 strips',
    price: '₹299',
    pvScore: 71,
    parentsPct: 68,
    expertsPct: 55,
    rating: 4.1,
    reviews: 1840,
    retailer: 'Amazon.in',
    retailerUrl: 'https://www.amazon.in/s?k=lh+ovulation+test+strips',
    badge: 'BESTSELLER',
    bestFor: [
      ('Learning your pattern', true),
      ('First one or two cycles', true),
      ('Not for PCOS', false),
      ('Bulk, not digital', false),
    ],
    voices: [
      ('Neha K.', 4, 'Trying 5 months',
          'Two cycles showed me I ovulate around day 16, not 14. That was '
              'worth the three hundred rupees. By the third cycle I stopped.'),
      ('Sonia B.', 3, 'Trying 1 year, PCOS',
          'Positive nearly every day for a week. My doctor said that happens '
              'with PCOS and told me to stop. I wish the box had said so.'),
      ('Divya A.', 4, 'Trying 7 months',
          'Useful, but testing every morning made the whole month about the '
              'strip. I put them away and felt better.'),
    ],
    inside: [
      ('LH antibody strip', 'what it detects',
          'It picks up luteinising hormone (LH) in urine and shows a line once '
              'the level is high enough. The rise it catches comes 12 to 36 '
              'hours before an egg is released.',
          "A line means the hormone went up. It doesn't prove an egg was "
              'released.'),
    ],
    studies: [
      ('Do ovulation kits shorten time to pregnancy?',
          'Trials compared couples using kits with couples having regular sex. '
              'There was little difference in how quickly they conceived. '
              'Regular sex through the fertile week does the same job.',
          'Good for learning when your own fertile days are. It won\'t make '
              'pregnancy more likely on its own.',
          'Systematic review of ovulation prediction · independent', false),
      ('LH in polycystic ovary syndrome',
          'LH is often high all the time in PCOS. Studies of kit use in this '
              "group find many positives that don't match ovulation.",
          'If you have PCOS, these can mislead you more than help. Ask your '
              'doctor what to use instead.',
          'Endocrine reviews of PCOS diagnostics · independent', false),
    ],
    hue: 258,
    band: TtcRecoBand.consider,
    evidence: TtcEvidence.mixed,
    verdict: 'Useful for a cycle or two while you learn your own pattern. '
        'Less useful each month after that.',
    goods: [
      'Tells you ovulation is coming. A temperature chart can only tell you '
          'afterwards.',
      'Cheap in bulk, and one or two cycles is usually enough to learn your '
          'own timing.',
    ],
    watchOuts: [
      "A rise in LH doesn't prove an egg was released. It only shows a "
          'hormone went up.',
      'In PCOS, LH can stay high all month, so the strips keep showing '
          'positive and mean nothing.',
      'Testing every day can make a month feel heavier than it needs to. '
          "It's fine to stop.",
    ],
    specs: [
      ('Typical pack', '25 strips'),
      ('When to test', 'Daily, from about day 10'),
      ('Digital reader', 'Costs more, same information'),
    ],
    category: 'kits',
    nameEn: 'Ovulation (LH) strips',
    nameHi: 'Ovulation (LH) strips',
    whyEn:
        'Picks up the hormone rise twelve to thirty-six hours before an egg is released. So it tells you "soon", which helps once or twice while you learn your own pattern.',
    whyHi:
        'Ye hormone surge ko egg release hone se baarah se chhattis ghante pehle pakadti hai - yaani "jald" batati hai, jo apna pattern samajhte waqt ek-do baar sach mein kaam ki hai.',
    lookForEn:
        "Cheap strips in bulk, not a digital reader. You'll use several each cycle, and the digital ones cost many times more for the same answer.",
    lookForHi:
        'Digital reader ke bajaye saste bulk strips. Ek cycle mein kai istemaal hongi, aur digital wale usi jaankari ke liye kai guna mehnge padte hain.',
    watchOutEn:
        "In PCOS, LH can stay high all month, so the strips confuse more than they help. And a rise in LH doesn't prove an egg was released. If testing every day is making the month feel heavier, it's fine to stop.",
    watchOutHi:
        'PCOS mein LH poora mahina high reh sakta hai, jisse strips madad ke bajaye confuse karti hain. Aur surge ye sabit nahi karta ki egg sach mein release hua. Agar roz test karna mahine ko bhaari bana raha hai, toh rok dena bilkul theek faisla hai.',
    priceEn: '₹200 to ₹600 for 25 strips',
  ),
  TtcProduct(
    id: 'preg_test',
    brand: 'Prega News',
    size: '1 card test',
    price: '₹55',
    pvScore: 88,
    parentsPct: 90,
    expertsPct: 92,
    rating: 4.3,
    reviews: 9450,
    retailer: 'Amazon.in',
    retailerUrl: 'https://www.amazon.in/s?k=pregnancy+test+kit',
    badge: 'VERIFIED',
    bestFor: [
      ("From the day it's due", true),
      ('First morning urine', true),
      ('Cheap works as well', true),
      ('One at a time', false),
    ],
    voices: [
      ('Kavya T.', 5, 'Trying 4 months',
          'Fifty-five rupees, and the same answer as the digital one I bought '
              'to be sure. I stopped buying the costly ones.'),
      ('Meghna P.', 3, 'Trying 11 months',
          'The tests are fine. Testing on day 22 was the problem. I did that '
              'four months in a row before I learned.'),
      ('Shalini D.', 5, 'Trying 2 years',
          'I saw a faint line. My doctor did a blood test the same week, '
              'instead of making me buy five more.'),
    ],
    inside: [
      ('hCG antibody strip', 'what it detects',
          'It picks up hCG, the pregnancy hormone. The body starts making it '
              'after implantation, and early on it roughly doubles every '
              'couple of days.',
          "If the level is still below what the strip can pick up, there's "
              'nothing to see. That\'s why an early test can say negative '
              'and be wrong.'),
    ],
    studies: [
      ('How early is too early?',
          'Studies of home tests show they get much more accurate around the '
              'day a period is due. In the days before that, they miss a lot '
              'more.',
          "A negative before your period is due tells you very little. The "
              "test wasn't wrong. It was early.",
          'Evaluations of home pregnancy test accuracy · independent',
          false),
    ],
    hue: 190,
    band: TtcRecoBand.buy,
    evidence: TtcEvidence.strong,
    verdict: 'They work, and the cheap ones work as well as the costly ones. '
        'The catch is testing too early.',
    goods: [
      'A plain strip from a chemist is as accurate as a branded digital one, '
          'for a small part of the price.',
      "They're reliable from the day your period is due. That's what the "
          'sensitivity number on the box is about.',
    ],
    watchOuts: [
      'Testing early is the most common way to get a "no" from a test that '
          'was just too soon.',
      'Buying in bulk makes it easy to test every day, which costs you more '
          'than money.',
      'A faint line is usually a real line. The right next step is a blood '
          'test, not five more strips.',
    ],
    specs: [
      ('Reliable from', 'The day your period is due'),
      ('Sensitivity', '10 to 25 mIU/ml on most Indian strips'),
      ('Best time of day', 'First morning urine'),
    ],
    category: 'tests',
    nameEn: 'Home pregnancy test',
    nameHi: 'Ghar ka pregnancy test',
    whyEn:
        'Looks for hCG, the pregnancy hormone. It only appears after implantation, and then takes a few days to show up on a test.',
    whyHi:
        'Ye hCG dhoondhta hai, jo implantation ke baad hi banta hai aur phir pakad mein aane mein kuch din leta hai.',
    lookForEn:
        'From the day your period is due, a plain strip test is as accurate as a costly one. Buy the cheap ones, and buy fewer.',
    lookForHi:
        'Period ki date ke din se, saada strip test kisi mehnge test jitna hi sahi hota hai. Saste lein aur kam lein.',
    watchOutEn:
        "Testing early mostly gives you a negative that means nothing, and then another one. A test starts to tell you something real on the day your period is due. Before that, you're paying money to feel worse.",
    watchOutHi:
        'Jaldi test karne se zyadatar aisa negative aata hai jiska koi matlab nahi, aur phir ek aur. Period ki date wale din test sach mein kuch batata hai - usse pehle sab kuch, paisa dekar bura mehsoos karna hai.',
    priceEn: '₹50 to ₹300',
  ),
  TtcProduct(
    id: 'lubricant',
    brand: 'Pre-Seed',
    size: '40 g',
    price: '₹749',
    pvScore: 62,
    parentsPct: 58,
    expertsPct: 48,
    rating: 4.0,
    reviews: 520,
    retailer: 'Amazon.in',
    retailerUrl: 'https://www.amazon.in/s?k=fertility+friendly+lubricant',
    badge: '',
    bestFor: [
      ('If you already use one', true),
      ('Around the fertile window', false),
      ('Not a way to improve odds', false),
    ],
    voices: [
      ('Aarti N.', 4, 'Trying 9 months',
          "We needed something, and I didn't know ordinary ones mattered. "
              'Switching was the only change.'),
      ('Farah S.', 3, 'Trying 6 months',
          "Costly for what it is, and we didn't notice it doing anything. "
              "We weren't using anything before."),
    ],
    inside: [
      ('Isotonic gel base', "why it's different",
          'Made to match the salt balance and acidity that sperm can handle. '
              "Ordinary lubricants and saliva don't.",
          ''),
    ],
    studies: [
      ('Do ordinary lubricants affect sperm?',
          'Lab studies show that several common lubricants, and saliva, slow '
              'sperm down. Products made for trying to conceive do this much '
              'less.',
          'If you use lubricant near your fertile days, it\'s worth changing '
              "the type. If you don't use any, buying some changes nothing.",
          'In vitro sperm motility studies · independent', false),
    ],
    hue: 104,
    band: TtcRecoBand.situational,
    evidence: TtcEvidence.mixed,
    verdict: 'Only worth buying if you already use lubricant. If you do, the '
        'type matters more than most people think.',
    goods: [
      'Ordinary lubricants and even saliva can slow sperm down. The '
          'fertility-friendly ones are made not to.',
      "For couples who need it, comfort matters, in a month that can start "
          'to feel like a timetable.',
    ],
    watchOuts: [
      "If you weren't using anything to begin with, buying one won't make "
          'pregnancy more likely.',
      'It costs several times more than an ordinary lubricant. The '
          'difference only matters if you use it near your fertile days.',
      'If dryness is new or keeps coming back, mention it to a doctor. It '
          "isn't something a bottle should fix.",
    ],
    specs: [
      ('Look for', 'Labelled fertility-friendly or sperm-safe'),
      ('Avoid', 'Ordinary lubricants and saliva near your fertile days'),
    ],
    category: 'wellness',
    nameEn: 'Fertility-friendly lubricant',
    nameHi: 'Fertility-friendly lubricant',
    whyEn:
        'A small thing, rarely mentioned, and easy to fix. Most ordinary lubricants, and saliva, make it harder for sperm to move.',
    whyHi:
        'Chhoti baat, kam batayi jaati hai, aasaani se theek: zyadatar aam lubricants aur thook, sperm ke chalne ki kshamta kam karte hain.',
    lookForEn:
        'The words "fertility-friendly" or "sperm-safe" printed on the pack. Not just hinted at in the advert.',
    lookForHi:
        'Pack par saaf likha "fertility-friendly" ya "sperm-safe" - marketing se andaaza nahi.',
    watchOutEn:
        "This is very unlikely to be the reason you haven't conceived yet. It's a two-minute change that costs almost nothing. See it as that, not as a fix.",
    watchOutHi:
        'Ye shayad hi wajah hogi ki couple conceive nahi kar paya. Ye do minute ka badlaav hai jismein kuch kharch nahi - ise waisa hi maanein, ilaaj nahi.',
    priceEn: '₹400 to ₹900',
  ),
  TtcProduct(
    id: 'coq10',
    brand: 'Healthvit CoQ10',
    size: '60 capsules',
    price: '₹1,299',
    pvScore: 54,
    parentsPct: 51,
    expertsPct: 42,
    rating: 4.0,
    reviews: 380,
    retailer: 'Amazon.in',
    retailerUrl: 'https://www.amazon.in/s?k=coq10+ubiquinol+300mg',
    badge: '',
    bestFor: [
      ('Only if a clinic named it', true),
      ('Around IVF', false),
      ('For him too', false),
    ],
    voices: [
      ('Ishita R.', 4, 'IVF, second cycle',
          "Our clinic put both of us on it before the cycle. I can't tell you "
              'if it helped. I can tell you it cost more than the injections '
              'we were arguing about.'),
      ('Tanvi G.', 3, 'Trying 2 years',
          'I bought it because of a poster in the shop, before anyone tested '
              "anything. I wouldn't do that again."),
    ],
    inside: [
      ('Coenzyme Q10', 'what it is',
          'A substance that helps cells make energy. It is found in most parts '
              'of the body. Some studies use a form called ubiquinol, which is '
              'usually the pricier one.',
          'Doses on Indian boxes vary a lot, and the number on the box may not '
              'be the number used in any trial.'),
    ],
    studies: [
      ('CoQ10 before IVF',
          'Small trials in women with low ovarian reserve (fewer eggs left) '
              'found differences in how many eggs were collected. The studies '
              'were small and done in different ways, and live-birth results '
              'were not always reported.',
          'Fine to take if the clinic running your cycle suggests it. Not '
              'something to buy on your own and count on.',
          'Small randomised trials, mixed results · independent', false),
      ('Antioxidants and male subfertility',
          'A large review of antioxidant supplements for men found only '
              'low-quality evidence. It could not say they lead to more live '
              'births.',
          "For your partner, the evidence is weaker than the adverts. Sleep, "
              'less alcohol and not smoking are better proven.',
          'Cochrane review of antioxidants for male subfertility · '
              'independent',
          false),
    ],
    hue: 38,
    band: TtcRecoBand.situational,
    evidence: TtcEvidence.thin,
    verdict: 'Clinics sometimes suggest it for egg or sperm quality. The '
        'evidence is early, and it costs a fair amount.',
    goods: [
      "Some clinics do recommend it, mostly around IVF. It isn't an odd "
          'or fringe idea.',
      'Most people take it without trouble at the usual doses.',
    ],
    watchOuts: [
      'Take this because a doctor who knows your results suggested it. Not '
          'because a poster in the shop did.',
      'One of the priciest things on this list, bought every month, for an '
          'effect no one has firmly proven.',
      'Doses on Indian boxes vary a lot, and the number on the box may not '
          'be the number used in the study.',
    ],
    specs: [
      ('Ask about', 'Dose, and whether it applies to you'),
      ('Typical use', 'Around IVF, or for sperm quality'),
      ('Evidence', 'Early, and not settled'),
    ],
    category: 'supplements',
    nameEn: 'CoQ10',
    nameHi: 'CoQ10',
    whyEn:
        'Studied for egg and sperm quality, mostly in people over thirty-five. Hopeful signs, but not proven.',
    whyHi:
        'Egg aur sperm quality ke liye study hua hai, khaaskar pentiis ke baad. Ummeed jagata hai, sabit nahi hua.',
    lookForEn: 'The dose your doctor gave you, not the one on the shop poster.',
    lookForHi: 'Wo dose jo doctor ne bataya, dukaan ke poster wala nahi.',
    watchOutEn:
        "Doses sold over the counter in India vary a lot, and this is one of the pricier things on this list. Ask a doctor before you ask a chemist. Put plainly, the evidence isn't strong enough to spend a lot on this without advice.",
    watchOutHi:
        'India mein bina prescription bikne wale doses bahut alag-alag hote hain, aur is list mein ye zyada mehngi cheezon mein hai. Chemist se pehle doctor se poochhein - imaandaar baat ye hai ki saboot itne mazboot nahi ki bina salaah ke bahut paisa lagaya jaye.',
    priceEn: '₹800 to ₹2,500 a month',
  ),
  // ⚠️ ADDED FOR THE PCOS PAGE, AND IT IS THE ONE SUPPLEMENT ON THIS LIST WITH
  // A GUIDELINE'S OPINION ATTACHED. The 2023 international PCOS guideline
  // grades inositol as limited evidence and asks that it be described as
  // experimental — so that is what `watchOut` says, in those words, rather
  // than the softer "promising" this list uses elsewhere.
  //
  // ⚠️ THE DOSE TRAP IS THE POINT OF `lookFor`. Almost every product sold for
  // this in India contains a fraction of the amount the trials used, and the
  // number on the front of the box is frequently the combined weight of a
  // blend. A buyer who does not know that overpays for nothing.
  TtcProduct(
    id: 'myo_inositol',
    brand: 'Inofolic',
    size: '30 sachets',
    price: '₹1,150',
    pvScore: 74,
    parentsPct: 72,
    expertsPct: 66,
    rating: 4.2,
    reviews: 640,
    retailer: 'Amazon.in',
    retailerUrl: 'https://www.amazon.in/s?k=myo+inositol+pcos',
    badge: '',
    bestFor: [
      ('PCOS only', true),
      ('Cycle regularity', true),
      ('Not for everyone trying', false),
    ],
    voices: [
      ('Swati J.', 5, 'PCOS, trying 14 months',
          'Four months in, my cycles went from anywhere between 45 and 70 days '
              "to roughly 34. It's the first time I could plan anything."),
      ('Ayesha K.', 4, 'PCOS, trying 8 months',
          'The sachets taste awful and I still take them. My doctor knew, and '
              'was fine with it. That mattered to me.'),
      ('Rhea M.', 3, 'PCOS, trying 2 years',
          "Nothing changed for me in six months. It's cheap enough that I "
              "don't regret trying."),
    ],
    inside: [
      ('Myo-inositol', 'what it is',
          'A kind of sugar alcohol that plays a part in how cells respond to '
              'insulin. The PCOS evidence rests on that link, not on '
              'fertility directly.',
          ''),
      ('D-chiro-inositol', 'sometimes added',
          'A related form. Products mix the two in different amounts, and the '
              "mix in the box isn't always the mix used in the studies.",
          "Read what's in the sachet, not the word on the front."),
    ],
    studies: [
      ('Inositol for ovulation in PCOS',
          'Reviews of trials in women with PCOS found better ovulation, and '
              'better signs of how the body handles insulin. Most trials were '
              'small, and there is little data on live births.',
          'A fair thing to talk over with your doctor if you have PCOS. Not a '
              'treatment, and never a swap for anything prescribed.',
          'Systematic reviews of inositol in PCOS · independent', false),
    ],
    hue: 14,
    band: TtcRecoBand.consider,
    evidence: TtcEvidence.mixed,
    verdict: 'For PCOS, one of the more hopeful supplements. It is not for '
        "people who don't have PCOS.",
    goods: [
      'Fair evidence in PCOS that it helps cycles become more regular.',
      'Cheaper than most fertility supplements, and most people take it '
          'without trouble.',
    ],
    watchOuts: [
      "It's a PCOS supplement. If you don't have PCOS, there's no reason to "
          'take it.',
      "It doesn't replace anything a doctor has prescribed. Tell them you're "
          'taking it, instead of adding it on your own.',
      "Combination products vary a lot. Read what's in the box, not the "
          'word on the front.',
    ],
    specs: [
      ('Who it is for', 'PCOS'),
      ('Commonly studied as', 'Myo-inositol, sometimes with D-chiro'),
      ('Tell your doctor', 'Yes, before starting'),
    ],
    category: 'supplements',
    nameEn: 'Myo-inositol',
    nameHi: 'Myo-inositol',
    whyEn:
        'The one PCOS supplement with real trials behind it. It has been studied for how the body uses insulin and for more regular ovulation. Hopeful, but not proven.',
    whyHi:
        'PCOS ka wo ek supplement jiske peeche asli trials hain. Insulin sensitivity aur zyada regular ovulation ke liye study hua - ummeed jagata hai, sabit nahi.',
    lookForEn:
        'Check the myo-inositol amount on the back, not the total on the front. The trials used about four grams a day. Many products have only a small part of that, mixed into a blend.',
    lookForHi:
        'Peeche likha myo-inositol ka number dekhein, aage ka total nahi. Trials mein roz kareeb chaar gram tha, aur bahut products blend mein uska thoda hissa hi rakhte hain.',
    watchOutEn:
        "The international PCOS guideline still calls this experimental. So see it as something worth trying, not a treatment. Give it three months, and tell your doctor. It affects insulin, which matters if you're on metformin.",
    watchOutHi:
        'International PCOS guideline abhi bhi ise experimental kehti hai, isliye ise ilaaj nahi, aazmane laayak cheez maanein. Teen mahine dein, aur doctor ko batayein - ye insulin par asar karta hai, jo metformin lene par maayne rakhta hai.',
    priceEn: '₹700 to ₹2,000 a month',
  ),
  TtcProduct(
    id: 'zinc',
    brand: 'Zincovit',
    size: '15 tablets',
    price: '₹105',
    pvScore: 48,
    parentsPct: 44,
    expertsPct: 38,
    rating: 4.2,
    reviews: 2100,
    retailer: 'Amazon.in',
    retailerUrl: 'https://www.amazon.in/s?k=zinc+supplement+tablets',
    badge: '',
    bestFor: [
      ('For him', true),
      ('Only if a test showed low', true),
      ('Not to be taken blind', false),
    ],
    voices: [
      ('Rohit M.', 4, 'His test came back low',
          'The blood test said low, the doctor said take it, and three months '
              'later the numbers were better. That order matters.'),
      ('Sameer A.', 2, 'Trying 1 year',
          'I bought a male fertility blend with zinc in it for eleven hundred '
              'rupees. The zinc in it costs about a hundred.'),
    ],
    inside: [
      ('Zinc', 'what it does',
          'A mineral that plays a part in making sperm. A real shortage '
              "affects this. Topping up a level that's already normal doesn't "
              'help.',
          "High doses stop the body taking in copper well. More isn't better "
              'here.'),
    ],
    studies: [
      ('Zinc and folic acid for male fertility',
          'A large randomised trial gave zinc and folic acid to men whose '
              'couples were having fertility treatment. Live birth rates were '
              'no different from the dummy pill (placebo).',
          "If he isn't short of zinc, taking it is unlikely to help. Testing "
              'first makes all the difference.',
          'FAZST randomised trial, 2,370 couples · independent', false),
    ],
    hue: 286,
    band: TtcRecoBand.situational,
    evidence: TtcEvidence.thin,
    verdict: "Worth taking if a test showed he's low. Worth nothing if it "
        "didn't.",
    goods: [
      'A real shortage does affect sperm production, and fixing it is easy '
          'and cheap.',
      'A blood test costs little and gives a proper answer.',
    ],
    watchOuts: [
      "Taking it without a test is guessing, and more isn't better. High "
          'doses stop the body taking in copper well.',
      'Most male fertility supplements are a handful of things like this, '
          'priced as if they were a treatment.',
      'For him, food, alcohol, smoking and sleep are better proven than any '
          'capsule.',
    ],
    specs: [
      ('Test first', 'Yes'),
      ('Whose', 'His'),
      ('Timescale', 'Sperm take about 2 to 3 months'),
    ],
    category: 'supplements',
    nameEn: 'Zinc',
    nameHi: 'Zinc',
    forPartner: true,
    whyEn:
        "Plays a direct part in making sperm and testosterone. This one's for your partner.",
    whyHi:
        'Seedhe sperm banne aur testosterone se juda. Ye unka hai.',
    lookForEn: 'A plain zinc supplement, if a test showed he is low.',
    lookForHi: 'Saada zinc supplement, agar test mein kami dikhi ho.',
    watchOutEn:
        "For most men, a handful of roasted chana at four o'clock does more than the supplements sold for this. Very high doses over a long time stop the body taking in copper well. More isn't better here.",
    watchOutHi:
        'Zyadatar mardon ke liye shaam chaar baje ek mutthi bhuna chana, iske liye beche jaane wale supplements se zyada karta hai. Lambe samay tak bahut zyada dose copper sokhne mein rukawat daalta hai - yahan zyada matlab behtar nahi.',
    priceEn: '₹150 to ₹500 a month',
  ),
  TtcProduct(
    id: 'thermometer',
    brand: 'Femometer',
    size: '1 unit',
    price: '₹1,199',
    pvScore: 66,
    parentsPct: 63,
    expertsPct: 58,
    rating: 4.3,
    reviews: 410,
    retailer: 'Amazon.in',
    retailerUrl: 'https://www.amazon.in/s?k=basal+body+thermometer',
    badge: '',
    bestFor: [
      ('Confirming you ovulate', true),
      ('Over two or three cycles', true),
      ('Not for timing today', false),
      ('One-off cost', false),
    ],
    voices: [
      ('Lakshmi V.', 5, 'Trying 10 months',
          'Three months of charting showed me I do ovulate. After a year of '
              'wondering, that was the answer I needed.'),
      ('Pooja S.', 3, 'Trying 6 months',
          'The same time every morning, before getting up, is harder than it '
              'sounds with a 6am shift. Half my readings were no use.'),
      ('Nandini B.', 4, 'Trying 1 year',
          'Good for the pattern. No use for "is today the day", which is what '
              'I bought it for.'),
    ],
    inside: [
      ('Two-decimal sensor', 'why it matters',
          'After ovulation, your temperature goes up by only a few tenths of a '
              'degree. An ordinary fever thermometer rounds that away.',
          ''),
    ],
    studies: [
      ('Basal temperature as an ovulation marker',
          'Studies checked it against scans and hormone tests. The rise in '
              'temperature reliably comes after ovulation, not before. So it '
              'only shows the day looking back.',
          'It answers "did I ovulate" well. It can\'t answer "should we try '
              'today" at all. Buy it for the first question.',
          'Comparative studies of fertility awareness methods · '
              'independent',
          false),
    ],
    hue: 152,
    band: TtcRecoBand.consider,
    evidence: TtcEvidence.mixed,
    verdict: "Shows you your own pattern over a few months. It can't tell you "
        'that today is the day.',
    goods: [
      "Over two or three cycles, it shows whether you're ovulating at all. "
          "That's a real and useful answer.",
      'You buy it once. It isn\'t a monthly cost.',
    ],
    watchOuts: [
      'Your temperature goes up after ovulation. By the time the chart '
          'moves, your fertile days are over.',
      'You need to check it at the same time every morning, before getting '
          'up. A broken night makes the reading no use.',
      'For some people, charting every day turns the whole month into an '
          "exam. If that's happening, put it away.",
    ],
    specs: [
      ('Resolution', 'Two decimal places'),
      ('Memory', 'Worth having'),
      ('Tells you', 'That you ovulated, afterwards'),
    ],
    category: 'kits',
    nameEn: 'Basal thermometer',
    nameHi: 'Basal thermometer',
    whyEn:
        "Reads to two decimal places, which an ordinary fever thermometer can't. It tells you ovulation happened, after it has happened.",
    whyHi:
        'Do decimal tak padhta hai, jo aam bukhaar wala thermometer nahi kar sakta. Ovulation hua ya nahi, ye baad mein confirm karta hai.',
    lookForEn: "Two decimal places and a memory. That's all it needs.",
    lookForHi: 'Do decimal aur memory function. Bas itni hi spec hai.',
    watchOutEn:
        "It can't warn you that ovulation is coming. By the time your temperature goes up, your fertile days are mostly over. And you need to check it at the same time every morning, before getting up. If that's making the month feel heavier, this is the first thing to drop.",
    watchOutHi:
        'Ye ovulation aane se pehle chetavni nahi de sakta - jab temperature badhta hai, tab window lagbhag band ho chuki hoti hai. Aur ise roz subah uthne se pehle usi samay naapna padta hai. Agar isse mahina bhaari ho raha hai, toh sabse pehle isi ko chhodein.',
    priceEn: '₹500 to ₹1,500',
  ),
  TtcProduct(
    id: 'book_impatient',
    brand: 'Various',
    size: 'Paperback',
    price: '₹499',
    pvScore: 78,
    parentsPct: 81,
    expertsPct: 62,
    rating: 4.4,
    reviews: 260,
    retailer: 'Amazon.in',
    retailerUrl: 'https://www.amazon.in/s?k=books+on+infertility+and+waiting',
    badge: '',
    bestFor: [
      ('The waiting, not the trying', true),
      ('Read it together', true),
      ('Not a protocol', false),
    ],
    voices: [
      ('Shreya D.', 5, 'Trying 2 years',
          'The first thing I read about how this feels, not what to do about '
              'it. My husband read it after me, and we talked differently '
              'after that.'),
      ('Manasi K.', 4, 'Trying 15 months',
          "Some of it didn't fit us. The chapter on telling family was worth "
              'the whole book.'),
    ],
    inside: [
      ('One copy', 'how to use it',
          'Read it together, one copy between you. What matters is the talk '
              'it starts.',
          ''),
    ],
    studies: [
      ('Distress while trying to conceive',
          'Surveys of couples having fertility care keep finding much more '
              'worry and low mood than in people generally. They also find '
              'both partners are affected.',
          "If the waiting feels heavy, that's what most people feel. It isn't "
              "a failing on your part. And a book can't take the place of "
              'talking to someone.',
          'Cohort studies of psychological distress in infertility · '
              'independent',
          false),
    ],
    hue: 222,
    band: TtcRecoBand.buy,
    evidence: TtcEvidence.mixed,
    verdict: 'The only thing on this list for the part of trying that no one '
        'prepares you for.',
    goods: [
      'The waiting is the hard part, and almost nothing sold for fertility '
          'is about it.',
      'One copy read by both of you is worth more than two read apart.',
    ],
    watchOuts: [
      "A book isn't treatment. If this is getting heavy, it can't take the "
          'place of talking to someone.',
      'Skip anything promising a method, a set plan or a number of days. '
          "That's a different kind of book with a similar cover.",
    ],
    specs: [
      ('Format', 'One copy, both of you'),
      ('What it is not', 'A protocol or a plan'),
    ],
    category: 'books',
    nameEn: 'A book about the waiting, not the trying',
    nameHi: 'Intezaar ke baare mein ek kitaab, koshish ke baare mein nahi',
    whyEn:
        'Most fertility books are how-to manuals. The ones couples finish are about how this feels. Reading the same book gives you both the same words for it.',
    whyHi:
        'Zyadatar fertility kitaabein manual hoti hain. Jo couples sach mein poori padhte hain wo ye batati hain ki ye mehsoos kaisa hota hai - aur ek hi cheez padhne se aap dono ko uske liye ek hi shabd milte hain.',
    lookForEn: "Something you'll both read. One copy, not two.",
    lookForHi: 'Aisi kuch jo aap dono padhein. Ek copy, do nahi.',
    watchOutEn:
        "Skip anything that promises a plan to get you pregnant in a set number of months. Nothing can promise that. A book that says it can isn't being honest with you.",
    watchOutHi:
        'Aisi kisi bhi cheez se bachein jo kehti ho ki itne mahinon mein conception pakka. Koi ye vaada nahi kar sakta, aur jo kitaab karti hai wo chapter ke hisaab se ummeed bech rahi hai.',
    priceEn: '₹300 to ₹800',
  ),
  // ⚠️ THE FIRST ENTRY HERE THAT EXISTS TO TALK SOMEBODY OUT OF A PURCHASE, AND
  // THE SHELF NEEDED ONE.
  //
  // The file's own header has always said "several of them exist mainly to talk
  // a couple out of buying something" — and until now none of the nine actually
  // did. Every one was worth buying in some circumstance, which made the
  // honesty structural rather than visible: a shelf where nothing is ever
  // rated "generally not needed" is indistinguishable from a shelf that cannot
  // say it.
  //
  // This is the product people in this stage most reliably waste money on, and
  // `ttc_read_supplement_timing` already says so in prose. Saying it on the
  // shelf, where the money is spent, is worth more.
  //
  // ⚠️ AND IT IS NOT AN ATTACK ON A BRAND. No manufacturer is named, nothing is
  // called a scam, and the "what's good" column is honestly filled rather than
  // left empty to make the point.
  TtcProduct(
    id: 'fertility_blend',
    brand: 'Various',
    size: '60 tablets',
    price: '₹1,499',
    pvScore: 34,
    parentsPct: 39,
    expertsPct: 21,
    rating: 4.0,
    reviews: 1560,
    retailer: 'Amazon.in',
    retailerUrl: 'https://www.amazon.in/s?k=fertility+supplement+for+women',
    badge: '',
    bestFor: [
      ('One tablet, if you want that', false),
      ('Cheaper as separate parts', true),
      ('Check for vitamin A', true),
    ],
    voices: [
      ('Nikita P.', 2, 'Trying 7 months',
          'Fifteen hundred a month for what turned out to be folic acid and a '
              'multivitamin. I read the box properly in the fourth month.'),
      ('Aparna R.', 4, 'Trying 1 year',
          "One tablet instead of three is worth something to me. I know I'm "
              'paying for the ease.'),
      ('Juhi S.', 1, 'Trying 3 years',
          'Nothing on the box is untrue, and nothing on it is proven either. '
              "That's the whole problem with these."),
    ],
    inside: [
      ('Folic acid', 'the part with evidence',
          'A good blend has the 400 mcg you need. This is the ingredient doing '
              'the work.',
          'It costs about ninety rupees on its own.'),
      ('Antioxidant mix', 'the part being sold',
          'Vitamins C and E, selenium and the like. They sound helpful, but '
              "they haven't been shown to help anyone conceive.",
          ''),
      ('Vitamin A', 'the one to check',
          'Some general multivitamins have retinol (a form of vitamin A) at '
              "levels that aren't right for someone who might conceive.",
          'Before you buy any multivitamin while trying, turn the box over and '
              'look for retinol or retinyl palmitate.'),
    ],
    studies: [
      ('Do multi-ingredient fertility supplements work?',
          'Reviews of mixed supplements sold for fertility find the trials are '
              'small, disagree with each other, and often don\'t report live '
              'births. The folate part has evidence. The blends as sold '
              "don't.",
          'If you want the part that works, buy that part. The rest is sold to '
              'you on how it sounds.',
          'Cochrane and systematic reviews of preconception supplements · '
              'independent',
          false),
    ],
    hue: 44,
    category: 'supplements',
    nameEn: 'A "fertility blend" multivitamin',
    nameHi: '"Fertility blend" multivitamin',
    band: TtcRecoBand.skip,
    evidence: TtcEvidence.thin,
    verdict: 'Mostly folic acid and a few antioxidants, at several times the '
        'price of buying only what you need.',
    whyEn:
        "These sell on ingredients that sound helpful, not on evidence that they help anyone conceive. That doesn't make them harmful. It makes them costly, and it means you have no reason to feel guilty for not buying one.",
    whyHi:
        'Ye un ingredients ke naam par bikte hain jo sunne mein theek lagte hain, is saboot par nahi ki inse conceive karne mein madad milti hai. Ye nuksaandeh nahi hain — bas mehnge hain, aur na khareedne par jo guilt hoti hai wo bejaa hai.',
    lookForEn:
        "If you do buy one, turn the box over. Check it has 400 mcg of folic acid, and check it doesn't have high-dose vitamin A.",
    lookForHi:
        'Agar khareedna hi hai toh dabba palat kar dekhein: 400 mcg folic acid hai ya nahi, aur high-dose vitamin A toh nahi hai.',
    watchOutEn:
        "A blend with 400 mcg of folic acid, bought in place of a folic acid tablet, is a costlier way to do the same thing. And general multivitamins sometimes have vitamin A at levels that aren't right for someone who might conceive.",
    watchOutHi:
        'Jis blend mein 400 mcg folic acid hai, use folic acid tablet ki jagah lena wahi kaam mehnge tareeke se karna hai. Aur aam multivitamins mein kabhi-kabhi vitamin A itna hota hai jo conceive karne waali ke liye theek nahi.',
    priceEn: '₹900 to ₹3,000 a month',
    goods: [
      "They're easy: one tablet instead of two or three.",
      'A well-made one does have the folic acid you need.',
    ],
    watchOuts: [
      'The folic acid inside is the part with evidence. On its own, it costs '
          'a small part of this price.',
      "Check for vitamin A, listed as retinol or retinyl palmitate. High doses "
          "aren't safe in pregnancy.",
      "A blood test tells you what you're short of. The common ones here are "
          'iron, B12 and vitamin D, and a blend only guesses at all three.',
    ],
    specs: [
      ('What has evidence', 'The folic acid'),
      ('Cheaper alternative', 'Plain folic acid, plus what a test shows'),
      ('Check the box for', 'Vitamin A'),
    ],
  ),
];

List<TtcProduct> ttcProductsIn(String category) =>
    ttcProducts.where((p) => p.category == category).toList();
