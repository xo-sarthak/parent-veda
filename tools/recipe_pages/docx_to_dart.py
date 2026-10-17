"""Drive recipe docs (.docx) -> lib/data/pp_recipe_docs/band_<band>.dart.

Usage (from the repo root):
    python -I tools/recipe_pages/docx_to_dart.py "<recipe doc .docx>" 7_8m

The docs live in the Drive folder "Recipes (not reviewed)", one per age band
("7-8 month band (PROMPT4) FINAL" is the first). Each recipe is one block that
starts with its id line ("7-8M-REC-01 — Oats porridge") and runs through fixed
labels: Why this is good for him, the PREP | COOK | LEVEL | AGE table, What
you need (an Ingredient | How much table), You'll also need, How to make it,
What's in it, Good to know, Take care, You can swap, More on ParentVeda.

It writes one `FoodRecipe` per block in the doc format the recipe page reads
(amounts beside ingredients, texture, meal role, alsoIn, docId), which is
what switches a dish onto the new page and photo card.

Strict on purpose, like tools/phase_pages: an unknown paragraph inside a
block, an unknown tag, a missing section or an ingredient row without an
amount stops the run, naming the recipe and the line. Standard library only.

Two things it derives, both from the repo rather than guessed:
  * ingredientKeys: only keys the Smart Meal Builder already knows (read from
    pp_food_data.dart), so a doc dish never adds a key nothing else uses;
  * photo: set only when assets/recipes/<id>.webp exists, so dropping a photo
    in and re-running is all it takes.
"""

import html
import os
import re
import sys
import zipfile

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
OUT_DIR = os.path.join(ROOT, 'lib', 'data', 'pp_recipe_docs')
FOOD_DATA = os.path.join(ROOT, 'lib', 'screens', 'post_pregnancy', 'pp_food_data.dart')

# The doc's categories, as kFoodCategories spells them.
CATEGORIES = ['First Foods', 'Breakfast', 'Lunch', 'Dinner', 'Snacks', 'Soups', 'Travel Food', 'Finger Foods']
# A dish's home rail is its first MEAL category; First Foods and Travel Food
# are always cross-listings (the pilot: First Foods Lunch Dinner -> Lunch).
HOME_ORDER = ['Breakfast', 'Lunch', 'Dinner', 'Snacks', 'Soups', 'Finger Foods']
SLOT = {'Breakfast': 'Breakfast', 'Lunch': 'Lunch', 'Dinner': 'Dinner',
        'Snacks': 'Evening snack', 'Finger Foods': 'Evening snack', 'Soups': 'Lunch'}
# Tags the page reads, and tags that are only labels in the doc.
OTHER_TAGS = ['Vegetarian', 'Vegan', 'Non-Veg', 'Soft Mash', 'Soft', 'Self-Feeding', 'No Cook',
              'No Added Sugar', 'Gluten Free', 'Indian']
AGE_TAG = re.compile(r'^\d+(-\d+)?M$')

LABELS = ['Why this is good for him', 'What you need', 'How to make it', "What's in it",
          'Good to know', 'Take care', 'You can swap', 'More on ParentVeda']
END_OF_BLOCKS = re.compile(r'^(FINGER FOODS$|ParentVeda —|COVERAGE REPORT)')
ID_LINE = re.compile(r'^(\d+-\d+M-REC-(\d+)) — (.+)$')

STOP = {'and', 'with', 'the', 'for', 'first', 'non', 'veg', 'food'}
NUTRIENT_WORDS = ['protein', 'iron', 'calcium', 'fibre', 'energy', 'vitamin a', 'vitamin c', 'folate',
                  'healthy fat', 'vitamins']


class DocError(Exception):
    pass


def blocks(path):
    """The doc body as ('p', text, is_list) and ('t', rows) items, in order."""
    xml = zipfile.ZipFile(path).read('word/document.xml').decode('utf8')
    body = re.search(r'<w:body>(.*)</w:body>', xml, re.S).group(1)

    def text(x):
        x = re.sub(r'<w:br/>', '\n', x)
        return html.unescape(''.join(re.findall(r'<w:t[^>]*>([^<]*)</w:t>', x))).strip()

    out = []
    for m in re.finditer(r'<w:tbl>.*?</w:tbl>|<w:p[ >].*?</w:p>', body, re.S):
        b = m.group(0)
        if b.startswith('<w:tbl>'):
            rows = [[text(c) for c in re.findall(r'<w:tc>.*?</w:tc>', r, re.S)]
                    for r in re.findall(r'<w:tr[ >].*?</w:tr>', b, re.S)]
            out.append(('t', rows))
        else:
            out.append(('p', text(b), '<w:numPr>' in b))
    return out


