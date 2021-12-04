import Foundation

struct Board {
	var rows: [[Int]]

	init(_ rawBoard: String) {
		rows = rawBoard.split(separator: "\n").map { line in
			line.split(separator: " ").map { n in Int(n)! }
		}
	}

	mutating func mark(_ num: Int) {
		rows = rows.map { row in row.map { n in num == n ? -1 : n } }
	}

	func hasWon() -> Bool {
		for row in rows {
			if row.allSatisfy({ $0 == -1 }) {
				return true
			}
		}

		for i in 0..<rows.first!.count {
			if rows.allSatisfy({ $0[i] == -1 }) {
				return true
			}
		}

		return false
	}

	func score(_ lastNumber: Int) -> Int {
		var result = 0
		for row in rows {
			for num in row {
				if num >= 0 {
					result += num
				}
			}
		}
		return result * lastNumber
	}
}

let lines = try String(contentsOfFile: "./input.txt", encoding: .utf8).components(separatedBy: "\n\n")
let numbers = lines.first!.split(separator: ",").map { n in Int(n)! }
var boards = lines.dropFirst(1).map { board in Board(board) }

for num in numbers {
	for i in 0..<boards.count {
		boards[i].mark(num)
	}

	if let board = boards.first(where: { $0.hasWon() }) {
		print(board.score(num))
		break
	}
}
