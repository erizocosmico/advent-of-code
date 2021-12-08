import Foundation

extension StringProtocol {
	subscript(offset: Int) -> Character {
		self[index(startIndex, offsetBy: offset)]
	}
}

struct Entry {
	let patterns: [String]
	let output: [String]

	init(_ raw: String) {
		let parts = raw.components(separatedBy: " | ")
		patterns = parts.first!.split(separator: " ").map { String($0) }
		output = parts.last!.split(separator: " ").map { String($0) }
	}

	func guessDigits() throws -> [String: Int] {
		let one = patterns.filter { $0.count == 2 }.first!
		let four = patterns.filter { $0.count == 4 }.first!
		let patterns = [String: Int](uniqueKeysWithValues: try patterns.map { p in
			let pattern = String(p.sorted())
			switch p.count {
			case 2: return (pattern, 1)
			case 3: return (pattern, 7)
			case 4: return (pattern, 4)
			case 7: return (pattern, 8)
			case 5:
				if one.allSatisfy({ pattern.contains($0) }) {
					return (pattern, 3)
				}

				if four.filter({ pattern.contains($0) }).count == 3 {
					return (pattern, 5)
				}

				return (pattern, 2)
			case 6:
				if four.allSatisfy({ pattern.contains($0) }) {
					return (pattern, 9)
				}

				if one.allSatisfy({ pattern.contains($0) }) {
					return (pattern, 0)
				}

				return (pattern, 6)
			default:
				throw GuessError.invalidPattern
			}
		})
		return patterns
	}

	func decode() throws -> Int {
		let digits = try guessDigits()
		return Int(output.reduce("") { acc, e in acc + String(digits[String(e.sorted())]!) })!
	}
}

enum GuessError: Error {
	case invalidPattern
}

let entries = try String(contentsOfFile: "./input.txt", encoding: .utf8)
	.split(separator: "\n")
	.map { line in Entry(String(line)) }

let targetDigits = [2, 3, 4, 7]

let result = try entries.reduce(0) { acc, e in acc + (try e.decode()) }

print(result)
