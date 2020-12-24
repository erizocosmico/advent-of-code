import Foundation

enum Color {
  case black, white
  func flip() -> Color { self == .black ? .white : .black }
}

struct Pos: Hashable {
  let x: Int
  let y: Int
}

enum ParseError: Error {
  case invalid(String)
}

enum Direction {
  case northeast, northwest
  case southeast, southwest
  case east, west

  func follow(_ current: Pos) -> Pos {
    let (x, y) = (current.x, current.y)
    switch self {
    case .northeast: return Pos(x: x + 1, y: y + 1)
    case .northwest: return Pos(x: x, y: y + 1)
    case .southeast: return Pos(x: x, y: y - 1)
    case .southwest: return Pos(x: x - 1, y: y - 1)
    case .east: return Pos(x: x + 1, y: y)
    case .west: return Pos(x: x - 1, y: y)
    }
  }
}

typealias Hexgrid = [Pos: Color]

func parseDirections(_ s: String) throws -> [Direction] {
  var dirs = [Direction]()
  var i = s.startIndex

  while i < s.endIndex {
    let ch = String(s[i])
    let dir: Direction

    switch ch {
    case "e": dir = .east
    case "w": dir = .west
    case "s", "n":
      i = s.index(after: i)
      let sch = String(s[i])
      switch ch + sch {
      case "ne": dir = .northeast
      case "nw": dir = .northwest
      case "se": dir = .southeast
      case "sw": dir = .southwest
      default:
        throw ParseError.invalid(ch + sch)
      }
    default:
      throw ParseError.invalid(ch)
    }

    dirs.append(dir)
    i = s.index(after: i)
  }

  return dirs
}

func followDirections(_ directions: [[Direction]]) -> Hexgrid {
  var grid = Hexgrid()

  for tileDirections in directions {
    var pos = Pos(x: 0, y: 0)
    for dir in tileDirections {
      pos = dir.follow(pos)
    }
    grid.updateValue((grid[pos] ?? .white).flip(), forKey: pos)
  }

  return grid
}

let adjacents: [Direction] = [.west, .east, .southeast, .southwest, .northeast, .northwest]

func flipTiles(_ grid: Hexgrid) -> Hexgrid {
  var new = grid
  let xs = grid.keys.map { $0.x }
  let ys = grid.keys.map { $0.y }
  let (minx, maxx) = (xs.min()! - 1, xs.max()! + 1)
  let (miny, maxy) = (ys.min()! - 1, ys.max()! + 1)

  for x in minx...maxx {
    for y in miny...maxy {
      let pos = Pos(x: x, y: y)
      let blackAdjacents = adjacents.map { (d: Direction) -> Pos in d.follow(pos) }
        .filter { (p: Pos) -> Bool in p.x >= minx && p.x <= maxx && p.y >= miny && p.y <= maxy }
        .map { (p: Pos) -> Color in grid[p] ?? .white }
        .filter { $0 == .black }
        .count

      switch grid[pos] ?? .white {
      case .white:
        if blackAdjacents == 2 {
          new.updateValue(.black, forKey: pos)
        }
      case .black:
        if blackAdjacents == 0 || blackAdjacents > 2 {
          new.updateValue(.white, forKey: pos)
        }
      }
    }
  }

  return new
}

let directions = try String(contentsOfFile: "./input.txt", encoding: .utf8)
  .components(separatedBy: "\n")
  .map(parseDirections)

var grid = followDirections(directions)

print("part 1:", grid.values.filter { $0 == .black }.count)

for _ in 1...100 {
  grid = flipTiles(grid)
}

print("part 2:", grid.values.filter { $0 == .black }.count)
