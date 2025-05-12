import Foundation
import Combine

class MealPlanViewModel: ObservableObject {
    @Published var mealPlans: [MealPlan] = []

    func addMealPlan(_ mealPlan: MealPlan) {
        mealPlans.append(mealPlan)
        // Save to persistence
    }

    func updateMealPlan(_ mealPlan: MealPlan) {
        if let index = mealPlans.firstIndex(where: { $0.id == mealPlan.id }) {
            mealPlans[index] = mealPlan
            // Save to persistence
        }
    }

    func deleteMealPlan(at offsets: IndexSet) {
        mealPlans.remove(atOffsets: offsets)
        // Save to persistence
    }

    func addRecipe(_ recipe: Recipe, to date: Date) {
        if let index = mealPlans.firstIndex(where: { Calendar.current.isDate(mealPlans[index].date, inSameDayAs: date) }) {
            mealPlans[index].recipes.append(recipe)
        } else {
            let newMealPlan = MealPlan(date: date, recipes: [recipe])
            mealPlans.append(newMealPlan)
        }
        // Save to persistence
    }
}
