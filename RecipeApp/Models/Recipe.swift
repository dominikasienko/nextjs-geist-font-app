import Foundation

struct Recipe: Identifiable, Codable {
    var id = UUID()
    var name: String
    var category: String
    var photoData: Data? // Store image data
    var description: String
    var ingredients: [Ingredient]
    var instructions: [String]
    var nutritionalInfo: NutritionalInfo?
}
