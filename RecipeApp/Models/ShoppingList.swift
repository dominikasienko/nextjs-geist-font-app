import Foundation

struct ShoppingList: Identifiable, Codable {
    var id = UUID()
    var items: [ShoppingItem]
}
