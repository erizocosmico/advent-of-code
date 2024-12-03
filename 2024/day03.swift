import Foundation
import RegexBuilder

let input = try String(contentsOfFile: "./inputs/03.txt", encoding: .utf8)
let mul = Regex {
  "mul("
  Capture {
    Repeat(.digit, 1...3)
  } transform: {
    Int($0)!
  }
  ","
  Capture {
    Repeat(.digit, 1...3)
  } transform: {
    Int($0)!
  }
  ")"
}

var result = 0
for match in input.matches(of: mul) {
  result += match.1 * match.2
}

print("Part 1:", result)

let instructions = Regex {
  Capture {
    ChoiceOf {
      "do()"
      mul
      "don't()"
    }
  }
}

result = 0
var enabled = true
for match in input.matches(of: instructions) {
  if match.0 == "do()" {
    enabled = true
  } else if match.0 == "don't()" {
    enabled = false
  } else if enabled {
    result += match.2! * match.3!
  }
}

print("Part 2:", result)
