import SwiftUI
import FirebaseAuth

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var userProfileVM: UserProfileViewModel
    @EnvironmentObject var recipeVM: RecipeViewModel
    @State private var selectedTab = 0
    @State private var showingAddRecipe = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Welcome Section
                VStack(alignment: .leading, spacing: 8) {
                    if let user = authViewModel.currentUser {
                        Text("Welcome back,")
                            .font(.title2)
                        Text(userProfileVM.userProfile?.displayName ?? user.displayName ?? "Chef")
                            .font(.title)
                            .fontWeight(.bold)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                
                // Quick Actions
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        QuickActionButton(
                            title: "Add Recipe",
                            icon: "plus",
                            color: .blue
                        ) {
                            showingAddRecipe = true
                        }
                        
                        QuickActionButton(
                            title: "Meal Plan",
                            icon: "calendar",
                            color: .orange
                        ) {
                            selectedTab = 2 // Switch to Meal Plan tab
                        }
                        
                        QuickActionButton(
                            title: "Shopping List",
                            icon: "cart",
                            color: .purple
                        ) {
                            selectedTab = 3 // Switch to Shopping List tab
                        }
                        
                        QuickActionButton(
                            title: "Favorites",
                            icon: "heart.fill",
                            color: .red
                        ) {
                            selectedTab = 4 // Switch to Favorites tab
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Recent Recipes
                VStack(alignment: .leading, spacing: 16) {
                    Text("Recent Recipes")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    if recipeVM.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else if recipeVM.recipes.isEmpty {
                        Text("No recipes yet")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(recipeVM.recipes.prefix(5)) { recipe in
                                    NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                                        RecipeCard(recipe: recipe)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                // Favorite Recipes
                VStack(alignment: .leading, spacing: 16) {
                    Text("Favorites")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    if recipeVM.favoriteRecipes.isEmpty {
                        Text("No favorites yet")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(recipeVM.favoriteRecipes.prefix(5)) { recipe in
                                    NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                                        RecipeCard(recipe: recipe)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
        }
        .navigationTitle("Home")
        .sheet(isPresented: $showingAddRecipe) {
            NavigationView {
                AddRecipeView(viewModel: recipeVM)
            }
        }
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                Text(title)
                    .font(.caption)
            }
            .frame(width: 80, height: 80)
            .background(color.opacity(0.1))
            .foregroundColor(color)
            .cornerRadius(12)
        }
    }
}

struct RecipeCard: View {
    let recipe: Recipe
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
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
                .frame(width: 160, height: 120)
                .clipped()
                .cornerRadius(8)
            } else {
                Color.gray.opacity(0.3)
                    .frame(width: 160, height: 120)
                    .cornerRadius(8)
            }
            
            // Recipe Info
            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.name)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(recipe.category)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                if let nutritionInfo = recipe.nutritionInfo {
                    Text("\(Int(nutritionInfo.calories)) calories")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 160, alignment: .leading)
            
            if recipe.isFavorite {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
        .frame(width: 160)
        .padding(.bottom, 8)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 3)
    }
}

#Preview {
    NavigationView {
        HomeView()
            .environmentObject(AuthViewModel())
            .environmentObject(UserProfileViewModel())
            .environmentObject(RecipeViewModel())
    }
}
