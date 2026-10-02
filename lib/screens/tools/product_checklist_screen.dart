// =============================================================================
//  ProductChecklistScreen - build your own checklists from our products
// -----------------------------------------------------------------------------
//  The mother browses ParentVeda's product catalogue and assembles her own
//  named checklists: each item carries a custom "when/for" note and a tick-off.
//  Curated starter lists give her a quick head start. All local + persisted.
//
//  ⚠️ ONE PARENTVEDA (2026-09-30, the pregnancy restyle, after main's TTC
//  tools). The app bar is the back arrow (and a menu where the page has one);
//  the page title is the serif on the page; "Your checklists" and "Curated
//  starters" are the one serif section heading. Rows that open somewhere carry
//  a drawn mark in the Tools tab's "Get ready" hue; the teal accent, the soft
//  shadows, the green, amber and rose tints, the decorative emoji in chrome,
//  the star beside our own score, the review count (seed reviews, not real
//  ones), the brand line (the name's first word, said twice) and the stock
//  photo placeholders are gone. Every filled button is the one ink.
//
//  ⚠️ FRESHENED (2026-10-02, the user: "it uses outdated emojis that are not used
//  in the app, and glyphs or marks not used any more; update it, make sure it
//  does not sound bad, use Mobbin so it is less confusing"). References: Noom's
//  and Lloyds' round-tick rows (https://mobbin.com/screens/b7950de7-6b61-481f-abfe-959c3916ef58,
//  https://mobbin.com/screens/82e6ae99-166c-4886-956b-c3dd8a6b9e56), Glovo's, Fresha's
//  and Subway's catalogue rows with one add control
//  (https://mobbin.com/screens/e5b6befa-470e-4809-8b65-f2df26535744), and Perplexity's
//  and Brick's starter cards (https://mobbin.com/screens/be80b9f7-f891-44b9-85ef-c8b6180d76c8).
//    · NO EMOJI: a product shows its own photo, or the family's drawn bag mark in
//      a quiet well; the starter lists and the lists she makes wear the TTC mark
//      family (the clipboard, the hands, the lotus, the jar), the marks the rest
//      of the app uses. The old hub marks (`IntentMark.*` wells) are gone here.
//    · TICKING IS ONE TAP. A dialog asked "Already got this?" before a tick took;
//      now it ticks, says what it did ("it won't go in your cart") and offers Undo.
//    · TICKED THINGS SINK to a "Got" group, so the list shows what is left.
//    · ONE ACTION AT THE FOOT. "Save list" saved nothing (the list saves as she
//      goes, now said once); the foot is one button: add what is left to the cart.
//    · THE WORDS: "Affiliate" is "Via Amazon", "Add when" is "Add a note", "Curated
//      starters" is "Starter lists", "ticked" is "ticked off". English only; the
//      shipped Hindi is untouched (`_Copy` returns it unchanged in Hindi).
//  The old pieces are kept below, commented, for revert.
// =============================================================================

import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';

import '../../data/product_data.dart';
import '../../localization/app_language.dart';
import '../../models/product_models.dart';
import '../../services/bought_store.dart';
import '../../services/cart_store.dart';
import '../../services/pregnancy_controller.dart';
import '../../services/product_checklist_store.dart';
import '../../widgets/mic_dictation_button.dart';
import '../brackets/hub/hub_intent_art.dart';
import '../cart_screen.dart';
// Kept for revert (2026-10-02, the wells are the TTC family marks now): import '../doors/pv_list_row.dart' show PvMarkWell;
import '../pregnancy/preg_chrome.dart';
import '../pregnancy/preg_tool_chrome.dart';
import '../products/pv_store_chrome.dart' show PvChip, kPvInk, kPvLine, pvStorePalette;
import '../products_screen.dart';
import '../../theme/pv_fonts.dart';
import '../ttc/doors/ttc_tab_art.dart' show TtcTabMark;
import '../ttc/ttc_tool_marks.dart' show TtcMarkLeading, TtcToolMark;
import '../v2/v2_palette.dart' show V2PaletteStore, v2BlockTint;

// Kept for revert (2026-09-30): the teal accent, the "bought" green and the
// star glyph's amber. Everything they drew is the one ink or a neutral tag.
// const Color _accent = Color(0xFF3E9A8C);
// const Color _green = Color(0xFF3FA56A);
// const Color _star = Color(0xFFF5A623); // rating star glyph accent

/// The Tools tab's "Get ready" hue (`tools_hub_screen.dart`), where this
/// tool's tile sits.
const double _kHue = 28;

// ---------------------------------------------------------------------------
//  Marks and words (2026-10-02)
// ---------------------------------------------------------------------------

/// The Tools tab's pastel for this tool, the tint the TTC family marks draw on.
Color _tint() => v2BlockTint(_kHue % 360, V2PaletteStore.instance.current);

/// A mark of the TTC tab family in the 44 box the app's lists draw it in.
Widget _tabMark(TtcTabMark m, {double size = 44}) =>
    TtcMarkLeading(tab: m, tint: _tint(), size: size);

/// The starter list's own mark, by its name (a const English identity in
/// `kCuratedChecklists`). Replaces the emoji and the old hub marks.
Widget _curatedLeading(CuratedList c, {double size = 44}) => _tabMark(
      switch (c.name) {
        'Newborn essentials' => TtcTabMark.heartHand,
        'Bump comfort' => TtcTabMark.lotus,
        'Skin & body' => TtcTabMark.jarLeaf,
        _ => TtcTabMark.checklist,
      },
      size: size,
    );

/// A product's picture: its own photo, or the family's bag mark in a quiet
/// well. Never an emoji and never a stock photo.
Widget _thumb(Product? p, double size) {
  final pal = pvStorePalette;
  Widget mark() => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: pal.surfaceAlt, borderRadius: BorderRadius.circular(12)),
        child: TtcMarkLeading(
            tool: TtcToolMark.hospitalBag, tint: _tint(), size: size * 0.74),
      );
  final photo = p == null ? null : _realImage(p);
  if (photo == null) return mark();
  return ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: Image.network(
      photo,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => mark(),
      loadingBuilder: (ctx, child, progress) => progress == null ? child : mark(),
    ),
  );
}

/// The words this tool says in English, plainer than the shipped ones. In
/// Hindi every line is the shipped one, untouched (new copy is English only).
class _Copy {
  const _Copy(this.s, this.hi);
  final S s;
  final bool hi;

  String get curated => hi ? s.pclCurated : 'Starter lists';
  String get curatedSub =>
      hi ? s.pclCuratedSub : 'Start from a ready-made list. Change anything you like.';
  String get empty => hi
      ? s.pclEmpty
      : 'No lists yet. Start your own, or begin from a starter list below.';
  String get emptyItems => hi
      ? s.pclEmptyItems
      : 'Nothing here yet. Add products from our catalogue, or add your own.';
  String get addOwn => hi ? s.pclAddOwn : 'Add your own item';
  String get customName => hi ? s.pclCustomName : 'Item name';
  String get customNote =>
      hi ? s.pclCustomNote : 'Note, such as when you need it (optional)';
  String get addNote => hi ? s.pclAddWhen : 'Add a note';
  String get notePrompt => hi ? s.pclNotePrompt : 'A note, such as when you need it';
  String listSummary(int total, int got) => hi
      ? s.pclListSummary(total, got)
      : total == 0
          ? 'Nothing added yet'
          : '$total items · $got ticked off';
  String gotOf(int got, int total) =>
      hi ? s.pclGotOf(got, total) : '$got of $total ticked off';
  String get adopt => hi ? s.pclAdopt : 'Use this list';
  String addRemaining(int n) =>
      hi ? s.pclAddRemaining : "Add what's left to cart ($n)";
  String get affiliate => hi ? s.pclAffiliate : 'Via Amazon';
  String get customTag => hi ? s.pclCustomTag : 'Added by you';
  String get boughtTag => hi ? s.pclBoughtTag : 'Bought';
  String gotHeading(int n) => hi ? 'Got · $n' : 'Got · $n';
  String get gotSnack =>
      hi ? s.pclGotPromptBody : "Ticked off. It won't go in your cart.";
  String get undo => hi ? 'Undo' : 'Undo';
  String get savedAuto => hi ? '' : 'Saved as you go';
  String get allDone => hi ? '' : 'Everything on this list is ticked off.';
  String get done => hi ? s.pclSave : 'Done';
}

