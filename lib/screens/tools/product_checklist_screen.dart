// =============================================================================
//  ProductChecklistScreen — build your own checklists from our products
// -----------------------------------------------------------------------------
//  The mother browses ParentVeda's product catalogue and assembles her own
//  named checklists: each item carries a custom "when/for" note and a tick-off.
//  Curated starter lists give her a quick head start. All local + persisted.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/product_data.dart';
import '../../localization/app_language.dart';
import '../../models/product_models.dart';
import '../../services/bought_store.dart';
import '../../services/cart_store.dart';
import '../../services/pregnancy_controller.dart';
import '../../services/product_checklist_store.dart';
import '../../theme/app_theme.dart';
import '../../widgets/mic_dictation_button.dart';
import '../cart_screen.dart';
import '../products_screen.dart';

const Color _accent = Color(0xFF3E9A8C);
const Color _green = Color(0xFF3FA56A);

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
String _itemName(ChecklistItem i) =>
    _itemProduct(i)?.name ?? (i.name.isEmpty ? 'Item' : i.name);
String _itemPrice(ChecklistItem i) => _itemProduct(i)?.price ?? i.price;
String _itemEmoji(ChecklistItem i) => _itemProduct(i)?.emoji ?? '🛍️';

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
            onPressed: () => Navigator.of(c).pop(),
            child: Text(s.pclCancel)),
        FilledButton(
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
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppTheme.surface,
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
                    color: AppTheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2))),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(s.pclAddToChecklist,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primary900)),
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
                            ? _accent
                            : AppTheme.neutral400,
                      ),
                      title: Text(l.name,
                          style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700)),
                      subtitle: Text(s.pclItemsCount(l.items.length),
                          style: GoogleFonts.manrope(
                              fontSize: 12, color: AppTheme.neutral500)),
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
                    leading: const Icon(Icons.add_rounded, color: _accent),
                    title: Text(s.pclNewChecklist,
                        style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700, color: _accent)),
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
    return Scaffold(
      backgroundColor: AppTheme.surfaceContainer,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceContainer,
        elevation: 0,
        title: Text(s.pclTitle),
      ),
      body: AnimatedBuilder(
        animation: ProductChecklistStore.instance,
        builder: (context, _) {
          final store = ProductChecklistStore.instance;
          final lists = store.checklists;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 36),
            children: [
              Text(s.pclIntro,
                  style: GoogleFonts.manrope(
                      fontSize: 13.5, height: 1.45, color: AppTheme.neutral600)),
              const SizedBox(height: 18),
              Row(children: [
                Expanded(
                  child: Text(s.pclYourLists,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primary900)),
                ),
                TextButton.icon(
                  onPressed: () => _newChecklist(context, s),
                  icon: const Icon(Icons.add_rounded, size: 18, color: _accent),
                  label: Text(s.pclNewChecklist,
                      style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700, color: _accent)),
                ),
              ]),
              const SizedBox(height: 4),
              if (lists.isEmpty)
                _emptyLists(s)
              else
                for (final l in lists) _checklistCard(context, s, l),
              const SizedBox(height: 24),
              Text(s.pclCurated,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primary900)),
              const SizedBox(height: 2),
              Text(s.pclCuratedSub,
                  style: GoogleFonts.manrope(
                      fontSize: 12.5, color: AppTheme.neutral500)),
              const SizedBox(height: 12),
              for (final c in kCuratedChecklists) _curatedCard(context, s, c),
            ],
          );
        },
      ),
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

  Widget _emptyLists(S s) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.outlineVariant)),
        child: Column(children: [
          const Icon(Icons.checklist_rounded, size: 34, color: _accent),
          const SizedBox(height: 10),
          Text(s.pclEmpty,
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                  fontSize: 13, height: 1.45, color: AppTheme.neutral600)),
        ]),
      );

  Widget _checklistCard(BuildContext context, S s, ProductChecklist l) {
    final total = l.items.length;
    final got = l.gotCount;
    final pct = total == 0 ? 0.0 : got / total;
    // Swipe-left to delete (with confirm); the ⋮ menu offers it too.
    return Dismissible(
      key: ValueKey('cl_${l.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(top: 12),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
            color: AppTheme.secondary500.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(20)),
        child: const Icon(Icons.delete_outline_rounded,
            color: AppTheme.secondary500),
      ),
      confirmDismiss: (_) => _confirmDeleteList(context, s, l),
      onDismissed: (_) => _deleteList(context, s, l),
      child: GestureDetector(
        onTap: () => _push(context,
            _ChecklistDetailScreen(controller: controller, checklistId: l.id)),
        child: Container(
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x0F2D144C),
                  blurRadius: 12,
                  offset: Offset(0, 3)),
            ],
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              // A tidy single list icon instead of the old emoji pile.
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: _accent.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.fact_check_rounded,
                    color: _accent, size: 24),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primary900)),
                      const SizedBox(height: 3),
                      Text(s.pclListSummary(total, got),
                          style: GoogleFonts.manrope(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.neutral500)),
                    ]),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded,
                    color: AppTheme.neutral400),
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
                      const Icon(Icons.delete_outline_rounded,
                          size: 18, color: AppTheme.secondary500),
                      const SizedBox(width: 8),
                      Text(s.pclDelete),
                    ]),
                  ),
                ],
              ),
            ]),
            if (total > 0) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: pct,
                  minHeight: 7,
                  backgroundColor: _accent.withValues(alpha: 0.12),
                  valueColor: const AlwaysStoppedAnimation(_accent),
                ),
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
              onPressed: () => Navigator.of(c).pop(false),
              child: Text(s.pclCancel)),
          FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.secondary500),
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

  Widget _curatedCard(BuildContext context, S s, CuratedList c) {
    return GestureDetector(
      onTap: () => _curatedPreview(context, s, c),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.outlineVariant),
        ),
        child: Row(children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: _accent.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14)),
            child: Text(c.emoji, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(c.name,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary900)),
              const SizedBox(height: 2),
              Text(s.pclItemsCount(c.items.length),
                  style: GoogleFonts.manrope(
                      fontSize: 12, color: AppTheme.neutral500)),
            ]),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppTheme.neutral400),
        ]),
      ),
    );
  }

  void _curatedPreview(BuildContext context, S s, CuratedList c) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.surface,
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
                    color: AppTheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2))),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
              child: Row(children: [
                Text(c.emoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(c.name,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primary900)),
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
                      leading:
                          Text(e.product!.emoji, style: const TextStyle(fontSize: 24)),
                      title: Text(e.product!.name,
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 14, fontWeight: FontWeight.w700)),
                      subtitle: Text(
                          e.note.isEmpty
                              ? e.product!.price
                              : '${e.note} · ${e.product!.price}',
                          style: GoogleFonts.manrope(
                              fontSize: 12, color: AppTheme.neutral500)),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                      backgroundColor: _accent,
                      padding: const EdgeInsets.symmetric(vertical: 13)),
                  onPressed: () {
                    final id =
                        ProductChecklistStore.instance.adoptCurated(c);
                    Navigator.of(sheetCtx).pop();
                    _push(
                        context,
                        _ChecklistDetailScreen(
                            controller: controller, checklistId: id));
                  },
                  child: Text(s.pclAdopt,
                      style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800)),
                ),
              ),
            ),
          ]),
        );
      },
    );
  }
}

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
    return AnimatedBuilder(
      animation: Listenable.merge([store, BoughtStore.instance]),
      builder: (context, _) {
        final list = store.byId(checklistId);
        if (list == null) {
          return Scaffold(
            appBar: AppBar(title: Text(s.pclTitle)),
            body: Center(child: Text(s.pclDeleted)),
          );
        }
        final total = list.items.length;
        final got = list.gotCount;
        return Scaffold(
          backgroundColor: AppTheme.surfaceContainer,
          appBar: AppBar(
            backgroundColor: AppTheme.surfaceContainer,
            elevation: 0,
            title: Text(list.name, maxLines: 1, overflow: TextOverflow.ellipsis),
            actions: [
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
                              onPressed: () => Navigator.of(c).pop(false),
                              child: Text(s.pclCancel)),
                          FilledButton(
                              style: FilledButton.styleFrom(
                                  backgroundColor: AppTheme.secondary500),
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
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 36),
            children: [
              // progress
              Row(children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: total == 0 ? 0.0 : got / total,
                      minHeight: 8,
                      backgroundColor: _accent.withValues(alpha: 0.12),
                      valueColor: const AlwaysStoppedAnimation(_accent),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(s.pclGotOf(got, total),
                    style: GoogleFonts.manrope(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: _accent)),
              ]),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _push(
                      context,
                      _AddProductsScreen(
                          controller: controller, checklistId: list.id)),
                  icon: const Icon(Icons.add_rounded, color: _accent),
                  label: Text(s.pclAddProducts,
                      style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800, color: _accent)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: _accent.withValues(alpha: 0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              if (list.items.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Text(s.pclEmptyItems,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.manrope(
                            fontSize: 13, color: AppTheme.neutral500)),
                  ),
                )
              else
                for (final item in list.items)
                  _itemRow(context, s, store, list.id, item),
            ],
          ),
          // Sticky finish bar — Save list (back to your lists) + Add to cart.
          bottomNavigationBar:
              list.items.isEmpty ? null : _bottomBar(context, s, list),
        );
      },
    );
  }

  Widget _bottomBar(BuildContext context, S s, ProductChecklist list) => SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          decoration: const BoxDecoration(
            color: AppTheme.surface,
            boxShadow: [
              BoxShadow(
                  color: Color(0x142D144C),
                  blurRadius: 16,
                  offset: Offset(0, -3)),
            ],
          ),
          child: Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context)
                    ..clearSnackBars()
                    ..showSnackBar(SnackBar(content: Text(s.pclSavedSnack)));
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.check_rounded, size: 18, color: _accent),
                label: Text(s.pclSaveList,
                    style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800, color: _accent)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: _accent.withValues(alpha: 0.5)),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: _accent,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.add_shopping_cart_rounded,
                    size: 18, color: Colors.white),
                label: Text(s.pclAddRemaining,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800, color: Colors.white)),
                onPressed: () => _addRemainingToCart(context, s, list),
              ),
            ),
          ]),
        ),
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
        name: p.name,
        emoji: p.emoji,
        unitPrice: parsePriceString(p.price),
      );
      added++;
    }
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
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

  Widget _itemRow(BuildContext context, S s, ProductChecklistStore store,
      String listId, ChecklistItem item) {
    final product = _itemProduct(item);
    final done = item.checked;
    final name = _itemName(item);
    final price = _itemPrice(item);
    final affiliate = product != null && productIsAffiliate(product);
    // Bought via our preview checkout → show it as owned (no buy actions).
    final bought = product != null && BoughtStore.instance.isBought(product.id);
    final owned = done || bought;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(8, 8, 4, 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A2D144C), blurRadius: 10, offset: Offset(0, 2)),
        ],
      ),
      child: Row(children: [
        // Bought via checkout → a locked green check (she owns it already).
        // Otherwise a normal tick-off box.
        if (bought)
          const Padding(
            padding: EdgeInsets.all(13),
            child: SizedBox(
              width: 22,
              height: 22,
              child: DecoratedBox(
                decoration: BoxDecoration(color: _green, shape: BoxShape.circle),
                child: Icon(Icons.check_rounded, size: 15, color: Colors.white),
              ),
            ),
          )
        else
          Checkbox(
            value: done,
            activeColor: _accent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            onChanged: (_) => _onCheck(context, s, store, listId, item),
          ),
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
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: AppTheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(12)),
                child:
                    Text(_itemEmoji(item), style: const TextStyle(fontSize: 22)),
              ),
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
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: owned
                                      ? AppTheme.neutral400
                                      : AppTheme.primary900,
                                  decoration: owned
                                      ? TextDecoration.lineThrough
                                      : null)),
                        ),
                        if (bought) ...[
                          const SizedBox(width: 6),
                          _miniTag(s.pclBoughtTag, _green),
                        ] else if (affiliate) ...[
                          const SizedBox(width: 6),
                          _miniTag(s.pclAffiliate, const Color(0xFFD98A2B)),
                        ] else if (item.isCustom) ...[
                          const SizedBox(width: 6),
                          _miniTag(s.pclCustomTag, _accent),
                        ],
                      ]),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () => _editNote(context, s, store, listId, item),
                        child: Row(children: [
                          Icon(Icons.schedule_rounded,
                              size: 13,
                              color: item.note.isEmpty
                                  ? AppTheme.neutral400
                                  : _accent),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                                item.note.isEmpty ? s.pclAddWhen : item.note,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.manrope(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: item.note.isEmpty
                                        ? AppTheme.neutral400
                                        : _accent)),
                          ),
                          if (price.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Text(price,
                                style: GoogleFonts.manrope(
                                    fontSize: 11.5,
                                    color: AppTheme.neutral500)),
                          ],
                        ]),
                      ),
                    ]),
              ),
            ]),
          ),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded, color: AppTheme.neutral400),
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

  Widget _miniTag(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(6)),
        child: Text(text,
            style: GoogleFonts.manrope(
                fontSize: 9.5, fontWeight: FontWeight.w800, color: color)),
      );

  // Ticking a NOT-yet-got item asks "Already got this?" first (Yes = owned, no
  // cart for it). Un-ticking a got item just clears it.
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
              onPressed: () => Navigator.of(c).pop(false),
              child: Text(s.pclGotPromptNo)),
          FilledButton(
              style: FilledButton.styleFrom(backgroundColor: _accent),
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
        name: p.name,
        emoji: p.emoji,
        unitPrice: parsePriceString(p.price),
      );
    }
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
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
    final note = await _promptText(context, s, s.pclEditNote, s.pclNotePrompt,
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

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S(widget.controller.language);
    return Scaffold(
      backgroundColor: AppTheme.surfaceContainer,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceContainer,
        elevation: 0,
        title: Text(s.pclAddProducts),
      ),
      bottomNavigationBar: _pickerBottomBar(s),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: s.pclSearchHint,
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: AppTheme.surface,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppTheme.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppTheme.outlineVariant),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
          child: OutlinedButton.icon(
            onPressed: _addOwnProduct,
            icon: const Icon(Icons.add_circle_outline_rounded,
                size: 18, color: _accent),
            label: Text(s.pclAddOwn,
                style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800, color: _accent)),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 44),
              side: BorderSide(color: _accent.withValues(alpha: 0.4)),
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
        Expanded(
          child: AnimatedBuilder(
            animation: ProductChecklistStore.instance,
            builder: (context, _) {
              final q = _query.trim();
              if (q.isNotEmpty) {
                final results = productSearch(q);
                if (results.isEmpty) {
                  return Center(
                    child: Text(s.pclNoResults,
                        style: GoogleFonts.manrope(color: AppTheme.neutral500)),
                  );
                }
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                  children: [for (final p in results) _productRow(s, p)],
                );
              }
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                children: [
                  for (final cat in kProductCategories) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(2, 14, 2, 8),
                      child: Text('${cat.emoji}  ${cat.name}',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primary900)),
                    ),
                    for (final p in productsForCategory(cat.id)) _productRow(s, p),
                  ],
                ],
              );
            },
          ),
        ),
      ]),
    );
  }

  Widget _productRow(S s, Product p) {
    final store = ProductChecklistStore.instance;
    final added = store.isInChecklist(widget.checklistId, p.id);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: Row(children: [
        Text(p.emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(p.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(p.price,
                style: GoogleFonts.manrope(
                    fontSize: 12, color: AppTheme.neutral500)),
          ]),
        ),
        const SizedBox(width: 8),
        GestureDetector(
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
              color: added ? _accent.withValues(alpha: 0.12) : _accent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(added ? Icons.check_rounded : Icons.add_rounded,
                  size: 16, color: added ? _accent : Colors.white),
              const SizedBox(width: 4),
              Text(added ? s.pclAdded : s.pclAdd,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: added ? _accent : Colors.white)),
            ]),
          ),
        ),
      ]),
    );
  }

  // Finish-right-here bar: Save list (back to your lists) or Add to cart.
  Widget _pickerBottomBar(S s) => SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          decoration: const BoxDecoration(
            color: AppTheme.surface,
            boxShadow: [
              BoxShadow(
                  color: Color(0x142D144C),
                  blurRadius: 16,
                  offset: Offset(0, -3)),
            ],
          ),
          child: Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _saveAndBack,
                icon: const Icon(Icons.check_rounded, size: 18, color: _accent),
                label: Text(s.pclSaveList,
                    style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800, color: _accent)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: _accent.withValues(alpha: 0.5)),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: _accent,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.add_shopping_cart_rounded,
                    size: 18, color: Colors.white),
                label: Text(s.cartAddToCart,
                    style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800, color: Colors.white)),
                onPressed: _addToCartAndOpen,
              ),
            ),
          ]),
        ),
      );

  void _saveAndBack() {
    final s = S(widget.controller.language);
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(s.pclSavedSnack)));
    Navigator.of(context).pop();
  }

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
          name: p.name,
          emoji: p.emoji,
          unitPrice: parsePriceString(p.price),
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

  // Add a product we don't stock — her own name + link + price + note.
  void _addOwnProduct() {
    final s = S(widget.controller.language);
    final nameC = TextEditingController();
    final linkC = TextEditingController();
    final priceC = TextEditingController();
    final noteC = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
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
                  Text(s.pclAddOwn,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primary900)),
                  const SizedBox(height: 14),
                  _customField(nameC, s.pclCustomName),
                  const SizedBox(height: 10),
                  _customField(linkC, s.pclCustomLink,
                      keyboard: TextInputType.url),
                  const SizedBox(height: 10),
                  _customField(priceC, s.pclCustomPrice),
                  const SizedBox(height: 10),
                  _customField(noteC, s.pclCustomNote),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                          backgroundColor: _accent,
                          padding: const EdgeInsets.symmetric(vertical: 13)),
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
                          style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w800)),
                    ),
                  ),
                ]),
          ),
        ),
      ),
    );
  }

  Widget _customField(TextEditingController c, String hint,
          {TextInputType? keyboard}) =>
      TextField(
        controller: c,
        keyboardType: keyboard,
        textCapitalization: keyboard == TextInputType.url
            ? TextCapitalization.none
            : TextCapitalization.sentences,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: AppTheme.surfaceContainer,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none),
        ),
      );
}
