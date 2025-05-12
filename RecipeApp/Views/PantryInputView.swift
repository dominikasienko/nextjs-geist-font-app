import SwiftUI

struct PantryInputView: View {
    @ObservedObject var viewModel: PantryViewModel
    @State private var ingredientName: String = ""
    @State private var ingredientQuantity: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Add Ingredient")) {
                    TextField("Ingredient Name", text: $ingredientName)
                    TextField("Quantity", text: $ingredientQuantity)
                    Button("Add") {
                        let ingredient = Ingredient(name: ingredientName, quantity: ingredientQuantity)
                        viewModel.addIngredient(ingredient)
                        ingredientName = ""
                        ingredientQuantity = ""
                    }
                    .disabled(ingredientName.isEmpty || ingredientQuantity.isEmpty)
                }
                Section(header: Text("Your Pantry")) {
                    List {
                        ForEach(viewModel.pantry.ingredients) { ingredient in
                            Text("\(ingredient.quantity) \(ingredient.name)")
                        }
                        .onDelete(perform: viewModel.removeIngredient)
                    }
                }
            }
            .navigationTitle("Pantry")
        }
    }
}
