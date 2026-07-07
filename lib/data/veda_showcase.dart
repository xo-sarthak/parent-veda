// =============================================================================
//  veda_showcase - curated, structured "showcase" answers for Ask Veda
// -----------------------------------------------------------------------------
//  The product doc specifies a FIXED structured result page (Veda Answer → what
//  it means → next actions → ParentVeda content → community → products →
//  services). We can't yet generate that for every question (no LLM backend), so
//  these are 5 hand-authored, web-researched answers that demo the full format.
//  When the question matches one of these, Ask Veda returns the structured card;
//  everything else falls through to the offline whole-app retrieval.
//
//  Content is general guidance written for ParentVeda (informed by NHS / Tommy's
//  / Mayo Clinic guidance) - never a diagnosis; the doctor disclaimer always
//  shows, and the reduced-movements entry is emergency-aware.
// =============================================================================

import '../localization/app_language.dart';

class VedaShowcase {
  const VedaShowcase({
    required this.id,
    required this.question,
    required this.keywords,
    this.urgent = false,
    required this.answer,
    required this.meaning,
    required this.actions,
    required this.pvContent,
    required this.community,
    this.products = const [],
    required this.services,
  });

  final String id;
  final LocalizedText question; // the showcase question (shown to the user)
  final List<String> keywords; // lowercase match terms
  final bool urgent; // emergency-aware → red banner
  final LocalizedText answer; // S1 - the single best answer
  final LocalizedText meaning; // S2 - what this means for you
  final List<LocalizedText> actions; // S3 - recommended next actions
  final List<LocalizedText> pvContent; // S4 - ParentVeda content/tools
  final LocalizedText community; // S5 - community insight
  final List<LocalizedText> products; // S6 - products (may be empty → hide)
  final List<LocalizedText> services; // S7 - services
}

