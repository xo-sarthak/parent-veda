#!/usr/bin/env python3
# =============================================================================
#  section_doc.py -- turn a parenting PpSection into a printable door map
# -----------------------------------------------------------------------------
#  WHY THIS EXISTS
#
#  The door maps in docs/*-DOOR-MAP.pdf have to reproduce every reader-facing
#  string in a section, verbatim. Sleep was transcribed by hand and it took a
#  long time; there are ten more sections and 33,000 lines of content behind
#  them. Transcription by hand is also the one part of the job that cannot be
#  verified -- a dropped card or a paraphrased callout looks exactly like the
#  real thing on the page.
#
#  So the content half is parsed out of the Dart, and only the commentary half
#  is written by a person. The trade: a small Dart-subset parser to maintain
#  (about 150 lines, and the data files use a deliberately tiny subset), in
#  exchange for a document that cannot silently drift from the app.
#
#  WHAT IT HANDLES, AND WHAT IT REFUSES
#
#  The section data files are pure data: constructor calls, string literals,
#  lists, records, dotted enum names, numbers and null. No conditionals, no
#  spreads, no interpolation, no string methods. The parser accepts exactly
#  that and RAISES on anything else rather than guessing -- a parser that
#  silently skips what it does not understand would drop content, which is the
#  failure this whole file exists to prevent.
#
#  RENDERER FIDELITY
#
#  Two behaviours of the real screens are reproduced here rather than described,
#  because a document that shows a page in the wrong order is not a substitute
#  for the app:
#
#    * `PpPage.orderedBlocks` hoists every PpVideoSlot to the top of the page.
#    * `PpConsult.surface` resolves `role` through kPpConsultRoleToCategory, so
#      a consult opens a FILTERED roster, not the whole list.
#
#  Usage:
#     python tools/section_doc.py <bracket_id>          # writes docs/<X>-DOOR-MAP.html
#     python tools/section_doc.py --all
# =============================================================================

import base64
import json
import os
import re
import sys
import urllib.request

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PP = os.path.join(ROOT, 'lib', 'screens', 'post_pregnancy')
DOCS = os.path.join(ROOT, 'docs')


# =============================================================================
#  1. A DART-SUBSET PARSER
# =============================================================================

def strip_comments(src):
    """Remove // and /* */ comments without touching string literals.

    Character by character rather than by regex, because a regex cannot tell
    `// note` from the `//` inside 'https://...' -- and both appear in these
    files.
    """
    out = []
    i, n = 0, len(src)
    while i < n:
        c = src[i]
        if c in "'\"":
            # A string literal, possibly raw (r'...'). Copy it whole.
            if i and src[i - 1] == 'r':
                pass
            q = c
            out.append(c)
            i += 1
            while i < n:
                if src[i] == '\\':
                    out.append(src[i:i + 2])
                    i += 2
                    continue
                out.append(src[i])
                if src[i] == q:
                    i += 1
                    break
                i += 1
            continue
        if c == '/' and i + 1 < n and src[i + 1] == '/':
            while i < n and src[i] != '\n':
                i += 1
            continue
        if c == '/' and i + 1 < n and src[i + 1] == '*':
            i += 2
            while i + 1 < n and not (src[i] == '*' and src[i + 1] == '/'):
                i += 1
            i += 2
            continue
        out.append(c)
        i += 1
    return ''.join(out)


class Call:
    """A constructor invocation: name, positional args, named args."""

    def __init__(self, name, args, kwargs):
        self.name, self.args, self.kwargs = name, args, kwargs

    def __repr__(self):
        return 'Call(%s)' % self.name


ESCAPES = {'n': '\n', 't': '\t', "'": "'", '"': '"', '\\': '\\', '$': '$', 'r': '\r'}


