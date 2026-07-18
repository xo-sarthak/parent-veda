// =============================================================================
//  ProviderResultsScreen - Find help · results for one need (parenting)
// -----------------------------------------------------------------------------
//  Lists every expert tagged for a need (via expertsForNeed). Default order is
//  highest rating first; the Rating / Availability / Price filters genuinely
//  re-sort and override that default. Each card shows name, a 1-2 line blurb,
//  rating, price and available timings, and opens the shared profile.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';
import 'pp_experts_data.dart';
import 'provider_profile_screen.dart';

enum _Sort { rating, availability, price }

class ProviderResultsScreen extends StatefulWidget {
  const ProviderResultsScreen({super.key, this.need});

  /// The need to list experts for. When null, shows the full find-help roster.
  final FindHelpNeed? need;

  @override
  State<ProviderResultsScreen> createState() => _ProviderResultsScreenState();
}

class _ProviderResultsScreenState extends State<ProviderResultsScreen> {
  // Default order = highest rating first (initial only; a filter overrides it).
  _Sort _sort = _Sort.rating;

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  List<Expert> get _base =>
      widget.need != null ? expertsForNeed(widget.need!.category) : kFindHelpExperts;

  List<Expert> get _experts {
    final list = [..._base];
    switch (_sort) {
      case _Sort.rating:
        list.sort((a, b) => b.ratingValue.compareTo(a.ratingValue));
      case _Sort.price:
        list.sort((a, b) => a.priceValue.compareTo(b.priceValue));
      case _Sort.availability:
        // Available today first, then by rating within each group.
        list.sort((a, b) {
          if (a.availableToday != b.availableToday) return a.availableToday ? -1 : 1;
          return b.ratingValue.compareTo(a.ratingValue);
        });
    }
    return list;
  }

  String get _title => widget.need != null ? '${widget.need!.label} near you' : 'All experts near you';
  String get _eyebrow => widget.need?.label ?? 'All experts';

  String get _sortLabel {
    switch (_sort) {
      case _Sort.rating:
        return 'top rated';
      case _Sort.availability:
        return 'available first';
      case _Sort.price:
        return 'lowest price';
    }
  }

  @override
  Widget build(BuildContext context) {
    final experts = _experts;
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 40),
          children: [
            _pad(ppBack(context, 'Find help')),

            const SizedBox(height: 22),
            _pad(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ppEyebrow(_eyebrow),
              const SizedBox(height: 10),
              Text(_title, style: ppFraunces(30, h: 1.14)),
              const SizedBox(height: 12),
              Text(
                  'Vetted specialists for your child, ranked by ParentVeda. Sort by rating, who is available today, or price.',
                  style: ppBody(15)),
            ])),

            // filters (these genuinely re-sort and override the default)
            // These re-ORDER the list, they do not narrow it - so they say so.
            // Unlabelled they read as filters, and a parent could reasonably
            // think tapping "Price" was hiding the expensive practitioners.
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text('SORT BY',
                  style: ppBody(9.5, color: ppMuted, w: FontWeight.w800).copyWith(letterSpacing: 0.8)),
            ),
            const SizedBox(height: 9),
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _chip('Rating', _Sort.rating),
                  _chip('Availability', _Sort.availability),
                  _chip('Price', _Sort.price),
                ],
              ),
            ),

            const SizedBox(height: 22),
            _pad(Text(_eyebrow, style: ppJakarta(18))),
            const SizedBox(height: 4),
            _pad(Text('${experts.length} available · sorted by $_sortLabel', style: ppBody(13))),
            const SizedBox(height: 6),

            if (experts.isEmpty)
              _pad(Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Text('No experts here yet - we\'re adding more soon.',
                    style: ppBody(14, color: ppMuted)),
              ))
            else
              for (var i = 0; i < experts.length; i++)
                _pad(_card(context, experts[i], top: i == 0, bottom: i == experts.length - 1)),

            const SizedBox(height: 22),
            _pad(Text(
                'Ranked by ParentVeda from our research and real parent reviews. Booking is mock for now.',
                textAlign: TextAlign.center, style: ppBody(12, color: ppMuted, h: 1.55))),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, _Sort mode) {
    final active = _sort == mode;
    return GestureDetector(
      onTap: () => setState(() => _sort = mode),
      child: Container(
        margin: const EdgeInsets.only(right: 9),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? ppPurple : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: active ? ppPurple : ppBorder),
        ),
        child: Text(label, style: ppBody(13, color: active ? Colors.white : ppSoft, w: FontWeight.w700)),
      ),
    );
  }

  Widget _card(BuildContext context, Expert e, {bool top = false, bool bottom = false}) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => ProviderProfileScreen(expert: e))),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          border: Border(
            top: top ? const BorderSide(color: ppHair) : BorderSide.none,
            bottom: bottom ? const BorderSide(color: ppHair) : BorderSide.none,
          ),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: ppBorder)),
            clipBehavior: Clip.antiAlias,
            child: const PpStriped(height: 58, colorA: ppBorder, colorB: ppStripeB),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                    child: Text(e.name,
                        style: ppBody(15, color: ppInk, w: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis)),
                const SizedBox(width: 10),
                Text('★ ${e.ratingValue.toStringAsFixed(1)}',
                    style: ppBody(12.5, color: ppCoral, w: FontWeight.w700)),
              ]),
              const SizedBox(height: 3),
              Text(e.blurb.isNotEmpty ? e.blurb : e.credential,
                  style: ppBody(12.5, h: 1.45), maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 8),
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: e.availableToday ? ppCoralTint : ppPanel,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(e.availableToday ? 'Today' : 'Tomorrow',
                      style: ppBody(10.5, color: e.availableToday ? ppCoral : ppMuted, w: FontWeight.w700)),
                ),
                const SizedBox(width: 8),
                if (e.timings.isNotEmpty)
                  Expanded(
                      child: Text(e.timings,
                          style: ppBody(11.5, color: ppMuted), maxLines: 1, overflow: TextOverflow.ellipsis))
                else
                  const Spacer(),
                const SizedBox(width: 8),
                Text('₹${e.priceValue}', style: ppBody(14, color: ppInk, w: FontWeight.w700)),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}
