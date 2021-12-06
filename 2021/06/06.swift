import Foundation

let input = try String(contentsOfFile: "./input.txt", encoding: .utf8)
	.split(separator: ",")
	.map { Int($0)! }

func fishesAfter(_ input: [Int], days: Int) -> Int {
	var fishes = Dictionary(input.map { ($0, 1) }, uniquingKeysWith: +)
	for _ in 1...days {
		var next: [Int: Int] = Dictionary()
		for (timer, num) in fishes {
			if timer == 0 {
				next[8] = num
				next[6] = (next[6] ?? 0) + num
			} else {
				next[timer-1] = (next[timer-1] ?? 0) + num
			}
		}
		fishes = next
	}

	return fishes.reduce(0, { (acc, kv) in acc + kv.value })
}

print("*", fishesAfter(input, days: 80))
print("**", fishesAfter(input, days: 256))