// =============================================================================
//  Memories — the domain
// -----------------------------------------------------------------------------
//  A "Memory" is a beautiful keepsake card a parent makes for one of two
//  milestones: announcing a pregnancy ("We're Expecting") or a birth ("Welcome
//  Baby"). The whole design philosophy: a timeless family keepsake first, a
//  shareable image second. Templates do ALL the layout — the parent only fills
//  in the words and a photo, never moves or resizes anything.
//
//  EXTENSIBILITY: adding a future memory type (Baby Shower, First Birthday…) is
//  a new [MemoryType] value + templates registered for it — no screen changes.
//  Adding a template is one entry in memory_templates.dart.
// =============================================================================

import 'package:flutter/material.dart';

/// The milestones. Only two ship now; the enum is where future ones slot in.
enum MemoryType { expecting, welcomeBaby }

extension MemoryTypeX on MemoryType {
  String get label =>
      this == MemoryType.expecting ? "We're Expecting" : 'Welcome Baby';
  String get emoji => this == MemoryType.expecting ? '🤰' : '👶';
  String get blurb => this == MemoryType.expecting
      ? 'Announce your pregnancy beautifully.'
      : 'Share the happiest news.';
}

/// The two export shapes. Logical [size] is what templates lay out against;
/// export multiplies by [exportScale] for a crisp 1080-wide image.
enum MemoryFormat { square, portrait }

extension MemoryFormatX on MemoryFormat {
  Size get size => this == MemoryFormat.square
      ? const Size(360, 360)
      : const Size(360, 640);
  double get exportScale => 3.0; // 360 -> 1080
  String get label => this == MemoryFormat.square ? 'Square' : 'Portrait';
}

/// A visual family, for the picker label. The look itself comes from the
/// template + palette.
enum MemoryStyle { minimal, elegant, floral, modern, indian, watercolour, neutral }

extension MemoryStyleX on MemoryStyle {
  String get label => switch (this) {
        MemoryStyle.minimal => 'Minimal',
        MemoryStyle.elegant => 'Elegant',
        MemoryStyle.floral => 'Floral',
        MemoryStyle.modern => 'Modern',
        MemoryStyle.indian => 'Indian',
        MemoryStyle.watercolour => 'Watercolour',
        MemoryStyle.neutral => 'Neutral',
      };
}

/// A colour world a template renders in. Kept small and calm on purpose.
@immutable
class MemoryPalette {
  const MemoryPalette({
    required this.bg,
    required this.ink,
    required this.soft,
    required this.accent,
    required this.panel,
  });

  final List<Color> bg; // 1 = solid, 2 = gradient
  final Color ink; // headings
  final Color soft; // secondary text
  final Color accent; // decorative lines / small marks
  final Color panel; // photo frame / soft panels
}

/// The parent's photo plus how they positioned it (pinch-zoom + drag). The
/// template decides the FRAME; this only pans/zooms within it.
class MemoryPhoto {
  MemoryPhoto(this.path, {this.scale = 1.0, this.offset = Offset.zero});
  final String path;
  double scale;
  Offset offset;
}

/// Everything editable, across both types. Fields are used per type; only the
/// baby name is ever required.
class MemoryData {
  MemoryData({required this.type});
  MemoryType type;

  // Pregnancy
  String coupleNames = '';
  String dueMonth = '';

  // Birth
  String babyName = '';
  String birthDate = '';
  String birthTime = '';
  String weight = '';
  String length = '';
  String parentNames = '';

  // Shared
  String message = '';
  MemoryPhoto? photo;

  MemoryData copy() {
    final d = MemoryData(type: type)
      ..coupleNames = coupleNames
      ..dueMonth = dueMonth
      ..babyName = babyName
      ..birthDate = birthDate
      ..birthTime = birthTime
      ..weight = weight
      ..length = length
      ..parentNames = parentNames
      ..message = message
      ..photo = photo == null
          ? null
          : MemoryPhoto(photo!.path,
              scale: photo!.scale, offset: photo!.offset);
    return d;
  }
}

/// A designed template: given the data, it renders the whole card at the
/// format's logical size. The parent never touches the layout.
@immutable
class MemoryTemplate {
  const MemoryTemplate({
    required this.id,
    required this.type,
    required this.style,
    required this.name,
    required this.format,
    required this.palette,
    required this.usesPhoto,
    required this.builder,
  });

  final String id;
  final MemoryType type;
  final MemoryStyle style;
  final String name;
  final MemoryFormat format;
  final MemoryPalette palette;
  final bool usesPhoto;

  /// Renders the card content, sized to [format].size. Wrapped by the preview
  /// (scaled) and the exporter (RepaintBoundary at exportScale).
  final Widget Function(MemoryTemplate t, MemoryData data) builder;
}
