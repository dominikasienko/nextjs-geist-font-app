import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var userProfileVM = UserProfileViewModel()
    @StateObject private var recipeVM = RecipeViewModel()
    @StateObject private var mealPlanVM = MealPlanViewModel()
    @StateObject private var shoppingListVM = ShoppingListViewModel()
    @State private var selectedTab: Tab = .home
    
    private var viewModels: ViewModels {
        ViewModels(
            authVM: authViewModel,
            userProfileVM: userProfileVM,
            recipeVM: recipeVM,
            mealPlanVM: mealPlanVM
        )
    }
    
    var body: some View {
        Group {
            if authViewModel.currentUser != nil {
                NavigationView {
                    CustomTabBar(selectedTab: $selectedTab, viewModels: viewModels)
                        .environmentObject(authViewModel)
                        .environmentObject(userProfileVM)
                        .environmentObject(recipeVM)
                        .environmentObject(mealPlanVM)
                        .environmentObject(shoppingListVM)
                }
                .navigationViewStyle(StackNavigationViewStyle())
            } else {
                AuthenticationView()
                    .environmentObject(authViewModel)
                    .environmentObject(userProfileVM)
            }
        }
        .onAppear {
            authViewModel.checkAuthStatus()
        }
        .onChange(of: authViewModel.currentUser) { user in
            if user != nil {
                // Load user data when authenticated
                userProfileVM.fetchUserProfile()
                recipeVM.fetchRecipes()
                // Reset tab to home when logging in
                selectedTab = .home
            } else {
                // Clear data when logging out
                userProfileVM.clearUserProfile()
                recipeVM.clearRecipes()
                mealPlanVM.clearMealPlans()
                shoppingListVM.clearShoppingList()
            }
        }
    }
}

struct AuthenticationView: View {
    @State private var showingRegistration = false
    @State private var showingForgotPassword = false
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                if authViewModel.isAuthenticating {
                    ProgressView("Authenticating...")
                } else {
                    LoginView()
                        .navigationBarHidden(true)
                }
            }
            .sheet(isPresented: $showingRegistration) {
                NavigationView {
                    RegistrationView()
                }
            }
            .sheet(isPresented: $showingForgotPassword) {
                NavigationView {
                    ForgotPasswordView()
                }
            }
            .alert("Error", isPresented: .constant(authViewModel.error != nil)) {
                Button("OK") {
                    authViewModel.error = nil
                }
            } message: {
                if let error = authViewModel.error {
                    Text(error.localizedDescription)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
