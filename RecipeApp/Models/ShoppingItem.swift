import Foundation
import FirebaseFirestoreSwift

struct ShoppingItem: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var quantity: String
    var isChecked: Bool
    var department: String?
    
    init(id: String? = nil,
         name: String,
         quantity: String,
         isChecked: Bool = false,
         department: String? = nil) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.isChecked = isChecked
        self.department = department
    }
}

// MARK: - Equatable
extension ShoppingItem: Equatable {
    static func == (lhs: ShoppingItem, rhs: ShoppingItem) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Hashable
extension ShoppingItem: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Department Categories
extension ShoppingItem {
    static let departments = [
        "Produce",
        "Meat & Seafood",
        "Dairy & Eggs",
        "Bakery",
        "Pantry",
        "Frozen Foods",
        "Beverages",
        "Condiments",
        "Snacks",
        "Other"
    ]
    
    static func suggestDepartment(for itemName: String) -> String {
        let lowercasedName = itemName.lowercased()
        
        // Produce
        if lowercasedName.contains("fruit") ||
           lowercasedName.contains("vegetable") ||
           lowercasedName.contains("lettuce") ||
           lowercasedName.contains("tomato") ||
           lowercasedName.contains("onion") {
            return "Produce"
        }
        
        // Meat & Seafood
        if lowercasedName.contains("meat") ||
           lowercasedName.contains("chicken") ||
           lowercasedName.contains("beef") ||
           lowercasedName.contains("fish") ||
           lowercasedName.contains("seafood") {
            return "Meat & Seafood"
        }
        
        // Dairy & Eggs
        if lowercasedName.contains("milk") ||
           lowercasedName.contains("cheese") ||
           lowercasedName.contains("yogurt") ||
           lowercasedName.contains("egg") ||
           lowercasedName.contains("butter") {
            return "Dairy & Eggs"
        }
        
        // Bakery
        if lowercasedName.contains("bread") ||
           lowercasedName.contains("roll") ||
           lowercasedName.contains("bun") ||
           lowercasedName.contains("pastry") {
            return "Bakery"
        }
        
        // Pantry
        if lowercasedName.contains("flour") ||
           lowercasedName.contains("sugar") ||
           lowercasedName.contains("rice") ||
           lowercasedName.contains("pasta") ||
           lowercasedName.contains("can") {
            return "Pantry"
        }
        
        // Frozen Foods
        if lowercasedName.contains("frozen") ||
           lowercasedName.contains("ice cream") {
            return "Frozen Foods"
        }
        
        // Beverages
        if lowercasedName.contains("drink") ||
           lowercasedName.contains("juice") ||
           lowercasedName.contains("soda") ||
           lowercasedName.contains("water") {
            return "Beverages"
        }
        
        // Condiments
        if lowercasedName.contains("sauce") ||
           lowercasedName.contains("dressing") ||
           lowercasedName.contains("oil") ||
           lowercasedName.contains("vinegar") ||
           lowercasedName.contains("spice") {
            return "Condiments"
        }
        
        // Snacks
        if lowercasedName.contains("chip") ||
           lowercasedName.contains("cookie") ||
           lowercasedName.contains("snack") ||
           lowercasedName.contains("nut") {
            return "Snacks"
        }
        
        return "Other"
    }
}