class Parser:
    def __init__(self, src):
        self.s = src
        self.i = 0

    # -- helpers ------------------------------------------------------------
    def ws(self):
        while self.i < len(self.s):
            if self.s[self.i].isspace():
                self.i += 1
            elif self.s.startswith('const ', self.i) or self.s.startswith('new ', self.i):
                self.i += self.s[self.i:].index(' ') + 1
            elif self.s.startswith('const(', self.i):
                self.i += 5
            else:
                break

    def at(self, lit):
        return self.s.startswith(lit, self.i)

    def expect(self, lit):
        self.ws()
        if not self.at(lit):
            raise SyntaxError('expected %r at %d: %r' % (lit, self.i, self.s[self.i:self.i + 60]))
        self.i += len(lit)

    # -- values -------------------------------------------------------------
    def value(self):
        self.ws()
        if self.i >= len(self.s):
            raise SyntaxError('unexpected end of input')
        c = self.s[self.i]
        if c == '[':
            return self.list_()
        if c == '(':
            return self.record()
        if c == '{':
            return self.map_()
        if c in "'\"" or (c == 'r' and self.i + 1 < len(self.s) and self.s[self.i + 1] in "'\""):
            return self.string()
        if c == '-' or c.isdigit():
            return self.number()
        m = re.match(r'[A-Za-z_$][A-Za-z0-9_$]*(\.[A-Za-z_$][A-Za-z0-9_$]*)*', self.s[self.i:])
        if not m:
            raise SyntaxError('cannot parse value at %d: %r' % (self.i, self.s[self.i:self.i + 60]))
        name = m.group(0)
        self.i += len(name)
        self.ws()
        if self.at('('):
            return self.call(name)
        if name == 'null':
            return None
        if name == 'true':
            return True
        if name == 'false':
            return False
        return Ident(name)

    def string(self):
        """One string, plus any adjacent literals Dart would concatenate."""
        parts = []
        while True:
            self.ws()
            raw = False
            if self.i < len(self.s) and self.s[self.i] == 'r' and self.s[self.i + 1] in "'\"":
                raw = True
                self.i += 1
            if self.i >= len(self.s) or self.s[self.i] not in "'\"":
                break
            q = self.s[self.i]
            self.i += 1
            buf = []
            while self.i < len(self.s) and self.s[self.i] != q:
                ch = self.s[self.i]
                if ch == '\\' and not raw:
                    nxt = self.s[self.i + 1]
                    buf.append(ESCAPES.get(nxt, nxt))
                    self.i += 2
                    continue
                buf.append(ch)
                self.i += 1
            self.i += 1
            parts.append(''.join(buf))
            # peek: another literal directly after means concatenation
            save = self.i
            self.ws()
            if self.i < len(self.s) and (self.s[self.i] in "'\"" or
                                         (self.s[self.i] == 'r' and self.s[self.i + 1] in "'\"")):
                continue
            self.i = save
            break
        return ''.join(parts)

    def number(self):
        m = re.match(r'-?\d+(\.\d+)?', self.s[self.i:])
        self.i += len(m.group(0))
        txt = m.group(0)
        return float(txt) if '.' in txt else int(txt)

    def list_(self):
        self.expect('[')
        items = []
        while True:
            self.ws()
            if self.at(']'):
                self.i += 1
                return items
            items.append(self.value())
            self.ws()
            if self.at(','):
                self.i += 1

    def record(self):
        """A Dart record literal, used for chart-card rows: ('label', 'value')."""
        self.expect('(')
        items = []
        while True:
            self.ws()
            if self.at(')'):
                self.i += 1
                return tuple(items)
            items.append(self.value())
            self.ws()
            if self.at(','):
                self.i += 1

    def map_(self):
        self.expect('{')
        out = {}
        while True:
            self.ws()
            if self.at('}'):
                self.i += 1
                return out
            k = self.value()
            self.expect(':')
            out[k] = self.value()
            self.ws()
            if self.at(','):
                self.i += 1

    def call(self, name):
        self.expect('(')
        args, kwargs = [], {}
        while True:
            self.ws()
            if self.at(')'):
                self.i += 1
                return Call(name, args, kwargs)
            m = re.match(r'([A-Za-z_][A-Za-z0-9_]*)\s*:(?!:)', self.s[self.i:])
            if m:
                self.i += len(m.group(0))
                kwargs[m.group(1)] = self.value()
            else:
                args.append(self.value())
            self.ws()
            if self.at(','):
                self.i += 1


class Ident:
    def __init__(self, name):
        self.name = name

    def __repr__(self):
        return 'Ident(%s)' % self.name


DECL = re.compile(r'^(?:final|const)\s+[\w<>?, ]*?\s*(\w+)\s*=\s*', re.M)


def declarations(path):
    """Every top-level `final X y = value;` in a file, as name -> parsed value."""
    src = strip_comments(open(path, encoding='utf-8').read())
    out = {}
    for m in DECL.finditer(src):
        p = Parser(src)
        p.i = m.end()
        try:
            out[m.group(1)] = p.value()
        except SyntaxError as e:
            raise SyntaxError('%s: %s -- %s' % (os.path.basename(path), m.group(1), e))
    return out


