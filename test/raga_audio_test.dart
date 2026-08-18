// =============================================================================
//  One player for the app — the bug, held as tests
// -----------------------------------------------------------------------------
//  "when I play Garbh Sankar Music there is no option to pause it."
//
//  The pause button existed the whole time. Four `RagaPlayer` widgets each built
//  their own `AudioPlayer`, so pressing pause on the card in front of you paused
//  a player that was not the one making the sound.
//
//  ⚠️ WHAT CAN AND CANNOT BE TESTED HERE. `audioplayers` has no implementation
//  under `flutter test`, so nothing below plays audio. What it does assert is the
//  part that was actually broken: that "is this playing?" and "whose sound is
//  this?" are answered by ONE object rather than by each widget separately. That
//  is where the bug lived — not in the plugin.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/services/raga_audio_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => RagaAudioStore.instance.resetForTest());

  group('there is exactly one of it', () {
    test('the store is a singleton, so two call sites share one answer', () {
      // The heart of the fix. Two widgets holding two `AudioPlayer`s is what made
      // it possible for the UI to disagree with the speakers.
      expect(RagaAudioStore.instance, same(RagaAudioStore.instance));
    });

    test('nothing is playing and nothing is owned on a fresh start', () {
      expect(RagaAudioStore.instance.isPlaying, isFalse);
      expect(RagaAudioStore.instance.asset, isNull);
    });
  });

  group('ownership is what the icon reads', () {
    // ⚠️ THE ASSERTION THAT ENCODES THE BUG. Before, each widget's icon read its
    // own `_isPlaying`, so two cards could both show a pause icon while only one
    // was audible. Now an icon is a function of (playing AND mine).
    test('a card that does not own the asset never reads as playing', () {
      final s = RagaAudioStore.instance;
      expect(s.isPlayingAsset('audio/raga_drone.wav'), isFalse);
      expect(s.owns('audio/raga_drone.wav'), isFalse);
    });

    test('and it shows its own zero position, not somebody else\'s progress', () {
      // The same confusion in a smaller form: a card inheriting another card's
      // 00:47 would be showing progress through audio it is not playing.
      final s = RagaAudioStore.instance;
      expect(s.positionFor('audio/raga_drone.wav'), Duration.zero);
      expect(s.durationFor('audio/raga_drone.wav'), const Duration(seconds: 12));
    });

    test('seeking an asset this store does not own is a no-op', () {
      final s = RagaAudioStore.instance;
      s.seek('audio/raga_drone.wav', const Duration(seconds: 5));
      expect(s.positionFor('audio/raga_drone.wav'), Duration.zero,
          reason: 'a card must not be able to scrub audio it does not own');
    });
  });

  group('stopping is safe from anywhere', () {
    // Called from `dispose`, which runs on every screen exit whether or not
    // anything was playing. A stop that threw when idle would crash on the way
    // out of a screen — the worst possible place for it.
    test('stop with nothing playing does nothing and does not throw', () async {
      await RagaAudioStore.instance.stop();
      expect(RagaAudioStore.instance.isPlaying, isFalse);
    });

    test('stop twice in a row is still fine', () async {
      await RagaAudioStore.instance.stop();
      await RagaAudioStore.instance.stop();
      expect(RagaAudioStore.instance.asset, isNull);
    });
  });

  group('it is a ChangeNotifier, which is the visible half of the fix', () {
    // The OTHER card's icon has to flip back to a play triangle when this one
    // starts. That only happens if cards subscribe rather than read.
    test('listeners can attach and detach', () {
      var calls = 0;
      void bump() => calls++;
      RagaAudioStore.instance.addListener(bump);
      RagaAudioStore.instance.removeListener(bump);
      expect(calls, 0);
    });
  });
}
