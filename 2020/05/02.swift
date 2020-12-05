import Foundation

func findSeat(pass: String) -> Int {
  let row = findAxisPosition(String(pass.prefix(7)), max: 127)
  let col = findAxisPosition(String(pass.suffix(3)), max: 7)
  return row * 8 + col
}

func findAxisPosition(_ directions: String, max: Int) -> Int {
  var (lower, upper) = (0, max)
  for d in directions {
    if "FL".contains(d) {
      upper = lower + (upper - lower) / 2
    } else {
      lower = lower + (upper - lower) / 2 + 1
    }
  }

  return lower
}

func findMissingSeat(_ seats: [Int]) -> Int {
  var prev = 0
  for seat in seats {
    if prev > 0 && seat - prev > 1 {
      return prev + 1
    }
    prev = seat
  }
  return 0
}

let seats = (try String(contentsOfFile: "./input.txt", encoding: .utf8))
  .components(separatedBy: "\n")
  .map(findSeat)
  .sorted()

print(findMissingSeat(seats))
