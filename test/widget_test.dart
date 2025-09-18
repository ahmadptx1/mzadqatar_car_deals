// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mzadqatar_car_deals/main.dart';

void main() {
  testWidgets('App shows listing screen and controls', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MzadQatarCarDealsApp());

    // Verify AppBar title is present
    expect(find.text('MzadQatar Car Deals'), findsOneWidget);

    // Verify the 'Go' button and the exact model input are present
    expect(find.text('Go'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });
}
