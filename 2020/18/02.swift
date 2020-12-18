import Foundation

indirect enum Expression {
  case sum(Expression, Expression)
  case product(Expression, Expression)
  case literal(Int)

  func eval() -> Int {
    switch self {
    case .sum(let left, let right): return left.eval() + right.eval()
    case .product(let left, let right): return left.eval() * right.eval()
    case .literal(let n): return n
    }
  }
}

enum ParseError: Error {
  case invalidCharacter(Character)
  case invalidToken(Token)
  case expectingToken(Token)
}

enum Token {
  case lparen
  case rparen
  case asterisk
  case plus
  case number(Int)

  func precedence() -> Int {
    switch self {
    case .lparen: return 3
    case .plus: return 2
    case .asterisk: return 1
    case .number, .rparen: return 0
    }
  }
}

struct TokenIterator {
  let tokens: [Token]
  var idx = 0

  mutating func next() -> Token? {
    if idx >= tokens.count {
      return nil
    }
    idx += 1
    return tokens[idx - 1]
  }

  func peek() -> Token? {
    if idx >= tokens.count {
      return nil
    }
    return tokens[idx]
  }
}

func charAt(_ s: String, _ idx: Int) -> Character {
  return s[s.index(s.startIndex, offsetBy: idx)]
}

let number = Character("0")...Character("9")

func tokenize(_ input: String) throws -> TokenIterator {
  var result = [Token]()
  var idx = 0

  while idx < input.count {
    let ch = charAt(input, idx)
    idx += 1

    switch ch {
    case Character("("):
      result.append(.lparen)
    case Character(")"):
      result.append(.rparen)
    case Character("+"):
      result.append(.plus)
    case Character("*"):
      result.append(.asterisk)
    case number:
      let startIdx = input.index(input.startIndex, offsetBy: idx - 1)
      while idx < input.count && number.contains(charAt(input, idx)) {
        idx += 1
      }
      let endIdx = input.index(input.startIndex, offsetBy: idx)
      result.append(.number(Int(input[startIdx..<endIdx])!))
    case Character(" "): continue
    default:
      throw ParseError.invalidCharacter(ch)
    }
  }

  return TokenIterator(tokens: result, idx: 0)
}

func parse(_ tokens: inout TokenIterator, precedence: Int = 0) throws -> Expression {
  var left: Expression
  switch tokens.next() {
  case .lparen:
    left = try parse(&tokens)
    guard case .rparen = tokens.next() else {
      throw ParseError.expectingToken(.rparen)
    }
  case .number(let n):
    left = .literal(n)
  case let token:
    throw ParseError.invalidToken(token!)
  }

  while precedence < tokens.peek()?.precedence() ?? 0 {
    switch tokens.next() {
    case .plus:
      let right = try parse(&tokens, precedence: Token.plus.precedence())
      left = .sum(left, right)
    case .asterisk:
      let right = try parse(&tokens, precedence: Token.asterisk.precedence())
      left = .product(left, right)
    case let token: throw ParseError.invalidToken(token!)
    }
  }

  return left
}

func eval(_ s: String) throws -> Int {
    var tokens = try tokenize(s)
    return (try parse(&tokens)).eval()
}

let input = try String(contentsOfFile: "./input.txt", encoding: .utf8)
  .components(separatedBy: "\n")

let result = try input.map(eval).reduce(0) { $0 + $1 }
print(result)
