// =============================================================================
//  Spiritual Reading — seed content (a gentle, surface-level testing feature)
// -----------------------------------------------------------------------------
//  A respectful, neutral look at how a few faith traditions approach calm,
//  gratitude, family and motherhood — shared for comfort and curiosity, NOT as
//  religious instruction, and with no intent to promote any one belief.
//
//  IMPORTANT: every reflection below is ORIGINAL, written in plain words. No
//  scripture, verse, prayer, mantra, hymn or copyrighted translation is quoted
//  or paraphrased — only general themes are described and reflected on gently.
//
//  Organised by TRADITION → SECTION (sub-heading) → READS. Seeded with ~20 reads
//  per tradition; designed to scale (add reads to a section, or sections to a
//  tradition, and the tool's "View all" + sub-headings absorb them).
// =============================================================================

class SpiritualRead {
  const SpiritualRead({required this.title, required this.body});
  final String title;
  final String body;
}

class SpiritualSection {
  const SpiritualSection({required this.title, required this.reads});
  final String title;
  final List<SpiritualRead> reads;
}

class SpiritualTradition {
  const SpiritualTradition({
    required this.id,
    required this.name,
    required this.symbol,
    required this.blurb,
    required this.sections,
  });
  final String id;
  final String name;
  final String symbol; // a neutral faith symbol (emoji)
  final String blurb;
  final List<SpiritualSection> sections;

  int get readCount =>
      sections.fold(0, (n, sec) => n + sec.reads.length);

  /// A flat preview (first reads across the sections) for the tool's main card.
  List<SpiritualRead> preview(int n) {
    final out = <SpiritualRead>[];
    for (final sec in sections) {
      for (final r in sec.reads) {
        out.add(r);
        if (out.length >= n) return out;
      }
    }
    return out;
  }
}

