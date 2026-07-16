// =============================================================================
//  The rank floor — Brand Product 5's single most important rule
// -----------------------------------------------------------------------------
//  "Sponsored products must never outrank objectively better products."
//
//  The naive way to build featured recommendations is to add a commercial term
//  to the scoring function. That is the one thing we must never do: once money
//  is an input to the score, "better" and "paying" become the same word, and no
//  amount of labelling repairs it.
//
//  So scoring stays commercially blind, and insertion happens AFTER ranking:
//  a sponsored item is placed at the first position where the organic item
//  below it scores lower than the sponsored item does on its own merits. It
//  earns its slot by its real score; sponsorship only buys the right to be
//  CONSIDERED, never the right to win.
//
//  Two hard rules fall out:
//    · never above an organic item with a higher score
//    · never slot 0 — the top of a list is editorial, and is not for sale
// =============================================================================

/// Insert [promo] into an already-ranked [organic] list without letting it
/// outrank anything better.
///
/// [scoreOf] is the host's own scoring function — passed in rather than
/// imported, so this file cannot see (or influence) how merit is calculated.
///
/// Returns a new list. [organic] is expected to be sorted best-first.
List<T> insertWithRankFloor<T>({
  required List<T> organic,
  required T promo,
  required double Function(T) scoreOf,
  bool Function(T, T)? isSame,
}) {
  final same = isSame ?? (T a, T b) => identical(a, b);

  // A sponsored item never appears twice, and never competes with itself.
  final rest = organic.where((o) => !same(o, promo)).toList();
  if (rest.isEmpty) return [promo];

  final promoScore = scoreOf(promo);

  // The first place where the sponsored item is genuinely at least as good as
  // what follows. Everything above it scored higher on merit and stays there.
  var at = rest.indexWhere((o) => scoreOf(o) < promoScore);
  if (at < 0) at = rest.length; // it beat nothing — it goes last

  // The top of a list is editorial. Even a sponsored item that outscores
  // everything does not get slot 0: that position is the one a parent reads as
  // "ParentVeda's pick", and it is not for sale.
  if (at == 0) at = 1;

  return [...rest.sublist(0, at), promo, ...rest.sublist(at)];
}

/// Does [promo] clear the quality floor to be eligible at all?
///
/// "Products must satisfy ParentVeda quality standards" — sponsorship buys
/// consideration, not entry. A product we would not recommend unpaid cannot be
/// bought into a list at any price.
bool clearsQualityFloor(double rating, {double floor = 4.0}) => rating >= floor;
