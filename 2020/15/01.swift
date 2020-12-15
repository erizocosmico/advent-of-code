func play(_ startingNumbers: [Int], turns: Int) -> Int {
  var prevSeen = [Int: Int]()
  for (i, n) in startingNumbers.dropLast().enumerated() {
    prevSeen.updateValue(i, forKey: n)
  }

  var last = startingNumbers.last!

  for turn in startingNumbers.count..<turns {
    if let prev = prevSeen[last] {
      prevSeen.updateValue(turn - 1, forKey: last)
      last = turn - 1 - prev
    } else {
      prevSeen.updateValue(turn - 1, forKey: last)
      last = 0
    }
  }

  return last
}

let input = [6, 19, 0, 5, 7, 13, 1]

print("part 1:", play(input, turns: 2020))
print("part 2:", play(input, turns: 30_000_000))
