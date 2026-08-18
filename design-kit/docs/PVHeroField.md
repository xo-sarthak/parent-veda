---
category: Layout
---

# PVHeroField

The top of every V3 screen: a chromatic field with the page riding over it as
an opaque sheet.

```jsx
<PVHeroField
  accentHue={273}
  variant={2}
  sheet={
    <>
      <PVSectionEyebrow>Where to go</PVSectionEyebrow>
      <PVBlockGrid>…</PVBlockGrid>
    </>
  }
>
  <PVSpineChip>WEEK 20</PVSpineChip>
  <PVText role="display">Twenty weeks</PVText>
</PVHeroField>
```

Content goes in `sheet`; only chrome goes in `children`. Type on the field
moves one ink tier darker than it would on the sheet.
