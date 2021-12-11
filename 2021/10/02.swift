import Foundation

enum SyntaxCheck {
	case ok
	case incomplete([Character])
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
		return .incomplete(stack)
	}

	return .ok
}

let scores: [Character: Int] = [
	"(": 1,
	"[": 2,
	"{": 3,
	"<": 4,
]

func isIncomplete(_ c: SyntaxCheck) -> Bool {
	switch c {
	case .incomplete: return true
	default: return false
	}
}

func completeScore(_ c: SyntaxCheck) -> Int {
	switch c {
	case let .incomplete(stack):
		return stack.reversed().reduce(0) { acc, ch in
			acc * 5 + scores[ch]!
		}
	default: return 0
	}
}

let lines = try String(contentsOfFile: "./input.txt", encoding: .utf8)
	.split(separator: "\n")

let completeScores: [Int] = lines
	.map { l in checkSyntax(String(l)) }
	.filter { isIncomplete($0) }
	.map { completeScore($0) }
	.sorted()

print(completeScores[completeScores.count / 2])
