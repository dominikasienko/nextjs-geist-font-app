import Foundation

struct Pantry: Identifiable, Codable {
    var id = UUID()
    var ingredients: [Ingredient]
}
