// =============================================================================
//  ConsultationsScreen (S2) - Prepare › 1:1 Consultations (data-driven)
//  Every specialist opens their profile (S7).
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/prepare_data.dart';
import 'consultation_detail_screen.dart';
import '../../widgets/pv_feedback.dart';
import '../../theme/pv_fonts.dart';
import '../doors/pv_door_chrome.dart' show PvDoorToolScaffold;
import 'prepare_common.dart';
import '../../localization/app_language.dart';

// ⚠️ THE SCREEN'S STRUCTURE — 2026-09-18, the door walk, from Mobbin. The
// user: "very cluttered… not structured well." Zocdoc, Preply and Alan
// share one shape for a list of people you book: a SPECIALTY ROW of pills
// at the top (the filter the door passes in is just the pill that starts
// selected), then one provider per block — avatar, the name bold, what
// they are and their credential, one line of proof (rating · reviews),
// the price, and their next availability as its own slim pill — hairlines
// between blocks, the whole block opens the detail where Book lives. The
// old row (`_specialistFull`) carried nine things and its own button.
class ConsultationsScreen extends StatefulWidget {
  const ConsultationsScreen({super.key, required this.lang, this.onlyRole});

  final AppLanguage lang;

  /// ⚠️ THE FILTER, AND IT IS A GENERAL RULE RATHER THAN ONE SCREEN'S FEATURE.
  ///
  /// Review, stated as a rule: "whichever expert we are pointing to anywhere,
  /// if the user clicks it, that filter should be applied."
  ///
  /// The failure it fixes is small and corrosive. A card said "Have a
  /// gynaecologist go through it with you", she tapped it, and landed on a list
  /// of five specialists — gynae, nutritionist, lactation consultant,
  /// counsellor, sleep expert — with no gynae in sight until she scrolled and
  /// picked one herself. The app named the expert and then made her find them.
  /// That reads as the app not remembering what it just said.
  ///
  /// So: pass the specialist id you promised. Anything else stays reachable
  /// through "See all experts" — the filter narrows the view, it never removes
  /// a specialist from the app, which is the same personalisation line the rest
  /// of the app holds.
  final String? onlyRole;

  @override
  State<ConsultationsScreen> createState() => _ConsultationsScreenState();
}

class _ConsultationsScreenState extends State<ConsultationsScreen> {
  AppLanguage get lang => widget.lang;

  /// The selected pill: a specialist id, or null for everyone. Starts on the
  /// role the door promised, when it exists.
  late String? _role = kSpecialists.any((x) => x.id == widget.onlyRole)
      ? widget.onlyRole
      : null;

  /// The specialists to show. Falls back to everyone when the requested role
  /// does not exist, rather than rendering an empty screen — a filter that
  /// matches nothing must never look like "we have no experts".
  List<Specialist> get _shown {
    if (_role == null) return kSpecialists;
    final hit = kSpecialists.where((x) => x.id == _role).toList();
    return hit.isEmpty ? kSpecialists : hit;
  }

  Widget _pill(String label, bool on, VoidCallback onTap) => PvPress(
        child: Material(
          color: on ? kInk : kCanvas,
          shape: StadiumBorder(side: BorderSide(color: on ? kInk : kBorder)),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: on
                ? null
                : () {
                    pvCommitFeedback();
                    onTap();
                  },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Text(label,
                  style: pvManrope(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: on ? Colors.white : kInk)),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final s = S(lang);
    void open(Specialist sp) => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ConsultationDetailScreen(specialist: sp, lang: lang)));

    // The door tool header (2026-09-19) — the same hero every leaf of a
    // door wears. Kept for revert: the Scaffold + bare back arrow + eyebrow
    // + pvHeroStyle title that stood here.
    return PvDoorToolScaffold(
      hue: 160,
      eyebrow: s.prepEyebrowPrivate,
      title: s.uiConsultations,
      intro: s.uiPrivateSessionRightExpert,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // ---- who: the specialty pills ---------------------------------
            // The filter is a row she can see and change. "All" is the way
            // back out; the door's promised expert is just the pill that
            // starts selected. Kept for revert: the "See all experts" pill.
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(children: [
                _pill('All', _role == null, () => setState(() => _role = null)),
                for (final x in kSpecialists) ...[
                  const SizedBox(width: 8),
                  _pill(x.role.now, _role == x.id,
                      () => setState(() => _role = x.id)),
                ],
              ]),
            ),
            const SizedBox(height: 18),

