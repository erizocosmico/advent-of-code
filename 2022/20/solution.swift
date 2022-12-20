import Foundation

func groveCoordinates(_ input: [Int], decriptionKey: Int = 1, mixes: Int = 1) -> Int {
	var file = input.enumerated().map { ($0, $1 * decriptionKey) }
	var pos = 0
	for _ in 0 ..< mixes {
		for i in 0 ..< file.count {
			while i != file[pos].0 {
				pos = (pos + 1) % file.count
			}
			let (j, n) = file[pos]
			if n == 0 {
				continue
			}
			file.remove(at: pos)
			var idx = (pos + n) % file.count
			if idx < 0 {
				idx += file.count
			}
			file.insert((j, n), at: idx)
		}
	}

	let idx = file.firstIndex { $0.1 == 0 }!
	return file[(idx + 1000) % file.count].1 + file[(idx + 2000) % file.count].1 + file[(idx + 3000) % file.count].1
}

let input = try String(contentsOfFile: "./input.txt", encoding: .utf8)
let file = input.split(separator: "\n").map { Int(String($0))! }

print("Part one:", groveCoordinates(file))
print("Part two:", groveCoordinates(file, decriptionKey: 811_589_153, mixes: 10))
