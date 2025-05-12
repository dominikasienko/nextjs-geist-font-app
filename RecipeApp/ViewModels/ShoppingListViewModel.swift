import Foundation
import Combine

class ShoppingListViewModel: ObservableObject {
    @Published var shoppingList: ShoppingList = ShoppingList(items: [])

    func addItem(_ item: ShoppingItem) {
        shoppingList.items.append(item)
        // Save to persistence
    }

    func updateItem(_ item: ShoppingItem) {
        if let index = shoppingList.items.firstIndex(where: { $0.id == item.id }) {
            shoppingList.items[index] = item
            // Save to persistence
        }
    }

    func removeItem(at offsets: IndexSet) {
        shoppingList.items.remove(atOffsets: offsets)
        // Save to persistence
    }

    func toggleItemSelection(_ item: ShoppingItem) {
        if let index = shoppingList.items.firstIndex(where: { $0.id == item.id }) {
            shoppingList.items[index].isSelected.toggle()
            // Save to persistence
        }
    }

    func groupedItems() -> [String: [ShoppingItem]] {
        Dictionary(grouping: shoppingList.items, by: { $0.department })
    }
}
