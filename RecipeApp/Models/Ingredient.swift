import Foundation

struct Ingredient: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var quantity: String
}
