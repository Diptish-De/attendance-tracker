import 'package:flutter_test/flutter_test.dart';
import 'package:bunkquest/main.dart';

void main() {
  testWidgets('BunkQuest smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const BunkQuestApp());
    expect(find.text('BunkQuest - Attendance OS'), findsNothing);
  });
}
