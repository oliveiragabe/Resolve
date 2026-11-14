import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app.dart';

void main() {
  testWidgets('Resolve inicia corretamente', (WidgetTester tester) async {
    await tester.pumpWidget(const ResolveApp());

    expect(find.text('Resolve'), findsOneWidget);
  });
}
