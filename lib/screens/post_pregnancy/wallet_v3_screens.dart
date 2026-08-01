// =============================================================================
//  Health Wallet — V3. The brief's structure, with two things changed.
// -----------------------------------------------------------------------------
//  WHAT IT TAKES FROM THE BRIEF, because the brief is right about these:
//
//    * "Health Wallet" as one mental model. The wallet metaphor tells a parent
//      what the thing is FOR, which "Your Baby's Health" never did.
//    * Reminders as a first-class section. It was the real gap — the app could
//      store everything and remember almost nothing.
//    * An emergency card that works with no signal, and one-tap sharing.
//    * Timeline over folders. Parents remember stories.
//
//  WHAT IT CHANGES, and neither is a matter of taste:
//
//  1. THE STATUS CARD DOES NOT SAY "HEALTHY".
//
//     The brief's home leads with a green dot and the word Healthy. The app
//     cannot know that — it knows what has been typed into it. The gap is
//     where the harm is: a child with an unlogged problem still gets a green
//     dot, and the parent who most needs to be nudged is the one most
//     reassured.
//
//     So V3 answers a question it can actually answer: IS ANYTHING WAITING FOR
//     YOU? Nothing due, or three things due. That is a fact about the wallet,
//     and it stays true no matter what is happening medically.
//
//     Same reasoning the rest of this codebase already uses. TruthSource puts
//     ParentVeda's own calculation second from the bottom, below the mother's
//     own observation; a computed "Healthy" would put it at the top.
//
//  2. NOTHING IS CREATED FROM A DOCUMENT WITHOUT A HUMAN SAYING YES.
//
//     The brief wants an uploaded prescription to create medicine reminders
//     automatically. A misread dose then becomes a recurring alarm telling a
//     parent to give the wrong amount — on time, every time, with the app's
//     authority behind it. The extraction is fine; the silence is not.
//
//     V3 keeps the extraction and adds one screen: here is what we read,
//     change anything that is wrong, then it gets saved.
//
//  WHAT IT KEEPS THAT THE BRIEF WOULD HAVE FOLDED IN: Vaccination stays its
//  own feature and is LINKED, not absorbed. It is a large shipped tracker with
//  its own schedule model, reminders and learn-why pages. Listing it as one row
//  inside Records would either duplicate it or strand it.
// =============================================================================

import 'package:flutter/material.dart';

import 'health_records_screen.dart';
import 'health_timeline_screen.dart';
import 'pp_child_profile.dart';
import 'pp_common.dart';
import 'pp_health_data.dart';
import 'pp_wallet_data.dart';
import 'vax_tracker_screen.dart';
import 'wallet_v2_screens.dart'
    show
        WalletEmergencyCardScreen,
        WalletRemindersScreen,
        WalletUploadScreen,
        walletConnectionCard,
        walletEmpty,
        walletStatusCard;

void _push(BuildContext c, Widget s) =>
    Navigator.of(c).push(MaterialPageRoute<void>(builder: (_) => s));

Widget _pad(Widget c) =>
    Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

