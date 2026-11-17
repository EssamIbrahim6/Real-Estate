import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';

class ImageGallery extends StatefulWidget {
  final String coverImage;
  final List<String> images;
  final ValueChanged<int>? onImageTap;
  final ValueChanged<int>? onViewAll;

  const ImageGallery({
    super.key,
    required this.coverImage,
    required this.images,
    this.onImageTap,
    this.onViewAll,
  });

  static List<String> collectImages(String coverImage, List<String> images) {
    final list = <String>[];
    final seen = <String>{};
    for (final image in [coverImage, ...images]) {
      if (image.trim().isNotEmpty && seen.add(image)) {
        list.add(image);
      }
    }
    return list;
  }

  @override
  State<ImageGallery> createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<ImageGallery> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  List<String> get _allImages =>
      ImageGallery.collectImages(widget.coverImage, widget.images);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = _allImages;
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final heroHeight = (MediaQuery.sizeOf(context).height * 0.4)
        .clamp(280.0, 420.0)
        .toDouble();
    return Column(
      children: [
        SizedBox(
          height: heroHeight,
          width: double.infinity,
          child: images.isEmpty
              ? Container(
                  color: colors.surfaceContainerLow,
                  child: const Icon(Icons.home_work_outlined, size: 64),
                )
              : ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(26),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      PageView.builder(
                        controller: _pageController,
                        itemCount: images.length,
                        onPageChanged: (index) =>
                            setState(() => _currentIndex = index),
                        itemBuilder: (context, index) => GestureDetector(
                          onTap: () => widget.onImageTap?.call(index),
                          child: Image.network(
                            images[index],
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  color: colors.surfaceContainerLow,
                                  child: Icon(
                                    Icons.broken_image_outlined,
                                    size: 48,
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return Container(
                                color: colors.surfaceContainerLow,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: colors.primary,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.12),
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.42),
                              ],
                              stops: const [0, 0.48, 1],
                            ),
                          ),
                        ),
                      ),
                      if (images.length > 1)
                        PositionedDirectional(
                          bottom: 16,
                          start: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.62),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.24),
                              ),
                            ),
                            child: Text(
                              '${_currentIndex + 1} / ${images.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      if (widget.onViewAll != null)
                        PositionedDirectional(
                          bottom: 12,
                          end: 16,
                          child: TextButton.icon(
                            onPressed: () =>
                                widget.onViewAll?.call(_currentIndex),
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.black.withValues(
                                alpha: 0.62,
                              ),
                              foregroundColor: Colors.white,
                              shape: const StadiumBorder(),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                            ),
                            icon: const Icon(Icons.photo_library_outlined),
                            label: Text(
                              l10n?.galleryViewAll ?? 'View all photos',
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
        ),
        if (images.length > 1)
          SizedBox(
            height: 88,
            child: ListView.separated(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 10, 16, 10),
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final isSelected = index == _currentIndex;
                return GestureDetector(
                  onTap: () => widget.onImageTap?.call(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: isSelected
                            ? colors.primary
                            : colors.outlineVariant,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: SizedBox(
                        width: 82,
                        child: Image.network(
                          images[index],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: colors.surfaceContainerLow,
                                child: Icon(
                                  Icons.broken_image_outlined,
                                  color: colors.onSurfaceVariant,
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
    );
  }
}
