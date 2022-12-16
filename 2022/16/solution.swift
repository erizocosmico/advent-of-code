import Foundation

struct Valve {
	let flow: Int
	let neighbours: [String]
}

func parseValves(_ input: String) -> [String: Valve] {
	let pattern = #/Valve ([A-Z]+) has flow rate=(\d+); tunnels? leads? to valves? ([A-Z, ]+)/#
	var result = [String: Valve]()
	input.split(separator: "\n").forEach { line in
		let m = String(line).firstMatch(of: pattern)!
		result[String(m.1)] = Valve(flow: Int(m.2)!, neighbours: m.3.split(separator: ", ").map { String($0) })
	}
	return result
}

typealias Destination = (valve: String, time: Int)

typealias Paths = [String: [Destination]]

struct Path: Hashable {
	let from: String
	let to: String
}

func buildPaths(_ valves: [String: Valve], start: String) -> Paths {
	var visited = Set<Path>()
	var pending = Set<Path>()
	var result = Paths()

	for (v, _) in valves {
		let path = Path(from: v, to: v)
		pending.insert(path)
		visited.insert(path)
	}

	var time = 1
	repeat {
		var next = Set<Path>()
		for p in pending {
			for n in valves[p.to]!.neighbours {
				let path = Path(from: p.from, to: n)
				if !visited.contains(path) {
					visited.insert(path)
					next.insert(path)
					if path.from != path.to && (valves[path.from]!.flow > 0 || path.from == start) && valves[path.to]!.flow > 0 {
						if result[path.from] == nil {
							result[path.from] = [Destination]()
						}
						result[path.from]!.append((valve: path.to, time: time))
					}
				}
			}
		}
		time += 1
		pending = next
	} while pending.count > 0

	return result
}

func findMaxPressure(_ valves: [String: Valve], paths: Paths, minutes: Int, helper: Bool) -> Int {
	var open = Set<String>()
	if !helper {
		return findMaxPressure(valves, paths: paths, minutes: minutes, valve: "AA", open: &open)
	}

	return findMaxPressure(valves, paths: paths, m1: minutes, m2: minutes, v1: "AA", v2: "AA", open: &open)
}

func findMaxPressure(_ valves: [String: Valve], paths: Paths, minutes: Int, valve: String, open: inout Set<String>) -> Int {
	var result = 0
	for p in paths[valve]! {
		if !open.contains(p.valve) && minutes >= p.time + 1 {
			open.insert(p.valve)
			let remainingTime = minutes - p.time - 1
			let pressure = findMaxPressure(valves, paths: paths, minutes: remainingTime, valve: p.valve, open: &open)
			open.remove(p.valve)
			result = max(result, pressure + remainingTime * valves[p.valve]!.flow)
		}
	}
	return result
}

func findMaxPressure(_ valves: [String: Valve], paths: Paths, m1: Int, m2: Int, v1: String, v2: String, open: inout Set<String>) -> Int {
	var result = 0
	for p in paths[v1]! {
		if !open.contains(p.valve) && m1 >= p.time + 1 {
			open.insert(p.valve)
			let remainingTime = m1 - p.time - 1
			let pressure = findMaxPressure(valves, paths: paths, m1: m2, m2: remainingTime, v1: v2, v2: p.valve, open: &open)
			open.remove(p.valve)
			result = max(result, pressure + remainingTime * valves[p.valve]!.flow)
		}
	}
	return result
}

let input = try String(contentsOfFile: "./input.txt", encoding: .utf8)
let valves = parseValves(input)
let paths = buildPaths(valves)

print("Part one:", findMaxPressure(valves, paths: paths, minutes: 30, helper: false))
print("Part two:", findMaxPressure(valves, paths: paths, minutes: 26, helper: true))
