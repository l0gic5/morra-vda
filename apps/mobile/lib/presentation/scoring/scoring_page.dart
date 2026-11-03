import 'package:flutter/material.dart';

import 'package:morra_vda/application/scoring/scoring_controller.dart';
import 'package:morra_rules/morra_rules.dart';

final class ScoringPage extends StatefulWidget {
  const ScoringPage({super.key});

  @override
  State<ScoringPage> createState() => _ScoringPageState();
}

final class _ScoringPageState extends State<ScoringPage> {
  late final ScoringController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScoringController();
    _controller.addListener(_onScoreChanged);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onScoreChanged)
      ..dispose();
    super.dispose();
  }

  void _onScoreChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final score = _controller.score;
    return Scaffold(
      appBar: AppBar(title: const Text('Conta-partita')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              if (score.status == GameStatus.tied)
                const Card(
                  child: ListTile(
                    leading: Icon(Icons.warning_amber),
                    title: Text('Parità'),
                    subtitle: Text('Puoi abbassare la mano.'),
                  ),
                ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _TeamButton(
                        label: 'Squadra 1',
                        score: score.teamOne,
                        onPressed: () => _controller.addPoint(Team.one),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _TeamButton(
                        label: 'Squadra 2',
                        score: score.teamTwo,
                        onPressed: () => _controller.addPoint(Team.two),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: _controller.undoLastPoint,
                icon: const Icon(Icons.undo),
                label: const Text('Annulla ultimo punto'),
              ),
              if (score.winner case final winner?)
                Text(
                  winner == Team.one
                      ? 'Vince la squadra 1'
                      : 'Vince la squadra 2',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

final class _TeamButton extends StatelessWidget {
  const _TeamButton({
    required this.label,
    required this.score,
    required this.onPressed,
  });

  final String label;
  final int score;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.all(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label),
          const SizedBox(height: 16),
          Text('$score', style: Theme.of(context).textTheme.displayLarge),
          const SizedBox(height: 16),
          const Icon(Icons.add, size: 32),
        ],
      ),
    );
  }
}
