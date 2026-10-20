import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_to_do_list/screens/onboarding/onboarding_screen.dart';
import 'package:flutter_to_do_list/services/onboarding_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('đi qua 2 trang rồi Bắt đầu: gọi onFinished và ghi nhớ đã xem', (tester) async {
    var finished = 0;
    await tester.pumpWidget(MaterialApp(home: OnboardingScreen(onFinished: () => finished++)));

    expect(find.text('Chào mừng đến với UBNA Manager'), findsOneWidget);
    expect(find.text('Quay lại'), findsNothing);

    await tester.tap(find.text('Tiếp tục'));
    await tester.pumpAndSettle();
    expect(find.text('Theo dõi công việc hiệu quả hơn'), findsOneWidget);
    expect(find.text('Quay lại'), findsOneWidget);

    await tester.runAsync(() async {
      await tester.tap(find.text('Bắt đầu'));
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pump();

    expect(finished, 1);
    expect(await OnboardingStore.hasSeen(), isTrue);
  });

  testWidgets('Bỏ qua ở trang đầu cũng hoàn tất', (tester) async {
    var finished = 0;
    await tester.pumpWidget(MaterialApp(home: OnboardingScreen(onFinished: () => finished++)));

    await tester.runAsync(() async {
      await tester.tap(find.text('Bỏ qua'));
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pump();

    expect(finished, 1);
  });
}
