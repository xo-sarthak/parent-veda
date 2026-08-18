// =============================================================================
//  Traditions: Ceremonies & Milestones — the section's content
// -----------------------------------------------------------------------------
//  Built from pp_specs/11-traditions.md, against the mechanism in
//  docs/PP-SECTION-PATTERN.md. Seven areas, twenty four pages.
//
//  ⚠️ THIS FILE IS DATA. No layout in it. `PpSectionScreen` renders the landing
//  and `PpContentPage` renders every page. See pp_content.dart's header.
//
//  ⚠️ SECULAR AND INCLUSIVE, NOT DEVOTIONAL. The spec is explicit and the data
//  behind it is explicit: "secular/cultural framing has the demand; scripture
//  branded framing does not". So a ceremony is presented as a rite of passage a
//  family performs, with the practical how-to, never as religious instruction.
//  No mantras are prescribed, no ritual is declared correct, and no faith is the
//  unmarked default in the copy even though the Hindu pages lead by search
//  demand. Area 5 exists so that a Muslim, Christian, Sikh, Jain or Parsi family
//  finds their own ceremony built to the same skeleton and the same voice,
//  rather than an afterthought.
//
//  ⚠️ THE ANTI-PRESSURE VOICE IS THE PRODUCT. Every page says, somewhere and
//  plainly, that the ceremony can be delayed, simplified or skipped, and that a
//  family who does none of this has lost nothing. Cost and family expectation
//  squeeze a lot of families and no competitor says so. Area 6 ("What it costs,
//  and how to keep it small") is a feature, not a footnote, and the script page
//  in it is the thing a mother will actually use at 11pm.
//
//  ⚠️ WHERE A CUSTOM IS HARMFUL, WE SAY SO CALMLY, AND WE NEVER MOCK ANYONE.
//  Kajal, honey, the umbilical stump, ghutti, water before six months, unsterile
//  blades, tight hip swaddling. Every one of these is done with love by someone
//  who believes it helps, usually a grandmother, and copy that sneers gets the
//  app closed and the practice continued. So: name the practice, name the harm
//  in one clean sentence, give the thing to do instead, and stop.
//
//  ⚠️ EVERY MEDICAL AND EVERY COST CLAIM BELOW IS MARKED `REQUIRED_REVIEW:` in
//  a comment directly above the block, so a human can sign each one off without
//  reading the whole file. Do not remove those markers until they are signed.
//
//  ⚠️ THE MULTI-FAITH "FILTER" THE SPEC ASKS FOR IS AN AREA, NOT A CONTROL.
//  A section author writes data and does not build chrome, and the section
//  screen has no filter widget. An area is the honest equivalent: it groups,
//  it is one tap, it never hides anything, and it does not ask a family to
//  declare its religion to the app before it can read. If a real toggle is
//  wanted later it belongs in `pp_section_screen.dart`, once, for all sections.
//
//  ⚠️ AGE AWARENESS IS THE BAND SET, AND CEREMONIES STAY BROWSABLE. Only the
//  four "what is coming up now" pages in Area 1 carry band tags. Every ceremony
//  page is untagged on purpose: a mundan page is still wanted by a parent whose
//  child is four, and a namkaran page is still read by someone helping a sister.
//  Bands narrow what LEADS, never what exists.
//
//  English only for now, plain `String`, per the standing instruction. Ceremony
//  names stay in the Hinglish a family actually says: namkaran, annaprashan,
//  mundan, chatti, jhula, godh bharai, nuskhe, aqiqah.
// =============================================================================

import 'package:flutter/material.dart' show Icons;

import 'pp_age_bands.dart';
import '../brackets/hub/hub_intent_art.dart';
import 'pp_content.dart';
import 'pp_section_screen.dart';

// =============================================================================
//  THE BANDS
// -----------------------------------------------------------------------------
//  Traditions has its own band set rather than reusing `kPpChildBands`, and the
//  reason is the shape of the ceremonies themselves: four of them fall inside
//  the first four months and one falls at six, so a single "0 to 12 months"
//  band would put the naming ceremony and the first solid meal on the same
//  page for a parent whose baby is three days old. The boundaries here are the
//  ceremony calendar, not a developmental one.
// =============================================================================

const PpBandSet kPpTraditionsBands = PpBandSet([
  PpBand(
    id: 'newborn',
    label: 'The first months',
    fromMonths: 0,
    toMonths: 4,
    blurb: 'Chatti, namkaran, the cradle, the first outing.',
  ),
  PpBand(
    id: 'half_year',
    label: '4 months to 1 year',
    fromMonths: 4,
    toMonths: 12,
    blurb: 'Annaprashan and the first solid meal.',
  ),
  PpBand(
    id: 'first_years',
    label: '1 to 3 years',
    fromMonths: 12,
    toMonths: 36,
    blurb: 'The first birthday, mundan, ear piercing.',
  ),
  PpBand(
    id: 'older',
    label: '3 to 5 years',
    fromMonths: 36,
    toMonths: 72,
    blurb: 'Aksharabhyasam, and the ceremonies of the older years.',
  ),
]);

// =============================================================================
//  THE SECTION
// =============================================================================

final PpSection kPpTraditionsSection = PpSection(
  id: 'parenting_traditional', // MUST match the hub's bracketId.
  title: 'Traditions',
  subtitle: 'Ceremonies & Milestones',
  intro: 'The ceremonies Indian families do for a new baby, explained simply. '
      'What actually happens, what you really need, what it costs, and what you '
      'can happily skip.',
  bandSet: kPpTraditionsBands,
  areas: [
    _whatsNow,
    _welcome,
    _firstMeal,
    _milestones,
    _otherFaiths,
    _keepItSmall,
    _notSafe,
  ],
  tools: [
    // ⚠️ BOTH OF THESE ARE LIVE AND REUSED, NOT REBUILT. `pp_names` is the
    // existing Baby Naming home (finder, meanings, couple swipe, astro) and
    // `pp_nuskhe` is the existing nuskhe screen. The spec's cell reconciliation
    // says LIVE means reuse, and a second naming tool would split one family's
    // shortlist across two stores.
    PpSectionTool(
      label: 'Find a name',
      blurb: 'Names by meaning, origin, sound and letter, with a shortlist you '
          'and your partner can build together.',
      surfaceId: 'pp_names',
      icon: Icons.auto_awesome_outlined,
    ),
    PpSectionTool(
      label: 'Dadi ke nuskhe, checked',
      blurb: 'The home remedies every family passes down, with an honest note '
          'on which ones are safe and which are not.',
      surfaceId: 'pp_nuskhe',
      icon: Icons.spa_outlined,
    ),
  ],
);

// =============================================================================
//  AREA 1 — What is coming up now
// -----------------------------------------------------------------------------
//  The only band-tagged area in the section. Its job is the spec's §9: surface
//  the ceremonies that are actually near, and let the rest stay browsable one
//  tap away. Each page is a calendar plus the links, which is genuinely the
//  thing a new parent asks first: "what is meant to happen, and when?"
// =============================================================================

final PpArea _whatsNow = PpArea(
  id: 'whats_now',
  mark: IntentMark.lampMark,
  title: 'Which ceremony is coming up now?',
  blurb: 'The order things usually happen in, and roughly when.',
  hue: 32,
  pages: [
    PpPage(
      id: 'now_newborn',
      title: 'The first months, in order',
      format: 'CHART-CARD',
      bands: ['newborn'],
      blocks: [
        PpIntro('In the first weeks a lot of names get thrown around. Chatti, '
            'namkaran, jhula, the first outing. Here they are in the order they '
            'usually come, with the day each one tends to fall on.'),
        PpChartCard(
          title: 'The usual order',
          subtitle: 'Counting from the day your baby was born',
          rows: [
            ('Day 6 or 7', 'Chatti or chhathi, the sixth day welcome'),
            ('Day 11 or 12', 'Namkaran, the naming'),
            ('Day 11 to 40', 'Jhula or palna, the cradle ceremony'),
            ('Around day 40', 'Nishkramana, the first outing'),
            ('No fixed day', 'Ear piercing, in families that do it early'),
          ],
          note: 'Every one of these days shifts by family and by region, and '
              'many families now fold two of them into one afternoon.',
          hue: 32,
        ),
        PpCallout('If these first weeks are hard, move the ceremony. A ritual '
            'done at two months instead of eleven days is not a smaller '
            'ritual. Nothing is lost by waiting until you can enjoy it.'),
        PpIndiaNote('In most joint families the date is picked by elders and '
            'you hear about it rather than choose it. If the date lands badly, '
            'say so early and give an alternative rather than a no. The page '
            'on family expectations has the exact words.'),
        PpLink('Chatti, the sixth day', pageId: 'chatti'),
        PpLink('Namkaran, the naming ceremony', pageId: 'namkaran'),
        PpLink('Jhula, the cradle ceremony', pageId: 'jhula'),
        PpLink('Nishkramana, the first outing', pageId: 'nishkramana'),
        PpLink('What to say when family wants it bigger',
            pageId: 'family_pressure'),
      ],
    ),
    PpPage(
      id: 'now_half_year',
      title: 'Coming up: her first solid meal',
      format: 'CHART-CARD',
      bands: ['half_year'],
      blocks: [
        PpIntro('The big one in this stretch is annaprashan, the first taste of '
            'solid food. It is the one ceremony that lines up almost exactly '
            'with what a paediatrician would tell you anyway.'),
        PpChartCard(
          title: 'What falls in this stretch',
          rows: [
            ('5 to 8 months', 'Annaprashan, the first solid food'),
            ('Around 6 months', 'Solids start, ceremony or not'),
            ('Any time', 'Ear piercing, in families that wait this long'),
            ('At 12 months', 'The first birthday'),
          ],
          note: 'Around six months is both the traditional window and the '
              'medical one, which is not a coincidence.',
          hue: 96,
        ),
        PpCallout('If the auspicious date lands at five months and your baby is '
            'not sitting or interested yet, do the ceremony with a symbolic '
            'lick and start real food when she is ready. The date and the diet '
            'do not have to be the same decision.'),
        PpLink('Annaprashan, the first solid meal', pageId: 'annaprashan'),
        PpLink('What to actually feed, on the day and after',
            pageId: 'annaprashan_food'),
        PpLink('Starting solids, step by step',
            surfaceId: 'pp_feeding',
            blurb: 'The feeding journey, with textures, portions and first '
                'foods.'),
      ],
    ),
    PpPage(
      id: 'now_first_years',
      title: 'Coming up: birthday, mundan, ears',
      format: 'CHART-CARD',
      bands: ['first_years'],
      blocks: [
        PpIntro('Between one and three the ceremonies get bigger and more '
            'public. This is also where the cost pressure lands hardest, so '
            'the page on keeping it small is worth reading before you book '
            'anything.'),
        PpChartCard(
          title: 'What falls in these two years',
          rows: [
            ('At 12 months', 'The first birthday'),
            ('Year 1 or year 3', 'Mundan, the first head shaving'),
            ('6 months to 5 years', 'Karnavedha, ear piercing'),
            ('From about 2 years', 'Aksharabhyasam, the start of learning'),
          ],
          note: 'Odd years are considered auspicious for mundan in most '
              'families, which is why it is usually one or three and rarely '
              'two.',
          hue: 268,
        ),
        PpCallout('A toddler has opinions now. Plan around the nap, keep the '
            'ceremony short, and accept in advance that he may cry through the '
            'important bit. That is not the ceremony going wrong.'),
        PpLink('Mundan, the first head shaving', pageId: 'mundan'),
        PpLink('Karnavedha, ear piercing', pageId: 'karnavedha'),
        PpLink('The first birthday', pageId: 'first_birthday'),
        PpLink('What a ceremony actually costs', pageId: 'what_it_costs'),
      ],
    ),
    PpPage(
      id: 'now_older',
      title: 'Coming up: the start of learning',
      format: 'CHART-CARD',
      bands: ['older'],
      blocks: [
        PpIntro('Between three and five there is one ceremony that most '
            'families still do, and it is a lovely one: the day a child writes '
            'a first letter. The rest of this stage is birthdays.'),
        PpChartCard(
          title: 'What falls in these years',
          rows: [
            ('2 to 5 years', 'Aksharabhyasam, the first letters'),
            ('Often at Vijayadashami', 'The traditional day for it'),
            ('Year 3, if not done at 1', 'Mundan, for families who waited'),
            ('7 to 11 years', 'Navjote, in Parsi families'),
            ('Around 11 years', 'Dastar Bandi, in Sikh families'),
          ],
          note: 'If a ceremony on this list has already passed for your child, '
              'nothing is owed. There is no making up for a missed date.',
          hue: 200,
        ),
        PpCallout('Aksharabhyasam marks a beginning, not a test. A child who '
            'traces a letter with help on the day and shows no interest for '
            'another year is completely normal.'),
        PpLink('Aksharabhyasam, the first letters', pageId: 'aksharabhyasam'),
        PpLink('Mundan, the first head shaving', pageId: 'mundan'),
        PpLink('Play that builds early learning',
            surfaceId: 'pp_activities',
            blurb: 'Age-matched play, with the reason each one helps.'),
      ],
    ),
  ],
);

// =============================================================================
//  AREA 2 — Welcoming her home
// =============================================================================

