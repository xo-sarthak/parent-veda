// =============================================================================
//  MicDictateButton — tap-to-dictate speech into any TextField
// -----------------------------------------------------------------------------
//  A small mic icon that appends recognized speech to a [TextEditingController].
//  Tap to start listening (mic turns coral), tap again to stop. Self-contained;
//  uses the on-device speech recognizer (speech_to_text). Permission denial is
//  handled gracefully with a snackbar.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../localization/app_language.dart';
import '../theme/app_theme.dart';

class MicDictateButton extends StatefulWidget {
  const MicDictateButton({
    super.key,
    required this.controller,
    required this.s,
    this.color,
  });

  final TextEditingController controller;
  final S s;
  final Color? color;

  @override
  State<MicDictateButton> createState() => _MicDictateButtonState();
}

class _MicDictateButtonState extends State<MicDictateButton> {
  final SpeechToText _speech = SpeechToText();
  bool _listening = false;
  String _base = '';

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_listening) {
      await _speech.stop();
      if (mounted) setState(() => _listening = false);
      return;
    }
    var ok = false;
    try {
      ok = await _speech.initialize(
        onStatus: (st) {
          if ((st == 'done' || st == 'notListening') && mounted) {
            setState(() => _listening = false);
          }
        },
        onError: (_) {
          if (mounted) setState(() => _listening = false);
        },
      );
    } catch (_) {
      ok = false;
    }
    if (!ok) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(widget.s.micDenied)));
      }
      return;
    }
    _base = widget.controller.text;
    if (mounted) setState(() => _listening = true);
    await _speech.listen(
      onResult: (r) {
        final words = r.recognizedWords;
        if (words.isEmpty) return;
        final sep = _base.isEmpty ? '' : ' ';
        final text = '$_base$sep$words';
        widget.controller.value = TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.color ?? AppTheme.primary500;
    return IconButton(
      visualDensity: VisualDensity.compact,
      tooltip: _listening ? widget.s.micListening : widget.s.micTap,
      icon: Icon(
        _listening ? Icons.mic_rounded : Icons.mic_none_rounded,
        color: _listening ? AppTheme.secondary500 : c,
        size: 22,
      ),
      onPressed: _toggle,
    );
  }
}
