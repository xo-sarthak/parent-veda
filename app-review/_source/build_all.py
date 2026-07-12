#!/usr/bin/env python3
"""Assemble the 7 ParentVeda pregnancy-app review PDFs from the content md files."""
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
CONTENT = os.path.join(HERE, "content")
OUT = r"C:\Projects\parentveda\app-review"
MD2PDF = os.path.join(HERE, "md2pdf.py")

# (out_filename, title, part, desc, [input md basenames])
PDFS = [
    ("00_Overview_and_Navigation.pdf", "Overview & Navigation", "PDF 1 of 7",
     "How the pregnancy app is structured: the launch flow, the five-tab shell, "
     "profile, search, and where every feature lives. Ends with a cross-app "
     "status cheat-sheet of what is live, mocked, parked, or testing-only.",
     ["00_overview.md", "00z_status_appendix.md"]),
    ("01_Today_and_Weekly_Journey.pdf", "Today & Weekly Journey", "PDF 2 of 7",
     "The daily home (Warm Nest) and the week-by-week pregnancy journey, including "
     "the V2 weekly flow, baby size views, and weekly reads and videos.",
     ["01_today_weekly.md"]),
    ("02_Garbh_Sanskar.pdf", "Garbh Sanskar", "PDF 3 of 7",
     "The prenatal-bonding program: the four live pillars (Shravan, Vichara, "
     "Samvad, Kriya), per-trimester content, and the games and readings.",
     ["02_garbh_sanskar.md"]),
    ("03_Tools_and_Trackers.pdf", "Tools & Trackers", "PDF 4 of 7",
     "Every pregnancy tool: kick counter, weight, kegel, contractions, due-date, "
     "symptoms, medicines, scans, hospital bag, checklists, reminders, the Can-I "
     "safety checker, scan-report help, and the Ask Veda answer engine.",
     ["03a_tools_trackers.md", "03b_tools_planners.md"]),
    ("04_Journal_Keepsakes_and_Journey_Map.pdf",
     "Journal, Keepsakes & Journey Map", "PDF 5 of 7",
     "Memory-keeping features: the journal and writer, combined view and booklet "
     "PDF, the dear-baby vault, the bump journey, and the milestone map.",
     ["04_journal_keepsakes.md"]),
    ("05_Prepare_Community_Calendar_Shop.pdf",
     "Prepare, Community, Calendar & Shop", "PDF 6 of 7",
     "The Prepare commerce tab (masterclasses, consults, cohorts, yoga, birthing "
     "classes), plus the community feed, the calendar, and the product shop.",
     ["05a_prepare.md", "05b_community_calendar_shop.md"]),
    ("06_Father_Mode.pdf", "Father Mode", "PDF 7 of 7",
     "The paired-partner father experience: its Slate skin, five father tabs, and "
     "the daily, reads, read-aloud and journal screens.",
     ["06_father_mode.md"]),
]


def main():
    only = set(sys.argv[1:])  # optionally build a subset by out-filename prefix
    os.makedirs(OUT, exist_ok=True)
    built, skipped = [], []
    for fname, title, part, desc, inputs in PDFS:
        if only and not any(fname.startswith(p) for p in only):
            continue
        paths = [os.path.join(CONTENT, b) for b in inputs]
        missing = [p for p in paths if not os.path.exists(p)]
        if missing:
            skipped.append((fname, "missing: " + ", ".join(os.path.basename(m) for m in missing)))
            continue
        outpath = os.path.join(OUT, fname)
        cmd = [sys.executable, MD2PDF, "--out", outpath, "--title", title,
               "--part", part, "--desc", desc] + paths
        r = subprocess.run(cmd, capture_output=True, text=True)
        if r.returncode != 0:
            skipped.append((fname, "ERROR: " + (r.stderr.strip()[-400:] or r.stdout.strip()[-400:])))
        else:
            built.append((fname, os.path.getsize(outpath)))

    print("== BUILT ==")
    for f, sz in built:
        print("  %-46s %6.1f KB" % (f, sz / 1024))
    if skipped:
        print("== SKIPPED ==")
        for f, why in skipped:
            print("  %-46s %s" % (f, why))


if __name__ == "__main__":
    main()
