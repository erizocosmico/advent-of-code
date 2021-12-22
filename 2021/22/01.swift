import Foundation

struct Point: Hashable {
	let x: Int
	let y: Int
	let z: Int
}

enum Step {
	case on(ClosedRange<Int>, ClosedRange<Int>, ClosedRange<Int>)
	case off(ClosedRange<Int>, ClosedRange<Int>, ClosedRange<Int>)

	func points() -> Set<Point> {
		switch self {
		case let .on(x, y, z): return expand(x, y, z)
		case let .off(x, y, z): return expand(x, y, z)
		}
	}

	func expand(_ xs: ClosedRange<Int>, _ ys: ClosedRange<Int>, _ zs: ClosedRange<Int>) -> Set<Point> {
		var result: Set<Point> = []
		for x in xs {
			for y in ys {
				for z in zs {
					result.insert(Point(x: x, y: y, z: z))
				}
			}
		}
		return result
	}

	func apply(_ s: inout Set<Point>) {
		switch self {
		case .on: s.formUnion(points())
		case .off: s.subtract(points())
		}
	}
}

func parseStep(_ line: String) throws -> Step {
	let parts = line.components(separatedBy: " ")
	let ranges = try parts.last!.components(separatedBy: ",").map(parseRange)
	if parts.first! == "on" {
		return .on(ranges[0], ranges[1], ranges[2])
	}
	return .off(ranges[0], ranges[1], ranges[2])
}

func parseRange(_ raw: String) throws -> ClosedRange<Int> {
	let parts = raw.dropFirst(2).components(separatedBy: "..")
	return Int(parts.first!)! ... Int(parts.last!)!
}

func reboot(_ steps: [Step]) -> Set<Point> {
	var result: Set<Point> = []
	for s in steps {
		s.apply(&result)
	}
	return result
}

func isIgnored(_ r: ClosedRange<Int>) -> Bool {
	return r.first! < -50 || r.first! > 50 || r.last! > 50 || r.last! < -50
}

func isIgnored(_ s: Step) -> Bool {
	switch s {
	case let .on(x, y, z): return isIgnored(x) || isIgnored(y) || isIgnored(z)
	case let .off(x, y, z): return isIgnored(x) || isIgnored(y) || isIgnored(z)
	}
}

let steps = try String(contentsOfFile: "./input.txt", encoding: .utf8)
	.components(separatedBy: "\n")
	.map(parseStep)

print("*", reboot(steps.filter { !isIgnored($0) }).count)
print("**", reboot(steps).count)
