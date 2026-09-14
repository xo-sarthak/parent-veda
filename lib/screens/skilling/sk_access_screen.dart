// =============================================================================
//  SkAccessScreen — the access rail: the free tools, for the grown-up
// -----------------------------------------------------------------------------
//  The Coding 8 to 11 task's "access rail (build this once, parent-gated,
//  reused by all 12)": the free tools a band's activities run in, which the
//  parent sets up once. The 11 to 14 task extends the same rail. Built once
//  here, in the shell, drawn from `SkDoorContent.access` for her band, so
//  any door with tools to set up gets the same screen.
//
//  ⚠️ GATED ON OPEN, LIKE THE GROWN-UP SCREEN. It holds links out of the
//  app, so it asks the grown-up check before drawing anything, and a fail
//  pops it. A child who taps "Free tools to set up" sees the sum and then
//  the door again.
//
//  ⚠️ THE TASK'S THREE PROMISES, ON SCREEN: every tool is free, none shows
//  ads to children, and any account is the parent's choice under the
//  existing consent. ParentVeda hosts no editor and collects nothing.
//  A tool with no url ("a supervised look at a real AI tool") is a line,
//  not a link — the parent's choice, not ours to point at.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/bracket_resolver.dart';
import '../../theme/pv_fonts.dart';
import '../v2/v2_palette.dart';
import 'sk_child_store.dart';
import 'sk_content.dart';
import 'sk_content_registry.dart';
import 'sk_door_content.dart';
import 'sk_grown_up_gate.dart';

class SkAccessScreen extends StatefulWidget {
  const SkAccessScreen({super.key, required this.doorId});
  final String doorId;

  @override
  State<SkAccessScreen> createState() => _SkAccessScreenState();
}

class _SkAccessScreenState extends State<SkAccessScreen> {
  bool _passed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final ok = await skAskGrownUp(context);
      if (!mounted) return;
      if (!ok) {
        Navigator.of(context).maybePop();
        return;
      }
      setState(() => _passed = true);
    });
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: Listenable.merge([V2PaletteStore.instance, SkChildStore.instance]),
        builder: (context, _) => _body(context, V2PaletteStore.instance.current),
      );

  Widget _body(BuildContext context, V2Palette p) {
    final c = skDoorContentFor(widget.doorId);
    final band = SkChildStore.instance.band;
    if (!_passed || c == null) {
      return Scaffold(
        backgroundColor: p.ground,
        body: Center(child: Icon(Icons.lock_outline_rounded, size: 28, color: p.ink3)),
      );
    }
    final tools = band == null ? const <SkAccessTool>[] : c.accessFor(band.id);
    return Scaffold(
      backgroundColor: p.ground,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 48),
          children: [
            skBack(context, p),
            const SizedBox(height: 18),
            Text((bracketById(widget.doorId)?.title.now ?? widget.doorId).toUpperCase(),
                style: pvManrope(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: p.action)),
            const SizedBox(height: 8),
            Text('Free tools to set up',
                style: pvFraunces(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                    color: p.ink1)),
            const SizedBox(height: 8),
            Text(
                band == null
                    ? 'Nothing to set up yet.'
                    : 'What the ${c.bandName(band.id)} activities run in. You '
                        'set it up once; she uses it. Every one is free, none '
                        'shows ads to children, and any account is yours to '
                        'choose. ParentVeda hosts no editor and collects '
                        'nothing.',
                style: pvManrope(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                    height: 1.55,
                    color: p.ink2)),
            const SizedBox(height: 22),
            for (final t in tools) ...[
              _ToolRow(tool: t, p: p),
              const SizedBox(height: 10),
            ],
            if (tools.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: p.surfaceAlt, borderRadius: BorderRadius.circular(16)),
                child: Text('This band needs nothing bought or installed.',
                    style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink2)),
              ),
          ],
        ),
      ),
    );
  }
}

class _ToolRow extends StatelessWidget {
  const _ToolRow({required this.tool, required this.p});
  final SkAccessTool tool;
  final V2Palette p;

  @override
  Widget build(BuildContext context) {
    final tags = [
      'Free',
      if (tool.offline) 'Offline',
      if (tool.noAccount) 'No account',
    ];
    return InkWell(
      onTap: tool.url == null
          ? null
          : () async {
              try {
                await launchUrl(Uri.parse(tool.url!),
                    mode: LaunchMode.externalApplication);
              } catch (_) {}
            },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: p.line),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: p.surfaceAlt, borderRadius: BorderRadius.circular(12)),
            child: Icon(
                tool.url == null
                    ? Icons.family_restroom_outlined
                    : Icons.open_in_new_rounded,
                size: 18,
                color: p.ink1),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(tool.name,
                  style: pvFraunces(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                      letterSpacing: -0.3,
                      color: p.ink1)),
              const SizedBox(height: 4),
              Text(tool.line,
                  style: pvManrope(fontSize: 13, height: 1.45, color: p.ink2)),
              const SizedBox(height: 9),
              Wrap(spacing: 6, children: [
                for (final t in tags)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: p.ground,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: p.line),
                    ),
                    child: Text(t.toUpperCase(),
                        style: pvManrope(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: p.ink3)),
                  ),
              ]),
            ]),
          ),
          if (tool.url != null) ...[
            const SizedBox(width: 6),
            Icon(Icons.chevron_right_rounded, size: 20, color: p.ink3),
          ],
        ]),
      ),
    );
  }
}
