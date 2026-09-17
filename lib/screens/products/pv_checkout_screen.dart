// =============================================================================
//  PvCheckoutScreen — address · payment · summary · Place order
// -----------------------------------------------------------------------------
//  One screen, the foodpanda / adidas spine: where it goes, how it is paid,
//  what it costs, one button. The address picker is CRED's sheet ("where
//  should we deliver your order?" · radio list · + Add new); the add form is
//  the adidas one, phone last.
//
//  ⚠️ THE ORDER'S STATUS COMES FROM THE PAYMENT, NEVER FROM THE TAP.
//    paid           → PaymentService verified Razorpay's signature server-side
//    notConfigured  → the payment stack is unreachable; the order is minted as
//                     `preview`, the copy says no money moved, nothing ships
//    cancelled      → nothing minted; she is told, quietly
//    failed         → nothing minted; the reason is shown
//
//  The lines go to the edge function so the SERVER prices the order from the
//  products table ("money is decided server-side"); when it cannot, it charges
//  the phone's figure and marks the Razorpay order `priced_by: client`.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../booking/payment_service.dart';
import '../../models/pv_product.dart';
import '../../services/cart_store.dart';
import '../../services/pv_catalog_store.dart';
import '../../services/pv_order_store.dart';
import '../../services/remote/supabase_repo.dart';
import '../../theme/pv_fonts.dart';
import '../v2/v2_palette.dart';
import 'pv_order_placed_screen.dart';
import 'pv_store_chrome.dart';

class PvCheckoutScreen extends StatefulWidget {
  const PvCheckoutScreen({super.key});

  @override
  State<PvCheckoutScreen> createState() => _PvCheckoutScreenState();
}

class _PvCheckoutScreenState extends State<PvCheckoutScreen> {
  bool _busy = false;
  PvAddress? _chosen;

  @override
  void initState() {
    super.initState();
    PvOrderStore.instance.init();
  }

  PvAddress? get _address => _chosen ?? PvOrderStore.instance.defaultAddress;

  // ---- the commit --------------------------------------------------------------

  Future<void> _place() async {
    final address = _address;
    if (address == null) {
      await _pickAddress();
      return;
    }
    final cart = CartStore.instance;
    final lines = cart.items(kProductsCartId);
    if (lines.isEmpty) return;
    final subtotal = cart.subtotal(kProductsCartId);
    final total = subtotal + PvOrderStore.deliveryFor(subtotal);

    setState(() => _busy = true);
    final result = await PaymentService.instance.pay(
      amountMinor: (total * 100).round(),
      title: lines.length == 1
          ? lines.first.name
          : '${lines.length} items from ParentVeda',
      reference: 'cart',
      email: SupabaseRepo.userEmail,
      // Razorpay prefills the contact only with a country code (found on the
      // phone: a bare ten-digit number left the field empty).
      contact: address.phone.length == 10
          ? '+91${address.phone}'
          : address.phone,
      lines: [
        for (final l in lines)
          {
            'productId': l.productId,
            'qty': l.qty,
            if (l.size.isNotEmpty) 'variantId': _variantIdFor(l),
          },
      ],
    );
    if (!mounted) return;
    setState(() => _busy = false);

    switch (result.outcome) {
      case PaymentOutcome.paid:
        final o = PvOrderStore.instance.place(
          lines: lines,
          address: address,
          status: PvOrderStatus.paid,
          paymentId: result.paymentId,
        );
        cart.clear(kProductsCartId);
        _done(o);
      case PaymentOutcome.notConfigured:
        final o = PvOrderStore.instance.place(
          lines: lines,
          address: address,
          status: PvOrderStatus.preview,
        );
        cart.clear(kProductsCartId);
        _done(o);
      case PaymentOutcome.free:
        final o = PvOrderStore.instance.place(
          lines: lines,
          address: address,
          status: PvOrderStatus.paid,
        );
        cart.clear(kProductsCartId);
        _done(o);
      case PaymentOutcome.cancelled:
        pvSnack(context, 'Payment cancelled — your bag is still here.');
      case PaymentOutcome.failed:
        pvSnack(
          context,
          result.message ?? 'Payment failed. Nothing was charged.',
        );
    }
  }

  /// The variant id the server prices from: the product's variant whose label
  /// matches the cart line's size. Empty when there is none.
  String _variantIdFor(CartItem l) {
    final p = PvCatalogStore.instance.byId(l.productId);
    if (p == null) return '';
    for (final v in p.variants) {
      if (v.label == l.size) return v.id;
    }
    return '';
  }

  void _done(PvOrder o) => Navigator.of(context).pushReplacement(
    MaterialPageRoute<void>(
      builder: (_) => PvOrderPlacedScreen(orderId: o.id),
      settings: const RouteSettings(name: 'store/placed'),
    ),
  );