def split_recipes(items):
    """[(doc_id, number, id_name, [items...])] for every recipe block."""
    recipes, cur = [], None
    for it in items:
        if it[0] == 'p':
            m = ID_LINE.match(it[1])
            if m:
                cur = (m.group(1), int(m.group(2)), m.group(3), [])
                recipes.append(cur)
                continue
            if END_OF_BLOCKS.match(it[1]):
                cur = None
                continue
        if cur is not None:
            cur[3].append(it)
    return recipes


def slug(name):
    name = re.sub(r'\(.*?\)', '', name)
    return re.sub(r'[^a-z0-9]+', '_', name.lower()).strip('_')


def sentence(s):
    s = s.strip()
    if not s:
        return s
    s = s[0].upper() + s[1:]
    return s if s.endswith(('.', '!', '?')) else s + '.'


def known_keys():
    src = open(FOOD_DATA, encoding='utf-8').read()
    keys = set()
    for body in re.findall(r'ingredientKeys:\s*\{([^}]*)\}', src):
        keys.update(re.findall(r"'([^']+)'", body))
    return keys


def parse(doc_id, number, id_name, items, band, keys):
    where = f'{doc_id} ({id_name})'

    def fail(msg):
        raise DocError(f'{where}: {msg}')

    paras = [it for it in items if not (it[0] == 'p' and not it[1])]
    if len(paras) < 4 or paras[0][0] != 'p':
        fail('too short')
    title, subtitle, diet_line, tag_line = (p[1] for p in paras[:4])
    rest = paras[4:]

    # --- diet · serves · meal role
    m = re.match(r'^\W*\s*(Veg|Egg|Non-Veg)\s*·\s*Serves\s+(\d+)\s*·\s*Meal role:\s*(.+)$', diet_line)
    if not m:
        fail(f'diet line not understood: {diet_line!r}')
    diet, serves, meal_role = m.group(1), int(m.group(2)), m.group(3).strip()
    meal_role = meal_role[0].upper() + meal_role[1:]

    # --- tags
    if not tag_line.startswith('TAGS:'):
        fail(f'expected TAGS, got {tag_line!r}')
    t = ' ' + tag_line[5:].strip() + ' '
    cats, flags = [], set()
    for name in sorted(CATEGORIES + OTHER_TAGS, key=len, reverse=True):
        while f' {name} ' in t:
            i = t.index(f' {name} ')
            if name in CATEGORIES:
                cats.append(name)
            else:
                flags.add(name)
            t = t[:i] + ' ' + t[i + len(name) + 2:]
    leftover = [w for w in t.split() if not AGE_TAG.match(w)]
    if leftover:
        fail(f'unknown tags {leftover}')
    order = {c: tag_line.index(c) for c in cats}
    cats.sort(key=order.get)
    home = next((c for c in cats if c in HOME_ORDER), None)
    if home is None:
        fail(f'no meal category in {cats}')
    also = [c for c in cats if c != home]
    texture = 'Soft mash' if 'Soft Mash' in flags else ('Soft' if 'Soft' in flags else None)

    # --- the labelled sections
    sections, label = {}, None
    for it in rest:
        if it[0] == 'p' and it[1] in LABELS:
            label = it[1]
            sections[label] = []
            continue
        if label is None:
            fail(f'text before the first section: {it!r}')
        sections[label].append(it)
    for need in LABELS[:-1]:
        if need not in sections:
            fail(f'missing section {need!r}')

    # Why ... then the facts table
    why_items = sections['Why this is good for him']
    facts = [it for it in why_items if it[0] == 't']
    why = ' '.join(it[1] for it in why_items if it[0] == 'p')
    if len(facts) != 1 or not why:
        fail('why text or facts table missing')
    row = facts[0][1][0]
    if len(row) != 4:
        fail(f'facts row {row!r}')
    prep, cook = (int(re.match(r'(\d+)\s*min', x).group(1)) for x in row[:2])
    difficulty = row[2]
    age = re.match(r'(\d+)\+ months', row[3])
    if not age:
        fail(f'age {row[3]!r}')
    age_tag = '7 to 8 mo' if age.group(1) == '7' else f'{age.group(1)} mo+'

    # What you need: the ingredient table, then "You'll also need"
    need = sections['What you need']
    tables = [it for it in need if it[0] == 't']
    if len(tables) != 1:
        fail('ingredient table missing')
    ingredients, amounts = [], []
    for r in tables[0][1][1:]:
        if len(r) != 2 or not r[0] or not r[1]:
            fail(f'ingredient row {r!r}')
        ingredients.append(r[0])
        amounts.append(r[1])
    equipment = []
    for it in need:
        if it[0] == 'p':
            m = re.match(r"^You'll also need:\s*(.+)$", it[1])
            if not m:
                fail(f'unexpected line in What you need: {it[1]!r}')
            gear = m.group(1).strip()
            if gear.lower() != 'nothing special':
                equipment = [g.strip() for g in re.split(r',\s*|\s+and\s+', gear) if g.strip()]

    steps = [it[1] for it in sections['How to make it'] if it[0] == 'p' and not it[1].startswith('➕')]
    if not steps:
        fail('no steps')

    # What's in it: "Fibre: oats. Iron (from plants): oats."
    whats = ' '.join(it[1] for it in sections["What's in it"])
    nutrients = []
    for part in re.split(r'(?<=\.)\s+(?=[A-Z][^:.]{0,48}:)', whats):
        m = re.match(r'^([^:]+):\s*(.+)$', part.strip())
        if not m:
            fail(f"What's in it not understood: {part!r}")
        nutrients.append((m.group(1).strip(), sentence(m.group(2))))

    gk = ' '.join(it[1] for it in sections['Good to know'])
    m = re.search(r'How often:\s*(.+?)\s*❄\s*Storing:\s*(.+)$', gk)
    if not m:
        fail(f'Good to know not understood: {gk!r}')
    frequency, storage = sentence(m.group(1)), sentence(m.group(2))

    mistakes = [it[1] for it in sections['Take care'] if it[0] == 'p']
    swaps = []
    for it in sections['You can swap']:
        for part in it[1].split(' · '):
            a, arrow, b = part.partition('→')
            swaps.append((a.strip(), b.strip()) if arrow else (part.strip(), ''))

    rid = f'pp_{band}_{slug(id_name)}'
    photo = f'assets/recipes/{rid}.webp'
    has_photo = os.path.exists(os.path.join(ROOT, photo))

    seed = 147 if number == 11 else 147 + number - (1 if number > 11 else 0)

    def short(n):
        return re.sub(r'\s*\(from plants\)', '', n)
    names = [short(n) for n, _ in nutrients]
    highlight = names[0] if len(names) == 1 else f'{names[0]} + {names[1][0].lower() + names[1][1:]}'

    words = [w for w in re.findall(r'[a-z]+', re.sub(r'\(.*?\)', '', title.lower())) if len(w) > 2 and w not in STOP]
    low_whats = whats.lower()
    tags = list(dict.fromkeys(words + [n for n in NUTRIENT_WORDS if n in low_whats] + [c.lower() for c in cats]))
    low_ing = ' '.join(ingredients).lower()
    ing_keys = sorted(k for k in keys if k != 'water' and re.search(r'\b' + re.escape(k) + r'\b', low_ing))

    return dict(
        id=rid, docId=doc_id, photo=photo if has_photo else None, title=title, subtitle=subtitle,
        category=home, alsoIn=also, slot=SLOT[home], ageTag=age_tag,
        veg=diet == 'Veg', egg=diet == 'Egg', vegan='Vegan' in flags, serves=serves,
        mealRole=meal_role, texture=texture, prepMin=prep, cookMin=cook, difficulty=difficulty,
        seed=seed, highlight=highlight, why=why, nutrients=nutrients, frequency=frequency,
        ingredients=ingredients, amounts=amounts, equipment=equipment, steps=steps,
        storage=[storage], mistakes=mistakes, substitutions=swaps, tags=tags, ingredientKeys=ing_keys,
        number=number,
    )


