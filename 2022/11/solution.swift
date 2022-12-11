import Foundation

struct Monkey {
	var items: [Int] = []
	var inspections: Int = 0
	var operation: (Int) -> Int
	var test: Int
	var passIfTrue: Int
	var passIfFalse: Int

	init(_ raw: String) {
		let parts = [String](raw.split(separator: "\n").dropFirst(1).map { String($0) })
		items = parts[0].split(separator: ": ").last!
			.split(separator: ", ")
			.map { Int(String($0))! }
		let opParts = parts[1].split(separator: "= old ").last!
			.split(separator: " ")
		let n = Int(String(opParts.last!)) ?? 0
		if opParts.first! == "+" {
			operation = opParts.last! == "old" ? { old in old + old } : { old in old + n }
		} else {
			operation = opParts.last! == "old" ? { old in old * old } : { old in old * n }
		}
		test = Int(String(parts[2].split(separator: "divisible by ").last!))!
		passIfTrue = Int(String(parts[3].split(separator: "monkey ").last!))!
		passIfFalse = Int(String(parts[4].split(separator: "monkey ").last!))!
	}
}

func solve(_ input: [Monkey], rounds: Int, manage: (Int) -> Int) -> Int {
	var monkeys = input
	for _ in 0 ..< rounds {
		for i in 0 ..< monkeys.count {
			let m = monkeys[i]
			monkeys[i].inspections += m.items.count
			for item in m.items {
				let level = manage(m.operation(item))
				if level % m.test == 0 {
					monkeys[m.passIfTrue].items.append(level)
				} else {
					monkeys[m.passIfFalse].items.append(level)
				}
			}
			monkeys[i].items = []
		}
	}

	return monkeys.sorted(by: { $0.inspections > $1.inspections })
		.prefix(2).reduce(1) { $0 * $1.inspections }
}

func lcm(_ monkeys: [Monkey]) -> Int {
	var result = monkeys.first!.test
	for m in monkeys.dropFirst(1) {
		result = result * m.test / gcd(result, m.test)
	}

	return result
}

func gcd(_ x: Int, _ y: Int) -> Int {
	var (a, b, r) = (0, max(x, y), min(x, y))

	while r != 0 {
		a = b
		b = r
		r = a % b
	}

	return b
}

let input = try String(contentsOfFile: "./input.txt", encoding: .utf8)
let monkeys = input.split(separator: "\n\n").map { raw in Monkey(String(raw)) }
let modulus = lcm(monkeys)

print("Part one:", solve(monkeys, rounds: 20, manage: { level in level / 3 }))
print("Part two:", solve(monkeys, rounds: 10000, manage: { level in level % modulus }))
