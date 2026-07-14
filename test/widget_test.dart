import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spell_pop/shared/widgets/pop_button.dart';

void main() {
  testWidgets('PopButton renders correctly and responds to taps', (WidgetTester tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: PopButton(
              onTap: () {
                tapped = true;
              },
              child: const Text('Tap Me'),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Tap Me'), findsOneWidget);
    
    await tester.tap(find.text('Tap Me'));
    await tester.pump();
    
    expect(tapped, true);
  });
}
