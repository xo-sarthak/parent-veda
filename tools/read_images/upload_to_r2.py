"""
Upload the mirrored photos to the R2 bucket.

    python tools/read_images/upload_to_r2.py

Reads the credentials from ~/Downloads/r2.env (four lines: R2_KEY,
R2_SECRET, R2_ENDPOINT, R2_BUCKET) — a file outside the repo, never a
value in this script or in the shell history. The token behind it is
scoped to Object Read & Write on the one bucket (see STILL-OPEN §70.3).

Walks ~/Downloads/parentveda-images/, uploads every *.jpg with
Content-Type image/jpeg and a year-long cache header, and skips a key
that is already in the bucket with the same size — so a re-run after a
re-pick uploads only what changed. Deletes nothing.

After it: Settings → Public access → allow the r2.dev subdomain (or
connect a custom domain), then set `kReadImageBase` in
lib/data/reads/read_images.dart to that URL with a trailing slash.
"""
import os, sys

try:
    import boto3
    from botocore.config import Config
except ImportError:
    print('pip install boto3'); sys.exit(1)

ENV = os.path.join(os.path.expanduser('~'), 'Downloads', 'r2.env')
SRC = os.path.join(os.path.expanduser('~'), 'Downloads', 'parentveda-images')

def load_env():
    if not os.path.exists(ENV):
        print(f'no {ENV} — see the header'); sys.exit(1)
    out = {}
    for line in open(ENV, encoding='utf-8'):
        line = line.strip()
        if not line or line.startswith('#') or '=' not in line: continue
        k, v = line.split('=', 1)
        out[k.strip()] = v.strip().strip('"').strip("'")
    for k in ('R2_KEY', 'R2_SECRET', 'R2_ENDPOINT', 'R2_BUCKET'):
        if not out.get(k):
            print(f'{ENV} is missing {k}'); sys.exit(1)
    return out

def main():
    env = load_env()
    s3 = boto3.client(
        's3',
        endpoint_url=env['R2_ENDPOINT'],
        aws_access_key_id=env['R2_KEY'],
        aws_secret_access_key=env['R2_SECRET'],
        region_name='auto',
        config=Config(signature_version='s3v4'),
    )
    bucket = env['R2_BUCKET']
    # what is already there, by size
    have = {}
    token = None
    while True:
        kw = {'Bucket': bucket}
        if token: kw['ContinuationToken'] = token
        r = s3.list_objects_v2(**kw)
        for o in r.get('Contents', []):
            have[o['Key']] = o['Size']
        if not r.get('IsTruncated'): break
        token = r.get('NextContinuationToken')
    files = sorted(f for f in os.listdir(SRC) if f.lower().endswith('.jpg'))
    up = skip = fail = 0
    for i, f in enumerate(files):
        path = os.path.join(SRC, f)
        size = os.path.getsize(path)
        if have.get(f) == size:
            skip += 1
            continue
        try:
            with open(path, 'rb') as fh:
                s3.put_object(Bucket=bucket, Key=f, Body=fh, ContentType='image/jpeg',
                              CacheControl='public, max-age=31536000, immutable')
            up += 1
            print(f'{i+1}/{len(files)} {f}', flush=True)
        except Exception as e:
            fail += 1
            print(f'{i+1}/{len(files)} FAIL {f} {e}', flush=True)
    print(f'done: {up} uploaded, {skip} already there, {fail} failed, {len(have)} were in the bucket before')

if __name__ == '__main__':
    main()
