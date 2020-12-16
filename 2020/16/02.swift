import Foundation

typealias Ticket = [Int]
typealias Constraint = ClosedRange<Int>
typealias Rules = [String: [Constraint]]

func parseConstraint(_ c: String) -> Constraint {
  let parts = c.components(separatedBy: "-")
  return (Int(parts[0])!)...(Int(parts[1])!)
}

func parseRule(_ line: String) -> (String, [Constraint]) {
  let parts = line.components(separatedBy: ": ")
  let (key, constraints) = (parts[0], parts[1])
  return (key, constraints.components(separatedBy: " or ").map(parseConstraint))
}

func parseRules(_ input: String) -> Rules {
  let pairs = input.components(separatedBy: "\n").map(parseRule)
  return Rules(uniqueKeysWithValues: pairs)
}

func parseTickets(_ input: String) -> [Ticket] {
  return input.components(separatedBy: "\n")
    .dropFirst()
    .map { $0.components(separatedBy: ",").map { Int($0)! } }
}

func invalidFields(ticket: Ticket, rules: Rules) -> [Int] {
  return ticket.filter { field in
    for rule in rules.values {
      for constraint in rule {
        if constraint.contains(field) {
          return false
        }
      }
    }
    return true
  }
}

func matchesRule(_ f: Int, _ constraints: [Constraint]) -> Bool {
  for c in constraints {
    if c.contains(f) {
      return true
    }
  }
  return false
}

func guessFields(rules: Rules, tickets: [Ticket]) -> [String] {
  var validRules = [Int: [String]]()

  // Find all valid rules for each position.
  for i in 0..<tickets.first!.count {
    var colValidRules = [String]()
    for (rule, constraints) in rules {
      let ok = tickets.first { !matchesRule($0[i], constraints) } == nil
      if ok {
        colValidRules.append(rule)
      }
    }
    validRules.updateValue(colValidRules, forKey: i)
  }

  // Determine which of the possible candidates is the one.
  var fields = [String](repeatElement("", count: tickets.first!.count))
  while validRules.count > 0 {
    // If only one rule is valid, it's assigned to the field.
    for (i, rules) in validRules {
      if rules.count == 1 {
        fields[i] = rules.first!
        validRules.removeValue(forKey: i)
      }
    }

    // Remove from the other candidates the ones we've already
    // determined.
    for (i, rules) in validRules {
      validRules.updateValue(rules.filter { !fields.contains($0)}, forKey: i)
    }
  }

  return fields
}

let input = try String(contentsOfFile: "./input.txt", encoding: .utf8)
let parts = input.components(separatedBy: "\n\n")

let rules = parseRules(parts[0])
let tickets = parseTickets(parts[2])
let myTicket = parseTickets(parts[1]).first!

let validTickets = tickets.filter { invalidFields(ticket: $0, rules: rules).isEmpty }
let fields = guessFields(rules: rules, tickets: validTickets)

let result = fields.enumerated()
  .filter { _, f in f.hasPrefix("departure") }
  .map { i, _ in UInt64(myTicket[i]) }
  .reduce(1) { $0 * $1 }

print(result)
