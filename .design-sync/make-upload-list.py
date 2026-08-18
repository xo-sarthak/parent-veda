"""Regenerate the upload manifest from the live ds-bundle/ immediately before upload.

Kept inside .design-sync/ deliberately: a stale list living in a temp dir is how
one repo's sync uploads another repo's design system.
"""
import collections
import json
import os

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'ds-bundle')
ROOT = os.path.normpath(ROOT)

SKIP_DIRS = {'_screenshots'}

files = []
for dirpath, dirnames, filenames in os.walk(ROOT):
    dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS and not d.startswith('.')]
    for name in filenames:
        rel = os.path.relpath(os.path.join(dirpath, name), ROOT)
        rel = rel.replace(os.sep, '/')
        if rel.startswith('.') or '/.' in rel:
            continue
        files.append(rel)

# _ds_sync.json is the anchor and is written LAST, in its own call.
files = sorted(f for f in files if f != '_ds_sync.json')

out = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'upload-list.json')
with open(out, 'w', encoding='utf-8') as fh:
    json.dump(files, fh, indent=0)

print('files to upload (excluding _ds_sync.json):', len(files))
print(collections.Counter(f.split('/')[0] for f in files))
