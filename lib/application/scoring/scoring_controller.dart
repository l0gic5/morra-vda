import 'package:flutter/foundation.dart';

import 'package:morra_vda/domain/scoring/scoring.dart';

final class ScoringController extends ChangeNotifier {
  ScoringController({int target = 16}) : game = ScoringGame(target: target);

  final ScoringGame game;

  GameScore get score => game.score;

  void addPoint(Team team) {
    game.addPoint(team);
    notifyListeners();
  }

  void undoLastPoint() {
    final undone = game.events
        .whereType<EventUndone>()
        .map((event) => event.eventId)
        .toSet();
    final lastPoint = game.events
        .whereType<PointScored>()
        .where((event) => !undone.contains(event.id))
        .lastOrNull;
    if (lastPoint == null) {
      return;
    }
    game.undo(lastPoint.id);
    notifyListeners();
  }
}
