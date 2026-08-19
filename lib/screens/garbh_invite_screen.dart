// =============================================================================
//  Invite someone to record - the mother's half
// -----------------------------------------------------------------------------
//  ⚠️ THIS IS HALF OF A TWO-HALF FEATURE, AND THE OTHER HALF IS NOT IN THIS
//  REPO. Read this before assuming the flow works end to end.
//
//  The spec's growth loop: she invites a family member, they open a link in a
//  mobile browser, record from their own phone with no login and no install,
//  and it lands in her journal tagged with the relationship she chose.
//
//  What exists here          | What does not exist yet
//  --------------------------|--------------------------------------------
//  Choosing who              | parentveda.in/record/{token} - a web app
//  Naming an unlisted person | server-side token -> account mapping
//  Sharing through the OS    | audio upload and storage
//  A journal that can hold   | the notification when one arrives
//  a family recording        |
//
//  ⚠️ SO THE LINK IS HONEST ABOUT NOT WORKING YET, rather than generated and
//  shared as though it does. Sending a mother's mother-in-law a dead link is
//  a worse outcome than not offering the button: she does not get told it
//  failed, she gets told nothing, and the mother finds out days later when no
//  recording has arrived.
//
//  ⚠️ AND THE RELATIONSHIP LIST IS OPEN, NOT FIXED. The spec is explicit and
//  it is right: six suggestions plus "someone else", where she types her own
//  word. Anyone whose voice she wants her baby to know should be invitable,
//  and a closed list decides that for her - which fails first for exactly the
//  families whose shape is least standard.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../theme/pv_fonts.dart';

const _ink = Color(0xFF2E2A32);
const _muted = Color(0xFF8A8290);
const _cream = Color(0xFFFBF9F6);
const _accent = Color(0xFFB98A7E);

/// The six the spec names, as suggestions only.
const List<String> kInviteSuggestions = [
  'Papa',
  'Dadi',
  'Nana',
  'Nani',
  'Bua',
  'Mausi',
  'Bhai',
  'Behen',
];

class GarbhInviteScreen extends StatefulWidget {
  const GarbhInviteScreen({super.key});

  @override
  State<GarbhInviteScreen> createState() => _GarbhInviteScreenState();
}

class _GarbhInviteScreenState extends State<GarbhInviteScreen> {
  String? _picked;
  final _other = TextEditingController();

  @override
  void dispose() {
    _other.dispose();
    super.dispose();
  }

  String? get _label {
    if (_picked == 'other') {
      final t = _other.text.trim();
      return t.isEmpty ? null : t;
    }
    return _picked;
  }

  Future<void> _share() async {
    final who = _label;
    if (who == null) return;

    // ⚠️ NO TOKEN IS MINTED HERE, AND NONE IS FAKED. A token has to map
    // server-side to her account and to this specific invite; generating a
    // plausible-looking string on the phone would produce a URL that 404s for
    // whoever she sends it to. See the header.
    // `Share.share` is the API this repo already uses (memory_export.dart,
    // bump_book_screen.dart). Same version, one way to share.
    await Share.share(
      'I am recording things for our baby to hear before they arrive. '
      'Would you record something as $who? ParentVeda will send you a link '
      'as soon as this is ready.',
      subject: 'Record something for the baby',
    );
  }

  @override
  Widget build(BuildContext context) {
    final ready = _label != null;

    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        backgroundColor: _cream,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: _ink,
        title: Text('Invite someone to record',
            style: pvFraunces(
                fontSize: 17, fontWeight: FontWeight.w600, color: _ink)),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 40),
          children: [
            Text('Whose voice should your baby know?',
                style: pvFraunces(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                    color: _ink)),
            const SizedBox(height: 8),
            Text(
                'They record from their own phone. No app to install, no '
                'account to make.',
                style: pvManrope(fontSize: 13.5, height: 1.55, color: _muted)),
            const SizedBox(height: 24),

            Wrap(
              spacing: 9,
              runSpacing: 9,
              children: [
                for (final w in kInviteSuggestions)
                  _Chip(
                      label: w,
                      on: _picked == w,
                      onTap: () => setState(() => _picked = w)),
                _Chip(
                    label: 'Someone else',
                    on: _picked == 'other',
                    onTap: () => setState(() => _picked = 'other')),
              ],
            ),

            if (_picked == 'other') ...[
              const SizedBox(height: 16),
              TextField(
                controller: _other,
                onChanged: (_) => setState(() {}),
                textCapitalization: TextCapitalization.words,
                style: pvManrope(fontSize: 15, color: _ink),
                decoration: InputDecoration(
                  // ⚠️ HER WORD, NOT OURS. The hint suggests rather than
                  // constrains, because the whole reason this field exists is
                  // that the list above cannot cover every family.
                  hintText: 'What do you call them?',
                  hintStyle: pvManrope(fontSize: 14.5, color: _muted),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0x22000000)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0x22000000)),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 26),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: ready ? _share : null,
                style: FilledButton.styleFrom(
                  backgroundColor: _accent,
                  disabledBackgroundColor: const Color(0x14000000),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.share_rounded,
                    size: 19, color: Colors.white),
                label: Text('Ask ${_label ?? 'them'}',
                    style: pvManrope(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
            ),

            const SizedBox(height: 20),
            // ⚠️ SAID PLAINLY, ON THE SCREEN, NOT ONLY IN A CODE COMMENT.
            // The recorder is not live, and a mother who shares this needs to
            // know that before her mother-in-law is waiting for a link.
            Container(
              padding: const EdgeInsets.fromLTRB(15, 13, 15, 14),
              decoration: BoxDecoration(
                color: const Color(0x0D000000),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                  'The recording page is still being built. For now this '
                  'sends them a message so they know it is coming, and we '
                  'will send you the link to pass on the moment it is ready.',
                  style: pvManrope(fontSize: 12.5, height: 1.55, color: _ink)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.on, required this.onTap});
  final String label;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
            color: on ? _accent : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border:
                Border.all(color: on ? _accent : const Color(0x22000000)),
          ),
          child: Text(label,
              style: pvManrope(
                  fontSize: 13.5,
                  fontWeight: on ? FontWeight.w800 : FontWeight.w600,
                  color: on ? Colors.white : _ink)),
        ),
      );
}
