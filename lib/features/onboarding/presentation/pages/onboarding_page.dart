import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/forest_colors.dart';
import '../../../../core/widgets/forest_button.dart';
import '../cubit/onboarding_cubit.dart';
import '../onboarding_tips.dart';
import '../widgets/page_dots.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key, required this.onFinished});

  /// Called once the user finishes or skips the tips.
  final VoidCallback onFinished;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  static const _pageTransition = Duration(milliseconds: 300);

  final _controller = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onStateChanged(BuildContext context, OnboardingState state) {
    if (state.completed) {
      widget.onFinished();
      return;
    }
    // Swipes already moved the PageView; only button taps need animating.
    if (_controller.hasClients && _controller.page?.round() != state.page) {
      _controller.animateToPage(
        state.page,
        duration: _pageTransition,
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OnboardingCubit>();
    return BlocConsumer<OnboardingCubit, OnboardingState>(
      listener: _onStateChanged,
      builder: (context, state) => Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: Visibility(
                    visible: !state.isLastPage,
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    child: TextButton(
                      onPressed: cubit.complete,
                      style: TextButton.styleFrom(
                        foregroundColor: ForestColors.forestGreen,
                      ),
                      child: const Text('Skip'),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: onboardingTips.length,
                  onPageChanged: cubit.pageChanged,
                  itemBuilder: (_, index) =>
                      _TipView(tip: onboardingTips[index]),
                ),
              ),
              PageDots(count: onboardingTips.length, current: state.page),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: SizedBox(
                  width: double.infinity,
                  child: ForestButton(
                    label: state.isLastPage ? "Let's go" : 'Next',
                    icon: state.isLastPage ? null : Icons.arrow_forward,
                    onPressed: cubit.next,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TipView extends StatelessWidget {
  const _TipView({required this.tip});

  final OnboardingTip tip;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: ForestColors.mistGreen,
                shape: BoxShape.circle,
                border: Border.all(
                  color: ForestColors.forestGreen,
                  width: AppTheme.borderWidth,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: ForestColors.forestGreen,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(tip.icon, size: 72, color: ForestColors.pineGreen),
            ),
            const SizedBox(height: 40),
            Text(
              tip.title.toUpperCase(),
              textAlign: TextAlign.center,
              style: ForestText.display(fontSize: 30),
            ),
            const SizedBox(height: 12),
            Text(
              tip.message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: ForestColors.darkGray,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
