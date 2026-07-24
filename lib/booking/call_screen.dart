// =============================================================================
//  CallScreen — the in-app live video call (LiveKit)
// -----------------------------------------------------------------------------
//  Opens when a mother taps "Join now" on a booking in its join window. It asks
//  the livekit-token edge function for a token (which verifies she holds the
//  booking), connects to the room, turns on her camera + mic, and renders every
//  participant's video with mute / camera / leave controls.
//
//  The room is derived from the booking's slot server-side, so she and the
//  expert of the same session land in the same room automatically — no link to
//  share. This is what turns the old "Link coming" placeholder into a real call.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';

import '../services/remote/supabase_repo.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({super.key, required this.bookingId, required this.title});

  final String bookingId;
  final String title;

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  Room? _room;
  bool _connecting = true;
  String? _error;
  bool _micOn = true;
  bool _camOn = true;

  @override
  void initState() {
    super.initState();
    _connect();
  }

  Future<void> _connect() async {
    try {
      final res = await SupabaseRepo.invokeEdge(
          'livekit-token', {'bookingId': widget.bookingId});
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
    } catch (e) {
      if (mounted) {
        setState(() {
          _connecting = false;
          _error = 'Something went wrong joining the call.';
        });
      }
    }
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<void> _leave() async {
    final r = _room;
    _room = null;
    r?.removeListener(_refresh);
    await r?.disconnect();
    await r?.dispose();
    if (mounted) Navigator.of(context).maybePop();
  }

  @override
  void dispose() {
    final r = _room;
    r?.removeListener(_refresh);
    r?.disconnect();
    r?.dispose();
    super.dispose();
  }

  List<Participant> get _participants {
    final r = _room;
    if (r == null) return const [];
    return [
      if (r.localParticipant != null) r.localParticipant!,
      ...r.remoteParticipants.values,
    ];
  }

  VideoTrack? _videoOf(Participant p) {
    for (final pub in p.videoTrackPublications) {
      final t = pub.track;
      if (t is VideoTrack && !pub.muted) return t;
    }
    return null;
  }

  Future<void> _toggleMic() async {
    _micOn = !_micOn;
    await _room?.localParticipant?.setMicrophoneEnabled(_micOn);
    _refresh();
  }

  Future<void> _toggleCam() async {
    _camOn = !_camOn;
    await _room?.localParticipant?.setCameraEnabled(_camOn);
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111015),
      body: SafeArea(
        child: _connecting
            ? _status('Joining ${widget.title}…', spinner: true)
            : _error != null
                ? _status(_error!)
                : _callView(),
      ),
    );
  }

  Widget _status(String msg, {bool spinner = false}) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            if (spinner) ...[
              const CircularProgressIndicator(color: Colors.white70),
              const SizedBox(height: 20),
            ],
            Text(msg,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white70, fontSize: 15, height: 1.5)),
            if (!spinner) ...[
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12)),
                  child: const Text('Close',
                      style: TextStyle(color: Colors.white, fontSize: 14)),
                ),
              ),
            ],
          ]),
        ),
      );

  Widget _callView() {
    final people = _participants;
    return Stack(children: [
      // Video grid.
      Padding(
        padding: const EdgeInsets.all(8),
        child: GridView.count(
          crossAxisCount: people.length <= 1 ? 1 : 2,
          childAspectRatio: 0.75,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: [for (final p in people) _tile(p)],
        ),
      ),
      // Controls.
      Positioned(
        left: 0,
        right: 0,
        bottom: 24,
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _ctrl(_micOn ? Icons.mic_rounded : Icons.mic_off_rounded, _toggleMic,
              on: _micOn),
          const SizedBox(width: 18),
          _ctrl(_camOn ? Icons.videocam_rounded : Icons.videocam_off_rounded,
              _toggleCam,
              on: _camOn),
          const SizedBox(width: 18),
          _ctrl(Icons.call_end_rounded, _leave, danger: true),
        ]),
      ),
    ]);
  }

  Widget _tile(Participant p) {
    final track = _videoOf(p);
    final name = p.name.isNotEmpty ? p.name : 'Guest';
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        color: const Color(0xFF1E1C24),
        child: Stack(fit: StackFit.expand, children: [
          if (track != null)
            VideoTrackRenderer(track)
          else
            Center(
              child: CircleAvatar(
                radius: 34,
                backgroundColor: const Color(0xFF6A30B6),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white, fontSize: 26),
                ),
              ),
            ),
          Positioned(
            left: 10,
            bottom: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(8)),
              child: Text(name,
                  style: const TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _ctrl(IconData icon, VoidCallback onTap,
          {bool on = true, bool danger = false}) =>
      GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 58,
          height: 58,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: danger
                ? const Color(0xFFE5484D)
                : on
                    ? Colors.white.withValues(alpha: 0.16)
                    : Colors.white,
          ),
          child: Icon(icon,
              size: 26,
              color: danger || on ? Colors.white : Colors.black),
        ),
      );
}
