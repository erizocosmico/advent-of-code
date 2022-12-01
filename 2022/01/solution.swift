import Foundation

let input = try String(contentsOfFile: "./input.txt", encoding: .utf8)
let inventory = input.split(separator: "\n\n")
	.map { chunk in chunk.split(separator: "\n").map { line in Int(line)! }}
let totals = inventory.map { $0.reduce(0, +) }

print("Part One:", totals.max()!)
print("Part Two:", totals.sorted().reversed().prefix(3).reduce(0, +))
