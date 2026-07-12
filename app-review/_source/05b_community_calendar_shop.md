## Screen: Community (`community_screen.dart`)

**Status:** Live (functional prototype over seeded data). Posting, joining, liking, saving, reposting, voting, commenting and hiding all work and persist locally (via `CommunityStore` + `shared_preferences`, with best-effort cloud sync). What is seeded or cosmetic is called out below. The old "Community Pulse" carousel is commented out (removed, kept for revert).

**Reached from:** The "Community" bottom-navigation tab (5th tab, groups icon). Also reachable from the Tools hub list, the global search screen, and Ask Veda. (The file header comment calling it a "Tools tab" is outdated; it is a primary bottom-nav tab.)

**Purpose:** A personalised parenting social layer: rooms ("communities") plus one algorithmic feed where the mother can read, post, react to, and discuss pregnancy topics, with a trust language that visibly marks verified experts.

**Sections & UI (home feed, top to bottom):**
- Soft pink-to-purple background wash. Top row of utility icons (right-aligned, in-scroll): Doctor (test) mode toggle, My Bookmarks, My Activity, Search.
- Warm header: a pink eyebrow kicker, a large serif title, and a subtitle (all English + Hindi via localization).
- Optional "Doctor mode" gradient banner (only when doctor test mode is on) with an "Exit" button.
- "Your communities": horizontal cards for joined rooms, each a gradient monogram badge, member count, an unread-posts count pill, and a green online dot. Long-press opens a sheet to Mute/Unmute or Leave.
- "Recommended for you": horizontal cards for rooms not yet joined, each with emoji, name, member count, description, and a Join / Joined button. If everything is joined, a friendly note shows instead.
- Feed toggle: two chips, "For you" (ranked blend) and "Following" (only joined rooms + followed experts).
- Doctor mode only: a "Needs verification" filter chip that narrows the feed to posts that asked for expert verification and are not yet verified.
- The feed: a list of flat, Twitter-style post rows.
- Floating compose button (round "+"). In doctor test mode it turns into a medical icon and authors as the test doctor.

**Post row (`CommunityPostCard`) UI:**
- Author avatar (a purple gradient seal with a verified badge for experts; a soft tinted disc for members), author name, verified tick for experts, "@handle", and a pseudo "time ago" (cosmetic, derived from the post id; user posts read as "now").
- The room the post is in ("in [emoji] [name]").
- Post body text; attached real photos (device gallery/camera images) or an emoji stand-in image; poll options; topic hashtags.
- Engagement row: comment count, repost count, like (heart), a cosmetic "views" number, save (bookmark), and share.
- A verification line: an endorsed post shows a subtle "Verified by ..." hint (tap opens a "who verified" sheet listing fictional experts); a post that requested verification shows an "Awaiting [specialty] verification" tag (or, in doctor mode, a "Comment to verify this post" prompt).
- A "..." menu per post: Follow/Unfollow the expert, Not interested (hides the post for the session), Mute user, Block user, Report. Mute/Block/Report are toast-only stubs; Not interested and Follow are functional.

**Features & interactions:**
- Post: the compose flow (`CreatePostScreen`) is functional. The mother types text (with mic dictation), optionally attaches real photos from gallery or camera (via `image_picker`), picks where to post ("Your feed" or a joined room), picks a post type (Question/Experience/Milestone/Photo), and can toggle "Ask an expert to verify this" with a preferred specialty. Auto-suggested topic hashtags are inferred from the text. Sending creates a real, persisted post that pins to the top of the feed.
- Like, save (bookmark), repost, and "not interested" hide all work per post and persist (except "not interested", which is session-only).
- Polls: tapping an option records a vote (persisted); the chosen option is highlighted. One vote per poll.
- Join/leave a room, mute/unmute a room: functional and persisted. On first run, the pregnancy-stage rooms marked auto-join (November 2026 Moms, Second Trimester, Delhi Moms) are joined automatically.
- Doctor (test) mode: a testing toggle that makes the user post and comment as the fictional "Dr. (You)" (OB-GYN), so posts render with the expert seal. A doctor commenting on a post that requested verification marks that post as expert-verified. This exists to demo the doctor experience; there are no real doctor logins.
- Search (`_CommunitySearchDelegate`): searches rooms (by name/topic) and posts (by text/author/topic).
- My Activity: lists the user's own posts, commented posts, liked posts, and upvoted posts. My Bookmarks: lists saved posts. Both are functional views over stored state.
- Room detail (`CommunityDetailScreen`): a banner (emoji, name, members, description, Join button), a composer entry (if joined), and that room's posts.
- Post detail (`PostDetailScreen`): the full post, seeded plus user comments, a comment composer (functional, persisted), "Related discussions" (posts sharing a topic), and "Suggested communities" (recommended rooms sharing a topic).

