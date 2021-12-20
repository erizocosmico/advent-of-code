import Foundation

struct Point: Hashable {
	let x: Int
	let y: Int

	init(_ x: Int, _ y: Int) {
		self.x = x
		self.y = y
	}
}

let parts = try String(contentsOfFile: "./input.txt", encoding: .utf8)
	.components(separatedBy: "\n\n")
let algorithm = Array(parts.first!).map { c in c == "#" ? 1 : 0 }
var input = [Point: Int]()
for (y, line) in parts.last!.components(separatedBy: "\n").enumerated() {
	for (x, c) in line.enumerated() {
		input[Point(x, y)] = c == "#" ? 1 : 0
	}
}

func bounds(_ input: [Point: Int]) throws -> (ClosedRange<Int>, ClosedRange<Int>) {
	let points = input.map { $0.key }
	let xs = points.map { $0.x }
	let ys = points.map { $0.y }
	let xrange = (xs.min()! - 1) ... (xs.max()! + 1)
	let yrange = (ys.min()! - 1) ... (ys.max()! + 1)
	return (xrange, yrange)
}

func index(_ input: [Point: Int], _ p: Point, _ infiniteValue: Int) -> Int {
	var result = 0
	for dy in 0 ..< 3 {
		for dx in 0 ..< 3 {
			let target = Point(p.x + dx - 1, p.y + dy - 1)
			result |= (input[target] ?? infiniteValue) << (8 - (dy * 3 + dx))
		}
	}
	return result
}

func enhance(_ input: [Point: Int], _ algorithm: [Int], _ infiniteValue: Int) throws -> ([Point: Int], Int) {
	let (xrange, yrange) = try bounds(input)
	var output = [Point: Int]()

	for x in xrange {
		for y in yrange {
			let p = Point(x, y)
			output[p] = algorithm[index(input, p, infiniteValue)]
		}
	}

	return (output, infiniteValue == 0 ? algorithm.first! : algorithm.last!)
}

func enhance(_ input: [Point: Int], _ algorithm: [Int], times: Int) throws -> [Point: Int] {
	var output = input
	var infiniteValue = 0
	for _ in 0 ..< times {
		let (enhanced, v) = try enhance(output, algorithm, infiniteValue)
		output = enhanced
		infiniteValue = v
	}
	return output
}

func countLits(_ img: [Point: Int]) -> Int {
	return img.filter { $0.value == 1 }.count
}

print("*", countLits(try enhance(input, algorithm, times: 2)))
print("**", countLits(try enhance(input, algorithm, times: 50)))
