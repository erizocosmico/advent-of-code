import Foundation

let input = try String(contentsOfFile: "./input.txt", encoding: .utf8)
let depths = input.split(separator: "\n").map { x in Int(x) ?? 0 }

var prev = depths.prefix(3)
var remaining = depths.dropFirst(1)
var increments = 0

while remaining.count >= 3 {
	let prevSum = prev.reduce(0, +)
	let current = remaining.prefix(3)
	let currentSum = current.reduce(0, +)
	if currentSum > prevSum {
		increments += 1
	}

	prev = current
	remaining = remaining.dropFirst(1)
}

print(increments)