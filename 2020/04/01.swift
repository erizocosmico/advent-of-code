import Foundation

func parsePassport(_ p: String) -> [String: String] {
  return [String: String](
    uniqueKeysWithValues: p.components(separatedBy: "\n")
      .flatMap { s in s.components(separatedBy: " ") }
      .map { s in
        let kv = s.components(separatedBy: ":")
        return (kv[0], kv[1])
      })
}

let requiredFields = ["byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"]

func isValid(passport: [String: String]) -> Bool {
  return requiredFields.allSatisfy { f in passport[f] != nil }
}

let passports = (try String(contentsOfFile: "./input.txt", encoding: .utf8))
  .components(separatedBy: "\n\n")
  .map(parsePassport)

print(passports.filter(isValid).count)
