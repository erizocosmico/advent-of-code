import Foundation

let input = try String(contentsOfFile: "./input.txt", encoding: .utf8)
let nums = input.split(separator: "\n").map { x in Int(x) ?? 0 }
for x in nums {
  if let y = nums.first(where: { y in nums.contains(2020 - x - y) }) {
    print(x * y * (2020 - x - y))
    break
  }
}
