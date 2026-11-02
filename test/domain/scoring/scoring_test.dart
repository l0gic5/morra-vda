import 'package:flutter_test/flutter_test.dart';
import 'package:morra_vda/domain/scoring/scoring.dart';

void main() {
  group('ScoringGame', () {
    test('somma i punti e segnala la parità', () {
      final game = ScoringGame();
      game.addPoint(Team.one);
      game.addPoint(Team.two);

      expect(game.score.teamOne, 1);
      expect(game.score.teamTwo, 1);
      expect(game.score.status, GameStatus.tied);
    });

    test('dichiara vincitrice la prima squadra al target', () {
      final game = ScoringGame(target: 2);
      game.addPoint(Team.one);
      game.addPoint(Team.one);

      expect(game.score.winner, Team.one);
      expect(() => game.addPoint(Team.two), throwsStateError);
    });

    test('supporta il target alternativo di 21 punti', () {
      final game = ScoringGame(target: 21);
      for (var i = 0; i < 21; i++) {
        game.addPoint(Team.two);
      }

      expect(game.score.winner, Team.two);
    });

    test('abbassa entrambi i punteggi una volta per squadra', () {
      final game = ScoringGame();
      for (var i = 0; i < 10; i++) {
        game.addPoint(Team.one);
        game.addPoint(Team.two);
      }

      game.lowerHand(team: Team.one, points: 5);
      expect(game.score.teamOne, 5);
      expect(game.score.teamTwo, 5);
      expect(() => game.lowerHand(team: Team.one, points: 5), throwsStateError);
      game.lowerHand(team: Team.two, points: 1);
      expect(game.score.teamOne, 4);
      expect(game.score.teamTwo, 4);
    });

    test('rifiuta abbassamento fuori parità', () {
      final game = ScoringGame();
      game.addPoint(Team.one);

      expect(() => game.lowerHand(team: Team.one, points: 1), throwsStateError);
    });

    test('annulla un evento e lo esclude dalla somma', () {
      final game = ScoringGame();
      final pointId = game.addPoint(Team.one);
      game.addPoint(Team.two);

      game.undo(pointId);

      expect(game.score.teamOne, 0);
      expect(game.score.teamTwo, 1);
      expect(() => game.undo(pointId), throwsStateError);
    });
  });

  test('un incontro termina alla terza partita vinta', () {
    final match = Match();
    final wonByOne = GameScore(
      teamOne: 16,
      teamTwo: 10,
      status: GameStatus.won,
      winner: Team.one,
    );
    final wonByTwo = GameScore(
      teamOne: 10,
      teamTwo: 16,
      status: GameStatus.won,
      winner: Team.two,
    );

    match.recordGame(wonByOne);
    match.recordGame(wonByTwo);
    match.recordGame(wonByOne);
    match.recordGame(wonByOne);

    expect(match.score.teamOneGames, 3);
    expect(match.score.teamTwoGames, 1);
    expect(match.score.winner, Team.one);
    expect(() => match.recordGame(wonByTwo), throwsStateError);
  });
}
