import SwiftUI

enum Tab: String, CaseIterable {
    case home = "Home"
    case recipes = "Recipes"
    case calendar = "Meal Plan"
    case shopping = "Shopping"
    case favorites = "Favorites"
    case settings = "Settings"
    
    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .recipes: return "book.fill"
        case .calendar: return "calendar"
        case .shopping: return "cart.fill"
        case .favorites: return "heart.fill"
        case .settings: return "gearshape.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .home: return .blue
        case .recipes: return .green
        case .calendar: return .orange
        case .shopping: return .purple
        case .favorites: return .red
        case .settings: return .gray
        }
    }
    
    @ViewBuilder
    func view(with viewModels: ViewModels) -> some View {
        switch self {
        case .home:
            HomeView()
                .environmentObject(viewModels.authVM)
                .environmentObject(viewModels.userProfileVM)
        case .recipes:
            RecipeListView(viewModel: viewModels.recipeVM)
        case .calendar:
            MealPlanView(viewModel: viewModels.mealPlanVM)
        case .shopping:
            ShoppingListView()
        case .favorites:
            FavoritesView()
        case .settings:
            SettingsView()
                .environmentObject(viewModels.authVM)
                .environmentObject(viewModels.userProfileVM)
        }
    }
}

struct ViewModels {
    let authVM: AuthViewModel
    let userProfileVM: UserProfileViewModel
    let recipeVM: RecipeViewModel
    let mealPlanVM: MealPlanViewModel
}

struct CustomTabBar: View {
    @Binding var selectedTab: Tab
    let viewModels: ViewModels
    
    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $selectedTab) {
                ForEach(Tab.allCases, id: \.self) { tab in
                    tab.view(with: viewModels)
                        .tag(tab)
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(Tab.allCases, id: \.self) { tab in
                        TabButton(
                            tab: tab,
                            isSelected: selectedTab == tab,
                            action: { selectedTab = tab }
                        )
                    }
                }
                .padding(.horizontal)
            }
            .background(
                Rectangle()
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: -5)
            )
        }
    }
}

struct TabButton: View {
    let tab: Tab
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: tab.icon)
                    .font(.system(size: 24))
                Text(tab.rawValue)
                    .font(.caption)
            }
            .foregroundColor(isSelected ? tab.color : .gray)
            .frame(width: 80, height: 50)
            .background(
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(tab.color.opacity(0.1))
                    }
                }
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    CustomTabBar(
        selectedTab: .constant(.home),
        viewModels: ViewModels(
            authVM: AuthViewModel(),
            userProfileVM: UserProfileViewModel(),
            recipeVM: RecipeViewModel(),
            mealPlanVM: MealPlanViewModel()
        )
    )
}