            for (int i = 0; i < _shown.length; i++)
              _specialist(s, _shown[i], () => open(_shown[i]),
                  bottom: i == _shown.length - 1),

            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: kPanel, borderRadius: BorderRadius.circular(18)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                pvEyebrow(s.prepHowItWorks, color: kPurple),
                const SizedBox(height: 8),
                Text(s.uiPickExpertPickSlot,
                    style: pvBody(kInk, 14).copyWith(height: 1.6)),
              ]),
            ),
            pvFooterNote(s.prepFooterConsultations),
          ]),
        ),
      ],
    );
  }

  // ⚠️ THREE LINES, NOT SEVEN — 2026-09-18, the door walk. The row carried
  // the role, the price, the name, the credential, a blurb, the rating,
  // the languages, the next slot AND a Book button; the user: "very
  // cluttered… not structured well." Zocdoc, Fresha and Alan (Mobbin) give
  // a specialist three lines: who, what, and one line of proof. So: an
  // initials disc; the NAME bold; role · credential; ★ rating · from ₹ ·
  // the next slot when there is one. The whole row opens the detail, where
  // Book lives — one tap here, not two targets. The seven-line row is
  // `_specialistFull` below, kept for revert.
  Widget _specialist(S str, Specialist s, VoidCallback onTap, {bool bottom = false}) {
    final initials = s.name.now
        .replaceAll('Dr. ', '')
        .split(' ')
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0])
        .join();
    final reviews = s.reviews.length;
    final proof = reviews == 0
        ? s.rating
        : '${s.rating}  ·  $reviews ${reviews == 1 ? 'review' : 'reviews'}';
    return PvPress(
      child: InkWell(
        onTap: () {
          pvCommitFeedback();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              top: const BorderSide(color: kHair),
              bottom: bottom ? const BorderSide(color: kHair) : BorderSide.none,
            ),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration:
                    const BoxDecoration(color: kPanel, shape: BoxShape.circle),
                child: Text(initials,
                    style: pvManrope(
                        fontSize: 16, fontWeight: FontWeight.w800, color: kInk)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.name.now, style: pvTitleStyle(16.5)),
                      const SizedBox(height: 2),
                      Text('${s.role.now}  ·  ${s.cred.now.split(' · ').first}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: pvBody(kSoft, 13)),
                      const SizedBox(height: 6),
                      Text(proof,
                          style: pvBody(kInk, 12.5)
                              .copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text('${s.fromPrice.now}  ·  30 min',
                          style: pvBody(kMuted, 12.5)),
                    ]),
              ),
              const SizedBox(width: 8),
              const Padding(
                padding: EdgeInsets.only(top: 14),
                child:
                    Icon(Icons.chevron_right_rounded, size: 20, color: kMuted),
              ),
            ]),
            // Next availability as its own slim pill, full width — Zocdoc's
            // "Next available" bar, in a hairline rather than yellow.
            if (s.next != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 9),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: kBorder),
                ),
                child: Text(s.next!.now,
                    style: pvManrope(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: kInk)),
              ),
            ],
          ]),
        ),
      ),
    );
  }

  /// The seven-line row with its own Book button, 2026-08 → 2026-09-18.
  /// Kept for revert.
  // ignore: unused_element
  Widget _specialistFull(S str, Specialist s, VoidCallback onTap, {bool bottom = false}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            top: const BorderSide(color: kHair),
            bottom: bottom ? const BorderSide(color: kHair) : BorderSide.none,
          ),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: kPanel, borderRadius: BorderRadius.circular(16)),
            child: Icon(s.icon, size: 24, color: kPurple),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(s.role.now, style: pvTitleStyle(16))),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(s.fromPrice.now, style: pvBody(kSoft, 13)),
                ),
              ]),
              const SizedBox(height: 3),
              Text.rich(
                TextSpan(children: [
                  TextSpan(
                      text: s.name.now,
                      style: const TextStyle(color: kInk, fontWeight: FontWeight.w700, fontSize: 13)),
                  TextSpan(
                      text: '  ·  ${s.cred.now.split(' · ').first}',
                      style: const TextStyle(color: kMuted, fontSize: 13)),
                ]),
              ),
              const SizedBox(height: 2),
              Text(s.desc.now, style: pvBody(kSoft, 13)),
              const SizedBox(height: 8),
              Row(children: [
                Text(s.rating, style: pvBody(kCoral, 12).copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(width: 10),
                Text(str.uiHindiEnglish, style: pvBody(kMuted, 12)),
                if (s.next != null) ...[
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(s.next!.now,
                        style: pvBody(kPurple, 12).copyWith(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ]),
            ]),
          ),
          const SizedBox(width: 10),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: pvOutlineButton(str.prepBook, onTap),
          ),
        ]),
      ),
    );
  }
}