/// A curated starter's drawn mark, by its name (the name is a const English
/// identity in `kCuratedChecklists`). Replaces the list's emoji in chrome.
// Kept for revert (2026-10-02): the old hub marks; `_curatedLeading` replaced it.
// ignore: unused_element
IntentMark _curatedMark(CuratedList c) => switch (c.name) {
      'Newborn essentials' => IntentMark.feedMark,
      'Bump comfort' => IntentMark.lotusMark,
      'Skin & body' => IntentMark.bodyMark,
      _ => IntentMark.listMark,
    };

/// The one outlined button: white, an ink hairline, ink words, a stadium.
ButtonStyle _outlineStyle() => OutlinedButton.styleFrom(
      foregroundColor: kPvInk,
      side: const BorderSide(color: kPvInk, width: 1.2),
      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
      shape: const StadiumBorder(),
    );

/// The filled button with the bar's padding.
ButtonStyle _filledStyle() => pregFilledStyle().copyWith(
      padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(vertical: 13, horizontal: 16)),
    );

/// A pushed page's app bar: the ground, the back arrow in ink, no title.
PreferredSizeWidget _pregAppBar({List<Widget>? actions}) {
  final pal = pvStorePalette;
  return AppBar(
    backgroundColor: pal.ground,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    foregroundColor: pal.ink1,
    actions: actions,
  );
}

/// A white field with the hairline, ink when focused. Replaces the filled
/// grey fields (a tint behind text).
InputDecoration _fieldDecoration(String hint, {Widget? prefix, Widget? suffix}) {
  final pal = pvStorePalette;
  OutlineInputBorder b(Color c, [double w = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: c, width: w));
  return InputDecoration(
    hintText: hint,
    hintStyle: pvManrope(fontSize: 14, color: pal.ink3),
    prefixIcon: prefix,
    suffixIcon: suffix,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: b(kPvLine),
    enabledBorder: b(kPvLine),
    focusedBorder: b(kPvInk, 1.4),
  );
}

/// A small neutral tag on an item (Bought, Amazon, Your own). A tint is for a
/// tag; the words are ink. Kept for revert: green, amber and teal tints with
/// the words in the same colour.
Widget _miniTag(String text) {
  final pal = pvStorePalette;
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(
        color: pal.surfaceAlt, borderRadius: BorderRadius.circular(999)),
    child: Text(text,
        style: pvManrope(fontSize: 10, fontWeight: FontWeight.w800, color: pal.ink2)),
  );
}

// Section 12 top filters (audience / stage). Shown ABOVE the existing
// category-grouped browse in the product picker.
const List<String> _kTopFilters = [
  'Baby',
  'Mom',
  'Trimester 1',
  'Trimester 2',
  'Trimester 3',
  'Post Birth',
  'Hospital Bag / Essentials',
];

void _push(BuildContext c, Widget w) =>
    Navigator.of(c).push(MaterialPageRoute(builder: (_) => w));

void _openUrl(String url) {
  final uri = Uri.tryParse(url.trim());
  if (uri != null && url.trim().isNotEmpty) {
    launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

// --- resolve a checklist item (catalog product OR custom) to display fields ---
Product? _itemProduct(ChecklistItem i) =>
    i.isCustom ? null : productById(i.productId);
// Display only - the card keys off product.id, not this. Resolved here so
// the ternary does not infer Object from a LocalizedText and a String.
String _itemName(ChecklistItem i) =>
    _itemProduct(i)?.name.now ?? (i.name.isEmpty ? 'Item' : i.name);
String _itemPrice(ChecklistItem i) => _itemProduct(i)?.price ?? i.price;
// Kept for revert (2026-10-02, no emoji anywhere): `_itemEmoji` returned the
// product's emoji for the picture; `_thumb` draws the photo or the family mark.
// String _itemEmoji(ChecklistItem i) => _itemProduct(i)?.emoji ?? '🛍️';

/// The product's own photo, or none. ⚠️ NEVER A STOCK PLACEHOLDER: when a
/// product has no `imageUrl`, `productImageUrl` returns a random loremflickr
/// picture, which is a placeholder image passed off as the product. The emoji
/// well stands in instead.
String? _realImage(Product p) => p.imageUrl.isEmpty ? null : p.imageUrl;

// --- product card helpers (Section 12) --------------------------------------
// The Product model has no explicit `brand` field, so we derive a sensible
// stand-in from the first token of the name (e.g. "ComfyBump Full-Body
// Pillow" -> "ComfyBump"). TODO: replace with a real Product.brand field.
// Kept for revert: the card no longer draws it (the name, said twice).
// ignore: unused_element
String _productBrand(Product p) {
  final first = p.name.now.trim().split(RegExp(r'\s+')).first;
  return first;
}

// Does [p] match the selected top filter? Empty filter = show all.
// The model lacks explicit audience / trimester / "essentials" fields, so each
// chip maps to the closest available signal (category id, category week window,
// or postpartum label). TODOs mark the approximations.
bool _productMatchesTopFilter(Product p, String filter) {
  if (filter.isEmpty) return true;
  final cat = productCategoryById(p.categoryId);
  if (cat == null) return false;
  switch (filter) {
    case 'Baby':
      // TODO: no audience field — approximate with baby-facing categories.
      return const {'swaddle', 'breast_pump'}.contains(cat.id);
    case 'Mom':
      // TODO: no audience field — everything not baby-only is mom-facing.
      return !const {'swaddle'}.contains(cat.id);
    case 'Trimester 1': // weeks ~4-13
      return cat.fromWeek <= 13 && cat.toWeek >= 4;
    case 'Trimester 2': // weeks ~14-27
      return cat.fromWeek <= 27 && cat.toWeek >= 14;
    case 'Trimester 3': // weeks ~28-40
      return cat.fromWeek <= 40 && cat.toWeek >= 28;
    case 'Post Birth':
      // .en - see ProductCategory.toWeek. This filter returned nothing at
      // all while the comparison was against the wrong type.
      return cat.toLabel.en == 'Postpartum';
    case 'Hospital Bag / Essentials':
      // TODO: no "essentials" flag — approximate with the near-birth +
      // newborn kit categories a mother typically packs.
      return const {
        'nursing_bra',
        'breast_pump',
        'swaddle',
        'maternity_wear',
        'compression_socks',
      }.contains(cat.id);
    default:
      return true;
  }
}

// ===========================================================================
//  Shared dialogs
// ===========================================================================

Future<String?> _promptText(BuildContext context, S s, String title, String hint,
    {String initial = ''}) {
  final ctrl = TextEditingController(text: initial);
  return showDialog<String>(
    context: context,
    builder: (c) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: ctrl,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
            hintText: hint,
            suffixIcon: MicDictateButton(controller: ctrl, s: s)),
        onSubmitted: (v) => Navigator.of(c).pop(v.trim()),
      ),
      actions: [
        TextButton(
            style: TextButton.styleFrom(foregroundColor: kPvInk),
            onPressed: () => Navigator.of(c).pop(),
            child: Text(s.pclCancel)),
        FilledButton(
            style: pregFilledStyle(),
            onPressed: () => Navigator.of(c).pop(ctrl.text.trim()),
            child: Text(s.pclSave)),
      ],
    ),
  );
}

/// Bottom sheet to add a single [product] to one of the mother's checklists
/// (or a brand-new one). Used from the product detail screen.
Future<void> showAddToChecklistSheet(
    BuildContext context, PregnancyController controller, Product product) {
  final s = S(controller.language);
  final store = ProductChecklistStore.instance;
  final pal = pvStorePalette;
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (sheetCtx) => AnimatedBuilder(
      animation: store,
      builder: (sheetCtx, _) {
        final lists = store.checklists;
        return SafeArea(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const SizedBox(height: 10),
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: kPvLine, borderRadius: BorderRadius.circular(2))),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(s.pclAddToChecklist,
                    style: pvFraunces(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                        color: pal.ink1)),
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final l in lists)
                    ListTile(
                      leading: Icon(
                        store.isInChecklist(l.id, product.id)
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                        color: store.isInChecklist(l.id, product.id)
                            ? kPvInk
                            : pal.ink3,
                      ),
                      title: Text(l.name,
                          style: pvManrope(
                              fontWeight: FontWeight.w700, color: pal.ink1)),
                      subtitle: Text(s.pclItemsCount(l.items.length),
                          style: pvManrope(fontSize: 12, color: pal.ink3)),
                      onTap: () {
                        if (!store.isInChecklist(l.id, product.id)) {
                          store.addItem(l.id, product.id);
                        }
                        Navigator.of(sheetCtx).pop();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(s.pclAddedTo(l.name))));
                      },
                    ),
                  ListTile(
                    leading: const Icon(Icons.add_rounded, color: kPvInk),
                    title: Text(s.pclNewChecklist,
                        style: pvManrope(
                            fontWeight: FontWeight.w700, color: kPvInk)),
                    onTap: () async {
                      final name = await _promptText(
                          sheetCtx, s, s.pclNewChecklist, s.pclNamePrompt);
                      if (name == null) return;
                      final id = store.createChecklist(name);
                      store.addItem(id, product.id);
                      if (sheetCtx.mounted) Navigator.of(sheetCtx).pop();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(s.pclAddedTo(
                                name.isEmpty ? s.pclTitle : name))));
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ]),
        );
      },
    ),
  );
}

