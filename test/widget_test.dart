// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:aeroporto_clima_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('BuscaAeroportoPage should display correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // We start at the '/busca' route.
    await tester.pumpWidget(const MyApp(initialRoute: '/busca'));

    // Verify that the search page widgets are present.
    expect(find.byType(TextField), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Buscar'), findsOneWidget);
    expect(find.text('Buscar Aeroporto (CPTEC)'), findsOneWidget);
  });
}
