import SwiftUI

struct RecipeListView: View {
    @ObservedObject var viewModel: RecipeViewModel
    @State private var searchText = ""
    @State private var selectedCategory: String?
    @State private var showingAddRecipe = false
    
    private var filteredRecipes: [Recipe] {
        var recipes = viewModel.recipes
        
        if let category = selectedCategory {
            recipes = recipes.filter { $0.category == category }
        }
        
        if !searchText.isEmpty {
            recipes = viewModel.searchRecipes(query: searchText)
        }
        
        return recipes
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Category Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        CategoryButton(title: "All",
                                    isSelected: selectedCategory == nil) {
                            selectedCategory = nil
                        }
                        
                        ForEach(Recipe.categories, id: \.self) { category in
                            CategoryButton(title: category,
                                        isSelected: selectedCategory == category) {
                                selectedCategory = category
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .background(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                } else if filteredRecipes.isEmpty {
                    EmptyStateView(
                        title: "No Recipes Found",
                        message: searchText.isEmpty ? "Add your first recipe!" : "Try adjusting your search"
                    )
                } else {
                    List {
                        ForEach(filteredRecipes) { recipe in
                            NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                                RecipeRow(recipe: recipe)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Recipes")
            .searchable(text: $searchText, prompt: "Search recipes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddRecipe = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddRecipe) {
                AddRecipeView(viewModel: viewModel)
            }
            .alert("Error", isPresented: .constant(viewModel.error != nil)) {
                Button("OK") {
                    viewModel.error = nil
                }
            } message: {
                if let error = viewModel.error {
                    Text(error.localizedDescription)
                }
            }
        }
    }
}

struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .fontWeight(isSelected ? .bold : .regular)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.accentColor : Color(.systemGray6))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

struct RecipeRow: View {
    let recipe: Recipe
    
    var body: some View {
        HStack(spacing: 12) {
            if let photoURL = recipe.photoURL,
               let url = URL(string: photoURL) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(width: 80, height: 80)
                .cornerRadius(8)
            } else {
                Color.gray.opacity(0.3)
                    .frame(width: 80, height: 80)
                    .cornerRadius(8)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.name)
                    .font(.headline)
                Text(recipe.category)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                if let nutritionInfo = recipe.nutritionInfo {
                    Text("\(Int(nutritionInfo.calories)) calories")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if recipe.isFavorite {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
            }
        }
        .padding(.vertical, 4)
    }
}

struct EmptyStateView: View {
    let title: String
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "book.closed")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(message)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

#Preview {
    RecipeListView(viewModel: RecipeViewModel())
}
