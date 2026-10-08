import 'package:flutter/material.dart';

class OnboardingTip {
  const OnboardingTip({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;
}

const onboardingTips = [
  OnboardingTip(
    icon: Icons.sports_bar,
    title: 'Explore breweries',
    message:
        'Scroll through breweries from Open Brewery DB. More load '
        'automatically as you reach the end of the list.',
  ),
  OnboardingTip(
    icon: Icons.search,
    title: 'Search as you type',
    message:
        'Look up a brewery by name or city. Results update as soon as you '
        'pause typing.',
  ),
  OnboardingTip(
    icon: Icons.storefront,
    title: 'Visit or call',
    message:
        'Open a brewery to see its address, then call it or visit its '
        'website with one tap.',
  ),
];