// ===========================================================================
//  Tool home
// ===========================================================================

class ProductChecklistScreen extends StatelessWidget {
  const ProductChecklistScreen({super.key, required this.controller});
  final PregnancyController controller;

  @override
  Widget build(BuildContext context) {
    final s = S(controller.language);
    // The front page wears the shared shell (2026-09-30, Tools audit): field,
    // round back, list mark, eyebrow, serif title, the intro. "New checklist"
    // is the one round ink control opposite the back button. Kept for revert:
    // Scaffold(appBar: _pregAppBar(), body: ListView with the serif title, the
    // pclIntro line, and a Row of PregSectionHeading + a TextButton.icon "add").
    return AnimatedBuilder(
      animation: ProductChecklistStore.instance,
      builder: (context, _) {
        final store = ProductChecklistStore.instance;
        final lists = store.checklists;
        final c = _Copy(s, controller.language.isHindi);
        return PregToolScaffold(
          hue: _kHue,
          eyebrow: 'Get ready',
          title: s.pclTitle,
          // A shorter English line; Hindi keeps the shipped sentence.
          // Kept for revert: intro: s.pclIntro.
          intro: controller.language.isHindi
              ? s.pclIntro
              : 'Your own lists of what to get, with a note on when you need each thing.',
          mark: IntentMark.listMark,
          action: Semantics(
            button: true,
            label: s.pclNewChecklist,
            child: Tooltip(
              message: s.pclNewChecklist,
              child: InkWell(
                key: const ValueKey('pcl_new_checklist'),
                onTap: () => _newChecklist(context, s),
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration:
                      const BoxDecoration(color: kPvInk, shape: BoxShape.circle),
                  child: const Icon(Icons.add_rounded, size: 20, color: Colors.white),
                ),
              ),
            ),
          ),
          children: [
            pregToolPad(Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PregSectionHeading(s.pclYourLists),
                  const SizedBox(height: 4),
                  if (lists.isEmpty)
                    _emptyLists(s, c)
                  else
                    for (final l in lists) _checklistCard(context, s, c, l),
                  const SizedBox(height: 28),
                  // Kept for revert: the heading in Jakarta 16 / w800 and the
                  // grey line under it, drawn separately.
                  PregSectionHeading(c.curated, lead: c.curatedSub),
                  const SizedBox(height: 12),
                  // One white card of rows with drawn marks. Kept for revert:
                  // `_curatedCard` per list, a bordered card with the emoji.
                  PregRowCard(children: [
                    for (final l in kCuratedChecklists) _curatedRow(context, s, c, l),
                  ]),
                ])),
          ],
        );
      },
    );
  }

  void _newChecklist(BuildContext context, S s) async {
    final name = await _promptText(context, s, s.pclNewChecklist, s.pclNamePrompt);
    if (name == null) return;
    final id = ProductChecklistStore.instance.createChecklist(name);
    if (context.mounted) {
      // Straight into Add-products (no empty in-between detail screen).
      _push(context,
          _AddProductsScreen(controller: controller, checklistId: id));
    }
  }

  // The empty state is the feature's advertisement: a white card with the
  // checklist's drawn mark. Kept for revert: a teal `Icons.checklist_rounded`.
  Widget _emptyLists(S s, _Copy c) {
    final pal = pvStorePalette;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: PregCard(
        padding: const EdgeInsets.all(22),
        child: Column(children: [
          // The family's clipboard (2026-10-02). Kept for revert:
          // PvMarkWell(p: pal, hue: _kHue, size: 48, mark: IntentMark.checkMark).
          _tabMark(TtcTabMark.checklist, size: 56),
          const SizedBox(height: 12),
          Text(c.empty,
              textAlign: TextAlign.center,
              style: pvManrope(fontSize: 13.5, height: 1.45, color: pal.ink2)),
        ]),
      ),
    );
  }

  Widget _checklistCard(BuildContext context, S s, _Copy c, ProductChecklist l) {
    final pal = pvStorePalette;
    final total = l.items.length;
    final got = l.gotCount;
    final pct = total == 0 ? 0.0 : got / total;
    // Swipe-left to delete (with confirm); the ⋮ menu offers it too.
    return Dismissible(
      key: ValueKey('cl_${l.id}'),
      direction: DismissDirection.endToStart,
      // A neutral well behind the bin. Kept for revert: the rose tint
      // (`AppTheme.secondary500` at 0.14) with a rose bin.
      background: Container(
        margin: const EdgeInsets.only(top: 12),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
            color: pal.surfaceAlt, borderRadius: BorderRadius.circular(20)),
        child: Icon(Icons.delete_outline_rounded, color: pal.ink1),
      ),
      confirmDismiss: (_) => _confirmDeleteList(context, s, l),
      onDismissed: (_) => _deleteList(context, s, l),
      // A white card with the hairline and a drawn mark (it opens the list).
      // Kept for revert: a shadowed card with a teal-tinted
      // `Icons.fact_check_rounded` well and a teal progress bar.
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: PregCard(
          padding: const EdgeInsets.fromLTRB(14, 12, 4, 14),
          onTap: () => _push(context,
              _ChecklistDetailScreen(controller: controller, checklistId: l.id)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              // Kept for revert: PvMarkWell(p: pal, hue: _kHue, size: 44,
              // mark: IntentMark.checkMark).
              _tabMark(TtcTabMark.checklist),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: pvManrope(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: pal.ink1)),
                      const SizedBox(height: 3),
                      Text(c.listSummary(total, got),
                          style: pvManrope(fontSize: 12.5, color: pal.ink3)),
                    ]),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert_rounded, color: pal.ink3),
                onSelected: (v) async {
                  if (v == 'delete') {
                    final ok = await _confirmDeleteList(context, s, l);
                    if (ok == true && context.mounted) {
                      _deleteList(context, s, l);
                    }
                  }
                },
                itemBuilder: (c) => [
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [
                      Icon(Icons.delete_outline_rounded,
                          size: 18, color: pal.ink2),
                      const SizedBox(width: 8),
                      Text(s.pclDelete),
                    ]),
                  ),
                ],
              ),
            ]),
            if (total > 0) ...[
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: _progress(pct, 6),
              ),
            ],
          ]),
        ),
      ),
    );
  }

  Future<bool?> _confirmDeleteList(
      BuildContext context, S s, ProductChecklist l) {
    return showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(s.pclDeleteConfirm),
        content: Text(l.name),
        actions: [
          TextButton(
              style: TextButton.styleFrom(foregroundColor: kPvInk),
              onPressed: () => Navigator.of(c).pop(false),
              child: Text(s.pclCancel)),
          // The one ink. Kept for revert: the rose fill (`secondary500`).
          FilledButton(
              style: pregFilledStyle(),
              onPressed: () => Navigator.of(c).pop(true),
              child: Text(s.pclDelete)),
        ],
      ),
    );
  }

  void _deleteList(BuildContext context, S s, ProductChecklist l) {
    ProductChecklistStore.instance.deleteChecklist(l.id);
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(s.pclDeleted)));
  }

  Widget _curatedRow(BuildContext context, S s, _Copy c, CuratedList l) => PregOfferRow(
        mark: _curatedMark(l),
        leading: _curatedLeading(l),
        hue: _kHue,
        title: l.name,
        line: s.pclItemsCount(l.items.length),
        onTap: () => _curatedPreview(context, s, c, l),
      );

  // Kept for revert (2026-09-30): `_curatedCard`, a bordered white card per
  // curated list with the list's emoji in a teal-tinted 46-pt well, the name
  // in Jakarta 14.5 / w700, the count and a chevron. Now `_curatedRow`.

  void _curatedPreview(BuildContext context, S s, _Copy cp, CuratedList c) {
    final pal = pvStorePalette;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetCtx) {
        final products = [
          for (final it in c.items)
            (product: productById(it.productId), note: it.note)
        ].where((e) => e.product != null).toList();
        return SafeArea(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const SizedBox(height: 10),
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: kPvLine, borderRadius: BorderRadius.circular(2))),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
              // The list's drawn mark, not its emoji. Kept for revert:
              // Text(c.emoji, style: const TextStyle(fontSize: 22)).
              child: Row(children: [
                // Kept for revert: PvMarkWell(p: pal, hue: _kHue, size: 40,
                // mark: _curatedMark(c)).
                _curatedLeading(c, size: 44),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(c.name,
                      style: pvFraunces(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                          color: pal.ink1)),
                ),
              ]),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  for (final e in products)
                    ListTile(
                      // The photo or the family mark. Kept for revert:
                      // Text(e.product!.emoji, style: const TextStyle(fontSize: 24)).
                      leading: _thumb(e.product, 40),
                      title: Text(e.product!.name.now,
                          style: pvManrope(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: pal.ink1)),
                      subtitle: Text(
                          e.note.isEmpty
                              ? e.product!.price
                              : '${e.note} · ${e.product!.price}',
                          style: pvManrope(fontSize: 12, color: pal.ink3)),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: _filledStyle(),
                  onPressed: () {
                    final id =
                        ProductChecklistStore.instance.adoptCurated(c);
                    Navigator.of(sheetCtx).pop();
                    _push(
                        context,
                        _ChecklistDetailScreen(
                            controller: controller, checklistId: id));
                  },
                  child: Text(cp.adopt,
                      style: pvManrope(fontWeight: FontWeight.w800)),
                ),
              ),
            ),
          ]),
        );
      },
    );
  }
}

