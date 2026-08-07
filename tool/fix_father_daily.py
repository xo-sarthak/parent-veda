"""The hand fixes father_daily_screen needs after its glossary is applied.

A FILE, and asserted, because the throwaway version of this destroyed the
screen: a one-liner passed a hand-built fake match object into re.sub, and for
every pair it decided not to change it returned None, which the regex engine
wrote back as an empty string. 96 `_t(...)` calls became nothing at all -
`return ;` where a label used to be - and because the English half went with
them the file could not be re-applied, only restored from git.

Every replacement below is exact-string and asserted. Nothing here is a regex
over source it does not fully understand.

    python tool/fix_father_daily.py [--dry]
"""

import sys

PATH = 'lib/screens/father/father_daily_screen.dart'

GREETING_OLD = (
    "    final part = hour < 12 ? 'morning' : "
    "(hour < 18 ? 'afternoon' : 'evening');")
GREETING_NEW = (
    "    // Bilingual, because it is INTERPOLATED into the greeting. Left as an\n"
    "    // English word it produced 'शुभ evening, Arjun' - the sentence around\n"
    "    // it translated and the word inside it not, which is worse than\n"
    "    // leaving the whole line English.\n"
    "    final part = hour < 12\n"
    "        ? _t('morning', 'प्रभात')\n"
    "        : (hour < 18 ? _t('afternoon', 'दोपहर') : _t('evening', 'संध्या'));")

# (old, new, how many occurrences are expected)
FIXES = [
    # A person's name is not copy, and code reads _dadName[0] for the avatar.
    ("static const String _dadName = _t('Arjun', 'Arjun').now;",
     "static const String _dadName = 'Arjun';", 1),
    # _t() is a function, so nothing holding one can be const.
    ("    const sub = _t(", "    final sub = _t(", 1),
    # The resolver stacked suffixes onto null and enum comparisons, which are
    # not text at all.
    ('_readAloudToday.now == null', '_readAloudToday == null', 1),
    ('today.now == null', 'today == null', 1),
    ('e.type.now == JournalEntryType.noteForBaby',
     'e.type == JournalEntryType.noteForBaby', 1),
    # This helper returns a bilingual label now, so its branches must not
    # resolve - the caller does.
    ('  String _journalKindLabel(JournalEntry e) {',
     '  LocalizedText _journalKindLabel(JournalEntry e) {', 1),
    ("if (e.images.isNotEmpty) return _t('Photo', 'फ़ोटो').now;",
     "if (e.images.isNotEmpty) return _t('Photo', 'फ़ोटो');", 1),
    ("if (e.audios.isNotEmpty) return _t('Voice', 'आवाज़').now;",
     "if (e.audios.isNotEmpty) return _t('Voice', 'आवाज़');", 1),
    ('Text(_journalKindLabel(recent).toUpperCase(),',
     'Text(_journalKindLabel(recent).now.toUpperCase(),', 1),
    # `?? _t(...)` makes the whole expression Object; resolve at the
    # fallback. Only the tail is replaced - the three sites sit at different
    # indents, and reflowing them here would mangle two of the three.
    ("_t('Week ${m.anchorWeek}', 'हफ़्ता ${m.anchorWeek}'),",
     "_t('Week ${m.anchorWeek}', 'हफ़्ता ${m.anchorWeek}').now,", 3),
    # Pure interpolation with identical halves - never was copy.
    ("(a.time.isNotEmpty ? _t(' · ${a.time}', ' · ${a.time}') : ''),",
     "(a.time.isNotEmpty ? ' · ${a.time}' : ''),", 1),
]


def main():
    dry = '--dry' in sys.argv
    src = open(PATH, encoding='utf-8', newline='').read()

    n = src.count(GREETING_OLD)
    if n != 2:
        sys.exit('expected 2 greeting sites, found ' + str(n))
    src = src.replace(GREETING_OLD, GREETING_NEW)
    print('greeting: 2 sites made bilingual')

    for old, new, want in FIXES:
        got = src.count(old)
        if got != want:
            sys.exit('expected ' + str(want) + ' of ' + repr(old[:48])
                     + ', found ' + str(got))
        src = src.replace(old, new)
    print('applied ' + str(len(FIXES)) + ' exact fixes, all counts as expected')

    if dry:
        print('(dry run - nothing written)')
        return
    open(PATH, 'w', encoding='utf-8', newline='').write(src)


if __name__ == '__main__':
    main()
