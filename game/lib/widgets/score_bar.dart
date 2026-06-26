import 'package:flutter/material.dart';
import '../game/game_state.dart';

class ScoreBar extends StatelessWidget {
  final GameState game;
  const ScoreBar({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: game,
      builder: (_, __) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '2048',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w900,
              color: Color(0xFF776E65),
            ),
          ),
          const Spacer(),
          _ScoreBox('SCORE', game.score),
          const SizedBox(width: 8),
          _ScoreBox('BEST', game.best),
          const SizedBox(width: 8),
          Column(
            children: [
              IconButton(
                tooltip: game.muted ? 'Unmute' : 'Mute',
                icon: Icon(
                  game.muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                  color: const Color(0xFF8F7A66),
                ),
                onPressed: game.toggleMute,
              ),
              _ActionButton('New Game', game.newGame),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScoreBox extends StatelessWidget {
  final String label;
  final int value;
  const _ScoreBox(this.label, this.value);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFBBADA0),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFFEEE4DA),
              ),
            ),
            Text(
              '$value',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _ActionButton(this.label, this.onTap);

  @override
  Widget build(BuildContext context) => ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8F7A66),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
      );
}
