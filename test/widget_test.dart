import 'package:flutter_test/flutter_test.dart';
import 'package:bunkquest/main.dart';
import 'package:bunkquest/services/attendance_store.dart';

void main() {
  testWidgets('BunkQuest smoke test', (WidgetTester tester) async {
    final store = AttendanceDataStore();
    await tester.pumpWidget(BunkQuestApp(store: store));
    expect(find.text('BunkQuest - Attendance OS'), findsNothing);
  });
}
