import Foundation

indirect enum Node {
	case elem(Int)
	case pair(Pair)

	func split() -> (Node, Bool) {
		switch self {
		case let .elem(n):
			if n >= 10 {
				let p = Pair(left: .elem(n / 2), right: .elem(n / 2 + n % 2))
				return (.pair(p), true)
			}
			return (self, false)
		case let .pair(p):
			return p.split()
		}
	}

	func explode(_ depth: Int) -> (Node, (left: Int, right: Int)?) {
		switch self {
		case .elem: return (self, nil)
		case let .pair(p):
			switch (p.left, p.right) {
			case let (.elem(l), .elem(r)):
				if depth >= 4 {
					return (.elem(0), (l, r))
				}

				return (self, nil)
			default:
				return p.explode(depth)
			}
		}
	}

	func magnitude() -> Int {
		switch self {
		case let .elem(n): return n
		case let .pair(p): return p.magnitude()
		}
	}

	func addLeft(_ n: Int) -> Node {
		if n == 0 { return self }
		switch self {
		case let .elem(x): return .elem(x + n)
		case let .pair(p): return p.addLeft(n)
		}
	}

	func addRight(_ n: Int) -> Node {
		if n == 0 { return self }
		switch self {
		case let .elem(x): return .elem(x + n)
		case let .pair(p): return p.addRight(n)
		}
	}

	func toPair() -> Pair? {
		switch self {
		case let .pair(p): return p
		default: return nil
		}
	}
}

struct Pair {
	let left: Node
	let right: Node

	func reduce() -> Pair {
		var p = self
		while true {
			let (n, toAdd) = p.explode(0)
			p = n.toPair()!
			if toAdd == nil {
				let (n, splitted) = p.split()
				p = n.toPair()!
				if !splitted {
					return p
				}
			}
		}
	}

	func split() -> (Node, Bool) {
		let (l, splitted) = left.split()
		if splitted {
			return (.pair(Pair(left: l, right: right)), true)
		} else {
			let (r, splitted) = right.split()
			if splitted {
				return (.pair(Pair(left: l, right: r)), true)
			}
		}

		return (.pair(self), false)
	}

	func explode(_ depth: Int) -> (Node, (left: Int, right: Int)?) {
		let (l, toAdd) = left.explode(depth + 1)
		if toAdd != nil {
			return (.pair(Pair(left: l, right: right.addRight(toAdd!.right))), (toAdd!.left, 0))
		} else {
			let (r, toAdd) = right.explode(depth + 1)
			if toAdd != nil {
				return (.pair(Pair(left: left.addLeft(toAdd!.left), right: r)), (0, toAdd!.right))
			}
			return (.pair(self), nil)
		}
	}

	func addRight(_ n: Int) -> Node {
		return .pair(Pair(left: left.addRight(n), right: right))
	}

	func addLeft(_ n: Int) -> Node {
		return .pair(Pair(left: left, right: right.addLeft(n)))
	}

	func magnitude() -> Int {
		return left.magnitude() * 3 + right.magnitude() * 2
	}
}

enum ParseError: Error {
	case expected(Character)
	case invalidElement
}

func expect(_ input: inout String, _ ch: Character) throws {
	if input.first! != ch {
		throw ParseError.expected(ch)
	}
	input.removeFirst(1)
}

func parsePair(_ input: inout String) throws -> Pair {
	try expect(&input, "[")
	let left = try parseElement(&input)
	try expect(&input, ",")
	let right = try parseElement(&input)
	try expect(&input, "]")
	return Pair(left: left, right: right)
}

func parseElement(_ input: inout String) throws -> Node {
	switch input.first! {
	case "[":
		return .pair(try parsePair(&input))
	case "0" ... "9":
		let n = Int(String(input.first!))!
		input.removeFirst(1)
		return .elem(n)
	default:
		throw ParseError.invalidElement
	}
}

func sum(_ a: Pair, _ b: Pair) -> Pair {
	return Pair(left: .pair(a), right: .pair(b)).reduce()
}

let numbers = try String(contentsOfFile: "./input.txt", encoding: .utf8)
	.split(separator: "\n")
	.map { (line: String.SubSequence) throws -> Pair in
		var line = String(line)
		return try parsePair(&line)
	}

print("*", numbers.dropFirst(1).reduce(numbers.first!, sum).magnitude())

var maxMagnitude = 0
for i in 0 ..< numbers.count {
	for j in i + 1 ..< numbers.count {
		let m1 = sum(numbers[i], numbers[j]).magnitude()
		let m2 = sum(numbers[j], numbers[i]).magnitude()
		if m1 > maxMagnitude {
			maxMagnitude = m1
		} else if m2 > maxMagnitude {
			maxMagnitude = m2
		}
	}
}

print("**", maxMagnitude)
