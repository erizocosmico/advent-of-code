import Foundation

enum Tile {
	case air, rock, sand
}

struct Point: Hashable {
	let x: Int
	let y: Int
}

func scanMap(_ input: String) -> [Point: Tile] {
	var map = [Point: Tile]()
	for line in input.split(separator: "\n") {
		let parts = line.split(separator: " -> ")
		var (fromx, fromy) = parseCoordinates(parts.first!)
		for part in parts.dropFirst(1) {
			let (tox, toy) = parseCoordinates(part)
			for x in min(fromx, tox) ... max(fromx, tox) {
				for y in min(fromy, toy) ... max(fromy, toy) {
					map[Point(x: x, y: y)] = .rock
				}
			}
			fromx = tox
			fromy = toy
		}
	}

	return map
}

func parseCoordinates<S: StringProtocol>(_ raw: S) -> (Int, Int) {
	let parts = raw.split(separator: ",")
	let x = Int(String(parts.first!))!
	let y = Int(String(parts.last!))!
	return (x, y)
}

let sandOrigin = (x: 500, y: 0)
let sandMoves = [
	(0, 1),
	(-1, 1),
	(1, 1),
]

func partOne(_ input: [Point: Tile]) -> Int {
	var map = input
	let maxy = input.max { $0.key.y < $1.key.y }!.key.y
	var sand = 0

	outer: while true {
		var (x, y) = sandOrigin

		sandLoop: while true {
			for (dx, dy) in sandMoves {
				if (map[Point(x: x + dx, y: y + dy)] ?? .air) == .air {
					x += dx
					y += dy
					if y > maxy {
						break outer
					}
					continue sandLoop
				}
			}

			map[Point(x: x, y: y)] = .sand
			sand += 1
			break
		}
	}

	return sand
}

func partTwo(_ input: [Point: Tile]) -> Int {
	var map = input
	let floor = input.max { $0.key.y < $1.key.y }!.key.y + 2
	var sand = 0
	let origin = Point(x: sandOrigin.x, y: sandOrigin.y)

	while map[origin] == nil {
		var (x, y) = sandOrigin

		sandLoop: while true {
			for (dx, dy) in sandMoves {
				if (map[Point(x: x + dx, y: y + dy)] ?? .air) == .air && y + dy != floor {
					x += dx
					y += dy
					continue sandLoop
				}
			}

			map[Point(x: x, y: y)] = .sand
			sand += 1
			break
		}
	}

	return sand
}

let input = try String(contentsOfFile: "./input.txt", encoding: .utf8)
let map = scanMap(input)

print("Part one:", partOne(map))
print("Part two:", partTwo(map))
