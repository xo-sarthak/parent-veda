// =============================================================================
//  The one seam every stage opens an expert profile through
// -----------------------------------------------------------------------------
//  There is ONE expert profile screen in this app, and it currently lives at
//  `lib/screens/post_pregnancy/provider_profile_screen.dart`. That is a
//  historical address, not a statement about who it belongs to: it was built
//  for Parenting first, and it is now what Pregnancy's Prepare tab and the
//  shared yoga marketplace open too.
//
//  ⚠️ WHY A ONE-LINE RE-EXPORT INSTEAD OF MOVING THE SCREEN. The screen is
//  bound to seven Parenting files — `pp_common` (its whole design system),
//  `pp_learning_data`, `pp_channels_data`, the booking sheets, the learning
//  detail screen, the watch channel. Moving it to `lib/experts/` would have
//  meant dragging Parenting's design system into a shared module, which is a
//  worse coupling than the one it fixes. Moving the DATA out was cheap and has
//  been done (`lib/experts/expert.dart`); moving the SCREEN is not, and buys
//  nothing today.
//
//  So the compromise is stated rather than hidden: pregnancy screens import
//  THIS file, never `../post_pregnancy/pp_expert_link.dart`. That is one seam
//  instead of fifteen cross-stage imports, and the day the screen does move,
//  this file is the only one that changes.
//
//  ⚠️ DO NOT ADD A SECOND WAY TO OPEN A PROFILE. The reason `PpExpertName`
//  exists at all is that hand-rolling a `GestureDetector` per call site is how
//  twenty-two of twenty-eight names ended up dead. Everything below is
//  deliberately shorter to use than writing it yourself.
// =============================================================================

export 'expert.dart';

export '../screens/post_pregnancy/pp_expert_link.dart'
    show openExpertProfile, PpExpertName, PpExpertTapRow;

// ⚠️ `expertByName` IS EXPORTED AND `expertById` IS NOT, ON PURPOSE.
//
// `expertById` falls back to the FIRST expert in the registry for an id it does
// not know — it hands back a real, different doctor. That is tolerable where
// the result is decoration and catastrophic where the name is a CLAIM, which
// is what every call site on this seam is: "this person leads that class".
//
// `expertByName` and `expertByIdOrNull` return null instead, which is a
// printable fact. A row that cannot resolve its person renders un-tappable;
// somebody else's profile does not open under her name.
export '../screens/post_pregnancy/pp_experts_data.dart'
    show expertByName, expertByIdOrNull, kExperts;