final PpArea _welcome = PpArea(
  id: 'welcome',
  mark: IntentMark.listMark,
  title: 'Welcoming her home',
  blurb: 'Chatti, namkaran, the cradle and the first outing.',
  hue: 24,
  pages: [
    // -------------------------------------------------------------------------
    //  Chatti
    // -------------------------------------------------------------------------
    PpPage(
      id: 'chatti',
      title: 'Chatti, the sixth day',
      subtitle: 'The first welcome, usually at home',
      format: 'CEREMONY',
      blocks: [
        PpIntro('Chatti, or chhathi, is the sixth night after birth. It is the '
            'first time the family formally welcomes the baby, and in many '
            'homes it is also the night the name is chosen or first said.'),
        PpArticle(
          heading: 'What it is',
          [
            'Historically the sixth night was the point at which a newborn was '
            'considered likely to thrive, and the family marked it with a '
            'small night gathering, sweets, and a lamp kept lit. The mother '
            'usually stays resting through it.',
            'It is a home ceremony almost everywhere. There is no venue, no '
            'invitation list and no fixed length. In many families it is an '
            'hour of singing after dinner and nothing more.',
          ],
        ),
        PpWhenLine('The sixth night after birth. Some families count the sixth '
            'day instead, and Punjabi and Gujarati families often keep the '
            'whole night awake, which is where the name jagrata comes from.'),
        PpTable(
          heading: 'What it is called where',
          columns: ['Where', 'What it is called'],
          rows: [
            ['North India', 'Chatti or chhathi, on the sixth night'],
            ['Gujarat', 'Chhathi, and often the naming night too'],
            ['Punjab', 'Chhati, frequently kept as a night vigil'],
            ['Bengal', 'Shashthi puja, for the goddess of the sixth day'],
            ['Maharashtra', 'Panchvi or sathi, depending on the family'],
            ['Tamil Nadu and Kerala', 'Usually folded into the naming day'],
          ],
        ),
        PpSteps(
          heading: 'How it usually goes',
          [
            PpStep('The room is cleaned and a lamp is lit',
                'Most families keep one lamp burning through the night.'),
            PpStep('A clean cloth, a pen and paper are placed near the baby',
                'The old idea is that the child\'s fate is written that night. '
                'Families keep the custom for the sentiment, not the belief.'),
            PpStep('The women of the house sing',
                'Sohar and badhai songs. This is usually the warmest part of '
                'the evening and costs nothing.'),
            PpStep('Sweets are shared and something is given away',
                'Often clothes or food to household help, or to a family who '
                'needs it.'),
            PpStep('The name may be said aloud for the first time',
                'In many families this is where namkaran actually happens, and '
                'the eleventh day ceremony is skipped entirely.'),
          ],
        ),
        PpCards(
          heading: 'What you need',
          hue: 24,
          [
            PpCard('A lamp', 'One diya. Kept away from the cot and never left '
                'burning unattended in the same room as the baby.'),
            PpCard('Sweets', 'Whatever the house makes. Halwa, laddoo, kheer.'),
            PpCard('A clean new cloth for the baby',
                'Washed before use, soft, nothing scratchy at the neck.'),
            PpCard('A pen and a blank page',
                'Symbolic. Placed near the cot, not in it.'),
            PpCard('Songs', 'A phone with the sohar your mother knows is '
                'completely fine if nobody remembers the words.'),
          ],
        ),
        PpCallout('What actually matters is that the household stops for an '
            'evening and marks that the baby is here. The lamp, the songs and '
            'the sweets are the ceremony. Everything else is decoration.'),
        PpCards(
          heading: 'Genuinely optional',
          hue: 340,
          [
            PpCard('A priest', 'Most families do chatti without one.'),
            PpCard('Staying awake all night',
                'A vigil with a six day old baby and a healing mother is a lot. '
                'An hour of singing counts.'),
            PpCard('Inviting the extended family',
                'A six day old baby has no immune reserve to spare. Small is '
                'the safer version and it is also the traditional one.'),
            PpCard('New clothes for everyone',
                'Nothing about the ceremony requires anyone to shop.'),
          ],
        ),
        // REQUIRED_REVIEW: newborn infection exposure at a gathering. Claim to
        // confirm: an under-3-month baby has limited immune defence, so keeping
        // the group small, excluding anyone unwell, handwashing before holding
        // and no kissing the face are the standard precautions.
        PpCallout(
          'Keep the group small and ask anyone with a cough, cold or fever to '
          'come another week. Everyone washes hands before holding her, and '
          'nobody kisses her face or hands. A cold that is nothing in an adult '
          'is not nothing in a six day old.',
          kind: PpCalloutKind.safety,
          title: 'Six days old is very new',
        ),
        // REQUIRED_REVIEW: fever threshold in a young infant. Claim to confirm:
        // any fever of 100.4F / 38C or above in a baby under 3 months needs to
        // be seen the same day, no waiting.
        PpCallout(
          'A fever of 100.4F, or 38C, in a baby under three months is a same '
          'day reason to see a doctor, whatever else seems fine. So is a baby '
          'who has gone unusually floppy, is refusing feeds, or will not wake '
          'properly. Do not wait for morning.',
          kind: PpCalloutKind.doctor,
          title: 'If she is unwell after the gathering',
        ),
        PpIndiaNote('If the mother is in jaapa and not up to a room full of '
            'people, that is normal and it is allowed. She can be greeted, '
            'stay in her room, and come out for ten minutes if she wants to.'),
        PpVideoSlot(
          title: 'What actually happens on chatti',
          subtitle: 'A real family, a small home ceremony, start to finish.',
          minutes: '5 MIN',
          slotId: 'traditions/chatti',
        ),
        PpLink('Namkaran, if the name is being said tonight', pageId: 'namkaran'),
        PpLink('Customs done with love that are not safe',
            pageId: 'newborn_customs'),
      ],
    ),

    // -------------------------------------------------------------------------
    //  Namkaran
    // -------------------------------------------------------------------------
    PpPage(
      id: 'namkaran',
      title: 'Namkaran, the naming ceremony',
      subtitle: 'The day her name is said out loud',
      format: 'CEREMONY',
      blocks: [
        PpIntro('Namkaran is the day your baby is formally given her name and '
            'it is spoken in front of the people who love her. In most families '
            'it happens in the first two weeks, at home, and takes under an '
            'hour.'),
        PpArticle(
          heading: 'What it is, and where it comes from',
          [
            'Naming a child in front of witnesses is one of the oldest rites '
            'there is, and almost every culture in India has a version of it. '
            'The point is public: the family says the name, everyone repeats '
            'it, and from that day the child is called by it.',
            'In practice this is the ceremony families are most attached to '
            'and least rigid about. The date moves, the guest list shrinks, '
            'the priest is optional in most homes. The name being said aloud '
            'is the part nobody skips.',
          ],
        ),
        PpWhenLine('Traditionally the eleventh or twelfth day after birth. '
            'Many families now do it any time in the first three months, often '
            'once the mother is out of jaapa and up to hosting.'),
        PpTable(
          heading: 'What it is called where',
          columns: ['Where', 'What it is called'],
          rows: [
            ['North India', 'Namkaran, usually on day 11 or 12'],
            ['Maharashtra', 'Barsa, on the twelfth day, with the cradle'],
            ['Tamil Nadu', 'Namakaranam or peyar suttal, with the thottil'],
            ['Kerala', 'Namakaranam, often on day 27 or 28'],
            ['Karnataka and Telugu states', 'Namakaranam, with the uyyala'],
            ['Bengal', 'The name is often given at the annaprashan instead'],
            ['Gujarat', 'Chhathi night doubles as the naming'],
            ['Punjab', 'Naam Karan, read from the Guru Granth Sahib'],
          ],
        ),
        PpSteps(
          heading: 'How it usually goes',
          [
            PpStep('A clean space is set up, usually a low table',
                'A cloth, a lamp, flowers. Ten minutes of work.'),
            PpStep('The family gathers and the baby is brought in',
                'Traditionally by the father or the grandmother, dressed in '
                'something new.'),
            PpStep('A short prayer or blessing is said',
                'A priest does this in some families. In many, the eldest '
                'person present simply says a blessing in their own words.'),
            PpStep('The name is whispered in the baby\'s ear',
                'Usually by the father or an aunt, three times. This is the '
                'moment the whole ceremony is built around.'),
            PpStep('The name is announced to the room',
                'Everyone repeats it. Some families write it on a plate of '
                'rice with a small stick or a gold ring.'),
            PpStep('Sweets are shared and blessings are given',
                'Elders bless the baby, often placing a hand on her head or '
                'giving a small gift. Then it is over.'),
          ],
        ),
        PpCards(
          heading: 'What you need',
          hue: 268,
          [
            PpCard('A name you have both agreed on',
                'Agree the day before, not on the day. This is the single '
                'biggest source of ceremony morning stress.'),
            PpCard('A low table and a clean cloth',
                'Any table, any clean cloth. It does not have to be new.'),
            PpCard('A lamp, flowers and rice',
                'A diya, whatever flowers are available, a plate of raw rice '
                'if the name is being written.'),
            PpCard('Something new for the baby to wear',
                'Washed once before the day. New fabric straight off a shelf '
                'can be stiff and dyed.'),
            PpCard('Sweets to share',
                'Made at home or bought. Nobody has ever judged the mithai.'),
            PpCard('A priest, only if your family wants one',
                'Dakshina is usually between Rs 500 and Rs 2,100.'),
          ],
        ),
        PpCallout('What actually matters: the name is said out loud, and the '
            'people who matter hear it. The priest, the hall, the outfits and '
            'the photographer are all optional, and a namkaran done by four '
            'people in a bedroom is a complete namkaran.'),
        PpCards(
          heading: 'Genuinely optional',
          hue: 340,
          [
            PpCard('A specific auspicious letter',
                'Many families pick a starting letter from the birth star. If '
                'you have already chosen a name you love, using it as a second '
                'name or a nickname keeps everyone happy.'),
            PpCard('A banquet hall',
                'This is a fifteen minute ceremony. The hall is for the lunch '
                'after it, and the lunch is optional too.'),
            PpCard('Matching outfits',
                'Lovely if you want them. Not part of anything.'),
            PpCard('Doing it on day eleven',
                'A newborn and a healing mother beat a date every time.'),
          ],
        ),
        // REQUIRED_REVIEW: legal/administrative claim, not medical. To confirm:
        // under the Registration of Births and Deaths Act, a birth is normally
        // registered within 21 days, and the name can be added to the record
        // afterwards, with the procedure and any late fee varying by state and
        // municipality.
        PpCallout(
          'The ceremony and the paperwork are two different things. In most '
          'states the birth is registered within 21 days, and the name can be '
          'added to the record afterwards if you have not decided yet. Check '
          'the exact rule with your municipal office or the hospital, because '
          'it varies by state.',
          title: 'The birth certificate is separate',
        ),
        // REQUIRED_REVIEW: newborn gathering precautions, same claim as chatti.
        PpCallout(
          'She is still very new. Keep the room airy, keep the group small, '
          'and ask anyone with a cough or cold to come another day. Hands '
          'washed before holding, and no kissing her face. If she is upset by '
          'the noise, take her out of the room. The ceremony can wait ten '
          'minutes and she cannot.',
          kind: PpCalloutKind.safety,
          title: 'Keeping a two week old comfortable',
        ),
        PpIndiaNote('If elders want a priest and you do not, the usual middle '
            'ground works: a short traditional blessing done by the eldest in '
            'the family. It costs nothing, it satisfies almost everyone, and '
            'it is what most homes did before priests were bookable by phone.'),
        PpVideoSlot(
          title: 'A namkaran, start to finish',
          subtitle: 'A small home ceremony, with the naming moment shown '
              'properly.',
          minutes: '6 MIN',
          slotId: 'traditions/namkaran',
        ),
        PpLink('Find a name, by meaning, origin or letter',
            surfaceId: 'pp_names',
            blurb: 'Search by meaning or sound, check the letter, shortlist '
                'together.'),
        PpLink('Make a naming announcement card',
            surfaceId: 'pp_memories',
            blurb: 'Pick a template, add her name and a photo, share it.'),
        PpLink('Ceremony essentials, if you are buying',
            surfaceId: 'pp_products',
            blurb: 'Silver spoon sets, outfits, thali sets. Compare before you '
                'buy.'),
        PpLink('How to keep it small', pageId: 'keeping_it_small'),
      ],
    ),

    // -------------------------------------------------------------------------
    //  Jhula
    // -------------------------------------------------------------------------
    PpPage(
      id: 'jhula',
      title: 'Jhula, the cradle ceremony',
      subtitle: 'The day she is placed in her cradle for the first time',
      format: 'CEREMONY',
      blocks: [
        PpIntro('The jhula, palna or thottil ceremony is the first time the '
            'baby is placed in her cradle, with the family watching and '
            'singing. In many south Indian families the naming happens in the '
            'same hour, in the cradle.'),
        PpArticle(
          heading: 'What it is',
          [
            'It is a handover moment. Until now the baby has been in arms; the '
            'cradle is the first place that belongs to her. The grandmother '
            'usually places her in it, the family sings, and the cradle is '
            'rocked for the first time.',
            'It is short, it is warm, and it is one of the least expensive '
            'ceremonies there is. In a lot of homes it is folded into the '
            'naming and takes fifteen minutes.',
          ],
        ),
        PpWhenLine('Usually between day 11 and day 40, most often on the same '
            'day as the naming. In Maharashtra it is the barsa on day 12; in '
            'Tamil Nadu and Kerala the thottil is often on day 28.'),
        PpTable(
          heading: 'What it is called where',
          columns: ['Where', 'What it is called'],
          rows: [
            ['North India', 'Jhula or palna'],
            ['Maharashtra', 'Barsa, the cradle and naming together'],
            ['Tamil Nadu', 'Thottil, often on the 28th day'],
            ['Kerala', 'Thottilil kidathal'],
            ['Telugu states', 'Uyyala or uyyala salla'],
            ['Karnataka', 'Tottilu shastra'],
          ],
        ),
        PpSteps(
          heading: 'How it usually goes',
          [
            PpStep('The cradle is decorated',
                'Flowers, a garland, sometimes mango leaves across the top. '
                'Nothing that can fall in.'),
            PpStep('The baby is dressed and brought in by a grandmother or '
                'aunt'),
            PpStep('She is placed in the cradle for the first time',
                'On her back, on a firm flat surface, with nothing loose '
                'around her.'),
            PpStep('The cradle is rocked gently while the family sings',
                'A lori. In many families each aunt sings one line.'),
            PpStep('The name may be said here',
                'In south Indian families the naming and the cradle are one '
                'ceremony.'),
            PpStep('Blessings, sweets, and it is done'),
          ],
        ),
        PpCards(
          heading: 'What you need',
          hue: 24,
          [
            PpCard('A cradle',
                'A cloth jhula, a wooden palna, or a modern cot. The ceremony '
                'does not care which.'),
            PpCard('Flowers or a garland',
                'Tied on the outside, above where she lies, not draped across '
                'her.'),
            PpCard('A firm flat mattress and one thin sheet',
                'This is the only part of the cradle that is a safety matter, '
                'not a style one.'),
            PpCard('A lori somebody knows',
                'Any lullaby. It is the voice that settles her, not the tune.'),
            PpCard('Sweets to share',
                'Whatever the house makes. Nobody has ever judged the mithai.'),
          ],
        ),
        PpCallout('What actually matters is that she goes into a safe cradle '
            'and somebody sings. Marigolds, a silver rattle and a videographer '
            'are all fully optional.'),
        // REQUIRED_REVIEW: safe sleep in a cradle or cloth jhula. Claims to
        // confirm: firm flat mattress, on the back, no pillows or loose cloth,
        // nothing tied above that can fall in, do not swing hard or leave a
        // baby unattended in a hanging cloth jhula, and check the hook or
        // suspension of a hanging cradle before the first use.
        PpCallout(
          'Before she goes in, check three things. The mattress is firm and '
          'flat with no pillow, no quilt and no loose cloth around her. '
          'Nothing is tied above her that could come loose and fall in. And if '
          'it is a hanging cloth jhula, the hook and knots are tested with '
          'your own weight pulling on them first. Rock it gently, never swing '
          'it hard, and do not leave her sleeping in a hanging jhula '
          'unwatched.',
          kind: PpCalloutKind.safety,
          title: 'The cradle itself',
        ),
        PpCallout(
          'Rocking a baby hard, or shaking a cradle to stop crying, can injure '
          'a young baby\'s brain. Slow and small is the whole technique. If '
          'crying has pushed you past patience, put her down somewhere safe '
          'and step out of the room for two minutes. That is the right move, '
          'not a failure.',
          kind: PpCalloutKind.safety,
          title: 'Gently, always',
        ),
        PpIndiaNote('A cloth jhula tied to a beam is what most of India uses '
            'and it works. The safety points are the same as any cot: firm '
            'surface, on her back, nothing loose. A baby who sleeps in a jhula '
            'is not sleeping worse than one in an imported cot.'),
        PpVideoSlot(
          title: 'The cradle ceremony, and setting the jhula up safely',
          subtitle: 'How it is done, and the three checks before she goes in.',
          minutes: '5 MIN',
          slotId: 'traditions/jhula',
        ),
        PpLink('Namkaran, if you are doing both together', pageId: 'namkaran'),
        PpLink('Lori and sleep sounds',
            surfaceId: 'pp_sleep_sounds',
            blurb: 'Lori, white noise and soft ragas, with a timer.'),
      ],
    ),

    // -------------------------------------------------------------------------
    //  Nishkramana
    // -------------------------------------------------------------------------
    PpPage(
      id: 'nishkramana',
      title: 'Nishkramana, the first outing',
      subtitle: 'The first time she leaves the house',
      format: 'CEREMONY',
      blocks: [
        PpIntro('Nishkramana marks the first time the baby is taken out of the '
            'house, traditionally to see the sun, the moon or a temple. It is '
            'one of the gentlest ceremonies there is, and one of the easiest '
            'to do symbolically at home.'),
        PpArticle(
          heading: 'What it is',
          [
            'For most of history the first weeks indoors were about keeping a '
            'newborn away from infection and weather, and the outing marked '
            'the end of that quiet period. The ceremony is simply the family '
            'stepping outside together with the baby for the first time.',
            'This is where ParentVeda will be honest with you: the old custom '
            'and current paediatric advice agree more than they disagree. '
            'Keeping a very young baby away from crowds is sensible. The '
            'question is only whether the outing has to be to a crowded place '
            'on a fixed day.',
          ],
        ),
        PpWhenLine('Traditionally around the fortieth day, or in the fourth '
            'month in some families. In practice, when the mother and the baby '
            'are both well enough, which is the version that was always meant.'),
        PpTable(
          heading: 'What it is called where',
          columns: ['Where', 'What it is called'],
          rows: [
            ['Sanskrit and north India', 'Nishkramana'],
            ['Tamil Nadu', 'Veliye kootti varudhal, the first taking out'],
            ['Kerala', 'Often combined with the first temple visit'],
            ['Maharashtra', 'The first darshan, usually after the fortieth day'],
            ['Bengal', 'Usually folded into the first temple or river visit'],
          ],
        ),
        PpSteps(
          heading: 'How it usually goes',
          [
            PpStep('A time is chosen, usually early morning or evening',
                'Which is also the sensible time. Midday sun and a six week '
                'old are a poor combination.'),
            PpStep('The baby is dressed and often has a small kajal dot placed '
                'behind the ear or on the foot',
                'Behind the ear or on the sole, never near or in the eyes. The '
                'safety page explains why.'),
            PpStep('The family steps out together',
                'Traditionally the father or grandfather carries her over the '
                'threshold.'),
            PpStep('She is shown the sun, the moon or the sky',
                'This is the actual moment. It takes about a minute.'),
            PpStep('Some families visit a temple, a gurdwara, a church or a '
                'river',
                'Whatever the family\'s place is. Choose a quiet hour.'),
            PpStep('Back home, and that is the ceremony done'),
          ],
        ),
        PpCards(
          heading: 'What you need',
          hue: 200,
          [
            PpCard('A quiet time of day',
                'Early morning or after sunset. Not noon, not a festival day.'),
            PpCard('Light cotton and a thin cover',
                'India is hot. Overdressing a newborn is far more common than '
                'underdressing one.'),
            PpCard('A carrier or the grandmother\'s arms',
                'Whatever means she is held, not passed around a queue.'),
            PpCard('Somewhere uncrowded to go',
                'A terrace, a garden, a temple at an empty hour. A mall is not '
                'the tradition.'),
          ],
        ),
        PpCallout('The symbolic version is a real version. Opening a window at '
            'sunrise, saying the blessing, and showing her the sky from your '
            'own balcony is a complete nishkramana. Many families now do '
            'exactly this and go to the temple weeks later.'),
        // REQUIRED_REVIEW: newborn outings. Claims to confirm: avoiding
        // crowded indoor places and anyone unwell in the early weeks, shade
        // and no direct midday sun for young infants, sunscreen generally not
        // advised under 6 months so shade and clothing instead, and that
        // routine immunisations at 6 weeks are a sensible thing to have had.
        PpCallout(
          'For a first outing, pick shade over sun and empty over crowded. '
          'Direct midday sun is too much for a young baby\'s skin, and '
          'sunscreen is generally not recommended under six months, so shade '
          'and light cotton do the work. Avoid crowded indoor places, and keep '
          'her out of the arms of anyone who is unwell.',
          kind: PpCalloutKind.safety,
          title: 'Sun, crowds and the first trip out',
        ),
        PpCallout(
          'If she develops a fever after an outing, a baby under three months '
          'with a temperature of 100.4F or 38C needs a doctor the same day. '
          'Also see a doctor for fast or laboured breathing, a baby who will '
          'not feed, or one who has become unusually floppy or hard to wake.',
          kind: PpCalloutKind.doctor,
          title: 'If she is unwell afterwards',
        ),
        PpIndiaNote('If your family holds to the fortieth day and the weather '
            'is brutal, do the ceremony at dawn. Nobody in the tradition '
            'intended a newborn to be carried through 42 degrees at noon to '
            'satisfy a date.'),
        PpVideoSlot(
          title: 'The first outing, done gently',
          subtitle: 'Both versions, the temple visit and the at home one.',
          minutes: '4 MIN',
          slotId: 'traditions/nishkramana',
        ),
        PpLink('Her vaccinations, and what is due',
            surfaceId: 'pp_vaccines',
            blurb: 'The schedule, what each one is for, and reminders.'),
        PpLink('Customs done with love that are not safe',
            pageId: 'newborn_customs'),
      ],
    ),
  ],
);

