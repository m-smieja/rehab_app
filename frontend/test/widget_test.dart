import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rehab_app/core/theme.dart';
import 'package:rehab_app/ui/screens/home_screen.dart';

void main() {
  testWidgets('Home screen shows DIGITAL REHAB title', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: const HomeScreen(),
      ),
    );

    expect(find.text('DIGITAL REHAB'), findsOneWidget);
  });
}
