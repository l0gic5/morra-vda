import 'package:morra_rules/morra_rules.dart';
import 'package:test/test.dart';

void main() {
  group('BaraondaQualificationPlan', () {
    test('usa cinque partite e otto qualificati fino a 19 giocatori', () {
      final plan = BaraondaQualificationPlan.forPlayers(19);

      expect(plan.games, 5);
      expect(plan.usesGroups, isFalse);
      expect(plan.qualifiedPlayers, 8);
      expect(plan.knockoutRound, KnockoutRound.semiFinals);
      expect(plan.hasEighthPlaceTieBreak, isTrue);
    });

    test('configura i gironi da 20 a 32 giocatori', () {
      final expected = {
        20: ([5, 5], [4, 4]),
        22: ([6, 5], [4, 4]),
        24: ([6, 6], [4, 4]),
        26: ([5, 4, 4], [3, 2, 2]),
        28: ([5, 5, 4], [3, 3, 2]),
        30: ([5, 5, 5], [2, 2, 2]),
        32: ([4, 4, 4, 4], [2, 2, 2, 2]),
      };

      for (final entry in expected.entries) {
        final plan = BaraondaQualificationPlan.forPlayers(entry.key);
        expect(plan.groupPairCounts, entry.value.$1);
        expect(plan.qualifiedPerGroup, entry.value.$2);
        expect(plan.qualifiedPlayers, 8);
        expect(plan.knockoutRound, KnockoutRound.quarterFinals);
      }
    });

    test('segnala gli spareggi speciali', () {
      expect(BaraondaQualificationPlan.forPlayers(26).hasGroupTieBreak, isTrue);
      expect(
        BaraondaQualificationPlan.forPlayers(30).hasThirdPlaceMiniTournament,
        isTrue,
      );
    });

    test('rifiuta numeri per cui manca una regola definita', () {
      expect(
        () => BaraondaQualificationPlan.forPlayers(21),
        throwsUnsupportedError,
      );
      expect(
        () => BaraondaQualificationPlan.forPlayers(0),
        throwsArgumentError,
      );
    });
  });
}
