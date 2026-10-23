import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/route_names.dart';
import '../../../../l10n/generated/app_localizations.dart';

class FullscreenGalleryRequest {
  final List<String> images;
  final int initialIndex;

  const FullscreenGalleryRequest({
    required this.images,
    required this.initialIndex,
  });
}

class FullscreenGalleryScreen extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const FullscreenGalleryScreen({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  @override
  State<FullscreenGalleryScreen> createState() =>
      _FullscreenGalleryScreenState();
}

class _FullscreenGalleryScreenState extends State<FullscreenGalleryScreen> {
  late final PageController _pageController;
  late int _currentIndex;

  int get _safeInitialIndex => widget.images.isEmpty
      ? 0
      : widget.initialIndex.clamp(0, widget.images.length - 1);

  @override
  void initState() {
    super.initState();
    _currentIndex = _safeInitialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        leading: IconButton(
          tooltip: l10n?.commonClose ?? 'Close',
          onPressed: _close,
          icon: const Icon(Icons.close),
        ),
        title: Text(
          widget.images.isEmpty
              ? (l10n?.galleryViewAll ?? 'Photos')
              : '${_currentIndex + 1} / ${widget.images.length}',
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: widget.images.isEmpty
          ? Center(
              child: Text(
                l10n?.detailsNoAmenities ?? 'No photos available.',
                style: const TextStyle(color: Colors.white70),
              ),
            )
          : PageView.builder(
              controller: _pageController,
              itemCount: widget.images.length,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              itemBuilder: (context, index) => InteractiveViewer(
                child: Center(
                  child: Image.network(
                    widget.images[index],
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.broken_image_outlined,
                          color: AppColors.textMuted,
                          size: 56,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'This photo could not be loaded.',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.brandGreen,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
    );
  }
}
