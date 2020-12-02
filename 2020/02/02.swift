import Foundation

struct Policy {
  let first: Int
  let second: Int
  let letter: Character
}

func parseInput(i: String) -> (Policy, String) {
  let parts = i.components(separatedBy: ": ")
  let password = parts[1]
  let policyParts = parts[0].components(separatedBy: " ")
  let letter = policyParts[1].first!
  let rangeParts = policyParts[0].components(separatedBy: "-")
  let policy = Policy(
    first: Int(rangeParts[0])!,
    second: Int(rangeParts[1])!,
    letter: letter
  )
  return (policy, password)
}

func passwordIsValid(policy: Policy, pwd: String) -> Bool {
  let first = pwd[pwd.index(pwd.startIndex, offsetBy: policy.first - 1)]
  let second = pwd[pwd.index(pwd.startIndex, offsetBy: policy.second - 1)]
  return (first == policy.letter && second != policy.letter)
    || (first != policy.letter && second == policy.letter)
}

let inputs = (try String(contentsOfFile: "./input.txt", encoding: .utf8))
  .components(separatedBy: "\n")
  .map(parseInput)

let validPasswords = inputs.filter(passwordIsValid).count
print(validPasswords)
