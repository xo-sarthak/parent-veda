#!/usr/bin/env python3
"""Markdown -> PDF converter (reportlab) for the ParentVeda app review docs.

Supports a small markdown subset:
  # Title            -> cover title (first file only)
  _subtitle_         -> cover subtitle (first file only, immediately after title)
  ## Heading         -> section / screen heading (TOC level 0, page break, bookmark)
  ### Heading        -> sub heading (TOC level 1)
  - bullet           -> bullet (two-space indent => sub bullet)
  **bold**  *italic*  `code`
  | a | b |          -> pipe table
  ---                -> horizontal rule
Everything else is a paragraph.

Usage:
  python md2pdf.py --out OUT.pdf --title "T" --subtitle "S" --part "PDF 3 of 7" \
                   --desc "..." in1.md [in2.md ...]
"""
import argparse
import datetime
import html
import os
import re

from reportlab.lib import colors
from reportlab.lib.pagesizes import A4
from reportlab.lib.units import cm
from reportlab.lib.styles import ParagraphStyle
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import (BaseDocTemplate, Frame, HRFlowable, PageBreak,
                                PageTemplate, Paragraph, Spacer, Table,
                                TableStyle)
from reportlab.platypus.tableofcontents import TableOfContents

# ---------------------------------------------------------------------------
# Palette (warm plum / rose, matching the pregnancy app mood)
PLUM = colors.HexColor("#5E4472")
PLUM_DEEP = colors.HexColor("#3F2E50")
ROSE = colors.HexColor("#B65C7E")
INK = colors.HexColor("#2B2530")
GREY = colors.HexColor("#6B6472")
FAINT = colors.HexColor("#9A8FA6")
RULE = colors.HexColor("#E4DCEC")
BAND = colors.HexColor("#F3EEF8")

PAGE_W, PAGE_H = A4
MARGIN = 2.0 * cm


# ---------------------------------------------------------------------------
def register_fonts():
    trials = [
        (r"C:\Windows\Fonts\segoeui.ttf", r"C:\Windows\Fonts\segoeuib.ttf",
         r"C:\Windows\Fonts\segoeuii.ttf", r"C:\Windows\Fonts\segoeuiz.ttf"),
        (r"C:\Windows\Fonts\arial.ttf", r"C:\Windows\Fonts\arialbd.ttf",
         r"C:\Windows\Fonts\ariali.ttf", r"C:\Windows\Fonts\arialbi.ttf"),
    ]
    for reg, bold, ital, boldital in trials:
        if os.path.exists(reg) and os.path.exists(bold):
            pdfmetrics.registerFont(TTFont("Body", reg))
            pdfmetrics.registerFont(TTFont("Body-Bold", bold))
            it = ital if os.path.exists(ital) else reg
            bi = boldital if os.path.exists(boldital) else bold
            pdfmetrics.registerFont(TTFont("Body-Italic", it))
            pdfmetrics.registerFont(TTFont("Body-BoldItalic", bi))
            pdfmetrics.registerFontFamily(
                "Body", normal="Body", bold="Body-Bold",
                italic="Body-Italic", boldItalic="Body-BoldItalic")
            return "Body", "Body-Bold"
    return "Helvetica", "Helvetica-Bold"


BODY, BODY_BOLD = register_fonts()
FOOTER_LEFT = "ParentVeda - Pregnancy App"

