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
//  WHAT IS GUARDED, AND WHY IT MATTERS MORE THAN IT LOOKS
// -----------------------------------------------------------------------------
//  This screen serves TWO products: a 1:1 consultation and a group class. Only
//  the first has been designed. The second renders `remoteParticipants.first`
//  and nothing else, which in a fifty-seat masterclass shows one arbitrary
//  attendee — a known, recorded gap, deliberately left alone for now.
//
//  So every behaviour added for consultations is gated on `_isConsult`, which
//  is `CallJoin.capacity == 1` — the same number the SERVER uses for the same
//  distinction (book_slot, 0029). Gated: the identity chips' role half, the
//  both-present clock, the near-end warning, the leave confirmation, and
//  treating one departure as the end of the call.
//
//  `capacity == 0` means "the server did not say" — the pre-0076 fallback path
//  — and counts as NOT a consult, so an unknown session keeps old behaviour
//  rather than acquiring rules it has never been tested under.
//
// -----------------------------------------------------------------------------
//  IDENTITY COMES FROM THE SESSION, NOT FROM THE CALL SITE
// -----------------------------------------------------------------------------
//  The token used to carry a user id and a display name and no role, so doctor
//  and parent received byte-identical credentials and this screen could not
//  tell you which side of the call you were on. `join_context_for_booking`
//  (0076) now supplies the role; see call_session.dart.
//
//  The name and role are drawn ON the video, OUTSIDE the chrome that fades.
//  That is the whole point: the chrome hides five seconds into a settled call,
//  which is precisely when the screen used to stop identifying anybody.
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
import 'package:wakelock_plus/wakelock_plus.dart';

import '../services/remote/supabase_repo.dart';
import '../theme/app_theme.dart';
import '../localization/app_language.dart';
import 'call_session.dart';

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
    this.join,
    this.startCameraOn = true,
    this.startMicOn = true,
  });

  final String bookingId;
  final String title;

  /// A join already fetched by the pre-join screen.
  ///
  /// When present the room opens immediately — no second token round trip, and
  /// no spinner on a screen the user has already been looking at. When absent
  /// (a group session, or any caller that has not been moved to the pre-join
  /// flow) this screen fetches its own, exactly as it always did.
  final CallJoin? join;

  /// What the pre-join toggles decided. Defaults reproduce the old behaviour —
  /// camera and microphone both live the moment you arrive — so any caller that
  /// does not set them is unaffected.
  final bool startCameraOn;
  final bool startMicOn;

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

/// What the screen is doing, as one value rather than three booleans that can
/// disagree with each other.
///
/// The old screen had `_connecting` and `_error` and nothing else, so a room
/// that dropped mid-call had no state to move to: it stayed in the "connected"
/// branch, rendering a frozen last frame with a running clock and a green
/// "live" dot. Every one of those said the call was fine.
enum _Phase { connecting, live, reconnecting, ended, failed }

class _CallScreenState extends State<CallScreen> with WidgetsBindingObserver {
  Room? _room;
  EventsListener<RoomEvent>? _events;

  _Phase _phase = _Phase.connecting;
  String? _error;

  /// Set when the room closed for a reason worth naming — the other person
  /// hung up, or the connection was lost for good.
  String? _endedBecause;

  /// The join context: our own role, the counterpart, the session window, and
  /// crucially the CAPACITY that decides whether any of this pass's behaviour
  /// applies at all.
  CallJoin? _join;

  /// The single guard. False for a group session, false for anything joined
  /// through the pre-0076 fallback — and in both of those cases every new
  /// behaviour below stays switched off and the screen behaves as it did
  /// before this work.
  bool get _isConsult => _join?.isConsult ?? false;

  late bool _micOn = widget.startMicOn;
  late bool _camOn = widget.startCameraOn;
  bool _speakerOn = true;
  bool _frontCamera = true;

