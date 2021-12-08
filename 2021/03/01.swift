import Foundation

let lines = try String(contentsOfFile: "./input.txt", encoding: .utf8).split(separator: "\n")
let diagnostic = lines.map { line in Int(line, radix: 2)! }

let rowSize = lines.first!.count
let gammaRate = (0 ..< rowSize).map { i in
	let mask = 1 << (rowSize - i - 1)
	let ones = diagnostic.reduce(0) { acc, n in acc + ((n & mask) > 0 ? 1 : 0) }
	return (ones > diagnostic.count / 2) ? mask : 0
}.reduce(0, +)
let epsilonRate = ((1 << rowSize) - 1) ^ gammaRate

print(gammaRate * epsilonRate)
