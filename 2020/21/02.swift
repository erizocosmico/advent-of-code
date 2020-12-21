import Foundation

typealias Food = (ingredients: [String], allergens: [String])

func parseInput(_ input: String) -> [Food] {
  return input.components(separatedBy: "\n").map { line in
    let parts = line.components(separatedBy: " (contains ")
    let ingredients = parts[0].components(separatedBy: " ")
    let allergens = parts[1].dropLast().components(separatedBy: ", ")
    return (ingredients, allergens)
  }
}

func findAllergenIngredients(_ foods: [Food]) -> [String: String] {
  var candidates = [String: Set<String>]()
  var allergens = Set<String>()

  for food in foods {
    for allergen in food.allergens {
      allergens.update(with: allergen)
      if candidates.keys.contains(allergen) {
        candidates.updateValue(
          candidates[allergen]!.intersection(food.ingredients),
          forKey: allergen
        )
      } else {
        candidates.updateValue(Set<String>(food.ingredients), forKey: allergen)
      }
    }
  }

  var allergenIngredients = [String: String]()
  while allergenIngredients.count != allergens.count {
    for (allergen, ingredients) in candidates {
      let ingredients = ingredients.subtracting(allergenIngredients.values)
      if ingredients.count == 1 {
        candidates.removeValue(forKey: allergen)
        allergenIngredients.updateValue(ingredients.first!, forKey: allergen)
      } else {
        candidates.updateValue(ingredients, forKey: allergen)
      }
    }
  }

  return allergenIngredients
}

let foods = parseInput(try String(contentsOfFile: "./input.txt", encoding: .utf8))
let allergenIngredients = findAllergenIngredients(foods)

let canonicalDangerousIngredientList = allergenIngredients.sorted { $0.key < $1.key }
  .map { $0.value }
  .joined(separator: ",")
print(canonicalDangerousIngredientList)
