import Foundation

struct Deck: Hashable {
  var cards: [Int]

  init(_ initialCards: [Int]) {
    cards = initialCards
  }

  mutating func draw() -> Int {
    return cards.removeFirst()
  }

  mutating func put(_ cards: Int...) {
    self.cards.append(contentsOf: cards)
  }

  func score() -> Int {
    var score = 0
    for (i, card) in cards.enumerated() {
      score += (cards.count - i) * card
    }
    return score
  }
}

func parseDeck(_ input: String) -> Deck {
  return Deck(input.components(separatedBy: "\n").dropFirst().map { Int($0)! })
}

struct State: Hashable {
  let deck1: Int
  let deck2: Int
}

func playRecursiveCombat(_ p1: inout Deck, _ p2: inout Deck) -> (Int, Int) {
  var seenDecks = Set<State>()
  while !p1.cards.isEmpty && !p2.cards.isEmpty {
    let state = State(deck1: p1.score(), deck2: p2.score())
    if seenDecks.contains(state) {
      return (1, 0)
    }
    seenDecks.update(with: state)

    let (card1, card2) = (p1.draw(), p2.draw())
    var firstWon = false
    if card1 <= p1.cards.count && card2 <= p2.cards.count {
      var deck1 = Deck([Int](p1.cards[0..<card1]))
      var deck2 = Deck([Int](p2.cards[0..<card2]))
      let (firstScore, _) = playRecursiveCombat(&deck1, &deck2)
      firstWon = firstScore > 0
    } else if card1 > card2 {
      firstWon = true
    }

    if firstWon {
      p1.put(card1, card2)
    } else {
      p2.put(card2, card1)
    }
  }

  return (p1.score(), p2.score())
}

let input = try String(contentsOfFile: "./input.txt", encoding: .utf8)
let decks = input.components(separatedBy: "\n\n").map(parseDeck)
var (player1, player2) = (decks[0], decks[1])

print(playRecursiveCombat(&player1, &player2))
