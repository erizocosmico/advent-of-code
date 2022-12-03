import Foundation

func priority(_ c: Character) -> Int {
	let ascii = Int(c.asciiValue!)
	if c.isLowercase {
		return ascii - 96
	}
	return ascii - 64 + 26
}

let rucksacks = try String(contentsOfFile: "./input.txt", encoding: .utf8).split(separator: "\n")

let partOne = rucksacks.map { r in
	let middle = r.count / 2
	let left = Set<Character>(r.prefix(middle))
	let right = Set<Character>(r.dropFirst(middle))
	let common = left.intersection(right).first!
	return priority(common)
}.reduce(0, +)
print("Part One:", partOne)

let rucsackSets = rucksacks.map { Set<Character>($0) }
let groups = stride(from: 0, to: rucsackSets.count, by: 3).map {
	Array(rucsackSets[$0 ..< min($0 + 3, rucsackSets.count)])
}

let partTwo = groups.map { g in
	let common = g.dropFirst(1)
		.reduce(g.first!) { Set($0.intersection($1)) }
		.first!
	return priority(common)
}.reduce(0, +)

print("Part Two:", partTwo)
