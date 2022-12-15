import Foundation

struct Point: Hashable {
	let x: Int
	let y: Int

	init(_ x: Int, _ y: Int) { self.x = x; self.y = y }

	func dist(_ other: Point) -> Int {
		return abs(x - other.x) + abs(y - other.y)
	}
}

func parseReadings(_ input: String) -> [(sensor: Point, beacon: Point)] {
	let pattern = #/Sensor at x=(-?\d+), y=(-?\d+): closest beacon is at x=(-?\d+), y=(-?\d+)/#
	return input.split(separator: "\n").map { line in
		let result = String(line).firstMatch(of: pattern)!
		return (sensor: Point(Int(result.1)!, Int(result.2)!), beacon: Point(Int(result.3)!, Int(result.4)!))
	}
}

func partOne(_ readings: [(Point, Point)], y: Int) -> Int {
	var beacons = Set<Point>()
	var occupied = [ClosedRange<Int>]()
	for (sensor, beacon) in readings {
		if beacon.y == y {
			beacons.insert(beacon)
		}
		let dist = sensor.dist(beacon)
		if (sensor.y - dist) ... (sensor.y + dist) ~= y {
			let horizontal = (dist - abs(y - sensor.y))
			occupied.append((sensor.x - horizontal) ... (sensor.x + horizontal))
		}
	}

	let row = joinRanges(occupied)
	let occupiedPoints = row.map { $0.upperBound - $0.lowerBound }.reduce(0, +)
	return occupiedPoints - beacons.count + 1
}

func partTwo(_ readings: [(Point, Point)], bound: Int) -> Int {
	for y in (0 ... bound).reversed() {
		var occupied = [ClosedRange<Int>]()
		for (sensor, beacon) in readings {
			let dist = sensor.dist(beacon)
			if (sensor.y - dist) <= y && (sensor.y + dist) >= y {
				let horizontal = (dist - abs(y - sensor.y))
				occupied.append(max(0, sensor.x - horizontal) ... min(bound, sensor.x + horizontal))
			}
		}

		let row = joinRanges(occupied)
		switch row.count {
		case 1 where row[0].lowerBound > 0: return y
		case 1 where row[0].upperBound < bound: return bound * 4_000_000 + y
		case 2: return (row[0].upperBound + 1) * 4_000_000 + y
		default: continue
		}
	}

	return 0
}

func joinRanges(_ ranges: [ClosedRange<Int>]) -> [ClosedRange<Int>] {
	var result = [ClosedRange<Int>]()
	var current: ClosedRange<Int>?
	for r in ranges.sorted(by: { $0.lowerBound < $1.lowerBound }) {
		if current == nil {
			current = r
		} else if current!.overlaps(r) {
			current = (min(r.lowerBound, current!.lowerBound) ... max(r.upperBound, current!.upperBound))
		} else {
			result.append(current!)
			current = r
		}
	}

	result.append(current!)
	return result
}

let input = try String(contentsOfFile: "./input.txt", encoding: .utf8)
let readings = parseReadings(input)

print("Part one:", partOne(readings, y: 2_000_000))
print("Part two:", partTwo(readings, bound: 4_000_000))
