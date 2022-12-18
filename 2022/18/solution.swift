import Foundation

struct Point3D: Hashable {
	let x: Int
	let y: Int
	let z: Int

	private static let _neighbours = [
		(1, 0, 0),
		(-1, 0, 0),
		(0, 1, 0),
		(0, -1, 0),
		(0, 0, 1),
		(0, 0, -1),
	]

	init(_ x: Int, _ y: Int, _ z: Int) { self.x = x; self.y = y; self.z = z }

	func neighbours() -> [Point3D] {
		var result = [Point3D]()
		for (dx, dy, dz) in Point3D._neighbours {
			result.append(Point3D(x + dx, y + dy, z + dz))
		}
		return result
	}
}

func exposedSides(_ cubes: Set<Point3D>) -> Int {
	var exposed = 0
	for c in cubes {
		for n in c.neighbours() {
			if !cubes.contains(n) {
				exposed += 1
			}
		}
	}
	return exposed
}

func dropletExteriorSurfaceArea(_ cubes: Set<Point3D>) -> Int {
	let upperBound = cubes.map { max($0.x, $0.y, $0.z) }.max()! + 1
	let lowerBound = cubes.map { min($0.x, $0.y, $0.z) }.min()! - 1
	let r = lowerBound ... upperBound
	var seen = Set<Point3D>()

	var stack = [Point3D(lowerBound, lowerBound, lowerBound)]
	repeat {
		let p = stack.popLast()!
		for n in p.neighbours() {
			if r ~= n.x && r ~= n.y && r ~= n.z && !seen.contains(n) && !cubes.contains(n) {
				stack.append(n)
			}
		}
		seen.insert(p)
	} while stack.count > 0

	var result = 0
	for c in cubes {
		for n in c.neighbours() {
			if seen.contains(n) {
				result += 1
			}
		}
	}
	return result
}

let input = try String(contentsOfFile: "./input.txt", encoding: .utf8)
let cubes = Set(input.split(separator: "\n").map { line in
	let parts = line.split(separator: ",").map { Int(String($0))! }
	return Point3D(parts[0], parts[1], parts[2])
})

print("Part one:", exposedSides(cubes))
print("Part two:", dropletExteriorSurfaceArea(cubes))
