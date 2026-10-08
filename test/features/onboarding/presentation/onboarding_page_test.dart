import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forest_test/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:forest_test/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:forest_test/features/onboarding/presentation/onboarding_tips.dart';
import 'package:forest_test/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';

class MockOnboardingRepository extends Mock implements OnboardingRepository {}

void main() {
  late MockOnboardingRepository repository;
  late int finished;

  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  setUp(() {
    repository = MockOnboardingRepository();
    when(() => repository.markCompleted()).thenAnswer((_) async {});
    finished = 0;
  });

  Future<void> pumpPage(WidgetTester tester) => tester.pumpWidget(
    MaterialApp(
      home: BlocProvider(
        create: (_) => OnboardingCubit(repository),
        child: OnboardingPage(onFinished: () => finished++),
      ),
    ),
  );

  // Long enough for the page transition, far shorter than a tip's timer.
  // Lets a page transition finish. When the timer moves on, the transition
  // only starts a couple of frames later, hence the extra pumps.
  Future<void> settlePage(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
  }

  String titleOf(int index) => onboardingTips[index].title.toUpperCase();

  // Skip keeps its space when hidden so the layout does not jump.
  bool skipVisible(WidgetTester tester) => tester
      .widget<Visibility>(
        find.ancestor(of: find.text('Skip'), matching: find.byType(Visibility)),
      )
      .visible;

  testWidgets('walks through the three tips with Next', (tester) async {
    await pumpPage(tester);
    expect(find.text(titleOf(0)), findsOneWidget);
    expect(skipVisible(tester), isTrue);

    await tester.tap(find.text('NEXT'));
    await settlePage(tester);
    expect(find.text(titleOf(1)), findsOneWidget);

    await tester.tap(find.text('NEXT'));
    await settlePage(tester);
    expect(find.text(titleOf(2)), findsOneWidget);
    expect(skipVisible(tester), isFalse);

    await tester.tap(find.text("LET'S GO"));
    await settlePage(tester);
    expect(finished, 1);
    verify(() => repository.markCompleted()).called(1);
  });

  testWidgets('follows swipes', (tester) async {
    await pumpPage(tester);

    await tester.fling(find.text(titleOf(0)), const Offset(-400, 0), 1000);
    await settlePage(tester);

    expect(find.text(titleOf(1)), findsOneWidget);
    expect(find.text('NEXT'), findsOneWidget);
  });

  testWidgets('Skip finishes right away', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.text('Skip'));
    await settlePage(tester);

    expect(finished, 1);
    verify(() => repository.markCompleted()).called(1);
  });

  testWidgets('moves to the next tip after each tip duration', (tester) async {
    await pumpPage(tester);
    // The timer starts counting on the first frame after mounting.
    await tester.pump();

    await tester.pump(
      kOnboardingTipDuration - const Duration(milliseconds: 100),
    );
    expect(find.text(titleOf(0)), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 100));
    await settlePage(tester);
    expect(find.text(titleOf(1)), findsOneWidget);

    await tester.pump(kOnboardingTipDuration);
    await settlePage(tester);
    expect(find.text(titleOf(2)), findsOneWidget);
  });

  testWidgets('waits on the last tip instead of finishing', (tester) async {
    await pumpPage(tester);

    await tester.pumpAndSettle();

    expect(find.text(titleOf(2)), findsOneWidget);
    expect(find.text("LET'S GO"), findsOneWidget);
    expect(finished, 0);
    verifyNever(() => repository.markCompleted());
  });

  testWidgets('restarts the timer when the user taps Next', (tester) async {
    await pumpPage(tester);
    await tester.pump(const Duration(seconds: 4));

    await tester.tap(find.text('NEXT'));
    await settlePage(tester);
    await tester.pump(const Duration(seconds: 3));

    // About 4 s into tip 1; a timer carried over from tip 0 would have
    // moved on already.
    expect(find.text(titleOf(1)), findsOneWidget);
  });
}
