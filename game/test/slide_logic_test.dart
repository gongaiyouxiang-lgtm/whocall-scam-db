import 'package:test/test.dart';
import 'package:flutter_2048/game/slide_logic.dart';

void main() {
  group('slideLine', () {
    test('merges adjacent equal pairs', () {
      final r = slideLine([2, 2, 4, 4]);
      expect(r.line, [4, 8, 0, 0]);
      expect(r.changed, isTrue);
      expect(r.scoreAdded, 12);
    });

    test('no change when already compacted', () {
      final r = slideLine([4, 8, 0, 0]);
      expect(r.changed, isFalse);
      expect(r.scoreAdded, 0);
    });

    test('does not double-merge in one pass', () {
      final r = slideLine([2, 2, 2, 2]);
      expect(r.line, [4, 4, 0, 0]);
    });

    test('compacts zeros and merges', () {
      final r = slideLine([0, 2, 0, 2]);
      expect(r.line, [4, 0, 0, 0]);
    });

    test('single tile slides to front', () {
      final r = slideLine([0, 0, 0, 8]);
      expect(r.line, [8, 0, 0, 0]);
      expect(r.changed, isTrue);
    });

    test('no merge with different values', () {
      final r = slideLine([2, 4, 2, 4]);
      expect(r.line, [2, 4, 2, 4]);
      expect(r.changed, isFalse);
    });

    test('merge at right boundary', () {
      final r = slideLine([0, 0, 4, 4]);
      expect(r.line, [8, 0, 0, 0]);
    });

    test('records merged index', () {
      final r = slideLine([2, 2, 0, 0]);
      expect(r.mergedAt, contains(0));
    });
  });
}