**Data:** `CommunityStore` (joins, mutes, likes, saves, upvotes, reposts, votes, user posts, user comments, doctor mode, doctor endorsements; persisted via `shared_preferences` and cloud-synced). Seed rooms and posts come from `community_data.dart` (`kCommunities`, `kSeedPosts`, `kSeedComments`). Models in `community_models.dart` (`Community`, `CommunityPost`, `CommunityComment`). Expert follows use `ExpertFollowStore`. What is mock/seeded: the verified experts and endorsement counts (fictional doctors in `kCommunityExperts`), the "who verified" sheet, "views"/"time ago"/base repost counts (cosmetic derived numbers), and the feed "ranking" (a simple engagement heuristic, not real ML). Real backend features such as live expert sessions, DMs, and moderation are not built. Note: `community_data.dart` also holds separate parenting-stage rooms/posts (`kParentingCommunities`, `kParentingPosts`) used only by the post-pregnancy app, not by this pregnancy screen.

## Screen: Community Profile (`community_profile_screen.dart`)

**Status:** Live. The follow action and the author's post list are functional; some numbers are mock (see Data).

**Reached from:** Tapping a post author's avatar or name anywhere a `CommunityPostCard` appears (feed, room detail, post detail, My Activity, My Bookmarks).

**Purpose:** An X/Twitter-style author profile that separates verified experts from ordinary members and shows that author's posts.

**Sections & UI:**
- App bar with the author's name.
- Header: a large avatar (purple gradient seal for experts, tinted disc for members), the name with a verified tick for experts, and "@handle".
- Experts additionally show a credential pill (for example "IBCLC") and a generic expert bio; members show a "Member" badge.
- A stats row: post count, followers, following.
- A divider, then the author's own posts rendered with the shared post card (tap opens the post detail). If none, a "no posts yet" note.

**Features & interactions:**
- Follow / Following button (experts only): functional, toggles via `ExpertFollowStore`.
- Tapping any listed post opens its detail screen.

