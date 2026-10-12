import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_app/core/constants/app_assets.dart';
import 'package:real_estate_app/core/router/route_names.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  int _currentPage = 0;

  final List<OnboardingModel> _pages = [
    OnboardingModel(
      title: 'Find best place\nto stay in good price',
      description: 'Find your perfect place to stay with the best prices.',
      image: AppAssets.onboarding1,
    ),
    OnboardingModel(
      title: 'Fast sell your property\nin just one click',
      description: 'Sell your property easily and quickly with just one click.',
      image: AppAssets.onboarding2,
    ),
    OnboardingModel(
      title: 'Find perfect choice for\nyour future house',
      description: 'Discover the perfect home that matches your needs.',
      image: AppAssets.onboarding3,
    ),
  ];

  // void _nextPage() {
  //   if (_currentPage < _pages.length - 1) {
  //     _pageController.nextPage(
  //       duration: const Duration(milliseconds: 300),
  //       curve: Curves.easeInOut,
  //     );
  //   } else {
  //     // Navigate to your Home / Login screen
  //     // Navigator.pushReplacement(...);
  //   }
  // }

  // void _skip() {
  //   // Navigate to your Home / Login screen
  //   // Navigator.pushReplacement(...);
  // }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_completed_onboarding', true);
    if (mounted) {
      context.go(AppRoutes.welcome);
    }
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skip() {
    _completeOnboarding();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: PageView.builder(
          controller: _pageController,
          itemCount: _pages.length,
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
          itemBuilder: (context, index) {
            return _buildOnboardingPage(_pages[index]);
          },
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingModel page) {
    final size = MediaQuery.sizeOf(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Logo
                Image.asset(
                  'assets/images/Mask group.png',
                  width: 88,
                  height: 60,
                  fit: BoxFit.contain,
                ),

                // Skip
                GestureDetector(
                  onTap: _skip,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E5E5),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Text(
                      'skip',
                      style: TextStyle(color: Color(0xFF666666), fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 27,
                  height: 1.45,
                  color: Color(0xFF17254D),
                  fontWeight: FontWeight.w600,
                ),
                children: _buildTitleSpans(page.title),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              page.description,
              style: const TextStyle(
                fontSize: 13,
                height: 1.6,
                color: Color(0xFF777777),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Image + Bottom controls
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(page.image, fit: BoxFit.cover),

                    // Bottom gradient
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: 180,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Color(0x99000000)],
                          ),
                        ),
                      ),
                    ),

                    // Bottom controls
                    Positioned(
                      bottom: 28,
                      left: 20,
                      right: 20,
                      child: Row(
                        children: [
                          // Back button
                          if (_currentPage > 0)
                            GestureDetector(
                              onTap: () {
                                _pageController.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                              child: Container(
                                width: 58,
                                height: 58,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.arrow_back_ios_new,
                                  size: 20,
                                  color: Color(0xFF17254D),
                                ),
                              ),
                            )
                          else
                            const SizedBox(width: 58),

                          const SizedBox(width: 16),

                          // Next button
                          Expanded(
                            child: GestureDetector(
                              onTap: _nextPage,
                              child: Container(
                                height: 58,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF72D600),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    _currentPage == _pages.length - 1
                                        ? 'Get Started'
                                        : 'Next',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Page indicator
                    Positioned(
                      bottom: 100,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_pages.length, (index) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentPage == index ? 48 : 16,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: size.height * 0.015),
        ],
      ),
    );
  }

  List<TextSpan> _buildTitleSpans(String title) {
    final words = title.split(' ');

    return words.map((word) {
      final isHighlighted = [
        'good',
        'price',
        'one',
        'click',
        'perfect',
        'choice',
      ].contains(word);

      return TextSpan(
        text: '$word ',
        style: TextStyle(
          color: isHighlighted
              ? const Color(0xFF1D5270)
              : const Color(0xFF17254D),
          fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w400,
        ),
      );
    }).toList();
  }
}

class OnboardingModel {
  final String title;
  final String description;
  final String image;

  OnboardingModel({
    required this.title,
    required this.description,
    required this.image,
  });
}
