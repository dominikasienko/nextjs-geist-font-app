import Foundation
import FirebaseFirestoreSwift

struct Ingredient: Identifiable, Codable {
    var id: String
    var name: String
    var quantity: String
    var nutritionInfo: NutritionalInfo?
    
    init(id: String = UUID().uuidString,
         name: String,
         quantity: String,
         nutritionInfo: NutritionalInfo? = nil) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.nutritionInfo = nutritionInfo
    }
}

// MARK: - Equatable
extension Ingredient: Equatable {
    static func == (lhs: Ingredient, rhs: Ingredient) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Hashable
extension Ingredient: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Common Units
extension Ingredient {
    static let commonUnits = [
        "cup",
        "tablespoon",
        "teaspoon",
        "ounce",
        "pound",
        "gram",
        "kilogram",
        "milliliter",
        "liter",
        "piece",
        "slice",
        "pinch",
        "to taste"
    ]
    
    static let unitAbbreviations = [
        "cup": "c",
        "tablespoon": "tbsp",
        "teaspoon": "tsp",
        "ounce": "oz",
        "pound": "lb",
        "gram": "g",
        "kilogram": "kg",
        "milliliter": "ml",
        "liter": "L"
    ]
    
    func formattedQuantity() -> String {
        let components = quantity.components(separatedBy: .whitespaces)
        guard components.count >= 2 else { return quantity }
        
        let amount = components[0]
        let unit = components[1]
        
        if let abbreviation = Ingredient.unitAbbreviations[unit.lowercased()] {
            return "\(amount) \(abbreviation)"
        }
        
        return quantity
    }
}

// MARK: - Sample Data
extension Ingredient {
    static var sampleData: [Ingredient] {
        [
            Ingredient(name: "All-purpose flour", quantity: "2 cups"),
            Ingredient(name: "Sugar", quantity: "1 cup"),
            Ingredient(name: "Eggs", quantity: "2 large"),
            Ingredient(name: "Milk", quantity: "1 cup"),
            Ingredient(name: "Butter", quantity: "1/2 cup")
        ]
    }
}
