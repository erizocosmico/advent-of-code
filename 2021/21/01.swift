struct Dice {
	var rolls = 0

	mutating func roll() -> Int {
		rolls += 1
		return rolls
	}

	mutating func roll(_ n: Int) -> Int {
		var result = 0
		for _ in 0 ..< n {
			result += roll()
		}
		return result
	}
}

struct Player {
	var pos: Int
	var score = 0

	mutating func move(_ steps: Int) {
		let n = (pos + steps) % 10
		pos = n == 0 ? 10 : n
		score += pos
	}
}

func play(_ player1: Player, _ player2: Player) -> Int {
	var (player1, player2, dice) = (player1, player2, Dice())
	while true {
		player1.move(dice.roll(3))
		if player1.score >= 1000 {
			return player2.score * dice.rolls
		}

		player2.move(dice.roll(3))
		if player2.score >= 1000 {
			return player1.score * dice.rolls
		}
	}
}

print(play(Player(pos: 3), Player(pos: 10)))
