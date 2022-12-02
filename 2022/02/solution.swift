import Foundation

enum Shape {
	case rock, paper, scissors

	func score() -> Int {
		switch self {
		case .rock: return 1
		case .paper: return 2
		case .scissors: return 3
		}
	}

	func beats(_ s: Shape) -> Bool {
		switch self {
		case .rock: return s == .scissors
		case .paper: return s == .rock
		case .scissors: return s == .paper
		}
	}

	func beats() -> Shape {
		switch self {
		case .rock: return .scissors
		case .paper: return .rock
		case .scissors: return .paper
		}
	}

	func loses() -> Shape {
		switch self {
		case .rock: return .paper
		case .paper: return .scissors
		case .scissors: return .rock
		}
	}
}

enum Outcome {
	case lose, draw, win

	func score() -> Int {
		switch self {
		case .lose: return 0
		case .draw: return 3
		case .win: return 6
		}
	}
}

func roundScore(_ s: Shape, _ o: Outcome) -> Int {
	switch o {
	case .draw: return o.score() + s.score()
	case .win: return o.score() + s.loses().score()
	case .lose: return o.score() + s.beats().score()
	}
}

func roundScore(_ other: Shape, _ you: Shape) -> Int {
	if other.beats(you) {
		return 0 + you.score()
	} else if you.beats(other) {
		return 6 + you.score()
	} else {
		return 3 + you.score()
	}
}

let shapes: [String: Shape] = [
	"A": .rock,
	"B": .paper,
	"C": .scissors,
	"X": .rock,
	"Y": .paper,
	"Z": .scissors,
]

let outcomes: [String: Outcome] = [
	"X": .lose,
	"Y": .draw,
	"Z": .win,
]

let lines = try String(contentsOfFile: "./input.txt", encoding: .utf8).split(separator: "\n")

func partOne() -> Int {
	let rounds = lines.map { round in
		let parts = round.split(separator: " ")
		return (shapes[String(parts[0])]!, shapes[String(parts[1])]!)
	}

	let total = rounds.map(roundScore).reduce(0, +)
	return total
}

func partTwo() -> Int {
	let rounds = lines.map { round in
		let parts = round.split(separator: " ")
		return (shapes[String(parts[0])]!, outcomes[String(parts[1])]!)
	}

	let total = rounds.map(roundScore).reduce(0, +)
	return total
}

print("Part one:", partOne())
print("Part two:", partTwo())
