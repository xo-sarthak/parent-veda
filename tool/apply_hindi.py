#!/usr/bin/env python3
"""Apply Devanagari Hindi into weekContent.json, keyed by week + JSON path.

WHY THIS EXISTS
---------------
weekContent.json holds 1,658 {en, hi} pairs across 37 weeks. The `hi` side was
Hinglish in Latin script, which a hi-IN text-to-speech engine cannot read - it
either mispronounces it with English phonetics or fails silently. The whole
file is being rewritten into Devanagari so the app can both display and SPEAK
Hindi. The original Hinglish is preserved verbatim in weekContent.hinglish.json
(JSON cannot carry comments, so a sibling file is how "comment out, never
delete" applies here).

Translations arrive per week as a TSV of:

    <json path>\t<devanagari>

...so a batch can be reviewed as plain text before it touches the JSON, and the
file's structure is never hand-edited. Paths look like:

    babySnapshot.reveal
    momJourney.commonSymptoms[2]
    nutrition.indianSuperfoodOfTheWeek.benefit

USAGE
    python tool/apply_hindi.py <week-number> <tsv-file>

It refuses to write unless every path in the TSV resolves to a real {en, hi}
pair - a typo'd path is a silently skipped translation, which would leave one
string in Hinglish with nothing to flag it.
"""
import json
import re
import sys

DATA = "lib/data/weekContent.json"

STEP = re.compile(r"([^.\[\]]+)|\[(\d+)\]")


def resolve(root, path):
    """Walk a dotted/indexed path to the {en, hi} dict it names."""
    node = root
    for name, idx in STEP.findall(path):
        if name:
            if not isinstance(node, dict) or name not in node:
                return None
            node = node[name]
        else:
            i = int(idx)
            if not isinstance(node, list) or i >= len(node):
                return None
            node = node[i]
    if isinstance(node, dict) and set(node.keys()) == {"en", "hi"}:
        return node
    return None


def main():
    if len(sys.argv) != 3:
        print(__doc__)
        sys.exit(2)
    week = int(sys.argv[1])
    tsv = sys.argv[2]

    weeks = json.load(open(DATA, encoding="utf-8"))
    target = next((w for w in weeks if w.get("week") == week), None)
    if target is None:
        sys.exit(f"week {week} not found in {DATA}")

    pairs, bad = [], []
    for line in open(tsv, encoding="utf-8"):
        line = line.rstrip("\n")
        if not line.strip() or line.lstrip().startswith("#"):
            continue
        path, _, hindi = line.partition("\t")
        node = resolve(target, path.strip())
        if node is None:
            bad.append(path.strip())
        else:
            pairs.append((node, hindi))

    if bad:
        sys.exit("unresolved paths (nothing written):\n  " + "\n  ".join(bad))

    for node, hindi in pairs:
        node["hi"] = hindi

    with open(DATA, "w", encoding="utf-8", newline="\n") as f:
        json.dump(weeks, f, ensure_ascii=False, indent=2)
        f.write("\n")
    print(f"week {week}: {len(pairs)} strings written")


if __name__ == "__main__":
    main()
