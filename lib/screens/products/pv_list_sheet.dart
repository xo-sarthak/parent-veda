// =============================================================================
//  pv_list_sheet.dart — "Save to a list" and "Edit list" (2026-10-28)
// -----------------------------------------------------------------------------
//  Amazon's "Add to List" sheet, in our look: her lists with a tick on the
//  ones that hold this product, one tap to put it in or take it out, and
//  "New list" right there so a first list never needs a trip elsewhere.
//  The store is PvListStore; this file only draws it.
// =============================================================================

import 'package:flutter/material.dart';

import '../../models/pv_product.dart';
import '../../services/pv_list_store.dart';
import '../../theme/pv_fonts.dart';
import 'pv_store_chrome.dart';

/// Opens the sheet for [product]. Every change is saved as it is tapped.
Future<void> showPvAddToListSheet(BuildContext context, PvProduct product) {
  final pal = pvStorePalette;
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: pal.ground,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _AddToListSheet(product: product),
  );
}

class _AddToListSheet extends StatefulWidget {
  const _AddToListSheet({required this.product});
  final PvProduct product;

  @override
  State<_AddToListSheet> createState() => _AddToListSheetState();
}

class _AddToListSheetState extends State<_AddToListSheet> {
  final _name = TextEditingController();
  bool _making = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _create() {
    final made = PvListStore.instance.create(
      _name.text,
      firstProductId: widget.product.id,
    );
    if (made == null) {
      setState(
        () => _error = _name.text.trim().isEmpty
            ? 'Give the list a name.'
            : 'You already have a list with that name.',
      );
      return;
    }
    _name.clear();
    setState(() {
      _making = false;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pal = pvStorePalette;
    final store = PvListStore.instance;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: ListenableBuilder(
          listenable: store,
          builder: (context, _) => Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
            child: Column(
              key: const ValueKey('pv_list_sheet'),
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Save to a list',
                  style: pvFraunces(
                    fontSize: 21,
                    fontWeight: FontWeight.w500,
                    color: pal.ink1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  store.lists.isEmpty
                      ? 'Make lists for anything: Hospital bag, Baby\'s room, '
                            'Gifts to ask for. A product can sit in as many as you like.'
                      : 'Tick a list to put ${widget.product.name} in it. '
                            'Untick to take it out.',
                  style: pvManrope(fontSize: 13.5, height: 1.45, color: pal.ink2),
                ),
                const SizedBox(height: 10),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.4,
                  ),
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (final l in store.lists)
                        CheckboxListTile(
                          key: ValueKey('pv_list_row_${l.id}'),
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          activeColor: kPvInk,
                          value: l.productIds.contains(widget.product.id),
                          onChanged: (_) =>
                              store.toggle(l.id, widget.product.id),
                          title: Text(
                            l.name,
                            style: pvManrope(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: pal.ink1,
                            ),
                          ),
                          subtitle: Text(
                            l.productIds.length == 1
                                ? '1 product'
                                : '${l.productIds.length} products',
                            style: pvManrope(fontSize: 12.5, color: pal.ink3),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                if (_making) ...[
                  TextField(
                    key: const ValueKey('pv_list_new_name'),
                    controller: _name,
                    autofocus: true,
                    maxLength: PvListStore.maxNameLength,
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (_) => _create(),
                    decoration: InputDecoration(
                      hintText: 'List name, e.g. Hospital bag',
                      errorText: _error,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  PvCommit(
                    key: const ValueKey('pv_list_create'),
                    label: 'Create and add',
                    onTap: _create,
                  ),
                ] else
                  PvSecondary(
                    key: const ValueKey('pv_list_new'),
                    label: 'New list',
                    icon: Icons.add_rounded,
                    onTap: () => setState(() => _making = true),
                  ),
                const SizedBox(height: 8),
                PvCommit(
                  label: 'Done',
                  onTap: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Rename or delete [list], from the wishlist. Deleting asks first, and
/// says the products themselves are not affected.
Future<void> showPvEditListSheet(BuildContext context, PvProductList list) {
  final pal = pvStorePalette;
  final name = TextEditingController(text: list.name);
  String? error;
  var confirmDelete = false;
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: pal.ground,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheet) => StatefulBuilder(
      builder: (sheet, setSheet) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(sheet).viewInsets.bottom),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
            child: Column(
              key: const ValueKey('pv_list_edit_sheet'),
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit list',
                  style: pvFraunces(
                    fontSize: 21,
                    fontWeight: FontWeight.w500,
                    color: pal.ink1,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: name,
                  maxLength: PvListStore.maxNameLength,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    errorText: error,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                PvCommit(
                  label: 'Save name',
                  onTap: () {
                    if (PvListStore.instance.rename(list.id, name.text)) {
                      Navigator.of(sheet).pop();
                    } else {
                      setSheet(
                        () => error = name.text.trim().isEmpty
                            ? 'Give the list a name.'
                            : 'You already have a list with that name.',
                      );
                    }
                  },
                ),
                const SizedBox(height: 8),
                PvSecondary(
                  key: const ValueKey('pv_list_delete'),
                  label: confirmDelete
                      ? 'Tap again to delete "${list.name}"'
                      : 'Delete list',
                  icon: Icons.delete_outline_rounded,
                  onTap: () {
                    if (!confirmDelete) {
                      setSheet(() => confirmDelete = true);
                      return;
                    }
                    PvListStore.instance.delete(list.id);
                    Navigator.of(sheet).pop();
                  },
                ),
                if (confirmDelete)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Only the list goes. The products stay in the store '
                      'and in any other list or your hearts.',
                      style: pvManrope(fontSize: 12.5, color: pal.ink3),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    ),
  ).whenComplete(
    // Not at once: the closing sheet's TextField listens through its exit
    // animation, so the controller is freed after it (600ms).
    // Braces, not `=>`: returning the Future would make whenComplete wait for it.
    () {
      Future<void>.delayed(const Duration(milliseconds: 600), name.dispose);
    },
  );
}