const List<SpiritualTradition> kSpiritualTraditions = [
  // ===========================================================================
  //  HINDUISM
  // ===========================================================================
  SpiritualTradition(
    id: 'hindu',
    name: 'Hinduism',
    symbol: '🕉️',
    blurb: 'Nurturing the bond, calm and blessing.',
    sections: [
      SpiritualSection(title: 'Reflections inspired by the Gita', reads: [
        SpiritualRead(
            title: 'Do your part, gently',
            body:
                "One idea many people draw from the Gita is to focus on doing your part with care, and to worry less about the outcome you can't fully control. In pregnancy that can be freeing: you nourish yourself, rest, and show up each day, and you let the rest unfold. It is a quiet kind of trust."),
        SpiritualRead(
            title: 'A steady mind',
            body:
                "A calm, steady mind is treasured in this tradition, not as something you force, but as something you return to again and again. When worries rise, you can simply notice them and come back to your breath. Your baby shares in that steadiness."),
        SpiritualRead(
            title: 'Love without keeping score',
            body:
                "Acting out of love, rather than for reward, is a thread that runs through this teaching. The care you are already giving your baby, unseen and unthanked, is exactly this kind of love. It asks for nothing back."),
        SpiritualRead(
            title: 'The calm that is already yours',
            body:
                "Much of this wisdom points inward: the peace you are looking for is often already within you, under the noise of the day. A few quiet minutes, hand on your bump, can be enough to find it again."),
        SpiritualRead(
            title: 'Plant the seed, trust the season',
            body:
                "A gentle lesson here is to tend what is in your hands and let time do the rest, the way a gardener plants and then waits. You are doing the tending now, day by day; the growing is not yours to rush."),
        SpiritualRead(
            title: 'Your effort is enough',
            body:
                "This teaching values wholehearted effort over a perfect result. On the days you simply eat well, rest, and get through, that is not 'not enough' — that is exactly the work."),
        SpiritualRead(
            title: 'Let the worry pass through',
            body:
                "Thoughts and fears are seen as visitors, not residents; they arrive and, if you let them, they leave. You can notice a worry, breathe, and watch it move on without making it your home."),
        SpiritualRead(
            title: 'Devotion in small acts',
            body:
                "Even ordinary actions can become a kind of devotion when done with love and attention. Pouring that love into the small care you give yourself and your baby turns a quiet day into something tender."),
        SpiritualRead(
            title: 'Being, before doing',
            body:
                "Underneath all the doing, this wisdom points to simply being, resting in the calm that does not depend on getting things done. A few still minutes remind you that you are already enough, exactly as you are."),
        SpiritualRead(
            title: 'Even days, uneven days',
            body:
                "An idea often drawn from the Gita is to meet the good days and the hard days with the same steady heart. Some days you will glow and some you will ache; both are part of the journey, and neither is the whole of it."),
        SpiritualRead(
            title: 'The quiet witness',
            body:
                "There is a calm part of you that can simply watch your feelings rise and fall, like watching clouds cross the sky. Returning to that watcher, even for a moment, gives the storms less power over you."),
        SpiritualRead(
            title: 'Each day, an offering',
            body:
                "You can think of a day not as a task to finish but as something to offer, given gently and with care. Even a slow, tired day offered with love is complete in itself."),
        SpiritualRead(
            title: 'Strength that stays gentle',
            body:
                "True strength here is not hardness but a soft, unshakeable steadiness. The way you are carrying so much while still being tender is exactly this kind of quiet power."),
        SpiritualRead(
            title: 'You are more than the tiredness',
            body:
                "This wisdom reminds us that we are more than our passing states, more than any one heavy day. The exhaustion is real, but it is weather, not who you are."),
        SpiritualRead(
            title: 'Faith, a little bigger than fear',
            body:
                "Where fear says 'what if it goes wrong', this teaching gently answers with trust that you are held and that you will meet what comes. You do not have to feel fearless, only to let faith be a little bigger than the fear."),
        SpiritualRead(
            title: 'Love that serves',
            body:
                "Caring for another without thought of reward is treasured here, and it is exactly what you are already doing. Every unseen sacrifice for your baby is this kind of quiet, selfless love."),
        SpiritualRead(
            title: 'Make your mind a friend',
            body:
                "The mind can be a kind companion or a harsh critic, and much of this wisdom is about choosing the friendlier voice. Speak to yourself the way you would speak to someone you love who is growing a baby."),
        SpiritualRead(
            title: 'Hold the reins loosely',
            body:
                "You can do your best and still hold the outcome with open hands, releasing what was never yours to control. There is a deep relief in that letting-go, especially in the parts of pregnancy you cannot steer."),
        SpiritualRead(
            title: 'A purpose held lightly',
            body:
                "Having a sense of purpose matters, but holding it lightly keeps it from becoming a burden. Your purpose right now is simply, beautifully, to nurture and to wait."),
        SpiritualRead(
            title: 'The light you already carry',
            body:
                "A recurring image is of an inner light that no worry can put out, steady beneath the surface. On the dim days, it is still there; you are still carrying it, and so is your baby."),
      ]),
      SpiritualSection(title: 'Ramayan stories, simply retold', reads: [
        SpiritualRead(
            title: 'A bond that travels any distance',
            body:
                "One much-loved story tells of unwavering devotion, a loyal heart that will cross any distance for the people it loves. Retold simply, it is a reminder of how fiercely we can love, and how that love carries us through hard stretches. You already know that love."),
        SpiritualRead(
            title: 'Patience through the hard stretch',
            body:
                "Many of these stories dwell on patience through long, difficult seasons, and the quiet strength it takes to keep going. Pregnancy has its own long stretches. The stories whisper that steadiness, in time, is its own reward."),
        SpiritualRead(
            title: 'The joy of homecoming',
            body:
                "These tales often end in a joyful return, lamps lit and a family made whole again. It is a lovely image to hold onto: the day your little one finally arrives, and your own homecoming into motherhood."),
        SpiritualRead(
            title: 'Family as a circle of care',
            body:
                "Running through these stories is the idea of family as a circle that protects and uplifts one another. As you prepare to grow your own circle, it is a gentle nudge to lean on the people around you."),
        SpiritualRead(
            title: 'A promise kept',
            body:
                "One thread in these tales is the weight of a promise kept, even when it costs dearly, because one's word is treated as sacred. There is quiet dignity in that, and a reminder that the gentle promises you are already making to your baby matter deeply."),
        SpiritualRead(
            title: 'The bridge of small stones',
            body:
                "A famous episode tells of a great bridge built across the sea, small stone by small stone, by many willing hands. It is a beautiful image for these months: an enormous thing being built slowly, by small daily acts of love."),
        SpiritualRead(
            title: 'Courage in a small frame',
            body:
                "Some of the most loved figures in these stories are humble and small, yet carry astonishing courage and devotion. It is a comfort that strength is not about size, and that your quiet, steady love is a mighty thing."),
        SpiritualRead(
            title: 'The long road home',
            body:
                "Many of these stories are, at heart, about a long separation and a joyful return home. You are on your own long road toward meeting your baby, and the homecoming at the end of it will be worth every mile."),
        SpiritualRead(
            title: 'Loyalty that does not waver',
            body:
                "Unshakeable loyalty, standing by loved ones through every hardship, runs through these tales. It mirrors the fierce, unwavering bond already forming between you and the little one you have not yet met."),
        SpiritualRead(
            title: 'Choosing the harder right',
            body:
                "Again and again, characters choose the harder right thing over the easier wrong one. As you step into parenthood, those small honest choices, made with love, become the ground your child will stand on."),
        SpiritualRead(
            title: 'Hope in a quiet garden',
            body:
                "In one part of the story, hope is kept alive through a long, lonely wait in a faraway garden. It is a tender reminder that even in slow, hard stretches, hope can be quietly tended and kept warm."),
        SpiritualRead(
            title: 'Standing together',
            body:
                "Bonds between brothers and companions, choosing to share each other's burdens, shine through these stories. As your family grows, it is a gentle nudge to let the people who love you carry some of the weight with you."),
        SpiritualRead(
            title: 'Strength offered in service',
            body:
                "Some characters find their greatest strength simply in serving the people they love, asking nothing back. The care you are giving now, unseen and tireless, is that same quiet strength."),
        SpiritualRead(
            title: 'Grace in the simple years',
            body:
                "A long stretch of the story unfolds in the forest, in a plainer, simpler life, and grace is found even there. It is a kind reminder that the slow, quiet seasons of pregnancy can hold their own gentle beauty."),
        SpiritualRead(
            title: 'Held in the heart',
            body:
                "Devotion in these tales is often shown as simply holding a loved one in your heart, no matter the distance. You are already doing this, carrying your baby not only in your body, but in your heart, all day long."),
        SpiritualRead(
            title: 'Going beyond what was asked',
            body:
                "In one beloved moment, a devoted helper, asked to bring one small thing, lovingly brings far more than needed. Love does that, it overflows the task, and you will feel it overflow when you meet your child."),
        SpiritualRead(
            title: 'A light that leads the way',
            body:
                "Faith in these stories is often a steady light that guides through dark and uncertain paths. On the uncertain nights of pregnancy, you can let your own quiet faith be that small, leading light."),
        SpiritualRead(
            title: 'A family made whole',
            body:
                "The story's heart is a family torn apart and lovingly made whole again. Soon your own family will gain a new member, and a wholeness you have been waiting for will arrive."),
        SpiritualRead(
            title: 'Gentleness is not weakness',
            body:
                "Many of the most admired figures pair great strength with great gentleness. It is a lovely model for motherhood, where tenderness and strength turn out to be the very same thing."),
        SpiritualRead(
            title: 'Keeping the lamp lit',
            body:
                "Through long, dark passages of these tales, someone always keeps a small lamp of hope burning. Whatever this stretch of your journey feels like, you can keep your own lamp lit, one day at a time."),
      ]),
      SpiritualSection(title: 'The meaning behind common mantras', reads: [
        SpiritualRead(
            title: 'The calm of a single sound',
            body:
                "The sound often written as 'Om' is described by many as a gentle hum, a way to settle the mind and breath. You do not need to chant anything; simply breathing slowly and evenly can bring the same quiet that your baby feels too."),
        SpiritualRead(
            title: 'A wish for peace',
            body:
                "Many simple chants are, at heart, just a repeated wish for peace, for yourself, your family, and all beings. You can make that wish in your own words, in any language, and it counts all the same."),
        SpiritualRead(
            title: 'Light over darkness',
            body:
                "A recurring idea is moving from darkness toward light, from worry toward clarity and hope. Lighting a small lamp, or simply turning your thoughts to something hopeful, echoes that gentle intention."),
        SpiritualRead(
            title: 'Gratitude as a daily note',
            body:
                "Underneath much of this is gratitude, pausing to be thankful for the ordinary good in a day. A single grateful thought before sleep is a small, real practice anyone can keep."),
        SpiritualRead(
            title: 'Repetition that soothes',
            body:
                "Much of the calm in chanting comes simply from gentle repetition, the way a soft, repeated sound settles a restless mind. You can find the same ease in any phrase you love, said slowly a few times over."),
        SpiritualRead(
            title: 'An anchor word',
            body:
                "Many chants give the mind a single word to return to whenever it wanders. Choosing your own quiet word, 'calm', 'safe', 'love', and coming back to it can steady a racing afternoon."),
        SpiritualRead(
            title: 'Breath as the simplest chant',
            body:
                "Before any words, there is the breath, and slow even breathing is itself a kind of wordless mantra. Lengthening your out-breath a little is one of the gentlest ways to share calm with your baby."),
        SpiritualRead(
            title: 'A wish for all to be well',
            body:
                "At their core, many chants are a wide, open wish for peace and wellbeing for everyone. Sending that kind thought out, to your family, your baby, yourself, is a small, warm practice anyone can keep."),
        SpiritualRead(
            title: 'Protection, wished gently',
            body:
                "Some chants carry the feeling of wrapping a loved one in protection and good will. Whatever your beliefs, silently wishing your baby safety and warmth is a tender thing to do."),
        SpiritualRead(
            title: 'The heart over the syllables',
            body:
                "It is widely felt that the sincerity behind a chant matters far more than getting the sounds exactly right. So you can let go of doing it 'properly' and simply mean what you say."),
        SpiritualRead(
            title: 'A wish for healing',
            body:
                "Many gentle chants hold the hope of healing and ease for body and mind. Resting a hand on your bump and quietly wishing comfort for both of you carries that same intention."),
        SpiritualRead(
            title: 'Naming your thanks',
            body:
                "Some find that softly naming what they are grateful for works like a mantra of its own. 'Thank you for this kick, this day, this little life' is a chant the heart understands."),
        SpiritualRead(
            title: 'A hum your baby feels',
            body:
                "A low, steady hum can be felt as much as heard, and your baby is close enough to feel the gentle vibration of your voice. Humming a tune you love is a simple, lovely way to be near."),
        SpiritualRead(
            title: 'Steadiness in rhythm',
            body:
                "Part of why rhythmic sound calms us is that a steady beat tells the body it is safe to settle. Rocking gently, breathing in time, or repeating a soft phrase all tap into that same steadiness."),
        SpiritualRead(
            title: 'A small prayer for safe arrival',
            body:
                "Many quietly repeat a short wish for a safe and gentle birth. You can shape your own, just a sentence, and return to it whenever worry about the day ahead creeps in."),
        SpiritualRead(
            title: 'Releasing on the out-breath',
            body:
                "A simple practice is to let each out-breath carry a little tension away with it. You might silently say 'I let this go' as you exhale, softening your shoulders and your mind."),
        SpiritualRead(
            title: 'Calling on quiet courage',
            body:
                "Some chants are meant to gather courage before something hard. Before a scan or an appointment, a few slow breaths and a steadying word of your own can do the same."),
        SpiritualRead(
            title: 'Welcoming ease',
            body:
                "Other gentle chants are about inviting ease and abundance into one's life. You might simply, sincerely, invite ease into these months, into your body, your home, your heart."),
        SpiritualRead(
            title: 'Quiet over volume',
            body:
                "It is the stillness a chant creates, not its loudness, that does the soothing. Even a single word said almost silently, with full attention, can settle you."),
        SpiritualRead(
            title: 'Your own words always count',
            body:
                "There is no special language required for any of this; a heartfelt wish in your own tongue is just as real. Speak to your baby, or to the quiet, however feels natural to you."),
      ]),
      SpiritualSection(title: 'Festivals & rituals', reads: [
        SpiritualRead(
            title: 'A gathering to bless the mother',
            body:
                "Families often hold a warm gathering in later pregnancy to bless and pamper the mother-to-be, with sweets, bangles and good wishes all around. Beyond the ritual, it is a way of saying: you are loved, and you are not doing this alone."),
        SpiritualRead(
            title: 'Lighting a lamp',
            body:
                "A small lit lamp is a tender symbol across many homes, standing for warmth, hope and a fresh beginning. Lighting one as you think of your baby can be a quiet, grounding moment in a busy day."),
        SpiritualRead(
            title: 'A protective thread',
            body:
                "Tying a simple thread as a gesture of protection and good wishes is a familiar custom. Whatever you believe, the intention behind it, to keep someone safe and loved, is a beautiful one to carry."),
        SpiritualRead(
            title: 'Auspicious beginnings',
            body:
                "Many traditions mark beginnings with care and good wishes, in the hope that what starts well grows well. Your pregnancy is one of life's biggest beginnings; treating it gently honours that."),
        SpiritualRead(
            title: 'The blessing of being pampered',
            body:
                "In many homes, late pregnancy brings a celebration where the mother is gently pampered and showered with blessings. Letting yourself be cared for like this is not indulgence; it is part of the tradition, and you deserve it."),
        SpiritualRead(
            title: 'Sweetness, shared',
            body:
                "Sweets are offered at happy beginnings as a wish that the life ahead will be sweet too. Sharing something sweet with the people you love is a small, joyful way to mark this season."),
        SpiritualRead(
            title: 'Bangles and good wishes',
            body:
                "Gifts like bangles, given to an expectant mother, carry warmth and well-wishing in a simple, beautiful form. Each one is really a loved one saying, 'I am thinking of you and your baby.'"),
        SpiritualRead(
            title: 'Lights as a fresh start',
            body:
                "Festivals of light celebrate the turning from darkness toward hope and new beginnings. Your pregnancy is its own festival of light, a small new life arriving to brighten your world."),
        SpiritualRead(
            title: 'Marking the months',
            body:
                "Many families mark each stage of pregnancy with a small ritual or a shared moment. You might create your own gentle ritual, a candle, a note, a photo, to honour each month as it passes."),
        SpiritualRead(
            title: 'A blessing for the road ahead',
            body:
                "Some customs are simply a way of asking for protection and good fortune for the months to come. Whatever form it takes, being blessed and wished well is a lovely thing to carry into birth."),
        SpiritualRead(
            title: 'Welcoming over the threshold',
            body:
                "Welcoming customs greet a new arrival warmly as they cross into the family home. You are already preparing that welcome, in your heart and in the little corner you are making ready."),
        SpiritualRead(
            title: 'First foods, in time',
            body:
                "Later there will be small ceremonies for a baby's first taste of solid food, full of joy and good wishes. For now, the nourishing food you eat is its own quiet first gift to your child."),
        SpiritualRead(
            title: 'The meaning under the custom',
            body:
                "Behind most rituals is a simple, loving intention, to protect, to bless, to give thanks. You can keep the meaning even where the form does not fit your life: just hold the loving wish."),
        SpiritualRead(
            title: 'A community that shows up',
            body:
                "Festivals and ceremonies gather people together, so no one carries joy or hardship alone. Letting your own community gather around you now is part of that same gift."),
        SpiritualRead(
            title: 'Colours of joy',
            body:
                "Bright colours, flowers and decoration are used to mark glad occasions and lift the heart. Bringing a little colour and beauty into your days can be its own small celebration of this time."),
        SpiritualRead(
            title: 'The blessings of elders',
            body:
                "The good wishes of grandparents and elders are treasured at every milestone. Their blessings, spoken or simply felt, wrap your baby in a love that stretches back through generations."),
        SpiritualRead(
            title: 'A name chosen with love',
            body:
                "Choosing a baby's name is often a small ceremony of its own, full of meaning and hope. As you turn names over in your mind, you are already beginning that loving ritual."),
        SpiritualRead(
            title: 'Hopes tied into a thread',
            body:
                "Tying a thread or token is a simple way of binding good wishes and protection to someone you love. You might tie your own quiet hopes to a small keepsake for your baby."),
        SpiritualRead(
            title: 'Gratitude at harvest',
            body:
                "Harvest festivals are, at heart, a thank-you for what has grown and been given. In your own way, you might pause to give thanks for the little life growing within you."),
        SpiritualRead(
            title: 'Making room for joy',
            body:
                "Rituals carve out time to simply stop and celebrate, instead of rushing past the good. Letting yourself fully feel the joy of this season, even briefly, is a ritual worth keeping."),
      ]),
      SpiritualSection(title: 'Calm & wellbeing', reads: [
        SpiritualRead(
            title: 'Sharing your calm',
            body:
                "A central idea in Garbh Sanskar is that a mother's calm is quietly shared with her baby. So caring for your own peace, with music you love, slow breaths, a little rest, is also caring for your little one."),
        SpiritualRead(
            title: 'Warm food, gentle rhythm',
            body:
                "Drawing on Ayurveda, this tradition leans toward warm, nourishing, easy-to-digest food and an unhurried daily rhythm. The aim is balance, a settled body and a settled mind."),
        SpiritualRead(
            title: 'Talking and singing to your bump',
            body:
                "Singing or speaking softly to your baby is a loved practice, and your baby really can hear you now. A few minutes a day begins a bond that continues long after birth."),
        SpiritualRead(
            title: 'Rest is not laziness',
            body:
                "This wisdom treats rest as part of the work of growing a baby, not a break from it. When your body asks you to slow down, it is okay, even wise, to listen."),
        SpiritualRead(
            title: 'Music for two',
            body:
                "Soft, soothing music is treasured here for the calm it brings the mother, and that calm reaches the baby too. A favourite gentle song, played often, can become a comfort your little one recognises after birth."),
        SpiritualRead(
            title: 'A slow morning',
            body:
                "An unhurried start to the day is treated as good medicine for body and mind. Even ten quiet minutes before the rush, breath, warmth, a hand on your bump, can set a gentler tone for everything after."),
        SpiritualRead(
            title: 'Eating with love',
            body:
                "There is a belief that how you eat matters as much as what you eat, that food given with calm and care nourishes more deeply. Sitting down, slowing down, and eating warm food with gratitude turns a meal into self-care."),
        SpiritualRead(
            title: 'One kind thought',
            body:
                "This tradition gently holds that a mother's loving, hopeful thoughts are felt by her baby. You do not need a perfectly positive mind, just to offer your little one one warm thought a day."),
        SpiritualRead(
            title: 'Gentle movement',
            body:
                "Soft movement, a slow walk, easy stretches, gentle prenatal yoga, is encouraged to keep body and mind at ease. The aim is not effort but flow, moving in a way that feels kind to you."),
        SpiritualRead(
            title: 'A little time in nature',
            body:
                "Time among trees, sky and fresh air has long been seen as quietly healing. Even sitting by a window in the light counts; let nature do some of the soothing for you."),
        SpiritualRead(
            title: 'Guarding your peace',
            body:
                "Because a mother's calm is shared with her baby, protecting that peace is treated as worthwhile, even necessary. It is okay to step back from noise, news or people that unsettle you right now."),
        SpiritualRead(
            title: 'Winding down for sleep',
            body:
                "A gentle, predictable wind-down helps both body and mind settle for rest. Dimming the lights, a warm drink, a few slow breaths, these small signals tell you it is safe to let go."),
        SpiritualRead(
            title: 'Breathing room',
            body:
                "Slow, deep breathing is one of the simplest tools this wisdom offers, calming the body almost at once. A few long breaths, whenever you remember, are a gift you can give yourself anywhere."),
        SpiritualRead(
            title: 'Surround yourself with softness',
            body:
                "Soft sounds, soft light, soft words, this tradition leans toward gentleness in your surroundings. Curating a little softness around you is a quiet way of caring for two."),
        SpiritualRead(
            title: 'Less, but kinder',
            body:
                "Wellbeing here is less about doing more and more about doing things gently. Trimming your days down to what truly matters, done with care, is its own kind of nourishment."),
        SpiritualRead(
            title: 'Calm is contagious',
            body:
                "Just as tension can spread, so can calm, and your settled heart can settle your baby. Tending your own peace is therefore one of the most loving things you can do for your child."),
        SpiritualRead(
            title: 'A small joy each day',
            body:
                "Building in one small, sure joy a day, a warm bath, a favourite tea, a song, keeps the heart light through a long season. These little pleasures are not extras; they are part of staying well."),
        SpiritualRead(
            title: 'Closing the day with thanks',
            body:
                "Ending the day by recalling one good thing settles the mind for sleep and softens the worries. A single grateful thought, hand on your bump, is a lovely way to say goodnight to your baby."),
        SpiritualRead(
            title: 'Permission to slow down',
            body:
                "This wisdom treats slowing down not as falling behind but as moving at the right pace for growing a baby. Give yourself full permission to rest; it is exactly what this season asks of you."),
        SpiritualRead(
            title: 'Tending the inner garden',
            body:
                "Caring for your inner world, your thoughts and feelings, is seen as tending a garden your baby will grow in. Be patient and kind with that garden; weeds and all, it is doing beautifully."),
      ]),
    ],
  ),

  // ===========================================================================
  //  ISLAM
  // ===========================================================================
  SpiritualTradition(
    id: 'islam',
    name: 'Islam',
    symbol: '☪️',
    blurb: 'Gratitude, gentle care for the mother, heartfelt prayer.',
    sections: [
      SpiritualSection(title: 'Gratitude & heartfelt prayer', reads: [
        SpiritualRead(
            title: 'A trust to be grateful for',
            body:
                "Pregnancy is often received as a gift and a trust, something precious placed in your care. Pausing to feel grateful, even on a tired day, can soften the worry and steady the heart."),
        SpiritualRead(
            title: 'Praying in your own words',
            body:
                "Heartfelt prayer does not need to be formal; many simply speak to God from the heart, asking for a healthy baby and a safe delivery. Whatever words come to you, said sincerely, are enough."),
        SpiritualRead(
            title: 'Patience as strength',
            body:
                "Patience through discomfort and waiting is deeply valued, and seen as a quiet strength rather than weakness. The long days are not wasted; they are part of what you are building."),
        SpiritualRead(
            title: 'Hope after hardship',
            body:
                "A reassuring idea is that ease tends to follow hardship, that hard stretches do not last forever. Holding gently to that hope can carry you through the heavier days."),
        SpiritualRead(
            title: 'Small thanks, often',
            body:
                "Gratitude is encouraged not as a grand gesture but as a habit, small thanks given often. A whispered thank-you for a kick, a meal, a good scan, all add up."),
        SpiritualRead(
            title: 'Thanking your body',
            body:
                "Your body is quietly working day and night to grow your baby, and that is worth a moment of thanks. Even when it aches, you can rest a hand where it hurts and gently thank it for carrying on."),
        SpiritualRead(
            title: 'A prayer to begin the day',
            body:
                "Some like to start the morning with a few heartfelt words, asking for ease and strength for the hours ahead. It need only be a breath and a sentence, offered before the day rushes in."),
        SpiritualRead(
            title: 'A prayer to close the day',
            body:
                "Ending the day with a quiet word of thanks settles the heart for rest. You might simply name one good thing and hand the rest of your worries over for the night."),
        SpiritualRead(
            title: 'Turning worry into a wish',
            body:
                "When anxiety rises, it can help to turn it gently into a prayer, a wish for safety rather than a loop of fear. The worry becomes something you place in kinder hands."),
        SpiritualRead(
            title: 'Grateful for the first flutters',
            body:
                "The first small movements are an easy thing to give thanks for, a quiet hello from your baby. Pausing to notice them turns an ordinary moment into a small blessing."),
        SpiritualRead(
            title: 'Thankful for the helpers',
            body:
                "Gratitude naturally widens to include the people who care for you, the ones who cook, drive, and check in. A silent thank-you for them is part of a grateful heart."),
        SpiritualRead(
            title: 'A heart at ease',
            body:
                "It is often felt that a grateful heart is a calmer one, less gripped by what is missing. Counting what is good, even briefly, can loosen the hold of a hard day."),
        SpiritualRead(
            title: 'Asking for a gentle birth',
            body:
                "Many quietly ask for a safe and gentle arrival, returning to that hope whenever the day ahead feels daunting. Shaping your own short wish for it can be steadying."),
        SpiritualRead(
            title: 'Thanks for ordinary days',
            body:
                "Not every day needs a milestone to be worth gratitude; an ordinary, uneventful day is itself a gift in pregnancy. A calm day is a good day, and worth a quiet thank-you."),
        SpiritualRead(
            title: 'Prayer in your own language',
            body:
                "Heartfelt words count in any language and any form; sincerity matters far more than eloquence. Speak however feels natural, and trust that it is enough."),
        SpiritualRead(
            title: 'Gratitude for nourishment',
            body:
                "Each meal that nourishes you and your baby is a small mercy worth noticing. Before you eat, a moment of thanks can turn the food into care for two."),
        SpiritualRead(
            title: 'Patience, asked for gently',
            body:
                "On the long days, some ask simply for patience, for the strength to keep waiting well. It is an honest, human thing to request, and a gentle one to grant yourself."),
        SpiritualRead(
            title: 'Held through uncertainty',
            body:
                "A comforting belief is that you are watched over even in the unknowns you cannot control. Resting in that sense of being held can ease a restless mind."),
        SpiritualRead(
            title: 'A whispered hope for your baby',
            body:
                "Many like to send a small, sincere hope toward their baby, for health, for peace, for a good life. Whispered with a hand on your bump, it is a tender daily habit."),
        SpiritualRead(
            title: 'Thankful after the scan',
            body:
                "A reassuring scan is a natural moment to pause and be grateful, to breathe out and say thank you. Letting relief turn into gratitude makes the good news land more fully."),
      ]),
      SpiritualSection(title: "The Prophet's gentleness (reflections)", reads: [
        SpiritualRead(
            title: 'Gentleness with children',
            body:
                "The example most often highlighted is one of remarkable gentleness, tenderness toward children and care for mothers. Reflecting on that softness is a lovely model for the parent you are becoming."),
        SpiritualRead(
            title: 'Mercy first',
            body:
                "Mercy and compassion are placed above harshness in this tradition. As you imagine raising your child, leading with mercy, patience over perfection, is a gentle north star."),
        SpiritualRead(
            title: 'Honour to mothers',
            body:
                "Mothers are held in especially high regard, their care for their children deeply honoured. Let that be a reminder that the love and effort you are pouring out right now matters enormously."),
        SpiritualRead(
            title: 'Kindness as worship',
            body:
                "Everyday kindness, to family, neighbours and strangers, is treated as a form of devotion. The quiet care you give and receive in these months is part of that same thread."),
        SpiritualRead(
            title: 'A calm household',
            body:
                "Calm, kindness and good manners at home are valued highly. Building a gentle, warm atmosphere now is a gift your baby will be born into."),
        SpiritualRead(
            title: 'Leading with tenderness',
            body:
                "The example most reflected on is one of deep tenderness, meeting others, especially children, with softness. Imagining that gentleness is a lovely way to picture the parent you are becoming."),
        SpiritualRead(
            title: 'Patience over anger',
            body:
                "Responding to difficulty with patience rather than anger is a quality often admired. In the harder moments of these months, choosing the calmer response is its own quiet strength."),
        SpiritualRead(
            title: 'A smile as kindness',
            body:
                "Even a warm smile is remembered as a small act of kindness worth giving freely. The gentle warmth you offer others ripples further than you know."),
        SpiritualRead(
            title: 'Mothers especially honoured',
            body:
                "Mothers are spoken of with particular tenderness and high regard. Let that settle in: the care you are pouring out, unseen, is held as deeply precious."),
        SpiritualRead(
            title: 'Gentle words',
            body:
                "Kind, gentle speech is valued over harshness, even when correcting. A soft home, built on gentle words, is a calm place for a baby to arrive into."),
        SpiritualRead(
            title: 'Forgiving easily',
            body:
                "Letting go of small wrongs rather than holding them is treated as a strength. Releasing old irritations makes room for a lighter, calmer heart now."),
        SpiritualRead(
            title: 'Care for the vulnerable',
            body:
                "Special care for the weak, the young and the tired runs through these reflections. In pregnancy, letting yourself be one of the gently-cared-for is entirely fitting."),
        SpiritualRead(
            title: 'Generosity of spirit',
            body:
                "Giving freely, in small ways, without keeping score, is much admired. The open-handed love you are already growing for your baby is this same generous spirit."),
        SpiritualRead(
            title: 'Calm in difficulty',
            body:
                "Staying steady and gentle even under strain is a quality often highlighted. You are carrying so much and still being tender, which is exactly this kind of grace."),
        SpiritualRead(
            title: 'Good character over grand deeds',
            body:
                "It is everyday good character, honesty, kindness, patience, that is most treasured, not grand gestures. The small, decent choices you make now are quietly shaping your child's world."),
        SpiritualRead(
            title: 'Welcoming children close',
            body:
                "Children were welcomed warmly and kept close, never seen as a nuisance. It is a sweet model for the patient, present parent you are becoming."),
        SpiritualRead(
            title: 'Humility',
            body:
                "Humbleness, never thinking yourself above others, is gently admired. There is rest in it too, the freedom of not having to prove anything."),
        SpiritualRead(
            title: 'Keeping promises',
            body:
                "Keeping one's word, even in small things, is treated as a mark of good character. The quiet promises you are already making to your baby are part of that."),
        SpiritualRead(
            title: 'Comfort for the grieving',
            body:
                "Sitting with those in pain and offering simple comfort is remembered as a kindness. Knowing how to be present for sorrow is a gift you can carry into family life."),
        SpiritualRead(
            title: 'Mercy as the first response',
            body:
                "Leading with mercy rather than judgement is a recurring theme. As you imagine raising your child, mercy first is a gentle north star to keep."),
      ]),
      SpiritualSection(title: 'Beautiful names & their meaning', reads: [
        SpiritualRead(
            title: 'Choosing a meaningful name',
            body:
                "Choosing a baby's name with care and meaning is a cherished part of welcoming a child. It is a small act of hope, a wish in a single word for who they might become."),
        SpiritualRead(
            title: 'Names of mercy and peace',
            body:
                "Many beloved names carry meanings like mercy, peace, light and gratitude. Even if you choose a different name entirely, dwelling on qualities you wish for your child is a sweet thing to do."),
        SpiritualRead(
            title: 'A name as a quiet prayer',
            body:
                "For many, a name is a kind of quiet prayer said over a lifetime; every time it is spoken, a good wish goes with it. It is worth choosing something you will love to say a thousand times."),
        SpiritualRead(
            title: 'Light and hope',
            body:
                "Names connected to light and hope are widely loved. Your baby is, in a real sense, a new light coming into your family, a hopeful beginning."),
        SpiritualRead(
            title: 'A family conversation',
            body:
                "Picking a name often becomes a warm family conversation, full of stories and meanings. Letting loved ones share in it is part of the joy."),
        SpiritualRead(
            title: 'A wish in one word',
            body:
                "A name is often chosen as a small wish for who a child might become. Turning meanings over in your mind is already a loving act of hope."),
        SpiritualRead(
            title: 'Names of peace',
            body:
                "Many cherished names carry meanings like peace and calm. Dwelling on the qualities you hope for your child is a sweet way to choose."),
        SpiritualRead(
            title: 'A name you will love to say',
            body:
                "You will speak this name thousands of times, so choosing one you love the sound of matters. Say your favourites aloud and notice which ones feel like home."),
        SpiritualRead(
            title: 'Meaning over fashion',
            body:
                "Choosing for meaning rather than trend is a cherished approach. A name with a tender meaning ages beautifully."),
        SpiritualRead(
            title: 'Names of gratitude',
            body:
                "Some names carry the sense of a gift received or a prayer answered. If your baby feels like exactly that, such a name can hold the whole story."),
        SpiritualRead(
            title: 'Light coming in',
            body:
                "Names linked to light are widely loved. Your baby truly is a new light arriving into your family."),
        SpiritualRead(
            title: 'A name and a blessing',
            body:
                "For many, speaking a child's name is like sending a small good wish each time. Choose something you will be glad to bless again and again."),
        SpiritualRead(
            title: "Grandparents' hopes",
            body:
                "Inviting grandparents into the naming carries their love forward to the new child. Their blessing, woven into a name, stretches back through generations."),
        SpiritualRead(
            title: 'Writing it down',
            body:
                "Seeing the name written, beside a tiny due date, can make the coming arrival feel suddenly real. It is a quiet, happy moment to let yourself have."),
        SpiritualRead(
            title: 'A name that can grow',
            body:
                "It is kind to choose a name that suits both a small baby and the grown person they will become. Picturing them at every age can help you choose well."),
        SpiritualRead(
            title: 'The meaning you give it',
            body:
                "In time, your child will fill their name with their own meaning, simply by being themselves. The name is a beginning; they make it theirs."),
        SpiritualRead(
            title: 'Saying it for the first time',
            body:
                "There is a particular sweetness in saying your baby's name out loud for the first time. It turns an idea into someone you are waiting for."),
        SpiritualRead(
            title: 'A shortlist of hopes',
            body:
                "Even a shortlist of names is really a little list of hopes. However you narrow it, each option carries a wish for your child."),
        SpiritualRead(
            title: 'No rush to decide',
            body:
                "There is no need to settle on a name before you are ready; some meet their baby first and choose then. Trust that the right one will come."),
        SpiritualRead(
            title: 'A sound full of love',
            body:
                "However it is chosen, a name becomes beautiful mostly through the love poured into saying it. Yours will be one of the warmest words your child ever hears."),
      ]),
      SpiritualSection(title: 'Family & kindness', reads: [
        SpiritualRead(
            title: 'Held by community',
            body:
                "Family and community are encouraged to support an expectant mother, easing her load and treating her gently. Letting people help you is not weakness; it is how this is meant to work."),
        SpiritualRead(
            title: 'Generosity at new life',
            body:
                "New life is often marked with generosity, sharing food, giving to those in need, spreading the joy outward. Kindness has a way of multiplying happiness."),
        SpiritualRead(
            title: 'Good company',
            body:
                "Keeping calm, good-hearted company is valued, especially in tender times. Surround yourself with people who soothe rather than stress you."),
        SpiritualRead(
            title: 'Caring for yourself counts',
            body:
                "Looking after your own body and heart, with rest, good food and a peaceful mind, is treated as part of caring for your child, not separate from it. Be as kind to yourself as you would be to someone you love."),
        SpiritualRead(
            title: 'Welcoming with warmth',
            body:
                "When the baby arrives, traditions of welcome centre on warmth, gratitude and gentle blessing. The thread through it all is simple: this child is loved."),
        SpiritualRead(
            title: 'Let people carry some weight',
            body:
                "Family is encouraged to ease an expectant mother's load, and accepting that help is wise, not weak. Letting others carry a little is how this is meant to work."),
        SpiritualRead(
            title: 'Joy shared widens',
            body:
                "Happy news is meant to be spread, and joy tends to grow when shared. Letting people celebrate with you doubles the gladness."),
        SpiritualRead(
            title: 'The kindness of neighbours',
            body:
                "Care for neighbours and those nearby is valued, a circle of looking out for one another. Leaning on that circle now is part of belonging to it."),
        SpiritualRead(
            title: 'A meal brought over',
            body:
                "Sharing food, especially with a tired new family, is a simple, treasured kindness. If someone offers, let them; a warm meal is real care."),
        SpiritualRead(
            title: 'Visiting with gentleness',
            body:
                "Visiting a new mother gently, briefly, helpfully, is a kindness worth knowing. You can ask for that kind of visit, and decline the draining kind."),
        SpiritualRead(
            title: 'Kindness multiplies',
            body:
                "A small kindness given tends to ripple outward to others. The gentleness you receive now you will pass on, and so it grows."),
        SpiritualRead(
            title: 'Caring for yourself is caring for your baby',
            body:
                "Looking after your own rest, food and peace is treated as part of caring for your child, not apart from it. Be as gentle with yourself as with someone you love."),
        SpiritualRead(
            title: 'A warm home',
            body:
                "A calm, kind atmosphere at home is valued highly. The gentle mood you build now is the world your baby will be born into."),
        SpiritualRead(
            title: 'Raising a kind child',
            body:
                "Children learn kindness most by being surrounded by it. The warmth in your home today is already quietly teaching."),
        SpiritualRead(
            title: 'Hospitality of the heart',
            body:
                "Welcoming others warmly, making room, offering comfort, is a cherished value. The same open-hearted welcome is what you are preparing for your baby."),
        SpiritualRead(
            title: 'Asking for help is okay',
            body:
                "There is no shame in needing help while you grow a baby; it is a season for receiving. Asking is its own quiet courage."),
        SpiritualRead(
            title: 'Gratitude to those who love you',
            body:
                "Pausing to thank the people who support you strengthens those bonds. A simple word of thanks is never wasted."),
        SpiritualRead(
            title: 'Gentle with the tired',
            body:
                "Extra patience for those who are weary, including yourself, is part of this kindness. On low-energy days, soften your expectations."),
        SpiritualRead(
            title: 'A circle around the cradle',
            body:
                "New life is meant to be met by a whole circle of care, not one pair of hands. Letting that circle form around you is a gift to your baby too."),
        SpiritualRead(
            title: 'Small acts, big love',
            body:
                "It is the steady small kindnesses, not grand gestures, that hold a family together. The little daily cares you give and receive are the real thing."),
      ]),
    ],
  ),

  // ===========================================================================
  //  SIKHISM
  // ===========================================================================
  SpiritualTradition(
    id: 'sikh',
    name: 'Sikhism',
    symbol: '🪯',
    blurb: 'A calm, grateful mind and the dignity of motherhood.',
    sections: [
      SpiritualSection(title: "The Gurus' wisdom", reads: [
        SpiritualRead(
            title: 'Everyone equal, everyone worthy',
            body:
                "A cornerstone of Sikh teaching is the equal worth and dignity of every person, and women and mothers are honoured fully. Carry yourself with that confidence: what you are doing matters, and you deserve care."),
        SpiritualRead(
            title: 'Honest, simple living',
            body:
                "Living honestly and simply, and sharing what you have, is treasured. In pregnancy that can look like a calmer, less cluttered rhythm, fewer demands and more of what truly nourishes."),
        SpiritualRead(
            title: 'Gratitude as a way of life',
            body:
                "Thankfulness runs through this tradition like a quiet melody, a habit of noticing the good. A grateful heart tends to be a calmer one, and your baby shares that calm."),
        SpiritualRead(
            title: 'Courage and grace together',
            body:
                "There is a beautiful balance here of courage and gentleness, strength held with grace. Pregnancy asks for exactly that mix, and you have more of it than you know."),
        SpiritualRead(
            title: 'The sacred in the ordinary',
            body:
                "Much of this wisdom finds the sacred in everyday life, in honest work, family and small kindnesses. The ordinary days of these months are quietly holy too."),
        SpiritualRead(
            title: 'Your worth is settled',
            body:
                "A cornerstone here is the equal, unshakeable worth of every person. Whatever the day brings, your value, and your baby's, is never in question."),
        SpiritualRead(
            title: 'Honest, simple days',
            body:
                "Living simply and honestly is treasured. In pregnancy that can mean a calmer, less cluttered rhythm, more of what nourishes and less of what drains."),
        SpiritualRead(
            title: 'Rising spirits',
            body:
                "There is a beloved idea of keeping the spirit bright and hopeful even through hardship. On heavy days, gently choosing hope is itself an act of strength."),
        SpiritualRead(
            title: 'Gratitude woven through',
            body:
                "Thankfulness runs through this tradition like a quiet melody. A grateful heart tends to be calmer, and your baby shares that calm."),
        SpiritualRead(
            title: 'Strength and grace together',
            body:
                "Courage held with gentleness is a beautiful balance here. Pregnancy asks for exactly that mix, and you carry more of it than you know."),
        SpiritualRead(
            title: 'The holy in plain days',
            body:
                "The sacred is found woven through ordinary life here. The unremarkable days of pregnancy hold their own quiet grace."),
        SpiritualRead(
            title: 'Share what you have',
            body:
                "Sharing freely with others is central to this way of life. Even in a tiring season, small generosity keeps the heart open."),
        SpiritualRead(
            title: 'One human family',
            body:
                "A deep theme is the oneness of all people, one human family. Your child is joining a wide circle that stretches far beyond your home."),
        SpiritualRead(
            title: 'Women deeply honoured',
            body:
                "This tradition honours women and mothers fully and without reservation. Carry yourself with that dignity; what you are doing is held as precious."),
        SpiritualRead(
            title: 'Work, worship, share',
            body:
                "A simple rhythm is treasured: honest work, a grateful heart, and sharing with others. It is a gentle frame for an ordinary, meaningful day."),
        SpiritualRead(
            title: 'Contentment as wealth',
            body:
                "Being at peace with what is, is seen as a deep kind of richness. Small this-is-enough moments are worth savouring amid the unknowns."),
        SpiritualRead(
            title: 'Fearless, gentle love',
            body:
                "Love here is both fearless and tender, brave and soft at once. That is exactly the love already forming for your baby."),
        SpiritualRead(
            title: 'Truthful living',
            body:
                "Living truthfully, in word and deed, is valued above show. The honest, steady choices you make now become ground your child will stand on."),
        SpiritualRead(
            title: 'Humble and upright',
            body:
                "Humility paired with quiet strength is admired. There is rest in not needing to prove anything, only to live well."),
        SpiritualRead(
            title: 'Hope as a discipline',
            body:
                "Keeping hope alive, almost as a practice, is cherished here. You can return to hope again and again, like coming back to a warm room."),
      ]),
      SpiritualSection(title: 'Inner calm & remembrance', reads: [
        SpiritualRead(
            title: 'Returning to a still centre',
            body:
                "Gentle remembrance, quietly bringing the mind back to a still, grateful centre, is a loved practice. It is a bit like meditation: not emptying the mind, just returning to calm whenever it wanders."),
        SpiritualRead(
            title: 'A settled, hopeful mind',
            body:
                "Keeping a steady, hopeful mind is valued over anxious striving. When worry rises, you can let it pass like a cloud and settle again into trust."),
        SpiritualRead(
            title: 'Contentment',
            body:
                "Contentment, being at peace with what is, is held as a deep kind of wealth. Even amid the unknowns of pregnancy, small moments of this-is-enough are worth savouring."),
        SpiritualRead(
            title: 'Calm you can share',
            body:
                "A peaceful inner state is not only for you; it ripples outward to those around you, including the little one you carry. Tending your calm is a gift you are already giving."),
        SpiritualRead(
            title: 'Letting go of fear',
            body:
                "This tradition gently encourages trust over fear, leaning on something larger than yourself. On heavy days, it can help simply to set a worry down and breathe."),
        SpiritualRead(
            title: 'Coming back to centre',
            body:
                "Gently bringing the mind back to a still, grateful centre is a loved practice. Like meditation, it is not about emptying the mind, just returning to calm."),
        SpiritualRead(
            title: 'A steady, hopeful mind',
            body:
                "A settled, hopeful mind is valued over anxious striving. When worry rises, you can let it drift past like a cloud and settle again."),
        SpiritualRead(
            title: 'Remembrance as comfort',
            body:
                "Quietly remembering what is good and larger than yourself can steady a restless heart. A few calm minutes of it can soften a hard afternoon."),
        SpiritualRead(
            title: 'Calm that ripples',
            body:
                "Your inner peace does not stay with you alone; it reaches the little one you carry. Tending your calm is already a gift to your baby."),
        SpiritualRead(
            title: 'Setting fear down',
            body:
                "Trust over fear is gently encouraged here. On anxious days, simply setting a worry down and breathing can be enough."),
        SpiritualRead(
            title: 'The ease of repetition',
            body:
                "Softly repeating a word or phrase you love can settle a busy mind, much like a lullaby. Choose your own gentle words and return to them."),
        SpiritualRead(
            title: 'Right here, right now',
            body:
                "Returning to the present moment, this breath, this room, is calming and always available. The future will keep; you only have to meet now."),
        SpiritualRead(
            title: 'Stillness as strength',
            body:
                "Quiet stillness is treasured, not as doing nothing but as gathering yourself. A few still minutes a day strengthen you for the rest."),
        SpiritualRead(
            title: 'Breath as an anchor',
            body:
                "Slow, even breathing is one of the simplest ways back to calm. Lengthening the out-breath a little quietly shares that ease with your baby."),
        SpiritualRead(
            title: 'Gratitude as remembrance',
            body:
                "Recalling small blessings is itself a kind of remembrance that lifts the heart. Naming one good thing can shift a whole mood."),
        SpiritualRead(
            title: 'A quieter morning',
            body:
                "Beginning the day with a little stillness sets a gentler tone for all that follows. Even five quiet minutes before the rush can help."),
        SpiritualRead(
            title: 'Peace, not perfection',
            body:
                "The aim is a peaceful heart, not a perfectly tidy mind. Some wandering is normal; the practice is simply coming back."),
        SpiritualRead(
            title: 'Held by something larger',
            body:
                "Leaning on something larger than yourself can ease the weight you carry. You are not holding all of this alone."),
        SpiritualRead(
            title: 'Letting the day soften',
            body:
                "Easing into evening with a calm wind-down helps both body and mind settle. Dimming the lights and slowing your breath signals it is safe to rest."),
        SpiritualRead(
            title: 'Contentment, returned to',
            body:
                "Contentment is less a feeling that arrives and more a place you return to. Each return, however brief, is worth it."),
      ]),
      SpiritualSection(title: 'Seva & community', reads: [
        SpiritualRead(
            title: 'Service with love',
            body:
                "Selfless service, helping others without expecting anything back, is central to Sikh life. The unseen care you give your baby every day is service of the purest kind."),
        SpiritualRead(
            title: 'The shared meal',
            body:
                "The tradition of a free community kitchen, where all sit together as equals and are fed, is much loved. Its spirit, everyone welcome and everyone cared for, is a beautiful one to bring into your home."),
        SpiritualRead(
            title: 'Lean on your community',
            body:
                "Just as service is given, it is also meant to be received. Letting your community support you now is part of the same circle of care."),
        SpiritualRead(
            title: 'Small kindnesses',
            body:
                "Grand gestures are not required; small, steady kindnesses are the heart of it. A warm word, a helping hand, a shared meal, these are enough."),
        SpiritualRead(
            title: 'Raising a kind child',
            body:
                "Caring for others is something children learn by watching. The gentleness you live now quietly plants those seeds in your little one."),
        SpiritualRead(
            title: 'Service, freely given',
            body:
                "Selfless service, helping with no thought of reward, is central here. The unseen care you give your baby each day is service of the purest kind."),
        SpiritualRead(
            title: 'Everyone at one table',
            body:
                "The tradition of a shared meal where all sit as equals is much loved. Its spirit, everyone welcome, everyone fed, is a beautiful one to bring home."),
        SpiritualRead(
            title: 'Receiving is part of it',
            body:
                "Service is given, but it is also meant to be received with grace. Letting your community support you now completes the circle."),
        SpiritualRead(
            title: 'Small, steady kindness',
            body:
                "Grand gestures are not required; small, steady kindnesses are the heart of it. A warm word or a helping hand is enough."),
        SpiritualRead(
            title: 'Kindness, caught not taught',
            body:
                "Children learn care most by watching it lived. The gentleness around your home today is already planting seeds."),
        SpiritualRead(
            title: 'Serving without a spotlight',
            body:
                "The quiet, unseen service often matters most, given without needing thanks. So much of mothering is exactly this, and it counts."),
        SpiritualRead(
            title: 'A welcome for everyone',
            body:
                "A spirit of welcome, making room for whoever comes, runs through community life. The same open-hearted welcome is what you are preparing for your baby."),
        SpiritualRead(
            title: 'Let others help',
            body:
                "Accepting help while you grow a baby is wise and gracious. People who love you want to serve; let them."),
        SpiritualRead(
            title: 'Gratitude to your helpers',
            body:
                "Pausing to thank those who care for you strengthens the bond. A simple thank-you keeps the circle warm."),
        SpiritualRead(
            title: 'Feeding body and heart',
            body:
                "Caring for others' simple needs, a meal, a rest, a listening ear, is treasured. Receiving that care now is part of the same goodness."),
        SpiritualRead(
            title: 'No one carries alone',
            body:
                "Community exists so that no one bears joy or hardship by themselves. Letting yourself be carried a little is the tradition working as intended."),
        SpiritualRead(
            title: 'The joy of giving',
            body:
                "There is a quiet gladness in giving that the tradition knows well. Even small acts of care lift the giver too."),
        SpiritualRead(
            title: 'Gentle with the weary',
            body:
                "Extra kindness for the tired, including yourself, fits this spirit. On low days, soften what you ask of yourself."),
        SpiritualRead(
            title: 'Planting kindness early',
            body:
                "The care your child sees now becomes the care they give later. You are quietly raising a kind person already."),
        SpiritualRead(
            title: 'A circle of hands',
            body:
                "New life is meant to be met by many willing hands, not one. Letting that circle form around you blesses your baby too."),
      ]),
      SpiritualSection(title: 'Naming & blessings', reads: [
        SpiritualRead(
            title: 'Naming within the community',
            body:
                "A well-loved custom is choosing the baby's name together within the community, in a spirit of blessing. It is a warm, shared welcome for the new child."),
        SpiritualRead(
            title: 'A name with meaning',
            body:
                "Names are often chosen for their meaning and the good wishes they carry. Picking something that holds hope for your child is a sweet, lasting gift."),
        SpiritualRead(
            title: 'Blessings all around',
            body:
                "New life is met with blessings and good wishes from family and community. Receiving them, and believing them, is part of the joy."),
        SpiritualRead(
            title: 'Welcomed as equal and whole',
            body:
                "A child is welcomed as a full, equal member of the community from the very start. Your baby belongs, simply by arriving."),
        SpiritualRead(
            title: 'Joy shared widely',
            body:
                "Happy news is meant to be shared, the joy spread outward. Letting others celebrate with you doubles the gladness."),
        SpiritualRead(
            title: 'A name chosen together',
            body:
                "Choosing a baby's name within the warmth of community is a loved custom. It is a shared welcome for the new child."),
        SpiritualRead(
            title: 'Meaning that lasts',
            body:
                "Names chosen for their meaning carry quiet wishes for years. Something hopeful is a gift that ages well."),
        SpiritualRead(
            title: 'Showered with blessings',
            body:
                "New life draws blessings from family and community alike. Receiving them, and believing them, is part of the joy."),
        SpiritualRead(
            title: 'Belonging from the start',
            body:
                "A child is welcomed as a full, equal member from the very beginning. Your baby belongs simply by arriving."),
        SpiritualRead(
            title: 'Joy spread wide',
            body:
                "Happy news is meant to be shared outward. Letting others rejoice with you multiplies the gladness."),
        SpiritualRead(
            title: 'Good wishes in a name',
            body:
                "A name can hold a quiet good wish, spoken every time it is said. Choose one you will be glad to repeat with love."),
        SpiritualRead(
            title: 'Said with love',
            body:
                "The way a name is first spoken, with tenderness, sets the tone. Your baby's name will be one of the softest words you say."),
        SpiritualRead(
            title: "Elders' blessings",
            body:
                "The blessings of grandparents and elders are treasured at every milestone. Their love, spoken or simply felt, wraps your baby warmly."),
        SpiritualRead(
            title: 'A warm welcome readied',
            body:
                "Welcoming customs centre on warmth, gratitude and gentle blessing. You are already preparing that welcome in your heart."),
        SpiritualRead(
            title: 'Gratitude at the threshold',
            body:
                "New arrivals are met with thankfulness for the gift of life. A grateful heart makes the welcome fuller."),
        SpiritualRead(
            title: 'A fresh beginning',
            body:
                "Each new child is a fresh beginning for a whole family. Your baby brings a new chapter, and new hope, to everyone."),
        SpiritualRead(
            title: 'Celebrating together',
            body:
                "Joy is meant to gather people, so no one celebrates alone. Letting your community share the happiness is part of the gift."),
        SpiritualRead(
            title: 'A name that fits a life',
            body:
                "Choosing a name that suits both a tiny baby and the grown person to come is kind. Picture them at every age as you choose."),
        SpiritualRead(
            title: 'Blessings spoken over you',
            body:
                "Blessings are often spoken over the mother too, wishes for peace and strength. Receiving them, you are reminded you are held."),
        SpiritualRead(
            title: 'Wanted and loved',
            body:
                "Under every custom is one simple message: this child is wanted and loved. That truth is worth resting in."),
      ]),
    ],
  ),

  // ===========================================================================
  //  CHRISTIANITY
  // ===========================================================================
  SpiritualTradition(
    id: 'christian',
    name: 'Christianity',
    symbol: '✝️',
    blurb: 'Hope, gratitude and prayer as a family welcomes new life.',
    sections: [
      SpiritualSection(title: 'Reflections & prayer', reads: [
        SpiritualRead(
            title: 'A gift to be thankful for',
            body:
                "A new pregnancy is often received as a gift and a reason for gratitude and hope. Even on tired days, a quiet thank-you can steady the heart."),
        SpiritualRead(
            title: 'Praying simply',
            body:
                "Prayer here is often just an honest conversation, asking for a healthy baby, a safe delivery and peace of mind. You do not need the perfect words; sincerity is enough."),
        SpiritualRead(
            title: 'Peace that steadies',
            body:
                "Many lean on their faith for a peace that holds them through worry, a calm that does not depend on everything going right. On anxious days, that can be a real anchor."),
        SpiritualRead(
            title: 'Hope as a quiet strength',
            body:
                "Hope runs through this tradition, the trust that good is being woven even when you cannot see it. Holding gently to hope can lighten the heavier stretches."),
        SpiritualRead(
            title: 'You are held',
            body:
                "A comforting thread is the sense of being known, loved and cared for, just as you are. Whatever you are feeling today, you are not carrying it unseen."),
        SpiritualRead(
            title: 'A reason for thanks',
            body:
                "A new pregnancy is often received as a gift and a cause for gratitude. Even on tired days, a quiet thank-you can steady the heart."),
        SpiritualRead(
            title: 'Honest, simple prayer',
            body:
                "Prayer here is often just honest conversation, asking for health, a safe birth, and peace. You do not need perfect words; sincerity is enough."),
        SpiritualRead(
            title: 'A peace that holds',
            body:
                "Many lean on faith for a calm that does not depend on everything going right. On anxious days, that can be a real anchor."),
        SpiritualRead(
            title: 'Hope that lightens',
            body:
                "Hope, the trust that good is being woven even unseen, runs deep here. Holding gently to it lightens the heavier stretches."),
        SpiritualRead(
            title: 'Casting your cares',
            body:
                "There is a comforting idea of handing your worries over rather than carrying them all. At night, you might set the day's fears down and rest."),
        SpiritualRead(
            title: 'Thanks in small things',
            body:
                "Gratitude is encouraged even in ordinary moments, not only the big ones. A grateful glance at a quiet day counts."),
        SpiritualRead(
            title: 'Praying for your baby',
            body:
                "Many like to pray simply over their growing baby, for health and a good life. A hand on your bump and a sincere wish is a tender daily habit."),
        SpiritualRead(
            title: 'Faith a little bigger than fear',
            body:
                "You do not have to be fearless, only to let trust be a touch larger than the fear. That small margin can carry you a long way."),
        SpiritualRead(
            title: 'Rest for the weary',
            body:
                "There is a tender invitation to bring your tiredness and find rest. Letting yourself slow down is welcomed, not frowned upon."),
        SpiritualRead(
            title: 'Praying with others',
            body:
                "Sharing your hopes with people who will pray alongside you can ease the load. You are not meant to carry it solo."),
        SpiritualRead(
            title: 'Grace on the hard days',
            body:
                "Grace, unearned kindness, is a thread here, meeting you exactly where you are. On the days you feel you fell short, grace says you are still enough."),
        SpiritualRead(
            title: 'Gratitude after good news',
            body:
                "A reassuring scan or appointment is a natural moment to pause and give thanks. Letting relief become gratitude makes the joy land fully."),
        SpiritualRead(
            title: 'A quiet trust',
            body:
                "Underneath the planning, many rest in a quiet trust that they are cared for. That trust can soften even the unknown parts of birth."),
        SpiritualRead(
            title: "A prayer at day's end",
            body:
                "Closing the day with a few honest words settles the heart for sleep. Name one good thing, hand over the rest, and rest."),
        SpiritualRead(
            title: 'Bring it all, just as it is',
            body:
                "Whatever is on your heart, joy, fear, or a long list of worries, can be brought to prayer exactly as it is. You do not have to tidy yourself up first."),
      ]),
      SpiritualSection(title: 'Parables, simply retold', reads: [
        SpiritualRead(
            title: 'Sought and cherished',
            body:
                "One much-loved story tells of a shepherd who searches tirelessly for a single lost lamb, a picture of how deeply each one matters. Retold simply, it is a reminder that your little one is treasured beyond counting."),
        SpiritualRead(
            title: 'Small beginnings, great growth',
            body:
                "Another favourite likens faith to a tiny seed that grows into something far larger than itself. It is a lovely image for the small cluster of cells now becoming your child."),
        SpiritualRead(
            title: 'Kindness to a stranger',
            body:
                "A well-known story praises the one who stops to help a stranger in need, simply out of compassion. Its quiet lesson, that kindness asks no questions, is a gentle one to raise a child by."),
        SpiritualRead(
            title: 'A joyful welcome home',
            body:
                "One story tells of a parent who runs to welcome a child home with open arms and no conditions. That picture of unconditional welcome is the very love you are already growing."),
        SpiritualRead(
            title: 'Building on something steady',
            body:
                "A short tale contrasts a house built on rock with one built on sand, the value of steady foundations. Calm habits and good support are the rock you are building your family on."),
        SpiritualRead(
            title: 'The one that mattered',
            body:
                "A loved story tells of a shepherd searching tirelessly for a single lost lamb. Retold simply, it is a reminder that your little one is treasured beyond counting."),
        SpiritualRead(
            title: 'A tiny seed',
            body:
                "Another likens growth to a tiny seed becoming something far larger than itself. It is a lovely image for the small beginning now becoming your child."),
        SpiritualRead(
            title: 'Help for a stranger',
            body:
                "A well-known tale praises the one who stops to help a stranger out of pure compassion. Its lesson, that kindness asks no questions, is a gentle one to raise a child by."),
        SpiritualRead(
            title: 'Run to welcome',
            body:
                "One story shows a parent running to welcome a child home with open arms and no conditions. That picture of unconditional welcome is the love you are already growing."),
        SpiritualRead(
            title: 'Built on rock',
            body:
                "A short tale weighs a house on rock against one on sand, the worth of steady foundations. Calm habits and good support are the rock under your new family."),
        SpiritualRead(
            title: 'A lamp set high',
            body:
                "One image speaks of a lamp not hidden but set where it gives light to all. The warmth and goodness you carry is meant to be shared, not tucked away."),
        SpiritualRead(
            title: 'Good soil',
            body:
                "A story of a sower notes how the same seed flourishes in cared-for soil. Tending your own peace and health prepares good ground for your baby."),
        SpiritualRead(
            title: 'Treasure worth everything',
            body:
                "A brief tale tells of treasure so precious one gives all to keep it. Your child is exactly that kind of treasure to you."),
        SpiritualRead(
            title: 'A coin found',
            body:
                "One story tells of a woman searching her whole house for a single lost coin, then rejoicing when it is found. It is a picture of how one small life can be worth a wholehearted search and a great gladness."),
        SpiritualRead(
            title: 'Two builders',
            body:
                "The tale of the wise and foolish builders gently asks what we build upon. Building on patience and love steadies whatever weather comes."),
        SpiritualRead(
            title: 'Gifts meant to be used',
            body:
                "A story encourages using whatever gifts you are given rather than burying them. The love and care you have to give, you are already putting to beautiful use."),
        SpiritualRead(
            title: 'Faith like a child',
            body:
                "A tender theme honours the simple, trusting heart of a child. Your baby will teach you that kind of open trust all over again."),
        SpiritualRead(
            title: 'Branches and vine',
            body:
                "One image pictures branches drawing life from the vine they are joined to. Staying close to what nourishes you keeps you steady and growing."),
        SpiritualRead(
            title: 'A little light',
            body:
                "A recurring picture is of a small light shining in a dark place. On uncertain nights, your quiet hope can be that small, steady light."),
        SpiritualRead(
            title: 'Welcomed like a child',
            body:
                "One gentle moment shows children being welcomed warmly and held close. Your child is arriving into exactly that kind of welcome."),
      ]),
      SpiritualSection(title: 'Figures of faith', reads: [
        SpiritualRead(
            title: "A mother's quiet yes",
            body:
                "A figure often reflected on is a young mother who said yes to an unknown, life-changing journey with quiet courage. Every mother's yes to this path carries that same brave tenderness."),
        SpiritualRead(
            title: 'Treasuring small moments',
            body:
                "Stories tell of a mother who quietly treasured and pondered the small moments of her child's life. It is a sweet invitation to savour the little wonders, the first flutter, the first scan."),
        SpiritualRead(
            title: 'Faithful through waiting',
            body:
                "Many honoured figures are remembered for their patience through long waiting. Pregnancy has its own waiting, and steadiness through it is its own kind of faith."),
        SpiritualRead(
            title: 'Caring hands',
            body:
                "Tradition is full of people remembered for their gentle, practical care of others. The hands that help you now, and the hands you will offer your child, carry that same goodness."),
        SpiritualRead(
            title: 'Welcoming children',
            body:
                "A tender theme is the special welcome given to children, the sense that they belong close and matter immensely. Your child is arriving into exactly that kind of welcome."),
        SpiritualRead(
            title: 'A brave yes',
            body:
                "A figure often reflected on is a young mother who said yes to an unknown, life-changing path with quiet courage. Every mother's yes carries that same brave tenderness."),
        SpiritualRead(
            title: 'Treasuring small wonders',
            body:
                "Stories tell of a mother who quietly pondered and treasured the small moments of her child's life. It is a sweet invitation to savour the little wonders you are noticing now."),
        SpiritualRead(
            title: 'Steady through the wait',
            body:
                "Many honoured figures are remembered for patience through long waiting. Steadiness through pregnancy's wait is its own quiet faith."),
        SpiritualRead(
            title: 'Gentle, practical care',
            body:
                "Tradition is full of people remembered for their humble, hands-on care of others. The hands that help you now carry that same goodness."),
        SpiritualRead(
            title: 'Children welcomed close',
            body:
                "A tender theme is the warm welcome given to children, the sense that they belong near and matter immensely. Your child is arriving into that welcome."),
        SpiritualRead(
            title: 'Two expectant mothers',
            body:
                "One warm story tells of two expectant mothers meeting and rejoicing together. It is a lovely picture of how shared joy lightens the wait."),
        SpiritualRead(
            title: 'A quiet, steady father',
            body:
                "Some figures are remembered not for words but for steady, protective care. The calm, dependable love around you now is its own kind of faith."),
        SpiritualRead(
            title: 'Courage in the unknown',
            body:
                "Many remembered figures stepped into uncertain futures with trust rather than certainty. You are doing the same brave thing, day by day."),
        SpiritualRead(
            title: 'Perseverance',
            body:
                "Stories honour those who kept going through long, hard seasons. Your perseverance through these months is quietly heroic too."),
        SpiritualRead(
            title: 'Hospitality remembered',
            body:
                "Some are remembered simply for opening their homes and hearts. The welcome you are preparing for your baby is that same warmth."),
        SpiritualRead(
            title: 'Gentleness as greatness',
            body:
                "Many honoured figures paired strength with great gentleness. It is a lovely model for motherhood, where tenderness and strength are the same thing."),
        SpiritualRead(
            title: 'Joy at a birth',
            body:
                "Stories often surround a birth with wonder and rejoicing. The joy gathering around your own coming arrival is part of that ancient gladness."),
        SpiritualRead(
            title: 'Trusting the unseen',
            body:
                "Faithful figures are remembered for trusting what they could not yet see. On the days the future feels foggy, that kind of trust can steady you."),
        SpiritualRead(
            title: 'Caring for the vulnerable',
            body:
                "A recurring honour goes to those who cared for the small and the weak. In welcoming a tiny, dependent baby, you join that gentle tradition."),
        SpiritualRead(
            title: 'Ordinary people, quiet faith',
            body:
                "Many remembered figures were ordinary people living with quiet faith. Your own ordinary, faithful days are part of the same story."),
      ]),
      SpiritualSection(title: 'Blessings for mother & baby', reads: [
        SpiritualRead(
            title: 'A blessing over you',
            body:
                "Families often speak blessings over an expectant mother, simple wishes for safety, peace and joy. To be wished well, sincerely, is a quiet comfort worth receiving."),
        SpiritualRead(
            title: 'Welcomed with love',
            body:
                "Many later welcome a baby with a blessing or christening, a celebration of the child joining the family in love. The heart of it is belonging."),
        SpiritualRead(
            title: 'Held by community',
            body:
                "Church and community often surround new parents with practical help and encouragement. Letting yourself be carried a little is part of the gift."),
        SpiritualRead(
            title: 'A new light',
            body:
                "A new child is often spoken of as a light coming into the family. You are, gently, carrying a new light toward the world."),
        SpiritualRead(
            title: 'Gratitude and belonging',
            body:
                "The thread through all of it is gratitude and belonging: this child is wanted, loved and home. That truth is worth resting in."),
        SpiritualRead(
            title: 'Wished well',
            body:
                "Families often speak simple blessings over an expectant mother, wishes for safety, peace and joy. To be sincerely wished well is a quiet comfort worth receiving."),
        SpiritualRead(
            title: 'Welcomed in love',
            body:
                "Many later welcome a baby with a blessing or christening, celebrating the child joining the family. The heart of it is belonging."),
        SpiritualRead(
            title: 'Surrounded by help',
            body:
                "Community often surrounds new parents with practical help and encouragement. Letting yourself be carried a little is part of the gift."),
        SpiritualRead(
            title: 'A light arriving',
            body:
                "A new child is often spoken of as a light coming into the family. You are gently carrying a new light toward the world."),
        SpiritualRead(
            title: 'Wanted and home',
            body:
                "A recurring comfort is that this child is wanted, loved and already at home in your heart. That belonging begins long before the birth."),
        SpiritualRead(
            title: 'Chosen guardians',
            body:
                "Naming godparents or special guardians weaves more love around a child. Your baby will have many hearts looking out for them."),
        SpiritualRead(
            title: 'A name blessed',
            body:
                "A child's name is often spoken with a blessing, a hope sent with it. Every time it is said, a good wish goes along."),
        SpiritualRead(
            title: 'Praying for a safe arrival',
            body:
                "Loved ones often pray simply for a safe, gentle birth. Their quiet hopes are gathering around you and your baby."),
        SpiritualRead(
            title: 'A candle lit',
            body:
                "Lighting a small candle is a tender way to hold someone in mind with hope. You might light one as you think of your baby."),
        SpiritualRead(
            title: 'Gratitude for the gift',
            body:
                "New life is met with thankfulness for the gift it is. Letting gratitude rise makes the joy fuller."),
        SpiritualRead(
            title: 'It takes a village',
            body:
                "There is deep wisdom in the idea that a child is raised by a whole community. Letting your village form around you blesses your baby too."),
        SpiritualRead(
            title: 'Hopes for the child',
            body:
                "Blessings often carry hopes for the child's character, kindness, courage, joy. The hopes you hold now are the first of many."),
        SpiritualRead(
            title: 'Peace wished over the home',
            body:
                "Blessings frequently wish peace over the whole household. A calm home is a gift your baby will be born into."),
        SpiritualRead(
            title: 'Blessed in the waiting',
            body:
                "The waiting itself is sometimes blessed, honoured as sacred rather than just endured. Your patient months are part of the gift."),
        SpiritualRead(
            title: 'Held and not alone',
            body:
                "Under every blessing is the reminder that you are held and not alone. Whatever today holds, that remains true."),
      ]),
    ],
  ),

  // ===========================================================================
  //  OTHERS — Jainism & Buddhism
  // ===========================================================================
  SpiritualTradition(
    id: 'others',
    name: 'Others',
    symbol: '🪷',
    blurb: 'Gentle reflections from Jainism and Buddhism.',
    sections: [
      SpiritualSection(title: 'Jainism · Ahimsa & compassion', reads: [
        SpiritualRead(
            title: 'Gentleness toward all life',
            body:
                "At the heart of Jain thought is ahimsa, a deep gentleness and non-harm toward all living things. As you grow a new life, that reverence for life feels especially close to home."),
        SpiritualRead(
            title: 'A compassionate plate',
            body:
                "This compassion often shows up in mindful, vegetarian eating and care not to harm. However you eat, the gentle intention behind it, to do as little harm as you can, is a beautiful one to carry."),
        SpiritualRead(
            title: 'Soft words, soft heart',
            body:
                "Non-harm extends to words and thoughts, not just actions, speaking kindly and thinking kindly. A calm, gentle inner world is a soothing place for your baby to grow."),
        SpiritualRead(
            title: 'Doing less harm, gently',
            body:
                "Jain practice is realistic: it is about reducing harm with care, not achieving perfection. The same grace applies to pregnancy, small kind choices without pressure."),
        SpiritualRead(
            title: 'Reverence for the small',
            body:
                "There is a tender attention here to even the smallest forms of life. It is a lovely lens for these months, when the smallest of beginnings, your baby, means everything."),
        SpiritualRead(
            title: 'Reverence for life',
            body:
                "At the heart of Jain thought is a deep gentleness toward all living things. As you grow a new life, that reverence feels especially close to home."),
        SpiritualRead(
            title: 'A gentle plate',
            body:
                "Compassion often shows up in mindful, gentle eating. However you eat, the kind intention, to do as little harm as you can, is a beautiful one to carry."),
        SpiritualRead(
            title: 'Soft words, soft thoughts',
            body:
                "Non-harm reaches into words and thoughts, not just actions. A calm, gentle inner world is a soothing place for your baby to grow."),
        SpiritualRead(
            title: 'Gentler, not perfect',
            body:
                "Jain practice is realistic: it is about reducing harm with care, not perfection. The same grace fits pregnancy, small kind choices without pressure."),
        SpiritualRead(
            title: 'Honouring the small',
            body:
                "There is tender attention here to even the smallest forms of life. It is a lovely lens now, when the smallest beginning, your baby, means everything."),
        SpiritualRead(
            title: 'Compassion for yourself',
            body:
                "Gentleness toward all beings includes yourself. Be as careful and kind with your own body and heart as you would be with any living thing."),
        SpiritualRead(
            title: 'Careful steps',
            body:
                "A mindful awareness of one's effect on the world is treasured. Moving through your days a little more gently is care for two."),
        SpiritualRead(
            title: 'Kindness to creatures',
            body:
                "Tenderness toward animals and small creatures is part of this gentleness. Noticing and protecting little lives is a sweet habit to model."),
        SpiritualRead(
            title: 'Peace begins within',
            body:
                "A peaceful outer life is seen to begin with a peaceful heart. Tending your own calm quietly tends your baby's world."),
        SpiritualRead(
            title: 'The path of least harm',
            body:
                "The aim is to choose, again and again, the path of least harm. In pregnancy that can simply mean gentler choices, made without guilt."),
        SpiritualRead(
            title: 'Patience as non-harm',
            body:
                "Patience itself is a kind of gentleness, sparing others and yourself sharp edges. On hard days, a patient pause is a small act of care."),
        SpiritualRead(
            title: 'Respect woven in',
            body:
                "Respect for life threads through ordinary actions, how you speak, eat and move. Let that respect include the little life you carry."),
        SpiritualRead(
            title: 'A gentle home',
            body:
                "Building a calm, harm-light home is a quiet expression of this value. Your baby will be born into the gentleness you create."),
        SpiritualRead(
            title: 'Gratitude for being alive',
            body:
                "There is wonder here at the gift of life itself. Pausing in awe that a new life is forming in you is its own gentle practice."),
        SpiritualRead(
            title: 'Kindness, repeated',
            body:
                "Compassion is treated as a daily practice, returned to again and again. Each small kind choice strengthens it, and your child will feel that warmth."),
      ]),
      SpiritualSection(title: 'Jainism · Calm reflections', reads: [
        SpiritualRead(
            title: 'Letting go lightly',
            body:
                "Jain wisdom values non-attachment, holding life's ups and downs a little more lightly. On anxious days, gently loosening your grip on what you cannot control can bring real relief."),
        SpiritualRead(
            title: 'Stillness as strength',
            body:
                "Quiet, reflective stillness is treasured, a settling of the restless mind. A few still minutes a day are a gift to both you and your baby."),
        SpiritualRead(
            title: 'A kind look inward',
            body:
                "Looking honestly and kindly at your own heart is encouraged, not to judge but to grow. A gentle nightly check-in can be calming rather than critical."),
        SpiritualRead(
            title: 'Forgiveness and a fresh start',
            body:
                "Jain tradition cherishes forgiveness, letting go of grudges and beginning again. Releasing old weight makes room for the new life ahead."),
        SpiritualRead(
            title: 'Peace from within',
            body:
                "Lasting peace, in this view, is grown from the inside out. The calm you cultivate now is something you carry into motherhood."),
        SpiritualRead(
            title: 'Holding lightly',
            body:
                "Jain wisdom values holding life's ups and downs a little more lightly. On anxious days, loosening your grip on what you cannot control brings relief."),
        SpiritualRead(
            title: 'The strength in stillness',
            body:
                "Quiet, reflective stillness is treasured, a settling of the restless mind. A few still minutes a day are a gift to you and your baby."),
        SpiritualRead(
            title: 'A gentle look within',
            body:
                "Looking honestly and gently at your own heart is encouraged, not to judge but to grow. A soft nightly check-in can calm rather than criticise."),
        SpiritualRead(
            title: 'The relief of forgiving',
            body:
                "Forgiveness, letting go of grudges and beginning again, is cherished. Releasing old weight makes room for the new life ahead."),
        SpiritualRead(
            title: 'Peace grown within',
            body:
                "Lasting peace, in this view, is grown from the inside out. The calm you cultivate now you carry into motherhood."),
        SpiritualRead(
            title: 'Even-hearted days',
            body:
                "Meeting good and hard moments with a steady heart is admired. Some days glow and some ache; both pass, and neither is the whole."),
        SpiritualRead(
            title: 'Simplicity soothes',
            body:
                "A simpler life is seen to quiet the mind. Trimming your days to what truly matters can be its own calm."),
        SpiritualRead(
            title: 'Loosening control',
            body:
                "Much suffering is said to come from gripping too tightly. Letting the uncontrollable parts of pregnancy simply be can ease the heart."),
        SpiritualRead(
            title: 'Contentment within reach',
            body:
                "Contentment, being at peace with what is, is a deep wealth. Small enough-for-now moments are worth pausing on."),
        SpiritualRead(
            title: 'Patience practised',
            body:
                "Patience is treated as something you grow with practice. Each calm pause through a long day strengthens it."),
        SpiritualRead(
            title: 'Inner freedom',
            body:
                "A quiet freedom comes from needing less and grasping less. That lightness is a gift you can give yourself now."),
        SpiritualRead(
            title: 'Gentle discipline',
            body:
                "Self-care here is gentle, steady, never harsh. Kind, consistent habits serve you better than strict ones."),
        SpiritualRead(
            title: 'Beginning again',
            body:
                "There is grace in beginning again after a hard day, without self-blame. Tomorrow is always a fresh page."),
        SpiritualRead(
            title: 'Quiet over noise',
            body:
                "Calm is found by turning down the noise, outer and inner. Choosing a little quiet is choosing peace for two."),
        SpiritualRead(
            title: 'A settled heart',
            body:
                "A settled heart is treated as the ground of a good life. Tending yours is among the kindest things you can do for your baby."),
      ]),
      SpiritualSection(title: 'Buddhism · Mindfulness & calm', reads: [
        SpiritualRead(
            title: 'One breath at a time',
            body:
                "Mindfulness, simply being present one breath at a time, is at the core of Buddhist practice. When pregnancy feels overwhelming, returning to this breath, right now, is always available to you."),
        SpiritualRead(
            title: 'Noticing without judging',
            body:
                "A gentle skill here is noticing feelings as they come and go, without grabbing or fighting them. Emotions, like weather, pass, and you can watch them with kindness."),
        SpiritualRead(
            title: 'This moment is enough',
            body:
                "Much of this teaching points to the peace of the present moment rather than the imagined future. A hand on your bump, a slow breath: this moment, just as it is, can be enough."),
        SpiritualRead(
            title: 'Calm is contagious',
            body:
                "A settled, mindful state ripples outward to those near you, including your baby. Tending your own calm is quietly tending theirs."),
        SpiritualRead(
            title: 'Back to the breath',
            body:
                "Mindfulness, being present one breath at a time, is at the core of this practice. When pregnancy feels overwhelming, this breath, right now, is always available."),
        SpiritualRead(
            title: 'Noticing, not judging',
            body:
                "A gentle skill is noticing feelings as they come and go without grabbing or fighting them. Emotions, like weather, pass, and you can watch them kindly."),
        SpiritualRead(
            title: 'Enough, right now',
            body:
                "Much of this points to the peace of the present rather than the imagined future. A hand on your bump, a slow breath, this moment can be enough."),
        SpiritualRead(
            title: 'Calm spreads',
            body:
                "A settled, mindful state ripples to those near you, including your baby. Tending your calm is quietly tending theirs."),
        SpiritualRead(
            title: 'Everything changes',
            body:
                "A core idea is that all things shift and pass, the hard moments too. Remembering this can soften a difficult day."),
        SpiritualRead(
            title: 'A fresh look',
            body:
                "Meeting things with a beginner's openness, as if new, brings wonder back. Each scan and flutter can be met with fresh eyes."),
        SpiritualRead(
            title: 'A gentle body scan',
            body:
                "Slowly noticing the body, part by part, with kindness, can release held tension. A few minutes of this is soothing for two."),
        SpiritualRead(
            title: 'Mindful steps',
            body:
                "Even a slow, attentive walk can become a calming practice. Feeling each step roots you in the present."),
        SpiritualRead(
            title: 'Thoughts drifting by',
            body:
                "Thoughts can be watched like leaves floating past on a stream. You need not chase each one; let them drift."),
        SpiritualRead(
            title: 'Kindness to this moment',
            body:
                "Meeting the present moment gently, whatever it holds, is the practice. Even a tiring moment can be met without resistance."),
        SpiritualRead(
            title: 'Gentle attention',
            body:
                "Bringing soft, curious attention to ordinary things, tea, light, breath, can calm the mind. Small noticing is a doorway to peace."),
        SpiritualRead(
            title: 'Always returning',
            body:
                "The practice is not to never wander but to keep returning. Each gentle return is the whole of it."),
        SpiritualRead(
            title: 'Present with your baby',
            body:
                "A few quiet, present minutes with a hand on your bump deepen the bond. Your baby shares in your settled attention."),
        SpiritualRead(
            title: 'Ease over effort',
            body:
                "Calm is invited, not forced; striving for peace can undo it. Let ease come gently, on its own time."),
        SpiritualRead(
            title: 'A little spaciousness',
            body:
                "Pausing creates a small space between feeling and reacting. In that space, a calmer choice can appear."),
        SpiritualRead(
            title: 'Rest in the breath',
            body:
                "When the mind is busy, the breath is a quiet place to rest. A few slow breaths can settle a whole afternoon."),
      ]),
      SpiritualSection(title: 'Buddhism · Loving-kindness', reads: [
        SpiritualRead(
            title: 'Wishing yourself well',
            body:
                "Loving-kindness practice often begins by wishing yourself well, may you be safe, may you be peaceful. It is a tender reminder that you, too, deserve the gentleness you are giving."),
        SpiritualRead(
            title: 'Widening the circle',
            body:
                "From yourself, the good wishes widen, to your baby, your family, and outward to all beings. A simple wish for happiness and safety is a sweet thing to whisper to your bump."),
        SpiritualRead(
            title: 'Kindness as practice',
            body:
                "Here, kindness is not a mood but a practice you return to daily. Each small, warm choice strengthens it, and your child will feel that warmth."),
        SpiritualRead(
            title: 'Begin with yourself',
            body:
                "Loving-kindness often begins by wishing yourself well, may you be safe, may you be at peace. It is a tender reminder that you deserve the gentleness you give."),
        SpiritualRead(
            title: 'The circle grows',
            body:
                "From yourself, good wishes widen to your baby, your family, and outward. A simple wish for happiness is sweet to whisper to your bump."),
        SpiritualRead(
            title: 'Kindness, practised daily',
            body:
                "Here kindness is not a passing mood but a practice you return to daily. Each warm choice strengthens it, and your child will feel that warmth."),
        SpiritualRead(
            title: 'A wish for your baby',
            body:
                "Sending a gentle wish toward your baby, may you be safe, may you be loved, is a lovely habit. Said with a hand on your bump, it begins a quiet bond."),
        SpiritualRead(
            title: 'Kindness on hard days',
            body:
                "Loving-kindness is most needed on the days you feel least lovable. Offering yourself warmth then is the heart of the practice."),
        SpiritualRead(
            title: 'Soft words to yourself',
            body:
                "Speaking to yourself as you would to a dear friend is a form of this kindness. Trade the harsh inner voice for a gentler one."),
        SpiritualRead(
            title: 'Forgiving yourself',
            body:
                "Releasing yourself from yesterday's mistakes is an act of kindness. You are allowed to begin again, gently."),
        SpiritualRead(
            title: 'Warmth toward all',
            body:
                "The practice widens until it includes even strangers and difficult people. A general goodwill lightens your own heart most of all."),
        SpiritualRead(
            title: 'Kindness to the weary',
            body:
                "Extra gentleness for the tired, including yourself, fits this practice. On low days, soften what you ask of yourself."),
        SpiritualRead(
            title: 'A peaceful wish',
            body:
                "Wishing peace, for yourself and others, is simple and steadying. Even a silent may-all-be-at-ease calms the one who says it."),
        SpiritualRead(
            title: 'Kindness multiplies',
            body:
                "Warmth given tends to ripple outward and return. The gentleness you offer now grows beyond what you can see."),
        SpiritualRead(
            title: 'Small kind acts',
            body:
                "Loving-kindness lives in small acts as much as grand ones. A soft word or patient pause carries it."),
        SpiritualRead(
            title: 'A softening heart',
            body:
                "The practice gradually softens a guarded heart. As you open to your baby, that tenderness widens to everyone."),
        SpiritualRead(
            title: 'Kindness as calm',
            body:
                "A kind heart and a calm heart tend to be the same heart. Choosing kindness is also choosing peace for two."),
        SpiritualRead(
            title: 'May you be safe',
            body:
                "A simple repeated wish, may you be safe, may you be well, can settle a restless mind. Offer it first to yourself, then to your baby."),
        SpiritualRead(
            title: 'Holding others gently',
            body:
                "Picturing loved ones and silently wishing them well warms the heart. Your baby rides along in that circle of care."),
        SpiritualRead(
            title: 'Beginning with warmth',
            body:
                "Starting the day with one warm wish sets a gentle tone. A single kind thought, offered sincerely, is enough."),
      ]),
      SpiritualSection(title: 'Buddhism · Stories, simply retold', reads: [
        SpiritualRead(
            title: 'The middle path',
            body:
                "A well-known idea is the middle way, avoiding harsh extremes and choosing balance. In pregnancy that is wise and freeing: not too much pressure, not too little care, just gentle, steady balance."),
        SpiritualRead(
            title: 'Comfort in shared humanity',
            body:
                "A tender old story tells of a grieving mother who learns, gently, that loss has touched every household, and finds comfort in that shared humanity. Simply retold, it is a reminder that you are never as alone in your feelings as they seem."),
        SpiritualRead(
            title: 'A lamp passed on',
            body:
                "Stories often picture wisdom as a lamp passed from one person to the next, losing none of its light. The love and calm you carry now is a light you will pass to your child."),
        SpiritualRead(
            title: 'The second arrow',
            body:
                "A teaching describes how pain is like one arrow, but worrying about it is a second arrow we fire at ourselves. In pregnancy, you can feel the real discomfort without adding the extra arrow of fear."),
        SpiritualRead(
            title: 'Setting down the load',
            body:
                "An old story tells of a traveller who carried someone across a river, then walked on, while his companion kept carrying the memory for miles. It gently asks: what are you still carrying that you could set down?"),
        SpiritualRead(
            title: 'The cup already full',
            body:
                "A well-known tale tells of a teacher pouring tea into a cup until it overflows, to show that a full mind cannot receive. Making a little empty space, a quiet pause, lets new calm in."),
        SpiritualRead(
            title: 'Who knows what is good',
            body:
                "A gentle story follows a farmer who meets each turn of fortune with who knows whether this is good or bad. It is freeing in pregnancy, where not every surprise can be judged at once."),
        SpiritualRead(
            title: 'The cracked pot',
            body:
                "One tale tells of a cracked water pot that, leaking along the path, unknowingly watered a row of flowers. Our imperfections, too, can quietly bring beauty we never planned."),
        SpiritualRead(
            title: 'A single candle',
            body:
                "A loved image shows one candle lighting many others without losing any of its own flame. The love and calm you carry can be shared endlessly and never run out."),
        SpiritualRead(
            title: 'The raft you can put down',
            body:
                "A teaching likens helpful practices to a raft for crossing a river, useful, but not meant to be carried on your back forever. Hold your routines lightly; keep what helps, release the rest."),
        SpiritualRead(
            title: 'The blind men and the elephant',
            body:
                "An old story tells of several people each touching one part of an elephant and describing something different. It is a gentle reminder to hold our own view humbly, especially amid so much pregnancy advice."),
        SpiritualRead(
            title: 'A handful of leaves',
            body:
                "One tale pictures a teacher holding a few leaves, saying what truly matters is small and simple compared to a whole forest of ideas. For you, the essentials are few: rest, nourish, love."),
        SpiritualRead(
            title: 'The wise response',
            body:
                "A story tells of a calm man who, offered an insult, simply did not accept it, so it stayed with the giver. You can let unkind or anxious words pass without taking them in."),
        SpiritualRead(
            title: 'Drop by drop',
            body:
                "A simple image notes that a water pot fills drop by drop, and so does goodness. Your small daily acts of care are quietly filling something beautiful."),
        SpiritualRead(
            title: 'The strawberry on the cliff',
            body:
                "An old story tells of a traveller in danger who pauses to taste a wild strawberry, sweet, right then. It is a tender nudge to taste the good moments even in an uncertain stretch."),
        SpiritualRead(
            title: 'Carrying less',
            body:
                "A tale honours a wanderer who travelled light and was free because of it. Letting go of a few worries lightens your own road too."),
        SpiritualRead(
            title: 'The echo',
            body:
                "One story likens the world to an echo that returns what we call into it. The gentleness you send out tends to come back to you."),
        SpiritualRead(
            title: 'A quiet teacher',
            body:
                "Some stories show wisdom taught not by words but by a calm, steady presence. The calm you embody now teaches your baby before a single word is spoken."),
        SpiritualRead(
            title: 'The melting snow',
            body:
                "A gentle image watches snow melt in its own time, with no need to rush it. Your body and baby are unfolding at their own pace; you need not hurry them."),
        SpiritualRead(
            title: 'Footprints on water',
            body:
                "One reflection notes that troubles, like footprints on water, can close over and fade. Many of today's worries will quietly smooth away in time."),
      ]),
    ],
  ),
];
