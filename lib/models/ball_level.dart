import 'dart:math';

/// A Ball in the Hole maze, parsed from an ASCII grid.
///
/// Legend: `#` wall, `.` floor, `S` ball start, `G` goal hole, `X` trap hole.
/// Every level must be fully enclosed by walls and contain exactly one `S`
/// and one `G`. Positions are in cell units (cell centres at x.5 / y.5);
/// the renderer decides how many pixels a cell is.
class BallLevel {
  final int cols;
  final int rows;
  final List<bool> _walls; // row-major, true = wall
  final Point<double> start;
  final Point<double> goal;
  final List<Point<double>> traps;

  BallLevel._(
    this.cols,
    this.rows,
    this._walls,
    this.start,
    this.goal,
    this.traps,
  );

  /// Cells outside the grid count as walls, so the ball can never escape
  /// even if a level string had a hole in its border.
  bool isWall(int c, int r) {
    if (c < 0 || c >= cols || r < 0 || r >= rows) return true;
    return _walls[r * cols + c];
  }

  double get aspectRatio => cols / rows;

  factory BallLevel.parse(String ascii) {
    final lines = ascii
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    assert(lines.isNotEmpty, 'Empty level');
    final rows = lines.length;
    final cols = lines.first.length;

    final walls = List<bool>.filled(cols * rows, false);
    Point<double>? start;
    Point<double>? goal;
    final traps = <Point<double>>[];

    for (var r = 0; r < rows; r++) {
      final line = lines[r];
      assert(line.length == cols, 'Row $r has ${line.length} cols, want $cols');
      for (var c = 0; c < cols; c++) {
        final centre = Point(c + 0.5, r + 0.5);
        switch (line[c]) {
          case '#':
            walls[r * cols + c] = true;
          case '.':
            break;
          case 'S':
            assert(start == null, 'Multiple starts');
            start = centre;
          case 'G':
            assert(goal == null, 'Multiple goals');
            goal = centre;
          case 'X':
            traps.add(centre);
          default:
            assert(false, 'Unknown char "${line[c]}" at $c,$r');
        }
      }
    }

    assert(start != null, 'Level has no start (S)');
    assert(goal != null, 'Level has no goal (G)');
    return BallLevel._(cols, rows, walls, start!, goal!, traps);
  }

  /// All levels, easiest first. Interior is 9×13 cells inside a wall border.
  static final List<BallLevel> all = _levelAscii
      .map(BallLevel.parse)
      .toList(growable: false);

  static int get count => _levelAscii.length;
}

// Hand-designed levels. Keep every trap off 1-cell-wide corridors so the
// goal stays reachable — test/ball_level_test.dart BFS-checks each one.
const List<String> _levelAscii = [
  // 1 — open room: learn to tilt.
  '''
###########
#S........#
#.........#
#.........#
#.........#
#....##...#
#....##...#
#.........#
#.........#
#.........#
#.........#
#.........#
#.........#
#........G#
###########
''',
  // 2 — serpentine descent, first trap.
  '''
###########
#S........#
#.........#
#.........#
########..#
#.........#
#.........#
#..########
#.........#
#....X....#
#.........#
########..#
#.........#
#G........#
###########
''',
  // 3 — outer ring with a baited inner box.
  '''
###########
#........S#
#.........#
#..#####..#
#..#...#..#
#..#.X.#..#
#..#...#..#
#..##.##..#
#..#...#..#
#..#...#..#
#..#####..#
#.X.....X.#
#.........#
#G........#
###########
''',
  // 4 — spiral inwards to the goal.
  '''
###########
#S........#
#.#######.#
#.#.....#.#
#.#.###.#.#
#.#.#G#.#.#
#.#.#.#...#
#.#.....#.#
#.#..X..#.#
#.#######.#
#....X....#
#.####.##.#
#....#....#
#..X.#....#
###########
''',
  // 5 — chambers gauntlet.
  '''
###########
#....#...S#
#.X..#....#
#....#.X..#
#.......#.#
###.#####.#
#...#..X..#
#.X.#.....#
#...#.###.#
#.#####...#
#.........#
#..X.###..#
#....#....#
#G...#..X.#
###########
''',
  // 6 — narrow switchback corridors.
  '''
###########
#S#.......#
#.#.#####.#
#.#.#...#.#
#.#.#.#.#.#
#...#.#.#.#
#.###.#.#.#
#.....#.#.#
#####.#.#.#
#....X#.#.#
#.#####.#.#
#.#.....#.#
#.#.#####.#
#...#....G#
###########
''',
  // 7 — open field, trap slalom.
  '''
###########
#S........#
#..X..X..X#
#.........#
#X..X..X..#
#.........#
#..X..X..X#
#....#....#
#X..X#.X..#
#....#....#
#..X.#..X.#
#.........#
#X..X..X..#
#........G#
###########
''',
  // 8 — serpentine gauntlet: weave through the traps on every lane.
  '''
###########
#S........#
#......X..#
########..#
#....X....#
#..X......#
#..########
#....X..X.#
#.........#
########..#
#.X....X..#
#.........#
#..########
#........G#
###########
''',
];
