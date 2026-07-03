// =============================================================================
//  StorageImage — drop-in replacement for Image.file that resolves a stored
//  reference (a Supabase Storage object path OR a legacy local path) to a local
//  file, downloading + caching on demand. Shows a gentle loading box while it
//  fetches and a "broken image" placeholder if it can't be resolved.
//
//  Usage: StorageImage(entry.imageUrl, fit: BoxFit.cover, width: ..., ...)
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';

import '../services/remote/storage_service.dart';

class StorageImage extends StatefulWidget {
  const StorageImage(
    this.reference, {
    super.key,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
  });

  /// The stored reference (Storage object path or legacy local file path).
  final String reference;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  @override
  State<StorageImage> createState() => _StorageImageState();
}

class _StorageImageState extends State<StorageImage> {
  late Future<File?> _future;

  @override
  void initState() {
    super.initState();
    _future = StorageService.resolve(widget.reference);
  }

  @override
  void didUpdateWidget(covariant StorageImage old) {
    super.didUpdateWidget(old);
    if (old.reference != widget.reference) {
      _future = StorageService.resolve(widget.reference);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = FutureBuilder<File?>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return _box(loading: true);
        }
        final file = snap.data;
        if (file == null) return _box(loading: false);
        return Image.file(
          file,
          fit: widget.fit,
          width: widget.width,
          height: widget.height,
          // If the cached file is somehow unreadable, fall back gracefully.
          errorBuilder: (_, _, _) => _box(loading: false),
        );
      },
    );
    if (widget.borderRadius != null) {
      content = ClipRRect(borderRadius: widget.borderRadius!, child: content);
    }
    return content;
  }

  Widget _box({required bool loading}) => Container(
        width: widget.width,
        height: widget.height,
        color: const Color(0xFFEDEDED),
        alignment: Alignment.center,
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(Icons.image_not_supported_rounded,
                size: 22, color: Colors.grey.shade400),
      );
}
