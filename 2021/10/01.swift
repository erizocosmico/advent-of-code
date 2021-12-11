import Foundation

let lines = try String(contentsOfFile: "./input.txt", encoding: .utf8)
	.split(separator: "\n")

enum SyntaxCheck {
	case ok
	case incomplete
	case invalidCharacter(Character)
	case corrupted(Character)
}

let bracketMatches: [Character: Character] = [
	")": "(",
	">": "<",
	"]": "[",
	"}": "{",
]

func checkSyntax(_ line: String) -> SyntaxCheck {
	var stack = [Character]()
	for ch in line {
		switch ch {
		case "{", "(", "[", "<":
			stack.append(ch)
		case "}", ")", "]", ">":
			let last = stack.popLast()
			if last == nil || last != bracketMatches[ch]! {
				return .corrupted(ch)
			}
		default:
			return .invalidCharacter(ch)
		}
	}

	if stack.count > 0 {
		return .incomplete
	}

	return .ok
}

let scores: [Character: Int] = [
	")": 3,
	"]": 57,
	"}": 1197,
	">": 25137,
]

func errorScore(_ lines: [SyntaxCheck]) -> Int {
	return lines.reduce(0) { acc, check in
		switch check {
		case let .corrupted(c):
			return acc + scores[c]!
		default:
			return acc
		}
	}
}

print(errorScore(lines.map { l in checkSyntax(String(l)) }))
