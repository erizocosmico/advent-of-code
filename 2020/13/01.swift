import Foundation

func nextBusDeparture(_ buses: [Int], since: Int) -> (Int, Int) {
  let nextDepartures: [(Int, Int)] = buses.map { b in
    if since % b == 0 {
      return (b, since)
    } else {
      return (b, (since / b + 1) * b)
    }
  }
  return nextDepartures.min { $0.1 < $1.1 }!
}

let input = try String(contentsOfFile: "./input.txt", encoding: .utf8)
  .components(separatedBy: "\n")

let timestamp = Int(input.first!)!
let buses = input.last!
  .components(separatedBy: ",")
  .filter { $0 != "x" }
  .map { Int($0)! }

let (bus, nextDeparture) = nextBusDeparture(buses, since: timestamp)
print((nextDeparture - timestamp) * bus)
