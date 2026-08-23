// =============================================================================
//  GroupCallScreen — a masterclass or cohort, as a room with a teacher in it
// -----------------------------------------------------------------------------
//  WHAT THIS REPLACES. Group sessions used to open CallScreen, which is a 1:1
//  screen. Its entire notion of "the other person" is:
//
//      Participant? get _remote => r.remoteParticipants.values.first;
//
//  In a fifty-seat masterclass that renders ONE arbitrary attendee — whoever
//  the map happened to yield first, very often not the host — while the other
//  forty-nine are invisible and their audio plays from nobody. Everyone
//  arrived publishing, because the token said they could and the client turned
//  the camera on at connect.
//
//  So this is a different screen rather than a mode inside that one. The 1:1
//  path is untouched by anything here, and neither file has to carry an `if`
//  about the other.
//
// -----------------------------------------------------------------------------
//  A CLASS IS A BROADCAST, AND THE LAYOUT SHOULD SAY SO
// -----------------------------------------------------------------------------
//  A grid is the wrong instinct. Forty tiles of forty people who are not
//  speaking, cannot speak, and mostly have no camera on is forty pictures of
//  nothing, and it shrinks the one thing anyone came to see.
//
//  So: SPEAKER VIEW. The host holds the stage; anyone the host has promoted
//  appears in a filmstrip beneath. Everyone else is a name in the participant
//  list, which is where a count of forty is genuinely useful and forty tiles
//  are not.
//
// -----------------------------------------------------------------------------
//  WHY THE HOST CONTROLS ARE ROUND TRIPS
// -----------------------------------------------------------------------------
//  Mute-all, remove and promote all go to the `livekit-moderate` edge function
//  rather than happening locally, because a LiveKit client governs its own
//  tracks and nobody else's. A local "mute everyone" can only ASK other
//  clients to mute themselves — which a modified client ignores and an offline
//  one never hears — leaving the host looking at a muted-looking list while a
//  live kitchen carries on being broadcast to the class.
//
//  Slower, and true. See CallModeration.
// =============================================================================

import 'dart:async';
import 'dart:convert';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../services/remote/supabase_repo.dart';
import '../theme/app_theme.dart';
import 'call_session.dart';

const _bg = Color(0xFF0E0D12);
const _panel = Color(0xFF17151E);
const _accent = AppTheme.primary;
const _danger = Color(0xFFE5484D);
const _live = Color(0xFF3ECF8E);
const _waiting = Color(0xFFE0A02E);

/// Messages that travel on the data channel.
///
/// The data channel is granted to EVERYONE, including attendees who may not
/// publish audio or video. That is deliberate and it is what makes a silent
/// audience participatory: a hand goes up and a question gets asked without
/// anyone being able to talk over the class.
class _Wire {
  static const hand = 'hand';
  static const question = 'q';
}

class GroupCallScreen extends StatefulWidget {
  const GroupCallScreen({
    super.key,
    required this.title,
    this.join,
    this.bookingId,
    this.hostName,
  }) : assert(join != null || bookingId != null,
            'a group call needs either a fetched join (the host route) or a '
            'bookingId to fetch one with (the attendee route)');

  final String title;

  /// Already fetched — the HOST route. A host has no booking, so their join is
  /// obtained from the slot before this screen opens and handed in.
  final CallJoin? join;

  /// The ATTENDEE route. Fetched here rather than beforehand because an
  /// attendee needs no camera or microphone permission to attend a class —
  /// they cannot publish — so there is nothing a pre-join screen would ask
  /// them, and a green room with no decisions in it is a delay pretending to
  /// be a step.
  final String? bookingId;

  /// Who is teaching, for the copy shown while waiting.
  final String? hostName;

  @override
  State<GroupCallScreen> createState() => _GroupCallScreenState();
}

enum _Phase { connecting, live, reconnecting, ended, failed }

class _Question {
  _Question(this.who, this.text, this.at);
  final String who;
  final String text;
  final DateTime at;
}