const List<VedaShowcase> kVedaShowcase = [
  // ---------------------------------------------------------------------------
  VedaShowcase(
    id: 'anomaly_scan',
    question: LocalizedText(
        en: 'When should I have my anomaly scan?',
        hi: 'Mera anomaly scan kab hona chahiye?'),
    keywords: [
      'anomaly scan',
      '20 week scan',
      'mid pregnancy scan',
      'anomaly',
      'scan timing',
      // Hinglish
      'anomaly scan kab',
      'scan kab hona',
    ],
    answer: LocalizedText(
      en: "Your anomaly scan (the '20-week scan') is usually done between 18 and 21 weeks. It's a detailed ~30-minute ultrasound that checks your baby's growth and looks closely at the brain, heart, spine, face, kidneys and other organs, plus the placenta. It's offered to everyone, and it's your choice.",
      hi: "Aapka anomaly scan (jise '20-week scan' kehte hain) aam taur par 18 se 21 week ke beech hota hai. Ye ek detailed ~30-minute ka ultrasound hai jo baby ki growth dekhta hai aur dimaag, dil, reedh ki haddi, chehra, kidney aur dusre organs, plus placenta ko gaur se check karta hai. Ye sabko offer hota hai, aur ye aapki marzi hai.",
    ),
    meaning: LocalizedText(
      en: "You're around week 20 - right in the window for this scan. It's one of the most detailed, reassuring looks at how your baby is developing.",
      hi: "Aap karib week 20 par ho - bilkul is scan ke window mein. Ye baby ki development dekhne ke sabse detailed aur reassuring tareekon mein se ek hai.",
    ),
    actions: [
      LocalizedText(
          en: "If you haven't booked it, contact your hospital/clinic to schedule it for 18–21 weeks.",
          hi: "Agar abhi tak book nahi kiya, to apne hospital/clinic se 18–21 week ke liye schedule karwa lo."),
      LocalizedText(
          en: "Ask your clinic if they want you to drink water beforehand.",
          hi: "Clinic se pooch lo ki scan se pehle paani peena hai ya nahi."),
      LocalizedText(
          en: "Jot down any questions for the sonographer.",
          hi: "Sonographer ke liye apne sawaal likh lo."),
      LocalizedText(
          en: "Add the appointment to your ParentVeda Calendar.",
          hi: "Appointment ko apne ParentVeda Calendar mein add kar lo."),
    ],
    pvContent: [
      LocalizedText(
          en: 'Week 20 Journey - baby development',
          hi: 'Week 20 Journey - baby development'),
      LocalizedText(
          en: "'Your scans' in the weekly flow",
          hi: "Weekly flow mein 'Your scans'"),
      LocalizedText(
          en: 'Calendar - log your appointment',
          hi: 'Calendar - apna appointment log karo'),
    ],
    community: LocalizedText(
      en: 'Mothers often ask what the anomaly scan checks - most call it the most reassuring scan of pregnancy.',
      hi: 'Mummies aksar poochti hain ki anomaly scan kya check karta hai - zyadatar ise pregnancy ka sabse reassuring scan kehti hain.',
    ),
    products: [],
    services: [
      LocalizedText(
          en: 'Scan centre / Sonography', hi: 'Scan centre / Sonography'),
      LocalizedText(
          en: 'Your gynaecologist / obstetrician',
          hi: 'Aapki gynaecologist / obstetrician'),
    ],
  ),
  // ---------------------------------------------------------------------------
  VedaShowcase(
    id: 'labour_signs',
    question: LocalizedText(
        en: 'What are the signs that labour is starting?',
        hi: 'Labour shuru hone ke signs kya hain?'),
    keywords: [
      'labour signs',
      'signs of labour',
      'labor',
      'contractions starting',
      'am i in labour',
      'when to go to hospital',
      // Hinglish
      'labour shuru',
      'labour ke signs',
      'labour kab',
      'delivery ke signs',
    ],
    answer: LocalizedText(
      en: "Common early signs of labour: a 'show' (a pinkish, jelly-like plug of mucus), contractions that get longer, stronger and closer together, backache or a heavy period-like ache, and your waters breaking (a trickle or a gush). Practice 'Braxton Hicks' tightenings are usually painless, irregular and don't build up.",
      hi: "Labour ke aam early signs: ek 'show' (gulaabi, jelly-jaisa mucus plug), contractions jo lambe, tez aur paas-paas hote jaate hain, kamar dard ya bhaari period-jaisa ache, aur paani ka toot-na (trickle ya gush). Practice 'Braxton Hicks' tightenings aam taur par dard-rahit, irregular hote hain aur build up nahi hote.",
    ),
    meaning: LocalizedText(
      en: "Near the end of pregnancy your body is preparing. Real labour contractions become regular and intensify, while practice ones fade. Before 37 weeks, these signs should be checked, as it could be early labour.",
      hi: "Pregnancy ke end ke paas aapka body taiyaari kar raha hota hai. Asli labour contractions regular aur tez hote jaate hain, jabki practice wale halke pad jaate hain. 37 week se pehle ye signs check karwana chahiye, kyunki ye early labour ho sakta hai.",
    ),
    actions: [
      LocalizedText(
          en: 'Time your contractions (our Contraction Timer tool helps).',
          hi: 'Apne contractions ka time dekho (humara Contraction Timer tool madad karta hai).'),
      LocalizedText(
          en: 'Most are advised to head to hospital when contractions are regular - about every 5 minutes, each lasting ~60 seconds.',
          hi: 'Zyadatar ko salah di jaati hai ki jab contractions regular ho jayein - karib har 5 minute mein, har ek ~60 second ka - tab hospital jaayein.'),
      LocalizedText(
          en: 'Call your midwife / maternity unit straight away if your waters break, you see bleeding, movements reduce, or it\'s before 37 weeks.',
          hi: 'Agar paani toot jaaye, bleeding dikhe, movements kam ho jayein, ya 37 week se pehle ho - to turant apni midwife / maternity unit ko call karo.'),
      LocalizedText(
          en: 'Keep your hospital bag ready.',
          hi: 'Apna hospital bag taiyaar rakho.'),
    ],
    pvContent: [
      LocalizedText(
          en: 'Contraction Timer tool', hi: 'Contraction Timer tool'),
      LocalizedText(en: 'Hospital Bag checklist', hi: 'Hospital Bag checklist'),
      LocalizedText(
          en: 'Week-by-week labour prep', hi: 'Week-by-week labour prep'),
    ],
    community: LocalizedText(
      en: 'A top question is telling real labour from Braxton Hicks - timing the contractions is the clearest way.',
      hi: 'Ek top sawaal hai asli labour ko Braxton Hicks se pehchan-na - contractions ka time dekhna sabse clear tareeka hai.',
    ),
    products: [
      LocalizedText(en: 'Hospital bag essentials', hi: 'Hospital bag essentials'),
    ],
    services: [
      LocalizedText(
          en: 'Maternity unit / Labour ward',
          hi: 'Maternity unit / Labour ward'),
      LocalizedText(
          en: 'Your obstetrician / midwife',
          hi: 'Aapki obstetrician / midwife'),
    ],
  ),
  // ---------------------------------------------------------------------------
  VedaShowcase(
    id: 'iron_foods',
    question: LocalizedText(
        en: 'What foods help boost my iron in pregnancy?',
        hi: 'Pregnancy mein iron badhane ke liye kaunse foods madad karte hain?'),
    keywords: [
      'iron',
      'iron rich foods',
      'hemoglobin',
      'haemoglobin',
      'anaemia',
      'anemia',
      'iron deficiency',
      'boost iron',
      // Hinglish
      'iron badhane',
      'iron wale food',
      'khoon ki kami',
    ],
    answer: LocalizedText(
      en: "In pregnancy you need about 27 mg of iron a day. Iron-rich foods include lean red meat, chicken, fish, eggs, lentils, beans, chickpeas, tofu, dark leafy greens like spinach, and iron-fortified cereals. Pair them with vitamin C (orange, lemon, tomato, bell pepper, amla) to absorb more iron - and keep tea/coffee away from mealtimes, as they reduce absorption.",
      hi: "Pregnancy mein aapko roz karib 27 mg iron chahiye. Iron-rich foods mein hain: lean red meat, chicken, fish, ande, dal, beans, chhole, tofu, dark leafy greens jaise palak, aur iron-fortified cereals. Inhe vitamin C (santra, nimbu, tamatar, shimla mirch, amla) ke saath khao taaki iron zyada absorb ho - aur chai/coffee ko khaane ke time se door rakho, kyunki ye absorption kam karte hain.",
    ),
    meaning: LocalizedText(
      en: "Your blood volume rises about 50% in pregnancy, so your iron needs jump. Enough iron helps prevent anaemia, which can leave you very tired, dizzy or breathless.",
      hi: "Pregnancy mein aapka blood volume karib 50% badh jaata hai, isliye iron ki zaroorat bhi badh jaati hai. Kaafi iron anaemia se bachata hai, jisse bahut thakaan, chakkar ya saans phoolna ho sakta hai.",
    ),
    actions: [
      LocalizedText(
          en: 'Include an iron-rich food at each main meal, with a vitamin-C food alongside.',
          hi: 'Har main meal mein ek iron-rich food rakho, saath mein ek vitamin-C wala food.'),
      LocalizedText(
          en: 'Keep tea and coffee between meals, not with them.',
          hi: 'Chai aur coffee khaane ke beech mein lo, khaane ke saath nahi.'),
      LocalizedText(
          en: 'Take your prescribed prenatal / iron supplement as advised.',
          hi: 'Apna prescribed prenatal / iron supplement salah ke mutabik lo.'),
      LocalizedText(
          en: 'If you feel very tired, dizzy or breathless, ask your doctor about a haemoglobin (Hb) test.',
          hi: 'Agar bahut thakaan, chakkar ya saans phoolne lage, to doctor se haemoglobin (Hb) test ke baare mein poocho.'),
    ],
    pvContent: [
      LocalizedText(
          en: 'Pregnancy nutrition reads', hi: 'Pregnancy nutrition reads'),
      LocalizedText(
          en: "'Can I eat…' food library", hi: "'Can I eat…' food library"),
      LocalizedText(en: 'Daily Learn - nutrition', hi: 'Daily Learn - nutrition'),
    ],
    community: LocalizedText(
      en: 'Iron and energy are among the most-asked nutrition topics - small daily swaps add up.',
      hi: 'Iron aur energy sabse zyada poochhe jaane wale nutrition topics mein se hain - chhote daily swaps kaam aate hain.',
    ),
    products: [],
    services: [
      LocalizedText(
          en: 'Dietitian / nutritionist', hi: 'Dietitian / nutritionist'),
      LocalizedText(
          en: 'Your gynaecologist (for Hb testing)',
          hi: 'Aapki gynaecologist (Hb testing ke liye)'),
    ],
  ),
  // ---------------------------------------------------------------------------
  VedaShowcase(
    id: 'sleep_back',
    question: LocalizedText(
        en: 'Is it safe to sleep on my back during pregnancy?',
        hi: 'Kya pregnancy mein peeth ke bal sona safe hai?'),
    keywords: [
      'sleep on back',
      'sleeping position',
      'sleep position',
      'back sleeping',
      'which side to sleep',
      'sleep on side',
      // Hinglish
      'peeth ke bal',
      'peeth ke bal sona',
      'kis karwat sona',
      'kis taraf sona',
    ],
    answer: LocalizedText(
      en: "Up to about 28 weeks, back-sleeping is generally fine. From 28 weeks (third trimester), the advice is to GO TO SLEEP ON YOUR SIDE - research links going to sleep on your back in the third trimester with a higher stillbirth risk, because the womb can press on a major blood vessel and reduce blood flow to your baby. Either side is fine. If you wake up on your back, don't panic - just roll onto your side.",
      hi: "Karib 28 week tak, peeth ke bal sona aam taur par theek hai. 28 week se (third trimester), salah hai ki KARWAT LEKAR SOYEIN - research third trimester mein peeth ke bal sone ko zyada stillbirth risk se jodti hai, kyunki garbh ek badi blood vessel par dabaav daal sakta hai aur baby tak blood flow kam kar sakta hai. Koi bhi side theek hai. Agar aap peeth ke bal jaag jaayein, to ghabrao mat - bas karwat le lo.",
    ),
    meaning: LocalizedText(
      en: "You're around week 20, so it isn't a worry yet - but it's a good habit to start settling on your side now, so it feels natural by the third trimester.",
      hi: "Aap karib week 20 par ho, to abhi ye chinta ki baat nahi - lekin abhi se karwat lekar sone ki aadat daalna achha hai, taaki third trimester tak ye natural lage.",
    ),
    actions: [
      LocalizedText(
          en: 'From the third trimester, start going to sleep on your side (left or right).',
          hi: 'Third trimester se, karwat (left ya right) lekar sona shuru karo.'),
      LocalizedText(
          en: 'Use a pillow between your knees or a pregnancy pillow to stay comfy on your side.',
          hi: 'Ghutno ke beech takiya ya pregnancy pillow use karo taaki karwat par comfy raho.'),
      LocalizedText(
          en: 'If you wake on your back, simply turn onto your side - no need to worry.',
          hi: 'Agar peeth ke bal jaago, to bas karwat le lo - chinta ki koi baat nahi.'),
    ],
    pvContent: [
      LocalizedText(en: 'Sleep & comfort reads', hi: 'Sleep & comfort reads'),
      LocalizedText(
          en: "Weekly 'for you, mum' tips", hi: "Weekly 'for you, mum' tips"),
    ],
    community: LocalizedText(
      en: 'Side-sleeping and pillows are a top comfort topic in the third trimester.',
      hi: 'Karwat lekar sona aur takiye third trimester ka top comfort topic hain.',
    ),
    products: [
      LocalizedText(en: 'Pregnancy pillow', hi: 'Pregnancy pillow'),
    ],
    services: [
      LocalizedText(
          en: 'Your midwife (if sleep worries persist)',
          hi: 'Aapki midwife (agar neend ki chinta bani rahe)'),
    ],
  ),
  // ---------------------------------------------------------------------------
  VedaShowcase(
    id: 'reduced_movements',
    urgent: true,
    question: LocalizedText(
        en: 'My baby is moving less today - what should I do?',
        hi: 'Mera baby aaj kam move kar raha hai - main kya karoon?'),
    keywords: [
      'baby moving less',
      'reduced movements',
      'less movement',
      'baby not moving',
      'fewer kicks',
      'reduced fetal movement',
      // Hinglish
      'kam move',
      'baby kam move',
      'kam hil',
      'movement kam',
    ],
    answer: LocalizedText(
      en: "If your baby is moving less than usual, contact your maternity unit straight away - do not wait, even in the middle of the night. Reduced movements can be an important sign that needs checking. Do NOT rely on cold drinks, sugar or home tricks to make baby move - get checked.",
      hi: "Agar aapka baby aam se kam move kar raha hai, to turant apni maternity unit se contact karo - ruko mat, chahe aadhi raat ho. Kam movements ek important sign ho sakta hai jise check karna zaroori hai. Baby ko move karwane ke liye thande drinks, sugar ya ghar ke nuskhon par bharosa MAT karo - jaakar check karwao.",
    ),
    meaning: LocalizedText(
      en: "There's no set 'normal number' of movements - what matters is YOUR baby's usual pattern. Movements increase up to about 32 weeks and then stay roughly steady; they should not fade near the end. A drop from what's normal for your baby should always be checked.",
      hi: "Movements ka koi fixed 'normal number' nahi hota - jo maayne rakhta hai wo hai AAPKE baby ka usual pattern. Movements karib 32 week tak badhte hain phir lagbhag steady rehte hain; end ke paas inhe kam nahi hona chahiye. Aapke baby ke normal se kami hamesha check karwani chahiye.",
    ),
    actions: [
      LocalizedText(
          en: 'Call your maternity unit / labour ward now and tell them movements are reduced.',
          hi: 'Abhi apni maternity unit / labour ward ko call karo aur batao ki movements kam hain.'),
      LocalizedText(
          en: 'Lie on your left side and focus on movements while you arrange to be seen.',
          hi: 'Left karwat lekar leto aur movements par dhyaan do jab tak aap check karwane ka intezaam karti ho.'),
      LocalizedText(
          en: "Go in to be checked - they'll listen to baby's heartbeat and may monitor.",
          hi: 'Jaakar check karwao - wo baby ki heartbeat sunenge aur monitor kar sakte hain.'),
      LocalizedText(
          en: 'Never wait until tomorrow.', hi: 'Kabhi kal tak intezaar mat karo.'),
    ],
    pvContent: [
      LocalizedText(
          en: 'Baby Movements / Kick Counter tool',
          hi: 'Baby Movements / Kick Counter tool'),
      LocalizedText(
          en: "'Your baby's movements' read",
          hi: "'Your baby's movements' read"),
    ],
    community: LocalizedText(
      en: 'This is one of the most important things to act on fast - mothers are always encouraged to get checked, never to wait.',
      hi: 'Ye un sabse important cheezon mein se hai jis par jaldi act karna chahiye - mummies ko hamesha check karwane ki salah di jaati hai, kabhi wait karne ki nahi.',
    ),
    products: [],
    services: [
      LocalizedText(
          en: 'Maternity unit / Labour ward (now)',
          hi: 'Maternity unit / Labour ward (abhi)'),
      LocalizedText(
          en: 'Your obstetrician / midwife',
          hi: 'Aapki obstetrician / midwife'),
    ],
  ),
];
