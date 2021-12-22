import Foundation

struct Cuboid {
	let on: Bool
	let x: ClosedRange<Int>
	let y: ClosedRange<Int>
	let z: ClosedRange<Int>

	func volume() -> Int {
		let n = (x.last! - x.first! + 1) * (y.last! - y.first! + 1) * (z.last! - z.first! + 1)
		return on ? n : -n
	}
}

func parseStep(_ line: String) throws -> Cuboid {
	let parts = line.components(separatedBy: " ")
	let ranges = try parts.last!.components(separatedBy: ",").map(parseRange)
	return Cuboid(on: parts.first! == "on", x: ranges[0], y: ranges[1], z: ranges[2])
}

func parseRange(_ raw: String) throws -> ClosedRange<Int> {
	let parts = raw.dropFirst(2).components(separatedBy: "..")
	return Int(parts.first!)! ... Int(parts.last!)!
}

func reboot(_ steps: [Cuboid]) -> (Int) {
	var cuboids = [Cuboid]()

	for s in steps {
		var new = [Cuboid]()
		for c in cuboids {
			let (minx, maxx) = (max(s.x.first!, c.x.first!), min(s.x.last!, c.x.last!))
			if minx > maxx {
				continue
			}

			let (miny, maxy) = (max(s.y.first!, c.y.first!), min(s.y.last!, c.y.last!))
			if miny > maxy {
				continue
			}

			let (minz, maxz) = (max(s.z.first!, c.z.first!), min(s.z.last!, c.z.last!))
			if minz > maxz {
				continue
			}

			new.append(Cuboid(on: !c.on, x: minx ... maxx, y: miny ... maxy, z: minz ... maxz))
		}

		cuboids.append(contentsOf: new)
		if s.on {
			cuboids.append(s)
		}
	}

	return cuboids.reduce(0) { $0 + $1.volume() }
}

func isIgnored(_ r: ClosedRange<Int>) -> Bool {
	return r.first! < -50 || r.first! > 50 || r.last! > 50 || r.last! < -50
}

func isIgnored(_ s: Cuboid) -> Bool {
	return isIgnored(s.x) || isIgnored(s.y) || isIgnored(s.z)
}

let steps = try String(contentsOfFile: "./input.txt", encoding: .utf8)
	.components(separatedBy: "\n")
	.map(parseStep)

print("*", reboot(steps.filter { !isIgnored($0) }))
print("**", reboot(steps))
