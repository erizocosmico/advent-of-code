import Foundation

enum PacketContent {
	case value(Int)
	case packets([Packet])
}

struct Packet {
	let version: Int
	let type: Int
	let content: PacketContent

	init(_ version: Int, _ type: Int, _ content: PacketContent) {
		self.version = version
		self.type = type
		self.content = content
	}

	func totalVersion() -> Int {
		switch content {
		case let .packets(p):
			return p.map { $0.totalVersion() }.reduce(version, +)
		default:
			return version
		}
	}

	func value() -> Int {
		switch content {
		case let .value(v): return v
		case let .packets(packets):
			switch type {
			case 0: return packets.map { $0.value() }.reduce(0, +)
			case 1: return packets.map { $0.value() }.reduce(1, *)
			case 2: return packets.map { $0.value() }.min()!
			case 3: return packets.map { $0.value() }.max()!
			case 5: return packets[0].value() > packets[1].value() ? 1 : 0
			case 6: return packets[0].value() < packets[1].value() ? 1 : 0
			case 7: return packets[0].value() == packets[1].value() ? 1 : 0
			default:
				return -1
			}
		}
	}
}

let translation = [
	"0": "0000",
	"1": "0001",
	"2": "0010",
	"3": "0011",
	"4": "0100",
	"5": "0101",
	"6": "0110",
	"7": "0111",
	"8": "1000",
	"9": "1001",
	"A": "1010",
	"B": "1011",
	"C": "1100",
	"D": "1101",
	"E": "1110",
	"F": "1111",
]

func toBinary(_ input: String) -> String {
	return input.map { c in translation[String(c)]! }.reduce("", +)
}

func parseLiteral(_ input: inout String) -> Int {
	var value = ""
	var last = false
	repeat {
		var group = input.prefix(5)
		input.removeFirst(5)

		last = group.removeFirst() == "0"
		value += group
	} while !last

	return Int(value, radix: 2)!
}

func parseSubpackets(_ input: inout String) -> [Packet] {
	let lengthType = Int(String(input.removeFirst()))!
	var packets = [Packet]()
	if lengthType == 1 {
		let numSubpackets = Int(input.prefix(11), radix: 2)!
		input.removeFirst(11)

		for _ in 0 ..< numSubpackets {
			packets.append(parsePacket(&input))
		}
	} else {
		let len = Int(input.prefix(15), radix: 2)!
		input.removeFirst(15)
		var subpacketsInput = String(input.prefix(len))
		input.removeFirst(len)

		while subpacketsInput.count > 0, subpacketsInput.contains("1") {
			packets.append(parsePacket(&subpacketsInput))
		}
	}

	return packets
}

func parseHeader(_ input: inout String) -> (Int, Int) {
	let version = Int(input.prefix(3), radix: 2)!
	let type = Int(input.dropFirst(3).prefix(3), radix: 2)!
	input.removeFirst(6)
	return (version, type)
}

func parsePacket(_ input: inout String) -> Packet {
	let (version, type) = parseHeader(&input)

	if type == 4 {
		return Packet(version, type, .value(parseLiteral(&input)))
	}

	return Packet(version, type, .packets(parseSubpackets(&input)))
}

var message = toBinary(try String(contentsOfFile: "./input.txt", encoding: .utf8))
let packet = parsePacket(&message)

print("*", packet.totalVersion())
print("**", packet.value())
