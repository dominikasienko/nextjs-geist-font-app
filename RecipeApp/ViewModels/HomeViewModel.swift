import Foundation
import Combine

class HomeViewModel: ObservableObject {
    @Published var recentRecipes: [Recipe] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let recipeVM: RecipeViewModel
    private let mealPlanVM: MealPlanViewModel
    private var cancellables = Set<AnyCancellable>()
    
    init(recipeVM: RecipeViewModel = RecipeViewModel(), 
         mealPlanVM: MealPlanViewModel = MealPlanViewModel()) {
        self.recipeVM = recipeVM
        self.mealPlanVM = mealPlanVM
        setupBindings()
    }
    
    private func setupBindings() {
        recipeVM.$recipes
            .map { Array($0.prefix(5)) }
            .assign(to: &$recentRecipes)
    }
    
    func fetchRecentRecipes() {
        isLoading = true
        recipeVM.fetchRecipes()
    }
    
    func navigateToMealPlan() -> MealPlanView {
        MealPlanView(viewModel: mealPlanVM)
    }
    
    func navigateToAddRecipe() -> AddRecipeView {
        AddRecipeView(viewModel: recipeVM)
    }
    
    func clearError() {
        errorMessage = nil
    }
}
