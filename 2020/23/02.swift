import Foundation

struct Circle {
  var cups = [UInt64: UInt64]()
  var currentCup: UInt64
  let max: UInt64

  init(_ cups: [UInt64]) {
    self.cups.reserveCapacity(cups.count)
    self.cups.updateValue(cups.first!, forKey: cups.last!)
    for (i, cup) in cups.dropLast().enumerated() {
      self.cups.updateValue(cups[i + 1], forKey: cup)
    }
    max = self.cups.keys.max()!
    currentCup = cups.first!
  }

  mutating func pickNextCups(_ n: UInt64, from: UInt64) -> [UInt64] {
    var selected = [UInt64]()
    var current = from
    for _ in 1...n {
      selected.append(cups[current]!)
      current = selected.last!
    }
    return selected
  }

  func destinationCup(_ excluded: [UInt64]) -> UInt64 {
    var target = currentCup - 1
    while true {
      if target < 1 {
        target = max
      }

      if !excluded.contains(target) {
        return target
      }
      target -= 1
    }
  }

  mutating func insertPickedCups(_ cups: [UInt64], after: UInt64) {
    let prev = self.cups[after]!
    self.cups.updateValue(self.cups[cups.last!]!, forKey: currentCup)
    self.cups.updateValue(cups.first!, forKey: after)
    self.cups.updateValue(prev, forKey: cups.last!)
  }

  mutating func selectNewCurrentCup() {
    currentCup = cups[currentCup]!
  }

  mutating func move() {
    let nextCups = pickNextCups(3, from: currentCup)
    let destination = destinationCup(nextCups)
    insertPickedCups(nextCups, after: destination)
    selectNewCurrentCup()
  }
}

let input: [UInt64] = "614752839".map { UInt64(String($0))! }

var circle = Circle(input + ((input.max()! + 1)...1_000_000))

for _ in 1...10_000_000 {
  circle.move()
}

print(circle.pickNextCups(2, from: 1).reduce(1) { $0 * $1 })
