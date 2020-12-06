import Foundation

func countGroupAnswers(group: String) -> Int {
  let groupAnswers = group.components(separatedBy: "\n").map { s in Set(s) }
  return groupAnswers.dropFirst()
    .reduce(groupAnswers.first!) { acc, a in acc.intersection(a) }
    .count
}

let result = (try String(contentsOfFile: "./input.txt", encoding: .utf8))
  .components(separatedBy: "\n\n")
  .map(countGroupAnswers)
  .reduce(0) { acc, n in acc + n }

print(result)