/// The progress line: the one ink on a neutral track. Kept for revert: teal
/// on a teal tint.
Widget _progress(double value, double height) {
  final pal = pvStorePalette;
  return ClipRRect(
    borderRadius: BorderRadius.circular(99),
    child: LinearProgressIndicator(
      value: value,
      minHeight: height,
      backgroundColor: pal.surfaceAlt,
      valueColor: const AlwaysStoppedAnimation(kPvInk),
    ),
  );
}

/// The finish bar under a list: a hairline above, the outlined second and the
/// one ink. Kept for revert: a shadow above, teal outline and teal fill.
Widget _finishBar(
        {required String saveLabel,
        required VoidCallback onSave,
        required String goLabel,
        required IconData goIcon,
        required VoidCallback onGo}) =>
    SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: kPvLine)),
        ),
        child: Row(children: [
          Expanded(
            child: OutlinedButton.icon(
              style: _outlineStyle(),
              onPressed: onSave,
              icon: const Icon(Icons.check_rounded, size: 18, color: kPvInk),
              label: Text(saveLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: pvManrope(fontWeight: FontWeight.w800, color: kPvInk)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: FilledButton.icon(
              style: _filledStyle(),
              icon: Icon(goIcon, size: 18, color: Colors.white),
              label: Text(goLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: pvManrope(fontWeight: FontWeight.w800, color: Colors.white)),
              onPressed: onGo,
            ),
          ),
        ]),
      ),
    );

// ===========================================================================
//  Checklist detail
// ===========================================================================

class _ChecklistDetailScreen extends StatelessWidget {
  const _ChecklistDetailScreen(
      {required this.controller, required this.checklistId});
  final PregnancyController controller;
  final String checklistId;

