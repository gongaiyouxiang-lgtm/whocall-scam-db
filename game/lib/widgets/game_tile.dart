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

  static const _palette = <int, (Color, Color)>{
    2:    (Color(0xFFEEE4DA), Color(0xFF776E65)),
    4:    (Color(0xFFEDE0C8), Color(0xFF776E65)),
    8:    (Color(0xFFF2B179), Color(0xFFF9F6F2)),
    16:   (Color(0xFFF59563), Color(0xFFF9F6F2)),
    32:   (Color(0xFFF67C5F), Color(0xFFF9F6F2)),
    64:   (Color(0xFFF65E3B), Color(0xFFF9F6F2)),
    128:  (Color(0xFFEDCF72), Color(0xFFF9F6F2)),
    256:  (Color(0xFFEDCC61), Color(0xFFF9F6F2)),
    512:  (Color(0xFFEDC850), Color(0xFFF9F6F2)),
    1024: (Color(0xFFEDC53F), Color(0xFFF9F6F2)),
    2048: (Color(0xFFEDC22E), Color(0xFFF9F6F2)),
  };

  static (Color, Color) _colorFor(int v) =>
      _palette[v] ?? (const Color(0xFF3C3A32), const Color(0xFFF9F6F2));

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
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 4,
              offset: const Offset(0, 2),
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
            end: const Offset(1.15, 1.15),
            duration: 80.ms,
            curve: Curves.easeOut,
          )
          .then()
          .scale(
            begin: const Offset(1.15, 1.15),
            end: const Offset(1, 1),
            duration: 80.ms,
            curve: Curves.easeIn,
          );
    }

    return tile;
  }
}
