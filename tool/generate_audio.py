"""Pre-generate Hindi (and English) narration for ParentVeda's reading content.

WHY PRE-GENERATED, not on-device TTS at runtime:
  - the Hindi voice pack is missing on many budget Android phones, and
    flutter_tts fails SILENTLY when it is
  - every phone ships a different narrator, so there is no brand voice and no
    testable quality floor
  - it is free at our volume, once, instead of per listen

WHY SEGMENTED, not one API call per passage:
  Chirp 3 HD does not take SSML, and its own pauses are too short for
  read-aloud content - the first thing anyone noticed. Synthesising each
  paragraph (and optionally each sentence) separately and stitching them with
  measured silence gives exact control the voice does not offer.

  The real win is that pauses become RE-TUNABLE WITHOUT RE-SYNTHESISING. The
  segments are cached on disk by a hash of (text, voice, rate); changing the
  gap only re-runs ffmpeg. So "too fast between paragraphs" costs seconds, not
  another pass over the whole corpus.

AUTH: Application Default Credentials. Run once:
      gcloud auth application-default login
  No service-account key - the org policy blocks those, correctly. A key file
  is the thing that gets committed and leaked; ADC has nothing to leak.

    python tool/generate_audio.py --demo          # two files, A/B the pauses
    python tool/generate_audio.py --help
"""

import argparse
import base64
import hashlib
import json
import os
import re
import subprocess
import sys
import urllib.request

API = 'https://texttospeech.googleapis.com/v1/text:synthesize'
PROJECT = 'project-a0e0d549-3f82-419c-8a0'
VOICE_HI = 'hi-IN-Chirp3-HD-Callirrhoe'
VOICE_EN = 'en-IN-Chirp3-HD-Callirrhoe'

# NOT inside build/. That directory is Flutter's own scratch space and
# `flutter clean` exists to delete it - which it did, on 2026-08-18, taking
# 1,660 freshly-synthesised passages and the whole segment cache with it.
#
# The .gitignore reasoning for keeping audio out of git was sound: it is derived
# and regenerable. What nobody checked was WHERE it landed instead. "Derived and
# regenerable" is only cheap while re-running the recipe is free, and these cost
# API quota - so between synthesis and upload they are briefly irreplaceable,
# and they were sitting in the one directory in the repo with a documented
# self-destruct that any developer triggers without thinking.
#
# `.narration-cache/` is gitignored, outside build/, and survives flutter clean.
# The segment cache surviving also means a re-run is mostly free rather than
# full price.
OUT = '.narration-cache/audio'
CACHE = '.narration-cache/audio/.segments'

# Silence inserted between segments, in milliseconds.
#
# Zero, chosen by ear: 260/620 read as draggy against Chirp's own punctuation
# pauses, which are already doing the work. Kept as knobs rather than deleted
# because the segments are cached - raising these re-stitches in seconds and
# re-synthesises nothing, so the decision stays cheap to revisit.
GAP_SENTENCE = 0
GAP_PARAGRAPH = 0


_TOKEN = {'value': None, 'at': 0}


def token(force=False):
    """A short-lived OAuth token from the logged-in gcloud user.

    Cached and refreshed on an interval: gcloud tokens last about an hour and
    a full run is longer than that, so fetching once at the start would fail
    two thirds of the way through with a 401 and lose the un-cached work.
    """
    import time
    if not force and _TOKEN['value'] and time.time() - _TOKEN['at'] < 1800:
        return _TOKEN['value']
    _TOKEN['value'] = _fetch_token()
    _TOKEN['at'] = time.time()
    return _TOKEN['value']


def _fetch_token():
    r = subprocess.run('gcloud auth print-access-token', shell=True,
                       capture_output=True, text=True)
    if r.returncode:
        sys.exit('gcloud auth failed - run: '
                 'gcloud auth application-default login\n' + r.stderr[:300])
    return r.stdout.strip()


