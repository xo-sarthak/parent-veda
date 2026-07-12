// =============================================================================
//  My Journal V2 - "Email to your child" (pre-filled draft composer)
// -----------------------------------------------------------------------------
//  A tiny sheet that asks only for the child's email address, then opens the
//  device mail composer with the subject + body ALREADY written from the memory
//  or letter. The mother never retypes anything - she just presses send.
//
//  Uses url_launcher (already a dependency, reused from products) via a mailto:
//  URI. If no mail app is available (or in tests) it falls back to a graceful
//  snackbar and never crashes.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'jv2_common.dart';
import 'jv2_data.dart';

/// The subject line for a shared memory / letter.
String jvEmailSubject(JvMemory m) => 'A memory from $jvParent: ${m.title}';

/// The pre-filled email body composed from a memory / letter. Letters already
/// carry their own sign-off, so we only append the warm closing for memories.
String jvEmailBody(JvMemory m) {
  final isLetter = m.kind == JvKind.letter;
  final header = '${m.title}\n${m.date} · ${m.age}\n\n';
  final closing = isLetter ? '' : '\n\nWith all my love,\n$jvParent';
  return '$header${m.body}$closing';
}

/// Builds the mailto: URI with an (optional) recipient and the pre-filled
/// subject + body, correctly percent-encoded (spaces -> %20, newlines -> %0A).
Uri jvMailtoUri(JvMemory m, {String recipient = ''}) {
  final subject = Uri.encodeComponent(jvEmailSubject(m));
  final body = Uri.encodeComponent(jvEmailBody(m));
  return Uri.parse('mailto:$recipient?subject=$subject&body=$body');
}

/// Opens a tiny sheet asking for the child's email, then launches the device
/// mail composer with the draft pre-filled. Safe to call from any screen.
void emailMemoryToChild(BuildContext context, JvMemory m) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: ppBg,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    builder: (ctx) => _EmailSheet(memory: m),
  );
}

class _EmailSheet extends StatefulWidget {
  const _EmailSheet({required this.memory});
  final JvMemory memory;

  @override
  State<_EmailSheet> createState() => _EmailSheetState();
}

class _EmailSheetState extends State<_EmailSheet> {
  final _email = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_sending) return;
    setState(() => _sending = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final uri = jvMailtoUri(widget.memory, recipient: _email.text.trim());
    var launched = false;
    try {
      launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      launched = false;
    }
    if (!mounted) return;
    navigator.pop();
    messenger.showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text(launched
          ? 'Opening your mail app - the letter is ready to send.'
          : 'Could not open a mail app on this device. Draft saved for now.'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.memory;
    final isLetter = m.kind == JvKind.letter;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 10),
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: ppLine, borderRadius: BorderRadius.circular(999)))),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Row(children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: jvPaper, shape: BoxShape.circle, border: Border.all(color: jvPaperLine)),
                  child: const Icon(Icons.mark_email_read_outlined, size: 19, color: ppPurple),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Email to $jvChild', style: ppFraunces(22, h: 1.1)),
                    const SizedBox(height: 2),
                    Text(isLetter ? 'For them to read one day' : 'Share this memory with them', style: ppBody(12, color: ppMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ]),
                ),
              ]),
              const SizedBox(height: 18),
              // preview of the pre-filled draft, so she can see it's ready
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: jvPaper, borderRadius: BorderRadius.circular(16), border: Border.all(color: jvPaperLine)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(jvEmailSubject(m), style: ppBody(13, color: ppInk, w: FontWeight.w700), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Text(m.body, style: ppFraunces(13, color: ppSoft, h: 1.6).copyWith(fontStyle: FontStyle.italic), maxLines: 3, overflow: TextOverflow.ellipsis),
                ]),
              ),
              const SizedBox(height: 16),
              Text("Your child's email", style: ppBody(12, color: ppMuted, w: FontWeight.w600)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: ppLine)),
                child: TextField(
                  controller: _email,
                  autofocus: true,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _send(),
                  style: ppBody(14, color: ppInk),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    filled: false,
                    hintText: 'name@email.com',
                    hintStyle: ppBody(14, color: ppMuted),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text('We only open your mail app - the note is already written. You can leave the address blank and fill it in there.',
                  style: ppBody(11, color: ppMuted, h: 1.5)),
              const SizedBox(height: 18),
              jvButton(_sending ? 'Opening…' : 'Open mail draft', _send, trailing: Icons.send_rounded),
            ]),
          ),
        ]),
      ),
    );
  }
}