// =============================================================================
//  AREA 3 — Her first solid meal
// -----------------------------------------------------------------------------
//  Annaprashan is the highest demand ceremony in the section, and it is the one
//  place where a ceremony page and a feeding page have to agree. The ritual
//  page covers the ceremony; the second page covers what actually goes in her
//  mouth, because "kheer with sugar and honey at six months" is the single most
//  common harmful overlap between the two.
// =============================================================================

final PpArea _firstMeal = PpArea(
  id: 'first_meal',
  mark: IntentMark.feedMark,
  title: 'Her first solid meal',
  blurb: 'Annaprashan, and what to actually feed on the day.',
  hue: 96,
  pages: [
    PpPage(
      id: 'annaprashan',
      title: 'Annaprashan, the first solid food',
      subtitle: 'The first grain, usually around six months',
      format: 'CEREMONY',
      blocks: [
        PpIntro('Annaprashan is the ceremony where a baby is given solid food '
            'for the first time, usually a spoon of kheer or sweetened rice '
            'fed by an uncle or grandfather. It is the most widely performed '
            'baby ceremony in India, and the one that best matches medical '
            'advice.'),
        PpArticle(
          heading: 'What it is, and why the timing is good',
          [
            'Anna means grain and prashan means feeding. The ceremony marks '
            'the point where a baby starts on food as well as milk, and it '
            'sits at around six months in almost every version of it.',
            'That is close to what paediatricians recommend anyway: milk only '
            'for about the first six months, then solids alongside continued '
            'breastfeeding or formula. So annaprashan is a rare case where the '
            'tradition and the guidance point at the same month, and you do '
            'not have to choose between your family and your doctor.',
          ],
        ),
        PpWhenLine('Around six months. Traditionally an even month for boys, '
            'often the sixth or eighth, and an odd month for girls, often the '
            'fifth or seventh. Families vary and so do priests.'),
        PpTable(
          heading: 'What it is called where',
          columns: ['Where', 'What it is called'],
          rows: [
            ['North India', 'Annaprashan'],
            ['Bengal', 'Mukhe bhaat, the rice in the mouth'],
            ['Kerala', 'Choroonu, usually at a temple'],
            ['Garhwal and Kumaon', 'Bhath khulai'],
            ['Tamil Nadu', 'Annaprasanam or chor oottu'],
            ['Karnataka and Telugu states', 'Annaprasana'],
          ],
        ),
        PpSteps(
          heading: 'How it usually goes',
          [
            PpStep('A time is fixed, usually late morning',
                'Pick a slot right after a nap and before she is starving. A '
                'tired or ravenous baby will not cooperate.'),
            PpStep('The food is cooked, often kheer or plain sweet rice',
                'Traditionally made by the grandmother. Cooked soft, mashed '
                'smooth, and cooled properly.'),
            PpStep('She is dressed and seated on a lap or in a decorated chair',
                'Upright and supported. Never lying back while being fed.'),
            PpStep('A short blessing is said'),
            PpStep('The first spoon is given, usually by the maternal uncle or '
                'the grandfather',
                'One small spoon, from a silver or steel spoon. She may taste '
                'it, spit it out, or ignore it entirely. All three are fine.'),
            PpStep('The family takes turns to feed a token spoon',
                'This is where it can get carried away. One or two tokens is '
                'plenty for a six month old.'),
            PpStep('In some families, objects are placed in front of her to '
                'choose from',
                'A pen, a book, a coin, some clay. Whichever she reaches for '
                'is said to suggest her path. It is a game, and it is a lovely '
                'photo.'),
          ],
        ),
        PpCards(
          heading: 'What you need',
          hue: 96,
          [
            PpCard('A silver or steel bowl and spoon',
                'Silver is traditional. Steel works identically. A soft '
                'weaning spoon is kinder on her gums than metal.'),
            PpCard('The first food itself',
                'Kheer, sweet rice, or plain mashed rice with dal water. See '
                'the next page for what suits a six month old.'),
            PpCard('A bib and a cloth',
                'Most of the first meal ends up on her chin.'),
            PpCard('A chair or a lap she can sit upright in',
                'Upright and supported, never reclined. A high chair works, so '
                'does a grandfather.'),
            PpCard('The choosing objects, if your family does that bit',
                'Nothing small enough to go in her mouth. No coins within '
                'reach.'),
            PpCard('New clothes, if you want them',
                'Cotton, loose, nothing tight at the neck for a meal.'),
          ],
        ),
        PpCallout('What actually matters is that she is upright, awake, calm, '
            'and that the food is soft and cool. Whether she eats it is not '
            'the measure of anything. Plenty of babies lick the spoon once at '
            'their own annaprashan and that is a complete ceremony.'),
        PpCards(
          heading: 'Genuinely optional',
          hue: 340,
          [
            PpCard('A temple or a hall',
                'Choroonu at Guruvayur is beautiful and a home version counts '
                'the same.'),
            PpCard('Twenty relatives each feeding a spoon',
                'Two is a ceremony. Twenty is a lot of sugar and a lot of '
                'hands near her mouth.'),
            PpCard('Sweetened kheer specifically',
                'The grain is the point. Plain rice, ragi or dal water is a '
                'better first food and is still fully traditional.'),
            PpCard('An exact auspicious month',
                'If the date lands before she can sit with support, do the '
                'ceremony symbolically and start real solids when she is '
                'ready.'),
          ],
        ),
        // REQUIRED_REVIEW: infant feeding claims. To confirm: honey is not to
        // be given before 12 months because of infant botulism risk; added
        // salt and sugar are not recommended in the first year; solids are
        // recommended from around 6 months and not before 4 months; readiness
        // signs are sitting with support, good head control, and interest in
        // food; food should be lukewarm and tested by the adult first.
        PpCallout(
          'Three rules for the food on the day. No honey, not even a drop, '
          'until she is one year old. No added salt or sugar in the first '
          'year. And test the temperature on your own wrist before the spoon '
          'goes anywhere near her, because kheer holds heat far longer than it '
          'looks like it does.',
          kind: PpCalloutKind.safety,
          title: 'What goes in the bowl',
        ),
        PpCallout(
          'If she coughs, gags repeatedly, goes silent and red, or brings up '
          'the feed forcefully, stop and let her recover sitting upright. '
          'Talk to your doctor before the ceremony if she was premature, has '
          'reflux, has had trouble swallowing, or has not started solids yet '
          'at seven months. A paediatrician can tell you in one visit whether '
          'she is ready.',
          kind: PpCalloutKind.doctor,
          title: 'If feeding does not go smoothly',
        ),
        PpIndiaNote('If your family fixes the date by the panchang and it '
            'falls at five months, the middle ground almost everyone accepts '
            'is a symbolic touch of the spoon on the day, and the first real '
            'meals started at six months. You keep the date and she keeps her '
            'gut.'),
        PpVideoSlot(
          title: 'An annaprashan, and the first spoon',
          subtitle: 'How the ceremony runs, and how to hold and feed her '
              'safely during it.',
          minutes: '7 MIN',
          slotId: 'traditions/annaprashan',
        ),
        PpLink('What to actually feed, on the day and after',
            pageId: 'annaprashan_food'),
        PpLink('Starting solids, step by step',
            surfaceId: 'pp_feeding',
            blurb: 'Textures, portions, first foods and how the first month '
                'of solids usually goes.'),
        PpLink('Recipes for the first year',
            surfaceId: 'pp_food',
            blurb: 'Age matched Indian recipes, with textures.'),
        PpLink('Thali sets, silver spoons and outfits',
            surfaceId: 'pp_products',
            blurb: 'Ceremony essentials, compared before you buy.'),
      ],
    ),
    PpPage(
      id: 'annaprashan_food',
      title: 'What to actually feed, on the day and after',
      subtitle: 'The ceremony food, and the real food that follows it',
      format: 'CARDS',
      blocks: [
        PpIntro('The ceremony gives her one spoon. The weeks after it are the '
            'part that actually feeds her. Here is what suits a six month old, '
            'and the short list of things that genuinely should not go in the '
            'bowl.'),
        PpCards(
          heading: 'Good first foods, all of them traditional',
          hue: 96,
          [
            PpCard('Plain rice, cooked soft and mashed',
                'The classic annaprashan food, and a fine first food. Thin it '
                'with dal water or milk.'),
            PpCard('Ragi porridge',
                'Iron and calcium, easy to digest, and what most of south '
                'India starts with.'),
            PpCard('Moong dal water, then mashed dal',
                'Protein and iron, and gentle on a new gut.'),
            PpCard('Mashed banana, apple stewed soft, or papaya',
                'Sweet enough on their own that no sugar is needed.'),
            PpCard('Steamed and mashed vegetables',
                'Bottle gourd, pumpkin, carrot, potato. Smooth at first, '
                'lumpier by eight months.'),
            PpCard('Ghee, a quarter spoon',
                'Traditional, useful calories, and completely fine.'),
          ],
        ),
        // REQUIRED_REVIEW: the "not before one" list. To confirm each item:
        // honey (infant botulism, under 12 months); added salt (immature
        // kidneys) and added sugar; cow or buffalo milk as a main drink before
        // 12 months, though small amounts in cooking are usually fine; whole
        // nuts, whole grapes, popcorn and hard raw pieces as choking hazards;
        // water in more than sips before 6 months.
        PpCards(
          heading: 'Not before her first birthday',
          hue: 8,
          [
            PpCard('Honey',
                'Not a drop before twelve months. Honey can carry spores that '
                'a baby\'s gut cannot yet handle, and infant botulism is '
                'serious. This includes honey in kheer and honey on a soother.'),
            PpCard('Added salt',
                'Her kidneys are not ready for it. Cook her portion out before '
                'you salt the family pot.'),
            PpCard('Added sugar',
                'Not needed, and it trains a preference early. Fruit is sweet '
                'enough.'),
            PpCard('Cow or buffalo milk as a drink',
                'Breast milk or formula stays the main milk until one. Milk in '
                'cooking, such as in kheer, is a different thing and is '
                'usually fine.'),
            PpCard('Whole nuts, whole grapes, popcorn, hard raw pieces',
                'Choking hazards. Nuts as a fine powder in porridge are fine; '
                'a whole almond is not.'),
          ],
        ),
        PpCallout(
          'Give food in small amounts at first and introduce one new thing '
          'every two or three days, so that if something disagrees with her '
          'you know what it was. Always seated upright, always with an adult '
          'watching, never in a moving car or a rocking cradle.',
          kind: PpCalloutKind.safety,
          title: 'How to introduce anything new',
        ),
        PpCallout(
          'See a doctor the same day for a rash with swelling around the lips '
          'or eyes, vomiting after a new food, or any change in breathing '
          'after eating. Any difficulty breathing, or a baby who goes limp, is '
          'an emergency, so call for help rather than waiting to see. Talk to '
          'your paediatrician before introducing peanut, egg or dairy if there '
          'is a strong family history of allergy.',
          kind: PpCalloutKind.doctor,
          title: 'Signs of a food reaction',
        ),
        PpCallout(
          'Rice water or dal water instead of milk is not a step up. Until she '
          'is one, milk still carries most of her nutrition and solids are '
          'practice and iron. Do not cut feeds to make room for food.',
          kind: PpCalloutKind.myth,
          title: '"Solids started, so reduce the milk"',
        ),
        PpIndiaNote('If the kheer for the ceremony is being made by a '
            'grandmother, ask for her portion to be lifted out before the '
            'sugar and honey go in. It is an easy sentence to say in advance '
            'and an awkward one to say in front of everyone on the day.'),
        PpLink('Starting solids, step by step', surfaceId: 'pp_feeding'),
        PpLink('Recipes matched to her age', surfaceId: 'pp_food'),
        PpLink('Annaprashan, the ceremony itself', pageId: 'annaprashan'),
      ],
    ),
  ],
);

