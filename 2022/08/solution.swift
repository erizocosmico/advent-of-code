import Foundation

func visibleTrees(_ trees: [[Int]]) -> Int {
	var result = 0

	for (y, row) in trees.enumerated() {
		for (x, _) in row.enumerated() {
			if isVisible(trees, x: x, y: y) {
				result += 1
			}
		}
	}

	return result
}

func highestScenicScore(_ trees: [[Int]]) -> Int {
	var result = 0

	for (y, row) in trees.enumerated() {
		for (x, _) in row.enumerated() {
			let score = scenicScore(trees, x: x, y: y)
			if score > result {
				result = score
			}
		}
	}

	return result
}

let directions: [(Int, Int)] = [
	(-1, 0),
	(0, 1),
	(1, 0),
	(0, -1),
]

func scenicScore(_ trees: [[Int]], x: Int, y: Int) -> Int {
	let height = trees[y][x]
	let ysize = trees.count
	let xsize = trees[0].count

	var result = 1
	for (dy, dx) in directions {
		var (currx, curry) = (x + dx, y + dy)
		var seen = 0
		while currx >= 0 && currx < xsize && curry >= 0 && curry < ysize {
			let h = trees[curry][currx]
			seen += 1
			if h >= height {
				break
			}
			currx += dx
			curry += dy
		}
		result *= seen
	}

	return result
}

func isVisible(_ trees: [[Int]], x: Int, y: Int) -> Bool {
	let height = trees[y][x]
	let ysize = trees.count
	let xsize = trees[0].count

	if x == 0 || y == 0 || x == xsize - 1 || y == ysize - 1 {
		return true
	}

	for (dy, dx) in directions {
		var visible = true
		var (currx, curry) = (x + dx, y + dy)
		while currx >= 0 && currx < xsize && curry >= 0 && curry < ysize {
			if trees[curry][currx] >= height {
				visible = false
				break
			}
			currx += dx
			curry += dy
		}

		if visible {
			return true
		}
	}

	return false
}

let input = try String(contentsOfFile: "./input.txt", encoding: .utf8)
let trees: [[Int]] = input.split(separator: "\n")
	.map { line in line.map { Int(String($0))! }}

print("Part one:", visibleTrees(trees))
print("Part two:", highestScenicScore(trees))
