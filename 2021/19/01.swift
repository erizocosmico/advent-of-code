import Foundation

struct Point: Hashable {
	let x: Int
	let y: Int
	let z: Int

	init(_ x: Int, _ y: Int, _ z: Int) {
		self.x = x
		self.y = y
		self.z = z
	}

	func vector(_ p: Point) -> Vector {
		return Vector(x - p.x, y - p.y, z - p.z)
	}

	func align(_ v: Vector) -> Point {
		return Point(x - v.x, y - v.y, z - v.z)
	}
}

struct Vector: Hashable {
	let x: Int
	let y: Int
	let z: Int

	init(_ x: Int, _ y: Int, _ z: Int) {
		self.x = x
		self.y = y
		self.z = z
	}

	func distance(_ v: Vector) -> Int {
		return abs(x - v.x) + abs(y - v.y) + abs(z - v.z)
	}
}

let rotations: [(Point) -> Point] = [
	{ Point(+$0.x, +$0.y, +$0.z) },
	{ Point(+$0.y, +$0.z, +$0.x) },
	{ Point(+$0.z, +$0.x, +$0.y) },
	{ Point(+$0.z, +$0.y, -$0.x) },
	{ Point(+$0.y, +$0.x, -$0.z) },
	{ Point(+$0.x, +$0.z, -$0.y) },

	{ Point(+$0.x, -$0.y, -$0.z) },
	{ Point(+$0.y, -$0.z, -$0.x) },
	{ Point(+$0.z, -$0.x, -$0.y) },
	{ Point(+$0.z, -$0.y, +$0.x) },
	{ Point(+$0.y, -$0.x, +$0.z) },
	{ Point(+$0.x, -$0.z, +$0.y) },

	{ Point(-$0.x, +$0.y, -$0.z) },
	{ Point(-$0.y, +$0.z, -$0.x) },
	{ Point(-$0.z, +$0.x, -$0.y) },
	{ Point(-$0.z, +$0.y, +$0.x) },
	{ Point(-$0.y, +$0.x, +$0.z) },
	{ Point(-$0.x, +$0.z, +$0.y) },

	{ Point(-$0.x, -$0.y, +$0.z) },
	{ Point(-$0.y, -$0.z, +$0.x) },
	{ Point(-$0.z, -$0.x, +$0.y) },
	{ Point(-$0.z, -$0.y, -$0.x) },
	{ Point(-$0.y, -$0.x, -$0.z) },
	{ Point(-$0.x, -$0.z, -$0.y) },
]

func rotate(_ scanner: [Point], _ rotation: (Point) -> Point) -> [Point] {
	return scanner.map(rotation)
}

let scanners = try String(contentsOfFile: "./input.txt", encoding: .utf8)
	.components(separatedBy: "\n\n")
	.map { (section: String) throws -> [Point] in
		try section.split(separator: "\n").dropFirst(1).map { (line: String.SubSequence) throws -> Point in
			let parts = line.split(separator: ",")
			return Point(Int(String(parts[0]))!, Int(String(parts[1]))!, Int(String(parts[2]))!)
		}
	}

var beacons = Set(scanners.first!)
var remaining = Set(scanners.dropFirst(1))
var sensorVectors: Set = [Vector(0, 0, 0)]

repeat {
	for b in beacons {
		for s in remaining {
			for r in rotations {
				let rotated = rotate(s, r)
				for p in rotated {
					let v = p.vector(b)
					let aligned = Set(rotated.map { $0.align(v) })
					if aligned.intersection(beacons).count >= 12 {
						beacons.formUnion(aligned)
						remaining.remove(s)
						sensorVectors.insert(v)
						break
					}
				}
			}
		}
	}
} while remaining.count > 0

print("*", beacons.count)

let vectors = Array(sensorVectors)
var largestDistance = 0
for i in 0 ..< vectors.count {
	for j in i ..< vectors.count {
		let dist = vectors[i].distance(vectors[j])
		if dist > largestDistance {
			largestDistance = dist
		}
	}
}

print("**", largestDistance)
