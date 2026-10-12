import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

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
    return Column(
      children: [
        SizedBox(
          height: 320,
          width: double.infinity,
          child: images.isEmpty
              ? Container(
                  color: AppColors.inputBackground,
                  child: const Icon(
                    Icons.home_work_outlined,
                    size: 64,
                    color: AppColors.textMuted,
                  ),
                )
              : Stack(
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
                                color: AppColors.inputBackground,
                                child: const Icon(
                                  Icons.broken_image_outlined,
                                  size: 48,
                                  color: AppColors.textMuted,
                                ),
                              ),
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Container(
                              color: AppColors.inputBackground,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    if (widget.onViewAll != null)
                      Positioned(
                        right: 16,
                        bottom: 12,
                        child: TextButton.icon(
                          onPressed: () =>
                              widget.onViewAll?.call(_currentIndex),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.black54,
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.photo_library_outlined),
                          label: const Text('View all photos'),
                        ),
                      ),
                    if (images.length > 1)
                      Positioned(
                        bottom: 22,
                        left: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_currentIndex + 1} / ${images.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
        ),
        if (images.length > 1)
          SizedBox(
            height: 76,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) => GestureDetector(
                onTap: () => widget.onImageTap?.call(index),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 76,
                    child: Image.network(
                      images[index],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.inputBackground,
                        child: const Icon(
                          Icons.broken_image_outlined,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
