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
    await tester.pumpAndSettle();
    expect(find.text(titleOf(1)), findsOneWidget);

    await tester.tap(find.text('NEXT'));
    await tester.pumpAndSettle();
    expect(find.text(titleOf(2)), findsOneWidget);
    expect(skipVisible(tester), isFalse);

    await tester.tap(find.text("LET'S GO"));
    await tester.pumpAndSettle();
    expect(finished, 1);
    verify(() => repository.markCompleted()).called(1);
  });

  testWidgets('follows swipes', (tester) async {
    await pumpPage(tester);

    await tester.fling(find.text(titleOf(0)), const Offset(-400, 0), 1000);
    await tester.pumpAndSettle();

    expect(find.text(titleOf(1)), findsOneWidget);
    expect(find.text('NEXT'), findsOneWidget);
  });

  testWidgets('Skip finishes right away', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(finished, 1);
    verify(() => repository.markCompleted()).called(1);
  });
}
