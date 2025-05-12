import SwiftUI

struct NutritionInfoView: View {
    let recipe: Recipe
    @StateObject private var nutritionVM = NutritionViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading = false
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView("Calculating nutrition info...")
                } else {
                    List {
                        Section(header: Text("Nutrition Facts")) {
                            if let nutritionInfo = nutritionVM.nutritionInfo {
                                NutritionRow(title: "Calories", value: "\(Int(nutritionInfo.calories)) kcal")
                                NutritionRow(title: "Protein", value: "\(Int(nutritionInfo.protein))g")
                                NutritionRow(title: "Carbohydrates", value: "\(Int(nutritionInfo.carbs))g")
                                NutritionRow(title: "Fat", value: "\(Int(nutritionInfo.fat))g")
                                NutritionRow(title: "Fiber", value: "\(Int(nutritionInfo.fiber))g")
                                
                                Section(header: Text("Per Ingredient")) {
                                    ForEach(recipe.ingredients) { ingredient in
                                        if let info = nutritionVM.ingredientNutrition[ingredient.name] {
                                            IngredientNutritionRow(
                                                ingredient: ingredient,
                                                calories: info.calories,
                                                protein: info.protein
                                            )
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Nutrition Information")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                calculateNutrition()
            }
        }
    }
    
    private func calculateNutrition() {
        isLoading = true
        nutritionVM.calculateNutrition(for: recipe) { result in
            isLoading = false
            switch result {
            case .success:
                break
            case .failure(let error):
                errorMessage = error.localizedDescription
                showingError = true
            }
        }
    }
}

struct NutritionRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}

struct IngredientNutritionRow: View {
    let ingredient: Ingredient
    let calories: Double
    let protein: Double
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(ingredient.name)
                .font(.headline)
            HStack {
                Text("\(Int(calories)) kcal")
                Text("•")
                Text("\(Int(protein))g protein")
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NutritionInfoView(recipe: Recipe(
        id: UUID().uuidString,
        name: "Sample Recipe",
        category: "Main Course",
        description: "A sample recipe",
        ingredients: [
            Ingredient(name: "Chicken Breast", quantity: "200g"),
            Ingredient(name: "Rice", quantity: "100g")
        ],
        instructions: ["Step 1", "Step 2"],
        photoURL: nil,
        isFavorite: false,
        nutritionInfo: nil
    ))
}
