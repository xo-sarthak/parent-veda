"""Products sheets (.xlsx) -> lib/data/products/sheet/*.dart and lib/data/kids_books/*.dart.

Usage (from the repo root):
    python -I tools/products/xlsx_to_dart.py "<Products folder>"

The Drive folder "Products" (2026-10-13) holds five workbooks:

  * Pregnancy and Parenting Product Catalogue - pregnancy, hospital-bag and
    nursery picks: bucket -> core category -> sub-category, one "decision
    factors" line per sub-category, Budget / Premium picks, a buy-by week.
  * Products Master - toys and crafts by PV_ID, with ParentVeda_Score and its
    four sub-scores.
  * 0-5 Product Master - toys by age group, with intents, parent buckets and a
    confidence of 1 to 5.
  * New Product Categories - every row is also in the 0-5 master; skipped and
    reported as a duplicate.
  * Book Recommendations Master - children's books by age and parent goal.

None has a price, link or photo: the store shows them as ParentVeda's
shortlist (the user, 2026-10-13). Nothing is invented to fill the gaps.

HELD: the "Portable Fetal Dopplers" and "Herbal Anti-Nausea Teas"
sub-categories conflict with the app's clinical stance and are written out
with held=true, shown nowhere until signed off (the user, 2026-10-13).

Strict: an unknown sheet, a missing column, a duplicate id, or an age the
parser cannot read stops the run. Book rows whose columns shifted one place
left (the Publisher cell missing) are repaired and reported, never guessed.
Standard library only.
"""

import html
import os
import re
import sys
import zipfile

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
OUT_PRODUCTS = os.path.join(ROOT, 'lib', 'data', 'products', 'sheet')
OUT_BOOKS = os.path.join(ROOT, 'lib', 'data', 'kids_books')

HELD_SUBS = {'Portable Fetal Dopplers', 'Herbal Anti-Nausea Teas'}
BUCKETS = {'BUCKET_01_PREGNANCY': 'pregnancy', 'BUCKET_02_HOSPITAL': 'hospital', 'BUCKET_03_NURSERY': 'nursery'}
# The one sheet category whose name is not a name a parent can read.
TOY_CATEGORY_NAMES = {'Unclassified': 'More to explore'}


class SheetError(Exception):
    pass


# ---- reading ------------------------------------------------------------------------------

def read_xlsx(path):
    """{sheet name: [ {header: value} ]} with the first non-empty row as the header."""
    z = zipfile.ZipFile(path)
    shared = []
    if 'xl/sharedStrings.xml' in z.namelist():
        x = z.read('xl/sharedStrings.xml').decode('utf8')
        for si in re.findall(r'<si>(.*?)</si>', x, re.S):
            shared.append(html.unescape(''.join(re.findall(r'<t[^>]*>([^<]*)</t>', si))))
    wb = z.read('xl/workbook.xml').decode('utf8')
    rels = z.read('xl/_rels/workbook.xml.rels').decode('utf8')
    target = {}
    for rel in re.findall(r'<Relationship [^>]*>', rels):
        rid = re.search(r'Id="([^"]+)"', rel).group(1)
        tgt = re.search(r'Target="([^"]+)"', rel).group(1).lstrip('/')
        target[rid] = tgt if tgt.startswith('xl/') else 'xl/' + tgt
    out = {}
    for name, rid in re.findall(r'<sheet [^>]*name="([^"]+)"[^>]*r:id="([^"]+)"', wb):
        x = z.read(target[rid]).decode('utf8')
        grid = []
        for r in re.findall(r'<row[^>]*>(.*?)</row>', x, re.S):
            cells = {}
            for col, attrs, inner in re.findall(r'<c r="([A-Z]+)\d+"([^>]*?)(?:/>|>(.*?)</c>)', r, re.S):
                v = re.search(r'<v>([^<]*)</v>', inner or '')
                inline = re.search(r'<is>.*?<t[^>]*>([^<]*)</t>', inner or '', re.S)
                if 't="s"' in attrs and v:
                    val = shared[int(v.group(1))]
                elif inline:
                    val = html.unescape(inline.group(1))
                else:
                    val = v.group(1) if v else ''
                cells[col] = ' '.join(val.split())
            if any(cells.values()):
                grid.append(cells)
        if not grid:
            out[name] = []
            continue
        head = grid[0]
        out[name] = [{head[c]: v for c, v in row.items() if c in head} for row in grid[1:]]
    return out


