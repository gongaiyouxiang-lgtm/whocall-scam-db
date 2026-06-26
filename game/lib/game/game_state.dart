import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'slide_logic.dart';

enum Direction { up, down, left, right }

class GameState extends ChangeNotifier {
  static const _size = 4;
  static const _kGrid  = 'g2048_grid';
  static const _kScore = 'g2048_score';
  static const _kBest  = 'g2048_best';
  static const _kWon   = 'g2048_won';
  static const _kOver  = 'g2048_over';
  static const _kKeep  = 'g2048_keep';

  List<int> grid = List.filled(16, 0);
  int score = 0;
  int best = 0;
  bool won = false;
  bool over = false;
  bool keepGoing = false;

  final newTiles    = <int>{};
  final mergedTiles = <int>{};

  final _rng = Random();

  // ── Persistence ───────────────────────────────────────────────

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    best = prefs.getInt(_kBest) ?? 0;

    final raw = prefs.getString(_kGrid);
    if (raw != null) {
      try {
        final list = (jsonDecode(raw) as List).cast<int>();
        if (list.length == 16) {
          grid      = list;
          score     = prefs.getInt(_kScore)  ?? 0;
          won       = prefs.getBool(_kWon)   ?? false;
          over      = prefs.getBool(_kOver)  ?? false;
          keepGoing = prefs.getBool(_kKeep)  ?? false;
          notifyListeners();
          return;
        }
      } catch (_) {}
    }

    _startGame();
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setString(_kGrid,  jsonEncode(grid)),
      prefs.setInt(_kScore,    score),
      prefs.setInt(_kBest,     best),
      prefs.setBool(_kWon,     won),
      prefs.setBool(_kOver,    over),
      prefs.setBool(_kKeep,    keepGoing),
    ]);
  }

  // ── Game Actions ─────────────────────────────────────────────

  void newGame() {
    _startGame();
    _persist();
    notifyListeners();
  }

  void continueAfterWin() {
    keepGoing = true;
    _persist();
    notifyListeners();
  }

  void _startGame() {
    grid = List.filled(16, 0);
    score     = 0;
    won       = false;
    over      = false;
    keepGoing = false;
    newTiles.clear();
    mergedTiles.clear();
    _spawnTile();
    _spawnTile();
  }

  // ── Core Logic ───────────────────────────────────────────────

  void _spawnTile() {
    final empty = <int>[];
    for (var i = 0; i < 16; i++) {
      if (grid[i] == 0) empty.add(i);
    }
    if (empty.isEmpty) return;
    final idx = empty[_rng.nextInt(empty.length)];
    grid[idx] = _rng.nextDouble() < 0.9 ? 2 : 4;
    newTiles.add(idx);
  }

  bool move(Direction dir) {
    if (over || (won && !keepGoing)) return false;
    newTiles.clear();
    mergedTiles.clear();

    var anyChanged = false;

    for (var i = 0; i < _size; i++) {
      final isHoriz  = dir == Direction.left || dir == Direction.right;
      final reversed = dir == Direction.right || dir == Direction.down;

      var line = isHoriz
          ? [for (var c = 0; c < _size; c++) grid[i * _size + c]]
          : [for (var r = 0; r < _size; r++) grid[r * _size + i]];
      if (reversed) line = line.reversed.toList();

      final res = slideLine(line);
      if (!res.changed) continue;
      anyChanged = true;
      score += res.scoreAdded;
      if (score > best) best = score;

      for (final mi in res.mergedAt) {
        final ei = reversed ? (_size - 1 - mi) : mi;
        mergedTiles.add(isHoriz ? i * _size + ei : ei * _size + i);
      }

      var result = res.line;
      if (reversed) result = result.reversed.toList();
      if (isHoriz) {
        for (var c = 0; c < _size; c++) grid[i * _size + c] = result[c];
      } else {
        for (var r = 0; r < _size; r++) grid[r * _size + i] = result[r];
      }
    }

    if (!anyChanged) return false;

    _spawnTile();
    if (!won && grid.contains(2048)) won = true;
    if (!_hasMove()) over = true;

    _persist();
    notifyListeners();
    return true;
  }

  bool _hasMove() {
    for (var i = 0; i < 16; i++) {
      if (grid[i] == 0) return true;
      if (i % _size < _size - 1 && grid[i] == grid[i + 1]) return true;
      if (i < _size * (_size - 1) && grid[i] == grid[i + _size]) return true;
    }
    return false;
  }
}
