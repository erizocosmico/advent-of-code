import Foundation

enum Fold {
	case vertical(Int)
	case horizontal(Int)

	func fold(_ paper: Set<Point>) -> Set<Point> {
		switch self {
		case let .vertical(y): return foldVertical(paper, y)
		case let .horizontal(x): return foldHorizontal(paper, x)
		}
	}

	func foldVertical(_ paper: Set<Point>, _ y: Int) -> Set<Point> {
		var new: Set<Point> = []
		var deleted: Set<Point> = []

		for p in paper {
			if p.y > y {
				deleted.insert(p)
				new.insert(Point(x: p.x, y: y - (p.y - y - 1) - 1))
			}
		}

		return paper.union(new).subtracting(deleted)
	}

	func foldHorizontal(_ paper: Set<Point>, _ x: Int) -> Set<Point> {
		var new: Set<Point> = []
		var deleted: Set<Point> = []

		for p in paper {
			if p.x > x {
				deleted.insert(p)
				new.insert(Point(x: x - (p.x - x - 1) - 1, y: p.y))
			}
		}

		return paper.union(new).subtracting(deleted)
	}
}

func display(_ paper: Set<Point>) {
	let maxx = paper.map { $0.x }.max()!
	let maxy = paper.map { $0.y }.max()!

	for y in 0 ... maxy {
		for x in 0 ... maxx {
			print(paper.contains(Point(x: x, y: y)) ? "#" : " ", terminator: "")
		}
		print("")
	}
}

struct Point: Hashable {
	let x: Int
	let y: Int
}

enum ParseError: Error {
	case invalidInstruction(String)
}

let input = try String(contentsOfFile: "./input.txt", encoding: .utf8)
	.components(separatedBy: "\n\n")

let points = try input.first!.split(separator: "\n").map { (line: String.SubSequence) throws -> Point in
	let parts = line.split(separator: ",")
	return Point(x: Int(parts.first!)!, y: Int(parts.last!)!)
}

let paper = Set(points)

let folds = try input.last!.split(separator: "\n").map { (line: String.SubSequence) throws -> Fold in
	let parts = line.split(separator: "=")
	switch parts.first! {
	case "fold along x": return Fold.horizontal(Int(parts.last!)!)
	case "fold along y": return Fold.vertical(Int(parts.last!)!)
	default: throw ParseError.invalidInstruction(String(line))
	}
}

print("First part:", folds.first!.fold(paper).count)

print("Second part:")
let result = folds.reduce(paper) { paper, f in f.fold(paper) }
display(result)
