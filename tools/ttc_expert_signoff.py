"""Regenerates docs/TTC-EXPERT-SIGNOFF.md from the code: every TTC read, door carousel and film, grouped by the
expert named on it. Run from the repo root:  py -3.11 tools/ttc_expert_signoff.py

Written 2026-09-26 in the TTC warmth pass. ⚠️ It rewrites the whole file, so the Sent / Signed off columns are
blank again afterwards: copy any dates across before re-running, or fill them in after.
"""
import re, glob, os, collections
os.chdir(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
LIT = r"(?:'(?:[^'\\\n]|\\.)*'|\"(?:[^\"\\\n]|\\.)*\")"

def join(expr):
    parts = re.findall(r"'((?:[^'\\\n]|\\.)*)'|\"((?:[^\"\\\n]|\\.)*)\"", expr)
    return ''.join(a or b for a, b in parts).replace("\\'", "'")

by = collections.defaultdict(list)
# reads
for f in sorted(glob.glob('lib/ttc/reads/*.dart')):
    s = open(f, encoding='utf-8').read()
    for m in re.finditer(r"PvRead\(\s*id:\s*'([^']+)'(.*?)author:\s*_en\((" + LIT + r")\)", s, re.S):
        rid, body, auth = m.group(1), m.group(2), join(m.group(3))
        t = re.search(r"title:\s*_en\(((?:\s*" + LIT + r")+)\)", body)
        title = join(t.group(1)) if t else rid
        door = os.path.basename(f).replace('ttc_reads_', '').replace('.dart', '').replace('_', ' ')
        by[auth].append(('Read', door, title, rid))
# door carousels (reviewedBy)
for f in sorted(glob.glob('lib/ttc/focus/*.dart')) + ['lib/screens/ttc/ttc_focus_screen.dart']:
    s = open(f, encoding='utf-8').read()
    s = re.sub(r'/\*.*?\*/', '', s, flags=re.S)
    s = re.sub(r'(?m)^\s*//.*$', '', s)
    for m in re.finditer(r"reviewedBy:\s*'([^']+)'", s):
        who = m.group(1).replace('Reviewed by ', '').split(',')[0]
        pre = s[:m.start()]
        # The TILE's title, which is the id in kTtcSignedOffStories
        # (2026-09-28). The last `title:` before the byline was a slide's
        # title on most carousels ("A blood test gives the answer."). Kept
        # for revert:
        # tm = list(re.finditer(r"(?:coverTitle|title):\s*'((?:[^'\\]|\\.)*)'", pre))
        # title = tm[-1].group(1) if tm else '?'
        in_door = '/focus/' in f.replace('\\', '/')
        tiles = list(re.finditer(r"Ttc(?:Carousel|Infographic)Tile\(", pre)) if in_door else []
        tm = re.search(r"title:\s*((?:\s*" + LIT + r")+)", pre[tiles[-1].end():]) if tiles else None
        title = join(tm.group(1)) if tm else None
        if title is None:  # a story built in code, not a door tile
            tm = list(re.finditer(r"(?:coverTitle|title):\s*'((?:[^'\\]|\\.)*)'", pre))
            title = tm[-1].group(1) if tm else 'Every door myth (the story built in code)'
        door = os.path.basename(f).replace('ttc_focus_', '').replace('.dart', '').replace('_', ' ')
        by[who].append(('Door carousel', door, title.replace("\\'", "'"), ''))
# videos
s = open('lib/ttc/ttc_videos_data.dart', encoding='utf-8').read()
for m in re.finditer(r"id:\s*'([^']+)'(.*?)expert:\s*_en\((" + LIT + r")\)", s, re.S):
    t = re.search(r"title:\s*_en\(((?:\s*" + LIT + r")+)\)", m.group(2))
    by[join(m.group(3))].append(('Film (not yet made)', '', join(t.group(1)) if t else m.group(1), m.group(1)))

out = ["# TTC expert sign-off list",
       "",
       "Written 2026-09-26 in the TTC warmth pass. The made-up reviewer names in TTC were replaced with real people",
       "from the expert roster (`Downloads/MASTER-CONTENT-PLAN-v3.xlsx`, sheet \"Expert roster\"), or with",
       "\"ParentVeda team\" where no roster expert fits. This is the list to send each expert before launch. Where an",
       "expert asks for changes, the text changes.",
       "",
       "**Until a piece is signed off, the app does not name its expert (launch sanity H14, 2026-09-28).** A read, a",
       "door carousel or an infographic shows \"By ParentVeda team\" with no tick. When an expert signs a piece off,",
       "fill in its Signed off date here and, in the same commit, add it to that expert's set in",
       "`lib/ttc/ttc_expert_signoff.dart`: a read by its id in `kTtcSignedOffReads`, a door carousel or infographic",
       "by its Title as listed here in `kTtcSignedOffStories` (tiles have no id; the title is the id). That one line",
       "brings back \"Reviewed by\" and the tick. `test/ttc_expert_signoff_test.dart` holds the rule.",
       "",
       "Films are placeholders (nothing filmed yet); the name on a film is the plan for who presents it.",
       "",
       "**Status (2026-09-26): nothing sent yet.** The user will send these later. Fill in the Sent and Signed off",
       "columns with dates as it happens. Keep this list current: whenever a TTC read, door carousel or film",
       "changes its named expert, run `py -3.11 tools/ttc_expert_signoff.py` (it reads the code, so the list always matches the app).",
       ""]
for who in sorted(by, key=lambda w: (-len(by[w]), w)):
    items = by[who]
    out.append('## %s (%d)' % (who, len(items)))
    out.append('')
    out.append('| Kind | Door | Title | id | Sent | Signed off |')
    out.append('|---|---|---|---|---|---|')
    for k, d, t, i in items:
        out.append('| %s | %s | %s | %s | | |' % (k, d, t.replace('|', '/'), ('`%s`' % i) if i else ''))
    out.append('')
out.append("""## Gaps and notes

- **No male-fertility specialist on the roster.** The ten His side reads say "By ParentVeda team" with no tick.
  Adding an andrologist or urologist to the "still to hire" list would let them carry a real reviewer.
- **Dr Ruchika Sood carries most of TTC.** The roster already calls her the single sign-off bottleneck; this list
  makes that concrete. Dr Simranpreet Sandhu (IVF counsellor) could take the IVF basics reads if the roster owner
  agrees.
- **Dr Ruchika Sood is not in the app's expert directory (`kExperts`)**, so tapping her byline may not open a
  profile yet.
- Out of TTC scope but carrying the same made-up names: `lib/data/community_data.dart` and
  `lib/data/mind_mood_data.dart` (pregnancy and community), plus pregnancy reads.
""")
open('docs/TTC-EXPERT-SIGNOFF.md', 'w', encoding='utf-8', newline='\n').write('\n'.join(out))
print({k: len(v) for k, v in by.items()})
