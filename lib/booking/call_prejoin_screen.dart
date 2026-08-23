// =============================================================================
//  CallPrejoinScreen — the green room before a 1:1 consultation
// -----------------------------------------------------------------------------
//  WHAT WAS WRONG. Tapping "Join now" put you straight into the room: connected,
//  camera on, live in front of your doctor. No preview, no mic check, no chance
//  to join with the camera off. Every professional video product puts a room
//  before the room, and a paid medical consultation is the last place to skip
//  it — the person joining is often anxious, often somewhere they would rather
//  not be seen, and has no idea whether the app is even working until they are
//  already on air.
//
//  Three jobs, and each one fixes a specific defect:
//
//  1. ASK FOR THE CAMERA AND MICROPHONE HERE.
//     They used to be requested inside the same `try` as room.connect(), so a
//     denied permission surfaced as "Something went wrong joining the call."
//     with no explanation and no way back. A permission question deserves a
//     screen where the answer can be explained and Settings is one tap away.
//
//  2. SHOW THE REFUSAL BEFORE THE BLACK SCREEN.
//     The token is fetched here, so "your consultation opens at 4:50 PM" and
//     "this session is not yours" are answered on a screen that can say so,
//     rather than after a spinner in an empty dark room.
//
//  3. LET HER SEE HERSELF FIRST, and decide what the doctor sees.
//
//  CONSULTS ONLY. Group sessions never reach this screen — they keep the
//  straight-to-room path they have always had. See CallJoin.isConsult.
// -----------------------------------------------------------------------------
//  ONE LIFECYCLE TRAP WORTH KNOWING. The preview needs its own camera track,
//  because there is no Room yet to own one. A camera is a single-consumer
//  device: if this track is still running when LiveKit tries to publish its
//  own, the publish fails or returns a black frame — on some Android devices
//  silently. So the preview track is stopped and disposed BEFORE navigating on,
//  in every exit path including the back button.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:permission_handler/permission_handler.dart';

import '../theme/app_theme.dart';
import '../widgets/global_ask_fab.dart' show kCallRoute;
import 'booking_models.dart';
import 'call_screen.dart';
import 'call_session.dart';
import 'group_call_screen.dart';

const _bg = Color(0xFF0E0D12);
const _panel = Color(0xFF17151E);
const _accent = AppTheme.primary;
const _danger = Color(0xFFE5484D);

class CallPrejoinScreen extends StatefulWidget {
  const CallPrejoinScreen({
    super.key,
    required this.bookingId,
    required this.title,
    this.displayName,
    this.waitingFor,
    this.startsUtc,
    this.hostSlot,
  });

  final String bookingId;
  final String title;

  /// Set when this is a HOST opening their own class.
  ///
  /// A host holds no booking, so there is no booking id to fetch a token with —
  /// the slot descriptor goes instead, and `open_session_room` (0079) seeds the
  /// slot if the class has no bookings yet. Everything else on this screen is
  /// identical, and deliberately so: a teacher about to appear in front of
  /// forty people wants the camera check at least as much as a doctor does.
  final Slot? hostSlot;

  /// The name the other side sees. A LABEL, never a credential — identity is
  /// the `sub` claim, which the server sets from the verified session.
  final String? displayName;

  /// Who this call is with, for the copy. A name, not a role.
  final String? waitingFor;

  /// When the appointment is, so the screen can say "starts in 6 minutes"
  /// rather than making her work it out.
  final DateTime? startsUtc;

  @override
  State<CallPrejoinScreen> createState() => _CallPrejoinScreenState();
}

enum _Stage { checking, needsPermission, ready, refused }

class _CallPrejoinScreenState extends State<CallPrejoinScreen> {
  _Stage _stage = _Stage.checking;

  LocalVideoTrack? _preview;
  bool _camOn = true;
  bool _micOn = true;

