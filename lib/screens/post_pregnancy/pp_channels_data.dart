// =============================================================================
//  ParentVeda Watch - channels (an expert + all their content)
// -----------------------------------------------------------------------------
//  A Channel gathers everything one expert has made across Watch into a single
//  YouTube-style page: Videos, Podcasts, Shorts, Courses and Masterclasses, with
//  a Subscribe relationship (WatchStore, shared with Follow). It is derived, not
//  authored: the video/short/podcast buckets are just filtered views of the
//  Watch catalog, so adding a video automatically shows up on its expert's
//  channel. Courses & Masterclasses are DISPLAY-ONLY stubs here (that module is
//  being rebuilt in parallel) - tapping one calls openExpertCourses(...) in
//  watch_channel_screen.dart, which the integrator rewires later.
// =============================================================================

import 'pp_experts_data.dart';
import 'pp_watch_data.dart';

/// A course/masterclass card shown on a channel. Purely for display - it does
/// NOT reach into the (parallel-rebuild) Courses module; on tap the channel
/// screen calls openExpertCourses(context, expertId).
class ChannelCourse {
  const ChannelCourse({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.lessons,
    required this.seed,
    this.masterclass = false,
  });

  final String id;
  final String title;
  final String subtitle;
  final int lessons; // "8 lessons" (course) / duration in minutes shown by caller
  final int seed;
  final bool masterclass; // false = course, true = single masterclass session
}

/// A channel = one expert + their content buckets. Cheap to construct (it just
/// filters the shared catalog), so build one anywhere with WatchChannel(id).
class WatchChannel {
  const WatchChannel(this.expertId);
  final String expertId;

  Expert get expert => expertById(expertId);
  String get name => expert.name;
  String get credential => expert.credential;

  /// A tidy @handle from the name ("Dr. Ananya Rao" -> "@ananyarao").
  String get handle {
    final cleaned = name
        .replaceAll(RegExp(r'(?:^|\s)(dr|mr|mrs|ms)\.?\s', caseSensitive: false), ' ')
        .toLowerCase()
        .replaceAll(RegExp('[^a-z]'), '');
    return '@$cleaned';
  }

  List<WatchVideo> get videos =>
      kWatchVideos.where((v) => v.expertId == expertId && !v.quick && !v.isPodcast).toList();
  List<WatchVideo> get shorts =>
      kWatchVideos.where((v) => v.expertId == expertId && v.quick).toList();
  List<WatchVideo> get podcasts =>
      kWatchPodcasts.where((v) => v.expertId == expertId).toList();

  List<ChannelCourse> get courses =>
      (_channelExtras[expertId] ?? _fallbackExtras(expert)).where((c) => !c.masterclass).toList();
  List<ChannelCourse> get masterclasses =>
      (_channelExtras[expertId] ?? _fallbackExtras(expert)).where((c) => c.masterclass).toList();

  int get contentCount => videos.length + shorts.length + podcasts.length;

  /// A short "X videos · Y shorts · Z podcasts" line for the channel header.
  String get statsLine {
    final parts = <String>[];
    if (videos.isNotEmpty) parts.add('${videos.length} ${videos.length == 1 ? 'video' : 'videos'}');
    if (shorts.isNotEmpty) parts.add('${shorts.length} shorts');
    if (podcasts.isNotEmpty) parts.add('${podcasts.length} ${podcasts.length == 1 ? 'podcast' : 'podcasts'}');
    return parts.isEmpty ? 'New content coming soon' : parts.join('  ·  ');
  }
}

/// Look up (or synthesise) a channel by expert id. Always succeeds - falls back
/// to the first expert if the id is unknown.
WatchChannel channelById(String expertId) =>
    WatchChannel(kExperts.any((e) => e.id == expertId) ? expertId : kExperts.first.id);

/// Every expert who has at least one piece of Watch content, richest first.
/// Backs the "suggested channel" interstitials in the home feed.
List<WatchChannel> allWatchChannels() {
  final ids = <String>{
    for (final v in kWatchVideos) v.expertId,
    for (final v in kWatchPodcasts) v.expertId,
  };
  final list = ids.map(WatchChannel.new).toList()
    ..sort((a, b) => b.contentCount.compareTo(a.contentCount));
  return list;
}

// ---- course / masterclass stubs (display-only) ------------------------------
//  Hand-authored so each channel reads convincingly. These do NOT import the
//  Courses module; they exist only to render the section. Real courses slot in
//  when the unified Courses & Masterclasses section is wired via openExpertCourses.
const Map<String, List<ChannelCourse>> _channelExtras = {
  'ananya': [
    ChannelCourse(id: 'c_sleepfound', title: 'Gentle Sleep Foundations', subtitle: 'A no-cry-it-out path through the 4-month shift', lessons: 8, seed: 41),
    ChannelCourse(id: 'm_sleepnight', title: 'The 4-Month Sleep Masterclass', subtitle: 'Live · her most-attended session', lessons: 90, seed: 42, masterclass: true),
  ],
  'kabir': [
    ChannelCourse(id: 'c_leaps', title: 'Understanding the Leaps', subtitle: 'Wonder Weeks, decoded leap by leap', lessons: 10, seed: 43),
    ChannelCourse(id: 'm_fussy', title: 'Demystifying the Fussy Phases', subtitle: 'Live masterclass · Q&A included', lessons: 75, seed: 44, masterclass: true),
  ],
  'neha': [
    ChannelCourse(id: 'c_solids', title: 'Starting Solids, Calmly', subtitle: 'Readiness, first foods and safety', lessons: 6, seed: 45),
    ChannelCourse(id: 'm_vaccines', title: 'Vaccines Without the Panic', subtitle: 'Live masterclass for new parents', lessons: 60, seed: 46, masterclass: true),
  ],
  'meher': [
    ChannelCourse(id: 'c_soothe', title: 'The Soothing Toolkit', subtitle: 'Holds, routines and staying regulated', lessons: 7, seed: 47),
    ChannelCourse(id: 'm_cohort', title: 'Two-Week Gentle Sleep Cohort', subtitle: 'Small-group · led live with other parents', lessons: 120, seed: 48, masterclass: true),
  ],
  'meera': [
    ChannelCourse(id: 'c_safe', title: 'Room-by-Room Baby-Proofing', subtitle: 'A calm, practical home-safety course', lessons: 5, seed: 49),
    ChannelCourse(id: 'm_fourthtri', title: 'Minding the Parent', subtitle: 'Live masterclass on fourth-trimester wellbeing', lessons: 55, seed: 50, masterclass: true),
  ],
  'ritu': [
    ChannelCourse(id: 'c_weaning', title: 'Indian-First Weaning', subtitle: 'Mess-friendly, allergy-safe starts', lessons: 6, seed: 51),
    ChannelCourse(id: 'm_firstfoods', title: 'First Foods Masterclass', subtitle: 'Live · portions for real family kitchens', lessons: 50, seed: 52, masterclass: true),
  ],
};

/// A gentle default for any expert without hand-authored extras, built from
/// their credential so the section is never empty.
List<ChannelCourse> _fallbackExtras(Expert e) => [
      ChannelCourse(id: 'c_${e.id}', title: '${e.name.split(' ').last}\'s Parenting Course', subtitle: e.credential, lessons: 6, seed: e.name.length + 40),
      ChannelCourse(id: 'm_${e.id}', title: 'Live Masterclass with ${e.name}', subtitle: e.credential, lessons: 60, seed: e.name.length + 60, masterclass: true),
    ];
