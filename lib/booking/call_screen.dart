// =============================================================================
//  CallScreen — the in-app live video call (LiveKit)
// -----------------------------------------------------------------------------
//  Opens when a parent or an expert taps "Join" on a booking. It asks the
//  livekit-token edge function for a token (the DATABASE decides whether this
//  caller may join — see 0075), connects to the room, turns on camera + mic,
//  and renders the call.
//
//  The room is derived from the booking's slot server-side, so both parties of
//  the same session land in the same room automatically — no link to share.
//
// -----------------------------------------------------------------------------
//  THE SHAPE IS THE ONE EVERY INDIAN PARENT ALREADY KNOWS
// -----------------------------------------------------------------------------
//  This is deliberately WhatsApp's video-call layout, in ParentVeda's colours.
//  That is not imitation for its own sake — it is the single interface almost
//  every user of this app already operates without thinking, and a video call
//  is the worst possible moment to teach someone a new one. A parent joining a
//  consult is often anxious and frequently late; whatever attention they have
//  belongs to the doctor, not to working out which circle ends the call.
//
//  So the conventions are borrowed exactly where they carry muscle memory:
//
//    * the other person full-bleed, you as a small rounded card,
//    * that card DRAGGABLE, snapping to whichever corner is nearest,
//    * tap the card to swap who is large — the standard way to check your own
//      framing without losing the call,
//    * one floating control bar, frosted, sitting over the video,
//    * a red pill to leave, wider than the rest so the finger finds it,
//    * tap anywhere to hide the chrome; it comes back on the next tap and
//      auto-hides again after a few seconds of a settled call.
//
//  And departed from where OUR product differs: the brand is purple rather
//  than green, the waiting state names the person being waited for, and there
//  is an elapsed timer because a consult is a bought, fixed number of minutes
//  and both sides deserve to see them going.
//
//  Chrome NEVER auto-hides before the other person arrives. Hiding controls
//  on someone sitting alone wondering whether the app is working is the one
//  place the convention would actively hurt.
//
// -----------------------------------------------------------------------------
//  AUDIO GOES TO THE SPEAKER, ON PURPOSE
// -----------------------------------------------------------------------------
//  Android routes WebRTC audio to the EARPIECE by default — correct for a phone
//  call held against your face, silent-looking for a video call held at arm's
//  length. That default is why the first working call had no sound: nothing was
//  broken, the audio was coming out of the wrong hole.
//
//  setSpeakerphoneOn(true) at connect fixes it, and the speaker button puts it
//  back on the earpiece for a parent taking the call in a clinic corridor —
//  a real need, not a toggle for its own sake.
// =============================================================================

import 'dart:async';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';

import '../services/remote/supabase_repo.dart';
import '../theme/app_theme.dart';

// ---- palette -----------------------------------------------------------------
// A call screen is dark whatever the rest of the app does — video reads better
// against black, and every camera app on the phone agrees. What makes it OURS
// is the accent: AppTheme.primary, the same purple as every other surface,
// rather than the green a user would read as "this is WhatsApp".
const _bg = Color(0xFF0E0D12);
const _panel = Color(0xFF17151E);
const _accent = AppTheme.primary;
const _danger = Color(0xFFE5484D);
const _live = Color(0xFF3ECF8E);
const _waiting = Color(0xFFE0A02E);

class CallScreen extends StatefulWidget {
  const CallScreen({
    super.key,
    required this.bookingId,
    required this.title,
    this.displayName,
    this.waitingFor,
  });

  final String bookingId;
  final String title;

  /// The name the OTHER side sees over your video. Sent to the token function,
  /// which stamps it into the LiveKit JWT — so it is a LABEL, never a
  /// credential. Identity is the `sub` claim, which the server sets from the
  /// verified session and this cannot influence.
  final String? displayName;

  /// Who this call is waiting for, for the pre-join copy. A name, not a role:
  /// "waiting for the expert" reads like a queue, "waiting for Dr. Neha" reads
  /// like an appointment.
  final String? waitingFor;

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  Room? _room;
  bool _connecting = true;
  String? _error;

