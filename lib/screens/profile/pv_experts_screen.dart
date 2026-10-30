// =============================================================================
//  PvExpertsScreen - "Our experts": who works with ParentVeda
// -----------------------------------------------------------------------------
//  Built 2026-10-30. Opened from You > Support > "Our experts" (every stage and
//  the father's view reach it from there) and from a small "Meet our experts"
//  link on the consult results screen.
//
//  ONE LIST, NO STAGE GROUPING, NO STAGE CHIPS (user, 2026-10-30): an expert is
//  never "only for" a stage, so the screen does not file them under one. Every
//  row is initials, name, role and "Helps with: <first three tags>"; a tap
//  opens `ProviderProfileScreen(onlyProfile: true)`.
//
//  ⚠️ A DIRECTORY, NOT A SHOP FRONT. No booking, rating, fee or review appears
//  here or on the profile, and nothing is marked verified: the data
//  (`kPanelExperts`) is what each expert supplied and ParentVeda keeps on file.
//  Booking with these five is out of scope for now.
//
//  The route is named `you/experts` (and `you/experts/<id>` for a profile) so
//  anything that reads the route name sees a You-area page, as it does for
//  `you/child/<id>`.
// =============================================================================

import 'package:flutter/material.dart';

import '../../experts/expert.dart';
import '../../experts/panel_experts.dart';
import '../../theme/pv_fonts.dart';
import '../post_pregnancy/provider_profile_screen.dart';
import 'pv_you_chrome.dart';

/// The route name this screen is opened under.
const String kPvExpertsRoute = 'you/experts';

/// Opens the directory. One place, so the You row and the "Meet our experts"
/// link cannot drift apart on the route name.
Future<void> openPvExperts(BuildContext context) => Navigator.of(context).push(
  MaterialPageRoute<void>(
    settings: const RouteSettings(name: kPvExpertsRoute),
    builder: (_) => const PvExpertsScreen(),
  ),
);

class PvExpertsScreen extends StatelessWidget {
  const PvExpertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return Scaffold(
      backgroundColor: p.ground,
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: PvYouTopBar(title: 'Our experts', eyebrow: 'ParentVeda'),
          ),
          SliverToBoxAdapter(
            child: PvYouSection(
              title: 'Who can help',
              lead:
                  'These are the specialists who work with ParentVeda. They never replace your own doctor.',
              children: [for (final e in kPanelExperts) _ExpertRow(expert: e)],
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 40),
              child: Text(
                'Each profile is what the expert supplied, and ParentVeda keeps it on file.',
                style: pvManrope(fontSize: 12, height: 1.5, color: p.ink3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpertRow extends StatelessWidget {
  const _ExpertRow({required this.expert});
  final Expert expert;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    final note = kPanelNameNote[expert.id] ?? '';
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          settings: RouteSettings(name: '$kPvExpertsRoute/${expert.id}'),
          builder: (_) =>
              ProviderProfileScreen(expert: expert, onlyProfile: true),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // The initial of the name without its "Dr.", so it is never a "D".
            PvAvatar(name: expert.name.replaceFirst('Dr. ', ''), size: 42),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    children: [
                      Text(
                        expert.name,
                        style: pvManrope(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: p.ink1,
                        ),
                      ),
                      if (note.isNotEmpty)
                        Text(
                          note,
                          style: pvManrope(fontSize: 12, color: p.ink3),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    expert.credential,
                    style: pvManrope(
                      fontSize: 12.5,
                      height: 1.35,
                      color: p.ink2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    panelHelpsWith(expert),
                    style: pvManrope(
                      fontSize: 12.5,
                      height: 1.35,
                      color: p.ink3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Icon(Icons.chevron_right_rounded, size: 20, color: p.ink3),
            ),
          ],
        ),
      ),
    );
  }
}