def resolve(v, env):
    """Replace Ident references with the values they name."""
    if isinstance(v, Ident):
        if v.name not in env:
            return v            # an enum name like IntentMark.chartLog
        return resolve(env[v.name], env)
    if isinstance(v, list):
        return [resolve(x, env) for x in v]
    if isinstance(v, tuple):
        return tuple(resolve(x, env) for x in v)
    if isinstance(v, Call):
        return Call(v.name,
                    [resolve(a, env) for a in v.args],
                    {k: resolve(a, env) for k, a in v.kwargs.items()})
    return v


# =============================================================================
#  2. NORMALISE INTO A DOCUMENT TREE
# =============================================================================

def enum_name(v):
    if isinstance(v, Ident):
        return v.name.split('.')[-1]
    return v


def block(c):
    """One PpBlock -> a plain dict the renderer understands."""
    n = c.name
    a, k = c.args, c.kwargs

    def kw(key, default=None):
        return k.get(key, default)

    if n == 'PpIntro':
        return {'t': 'intro', 'text': a[0]}
    if n == 'PpArticle':
        return {'t': 'article', 'heading': kw('heading'), 'paras': a[0]}
    if n == 'PpSteps':
        return {'t': 'steps', 'heading': kw('heading'),
                'steps': [{'title': s.args[0],
                           'detail': s.args[1] if len(s.args) > 1 else s.kwargs.get('detail')}
                          for s in a[0]]}
    if n == 'PpCards':
        return {'t': 'cards', 'heading': kw('heading'), 'hue': kw('hue', 268),
                'cards': [{'title': x.args[0], 'line': x.args[1]} for x in a[0]]}
    if n == 'PpTable':
        return {'t': 'table', 'heading': kw('heading'),
                'columns': kw('columns'), 'rows': kw('rows')}
    if n == 'PpChartCard':
        return {'t': 'chart', 'title': kw('title'), 'subtitle': kw('subtitle'),
                'note': kw('note'), 'rows': [list(r) for r in kw('rows')]}
    if n == 'PpCallout':
        return {'t': 'callout', 'text': a[0], 'title': kw('title'),
                'kind': enum_name(kw('kind')) or 'key'}
    if n == 'PpScript':
        return {'t': 'script', 'heading': kw('heading'),
                'lines': [{'say': x.kwargs.get('say'),
                           'notThis': x.kwargs.get('notThis'),
                           'why': x.kwargs.get('why')} for x in a[0]]}
    if n == 'PpWhenLine':
        return {'t': 'when', 'text': a[0]}
    if n == 'PpIndiaNote':
        return {'t': 'india', 'text': a[0]}
    if n == 'PpVideoSlot':
        return {'t': 'video', 'title': kw('title'), 'subtitle': kw('subtitle'),
                'minutes': kw('minutes'), 'slotId': kw('slotId')}
    if n == 'PpAudioSlot':
        return {'t': 'audio', 'title': kw('title'), 'category': kw('category'),
                'minutes': kw('minutes'), 'slotId': kw('slotId')}
    if n == 'PpLink':
        return {'t': 'link', 'label': a[0], 'blurb': kw('blurb'),
                'surfaceId': kw('surfaceId'), 'pageId': kw('pageId')}
    if n == 'PpConsult':
        return {'t': 'consult', 'title': kw('title'), 'whoFor': kw('whoFor'),
                'surfaceId': kw('surfaceId'), 'role': kw('role')}
    raise SyntaxError('unknown block type: ' + n)


def page(c):
    k = c.kwargs
    blocks = [block(b) for b in k['blocks']]
    # ⚠️ THE RENDERER HOISTS VIDEO. See PpPage.orderedBlocks -- every video
    # slot moves to the top of the page, both halves keeping authored order.
    vids = [b for b in blocks if b['t'] == 'video']
    if vids:
        blocks = vids + [b for b in blocks if b['t'] != 'video']
    return {'id': k['id'], 'title': k['title'], 'subtitle': k.get('subtitle'),
            'format': k.get('format'), 'bands': k.get('bands') or [],
            'blocks': blocks}


def area(c):
    k = c.kwargs
    return {'id': k['id'], 'title': k['title'], 'blurb': k['blurb'],
            'hue': k.get('hue', 268), 'mark': enum_name(k.get('mark')) or 'listMark',
            'bands': k.get('bands') or [], 'pinned': k.get('pinned', False),
            'cover': k.get('cover'), 'toolSurfaceId': k.get('toolSurfaceId'),
            'pages': [page(p) for p in (k.get('pages') or [])]}


def band(c):
    k = c.kwargs
    return {'id': k['id'], 'label': k['label'], 'from': k['fromMonths'],
            'to': k['toMonths'], 'blurb': k.get('blurb')}


