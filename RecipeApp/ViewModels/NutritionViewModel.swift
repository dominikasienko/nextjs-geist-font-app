import Foundation
import Combine

class NutritionViewModel: ObservableObject {
    @Published var dailyCalorieLimit: Double = 2000
    @Published var consumedCalories: Double = 0
    @Published var userSex: String = "male" // default
    @Published var dietPreference: String = "none" // default

    func updateConsumedCalories(for mealPlans: [MealPlan]) {
        consumedCalories = mealPlans.reduce(0) { total, mealPlan in
            total + mealPlan.recipes.reduce(0) { $0 + adjustedCalories(for: $1) }
        }
    }

    private func adjustedCalories(for recipe: Recipe) -> Double {
        guard let baseCalories = recipe.nutritionalInfo?.calories else { return 0 }
        var adjusted = baseCalories

        // Adjust calories based on diet preference
        switch dietPreference.lowercased() {
        case "vegan":
            adjusted *= 0.95
        case "keto":
            adjusted *= 1.05
        default:
            break
        }

        // Adjust calories based on sex
        if userSex.lowercased() == "female" {
            adjusted *= 0.9
        }

        return adjusted
    }

    func isWithinCalorieLimit() -> Bool {
        consumedCalories <= dailyCalorieLimit
    }
}
