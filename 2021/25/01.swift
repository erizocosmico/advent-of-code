import Foundation

let map = try String(contentsOfFile: "./input.txt", encoding: .utf8)
	.components(separatedBy: "\n")
	.map { Array($0) }

func moveHerd(_ map: [[Character]], _ ch: Character, _ dx: Int, _ dy: Int) -> [[Character]] {
	var result = map
	for y in 0 ..< map.count {
		for x in 0 ..< map[y].count {
			let c = map[y][x]
			if c == ch {
				let newx = x + dx < map[y].count ? x + dx : 0
				let newy = y + dy < map.count ? y + dy : 0

				if map[newy][newx] == "." {
					result[newy][newx] = ch
					result[y][x] = "."
				}
			}
		}
	}
	return result
}

func solve(_ map: [[Character]]) -> Int {
	var current = map
	var prev = map
	var steps = 0

	repeat {
		prev = current
		current = moveHerd(moveHerd(current, ">", 1, 0), "v", 0, 1)
		steps += 1
	} while current != prev

	return steps
}

print(solve(map))
