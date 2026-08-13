"""The one true placeholder regex for Dart string interpolation.

    $name        bare identifier - ASCII letters, digits, underscore, and it
                 must START with a letter or underscore
    ${anything}  braced, terminated by the closing brace

WHY THIS IS ITS OWN MODULE. Every validator in tool/ wrote `\\$\\w+` for the
bare form, and in Python `\\w` is UNICODE-AWARE. So `$weekवें हफ़्ते` - a
perfectly correct Hindi ordinal built on an interpolated week number - matched
as a single placeholder named `weekवें`, which then failed parity against the
English `$week` and blocked the translation.

Dart's own lexer stops the identifier at the first non-ASCII-word character, so
`$weekवें` really is `$week` followed by `वें`. The code was right and the
check was wrong, and the check would have rejected correct Hindi every time a
number was followed by a Devanagari suffix - which is most of the time, because
that is how Hindi forms ordinals.
"""

import re

PLACEHOLDER = re.compile(r'\$\{[^}]*\}|\$[A-Za-z_][A-Za-z0-9_]*')


def placeholders(s):
    """Sorted placeholder list, for parity comparison between en and hi."""
    return sorted(PLACEHOLDER.findall(s))


def parity(en, hi):
    return placeholders(en) == placeholders(hi)
