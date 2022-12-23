import Foundation

enum Direction {
	case north, south, west, east
}

struct Pos: Hashable {
	let x: Int
	let y: Int
	init(_ x: Int, _ y: Int) { self.x = x; self.y = y }

	func adjacent() -> [Pos] {
		return [
			Pos(x - 1, y - 1),
			Pos(x, y - 1),
			Pos(x + 1, y - 1),
			Pos(x - 1, y),
			Pos(x + 1, y),
			Pos(x - 1, y + 1),
			Pos(x, y + 1),
			Pos(x + 1, y + 1),
		]
	}

	func adjacent(_ dir: Direction) -> [Pos] {
		switch dir {
		case .north: return [Pos(x, y - 1), Pos(x - 1, y - 1), Pos(x + 1, y - 1)]
		case .west: return [Pos(x - 1, y), Pos(x - 1, y - 1), Pos(x - 1, y + 1)]
		case .east: return [Pos(x + 1, y), Pos(x + 1, y - 1), Pos(x + 1, y + 1)]
		case .south: return [Pos(x, y + 1), Pos(x - 1, y + 1), Pos(x + 1, y + 1)]
		}
	}

	func next(_ dir: Direction) -> Pos {
		switch dir {
		case .north: return Pos(x, y - 1)
		case .west: return Pos(x - 1, y)
		case .east: return Pos(x + 1, y)
		case .south: return Pos(x, y + 1)
		}
	}
}

struct Grove {
	var positions = Set<Pos>()
	var directions: [Direction] = [.north, .south, .west, .east]

	init(_ raw: String) {
		for (y, row) in raw.split(separator: "\n").enumerated() {
			for (x, c) in row.enumerated() {
				if c == "#" {
					positions.insert(Pos(x, y))
				}
			}
		}
	}

	mutating func round() -> Bool {
		var proposed = [Pos: [Pos]]()
		for pos in positions {
			if !adjacents(pos) {
				continue
			}

			for d in directions {
				if !adjacents(pos, d) {
					let next = pos.next(d)
					if proposed[next] == nil {
						proposed[next] = [Pos]()
					}
					proposed[next]!.append(pos)
					break
				}
			}
		}

		if proposed.count == 0 {
			return false
		}

		for (dst, srcs) in proposed {
			if srcs.count == 1 {
				positions.remove(srcs[0])
				positions.insert(dst)
			}
		}

		rotateDirections()
		return true
	}

	mutating func simulate() -> Int {
		var rounds = 1
		while true {
			if !round() {
				break
			}
			rounds += 1
		}
		return rounds
	}

	mutating func run(rounds: Int) -> Int {
		for _ in 0 ..< rounds {
			if !round() {
				break
			}
		}

		let minx = positions.min { $0.x < $1.x }!.x
		let maxx = positions.max { $0.x < $1.x }!.x
		let miny = positions.min { $0.y < $1.y }!.y
		let maxy = positions.max { $0.y < $1.y }!.y

		var empty = 0
		for y in miny ... maxy {
			for x in minx ... maxx {
				if !positions.contains(Pos(x, y)) {
					empty += 1
				}
			}
		}

		return empty
	}

	func adjacents(_ pos: Pos) -> Bool {
		for a in pos.adjacent() {
			if positions.contains(a) {
				return true
			}
		}
		return false
	}

	func adjacents(_ pos: Pos, _ dir: Direction) -> Bool {
		for a in pos.adjacent(dir) {
			if positions.contains(a) {
				return true
			}
		}
		return false
	}

	mutating func rotateDirections() {
		let head = directions.removeFirst()
		directions.append(head)
	}
}

func part1(_ input: Grove) -> Int {
	var g = input
	return g.run(rounds: 10)
}

func part2(_ input: Grove) -> Int {
	var g = input
	return g.simulate()
}

let input = try String(contentsOfFile: "./input.txt", encoding: .utf8)
let grove = Grove(input)
print("Part one:", part1(grove))
print("Part two:", part2(grove))