  bool _micOn = true;
  bool _camOn = true;
  bool _speakerOn = true;
  bool _frontCamera = true;

  /// Which video is large. Tapping the small card swaps them — the standard
  /// way to check your own framing mid-call without leaving the screen.
  bool _selfIsMain = false;

  /// Chrome visibility, WhatsApp-style: tap to toggle, auto-hide once the call
  /// is settled. Never auto-hides while alone (see the header note).
  bool _chrome = true;
  Timer? _chromeTimer;

  /// Where the self-view card sits. Null until first laid out, then a concrete
  /// offset the drag updates. Snaps to the nearest corner on release, because
  /// a card left mid-edge covers exactly the face you are trying to watch.
  Offset? _selfPos;

  Timer? _tick;
  Duration _elapsed = Duration.zero;

  static const _selfW = 108.0;
  static const _selfH = 152.0;
  static const _margin = 14.0;

  @override
  void initState() {
    super.initState();
    _connect();
  }

  Future<void> _connect() async {
    try {
      // The id is logged because a refusal is ambiguous without it: a booking
      // that only ever existed on this phone and one the server cancelled look
      // identical from here.
      debugPrint('[call] joining bookingId=${widget.bookingId} '
          'as uid=${SupabaseRepo.userId}');
      final res = await SupabaseRepo.invokeEdge('livekit-token', {
        'bookingId': widget.bookingId,
        if (widget.displayName != null) 'name': widget.displayName,
      });
      final url = res?['url'] as String?;
      final token = res?['token'] as String?;
      if (url == null || token == null) {
        setState(() {
          _connecting = false;
          _error = 'Could not join this session. Make sure you are signed in '
              'and try again a few minutes before it starts.';
        });
        return;
      }

      final room = Room();
      await room.connect(url, token);
      await room.localParticipant?.setCameraEnabled(true);
      await room.localParticipant?.setMicrophoneEnabled(true);

      // AFTER connecting: the audio session only exists once there is a track
      // to route, so calling this earlier is a no-op that looks like it worked.
      await _applySpeaker(true);

      room.addListener(_refresh);
      if (!mounted) {
        await room.disconnect();
        await room.dispose();
        return;
      }
      setState(() {
        _room = room;
        _connecting = false;
      });
      _tick = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _elapsed += const Duration(seconds: 1));
      });
    } catch (e) {
      debugPrint('[call] connect failed: $e');
      if (mounted) {
        setState(() {
          _connecting = false;
          _error = 'Something went wrong joining the call.';
        });
      }
    }
  }

  Future<void> _applySpeaker(bool on) async {
    try {
      await Hardware.instance.setSpeakerphoneOn(on);
    } catch (e) {
      // Desktop and some emulators have no routing to switch. A call with the
      // wrong speaker is still a call; a crash is not.
      debugPrint('[call] speakerphone unavailable: $e');
    }
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<void> _leave() async {
    final r = _room;
    _room = null;
    _tick?.cancel();
    _chromeTimer?.cancel();
    r?.removeListener(_refresh);
    await r?.disconnect();
    await r?.dispose();
    if (mounted) Navigator.of(context).maybePop();
  }

  @override
  void dispose() {
    _tick?.cancel();
    _chromeTimer?.cancel();
    final r = _room;
    r?.removeListener(_refresh);
    r?.disconnect();
    r?.dispose();
    super.dispose();
  }

  // ---- chrome ---------------------------------------------------------------

  void _armAutoHide() {
    _chromeTimer?.cancel();
    if (_remote == null) return; // never hide on someone sitting alone
    _chromeTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) setState(() => _chrome = false);
    });
  }

  void _tapBackground() {
    setState(() => _chrome = !_chrome);
    if (_chrome) _armAutoHide();
  }

  // ---- participants ---------------------------------------------------------

  Participant? get _remote {
    final r = _room;
    if (r == null || r.remoteParticipants.isEmpty) return null;
    return r.remoteParticipants.values.first;
  }

  VideoTrack? _videoOf(Participant? p) {
    if (p == null) return null;
    for (final pub in p.videoTrackPublications) {
      final t = pub.track;
      if (t is VideoTrack && !pub.muted) return t;
    }
    return null;
  }

  bool _audioMuted(Participant? p) {
    if (p == null) return false;
    final pubs = p.audioTrackPublications;
    if (pubs.isEmpty) return true;
    return pubs.every((pub) => pub.muted);
  }

  String get _remoteName {
    final r = _remote;
    if (r != null && r.name.isNotEmpty) return r.name;
    final who = widget.waitingFor?.trim();
    return (who != null && who.isNotEmpty) ? who : 'the other person';
  }

  // ---- controls -------------------------------------------------------------

  Future<void> _toggleMic() async {
    _micOn = !_micOn;
    await _room?.localParticipant?.setMicrophoneEnabled(_micOn);
    _armAutoHide();
    _refresh();
  }

  Future<void> _toggleCam() async {
    _camOn = !_camOn;
    await _room?.localParticipant?.setCameraEnabled(_camOn);
    _armAutoHide();
    _refresh();
  }

  Future<void> _toggleSpeaker() async {
    _speakerOn = !_speakerOn;
    await _applySpeaker(_speakerOn);
    _armAutoHide();
    _refresh();
  }

  Future<void> _flipCamera() async {
    LocalVideoTrack? track;
    for (final pub in _room?.localParticipant?.videoTrackPublications ??
        const <TrackPublication>[]) {
      final t = pub.track;
      if (t is LocalVideoTrack) {
        track = t;
        break;
      }
    }
    if (track == null) return;
    _frontCamera = !_frontCamera;
    try {
      await track.setCameraPosition(
          _frontCamera ? CameraPosition.front : CameraPosition.back);
    } catch (e) {
      _frontCamera = !_frontCamera; // it did not happen; do not claim it did
      debugPrint('[call] camera flip failed: $e');
    }
    _armAutoHide();
    _refresh();
  }

  /// The second line: state, then what this session IS — with the person's name
  /// taken out of it.
  ///
  /// Booking titles read "Consult · Dr. Neha Sharma", and the headline above is
  /// already "Dr. Neha Sharma", so printing both gave
  /// "00:52 · Consult · Dr. Neha Sharma" under a heading saying the same name.
  /// Stripping it here rather than shortening the title itself: the title is
  /// what the parent BOUGHT and reads correctly everywhere else — it is only
  /// redundant on the one screen where the name is already the headline.
  String get _statusLine {
    final state = _remote == null ? 'Waiting' : _clock;
    final name = _remoteName.trim();
    var what = widget.title.trim();
    if (name.isNotEmpty && name != 'the other person') {
      what = what
          .replaceAll(RegExp(RegExp.escape(name), caseSensitive: false), '')
          // whatever separator the removal left dangling at either end
          .replaceAll(RegExp(r'^[\s·\-–—,:]+'), '')
          .replaceAll(RegExp(r'[\s·\-–—,:]+$'), '')
          .trim();
    }
    return what.isEmpty ? state : '$state · $what';
  }

  String get _clock {
    final m = _elapsed.inMinutes.toString().padLeft(2, '0');
    final s = (_elapsed.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // ---- build ----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: _connecting
          ? _status('Joining ${widget.title}…', spinner: true)
          : _error != null
              ? _status(_error!)
              : _callView(),
    );
  }

  Widget _status(String msg, {bool spinner = false}) => SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              if (spinner) ...[
                const SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.4, color: _accent),
                ),
                const SizedBox(height: 22),
              ],
              Text(msg,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 15, height: 1.55)),
              if (!spinner) ...[
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () => Navigator.of(context).maybePop(),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 26, vertical: 13),
                    decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12)),
                    child: const Text('Close',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ]),
          ),
        ),
      );

  Widget _callView() {
    final remoteTrack = _videoOf(_remote);
    final selfTrack = _camOn ? _videoOf(_room?.localParticipant) : null;

    // Swap decides which feed is full-bleed. The card always shows the other.
    final mainTrack = _selfIsMain ? selfTrack : remoteTrack;
    final cardTrack = _selfIsMain ? remoteTrack : selfTrack;

    return LayoutBuilder(builder: (context, box) {
      final pos = _selfPos ??= Offset(
        box.maxWidth - _selfW - _margin,
        MediaQuery.of(context).padding.top + 72,
      );

      return Stack(fit: StackFit.expand, children: [
        // ---- the big picture ------------------------------------------------
        GestureDetector(
          onTap: _tapBackground,
          behavior: HitTestBehavior.opaque,
          child: mainTrack != null
              ? VideoTrackRenderer(mainTrack, fit: VideoViewFit.cover)
              : _emptyMain(),
        ),

        // Edge-only scrim so white chrome survives a bright frame. The middle
        // of the picture — the face — is left untouched.
        if (_chrome)
          IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0, 0.2, 0.66, 1],
                  colors: [
                    Colors.black.withValues(alpha: 0.52),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
          ),

        _selfCard(pos, cardTrack, box),

        // POSITIONED, not just aligned. Stack(fit: StackFit.expand) forces
        // every NON-positioned child to fill the stack — so the top bar's Row
        // became full-height and centred its own contents, planting the
        // doctor's name across the middle of their face. Pinning it to the top
        // edge is the fix; the scrim above assumes it is up there too.
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: AnimatedOpacity(
            opacity: _chrome ? 1 : 0,
            duration: const Duration(milliseconds: 180),
            child: IgnorePointer(ignoring: !_chrome, child: _topBar()),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: AnimatedSlide(
            offset: _chrome ? Offset.zero : const Offset(0, 1.4),
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: AnimatedOpacity(
              opacity: _chrome ? 1 : 0,
              duration: const Duration(milliseconds: 180),
              child: IgnorePointer(ignoring: !_chrome, child: _controls()),
            ),
          ),
        ),
      ]);
    });
  }

  /// The full-bleed area when there is no video for it: nobody has joined yet,
  /// or they have their camera off. Those are different facts and the screen
  /// says which — "waiting" when you are alone is the difference between an
  /// appointment that has not started and one where the other person is simply
  /// camera-shy.
  Widget _emptyMain() {
    final alone = _remote == null;
    final name = _selfIsMain ? 'You' : _remoteName;
    return Container(
      color: _panel,
      child: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 96,
            height: 96,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
                shape: BoxShape.circle, color: _accent),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            _selfIsMain
                ? 'Your camera is off'
                : alone
                    ? 'Waiting for $name to join'
                    : '$name has their camera off',
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16.5,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            _selfIsMain
                ? 'Tap the video button to turn it back on.'
                : alone
                    ? 'They will appear here as soon as they do.'
                    : 'You can still hear each other.',
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Colors.white54, fontSize: 13.5, height: 1.5),
          ),
        ]),
      ),
    );
  }

  /// The small card: draggable, corner-snapping, tap to swap.
  Widget _selfCard(Offset pos, VideoTrack? track, BoxConstraints box) {
    final top = MediaQuery.of(context).padding.top + 62;
    final bottom = box.maxHeight - _selfH - 150;

    return Positioned(
      left: pos.dx,
      top: pos.dy,
      child: GestureDetector(
        onTap: () {
          setState(() => _selfIsMain = !_selfIsMain);
          _armAutoHide();
        },
        onPanUpdate: (d) => setState(() {
          _selfPos = Offset(
            (pos.dx + d.delta.dx).clamp(_margin, box.maxWidth - _selfW - _margin),
            (pos.dy + d.delta.dy).clamp(top, bottom < top ? top : bottom),
          );
        }),
        onPanEnd: (_) {
          // Snap horizontally to the nearer edge. Left free vertically, so it
          // can be parked away from whatever is on screen.
          final left = _selfPos!.dx < (box.maxWidth - _selfW) / 2;
          setState(() => _selfPos = Offset(
              left ? _margin : box.maxWidth - _selfW - _margin, _selfPos!.dy));
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: _selfW,
            height: _selfH,
            color: _panel,
            child: Stack(fit: StackFit.expand, children: [
              if (track != null)
                VideoTrackRenderer(track, fit: VideoViewFit.cover)
              else
                Center(
                  child: Icon(
                      _selfIsMain
                          ? Icons.person_outline_rounded
                          : Icons.videocam_off_rounded,
                      color: Colors.white38,
                      size: 24),
                ),
              if (!_micOn && !_selfIsMain)
                Positioned(
                  right: 6,
                  bottom: 6,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        color: _danger, shape: BoxShape.circle),
                    child: const Icon(Icons.mic_off_rounded,
                        size: 12, color: Colors.white),
                  ),
                ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _topBar() => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
          child: Row(children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // The PERSON, not the product. On a call the name of who
                    // you are talking to outranks the name of what was booked,
                    // which moves to the line below.
                    Text(_remoteName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2)),
                    const SizedBox(height: 4),
                    Row(children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _remote == null ? _waiting : _live),
                      ),
                      const SizedBox(width: 7),
                      Flexible(
                        child: Text(
                          _statusLine,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ]),
                  ]),
            ),
            if (_remote != null && _audioMuted(_remote))
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20)),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.mic_off_rounded, size: 13, color: Colors.white),
                  SizedBox(width: 5),
                  Text('Muted',
                      style: TextStyle(color: Colors.white, fontSize: 11.5)),
                ]),
              ),
          ]),
        ),
      );

  /// One floating, frosted bar — WhatsApp's shape. The leave button is a wide
  /// pill rather than another circle so the finger finds it without aiming,
  /// which matters most in the moment someone is trying to get off a call.
  Widget _controls() => Align(
        alignment: Alignment.bottomCenter,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 22, left: 16, right: 16),
            // FIVE CONTROLS DO NOT FIT EVERY PHONE. At 52px circles plus a
            // 74px pill the bar needs ~344dp, which a narrow or large-font
            // device does not have — and Flutter's answer to that is a yellow
            // overflow stripe, on top of a live consultation.
            //
            // scaleDown rather than a smaller fixed size: the bar keeps its
            // designed proportions on the phones that can hold it, and shrinks
            // only where it must. Dropping a control instead would mean
            // choosing which one a small-screen user does not get, and none of
            // mute, camera, speaker, flip or leave is optional in a consult.
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: ClipRRect(
              borderRadius: BorderRadius.circular(38),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(38),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.10)),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    _round(Icons.flip_camera_ios_rounded, _flipCamera,
                        tip: 'Flip camera'),
                    _round(
                        _speakerOn
                            ? Icons.volume_up_rounded
                            : Icons.phone_in_talk_rounded,
                        _toggleSpeaker,
                        on: _speakerOn,
                        tip: _speakerOn ? 'Speaker on' : 'Earpiece'),
                    _round(
                        _camOn
                            ? Icons.videocam_rounded
                            : Icons.videocam_off_rounded,
                        _toggleCam,
                        on: _camOn,
                        tip: _camOn ? 'Camera on' : 'Camera off'),
                    _round(_micOn ? Icons.mic_rounded : Icons.mic_off_rounded,
                        _toggleMic,
                        on: _micOn, tip: _micOn ? 'Mute' : 'Unmute'),
                    const SizedBox(width: 6),
                    Semantics(
                      button: true,
                      label: 'Leave call',
                      child: GestureDetector(
                        onTap: _leave,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: 74,
                          height: 52,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: _danger,
                              borderRadius: BorderRadius.circular(26)),
                          child: const Icon(Icons.call_end_rounded,
                              size: 25, color: Colors.white),
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          ),
        ),
        ),
      );

  /// An "off" control inverts to a white fill — the same signal WhatsApp uses,
  /// and the reason there are no text labels: inverted-means-off is understood
  /// without reading, and a row of five labels would crowd the bar.
  Widget _round(IconData icon, VoidCallback onTap,
          {bool on = true, required String tip}) =>
      Semantics(
        button: true,
        label: tip,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: on ? Colors.white.withValues(alpha: 0.16) : Colors.white,
              ),
              child: Icon(icon,
                  size: 23, color: on ? Colors.white : const Color(0xFF17151E)),
            ),
          ),
        ),
      );
}
