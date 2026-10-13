"""Book companion docs (.docx / .pdf) -> lib/data/book_companions/*.dart.

Usage (from the repo root):
    python -I tools/book_companions/docx_to_dart.py "<Book summary folder>"

Every companion follows the Book Companion Bible: Hero -> What this book is
about -> About the author -> Core philosophy -> The book's most important ideas
-> Chapter by chapter -> ParentVeda's take -> Memorable quotes, and sometimes
one addendum ("Talk to your doctor before", "When to seek extra help",
"Reading this in an Indian context"). Single-book files hold one book; a
"Volume" file holds several, listed in its Contents.

The docs were written over many revisions, so their layout varies: the Hero
is a table or "Field: value" lines; pointers are list items or "•" runs; a
chapter title is on its own line, glued in a bold run, or glued to a summary
that opens with a verb. Parsing is by label, and each fallback is tried in
order. Writers' blocks (BOOK ID, COPYRIGHT CHECK, QUALITY CHECKLIST, NOTE,
LAST VERIFIED, STATUS, revision notes) end a book and are never carried.

Strict: a book with no title, author, about, philosophy, ideas, chapters or
take stops the run with the file and the book named. Standard library, plus
pypdf for the one PDF (if pypdf is missing or the PDF will not parse, it is
reported and left out, never half-read).
"""

import html
import os
import re
import sys
import zipfile

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
OUT = os.path.join(ROOT, 'lib', 'data', 'book_companions')
BR = '\n'

SECTIONS = [
    ('hero', r'hero'),
    ('about', r'what this book is about'),
    ('author', r'about the author'),
    ('philosophy', r'core philosophy'),
    ('ideas', r'the book.s most important ideas'),
    ('chapters', r'chapter[- ]by[- ]chapter summary'),
    ('take', r'parentveda.s take'),
    ('quotes', r'memorable quotes'),
]
ADDENDA = r'(talk to your doctor before|when to seek extra help|reading this in an indian context)'
# A line that starts the writers' material: the book ends there.
WRITERS = re.compile(r'^(copyright check|quality checklist|internal quality checklist|book id|note\b|note on|'
                     r'last verified|status:|verification|editorial notes|revision note|revision notes|'
                     r'checked against|title / author|section\(s\) covered|idea count|word count)', re.I)
# A chapter summary's opening verb, for titles glued to their summary with no
# break, bold or punctuation between them ("Part 2: The Child as a Being, Not a
# Project Turns to the child's own essence…").
VERBS = (r'Introduces|Explains|Breaks|Shows|Addresses|Covers|Tackles|Opens|Turns|Moves|Reframes|Closes|'
         r'Sets|Describes|Walks|Lays|Offers|Gives|Looks|Focuses|Examines|Explores|Argues|Begins|Ends|Wraps|'
         r'Takes|Presents|Outlines|Makes|Builds|Unpacks|Details|Treats|Compares|Teaches|Answers|Shifts|Returns')


class DocError(Exception):
    pass


MISSING = []  # books a file lists but does not contain


# ---- reading --------------------------------------------------------------------

def para_runs(p):
    """Paragraph text, with BR at line breaks and at a bold title's end."""
    out, prev_bold = [], None
    for run in re.findall(r'<w:r[ >].*?</w:r>', p, re.S):
        # Text and breaks IN ORDER: one run can hold "title<w:br/>body".
        pieces = re.findall(r'<w:t[^>]*>([^<]*)</w:t>|(<w:br\b[^>]*/>|<w:cr/>)', run)
        t = ''.join(a for a, b in pieces)
        bold = re.search(r'<w:b(?: w:val="(?:1|true)")?/>', run) is not None
        if prev_bold and not bold and t.strip() and out and not out[-1].endswith(BR):
            out.append(BR)  # "Title" in bold, then the summary in plain
        for a, b in pieces:
            out.append(BR if b else a)
        if t.strip():
            prev_bold = bold
    return html.unescape(''.join(out))