  @override
  Widget build(BuildContext context) {
    final s = S(controller.language);
    final store = ProductChecklistStore.instance;
    final pal = pvStorePalette;
    return AnimatedBuilder(
      animation: Listenable.merge([store, BoughtStore.instance]),
      builder: (context, _) {
        final list = store.byId(checklistId);
        if (list == null) {
          return Scaffold(
            backgroundColor: pal.ground,
            appBar: _pregAppBar(),
            body: ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
              children: [
                Text(s.pclTitle, style: pregPageTitleStyle()),
                const SizedBox(height: 12),
                Text(s.pclDeleted,
                    style: pvManrope(fontSize: 14, color: pal.ink2)),
              ],
            ),
            // Kept for revert: AppBar(title: Text(s.pclTitle)) over
            // Center(child: Text(s.pclDeleted)).
          );
        }
        final total = list.items.length;
        final got = list.gotCount;
        final c = _Copy(s, controller.language.isHindi);
        bool owned(ChecklistItem it) {
          final pr = _itemProduct(it);
          return it.checked ||
              (pr != null && BoughtStore.instance.isBought(pr.id));
        }

        final todo = [for (final it in list.items) if (!owned(it)) it];
        final gotItems = [for (final it in list.items) if (owned(it)) it];
        return Scaffold(
          backgroundColor: pal.ground,
          // The back arrow and the list's menu; the list's name is the serif
          // on the page. Kept for revert: `title: Text(list.name, maxLines: 1,
          // overflow: TextOverflow.ellipsis)` in the app bar.
          appBar: _pregAppBar(actions: [
            PopupMenuButton<String>(
              onSelected: (v) async {
                if (v == 'rename') {
                  final name = await _promptText(
                      context, s, s.pclRename, s.pclNamePrompt,
                      initial: list.name);
                  if (name != null) store.renameChecklist(list.id, name);
                } else if (v == 'delete') {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (c) => AlertDialog(
                      title: Text(s.pclDeleteConfirm),
                      actions: [
                        TextButton(
                            style: TextButton.styleFrom(foregroundColor: kPvInk),
                            onPressed: () => Navigator.of(c).pop(false),
                            child: Text(s.pclCancel)),
                        // The one ink. Kept for revert: the rose fill.
                        FilledButton(
                            style: pregFilledStyle(),
                            onPressed: () => Navigator.of(c).pop(true),
                            child: Text(s.pclDelete)),
                      ],
                    ),
                  );
                  if (ok == true) {
                    store.deleteChecklist(list.id);
                    if (context.mounted) Navigator.of(context).pop();
                  }
                }
              },
              itemBuilder: (c) => [
                PopupMenuItem(value: 'rename', child: Text(s.pclRename)),
                PopupMenuItem(value: 'delete', child: Text(s.pclDelete)),
              ],
            ),
          ]),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
            children: [
              Semantics(
                header: true,
                child: Text(list.name, style: pregPageTitleStyle()),
              ),
              const SizedBox(height: 14),
//  // Kept for revert (2026-10-02): the single list of every item, ticked or not.
//                // progress
//                Row(children: [
//                  Expanded(child: _progress(total == 0 ? 0.0 : got / total, 8)),
//                  const SizedBox(width: 12),
//                  Text(s.pclGotOf(got, total),
//                      style: pvManrope(
//                          fontSize: 12.5,
//                          fontWeight: FontWeight.w800,
//                          color: pal.ink1)),
//                ]),
//                const SizedBox(height: 16),
//                SizedBox(
//                  width: double.infinity,
//                  child: OutlinedButton.icon(
//                    onPressed: () => _push(
//                        context,
//                        _AddProductsScreen(
//                            controller: controller, checklistId: list.id)),
//                    icon: const Icon(Icons.add_rounded, color: kPvInk),
//                    label: Text(s.pclAddProducts,
//                        style: pvManrope(
//                            fontWeight: FontWeight.w800, color: kPvInk)),
//                    style: _outlineStyle(),
//                  ),
//                ),
//                const SizedBox(height: 14),
//                // Every item in one white card, hairlines between. Kept for
//                // revert: a shadowed card per item, 10 apart; the empty line
//                // centred on the page.
//                Container(
//                  decoration: BoxDecoration(
//                    color: Colors.white,
//                    borderRadius: BorderRadius.circular(20),
//                    border: Border.all(color: kPvLine),
//                  ),
//                  clipBehavior: Clip.antiAlias,
//                  child: list.items.isEmpty
//                      ? Padding(
//                          padding: const EdgeInsets.all(18),
//                          child: Text(s.pclEmptyItems,
//                              textAlign: TextAlign.center,
//                              style: pvManrope(
//                                  fontSize: 13.5, height: 1.45, color: pal.ink2)),
//                        )
//                      : Column(children: [
//                          for (var i = 0; i < list.items.length; i++) ...[
//                            if (i > 0)
//                              const Divider(
//                                  height: 1,
//                                  thickness: 1,
//                                  color: kPvLine,
//                                  indent: 64,
//                                  endIndent: 16),
//                            _itemRow(context, s, store, list.id, list.items[i]),
//                          ],
//                        ]),
//                ),
//              ],
//            ),
              // ---- progress, and what has been done for her (2026-10-02) -------
              // Side by side; stacked at a large text size, where the words need
              // the whole line.
              if (MediaQuery.textScalerOf(context).scale(10) > 13)
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(c.gotOf(got, total),
                      style: pvManrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: pal.ink1)),
                  const SizedBox(height: 8),
                  _progress(total == 0 ? 0.0 : got / total, 8),
                ])
              else
                Row(children: [
                  Expanded(child: _progress(total == 0 ? 0.0 : got / total, 8)),
                  const SizedBox(width: 12),
                  Text(c.gotOf(got, total),
                      style: pvManrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: pal.ink1)),
                ]),
              if (total > 0 && c.savedAuto.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(c.savedAuto,
                    key: const ValueKey('pcl_saved_auto'),
                    style: pvManrope(fontSize: 12.5, color: pal.ink3)),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  key: const ValueKey('pcl_add_products'),
                  onPressed: () => _push(
                      context,
                      _AddProductsScreen(
                          controller: controller, checklistId: list.id)),
                  icon: const Icon(Icons.add_rounded, color: kPvInk),
                  label: Text(s.pclAddProducts,
                      style: pvManrope(
                          fontWeight: FontWeight.w800, color: kPvInk)),
                  style: _outlineStyle(),
                ),
              ),
              const SizedBox(height: 14),
              // What is left first, what is got in its own group below, so the
              // list shows what still needs doing (Noom, Structured).
              if (list.items.isEmpty)
                _itemsCard(Padding(
                  padding: const EdgeInsets.all(18),
                  child: Text(c.emptyItems,
                      textAlign: TextAlign.center,
                      style: pvManrope(
                          fontSize: 14, height: 1.45, color: pal.ink2)),
                ))
              else ...[
                if (todo.isNotEmpty)
                  _itemsCard(Column(children: [
                    for (var i = 0; i < todo.length; i++) ...[
                      if (i > 0) _rowDivider(),
                      _itemRow(context, s, store, list.id, todo[i]),
                    ],
                  ]))
                else if (c.allDone.isNotEmpty)
                  _itemsCard(Padding(
                    padding: const EdgeInsets.all(18),
                    child: Text(c.allDone,
                        key: const ValueKey('pcl_all_done'),
                        textAlign: TextAlign.center,
                        style: pvManrope(
                            fontSize: 14, height: 1.45, color: pal.ink2)),
                  )),
                if (gotItems.isNotEmpty) ...[
                  const SizedBox(height: 22),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
                    child: Text(c.gotHeading(gotItems.length).toUpperCase(),
                        key: const ValueKey('pcl_got_heading'),
                        style: pregGroupLabelStyle()),
                  ),
                  _itemsCard(Column(children: [
                    for (var i = 0; i < gotItems.length; i++) ...[
                      if (i > 0) _rowDivider(),
                      _itemRow(context, s, store, list.id, gotItems[i]),
                    ],
                  ])),
                ],
              ],
            ],
          ),
          // Sticky finish bar - Save list (back to your lists) + Add to cart.
          // ONE ACTION (2026-10-02): add what is left to the cart, with how many.
          // Not drawn when nothing is left to add. Kept for revert: the two-button
          // `_bottomBar` (Save list and Add remaining to cart).
          bottomNavigationBar: _cartBar(context, s, c, list),
        );
      },
    );
  }

  /// The items the cart can take: not got, a catalogue product, not Amazon's,
  /// not bought and not in the cart. The same rule as `_addRemainingToCart`.
  List<Product> _cartable(ProductChecklist list) {
    final out = <Product>[];
    for (final item in list.items) {
      if (item.checked) continue;
      final p = productById(item.productId);
      if (p == null) continue;
      if (productIsAffiliate(p)) continue;
      if (BoughtStore.instance.isBought(p.id)) continue;
      if (CartStore.instance.contains(kProductsCartId, p.id)) continue;
      out.add(p);
    }
    return out;
  }

  Widget? _cartBar(BuildContext context, S s, _Copy c, ProductChecklist list) {
    final n = _cartable(list).length;
    if (n == 0) return null;
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: kPvLine)),
        ),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            key: const ValueKey('pcl_cart_bar'),
            style: _filledStyle(),
            icon: const Icon(Icons.add_shopping_cart_rounded,
                size: 18, color: Colors.white),
            label: Text(c.addRemaining(n),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: pvManrope(fontWeight: FontWeight.w800, color: Colors.white)),
            onPressed: () => _addRemainingToCart(context, s, list),
          ),
        ),
      ),
    );
  }

  /// One white card with the hairline: the surface for a group of items.
  Widget _itemsCard(Widget child) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kPvLine),
        ),
        clipBehavior: Clip.antiAlias,
        child: child,
      );

  Widget _rowDivider() => const Divider(
      height: 1, thickness: 1, color: kPvLine, indent: 64, endIndent: 16);

  // Kept for revert (2026-10-02): two buttons, "Save list" (the list had already
  // saved) and "Add remaining to cart". `_cartBar` replaced it.
  // ignore: unused_element
  Widget _bottomBar(BuildContext context, S s, ProductChecklist list) => _finishBar(
        saveLabel: s.pclSaveList,
        onSave: () {
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(SnackBar(content: Text(s.pclSavedSnack)));
          Navigator.of(context).pop();
        },
        goLabel: s.pclAddRemaining,
        goIcon: Icons.add_shopping_cart_rounded,
        onGo: () => _addRemainingToCart(context, s, list),
      );

  // Cart ONLY the items she still needs: un-got, catalogue, non-affiliate.
  // (Got items, custom products and affiliate items are skipped.)
  void _addRemainingToCart(BuildContext context, S s, ProductChecklist list) {
    var added = 0;
    for (final item in list.items) {
      if (item.checked) continue; // already got it
      final p = productById(item.productId);
      if (p == null) continue; // custom item
      if (productIsAffiliate(p)) continue; // affiliate → bought on Amazon
      if (BoughtStore.instance.isBought(p.id)) continue; // already bought
      if (CartStore.instance.contains(kProductsCartId, p.id)) continue;
      CartStore.instance.add(
        kProductsCartId,
        productId: p.id,
        name: p.name.now,
        unitPrice: parsePriceString(p.price),
        image: p.imageUrl,
      );
      added++;
    }
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
          // Flutter 3.44 keeps a snackbar with an action on screen until it is
          // dismissed (`persist` defaults to true when there is an action).
          persist: false,
        content: Text(added == 0 ? s.cartAllInCart : s.cartAddedN(added)),
        action: SnackBarAction(
          label: s.cartViewCart,
          onPressed: () => _push(
              context,
              CartScreen(
                  controller: controller,
                  cartId: kProductsCartId,
                  title: s.cartProductsTitle)),
        ),
      ));
  }

