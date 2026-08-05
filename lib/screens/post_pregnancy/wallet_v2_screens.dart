// =============================================================================
//  Health Wallet — V2. The redesign brief, built as written.
// -----------------------------------------------------------------------------
//  The brief's IA, in its order: Summary → Timeline → Records → Reminders →
//  Emergency. Its home wireframe, its language, and the two things this
//  codebase would push back on kept intact:
//
//    * the status card leads with "Healthy"
//    * uploading a prescription offers to create reminders from what was
//      read, without a confirmation step
//
//  Both arguments live in V3 and in pp_wallet_data.dart. Building a V2 with
//  them already fixed would be building V3 twice.
//
//  WHAT IS REUSED RATHER THAN REBUILT, and this is most of it: the brief's
//  Timeline, Records, Growth and Doctor Visit screens already exist and
//  already match what it describes. `HealthTimelineScreen`,
//  `HealthRecordsScreen`, `HealthGrowthScreen` and `HealthDoctorVisitScreen`
//  are opened as they stand. The genuinely new surfaces are the Reminders hub
//  and the Emergency card, and those are shared with V3 because the versions
//  do not disagree about them.
//
//  TWO MECHANICAL DEPARTURES, as with Grow:
//    * line icons instead of the wireframe's 🟢 ➕ 💊 📝 📄 🚑 🌧 — app-wide
//      chrome rule, not a view about this feature.
//    * the upload flow cannot actually read a document. There is no OCR in
//      this repo and there should not be; see the handover note in
//      pp_wallet_data.dart. The screen says so rather than faking an extract.
// =============================================================================

import 'package:barcode/barcode.dart';
import 'package:flutter/material.dart';

import '../../widgets/global_ask_fab.dart' show kAskFabReserve;
import 'package:flutter/services.dart';

import '../../services/reminder_store.dart';
import 'health_emergency_screen.dart';
import 'health_records_screen.dart';
import 'health_timeline_screen.dart';
import 'pp_child_profile.dart';
import 'pp_common.dart';
import 'pp_health_data.dart';
import 'pp_wallet_data.dart';

void _push(BuildContext c, Widget s) =>
    Navigator.of(c).push(MaterialPageRoute<void>(builder: (_) => s));

Widget _pad(Widget c) =>
    Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

// =============================================================================
//  SUMMARY — the landing screen
// =============================================================================

