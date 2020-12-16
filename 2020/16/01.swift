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

let input = try String(contentsOfFile: "./input.txt", encoding: .utf8)
let parts = input.components(separatedBy: "\n\n")

let rules = parseRules(parts[0])
let tickets = parseTickets(parts[2])

let errorRate = tickets.flatMap { invalidFields(ticket: $0, rules: rules) }
  .reduce(0) { $0 + $1 }
print(errorRate)
