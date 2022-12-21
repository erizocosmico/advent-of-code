import Foundation

enum Monkey {
	case number(Int)
	case math(String, String, String)
}

func number(_ input: [String: Monkey], monkey: String) -> Int {
	switch input[monkey]! {
	case let .number(n): return n
	case let .math(m1, op, m2):
		let n1 = number(input, monkey: m1)
		let n2 = number(input, monkey: m2)
		switch op {
		case "+": return n1 + n2
		case "-": return n1 - n2
		case "/": return n1 / n2
		case "*": return n1 * n2
		default: return -1
		}
	}
}

func hasVar(_ input: [String: Monkey], monkey: String) -> Bool {
	if monkey == "humn" {
		return true
	}
	switch input[monkey]! {
	case let .math(m1, _, m2):
		return hasVar(input, monkey: m1) || hasVar(input, monkey: m2)
	default: return false
	}
}

func solve(_ monkeys: [String: Monkey], monkey: String) -> Int {
	switch monkeys[monkey]! {
	case let .math(a, _, b):
		if hasVar(monkeys, monkey: a) {
			return solve(monkeys, a, number(monkeys, monkey: b))
		}
		return solve(monkeys, b, number(monkeys, monkey: a))
	default: return -1
	}
}

func solve(_ monkeys: [String: Monkey], _ x: String, _ eq: Int) -> Int {
	if x == "humn" {
		return eq
	}

	switch monkeys[x]! {
	case let .math(a, op, b):
		if hasVar(monkeys, monkey: a) {
			let n = number(monkeys, monkey: b)
			switch op {
			case "+": return solve(monkeys, a, eq - n)
			case "-": return solve(monkeys, a, eq + n)
			case "*": return solve(monkeys, a, eq / n)
			case "/": return solve(monkeys, a, eq * n)
			default: return -1
			}
		} else {
			let n = number(monkeys, monkey: a)
			switch op {
			case "+": return solve(monkeys, b, eq - n)
			case "-": return solve(monkeys, b, n - eq)
			case "*": return solve(monkeys, b, eq / n)
			case "/": return solve(monkeys, b, n / eq)
			default: return -1
			}
		}
	default: return -1
	}
}

let input = try String(contentsOfFile: "./input.txt", encoding: .utf8)
var monkeys = [String: Monkey]()
for line in input.split(separator: "\n") {
	let parts = line.split(separator: ": ")
	let name = String(parts[0])
	let ops = parts[1].split(separator: " ").map { String($0) }
	if ops.count == 1 {
		monkeys[name] = .number(Int(ops[0])!)
	} else {
		monkeys[name] = .math(ops[0], ops[1], ops[2])
	}
}

print("Part one:", number(monkeys, monkey: "root"))
print("Part two:", solve(monkeys, monkey: "root"))
