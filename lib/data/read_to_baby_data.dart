
import '../localization/app_language.dart';

// =============================================================================
//  Read to your baby - content pools (gentle pieces to read aloud)
// -----------------------------------------------------------------------------
//  Original, warm pieces for the customizable "Read to your baby" daily feed:
//  children's stories, rhymes/lullabies, and affirmations/blessings. The
//  spiritual-reading category draws from kSpiritualTraditions instead (not here).
//
//  TONE: every piece is written to be read DIRECTLY TO THE BABY - the mother is
//  speaking to her little one ("Little one…", "My darling…"). It's "read to your
//  baby", so it feels addressed to the baby, not narrated about the world.
//
//  IMPORTANT: every piece below is ORIGINAL writing. No existing or copyrighted
//  nursery rhyme, lullaby, song, poem or story is reproduced or reworded - these
//  are fresh, gentle pieces written for an expectant mother to read aloud.
// =============================================================================

/// Category keys (must match ReadToBabyStore + the customize sheet).
/// [kRtbSpeaking] = the Garbh Samvad trimester speaking cards, folded in as a
/// toggleable category when "Read to your baby" merged into Samvad.
LocalizedText _t(String en, String hi) => LocalizedText(en: en, hi: hi);

const String kRtbSpeaking = 'speaking';
const String kRtbStories = 'stories';
const String kRtbSpiritual = 'spiritual';
const String kRtbRhymes = 'rhymes';
const String kRtbAffirmations = 'affirmations';

class ReadAloudPiece {
  const ReadAloudPiece(
      {required this.category, required this.title, required this.body});
  final String category;
  final LocalizedText title;
  final LocalizedText body;

  /// What this piece IS, for bookmarking - the English title, never the one on
  /// screen. The saved hub used to key on the displayed title, which meant a
  /// piece answered to a different name in each language: marks made in
  /// English vanished in Hindi and came back on switching. See
  /// [SavedRtbPiece.key] and test/rtb_saved_identity_test.dart.
  String get saveKey => title.en;
}

