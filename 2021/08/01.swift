import Foundation

struct Entry {
	let patterns: [String]
	let output: [String]

	init(_ raw: String) {
		let parts = raw.components(separatedBy: " | ")
		patterns = parts.first!.split(separator: " ").map { String($0) }
		output = parts.last!.split(separator: " ").map { String($0) }
	}
}

let entries = try String(contentsOfFile: "./input.txt", encoding: .utf8)
	.split(separator: "\n")
	.map { line in Entry(String(line)) }

let targetDigits = [2, 3, 4, 7]

let result = entries.reduce(0) { acc, entry in
	let n = entry.output.filter { e in targetDigits.contains(e.count) }.count
	return acc + n
}

print(result)
