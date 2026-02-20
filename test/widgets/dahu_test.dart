import 'package:ca_joue/widgets/dahu.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Dahu', () {
    testWidgets('renders at onboarding size without errors', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: Dahu(size: DahuSize.onboarding),
        ),
      );

      expect(find.byType(Dahu), findsOneWidget);
    });

    testWidgets('renders at each DahuSize variant', (tester) async {
      for (final size in DahuSize.values) {
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Dahu(size: size),
          ),
        );

        expect(find.byType(Dahu), findsOneWidget);
      }
    });

    testWidgets('excludes semantics', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: Dahu(size: DahuSize.onboarding),
        ),
      );

      final semantics = tester.widget<Semantics>(find.byType(Semantics));
      expect(semantics.excludeSemantics, isTrue);
    });
  });
}
