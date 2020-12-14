import Foundation

struct Mask {
  let zeros: UInt64
  let ones: UInt64

  init(_ mask: String) {
    zeros = UInt64(mask.replacingOccurrences(of: "X", with: "1"), radix: 2)!
    ones = UInt64(mask.replacingOccurrences(of: "X", with: "0"), radix: 2)!
  }

  func apply(_ n: UInt64) -> UInt64 {
    return (n & zeros) | ones
  }
}

enum Instruction {
  case mask(Mask)
  case setValue(Int, UInt64)
}

func parseInstruction(s: String) -> Instruction {
  if s.hasPrefix("mask = ") {
    return .mask(Mask(String(s.dropFirst(7))))
  }

  let parts = s.dropFirst(4).components(separatedBy: "] = ")
  return .setValue(Int(parts[0])!, UInt64(parts[1])!)
}

func run(_ instructions: [Instruction]) -> [Int: UInt64] {
  var mask: Mask? = nil
  var memory = [Int: UInt64]()

  for i in instructions {
    switch i {
    case .mask(let m):
      mask = m
    case .setValue(let idx, let v):
      memory.updateValue(mask!.apply(v), forKey: idx)
    }
  }

  return memory
}

let instructions = try String(contentsOfFile: "./input.txt", encoding: .utf8)
  .components(separatedBy: "\n")
  .map(parseInstruction)

let memory = run(instructions)
print(memory.values.reduce(0) { $0 + $1 })
