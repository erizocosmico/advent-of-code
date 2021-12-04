import Foundation

let lines = try String(contentsOfFile: "./input.txt", encoding: .utf8).split(separator: "\n")
let diagnostic = lines.map { line in Int(line, radix: 2)! }

let rowSize = lines.first!.count
let oxygenRating = rating(diagnostic, rowSize, mostCommon)
let co2Rating = rating(diagnostic, rowSize, leastCommon)

print(oxygenRating * co2Rating)

func rating(_ numbers: [Int], _ bits: Int, _ criteria: ([Int], Int) -> Int) -> Int {
	let selector = criteria(numbers, bits - 1)
	let selected = numbers.filter { n in bitAt(n, bits - 1) == selector }

	if selected.count == 1 {
		return selected.first!
	}

	return rating(selected, bits - 1, criteria)
}

func bitAt(_ n: Int, _ bit: Int) -> Int {
	return n & (1 << bit) > 0 ? 1 : 0
}

func leastCommon(_ numbers: [Int], _ bit: Int) -> Int {
	let ones = numbers.map { ($0 & (1 << bit) > 0) ? 1 : 0 }.reduce(0, +)
	return (numbers.count - ones) <= ones ? 0 : 1
}

func mostCommon(_ numbers: [Int], _ bit: Int) -> Int {
	let ones = numbers.map { ($0 & (1 << bit) > 0) ? 1 : 0 }.reduce(0, +)
	return (numbers.count - ones) > ones ? 0 : 1
}