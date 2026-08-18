// =============================================================================
//  The baby-sleep sound library
// -----------------------------------------------------------------------------
//  ⚠️ THE SPEC FLAGGED A DECISION HERE AND ASKED FOR THE RECOMMENDED DEFAULT TO
//  BE BUILT, LEFT EASY TO CHANGE:
//
//    "build the Sleep Sounds player as a REUSABLE app-wide ParentVeda Audio
//     player component, and surface it here in Sleep, rather than locking it
//     inside the Sleep section only... Also decide whether its library is fresh
//     or extends the existing Garbh Sanskar audio library. Default assumption for
//     this build: a reusable player with its own new baby-sleep library, kept
//     separate from the Garbh Sanskar (pregnancy, baby-connection) library so the
//     two do not blur. Mark the library source as REQUIRED-CONFIRM."
//
//  Both halves of that default are implemented, and both are worth defending:
//
//  **The player is reusable.** It is `RagaAudioStore` — which already exists,
//  already owns the one-player-app-wide invariant, and was written for the
//  pregnancy ragas. Building a second player for baby sleep would have recreated
//  the exact bug that store was built to fix: two players, one pair of speakers,
//  and a pause button that pauses the wrong thing. So Sleep Sounds is a new
//  LIBRARY on the existing PLAYER, which is the strongest form of the spec's
//  recommendation.
//
//  **The library is separate.** Garbh Sanskar audio is pregnancy: ragas chosen to
//  connect a mother to a baby she has not met. This is a baby who will not sleep.
//  Same file format, different job — and merging them would put a bedtime story
//  in a prenatal practice and a garbha-samskara raga in a 2am playlist.
//
//  ⚠️ REQUIRED-CONFIRM, as asked: `kPpSoundsLibrarySource` below names the
//  decision in one place so it is repointable rather than dispersed.
//
//  ⚠️ EVERY TRACK IS A PLACEHOLDER. Titles, categories, lengths and slot ids are
//  real; the files are not. `asset` is what a real file drops into.
//
//  ⚠️ ENGLISH ONLY FOR NOW.
// =============================================================================

/// ⚠️ REQUIRED-CONFIRM. Which library this player draws from.
///
/// Named here rather than implied by the data so repointing it is one edit and
/// one review, not a search. If the answer changes to "extend Garbh Sanskar",
/// this is the line that changes and `kPpSoundCategories` is what gets replaced.
const String kPpSoundsLibrarySource = 'baby_sleep_v1';

/// One category of sounds.
class PpSoundCategory {
  const PpSoundCategory({
    required this.id,
    required this.label,
    required this.blurb,
    required this.tracks,
    this.hue = 268,
  });

  final String id;
  final String label;

  /// What this category is actually for. Not decoration: "white noise" means
  /// nothing to a first-time parent, and "the whooshing sound of the womb, which
  /// is the last thing she heard for nine months" means everything.
  final String blurb;
  final List<PpSoundTrack> tracks;
  final double hue;
}

class PpSoundTrack {
  const PpSoundTrack({
    required this.id,
    required this.title,
    required this.minutes,
    this.note,
    this.asset,
  });

  /// Stable slug. Becomes the slot id a real file is mapped to.
  final String id;

  final String title;

  /// Shown as "8 min". A loop's length is honest information: a 30-second loop
  /// and a 45-minute recording behave very differently at 2am.
  final String minutes;

  /// One line where the track needs explaining.
  final String? note;

  /// ⚠️ NULL UNTIL A REAL FILE EXISTS. A track with no asset renders as a
  /// placeholder row and does not pretend to be playable — the alternative is a
  /// play button that does nothing, which teaches her that taps do nothing.
  final String? asset;

  bool get isLive => asset != null;
  String get slotId => 'sounds/$id';
}

