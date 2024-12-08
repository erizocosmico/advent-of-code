import Foundation

let input = try String(contentsOfFile: "./inputs/08.txt", encoding: .utf8)
let map = input.split(separator: "\n").map { $0.map { String($0) } }
let bounds = (x: map[0].count, y: map.count)

struct Point: Hashable {
  let x: Int
  let y: Int

  init(_ x: Int, _ y: Int) {
    self.x = x
    self.y = y
  }
}

func antinodes(antennas: [Point], resonance: Bool) -> Set<Point> {
  var result = Set<Point>()

  if antennas.count <= 1 {
    return result
  }

  for (i, p1) in antennas.enumerated() {
    if resonance {
      result.insert(p1)
    }

    for (j, p2) in antennas.enumerated() {
      if i == j {
        continue
      }

      let (dx, dy) = (p1.x - p2.x, p1.y - p2.y)
      var a = p1

      while true {
        a = Point(a.x + dx, a.y + dy)
        if a.x >= 0 && a.x < bounds.x && a.y >= 0 && a.y < bounds.y {
          result.insert(a)
        } else {
          break
        }

        if !resonance {
          break
        }
      }
    }
  }

  return result
}

var antennas = [String: [Point]]()

for (y, row) in map.enumerated() {
  for (x, freq) in row.enumerated() {
    if freq == "." {
      continue
    }

    var a = antennas[freq] ?? []
    a.append(Point(x, y))
    antennas[freq] = a
  }
}

print("Part one:", Set(antennas.values.flatMap { antinodes(antennas: $0, resonance: false) }).count)
print("Part two:", Set(antennas.values.flatMap { antinodes(antennas: $0, resonance: true) }).count)
