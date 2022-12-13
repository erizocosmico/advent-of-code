import Foundation

struct Packet: Equatable {
	let data: [Data]

	init<S: StringProtocol>(_ raw: S) throws {
		data = try parseList(raw)
	}

	func before(_ other: Packet) -> Bool {
		return listsOrdered(data, other.data) ?? true
	}

	init(divider: Int) {
		data = [.list([.number(divider)])]
	}

	static func == (lhs: Packet, rhs: Packet) -> Bool {
		return lhs.data == rhs.data
	}
}

enum Data: Equatable {
	case number(Int)
	case list([Data])

	func before(_ other: Data) -> Bool? {
		switch (self, other) {
		case let (.number(a), .number(b)): return a == b ? nil : a < b
		case let (.number(a), .list(l)): return listsOrdered([.number(a)], l)
		case let (.list(l), .number(a)): return listsOrdered(l, [.number(a)])
		case let (.list(l1), .list(l2)): return listsOrdered(l1, l2)
		}
	}

	static func == (lhs: Data, rhs: Data) -> Bool {
		switch (lhs, rhs) {
		case let (.number(a), .number(b)): return a == b
		case let (.list(l1), .list(l2)): return l1 == l2
		default: return false
		}
	}
}

func listsOrdered(_ a: [Data], _ b: [Data]) -> Bool? {
	for i in 0 ..< min(a.count, b.count) {
		if let x = a[i].before(b[i]) {
			return x
		}
	}

	return a.count == b.count ? nil : a.count < b.count
}

enum ParseError: Error {
	case invalidInput
}

func parseList<S: StringProtocol>(_ raw: S) throws -> [Data] {
	let (data, _) = try parseList(raw, from: raw.index(raw.startIndex, offsetBy: 1))
	return data
}

func parseList<S: StringProtocol>(_ raw: S, from: String.Index) throws -> ([Data], String.Index) {
	var idx = from

	var result = [Data]()
	while idx < raw.endIndex {
		let c = raw[idx]
		if c == "[" {
			let (list, next) = try parseList(raw, from: raw.index(idx, offsetBy: 1))
			idx = next
			result.append(.list(list))
		} else if c == "]" {
			return (result, raw.index(idx, offsetBy: 1))
		} else if c == "," {
			idx = raw.index(idx, offsetBy: 1)
		} else {
			let start = idx
			while raw[idx] <= "9", raw[idx] >= "0" {
				idx = raw.index(idx, offsetBy: 1)
			}
			result.append(.number(Int(String(raw[start ..< idx]))!))
		}
	}

	throw ParseError.invalidInput
}

func findDecoderKey(_ input: [Packet]) -> Int {
	let (d1, d2) = (Packet(divider: 2), Packet(divider: 6))
	var packets = input + [d1, d2]
	packets.sort { a, b in a.before(b) }

	var key = 1
	for (i, p) in packets.enumerated() {
		if p == d1 || p == d2 {
			key *= i + 1
		}
	}

	return key
}

func findOrderedPairs(_ pairs: [[Packet]]) -> Int {
	var sum = 0
	for (i, pair) in pairs.enumerated() {
		if pair[0].before(pair[1]) {
			sum += i + 1
		}
	}
	return sum
}

let input = try String(contentsOfFile: "./input.txt", encoding: .utf8)
let pairs: [[Packet]] = try input.split(separator: "\n\n").map { pair in
	try pair.split(separator: "\n").map { line in try Packet(line) }
}

let packets = pairs.flatMap { $0 }

print("Part one:", findOrderedPairs(pairs))
print("Part two:", findDecoderKey(packets))
