// =============================================================================
//  Memory models - journal entries and photo memories (local only)
// =============================================================================

class JournalEntry {
  JournalEntry({
    required this.id,
    required this.week,
    required this.dateIso,
    required this.source,
    required this.prompt,
    required this.text,
    List<String>? photoPaths,
  }) : photoPaths = photoPaths ?? [];

  final String id;
  final int week;
  final String dateIso; // yyyy-MM-dd
  final String source; // bonding_ritual | reflect_remember
  final String prompt;
  String text;

  /// Up to two photo file paths attached to this note.
  List<String> photoPaths;

  Map<String, dynamic> toJson() => {
        'id': id,
        'week': week,
        'date': dateIso,
        'source': source,
        'prompt': prompt,
        'text': text,
        'photos': photoPaths,
      };

  factory JournalEntry.fromJson(Map<String, dynamic> j) => JournalEntry(
        id: (j['id'] ?? '').toString(),
        week: (j['week'] is int) ? j['week'] : int.tryParse('${j['week']}') ?? 0,
        dateIso: (j['date'] ?? '').toString(),
        source: (j['source'] ?? '').toString(),
        prompt: (j['prompt'] ?? '').toString(),
        text: (j['text'] ?? '').toString(),
        photoPaths: (j['photos'] is List)
            ? (j['photos'] as List).map((e) => e.toString()).toList()
            : <String>[],
      );
}

class PhotoMemory {
  PhotoMemory({
    required this.id,
    required this.week,
    required this.dateIso,
    required this.path,
  });

  final String id;
  final int week;
  final String dateIso;
  final String path;

  Map<String, dynamic> toJson() => {
        'id': id,
        'week': week,
        'date': dateIso,
        'path': path,
      };

  factory PhotoMemory.fromJson(Map<String, dynamic> j) => PhotoMemory(
        id: (j['id'] ?? '').toString(),
        week: (j['week'] is int) ? j['week'] : int.tryParse('${j['week']}') ?? 0,
        dateIso: (j['date'] ?? '').toString(),
        path: (j['path'] ?? '').toString(),
      );
}
