---
category: Foundations
---

# PVScreen

The root wrapper. Every ParentVeda screen starts here.

```jsx
<PVScreen>
  <PVHeroField sheet={<>…page content…</>}>
    <PVSpineChip>WEEK 20</PVSpineChip>
  </PVHeroField>
</PVScreen>
```

Without it the components render on the host page's background in the browser's
default serif — the most common way a design comes back not looking like ours.