def clean(raw):
    """Dart source text -> the words a listener should hear.

    Adjacent string literals are how long prose is written in this codebase,
    so a passage arrives as  'para one\\n\\n'  '  '  'para two'  . The joins
    are syntax, not content, and reading them aloud would be gibberish.
    """
    raw = re.sub(r"'\s*\n\s*'", '', raw)      # drop adjacent-literal joins
    raw = raw.replace('\\n', '\n').replace("\\'", "'").replace('\\"', '"')
    return raw.strip()


# A comma only ends a segment when what precedes it is SHORT - a vocative or a
# brief opener like `माँ,`. That is the case where a fresh utterance fixes the
# schwa clipping, because the real clause then starts a sentence.
#
# Splitting at EVERY comma broke lists. `अगर ज़्यादा ब्लीडिंग, पेट में तेज़ दर्द,
# …, तो डॉक्टर को फ़ोन कीजिए।` became five separate utterances, each with its
# own falling, finished intonation - so a sentence building towards "call your
# doctor" instead sounded like five statements ending, and the passage read as
# unfinished. Content was intact; the prosody was not.
VOCATIVE_MAX = 16


def _split_sentences(para):
    """A paragraph -> the chunks to synthesise, one utterance each.

    Sentences FIRST, always. An earlier version tested the whole paragraph for
    list-ness and, when it matched, split on commas without ever splitting on
    the danda - so two sentences ran together inside one segment.

    Then, per sentence:
      * a LIST is split at its commas, so each item gets its own breath - which
        is how a person reads a warning list aloud
      * a short opener like the vocative `माँ,` is split off, and its comma
        dropped; that is what stops Chirp swallowing the first syllable of the
        word after it, while bare `माँ` keeps its own full length
      * ordinary prose is left whole, because splitting it at every comma made
        sentences sound like a run of finished statements

    `और` / `या` only DETECT a list - a Hindi list often carries one comma
    because the last item is joined by a conjunction. They are not split
    points: doing that left `खिंचाव` alone as a segment, and a one-word
    utterance gets clipped the same way `माँ,` did.
    """
    out = []
    for sent in re.split(r'(?<=[।?!])\s+', para):
        sent = sent.strip()
        if not sent:
            continue
        listish = sent.count(',') >= 3 or (
            sent.count(',') >= 1 and re.search(r'\s(और|या)\s', sent))
        if listish:
            out += [x.strip() for x in re.split(r'(?<=,)\s+', sent)
                    if x.strip()]
            continue
        head, _, rest = sent.partition(',')
        if rest.strip() and len(head) <= VOCATIVE_MAX:
            out.append(head.rstrip(',').strip())
            out.append(rest.strip())
        else:
            out.append(sent)
    return out


def segments(text):
    """(text, gap_after_ms) per chunk: paragraphs, then sentences, then commas.

    Splitting keys on the danda - Hindi's full stop - plus ? and !. A number
    like `3.1 cm` has no danda, so it survives; splitting on the Latin period
    would have cut it in half.

    COMMAS ARE SPLIT TOO, and that is a pronunciation fix, not a pacing one.
    Chirp drops the inherent schwa in some words when they sit mid-utterance:
    `माँ, हमारा आधा सफ़र` came out "hmaara". The same word alone was perfect.
    So the bug is position, not spelling - and giving the word its own segment
    puts it back at the start of an utterance, where the voice says it right.

    Tried and rejected first: a ZWNJ hint (no effect), a slower rate (no
    effect), and swapping the word for a synonym (changes the meaning to fix a
    sound). Respelling with an explicit short-a helped, but respelling every
    affected word is a list nobody will maintain; splitting is structural and
    needs no list.

    The cost is roughly twice the API calls for the same characters - the bill
    is by character, so this is free.
    """
    out = []
    paras = [p.strip() for p in text.split('\n\n') if p.strip()]
    for pi, para in enumerate(paras):
        parts = _split_sentences(para)
        for si, sent in enumerate(parts):
            last_in_para = si == len(parts) - 1
            last_overall = last_in_para and pi == len(paras) - 1
            gap = 0 if last_overall else (
                GAP_PARAGRAPH if last_in_para else GAP_SENTENCE)
            out.append((sent, gap))
    return out