class _GroupCallScreenState extends State<GroupCallScreen>
    with WidgetsBindingObserver {
  Room? _room;
  EventsListener<RoomEvent>? _events;

  _Phase _phase = _Phase.connecting;
  String? _error;
  String? _endedBecause;

  bool _micOn = false;
  bool _camOn = false;
  bool _speakerOn = true;
  bool _frontCamera = true;
  bool _handUp = false;
  bool _busy = false;

  /// Whoever LiveKit last reported as speaking. Drives who holds the stage
  /// when more than one person is entitled to publish.
  String? _activeSpeakerId;

  final List<_Question> _questions = [];
  final Set<String> _handsUp = {};
  int _unreadQuestions = 0;

  Timer? _tick;
  Duration _elapsed = Duration.zero;

  /// Null until the attendee route has fetched one. The host route hands it in.
  CallJoin? _join;

  bool get _isHost => _join?.role.isHost ?? false;

  /// Moderation is addressed to a slot, not a booking — a host has no booking,
  /// and the room is one per slot.
  String get _slotId => _join?.slotId ?? '';

  /// May this device turn anything on? False for an attendee until the host
  /// promotes them — at which point LiveKit updates the permission live and
  /// [ParticipantPermissionsUpdatedEvent] tells us.
  bool _canPublish = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _join = widget.join;
    _canPublish = widget.join?.canPublish ?? false;
    WakelockPlus.enable().catchError((Object e) {
      debugPrint('[group] wakelock unavailable: $e');
    });
    _connect();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final lp = _room?.localParticipant;
    if (lp == null || !_camOn) return;
    if (state == AppLifecycleState.resumed) {
      lp.setCameraEnabled(true).catchError((Object e) => null);
    } else if (state == AppLifecycleState.paused) {
      lp.setCameraEnabled(false).catchError((Object e) => null);
    }
  }

  // ---- connection -----------------------------------------------------------

  Future<void> _connect() async {
    setState(() {
      _phase = _Phase.connecting;
      _error = null;
    });
    try {
      var join = _join;
      if (join == null) {
        final (fetched, failure) =
            await CallSession.fetchJoin(bookingId: widget.bookingId!);
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
          _error = 'Could not open this session. Please try again.';
        });
        return;
      }
      _join = join;
      _canPublish = join.canPublish;

      // adaptiveStream and dynacast matter here in a way they never did at two
      // participants: they stop the server sending video nobody is looking at.
      // In a room of forty that is the difference between a class and a melted
      // phone.
      final room = Room(
        roomOptions: const RoomOptions(adaptiveStream: true, dynacast: true),
      );

      final events = room.createListener();
      _wireEvents(events);
      _events = events;

      await room.connect(join.url, join.token);

      // THE HOST ARRIVES LIVE. AN ATTENDEE ARRIVES SILENT.
      //
      // This is the whole fix for "fifty mothers joined a masterclass and fifty
      // were broadcasting". The token already forbids an attendee from
      // publishing, so this is belt and braces rather than the enforcement —
      // but asking for a camera we are not allowed to publish would throw on
      // some devices and log a permission error on the rest.
      if (_canPublish) {
        await room.localParticipant?.setCameraEnabled(true);
        await room.localParticipant?.setMicrophoneEnabled(true);
        _camOn = true;
        _micOn = true;
      }

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
      _recordJoin();
      _tick = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _elapsed += const Duration(seconds: 1));
      });
    } catch (e) {
      debugPrint('[group] connect failed: $e');
      if (mounted) {
        setState(() {
          _phase = _Phase.failed;
          _error = 'Something went wrong joining this session.';
        });
      }
    }
  }

  void _wireEvents(EventsListener<RoomEvent> events) {
    events
      ..on<ParticipantConnectedEvent>((_) => _refresh())
      ..on<ParticipantDisconnectedEvent>((e) {
        // In a class one person leaving means nothing — unless it is the
        // teacher, and then it means everything.
        final left = CallSession.roleFromMetadata(e.participant.metadata);
        if (left.isHost && !_isHost) {
          setState(() => _endedBecause =
              '${_hostName()} has left. They may be reconnecting.');
        }
        _handsUp.remove(e.participant.identity);
        _refresh();
      })
      ..on<RoomReconnectingEvent>((_) {
        if (mounted) setState(() => _phase = _Phase.reconnecting);
      })
      ..on<RoomReconnectedEvent>((_) {
        if (mounted) setState(() => _phase = _Phase.live);
      })
      ..on<RoomDisconnectedEvent>((e) {
        if (!mounted) return;
        _tick?.cancel();
        setState(() {
          _phase = _Phase.ended;
          _endedBecause = switch (e.reason) {
            DisconnectReason.clientInitiated => null,
            // The host ended it for everyone. Not an error — the class is over.
            DisconnectReason.roomDeleted => 'The host ended this session.',
            DisconnectReason.participantRemoved =>
              'You were removed from this session.',
            _ => 'The connection to this session was lost.',
          };
        });
      })
      ..on<ActiveSpeakersChangedEvent>((e) {
        if (!mounted) return;
        // First speaker who is not us. Keeping our own voice off the stage
        // stops the screen flipping to a self-view every time we say "yes".
        final other = e.speakers
            .where((p) => p is! LocalParticipant)
            .map((p) => p.identity)
            .firstOrNull;
        setState(() => _activeSpeakerId = other);
      })
      // The host promoted or demoted us, live, with no reconnect.
      ..on<ParticipantPermissionsUpdatedEvent>((e) {
        if (e.participant is! LocalParticipant || !mounted) return;
        final may = e.participant.permissions.canPublish;
        if (may == _canPublish) return;
        setState(() {
          _canPublish = may;
          if (!may) {
            _micOn = false;
            _camOn = false;
          }
          _handUp = false;
        });
        if (!may) {
          _room?.localParticipant?.setMicrophoneEnabled(false);
          _room?.localParticipant?.setCameraEnabled(false);
        }
        _toast(may
            ? 'The host has invited you to speak. Your mic is ready.'
            : 'You are back on mute.');
      })
      ..on<DataReceivedEvent>(_onData);
  }

  void _onData(DataReceivedEvent e) {
    if (!mounted) return;
    try {
      final msg = jsonDecode(utf8.decode(e.data));
      if (msg is! Map) return;
      final who = e.participant?.name.isNotEmpty == true
          ? e.participant!.name
          : 'Someone';
      switch (msg['t']) {
        case _Wire.hand:
          final id = e.participant?.identity;
          if (id == null) return;
          setState(() {
            if (msg['up'] == true) {
              _handsUp.add(id);
            } else {
              _handsUp.remove(id);
            }
          });
        case _Wire.question:
          final text = (msg['text'] ?? '').toString().trim();
          if (text.isEmpty) return;
          setState(() {
            _questions.add(_Question(who, text, DateTime.now()));
            _unreadQuestions++;
          });
      }
    } catch (_) {
      // Somebody else's data, or malformed. A bad packet costs a message,
      // never the session.
    }
  }

  Future<void> _send(Map<String, Object?> msg) async {
    try {
      await _room?.localParticipant?.publishData(
        utf8.encode(jsonEncode(msg)),
        reliable: true,
      );
    } catch (e) {
      debugPrint('[group] send failed: $e');
    }
  }

  /// A refusal, said as the reason it was. Same discipline as the consult
  /// screen: "this session opens at 7:30 PM" and "you are offline" are
  /// different sentences and one of them is worth a Retry button.
  String _failureCopy(CallJoinFailure f) => switch (f.kind) {
        CallRefusal.tooEarly => f.opensUtc != null
            ? 'This session opens at ${_clockAt(f.opensUtc!)}.'
            : 'This session has not opened yet.',
        CallRefusal.ended =>
          'This session has ended. If a recording was included, it will appear '
              'in My Bookings.',
        CallRefusal.notYours =>
          'This session is not available. It may have been cancelled, or it '
              'belongs to a different account.',
        CallRefusal.notSignedIn =>
          'Please sign in as the account that booked this session.',
        CallRefusal.offline =>
          'You appear to be offline. Check your connection and try again.',
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
      debugPrint('[group] speakerphone unavailable: $e');
    }
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  // ---- attendance -----------------------------------------------------------

  String? _sessionRowId;

  void _recordJoin() {
    if (_sessionRowId != null) return;

    // ATTENDEES ONLY, AND KEYED ON THE BOOKING.
    //
    // This first passed the SLOT id, which was wrong twice over and silently:
    // `record_consult_join` (0078) looks its argument up in `booking_bookings`,
    // so a slot id found nothing and the function returned null without a row —
    // no error, no attendance. And `settle_my_bookings` matches
    // `consult_sessions.booking_id = booking_bookings.id`, so even a row keyed
    // on the slot would never have settled anything.
    //
    // A HOST has no booking and nothing to settle, so there is nothing to
    // record for them here. Host attendance is a separate question — it belongs
    // with the session log a class needs for its own sake — and pretending to
    // record it would be worse than the gap.
    final bookingId = widget.bookingId;
    if (bookingId == null || bookingId.isEmpty) return;

    final id = 'cs_${bookingId}_${DateTime.now().microsecondsSinceEpoch}';
    _sessionRowId = id;
    SupabaseRepo.recordConsultJoin(id, bookingId).catchError((Object e) {
      debugPrint('[group] attendance not recorded: $e');
      return null;
    });
  }

  void _recordLeave() {
    final id = _sessionRowId;
    if (id == null) return;
    _sessionRowId = null;
    SupabaseRepo.recordConsultLeave(id).catchError((Object e) {});
  }

  // ---- leaving --------------------------------------------------------------

  Future<void> _confirmLeave() async {
    // The host leaving is not the same act as an attendee leaving, so it does
    // not get the same question. A teacher walking out of their own class
    // should be asked whether they mean to end it for everyone.
    if (!_isHost) {
      await _leave();
      return;
    }
    final choice = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _panel,
        title: const Text('Leave this session?',
            style: TextStyle(color: Colors.white, fontSize: 17)),
        content: const Text(
          'You can step out and come back, or end it for everyone.',
          style: TextStyle(color: Colors.white70, height: 1.5),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop('stay'),
              child: const Text('Stay')),
          TextButton(
              onPressed: () => Navigator.of(ctx).pop('leave'),
              child: const Text('Just leave')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop('end'),
            child: const Text('End for everyone',
                style: TextStyle(color: _danger)),
          ),
        ],
      ),
    );
    if (choice == 'end') {
      await CallModeration.endRoom(_slotId);
      await _leave();
    } else if (choice == 'leave') {
      await _leave();
    }
  }

  Future<void> _leave() async {
    _recordLeave();
    final r = _room;
    _room = null;
    _tick?.cancel();
    await _events?.dispose();
    _events = null;
    r?.removeListener(_refresh);
    await r?.disconnect();
    await r?.dispose();
    if (mounted) Navigator.of(context).maybePop();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    WakelockPlus.disable().catchError((Object e) {});
    _recordLeave();
    _tick?.cancel();
    _events?.dispose();
    final r = _room;
    r?.removeListener(_refresh);
    r?.disconnect();
    r?.dispose();
    super.dispose();
  }

  // ---- participants ---------------------------------------------------------

  List<Participant> get _everyone {
    final r = _room;
    if (r == null) return const [];
    return [
      if (r.localParticipant != null) r.localParticipant!,
      ...r.remoteParticipants.values,
    ];
  }

  /// Who holds the stage: the active speaker if there is one, otherwise the
  /// host, otherwise anybody publishing video.
  Participant? get _stage {
    final all = _everyone;
    if (all.isEmpty) return null;
    if (_activeSpeakerId != null) {
      for (final p in all) {
        if (p.identity == _activeSpeakerId) return p;
      }
    }
    for (final p in all) {
      if (CallSession.roleFromMetadata(p.metadata).isHost) return p;
    }
    for (final p in all) {
      if (p is! LocalParticipant && _videoOf(p) != null) return p;
    }
    return null;
  }

  /// Everyone publishing video who is not on the stage — the filmstrip.
  List<Participant> get _strip {
    final stageId = _stage?.identity;
    return [
      for (final p in _everyone)
        if (p.identity != stageId && _videoOf(p) != null) p,
    ];
  }

  VideoTrack? _videoOf(Participant? p) {
    if (p == null) return null;
    for (final pub in p.videoTrackPublications) {
      final t = pub.track;
      if (t is VideoTrack && !pub.muted) return t;
    }
    return null;
  }

  bool _muted(Participant p) {
    final pubs = p.audioTrackPublications;
    if (pubs.isEmpty) return true;
    return pubs.every((pub) => pub.muted);
  }

  String _nameOf(Participant p) =>
      p is LocalParticipant ? 'You' : (p.name.isNotEmpty ? p.name : 'Guest');

  String _hostName() {
    for (final p in _everyone) {
      if (CallSession.roleFromMetadata(p.metadata).isHost) return _nameOf(p);
    }
    final n = widget.hostName?.trim();
    return (n != null && n.isNotEmpty) ? n : 'the host';
  }

  // ---- controls -------------------------------------------------------------

  Future<void> _toggleMic() async {
    if (!_canPublish) return;
    _micOn = !_micOn;
    await _room?.localParticipant?.setMicrophoneEnabled(_micOn);
    _refresh();
  }

  Future<void> _toggleCam() async {
    if (!_canPublish) return;
    _camOn = !_camOn;
    await _room?.localParticipant?.setCameraEnabled(_camOn);
    _refresh();
  }

  Future<void> _toggleSpeaker() async {
    _speakerOn = !_speakerOn;
    await _applySpeaker(_speakerOn);
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
    } catch (_) {
      _frontCamera = !_frontCamera;
    }
    _refresh();
  }

  Future<void> _toggleHand() async {
    setState(() => _handUp = !_handUp);
    await _send({'t': _Wire.hand, 'up': _handUp});
    _toast(_handUp
        ? 'Hand raised. The host can see it.'
        : 'Hand lowered.');
  }

  Future<void> _muteAll() async {
    setState(() => _busy = true);
    final n = await CallModeration.muteAll(_slotId);
    if (!mounted) return;
    setState(() => _busy = false);
    // Said from the RESULT, never from the intent. A "muted everyone" message
    // that fires whether or not the server agreed is the same class of lie the
    // doctor's Cancel button used to tell.
    _toast(n == null
        ? 'Could not mute the room. Please try again.'
        : n == 0
            ? 'Nobody was unmuted.'
            : n == 1
                ? '1 person muted.'
                : '$n people muted.');
  }

  void _toast(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Text(m),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _panel,
      ));
  }

  String get _clock {
    final m = _elapsed.inMinutes.toString().padLeft(2, '0');
    final s = (_elapsed.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // ---- build ----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isHost || _phase != _Phase.live,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmLeave();
      },
      child: Scaffold(
        backgroundColor: _bg,
        body: switch (_phase) {
          _Phase.connecting => _status('Joining ${widget.title}…', spinner: true),
          _Phase.failed => _status(_error ?? 'Something went wrong.', retry: true),
          _Phase.ended => _endedView(),
          _Phase.live || _Phase.reconnecting => _room == null
              ? _status('Joining…', spinner: true)
              : _sessionView(),
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
                        strokeWidth: 2.4, color: _accent)),
                const SizedBox(height: 22),
              ],
              Text(msg,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 15, height: 1.55)),
              if (!spinner) ...[
                const SizedBox(height: 24),
                if (retry) ...[
                  _pill('Try again', _connect, filled: true),
                  const SizedBox(height: 10),
                ],
                _pill('Close', () => Navigator.of(context).maybePop()),
              ],
            ]),
          ),
        ),
      );

  Widget _endedView() => SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.groups_rounded, size: 40, color: Colors.white38),
              const SizedBox(height: 18),
              const Text('Session ended',
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
              const SizedBox(height: 14),
              Text('You were here for $_clock',
                  style: const TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 24),
              _pill('Rejoin', _connect, filled: true),
              const SizedBox(height: 10),
              _pill('Done', () => Navigator.of(context).maybePop()),
            ]),
          ),
        ),
      );

  Widget _sessionView() {
    final stage = _stage;
    final stageTrack = _videoOf(stage);
    final strip = _strip;

    return Stack(fit: StackFit.expand, children: [
      Positioned.fill(
        child: stageTrack != null
            ? VideoTrackRenderer(stageTrack, fit: VideoViewFit.cover)
            : _emptyStage(),
      ),

      // Edge scrim so white chrome survives a bright frame.
      IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0, 0.22, 0.62, 1],
              colors: [
                Colors.black.withValues(alpha: 0.6),
                Colors.transparent,
                Colors.transparent,
                Colors.black.withValues(alpha: 0.78),
              ],
            ),
          ),
        ),
      ),

      // The name on the stage, always on. Same reasoning as the 1:1 screen:
      // an unlabelled face is the complaint that started all of this.
      if (stage != null)
        Positioned(
          left: 18,
          right: 18,
          bottom: strip.isEmpty ? 132 : 244,
          child: Align(
            alignment: Alignment.centerLeft,
            child: _chip(_nameOf(stage),
                CallSession.roleFromMetadata(stage.metadata)),
          ),
        ),

      if (strip.isNotEmpty)
        Positioned(left: 0, right: 0, bottom: 128, child: _filmstrip(strip)),

      Positioned(top: 0, left: 0, right: 0, child: _topBar()),

      if (_phase == _Phase.reconnecting)
        Positioned(
          top: MediaQuery.of(context).padding.top + 78,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.62),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _waiting.withValues(alpha: 0.55)),
              ),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.wifi_tethering_rounded, size: 14, color: _waiting),
                SizedBox(width: 7),
                Text('Reconnecting…',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
        ),

      Positioned(left: 0, right: 0, bottom: 0, child: _controls()),
    ]);
  }

  Widget _emptyStage() {
    final waitingForHost = !_isHost;
    return Container(
      color: _panel,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 92,
              height: 92,
              alignment: Alignment.center,
              decoration:
                  const BoxDecoration(shape: BoxShape.circle, color: _accent),
              child: Icon(
                  waitingForHost
                      ? Icons.school_outlined
                      : Icons.groups_outlined,
                  size: 40,
                  color: Colors.white),
            ),
            const SizedBox(height: 20),
            Text(
              waitingForHost
                  ? 'Waiting for ${_hostName()} to begin'
                  : 'You are live. Turn on your camera to begin.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16.5,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              waitingForHost
                  ? 'The session will start here. Your microphone is off until '
                      'the host invites you to speak.'
                  : '${_everyone.length - 1} ${_everyone.length == 2 ? "person is" : "people are"} here.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white54, fontSize: 13.5, height: 1.5),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _filmstrip(List<Participant> people) => SizedBox(
        height: 100,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: people.length,
          separatorBuilder: (_, _) => const SizedBox(width: 10),
          itemBuilder: (_, i) {
            final p = people[i];
            final t = _videoOf(p);
            return ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 78,
                height: 100,
                child: Stack(fit: StackFit.expand, children: [
                  Container(color: _panel),
                  if (t != null)
                    VideoTrackRenderer(t, fit: VideoViewFit.cover),
                  Positioned(
                    left: 4,
                    right: 4,
                    bottom: 4,
                    child: Text(_nameOf(p),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600)),
                  ),
                ]),
              ),
            );
          },
        ),
      );

  Widget _chip(String name, CallRole role) {
    final label = role.label;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5.5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(name,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 12.5,
                fontWeight: FontWeight.w600)),
        if (label.isNotEmpty) ...[
          const SizedBox(width: 6),
          Container(
              width: 3,
              height: 3,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.45))),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                  color: _accent, fontSize: 11.5, fontWeight: FontWeight.w700)),
        ],
      ]),
    );
  }

  Widget _topBar() => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 12, 0),
          child: Row(children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(widget.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2)),
                    const SizedBox(height: 4),
                    Row(children: [
                      Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _phase == _Phase.live ? _live : _waiting)),
                      const SizedBox(width: 7),
                      Text(
                        _isHost ? 'Hosting · $_clock' : 'Live · $_clock',
                        style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500),
                      ),
                    ]),
                  ]),
            ),
            // The count is the number a class needs and a grid of forty tiles
            // would only obscure. Tap for who.
            _roundSmall(
              Icons.people_alt_rounded,
              _openParticipants,
              badge: '${_everyone.length}',
            ),
            const SizedBox(width: 6),
            _roundSmall(
              Icons.forum_rounded,
              _openQuestions,
              badge: _unreadQuestions > 0 ? '$_unreadQuestions' : null,
              badgeHot: _unreadQuestions > 0,
            ),
          ]),
        ),
      );

  Widget _controls() => SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20, left: 14, right: 14),
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
                    border:
                        Border.all(color: Colors.white.withValues(alpha: 0.10)),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    // ATTENDEE CONTROLS ARE DIFFERENT CONTROLS, not greyed-out
                    // versions of the host's. Showing a mic button that cannot
                    // work would be an invitation to tap it and wonder.
                    if (_canPublish) ...[
                      _round(Icons.flip_camera_ios_rounded, _flipCamera),
                      _round(
                          _camOn
                              ? Icons.videocam_rounded
                              : Icons.videocam_off_rounded,
                          _toggleCam,
                          on: _camOn),
                      _round(_micOn ? Icons.mic_rounded : Icons.mic_off_rounded,
                          _toggleMic,
                          on: _micOn),
                    ] else
                      _round(
                        _handUp
                            ? Icons.back_hand_rounded
                            : Icons.back_hand_outlined,
                        _toggleHand,
                        on: !_handUp,
                      ),
                    _round(
                        _speakerOn
                            ? Icons.volume_up_rounded
                            : Icons.phone_in_talk_rounded,
                        _toggleSpeaker,
                        on: _speakerOn),
                    if (_isHost)
                      _round(Icons.mic_off_rounded, _busy ? null : _muteAll),
                    const SizedBox(width: 6),
                    Semantics(
                      button: true,
                      label: 'Leave session',
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
      );

  Widget _round(IconData icon, VoidCallback? onTap, {bool on = true}) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Opacity(
            opacity: onTap == null ? 0.5 : 1,
            child: Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: on ? Colors.white.withValues(alpha: 0.16) : Colors.white,
              ),
              child: Icon(icon,
                  size: 23,
                  color: on ? Colors.white : const Color(0xFF17151E)),
            ),
          ),
        ),
      );

  Widget _roundSmall(IconData icon, VoidCallback onTap,
          {String? badge, bool badgeHot = false}) =>
      GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 15, color: Colors.white),
            if (badge != null) ...[
              const SizedBox(width: 5),
              Text(badge,
                  style: TextStyle(
                      color: badgeHot ? _accent : Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
            ],
          ]),
        ),
      );

  Widget _pill(String label, VoidCallback onTap, {bool filled = false}) =>
      GestureDetector(
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
      );

  // ---- sheets ---------------------------------------------------------------

  void _openParticipants() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: _panel,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) {
          final people = _everyone;
          return SafeArea(
            top: false,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(ctx).size.height * 0.7),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                  child: Row(children: [
                    Text('In this session · ${people.length}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700)),
                    const Spacer(),
                    if (_isHost && people.length > 1)
                      TextButton(
                        onPressed: () async {
                          await _muteAll();
                          setSheet(() {});
                        },
                        child: const Text('Mute all',
                            style: TextStyle(color: _accent)),
                      ),
                  ]),
                ),
                Flexible(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 12),
                    itemCount: people.length,
                    itemBuilder: (_, i) =>
                        _participantRow(people[i], () => setSheet(() {})),
                  ),
                ),
              ]),
            ),
          );
        },
      ),
    );
  }

  Widget _participantRow(Participant p, VoidCallback rebuild) {
    final role = CallSession.roleFromMetadata(p.metadata);
    final isMe = p is LocalParticipant;
    final hand = _handsUp.contains(p.identity);
    final mayPublish = p.permissions.canPublish;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: role.isHost ? _accent : Colors.white24,
        child: Text(
          _nameOf(p).isNotEmpty ? _nameOf(p)[0].toUpperCase() : '?',
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
      title: Row(children: [
        Flexible(
          child: Text(_nameOf(p),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 14.5)),
        ),
        if (role.label.isNotEmpty) ...[
          const SizedBox(width: 8),
          Text(role.label,
              style: const TextStyle(
                  color: _accent, fontSize: 11, fontWeight: FontWeight.w700)),
        ],
        if (hand) ...[
          const SizedBox(width: 8),
          const Icon(Icons.back_hand_rounded, size: 14, color: _waiting),
        ],
      ]),
      subtitle: Text(
        mayPublish ? (_muted(p) ? 'Muted' : 'Speaking') : 'Listening',
        style: const TextStyle(color: Colors.white38, fontSize: 11.5),
      ),
      // Host actions live behind an explicit menu rather than on the row, so
      // removing someone is never one stray tap while scrolling a list of forty.
      trailing: (!_isHost || isMe)
          ? null
          : PopupMenuButton<String>(
              color: _panel,
              icon: const Icon(Icons.more_horiz_rounded, color: Colors.white54),
              onSelected: (v) async {
                switch (v) {
                  case 'allow':
                  case 'deny':
                    await CallModeration.setCanSpeak(
                        _slotId, p.identity,
                        allow: v == 'allow');
                  case 'remove':
                    await CallModeration.remove(_slotId, p.identity);
                }
                rebuild();
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: mayPublish ? 'deny' : 'allow',
                  child: Text(
                      mayPublish ? 'Mute and stop video' : 'Invite to speak',
                      style: const TextStyle(color: Colors.white)),
                ),
                const PopupMenuItem(
                  value: 'remove',
                  child: Text('Remove from session',
                      style: TextStyle(color: _danger)),
                ),
              ],
            ),
    );
  }

  void _openQuestions() {
    setState(() => _unreadQuestions = 0);
    final controller = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: _panel,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: StatefulBuilder(
          builder: (ctx, setSheet) => SafeArea(
            top: false,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(ctx).size.height * 0.7),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 18, 20, 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Questions',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
                Flexible(
                  child: _questions.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.fromLTRB(20, 20, 20, 30),
                          child: Text(
                            'No questions yet. Anything asked here goes to the '
                            'host and everyone in the session.',
                            style: TextStyle(
                                color: Colors.white54,
                                fontSize: 13,
                                height: 1.5),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 8),
                          itemCount: _questions.length,
                          itemBuilder: (_, i) {
                            final q = _questions[i];
                            return ListTile(
                              dense: true,
                              title: Text(q.who,
                                  style: const TextStyle(
                                      color: _accent,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700)),
                              subtitle: Text(q.text,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13.5,
                                      height: 1.4)),
                            );
                          },
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                  child: Row(children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        style: const TextStyle(color: Colors.white),
                        minLines: 1,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Ask a question…',
                          hintStyle: const TextStyle(color: Colors.white38),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.08),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send_rounded, color: _accent),
                      onPressed: () async {
                        final text = controller.text.trim();
                        if (text.isEmpty) return;
                        controller.clear();
                        await _send({'t': _Wire.question, 'text': text});
                        // Our own data messages do not come back to us, so the
                        // sender has to add their own or the list would look
                        // like it swallowed the question.
                        setState(() => _questions
                            .add(_Question('You', text, DateTime.now())));
                        setSheet(() {});
                      },
                    ),
                  ]),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
