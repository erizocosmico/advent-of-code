import Foundation

struct Deck {
  private var cards: [Int]

  init(_ initialCards: [Int]) {
    cards = initialCards
  }

  func hasCards() -> Bool { return !cards.isEmpty }

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

func playCombat(_ p1: inout Deck, _ p2: inout Deck) -> Int {
  while p1.hasCards() && p2.hasCards() {
    let (card1, card2) = (p1.draw(), p2.draw())
    if card1 > card2 {
      p1.put(card1, card2)
    } else {
      p2.put(card2, card1)
    }
  }

  return p1.hasCards() ? p1.score() : p2.score()
}

let input = try String(contentsOfFile: "./input.txt", encoding: .utf8)
let decks = input.components(separatedBy: "\n\n").map(parseDeck)
var (player1, player2) = (decks[0], decks[1])

print(playCombat(&player1, &player2))
