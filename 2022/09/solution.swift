import Foundation

enum Direction {
	case up, down, left, right

	func step() -> (x: Int, y: Int) {
		switch self {
		case .up: return (x: 0, y: -1)
		case .down: return (x: 0, y: 1)
		case .left: return (x: -1, y: 0)
		case .right: return (x: 1, y: 0)
		}
	}
}

struct Point: Hashable {
	let x: Int
	let y: Int
}

enum ParseError: Error {
	case invalidMove
}

func parseMove(_ s: String) throws -> (Direction, Int) {
	let parts = s.split(separator: " ")
	let n = Int(String(parts.last!))!
	switch String(parts.first!) {
	case "U": return (Direction.up, n)
	case "L": return (Direction.left, n)
	case "R": return (Direction.right, n)
	case "D": return (Direction.down, n)
	default:
		throw ParseError.invalidMove
	}
}

func touching(head: Point, tail: Point) -> Bool {
	return abs(head.x - tail.x) <= 1 && abs(head.y - tail.y) <= 1
}

func catchup(head: Point, tail: Point) -> Point {
	if head.x == tail.x {
		let dy = head.y > tail.y ? 1 : -1
		return Point(x: tail.x, y: tail.y + dy)
	}

	if head.y == tail.y {
		let dx = head.x > tail.x ? 1 : -1
		return Point(x: tail.x + dx, y: tail.y)
	}

	let dy = head.y > tail.y ? 1 : -1
	let dx = head.x > tail.x ? 1 : -1
	return Point(x: tail.x + dx, y: tail.y + dy)
}

func solve(_ moves: [(Direction, Int)], points: Int) -> Int {
	var rope = [Point]()
	for _ in 0 ..< points {
		rope.append(Point(x: 0, y: 0))
	}
	var positions: Set<Point> = Set()
	positions.insert(rope[0])

	for m in moves {
		let (dir, n) = m

		for _ in 0 ..< n {
			let (dx, dy) = dir.step()
			let head = rope[0]
			rope[0] = Point(x: head.x + dx, y: head.y + dy)
			for i in 1 ..< rope.count {
				let prev = rope[i - 1]
				let curr = rope[i]
				if !touching(head: prev, tail: curr) {
					rope[i] = catchup(head: prev, tail: curr)
				}
			}
			positions.insert(rope.last!)
		}
	}

	return positions.count
}

let input = try String(contentsOfFile: "./input.txt", encoding: .utf8)
let moves = try input.split(separator: "\n").map { try parseMove(String($0)) }

print("Part one:", solve(moves, points: 2))
print("Part two:", solve(moves, points: 10))
