"""Shared scanner for `_p(english, hindi)` call sites in Dart source.

Why a scanner and not a regex: the second argument may contain commas, nested
parens, escaped quotes and `${...}` interpolation. A regex that splits on the
first comma corrupts roughly one call in twenty, silently, and the analyzer
does not notice because the result is still valid Dart.

The identity of a call is its ORDINAL POSITION in the file (0-based). That is
stable across a translation pass, which only ever rewrites argument text, and
it survives the length changes that make line numbers useless.
"""

import re

PLACEHOLDER = re.compile(r'\$\{[^}]*\}|\$\w+')


def placeholders(text):
    """The set of interpolations a string carries. Must survive translation."""
    return sorted(PLACEHOLDER.findall(text))


def _scan_args(src, open_paren):
    """Given the index of '(' return (arg_spans, close_paren_index).

    arg_spans are (start, end) offsets of each top-level argument.
    """
    i = open_paren + 1
    depth = 1              # paren/brace nesting inside the call
    stack = []             # string-quote chars we are currently inside
    args, start = [], i
    n = len(src)
    while i < n:
        c = src[i]
        if stack:                                  # inside a string literal
            if c == '\\':
                i += 2
                continue
            if c == '$' and i + 1 < n and src[i + 1] == '{':
                stack.append(None)                 # None = interpolation code
                i += 2
                continue
            if c == '}' and stack[-1] is None:
                stack.pop()
                i += 1
                continue
            if stack[-1] is not None and c == stack[-1]:
                stack.pop()
                i += 1
                continue
            if stack[-1] is None and c in "'\"":   # string inside ${...}
                stack.append(c)
                i += 1
                continue
            i += 1
            continue
        if c in "'\"":
            stack.append(c)
        elif c in '([{':
            depth += 1
        elif c in ')]}':
            depth -= 1
            if depth == 0:
                args.append((start, i))
                return args, i
        elif c == ',' and depth == 1:
            args.append((start, i))
            start = i + 1
        i += 1
    raise ValueError(f'unterminated _p( at offset {open_paren}')


def find_calls(src, marker='_p('):
    """Every `_p(...)` call in file order.

    Each entry: dict(idx, en_span, hi_span, en_src, hi_src, simple, text_en,
    text_hi). `simple` means the argument is exactly one quoted literal and can
    therefore be rewritten mechanically; anything else (ternary, concatenation,
    identifier) is flagged for hand editing.
    """
    out, idx, pos = [], 0, 0
    while True:
        m = src.find(marker, pos)
        if m < 0:
            return out
        # skip the declaration itself: `T _p<T>(T en, T hi) => ...`
        line_start = src.rfind('\n', 0, m) + 1
        line = src[line_start:src.find('\n', m)]
        if 'T en, T hi' in line or 'String en, String hi' in line:
            pos = m + len(marker)
            continue
        op = m + len(marker) - 1
        try:
            spans, close = _scan_args(src, op)
        except ValueError:
            pos = m + len(marker)
            continue
        if len(spans) != 2:
            pos = close + 1
            continue
        (a0, a1), (b0, b1) = spans
        en_src, hi_src = src[a0:a1].strip(), src[b0:b1].strip()
        rec = dict(
            idx=idx,
            en_span=(a0, a1), hi_span=(b0, b1),
            en_src=en_src, hi_src=hi_src,
            simple=_is_literal(hi_src) and _is_literal(en_src),
            text_en=_literal_value(en_src),
            text_hi=_literal_value(hi_src),
        )
        out.append(rec)
        idx += 1
        pos = close + 1


def find_localized(src, ctor='LocalizedText('):
    """Every `LocalizedText(en: '…', hi: '…')` in file order.

    Same contract as find_calls: ordinal index is the identity, and `simple`
    means the hi value is one plain literal that can be rewritten mechanically.
    Named arguments may appear in either order, so both are matched by label
    rather than by position.
    """
    out, idx, pos = [], 0, 0
    while True:
        m = src.find(ctor, pos)
        if m < 0:
            return out
        op = m + len(ctor) - 1
        try:
            spans, close = _scan_args(src, op)
        except ValueError:
            pos = m + len(ctor)
            continue
        named = {}
        for a, b in spans:
            frag = src[a:b]
            lbl = frag.lstrip()[:3]
            if lbl.startswith('en:'):
                off = frag.index('en:') + 3
                named['en'] = (a + off, b)
            elif lbl.startswith('hi:'):
                off = frag.index('hi:') + 3
                named['hi'] = (a + off, b)
        if 'en' in named and 'hi' in named:
            en_src = src[named['en'][0]:named['en'][1]].strip()
            hi_src = src[named['hi'][0]:named['hi'][1]].strip()
            out.append(dict(
                idx=idx,
                en_span=named['en'], hi_span=named['hi'],
                en_src=en_src, hi_src=hi_src,
                simple=_is_literal(hi_src) and _is_literal(en_src),
                text_en=_literal_value(en_src),
                text_hi=_literal_value(hi_src),
            ))
            idx += 1
        pos = close + 1


def _is_literal(s):
    """True when s is exactly ONE quoted Dart string literal."""
    if len(s) < 2 or s[0] not in "'\"" or s[-1] != s[0]:
        return False
    q, i, n = s[0], 1, len(s)
    while i < n - 1:
        if s[i] == '\\':
            i += 2
            continue
        if s[i] == q:
            return False          # closed early => concatenation or worse
        i += 1
    return True


_UNESCAPE = {'n': '\n', 't': '\t', 'r': '\r', '\\': '\\', "'": "'", '"': '"',
             '$': '$'}


def _literal_value(s):
    """The text inside a literal, unescaped. None when s is not a literal.

    Single pass, because chained str.replace calls on escapes are order
    dependent: unescaping `\\\\` after `\\n` turns a literal backslash-n into a
    newline.
    """
    if not _is_literal(s):
        return None
    body, out, i, n = s[1:-1], [], 0, len(s) - 2
    while i < n:
        c = body[i]
        if c == '\\' and i + 1 < n:
            nxt = body[i + 1]
            out.append(_UNESCAPE.get(nxt, '\\' + nxt))
            i += 2
            continue
        out.append(c)
        i += 1
    return ''.join(out)


def quote_of(literal_src):
    """The quote character a literal was written with, so a rewrite keeps it."""
    return literal_src[0] if literal_src[:1] in ("'", '"') else "'"


def dart_literal(text, quote="'"):
    """Render text as a Dart literal using `quote`.

    `$` is deliberately NOT escaped: interpolations must stay live, and the
    placeholder guard is what proves the translator kept them. The other quote
    character is left bare — legal Dart, and it keeps the source readable.
    """
    body = (text.replace('\\', '\\\\')
                .replace(quote, '\\' + quote)
                .replace('\n', r'\n')
                .replace('\t', r'\t'))
    return quote + body + quote
