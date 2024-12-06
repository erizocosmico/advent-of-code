import Foundation

enum Direction {
  case up
  case down
  case left
  case right
}

enum Tile {
  case obstacle
  case empty
}

enum PathError: Error {
  case loop
}

struct Point: Hashable {
  let x: Int
  let y: Int

  func inBounds(_ bounds: (x: Int, y: Int)) -> Bool {
    return x >= 0 && x < bounds.x && y >= 0 && y < bounds.y
  }
}

struct Position: Hashable {
  let pos: Point
  let dir: Direction

  init(_ pos: Point, _ dir: Direction) {
    self.pos = pos
    self.dir = dir
  }

  func advance() -> Position {
    switch self.dir {
    case .up: Position(Point(x: pos.x, y: pos.y - 1), dir)
    case .left: Position(Point(x: pos.x - 1, y: pos.y), dir)
    case .right: Position(Point(x: pos.x + 1, y: pos.y), dir)
    case .down: Position(Point(x: pos.x, y: pos.y + 1), dir)
    }
  }

  func rotate() -> Position {
    switch self.dir {
    case .up: Position(pos, .right)
    case .left: Position(pos, .up)
    case .right: Position(pos, .down)
    case .down: Position(pos, .left)
    }
  }
}

func patrolPath(_ map: [[Tile]], start: Point) throws -> Set<Point> {
  return try! patrolPath(map, start: start, obstacle: nil)
}

func patrolPath(_ map: [[Tile]], start: Point, obstacle: Point?) throws -> Set<Point> {
  let bounds = (x: map[0].count, y: map.count)
  var pos = Position(start, .up)
  var path = Set<Position>()
  path.insert(pos)
  while true {
    let newPos = pos.advance()
    if !newPos.pos.inBounds(bounds) {
      break
    }

    if map[newPos.pos.y][newPos.pos.x] == .obstacle
      || (obstacle != nil && obstacle == newPos.pos)
    {
      pos = pos.rotate()
    } else {
      if path.contains(newPos) {
        throw PathError.loop
      }
      pos = newPos
      path.insert(newPos)
    }
  }
  return Set(path.map { $0.pos })
}

func obstructableTiles(_ map: [[Tile]], start: Point, path: Set<Point>) -> Set<Point> {
  return try! path.filter { $0 != start }.filter { obs in
    do {
      let _ = try patrolPath(map, start: start, obstacle: obs)
      return false
    } catch PathError.loop {
      return true
    }
  }
}

let input = try String(contentsOfFile: "./inputs/06.txt", encoding: .utf8)
var guardStart = Point(x: 0, y: 0)
let map = input.split(separator: "\n").enumerated().map { (y, line) in
  line.enumerated().map { (x, ch) in
    switch ch {
    case "#": return Tile.obstacle
    case "^":
      guardStart = Point(x: x, y: y)
      fallthrough
    default: return Tile.empty
    }
  }
}

let path = try! patrolPath(map, start: guardStart)
print("Part one:", path.count)
print("Part two:", obstructableTiles(map, start: guardStart, path: path).count)
