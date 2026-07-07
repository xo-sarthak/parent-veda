// =============================================================================
//  BumpPhoto - one entry in "My Bump Journey" (the visual pregnancy timeline)
// -----------------------------------------------------------------------------
//  Not a gallery item - a keepsake. One photo per week, with an optional
//  caption, a favourite flag, and the gestational week/trimester it belongs to.
//  The image file lives in the app documents dir; only metadata is persisted.
// =============================================================================

import 'package:flutter/foundation.dart';

@immutable
class BumpPhoto {
  const BumpPhoto({
    required this.id,
    required this.imageUrl,
    required this.weekNumber,
    required this.date,
    this.caption = '',
    this.isFavorite = false,
  });

  final String id;
  final String imageUrl; // local file path
  final int weekNumber;
  final DateTime date;
  final String caption;
  final bool isFavorite;

  int get trimester => weekNumber <= 13 ? 1 : (weekNumber <= 27 ? 2 : 3);

  BumpPhoto copyWith({String? caption, bool? isFavorite}) => BumpPhoto(
        id: id,
        imageUrl: imageUrl,
        weekNumber: weekNumber,
        date: date,
        caption: caption ?? this.caption,
        isFavorite: isFavorite ?? this.isFavorite,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'imageUrl': imageUrl,
        'weekNumber': weekNumber,
        'date': date.toIso8601String(),
        'caption': caption,
        'isFavorite': isFavorite,
      };

  factory BumpPhoto.fromJson(Map<String, dynamic> j) => BumpPhoto(
        id: (j['id'] ?? '').toString(),
        imageUrl: (j['imageUrl'] ?? '').toString(),
        weekNumber: (j['weekNumber'] is int)
            ? j['weekNumber'] as int
            : int.tryParse('${j['weekNumber']}') ?? 0,
        date: DateTime.tryParse(j['date']?.toString() ?? '') ?? DateTime.now(),
        caption: (j['caption'] ?? '').toString(),
        isFavorite: j['isFavorite'] == true,
      );
}
