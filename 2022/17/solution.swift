import Foundation

struct Point: Hashable {
	var x: Int
	var y: Int
	init(_ x: Int, _ y: Int) { self.x = x; self.y = y }
	mutating func move(x: Int, y: Int) { self.x += x; self.y += y }
}

struct CircularList<T> {
	let list: [T]
	var i = 0

	init(_ list: [T]) { self.list = list }
	mutating func next() -> T {
		let result = list[i]
		i += 1
		if i >= list.count {
			i = 0
		}
		return result
	}
}

struct Shape {
	var points: [Point]
	init(_ points: [Point]) { self.points = points }

	mutating func move(x: Int, y: Int) {
		for i in 0 ..< points.count {
			points[i].move(x: x, y: y)
		}
	}

	func canMove(x: Int, y: Int, cave: [[Bool]]) -> Bool {
		for p in points {
			if p.y + y < 0 || p.x + x < 0 || p.x + x >= cave[0].count || cave[p.y + y][p.x + x] {
				return false
			}
		}
		return true
	}
}

let shapes = [
	Shape([Point(2, 0), Point(3, 0), Point(4, 0), Point(5, 0)]),
	Shape([Point(3, 0), Point(2, 1), Point(3, 1), Point(4, 1), Point(3, 2)]),
	Shape([Point(2, 0), Point(3, 0), Point(4, 0), Point(4, 1), Point(4, 2)]),
	Shape([Point(2, 0), Point(2, 1), Point(2, 2), Point(2, 3)]),
	Shape([Point(2, 0), Point(3, 0), Point(2, 1), Point(3, 1)]),
]

func makeShape(_ shape: Shape, y: Int) -> Shape {
	var result = shape
	result.move(x: 0, y: y)
	return result
}

struct State: Hashable {
	let jets: Int
	let shapes: Int
	init(_ jets: Int, _ shapes: Int) { self.jets = jets; self.shapes = shapes }
}

func heightAfterRocks(_ input: [Int], rocks: Int) -> Int {
	var jets = CircularList(input)
	var shapes = CircularList(shapes)
	var cave = [[Bool]]()
	var states = [State: (Int, Int)]()
	var n = 0

	while n < rocks {
		let height = highestOccupiedHeight(cave)
		let state = State(jets.i, shapes.i)
		if let s = states[state] {
			let (prevn, prevHeight) = s
			if (rocks - n) % (prevn - n) == 0 {
				return height + (prevHeight - height) * (rocks - n) / (prevn - n) + 1
			}
		} else {
			states[state] = (n, height)
		}

		var rock = makeShape(shapes.next(), y: height + 4)
		let maxy = rock.points.max { $0.y < $1.y }!.y
		for _ in (cave.count - 1) ... max(maxy, cave.count - 1) {
			cave.append(Array(repeating: false, count: 7))
		}

		while true {
			let jet = jets.next()
			if rock.canMove(x: jet, y: 0, cave: cave) {
				rock.move(x: jet, y: 0)
			}

			if rock.canMove(x: 0, y: -1, cave: cave) {
				rock.move(x: 0, y: -1)
			} else {
				break
			}
		}

		for p in rock.points {
			cave[p.y][p.x] = true
		}

		n += 1
	}

	return highestOccupiedHeight(cave) + 1
}

func highestOccupiedHeight(_ cave: [[Bool]]) -> Int {
	for y in 0 ..< cave.count {
		if cave[cave.count - y - 1].contains(true) {
			return cave.count - y - 1
		}
	}
	return -1
}

let input = try String(contentsOfFile: "./input.txt", encoding: .utf8)
let jets = input.map { $0 == ">" ? 1 : -1 }

print("Part one:", heightAfterRocks(jets, rocks: 2022))
print("Part two:", heightAfterRocks(jets, rocks: 1_000_000_000_000))
