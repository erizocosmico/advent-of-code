import Foundation

func isTree(_ map: [[Character]], x: Int, y: Int) -> Bool {
  let row = map[y]
  return row[x % row.count] == Character("#")
}

func treesInSlope(_ map: [[Character]], slopeX: Int, slopeY: Int) -> Int {
  var (x, y) = (0, 0)
  var trees = 0
  while y < map.count {
    if isTree(map, x: x, y: y) {
      trees += 1
    }

    x += slopeX
    y += slopeY
  }
  return trees
}

let map = (try String(contentsOfFile: "./input.txt", encoding: .utf8))
  .components(separatedBy: "\n")
  .map { s in Array(s) }

print(treesInSlope(map, slopeX: 3, slopeY: 1))
