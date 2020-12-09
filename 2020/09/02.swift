import Foundation

let numbers = try String(contentsOfFile: "./input.txt", encoding: .utf8)
  .components(separatedBy: "\n")
  .map { s in Int(s)! }

func firstInvalidNumber(_ seq: [Int], preamble: Int) -> Int? {
  for i in preamble...(seq.count - 1) {
    if isInvalidNumber(seq[i], preamble: seq[(i - preamble)...(i - 1)].sorted()) {
      return seq[i]
    }
  }
  return nil
}

func isInvalidNumber(_ n: Int, preamble: [Int]) -> Bool {
  if n < preamble.first! || n >= preamble.last! * 2 {
    return true
  }

  for a in preamble {
    for b in preamble.reversed() {
      if a != b && a + b == n {
        return false
      }
    }
  }

  return true
}

func findWeakness(_ seq: [Int], invalidNumber: Int) -> Int? {
  var first = 0
  var sum = 0
  var len = 0

  for i in 0..<seq.count {
    let n = seq[i]

    if n == invalidNumber {
      first = i + 1
      sum = 0
      len = 0
      continue
    }

    sum += n
    len += 1

    while sum > invalidNumber {
      sum -= seq[first]
      len -= 1
      first += 1
    }

    if len >= 2 && sum == invalidNumber {
      let nums = seq[first...i]
      return nums.min()! + nums.max()!
    }
  }

  return nil
}

print(findWeakness(numbers, invalidNumber: firstInvalidNumber(numbers, preamble: 25)!)!)
