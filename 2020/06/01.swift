import Foundation

let result = (try String(contentsOfFile: "./input.txt", encoding: .utf8))
  .components(separatedBy: "\n\n")
  .map { group in Set(group.replacingOccurrences(of: "\n", with: "")).count }
  .reduce(0) { acc, n in acc + n }

print(result)
