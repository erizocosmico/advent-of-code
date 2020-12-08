import Foundation

struct Instruction {
  let op: String
  let arg: Int

  init(_ s: String) {
    let parts = s.components(separatedBy: " ")
    self.op = parts[0]
    self.arg = Int(parts[1].replacingOccurrences(of: "+", with: ""))!
  }
}

enum InstructionError: Error {
  case InvalidOp
}

func run(_ instructions: [Instruction]) throws -> Int {
  var acc = 0
  var ptr = 0
  var seen: Set<Int> = Set()

  while ptr < instructions.count {
    if seen.contains(ptr) {
      break
    }

    let i = instructions[ptr]
    seen.update(with: ptr)
    switch i.op {
    case "acc":
      acc += i.arg
      ptr += 1
    case "jmp":
      ptr += i.arg
    case "nop":
      ptr += 1
    default:
      throw InstructionError.InvalidOp
    }
  }

  return acc
}

let instructions = try String(contentsOfFile: "./input.txt", encoding: .utf8)
  .components(separatedBy: "\n")
  .map { s in Instruction(s) }

print(try run(instructions))
