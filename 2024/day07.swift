import Foundation

enum Operator {
  case add
  case mul
  case concat
}

struct Equation {
  let result: Int
  let operands: [Int]

  init(_ input: any StringProtocol) {
    let parts = input.split(separator: ": ")
    result = Int(parts[0])!
    operands = parts[1].split(separator: " ").map { Int($0)! }
  }

  func isValid(ops: [Operator]) -> Bool {
    var places = Array(repeating: 0, count: operands.count - 1)

    repeat {
      let operators = places.map { ops[$0] }
      var n = operands[0]
      for (i, op) in operators.enumerated() {
        switch op {
        case .mul: n = n * operands[i + 1]
        case .add: n = n + operands[i + 1]
        case .concat: n = Int(String(n) + String(operands[i + 1]))!
        }
      }

      if n == result {
        return true
      }

      for idx in (0...(places.count - 1)).reversed() {
        places[idx] += 1
        if idx > 0 && places[idx] >= ops.count {
          places[idx] = 0
          places[idx - 1] += 1
          if places[idx - 1] >= ops.count {
            continue
          }
        }
        break
      }
    } while places[0] < ops.count
    return false
  }
}

let input = try String(contentsOfFile: "./inputs/07.txt", encoding: .utf8)
let equations = input.split(separator: "\n").map { Equation($0) }

print(
  "Part one:", equations.filter { $0.isValid(ops: [.add, .mul]) }.map { $0.result }.reduce(0, (+))
)
print(
  "Part two:",
  equations.filter { $0.isValid(ops: [.add, .mul, .concat]) }.map { $0.result }.reduce(0, (+))
)