def q(s):
    return "'" + s.replace('\\', '\\\\').replace("'", "\\'").replace('$', '\\$') + "'"


def qlist(xs):
    return '[' + ', '.join(q(x) for x in xs) + ']'


def qset(xs):
    return '{' + ', '.join(q(x) for x in xs) + '}'


def emit(r):
    L = ['  FoodRecipe(',
         f"    id: {q(r['id'])},",
         f"    docId: {q(r['docId'])},"]
    if r['photo']:
        L.append(f"    photo: {q(r['photo'])},")
    L += [f"    title: {q(r['title'])},",
          f"    subtitle: {q(r['subtitle'])},",
          f"    category: {q(r['category'])},"]
    if r['alsoIn']:
        L.append(f"    alsoIn: {qset(r['alsoIn'])},")
    L += [f"    slot: {q(r['slot'])},",
          f"    ageTag: {q(r['ageTag'])},",
          f"    veg: {str(r['veg']).lower()},"]
    if r['egg']:
        L.append('    egg: true,')
    if r['vegan']:
        L.append('    vegan: true,')
    L += [f"    serves: {r['serves']},",
          f"    mealRole: {q(r['mealRole'])},"]
    if r['texture']:
        L.append(f"    texture: {q(r['texture'])},")
    L += [f"    prepMin: {r['prepMin']},",
          f"    cookMin: {r['cookMin']},",
          f"    difficulty: {q(r['difficulty'])},",
          f"    seed: {r['seed']},",
          f"    highlight: {q(r['highlight'])},",
          f"    why: {q(r['why'])},",
          '    nutrients: [']
    L += [f"      FoodNutrient({q(n)}, '', {q(s)})," for n, s in r['nutrients']]
    L += ['    ],',
          f"    frequency: {q(r['frequency'])},",
          f"    ingredients: {qlist(r['ingredients'])},",
          f"    amounts: {qlist(r['amounts'])},"]
    if r['equipment']:
        L.append(f"    equipment: {qlist(r['equipment'])},")
    L += [f"    steps: {qlist(r['steps'])},",
          f"    storage: {qlist(r['storage'])},",
          f"    mistakes: {qlist(r['mistakes'])},",
          '    substitutions: {' + ', '.join(f'{q(a)}: {q(b)}' for a, b in r['substitutions']) + '},',
          "    healthierNote: '',",
          f"    tags: {qset(r['tags'])},",
          f"    ingredientKeys: {qset(r['ingredientKeys'])},",
          '  ),']
    return '\n'.join(L)


