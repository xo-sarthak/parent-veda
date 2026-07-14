// =============================================================================
//  Week 5 — FULL page content (bilingual)
// -----------------------------------------------------------------------------
//  The complete, doc-faithful Week 5 content authored for the "Full" weekly
//  flow (Week5FullFlowView), a preview alternative to the schema-driven V2 flow.
//  Sections mirror the content doc exactly: Opening Snapshot · About Your Baby ·
//  Baby Science · You This Week · Health (Symptoms + Diet) · Trimester Tips ·
//  Share With Partner. Every leaf is a bilingual LocalizedText (en + romanised
//  Hinglish). Medical framing kept non-diagnostic; a doctor disclaimer is shown
//  by the screen. Not wired to weekContent.json on purpose — this is the richer
//  shape we may later promote into the schema for all weeks.
// =============================================================================

import '../localization/app_language.dart';

LocalizedText _t(String en, String hi) => LocalizedText(en: en, hi: hi);

// ---- section models ---------------------------------------------------------
class W5Snapshot {
  const W5Snapshot({required this.fruit, required this.length, required this.weight});
  final LocalizedText fruit;
  final LocalizedText length;
  final LocalizedText weight;
}

class W5About {
  const W5About({
    required this.teaser,
    required this.opening,
    required this.howBig,
    required this.whatsHappening,
  });
  final LocalizedText teaser; // cover teaser (before tap)
  final LocalizedText opening;
  final LocalizedText howBig;
  final LocalizedText whatsHappening;
}

class W5Card {
  const W5Card({required this.title, required this.body});
  final LocalizedText title;
  final LocalizedText body;
}

class W5Highlight {
  const W5Highlight({required this.title, required this.teaser, required this.body});
  final LocalizedText title;
  final LocalizedText teaser;
  final LocalizedText body;
}

class W5You {
  const W5You({
    required this.feeling,
    required this.changingBody,
    required this.beKind,
    required this.highlights,
    required this.selfCare,
  });
  final LocalizedText feeling;
  final LocalizedText changingBody;
  final LocalizedText beKind;
  final List<W5Highlight> highlights;
  final LocalizedText selfCare;
}

class W5Symptom {
  const W5Symptom({
    required this.name,
    required this.teaser,
    required this.howCommon,
    required this.why,
    required this.helps,
    required this.whenDoctor,
  });
  final LocalizedText name;
  final LocalizedText teaser;
  final LocalizedText howCommon;
  final LocalizedText why;
  final List<LocalizedText> helps;
  final LocalizedText whenDoctor;
}

class W5Superfood {
  const W5Superfood({
    required this.food,
    required this.benefit,
    required this.tryAs,
    required this.note,
  });
  final LocalizedText food;
  final LocalizedText benefit;
  final LocalizedText tryAs;
  final LocalizedText note;
}

class W5Diet {
  const W5Diet({required this.superfood, required this.favour, required this.avoid});
  final W5Superfood superfood;
  final List<W5Card> favour;
  final List<W5Card> avoid;
}

class W5Tip {
  const W5Tip({required this.oneLine, required this.readMore});
  final LocalizedText oneLine;
  final LocalizedText readMore;
}

class W5Scan {
  const W5Scan({required this.name, required this.window});
  final LocalizedText name;
  final LocalizedText window;
}

class W5Partner {
  const W5Partner({
    required this.baby,
    required this.mother,
    required this.scans,
    required this.help,
  });
  final LocalizedText baby;
  final LocalizedText mother;
  final List<W5Scan> scans;
  final List<LocalizedText> help;
}

class Week5Full {
  const Week5Full({
    required this.trimesterMonth,
    required this.snapshot,
    required this.about,
    required this.science,
    required this.you,
    required this.symptoms,
    required this.diet,
    required this.tips,
    required this.partner,
  });
  final LocalizedText trimesterMonth;
  final W5Snapshot snapshot;
  final W5About about;
  final List<W5Card> science;
  final W5You you;
  final List<W5Symptom> symptoms;
  final W5Diet diet;
  final List<W5Tip> tips;
  final W5Partner partner;
}

