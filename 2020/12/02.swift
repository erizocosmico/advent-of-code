import Foundation

struct Instruction {
  let action: String
  let value: Int
}

let directions: [Direction] = [.north, .east, .south, .west]

enum Direction {
  case north, south, west, east
}

struct Waypoint {
  var x: (Int, Direction)
  var y: (Int, Direction)

  mutating func rotate(_ angle: Int) {
    let dirs = angle > 0 ? directions : directions.reversed()
    let xdir = dirs[(Int(dirs.firstIndex(of: x.1)!) + (abs(angle) / 90)) % dirs.count]
    let ydir = dirs[(Int(dirs.firstIndex(of: y.1)!) + (abs(angle) / 90)) % dirs.count]
    let swap = (abs(angle) / 90) % 2 != 0
    let (newx, newy) = (abs(swap ? y.0 : x.0), abs(swap ? x.0 : y.0))
    x = (newx, swap ? ydir : xdir)
    y = (newy, swap ? xdir : ydir)
  }

  mutating func move(_ dir: Direction, _ n: Int) {
    switch dir {
    case .east, .west:
      if dir == x.1 {
        x = (x.0 + n, dir)
      } else if x.0 < n {
        x = (n - x.0, x.1 == .east ? .west : .east)
      } else {
        x = (x.0 - n, x.1)
      }
    case .north, .south:
      if dir == y.1 {
        y = (y.0 + n, dir)
      } else if y.0 < n {
        y = (n - y.0, y.1 == .north ? .south : .north)
      } else {
        y = (y.0 - n, y.1)
      }
    }
  }

}

struct Ship {
  var x: Int
  var y: Int

  mutating func move(_ dir: Direction, _ n: Int) {
    switch dir {
    case .east: x += n
    case .west: x -= n
    case .north: y += n
    case .south: y -= n
    }
  }

}

func navigate(_ instructions: [Instruction]) -> (Int, Int) {
  var waypoint = Waypoint(x: (10, .east), y: (1, .north))
  var ship = Ship(x: 0, y: 0)

  for i in instructions {
    switch i.action {
    case "N": waypoint.move(.north, i.value)
    case "S": waypoint.move(.south, i.value)
    case "E": waypoint.move(.east, i.value)
    case "W": waypoint.move(.west, i.value)
    case "L": waypoint.rotate(-i.value)
    case "R": waypoint.rotate(i.value)
    case "F":
      ship.move(waypoint.x.1, waypoint.x.0 * i.value)
      ship.move(waypoint.y.1, waypoint.y.0 * i.value)
    default: continue
    }
  }

  return (ship.x, ship.y)
}

let instructions = try String(contentsOfFile: "./input.txt", encoding: .utf8)
  .components(separatedBy: "\n")
  .map { s in Instruction(action: String(s.prefix(1)), value: Int(String(s.dropFirst()))!) }

let (x, y) = navigate(instructions)
print(abs(x) + abs(y))