def need(row, cols, where):
    for c in cols:
        if c not in row:
            raise SheetError(f'{where}: no column "{c}"')


def slug(*parts):
    return re.sub(r'[^a-z0-9]+', '_', ' '.join(parts).lower()).strip('_')[:60]


def months(label, where):
    """'6-9 Months' -> (6, 9); '2-3 Years' -> (24, 36); '3-5y' -> (36, 60)."""
    m = re.match(r'^(\d+)\s*-\s*(\d+)\s*(Months|Years|y)$', label.strip(), re.I)
    if not m:
        raise SheetError(f'{where}: cannot read the age "{label}"')
    a, b, unit = int(m.group(1)), int(m.group(2)), m.group(3).lower()
    return (a, b) if unit == 'months' else (a * 12, b * 12)


# ---- the catalogue -------------------------------------------------------------------------

def catalogue(rows):
    cols = ['Master Bucket ID', 'Core Category', 'Sub-Sub-Category',
            'ParentVeda Decision Factors & Quality Vector', 'Pricing Tier', 'Brand Name',
            'Product Name / Variant', 'Target Purchase Timeline']
    need(rows[0], cols, 'Catalogue')
    picks, ids = [], set()
    for i, r in enumerate(rows, start=2):
        bucket = BUCKETS.get(r['Master Bucket ID'])
        if not bucket:
            raise SheetError(f'Catalogue row {i}: unknown bucket "{r["Master Bucket ID"]}"')
        wk = re.search(r'Week\s+(\d+)', r['Target Purchase Timeline'])
        if not wk:
            raise SheetError(f'Catalogue row {i}: no week in "{r["Target Purchase Timeline"]}"')
        pid = 'pvs_' + slug(r['Brand Name'], r['Product Name / Variant'])
        if pid in ids:
            raise SheetError(f'Catalogue row {i}: "{r["Product Name / Variant"]}" by {r["Brand Name"]} twice')
        ids.add(pid)
        picks.append({
            'id': pid, 'bucket': bucket, 'category': r['Core Category'], 'sub': r['Sub-Sub-Category'],
            'factors': [f.strip(' .') for f in r['ParentVeda Decision Factors & Quality Vector'].split(';') if f.strip(' .')],
            'tier': r['Pricing Tier'].lower(), 'brand': r['Brand Name'], 'name': r['Product Name / Variant'],
            'week': int(wk.group(1)), 'held': r['Sub-Sub-Category'] in HELD_SUBS,
        })
    return picks


# ---- toys -------------------------------------------------------------------------------------

def _brand(b):
    """The 0-5 sheet writes "ParentVeda Curated" and the new-categories sheet
    "Generic" for the same thing: a kind of toy, any good maker."""
    return '' if b in ('ParentVeda Curated', 'Generic') else b


def _age_label(lo, hi):
    return f'{lo}-{hi} Months' if hi <= 24 else f'{lo // 12}-{hi // 12} Years'


