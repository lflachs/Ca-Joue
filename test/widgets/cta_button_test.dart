import 'package:ca_joue/widgets/cta_button.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CtaButton', () {
    testWidgets('renders with label text', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: CtaButton(label: 'Test', onPressed: () {}),
        ),
      );

      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('shows disabled state when onPressed is null', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: CtaButton(label: 'Disabled'),
        ),
      );

      expect(find.text('Disabled'), findsOneWidget);
    });

    testWidgets('has semantic label', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: CtaButton(label: 'Action', onPressed: () {}),
        ),
      );

      final semantics = tester.widget<Semantics>(find.byType(Semantics));
      expect(semantics.properties.label, 'Action');
      expect(semantics.properties.button, isTrue);
    });

    testWidgets('tap callback fires', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: CtaButton(
            label: 'Tap me',
            onPressed: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.text('Tap me'));
      expect(tapped, isTrue);
    });
  });
}
