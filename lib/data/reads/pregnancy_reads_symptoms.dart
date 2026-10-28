// =============================================================================
//  Symptoms door: the written reads it owns (relevance Batch 6, 2026-10-28)
// -----------------------------------------------------------------------------
//  The Symptoms door's pages are the symptom library and the "Is this
//  normal?" answers, both adapted into reads by `symptom_reads.dart`. This
//  file holds the door's own long reads, which are written, not adapted.
//
//  The first is "Your baby's movements" (PREGNANCY-GAP §4, search ranks 24,
//  26, 34): when movements start and how to learn their pattern. The door
//  had only the warning side ("When the baby moves less", Complications) and
//  one paragraph in a weekly read. It sits on By symptom in a section of its
//  own, banded weeks 16 to 30, so it leads that tab while she is waiting to
//  feel her baby and getting to know the pattern.
//
//  ⚠️ IT NEVER TELLS HER TO COUNT BEFORE CALLING. "When the baby moves less"
//  says: don't wait, don't drink something cold first, don't count for two
//  hours. This read agrees, and where her own doctor has given her a daily
//  count it defers to that without ever making a count a reason to wait.
//
//  ⚠️ NO PHOTOGRAPH, like every page on this door (`symptom_reads.dart`).
// =============================================================================

import '../../localization/app_language.dart';
import '../../models/pv_read.dart';

LocalizedText _en(String s) => LocalizedText(en: s, hi: s);

const double _hue = 26;

final LocalizedText _desk = _en('ParentVeda editorial');
final LocalizedText _kicker = _en('Symptoms');