# ---------------------------------------------------------------------------
styles = {
    "cover_title": ParagraphStyle("cover_title", fontName=BODY_BOLD, fontSize=30,
                                  leading=36, textColor=PLUM_DEEP),
    "cover_sub": ParagraphStyle("cover_sub", fontName=BODY, fontSize=14,
                                leading=20, textColor=ROSE, spaceBefore=10),
    "cover_part": ParagraphStyle("cover_part", fontName=BODY_BOLD, fontSize=11,
                                 leading=16, textColor=FAINT, spaceBefore=26),
    "cover_desc": ParagraphStyle("cover_desc", fontName=BODY, fontSize=10.5,
                                 leading=16, textColor=GREY, spaceBefore=10),
    "cover_meta": ParagraphStyle("cover_meta", fontName=BODY, fontSize=9,
                                 leading=13, textColor=FAINT),
    "toc_title": ParagraphStyle("toc_title", fontName=BODY_BOLD, fontSize=18,
                                leading=22, textColor=PLUM_DEEP, spaceAfter=12),
    "h2": ParagraphStyle("h2", fontName=BODY_BOLD, fontSize=16, leading=20,
                         textColor=PLUM, spaceBefore=4, spaceAfter=8),
    "h3": ParagraphStyle("h3", fontName=BODY_BOLD, fontSize=12, leading=16,
                         textColor=PLUM_DEEP, spaceBefore=10, spaceAfter=4),
    "body": ParagraphStyle("body", fontName=BODY, fontSize=10, leading=15,
                           textColor=INK, spaceAfter=6),
    "bullet1": ParagraphStyle("bullet1", fontName=BODY, fontSize=10, leading=15,
                              textColor=INK, leftIndent=16, bulletIndent=4,
                              spaceAfter=3),
    "bullet2": ParagraphStyle("bullet2", fontName=BODY, fontSize=10, leading=15,
                              textColor=INK, leftIndent=32, bulletIndent=20,
                              spaceAfter=2),
    "cell": ParagraphStyle("cell", fontName=BODY, fontSize=9, leading=12,
                           textColor=INK),
    "cellh": ParagraphStyle("cellh", fontName=BODY_BOLD, fontSize=9, leading=12,
                            textColor=colors.white),
}
_toc_l0 = ParagraphStyle("toc0", fontName=BODY_BOLD, fontSize=10.5, leading=17,
                         textColor=PLUM_DEEP, leftIndent=0)
_toc_l1 = ParagraphStyle("toc1", fontName=BODY, fontSize=9.5, leading=15,
                         textColor=GREY, leftIndent=18)


# ---------------------------------------------------------------------------
def sanitize(s):
    repl = {
        "—": "-", "–": "-", "‘": "'", "’": "'",
        "“": '"', "”": '"', "…": "...", "→": "->",
        "←": "<-", "✓": "(done)", "✔": "(done)",
        "★": "*", "☆": "*", "♥": "(heart)", " ": " ",
        "•": "-",
    }
    for k, v in repl.items():
        s = s.replace(k, v)
    return s


def inline(text):
    """Convert a small markdown inline subset to reportlab mini-html."""
    text = html.escape(text, quote=False)
    text = re.sub(r"`([^`]+)`",
                  r'<font face="Courier" size="9">\1</font>', text)
    text = re.sub(r"\*\*([^*]+)\*\*", r"<b>\1</b>", text)
    text = re.sub(r"(?<!\*)\*([^*\s][^*]*?)\*(?!\*)", r"<i>\1</i>", text)
    return text


def plain(text):
    text = re.sub(r"`([^`]+)`", r"\1", text)
    text = re.sub(r"\*\*([^*]+)\*\*", r"\1", text)
    text = re.sub(r"(?<!\*)\*([^*]+)\*(?!\*)", r"\1", text)
    return text


# ---------------------------------------------------------------------------
class DocTemplate(BaseDocTemplate):
    def __init__(self, filename, **kw):
        super().__init__(filename, **kw)
        frame = Frame(MARGIN, MARGIN, PAGE_W - 2 * MARGIN,
                      PAGE_H - 2 * MARGIN, id="main")
        self.addPageTemplates([PageTemplate(id="main", frames=[frame],
                                            onPage=_footer)])
        self._seq = 0

    def beforeDocument(self):
        # Reset per build pass so TOC keys are deterministic and converge.
        self._seq = 0

    def afterFlowable(self, flowable):
        lvl = getattr(flowable, "_toc_level", None)
        if lvl is None:
            return
        text = getattr(flowable, "_toc_text", flowable.getPlainText())
        key = "sec-%d" % self._seq
        self._seq += 1
        self.canv.bookmarkPage(key)
        self.canv.addOutlineEntry(text, key, level=lvl, closed=(lvl > 0))
        self.notify("TOCEntry", (lvl, text, self.page, key))


