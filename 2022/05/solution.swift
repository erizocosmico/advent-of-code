import Foundation

let parts = try String(contentsOfFile: "./input.txt", encoding: .utf8).split(separator: "\n\n")
let crates = parseCrates(String(parts[0]))
let moves = parseMoves(String(parts[1]))

print("Part one:", solve(crates, moves, multiple: false))
print("Part two:", solve(crates, moves, multiple: true))

struct Move {
	let number: Int
	let from: Int
	let to: Int

	func apply(_ crates: [[Character]], multiple: Bool) -> [[Character]] {
		var crates = crates
		let moved = crates[from].suffix(number)
		crates[from].removeLast(number)
		crates[to].append(contentsOf: multiple ? Array(moved) : Array(moved.reversed()))
		return crates
	}
}

func solve(_ crates: [[Character]], _ moves: [Move], multiple: Bool) -> String {
	let result = moves.reduce(crates) { $1.apply($0, multiple: multiple) }
	return String(result.map { $0.last! })
}

func parseCrates(_ input: String) -> [[Character]] {
	let parts = input.split(separator: "\n")
	let stacks = String(parts.last!)
		.trimmingCharacters(in: .whitespaces)
		.split(separator: "   ")
		.count
	var result: [[Character]] = Array(repeating: [], count: stacks)
	for line in parts.dropLast(1).reversed() {
		for (n, ch) in line.enumerated() {
			if ch != "[", ch != "]", ch != " " {
				result[n / 4].append(ch)
			}
		}
	}
	return result
}

func parseMoves(_ input: String) -> [Move] {
	let pattern = #/move (\d+) from (\d+) to (\d+)/#
	return input.split(separator: "\n").map { line in
		let result = String(line).firstMatch(of: pattern)!
		return Move(number: Int(result.1)!, from: Int(result.2)! - 1, to: Int(result.3)! - 1)
	}
}
