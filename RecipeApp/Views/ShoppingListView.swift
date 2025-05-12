import SwiftUI

struct ShoppingListView: View {
    @StateObject private var shoppingListVM = ShoppingListViewModel()
    @State private var selectedDates: Set<Date> = []
    @State private var showingDatePicker = false
    @State private var showingSortOptions = false
    @State private var groupByDepartment = true
    
    private var groupedItems: [(String, [ShoppingItem])] {
        if groupByDepartment {
            let grouped = Dictionary(grouping: shoppingListVM.shoppingItems) { item in
                item.department ?? "Other"
            }
            return grouped.sorted { $0.key < $1.key }
        } else {
            return [("All Items", shoppingListVM.shoppingItems)]
        }
    }
    
    init() {
        _viewModel = StateObject(wrappedValue: ShoppingListViewModel())
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Date Selection Section
                VStack(alignment: .leading, spacing: 8) {
                    Button(action: { showingDatePicker = true }) {
                        HStack {
                            Image(systemName: "calendar")
                            Text(selectedDates.isEmpty ? "Select Dates" : "\(selectedDates.count) days selected")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .shadow(radius: 1)
                    }
                    
                    if !selectedDates.isEmpty {
                        Text(formatSelectedDates())
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                
                // Shopping List
                if shoppingListVM.isLoading {
                    ProgressView("Generating shopping list...")
                } else if shoppingListVM.shoppingItems.isEmpty {
                    EmptyStateView()
                } else {
                    ShoppingListContent(
                        groupedItems: groupedItems,
                        onToggleItem: shoppingListVM.toggleItemCheck
                    )
                }
                
                // Generate Button
                if !selectedDates.isEmpty {
                    Button(action: {
                        shoppingListVM.generateShoppingList(for: Array(selectedDates))
                    }) {
                        HStack {
                            Image(systemName: "list.bullet")
                            Text("Generate Shopping List")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding()
                    }
                }
            }
            .navigationTitle("Shopping List")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { groupByDepartment.toggle() }) {
                            Label(
                                groupByDepartment ? "Show All Items" : "Group by Department",
                                systemImage: groupByDepartment ? "list.bullet" : "folder"
                            )
                        }
                        
                        Button(action: { shoppingListVM.clearCheckedItems() }) {
                            Label("Clear Checked Items", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingDatePicker) {
                DatePickerView(selectedDates: $selectedDates)
            }
            .alert("Error", isPresented: .constant(shoppingListVM.errorMessage != nil)) {
                Button("OK") {
                    shoppingListVM.clearError()
                }
            } message: {
                if let errorMessage = shoppingListVM.errorMessage {
                    Text(errorMessage)
                }
            }
        }
    }
    
    private func formatSelectedDates() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        let sortedDates = selectedDates.sorted()
        return sortedDates.map { formatter.string(from: $0) }.joined(separator: ", ")
    }
}

struct ShoppingListContent: View {
    let groupedItems: [(String, [ShoppingItem])]
    let onToggleItem: (ShoppingItem) -> Void
    
    var body: some View {
        List {
            ForEach(groupedItems, id: \.0) { department, items in
                Section(header: Text(department)) {
                    ForEach(items) { item in
                        ShoppingItemRow(item: item, onToggle: onToggleItem)
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
}

struct ShoppingItemRow: View {
    let item: ShoppingItem
    let onToggle: (ShoppingItem) -> Void
    
    var body: some View {
        HStack {
            Button(action: { onToggle(item) }) {
                Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(item.isChecked ? .green : .gray)
            }
            
            VStack(alignment: .leading) {
                Text(item.name)
                    .strikethrough(item.isChecked)
                Text(item.quantity)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func generateFromMealPlan() {
        // Generate shopping list from meal plan recipes
        let mealPlanRecipes = recipeVM.recipes.filter { recipe in
            // Logic to filter recipes in meal plan
            true // Placeholder
        }
        
        for recipe in mealPlanRecipes {
            for ingredient in recipe.ingredients {
                let item = ShoppingItem(
                    name: ingredient.name,
                    quantity: ingredient.quantity,
                    isChecked: false
                )
                viewModel.saveItem(item)
            }
        }
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "cart")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Items")
                .font(.title2)
            
            Text("Select dates to generate your shopping list")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

#Preview {
    ShoppingListView()
}
