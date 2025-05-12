import Foundation
import Combine

class PantryViewModel: ObservableObject {
    @Published var pantry: Pantry = Pantry(ingredients: [])
    @Published var filteredRecipes: [Recipe] = []

    func addIngredient(_ ingredient: Ingredient) {
        pantry.ingredients.append(ingredient)
        // Save to persistence
    }

    func removeIngredient(at offsets: IndexSet) {
        pantry.ingredients.remove(atOffsets: offsets)
        // Save to persistence
    }

    func filterRecipes(recipes: [Recipe], mealType: String? = nil) {
        filteredRecipes = recipes.filter { recipe in
            let hasAllIngredients = recipe.ingredients.allSatisfy { recipeIngredient in
                pantry.ingredients.contains(where: { $0.name.lowercased() == recipeIngredient.name.lowercased() })
            }
            if let mealType = mealType, !mealType.isEmpty {
                return hasAllIngredients && recipe.category.lowercased() == mealType.lowercased()
            }
            return hasAllIngredients
        }
    }
}
