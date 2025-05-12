import SwiftUI

struct AddRecipeView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: RecipeViewModel

    @State private var name: String = ""
    @State private var category: String = ""
    @State private var description: String = ""
    @State private var ingredients: [Ingredient] = []
    @State private var instructions: [String] = []
    @State private var newIngredientName: String = ""
    @State private var newIngredientQuantity: String = ""
    @State private var newInstruction: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Recipe Info")) {
                    TextField("Name", text: $name)
                    TextField("Category", text: $category)
                    TextField("Description", text: $description)
                }
                Section(header: Text("Ingredients")) {
                    ForEach(ingredients) { ingredient in
                        Text("\(ingredient.quantity) \(ingredient.name)")
                    }
                    HStack {
                        TextField("Quantity", text: $newIngredientQuantity)
                        TextField("Ingredient", text: $newIngredientName)
                        Button(action: addIngredient) {
                            Image(systemName: "plus.circle.fill")
                        }
                        .disabled(newIngredientName.isEmpty || newIngredientQuantity.isEmpty)
                    }
                }
                Section(header: Text("Instructions")) {
                    ForEach(instructions, id: \.self) { instruction in
                        Text(instruction)
                    }
                    HStack {
                        TextField("Add instruction", text: $newInstruction)
                        Button(action: addInstruction) {
                            Image(systemName: "plus.circle.fill")
                        }
                        .disabled(newInstruction.isEmpty)
                    }
                }
            }
            .navigationTitle("Add Recipe")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveRecipe()
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(name.isEmpty || ingredients.isEmpty || instructions.isEmpty)
                }
            }
        }
    }

    private func addIngredient() {
        let ingredient = Ingredient(name: newIngredientName, quantity: newIngredientQuantity)
        ingredients.append(ingredient)
        newIngredientName = ""
        newIngredientQuantity = ""
    }

    private func addInstruction() {
        instructions.append(newInstruction)
        newInstruction = ""
    }

    private func saveRecipe() {
        let recipe = Recipe(name: name, category: category, photoData: nil, description: description, ingredients: ingredients, instructions: instructions)
        viewModel.addRecipe(recipe)
    }
}
