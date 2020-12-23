import Foundation

struct Circle {
  var cups = [Int: Int]()
  var currentCup: Int
  let max: Int

  init(_ cups: [Int]) {
    self.cups.updateValue(cups.first!, forKey: cups.last!)
    for (i, cup) in cups.dropLast().enumerated() {
      self.cups.updateValue(cups[i + 1], forKey: cup)
    }
    max = self.cups.keys.max()!
    currentCup = cups.first!
  }

  mutating func pickNextCups(_ n: Int, from: Int) -> [Int] {
    var selected = [Int]()
    var current = from
    for _ in 1...n {
      selected.append(cups[current]!)
      current = selected.last!
    }
    return selected
  }

  func destinationCup(_ excluded: [Int]) -> Int {
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

  mutating func insertPickedCups(_ cups: [Int], after: Int) {
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

  func labels() -> [Int] {
    var labels = [Int]()
    var next = cups[1]!
    while next != 1 {
      labels.append(next)
      next = cups[next]!
    }

    return labels
  }
}

let input: [Int] = "614752839".map { Int(String($0))! }

var circle = Circle(input)

for _ in 1...100 {
  circle.move()
}

print(circle.labels().map { String($0) }.reduce("") { $0 + $1 })
