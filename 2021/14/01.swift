import Foundation

struct Polymer {
	var pairs = [String: Int]()
	var frequencies = [Character: Int]()

	init(_ polymer: [Character]) {
		for i in 0 ..< (polymer.count - 1) {
			let pair = String(polymer[i]) + String(polymer[i + 1])
			pairs[pair] = (pairs[pair] ?? 0) + 1
		}

		for ch in polymer {
			frequencies[ch] = (frequencies[ch] ?? 0) + 1
		}
	}

	mutating func run(_ rules: [String: Character], _ steps: Int) {
		for _ in 0 ..< steps {
			var newPairs = [String: Int]()
			for (pair, n) in pairs {
				if let insert = rules[pair] {
					let newPair = String(pair.first!) + String(insert)
					let nextPair = String(insert) + String(pair.last!)
					newPairs[nextPair] = (newPairs[nextPair] ?? 0) + n
					newPairs[newPair] = (newPairs[newPair] ?? 0) + n
					frequencies[insert] = (frequencies[insert] ?? 0) + n
				} else {
					newPairs[pair] = (newPairs[pair] ?? 0) + n
				}
			}
			pairs = newPairs
		}
	}

	func score() -> Int {
		let max = frequencies.max(by: { a, b in a.value < b.value })!.value
		let min = frequencies.min(by: { a, b in a.value < b.value })!.value
		return max - min
	}
}

let input = try String(contentsOfFile: "./input.txt", encoding: .utf8)
	.components(separatedBy: "\n\n")

var polymer = Polymer(Array(input.first!))
let rules: [String: Character] = Dictionary(uniqueKeysWithValues: input.last!.split(separator: "\n")
	.map { line in
		let parts = line.components(separatedBy: " -> ")
		return (parts.first!, parts.last!.first!)
	})

polymer.run(rules, 10)
print("*", polymer.score())

polymer.run(rules, 30)
print("**", polymer.score())
