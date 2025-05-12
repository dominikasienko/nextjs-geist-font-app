import SwiftUI

struct FavoritesView: View {
    @StateObject private var recipeVM = RecipeViewModel()
    @State private var searchText = ""
    
    var filteredRecipes: [Recipe] {
        let favoriteRecipes = recipeVM.recipes.filter { $0.isFavorite }
        if searchText.isEmpty {
            return favoriteRecipes
        }
        return favoriteRecipes.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.description.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationView {
            Group {
                if filteredRecipes.isEmpty {
                    EmptyFavoritesView()
                } else {
                    List {
                        ForEach(filteredRecipes) { recipe in
                            NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                                FavoriteRecipeRow(recipe: recipe)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .searchable(text: $searchText, prompt: "Search favorites")
            .navigationTitle("Favorites")
        }
        .onAppear {
            recipeVM.fetchRecipes()
        }
    }
}

struct EmptyFavoritesView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.3))
            
            Text("No Favorite Recipes")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("Add recipes to your favorites to see them here")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}

struct FavoriteRecipeRow: View {
    let recipe: Recipe
    
    var body: some View {
        HStack(spacing: 16) {
            if let photoURL = recipe.photoURL,
               let url = URL(string: photoURL) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(width: 60, height: 60)
                .cornerRadius(8)
            } else {
                Color.gray.opacity(0.3)
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.name)
                    .font(.headline)
                Text(recipe.category)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "heart.fill")
                .foregroundColor(.red)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    FavoritesView()
}
