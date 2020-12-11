import Foundation

enum Tile {
  case floor
  case emptySeat
  case occupiedSeat
}

typealias Grid = [[Tile]]

let adjacents = [
  (-1, -1),
  (-1, 0),
  (-1, 1),
  (0, -1),
  (0, 1),
  (1, -1),
  (1, 0),
  (1, 1),
]

func adjacentOccupiedSeats(_ grid: Grid, x: Int, y: Int) -> Int {
  var occupied = 0
  for (dx, dy) in adjacents {
    let (x, y) = (x + dx, y + dy)
    if x >= 0 && y >= 0
      && y < grid.count
      && x < grid[y].count
      && grid[y][x] == .occupiedSeat
    {
      occupied += 1
    }
  }
  return occupied
}

func nextState(_ grid: Grid) -> Grid {
  var result = grid

  for y in 0..<grid.count {
    for x in 0..<grid[y].count {
      switch grid[y][x] {
      case .emptySeat:
        if adjacentOccupiedSeats(grid, x: x, y: y) == 0 {
          result[y][x] = .occupiedSeat
        }
      case .occupiedSeat:
        if adjacentOccupiedSeats(grid, x: x, y: y) >= 4 {
          result[y][x] = .emptySeat
        }
      default: continue
      }
    }
  }

  return result
}

func findStableState(_ grid: Grid) -> Grid {
  var current = grid
  var next = nextState(grid)
  while current != next {
    current = next
    next = nextState(current)
  }

  return next
}

func occupiedSeats(_ grid: Grid) -> Int {
  return grid.reduce(0) { (acc, row) in
    return acc + row.filter { $0 == .occupiedSeat }.count
  }
}

let grid: Grid = try String(contentsOfFile: "./input.txt", encoding: .utf8)
  .components(separatedBy: "\n")
  .map { $0.map { $0 == Character(".") ? Tile.floor : Tile.emptySeat } }

print(occupiedSeats(findStableState(grid)))
