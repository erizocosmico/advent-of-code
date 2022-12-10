import Foundation

enum Instruction {
	case addx(Int)
	case noop
}

enum ParseError: Error {
	case invalidInstruction(String)
}

let input = try String(contentsOfFile: "./input.txt", encoding: .utf8)
let instructions: [Instruction] = try input.split(separator: "\n").map { line in
	let parts = line.split(separator: " ")
	switch parts.first! {
	case "addx": return Instruction.addx(Int(String(parts.last!))!)
	case "noop": return Instruction.noop
	default:
		throw ParseError.invalidInstruction(String(parts.first!))
	}
}

func measureSignals(_ instructions: [Instruction], signals: Set<Int>) -> [Int] {
	var cycles = 1
	var register = 1
	var result = [Int]()
	for i in instructions {
		var incr = 0
		var delay = 0
		switch i {
		case let .addx(n): incr = n
			delay = 2
		case .noop: delay = 1
		}

		for _ in 0 ..< delay {
			if signals.contains(cycles) {
				result.append(register * cycles)
			}
			cycles += 1
		}

		register += incr

		if signals.count == result.count {
			break
		}
	}

	return result
}

func renderCrt(_ instructions: [Instruction]) {
	var cycles = 1
	var pixel = 0
	var register = 1
	for i in instructions {
		var incr = 0
		var delay = 0
		switch i {
		case let .addx(n): incr = n
			delay = 2
		case .noop: delay = 1
		}

		for _ in 0 ..< delay {
			print(abs(register - pixel) <= 1 ? "#" : ".", terminator: "")
			if cycles % 40 == 0 {
				print("")
				pixel = 0
			} else {
				pixel += 1
			}
			cycles += 1
		}

		register += incr
	}
}

let interestingSignals = Set([20, 60, 100, 140, 180, 220])
print("Part one:", measureSignals(instructions, signals: interestingSignals).reduce(0, +))
print("Part two:")
renderCrt(instructions)
