class SlideResult {
  final List<int> line;
  final bool changed;
  final Set<int> mergedAt;
  final int scoreAdded;

  const SlideResult({
    required this.line,
    required this.changed,
    required this.mergedAt,
    required this.scoreAdded,
  });
}

SlideResult slideLine(List<int> line) {
  assert(line.length == 4);
  final original = List<int>.from(line);
  final tiles = line.where((v) => v != 0).toList();
  final merged = <int>{};
  var scoreAdded = 0;

  var i = 0;
  while (i < tiles.length - 1) {
    if (tiles[i] == tiles[i + 1]) {
      tiles[i] *= 2;
      scoreAdded += tiles[i];
      tiles.removeAt(i + 1);
      merged.add(i);
    }
    i++;
  }

  while (tiles.length < 4) tiles.add(0);

  var changed = false;
  for (var j = 0; j < 4; j++) {
    if (original[j] != tiles[j]) {
      changed = true;
      break;
    }
  }

  return SlideResult(
    line: tiles,
    changed: changed,
    mergedAt: merged,
    scoreAdded: scoreAdded,
  );
}