//  // Kept for revert (2026-10-02): the checkbox row with the clock line and the emoji well.
//    Widget _itemRow(BuildContext context, S s, ProductChecklistStore store,
//        String listId, ChecklistItem item) {
//      final pal = pvStorePalette;
//      final product = _itemProduct(item);
//      final done = item.checked;
//      final name = _itemName(item);
//      final price = _itemPrice(item);
//      final affiliate = product != null && productIsAffiliate(product);
//      // Bought via our preview checkout → show it as owned (no buy actions).
//      final bought = product != null && BoughtStore.instance.isBought(product.id);
//      final owned = done || bought;
//      return Padding(
//        padding: const EdgeInsets.fromLTRB(8, 8, 4, 8),
//        child: Row(children: [
//          // Bought via checkout → a locked ink check (she owns it already).
//          // Otherwise a normal tick-off box. Kept for revert: the check was
//          // green (0xFF3FA56A).
//          if (bought)
//            const Padding(
//              padding: EdgeInsets.all(13),
//              child: SizedBox(
//                width: 22,
//                height: 22,
//                child: DecoratedBox(
//                  decoration: BoxDecoration(color: kPvInk, shape: BoxShape.circle),
//                  child: Icon(Icons.check_rounded, size: 15, color: Colors.white),
//                ),
//              ),
//            )
//          else
//            Checkbox(
//              value: done,
//              activeColor: kPvInk,
//              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
//              onChanged: (_) => _onCheck(context, s, store, listId, item),
//            ),
//          Expanded(
//            child: GestureDetector(
//              behavior: HitTestBehavior.opaque,
//              onTap: () {
//                if (product != null) {
//                  _push(
//                      context,
//                      ProductDetailScreen(
//                          product: product, controller: controller));
//                } else if (item.link.isNotEmpty) {
//                  _openUrl(item.link);
//                }
//              },
//              child: Row(children: [
//                Container(
//                  width: 42,
//                  height: 42,
//                  alignment: Alignment.center,
//                  decoration: BoxDecoration(
//                      color: pal.surfaceAlt,
//                      borderRadius: BorderRadius.circular(12)),
//                  child:
//                      Text(_itemEmoji(item), style: const TextStyle(fontSize: 22)),
//                ),
//                const SizedBox(width: 12),
//                Expanded(
//                  child: Column(
//                      crossAxisAlignment: CrossAxisAlignment.start,
//                      children: [
//                        Row(children: [
//                          Flexible(
//                            child: Text(name,
//                                maxLines: 2,
//                                overflow: TextOverflow.ellipsis,
//                                style: pvManrope(
//                                    fontSize: 14,
//                                    fontWeight: FontWeight.w700,
//                                    color: owned ? pal.ink3 : pal.ink1,
//                                    decoration: owned
//                                        ? TextDecoration.lineThrough
//                                        : null)),
//                          ),
//                          if (bought) ...[
//                            const SizedBox(width: 6),
//                            _miniTag(s.pclBoughtTag),
//                          ] else if (affiliate) ...[
//                            const SizedBox(width: 6),
//                            _miniTag(s.pclAffiliate),
//                          ] else if (item.isCustom) ...[
//                            const SizedBox(width: 6),
//                            _miniTag(s.pclCustomTag),
//                          ],
//                        ]),
//                        const SizedBox(height: 4),
//                        GestureDetector(
//                          onTap: () => _editNote(context, s, store, listId, item),
//                          child: Row(children: [
//                            Icon(Icons.schedule_rounded,
//                                size: 13,
//                                color: item.note.isEmpty ? pal.ink3 : pal.ink2),
//                            const SizedBox(width: 4),
//                            Flexible(
//                              child: Text(
//                                  item.note.isEmpty ? s.pclAddWhen : item.note,
//                                  maxLines: 1,
//                                  overflow: TextOverflow.ellipsis,
//                                  style: pvManrope(
//                                      fontSize: 12,
//                                      fontWeight: FontWeight.w600,
//                                      color: item.note.isEmpty
//                                          ? pal.ink3
//                                          : pal.ink2)),
//                            ),
//                            if (price.isNotEmpty) ...[
//                              const SizedBox(width: 6),
//                              Text(price,
//                                  style: pvManrope(
//                                      fontSize: 11.5, color: pal.ink3)),
//                            ],
//                          ]),
//                        ),
//                      ]),
//                ),
//              ]),
//            ),
//          ),
//          PopupMenuButton<String>(
//            icon: Icon(Icons.more_vert_rounded, color: pal.ink3),
//            onSelected: (v) {
//              switch (v) {
//                case 'cart':
//                  if (product != null) _cartSingle(context, s, product);
//                  break;
//                case 'buynow':
//                  if (product != null) {
//                    showSingleItemBuyNow(context, controller, product);
//                  }
//                  break;
//                case 'amazon':
//                  if (product != null) _openUrl(amazonSearchUrl(product));
//                  break;
//                case 'link':
//                  _openUrl(item.link);
//                  break;
//                case 'note':
//                  _editNote(context, s, store, listId, item);
//                  break;
//                case 'remove':
//                  store.removeItem(listId, item.id);
//                  break;
//              }
//            },
//            // Buy actions only on items she doesn't have yet (got/bought = none).
//            itemBuilder: (c) => [
//              if (!owned && product != null && !affiliate) ...[
//                PopupMenuItem(value: 'cart', child: Text(s.cartAddToCart)),
//                PopupMenuItem(value: 'buynow', child: Text(s.cartBuyNow)),
//              ],
//              if (!owned && affiliate)
//                PopupMenuItem(value: 'amazon', child: Text(s.prBuyOnAmazon)),
//              if (!done && item.isCustom && item.link.isNotEmpty)
//                PopupMenuItem(value: 'link', child: Text(s.pclOpenLink)),
//              PopupMenuItem(value: 'note', child: Text(s.pclEditNote)),
//              PopupMenuItem(value: 'remove', child: Text(s.pclRemove)),
//            ],
//          ),
//        ]),
//      );
//    }

  Widget _itemRow(BuildContext context, S s, ProductChecklistStore store,
      String listId, ChecklistItem item) {
    final pal = pvStorePalette;
    final c = _Copy(s, controller.language.isHindi);
    final product = _itemProduct(item);
    final done = item.checked;
    final name = _itemName(item);
    final price = _itemPrice(item);
    final affiliate = product != null && productIsAffiliate(product);
    // Bought via our preview checkout: shown as owned, nothing left to buy.
    final bought = product != null && BoughtStore.instance.isBought(product.id);
    final owned = done || bought;
    return Padding(
      key: ValueKey('pcl_item_${item.id}'),
      padding: const EdgeInsets.fromLTRB(2, 6, 0, 6),
      child: Row(children: [
        _tick(context, c, store, listId, item, owned: owned, locked: bought),
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (product != null) {
                _push(
                    context,
                    ProductDetailScreen(
                        product: product, controller: controller));
              } else if (item.link.isNotEmpty) {
                _openUrl(item.link);
              }
            },
            child: Row(children: [
              _thumb(product, 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Flexible(
                          child: Text(name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: pvManrope(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                  color: owned ? pal.ink3 : pal.ink1,
                                  decoration: owned
                                      ? TextDecoration.lineThrough
                                      : null)),
                        ),
                        if (bought) ...[
                          const SizedBox(width: 6),
                          _miniTag(c.boughtTag),
                        ] else if (affiliate) ...[
                          const SizedBox(width: 6),
                          _miniTag(c.affiliate),
                        ] else if (item.isCustom) ...[
                          const SizedBox(width: 6),
                          _miniTag(c.customTag),
                        ],
                      ]),
                      const SizedBox(height: 4),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _editNote(context, s, store, listId, item),
                        child: Row(children: [
                          if (item.note.isEmpty) ...[
                            Icon(Icons.edit_outlined, size: 13, color: pal.ink3),
                            const SizedBox(width: 4),
                          ],
                          Flexible(
                            child: Text(
                                item.note.isEmpty ? c.addNote : item.note,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: pvManrope(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: item.note.isEmpty
                                        ? pal.ink3
                                        : pal.ink2)),
                          ),
                          if (price.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Text(price,
                                style: pvManrope(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: pal.ink2)),
                          ],
                        ]),
                      ),
                    ]),
              ),
            ]),
          ),
        ),
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert_rounded, color: pal.ink3),
          onSelected: (v) {
            switch (v) {
              case 'cart':
                if (product != null) _cartSingle(context, s, product);
                break;
              case 'buynow':
                if (product != null) {
                  showSingleItemBuyNow(context, controller, product);
                }
                break;
              case 'amazon':
                if (product != null) _openUrl(amazonSearchUrl(product));
                break;
              case 'link':
                _openUrl(item.link);
                break;
              case 'note':
                _editNote(context, s, store, listId, item);
                break;
              case 'remove':
                store.removeItem(listId, item.id);
                break;
            }
          },
          // Buy actions only on items she doesn't have yet (got/bought = none).
          itemBuilder: (c) => [
            if (!owned && product != null && !affiliate) ...[
              PopupMenuItem(value: 'cart', child: Text(s.cartAddToCart)),
              PopupMenuItem(value: 'buynow', child: Text(s.cartBuyNow)),
            ],
            if (!owned && affiliate)
              PopupMenuItem(value: 'amazon', child: Text(s.prBuyOnAmazon)),
            if (!done && item.isCustom && item.link.isNotEmpty)
              PopupMenuItem(value: 'link', child: Text(s.pclOpenLink)),
            PopupMenuItem(value: 'note', child: Text(s.pclEditNote)),
            PopupMenuItem(value: 'remove', child: Text(s.pclRemove)),
          ],
        ),
      ]),
    );
  }

  /// The round tick: a ring, and the one ink with a check when it is got. One
  /// tap ticks it, says what that did, and offers Undo (2026-10-02; a dialog
  /// used to ask first). A bought item is locked: she owns it already.
  Widget _tick(BuildContext context, _Copy c, ProductChecklistStore store,
      String listId, ChecklistItem item,
      {required bool owned, required bool locked}) {
    final pal = pvStorePalette;
    return Semantics(
      checked: owned,
      label: _itemName(item),
      child: InkResponse(
        key: ValueKey('pcl_tick_${item.id}'),
        radius: 26,
        onTap: locked ? null : () => _toggle(context, c, store, listId, item),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: owned ? kPvInk : Colors.transparent,
                border: owned
                    ? null
                    : Border.all(color: pal.ink3.withValues(alpha: 0.7), width: 1.6),
              ),
              child: owned
                  ? const Icon(Icons.check_rounded, size: 15, color: Colors.white)
                  : null,
            ),
          ),
        ),
      ),
    );
  }

  void _toggle(BuildContext context, _Copy c, ProductChecklistStore store,
      String listId, ChecklistItem item) {
    final wasDone = item.checked;
    store.toggleChecked(listId, item.id);
    if (wasDone) return; // un-ticking needs no words
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        persist: false,
        content: Text(c.gotSnack),
        action: SnackBarAction(
            label: c.undo,
            onPressed: () => store.toggleChecked(listId, item.id)),
      ));
  }

  // Ticking a NOT-yet-got item asks "Already got this?" first (Yes = owned, no
  // cart for it). Un-ticking a got item just clears it. Kept for revert
  // (2026-10-02): `_toggle` ticks at once and offers Undo instead.
  // ignore: unused_element
  void _onCheck(BuildContext context, S s, ProductChecklistStore store,
      String listId, ChecklistItem item) async {
    if (item.checked) {
      store.toggleChecked(listId, item.id);
      return;
    }
    final yes = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(s.pclGotPromptTitle),
        content: Text(s.pclGotPromptBody),
        actions: [
          TextButton(
              style: TextButton.styleFrom(foregroundColor: kPvInk),
              onPressed: () => Navigator.of(c).pop(false),
              child: Text(s.pclGotPromptNo)),
          FilledButton(
              style: pregFilledStyle(),
              onPressed: () => Navigator.of(c).pop(true),
              child: Text(s.pclGotPromptYes)),
        ],
      ),
    );
    if (yes == true) store.toggleChecked(listId, item.id);
  }

  void _cartSingle(BuildContext context, S s, Product p) {
    final inCart = CartStore.instance.contains(kProductsCartId, p.id);
    if (!inCart) {
      CartStore.instance.add(
        kProductsCartId,
        productId: p.id,
        name: p.name.now,
        unitPrice: parsePriceString(p.price),
        image: p.imageUrl,
      );
    }
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
          // Flutter 3.44 keeps a snackbar with an action on screen until it is
          // dismissed (`persist` defaults to true when there is an action).
          persist: false,
        content: Text(inCart ? s.cartAllInCart : s.cartAddedN(1)),
        action: SnackBarAction(
          label: s.cartViewCart,
          onPressed: () => _push(
              context,
              CartScreen(
                  controller: controller,
                  cartId: kProductsCartId,
                  title: s.cartProductsTitle)),
        ),
      ));
  }

  void _editNote(BuildContext context, S s, ProductChecklistStore store,
      String listId, ChecklistItem item) async {
    final note = await _promptText(context, s, s.pclEditNote,
        _Copy(s, controller.language.isHindi).notePrompt,
        initial: item.note);
    if (note != null) store.setNote(listId, item.id, note);
  }
}

