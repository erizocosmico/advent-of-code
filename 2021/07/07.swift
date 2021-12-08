import Foundation

let positions = try String(contentsOfFile: "./input.txt", encoding: .utf8)
	.split(separator: ",")
	.map { Int($0)! }

var (min, max) = (positions.min()!, positions.max()!)
let mid = (max + min) / 2
let inLastHalf = positions.filter { $0 > mid }.count
if inLastHalf >= positions.count / 2 {
	min = mid
} else {
	max = mid
}

func triangularFuelCost(_ steps: Int) -> Int {
	return (steps * steps + steps) / 2
}

func constantFuelCost(_ steps: Int) -> Int { return steps }

func fuelNeededToAlign(_ positions: [Int], _ position: Int, _ fuelCost: (Int) -> Int) -> Int {
	return positions.map { p in fuelCost(abs(p - position)) }.reduce(0, +)
}

print("*", (min ... max).map { fuelNeededToAlign(positions, $0, constantFuelCost) }.min()!)
print("**", (min ... max).map { fuelNeededToAlign(positions, $0, triangularFuelCost) }.min()!)