def read_docx(path):
    """Lines as (kind, text): kind is 'h' heading, 'li' list item, 'p' paragraph, 'tr' table row."""
    x = zipfile.ZipFile(path).read('word/document.xml').decode('utf8')
    body = re.search(r'<w:body>(.*)</w:body>', x, re.S).group(1)
    lines = []
    for blk in re.findall(r'<w:tbl>.*?</w:tbl>|<w:p[ >].*?</w:p>', body, re.S):
        if blk.startswith('<w:tbl>'):
            for row in re.findall(r'<w:tr[ >].*?</w:tr>', blk, re.S):
                cells = []
                for c in re.findall(r'<w:tc>.*?</w:tc>', row, re.S):
                    cells.append(' '.join(' '.join(para_runs(p).split()) for p in re.findall(r'<w:p[ >].*?</w:p>', c, re.S)).strip())
                lines.append(('tr', cells))
            continue
        st = (re.search(r'<w:pStyle w:val="([^"]+)"', blk) or [None, ''])[1].lower()
        # A numbered paragraph is a list item even when styled as a heading
        # (Whole-Brain Child and Conscious Parent style every line as one).
        kind = 'li' if '<w:numPr>' in blk else ('h' if st.startswith(('heading', 'title')) else 'p')
        for k, seg in enumerate(para_runs(blk).split(BR)):
            seg = ' '.join(seg.split())
            if seg:
                lines.append((kind if k == 0 else ('li' if kind == 'li' else 'p'), seg))
    return lines


def read_pdf(path):
    try:
        from pypdf import PdfReader
    except ImportError:
        raise DocError(f'{os.path.basename(path)}: pypdf is not installed')
    text = '\n'.join(p.extract_text() or '' for p in PdfReader(path).pages)
    # pypdf spaces every word and breaks every line; rebuild paragraphs by label.
    text = re.sub(r'[ \t]+', ' ', text)
    text = re.sub(r'\s*\n\s*', ' ', text)
    # The writers' block starts at "BOOK ID"; nothing after it is the book.
    text = text.split('BOOK ID:')[0]
    labels = ['1. Hero', '2. What This Book Is About', '3. About the Author', '4. Core Philosophy',
              "5. The Book's Most Important Ideas", '6. Chapter-by-Chapter Summary', "7. ParentVeda's Take",
              '8. Memorable Quotes', 'Talk to Your Doctor Before', 'When to Seek Extra Help',
              'Reading This in an Indian Context', 'COPYRIGHT CHECK', 'QUALITY CHECKLIST']
    for lab in labels:
        text = text.replace(lab, '\u0001' + lab + '\u0001')
    lines, cur = [], None
    for part in text.split('\u0001'):
        part = part.strip()
        if not part:
            continue
        if part in labels:
            lines.append(('h', part))
            cur = part
            continue
        lines += pdf_section_lines(cur or '', part)
    return lines


SMALL = {'of', 'the', 'a', 'an', 'and', 'to', 'in', 'on', 'for', 'by', 'with', 'is', 'not', 'your', 'at', 'or'}


def split_title_case(s):
    """'Connect: The Foundation of Everything Before any coaching…' -> title, body.
    The body starts at the first capitalised word followed by an ordinary
    lower-case word (a title's small words — of, the, by — do not count)."""
    w = s.split(' ')
    for i in range(1, len(w) - 1):
        if w[i][:1].isupper() and w[i + 1][:1].islower() and w[i + 1].lower() not in SMALL:
            return ' '.join(w[:i]).strip(), ' '.join(w[i:]).strip()
    return None


