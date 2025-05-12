import Foundation

struct MealPlan: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var recipes: [Recipe]
}
