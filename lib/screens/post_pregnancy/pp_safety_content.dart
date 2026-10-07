// =============================================================================
//  Keeping him safe — the parenting safety section
// -----------------------------------------------------------------------------
//  Built 2026-10-02 from the parenting gap analysis
//  (`docs/gap-analysis/parenting/`), which found What to Expect and
//  theAsianparent both carry a full child-safety shelf and ParentVeda had
//  none: babyproofing, poisons, water, car seats, heat, first aid and body
//  safety were the largest single block of P1 gaps (25 of 60).
//
//  ⚠️ WRITTEN FOR AN INDIAN HOME, NOT TRANSLATED FROM AN AMERICAN ONE. The
//  competitor pieces were used as a list of questions to answer, never as
//  text. The hazards are ours: balcony grilles, the gas stove, a cup of hot
//  chai at toddler height, the bucket bath, water tanks, kapoor in the pooja
//  thali, a two-wheeler on the school run, a dog on the street and rabies.
//  Their car-seat piece was about a European standard expiring; ours says
//  what to look for on a seat sold here, and what the law says about a child
//  on a two-wheeler.
//
//  ⚠️ THE VOICE. Calm before careful: every page opens by saying this is
//  common and fixable, then gives the rule, then what to do instead. A
//  frightened parent reads less, so the action comes before the reasoning.
//
//  Five areas, one per door tab. Every page is open to every band: a safety
//  rule a parent meets early is not wasted, and a crawling hazard listed for
//  the wrong month is still a hazard in the house.
// =============================================================================

import '../brackets/hub/hub_intent_art.dart';
import 'pp_age_bands.dart';
import 'pp_content.dart';
import 'pp_section_screen.dart';

