import Foundation
import FirebaseFirestore
import FirebaseAuth

class ShoppingListViewModel: ObservableObject {
    @Published var shoppingItems: [ShoppingItem] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let db = Firestore.firestore()
    
    func fetchShoppingList() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        isLoading = true
        
        db.collection("users").document(userId)
            .collection("shoppingList")
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.isLoading = false
                    
                    if let error = error {
                        self.error = error
                        return
                    }
                    
                    self.shoppingItems = snapshot?.documents.compactMap { document in
                        try? document.data(as: ShoppingItem.self)
                    } ?? []
                }
            }
    }
    
    func saveItem(_ item: ShoppingItem) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        do {
            try db.collection("users").document(userId)
                .collection("shoppingList")
                .document(item.id ?? UUID().uuidString)
                .setData(from: item) { [weak self] error in
                    if error == nil {
                        DispatchQueue.main.async {
                            if let index = self?.shoppingItems.firstIndex(where: { $0.id == item.id }) {
                                self?.shoppingItems[index] = item
                            } else {
                                self?.shoppingItems.append(item)
                            }
                        }
                    }
                }
        } catch {
            self.error = error
        }
    }
    
    func deleteItem(_ item: ShoppingItem) {
        guard let userId = Auth.auth().currentUser?.uid,
              let itemId = item.id else { return }
        
        db.collection("users").document(userId)
            .collection("shoppingList")
            .document(itemId)
            .delete { [weak self] error in
                if error == nil {
                    DispatchQueue.main.async {
                        self?.shoppingItems.removeAll { $0.id == item.id }
                    }
                }
            }
    }
    
    func toggleItemCheck(_ item: ShoppingItem) {
        var updatedItem = item
        updatedItem.isChecked.toggle()
        saveItem(updatedItem)
    }
    
    func clearCheckedItems() {
        shoppingItems.filter { $0.isChecked }.forEach { deleteItem($0) }
    }
    
    func clearShoppingList() {
        shoppingItems = []
        error = nil
    }
}
