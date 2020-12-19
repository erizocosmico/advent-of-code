import Foundation

enum Rule {
  case letter(Character)
  case all([Rule])
  case any([Rule])

  func match(_ s: String) -> (Bool, String) {
    switch self {
    case .letter(let ch):
      if s.hasPrefix(String(ch)) {
        return (true, String(s.dropFirst()))
      }
      return (false, s)
    case .all(let rules):
      var remaining = s
      for rule in rules {
        let (ok, rest) = rule.match(remaining)
        if !ok {
          return (false, s)
        }
        remaining = rest
      }
      return (true, remaining)
    case .any(let rules):
      for rule in rules {
        let (ok, remaining) = rule.match(s)
        if ok {
          return (true, remaining)
        }
      }
      return (false, s)
    }
  }

  func consecutiveMatches(_ msg: String) -> (Int, String) {
    var matches = 0
    var (ok, remaining) = (true, msg)
    while ok {
      (ok, remaining) = self.match(remaining)
      if ok {
        matches += 1
      }
    }

    return (matches, remaining)
  }
}

func parseRule(_ rule: String, _ rules: [Int: String]) -> Rule {
  if rule.hasPrefix("\"") && rule.hasSuffix("\"") {
    return .letter(rule.dropFirst().first!)
  }

  if rule.contains("|") {
    return .any(rule.components(separatedBy: " | ").map { parseRule($0, rules) })
  }

  return .all(rule.components(separatedBy: " ").map { parseRule(rules[Int($0)!]!, rules) })
}

func parseRules(_ input: String) -> [Int: String] {
  var rules = [Int: String]()
  for line in input.components(separatedBy: "\n") {
    let parts = line.components(separatedBy: ": ")
    rules.updateValue(parts[1], forKey: Int(parts[0])!)
  }
  return rules
}

func validMessages(_ msgs: [String], _ rules: [Int: String]) -> Int {
  let r42 = parseRule(rules[42]!, rules)
  let r31 = parseRule(rules[31]!, rules)

  var matches = 0
  for msg in msgs {
    let (a, remaining) = r42.consecutiveMatches(msg)
    let (b, rest) = r31.consecutiveMatches(remaining)

    if rest.count == 0 && a > b && b > 0 {
      matches += 1
    }
  }

  return matches
}

let parts = try String(contentsOfFile: "./input.txt", encoding: .utf8).components(
  separatedBy: "\n\n")
let rules = parseRules(parts[0])
let messages = parts[1].components(separatedBy: "\n")

print(validMessages(messages, rules))
