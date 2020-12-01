import Foundation

let input = try String(contentsOfFile: "./input.txt", encoding: .utf8)
let nums = input.split(separator: "\n").map { x in Int(x) ?? 0 }
let firstNum = nums.first { x in nums.contains(2020 - x) } ?? 0
print(firstNum * (2020 - firstNum))
