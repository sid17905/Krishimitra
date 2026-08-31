import 'package:flutter_test/flutter_test.dart';
import 'package:krishimitra/main.dart';

void main() {
  testWidgets('KrishiMitra app renders', (WidgetTester tester) async {
    await tester.pumpWidget(const KrishiMitraApp());
    await tester.pumpAndSettle();

    expect(find.byType(KrishiMitraApp), findsOneWidget);
  });
}
