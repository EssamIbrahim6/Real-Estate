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
      body: SafeArea(
        child: widget.images.isEmpty
            ? Center(
                child: Text(
                  l10n?.galleryEmpty ?? 'No photos available',
                  style: const TextStyle(color: Colors.white70),
                ),
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 8),
                    child: Row(
                      children: [
                        IconButton(
                          tooltip: l10n?.commonClose ?? 'Close',
                          onPressed: _close,
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.12,
                            ),
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.close_rounded),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.14),
                            ),
                          ),
                          child: Text(
                            '${_currentIndex + 1} / ${widget.images.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: widget.images.length,
                      onPageChanged: (index) =>
                          setState(() => _currentIndex = index),
                      itemBuilder: (context, index) => InteractiveViewer(
                        child: Center(
                          child: Image.network(
                            widget.images[index],
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.broken_image_outlined,
                                      color: Colors.white54,
                                      size: 56,
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      l10n?.galleryImageLoadError ??
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
                  ),
                  if (widget.images.length > 1)
                    SizedBox(
                      height: 88,
                      child: ListView.separated(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          16,
                          10,
                          16,
                          12,
                        ),
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.images.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final selected = index == _currentIndex;
                          return GestureDetector(
                            onTap: () => _pageController.animateToPage(
                              index,
                              duration: const Duration(milliseconds: 260),
                              curve: Curves.easeOutCubic,
                            ),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: selected
                                      ? Colors.white
                                      : Colors.white.withValues(alpha: 0.28),
                                  width: selected ? 2 : 1,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: SizedBox(
                                  width: 82,
                                  child: Image.network(
                                    widget.images[index],
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => const ColoredBox(
                                      color: Color(0xFF242424),
                                      child: Icon(
                                        Icons.broken_image_outlined,
                                        color: Colors.white54,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
