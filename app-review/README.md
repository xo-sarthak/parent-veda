# ParentVeda - Pregnancy App: Feature & Screen Reference

Seven PDFs documenting everything in the **pregnancy app** (the parenting / post-pregnancy
module is intentionally excluded). Each PDF has a cover, a clickable table of contents, and
PDF bookmarks, and documents every screen with: **Status, Reached from, Purpose, Sections &
UI, Features & interactions, and Data source.**

Total: **66 screens across 103 pages.**

| PDF | Area | Screens |
|-----|------|---------|
| `00_Overview_and_Navigation.pdf` | App map, launch flow, auth, shell, profile, search, saved hub. Ends with a cross-app **Status cheat-sheet for testers**. | 7 |
| `01_Today_and_Weekly_Journey.pdf` | Warm Nest daily home + the week-by-week journey (V2 flow, size views, weekly reads/videos). | 8 |
| `02_Garbh_Sanskar.pdf` | The four live pillars (Shravan, Vichara, Samvad, Kriya), games, spiritual reading. | 3 |
| `03_Tools_and_Trackers.pdf` | All 18 tools: kick counter, weight, kegel, contractions, due-date, symptoms, medicines, scans, hospital bag, checklist, reminders, Can-I, report help, Ask Veda. | 18 |
| `04_Journal_Keepsakes_and_Journey_Map.pdf` | Journal + writer, combined booklet/PDF, dear-baby vault, bump journey, milestone map. | 8 |
| `05_Prepare_Community_Calendar_Shop.pdf` | Prepare commerce (masterclasses, consults, cohorts, yoga, birthing) + community, calendar, shop. | 16 |
| `06_Father_Mode.pdf` | The paired-partner Slate experience: daily, reads, read-aloud, journal. | 6 |

**Start with PDF 00** - its overview orients you to the whole app, and its appendix lists
what is live vs mocked vs parked vs testing-only across every area.

## Regenerating or editing

The editable Markdown sources and the generator live in `_source/`. To rebuild after editing
any `.md` file:

```
cd _source
python build_all.py            # rebuilds all 7 PDFs into this folder
python build_all.py 03         # rebuild just one (by filename prefix)
```

Requires Python with `reportlab` (`pip install reportlab`). The generator is `md2pdf.py`;
`build_all.py` maps the source files to the seven PDFs.
