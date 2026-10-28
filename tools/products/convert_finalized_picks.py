"""The SEO plan's "Finalized picks" tab -> a store sheet the importer reads.

Store Track A (2026-10-28). The team's workbook
(ParentVeda_SEO_Plan_Door_Order_*.xlsx) lists ~515 picks with a tagged
Amazon link each. Most of them come from the same Drive lists the app
already shows as ParentVeda's shortlist, so this converter:

  1. MATCHES each pick to the product the app already has, by brand + name
     (tools/products/store_catalogue_index.json, written by
     test/store_sheet_feed_test.dart). The row reuses that product's id, so
     the link lands ON it and it keeps its category, tier and notes.
  2. ADDS children's books (section D) as new products under Play &
     Development, aged from their heading ("Books: 1-3y" -> 12 to 36 months).
     The app holds them only in the read-to-baby feature, not the store.
  3. SKIPS what is held: the fetal-doppler and herbal-tea picks conflict with
     the app's clinical stance and stay out until signed off (2026-10-13).
  4. REPORTS anything else it cannot place, never guessing a shelf for it.

Then run the importer on what it writes:

    python -I tools/products/convert_finalized_picks.py "<workbook>.xlsx"
       -> tools/products/out/store_sheet_from_picks.xlsx  (open it, check it)
    python -I tools/products/import_store_sheet.py tools/products/out/store_sheet_from_picks.xlsx
       -> tools/products/out/store_products.sql           (paste into Supabase)

THE LINKS ARE AMAZON SEARCH PAGES, not exact listings: they earn (the tag
is on them) but cannot sync a price or photo. When someone opens each pick
and copies its ASIN into the store sheet's asin column, the same rows
update and, with the Creators API keys, the sync starts.

Needs openpyxl.
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

import openpyxl

HERE = Path(__file__).resolve().parent
INDEX = HERE / "store_catalogue_index.json"
OUT = HERE / "out" / "store_sheet_from_picks.xlsx"
sys.path.insert(0, str(HERE))
from import_store_sheet import HEADERS  # noqa: E402  (same columns, one source)

HELD = {"Portable Fetal Dopplers", "Herbal Anti-Nausea Teas"}
# Placeholder picks with no real product yet (user, 2026-10-28: "ignore them
# for the time"). Not reported as unplaced; name a real product to bring one in.
IGNORED_PREFIXES = ("ParentVeda Curated ", "Generic ")
BOOKS_CATEGORY = "play_and_development"


def norm(s: str) -> str:
    return re.sub(r"[^a-z0-9]", "", (s or "").lower())


def slug(s: str) -> str:
    return re.sub(r"_+", "_", re.sub(r"[^a-z0-9]", "_", s.lower())).strip("_")


def link_of(cell) -> str:
    if cell.hyperlink and cell.hyperlink.target:
        return cell.hyperlink.target
    v = str(cell.value or "")
    m = re.search(r'"(https://[^"]+)"', v)
    return m.group(1) if m else (v if v.startswith("https://") else "")


def book_ages(heading: str):
    m = re.search(r"(\d)\s*-\s*(\d)\s*y", heading)
    return (int(m.group(1)) * 12, int(m.group(2)) * 12) if m else (0, 60)


def main() -> None:
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    idx = json.loads(INDEX.read_text(encoding="utf-8"))
    by_full = {norm(p["brand"] + p["name"]): p for p in idx}
    by_name = {norm(p["name"]): p for p in idx}

    ws = openpyxl.load_workbook(sys.argv[1])["Finalized picks"]
    section = heading = None
    rows, unplaced, held, ignored, seen = [], [], 0, 0, set()
    for r in ws.iter_rows(min_row=4):
        a = r[0].value
        if a and str(a).startswith("SECTION"):
            section = str(a)[8]
            continue
        if a and a != "Plan category / topic":
            heading = str(a)
        pick = r[2].value
        if not pick or pick == "Pick (brand + product)":
            continue
        pick = str(pick).strip()
        tier = str(r[3].value or "").strip()
        link = link_of(r[5]) if len(r) > 5 else ""
        if heading in HELD:
            held += 1
            continue
        if pick.startswith(IGNORED_PREFIXES):
            ignored += 1
            continue

        p = by_full.get(norm(pick)) or by_name.get(norm(pick))
        row = dict.fromkeys(HEADERS, "")
        if p:
            row.update(
                product_key=p["id"], stage=p["stage"], category=p["category"],
                sub_id=p["sub"], brand=p["brand"], name=p["name"],
            )
        elif section == "D":
            title, _, author = pick.rpartition(" - ")
            lo, hi = book_ages(heading or "")
            row.update(
                product_key=f"pvk_{slug(title or pick)}"[:60], stage="parenting",
                category=BOOKS_CATEGORY, brand=author or "", name=title or pick,
                age_min_months=lo, age_max_months=hi,
                best_for=f"Children's book, {heading.split(':', 1)[-1].strip()}",
            )
        else:
            unplaced.append(f"{heading} | {pick}")
            continue
        if row["product_key"] in seen:
            continue  # the same pick listed under two headings
        seen.add(row["product_key"])
        row.update(programme="amazon", link=link, badge=tier if tier in {"Premium"} else "")
        rows.append(row)

    out = openpyxl.Workbook()
    sh = out.active
    sh.title = "Products"
    sh.append(HEADERS)
    for row in rows:
        sh.append([row[h] if row[h] != "" else None for h in HEADERS])
    OUT.parent.mkdir(parents=True, exist_ok=True)
    out.save(OUT)

    print(f"{len(rows)} products -> {OUT}")
    print(f"{held} held picks skipped (fetal dopplers, nausea teas)")
    print(f"{ignored} placeholder picks ignored (ParentVeda Curated / Generic)")
    if unplaced:
        print(f"{len(unplaced)} picks not placed (no matching product, no rule):")
        for u in unplaced:
            print("  -", u)


if __name__ == "__main__":
    main()
