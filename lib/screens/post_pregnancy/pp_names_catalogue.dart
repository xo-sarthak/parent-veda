// =============================================================================
//  The wider name catalogue - Indian names across faiths and regions
// -----------------------------------------------------------------------------
//  Added 2026-10-02 from the parenting gap analysis: theAsianparent and What
//  to Expect browse thousands of names; ours had 22, hand-written in full.
//  These are written in a compact form (name, Devanagari, gender, community,
//  region, origin, meaning, popularity) and expanded into ordinary BabyName
//  objects in pp_names_data.dart, which derives the rest:
//
//   * syllables, by counting vowel groups;
//   * the Chaldean number, by the same table the hand-written ones used;
//   * the rashi, from the traditional "naam akshar" chart by first sound,
//     offered as tradition, never as a claim, and saying so;
//   * three similar names of the same gender and community.
//
//  Meanings are the common ones a family would be told; several names carry
//  more than one, and a pandit, maulvi, granthi or priest may give another.
//  Hand-written entries in kBabyNamesAuthored always win over these.
//
//  One line per name:  Name|देवनागरी|b/g/u|Community|Region|Origin|meaning|T/C/R
//  (T trending, C classic, R rare). REQUIRED_REVIEW (a second reader for
//  meanings and the Devanagari).
// =============================================================================