final PpSection kPpSafetySection = PpSection(
  id: 'parenting_safety', // MUST match the hub's bracketId.
  title: 'Keeping your child safe',
  subtitle: 'Home, water, road and first aid',
  autoScope: true,
  intro: 'Most accidents with little children happen at home, on an ordinary '
      'day, in a few seconds. The good news: most can be prevented with '
      'small changes you make once. Here they are, room by room, with '
      'what to do if something does happen.',
  bandSet: kPpChildBands,
  areas: [
    // =========================================================================
    //  1. AROUND THE HOUSE
    // =========================================================================
    PpArea(
      id: 'around_house',
      mark: IntentMark.checkMark,
      title: 'Is my home safe for my child?',
      blurb: 'Room by room, from the first crawl to the first climb.',
      hue: 28,
      pages: [
        PpPage(
          id: 'safety_room_by_room',
          title: 'Making your home safe, room by room',
          subtitle: 'Get down to your child\'s eye level, then go room by room',
          format: 'STEP-LIST',
          blocks: [
            PpIntro('Your home doesn\'t need to become a padded box. Look at '
                'it the way your child will: from the floor, with hands that '
                'grab and a mouth that tastes everything. Do this once before '
                'crawling starts, and again at pulling up and climbing.'),
            PpSteps(heading: 'Kitchen', [
              PpStep('Keep your child out while you cook, if you can',
                  'A gate at the kitchen door, or a playpen where you can '
                  'see it, is the easiest fix of all.'),
              PpStep('Use the back burners, handles turned in',
                  'A pot handle sticking out sits right at a toddler\'s '
                  'reaching height.'),
              PpStep('Turn the gas off at the cylinder at night',
                  'Little hands love knobs. Keep the lighter and matches up '
                  'high.'),
              PpStep('Knives, the pressure cooker and the hot pan stay at the '
                  'back of the counter'),
            ]),
            PpSteps(heading: 'Living room and bedroom', [
              PpStep('Cover the sockets you don\'t use',
                  'Plug covers are cheap. Tuck wires and chargers out of '
                  'reach; a dangling wire pulls down whatever is on the '
                  'other end.'),
              PpStep('Soften sharp corners',
                  'Glass tables and the corners of the diwan are at forehead '
                  'height for a new walker. Corner guards help.'),
              PpStep('Anchor anything that can tip',
                  'TV, cupboard, bookshelf. There\'s a whole page on this.'),
              PpStep('Keep small things off the floor',
                  'Coins, hairpins, bindis, beads, buttons, batteries. If it '
                  'fits through a toilet roll tube, it\'s a choking risk.'),
            ]),
            PpSteps(heading: 'Bathroom', [
              PpStep('Empty every bucket and tub after use',
                  'A toddler can drown in a few centimetres of water. This '
                  'is the habit that matters most.'),
              PpStep('Keep the bathroom door shut, and the toilet lid down'),
              PpStep('Cleaners, razors and medicines go up high',
                  'Toilet cleaners and phenyl burn the mouth and throat.'),
            ]),
            PpSteps(heading: 'Windows, balconies and stairs', [
              PpStep('Grilles or window guards on every window within reach',
                  'A mosquito net won\'t hold a child.'),
              PpStep('Nothing to climb near the balcony railing',
                  'No stool, chair, plant pot or cooler near the edge. '
                  'Children climb whatever is there.'),
              PpStep('Stair gates, top and bottom',
                  'From the first crawl until your child goes up and down '
                  'steadily.'),
            ]),
            PpCallout('Crawling and walking change what a child can reach '
                'almost overnight. Walk through the house again with each new '
                'skill.'),
            PpIndiaNote('In a joint family, tell everyone the few rules that '
                'matter most: buckets empty, balcony door shut, hot tea never '
                'on a low table. Once they know the plan, grandparents often '
                'make the best safety team.'),
        // Added 2026-10-02 from the parenting gap analysis (P2/P3).
            PpCards(heading: 'When crawling starts', [
              PpCard('Crawl the house yourself', 'On your hands and knees, you\'ll '
                  'spot wires, coins and sharp corners you never noticed.'),
              PpCard('Clothes for crawling', 'Soft trousers protect little knees '
                  'on hard floors.'),
              PpCard('Keep floors clean', 'Sweep often, and mop with plain water '
                  'or a mild cleaner, not phenyl.'),
              PpCard('Watch rugs and wet floors', 'They cause slips once pulling up begins.'),
            ]),
          ],
        ),
        PpPage(
          id: 'safety_tip_overs',
          title: 'TVs, cupboards and furniture that can fall',
          subtitle: 'Anchor it to the wall once, and you can relax',
          format: 'CARDS',
          blocks: [
            PpIntro('Toddlers climb. They open a drawer and step on it, or '
                'pull up on a TV stand. Heavy furniture tipping onto a small '
                'child is one of the most serious home accidents, and one of '
                'the easiest to prevent.'),
            PpCards([
              PpCard('Strap it to the wall',
                  'Anti-tip straps or L-brackets for the TV, cupboard, '
                  'bookshelf and dressing table. A local carpenter can do the '
                  'whole house in an hour.'),
              PpCard('Mount or push the TV back',
                  'A wall-mounted TV is safest. If it sits on a stand, push '
                  'it to the back and strap it.'),
              PpCard('Heavy things low',
                  'Heavy items go in the bottom drawers and shelves, so the '
                  'piece isn\'t top-heavy.'),
              PpCard('Nothing tempting on top',
                  'Toys, the remote or sweets on top of a cupboard invite '
                  'climbing.'),
              PpCard('Drawer stops',
                  'Child locks keep drawers from turning into a ladder.'),
            ]),
            PpCallout('If anything heavy has fallen on your child, see a '
                'doctor, even if everything seems fine afterwards.',
                kind: PpCalloutKind.doctor),
          ],
        ),
        PpPage(
          id: 'safety_poisons',
          title: 'Medicines, cleaners and other poisons',
          subtitle: 'Up, away, and in their own bottles',
          format: 'ARTICLE',
          blocks: [
            PpIntro('Children explore with their mouths. Many poisonings '
                'happen in the few minutes a medicine strip or a bottle of '
                'cleaner is left out. A few habits close almost every gap.'),
            PpSteps(heading: 'The habits that keep your child safe', [
              PpStep('Store medicines up high, ideally locked',
                  'Yours and the grandparents\' too. Iron tablets, blood '
                  'pressure and diabetes medicines are especially dangerous '
                  'to a small child.'),
              PpStep('Never store anything in a food or drink bottle',
                  'Kerosene, phenyl or acid in a water bottle is a common '
                  'and serious accident.'),
              PpStep('Put things back straight away',
                  'Most poisonings happen while the item is in use.'),
              PpStep('Don\'t call medicine sweets',
                  'A child who believes it will go looking for more when '
                  'you\'re not there.'),
            ]),
            PpCards(heading: 'Easy to forget', [
              PpCard('Kapoor (camphor)',
                  'In the prayer plate or the cupboard. Even a small piece can '
                  'cause fits in a child.'),
              PpCard('Button batteries and magnets',
                  'From remotes, toys and watches. If swallowed, go to a '
                  'hospital now.'),
              PpCard('Mosquito repellent refills', 'Liquid vaporiser bottles.'),
              PpCard('Naphthalene balls', 'In the clothes cupboard.'),
              PpCard('Detergent pods and toilet cleaner',
                  'Bright colours look like sweets.'),
            ]),
            PpSteps(heading: 'If your child has swallowed something', [
              PpStep('Take it out of the mouth and stay calm'),
              PpStep('Don\'t try to make your child vomit',
                  'And don\'t give salt water or milk unless a doctor tells '
                  'you to.'),
              PpStep('Take the bottle or strip with you',
                  'The doctor needs to know exactly what and how much.'),
              PpStep('Call your doctor or go to the nearest hospital',
                  'Go straight away for drowsiness, trouble breathing or a '
                  'fit, or if it was a battery, magnet, kapoor or acid.'),
            ]),
            PpCallout('The National Poisons Information Centre at AIIMS '
                'answers on 1800-116-117. Save it in your phone today. In an '
                'emergency, call 112 or go to the hospital.',
                kind: PpCalloutKind.doctor),
            PpLink('Is this an emergency?',
                surfaceId: 'pp_page/parenting_health/health_go_now',
                blurb: 'The signs that mean go now.'),
          ],
        ),
        PpPage(
          id: 'safety_choking_objects',
          title: 'Small things a child can choke on',
          subtitle: 'The toilet roll test',
          format: 'CARDS',
          blocks: [
            PpIntro('Under four, a child\'s airway is about as wide as a '
                'drinking straw, and everything goes into the mouth. No one '
                'can watch every second, so the trick is keeping the floor '
                'and low shelves clear of small things.'),
            PpCallout('If it fits through an empty toilet roll tube, it\'s '
                'small enough to choke on. Keep it out of reach.'),
            PpCards(heading: 'The usual suspects at home', [
              PpCard('Coins', 'The commonest thing children swallow in India.'),
              PpCard('Balloons',
                  'Uninflated or burst balloon pieces are among the most '
                  'dangerous. Pick them all up after every party.'),
              PpCard('Button batteries and magnets',
                  'Dangerous even when they don\'t choke. Go to hospital.'),
              PpCard('Hairpins, bindis, beads and buttons',
                  'Check the floor after everyone dresses up for a function.'),
              PpCard('Older siblings\' toys',
                  'Lego, marbles, small car wheels, pen caps.'),
              PpCard('Hard foods',
                  'Whole peanuts, chana, whole grapes, popcorn and hard '
                  'sweets until at least four.'),
            ]),
            PpLink('How to cut food so it doesn\'t cause choking',
                surfaceId: 'pp_page/parenting_feeding/safety_choking'),
            PpLink('If your child is choking right now',
                surfaceId: 'pp_page/parenting_health/health_choking_response',
                blurb: 'What to do in the first minute.'),
          ],
        ),
        PpPage(
          id: 'safety_walkers',
          title: 'Are baby walkers safe?',
          subtitle: 'Why doctors say skip it',
          bands: ['infant', 'toddler_1'],
          format: 'ARTICLE',
          blocks: [
            PpIntro('Almost every family is gifted a walker, and babies love '
                'them. Still, the Indian Academy of Pediatrics and doctors '
                'around the world advise against them, and the reason is '
                'easy to see.'),
            PpArticle([
              'A walker lets a baby move far faster than crawling allows, '
                  'long before danger makes sense. That means falls down '
                  'stairs and steps, reaching the stove, hot tea or the '
                  'balcony, and tipping over at a threshold. These injuries '
                  'happen even with an adult in the room.',
              'Walkers also don\'t help babies learn to walk. Some studies '
                  'suggest they may slightly delay it, because the muscles '
                  'and balance aren\'t used the way they are on the '
                  'floor.',
            ]),
            PpCards(heading: 'What to do instead', [
              PpCard('Floor time',
                  'Plenty of time on a clean mat is the best training there '
                  'is.'),
              PpCard('A push-along toy',
                  'Once your baby is pulling up, a sturdy push toy to walk '
                  'behind is fine.'),
              PpCard('Cruising', 'Let your baby walk holding the sofa or your hands.'),
            ]),
            PpWhenLine('If you already have one, it\'s fine to put it away. '
                'Your baby won\'t miss out on anything.'),
          ],
        ),
        PpPage(
          id: 'safety_falls',
          title: 'Falls from beds, stairs and balconies',
          subtitle: 'The commonest injury, and the easiest to plan for',
          format: 'CARDS',
          blocks: [
            PpIntro('Every child falls, and most falls end in a bump and a '
                'cuddle. The ones to plan for are falls from a height: off '
                'the bed, down the stairs, or from a window or balcony. A '
                'little planning removes most of the risk.'),
            PpCards([
              PpCard('The big bed',
                  'Babies roll earlier than you expect, sometimes in the very '
                      'first months. Never leave your baby on a bed or sofa, '
                      'even for a moment. Change nappies on the floor if '
                      'you\'re alone.'),
              PpCard('Pillows are not a wall',
                  'A ring of pillows won\'t stop a rolling baby, and adds a '
                      'suffocation risk. A cot or a mattress on the floor is '
                      'safer.'),
              PpCard('Stairs',
                  'Gates at the top and bottom. Once crawling starts, teach '
                      'coming down backwards, tummy first.'),
              PpCard('Windows and balconies',
                  'Grilles or guards on every window. Keep furniture, coolers '
                      'and pots away from railings, and the balcony door '
                      'locked.'),
              PpCard('Chairs and high chairs',
                  'Always use the straps. Keep chairs away from the kitchen '
                      'counter and windows.'),
              PpCard('The roof terrace',
                  'Never unsupervised, and especially not in kite season.'),
            ]),
            PpLink('After a fall or a bump on the head',
                surfaceId: 'pp_page/parenting_health/health_accidents',
                blurb: 'What to watch for, and when to go now.'),
          ],
        ),
        PpPage(
          id: 'safety_burns_home',
          title: 'Hot tea, the iron and the oil lamp: preventing burns',
          subtitle: 'The burns Indian homes see most',
          format: 'CARDS',
          blocks: [
            PpIntro('Most burns in small children are scalds from hot drinks. '
                'They happen in a second, while someone holds the baby and a '
                'cup of chai together. These habits prevent nearly all of '
                'them.'),
            PpCards([
              PpCard('Never hold your baby and a hot drink together',
                  'Put the cup down out of reach first. Tea can badly scald '
                      'a baby\'s skin even ten minutes after it\'s '
                      'made.'),
              PpCard('No hot cups on low tables',
                  'Or on a tablecloth that small hands can pull.'),
              PpCard('The iron and the hair straightener',
                  'Unplug them and put them up high to cool, cords and all.'),
              PpCard('Oil lamps, incense sticks and mosquito coils',
                  'Place them high, away from curtains and little hands. Never '
                      'leave a lit lamp anywhere a baby can crawl.'),
              PpCard('Bath and geyser water',
                  'Cold first, then hot. Test with your elbow every time.'),
              PpCard('Room heaters and coal stoves',
                  'Keep a guard around them. Never use a coal stove in a '
                      'closed room: it gives off a gas that can kill silently.'),
            ]),
            PpLink('If your child is burned: the first 20 minutes',
                surfaceId: 'pp_page/parenting_health/health_accidents'),
          ],
        ),
        PpPage(
          id: 'safety_toys',
          title: 'Safe toys, and what to check',
          subtitle: 'Small parts, batteries, magnets and strings',
          format: 'STEP-LIST',
          blocks: [
            PpIntro('Toys are how children learn, and most are perfectly safe. '
                'A few quick checks, especially on cheap or hand-me-down toys, '
                'catch the ones that aren\'t.'),
            PpSteps([
              PpStep('Check the age on the box',
                  '"Not for under 3" usually means small parts that can choke.'),
              PpStep('Look for a battery cover held by a screw',
                  'Button batteries must never be reachable.'),
              PpStep('Avoid small, strong magnets',
                  'Two swallowed magnets can pinch the bowel together.'),
              PpStep('No long strings or cords',
                  'Pull toys with cords longer than about 30 cm can wrap around '
                      'a child\'s neck.'),
              PpStep('Check paint and plastic',
                  'Look for a BIS mark on toys sold in India, and avoid cheap '
                      'painted toys that may contain lead.'),
              PpStep('Check old toys now and then',
                  'Loose eyes on soft toys, broken plastic and cracked rattles '
                      'go in the bin.'),
            ]),
            PpCallout('Keep older siblings\' toys, like small building '
                'bricks and marbles, in a separate place out of reach.'),
          ],
        ),
        // Added 2026-10-02 from the parenting gap analysis (P3).
        PpPage(
          id: 'safety_bunk_quake',
          title: 'Bunk beds, earthquakes and emergencies at home',
          subtitle: 'A plan you make once',
          format: 'CARDS',
          blocks: [
            PpIntro('Some risks are rare but worth a few minutes of planning: '
                'bunk beds, and what to do in an earthquake, fire or flood.'),
            PpCards(heading: 'Bunk beds', [
              PpCard('No child under six on the top bunk',
                  'Falls from the top bunk cause serious injuries.'),
              PpCard('Guard rails on both sides of the top', 'And a firm '
                  'ladder.'),
              PpCard('No ropes, belts or scarves tied to the bunk', 'They can '
                  'strangle.'),
            ]),
            PpCards(heading: 'In an earthquake', [
              PpCard('Drop, cover and hold on', 'Under a sturdy table, with '
                  'your baby held close to your chest, away from windows and '
                  'heavy furniture.'),
              PpCard('Don\'t run outside during the shaking', 'Most injuries '
                  'come from falling objects.'),
              PpCard('Afterwards', 'Go out calmly by the stairs, never the '
                  'lift.'),
            ]),
            PpCards(heading: 'Be ready', [
              PpCard('An emergency bag', 'Your child\'s medicines, nappies, '
                  'formula or food, water, a torch, copies of documents and a '
                  'phone charger.'),
              PpCard('Know your way out', 'And a place to meet outside.'),
              PpCard('Numbers saved', '112 for any emergency.'),
            ]),
          ],
        ),
      ],
    ),

    // =========================================================================
    //  2. WATER AND BATHS
    // =========================================================================
    PpArea(
      id: 'water_bath',
      mark: IntentMark.stepsMark,
      title: 'Bath time and water',
      blurb: 'Buckets, tubs, tanks and pools.',
      hue: 206,
      pages: [
        PpPage(
          id: 'safety_bath',
          title: 'Bath time, safely',
          subtitle: 'From the baby tub to the bucket bath',
          format: 'STEP-LIST',
          blocks: [
            PpIntro('Bath time can be the nicest part of the day. It needs '
                'just one rule, kept every time: an adult\'s hand within '
                'reach, the whole time.'),
            PpSteps([
              PpStep('Get everything ready first',
                  'Towel, clothes, soap, mug. Then you never need to step '
                  'away.'),
              PpStep('Check the water with your elbow',
                  'Warm, not hot, around body temperature. Run cold water '
                  'first, then add hot. Geyser water can scald in seconds.'),
              PpStep('Keep the water shallow',
                  'Waist-deep on a seated baby is plenty.'),
              PpStep('Use a non-slip mat',
                  'Wet floors and tubs are slippery for both of you.'),
              PpStep('If the doorbell or phone rings, take your baby with you',
                  'Wrapped in a towel. Never leave a baby in the bath, even '
                  'for a moment, even with an older sibling.'),
              PpStep('Empty the tub or bucket straight after'),
            ]),
            PpCallout('A bath seat or ring is not a safety device. Babies can '
                'slip out of them or tip over. Your hand is the safety device.',
                kind: PpCalloutKind.safety),
            PpIndiaNote('For a bucket-and-mug bath, sit your baby on a low '
                'stool or your lap. Keep the bucket beside you, not in front, '
                'and tip it out when you\'re done.'),
          ],
        ),
        PpPage(
          id: 'safety_drowning',
          title: 'Water safety, and what drowning really looks like',
          subtitle: 'Silent, quick, and preventable',
          format: 'ARTICLE',
          blocks: [
            PpIntro('Drowning doesn\'t look like it does in films. There\'s '
                'usually no splashing and no shouting. A small child slips '
                'under without a sound, often in water a few centimetres '
                'deep. Knowing this is the first step to preventing it.'),
            PpCards(heading: 'The signs to know', [
              PpCard('Head low in the water', 'Mouth at the water line.'),
              PpCard('Upright, not kicking', 'As if climbing an invisible ladder.'),
              PpCard('Silent', 'No breath left to call for help.'),
              PpCard('Glassy eyes', 'Not focusing, or closed.'),
            ]),
            PpSteps(heading: 'Where the risk is at home', [
              PpStep('Buckets and tubs', 'Empty them, every time.'),
              PpStep('Water tanks, sumps and drums',
                  'Keep a fixed, heavy lid on every one.'),
              PpStep('Toilets', 'Lid down, bathroom door shut.'),
              PpStep('Ponds, wells and drains near home',
                  'In villages and new colonies, these are a real danger.'),
            ]),
            PpSteps(heading: 'At a pool or the beach', [
              PpStep('Stay within arm\'s reach', 'Not on your phone, not '
                  'chatting at the edge.'),
              PpStep('Choose one watcher at a time',
                  'On a family outing, agree who is watching, so no one '
                  'assumes someone else is.'),
              PpStep('Armbands and rings are not lifesaving',
                  'They can slip off. Only a proper life jacket counts.'),
            ]),
            PpCallout('If your child has been pulled from water, take your '
                'child to a hospital to be checked, even after coughing and '
                'seeming fine. Problems can show up hours later. If your '
                'child is not breathing, start CPR and call 112.',
                kind: PpCalloutKind.doctor),
            PpLink('CPR for babies and toddlers',
                surfaceId: 'pp_page/parenting_safety/safety_cpr'),
          ],
        ),
      ],
    ),

    // =========================================================================
    //  3. ON THE ROAD AND OUT
    // =========================================================================
    PpArea(
      id: 'road_out',
      mark: IntentMark.compassMark,
      title: 'On the road, and in the heat',
      blurb: 'Car seats, two-wheelers, parked cars and hot days.',
      hue: 160,
      pages: [
        PpPage(
          id: 'safety_car_seat',
          title: 'Car seats, and children on two-wheelers',
          subtitle: 'The safest way to carry your child',
          format: 'ARTICLE',
          blocks: [
            PpIntro('In India most babies travel on a lap, and holding your '
                'baby close feels natural. But in a sudden stop, no adult can '
                'hold on to a child. A car seat is what reliably protects '
                'your child.'),
            PpSteps(heading: 'In a car', [
              PpStep('Use a car seat from the very first ride home'),
              PpStep('Rear-facing for as long as the seat allows',
                  'Usually until at least two years, often longer. It '
                  'protects the head and neck best.'),
              PpStep('Always in the back seat',
                  'Never in front of an airbag.'),
              PpStep('Straps snug, at or below the shoulders',
                  'You shouldn\'t be able to pinch a fold in the strap. '
                  'Take off thick jackets first.'),
            ]),
            PpCards(heading: 'Choosing a seat', [
              PpCard('Check the label',
                  'Look for a seat tested to ECE R129 (i-Size) or ECE R44/04. '
                  'R129 is the newer standard. An R44 seat you already own is '
                  'still fine to use if it\'s in good condition.'),
              PpCard('Check the expiry date',
                  'Most seats are stamped with a use-by date, usually six to '
                  'ten years from manufacture.'),
              PpCard('Be careful second-hand',
                  'Only take a seat from someone you trust, with all its '
                  'parts, that has never been in an accident.'),
            ]),
            PpCallout('On a two-wheeler, Indian law since 2023 requires a '
                'child aged nine months to four years to wear a crash helmet '
                'and a safety harness. The harness ties the child to the '
                'rider, and the speed must stay under 40 km/h. A baby under '
                'nine months should not ride on a two-wheeler at all.',
                kind: PpCalloutKind.safety),
            PpIndiaNote('In an auto or taxi with no seat belts, hold your '
                'child facing you, never squeezed between you and the front '
                'seat. Choose a car with a car seat whenever you can.'),
          ],
        ),
        PpPage(
          id: 'safety_hot_car',
          title: 'Never leave a child in the car',
          subtitle: 'Not for a minute, not with the window down',
          format: 'CARDS',
          blocks: [
            PpIntro('Leaving a sleeping baby in the car while you run into a '
                'shop can feel harmless. But a parked car heats up very fast, '
                'even in the shade, and a child\'s body heats three to five '
                'times faster than an adult\'s.'),
            PpCards([
              PpCard('Take your child with you, always',
                  'Even for one minute. Even if your child is asleep.'),
              PpCard('Leave something you need in the back',
                  'Your phone or bag beside the car seat, so you always look '
                  'in the back before you lock up. Tired parents forget; '
                  'it happens to loving, careful people.'),
              PpCard('Keep the car locked at home',
                  'And the keys out of reach. Children climb into parked '
                  'cars while playing and can\'t get out.'),
              PpCard('If you see a child alone in a car',
                  'Call 112 straight away.'),
            ]),
            PpCallout('If a child has been in a hot car and is drowsy, '
                'floppy, very hot or not sweating, cool the child with water. '
                'Then go to the nearest hospital now.',
                kind: PpCalloutKind.doctor),
          ],
        ),
        PpPage(
          id: 'safety_heat',
          title: 'Keeping your child cool on hot days',
          subtitle: 'Shade, feeds, and light cotton',
          format: 'STEP-LIST',
          blocks: [
            PpIntro('Babies and small children can\'t cool themselves as well '
                'as we can, and Indian summers are long. A few easy habits '
                'carry them through the hottest months comfortably.'),
            PpSteps([
              PpStep('Feed more often',
                  'Under six months, breast milk or formula is enough; no '
                  'water is needed. Older children need water through '
                  'the day.'),
              PpStep('Stay indoors in the hottest hours',
                  'Roughly 11 in the morning to 4 in the afternoon.'),
              PpStep('Light, loose cotton',
                  'One layer is usually enough. A sun hat when outside.'),
              PpStep('Don\'t cover the pram with a cloth or dupatta',
                  'It traps heat inside. Use a proper sunshade instead.'),
              PpStep('Keep the room airy',
                  'A fan or cooler is fine; just don\'t point it straight at your child.'),
            ]),
            PpCallout('Call your doctor or go to hospital if your child is '
                'unusually drowsy or very hot to touch. The same goes for '
                'fewer wet nappies, a dry mouth, vomiting, or a fit.',
                kind: PpCalloutKind.doctor),
          ],
        ),
        PpPage(
          id: 'safety_crowds',
          title: 'Fairs, malls and stations: if your child gets lost',
          subtitle: 'A plan you make before you leave home',
          format: 'STEP-LIST',
          blocks: [
            PpIntro('Losing sight of your child in a crowd is every parent\'s '
                'fear, and it happens in seconds at a wedding, temple, fair or '
                'station. A little preparation makes it far less likely, and '
                'far shorter if it does happen.'),
            PpSteps(heading: 'Before you go', [
              PpStep('Put your phone number on your child',
                  'A wristband, a card in a pocket, or written on an arm '
                      'with a pen. Not your child\'s name on the outside, '
                      'where strangers can read it.'),
              PpStep('Take a photo that morning',
                  'So you can show exactly what your child is wearing.'),
              PpStep('Choose bright clothes',
                  'Easy to spot from far away.'),
            ]),
            PpSteps(heading: 'Teach your child, from about three', [
              PpStep('If you are lost, stand still',
                  'Stay where you are. Mummy and Papa will come back to find '
                      'you.'),
              PpStep('Ask a safe person for help',
                  'A police officer, a shopkeeper at the counter, or a mother '
                      'with children.'),
              PpStep('Know both parents\' names and a phone number',
                  'Practise it as a song or a game.'),
            ]),
            PpCallout('If your child is missing, tell the nearest police '
                'officer, security guard or announcement desk at once, and '
                'call 112. Don\'t wait to search on your own first.',
                kind: PpCalloutKind.safety),
          ],
        ),
        PpPage(
          id: 'safety_road_sense',
          title: 'Roads, parking and the school van',
          subtitle: 'Small children can\'t judge traffic yet',
          format: 'CARDS',
          blocks: [
            PpIntro('Until about eight or nine, children can\'t judge how fast '
                'a vehicle is coming, and they\'re too small for drivers to '
                'see. So the road is always an adult\'s job, hand in '
                'hand.'),
            PpCards([
              PpCard('Hold hands near any road',
                  'Including the lane outside your gate and the parking.'),
              PpCard('Reversing cars',
                  'Before you or anyone reverses out, know exactly where every '
                      'child is. Drivers can\'t see a toddler behind the car.'),
              PpCard('Walk on the side away from traffic',
                  'With you between your child and the road.'),
              PpCard('The school van or auto',
                  'Check the number of children, that there is a door that '
                      'closes, and an adult helper. Overloaded autos are a '
                      'real risk.'),
              PpCard('Cycles and scooters',
                  'A helmet every time, even on the colony road.'),
            ]),
        // Added 2026-10-02 from the parenting gap analysis (P2/P3).
            PpCards(heading: 'Escalators, tricycles and scooters', [
              PpCard('Escalators', 'Hold hands, keep feet in the middle of '
                  'the step away from the edges, and take the lift with a '
                  'pram. Never let a child sit on the steps.'),
              PpCard('Tricycles and scooters', 'A helmet every time, closed '
                  'shoes, and only on a flat, enclosed path away from traffic '
                  'and parking.'),
            ]),
          ],
        ),
        PpPage(
          id: 'safety_festivals',
          title: 'Diwali, Holi and kite season, safely',
          subtitle: 'Keep the joy, skip the hospital visit',
          format: 'CARDS',
          blocks: [
            PpIntro('Festivals are some of the happiest days of childhood. '
                'They also bring a few predictable injuries every year. With '
                'small children, a little planning means everyone enjoys the '
                'day.'),
            PpCards(heading: 'Diwali', [
              PpCard('Small children watch, adults light',
                  'Even sparklers burn at very high temperatures. Keep '
                      'little ones well back.'),
              PpCard('Cotton clothes, not synthetic',
                  'Synthetic fabric catches fire and melts onto skin.'),
              PpCard('A bucket of water and sand nearby',
                  'For used sparklers and duds. Never relight a dud.'),
              PpCard('Protect little ears and lungs',
                  'Loud crackers can damage hearing, and smoke worsens asthma. '
                      'Indoors with windows shut can be the kinder choice.'),
            ]),
            PpCards(heading: 'Holi', [
              PpCard('Use safe, natural colours',
                  'Some cheap colours contain chemicals that burn skin and '
                      'eyes. Oil the skin and hair first.'),
              PpCard('No balloons aimed at the face',
                  'Water balloons cause eye injuries every year.'),
              PpCard('Colour in the eye',
                  'Rinse with clean running water for 15 minutes and see a '
                      'doctor.'),
            ]),
            PpCards(heading: 'Kite season', [
              PpCard('Kite string (manja) cuts',
                  'Glass-coated string cuts deeply. Keep children away, and '
                      'cover the neck on a two-wheeler.'),
              PpCard('Rooftops',
                  'Children chasing kites fall from roofs every year. No '
                      'terrace without an adult right beside them.'),
            ]),
            PpCallout('For a burn, cool it under running water for 20 minutes. '
                'Go to hospital for anything larger than your child\'s palm, '
                'or on the face, hands or private parts.',
                kind: PpCalloutKind.doctor),
          ],
        ),
        // Added 2026-10-02 from the parenting gap analysis (P2/P3).
        PpPage(
          id: 'safety_travel',
          title: 'Travelling with a baby or toddler',
          subtitle: 'Car, train and plane, and what to pack',
          format: 'CARDS',
          blocks: [
            PpIntro('Travel with a little one takes more planning, not more '
                'courage. With the right bag and realistic plans, most trips '
                'go better than you fear.'),
            PpCards(heading: 'The bag', [
              PpCard('Nappies and wipes', 'One more than you think, plus a '
                  'changing mat and bags for dirty ones.'),
              PpCard('Two changes of clothes', 'For your child, and a top for you.'),
              PpCard('Food and water', 'Milk, snacks, a bottle of boiled water.'),
              PpCard('Medicines', 'The fever medicine and syringe, ORS, any '
                  'regular medicines, and the vaccine card.'),
              PpCard('Comfort', 'A favourite blanket or soft toy, and a new '
                  'small toy or book.'),
            ]),
            PpCards(heading: 'On the way', [
              PpCard('By car', 'A car seat every trip, stops every two hours, '
                  'and windows shaded.'),
              PpCard('By train', 'A lower berth if you can, and a sheet to keep '
                  'your child off the floor.'),
              PpCard('By plane', 'Feed or give a drink during take-off and '
                  'landing to ease the ears.'),
              PpCard('Abroad', 'A passport for your child, travel insurance '
                  'that covers your child, and a vaccine check with your doctor.'),
            ]),
            PpWhenLine('Keep the routine loosely: naps and meals at roughly '
                'the usual times make arrival far easier.'),
          ],
        ),
        PpPage(
          id: 'safety_sun',
          title: 'Sun, sunscreen and sunburn',
          subtitle: 'Shade first, then cover, then sunscreen',
          format: 'STEP-LIST',
          blocks: [
            PpIntro('Indian sun is strong for much of the year, and a baby\'s '
                'skin burns easily, whatever its colour. Shade and clothing '
                'do most of the work.'),
            PpSteps([
              PpStep('Under six months, keep your baby out of direct sun',
                  'Shade, a hat and light cotton covering arms and legs.'),
              PpStep('Avoid the strongest sun', 'Roughly 11 in the morning to 4 '
                  'in the afternoon.'),
              PpStep('From six months, sunscreen on uncovered skin',
                  'SPF 30 or more, broad spectrum, mineral (zinc or titanium) '
                      'types for babies. Apply 15 minutes before going out, and '
                      'again every two hours or after water.'),
              PpStep('A wide-brimmed hat and sunglasses', 'For older babies and '
                  'toddlers.'),
            ]),
            PpCallout('For sunburn, cool the skin with damp cloths, give extra '
                'fluids, and stay out of the sun. See a doctor for blisters or '
                'fever, or if your child seems unwell.',
                kind: PpCalloutKind.doctor),
          ],
        ),
        PpPage(
          id: 'safety_motion_sickness',
          title: 'Car sickness and motion sickness',
          subtitle: 'Common from about two years',
          bands: ['toddler_1', 'toddler_2', 'preschool'],
          format: 'STEP-LIST',
          blocks: [
            PpIntro('Motion sickness is uncommon in babies and more common '
                'from about two, especially on winding hill roads. A few '
                'tricks help many children.'),
            PpSteps([
              PpStep('A light meal before, not a big one'),
              PpStep('Looking out of the front window', 'At the horizon, '
                  'not at a phone or book.'),
              PpStep('Fresh air', 'A window open a little.'),
              PpStep('Frequent stops', 'On ghat and hill roads especially.'),
              PpStep('Keep a bag and a change of clothes handy'),
            ]),
            PpCallout('Ask your doctor before giving any motion sickness '
                'medicine; many aren\'t suitable for young children.',
                kind: PpCalloutKind.doctor),
          ],
        ),
      ],
    ),

    // =========================================================================
    //  4. FIRST AID
    // =========================================================================
    PpArea(
      id: 'first_aid',
      mark: IntentMark.cuppedHands,
      title: 'First aid, before help arrives',
      blurb: 'CPR, a cut that won\'t stop, a dog bite.',
      hue: 344,
      pages: [
        PpPage(
          id: 'safety_cpr',
          title: 'CPR for babies and toddlers',
          subtitle: 'Read it once on a calm day',
          format: 'STEP-LIST',
          blocks: [
            PpIntro('We hope you never need this. Reading it once now, '
                'calmly, means your hands will remember more than you think '
                'if the day ever comes. A short in-person class is even '
                'better, and many hospitals run them.'),
            PpCallout('Use this only if your child is not responding and not '
                'breathing normally. Shout for help, and get someone to call '
                '112 or 108 while you start. If you are alone, put your phone '
                'on speaker and call as you begin.',
                kind: PpCalloutKind.doctor),
            PpSteps(heading: 'For a baby under one', [
              PpStep('Lay your baby face up on a firm surface',
                  'Tilt the head back gently, just a little.'),
              PpStep('Give 5 gentle breaths',
                  'Cover the mouth and nose with your mouth. Watch for the '
                  'chest to rise.'),
              PpStep('Press 30 times with two fingers',
                  'In the centre of the chest, just below the nipple line. '
                  'Press down about a third of the chest, around 4 cm, fast: '
                  'about two presses a second.'),
              PpStep('Then 2 breaths, then 30 presses',
                  'Keep going until help arrives or your baby starts breathing.'),
            ]),
            PpSteps(heading: 'For a child over one', [
              PpStep('Same rhythm: 5 breaths first, then 30 presses and 2 '
                  'breaths'),
              PpStep('Use the heel of one hand',
                  'Centre of the chest, pressing about 5 cm, a third of the '
                  'chest.'),
              PpStep('Breaths into the mouth',
                  'Pinch the nose closed as you breathe.'),
            ]),
            PpWhenLine('Don\'t stop to check unless your child moves, coughs '
                'or starts breathing. Then roll your child onto one side and '
                'stay close until help arrives.'),
          ],
        ),
        PpPage(
          id: 'safety_bleeding',
          title: 'A cut that won\'t stop bleeding',
          subtitle: 'Press, hold, and don\'t peek',
          format: 'STEP-LIST',
          blocks: [
            PpIntro('Children bleed a lot from small cuts, especially on the '
                'head and face, and it looks much worse than it is. Firm, '
                'steady pressure stops almost every one.'),
            PpSteps([
              PpStep('Press firmly with a clean cloth',
                  'A handkerchief or a folded towel is fine.'),
              PpStep('Hold for a full 10 minutes without lifting to look',
                  'Peeking lets the clot break. Use a clock.'),
              PpStep('If blood soaks through, add more cloth on top',
                  'Leave the first one in place.'),
              PpStep('Raise the cut above the heart if you can'),
              PpStep('Once it stops, rinse with clean water and cover it'),
            ]),
            PpCallout('Go to a doctor or hospital if it is still bleeding '
                'after 10 minutes of firm pressure, or if blood is spurting. '
                'Go too if the cut is deep, gaping, on the face, very dirty, '
                'or from glass, metal or an animal.',
                kind: PpCalloutKind.doctor),
            PpIndiaNote('Don\'t put turmeric, coffee powder, mud or ash on a '
                'cut. They don\'t stop bleeding and can cause infection.'),
            PpWhenLine('For a dirty or rusty wound, check the vaccination '
                'card for tetanus and ask the doctor.'),
          ],
        ),
        PpPage(
          id: 'safety_dog_bites',
          title: 'If a dog, cat or monkey bites your child',
          subtitle: 'Wash it well, and see a doctor the same day',
          format: 'STEP-LIST',
          blocks: [
            PpIntro('Animal bites and scratches are common in Indian '
                'neighbourhoods, and most heal well. What matters is washing '
                'the wound properly and getting the rabies vaccine in time. '
                'Given promptly, it works very well.'),
            PpSteps([
              PpStep('Wash the wound under running water with soap',
                  'For a full 15 minutes. This alone removes much of the '
                  'risk.'),
              PpStep('Apply an antiseptic',
                  'Such as povidone iodine, if you have it.'),
              PpStep('Don\'t cover it tightly, and don\'t let anyone stitch '
                  'it straight away'),
              PpStep('See a doctor the same day',
                  'Even for a small scratch or lick on broken skin, and even '
                  'from a pet dog. The doctor decides about the anti-rabies '
                  'vaccine and injection.'),
            ]),
            PpCallout('Rabies is almost always fatal once symptoms start, and '
                'almost always preventable before. Go the same day; '
                'government hospitals give the vaccine free.',
                kind: PpCalloutKind.doctor),
            PpIndiaNote('Don\'t put chilli, oil, turmeric or lime on a bite. '
                'Teach children not to touch street dogs, or any dog that is '
                'eating, sleeping or with puppies.'),
          ],
        ),
        PpPage(
          id: 'safety_snake_scorpion',
          title: 'Snake and scorpion bites',
          subtitle: 'Keep your child still and get to a hospital',
          format: 'STEP-LIST',
          blocks: [
            PpIntro('Snake and scorpion bites are a real risk in many parts of '
                'India, especially in the monsoon and in villages, farms and '
                'new colonies. Most bites are treatable, and the hospital '
                'matters far more than anything done at home.'),
            PpSteps(heading: 'If a snake bites your child', [
              PpStep('Keep your child calm and still',
                  'Movement spreads venom faster. Carry your child.'),
              PpStep('Keep the bitten arm or leg still, at heart level',
                  'Like a fracture. Remove rings, anklets and tight clothes.'),
              PpStep('Go to the nearest hospital with anti-venom now',
                  'Government hospitals and primary health centres stock it. '
                      'Call 108 or 112.'),
            ]),
            PpCallout('Don\'t cut the bite, suck it, tie a tight band above '
                'it, put ice or herbs on it, or go to a faith healer first. '
                'These waste the time that saves lives.',
                kind: PpCalloutKind.safety),
            PpSteps(heading: 'If a scorpion stings your child', [
              PpStep('Wash the area and hold something cold on it'),
              PpStep('Go to a hospital the same day',
                  'In small children, some scorpion stings affect the heart. '
                      'Go now for sweating, vomiting, great restlessness or '
                      'fast breathing.'),
            ]),
            PpCallout('Any snake bite, or a scorpion sting in a child, needs a '
                'hospital, even if your child seems fine at first.',
                kind: PpCalloutKind.doctor),
            PpIndiaNote('Shake out shoes and clothes left outside, use a torch '
                'at night, and keep the area around the house clear of '
                'rubbish and long grass.'),
          ],
        ),
        PpPage(
          id: 'safety_first_aid_kit',
          title: 'The first aid kit to keep at home',
          subtitle: 'One box, high up, that everyone knows about',
          format: 'CARDS',
          blocks: [
            PpIntro('You don\'t need much. A small box with a few things, kept '
                'in one place every adult in the house knows, saves panic on '
                'the day you need it.'),
            PpCards([
              PpCard('Thermometer', 'A digital one.'),
              PpCard('Paracetamol syrup or drops',
                  'In the strength your doctor recommends, with its own '
                      'syringe or cup.'),
              PpCard('ORS sachets', 'For diarrhoea and vomiting.'),
              PpCard('Saline nose drops', 'For blocked noses.'),
              PpCard('Clean gauze, bandages and plasters', 'For cuts and grazes.'),
              PpCard('Antiseptic solution', 'Such as povidone iodine.'),
              PpCard('Blunt-tipped scissors and tweezers', 'For splinters and cutting tape.'),
              PpCard('A list of numbers on the lid',
                  'Your paediatrician, the nearest children\'s emergency, '
                      '112, 108, and the AIIMS poison line 1800-116-117.'),
            ]),
            PpCallout('Keep the kit out of children\'s reach, and check expiry '
                'dates every few months.'),
          ],
        ),
        // Added 2026-10-02 from the parenting gap analysis (P2/P3).
        PpPage(
          id: 'safety_minor_injuries',
          title: 'Scrapes, splinters, nosebleeds and stings',
          subtitle: 'The small things, handled calmly',
          format: 'CARDS',
          blocks: [
            PpIntro('Most little injuries of childhood need nothing more than '
                'a calm adult, clean water and a cuddle. Here\'s what to do '
                'for the common ones, and when they need a doctor.'),
            PpCards(heading: 'Scrapes and small cuts', [
              PpCard('Clean it', 'Rinse with clean running water for a few '
                  'minutes to wash out dirt.'),
              PpCard('Cover it', 'A clean plaster or dressing. Change it daily.'),
              PpCard('Watch for infection', 'Spreading redness, swelling, pus '
                  'or fever mean a doctor.'),
            ]),
            PpCards(heading: 'Splinters', [
              PpCard('Wash the area', 'Then use clean tweezers to pull it out '
                  'at the angle it went in.'),
              PpCard('If it\'s deep or glass', 'Leave it and see a doctor.'),
            ]),
            PpCards(heading: 'Nosebleeds', [
              PpCard('Sit up, leaning forward', 'Not back, so the blood isn\'t '
                  'swallowed.'),
              PpCard('Pinch the soft part of the nose', 'Firmly, for 10 minutes '
                  'without letting go.'),
              PpCard('See a doctor if', 'It doesn\'t stop after 20 minutes, '
                  'follows a hard knock, or happens very often.'),
            ]),
            PpCards(heading: 'Split lips and mouth bumps', [
              PpCard('Press with a clean cloth', 'Mouth cuts bleed a lot and '
                  'heal fast.'),
              PpCard('Something cold to suck', 'An ice lolly or cold cloth '
                  'eases swelling.'),
              PpCard('See a dentist or doctor if', 'A tooth is loose, broken or '
                  'pushed in, or a cut is deep or won\'t stop bleeding.'),
            ]),
            PpCards(heading: 'Bee stings and insect bites', [
              PpCard('Scrape the sting out', 'With a fingernail or card.'),
              PpCard('Wash and cool it', 'A cold cloth eases pain and swelling.'),
              PpCard('Spider and other bites', 'Wash with soap and water and '
                  'hold something cold on it. Most spider bites in India are '
                  'harmless; see a doctor if pain spreads, the bite blisters or '
                  'darkens, or your child feels unwell.'),
              PpCard('Go now if', 'There\'s swelling of the face or lips, '
                  'trouble breathing, or faintness: call 112.'),
            ]),
            PpCards(heading: 'Something stuck in the nose or ear', [
              PpCard('Don\'t poke at it', 'You may push it further in.'),
              PpCard('For the nose', 'Block the other nostril and ask your '
                  'child to blow gently. If it doesn\'t come out, see a doctor.'),
              PpCard('A button battery or magnet', 'In the nose or ear is an '
                  'emergency. Go to hospital now.'),
            ]),
            PpCallout('Go to hospital for a wound that is deep, gaping, on the '
                'face, won\'t stop bleeding, or was caused by an animal.',
                kind: PpCalloutKind.doctor),
          ],
        ),
        PpPage(
          id: 'safety_bones',
          title: 'Sprains, broken bones and caring for a cast',
          subtitle: 'How to tell, and what to do',
          format: 'STEP-LIST',
          blocks: [
            PpIntro('Young children\'s bones bend and break differently from '
                'adults\', and a toddler can\'t always tell you where it hurts. '
                'If an arm goes unused, or a leg takes no weight after a fall, '
                'assume it needs checking.'),
            PpSteps(heading: 'Signs of a broken bone', [
              PpStep('Won\'t use the arm, or won\'t walk', 'Even when '
                  'distracted with a favourite toy.'),
              PpStep('Swelling, bruising or a strange shape'),
              PpStep('Pain when you gently touch one spot'),
            ]),
            PpSteps(heading: 'What to do', [
              PpStep('Keep it still', 'Support the arm in a sling made from a '
                  'dupatta, or keep your child off the leg.'),
              PpStep('A cold pack wrapped in cloth', 'For swelling.'),
              PpStep('Go to a doctor or hospital', 'An X-ray tells a sprain '
                  'from a break.'),
              PpStep('Don\'t let anyone massage or pull it', 'Including a '
                  'traditional bonesetter. It can make a break worse.'),
            ]),
            PpSteps(heading: 'Caring for a cast', [
              PpStep('Keep it dry', 'Cover with a plastic bag at bath time.'),
              PpStep('Nothing inside it', 'No sticks or pens for itching.'),
              PpStep('Raise the limb for the first days', 'On a pillow.'),
            ]),
            PpCallout('Go back to the doctor if the fingers or toes are cold, '
                'blue, swollen or numb, the cast smells or gets wet inside, or '
                'the pain gets worse.',
                kind: PpCalloutKind.doctor),
          ],
        ),
      ],
    ),

    // =========================================================================
    //  5. BODY SAFETY
    // =========================================================================
    PpArea(
      id: 'body_safety',
      mark: IntentMark.moodArc,
      title: 'My body is mine',
      blurb: 'Talking about touch, privacy and safe adults, age by age.',
      hue: 268,
      pages: [
        PpPage(
          id: 'safety_body_talk',
          title: 'Talking about the body and safe touch, age by age',
          subtitle: 'Small, ordinary conversations, starting early',
          format: 'ARTICLE',
          blocks: [
            PpIntro('This can feel like a hard topic, but with little '
                'children it\'s easy and gentle. You\'re teaching three things: '
                'my body is mine, I can say no, and I can always tell. '
                'Children who learn this early are safer.'),
            PpSteps(heading: 'Age by age', [
              PpStep('From the start',
                  'Say what you\'re doing before a change or a wipe, even '
                  'before your baby can answer. "I am going to change your '
                  'nappy now." It builds the habit for both of you.'),
              PpStep('Around 2 to 3 years',
                  'Use the real names for body parts. Teach that the parts '
                  'covered by underwear are private. Only Mummy, Papa or a '
                  'doctor with a parent there may look or touch, to keep '
                  'your child clean and healthy.'),
              PpStep('Around 3 to 5 years',
                  'Teach the difference between a surprise, which is happy '
                  'and gets told soon, and a secret about touch, which always '
                  'gets told to you. Together, name three safe adults to '
                  'go to.'),
            ]),
            PpScript(heading: 'Words you can borrow', [
              PpScriptLine(
                  say: 'Your body belongs to you. If anyone touches you in a '
                      'way you do not like, you can say no and come and tell '
                      'me.',
                  why: 'Easy to say, and it gives permission.'),
              PpScriptLine(
                  say: 'You do not have to hug anyone. You can wave or say '
                      'namaste instead.',
                  notThis: 'Go and give Uncle a kiss.',
                  why: 'Forcing affection teaches children that adults decide '
                      'about their bodies.'),
              PpScriptLine(
                  say: 'You will never be in trouble for telling me.',
                  why: 'The line that matters most.'),
            ]),
            PpCallout('If your child tells you something worrying, stay calm, '
                'believe it, and say thank you for telling. Then talk to your '
                'paediatrician or call Childline on 1098. In India, the POCSO '
                'Act protects children, and help is confidential.',
                kind: PpCalloutKind.doctor),
          ],
        ),
        PpPage(
          id: 'safety_screens_online',
          title: 'Phones, videos and staying safe online',
          subtitle: 'Easy settings and clear rules',
          bands: ['toddler_2', 'preschool'],
          format: 'STEP-LIST',
          blocks: [
            PpIntro('Many small children watch videos on a phone, often handed '
                'over by a loving relative. You don\'t have to ban it to keep '
                'your child safe. A few settings and habits make a big difference.'),
            PpSteps([
              PpStep('Use a kids\' app or profile, with autoplay off',
                  'Autoplay leads from a cartoon to things no child should '
                      'see, in a few clicks.'),
              PpStep('Watch in the same room',
                  'Screens in shared spaces, not alone in a bedroom.'),
              PpStep('No video calls or chats with people your child doesn\'t know'),
              PpStep('Turn on parental controls',
                  'On the phone, the TV and YouTube. It takes ten minutes.'),
              PpStep('Teach your child to come and tell you',
                  'Anything scary or strange can be shared, and nobody gets '
                      'in trouble.'),
            ]),
            PpWhenLine('Doctors suggest little or no screen time under two, '
                'apart from video calls with family. From two to five, about '
                'an hour a day of good programmes, ideally watched '
                'together.'),
          ],
        ),
      ],
    ),
  ],
);
