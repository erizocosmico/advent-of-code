import Foundation

enum Resource: Hashable {
	case ore, clay, obsidian, geode
}

typealias Blueprint = [Resource: [Resource: Int]]

func blueprintsQuality(_ bs: [Blueprint], time: Int) async -> Int {
	return await withTaskGroup(of: Int.self) { group in
		for (i, b) in bs.enumerated() {
			group.addTask {
				(i + 1) * blueprintGeodes(b, time: time)
			}
		}

		var result = 0
		for await res in group {
			result += res
		}

		return result
	}
}

func blueprintsGeodes(_ bs: [Blueprint], time: Int) async -> Int {
	return await withTaskGroup(of: Int.self) { group in
		for i in 0 ..< min(3, bs.count) {
			group.addTask { blueprintGeodes(bs[i], time: time) }
		}

		var result = 1
		for await res in group {
			result *= res
		}

		return result
	}
}

let buildOrder: [Resource] = [
	.geode,
	.obsidian,
	.clay,
	.ore,
]

func blueprintGeodes(_ b: Blueprint, time: Int) -> Int {
	let resources = [Resource: Int]()
	let robots = [Resource.ore: 1]
	var best = 0
	let result = blueprintGeodes(b, time: time, resources: resources, robots: robots, best: &best, banned: [])
	print(result)
	return result
}

func simulateGeodes(robots: Int, current: Int, time: Int) -> Int {
	var result = current
	var t = time
	while t > 0 {
		result += robots
		t -= 1
	}
	return result
}

func blueprintGeodes(_ b: Blueprint, time: Int, resources: [Resource: Int], robots: [Resource: Int], best: inout Int, banned: [Resource]) -> Int {
	if time == 0 {
		best = max(best, resources[.geode] ?? 0)
		return resources[.geode] ?? 0
	}

	if best > 0 && ((robots[.geode] ?? 0) * time + (resources[.geode] ?? 0) + time) < best / 5 {
		return 0
	}

	/*
	 if best > 0 && time < 5 && simulateGeodes(robots: robots[.geode] ?? 0, current: resources[.geode] ?? 0, time: time) < (best - time / 2) {
	 	return 0
	 }*/

	var result = 0
	var newResources = resources
	for (r, n) in robots {
		newResources[r] = (newResources[r] ?? 0) + n
	}

	var newBanned = [Resource]()
	for r in buildOrder {
		if time == 1 || (time < 3 && r != .geode) {
			break
		}

		if !shouldBuildRobot(b, typ: r, robots: robots) || banned.contains(r) {
			continue
		}

		if canBuildRobot(cost: b[r]!, resources: resources) {
			var rs = newResources
			for (res, n) in b[r]! {
				rs[res] = rs[res]! - n
			}
			var newRobots = robots
			newRobots[r] = (newRobots[r] ?? 0) + 1
			result = max(result, blueprintGeodes(b, time: time - 1, resources: rs, robots: newRobots, best: &best, banned: []))

			if r == .geode {
				return result
			}

			newBanned.append(r)
		}
	}

	return max(result, blueprintGeodes(b, time: time - 1, resources: newResources, robots: robots, best: &best, banned: newBanned))
}

func canBuildRobot(cost: [Resource: Int], resources: [Resource: Int]) -> Bool {
	for (res, n) in cost {
		if resources[res] ?? 0 < n {
			return false
		}
	}
	return true
}

func shouldBuildRobot(_ b: Blueprint, typ: Resource, robots: [Resource: Int]) -> Bool {
	if typ == .geode {
		return true
	}

	var maxReq = 0
	for r in buildOrder {
		maxReq = max(maxReq, b[r]![typ] ?? 0)
	}

	let current = robots[typ] ?? 0
	return current < maxReq
}

let input = try String(contentsOfFile: "./input.txt", encoding: .utf8)
let blueprints: [Blueprint] = input.split(separator: "\n").map { line in
	let parts = String(line).components(separatedBy: CharacterSet.decimalDigits.inverted).filter { $0 != "" }.map { String($0) }
	return [
		Resource.ore: [.ore: Int(parts[1])!],
		Resource.clay: [.ore: Int(parts[2])!],
		Resource.obsidian: [.ore: Int(parts[3])!, .clay: Int(parts[4])!],
		Resource.geode: [.ore: Int(parts[5])!, .obsidian: Int(parts[6])!],
	]
}

// print("Part one:", await blueprintsQuality(blueprints, time: 24))
print("Part two:", await blueprintsGeodes(blueprints, time: 32))
