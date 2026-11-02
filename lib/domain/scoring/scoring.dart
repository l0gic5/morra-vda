enum Team { one, two }

sealed class ScoringEvent {
  const ScoringEvent({required this.id});

  final String id;
}

final class PointScored extends ScoringEvent {
  const PointScored({required super.id, required this.team});

  final Team team;
}

final class HandLowered extends ScoringEvent {
  const HandLowered({
    required super.id,
    required this.team,
    required this.points,
  }) : assert(points > 0);

  final Team team;
  final int points;
}

final class EventUndone extends ScoringEvent {
  const EventUndone({required super.id, required this.eventId});

  final String eventId;
}

enum GameStatus { inProgress, tied, won }

final class GameScore {
  const GameScore({
    required this.teamOne,
    required this.teamTwo,
    required this.status,
    this.winner,
  });

  final int teamOne;
  final int teamTwo;
  final GameStatus status;
  final Team? winner;

  bool get isTie => teamOne == teamTwo;

  int scoreFor(Team team) => team == Team.one ? teamOne : teamTwo;
}

final class ScoringGame {
  ScoringGame({this.target = 16}) : assert(target > 0);

  final int target;
  final List<ScoringEvent> _events = [];
  int _nextEventId = 0;

  List<ScoringEvent> get events => List.unmodifiable(_events);

  GameScore get score {
    var teamOne = 0;
    var teamTwo = 0;
    final loweredBy = <Team>{};
    final undone = <String>{};

    for (final event in _events) {
      if (event case EventUndone(:final eventId)) {
        undone.add(eventId);
      }
    }

    for (final event in _events) {
      if (undone.contains(event.id)) {
        continue;
      }
      switch (event) {
        case PointScored(team: final team):
          if (team == Team.one) {
            teamOne++;
          } else {
            teamTwo++;
          }
        case HandLowered(team: final team, points: final points):
          loweredBy.add(team);
          teamOne -= points;
          teamTwo -= points;
        case EventUndone():
          break;
      }
    }

    final winner = teamOne >= target
        ? Team.one
        : teamTwo >= target
        ? Team.two
        : null;
    return GameScore(
      teamOne: teamOne,
      teamTwo: teamTwo,
      status: winner != null
          ? GameStatus.won
          : teamOne == teamTwo
          ? GameStatus.tied
          : GameStatus.inProgress,
      winner: winner,
    );
  }

  String addPoint(Team team) {
    _ensureInProgress();
    return _append(PointScored(id: _newId(), team: team));
  }

  String lowerHand({required Team team, required int points}) {
    _ensureInProgress();
    if (!score.isTie) {
      throw StateError('La mano si può abbassare solo in caso di parità.');
    }
    if (points <= 0 || points > score.teamOne) {
      throw ArgumentError.value(points, 'points');
    }
    if (_hasActiveLowering(team)) {
      throw StateError(
        'La squadra ha già abbassato la mano in questa partita.',
      );
    }
    return _append(HandLowered(id: _newId(), team: team, points: points));
  }

  String undo(String eventId) {
    if (!_events.any((event) => event.id == eventId)) {
      throw ArgumentError.value(eventId, 'eventId');
    }
    if (_events.any(
      (event) => event is EventUndone && event.eventId == eventId,
    )) {
      throw StateError('L\'evento è già stato annullato.');
    }
    return _append(EventUndone(id: _newId(), eventId: eventId));
  }

  String _append(ScoringEvent event) {
    _events.add(event);
    return event.id;
  }

  String _newId() => 'event-${_nextEventId++}';

  bool _hasActiveLowering(Team team) {
    final undone = _events
        .whereType<EventUndone>()
        .map((event) => event.eventId)
        .toSet();
    return _events.whereType<HandLowered>().any(
      (event) => event.team == team && !undone.contains(event.id),
    );
  }

  void _ensureInProgress() {
    if (score.status == GameStatus.won) {
      throw StateError('La partita è già terminata.');
    }
  }
}

final class MatchScore {
  const MatchScore({
    required this.teamOneGames,
    required this.teamTwoGames,
    this.winner,
  });

  final int teamOneGames;
  final int teamTwoGames;
  final Team? winner;

  bool get isComplete => winner != null;
}

final class Match {
  Match({this.gamesToWin = 3}) : assert(gamesToWin > 0);

  final int gamesToWin;
  final List<Team> _gameWinners = [];

  List<Team> get gameWinners => List.unmodifiable(_gameWinners);

  MatchScore get score {
    final teamOne = _gameWinners.where((team) => team == Team.one).length;
    final teamTwo = _gameWinners.where((team) => team == Team.two).length;
    return MatchScore(
      teamOneGames: teamOne,
      teamTwoGames: teamTwo,
      winner: teamOne >= gamesToWin
          ? Team.one
          : teamTwo >= gamesToWin
          ? Team.two
          : null,
    );
  }

  void recordGame(GameScore game) {
    final winner = game.winner;
    if (winner == null) {
      throw StateError('Si può registrare solo una partita vinta.');
    }
    if (score.isComplete) {
      throw StateError('L\'incontro è già terminato.');
    }
    _gameWinners.add(winner);
  }
}
