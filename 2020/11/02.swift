import Foundation

enum Tile {
  case floor
  case emptySeat
  case occupiedSeat
}

typealias Grid = [[Tile]]

let directions = [
  (-1, -1),
  (-1, 0),
  (-1, 1),
  (0, -1),
  (0, 1),
  (1, -1),
  (1, 0),
  (1, 1),
]

func visibleOccupiedSeats(_ grid: Grid, x: Int, y: Int) -> Int {
  var occupied = 0
  for (dx, dy) in directions {
    var (x, y) = (x + dx, y + dy)
    while x >= 0 && y >= 0 && y < grid.count && x < grid[y].count {
      if grid[y][x] == .floor {
        x += dx
        y += dy
      } else {
        if grid[y][x] == .occupiedSeat {
          occupied += 1
        }
        break
      }
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
        if visibleOccupiedSeats(grid, x: x, y: y) == 0 {
          result[y][x] = .occupiedSeat
        }
      case .occupiedSeat:
        if visibleOccupiedSeats(grid, x: x, y: y) >= 5 {
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
