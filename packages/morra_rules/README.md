# morra_rules

Rules engine for **Morra Valdostana** tournaments, written in pure Dart with no Flutter dependency.

The same package is meant to be used by the Flutter app (live score counting, also offline) and by the Serverpod backend (validation and official results), so there is a single implementation of the rules.

This package is internal to the monorepo (`publish_to: none`).

## What it contains

**Scoring** (`lib/src/scoring.dart`):

- `ScoringGame`: one game between two teams, won by the first team to reach the target score (16 by default).
- Scores are **derived from an append-only list of events**, not stored as a number:
  - `PointScored`: +1 for a team.
  - `HandLowered`: both scores go down by the same amount, only when the game is tied, and only once per team per game.
  - `EventUndone`: cancels a previous event.
- `GameScore`: current score, status (`inProgress`, `tied`, `won`) and winner.
- `Match`: a series of games, won by the first team to win `gamesToWin` games (3 by default).

Planned: pairings (baraonda and fixed pairs, remainder handling), stage points and season ranking.

## Usage

```dart
import 'package:morra_rules/morra_rules.dart';

void main() {
  final game = ScoringGame(); // target 16

  game.addPoint(Team.one);
  game.addPoint(Team.two);

  print(game.score.teamOne); // 1
  print(game.score.isTie);   // true

  // when the score is tied, a team can lower the hand (once per game)
  game.lowerHand(team: Team.one, points: 1);

  // undo any event by its id
  final id = game.addPoint(Team.two);
  game.undo(id);

  // when a game is won, record it in the match
  final match = Match(); // first to 3 games
  if (game.score.status == GameStatus.won) {
    match.recordGame(game.score);
  }
  print(match.score.teamOneGames);
}
```

## Design notes

- **Events, not counters.** Undo, history and replaying a disputed game come from the event list. Events carry client-generated IDs so a server can insert them idempotently.
- **No Flutter, no I/O.** Keeping the package pure makes it fast to test and shareable with the server.
- **Rules are configurable** (target score, games to win, lowering amounts), because local variants differ between clubs and seasons.

## Development

```bash
dart pub get
dart analyze
dart test
```

Add a test for every real case that comes up at a tournament (ties, lowering, undo, remainders, play-offs): the rules engine is the most delicate part of the project.
