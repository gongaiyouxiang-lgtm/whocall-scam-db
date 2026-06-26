import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class GameTile extends StatelessWidget {
  final int value;
  final int row;
  final int col;
  final double cellSize;
  final bool isNew;
  final bool isMerged;

  static const _gap = 10.0;
  static const _pad = 10.0;

  const GameTile({
    super.key,
    required this.value,
    required this.row,
    required this.col,
    required this.cellSize,
    this.isNew = false,
    this.isMerged = false,
  });

  // (background, text) — vivid rainbow palette
  static const _palette = <int, (Color, Color)>{
    2:    (Color(0xFF64B5F6), Colors.white),   // blue
    4:    (Color(0xFF4DD0E1), Colors.white),   // cyan
    8:    (Color(0xFF81C784), Colors.white),   // green
    16:   (Color(0xFFDCE775), Color(0xFF333333)), // lime
    32:   (Color(0xFFFFD54F), Color(0xFF333333)), // yellow
    64:   (Color(0xFFFFB74D), Colors.white),   // orange
    128:  (Color(0xFFFF8A65), Colors.white),   // deep orange
    256:  (Color(0xFFF06292), Colors.white),   // pink
    512:  (Color(0xFFBA68C8), Colors.white),   // purple
    1024: (Color(0xFF7986CB), Colors.white),   // indigo
    2048: (Color(0xFFFFD700), Color(0xFF333333)), // gold
  };

  static (Color, Color) _colorFor(int v) =>
      _palette[v] ?? (const Color(0xFFE53935), Colors.white); // red for super

  double get _fontSize {
    if (value >= 1000) return 18;
    if (value >= 100)  return 24;
    return 32;
  }

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = _colorFor(value);

    Widget tile = AnimatedPositioned(
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
      left: _pad + col * (cellSize + _gap),
      top:  _pad + row * (cellSize + _gap),
      width: cellSize,
      height: cellSize,
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: bg.withOpacity(0.5),
              blurRadius: 8,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Center(
          child: Text(
            '$value',
            style: TextStyle(
              fontSize: _fontSize,
              fontWeight: FontWeight.w900,
              color: fg,
            ),
          ),
        ),
      ),
    );

    if (isNew) {
      tile = tile
          .animate()
          .scale(
            begin: const Offset(0, 0),
            end: const Offset(1, 1),
            duration: 200.ms,
            curve: Curves.elasticOut,
          );
    } else if (isMerged) {
      tile = tile
          .animate()
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.2, 1.2),
            duration: 80.ms,
            curve: Curves.easeOut,
          )
          .then()
          .scale(
            begin: const Offset(1.2, 1.2),
            end: const Offset(1, 1),
            duration: 80.ms,
            curve: Curves.easeIn,
          );
    }

    return tile;
  }
}
