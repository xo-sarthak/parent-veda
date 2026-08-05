"""Route the Ready-for-Birth screen's interpolated copy through the table.

These are the strings the bulk extractor deliberately refused: each carries a
$variable, so it needs a method whose parameter name matches this call site.
Doing them by hand is the point — a sweep that guessed would compile and lie.
"""

PATH = 'lib/screens/tools/ready_for_birth_screen.dart'

EDITS = [
    ("'$due days to your due date'", 'S.now.rfbDaysToDue(due)'),
    ("'Your due date is today'", 'S.now.rfbDueToday'),
    ("'A little past your due date — any day now'", 'S.now.rfbPastDue'),
    ("'WEEK $w'", 'S.now.rfbWeekCaps(w)'),
    ("'Ready for birth'", 'S.now.rfbReadyForBirth'),
    ("'Getting ready'", 'S.now.rfbGettingReady'),
    ("'All done'", 'S.now.rfbAllDone'),
    ("'~${estMinutesFor(r.remaining)} min left'",
     'S.now.rfbMinLeft(estMinutesFor(r.remaining))'),
    ("'~${estMinutesFor(r.remaining)} min'",
     'S.now.rfbMin(estMinutesFor(r.remaining))'),
    ("'All packed'", 'S.now.rfbAllPacked'),
    ("'$packed packed · $remaining to go'",
     'S.now.rfbPackedToGo(packed, remaining)'),
    ("'$packed of ${items.length} packed'",
     'S.now.rfbPackedOf(packed, items.length)'),
    ("'Step ${_step + 1} of ${steps.length}'",
     'S.now.rfbStepOf(_step + 1, steps.length)'),
    ("'All done here'", 'S.now.rfbAllDoneHere'),
    ("'$remaining left to pack'", 'S.now.rfbLeftToPack(remaining)'),
    ("'Finish'", 'S.now.rfbFinish'),
    ("'Done · next'", 'S.now.rfbDoneNext'),
    ("'Delivery type'", 'S.now.rfbDeliveryType'),
    ("'Not sure'", 'S.now.rfbNotSure'),
    ("'Season of your due date'", 'S.now.rfbSeasonOfDue'),
    ("'My hospital already provides'", 'S.now.rfbHospitalProvides'),
    ("'Options'", 'S.now.rfbOptions'),
    ("'${whyPack(item)} Our picks below balance comfort, safety and value — or grab one from a store you already trust.'",
     'S.now.rfbWhyThenPicks(whyPack(item))'),
    ("'Buy on ${p.store}'", 'S.now.rfbBuyOn(p.store)'),
    ('"Let\'s Pack Together"', 'S.now.rfbPackTogether'),
]

src = open(PATH, encoding='utf-8').read()
done, missed = 0, []
for old, new in EDITS:
    if old in src:
        src = src.replace(old, new)
        done += 1
    else:
        missed.append(old[:64])

# Anything that was `const Text(...)` around a replaced literal stops being a
# compile-time constant; the analyzer will name them and they get fixed there.
open(PATH, 'w', encoding='utf-8', newline='').write(src)
print(f'{done}/{len(EDITS)} replaced')
for m in missed:
    print('  MISS: ' + m)
