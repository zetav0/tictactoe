import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/models/ball_level.dart';

void main() {
  group('BallLevel definitions', () {
    test('there are levels', () {
      expect(BallLevel.all, isNotEmpty);
    });

    for (var i = 0; i < BallLevel.all.length; i++) {
      final n = i + 1;

      test('level $n is structurally valid', () {
        final level = BallLevel.all[i];

        // Fully enclosed by a wall border.
        for (var c = 0; c < level.cols; c++) {
          expect(level.isWall(c, 0), isTrue, reason: 'top border open at $c');
          expect(
            level.isWall(c, level.rows - 1),
            isTrue,
            reason: 'bottom border open at $c',
          );
        }
        for (var r = 0; r < level.rows; r++) {
          expect(level.isWall(0, r), isTrue, reason: 'left border open at $r');
          expect(
            level.isWall(level.cols - 1, r),
            isTrue,
            reason: 'right border open at $r',
          );
        }

        // Start, goal and traps sit on open floor.
        for (final p in [level.start, level.goal, ...level.traps]) {
          expect(
            level.isWall(p.x.floor(), p.y.floor()),
            isFalse,
            reason: 'feature at $p is inside a wall',
          );
        }

        // Goal is not right where the ball spawns.
        expect(level.start, isNot(equals(level.goal)));
      });

      test('level $n goal is reachable without crossing a trap', () {
        final level = BallLevel.all[i];
        final trapCells = {
          for (final t in level.traps) t.y.floor() * level.cols + t.x.floor(),
        };

        bool passable(int c, int r) =>
            !level.isWall(c, r) && !trapCells.contains(r * level.cols + c);

        final startCell = (level.start.x.floor(), level.start.y.floor());
        final goalCell = (level.goal.x.floor(), level.goal.y.floor());

        final visited = <(int, int)>{startCell};
        final queue = [startCell];
        var found = false;
        while (queue.isNotEmpty) {
          final (c, r) = queue.removeLast();
          if ((c, r) == goalCell) {
            found = true;
            break;
          }
          for (final (nc, nr) in [(c + 1, r), (c - 1, r), (c, r + 1), (c, r - 1)]) {
            if (passable(nc, nr) && visited.add((nc, nr))) {
              queue.add((nc, nr));
            }
          }
        }
        expect(found, isTrue, reason: 'no trap-free path from start to goal');
      });
    }
  });
}
