import SwiftUI

struct FavoritesView: View {
    @ObservedObject var userProfileVM: UserProfileViewModel
    @ObservedObject var recipeVM: RecipeViewModel

    var favoriteRecipes: [Recipe] {
        guard let favoriteIDs = userProfileVM.userProfile?.favoriteRecipeIDs else { return [] }
        return recipeVM.recipes.filter { favoriteIDs.contains($0.id.uuidString) }
    }

    var body: some View {
        NavigationView {
            List {
                if favoriteRecipes.isEmpty {
                    Text("No favorite recipes yet.")
                        .foregroundColor(.gray)
                } else {
                    ForEach(favoriteRecipes) { recipe in
                        NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                            Text(recipe.name)
                        }
                    }
                }
            }
            .navigationTitle("Favorite Recipes")
        }
    }
}