def toys(master, zero5, newcats, report):
    need(master[0], ['PV_ID', 'Product', 'Brand', 'Category', 'Top_3_Intents', 'Budget_Tier',
                     'ParentVeda_Score', 'Recommendation_Confidence'], 'Products Master')
    need(zero5[0], ['Product_Name', 'Brand', 'Category', 'Subcategory', 'Age_Group', 'Budget_Tier',
                    'Primary_Intent', 'Secondary_Intent', 'Parent_Bucket_1', 'Parent_Bucket_2',
                    'Parent_Bucket_3', 'Recommendation_Confidence'], '0-5 Product Master')
    out, ids = [], set()

    def skills(*xs):
        seen = []
        for x in xs:
            for s in (x or '').split(','):
                s = s.strip()
                if s and s not in seen:
                    seen.append(s)
        return seen

    from collections import Counter
    reused = {k for k, n in Counter(r['PV_ID'] for r in master).items() if n > 1}
    for r in master:
        # The sheet gives one PV_ID to two families (PV-CRA-001..015: foil art
        # and crayons). Neither is wrong alone, so those rows are keyed by id,
        # product and brand, and reported for the team to renumber.
        tid = 'pvt_' + (slug(r['PV_ID'], r['Product'], r['Brand']) if r['PV_ID'] in reused else slug(r['PV_ID']))
        if tid in ids:
            raise SheetError(f'Products Master: {r["PV_ID"]} {r["Product"]} twice')
        ids.add(tid)
        if r['PV_ID'] in reused:
            report['toys_reused_id'].append(f'{r["PV_ID"]}: {r["Product"]} / {r["Brand"]}')
        if r.get('Data_Quality') == 'Product Family':
            report['toys_family'].append(f'{r["PV_ID"]}: {r["Product"]} / {r["Brand"]}')
        out.append({
            'id': tid, 'name': r['Product'], 'brand': r['Brand'],
            'category': TOY_CATEGORY_NAMES.get(r['Category'], r['Category']), 'sub': '',
            'age': None, 'tier': r['Budget_Tier'].lower(),
            'skills': skills(r['Top_3_Intents'], r.get('Primary_Intent'), r.get('Secondary_Intent')),
            'score': int(r['ParentVeda_Score']), 'confidence': int(r['Recommendation_Confidence']),
            # Only some rows were scored part by part; the rest carry the total.
            'sub_scores': [(label, r[col]) for label, col in (
                ('Developmental value', 'Developmental_Value'), ('Safety', 'Safety'),
                ('Build quality', 'Build_Quality'), ('Longevity', 'Longevity')) if r.get(col)],
            'verified': r.get('Verification_Status') == 'Verified',
        })
    seen_z = {}
    for i, r in enumerate(zero5, start=2):
        key = (r['Product_Name'].lower(), _brand(r['Brand']).lower())
        if key in seen_z:
            # The same toy at a neighbouring age ("2-3 Years" and "3-4 Years"):
            # one entry covering both, never two cards for one toy.
            t = seen_z[key]
            lo, hi = months(r['Age_Group'], f'0-5 row {i}')
            a0, a1, _ = t['age']
            t['age'] = (min(a0, lo), max(a1, hi), _age_label(min(a0, lo), max(a1, hi)))
            report['toys_dup'].append(f'{r["Product_Name"]}: ages joined to {t["age"][2]}')
            continue
        twin = next((t for t in out if t['name'].lower() == key[0] and t['brand'].lower() == key[1]), None)
        lo, hi = months(r['Age_Group'], f'0-5 row {i}')
        if twin:
            # In both: the master keeps its score; the 0-5 sheet adds the age.
            twin['age'] = (lo, hi, r['Age_Group'])
            report['toys_merged'].append(f'{r["Product_Name"]} by {r["Brand"]}')
            continue
        tid = 'pvt_z_' + slug(r['Product_Name'], r['Brand'])
        if tid in ids:
            raise SheetError(f'0-5 row {i}: id {tid} twice')
        ids.add(tid)
        seen_z[key] = {
            'id': tid, 'name': r['Product_Name'],
            # "ParentVeda Curated" / "Generic" name a kind of toy, not a maker.
            'brand': _brand(r['Brand']),
            'category': r['Category'], 'sub': r['Subcategory'], 'age': (lo, hi, r['Age_Group']),
            'tier': r['Budget_Tier'].lower(),
            'skills': skills(r['Primary_Intent'], r['Secondary_Intent'], r['Parent_Bucket_1'],
                             r['Parent_Bucket_2'], r['Parent_Bucket_3']),
            'score': None, 'confidence': int(r['Recommendation_Confidence']), 'sub_scores': [],
            'verified': r.get('Product_Type') == 'Verified Product',
        }
        out.append(seen_z[key])
    z_names = {(r['Product_Name'].lower(), _brand(r['Brand']).lower()) for r in zero5}
    for r in newcats:
        if (r['Product_Name'].lower(), _brand(r['Brand']).lower()) not in z_names:
            raise SheetError(f'New Product Categories: "{r["Product_Name"]}" is not in the 0-5 master')
    report['newcats'] = len(newcats)
    return out


# ---- children's books -------------------------------------------------------------------------

AGE_RE = re.compile(r'^\d+-\d+y$')


