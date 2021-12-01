import Foundation

let input = try String(contentsOfFile: "./input.txt", encoding: .utf8)
let depths = input.split(separator: "\n").map { x in Int(x) ?? 0 }

var prev = depths.first!
var increments = 0

for depth in depths {
	if depth > prev {
		increments += 1
	}
	prev = depth
}

print(increments)