class WalletV2Home extends StatelessWidget {
  const WalletV2Home({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: HealthStore.instance,
      builder: (context, _) {
        final status = walletStatusDoc();
        final connections = walletConnections();
        return Scaffold(
          backgroundColor: ppBg,
          body: SafeArea(
            bottom: false,
            child: ListView(
              padding: EdgeInsets.only(top: 12, bottom: kAskFabReserve),
              children: [
                _pad(Row(children: [
                  Expanded(child: ppBack(context, 'Explore')),
                  const SizedBox(width: 128),
                ])),
                const SizedBox(height: 18),
                _pad(Text('Health Wallet', style: ppFraunces(31, h: 1.05))),
                const SizedBox(height: 8),
                _pad(Text(
                    "Your child's complete medical history. Always with you.",
                    style: ppBody(14, h: 1.55))),

                const SizedBox(height: 22),
                _pad(walletStatusCard(status)),

                const SizedBox(height: 20),
                _pad(_upcoming(context)),

                const SizedBox(height: 28),
                _pad(Text('Quick actions', style: ppJakarta(17))),
                const SizedBox(height: 12),
                _pad(_quickActions(context)),

                const SizedBox(height: 28),
                _pad(Text('Recent activity', style: ppJakarta(17))),
                const SizedBox(height: 12),
                _pad(_recent(context)),

                if (connections.isNotEmpty) ...[
                  const SizedBox(height: 28),
                  _pad(Text('Smart reminder', style: ppJakarta(17))),
                  const SizedBox(height: 12),
                  _pad(walletConnectionCard(context, connections.first)),
                ],

                const SizedBox(height: 26),
                _pad(_openTimeline(context)),
                const SizedBox(height: 34),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _upcoming(BuildContext context) {
    final due = WalletReminders.dueSoon();
    return GestureDetector(
      onTap: () => _push(context, const WalletRemindersScreen()),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: ppBorder),
        ),
        child: Row(children: [
          const Icon(Icons.notifications_none_rounded, size: 19, color: ppPurple),
          const SizedBox(width: 13),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Upcoming',
                  style: ppBody(11, color: ppMuted, w: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(
                  due.isEmpty
                      ? 'No reminders set yet'
                      : '${due.length} reminder${due.length == 1 ? '' : 's'} on',
                  style: ppJakarta(14)),
            ]),
          ),
          const Icon(Icons.chevron_right_rounded, size: 20, color: ppMuted),
        ]),
      ),
    );
  }

  Widget _quickActions(BuildContext context) {
    final actions = <(IconData, String, VoidCallback)>[
      (Icons.medical_services_outlined, 'Doctor visit',
          () => _push(context, const HealthRecordsScreen(category: 'visits'))),
      (Icons.medication_outlined, 'Medicine',
          () => _push(context, const HealthRecordsScreen(category: 'medications'))),
      (Icons.edit_note_rounded, 'Symptom',
          () => _push(context, const HealthRecordsScreen(category: 'symptoms'))),
      (Icons.upload_file_outlined, 'Upload report',
          () => _push(context, const WalletUploadScreen())),
      (Icons.emergency_outlined, 'Emergency card',
          () => _push(context, const WalletEmergencyCardScreen())),
    ];
    // THREE PER ROW, MEASURED, not a guessed fixed width.
    //
    // 104 was picked to look right and happened to fit only twice per row on a
    // 360dp screen, so five actions laid out 2 + 2 + 1 and "Emergency card" —
    // the one you would reach for in a hurry — sat alone on its own row looking
    // like an afterthought. Deriving the width from the row means 3 + 2, the
    // tiles fill the width, and it stays correct on a narrower or wider phone
    // instead of being right on exactly one.
    const spacing = 10.0;
    return LayoutBuilder(builder: (context, box) {
      final w = (box.maxWidth - spacing * 2) / 3;
      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: [
          for (final a in actions)
            GestureDetector(
              onTap: a.$3,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: w,
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: ppBorder),
                ),
                child: Column(children: [
                  Icon(a.$1, size: 21, color: ppPurple),
                  const SizedBox(height: 9),
                  Text(a.$2,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: ppBody(11.5, color: ppInk, w: FontWeight.w700)),
                ]),
              ),
            ),
        ],
      );
    });
  }

  Widget _recent(BuildContext context) {
    final store = HealthStore.instance;
    final rows = <(String, String)>[
      for (final v in store.visits.take(2)) (v.title, v.date),
      for (final p in store.prescriptions.take(1)) ('Prescription added', p.date),
      for (final s in store.symptoms.take(1)) (s.name, s.date),
    ];
    if (rows.isEmpty) {
      return walletEmpty(
        'Nothing logged yet.',
        'Add a doctor visit, a symptom or a report and it will appear here as '
            'the start of the story.',
      );
    }
    return Column(children: [
      for (final r in rows)
        Padding(
          padding: const EdgeInsets.only(bottom: 9),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: ppHair),
            ),
            child: Row(children: [
              Expanded(child: Text(r.$1, style: ppJakarta(13))),
              Text(r.$2, style: ppBody(11.5, color: ppMuted)),
            ]),
          ),
        ),
    ]);
  }

  Widget _openTimeline(BuildContext context) => GestureDetector(
        onTap: () => _push(context, const HealthTimelineScreen()),
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: ppPurple,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text('Open timeline',
              style: ppBody(13.5, color: Colors.white, w: FontWeight.w800)),
        ),
      );
}

// =============================================================================
//  Shared pieces — used by both new versions
// =============================================================================

/// The status card. Takes a [WalletStatus] rather than computing one, which is
/// what lets V2 and V3 render the same component and still disagree about what
/// it says.
Widget walletStatusCard(WalletStatus s) {
  final tone = switch (s.tone) {
    'good' => ppAccentGreen,
    'watch' => ppAccentAmber,
    _ => ppSoft,
  };
  return Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: ppBorder),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('CURRENT STATUS',
          style: ppBody(10.5, color: ppMuted, w: FontWeight.w800)),
      const SizedBox(height: 12),
      Row(children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: tone, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(s.headline, style: ppFraunces(24, h: 1.1))),
      ]),
      const SizedBox(height: 8),
      Text(s.sub, style: ppBody(12.5, h: 1.55)),
      const SizedBox(height: 16),
      Container(height: 1, color: ppHair),
      const SizedBox(height: 14),
      for (var i = 0; i < s.tiles.length; i++) ...[
        Row(children: [
          Expanded(child: Text(s.tiles[i].label, style: ppBody(13, color: ppSoft))),
          Text(s.tiles[i].value,
              style: ppJakarta(13,
                  color: s.tiles[i].status == 'watch'
                      ? ppAccentAmber
                      : ppTitleInk)),
        ]),
        if (i != s.tiles.length - 1) const SizedBox(height: 11),
      ],
    ]),
  );
}