def pdf_section_lines(label, blob):
    """Rebuild a PDF section's lines from its flattened text."""
    out = []
    if label == '1. Hero':
        fields = ['Book Title', 'Author', 'ParentVeda Rating', 'Reading Time', 'Recommended For', 'Primary Themes']
        pat = '(' + '|'.join(map(re.escape, fields)) + ')'
        parts = re.split(pat, blob.replace('Field Value', ''))
        for i in range(1, len(parts) - 1, 2):
            out.append(('tr', [parts[i], parts[i + 1].strip()]))
        return out
    if label.startswith('5.'):
        for m in re.finditer(r'(\d)\.\s+(.+?)(?=\s\d\.\s+[A-Z]|$)', blob):
            head, *bul = [x.strip() for x in m.group(2).split('●')]
            sp = split_title_case(head) if ':' in head[:40] else None
            if not sp:
                raise DocError(f'PDF idea {m.group(1)}: no title split in {head[:60]!r}')
            out.append(('p', f'{m.group(1)}. {sp[0]}'))
            out.append(('p', sp[1]))
            out += [('li', b) for b in bul if b]
        return out
    if label.startswith('6.'):
        for chunk in re.split(r'(?=Part \d+:)', blob):
            chunk = chunk.strip()
            if not chunk:
                continue
            head, _, rest = chunk.partition('Read More:')
            out.append(('h', head.strip()))
            if rest:
                out.append(('p', 'Read More:'))
                out += [('li', b.strip()) for b in rest.split('●') if b.strip()]
        return out
    if label.startswith('8.'):
        # Each quote with its "(on …)" note: "I accept and love you…" (on the manifesto)
        found = re.findall(r'([“"][^”"]+[”"]\s*(?:\([^)]*\))?)', blob)
        return [('p', q.strip()) for q in found]
    if '●' in blob:
        first, *bul = blob.split('●')
        return [('p', first.strip())] + [('li', b.strip()) for b in bul if b.strip()]
    if label.startswith('3.') and 'Other notable books' in blob:
        a, b = blob.split('Other notable books', 1)
        return [('p', a.strip()), ('p', 'Other notable books' + b)]
    return [('p', blob)]


# ---- splitting a file into books -----------------------------------------------------

def books_in(lines, fname):
    """[(title_line, lines)] for each book in a file."""
    contents, contents_end = [], 0
    for i, (k, t) in enumerate(lines):
        if k != 'tr' and t.lower() == 'contents':
            contents_end = i
            for k2, t2 in lines[i + 1:]:
                if k2 == 'tr':
                    break
                m = re.match(r'^(\d+)\.\s+(.+?)(?:\s+—\s+.+)?$', t2)
                if not m:
                    if k2 == 'h':  # a group heading inside Contents ("Sleep", "Nutrition")
                        contents_end += 1
                        continue
                    break
                contents.append((int(m.group(1)), m.group(2).strip()))
                contents_end += 1
            break
    if not contents:
        return [(None, lines)]
    starts = []
    for n, title in contents:
        # Match on the short title: a heading may drop the subtitle Contents gives
        # ("16. Child of Mine" vs "Child of Mine: Feeding with Love…").
        short = title.split(':')[0].strip()[:25]
        pat = re.compile(r'^' + str(n) + r'\.\s+' + re.escape(short), re.I)
        hits = [i for i, (k, t) in enumerate(lines) if k != 'tr' and pat.match(t)]
        # The Contents list itself matches too; the book is a hit after it.
        body_hits = [i for i in hits if i > contents_end]
        if not body_hits:
            # Listed, never written (Volume Three's book 14). Reported, not fatal.
            MISSING.append(f'{fname}: "{n}. {title}" is in its Contents but the companion is not in the file')
            continue
        starts.append(body_hits[0])
    out = []
    for j, s in enumerate(starts):
        e = starts[j + 1] if j + 1 < len(starts) else len(lines)
        out.append((lines[s][1], lines[s + 1:e]))
    return out


# ---- one book ------------------------------------------------------------------------

def norm(t):
    return re.sub(r'^\d+\.\s*', '', t).strip().lower().replace('’', "'")


def section_key(t):
    n = norm(t)
    for key, pat in SECTIONS:
        if re.fullmatch(pat, n):
            return key
    if re.fullmatch(ADDENDA, n):
        return 'addendum'
    return None


def bullets(t):
    """'• a • b' -> ['a', 'b']; plain text -> [text]."""
    if '•' in t:
        return [x.strip() for x in t.split('•') if x.strip()]
    return [t]


def split_title(t):
    """A chapter or idea title glued to its text, by an opening verb."""
    m = re.match(r'^(.{3,120}?)\s+((?:' + VERBS + r')\b.+)$', t)
    return (m.group(1).strip(), m.group(2).strip()) if m else None