  /// True once the OS has refused permanently — the in-app prompt will not
  /// appear again and the only route is Settings. Saying "allow access" to
  /// someone who cannot is worse than saying nothing.
  bool _permanentlyDenied = false;

  CallJoin? _join;
  CallJoinFailure? _failure;
  bool _joining = false;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  @override
  void dispose() {
    _disposePreview();
    super.dispose();
  }

  Future<void> _disposePreview() async {
    final t = _preview;
    _preview = null;
    if (t == null) return;
    try {
      await t.stop();
      await t.dispose();
    } catch (e) {
      debugPrint('[prejoin] preview teardown: $e');
    }
  }

  // ---- preparation ----------------------------------------------------------

  Future<void> _prepare() async {
    setState(() => _stage = _Stage.checking);

    // Ask for both up front. A consultation needs both; asking for the camera
    // now and the microphone thirty seconds later, mid-call, is two
    // interruptions for one decision.
    final results = await [Permission.camera, Permission.microphone].request();
    final cam = results[Permission.camera] ?? PermissionStatus.denied;
    final mic = results[Permission.microphone] ?? PermissionStatus.denied;

    if (!mounted) return;

    if (!cam.isGranted || !mic.isGranted) {
      setState(() {
        _permanentlyDenied = cam.isPermanentlyDenied || mic.isPermanentlyDenied;
        _stage = _Stage.needsPermission;
      });
      return;
    }

    // Fetch the token BEFORE showing a Join button. If the session has not
    // opened yet, or is not this caller's, that is the whole answer and there
    // is no point previewing a camera for a call that cannot happen.
    final slot = widget.hostSlot;
    final (join, failure) = slot != null
        ? await CallSession.fetchHostJoin(
            slot: slot, displayName: widget.displayName)
        : await CallSession.fetchJoin(
            bookingId: widget.bookingId,
            displayName: widget.displayName,
          );
    if (!mounted) return;

    if (failure != null) {
      setState(() {
        _failure = failure;
        _stage = _Stage.refused;
      });
      return;
    }

    await _startPreview();
    if (!mounted) return;
    setState(() {
      _join = join;
      _stage = _Stage.ready;
    });
  }

  Future<void> _startPreview() async {
    try {
      final t = await LocalVideoTrack.createCameraTrack(
        const CameraCaptureOptions(cameraPosition: CameraPosition.front),
      );
      if (!mounted) {
        await t.stop();
        await t.dispose();
        return;
      }
      setState(() => _preview = t);
    } catch (e) {
      // A camera that will not open is not a reason to block the call — audio
      // consultations are real. Fall through with the toggle off and say so.
      debugPrint('[prejoin] camera preview failed: $e');
      if (mounted) setState(() => _camOn = false);
    }
  }

  Future<void> _toggleCam() async {
    final next = !_camOn;
    setState(() => _camOn = next);
    if (next) {
      await _startPreview();
    } else {
      await _disposePreview();
      if (mounted) setState(() {});
    }
  }

  // ---- go -------------------------------------------------------------------

