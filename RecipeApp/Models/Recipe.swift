import Foundation
import FirebaseFirestoreSwift

struct Recipe: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var category: String
    var description: String
    var ingredients: [Ingredient]
    var instructions: [String]
    var photoURL: String?
    var isFavorite: Bool
    var nutritionInfo: NutritionalInfo?
    var createdAt: Date
    var updatedAt: Date
    
    static let categories = [
        "Main Course",
        "Appetizer",
        "Soup",
        "Salad",
        "Side Dish",
        "Dessert",
        "Breakfast",
        "Snack",
        "Beverage"
    ]
    
    init(id: String? = nil,
         name: String,
         category: String,
         description: String,
         ingredients: [Ingredient],
         instructions: [String],
         photoURL: String? = nil,
         isFavorite: Bool = false,
         nutritionInfo: NutritionalInfo? = nil,
         createdAt: Date = Date(),
         updatedAt: Date = Date()) {
        self.id = id
        self.name = name
        self.category = category
        self.description = description
        self.ingredients = ingredients
        self.instructions = instructions
        self.photoURL = photoURL
        self.isFavorite = isFavorite
        self.nutritionInfo = nutritionInfo
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Equatable
extension Recipe: Equatable {
    static func == (lhs: Recipe, rhs: Recipe) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Hashable
extension Recipe: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Sample Data
extension Recipe {
    static var sampleData: [Recipe] {
        [
            Recipe(
                name: "Classic Pancakes",
                category: "Breakfast",
                description: "Fluffy and delicious pancakes perfect for breakfast",
                ingredients: [
                    Ingredient(name: "All-purpose flour", quantity: "1.5 cups"),
                    Ingredient(name: "Milk", quantity: "1.25 cups"),
                    Ingredient(name: "Eggs", quantity: "2 large"),
                    Ingredient(name: "Butter", quantity: "3 tbsp, melted")
                ],
                instructions: [
                    "Mix dry ingredients",
                    "Combine wet ingredients",
                    "Cook on griddle until golden brown"
                ]
            ),
            Recipe(
                name: "Garden Salad",
                category: "Salad",
                description: "Fresh and healthy garden salad",
                ingredients: [
                    Ingredient(name: "Mixed greens", quantity: "4 cups"),
                    Ingredient(name: "Cherry tomatoes", quantity: "1 cup"),
                    Ingredient(name: "Cucumber", quantity: "1, sliced"),
                    Ingredient(name: "Red onion", quantity: "1/2, sliced")
                ],
                instructions: [
                    "Wash and prepare vegetables",
                    "Combine in a large bowl",
                    "Toss with your favorite dressing"
                ]
            )
        ]
    }
}
