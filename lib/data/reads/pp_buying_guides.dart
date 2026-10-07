// =============================================================================
//  Parenting · buying guides: how to choose, never "the best ten" (2026-10-07)
// -----------------------------------------------------------------------------
//  Gap analysis P3 (What to buy): "Both apps publish 'best X' lists, which we
//  will not copy. But parents need help choosing a car seat, a cot, a carrier
//  and a first pair of shoes. Short guides that say what matters and what to
//  skip, inside What to buy, with no brand ranking." Outcome: "She buys less
//  and buys safer."
//
//  Authored as PvRead (CLAUDE.md, "one reader"): each opens in PvReaderScreen
//  like every other read. No brands, no prices, no "top picks". Each guide:
//  what matters, what to skip, an India note, and one safety line.
//  REQUIRED_REVIEW (paediatrician / child-safety): every figure below.
// =============================================================================

import '../../localization/app_language.dart';
import '../../models/pv_read.dart';

LocalizedText _s(String s) => LocalizedText(en: s, hi: s);
const LocalizedText _desk = LocalizedText(en: 'ParentVeda editorial', hi: 'ParentVeda editorial');
const LocalizedText _kicker = LocalizedText(en: 'How to choose', hi: 'How to choose');

class _Guide {
  const _Guide({
    required this.id,
    required this.title,
    required this.teaser,
    required this.short,
    required this.hue,
    required this.matters,
    required this.skip,
    this.india,
    required this.safety,
  });
  final String id;
  final String title;
  final String teaser;
  final String short;
  final double hue;
  final List<String> matters;
  final List<String> skip;
  final String? india;
  final String safety;
}

