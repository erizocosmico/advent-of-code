import Foundation

struct Point: Hashable {
	let x: Int
	let y: Int

	init(_ x: Int, _ y: Int) {
		self.x = x
		self.y = y
	}

	init(_ raw: String) {
		let parts = raw.split(separator: ",")
		x = Int(parts.first!)!
		y = Int(parts.last!)!
	}
}

func compare(_ a: Int, _ b: Int) -> Int {
	if a < b { return -1 }
	if a > b { return 1 }
	return 0
}

struct Line {
	let start: Point
	let end: Point

	init(_ raw: String) {
		let parts = raw.components(separatedBy: " -> ")
		start = Point(parts.first!)
		end = Point(parts.last!)
	}

	func points() -> [Point] {
		var (x, y) = (start.x, start.y)
		let (dx, dy) = (compare(end.x, start.x), compare(end.y, start.y))

		var points: [Point] = Array()
		while x != end.x || y != end.y {
			points.append(Point(x, y))
			x += dx
			y += dy
		}
		points.append(Point(x, y))
		return points
	}
}

let points = try String(contentsOfFile: "./input.txt", encoding: .utf8)
	.split(separator: "\n")
	.map { l in Line(String(l)) }
	.flatMap { l in l.points() }

let overlappingPoints = Dictionary(points.map { ($0, 1) }, uniquingKeysWith: +)
	.filter { _, freq in freq > 1 }
	.count

print(overlappingPoints)
