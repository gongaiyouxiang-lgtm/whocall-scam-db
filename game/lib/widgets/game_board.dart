import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../game/game_state.dart';
import 'game_tile.dart';

class GameBoard extends StatelessWidget {
  final GameState game;
  const GameBoard({super.key, required this.game});

  static const _gap = 10.0;
  static const _pad = 10.0;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: game,
      builder: (context, _) => Focus(
        autofocus: true,
        onKeyEvent: _handleKey,
        child: GestureDetector(
          onHorizontalDragEnd: (d) {
            final v = d.primaryVelocity ?? 0;
            if (v.abs() > 150) {
              game.move(v > 0 ? Direction.right : Direction.left);
            }
          },
          onVerticalDragEnd: (d) {
            final v = d.primaryVelocity ?? 0;
            if (v.abs() > 150) {
              game.move(v > 0 ? Direction.down : Direction.up);
            }
          },
          child: AspectRatio(
            aspectRatio: 1,
            child: LayoutBuilder(builder: _buildBoard),
          ),
        ),
      ),
    );
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final dir = {
      LogicalKeyboardKey.arrowUp:    Direction.up,
      LogicalKeyboardKey.arrowDown:  Direction.down,
      LogicalKeyboardKey.arrowLeft:  Direction.left,
      LogicalKeyboardKey.arrowRight: Direction.right,
    }[event.logicalKey];
    if (dir == null) return KeyEventResult.ignored;
    game.move(dir);
    return KeyEventResult.handled;
  }

  Widget _buildBoard(BuildContext context, BoxConstraints constraints) {
    final size = constraints.maxWidth;
    final cellSize = (size - _pad * 2 - _gap * 3) / 4;

    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: const Color(0xFFBBADA0),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            children: [
              for (var i = 0; i < 16; i++)
                _bgCell(i ~/ 4, i % 4, cellSize),
              for (var i = 0; i < 16; i++)
                if (game.grid[i] != 0)
                  GameTile(
                    key: ValueKey('t${i}_${game.grid[i]}'),
                    value: game.grid[i],
                    row: i ~/ 4,
                    col: i % 4,
                    cellSize: cellSize,
                    isNew: game.newTiles.contains(i),
                    isMerged: game.mergedTiles.contains(i),
                  ),
            ],
          ),
        ),
        if (game.won && !game.keepGoing)
          _overlay('🎉 You reached 2048!', 'Keep Going', game.continueAfterWin),
        if (game.over)
          _overlay('Game Over', 'New Game', game.newGame),
      ],
    );
  }

  Widget _bgCell(int r, int c, double cellSize) => Positioned(
        left: _pad + c * (cellSize + _gap),
        top:  _pad + r * (cellSize + _gap),
        width: cellSize,
        height: cellSize,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFCDC1B4),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      );

  Widget _overlay(String msg, String btnText, VoidCallback onTap) =>
      Positioned.fill(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            color: const Color(0xFFFAF8EF).withOpacity(0.82),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  msg,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF776E65),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8F7A66),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: Text(
                    btnText,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
