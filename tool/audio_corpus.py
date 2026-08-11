"""What gets narrated, and under what key.

Separate from generate_audio.py on purpose. That file knows how to turn text
into an mp3; this one knows which text is worth narrating and what to call it.
Keeping them apart means the scope can change without touching the synthesis,
and the synthesis can change without re-deciding scope.

THE KEY IS THE CONTRACT. It ends up in a manifest the app reads, so it must be
stable across runs and independent of the text - key on POSITION (week 20's
grow.body), never on a hash of the words, or every copy edit orphans its audio
and every duplicated sentence collides.

WHAT IS EXCLUDED, and why:
  - anything under ~40 characters: labels, chips, button text. Narrating
    "Save" helps nobody and triples the file count.
  - can_i / tests_scans / read_next by default: reference material, LOOKED UP
    rather than listened to. Available behind --include-reference when we know
    whether anyone presses play.
"""

import json
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from unwrap_t import calls   # noqa: E402

DEV = re.compile('[ऀ-ॿ]')
MIN_CHARS = 40

# Read-aloud content first: it is written to be spoken, so the voice earns the
# most there. Reference material last, and off by default.
DART_BODIES = [
    ('garbh', 'lib/data/garbh_data.dart'),
    ('rtb', 'lib/data/read_to_baby_data.dart'),
    ('spiritual', 'lib/data/spiritual_reading_data.dart'),
    # NOT 'week5': weekContent.json already owns `week5.*` for calendar
    # week 5, and this file is the separate deep-dive view. The two only
    # avoided overwriting each other because one uses numeric suffixes and
    # the other named ones - an accident, not a design.
    ('w5deep', 'lib/data/week5_full_data.dart'),
]
REFERENCE = [
    ('cani', 'lib/data/can_i_data.dart'),
    ('tests', 'lib/data/tests_scans_reports_data.dart'),
    ('reads', 'lib/data/read_next_data.dart'),
]


# Spoken lead-ins for fields whose meaning lives in an ON-SCREEN heading.
#
# This is the audio-specific failure the screen never has. `mythBuster.myth`
# reads correctly under a "Myth" label; narrated bare it is the app asserting
# something false in its own voice, and the correction only arrives afterwards.
# `skipThisWeek` is the same shape - "spending hours reading worst-case
# stories online" is advice TO do it, until you can see the heading.
#
# So the label becomes part of what is said. The screen is unchanged; only the
# text sent for synthesis gains a prefix.
SPOKEN_PREFIX = {
    'actionPlan.mythBuster.myth': 'एक आम ग़लतफ़हमी — ',
    'actionPlan.mythBuster.truth': 'सच यह है — ',
    'actionPlan.skipThisWeek': 'इस हफ़्ते यह न कीजिए — ',
    'actionPlan.doThisWeek': 'इस हफ़्ते यह कीजिए — ',
    'actionPlan.redFlags': 'डॉक्टर को कब बुलाना है — ',
    'reflectAndRemember.journalPrompt': 'लिखने के लिए — ',
    'reflectAndRemember.photoPrompt': 'तस्वीर के लिए — ',
    'reflectAndRemember.reflectionPrompt': 'सोचने के लिए — ',
    'garbhSanskar.affirmation': 'आज का संकल्प — ',
    'garbhSanskar.reflectionPrompt': 'सोचने के लिए — ',
    'partnerCorner.whatSheMayFeel': 'वे क्या महसूस कर सकती हैं — ',
    'partnerCorner.whatYouCanDo': 'आप क्या कर सकते हैं — ',
    'partnerCorner.oneMission': 'इस हफ़्ते का एक काम — ',
}


def spoken(key, text):
    """The text to SYNTHESISE for [key] - display text plus any lead-in."""
    field = '.'.join(key.split('.')[1:])
    return SPOKEN_PREFIX.get(field, '') + text


def _worth_narrating(hi):
    return bool(DEV.search(hi)) and len(hi) >= MIN_CHARS


def from_week_content(only_week=None):
    """weekContent.json -> (key, hindi). Key is week + JSON path."""
    doc = json.load(open('lib/data/weekContent.json', encoding='utf-8'))
    out = []

    def walk(node, path):
        if isinstance(node, dict):
            if set(node) == {'en', 'hi'}:
                if _worth_narrating(node['hi']):
                    out.append((path, node['hi']))
                return
            for k, v in node.items():
                walk(v, path + '.' + str(k))
        elif isinstance(node, list):
            for i, v in enumerate(node):
                walk(v, path + '.' + str(i))

    # A LIST of week objects, each carrying its own `week` number - not a map
    # keyed by week. Assuming the latter silently yielded zero passages, which
    # looked like "week 20 has no audio-worthy content" rather than a bug.
    for block in doc:
        wk = block.get('week')
        if only_week is not None and str(wk) != str(only_week):
            continue
        walk(block, 'week' + str(wk))
    return out


def from_dart(prefix, path):
    """A data file -> (key, hindi). Key is prefix + ordinal.

    Ordinal, not a slug of the text: the position in the file is what stays
    put when wording changes. Reordering entries WOULD shift keys, which is
    why the manifest is regenerated whole rather than merged.
    """
    src = open(path, encoding='utf-8').read()
    out = []
    n = 0
    for _s, _e, args in calls(src, '_t('):
        if len(args) != 2:
            continue
        hi = src[args[1][0]:args[1][1]].strip()
        hi = hi[1:-1] if hi[:1] in "'\"" else hi
        n += 1
        if _worth_narrating(hi):
            out.append((prefix + '.' + str(n), hi))
    return out


def corpus(scope='pilot', include_reference=False):
    """(key, hindi) for the requested scope."""
    if scope == 'pilot':
        items = from_week_content(only_week=20)[:12]
        items += from_dart('garbh', 'lib/data/garbh_data.dart')[:4]
        items += from_dart('rtb', 'lib/data/read_to_baby_data.dart')[:4]
        return items

    items = from_week_content()
    for prefix, path in DART_BODIES:
        items += from_dart(prefix, path)
    if include_reference:
        for prefix, path in REFERENCE:
            items += from_dart(prefix, path)
    return items


if __name__ == '__main__':
    scope = sys.argv[1] if len(sys.argv) > 1 else 'pilot'
    items = corpus(scope, include_reference='--include-reference' in sys.argv)
    chars = sum(len(t) for _, t in items)
    print('scope=%s  passages=%d  chars=%d' % (scope, len(items), chars))
    for k, t in items[:6]:
        # Windows consoles default to cp1252 and raise on Devanagari; the
        # counts above are the point, so degrade rather than crash.
        try:
            print('  %-28s %s' % (k, t[:56]))
        except UnicodeEncodeError:
            print('  %-28s [%d chars]' % (k, len(t)))
