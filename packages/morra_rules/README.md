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

Planned: qualification groups and knockout brackets for baraonda, fixed-pair
pairings, stage points and season ranking.

## Tournament format

A stage always has two phases:

1. qualification groups;
2. a knockout phase with the required power-of-two bracket: round of 16,
   quarter-finals, semi-finals and final. Smaller stages omit unnecessary
   initial rounds.

For baraonda, the qualification rules are:

- up to 19 players: 5 games with a newly drawn pair each time; the top 8
  players advance to the semi-finals and are paired again; the younger player
  wins an eighth-place tie-break;
- 20 players: two groups of 5 pairs, top 4 pairs from each group advance to
  the quarter-finals;
- 22 players: groups of 6 and 5 pairs, top 4 pairs from each advance;
- 24 players: two groups of 6 pairs, top 4 pairs from each advance;
- 26 players: groups of 5, 4 and 4 pairs; top 3 from the group of 5 and top 2
  from each group of 4 advance, with the third-placed pairs from those groups
  playing a tie-break for the final quarter-final place;
- 28 players: groups of 5, 5 and 4 pairs; top 3 from each group of 5 and top 2
  from the group of 4 advance;
- 30 players: three groups of 5 pairs; top 2 from each advance, while the
  third-placed pairs play a three-pair mini-tournament and its top 2 advance;
- 32 players: four groups of 4 pairs, with top 2 from each advancing.

When the number of players leaves a remainder, the admin configures the stage
to use an individual 1-vs-1 play-off (preferred) or a fairly rotated walkover
win.

`BaraondaQualificationPlan.forPlayers` exposes these qualification rules to the
app and server without performing the random draw. Unsupported participant
counts are rejected until their official qualification format is defined.

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
  game.lowerHand(team: Team.one, points: 5);

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

- **Events, not counters.** Undo, history and replaying a disputed game come from the event list. Events carry client-generated IDs so a server can insert them idempotently. `ScoringGame` can replay an ordered event log through its `events` parameter; duplicate IDs, invalid references and attempts to undo another undo are rejected.
- **No Flutter, no I/O.** Keeping the package pure makes it fast to test and shareable with the server.
- **Rules are configurable** (target score, games to win, deciding-game target and lowering amounts). Lowering accepts 5, 10, 15 or 20 points; the latter two are rare but supported.

## Development

```bash
dart pub get
dart analyze
dart test
```

Add a test for every real case that comes up at a tournament (ties, lowering, undo, remainders, play-offs): the rules engine is the most delicate part of the project.