// =============================================================================
//  AREA 4 — Hair, ears and the first birthday
// =============================================================================

final PpArea _milestones = PpArea(
  id: 'milestones',
  mark: IntentMark.stepsMark,
  title: 'Hair, ears and the first birthday',
  blurb: 'Mundan, ear piercing, the first birthday, and the first letters.',
  hue: 268,
  pages: [
    // -------------------------------------------------------------------------
    //  Mundan
    // -------------------------------------------------------------------------
    PpPage(
      id: 'mundan',
      title: 'Mundan, the first head shaving',
      subtitle: 'Usually in the first or third year',
      format: 'CEREMONY',
      blocks: [
        PpIntro('Mundan is the ceremony where a child\'s birth hair is shaved '
            'off for the first time. It is done at home, at a temple or at a '
            'family shrine, and it is over in about ten minutes of actual '
            'shaving.'),
        PpArticle(
          heading: 'What it is',
          [
            'Birth hair is treated as belonging to the time before, and '
            'removing it marks a fresh start. In many families the hair is '
            'then offered at a temple or a river, or buried under a tree.',
            'It is also, practically, a toddler having his head shaved by a '
            'stranger while a crowd watches. Almost every child cries. That is '
            'expected, it is not a bad omen, and it is not a reflection on '
            'anybody.',
          ],
        ),
        PpWhenLine('Most often in the first year or the third year. Odd years '
            'are considered auspicious in most families, which is why it is '
            'rarely done at two. Some families do it as late as five or seven.'),
        PpTable(
          heading: 'What it is called where',
          columns: ['Where', 'What it is called'],
          rows: [
            ['Sanskrit and north India', 'Chudakarana or mundan'],
            ['Maharashtra', 'Jawal or choula'],
            ['Tamil Nadu', 'Mottai adithal'],
            ['Kerala', 'Mudi kalayal, often at a temple'],
            ['Telugu states', 'Puttu ventrukalu teeyadam'],
            ['Punjab and the north', 'Mundan, often at a family shrine'],
          ],
        ),
        PpSteps(
          heading: 'How it usually goes',
          [
            PpStep('A place and a barber are arranged in advance',
                'Home, temple or a known salon. Ask about the blade before you '
                'book, not on the day.'),
            PpStep('The child is fed and rested first',
                'A hungry or tired toddler and a razor near his scalp is the '
                'worst possible combination. Go after a nap.'),
            PpStep('He sits on a lap, usually facing the parent',
                'Held firmly and calmly, chest to chest, so his head is still '
                'and he can hide his face.'),
            PpStep('A short blessing is said, and a first symbolic snip is '
                'taken',
                'Often by a grandfather or the maternal uncle.'),
            PpStep('The barber shaves the head',
                'A fresh blade, opened in front of you. Five to ten minutes.'),
            PpStep('The head is washed and the hair collected',
                'Lukewarm water. Check for nicks while you dry him.'),
            PpStep('The hair is offered or buried, and sweets are shared',
                'Then get him out of the crowd and let him recover.'),
          ],
        ),
        PpCards(
          heading: 'What you need',
          hue: 268,
          [
            PpCard('A barber who works with small children',
                'Ask. The difference between one who does and one who does not '
                'is the difference between five minutes and forty.'),
            PpCard('A fresh, sealed blade',
                'Opened in front of you. This is not a preference, it is the '
                'one non negotiable of the day.'),
            PpCard('Lukewarm water and a soft towel',
                'For washing the head afterwards and checking it as you dry '
                'him.'),
            PpCard('A cap or a soft cotton scarf for afterwards',
                'A bare scalp burns fast in Indian sun.'),
            PpCard('Something distracting',
                'A favourite snack, a song he likes, a phone if that is what '
                'works. Nobody is judging on mundan day.'),
            PpCard('A small pouch for the hair, if you are keeping it',
                'Many families offer it, bury it, or keep a lock of it. All '
                'three are done.'),
          ],
        ),
        PpCallout('What actually matters is a clean blade, a still head and a '
            'child who is fed and rested. The temple, the outfit and the '
            'photographs are all optional, and a mundan done by a local barber '
            'at home is exactly as complete as one at a famous temple.'),
        // REQUIRED_REVIEW: shaving hygiene. Claims to confirm: a reused or
        // unsterilised blade carries a risk of bloodborne infection including
        // hepatitis B, hepatitis C and HIV, and of tetanus through a scalp
        // nick; a new single use blade per person is the standard precaution;
        // tetanus is covered by routine childhood immunisation.
        PpCallout(
          'One blade, one child, opened in front of you. A reused or wiped '
          'down blade can pass on infections through a small scalp nick, and '
          'scalp nicks are common. If a barber is reluctant to open a new '
          'blade in front of you, do not use him. Check that his routine '
          'tetanus shots are up to date before the day.',
          kind: PpCalloutKind.safety,
          title: 'The blade is the whole safety question',
        ),
        PpCallout(
          'After a mundan, keep the scalp out of direct sun and leave any '
          'small nicks alone, clean and dry. See a doctor if a cut becomes '
          'red, swollen, warm or starts to ooze, if he develops a fever in the '
          'following days, or if a cut is deep or will not stop bleeding. Do '
          'not put ash, turmeric, oil or any paste on a fresh cut.',
          kind: PpCalloutKind.doctor,
          title: 'If a nick does not settle',
        ),
        PpCallout(
          'Shaving a baby\'s head does not make the hair grow back thicker, '
          'darker or faster. Hair thickness is set by the follicle, and the '
          'new hair only looks coarser because it comes back with a blunt cut '
          'end. Do the mundan for the meaning if you want to, and do not do it '
          'for the hair.',
          kind: PpCalloutKind.myth,
          title: '"It will grow back thicker"',
        ),
        PpIndiaNote('If your family is set on a particular temple and the '
            'queue is four hours in May heat, the usual compromise is a first '
            'symbolic snip at the temple and the actual shave at home in the '
            'evening. Nobody has ever objected to that once it is done.'),
        PpVideoSlot(
          title: 'A mundan, and how to hold him through it',
          subtitle: 'The hold that keeps his head still, and the blade check.',
          minutes: '6 MIN',
          slotId: 'traditions/mundan',
        ),
        PpLink('At the ceremony itself: blades, piercing and heat',
            pageId: 'ceremony_day_safety'),
        PpLink('If your family keeps kesh instead', pageId: 'sikh_naming'),
      ],
    ),

    // -------------------------------------------------------------------------
    //  Karnavedha
    // -------------------------------------------------------------------------
    PpPage(
      id: 'karnavedha',
      title: 'Karnavedha, ear piercing',
      subtitle: 'For girls and, in many families, for boys',
      format: 'CEREMONY',
      blocks: [
        PpIntro('Karnavedha is the ear piercing ceremony. Families differ '
            'enormously on when to do it, from a few weeks old to five years, '
            'and there is no single right answer. What does matter is how it '
            'is done.'),
        PpArticle(
          heading: 'What it is',
          [
            'Ear piercing is done in most Indian communities for girls and in '
            'many for boys as well, often on the same day as another ceremony '
            'to save a second gathering. In the south it is frequently done '
            'with the mundan or the naming.',
            'It is a small procedure, not a medical event, but it is a wound. '
            'The whole difference between an easy piercing and a bad month is '
            'hygiene and aftercare, so this page spends most of its length '
            'there.',
          ],
        ),
        PpWhenLine('Anywhere from a few weeks to five years, depending on the '
            'family. Waiting until a child is old enough to keep her hands '
            'away and tell you if it hurts makes aftercare much easier.'),
        PpTable(
          heading: 'What it is called where',
          columns: ['Where', 'What it is called'],
          rows: [
            ['Sanskrit and north India', 'Karnavedha or kaan chedan'],
            ['Tamil Nadu', 'Kadhu kuthal'],
            ['Kerala', 'Kadhu kuthu'],
            ['Telugu states', 'Chevulu kuttinchadam'],
            ['Maharashtra', 'Kan topane'],
          ],
        ),
        PpSteps(
          heading: 'How it is done, safely',
          [
            PpStep('Choose who does it before you choose the date',
                'A paediatrician, a clinic, or a jeweller or piercer known for '
                'sterile technique. Many paediatricians will do it, and that '
                'is the easiest way to be sure.'),
            PpStep('Check what is being used',
                'A sterile single use needle, or a sealed sterile cartridge. '
                'Gloves. Skin cleaned first. A reusable gun barrel that is '
                'only wiped between customers is the version to avoid.'),
            PpStep('Feed her first and go after a nap',
                'A calm child is a still child, and stillness is what keeps '
                'the holes even.'),
            PpStep('Hold her firmly and hand her straight to you afterwards',
                'Chest to chest. It is over in seconds and the crying stops '
                'faster than you expect.'),
            PpStep('Plain gold or medical grade studs go in',
                'Small, light, flat backed. Not heavy jhumkas and not a wire '
                'thread that can catch.'),
            PpStep('Clean twice a day and do not remove the studs early',
                'Follow whatever the piercer or doctor tells you. Usually '
                'saline or the solution they give you, for four to six weeks.'),
          ],
        ),
        PpCards(
          heading: 'What you need',
          hue: 340,
          [
            PpCard('Someone with sterile technique',
                'A clinic, a paediatrician, or a piercer who opens sealed '
                'sterile equipment in front of you.'),
            PpCard('Small plain gold or medical grade studs',
                'Light and flat backed. Heavy earrings on a baby pull and '
                'tear.'),
            PpCard('Saline or the cleaning solution you are given',
                'Twice a day for four to six weeks, or whatever the piercer '
                'or doctor tells you.'),
            PpCard('Clean hands, every single time you touch her ears',
                'This is the whole of aftercare. Nothing else matters as '
                'much.'),
            PpCard('Two calm adults',
                'One to hold, one to comfort. It is a two person job.'),
          ],
        ),
        PpCallout('What actually matters is sterile equipment, light plain '
            'studs and clean hands for six weeks. The auspicious date, the '
            'gold weight and the ceremony around it are all optional.'),
        // REQUIRED_REVIEW: piercing hygiene and aftercare. Claims to confirm:
        // sterile single use needle or sealed cartridge, cleaning with saline,
        // keeping studs in for the healing period, avoiding heavy earrings on
        // an infant, and that piercing on infected or broken skin should wait.
        // Also confirm the tetanus immunisation point.
        PpCallout(
          'Delay the piercing if she is unwell, if the ear skin is broken or '
          'infected, or if her routine immunisations are behind. Do not let '
          'anyone pierce with a sewing needle, a thorn, a reused stud, or a '
          'gun barrel that has only been wiped. Keep her hair, dupattas and '
          'her own fingers away from the studs while they heal.',
          kind: PpCalloutKind.safety,
          title: 'When to wait, and what to refuse',
        ),
        PpCallout(
          'See a doctor if an ear becomes red and swollen, feels hot, oozes '
          'yellow or green, if she develops a fever, or if a stud sinks into '
          'the earlobe. A stud that has embedded needs a doctor to remove it, '
          'not a family member with tweezers. Raised lumpy scarring, called a '
          'keloid, also needs a doctor to look at it early.',
          kind: PpCalloutKind.doctor,
          title: 'If an ear does not settle',
        ),
        PpCallout(
          'Ear piercing does not improve eyesight, hearing, brain development '
          'or behaviour. It is a cultural and aesthetic choice, made with love, '
          'and there is no medical reason either to do it or to avoid it when '
          'it is done cleanly.',
          kind: PpCalloutKind.myth,
          title: '"Piercing is good for her eyes"',
        ),
        PpIndiaNote('If an elder offers to do it at home with a gold wire, it '
            'is worth saying yes to the ceremony and no to the method. The '
            'usual sentence that works: "Let us do the puja at home, and the '
            'piercing itself at the clinic, and then we do not risk an '
            'infection during the festival."'),
        PpVideoSlot(
          title: 'Ear piercing, and the six weeks after',
          subtitle: 'What sterile actually looks like, and how to clean the '
              'ears at home.',
          minutes: '5 MIN',
          slotId: 'traditions/karnavedha',
        ),
        PpLink('At the ceremony itself: blades, piercing and heat',
            pageId: 'ceremony_day_safety'),
      ],
    ),

    // -------------------------------------------------------------------------
    //  First birthday
    // -------------------------------------------------------------------------
    PpPage(
      id: 'first_birthday',
      title: 'The first birthday',
      subtitle: 'The modern milestone, and how to keep it hers',
      format: 'CEREMONY',
      blocks: [
        PpIntro('The first birthday is the newest ceremony in this section and '
            'often the most expensive. It is also the one where the gap '
            'between what the child enjoys and what the party costs is widest.'),
        PpArticle(
          heading: 'What it is now',
          [
            'Traditionally the first year was marked quietly, sometimes with '
            'the mundan, sometimes with a temple visit and food given away. '
            'The themed party with a cake and a photographer arrived in the '
            'last twenty years and is now the default in cities.',
            'A one year old does not know it is her birthday. She knows there '
            'are lights, loud music, forty faces and no nap. That is worth '
            'holding in mind when you plan, because it decides whether the '
            'photographs show a happy child or a distressed one.',
          ],
        ),
        PpWhenLine('At twelve months, or on the nearest weekend, or on the '
            'tithi rather than the date if your family counts it that way. '
            'Any of those is correct.'),
        PpCards(
          heading: 'Simple traditions families still keep',
          hue: 44,
          [
            PpCard('Tulabharam or weighing',
                'The child is weighed against grain, fruit or sugar and that '
                'weight is given away. Meaningful, inexpensive, and popular '
                'again.'),
            PpCard('Giving food away',
                'A meal cooked for a school, a shelter or the family who works '
                'in your building. Many families now do this instead of return '
                'gifts.'),
            PpCard('Planting a tree',
                'One tree per birthday. Children love visiting theirs.'),
            PpCard('A handprint or footprint',
                'Taken every year on the same date. Costs nothing and becomes '
                'the thing you keep.'),
            PpCard('Mundan on the same day',
                'Common, and it saves a second gathering.'),
            PpCard('New clothes and a temple, church or gurdwara visit',
                'Quiet, short, and easier on a one year old than a hall.'),
          ],
        ),
        PpSteps(
          heading: 'How to plan it around her, not around the guests',
          [
            PpStep('Pick the time from her nap, then tell people',
                'Late morning or late afternoon. Never the slot that eats her '
                'nap.'),
            PpStep('Keep it to about ninety minutes',
                'Her tolerance for noise and strangers runs out long before '
                'the buffet does.'),
            PpStep('Have one quiet room she can be taken to',
                'A bedroom with the lights low. You will use it.'),
            PpStep('Feed her before the party, properly',
                'Party food at one year old is mostly sugar and mostly not for '
                'her.'),
            PpStep('Do the cake early, not at the end',
                'Get the moment done while she is still fresh.'),
            PpStep('Let her be held by people she knows',
                'A passed around baby at the two hour mark is a crying baby.'),
          ],
        ),
        PpCallout('What actually matters is that she is fed, rested and near '
            'someone familiar. The theme, the balloon arch, the return gifts '
            'and the photographer are for the adults, which is allowed, as '
            'long as you know that is what they are.'),
        // REQUIRED_REVIEW: first birthday food and party safety. Claims to
        // confirm: no added sugar in the first year and cake in a tiny taste
        // at most, choking hazards from grapes, nuts, hard sweets and small
        // toy parts, candle and open flame safety, and hearing protection from
        // sustained loud music for infants.
        PpCallout(
          'Cake is a taste, not a meal, and added sugar is still not '
          'recommended in the first year. Keep grapes, nuts, hard sweets and '
          'small toy parts away from the floor she crawls on. Keep candles, '
          'sparklers and hot food out of her reach. And keep her away from the '
          'speakers, because sustained loud music is genuinely too much for a '
          'baby\'s ears.',
          kind: PpCalloutKind.safety,
          title: 'Cake, choking and the speakers',
        ),
        PpIndiaNote('If the family expectation is two hundred guests and your '
            'budget is not, the version that works in most families is a small '
            'ceremony at home in the morning and an open house in the evening '
            'with tea and mithai. It reads as generous and it costs a '
            'fraction.'),
        PpVideoSlot(
          title: 'A first birthday that suits a one year old',
          subtitle: 'Timing, the cake moment, and the quiet room.',
          minutes: '5 MIN',
          slotId: 'traditions/first_birthday',
        ),
        PpLink('Make an invite or a birthday card',
            surfaceId: 'pp_memories',
            blurb: 'Pick a template, add a photo, share it on WhatsApp.'),
        PpLink('What a ceremony actually costs', pageId: 'what_it_costs'),
        PpLink('Mundan, if you are doing both on the day', pageId: 'mundan'),
      ],
    ),

    // -------------------------------------------------------------------------
    //  Aksharabhyasam
    // -------------------------------------------------------------------------
    PpPage(
      id: 'aksharabhyasam',
      title: 'Aksharabhyasam, the first letters',
      subtitle: 'The start of learning, usually between two and five',
      format: 'CEREMONY',
      blocks: [
        PpIntro('Aksharabhyasam is the day a child writes a first letter, '
            'usually guided hand over hand by a parent or grandparent, in a '
            'tray of rice. It is short, it is sweet, and it costs almost '
            'nothing.'),
        PpArticle(
          heading: 'What it is',
          [
            'The ceremony marks the beginning of formal learning. An adult '
            'holds the child\'s finger and traces a letter or a syllable in '
            'rice, sand or on a slate, and the child repeats it. In many '
            'families it is done at a temple; in many others it is done at the '
            'kitchen table.',
            'It is a beginning, and beginnings do not have standards. A child '
            'who scribbles, refuses, or wanders off has still had his '
            'aksharabhyasam.',
          ],
        ),
        PpWhenLine('Usually between two and five years old. Very commonly on '
            'Vijayadashami, the last day of Navratri, which is why families '
            'often wait for that date rather than a birthday.'),
        PpTable(
          heading: 'What it is called where',
          columns: ['Where', 'What it is called'],
          rows: [
            ['Telugu states', 'Aksharabhyasam'],
            ['Kerala', 'Vidyarambham, usually at Vijayadashami'],
            ['Tamil Nadu', 'Vidyarambham or ezhuthaniyippu'],
            ['Bengal', 'Hate khori, the chalk in the hand'],
            ['Karnataka and Maharashtra', 'Vidyarambha'],
            ['North India', 'Vidyarambh, often at home'],
          ],
        ),
        PpSteps(
          heading: 'How it usually goes',
          [
            PpStep('A tray of raw rice, or sand, or a slate is set out'),
            PpStep('The child sits on a lap, usually a grandparent\'s'),
            PpStep('An adult holds his finger and traces a letter',
                'Often the first letter of the alphabet, or a short syllable, '
                'traced two or three times.'),
            PpStep('He is asked to say it aloud',
                'He may or may not. Either is fine.'),
            PpStep('A book, a pencil and sometimes a small sweet are given',
                'The gift of the first pencil is the part children remember.'),
            PpStep('Blessings, and that is it',
                'The whole thing takes ten minutes.'),
          ],
        ),
        PpCards(
          heading: 'What you need',
          hue: 200,
          [
            PpCard('A tray and raw rice',
                'Or clean sand, or a slate and chalk. Any of the three.'),
            PpCard('A pencil and a blank notebook',
                'His own, kept afterwards. This is the keepsake.'),
            PpCard('A lap and ten quiet minutes',
                'Ideally a grandparent\'s lap. That is the part he will '
                'remember.'),
            PpCard('Sweets, if the family shares them',
                'Anything the house makes. This ceremony has never needed a '
                'caterer.'),
          ],
        ),
        PpCallout('What actually matters is that an adult he loves sits with '
            'him and shows him a letter, and that it feels good. Do not turn '
            'it into a test, do not correct him, and do not let anyone ask him '
            'to perform for the room.'),
        PpCallout(
          'This ceremony is not a signal to start formal reading drills. '
          'Children learn letters at very different ages, and pushing a three '
          'year old into worksheets after aksharabhyasam is the fastest way to '
          'make him dislike them. Play, talk and being read to build reading '
          'far more than tracing does.',
          kind: PpCalloutKind.myth,
          title: '"Now he should start learning properly"',
        ),
        PpIndiaNote('If your family is spread out, doing this over a video '
            'call with a grandparent guiding from the screen while you hold '
            'his hand works beautifully, and it is what a lot of families '
            'already do.'),
        PpVideoSlot(
          title: 'Aksharabhyasam at home',
          subtitle: 'The rice tray version, in ten minutes.',
          minutes: '4 MIN',
          slotId: 'traditions/aksharabhyasam',
        ),
        PpLink('Play that builds early learning',
            surfaceId: 'pp_activities',
            blurb: 'Age matched play, and what each one is actually building.'),
        PpLink('Reading with your child', surfaceId: 'pp_read'),
      ],
    ),
  ],
);