**Data:** Author identity, credential, and posts come from the tapped `CommunityPost` plus `CommunityStore.createdPosts` and the seed posts. The post count is real (posts by that author). Followers and following counts are mock (derived from the author name's hash). The expert bio is a fixed localized string, not per-author.

## Screen: My Calendar (`calendar_screen.dart`)

**Status:** Live. Views, filters, search, adding/deleting personal events, and the assembled event feed all work; personal events and appointments persist (locally, with best-effort Supabase cloud sync).

**Reached from:** The "Calendar" bottom-navigation tab (4th tab, calendar icon). Also reachable from the global search screen and Ask Veda.

**Purpose:** The pregnancy "command center" that answers where am I, what has happened, and what is next, by merging system milestones, journal and health logs, appointments, and the mother's own events onto one timeline/calendar.

**Sections & UI:**
- Header: title "My Calendar" (English + Hindi), a search toggle (searches event title/description), and a "+" to add a personal event.
- Progress card: current week of 40, "days together" with a heart glyph, a circular percent ring, and days remaining.
- A segmented control with three tabs: Journey Timeline, Calendar, Upcoming. The screen opens on the Calendar tab by default.
- Category filter chips: All, Milestones, Medical, Appointments, Journal, Personal, ParentVeda. Each category has its own dot colour.
- Tab 1, Journey Timeline: a vertical rail of event cards. Each card has a category icon, title, description, date, a left colour bar, and a status pill: "You are here" (current week), "Completed", or "Upcoming". Tap a card to open its event sheet.
- Tab 2, Calendar grid: month name with previous/next arrows, weekday letters, and a day grid. Each day cell shows the day number, up to three coloured category dots for that day, a small gold week-start tag (for example "21w"), a trimester-start pill on weeks 4/14/28 (T1/T2/T3), a "Childbirth" tag on the due date, a soft highlight band across the current pregnancy week, and a filled circle on today. Tapping a day selects it. Below the grid: a collapsible "What the dots mean" colour legend, and a selected-day panel showing that date, its pregnancy week, each event on that day (named with its category and meaning), and an "Add Note" row.
- Tab 3, Upcoming: future events grouped into This Week, Next 2 Weeks, This Month, and Later, each row showing the event icon, title, and a days-out label. Tap opens the event sheet.

**Features & interactions:**
- Add personal event ("+" or "Add Note"): a bottom sheet with a title field, a note field (with mic dictation), and a date picker. Saves a persisted personal event. Add Note pre-fills the selected day's date.
- Event sheet (tap any event): icon, title, full date, description, and context actions: "Open Week N" (jumps to that week in the weekly card stack), "Open Journal", and "Delete" (personal events only).
- Filter chips narrow every view to one category; search narrows by text.
- Month navigation and day selection are functional; the current week and due date are highlighted automatically from the saved due date.

**Data:** `CalendarStore.allEvents(...)` assembles the event list at build time by merging: system milestones/medical/ParentVeda-unlock events from `kJourneyMilestones`; journal entries from `JournalStore`; weight and kick-session logs from `ToolsStore` (as journal-lane events); mother-added personal events (persisted by `CalendarStore`); and appointments from the shared `ScansStore` (shown in the green "Appointment" lane). Scans appear two ways: the scheduled scan roadmap shows as blue "Medical" milestone events, and appointments the mother added under Scans & Appointments show as green "Appointment" events (these can also be partner-shared read-only). Completed scans are recorded to the Journal rather than added here directly. Models: `CalendarEvent`, `CalEventCategory`, `CalEventStatus`, `CalMeta` (colour + icon per category) in `calendar_event.dart`.

## Screen: ParentVeda Products / Shop (`products_screen.dart`)

**Status:** Live. It is a working catalog with saved items, an in-app cart, and a preview (mock) checkout. It is framed as a trust-first "decision engine", not a plain catalogue. Real payment is NOT taken; roughly half the catalog is affiliate (buy on Amazon, external), half is ParentVeda (in-app cart plus mock checkout).

**Reached from:** Not a bottom-nav tab. Opened from the Tools hub, the Home screen, the global search screen, Ask Veda, and the product-checklist "add products" flow.

**Purpose:** Help the mother reach a confident purchase decision per category (what to look for, what to avoid, when it is useful, top scored picks, and structured reviews) rather than just browse a list.

**Sections & UI:**
- App bar: title with a heart glyph, a search action, and a cart icon with a live item-count badge.
- Three tabs: Recommended, Browse all, Saved.
- Recommended tab: a heading for the current week, a subtitle, then category cards relevant to the current pregnancy week (each tagged "Relevant now"). If none are relevant, all categories show.
- Browse all tab: every product category as a card (emoji, name, one-line guidance, "See picks" arrow).
- Saved tab: product cards for items the mother saved (heart), or an empty state.
- Category page (`ProductCategoryScreen`): a guidance card (one-line advice plus "Look for" checks and "Avoid" crosses), a week-relevance timeline (shows whether the category is useful now or coming up, with a "you are at week N" marker), then "ParentVeda Picks" as product cards, then a browse-all count.
- Product card: badge (for example Best Overall, Best Budget, Best Premium, Sensitive Skin, Newborns), an "Affiliate" tag on Amazon products, a save heart, an emoji thumbnail, name and summary, a score pill (x/10), a "Best for" line, "Why" reasons (green checks), "Consider" caveats (red dots), price, and a Buy button. The Buy button says "Buy on Amazon" for affiliate products (opens an external Amazon India search URL) or "Buy now" for ParentVeda products (opens a single-item mock checkout).
- Product detail (`ProductDetailScreen`): a hero (large emoji, affiliate tag, badge, name, summary), a Verdict card (score, best-for, price), the week-relevance timeline, a "Why / Consider" card, a review summary (most loved, praise, drawback, "would buy again %"), structured parent reviews (used during, liked, watch out, would-buy-again tick), buy actions, and related products. The app bar also has an "Add to checklist" action and the cart icon.

**Features & interactions:**
- Save/unsave a product (heart), persisted via `ProductStore`.
- Search (`_ProductSearchDelegate`): matches categories and products, guidance-led.
- Affiliate product Buy: launches an external Amazon India search URL (`url_launcher`); no in-app cart.
- ParentVeda product Buy now: opens the preview checkout for that one item. Add to cart: adds to the in-app products cart (with a size step for apparel categories).
- Add to checklist: adds the product to a product checklist.

**Data:** Seed catalog in `product_data.dart` (`kProductCategories`, `kProducts`) with helpers `recommendedCategories(week)`, `productsForCategory`, `productIsAffiliate`, `amazonSearchUrl`. Models in `product_models.dart` (`Product`, `ProductCategory`, `ProductReview`, `ReviewSummary`, `ProductBadge`). Saved list is `ProductStore` (persisted + cloud-synced). Scores, badges, reviews, and review summaries are seeded editorial content. Product photos fall back to a placeholder image service or the emoji. The affiliate/ParentVeda split is defined by a fixed id set (about 12 of 24 products are affiliate).

## Screen: Cart & Preview Checkout (`cart_screen.dart`)

**Status:** Live but simulated. It is a believable marketplace cart and checkout; NO real payment is processed. The flow ends at a friendly "order placed" preview, and placing an order marks the items as "bought" so checklists can show an "already bought" state.

**Reached from:** The cart icon in the Products and Product Detail app bars (opens the products cart), and the "Buy now" buttons on ParentVeda products (open a single-item throwaway checkout). Also used for hospital-bag items via a shared helper.

**Purpose:** Let the mother review chosen items, adjust quantities and variants, and complete a preview order, with reusable helpers for adding to cart and for a single-item buy-now.

**Sections & UI:**
- Cart list: one row per line item with an emoji thumbnail, name, size/colour variant chips, a quantity stepper, unit price and line total, and a remove (x) button.
- Price summary bar: subtotal, delivery ("Free"), total, and a "Buy now" button.
- Empty state: a cart icon and an encouraging message when the cart is empty.
- Checkout screen (`_CheckoutScreen`): a "Deliver to" card (a mock saved address with a "Change" affordance), an order summary (each item with quantity/size and line total), a price card (subtotal, free delivery, total), a payment-method card carrying a "Coming soon" tag, and a "Place order" button showing the total.
- Order-placed view: a celebration state ("order placed") with a subtitle and a "Continue shopping" button that returns to the first screen.

**Features & interactions:**
- Add to cart (`showAddToCartFlow`): for apparel categories (maternity wear, nursing bra, compression socks, swaddle) it first asks for a size via a bottom sheet, then adds the line and shows a snackbar with a "View cart" action.
- Quantity stepper: increase/decrease per line; dropping to zero removes the line. Remove (x) deletes a line. All cart changes persist.
- Cart badge (`cartIconButton`): a reusable app-bar cart icon with a live total-quantity badge.
- Buy now (single item, `showSingleItemBuyNow` / `showSingleBuyNow`): uses a throwaway one-item cart so the real cart is untouched, then runs the same preview checkout.
- Place order: takes no payment; it marks every ordered product id in `BoughtStore` (so product checklists can display "already bought"), then shows the celebratory placed view. The payment method is explicitly a "coming soon" placeholder.

**Data:** `CartStore` holds separate carts (products, hospital bag, and a throwaway "buyNow" cart), each a list of `CartItem` (product id, name, emoji, unit price, quantity, optional size/colour), persisted and cloud-synced. `BoughtStore` holds the set of bought product ids (persisted + cloud). Prices are formatted as Indian rupees (`formatINR`), parsed from the product price label. No order records, shipping, or payment integration exist; checkout is a front-end simulation.