// ===========================================================================
//  Add products (catalogue picker)
// ===========================================================================

class _AddProductsScreen extends StatefulWidget {
  const _AddProductsScreen(
      {required this.controller, required this.checklistId});
  final PregnancyController controller;
  final String checklistId;

  @override
  State<_AddProductsScreen> createState() => _AddProductsScreenState();
}

class _AddProductsScreenState extends State<_AddProductsScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  String _topFilter = ''; // '' = All; one of _kTopFilters otherwise

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S(widget.controller.language);
    final pal = pvStorePalette;
    return Scaffold(
      backgroundColor: pal.ground,
      // The back arrow only; the title is the serif on the page. Kept for
      // revert: `title: Text(s.pclAddProducts)` in the app bar.
      appBar: _pregAppBar(),
      bottomNavigationBar: _pickerBottomBar(s),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Semantics(
              header: true,
              child: Text(s.pclAddProducts, style: pregPageTitleStyle()),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _query = v),
            style: pvManrope(fontSize: 14.5, color: pal.ink1),
            decoration: _fieldDecoration(s.pclSearchHint,
                    prefix: Icon(Icons.search_rounded, color: pal.ink2))
                .copyWith(contentPadding: const EdgeInsets.symmetric(vertical: 0)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: OutlinedButton.icon(
            onPressed: _addOwnProduct,
            icon: const Icon(Icons.add_rounded, size: 18, color: kPvInk),
            label: Text(_Copy(s, widget.controller.language.isHindi).addOwn,
                style: pvManrope(fontWeight: FontWeight.w800, color: kPvInk)),
            style: _outlineStyle().copyWith(
              minimumSize: const WidgetStatePropertyAll(Size(double.infinity, 44)),
              padding: const WidgetStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: 16)),
            ),
          ),
        ),
        // Section 12: top filter chips (audience / stage) ABOVE the existing
        // category-grouped browse below.
        _topFilterChips(),
        const SizedBox(height: 4),
        Expanded(
          child: AnimatedBuilder(
            animation: ProductChecklistStore.instance,
            builder: (context, _) {
              final q = _query.trim();
              if (q.isNotEmpty) {
                final results = productSearch(q)
                    .where((p) => _productMatchesTopFilter(p, _topFilter))
                    .toList();
                if (results.isEmpty) {
                  return Center(
                    child: Text(s.pclNoResults,
                        style: pvManrope(color: pal.ink3)),
                  );
                }
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                  children: [for (final p in results) _productCard(s, p)],
                );
              }
              // Existing category filters (grouped browse), now honouring the
              // selected top filter and skipping categories left empty by it.
              final children = <Widget>[];
              for (final cat in kProductCategories) {
                final prods = productsForCategory(cat.id)
                    .where((p) => _productMatchesTopFilter(p, _topFilter))
                    .toList();
                if (prods.isEmpty) continue;
                // A group label inside the list: the small caps label, no
                // emoji. Kept for revert: Text('${cat.emoji}  ${cat.name}')
                // in Jakarta 14 / w800.
                children.add(Padding(
                  padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
                  child: Text(cat.name.now.toUpperCase(),
                      style: pregGroupLabelStyle()),
                ));
                for (final p in prods) {
                  children.add(_productCard(s, p));
                }
              }
              if (children.isEmpty) {
                return Center(
                  child: Text(s.pclNoResults,
                      style: pvManrope(color: pal.ink3)),
                );
              }
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                children: children,
              );
            },
          ),
        ),
      ]),
    );
  }

  // --- Top filter chips row (Section 12) ------------------------------------
  Widget _topFilterChips() => SizedBox(
        height: 38,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [for (final f in _kTopFilters) _chip(f)],
        ),
      );

  // The store's hairline chip, ink when chosen. Kept for revert: a
  // hand-drawn pill, teal when chosen.
  Widget _chip(String f) {
    final sel = _topFilter == f;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: PvChip(
        label: f,
        selected: sel,
        onTap: () => setState(() => _topFilter = sel ? '' : f),
      ),
    );
  }

  // Full product CARD (Section 12): photo, name, our score, price + the
  // add/remove toggle. Tapping the card opens the pregnancy-side
  // ProductDetailScreen (reused from products_screen.dart).
  //
  // ⚠️ 2026-09-30, what went and why. The brand line was the name's first
  // word (`_productBrand`), printed over the name that begins with it: one
  // fact, twice. The star beside the score read as a rating from mothers,
  // and the score is ours. The "(n)" beside it counted seed reviews. The
  // photo fell back to a random stock picture. Kept for revert:
  //   Text(_productBrand(p).toUpperCase(), ...)
  //   const Icon(Icons.star_rounded, size: 14, color: _star)
  //   if (reviewCount > 0) Text('($reviewCount)', ...)
  //   Image.network(productImageUrl(p), ...)
  Widget _productCard(S s, Product p) {
    final pal = pvStorePalette;
    final store = ProductChecklistStore.instance;
    final added = store.isInChecklist(widget.checklistId, p.id);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: PregCard(
        padding: const EdgeInsets.all(10),
        onTap: () => _push(
            context,
            ProductDetailScreen(
                product: p, controller: widget.controller)),
        child: Row(children: [
          // The product's own photo, or the family's bag mark in a quiet well
          // (2026-10-02). Kept for revert: its emoji in a neutral well.
          _thumb(p, 62),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.name.now,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: pvManrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                          color: pal.ink1)),
                  const SizedBox(height: 4),
                  Text(p.price,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: pvManrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: pal.ink1)),
                  const SizedBox(height: 2),
                  // score is the ParentVeda Score (x/10), said as ours.
                  Text('Score ${p.score.toStringAsFixed(1)}/10',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: pvManrope(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: pal.ink3)),
                ]),
          ),
          const SizedBox(width: 8),
          // Add is the one ink; once added it is white with the hairline and
          // a tick. Kept for revert: teal fill, and a teal tint once added.
          Semantics(
            button: true,
            child: GestureDetector(
              onTap: () {
                if (added) {
                  store.removeItem(widget.checklistId, p.id);
                } else {
                  store.addItem(widget.checklistId, p.id);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                decoration: BoxDecoration(
                  color: added ? Colors.white : kPvInk,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: added ? kPvLine : kPvInk),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(added ? Icons.check_rounded : Icons.add_rounded,
                      size: 16, color: added ? kPvInk : Colors.white),
                  const SizedBox(width: 4),
                  Text(added ? s.pclAdded : s.pclAdd,
                      style: pvManrope(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: added ? kPvInk : Colors.white)),
                ]),
              ),
            ),
          ),
        ]),
      ),
    );
  }