// =============================================================================
//  AREA 5 — Ceremonies in other faiths
// -----------------------------------------------------------------------------
//  ⚠️ THIS AREA IS NOT A SUPPLEMENT. Every page here is built to the same
//  skeleton, at the same depth, in the same voice as the Hindu pages. The Hindu
//  pages lead the section because that is where the demand is, and that is a
//  ranking decision, not a statement about whose ceremony is the real one.
//
//  ⚠️ AND THE VOICE STAYS DESCRIPTIVE. Practice inside every one of these
//  traditions varies by school, by region and by family, and it is not the
//  app's place to say which version is correct. So the copy says "many families
//  do", never "you must", and points at the family's own religious guide where
//  a religious question is genuinely being asked.
// =============================================================================

final PpArea _otherFaiths = PpArea(
  id: 'other_faiths',
  mark: IntentMark.cuppedHands,
  title: 'Ceremonies in Muslim, Christian, Sikh, Jain and Parsi families',
  blurb: 'The same how-to, for the welcome your own family performs.',
  hue: 200,
  pages: [
    PpPage(
      id: 'aqiqah',
      title: 'Aqiqah, and naming in a Muslim family',
      subtitle: 'Usually around the seventh day',
      format: 'CEREMONY',
      blocks: [
        PpIntro('Aqiqah is the welcome ceremony many Muslim families perform '
            'for a new baby. It usually brings together three things: the '
            'name being given, the baby\'s head being shaved, and food or '
            'charity being shared with others.'),
        PpArticle(
          heading: 'What it is',
          [
            'The most common practice is that on the seventh day the child is '
            'named, the head is shaved, and an animal is sacrificed with the '
            'meat divided between the family, relatives and those in need. '
            'Some families also give the weight of the shaved hair in silver '
            'to charity.',
            'Practice varies between schools and between families, and this '
            'page describes what is commonly done rather than what is '
            'required. Your family\'s imam or religious guide is the right '
            'person for the religious questions; this page is the practical '
            'side.',
          ],
        ),
        PpWhenLine('Most commonly the seventh day after birth. Many families '
            'do it on the fourteenth or twenty first day, and many delay it '
            'until they can afford it. Delaying is widely accepted.'),
        PpSteps(
          heading: 'How it usually goes',
          [
            PpStep('The name is chosen and given',
                'Often announced to family on the day, sometimes with a short '
                'gathering.'),
            PpStep('The baby\'s head is shaved',
                'A fresh sealed blade, and the same care as any newborn '
                'shaving. See the note below.'),
            PpStep('The hair may be weighed and its value given in silver',
                'A small amount, given as charity.'),
            PpStep('An animal is sacrificed, where the family does this',
                'Traditionally two for a boy and one for a girl, though many '
                'families do one either way.'),
            PpStep('The meat is divided in three',
                'The family, relatives and neighbours, and those in need. The '
                'third share is the part most families treat as the heart of '
                'it.'),
            PpStep('Family and neighbours eat together'),
          ],
        ),
        PpCards(
          heading: 'What you need',
          hue: 200,
          [
            PpCard('The name, agreed',
                'Meaning matters a great deal in Muslim naming, so it is worth '
                'looking up before the day.'),
            PpCard('A barber with a fresh sealed blade',
                'Non negotiable, exactly as for any head shaving.'),
            PpCard('Arrangements for the sacrifice, if you are doing it',
                'Many families now arrange this through a butcher or a '
                'charity, which is entirely accepted.'),
            PpCard('Food for the shared meal',
                'Cooked at home or catered. Neither is more correct.'),
            PpCard('A soft cap for afterwards',
                'A newly shaved scalp needs shade.'),
          ],
        ),
        PpCallout('What actually matters is the name, the child being welcomed, '
            'and something being given to people who need it. If money is '
            'tight, the giving can be small and the meal can be at home. No '
            'family is failing a child by keeping it modest or by waiting.'),
        // REQUIRED_REVIEW: newborn head shaving hygiene, same claim as the
        // mundan page: single use sealed blade, risk of bloodborne infection
        // and tetanus through a nick, and shade for a newly shaved scalp.
        PpCallout(
          'A newborn scalp is thin and nicks easily. One fresh sealed blade, '
          'opened in front of you, and nothing else. Do not let ash, oil, '
          'turmeric or any paste be put on the shaved head or on a nick, and '
          'keep the scalp out of direct sun afterwards. If a nick becomes red '
          'or the baby develops a fever, see a doctor.',
          kind: PpCalloutKind.safety,
          title: 'Shaving a seven day old head',
        ),
        PpIndiaNote('If the family is spread across cities, many now do the '
            'naming and shaving at home on the seventh day and the shared meal '
            'weeks later when everyone can travel. That is a common and '
            'accepted split.'),
        PpVideoSlot(
          title: 'Aqiqah, explained simply',
          subtitle: 'What the day involves, and the practical arrangements.',
          minutes: '6 MIN',
          slotId: 'traditions/aqiqah',
        ),
        PpLink('Find a name, with meanings and origins',
            surfaceId: 'pp_names',
            blurb: 'Search by meaning, origin and sound.'),
        PpLink('Tahneek, the first sweet taste', pageId: 'tahneek'),
        PpLink('Make an announcement card', surfaceId: 'pp_memories'),
      ],
    ),
    PpPage(
      id: 'tahneek',
      title: 'Tahneek, the first sweet taste',
      subtitle: 'In the first days after birth',
      format: 'CEREMONY',
      blocks: [
        PpIntro('Tahneek is the custom of an elder placing a tiny softened '
            'piece of date on a newborn\'s gums and saying a blessing. It '
            'takes a moment and is done in the first days.'),
        PpArticle(
          heading: 'What it is',
          [
            'A date is softened, usually chewed or mashed, and a very small '
            'amount is rubbed gently on the roof of the baby\'s mouth or the '
            'gums by a respected elder, who then makes a prayer for the child. '
            'It is a blessing, not a feed.',
            'Practice differs on who does it and how, and families follow '
            'their own guidance. What follows is the safety side, which is the '
            'part an app can usefully add.',
          ],
        ),
        PpWhenLine('Usually within the first day or two of birth, and often '
            'straight after the baby has fed.'),
        PpSteps(
          heading: 'How it is done',
          [
            PpStep('Let the first breastfeed happen first',
                'Nothing should delay or replace the first feeds. The colostrum '
                'in those first hours matters more than any custom.'),
            PpStep('The date is softened until it is completely smooth',
                'No lumps, no skin, no piece that could be swallowed whole.'),
            PpStep('Hands are washed thoroughly',
                'This is the single most important step on this page.'),
            PpStep('A trace is rubbed on the gums',
                'A trace, not a spoonful. The baby is held upright and awake.'),
            PpStep('The blessing is said, and it is done'),
          ],
        ),
        PpCallout('What actually matters is that it is a trace, that hands are '
            'clean, and that it does not replace a feed. Everything else is '
            'family practice.'),
        // REQUIRED_REVIEW: this is the highest priority medical review on the
        // page. Claims to confirm: honey must not be substituted for the date
        // before 12 months because of infant botulism risk; anything placed in
        // a newborn's mouth is an infection route, so handwashing matters and
        // an unwell adult should not do it; nothing should be given that could
        // choke; and nothing should delay or replace early breastfeeding.
        PpCallout(
          'Never substitute honey for the date. Honey must not be given to a '
          'baby under one year at all, because it can carry spores that a '
          'newborn gut cannot handle, and infant botulism is serious. Anyone '
          'with a cough, cold, mouth ulcer or fever should not do the tahneek. '
          'Wash hands first, use a trace with no lump in it, and never let it '
          'delay a feed.',
          kind: PpCalloutKind.safety,
          title: 'Honey is the one real danger here',
        ),
        PpCallout(
          'Call a doctor straight away if a newborn becomes floppy or unusually '
          'weak, has a weak cry, feeds poorly, or is constipated along with any '
          'of these. Those are the signs that need seeing urgently in a young '
          'baby, whatever the cause.',
          kind: PpCalloutKind.doctor,
          title: 'When a newborn needs seeing urgently',
        ),
        PpIndiaNote('Some families use a little jaggery, sugar water or ghutti '
            'instead of a date. Those carry their own problems and the safety '
            'page covers them, so it is worth reading before the day rather '
            'than arguing about it in the room.'),
        PpVideoSlot(
          title: 'Tahneek, done safely',
          subtitle: 'The custom, and the three things to check first.',
          minutes: '3 MIN',
          slotId: 'traditions/tahneek',
        ),
        PpLink('Aqiqah, and naming', pageId: 'aqiqah'),
        PpLink('Customs done with love that are not safe',
            pageId: 'newborn_customs'),
      ],
    ),
    PpPage(
      id: 'christening',
      title: 'Baptism, christening and dedication',
      subtitle: 'In Christian families',
      format: 'CEREMONY',
      blocks: [
        PpIntro('Baptism, often called a christening, is the ceremony in which '
            'a baby is welcomed into the church and formally named. Some '
            'churches instead hold a dedication or thanksgiving service, which '
            'plays the same family role.'),
        PpArticle(
          heading: 'What it is',
          [
            'In Catholic, Orthodox and many Protestant churches an infant is '
            'baptised with water, given a Christian name, and godparents take '
            'on a role in the child\'s life. In Baptist and several other '
            'churches, baptism happens later by choice and a dedication '
            'service is held for a baby instead.',
            'Either way it is a short service, usually inside a normal Sunday '
            'service or just after it, followed by lunch at home. Your parish '
            'priest or pastor sets the details, so the first practical step is '
            'always a conversation with them.',
          ],
        ),
        PpWhenLine('Commonly in the first few weeks or months. Many families '
            'wait for relatives to travel, and churches are generally relaxed '
            'about the timing.'),
        PpSteps(
          heading: 'How it usually goes',
          [
            PpStep('Speak to the parish and pick a date',
                'Most parishes ask for a short meeting or a preparation class '
                'first.'),
            PpStep('Choose godparents and confirm the name',
                'Some churches have requirements about godparents. Ask early '
                'rather than the week before.'),
            PpStep('The family gathers at the church'),
            PpStep('The priest or pastor blesses the water and says the '
                'prayers'),
            PpStep('Water is poured over the baby\'s head three times',
                'A small amount, usually lukewarm. Most babies startle and '
                'settle within seconds.'),
            PpStep('A candle is lit and the child is welcomed by name',
                'Photographs are usually allowed, but ask beforehand.'),
            PpStep('Lunch or tea afterwards, at home or at a hall'),
          ],
        ),
        PpCards(
          heading: 'What you need',
          hue: 200,
          [
            PpCard('A date agreed with the parish',
                'The first practical step, before anything else is planned.'),
            PpCard('Godparents, where your church has them',
                'Some churches have requirements about who can stand. Ask '
                'early.'),
            PpCard('A christening outfit',
                'Traditionally white. A soft white cotton set is completely '
                'acceptable and far more comfortable than a stiff gown.'),
            PpCard('A shawl or a change of clothes',
                'She will get wet. A dry layer and a towel in the bag makes '
                'the difference.'),
            PpCard('A candle, if the church asks you to bring one',
                'Many parishes provide it. Check when you fix the date.'),
            PpCard('Lunch, of whatever size you want',
                'At home or at a hall. Neither is more correct, and the '
                'service is the ceremony.'),
          ],
        ),
        PpCallout('What actually matters is the church, the water, the name '
            'and the people who promise to look after her. The gown, the hall '
            'and the cake are family choices with no religious weight at all.'),
        PpCallout(
          'Churches can be cold and stone floors colder. Bring a warm layer '
          'and a towel, ask for lukewarm rather than cold water if your baby '
          'is very young, and dry her head straight away afterwards. Feed her '
          'before the service, not during the drive.',
          kind: PpCalloutKind.safety,
          title: 'Keeping her comfortable during the service',
        ),
        PpIndiaNote('In much of Kerala, Goa and the north east the christening '
            'lunch is the larger event and the service is short. If you want a '
            'smaller day, the service is not the part to shorten, the lunch '
            'is, and most families understand that immediately.'),
        PpVideoSlot(
          title: 'A christening, start to finish',
          subtitle: 'What happens in the service, and what to bring.',
          minutes: '5 MIN',
          slotId: 'traditions/christening',
        ),
        PpLink('Find a name, with meanings and origins',
            surfaceId: 'pp_names'),
        PpLink('Make a christening invite', surfaceId: 'pp_memories'),
        PpLink('How to keep it small', pageId: 'keeping_it_small'),
      ],
    ),
    PpPage(
      id: 'sikh_naming',
      title: 'Naam Karan at the Gurdwara, and kesh',
      subtitle: 'In Sikh families',
      format: 'CEREMONY',
      blocks: [
        PpIntro('In a Sikh family the naming happens at the Gurdwara. The Guru '
            'Granth Sahib is opened at random, and the first letter of the '
            'first word on that page gives the letter the child\'s name will '
            'begin with.'),
        PpArticle(
          heading: 'What it is',
          [
            'The family attends the Gurdwara when they are ready, usually in '
            'the first few weeks. Ardas is said, a hukamnama is read, and the '
            'family chooses a name starting with that letter. Kaur is added '
            'for a girl and Singh for a boy, and the name is announced to the '
            'sangat, who respond with the jaikara.',
            'It is a warm, short, inexpensive ceremony. Karah prasad is shared '
            'and often langar follows, which is served to everyone present '
            'regardless of who they are.',
          ],
        ),
        PpWhenLine('When the mother and baby are well enough to attend, '
            'commonly in the first few weeks. There is no fixed day.'),
        PpSteps(
          heading: 'How it usually goes',
          [
            PpStep('The family goes to the Gurdwara with the baby',
                'Heads covered, shoes left outside, as always.'),
            PpStep('Ardas is said for the child'),
            PpStep('The Guru Granth Sahib is opened at random and a hukamnama '
                'is read',
                'The first letter of the first word is the letter for the '
                'name.'),
            PpStep('The family chooses a name beginning with that letter',
                'Some families come with a shortlist for several letters so '
                'they can decide on the spot.'),
            PpStep('Kaur or Singh is added, and the name is announced'),
            PpStep('Karah prasad is shared, and often langar follows'),
          ],
        ),
        PpCards(
          heading: 'What you need',
          hue: 200,
          [
            PpCard('Head coverings for everyone',
                'Including the baby if you wish, though it is not required for '
                'an infant.'),
            PpCard('A shortlist of names for several letters',
                'The most practical preparation there is. You will not know '
                'the letter until the day.'),
            PpCard('Ingredients or an offering for karah prasad',
                'Many families give this. The Gurdwara will tell you what is '
                'usual there.'),
            PpCard('Nothing else',
                'This ceremony genuinely requires no purchases.'),
          ],
        ),
        PpCallout('What actually matters is that the family attends, the '
            'hukamnama is taken, and the child is named. There is no cost '
            'attached to any of it, and no version of this ceremony is more '
            'correct for being larger.'),
        PpArticle(
          heading: 'Kesh, and why there is no mundan',
          [
            'In Sikh practice kesh, uncut hair, is one of the articles of '
            'faith. So there is no head shaving ceremony for a child raised in '
            'that practice, and a mundan is simply not part of the tradition.',
            'Practically that means the hair is cared for rather than cut. It '
            'is combed gently with a kangha, often oiled, and tied in a joora '
            'on top of the head, covered with a patka once a child is old '
            'enough. Later, usually around eleven, a Dastar Bandi marks the '
            'first turban and is a real celebration in its own right.',
            'If your family is Sikh and relatives from another tradition ask '
            'about a mundan, the answer is simply that this family keeps kesh. '
            'It is not a gap in the ceremonies; it is one of them.',
          ],
        ),
        PpCallout(
          'A child\'s joora should be tied loosely. Hair pulled tight day '
          'after day at the same spot can cause soreness and thinning at the '
          'hairline. Comb gently from the ends upward, oil if it helps, and '
          'change where the parting sits from time to time.',
          kind: PpCalloutKind.safety,
          title: 'Caring for a small child\'s kesh',
        ),
        PpIndiaNote('Gurdwaras will normally do the naming without an '
            'appointment and without a fee. If someone quotes you a price for '
            'a Naam Karan, that is not how it works.'),
        PpVideoSlot(
          title: 'Naam Karan at the Gurdwara',
          subtitle: 'The hukamnama, the naming, and what to prepare.',
          minutes: '5 MIN',
          slotId: 'traditions/sikh_naming',
        ),
        PpLink('Find a name, by first letter',
            surfaceId: 'pp_names',
            blurb: 'Filter by starting letter, which is exactly what this '
                'ceremony needs.'),
        PpLink('Mundan, for families who do it', pageId: 'mundan'),
      ],
    ),
    PpPage(
      id: 'jain_parsi',
      title: 'Welcomes in Jain and Parsi families',
      subtitle: 'Naming, and the ceremonies that come later',
      format: 'CEREMONY',
      blocks: [
        PpIntro('Jain and Parsi families each have their own welcome for a new '
            'baby, and both are quieter than the ceremonies around them. Here '
            'is what each usually involves.'),
        PpArticle(
          heading: 'In a Jain family',
          [
            'The naming, namkaran, is usually done between the tenth and '
            'twelfth day, at home or at the derasar. The family gathers, a '
            'blessing is said, the name is announced, and sweets are shared. '
            'Many families visit the temple with the baby for the first time '
            'on the same day or soon after.',
            'Jain practice puts weight on restraint and on giving, so the '
            'ceremonies tend to be deliberately modest and the money often '
            'goes to daan instead of to the gathering. That is a choice worth '
            'knowing about if relatives from other traditions expect '
            'something larger.',
          ],
        ),
        PpArticle(
          heading: 'In a Parsi family',
          [
            'The early ceremonies are small: the baby is welcomed at home, '
            'often with a sixth day observance, and the naming is done within '
            'the family. Some families mark it with a jashan, a thanksgiving '
            'ceremony performed by priests at home.',
            'The large ceremony in a Parsi childhood comes later. Navjote, the '
            'initiation, is usually held between seven and eleven years old, '
            'when the child receives the sudreh and kusti. It is worth knowing '
            'that this is the milestone the family is saving and planning for, '
            'rather than the first birthday.',
          ],
        ),
        PpWhenLine('Jain naming: usually day ten to twelve. Parsi naming: in '
            'the early weeks, with Navjote much later, between seven and '
            'eleven years.'),
        PpCards(
          heading: 'What you need, for either',
          hue: 200,
          [
            PpCard('A date agreed with the family',
                'Usually day ten to twelve in a Jain home, and the early '
                'weeks in a Parsi one.'),
            PpCard('A clean space at home, or the temple or agiary',
                'Both traditions are comfortable with a home ceremony.'),
            PpCard('The name, agreed in advance',
                'Deciding on the morning is the single biggest source of '
                'ceremony day stress.'),
            PpCard('Sweets, and something given away',
                'Giving is central to both, and it is the part nobody regrets '
                'spending on.'),
          ],
        ),
        PpCallout('What actually matters in both traditions is the name being '
            'given and something being shared with others. Both are unusually '
            'relaxed about scale, which is worth remembering if anyone tells '
            'you otherwise.'),
        // REQUIRED_REVIEW: same newborn gathering precautions as the chatti and
        // namkaran pages.
        PpCallout(
          'These are still newborn gatherings. Keep the group small, keep '
          'anyone unwell away, wash hands before holding her, and no kissing '
          'her face. If incense or smoke fills the room, open a window and '
          'take her out of it, because young lungs do not cope with smoke well.',
          kind: PpCalloutKind.safety,
          title: 'For any newborn ceremony at home',
        ),
        PpIndiaNote('If your community is small in your city, ask the local '
            'derasar or agiary rather than searching online. Practice varies a '
            'lot between communities, and the people there will tell you '
            'exactly what is done locally.'),
        PpVideoSlot(
          title: 'Jain and Parsi welcomes',
          subtitle: 'What each involves, and what is prepared beforehand.',
          minutes: '5 MIN',
          slotId: 'traditions/jain_parsi',
        ),
        PpLink('Find a name, with meanings and origins',
            surfaceId: 'pp_names'),
        PpLink('Customs done with love that are not safe',
            pageId: 'newborn_customs'),
      ],
    ),
  ],
);

