import 'package:flutter_test/flutter_test.dart';

import 'package:morra_vda/main.dart';

void main() {
  testWidgets('incrementa il punteggio e mostra la parità', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('0'), findsNWidgets(2));
    await tester.tap(find.text('Squadra 1'));
    await tester.pump();
    expect(find.text('1'), findsOneWidget);

    await tester.tap(find.text('Squadra 2'));
    await tester.pump();
    expect(find.text('Parità'), findsOneWidget);
    expect(find.text('Puoi abbassare la mano.'), findsOneWidget);
  });

  testWidgets('annulla l’ultimo punto', (tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Squadra 1'));
    await tester.pump();
    await tester.tap(find.text('Annulla ultimo punto'));
    await tester.pump();

    expect(find.text('0'), findsNWidgets(2));
  });
}
