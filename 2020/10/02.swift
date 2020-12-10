import Foundation

let adapters = try String(contentsOfFile: "./input.txt", encoding: .utf8)
  .components(separatedBy: "\n")
  .map { s in Int(s)! }
  .sorted()

func countArrangements(_ adapters: [Int]) -> Int {
  var seen = [Int: Int]()
  return countArrangements(adapters, jolts: 0, offset: 0, seen: &seen)
}

func countArrangements(_ adapters: [Int], jolts: Int, offset: Int, seen: inout [Int: Int]) -> Int {
  if offset == adapters.count {
    return 1
  }

  var idx = offset
  var count = 0
  while idx < adapters.count && adapters[idx] - jolts <= 3 {
    if let arrangements = seen[idx] {
      count += arrangements
    } else {
      let arrangements = countArrangements(
        adapters, jolts: adapters[idx], offset: idx + 1, seen: &seen)
      seen.updateValue(arrangements, forKey: idx)
      count += arrangements
    }
    idx += 1
  }

  return count
}

print(countArrangements(adapters))
