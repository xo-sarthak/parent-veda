// =============================================================================
//  Doctor reads — three short pieces for the clinician, as PvReads
// -----------------------------------------------------------------------------
//  The "For you" block on the ParentVeda+ Home (Mobbin audit #8c, 2026-09-21:
//  Airbnb's "Resources for hosting now", Withings' mission cards). One
//  reader for everything (CLAUDE.md), so these open in PvReaderScreen like
//  any other writing. English only. No clinical content — these are about
//  how the platform works for her, so `whenToSeeSomeone` is the calm
//  "questions? write to us" line the reader requires rather than a medical
//  disclaimer.
//
//  Covers: CC0 StockSnap photographs through the Openverse proxy (the one
//  host that answers the phone — read_images.dart), the three candidates
//  from the hero pass that were not used for the band. Credited here; CC0
//  needs no credit and we give it anyway.
// =============================================================================

import '../../localization/app_language.dart';
import '../../models/pv_read.dart';
import 'read_images.dart' show openverseImageUrl;

LocalizedText _s(String s) => LocalizedText(en: s, hi: s);

const LocalizedText _kicker = LocalizedText(en: 'For you', hi: 'For you');
const LocalizedText _desk = LocalizedText(en: 'ParentVeda partnerships', hi: 'ParentVeda partnerships');

PvCallout get _askUs => PvCallout(
      tone: PvCalloutTone.note,
      title: _s('Questions about any of this?'),
      body: _s('Write to partners@parentveda.com. A person answers, usually the same day.'),
    );

/// Cover credits, shown under Profile → About with the hero photographs.
const kDoctorReadCredits = <String, String>{
  'dr_consult_runs': 'Breather · StockSnap (CC0)',
  'dr_prescription': 'Jeffrey Betts · StockSnap (CC0)',
  'dr_qr_where': 'Burst · StockSnap (CC0)',
};

