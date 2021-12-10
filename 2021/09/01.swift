import Foundation

func adjacentPoints(_ matrix: [[Int]], _ x: Int, _ y: Int) -> [Int] {
	var result = [Int]()
	if y > 0 {
		result.append(matrix[y - 1][x])
	}

	if y + 1 < matrix.count {
		result.append(matrix[y + 1][x])
	}

	if x > 0 {
		result.append(matrix[y][x - 1])
	}

	if x + 1 < matrix[y].count {
		result.append(matrix[y][x + 1])
	}

	return result
}

func findLowPoints(_ heightmap: [[Int]]) -> [Int] {
	var result = [Int]()

	for y in 0 ..< heightmap.count {
		let row = heightmap[y]
		for x in 0 ..< row.count {
			let adjacents = adjacentPoints(heightmap, x, y)
			if adjacents.allSatisfy({ $0 > row[x] }) {
				result.append(row[x])
			}
		}
	}

	return result
}

let heightmap = try String(contentsOfFile: "./input.txt", encoding: .utf8)
	.split(separator: "\n")
	.map { line in
		Array(line).map { c in
			Int(String(c))!
		}
	}

let lowPoints = findLowPoints(heightmap)

print(lowPoints.map { $0 + 1 }.reduce(0, +))
