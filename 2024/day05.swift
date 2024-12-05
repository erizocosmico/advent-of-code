import Foundation

let input = try String(contentsOfFile: "./inputs/05.txt", encoding: .utf8)
let parts = input.split(separator: "\n\n")
let rules = parseRules(String(parts[0]))
let updates = parts[1].split(separator: "\n").map { $0.split(separator: ",").map { Int($0)! } }

func parseRules(_ input: String) -> [Int: [Int]] {
  var rules = [Int: [Int]]()
  for line in input.split(separator: "\n") {
    let parts = line.split(separator: "|")
    let (a, b) = (Int(parts[0])!, Int(parts[1])!)
    var after = rules[a] ?? []
    after.append(b)
    rules.updateValue(after, forKey: a)
  }
  return rules
}

func isCorrectUpdate(_ update: [Int], rules: [Int: [Int]]) -> Bool {
  var seen = Set<Int>()
  for page in update {
    for p in rules[page] ?? [] {
      if seen.contains(p) {
        return false
      }
    }
    seen.insert(page)
  }
  return true
}

func fixUpdate(_ update: [Int], rules: [Int: [Int]]) -> [Int] {
  var seen = [Int: Int]()
  var result = [Int]()
  Outer: for (idx, page) in update.enumerated() {
    for p in rules[page] ?? [] {
      if let prevIdx = seen[p] {
        seen[p] = idx
        seen[page] = prevIdx
        result[prevIdx] = page
        result.append(p)
        continue Outer
      }
    }
    seen[page] = idx
    result.append(page)
  }

  if result != update {
    result = fixUpdate(result, rules: rules)
  }

  return result
}

let correct = updates.filter { isCorrectUpdate($0, rules: rules) }
print("Part one:", correct.map { $0[$0.count / 2] }.reduce(0, (+)))

let incorrect = updates.filter { !isCorrectUpdate($0, rules: rules) }.map {
  fixUpdate($0, rules: rules)
}
print("Part two:", incorrect.map { $0[$0.count / 2] }.reduce(0, (+)))