class WalletV3Home extends StatelessWidget {
  const WalletV3Home({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: HealthStore.instance,
      builder: (context, _) {
        final child = ChildProfileStore.instance;
        final status = walletStatusRecord();
        final connections = walletConnections();
        return Scaffold(
          backgroundColor: ppBg,
          body: SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.only(top: 12, bottom: 40),
              children: [
                _pad(Row(children: [
                  Expanded(child: ppBack(context, 'Explore')),
                  const SizedBox(width: 128),
                ])),
                const SizedBox(height: 18),
                _pad(ppEyebrow('Health Wallet', color: ppPurple)),
                const SizedBox(height: 8),
                _pad(Text('Everything, in one place',
                    style: ppFraunces(31, h: 1.05))),
                const SizedBox(height: 8),
                _pad(Text(
                    "${child.theyCap} health records, kept together and "
                    'available when someone asks — including when there is no '
                    'signal.',
                    style: ppBody(14, h: 1.55))),

                // ---- what the app can actually tell you --------------------
                const SizedBox(height: 22),
                _pad(walletStatusCard(status)),
                const SizedBox(height: 10),
                _pad(_whatThisMeans(context)),

                // ---- the five sections -------------------------------------
                const SizedBox(height: 28),
                _pad(Text('The wallet', style: ppJakarta(17))),
                const SizedBox(height: 12),
                _pad(_row(
                  context,
                  Icons.timeline_rounded,
                  'Timeline',
                  'The whole story, newest first.',
                  const HealthTimelineScreen(),
                )),
                const SizedBox(height: 10),
                _pad(_row(
                  context,
                  Icons.folder_open_rounded,
                  'Records',
                  'Visits, medicines, reports, symptoms, allergies.',
                  const HealthRecordsScreen(category: 'visits'),
                )),
                const SizedBox(height: 10),
                _pad(_row(
                  context,
                  Icons.notifications_none_rounded,
                  'Reminders',
                  'So you never have to hold a date in your head.',
                  const WalletRemindersScreen(),
                )),
                const SizedBox(height: 10),
                _pad(_row(
                  context,
                  Icons.emergency_outlined,
                  'Emergency card',
                  'Works with no signal. One tap to hand over.',
                  const WalletEmergencyCardScreen(),
                )),

                // ---- linked, not absorbed ----------------------------------
                const SizedBox(height: 10),
                _pad(_row(
                  context,
                  Icons.vaccines_outlined,
                  'Vaccinations',
                  'Its own tracker, with the schedule and the why.',
                  const VaxTrackerScreen(),
                  note: 'Kept separate on purpose',
                )),

                // ---- add something -----------------------------------------
                const SizedBox(height: 28),
                _pad(Text('Add something', style: ppJakarta(17))),
                const SizedBox(height: 12),
                _pad(_addRow(context)),

                // ---- understand ---------------------------------------------
                const SizedBox(height: 28),
                _pad(Text('From your own records', style: ppJakarta(17))),
                const SizedBox(height: 4),
                _pad(Text(
                    'Patterns in what you have written down. Never a diagnosis, '
                    'and never a reason — only what is there.',
                    style: ppBody(12.5, color: ppMuted))),
                const SizedBox(height: 12),
                if (connections.isEmpty)
                  _pad(walletEmpty(
                    'Nothing to point at yet',
                    'Once there are a few visits and symptoms logged, this is '
                        'where repeats and this-time-last-year turn up — the '
                        'things worth mentioning at the next appointment.',
                  ))
                else
                  ...connections.map((c) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _pad(walletConnectionCard(context, c)),
                      )),

                const SizedBox(height: 34),
              ],
            ),
          ),
        );
      },
    );
  }

  /// The disclosure the brief's version cannot offer, because its status card
  /// makes a claim this one does not.
  Widget _whatThisMeans(BuildContext context) => GestureDetector(
        onTap: () => showModalBottomSheet<void>(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (ctx) => Container(
            decoration: const BoxDecoration(
              color: ppBg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 30),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                    color: ppBorder, borderRadius: BorderRadius.circular(999)),
              ),
              const SizedBox(height: 22),
              Text('What this card is, and is not', style: ppJakarta(17)),
              const SizedBox(height: 14),
              Text(
                  'It counts what is in the wallet: reminders that are on, '
                  'medicines still running, allergies recorded, records kept.\n\n'
                  'It is deliberately not a verdict on your child. ParentVeda '
                  'only sees what you have typed in, so "nothing waiting" '
                  'means nothing is waiting HERE — it does not mean all is '
                  'well, and a worry you have not logged is still a worry.\n\n'
                  'If something feels wrong, your paediatrician is the right '
                  'call. Not this page.',
                  style: ppBody(13.5, h: 1.65)),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => Navigator.of(ctx).pop(),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: ppPurple,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text('Got it',
                      style:
                          ppBody(13.5, color: Colors.white, w: FontWeight.w800)),
                ),
              ),
            ]),
          ),
        ),
        behavior: HitTestBehavior.opaque,
        child: Row(children: [
          const Icon(Icons.info_outline_rounded, size: 15, color: ppMuted),
          const SizedBox(width: 8),
          Expanded(
            child: Text('What this card is, and is not',
                style: ppBody(12, color: ppSoft, w: FontWeight.w700)),
          ),
        ]),
      );

  Widget _row(BuildContext context, IconData icon, String title, String sub,
          Widget dest,
          {String? note}) =>
      GestureDetector(
        onTap: () => _push(context, dest),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: ppBorder),
          ),
          child: Row(children: [
            Icon(icon, size: 19, color: ppPurple),
            const SizedBox(width: 13),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(title, style: ppJakarta(13.5)),
                  if (note != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: ppPanel,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(note,
                          style: ppBody(9.5, color: ppMuted, w: FontWeight.w700)),
                    ),
                  ],
                ]),
                const SizedBox(height: 3),
                Text(sub, style: ppBody(11.5, color: ppMuted)),
              ]),
            ),
            const Icon(Icons.chevron_right_rounded, size: 20, color: ppMuted),
          ]),
        ),
      );

  Widget _addRow(BuildContext context) {
    final actions = <(IconData, String, VoidCallback)>[
      (Icons.medical_services_outlined, 'Visit',
          () => _push(context, const HealthRecordsScreen(category: 'visits'))),
      (Icons.edit_note_rounded, 'Symptom',
          () => _push(context, const HealthRecordsScreen(category: 'symptoms'))),
      (Icons.upload_file_outlined, 'Document',
          () => _push(context, const WalletUploadScreen())),
    ];
    return Row(children: [
      for (var i = 0; i < actions.length; i++) ...[
        Expanded(
          child: GestureDetector(
            onTap: actions[i].$3,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: ppBorder),
              ),
              child: Column(children: [
                Icon(actions[i].$1, size: 20, color: ppPurple),
                const SizedBox(height: 8),
                Text(actions[i].$2,
                    style: ppBody(11.5, color: ppInk, w: FontWeight.w700)),
              ]),
            ),
          ),
        ),
        if (i != actions.length - 1) const SizedBox(width: 10),
      ],
    ]);
  }
}