/// One "understand" observation. Always ends in a conversation, never a cause.
Widget walletConnectionCard(BuildContext context, WalletConnection c) =>
    Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ppPanel,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(c.icon, size: 18, color: ppPurple),
          const SizedBox(width: 10),
          Expanded(child: Text(c.title, style: ppJakarta(14))),
        ]),
        const SizedBox(height: 10),
        Text(c.body, style: ppBody(12.5, h: 1.55)),
        const SizedBox(height: 12),
        Row(children: [
          const Icon(Icons.arrow_forward_rounded, size: 15, color: ppPurple),
          const SizedBox(width: 7),
          Expanded(
              child: Text(c.action,
                  style: ppBody(12, color: ppPurple, w: FontWeight.w700))),
        ]),
      ]),
    );

/// Every empty state educates rather than apologising — the brief asks for
/// this explicitly, and it is also the house rule ("a feature is never
/// hidden": the empty state is the feature's advertisement).
Widget walletEmpty(String title, String body, {String? cta, VoidCallback? onCta}) =>
    Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: ppPanel,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: ppJakarta(14)),
        const SizedBox(height: 7),
        Text(body, style: ppBody(12.5, h: 1.55)),
        if (cta != null) ...[
          const SizedBox(height: 14),
          GestureDetector(
            onTap: onCta,
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: ppPurple,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(cta,
                  style: ppBody(13, color: Colors.white, w: FontWeight.w800)),
            ),
          ),
        ],
      ]),
    );

// =============================================================================
//  REMINDERS — the flagship the existing feature never had
// -----------------------------------------------------------------------------
//  Shared by V2 and V3: they do not disagree about this one, and the brief is
//  simply right that it was missing.
//
//  Writes through ReminderStore, so these land in the same list and the same
//  scheduler as every other reminder in the app. Medicine is absent on purpose
//  — see the note in pp_wallet_data.dart.
// =============================================================================

class WalletRemindersScreen extends StatefulWidget {
  const WalletRemindersScreen({super.key});

  @override
  State<WalletRemindersScreen> createState() => _WalletRemindersScreenState();
}

class _WalletRemindersScreenState extends State<WalletRemindersScreen> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ReminderStoreListenable.instance,
      builder: (context, _) => Scaffold(
        backgroundColor: ppBg,
        body: SafeArea(
          bottom: false,
          child: ListView(
            padding: EdgeInsets.only(top: 12, bottom: kAskFabReserve),
            children: [
              _pad(ppBack(context, 'Health Wallet')),
              const SizedBox(height: 20),
              _pad(Text('Reminders', style: ppFraunces(28, h: 1.05))),
              const SizedBox(height: 8),
              _pad(Text(
                  'You should never have to hold these dates in your head. '
                  'Switch on what you want and the app carries it.',
                  style: ppBody(13.5, h: 1.55))),
              const SizedBox(height: 22),
              for (final k in kWalletReminderKinds)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _pad(_kindRow(k)),
                ),
              const SizedBox(height: 20),
              _pad(_medicineNote(context)),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _kindRow(WalletReminderKind k) {
    final existing = WalletReminders.forKind(k);
    final on = existing.any((r) => r.enabled);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: ppBorder),
      ),
      child: Row(children: [
        Icon(k.icon, size: 19, color: on ? ppPurple : ppMuted),
        const SizedBox(width: 13),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(k.label, style: ppJakarta(13.5)),
            const SizedBox(height: 3),
            Text(k.blurb, style: ppBody(11.5, color: ppMuted, h: 1.4)),
          ]),
        ),
        Switch.adaptive(
          value: on,
          activeTrackColor: ppPurple,
            activeThumbColor: Colors.white,
          onChanged: (v) async {
            if (v) {
              WalletReminders.add(
                  kind: k,
                  title: k.label,
                  body: k.blurb,
                  hour: k.hour);
            } else {
              for (final r in existing) {
                ReminderStore.instance.remove(r.id);
              }
            }
            if (mounted) setState(() {});
          },
        ),
      ]),
    );
  }

  // Medicine is not on the list above, and a parent looking for it deserves to
  // be told where it went rather than concluding it is missing.
  Widget _medicineNote(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ppPanel,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.medication_outlined, size: 17, color: ppSoft),
            const SizedBox(width: 9),
            Text('Medicine reminders live with the medicine',
                style: ppJakarta(13)),
          ]),
          const SizedBox(height: 9),
          Text(
              'A dose reminder is set on the medicine record itself, so the '
              'time, the dose and the alarm can never disagree with each '
              'other. Open a medicine to switch its reminder on.',
              style: ppBody(12.5, h: 1.55)),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _push(
                context, const HealthRecordsScreen(category: 'medications')),
            behavior: HitTestBehavior.opaque,
            child: Row(children: [
              const Icon(Icons.arrow_forward_rounded, size: 15, color: ppPurple),
              const SizedBox(width: 7),
              Text('Open medicines',
                  style: ppBody(12, color: ppPurple, w: FontWeight.w700)),
            ]),
          ),
        ]),
      );
}

