import Foundation

let input = try String(contentsOfFile: "./inputs/04.txt", encoding: .utf8)
let grid = input.split(separator: "\n").map { [Character]($0) }

let directions = [
  (-1, -1),
  (0, -1),
  (1, -1),
  (1, 0),
  (1, 1),
  (0, 1),
  (-1, 1),
  (-1, 0),
]

func search(_ pattern: String, _ x: Int, _ y: Int) -> [[(Int, Int)]] {
  var result = [[(Int, Int)]]()
  for (dx, dy) in directions {
    var s = [(Int, Int)]()
    for i in 0..<pattern.count {
      s.append((dx * i + x, dy * i + y))
    }
    result.append(s)
  }
  return result
}

func part1(_ grid: [[Character]]) -> Int {
  var count = 0
  for y in 0..<grid.count {
    for x in 0..<grid[0].count {
      if grid[y][x] != "X" {
        continue
      }

      count += search("XMAS", x, y).count { matches(grid, "XMAS", $0) }
    }
  }
  return count
}

let xsearch = [
  [
    (0, 0),
    (1, 1),
    (2, 2),
  ],
  [
    (0, 2),
    (1, 1),
    (2, 0),
  ],
]

func part2(_ grid: [[Character]]) -> Int {
  var count = 0
  for y in 0..<grid.count {
    for x in 0..<grid[0].count {
      if grid[y][x] != "M" && grid[y][x] != "S" {
        continue
      }

      let matched = xsearch.allSatisfy { (search) in
        let points = search.map { (x + $0.0, y + $0.1) }
        return matches(grid, "MAS", points) || matches(grid, "SAM", points)
      }

      if matched {
        count += 1
      }
    }
  }
  return count
}

func isValidPoint(_ grid: [[Character]], _ p: (Int, Int)) -> Bool {
  return p.0 < 0 || p.0 >= grid[0].count || p.1 < 0 || p.1 >= grid.count
}

func matches(_ grid: [[Character]], _ pattern: String, _ points: [(Int, Int)]) -> Bool {
  if points.first(where: { isValidPoint(grid, $0) }) != nil {
    return false
  }

  return String(points.map { grid[$0.1][$0.0] }) == pattern
}

print("Part one:", part1(grid))
print("Part two:", part2(grid))