//    // Kept for revert (2026-10-02, no emoji anywhere): the emoji well. `_thumb`
//    // draws the photo or the family mark instead.
//    Widget _imgFallback(Product p) => Container(
//          width: 62,
//          height: 62,
//          alignment: Alignment.center,
//          color: pvStorePalette.surfaceAlt,
//          child: Text(p.emoji, style: const TextStyle(fontSize: 26)),
//        );


  // Old compact row, replaced by _productCard above. Kept for reference/revert.
  // Widget _productRow(S s, Product p) {
  //   final store = ProductChecklistStore.instance;
  //   final added = store.isInChecklist(widget.checklistId, p.id);
  //   return Container(
  //     margin: const EdgeInsets.only(bottom: 8),
  //     padding: const EdgeInsets.all(10),
  //     decoration: BoxDecoration(
  //       color: AppTheme.surface,
  //       borderRadius: BorderRadius.circular(14),
  //       border: Border.all(color: AppTheme.outlineVariant),
  //     ),
  //     child: Row(children: [
  //       Text(p.emoji, style: const TextStyle(fontSize: 24)),
  //       const SizedBox(width: 12),
  //       Expanded(
  //         child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
  //           Text(p.name,
  //               maxLines: 1,
  //               overflow: TextOverflow.ellipsis,
  //               style: pvJakarta(
  //                   fontSize: 13.5, fontWeight: FontWeight.w700)),
  //           const SizedBox(height: 2),
  //           Text(p.price,
  //               style: pvManrope(
  //                   fontSize: 12, color: AppTheme.neutral500)),
  //         ]),
  //       ),
  //       const SizedBox(width: 8),
  //       GestureDetector(
  //         onTap: () {
  //           if (added) {
  //             store.removeItem(widget.checklistId, p.id);
  //           } else {
  //             store.addItem(widget.checklistId, p.id);
  //           }
  //         },
  //         child: Container(
  //           padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
  //           decoration: BoxDecoration(
  //             color: added ? _accent.withValues(alpha: 0.12) : _accent,
  //             borderRadius: BorderRadius.circular(12),
  //           ),
  //           child: Row(mainAxisSize: MainAxisSize.min, children: [
  //             Icon(added ? Icons.check_rounded : Icons.add_rounded,
  //                 size: 16, color: added ? _accent : Colors.white),
  //             const SizedBox(width: 4),
  //             Text(added ? s.pclAdded : s.pclAdd,
  //                 style: pvJakarta(
  //                     fontSize: 12.5,
  //                     fontWeight: FontWeight.w800,
  //                     color: added ? _accent : Colors.white)),
  //           ]),
  //         ),
  //       ),
  //     ]),
  //   );
  // }


  // Finish-right-here bar: Save list (back to your lists) or Add to cart.
  // ONE BUTTON (2026-10-02): "Done", with how many are on the list. The cart is
  // one tap away on the list itself. Kept for revert: `_finishBar` with Save
  // list and Add to cart (`_addToCartAndOpen` below).
  Widget _pickerBottomBar(S s) => AnimatedBuilder(
        animation: ProductChecklistStore.instance,
        builder: (context, _) {
          final n =
              ProductChecklistStore.instance.byId(widget.checklistId)?.items.length ?? 0;
          final c = _Copy(s, widget.controller.language.isHindi);
          return SafeArea(
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: kPvLine)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  key: const ValueKey('pcl_picker_done'),
                  style: _filledStyle(),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(n == 0 ? c.done : '${c.done} · $n',
                      style: pvManrope(fontWeight: FontWeight.w800, color: Colors.white)),
                ),
              ),
            ),
          );
        },
      );

  // ignore: unused_element
  void _saveAndBack() {
    final s = S(widget.controller.language);
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(s.pclSavedSnack)));
    Navigator.of(context).pop();
  }

  // ignore: unused_element
  void _addToCartAndOpen() {
    final s = S(widget.controller.language);
    final list = ProductChecklistStore.instance.byId(widget.checklistId);
    if (list != null) {
      for (final item in list.items) {
        final p = productById(item.productId);
        if (p == null) continue; // custom item
        if (productIsAffiliate(p)) continue; // affiliate → Amazon
        if (BoughtStore.instance.isBought(p.id)) continue; // already bought
        if (CartStore.instance.contains(kProductsCartId, p.id)) continue;
        CartStore.instance.add(
          kProductsCartId,
          productId: p.id,
          name: p.name.now,
          unitPrice: parsePriceString(p.price),
          image: p.imageUrl,
        );
      }
    }
    _push(
        context,
        CartScreen(
            controller: widget.controller,
            cartId: kProductsCartId,
            title: s.cartProductsTitle));
  }

  // Add a product we don't stock - her own name + link + price + note.
  void _addOwnProduct() {
    final s = S(widget.controller.language);
    final cp = _Copy(s, widget.controller.language.isHindi);
    final pal = pvStorePalette;
    final nameC = TextEditingController();
    final linkC = TextEditingController();
    final priceC = TextEditingController();
    final noteC = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetCtx) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(sheetCtx).viewInsets.bottom),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cp.addOwn,
                      style: pvFraunces(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                          color: pal.ink1)),
                  const SizedBox(height: 14),
                  _customField(nameC, cp.customName),
                  const SizedBox(height: 10),
                  _customField(linkC, s.pclCustomLink,
                      keyboard: TextInputType.url),
                  const SizedBox(height: 10),
                  _customField(priceC, s.pclCustomPrice),
                  const SizedBox(height: 10),
                  _customField(noteC, cp.customNote),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: _filledStyle(),
                      onPressed: () {
                        final name = nameC.text.trim();
                        if (name.isEmpty) return;
                        ProductChecklistStore.instance.addCustomItem(
                          widget.checklistId,
                          name: name,
                          link: linkC.text.trim(),
                          price: priceC.text.trim(),
                          note: noteC.text.trim(),
                        );
                        Navigator.of(sheetCtx).pop();
                        ScaffoldMessenger.of(context)
                          ..clearSnackBars()
                          ..showSnackBar(
                              SnackBar(content: Text(s.pclCustomAdded(name))));
                      },
                      child: Text(s.pclSave,
                          style: pvManrope(fontWeight: FontWeight.w800)),
                    ),
                  ),
                ]),
          ),
        ),
      ),
    );
  }

  // A white field with the hairline. Kept for revert: a filled grey field.
  Widget _customField(TextEditingController c, String hint,
          {TextInputType? keyboard}) =>
      TextField(
        controller: c,
        keyboardType: keyboard,
        textCapitalization: keyboard == TextInputType.url
            ? TextCapitalization.none
            : TextCapitalization.sentences,
        style: pvManrope(fontSize: 14.5, color: pvStorePalette.ink1),
        decoration: _fieldDecoration(hint),
      );
}
