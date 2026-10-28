"""The store's product sheet (.xlsx) -> SQL that loads it into `products`.

Store Track A, slice 2 (2026-10-28). PLUG AND PLAY: the app reads these rows
(domain = 'store', migration 0120) on start, so a product added or a link
changed in the sheet reaches every phone without an app release.

Usage (from the repo root):

    # 1. The blank template, every column the store reads, with notes:
    python -I tools/products/import_store_sheet.py --template "store_sheet.xlsx"

    # 2. Fill it in, then turn it into SQL:
    python -I tools/products/import_store_sheet.py "store_sheet.xlsx"
       -> tools/products/out/store_products.sql
       Paste that into the Supabase SQL editor and run it.

PLACEHOLDERS. A blank cell, or one starting with '#', means "not given yet".
Fill in whatever you know today; the rest stays empty and the app shows the
honest fallback (no link = no buy button; no photo = the cover block; no
price = "See price on ..."). Re-running with more filled in just updates the
same rows (keyed on product_key). Rows whose product_key is a placeholder
are skipped as unfinished.

STRICT. Any row with an error (unknown stage or category, a link that is not
https, a bad ASIN, a price that is not a number) is reported and NOTHING is
written: half a catalogue is worse than yesterday's.

AMAZON AND FLIPKART RULE. Their price, stars, photo and "About this item"
may only come from their own API (the affiliate-refresh function). So for
programme = amazon or flipkart this importer never writes a price, MRP or
checked date, and says so if the sheet has one.

Needs openpyxl (pip install openpyxl).
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from datetime import date, datetime
from pathlib import Path

try:
    import openpyxl
    from openpyxl.styles import Font
except ImportError:  # pragma: no cover
    sys.exit("openpyxl is needed: pip install openpyxl")

HERE = Path(__file__).resolve().parent
CATEGORIES = HERE / "store_categories.json"  # kept in sync by store_sheet_feed_test
OUT = HERE / "out" / "store_products.sql"

STAGE_WORDS = {
    "ttc": "ttc",
    "trying": "ttc",
    "trying_to_conceive": "ttc",
    "pregnancy": "pregnancy",
    "pregnant": "pregnancy",
    "parenting": "parenting",
    "baby": "parenting",
}
PROGRAMMES = {"amazon", "flipkart", "inrdeals", "cuelinks", "direct"}
API_PRICED = {"amazon", "flipkart"}

# (header, required, what it is, example) -- the template's own documentation.
COLUMNS = [
    ("product_key", True, "Unique id, never changes. Lower case, underscores. Reuse an existing app id to replace that product.", "pva_lansinoh_nipple_cream"),
    ("status", False, "published (shown) or draft (hidden). Blank = published.", "published"),
    ("stage", True, "ttc, pregnancy or parenting. Several: comma separated, first leads.", "pregnancy"),
    ("category", True, "A store category id from the Lists tab.", "#"),
    ("sub_id", False, "Sub-category id, if the category has them.", "#"),
    ("brand", False, "Brand name.", "Lansinoh"),
    ("name", True, "Product name as parents should see it.", "HPA Lanolin Nipple Cream"),
    ("why_we_picked", False, "One or two lines: why ParentVeda picked it. No medical claims.", "#"),
    ("programme", False, "amazon, flipkart, inrdeals, cuelinks or direct.", "amazon"),
    ("retailer", False, "Shop name shown on the button. Blank = from programme.", "#"),
    ("link", False, "The affiliate or product link (https). A category page is fine for now.", "#"),
    ("asin", False, "Amazon only: the 10-character ASIN. Turns on price/stars/photo sync once API keys exist.", "#"),
    ("guide_price", False, "Brand networks only: the price you checked, whole rupees. Ignored for Amazon/Flipkart.", "#"),
    ("price_checked_on", False, "Date you checked guide_price (YYYY-MM-DD).", "#"),
    ("mrp", False, "Brand networks only: MRP, whole rupees.", "#"),
    ("image_urls", False, "Our own or licensed photos only, https, separated by |. Never copied from Amazon.", "#"),
    ("best_for", False, "One line: who it suits.", "#"),
    ("pros", False, "What is good, separated by |.", "#"),
    ("cons", False, "Watch-outs, separated by |. Both halves, always.", "#"),
    ("week_from", False, "Pregnancy week it becomes relevant.", "#"),
    ("week_to", False, "Pregnancy week it stops being relevant.", "#"),
    ("age_min_months", False, "Child age from, in months.", "#"),
    ("age_max_months", False, "Child age to, in months.", "#"),
    ("where_it_shows", False, "Placement keys for moment-of-need cards, separated by |.", "#"),
    ("badge", False, "Best overall / Best value / Premium.", "#"),
]
HEADERS = [c[0] for c in COLUMNS]


def blank(v) -> bool:
    return v is None or (isinstance(v, str) and (not v.strip() or v.strip().startswith("#")))


def text(v) -> str:
    return "" if blank(v) else str(v).strip()


def parts(v) -> list[str]:
    return [p.strip() for p in text(v).split("|") if p.strip()]


def whole(v, col, errs, where):
    if blank(v):
        return None
    try:
        f = float(str(v).replace(",", "").replace("₹", "").strip())
        if f < 0 or f != int(f):
            raise ValueError
        return int(f)
    except ValueError:
        errs.append(f"{where}: {col} '{v}' is not a whole number")
        return None


def sql(v) -> str:
    if v is None:
        return "null"
    if isinstance(v, bool):
        return "true" if v else "false"
    if isinstance(v, int):
        return str(v)
    if isinstance(v, list):
        return "array[" + ",".join(sql(x) for x in v) + "]::text[]" if v else "'{}'::text[]"
    if isinstance(v, dict) or (isinstance(v, tuple) and v and v[0] == "json"):
        payload = v[1] if isinstance(v, tuple) else v
        return "'" + json.dumps(payload, ensure_ascii=False).replace("'", "''") + "'::jsonb"
    return "'" + str(v).replace("'", "''") + "'"


def write_template(path: Path) -> None:
    cats = json.loads(CATEGORIES.read_text(encoding="utf-8"))
    wb = openpyxl.Workbook()
    ws = wb.active
    ws.title = "Products"
    ws.append(HEADERS)
    ws.append([c[3] for c in COLUMNS])
    for i, (_, req, _, _) in enumerate(COLUMNS, start=1):
        cell = ws.cell(row=1, column=i)
        cell.font = Font(bold=True, color="B00020" if req else "000000")
        ws.column_dimensions[cell.column_letter].width = 22
    ws.freeze_panes = "A2"

    doc = wb.create_sheet("Read me")
    doc.append(["column", "required", "what it is"])
    for h, req, what, _ in COLUMNS:
        doc.append([h, "yes" if req else "", what])
    doc.append([])
    doc.append(["Placeholders", "", "A blank cell or one starting with # means 'not given yet'. Fill what you know; re-run later."])
    doc.append(["Amazon / Flipkart", "", "Price, stars, photo and 'About this item' come only from their API. Do not type them in."])
    doc.column_dimensions["A"].width = 20
    doc.column_dimensions["C"].width = 110

    lists = wb.create_sheet("Lists")
    lists.append(["category id", "stage", "category name", "", "stage words", "", "programme"])
    stages = sorted(set(STAGE_WORDS.values()))
    progs = sorted(PROGRAMMES)
    for i, c in enumerate(cats):
        row = [c["id"], c["stage"], c["name"], ""]
        row += [stages[i] if i < len(stages) else "", ""]
        row += [progs[i] if i < len(progs) else ""]
        lists.append(row)
    for col in "ABC":
        lists.column_dimensions[col].width = 28
    path.parent.mkdir(parents=True, exist_ok=True)
    wb.save(path)
    print(f"template written: {path}")


def read_rows(path: Path):
    cats = {c["id"] for c in json.loads(CATEGORIES.read_text(encoding="utf-8"))}
    wb = openpyxl.load_workbook(path, data_only=True)
    if "Products" not in wb.sheetnames:
        sys.exit("the workbook has no 'Products' tab (make one with --template)")
    ws = wb["Products"]
    it = ws.iter_rows(values_only=True)
    header = [text(h).lower() for h in next(it)]
    missing = [h for h, req, _, _ in COLUMNS if req and h not in header]
    if missing:
        sys.exit(f"missing required columns: {', '.join(missing)}")
    col = {h: header.index(h) for h in HEADERS if h in header}

    errs: list[str] = []
    notes: list[str] = []
    rows: list[dict] = []
    seen: set[str] = set()
    for n, raw in enumerate(it, start=2):
        get = lambda h: raw[col[h]] if h in col and col[h] < len(raw) else None  # noqa: E731
        key = text(get("product_key"))
        if not key:
            continue  # unfinished or blank row
        where = f"row {n} ({key})"
        if not re.fullmatch(r"[a-z0-9_]+", key):
            errs.append(f"{where}: product_key may use only a-z, 0-9 and _")
        if key in seen:
            errs.append(f"{where}: product_key used twice")
        seen.add(key)

        name = text(get("name"))
        if not name:
            errs.append(f"{where}: name is required")
        stages = []
        for w in re.split(r"[,\s]+", text(get("stage")).lower()):
            if w:
                if w in STAGE_WORDS:
                    stages.append(STAGE_WORDS[w])
                else:
                    errs.append(f"{where}: stage '{w}' is not ttc, pregnancy or parenting")
        if not stages:
            errs.append(f"{where}: stage is required")
        category = text(get("category"))
        if not category:
            errs.append(f"{where}: category is required (see the Lists tab)")
        elif category not in cats:
            errs.append(f"{where}: category '{category}' is not a store category (see the Lists tab)")

        status = text(get("status")).lower() or "published"
        if status not in {"published", "draft"}:
            errs.append(f"{where}: status must be published or draft")
        programme = text(get("programme")).lower()
        if programme and programme not in PROGRAMMES:
            errs.append(f"{where}: programme '{programme}' is not one of {', '.join(sorted(PROGRAMMES))}")
        link = text(get("link"))
        if link and not link.startswith("https://"):
            errs.append(f"{where}: link must start with https://")
        asin = text(get("asin")).upper()
        if asin and not re.fullmatch(r"[A-Z0-9]{10}", asin):
            errs.append(f"{where}: asin '{asin}' is not 10 letters/digits")
        images = parts(get("image_urls"))
        for u in images:
            if not u.startswith("https://"):
                errs.append(f"{where}: image '{u}' must start with https://")

        price = whole(get("guide_price"), "guide_price", errs, where)
        mrp = whole(get("mrp"), "mrp", errs, where)
        checked = get("price_checked_on")
        checked_at = None
        if not blank(checked):
            if isinstance(checked, (datetime, date)):
                checked_at = checked.strftime("%Y-%m-%d")
            elif re.fullmatch(r"\d{4}-\d{2}-\d{2}", text(checked)):
                checked_at = text(checked)
            else:
                errs.append(f"{where}: price_checked_on must be YYYY-MM-DD")
        api_priced = programme in API_PRICED or "amazon" in link or "flipkart" in link
        if api_priced and (price is not None or mrp is not None or checked_at):
            notes.append(f"{where}: price/MRP ignored - {programme or 'this shop'} prices come only from its API")
            price = mrp = checked_at = None

        nums = {
            h: whole(get(h), h, errs, where)
            for h in ("week_from", "week_to", "age_min_months", "age_max_months")
        }
        rows.append({
            "source_key": key,
            "domain": "store",
            "status": status,
            "name": name,
            "brand": text(get("brand")),
            "category": category,
            "sub_id": text(get("sub_id")),
            "stage": stages,
            "summary": text(get("why_we_picked")),
            "programme": programme,
            "retailer": text(get("retailer")),
            "buy_url": link or None,
            "asin": asin or None,
            "images": images,
            "best_for": text(get("best_for")),
            "pros": ("json", parts(get("pros"))),
            "cons": ("json", parts(get("cons"))),
            "week_from": nums["week_from"],
            "week_to": nums["week_to"],
            "age_min_months": nums["age_min_months"] if nums["age_min_months"] is not None else 0,
            "age_max_months": nums["age_max_months"] if nums["age_max_months"] is not None else 72,
            "placements": parts(get("where_it_shows")),
            "badge": text(get("badge")),
            # Brand networks only; for Amazon/Flipkart these keys are left
            # out of the statement so the API's values are never touched.
            **({} if api_priced else {
                "price_inr": price or 0,
                "mrp_inr": mrp,
                "price_checked_at": checked_at,
            }),
        })
    return rows, errs, notes


def write_sql(rows: list[dict], out: Path) -> None:
    lines = [
        "-- GENERATED by tools/products/import_store_sheet.py - do not edit by hand.",
        f"-- {len(rows)} products, {datetime.now():%Y-%m-%d %H:%M}. Run in the Supabase SQL editor.",
        "begin;",
    ]
    for r in rows:
        cols = list(r.keys())
        upd = [c for c in cols if c != "source_key"]
        lines.append(
            f"insert into public.products ({', '.join(cols)})\n"
            f"  values ({', '.join(sql(r[c]) for c in cols)})\n"
            f"  on conflict (source_key) do update set "
            + ", ".join(f"{c} = excluded.{c}" for c in upd)
            + ", updated_at = now();"
        )
    keys = ", ".join(sql(r["source_key"]) for r in rows) or "''"
    lines.append(
        "-- A product taken out of the sheet is archived (hidden), never deleted.\n"
        "update public.products set status = 'archived', updated_at = now()\n"
        f"  where domain = 'store' and status <> 'archived' and source_key not in ({keys});"
    )
    lines.append("commit;")
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("sheet", nargs="?", help="the filled-in store sheet (.xlsx)")
    ap.add_argument("--template", help="write a blank template to this path and stop")
    ap.add_argument("--out", default=str(OUT), help="where to write the SQL")
    a = ap.parse_args()
    if a.template:
        write_template(Path(a.template))
        return
    if not a.sheet:
        ap.error("give the sheet, or --template PATH")
    rows, errs, notes = read_rows(Path(a.sheet))
    for n in notes:
        print("note:", n)
    if errs:
        print(f"\n{len(errs)} problem(s); nothing written:")
        for e in errs:
            print("  -", e)
        sys.exit(1)
    write_sql(rows, Path(a.out))
    print(f"{len(rows)} products -> {a.out}")


if __name__ == "__main__":
    main()
