import Foundation

struct Tile {
  let id: Int
  let tile: [String]

  func borders() -> [String] {
    let top = tile.first!
    let bottom = tile.last!
    let left = String(tile.map { $0.first! })
    let right = String(tile.map { $0.last! })
    return [
      top,
      left,
      right,
      bottom,
      String(top.reversed()),
      String(left.reversed()),
      String(right.reversed()),
      String(bottom.reversed()),
    ]
  }
}

func parseInput(_ input: String) -> [Tile] {
  return input.components(separatedBy: "\n\n").map { tile in
    let lines = tile.components(separatedBy: "\n")
    let id = Int(String(lines.first!.components(separatedBy: " ").last!.dropLast()))!
    return Tile(id: id, tile: [String](lines.dropFirst()))
  }
}

func findCorners(_ tiles: [Tile]) -> [Int] {
  var tileBorders = [String: [Int]]()

  for tile in tiles {
    for border in tile.borders() {
      tileBorders.updateValue((tileBorders[border] ?? []) + [tile.id], forKey: border)
    }
  }

  let uniqueBorders = tileBorders.filter { $0.value.count == 1 }.map { $0.value.first! }
  var uniqueTileBorders = [Int: Int]()
  for id in uniqueBorders {
    uniqueTileBorders.updateValue(1 + (uniqueTileBorders[id] ?? 0), forKey: id)
  }

  return uniqueTileBorders.filter { $0.value == 4 }.map { $0.key }
}

let input = try String(contentsOfFile: "./input.txt", encoding: .utf8)
let corners = findCorners(parseInput(input))

print(corners.reduce(1) { $0 * $1 })
