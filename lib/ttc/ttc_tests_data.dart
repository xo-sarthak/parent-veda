// =============================================================================
//  TTC - the medical test library
// -----------------------------------------------------------------------------
//  "Medical reports: AMH, FSH, LH, TSH, Vitamin D, Vitamin B12, HbA1c, Semen
//   Analysis, Ultrasound, HSG."                          - TTC master, §3.8
//
//  The point of this library is not to list tests. It is to answer the question
//  a couple actually has standing in a diagnostic centre in India: *is this one
//  worth doing, what will it tell us, and what do we do with the number?*
//
//  So every entry carries what it measures, why it is done, WHEN in the cycle
//  it has to be taken (getting this wrong is the single most common reason a
//  fertility test has to be repeated), a real Indian price range, and how to
//  read the result without over-reading it.
//
//  Prices are indicative ranges for private labs in Indian metros as of 2026
//  and will drift. They are here because "get an AMH test" without a number
//  attached is not usable advice for most families.
//
//  NOTHING HERE DIAGNOSES. Every entry ends up under a disclaimer, and several
//  exist specifically to talk a couple DOWN from over-interpreting a number.
// =============================================================================

class TtcTest {
  const TtcTest({
    required this.id,
    required this.name,
    required this.forHim,
    required this.whatEn,
    required this.whatHi,
    required this.whyEn,
    required this.whyHi,
    required this.whenEn,
    required this.whenHi,
    required this.costEn,
    required this.costHi,
    required this.readingEn,
    required this.readingHi,
  });

  final String id;
  final String name;

  /// True when this is a test for him. Roughly half the value of this library
  /// is that his tests are listed beside hers rather than in a footnote.
  final bool forHim;

  final String whatEn;
  final String whatHi;
  final String whyEn;
  final String whyHi;
  final String whenEn;
  final String whenHi;
  final String costEn;
  final String costHi;

  /// How to read the result - and, more often, how not to over-read it.
  final String readingEn;
  final String readingHi;

  String what(bool hi) => hi ? whatHi : whatEn;
  String why(bool hi) => hi ? whyHi : whyEn;
  String when(bool hi) => hi ? whenHi : whenEn;
  String cost(bool hi) => hi ? costHi : costEn;
  String reading(bool hi) => hi ? readingHi : readingEn;
}

