// =============================================================================
//  PhotoViewerScreen — full-screen memory photo with a week badge + date.
// =============================================================================

import 'package:flutter/material.dart';

import '../localization/app_language.dart';
import '../models/memory_models.dart';
import '../widgets/storage_image.dart';

class PhotoViewerScreen extends StatelessWidget {
  const PhotoViewerScreen({super.key, required this.photo, required this.lang});

  final PhotoMemory photo;
  final AppLanguage lang;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        leading: const BackButton(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: InteractiveViewer(
              minScale: 1,
              maxScale: 4,
              child: StorageImage(photo.path, fit: BoxFit.contain),
            ),
          ),
          Positioned(
            left: 20,
            bottom: 32,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    lang.isEnglish ? 'Week ${photo.week}' : 'Hafta ${photo.week}',
                    style: text.labelLarge?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Text(photo.dateIso,
                      style: text.labelMedium?.copyWith(color: Colors.white70)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
