import Foundation

typealias Rules = [String: [String]]

func parseRule(rule: String) -> (String, [String]) {
  let parts = rule.components(separatedBy: " bags contain ")
  let (type, contained) = (parts[0], parts[1])
  if contained.hasPrefix("no other bags") {
    return (type, [])
  }

  let containedBags: [String] = contained.components(separatedBy: ", ")
    .map { x in
      let parts = x.components(separatedBy: " ")
      return parts[1] + " " + parts[2]
    }

  return (type, containedBags)
}

func canHoldBag(_ rules: Rules, _ target: String, _ type: String) -> Bool {
  if target == type {
    return true
  }

  for type in rules[type]! {
    if canHoldBag(rules, target, type) {
      return true
    }
  }

  return false
}

let input = try String(contentsOfFile: "./input.txt", encoding: .utf8)
let rules = Rules(
  uniqueKeysWithValues: input.components(separatedBy: "\n").map(parseRule)
)
let target = "shiny gold"

print(rules.keys.filter { $0 != target && canHoldBag(rules, target, $0) }.count)
