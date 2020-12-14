import Foundation

func power(_ a: Int, _ b: Int) -> Int {
  return Int(truncating: NSDecimalNumber(decimal: pow(Decimal(a), b)))
}

struct Mask {
  let mask: String

  init(_ mask: String) { self.mask = mask }

  func addresses(_ n: UInt64) -> [UInt64] {
    let n = UInt64(mask.replacingOccurrences(of: "X", with: "0"), radix: 2)! | n
    let xs = mask.enumerated().filter { $0.1 == Character("X") }.map { $0.0 }
    let numAddresses = power(2, xs.count)
    var addrs: [UInt64] = []

    for i in 0..<numAddresses {
      var num = n
      for (j, idx) in xs.enumerated() {
        if (i / (numAddresses / power(2, j + 1))) % 2 == 0 {
          num &= ~(1 << (36 - idx - 1))
        } else {
          num |= 1 << (36 - idx - 1)
        }
      }
      addrs.append(num)
    }

    return addrs
  }
}

enum Instruction {
  case mask(Mask)
  case setValue(UInt64, UInt64)
}

func parseInstruction(s: String) -> Instruction {
  if s.hasPrefix("mask = ") {
    return .mask(Mask(String(s.dropFirst(7))))
  }

  let parts = s.dropFirst(4).components(separatedBy: "] = ")
  return .setValue(UInt64(parts[0])!, UInt64(parts[1])!)
}

func run(_ instructions: [Instruction]) -> [UInt64: UInt64] {
  var mask: Mask? = nil
  var memory = [UInt64: UInt64]()

  for i in instructions {
    switch i {
    case .mask(let m):
      mask = m
    case .setValue(let idx, let v):
      for i in mask!.addresses(idx) {
        memory.updateValue(v, forKey: i)
      }
    }
  }

  return memory
}

let instructions = try String(contentsOfFile: "./input.txt", encoding: .utf8)
  .components(separatedBy: "\n")
  .map(parseInstruction)

let memory = run(instructions)
print(memory.values.reduce(0) { $0 + $1 })
