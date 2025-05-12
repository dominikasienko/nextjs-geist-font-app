import SwiftUI

struct ShoppingListView: View {
    @ObservedObject var viewModel: ShoppingListViewModel

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.groupedItems().keys.sorted(), id: \.self) { department in
                    Section(header: Text(department)) {
                        ForEach(viewModel.groupedItems()[department] ?? []) { item in
                            HStack {
                                Button(action: {
                                    viewModel.toggleItemSelection(item)
                                }) {
                                    Image(systemName: item.isSelected ? "checkmark.square" : "square")
                                }
                                .buttonStyle(BorderlessButtonStyle())
                                Text("\(item.quantity) \(item.name)")
                            }
                        }
                        .onDelete { indexSet in
                            let items = viewModel.groupedItems()[department] ?? []
                            let idsToDelete = indexSet.map { items[$0].id }
                            viewModel.shoppingList.items.removeAll { idsToDelete.contains($0.id) }
                        }
                    }
                }
            }
            .navigationTitle("Shopping List")
        }
    }
}