final List<PvRead> kDoctorReads = [
  PvRead(
    id: 'dr_consult_runs',
    kicker: _kicker,
    title: _s('How a consultation runs here'),
    teaser: _s('Fifteen minutes before, ten minutes before, the call, and what happens after.'),
    scaleSetter: _s('Nothing to set up. A parent books inside your hours, you both get a reminder, '
        'and Join opens ten minutes before. The whole thing happens in ParentVeda+.'),
    author: _desk,
    authorRole: _kicker,
    hue: 206,
    imageUrl: openverseImageUrl('e9a4eb0b-1415-40eb-a5c5-73ef7ab8fcee'),
    sections: [
      PvReadSection(
        heading: _s('Before'),
        bullets: [
          _s('A parent books a slot inside the hours you set. You see it on Home and in Appointments within a minute or two.'),
          _s('An hour before, both of you get a reminder. She gets a second one at ten minutes.'),
          _s('Join opens ten minutes before the time. You enter a green room first — camera check, her name, the time — and go in when you are ready.'),
        ],
      ),
      PvReadSection(
        heading: _s('During'),
        paragraphs: [
          _s('The call is a plain video call inside the app: no links, no third-party app, nothing for her to install. '
              'If she has not joined ten minutes after the start, you may mark it a no-show from the card; you are paid for the slot you held.'),
        ],
      ),
      PvReadSection(
        heading: _s('After'),
        bullets: [
          _s('Write the prescription from the card — medicines, doses, durations, your advice. It lands in her app the moment you save, and stays there.'),
          _s('The consultation appears on your Earnings tab that day, with the fee, your share and the date it will be paid.'),
        ],
      ),
      PvReadSection(
        heading: _s('If you cannot make it'),
        paragraphs: [
          _s('Cancel from the card. She gets her credit back at once and can book any other time. Cancelling is always free for her when it is you who cannot come.'),
        ],
      ),
    ],
    whenToSeeSomeone: _askUs,
    faqs: [
      PvReadFaq(
        question: _s('Can a parent book me at any time of day?'),
        answer: _s('Only inside the hours you set, with the notice you set (two hours by default). Availability → Consultation rules.'),
      ),
      PvReadFaq(
        question: _s('What if she cancels late?'),
        answer: _s('Inside two hours of the slot she keeps her credit but gets one free reschedule. You are not asked to do anything.'),
      ),
    ],
  ),
  PvRead(
    id: 'dr_prescription',
    kicker: _kicker,
    title: _s('A prescription a parent can act on'),
    teaser: _s('What she sees, what she does with it, and the three lines that stop the phone calls.'),
    scaleSetter: _s('Your prescription is the thing she opens at the chemist and again at 2 a.m. '
        'Written for that moment, it saves both of you a follow-up call.'),
    author: _desk,
    authorRole: _kicker,
    hue: 42,
    imageUrl: openverseImageUrl('a720e66f-e815-4374-a1f4-cf1eca1f300b'),
    sections: [
      PvReadSection(
        heading: _s('What she sees'),
        paragraphs: [
          _s('Each medicine as a row — name, dose, how long — and your advice underneath, in her app, under the consultation. '
              'She can show it at the chemist and it is there when she looks again next week.'),
        ],
      ),
      PvReadSection(
        heading: _s('Three lines that help'),
        bullets: [
          _s('When to take it, in her words: "after breakfast and after dinner" rather than "BD".'),
          _s('What to expect: "the first two days may feel worse before better".'),
          _s('When to call: the one sign that means come back, and the one that means the emergency room.'),
        ],
      ),
      PvReadSection(
        heading: _s('What the app does for you'),
        bullets: [
          _s('It prefills a prescription you have already written for this booking, so you never send a duplicate by mistake.'),
          _s('A consultation without a prescription is listed under Past as still needing one — the thing every doctor forgets once the call ends.'),
        ],
      ),
    ],
    whenToSeeSomeone: _askUs,
    faqs: [
      PvReadFaq(
        question: _s('Can I edit a prescription after saving?'),
        answer: _s('Open the same consultation and write again; the newer one is what she sees. The earlier one stays on record.'),
      ),
    ],
  ),
  PvRead(
    id: 'dr_qr_where',
    kicker: _kicker,
    title: _s('Where your QR earns the most'),
    teaser: _s('One code, three places. Where partners have found it works, and where it does not.'),
    scaleSetter: _s('Your referral kit is one code printed three ways. A parent who scans it is yours on ParentVeda from that day, '
        'whatever she goes on to use.'),
    author: _desk,
    authorRole: _kicker,
    hue: 104,
    imageUrl: openverseImageUrl('9411a2d6-d200-4225-aa93-239518ae7322'),
    sections: [
      PvReadSection(
        heading: _s('The three places'),
        bullets: [
          _s('The poster, at eye level in the waiting area — not the consulting room, where nobody has a free minute.'),
          _s('The WhatsApp message, sent after a visit with the one line you would say anyway: "the app I mentioned".'),
          _s('The link, in your clinic\'s own profile pages and any note you already send patients.'),
        ],
      ),
      PvReadSection(
        heading: _s('What it means for you'),
        paragraphs: [
          _s('Every family who arrives through your code is counted on your Earnings tab under Referrals — how many, which stage they are in, '
              'and what that earns once a rate is agreed. Never who: names are theirs.'),
        ],
      ),
      PvReadSection(
        heading: _s('What does not work'),
        bullets: [
          _s('A code on the prescription pad. She reads the medicines and never sees it.'),
          _s('Asking at the end of a hard visit. Send the message the next morning instead.'),
        ],
      ),
    ],
    whenToSeeSomeone: _askUs,
    faqs: [
      PvReadFaq(
        question: _s('If a parent scans two doctors\' codes?'),
        answer: _s('The first scan counts, permanently. A later code at checkout earns that sale only, never the family.'),
      ),
    ],
  ),
];

PvRead? doctorReadById(String id) {
  for (final r in kDoctorReads) {
    if (r.id == id) return r;
  }
  return null;
}