def main():
    if len(sys.argv) != 3:
        raise SystemExit(__doc__)
    path, band = sys.argv[1], sys.argv[2]
    keys = known_keys()
    raw = split_recipes(blocks(path))
    seen = set()
    recipes = []
    for doc_id, number, id_name, items in raw:
        if doc_id in seen:
            raise DocError(f'{doc_id} appears twice')
        seen.add(doc_id)
        recipes.append(parse(doc_id, number, id_name, items, band, keys))
    recipes.sort(key=lambda r: r['number'])
    name = 'kRecipeBand' + ''.join(p.capitalize() for p in band.split('_'))
    out = [
        '// GENERATED by tools/recipe_pages/docx_to_dart.py - do not edit by hand.',
        f'// Source: Drive "Recipes (not reviewed)" / {os.path.basename(path)}.',
        '// The doc is the source of truth: fix the doc, re-run the converter.',
        '// Its status is "Editorial Review Pending — Medical Review Pending".',
        '',
        "import '../../screens/post_pregnancy/pp_food_data.dart' show FoodRecipe, FoodNutrient;",
        '',
        f'const List<FoodRecipe> {name} = [',
    ]
    out += [emit(r) for r in recipes]
    out += ['];', '']
    os.makedirs(OUT_DIR, exist_ok=True)
    dest = os.path.join(OUT_DIR, f'band_{band}.dart')
    with open(dest, 'w', encoding='utf-8', newline='\n') as f:
        f.write('\n'.join(out))
    print(f'{len(recipes)} recipes -> {os.path.relpath(dest, ROOT)}')
    for r in recipes:
        print(f"  {r['docId']}  {r['id']}  {r['category']} +{r['alsoIn']}  {r['ageTag']}"
              f"  photo={'yes' if r['photo'] else 'no'}")


if __name__ == '__main__':
    try:
        main()
    except DocError as e:
        raise SystemExit(f'STOP: {e}')
