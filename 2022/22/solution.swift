import Foundation

struct Pos: Hashable {
	let x: Int
	let y: Int
	init(_ x: Int, _ y: Int) { self.x = x; self.y = y }
}

enum Direction {
	case up, left, right, down

	func value() -> Int {
		switch self {
		case .up: return 3
		case .left: return 2
		case .down: return 1
		case .right: return 0
		}
	}

	func opposite() -> Direction {
		switch self {
		case .up: return .down
		case .left: return .right
		case .down: return .up
		case .right: return .left
		}
	}

	func turnLeft() -> Direction {
		switch self {
		case .up: return .left
		case .left: return .down
		case .down: return .right
		case .right: return .up
		}
	}

	func turnRight() -> Direction {
		switch self {
		case .up: return .right
		case .left: return .up
		case .down: return .left
		case .right: return .down
		}
	}

	func advance() -> (Int, Int) {
		switch self {
		case .up: return (0, -1)
		case .left: return (-1, 0)
		case .down: return (0, 1)
		case .right: return (1, 0)
		}
	}
}

enum Instruction {
	case advance(Int)
	case turnLeft
	case turnRight
}

func parseInstructions<S: StringProtocol>(_ input: S) -> [Instruction] {
	var i = input.startIndex
	var result = [Instruction]()
	while i < input.endIndex {
		switch input[i] {
		case "L":
			result.append(.turnLeft)
			i = input.index(i, offsetBy: 1)
		case "R":
			result.append(.turnRight)
			i = input.index(i, offsetBy: 1)
		default:
			var next = input.index(i, offsetBy: 1)
			while next < input.endIndex, input[next] != "L", input[next] != "R" {
				next = input.index(next, offsetBy: 1)
			}
			result.append(.advance(Int(String(input[i ..< next]))!))
			i = next
		}
	}
	return result
}

struct Board {
	let tiles: [Pos: Bool]
	let start: Pos

	init<S: StringProtocol>(_ input: S) {
		var result = [Pos: Bool]()
		var s: Pos?
		for (y, line) in input.split(separator: "\n").enumerated() {
			for (x, c) in line.enumerated() {
				if c == "." {
					if s == nil {
						s = Pos(x, y)
					}
					result[Pos(x, y)] = true
				} else if c == "#" {
					result[Pos(x, y)] = false
				}
			}
		}
		tiles = result
		start = s!
	}

	func run(_ instructions: [Instruction], cube: Bool = false) -> Int {
		var (pos, dir) = (start, Direction.right)

		for i in instructions {
			switch i {
			case .turnLeft: dir = dir.turnLeft()
			case .turnRight: dir = dir.turnRight()
			case let .advance(n):
				for _ in 0 ..< n {
					let (dx, dy) = dir.advance()
					let next = Pos(pos.x + dx, pos.y + dy)
					if let t = tiles[next] {
						if t {
							pos = next
						} else {
							break
						}
					} else {
						if let (newPos, newDir) = (cube ? wrapCube : wrap)(pos, dir) {
							pos = newPos
							dir = newDir
						} else {
							break
						}
					}
				}
			}
		}

		return (pos.x + 1) * 4 + (pos.y + 1) * 1000 + dir.value()
	}

	func wrap(_ pos: Pos, _ dir: Direction) -> (Pos, Direction)? {
		let (dx, dy) = dir.opposite().advance()
		var (prev, curr) = (pos, pos)
		while true {
			curr = Pos(prev.x + dx, prev.y + dy)
			if tiles[curr] != nil {
				prev = curr
			} else {
				if tiles[prev]! {
					return (prev, dir)
				}
				return nil
			}
		}
	}

	// Cube shape, so that 1 is at the bottom, 6 at the top, 5 on the left and 3 on the right
	//    [2][3]
	//    [1]
	// [5][4]
	// [6]
	func wrapCube(_ pos: Pos, _ dir: Direction) -> (Pos, Direction)? {
		var next = pos
		var d = dir
		if 0 ..< 50 ~= pos.x {
			if 100 ..< 150 ~= pos.y { // cube 5
				if dir == .up { // up to cube 1 left side
					next = Pos(50, pos.x + 50)
					d = .right
				} else { // left to cube 2 left side
					next = Pos(50, 49 - (pos.y - 100))
					d = .right
				}
			} else { // cube 6
				if dir == .left { // left to cube 2 up side
					next = Pos(pos.y - 100, 0)
					d = .down
				} else if dir == .down { // down to cube 3 up side
					next = Pos(pos.x + 100, 0)
					d = .down
				} else { // right to cube 4 down side
					next = Pos(pos.y - 100, 149)
					d = .up
				}
			}
		} else if 50 ..< 100 ~= pos.x {
			if 0 ..< 50 ~= pos.y { // cube 2
				if dir == .up { // up to cube 6 left side
					next = Pos(0, pos.x + 100)
					d = .right
				} else { // left to cube 5 left side
					next = Pos(0, 149 - pos.y)
					d = .right
				}
			} else if 50 ..< 100 ~= pos.y { // cube 1
				if dir == .left { // left to cube 5 up side
					next = Pos(pos.y - 50, 100)
					d = .down
				} else { // right to cube 3 down side
					next = Pos(pos.y + 50, 49)
					d = .up
				}
			} else { // cube 4
				if dir == .right { // right to cube 3 right side
					next = Pos(149, 149 - pos.y)
					d = .left
				} else { // down to cube 6 right side
					next = Pos(49, pos.x + 100)
					d = .left
				}
			}
		} else { // cube 3
			if dir == .up { // up to cube 6 down side
				next = Pos(pos.x - 100, 199)
				d = .up
			} else if dir == .right { // right to cube 4 right side
				next = Pos(99, 149 - pos.y)
				d = .left
			} else { // down to cube 1 right side
				next = Pos(99, pos.x - 50)
				d = .left
			}
		}

		return (tiles[next] ?? false) == true ? (next, d) : nil
	}
}

let input = try String(contentsOfFile: "./input.txt", encoding: .utf8)
let parts = input.split(separator: "\n\n")
let board = Board(parts[0])
let instructions = parseInstructions(parts[1])

print("Part one:", board.run(instructions))
print("Part two:", board.run(instructions, cube: true))
