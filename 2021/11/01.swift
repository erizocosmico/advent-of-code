import Foundation

func increase(_ grid: inout [[Int]]) {
	for i in 0 ..< grid.count {
		for j in 0 ..< grid[i].count {
			grid[i][j] += 1
		}
	}
}

let adjacents = [
	(-1, -1),
	(-1, 0),
	(-1, 1),
	(0, -1),
	(0, 1),
	(1, -1),
	(1, 0),
	(1, 1),
]

func increaseAdjacents(_ grid: inout [[Int]], _ i: Int, _ j: Int) {
	let maxi = grid.count
	let maxj = grid[i].count

	for (di, dj) in adjacents {
		if i + di >= 0, i + di < maxi,
		   j + dj >= 0, j + dj < maxj,
		   grid[i + di][j + dj] > 0
		{
			grid[i + di][j + dj] += 1
		}
	}
}

func step(_ grid: inout [[Int]]) -> Int {
	increase(&grid)

	var result = 0
	var flashes: Int
	repeat {
		flashes = 0

		for i in 0 ..< grid.count {
			for j in 0 ..< grid[i].count {
				if grid[i][j] > 9 {
					grid[i][j] = 0
					flashes += 1
					increaseAdjacents(&grid, i, j)
				}
			}
		}

		result += flashes
	} while flashes > 0

	return result
}

func flashesAfter(_ grid: [[Int]], steps: Int) -> Int {
	var grid = grid
	var result = 0
	for _ in 0 ..< steps {
		result += step(&grid)
	}
	return result
}

func stepsUntilAllFlash(_ grid: [[Int]]) -> Int {
	var grid = grid
	var steps = 1
	while step(&grid) != grid.count * grid.count {
		steps += 1
	}
	return steps
}

let grid = try String(contentsOfFile: "./input.txt", encoding: .utf8)
	.split(separator: "\n")
	.map { line in String(line).map { Int(String($0))! }}

print("*", flashesAfter(grid, steps: 100))
print("**", stepsUntilAllFlash(grid))