  Future<void> _join_() async {
    final join = _join;
    if (join == null || _joining) return;
    setState(() => _joining = true);

    // Release the camera before the room asks for it. See the header note.
    await _disposePreview();
    if (!mounted) return;

    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        settings: const RouteSettings(name: kCallRoute),
        // A class and a consult are different rooms with different rules, so
        // they are different screens. The server has already said which this
        // is — capacity — and the client does not get a second opinion.
        builder: (_) => join.isGroup
            ? GroupCallScreen(
                title: widget.title,
                join: join,
                hostName: widget.waitingFor,
              )
            : CallScreen(
                bookingId: widget.bookingId,
                title: widget.title,
                displayName: widget.displayName,
                waitingFor: widget.waitingFor,
                join: join,
                startCameraOn: _camOn,
                startMicOn: _micOn,
              ),
      ),
    );
  }

  // ---- build ----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (_, _) => _disposePreview(),
      child: Scaffold(
        backgroundColor: _bg,
        body: SafeArea(
          child: switch (_stage) {
            _Stage.checking => _centred(
                const CircularProgressIndicator(
                    strokeWidth: 2.4, color: _accent),
                'Getting your camera ready…',
              ),
            _Stage.needsPermission => _permissionView(),
            _Stage.refused => _refusalView(),
            _Stage.ready => _readyView(),
          },
        ),
      ),
    );
  }

  Widget _centred(Widget top, String msg) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            SizedBox(width: 30, height: 30, child: top),
            const SizedBox(height: 22),
            Text(msg,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white70, fontSize: 15, height: 1.55)),
          ]),
        ),
      );

  Widget _permissionView() => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.videocam_off_rounded,
                size: 44, color: Colors.white38),
            const SizedBox(height: 20),
            const Text(
              'ParentVeda needs your camera and microphone',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Text(
              _permanentlyDenied
                  ? 'They are turned off for ParentVeda. Open Settings to allow '
                      'them, then come back to this screen.'
                  : 'They are only used during a live consultation, and only '
                      'while you are on the call.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white54, fontSize: 13.5, height: 1.55),
            ),
            const SizedBox(height: 26),
            _wideButton(
              _permanentlyDenied ? 'Open Settings' : 'Allow access',
              () async {
                if (_permanentlyDenied) {
                  await openAppSettings();
                } else {
                  await _prepare();
                }
              },
            ),
            const SizedBox(height: 12),
            _quietButton('Not now', () => Navigator.of(context).maybePop()),
          ]),
        ),
      );

  /// The server said no, and said WHY. Each reason gets its own sentence and
  /// its own button — the whole point of keeping the refusal body.
  Widget _refusalView() {
    final f = _failure!;
    final (title, body) = switch (f.kind) {
      CallRefusal.tooEarly => (
          'This consultation has not opened yet',
          f.opensUtc != null
              ? 'You can join from ${_clock(f.opensUtc!)}, ten minutes before '
                  'it starts. We will remind you.'
              : 'You can join ten minutes before it starts. We will remind you.',
        ),
      CallRefusal.ended => (
          'This consultation has ended',
          'The room is closed. If you still need to speak to someone, you can '
              'book a follow-up from My Bookings.',
        ),
      CallRefusal.notYours => (
          'This session is not available',
          'It may have been cancelled, or it belongs to a different account. '
              'Check My Bookings, or sign in as the account that booked it.',
        ),
      CallRefusal.notSignedIn => (
          'Please sign in',
          'You need to be signed in as the account that booked this session.',
        ),
      CallRefusal.offline => (
          'You appear to be offline',
          'A video consultation needs a working connection. Check your network '
              'and try again.',
        ),
      CallRefusal.serverError => (
          'We could not open this session',
          'Something went wrong on our side, not yours. Please try again in a '
              'moment.',
        ),
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(
            f.kind == CallRefusal.tooEarly
                ? Icons.schedule_rounded
                : Icons.info_outline_rounded,
            size: 42,
            color: Colors.white38,
          ),
          const SizedBox(height: 20),
          Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Text(body,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white54, fontSize: 13.5, height: 1.55)),
          const SizedBox(height: 26),
          if (f.retryable) ...[
            _wideButton('Try again', _prepare),
            const SizedBox(height: 12),
          ],
          _quietButton('Back', () => Navigator.of(context).maybePop()),
        ]),
      ),
    );
  }

  Widget _readyView() {
    final hosting = widget.hostSlot != null;
    final who = (widget.waitingFor?.trim().isNotEmpty ?? false)
        ? widget.waitingFor!.trim()
        : (_join?.counterpart.trim().isNotEmpty ?? false)
            ? _join!.counterpart.trim()
            : 'your consultation';

    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
        child: Row(children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.arrow_back_rounded,
                  color: Colors.white70, size: 22),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text('Ready to join',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16.5,
                    fontWeight: FontWeight.w700)),
          ),
        ]),
      ),

      // The preview. Big, because checking your own framing is the entire
      // reason this screen exists.
      Expanded(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Container(
              color: _panel,
              width: double.infinity,
              child: _preview != null && _camOn
                  ? VideoTrackRenderer(_preview!, fit: VideoViewFit.cover)
                  : Center(
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.videocam_off_rounded,
                                color: Colors.white38, size: 30),
                            SizedBox(height: 12),
                            Text('Your camera is off',
                                style: TextStyle(
                                    color: Colors.white54, fontSize: 13.5)),
                          ]),
                    ),
            ),
          ),
        ),
      ),

      Padding(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
        child: Column(children: [
          Text(hosting ? 'You are hosting $who' : 'You are joining $who',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white, fontSize: 15.5, fontWeight: FontWeight.w600)),
          if (_startsIn() != null) ...[
            const SizedBox(height: 5),
            Text(_startsIn()!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white54, fontSize: 12.5)),
          ],
        ]),
      ),

      // The two decisions that must be made BEFORE the door opens, not after.
      Padding(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 10),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _toggle(
            icon: _micOn ? Icons.mic_rounded : Icons.mic_off_rounded,
            on: _micOn,
            label: _micOn ? 'Mic on' : 'Mic off',
            onTap: () => setState(() => _micOn = !_micOn),
          ),
          const SizedBox(width: 26),
          _toggle(
            icon: _camOn ? Icons.videocam_rounded : Icons.videocam_off_rounded,
            on: _camOn,
            label: _camOn ? 'Camera on' : 'Camera off',
            onTap: _toggleCam,
          ),
        ]),
      ),

      Padding(
        padding: const EdgeInsets.fromLTRB(24, 6, 24, 22),
        child: _wideButton(
            _joining
                ? (hosting ? 'Starting…' : 'Joining…')
                : (hosting ? 'Start session' : 'Join now'),
            _joining ? null : _join_),
      ),
    ]);
  }

  Widget _toggle({
    required IconData icon,
    required bool on,
    required String label,
    required VoidCallback onTap,
  }) =>
      Semantics(
        button: true,
        label: label,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: on ? Colors.white.withValues(alpha: 0.16) : _danger,
              ),
              child: Icon(icon, size: 24, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(label,
                style: const TextStyle(color: Colors.white54, fontSize: 11.5)),
          ]),
        ),
      );

  Widget _wideButton(String label, VoidCallback? onTap) => Semantics(
        button: true,
        label: label,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Opacity(
            opacity: onTap == null ? 0.6 : 1,
            child: Container(
              height: 52,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: _accent, borderRadius: BorderRadius.circular(15)),
              child: Text(label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700)),
            ),
          ),
        ),
      );

  Widget _quietButton(String label, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Text(label,
              style: const TextStyle(color: Colors.white54, fontSize: 13.5)),
        ),
      );

  String? _startsIn() {
    final s = widget.startsUtc ?? _join?.startsUtc;
    if (s == null) return null;
    final diff = s.difference(DateTime.now().toUtc());
    if (diff.isNegative) return 'Started ${_ago(-diff)} ago';
    if (diff.inMinutes < 1) return 'Starting now';
    if (diff.inMinutes == 1) return 'Starts in 1 minute';
    if (diff.inMinutes < 60) return 'Starts in ${diff.inMinutes} minutes';
    return 'Starts at ${_clock(s)}';
  }

  String _ago(Duration d) =>
      d.inMinutes < 1 ? 'a moment' : '${d.inMinutes} min';

  String _clock(DateTime utc) {
    final d = utc.toLocal();
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final m = d.minute.toString().padLeft(2, '0');
    return '$h:$m ${d.hour < 12 ? 'AM' : 'PM'}';
  }
}
