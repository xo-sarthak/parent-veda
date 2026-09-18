"""Download the embedding model into tools/question_miner/.models/.

huggingface.co is connection-reset from this network (2026-09-18), so
fastembed's own downloader cannot run. This pulls the same ONNX files from the
hf-mirror.com mirror, pinned to one commit, with retries — the mirror resets
too, just less often. Run once; the folder is gitignored.
"""

from __future__ import annotations

import subprocess
import sys
import time
from pathlib import Path

REPO_ID = "Qdrant/bge-small-en-v1.5-onnx-Q"
REVISION = "52398278842ec682c6f32300af41344b1c0b0bb2"
FILES = ["config.json", "model_optimized.onnx", "ort_config.json", "special_tokens_map.json",
         "tokenizer.json", "tokenizer_config.json", "vocab.txt"]
MIRRORS = ["https://hf-mirror.com", "https://huggingface.co"]
DEST = Path(__file__).resolve().parent / ".models" / "bge-small-en-v1.5"


def fetch(name: str) -> bool:
    target = DEST / name
    if target.exists() and target.stat().st_size > 0:
        print(f"  {name}: present")
        return True
    for attempt in range(8):
        base = MIRRORS[attempt % len(MIRRORS)] if attempt >= 6 else MIRRORS[0]
        url = f"{base}/{REPO_ID}/resolve/{REVISION}/{name}"
        r = subprocess.run(["curl", "-sS", "-L", "--max-time", "900", "-o", str(target), url],
                           capture_output=True, text=True)
        if r.returncode == 0 and target.exists() and target.stat().st_size > 0:
            print(f"  {name}: {target.stat().st_size:,} bytes")
            return True
        print(f"  {name}: attempt {attempt + 1} failed ({r.stderr.strip()[:80]})")
        time.sleep(3)
    return False


def main() -> int:
    DEST.mkdir(parents=True, exist_ok=True)
    print(f"model -> {DEST}")
    ok = all(fetch(f) for f in FILES)
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
