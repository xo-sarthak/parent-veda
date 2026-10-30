// Reads every community migration the way Postgres would apply them: in
// file order, with the LAST definition of a function winning. Phase 1's
// tests read 0121 by a fixed path, so a later migration that replaced a
// function was invisible to them; this is the shared reader they use now.
import 'dart:io';

class CommunitySql {
  CommunitySql._(this.files);

  /// (file name, contents), in apply order.
  final List<(String, String)> files;

  static CommunitySql load() {
    final dir = Directory('supabase/migrations');
    final names = [
      for (final f in dir.listSync())
        if (f is File && f.uri.pathSegments.last.contains('community') && f.path.endsWith('.sql'))
          f.uri.pathSegments.last,
    ]..sort();
    return CommunitySql._([
      for (final n in names) (n, File('supabase/migrations/$n').readAsStringSync()),
    ]);
  }

  String get all => files.map((f) => f.$2).join('\n');

  /// Index of the file a name lives in, for "is this grant later than that drop".
  int indexOf(String name) => files.indexWhere((f) => f.$1 == name);

  /// function name -> (declared parameter names, body, file index), last wins.
  ///
  /// The argument list is read by counting parentheses, so a default such
  /// as `p_scope text default 'for_you'` or `p_at timestamptz default now()`
  /// does not end it early (the old regex stopped at the first `)`).
  Map<String, ({Set<String> params, String body, int file})> functions() {
    final out = <String, ({Set<String> params, String body, int file})>{};
    final head = RegExp(r'create or replace function public\.(\w+)\(');
    for (var i = 0; i < files.length; i++) {
      final src = files[i].$2;
      for (final m in head.allMatches(src)) {
        var depth = 1;
        var k = m.end;
        while (k < src.length && depth > 0) {
          final ch = src[k];
          if (ch == '(') depth++;
          if (ch == ')') depth--;
          k++;
        }
        final args = src.substring(m.end, k - 1);
        final bodyStart = src.indexOf(r'$$', k);
        final bodyEnd = bodyStart < 0 ? -1 : src.indexOf(r'$$', bodyStart + 2);
        out[m.group(1)!] = (
          params: {
            for (final p in _topLevelSplit(args))
              if (p.trim().isNotEmpty) p.trim().split(RegExp(r'\s+')).first,
          },
          body: bodyStart < 0 || bodyEnd < 0 ? '' : src.substring(bodyStart + 2, bodyEnd),
          file: i,
        );
      }
    }
    return out;
  }

  /// The file index of the last `drop function ... public.<fn>(`, or -1.
  int lastDrop(String fn) {
    var at = -1;
    for (var i = 0; i < files.length; i++) {
      if (files[i].$2.contains('drop function if exists public.$fn(')) at = i;
    }
    return at;
  }

  /// Every `grant execute on function … to authenticated;` block, with its file.
  List<(int, String)> grants() => _blocks(RegExp(r'grant execute on function([\s\S]*?)to authenticated;'));

  /// Every `revoke all on function … from public, anon;` block, with its file.
  List<(int, String)> anonRevokes() => _blocks(RegExp(r'revoke all on function([\s\S]*?)from public, anon;'));

  /// Every `revoke all on function … from public, anon, authenticated;` block.
  List<(int, String)> appRevokes() =>
      _blocks(RegExp(r'revoke all on function([\s\S]*?)from public, anon, authenticated;'));

  List<(int, String)> _blocks(RegExp re) => [
        for (var i = 0; i < files.length; i++)
          for (final m in re.allMatches(files[i].$2)) (i, m.group(1)!),
      ];

  static List<String> _topLevelSplit(String s) {
    final out = <String>[];
    var depth = 0;
    var quoted = false;
    var start = 0;
    for (var i = 0; i < s.length; i++) {
      final ch = s[i];
      if (ch == "'") quoted = !quoted;
      if (quoted) continue;
      if (ch == '(') depth++;
      if (ch == ')') depth--;
      if (ch == ',' && depth == 0) {
        out.add(s.substring(start, i));
        start = i + 1;
      }
    }
    out.add(s.substring(start));
    return out;
  }
}
