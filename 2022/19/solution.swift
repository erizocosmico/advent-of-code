import Foundation

enum Resource {
	case ore, clay, obsidian, geode
}

struct State: Hashable {
	var ore: Int
	var clay: Int
	var obsidian: Int
	var geodes: Int

	var oreRobots: Int
	var clayRobots: Int
	var obsidianRobots: Int
	var geodeRobots: Int

	var time: Int

	func canBuild(_ cost: Cost) -> Bool {
		return cost.ore <= ore && cost.clay <= clay && cost.obsidian <= obsidian
	}

	func shouldBuild(_ b: inout Blueprint, _ typ: Resource) -> Bool {
		let maxReq = b.maxCost[typ] ?? 0
		switch typ {
		case .ore: return oreRobots < maxReq
		case .geode: return true
		case .clay: return clayRobots < maxReq
		case .obsidian: return obsidianRobots < maxReq
		}
	}

	mutating func collect() {
		ore += oreRobots
		clay += clayRobots
		obsidian += obsidianRobots
		geodes += geodeRobots
		time -= 1
	}

	mutating func pay(_ cost: Cost) {
		ore -= cost.ore
		clay -= cost.clay
		obsidian -= cost.obsidian
	}

	mutating func build(_ typ: Resource, _ cost: Cost) {
		pay(cost)
		switch typ {
		case .ore: oreRobots += 1
		case .clay: clayRobots += 1
		case .obsidian: obsidianRobots += 1
		case .geode: geodeRobots += 1
		}
	}
}

struct Cost {
	let ore: Int
	let clay: Int
	let obsidian: Int
}

struct Blueprint {
	let ore: Cost
	let clay: Cost
	let obsidian: Cost
	let geode: Cost

	lazy var robots: [(Resource, Cost)] = [(.geode, geode), (.obsidian, obsidian), (.clay, clay), (.ore, ore)]

	lazy var maxCost: [Resource: Int] = {
		var result = [Resource: Int]()
		for (_, cost) in robots {
			result[.ore] = max(result[.ore] ?? 0, cost.ore)
			result[.clay] = max(result[.clay] ?? 0, cost.clay)
			result[.obsidian] = max(result[.obsidian] ?? 0, cost.obsidian)
		}
		return result
	}()

	mutating func maxGeodes(time: Int) -> Int {
		var best = 0
		var cache = [State: Int]()
		let state = State(
			ore: 0, clay: 0, obsidian: 0, geodes: 0,
			oreRobots: 1, clayRobots: 0, obsidianRobots: 0, geodeRobots: 0,
			time: time
		)
		return maxGeodes(state: state, cache: &cache, best: &best, banned: [])
	}

	mutating func maxGeodes(state: State, cache: inout [State: Int], best: inout Int, banned: [Resource]) -> Int {
		if state.time == 0 {
			best = max(best, state.geodes)
			return state.geodes
		}

		if let geodes = cache[state] {
			return geodes
		}

		if best > 0 && (state.geodeRobots * state.time + state.geodes + state.time) < best / 5 {
			return 0
		}

		var result = 0
		var newState = state
		newState.collect()

		var newBanned = [Resource]()
		for (typ, cost) in robots {
			if state.time == 1 || (state.time < 3 && typ != .geode) {
				break
			}

			if !state.shouldBuild(&self, typ) || banned.contains(typ) {
				continue
			}

			if state.canBuild(cost) {
				var ss = newState
				ss.build(typ, cost)
				result = max(result, maxGeodes(state: ss, cache: &cache, best: &best, banned: []))
				cache[ss] = result
				if typ == .geode {
					return result
				}

				newBanned.append(typ)
			}
		}

		result = max(result, maxGeodes(state: newState, cache: &cache, best: &best, banned: newBanned))
		cache[newState] = result

		return result
	}
}

func blueprintsQuality(_ bs: [Blueprint], time: Int) async -> Int {
	return await withTaskGroup(of: Int.self) { group in
		for i in 0 ..< bs.count {
			group.addTask {
				var b = bs[i]
				return (i + 1) * b.maxGeodes(time: time)
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
			group.addTask {
				var b = bs[i]
				return b.maxGeodes(time: time)
			}
		}

		var result = 1
		for await res in group {
			result *= res
		}

		return result
	}
}

let input = try String(contentsOfFile: "./input.txt", encoding: .utf8)
let blueprints: [Blueprint] = input.split(separator: "\n").map { line in
	let parts = String(line).components(separatedBy: CharacterSet.decimalDigits.inverted).filter { $0 != "" }.map { String($0) }
	return Blueprint(
		ore: Cost(ore: Int(parts[1])!, clay: 0, obsidian: 0),
		clay: Cost(ore: Int(parts[2])!, clay: 0, obsidian: 0),
		obsidian: Cost(ore: Int(parts[3])!, clay: Int(parts[4])!, obsidian: 0),
		geode: Cost(ore: Int(parts[5])!, clay: 0, obsidian: Int(parts[6])!)
	)
}

print("Part one:", await blueprintsQuality(blueprints, time: 24))
print("Part two:", await blueprintsGeodes(blueprints, time: 32))
