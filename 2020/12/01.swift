import Foundation

struct Instruction {
  let action: String
  let value: Int
}

let directions: [Direction] = [.north, .east, .south, .west]

enum Direction {
  case north, south, west, east

  func advance(_ x: Int, _ y: Int, n: Int) -> (Int, Int) {
    switch self {
    case .north: return (x, y + n)
    case .south: return (x, y - n)
    case .west: return (x - n, y)
    case .east: return (x + n, y)
    }
  }

  func rotate(_ angle: Int) -> Direction {
    let dir = angle > 0 ? directions : directions.reversed()
    return dir[(Int(dir.firstIndex(of: self)!) + (abs(angle) / 90)) % dir.count]
  }
}

struct Position {
  var x: Int
  var y: Int
}

func navigate(_ instructions: [Instruction]) -> (Int, Int) {
  var dir = Direction.east
  var (x, y) = (0, 0)

  for i in instructions {
    switch i.action {
    case "N": (x, y) = Direction.north.advance(x, y, n: i.value)
    case "S": (x, y) = Direction.south.advance(x, y, n: i.value)
    case "E": (x, y) = Direction.east.advance(x, y, n: i.value)
    case "W": (x, y) = Direction.west.advance(x, y, n: i.value)
    case "L": dir = dir.rotate(-i.value)
    case "R": dir = dir.rotate(i.value)
    case "F": (x, y) = dir.advance(x, y, n: i.value)
    default: continue
    }
  }

  return (x, y)
}

let instructions = try String(contentsOfFile: "./input.txt", encoding: .utf8)
  .components(separatedBy: "\n")
  .map { s in Instruction(action: String(s.prefix(1)), value: Int(String(s.dropFirst()))!) }

let (x, y) = navigate(instructions)
print(abs(x) + abs(y))