def _cached(text, voice, rate):
    key = hashlib.sha256(
        (voice + '|' + str(rate) + '|' + text).encode('utf-8')).hexdigest()[:20]
    return os.path.exists(os.path.join(CACHE, key + '.mp3'))


def synth(text, voice, rate, tok, attempts=6):
    """One segment -> mp3 on disk, cached by content hash. Retries on 429/5xx.

    A bulk run WILL be rate limited - Chirp 3 HD has a modest per-minute quota
    and eight workers tripped it within a minute. Backoff is not defensive
    programming here, it is the normal path: the job is thousands of calls and
    the server is entitled to say "slow down".

    Exponential with jitter, because synchronised retries from every worker
    would recreate the same spike that caused the 429. A 401 refreshes the
    token instead - a run outlives an access token.
    """
    import random
    import time

    key = hashlib.sha256(
        (voice + '|' + str(rate) + '|' + text).encode('utf-8')).hexdigest()[:20]
    os.makedirs(CACHE, exist_ok=True)
    path = os.path.join(CACHE, key + '.mp3')
    if os.path.exists(path):
        return path

    body = json.dumps({
        'audioConfig': {'audioEncoding': 'MP3', 'speakingRate': rate},
        'input': {'text': text},
        'voice': {'languageCode': voice[:5], 'name': voice},
    }).encode('utf-8')

    delay = 2.0
    for attempt in range(attempts):
        req = urllib.request.Request(API, data=body, method='POST')
        req.add_header('Authorization', 'Bearer ' + tok)
        req.add_header('Content-Type', 'application/json; charset=utf-8')
        req.add_header('x-goog-user-project', PROJECT)
        try:
            with urllib.request.urlopen(req, timeout=90) as r:
                data = json.loads(r.read().decode('utf-8'))
            # Write via a temp name: a half-written mp3 left by an interrupted
            # run would be treated as cached and silently played as garbage.
            tmp = path + '.part'
            with open(tmp, 'wb') as f:
                f.write(base64.b64decode(data['audioContent']))
            os.replace(tmp, path)
            return path
        except urllib.error.HTTPError as e:
            if e.code == 401:
                tok = token(force=True)
                continue
            if e.code not in (408, 429, 500, 502, 503, 504):
                raise
        except Exception:
            if attempt == attempts - 1:
                raise
        time.sleep(delay + random.uniform(0, delay))
        delay = min(delay * 2, 60)
    raise RuntimeError('gave up after %d attempts: %s' % (attempts, text[:60]))


def stitch(pieces, out_path):
    """Concatenate [(mp3_path, gap_ms)] into one file, gaps as real silence."""
    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    inputs, filters, labels = [], [], []
    idx = 0
    for path, gap in pieces:
        inputs += ['-i', path]
        labels.append('[%d:a]' % idx)
        idx += 1
        if gap:
            # anullsrc generates silence; -t bounds it to the gap length.
            inputs += ['-f', 'lavfi', '-t', '%.3f' % (gap / 1000.0),
                       '-i', 'anullsrc=r=24000:cl=mono']
            labels.append('[%d:a]' % idx)
            idx += 1
    filters.append(''.join(labels) + 'concat=n=%d:v=0:a=1[out]' % idx)
    cmd = (['ffmpeg', '-y', '-loglevel', 'error'] + inputs
           + ['-filter_complex', ';'.join(filters), '-map', '[out]',
              '-codec:a', 'libmp3lame', '-b:a', '64k', '-ac', '1', out_path])
    r = subprocess.run(cmd, capture_output=True, text=True)
    if r.returncode:
        sys.exit('ffmpeg failed:\n' + r.stderr[-800:])
    return out_path