def parse_book(name, lines, fname):
    sec, cur = {}, None
    for k, t in lines:
        if k != 'tr' and WRITERS.match(t):
            break
        # Volume Three closes with editorial notes headed "On the substance
        # standard…", "On medical and factual verification" — not the book.
        if k == 'h' and re.match(r'^On (the|medical)\b', t):
            break
        key = section_key(t) if k != 'tr' and len(t) < 70 else None
        if key:
            cur = key
            if key == 'addendum':
                sec['addendum_title'] = t.strip()
            sec.setdefault(cur, [])
            continue
        if cur:
            sec[cur].append((k, t))
    book = {'file': fname}

    # Hero: table rows or "Field: value" lines.
    hero = {}
    rows = sec.get('hero', [])
    pending = None  # "Title:" in bold, its value on the next line
    for k, t in rows:
        if k == 'tr' and len(t) >= 2:
            hero[t[0].strip().lower()] = t[1].strip()
            continue
        if k == 'tr':
            continue
        if pending:
            hero[pending] = t.strip()
            pending = None
            continue
        m = re.match(r'^([A-Za-z ]+):\s*(.*)$', t)
        if m and m.group(2):
            hero[m.group(1).strip().lower()] = m.group(2).strip()
        elif m:
            pending = m.group(1).strip().lower()
    book['title'] = hero.get('book title') or hero.get('title') or ''
    book['author'] = hero.get('author') or hero.get('authors') or ''
    rt = hero.get('reading time', '')
    book['minutes'] = int(re.search(r'\d+', rt).group(0)) if re.search(r'\d+', rt) else 7
    book['recommended'] = [x.strip() for x in re.split(r'\s*·\s*', hero.get('recommended for', '')) if x.strip()]
    book['themes'] = [x.strip() for x in re.split(r'\s*·\s*', hero.get('primary themes', '')) if x.strip()]

    book['about'] = ' '.join(t for k, t in sec.get('about', []) if k != 'tr')
    intro, others, want_others = [], [], False
    for k, t in sec.get('author', []):
        if want_others:  # "Other notable books:" in bold, the list on the next line
            others = [x.strip(' .') for x in re.split(r'[;·]', t) if x.strip(' .')]
            want_others = False
        elif t.lower().startswith('other notable books'):
            rest = t.split(':', 1)[1] if ':' in t else ''
            others = [x.strip(' .') for x in re.split(r'[;·]', rest) if x.strip(' .')]
            want_others = not others
        else:
            line = re.sub(r'^one-line introduction:\s*', '', t, flags=re.I)
            if line:
                intro.append(line)
    book['author_intro'] = ' '.join(intro)
    book['other_books'] = others
    book['philosophy'] = ' '.join(t for k, t in sec.get('philosophy', []))

    # Ideas: a numbered or heading title, a body, pointers.
    ideas, idea = [], None
    for k, t in sec.get('ideas', []):
        if re.fullmatch(r'\(tap .*\)', t, re.I):
            continue
        m = re.match(r'^(\d+)\.\s+(.+)$', t)
        if m and k != 'li':
            idea = {'title': m.group(2).strip(), 'body': '', 'points': []}
            ideas.append(idea)
            continue
        if idea is None:
            raise DocError(f'{fname} / {name}: idea text before an idea title: {t[:60]!r}')
        if k == 'li' or t.startswith('•'):
            idea['points'] += bullets(t)
        elif not idea['body']:
            idea['body'] = t
        else:
            idea['points'] += bullets(t) if '•' in t else [t]
    book['ideas'] = ideas

    # Chapters: title, summary, "Read More" points.
    chapters, ch = [], None
    chap_lines = sec.get('chapters', [])
    # A book whose chapters are numbered ("Part 3", "Chapter 2") opens a new
    # chapter only on such a line; anything else after "Read More" is a point
    # (Ayurvedic Garbha Sanskar writes its sub-points as "First trimester: …").
    numbered = any(re.match(r'^(Part|Chapter)\s+\d+', t) for k, t in chap_lines if k != 'tr')
    for k, t in chap_lines:
        if numbered and ch is not None and ch.get('in_points') and k != 'li' \
                and not re.match(r'^(Part|Chapter)\s+\d+', t) and not re.match(r'^read more', t, re.I):
            ch['points'].append(t)
            continue
        rm = re.match(r'^read more(?:\s*\([^)]*\))?\s*:?\s*(.*)$', t, re.I)
        if rm:
            if ch is None:
                raise DocError(f'{fname} / {name}: "Read More" before a chapter')
            if rm.group(1):
                ch['points'] += bullets(rm.group(1))
            ch['in_points'] = True
            continue
        if k == 'li' or t.startswith('•'):
            if ch is None:
                raise DocError(f'{fname} / {name}: chapter point before a chapter: {t[:60]!r}')
            ch['points'] += bullets(t)
            continue
        if ch is None or ch.get('in_points') or (ch['summary'] and k == 'h'):
            title, summary = t, ''
            glued = split_title(t)
            if glued is None and len(t) > 90:
                # Last resort: a Title Case title, then prose ("…The Foundation The opening anchor…").
                after = t.split('—', 1)
                if len(after) == 2:
                    sp = split_title_case(after[1].strip())
                    glued = (f'{after[0].strip()} — {sp[0]}', sp[1]) if sp else None
            if glued and (len(t) > 90 or k == 'h'):
                title, summary = glued
            ch = {'title': title, 'summary': summary, 'points': []}
            chapters.append(ch)
        elif not ch['summary']:
            ch['summary'] = t
        else:
            ch['summary'] += ' ' + t
    for c in chapters:
        c.pop('in_points', None)
    book['chapters'] = chapters

    # The take: ❤️ / ⚠️ pointers, or one paragraph.
    take = ' '.join(t for k, t in sec.get('take', []))
    points = []
    for mk, txt in re.findall(r'(❤️|❤|⚠️|⚠)\s*([^❤⚠]+)', take):
        points.append(('good' if mk.startswith('❤') else 'care', txt.strip().rstrip('️').strip()))
    book['take_points'] = points
    book['take'] = '' if points else take

    # Quotes: quoted lines only; a note about quotes is the writers'.
    book['quotes'] = [t for k, t in sec.get('quotes', []) if t[:1] in '"“‘\'']

    if 'addendum' in sec:
        body, pts = [], []
        for k, t in sec['addendum']:
            (pts.extend(bullets(t)) if (k == 'li' or t.startswith('•')) else body.append(t))
        book['addendum'] = (sec['addendum_title'], ' '.join(body), pts)

    for f in ('title', 'author', 'about', 'philosophy'):
        if not book[f]:
            raise DocError(f'{fname} / {name}: no {f}')
    if len(ideas) < 3:
        raise DocError(f'{fname} / {name}: {len(ideas)} ideas')
    if len(chapters) < 2:
        raise DocError(f'{fname} / {name}: {len(chapters)} chapters')
    if not (book['take'] or book['take_points']):
        raise DocError(f'{fname} / {name}: no ParentVeda take')
    for i in ideas:
        if not i['body']:
            raise DocError(f'{fname} / {name}: idea "{i["title"]}" has no body')
    return book


