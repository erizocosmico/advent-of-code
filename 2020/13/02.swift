import Foundation

let input: [(Int64, Int64)] = try String(contentsOfFile: "./input.txt", encoding: .utf8)
  .components(separatedBy: "\n")
  .last!
  .components(separatedBy: ",")
  .enumerated()
  .filter { _, n in n != "x" }
  .map { i, n in (Int64(i), Int64(n)!) }

let (offsets, ids) = (input.map { $0.0 }, input.map { $0.1 })

print(solve(ids, offsets))

// Find the first time at which each bus departs at its offset
// relative to the first bus using the chinese remainder theorem.
func solve(_ ids: [Int64], _ offsets: [Int64]) -> Int64 {
    let prod = ids.reduce(1) { $0 * $1 }
    var (p, sum) = (Int64(0), Int64(0))

    for i in 0..<ids.count {
        p = prod / ids[i]
        sum += offsets[i] * mulInv(p, ids[i]) * p
    }

    return prod - sum % prod
}

func mulInv(_ a: Int64, _ b: Int64) -> Int64 {
    var (a, b, b0) = (a, b, b)
    var (x0, x1) = (Int64(0), Int64(1))

    if b == 1 {
        return 1
    }

    while a > 1 {
        let q = a / b
        (a, b) = (b, a % b)
        (x0, x1) = (x1 - q * x0, x0)
    }

    if x1 < 0 {
        x1 += b0
    }

    return x1
}