def build(text, out_path, voice=VOICE_HI, rate=1.0, gaps=True):
    tok = token()
    segs = segments(clean(text))
    pieces = [(synth(s, voice, rate, tok), g if gaps else 0) for s, g in segs]
    stitch(pieces, out_path)
    chars = sum(len(s) for s, _ in segs)
    print('%-34s %2d segments, %5d chars' %
          (os.path.basename(out_path), len(segs), chars))
    return chars


def run(scope, rate, include_reference=False):
    """Generate every passage in [scope] and write a manifest beside them.

    The manifest is what the app reads: key -> file + a hash of the text it was
    made from. The hash is the staleness guard - edit a paragraph later and it
    stops matching, so the passage regenerates instead of silently playing the
    old words. That failure is the one this whole design is most prone to,
    because nothing about stale audio looks wrong from the code side.
    """
    sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
    from audio_corpus import corpus

    from audio_corpus import spoken

    items = corpus(scope, include_reference=include_reference)
    tok = token()
    manifest, chars, made = {}, 0, 0
    from concurrent.futures import ThreadPoolExecutor

    # Pre-warm the segment cache in parallel. Synthesis is network-bound and
    # billed per character, so concurrency costs nothing and turns half an
    # hour of waiting into a few minutes. Stitching stays serial - it is local
    # ffmpeg work and ordering matters.
    wanted = []
    for key, text in items:
        wanted += [s for s, _ in segments(clean(spoken(key, text)))]
    todo = [s for s in dict.fromkeys(wanted) if not _cached(s, VOICE_HI, rate)]
    print('%d unique segments, %d need synthesis' % (len(set(wanted)), len(todo)))
    if todo:
        with ThreadPoolExecutor(max_workers=3) as pool:
            for n, _ in enumerate(pool.map(
                    lambda t: synth(t, VOICE_HI, rate, token()), todo), 1):
                if n % 100 == 0:
                    print('   synthesised %d/%d' % (n, len(todo)))

    for i, (key, text) in enumerate(items, 1):
        out_path = os.path.join(OUT, 'hi', key + '.mp3')
        segs = segments(clean(spoken(key, text)))
        pieces = [(synth(s, VOICE_HI, rate, tok), g) for s, g in segs]
        stitch(pieces, out_path)
        made += 1
        chars += sum(len(s) for s, _ in segs)
        manifest[key] = {
            'file': 'hi/' + key + '.mp3',
            'hash': hashlib.sha256(text.encode('utf-8')).hexdigest()[:16],
            'chars': len(text),
        }
        if i % 25 == 0 or i == len(items):
            print('  %d/%d' % (i, len(items)))

    mpath = os.path.join(OUT, 'manifest_hi.json')
    with open(mpath, 'w', encoding='utf-8') as f:
        json.dump(manifest, f, ensure_ascii=False, indent=1, sort_keys=True)
    print()
    print('%d files, %d characters synthesised' % (made, chars))
    print('manifest: ' + mpath)
    return chars


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--demo', action='store_true',
                    help='two files from one real passage, with and without '
                         'the stitched pauses, to compare')
    ap.add_argument('--scope', choices=['pilot', 'full'],
                    help='pilot = ~20 passages to listen to; full = everything')
    ap.add_argument('--include-reference', action='store_true',
                    help='also narrate can_i / tests_scans / read_next')
    ap.add_argument('--rate', type=float, default=1.0)
    args = ap.parse_args()

    if args.scope:
        run(args.scope, args.rate, args.include_reference)
        return

    if args.demo:
        raw = json.load(open('build/audio/_passage.json', encoding='utf-8'))
        text = raw['text']
        total = 0
        total += build(text, OUT + '/demo_with_pauses.mp3', rate=args.rate)
        total += build(text, OUT + '/demo_no_pauses.mp3', rate=args.rate,
                       gaps=False)
        print('\ncharacters billed this run: %d '
              '(segments are cached, so the second file cost nothing)' % total)
        return
    ap.print_help()


if __name__ == '__main__':
    main()
