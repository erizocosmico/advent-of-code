import Foundation

let adapters = try String(contentsOfFile: "./input.txt", encoding: .utf8)
  .components(separatedBy: "\n")
  .map { s in Int(s)! }
  .sorted()

enum ChainError: Error {
  case notChainable
}

func joltDifferences(_ adapters: [Int]) throws -> (Int, Int, Int) {
  var (diff1, diff2, diff3) = (0, 0, 0)
  var jolts = 0

  for a in adapters {
    switch a - jolts {
    case 1: diff1 += 1
    case 2: diff2 += 1
    case 3: diff3 += 1
    default: throw ChainError.notChainable
    }
    jolts = a
  }

  return (diff1, diff2, diff3 + 1)
}

let diffs = try joltDifferences(adapters)
print(diffs.0 * diffs.2)
