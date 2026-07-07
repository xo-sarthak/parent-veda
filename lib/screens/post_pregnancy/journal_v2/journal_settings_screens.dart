// =============================================================================
//  My Journal V2 - library, hardcover customization, print & settings
// =============================================================================

import 'package:flutter/material.dart';

import 'journal_storybook_screens.dart';
import 'jv2_common.dart';
import 'jv2_data.dart';

void _snack(BuildContext c, String m) =>
    ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(m), behavior: SnackBarBehavior.floating));

// ---- Storybook Library ------------------------------------------------------
class StorybookLibraryScreen extends StatelessWidget {
  const StorybookLibraryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: ListView(
        padding: const EdgeInsets.only(top: 58, bottom: 30),
        children: [
          jvPad(jvTopBar(context, title: 'Storybooks')),
          const SizedBox(height: 18),
          jvPad(GestureDetector(
            onTap: () => _snack(context, 'New storybook - coming soon'),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(20)),
              child: Row(children: [
                Container(width: 42, height: 42, alignment: Alignment.center, decoration: const BoxDecoration(color: ppPurple, shape: BoxShape.circle), child: const Icon(Icons.add, size: 22, color: Colors.white)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Create a new book', style: ppJakarta(15)),
                    const SizedBox(height: 2),
                    Text('A year, a theme, or letters', style: ppBody(12)),
                  ]),
                ),
              ]),
            ),
          )),
          const SizedBox(height: 24),
          jvPad(Text('Your storybooks', style: ppJakarta(14, color: ppMuted))),
          const SizedBox(height: 8),
          for (final b in jvStorybooks)
            jvPad(GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => StorybookScreen(book: b))),
              behavior: HitTestBehavior.opaque,
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: ppHair)),
                child: Row(children: [
                  JvBookCover(width: 54, height: 74, title: b.title.toUpperCase()),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(b.title, style: ppJakarta(16)),
                      const SizedBox(height: 3),
                      Text(b.years, style: ppBody(12, color: ppMuted)),
                      const SizedBox(height: 2),
                      Text(b.detail, style: ppBody(12, color: ppPurple, w: FontWeight.w600)),
                    ]),
                  ),
                  const Icon(Icons.chevron_right_rounded, size: 20, color: ppMuted),
                ]),
              ),
            )),
        ],
      ),
    );
  }
}

// ---- Hardcover Customization ------------------------------------------------
class HardcoverCustomizationScreen extends StatefulWidget {
  const HardcoverCustomizationScreen({super.key});
  @override
  State<HardcoverCustomizationScreen> createState() => _HardcoverCustomizationScreenState();
}

class _HardcoverCustomizationScreenState extends State<HardcoverCustomizationScreen> {
  int _color = 0;
  int _image = 0;
  static const _covers = [Color(0xFF4A3A6B), Color(0xFF6A30B6), Color(0xFF3B4A66), Color(0xFFB4532F)];

  final _title = TextEditingController(text: 'Our Story');
  final _subtitle = TextEditingController(text: "$jvChild's Journey");
  final _dedication = TextEditingController(text: 'For you, my little one.');

  @override
  void dispose() {
    _title.dispose();
    _subtitle.dispose();
    _dedication.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: ListView(
        padding: const EdgeInsets.only(top: 58, bottom: 40),
        children: [
          jvPad(jvTopBar(context, title: 'Customize Your Book')),
          const SizedBox(height: 22),
          // preview
          Center(
            child: Container(
              width: 168,
              height: 224,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [_covers[_color], Color.lerp(_covers[_color], Colors.black, 0.25)!]),
                boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 28, spreadRadius: -8, offset: Offset(0, 16))],
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(width: 62, height: 62, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: jvGold, width: 2)), clipBehavior: Clip.antiAlias, child: JvPhoto(seed: _image)),
                const SizedBox(height: 16),
                Text('OUR STORY', style: ppFraunces(17, color: const Color(0xFFF3ECDD))),
                const SizedBox(height: 6),
                Text('AARAV', style: ppBody(12, color: jvGold, w: FontWeight.w700).copyWith(letterSpacing: 2)),
              ]),
            ),
          ),
          const SizedBox(height: 28),
          jvPad(Text('Cover colour', style: ppJakarta(14))),
          const SizedBox(height: 12),
          jvPad(Row(children: [
            for (var i = 0; i < _covers.length; i++)
              GestureDetector(
                onTap: () => setState(() => _color = i),
                child: Container(
                  margin: const EdgeInsets.only(right: 14),
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(color: _covers[i], shape: BoxShape.circle, border: Border.all(color: i == _color ? ppInk : Colors.transparent, width: 2.5)),
                ),
              ),
          ])),
          const SizedBox(height: 22),
          jvPad(Text('Cover image', style: ppJakarta(14))),
          const SizedBox(height: 12),
          jvPad(Row(children: [
            for (var i = 0; i < 3; i++)
              GestureDetector(
                onTap: () => setState(() => _image = i),
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: i == _image ? ppPurple : Colors.transparent, width: 2)),
                  child: JvPhoto(seed: i, height: 52, width: 52, radius: 12),
                ),
              ),
            GestureDetector(
              onTap: () => _snack(context, 'Add a photo - coming soon'),
              child: Container(width: 52, height: 52, alignment: Alignment.center, decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.add, size: 20, color: ppPurple)),
            ),
          ])),
          const SizedBox(height: 24),
          jvPad(_field('Title', _title)),
          jvPad(_field('Subtitle (optional)', _subtitle)),
          jvPad(_field('Dedication (optional)', _dedication)),
          const SizedBox(height: 20),
          jvPad(jvButton('Preview book', () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const StorybookScreen())))),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController controller) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: ppBody(12, color: ppMuted, w: FontWeight.w600)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: ppLine)),
            child: TextField(
              controller: controller,
              style: ppBody(14, color: ppInk),
              decoration: const InputDecoration(border: InputBorder.none, isDense: true, filled: false),
            ),
          ),
        ]),
      );
}