// =============================================================================
//  THE CONTENT
// =============================================================================
final Week5Full week5Full = Week5Full(
  trimesterMonth: _t('Trimester 1 · Month 2', 'Trimester 1 · Month 2'),

  // ---- 1 · Opening Snapshot -------------------------------------------------
  snapshot: W5Snapshot(
    fruit: _t('Sesame seed', 'Til ka daana'),
    length: _t('0.2 cm', '0.2 cm'),
    weight: _t('Too small to measure', 'Maapne ke liye bahut chhota'),
  ),

  // ---- 2 · About Your Baby --------------------------------------------------
  about: W5About(
    teaser: _t(
      'This is the week my brain and spine begin to take shape, from a small groove of cells quietly folding into something remarkable.',
      'Yeh woh hafta hai jab mera brain aur spine banna shuru hote hain — cells ki ek chhoti si groove chupchaap kuch khaas mein badalne lagti hai.',
    ),
    opening: _t(
      "Right now I'm about the size of a sesame seed, but I'm busy in a way you can't yet see. The tube that will become my brain and spinal cord is forming along my back, and the cluster of cells that will one day beat as my heart is taking shape.",
      'Abhi main lagbhag til ke daane jitna hoon, par main aise busy hoon jo tum abhi dekh nahi sakti. Jo tube mera brain aur spinal cord banegi woh meri peeth ke saath ban rahi hai, aur cells ka woh gucchha jo ek din mere dil ki tarah dhadkega, aakaar le raha hai.',
    ),
    howBig: _t(
      "I'm around 2 millimetres long, about a sesame seed. Far too small to feel, but growing a little more every single day.",
      'Main lagbhag 2 millimetre lamba hoon, ek til ke daane jitna. Mehsoos karne ke liye bahut chhota, par har din thoda aur badh raha hoon.',
    ),
    whatsHappening: _t(
      "This week my foundations are being laid. My neural tube is closing over, the structure that becomes my brain, spinal cord and backbone. My tiny heart tube may give its very first flutter around now, though it's far too soon for anyone to hear it. My own first blood vessels are appearing, and the cord that will connect us is beginning to form.",
      'Is hafte meri neenv rakhi ja rahi hai. Meri neural tube band ho rahi hai — wahi structure jo mera brain, spinal cord aur reedh ki haddi banega. Mera nanha heart tube shayad abhi apni pehli dhadkan de, halaanki ise sunne ke liye abhi bahut jaldi hai. Mere apne pehle blood vessels ubhar rahe hain, aur woh cord jo humein jodegi, banna shuru ho rahi hai.',
    ),
  ),

  // ---- 3 · Baby Science -----------------------------------------------------
  science: [
    W5Card(
      title: _t('My brain and spine are forming', 'Mera brain aur spine ban rahe hain'),
      body: _t(
        "Long before I look anything like a baby, a tiny groove is running down my back, and this week that groove is closing into the tube that will become my brain and spinal cord. It's the beginning of my entire nervous system. It's also why folic acid matters so much right now. It helps this delicate closing happen safely.",
        'Bahut pehle ki main baby jaisa dikhoon, meri peeth par ek chhoti si groove chal rahi hai, aur is hafte woh groove band hokar woh tube ban rahi hai jo mera brain aur spinal cord banegi. Yeh mere poore nervous system ki shuruaat hai. Isiliye folic acid abhi itna zaroori hai — woh is naazuk band hone ko surakshit tareeke se hone mein madad karta hai.',
      ),
    ),
    W5Card(
      title: _t('My heart begins its first beats', 'Mera dil apni pehli dhadkan leta hai'),
      body: _t(
        "Right now I don't have a heart the way you picture one. I have a tiny tube of cells. But around this week, that little tube may begin its first coordinated beats, the start of a rhythm it will keep for the rest of my life. It's far too early for anyone to hear it from the outside yet, but quietly, it's beginning.",
        'Abhi mere paas waisa dil nahi jaisa tum sochti ho. Mere paas cells ki ek nanhi tube hai. Par is hafte ke aaspaas woh chhoti tube apni pehli dhadkanein le sakti hai — ek aisi rhythm jo main zindagi bhar rakhoonga. Ise bahar se sunne ke liye abhi bahut jaldi hai, par chupchaap, yeh shuru ho raha hai.',
      ),
    ),
    W5Card(
      title: _t("I'm built from three layers", 'Main teen layers se ban raha hoon'),
      body: _t(
        "Much of my body plan is being built from three remarkable layers of cells, and each one has a job. One will become my skin, brain and nerves. The middle one will build my heart, bones and muscles. The innermost will grow my lungs and digestive system. Every part of me is quietly mapped out in these layers, waiting to unfold.",
        'Mere body ka zyada plan cells ki teen khaas layers se ban raha hai, aur har ek ka apna kaam hai. Ek meri skin, brain aur nerves banegi. Beech waali mera dil, haddiyan aur muscles banayegi. Sabse andar waali mere lungs aur digestive system ugayegi. Mera har hissa in layers mein chupchaap tay ho raha hai, khulne ka intezaar karta hua.',
      ),
    ),
    W5Card(
      title: _t('My lifeline is being built', 'Meri lifeline ban rahi hai'),
      body: _t(
        "While I'm forming, something just as important is growing beside me, the placenta. Think of it as my kitchen, my lungs and my waste system all in one, before any of my own are ready. Tiny finger-like structures are growing into the wall of your womb as the placenta begins taking shape, getting ready to pass oxygen and nourishment from you to me, and carry my waste away.",
        'Jabki main ban raha hoon, mere saath utni hi zaroori cheez badh rahi hai — placenta. Ise mera kitchen, mere lungs aur mera waste system samajh lo, ek hi mein, jab tak mere apne taiyaar na ho jayein. Nanhi ungliyon jaisi structures tumhare womb ki deewar mein badh rahi hain jab placenta aakaar le raha hai — taiyaar hota hua ki tumse mujh tak oxygen aur poshan pahunchaye, aur mera waste bahar le jaaye.',
      ),
    ),
    W5Card(
      title: _t('Our private supply line forms', 'Hamari niji supply line banti hai'),
      body: _t(
        "This week, the connection between us is becoming more organised. My first blood vessels are appearing, and the stalk that links me to the placenta is developing into what will become the umbilical cord, the private line that connects us for the whole journey. In time, everything I need will travel along it from you, long before I can do any of this for myself.",
        'Is hafte, hamare beech ka connection aur vyavasthit ho raha hai. Mere pehle blood vessels ubhar rahe hain, aur woh dandi jo mujhe placenta se jodti hai umbilical cord ban rahi hai — woh niji line jo poori journey humein jodti hai. Waqt ke saath, jo bhi mujhe chahiye woh isi ke zariye tumse aayega, bahut pehle ki main yeh khud kar sakoon.',
      ),
    ),
    W5Card(
      title: _t('My face begins to take shape', 'Mera chehra aakaar lene lagta hai'),
      body: _t(
        "It's early, but the very first foundations of my face are beginning to appear this week. Tiny clusters of cells that will become my eyes, ears and nose are just starting to form, like the faint pencil lines of a drawing before any details arrive. There's nothing to see from the outside yet, but the outline of the face you'll one day know is quietly beginning to emerge.",
        'Abhi jaldi hai, par mere chehre ki sabse pehli neenv is hafte dikhne lagti hai. Cells ke nanhe gucche jo meri aankhein, kaan aur naak banenge abhi banna shuru ho rahe hain — jaise kisi drawing ki halki pencil lines, detail aane se pehle. Bahar se abhi kuch dikhne ko nahi hai, par jis chehre ko tum ek din pehchanogi uski roop-rekha chupchaap ubharne lagi hai.',
      ),
    ),
  ],

  // ---- 4 · You This Week ----------------------------------------------------
  you: W5You(
    feeling: _t(
      "For many women, Week 5 is the week you find out. A missed period, a positive test, and suddenly everything feels different. The news can bring joy, disbelief and quiet worry all at once, sometimes within the same hour. Your body may already be giving you signals, more tiredness than usual, tender breasts, or waves of nausea, while some women feel completely normal and wonder if that's okay. It is. There is no single way to feel at five weeks. If you haven't already, this is a good week to confirm your pregnancy with your healthcare provider and think about booking your first prenatal appointment.",
      'Bahut si mahilaon ke liye, Week 5 wahi hafta hai jab pata chalta hai. Period miss hona, ek positive test, aur achanak sab kuch alag lagne lagta hai. Yeh khabar khushi, yakeen na hona aur halki fikr — sab ek saath la sakti hai, kabhi ek hi ghante mein. Tumhara body pehle se signals de raha ho sakta hai — aam se zyada thakaan, breast mein narmi, ya matli ki leherein — jabki kuch mahilaayein bilkul normal mehsoos karti hain aur sochti hain ki kya yeh theek hai. Haan, theek hai. Paanch hafte mein mehsoos karne ka koi ek tareeka nahi hota. Agar abhi tak nahi kiya, to yeh apni pregnancy doctor se confirm karne aur pehli prenatal appointment book karne ka accha hafta hai.',
    ),
    changingBody: _t(
      "On the outside, almost nothing looks different yet. There is no bump at five weeks, and there won't be for a while. But inside, a lot is already in motion. The hormone hCG is climbing quickly, which is what a pregnancy test picks up. Progesterone is rising too, helping maintain the lining of your womb and support this early pregnancy. Your breasts may feel fuller or tender as they respond to these hormones, and you might find yourself needing the bathroom more often. Small signals of a body already adapting.",
      'Bahar se abhi kuch khaas alag nahi dikhta. Paanch hafte mein koi bump nahi hota, aur kuch waqt tak nahi hoga. Par andar, bahut kuch pehle se ho raha hai. Hormone hCG tezi se badh raha hai — wahi jo pregnancy test pakadta hai. Progesterone bhi badh raha hai, jo tumhare womb ki lining ko banaye rakhne aur is shuruaati pregnancy ko support karne mein madad karta hai. Tumhare breasts in hormones ke jawaab mein bhare ya narm mehsoos ho sakte hain, aur tum baar-baar bathroom jaane ki zaroorat mehsoos kar sakti ho. Ek dhalte hue body ke chhote signals.',
    ),
    beKind: _t(
      "Be gentle with yourself this week. Your body is doing enormous, invisible work, and feeling tired or unsettled does not mean anything is wrong. Rest when you can, eat what stays down, and try not to measure yourself against how anyone else felt. This is your pregnancy, at your pace.",
      'Is hafte apne saath naram raho. Tumhara body bahut bada, andekha kaam kar raha hai, aur thakaan ya bechaini mehsoos hona iska matlab nahi ki kuch galat hai. Jab ho sake aaram karo, jo andar tik jaaye woh khao, aur khud ko kisi aur ke experience se mat naapo. Yeh tumhari pregnancy hai, tumhari raftaar par.',
    ),
    highlights: [
      W5Highlight(
        title: _t('Hormones', 'Hormones'),
        teaser: _t(
          "The rising hormones behind almost everything you're feeling.",
          'Badhte hormones — jo tumhare lagbhag har ehsaas ke peeche hain.',
        ),
        body: _t(
          "Two hormones are doing most of the work right now. hCG is the one a pregnancy test detects, and it climbs fast this week. Higher hCG is thought to add to early nausea, though the exact reason isn't fully understood. Progesterone is rising too, helping maintain the lining of your womb and support the pregnancy. Together they explain much of what you may notice: tiredness, tender breasts and changing moods. This is all your body doing just what it should.",
          'Abhi do hormones sabse zyada kaam kar rahe hain. hCG wahi hai jise pregnancy test pakadta hai, aur is hafte yeh tezi se badhta hai. Maana jaata hai ki zyada hCG shuruaati matli badha sakta hai, halaanki iski theek wajah poori tarah samjhi nahi gayi. Progesterone bhi badh raha hai, jo womb ki lining banaye rakhne aur pregnancy ko support karne mein madad karta hai. Dono milkar bahut kuch samjhaate hain jo tum mehsoos karti ho: thakaan, breast narmi aur badalte moods. Yeh sab tumhara body wahi kar raha hai jo use karna chahiye.',
        ),
      ),
      W5Highlight(
        title: _t('Your emotions', 'Tumhari bhavnaayein'),
        teaser: _t(
          'A positive test can stir up every feeling at once.',
          'Ek positive test har bhavna ko ek saath jaga sakta hai.',
        ),
        body: _t(
          "Finding out you're pregnant can bring joy, nerves, and a flicker of 'is this really happening', sometimes all in the same hour. Rising hormones can make these feelings stronger, so if you are more tearful or on edge than usual, there is a reason. Feeling worried or a little overwhelmed is common in early pregnancy, and many women have moments of anxiety as they adjust to the news. Talking to someone you trust often takes the edge off.",
          "Pata chalna ki tum pregnant ho — khushi, ghabraahat, aur 'kya sach mein ho raha hai' ki ek chamak la sakta hai, kabhi sab ek hi ghante mein. Badhte hormones in bhavnaon ko aur tez kar sakte hain, isliye agar tum aam se zyada roti ya chidchidi ho, to iski wajah hai. Fikr ya thoda overwhelmed mehsoos hona shuruaati pregnancy mein aam hai, aur bahut si mahilaayein khabar ko apnaate waqt anxiety ke pal mehsoos karti hain. Kisi bharose waale se baat karna aksar bojh halka kar deta hai.",
        ),
      ),
      W5Highlight(
        title: _t('Your changing body', 'Tumhara badalta body'),
        teaser: _t(
          'No bump yet, but plenty already shifting inside.',
          'Abhi bump nahi, par andar bahut kuch badal raha hai.',
        ),
        body: _t(
          "It is far too early for a bump, and you will look much the same to the outside world for weeks yet. But your body has already begun reshaping itself around this pregnancy. Your body is beginning to send more blood towards your womb and the developing placenta, and breast tissue is responding to the new hormones. You might feel these shifts as tenderness or fullness. Nothing needs to look different for a lot to be happening.",
          'Bump ke liye abhi bahut jaldi hai, aur duniya ko tum kai hafton tak lagbhag waisi hi dikhogi. Par tumhara body pehle se is pregnancy ke aaspaas khud ko dhaalne laga hai. Tumhara body womb aur ban rahe placenta ki taraf zyada blood bhejne laga hai, aur breast tissue naye hormones ka jawaab de raha hai. In badlaavon ko tum narmi ya bharipan ki tarah mehsoos kar sakti ho. Bahut kuch hone ke liye zaroori nahi ki kuch alag dikhe.',
        ),
      ),
      W5Highlight(
        title: _t('Appetite & cravings', 'Bhookh aur cravings'),
        teaser: _t(
          'Foods you once loved may suddenly turn, or tempt you.',
          'Jo khaana kabhi pasand tha woh achanak bura lag sakta hai, ya lubha sakta hai.',
        ),
        body: _t(
          "Your relationship with food can shift early. Some women go off tea, coffee or favourite meals almost overnight, while others start craving specific things. Changing hormones are thought to play a big part, and they may make certain smells or tastes feel much stronger than usual. There is no need to force foods that do not appeal right now. Eat what feels easy, keep something plain nearby, and trust that most food dislikes ease as the weeks go on.",
          'Khaane ke saath tumhara rishta jaldi badal sakta hai. Kuch mahilaayein chai, coffee ya favourite khaane se raat-o-raat door ho jaati hain, jabki kuch ko khaas cheezon ki craving hone lagti hai. Maana jaata hai ki badalte hormones badi bhoomika nibhaate hain, aur woh kuch smells ya taste ko aam se kai guna tez bana sakte hain. Jo cheez abhi accha na lage use zabardasti khaane ki zaroorat nahi. Jo aasaan lage woh khao, kuch simple paas rakho, aur bharosa rakho ki zyadatar khaane ki naapasand hafton ke saath kam ho jaati hai.',
        ),
      ),
    ],
    selfCare: _t(
      "This is a good week to book your first prenatal appointment, and to start folic acid if you haven't already, or continue it if you have. Rest when you can, because early tiredness is real.",
      'Yeh apni pehli prenatal appointment book karne, aur agar abhi tak nahi liya to folic acid shuru karne (ya le rahi ho to jaari rakhne) ka accha hafta hai. Jab ho sake aaram karo, kyunki shuruaati thakaan sach mein hoti hai.',
    ),
  ),

  // ---- 5 · Health · Symptoms ------------------------------------------------
  symptoms: [
    W5Symptom(
      name: _t('Nausea', 'Matli (Nausea)'),
      teaser: _t(
        'That queasy, off-colour feeling that can arrive at any time of day. It often begins around now as pregnancy hormones climb.',
        'Woh ubkaai jaisa, ajeeb sa ehsaas jo din ke kisi bhi waqt aa sakta hai. Pregnancy hormones badhne ke saath aksar abhi shuru hota hai.',
      ),
      howCommon: _t(
        'Very common. Many women notice it from around week five or six.',
        'Bahut aam. Bahut si mahilaayein ise lagbhag paanch-chhah hafte se mehsoos karti hain.',
      ),
      why: _t(
        "Rising pregnancy hormones, especially hCG, can unsettle your stomach. Despite the name, this queasiness can happen morning, noon or night, not just early in the day.",
        'Badhte pregnancy hormones, khaaskar hCG, tumhara pet gadbada sakte hain. Naam ke bavajood, yeh ubkaai subah, dopahar ya raat — kisi bhi waqt ho sakti hai, sirf subah nahi.',
      ),
      helps: [
        _t('Eat small, frequent meals through the day', 'Din bhar chhote, baar-baar meals khao'),
        _t('Keep plain snacks like crackers or toast nearby', 'Crackers ya toast jaise simple snacks paas rakho'),
        _t('Sip ginger tea, lemon water or nimbu paani', 'Adrak ki chai, lemon water ya nimbu paani ghoont-ghoont piyo'),
        _t('Cut back on caffeine, which can worsen nausea', 'Caffeine kam karo, jo matli badha sakta hai'),
      ],
      whenDoctor: _t(
        'If you cannot keep food or fluids down, or are losing weight, call your doctor.',
        'Agar khaana ya paani andar tik na rahe, ya weight gir raha ho, to doctor ko call karo.',
      ),
    ),
    W5Symptom(
      name: _t('Fatigue', 'Thakaan'),
      teaser: _t(
        'A heavy, bone-deep tiredness that can hit even after a full night\'s sleep. It is one of the earliest signs of pregnancy.',
        'Ek bhaari, haddiyon tak ki thakaan jo poori raat ki neend ke baad bhi ho sakti hai. Yeh pregnancy ke sabse pehle sanketon mein se ek hai.',
      ),
      howCommon: _t(
        'Very common in early pregnancy, and often one of the first things you notice.',
        'Shuruaati pregnancy mein bahut aam, aur aksar sabse pehle mehsoos hone waali cheezon mein se ek.',
      ),
      why: _t(
        "Rising progesterone has a naturally calming, sleep-inducing effect. At the same time, your body is working hard to build the placenta and support your growing baby.",
        'Badhta progesterone kudrati taur par shaant karne aur neend laane waala hota hai. Saath hi, tumhara body placenta banane aur badhte baby ko support karne mein khoob mehnat kar raha hai.',
      ),
      helps: [
        _t('Rest whenever you can, even short naps', 'Jab ho sake aaram karo, chhoti jhapki bhi'),
        _t('Go to bed a little earlier than usual', 'Aam se thoda jaldi so jao'),
        _t('Stay hydrated and eat regular, balanced meals', 'Paani peete raho aur niyamit, santulit meals khao'),
        _t('Gentle movement like a short walk can lift energy', 'Halki movement jaise chhoti walk energy badha sakti hai'),
      ],
      whenDoctor: _t(
        'If tiredness feels extreme, or comes with breathlessness or dizziness, mention it to your doctor.',
        'Agar thakaan bahut zyada lage, ya saans phoolne ya chakkar ke saath aaye, to doctor ko bataao.',
      ),
    ),
    W5Symptom(
      name: _t('Tender breasts', 'Breast mein narmi aur dard'),
      teaser: _t(
        'Sore, swollen or tingling breasts are often one of the very first signs of pregnancy, sometimes even before a missed period.',
        'Dukhte, soojhe ya jhunjhunahat waale breasts aksar pregnancy ke sabse pehle sanketon mein se ek hote hain, kabhi period miss hone se bhi pehle.',
      ),
      howCommon: _t(
        'Very common, and often one of the earliest changes women notice.',
        'Bahut aam, aur aksar sabse pehle mehsoos hone waale badlaavon mein se ek.',
      ),
      why: _t(
        "Rising hormones increase blood flow and begin preparing the milk-producing tissue in your breasts. This can make them feel fuller, heavier or more sensitive than usual.",
        'Badhte hormones blood flow badhate hain aur breasts mein doodh banane waale tissue ko taiyaar karne lagte hain. Isse woh aam se zyada bhare, bhaari ya sensitive mehsoos ho sakte hain.',
      ),
      helps: [
        _t('Wear a soft, well-fitting supportive bra', 'Naram, sahi fitting waali supportive bra pehno'),
        _t('Try a wireless or sleep bra at night', 'Raat mein wireless ya sleep bra try karo'),
        _t('Avoid tight clothing that presses on the area', 'Tight kapde jo us jagah dabaayein, unse bacho'),
        _t('Warm or cool compresses can ease soreness', 'Garam ya thanda compress dard kam kar sakta hai'),
      ],
      whenDoctor: _t(
        'If you feel a lump, or notice unusual discharge, have it checked by your doctor.',
        'Agar koi gaanth mehsoos ho, ya asamaanya discharge dikhe, to doctor se jaanch karwao.',
      ),
    ),
    W5Symptom(
      name: _t('Frequent urination', 'Baar-baar peshaab'),
      teaser: _t(
        'Needing to pee more often than usual, even this early. It is a common and harmless sign that your body is adapting.',
        'Aam se zyada baar peshaab jaana, itni jaldi bhi. Yeh ek aam aur nuksaan-rahit sanket hai ki tumhara body dhal raha hai.',
      ),
      howCommon: _t(
        'Common from early pregnancy, and it tends to come and go throughout.',
        'Shuruaati pregnancy se aam, aur poore samay aata-jaata rehta hai.',
      ),
      why: _t(
        "Pregnancy increases blood flow, so your kidneys process more fluid and produce more urine. Rising hormones also make your bladder more sensitive than usual.",
        'Pregnancy blood flow badhati hai, isliye tumhari kidneys zyada fluid process karke zyada peshaab banati hain. Badhte hormones bladder ko bhi aam se zyada sensitive bana dete hain.',
      ),
      helps: [
        _t('Keep drinking water; do not cut fluids', 'Paani peete raho; fluids kam mat karo'),
        _t('Reduce drinks in the hour before bed', 'Sone se ek ghante pehle drinks kam karo'),
        _t('Lean forward when you pee to empty fully', 'Peshaab karte waqt aage jhuko taaki bladder poora khaali ho'),
        _t('Cut back on caffeine, which increases urination', 'Caffeine kam karo, jo peshaab badhata hai'),
      ],
      whenDoctor: _t(
        'If it stings or burns when you pee, or you feel feverish, call your doctor.',
        'Agar peshaab mein jalan ho, ya bukhaar jaisa lage, to doctor ko call karo.',
      ),
    ),
    W5Symptom(
      name: _t('Bloating', 'Pet mein bharipan (Bloating)'),
      teaser: _t(
        'A full, puffy or gassy feeling in your tummy, a little like the bloating some women get before a period.',
        'Pet mein bhara, phoola ya gas jaisa ehsaas, thoda usi bloating jaisa jo kuch mahilaon ko period se pehle hota hai.',
      ),
      howCommon: _t(
        'Common in early pregnancy, and especially noticeable in the first trimester.',
        'Shuruaati pregnancy mein aam, aur pehle trimester mein khaaskar mehsoos hota hai.',
      ),
      why: _t(
        "Rising progesterone relaxes the muscles of your digestive tract, which slows digestion. Food moves through more slowly, which can leave you feeling gassy or full.",
        'Badhta progesterone tumhare digestive tract ki muscles ko dheela karta hai, jisse digestion dheema ho jaata hai. Khaana zyada dheere aage badhta hai, jisse gas ya bharipan mehsoos ho sakta hai.',
      ),
      helps: [
        _t('Eat smaller meals more slowly through the day', 'Din bhar chhote meals dheere-dheere khao'),
        _t('Stay hydrated with water through the day', 'Din bhar paani se hydrated raho'),
        _t('Include fibre from fruit, vegetables and dals', 'Fruit, sabziyon aur daal se fibre lo'),
        _t('Gentle movement helps digestion keep moving', 'Halki movement digestion ko chalta rakhti hai'),
      ],
      whenDoctor: _t(
        'If bloating comes with severe pain or will not settle, speak to your doctor.',
        'Agar bloating tez dard ke saath aaye ya theek na ho, to doctor se baat karo.',
      ),
    ),
  ],

  // ---- 6 · Health · Diet ----------------------------------------------------
  diet: W5Diet(
    superfood: W5Superfood(
      food: _t('Palak (Spinach)', 'Palak'),
      benefit: _t(
        "Rich in folate, the key nutrient helping your baby's brain and spine form safely.",
        'Folate se bharpoor — wahi khaas nutrient jo tumhare baby ke brain aur spine ko surakshit banne mein madad karta hai.',
      ),
      tryAs: _t(
        'Try it as: palak dal or lightly sautéed saag.',
        'Aise try karo: palak dal ya halki sautéed saag.',
      ),
      note: _t(
        "In these early weeks, folate matters most, while your baby's brain and spinal cord are taking shape.",
        'In shuruaati hafton mein folate sabse zyada mayne rakhta hai, jab tumhare baby ka brain aur spinal cord aakaar le rahe hote hain.',
      ),
    ),
    favour: [
      W5Card(
        title: _t('Spinach & leafy greens', 'Palak aur patte waali sabziyan'),
        body: _t(
          "Palak, methi and mustard greens are packed with folate for your baby's developing nervous system.",
          'Palak, methi aur sarson ka saag folate se bhare hain — tumhare baby ke ban rahe nervous system ke liye.',
        ),
      ),
      W5Card(
        title: _t('Dals & legumes', 'Dal aur phaliyan'),
        body: _t(
          'Moong, masoor and rajma bring folate, protein and iron, all vital in these early building weeks.',
          'Moong, masoor aur rajma folate, protein aur iron dete hain — in shuruaati building hafton mein sabhi zaroori.',
        ),
      ),
      W5Card(
        title: _t('Citrus & amla', 'Khatte fal aur amla'),
        body: _t(
          'Oranges, sweet lime and amla add folate and vitamin C, which helps your body absorb iron.',
          'Santara, mosambi aur amla folate aur vitamin C dete hain, jo tumhare body ko iron soakne mein madad karta hai.',
        ),
      ),
      W5Card(
        title: _t('Whole grains', 'Saabut anaaj'),
        body: _t(
          'Whole wheat roti, brown rice and oats give steady energy and gentle fibre for digestion.',
          'Gehu ki roti, brown rice aur oats steady energy aur digestion ke liye halka fibre dete hain.',
        ),
      ),
      W5Card(
        title: _t('Curd & yoghurt', 'Dahi aur yoghurt'),
        body: _t(
          'Cooling, easy on the stomach, and a good source of calcium and gentle probiotics.',
          'Thanda, pet par aasaan, aur calcium tatha halke probiotics ka accha source.',
        ),
      ),
      W5Card(
        title: _t('Nuts & seeds', 'Meve aur beej'),
        body: _t(
          'A handful of almonds, walnuts or peanuts adds folate, healthy fats and a protein boost.',
          'Muththi bhar badaam, akhrot ya moongfali folate, healthy fats aur protein ka boost deti hai.',
        ),
      ),
      W5Card(
        title: _t('Bananas & simple fruit', 'Kela aur simple fal'),
        body: _t(
          'Easy to keep down on queasy days, and a quick, gentle source of energy.',
          'Matli waale din andar tikaana aasaan, aur quick, halki energy ka source.',
        ),
      ),
    ],
    avoid: [
      W5Card(
        title: _t('Raw or undercooked meat & eggs', 'Kacha ya adhpaka meat aur ande'),
        body: _t(
          'Can carry bacteria like salmonella or listeria, so cook everything thoroughly before eating.',
          'Salmonella ya listeria jaise bacteria ho sakte hain, isliye khaane se pehle sab kuch achhe se pakao.',
        ),
      ),
      W5Card(
        title: _t('Unpasteurised milk & soft cheese', 'Bina-pasteurised doodh aur soft cheese'),
        body: _t(
          'May contain listeria bacteria, so choose pasteurised milk and hard cheeses instead.',
          'Isme listeria bacteria ho sakte hain, isliye pasteurised doodh aur hard cheese chuno.',
        ),
      ),
      W5Card(
        title: _t('High-mercury fish', 'Zyada-mercury waali machhli'),
        body: _t(
          "Limit shark, swordfish and king mackerel, as mercury can affect your baby's developing brain.",
          'Shark, swordfish aur king mackerel seemit karo, kyunki mercury tumhare baby ke ban rahe brain ko prabhaavit kar sakta hai.',
        ),
      ),
      W5Card(
        title: _t('Too much caffeine', 'Bahut zyada caffeine'),
        body: _t(
          'Keep it under about 200 mg a day, roughly one cup of coffee.',
          'Ise din mein lagbhag 200 mg ke neeche rakho, mote taur par ek cup coffee.',
        ),
      ),
      W5Card(
        title: _t('Alcohol', 'Sharaab'),
        body: _t(
          'No amount is considered safe in pregnancy, so it is best avoided completely.',
          'Pregnancy mein koi bhi maatra surakshit nahi maani jaati, isliye ise poori tarah chhod dena behtar hai.',
        ),
      ),
    ],
  ),

  // ---- 7 · Trimester Tips (T1 · Weeks 1–13) ---------------------------------
  tips: [
    W5Tip(
      oneLine: _t('Take your folic acid every single day.', 'Apna folic acid har din lo.'),
      readMore: _t(
        "Folic acid is one of the most important things you can take right now. In these early weeks, it helps your baby's brain and spine form properly. Most doctors suggest 400 micrograms a day, ideally from before pregnancy through the first trimester. Take it at the same time each day so it becomes a habit.",
        'Folic acid abhi tum jo le sakti ho usme sabse zaroori cheezon mein se ek hai. In shuruaati hafton mein yeh tumhare baby ke brain aur spine ko theek se banne mein madad karta hai. Zyadatar doctor din mein 400 microgram salaah dete hain, behtar hai pregnancy se pehle se pehle trimester tak. Ise har din ek hi waqt lo taaki aadat ban jaaye.',
      ),
    ),
    W5Tip(
      oneLine: _t("Book your first doctor's visit as early as you can.", 'Apni pehli doctor visit jitni jaldi ho sake book karo.'),
      readMore: _t(
        "Once you know you are pregnant, book your first appointment with a doctor or gynaecologist. This first visit sets up your care for the months ahead. Your doctor will confirm your pregnancy, talk through your health, and guide you on tests, diet and supplements. Do not worry if you have many questions. That is exactly what this visit is for.",
        'Jaise hi pata chale ki tum pregnant ho, doctor ya gynaecologist se pehli appointment book karo. Yeh pehli visit aane waale mahinon ki dekhbhaal tay karti hai. Tumhara doctor pregnancy confirm karega, tumhari sehat par baat karega, aur tests, diet tatha supplements par maargdarshan dega. Agar bahut sawaal hain to fikr mat karo. Yeh visit isi ke liye hai.',
      ),
    ),
    W5Tip(
      oneLine: _t('Eat small, frequent meals to ease nausea.', 'Matli kam karne ke liye chhote, baar-baar meals khao.'),
      readMore: _t(
        "Morning sickness can strike at any time of day, and an empty stomach often makes it worse. Instead of three big meals, try eating small amounts every few hours. Keep simple snacks like biscuits, toast or a banana close by, even next to your bed. Ginger and nimbu paani help many women feel a little settled.",
        'Morning sickness din ke kisi bhi waqt aa sakti hai, aur khaali pet ise aksar badha deta hai. Teen bade meals ke bajaay, har kuch ghante mein thoda-thoda khaane ki koshish karo. Biscuit, toast ya kela jaise simple snacks paas rakho, apne bistar ke paas bhi. Adrak aur nimbu paani bahut si mahilaon ko thoda behtar mehsoos karaate hain.',
      ),
    ),
    W5Tip(
      oneLine: _t('Rest as much as your body needs.', 'Jitna tumhare body ko chahiye utna aaram karo.'),
      readMore: _t(
        "First-trimester tiredness is real, and it can feel heavier than any tiredness before. Your body is doing huge work behind the scenes, so give yourself permission to slow down. Sleep a little earlier, take short naps when you can, and let some chores wait. Rest is not being lazy. It is part of looking after your baby.",
        'Pehle trimester ki thakaan sach hoti hai, aur yeh pehle ki kisi bhi thakaan se bhaari lag sakti hai. Tumhara body parde ke peeche bahut bada kaam kar raha hai, isliye khud ko dheema hone ki ijaazat do. Thoda jaldi so jao, jab ho sake chhoti jhapki lo, aur kuch kaam ko intezaar karne do. Aaram karna aalas nahi hai. Yeh apne baby ki dekhbhaal ka hissa hai.',
      ),
    ),
    W5Tip(
      oneLine: _t('Drink plenty of water through the day.', 'Din bhar khoob paani piyo.'),
      readMore: _t(
        "Staying well hydrated helps with many early pregnancy small discomforts, from tiredness to headaches to constipation. Aim to sip water steadily through the day rather than a lot at once. If plain water feels dull, try coconut water, buttermilk or nimbu paani. On queasy days, cool drinks are sometimes easier to manage than food.",
        'Achhe se hydrated rehna shuruaati pregnancy ki kai chhoti takleefon mein madad karta hai — thakaan se lekar sardard aur constipation tak. Ek saath bahut zyada ke bajaay din bhar thoda-thoda paani piyo. Agar saada paani boring lage, to nariyal paani, chhaach ya nimbu paani try karo. Matli waale din, thande drinks kabhi khaane se aasaan hote hain.',
      ),
    ),
    W5Tip(
      oneLine: _t('Cook food well and wash fruits and vegetables.', 'Khaana achhe se pakao aur fal-sabzi dhoyo.'),
      readMore: _t(
        "In pregnancy, your body fights off infections less easily, so food safety matters more than usual. Cook meat, fish and eggs fully, and choose pasteurised milk and dairy. Wash fruits and vegetables well before eating. Avoid raw or undercooked items and unpasteurised foods for now. These simple habits lower the chance of an upset that could affect you both.",
        'Pregnancy mein tumhara body infections se kam aasaani se ladta hai, isliye food safety aam se zyada mayne rakhti hai. Meat, machhli aur ande poore pakao, aur pasteurised doodh aur dairy chuno. Khaane se pehle fal aur sabziyan achhe se dhoyo. Kacchi ya adhpaki cheezein aur bina-pasteurised khaane abhi ke liye chhodo. Yeh simple aadatein us gadbadi ka khatra kam karti hain jo tum dono ko prabhaavit kar sakti hai.',
      ),
    ),
    W5Tip(
      oneLine: _t('Limit caffeine, and skip alcohol and smoking.', 'Caffeine seemit karo, aur sharaab tatha smoking chhodo.'),
      readMore: _t(
        "A little caffeine is fine, but try to keep it under about 200 milligrams a day, roughly one cup of coffee, counting tea and cola too. Alcohol has no known safe amount in pregnancy, so it is best left. If you smoke, or are around smoke, this is a good time to step away, for you both.",
        'Thodi caffeine theek hai, par ise din mein lagbhag 200 milligram ke neeche rakhne ki koshish karo — mote taur par ek cup coffee, chai aur cola ko bhi ginte hue. Pregnancy mein sharaab ki koi surakshit maatra nahi maani jaati, isliye ise chhod dena behtar hai. Agar tum smoke karti ho, ya smoke ke aaspaas ho, to yeh door hat-ne ka accha waqt hai, tum dono ke liye.',
      ),
    ),
    W5Tip(
      oneLine: _t("Keep moving gently, with your doctor's okay.", 'Doctor ki ijaazat se, halki movement jaari rakho.'),
      readMore: _t(
        "Unless your doctor advises otherwise, gentle movement is good for you now. A daily walk, light stretching or prenatal yoga can lift your mood, help you sleep and ease early aches. There is no need to push hard. Move at a pace where you can still chat comfortably. Always check with your doctor before starting anything new.",
        'Jab tak tumhara doctor mana na kare, halki movement abhi tumhare liye acchi hai. Roz ki walk, halki stretching ya prenatal yoga tumhara mood behtar kar sakti hai, neend mein madad kar sakti hai aur shuruaati dard kam kar sakti hai. Zor lagaane ki zaroorat nahi. Us raftaar par chalo jahaan tum aaraam se baat bhi kar sako. Kuch naya shuru karne se pehle hamesha apne doctor se poochho.',
      ),
    ),
    W5Tip(
      oneLine: _t('Share how you feel with someone you trust.', 'Apni bhavnaayein kisi bharose waale ke saath baanto.'),
      readMore: _t(
        "Early pregnancy can bring a mix of joy, worry and mood swings, often all at once. This is normal, and hormones play a big part. You do not have to carry it alone. Talking to your partner, a close friend or family member can lighten the load. If low feelings stay for long, tell your doctor.",
        'Shuruaati pregnancy khushi, fikr aur mood swings ka mishran la sakti hai, aksar sab ek saath. Yeh normal hai, aur hormones badi bhoomika nibhaate hain. Ise akele uthaane ki zaroorat nahi. Apne partner, kisi kareebi dost ya parivaar se baat karna bojh halka kar sakta hai. Agar udaasi lambe samay tak rahe, to apne doctor ko bataao.',
      ),
    ),
  ],

  // ---- 8 · Share With Partner -----------------------------------------------
  partner: W5Partner(
    baby: _t(
      "This week I am about the size of a sesame seed, but a lot is happening inside me. My brain, spine and tiny heart are just beginning to form. You cannot feel me yet, but I am already growing a little more every single day.",
      'Is hafte main lagbhag til ke daane jitna hoon, par mere andar bahut kuch ho raha hai. Mera brain, spine aur nanha dil abhi banna shuru ho rahe hain. Tum abhi mujhe mehsoos nahi kar sakte, par main pehle se har din thoda aur badh raha hoon.',
    ),
    mother: _t(
      "She has likely just found out she is pregnant, and it may still feel wonderfully unreal. She might be more tired than usual, or feeling a little queasy as her body adjusts. Right now, small gestures of care and patience mean more to her than anything grand.",
      'Use shayad abhi-abhi pata chala hai ki woh pregnant hai, aur yeh abhi bhi khoobsurat tareeke se anokha lag sakta hai. Woh aam se zyada thaki ho sakti hai, ya body ke dhalne ke saath thodi matli mehsoos kar sakti hai. Abhi, dekhbhaal aur sabr ke chhote ishaare uske liye kisi badi cheez se zyada mayne rakhte hain.',
    ),
    scans: [
      W5Scan(name: _t('First check-up', 'Pehla check-up'), window: _t('Week 6 to 8', 'Week 6 se 8')),
      W5Scan(name: _t('Dating scan', 'Dating scan'), window: _t('Week 6 to 9', 'Week 6 se 9')),
      W5Scan(name: _t('NT scan', 'NT scan'), window: _t('Week 11 to 13', 'Week 11 se 13')),
    ],
    help: [
      _t('Take on more of the cooking and daily chores.', 'Khaana banane aur roz ke kaam ka zyada hissa apne upar lo.'),
      _t('Keep simple snacks and water near her bed.', 'Uske bistar ke paas simple snacks aur paani rakho.'),
      _t('Be patient with her tiredness and changing moods.', 'Uski thakaan aur badalte moods ke saath sabr rakho.'),
      _t("Go with her to that first doctor's visit.", 'Us pehli doctor visit par uske saath jao.'),
      _t('Listen when she wants to talk, without fixing.', 'Jab woh baat karna chahe to suno, theek karne ki koshish ke bina.'),
      _t('Remind her gently to take her folic acid.', 'Use pyaar se folic acid lene ki yaad dilao.'),
    ],
  ),
);
