import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class IntroCarouselScreen extends StatefulWidget {
  const IntroCarouselScreen({super.key});

  @override
  State<IntroCarouselScreen> createState() => _IntroCarouselScreenState();
}

class _IntroCarouselScreenState extends State<IntroCarouselScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  final _pages = const [
    _IntroPageData(
      imageUrl:
          'https://images.unsplash.com/photo-1514525253440-b393452e2729?auto=format&fit=crop&w=1000&q=80',
      title: 'Discover Events',
      subtitle:
          'Never miss out on local festivals, concerts, and community gatherings in your area',
    ),
    _IntroPageData(
      imageUrl:
          'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=1000&q=80',
      title: 'Find great deals',
      subtitle:
          'Stay updated on special promotions, discounts, and exclusive offers from local spots',
    ),
    _IntroPageData(
      imageUrl:
          'https://images.unsplash.com/photo-1514933651103-005eec06c04b?auto=format&fit=crop&w=1000&q=80',
      title: 'Join the community',
      subtitle:
          'Start exploring and connecting with local businesses and events in your neighborhood',
    ),
    _IntroPageData(
      imageUrl:
          'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=1000&q=80',
      title: "Who's Got What?",
      subtitle: 'Welcome to your community. See what\'s happening around you right now.',
    ),
  ];

  @override
  void initState() {
  super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      int nextPage = _currentPage + 1;
      if (nextPage >= _pages.length) {
        // Stop auto-scrolling on the last page
        _timer?.cancel();
        return;
      }
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
              if (index < _pages.length - 1) {
                _startAutoScroll();
              } else {
                _timer?.cancel();
              }
            },
            itemBuilder: (context, index) {
              final page = _pages[index];
              final isLast = index == _pages.length - 1;
              return _IntroPage(
                data: page,
                showCta: isLast,
              );
            },
          ),
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 8,
                      width: _currentPage == index ? 24 : 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? Colors.white
                            : Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (_currentPage == _pages.length - 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => context.go('/onboarding'),
                        child: const Text("Start seeing Who's Got What now!"),
                      ),
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

class _IntroPageData {
  final String imageUrl;
  final String title;
  final String subtitle;

  const _IntroPageData({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
  });
}

class _IntroPage extends StatelessWidget {
  final _IntroPageData data;
  final bool showCta;

  const _IntroPage({
    required this.data,
    required this.showCta,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          data.imageUrl,
          fit: BoxFit.cover,
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.2),
                Colors.black.withOpacity(0.6),
              ],
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  data.subtitle,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