// ---- Print Storybook --------------------------------------------------------
class PrintStorybookScreen extends StatelessWidget {
  const PrintStorybookScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: ListView(
        padding: const EdgeInsets.only(top: 58, bottom: 40),
        children: [
          jvPad(jvTopBar(context, title: 'Print Storybook')),
          const SizedBox(height: 24),
          const Center(child: JvBookCover(width: 150, height: 200, since: 'Since 2023')),
          const SizedBox(height: 26),
          jvPad(Text('Premium Hardcover Book', style: ppFraunces(26, h: 1.15))),
          const SizedBox(height: 14),
          jvPad(Column(children: [
            _spec('220 pages, printed to order'),
            _spec('Museum-quality archival paper'),
            _spec('Lay-flat binding, opens fully'),
            _spec('A lifetime keepsake, made to last'),
          ])),
          const SizedBox(height: 20),
          jvPad(Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('₹2,499', style: ppFraunces(30, color: ppInk)),
            const SizedBox(width: 10),
            Flexible(child: Padding(padding: const EdgeInsets.only(bottom: 6), child: Text('Free shipping', style: ppBody(12, color: ppMuted), maxLines: 1, overflow: TextOverflow.ellipsis))),
          ])),
          const SizedBox(height: 18),
          jvPad(jvButton('Preview book', () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const StorybookScreen())))),
          const SizedBox(height: 12),
          jvPad(jvButton('Order now', () => _snack(context, 'Ordering opens soon'), filled: false)),
          const SizedBox(height: 16),
          jvPad(Text('Printed and delivered by our keepsake partner. Your memories never leave ParentVeda.', textAlign: TextAlign.center, style: ppBody(12, color: ppMuted, h: 1.5))),
        ],
      ),
    );
  }

  Widget _spec(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.check_rounded, size: 16, color: ppPurple),
          const SizedBox(width: 10),
          Expanded(child: Text(t, style: ppBody(14, color: ppInk, h: 1.5))),
        ]),
      );
}

// ---- Settings ---------------------------------------------------------------
class JournalSettingsScreen extends StatelessWidget {
  const JournalSettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: ListView(
        padding: const EdgeInsets.only(top: 58, bottom: 30),
        children: [
          jvPad(jvTopBar(context, title: 'Journal Settings')),
          const SizedBox(height: 18),
          jvPad(_group([
            _row(context, Icons.person_outline_rounded, 'Profile', jvChild),
            _row(context, Icons.lock_outline_rounded, 'Privacy', 'Only parents'),
            _row(context, Icons.cloud_done_outlined, 'Backup & Sync', 'On'),
            _row(context, Icons.notifications_none_rounded, 'Notifications', 'On'),
          ])),
          const SizedBox(height: 16),
          jvPad(_group([
            _row(context, Icons.download_outlined, 'Export memories', ''),
            _row(context, Icons.workspace_premium_outlined, 'My subscription', 'Premium'),
            _row(context, Icons.help_outline_rounded, 'Help & support', ''),
            _row(context, Icons.info_outline_rounded, 'About My Journal', ''),
          ])),
        ],
      ),
    );
  }

  Widget _group(List<Widget> rows) => Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: ppHair)),
        clipBehavior: Clip.antiAlias,
        child: Column(children: rows),
      );

  Widget _row(BuildContext context, IconData icon, String label, String value) => GestureDetector(
        onTap: () => _snack(context, '$label - coming soon'),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: ppHair))),
          child: Row(children: [
            Icon(icon, size: 19, color: ppPurple),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: ppBody(14, color: ppInk, w: FontWeight.w600))),
            if (value.isNotEmpty) Text(value, style: ppBody(12, color: ppMuted)),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right_rounded, size: 18, color: ppMuted),
          ]),
        ),
      );
}
