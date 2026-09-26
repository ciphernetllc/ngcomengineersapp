import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _sliderData = [
    {
      "image": "assets/images/eng1.jpg",
      "title": "Fast & Reliable\nConnection",
      "subtitle": "Experience high-speed internet that keeps you connected to what matters most."
    },
    {
      "image": "assets/images/eng2.png",
      "title": "Unlimited Data\nPlans",
      "subtitle": "Choose from our range of unlimited plans tailored to your needs and budget."
    },
    {
      "image": "assets/images/ngcom_logo.webp",
      "title": "24/7 Dedicated\nSupport",
      "subtitle": "Our team is always available to ensure your connection remains seamless."
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _sliderData.length,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      _sliderData[index]['image']!,
                      height: 300,
                      fit: BoxFit.contain,
                    ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                    const SizedBox(height: 60),
                    Text(
                      _sliderData[index]['title']!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            height: 1.2,
                            color: AppTheme.secondaryColor,
                          ),
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
                    const SizedBox(height: 20),
                    Text(
                      _sliderData[index]['subtitle']!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.secondaryColor.withValues(alpha: 0.6),
                          ),
                    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
                  ],
                ),
              );
            },
          ),
          Positioned(
            bottom: 60,
            left: 40,
            right: 40,
            child: Column(
              children: [
                SmoothPageIndicator(
                  controller: _pageController,
                  count: _sliderData.length,
                  effect: const ExpandingDotsEffect(
                    activeDotColor: AppTheme.primaryColor,
                    dotColor: Color(0xFFE0E0E0),
                    dotHeight: 8,
                    dotWidth: 8,
                    expansionFactor: 4,
                    spacing: 8,
                  ),
                ),
                const SizedBox(height: 40),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _currentPage == _sliderData.length - 1
                      ? ElevatedButton(
                          key: const ValueKey('get_started'),
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          child: const Text('Get Started'),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () {
                                _pageController.jumpToPage(_sliderData.length - 1);
                              },
                              child: Text(
                                'Skip',
                                style: TextStyle(color: AppTheme.secondaryColor.withValues(alpha: 0.5)),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: const BoxDecoration(
                                  color: AppTheme.primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.arrow_forward, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
