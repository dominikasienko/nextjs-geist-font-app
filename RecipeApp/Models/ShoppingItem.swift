import Foundation

struct ShoppingItem: Identifiable, Codable {
    var id = UUID()
    var name: String
    var quantity: String
    var department: String
    var isSelected: Bool = true
}
