"""
Fetch every photo the app references into one folder for Cloudflare R2.

    python tools/read_images/fetch_read_images.py

Reads `kReadImageUrls` and `kReadImageCredits` out of
lib/data/reads/read_images.dart (no Dart needed), downloads each URL slowly
(Wikimedia throttles by IP), resizes to a 1200px long edge JPEG at quality
84, and writes:

    ~/Downloads/parentveda-images/<id>.jpg      one file per id
    ~/Downloads/parentveda-images/manifest.json  id -> {file, source, credit}
    ~/Downloads/parentveda-images/CREDITS.txt    the attribution list

Upload the folder to an R2 bucket as-is (flat, the ids are the names) and
set `kReadImageBase` in read_images.dart to the bucket's public URL. The
source URLs stay in the map as the fallback for an id the bucket lacks.

Re-runnable: an id whose file exists is skipped, so a failed run resumes.

StockSnap: cdn.stocksnap.io sits behind Cloudflare and answers 403 to any
scripted fetch (browser headers, referer, nothing helps), so the table's
StockSnap URLs are fetched through Openverse's image proxy instead —
`openverse_ids.json` beside this script maps id -> Openverse image id, and
`/thumb/?full_size=true` serves the 960w original. The table keeps the
StockSnap URL: it is the provenance the credit points at.
"""
import io, json, os, re, sys, time, urllib.request

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
SRC = os.path.join(REPO, 'lib', 'data', 'reads', 'read_images.dart')
OUT = os.path.join(os.path.expanduser('~'), 'Downloads', 'parentveda-images')
OV_IDS = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'openverse_ids.json')
UA = 'ParentVeda/1.0 (image mirror for R2; ishaansingh2512@gmail.com)'

try:
    from PIL import Image
except ImportError:
    print('pip install pillow'); sys.exit(1)

def parse():
    s = io.open(SRC, encoding='utf-8').read()
    def block(name):
        m = re.search(r'const Map<String, String> %s = \{(.*?)\n\};' % name, s, re.S)
        body = m.group(1)
        out = {}
        for k, v in re.findall(r"'((?:[^'\\]|\\.)*)':\s*'((?:[^'\\]|\\.)*)'", body):
            out[k.replace("\\'", "'")] = v.replace("\\'", "'")
        return out
    return block('kReadImageUrls'), block('kReadImageCredits')

def main():
    urls, credits = parse()
    ov = json.load(open(OV_IDS)) if os.path.exists(OV_IDS) else {}
    os.makedirs(OUT, exist_ok=True)
    manifest_path = os.path.join(OUT, 'manifest.json')
    manifest = json.load(open(manifest_path)) if os.path.exists(manifest_path) else {}
    done = fail = 0
    for i, (k, url) in enumerate(urls.items()):
        fn = os.path.join(OUT, k + '.jpg')
        # an id already fetched from THIS url is done; a re-picked id (the
        # manifest remembers a different source) is fetched again
        if os.path.exists(fn) and manifest.get(k, {}).get('source') == url:
            manifest[k] = {'file': k + '.jpg', 'source': url, 'credit': credits.get(k, '')}
            continue
        fetch = url
        # StockSnap 403s scripts and Flickr's CDN resets them; both are
        # indexed by Openverse, whose proxy answers (see the header).
        if 'stocksnap.io' in url or 'staticflickr.com' in url:
            if k not in ov:
                fail += 1
                print(f'{i+1}/{len(urls)} FAIL {k} hotlink-hostile url with no openverse id in {OV_IDS}', flush=True)
                continue
            fetch = f'https://api.openverse.org/v1/images/{ov[k]}/thumb/?full_size=true'
        try:
            req = urllib.request.Request(fetch, headers={'User-Agent': UA})
            data = urllib.request.urlopen(req, timeout=40).read()
            im = Image.open(io.BytesIO(data)).convert('RGB')
            im.thumbnail((1200, 1200))
            im.save(fn, 'JPEG', quality=84, optimize=True)
            manifest[k] = {'file': k + '.jpg', 'source': url, 'credit': credits.get(k, '')}
            done += 1
            print(f'{i+1}/{len(urls)} {k}', flush=True)
        except Exception as e:
            fail += 1
            print(f'{i+1}/{len(urls)} FAIL {k} {e}', flush=True)
            if '429' in str(e):
                time.sleep(45)
        # polite: Wikimedia answers 429 above roughly one request a second
        time.sleep(1.8 if 'wikimedia' in url else 0.4)
        json.dump(manifest, open(manifest_path, 'w'), indent=1)
    json.dump(manifest, open(manifest_path, 'w'), indent=1)
    with io.open(os.path.join(OUT, 'CREDITS.txt'), 'w', encoding='utf-8') as f:
        f.write('ParentVeda read images — sources and licences\n\n')
        for k, m in sorted(manifest.items()):
            f.write(f"{m['file']}\n  {m['credit']}\n  {m['source']}\n\n")
    print(f'done: {done} fetched, {fail} failed, {len(manifest)} in manifest -> {OUT}')

if __name__ == '__main__':
    main()