def kids_books(rows, report):
    need(rows[0], ['Book Title', 'Author', 'Publisher', 'Indian/Global', 'Age Bucket', 'Parent Intent',
                   'Theme', 'Reading Mode', 'Recommendation Type'], 'Book Recommendations')
    books = {}
    for i, r in enumerate(rows, start=2):
        r = dict(r)
        if r['Publisher'] in ('Indian', 'Global') and AGE_RE.match(r['Indian/Global'] or ''):
            # Publisher cell missing: every later column moved one place left.
            report['books_repaired'].append(f'row {i}: {r["Book Title"]}')
            r = {**r, 'Publisher': '', 'Indian/Global': r['Publisher'], 'Age Bucket': r['Indian/Global'],
                 'Parent Intent': r['Age Bucket'], 'Theme': r['Parent Intent']}
        if not AGE_RE.match(r['Age Bucket'] or '') or r['Indian/Global'] not in ('Indian', 'Global'):
            report['books_skipped'].append(f'row {i}: {r["Book Title"]} (age "{r["Age Bucket"]}")')
            continue
        lo, hi = months(r['Age Bucket'], f'Books row {i}')
        key = (r['Book Title'].lower(), r['Author'].lower())
        goal = r['Parent Intent']
        if key in books:
            b = books[key]
            if goal and goal not in b['goals']:
                b['goals'].append(goal)
            report['books_merged'].append(r['Book Title'])
            continue
        books[key] = {
            'id': 'kb_' + slug(r['Book Title'], r['Author']), 'title': r['Book Title'], 'author': r['Author'],
            'publisher': r['Publisher'], 'indian': r['Indian/Global'] == 'Indian',
            'age': (lo, hi, r['Age Bucket']), 'goals': [goal] if goal else [], 'theme': r['Theme'],
            'mode': r.get('Reading Mode', ''), 'essential': r.get('Recommendation Type') == 'Essential',
            'nice': r.get('Recommendation Type') == 'Nice to Have',
        }
    out = list(books.values())
    if len({b['id'] for b in out}) != len(out):
        raise SheetError('Books: two books share an id')
    return out


# ---- Dart ---------------------------------------------------------------------------------------

def q(s):
    s = s.replace('\\', '\\\\').replace("'", "\\'").replace('$', '\\$')
    return f"'{s}'"


def ql(items):
    return '[' + ', '.join(q(x) for x in items) + ']'


HEAD = '// GENERATED by tools/products/xlsx_to_dart.py - do not edit by hand.\n'


def dart_catalogue(picks):
    L = [HEAD, "// Source: ParentVeda Pregnancy and Parenting Product Catalogue.xlsx", '',
         "import '../pv_sheet_products.dart';", '', 'const List<SheetPick> kSheetPicks = [']
    for p in picks:
        L.append(f"  SheetPick({q(p['id'])}, SheetBucket.{p['bucket']}, {q(p['category'])}, {q(p['sub'])},")
        L.append(f"      {ql(p['factors'])},")
        L.append(f"      {q(p['tier'])}, {q(p['brand'])}, {q(p['name'])}, {p['week']}"
                 + (', held: true' if p['held'] else '') + '),')
    L.append('];')
    return '\n'.join(L) + '\n'


def dart_toys(ts):
    L = [HEAD, '// Sources: ParentVeda Products Master.xlsx, ParentVeda 0-5 Product Master.xlsx', '',
         "import '../pv_sheet_products.dart';", '', 'const List<SheetToy> kSheetToys = [']
    for t in ts:
        age = t['age']
        L.append('  SheetToy(')
        L.append(f"    id: {q(t['id'])}, name: {q(t['name'])}, brand: {q(t['brand'])},")
        L.append(f"    category: {q(t['category'])}, sub: {q(t['sub'])}, tier: {q(t['tier'])},")
        if age:
            L.append(f"    ageMin: {age[0]}, ageMax: {age[1]}, ageLabel: {q(age[2])},")
        L.append(f"    skills: {ql(t['skills'])},")
        L.append(f"    score: {t['score'] if t['score'] is not None else 'null'}, confidence: {t['confidence']},")
        if t['sub_scores']:
            L.append('    subScores: [' + ', '.join(f"({q(k)}, {int(v)})" for k, v in t['sub_scores']) + '],')
        L.append('  ),')
    L.append('];')
    return '\n'.join(L) + '\n'