// =============================================================================
//  AREA 6 — What it costs, and how to keep it small
// -----------------------------------------------------------------------------
//  ⚠️ THIS IS THE SECTION'S REASON TO EXIST, NOT ITS APPENDIX. Every other app
//  in this space describes ceremonies; none of them says out loud that a family
//  is allowed to do a small one. Cost and family expectation are the two things
//  that actually hurt here, and the script page is the one a mother will use.
// =============================================================================

final PpArea _keepItSmall = PpArea(
  id: 'keep_it_small',
  mark: IntentMark.compareMark,
  title: 'What it costs, and how to keep it small',
  blurb: 'Real numbers, the small version of each ceremony, and what to say.',
  hue: 44,
  pages: [
    PpPage(
      id: 'what_it_costs',
      title: 'What a ceremony actually costs',
      subtitle: 'Honest ranges, so you can decide before anyone books anything',
      format: 'CHART-CARD',
      blocks: [
        PpIntro('Nobody publishes this and everybody wants it. Here are the '
            'realistic ranges for the pieces of a baby ceremony in an Indian '
            'city, so you can see where the money actually goes before a '
            'decision gets made for you.'),
        // REQUIRED_REVIEW: cost figures. These are 2026 metro estimates and
        // need a sanity check before ship. They vary enormously by city, by
        // season and by community, and the copy says so, but a badly wrong
        // number would still read as authoritative.
        PpChartCard(
          title: 'What each piece tends to cost',
          subtitle: 'City ranges. Smaller towns run well below these.',
          rows: [
            ('Priest dakshina', 'Rs 500 to Rs 2,100'),
            ('Pooja samagri and flowers', 'Rs 300 to Rs 1,500'),
            ('Sweets for a home gathering', 'Rs 500 to Rs 3,000'),
            ('Catering, per plate', 'Rs 350 to Rs 1,200'),
            ('A hall for an afternoon', 'Rs 8,000 to Rs 60,000'),
            ('Decor and a backdrop', 'Rs 3,000 to Rs 40,000'),
            ('Photographer for a few hours', 'Rs 5,000 to Rs 30,000'),
            ('Ceremony outfit for the baby', 'Rs 500 to Rs 5,000'),
            ('Silver spoon and bowl set', 'Rs 1,500 to Rs 8,000'),
            ('Printed invites, per card', 'Rs 20 to Rs 150'),
            ('Return gifts, per guest', 'Rs 100 to Rs 500'),
          ],
          note: 'These are indicative and they move a lot by city and season. '
              'Get two quotes for anything above Rs 5,000.',
          hue: 44,
        ),
        PpTable(
          heading: 'Three honest versions of the same ceremony',
          columns: ['Version', 'Who comes', 'Rough total'],
          rows: [
            ['At home, family only', '8 to 15 people', 'Rs 2,000 to Rs 8,000'],
            ['At home, extended family', '30 to 50 people',
              'Rs 15,000 to Rs 60,000'],
            ['Hall, catered, decorated', '100 plus', 'Rs 1,00,000 and up'],
          ],
        ),
        PpCards(
          heading: 'Where the money goes without anyone noticing',
          hue: 44,
          [
            PpCard('The guest count',
                'Every single cost above except the priest scales with it. '
                'Cutting the list by twenty does more than negotiating '
                'everything else.'),
            PpCard('The hall',
                'Booking a hall usually forces catering, decor and a longer '
                'event. It is one decision that makes four.'),
            PpCard('Return gifts',
                'A hundred guests at Rs 300 is Rs 30,000 of things nobody '
                'remembers.'),
            PpCard('Two ceremonies instead of one',
                'Mundan with the first birthday, naming with the cradle. '
                'Combining is traditional, not a shortcut.'),
            PpCard('Same day decisions',
                'Everything bought on the morning costs more. Decide the list '
                'a week ahead.'),
          ],
        ),
        PpCallout('Please do not borrow money for a baby ceremony. There is no '
            'tradition in this country that asks a family to go into debt to '
            'welcome a child, and every one of these ceremonies has a version '
            'that costs almost nothing.'),
        PpIndiaNote('If relatives are contributing, agree who is paying for '
            'what before anything is booked. The most common ceremony fight in '
            'Indian families is not about the ritual, it is about an assumed '
            'contribution that never got said out loud.'),
        PpLink('How to keep it small', pageId: 'keeping_it_small'),
        PpLink('What to say when family wants it bigger',
            pageId: 'family_pressure'),
        PpLink('Ceremony essentials, compared',
            surfaceId: 'pp_products',
            blurb: 'Thali sets, spoons and outfits, side by side before you '
                'buy.'),
      ],
    ),
    PpPage(
      id: 'keeping_it_small',
      title: 'How to keep it small',
      subtitle: 'The one hour, at home, family only version',
      format: 'STEP-LIST',
      blocks: [
        PpIntro('Every ceremony in this section has a small version that is '
            'complete, traditional and takes about an hour. Here is how to '
            'build one, and what to cut first when something has to go.'),
        PpSteps(
          heading: 'The one hour version, for any ceremony',
          [
            PpStep('Fix the guest list first, before the date',
                'Grandparents, siblings, the two or three people who have '
                'actually helped you this month. That is the list.'),
            PpStep('Do it at home, in the morning',
                'Morning ceremonies end. Evening ones stretch, and stretching '
                'is what costs money.'),
            PpStep('Keep the ritual itself to fifteen minutes',
                'The naming, the first spoon, the cradle. That is the '
                'ceremony. The rest is a gathering.'),
            PpStep('Serve one thing well',
                'Chai and good mithai, or one hot dish. A buffet is a decision '
                'you can simply not make.'),
            PpStep('Skip printed invites',
                'A card made on your phone, sent on WhatsApp, is now normal '
                'even for large weddings.'),
            PpStep('Take photographs yourself, and ask one relative to shoot',
                'Give one person that job. You will get better candid pictures '
                'than a stranger takes.'),
            PpStep('Plan the ending',
                'Say the finish time on the invite. Ceremonies that do not '
                'announce an end do not have one.'),
          ],
        ),
        PpTable(
          heading: 'What to cut, in order',
          columns: ['Cut this first', 'Keep this'],
          rows: [
            ['The hall', 'A clean corner of your own home'],
            ['Return gifts', 'Sweets shared with everyone who came'],
            ['Full catering', 'One good dish and chai'],
            ['A professional photographer', 'One relative with a phone'],
            ['Printed invitations', 'A card on WhatsApp'],
            ['Two ceremonies', 'Both rituals on the same morning'],
            ['New clothes for the adults', 'Something new for the baby'],
          ],
        ),
        PpCallout('A small ceremony is not a compromised ceremony. The ritual '
            'is identical, the blessing is identical, and the child does not '
            'know the difference. The only thing that changes is who watches.'),
        PpCards(
          heading: 'Small versions that families genuinely love',
          hue: 44,
          [
            PpCard('Naming at home, over a video call',
                'Grandparents joining from another city, the name whispered '
                'and announced. Common now and it works.'),
            PpCard('Annaprashan at the kitchen table',
                'Grandfather, one spoon, three people, twenty photographs.'),
            PpCard('Mundan at home in the evening',
                'The barber comes to you, the child is calmer, and there is no '
                'queue.'),
            PpCard('First birthday as a breakfast',
                'Eight people, cake at 10am, everyone home by noon and the nap '
                'intact.'),
            PpCard('Giving instead of gifting',
                'A meal cooked for a school or shelter in the child\'s name, '
                'instead of return gifts.'),
          ],
        ),
        PpIndiaNote('If you are the daughter in law and this is not your call '
            'to make alone, the move that works is to offer a specific '
            'alternative rather than a refusal. "Let us do it at home on '
            'Sunday morning and I will make sure everyone gets fed properly" '
            'lands very differently from "I do not want a big function".'),
        PpVideoSlot(
          title: 'A complete ceremony in one hour, at home',
          subtitle: 'A real family doing the small version, start to finish.',
          minutes: '6 MIN',
          slotId: 'traditions/keeping_it_small',
        ),
        PpLink('What to say when family wants it bigger',
            pageId: 'family_pressure'),
        PpLink('What a ceremony actually costs', pageId: 'what_it_costs'),
      ],
    ),
    PpPage(
      id: 'family_pressure',
      title: 'What to say when family wants it bigger',
      subtitle: 'The exact words, for the conversations that are hard',
      format: 'SCRIPT BOX',
      blocks: [
        PpIntro('Most ceremony stress is not about the ceremony. It is about '
            'one conversation that nobody wants to start. Here are lines that '
            'work, written to keep the relationship intact rather than to win.'),
        PpScript(
          heading: 'When the guest list keeps growing',
          [
            PpScriptLine(
              say: 'We want to keep it to family this time, because she is '
                  'still so small. Let us do a bigger celebration at her '
                  'birthday.',
              notThis: 'We are not inviting all those people.',
              why: 'It gives a reason that is about the baby, not about them, '
                  'and it offers a future occasion instead of a closed door.',
            ),
            PpScriptLine(
              say: 'The doctor has said to keep gatherings small until her '
                  'vaccinations are done. We are just being careful.',
              notThis: 'It is not safe, obviously.',
              why: 'A doctor is a neutral third party. Elders rarely argue '
                  'with one, and it takes the disagreement out of the family.',
            ),
          ],
        ),
        PpScript(
          heading: 'When the budget is the real problem',
          [
            PpScriptLine(
              say: 'We have set aside this much for it, and we want to do it '
                  'properly within that. Can you help us decide what matters '
                  'most?',
              notThis: 'We cannot afford it.',
              why: 'Naming a number and asking for help turns a refusal into a '
                  'shared decision, and elders almost always choose the ritual '
                  'over the decor.',
            ),
            PpScriptLine(
              say: 'We would rather put that money into her name than into a '
                  'hall for one afternoon.',
              notThis: 'That is a waste of money.',
              why: 'It reframes the small version as a considered choice, '
                  'which it is, instead of a shortfall.',
            ),
          ],
        ),
        PpScript(
          heading: 'When a custom is one you are not comfortable with',
          [
            PpScriptLine(
              say: 'Let us do the puja exactly as you want, and do the '
                  'piercing at the clinic afterwards. Then there is no risk of '
                  'an infection spoiling the day.',
              notThis: 'That is unhygienic, we are not doing it that way.',
              why: 'It agrees to the ceremony and moves only the method. Almost '
                  'nobody objects when the ritual is left untouched.',
            ),
            PpScriptLine(
              say: 'The paediatrician was very clear about no honey before one '
                  'year. Can we use a little dates paste instead? Everything '
                  'else stays the same.',
              notThis: 'You cannot give her that, it is dangerous.',
              why: 'It names the authority, offers a substitute, and keeps the '
                  'grandmother\'s role in the ritual intact, which is usually '
                  'what she is actually protecting.',
            ),
            PpScriptLine(
              say: 'We have stopped the kajal because the doctor found lead in '
                  'the ones sold in the market. I know it is not what we grew '
                  'up with.',
              notThis: 'That stuff is poison, why would you put it on a baby.',
              why: 'It blames the product, not the person offering it, and it '
                  'acknowledges that the custom came from love.',
            ),
          ],
        ),
        PpScript(
          heading: 'When the date does not work for you',
          [
            PpScriptLine(
              say: 'That week is too soon for her, but the following Sunday '
                  'works for us and we would love your help organising it.',
              notThis: 'We cannot do that date.',
              why: 'An alternative plus an invitation to help is almost never '
                  'refused. A flat no almost always is.',
            ),
          ],
        ),
        PpCallout('If a conversation is going badly, stop it rather than '
            'finish it. "Let me think about it and we will talk tomorrow" is a '
            'complete sentence, and most ceremony arguments settle themselves '
            'overnight.'),
        PpIndiaNote('Get your partner to say the difficult line to their own '
            'parents. It is not fair, it is not modern, and it works better '
            'than anything else on this page.'),
        PpLink('How to keep it small', pageId: 'keeping_it_small'),
        PpLink('Customs done with love that are not safe',
            pageId: 'newborn_customs'),
      ],
    ),
  ],
);