def slug(t):
    t = re.split(r'[:(]', t)[0]
    return re.sub(r'[^a-z0-9]+', '_', t.lower()).strip('_')[:40]


# ---- Dart ------------------------------------------------------------------------------

def q(s):
    s = s.replace('\\', '\\\\').replace("'", "\\'").replace('$', '\\$')
    return f"'{s}'"


def ql(items, ind):
    if not items:
        return '[]'  # already a const context
    pad = ' ' * ind
    return '[\n' + ''.join(f'{pad}  {q(x)},\n' for x in items) + f'{pad}]'


def dart(b, var):
    L = ['// GENERATED by tools/book_companions/docx_to_dart.py - do not edit by hand.',
         f"// Source: {b['file']}", '', "import '../book_companions.dart';", '',
         f'const BookDoc {var} = BookDoc(',
         f"  id: {q('book_' + b['slug'])},", f"  title: {q(b['title'])},", f"  author: {q(b['author'])},",
         f"  minutes: {b['minutes']},", f"  recommendedFor: {ql(b['recommended'], 2)},",
         f"  themes: {ql(b['themes'], 2)},", f"  about: {q(b['about'])},",
         f"  authorIntro: {q(b['author_intro'])},", f"  otherBooks: {ql(b['other_books'], 2)},",
         f"  philosophy: {q(b['philosophy'])},", '  ideas: [']
    for i in b['ideas']:
        L.append(f"    BookDocIdea({q(i['title'])}, {q(i['body'])}, {ql(i['points'], 4)}),")
    L.append('  ],')
    L.append('  chapters: [')
    for c in b['chapters']:
        L.append(f"    BookDocChapter({q(c['title'])}, {q(c['summary'])}, {ql(c['points'], 4)}),")
    L.append('  ],')
    L.append(f"  take: {q(b['take'])},")
    L.append('  takePoints: [')
    for kind, t in b['take_points']:
        L.append(f"    BookDocTakePoint({'true' if kind == 'good' else 'false'}, {q(t)}),")
    L.append('  ],')
    L.append(f"  quotes: {ql(b['quotes'], 2)},")
    if 'addendum' in b:
        t, body, pts = b['addendum']
        L.append(f'  addendumTitle: {q(t)},')
        L.append(f'  addendumBody: {q(body)},')
        L.append(f'  addendumPoints: {ql(pts, 2)},')
    L.append(');')
    return '\n'.join(L) + '\n'


