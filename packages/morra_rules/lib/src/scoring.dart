enum Team { one, two }

const allowedLoweringPoints = {5, 10, 15, 20};

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
    this.target = 16,
    this.winner,
  });

  final int teamOne;
  final int teamTwo;
  final GameStatus status;
  final int target;
  final Team? winner;

  bool get isTie => teamOne == teamTwo;

  int scoreFor(Team team) => team == Team.one ? teamOne : teamTwo;
}

final class ScoringGame {
  ScoringGame({this.target = 16, Iterable<ScoringEvent> events = const []})
    : assert(target > 0) {
    for (final event in events) {
      _appendFromReplay(event);
    }
  }

  final int target;
  final List<ScoringEvent> _events = [];
  int _nextEventId = 0;

  List<ScoringEvent> get events => List.unmodifiable(_events);

  GameScore get score {
    var teamOne = 0;
    var teamTwo = 0;
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
        case HandLowered(points: final points):
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
      target: target,
      winner: winner,
    );
  }

  String addPoint(Team team, {String? id}) {
    _ensureInProgress();
    return _append(PointScored(id: id ?? _newId(), team: team));
  }

  String lowerHand({required Team team, required int points, String? id}) {
    _ensureInProgress();
    if (!score.isTie) {
      throw StateError('La mano si può abbassare solo in caso di parità.');
    }
    if (!allowedLoweringPoints.contains(points) || points > score.teamOne) {
      throw ArgumentError.value(points, 'points');
    }
    if (_hasActiveLowering(team)) {
      throw StateError(
        'La squadra ha già abbassato la mano in questa partita.',
      );
    }
    return _append(HandLowered(id: id ?? _newId(), team: team, points: points));
  }

  String undo(String eventId, {String? id}) {
    final event = _events.where((event) => event.id == eventId).firstOrNull;
    if (event == null || event is EventUndone) {
      throw ArgumentError.value(eventId, 'eventId');
    }
    if (_events.any(
      (event) => event is EventUndone && event.eventId == eventId,
    )) {
      throw StateError('L\'evento è già stato annullato.');
    }
    return _append(EventUndone(id: id ?? _newId(), eventId: eventId));
  }

  String _append(ScoringEvent event) {
    if (event.id.isEmpty || _events.any((current) => current.id == event.id)) {
      throw ArgumentError.value(event.id, 'event.id');
    }
    _events.add(event);
    return event.id;
  }

  String _newId() {
    var id = 'event-${_nextEventId++}';
    while (_events.any((event) => event.id == id)) {
      id = 'event-${_nextEventId++}';
    }
    return id;
  }

  void _appendFromReplay(ScoringEvent event) {
    switch (event) {
      case PointScored():
        _ensureInProgress();
      case HandLowered(:final team, :final points):
        _ensureInProgress();
        if (!score.isTie) {
          throw StateError('La mano si può abbassare solo in caso di parità.');
        }
        if (!allowedLoweringPoints.contains(points) || points > score.teamOne) {
          throw ArgumentError.value(points, 'points');
        }
        if (_hasActiveLowering(team)) {
          throw StateError(
            'La squadra ha già abbassato la mano in questa partita.',
          );
        }
      case EventUndone(:final eventId):
        final target = _events
            .where((event) => event.id == eventId)
            .firstOrNull;
        if (target == null || target is EventUndone) {
          throw ArgumentError.value(eventId, 'eventId');
        }
        if (_events.any(
          (current) => current is EventUndone && current.eventId == eventId,
        )) {
          throw StateError('L\'evento è già stato annullato.');
        }
    }
    _append(event);
  }

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
  Match({
    this.gamesToWin = 3,
    this.regularGameTarget = 16,
    this.decidingGameTarget = 21,
  }) : assert(gamesToWin > 0),
       assert(regularGameTarget > 0),
       assert(decidingGameTarget > 0);

  final int gamesToWin;
  final int regularGameTarget;
  final int decidingGameTarget;
  final List<Team> _gameWinners = [];

  List<Team> get gameWinners => List.unmodifiable(_gameWinners);

  int get nextGameTarget => _gameWinners.length == gamesToWin * 2 - 2
      ? decidingGameTarget
      : regularGameTarget;

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
    if (winner == null || game.status != GameStatus.won) {
      throw StateError('Si può registrare solo una partita vinta.');
    }
    if (score.isComplete) {
      throw StateError('L\'incontro è già terminato.');
    }
    if (game.target != nextGameTarget ||
        game.scoreFor(winner) <= game.scoreFor(_otherTeam(winner))) {
      throw ArgumentError.value(game, 'game');
    }
    _gameWinners.add(winner);
  }

  Team _otherTeam(Team team) => team == Team.one ? Team.two : Team.one;
}
