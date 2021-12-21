struct Player: Hashable {
	let pos: Int
	let score: Int

	func moved(_ steps: Int) -> Player {
		let n = (pos + steps) % 10
		let p = n == 0 ? 10 : n
		return Player(pos: p, score: score + p)
	}
}

struct State: Hashable {
	let p1: Player
	let p2: Player
}

var cache = [State: (Int, Int)]()

let diceFreqs = [
	3: 1,
	4: 3,
	5: 6,
	6: 7,
	7: 6,
	8: 3,
	9: 1,
]

func play(_ current: Player, _ other: Player) -> (Int, Int) {
	let state = State(p1: current, p2: other)
	if let r = cache[state] {
		return r
	}

	if current.score >= 21 {
		return (1, 0)
	}

	if other.score >= 21 {
		return (0, 1)
	}

	var (currentWins, otherWins) = (0, 0)
	for r in 3 ... 9 {
		let (cw, ow) = play(other, current.moved(r))
		currentWins += diceFreqs[r]! * ow
		otherWins += diceFreqs[r]! * cw
	}

	cache[state] = (currentWins, otherWins)
	return (currentWins, otherWins)
}

let (p1wins, p2wins) = play(Player(pos: 3, score: 0), Player(pos: 10, score: 0))
print(max(p1wins, p2wins))
