// =============================================================================
//  YogaInstructorScreen — the teacher behind the class
// -----------------------------------------------------------------------------
//  For a live class, and especially a 1:1, the instructor IS the product — you
//  are booking a person, not a video. The class detail had their bio inline but
//  no way to open THEM: who they are, what they focus on, their rating, and
//  every other class they teach. Tapping the instructor row on a class now
//  opens this, built entirely from data already on the YogaClass (name,
//  credential, bio, focus, rating) plus classesByInstructor for their roster.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';
import 'pp_yoga_data.dart';
import 'yoga_common.dart';

class YogaInstructorScreen extends StatelessWidget {
  const YogaInstructorScreen({super.key, required this.source});

  /// Any one class this instructor teaches — we read their details off it.
  final YogaClass source;

  Widget _pad(Widget c) =>
      Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  @override
  Widget build(BuildContext context) {
    final tint = yogaTint(source.seed + 2);
    final classes = [
      source,
      ...classesByInstructor(source.instructorName, excludeId: source.id),
    ];
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 40),
          children: [
            _pad(ppBack(context, source.title)),
            const SizedBox(height: 18),

            // Identity
            _pad(Row(children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: ppBorder, width: 2)),
                clipBehavior: Clip.antiAlias,
                child: PpStriped(height: 76, colorA: tint.$1, colorB: tint.$2),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Flexible(
                          child: Text(source.instructorName,
                              style: ppFraunces(26, h: 1.05),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.verified_rounded,
                            size: 19, color: ppPurple),
                      ]),
                      const SizedBox(height: 4),
                      Text(source.instructorCredential,
                          style: ppBody(12.5, color: ppSoft, h: 1.35),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ]),
              ),
            ])),
            const SizedBox(height: 14),
            _pad(yogaStars(source.rating, source.reviewsCount)),

            // Bio
            if (source.instructorBio.isNotEmpty) ...[
              const SizedBox(height: 22),
              _pad(Text('About', style: ppJakarta(17))),
              const SizedBox(height: 10),
              _pad(Text(source.instructorBio,
                  style: ppBody(14.5, color: ppInk, h: 1.6))),
            ],

            // Focus
            if (source.instructorFocus.isNotEmpty) ...[
              const SizedBox(height: 22),
              _pad(Text('Works most with', style: ppJakarta(17))),
              const SizedBox(height: 12),
              _pad(Wrap(spacing: 8, runSpacing: 8, children: [
                for (final f in source.instructorFocus)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 13, vertical: 8),
                    decoration: BoxDecoration(
                        color: ppPanel,
                        borderRadius: BorderRadius.circular(999)),
                    child: Text(f,
                        style: ppBody(12.5, color: ppInk, w: FontWeight.w600)),
                  ),
              ])),
            ],

            // Their classes
            const SizedBox(height: 26),
            _pad(Text('Classes with ${source.instructorName.split(' ').first}',
                style: ppJakarta(17))),
            const SizedBox(height: 12),
            for (final c in classes) _pad(_classRow(context, c)),
          ],
        ),
      ),
    );
  }

  Widget _classRow(BuildContext context, YogaClass c) => GestureDetector(
        // Pop back to the class list root only if tapping a DIFFERENT class, so
        // we don't stack duplicate detail screens.
        onTap: () => Navigator.of(context).maybePop(),
        behavior: HitTestBehavior.opaque,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ppHair),
          ),
          child: Row(children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.title,
                        style: ppBody(14, color: ppInk, w: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 3),
                    Text('${c.durationLabel} · ${c.price.split('·').first.trim()}',
                        style: ppBody(11.5, color: ppSoft),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ]),
            ),
            yogaModeBadge(c.mode),
          ]),
        ),
      );
}
