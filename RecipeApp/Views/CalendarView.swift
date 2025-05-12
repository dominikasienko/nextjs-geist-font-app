import SwiftUI

struct CalendarView: View {
    @StateObject private var mealPlanVM = MealPlanViewModel()
    @State private var selectedDate = Date()
    @State private var showingRecipePicker = false
    @State private var selectedMealType: MealPlan.MealType = .dinner
    @State private var showingAlert = false
    
    private let calendar = Calendar.current
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Calendar
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding()
                .onChange(of: selectedDate) { newDate in
                    mealPlanVM.fetchMealPlans(for: newDate)
                }
                
                // Meal Type Selector
                Picker("Meal Type", selection: $selectedMealType) {
                    ForEach(MealPlan.MealType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Meal Plans List
                List {
                    if let plans = mealPlanVM.mealPlans[calendar.startOfDay(for: selectedDate)] {
                        ForEach(plans.filter { $0.mealType == selectedMealType }) { plan in
                            MealPlanRow(plan: plan)
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        mealPlanVM.deleteMealPlan(plan, at: selectedDate)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                        
                        if plans.filter({ $0.mealType == selectedMealType }).isEmpty {
                            Text("No meals planned for \(selectedMealType.rawValue.lowercased())")
                                .foregroundColor(.secondary)
                                .italic()
                        }
                    }
                }
                .listStyle(PlainListStyle())
                
                // Add Meal Plan Button
                Button(action: { showingRecipePicker = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add \(selectedMealType.rawValue)")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding()
                }
            }
            .navigationTitle("Meal Planner")
            .sheet(isPresented: $showingRecipePicker) {
                RecipePickerView(selectedDate: selectedDate, mealType: selectedMealType) { recipe in
                    let mealPlan = MealPlan(
                        recipeId: recipe.id,
                        recipeName: recipe.name,
                        date: selectedDate,
                        mealType: selectedMealType
                    )
                    mealPlanVM.addMealPlan(mealPlan)
                    showingRecipePicker = false
                }
            }
            .alert("Error", isPresented: .constant(mealPlanVM.errorMessage != nil)) {
                Button("OK") {
                    mealPlanVM.clearError()
                }
            } message: {
                if let errorMessage = mealPlanVM.errorMessage {
                    Text(errorMessage)
                }
            }
            .onAppear {
                mealPlanVM.fetchMealPlans(for: selectedDate)
            }
        }
    }
}

struct MealPlanRow: View {
    let plan: MealPlan
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(plan.recipeName)
                .font(.headline)
            
            if let notes = plan.notes {
                Text(notes)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct RecipePickerView: View {
    let selectedDate: Date
    let mealType: MealPlan.MealType
    let onSelect: (Recipe) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var recipeVM = RecipeViewModel()
    @State private var searchText = ""
    
    var filteredRecipes: [Recipe] {
        if searchText.isEmpty {
            return recipeVM.recipes
        }
        return recipeVM.recipes.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationView {
            List(filteredRecipes) { recipe in
                Button(action: { onSelect(recipe) }) {
                    Text(recipe.name)
                }
            }
            .searchable(text: $searchText, prompt: "Search recipes")
            .navigationTitle("Select Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    CalendarView()
}
