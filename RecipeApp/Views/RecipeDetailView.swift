import SwiftUI
import FirebaseFirestore
import FirebaseStorage

struct RecipeDetailView: View {
    let recipe: Recipe
    @StateObject private var nutritionVM = NutritionViewModel()
    @State private var showingNutritionInfo = false
    @State private var isFavorite: Bool
    @EnvironmentObject var recipeVM: RecipeViewModel
    
    init(recipe: Recipe) {
        self.recipe = recipe
        _isFavorite = State(initialValue: recipe.isFavorite)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Recipe Image
                if let photoURL = recipe.photoURL,
                   let url = URL(string: photoURL) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .frame(height: 250)
                    .clipped()
                } else {
                    Color.gray.opacity(0.3)
                        .frame(height: 250)
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    // Recipe Header
                    HStack {
                        VStack(alignment: .leading) {
                            Text(recipe.name)
                                .font(.title)
                                .fontWeight(.bold)
                            Text(recipe.category)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button(action: toggleFavorite) {
                            Image(systemName: isFavorite ? "heart.fill" : "heart")
                                .font(.title2)
                                .foregroundColor(isFavorite ? .red : .gray)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Description
                    if !recipe.description.isEmpty {
                        Text(recipe.description)
                            .padding(.horizontal)
                    }
                    
                    // Nutrition Button
                    Button(action: { showingNutritionInfo = true }) {
                        HStack {
                            Image(systemName: "chart.bar.fill")
                            Text("View Nutrition Information")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                    
                    // Ingredients
                    Section(header: SectionHeader(title: "Ingredients")) {
                        ForEach(recipe.ingredients) { ingredient in
                            HStack {
                                Text("•")
                                Text(ingredient.name)
                                Spacer()
                                Text(ingredient.quantity)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Instructions
                    Section(header: SectionHeader(title: "Instructions")) {
                        ForEach(Array(recipe.instructions.enumerated()), id: \.offset) { index, instruction in
                            HStack(alignment: .top) {
                                Text("\(index + 1).")
                                    .fontWeight(.bold)
                                    .frame(width: 25, alignment: .leading)
                                Text(instruction)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingNutritionInfo) {
            NutritionInfoView(recipe: recipe)
        }
    }
    
    private func toggleFavorite() {
        isFavorite.toggle()
        recipeVM.toggleFavorite(recipe)
    }
}

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.title2)
            .fontWeight(.bold)
            .padding(.horizontal)
            .padding(.top)
    }
}

#Preview {
    NavigationView {
        RecipeDetailView(recipe: Recipe(
            id: UUID().uuidString,
            name: "Sample Recipe",
            category: "Main Course",
            description: "A delicious sample recipe",
            ingredients: [
                Ingredient(name: "Ingredient 1", quantity: "1 cup"),
                Ingredient(name: "Ingredient 2", quantity: "2 tbsp")
            ],
            instructions: [
                "Step 1: Do something",
                "Step 2: Do something else"
            ],
            photoURL: nil,
            isFavorite: false
        ))
        .environmentObject(RecipeViewModel())
    }
}
