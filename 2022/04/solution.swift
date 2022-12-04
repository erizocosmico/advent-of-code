import Foundation

func parseAssignment(_ s: String) -> Set<Int> {
	let parts = s.split(separator: "-")
	return Set(Int(parts.first!)! ... Int(parts.last!)!)
}

let lines = try String(contentsOfFile: "./input.txt", encoding: .utf8).split(separator: "\n")
let pairs: [(Set<Int>, Set<Int>)] = lines.map { line in
	let parts = line.split(separator: ",")
	return (parseAssignment(String(parts.first!)), parseAssignment(String(parts.last!)))
}

let fullOverlaps = pairs.filter { a, b in a.isSubset(of: b) || b.isSubset(of: a) }
let overlaps = pairs.filter { a, b in a.intersection(b).count > 0 }

print("Part one:", fullOverlaps.count)
print("Part two:", overlaps.count)
