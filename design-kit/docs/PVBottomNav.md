---
category: Navigation
---

# PVBottomNav

Two changes on the active tab — colour and weight — and **no container**.
Labels are always visible, on every tab.

```jsx
<PVBottomNav
  activeIndex={0}
  items={[
    { label: 'Today', icon: <PVIcon name="home" /> },
    { label: 'Week', icon: <PVIcon name="calendar" /> },
    { label: 'Tools', icon: <PVIcon name="tools" /> },
    { label: 'Circle', icon: <PVIcon name="community" /> },
    { label: 'You', icon: <PVIcon name="profile" /> },
  ]}
/>
```
