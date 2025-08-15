import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trade_trackr/main.dart';

void main() {
  testWidgets('App initialization test', (WidgetTester tester) async {
    await tester.pumpWidget(const TradeTrackrApp());

    // Verify that the app title is displayed
    expect(find.text('Trade Trackr'), findsOneWidget);
    
    // Verify that the add trade button exists
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.text('Add Trade'), findsOneWidget);
  });
}