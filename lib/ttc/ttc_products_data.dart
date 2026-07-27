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
  TtcProduct(
    id: 'zinc',
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
];

List<TtcProduct> ttcProductsIn(String category) =>
    ttcProducts.where((p) => p.category == category).toList();