/// The five categories the spec names.
const List<PpSoundCategory> kPpSoundCategories = [
  PpSoundCategory(
    id: 'lori',
    label: 'Lullabies and lori',
    blurb: 'The songs Indian families have always sung babies down with.',
    hue: 268,
    tracks: [
      PpSoundTrack(
          id: 'lori_chanda_mama',
          title: 'Chanda Mama',
          minutes: '6 min',
          note: 'The moon as an uncle. Almost every Indian child hears this one.'),
      PpSoundTrack(
          id: 'lori_so_ja_rajkumari',
          title: 'So Ja Rajkumari',
          minutes: '5 min'),
      PpSoundTrack(
          id: 'lori_nini_baba',
          title: 'Nini Baba Nini',
          minutes: '7 min',
          note: 'Slow, wordless after the first verse, for nights when even '
              'singing feels like effort.'),
      PpSoundTrack(
          id: 'lori_hummed',
          title: 'Just humming, no words',
          minutes: '20 min',
          note: 'For when she settles to your voice but you have run out of it.'),
      PpSoundTrack(
          id: 'lori_tamil',
          title: 'Aaraaro Aariraro',
          minutes: '6 min',
          note: 'A Tamil lullaby, sung the way it is at home.'),
      PpSoundTrack(
          id: 'lori_bengali',
          title: 'Ghum Parani Maashi Pishi',
          minutes: '5 min',
          note: 'Bengali, calling the aunties who bring sleep.'),
    ],
  ),
  PpSoundCategory(
    id: 'white',
    label: 'White noise and womb sounds',
    blurb: 'A steady sound that covers the small noises of a busy house. This is '
        'the one with real evidence behind it for newborns.',
    hue: 206,
    tracks: [
      PpSoundTrack(
          id: 'white_womb',
          title: 'Womb sound',
          minutes: '45 min',
          note: 'The whooshing she heard for nine months. Often the fastest '
              'thing to settle a newborn.'),
      PpSoundTrack(
          id: 'white_heartbeat',
          title: 'Heartbeat, slow',
          minutes: '30 min'),
      PpSoundTrack(id: 'white_plain', title: 'Plain white noise', minutes: '45 min'),
      PpSoundTrack(
          id: 'white_fan',
          title: 'Ceiling fan',
          minutes: '45 min',
          note: 'What most Indian babies already fall asleep to.'),
      PpSoundTrack(
          id: 'white_shush',
          title: 'Shushing',
          minutes: '20 min',
          note: 'Louder than you would expect, on purpose. That is how it works.'),
    ],
  ),
  PpSoundCategory(
    id: 'nature',
    label: 'Nature and calm sounds',
    blurb: 'Slower and less even than white noise. Better for older babies and '
        'toddlers than for newborns.',
    hue: 160,
    tracks: [
      PpSoundTrack(id: 'nat_rain', title: 'Monsoon rain, steady', minutes: '45 min'),
      PpSoundTrack(
          id: 'nat_rain_roof',
          title: 'Rain on a tin roof',
          minutes: '30 min'),
      PpSoundTrack(id: 'nat_river', title: 'River over stones', minutes: '30 min'),
      PpSoundTrack(
          id: 'nat_night',
          title: 'Night crickets',
          minutes: '45 min',
          note: 'Quiet enough to sleep through, and it does not stop suddenly.'),
      PpSoundTrack(id: 'nat_sea', title: 'Slow waves', minutes: '30 min'),
    ],
  ),
  PpSoundCategory(
    id: 'raga',
    label: 'Soft ragas',
    blurb: 'Night ragas, played slow and thin. Chosen for stillness, not for '
        'performance.',
    hue: 42,
    tracks: [
      PpSoundTrack(
          id: 'raga_yaman',
          title: 'Raga Yaman, flute',
          minutes: '20 min',
          note: 'An evening raga. Traditionally played as the light goes.'),
      PpSoundTrack(id: 'raga_bhupali', title: 'Raga Bhupali, sitar', minutes: '20 min'),
      PpSoundTrack(
          id: 'raga_nilambari',
          title: 'Raga Nilambari',
          minutes: '25 min',
          note: 'The raga traditionally associated with sleep.'),
      PpSoundTrack(id: 'raga_tanpura', title: 'Tanpura drone only', minutes: '45 min'),
    ],
  ),
  PpSoundCategory(
    id: 'stories',
    label: 'Bedtime stories',
    blurb: 'Short, slow and deliberately uneventful. For toddlers who want a '
        'story after the lights are off.',
    hue: 344,
    tracks: [
      PpSoundTrack(
          id: 'story_sleepy_elephant',
          title: 'The elephant who could not sleep',
          minutes: '8 min'),
      PpSoundTrack(
          id: 'story_moon_walk',
          title: 'Walking the moon home',
          minutes: '7 min'),
      PpSoundTrack(
          id: 'story_banyan',
          title: 'The old banyan tree',
          minutes: '9 min'),
      PpSoundTrack(
          id: 'story_counting_stars',
          title: 'Counting stars, badly',
          minutes: '6 min',
          note: 'Ends mid-count, on purpose.'),
    ],
  ),
];

/// Every track, flattened.
List<PpSoundTrack> get kPpAllSoundTracks =>
    [for (final c in kPpSoundCategories) ...c.tracks];

PpSoundCategory? ppSoundCategory(String id) {
  for (final c in kPpSoundCategories) {
    if (c.id == id) return c;
  }
  return null;
}
