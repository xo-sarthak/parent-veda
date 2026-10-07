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
    blurb: 'The sixth-day welcome, the naming, the cradle, the first outing.',
  ),
  PpBand(
    id: 'half_year',
    label: '4 months to 1 year',
    fromMonths: 4,
    toMonths: 12,
    blurb: 'The first rice feeding and the first solid meal.',
  ),
  PpBand(
    id: 'first_years',
    label: '1 to 3 years',
    fromMonths: 12,
    toMonths: 36,
    blurb: 'The first birthday, the first head shaving, ear piercing.',
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
  intro: 'The ceremonies Indian families do for a new baby, in plain words. '
      'What happens, what you need, what it costs, and what you '
      'can happily skip.',
  bandSet: kPpTraditionsBands,
  // ⚠️ THE AGE RULE, THE ONE FIX. The four chips came off and with them the
  // "everything here is worth reading at any age" line they triggered. Six
  // areas are for every age and show in full; "Which ceremony is coming up
  // now?" is the one band-tagged area and opens the right chart for her
  // age on its own.
  autoScope: true,
  areas: [
    _whatsNow,
    _welcome,
    _firstMeal,
    _milestones,
    _otherFaiths,
    _keepItSmall,
    _notSafe,
    _firstFestivals, // [NEW AREA], on the user's call (call 2)
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
      label: 'Home remedies from the elders, checked',
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
        // ⚠️ ADDED IN THE S07-S11 PASS. This area had no video at all, and
        // the doc asks for one in every sub-section - spelled out in the
        // early sections, then pointed at the prompt once it became
        // repetitive.
        PpVideoSlot(
          title: 'The ceremonies of the first year',
          subtitle: 'What each one is for, when it usually happens, and what to arrange ahead.',
          minutes: '6 MIN',
          slotId: 'traditions/first_year_ceremonies',
        ),
        PpIntro('In the first weeks you\'ll hear about a lot of ceremonies: the sixth-day welcome (chatti), '
            'the naming (namkaran), the cradle (jhula), the first outing. Here they are in the order they '
            'usually come, with the day each one tends to fall on.'),
        PpChartCard(
          title: 'The usual order',
          subtitle: 'Counting from the day your baby was born',
          rows: [
            ('Day 6 or 7', 'The sixth-day welcome (chatti or chhathi)'),
            ('Day 11 or 12', 'The naming (namkaran)'),
            ('Day 11 to 40', 'The cradle ceremony (jhula or palna)'),
            ('Around day 40', 'The first outing (nishkramana)'),
            ('No fixed day', 'Ear piercing, in families that do it early'),
          ],
          note: 'Every one of these days shifts by family and by region, and '
              'many families now fold two of them into one afternoon.',
          hue: 32,
        ),
        PpCallout('If these first weeks are hard, move the ceremony. A ritual '
            'done at two months instead of eleven days counts just the same, '
            'and nothing is lost by waiting until you can enjoy it.'),
        PpIndiaNote('In most joint families the elders pick the date, and you '
            'hear about it rather than choose it. If it lands badly, say so '
            'early and offer another date instead of a no. The page on family '
            'expectations has words you can use.'),
        PpLink('The sixth-day welcome (chatti)', pageId: 'chatti'),
        PpLink('The naming ceremony (namkaran)', pageId: 'namkaran'),
        PpLink('The cradle ceremony (jhula)', pageId: 'jhula'),
        PpLink('The first outing (nishkramana)', pageId: 'nishkramana'),
        PpLink('What to say when family wants it bigger',
            pageId: 'family_pressure'),
      ],
    ),
    PpPage(
      id: 'now_half_year',
      title: 'Coming up: the first solid meal',
      format: 'CHART-CARD',
      bands: ['half_year'],
      blocks: [
        PpIntro('The big one in these months is the first rice feeding (annaprashan), the first taste of '
            'solid food. It\'s the one ceremony that lines up almost exactly '
            'with what your paediatrician would tell you anyway.'),
        PpChartCard(
          title: 'What falls in this stretch',
          rows: [
            ('5 to 8 months', 'The first rice feeding (annaprashan)'),
            ('Around 6 months', 'Solids start, ceremony or not'),
            ('Any time', 'Ear piercing, in families that wait this long'),
            ('At 12 months', 'The first birthday'),
          ],
          note: 'Around six months is both the traditional window and the '
              'medical one, which is not a coincidence.',
          hue: 96,
        ),
        PpCallout('Say the auspicious date lands at five months, and your baby '
            'isn\'t sitting or interested in food yet. Do the ceremony with a '
            'symbolic lick, and start real food when your baby is ready. The '
            'date and the diet don\'t have to be the same decision.'),
        PpLink('The first rice feeding (annaprashan)', pageId: 'annaprashan'),
        PpLink('What to feed, on the day and after',
            pageId: 'annaprashan_food'),
        PpLink('Starting solids, step by step',
            surfaceId: 'pp_feeding',
            blurb: 'The feeding guide, with textures, portions and first '
                'foods.'),
      ],
    ),
    PpPage(
      id: 'now_first_years',
      title: 'Coming up: birthday, first head shaving, ears',
      format: 'CHART-CARD',
      bands: ['first_years'],
      blocks: [
        PpIntro('Between one and three the ceremonies get bigger and more '
            'public. This is also when the pressure to spend is strongest, so '
            'read the page on keeping it small before you book '
            'anything.'),
        PpChartCard(
          title: 'What falls in these two years',
          rows: [
            ('At 12 months', 'The first birthday'),
            ('Year 1 or year 3', 'The first head shaving (mundan)'),
            ('6 months to 5 years', 'Ear piercing (karnavedha)'),
            ('From about 2 years', 'The start of learning (aksharabhyasam)'),
          ],
          note: 'Odd years are considered auspicious for the head shaving in most '
              'families, which is why it is usually one or three and rarely '
              'two.',
          hue: 268,
        ),
        PpCallout('Toddlers have opinions. Plan around the nap, keep the '
            'ceremony short, and expect some crying through the important '
            'bit. That\'s normal, and the ceremony still counts.'),
        PpLink('The first head shaving (mundan)', pageId: 'mundan'),
        PpLink('Ear piercing (karnavedha)', pageId: 'karnavedha'),
        PpLink('The first birthday', pageId: 'first_birthday'),
        PpLink('What a ceremony really costs', pageId: 'what_it_costs'),
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
            ('2 to 5 years', 'The first letters (aksharabhyasam)'),
            ('Often at Vijayadashami', 'The traditional day for it'),
            ('Year 3, if not done at 1', 'The head shaving, for families who waited'),
            ('7 to 11 years', 'The Parsi initiation (Navjote)'),
            ('Around 11 years', 'The first turban (Dastar Bandi), in Sikh families'),
          ],
          note: 'If a ceremony on this list has already passed for your child, '
              'nothing is owed, and there\'s nothing to make up.',
          hue: 200,
        ),
        PpCallout('The first letters ceremony marks a beginning. It isn\'t a test. Many '
            'children trace a letter with help on the day, then show no '
            'interest for another year. That\'s completely normal.'),
        PpLink('The first letters (aksharabhyasam)', pageId: 'aksharabhyasam'),
        PpLink('The first head shaving (mundan)', pageId: 'mundan'),
        PpLink('Play that builds early learning',
            surfaceId: 'pp_activities',
            blurb: 'Age-matched play, with the reason each one helps.'),
      ],
    ),
    // ⚠️ [NEW], two scaffolds at the top, next to "what is coming up". "Half
    // the section tells a parent to push back on a bad muhurat but never
    // explains the muhurat." Copy supplied, not generated.
    PpPage(
      id: 'how_date_chosen',
      title: 'How the date gets chosen, and what to do when it doesn\'t suit your baby',
      subtitle: 'The Hindu calendar, the auspicious time, the priest, the birth-star',
      format: 'ARTICLE',
      
      blocks: [
        // Written 2026-10-02 (parenting gap analysis), filling the scaffold.
        // REQUIRED_REVIEW.
        PpIntro('In many families the Hindu calendar (panchang) sets the date of the naming, '
            'the first rice feeding or the head shaving. The priest works out an auspicious time (muhurat) '
            'from your baby\'s birth-star and the family\'s calendar. It\'s '
            'a lovely tradition, and there\'s usually more than one good date.'),
        PpArticle(heading: 'How it usually works', [
          'The priest looks at the date, time and place of birth, the birth star (nakshatra) '
              'and the lunar calendar, and suggests days that are considered '
              'auspicious. Families often have a range: naming on day 11 or '
              '12, rice feeding near six months, head shaving in the first or '
              'third year, with flexibility around them.',
        ]),
        PpArticle(heading: 'When the date does not suit the baby', [
          'Sometimes the auspicious time falls when your baby is unwell, too young for solid '
              'food, in the middle of vaccines, or during extreme heat or a crowded '
              'festival. It\'s fine to ask for another date. Most priests will '
              'suggest the next auspicious window if you explain the reason.',
          'For the first rice feeding, wait until your baby is about six months and ready '
              'for food. An earlier date can still be kept, with a symbolic touch '
              'of kheer to the lips and no solids fed.',
        ]),
        PpScript(heading: 'Words for the conversation', [
          PpScriptLine(
              say: 'The doctor wants us to wait until the vaccines are done. '
                  'Is there an auspicious day in the next month?',
              why: 'Asking for an alternative keeps the tradition and the baby\'s '
                  'needs together.'),
        ]),
      ],
    ),
    PpPage(
      id: 'how_name_chosen',
      title: 'How Indian families choose the name',
      subtitle: 'Birth-star letters, family names, numerology, and a name that survives school',
      format: 'ARTICLE',
      
      blocks: [
        // Written 2026-10-02 (parenting gap analysis), filling the scaffold.
        // REQUIRED_REVIEW.
        PpIntro('Choosing a name is one of the most loved decisions in an Indian '
            'family, and often one with many voices. Here are the traditions '
            'families draw on, and a few practical thoughts.'),
        PpCards(heading: 'The traditions', [
          PpCard('Birth sign and birth-star letters (rashi and nakshatra)', 'Many families pick a name starting '
              'with a syllable linked to the baby\'s birth-star.'),
          PpCard('Family and clan (gotra) names', 'Honouring a grandparent, a deity, or a '
              'family tradition.'),
          PpCard('Meaning', 'Names chosen for their meaning in Sanskrit, Tamil, '
              'Arabic, Persian, Punjabi or another language of the family.'),
          PpCard('Numerology', 'Some families check the name\'s number; others do '
              'not.'),
        ]),
        PpCards(heading: 'Practical thoughts', [
          PpCard('Say it aloud with the surname', 'At school roll call, and in '
              'another language.'),
          PpCard('Check the spelling once', 'It goes on the birth certificate, '
              'Aadhaar and passport.'),
          PpCard('A pet name is fine', 'Most children have a pet name at home and '
              'a formal name for school.'),
        ]),
        PpLink('Find a name', surfaceId: 'pp_names',
            blurb: 'Search names by meaning, letter and language.'),
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
  title: 'Welcoming your baby home',
  blurb: 'The sixth-day welcome, the naming, the cradle and the first outing.',
  hue: 24,
  pages: [
    // -------------------------------------------------------------------------
    //  Chatti
    // -------------------------------------------------------------------------
    PpPage(
      id: 'chatti',
      title: 'The sixth-day welcome (chatti)',
      subtitle: 'The first welcome, usually at home',
      format: 'CEREMONY',
      blocks: [
        PpIntro('The sixth-day welcome (chatti, or chhathi) falls on the sixth night after birth. It is the '
            'first time the family formally welcomes your baby, and in many '
            'homes it is also the night the name is chosen or first said.'),
        PpArticle(
          heading: 'What it is',
          [
            'Long ago, the sixth night was when a newborn was thought likely '
            'to thrive. Families marked it with a small night gathering, '
            'sweets, and a lamp kept lit. As the new mother, you usually rest '
            'through it.',
            'It is a home ceremony almost everywhere. There is no venue, no '
            'invitation list and no fixed length. In many families it is an '
            'hour of singing after dinner and nothing more.',
          ],
        ),
        PpWhenLine('The sixth night after birth. Some families count the sixth '
            'day instead, and Punjabi and Gujarati families often keep the '
            'whole night awake. That is why it is also called a night vigil (jagrata).'),
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
                'Many families keep the custom for the love in it.'),
            PpStep('The women of the house sing',
                'Traditional birth songs (sohar and badhai). This is usually the warmest part of '
                'the evening and costs nothing.'),
            PpStep('Sweets are shared and something is given away',
                'Often clothes or food to household help, or to a family who '
                'needs it.'),
            PpStep('The name may be said aloud for the first time',
                'In many families this is the naming ceremony itself, and there is no '
                'separate ceremony on the eleventh day.'),
          ],
        ),
        PpCards(
          heading: 'What you need',
          hue: 24,
          [
            PpCard('A lamp', 'One oil lamp. Kept away from the cot and never left '
                'burning unattended in the same room as the baby.'),
            PpCard('Sweets', 'Whatever the house makes. Halwa, laddoo, kheer.'),
            PpCard('A clean new cloth for the baby',
                'Washed before use, soft, nothing scratchy at the neck.'),
            PpCard('A pen and a blank page',
                'Symbolic. Placed near the cot, not in it.'),
            PpCard('Songs', 'If nobody remembers the words, playing the birth songs '
                'your mother knows on a phone is completely fine.'),
          ],
        ),
        PpCallout('What matters is that the household stops for an evening '
            'to mark that your baby is here. The lamp, the songs and the '
            'sweets are the ceremony. Everything else is extra.'),
        PpCards(
          heading: 'Happily optional',
          hue: 340,
          [
            PpCard('A priest', 'Most families do the sixth-day welcome without one.'),
            PpCard('Staying awake all night',
                'A vigil with a six day old baby and a healing mother is a lot. '
                'An hour of singing counts.'),
            PpCard('Inviting the extended family',
                'A six day old baby has no immune reserve to spare. Small is '
                'safer, and it\'s also the traditional way.'),
            PpCard('New clothes for everyone',
                'Nothing about the ceremony requires anyone to shop.'),
          ],
        ),
        // REQUIRED_REVIEW: newborn infection exposure at a gathering. Claim to
        // confirm: an under-3-month baby has limited immune defence, so keeping
        // the group small, excluding anyone unwell, handwashing before holding
        // and no kissing the face are the standard precautions.
        PpCallout(
          'Keep the group small, and ask anyone with a cough, cold or fever to '
          'come another week. Everyone washes hands before holding your baby, '
          'and nobody kisses the face or hands. A cold that is mild in an adult '
          'can be serious in a six day old.',
          kind: PpCalloutKind.safety,
          title: 'Six days old is very new',
        ),
        // REQUIRED_REVIEW: fever threshold in a young infant. Claim to confirm:
        // any fever of 100.4F / 38C or above in a baby under 3 months needs to
        // be seen the same day, no waiting.
        PpCallout(
          'A fever of 100.4F, or 38C, in a baby under three months means '
          'seeing a doctor the same day, even if all else seems fine. The same '
          'goes for a baby who is unusually floppy, refusing feeds, or not '
          'waking properly. Don\'t wait for morning.',
          kind: PpCalloutKind.doctor,
          title: 'If your baby is unwell after the gathering',
        ),
        PpIndiaNote('If you\'re in your forty days of rest and not up to a room full of people, '
            'that\'s normal and it\'s allowed. Guests can greet you in your '
            'room, and you can come out for ten minutes if you want to.'),
        PpVideoSlot(
          title: 'What happens at the sixth-day welcome',
          subtitle: 'A real family, a small home ceremony, start to finish.',
          minutes: '5 MIN',
          slotId: 'traditions/chatti',
        ),
        PpLink('The naming ceremony, if the name is being said tonight', pageId: 'namkaran'),
        PpLink('Customs done with love that are not safe',
            pageId: 'newborn_customs'),
        // [single-source] The short line above stays word for word; the full
        // newborn-gathering block lives once, on "On the day: blades,
        // piercing and heat".
        PpLink('The full newborn-in-a-crowd rule, once',
            pageId: 'ceremony_day_safety',
            blurb: 'Small group, washed hands, no kisses on the face, and the '
                'fever that means a doctor today.'),
      ],
    ),

    // -------------------------------------------------------------------------
    //  Namkaran
    // -------------------------------------------------------------------------
    PpPage(
      id: 'namkaran',
      title: 'The naming ceremony (namkaran)',
      subtitle: 'The day your baby\'s name is said out loud',
      format: 'CEREMONY',
      blocks: [
        PpIntro('The naming ceremony is the day your baby is formally named, with the '
            'name said aloud in front of the family. In most families it '
            'happens in the first two weeks, at home, and takes under an '
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
            'once the mother is through her forty days of rest and up to hosting.'),
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
                'person present says a blessing in their own words.'),
            PpStep('The name is whispered in the baby\'s ear',
                'Usually by the father or an aunt, three times. This is the '
                'moment the whole ceremony is built around.'),
            PpStep('The name is announced to the room',
                'Everyone repeats it. Some families write it on a plate of '
                'rice with a small stick or a gold ring.'),
            PpStep('Sweets are shared and blessings are given',
                'Elders bless the baby, often with a hand on the head or a '
                'small gift. Then it\'s done.'),
          ],
        ),
        PpCards(
          heading: 'What you need',
          hue: 268,
          [
            PpCard('A name you have both agreed on',
                'Settle it the day before, not on the day. A last-minute name '
                'debate causes more ceremony morning stress than anything.'),
            PpCard('A low table and a clean cloth',
                'Any table, any clean cloth. It does not have to be new.'),
            PpCard('A lamp, flowers and rice',
                'An oil lamp, whatever flowers are available, a plate of raw rice '
                'if the name is being written.'),
            PpCard('Something new for the baby to wear',
                'Washed once before the day. New fabric straight off a shelf '
                'can be stiff and dyed.'),
            PpCard('Sweets to share',
                'Made at home or bought. Nobody has ever judged the sweets.'),
            PpCard('A priest, only if your family wants one',
                'The priest\'s fee (dakshina) is usually between Rs 500 and Rs 2,100.'),
          ],
        ),
        PpCallout('What matters: the name is said out loud, and the '
            'people who matter hear it. The priest, the hall, the outfits and '
            'the photographer are all optional, and a naming done by four '
            'people in a bedroom is a complete naming.'),
        PpCards(
          heading: 'Happily optional',
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
          'Your baby is still very new. Keep the room airy and the group small, '
          'and ask anyone with a cough or cold to come another day. Hands are '
          'washed before holding, and nobody kisses the baby\'s face. If the '
          'noise is upsetting your baby, step out of the room together. The '
          'ceremony can wait ten minutes.',
          kind: PpCalloutKind.safety,
          title: 'Keeping a two week old comfortable',
        ),
        PpIndiaNote('If elders want a priest and you do not, the usual middle '
            'ground works: a short traditional blessing done by the eldest in '
            'the family. It costs nothing, it satisfies almost everyone, and '
            'it is what most homes did before priests were bookable by phone.'),
        PpVideoSlot(
          title: 'A naming ceremony, start to finish',
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
            blurb: 'Pick a template, add the name and a photo, share it.'),
        PpLink('Ceremony essentials, if you are buying',
            surfaceId: 'pp_products',
            blurb: 'Silver spoon sets, outfits, thali sets. Compare before you '
                'buy.'),
        PpLink('How to keep it small', pageId: 'keeping_it_small'),
        // [single-source] The short line above stays word for word; the full
        // newborn-gathering block lives once, on "On the day: blades,
        // piercing and heat".
        PpLink('The full newborn-in-a-crowd rule, once',
            pageId: 'ceremony_day_safety',
            blurb: 'Small group, washed hands, no kisses on the face, and the '
                'fever that means a doctor today.'),
      ],
    ),

    // -------------------------------------------------------------------------
    //  Jhula
    // -------------------------------------------------------------------------
    PpPage(
      id: 'jhula',
      title: 'The cradle ceremony (jhula)',
      subtitle: 'The day your baby first goes into the cradle',
      format: 'CEREMONY',
      blocks: [
        PpIntro('The cradle ceremony (jhula, palna or thottil) is the first time your '
            'baby is placed in the cradle, with the family watching and '
            'singing. In many south Indian families the naming happens in the '
            'same hour, in the cradle.'),
        PpArticle(
          heading: 'What it is',
          [
            'It\'s a handover moment. Until now your baby has been in arms, and '
            'the cradle is the first place that is the baby\'s own. Usually a '
            'grandmother lays the baby down, the family sings, and the cradle '
            'is rocked for the first time.',
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
            PpStep('Your baby goes into the cradle for the first time',
                'Lying face up on a firm, flat mattress, with nothing loose '
                'nearby.'),
            PpStep('The cradle is rocked gently while the family sings',
                'A lullaby. In many families each aunt sings one line.'),
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
                'A cloth swing cradle, a wooden cradle, or a modern cot. The ceremony '
                'does not care which.'),
            PpCard('Flowers or a garland',
                'Tied on the outside of the cradle, never draped across your '
                'baby.'),
            PpCard('A firm flat mattress and one thin sheet',
                'This is the only part of the cradle that is a safety matter, '
                'not a style one.'),
            PpCard('A lullaby somebody knows',
                'Any lullaby will do. Babies settle to a loved voice more than '
                'a tune.'),
            PpCard('Sweets to share',
                'Whatever the house makes. Nobody has ever judged the sweets.'),
          ],
        ),
        PpCallout('What matters is a safe cradle and somebody singing. '
            'Marigolds, a silver rattle and a videographer are all fully '
            'optional.'),
        // REQUIRED_REVIEW: safe sleep in a cradle or cloth jhula. Claims to
        // confirm: firm flat mattress, on the back, no pillows or loose cloth,
        // nothing tied above that can fall in, do not swing hard or leave a
        // baby unattended in a hanging cloth jhula, and check the hook or
        // suspension of a hanging cradle before the first use.
        PpCallout(
          'Before your baby goes in, check three things. The mattress is firm '
          'and flat, with no pillow, no quilt and no loose cloth. Nothing is '
          'tied above that could come loose and fall in. And for a hanging '
          'cloth swing, test the hook and knots first by pulling on them with '
          'your own weight. Rock it gently, never swing it hard, and do not '
          'leave a baby sleeping in a hanging cloth swing '
          'unwatched.',
          kind: PpCalloutKind.safety,
          title: 'The cradle itself',
        ),
        PpCallout(
          'Rocking a baby hard, or shaking a cradle to stop crying, can injure '
          'a young baby\'s brain. Keep every movement slow and small. If the '
          'crying has pushed you past your patience, lay your baby down '
          'somewhere safe and step out of the room for two minutes. That is '
          'the right thing to do, and every parent needs it sometimes.',
          kind: PpCalloutKind.safety,
          title: 'Gently, always',
        ),
        PpIndiaNote('A cloth swing cradle tied to a beam is what most of India uses, '
            'and it works. The safety points are the same as any cot: firm '
            'surface, baby on the back, nothing loose. A cloth swing is as good a '
            'place to sleep as an imported cot.'),
        PpVideoSlot(
          title: 'The cradle ceremony, and setting the cloth swing up safely',
          subtitle: 'How it\'s done, and the three checks before your baby goes in.',
          minutes: '5 MIN',
          slotId: 'traditions/jhula',
        ),
        PpLink('The naming ceremony, if you are doing both together', pageId: 'namkaran'),
        PpLink('Lullabies and sleep sounds',
            surfaceId: 'pp_sleep_sounds',
            blurb: 'Lullabies, white noise and soft ragas, with a timer.'),
      ],
    ),

    // -------------------------------------------------------------------------
    //  Nishkramana
    // -------------------------------------------------------------------------
    PpPage(
      id: 'nishkramana',
      title: 'The first outing (nishkramana)',
      subtitle: 'Your baby\'s first time out of the house',
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
            'the end of that resting time. The ceremony is the family '
            'stepping outside together with the baby for the first time.',
            'Here the old custom and current paediatric advice agree more '
            'than they disagree. '
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
            PpStep('The baby is dressed and often has a small kohl (kajal) dot placed '
                'behind the ear or on the foot',
                'Behind the ear or on the sole, never near or in the eyes. The '
                'safety page explains why.'),
            PpStep('The family steps out together',
                'Traditionally the father or grandfather carries the baby over '
                'the threshold.'),
            PpStep('Your baby is shown the sun, the moon or the sky',
                'This is the heart of it. It takes about a minute.'),
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
                'Whatever keeps your baby held close, not passed down a queue.'),
            PpCard('Somewhere uncrowded to go',
                'A terrace, a garden, a temple at an empty hour. A mall is not '
                'the tradition.'),
          ],
        ),
        PpCallout('The symbolic version counts fully. Open a window at '
            'sunrise, say the blessing, and show your baby the sky from your '
            'own balcony. That is a complete nishkramana. Many families now do '
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
          'your baby out of the arms of anyone who is unwell.',
          kind: PpCalloutKind.safety,
          title: 'Sun, crowds and the first trip out',
        ),
        PpCallout(
          'If your baby gets a fever after an outing: under three months, a '
          'temperature of 100.4F or 38C needs a doctor the same day. Also see '
          'a doctor for fast or laboured breathing, a baby who won\'t feed, '
          'or one who has become unusually floppy or hard to wake.',
          kind: PpCalloutKind.doctor,
          title: 'If your baby is unwell afterwards',
        ),
        PpIndiaNote('If your family keeps to the fortieth day and the weather '
            'is harsh, do the ceremony at dawn. The tradition never meant a '
            'newborn to be carried through 42 degrees at noon to keep a '
            'date.'),
        PpVideoSlot(
          title: 'The first outing, done gently',
          subtitle: 'Both versions, the temple visit and the at home one.',
          minutes: '4 MIN',
          slotId: 'traditions/nishkramana',
        ),
        PpLink('Vaccinations, and what is due',
            surfaceId: 'pp_vaccines',
            blurb: 'The schedule, what each one is for, and reminders.'),
        PpLink('Customs done with love that are not safe',
            pageId: 'newborn_customs'),
        // [single-source] The short line above stays word for word; the full
        // newborn-gathering block lives once, on "On the day: blades,
        // piercing and heat".
        PpLink('The full newborn-in-a-crowd rule, once',
            pageId: 'ceremony_day_safety',
            blurb: 'Small group, washed hands, no kisses on the face, and the '
                'fever that means a doctor today.'),
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
  title: 'The first solid meal',
  blurb: 'The first rice feeding, and what to feed on the day.',
  hue: 96,
  pages: [
    PpPage(
      id: 'annaprashan',
      title: 'The first rice feeding (annaprashan)',
      subtitle: 'The first grain, usually around six months',
      format: 'CEREMONY',
      blocks: [
        PpIntro('The first rice feeding is the ceremony where your baby has solid food '
            'for the first time. Usually it\'s a spoon of kheer or sweetened '
            'rice, fed by an uncle or grandfather. It is the most widely performed '
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
            'breastfeeding or formula. So here the tradition and the guidance '
            'point at the same month. You don\'t have to choose between your '
            'family and your doctor.',
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
                'Pick a slot right after a nap, before hunger sets in. A tired '
                'or very hungry baby won\'t be in the mood.'),
            PpStep('The food is cooked, often kheer or plain sweet rice',
                'Traditionally made by the grandmother. Cooked soft, mashed '
                'smooth, and cooled properly.'),
            PpStep('Your baby is dressed and seated on a lap or a decorated chair',
                'Upright and supported. Never lying back while being fed.'),
            PpStep('A short blessing is said'),
            PpStep('The first spoon is given, usually by the maternal uncle or '
                'the grandfather',
                'One small spoonful, from a silver or steel spoon. Your baby may '
                'taste it, spit it out, or ignore it. All three are fine.'),
            PpStep('The family takes turns to feed a token spoon',
                'This is where it can get carried away. One or two tokens are '
                'plenty for a six month old.'),
            PpStep('In some families, objects are placed in front of the baby '
                'to choose from',
                'A pen, a book, a coin, some clay. The one your baby reaches for '
                'is said to hint at the path ahead. It\'s a game, and a lovely '
                'photo.'),
          ],
        ),
        PpCards(
          heading: 'What you need',
          hue: 96,
          [
            PpCard('A silver or steel bowl and spoon',
                'Silver is traditional. Steel works just as well. A soft '
                'weaning spoon is kinder on little gums than metal.'),
            PpCard('The first food itself',
                'Kheer, sweet rice, or plain mashed rice with dal water. See '
                'the next page for what suits a six month old.'),
            PpCard('A bib and a cloth',
                'Most of the first meal ends up on the chin.'),
            PpCard('A chair or a lap to sit upright in',
                'Upright and supported, never reclined. A high chair works, so '
                'does a grandfather.'),
            PpCard('The choosing objects, if your family does that bit',
                'Nothing small enough to fit in a baby\'s mouth. No coins within '
                'reach.'),
            PpCard('New clothes, if you want them',
                'Cotton, loose, nothing tight at the neck for a meal.'),
          ],
        ),
        PpCallout('What matters is a baby who is upright, awake and calm, and '
            'food that is soft and cool. How much gets eaten doesn\'t matter at '
            'all. Plenty of babies lick the spoon once at their own '
            'rice feeding, and that is a complete ceremony.'),
        PpCards(
          heading: 'Happily optional',
          hue: 340,
          [
            PpCard('A temple or a hall',
                'Choroonu at Guruvayur is beautiful and a home version counts '
                'the same.'),
            PpCard('Twenty relatives each feeding a spoon',
                'Two is a ceremony. Twenty is a lot of sugar and a lot of '
                'hands near a small mouth.'),
            PpCard('Sweetened kheer specifically',
                'The grain is the point. Plain rice, ragi or dal water is a '
                'better first food and is still fully traditional.'),
            PpCard('An exact auspicious month',
                'If the date lands before your baby can sit with support, do '
                'the ceremony symbolically and start real solids when your baby '
                'is ready.'),
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
          'until your baby is one year old. No added salt or sugar in the first '
          'year. And test the temperature on your own wrist before the spoon '
          'goes near the baby. Kheer holds heat far longer than it '
          'looks.',
          kind: PpCalloutKind.safety,
          title: 'What goes in the bowl',
        ),
        PpCallout(
          'If your baby coughs, gags again and again, goes silent and red, or '
          'brings up the feed forcefully, stop and let the baby recover sitting '
          'upright. Talk to your doctor before the ceremony if your baby was '
          'premature, has reflux, has had trouble swallowing, or has not started '
          'solids yet at seven months. A paediatrician can tell you in one visit '
          'whether your baby is ready.',
          kind: PpCalloutKind.doctor,
          title: 'If feeding doesn\'t go smoothly',
        ),
        PpIndiaNote('If your family fixes the date by the panchang and it '
            'falls at five months, there\'s a middle ground almost everyone '
            'accepts. Touch the spoon to the lips on the day, and start real '
            'meals at six months. The date is kept, and so is a happy tummy.'),
        PpVideoSlot(
          title: 'A first rice feeding, and the first spoon',
          subtitle: 'How the ceremony runs, and how to hold and feed your baby '
              'safely during it.',
          minutes: '7 MIN',
          slotId: 'traditions/annaprashan',
        ),
        PpLink('What to feed, on the day and after',
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
      title: 'What to feed, on the day and after',
      subtitle: 'The ceremony food, and the real food that follows it',
      format: 'CARDS',
      blocks: [
        PpIntro('The ceremony is one spoonful. The real feeding happens in '
            'the weeks after it. Here is what suits a six month old, and the '
            'short list of things that must stay out of the '
            'bowl.'),
        PpCards(
          heading: 'Good first foods, all of them traditional',
          hue: 96,
          [
            PpCard('Plain rice, cooked soft and mashed',
                'The classic first rice feeding food, and a fine first food. Thin it '
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
          heading: 'Not before the first birthday',
          hue: 8,
          [
            PpCard('Honey',
                'Not a drop before twelve months. Honey can carry spores that '
                'a baby\'s gut cannot yet handle, and infant botulism is '
                'serious. This includes honey in kheer and honey on a soother.'),
            PpCard('Added salt',
                'A baby\'s kidneys aren\'t ready for it. Take the baby\'s portion '
                'out before you salt the family pot.'),
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
          'Start with small amounts, and bring in one new food every two or '
          'three days. That way, if something disagrees, you know which food '
          'it was. Always seated upright, always with an adult watching, '
          'never in a moving car or a rocking cradle.',
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
          'Rice water or dal water in place of milk is not a step up. Until '
          'the first birthday, milk still carries most of the nutrition, and '
          'solids are practice and iron. Don\'t cut feeds to make room for food.',
          kind: PpCalloutKind.myth,
          title: '"Solids started, so reduce the milk"',
        ),
        PpIndiaNote('If a grandmother is making the kheer for the ceremony, '
            'ask for the baby\'s portion to be lifted out before the sugar and '
            'honey go in. It\'s an easy thing to ask in advance, and an awkward '
            'one to say in front of everyone on the day.'),
        PpLink('Starting solids, step by step', surfaceId: 'pp_feeding'),
        PpLink('Recipes matched to your baby\'s age', surfaceId: 'pp_food'),
        PpLink('The first rice feeding, the ceremony itself', pageId: 'annaprashan'),
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
  blurb: 'The head shaving, ear piercing, the first birthday, and the first letters.',
  hue: 268,
  pages: [
    // -------------------------------------------------------------------------
    //  Mundan
    // -------------------------------------------------------------------------
    PpPage(
      id: 'mundan',
      title: 'The first head shaving (mundan)',
      subtitle: 'Usually in the first or third year',
      format: 'CEREMONY',
      blocks: [
        PpIntro('The head shaving (mundan) is the ceremony where a child\'s birth hair is shaved '
            'off for the first time. It is done at home, at a temple or at a '
            'family shrine, and the shaving itself is over in about ten '
            'minutes.'),
        PpArticle(
          heading: 'What it is',
          [
            'Birth hair is treated as belonging to the time before, and '
            'removing it marks a fresh start. In many families the hair is '
            'then offered at a temple or a river, or buried under a tree.',
            'In practice, it is also a toddler having a head shave from a '
            'stranger while a crowd watches. Almost every child cries. That is '
            'expected. It isn\'t a bad omen, and it says nothing about '
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
                'A hungry or tired toddler and a razor near the scalp are a '
                'hard mix. Go after a nap.'),
            PpStep('Your child sits on a lap, usually facing the parent',
                'Held firmly and calmly, chest to chest. The head stays still, '
                'and your child can hide against you.'),
            PpStep('A short blessing is said, and a first symbolic snip is '
                'taken',
                'Often by a grandfather or the maternal uncle.'),
            PpStep('The barber shaves the head',
                'A fresh blade, opened in front of you. Five to ten minutes.'),
            PpStep('The head is washed and the hair collected',
                'Lukewarm water. Check for nicks as you pat the head dry.'),
            PpStep('The hair is offered or buried, and sweets are shared',
                'Then take your child away from the crowd for some calm.'),
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
                'Opened in front of you. This is the one thing on the day you '
                'never bend on.'),
            PpCard('Lukewarm water and a soft towel',
                'For washing the head afterwards and checking it as you dry '
                'it.'),
            PpCard('A cap or a soft cotton scarf for afterwards',
                'A bare scalp burns fast in Indian sun.'),
            PpCard('Something distracting',
                'A favourite snack, a loved song, a phone if that is what '
                'works. Nobody is judging on the day of the head shaving.'),
            PpCard('A small pouch for the hair, if you are keeping it',
                'Many families offer it, bury it, or keep a lock of it. All '
                'three are done.'),
          ],
        ),
        PpCallout('What matters is a clean blade, a still head and a child '
            'who is fed and rested. The temple, the outfit and the photographs '
            'are all optional. A head shaving done by a local barber at home is '
            'exactly as complete as one at a famous temple.'),
        // REQUIRED_REVIEW: shaving hygiene. Claims to confirm: a reused or
        // unsterilised blade carries a risk of bloodborne infection including
        // hepatitis B, hepatitis C and HIV, and of tetanus through a scalp
        // nick; a new single use blade per person is the standard precaution;
        // tetanus is covered by routine childhood immunisation.
        PpCallout(
          'One blade, one child, opened in front of you. A reused or wiped '
          'down blade can pass on infections through a small scalp nick, and '
          'scalp nicks are common. If a barber won\'t open a new blade in '
          'front of you, find another barber. Check that your child\'s '
          'routine tetanus shots are up to date before the day.',
          kind: PpCalloutKind.safety,
          title: 'The blade is the whole safety question',
        ),
        PpCallout(
          'After the head shaving, keep the scalp out of direct sun, and leave small '
          'nicks alone, clean and dry. See a doctor if a cut turns red, '
          'swollen or warm, or starts to ooze. See one too for a fever in the '
          'following days, or a cut that is deep or won\'t stop bleeding. Don\'t '
          'put ash, turmeric, oil or any paste on a fresh cut.',
          kind: PpCalloutKind.doctor,
          title: 'If a nick doesn\'t settle',
        ),
        PpCallout(
          'Shaving a baby\'s head does not make the hair grow back thicker, '
          'darker or faster. Hair thickness is set by the follicle, and the '
          'new hair only looks coarser because it comes back with a blunt cut '
          'end. Do the head shaving for its meaning if you want to, but not for the '
          'hair.',
          kind: PpCalloutKind.myth,
          title: '"It will grow back thicker"',
        ),
        PpIndiaNote('Your family may be set on a particular temple, with a '
            'four hour queue in May heat. The usual middle path is a first '
            'symbolic snip at the temple, and the full shave at home in the '
            'evening. Families are almost always happy with it afterwards.'),
        PpVideoSlot(
          title: 'The head shaving, and how to hold your child through it',
          subtitle: 'The hold that keeps the head still, and the blade check.',
          minutes: '6 MIN',
          slotId: 'traditions/mundan',
        ),
        PpLink('At the ceremony itself: blades, piercing and heat',
            pageId: 'ceremony_day_safety'),
        PpLink('If your family keeps uncut hair (kesh) instead', pageId: 'sikh_naming'),
        // [single-source] The fresh-sealed-blade rule lives once, on "On the
        // day: blades, piercing and heat".
        PpLink('The blade rule, once',
            pageId: 'ceremony_day_safety',
            blurb: 'One fresh sealed blade, opened in front of you, and '
                'nothing on the shaved head.'),
      ],
    ),

    // -------------------------------------------------------------------------
    //  Karnavedha
    // -------------------------------------------------------------------------
    PpPage(
      id: 'karnavedha',
      title: 'Ear piercing (karnavedha)',
      subtitle: 'For girls and, in many families, for boys',
      format: 'CEREMONY',
      blocks: [
        PpIntro('Karnavedha is the ear piercing ceremony. Families differ '
            'a lot on when to do it, from a few weeks old to five years, and '
            'there is no single right answer. What matters most is how it is '
            'done.'),
        PpArticle(
          heading: 'What it is',
          [
            'Most Indian communities pierce the ears of girls, and many pierce '
            'boys\' ears as well. It is often done on the same day as another '
            'ceremony, to save a second gathering. In the south it often goes '
            'with the head shaving or the naming.',
            'It is a small procedure, but it still makes a wound. Clean tools '
            'and good aftercare make the difference between an easy piercing '
            'and a hard month, so most of this page is about those.',
          ],
        ),
        PpWhenLine('Anywhere from a few weeks to five years, depending on the '
            'family. Aftercare is much easier once a child can leave the '
            'ears alone and tell you if it hurts.'),
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
                'is the easiest way to feel sure.'),
            PpStep('Check what is being used',
                'A sterile single use needle, or a sealed sterile cartridge. '
                'Gloves. Skin cleaned first. A reusable gun barrel that is '
                'only wiped between customers is the version to avoid.'),
            PpStep('Feed your child first and go after a nap',
                'A calm child is a still child, and stillness is what keeps '
                'the holes even.'),
            PpStep('Hold your child firmly, and take a cuddle straight after',
                'Chest to chest. It is over in seconds, and the crying stops '
                'faster than you expect.'),
            PpStep('Plain gold or medical grade studs go in',
                'Small, light, flat backed. Not heavy hanging earrings and not a wire '
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
            PpCard('Clean hands, every time you touch the ears',
                'This is most of aftercare. Nothing else matters as '
                'much.'),
            PpCard('Two calm adults',
                'One to hold, one to comfort. It is a two person job.'),
          ],
        ),
        PpCallout('What matters is sterile equipment, light plain '
            'studs and clean hands for six weeks. The auspicious date, the '
            'gold weight and the ceremony around it are all optional.'),
        // REQUIRED_REVIEW: piercing hygiene and aftercare. Claims to confirm:
        // sterile single use needle or sealed cartridge, cleaning with saline,
        // keeping studs in for the healing period, avoiding heavy earrings on
        // an infant, and that piercing on infected or broken skin should wait.
        // Also confirm the tetanus immunisation point.
        PpCallout(
          'Delay the piercing if your child is unwell, if the ear skin is '
          'broken or infected, or if routine immunisations are not up to date. '
          'Don\'t let anyone pierce with a sewing needle, a thorn, a reused '
          'stud, or a gun barrel that has only been wiped. Keep hair, dupattas '
          'and little fingers away from the studs while they heal.',
          kind: PpCalloutKind.safety,
          title: 'When to wait, and what to refuse',
        ),
        PpCallout(
          'See a doctor if an ear turns red and swollen, feels hot, or oozes '
          'yellow or green. See one too for a fever, or a stud sinking into '
          'the earlobe. An embedded stud needs a doctor to remove it, not a '
          'family member with tweezers. Raised, lumpy scarring (a keloid) '
          'also needs a doctor to look at it early.',
          kind: PpCalloutKind.doctor,
          title: 'If an ear doesn\'t settle',
        ),
        PpCallout(
          'Ear piercing does not improve eyesight, hearing, brain development '
          'or behaviour. It is a cultural choice, made with love. Done '
          'cleanly, there is no medical reason either to do it or to avoid '
          'it.',
          kind: PpCalloutKind.myth,
          title: '"Piercing is good for the eyes"',
        ),
        PpIndiaNote('If an elder offers to do it at home with a gold wire, say '
            'yes to the ceremony and no to the method. A sentence that usually '
            'works: "Let\'s do the puja at home and the piercing at the clinic. '
            'Then we don\'t risk an infection during the festival."'),
        PpVideoSlot(
          title: 'Ear piercing, and the six weeks after',
          subtitle: 'What sterile looks like, and how to clean the '
              'ears at home.',
          minutes: '5 MIN',
          slotId: 'traditions/karnavedha',
        ),
        PpLink('At the ceremony itself: blades, piercing and heat',
            pageId: 'ceremony_day_safety'),
        // [single-source] The fresh-sealed-blade rule lives once, on "On the
        // day: blades, piercing and heat".
        PpLink('The blade rule, once',
            pageId: 'ceremony_day_safety',
            blurb: 'One fresh sealed blade, opened in front of you, and '
                'nothing on the shaved head.'),
      ],
    ),

    // -------------------------------------------------------------------------
    //  First birthday
    // -------------------------------------------------------------------------
    PpPage(
      id: 'first_birthday',
      title: 'The first birthday',
      subtitle: 'The modern milestone, and how to keep it about your child',
      format: 'CEREMONY',
      blocks: [
        PpIntro('The first birthday is the newest ceremony in this section and '
            'often the most expensive. It is also the one where the gap '
            'between what the child enjoys and what the party costs is widest.'),
        PpArticle(
          heading: 'What it is now',
          [
            'Traditionally the first year was marked quietly, sometimes with '
            'the head shaving, sometimes with a temple visit and food given away. '
            'The themed party with a cake and a photographer arrived in the '
            'last twenty years and is now the default in cities.',
            'A one year old doesn\'t know it\'s a birthday. What a one year old '
            'notices is lights, loud music, forty faces and no nap. Keep that '
            'in mind as you plan. It decides whether the photos show a happy '
            'child or an upset one.',
          ],
        ),
        PpWhenLine('At twelve months, or on the nearest weekend, or on the '
            'lunar date (tithi) rather than the calendar date if your family counts it that way. '
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
            PpCard('The head shaving on the same day',
                'Common, and it saves a second gathering.'),
            PpCard('New clothes and a temple, church or gurdwara visit',
                'Quiet, short, and easier on a one year old than a hall.'),
          ],
        ),
        PpSteps(
          heading: 'How to plan it around your child, not the guests',
          [
            PpStep('Pick the time around the nap, then tell people',
                'Late morning or late afternoon. Never the slot that eats into '
                'the nap.'),
            PpStep('Keep it to about ninety minutes',
                'A one year old\'s patience for noise and strangers runs out '
                'long before the buffet does.'),
            PpStep('Have one quiet room to slip away to',
                'A bedroom with the lights low. You will use it.'),
            PpStep('Give a proper meal before the party',
                'Party food is mostly sugar, and mostly not meant for a one '
                'year old.'),
            PpStep('Do the cake early, not at the end',
                'Get the moment done while your child is still fresh.'),
            PpStep('Keep your child with familiar people',
                'A baby passed around for two hours is a crying baby.'),
          ],
        ),
        PpCallout('What matters is a child who is fed, rested and near someone '
            'familiar. The theme, the balloon arch, the return gifts and the '
            'photographer are for the adults. That\'s allowed, as long as you '
            'know who they are for.'),
        // REQUIRED_REVIEW: first birthday food and party safety. Claims to
        // confirm: no added sugar in the first year and cake in a tiny taste
        // at most, choking hazards from grapes, nuts, hard sweets and small
        // toy parts, candle and open flame safety, and hearing protection from
        // sustained loud music for infants.
        PpCallout(
          'Cake is a small taste. Added sugar is still not recommended in the '
          'first year. Keep grapes, nuts, hard sweets and small toy parts off '
          'the floor where your baby crawls. Keep candles, sparklers and hot '
          'food out of reach. And keep your baby away from the speakers, '
          'because long, loud music is too much for a baby\'s ears.',
          kind: PpCalloutKind.safety,
          title: 'Cake, choking and the speakers',
        ),
        PpIndiaNote('If the family expects two hundred guests and your budget '
            'doesn\'t, try what works in most families. Hold a small ceremony '
            'at home in the morning, and an open house in the evening with tea '
            'and sweets. It feels generous and costs a fraction.'),
        PpVideoSlot(
          title: 'A first birthday that suits a one year old',
          subtitle: 'Timing, the cake moment, and the quiet room.',
          minutes: '5 MIN',
          slotId: 'traditions/first_birthday',
        ),
        PpLink('Make an invite or a birthday card',
            surfaceId: 'pp_memories',
            blurb: 'Pick a template, add a photo, share it on WhatsApp.'),
        PpLink('What a ceremony really costs', pageId: 'what_it_costs'),
        PpLink('The head shaving, if you are doing both on the day', pageId: 'mundan'),
      ],
    ),

    // -------------------------------------------------------------------------
    //  Aksharabhyasam
    // -------------------------------------------------------------------------
    PpPage(
      id: 'aksharabhyasam',
      title: 'The first letters (aksharabhyasam)',
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
            'It is a beginning, and beginnings have no standard to meet. A '
            'child who scribbles, refuses or wanders off has still had a full '
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
            PpStep('An adult holds the child\'s finger and traces a letter',
                'Often the first letter of the alphabet, or a short syllable, '
                'traced two or three times.'),
            PpStep('Your child is asked to say it aloud',
                'It may happen, or not. Either is fine.'),
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
                'Your child\'s own, kept afterwards. This is the keepsake.'),
            PpCard('A lap and ten quiet minutes',
                'Ideally a grandparent\'s lap. That is the part children '
                'remember.'),
            PpCard('Sweets, if the family shares them',
                'Anything the house makes. This ceremony has never needed a '
                'caterer.'),
          ],
        ),
        PpCallout('What matters is a loved adult sitting close, showing a '
            'letter, and the moment feeling good. Don\'t turn it into a test, '
            'don\'t correct, and don\'t let anyone ask your child to perform '
            'for the room.'),
        PpCallout(
          'This ceremony is not a signal to start formal reading drills. '
          'Children learn letters at very different ages. Pushing a three '
          'year old into worksheets after aksharabhyasam is the quickest way '
          'to turn a child off them. Play, talk and being read to build '
          'reading far more than tracing does.',
          kind: PpCalloutKind.myth,
          title: '"Now the real studying starts"',
        ),
        PpIndiaNote('If your family is spread out, try a video call. A '
            'grandparent guides from the screen while you hold your child\'s '
            'hand. It works beautifully, and a lot of families already do it.'),
        PpVideoSlot(
          title: 'Aksharabhyasam at home',
          subtitle: 'The rice tray version, in ten minutes.',
          minutes: '4 MIN',
          slotId: 'traditions/aksharabhyasam',
        ),
        PpLink('Play that builds early learning',
            surfaceId: 'pp_activities',
            blurb: 'Age matched play, and what each one is building.'),
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
            'Most commonly, on the seventh day the child is named and the head '
            'is shaved. An animal is sacrificed, and the meat is divided '
            'between the family, relatives and those in need. Some families '
            'also give the weight of the shaved hair in silver to charity.',
            'Practice varies between schools and between families. This page '
            'describes what is commonly done, not what is required. Your '
            'family\'s imam or religious guide is the right person for the '
            'religious questions. This page is the practical side.',
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
                'Never skipped, exactly as for any head shaving.'),
            PpCard('Arrangements for the sacrifice, if you are doing it',
                'Many families now arrange this through a butcher or a '
                'charity, which is entirely accepted.'),
            PpCard('Food for the shared meal',
                'Cooked at home or catered. Neither is more correct.'),
            PpCard('A soft cap for afterwards',
                'A newly shaved scalp needs shade.'),
          ],
        ),
        PpCallout('What matters is the name, the welcome, and something given '
            'to people who need it. If money is tight, the giving can be small '
            'and the meal can be at home. Keeping it modest, or waiting, takes '
            'nothing away from your child.'),
        // REQUIRED_REVIEW: newborn head shaving hygiene, same claim as the
        // mundan page: single use sealed blade, risk of bloodborne infection
        // and tetanus through a nick, and shade for a newly shaved scalp.
        PpCallout(
          'A newborn scalp is thin and nicks easily. One fresh sealed blade, '
          'opened in front of you, and nothing else. Don\'t let anyone put ash, '
          'oil, turmeric or any paste on the shaved head or a nick, and keep '
          'the scalp out of direct sun afterwards. If a nick turns red or your '
          'baby gets a fever, see a doctor.',
          kind: PpCalloutKind.safety,
          title: 'Shaving a seven day old head',
        ),
        PpIndiaNote('If the family is spread across cities, many now do the '
            'naming and shaving at home on the seventh day. The shared meal '
            'comes weeks later, when everyone can travel. That is a common and '
            'accepted split.'),
        PpVideoSlot(
          title: 'Aqiqah, in plain words',
          subtitle: 'What the day involves, and the practical arrangements.',
          minutes: '6 MIN',
          slotId: 'traditions/aqiqah',
        ),
        PpLink('Find a name, with meanings and origins',
            surfaceId: 'pp_names',
            blurb: 'Search by meaning, origin and sound.'),
        PpLink('Tahneek, the first sweet taste', pageId: 'tahneek'),
        PpLink('Make an announcement card', surfaceId: 'pp_memories'),
        // [single-source] The short line above stays word for word; the full
        // newborn-gathering block lives once, on "On the day: blades,
        // piercing and heat".
        PpLink('The full newborn-in-a-crowd rule, once',
            pageId: 'ceremony_day_safety',
            blurb: 'Small group, washed hands, no kisses on the face, and the '
                'fever that means a doctor today.'),
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
            'A date is softened, usually chewed or mashed. A respected elder '
            'rubs a very small amount gently on the roof of the baby\'s mouth '
            'or the gums, then makes a prayer for the child. It is a blessing, '
            'not a feed.',
            'Practice differs on who does it and how, and families follow '
            'their own guidance. What follows is the safety side, which is '
            'where we can help.',
          ],
        ),
        PpWhenLine('Usually within the first day or two of birth, and often '
            'straight after the baby has fed.'),
        PpSteps(
          heading: 'How it is done',
          [
            PpStep('Let the first breastfeed happen first',
                'Nothing should delay or replace the first feeds. The first '
                'milk (colostrum) in those early hours matters more than any custom.'),
            PpStep('The date is softened until it is completely smooth',
                'No lumps, no skin, no piece that could be swallowed whole.'),
            PpStep('Hands are washed thoroughly',
                'This is the most important step on this page.'),
            PpStep('A trace is rubbed on the gums',
                'A trace, not a spoonful. The baby is held upright and awake.'),
            PpStep('The blessing is said, and it is done'),
          ],
        ),
        PpCallout('What matters is a trace, clean hands, and no feed '
            'replaced. Everything else is family practice.'),
        // REQUIRED_REVIEW: this is the highest priority medical review on the
        // page. Claims to confirm: honey must not be substituted for the date
        // before 12 months because of infant botulism risk; anything placed in
        // a newborn's mouth is an infection route, so handwashing matters and
        // an unwell adult should not do it; nothing should be given that could
        // choke; and nothing should delay or replace early breastfeeding.
        PpCallout(
          'Never use honey in place of the date. Honey must not be given to a '
          'baby under one year at all. It can carry spores that a newborn gut '
          'can\'t handle, and infant botulism is serious. Anyone with a cough, '
          'cold, mouth ulcer or fever should not do the tahneek. Wash hands '
          'first, use a trace with no lump in it, and never let it delay a '
          'feed.',
          kind: PpCalloutKind.safety,
          title: 'Honey is the one real danger here',
        ),
        PpCallout(
          'Call a doctor straight away if a newborn becomes floppy or unusually '
          'weak, has a weak cry, feeds poorly, or is constipated along with any '
          'of these. In a young baby, these signs need seeing urgently, '
          'whatever the cause.',
          kind: PpCalloutKind.doctor,
          title: 'When a newborn needs seeing urgently',
        ),
        PpIndiaNote('Some families use a little jaggery, sugar water or herbal drops (ghutti) '
            'instead of a date. Those carry their own problems, and the safety '
            'page covers them. Read it before the day, so nobody has to debate '
            'it in the room.'),
        PpVideoSlot(
          title: 'Tahneek, done safely',
          subtitle: 'The custom, and the three things to check first.',
          minutes: '3 MIN',
          slotId: 'traditions/tahneek',
        ),
        PpLink('Aqiqah, and naming', pageId: 'aqiqah'),
        PpLink('Customs done with love that are not safe',
            pageId: 'newborn_customs'),
        // [single-source] The short line above stays word for word; the full
        // newborn-gathering block lives once, on "On the day: blades,
        // piercing and heat".
        PpLink('The full newborn-in-a-crowd rule, once',
            pageId: 'ceremony_day_safety',
            blurb: 'Small group, washed hands, no kisses on the face, and the '
                'fever that means a doctor today.'),
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
                'Some churches have rules about godparents. Ask early, not '
                'the week before.'),
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
                'There will be some water. A dry layer and a towel in the bag '
                'make all the difference.'),
            PpCard('A candle, if the church asks you to bring one',
                'Many parishes provide it. Check when you fix the date.'),
            PpCard('Lunch, of whatever size you want',
                'At home or at a hall. Neither is more correct, and the '
                'service is the ceremony.'),
          ],
        ),
        PpCallout('What matters is the church, the water, the name, and the '
            'people who promise to look after your child. The gown, the hall '
            'and the cake are family choices with no religious weight at all.'),
        PpCallout(
          'Churches can be cold, and stone floors colder. Bring a warm layer '
          'and a towel, and ask for lukewarm water if your baby is very young. '
          'Dry the head straight away afterwards. Feed your baby before the '
          'service, not during the drive.',
          kind: PpCalloutKind.safety,
          title: 'Keeping your baby comfortable during the service',
        ),
        PpIndiaNote('In much of Kerala, Goa and the north east, the christening '
            'lunch is the bigger event and the service is short. If you want a '
            'smaller day, shorten the lunch rather than the service. Most '
            'families understand that straight away.'),
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
        // [single-source] The short line above stays word for word; the full
        // newborn-gathering block lives once, on "On the day: blades,
        // piercing and heat".
        PpLink('The full newborn-in-a-crowd rule, once',
            pageId: 'ceremony_day_safety',
            blurb: 'Small group, washed hands, no kisses on the face, and the '
                'fever that means a doctor today.'),
      ],
    ),
    PpPage(
      id: 'sikh_naming',
      title: 'The Sikh naming (Naam Karan), and uncut hair',
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
            'The family goes to the Gurdwara when ready, usually in the first '
            'few weeks. Ardas is said, a hukamnama is read, and the family '
            'chooses a name starting with that letter. Kaur is added for a '
            'girl and Singh for a boy. The name is announced to the sangat, '
            'who respond with the jaikara.',
            'It is a warm, short, inexpensive ceremony. Karah prasad is shared, '
            'and often langar follows, served to everyone present, whoever '
            'they are.',
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
                'The most useful preparation there is. You won\'t know the '
                'letter until the day.'),
            PpCard('Ingredients or an offering for karah prasad',
                'Many families give this. The Gurdwara will tell you what is '
                'usual there.'),
            PpCard('Nothing else',
                'This ceremony needs nothing bought at all.'),
          ],
        ),
        PpCallout('What matters is that the family attends, the '
            'hukamnama is taken, and the child is named. There is no cost '
            'attached to any of it, and no version of this ceremony is more '
            'correct for being larger.'),
        PpArticle(
          heading: 'Uncut hair (kesh), and why there is no head shaving',
          [
            'In Sikh practice kesh, uncut hair, is one of the articles of '
            'faith. So there is no head shaving ceremony for a child raised in '
            'that practice, and a head shaving is not part of the tradition.',
            'In daily life, the hair is cared for rather than cut. It is '
            'combed gently with a kangha, often oiled, and tied in a joora on '
            'top of the head. Once a child is old enough, a patka covers it. '
            'Later, usually around eleven, a Dastar Bandi marks the '
            'first turban and is a real celebration in its own right.',
            'If your family is Sikh and relatives from another tradition ask '
            'about a head shaving, the answer is that this family keeps uncut hair. '
            'Keeping uncut hair is one of the family\'s ceremonies in itself.',
          ],
        ),
        PpCallout(
          'Tie a child\'s joora loosely. Hair pulled tight at the same spot, '
          'day after day, can cause soreness and thinning at the hairline. '
          'Comb gently from the ends upward, oil if it helps, and move the '
          'parting now and then.',
          kind: PpCalloutKind.safety,
          title: 'Caring for a small child\'s uncut hair',
        ),
        PpIndiaNote('Gurdwaras will normally do the naming without an '
            'appointment and without a fee. If someone quotes you a price for '
            'a Sikh naming, that isn\'t how it works.'),
        PpVideoSlot(
          title: 'The Sikh naming at the Gurdwara',
          subtitle: 'The hukamnama, the naming, and what to prepare.',
          minutes: '5 MIN',
          slotId: 'traditions/sikh_naming',
        ),
        PpLink('Find a name, by first letter',
            surfaceId: 'pp_names',
            blurb: 'Filter by starting letter, which is exactly what this '
                'ceremony needs.'),
        PpLink('The head shaving (mundan), for families who do it', pageId: 'mundan'),
        // [single-source] The short line above stays word for word; the full
        // newborn-gathering block lives once, on "On the day: blades,
        // piercing and heat".
        PpLink('The full newborn-in-a-crowd rule, once',
            pageId: 'ceremony_day_safety',
            blurb: 'Small group, washed hands, no kisses on the face, and the '
                'fever that means a doctor today.'),
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
            'Jain practice values restraint and giving, so the ceremonies '
            'tend to be modest on purpose. The money often goes to charity '
            'instead of the gathering. That helps to know if relatives from '
            'other traditions expect something larger.',
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
            'when the child receives the sudreh and kusti. This, rather than '
            'the first birthday, is the milestone families save and plan '
            'for.',
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
                'Deciding on the morning causes more ceremony day stress than '
                'anything else.'),
            PpCard('Sweets, and something given away',
                'Giving is central to both, and it is the part nobody regrets '
                'spending on.'),
          ],
        ),
        PpCallout('What matters in both traditions is the name being given '
            'and something being shared with others. Both are relaxed about '
            'size, so hold on to that if anyone tells you otherwise.'),
        // REQUIRED_REVIEW: same newborn gathering precautions as the chatti and
        // namkaran pages.
        PpCallout(
          'These are still newborn gatherings. Keep the group small, keep '
          'anyone unwell away, wash hands before holding your baby, and no '
          'kisses on the face. If incense or smoke fills the room, open a '
          'window and take your baby out. Young lungs don\'t cope well with smoke.',
          kind: PpCalloutKind.safety,
          title: 'For any newborn ceremony at home',
        ),
        PpIndiaNote('If your community is small in your city, ask the local '
            'derasar or agiary rather than searching online. Practice varies a '
            'lot between communities, and the people there can tell you '
            'what is done locally.'),
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
        // [single-source] The short line above stays word for word; the full
        // newborn-gathering block lives once, on "On the day: blades,
        // piercing and heat".
        PpLink('The full newborn-in-a-crowd rule, once',
            pageId: 'ceremony_day_safety',
            blurb: 'Small group, washed hands, no kisses on the face, and the '
                'fever that means a doctor today.'),
      ],
    ),
    // ⚠️ [NEW], a scaffold. "The five-faith area assumes one tradition per
    // household and a temple or church nearby."
    PpPage(
      id: 'interfaith_far_from_home',
      title: 'Interfaith families, and doing this far from home',
      subtitle: 'Two traditions in one house, or no pandit, agiary or gurdwara nearby',
      format: 'ARTICLE',
      
      blocks: [
        // Written 2026-10-02 (parenting gap analysis), filling the scaffold.
        // REQUIRED_REVIEW.
        PpIntro('Many families bring two faiths or traditions into one home, or '
            'live far from the family temple, gurdwara, agiary, mosque or '
            'church. Ceremonies can still be meaningful, and often become more '
            'personal.'),
        PpArticle(heading: 'Two traditions in one house', [
          'Some families hold two small ceremonies. Others blend them, with a '
              'blessing from each side. Talk together first about what matters '
              'most to each of you, then talk to the grandparents.',
        ]),
        PpArticle(heading: 'Far from home', [
          'Many priests now conduct ceremonies over video call, and community '
              'associations abroad often help. A grandparent can lead a short '
              'ritual at home. The heart of most ceremonies is the family\'s '
              'blessing, which travels anywhere.',
        ]),
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
      title: 'What a ceremony really costs',
      subtitle: 'Honest ranges, so you can decide before anyone books anything',
      format: 'CHART-CARD',
      blocks: [
        PpIntro('Everybody wants these numbers and almost nobody shares them. '
            'Here are realistic ranges for each part of a baby ceremony in an '
            'Indian city. You can see where the money goes before a decision '
            'gets made for you.'),
        // REQUIRED_REVIEW: cost figures. These are 2026 metro estimates and
        // need a sanity check before ship. They vary enormously by city, by
        // season and by community, and the copy says so, but a badly wrong
        // number would still read as authoritative.
        PpChartCard(
          title: 'What each piece tends to cost',
          subtitle: 'City ranges. Smaller towns run well below these.',
          rows: [
            ('The priest\'s fee', 'Rs 500 to Rs 2,100'),
            ('Prayer items and flowers', 'Rs 300 to Rs 1,500'),
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
                'Every cost above except the priest grows with it. Cutting '
                'the list by twenty saves more than bargaining over '
                'everything else.'),
            PpCard('The hall',
                'Booking a hall usually brings catering, decor and a longer '
                'event with it. One decision becomes four.'),
            PpCard('Return gifts',
                'A hundred guests at Rs 300 is Rs 30,000 of things nobody '
                'remembers.'),
            PpCard('Two ceremonies instead of one',
                'Head shaving with the first birthday, naming with the cradle. '
                'Combining them is traditional too.'),
            PpCard('Same day decisions',
                'Everything bought on the morning costs more. Decide the list '
                'a week ahead.'),
          ],
        ),
        PpCallout('Please don\'t borrow money for a baby ceremony. No tradition '
            'in this country asks a family to go into debt to welcome a child. '
            'Every one of these ceremonies has a version that costs almost '
            'nothing.'),
        PpIndiaNote('If relatives are chipping in, agree who pays for what '
            'before anything is booked. In Indian families, the most common '
            'ceremony fight is over money someone assumed would come, and '
            'nobody said out loud.'),
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
                'Grandparents, siblings, and the two or three people who have '
                'helped you this month. That is the list.'),
            PpStep('Do it at home, in the morning',
                'Morning ceremonies end. Evening ones stretch, and stretching '
                'is what costs money.'),
            PpStep('Keep the ritual itself to fifteen minutes',
                'The naming, the first spoon, the cradle. That is the '
                'ceremony. The rest is a gathering.'),
            PpStep('Serve one thing well',
                'Chai and good sweets, or one hot dish. You can skip the buffet '
                'altogether.'),
            PpStep('Skip printed invites',
                'A card made on your phone, sent on WhatsApp, is now normal '
                'even for large weddings.'),
            PpStep('Take photographs yourself, and ask one relative to shoot',
                'Give one person that job. You will get better candid pictures '
                'than a stranger takes.'),
            PpStep('Plan the ending',
                'Put the finish time on the invite. Without one, ceremonies '
                'tend to run on and on.'),
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
        PpCallout('A small ceremony is a full ceremony. The ritual is the '
            'same, the blessing is the same, and your child won\'t know the '
            'difference. Only the number of people watching changes.'),
        PpCards(
          heading: 'Small versions that families love',
          hue: 44,
          [
            PpCard('Naming at home, over a video call',
                'Grandparents joining from another city, the name whispered '
                'and announced. Common now and it works.'),
            PpCard('The first rice feeding at the kitchen table',
                'Grandfather, one spoon, three people, twenty photographs.'),
            PpCard('Head shaving at home in the evening',
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
        PpIndiaNote('If you\'re the daughter in law and this isn\'t your call '
            'alone, offer a clear alternative rather than a refusal. "Let\'s do '
            'it at home on Sunday morning, and I\'ll make sure everyone eats '
            'well" lands very differently from "I don\'t want a big function".'),
        PpVideoSlot(
          title: 'A complete ceremony in one hour, at home',
          subtitle: 'A real family doing the small version, start to finish.',
          minutes: '6 MIN',
          slotId: 'traditions/keeping_it_small',
        ),
        PpLink('What to say when family wants it bigger',
            pageId: 'family_pressure'),
        PpLink('What a ceremony really costs', pageId: 'what_it_costs'),
      ],
    ),
    PpPage(
      id: 'family_pressure',
      title: 'What to say when family wants it bigger',
      subtitle: 'The exact words, for the conversations that are hard',
      format: 'SCRIPT BOX',
      blocks: [
        PpIntro('Most ceremony stress comes from one conversation that nobody '
            'wants to start. Here are lines that work. They are written to '
            'keep the relationship close, rather than to win.'),
        PpScript(
          heading: 'When the guest list keeps growing',
          [
            PpScriptLine(
              say: 'We want to keep it to family this time, because the baby '
                  'is still so small. Let\'s have a bigger celebration on the '
                  'first birthday.',
              notThis: 'We are not inviting all those people.',
              why: 'It gives a reason that is about the baby, not about them, '
                  'and it offers a future occasion instead of a closed door.',
            ),
            PpScriptLine(
              say: 'The doctor has said to keep gatherings small until the '
                  'baby\'s vaccinations are done. We are just being careful.',
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
                  'shared decision. Elders almost always choose the ritual over '
                  'the decor.',
            ),
            PpScriptLine(
              say: 'We would rather put that money aside for the baby than '
                  'into a hall for one afternoon.',
              notThis: 'That is a waste of money.',
              why: 'It shows the small version as a thought-through choice, '
                  'which it is, and not as falling short.',
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
              notThis: 'You cannot give the baby that, it is dangerous.',
              why: 'It names the doctor, offers a swap, and keeps the '
                  'grandmother\'s place in the ritual. That place usually '
                  'matters most to the grandmother.',
            ),
            PpScriptLine(
              say: 'We have stopped the kohl because the doctor found lead in '
                  'the ones sold in the market. I know it is not what we grew '
                  'up with.',
              notThis: 'That stuff is poison, why would you put it on a baby.',
              why: 'It blames the product, not the person offering it, and it '
                  'honours the love the custom came from.',
            ),
          ],
        ),
        PpScript(
          heading: 'When the date does not work for you',
          [
            PpScriptLine(
              say: 'That week is too soon for the baby, but the following Sunday '
                  'works for us, and we would love your help organising it.',
              notThis: 'We cannot do that date.',
              why: 'An alternative plus an invitation to help is almost never '
                  'refused. A flat no almost always is.',
            ),
          ],
        ),
        PpCallout('If a conversation is going badly, pause it rather than '
            'push through. "Let me think about it and we\'ll talk tomorrow" is '
            'enough. Most ceremony arguments settle '
            'overnight.'),
        PpIndiaNote('Ask your partner to say the difficult line to their own '
            'parents. It may not feel fair, but it works better than anything '
            'else on this page.'),
        PpLink('How to keep it small', pageId: 'keeping_it_small'),
        PpLink('Customs done with love that are not safe',
            pageId: 'newborn_customs'),
      ],
    ),
    // ⚠️ [NEW], three scaffolds. "If you would rather not do a ceremony at
    // all" is the honest, sensitive one (call 1, the user's call: add it,
    // read it before it ships). The other two are light cards.
    PpPage(
      id: 'skip_it',
      title: 'If you would rather not do a ceremony at all',
      subtitle: 'Yes, that is alright. And how to hold the line kindly',
      format: 'SHORT ARTICLE',
      
      blocks: [
        // Written 2026-10-02 (parenting gap analysis), filling the scaffold.
        // REQUIRED_REVIEW.
        // ⚠️ THE BRIEF ASKS FOR THE USER'S SIGN-OFF ON TONE BEFORE THIS SHIPS.
        PpIntro('Some families choose not to hold a naming, head shaving or other '
            'ceremony, for reasons of faith, money, health, distance or plain '
            'preference. Yes, that is alright. A ceremony that doesn\'t happen '
            'does your baby no harm.'),
        PpArticle([
          'Traditions are meant to bring a family together, not weigh on it. '
              'You can mark the moment in a smaller way: a quiet prayer at home, a '
              'meal with grandparents, a photo and a letter to your baby. Or '
              'nothing at all.',
          'When relatives disagree, it often comes from love and worry. Listening '
              'first, then explaining kindly, usually works better than arguing.',
        ]),
        PpScript(heading: 'Words that hold the line kindly', [
          PpScriptLine(
              say: 'We have decided to keep it very simple this time. We would love '
                  'you to come for lunch and bless the baby.',
              notThis: 'We do not believe in all that.',
              why: 'Inviting them in keeps the relationship warm.'),
          PpScriptLine(
              say: 'Maybe we will do it later, when the baby is a little older.',
              why: 'Leaving a door open often ends the pressure.'),
        ]),
      ],
    ),
    PpPage(
      id: 'someone_elses_ceremony',
      title: 'Going to someone else\'s baby\'s ceremony',
      subtitle: 'What to gift, the gift money, what to wear, whether to bring your own baby',
      format: 'CARDS',
      
      blocks: [
        // Written 2026-10-02 (parenting gap analysis), filling the scaffold.
        // REQUIRED_REVIEW.
        PpIntro('Going to a cousin\'s or friend\'s baby ceremony is lovely, and a '
            'little planning helps when you are taking your own baby.'),
        PpCards([
          PpCard('The gift', 'Clothes a size bigger, a book, a silver item, or '
              'gift money (shagun) in an envelope with an odd amount, like 501 or 1,101.'),
          PpCard('What to wear', 'Comfortable traditional clothes. If you are '
              'feeding, something that opens easily.'),
          PpCard('Your own baby', 'Go at a quiet time, keep away from smoke and '
              'crowds, and leave before your baby gets overtired.'),
          PpCard('Holding the new baby', 'Wash your hands first, and wait to be '
              'offered.'),
        ]),
      ],
    ),
    PpPage(
      id: 'twins_adopted_second',
      title: 'Twins, an adopted baby, or the second child',
      subtitle: 'No rule, and no debt',
      format: 'CARDS',
      
      blocks: [
        // Written 2026-10-02 (parenting gap analysis), filling the scaffold.
        // REQUIRED_REVIEW.
        PpIntro('There is no rule and no debt. Every family fits traditions to '
            'its own life. A ceremony is about welcoming a child, whatever the '
            'way home and whatever the birth order.'),
        PpCards([
          PpCard('Twins', 'Many families hold one ceremony for both, with each baby '
              'named in turn. It halves the cost and the tiredness.'),
          PpCard('An adopted baby', 'Ceremonies can be held at any age. Many '
              'families do a naming or welcome when the child comes home.'),
          PpCard('The second child', 'A smaller ceremony is just as meaningful. '
              'Give the older child a role, like handing over the plate.'),
          PpCard('A late ceremony', 'If health, money or distance delayed it, it '
              'can be done later. Nothing is lost.'),
        ]),
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
  blurb: 'The few that can harm a baby, and what to do instead.',
  hue: 8,
  pages: [
    PpPage(
      id: 'newborn_customs',
      title: 'On a newborn: kohl, honey and the cord',
      subtitle: 'The customs worth stopping, and why',
      format: 'CARDS',
      blocks: [
        PpIntro('Almost everything passed down in Indian homes is harmless, '
            'and a lot of it is good. A short list is not. Here are the ones '
            'worth knowing about, said plainly, with no judgement of anyone '
            'who has been doing them.'),
        // [reformat] "add a labelled picture to the visual ones, because these
        // are 'do this, not that' that a photo settles faster than words."
        // Drawn in code; artwork can replace via `PpIllustration.asset`.
        PpIllustration(
          kind: PpIllustrationKind.newbornCustoms,
          title: 'The four you can see',
          labels: [
            PpIllustrationLabel('Kohl (kajal)', 'Never in the eye. If the family insists on a dot, the sole of the foot or behind the ear, and a fresh stick.'),
            PpIllustrationLabel('The cord', 'Bare and dry. Nothing on it, folded nappy below it, until it falls off on its own.'),
            PpIllustrationLabel('The swaddle', 'Arms snug, hips and knees free to bend out, frog-leg. Never straight-legged and tight.'),
            PpIllustrationLabel('Head shape', 'It rounds itself. No pressing, no binding, no shaping between pillows.'),
          ],
        ),
        PpArticle([
          'Every custom below is done out of love, usually by a grandmother '
          'who did the same for her own children and saw them grow up fine. '
          'She isn\'t being careless. This information wasn\'t around when she '
          'was raising her family. Some of these products are also sold '
          'openly in shops, which makes them look approved.',
          'So this is a page to read, not a page to hand someone as proof. '
          'The words that work in the room are on the family '
          'conversation page.',
        ]),
        // REQUIRED_REVIEW: kajal / surma lead content. Claims to confirm:
        // traditional and market kajal and surma have repeatedly been found to
        // contain lead, lead is toxic to a developing brain with no safe level,
        // and it can also block tear ducts and irritate the eye. Confirm the
        // advice to raise past use with a doctor.
        PpCards(
          heading: 'The eyes: kohl (kajal and surma)',
          hue: 8,
          [
            PpCard('What is done',
                'Kohl is put in or around a baby\'s eyes, often with a dot on '
                'the cheek or forehead. It is meant to protect from the evil eye (nazar), and '
                'to make the eyes look bigger and stronger.'),
            PpCard('Why it is not safe',
                'Traditional and market kohl products have repeatedly been '
                'found to contain lead. Lead is absorbed easily by a baby and '
                'is toxic to a developing brain, and there is no amount of it '
                'that is considered safe.'),
            PpCard('What to do instead',
                'Nothing in or near the eyes. If the custom matters to your '
                'family, put a small dot behind the ear or on the sole of the '
                'foot. That keeps the tradition, well away from the eyes.'),
            PpCard('If you have been using it',
                'Stop, and mention it at the next check-up. Ask the doctor '
                'whether a lead test is worth doing, especially if it has been '
                'used daily for months.'),
          ],
        ),
        // REQUIRED_REVIEW: honey and infant botulism, under 12 months.
        PpCards(
          heading: 'The mouth: honey, herbal drops and gripe water',
          hue: 8,
          [
            PpCard('Honey, in any form, before one year',
                'Honey can carry spores that a baby\'s gut cannot yet handle, '
                'and infant botulism is a serious illness. This includes honey '
                'on a finger, in kheer, and on a soother. After the first '
                'birthday it is fine.'),
            PpCard('Herbal drops (janam ghutti) and other unregulated herbal mixtures',
                'These are unregulated, the contents vary batch to batch, and '
                'some have been found to contain heavy metals or opium '
                'derivatives. A newborn gut does not need any of it.'),
            PpCard('Gripe water',
                'Widely sold and widely given. There is no good evidence it '
                'helps colic. Some versions have contained alcohol or sugar, '
                'and it fills a small stomach that needs '
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
                'Cow dung, ash, oil, turmeric, kohl or a coin is applied to '
                'the stump to help it dry and fall off faster.'),
            PpCard('Why it is not safe',
                'Anything put on the stump can carry infection straight into '
                'the bloodstream. Newborn tetanus (neonatal tetanus) from this '
                'practice is still seen in India. It is one of the most '
                'dangerous customs on this page.'),
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
        // Added 2026-10-02 from the parenting gap analysis (P1, ADD TO OURS:
        // What to Expect's amber teething necklace piece). In Indian homes the
        // same question is the black thread and the taveez, so both are here.
        // REQUIRED_REVIEW: strangulation and choking risk of neck cords and
        // beads in infants.
        PpCards(
          heading: 'Teething necklaces, black threads and amulets',
          hue: 8,
          [
            PpCard('What is done',
                'An amber teething necklace, or a black thread or amulet (taveez) tied '
                'round the neck to soothe teething or ward off the evil eye.'),
            PpCard('Why it is not safe',
                'Anything round a baby\'s neck can tighten and strangle, '
                'especially in sleep, and beads that break off can choke. '
                'There is no evidence amber eases teething at all.'),
            PpCard('What to do instead',
                'If the thread matters to your family, tie it loosely on the '
                'wrist or ankle, check it daily, and take it off for sleep. '
                'For teething, a cold, clean teething ring and gentle gum '
                'rubbing with a clean finger.'),
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
                'Before six months, milk gives a baby all the water needed, '
                'even in Indian summers. Water fills a very small stomach and '
                'pushes out milk. In larger amounts it can dangerously dilute '
                'the salts in the blood.'),
            PpCard('What to do instead',
                'Feed more often in hot weather. Dress your baby in light '
                'cotton, out of direct sun, in the coolest room. From six '
                'months, sips of water with meals are fine and expected.'),
          ],
        ),
        // REQUIRED_REVIEW: swaddling and hip dysplasia; also head shaping.
        PpCards(
          heading: 'The body: tight swaddling and head shaping',
          hue: 8,
          [
            PpCard('Tight swaddling with the legs straightened',
                'Wrapping a baby tightly with the legs pulled straight and '
                'pressed together is linked to hip problems. A baby\'s hip '
                'joint needs to sit bent and open to develop properly.'),
            PpCard('What to do instead',
                'Swaddle the arms if it settles your baby, and leave the legs '
                'loose enough to bend up and out, like a frog. Check that a hand '
                'slides in easily at the chest. Stop swaddling once your baby '
                'starts trying to roll.'),
            PpCard('Shaping the head with pressure or a tight cloth',
                'Pressing or binding a baby\'s head to round it does not work '
                'and can be harmful. Skull shape from lying is common and '
                'usually corrects itself.'),
            PpCard('What to do instead',
                'Plenty of supervised tummy time while your baby is awake, and '
                'switch which end of the cot the head goes. If one side stays '
                'flat, or the head looks lopsided, ask your paediatrician. It '
                'is very treatable when picked up early.'),
          ],
        ),
        PpCallout(
          'One rule covers most of this list. In the first six months, '
          'nothing goes into a baby\'s mouth, eyes, ears, nose or navel except '
          'breast milk, formula, and medicine a doctor has prescribed. Oil for '
          'a massage on the skin is fine. Everything else waits.',
          kind: PpCalloutKind.safety,
          title: 'The rule that covers most of it',
        ),
        PpCallout(
          'If any of these has been done, stay calm and blame nobody. Stop '
          'it, and mention it at the next visit. Some signs mean seeing a '
          'doctor now, not at the next visit. They are a fever under three '
          'months, poor feeding, a baby gone floppy or unusually sleepy, fast '
          'breathing, or a cord area that looks red or smells.',
          kind: PpCalloutKind.doctor,
          title: 'If something on this page has already been done',
        ),
        PpIndiaNote('Most of the old ways are still good. Massage with warm '
            'oil, being carried a lot, cosleeping, the cloth swing, carom seed water for '
            'the mother, ghee in food from six months. This page is a short '
            'list of exceptions. It says nothing about how well your family '
            'raises children.'),
        PpVideoSlot(
          title: 'Kohl, honey and the cord, explained calmly',
          subtitle: 'The five minute version to watch together with a '
              'grandmother.',
          minutes: '5 MIN',
          slotId: 'traditions/newborn_customs',
        ),
        PpLink('Home remedies from the elders, checked one by one',
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
        PpIntro('Ceremony days have their own small risks. Almost all of them '
            'can be prevented with a decision made a week ahead. Here is the '
            'short list, ceremony by ceremony.'),
        // REQUIRED_REVIEW: blade hygiene, as on the mundan page.
        PpCards(
          heading: 'Anything involving a blade',
          hue: 8,
          [
            PpCard('One fresh sealed blade, opened in front of you',
                'A reused or wiped down blade can pass on hepatitis B, '
                'hepatitis C or HIV through a small scalp nick, and scalp '
                'nicks are common at head shavings.'),
            PpCard('Ask before you book, not on the morning',
                'A barber who is used to shaving babies will say yes immediately. '
                'Hesitation is your answer.'),
            PpCard('Nothing on a nick',
                'No ash, no turmeric, no oil, no paste. Clean water, kept dry, '
                'and a doctor if it turns red or swollen, or a fever '
                'starts.'),
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
            PpCard('Postpone if your child is unwell or the skin is broken',
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
                'first, then do the ritual. Every priest in the country has seen '
                'this and will wait.'),
            PpCard('Watch for overheating',
                'Flushed, damp hair, breathing fast, unusually sleepy. Move '
                'your baby somewhere cool, remove a layer, offer a feed. Under '
                'six months, fewer wet nappies than usual means more milk is '
                'needed, not water.'),
            PpCard('Under three months, keep your baby out of the crowd',
                'Not passed around, not kissed on the face, and away from '
                'anyone with a cough or a cold. A fever of 100.4F or 38C in a '
                'baby that young needs a doctor the same day.'),
            PpCard('Fire ritual (havan) smoke, incense and firecrackers',
                'Smoke irritates young lungs, and firecrackers are far too '
                'loud for a baby\'s ears. Keep your baby in another room with '
                'a window open, or well away from the smoke.'),
          ],
        ),
        PpCards(
          heading: 'The everyday things that go wrong',
          hue: 44,
          [
            PpCard('The nap gets skipped',
                'This causes more ceremony day misery than everything else on '
                'this page combined. Plan the time around it.'),
            PpCard('Nobody is watching the toddler',
                'Oil lamps, hot food, coins, small prayer items on a low table. '
                'Give one adult the single job of watching the toddler.'),
            PpCard('Stiff new clothes',
                'Wash the new outfit once first. Metallic thread work and stiff seams scratch, '
                'and a baby who is itchy will cry through the whole ceremony.'),
            PpCard('No quiet room',
                'Decide in advance which room your baby can be taken to. You '
                'will need it at some point.'),
          ],
        ),
        PpCallout(
          'Two decisions prevent most of this. Ask about the blade or the '
          'needle a week before, and fix the time around the nap and the '
          'feed. Everything else on this page follows from those two.',
          kind: PpCalloutKind.safety,
          title: 'Decide it a week early',
        ),
        PpCallout(
          'Go to a doctor the same day for a fever in a baby under three '
          'months, or spreading redness or pus at a cut or piercing. Go the '
          'same day, too, for fast or laboured breathing, a baby gone floppy '
          'or hard to wake, or a burn. Cool a burn under running water for '
          'twenty minutes first. Don\'t put ghee, toothpaste or ice on it.',
          kind: PpCalloutKind.doctor,
          title: 'When to leave the ceremony and go',
        ),
        PpIndiaNote('None of this needs announcing to the room. Ask the barber '
            'about the blade on the phone, tell the priest softly that the baby '
            'needs a feed first, and pick the quiet room yourself. The ceremony '
            'runs as everyone expects, and your baby is fine.'),
        PpLink('The head shaving, in full', pageId: 'mundan'),
        PpLink('Ear piercing (karnavedha), in full', pageId: 'karnavedha'),
        PpLink('What to say, without a fight', pageId: 'family_pressure'),
        // The fever line here is Health's go-now list's; one list, cross-linked.
        PpLink('The signs that mean a doctor now, in full',
            surfaceId: 'pp_page/parenting_health/health_go_now',
            blurb: 'The canonical list, kept in Health.'),
      ],
    ),
    // ⚠️ [NEW], the sensitive one (call 1, the user's call): the mother
    // treated as apart or "not to be touched" during the ceremonies meant
    // to welcome her baby. Written gently, us-not-shame, and read by the
    // user before it ships. A scaffold until then.
    PpPage(
      id: 'mother_kept_apart',
      title: 'When the mother is kept apart',
      subtitle: 'The forty days apart, the prayers and the kitchen, handled with care',
      format: 'ARTICLE',
      
      blocks: [
        // Written 2026-10-02 (parenting gap analysis), filling the scaffold.
        // REQUIRED_REVIEW.
        // ⚠️ THE BRIEF ASKS FOR THE USER'S SIGN-OFF ON TONE BEFORE THIS SHIPS.
        PpIntro('In some families, a new mother is kept apart for a time after '
            'birth. She may not enter the kitchen or the puja room, touch '
            'certain things, or rest with the family. For some mothers this rest '
            'is welcome. For others it feels isolating. Both feelings are valid.'),
        PpArticle(heading: 'What the custom often protects', [
          'Many of these practices began as a way to make sure the mother rested '
              'and was protected from infection and heavy work after birth. That '
              'purpose is a good one, and worth keeping.',
        ]),
        PpArticle(heading: 'When it does not feel right', [
          'If the custom leaves you lonely, unable to bathe or eat well, or '
              'separated from your baby, it is fine to ask for changes. Nothing in '
              'medicine says a mother must be kept away from her baby, the '
              'kitchen or her family.',
          'You can keep the resting and let go of the rest: being looked after, '
              'without being cut off.',
        ]),
        PpScript(heading: 'Words that keep the peace', [
          PpScriptLine(
              say: 'I love that you want me to rest. Can my husband sit with me and '
                  'the baby in the evenings?',
              why: 'Keeps the care, eases the isolation.'),
        ]),
        PpCallout('If feeling apart is leaving you low, tearful or anxious most '
            'days, talk to your doctor. The custom matters less here than how '
            'you are feeling.',
            kind: PpCalloutKind.doctor),
      ],
    ),
  ],
);

// =============================================================================
//  [NEW AREA] The baby's first festivals — on the user's call (call 2)
// -----------------------------------------------------------------------------
//  "First Diwali, Holi, Eid, Christmas, Raksha Bandhan. Genuinely searched,
//  genuinely useful, and squarely this section's mix of warmth and safety."
//  Its own small area rather than a card under the not-safe customs, so
//  festival safety is not undersold. A scaffold until the copy lands; the
//  owed ledger lists it (P11) and the door test holds it there.
// =============================================================================

const PpArea _firstFestivals = PpArea(
  id: 'first_festivals',
  mark: IntentMark.moonMark,
  title: 'The first festivals, done safely',
  blurb: 'Oil lamps and cracker noise, colours on baby skin, fasting while '
      'nursing. The warmth, and the same-day safety.',
  hue: 44,
  pages: [
    PpPage(
      id: 'first_festivals',
      title: 'The baby\'s first festivals, done safely',
      subtitle: 'First Diwali, Holi, Eid, Christmas, Raksha Bandhan',
      format: 'CARDS',
      
      blocks: [
        // Written 2026-10-02 (parenting gap analysis), filling the scaffold.
        // REQUIRED_REVIEW.
        PpIntro('A baby\'s first Diwali, Holi, Eid, Christmas or Raksha Bandhan '
            'is a joy for the whole family. A few small changes keep it safe '
            'and happy for your baby.'),
        PpCards([
          PpCard('Diwali', 'Oil lamps out of reach, a lit lamp never on the floor, and '
              'the baby indoors and far from crackers. Loud crackers can harm small '
              'ears, and smoke is hard on small lungs.'),
          PpCard('Holi', 'Natural colours, gently, away from the face. Keep your '
              'baby indoors when colours and water balloons are flying.'),
          PpCard('Eid and big family meals', 'Lots of hands want a cuddle. Wash '
              'hands, and no sweets or honey before one.'),
          PpCard('Christmas and New Year', 'Small decorations, tinsel and batteries '
              'out of reach.'),
          PpCard('Raksha Bandhan', 'A soft thread on the wrist, loose, and taken '
              'off for sleep.'),
          PpCard('If you are fasting while breastfeeding', 'Eat and drink well in '
              'the hours you can, and break the fast if you feel dizzy.'),
        ]),
        PpLink('Diwali, Holi and kite season, safely',
            surfaceId: 'pp_page/parenting_safety/safety_festivals'),
      ],
    ),
  ],
);
