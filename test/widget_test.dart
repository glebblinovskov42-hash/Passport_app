import 'package:flutter_test/flutter_test.dart';
import 'package:passport_ocr_app/main.dart';

void main() {
  testWidgets('PassportApp starts successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const PassportApp());

    expect(find.text('Passport OCR'), findsOneWidget);
  });
}