/// ReminderStore is a ChangeNotifier already; this is just a named handle so
/// the screen above reads clearly.
class ReminderStoreListenable {
  static Listenable get instance => ReminderStore.instance;
}

// =============================================================================
//  EMERGENCY CARD
// -----------------------------------------------------------------------------
//  Shared by V2 and V3. The existing HealthEmergencyScreen holds the EDITOR —
//  where the details are typed — and is untouched. This is the CARD: the thing
//  you hold up.
//
//  The QR encodes the details themselves rather than a link. An emergency is
//  the one moment you cannot assume there is internet, and a link that needs a
//  network is a card that fails exactly when it is needed. See the note in
//  pp_wallet_data.dart for the trade this accepts.
// =============================================================================

class WalletEmergencyCardScreen extends StatelessWidget {
  const WalletEmergencyCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = walletEmergencyText();
    final child = ChildProfileStore.instance;
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.only(top: 12, bottom: kAskFabReserve),
          children: [
            _pad(ppBack(context, 'Health Wallet')),
            const SizedBox(height: 20),
            _pad(Text('Emergency card', style: ppFraunces(28, h: 1.05))),
            const SizedBox(height: 8),
            _pad(Text(
                'Everything a stranger needs in the first two minutes. Works '
                'with no signal.',
                style: ppBody(13.5, h: 1.55))),
            const SizedBox(height: 22),
            _pad(_card(context, child.name, text)),
            const SizedBox(height: 16),
            _pad(_actions(context, text)),
            const SizedBox(height: 20),
            _pad(walletEmpty(
              'What is deliberately not on it',
              'No history, no reports, no address. A card that has to be '
                  'readable by a stranger should carry only what a stranger '
                  'needs.',
            )),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _card(BuildContext context, String name, String text) {
    // Vector QR, drawn straight from the barcode package — the same approach
    // as the care-partner poster, so it stays crisp at any size and needs no
    // image asset.
    final svg = Barcode.qrCode().toSvg(text, width: 190, height: 190);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ppBorder),
      ),
      child: Column(children: [
        Text(name, style: ppFraunces(22)),
        const SizedBox(height: 4),
        Text('ParentVeda emergency card',
            style: ppBody(11.5, color: ppMuted)),
        const SizedBox(height: 18),
        SizedBox(
          width: 190,
          height: 190,
          child: _QrSvg(svg: svg),
        ),
        const SizedBox(height: 18),
        Container(height: 1, color: ppHair),
        const SizedBox(height: 14),
        for (final line in text.split('\n'))
          Padding(
            padding: const EdgeInsets.only(bottom: 7),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(
                width: 108,
                child: Text(line.split(':').first,
                    style: ppBody(11, color: ppMuted, w: FontWeight.w800)),
              ),
              Expanded(
                child: Text(
                    line.contains(':')
                        ? line.substring(line.indexOf(':') + 1).trim()
                        : line,
                    style: ppBody(12.5, h: 1.45)),
              ),
            ]),
          ),
      ]),
    );
  }

  Widget _actions(BuildContext context, String text) => Row(children: [
        Expanded(
          child: GestureDetector(
            onTap: () async {
              await Clipboard.setData(ClipboardData(text: text));
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Copied — paste anywhere')));
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: ppPurple,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Text('Copy details',
                  style: ppBody(13, color: Colors.white, w: FontWeight.w800)),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () => _push(context, const HealthEmergencyScreen()),
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: ppPanel,
                borderRadius: BorderRadius.circular(13),
              ),
              child:
                  Text('Edit details', style: ppJakarta(13, color: ppPurple)),
            ),
          ),
        ),
      ]);
}

