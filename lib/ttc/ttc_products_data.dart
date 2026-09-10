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
          'Good trials, repeated, pointing the same way. This is about as sure '
              'as fertility advice gets.',
        TtcEvidence.mixed =>
          'Some real evidence and some disagreement between studies. Reasonable '
              'to try; not something to count on.',
        TtcEvidence.thin =>
          'Little good evidence either way. That does not mean it does nothing '
              '— it means nobody has properly shown that it does.',
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
          'Ninety rupees. I had spent nine hundred on a prenatal blend the '
              'month before and this does the part that actually matters.'),
      ('Preeti S.', 5, 'Trying 8 months',
          'My gynaec wrote this exact one. Chemist had it, no fuss, and it is '
              'the one thing nobody argued with me about.'),
      ('Ritu M.', 4, 'Trying 1 year',
          'Works, but check the strength. I bought 5 mg thinking stronger was '
              'better and had to be told otherwise.'),
    ],
    inside: [
      ('Folic acid', 'the whole point',
          'A synthetic form of folate that the body absorbs far more reliably '
              'than food folate. It is what the neural tube needs to be '
              'present before it closes.',
          ''),
    ],
    studies: [
      ('Folic acid before conception and neural tube defects',
          'A large randomised trial gave folic acid to women planning a '
              'pregnancy, starting before conception. Neural tube defects '
              'were substantially less common than in the group that did not '
              'take it.',
          'This is the reason the advice is "before", not "when you find out". '
              'The window it protects has usually closed by the time a test is '
              'positive.',
          'MRC Vitamin Study, randomised · independent', false),
      ('Higher doses, and who needs them',
          'Reviews of dosing looked at women with diabetes, epilepsy '
              'medication, absorption conditions and a previous affected '
              'pregnancy. Several groups are advised considerably more than '
              'the standard amount.',
          'If any of those describe you, the number on the box is not your '
              'number. That is a prescription conversation, not a shelf one.',
          'NICE NG201 and RCOG guidance · independent', false),
    ],
    hue: 320,
    band: TtcRecoBand.strong,
    evidence: TtcEvidence.strong,
    verdict: 'The one purchase on this list with settled evidence behind it. '
        'Start it before you conceive, not after.',
    goods: [
      'Decades of trials, all pointing the same way. Nothing else here is on '
          'this footing.',
      'The plain tablet costs less than a cup of chai a week.',
      'Stocked in every chemist in India, so you can replace it anywhere.',
    ],
    watchOuts: [
      'A "prenatal" combination often bundles things you may not need, at '
          'several times the price of plain folic acid.',
      'Some people need a much higher dose — diabetes, epilepsy medication, a '
          'previous neural tube pregnancy. That is a prescription, not a shelf '
          'choice.',
      'Check the unit. 400 mcg and 5 mg are a thousand times apart, and both '
          'appear on Indian boxes.',
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
        'The single most evidence-backed thing you can buy in this list. Needed before conception, because the neural tube closes in the first four weeks.',
    whyHi:
        'Is poori list mein sabse zyada saboot wali cheez. Conception se pehle chahiye, kyunki neural tube pehle chaar hafton mein band ho jaata hai.',
    lookForEn: 'Plain 400mcg folic acid. That is all most people need.',
    lookForHi: 'Sirf 400mcg folic acid. Zyadatar logon ko bas itna hi chahiye.',
    watchOutEn:
        'Expensive "prenatal" combinations often bundle things you may not need and cost several times more than plain folic acid. If you have diabetes, epilepsy or a previous neural tube pregnancy, your doctor may want a higher dose - that is a prescription question, not a shelf one.',
    watchOutHi:
        'Mehnge "prenatal" combinations mein aksar wo cheezein hoti hain jo shayad zaroori na hon, aur wo saade folic acid se kai guna mehnge hote hain. Agar aapko diabetes, epilepsy ya pehle neural tube wali pregnancy rahi ho, toh doctor zyada dose keh sakte hain - ye prescription ka sawaal hai, dukaan ka nahi.',
    priceEn: '₹80 – ₹250 a month',
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
          'Two cycles told me I ovulate around day 16, not 14. That was worth '
              'the three hundred rupees. The third cycle I stopped.'),
      ('Sonia B.', 3, 'Trying 1 year, PCOS',
          'Positive nearly every day for a week. My doctor said that happens '
              'with PCOS and to stop using them. Wish the box had said so.'),
      ('Divya A.', 4, 'Trying 7 months',
          'Useful, but testing every morning started to make the whole month '
              'about the strip. Put them away and felt better.'),
    ],
    inside: [
      ('LH antibody strip', 'what it detects',
          'Binds luteinising hormone in urine and shows a line above a '
              'threshold. The surge it catches comes 12 to 36 hours before an '
              'egg is released.',
          'A line means the hormone rose. It does not prove an egg was '
              'actually released.'),
    ],
    studies: [
      ('Do ovulation kits shorten time to pregnancy?',
          'Trials comparing kit users with couples having regular sex found '
              'little difference in how quickly they conceived. Regular sex '
              'across the fertile week covers the same ground.',
          'Useful for learning when your own window is. Not something that '
              'improves the odds by itself.',
          'Systematic review of ovulation prediction · independent', false),
      ('LH in polycystic ovary syndrome',
          'Baseline LH is frequently raised in PCOS, and studies of kit use in '
              'this group report repeated positives that do not correspond to '
              'ovulation.',
          'If you have PCOS, these can mislead rather than help. Ask your '
              'doctor what to use instead.',
          'Endocrine reviews of PCOS diagnostics · independent', false),
    ],
    hue: 258,
    band: TtcRecoBand.consider,
    evidence: TtcEvidence.mixed,
    verdict: 'Genuinely useful for a cycle or two while you learn your own '
        'pattern. Less useful every month after that.',
    goods: [
      'Tells you ovulation is coming, which a temperature chart can only tell '
          'you afterwards.',
      'Cheap in bulk, and one or two cycles is usually enough to learn your '
          'own timing.',
    ],
    watchOuts: [
      'A surge does not prove an egg was released. It says a hormone rose.',
      'In PCOS, LH can run high all month, so the strips read positive '
          'repeatedly and mean nothing.',
      'Testing daily can make a month heavier than it needs to be. Stopping '
          'is a perfectly good decision.',
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
        'Detects the hormone surge twelve to thirty-six hours before an egg is released - so it tells you "soon", which is genuinely useful once or twice while you learn your own pattern.',
    whyHi:
        'Ye hormone surge ko egg release hone se baarah se chhattis ghante pehle pakadti hai - yaani "jald" batati hai, jo apna pattern samajhte waqt ek-do baar sach mein kaam ki hai.',
    lookForEn:
        'Cheap bulk strips rather than a digital reader. You will use several per cycle, and the digital ones cost many times more for the same information.',
    lookForHi:
        'Digital reader ke bajaye saste bulk strips. Ek cycle mein kai istemaal hongi, aur digital wale usi jaankari ke liye kai guna mehnge padte hain.',
    watchOutEn:
        'In PCOS, LH can run high all month, which makes strips confusing rather than helpful. And a surge does not prove an egg was actually released. If testing daily is making the month heavier, stopping is a perfectly good decision.',
    watchOutHi:
        'PCOS mein LH poora mahina high reh sakta hai, jisse strips madad ke bajaye confuse karti hain. Aur surge ye sabit nahi karta ki egg sach mein release hua. Agar roz test karna mahine ko bhaari bana raha hai, toh rok dena bilkul theek faisla hai.',
    priceEn: '₹200 – ₹600 for 25 strips',
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
      ('From the day it is due', true),
      ('First morning urine', true),
      ('Cheap works as well', true),
      ('One at a time', false),
    ],
    voices: [
      ('Kavya T.', 5, 'Trying 4 months',
          'Fifty-five rupees and the same answer as the digital one I bought '
              'to be sure. I stopped buying the expensive ones.'),
      ('Meghna P.', 3, 'Trying 11 months',
          'The tests are fine. Testing on day 22 was the problem, and I did '
              'that four months in a row before I learned.'),
      ('Shalini D.', 5, 'Trying 2 years',
          'A faint line, and my doctor did a blood test the same week rather '
              'than making me buy five more.'),
    ],
    inside: [
      ('hCG antibody strip', 'what it detects',
          'Detects human chorionic gonadotropin, which a pregnancy starts '
              'producing after implantation and which roughly doubles every '
              'couple of days early on.',
          'Below the strip\'s sensitivity there is nothing to detect, which is '
              'why an early test can read negative and be wrong.'),
    ],
    studies: [
      ('How early is too early?',
          'Studies of home test accuracy show sensitivity rising sharply '
              'around the date a period is due, and being markedly lower in '
              'the days before it.',
          'A negative before your period is due tells you very little. The '
              'test was not wrong; it was early.',
          'Evaluations of home pregnancy test accuracy · independent',
          false),
    ],
    hue: 190,
    band: TtcRecoBand.buy,
    evidence: TtcEvidence.strong,
    verdict: 'They work, and the cheap ones work as well as the expensive '
        'ones. The trap is testing too early.',
    goods: [
      'A plain strip from a chemist is as accurate as a branded digital one at '
          'a fraction of the price.',
      'Reliable from the day a period is due, which is what the sensitivity '
          'number on the box is about.',
    ],
    watchOuts: [
      'Testing early is the commonest way to be told "no" by a test that was '
          'simply too soon.',
      'Buying in bulk quietly encourages testing every day, which is expensive '
          'in more ways than one.',
      'A faint line is usually a real line, but the honest next step is a '
          'blood test, not five more strips.',
    ],
    specs: [
      ('Reliable from', 'The day your period is due'),
      ('Sensitivity', '10–25 mIU/ml on most Indian strips'),
      ('Best time of day', 'First morning urine'),
    ],
    category: 'tests',
    nameEn: 'Home pregnancy test',
    nameHi: 'Ghar ka pregnancy test',
    whyEn:
        'Looks for hCG, which only appears after implantation and then takes a few days to become detectable.',
    whyHi:
        'Ye hCG dhoondhta hai, jo implantation ke baad hi banta hai aur phir pakad mein aane mein kuch din leta hai.',
    lookForEn:
        'A plain strip test is as accurate as an expensive one from the day your period is due. Buy the cheap ones and buy fewer.',
    lookForHi:
        'Period ki date ke din se, saada strip test kisi mehnge test jitna hi sahi hota hai. Saste lein aur kam lein.',
    watchOutEn:
        'Testing early mostly produces a negative that means nothing, and then another one. The day your period is due is when a test becomes genuinely informative - everything before that is paying money to feel worse.',
    watchOutHi:
        'Jaldi test karne se zyadatar aisa negative aata hai jiska koi matlab nahi, aur phir ek aur. Period ki date wale din test sach mein kuch batata hai - usse pehle sab kuch, paisa dekar bura mehsoos karna hai.',
    priceEn: '₹50 – ₹300',
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
          'We needed something and I did not know ordinary ones mattered. '
              'Switching was the whole change.'),
      ('Farah S.', 3, 'Trying 6 months',
          'Expensive for what it is, and it did not do anything we could '
              'notice. We were not using anything before.'),
    ],
    inside: [
      ('Isotonic gel base', 'why it is different',
          'Formulated to match the salt balance and acidity that sperm '
              'tolerate, which ordinary lubricants and saliva do not.',
          ''),
    ],
    studies: [
      ('Do ordinary lubricants affect sperm?',
          'Laboratory studies show several common lubricants and saliva reduce '
              'sperm movement, while products formulated for the purpose do '
              'not to the same degree.',
          'If you use lubricant near your fertile window, the type is worth '
              'changing. If you do not use any, buying some changes nothing.',
          'In vitro sperm motility studies · independent', false),
    ],
    hue: 104,
    band: TtcRecoBand.situational,
    evidence: TtcEvidence.mixed,
    verdict: 'Only worth buying if you already use lubricant. If you do, the '
        'type matters more than most people realise.',
    goods: [
      'Ordinary lubricants and even saliva can slow sperm; the fertility-'
          'friendly ones are formulated not to.',
      'For couples who need it, comfort is not a small thing during a month '
          'that can start to feel like a schedule.',
    ],
    watchOuts: [
      'Buying one does not improve your chances if you were not using anything '
          'to begin with.',
      'Several times the price of an ordinary lubricant, for a difference that '
          'only matters if you use it near the fertile window.',
      'Dryness that is new or persistent is worth mentioning to a doctor '
          'rather than solving with a bottle.',
    ],
    specs: [
      ('Look for', 'Labelled fertility-friendly or sperm-safe'),
      ('Avoid', 'Ordinary lubricants and saliva near the window'),
    ],
    category: 'wellness',
    nameEn: 'Fertility-friendly lubricant',
    nameHi: 'Fertility-friendly lubricant',
    whyEn:
        'Small, rarely mentioned, and easy to fix: most ordinary lubricants - and saliva - reduce how well sperm can move.',
    whyHi:
        'Chhoti baat, kam batayi jaati hai, aasaani se theek: zyadatar aam lubricants aur thook, sperm ke chalne ki kshamta kam karte hain.',
    lookForEn:
        'The words "fertility-friendly" or "sperm-safe" printed on the pack, not implied by the marketing.',
    lookForHi:
        'Pack par saaf likha "fertility-friendly" ya "sperm-safe" - marketing se andaaza nahi.',
    watchOutEn:
        'This is very unlikely to be the reason a couple has not conceived. It is a two-minute change that costs almost nothing - treat it as that, not as a fix.',
    watchOutHi:
        'Ye shayad hi wajah hogi ki couple conceive nahi kar paya. Ye do minute ka badlaav hai jismein kuch kharch nahi - ise waisa hi maanein, ilaaj nahi.',
    priceEn: '₹400 – ₹900',
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
      ('His side too', false),
    ],
    voices: [
      ('Ishita R.', 4, 'IVF, second cycle',
          'Our clinic put both of us on it before the cycle. I cannot tell you '
              'if it helped. I can tell you it cost more than the injections '
              'we were arguing about.'),
      ('Tanvi G.', 3, 'Trying 2 years',
          'Bought it off a shelf talker before anyone tested anything. Would '
              'not do that again.'),
    ],
    inside: [
      ('Coenzyme Q10', 'what it is',
          'A compound involved in how cells produce energy, present in most '
              'tissues. Ubiquinol is the form some studies use and it is '
              'usually the more expensive one.',
          'Doses on Indian boxes vary widely, and the number on the box is not '
              'necessarily the number used in any trial.'),
    ],
    studies: [
      ('CoQ10 before IVF',
          'Small trials in women with low ovarian reserve reported differences '
              'in the number of eggs retrieved. The studies were small, the '
              'protocols differed, and live-birth results were not '
              'consistently reported.',
          'Reasonable to take if the clinic running your cycle suggests it. '
              'Not something to buy on your own and count on.',
          'Small randomised trials, mixed results · independent', false),
      ('Antioxidants and male subfertility',
          'A large review of antioxidant supplements for men found low-quality '
              'evidence and could not conclude they improve live birth rates.',
          'On his side, the evidence is weaker than the marketing. Sleep, '
              'alcohol and smoking are better established.',
          'Cochrane review of antioxidants for male subfertility · '
              'independent',
          false),
    ],
    hue: 38,
    band: TtcRecoBand.situational,
    evidence: TtcEvidence.thin,
    verdict: 'Sometimes suggested by clinics for egg or sperm quality. The '
        'evidence is early, and the cost is real.',
    goods: [
      'Some clinics do recommend it, particularly around IVF, and it is not a '
          'fringe suggestion.',
      'Generally well tolerated at the doses usually named.',
    ],
    watchOuts: [
      'This is one to take because a doctor who knows your results named it — '
          'not because a shelf talker did.',
      'Among the most expensive things on this list, taken monthly, for an '
          'effect nobody has firmly established.',
      'Doses on Indian boxes vary widely, and the number on the box is not '
          'necessarily the number in the study.',
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
        'Studied for egg and sperm quality, particularly over thirty-five. Promising rather than proven.',
    whyHi:
        'Egg aur sperm quality ke liye study hua hai, khaaskar pentiis ke baad. Ummeed jagata hai, sabit nahi hua.',
    lookForEn: 'A dose your doctor named, not the one on the shelf talker.',
    lookForHi: 'Wo dose jo doctor ne bataya, dukaan ke poster wala nahi.',
    watchOutEn:
        'Doses sold over the counter in India vary enormously, and this is among the more expensive things in this list. Ask a doctor before a chemist - the honest summary is that the evidence is not strong enough to spend heavily on without advice.',
    watchOutHi:
        'India mein bina prescription bikne wale doses bahut alag-alag hote hain, aur is list mein ye zyada mehngi cheezon mein hai. Chemist se pehle doctor se poochhein - imaandaar baat ye hai ki saboot itne mazboot nahi ki bina salaah ke bahut paisa lagaya jaye.',
    priceEn: '₹800 – ₹2,500 a month',
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
          'Four months in my cycles went from anywhere between 45 and 70 days '
              'to roughly 34. That is the first time I could plan anything.'),
      ('Ayesha K.', 4, 'PCOS, trying 8 months',
          'The sachets taste awful and I still take them. My doctor knew about '
              'it and was fine with it, which mattered to me.'),
      ('Rhea M.', 3, 'PCOS, trying 2 years',
          'Nothing changed for me in six months. It is cheap enough that I do '
              'not regret trying.'),
    ],
    inside: [
      ('Myo-inositol', 'what it is',
          'A sugar alcohol involved in how cells respond to insulin. The PCOS '
              'evidence is built around that link rather than around fertility '
              'directly.',
          ''),
      ('D-chiro-inositol', 'sometimes added',
          'A related form. Products combine the two in different ratios, and '
              'the ratio in the box is not always the ratio in the studies.',
          'Read what is actually in the sachet rather than the word on the '
              'front.'),
    ],
    studies: [
      ('Inositol for ovulation in PCOS',
          'Reviews of trials in women with PCOS report improvements in '
              'ovulation and in markers of insulin resistance. Trials were '
              'mostly small and live-birth data is limited.',
          'A reasonable thing to discuss with your doctor if you have PCOS. '
              'Not a treatment, and not a substitute for anything prescribed.',
          'Systematic reviews of inositol in PCOS · independent', false),
    ],
    hue: 14,
    band: TtcRecoBand.consider,
    evidence: TtcEvidence.mixed,
    verdict: 'For PCOS specifically, one of the more promising supplements — '
        'and it is not for people without it.',
    goods: [
      'Reasonable evidence in PCOS for helping cycles become more regular.',
      'Cheaper than most fertility supplements, and generally well tolerated.',
    ],
    watchOuts: [
      'It is a PCOS supplement. If you do not have PCOS there is no reason to '
          'be taking it.',
      'It is not a substitute for anything a doctor has prescribed, and it '
          'should be mentioned to them rather than added quietly.',
      'Combination products vary a great deal. Read what is actually in the '
          'box rather than the word on the front.',
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
        'The one PCOS supplement with real trials behind it. Studied for insulin sensitivity and more regular ovulation - promising, not established.',
    whyHi:
        'PCOS ka wo ek supplement jiske peeche asli trials hain. Insulin sensitivity aur zyada regular ovulation ke liye study hua - ummeed jagata hai, sabit nahi.',
    lookForEn:
        'Check the myo-inositol figure on the back, not the total on the front. The trials used about four grams a day, and many products carry a fraction of that in a blend.',
    lookForHi:
        'Peeche likha myo-inositol ka number dekhein, aage ka total nahi. Trials mein roz kareeb chaar gram tha, aur bahut products blend mein uska thoda hissa hi rakhte hain.',
    watchOutEn:
        'The international PCOS guideline still calls this experimental, so treat it as something worth trying rather than a treatment. Give it three months, and tell your doctor - it affects insulin, which matters if you are on metformin.',
    watchOutHi:
        'International PCOS guideline abhi bhi ise experimental kehti hai, isliye ise ilaaj nahi, aazmane laayak cheez maanein. Teen mahine dein, aur doctor ko batayein - ye insulin par asar karta hai, jo metformin lene par maayne rakhta hai.',
    priceEn: '₹700 – ₹2,000 a month',
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
          'Blood test said low, doctor said take it, three months later the '
              'numbers were better. That order matters.'),
      ('Sameer A.', 2, 'Trying 1 year',
          'Bought a male fertility blend with zinc in it for eleven hundred '
              'rupees. The zinc in it costs about a hundred.'),
    ],
    inside: [
      ('Zinc', 'what it does',
          'A mineral involved in sperm production. Genuine deficiency affects '
              'it; correcting a level that is already normal does not.',
          'High doses interfere with copper absorption. More is not better '
              'here.'),
    ],
    studies: [
      ('Zinc and folic acid for male fertility',
          'A large randomised trial gave zinc and folic acid to men in couples '
              'undergoing fertility treatment. Live birth rates did not '
              'differ from placebo.',
          'Taking it without a deficiency is unlikely to help. Testing first '
              'is the whole difference.',
          'FAZST randomised trial, 2,370 couples · independent', false),
    ],
    hue: 286,
    band: TtcRecoBand.situational,
    evidence: TtcEvidence.thin,
    verdict: 'Worth taking if a test showed he is low. Worth nothing if it '
        'did not.',
    goods: [
      'Genuine deficiency does affect sperm production, and correcting it is '
          'straightforward and cheap.',
      'A blood test is inexpensive and answers the question properly.',
    ],
    watchOuts: [
      'Taking it without knowing is guessing, and more is not better — high '
          'doses interfere with copper absorption.',
      'Most male fertility supplements are a handful of ingredients like this '
          'one, priced as though they were a treatment.',
      'Diet, alcohol, smoking and sleep are better established than any '
          'capsule on his side.',
    ],
    specs: [
      ('Test first', 'Yes'),
      ('Whose', 'His'),
      ('Timescale', 'Sperm take about 2–3 months'),
    ],
    category: 'supplements',
    nameEn: 'Zinc',
    nameHi: 'Zinc',
    forPartner: true,
    whyEn:
        'Directly involved in sperm production and testosterone. This one is his.',
    whyHi:
        'Seedhe sperm banne aur testosterone se juda. Ye unka hai.',
    lookForEn: 'A plain zinc supplement, if a test showed you are low.',
    lookForHi: 'Saada zinc supplement, agar test mein kami dikhi ho.',
    watchOutEn:
        'A fistful of roasted chana at four o\'clock does more for most men than the supplements marketed for this. Very high doses over long periods interfere with copper absorption - more is not better here.',
    watchOutHi:
        'Zyadatar mardon ke liye shaam chaar baje ek mutthi bhuna chana, iske liye beche jaane wale supplements se zyada karta hai. Lambe samay tak bahut zyada dose copper sokhne mein rukawat daalta hai - yahan zyada matlab behtar nahi.',
    priceEn: '₹150 – ₹500 a month',
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
          'Three months of charting told me I do ovulate. After a year of '
              'wondering, that was the answer I actually needed.'),
      ('Pooja S.', 3, 'Trying 6 months',
          'Same time every morning before getting up is harder than it sounds '
              'with a 6am shift. Half my readings were unusable.'),
      ('Nandini B.', 4, 'Trying 1 year',
          'Good for the pattern. Useless for "is today the day", which is what '
              'I bought it for.'),
    ],
    inside: [
      ('Two-decimal sensor', 'why it matters',
          'The shift after ovulation is a few tenths of a degree. An ordinary '
              'fever thermometer rounds it away.',
          ''),
    ],
    studies: [
      ('Basal temperature as an ovulation marker',
          'Comparisons with ultrasound and hormone measurement show the '
              'temperature rise reliably follows ovulation rather than '
              'predicting it, and identifies the day only in retrospect.',
          'It answers "did I ovulate" well and "should we try today" not at '
              'all. Buy it for the first question.',
          'Comparative studies of fertility awareness methods · '
              'independent',
          false),
    ],
    hue: 152,
    band: TtcRecoBand.consider,
    evidence: TtcEvidence.mixed,
    verdict: 'Shows you your own pattern over a few months. It cannot tell you '
        'that today is the day.',
    goods: [
      'Over two or three cycles it shows whether you are ovulating at all, '
          'which is a real and useful answer.',
      'A one-off purchase rather than a monthly cost.',
    ],
    watchOuts: [
      'The temperature rises AFTER ovulation. By the time the chart moves, the '
          'window has closed.',
      'It needs measuring at the same time every morning before getting up, '
          'and a broken night makes the reading unusable.',
      'For some people, charting daily turns the whole month into an exam. If '
          'it is doing that, put it away.',
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
        'Reads to two decimal places, which an ordinary fever thermometer cannot. Confirms that ovulation happened, after the fact.',
    whyHi:
        'Do decimal tak padhta hai, jo aam bukhaar wala thermometer nahi kar sakta. Ovulation hua ya nahi, ye baad mein confirm karta hai.',
    lookForEn: 'Two decimal places and a memory function. That is the whole spec.',
    lookForHi: 'Do decimal aur memory function. Bas itni hi spec hai.',
    watchOutEn:
        'It cannot warn you ovulation is coming - by the time the temperature rises, the window has essentially closed. And it needs measuring at the same time every morning before getting up. If that is making the month heavier, this is the first thing to drop.',
    watchOutHi:
        'Ye ovulation aane se pehle chetavni nahi de sakta - jab temperature badhta hai, tab window lagbhag band ho chuki hoti hai. Aur ise roz subah uthne se pehle usi samay naapna padta hai. Agar isse mahina bhaari ho raha hai, toh sabse pehle isi ko chhodein.',
    priceEn: '₹500 – ₹1,500',
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
          'The first thing I read that was about how this feels rather than '
              'what to do about it. My husband read it after me and we talked '
              'differently afterwards.'),
      ('Manasi K.', 4, 'Trying 15 months',
          'Some of it did not apply to us. The chapter on telling family was '
              'worth the whole book.'),
    ],
    inside: [
      ('One copy', 'how to use it',
          'Read by both of you rather than bought twice. The point is the '
              'conversation it starts.',
          ''),
    ],
    studies: [
      ('Distress while trying to conceive',
          'Surveys of couples in fertility care consistently find rates of '
              'anxiety and low mood well above the general population, and '
              'find that both partners are affected.',
          'If the waiting is heavy, that is the common experience rather than '
              'a personal failing — and a book is not a substitute for '
              'talking to someone.',
          'Cohort studies of psychological distress in infertility · '
              'independent',
          false),
    ],
    hue: 222,
    band: TtcRecoBand.buy,
    evidence: TtcEvidence.mixed,
    verdict: 'The only thing on this list aimed at the part of trying that '
        'nobody prepares you for.',
    goods: [
      'The waiting is the hard part, and almost nothing sold for fertility is '
          'about it.',
      'One copy, read by both of you, is worth more than two separate ones.',
    ],
    watchOuts: [
      'A book is not treatment, and it is not a substitute for talking to '
          'somebody if this is getting heavy.',
      'Avoid anything promising a method, a protocol or a number of days. '
          'That is a different genre wearing the same cover.',
    ],
    specs: [
      ('Format', 'One copy, both of you'),
      ('What it is not', 'A protocol or a plan'),
    ],
    category: 'books',
    nameEn: 'A book about the waiting, not the trying',
    nameHi: 'Intezaar ke baare mein ek kitaab, koshish ke baare mein nahi',
    whyEn:
        'Most fertility books are manuals. The ones couples actually finish are the ones about how this feels - and reading the same thing gives you both the same words for it.',
    whyHi:
        'Zyadatar fertility kitaabein manual hoti hain. Jo couples sach mein poori padhte hain wo ye batati hain ki ye mehsoos kaisa hota hai - aur ek hi cheez padhne se aap dono ko uske liye ek hi shabd milte hain.',
    lookForEn: 'Something you will both read. One copy, not two.',
    lookForHi: 'Aisi kuch jo aap dono padhein. Ek copy, do nahi.',
    watchOutEn:
        'Avoid anything promising a protocol that guarantees conception in a set number of months. Nothing can promise that, and a book that does is selling hope by the chapter.',
    watchOutHi:
        'Aisi kisi bhi cheez se bachein jo kehti ho ki itne mahinon mein conception pakka. Koi ye vaada nahi kar sakta, aur jo kitaab karti hai wo chapter ke hisaab se ummeed bech rahi hai.',
    priceEn: '₹300 – ₹800',
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
      ('Convenience, if you want it', false),
      ('Cheaper as separate parts', true),
      ('Check for vitamin A', true),
    ],
    voices: [
      ('Nikita P.', 2, 'Trying 7 months',
          'Fifteen hundred a month for what turned out to be folic acid and a '
              'multivitamin. I read the box properly the fourth month.'),
      ('Aparna R.', 4, 'Trying 1 year',
          'One tablet instead of three is worth something to me. I know I am '
              'paying for the convenience.'),
      ('Juhi S.', 1, 'Trying 3 years',
          'Nothing on the box is untrue and nothing on it is proven either. '
              'That is the whole problem with this category.'),
    ],
    inside: [
      ('Folic acid', 'the part with evidence',
          'A good blend contains the 400 mcg you actually need. This is the '
              'ingredient doing the work.',
          'It costs about ninety rupees on its own.'),
      ('Antioxidant mix', 'the part being sold',
          'Vitamins C and E, selenium and similar. Plausible-sounding, and not '
              'shown to help anyone conceive.',
          ''),
      ('Vitamin A', 'the one to check',
          'Some general multivitamins carry retinol at levels that are not '
              'appropriate for somebody who might conceive.',
          'Turn the box over and look for retinol or retinyl palmitate before '
              'you buy any multivitamin while trying.'),
    ],
    studies: [
      ('Do multi-ingredient fertility supplements work?',
          'Reviews of combination supplements marketed for fertility find the '
              'trials small, inconsistent and often unable to report live '
              'births. The folate component has evidence; the blends as sold '
              'do not.',
          'If you want the part that works, buy that part. The rest is being '
              'sold to you on how it sounds.',
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
        'price of buying what you actually need.',
    whyEn:
        'These are sold on plausible-sounding ingredients rather than on evidence that they help anyone conceive. That does not make them harmful — it makes them expensive, and it makes the guilt attached to not buying one unearned.',
    whyHi:
        'Ye un ingredients ke naam par bikte hain jo sunne mein theek lagte hain, is saboot par nahi ki inse conceive karne mein madad milti hai. Ye nuksaandeh nahi hain — bas mehnge hain, aur na khareedne par jo guilt hoti hai wo bejaa hai.',
    lookForEn:
        'If you do buy one, turn the box over: check it has 400 mcg of folic acid and check it does not carry high-dose vitamin A.',
    lookForHi:
        'Agar khareedna hi hai toh dabba palat kar dekhein: 400 mcg folic acid hai ya nahi, aur high-dose vitamin A toh nahi hai.',
    watchOutEn:
        'A blend containing 400 mcg of folic acid, bought instead of a folic acid tablet, is a more costly way to do the same thing. And general multivitamins sometimes carry vitamin A at levels that are not appropriate for somebody who might conceive.',
    watchOutHi:
        'Jis blend mein 400 mcg folic acid hai, use folic acid tablet ki jagah lena wahi kaam mehnge tareeke se karna hai. Aur aam multivitamins mein kabhi-kabhi vitamin A itna hota hai jo conceive karne waali ke liye theek nahi.',
    priceEn: '₹900 – ₹3,000 a month',
    goods: [
      'They are convenient — one tablet instead of two or three.',
      'A well-made one does contain the folic acid you actually need.',
    ],
    watchOuts: [
      'The folic acid inside is the part with evidence, and it costs a fraction '
          'of this on its own.',
      'Check for vitamin A, listed as retinol or retinyl palmitate. High doses '
          'are not safe in pregnancy.',
      'What you are actually short of is a blood test question — iron, B12 and '
          'vitamin D are the common ones here, and a blend guesses at all '
          'three.',
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
