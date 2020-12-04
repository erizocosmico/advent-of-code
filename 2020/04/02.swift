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

func numberBetween(_ n: String, min: Int, max: Int) -> Bool {
  if let n = Int(n) {
    return (min...max).contains(n)
  }
  return false
}

func matches(_ value: String, pattern: String) -> Bool {
  return value.range(of: pattern, options: .regularExpression) != nil
}

let requiredFields = ["byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"]
let validEyeColors = ["amb", "blu", "brn", "gry", "grn", "hzl", "oth"]

func isFieldValid(key: String, value: String) -> Bool {
  switch key {
  case "byr": return numberBetween(value, min: 1920, max: 2002)
  case "iyr": return numberBetween(value, min: 2010, max: 2020)
  case "eyr": return numberBetween(value, min: 2020, max: 2030)
  case "hgt":
    if matches(value, pattern: #"^\d+(cm|in)"#) {
      let num = String(value.prefix(value.count - 2))
      if value.hasSuffix("cm") {
        return numberBetween(num, min: 150, max: 193)
      } else {
        return numberBetween(num, min: 59, max: 76)
      }
    }
  case "hcl": return matches(value, pattern: #"^#[a-f0-9]{6}$"#)
  case "ecl": return validEyeColors.contains(value)
  case "pid": return matches(value, pattern: #"^[0-9]{9}$"#)
  default: return true
  }
  return false
}

func isValid(passport: [String: String]) -> Bool {
  return requiredFields.allSatisfy { f in passport[f] != nil } && passport.allSatisfy(isFieldValid)
}

let passports = (try String(contentsOfFile: "./input.txt", encoding: .utf8))
  .components(separatedBy: "\n\n")
  .map(parsePassport)

print(passports.filter(isValid).count)
