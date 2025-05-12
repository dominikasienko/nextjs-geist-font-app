import Foundation
import FirebaseFirestoreSwift

struct MealPlan: Identifiable, Codable {
    @DocumentID var id: String?
    let recipeId: String
    let recipeName: String
    let date: Date
    let mealType: MealType
    var notes: String?
    
    enum MealType: String, Codable, CaseIterable {
        case breakfast = "Breakfast"
        case lunch = "Lunch"
        case dinner = "Dinner"
        case snack = "Snack"
    }
    
    init(id: String? = nil,
         recipeId: String,
         recipeName: String,
         date: Date,
         mealType: MealType = .dinner,
         notes: String? = nil) {
        self.id = id
        self.recipeId = recipeId
        self.recipeName = recipeName
        self.date = date
        self.mealType = mealType
        self.notes = notes
    }
}

// MARK: - Equatable
extension MealPlan: Equatable {
    static func == (lhs: MealPlan, rhs: MealPlan) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Hashable
extension MealPlan: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Helper Methods
extension MealPlan {
    static func groupByDate(_ mealPlans: [MealPlan]) -> [Date: [MealPlan]] {
        let calendar = Calendar.current
        return Dictionary(grouping: mealPlans) { mealPlan in
            calendar.startOfDay(for: mealPlan.date)
        }
    }
    
    static func sortByMealType(_ mealPlans: [MealPlan]) -> [MealPlan] {
        mealPlans.sorted { plan1, plan2 in
            let typeOrder = [
                MealType.breakfast,
                MealType.lunch,
                MealType.dinner,
                MealType.snack
            ]
            
            let index1 = typeOrder.firstIndex(of: plan1.mealType) ?? 0
            let index2 = typeOrder.firstIndex(of: plan2.mealType) ?? 0
            
            return index1 < index2
        }
    }
}

// MARK: - Sample Data
extension MealPlan {
    static var sampleData: [MealPlan] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return [
            MealPlan(
                recipeId: "1",
                recipeName: "Classic Pancakes",
                date: today,
                mealType: .breakfast
            ),
            MealPlan(
                recipeId: "2",
                recipeName: "Garden Salad",
                date: today,
                mealType: .lunch
            ),
            MealPlan(
                recipeId: "3",
                recipeName: "Grilled Chicken",
                date: calendar.date(byAdding: .day, value: 1, to: today)!,
                mealType: .dinner
            )
        ]
    }
}