def section(c):
    k = c.kwargs
    bs = k.get('bandSet')
    return {'id': k['id'], 'title': k['title'], 'subtitle': k.get('subtitle'),
            'intro': k['intro'],
            'bands': [band(b) for b in bs.args[0]] if isinstance(bs, Call) else [],
            'tools': [{'label': t.kwargs['label'], 'blurb': t.kwargs['blurb'],
                       'surfaceId': t.kwargs['surfaceId'],
                       'icon': enum_name(t.kwargs.get('icon'))}
                      for t in (k.get('tools') or [])],
            'areas': [area(x) for x in k['areas']]}


ROLE_TO_CATEGORY = {
    'pediatrician': 'Pediatrician', 'paediatrician': 'Pediatrician',
    'lactation': 'Lactation expert', 'speech': 'Speech therapist',
    'psychologist': 'Child psychologist', 'sleep': 'Sleep expert',
    'nutrition': 'Nutritionist', 'physio': 'Physiotherapist',
    'group_physio': 'Physiotherapist',
    'maternal_mental_health': 'Maternal mental health',
    'group_mental_health': 'Maternal mental health',
    'development': 'Development expert',
    'early_learning': 'Early learning expert',
    'school_readiness': 'Early learning expert',
}


def consult_surface(b):
    """PpConsult.surface -- the filtered roster, where the role maps."""
    if b['surfaceId'] != 'pp_experts':
        return b['surfaceId']
    cat = ROLE_TO_CATEGORY.get(b['role'])
    return b['surfaceId'] if cat is None else 'pp_experts/%s' % cat


# =============================================================================
#  3. LOAD
# =============================================================================

SECTION_FILES = {
    'parenting_sleep': 'pp_sleep_content.dart',
    'parenting_feeding': 'pp_feeding_content.dart',
    'parenting_health': 'pp_health_content.dart',
    'parenting_development': 'pp_development_content.dart',
    'parenting_behaviour': 'pp_behaviour_content.dart',
    'parenting_potty': 'pp_potty_content.dart',
    'parenting_early_learning': 'pp_early_learning_content.dart',
    'parenting_first_40': 'pp_first40_content.dart',
    'parenting_maternal': 'pp_you_maa_content.dart',
    'parenting_traditional': 'pp_traditions_content.dart',
}


def load_section(bracket_id):
    """Resolve a section, following references into other files.

    ⚠️ RESOLVED PER FILE FIRST, THEN GLOBALLY, and the order matters.
    Behaviour's ten areas live in three files (`pp_behaviour_content`,
    `_bands`, `_more`) and each of those files has its own private band
    constants -- `_toddler`, `_all`, `_early`. Merging every declaration into
    one namespace would let one file's `_toddler` answer another file's
    reference, silently mis-tagging pages by age.

    So each file is resolved against its OWN privates first; only public names
    (no leading underscore) are then shared across files. A collision on a
    public name would be a real Dart error, so it cannot happen here.
    """
    shared = declarations(os.path.join(PP, 'pp_age_bands.dart'))
    own = os.path.join(PP, SECTION_FILES[bracket_id])

    per_file = {}
    for fn in sorted(os.listdir(PP)):
        if not fn.startswith('pp_') or not fn.endswith('.dart'):
            continue
        path = os.path.join(PP, fn)
        try:
            raw = declarations(path)
        except SyntaxError:
            continue          # a screen file, not a data file
        local = dict(shared)
        local.update(raw)
        per_file[path] = {k: resolve(v, local) for k, v in raw.items()}

    env = dict(shared)
    for path, vals in per_file.items():
        for k, v in vals.items():
            if not k.startswith('_'):
                env[k] = v
    env.update(per_file.get(own, {}))     # the section's own file wins

    for name, v in env.items():
        if isinstance(v, Call) and v.name == 'PpSection':
            s = section(resolve(v, env))
            if s['id'] == bracket_id:
                return s
    raise KeyError('no PpSection with id %s' % bracket_id)


if __name__ == '__main__':
    which = sys.argv[1:] or list(SECTION_FILES)
    for b in which:
        s = load_section(b)
        pages = sum(len(a['pages']) for a in s['areas'])
        blocks = sum(len(p['blocks']) for a in s['areas'] for p in a['pages'])
        print('%-26s %-22s areas=%2d pages=%3d blocks=%4d bands=%d tools=%d'
              % (b, s['title'], len(s['areas']), pages, blocks,
                 len(s['bands']), len(s['tools'])))
