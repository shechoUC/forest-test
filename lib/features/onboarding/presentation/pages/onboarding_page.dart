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

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  static const _pageTransition = Duration(milliseconds: 300);

  final _controller = PageController();

  /// Fills the current dot and moves on to the next tip when it completes.
  late final AnimationController _progress =
      AnimationController(vsync: this, duration: kOnboardingTipDuration)
        ..addStatusListener(_onProgressStatus)
        ..forward();

  /// True while the user's finger is on the PageView; the timer pauses.
  bool _dragging = false;

  @override
  void dispose() {
    _progress.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onProgressStatus(AnimationStatus status) {
    final cubit = context.read<OnboardingCubit>();
    // The last tip waits for "Let's go" instead of leaving on its own.
    if (status.isCompleted && !cubit.state.isLastPage) cubit.next();
  }

  void _restartProgress() {
    _progress.value = 0;
    if (!_dragging) _progress.forward();
  }

  bool _onScroll(ScrollNotification notification) {
    if (notification is ScrollStartNotification &&
        notification.dragDetails != null) {
      _dragging = true;
      _progress.stop();
    } else if (notification is ScrollEndNotification && _dragging) {
      _dragging = false;
      if (!_progress.isCompleted) _progress.forward();
    }
    return false;
  }

  void _onStateChanged(BuildContext context, OnboardingState state) {
    if (state.completed) {
      _progress.stop();
      widget.onFinished();
      return;
    }
    _restartProgress();
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
                child: NotificationListener<ScrollNotification>(
                  onNotification: _onScroll,
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: onboardingTips.length,
                    onPageChanged: cubit.pageChanged,
                    itemBuilder: (_, index) =>
                        _TipView(tip: onboardingTips[index]),
                  ),
                ),
              ),
              PageDots(
                count: onboardingTips.length,
                current: state.page,
                progress: _progress,
              ),
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
              style: Theme.of(context).textTheme.bodyLarge
                  ?.copyWith(color: ForestColors.darkGray),
            ),
          ],
        ),
      ),
    );
  }
}