// =============================================================================
//  AREA 7 — Customs done with love that are not safe
// -----------------------------------------------------------------------------
//  ⚠️ THE HARDEST WRITING IN THE SECTION, AND THE TONE IS THE WHOLE JOB.
//
//  Every practice on these two pages is done by someone who loves this baby and
//  believes it helps. Copy that sneers gets the app closed and the practice
//  continued, which is the outcome that costs a child something. So each card
//  follows one shape: name the custom, say who it comes from and why, state the
//  harm in one clean sentence, give the thing to do instead, and stop.
//
//  ⚠️ EVERY CLAIM ON THESE PAGES IS MARKED `REQUIRED_REVIEW:` AND NEEDS A
//  CLINICIAN TO SIGN IT OFF BEFORE SHIP. Not because any of it is obscure, but
//  because this is the part of the section a family will act on immediately.
// =============================================================================

final PpArea _notSafe = PpArea(
  id: 'not_safe',
  mark: IntentMark.checkMark,
  title: 'Customs done with love that are not safe',
  blurb: 'The few that genuinely harm a baby, and what to do instead.',
  hue: 8,
  pages: [
    PpPage(
      id: 'newborn_customs',
      title: 'On a newborn: kajal, honey and the cord',
      subtitle: 'Six customs worth stopping, and why',
      format: 'CARDS',
      blocks: [
        PpIntro('Almost everything passed down in Indian homes is harmless and '
            'a lot of it is genuinely good. A short list is not. These are the '
            'ones worth knowing about, said plainly, with no judgement of '
            'anyone who has been doing them.'),
        PpArticle([
          'Every custom below is done out of love, usually by a grandmother '
          'who did the same for her own children and saw them grow up fine. '
          'She is not being careless. The information simply was not available '
          'when she was doing this, and some of these products are sold '
          'openly in shops, which makes them look approved.',
          'So this is a page to read, not a page to hand to someone as proof. '
          'The words that actually work in the room are on the family '
          'conversation page.',
        ]),
        // REQUIRED_REVIEW: kajal / surma lead content. Claims to confirm:
        // traditional and market kajal and surma have repeatedly been found to
        // contain lead, lead is toxic to a developing brain with no safe level,
        // and it can also block tear ducts and irritate the eye. Confirm the
        // advice to raise past use with a doctor.
        PpCards(
          heading: 'The eyes: kajal and surma',
          hue: 8,
          [
            PpCard('What is done',
                'Kajal is put in or around a baby\'s eyes, and often a dot on '
                'the cheek or forehead, to protect from nazar and to make the '
                'eyes look bigger and stronger.'),
            PpCard('Why it is not safe',
                'Traditional and market kajal and surma have repeatedly been '
                'found to contain lead. Lead is absorbed easily by a baby and '
                'is toxic to a developing brain, and there is no amount of it '
                'that is considered safe.'),
            PpCard('What to do instead',
                'Nothing in or near the eyes. If the custom matters to your '
                'family, a small dot behind the ear or on the sole of the foot '
                'keeps the tradition and keeps it away from her eyes.'),
            PpCard('If you have been using it',
                'Stop, and mention it at her next visit. Ask the doctor '
                'whether a lead test is worth doing, especially if it has been '
                'used daily for months.'),
          ],
        ),
        // REQUIRED_REVIEW: honey and infant botulism, under 12 months.
        PpCards(
          heading: 'The mouth: honey, ghutti and gripe water',
          hue: 8,
          [
            PpCard('Honey, in any form, before one year',
                'Honey can carry spores that a baby\'s gut cannot yet handle, '
                'and infant botulism is a serious illness. This includes honey '
                'on a finger, in kheer, and on a soother. After her first '
                'birthday it is fine.'),
            PpCard('Janam ghutti and unregulated ghutti mixtures',
                'These are unregulated, the contents vary batch to batch, and '
                'some have been found to contain heavy metals or opium '
                'derivatives. A newborn gut does not need any of it.'),
            PpCard('Gripe water',
                'Widely sold and widely given. There is no good evidence it '
                'helps colic, some formulations have contained alcohol or '
                'sugar, and it fills a small stomach that should be taking '
                'milk.'),
            PpCard('What to do instead',
                'For the first six months, breast milk or formula and nothing '
                'else. For a windy or unsettled baby, upright holding, '
                'burping, a warm bath and gentle tummy massage do more than '
                'any bottle from a shop.'),
          ],
        ),
        // REQUIRED_REVIEW: umbilical cord care. Claims to confirm: nothing
        // should be applied to the stump, dry cord care is standard, and
        // applying cow dung, ash, oil, turmeric or kajal carries a real risk of
        // neonatal tetanus and other infection. Confirm the infection signs.
        PpCards(
          heading: 'The umbilical stump: keep it dry and bare',
          hue: 8,
          [
            PpCard('What is done',
                'Cow dung, ash, oil, turmeric, kajal or a coin is applied to '
                'the stump to help it dry and fall off faster.'),
            PpCard('Why it is not safe',
                'Anything applied to the stump can introduce infection '
                'directly into the bloodstream, and neonatal tetanus from '
                'exactly this practice is still seen in India. It is one of '
                'the most dangerous customs on this page.'),
            PpCard('What to do instead',
                'Nothing on it at all. Keep it clean, dry and open to air, and '
                'fold the nappy down below it. It falls off on its own, '
                'usually within one to three weeks.'),
            PpCard('When to see a doctor',
                'Redness spreading onto the tummy, swelling, pus, a bad smell, '
                'bleeding that does not stop, or a fever. Any of these needs a '
                'doctor the same day.'),
          ],
        ),
        // REQUIRED_REVIEW: water before 6 months. Claims to confirm: exclusive
        // milk feeding for about the first 6 months, and that plain water in
        // any quantity before then can displace milk and, in larger amounts,
        // cause dangerously low sodium.
        PpCards(
          heading: 'Water, and being made to drink in the heat',
          hue: 8,
          [
            PpCard('What is done',
                'In summer, spoons of water, sugar water or gripe water are '
                'given to a young baby who seems hot or thirsty.'),
            PpCard('Why it is not safe',
                'Before six months, milk supplies all the water she needs, '
                'even in Indian summers. Water fills a very small stomach and '
                'displaces milk, and in larger amounts it can dangerously '
                'dilute the salts in her blood.'),
            PpCard('What to do instead',
                'Feed more often in hot weather. Keep her in light cotton, out '
                'of direct sun, and in the coolest room. From six months, '
                'sips of water with meals are fine and expected.'),
          ],
        ),
        // REQUIRED_REVIEW: swaddling and hip dysplasia; also head shaping.
        PpCards(
          heading: 'The body: tight swaddling and head shaping',
          hue: 8,
          [
            PpCard('Tight swaddling with the legs straightened',
                'Wrapping a baby tightly with the legs pulled straight and '
                'pressed together is linked to hip problems, because a baby\'s '
                'hip joint needs to sit bent and open to develop properly.'),
            PpCard('What to do instead',
                'Swaddle the arms if it settles her, and leave the legs loose '
                'enough to bend up and out, like a frog. You should be able to '
                'slide a hand in at her chest. Stop swaddling once she starts '
                'trying to roll.'),
            PpCard('Shaping the head with pressure or a tight cloth',
                'Pressing or binding a baby\'s head to round it does not work '
                'and can be harmful. Skull shape from lying is common and '
                'usually corrects itself.'),
            PpCard('What to do instead',
                'Plenty of supervised tummy time while she is awake, and '
                'change which end of the cot her head is at. If one side stays '
                'flat, or her head looks lopsided, ask your paediatrician, '
                'because it is very treatable when picked up early.'),
          ],
        ),
        PpCallout(
          'One clean rule that covers most of this list: in the first six '
          'months, nothing goes into her mouth, eyes, ears, nose or navel '
          'except breast milk, formula, and medicine a doctor has prescribed. '
          'Oil for a malish on her skin is fine. Everything else waits.',
          kind: PpCalloutKind.safety,
          title: 'The rule that covers most of it',
        ),
        PpCallout(
          'If any of these has been done, do not panic and do not blame '
          'anybody. Stop it, and mention it at the next visit. Take her to a '
          'doctor now, rather than at the next visit, if she has a fever under '
          'three months, is feeding poorly, has gone floppy or unusually '
          'sleepy, is breathing fast, or the cord area looks red or smells.',
          kind: PpCalloutKind.doctor,
          title: 'If something on this page has already been done',
        ),
        PpIndiaNote('Most of the good ones are still good. Malish with warm '
            'oil, being carried constantly, cosleeping, jhula, ajwain water '
            'for the mother, ghee in her food from six months. This page is a '
            'short list of exceptions, not a verdict on how your family raises '
            'children.'),
        PpVideoSlot(
          title: 'Kajal, honey and the cord, explained calmly',
          subtitle: 'The five minute version to watch with a grandmother, not '
              'at her.',
          minutes: '5 MIN',
          slotId: 'traditions/newborn_customs',
        ),
        PpLink('Dadi ke nuskhe, checked one by one',
            surfaceId: 'pp_nuskhe',
            blurb: 'The home remedies, with an honest note on each.'),
        PpLink('What to say, without a fight', pageId: 'family_pressure'),
      ],
    ),
    PpPage(
      id: 'ceremony_day_safety',
      title: 'On the day: blades, piercing and heat',
      subtitle: 'The things that go wrong at ceremonies, and how to prevent them',
      format: 'CARDS',
      blocks: [
        PpIntro('Ceremony days have their own small risks, and they are all '
            'preventable with one decision made a week in advance. Here is the '
            'short list, ceremony by ceremony.'),
        // REQUIRED_REVIEW: blade hygiene, as on the mundan page.
        PpCards(
          heading: 'Anything involving a blade',
          hue: 8,
          [
            PpCard('One fresh sealed blade, opened in front of you',
                'A reused or wiped down blade can pass on hepatitis B, '
                'hepatitis C or HIV through a small scalp nick, and scalp '
                'nicks are common at a mundan.'),
            PpCard('Ask before you book, not on the morning',
                'A barber who is used to mundans will say yes immediately. '
                'Hesitation is your answer.'),
            PpCard('Nothing on a nick',
                'No ash, no turmeric, no oil, no paste. Clean water, kept dry, '
                'and a doctor if it becomes red or swollen or she develops a '
                'fever.'),
          ],
        ),
        // REQUIRED_REVIEW: piercing hygiene, as on the karnavedha page.
        PpCards(
          heading: 'Ear piercing',
          hue: 8,
          [
            PpCard('Sterile single use needle, or a sealed sterile cartridge',
                'Not a sewing needle, not a thorn, not a reused stud, not a '
                'gun barrel that has only been wiped.'),
            PpCard('Light plain studs, and clean hands for six weeks',
                'Heavy earrings on an infant pull and tear a healing hole.'),
            PpCard('Postpone if she is unwell or the skin is broken',
                'And see a doctor for spreading redness, heat, pus, fever, or '
                'a stud that sinks into the lobe.'),
          ],
        ),
        // REQUIRED_REVIEW: heat, dehydration and missed feeds at long events;
        // and infection exposure in a crowd for an under-3-month baby.
        PpCards(
          heading: 'Long ceremonies, heat and crowds',
          hue: 8,
          [
            PpCard('Do not let a ceremony delay a feed',
                'No baby should be kept waiting for an auspicious moment. Feed '
                'her, then do the ritual. Every priest in the country has seen '
                'this and will wait.'),
            PpCard('Watch for overheating',
                'Flushed, damp hair, breathing fast, unusually sleepy. Move '
                'her somewhere cool, remove a layer, offer a feed. Fewer wet '
                'nappies than usual means she needs more milk, not water, if '
                'she is under six months.'),
            PpCard('Keep her out of the crowd if she is under three months',
                'Not passed around, not kissed on the face, and away from '
                'anyone with a cough or a cold. A fever of 100.4F or 38C in a '
                'baby that young needs a doctor the same day.'),
            PpCard('Havan smoke, incense and firecrackers',
                'Smoke irritates young lungs, and firecrackers are far too '
                'loud for a baby\'s ears. Keep her in another room with a '
                'window open, or outside the smoke entirely.'),
          ],
        ),
        PpCards(
          heading: 'The ordinary things that actually go wrong',
          hue: 44,
          [
            PpCard('The nap gets skipped',
                'This causes more ceremony day misery than everything else on '
                'this page combined. Plan the time around it.'),
            PpCard('Nobody is watching the toddler',
                'Diyas, hot food, coins, small pooja items on a low table. '
                'Give one adult the single job of watching him.'),
            PpCard('Stiff new clothes',
                'Wash the new outfit once first. Zari and stiff seams scratch, '
                'and a baby who is itchy will cry through the whole ceremony.'),
            PpCard('No quiet room',
                'Decide in advance which room she can be taken to. You will '
                'need it at some point.'),
          ],
        ),
        PpCallout(
          'The one decision that prevents most of this: ask about the blade or '
          'the needle a week before, and fix the time around her nap and her '
          'feed. Everything else on this page follows from those two.',
          kind: PpCalloutKind.safety,
          title: 'Decide it a week early',
        ),
        PpCallout(
          'Go to a doctor the same day for a fever in a baby under three '
          'months, spreading redness or pus at any cut or piercing, fast or '
          'laboured breathing, a baby who has gone floppy or is hard to wake, '
          'or a burn. For a burn, cool it under running water for twenty '
          'minutes first, and do not put ghee, toothpaste or ice on it.',
          kind: PpCalloutKind.doctor,
          title: 'When to leave the ceremony and go',
        ),
        PpIndiaNote('None of this needs to be announced to the room. Ask the '
            'barber about the blade on the phone, tell the priest quietly that '
            'she needs feeding first, and pick the quiet room yourself. The '
            'ceremony runs exactly as everyone expects and she is fine.'),
        PpLink('Mundan, in full', pageId: 'mundan'),
        PpLink('Karnavedha, ear piercing, in full', pageId: 'karnavedha'),
        PpLink('What to say, without a fight', pageId: 'family_pressure'),
      ],
    ),
  ],
);