def main():
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    folder = sys.argv[1]
    books, errors, left_out = [], [], []
    for f in sorted(os.listdir(folder)):
        path = os.path.join(folder, f)
        try:
            if f.lower().endswith('.docx'):
                lines = read_docx(path)
            elif f.lower().endswith('.pdf'):
                lines = read_pdf(path)
            else:
                continue
            for name, blines in books_in(lines, f):
                books.append(parse_book(name or f, blines if name else lines, f))
        except DocError as e:
            (left_out if f.lower().endswith('.pdf') else errors).append(str(e))
    if errors:
        sys.exit('Stopped, nothing written:\n  ' + '\n  '.join(errors))
    seen = {}
    for b in books:
        b['slug'] = slug(b['title'])
        if b['slug'] in seen:
            sys.exit(f'Stopped: "{b["title"]}" appears twice ({seen[b["slug"]]} and {b["file"]})')
        seen[b['slug']] = b['file']
    os.makedirs(OUT, exist_ok=True)
    for old in os.listdir(OUT):
        if old.endswith('.dart'):
            os.remove(os.path.join(OUT, old))
    names = []
    for b in sorted(books, key=lambda b: b['slug']):
        var = 'kBook' + ''.join(w[:1].upper() + w[1:] for w in b['slug'].split('_'))
        with open(os.path.join(OUT, f"{b['slug']}.dart"), 'w', encoding='utf-8', newline='\n') as fh:
            fh.write(dart(b, var))
        names.append((b['slug'], var))
    idx = ['// GENERATED by tools/book_companions/docx_to_dart.py - do not edit by hand.', '']
    idx += [f"import '{s}.dart';" for s, _ in names]
    idx += ["import '../book_companions.dart';", '', '/// Every book companion, by id.',
            'const List<BookDoc> kBookDocList = [']
    idx += [f'  {v},' for _, v in names]
    idx += ['];', '']
    with open(os.path.join(OUT, 'index.dart'), 'w', encoding='utf-8', newline='\n') as fh:
        fh.write('\n'.join(idx))
    print(f'Wrote {len(books)} books')
    for b in sorted(books, key=lambda b: b['slug']):
        print(f"  {b['slug']:42} ideas {len(b['ideas'])} ch {len(b['chapters'])} take {len(b['take_points']) or 'para'} "
              f"q {len(b['quotes'])} add {'Y' if 'addendum' in b else '-'}")
    for e in left_out + MISSING:
        print('LEFT OUT:', e)


if __name__ == '__main__':
    main()
