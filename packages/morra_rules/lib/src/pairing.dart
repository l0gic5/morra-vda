enum RemainderHandling { individualPlayoff, walkover }

enum KnockoutRound { semiFinals, quarterFinals }

final class BaraondaQualificationPlan {
  const BaraondaQualificationPlan._({
    required this.playerCount,
    required this.games,
    required this.groupPairCounts,
    required this.qualifiedPerGroup,
    required this.qualifiedPlayers,
    required this.knockoutRound,
    this.hasEighthPlaceTieBreak = false,
    this.hasThirdPlaceMiniTournament = false,
    this.hasGroupTieBreak = false,
  });

  factory BaraondaQualificationPlan.forPlayers(int playerCount) {
    if (playerCount <= 0) {
      throw ArgumentError.value(playerCount, 'playerCount');
    }

    if (playerCount <= 19) {
      return BaraondaQualificationPlan._(
        playerCount: playerCount,
        games: 5,
        groupPairCounts: const [],
        qualifiedPerGroup: const [],
        qualifiedPlayers: 8,
        knockoutRound: KnockoutRound.semiFinals,
        hasEighthPlaceTieBreak: true,
      );
    }

    final plan = _plans[playerCount];
    if (plan == null) {
      throw UnsupportedError(
        'Non esiste un regolamento di qualificazione definito per '
        '$playerCount giocatori.',
      );
    }
    return plan;
  }

  final int playerCount;
  final int games;
  final List<int> groupPairCounts;
  final List<int> qualifiedPerGroup;
  final int qualifiedPlayers;
  final KnockoutRound knockoutRound;
  final bool hasEighthPlaceTieBreak;
  final bool hasThirdPlaceMiniTournament;
  final bool hasGroupTieBreak;

  bool get usesGroups => groupPairCounts.isNotEmpty;

  int get groupCount => groupPairCounts.length;

  int get pairCount => playerCount ~/ 2;

  static final _plans = <int, BaraondaQualificationPlan>{
    20: BaraondaQualificationPlan._(
      playerCount: 20,
      games: 0,
      groupPairCounts: [5, 5],
      qualifiedPerGroup: [4, 4],
      qualifiedPlayers: 8,
      knockoutRound: KnockoutRound.quarterFinals,
    ),
    22: BaraondaQualificationPlan._(
      playerCount: 22,
      games: 0,
      groupPairCounts: [6, 5],
      qualifiedPerGroup: [4, 4],
      qualifiedPlayers: 8,
      knockoutRound: KnockoutRound.quarterFinals,
    ),
    24: BaraondaQualificationPlan._(
      playerCount: 24,
      games: 0,
      groupPairCounts: [6, 6],
      qualifiedPerGroup: [4, 4],
      qualifiedPlayers: 8,
      knockoutRound: KnockoutRound.quarterFinals,
    ),
    26: BaraondaQualificationPlan._(
      playerCount: 26,
      games: 0,
      groupPairCounts: [5, 4, 4],
      qualifiedPerGroup: [3, 2, 2],
      qualifiedPlayers: 8,
      knockoutRound: KnockoutRound.quarterFinals,
      hasGroupTieBreak: true,
    ),
    28: BaraondaQualificationPlan._(
      playerCount: 28,
      games: 0,
      groupPairCounts: [5, 5, 4],
      qualifiedPerGroup: [3, 3, 2],
      qualifiedPlayers: 8,
      knockoutRound: KnockoutRound.quarterFinals,
    ),
    30: BaraondaQualificationPlan._(
      playerCount: 30,
      games: 0,
      groupPairCounts: [5, 5, 5],
      qualifiedPerGroup: [2, 2, 2],
      qualifiedPlayers: 8,
      knockoutRound: KnockoutRound.quarterFinals,
      hasThirdPlaceMiniTournament: true,
    ),
    32: BaraondaQualificationPlan._(
      playerCount: 32,
      games: 0,
      groupPairCounts: [4, 4, 4, 4],
      qualifiedPerGroup: [2, 2, 2, 2],
      qualifiedPlayers: 8,
      knockoutRound: KnockoutRound.quarterFinals,
    ),
  };
}