final List<ReadAloudPiece> kReadAloudPieces = [
  // ---------- Children's stories (told to the baby) ----------
  ReadAloudPiece(
      category: kRtbStories,
      title: _t('The Little Cloud Who Loved to Rain', 'वह नन्हा बादल जिसे बरसना अच्छा लगता था'),
      body:
          _t("Little one, let me tell you about a small grey cloud that drifted over the fields, sprinkling soft rain so the flowers could drink and the rivers could sing. Everywhere it floated, the world turned a little greener. You are like that little cloud, my love - wherever you go, you will leave the world a little fresher and kinder, just by being you.", 'नन्ही जान, सुनो — एक छोटा-सा भूरा बादल खेतों के ऊपर तैरता था, और हल्की बूँदें बरसाता था, ताकि फूल पानी पी सकें और नदियाँ गा सकें। जहाँ-जहाँ वह गया, दुनिया थोड़ी और हरी हो गई। तुम भी उसी नन्हे बादल जैसे हो, मेरी जान — जहाँ भी जाओगे, दुनिया को थोड़ा और ताज़ा, थोड़ा और नरम कर जाओगे, बस अपने होने भर से।')),
  ReadAloudPiece(
      category: kRtbStories,
      title: _t('Mira and the Sleepy Moon', 'मीरा और नींद भरा चाँद'),
      body:
          _t("My darling, a little girl named Mira waved to the moon every night. One evening the moon looked tired, its glow soft and dim, so Mira whispered, \"Rest now - I'll keep watch.\" And she hummed a quiet tune until morning. One day, when I am tired, you and I will keep watch for each other too. That is what love does, sweet one.", 'मेरी जान, मीरा नाम की एक नन्ही लड़की हर रात चाँद को हाथ हिलाती थी। एक शाम चाँद थका-सा लगा, उसकी चमक धीमी पड़ गई थी, तो मीरा ने धीरे से कहा, "अब आराम कर लो — मैं पहरा दूँगी।" और वह सुबह तक धीमे-धीमे गुनगुनाती रही। एक दिन, जब मैं थकूँगी, तुम और मैं भी एक-दूसरे के लिए ऐसे ही जागेंगे। प्यार यही करता है, मेरे प्यारे।')),
  ReadAloudPiece(
      category: kRtbStories,
      title: _t('The Elephant Who Shared His Shade', 'वह हाथी जिसने अपनी छाँव बाँट दी'),
      body:
          _t("Sweet baby, under the hot afternoon sun a kind elephant stood beneath the only tree, and one by one he waved all the little animals into his cool shade. \"There's room for everyone,\" he rumbled softly. I hope you grow up with a heart like his, little one - big enough to make room for everyone you meet.", 'मेरे प्यारे शिशु, दोपहर की तेज़ धूप में एक भला हाथी इकलौते पेड़ के नीचे खड़ा था, और एक-एक करके उसने सारे छोटे जानवरों को अपनी ठंडी छाँव में बुला लिया। "जगह सबके लिए है," उसने धीरे से कहा। मैं चाहती हूँ कि तुम्हारा दिल भी उसी जैसा बड़ा हो, नन्ही जान — इतना बड़ा कि हर मिलने वाले के लिए जगह बन जाए।')),
  ReadAloudPiece(
      category: kRtbStories,
      title: _t('The Smallest Seed', 'सबसे नन्हा बीज'),
      body:
          _t("Little one, in a corner of the garden lay the tiniest seed, sure it was far too small to matter. But the rain came, and the sun came, and slowly it pushed up a single green leaf - until one morning it was the tallest sunflower of all. You are small right now too, my love, but oh, how wonderfully you are growing.", 'नन्ही जान, बगिया के एक कोने में सबसे छोटा बीज पड़ा था, यह मानकर कि वह इतना छोटा है कि उसका कोई मतलब ही नहीं। पर बारिश आई, धूप आई, और उसने धीरे से एक हरी पत्ती बाहर निकाली — और एक सुबह वह सबसे ऊँचा सूरजमुखी बन चुका था। तुम भी अभी छोटे हो, मेरी जान, पर कितनी ख़ूबसूरती से बढ़ रहे हो।')),
  ReadAloudPiece(
      category: kRtbStories,
      title: _t("Bunny's Lost Button", 'खरगोश का खोया हुआ बटन'),
      body:
          _t("My love, a little bunny once lost the button from her coat, and all her friends helped her look - the birds, the beetles, even the breeze, lifting the leaves. At last they found it shining in the grass. \"Thank you, friends,\" said Bunny. One day you'll have friends like that, little one, and a family who is always here to help you.", 'मेरी जान, एक नन्ही खरगोश के कोट का बटन खो गया, और उसके सारे दोस्त उसे ढूँढ़ने लगे — चिड़ियाँ, भँवरे, और हवा भी, पत्तों को उठा-उठाकर। आख़िर वह घास में चमकता हुआ मिल गया। "शुक्रिया, दोस्तो," खरगोश ने कहा। एक दिन तुम्हारे भी ऐसे ही दोस्त होंगे, नन्ही जान, और एक परिवार जो हमेशा तुम्हारी मदद के लिए यहीं है।')),
  ReadAloudPiece(
      category: kRtbStories,
      title: _t('The Star That Came to Visit', 'वह तारा जो मिलने आया'),
      body:
          _t("Sweet baby, one night a tiny star slipped down to see the world up close. It tiptoed past sleeping flowers and quiet streams, marvelling at how soft the night could be. \"What a gentle place,\" it twinkled, and shone a little brighter ever after. The world is waiting to show you all its gentle wonders, my darling.", 'मेरे प्यारे शिशु, एक रात एक नन्हा तारा दुनिया को पास से देखने के लिए नीचे उतर आया। वह सोते हुए फूलों और चुपचाप बहती धाराओं के पास से दबे पाँव गुज़रा, और हैरान होता रहा कि रात इतनी नरम भी हो सकती है। "कितनी कोमल जगह है," उसने टिमटिमाकर कहा, और उस दिन के बाद थोड़ा और चमकने लगा। यह दुनिया तुम्हें अपने सारे कोमल अचरज दिखाने के लिए तैयार बैठी है, मेरी जान।')),
  ReadAloudPiece(
      category: kRtbStories,
      title: _t('The River and the Stone', 'नदी और पत्थर'),
      body:
          _t("Little one, a round little stone sat in the middle of a river, worried it was in the way. But the water simply sang around it, and over the years made it smooth and beautiful. \"We are better together,\" laughed the river. You and I are like that too, my love - gentler, and stronger, together.", 'नन्ही जान, एक गोल-सा नन्हा पत्थर नदी के बीच बैठा यह सोचकर परेशान था कि वह रास्ते में आ रहा है। पर पानी उसके चारों ओर गाता हुआ बहता रहा, और बरसों में उसे चिकना और सुंदर बना दिया। "साथ में हम दोनों और अच्छे हैं," नदी हँसी। तुम और मैं भी ऐसे ही हैं, मेरी जान — साथ में और नरम, और मज़बूत।')),
  ReadAloudPiece(
      category: kRtbStories,
      title: _t('Little Owl Learns to Wait', 'नन्ही उल्लू इंतज़ार करना सीखती है'),
      body:
          _t("My darling, a little owl wanted to fly before her wings were quite ready. \"Soon,\" said her mother, tucking her close. Each night she grew a little stronger, until one evening she lifted into the sky all on her own. There's no hurry, little one - I'm holding you close, and your day to soar will surely come.", 'मेरी जान, एक नन्ही उल्लू अपने पंख पूरी तरह तैयार होने से पहले ही उड़ना चाहती थी। "बस, थोड़ा और," उसकी माँ ने उसे पास समेटते हुए कहा। हर रात वह थोड़ी और मज़बूत होती गई, और एक शाम वह अपने आप आसमान में उठ गई। कोई जल्दी नहीं है, नन्ही जान — मैं तुम्हें अपने पास थामे हूँ, और तुम्हारे उड़ने का दिन ज़रूर आएगा।')),
  ReadAloudPiece(
      category: kRtbStories,
      title: _t('The Kind Little Boat', 'वह भली नन्ही नाव'),
      body:
          _t("Sweet baby, a small wooden boat carried anyone who needed to cross the pond - the duck, the frog, the careful little mouse. It was never the fastest or the grandest, but it was always there. \"Slow and kind gets everyone home,\" it creaked happily. May you always be that kind, my love.", 'मेरे प्यारे शिशु, लकड़ी की एक छोटी नाव हर उस जीव को तालाब पार कराती थी जिसे पार जाना हो — बत्तख़, मेंढक, और वह सँभल-सँभलकर चलने वाला नन्हा चूहा। वह न सबसे तेज़ थी, न सबसे शानदार, पर हमेशा वहीं मौजूद रहती थी। "धीरे चलो और नरमी से — सब घर पहुँच जाते हैं," वह ख़ुश होकर चरमराई। तुम भी हमेशा उतने ही भले रहना, मेरी जान।')),
  ReadAloudPiece(
      category: kRtbStories,
      title: _t('Mango for Everyone', 'आम सबके लिए'),
      body:
          _t("Little one, a monkey once found one perfect mango at the very top of the tree. He could have kept it all, but instead he called his friends and shared it slice by slice. The mango was small, but the laughter was big. \"Shared sweetness tastes the best,\" he grinned - and one day, my love, I think you'll agree.", 'नन्ही जान, एक बंदर को पेड़ की सबसे ऊँची डाल पर एकदम पका हुआ आम मिला। वह पूरा अपने पास रख सकता था, पर उसने अपने दोस्तों को बुलाया और फाँक-फाँक करके बाँट दिया। आम छोटा था, पर हँसी बहुत बड़ी। "बाँटी हुई मिठास सबसे अच्छी लगती है," उसने मुस्कुराकर कहा — और एक दिन, मेरी जान, मुझे लगता है तुम भी यही कहोगे।')),
  ReadAloudPiece(
      category: kRtbStories,
      title: _t("The Firefly's Little Light", 'जुगनू की नन्ही रोशनी'),
      body:
          _t("My darling, a firefly felt its glow was far too small to matter in the wide dark night. But a lost beetle followed that tiny light all the way safely home. \"Even the smallest light can lead someone,\" said the beetle. Your light is small and new, little one, but already it has lit up my whole world.", 'मेरी जान, एक जुगनू को लगता था कि इतनी बड़ी अँधेरी रात में उसकी चमक का कोई मोल नहीं। पर एक भटका हुआ भँवरा उसी नन्ही रोशनी के पीछे-पीछे सही-सलामत घर पहुँच गया। "सबसे छोटी रोशनी भी किसी को राह दिखा सकती है," भँवरे ने कहा। तुम्हारी रोशनी अभी नन्ही और नई है, नन्ही जान, पर उसने अभी से मेरी पूरी दुनिया जगमगा दी है।')),
  ReadAloudPiece(
      category: kRtbStories,
      title: _t('Tortoise Takes His Time', 'कछुआ अपने समय से चलता है'),
      body:
          _t("Sweet baby, while everyone rushed past, a tortoise walked slowly along the path, noticing the dewdrops and the singing birds. He arrived last, but he had seen the most beautiful morning of all. \"The world is lovely when you take your time,\" he smiled. Take your time, my love - we have all the time we need.", 'मेरे प्यारे शिशु, जब सब भागते हुए आगे निकल रहे थे, एक कछुआ रास्ते पर धीरे-धीरे चलता रहा, ओस की बूँदें और गाती चिड़ियाँ देखता हुआ। वह सबसे आख़िर में पहुँचा, पर उसने सबसे सुंदर सुबह देखी थी। "अपने समय से चलो, तो दुनिया प्यारी लगती है," वह मुस्कुराया। तुम भी अपना समय लो, मेरी जान — हमारे पास उतना समय है जितना चाहिए।')),
  ReadAloudPiece(
      category: kRtbStories,
      title: _t('The Blanket of Stars', 'तारों की चादर'),
      body:
          _t("Little one, when night fell, the sky pulled a soft blanket of stars over the sleeping world. The mountains grew quiet, the oceans grew calm, and every little creature curled up safe and warm. \"Goodnight, world,\" whispered the sky. And goodnight to you, my darling - safe, and warm, and so very loved.", 'नन्ही जान, रात हुई तो आसमान ने सोती हुई दुनिया पर तारों की एक नरम चादर ओढ़ा दी। पहाड़ चुप हो गए, समंदर शांत हो गए, और हर नन्हा जीव सिमटकर सुरक्षित और गरम हो गया। "शुभ रात्रि, दुनिया," आसमान ने धीरे से कहा। और शुभ रात्रि तुम्हें भी, मेरी जान — सुरक्षित, गरम, और इतना सारा प्यार पाए हुए।')),
  ReadAloudPiece(
      category: kRtbStories,
      title: _t('Pip the Curious Sparrow', 'पिप — जिज्ञासु गौरैया'),
      body:
          _t("My love, a little sparrow named Pip longed to see what lay beyond the garden wall. He flew a little farther each day - past the pond, past the field - then returned each evening to tell his family all about it. The world is big and wonderful, little one, and no matter how far you go, home will always be here for you.", 'मेरी जान, पिप नाम की एक नन्ही गौरैया को यह देखने की बहुत इच्छा थी कि बगिया की दीवार के उस पार क्या है। वह हर दिन थोड़ा और दूर उड़ता — तालाब के पार, खेत के पार — और हर शाम लौटकर अपने परिवार को सब कुछ सुनाता। दुनिया बड़ी है और बहुत प्यारी, नन्ही जान, और तुम कितना भी दूर जाओ, घर हमेशा यहीं तुम्हारा इंतज़ार करेगा।')),
  ReadAloudPiece(
      category: kRtbStories,
      title: _t('The Two Little Streams', 'दो नन्ही धाराएँ'),
      body:
          _t("Sweet baby, two little streams trickled down the hillside, each one all alone. When they finally met in the valley, they became a wide, happy river, strong enough to turn the old mill wheel. \"Together we can do so much,\" they sang. You are never alone, my darling - we will flow through this life together.", 'मेरे प्यारे शिशु, दो नन्ही धाराएँ पहाड़ी से नीचे बहती थीं, दोनों अकेली-अकेली। जब वे आख़िर घाटी में मिलीं, तो एक चौड़ी, ख़ुश नदी बन गईं — इतनी मज़बूत कि पुरानी चक्की का पहिया घुमा दे। "साथ मिलकर हम कितना कुछ कर सकते हैं," वे गाने लगीं। तुम कभी अकेले नहीं हो, मेरी जान — हम इस पूरे जीवन में साथ-साथ बहेंगे।')),
  ReadAloudPiece(
      category: kRtbStories,
      title: _t('The Gentle Giant', 'कोमल विशालकाय'),
      body:
          _t("Little one, deep in the forest lived a giant so big that birds nested in his hair. Yet he moved so softly he never startled a deer or crushed a single flower. \"Big hearts step gently,\" he would say. May you grow a heart that big and that gentle, my love - and the whole world will feel safe beside you.", 'नन्ही जान, जंगल के भीतर एक ऐसा विशालकाय रहता था कि चिड़ियाँ उसके बालों में घोंसले बना लेती थीं। फिर भी वह इतनी नरमी से चलता कि न कोई हिरण चौंकता, न एक भी फूल कुचला जाता। "बड़े दिल वाले धीरे क़दम रखते हैं," वह कहता। तुम्हारा दिल भी उतना ही बड़ा और उतना ही कोमल हो, मेरी जान — और तुम्हारे पास पूरी दुनिया ख़ुद को सुरक्षित महसूस करेगी।')),

  // ---------- Rhymes, poems & lullabies (sung to the baby) ----------
  ReadAloudPiece(
      category: kRtbRhymes,
      title: _t('Sleepy Time Song', 'नींद का गीत'),
      body:
          _t("The candle's low, the night is deep,\nThe little birds have gone to sleep.\nClose your eyes and softly rest,\nMy darling, held against my chest.", 'दीया मद्धम, रात गहरी,\nसो गई हैं चिड़ियाँ सारी।\nआँखें मूँदो, चैन से सो जाओ,\nमेरी जान, मेरे सीने में समाओ।')),
  ReadAloudPiece(
      category: kRtbRhymes,
      title: _t('Counting Stars', 'तारे गिनना'),
      body:
          _t("One little star to wish you goodnight,\nTwo little stars, so soft and bright.\nThree little stars above the tree,\nFour little stars to watch over thee.", 'एक नन्हा तारा कहे तुम्हें शुभ रात,\nदो नन्हे तारे, उजले और नरम-सी बात।\nतीन नन्हे तारे पेड़ के ऊपर चमकें,\nचार नन्हे तारे तुम्हें सोते हुए ताकें।')),
  ReadAloudPiece(
      category: kRtbRhymes,
      title: _t("The Rain's Lullaby", 'बारिश की लोरी'),
      body:
          _t("Pitter, patter, gentle rain,\nTapping soft on the window-pane.\nSleep, my love, so calm and slow,\nOff to dreamland we will go.", 'टिप-टिप, टप-टप, नरम फुहार,\nखिड़की पर बजती बार-बार।\nसो जाओ, मेरी जान, चैन से सो,\nसपनों के देश चलें हम दो।')),
  ReadAloudPiece(
      category: kRtbRhymes,
      title: _t('Tiny Toes', 'नन्हे पैर'),
      body:
          _t("Ten tiny toes and ten tiny fingers,\nA soft little nose where your sweet smile lingers.\nTwo little ears and one sleepy yawn -\nDream, little darling, until the dawn.", 'दस नन्ही उँगलियाँ पैरों की, दस हाथों की,\nएक नरम-सी नाक, और मुस्कान होंठों की।\nदो नन्हे कान, और एक नींद भरी जम्हाई —\nसपने देखो, मेरी जान, जब तक न हो सुबह आई।')),
  ReadAloudPiece(
      category: kRtbRhymes,
      title: _t('Moonbeam Boat', 'चाँदनी की नाव'),
      body:
          _t("Climb aboard the moonbeam boat,\nAcross the quiet sky we'll float,\nPast the clouds so soft and white -\nSail with me, my love, tonight.", 'चढ़ जाओ चाँदनी की नाव में,\nचुप आसमान में बहें साथ में।\nनरम, उजले बादलों के पार —\nचलो मेरी जान, आज की रात।')),
  ReadAloudPiece(
      category: kRtbRhymes,
      title: _t("The Garden's Asleep", 'बगिया सो गई'),
      body:
          _t("The roses nod, the daisies fold,\nThe evening turns from blue to gold.\nThe garden's tucked in, snug and deep,\nAnd so, my love, it's time to sleep.", 'गुलाब झुके, गेंदे मुँदे,\nनीली शाम सुनहरी हुई।\nबगिया सिमटकर सो गई गहरी —\nऔर अब, मेरी जान, बारी तुम्हारी।')),
  ReadAloudPiece(
      category: kRtbRhymes,
      title: _t('Whispering Wind', 'फुसफुसाती हवा'),
      body:
          _t("The wind goes whispering through the trees,\nA soft and sleepy, swaying breeze.\nIt hums a tune both low and sweet -\nA lullaby for your tiny feet.", 'हवा पेड़ों से कुछ फुसफुसाती,\nनरम, नींद भरी, झूमती-सी आती।\nधीमी, मीठी एक धुन गुनगुनाती —\nतुम्हारे नन्हे पैरों के लिए लोरी गाती।')),
  ReadAloudPiece(
      category: kRtbRhymes,
      title: _t('My Little Wonder', 'मेरा नन्हा अचरज'),
      body:
          _t("Of all the wonders, big and small,\nYou are the dearest one of all.\nThe stars may shine, the oceans roll,\nBut you, my love, light up my whole.", 'सारे अचरजों में, छोटे या बड़े,\nसबसे प्यारे तुम ही लगे।\nतारे चमकें, समंदर बहें,\nपर मेरी दुनिया, मेरी जान, तुमसे जगे।')),
  ReadAloudPiece(
      category: kRtbRhymes,
      title: _t('Cradle of Leaves', 'पत्तों का पालना'),
      body:
          _t("In a cradle made of leaves,\nRocked by gentle evening breeze,\nThe little bird tucks in its head -\nAnd you, my love, in your soft bed.", 'पत्तों से बने एक पालने में,\nशाम की नरम हवा के झूले में,\nनन्ही चिड़िया सिर छिपा लेती है —\nऔर तुम, मेरी जान, अपने नरम बिस्तर में।')),
  ReadAloudPiece(
      category: kRtbRhymes,
      title: _t('Slow the Day', 'दिन धीमा हुआ'),
      body:
          _t("Slow the day and dim the light,\nSoft the blanket, warm and tight.\nThe world says hush, the stars agree -\nSleep, my love, so peacefully.", 'दिन ढल चला, रोशनी मद्धम,\nकंबल नरम, गरम और घना।\nदुनिया कहे — शश्श, तारे भी मानें —\nसो जाओ, मेरी जान, चैन से।')),
  ReadAloudPiece(
      category: kRtbRhymes,
      title: _t('Tiny Heartbeat', 'नन्ही धड़कन'),
      body:
          _t("Your tiny heartbeat, soft and true,\nBeats its little song just for you.\nDrum, drum, drum, so steady and small -\nThe sweetest sound I know at all.", 'तुम्हारी नन्ही धड़कन, नरम और सच्ची,\nअपना छोटा-सा गीत तुम्हारे लिए रचती।\nधक, धक, धक — नन्ही और एकसार —\nसबसे मीठी आवाज़ यही, मेरी जान, हर बार।')),
  ReadAloudPiece(
      category: kRtbRhymes,
      title: _t('Dreamland Train', 'सपनों की रेल'),
      body:
          _t("All aboard the dreamland train,\nDown the soft and sleepy lane,\nChugging slow past fields of sheep -\nOff we go, my love, to sleep.", 'आ जाओ, सपनों की रेल चली,\nनरम, नींद भरी गली-गली।\nभेड़ों के खेतों से धीरे गुज़री —\nचलो, मेरी जान, अब नींद की बारी।')),
  ReadAloudPiece(
      category: kRtbRhymes,
      title: _t("Bumble's Lullaby", 'मधुमक्खी की लोरी'),
      body:
          _t("The busy bee has flown back home,\nNo more across the fields to roam.\nIt folds its wings, begins to hum -\nSleep now, my love, till morning's come.", 'मेहनती मधुमक्खी घर लौट आई,\nअब खेतों की सैर नहीं, नींद छाई।\nपंख समेटे, धीरे से गुनगुनाए —\nसो जाओ, मेरी जान, जब तक सुबह न आए।')),
  ReadAloudPiece(
      category: kRtbRhymes,
      title: _t('Snug as Can Be', 'एकदम सिमटे हुए'),
      body:
          _t("Snug as a pea in a cosy pod,\nSafe as a seed in the warm soft sod,\nTucked away where the world is mild -\nSleep, my dear, my little child.", 'फली में मटर के दाने जैसे सिमटे,\nगरम नरम मिट्टी में बीज जैसे लिपटे,\nवहाँ छिपे जहाँ दुनिया नरम है —\nसो जाओ, मेरे प्यारे, मेरे नन्हे।')),
  ReadAloudPiece(
      category: kRtbRhymes,
      title: _t('The Sleepy Sea', 'नींद भरा समंदर'),
      body:
          _t("The waves roll in, then roll away,\nThey've sung their songs throughout the day.\nNow soft and slow they kiss the shore\nAnd whisper, \"sleep, my love,\" once more.", 'लहरें आती हैं, फिर लौट जाती हैं,\nदिन भर अपने गीत गाती हैं।\nअब नरमी से किनारे को छूती हैं\nऔर धीरे से कहती हैं — "सो जाओ, मेरी जान।"')),
  ReadAloudPiece(
      category: kRtbRhymes,
      title: _t('Goodnight, Everything', 'शुभ रात्रि, सब कुछ'),
      body:
          _t("Goodnight to the hills, goodnight to the streams,\nGoodnight to the world and all of its dreams.\nGoodnight to the stars and the silvery moon -\nGoodnight, my love, I'll hold you soon.", 'शुभ रात्रि पहाड़ों को, शुभ रात्रि धाराओं को,\nशुभ रात्रि दुनिया को और उसके सारे सपनों को।\nशुभ रात्रि तारों को और चाँदी-से चाँद को —\nशुभ रात्रि, मेरी जान, जल्द थामूँगी तुमको।')),

  // ---------- Affirmations & blessings (spoken to the baby) ----------
  ReadAloudPiece(
      category: kRtbAffirmations,
      title: _t('You are loved', 'तुमसे बहुत प्यार है'),
      body:
          _t("Little one, you are already so deeply loved. Before your first breath, before your first cry, you are wanted, treasured and adored.", 'नन्ही जान, तुमसे अभी से इतना गहरा प्यार है। तुम्हारी पहली साँस से पहले, तुम्हारी पहली आवाज़ से पहले — तुम्हें चाहा गया है, सँभाला गया है, और दिल में बसा लिया गया है।')),
  ReadAloudPiece(
      category: kRtbAffirmations,
      title: _t('Grow gently', 'नरमी से बढ़ो'),
      body:
          _t("Take your time, my darling. Grow strong and grow gently - there is no rush at all. We will be right here, waiting with open arms.", 'अपना समय लो, मेरी जान। मज़बूत बनो और नरमी से बढ़ो — बिलकुल कोई जल्दी नहीं है। हम यहीं होंगे, बाँहें खोले तुम्हारा इंतज़ार करते हुए।')),
  ReadAloudPiece(
      category: kRtbAffirmations,
      title: _t('You are safe', 'तुम सुरक्षित हो'),
      body:
          _t("You are warm, you are held, you are safe. Wherever this journey takes us, you will never be alone.", 'तुम गरम हो, तुम थामे हुए हो, तुम सुरक्षित हो। यह सफ़र हमें कहीं भी ले जाए, तुम कभी अकेले नहीं होगे।')),
  ReadAloudPiece(
      category: kRtbAffirmations,
      title: _t('A wish for joy', 'ख़ुशी की एक दुआ'),
      body:
          _t("May your days be full of laughter, your nights full of rest, and your heart full of all the love this world can hold.", 'तुम्हारे दिन हँसी से भरे रहें, तुम्हारी रातें चैन से, और तुम्हारा दिल उस सारे प्यार से जो यह दुनिया अपने भीतर समा सकती है।')),
  ReadAloudPiece(
      category: kRtbAffirmations,
      title: _t('Brave and kind', 'हिम्मती और भला'),
      body:
          _t("May you grow up brave enough to follow your heart, and kind enough to look after others along the way.", 'तुम इतने हिम्मती बनो कि अपने दिल की सुन सको, और इतने भले कि रास्ते में मिलने वालों का ख़याल रख सको।')),
  ReadAloudPiece(
      category: kRtbAffirmations,
      title: _t('Our little blessing', 'हमारा नन्हा आशीर्वाद'),
      body:
          _t("You are our greatest blessing, the answer to wishes we hardly dared to make. Thank you for choosing us.", 'तुम हमारा सबसे बड़ा आशीर्वाद हो — उन दुआओं का जवाब, जिन्हें माँगते हुए भी हम झिझकते थे। हमें चुनने के लिए शुक्रिया।')),
  ReadAloudPiece(
      category: kRtbAffirmations,
      title: _t('Sweet dreams', 'मीठे सपने'),
      body:
          _t("Rest now, little one. Dream of soft skies and gentle seas, and know that you are dreamed of too.", 'अब आराम करो, नन्ही जान। नरम आसमानों और कोमल समंदरों के सपने देखो — और जानो कि तुम्हें भी कोई सपनों में देखता है।')),
  ReadAloudPiece(
      category: kRtbAffirmations,
      title: _t('You are enough', 'तुम काफ़ी हो'),
      body:
          _t("Just as you are, you are enough. You don't have to be anything other than exactly, wonderfully you.", 'तुम जैसे हो, वैसे ही काफ़ी हो। तुम्हें अपने सिवा और कुछ बनने की ज़रूरत नहीं — बस तुम, ठीक वैसे ही, जितने प्यारे हो।')),
  ReadAloudPiece(
      category: kRtbAffirmations,
      title: _t('A calm heart', 'एक शांत दिल'),
      body:
          _t("May you carry a calm heart through the busy world, and always find your way back to peace.", 'इस भागती दुनिया में तुम्हारा दिल शांत रहे, और तुम हमेशा सुकून तक लौटने का रास्ता पा लो।')),
  ReadAloudPiece(
      category: kRtbAffirmations,
      title: _t('The world is waiting', 'दुनिया इंतज़ार में है'),
      body:
          _t("There is so much beauty waiting for you - sunrises and seashells, music and friends. We cannot wait to show you all of it.", 'तुम्हारे लिए कितनी सारी ख़ूबसूरती इंतज़ार में है — उगते सूरज और समंदर के सीप, संगीत और दोस्त। हमें तुम्हें यह सब दिखाने का बेसब्री से इंतज़ार है।')),
  ReadAloudPiece(
      category: kRtbAffirmations,
      title: _t('Held in love', 'प्यार में थमे हुए'),
      body:
          _t("Today and every day, you are held in love. It surrounds you now, and it always will.", 'आज और हर दिन, तुम प्यार में थामे हुए हो। वह अभी तुम्हें घेरे हुए है, और हमेशा घेरे रहेगा।')),
  ReadAloudPiece(
      category: kRtbAffirmations,
      title: _t('A wish for strength', 'ताक़त की एक दुआ'),
      body:
          _t("When the days are hard, may you find the strength inside you that has been there all along.", 'जब दिन मुश्किल हों, तुम अपने भीतर वह ताक़त पा लो जो हमेशा से वहीं थी।')),
  ReadAloudPiece(
      category: kRtbAffirmations,
      title: _t('You belong', 'यह जगह तुम्हारी है'),
      body:
          _t("You have a place in this family and in this world. You belong, simply by being you.", 'इस परिवार में और इस दुनिया में तुम्हारी अपनी जगह है। यह जगह तुम्हारी है, बस इसलिए कि तुम तुम हो।')),
  ReadAloudPiece(
      category: kRtbAffirmations,
      title: _t('Gentle beginnings', 'कोमल शुरुआत'),
      body:
          _t("May your beginning be gentle and your welcome be warm. We are getting everything ready for you.", 'तुम्हारी शुरुआत कोमल हो और तुम्हारा स्वागत गरमजोशी भरा। हम तुम्हारे लिए सब कुछ तैयार कर रहे हैं।')),
  ReadAloudPiece(
      category: kRtbAffirmations,
      title: _t('Loved beyond measure', 'बेहिसाब प्यार'),
      body:
          _t("There is no measuring how much you are loved - it is wider than the sky and deeper than the sea.", 'तुमसे कितना प्यार है, इसका कोई नाप नहीं — यह आसमान से चौड़ा है और समंदर से गहरा।')),
  ReadAloudPiece(
      category: kRtbAffirmations,
      title: _t('A blessing for the journey', 'सफ़र के लिए एक आशीर्वाद'),
      body:
          _t("May good health follow you, may kindness surround you, and may you always know how very loved you are.", 'सेहत तुम्हारे साथ चले, भलाई तुम्हें घेरे रहे, और तुम्हें हमेशा पता रहे कि तुमसे कितना प्यार है।')),
];

List<ReadAloudPiece> readAloudByCategory(String category) =>
    kReadAloudPieces.where((p) => p.category == category).toList();

/// The FATHER's affirmations & blessings - a distinct half of the shared pool,
/// so his "Read to your baby" affirmations differ from the mother's (she keeps
/// the full set). Same dataset, different slice; refine the selection anytime.
List<ReadAloudPiece> readAloudFatherAffirmations() {
  final all = readAloudByCategory(kRtbAffirmations);
  return all.sublist(all.length ~/ 2);
}