const List<_Guide> _kGuides = [
  _Guide(
    id: 'car_seat',
    title: 'Choosing a car seat',
    teaser: 'What keeps a baby safe in a car, and what is only extra.',
    short: 'Rear-facing, fitted tightly, approved, and never second-hand with an unknown past.',
    hue: 206,
    matters: [
      'Rear-facing for as long as the seat allows, at least until about two years. It protects the head and neck best.',
      'A safety approval label on the seat, such as ECE R44/04 or R129 (i-Size).',
      'It fits your car. Try it before you buy: fitted with ISOFIX or the seat belt, it should move less than an inch at the belt path.',
      'A five-point harness that sits at or just below the shoulders when rear-facing.',
      'Easy to fit every time. The safest seat is the one you fit correctly on a busy morning.',
    ],
    skip: [
      'Extra cushions, head huggers or strap covers that did not come with the seat.',
      'A second-hand seat when you do not know if it has been in a crash, or if it is past its expiry date.',
      'Paying more for features you will not use, like a seat that swivels when your car is small.',
    ],
    india: 'Holding a baby in your lap is not safe in a car, even for a short ride. Never fit a rear-facing seat in a front seat with an airbag.',
    safety: 'Read the seat\'s manual and your car\'s manual together, and fit it before the baby comes home.',
  ),
  _Guide(
    id: 'cot',
    title: 'Choosing a cot and mattress',
    teaser: 'A safe place to sleep is simple, and simple is cheaper.',
    short: 'Firm, flat and snug, with nothing else inside.',
    hue: 268,
    matters: [
      'A firm, flat mattress that fits the cot snugly, with a gap of no more than two fingers between mattress and side.',
      'Bars no more than about 6 cm apart, so a head cannot pass through.',
      'Sturdy, with no loose screws, no peeling paint and no cut-outs a head or limb could catch in.',
      'A base you can lower as your baby starts to pull up.',
    ],
    skip: [
      'Bumpers, pillows, quilts and soft toys in the cot. They raise the risk of suffocation.',
      'Sleep positioners, wedges and sloping sleepers.',
      'An old mattress that sags or has a dip in it.',
    ],
    india: 'A jhula or cradle needs the same rules: flat, firm, baby on the back, nothing soft around the face.',
    safety: 'Every sleep, put your baby on the back, on a firm flat surface, with nothing else in the cot.',
  ),
  _Guide(
    id: 'pram',
    title: 'Choosing a pram or stroller',
    teaser: 'Think about where you will push it before you think about the look.',
    short: 'Lie-flat for a young baby, a good harness and brakes, and a fold that fits your life.',
    hue: 160,
    matters: [
      'Lie-flat, or nearly, for a baby under about six months.',
      'A five-point harness and brakes that are easy to work with one foot.',
      'Folded size and weight: will it fit your car boot, an auto, your lift or your stairs?',
      'Wheels that cope with the roads you have. Bigger wheels and some suspension help on broken pavements.',
      'A canopy that blocks the sun well.',
    ],
    skip: [
      'A full travel system if you will rarely use the car seat part.',
      'Cup holders and gadgets you could add later.',
      'Using the pram as the place for long sleeps. Move your baby to a flat cot when you can.',
    ],
    india: 'If you mostly carry your baby or travel by auto, a light, simple stroller or a carrier may serve you better than a large pram.',
    safety: 'Always use the harness and the brakes, and never hang heavy bags on the handle.',
  ),
  _Guide(
    id: 'carrier',
    title: 'Choosing a baby carrier',
    teaser: 'Close and comfortable for both of you, with the airway always clear.',
    short: 'Tight, upright, face visible, chin off the chest, and hips in an M shape.',
    hue: 344,
    matters: [
      'TICKS: tight, in view at all times, close enough to kiss, keep the chin off the chest, supported back.',
      'A wide seat, so the knees sit higher than the bottom in an M shape. It is kinder to the hips.',
      'It fits both adults who will use it, and adjusts easily.',
      'Breathable fabric. A carrier gets warm quickly in Indian summers.',
    ],
    skip: [
      'Narrow carriers where the legs dangle straight down from the crotch.',
      'Pouch slings that curl a young baby chin to chest.',
    ],
    india: 'A dupatta or saree sling is a long tradition. If you use one, the same rules apply: upright, face visible, chin off the chest.',
    safety: 'Check often that you can see your baby\'s face and that breathing is easy. Take extra care when bending.',
  ),
  _Guide(
    id: 'high_chair',
    title: 'Choosing a high chair',
    teaser: 'Feet supported, sitting upright, and easy to clean.',
    short: 'Stable, with a harness and a footrest, for when your baby sits up well.',
    hue: 96,
    matters: [
      'A wide, stable base that does not tip when your child leans or pushes.',
      'A harness, ideally five-point.',
      'A footrest. Feet that are supported help a child sit up and eat well.',
      'Easy to clean, with a tray that comes off.',
      'For a baby who sits up well with good head control, usually around six months.',
    ],
    skip: [
      'Chairs with lots of toys attached. Meals go better with fewer distractions.',
      'A high chair if your family eats sitting on the floor. A lap or a low, stable seat works too.',
    ],
    india: 'Many families eat together on the floor. Your child can join you sitting upright, with you close by.',
    safety: 'Always use the harness, never leave your child alone in the chair, and keep it away from tables they could push off.',
  ),
  _Guide(
    id: 'first_shoes',
    title: 'Choosing first shoes',
    teaser: 'Bare feet are best for learning to walk. Shoes are for outdoors.',
    short: 'Barefoot indoors; for outside, soft, flexible and roomy.',
    hue: 28,
    matters: [
      'Barefoot at home while your child learns to walk. It helps balance and builds foot muscles.',
      'Shoes only once your child walks outdoors.',
      'A soft sole that bends easily at the toes.',
      'About a thumb\'s width of space past the longest toe, and a wide toe area.',
      'A strap or Velcro that holds the heel in place.',
    ],
    skip: [
      'Hard, stiff soles.',
      '"Corrective" shoes, unless your doctor advises them.',
      'Hand-me-down shoes that have taken the shape of another child\'s foot.',
    ],
    india: 'Check size every two or three months. Small feet grow fast, and tight shoes are the most common problem.',
    safety: 'If your child walks only on tiptoe, or limps, mention it to your paediatrician.',
  ),
];

/// The read id for a guide.
String ppBuyingGuideId(String key) => 'pp_buy_$key';

/// Every guide, as a read.
List<PvRead> get kPpBuyingGuides => [for (final g in _kGuides) _read(g)];

PvRead? ppBuyingGuideById(String id) {
  for (final r in kPpBuyingGuides) {
    if (r.id == id) return r;
  }
  return null;
}

PvRead _read(_Guide g) => PvRead(
      id: ppBuyingGuideId(g.id),
      kicker: _kicker,
      title: _s(g.title),
      teaser: _s(g.teaser),
      scaleSetter: _s(g.short),
      shortAnswer: _s(g.short),
      author: _desk,
      authorRole: _s('Written by our team'),
      reviewed: false,
      hue: g.hue,
      sections: [
        PvReadSection(heading: _s('What matters'), bullets: [for (final m in g.matters) _s(m)]),
        PvReadSection(heading: _s('What you can skip'), bullets: [for (final x in g.skip) _s(x)]),
        if (g.india case final ind?) PvReadSection(heading: _s('In an Indian home'), paragraphs: [_s(ind)]),
      ],
      whenToSeeSomeone: PvCallout(tone: PvCalloutTone.note, title: _s('Safety first'), body: _s(g.safety)),
      faqs: const [],
      readNext: [for (final o in _kGuides) if (o.id != g.id) ppBuyingGuideId(o.id)].take(2).toList(),
    );
