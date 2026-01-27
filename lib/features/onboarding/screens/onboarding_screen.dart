import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:limitim/features/onboarding/cubit/onboarding_cubit.dart';
import 'package:limitim/features/onboarding/models/onboarding_page_data.dart';
import 'package:limitim/features/onboarding/widgets/onboarding_page_widget.dart';
import 'package:limitim/features/onboarding/widgets/page_indicator.dart';

/// Main onboarding screen with PageView
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final List<OnboardingPageData> _pages = OnboardingPageData.pages;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
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

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _completeOnboarding() {
    context.read<OnboardingCubit>().completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top navigation bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  if (_currentPage > 0)
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: _previousPage,
                    )
                  else
                    const SizedBox(width: 48),

                  // Skip button
                  if (!isLastPage)
                    TextButton(
                      onPressed: _completeOnboarding,
                      child: Text(
                        'Atla',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    )
                  else
                    const SizedBox(width: 48),
                ],
              ),
            ),

            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return OnboardingPageWidget(pageData: _pages[index]);
                },
              ),
            ),

            // Bottom section: Indicator and Next button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                children: [
                  // Page indicator
                  PageIndicator(
                    currentPage: _currentPage,
                    pageCount: _pages.length,
                  ),

                  const SizedBox(height: 32),

                  // Next/Start button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        isLastPage ? 'Başlayalım' : 'Devam',
                        style: TextStyle(
                          fontSize: Theme.of(
                            context,
                          ).textTheme.titleMedium?.fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