final List<PvRead> kPregnancyReadsSymptoms = [
  PvRead(
    id: 'preg_sym_read_movements',
    hue: _hue,
    kicker: _kicker,
    title: _en("Your baby's movements, from first flutters to a pattern"),
    teaser: _en(
      "When you'll first feel your baby, what it feels like, and "
      "how to get to know the pattern that's normal for them.",
    ),
    shortAnswer: _en(
      "Most women first feel their baby move between 16 and 24 "
      "weeks, often later in a first pregnancy. From about 24 weeks the "
      "movements settle into a pattern of their own. There is no set number "
      "to reach. What matters is knowing your baby's usual pattern, and "
      "calling your maternity unit straight away if it slows down or "
      "changes.",
    ),
    scaleSetter: _en(
      "Feeling your baby move is, for many women, the moment "
      "pregnancy starts to feel real. It can also bring a new worry: am I "
      "feeling enough? This page goes through what's normal at each stage, "
      "so you know what to expect and when to call.",
    ),
    author: _desk,
    authorRole: _kicker,
    reviewed: false,
    sections: [
      PvReadSection(
        paragraphs: [
          _en(
            "Your baby starts moving long before you can feel it. The early "
            "scans often show little kicks and stretches at 8 to 12 weeks, "
            "but the baby is too small, and too well cushioned, for you to "
            "notice.",
          ),
          _en(
            "Over the next months the movements grow from faint flutters "
            "into kicks, rolls and pushes you can see from the outside. "
            "Learning how your baby moves is one of the most useful things "
            "you can do in the second half of pregnancy.",
          ),
        ],
      ),
      PvReadSection(
        heading: _en('When will I first feel my baby?'),
        paragraphs: [
          _en(
            "Usually between 16 and 24 weeks. In a first pregnancy it's "
            "often around 18 to 20 weeks or a little later, because you "
            "don't yet know what the feeling is. In a second pregnancy many "
            "women notice it from about 16 weeks.",
          ),
          _en(
            "If your placenta is at the front of your womb (your scan report "
            "may say \"anterior placenta\"), it sits between your baby and "
            "your tummy and softens the kicks. You may feel movements later, "
            "and more gently, and that's normal.",
          ),
          _en(
            "Busy days hide the early flutters. Many women first notice them "
            "lying down in the evening, when everything else is quiet.",
          ),
        ],
      ),
      PvReadSection(
        heading: _en('What does it feel like?'),
        paragraphs: [
          _en(
            "At first: a flutter, a bubble, a light tap, or something like "
            "gas or a fish turning over. It's easy to mistake for your own "
            "stomach.",
          ),
          _en(
            "Later: clear kicks and jabs, rolls and stretches, and sometimes "
            "small regular jumps that are your baby's hiccups. Near the end "
            "there is less room, so you may feel more pushing and rolling "
            "and fewer sharp kicks.",
          ),
        ],
      ),
      PvReadSection(
        heading: _en("Getting to know your baby's pattern"),
        paragraphs: [
          _en(
            "From about 24 weeks, most babies have a pattern: times of day "
            "when they're busy and times when they sleep. Sleep spells "
            "usually last 20 to 40 minutes, and rarely more than 90.",
          ),
          _en(
            "To learn the pattern, notice your baby at quiet moments over a "
            "few days, for example after a meal or when you lie down on your "
            "side in the evening. You'll soon know when your baby is usually "
            "busy, and what a normal day feels like.",
          ),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.reassure,
          title: _en("Movements don't slow down near the end"),
          body: _en(
            "It's a common belief that babies move less in the last "
            "weeks. They don't. The movements change in kind as space runs "
            "out, but they should not become fewer, right up to and during "
            "labour.",
          ),
        ),
      ),
      PvReadSection(
        heading: _en('Should I count kicks?'),
        paragraphs: [
          _en(
            "There's no number of kicks that every baby should reach. "
            "What matters is your baby's usual pattern, and any change from "
            "it.",
          ),
          _en(
            "Some doctors in India ask women to keep a daily count, for "
            "example the time it takes to feel ten movements. If yours has, "
            "carry on as they've asked. But never wait to finish a count if "
            "you feel your baby is moving less. Call.",
          ),
        ],
      ),
      PvReadSection(
        heading: _en('What happens when you call'),
        paragraphs: [
          _en("The maternity unit will usually ask you to come in, whatever "
              "the time. There, a midwife or doctor listens to your baby's "
              "heartbeat and often puts a monitor on your tummy for 20 to 30 "
              "minutes (a CTG), which traces the heartbeat as your baby "
              "moves. Some women also have a scan."),
          _en("Most of the time everything is fine, and you go home "
              "reassured the same day. If something needs more care, it has "
              "been found early, which is the whole reason for going. You "
              "will never be wasting anyone's time, and calling again on "
              "another day is just as welcome."),
        ],
      ),
      PvReadSection(
        heading: _en("Things that don't help"),
        bullets: [
          _en(
            "A cold drink, something sweet, or lying down and waiting to "
            "'wake the baby'. If movements are less, call first.",
          ),
          _en(
            "Home heartbeat machines (dopplers). Hearing a heartbeat does "
            "not show that a baby is well, and has made women wait when they "
            "needed to be seen.",
          ),
          _en(
            "Waiting until the next day, or your next check-up, to mention "
            "a change. The check is quick, and the maternity unit would "
            "always rather see you.",
          ),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Call your maternity unit or doctor straight away if'),
      body: _en(
        "Your baby is moving less than usual, the pattern has changed, "
        "or you can't feel the movements you normally would, at any hour. "
        "Don't wait until the next day. If you are past 24 weeks and have "
        "never felt your baby move, call today. For bleeding, fluid leaking "
        "or strong tummy pain, go to hospital now, or call 108.",
      ),
    ),
    faqs: [
      PvReadFaq(
        question: _en(
          "I'm 20 weeks and haven't felt anything yet. Is that "
          "all right?",
        ),
        answer: _en(
          "Usually, yes, especially in a first pregnancy or with a "
          "placenta at the front. Mention it at your next check-up. If you "
          "reach 24 weeks without feeling your baby, call your doctor.",
        ),
      ),
      PvReadFaq(
        question: _en('Does my baby sleep in the womb?'),
        answer: _en(
          "Yes, in spells that are usually 20 to 40 minutes long. A "
          "quiet spell is normal; a day that feels quieter than usual is a "
          "reason to call.",
        ),
      ),
      PvReadFaq(
        question: _en('Which side should I lie on to feel movements?'),
        answer: _en(
          "Lying on your left side is often easiest, and it's a good "
          "way to rest in later pregnancy too.",
        ),
      ),
    ],
    evidence: _en(
      'RCOG Green-top Guideline 57, Reduced fetal movements · NHS, '
      "Your baby's movements · NICE NG201, Antenatal care (2021) · Tommy's "
      'and Kicks Count guidance on learning a baby\'s pattern · Sources '
      'checked October 2026.',
    ),
    readNext: ['preg_cond_read_less_movement'],
  ),
];

/// A read in this file by id, or null.
PvRead? symptomsDoorReadById(String id) {
  for (final r in kPregnancyReadsSymptoms) {
    if (r.id == id) return r;
  }
  return null;
}
