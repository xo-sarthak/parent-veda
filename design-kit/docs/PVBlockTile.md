---
category: Layout
---

# PVBlockTile

One door on the grid. Pass a hue; saturation and lightness are fixed by token,
which is what makes twelve tiles read as one family.

```jsx
<PVBlockGrid columns={3}>
  <PVBlockTile label="Scans & tests" hue={PV_HUES.scans} mark={<PVIcon name="scan" size={34} />} />
  <PVBlockTile label="Nutrition" hue={PV_HUES.practice} mark={<PVIcon name="leaf" size={34} />} />
  <PVBlockTile label="Mind & mood" hue={PV_HUES.watch} mark={<PVIcon name="heart" size={34} />} state="notReady" />
</PVBlockGrid>
```

A hue belongs to a subject and stays with it everywhere. Two doors never share
a hue on one screen.