/// Paints a QR from the barcode package's SVG output.
///
/// The package emits SVG; Flutter has no SVG widget without a dependency, so
/// the rects are parsed out and painted directly. Cheap (a QR is a few hundred
/// rects), exact, and avoids adding flutter_svg for one screen.
class _QrSvg extends StatelessWidget {
  const _QrSvg({required this.svg});
  final String svg;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _QrPainter(svg), size: const Size(190, 190));
}

class _QrPainter extends CustomPainter {
  _QrPainter(this.svg);
  final String svg;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = ppTitleInk;
    final re = RegExp(
        r'<rect[^>]*x="([\d.]+)"[^>]*y="([\d.]+)"[^>]*width="([\d.]+)"[^>]*height="([\d.]+)"');
    for (final m in re.allMatches(svg)) {
      canvas.drawRect(
        Rect.fromLTWH(
          double.parse(m[1]!),
          double.parse(m[2]!),
          double.parse(m[3]!),
          double.parse(m[4]!),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _QrPainter old) => old.svg != svg;
}

// =============================================================================
//  UPLOAD — V2's version, per the brief
// -----------------------------------------------------------------------------
//  The brief: uploading a prescription should AUTOMATICALLY detect medicines,
//  create medicine reminders, identify the doctor, detect the visit date and
//  attach it to the timeline.
//
//  Built as described, with one thing it cannot lie about: there is no
//  extraction engine in this repo, so nothing is actually read. The screen
//  states that rather than showing a fake progress bar filling up to invented
//  results — a demo that pretends to read a prescription is the one demo that
//  could get somebody hurt if it were ever believed.
// =============================================================================

class WalletUploadScreen extends StatelessWidget {
  const WalletUploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auto = WalletVersionStore.instance.version == WalletVersion.v2;
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.only(top: 12, bottom: kAskFabReserve),
          children: [
            _pad(ppBack(context, 'Health Wallet')),
            const SizedBox(height: 20),
            _pad(Text('Upload a document', style: ppFraunces(28, h: 1.05))),
            const SizedBox(height: 8),
            _pad(Text(
                'A prescription, a blood report, a discharge summary. It is '
                'kept in the wallet and added to the timeline.',
                style: ppBody(13.5, h: 1.55))),
            const SizedBox(height: 22),
            _pad(walletEmpty(
              'Reading a document is not wired up yet',
              'ParentVeda has no text-recognition of its own — that lives in '
                  'the Ask Veda service, in a different codebase. Until it is '
                  'connected, a document is stored and you type the few '
                  'details you want searchable.',
              cta: 'Add it by hand',
              onCta: () => _push(
                  context, const HealthRecordsScreen(category: 'reports')),
            )),
            const SizedBox(height: 22),
            _pad(Text('What it will do once connected', style: ppJakarta(16))),
            const SizedBox(height: 12),
            _pad(_plan(auto)),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _plan(bool auto) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ppBorder),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          for (final s in const [
            'Classify the document',
            'Pull out the medicines, the doctor and the date',
            'Store the original file, untouched',
            'Add one entry to the timeline',
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.check_rounded, size: 15, color: ppPurple),
                const SizedBox(width: 10),
                Expanded(child: Text(s, style: ppBody(13, h: 1.5))),
              ]),
            ),
          Container(height: 1, color: ppHair),
          const SizedBox(height: 12),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(auto ? Icons.bolt_rounded : Icons.fact_check_outlined,
                size: 16, color: auto ? ppAccentAmber : ppPurple),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                  auto
                      ? 'Then set the medicine reminders automatically, as the '
                          'brief asks. Nothing is shown to you first.'
                      : 'Then show you everything it read, and change nothing '
                          'until you have confirmed each field.',
                  style: ppBody(13, h: 1.5)),
            ),
          ]),
        ]),
      );
}
