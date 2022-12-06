import Foundation

let input = try String(contentsOfFile: "./input.txt", encoding: .utf8)

print("Part one:", findCharactersBeforeMarker(input, size: 4))
print("Part two:", findCharactersBeforeMarker(input, size: 14))

func findCharactersBeforeMarker(_ input: String, size: Int) -> Int {
	var chunk = [Character](input.prefix(size - 1))
	for i in (size - 1) ..< input.count {
		chunk.append(input[input.index(input.startIndex, offsetBy: i)])
		if !hasRepeatedCharacter(chunk) {
			return i + 1
		}
		chunk.removeFirst()
	}
	return 0
}

func hasRepeatedCharacter(_ chunk: [Character]) -> Bool {
	for (i, ch) in chunk.enumerated() {
		if chunk.lastIndex(of: ch) != i {
			return true
		}
	}
	return false
}
