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

struct Line {
	let start: Point
	let end: Point

	init(_ raw: String) {
		let parts = raw.components(separatedBy: " -> ")
		start = Point(parts.first!)
		end = Point(parts.last!)
	}

	func isHorizontal() -> Bool {
		return start.y == end.y
	}

	func isVertical() -> Bool {
		return start.x == end.x
	}

	func points() -> [Point] {
		if isVertical() {
			return (min(start.y, end.y)...max(start.y, end.y)).map { Point(start.x, $0) }
		}

		return (min(start.x, end.x)...max(start.x, end.x)).map { Point($0, start.y) }
	}
}

let lines = try String(contentsOfFile: "./input.txt", encoding: .utf8)
	.split(separator: "\n")
	.map { l in Line(String(l)) }
	.filter { l in l.isVertical() || l.isHorizontal() }

let points = lines.flatMap { l in l.points() }
let overlappingPoints = Dictionary(points.map { ($0, 1) }, uniquingKeysWith: +)
	.filter { (_, freq) in freq > 1 }
	.count

print(overlappingPoints)
