import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

class RecipeViewModel: ObservableObject {
    @Published var recipes: [Recipe] = []
    @Published var favoriteRecipes: [Recipe] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Filter favorite recipes whenever recipes array changes
        $recipes
            .map { recipes in
                recipes.filter { $0.isFavorite }
            }
            .assign(to: &$favoriteRecipes)
    }
    
    func fetchRecipes() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        isLoading = true
        
        db.collection("users").document(userId)
            .collection("recipes")
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.isLoading = false
                    
                    if let error = error {
                        self.error = error
                        return
                    }
                    
                    self.recipes = snapshot?.documents.compactMap { document in
                        try? document.data(as: Recipe.self)
                    } ?? []
                }
            }
    }
    
    func addRecipe(_ recipe: Recipe, completion: @escaping (Error?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        do {
            try db.collection("users").document(userId)
                .collection("recipes")
                .document(recipe.id)
                .setData(from: recipe) { [weak self] error in
                    if error == nil {
                        DispatchQueue.main.async {
                            self?.recipes.append(recipe)
                        }
                    }
                    completion(error)
                }
        } catch {
            completion(error)
        }
    }
    
    func updateRecipe(_ recipe: Recipe, completion: @escaping (Error?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        do {
            try db.collection("users").document(userId)
                .collection("recipes")
                .document(recipe.id)
                .setData(from: recipe) { [weak self] error in
                    if error == nil {
                        DispatchQueue.main.async {
                            if let index = self?.recipes.firstIndex(where: { $0.id == recipe.id }) {
                                self?.recipes[index] = recipe
                            }
                        }
                    }
                    completion(error)
                }
        } catch {
            completion(error)
        }
    }
    
    func deleteRecipe(_ recipe: Recipe) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(userId)
            .collection("recipes")
            .document(recipe.id)
            .delete { [weak self] error in
                if error == nil {
                    DispatchQueue.main.async {
                        self?.recipes.removeAll { $0.id == recipe.id }
                    }
                }
            }
    }
    
    func toggleFavorite(_ recipe: Recipe) {
        var updatedRecipe = recipe
        updatedRecipe.isFavorite.toggle()
        
        updateRecipe(updatedRecipe) { [weak self] error in
            if let error = error {
                self?.error = error
            }
        }
    }
    
    func searchRecipes(query: String) -> [Recipe] {
        guard !query.isEmpty else { return recipes }
        
        let lowercasedQuery = query.lowercased()
        return recipes.filter { recipe in
            recipe.name.lowercased().contains(lowercasedQuery) ||
            recipe.category.lowercased().contains(lowercasedQuery) ||
            recipe.description.lowercased().contains(lowercasedQuery) ||
            recipe.ingredients.contains { $0.name.lowercased().contains(lowercasedQuery) }
        }
    }
    
    func clearRecipes() {
        recipes = []
        favoriteRecipes = []
        error = nil
        isLoading = false
    }
}