const List<TtcTest> ttcTests = [
  TtcTest(
    id: 'tsh',
    name: 'TSH (thyroid)',
    forHim: false,
    whatEn: 'How hard your body is pushing your thyroid to work.',
    whatHi: 'Aapka body thyroid se kitna kaam karwa raha hai.',
    whyEn:
        'An underactive thyroid causes irregular cycles, disrupts ovulation and raises the risk of early miscarriage. It is common in Indian women and often has no obvious symptoms.',
    whyHi:
        'Kam kaam karta thyroid irregular cycles karta hai, ovulation bigaadta hai aur shuruaati miscarriage ka khatra badhata hai. Ye Indian auraton mein aam hai aur aksar iske saaf symptoms nahi hote.',
    whenEn: 'Any day of the cycle. Fasting is not required.',
    whenHi: 'Cycle ke kisi bhi din. Khaali pet hona zaroori nahi.',
    costEn: '₹150 – ₹400',
    costHi: '₹150 – ₹400',
    readingEn:
        'Many fertility specialists prefer TSH below 2.5 when trying, which is stricter than the general lab range - so a result marked "normal" may still be worth discussing. Treatment is usually a single daily tablet.',
    readingHi:
        'Bahut se fertility specialists koshish ke dauraan TSH 2.5 se neeche pasand karte hain, jo aam lab range se sakht hai - toh "normal" likha result bhi baat karne layak ho sakta hai. Ilaaj aam taur par roz ki ek goli hoti hai.',
  ),
  TtcTest(
    id: 'amh',
    name: 'AMH',
    forHim: false,
    whatEn: 'A rough estimate of how many eggs remain - the size of the reserve.',
    whatHi: 'Kitne eggs bache hain iska mota andaaza - reserve ka size.',
    whyEn:
        'Mainly used to predict how ovaries will respond to IVF stimulation. It is a planning number for a specialist, not a fertility score.',
    whyHi:
        'Zyadatar ye batane ke liye ki ovaries IVF stimulation par kaisa jawab denge. Ye specialist ke liye planning ka number hai, fertility score nahi.',
    whenEn: 'Any day of the cycle - AMH is stable across the month.',
    whenHi: 'Cycle ke kisi bhi din - AMH poore mahine sthir rehta hai.',
    costEn: '₹1,200 – ₹2,500',
    costHi: '₹1,200 – ₹2,500',
    readingEn:
        'It says almost nothing about egg QUALITY, and on its own it is a poor predictor of natural conception. A low AMH with regular cycles is not a verdict. The useful question to ask your doctor is: what does this number change about our plan? If the answer is nothing, it changes nothing.',
    readingHi:
        'Ye egg ki QUALITY ke baare mein lagbhag kuch nahi batata, aur akele ye natural conception ka kharaab predictor hai. Regular cycles ke saath kam AMH koi faisla nahi hai. Doctor se poochhne layak sawaal: ye number hamare plan mein kya badalta hai? Agar jawab "kuch nahi" hai, toh sach mein kuch nahi badalta.',
  ),
  TtcTest(
    id: 'fsh_lh',
    name: 'FSH and LH',
    forHim: false,
    whatEn: 'The two pituitary hormones that drive the ovaries each cycle.',
    whatHi: 'Do pituitary hormones jo har cycle ovaries ko chalate hain.',
    whyEn:
        'Read together they help explain irregular or absent cycles, and the ratio between them is one of the signals used when PCOS is suspected.',
    whyHi:
        'Saath mein padhne par ye irregular ya band cycles samjhane mein madad karte hain, aur inka aapasi anupaat un signals mein hai jinse PCOS ka shak hota hai.',
    whenEn:
        'Day 2 or 3 of the cycle - counted from the first day of full flow. Taken on the wrong day, the result is not interpretable and has to be repeated.',
    whenHi:
        'Cycle ke din 2 ya 3 - poore flow ke pehle din se ginti. Galat din liya gaya result samajh mein nahi aata aur dobara karwana padta hai.',
    costEn: '₹500 – ₹1,200 for both',
    costHi: '₹500 – ₹1,200 dono ke liye',
    readingEn:
        'This is the test most often wasted by being taken on the wrong day. If your cycles are irregular and day 2 is hard to identify, ask your doctor when to go rather than guessing.',
    readingHi:
        'Ye wo test hai jo sabse zyada galat din liye jaane se barbaad hota hai. Agar aapke cycles irregular hain aur din 2 pehchaanna mushkil hai, toh andaaza lagane ke bajaye doctor se poochhein ki kab jaana hai.',
  ),
  TtcTest(
    id: 'semen',
    name: 'Semen analysis',
    forHim: true,
    whatEn: 'Sperm count, movement and shape, plus semen volume.',
    whatHi: 'Sperm ki ginti, chaal aur aakaar, aur semen ki matra.',
    whyEn:
        'A male factor is involved in roughly forty to fifty per cent of couples who struggle - yet the woman is usually investigated first, through tests that are slower, costlier and more invasive. This one is cheap, same-day and non-invasive.',
    whyHi:
        'Jo couples mushkil jhelte hain unmein lagbhag chalis se pachas pratishat mein mard ka factor hota hai - phir bhi aam taur par pehle aurat ke test hote hain, jo dheere, mehnge aur zyada takleefdeh hote hain. Ye sasta, usi din ka aur bina takleef ka hai.',
    whenEn:
        'After two to five days without ejaculation. Less or more than that changes the result.',
    whenHi:
        'Do se paanch din bina ejaculation ke baad. Isse kam ya zyada hone par result badal jaata hai.',
    costEn: '₹300 – ₹1,000',
    costHi: '₹300 – ₹1,000',
    readingEn:
        'Results vary a great deal between samples, including in men with no problem at all. One unexpected result is not a conclusion - repeat it after two to three months, which is also roughly how long it takes for lifestyle changes to show.',
    readingHi:
        'Samples ke beech results kaafi badalte hain, un mardon mein bhi jinhe koi dikkat nahi. Ek unexpected result nateeja nahi hai - do-teen mahine baad dobara karwayein, jo lagbhag utna hi samay hai jitna lifestyle badlaav dikhne mein lagta hai.',
  ),
  TtcTest(
    id: 'vitd',
    name: 'Vitamin D',
    forHim: false,
    whatEn: 'How much vitamin D is circulating in your blood.',
    whatHi: 'Aapke khoon mein kitna vitamin D chal raha hai.',
    whyEn:
        'A majority of Indian adults are low, including people who spend time outdoors. Low levels are linked to cycle irregularity and to sperm quality, so it is worth testing both of you.',
    whyHi:
        'Zyadatar Indian adults mein kami hai, un logon mein bhi jo dhoop mein rehte hain. Kam level cycle ki irregularity aur sperm quality dono se juda hai, toh dono ka test karwana theek hai.',
    whenEn: 'Any day. No fasting needed.',
    whenHi: 'Kisi bhi din. Khaali pet hona zaroori nahi.',
    costEn: '₹500 – ₹1,500',
    costHi: '₹500 – ₹1,500',
    readingEn:
        'Test before supplementing rather than after - the dose depends on how low you are, and high-dose weekly sachets are commonly sold without anyone checking whether you needed them.',
    readingHi:
        'Supplement lene se pehle test karwayein, baad mein nahi - dose is par nirbhar hai ki kami kitni hai, aur high-dose weekly sachets aam taur par bina ye dekhe bech diye jaate hain ki aapko zaroorat thi ya nahi.',
  ),
  TtcTest(
    id: 'b12',
    name: 'Vitamin B12',
    forHim: false,
    whatEn: 'Your B12 level.',
    whatHi: 'Aapka B12 level.',
    whyEn:
        'Deficiency is very common in Indian vegetarians and is linked to ovulation problems and to early pregnancy risk.',
    whyHi:
        'Indian vegetarians mein iski kami bahut aam hai, aur ye ovulation ki dikkat aur shuruaati pregnancy ke khatre se judi hai.',
    whenEn: 'Any day.',
    whenHi: 'Kisi bhi din.',
    costEn: '₹500 – ₹1,200',
    costHi: '₹500 – ₹1,200',
    readingEn:
        'If you have been taking a B12 supplement, say so - it raises the measured level and can mask a deficiency that is still there in your tissues.',
    readingHi:
        'Agar aap B12 supplement le rahe hain toh bata dein - isse naapa gaya level badh jaata hai aur wo kami chhup sakti hai jo tissues mein abhi bhi hai.',
  ),
  TtcTest(
    id: 'hba1c',
    name: 'HbA1c (blood sugar)',
    forHim: false,
    whatEn: 'Your average blood sugar over roughly the last three months.',
    whatHi: 'Pichhle lagbhag teen mahine ka aapka average blood sugar.',
    whyEn:
        'Insulin resistance is central to PCOS and affects ovulation. India has one of the highest rates of diabetes in the world, and it is frequently undiagnosed at the age most couples are trying.',
    whyHi:
        'Insulin resistance PCOS ka kendra hai aur ovulation par asar daalta hai. India mein duniya ki sabse zyada diabetes dar mein se ek hai, aur jis umar mein zyadatar couples koshish karte hain us umar mein ye aksar pakda nahi jaata.',
    whenEn: 'Any day. Unlike a fasting sugar test, this one needs no fasting.',
    whenHi: 'Kisi bhi din. Fasting sugar test ke ulat, iske liye khaali pet hona zaroori nahi.',
    costEn: '₹400 – ₹800',
    costHi: '₹400 – ₹800',
    readingEn:
        'Worth doing before pregnancy rather than during: sugar control in the first weeks matters, and those weeks pass before most women know they are pregnant.',
    readingHi:
        'Pregnancy ke dauraan nahi, pehle karwana theek hai: pehle hafton mein sugar ka control maayne rakhta hai, aur wo hafte tab guzar jaate hain jab zyadatar auraton ko pata bhi nahi hota.',
  ),
  TtcTest(
    id: 'ultrasound',
    name: 'Pelvic ultrasound',
    forHim: false,
    whatEn: 'A scan of the uterus and ovaries.',
    whatHi: 'Uterus aur ovaries ka scan.',
    whyEn:
        'Shows fibroids, ovarian cysts, the polycystic appearance seen in PCOS, and the thickness of the uterine lining. It can also be used across a cycle to watch a follicle grow, which is the most direct way to confirm ovulation.',
    whyHi:
        'Fibroids, ovarian cysts, PCOS mein dikhne wala polycystic roop, aur uterus ki lining ki motai dikhata hai. Ise cycle bhar follicle ka badhna dekhne ke liye bhi istemaal kiya ja sakta hai, jo ovulation confirm karne ka sabse seedha tareeka hai.',
    whenEn:
        'Usually early in the cycle for a baseline. Follicle tracking runs across several visits mid-cycle.',
    whenHi:
        'Baseline ke liye aam taur par cycle ki shuruaat mein. Follicle tracking mein cycle ke beech kai visits hoti hain.',
    costEn: '₹800 – ₹2,500',
    costHi: '₹800 – ₹2,500',
    readingEn:
        'A "polycystic appearance" on a scan is not by itself a PCOS diagnosis - it is one of three criteria, and plenty of women have it without the condition.',
    readingHi:
        'Scan par "polycystic appearance" akele PCOS ka diagnosis nahi hai - ye teen mein se ek criteria hai, aur bahut si auraton mein ye bina condition ke bhi hota hai.',
  ),
  TtcTest(
    id: 'hsg',
    name: 'HSG (tube test)',
    forHim: false,
    whatEn:
        'An X-ray taken while dye is passed through the uterus, to see whether the fallopian tubes are open.',
    whatHi:
        'Uterus se dye guzaarte hue liya gaya X-ray, ye dekhne ke liye ki fallopian tubes khuli hain ya nahi.',
    whyEn:
        'Blocked tubes are a common and completely silent cause. No amount of timing helps if the path is closed, which is why this is usually done before moving to treatment.',
    whyHi:
        'Band tubes ek aam aur bilkul chupchaap wajah hain. Agar raasta band hai toh koi bhi timing kaam nahi karti - isiliye ye aam taur par treatment par jaane se pehle hota hai.',
    whenEn:
        'Between the end of your period and ovulation - after bleeding stops, before an egg is released.',
    whenHi:
        'Period khatam hone aur ovulation ke beech - bleeding rukne ke baad, egg release hone se pehle.',
    costEn: '₹2,000 – ₹5,000',
    costHi: '₹2,000 – ₹5,000',
    readingEn:
        'It is uncomfortable and it is normal to be nervous about it - ask about pain relief beforehand rather than hoping. Some studies find a small rise in conception in the months right after, thought to be a flushing effect.',
    readingHi:
        'Ye takleefdeh hota hai aur ismein ghabraahat hona normal hai - ummeed karne ke bajaye pehle hi dard ki dawai ke baare mein poochhein. Kuch studies iske turant baad ke mahinon mein conception mein halka izaafa paati hain, jise flushing ka asar maana jaata hai.',
  ),
  TtcTest(
    id: 'prolactin',
    name: 'Prolactin',
    forHim: false,
    whatEn: 'The hormone that drives milk production.',
    whatHi: 'Wo hormone jo doodh banne ko chalata hai.',
    whyEn:
        'When it is high outside breastfeeding it can suppress ovulation entirely. It is a straightforward thing to find and usually straightforward to treat.',
    whyHi:
        'Breastfeeding ke bahar jab ye zyada hota hai toh ovulation poori tarah rok sakta hai. Ise pakadna seedha hai aur ilaaj bhi aam taur par seedha hota hai.',
    whenEn:
        'Morning, and ideally not straight after exercise, stress or a breast examination - all of which raise it temporarily.',
    whenHi:
        'Subah, aur behtar hai ki exercise, stress ya breast examination ke turant baad nahi - ye sab ise thodi der ke liye badha dete hain.',
    costEn: '₹300 – ₹700',
    costHi: '₹300 – ₹700',
    readingEn:
        'A single mildly high result is often just the morning it was taken. It is normally repeated before anyone acts on it.',
    readingHi:
        'Ek baar ka halka zyada result aksar bas us subah ki baat hoti hai. Ispar kuch karne se pehle aam taur par dobara karwaya jaata hai.',
  ),
];

List<TtcTest> ttcTestsFor({required bool him}) =>
    ttcTests.where((t) => t.forHim == him).toList();

TtcTest? ttcTestById(String id) {
  for (final t in ttcTests) {
    if (t.id == id) return t;
  }
  return null;
}
