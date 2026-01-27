import 'package:flutter/material.dart';

/// Data model for onboarding page content
class OnboardingPageData {
  final IconData icon;
  final String title;
  final String description;
  final Color? iconColor;

  const OnboardingPageData({
    required this.icon,
    required this.title,
    required this.description,
    this.iconColor,
  });

  /// Predefined onboarding pages for the app
  static List<OnboardingPageData> get pages => [
    // Page 1: Welcome
    const OnboardingPageData(
      icon: Icons.account_balance_wallet_rounded,
      title: 'Limitim\'e Hoş Geldiniz',
      description:
          'Aylık bütçenizi kolayca yönetin, harcamalarınızı takip edin ve finansal hedeflerinize ulaşın.',
    ),

    // Page 2: Set Budget
    const OnboardingPageData(
      icon: Icons.attach_money_outlined,
      title: 'Bütçenizi Belirleyin',
      description:
          'Her ay için harcama limitinizi belirleyin. Uygulama size ne kadar bütçeniz kaldığını anlık olarak gösterir.',
    ),

    // Page 3: Track Expenses
    const OnboardingPageData(
      icon: Icons.receipt_long_outlined,
      title: 'Harcamalarınızı Kaydedin',
      description:
          'Her harcamanızı kolayca ekleyin, düzenleyin ve takip edin. Takvim görünümünde günlük harcamalarınızı inceleyin.',
    ),

    // Page 4: Review History
    const OnboardingPageData(
      icon: Icons.analytics_outlined,
      title: 'Geçmişinizi İnceleyin',
      description:
          'Tamamlanan bütçe dönemlerinizi arşivde saklayın ve harcama alışkanlıklarınızı analiz edin.',
    ),
  ];
}
