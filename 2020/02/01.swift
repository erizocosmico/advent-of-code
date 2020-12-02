import Foundation

struct Policy {
  let min: Int
  let max: Int
  let letter: String
}

func parseInput(i: String) -> (Policy, String) {
  let parts = i.components(separatedBy: ": ")
  let password = parts[1]
  let policyParts = parts[0].components(separatedBy: " ")
  let letter = policyParts[1]
  let rangeParts = policyParts[0].components(separatedBy: "-")
  let policy = Policy(min: Int(rangeParts[0])!, max: Int(rangeParts[1])!, letter: letter)
  return (policy, password)
}

func passwordIsValid(policy: Policy, pwd: String) -> Bool {
  let occurrences = pwd.components(separatedBy: policy.letter).count - 1
  return (policy.min...policy.max).contains(occurrences)
}

let inputs = (try String(contentsOfFile: "./input.txt", encoding: .utf8))
  .components(separatedBy: "\n")
  .map(parseInput)

let validPasswords = inputs.filter(passwordIsValid).count
print(validPasswords)