const String kNameCatalogueRaw = '''
Aadi|आदि|b|Hindu|Pan-India|Sanskrit|The beginning; first|T
Aadhya|आद्या|g|Hindu|Pan-India|Sanskrit|The first power; Goddess Durga|T
Aahana|आहना|g|Hindu|Pan-India|Sanskrit|The first rays of the sun|T
Aakash|आकाश|b|Hindu|Pan-India|Sanskrit|The sky|C
Aanya|आन्या|g|Hindu|Pan-India|Sanskrit|Inexhaustible; grace|T
Aarush|आरुष|b|Hindu|Pan-India|Sanskrit|The first ray of the sun|T
Aaryan|आर्यन|b|Hindu|Pan-India|Sanskrit|Noble; honourable|T
Aashi|आशी|g|Hindu|Pan-India|Sanskrit|Blessing; smile|C
Abhay|अभय|b|Hindu|Pan-India|Sanskrit|Fearless|C
Abhinav|अभिनव|b|Hindu|Pan-India|Sanskrit|New; fresh|C
Abhishek|अभिषेक|b|Hindu|Pan-India|Sanskrit|A sacred bath of a deity|C
Aditi|अदिति|g|Hindu|Pan-India|Sanskrit|Boundless; mother of the gods|C
Aditya|आदित्य|b|Hindu|Pan-India|Sanskrit|The sun|C
Advik|अद्विक|b|Hindu|Pan-India|Sanskrit|Unique; one of a kind|T
Agastya|अगस्त्य|b|Hindu|South|Sanskrit|A revered sage|R
Ahaan|अहान|b|Hindu|Pan-India|Sanskrit|Dawn; first light|T
Aishwarya|ऐश्वर्या|g|Hindu|Pan-India|Sanskrit|Prosperity; wealth|C
Ajay|अजय|b|Hindu|Pan-India|Sanskrit|Unconquerable|C
Akanksha|आकांक्षा|g|Hindu|Pan-India|Sanskrit|Wish; aspiration|C
Akshara|अक्षरा|g|Hindu|South|Sanskrit|A letter; imperishable|C
Akshay|अक्षय|b|Hindu|Pan-India|Sanskrit|Imperishable; eternal|C
Alok|आलोक|b|Hindu|North|Sanskrit|Light; brightness|C
Amaira|अमायरा|g|Hindu|Pan-India|Sanskrit|Eternally beautiful|T
Aman|अमन|b|Secular|North|Urdu · Sanskrit|Peace|C
Amar|अमर|b|Hindu|Pan-India|Sanskrit|Immortal|C
Ambika|अम्बिका|g|Hindu|Pan-India|Sanskrit|Mother; Goddess Parvati|C
Amit|अमित|b|Hindu|Pan-India|Sanskrit|Boundless; infinite|C
Amrita|अमृता|g|Hindu|Pan-India|Sanskrit|Nectar of immortality|C
Anahita|अनाहिता|g|Secular|West|Persian|Graceful; pure|R
Anand|आनंद|b|Hindu|Pan-India|Sanskrit|Joy; bliss|C
Ananya|अनन्या|g|Hindu|Pan-India|Sanskrit|Unique; without equal|T
Anika|अनिका|g|Hindu|Pan-India|Sanskrit|Grace; Goddess Durga|T
Anirudh|अनिरुद्ध|b|Hindu|Pan-India|Sanskrit|Unstoppable; grandson of Krishna|C
Anjali|अंजलि|g|Hindu|Pan-India|Sanskrit|An offering with folded hands|C
Ankit|अंकित|b|Hindu|North|Sanskrit|Marked; dedicated|C
Ansh|अंश|b|Hindu|Pan-India|Sanskrit|A part; a portion of the divine|T
Anushka|अनुष्का|g|Hindu|Pan-India|Sanskrit|Grace; a ray of light|T
Anvi|अन्वी|g|Hindu|Pan-India|Sanskrit|Goddess of the forest|T
Arjun|अर्जुन|b|Hindu|Pan-India|Sanskrit|Bright; the archer of the Mahabharata|C
Arnav|अर्णव|b|Hindu|Pan-India|Sanskrit|The ocean|T
Arya|आर्या|g|Hindu|Pan-India|Sanskrit|Noble; Goddess Durga|T
Ashwin|अश्विन|b|Hindu|South|Sanskrit|A month of the Hindu calendar; horse-tamer|C
Atharv|अथर्व|b|Hindu|West|Sanskrit|Lord Ganesha; the fourth Veda|T
Avni|अवनी|g|Hindu|Pan-India|Sanskrit|The earth|T
Ayaan|अयान|b|Secular|Pan-India|Arabic · Sanskrit|Gift of God; path|T
Ayush|आयुष|b|Hindu|Pan-India|Sanskrit|Long life|C
Bhavna|भावना|g|Hindu|Pan-India|Sanskrit|Feeling; sentiment|C
Bhavya|भव्या|g|Hindu|Pan-India|Sanskrit|Grand; splendid|C
Bhuvan|भुवन|b|Hindu|Pan-India|Sanskrit|The world|C
Chaitanya|चैतन्य|b|Hindu|West|Sanskrit|Consciousness|C
Chandni|चांदनी|g|Hindu|North|Hindi|Moonlight|C
Charvi|चार्वी|g|Hindu|Pan-India|Sanskrit|Beautiful|T
Chetan|चेतन|b|Hindu|Pan-India|Sanskrit|Consciousness; alive|C
Chirag|चिराग|b|Hindu|North|Persian · Hindi|A lamp|C
Daksh|दक्ष|b|Hindu|Pan-India|Sanskrit|Skilful; able|T
Darsh|दर्श|b|Hindu|Pan-India|Sanskrit|Sight; Lord Krishna|T
Deepak|दीपक|b|Hindu|Pan-India|Sanskrit|A lamp|C
Deepika|दीपिका|g|Hindu|Pan-India|Sanskrit|A little lamp|C
Devansh|देवांश|b|Hindu|Pan-India|Sanskrit|A part of the divine|T
Devika|देविका|g|Hindu|Pan-India|Sanskrit|Little goddess|C
Dhruv|ध्रुव|b|Hindu|Pan-India|Sanskrit|The pole star; steadfast|T
Diya|दिया|g|Hindu|Pan-India|Hindi|A lamp|T
Divya|दिव्या|g|Hindu|Pan-India|Sanskrit|Divine; radiant|C
Eshaan|ईशान|b|Hindu|Pan-India|Sanskrit|Lord Shiva; the north-east|T
Eshita|ईशिता|g|Hindu|Pan-India|Sanskrit|One who desires; mastery|C
Gargi|गार्गी|g|Hindu|Pan-India|Sanskrit|A learned woman of the Upanishads|R
Gauri|गौरी|g|Hindu|Pan-India|Sanskrit|Fair; Goddess Parvati|C
Gautam|गौतम|b|Hindu|Pan-India|Sanskrit|A sage; the Buddha's family name|C
Gayatri|गायत्री|g|Hindu|Pan-India|Sanskrit|A Vedic hymn; mother of the Vedas|C
Girish|गिरीश|b|Hindu|Pan-India|Sanskrit|Lord of the mountains; Shiva|C
Gopal|गोपाल|b|Hindu|Pan-India|Sanskrit|Protector of cows; Krishna|C
Harini|हरिणी|g|Hindu|South|Sanskrit|A deer|C
Harsh|हर्ष|b|Hindu|Pan-India|Sanskrit|Happiness|C
Hemant|हेमंत|b|Hindu|Pan-India|Sanskrit|Early winter|C
Himani|हिमानी|g|Hindu|North|Sanskrit|Snow; Goddess Parvati|C
Hridaan|हृदान|b|Hindu|Pan-India|Sanskrit|Gift from the heart|T
Isha|ईशा|g|Hindu|Pan-India|Sanskrit|Goddess; one who protects|C
Ishaan|ईशान|b|Hindu|Pan-India|Sanskrit|The sun; Lord Shiva|T
Ishani|ईशानी|g|Hindu|Pan-India|Sanskrit|Goddess Parvati|T
Ishita|इशिता|g|Hindu|Pan-India|Sanskrit|Mastery; desired|C
Jahnavi|जाह्नवी|g|Hindu|Pan-India|Sanskrit|The river Ganga|C
Jai|जय|b|Hindu|Pan-India|Sanskrit|Victory|C
Janaki|जानकी|g|Hindu|Pan-India|Sanskrit|Sita, daughter of King Janaka|C
Jayant|जयंत|b|Hindu|Pan-India|Sanskrit|Victorious|C
Jiya|जिया|g|Hindu|North|Hindi|Heart; sweet|T
Kalpana|कल्पना|g|Hindu|Pan-India|Sanskrit|Imagination|C
Kartik|कार्तिक|b|Hindu|Pan-India|Sanskrit|A holy month; Lord Kartikeya|C
Kavya|काव्या|g|Hindu|Pan-India|Sanskrit|Poetry|T
Keshav|केशव|b|Hindu|Pan-India|Sanskrit|Lord Krishna|C
Kiran|किरण|u|Hindu|Pan-India|Sanskrit|A ray of light|C
Krish|क्रिश|b|Hindu|Pan-India|Sanskrit|Short for Krishna|T
Krishna|कृष्ण|b|Hindu|Pan-India|Sanskrit|Dark; the eighth avatar of Vishnu|C
Kunal|कुणाल|b|Hindu|Pan-India|Sanskrit|A lotus; a bird with beautiful eyes|C
Lakshmi|लक्ष्मी|g|Hindu|Pan-India|Sanskrit|Goddess of wealth|C
Lavanya|लावण्या|g|Hindu|South|Sanskrit|Grace; beauty|C
Madhav|माधव|b|Hindu|Pan-India|Sanskrit|Lord Krishna|C
Mahika|महिका|g|Hindu|Pan-India|Sanskrit|Dew; the earth|T
Manav|मानव|b|Hindu|Pan-India|Sanskrit|Human being|C
Manya|मान्या|g|Hindu|Pan-India|Sanskrit|Worthy of honour|T
Medha|मेधा|g|Hindu|Pan-India|Sanskrit|Intelligence; wisdom|C
Meera|मीरा|g|Hindu|Pan-India|Sanskrit|The poet-saint devoted to Krishna|C
Mihir|मिहिर|b|Hindu|Pan-India|Sanskrit|The sun|C
Mohit|मोहित|b|Hindu|North|Sanskrit|Enchanted|C
Nakul|नकुल|b|Hindu|Pan-India|Sanskrit|One of the Pandava brothers|C
Naina|नैना|g|Hindu|North|Hindi|Eyes|C
Namrata|नम्रता|g|Hindu|Pan-India|Sanskrit|Humility|C
Navya|नव्या|g|Hindu|Pan-India|Sanskrit|New; young|T
Neel|नील|b|Hindu|Pan-India|Sanskrit|Blue; the sapphire|T
Neha|नेहा|g|Hindu|Pan-India|Sanskrit|Love; affection|C
Nikhil|निखिल|b|Hindu|Pan-India|Sanskrit|Complete; whole|C
Nirav|नीरव|b|Hindu|West|Sanskrit|Quiet; silent|C
Nisha|निशा|g|Hindu|Pan-India|Sanskrit|Night|C
Nitya|नित्या|g|Hindu|Pan-India|Sanskrit|Eternal|T
Ojas|ओजस|b|Hindu|West|Sanskrit|Vitality; brilliance|T
Om|ॐ|b|Hindu|Pan-India|Sanskrit|The sacred sound|C
Pallavi|पल्लवी|g|Hindu|Pan-India|Sanskrit|New leaves; a young shoot|C
Pari|परी|g|Hindu|North|Persian · Hindi|A fairy|T
Parth|पार्थ|b|Hindu|Pan-India|Sanskrit|Arjuna, son of Pritha|C
Pooja|पूजा|g|Hindu|Pan-India|Sanskrit|Worship|C
Pragya|प्रज्ञा|g|Hindu|North|Sanskrit|Wisdom|C
Pranav|प्रणव|b|Hindu|Pan-India|Sanskrit|The sacred syllable Om|C
Prisha|प्रिशा|g|Hindu|Pan-India|Sanskrit|Beloved; a gift of God|T
Priya|प्रिया|g|Hindu|Pan-India|Sanskrit|Beloved|C
Rachit|रचित|b|Hindu|North|Sanskrit|Created; composed|C
Radha|राधा|g|Hindu|Pan-India|Sanskrit|Krishna's beloved; prosperity|C
Raghav|राघव|b|Hindu|Pan-India|Sanskrit|Lord Rama, of the Raghu clan|C
Rahul|राहुल|b|Hindu|Pan-India|Sanskrit|Conqueror of misery; son of the Buddha|C
Raj|राज|b|Hindu|Pan-India|Sanskrit|King; rule|C
Rajat|रजत|b|Hindu|North|Sanskrit|Silver|C
Ranveer|रणवीर|b|Hindu|North|Sanskrit|Brave in battle|T
Reyansh|रेयांश|b|Hindu|Pan-India|Sanskrit|A ray of light; part of Vishnu|T
Ridhima|रिद्धिमा|g|Hindu|North|Sanskrit|Full of love; prosperity|T
Rishi|ऋषि|b|Hindu|Pan-India|Sanskrit|A sage|C
Riya|रिया|g|Hindu|Pan-India|Sanskrit|Singer; graceful|C
Rohan|रोहन|b|Hindu|Pan-India|Sanskrit|Ascending; rising|C
Rudra|रुद्र|b|Hindu|Pan-India|Sanskrit|Lord Shiva in his fierce form|T
Rupal|रूपल|g|Hindu|West|Sanskrit|Made of silver; beautiful|C
Saanvi|सान्वी|g|Hindu|Pan-India|Sanskrit|Goddess Lakshmi; follower|T
Sahil|साहिल|b|Secular|North|Arabic · Urdu|The shore|C
Sai|साई|u|Hindu|Pan-India|Sanskrit · Marathi|Divine; a saint|C
Samaira|समायरा|g|Hindu|Pan-India|Sanskrit|Enchanting; protected by God|T
Samarth|समर्थ|b|Hindu|West|Sanskrit|Capable; powerful|T
Sanjana|संजना|g|Hindu|Pan-India|Sanskrit|Gentle; in harmony|C
Sara|सारा|g|Secular|Pan-India|Hebrew · Sanskrit|Princess; pure|T
Sarthak|सार्थक|b|Hindu|Pan-India|Sanskrit|Meaningful; fulfilled|C
Saurabh|सौरभ|b|Hindu|Pan-India|Sanskrit|Fragrance|C
Shaurya|शौर्य|b|Hindu|Pan-India|Sanskrit|Bravery|T
Shiv|शिव|b|Hindu|Pan-India|Sanskrit|Auspicious; Lord Shiva|C
Shlok|श्लोक|b|Hindu|Pan-India|Sanskrit|A hymn; a verse|T
Shreya|श्रेया|g|Hindu|Pan-India|Sanskrit|Auspicious; credit|C
Shruti|श्रुति|g|Hindu|Pan-India|Sanskrit|That which is heard; the Vedas|C
Siddharth|सिद्धार्थ|b|Hindu|Pan-India|Sanskrit|One who has achieved his goal; the Buddha|C
Sneha|स्नेहा|g|Hindu|Pan-India|Sanskrit|Affection|C
Suhana|सुहाना|g|Hindu|North|Hindi|Pleasant; lovely|T
Swara|स्वरा|g|Hindu|West|Sanskrit|A musical note|T
Tanvi|तन्वी|g|Hindu|Pan-India|Sanskrit|Slender; delicate|C
Tara|तारा|g|Hindu|Pan-India|Sanskrit|A star|T
Tanish|तनिष|b|Hindu|Pan-India|Sanskrit|Ambition; a jewel|T
Tejas|तेजस|b|Hindu|West|Sanskrit|Brilliance; radiance|C
Trisha|तृषा|g|Hindu|Pan-India|Sanskrit|Thirst; desire|C
Tushar|तुषार|b|Hindu|Pan-India|Sanskrit|Frost; dew|C
Uday|उदय|b|Hindu|Pan-India|Sanskrit|Rising; sunrise|C
Urvi|उर्वी|g|Hindu|Pan-India|Sanskrit|The earth|T
Vaani|वाणी|g|Hindu|Pan-India|Sanskrit|Speech; Goddess Saraswati|C
Vansh|वंश|b|Hindu|North|Sanskrit|Lineage; family|T
Varun|वरुण|b|Hindu|Pan-India|Sanskrit|Lord of the waters|C
Ved|वेद|b|Hindu|Pan-India|Sanskrit|Sacred knowledge|T
Vedika|वेदिका|g|Hindu|Pan-India|Sanskrit|An altar; awareness|T
Vihaan|विहान|b|Hindu|Pan-India|Sanskrit|Dawn; morning|T
Vikram|विक्रम|b|Hindu|Pan-India|Sanskrit|Valour; a legendary king|C
Vivaan|विवान|b|Hindu|Pan-India|Sanskrit|Full of life; Lord Krishna|T
Yash|यश|b|Hindu|Pan-India|Sanskrit|Fame; glory|C
Yashvi|यशवी|g|Hindu|Pan-India|Sanskrit|Famous; glorious|T
Yuvan|युवान|b|Hindu|South|Sanskrit|Youthful; strong|T
Yuvraj|युवराज|b|Hindu|North|Sanskrit|Crown prince|C
Zoya|ज़ोया|g|Muslim|Pan-India|Persian · Arabic|Alive; loving|T
Aarohi|आरोही|g|Hindu|West|Sanskrit|An ascending musical scale|T
Aniket|अनिकेत|b|Hindu|West|Sanskrit|Lord of all; without a fixed home|C
Mrunal|मृणाल|u|Hindu|West|Sanskrit|Lotus stem|C
Omkar|ओंकार|b|Hindu|West|Sanskrit|The sacred sound Om|C
Pranjal|प्रांजल|u|Hindu|West|Sanskrit|Honest; sincere|C
Sharvari|शर्वरी|g|Hindu|West|Sanskrit|Twilight; night|R
Soham|सोहम|b|Hindu|West|Sanskrit|I am that (the divine)|T
Tanmay|तन्मय|b|Hindu|West|Sanskrit|Absorbed; engrossed|C
Vedant|वेदांत|b|Hindu|West|Sanskrit|The end of the Vedas; ultimate knowledge|T
Dhwani|ध्वनि|g|Hindu|West|Sanskrit|Sound; voice|C
Heer|हीर|g|Hindu|West|Sanskrit · Punjabi|A diamond|T
Jinal|जिनल|g|Hindu|West|Gujarati|Devoted to God|C
Krupa|कृपा|g|Hindu|West|Sanskrit|Grace; kindness|C
Mitali|मिताली|g|Hindu|East|Sanskrit|Friendship|C
Nirali|निराली|g|Hindu|West|Gujarati · Hindi|Unique; different|C
Parthiv|पार्थिव|b|Hindu|West|Sanskrit|Of the earth|C
Riddhi|ऋद्धि|g|Hindu|West|Sanskrit|Prosperity; good fortune|C
Siddhi|सिद्धि|g|Hindu|West|Sanskrit|Achievement; perfection|C
Viraj|विराज|b|Hindu|West|Sanskrit|Splendour; the supreme being|C
Aditri|आदित्री|g|Hindu|Pan-India|Sanskrit|Goddess Lakshmi; honoured|R
Bodhi|बोधि|u|Hindu|Pan-India|Sanskrit · Pali|Enlightenment|R
Ira|इरा|g|Hindu|Pan-India|Sanskrit|The earth; Goddess Saraswati|T
Kiaan|कियान|b|Secular|Pan-India|Sanskrit · Persian|Grace of God; ancient|T
Mishka|मिश्का|g|Hindu|Pan-India|Sanskrit|A gift of love|T
Navya Sri|नव्यश्री|g|Hindu|South|Sanskrit · Telugu|New prosperity|R
Reva|रेवा|g|Hindu|Pan-India|Sanskrit|The river Narmada|R
Sarvagya|सर्वज्ञ|b|Hindu|Pan-India|Sanskrit|All-knowing|R
Taarush|तारुष|b|Hindu|Pan-India|Sanskrit|Conqueror; small plant|R
Vanya|वान्या|g|Hindu|Pan-India|Sanskrit|Of the forest; gracious|T
Advaita|अद्वैता|g|Hindu|South|Sanskrit|Non-duality; unique|R
Anagha|अनघा|g|Hindu|South|Sanskrit|Sinless; pure|C
Aravind|अरविंद|b|Hindu|South|Sanskrit|A lotus|C
Bhargavi|भार्गवी|g|Hindu|South|Sanskrit|Goddess Lakshmi; Parvati|C
Deepthi|दीप्ति|g|Hindu|South|Sanskrit|Brightness; lustre|C
Dhanush|धनुष|b|Hindu|South|Sanskrit|A bow|C
Gowtham|गौतम|b|Hindu|South|Sanskrit · Telugu|A sage; enlightened|C
Hari|हरि|b|Hindu|South|Sanskrit|Lord Vishnu|C
Ilakkiya|इलक्किया|g|Hindu|South|Tamil|Literature|R
Kavin|कविन|b|Hindu|South|Tamil|Handsome; graceful|T
Kayal|कयल|g|Hindu|South|Tamil|A fish; eyes shaped like a fish|R
Keerthana|कीर्तना|g|Hindu|South|Sanskrit|A devotional song|C
Lokesh|लोकेश|b|Hindu|South|Sanskrit|Lord of the world|C
Madhumitha|मधुमिता|g|Hindu|South|Sanskrit|Sweet as honey|C
Magizh|मगिल|u|Hindu|South|Tamil|Joy; happiness|R
Malar|मलर|g|Hindu|South|Tamil|A flower|C
Meenakshi|मीनाक्षी|g|Hindu|South|Sanskrit|Fish-eyed; Goddess of Madurai|C
Nila|निला|g|Hindu|South|Tamil|The moon|T
Pradeep|प्रदीप|b|Hindu|South|Sanskrit|A light; a lamp|C
Ramya|रम्या|g|Hindu|South|Sanskrit|Beautiful; pleasing|C
Sanjay|संजय|b|Hindu|Pan-India|Sanskrit|Victorious|C
Senthil|सेंथिल|b|Hindu|South|Tamil|Lord Murugan|C
Shanmukh|षण्मुख|b|Hindu|South|Sanskrit|Six-faced; Lord Murugan|C
Sindhu|सिंधु|g|Hindu|South|Sanskrit|The river; the ocean|C
Sowmya|सौम्या|g|Hindu|South|Sanskrit|Gentle; calm|C
Srinivas|श्रीनिवास|b|Hindu|South|Sanskrit|Abode of Lakshmi; Lord Venkateshwara|C
Tamizh|तमिल|u|Hindu|South|Tamil|The Tamil language; sweetness|R
Thanvi|तन्वी|g|Hindu|South|Sanskrit|Delicate; slender|C
Vaishnavi|वैष्णवी|g|Hindu|South|Sanskrit|Devotee of Vishnu; Goddess Durga|C
Venkat|वेंकट|b|Hindu|South|Telugu · Sanskrit|Lord Venkateshwara|C
Yazhini|याळिनी|g|Hindu|South|Tamil|Music of the yazh, an ancient harp|R
Abhirami|अभिरामी|g|Hindu|South|Sanskrit|Pleasing; Goddess Parvati|C
Anirban|अनिर्बाण|b|Hindu|East|Bengali · Sanskrit|Undying; eternal flame|C
Arpita|अर्पिता|g|Hindu|East|Sanskrit|Offered; dedicated|C
Debolina|देबोलीना|g|Hindu|East|Bengali|Absorbed in the divine|C
Indrani|इंद्राणी|g|Hindu|East|Sanskrit|Wife of Indra|C
Ishaanvi|ईशान्वी|g|Hindu|East|Sanskrit|Goddess Lakshmi|T
Joydeep|जयदीप|b|Hindu|East|Bengali · Sanskrit|Lamp of victory|C
Mrinalini|मृणालिनी|g|Hindu|East|Sanskrit|A lotus plant|C
Oishi|ऐशी|g|Hindu|East|Bengali|Divine; of the goddess|R
Payel|पायल|g|Hindu|East|Bengali · Hindi|An anklet|C
Rituparna|ऋतुपर्णा|g|Hindu|East|Sanskrit|Leaf of the season|R
Shubhro|शुभ्र|b|Hindu|East|Bengali · Sanskrit|Bright; white|C
Sohini|सोहिनी|g|Hindu|East|Sanskrit|Beautiful; a raga|C
Sourav|सौरव|b|Hindu|East|Bengali · Sanskrit|Fragrance; divine|C
Tiyasha|तियाशा|g|Hindu|East|Bengali|Thirst; desire|R
Trina|तृणा|g|Hindu|East|Sanskrit|A blade of grass|C
Anwesha|अन्वेषा|g|Hindu|East|Sanskrit|Search; quest|C
Ayesha|आयशा|g|Muslim|Pan-India|Arabic|Alive; prosperous|C
Aamir|आमिर|b|Muslim|Pan-India|Arabic|Prosperous; full of life|C
Aariz|आरिज़|b|Muslim|Pan-India|Arabic|Respectable; leader|T
Adnan|अदनान|b|Muslim|Pan-India|Arabic|Settler; an ancestor of the Prophet|C
Afreen|आफ़रीन|g|Muslim|Pan-India|Persian|Praise; encouragement|C
Ahmed|अहमद|b|Muslim|Pan-India|Arabic|Highly praised|C
Aisha|आइशा|g|Muslim|Pan-India|Arabic|Living; life|C
Alina|अलीना|g|Muslim|Pan-India|Arabic · Greek|Noble; light|T
Alisha|अलीशा|g|Muslim|Pan-India|Arabic · Sanskrit|Protected by God|T
Amaan|अमान|b|Muslim|Pan-India|Arabic|Safety; protection|T
Amaya|अमाया|g|Secular|Pan-India|Japanese · Sanskrit|Night rain; without illusion|T
Arham|अरहम|b|Muslim|Pan-India|Arabic|Merciful|T
Arhaan|अरहान|b|Muslim|Pan-India|Arabic|Ruler; king|T
Arshia|अर्शिया|g|Muslim|Pan-India|Persian|Heavenly; of the throne|T
Ayat|आयत|g|Muslim|Pan-India|Arabic|A sign; a verse of the Quran|T
Azaan|अज़ान|b|Muslim|Pan-India|Arabic|The call to prayer|T
Bilal|बिलाल|b|Muslim|Pan-India|Arabic|Water; a companion of the Prophet|C
Danish|दानिश|b|Muslim|North|Persian|Knowledge; wisdom|C
Eman|ईमान|g|Muslim|Pan-India|Arabic|Faith|T
Faiz|फ़ैज़|b|Muslim|North|Arabic|Grace; abundance|C
Farhan|फ़रहान|b|Muslim|Pan-India|Arabic|Happy; joyful|C
Fatima|फ़ातिमा|g|Muslim|Pan-India|Arabic|Daughter of the Prophet; one who abstains|C
Hamza|हमज़ा|b|Muslim|Pan-India|Arabic|Lion; strong|T
Haniya|हानिया|g|Muslim|Pan-India|Arabic|Happy; content|T
Hiba|हिबा|g|Muslim|Pan-India|Arabic|A gift|T
Ibrahim|इब्राहिम|b|Muslim|Pan-India|Arabic|The prophet Abraham|C
Imran|इमरान|b|Muslim|Pan-India|Arabic|Prosperity; family of Imran|C
Inaya|इनाया|g|Muslim|Pan-India|Arabic|Care; concern|T
Irfan|इरफ़ान|b|Muslim|Pan-India|Arabic|Knowledge; awareness|C
Ismail|इस्माइल|b|Muslim|Pan-India|Arabic|God hears; the prophet Ishmael|C
Khadija|ख़दीजा|g|Muslim|Pan-India|Arabic|Wife of the Prophet; early child|C
Mahira|माहिरा|g|Muslim|Pan-India|Arabic|Skilful; clever|T
Maryam|मरयम|g|Muslim|Pan-India|Arabic|Mother of Prophet Isa (Jesus)|C
Mehr|मेहर|g|Muslim|North|Persian|Kindness; the sun|T
Mohammed|मोहम्मद|b|Muslim|Pan-India|Arabic|Praiseworthy; the Prophet|C
Musa|मूसा|b|Muslim|Pan-India|Arabic · Hebrew|The prophet Moses|C
Naira|नायरा|g|Muslim|Pan-India|Arabic|Shining; bright|T
Nasreen|नसरीन|g|Muslim|North|Persian|Wild rose|C
Noor|नूर|g|Muslim|Pan-India|Arabic|Light|T
Rayyan|रय्यान|b|Muslim|Pan-India|Arabic|Gate of heaven; well watered|T
Rehan|रेहान|b|Muslim|Pan-India|Arabic|Sweet basil; fragrant|C
Rizwan|रिज़वान|b|Muslim|Pan-India|Arabic|Keeper of the gates of heaven; contentment|C
Rumi|रूमी|u|Muslim|Pan-India|Persian|The Sufi poet; from Rum|R
Saad|साद|b|Muslim|Pan-India|Arabic|Good fortune|C
Safa|सफ़ा|g|Muslim|Pan-India|Arabic|Purity; a hill near Mecca|C
Saif|सैफ़|b|Muslim|Pan-India|Arabic|A sword|C
Sameer|समीर|b|Secular|Pan-India|Arabic · Sanskrit|Gentle breeze; companion|C
Sana|सना|g|Muslim|Pan-India|Arabic|Brilliance; praise|C
Shifa|शिफ़ा|g|Muslim|Pan-India|Arabic|Healing|C
Sufiyan|सुफ़ियान|b|Muslim|Pan-India|Arabic|Devoted; pure|C
Taha|ताहा|b|Muslim|Pan-India|Arabic|Pure; the name of a surah|T
Talha|तल्हा|b|Muslim|Pan-India|Arabic|A kind of tree; a companion of the Prophet|C
Umar|उमर|b|Muslim|Pan-India|Arabic|Long-lived; flourishing|C
Usman|उस्मान|b|Muslim|Pan-India|Arabic|A companion of the Prophet|C
Yusuf|यूसुफ़|b|Muslim|Pan-India|Arabic · Hebrew|The prophet Joseph|C
Zain|ज़ैन|b|Muslim|Pan-India|Arabic|Beauty; grace|T
Zara|ज़ारा|g|Muslim|Pan-India|Arabic|Radiance; princess|T
Zayan|ज़यान|b|Muslim|Pan-India|Arabic|Beautiful; graceful|T
Zehra|ज़ेहरा|g|Muslim|Pan-India|Arabic|Radiant; brilliant|T
Zidan|ज़िदान|b|Muslim|Pan-India|Arabic|Growth; abundance|R
Zubair|ज़ुबैर|b|Muslim|Pan-India|Arabic|Strong; a companion of the Prophet|C
Aliya|आलिया|g|Muslim|Pan-India|Arabic|Exalted; noble|C
Areeba|अरीबा|g|Muslim|Pan-India|Arabic|Wise; clever|T
Hoorain|हूरैन|g|Muslim|Pan-India|Arabic|Maidens of paradise|T
Rida|रिदा|g|Muslim|Pan-India|Arabic|Contentment; God's favour|C
Ahad|अहद|b|Muslim|Pan-India|Arabic|One; unique|T
Amandeep|अमनदीप|u|Sikh|North|Punjabi · Sanskrit|Lamp of peace|C
Amrit|अमृत|u|Sikh|North|Sanskrit · Punjabi|Nectar; holy water|C
Angad|अंगद|b|Sikh|North|Punjabi · Sanskrit|The second Sikh Guru; a part of the body|C
Arjan|अर्जन|b|Sikh|North|Punjabi|The fifth Guru, Guru Arjan Dev|C
Arshdeep|अर्शदीप|u|Sikh|North|Punjabi|Light of the heavens|C
Balraj|बलराज|b|Sikh|North|Punjabi · Sanskrit|Mighty king|C
Dilpreet|दिलप्रीत|g|Sikh|North|Punjabi|Love of the heart|C
Fateh|फ़तेह|b|Sikh|North|Punjabi · Persian|Victory|T
Gurbani|गुरबाणी|g|Sikh|North|Punjabi|The Guru's word|C
Gurnoor|गुरनूर|u|Sikh|North|Punjabi|The Guru's light|T
Gurpreet|गुरप्रीत|u|Sikh|North|Punjabi|Love of the Guru|C
Harleen|हरलीन|g|Sikh|North|Punjabi|Absorbed in God|C
Harnoor|हरनूर|g|Sikh|North|Punjabi|God's light|T
Harpreet|हरप्रीत|u|Sikh|North|Punjabi|Love of God|C
Inder|इंदर|b|Sikh|North|Punjabi · Sanskrit|Lord Indra; ruler|C
Jasleen|जसलीन|g|Sikh|North|Punjabi|Absorbed in praising God|C
Jaspreet|जसप्रीत|u|Sikh|North|Punjabi|Love of praise for God|C
Jasraj|जसराज|b|Sikh|North|Punjabi|Glorious king|C
Jaskaran|जसकरण|b|Sikh|North|Punjabi|One who sings God's praises|C
Karanveer|करणवीर|b|Sikh|North|Punjabi · Sanskrit|Brave like Karna|C
Kirat|किरत|u|Sikh|North|Punjabi|Honest work; praise|T
Mannat|मन्नत|g|Sikh|North|Punjabi · Persian|A prayer; a vow|T
Manpreet|मनप्रीत|u|Sikh|North|Punjabi|Love of the mind|C
Navdeep|नवदीप|u|Sikh|North|Punjabi · Sanskrit|A new lamp|C
Navjot|नवजोत|u|Sikh|North|Punjabi|A new light|C
Nihal|निहाल|b|Sikh|North|Punjabi · Persian|Content; blessed|C
Prabhjot|प्रभजोत|u|Sikh|North|Punjabi|Light of God|C
Rabaab|रबाब|g|Sikh|North|Punjabi|A stringed instrument of devotional music|R
Rajveer|राजवीर|b|Sikh|North|Punjabi · Sanskrit|Brave king|T
Sahib|साहिब|b|Sikh|North|Punjabi · Arabic|Master; lord|C
Sehaj|सहज|u|Sikh|North|Punjabi|Calm; poise|T
Simran|सिमरन|g|Sikh|North|Punjabi|Remembrance of God|C
Sukhman|सुखमन|u|Sikh|North|Punjabi|Peace of mind|C
Taranpreet|तरनप्रीत|u|Sikh|North|Punjabi|Love that carries across|C
Tegbir|तेगबीर|b|Sikh|North|Punjabi|Brave with the sword|R
Waheed|वहीद|b|Muslim|North|Arabic|Unique; singular|C
Aaron|ऐरन|b|Christian|Pan-India|Hebrew|Mountain of strength; brother of Moses|C
Abigail|एबिगेल|g|Christian|Pan-India|Hebrew|A father's joy|C
Alan|एलन|b|Christian|Pan-India|Celtic|Handsome; cheerful|C
Alfred|अल्फ़्रेड|b|Christian|South|English|Wise counsellor|C
Angela|एंजेला|g|Christian|Pan-India|Greek|Messenger; angel|C
Anna|ऐना|g|Christian|Pan-India|Hebrew|Grace|C
Ashley|ऐशली|u|Christian|Pan-India|English|Ash-tree meadow|C
Benjamin|बेंजामिन|b|Christian|Pan-India|Hebrew|Son of the right hand|C
Catherine|कैथरीन|g|Christian|Pan-India|Greek|Pure|C
Christopher|क्रिस्टोफ़र|b|Christian|Pan-India|Greek|Bearer of Christ|C
Clara|क्लारा|g|Christian|Pan-India|Latin|Clear; bright|C
Daniel|डेनियल|b|Christian|Pan-India|Hebrew|God is my judge|C
David|डेविड|b|Christian|Pan-India|Hebrew|Beloved|C
Elizabeth|एलिज़ाबेथ|g|Christian|Pan-India|Hebrew|God is my oath|C
Emmanuel|इमैनुएल|b|Christian|Pan-India|Hebrew|God is with us|C
Esther|एस्थर|g|Christian|Pan-India|Persian · Hebrew|A star|C
Evan|इवान|b|Christian|Pan-India|Welsh · Hebrew|God is gracious|T
Gabriel|गेब्रियल|b|Christian|Pan-India|Hebrew|God is my strength|C
Grace|ग्रेस|g|Christian|Pan-India|Latin|Grace; goodness|C
Hannah|हन्ना|g|Christian|Pan-India|Hebrew|Grace; favour|C
Isaac|आइज़ैक|b|Christian|Pan-India|Hebrew|He will laugh|C
Jacob|जैकब|b|Christian|Pan-India|Hebrew|Supplanter|C
Jerome|जेरोम|b|Christian|South|Greek|Sacred name|C
Joel|जोएल|b|Christian|Pan-India|Hebrew|The Lord is God|C
John|जॉन|b|Christian|Pan-India|Hebrew|God is gracious|C
Joseph|जोसेफ़|b|Christian|Pan-India|Hebrew|He will add|C
Joshua|जोशुआ|b|Christian|Pan-India|Hebrew|The Lord is salvation|C
Leah|लिया|g|Christian|Pan-India|Hebrew|Weary; delicate|C
Lydia|लिडिया|g|Christian|Pan-India|Greek|From Lydia; a woman of the New Testament|C
Mary|मैरी|g|Christian|Pan-India|Hebrew|Beloved; the mother of Jesus|C
Mathew|मैथ्यू|b|Christian|South|Hebrew|Gift of God|C
Michael|माइकल|b|Christian|Pan-India|Hebrew|Who is like God|C
Miriam|मिरियम|g|Christian|Pan-India|Hebrew|Beloved; sister of Moses|C
Nathan|नैथन|b|Christian|Pan-India|Hebrew|He gave|C
Noel|नोएल|u|Christian|Pan-India|French|Christmas|C
Paul|पॉल|b|Christian|Pan-India|Latin|Small; humble|C
Peter|पीटर|b|Christian|Pan-India|Greek|A rock|C
Rachel|रेचल|g|Christian|Pan-India|Hebrew|A ewe; gentle|C
Rebecca|रेबेका|g|Christian|Pan-India|Hebrew|To bind; captivating|C
Ruth|रूथ|g|Christian|Pan-India|Hebrew|Friend; companion|C
Samuel|सैमुअल|b|Christian|Pan-India|Hebrew|God has heard|C
Sophia|सोफ़िया|g|Christian|Pan-India|Greek|Wisdom|T
Stephen|स्टीफ़न|b|Christian|Pan-India|Greek|Crown|C
Thomas|थॉमस|b|Christian|South|Aramaic|Twin; the apostle of India|C
Vincent|विंसेंट|b|Christian|Pan-India|Latin|Conquering|C
Zachariah|ज़कराया|b|Christian|Pan-India|Hebrew|God remembers|R
Ann Maria|ऐन मारिया|g|Christian|South|Hebrew · Latin|Grace and beloved|C
Jovita|जोविता|g|Christian|West|Latin|Joyful|R
Shalom|शालोम|u|Christian|Pan-India|Hebrew|Peace|R
Alvin|एल्विन|b|Christian|South|English|Noble friend|C
Aadvik|आद्विक|b|Hindu|Pan-India|Sanskrit|Unique|T
Aarna|आर्णा|g|Hindu|Pan-India|Sanskrit|Goddess Lakshmi; the sea|T
Ahana|अहना|g|Hindu|East|Sanskrit|Inner light; the first rays of the sun|C
Akira|अकीरा|g|Secular|Pan-India|Japanese · Sanskrit|Bright; graceful strength|T
Alaya|आलया|g|Hindu|Pan-India|Sanskrit|Home; abode|T
Anay|अनय|b|Hindu|Pan-India|Sanskrit|Lord Vishnu; without a superior|T
Anvay|अन्वय|b|Hindu|West|Sanskrit|Connected; lineage|T
Aryav|आर्यव|b|Hindu|Pan-India|Sanskrit|Noble|T
Avyaan|अव्यान|b|Hindu|Pan-India|Sanskrit|Lord Vishnu; without equal|T
Ayansh|अयांश|b|Hindu|Pan-India|Sanskrit|The first ray of the sun|T
Darshana|दर्शना|g|Hindu|Pan-India|Sanskrit|Vision; seeing the divine|C
Dhriti|धृति|g|Hindu|Pan-India|Sanskrit|Patience; courage|T
Divit|दिवित|b|Hindu|Pan-India|Sanskrit|Immortal; divine|T
Eva|ईवा|g|Secular|Pan-India|Hebrew · Sanskrit|Life|T
Garv|गर्व|b|Hindu|North|Sanskrit|Pride|T
Hiya|हिया|g|Hindu|Pan-India|Sanskrit|Heart|T
Hriday|हृदय|b|Hindu|Pan-India|Sanskrit|Heart|C
Jivika|जीविका|g|Hindu|Pan-India|Sanskrit|Livelihood; water|R
Kairav|कैरव|b|Hindu|Pan-India|Sanskrit|A white lotus|T
Kashvi|काश्वी|g|Hindu|Pan-India|Sanskrit|Shining; bright|T
Kiyansh|कियांश|b|Hindu|Pan-India|Sanskrit|Gift of God; a part of the divine|T
Laksh|लक्ष|b|Hindu|Pan-India|Sanskrit|Aim; target|T
Lavya|लव्या|g|Hindu|Pan-India|Sanskrit|Worthy of praise|R
Mahi|माही|u|Hindu|Pan-India|Sanskrit|The earth; great|T
Mayra|मायरा|g|Hindu|Pan-India|Sanskrit · Arabic|Beloved; admirable|T
Moksh|मोक्ष|b|Hindu|Pan-India|Sanskrit|Liberation|T
Naitik|नैतिक|b|Hindu|West|Sanskrit|Moral; principled|C
Nivaan|निवान|b|Hindu|Pan-India|Sanskrit|Holy; sacred|T
Ojasvi|ओजस्वी|g|Hindu|Pan-India|Sanskrit|Bright; full of vitality|T
Parv|पर्व|b|Hindu|Pan-India|Sanskrit|A festival|T
Pihu|पीहू|g|Hindu|North|Hindi|The call of a peacock; sweet|T
Raahi|राही|u|Hindu|North|Hindi|A traveller|T
Riaan|रियान|b|Secular|Pan-India|Sanskrit · Arabic|Little king; gate of heaven|T
Rivaan|रिवान|b|Hindu|Pan-India|Sanskrit|Bright|T
Ruhi|रूही|g|Muslim|Pan-India|Arabic|Of the soul|C
Shanaya|शनाया|g|Hindu|Pan-India|Sanskrit|The first ray of the sun|T
Shivansh|शिवांश|b|Hindu|Pan-India|Sanskrit|A part of Shiva|T
Siya|सिया|g|Hindu|Pan-India|Sanskrit|Sita|T
Tvisha|त्विषा|g|Hindu|Pan-India|Sanskrit|Bright; radiant|R
Vaanya|वान्या|g|Hindu|Pan-India|Sanskrit|Gracious gift of God|T
Viaan|वियान|b|Hindu|Pan-India|Sanskrit|Full of life|T
Yuvika|युविका|g|Hindu|Pan-India|Sanskrit|A young woman|T
Zian|ज़ियान|b|Muslim|Pan-India|Arabic|Self-illuminating|T
Bhavesh|भावेश|b|Hindu|West|Sanskrit|Lord of feelings; Shiva|C
Chinmay|चिन्मय|b|Hindu|West|Sanskrit|Full of consciousness|C
Darshil|दर्शिल|b|Hindu|West|Sanskrit|Fine-looking|C
Hetvi|हेत्वी|g|Hindu|West|Gujarati|Loving; affectionate|C
Jash|जश|b|Hindu|West|Gujarati · Sanskrit|Fame; glory|C
Kavish|कविश|b|Hindu|Pan-India|Sanskrit|King of poets; Lord Ganesha|C
Mahek|महक|g|Hindu|West|Hindi|Fragrance|C
Nishtha|निष्ठा|g|Hindu|Pan-India|Sanskrit|Faith; devotion|C
Prerna|प्रेरणा|g|Hindu|Pan-India|Sanskrit|Inspiration|C
Rishabh|ऋषभ|b|Hindu|Pan-India|Sanskrit|Superior; the first Jain Tirthankara|C
Shivani|शिवानी|g|Hindu|Pan-India|Sanskrit|Goddess Parvati|C
Utkarsh|उत्कर्ष|b|Hindu|North|Sanskrit|Rise; excellence|C
Vrinda|वृंदा|g|Hindu|Pan-India|Sanskrit|Tulsi; Goddess Radha|C
Yamini|यामिनी|g|Hindu|Pan-India|Sanskrit|Night|C
Kshitij|क्षितिज|b|Hindu|Pan-India|Sanskrit|The horizon|C
Mrinal|मृणाल|b|Hindu|East|Sanskrit|Lotus stem|C
Abeer|अबीर|u|Hindu|North|Arabic · Hindi|Fragrance; coloured powder of Holi|T
Aranya|अरण्या|g|Hindu|Pan-India|Sanskrit|Forest|R
Dev|देव|b|Hindu|Pan-India|Sanskrit|God; divine|C
Ekansh|एकांश|b|Hindu|Pan-India|Sanskrit|Whole; a single part|T
Gaurav|गौरव|b|Hindu|Pan-India|Sanskrit|Pride; honour|C
Ishwar|ईश्वर|b|Hindu|Pan-India|Sanskrit|God; the supreme lord|C
Jagat|जगत|b|Hindu|Pan-India|Sanskrit|The world|C
Kush|कुश|b|Hindu|Pan-India|Sanskrit|Son of Rama; sacred grass|C
Luv|लव|b|Hindu|Pan-India|Sanskrit|Son of Rama|C
Nandini|नंदिनी|g|Hindu|Pan-India|Sanskrit|Daughter; the sacred cow|C
Pavan|पवन|b|Hindu|Pan-India|Sanskrit|Wind; breeze|C
Rani|रानी|g|Hindu|Pan-India|Sanskrit|Queen|C
Sagar|सागर|b|Hindu|Pan-India|Sanskrit|The ocean|C
Tulsi|तुलसी|g|Hindu|Pan-India|Sanskrit|Holy basil|C
Uma|उमा|g|Hindu|Pan-India|Sanskrit|Goddess Parvati; tranquillity|C
Vidya|विद्या|g|Hindu|Pan-India|Sanskrit|Knowledge|C
Aarvi|आर्वी|g|Hindu|Pan-India|Sanskrit|Peace|T
Advika|अद्विका|g|Hindu|Pan-India|Sanskrit|Unique; one of a kind|T
Amara|अमारा|g|Secular|Pan-India|Sanskrit · Igbo|Immortal; grace|T
Charu|चारु|g|Hindu|Pan-India|Sanskrit|Beautiful; graceful|C
Ela|एला|g|Hindu|Pan-India|Sanskrit|The earth; cardamom|T
Gia|जिया|g|Secular|Pan-India|Italian · Hindi|God's grace; heart|T
Inika|इनिका|g|Hindu|Pan-India|Sanskrit|Little earth|T
Kyra|काइरा|g|Secular|Pan-India|Greek|Lady; throne|T
Liana|लियाना|g|Secular|Pan-India|French|A climbing vine; youth|R
Nayra|नायरा|g|Hindu|Pan-India|Sanskrit|Beautiful; shining|T
Oviya|ओविया|g|Hindu|South|Tamil|Drawing; a work of art|T
Rhea|रिया|g|Secular|Pan-India|Greek · Sanskrit|Flowing; singer|T
Saisha|साइशा|g|Hindu|Pan-India|Sanskrit|Meaningful life; God's grace|T
Taarini|तारिणी|g|Hindu|Pan-India|Sanskrit|Goddess Durga; one who carries across|C
Vamika|वामिका|g|Hindu|Pan-India|Sanskrit|Goddess Durga|T
Yaira|यायरा|g|Hindu|Pan-India|Sanskrit|Goddess Lakshmi|R
Aabha|आभा|g|Hindu|Pan-India|Sanskrit|Glow; splendour|C
Aabid|आबिद|b|Muslim|Pan-India|Arabic|Worshipper|C
Aabir|अबीर|b|Hindu|North|Hindi|Coloured powder of Holi|T
Aadhavan|आधवन|b|Hindu|South|Tamil|The sun|T
Aadil|आदिल|b|Muslim|Pan-India|Arabic|Just; fair|C
Aadya|आद्या|g|Hindu|Pan-India|Sanskrit|The first; Goddess Durga|T
Aafiya|आफ़िया|g|Muslim|Pan-India|Arabic|Good health|T
Aagam|आगम|b|Jain|West|Sanskrit|Scripture; coming|R
Aahil|आहिल|b|Muslim|Pan-India|Arabic|Prince; leader|T
Aakaash|आकाश|b|Hindu|Pan-India|Sanskrit|Sky|C
Aakarsh|आकर्ष|b|Hindu|Pan-India|Sanskrit|Attraction; charm|T
Aakriti|आकृति|g|Hindu|Pan-India|Sanskrit|Shape; form|C
Aalim|आलिम|b|Muslim|Pan-India|Arabic|Learned; scholar|C
Aaliya|आलिया|g|Muslim|Pan-India|Arabic|High; exalted|T
Aalok|आलोक|b|Hindu|North|Sanskrit|Light|C
Aamna|आमना|g|Muslim|Pan-India|Arabic|Safe; peaceful|C
Aamod|आमोद|b|Hindu|West|Sanskrit|Delight; pleasure|C
Aanvi|आन्वी|g|Hindu|Pan-India|Sanskrit|Goddess of the forest|T
Aaradhya|आराध्या|g|Hindu|Pan-India|Sanskrit|Worshipped; Goddess Lakshmi|T
Aarnav|आर्णव|b|Hindu|Pan-India|Sanskrit|The ocean|T
Aarti|आरती|g|Hindu|West|Sanskrit|A ritual of light in worship|C
Aarzoo|आरज़ू|g|Secular|North|Persian|Wish|C
Aashay|आशय|b|Hindu|West|Sanskrit|Meaning; intention|C
Aashish|आशीष|b|Hindu|Pan-India|Sanskrit|Blessing|C
Aashna|आशना|g|Hindu|North|Persian · Hindi|Beloved; friend|C
Aashutosh|आशुतोष|b|Hindu|Pan-India|Sanskrit|Easily pleased; Lord Shiva|C
Aastha|आस्था|g|Hindu|North|Sanskrit|Faith|C
Aatif|आतिफ़|b|Muslim|Pan-India|Arabic|Compassionate|C
Aayan|आयान|b|Muslim|Pan-India|Arabic|Gift of God|T
Abbas|अब्बास|b|Muslim|Pan-India|Arabic|Lion; stern|C
Abdul|अब्दुल|b|Muslim|Pan-India|Arabic|Servant of God|C
Abdullah|अब्दुल्लाह|b|Muslim|Pan-India|Arabic|Servant of God|C
Abhigyan|अभिज्ञान|b|Hindu|Pan-India|Sanskrit|Recognition; knowledge|R
Abhijeet|अभिजीत|b|Hindu|Pan-India|Sanskrit|Victorious|C
Abhijit|अभिजीत|b|Hindu|East|Sanskrit|Victorious|C
Abhilash|अभिलाष|b|Hindu|South|Sanskrit|Desire; wish|C
Abhilasha|अभिलाषा|g|Hindu|North|Sanskrit|Desire; wish|C
Abhimanyu|अभिमन्यु|b|Hindu|Pan-India|Sanskrit|Son of Arjuna; brave|C
Abhinandan|अभिनंदन|b|Jain|West|Sanskrit|Greeting; the fourth Tirthankara|C
Abhiraj|अभिराज|b|Hindu|North|Sanskrit|Fearless king|C
Abhiram|अभिराम|b|Hindu|South|Sanskrit|Pleasing; delightful|C
Aboli|अबोली|g|Hindu|West|Marathi|A flower; the firecracker flower|C
Abraham|अब्राहम|b|Christian|Pan-India|Hebrew|Father of many nations|C
Achala|अचला|g|Hindu|Pan-India|Sanskrit|Steady; the earth|C
Achyut|अच्युत|b|Hindu|Pan-India|Sanskrit|Imperishable; Lord Vishnu|C
Adam|एडम|b|Christian|Pan-India|Hebrew|Man; of the earth|C
Adarsh|आदर्श|b|Hindu|Pan-India|Sanskrit|Ideal; a model|C
Adeeba|अदीबा|g|Muslim|Pan-India|Arabic|Cultured; well mannered|C
Adeel|अदील|b|Muslim|Pan-India|Arabic|Just; equal|C
Adhira|अधीरा|g|Hindu|South|Sanskrit|Lightning|T
Adhiraj|अधिराज|b|Hindu|North|Sanskrit|King; ruler|T
Adil|आदिल|b|Parsi|West|Persian|Just; fair|C
Adinath|आदिनाथ|b|Hindu|Pan-India|Sanskrit|The first lord|R
Aditee|अदिती|g|Hindu|West|Sanskrit|Boundless|C
Adithya|आदित्य|b|Hindu|South|Sanskrit|The sun|C
Advay|अद्वय|b|Hindu|Pan-India|Sanskrit|One; unique|T
Advita|अद्विता|g|Hindu|Pan-India|Sanskrit|Unique|T
Afnan|अफ़नान|u|Muslim|Pan-India|Arabic|Branches of a tree|T
Afsana|अफ़साना|g|Muslim|North|Persian|A story|C
Aftab|आफ़ताब|b|Muslim|North|Persian|The sun|C
Afzal|अफ़ज़ल|b|Muslim|Pan-India|Arabic|The best; excellent|C
Agampreet|अगमप्रीत|u|Sikh|North|Punjabi · Sanskrit|Love for the unfathomable God|T
Agnes|एग्नेस|g|Christian|South|Greek|Pure; holy|C
Agneya|आग्नेय|b|Hindu|Pan-India|Sanskrit|Born of fire|R
Agni|अग्नि|b|Hindu|Pan-India|Sanskrit|Fire; the fire god|C
Ahalya|अहल्या|g|Hindu|Pan-India|Sanskrit|Wife of the sage Gautama|R
Ahan|अहन|b|Hindu|Pan-India|Sanskrit|Dawn; day|T
Ahilya|अहिल्या|g|Hindu|West|Sanskrit|A queen of Indore; a figure of the Ramayana|C
Ahimsa|अहिंसा|g|Jain|West|Sanskrit|Non violence|R
Ahona|आहोना|g|Hindu|East|Bengali|Dawn; the first rays|T
Aishani|ऐशानी|g|Hindu|Pan-India|Sanskrit|Goddess Durga|T
Aishik|ऐशिक|b|Hindu|East|Bengali · Sanskrit|Divine|T
Ajeet|अजीत|b|Sikh|North|Punjabi · Sanskrit|Unconquerable|C
Ajinkya|अजिंक्य|b|Hindu|West|Sanskrit|Invincible|C
Ajit|अजित|b|Hindu|Pan-India|Sanskrit|Unconquered|C
Ajith|अजित|b|Hindu|South|Sanskrit|Unconquered|C
Ajitnath|अजितनाथ|b|Jain|West|Sanskrit|The second Tirthankara; unconquered lord|R
Ajooni|अजूनी|g|Sikh|North|Punjabi|Beyond birth; God|T
Akash|आकाश|b|Hindu|Pan-India|Sanskrit|Sky|C
Akbar|अकबर|b|Muslim|North|Arabic|Great|C
Akhil|अखिल|b|Hindu|Pan-India|Sanskrit|Complete; whole|C
Akhila|अखिला|g|Hindu|South|Sanskrit|Complete; whole|C
Akhilesh|अखिलेश|b|Hindu|North|Sanskrit|Lord of all|C
Akram|अकरम|b|Muslim|Pan-India|Arabic|Most generous|C
Akriti|आकृति|g|Hindu|North|Sanskrit|Shape|C
Akshat|अक्षत|b|Hindu|Pan-India|Sanskrit|Unbroken; whole rice used in worship|C
Akshit|अक्षित|b|Hindu|Pan-India|Sanskrit|Permanent; indestructible|C
Akshita|अक्षिता|g|Hindu|Pan-India|Sanskrit|Imperishable|T
Alakh|अलख|b|Hindu|North|Sanskrit|Invisible; God beyond sight|R
Alaknanda|अलकनंदा|g|Hindu|North|Sanskrit|A Himalayan river|R
Alankar|अलंकार|b|Hindu|Pan-India|Sanskrit|Ornament|R
Albert|अल्बर्ट|b|Christian|Pan-India|English|Noble and bright|C
Aleena|अलीना|g|Muslim|South|Arabic|Noble; soft|T
Alex|एलेक्स|b|Christian|Pan-India|Greek|Defender|C
Alexander|अलेक्ज़ेंडर|b|Christian|Pan-India|Greek|Defender of people|C
Ali|अली|b|Muslim|Pan-India|Arabic|High; exalted|C
Alice|एलिस|g|Christian|Pan-India|English|Noble|C
Alka|अलका|g|Hindu|North|Sanskrit|A curl of hair; the city of Kubera|C
Almas|अलमास|g|Muslim|North|Persian|Diamond|C
Alpa|अल्पा|g|Hindu|West|Sanskrit|Little; small|C
Altaf|अल्ताफ़|b|Muslim|Pan-India|Arabic|Kindness; grace|C
Amanpreet|अमनप्रीत|u|Sikh|North|Punjabi · Sanskrit|Love for peace|C
Amarjeet|अमरजीत|b|Sikh|North|Punjabi · Sanskrit|Eternal victory|C
Amartya|अमर्त्य|b|Hindu|East|Sanskrit|Immortal|R
Amay|अमय|b|Hindu|West|Sanskrit|Without illusion|T
Ambar|अम्बर|b|Hindu|North|Sanskrit|The sky|C
Ambuj|अम्बुज|b|Hindu|North|Sanskrit|Lotus|C
Ambujam|अम्बुजम|g|Hindu|South|Sanskrit|Lotus|R
Ameen|अमीन|b|Muslim|South|Arabic|Trustworthy|C
Ameera|अमीरा|g|Muslim|Pan-India|Arabic|Princess; leader|T
Amelia|अमेलिया|g|Christian|Pan-India|Latin|Industrious; hard working|T
Ameya|अमेय|b|Hindu|West|Sanskrit|Immeasurable; boundless|C
Amina|आमिना|g|Muslim|Pan-India|Arabic|Trustworthy; mother of the Prophet|C
Amir|अमीर|b|Muslim|Pan-India|Arabic|Prince; commander|C
Amitava|अमिताभ|b|Hindu|East|Sanskrit|Boundless splendour|C
Amodini|आमोदिनी|g|Hindu|Pan-India|Sanskrit|Joyful|R
Amogh|अमोघ|b|Hindu|West|Sanskrit|Unfailing|R
Amogha|अमोघा|g|Hindu|Pan-India|Sanskrit|Unfailing|R
Amol|अमोल|b|Hindu|West|Sanskrit|Priceless|C
Amrapali|आम्रपाली|g|Buddhist|East|Sanskrit|A follower of the Buddha in Vaishali|R
Amrinder|अमरिंदर|b|Sikh|North|Punjabi · Sanskrit|Eternal god of heaven|C
Amritleen|अमृतलीन|g|Sikh|North|Punjabi · Sanskrit|Absorbed in nectar|T
Amritpal|अमृतपाल|b|Sikh|North|Punjabi · Sanskrit|Protector of nectar|C
Amruta|अमृता|g|Hindu|West|Sanskrit|Nectar|C
Anahat|अनाहत|b|Hindu|Pan-India|Sanskrit|The unstruck sound; the heart chakra|R
Anam|अनम|g|Muslim|Pan-India|Arabic|Blessing; God's creation|C
Anamika|अनामिका|g|Hindu|Pan-India|Sanskrit|Nameless; the ring finger|C
Ananda|आनंद|b|Buddhist|Pan-India|Pali|Bliss; the Buddha's companion|C
Anandi|आनंदी|g|Hindu|West|Sanskrit|Joyful|C
Anandita|आनंदिता|g|Hindu|Pan-India|Sanskrit|Joyful|C
Anant|अनंत|b|Hindu|Pan-India|Sanskrit|Endless; infinite|C
Ananth|अनंत|b|Hindu|South|Sanskrit|Endless|C
Anas|अनस|b|Muslim|Pan-India|Arabic|Friendliness; affection|C
Anbarasu|अन्बरसु|b|Hindu|South|Tamil|King of love|R
Anbu|अन्बु|u|Hindu|South|Tamil|Love|C
Andrew|एंड्रयू|b|Christian|Pan-India|Greek|Strong; manly|C
Anees|अनीस|b|Muslim|Pan-India|Arabic|Close friend; companion|C
Aneesh|अनीश|b|Hindu|Pan-India|Sanskrit|Supreme; without a master|C
Anekant|अनेकांत|b|Jain|West|Sanskrit|Many sided truth|R
Angel|एंजेल|u|Christian|Pan-India|Greek|Messenger of God|T
Angira|अंगिरा|b|Hindu|Pan-India|Sanskrit|A Vedic sage|R
Anhad|अनहद|b|Sikh|North|Punjabi|The unstruck celestial sound|T
Animesh|अनिमेष|b|Hindu|Pan-India|Sanskrit|Unblinking; watchful|C
Anindita|अनिंदिता|g|Hindu|East|Sanskrit|Flawless; beyond reproach|C
Anirvan|अनिर्वाण|b|Hindu|East|Sanskrit|Undying; ever bright|R
Anisa|अनीसा|g|Muslim|Pan-India|Arabic|Friendly; companion|C
Anisha|अनीशा|g|Hindu|Pan-India|Sanskrit|Unbroken; continuous|C
Anita|अनीता|g|Christian|Pan-India|Hebrew · Sanskrit|Grace|C
Anjan|अंजन|b|Hindu|East|Sanskrit|Kohl; a mountain|C
Anjana|अंजना|g|Hindu|Pan-India|Sanskrit|Mother of Hanuman|C
Anjaneya|आंजनेय|b|Hindu|South|Sanskrit|Lord Hanuman, son of Anjana|C
Ankita|अंकिता|g|Hindu|Pan-India|Sanskrit|Marked; distinguished|C
Ankur|अंकुर|b|Hindu|North|Sanskrit|A sprout; a new shoot|C
Anmol|अनमोल|b|Hindu|North|Hindi|Priceless|C
Annamma|अन्नम्मा|g|Christian|South|Hebrew · Malayalam|Mother Anna|C
Annapurna|अन्नपूर्णा|g|Hindu|Pan-India|Sanskrit|Goddess of food|C
Annie|ऐनी|g|Christian|Pan-India|Hebrew|Grace|C
Anoop|अनूप|b|Hindu|South|Sanskrit|Unequalled|C
Anshika|अंशिका|g|Hindu|North|Sanskrit|A small part|T
Anshul|अंशुल|b|Hindu|North|Sanskrit|Radiant; sunny|C
Anshuman|अंशुमान|b|Hindu|Pan-India|Sanskrit|The sun; radiant|C
Antara|अंतरा|g|Hindu|East|Sanskrit|The inner self; a part of a song|C
Anthony|एंथनी|b|Christian|Pan-India|Latin|Priceless; worthy of praise|C
Antony|एंटनी|b|Christian|South|Latin|Priceless|C
Antriksh|अंतरिक्ष|b|Hindu|North|Sanskrit|Space; the sky|T
Anuj|अनुज|b|Hindu|Pan-India|Sanskrit|Younger brother|C
Anuja|अनुजा|g|Hindu|West|Sanskrit|Younger sister|C
Anupam|अनुपम|b|Hindu|Pan-India|Sanskrit|Incomparable|C
Anupama|अनुपमा|g|Hindu|Pan-India|Sanskrit|Matchless|C
Anuradha|अनुराधा|g|Hindu|Pan-India|Sanskrit|A star|C
Anurag|अनुराग|b|Hindu|Pan-India|Sanskrit|Love; affection|C
Anushree|अनुश्री|g|Hindu|West|Sanskrit|Goddess Lakshmi; pretty|C
Anusree|अनुश्री|g|Hindu|South|Sanskrit|Goddess Lakshmi; pretty|C
Anvita|अन्विता|g|Hindu|Pan-India|Sanskrit|One who connects|T
Aparajita|अपराजिता|g|Hindu|East|Sanskrit|Undefeated; a blue flower|C
Aparna|अपर्णा|g|Hindu|Pan-India|Sanskrit|Goddess Parvati|C
Apeksha|अपेक्षा|g|Hindu|Pan-India|Sanskrit|Expectation; hope|C
Apurva|अपूर्व|u|Hindu|Pan-India|Sanskrit|Unique; never before|C
Aqib|आक़िब|b|Muslim|Pan-India|Arabic|Follower; successor|C
Aqsa|अक़्सा|g|Muslim|Pan-India|Arabic|The farthest; the mosque in Jerusalem|C
Aradhana|आराधना|g|Hindu|Pan-India|Sanskrit|Worship|C
Arav|आरव|b|Hindu|Pan-India|Sanskrit|Peaceful|T
Archana|अर्चना|g|Hindu|Pan-India|Sanskrit|Worship|C
Archit|अर्चित|b|Hindu|Pan-India|Sanskrit|Worshipped|C
Ardeshir|अर्देशिर|b|Parsi|West|Persian|A just ruler|C
Areeb|अरीब|b|Muslim|Pan-India|Arabic|Wise; intelligent|T
Areesha|अरीशा|g|Muslim|Pan-India|Arabic|Throne; canopy|T
Arif|आरिफ़|b|Muslim|Pan-India|Arabic|Knowing; wise|C
Arihant|अरिहंत|b|Hindu|West|Sanskrit|Destroyer of inner enemies|C
Arindam|अरिंदम|b|Hindu|East|Sanskrit|Subduer of enemies|C
Aritra|अरित्र|b|Hindu|East|Sanskrit|One who steers; a rudder|C
Arivu|अरिवु|b|Hindu|South|Tamil|Knowledge; wisdom|R
Arka|अर्क|b|Hindu|East|Sanskrit|The sun|C
Arnesh|अर्णेश|b|Hindu|Pan-India|Sanskrit|Lord of the sea|R
Arohi|आरोही|g|Hindu|West|Sanskrit|Ascending notes of music|T
Aron|एरन|b|Christian|South|Hebrew|Exalted; mountain of strength|C
Arsalan|अरसलान|b|Muslim|North|Persian|Lion|T
Arshad|अरशद|b|Muslim|Pan-India|Arabic|Most rightly guided|C
Arshleen|अर्शलीन|g|Sikh|North|Punjabi · Persian|Absorbed in heaven|T
Arul|अरुल|b|Hindu|South|Tamil|Grace; blessing|C
Arulmozhi|अरुलमोझी|u|Hindu|South|Tamil|Words of grace|R
Arun|अरुण|b|Hindu|Pan-India|Sanskrit|Dawn; the charioteer of the sun|C
Aruna|अरुणा|g|Hindu|Pan-India|Sanskrit|Dawn|C
Arunima|अरुणिमा|g|Hindu|East|Sanskrit|The glow of dawn|C
Arush|आरुष|b|Hindu|Pan-India|Sanskrit|First ray of the sun|T
Aryaman|अर्यमन|b|Hindu|Pan-India|Sanskrit|A Vedic god of friendship|R
Arzoo|आरज़ू|g|Muslim|North|Persian|Wish; desire|C
Asad|असद|b|Muslim|Pan-India|Arabic|Lion|C
Ashok|अशोक|b|Hindu|Pan-India|Sanskrit|Without sorrow|C
Ashoka|अशोक|b|Buddhist|Pan-India|Sanskrit|Without sorrow; the great emperor|C
Ashwini|अश्विनी|g|Hindu|West|Sanskrit|The first star|C
Asif|आसिफ़|b|Muslim|Pan-India|Arabic|Forgiveness|C
Asiya|आसिया|g|Muslim|Pan-India|Arabic|One who tends the weak; wife of Pharaoh|C
Asma|अस्मा|g|Muslim|Pan-India|Arabic|Excellent; lofty|C
Asmita|अस्मिता|g|Hindu|Pan-India|Sanskrit|Self respect; pride|C
Aswathy|अश्वती|g|Hindu|South|Malayalam|The star Ashwini|C
Atharva|अथर्व|b|Hindu|West|Sanskrit|The fourth Veda|T
Athira|आतिरा|g|Hindu|South|Malayalam|The star Ardra|C
Atiya|अतिया|g|Muslim|Pan-India|Arabic|Gift|C
Atul|अतुल|b|Hindu|Pan-India|Sanskrit|Matchless|C
Atulya|अतुल्य|b|Hindu|Pan-India|Sanskrit|Incomparable|T
Augustine|ऑगस्टीन|b|Christian|South|Latin|Venerable; great|C
Avantika|अवंतिका|g|Hindu|Pan-India|Sanskrit|An old name of the city Ujjain|C
Avik|अविक|b|Hindu|East|Sanskrit|A diamond; brave|C
Avika|अविका|g|Hindu|Pan-India|Sanskrit|The earth|T
Avinash|अविनाश|b|Hindu|Pan-India|Sanskrit|Indestructible|C
Avneet|अवनीत|g|Sikh|North|Punjabi|Humble; modest|C
Avyan|अव्यान|b|Hindu|Pan-India|Sanskrit|One without flaws|T
Avyukt|अव्युक्त|b|Hindu|Pan-India|Sanskrit|Clear; transparent|R
Ayaz|अयाज़|b|Muslim|North|Persian|A cool breeze|C
Ayushman|आयुष्मान|b|Hindu|North|Sanskrit|Blessed with long life|T
Azhar|अज़हर|b|Muslim|Pan-India|Arabic|Bright; shining|C
Aziz|अज़ीज़|b|Muslim|Pan-India|Arabic|Dear; beloved|C
Azlan|अज़लान|b|Muslim|Pan-India|Arabic|Lion|T
Bahman|बहमन|b|Parsi|West|Persian|Good mind|C
Baljeet|बलजीत|b|Sikh|North|Punjabi · Sanskrit|Victory of strength|C
Balpreet|बलप्रीत|u|Sikh|North|Punjabi · Sanskrit|Strength of love|C
Balram|बलराम|b|Hindu|Pan-India|Sanskrit|Elder brother of Krishna|C
Balwinder|बलविंदर|b|Sikh|North|Punjabi · Sanskrit|Strong like a god|C
Bani|बानी|g|Sikh|North|Punjabi|The Guru's word|T
Bano|बानो|g|Muslim|North|Persian|Lady; princess|C
Barinder|बरिंदर|b|Sikh|North|Punjabi · Sanskrit|Lord of the brave|C
Barsha|बर्षा|g|Hindu|East|Bengali · Sanskrit|Rain|C
Basheer|बशीर|b|Muslim|Pan-India|Arabic|Bearer of good news|C
Beatrice|बिएट्रिस|g|Christian|South|Latin|She who brings happiness|R
Behram|बहराम|b|Parsi|West|Persian|Victorious; Mars|C
Benazir|बेनज़ीर|g|Muslim|North|Persian|Matchless|C
Benedict|बेनेडिक्ट|b|Christian|South|Latin|Blessed|C
Benny|बेनी|b|Christian|South|Hebrew|Blessed; son of the right hand|C
Bernard|बर्नार्ड|b|Christian|South|English|Brave as a bear|C
Bhabani|भवानी|g|Hindu|East|Sanskrit|Goddess Parvati|C
Bhagat|भगत|b|Sikh|North|Punjabi|Devotee|C
Bhagyashree|भाग्यश्री|g|Hindu|West|Sanskrit|Good fortune; Goddess Lakshmi|C
Bhairavi|भैरवी|g|Hindu|Pan-India|Sanskrit|A raga; Goddess Durga|C
Bhakti|भक्ति|g|Hindu|West|Sanskrit|Devotion|C
Bhanu|भानु|b|Hindu|Pan-India|Sanskrit|The sun|C
Bharat|भरत|b|Hindu|Pan-India|Sanskrit|India; brother of Rama|C
Bharathi|भारती|g|Hindu|South|Sanskrit|Goddess Saraswati|C
Bhargav|भार्गव|b|Hindu|South|Sanskrit|Lord Shiva; descendant of Bhrigu|C
Bhaskar|भास्कर|b|Hindu|Pan-India|Sanskrit|The sun|C
Bhavana|भावना|g|Hindu|South|Sanskrit|Feeling; meditation|C
Bhavik|भाविक|b|Hindu|West|Sanskrit|Devoted; sentimental|C
Bhavika|भाविका|g|Hindu|West|Sanskrit|Full of feeling|C
Bhavin|भाविन|b|Hindu|West|Gujarati · Sanskrit|Living; full of feeling|C
Bhoomika|भूमिका|g|Hindu|Pan-India|Sanskrit|The earth; a role|C
Bhrigu|भृगु|b|Hindu|Pan-India|Sanskrit|A Vedic sage|R
Bhumi|भूमि|g|Hindu|West|Sanskrit|The earth|C
Bhupen|भूपेन|b|Hindu|East|Sanskrit|King; lord of the earth|C
Bhupinder|भूपिंदर|b|Sikh|North|Punjabi · Sanskrit|King of kings|C
Bhushan|भूषण|b|Hindu|West|Sanskrit|Ornament|C
Bianca|बियांका|g|Christian|West|Italian|White|C
Bidisha|बिदिशा|g|Hindu|East|Bengali|An old city of central India|C
Bijoy|बिजय|b|Hindu|East|Bengali · Sanskrit|Victory|C
Bijoya|बिजया|g|Hindu|East|Bengali · Sanskrit|Victory; the last day of Durga Puja|C
Bipasha|बिपाशा|g|Hindu|East|Sanskrit|A river|C
Bipin|बिपिन|b|Hindu|East|Sanskrit|A forest|C
Biswajit|बिस्वजीत|b|Hindu|East|Bengali · Sanskrit|Conqueror of the world|C
Blessy|ब्लेसी|g|Christian|South|English|Blessed|T
Bornali|बर्णाली|g|Hindu|East|Bengali|Colourful|C
Brijesh|बृजेश|b|Hindu|North|Sanskrit|Lord of Braj; Krishna|C
Brishti|बृष्टि|g|Hindu|East|Bengali|Rain|C
Bushra|बुशरा|g|Muslim|Pan-India|Arabic|Good news|C
Carmel|कार्मेल|g|Christian|South|Hebrew|Garden; vineyard|C
Caroline|कैरोलिन|g|Christian|Pan-India|Latin|Free woman|C
Cecilia|सेसिलिया|g|Christian|South|Latin|Patron saint of music|C
Celine|सेलीन|g|Christian|Pan-India|Latin|Heavenly|C
Chacko|चाको|b|Christian|South|Hebrew · Malayalam|Jacob|C
Chaitali|चैताली|g|Hindu|East|Bengali · Sanskrit|Born in the month of Chaitra|C
Chaithra|चैत्रा|g|Hindu|South|Sanskrit|The first month of the year; spring|C
Chaitra|चैत्र|b|Hindu|Pan-India|Sanskrit|The first month of the Hindu year|C
Chakor|चकोर|b|Hindu|North|Sanskrit|A bird said to drink moonlight|R
Chanchal|चंचल|u|Hindu|North|Sanskrit|Playful; restless|C
Chandan|चंदन|b|Hindu|Pan-India|Sanskrit|Sandalwood|C
Chandana|चंदना|g|Hindu|South|Sanskrit|Sandalwood|C
Chandrakant|चंद्रकांत|b|Hindu|West|Sanskrit|Beloved of the moon; moonstone|C
Chandrika|चंद्रिका|g|Hindu|South|Sanskrit|Moonlight|C
Chandrima|चंद्रिमा|g|Hindu|East|Sanskrit|The moon|C
Charanjeet|चरणजीत|u|Sikh|North|Punjabi · Sanskrit|Victory at the feet of the Guru|C
Charles|चार्ल्स|b|Christian|Pan-India|English|Free man|C
Chellam|चेल्लम|g|Hindu|South|Tamil|Darling; dear one|C
Chetna|चेतना|g|Hindu|Pan-India|Sanskrit|Consciousness|C
Chhavi|छवि|g|Hindu|North|Sanskrit|Image; reflection|C
Chintan|चिंतन|b|Hindu|West|Sanskrit|Contemplation|C
Chiranjeev|चिरंजीव|b|Hindu|North|Sanskrit|Long-lived|C
Chiranjeevi|चिरंजीवी|b|Hindu|South|Sanskrit|Immortal; long-lived|C
Chirayu|चिरायु|b|Hindu|West|Sanskrit|Long life|C
Chitra|चित्रा|g|Hindu|Pan-India|Sanskrit|Picture; a star|C
Christina|क्रिस्टीना|g|Christian|Pan-India|Greek|Follower of Christ|C
Christy|क्रिस्टी|u|Christian|South|Greek|Follower of Christ|C
Clement|क्लेमेंट|b|Christian|South|Latin|Merciful; gentle|C
Cynthia|सिंथिया|g|Christian|Pan-India|Greek|The moon|C
Cyrus|साइरस|b|Parsi|West|Persian|Sun; a great king|C
Daisy|डेज़ी|g|Christian|Pan-India|English|A daisy flower|C
Daivik|दैविक|b|Hindu|Pan-India|Sanskrit|Divine|T
Dakshesh|दक्षेश|b|Hindu|Pan-India|Sanskrit|Lord Shiva|R
Daljeet|दलजीत|b|Sikh|North|Punjabi · Sanskrit|Victorious over the army|C
Damini|दामिनी|g|Hindu|North|Sanskrit|Lightning|C
Damodar|दामोदर|b|Hindu|Pan-India|Sanskrit|Krishna, bound by a rope at the waist|C
Darius|डेरियस|b|Parsi|West|Persian|One who holds firm to good|C
Darpan|दर्पण|b|Hindu|Pan-India|Sanskrit|Mirror|R
Darshan|दर्शन|b|Hindu|South|Sanskrit|Sight of the divine|C
Darshit|दर्शित|b|Hindu|West|Sanskrit|Shown; displayed|C
Davinder|दविंदर|b|Sikh|North|Punjabi · Sanskrit|Lord of the gods|C
Dawa|दावा|u|Buddhist|North|Tibetan|The moon; born on a Monday|C
Debashish|देबाशीष|b|Hindu|East|Bengali · Sanskrit|Blessing of the gods|C
Debasmita|देबस्मिता|g|Hindu|East|Bengali · Sanskrit|Smile of the gods|C
Debjani|देबजानी|g|Hindu|East|Bengali · Sanskrit|Known by the gods|C
Deborah|डेबोरा|g|Christian|Pan-India|Hebrew|Bee|C
Deeksha|दीक्षा|g|Hindu|Pan-India|Sanskrit|Initiation|C
Deepali|दीपाली|g|Hindu|West|Sanskrit|A row of lamps|C
Deepesh|दीपेश|b|Hindu|North|Sanskrit|Lord of light|C
Dennis|डेनिस|b|Christian|Pan-India|Greek|Follower of Dionysus|C
Devananda|देवानंदा|g|Hindu|South|Sanskrit|Joy of the gods|T
Devanshi|देवांशी|g|Hindu|Pan-India|Sanskrit|A part of the divine|T
Devarsh|देवर्ष|b|Hindu|Pan-India|Sanskrit|Sage among the gods|T
Devashree|देवश्री|g|Hindu|West|Sanskrit|Divine Lakshmi|C
Deven|देवेन|b|Hindu|West|Sanskrit|Like a god|C
Devendra|देवेंद्र|b|Hindu|North|Sanskrit|King of the gods; Indra|C
Devesh|देवेश|b|Hindu|North|Sanskrit|Lord of the gods|C
Devyani|देवयानी|g|Hindu|West|Sanskrit|Daughter of Shukracharya|C
Dhairya|धैर्य|b|Hindu|West|Sanskrit|Patience; courage|T
Dhanashree|धनश्री|g|Hindu|West|Sanskrit|Goddess of wealth; a raga|C
Dhanraj|धनराज|b|Hindu|North|Sanskrit|Lord of wealth|C
Dhanvi|धन्वी|g|Hindu|West|Sanskrit|Wealthy; Goddess Lakshmi|T
Dhanvin|धन्विन|b|Hindu|Pan-India|Sanskrit|Archer; Lord Shiva|R
Dhanya|धन्या|g|Hindu|South|Sanskrit|Blessed; grateful|C
Dhara|धारा|g|Hindu|West|Sanskrit|A stream; the earth|C
Dharini|धारिणी|g|Hindu|Pan-India|Sanskrit|The earth|C
Dharmesh|धर्मेश|b|Hindu|West|Sanskrit|Lord of righteousness|C
Dharmik|धार्मिक|b|Hindu|West|Sanskrit|Religious; righteous|C
Dhaval|धवल|b|Hindu|West|Sanskrit|White; pure|C
Dheeraj|धीरज|b|Hindu|Pan-India|Sanskrit|Patience|C
Dhruvi|ध्रुवी|g|Hindu|West|Sanskrit|Firm; steady|T
Dhruvil|ध्रुविल|b|Hindu|West|Sanskrit|Steady like the pole star|T
Dhvani|ध्वनि|g|Hindu|West|Sanskrit|Sound|C
Diana|डायना|g|Christian|Pan-India|Latin|Divine; heavenly|C
Dibyendu|दिब्येंदु|b|Hindu|East|Bengali · Sanskrit|Divine moon|C
Digvijay|दिग्विजय|b|Hindu|North|Sanskrit|Conqueror of all directions|C
Diksha|दीक्षा|g|Hindu|North|Sanskrit|Initiation|C
Dikshit|दीक्षित|b|Hindu|North|Sanskrit|Initiated|C
Dilraj|दिलराज|b|Sikh|North|Punjabi · Persian|King of hearts|C
Dilshad|दिलशाद|u|Muslim|North|Persian|Happy hearted|C
Dinesh|दिनेश|b|Hindu|Pan-India|Sanskrit|The sun; lord of the day|C
Dipankar|दीपंकर|b|Hindu|East|Sanskrit|One who lights the lamp|C
Dipanwita|दीपान्विता|g|Hindu|East|Bengali · Sanskrit|Lit with lamps|C
Dipika|दीपिका|g|Hindu|East|Sanskrit|A little lamp|C
Divakar|दिवाकर|b|Hindu|South|Sanskrit|The sun|C
Divija|दिविजा|g|Hindu|Pan-India|Sanskrit|Born in heaven|R
Divisha|दिविशा|g|Hindu|Pan-India|Sanskrit|Goddess; queen of the gods|T
Divyam|दिव्यम|b|Hindu|Pan-India|Sanskrit|Divine; brilliant|T
Divyansh|दिव्यांश|b|Hindu|North|Sanskrit|A divine part|T
Divyesh|दिव्येश|b|Hindu|West|Sanskrit|Divine lord; the sun|C
Dolma|डोल्मा|g|Buddhist|North|Tibetan|Tara, the saviour goddess|C
Dominic|डोमिनिक|b|Christian|West|Latin|Belonging to the Lord|C
Dorje|दोरजे|b|Buddhist|North|Tibetan|Thunderbolt; diamond|C
Dorothy|डोरोथी|g|Christian|Pan-India|Greek|Gift of God|C
Drishti|दृष्टि|g|Hindu|North|Sanskrit|Sight; vision|C
Dua|दुआ|g|Muslim|Pan-India|Arabic|Prayer|T
Durba|दूर्बा|g|Hindu|East|Bengali|Sacred grass|C
Durga|दुर्गा|g|Hindu|Pan-India|Sanskrit|Goddess Durga; invincible|C
Edwin|एडविन|b|Christian|South|English|Rich friend|C
Ehsan|एहसान|b|Muslim|Pan-India|Arabic|Kindness; good deeds|C
Ekagra|एकाग्र|b|Hindu|Pan-India|Sanskrit|Focused|R
Ekamjot|एकमजोत|u|Sikh|North|Punjabi|Light of the one God|T
Ekjot|एकजोत|u|Sikh|North|Punjabi|One light|T
Eklavya|एकलव्य|b|Hindu|Pan-India|Sanskrit|The devoted archer of the Mahabharata|R
Ekta|एकता|g|Hindu|North|Sanskrit|Unity|C
Elakkiya|इलक्किया|g|Hindu|South|Tamil|Literature|R
Elango|इलंगो|b|Hindu|South|Tamil|Young prince; the poet of Silappatikaram|R
Elijah|एलाइजा|b|Christian|Pan-India|Hebrew|My God is the Lord|T
Elisa|एलिसा|g|Christian|Pan-India|Hebrew|Pledged to God|T
Elsa|एल्सा|g|Christian|South|Hebrew|Pledged to God|C
Emily|एमिली|g|Christian|Pan-India|Latin|Industrious|C
Esha|ईशा|g|Hindu|Pan-India|Sanskrit|Desire; purity|C
Eshal|ईशाल|g|Muslim|Pan-India|Arabic|A flower of paradise|T
Eshana|एषणा|g|Hindu|Pan-India|Sanskrit|Desire; search|R
Ethan|ईथन|b|Christian|Pan-India|Hebrew|Strong; firm|T
Eugene|यूजीन|b|Christian|South|Greek|Well born; noble|C
Ezhil|एझिल|u|Hindu|South|Tamil|Beauty|T
Ezra|एज़्रा|b|Christian|Pan-India|Hebrew|Help|T
Fahad|फ़हद|b|Muslim|Pan-India|Arabic|Leopard|C
Faisal|फ़ैसल|b|Muslim|Pan-India|Arabic|Decisive; judge|C
Faiza|फ़ाइज़ा|g|Muslim|Pan-India|Arabic|Victorious|C
Falguni|फाल्गुनी|g|Hindu|West|Sanskrit|Born in the month of Phalgun|C
Farah|फ़रह|g|Muslim|Pan-India|Arabic|Joy; happiness|C
Faraz|फ़राज़|b|Muslim|North|Persian|Height; elevation|C
Fareed|फ़रीद|b|Muslim|Pan-India|Arabic|Unique; matchless|C
Farida|फ़रीदा|g|Muslim|Pan-India|Arabic|Unique; a precious pearl|C
Fariha|फ़रीहा|g|Muslim|Pan-India|Arabic|Happy; joyful|C
Farokh|फ़रोख़|b|Parsi|West|Persian|Happy; fortunate|C
Farzana|फ़रज़ाना|g|Muslim|North|Persian|Wise; intelligent|C
Fatehjeet|फ़तेहजीत|b|Sikh|North|Punjabi · Persian|Victory upon victory|T
Fathima|फ़ातिमा|g|Muslim|South|Arabic|Daughter of the Prophet|C
Felix|फ़ेलिक्स|b|Christian|Pan-India|Latin|Happy; lucky|C
Feroz|फ़िरोज़|b|Muslim|North|Persian|Victorious; turquoise|C
Feroze|फ़िरोज़|b|Parsi|West|Persian|Victorious; turquoise|C
Fiona|फ़ियोना|g|Christian|Pan-India|Celtic|Fair; white|C
Firdaus|फ़िरदौस|g|Muslim|North|Persian|Paradise|C
Fiza|फ़िज़ा|g|Muslim|North|Arabic|Breeze; nature|C
Flora|फ़्लोरा|g|Christian|West|Latin|Flower|C
Florence|फ़्लोरेंस|g|Christian|South|Latin|Blooming; flourishing|C
Foram|फोरम|g|Hindu|West|Gujarati|Fragrance|C
Francis|फ़्रांसिस|b|Christian|Pan-India|Latin|Free man; the saint of Assisi|C
Gagan|गगन|b|Hindu|North|Sanskrit|The sky|C
Gagandeep|गगनदीप|b|Sikh|North|Punjabi · Sanskrit|Lamp of the sky|C
Ganesh|गणेश|b|Hindu|Pan-India|Sanskrit|Lord Ganesha; lord of the ganas|C
Ganga|गंगा|g|Hindu|Pan-India|Sanskrit|The holy river Ganga|C
Garima|गरिमा|g|Hindu|North|Sanskrit|Dignity; grace|C
Gaurang|गौरांग|b|Hindu|East|Sanskrit|Fair bodied; Chaitanya Mahaprabhu|C
Gaurangi|गौरांगी|g|Hindu|East|Sanskrit|Fair bodied|C
Gauravi|गौरवी|g|Hindu|West|Sanskrit|Pride; honour|R
Gautami|गौतमी|g|Buddhist|Pan-India|Sanskrit|The Buddha's foster mother|C
Gautham|गौतम|b|Hindu|South|Sanskrit|The Buddha; a sage|C
Gayathri|गायत्री|g|Hindu|South|Sanskrit|A Vedic hymn|C
Geeta|गीता|g|Hindu|Pan-India|Sanskrit|Song; the holy book|C
George|जॉर्ज|b|Christian|Pan-India|Greek|Farmer|C
Ghazal|ग़ज़ल|g|Muslim|North|Arabic|A poem of love|C
Ghazala|ग़ज़ाला|g|Muslim|North|Arabic|A young deer|C
Girdhar|गिरधर|b|Hindu|North|Sanskrit|One who held the mountain; Krishna|C
Girija|गिरिजा|g|Hindu|South|Sanskrit|Daughter of the mountain; Parvati|C
Gitanjali|गीतांजलि|g|Hindu|East|Sanskrit|An offering of songs|C
Gloria|ग्लोरिया|g|Christian|Pan-India|Latin|Glory|C
Gokul|गोकुल|b|Hindu|South|Sanskrit|The village of Krishna's childhood|C
Gopika|गोपिका|g|Hindu|South|Sanskrit|A cowherd girl devoted to Krishna|C
Govind|गोविंद|b|Hindu|Pan-India|Sanskrit|Protector of cows; Krishna|C
Gracy|ग्रेसी|g|Christian|South|Latin|Grace|C
Gregory|ग्रेगरी|b|Christian|South|Greek|Watchful; alert|C
Guhan|गुहन|b|Hindu|South|Sanskrit|Lord Murugan|C
Gulnaz|गुलनाज़|g|Muslim|North|Persian|Delicate as a flower|C
Gulzar|गुलज़ार|b|Muslim|North|Persian|A garden of roses|C
Gunjan|गुंजन|u|Hindu|Pan-India|Sanskrit|The humming of a bee|C
Gunjita|गुंजिता|g|Hindu|Pan-India|Sanskrit|The humming of bees|R
Gurbaaz|गुरबाज़|b|Sikh|North|Punjabi · Persian|Falcon of the Guru|T
Gurdeep|गुरदीप|b|Sikh|North|Punjabi · Sanskrit|Lamp of the Guru|C
Gurjas|गुरजस|b|Sikh|North|Punjabi|Praise of the Guru|T
Gurjot|गुरजोत|u|Sikh|North|Punjabi|Light of the Guru|C
Gurkiran|गुरकिरण|g|Sikh|North|Punjabi · Sanskrit|Ray of light of the Guru|C
Gurkirat|गुरकीरत|u|Sikh|North|Punjabi|Praise of the Guru|C
Gurman|गुरमन|u|Sikh|North|Punjabi|Heart of the Guru|C
Gurmeet|गुरमीत|u|Sikh|North|Punjabi|Friend of the Guru|C
Gurnam|गुरनाम|b|Sikh|North|Punjabi|Name of the Guru|C
Gursehaj|गुरसहज|b|Sikh|North|Punjabi|Calm of the Guru|T
Gursimran|गुरसिमरन|u|Sikh|North|Punjabi|Remembrance of the Guru|C
Gurvinder|गुरविंदर|b|Sikh|North|Punjabi · Sanskrit|Lord of the Guru's people|C
Gyan|ज्ञान|b|Hindu|North|Sanskrit|Knowledge|C
Habib|हबीब|b|Muslim|Pan-India|Arabic|Beloved|C
Hadi|हादी|b|Muslim|Pan-India|Arabic|Guide; leader|T
Hafeez|हफ़ीज़|b|Muslim|Pan-India|Arabic|Protector; guardian|C
Hafiza|हाफ़िज़ा|g|Muslim|Pan-India|Arabic|Guardian; one who knows the Quran by heart|C
Hafsa|हफ़्सा|g|Muslim|Pan-India|Arabic|Young lioness; a wife of the Prophet|C
Haider|हैदर|b|Muslim|Pan-India|Arabic|Lion; a title of Ali|C
Hamid|हामिद|b|Muslim|Pan-India|Arabic|Praising; thankful|C
Hamsa|हंसा|g|Hindu|South|Sanskrit|Swan|C
Hamsini|हंसिनी|g|Hindu|South|Sanskrit|One who rides a swan; Saraswati|T
Hana|हना|g|Muslim|Pan-India|Arabic|Happiness; bliss|T
Hansa|हंसा|g|Hindu|West|Sanskrit|Swan|C
Hansika|हंसिका|g|Hindu|Pan-India|Sanskrit|A swan|C
Harbhajan|हरभजन|b|Sikh|North|Punjabi · Sanskrit|Hymns of God|C
Hardik|हार्दिक|b|Hindu|West|Sanskrit|Heartfelt|C
Hareem|हरीम|g|Muslim|Pan-India|Arabic|Sacred; holy|T
Hargun|हरगुन|u|Sikh|North|Punjabi|Virtues of God|T
Harika|हारिका|g|Hindu|South|Sanskrit|Goddess Lakshmi|C
Haripriya|हरिप्रिया|g|Hindu|Pan-India|Sanskrit|Beloved of Vishnu; Lakshmi|C
Haris|हारिस|b|Muslim|Pan-India|Arabic|Guardian; farmer|C
Harjeet|हरजीत|b|Sikh|North|Punjabi · Sanskrit|Victory of God|C
Harjot|हरजोत|u|Sikh|North|Punjabi|Light of God|C
Harkirat|हरकीरत|u|Sikh|North|Punjabi|Praise of God|C
Harman|हरमन|u|Sikh|North|Punjabi|Loved by God; dear to all|C
Harmeet|हरमीत|u|Sikh|North|Punjabi|Friend of God|C
Harnaaz|हरनाज़|g|Sikh|North|Punjabi · Persian|Pride of God|T
Harshada|हर्षदा|g|Hindu|West|Sanskrit|Giver of joy|C
Harshali|हर्षाली|g|Hindu|West|Sanskrit|Joyful|C
Harshdeep|हर्षदीप|u|Sikh|North|Punjabi · Sanskrit|Lamp of joy|C
Harshit|हर्षित|b|Hindu|North|Sanskrit|Joyful|C
Harshita|हर्षिता|g|Hindu|Pan-India|Sanskrit|Full of joy|C
Harshvardhan|हर्षवर्धन|b|Hindu|North|Sanskrit|One who increases joy|C
Harsimran|हरसिमरन|u|Sikh|North|Punjabi|Remembrance of God|C
Hasan|हसन|b|Muslim|Pan-India|Arabic|Handsome; good|C
Hazel|हेज़ल|g|Christian|Pan-India|English|The hazel tree|T
Helen|हेलेन|g|Christian|Pan-India|Greek|Light; bright|C
Hema|हेमा|g|Hindu|Pan-India|Sanskrit|Golden|C
Hemang|हेमांग|b|Hindu|West|Sanskrit|Golden bodied|C
Hemangi|हेमांगी|g|Hindu|West|Sanskrit|Golden bodied|C
Hemanth|हेमंत|b|Hindu|South|Sanskrit|Early winter|C
Hemendra|हेमेंद्र|b|Hindu|North|Sanskrit|Lord of gold|C
Hemlata|हेमलता|g|Hindu|North|Sanskrit|Golden creeper|C
Hetal|हेतल|g|Hindu|West|Gujarati|Friendly; loving|C
Himadri|हिमाद्रि|u|Hindu|East|Sanskrit|The Himalayas|C
Himanshu|हिमांशु|b|Hindu|North|Sanskrit|The moon|C
Hina|हिना|g|Muslim|North|Arabic|Henna|C
Hiral|हीरल|g|Hindu|West|Gujarati|Lustrous; like a diamond|C
Hiranmoy|हिरण्मय|b|Hindu|East|Bengali · Sanskrit|Golden|C
Hitesh|हितेश|b|Hindu|West|Sanskrit|Lord of goodness|C
Hoor|हूर|g|Muslim|Pan-India|Arabic|A maiden of paradise|T
Hormazd|होर्मज़्द|b|Parsi|West|Persian|The wise lord|R
Hridya|हृद्या|g|Hindu|Pan-India|Sanskrit|Of the heart; pleasing|T
Hrishikesh|हृषीकेश|b|Hindu|West|Sanskrit|Lord of the senses; Vishnu|C
Hrishita|हृषिता|g|Hindu|Pan-India|Sanskrit|Joyful|R
Hrithik|ऋतिक|b|Hindu|North|Sanskrit|From the heart; truthful|C
Huma|हुमा|g|Muslim|North|Persian|A bird of good fortune|C
Humaira|हुमैरा|g|Muslim|Pan-India|Arabic|Rosy; a name of Aisha|C
Husain|हुसैन|b|Muslim|Pan-India|Arabic|Handsome; grandson of the Prophet|C
Huzaifa|हुज़ैफ़ा|b|Muslim|Pan-India|Arabic|A companion of the Prophet|T
Iffat|इफ़्फ़त|g|Muslim|North|Arabic|Chastity; modesty|C
Ignatius|इग्नेशियस|b|Christian|South|Latin|Fiery|C
Ila|इला|g|Hindu|Pan-India|Sanskrit|The earth|C
Ilavarasi|इलवरसी|g|Hindu|South|Tamil|Princess|R
Ilham|इलहाम|g|Muslim|Pan-India|Arabic|Inspiration|T
Ilma|इल्मा|g|Muslim|Pan-India|Arabic|Knowledge|T
Imtiaz|इम्तियाज़|b|Muslim|North|Arabic|Distinction|C
Inba|इन्बा|u|Hindu|South|Tamil|Joy; happiness|T
Inderjeet|इंद्रजीत|b|Hindu|North|Sanskrit|Conqueror of Indra|C
Inderpreet|इंदरप्रीत|u|Sikh|North|Punjabi · Sanskrit|Love of Indra; heavenly love|C
Indhu|इंदु|g|Hindu|South|Sanskrit|The moon|C
Indira|इंदिरा|g|Hindu|Pan-India|Sanskrit|Goddess Lakshmi|C
Indra|इंद्र|b|Hindu|Pan-India|Sanskrit|King of the gods|C
Indranil|इंद्रनील|b|Hindu|East|Sanskrit|Sapphire|C
Indu|इंदु|g|Hindu|Pan-India|Sanskrit|The moon|C
Indulekha|इंदुलेखा|g|Hindu|South|Sanskrit|The crescent moon|R
Inshirah|इनशिराह|g|Muslim|Pan-India|Arabic|Relief; openness of heart|R
Iqbal|इक़बाल|b|Muslim|North|Arabic|Good fortune; prosperity|C
Iqra|इक़रा|g|Muslim|Pan-India|Arabic|Read; the first word revealed|T
Irene|आइरीन|g|Christian|Pan-India|Greek|Peace|C
Irshad|इरशाद|b|Muslim|Pan-India|Arabic|Guidance|C
Isabel|इसाबेल|g|Christian|Pan-India|Hebrew|Pledged to God|T
Ishan|ईशान|b|Hindu|Pan-India|Sanskrit|Lord Shiva; the north east|C
Ishanvi|ईशान्वी|g|Hindu|Pan-India|Sanskrit|Goddess Lakshmi|T
Ishaq|इसहाक़|b|Muslim|Pan-India|Arabic|The prophet Isaac; laughter|C
Ishika|ईशिका|g|Hindu|Pan-India|Sanskrit|A painter's brush|T
Ishmeet|इशमीत|u|Sikh|North|Punjabi|Friend of God|T
Ishq|इश्क़|u|Secular|North|Arabic|Love|R
Ishwari|ईश्वरी|g|Hindu|West|Sanskrit|Goddess|C
Ivan|इवान|b|Christian|Pan-India|Hebrew|God is gracious|T
Izaan|इज़ान|b|Muslim|Pan-India|Arabic|Obedience|T
Jabir|जाबिर|b|Muslim|Pan-India|Arabic|Comforter; one who restores|C
Jacinta|जसिंटा|g|Christian|West|Greek|The hyacinth flower|C
Jacqueline|जैकलीन|g|Christian|Pan-India|French|He who follows|C
Jaden|जेडन|b|Christian|Pan-India|Hebrew|Thankful|T
Jagannath|जगन्नाथ|b|Hindu|East|Sanskrit|Lord of the universe|C
Jagdish|जगदीश|b|Hindu|North|Sanskrit|Lord of the world|C
Jagrit|जागृत|b|Hindu|North|Sanskrit|Awake; alert|R
Jagriti|जागृति|g|Hindu|North|Sanskrit|Awakening|C
Jagruti|जागृति|g|Hindu|West|Sanskrit|Awareness; awakening|C
Jahangir|जहाँगीर|b|Muslim|North|Persian|Conqueror of the world|C
Jaidev|जयदेव|b|Hindu|East|Sanskrit|Victory of God; a poet of Odisha|C
Jainam|जैनम|b|Jain|West|Sanskrit|Follower of the Jinas|T
Jamal|जमाल|b|Muslim|Pan-India|Arabic|Beauty|C
James|जेम्स|b|Christian|Pan-India|Hebrew|One who follows|C
Jamila|जमीला|g|Muslim|Pan-India|Arabic|Beautiful|C
Jamshed|जमशेद|b|Parsi|West|Persian|A shining king of legend|C
Janak|जनक|b|Hindu|North|Sanskrit|Father; father of Sita|C
Janhvi|जान्हवी|g|Hindu|Pan-India|Sanskrit|The river Ganga|T
Jannat|जन्नत|g|Muslim|North|Arabic|Paradise|T
Jasdeep|जसदीप|u|Sikh|North|Punjabi|Lamp of glory|C
Jasjeet|जसजीत|b|Sikh|North|Punjabi|Victory of glory|C
Jaskirat|जसकीरत|u|Sikh|North|Punjabi|Singing the praise of God|C
Jasmeet|जसमीत|u|Sikh|North|Punjabi|Friend of glory|C
Jasmine|जैस्मिन|g|Christian|Pan-India|Persian|Jasmine flower|C
Jasnoor|जसनूर|g|Sikh|North|Punjabi · Arabic|Light of glory|T
Jasveer|जसवीर|b|Sikh|North|Punjabi · Sanskrit|Brave and glorious|C
Jaswinder|जसविंदर|u|Sikh|North|Punjabi · Sanskrit|Lord of glory|C
Jatin|जतिन|b|Hindu|North|Sanskrit|One with matted hair; Lord Shiva|C
Javed|जावेद|b|Muslim|North|Persian|Eternal|C
Jaya|जया|g|Hindu|Pan-India|Sanskrit|Victory|C
Jayanthi|जयंती|g|Hindu|South|Sanskrit|Victorious; a festival|C
Jayesh|जयेश|b|Hindu|West|Sanskrit|Lord of victory|C
Jeevan|जीवन|b|Hindu|Pan-India|Sanskrit|Life|C
Jehangir|जहांगीर|b|Parsi|West|Persian|Conqueror of the world|C
Jemima|जेमिमा|g|Christian|South|Hebrew|Dove|R
Jennifer|जेनिफ़र|g|Christian|Pan-India|Welsh|Fair; white wave|C
Jessica|जेसिका|g|Christian|Pan-India|Hebrew|God beholds|C
Jhanvi|जान्हवी|g|Hindu|Pan-India|Sanskrit|The river Ganga|C
Jhilmil|झिलमिल|g|Hindu|East|Hindi|Sparkling; shimmering|C
Jignesh|जिग्नेश|b|Hindu|West|Gujarati · Sanskrit|Curiosity to know|C
Jigyasa|जिज्ञासा|g|Hindu|North|Sanskrit|Curiosity|C
Jinay|जिनय|b|Jain|West|Sanskrit|Of the Jina; victorious|T
Jineet|जिनीत|b|Jain|West|Sanskrit|Victorious|T
Jinesh|जिनेश|b|Jain|West|Sanskrit|Lord of the Jinas|C
Jishnu|जिष्णु|b|Hindu|South|Sanskrit|Victorious; Arjuna|C
Jitendra|जितेंद्र|b|Hindu|North|Sanskrit|One who has conquered the senses|C
Jivansh|जीवांश|b|Hindu|Pan-India|Sanskrit|A part of life|T
Jivraj|जीवराज|b|Hindu|West|Sanskrit|Lord of life|C
Joanna|जोआना|g|Christian|Pan-India|Hebrew|God is gracious|C
Joginder|जोगिंदर|b|Sikh|North|Punjabi · Sanskrit|Lord of yogis|C
Johan|जोहान|b|Christian|Pan-India|Hebrew|God is gracious|T
Jonathan|जोनाथन|b|Christian|Pan-India|Hebrew|Gift of God|C
Jot|जोत|u|Sikh|North|Punjabi|Light; flame|T
Joyce|जॉयस|g|Christian|Pan-India|Latin|Joyful|C
Joyita|जयिता|g|Hindu|East|Bengali|Victorious|C
Jude|ज्यूड|b|Christian|South|Hebrew|Praised|C
Judith|जूडिथ|g|Christian|Pan-India|Hebrew|Praised|C
Juhi|जूही|g|Hindu|North|Hindi|Jasmine|C
Jui|जुई|g|Hindu|West|Marathi|A jasmine flower|C
Julia|जूलिया|g|Christian|Pan-India|Latin|Youthful|C
Junaid|जुनैद|b|Muslim|Pan-India|Arabic|Soldier; a famous Sufi|C
Justin|जस्टिन|b|Christian|Pan-India|Latin|Just; fair|C
Jyoti|ज्योति|g|Hindu|Pan-India|Sanskrit|Light; flame|C
Kailash|कैलाश|b|Hindu|North|Sanskrit|The abode of Lord Shiva|C
Kainaat|कायनात|g|Secular|North|Arabic|The universe|T
Kainat|कायनात|g|Muslim|North|Arabic|The universe|T
Kajal|काजल|g|Hindu|North|Hindi|Kohl|C
Kakoli|काकली|g|Hindu|East|Bengali|The song of a bird|C
Kalaivani|कलैवाणी|g|Hindu|South|Tamil|Goddess Saraswati|C
Kalindi|कालिंदी|g|Hindu|North|Sanskrit|The river Yamuna|C
Kalpesh|कल्पेश|b|Hindu|West|Sanskrit|Lord of imagination|C
Kalyani|कल्याणी|g|Hindu|Pan-India|Sanskrit|Auspicious; Goddess Durga|C
Kamakshi|कामाक्षी|g|Hindu|South|Sanskrit|Goddess with loving eyes; Parvati|C
Kamal|कमल|b|Hindu|Pan-India|Sanskrit|Lotus|C
Kamaljeet|कमलजीत|u|Sikh|North|Punjabi · Sanskrit|Victory of the lotus|C
Kamini|कामिनी|g|Hindu|Pan-India|Sanskrit|Beautiful woman|C
Kamran|कामरान|b|Muslim|North|Persian|Successful; fortunate|C
Kanak|कनक|g|Hindu|North|Sanskrit|Gold|C
Kanan|कानन|u|Hindu|East|Sanskrit|A forest|C
Kanav|कणव|b|Hindu|Pan-India|Sanskrit|A sage; clever|T
Kangkan|कंकण|b|Hindu|East|Sanskrit|A bracelet|C
Kanha|कान्हा|b|Hindu|North|Hindi|Little Krishna|T
Kanika|कणिका|g|Hindu|Pan-India|Sanskrit|An atom; a small particle|C
Kanimozhi|कनिमोझी|g|Hindu|South|Tamil|Sweet words|C
Kanishk|कनिष्क|b|Hindu|North|Sanskrit|A Kushan king|C
Kannan|कण्णन|b|Hindu|South|Tamil|Lord Krishna|C
Kapil|कपिल|b|Hindu|Pan-India|Sanskrit|A sage; tawny|C
Karamjeet|करमजीत|b|Sikh|North|Punjabi · Sanskrit|Victory of good deeds|C
Karan|करण|b|Hindu|Pan-India|Sanskrit|Ear; a warrior of the Mahabharata|C
Karishma|करिश्मा|g|Hindu|North|Persian|Wonder|C
Karma|कर्मा|u|Buddhist|North|Sanskrit|Action; deed|C
Karthik|कार्तिक|b|Hindu|South|Sanskrit|Lord Murugan; a month|C
Karthika|कार्तिका|g|Hindu|South|Sanskrit|A star; radiant|C
Karuna|करुणा|g|Hindu|Pan-India|Sanskrit|Compassion|C
Kashif|काशिफ़|b|Muslim|Pan-India|Arabic|Discoverer; revealer|C
Kashish|कशिश|g|Hindu|North|Persian · Hindi|Attraction|C
Kashyap|कश्यप|b|Hindu|Pan-India|Sanskrit|A Vedic sage|C
Kasturi|कस्तूरी|g|Hindu|East|Sanskrit|Musk; fragrance|C
Kathir|कतिर|b|Hindu|South|Tamil|A ray of light|T
Kaumudi|कौमुदी|g|Hindu|Pan-India|Sanskrit|Moonlight|R
Kausar|कौसर|g|Muslim|Pan-India|Arabic|A river in paradise; abundance|C
Kaushal|कौशल|b|Hindu|North|Sanskrit|Skill|C
Kaushik|कौशिक|b|Hindu|West|Sanskrit|Sage Vishwamitra|C
Kaustubh|कौस्तुभ|b|Hindu|West|Sanskrit|The jewel worn by Vishnu|C
Kaveri|कावेरी|g|Hindu|South|Sanskrit|A sacred river of the south|C
Kavisha|कविशा|g|Hindu|West|Sanskrit|A poetess|T
Kaviya|कविया|g|Hindu|South|Tamil|Poetry|T
Kavyansh|काव्यांश|b|Hindu|Pan-India|Sanskrit|A part of poetry|T
Kawaljeet|कवलजीत|u|Sikh|North|Punjabi · Sanskrit|Victory of the lotus|C
Kedar|केदार|b|Hindu|West|Sanskrit|Lord Shiva; a field|C
Keerthi|कीर्ति|g|Hindu|South|Sanskrit|Fame|C
Kesar|केसर|g|Hindu|North|Sanskrit|Saffron|T
Ketaki|केतकी|g|Hindu|West|Sanskrit|A fragrant flower|C
Ketan|केतन|b|Hindu|West|Sanskrit|Home; a banner|C
Keya|केया|g|Hindu|East|Bengali|A monsoon flower|C
Khalid|ख़ालिद|b|Muslim|Pan-India|Arabic|Eternal; everlasting|C
Khurshed|ख़ुर्शीद|b|Parsi|West|Persian|The sun|C
Khushal|ख़ुशाल|b|Hindu|West|Persian · Hindi|Happy; prosperous|C
Khushi|ख़ुशी|g|Hindu|North|Persian · Hindi|Happiness|C
Khushpreet|ख़ुशप्रीत|g|Sikh|North|Punjabi · Persian|Happy love|C
Kimaya|किमया|g|Hindu|West|Sanskrit|Divine; wonderful|T
Kinjal|किंजल|g|Hindu|West|Gujarati|A river bank|C
Kiranjeet|किरणजीत|g|Sikh|North|Punjabi · Sanskrit|Victorious ray of light|C
Kirpal|किरपाल|b|Sikh|North|Punjabi · Sanskrit|Merciful|C
Kirti|कीर्ति|g|Hindu|North|Sanskrit|Fame; glory|C
Koel|कोयल|g|Hindu|East|Bengali · Hindi|The cuckoo bird|C
Komal|कोमल|g|Hindu|Pan-India|Sanskrit|Soft; tender|C
Krishay|कृशय|b|Hindu|Pan-India|Sanskrit|Lord Krishna|T
Krishiv|कृशिव|b|Hindu|Pan-India|Sanskrit|Krishna and Shiva together|T
Kriti|कृति|g|Hindu|Pan-India|Sanskrit|A creation; a work of art|C
Kritika|कृतिका|g|Hindu|Pan-India|Sanskrit|A star; the Pleiades|C
Kriyansh|क्रियांश|b|Hindu|Pan-India|Sanskrit|A part of action|T
Kshama|क्षमा|g|Jain|West|Sanskrit|Forgiveness|C
Kshitija|क्षितिजा|g|Hindu|West|Sanskrit|Daughter of the earth|C
Kuldeep|कुलदीप|b|Sikh|North|Punjabi · Sanskrit|Lamp of the family|C
Kulsum|कुलसुम|g|Muslim|Pan-India|Arabic|Daughter of the Prophet; rosy cheeks|C
Kulwant|कुलवंत|b|Sikh|North|Punjabi · Sanskrit|Of a noble family|C
Kumar|कुमार|b|Hindu|Pan-India|Sanskrit|Young prince|C
Kumaran|कुमरन|b|Hindu|South|Tamil|Young; Lord Murugan|C
Kumud|कुमुद|g|Hindu|Pan-India|Sanskrit|A night lotus|C
Kunwar|कुंवर|b|Hindu|North|Hindi|Prince|C
Kuriakose|कुरियाकोस|b|Christian|South|Greek|Of the Lord|C
Kusum|कुसुम|g|Hindu|North|Sanskrit|Flower|C
Labanya|लाबण्य|g|Hindu|East|Bengali · Sanskrit|Grace; beauty|C
Laiba|लाइबा|g|Muslim|Pan-India|Arabic|A maiden of paradise|T
Lajja|लज्जा|g|Hindu|West|Sanskrit|Modesty|R
Lakshana|लक्षणा|g|Hindu|South|Sanskrit|Auspicious marks; good qualities|C
Lakshay|लक्ष्य|b|Hindu|North|Sanskrit|Aim; goal|T
Lakshit|लक्षित|b|Hindu|North|Sanskrit|Distinguished; aimed|C
Lakshman|लक्ष्मण|b|Hindu|Pan-India|Sanskrit|Brother of Rama|C
Lakshmikanth|लक्ष्मीकांत|b|Hindu|South|Sanskrit|Beloved of Lakshmi; Vishnu|C
Lalit|ललित|b|Hindu|North|Sanskrit|Graceful; beautiful|C
Lalita|ललिता|g|Hindu|Pan-India|Sanskrit|Graceful; Goddess Parvati|C
Lata|लता|g|Hindu|Pan-India|Sanskrit|A creeper; a vine|C
Lavina|लविना|g|Christian|West|Latin|Purity|C
Lawrence|लॉरेंस|b|Christian|Pan-India|Latin|From Laurentum; crowned with laurel|C
Leela|लीला|g|Hindu|Pan-India|Sanskrit|Divine play|C
Lekshmi|लक्ष्मी|g|Hindu|South|Sanskrit|Goddess Lakshmi|C
Leon|लियोन|b|Christian|Pan-India|Greek|Lion|T
Lhamo|ल्हामो|g|Buddhist|North|Tibetan|Goddess|C
Linda|लिंडा|g|Christian|Pan-India|Latin|Pretty|C
Lipika|लिपिका|g|Hindu|East|Sanskrit|A letter; a script|C
Livleen|लिवलीन|g|Sikh|North|Punjabi|Absorbed in God's love|T
Lobsang|लोबसांग|b|Buddhist|North|Tibetan|Kind hearted; noble minded|C
Lubna|लुबना|g|Muslim|Pan-India|Arabic|A tree of sweet sap|C
Lucy|लूसी|g|Christian|Pan-India|Latin|Light|C
Luke|ल्यूक|b|Christian|Pan-India|Greek|From Lucania; light|C
Maahi|माही|g|Hindu|North|Sanskrit|The earth|T
Maaz|माज़|b|Muslim|Pan-India|Arabic|Brave; protected|T
Madhan|मदन|b|Hindu|South|Sanskrit|The god of love|C
Madhavi|माधवी|g|Hindu|Pan-India|Sanskrit|A spring creeper; Goddess Lakshmi|C
Madhu|मधु|g|Hindu|Pan-India|Sanskrit|Honey|C
Madhur|मधुर|b|Hindu|North|Sanskrit|Sweet|C
Madhura|मधुरा|g|Hindu|West|Sanskrit|Sweet|C
Madhuri|माधुरी|g|Hindu|Pan-India|Sanskrit|Sweetness|C
Madhurima|मधुरिमा|g|Hindu|East|Sanskrit|Sweetness|C
Madiha|मदीहा|g|Muslim|Pan-India|Arabic|Praiseworthy|C
Mahavir|महावीर|b|Jain|Pan-India|Sanskrit|Great hero; the twenty fourth Tirthankara|C
Maheen|माहीन|g|Muslim|North|Persian|Delicate; fine|T
Mahesh|महेश|b|Hindu|Pan-India|Sanskrit|Great lord; Lord Shiva|C
Mahima|महिमा|g|Hindu|North|Sanskrit|Greatness; glory|C
Mahnoor|माहनूर|g|Muslim|North|Persian · Arabic|Moonlight|T
Mainak|मैनाक|b|Hindu|East|Sanskrit|A mountain of legend|C
Maitreya|मैत्रेय|b|Buddhist|Pan-India|Sanskrit|Friendly; the future Buddha|R
Maitri|मैत्री|g|Hindu|West|Sanskrit|Friendship|C
Majid|माजिद|b|Muslim|Pan-India|Arabic|Glorious; noble|C
Malavika|मालविका|g|Hindu|South|Sanskrit|Princess of Malwa|C
Malini|मालिनी|g|Hindu|Pan-India|Sanskrit|A garland maker; fragrant|C
Mamata|ममता|g|Hindu|East|Sanskrit|Motherly love|C
Mamta|ममता|g|Hindu|North|Sanskrit|Motherly love|C
Manan|मनन|b|Hindu|West|Sanskrit|Reflection; deep thought|T
Manasi|मानसी|g|Hindu|West|Sanskrit|Of the mind; spiritual|C
Manasvi|मनस्वी|u|Hindu|Pan-India|Sanskrit|Wise; intelligent|T
Mandakini|मंदाकिनी|g|Hindu|North|Sanskrit|A river of heaven|C
Mandar|मंदार|b|Hindu|West|Sanskrit|A heavenly tree|C
Mangala|मंगला|g|Buddhist|Pan-India|Sanskrit|Auspicious|C
Mangesh|मंगेश|b|Hindu|West|Sanskrit|Lord Shiva|C
Manha|मनहा|g|Muslim|Pan-India|Arabic|A gift of God|T
Mani|मणि|u|Hindu|South|Sanskrit|A jewel|C
Manikandan|मणिकंडन|b|Hindu|South|Tamil|Lord Ayyappa; one with a bell at the neck|C
Maninder|मनिंदर|b|Sikh|North|Punjabi · Sanskrit|Lord of the mind|C
Manish|मनीष|b|Hindu|Pan-India|Sanskrit|Lord of the mind; wise|C
Manisha|मनीषा|g|Hindu|Pan-India|Sanskrit|Wisdom; intellect|C
Manjari|मंजरी|g|Hindu|Pan-India|Sanskrit|A bunch of blossoms|C
Manjeet|मनजीत|u|Sikh|North|Punjabi · Sanskrit|Conqueror of the mind|C
Manjot|मनजोत|u|Sikh|North|Punjabi|Light of the mind|C
Manjunath|मंजुनाथ|b|Hindu|South|Sanskrit|Lord of snow; Lord Shiva|C
Manmeet|मनमीत|u|Sikh|North|Punjabi|Friend of the heart|C
Manoj|मनोज|b|Hindu|Pan-India|Sanskrit|Born of the mind; Kamadeva|C
Mansi|मानसी|g|Hindu|West|Sanskrit|Of the mind|C
Mansoor|मंसूर|b|Muslim|Pan-India|Arabic|Victorious; helped by God|C
Manthan|मंथन|b|Hindu|West|Sanskrit|Churning; deep thought|C
Manu|मनु|b|Hindu|South|Sanskrit|The first man; wise|C
Manveer|मनवीर|b|Sikh|North|Punjabi · Sanskrit|Brave of heart|C
Mariam|मरियम|g|Muslim|Pan-India|Arabic|Mother of Prophet Isa|C
Mariamma|मरियम्मा|g|Christian|South|Hebrew · Malayalam|Mother Mary|C
Marina|मरीना|g|Christian|Pan-India|Latin|Of the sea|C
Mark|मार्क|b|Christian|Pan-India|Latin|Warlike; a gospel writer|C
Martha|मार्था|g|Christian|Pan-India|Aramaic|Lady; mistress of the house|C
Martin|मार्टिन|b|Christian|Pan-India|Latin|Warlike|C
Marudevi|मरुदेवी|g|Jain|West|Sanskrit|Mother of the first Tirthankara|R
Mathai|मथाई|b|Christian|South|Hebrew · Malayalam|Matthew; gift of God|C
Mathi|मति|g|Hindu|South|Tamil|The moon; wisdom|T
Mayank|मयंक|b|Hindu|North|Sanskrit|The moon|C
Medhansh|मेधांश|b|Hindu|Pan-India|Sanskrit|A part of wisdom|T
Megha|मेघा|g|Hindu|Pan-India|Sanskrit|Cloud|C
Meghana|मेघना|g|Hindu|South|Sanskrit|Cloud|C
Meghna|मेघना|g|Hindu|East|Sanskrit|A great river; clouds|C
Mehak|महक|g|Hindu|North|Hindi|Fragrance|C
Mehakpreet|महकप्रीत|g|Sikh|North|Punjabi|Fragrance of love|T
Mehar|मेहर|g|Sikh|North|Punjabi · Persian|Grace; kindness|T
Mehboob|महबूब|b|Muslim|North|Arabic|Beloved|C
Mehjabeen|महजबीन|g|Muslim|North|Persian|Moon browed; beautiful|C
Mehreen|मेहरीन|g|Muslim|North|Persian|Kind; loving|T
Mehtab|महताब|u|Muslim|North|Persian|Moonlight|C
Mehul|मेहुल|b|Hindu|West|Sanskrit|Rain; cloud|C
Mehwish|महवश|g|Muslim|North|Persian|Like the moon|C
Melissa|मेलिसा|g|Christian|Pan-India|Greek|Honey bee|C
Melvin|मेल्विन|b|Christian|South|Celtic|Gentle chief|C
Merlin|मर्लिन|u|Christian|South|Welsh|Sea fortress|C
Metta|मेत्ता|g|Buddhist|Pan-India|Pali|Loving kindness|R
Mia|मिया|g|Christian|Pan-India|Latin|Mine; beloved|T
Midhun|मिथुन|b|Hindu|South|Sanskrit|A pair; Gemini|C
Mihika|मिहिका|g|Hindu|West|Sanskrit|Mist; dew|T
Milan|मिलन|b|Hindu|Pan-India|Sanskrit|Meeting; union|C
Minha|मिनहा|g|Muslim|Pan-India|Arabic|Gift; blessing|T
Misbah|मिस्बाह|g|Muslim|Pan-India|Arabic|Lamp|C
Mishti|मिष्टी|g|Hindu|East|Bengali|Sweet|T
Mitesh|मितेश|b|Hindu|West|Sanskrit|One with few desires|C
Mithran|मित्रन|b|Hindu|South|Sanskrit|Friend; the sun|T
Mitra|मित्र|b|Hindu|Pan-India|Sanskrit|Friend; the sun|C
Mohan|मोहन|b|Hindu|Pan-India|Sanskrit|Charming; Krishna|C
Mohana|मोहना|g|Hindu|South|Sanskrit|Enchanting|C
Mohini|मोहिनी|g|Hindu|Pan-India|Sanskrit|Enchanting; a form of Vishnu|C
Mohua|मोहुआ|g|Hindu|East|Bengali|The mahua flower|C
Moksha|मोक्षा|g|Jain|West|Sanskrit|Liberation|T
Monica|मोनिका|g|Christian|Pan-India|Latin|Advisor; the mother of Saint Augustine|C
Monika|मोनिका|g|Hindu|North|Sanskrit · Latin|Advisor; noble|C
Mounika|मौनिका|g|Hindu|South|Sanskrit|Silent; reserved|C
Mridul|मृदुल|b|Hindu|Pan-India|Sanskrit|Soft; gentle|C
Mridula|मृदुला|g|Hindu|Pan-India|Sanskrit|Soft; gentle|C
Mrinmoy|मृण्मय|b|Hindu|East|Bengali · Sanskrit|Made of earth|C
Mrunmayi|मृण्मयी|g|Hindu|West|Sanskrit|Made of earth|C
Mubarak|मुबारक|b|Muslim|Pan-India|Arabic|Blessed|C
Mugdha|मुग्धा|g|Hindu|West|Sanskrit|Charmed; innocent|C
Muhsin|मुहसिन|b|Muslim|South|Arabic|Benefactor; one who does good|C
Mukesh|मुकेश|b|Hindu|North|Sanskrit|Lord of liberation|C
Mukund|मुकुंद|b|Hindu|Pan-India|Sanskrit|Giver of freedom; Lord Vishnu|C
Mumtaz|मुमताज़|g|Muslim|North|Arabic|Distinguished; excellent|C
Muneer|मुनीर|b|Muslim|Pan-India|Arabic|Shining; luminous|C
Murtaza|मुर्तज़ा|b|Muslim|Pan-India|Arabic|Chosen; a title of Ali|C
Murugan|मुरुगन|b|Hindu|South|Tamil|Lord Murugan; beautiful|C
Muskaan|मुस्कान|g|Muslim|North|Persian|Smile|C
Muskan|मुस्कान|g|Hindu|North|Persian · Hindi|Smile|C
Mustafa|मुस्तफ़ा|b|Muslim|Pan-India|Arabic|Chosen; a name of the Prophet|C
Mysha|मायशा|g|Muslim|Pan-India|Arabic|Lively; full of life|T
Naaz|नाज़|g|Secular|North|Persian|Pride; grace|C
Nabanita|नबनीता|g|Hindu|East|Bengali · Sanskrit|Fresh butter; new|C
Nabeel|नबील|b|Muslim|Pan-India|Arabic|Noble|C
Nachiket|नचिकेत|b|Hindu|West|Sanskrit|A seeker in the Upanishads|C
Nadeem|नदीम|b|Muslim|Pan-India|Arabic|Companion; friend|C
Nadia|नादिया|g|Muslim|Pan-India|Arabic|Caller; moist with dew|C
Nafisa|नफ़ीसा|g|Muslim|Pan-India|Arabic|Precious; delicate|C
Nagaraj|नागराज|b|Hindu|South|Sanskrit|King of serpents|C
Nagarjuna|नागार्जुन|b|Hindu|South|Sanskrit|A Buddhist philosopher; strong|C
Naksh|नक्ष|b|Hindu|Pan-India|Sanskrit|Star; the moon|T
Nakshatra|नक्षत्र|u|Hindu|Pan-India|Sanskrit|A star|T
Nalini|नलिनी|g|Hindu|Pan-India|Sanskrit|Lotus|C
Naman|नमन|b|Hindu|North|Sanskrit|Salutation; bowing|T
Namra|नम्रा|g|Jain|West|Sanskrit|Humble; polite|C
Nanak|नानक|b|Sikh|North|Punjabi|The first Sikh Guru|C
Nancy|नैन्सी|g|Christian|Pan-India|Hebrew|Grace|C
Nandan|नंदन|b|Hindu|Pan-India|Sanskrit|Son; one who gives joy|C
Nandana|नंदना|g|Hindu|South|Sanskrit|Daughter; a garden of the gods|T
Nandhini|नंदिनी|g|Hindu|South|Sanskrit|Delight; the sacred cow|C
Nandish|नंदीश|b|Hindu|Pan-India|Sanskrit|Lord of Nandi; Shiva|C
Nandita|नंदिता|g|Hindu|Pan-India|Sanskrit|Happy; joyful|C
Naomi|नाओमी|g|Christian|Pan-India|Hebrew|Pleasant; sweet|C
Naresh|नरेश|b|Hindu|North|Sanskrit|King|C
Nargis|नरगिस|g|Muslim|North|Persian|The narcissus flower|C
Nariman|नरीमन|b|Parsi|West|Persian|Brave; strong hearted|C
Narmadha|नर्मदा|g|Hindu|South|Sanskrit|The river Narmada; giver of joy|C
Naseem|नसीम|u|Muslim|North|Arabic|A gentle breeze|C
Nasir|नासिर|b|Muslim|Pan-India|Arabic|Helper; supporter|C
Nathaniel|नथानिएल|b|Christian|Pan-India|Hebrew|Gift of God|C
Navami|नवमी|g|Hindu|Pan-India|Sanskrit|The ninth day of the moon|R
Navaneeth|नवनीत|b|Hindu|South|Sanskrit|Fresh butter; Krishna|C
Navaz|नवाज़|b|Parsi|West|Persian|Kind; caressing|C
Naveed|नवेद|b|Muslim|North|Persian|Good news|C
Naveen|नवीन|b|Hindu|Pan-India|Sanskrit|New|C
Navleen|नवलीन|g|Sikh|North|Punjabi|Absorbed in the new|C
Navneet|नवनीत|u|Sikh|North|Punjabi · Sanskrit|Ever new; fresh butter|C
Navraj|नवराज|b|Sikh|North|Punjabi · Sanskrit|New king|C
Nayan|नयन|b|Hindu|West|Sanskrit|Eye|C
Nayantara|नयनतारा|g|Hindu|Pan-India|Sanskrit|Star of the eye|C
Nazia|नाज़िया|g|Muslim|North|Persian|Pride; delicate|C
Nazneen|नाज़नीन|g|Muslim|North|Persian|Delicate; beautiful|C
Neelam|नीलम|g|Hindu|North|Sanskrit|Sapphire|C
Neelansh|नीलांश|b|Hindu|Pan-India|Sanskrit|A part of the blue sky|T
Neelima|नीलिमा|g|Hindu|Pan-India|Sanskrit|Blueness of the sky|C
Neeraj|नीरज|b|Hindu|North|Sanskrit|Lotus|C
Neeti|नीति|g|Hindu|Pan-India|Sanskrit|Good conduct; policy|C
Neev|नींव|b|Hindu|North|Hindi|Foundation|T
Nehal|नेहल|g|Hindu|West|Sanskrit|Rainy; beautiful|C
Nemi|नेमि|b|Jain|West|Sanskrit|Rim of a wheel; a Tirthankara|R
Netra|नेत्रा|g|Hindu|West|Sanskrit|Eye|C
Nicholas|निकोलस|b|Christian|Pan-India|Greek|Victory of the people|C
Nida|निदा|g|Muslim|Pan-India|Arabic|A call; voice|C
Nidhi|निधि|g|Hindu|West|Sanskrit|Treasure|C
Nidhish|निधीश|b|Hindu|Pan-India|Sanskrit|Lord of treasures|R
Nihaan|निहान|b|Hindu|Pan-India|Sanskrit|Born; rising|T
Nihar|निहार|b|Hindu|Pan-India|Sanskrit|Morning dew; mist|C
Niharika|निहारिका|g|Hindu|Pan-India|Sanskrit|Nebula; misty|C
Nikhila|निखिला|g|Hindu|South|Sanskrit|Complete; whole|C
Nikita|निकिता|g|Hindu|Pan-India|Sanskrit|The earth|C
Nikunj|निकुंज|b|Hindu|West|Sanskrit|A grove; a bower|C
Nilesh|नीलेश|b|Hindu|West|Sanskrit|Blue lord; Krishna|C
Nilim|नीलिम|b|Hindu|East|Sanskrit|Blue|C
Nilofar|नीलोफ़र|g|Muslim|North|Persian|Water lily|C
Nima|नीमा|u|Buddhist|North|Tibetan|The sun; born on a Sunday|C
Nimrat|निमरत|g|Sikh|North|Punjabi|Humility|C
Niranjan|निरंजन|b|Hindu|Pan-India|Sanskrit|Spotless; pure|C
Nirmal|निर्मल|b|Hindu|Pan-India|Sanskrit|Pure; clean|C
Nirmala|निर्मला|g|Hindu|Pan-India|Sanskrit|Pure; clean|C
Nirvaan|निर्वाण|b|Hindu|Pan-India|Sanskrit|Liberation|T
Nirvi|निर्वी|g|Hindu|West|Sanskrit|Wise|T
Nisarg|निसर्ग|b|Hindu|West|Sanskrit|Nature|C
Nishant|निशांत|b|Hindu|Pan-India|Sanskrit|Dawn; end of night|C
Nishat|निशात|g|Muslim|North|Persian|Joy; happiness|C
Nishita|निशिता|g|Hindu|Pan-India|Sanskrit|Sharp; alert|C
Nishith|निशीथ|b|Hindu|West|Sanskrit|Midnight|C
Nishka|निष्का|g|Hindu|Pan-India|Sanskrit|Honest; pure|T
Nithya|नित्या|g|Hindu|South|Sanskrit|Eternal|C
Nitin|नितिन|b|Hindu|Pan-India|Sanskrit|On the right path|C
Nityam|नित्यम|b|Hindu|Pan-India|Sanskrit|Eternal|R
Nivedan|निवेदन|b|Hindu|Pan-India|Sanskrit|A humble request|R
Nivetha|निवेदा|g|Hindu|South|Sanskrit|An offering to God|C
Niyati|नियति|g|Hindu|Pan-India|Sanskrit|Destiny|C
Noah|नोआ|b|Christian|Pan-India|Hebrew|Rest; comfort|T
Noorpreet|नूरप्रीत|g|Sikh|North|Punjabi · Arabic|Love of light|T
Norbu|नोरबू|b|Buddhist|North|Tibetan|Jewel|C
Nupur|नूपुर|g|Hindu|Pan-India|Sanskrit|Anklet|C
Nusrat|नुसरत|u|Muslim|North|Arabic|Help; victory|C
Ojasvini|ओजस्विनी|g|Hindu|Pan-India|Sanskrit|Full of vigour; radiant|R
Olivia|ओलिविया|g|Christian|Pan-India|Latin|Olive tree|T
Oscar|ऑस्कर|b|Christian|Pan-India|English|Spear of God|C
Ouseph|औसेफ़|b|Christian|South|Hebrew · Malayalam|Joseph; God will add|C
Paavan|पावन|b|Hindu|Pan-India|Sanskrit|Pure; holy|C
Padma|पद्मा|g|Hindu|Pan-India|Sanskrit|Lotus; Goddess Lakshmi|C
Padmavati|पद्मावती|g|Jain|West|Sanskrit|Full of lotuses; a guardian goddess|C
Padmini|पद्मिनी|g|Hindu|South|Sanskrit|Lotus; a lotus pond|C
Pallab|पल्लब|b|Hindu|East|Bengali|New leaves|C
Pankaj|पंकज|b|Hindu|Pan-India|Sanskrit|Lotus|C
Parambir|परमबीर|b|Sikh|North|Punjabi · Sanskrit|Supremely brave|C
Paramjeet|परमजीत|u|Sikh|North|Punjabi · Sanskrit|Supreme victory|C
Paras|पारस|b|Hindu|North|Sanskrit|The philosopher's stone|C
Parikshit|परीक्षित|b|Hindu|Pan-India|Sanskrit|Tested; a king of the Mahabharata|R
Parinita|परिणीता|g|Hindu|East|Sanskrit|Married; complete|C
Parneet|परनीत|g|Sikh|North|Punjabi|Devoted to the Guru|C
Paromita|पारमिता|g|Hindu|East|Sanskrit|Perfection|C
Parshva|पार्श्व|b|Jain|West|Sanskrit|The twenty third Tirthankara|C
Partha|पार्थ|b|Hindu|East|Sanskrit|Arjuna|C
Parul|पारुल|g|Hindu|North|Sanskrit|A flower|C
Parvathy|पार्वती|g|Hindu|South|Sanskrit|Goddess Parvati|C
Parveen|परवीन|g|Muslim|North|Persian|The Pleiades|C
Pasang|पासांग|u|Buddhist|North|Tibetan|Born on a Friday|C
Patrick|पैट्रिक|b|Christian|Pan-India|Latin|Nobleman|C
Pavithra|पवित्रा|g|Hindu|South|Sanskrit|Pure; holy|C
Pavitra|पवित्रा|g|Hindu|Pan-India|Sanskrit|Pure; holy|C
Pavneet|पवनीत|g|Sikh|North|Punjabi · Sanskrit|Pure; holy|C
Pavni|पावनी|g|Hindu|Pan-India|Sanskrit|Pure; holy|T
Pawandeep|पवनदीप|u|Sikh|North|Punjabi · Sanskrit|Lamp in the wind|C
Payal|पायल|g|Hindu|North|Hindi|Anklet|C
Pema|पेमा|u|Buddhist|North|Tibetan|Lotus|C
Pervez|परवेज़|b|Parsi|West|Persian|Victorious; fortunate|C
Philip|फ़िलिप|b|Christian|Pan-India|Greek|Lover of horses|C
Philomena|फ़िलोमिना|g|Christian|South|Greek|Loved one; strength|C
Piyush|पीयूष|b|Hindu|Pan-India|Sanskrit|Nectar|C
Ponni|पोन्नि|g|Hindu|South|Tamil|Golden; the river Kaveri|C
Poonam|पूनम|g|Hindu|North|Hindi|Full moon|C
Poongodi|पूंगोडी|g|Hindu|South|Tamil|A flowering creeper|R
Prabhat|प्रभात|b|Hindu|North|Sanskrit|Morning; dawn|C
Prabhleen|प्रभलीन|g|Sikh|North|Punjabi · Sanskrit|Absorbed in God|C
Prabhnoor|प्रभनूर|u|Sikh|North|Punjabi · Arabic|Light of God|T
Prabhu|प्रभु|b|Hindu|South|Sanskrit|Lord; master|C
Prachi|प्राची|g|Hindu|Pan-India|Sanskrit|The east; dawn|C
Pradyumna|प्रद्युम्न|b|Hindu|Pan-India|Sanskrit|Son of Krishna; mighty|R
Pragati|प्रगति|g|Hindu|North|Sanskrit|Progress|C
Pragyan|प्रज्ञान|b|Hindu|East|Sanskrit|Wisdom|C
Prajakta|प्राजक्ता|g|Hindu|West|Marathi|The night jasmine flower|C
Prajna|प्रज्ञा|g|Buddhist|Pan-India|Sanskrit|Wisdom; insight|C
Prakash|प्रकाश|b|Hindu|Pan-India|Sanskrit|Light|C
Prakhar|प्रखर|b|Hindu|North|Sanskrit|Sharp; brilliant|C
Prakriti|प्रकृति|g|Hindu|Pan-India|Sanskrit|Nature|C
Pramod|प्रमोद|b|Hindu|Pan-India|Sanskrit|Joy; delight|C
Pranali|प्रणाली|g|Hindu|West|Sanskrit|A system; a channel|C
Pranavi|प्रणवी|g|Hindu|South|Sanskrit|The sacred sound Om|T
Pranay|प्रणय|b|Hindu|Pan-India|Sanskrit|Love; affection|C
Pranit|प्रणीत|b|Hindu|West|Sanskrit|Led forward; humble|C
Pranshu|प्रांशु|b|Hindu|North|Sanskrit|Tall|C
Prarthana|प्रार्थना|g|Hindu|Pan-India|Sanskrit|Prayer|C
Prasanna|प्रसन्न|u|Hindu|South|Sanskrit|Cheerful; pleased|C
Prasanta|प्रशांत|b|Hindu|East|Sanskrit|Calm; tranquil|C
Prasenjit|प्रसेनजीत|b|Hindu|East|Sanskrit|Conqueror of armies|C
Prashant|प्रशांत|b|Hindu|Pan-India|Sanskrit|Calm; tranquil|C
Pratham|प्रथम|b|Hindu|West|Sanskrit|First|T
Pratibha|प्रतिभा|g|Hindu|Pan-India|Sanskrit|Talent; brilliance|C
Pratik|प्रतीक|b|Hindu|Pan-India|Sanskrit|Symbol|C
Pratiksha|प्रतीक्षा|g|Jain|West|Sanskrit|Waiting; hope|C
Pratyaksh|प्रत्यक्ष|b|Hindu|North|Sanskrit|Visible; evident|T
Pratyush|प्रत्यूष|b|Hindu|Pan-India|Sanskrit|Dawn|C
Pratyusha|प्रत्यूषा|g|Hindu|South|Sanskrit|Dawn|C
Praveen|प्रवीण|b|Hindu|Pan-India|Sanskrit|Skilful; expert|C
Preet|प्रीत|u|Sikh|North|Punjabi|Love|C
Preeti|प्रीति|g|Hindu|Pan-India|Sanskrit|Love|C
Prem|प्रेम|b|Hindu|Pan-India|Sanskrit|Love|C
Priscilla|प्रिसिला|g|Christian|South|Latin|Ancient; venerable|C
Pritam|प्रीतम|b|Hindu|East|Sanskrit|Beloved|C
Pritha|पृथा|g|Hindu|East|Sanskrit|Kunti, mother of the Pandavas|C
Pritish|प्रीतीश|b|Hindu|East|Sanskrit|God of love|C
Priyanka|प्रियंका|g|Hindu|Pan-India|Sanskrit|Dear; lovely|C
Puja|पूजा|g|Hindu|East|Sanskrit|Worship|C
Puneet|पुनीत|b|Hindu|North|Sanskrit|Pure; holy|C
Puneeth|पुनीत|b|Hindu|South|Sanskrit|Pure|C
Purab|पूरब|b|Hindu|North|Hindi|The east|T
Purvi|पूर्वी|g|Hindu|Pan-India|Sanskrit|Eastern; a raga|C
Pushkar|पुष्कर|b|Hindu|North|Sanskrit|Lotus; a sacred lake|C
Pushpa|पुष्पा|g|Hindu|Pan-India|Sanskrit|Flower|C
Rachana|रचना|g|Hindu|Pan-India|Sanskrit|Creation|C
Radhika|राधिका|g|Hindu|Pan-India|Sanskrit|Radha, beloved of Krishna|C
Rafia|रफ़िया|g|Muslim|Pan-India|Arabic|Exalted; high|C
Rafiq|रफ़ीक़|b|Muslim|Pan-India|Arabic|Friend; companion|C
Raghavan|राघवन|b|Hindu|South|Sanskrit|Lord Rama|C
Raghu|रघु|b|Hindu|Pan-India|Sanskrit|An ancestor of Rama; swift|C
Raghunandan|रघुनंदन|b|Hindu|North|Sanskrit|Son of the Raghu clan; Rama|R
Raghuveer|रघुवीर|b|Hindu|North|Sanskrit|Hero of the Raghu clan; Rama|C
Ragini|रागिनी|g|Hindu|Pan-India|Sanskrit|A melody|C
Rahil|राहिल|b|Muslim|Pan-India|Arabic|Traveller|C
Rahim|रहीम|b|Muslim|Pan-India|Arabic|Merciful|C
Rahima|रहीमा|g|Muslim|Pan-India|Arabic|Merciful; kind|C
Rahula|राहुल|b|Buddhist|Pan-India|Pali|Son of the Buddha|C
Raihana|रैहाना|g|Muslim|Pan-India|Arabic|Sweet basil|C
Raivat|रैवत|b|Hindu|West|Sanskrit|Wealthy; a mountain|R
Rajalakshmi|राजलक्ष्मी|g|Hindu|South|Sanskrit|Royal Lakshmi|C
Rajani|रजनी|g|Hindu|Pan-India|Sanskrit|Night|C
Rajarshi|राजर्षि|b|Hindu|East|Sanskrit|A king who is also a sage|C
Rajasekhar|राजशेखर|b|Hindu|South|Sanskrit|Crown of kings; Lord Shiva|C
Rajashree|राजश्री|g|Hindu|East|Sanskrit|Royal grace|C
Rajdeep|राजदीप|b|Sikh|North|Punjabi · Sanskrit|Lamp of the kingdom|C
Rajeev|राजीव|b|Hindu|Pan-India|Sanskrit|Blue lotus|C
Rajesh|राजेश|b|Hindu|Pan-India|Sanskrit|King of kings|C
Rajvi|राजवी|g|Hindu|West|Gujarati|Royal|C
Rakesh|राकेश|b|Hindu|Pan-India|Sanskrit|Lord of the full moon night|C
Rakshith|रक्षित|b|Hindu|South|Sanskrit|Protected|C
Ram|राम|b|Hindu|Pan-India|Sanskrit|Lord Rama; pleasing|C
Ramesh|रमेश|b|Hindu|Pan-India|Sanskrit|Lord of Lakshmi; Vishnu|C
Ranajit|रणजीत|b|Hindu|East|Bengali · Sanskrit|Victor in battle|C
Ranbir|रणबीर|b|Hindu|North|Sanskrit|Brave in battle|C
Rania|रानिया|g|Muslim|Pan-India|Arabic|Queenly; gazing|T
Ranjana|रंजना|g|Hindu|Pan-India|Sanskrit|Delighting|C
Ranjani|रंजनी|g|Hindu|South|Sanskrit|Pleasing; a raga|C
Ranjit|रंजीत|b|Hindu|North|Sanskrit|Victor in battle|C
Ranvijay|रणविजय|b|Hindu|North|Sanskrit|Victorious in battle|C
Raphael|राफ़ेल|b|Christian|Pan-India|Hebrew|God heals|C
Rashi|राशि|g|Hindu|Pan-India|Sanskrit|A sign of the zodiac; a heap|C
Rashid|राशिद|b|Muslim|Pan-India|Arabic|Rightly guided|C
Rashmi|रश्मि|g|Hindu|Pan-India|Sanskrit|Ray of light|C
Rasika|रसिका|g|Hindu|West|Sanskrit|One who appreciates art|C
Rati|रति|g|Hindu|Pan-India|Sanskrit|Wife of Kamadeva; love|C
Raunak|रौनक|b|Hindu|North|Urdu · Hindi|Brightness; liveliness|C
Ravi|रवि|b|Hindu|Pan-India|Sanskrit|The sun|C
Ravleen|रवलीन|g|Sikh|North|Punjabi · Sanskrit|Absorbed in the sun|C
Ravneet|रवनीत|g|Sikh|North|Punjabi · Sanskrit|Like the sun|C
Razia|रज़िया|g|Muslim|North|Arabic|Content; pleased|C
Reeva|रीवा|g|Hindu|Pan-India|Sanskrit|The river Narmada|T
Regina|रेजिना|g|Christian|Pan-India|Latin|Queen|C
Rehana|रेहाना|g|Muslim|Pan-India|Arabic|Sweet basil|C
Rehmat|रहमत|u|Muslim|North|Arabic|Mercy|C
Rekha|रेखा|g|Hindu|Pan-India|Sanskrit|A line|C
Renuka|रेणुका|g|Hindu|West|Sanskrit|Mother of Parashurama|C
Reshma|रेशमा|g|Hindu|South|Persian · Hindi|Silken|C
Reuben|रूबेन|b|Christian|Pan-India|Hebrew|Behold, a son|C
Revathi|रेवती|g|Hindu|South|Sanskrit|A star|C
Rewa|रेवा|g|Hindu|West|Sanskrit|The river Narmada|C
Reyaan|रेयान|b|Hindu|Pan-India|Sanskrit|Little king|T
Richa|ऋचा|g|Hindu|North|Sanskrit|A Vedic hymn|C
Riddhima|रिद्धिमा|g|Hindu|Pan-India|Sanskrit|Prosperity|T
Riddhiman|ऋद्धिमान|b|Hindu|East|Sanskrit|Prosperous|C
Rihaan|रिहान|b|Hindu|Pan-India|Sanskrit|Chosen by God|T
Rimjhim|रिमझिम|g|Hindu|East|Hindi|The patter of rain|C
Rishaan|ऋषान|b|Hindu|Pan-India|Sanskrit|Good man; a part of a sage|T
Rishika|ऋषिका|g|Hindu|Pan-India|Sanskrit|A woman sage|C
Rishit|ऋषित|b|Hindu|West|Sanskrit|The best|T
Rita|रीटा|g|Christian|Pan-India|Latin|Pearl|C
Ritam|ऋतम|b|Hindu|East|Sanskrit|Truth; cosmic order|R
Ritesh|रितेश|b|Hindu|North|Sanskrit|Lord of truth|C
Ritika|ऋतिका|g|Hindu|Pan-India|Sanskrit|Movement; brass|C
Ritu|ऋतु|g|Hindu|North|Sanskrit|Season|C
Rituraj|ऋतुराज|b|Hindu|East|Sanskrit|King of seasons; spring|C
Ritvik|ऋत्विक|b|Hindu|Pan-India|Sanskrit|A priest who leads the ritual|T
Robert|रॉबर्ट|b|Christian|Pan-India|English|Bright fame|C
Rohini|रोहिणी|g|Hindu|Pan-India|Sanskrit|A star; wife of the moon|C
Rohit|रोहित|b|Hindu|West|Sanskrit|Red; the rising sun|C
Ronit|रोनित|b|Hindu|North|Sanskrit|Bright; joyful|C
Roopa|रूपा|g|Hindu|South|Sanskrit|Beauty; form|C
Rose|रोज़|g|Christian|Pan-India|Latin|Rose flower|C
Rosemary|रोज़मेरी|g|Christian|Pan-India|Latin|Dew of the sea|C
Roshan|रोशन|u|Muslim|North|Persian|Bright; shining|C
Roshni|रोशनी|g|Parsi|West|Persian|Light|C
Royce|रॉयस|b|Christian|South|English|Son of the king|R
Rubina|रूबीना|g|Muslim|North|Persian|Ruby|C
Ruchi|रुचि|g|Hindu|North|Sanskrit|Interest; taste|C
Rudraksh|रुद्राक्ष|b|Hindu|North|Sanskrit|The eye of Rudra; a sacred bead|T
Rudrani|रुद्राणी|g|Hindu|Pan-India|Sanskrit|Goddess Parvati|R
Rudransh|रुद्रांश|b|Hindu|North|Sanskrit|A part of Rudra; Shiva|T
Rujul|ऋजुल|b|Hindu|West|Sanskrit|Honest; simple|C
Rukhsana|रुख़साना|g|Muslim|North|Persian|Bright; brilliant|C
Rukhsar|रुख़सार|g|Muslim|North|Persian|Cheek; face|C
Rukmini|रुक्मिणी|g|Hindu|Pan-India|Sanskrit|Wife of Krishna|C
Ruksana|रुख़साना|g|Muslim|North|Persian|Bright; brilliant|C
Rumaisa|रुमैसा|g|Muslim|Pan-India|Arabic|A companion of the Prophet|T
Rupa|रूपा|g|Hindu|East|Sanskrit|Beauty; form|C
Rupali|रूपाली|g|Hindu|West|Sanskrit|Beautiful|C
Rupinder|रूपिंदर|u|Sikh|North|Punjabi · Sanskrit|Of great beauty|C
Rupkatha|रूपकथा|g|Hindu|East|Bengali|A fairy tale|R
Rushil|रुशिल|b|Hindu|West|Sanskrit|Charming|T
Rustom|रुस्तम|b|Parsi|West|Persian|A legendary hero|C
Rutuja|ऋतुजा|g|Hindu|West|Sanskrit|Born of the seasons|C
Rutvik|ऋत्विक|b|Hindu|West|Sanskrit|A priest|T
Ryan|रायन|b|Christian|Pan-India|Celtic|Little king|T
Saachi|साची|g|Hindu|Pan-India|Sanskrit|Truth; beloved|T
Saanjh|सांझ|g|Sikh|North|Punjabi|Evening; a bond|T
Saba|सबा|g|Muslim|Pan-India|Arabic|A morning breeze|C
Sabari|शबरी|g|Hindu|South|Sanskrit|A devotee of Rama|C
Sabeena|सबीना|g|Muslim|Pan-India|Arabic|Beautiful|C
Sabrina|सब्रीना|g|Christian|Pan-India|Latin|From the river Severn|C
Sabyasachi|सब्यसाची|b|Hindu|East|Sanskrit|Arjuna, who could shoot with either hand|C
Sachi|सची|g|Hindu|Pan-India|Sanskrit|Wife of Indra; grace|C
Sachin|सचिन|b|Hindu|Pan-India|Sanskrit|Pure; Indra|C
Sadhana|साधना|g|Hindu|Pan-India|Sanskrit|Devoted practice|C
Sadia|सादिया|g|Muslim|Pan-India|Arabic|Lucky; fortunate|C
Sadiq|सादिक़|b|Muslim|Pan-India|Arabic|Truthful; sincere|C
Saeed|सईद|b|Muslim|Pan-India|Arabic|Happy; fortunate|C
Sahaj|सहज|b|Hindu|North|Sanskrit|Natural; easy|T
Sahana|सहना|g|Hindu|South|Sanskrit|Patience; a raga|C
Sahar|सहर|g|Muslim|Pan-India|Arabic|Dawn|C
Sahas|साहस|b|Hindu|Pan-India|Sanskrit|Courage|T
Sahithi|साहिती|g|Hindu|South|Sanskrit|Literature|T
Saima|साइमा|g|Muslim|Pan-India|Arabic|Fasting|C
Sajid|साजिद|b|Muslim|Pan-India|Arabic|One who bows in prayer|C
Sakina|सकीना|g|Muslim|Pan-India|Arabic|Tranquillity; peace|C
Sakshi|साक्षी|g|Hindu|Pan-India|Sanskrit|Witness|C
Salim|सलीम|b|Muslim|Pan-India|Arabic|Safe; sound|C
Salma|सलमा|g|Muslim|Pan-India|Arabic|Peaceful; safe|C
Salman|सलमान|b|Muslim|Pan-India|Arabic|Safe; a companion of the Prophet|C
Saloni|सलोनी|g|Hindu|North|Hindi|Beautiful; lovely|C
Samanvi|समन्वी|g|Hindu|Pan-India|Sanskrit|Bringing together|T
Samar|समर|b|Hindu|North|Sanskrit|War; battle|C
Sambhav|संभव|b|Hindu|North|Sanskrit|Possible; born|C
Sameeksh|समीक्ष|b|Hindu|Pan-India|Sanskrit|Insight; careful look|R
Sameera|समीरा|g|Muslim|Pan-India|Arabic|Companion in evening talk|C
Samiksha|समीक्षा|g|Hindu|Pan-India|Sanskrit|Analysis; review|C
Samina|समीना|g|Muslim|Pan-India|Arabic|Precious; valuable|C
Samkit|समकित|b|Jain|West|Sanskrit|Right belief|T
Samreen|समरीन|g|Muslim|North|Arabic|Fruitful|C
Sanchi|सांची|g|Hindu|North|Sanskrit|Collection; a Buddhist site|C
Sanchit|संचित|b|Hindu|North|Sanskrit|Collected; gathered|C
Sandeep|संदीप|b|Hindu|Pan-India|Sanskrit|A lit lamp|C
Sandhya|संध्या|g|Hindu|Pan-India|Sanskrit|Twilight; evening|C
Sangat|संगत|u|Sikh|North|Punjabi|Holy company; congregation|R
Sangeeta|संगीता|g|Hindu|Pan-India|Sanskrit|Music|C
Sanghamitra|संघमित्रा|g|Buddhist|Pan-India|Sanskrit|Friend of the community; Ashoka's daughter|R
Sania|सानिया|g|Muslim|Pan-India|Arabic|Brilliant; radiant|C
Sanidhya|सानिध्य|b|Hindu|West|Sanskrit|Nearness; closeness to God|T
Sanika|सानिका|g|Hindu|West|Marathi|A flute|C
Sanjeev|संजीव|b|Hindu|Pan-India|Sanskrit|Giving life|C
Sankalp|संकल्प|b|Hindu|West|Sanskrit|Resolve; determination|C
Sanskar|संस्कार|b|Hindu|North|Sanskrit|Values; good upbringing|T
Santosh|संतोष|b|Hindu|Pan-India|Sanskrit|Contentment|C
Sanvi|सान्वी|g|Hindu|Pan-India|Sanskrit|Goddess Lakshmi|T
Sanyam|संयम|b|Jain|West|Sanskrit|Self restraint|C
Sapna|सपना|g|Hindu|North|Hindi|Dream|C
Saptarshi|सप्तर्षि|b|Hindu|East|Sanskrit|The seven sages; the Great Bear|C
Sarabjeet|सरबजीत|b|Sikh|North|Punjabi · Sanskrit|One who conquers all|C
Sarang|सारंग|b|Hindu|West|Sanskrit|A spotted deer; a raga|C
Saraswati|सरस्वती|g|Hindu|Pan-India|Sanskrit|Goddess of learning|C
Saravanan|शरवणन|b|Hindu|South|Tamil|Lord Murugan; born in the reed pond|C
Sarayu|सरयू|g|Hindu|North|Sanskrit|A sacred river of Ayodhya|C
Sarika|सारिका|g|Hindu|Pan-India|Sanskrit|A myna bird|C
Saroj|सरोज|g|Hindu|North|Sanskrit|Lotus|C
Sarvesh|सर्वेश|b|Hindu|Pan-India|Sanskrit|Lord of all|C
Sasank|शशांक|b|Hindu|South|Sanskrit|The moon|C
Sasmita|सस्मिता|g|Hindu|East|Sanskrit|Smiling|C
Satnam|सतनाम|b|Sikh|North|Punjabi|True name; God|C
Satpreet|सतप्रीत|u|Sikh|North|Punjabi|True love|C
Satvik|सात्विक|b|Hindu|Pan-India|Sanskrit|Pure; virtuous|T
Satyam|सत्यम|b|Hindu|Pan-India|Sanskrit|Truth|C
Saumya|सौम्य|u|Hindu|Pan-India|Sanskrit|Gentle; mild|C
Savita|सविता|g|Hindu|Pan-India|Sanskrit|The sun|C
Sayali|सायली|g|Hindu|West|Marathi|A white flower|C
Sebastian|सेबेस्टियन|b|Christian|Pan-India|Greek|Venerable; revered|C
Seema|सीमा|g|Hindu|Pan-India|Sanskrit|Boundary|C
Sehajpreet|सहजप्रीत|u|Sikh|North|Punjabi|Love with calm|T
Sejal|सेजल|g|Hindu|West|Gujarati|River water; pure|C
Selvi|सेल्वी|g|Hindu|South|Tamil|Prosperous girl|C
Sendhil|सेंदिल|b|Hindu|South|Tamil|Lord Murugan|R
Shaan|शान|b|Hindu|North|Hindi|Pride; dignity|T
Shabana|शबाना|g|Muslim|North|Persian|Of the night|C
Shabnam|शबनम|g|Muslim|North|Persian|Dew|C
Shadab|शादाब|b|Muslim|North|Persian|Green; fresh|C
Shahana|शहाना|g|Muslim|South|Persian|Royal; a raga|C
Shahid|शाहिद|b|Muslim|Pan-India|Arabic|Witness|C
Shahrukh|शाहरुख़|b|Parsi|West|Persian|Face of a king|C
Shahzad|शहज़ाद|b|Muslim|North|Persian|Prince|C
Shailaja|शैलजा|g|Hindu|Pan-India|Sanskrit|Daughter of the mountain; Parvati|C
Shailja|शैलजा|g|Hindu|North|Sanskrit|Daughter of the mountain|C
Shaily|शैली|g|Hindu|West|Sanskrit|Style|C
Shaista|शाइस्ता|g|Muslim|North|Persian|Polite; well behaved|C
Shaivi|शैवी|g|Hindu|Pan-India|Sanskrit|Of Lord Shiva; prosperity|T
Shakeel|शकील|b|Muslim|Pan-India|Arabic|Handsome; well formed|C
Shakti|शक्ति|g|Hindu|Pan-India|Sanskrit|Power; energy|C
Shalaka|शलाका|g|Hindu|West|Sanskrit|A thin stick; Goddess Parvati|C
Shalini|शालिनी|g|Hindu|Pan-India|Sanskrit|Modest|C
Shama|शमा|g|Muslim|North|Arabic|A candle; a flame|C
Shambhavi|शांभवी|g|Hindu|Pan-India|Sanskrit|Goddess Parvati|T
Shamim|शमीम|u|Muslim|North|Arabic|Fragrance|C
Shamit|शमित|b|Hindu|Pan-India|Sanskrit|Calm; peaceful|C
Shantanu|शांतनु|b|Hindu|Pan-India|Sanskrit|Wholesome; a king of the Mahabharata|C
Shanthi|शांति|g|Hindu|South|Sanskrit|Peace|C
Shantinath|शांतिनाथ|b|Jain|West|Sanskrit|Lord of peace; the sixteenth Tirthankara|R
Sharad|शरद|b|Hindu|West|Sanskrit|Autumn|C
Sharanya|शरण्या|g|Hindu|South|Sanskrit|One who gives refuge|T
Shardul|शार्दूल|b|Hindu|West|Sanskrit|A tiger|C
Sharmila|शर्मिला|g|Hindu|Pan-India|Sanskrit|Shy; modest|C
Sharmistha|शर्मिष्ठा|g|Hindu|East|Sanskrit|A queen of the Mahabharata|C
Sharon|शेरोन|g|Christian|Pan-India|Hebrew|A fertile plain|C
Shashank|शशांक|b|Hindu|Pan-India|Sanskrit|The moon|C
Shashi|शशि|u|Hindu|Pan-India|Sanskrit|The moon|C
Shashidhar|शशिधर|b|Hindu|South|Sanskrit|One who wears the moon; Shiva|C
Shaunak|शौनक|b|Hindu|West|Sanskrit|A wise sage|R
Shawn|शॉन|b|Christian|West|Hebrew|God is gracious|C
Shayan|शायान|b|Muslim|North|Persian|Worthy; deserving|T
Shazia|शाज़िया|g|Muslim|North|Persian|Fragrance; unique|C
Shekhar|शेखर|b|Hindu|Pan-India|Sanskrit|Crown; peak|C
Shibli|शिबली|b|Muslim|South|Arabic|Lion cub|C
Shikha|शिखा|g|Hindu|North|Sanskrit|Crest; flame|C
Shilpa|शिल्पा|g|Hindu|Pan-India|Sanskrit|Well proportioned; a carving|C
Shiny|शाइनी|g|Christian|South|English|Bright; shining|C
Shireen|शीरीन|g|Muslim|North|Persian|Sweet|C
Shirin|शीरीं|g|Parsi|West|Persian|Sweet|C
Shirish|शिरीष|b|Hindu|West|Sanskrit|A flowering tree|C
Shirley|शर्ली|g|Christian|Pan-India|English|Bright meadow|C
Shital|शीतल|u|Jain|West|Sanskrit|Cool; calm; a Tirthankara|C
Shivaay|शिवाय|b|Hindu|North|Sanskrit|Lord Shiva|T
Shivali|शिवाली|g|Hindu|Pan-India|Sanskrit|Beloved of Shiva|C
Shivam|शिवम|b|Hindu|North|Sanskrit|Auspicious; Lord Shiva|C
Shivangi|शिवांगी|g|Hindu|North|Sanskrit|A part of Shiva|C
Shivanya|शिवान्या|g|Hindu|Pan-India|Sanskrit|Of Lord Shiva|T
Shivika|शिविका|g|Hindu|Pan-India|Sanskrit|A palanquin|R
Shloka|श्लोका|g|Hindu|West|Sanskrit|A verse|T
Shlokesh|श्लोकेश|b|Hindu|Pan-India|Sanskrit|Lord of verses|R
Shoaib|शोएब|b|Muslim|Pan-India|Arabic|A prophet; one who guides|C
Shobha|शोभा|g|Hindu|Pan-India|Sanskrit|Splendour; beauty|C
Shrabani|श्राबणी|g|Hindu|East|Bengali · Sanskrit|Born in the month of Shravan|C
Shraddha|श्रद्धा|g|Hindu|Pan-India|Sanskrit|Faith; devotion|C
Shravani|श्रावणी|g|Hindu|West|Sanskrit|Born in the month of Shravan|C
Shrenik|श्रेणिक|b|Jain|West|Sanskrit|A king devoted to Mahavira|C
Shresth|श्रेष्ठ|b|Hindu|North|Sanskrit|The best|T
Shrey|श्रेय|b|Hindu|West|Sanskrit|Credit; merit|T
Shreyansh|श्रेयांश|b|Hindu|Pan-India|Sanskrit|Part of fame; one who brings good|T
Shreyas|श्रेयस|b|Hindu|West|Sanskrit|Excellent; the best|C
Shriya|श्रिया|g|Hindu|Pan-India|Sanskrit|Prosperity; Goddess Lakshmi|C
Shubh|शुभ|b|Hindu|North|Sanskrit|Auspicious|T
Shubham|शुभम|b|Hindu|North|Sanskrit|Auspicious|C
Shubhang|शुभांग|b|Hindu|Pan-India|Sanskrit|Handsome; Lord Shiva|R
Shubhankar|शुभंकर|b|Hindu|East|Sanskrit|One who does good|C
Shubhi|शुभी|g|Hindu|North|Sanskrit|Auspicious|T
Shweta|श्वेता|g|Hindu|Pan-India|Sanskrit|White; fair|C
Shyam|श्याम|b|Hindu|Pan-India|Sanskrit|Dark; Krishna|C
Shyamal|श्यामल|b|Hindu|East|Sanskrit|Dark; dusky|C
Siddhant|सिद्धांत|b|Hindu|Pan-India|Sanskrit|Principle|C
Siddhartha|सिद्धार्थ|b|Buddhist|Pan-India|Sanskrit|The Buddha's birth name; one who has reached his goal|C
Siddhesh|सिद्धेश|b|Hindu|West|Sanskrit|Lord of the perfected; Shiva|C
Sidra|सिदरा|g|Muslim|Pan-India|Arabic|A lote tree in paradise|T
Sifat|सिफ़त|g|Sikh|North|Punjabi · Arabic|Praise; quality|T
Simar|सिमर|g|Sikh|North|Punjabi|Remembrance of God|T
Simon|साइमन|b|Christian|Pan-India|Hebrew|He has heard|C
Sinchana|सिंचना|g|Hindu|South|Sanskrit|Sprinkling of water|T
Sivakami|शिवकामी|g|Hindu|South|Sanskrit|Goddess Parvati, beloved of Shiva|C
Smita|स्मिता|g|Hindu|Pan-India|Sanskrit|Smiling|C
Smriti|स्मृति|g|Hindu|Pan-India|Sanskrit|Memory|C
Snehal|स्नेहल|u|Hindu|West|Sanskrit|Loving; friendly|C
Snigdha|स्निग्धा|g|Hindu|East|Sanskrit|Gentle; smooth|C
Sohan|सोहन|b|Hindu|North|Sanskrit|Handsome; charming|C
Sohrab|सोहराब|b|Parsi|West|Persian|Illustrious; son of Rustom|C
Solomon|सोलोमन|b|Christian|Pan-India|Hebrew|Peace|C
Somnath|सोमनाथ|b|Hindu|East|Sanskrit|Lord of the moon; Shiva|C
Somya|सौम्या|g|Hindu|Pan-India|Sanskrit|Gentle; soft|C
Sonal|सोनल|g|Hindu|West|Hindi|Golden|C
Sonali|सोनाली|g|Hindu|West|Hindi|Golden|C
Sonam|सोनम|u|Buddhist|North|Tibetan|Fortunate; merit|C
Sophie|सोफ़ी|g|Christian|Pan-India|Greek|Wisdom|T
Soumya|सौम्य|b|Hindu|East|Sanskrit|Gentle; calm|C
Sparsh|स्पर्श|b|Hindu|North|Sanskrit|Touch|T
Srabanti|श्राबंती|g|Hindu|East|Bengali · Sanskrit|Born in the month of Shravan|C
Sravani|श्रावणी|g|Hindu|South|Sanskrit|Born in the month of Shravan|C
Sreehari|श्रीहरि|b|Hindu|South|Sanskrit|Lord Vishnu|C
Sreeja|श्रीजा|g|Hindu|South|Sanskrit|Born of Lakshmi|C
Sreejita|श्रीजिता|g|Hindu|East|Bengali · Sanskrit|Victorious|C
Sreelakshmi|श्रीलक्ष्मी|g|Hindu|South|Sanskrit|Goddess Lakshmi|C
Srikanth|श्रीकांत|b|Hindu|South|Sanskrit|Beloved of Lakshmi; Vishnu|C
Srinidhi|श्रीनिधि|u|Hindu|South|Sanskrit|Treasure of Lakshmi|C
Srishti|सृष्टि|g|Hindu|Pan-India|Sanskrit|Creation; the world|C
Sruthi|श्रुति|g|Hindu|South|Sanskrit|Musical pitch; the Vedas|C
Steffi|स्टेफ़ी|g|Christian|Pan-India|Greek|Crown|C
Stella|स्टेला|g|Christian|Pan-India|Latin|Star|C
Subhadra|सुभद्रा|g|Hindu|East|Sanskrit|Sister of Krishna; auspicious|C
Subhan|सुबहान|b|Muslim|Pan-India|Arabic|Glory be|C
Subhankar|शुभंकर|b|Hindu|East|Sanskrit|One who brings good|C
Subhash|सुभाष|b|Hindu|East|Sanskrit|Well spoken|C
Subhashree|सुभश्री|g|Hindu|East|Sanskrit|Auspicious|C
Subodh|सुबोध|b|Hindu|Pan-India|Sanskrit|Easy to understand; wise|C
Subramanian|सुब्रमणियन|b|Hindu|South|Sanskrit|Lord Murugan|C
Sudarshan|सुदर्शन|b|Hindu|Pan-India|Sanskrit|Good looking; the discus of Vishnu|C
Sudeep|सुदीप|b|Hindu|Pan-India|Sanskrit|Bright|C
Sudeshna|सुदेष्णा|g|Hindu|East|Sanskrit|A queen of the Mahabharata|C
Sudha|सुधा|g|Hindu|South|Sanskrit|Nectar|C
Sudhir|सुधीर|b|Hindu|Pan-India|Sanskrit|Wise; resolute|C
Sudiksha|सुदीक्षा|g|Hindu|North|Sanskrit|Good initiation|C
Sudip|सुदीप|b|Hindu|East|Sanskrit|Bright|C
Suhail|सुहैल|b|Muslim|Pan-India|Arabic|The star Canopus|C
Suhani|सुहानी|g|Hindu|North|Hindi|Pleasant; lovely|C
Suhas|सुहास|b|Hindu|South|Sanskrit|A pleasant smile|C
Suhasini|सुहासिनी|g|Hindu|South|Sanskrit|Always smiling|C
Sujata|सुजाता|g|Hindu|Pan-India|Sanskrit|Of a good family|C
Sujay|सुजय|b|Hindu|Pan-India|Sanskrit|Good victory|C
Sujith|सुजीत|b|Hindu|South|Sanskrit|Good victory|C
Sukanta|सुकांत|b|Hindu|East|Sanskrit|Handsome|C
Sukanya|सुकन्या|g|Hindu|Pan-India|Sanskrit|A good girl; daughter|C
Sukhbir|सुखबीर|b|Sikh|North|Punjabi · Sanskrit|Brave and at peace|C
Sukhdeep|सुखदीप|u|Sikh|North|Punjabi · Sanskrit|Lamp of peace|C
Sukhjeet|सुखजीत|u|Sikh|North|Punjabi · Sanskrit|Victory of peace|C
Sukhmani|सुखमनी|g|Sikh|North|Punjabi|Jewel of peace; a Sikh prayer|C
Sukhpreet|सुखप्रीत|g|Sikh|North|Punjabi · Sanskrit|One who finds joy in love|C
Sukhwinder|सुखविंदर|u|Sikh|North|Punjabi · Sanskrit|Lord of peace|C
Sukriti|सुकृति|g|Hindu|Pan-India|Sanskrit|Good deed|C
Sulekha|सुलेखा|g|Hindu|Pan-India|Sanskrit|Beautiful writing|C
Sultan|सुल्तान|b|Muslim|Pan-India|Arabic|King; ruler|C
Sultana|सुल्ताना|g|Muslim|Pan-India|Arabic|Queen|C
Suman|सुमन|g|Hindu|North|Sanskrit|Flower; good minded|C
Sumati|सुमति|g|Jain|West|Sanskrit|Good mind; the fifth Tirthankara|C
Sumedh|सुमेध|b|Hindu|West|Sanskrit|Wise; clever|C
Sumedha|सुमेधा|g|Hindu|Pan-India|Sanskrit|Wise; intelligent|C
Sumit|सुमित|b|Hindu|North|Sanskrit|A good friend|C
Sunanda|सुनंदा|g|Hindu|Pan-India|Sanskrit|Pleasing|C
Sunil|सुनील|b|Hindu|Pan-India|Sanskrit|Deep blue|C
Sunita|सुनीता|g|Hindu|Pan-India|Sanskrit|Well behaved|C
Sunny|सनी|b|Christian|Pan-India|English|Bright; cheerful|C
Supratim|सुप्रतिम|b|Hindu|East|Bengali · Sanskrit|Beautiful image|C
Supreet|सुप्रीत|g|Sikh|North|Punjabi|One who loves well|C
Supriya|सुप्रिया|g|Hindu|Pan-India|Sanskrit|Dearly loved|C
Suraj|सूरज|b|Hindu|Pan-India|Sanskrit|The sun|C
Surbhi|सुरभि|g|Hindu|North|Sanskrit|Fragrance; the divine cow|C
Surjeet|सुरजीत|b|Sikh|North|Punjabi · Sanskrit|Conqueror of the gods|C
Surya|सूर्य|b|Hindu|Pan-India|Sanskrit|The sun|C
Suryansh|सूर्यांश|b|Hindu|Pan-India|Sanskrit|A part of the sun|T
Susan|सूज़न|g|Christian|Pan-India|Hebrew|Lily|C
Sushant|सुशांत|b|Hindu|Pan-India|Sanskrit|Very calm|C
Sushanta|सुशांत|b|Hindu|East|Sanskrit|Very calm|C
Sushma|सुषमा|g|Hindu|Pan-India|Sanskrit|Exquisite beauty|C
Svara|स्वरा|g|Hindu|Pan-India|Sanskrit|A musical note|T
Swagata|स्वागता|g|Hindu|East|Sanskrit|Welcome|C
Swapnil|स्वप्निल|b|Hindu|West|Sanskrit|Dreamy; seen in a dream|C
Swathi|स्वाति|g|Hindu|South|Sanskrit|A star|C
Swati|स्वाति|g|Hindu|Pan-India|Sanskrit|A star|C
Syed|सैयद|b|Muslim|Pan-India|Arabic|Leader; master|C
Taanvi|तान्वी|g|Hindu|Pan-India|Sanskrit|Delicate; slender|T
Tabassum|तबस्सुम|g|Muslim|North|Arabic|Smile|C
Tahir|ताहिर|b|Muslim|Pan-India|Arabic|Pure; clean|C
Tahira|ताहिरा|g|Muslim|Pan-India|Arabic|Pure|C
Tajinder|तजिंदर|b|Sikh|North|Punjabi · Sanskrit|Lord of glory|C
Taksh|तक्ष|b|Hindu|Pan-India|Sanskrit|A son of Bharata; carpenter|T
Tamanna|तमन्ना|g|Muslim|North|Arabic|Wish; desire|C
Tamilselvi|तमिलसेल्वी|g|Hindu|South|Tamil|Treasure of Tamil|R
Tanay|तनय|b|Hindu|Pan-India|Sanskrit|Son|C
Tanima|तनिमा|g|Hindu|East|Sanskrit|Slender; delicate|C
Tanmoy|तन्मय|b|Hindu|East|Bengali · Sanskrit|Absorbed|C
Tanuja|तनुजा|g|Hindu|Pan-India|Sanskrit|Daughter|C
Tanushree|तनुश्री|g|Hindu|East|Sanskrit|Beautiful body|C
Tanveer|तनवीर|b|Muslim|North|Arabic|Enlightening; radiant|C
Tapas|तपस|b|Hindu|East|Sanskrit|Penance; heat|C
Taran|तरन|u|Sikh|North|Punjabi|One who carries across; a raft|C
Tarandeep|तरनदीप|u|Sikh|North|Punjabi · Sanskrit|Lamp that saves|C
Taranjot|तरनजोत|u|Sikh|North|Punjabi|Light that carries across|C
Tariq|तारिक़|b|Muslim|Pan-India|Arabic|The morning star|C
Tarun|तरुण|b|Hindu|Pan-India|Sanskrit|Young|C
Taruna|तरुणा|g|Hindu|North|Sanskrit|Young|C
Taruni|तरुणी|g|Hindu|Pan-India|Sanskrit|Young woman|C
Tashi|ताशी|u|Buddhist|North|Tibetan|Good fortune|C
Tasneem|तसनीम|g|Muslim|Pan-India|Arabic|A fountain in paradise|C
Tathagat|तथागत|b|Buddhist|Pan-India|Pali|The Buddha; one who has thus gone|R
Tathagata|तथागत|b|Hindu|East|Sanskrit|The Buddha|C
Taufiq|तौफ़ीक़|b|Muslim|Pan-India|Arabic|Divine help; success|C
Teerth|तीर्थ|b|Hindu|West|Sanskrit|A holy place|C
Tegveer|तेगवीर|b|Sikh|North|Punjabi · Persian|Brave with the sword|T
Tehmina|तहमीना|g|Parsi|West|Persian|Strong; mother of Sohrab|C
Teja|तेजा|b|Hindu|South|Sanskrit|Brilliance|C
Tejal|तेजल|g|Hindu|West|Sanskrit|Bright; lustrous|C
Tejasvi|तेजस्वी|u|Hindu|Pan-India|Sanskrit|Radiant; brilliant|T
Tejaswini|तेजस्विनी|g|Hindu|West|Sanskrit|Radiant; brilliant|C
Tejbir|तेजबीर|b|Sikh|North|Punjabi · Sanskrit|Brave and radiant|C
Tejpal|तेजपाल|b|Sikh|North|Punjabi · Sanskrit|Protector of glory|C
Tenzin|तेनज़िन|u|Buddhist|North|Tibetan|Holder of the teachings|C
Teresa|टेरेसा|g|Christian|Pan-India|Greek|Harvester|C
Tessa|टेसा|g|Christian|Pan-India|Greek|Harvester|T
Thamarai|तामरई|g|Hindu|South|Tamil|Lotus|R
Tharun|तरुण|b|Hindu|South|Sanskrit|Young|C
Thendral|तेंड्रल|g|Hindu|South|Tamil|A gentle breeze|R
Timothy|टिमोथी|b|Christian|Pan-India|Greek|Honouring God|C
Tithi|तिथि|g|Hindu|East|Sanskrit|A date of the lunar calendar|C
Tobias|टोबियास|b|Christian|Pan-India|Hebrew|God is good|R
Tony|टोनी|b|Christian|Pan-India|Latin|Priceless|C
Trilok|त्रिलोक|b|Hindu|North|Sanskrit|The three worlds|C
Tripti|तृप्ति|g|Hindu|North|Sanskrit|Contentment|C
Trishala|त्रिशला|g|Jain|West|Sanskrit|Mother of Mahavira|C
Trishna|तृष्णा|g|Hindu|Pan-India|Sanskrit|Thirst; desire|C
Trishul|त्रिशूल|b|Hindu|North|Sanskrit|Shiva's trident|R
Trupti|तृप्ति|g|Hindu|West|Sanskrit|Contentment|C
Tuhin|तुहिन|b|Hindu|East|Sanskrit|Snow; dew|C
Tulika|तूलिका|g|Hindu|Pan-India|Sanskrit|A painter's brush|C
Tushit|तुषित|b|Hindu|Pan-India|Sanskrit|Contented; a class of gods|R
Udayan|उदयन|b|Hindu|East|Sanskrit|Rising; an ancient king|C
Udit|उदित|b|Hindu|Pan-India|Sanskrit|Risen; awakened|C
Ujaan|उजान|b|Hindu|East|Bengali|Upstream; against the current|T
Ujjal|उज्जल|b|Sikh|North|Punjabi · Sanskrit|Bright; pure|C
Ujjwal|उज्ज्वल|b|Hindu|North|Sanskrit|Bright; shining|C
Ujjwala|उज्ज्वला|g|Hindu|West|Sanskrit|Bright|C
Umaima|उमैमा|g|Muslim|Pan-India|Arabic|Young mother|C
Umang|उमंग|b|Hindu|North|Sanskrit|Enthusiasm|C
Unnati|उन्नति|g|Hindu|North|Sanskrit|Progress|C
Upasana|उपासना|g|Hindu|Pan-India|Sanskrit|Worship|C
Upendra|उपेंद्र|b|Hindu|Pan-India|Sanskrit|Younger brother of Indra; Vishnu|C
Urmi|ऊर्मि|g|Hindu|East|Sanskrit|A wave|C
Urmila|उर्मिला|g|Hindu|Pan-India|Sanskrit|Wife of Lakshman; enchanting|C
Urvashi|उर्वशी|g|Hindu|West|Sanskrit|A celestial dancer|C
Usha|उषा|g|Hindu|Pan-India|Sanskrit|Dawn|C
Uzair|उज़ैर|b|Muslim|Pan-India|Arabic|A prophet; helper|C
Uzma|उज़मा|g|Muslim|Pan-India|Arabic|Greatest|C
Vaibhav|वैभव|b|Hindu|Pan-India|Sanskrit|Glory; riches|C
Vaidehi|वैदेही|g|Hindu|Pan-India|Sanskrit|Sita, princess of Videha|C
Vaigai|वैगई|g|Hindu|South|Tamil|A river of Tamil Nadu|R
Vaishali|वैशाली|g|Hindu|West|Sanskrit|An ancient city|C
Valentina|वेलेंटीना|g|Christian|Pan-India|Latin|Strong; healthy|R
Valli|वल्ली|g|Hindu|South|Tamil|A creeper; consort of Murugan|C
Vamsi|वंशी|b|Hindu|South|Sanskrit|Flute; Krishna|C
Vandana|वंदना|g|Hindu|Pan-India|Sanskrit|Worship; salutation|C
Vani|वाणी|g|Hindu|Pan-India|Sanskrit|Speech; Saraswati|C
Vardhaman|वर्धमान|b|Jain|Pan-India|Sanskrit|Ever growing; Mahavira's birth name|C
Vardhan|वर्धन|b|Hindu|Pan-India|Sanskrit|Growth; one who increases|C
Varenya|वरेण्य|u|Hindu|Pan-India|Sanskrit|Most excellent; worthy of choosing|R
Varghese|वर्गीज़|b|Christian|South|Greek|Farmer; George|C
Varsha|वर्षा|g|Hindu|Pan-India|Sanskrit|Rain|C
Vartika|वर्तिका|g|Hindu|North|Sanskrit|The wick of a lamp|C
Vasant|वसंत|b|Hindu|West|Sanskrit|Spring|C
Vasanthi|वसंती|g|Hindu|South|Sanskrit|Of spring|C
Vasavi|वासवी|g|Hindu|South|Sanskrit|Wife of Indra|C
Vasudev|वासुदेव|b|Hindu|Pan-India|Sanskrit|Father of Krishna; Krishna|C
Vasudha|वसुधा|g|Hindu|Pan-India|Sanskrit|The earth|C
Vatsal|वत्सल|b|Hindu|West|Sanskrit|Affectionate|C
Vatsala|वत्सला|g|Hindu|West|Sanskrit|Affectionate|C
Vedansh|वेदांश|b|Hindu|Pan-India|Sanskrit|A part of the Vedas|T
Vedanshi|वेदांशी|g|Hindu|Pan-India|Sanskrit|A part of the Vedas|T
Veer|वीर|b|Sikh|North|Punjabi · Sanskrit|Brave; brother|T
Veerpal|वीरपाल|u|Sikh|North|Punjabi · Sanskrit|Protector of the brave|C
Velan|वेलन|b|Hindu|South|Tamil|Lord Murugan, bearer of the spear|C
Venkatesh|वेंकटेश|b|Hindu|South|Sanskrit|Lord of Venkata hill; Vishnu|C
Veronica|वेरोनिका|g|Christian|Pan-India|Latin|True image|C
Vetri|वेट्रि|u|Hindu|South|Tamil|Victory|T
Vibha|विभा|g|Hindu|Pan-India|Sanskrit|Radiance|C
Victor|विक्टर|b|Christian|Pan-India|Latin|Winner|C
Victoria|विक्टोरिया|g|Christian|Pan-India|Latin|Victory|C
Vidhan|विधान|b|Jain|West|Sanskrit|Rule; order|C
Vidhi|विधि|g|Hindu|West|Sanskrit|Destiny; ritual|C
Vidur|विदुर|b|Hindu|North|Sanskrit|Wise; a sage of the Mahabharata|R
Vihaana|विहाना|g|Hindu|Pan-India|Sanskrit|Dawn; morning|T
Vijay|विजय|b|Hindu|Pan-India|Sanskrit|Victory|C
Vikas|विकास|b|Hindu|Pan-India|Sanskrit|Growth; progress|C
Vimal|विमल|b|Jain|West|Sanskrit|Pure; spotless|C
Vinay|विनय|b|Hindu|Pan-India|Sanskrit|Humility; good manners|C
Vinayak|विनायक|b|Hindu|West|Sanskrit|Lord Ganesha|C
Vineeta|विनीता|g|Hindu|Pan-India|Sanskrit|Humble|C
Vinit|विनीत|b|Hindu|Pan-India|Sanskrit|Humble; modest|C
Vinod|विनोद|b|Hindu|Pan-India|Sanskrit|Humour; joy|C
Vipul|विपुल|b|Hindu|West|Sanskrit|Abundant|C
Viraat|विराट|b|Hindu|North|Sanskrit|Huge; immense|T
Viral|विरल|b|Hindu|West|Sanskrit|Rare; precious|C
Viransh|वीरांश|b|Hindu|Pan-India|Sanskrit|A part of the brave|T
Vishakha|विशाखा|g|Hindu|West|Sanskrit|A star|C
Vishal|विशाल|b|Hindu|Pan-India|Sanskrit|Vast; large|C
Vishnu|विष्णु|b|Hindu|Pan-India|Sanskrit|Lord Vishnu, the preserver|C
Vishwas|विश्वास|b|Hindu|West|Sanskrit|Faith; trust|C
Vivek|विवेक|b|Hindu|Pan-India|Sanskrit|Wisdom; discernment|C
Vivian|विवियन|u|Christian|Pan-India|Latin|Lively|C
Vrushali|वृषाली|g|Hindu|West|Sanskrit|Wife of Karna|C
Vyom|व्योम|b|Hindu|Pan-India|Sanskrit|The sky|T
Wafa|वफ़ा|g|Muslim|Pan-India|Arabic|Faithfulness; loyalty|C
Wahid|वाहिद|b|Muslim|Pan-India|Arabic|One; unique|C
Waris|वारिस|b|Sikh|North|Punjabi · Arabic|Heir|C
Waseem|वसीम|b|Muslim|Pan-India|Arabic|Handsome; graceful|C
Wilson|विल्सन|b|Christian|South|English|Son of William|C
Winnie|विनी|g|Christian|South|Welsh|Fair; blessed|C
Xavier|ज़ेवियर|b|Christian|West|Basque|New house|C
Yadu|यदु|b|Hindu|South|Sanskrit|An ancestor of Krishna|R
Yahya|यह्या|b|Muslim|Pan-India|Arabic|The prophet John; alive|C
Yajat|यजत|b|Hindu|Pan-India|Sanskrit|Holy; Lord Shiva|R
Yamuna|यमुना|g|Hindu|Pan-India|Sanskrit|The holy river Yamuna|C
Yashas|यशस|b|Hindu|South|Sanskrit|Fame; success|T
Yashasvi|यशस्वी|u|Hindu|Pan-India|Sanskrit|Famous; successful|T
Yashika|यशिका|g|Hindu|Pan-India|Sanskrit|Success; fame|T
Yashoda|यशोदा|g|Hindu|Pan-India|Sanskrit|Mother of Krishna|C
Yashodhan|यशोधन|b|Hindu|West|Sanskrit|Rich in fame|C
Yashodhara|यशोधरा|g|Buddhist|Pan-India|Sanskrit|Bearer of glory; the Buddha's wife|C
Yashwant|यशवंत|b|Hindu|West|Sanskrit|Famous; glorious|C
Yasir|यासिर|b|Muslim|Pan-India|Arabic|Wealthy; easy going|C
Yasmin|यासमीन|g|Muslim|Pan-India|Persian|Jasmine|C
Yatharth|यथार्थ|b|Hindu|North|Sanskrit|Truth; reality|T
Yatin|यतिन|b|Hindu|Pan-India|Sanskrit|An ascetic|C
Yazad|यज़द|b|Parsi|West|Persian|Worthy of worship; God|R
Yazhan|याझन|b|Hindu|South|Tamil|Player of the yazh, an old harp|T
Yogendra|योगेंद्र|b|Hindu|North|Sanskrit|Lord of yoga|C
Yogesh|योगेश|b|Hindu|Pan-India|Sanskrit|Lord of yoga; Shiva|C
Yogini|योगिनी|g|Hindu|Pan-India|Sanskrit|One who practises yoga|R
Yogita|योगिता|g|Hindu|West|Sanskrit|Enchanted|C
Younus|यूनुस|b|Muslim|Pan-India|Arabic|The prophet Jonah; dove|C
Yudhishthir|युधिष्ठिर|b|Hindu|Pan-India|Sanskrit|Steady in battle; the eldest Pandava|R
Yug|युग|b|Hindu|West|Sanskrit|An age; an era|T
Yukti|युक्ति|g|Hindu|North|Sanskrit|Skill; idea|C
Yuvansh|युवांश|b|Hindu|Pan-India|Sanskrit|A youthful part|T
Zachary|ज़ैकरी|b|Christian|Pan-India|Hebrew|God remembers|C
Zaheer|ज़हीर|b|Muslim|Pan-India|Arabic|Helper; supporter|C
Zaid|ज़ैद|b|Muslim|Pan-India|Arabic|Growth; abundance|C
Zainab|ज़ैनब|g|Muslim|Pan-India|Arabic|A fragrant plant; daughter of the Prophet|C
Zaira|ज़ायरा|g|Muslim|Pan-India|Arabic|Visitor; rose|T
Zakia|ज़ाकिया|g|Muslim|Pan-India|Arabic|Pure; intelligent|C
Zakir|ज़ाकिर|b|Muslim|Pan-India|Arabic|One who remembers God|C
Zalak|झलक|g|Hindu|West|Gujarati · Hindi|A glimpse|C
Zarina|ज़रीना|g|Muslim|North|Persian|Golden|C
Zarir|ज़रीर|b|Parsi|West|Persian|Golden|R
Zayn|ज़ैन|b|Muslim|Pan-India|Arabic|Beauty; grace|T
Zeel|झील|g|Hindu|West|Hindi|A lake|C
Zeenat|ज़ीनत|g|Muslim|North|Arabic|Beauty; adornment|C
Zeeshan|ज़ीशान|b|Muslim|North|Arabic · Persian|Of high rank; dignified|C
Zikra|ज़िकरा|g|Muslim|Pan-India|Arabic|Remembrance|T
Zoe|ज़ोई|g|Christian|Pan-India|Greek|Life|T
Zohra|ज़ोहरा|g|Muslim|North|Arabic|Venus; brilliant|C
Zorawar|ज़ोरावर|b|Sikh|North|Punjabi · Persian|Brave; powerful|T
Zubaida|ज़ुबैदा|g|Muslim|Pan-India|Arabic|Excellent; the best part|C
Zubin|ज़ुबिन|b|Parsi|West|Persian|Honour; a spear|C
Zuha|ज़ुहा|g|Muslim|Pan-India|Arabic|Morning light|T
Zulfiqar|ज़ुल्फ़िक़ार|b|Muslim|Pan-India|Arabic|The sword of Ali|C
Zunaira|ज़ुनैरा|g|Muslim|Pan-India|Arabic|A flower of paradise|T
''';
