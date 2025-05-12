import Foundation
import Combine

class RecipeViewModel: ObservableObject {
    @Published var recipes: [Recipe] = []
    @Published var searchText: String = ""

    var cancellables = Set<AnyCancellable>()

    init() {
        // Load initial data or from persistence
        loadRecipes()
        
        // Setup search filtering
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] searchTerm in
                self?.filterRecipes(searchTerm: searchTerm)
            }
            .store(in: &cancellables)
    }

    func loadRecipes() {
        // Load recipes from persistence or sample data
        // For MVP, start with empty or sample data
        recipes = []
    }

    func addRecipe(_ recipe: Recipe) {
        recipes.append(recipe)
        // Save to persistence
    }

    func updateRecipe(_ recipe: Recipe) {
        if let index = recipes.firstIndex(where: { $0.id == recipe.id }) {
            recipes[index] = recipe
            // Save to persistence
        }
    }

    func deleteRecipe(at offsets: IndexSet) {
        recipes.remove(atOffsets: offsets)
        // Save to persistence
    }

    private func filterRecipes(searchTerm: String) {
        if searchTerm.isEmpty {
            loadRecipes()
        } else {
            recipes = recipes.filter {
                $0.name.localizedCaseInsensitiveContains(searchTerm) ||
                $0.ingredients.contains(where: { $0.name.localizedCaseInsensitiveContains(searchTerm) })
            }
        }
    }
}