  /// The other side's connection quality, when LiveKit reports it. A frozen
  /// picture and a bad line look identical from the sofa; only one of them is
  /// worth telling someone about.
  ConnectionQuality _remoteQuality = ConnectionQuality.unknown;

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

  /// When the SECOND person arrived. The consult clock is measured from here,
  /// not from connect.
  ///
  /// The old timer started the moment you connected, which meant a parent who
  /// joined eight minutes early greeted her doctor with a clock already reading
  /// 08:00 — of a consultation she had paid thirty minutes for. The screen's own
  /// header says the timer exists because "a consult is a bought, fixed number
  /// of minutes and both sides deserve to see them going"; it was measuring the
  /// wrong thing to say it.
  DateTime? _bothPresentAt;

  /// Fired once, five minutes from the scheduled end.
  bool _warnedNearEnd = false;

  static const _selfW = 108.0;
  static const _selfH = 152.0;
  static const _margin = 14.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // A consultation is exactly the situation the screen timeout was invented
    // for and is exactly wrong about: long stretches of listening without a
    // touch. Held for the whole screen, released in dispose.
    WakelockPlus.enable().catchError((Object e) {
      debugPrint('[call] wakelock unavailable: $e');
    });
    _connect();
  }

  /// Camera capture is stopped while the app is in the background and resumed
  /// when it returns.
  ///
  /// Politeness and battery, but mostly honesty: without this the camera keeps
  /// publishing while she is reading a message in another app, and the doctor
  /// keeps watching a room she believes she has stepped away from. Audio is
  /// deliberately left alone — stepping out of the app to check a date should
  /// not drop you out of the conversation.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final lp = _room?.localParticipant;
    if (lp == null || !_camOn) return;
    if (state == AppLifecycleState.resumed) {
      lp.setCameraEnabled(true).catchError((Object e) {
        debugPrint('[call] camera resume failed: $e');
        return null;
      });
    } else if (state == AppLifecycleState.paused) {
      lp.setCameraEnabled(false).catchError((Object e) {
        debugPrint('[call] camera pause failed: $e');
        return null;
      });
    }
  }

  Future<void> _connect() async {
    setState(() {
      _phase = _Phase.connecting;
      _error = null;
    });
    try {
      // The id is logged because a refusal is ambiguous without it: a booking
      // that only ever existed on this phone and one the server cancelled look
      // identical from here.
      debugPrint('[call] joining bookingId=${widget.bookingId}');

      // The pre-join screen has usually done this already. Fetching again would
      // mint a second token for the same session for no reason.
      var join = widget.join ?? _join;
      if (join == null) {
        final (fetched, failure) = await CallSession.fetchJoin(
          bookingId: widget.bookingId,
          displayName: widget.displayName,
        );
        if (!mounted) return;
        if (failure != null) {
          setState(() {
            _phase = _Phase.failed;
            _error = _failureCopy(failure);
          });
          return;
        }
        join = fetched;
      }
      if (join == null) {
        setState(() {
          _phase = _Phase.failed;
          _error = 'Could not join this session. Please try again.';
        });
        return;
      }
      _join = join;

      // adaptiveStream and dynacast let LiveKit stop sending video nobody is
      // looking at. At two participants the saving is small; the reason to turn
      // them on now is that they are the difference between a class working and
      // a class melting a phone, and a flag that is only ever exercised in the
      // feature that needs it most is a flag nobody has tested.
      final room = Room(
        roomOptions: const RoomOptions(adaptiveStream: true, dynacast: true),
      );

      // SUBSCRIBE BEFORE CONNECTING. Events fired during connect — a
      // participant already in the room, an immediate failure — are missed by a
      // listener attached afterwards, and "the doctor was already there" is the
      // single most likely case in a consultation where one side is punctual.
      final events = room.createListener();
      _wireEvents(events);
      _events = events;

      await room.connect(join.url, join.token);
      await room.localParticipant?.setCameraEnabled(widget.startCameraOn);
      await room.localParticipant?.setMicrophoneEnabled(widget.startMicOn);

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
        _phase = _Phase.live;
      });
      _noteIfBothPresent();
      _recordJoin();
      _tick = Timer.periodic(const Duration(seconds: 1), (_) => _onTick());
    } catch (e) {
      debugPrint('[call] connect failed: $e');
      if (mounted) {
        setState(() {
          _phase = _Phase.failed;
          _error = 'Something went wrong joining the call.';
        });
      }
    }
  }

  /// The states the screen could not previously observe.
  ///
  /// `room.addListener` alone gives a change notification with no reason
  /// attached, which is why a dropped call used to be indistinguishable from a
  /// quiet one. These are the reasons.
  void _wireEvents(EventsListener<RoomEvent> events) {
    events
      ..on<ParticipantConnectedEvent>((_) {
        if (!mounted) return;
        _noteIfBothPresent();
        setState(() {});
      })
      ..on<ParticipantDisconnectedEvent>((_) {
        if (!mounted) return;
        // In a consult there is exactly one other person, so their leaving IS
        // the end of the call and should say so. In a class it is one of fifty
        // and means nothing — hence the guard.
        if (_isConsult && _remote == null) {
          setState(() {
            _phase = _Phase.ended;
            _endedBecause = '$_remoteName left the call.';
          });
          _tick?.cancel();
        } else {
          setState(() {});
        }
      })
      ..on<RoomReconnectingEvent>((_) {
        if (!mounted) return;
        setState(() => _phase = _Phase.reconnecting);
      })
      ..on<RoomReconnectedEvent>((_) {
        if (!mounted) return;
        setState(() => _phase = _Phase.live);
      })
      ..on<RoomDisconnectedEvent>((e) {
        if (!mounted) return;
        debugPrint('[call] disconnected: ${e.reason}');
        _tick?.cancel();
        setState(() {
          _phase = _Phase.ended;
          _endedBecause = e.reason == DisconnectReason.clientInitiated
              ? null
              : 'The connection to the call was lost.';
        });
      })
      ..on<ParticipantConnectionQualityUpdatedEvent>((e) {
        if (!mounted || e.participant is LocalParticipant) return;
        setState(() => _remoteQuality = e.connectionQuality);
      });
  }

  /// The id of this device's attendance row, once the server has one.
  String? _sessionRowId;

  /// TELLING THE SERVER SOMEBODY TURNED UP.
  ///
  /// Until this existed, attendance was inferred from the clock — a booking
  /// whose end time had passed was written into the parent's history as
  /// "attended", whether or not a single person had joined, and
  /// `BookingStatus.missed` was never written by anything at all.
  ///
  /// The id is minted HERE, not by the server, for the same reason booking and
  /// prescription ids are: rejoining after a dropped connection is the normal
  /// case in a video call, and a client-minted id makes the retry write the
  /// same row instead of logging a second arrival.
  void _recordJoin() {
    if (_sessionRowId != null) return; // a rejoin is the same attendance
    final id = 'cs_${widget.bookingId}_${DateTime.now().microsecondsSinceEpoch}';
    _sessionRowId = id;
    SupabaseRepo.recordConsultJoin(id, widget.bookingId)
        .catchError((Object e) {
      debugPrint('[call] attendance not recorded: $e');
      return null;
    });
  }

  void _recordLeave() {
    final id = _sessionRowId;
    if (id == null) return;
    _sessionRowId = null;
    SupabaseRepo.recordConsultLeave(id).catchError((Object e) {
      debugPrint('[call] leave not recorded: $e');
    });
  }

  /// Starts the consult clock the first time both people are in the room.
  void _noteIfBothPresent() {
    if (_bothPresentAt != null) return;
    if (_remote == null) return;
    _bothPresentAt = DateTime.now();
    _elapsed = Duration.zero;
  }

  void _onTick() {
    if (!mounted) return;
    setState(() {
      // Before the other person arrives there is nothing to count. A group
      // session keeps the old behaviour — count from connect — because a class
      // has no "both present" moment to wait for.
      if (!_isConsult || _bothPresentAt != null) {
        _elapsed += const Duration(seconds: 1);
      }
    });

    // Five minutes out from the end of what was bought. Said once, quietly,
    // and only for a consult: a class overrunning is the host's business.
    final ends = _join?.endsUtc;
    if (_isConsult && !_warnedNearEnd && ends != null && _remote != null) {
      final left = ends.difference(DateTime.now().toUtc());
      if (!left.isNegative && left.inMinutes <= 5) {
        _warnedNearEnd = true;
        _showNearEndNotice();
      }
    }
  }

  void _showNearEndNotice() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('About 5 minutes left in this consultation.'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _panel,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  String _failureCopy(CallJoinFailure f) => switch (f.kind) {
        CallRefusal.tooEarly => f.opensUtc != null
            ? 'This consultation opens at ${_clockAt(f.opensUtc!)}, ten minutes '
                'before it starts.'
            : 'This consultation has not opened yet. You can join ten minutes '
                'before it starts.',
        CallRefusal.ended =>
          'This consultation has ended. You can book a follow-up from My '
              'Bookings.',
        CallRefusal.notYours =>
          'This session is not available. It may have been cancelled, or it '
              'belongs to a different account.',
        CallRefusal.notSignedIn =>
          'Please sign in as the account that booked this session.',
        CallRefusal.offline =>
          'You appear to be offline. A video consultation needs a working '
              'connection.',
        CallRefusal.serverError =>
          'Something went wrong on our side. Please try again in a moment.',
      };

  String _clockAt(DateTime utc) {
    final d = utc.toLocal();
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final m = d.minute.toString().padLeft(2, '0');
    return '$h:$m ${d.hour < 12 ? 'AM' : 'PM'}';
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

  /// Leaving, with one question first.
  ///
  /// The red pill used to hang up on the first tap. That is right for a call
  /// you can restart by tapping a contact; it is wrong for a bought
  /// consultation with a clinician, where the same accident costs money and
  /// requires the other person to still be there when you come back.
  ///
  /// The confirmation is only for a live consult. A class, a call that has
  /// already ended, and a connection that never came up all leave immediately —
  /// asking "are you sure?" about a call that is already over is noise.
  Future<void> _confirmLeave() async {
    if (!_isConsult || _phase != _Phase.live) {
      await _leave();
      return;
    }
    final go = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _panel,
        title: const Text('Leave this consultation?',
            style: TextStyle(color: Colors.white, fontSize: 17)),
        content: Text(
          _remote == null
              ? 'You can rejoin from My Bookings while the session is running.'
              : 'You are still connected to $_remoteName. You can rejoin from '
                  'My Bookings while the session is running.',
          style: const TextStyle(color: Colors.white70, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Leave', style: TextStyle(color: _danger)),
          ),
        ],
      ),
    );
    if (go == true) await _leave();
  }

  Future<void> _leave() async {
    _recordLeave();
    final r = _room;
    _room = null;
    _tick?.cancel();
    _chromeTimer?.cancel();
    await _events?.dispose();
    _events = null;
    r?.removeListener(_refresh);
    await r?.disconnect();
    await r?.dispose();
    if (mounted) Navigator.of(context).maybePop();
  }

  @override
  void dispose() {
    // Covers the exits that are not the red pill — a back gesture on a class,
    // the process being torn down, a route popped from elsewhere. Without it a
    // session would show a join and no leave, and read as still running.
    _recordLeave();
    WidgetsBinding.instance.removeObserver(this);
    WakelockPlus.disable().catchError((Object e) {
      debugPrint('[call] wakelock release: $e');
    });
    _tick?.cancel();
    _chromeTimer?.cancel();
    _events?.dispose();
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
    if (who != null && who.isNotEmpty) return who;
    final fromServer = _join?.counterpart.trim() ?? '';
    if (fromServer.isNotEmpty) return fromServer;
    return 'the other person';
  }

  /// The other participant's role, read from the metadata the server stamped
  /// into their token.
  ///
  /// Not inferred from ours. "I am the parent, therefore they are the doctor"
  /// holds today only because a consult has exactly two people — it stops being
  /// true the moment anything else joins, and a badge that is right by
  /// coincidence is a badge that will be wrong later.
  CallRole get _remoteRole => CallSession.roleFromMetadata(_remote?.metadata);

  CallRole get _myRole => _join?.role ?? CallRole.unknown;

  /// A name with its role beside it, drawn ON the video and outside the chrome
  /// that auto-hides.
  ///
  /// This is the fix for the complaint that you cannot tell who is who. The
  /// only name on screen used to live in the top bar, which disappears five
  /// seconds into a settled call — so for almost the whole consultation the
  /// screen said nothing about who was on it. Meet, Zoom and WhatsApp all keep
  /// a persistent label for the same reason.
  Widget _nameChip(String name, CallRole role, {bool compact = false}) {
    final label = role.label;
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: compact ? 7 : 10, vertical: compact ? 3 : 5.5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Flexible(
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: Colors.white,
                fontSize: compact ? 10.5 : 12.5,
                fontWeight: FontWeight.w600),
          ),
        ),
        // Omitted rather than guessed when the role is unknown — a group
        // session and the pre-0076 fallback both land here.
        if (label.isNotEmpty) ...[
          SizedBox(width: compact ? 4 : 6),
          Container(
            width: 3,
            height: 3,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.45)),
          ),
          SizedBox(width: compact ? 4 : 6),
          Text(
            label,
            style: TextStyle(
                color: role.isExpert ? _accent : Colors.white70,
                fontSize: compact ? 10 : 11.5,
                fontWeight: FontWeight.w700),
          ),
        ],
      ]),
    );
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
    // The clock only appears once there is something to count. In a consult
    // that is the moment the second person arrives (see _bothPresentAt); until
    // then the line says "Waiting", because a timer running against an empty
    // room is telling the user a number about nothing.
    final counting = !_isConsult || _bothPresentAt != null;
    final state = (_remote == null || !counting) ? 'Waiting' : _clock;
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
    // A hardware back press during a live consult goes through the same
    // question as the red pill. Without this the confirmation is trivially
    // bypassed by the one gesture people make without looking.
    return PopScope(
      canPop: !(_isConsult && _phase == _Phase.live),
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmLeave();
      },
      child: Scaffold(
        backgroundColor: _bg,
        body: switch (_phase) {
          _Phase.connecting =>
            _status('Joining ${widget.title}…', spinner: true),
          _Phase.failed => _status(
              _error ?? 'Something went wrong joining the call.',
              retry: true,
            ),
          _Phase.ended => _endedView(),
          _Phase.live || _Phase.reconnecting => _callView(),
        },
      ),
    );
  }

  Widget _status(String msg, {bool spinner = false, bool retry = false}) =>
      SafeArea(
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
                // A dead end with one Close button was the whole vocabulary
                // here, for six different causes. Where trying again could
                // plausibly work, offer it.
                if (retry) ...[
                  _pillButton('Try again', _connect, filled: true),
                  const SizedBox(height: 10),
                ],
                _pillButton(S.now.uiClose, () => Navigator.of(context).maybePop()),
              ],
            ]),
          ),
        ),
      );

  /// The call is over. Previously this state did not exist: the screen either
  /// stayed frozen on a dead room or popped with no explanation, so "the doctor
  /// hung up" and "your Wi-Fi died" looked the same and neither was said.
  Widget _endedView() => SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.call_end_rounded, size: 40, color: Colors.white38),
              const SizedBox(height: 20),
              const Text('Call ended',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w700)),
              if (_endedBecause != null) ...[
                const SizedBox(height: 8),
                Text(_endedBecause!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 13.5, height: 1.5)),
              ],
              if (_bothPresentAt != null) ...[
                const SizedBox(height: 14),
                Text('You spoke for $_clockLabel',
                    style: const TextStyle(color: Colors.white70, fontSize: 13)),
              ],
              const SizedBox(height: 26),
              // Rejoining is the common case after a dropped connection, and
              // there was no way to do it without backing out to a list.
              _pillButton('Rejoin', _connect, filled: true),
              const SizedBox(height: 10),
              _pillButton('Done', () => Navigator.of(context).maybePop()),
            ]),
          ),
        ),
      );

  Widget _pillButton(String label, VoidCallback onTap, {bool filled = false}) =>
      Semantics(
        button: true,
        label: label,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 13),
            decoration: BoxDecoration(
                color: filled ? _accent : Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12)),
            child: Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
          ),
        ),
      );

  String get _clockLabel {
    final m = _elapsed.inMinutes;
    final s = _elapsed.inSeconds % 60;
    if (m == 0) return '$s seconds';
    return m == 1 ? '1 minute' : '$m minutes';
  }

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

        // WHO IS THE BIG PICTURE. Persistent, and deliberately NOT inside the
        // chrome that fades: for most of a settled call the chrome is hidden,
        // which is exactly when the screen used to carry no identification at
        // all. Sits above the control bar so it never collides with it.
        Positioned(
          left: 18,
          right: 140, // clear of the self card's landing corner
          bottom: MediaQuery.of(context).padding.bottom + 108,
          child: Align(
            alignment: Alignment.centerLeft,
            child: _nameChip(
              _selfIsMain ? 'You' : _remoteName,
              _selfIsMain ? _myRole : _remoteRole,
            ),
          ),
        ),

        // Reconnecting, and a weak line, both said out loud. Neither state
        // existed before; a dropped call simply froze while the timer kept
        // running and the status dot stayed green.
        if (_phase == _Phase.reconnecting)
          _banner(
            icon: Icons.wifi_tethering_rounded,
            text: 'Reconnecting…',
            color: _waiting,
          )
        else if (_remote != null &&
            (_remoteQuality == ConnectionQuality.poor ||
                _remoteQuality == ConnectionQuality.lost))
          _banner(
            icon: Icons.signal_cellular_alt_rounded,
            text: 'Weak connection — video may freeze',
            color: _waiting,
          ),

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

  /// A thin notice pinned under the top bar. Always visible — a connection
  /// problem is the one thing that must not hide with the chrome, because the
  /// user's next move (wait, or give up and phone) depends on knowing it.
  Widget _banner({
    required IconData icon,
    required String text,
    required Color color,
  }) =>
      Positioned(
        top: MediaQuery.of(context).padding.top + 74,
        left: 0,
        right: 0,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.62),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withValues(alpha: 0.55)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 7),
              Text(text,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ]),
          ),
        ),
      );

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

              // THE SIGNIFIER THAT WAS MISSING.
              //
              // Tapping this card to swap has always worked. Nothing said so —
              // it was a bare video rectangle — so it read as "a small block
              // you cannot make bigger", which is exactly how it was reported.
              // The interaction did not need building; the invitation did.
              Positioned(
                left: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Icon(Icons.swap_horiz_rounded,
                      size: 13, color: Colors.white),
                ),
              ),

              // And who this small one is, for the same reason the big one is
              // labelled: so neither picture is ever anonymous.
              Positioned(
                left: 5,
                right: 5,
                bottom: 5,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _nameChip(
                    _selfIsMain ? _remoteName : 'You',
                    _selfIsMain ? _remoteRole : _myRole,
                    compact: true,
                  ),
                ),
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
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.mic_off_rounded, size: 13, color: Colors.white),
                  SizedBox(width: 5),
                  Text(S.now.uiMuted,
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
                      label: S.now.uiLeaveCall,
                      child: GestureDetector(
                        onTap: _confirmLeave,
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
