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

	return caves[last]!.filter { cave in
		if cave == "start" {
			return false
		}
		return !seen.contains(cave) || (seen.contains(cave) && !seen.contains("small"))
	}
	.flatMap { (cave: String) -> [[String]] in
		var seen = seen
		if cave.uppercased() != cave {
			if seen.contains(cave), !seen.contains("small") {
				seen = seen.union(Set(["small"]))
			} else {
				seen = seen.union(Set([cave]))
			}
		}
		return findPaths(caves, path + [cave], seen)
	}
}

print(findPaths(caves).count)
