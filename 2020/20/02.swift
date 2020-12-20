import Foundation

enum Border: Hashable {
  case top(String)
  case left(String)
  case right(String)
  case bottom(String)

  func value() -> String {
    switch self {
    case .top(let v): return v
    case .left(let v): return v
    case .bottom(let v): return v
    case .right(let v): return v
    }
  }
}

func gridFlips(_ x: [String]) -> [[String]] {
  return [
    x,
    x.reversed(),
    x.map { String($0.reversed()) },
    x.reversed().map { String($0.reversed()) },
  ]
}

func gridRotations(_ x: [String]) -> [[String]] {
  var rotations = [x.map { [Character]($0) }]

  for _ in 1...4 {
    let last = rotations.last!
    var tile = last
    for y in 0..<tile.count {
      for x in 0..<tile.count {
        tile[x][y] = last[tile.count - y - 1][x]
      }
    }
    rotations.append(tile)
  }

  return rotations.map { $0.map { String($0) } }
}

func gridPermutations(_ x: [String]) -> [[String]] {
  var permutations = Set<[String]>()
  for flip in gridFlips(x) {
    for rotation in gridRotations(flip) {
      permutations.update(with: rotation)
    }
  }
  return [[String]](permutations)
}

struct Tile: Hashable {
  let id: Int
  let tile: [String]

  func borders() -> [Border] {
    let top = tile.first!
    let bottom = tile.last!
    let left = String(tile.map { $0.first! })
    let right = String(tile.map { $0.last! })
    return [.top(top), .left(left), .bottom(bottom), .right(right)]
  }

  func flips() -> [Tile] {
    return gridFlips(tile).map { Tile(id: id, tile: $0) }
  }

  func rotations() -> [Tile] {
    return gridRotations(tile).map { Tile(id: id, tile: $0) }
  }

  func permutations() -> [Tile] {
    return gridPermutations(tile).map { Tile(id: id, tile: $0) }
  }

  func withoutBorders() -> Tile {
    let t = tile.dropFirst().dropLast().map { String($0.dropFirst().dropLast()) }
    return Tile(id: id, tile: t)
  }
}

func parseInput(_ input: String) -> [Tile] {
  return input.components(separatedBy: "\n\n").map { tile in
    let lines = tile.components(separatedBy: "\n")
    let id = Int(String(lines.first!.components(separatedBy: " ").last!.dropLast()))!
    return Tile(id: id, tile: [String](lines.dropFirst()))
  }
}

func assemble(_ tiles: [Tile]) -> [[Tile]] {
  var borders = [Border: [Tile]]()
  let side = Int(Double(tiles.count).squareRoot())
  var grid = [[Tile?]](repeatElement([Tile?](repeatElement(nil, count: side)), count: side))
  var permutations = tiles.flatMap { $0.permutations() }
  for perm in permutations {
    for border in perm.borders() {
      borders.updateValue((borders[border] ?? []) + [perm], forKey: border)
    }
  }

  for y in 0..<side {
    for x in 0..<side {
      let tile = permutations.first { t in
        let bs = t.borders()
        let (top, left, bottom, right) = (bs[0], bs[1], bs[2], bs[3])

        // Discard if is the top edge and does not have an unmatched top border.
        if y == 0 && borders[top]!.filter({ $0.id != t.id }).count > 0 {
          return false
        }

        // Discard if is not on the bottom edge and the bottom border has no matching top border.
        if y < side - 1 && borders[.top(bottom.value())]!.filter({ $0.id != t.id }).count == 0 {
          return false
        }

        // Discard if is not on the right edge and the right border has no matching left border.
        if x < side - 1 && borders[.left(right.value())]!.filter({ $0.id != t.id }).count == 0 {
          return false
        }

        // Discard if is not on an edge and the top border does not match the previous bottom border.
        if y > 0 && top.value() != grid[y - 1][x]!.borders()[2].value() {
          return false
        }

        // Discard if is the left edge and does not have an unmatched left border.
        if x == 0 && borders[left]!.filter({ $0.id != t.id }).count > 0 {
          return false
        }

        // Discard if is not on an edge and the left border does not match the previous right border.
        if x > 0 && left.value() != grid[y][x - 1]!.borders()[3].value() {
          return false
        }

        // Discard if is the bottom edge and does not have an unmatched bottom border.
        if y == side - 1 && borders[bottom]!.filter({ $0.id != t.id }).count > 0 {
          return false
        }

        // Discard if is the right edge and does not have an unmatched right border.
        if x == side - 1 && borders[right]!.filter({ $0.id != t.id }).count > 0 {
          return false
        }

        return true
      }!

      grid[y][x] = tile
      permutations = permutations.filter { $0.id != tile.id }
    }
  }

  return grid.map { $0.map { $0!.withoutBorders() } }
}

func combineImage(_ image: [[Tile]]) -> [String] {
  var result = [String](repeatElement("", count: image.count * image[0][0].tile.count))
  for (i, row) in image.enumerated() {
    for col in row {
      for (j, line) in col.tile.enumerated() {
        let idx = i * col.tile.count + j
        result[idx] = result[idx] + line
      }
    }
  }

  return result
}

let seaMonster = [
  (0, 1), (1, 2), (4, 2),
  (5, 1), (6, 1), (7, 2),
  (10, 2), (11, 1), (12, 1),
  (13, 2), (16, 2), (17, 1),
  (18, 1), (19, 1), (18, 0),
]

func detectSeaMonsters(_ img: [[Character]]) -> [[(Int, Int)]] {
  var result = [[(Int, Int)]]()
  for y in 0..<(img.count - 3) {
    for x in 0..<(img[0].count - 20) {
      let monster = seaMonster.map { pos in (x + pos.0, y + pos.1) }
      if monster.allSatisfy({ img[$0.1][$0.0] == Character("#") }) {
        result.append(monster)
      }
    }
  }
  return result
}

func waterRoughness(_ image: [String]) -> Int? {
  for img in gridPermutations(image) {
    var img = img.map { [Character]($0) }
    let monsters = detectSeaMonsters(img)
    if monsters.count == 0 {
      continue
    }

    for monster in monsters {
      for (x, y) in monster {
        img[y][x] = Character(".")
      }
    }

    var roughness = 0
    for row in img {
      for col in row {
        if col == Character("#") {
          roughness += 1
        }
      }
    }
    return roughness
  }
  return nil
}

let input = try String(contentsOfFile: "./input.txt", encoding: .utf8)
let image = assemble(parseInput(input))
let combinedImage = combineImage(image)
print(waterRoughness(combinedImage)!)
