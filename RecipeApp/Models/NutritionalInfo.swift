import Foundation

struct NutritionalInfo: Codable, Identifiable {
    let id: String
    var calories: Double
    var protein: Double
    var carbs: Double
    var fat: Double
    var fiber: Double
    
    init(id: String = UUID().uuidString,
         calories: Double,
         protein: Double,
         carbs: Double,
         fat: Double,
         fiber: Double) {
        self.id = id
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.fiber = fiber
    }
}
