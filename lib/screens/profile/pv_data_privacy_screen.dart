// =============================================================================
//  PvDataPrivacyScreen — what we store, download it, delete it
// -----------------------------------------------------------------------------
//  Apple Health's privacy sentence, Urban Company's Privacy Center and
//  Zalando's "Request or delete data" folded into one page (audit §3): the
//  plain-language list of what we hold for THIS stage, a download row, and
//  the delete at the end in red.
//
//  ⚠️ DOWNLOAD IS PRESENT AND SAYS "COMING" — the user's call (2026-09-19).
//  Her rows live across a dozen tables and only a server function can gather
//  them into one file; that edge function is owed (STILL-OPEN §67). The row
//  is here now because a feature is never hidden, and because a person
//  looking for this right should find where it will be, not nothing.
// =============================================================================

import 'package:flutter/material.dart';

import '../../services/life_stage_store.dart';
import '../../services/remote/supabase_repo.dart';
import '../../theme/pv_fonts.dart';
import 'pv_account_actions.dart';
import 'pv_you_chrome.dart';
import 'pv_you_content.dart';

class PvDataPrivacyScreen extends StatelessWidget {
  const PvDataPrivacyScreen({super.key, required this.stage});
  final LifeStage stage;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    final content = pvYouContentFor(stage);
    final signedIn = SupabaseRepo.isLoggedIn;
    return Scaffold(
      backgroundColor: p.ground,
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: PvYouTopBar(title: 'Data and privacy', eyebrow: 'Account'),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What we store',
                    style: pvManrope(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: p.ink1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (final t in content.whatWeStore)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '•  ',
                            style: pvManrope(fontSize: 13.5, color: p.ink2),
                          ),
                          Expanded(
                            child: Text(
                              t,
                              style: pvManrope(
                                fontSize: 13.5,
                                height: 1.45,
                                color: p.ink2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 6),
                  Text(
                    signedIn
                        ? 'Kept on this phone first, and synced to your account so a new phone gets it back. Every row is yours alone; a paired partner reads only what the partner page lists.'
                        : 'You are not signed in, so everything here lives on this phone only. Sign in to keep it across phones.',
                    style: pvManrope(
                      fontSize: 12.5,
                      height: 1.5,
                      color: p.ink3,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: PvYouSection(
              title: 'Your data',
              children: [
                PvYouRow(
                  icon: Icons.download_outlined,
                  title: 'Download my data',
                  subtitle:
                      'One file with everything above. Coming — the server side is being built.',
                  value: 'Coming',
                  onTap: () => pvSnack(
                    context,
                    'Not ready yet. When it is, it lands here — a file of everything we hold.',
                  ),
                ),
                PvYouRow(
                  icon: Icons.policy_outlined,
                  title: 'Privacy notice',
                  subtitle: 'The long version of the list above',
                  onTap: () => pvSnack(
                    context,
                    'The privacy notice opens here once it is published.',
                  ),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: PvYouSection(
              title: 'Leave',
              lead:
                  'Signing out keeps everything. Deleting removes it from our servers for good.',
              children: [
                PvYouRow(
                  icon: Icons.logout_rounded,
                  title: 'Sign out',
                  onTap: () => pvSignOut(context),
                ),
                PvYouRow(
                  icon: Icons.delete_outline_rounded,
                  title: 'Delete account',
                  danger: true,
                  onTap: () => pvDeleteAccount(context),
                ),
              ],
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}
