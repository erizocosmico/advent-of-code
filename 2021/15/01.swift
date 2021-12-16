import Foundation

let map = try String(contentsOfFile: "./input.txt", encoding: .utf8)
	.split(separator: "\n")
	.map { line in Array(line).map { c in Int(String(c))! }}

struct Point: Hashable {
	let x: Int
	let y: Int

	func distance(_ to: Point) -> Int {
		return abs(to.x - x) + abs(to.y - y)
	}
}

func neighbours(_ map: [[Int]], _ p: Point) -> [Point] {
	var points = [Point]()

	if p.x - 1 >= 0 {
		points.append(Point(x: p.x - 1, y: p.y))
	}
	if p.y - 1 >= 0 {
		points.append(Point(x: p.x, y: p.y - 1))
	}
	if p.x + 1 < map[p.y].count {
		points.append(Point(x: p.x + 1, y: p.y))
	}
	if p.y + 1 < map.count {
		points.append(Point(x: p.x, y: p.y + 1))
	}

	return points
}

let maxDeviation = 10

func minimumRiskPath(_ map: [[Int]], _ start: Point, _ target: Point) -> Int {
	var stack: Set = [start]
	var costs = [start: 0]
	var bestDistance = 1 << 32

	while stack.count > 0 {
		let curr = stack.min(by: { a, b in costs[a]! < costs[b]! })!
		stack.remove(curr)

		for p in neighbours(map, curr) {
			let cost = costs[curr]! + map[p.y][p.x]
			if p == target {
				return cost
			}

			if costs[p] == nil || costs[p]! > cost {
				costs[p] = cost
				let distance = p.distance(target)
				// Don't explore points whose distance is more than n
				// away from the closest distance to the target we've
				// seen so far.
				if bestDistance - distance > -maxDeviation {
					if distance < bestDistance {
						bestDistance = distance
					}
					stack.insert(p)
				}
			}
		}
	}

	return -1
}

func extendMap(_ map: [[Int]]) -> [[Int]] {
	let row = Array(repeating: 0, count: map[0].count * 5)
	var result = Array(repeating: row, count: map.count * 5)

	for i in 0 ..< 5 {
		for j in 0 ..< 5 {
			for y in 0 ..< map.count {
				for x in 0 ..< map[y].count {
					let fx = map[y].count * i + x
					let fy = map.count * j + y
					let fn = map[y][x] + i + j
					result[fy][fx] = fn > 9 ? fn - 9 : fn
				}
			}
		}
	}

	return result
}

let start = Point(x: 0, y: 0)
let end = Point(x: map[0].count - 1, y: map.count - 1)
print("*", minimumRiskPath(map, start, end))

let bigMap = extendMap(map)
let bigEnd = Point(x: bigMap[0].count - 1, y: bigMap.count - 1)
print("**", minimumRiskPath(bigMap, start, bigEnd))