  // ---- address -----------------------------------------------------------------

  Future<void> _pickAddress() async {
    final p = pvStorePalette;
    final store = PvOrderStore.instance;
    if (store.addresses.isEmpty) {
      await _addAddress();
      return;
    }
    final picked = await showModalBottomSheet<PvAddress>(
      context: context,
      backgroundColor: p.ground,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Where should we deliver?',
                      style: pvFraunces(
                        fontSize: 21,
                        fontWeight: FontWeight.w500,
                        color: p.ink1,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      Navigator.of(ctx).pop();
                      await _addAddress();
                    },
                    child: Text(
                      '+ Add new',
                      style: pvManrope(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: p.action,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              for (final a in store.addresses)
                InkWell(
                  onTap: () => Navigator.of(ctx).pop(a),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: a.id == _address?.id ? p.ink1 : kPvLine,
                        width: a.id == _address?.id ? 1.4 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          a.id == _address?.id
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_off_rounded,
                          size: 20,
                          color: p.ink1,
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: _addressText(p, a)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    if (picked != null && mounted) {
      PvOrderStore.instance.setDefault(picked.id);
      setState(() => _chosen = picked);
    }
  }

  Future<void> _addAddress() async {
    final a = await showModalBottomSheet<PvAddress>(
      context: context,
      isScrollControlled: true,
      backgroundColor: pvStorePalette.ground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _AddressForm(),
    );
    if (a != null && mounted) {
      PvOrderStore.instance.saveAddress(a);
      setState(() => _chosen = a);
    }
  }

  Widget _addressText(V2Palette p, PvAddress a) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Text(
            a.name,
            style: pvManrope(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: p.ink1,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: p.surfaceAlt,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              a.label,
              style: pvManrope(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: p.ink2,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 3),
      Text(
        a.oneLine,
        style: pvManrope(fontSize: 13, height: 1.4, color: p.ink2),
      ),
      Text(a.phone, style: pvManrope(fontSize: 12.5, color: p.ink3)),
    ],
  );

  // ---- build --------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return ListenableBuilder(
      listenable: Listenable.merge([CartStore.instance, PvOrderStore.instance]),
      builder: (context, _) {
        final cart = CartStore.instance;
        final lines = cart.items(kProductsCartId);
        final subtotal = cart.subtotal(kProductsCartId);
        final delivery = PvOrderStore.deliveryFor(subtotal);
        final total = subtotal + delivery;
        final address = _address;
        return Scaffold(
          backgroundColor: p.ground,
          body: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        16,
                        MediaQuery.of(context).padding.top + 10,
                        16,
                        8,
                      ),
                      child: Row(
                        children: [
                          PvRoundIcon(
                            icon: Icons.arrow_back_rounded,
                            onTap: () => Navigator.of(context).maybePop(),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Checkout',
                              style: pvFraunces(
                                fontSize: 24,
                                fontWeight: FontWeight.w500,
                                color: p.ink1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    sliver: SliverList.list(
                      children: [
                        _block(
                          p,
                          'Deliver to',
                          action: address == null ? 'Add' : 'Change',
                          onAction: _pickAddress,
                          child: address == null
                              ? Text(
                                  'Add a delivery address to continue.',
                                  style: pvManrope(fontSize: 14, color: p.ink2),
                                )
                              : _addressText(p, address),
                        ),
                        const SizedBox(height: 12),
                        _block(
                          p,
                          'Payment',
                          child: Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: p.surfaceAlt,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.lock_outline_rounded,
                                  size: 18,
                                  color: p.ink1,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Razorpay secure checkout',
                                      style: pvManrope(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: p.ink1,
                                      ),
                                    ),
                                    Text(
                                      'UPI · cards · net banking · wallets. Opens on Place order.',
                                      style: pvManrope(
                                        fontSize: 12.5,
                                        height: 1.4,
                                        color: p.ink3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        _block(
                          p,
                          'Order summary',
                          child: Column(
                            children: [
                              for (final l in lines)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      Text(
                                        '${l.qty}×',
                                        style: pvManrope(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: p.ink3,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          l.size.isEmpty
                                              ? l.name
                                              : '${l.name} · ${l.size}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: pvManrope(
                                            fontSize: 13.5,
                                            color: p.ink1,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '₹${PvProduct.groupRupees(l.lineTotal.round())}',
                                        style: pvManrope(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w700,
                                          color: p.ink1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              const Divider(height: 14),
                              _sum(
                                p,
                                'Subtotal',
                                '₹${PvProduct.groupRupees(subtotal.round())}',
                              ),
                              _sum(
                                p,
                                'Delivery',
                                delivery == 0 ? 'Free' : '₹${delivery.round()}',
                              ),
                              const Divider(height: 14),
                              _sum(
                                p,
                                'Total',
                                '₹${PvProduct.groupRupees(total.round())}',
                                bold: true,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'By placing the order you agree to our terms. Unopened items can be returned within 7 days. The amount is confirmed by our server before payment opens.',
                          style: pvManrope(
                            fontSize: 11.5,
                            height: 1.5,
                            color: p.ink3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 120)),
                ],
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    12,
                    16,
                    MediaQuery.of(context).padding.bottom + 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: kPvLine)),
                  ),
                  child: PvCommit(
                    label: address == null
                        ? 'Add address to continue'
                        : 'Place order',
                    trailing: address == null
                        ? null
                        : '₹${PvProduct.groupRupees(total.round())}',
                    busy: _busy,
                    onTap: lines.isEmpty ? null : _place,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _block(
    V2Palette p,
    String title, {
    required Widget child,
    String? action,
    VoidCallback? onAction,
  }) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: kPvLine),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title.toUpperCase(),
                style: pvManrope(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: p.ink3,
                ),
              ),
            ),
            if (action != null)
              InkWell(
                onTap: onAction,
                child: Text(
                  action,
                  style: pvManrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: p.action,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        child,
      ],
    ),
  );

  Widget _sum(V2Palette p, String k, String v, {bool bold = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      children: [
        Expanded(
          child: Text(
            k,
            style: pvManrope(
              fontSize: 14,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
              color: bold ? p.ink1 : p.ink2,
            ),
          ),
        ),
        Text(
          v,
          style: pvManrope(
            fontSize: bold ? 17 : 14,
            fontWeight: FontWeight.w800,
            color: p.ink1,
          ),
        ),
      ],
    ),
  );
}

/// The add-address form. Every field required except the second line; the
/// PIN is six digits, the phone ten. Saved as the default.
class _AddressForm extends StatefulWidget {
  const _AddressForm();

  @override
  State<_AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends State<_AddressForm> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _l1 = TextEditingController();
  final _l2 = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _pin = TextEditingController();
  String _label = 'Home';

  @override
  void dispose() {
    for (final c in [_name, _phone, _l1, _l2, _city, _state, _pin]) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _valid =>
      _name.text.trim().isNotEmpty &&
      _phone.text.trim().length == 10 &&
      _l1.text.trim().isNotEmpty &&
      _city.text.trim().isNotEmpty &&
      _state.text.trim().isNotEmpty &&
      _pin.text.trim().length == 6;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Add an address',
                      style: pvFraunces(
                        fontSize: 21,
                        fontWeight: FontWeight.w500,
                        color: p.ink1,
                      ),
                    ),
                  ),
                  PvRoundIcon(
                    icon: Icons.close_rounded,
                    size: 34,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _field(p, _name, 'Full name', TextInputType.name),
              _field(
                p,
                _l1,
                'House, building, street',
                TextInputType.streetAddress,
              ),
              _field(
                p,
                _l2,
                'Area, landmark (optional)',
                TextInputType.streetAddress,
              ),
              Row(
                children: [
                  Expanded(child: _field(p, _city, 'City', TextInputType.text)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _field(p, _state, 'State', TextInputType.text),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _field(
                      p,
                      _pin,
                      'PIN code',
                      TextInputType.number,
                      maxLen: 6,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _field(
                      p,
                      _phone,
                      'Phone',
                      TextInputType.phone,
                      maxLen: 10,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                children: [
                  for (final l in const ['Home', 'Work', 'Other'])
                    PvChip(
                      label: l,
                      selected: _label == l,
                      onTap: () => setState(() => _label = l),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              PvCommit(
                label: 'Save address',
                onTap: _valid
                    ? () => Navigator.of(context).pop(
                        PvAddress(
                          id: 'addr_${DateTime.now().microsecondsSinceEpoch}',
                          name: _name.text.trim(),
                          phone: _phone.text.trim(),
                          line1: _l1.text.trim(),
                          line2: _l2.text.trim(),
                          city: _city.text.trim(),
                          state: _state.text.trim(),
                          pin: _pin.text.trim(),
                          label: _label,
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    V2Palette p,
    TextEditingController c,
    String hint,
    TextInputType type, {
    int? maxLen,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextField(
      controller: c,
      keyboardType: type,
      maxLength: maxLen,
      inputFormatters:
          type == TextInputType.number || type == TextInputType.phone
          ? [FilteringTextInputFormatter.digitsOnly]
          : null,
      onChanged: (_) => setState(() {}),
      style: pvManrope(fontSize: 15, color: p.ink1),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: pvManrope(fontSize: 14, color: p.ink3),
        counterText: '',
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: kPvLine),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: p.ink1, width: 1.4),
        ),
      ),
    ),
  );
}
