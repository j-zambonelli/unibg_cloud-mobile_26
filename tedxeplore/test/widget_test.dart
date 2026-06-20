import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tedxeplore/main.dart';

void main() {
  testWidgets('TEDxplore Login Screen Smoke Test', (WidgetTester tester) async {
    await tester.pumpWidget(const TedXploreApp());

    expect(find.textContaining('TED'), findsOneWidget);
    expect(find.textContaining('xplore'), findsOneWidget);

    expect(find.byIcon(Icons.import_contacts), findsOneWidget);
    expect(find.text('Login with Amazon'), findsOneWidget);

    await tester.tap(find.text('Login with Amazon'));
    await tester.pumpAndSettle();

    expect(find.text('Suggeriti per te'), findsOneWidget);
  });
}