def _footer(canvas, doc):
    canvas.saveState()
    if doc.page > 1:
        canvas.setFont(BODY, 8)
        canvas.setFillColor(FAINT)
        canvas.drawString(MARGIN, 1.15 * cm, FOOTER_LEFT)
        canvas.drawRightString(PAGE_W - MARGIN, 1.15 * cm, "Page %d" % doc.page)
        canvas.setStrokeColor(RULE)
        canvas.setLineWidth(0.5)
        canvas.line(MARGIN, 1.5 * cm, PAGE_W - MARGIN, 1.5 * cm)
    canvas.restoreState()


# ---------------------------------------------------------------------------
def strip_cover_lines(lines):
    """Pull a leading '# title' and following '_subtitle_' off the top."""
    title = subtitle = None
    out = list(lines)
    while out and out[0].strip() == "":
        out.pop(0)
    if out and out[0].startswith("# "):
        title = out.pop(0)[2:].strip()
        while out and out[0].strip() == "":
            out.pop(0)
        if out and re.match(r"^_.*_$", out[0].strip()):
            subtitle = out.pop(0).strip().strip("_").strip()
    return title, subtitle, out


def parse_table(block):
    rows = []
    for ln in block:
        cells = [c.strip() for c in ln.strip().strip("|").split("|")]
        rows.append(cells)
    if len(rows) >= 2 and re.match(r"^:?-{2,}:?$", rows[1][0].replace(" ", "")):
        header = rows[0]
        body = rows[2:]
    else:
        header, body = None, rows
    ncols = max(len(r) for r in rows)
    avail = PAGE_W - 2 * MARGIN
    colw = [avail / ncols] * ncols
    data = []
    if header:
        data.append([Paragraph(inline(c), styles["cellh"]) for c in header]
                    + [Paragraph("", styles["cellh"])] * (ncols - len(header)))
    for r in body:
        data.append([Paragraph(inline(c), styles["cell"]) for c in r]
                    + [Paragraph("", styles["cell"])] * (ncols - len(r)))
    t = Table(data, colWidths=colw, repeatRows=1 if header else 0)
    ts = [
        ("GRID", (0, 0), (-1, -1), 0.5, RULE),
        ("VALIGN", (0, 0), (-1, -1), "TOP"),
        ("LEFTPADDING", (0, 0), (-1, -1), 6),
        ("RIGHTPADDING", (0, 0), (-1, -1), 6),
        ("TOPPADDING", (0, 0), (-1, -1), 4),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 4),
    ]
    if header:
        ts += [("BACKGROUND", (0, 0), (-1, 0), PLUM),
               ("ROWBACKGROUNDS", (0, 1), (-1, -1), [colors.white, BAND])]
    t.setStyle(TableStyle(ts))
    return t