def dart_books(bs):
    L = [HEAD, '// Source: ParentVeda Book Recommendations Master.xlsx', '',
         "import '../kids_books.dart';", '', 'const List<KidsBook> kKidsBooks = [']
    for b in bs:
        L.append('  KidsBook(')
        L.append(f"    id: {q(b['id'])}, title: {q(b['title'])}, author: {q(b['author'])},")
        L.append(f"    publisher: {q(b['publisher'])}, indian: {'true' if b['indian'] else 'false'},")
        L.append(f"    ageMin: {b['age'][0]}, ageMax: {b['age'][1]}, ageLabel: {q(b['age'][2])},")
        L.append(f"    goals: {ql(b['goals'])}, theme: {q(b['theme'])}, mode: {q(b['mode'])},")
        rec = 'essential' if b['essential'] else ('niceToHave' if b['nice'] else 'listed')
        L.append(f'    rank: KidsBookRank.{rec},')
        L.append('  ),')
    L.append('];')
    return '\n'.join(L) + '\n'


def write(folder, name, text):
    os.makedirs(folder, exist_ok=True)
    with open(os.path.join(folder, name), 'w', encoding='utf-8', newline='\n') as fh:
        fh.write(text)


def main():
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    folder = sys.argv[1]
    books_wb = {}
    try:
        wb = {f: read_xlsx(os.path.join(folder, f)) for f in sorted(os.listdir(folder)) if f.endswith('.xlsx')}
        expect = {'ParentVeda Pregnancy and Parenting Product Catalogue.xlsx', 'ParentVeda Products Master.xlsx',
                  'ParentVeda 0-5 Product Master.xlsx', 'ParentVeda New Product Categories.xlsx',
                  'ParentVeda Book Recommendations Master.xlsx'}
        if set(wb) != expect:
            raise SheetError(f'unexpected files: {sorted(set(wb) ^ expect)}')
        report = {'toys_dup': [], 'toys_merged': [], 'toys_reused_id': [], 'toys_family': [], 'books_repaired': [], 'books_skipped': [], 'books_merged': []}
        picks = catalogue(wb['ParentVeda Pregnancy and Parenting Product Catalogue.xlsx']['Sheet1'])
        ts = toys(wb['ParentVeda Products Master.xlsx']['Products_Master'],
                  wb['ParentVeda 0-5 Product Master.xlsx']['ParentVeda_0to5_Master'],
                  wb['ParentVeda New Product Categories.xlsx']['ParentVeda_NewCategories_FINAL'], report)
        books_wb = wb['ParentVeda Book Recommendations Master.xlsx']
        bs = kids_books(books_wb['Candidate_Book_Master'], report)
    except SheetError as e:
        sys.exit(f'Stopped, nothing written: {e}')

    write(OUT_PRODUCTS, 'catalogue.dart', dart_catalogue(picks))
    write(OUT_PRODUCTS, 'toys.dart', dart_toys(ts))
    write(OUT_BOOKS, 'kids_books_list.dart', dart_books(bs))

    held = [p for p in picks if p['held']]
    print(f'Catalogue: {len(picks)} picks in {len({p["sub"] for p in picks})} sub-categories, '
          f'{len({p["category"] for p in picks})} categories; held {len(held)} '
          f'({", ".join(sorted({p["sub"] for p in held}))})')
    print(f'Toys: {len(ts)} ({sum(1 for t in ts if t["score"] is not None)} scored, '
          f'{sum(1 for t in ts if t["age"])} with an age, {sum(1 for t in ts if not t["verified"])} not yet verified '
          f'in the sheet); merged {len(report["toys_merged"])}: '
          f'{"; ".join(report["toys_merged"])}; duplicate rows skipped {len(report["toys_dup"])}')
    for d in report['toys_dup']:
        print('  dup ' + d)
    print(f'PV_IDs used twice ({len(report["toys_reused_id"])} rows), to renumber:')
    for d in report['toys_reused_id']:
        print('  ' + d)
    print(f'Rows the sheet marks "Product Family" (a range, not one product): {len(report["toys_family"])}')
    print(f'New Product Categories: all {report["newcats"]} rows are in the 0-5 master (skipped)')
    print(f'Kids books: {len(bs)} (repaired {len(report["books_repaired"])}, '
          f'merged {len(report["books_merged"])}, skipped {len(report["books_skipped"])})')
    for k in ('books_repaired', 'books_skipped', 'books_merged'):
        for d in report[k]:
            print(f'  {k[6:]} {d}')
    print('Not carried: the books sheet\'s empty scoring sheets; "Why Recommended" (it repeats the theme); '
          '"Tags" (all "Candidate").')


if __name__ == '__main__':
    main()
