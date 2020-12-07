import Foundation

typealias Rules = [String: [(Int, String)]]

func parseRule(rule: String) -> (String, [(Int, String)]) {
  let parts = rule.components(separatedBy: " bags contain ")
  let (type, contained) = (parts[0], parts[1])
  if contained.hasPrefix("no other bags") {
    return (type, [])
  }

  let containedBags: [(Int, String)] = contained.components(separatedBy: ", ")
    .map { x in
      let parts = x.components(separatedBy: " ")
      return (Int(parts[0])!, parts[1] + " " + parts[2])
    }

  return (type, containedBags)
}

func bagsInside(_ rules: Rules, _ type: String) -> Int {
  var count = 0
  for (n, type) in rules[type]! {
    count += n * (1 + bagsInside(rules, type))
  }
  return count
}

let input = try String(contentsOfFile: "./input.txt", encoding: .utf8)
let rules = Rules(
  uniqueKeysWithValues: input.components(separatedBy: "\n").map(parseRule)
)

print(bagsInside(rules, "shiny gold"))
