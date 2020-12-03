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

let slopes = [
  (1, 1),
  (3, 1),
  (5, 1),
  (7, 1),
  (1, 2),
]

let map = (try String(contentsOfFile: "./input.txt", encoding: .utf8))
  .components(separatedBy: "\n")
  .map { s in Array(s) }

let result =
  slopes
  .map { slope in treesInSlope(map, slopeX: slope.0, slopeY: slope.1) }
  .reduce(1) { acc, trees in acc * trees }

print(result)
