import Foundation

struct Point: Hashable {
	let x: Int
	let y: Int

	init(_ x: Int, _ y: Int) {
		self.x = x
		self.y = y
	}
}

func findBasin(_ heightmap: [[Int]], _ x: Int, _ y: Int) -> [Int] {
	var result = [heightmap[y][x]]
	var seen: Set = [Point(x, y)]
	result.append(contentsOf: adjacentBasinPoints(heightmap, x, y, &seen))
	return result
}

func adjacentBasinPoints(_ matrix: [[Int]], _ x: Int, _ y: Int, _ seen: inout Set<Point>) -> [Int] {
	var result = [Int]()
	if y > 0, matrix[y - 1][x] < 9, !seen.contains(Point(x, y - 1)) {
		seen.insert(Point(x, y - 1))
		result.append(matrix[y - 1][x])
		result.append(contentsOf: adjacentBasinPoints(matrix, x, y - 1, &seen))
	}

	if y + 1 < matrix.count, matrix[y + 1][x] < 9, !seen.contains(Point(x, y + 1)) {
		seen.insert(Point(x, y + 1))
		result.append(matrix[y + 1][x])
		result.append(contentsOf: adjacentBasinPoints(matrix, x, y + 1, &seen))
	}

	if x > 0, matrix[y][x - 1] < 9, !seen.contains(Point(x - 1, y)) {
		seen.insert(Point(x - 1, y))
		result.append(matrix[y][x - 1])
		result.append(contentsOf: adjacentBasinPoints(matrix, x - 1, y, &seen))
	}

	if x + 1 < matrix[y].count, matrix[y][x + 1] < 9, !seen.contains(Point(x + 1, y)) {
		seen.insert(Point(x + 1, y))
		result.append(matrix[y][x + 1])
		result.append(contentsOf: adjacentBasinPoints(matrix, x + 1, y, &seen))
	}

	return result
}

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

func isLowPoint(_ heightmap: [[Int]], _ x: Int, _ y: Int) -> Bool {
	let adjacents = adjacentPoints(heightmap, x, y)
	return adjacents.allSatisfy { $0 > heightmap[y][x] }
}

func findBasins(_ heightmap: [[Int]]) -> [[Int]] {
	var result = [[Int]]()
	for y in 0 ..< heightmap.count {
		let row = heightmap[y]
		for x in 0 ..< row.count {
			if isLowPoint(heightmap, x, y) {
				let basin = findBasin(heightmap, x, y)
				result.append(basin)
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

let basins = findBasins(heightmap)

print(basins.map { $0.count }.sorted().reversed().prefix(3).reduce(1, *))
