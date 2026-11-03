import 'package:morra_rules/morra_rules.dart';
import 'package:test/test.dart';

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
      game.lowerHand(team: Team.two, points: 5);
      expect(game.score.teamOne, 0);
      expect(game.score.teamTwo, 0);
    });

    test('rifiuta abbassamento fuori parità', () {
      final game = ScoringGame();
      game.addPoint(Team.one);

      expect(() => game.lowerHand(team: Team.one, points: 1), throwsStateError);
    });

    test('accetta solo gli abbassamenti previsti dal regolamento', () {
      final game = ScoringGame();
      for (var i = 0; i < 10; i++) {
        game.addPoint(Team.one);
        game.addPoint(Team.two);
      }

      expect(
        () => game.lowerHand(team: Team.one, points: 1),
        throwsArgumentError,
      );
      game.lowerHand(team: Team.one, points: 10);
      expect(game.score.teamOne, 0);
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

    test('accetta ID generati dal client e li conserva nel registro', () {
      final game = ScoringGame();

      final pointId = game.addPoint(Team.one, id: 'device-a-1');

      expect(pointId, 'device-a-1');
      expect(game.events.single.id, 'device-a-1');
    });

    test('rigioca un registro ordinato e ne ricostruisce il punteggio', () {
      final events = <ScoringEvent>[
        const PointScored(id: 'device-a-1', team: Team.one),
        const PointScored(id: 'device-a-2', team: Team.two),
        const EventUndone(id: 'device-a-3', eventId: 'device-a-1'),
      ];

      final game = ScoringGame(events: events);

      expect(game.score.teamOne, 0);
      expect(game.score.teamTwo, 1);
      expect(game.events, orderedEquals(events));
    });

    test('rifiuta ID duplicati e annullamento di un annullamento', () {
      final game = ScoringGame();
      game.addPoint(Team.one, id: 'point');

      expect(() => game.addPoint(Team.two, id: 'point'), throwsArgumentError);
      expect(
        () => ScoringGame(
          events: [const EventUndone(id: 'undo', eventId: 'missing')],
        ),
        throwsArgumentError,
      );
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

  test('rifiuta un risultato incoerente quando registra una partita', () {
    final match = Match();
    final invalidGame = GameScore(
      teamOne: 16,
      teamTwo: 10,
      status: GameStatus.inProgress,
      winner: Team.one,
    );

    expect(() => match.recordGame(invalidGame), throwsStateError);
  });

  test('rifiuta un vincitore che non ha il punteggio maggiore', () {
    final match = Match();
    final invalidGame = GameScore(
      teamOne: 10,
      teamTwo: 16,
      status: GameStatus.won,
      winner: Team.one,
    );

    expect(() => match.recordGame(invalidGame), throwsArgumentError);
  });

  test('usa 21 solo per la bella dopo il 2-2', () {
    final match = Match();
    final regularGame = GameScore(
      teamOne: 16,
      teamTwo: 10,
      status: GameStatus.won,
      winner: Team.one,
    );
    final decidingGame = GameScore(
      teamOne: 21,
      teamTwo: 19,
      status: GameStatus.won,
      target: 21,
      winner: Team.one,
    );

    expect(match.nextGameTarget, 16);
    match.recordGame(regularGame);
    match.recordGame(regularGame);
    match.recordGame(
      GameScore(
        teamOne: 10,
        teamTwo: 16,
        status: GameStatus.won,
        winner: Team.two,
      ),
    );
    match.recordGame(
      GameScore(
        teamOne: 10,
        teamTwo: 16,
        status: GameStatus.won,
        winner: Team.two,
      ),
    );

    expect(match.nextGameTarget, 21);
    expect(() => match.recordGame(regularGame), throwsArgumentError);
    match.recordGame(decidingGame);
    expect(match.score.winner, Team.one);
  });
}