def build_flowables(lines):
    flow = []
    h2_count = [0]

    def heading(text, level):
        style = styles["h2"] if level == 0 else styles["h3"]
        p = Paragraph(inline(text), style)
        p._toc_level = level
        p._toc_text = plain(text)
        return p

    i = 0
    n = len(lines)
    while i < n:
        raw = lines[i].rstrip("\n")
        line = raw.strip()

        if line == "":
            i += 1
            continue

        # tables
        if line.startswith("|") and i + 1 < n and lines[i + 1].strip().startswith("|"):
            block = []
            while i < n and lines[i].strip().startswith("|"):
                block.append(lines[i])
                i += 1
            flow.append(Spacer(1, 2))
            flow.append(parse_table(block))
            flow.append(Spacer(1, 6))
            continue

        if line.startswith("### "):
            flow.append(heading(line[4:].strip(), 1))
            i += 1
            continue
        if line.startswith("## "):
            if h2_count[0] > 0:
                flow.append(PageBreak())
            h2_count[0] += 1
            h = heading(line[3:].strip(), 0)
            flow.append(h)
            flow.append(HRFlowable(width="100%", thickness=1.1, color=RULE,
                                   spaceBefore=1, spaceAfter=8))
            i += 1
            continue
        if line.startswith("# "):
            flow.append(heading(line[2:].strip(), 0))
            i += 1
            continue

        if line == "---" or re.match(r"^-{3,}$", line):
            flow.append(Spacer(1, 2))
            flow.append(HRFlowable(width="100%", thickness=0.6, color=RULE,
                                   spaceBefore=2, spaceAfter=6))
            i += 1
            continue

        m = re.match(r"^(\s*)[-*]\s+(.*)$", raw)
        if m:
            indent = len(m.group(1))
            level = 1 if indent >= 2 else 0
            style = styles["bullet2"] if level else styles["bullet1"]
            bt = "–" if level else "•"
            flow.append(Paragraph(inline(m.group(2).strip()), style,
                                  bulletText=bt))
            i += 1
            continue

        # paragraph (join following non-blank, non-special lines)
        para = [line]
        i += 1
        while i < n:
            nxt = lines[i].strip()
            if (nxt == "" or nxt.startswith("#") or nxt.startswith("- ")
                    or nxt.startswith("* ") or nxt.startswith("|")
                    or re.match(r"^-{3,}$", nxt)):
                break
            para.append(nxt)
            i += 1
        flow.append(Paragraph(inline(" ".join(para)), styles["body"]))

    return flow


# ---------------------------------------------------------------------------
def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", required=True)
    ap.add_argument("--title", default=None)
    ap.add_argument("--subtitle", default=None)
    ap.add_argument("--part", default="")
    ap.add_argument("--desc", default="")
    ap.add_argument("inputs", nargs="+")
    args = ap.parse_args()

    global FOOTER_LEFT

    all_lines = []
    cover_title = args.title
    cover_sub = args.subtitle
    for idx, path in enumerate(args.inputs):
        with open(path, encoding="utf-8") as f:
            raw = [sanitize(x) for x in f.read().splitlines()]
        t, s, body = strip_cover_lines(raw)
        if idx == 0:
            cover_title = cover_title or t
            cover_sub = cover_sub or s
        all_lines.extend(body)
        all_lines.append("")

    cover_title = cover_title or "ParentVeda Pregnancy App"
    if args.part:
        FOOTER_LEFT = "ParentVeda - Pregnancy App  -  " + args.part

    story = []
    # cover
    story.append(Spacer(1, 5 * cm))
    story.append(Paragraph(inline(cover_title), styles["cover_title"]))
    if cover_sub:
        story.append(Paragraph(inline(cover_sub), styles["cover_sub"]))
    story.append(HRFlowable(width="42%", thickness=2, color=ROSE,
                            spaceBefore=18, spaceAfter=2, hAlign="LEFT"))
    if args.part:
        story.append(Paragraph(args.part, styles["cover_part"]))
    if args.desc:
        story.append(Paragraph(inline(args.desc), styles["cover_desc"]))
    story.append(Spacer(1, 1.2 * cm))
    today = datetime.date.today().strftime("%d %B %Y")
    story.append(Paragraph(
        "Feature & Screen Reference for review and testing.<br/>"
        "Generated %s." % today, styles["cover_meta"]))
    story.append(PageBreak())

    # toc
    story.append(Paragraph("Contents", styles["toc_title"]))
    toc = TableOfContents()
    toc.levelStyles = [_toc_l0, _toc_l1]
    toc.dotsMinLevel = 0
    story.append(toc)
    story.append(PageBreak())

    story.extend(build_flowables(all_lines))

    doc = DocTemplate(args.out, pagesize=A4,
                      title=cover_title, author="ParentVeda")
    doc.multiBuild(story)
    print("Wrote", args.out)


if __name__ == "__main__":
    main()
