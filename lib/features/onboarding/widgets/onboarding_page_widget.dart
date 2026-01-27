import 'package:flutter/material.dart';
import 'package:limitim/features/onboarding/models/onboarding_page_data.dart';

/// Reusable widget for displaying onboarding page content
class OnboardingPageWidget extends StatelessWidget {
  final OnboardingPageData pageData;

  const OnboardingPageWidget({super.key, required this.pageData});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),

          // Icon/Illustration
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              pageData.icon,
              size: 80,
              color:
                  pageData.iconColor ?? Theme.of(context).colorScheme.primary,
            ),
          ),

          const SizedBox(height: 48),

          // Title
          Text(
            pageData.title,
            style: Theme.of(
              context,
            ).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // Description
          Text(
            pageData.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const Spacer(flex: 3),
        ],
      ),
    );
  }
}
