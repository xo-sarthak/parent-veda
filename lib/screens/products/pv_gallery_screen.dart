// =============================================================================
//  PvGalleryScreen — full-screen photos: swipe, pinch to zoom, double-tap
// -----------------------------------------------------------------------------
//  H&M / SSENSE's viewer: white page, close top-right, the counter under the
//  image. `InteractiveViewer` per page (the app already uses it in
//  photo_viewer_screen.dart), so no new dependency. A zoomed page hands the
//  horizontal drag to the viewer, not the PageView — that is what
//  `panEnabled` + the scale check below arrange.
// =============================================================================

import 'package:flutter/material.dart';

import '../../models/pv_product.dart';
import '../../theme/pv_fonts.dart';
import 'pv_store_chrome.dart';

class PvGalleryScreen extends StatefulWidget {
  const PvGalleryScreen({
    super.key,
    required this.product,
    this.initial = 0,
    this.frameZeroTag,
  });
  final PvProduct product;
  final int initial;

  /// The page's frame-0 tag (which may be the card's), so the zoom flies too.
  final String? frameZeroTag;

  @override
  State<PvGalleryScreen> createState() => _PvGalleryScreenState();
}

class _PvGalleryScreenState extends State<PvGalleryScreen> {
  late final PageController _pages = PageController(
    initialPage: widget.initial,
  );
  late int _page = widget.initial;
  final Map<int, TransformationController> _tc = {};
  bool _zoomed = false;

  TransformationController _ctl(int i) =>
      _tc.putIfAbsent(i, TransformationController.new);

  @override
  void dispose() {
    _pages.dispose();
    for (final c in _tc.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _toggleZoom(int i, Offset at) {
    final c = _ctl(i);
    if (c.value != Matrix4.identity()) {
      c.value = Matrix4.identity();
      setState(() => _zoomed = false);
    } else {
      final m = Matrix4.identity()
        ..translateByDouble(-at.dx * 1.5, -at.dy * 1.5, 0, 1)
        ..scaleByDouble(2.5, 2.5, 1, 1);
      c.value = m;
      setState(() => _zoomed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    final n = widget.product.images.length;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pages,
            physics: _zoomed
                ? const NeverScrollableScrollPhysics()
                : const PageScrollPhysics(),
            itemCount: n,
            onPageChanged: (i) => setState(() {
              _page = i;
              _zoomed = false;
            }),
            itemBuilder: (_, i) => GestureDetector(
              onDoubleTapDown: (d) => _toggleZoom(i, d.localPosition),
              child: InteractiveViewer(
                transformationController: _ctl(i),
                minScale: 1,
                maxScale: 4,
                onInteractionEnd: (_) => setState(
                  () => _zoomed = _ctl(i).value != Matrix4.identity(),
                ),
                child: Center(
                  child: Hero(
                    tag: i == 0 && widget.frameZeroTag != null
                        ? widget.frameZeroTag!
                        : 'pv_img_${widget.product.id}_$i',
                    child: PvProductImage(
                      product: widget.product,
                      index: i,
                      fit: BoxFit.contain,
                      radius: 0,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 16,
            child: PvRoundIcon(
              icon: Icons.close_rounded,
              onTap: () => Navigator.of(context).maybePop(),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: MediaQuery.of(context).padding.bottom + 24,
            child: Column(
              children: [
                if (n > 1)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < n; i++)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i == _page
                                ? p.ink1
                                : p.ink1.withValues(alpha: 0.25),
                          ),
                        ),
                    ],
                  ),
                const SizedBox(height: 8),
                Text(
                  '${_page + 1} of $n · pinch or double-tap to zoom',
                  style: pvManrope(fontSize: 12, color: p.ink3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
