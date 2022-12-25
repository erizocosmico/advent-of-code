import Foundation

func snafuToInt(_ snafu: String) -> Int {
	var result = 0
	for (i, c) in snafu.reversed().enumerated() {
		var n = String(c)
		if n == "-" { n = "-1" } else if n == "=" { n = "-2" }
		result += Int(n)! * Int(pow(Double(5), Double(i)))
	}
	return result
}

func intToSnafu(_ n: Int) -> String {
	var num = n
	var result = ""
	while num > 0 {
		let r = num % 5
		switch r {
		case 3: result = "=" + result
		case 4: result = "-" + result
		default: result = String(r) + result
		}
		num = (num / 5) + (r > 2 ? 1 : 0)
	}
	return result
}

let input = try String(contentsOfFile: "./input.txt", encoding: .utf8)
let numbers = input.split(separator: "\n").map { snafuToInt(String($0)) }
let total = numbers.reduce(0, +)
print("Part one:", intToSnafu(total))
