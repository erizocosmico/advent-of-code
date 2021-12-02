import Foundation

enum Command {
	case up(Int)
	case down(Int)
	case forward(Int)

	func execute(_ depth: Int, _ pos: Int) -> (Int, Int) {
		switch self {
			case .up(let n): return (depth - n, pos)
			case .down(let n): return (depth + n, pos)
			case .forward(let n): return (depth, pos + n)
		}
	}
}

enum CommandError : Error {
	case invalidCommand
}

func parseCommand(_ line: String) throws -> Command {
	let parts = line.split(separator: " ")
	let n = Int(parts.last!)!
	switch parts.first! {
		case "up": return Command.up(n)
		case "down": return Command.down(n)
		case "forward": return Command.forward(n)
		default: throw CommandError.invalidCommand
	}
}

let input = try String(contentsOfFile: "./input.txt", encoding: .utf8)
let commands = try input.split(separator: "\n").map { line in try parseCommand(String(line)) }
let (depth, pos) = commands.reduce((depth: 0, pos: 0)) { (pos, cmd) in cmd.execute(pos.depth, pos.pos) }

print(depth * pos)