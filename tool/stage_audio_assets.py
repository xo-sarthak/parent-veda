"""Copy generated narration into assets/ so the app can play it locally.

TEMPORARY BY DESIGN. The audio belongs on R2, fetched once and cached by
StorageService - bundling ~105 MB into the APK is not something to ship. This
exists so playback can be wired and felt on a device before hosting is set up,
and so the swap to R2 is a change in ONE place (NarrationService._sourceFor).

    python tool/stage_audio_assets.py            # everything
    python tool/stage_audio_assets.py --weeks 18,19,20,21,22
"""

import json
import os
import shutil
import sys

SRC = 'build/audio'
DST = 'assets/narration'


def main():
    only = None
    if '--weeks' in sys.argv:
        only = set(sys.argv[sys.argv.index('--weeks') + 1].split(','))

    manifest = json.load(open(os.path.join(SRC, 'manifest_hi.json'),
                              encoding='utf-8'))
    os.makedirs(os.path.join(DST, 'hi'), exist_ok=True)

    staged, bytes_ = {}, 0
    for key, meta in manifest.items():
        if only is not None and key.startswith('week'):
            wk = key.split('.')[0].replace('week', '')
            if wk not in only:
                continue
        src = os.path.join(SRC, meta['file'].replace('/', os.sep))
        if not os.path.exists(src):
            continue
        dst = os.path.join(DST, 'hi', key + '.mp3')
        shutil.copyfile(src, dst)
        staged[key] = meta
        bytes_ += os.path.getsize(dst)

    # The staged manifest lists ONLY what was copied, so the app never believes
    # in a file that is not there - a missing asset would throw at play time,
    # which is a worse failure than falling back to the on-device voice.
    with open(os.path.join(DST, 'manifest_hi.json'), 'w',
              encoding='utf-8') as f:
        json.dump(staged, f, ensure_ascii=False, indent=1, sort_keys=True)

    print('staged %d of %d passages, %.0f MB'
          % (len(staged), len(manifest), bytes_ / 1024 / 1024))
    print('assets/narration/  ->  add to pubspec if not already there')


if __name__ == '__main__':
    main()
