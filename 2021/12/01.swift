import Foundation

let connections = try String(contentsOfFile: "./input.txt", encoding: .utf8)
	.split(separator: "\n")
	.flatMap { (line: String.SubSequence) throws -> [(String, String)] in
		let parts = line.split(separator: "-")
		return [
			(String(parts.first!), String(parts.last!)),
			(String(parts.last!), String(parts.first!)),
		]
	}

let caves = Dictionary(grouping: connections, by: { e in e.0 }).mapValues { v in v.map { e in e.1 } }

func findPaths(_ caves: [String: [String]]) -> [[String]] {
	let seen: Set = ["start"]
	return findPaths(caves, ["start"], seen)
}

func findPaths(_ caves: [String: [String]], _ path: [String], _ seen: Set<String>) -> [[String]] {
	let last = path.last!
	if last == "end" {
		return [path]
	}

	return caves[last]!.filter { cave in !seen.contains(cave) }
		.flatMap { (cave: String) -> [[String]] in
			let isBig = cave.uppercased() == cave
			let seen = !isBig ? seen.union(Set([cave])) : seen
			return findPaths(caves, path + [cave], seen)
		}
}

print(findPaths(caves).count)
